            
import gulp from 'gulp'; 
const { src, dest, parallel, series, watch, task } = gulp;

// Load plugins
import uglify from 'gulp-uglify';
import rename from 'gulp-rename';
import gulpif from 'gulp-if';
import argv from 'yargs';
import autoprefixer from 'gulp-autoprefixer';
import cssnano from 'gulp-cssnano';
import concat from 'gulp-concat';
import clean from 'gulp-clean';
import imagemin from 'gulp-imagemin';
import pngquant from 'imagemin-pngquant';
import changed from 'gulp-changed';
import {nunjucksCompile} from 'gulp-nunjucks';
import nunjucks_lib from 'nunjucks';
import stylus from 'gulp-stylus';
import jsonTransform from 'gulp-json-transform';
import nunjucksRender from 'gulp-nunjucks-render';
import inlineCss from 'gulp-inline-css';

import browsersync from 'browser-sync';

import fs from 'fs';


var outdest='./tmp';

// Error handler
function handleError(err) {
	console.log(err.toString());
	process.ext(-1);
}

// Clean assets

function clear() {
    return src(`${outdest}/*`, {
            read: false
        })
        .pipe(clean());
}

// JS function 

function js() {
    const source = './src/js/*.js';

    return src(source)
        .pipe(changed(source))
        .pipe(concat('bundle.js'))
        .pipe(uglify())
        .pipe(rename({
            extname: '.min.js'
        }))
        .pipe(dest(`${outdest}/js/`))
        .pipe(browsersync.stream());
}

// just copy the fonts
function fonts() {
    return src('./src/fonts/*')
	.pipe(dest(`${outdest}/fonts`));
}

// CSS function 
// styled 
function css() {
    const source = 'src/_styles/*.styl';

    return src(source)
      .pipe(changed(source))
      //.pipe(plugins.sourcemaps.init())
      .pipe(stylus({
        compress: true,
        'include css': true
      }))
      .on('error', handleError)
      //.on('error', plugins.notify.onError(config.defaultNotification))
      //.pipe(plugins.postcss([autoprefixer({browsers: ['last 2 version', '> 5%', 'safari 5', 'ios 6', 'android 4']})]))
      .pipe(rename(function(path) {
        // Remove 'source' directory as well as prefixed folder underscores
        // Ex: 'src/_styles' --> '/styles'
        //path.dirname = path.dirname.replace(dirs.source, '').replace('_', '');
        path.dirname = path.dirname.replace('_', '');
      }))
      .pipe(gulpif(argv.production, cssnano({rebase: false})))
      //.pipe(plugins.sourcemaps.write('./'))
      .pipe(dest('./src/styles'))
      //.pipe(dest(`${outdest}/styles`))
      .pipe(browsersync.stream({match: '**/*.css'}));
}

// Optimize images
// mmoerz: added flavour
function img() {
    return src(['./src/_images/**/*.svg', './src/_images/**/*.png', './src/_images/**/*.jpg'])
        .pipe(imagemin([
	  imagemin.jpegtran({progressive: true}),
	  imagemin.svgo({plugins: [{removeViewBox: false}]})
	], { use: [pngquant({speed: 10})] }))
        .pipe(dest(`${outdest}/images`));
}

const site = {};

// read all data .json files
function data() {
	site['data'] = {};
	// JSON.parse(fs.readFileSync(somefile))
        return gulp.src('./src/_data/*.json')
	.pipe(jsonTransform(function(data, file) {
		site['data'][file.relative.replace('.json','')] = data;
		return {
			file_relative: file.relative,
			data: data
		};
	}))
	.pipe(dest('debug'));
}

// copy robot.txt and sitemap.xml 
function copy() {
	return src(['./src/*.txt', './src/*.xml'])
	    .pipe(dest('./tmp'));
}

const manageEnvironment = function(environment) {
	environment.addFilter('safi', function(str) {
	  return `${str} wurde als sicher angegeben`;
	});
	environment.addGlobal('site', site);
	environment.addGlobal('production','2');
}

// better for loading data from json files
// https://stackoverflow.com/questions/70393984/how-do-i-access-json-from-gulp-data-in-nunjucks
//
// https://www.npmjs.com/package/gulp-nunjucks-render
function compile(cb) {
    // read the precompiled css file (for inlining in the html file)
    site['maincss'] = fs.readFileSync('./src/styles/main.amp.css', 'utf8')

    return src(['./src/*.nunjucks', '!./src/nohtml.*'])
        .pipe(nunjucksRender({
            path: ['src', 'src/_layouts'], // String or Array
            ext: '.html',
            inheritExtension: false,
            envOptions: {
		autoescaping: false, // otherwise prevents use of html tags
                watch: false, // aendern fuers ueberwachen!!
            },
            manageEnv: manageEnvironment,
            loaders: null
        }))
	//.pipe(inlineCss()) // does not work as expected
	// fonts seem to get ignored
	.pipe(dest(`${outdest}`));
}

// Watch files

function watchFiles() {
    watch('./src/_styles/*', css);
    watch('./src/**.json', series(data, compile));
    watch('./src/**.nunjucks', series(data, compile));
    watch('./src/**/*.nunjucks', series(data, compile));
    watch('./src/_images/*', img);
    watch('./src/fonts/*', fonts);
    watch('./src/*.txt', copy);
    watch('./src/*.xml', copy);
}

// BrowserSync

function browserSync() {
    browsersync.init({
        server: {
            baseDir: './tmp'
        },
        port: 3000
    });
}

// Tasks to define the execution of the functions simultaneously or in series

task( 'watch', parallel(watchFiles, browserSync));

task( 'default', 
	series(clear, 
		fonts,
		parallel(js, css, img, copy), 
		data,
		compile)
);

