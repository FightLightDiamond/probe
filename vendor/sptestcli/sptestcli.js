#!/usr/bin/env node
'use strict';
const dns = require('dns');
const meow = require('meow');
const chalk = require('chalk');
const logUpdate = require('log-update');
const ora = require('ora');
const api = require('./api');
var cli = require('cli');

var options = cli.parse({
    country: [ 'c', 'Country code', 'string', 'SG' ],          // -c, --country SG   Country code
	json: ['j','Output json format']
});


meow(`
	Usage
	  $ sptestcli
	  $ sptestcli -c SG
`);

// Check connection
dns.lookup('speed-portal.singnet.com.sg', err => {
	if (err && err.code === 'ENOTFOUND') {
		console.error(chalk.red('\n Please check your internet connection.\n'));
		if (options.json) {
			var jsonOutput=
				'{' +
				'"status":"error",' +
				'"message":"Please check your internet connection."' +
			'}';
			console.log(jsonOutput);

		}
		process.exit(1);
	}
});


let data = {
	ping:0,
	dlspeed:0,
	ulspeed:0,
	isDone:false};
const spinner = ora();

const speed = () => chalk[data.isDone ? 'green' : 'cyan']('Ping: '+data.ping + ' ms' +'	Download: '+data.dlspeed + ' Mbps' +'	Upload: '+data.ulspeed + ' Mbps') + '\n\n';



function exit() {
	if (process.stdout.isTTY) {
		logUpdate(`\n\n    ${speed()}`);
	} else {
		console.log(`Ping: ${data.ping} ms	Download: ${data.dlspeed} Mbps	Upload: ${data.ulspeed} Mbps`);
	}

	process.exit();
}

if (process.stdout.isTTY) {
	setInterval(() => {
		const pre = '\n\n  ' + chalk.gray.dim(spinner.frame());
		// if (!data.dlspeed) {
         //    //console.log(data.dlspeed);
		// 	logUpdate(pre + '\n\n');
		// 	return;
		// }
		if (data.hasError==1) {
			logUpdate(pre + data.message+ '\n\n');
			//console.log('hasError'+data.message);
            if (options.json) {
                var jsonOutput=
                    '{' +
                    '"status":"error",' +
                    '"message":"'+data.message+'"' +
                '}';
                console.log(jsonOutput);
                process.exit();

            }
			exit();
		}
    	//console.log(data.dlspeed);

		logUpdate(pre + speed());
	}, 50);
}

let timeout;
//console.log("start call api");
var url='http://speed-portal.singnet.com.sg/cli/test/';
url += options.country;
api(url)
	.forEach(result => {
		data = result;

		// Exit after the speed has been the same for 3 sec
		// needed as sometimes `isDone` doesn't work for some reason
		clearTimeout(timeout);
		timeout = setTimeout(() => {
			//console.log("test timeout");
			data.isDone = true;
			if (options.json) {
				var jsonOutput=
					'{' +
						'"status":"timeout",' +
						'"result":{"ping":'+data.ping+',"download":'+data.dlspeed+',"upload":'+data.ulspeed+'}' +
					'}';
				console.log(jsonOutput);
                process.exit(1);

			}
			exit();
		}, 20000);

		if (data.isDone) {
            //console.log("All done.");
            if (options.json) {
                logUpdate(`\n\n    ${speed()}`);
                var jsonOutput=
                    '{' +
                    '"status":"success",' +
                    '"result":{"ping":'+data.ping+',"download":'+data.dlspeed+',"upload":'+data.ulspeed+'}' +
                '}';
                console.log(jsonOutput);
                process.exit();

            }
			exit();
		}
	})
	.then(() => {exit();})
	.catch(err => {
		console.error(err.message)
		//console.log("error.");
		if (options.json) {
			var jsonOutput=
				'{' +
				'"status":"error",'+
				'"message":"'+err.message+'"' +
			'}';
			console.log(jsonOutput);

		}
		process.exit(1);
	});
