import path from 'path'

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
    { src: '@/plugins/swiper', mode: 'client' },
    { src: '@/plugins/vue-lazyload', mode: 'client' },
    { src: '@/plugins/vue-animate-number', mode: 'client' },
    { src: '@/plugins/vue-echarts', mode: 'client' },
    { src: '@/plugins/vue-tel-input', mode: 'client' },
    { src: '@/plugins/mq', mode: 'client' },
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
    '@nuxtjs/eslint-module',
    '@nuxtjs/composition-api/module'
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    // https://go.nuxtjs.dev/axios
    '@nuxtjs/axios',
    '@nuxtjs/proxy',
    '@nuxtjs/style-resources',
    '@nuxtjs/i18n'
  ],

  // i18n configuration
  i18n: {
    locales: [
      { code: 'en', iso: 'en-US', file: 'en.js' },
      { code: 'es', iso: 'es-ES', file: 'es.js' },
      { code: 'ar', iso: 'ar-SA', file: 'ar.js' }
    ],
    defaultLocale: 'en',
    langDir: 'locales/',
    vueI18n: {
      fallbackLocale: 'en'
    },
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'i18n_redirected',
      redirectOn: 'root'
    },
    strategy: 'prefix_except_default',
    parsePages: false
  },

  // Global SCSS variables
  styleResources: {
    scss: [
      '~/assets/scss/variables.scss',
      '~/assets/scss/mixins.scss'
    ]
  },

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
    extend(config, { isClient }) {
      // Fix asset resolution
      config.resolve.alias['~assets'] = path.resolve(__dirname, './assets');
      
      // Make file resolution case-insensitive
      config.resolve.plugins = config.resolve.plugins || [];
      
      // Add proper handling for webp files
      const webpRule = {
        test: /\.(webp)$/i,
        loader: 'file-loader',
        options: {
          name: '[path][name].[ext]'
        }
      };
      config.module.rules.push(webpRule);

      // Add proper handling for i18n blocks in Vue components
      config.module.rules.push({
        resourceQuery: /blockType=i18n/,
        type: 'javascript/auto',
        loader: '@intlify/vue-i18n-loader'
      });
    }
  },

  router: {
    middleware: ['browserVersion', 'axiosMiddle']
  }
}
