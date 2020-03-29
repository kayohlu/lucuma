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
import * as intlTelInput from 'intl-tel-input';
import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live")
let actualSocket = liveSocket.getSocket()
// console.log(liveSocket)

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
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

actualSocket.onMessage(function(message) {
 // console.info("message from socket")
 // console.log(message)
   var input = document.querySelector("#input-phone");
   var instance = intlTelInput(input, {
    initialCountry: "IE",
    nationalMode: false,
    geoIpLookup: function(success, failure) {
      $.get("https://ipinfo.io", function() {}, "jsonp").always(function(resp) {
        var countryCode = (resp && resp.country) ? resp.country : "";
        console.log(countryCode);
        success(countryCode);
      });
    }
  });
})

// console.log(actualSocket.isConnected())
liveSocket.connect()
// console.log(actualSocket.isConnected())

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
