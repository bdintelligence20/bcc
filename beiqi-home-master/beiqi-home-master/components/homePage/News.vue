<template>
  <div>
    <mq-layout :mq="['xl','lg','md','sm']">
      <div class="news-container main wow animate__slideInUp">
        <el-row :gutter="3" type="flex">
          <el-col :span="8" class="img-box"  v-for="(item, index) in newsList" :key="index">
            <a v-if="item.linkUrl.includes('http') || !item.linkUrl" :href="item.linkUrl ? item.linkUrl : false" target="_blank" class="news-item"  @mouseenter="expandTitle(item.id)" @mouseleave="collapseTitle(item.id)">
              <img v-lazy="item.imageUrl ? baseUrl + item.imageUrl : ''" :alt="item.alt" class="news-image"/>
              <div :class="{'expanded': isExpanded && item.id === currentIndex}" class="new-item-text-wrap">
                <div class="text-title">{{ item.title }}</div>
              </div>
            </a>

            <nuxt-link v-else :to="localePath(item.linkUrl)" class="news-item" @mouseenter.native="expandTitle(item.id)" @mouseleave.native="collapseTitle(item.id)">
              <img v-lazy="item.imageUrl ? baseUrl + item.imageUrl: ''" :alt="item.describe" class="news-image">
              <div :class="{'expanded': isExpanded && item.id === currentIndex}" class="new-item-text-wrap">
                <div class="text-title">{{ item.title }}</div>
              </div>
            </nuxt-link>
          </el-col>
          <!-- <el-col :span="16">
            <el-row :gutter="2" type="flex">
              <el-col>
                <nuxt-link v-if="newsList[2]" :to="localePath(newsList[2].linkUrl)"
                           class="news-item"
                           @mouseenter.native="expandTitle(newsList[2].id)"
                           @mouseleave.native="collapseTitle(newsList[2].id)">
                  <img v-lazy="newsList[2].imageUrl ? baseUrl + newsList[2].imageUrl : ''" :alt="newsList[2].describe" class="news-image">
                  <div :class="{'expanded': isExpanded && newsList[2].id === currentIndex}" class="new-item-text-wrap">
                    <div class="text-title">{{ newsList[2].title }}</div>
                  </div>
                </nuxt-link>
              </el-col>
              <el-col>
                <nuxt-link v-if="newsList[3]" :to="localePath(newsList[3].linkUrl)"
                           class="news-item"
                           @mouseenter.native="expandTitle(newsList[3].id)"
                           @mouseleave.native="collapseTitle(newsList[3].id)">
                  <img v-lazy="newsList[3].imageUrl ? baseUrl + newsList[3].imageUrl : ''" :alt="newsList[3].describe" class="news-image">
                  <div :class="{'expanded': isExpanded && newsList[3].id === currentIndex}" class="new-item-text-wrap">
                    <div class="text-title">{{ newsList[3].title }}</div>
                  </div>
                </nuxt-link>
              </el-col>
            </el-row>
            <el-row :gutter="2" class="mt2">
              <el-col v-if="newsList[1]">
                <a v-if="newsList[1].linkUrl.includes('http') || !newsList[1].linkUrl" :href="newsList[1].linkUrl ? newsList[1].linkUrl : false" target="_blank" class="news-item item-1">
                  <img v-lazy="newsList[1].imageUrl ? baseUrl + newsList[1].imageUrl : ''" :alt="newsList[1].describe" class="news-image">
                </a>
                <nuxt-link v-else :to="newsList[1].linkUrl" class="news-item item-1">
                  <img v-lazy="newsList[1].imageUrl ? baseUrl + newsList[1].imageUrl : ''" :alt="newsList[1].describe" class="news-image">
                </nuxt-link>
              </el-col>
            </el-row>
          </el-col> -->
        </el-row>
        <!-- <el-row :gutter="2" class="mt2" type="flex">
          <el-col>
            <nuxt-link v-if="newsList[4]" :to="localePath(newsList[4].linkUrl)" class="news-item"
                       @mouseenter.native="expandTitle(newsList[4].id)"
                       @mouseleave.native="collapseTitle(newsList[4].id)">
              <img v-lazy="newsList[4].imageUrl ? baseUrl + newsList[4].imageUrl : ''" :alt="newsList[4].describe" class="news-image">
              <div :class="{'expanded': isExpanded && newsList[4].id === currentIndex}" class="new-item-text-wrap">
                <div class="text-title">{{ newsList[4].title }}</div>
              </div>
            </nuxt-link>
          </el-col>
          <el-col>
            <nuxt-link v-if="newsList[5]" :to="localePath(newsList[5].linkUrl)" class="news-item"
                       @mouseenter.native="expandTitle(newsList[5].id)"
                       @mouseleave.native="collapseTitle(newsList[5].id)">
              <img v-lazy="newsList[5].imageUrl ? baseUrl + newsList[5].imageUrl : ''" :alt="newsList[5].describe" class="news-image">
              <div :class="{'expanded': isExpanded && newsList[5].id === currentIndex}" class="new-item-text-wrap">
                <div class="text-title">{{ newsList[5].title }}</div>
              </div>
            </nuxt-link>
          </el-col>
          <el-col>
            <nuxt-link v-if="newsList[6]" :to="localePath(newsList[6].linkUrl)" class="news-item"
                       @mouseenter.native="expandTitle(newsList[6].id)"
                       @mouseleave.native="collapseTitle(newsList[6].id)">
              <img v-lazy="newsList[6].imageUrl ? baseUrl + newsList[6].imageUrl : ''" :alt="newsList[6].describe" class="news-image">
              <div :class="{'expanded': isExpanded && newsList[6].id === currentIndex}" class="new-item-text-wrap">
                <div class="text-title">{{ newsList[6].title }}</div>
              </div>
            </nuxt-link>
          </el-col>
        </el-row> -->
        <div class="bottom-btn">
          <nuxt-link :to="localePath('/news/newsRelease?id=31', $i18n.locale)">
            <el-button class="border-el-button show-more-btn">
              {{ $t('btn.showMore') }}
            </el-button>
          </nuxt-link>
        </div>
      </div>
    </mq-layout>
    <mq-layout mq="xs">
      <div v-swiper:newsSwiper="swiperOption" class="swiper" @slideChange="handleSlideChange">
        <div class="swiper-wrapper">
          <div v-for="(item, index) in newsList" :key="index" class="swiper-slide">
            <a v-if="item.linkUrl.includes('http') || !item.linkUrl" :href="item.linkUrl ? item.linkUrl : false" target="_blank">
              <img v-lazy="item.mobileImageUrl ? baseUrl + item.mobileImageUrl : ''" :alt="item.alt" class="image"/>
              <div v-if="item.title" class="title-wrap">
                <div class="title-body">
                  <div class="title text-uppercase">{{ item.title }}</div>
                </div>
              </div>
            </a>

            <nuxt-link v-else :to="item.linkUrl">
              <img v-lazy="item.mobileImageUrl ? baseUrl + item.mobileImageUrl : ''" :alt="item.alt" class="image"/>
              <div v-if="item.title" class="title-wrap">
                <div class="title-body">
                  <div class="title text-uppercase">{{ item.title }}</div>
                </div>
              </div>
            </nuxt-link>
          </div>
        </div>

        <div class="swiper-button swiper-button-prev"></div>
        <div class="swiper-button swiper-button-next"></div>
        <div slot="pagination" class="swiper-pagination swiper-pagination-bullets"></div>
        <div class="page">
          {{ currentPage }} -
          <span class="total">{{ newsList.length }}</span>
        </div>
      </div>
    </mq-layout>
  </div>
