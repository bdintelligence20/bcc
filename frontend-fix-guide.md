# Frontend Fix Guide for BAIC Global

This guide explains the changes made to fix the frontend connectivity issues with the backend services.

## Issues Fixed

1. **API Request Prefixing**: The frontend was making requests to paths like `/website/webConfig/getWebConfig` directly, not to `/home-api/website/webConfig/getWebConfig` as it should. This was causing 404 errors because the backend services were expecting requests with the correct prefixes.

2. **Proxy Configuration**: The proxy configuration in nuxt.config.js was missing pathRewrite settings, which are needed to ensure that requests are forwarded correctly to the backend services.

## Changes Made

### 1. Fixed axios.js Plugin

The axios.js plugin was updated to correctly handle URL prefixing:

```javascript
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
```

This ensures that URLs are correctly prefixed with `/home-api` or `/api` before being sent to the backend.

### 2. Updated nuxt.config.js Proxy Configuration

The proxy configuration in nuxt.config.js was updated to include pathRewrite settings:

```javascript
proxy: {
  '/home-api': {
    target: 'http://34.42.200.5:8080',
    changeOrigin: true,
    pathRewrite: { '^/home-api': '/home-api' }
  },
  '/api': {
    target: 'http://34.42.200.5:8080',
    changeOrigin: true,
    pathRewrite: { '^/api': '/api' }
  },
  '/geoip': {
    target: 'http://34.42.200.5:8080',
    changeOrigin: true,
    pathRewrite: { '^/geoip': '/geoip' }
  },
  '/file': {
    target: 'http://34.42.200.5:8080',
    changeOrigin: true,
    pathRewrite: { '^/file': '/file' }
  }
}
```

This ensures that requests are correctly forwarded to the backend services.

### 3. Updated update-plugins.sh Script

The update-plugins.sh script was updated to include the fixed axios.js plugin, ensuring that the fix is applied during deployment.

## Deployment Steps

1. Push the changes to GitHub:
   ```bash
   git add .
   git commit -m "Fix frontend connectivity issues"
   git push
   ```

2. Deploy the frontend using Cloud Build:
   ```bash
   gcloud builds submit --config=cloudbuild-frontend.yaml
   ```

3. Wait for the deployment to complete. The frontend will be available at:
   ```
   https://baic-457613.appspot.com/
   ```

## Verification

After deployment, verify that the frontend is correctly connecting to the backend services:

1. Open the frontend in a browser
2. Check the browser's developer console for any API request errors
3. Verify that the website is displaying data correctly

If there are still issues, check the App Engine logs for more information:

```bash
gcloud app logs tail -s default
