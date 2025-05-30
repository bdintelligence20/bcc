package com.ruoyi.file.service;

import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.file.domain.FileBean;
import com.ruoyi.file.domain.StorageBean;
import com.ruoyi.file.dto.DownloadFileDTO;
import com.ruoyi.file.dto.PreviewDTO;
import com.ruoyi.file.dto.UploadFileDTO;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

public interface IFiletransferService {


    /**
     * 上传文件
     * @param request 请求
     * @param UploadFileDto 文件信息
     */
    void uploadFile(HttpServletRequest request, UploadFileDTO UploadFileDto, Long userId);

    AjaxResult downloadImage(String imagePath, String batch);

    void downloadFile(HttpServletResponse httpServletResponse, DownloadFileDTO downloadFileDTO);

    /**
     * 预览文件
     * @param httpServletResponse
     * @param previewDTO
     */
    void previewFile(HttpServletResponse httpServletResponse, PreviewDTO previewDTO);

    void deleteFile(FileBean fileBean);

    StorageBean selectStorageBean(StorageBean storageBean);

    void insertStorageBean(StorageBean storageBean);

    void updateStorageBean(StorageBean storageBean);

    StorageBean selectStorageByUser(StorageBean storageBean);

    Long selectStorageSizeByUserId(Long userId);
}
