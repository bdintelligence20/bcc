#!/bin/bash

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
