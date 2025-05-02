#!/bin/bash

# Update axios.js
cat > plugins/axios.js << 'EOF'
import { Message } from 'element-ui'
import { getToken, removeToken } from '~/utils/token'

const errorCode = {
  401: '认证失败，无法访问系统资源',
  403: '当前操作没有权限',
  404: '访问资源不存在',
  default: '系统未知错误，请反馈给管理员',
}

function isSubStringInArray(subString, array) {
  return array.some(item => subString.includes(item))
}

export default function ({$axios, i18n, route, redirect}) {
  // console.log(redirect)
  // 基本配置
  $axios.defaults.timeout = 10000
  $axios.defaults.headers.post['Content-Type'] = 'application/json'
  $axios.defaults.headers.patch['Content-Type'] = 'application/json'
  $axios.defaults.headers.put['Content-Type'] = 'application/json'

  // 不需要加多语言的接口
  let filterateUrl = [
    "/newLabel",
    "/captchaImage",
    "/login",
    "/getInfo",
    "/getAllMaterialList",
    "/user",
    '/getPyteNewLabel',
    '/PyteNewLabel',
    '/materialLog',
  ]

  // 请求回调
  $axios.onRequest(
    config => {
      console.log(config.url, 'config.url')

      // Already has /home-api or /api or /geoip prefix
      if (config.url.startsWith('/home-api') || config.url.startsWith('/api') || config.url.startsWith('/geoip') || config.url.startsWith('/file')) {
        // Do nothing, URL already has the correct prefix
        if (config.url.startsWith('/home-api') || config.url.startsWith('/api')) {
          config.headers['Authorization'] = getToken()
        }
      } else {
        // Add prefix based on URL type
        if (isSubStringInArray(config.url, filterateUrl)) {
          config.url = '/home-api' + config.url
          config.headers['Authorization'] = getToken()
        } else {
          config.url = '/home-api' + config.url + '/' + i18n.locale
        }
      }

      // console.log('onRequest:'+config.url)
      // get请求映射params参数
      // if (config.method === 'get' && config.params) {
      //   let url = config.url + '?' + tansParams(config.params)
      //   url = url.slice(0, -1)
      //   config.params = {}
      //   config.url = url
      // }
      return config
    },
    error => {
      return Promise.reject(error)
    }
  )

  // 返回回调
  $axios.onResponse(res => {
    // console.log('onResponse:'+res.config.url)
    // 未设置状态码则默认成功状态
    const code = res.data.code || 200
    // 获取错误信息
    const msg = errorCode[code] || res.data.msg || errorCode['default']
    // 二进制数据则直接返回
    if (res.request.responseType === 'blob' || res.request.responseType === 'arraybuffer') {
      return res.data
    }
    if (code !== 200) {
      if (isSubStringInArray(res.config.url, filterateUrl)) {
        // token过期,需重新登录
        if (code == 401) {
          Message({message: 'Login status has expired, please log in again', type: 'error'})
          // 清除token
          removeToken()
          localStorage.removeItem('user')
          // 跳转到登录页
          redirect('/distributorCenter/login')
          return
        } else {
          Message({message: msg, type: 'error'})
        }
      }
      // 在页面里处理,不要全局报错
      Message({message: msg, type: 'error'})
      return Promise.reject(new Error(msg))
    } else {
      return res.data
    }
  })

  // 错误回调
  $axios.onError(error => {
    console.error(error)
  })
}
EOF

# Update vue-animate-number.js
cat > plugins/vue-animate-number.js << 'EOF'
import Vue from 'vue'

// Only run on client-side to avoid requestAnimationFrame errors in SSR
if (process.client) {
  const VueAnimateNumber = require('vue-animate-number')
  Vue.use(VueAnimateNumber)
}
EOF

# Update vue-echarts.js
cat > plugins/vue-echarts.js << 'EOF'
import Vue from 'vue';

// Only run on client-side to avoid browser API errors in SSR
if (process.client) {
  const echarts = require('echarts/core');

  // Import chart components
  const { PieChart } = require('echarts/charts');
  const { DatasetComponent } = require('echarts/components');
  const { UniversalTransition } = require('echarts/features');
  const { CanvasRenderer } = require('echarts/renderers');

  // Register components
  echarts.use([
    DatasetComponent,
    PieChart,
    UniversalTransition,
    CanvasRenderer
  ])

  Vue.prototype.$echarts = echarts
}
EOF

# Update vue-lazyload.js
cat > plugins/vue-lazyload.js << 'EOF'
import Vue from 'vue'

// Only run on client-side to avoid browser API errors in SSR
if (process.client) {
  const VueLazyload = require('vue-lazyload')
  // or with options
  Vue.use(VueLazyload, {
    preLoad: 1.3,
    loading: '',
    attempt: 1,
    throttleWait: 100,
    observer: true
  })
}
EOF

# Update vue-tel-input.js
cat > plugins/vue-tel-input.js << 'EOF'
import Vue from 'vue';

// Only run on client-side to avoid browser API errors in SSR
if (process.client) {
  const VueTelInput = require('vue-tel-input');
  // Use the default country list provided by the library
  Vue.use(VueTelInput);
}
EOF

# Update mq.js
cat > plugins/mq.js << 'EOF'
import Vue from 'vue'

// Only run on client-side to avoid browser API errors in SSR
if (process.client) {
  const VueMq = require('vue-mq')
  Vue.use(VueMq, {
    // should always be matching tailwind breakpoints
    breakpoints: {
      xs: 768,
      sm: 992,
      md: 1200,
      lg: 1920,
      xl: Infinity
    },
    defaultBreakpoint: 'lg'
  })
}
EOF

# Update swiper.js
cat > plugins/swiper.js << 'EOF'
import Vue from "vue";
import "swiper/dist/css/swiper.css";
if (process.client) {
  const VueAwesomeSwiper = require("vue-awesome-swiper/dist/ssr");
  Vue.use(VueAwesomeSwiper);
}
EOF

echo "Plugins updated successfully!"
