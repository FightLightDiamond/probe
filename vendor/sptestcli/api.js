'use strict';
/* eslint-env browser */
const driver = require('promise-phantom');
const phantomjs = require('phantomjs-prebuilt');
const Observable = require('zen-observable');

function init(page, observer, prevPing, prevDlSpeed, prevUlSpeed) {
    // TODO: Doesn't work with arrow function. open issue on `promise-phantom`
    page.evaluate(function () { // eslint-disable-line prefer-arrow-callback
        const $ = document.querySelector.bind(document);

        return {
            ping: Number($('#avgLatency').textContent),
            dlspeed: Number($('#downloadSpeed').textContent),
            ulspeed: Number($('#uploadSpeed').textContent),
            //unit: 'Mbps',
            // Somehow it didn't work with `Boolean($('#speed-value.succeeded'))
            hasError: Number($('#check_result').textContent),
            message: $('#message').textContent,
            isDone: $('#testbutton').textContent=="Restart"?true:false//document.querySelectorAll('Restart').length > 0
        };
    })
        .then(result => {
        //console.log('previous result: ping= '+prevPing+', dowload='+prevDlSpeed+', upload='+prevUlSpeed);
        //observer.next(result);
        if (((result.ping >0)||(result.dlspeed >0)||(result.ulspeed >0))&&((result.ping !== prevPing)||(result.dlspeed !== prevDlSpeed)||(result.ulspeed !== prevUlSpeed))) {
        //result.message="result"+ result.ping + ':'+result.dlspeed +':'+result.ulspeed+':'+result.hasError+':'+result.isDone;
        // console.log('result '+result.message);
        // console.log('previous result: ping= '+prevPing+', dowload='+prevDlSpeed+', upload='+prevUlSpeed);
        observer.next(result);
    }
    //result.message="same result";
    //console.log('same result');

    if (result.isDone) {
        //result.message="Done";
        page.close();
        observer.complete();
    } else {

        setTimeout(init, 100, page, observer, result.ping, result.dlspeed, result.ulspeed);
    }
})
.catch(err => observer.error(err));
}

module.exports = (url) => new Observable(observer => {

    driver.create({path: phantomjs.path})
    .then(phantom => phantom.createPage())
.then(page => page.open(url).then(() => {
    // page.set('settings.resourceTimeout',30000);
    // page.onResourceTimeout = function(e) {
    // 	console.log(e.errorCode);   // it'll probably be 408
    // 	console.log(e.errorString); // it'll probably be 'Network timeout on resource'
    // 	console.log(e.url);         // the url whose request timed out
    // 	phantom.exit(1);
    // };
    init(page, observer);
}))
.catch(err => { observer.error(err)});
});
