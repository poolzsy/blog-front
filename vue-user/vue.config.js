
const path = require('path')
const CompressionWebpackPlugin = require('compression-webpack-plugin')
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')
const ImageMinimizerPlugin = require('image-minimizer-webpack-plugin')

const isProduction = process.env.NODE_ENV === 'production'

function resolve(dir) {
  return path.join(__dirname, dir)
}

module.exports = {
  devServer: {
    proxy: {
      '/api': {
        target: 'http://47.239.192.234:7777',  
        changeOrigin: true,
        pathRewrite: {
          '^/api': '/api'
        }
      }
    }
  },
  publicPath: '/',
  outputDir: 'dist',
  assetsDir: 'static',
  lintOnSave: process.env.NODE_ENV === 'development',
  productionSourceMap: false,
  configureWebpack: {
    devtool: 'source-map',
    resolve: {
      alias: {
        '@': resolve('src')
      }
    },
    // 图片压缩
    optimization: {
      minimizer: [
        new ImageMinimizerPlugin({
          minimizer: {
            implementation: ImageMinimizerPlugin.imageminMinify,
            options: {
              plugins: [
                ['gifsicle', { interlaced: true }],
                ['jpegtran', { progressive: true }],
                ['optipng', { optimizationLevel: 5 }],
                ['svgo', {
                  plugins: [
                    {
                      name: 'preset-default',
                      params: {
                        overrides: {
                          removeViewBox: false,
                          addAttributesToSVGElement: {
                            params: {
                              attributes: [
                                { xmlns: 'http://www.w3.org/2000/svg' }
                              ]
                            }
                          }
                        }
                      }
                    }
                  ]
                }]
              ]
            }
          }
        })
      ]
    },
    plugins: [
      // 开启gzip压缩
      isProduction && new CompressionWebpackPlugin({
        test: /\.(js|css|html|svg)$/,
        threshold: 10240, // 只有大小大于该值的资源会被处理 10240
        deleteOriginalAssets: false // 不删除原文件
      }),
      process.env.npm_config_report && new BundleAnalyzerPlugin()
    ].filter(Boolean)
  },
  chainWebpack: config => {
    // 移除 prefetch 插件，减少首屏加载带宽
    config.plugins.delete('prefetch')
    config.plugins.delete('preload')

    // 设置图片压缩
    config.module
      .rule('images')
      .test(/\.(png|jpe?g|gif|webp)$/i)
      .use('url-loader')
      .loader('url-loader')
      .tap(options => {
        options = options || {}
        options.limit = 10240 // 10kb以下转base64
        options.fallback = {
          loader: 'file-loader',
          options: {
            name: 'static/img/[name].[hash:8].[ext]'
          }
        }
        return options
      })

    // 优化ElementUI按需加载
    config.module
      .rule('babel')
      .use('babel-loader')
      .tap(options => {
        return {
          ...options,
          plugins: [
            ...(options.plugins || []),
            [
              'component',
              {
                libraryName: 'element-ui',
                styleLibraryName: 'theme-chalk'
              }
            ]
          ]
        }
      })
  }
}
