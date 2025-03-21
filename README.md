# ReadMe fuer Ordi3


## Description

Ordinationsseite fuer Dr. Marieta Moerz

## Technologies used

JavaScript
- [Browserify](http://browserify.org/) with ES6/2015 support through [Babel](https://babeljs.io/)
- [Node](https://nodejs.org/)

Styles
- [Stylus](https://learnboost.github.io/stylus/)

Markup
- [Nunjucks](https://mozilla.github.io/nunjucks/)

Optimization
- [Imagemin](https://github.com/imagemin/imagemin)
- [Uglify](https://github.com/mishoo/UglifyJS)

Server
- [BrowserSync](http://www.browsersync.io/)

Automation
- [Gulp](http://gulpjs.com)

Code Management
- [Git](https://git-scm.com/)

## Test fuer AMP Compatibilitaet
https://search.google.com/test/amp

## Automated tasks

This project uses [Gulp](http://gulpjs.com) to run automated tasks for development and production builds.
At the moment supported parameters are:
`gulp` or `gulp default`: which compiles the nunjuck templates into the .html files, minifies the images and stuffs the css as inline code in the .html file.

Default output directory is ./tmp

`gulp watch` fires up the webserver with browserify support

The tasks are as follows:

`gulp --production`: Same as `gulp serve --production` also run `gulp test` and  not boot up production server

`gulp serve`: Compiles preprocessors and boots up development server
`gulp serve --open`: Same as `gulp serve` but will also open up site/app in your default browser
`gulp serve --production`: Same as `gulp serve` but will run all production tasks so you can view the site/app in it's final optimized form

***Adding the `--debug` option to any gulp task displays extra debugging information (ex. data being loaded into your templates)***
