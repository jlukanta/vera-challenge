/* jshint node:true */
"use strict";

// Dependencies
var __ = require('lodash');
var async = require('async');
var mockfs = require('./mockfs.js');

// Constants
var CONCURRENCY_LIMIT = 4;
var RUN_PROCESS_DIR_SYNC = false;
var TIMEOUT = 5000; // pass this as part of function signature
var DEBUG = false;

// task = { name : string, timeout : int , path : string }
// name is either list or stat
var queue = async.queue(function(task, callback) {
  var path = task.path;
  var timeout = task.timeout;
  if (task.name === 'list') {
    timeoutAsyncWrapper(mockfs.list, path, timeout, callback);
  }
  else if (task.name === 'stat') {
    timeoutAsyncWrapper(mockfs.stat, path, timeout, callback);
  }
  else {
    callback(new Error("Queue error: Unrecognized task name"));
  }
}, CONCURRENCY_LIMIT);

var output = function(dict) {
  console.log(`${JSON.stringify(dict, null, 2)}`);
};

var debugPrint = function(funcName, path, err, entry) {
  if (!DEBUG) {
    return;
  }
  var errString = "none";
  if (err && err.message) {
    errString = err.message;
  }
  console.log(`${funcName} ${path} | error ${errString} | entry ${JSON.stringify(entry, null, 2)}`);
};

// Calls an async function and returns a timeout if the
// function does not return after a given time
// callback(err, result)
var timeoutAsyncWrapper = function(asyncFunc, arg, timeout, callback) {
  var timer = setTimeout(function() {
    timer = null;
    return callback(new Error("Filesystem timeout"));
  }, timeout);
  asyncFunc(arg, function(err, result) {
    if (!timer) {
      // The timer already went off before, then we have 
      // already called the callback and indicated there
      // was a timeout error.
    }
    else {
      clearTimeout(timer);
      timer = null;
      if (__.isString(err)) {
        // Sometimes the function could return back a error
        // string. We want to cast it into an error object.
        err = new Error(err);
      }
      return callback(err, result);
    }
  });
};

// A wrapper function of mockFS.list()
// callback (err, result)
// err is an error object
var listAsync = function(path, timeout, callback) {
  queue.push({name : "list", path : path, timeout : timeout}, callback);
};

// A wrapper function of mockFS.stat()
// callback (err, result)
// err is an error object
var statAsync = function(path, timeout, callback) {
  queue.push({name : "stat", path : path, timeout : timeout}, callback);
};

// callback(err, entry)
var processDirAsync = function (path, callback) {

  var entry = {};

  // callback (err, childFiles)
  var listPath = function(callback) {
    listAsync(path, TIMEOUT, callback);
  };

  // callback (err)
  var iterateChildFiles = function(files, callback) {

    // Maps file to file type, and store it in a dictionary
    // callback(err)
    var processFile = function(file, callback) {
      var childPath = mockfs.join(path, file);
      statAsync(childPath, TIMEOUT, function(err, stat){
        if (err) {
          entry[file] = "error: " + err.message;
          // We want to recover from error here because we want
          // to check other files / directories in the path even
          // when some of them failed to return their stat.
          return callback();
        }
        if (stat.isDirectory()) {
          processDirAsync(childPath, function(err, childEntry){
            if (!err) {
              entry[file] = childEntry;
            }
            // We already ignore errors due to mockFS errors (timeout
            // or FS errors). If we get an error here, most likely it
            // is very serious (eg. syntax error, etc) and we want to
            // notify the calling method.
            return callback(err);
          });
        } else if (stat.isFile()) {
          entry[file] = "file";
          return callback();
        } else {
          entry[file] = "unknown";
          return callback();
        }
      });
    };

    async.each(files, processFile, callback);
  };

  async.waterfall([listPath, iterateChildFiles], function(err) {
    return callback(err, entry);
  });
};

// Copied and pasted from http://joelrbrandt.github.io/mockfs/
var processDirSync = function (path, entry) {

  var files = mockfs.listSync(path);
  files.forEach(function (f) {
    try {
      var childPath = mockfs.join(path, f),
               stat = mockfs.statSync(childPath);

      if (stat.isDirectory()) {
        entry[f] = {};
        processDirSync(childPath, entry[f]);
      } else if (stat.isFile()) {
        entry[f] = "file";
      } else {
        entry[f] = "unknown";
      }
    } catch (e) {
      entry[f] = "error: " + e.message;
    }
  });
};

var main = function () {
  var path = '/';
  if (RUN_PROCESS_DIR_SYNC) {
    var files = {};
    processDirSync(path, files);
    output(files);
  }
  else {
    processDirAsync(path, function(err, files) {
      if (err) {
        console.log("error: " + err.message);
      }
      else {
        output(files);
      }
    });
  }
};

main();