</template>

<script>
import NewsImageBanner from '@/components/img/banner'

if (process.browser) {
  // 在这里根据环境引入wow.js
  var {WOW} = require('wow.js/dist/wow')
}

export default {
  name: "HomePageNews",
  components: {NewsImageBanner},
  props: {
    newsList: Array
  },
  data() {
    return {
      baseUrl: process.env.imgBaseUrl,
      isExpanded: false,
      currentIndex: null,
      currentPage: 1,
      swiperOption: {
        pagination: {
          el: '.swiper-pagination',
          clickable: true,
          renderBullet(index, className) {
            return `<div class="${className} swiper-pagination-bullet-custom"></div>`
          },
        },
        navigation: {
          nextEl: '.swiper-button-next',
          prevEl: '.swiper-button-prev',
        }
      }
    }
  },

  mounted() {
    this.wowFun()
  },

  methods: {
    handleSlideChange() {
      this.currentPage = this.newsSwiper.realIndex + 1
    },
    wowFun() {
      this.$nextTick(() => {
        if (process.browser) {
          const wow = new WOW({
            boxClass: 'wow', // 需要执行动画的元素的 class
            animateClass: 'animate__animated', // Animate.css 动画的 class
            offset: 0, // 距离可视区域多少开始执行动画
            mobile: true, // 是否在移动设备上执行动画
            live: true // 异步加载的内容是否有效
          });
          wow.init();
        }
      })
    },
    expandTitle(id) {
      this.currentIndex = id
      this.isExpanded = true
    },
    collapseTitle(id) {
      this.currentIndex = id
      this.isExpanded = false
    }
  },
}
</script>

