/**
 * Author: SHI
 * Date: 2022/7/20
 * Remark: vue-tel-input
 */

import Vue from 'vue';

// Only run on client-side to avoid browser API errors in SSR
if (process.client) {
  const VueTelInput = require('vue-tel-input');
  // Use the default country list provided by the library
  Vue.use(VueTelInput);
}
