// Production version of nuxt.config.js for deployment
import I18N from './plugins/i18n'

export default {
  // Target: https://go.nuxtjs.dev/config-target
  target: 'static',

  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    title: 'beiqi',
    htmlAttrs: {
      lang: 'en',
    },
    meta: [{ charset: 'utf-8' }, { name: 'viewport', content: 'width=device-width, initial-scale=1' }, { hid: 'description', name: 'description', content: 'my website description' }, { name: 'format-detection', content: 'telephone=no' }],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      { rel: 'preconnect', href: 'https://www.facebook.com' }
    ],
    script: [
      {
        innerHTML: `
        var browserType = function(from){
          var explorer = from.toLowerCase();
          var isIe = false;
          if (explorer.indexOf('msie') >= 0 || explorer.indexOf('rv:11.0') >= 0) {
             isIe = true;
           }
           return isIe;
           }
          var loggedIE = browserType(window.navigator.userAgent);
          if (loggedIE) {
             document.cookie="isIe=true";
              var nowHref = window.location.href
              if(nowHref.indexOf('ie') < 0) {
                window.location.pathname= "/ie";
              }
          } else {
           document.cookie="isIe=false";
          }
         `,
        defer: true
      },
      {
        innerHTML: `
        !(function (f, b, e, v, n, t, s) {
          if (f.fbq) return;
          n = f.fbq = function () {
            n.callMethod ? n.callMethod.apply(n, arguments) : n.queue.push(arguments);
          };
          if (!f._fbq) f._fbq = n;
          n.push = n;
          n.loaded = !0;
          n.version = "2.0";
          n.queue = [];
          t = b.createElement(e);
          t.async = !0;
          t.src = v;
          s = b.getElementsByTagName(e)[0];
          s.parentNode.insertBefore(t, s);
        })(
          window,
          document,
          "script",
          "https://connect.facebook.net/en_US/fbevents.js"
        );
        fbq("init", "SECRT-ID");
        fbq("track", "PageView");
         `,
        async: true
      },
    ],
    __dangerouslyDisableSanitizers: ['script'],
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: [
    'element-ui/lib/theme-chalk/index.css',
    '@/assets/scss/main.scss',
    'normalize.css/normalize.css',
    'animate.css/animate.css',
  ],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: [
    '@/plugins/mq',
    '@/plugins/news',
    '@/plugins/element-ui',
    { src: '@/plugins/vue-lazyload', ssr: false },
    { src: '@/plugins/swiper', ssr: false },
    '@/plugins/axios',
    '@/plugins/api-plugin',
    { src: './plugins/gtag.js', mode: 'client' },
    { src: './plugins/vue-tel-input.js', ssr: false },
    { src: '@/plugins/vue-animate-number', ssr: false },
    { src: '@/plugins/vue-echarts.js', ssr: false },
  ],
  
  components: true,

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: ['@nuxtjs/axios', '@nuxtjs/style-resources', ['@nuxtjs/i18n', I18N]],
  
  env: {
    imgBaseUrl: '/file',
  },
  
  axios: {
    proxy: true,
    prefix: '',
  },
  
  // Updated proxy configuration for production
  proxy: {
    '/home-api': {
      target: 'http://localhost:7071', // This will be handled by Nginx on the same server
      changeOrigin: true,
    },
    '/api': {
      target: 'http://localhost:7070', // This will be handled by Nginx on the same server
      changeOrigin: true,
    },
    '/file': {
      target: 'http://localhost:7071/home-api', // This will be handled by Nginx on the same server
      changeOrigin: true,
      pathRewrite: { '^/file': '/file' }
    },
    '/geoip': {
      target: 'http://localhost:3000', // This will be handled by Nginx on the same server
      changeOrigin: true,
    },
  },
  
  styleResources: {
    scss: ['~/assets/scss/variables.scss', '~/assets/scss/mixins.scss'],
  },
  
  build: {
    transpile: [/^element-ui/],
    extractCSS: true,
    optimizeCSS: true,
    loaders: {
      imgUrl: { limit: 8192 },
    }
  },
  
  router: {
    base: '/',
    prefetchLinks: false
  },
  
  server: {
    host: '0.0.0.0',
    port: 3000,
  },
}
