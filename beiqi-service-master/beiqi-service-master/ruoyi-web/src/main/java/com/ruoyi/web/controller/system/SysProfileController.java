package com.ruoyi.web.controller.system;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.config.EmailConfig;
import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.EmailService;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.file.FileUploadUtils;
import com.ruoyi.common.utils.file.MimeTypeUtils;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.util.SendMailUtil;
import com.ruoyi.website.domain.vo.UpdatePwdVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

import static com.ruoyi.system.util.SendMailUtil.sendMailUtil;

/**
 * 个人信息 业务处理
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/system/user/profile")
public class SysProfileController extends BaseController
{
    @Autowired
    private ISysUserService userService;

    @Autowired
    private TokenService tokenService;

    @Autowired
    RedisTemplate redisTemplate;

    @Autowired
    EmailService emailService;

    @Autowired
    private EmailConfig emailConfig;

    /**
     * 个人信息
     */
    @GetMapping
    public AjaxResult profile()
    {
        LoginUser loginUser = tokenService.getLoginUser(ServletUtils.getRequest());
        SysUser user = loginUser.getUser();
        AjaxResult ajax = AjaxResult.success(user);
        ajax.put("roleGroup", userService.selectUserRoleGroup(loginUser.getUsername()));
        ajax.put("postGroup", userService.selectUserPostGroup(loginUser.getUsername()));
        return ajax;
    }

    /**
     * 修改用户
     */
    @Log(title = "个人信息", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult updateProfile(@RequestBody SysUser user)
    {
        if (StringUtils.isNotEmpty(user.getPhonenumber())
                && UserConstants.NOT_UNIQUE.equals(userService.checkPhoneUnique(user)))
        {
            return AjaxResult.error("修改用户'" + user.getUserName() + "'失败，手机号码已存在");
        }
        if (StringUtils.isNotEmpty(user.getEmail())
                && UserConstants.NOT_UNIQUE.equals(userService.checkEmailUnique(user)))
        {
            return AjaxResult.error("修改用户'" + user.getUserName() + "'失败，邮箱账号已存在");
        }
        if (userService.updateUserProfile(user) > 0)
        {
            LoginUser loginUser = tokenService.getLoginUser(ServletUtils.getRequest());
            // 更新缓存用户信息
            loginUser.getUser().setNickName(user.getNickName());
            loginUser.getUser().setPhonenumber(user.getPhonenumber());
            loginUser.getUser().setEmail(user.getEmail());
            loginUser.getUser().setSex(user.getSex());
            tokenService.setLoginUser(loginUser);
            return AjaxResult.success();
        }
        return AjaxResult.error("修改个人信息异常，请联系管理员");
    }

    /**
     * 重置密码
     */
    @Log(title = "个人信息", businessType = BusinessType.UPDATE)
    @PutMapping("/updatePwd")
    public AjaxResult updatePwd(String oldPassword, String newPassword)
    {
        LoginUser loginUser = tokenService.getLoginUser(ServletUtils.getRequest());
        String userName = loginUser.getUsername();
        String password = loginUser.getPassword();
        if (!SecurityUtils.matchesPassword(oldPassword, password))
        {
            return AjaxResult.error("修改密码失败，旧密码错误");
        }
        if (SecurityUtils.matchesPassword(newPassword, password))
        {
            return AjaxResult.error("新密码不能与旧密码相同");
        }
        if (userService.updateUserPassword(userName, SecurityUtils.encryptPassword(newPassword)) > 0)
        {
            // 更新缓存用户密码
            loginUser.getUser().setPassword(SecurityUtils.encryptPassword(newPassword));
            tokenService.setLoginUser(loginUser);
            return AjaxResult.success();
        }
        return AjaxResult.error("修改密码异常，请联系管理员");
    }


    /**
     * 头像上传
     */
    @Log(title = "用户头像", businessType = BusinessType.UPDATE)
    @PostMapping("/avatar")
    public AjaxResult avatar(@RequestParam("avatarfile") MultipartFile file) throws Exception
    {
        if (!file.isEmpty())
        {
            LoginUser loginUser = getLoginUser();
            String avatar = FileUploadUtils.upload2(RuoYiConfig.getAvatarPath(), file, MimeTypeUtils.IMAGE_EXTENSION);
            if (userService.updateUserAvatar(loginUser.getUsername(), avatar))
            {
                AjaxResult ajax = AjaxResult.success();
                ajax.put("imgUrl", avatar);
                // 更新缓存用户头像
                loginUser.getUser().setAvatar(avatar);
                tokenService.setLoginUser(loginUser);
                return ajax;
            }
        }
        return AjaxResult.error("上传图片异常，请联系管理员");
    }

    /**
     * 邮件发送验证码
     */
    @RequestMapping("/retrieve")
    public AjaxResult retrieve_sendCode(@RequestBody Map<String, Object> json) {
        try {
            String email = (String) json.get("email");
            String userName = (String) json.get("userName");
            SendMailUtil sendMailUtil = new SendMailUtil();
            if (!sendMailUtil.isEmail(email)) {
                return AjaxResult.error("邮箱格式不正确");
            } else {
                ValueOperations<String, String> operations = redisTemplate.opsForValue();
                if(operations.get(email)!=null){
                    return AjaxResult.error("验证码已发送,请三分钟后重试");
                }
                else {
                    EmailConfig.RetrieveConfig retrieveConfig = emailConfig.getRetrieve();
                    StringBuilder code = sendMailUtil.CreateCode();
                    operations.set(email, String.valueOf(code));
                    Map<String, Object> kvs = new HashMap<>();
                    kvs.put("code",code);
                    kvs.put("userName",userName);
                    redisTemplate.expire(email, 3, TimeUnit.MINUTES);
                    if (retrieveConfig.isEnabled()){
                        String from = retrieveConfig.getFrom();
                        emailService.send(EmailService.EmailTemplate.RETRIEVE,"verification message",from,email,null,kvs);
                    }
                    return AjaxResult.success("验证码发送成功");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return AjaxResult.error("出现未知错误");
        }
    }

    /**
     * 找回密码
     */
    @PostMapping("/saveRetrieve")
    public AjaxResult SaveRetrieve(@RequestBody Map<String, Object> json) throws Exception {
        String password= (String) json.get("password");
        String repassword= (String) json.get("repassword");
        String email= (String) json.get("email");
        String code= (String) json.get("code");
        String userName = (String) json.get("userName");
        ValueOperations<String, String> operations = redisTemplate.opsForValue();
        String get_code= operations.get(email);
        SendMailUtil sendMailUtil=new SendMailUtil();
        String message="";
        int SureInformation=1;
        if(!sendMailUtil.CheckPassword(password,repassword)||password.length()<3) {
            SureInformation = 0;
            message= "两次密码不匹配或者密码过短";
        }
        if(get_code==null|| !Objects.equals(code, get_code)){
            SureInformation=0;
            message = "邮箱或验证码不正确";
        }
        if(SureInformation==1) {
            if (userService.updateUserPwd(userName,email, SecurityUtils.encryptPassword(password)) > 0)
            {
                return AjaxResult.success();
            }
            return AjaxResult.error("修改密码异常，请联系管理员");
        }

        return AjaxResult.error(message);
    }

    /**
     * 重置密码
     */
    @Log(title = "个人信息", businessType = BusinessType.UPDATE)
    @PutMapping("/updatePasswordd")
    public AjaxResult updatePasswordd(@RequestBody UpdatePwdVO updatePwdVO)
    {
        String email = updatePwdVO.getEmail();
        String newPassword = updatePwdVO.getNewPassword();
        String repassword = updatePwdVO.getRepassword();
        String code = updatePwdVO.getCode();
        LoginUser loginUser = tokenService.getLoginUser(ServletUtils.getRequest());
        ValueOperations<String, String> operations = redisTemplate.opsForValue();
        String get_code= operations.get(email);
        if(get_code==null|| !Objects.equals(code, get_code)){
            return AjaxResult.error("邮箱错误");
        }
        String userName = loginUser.getUsername();
        /*SysUser user = userService.selectUserByUserNameByEmail(userName, email);
        if (user == null){
            return AjaxResult.error("邮箱错误");
        }*/
        if(!sendMailUtil.CheckPassword(newPassword,repassword)||newPassword.length()<3) {
            return AjaxResult.error("两次密码不匹配或者密码过短");
        }
        if (userService.resetUserPwd(email, userName, SecurityUtils.encryptPassword(newPassword)) > 0)
        {
            // 更新缓存用户密码
            loginUser.getUser().setPassword(SecurityUtils.encryptPassword(newPassword));
            tokenService.setLoginUser(loginUser);
            return AjaxResult.success();
        }
        return AjaxResult.error("修改密码异常，请联系管理员");
    }

}
