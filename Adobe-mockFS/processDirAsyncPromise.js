/* jshint node:true */
"use strict";

// Dependencies
const Promise = require('bluebird');
const mockfs = require('./mockfs.js');

Promise.promisifyAll(mockfs);

const CONCURRENCY_LIMIT = 4;

const output = function(dict) {
  console.log(`${JSON.stringify(dict)}`);
};

// return Promise<Tree>, where Tree is a dictionary that maps file
//                       to its type or another dictionary.
const processDirAsync = (path) => {
  const getFiles = () => {
    return mockfs.listAsync(path);
  };
  const getTree = (files) => {
    // For each file:
    // * Get the path of the file
    // * Get the stat using the path
    // * If stat.isDirectory(), then process the directory
    // * Otherwise, add an entry indicating the type of the file.

    let entries = {};

    const addFileEntry = (file) => {
      const childPath = mockfs.join(path, file);

      const errHandler = (err) => {
        // err is always a string
        entries[file] = `error: ${err}`;
      };

      const getStat = () => {
        return mockfs.statAsync(childPath);
      };
      const processStat = (stat) => {
        if (stat.isDirectory()) {
          return processDirAsync(childPath).then((childEntries) => {
            entries[file] = childEntries;
          });
        }
        else if (stat.isFile()) {
          entries[file] = 'file';
        }
        else {
          entries[file] = 'unknown';
        }
      };

      return getStat().then(processStat).catch(errHandler);
    };

    const returnResult = () => {
      return entries;
    };

    return Promise.each(files, addFileEntry)
      .then(returnResult);
  };
  return getFiles().then(getTree);
};

const main = function () {
  processDirAsync("/").then((entries) => {
    output(files);
  }).catch((err) => {
    if (__.isString(err)) {
      console.log(`error: ${err}`);
    }
    else {
      console.log(`error: ${err.message}`);
    }
  });
};

main();
