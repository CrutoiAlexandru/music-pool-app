// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
var express = require('express');

Parse.Cloud.define("hello", (request) => {
    return "hello";
});
