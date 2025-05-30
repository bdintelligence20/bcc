import Cookies from 'js-cookie'
import config from '@/config'
import {getToken} from '@/utils/auth'
import {Message} from 'element-ui';
import TurndownService from 'turndown'
import showdown from 'showdown'
import showdownKatex from 'showdown-katex'
// 全局函数
const globalFunction = {
  formatVideoTime(timestamp) {
    if (!timestamp){
      return ''
    }
    let timeMs = timestamp/1000;
    let hours = parseInt(timeMs/3600);
    let mini = parseInt(timeMs%3600/60);
    let second = Math.ceil(timeMs%60);
    if (hours > 0){
      return hours + ':' + mini + ':' + second;
    } else {
      return mini + ':' + second;
    }
  },
  previewPicture(url) {
    const index = url.lastIndexOf(".");
    //获取后缀
    const ext = url.substr(index + 1);
    const imageUrl = {
      fileUrl: url,
      downloadLink: url,
      fileName: '预览图',
      extendName: ext
    };
    let data = {
      imgPreviewVisible: true,
      imgPreviewList: [imageUrl],
      activeIndex: 0
    };
    this.$store.commit('setImgPreviewData', data)
  },
  /**
   * 将Markdown转成Html
   * @param text
   */
  markdownToHtml: text => {
    let converter = new showdown.Converter({
      tables: true,
      extensions: [
        showdownKatex({
          // maybe you want katex to throwOnError
          throwOnError: true,
          // disable displayMode
          displayMode: false,
          // change errorColor to blue
          errorColor: '#1500ff',
        }),
      ],
    });
    let html = converter.makeHtml(text)
    return html;
  },
  /**
   * 将Html转成Markdown
   * @param text
   */
  htmlToMarkdown: text => {
    var turndownService = new TurndownService()
    // 用于提取代码语言
    turndownService.addRule('CodeBlock', {
      filter: function (node, options) {
        return (
          node.nodeName === 'PRE' &&
          node.firstChild &&
          node.firstChild.nodeName === 'CODE'
        )
      },
      replacement: function (content, node, options) {
        var className = node.firstChild.getAttribute('class') || ''
        var language = (className.match(/language-(\S+)/) || [null, ''])[1]
        return (
          '\n\n' + options.fence + language + '\n' +
          node.firstChild.textContent +options.fence
        )
      }
    })

    // 提取数学公式进行转换
    turndownService.addRule('multiplemath', {
      filter (node, options) {
        return node.classList.contains('vditor-math')
      },
      replacement (content, node, options) {
        // console.log("中间内容", node.firstChild.textContent)
        return `$$ \n${node.firstChild.textContent}\n $$`
      }
    })
    var turndownPluginGfm = require('turndown-plugin-gfm')
    var gfm = turndownPluginGfm.gfm
    var tables = turndownPluginGfm.tables
    var strikethrough = turndownPluginGfm.strikethrough
    turndownService.use(gfm)
    turndownService.use([tables, strikethrough])
    return turndownService.turndown(text)
  },
  /**
   * 将Html转成Markdown文件
   * @param title：标题
   * @param text：正文
   */
  htmlToMarkdownFile: (title, text) => {
    title = title || "默认标题"
    let turndownService = new TurndownService()
    let markdown = turndownService.turndown(text)
    //创建一个blob对象,file的一种
    let blob = new Blob([markdown])
    let aLink = document.createElement('a')
    aLink.style.display = 'none'
    aLink.href = URL.createObjectURL(blob)
    aLink.setAttribute('download', title + '.md') // 设置下载文件名称
    document.body.appendChild(aLink)
    aLink.click()
    URL.revokeObjectURL(aLink.href);//清除引用
    document.body.removeChild(aLink);
  },
  /**
   * 格式化文件大小
   * @param {number} size 文件大小
   * @returns {string} 文件大小（带单位）
   */
  calculateFileSize: function (size) {
    const B = 1024
    const KB = Math.pow(1024, 2)
    const MB = Math.pow(1024, 3)
    const GB = Math.pow(1024, 4)
    if (!size) {
      return '_'
    } else if (size < KB) {
      return (size / B).toFixed(0) + 'KB'
    } else if (size < MB) {
      return (size / KB).toFixed(1) + 'MB'
    } else if (size < GB) {
      return (size / MB).toFixed(2) + 'GB'
    } else {
      return (size / GB).toFixed(3) + 'TB'
    }
  },
  previewVideo(url) {
    window.open(process.env.VUE_APP_FILE_UOLOAD_HOST + url);
  },


  /**
   * 获取图片缩略图路径
   * @param {object} row 文件信息
   * @returns {string} 图片缩略图路径
   */
  getImgMinPath: function (row) {
    return process.env.VUE_APP_BASE_API + `/filetransfer/preview?userFileId=${row.userFileId}&isMin=true&shareBatchNum=${row.shareBatchNum}&extractionCode=${row.extractionCode}&token=${getToken()}`
  },
  /**
   * 获取文件查看路径
   * @param {object} row 文件信息
   * @returns {string} 文件路径
   */
  getViewFilePath: function (row) {
    return process.env.VUE_APP_BASE_API + `/filetransfer/preview?userFileId=${row.userFileId}&isMin=false&shareBatchNum=${row.shareBatchNum}&extractionCode=${row.extractionCode}&token=${getToken()}`
  },
  /**
   * 获取文件下载路径
   * @param {object} row 文件信息
   * @returns {string}  文件下载路径
   */
  getDownloadFilePath: function (row) {
    return process.env.VUE_APP_BASE_API + `/filetransfer/downloadfile?userFileId=${row.userFileId}&token=${getToken()}`
  },
  /**
   * 获取 office 文件在线预览路径
   * @param {object} row
   * @returns {string} office 文件在线预览路径
   */
  getFileOnlineViewPathByOffice: function (row) {
    let fileUrl = `${location.protocol}//${location.host}${process.env.VUE_APP_BASE_API}/filetransfer/preview?userFileId=${row.userFileId}&isMin=false&shareBatchNum=${row.shareBatchNum}&extractionCode=${row.extractionCode}&token=${getToken()}`
    //return `https://view.officeapps.live.com/op/embed.aspx?src=${fileUrl}`
    return `http://ow365.cn/?i=24998&ssl=1&furl=${fileUrl}`
  },
  /**
   * 设置 Cookies
   * @param {string} name 名称
   * @param {string} value 值
   * @param {object} others 域名、路径、有效期等，封装到对象中
   */
  setCookies: function (name, value, others = null) {
    Cookies.set(name, value, {domain: config.domain, ...others})
  },
  /**
   * 获取 Cookies
   * @param {string} name 名称
   * @param {object} others 域名、路径等，封装到对象中
   * @returns {string} Cookies 值
   */
  getCookies: function (name, others = null) {
    return Cookies.get(name, {domain: config.domain, ...others})
  },
  /**
   * 移除 Cookies
   * @param {string} name 名称
   * @param {object} others 域名、路径等，封装到对象中
   */
  removeCookies: function (name, others = null) {
    Cookies.remove(name, {domain: config.domain, ...others})
  },
  /**
   * 获取分享链接
   * @param {string} shareBatchNum
   * @returns {string} 完整的分享链接
   */
  getShareLink: function (shareBatchNum) {
    return `${location.protocol}//${location.host}/share/${shareBatchNum}`
  },
  /**
   * 复制分享链接
   * @param {string} shareBatchNum
   * @param {string} extractionCode
   */
  copyShareLink: function (shareBatchNum, extractionCode) {
    let input = document.createElement('textarea') // 直接构建textarea以保持换行
    input.value =
      extractionCode === null
        ? `分享链接：${this.getShareLink(
        shareBatchNum
        )}\n复制链接到浏览器中并输入提取码即可查看文件`
        : `分享链接：${this.getShareLink(shareBatchNum)}\n提取码：${extractionCode
          }\n复制链接到浏览器中并输入提取码即可查看文件` // 设置内容
    document.body.appendChild(input) // 添加临时实例
    input.select() // 选择实例内容
    document.execCommand('Copy') // 执行复制
    document.body.removeChild(input) // 删除临时实例
    Message.success('复制成功')
  }
}

export default globalFunction
