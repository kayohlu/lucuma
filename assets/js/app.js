// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import $ from "jquery"
window.$ = $;
import 'bootstrap'
import Highcharts from "highcharts"


// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import './lucuma_liveview'
import './waitlist_analytics'
import './stripe_payments'

$(function () {
  $('[data-toggle="popover"]').popover({
    // container: 'body'
  })
})

Highcharts.setOptions({
  chart: {
    style: {
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";'
    }
  }
});

$(document).ready(function(){
  if (document.querySelector(".js_submitOnClick")) {
    $('[data-toggle="buttons"] .btn').on('click', function () {
      $(this).toggleClass('btn-light active');

      var $checkbox = $(this).find('[type=checkbox]');
      $checkbox.prop('checked',!$checkbox.prop('checked'));

      $(this).parents('form').submit();

      return false;
    });
  }
});
