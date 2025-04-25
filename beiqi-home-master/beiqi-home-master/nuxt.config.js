export default {
  server: {
    host: '0.0.0.0',
    port: 8080
  },
  
  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    title: 'BAIC',
    htmlAttrs: {
      lang: 'en'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' }
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
    ]
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: [
    'element-ui/lib/theme-chalk/index.css',
    '@/assets/scss/index.scss'
  ],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: [
    '@/plugins/element-ui',
    '@/plugins/i18n',
    '@/plugins/swiper',
    '@/plugins/vue-lazyload',
    '@/plugins/vue-animate-number',
    '@/plugins/vue-echarts',
    '@/plugins/vue-tel-input',
    '@/plugins/mq',
    '@/plugins/nav',
    '@/plugins/news',
    '@/plugins/api-plugin',
    { src: '@/plugins/gtag', mode: 'client' }
  ],

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: true,

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
    // https://go.nuxtjs.dev/eslint
    '@nuxtjs/eslint-module'
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    // https://go.nuxtjs.dev/axios
    '@nuxtjs/axios',
    '@nuxtjs/proxy'
  ],

  // Axios module configuration: https://go.nuxtjs.dev/config-axios
  axios: {
    proxy: true
  },

  proxy: {
    '/home-api': {
      target: 'https://web-backend-dot-baic-457613.appspot.com',
      changeOrigin: true
    },
    '/api': {
      target: 'https://baic-457613.appspot.com',
      changeOrigin: true
    },
    '/geoip': {
      target: 'https://geoip-RANDOM_HASH-uc.a.run.app',
      changeOrigin: true
    }
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {
    transpile: [/^element-ui/],
  },

  router: {
    middleware: ['browserVersion', 'axiosMiddle']
  }
}
