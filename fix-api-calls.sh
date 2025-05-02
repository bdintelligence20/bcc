#!/bin/bash

# This script fixes the API calls in the frontend by directly modifying the API files

echo "Fixing API calls in the frontend..."

# Create a backup directory
mkdir -p backup/api/apiList

# Backup the original API files
cp -r beiqi-home-master/beiqi-home-master/api/apiList/* backup/api/apiList/

# Fix the home.js file
cat > beiqi-home-master/beiqi-home-master/api/apiList/home.js << 'EOF'
export default (axios) => ({
  menuList: (data) => axios({ url: '/home-api/index/tree', method: 'get', params: data }),
  getBanner: (data) => axios({ url: '/home-api/index/getAllBannerList', method: 'get', params: data }),
  productNavList: (data) => axios({ url: '/home-api/vehicle/class', method: 'get', params: data }),
  getSection: (data) => axios({ url: '/home-api/index/show', method: 'get', params: data }),
  getCarlist: (data) => axios({ url: '/home-api/index/class/home', method: 'get', params: data }),
  // 获取首页新闻
  getNews: (data) => axios({ url: '/home-api/index/newsShow', method: 'get', params: data }),
  getMap: (data) => axios({ url: '/home-api/contact/country', method: 'get', params: data }),
})
EOF

# Fix the footer.js file
cat > beiqi-home-master/beiqi-home-master/api/apiList/footer.js << 'EOF'
export default (axios) => ({
  getWebConfig: (data) => axios({ url: '/home-api/website/webConfig/getWebConfig', method: 'post', data: data }),
  newsList: (data) => axios({ url: '/home-api/website/news/rlist/', method: 'get', params: data }),
})
EOF

# Fix the contact.js file
if [ -f beiqi-home-master/beiqi-home-master/api/apiList/contact.js ]; then
  cat > beiqi-home-master/beiqi-home-master/api/apiList/contact.js << 'EOF'
export default (axios) => ({
  getArea: (data) => axios({ url: '/home-api/area', method: 'get', params: data }),
  getCountry: (data) => axios({ url: '/home-api/contact/country', method: 'get', params: data }),
  getCity: (data) => axios({ url: '/home-api/contact/city', method: 'get', params: data }),
  getDealer: (data) => axios({ url: '/home-api/contact/dealer', method: 'get', params: data }),
  getDistributor: (data) => axios({ url: '/home-api/contact/distributor', method: 'get', params: data }),
  getDistributorDetail: (data) => axios({ url: '/home-api/contact/distributor/detail', method: 'get', params: data }),
  getDistributorList: (data) => axios({ url: '/home-api/contact/distributor/list', method: 'get', params: data }),
  getDistributorMap: (data) => axios({ url: '/home-api/contact/distributor/map', method: 'get', params: data }),
  getDistributorMapList: (data) => axios({ url: '/home-api/contact/distributor/map/list', method: 'get', params: data }),
  getDistributorMapDetail: (data) => axios({ url: '/home-api/contact/distributor/map/detail', method: 'get', params: data }),
})
EOF
fi

# Fix the distributor.js file
if [ -f beiqi-home-master/beiqi-home-master/api/apiList/distributor.js ]; then
  cat > beiqi-home-master/beiqi-home-master/api/apiList/distributor.js << 'EOF'
export default (axios) => ({
  login: (data) => axios({ url: '/home-api/login', method: 'post', data: data }),
  getInfo: (data) => axios({ url: '/home-api/getInfo', method: 'get', params: data }),
  logout: (data) => axios({ url: '/home-api/logout', method: 'post', data: data }),
  captchaImage: (data) => axios({ url: '/home-api/captchaImage', method: 'get', params: data }),
  getDistributorInfo: (data) => axios({ url: '/home-api/distributor/info', method: 'get', params: data }),
  updateDistributorInfo: (data) => axios({ url: '/home-api/distributor/info', method: 'put', data: data }),
  getDistributorList: (data) => axios({ url: '/home-api/distributor/list', method: 'get', params: data }),
  getDistributorDetail: (data) => axios({ url: '/home-api/distributor/detail', method: 'get', params: data }),
  addDistributor: (data) => axios({ url: '/home-api/distributor', method: 'post', data: data }),
  updateDistributor: (data) => axios({ url: '/home-api/distributor', method: 'put', data: data }),
  deleteDistributor: (data) => axios({ url: '/home-api/distributor', method: 'delete', data: data }),
})
EOF
fi

# Fix the job.js file
if [ -f beiqi-home-master/beiqi-home-master/api/apiList/job.js ]; then
  cat > beiqi-home-master/beiqi-home-master/api/apiList/job.js << 'EOF'
export default (axios) => ({
  getJobList: (data) => axios({ url: '/home-api/job/list', method: 'get', params: data }),
  getJobDetail: (data) => axios({ url: '/home-api/job/detail', method: 'get', params: data }),
  applyJob: (data) => axios({ url: '/home-api/job/apply', method: 'post', data: data }),
})
EOF
fi

# Fix the news.js file
if [ -f beiqi-home-master/beiqi-home-master/api/apiList/news.js ]; then
  cat > beiqi-home-master/beiqi-home-master/api/apiList/news.js << 'EOF'
export default (axios) => ({
  getNewsList: (data) => axios({ url: '/home-api/news/list', method: 'get', params: data }),
  getNewsDetail: (data) => axios({ url: '/home-api/news/detail', method: 'get', params: data }),
  getNewsCategory: (data) => axios({ url: '/home-api/news/category', method: 'get', params: data }),
  getNewsTag: (data) => axios({ url: '/home-api/news/tag', method: 'get', params: data }),
  getNewsRelated: (data) => axios({ url: '/home-api/news/related', method: 'get', params: data }),
  getNewsHot: (data) => axios({ url: '/home-api/news/hot', method: 'get', params: data }),
  getNewsRecommend: (data) => axios({ url: '/home-api/news/recommend', method: 'get', params: data }),
})
EOF
fi

# Fix the product.js file
if [ -f beiqi-home-master/beiqi-home-master/api/apiList/product.js ]; then
  cat > beiqi-home-master/beiqi-home-master/api/apiList/product.js << 'EOF'
export default (axios) => ({
  getProductList: (data) => axios({ url: '/home-api/product/list', method: 'get', params: data }),
  getProductDetail: (data) => axios({ url: '/home-api/product/detail', method: 'get', params: data }),
  getProductCategory: (data) => axios({ url: '/home-api/product/category', method: 'get', params: data }),
  getProductTag: (data) => axios({ url: '/home-api/product/tag', method: 'get', params: data }),
  getProductRelated: (data) => axios({ url: '/home-api/product/related', method: 'get', params: data }),
  getProductHot: (data) => axios({ url: '/home-api/product/hot', method: 'get', params: data }),
  getProductRecommend: (data) => axios({ url: '/home-api/product/recommend', method: 'get', params: data }),
})
EOF
fi

# Fix the testDrive.js file
if [ -f beiqi-home-master/beiqi-home-master/api/apiList/testDrive.js ]; then
  cat > beiqi-home-master/beiqi-home-master/api/apiList/testDrive.js << 'EOF'
export default (axios) => ({
  getTestDriveList: (data) => axios({ url: '/home-api/testDrive/list', method: 'get', params: data }),
  getTestDriveDetail: (data) => axios({ url: '/home-api/testDrive/detail', method: 'get', params: data }),
  applyTestDrive: (data) => axios({ url: '/home-api/testDrive/apply', method: 'post', data: data }),
})
EOF
fi

echo "Done!"