<style lang="scss" scoped>
.el-row {
  flex-wrap: wrap;
}
.news-item {
  position: relative;
  display: block;
  overflow: hidden;
  margin-bottom: 3px;
  background-color: transparent;
  &::before {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    opacity: 0;
    transition: all 0.4s;
    background-image: linear-gradient(to bottom, rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.5));
    z-index: 1;
  }
  img {
    width: 100%;
  }

  &:hover {
    &::before {
      opacity: 1; // 鼠标悬停时显示遮罩层
    }
    .news-image {
      transform: scale(1.1);
    }
  }

  .new-item-text-wrap {
    position: absolute;
    bottom: 0;
    max-height: 3.8em;
    transition: all .4s;
    z-index: 2;

    .text-title {
      padding: 20px;
      font-size: 20px;
      color: #fff;
      text-transform: uppercase;
    }
  }

  .expanded {
    //显示全部标题
    max-height: 100%;
  }

  .news-image {
    transition: transform .4s; /* 添加过渡效果 */
    transform: scale(1);
  }
}

.bottom-btn {
  display: flex;
  justify-content: center;
  margin-top: 3.646vw;

  .show-more-btn {
    padding: 1.042vw 3.646vw;
  }
}

@media only screen and (max-width: 768px) {
  .swiper-wrapper {
    padding-bottom: 50px;
  }
  .swiper-slide {
    position: relative;
    width: 100%;
  }
  .title-wrap {
    position: absolute;
    width: 100%;
    left: 0;
    bottom: 0;
    background: url("~/assets/image/home/wap/news-bg.jpg") no-repeat;
    .title-body {
      color: #fff;
      width: 85%;
      margin: 0 auto;
      padding: 15px 0;
      text-align: center;
    }
  }
  .page {
    position: absolute;
    bottom: 10px;
    right: 10px;
    font-size: 12px;

    .total {
      opacity: .4;
    }
  }

  .swiper-button {
    width: 40px;
    height: 40px;
    margin-top: -20px;
    background-size: 100% 100%;
  }

  .swiper-button-prev {
    background-image: url("../../assets/image/home/wap/prev.png");
  }
  .swiper-button-next {
    background-image: url("../../assets/image/home/wap/next.png");
  }

  ::v-deep .swiper-pagination-bullet-custom {
    width: 30px;
    height: 2px;
    border-radius: 0;
    background-color: #9a9fa6;
    opacity: 0.3;
    transition: 0.3s;

    &.swiper-pagination-bullet-active {
      opacity: 1;
      transition: 0.3s;
      background: #d13232;
    }
  }
}
</style>
