import Vue from 'vue';

// Only run on client-side to avoid browser API errors in SSR
if (process.client) {
  const echarts = require('echarts/core'); // 引入echarts核心api

  // 引入饼图图表，图表后缀都为 Chart
  const { PieChart } = require('echarts/charts');
  // 引入数据集，组件后缀都为 Component
  const { DatasetComponent } = require('echarts/components');
  // 全局过渡动画
  const { UniversalTransition } = require('echarts/features');
  // 引入 Canvas 渲染器，注意引入 CanvasRenderer 或者 SVGRenderer 是必须的一步
  const { CanvasRenderer } = require('echarts/renderers');

  // 注册必须的组件
  echarts.use([
    DatasetComponent,
    PieChart,
    UniversalTransition,
    CanvasRenderer
  ])

  Vue.prototype.$echarts = echarts // 引入组件（将echarts注册为全局）
}
