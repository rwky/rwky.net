(function() {
  var app, express, http, path, routes,
    slice = [].slice;

  express = require("express");

  routes = require("./routes");

  http = require("http");

  path = require("path");

  app = express();

  routes = require('./routes');

  app.config = require('./config/config');

  app.enable('trust proxy');

  app.set("views", __dirname + "/views");

  app.set("view engine", "hjs");

  app.use(require('body-parser').urlencoded({
    extended: false
  }));

  app.use(function(req, res, next) {
    res.setTimeout(180000, function() {
      res.status(408);
      return next(new Error('Client Timeout'), req, res);
    });
    req.setTimeout(180000, function() {
      res.status(504);
      return next(new Error('Gateway Timeout'), req, res);
    });
    req.timeout = setTimeout(function() {
      res.status(504);
      return next(new Error('Request Timeout'), req, res);
    }, 180000);
    res.oldEnd = res.end;
    res.end = function() {
      var args;
      args = arguments;
      clearTimeout(req.timeout);
      return res.oldEnd.apply(this, args);
    };
    res.locals.paypal = app.config.paypal;
    return next();
  });

  app.use(function(req, res, next) {
    var render;
    render = res.render;
    res.render = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (!args[1]) {
        args[1] = {};
      }
      if (!args[1].partials) {
        args[1].partials = {};
      }
      args[1].partials.header = 'header';
      args[1].partials.footer = 'footer';
      return render.apply(res, args);
    };
    return next();
  });

  routes(app);

  app.use(function(err, req, res, next) {
    console.error(err + ' ' + err.stack);
    return res.status(500).send('Oops something has gone wrong, please try again');
  });

  http.createServer(app).listen(3000);

}).call(this);
