/*
 * @Author: 不二
 * @Date: 2023-08-25 14:11:33
 * @LastEditTime: 2025-04-29 15:39:00
 */
import Vue from 'vue'

// Only run on client-side to avoid requestAnimationFrame errors in SSR
if (process.client) {
  const VueAnimateNumber = require('vue-animate-number')
  Vue.use(VueAnimateNumber)
}
