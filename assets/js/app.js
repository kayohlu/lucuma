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

import Cleave from 'cleave.js'

import * as intlTelInput from 'intl-tel-input';
// import "intl-tel-input/build/js/utils"

import 'select2';
import 'select2/dist/css/select2.css';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

$(function() {
  // Build the chart
  // Make monochrome colors
  var pieColors = (function () {
    var colors = [],
    base = Highcharts.getOptions().colors[0],
    i;

    for (i = 0; i < 10; i += 1) {
      // Start out with a darkened base color (negative brighten), and end
      // up with a much brighter color
      colors.push(Highcharts.Color(base).brighten((i - 3) / 7).get());
    }
    return colors;
  }());

if ($('#party-size-container').length > 0) {
Highcharts.chart('party-size-container', {
    chart: {
      type: 'column'
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    xAxis: {
        tickWidth: 0,
        lineWidth: 0,
        type: 'category',
        labels: {
          useHTML: true,
          format: "{value} <i class='fas fa-users'></i>",
        },
        title: {
          text: "Party Size Summary",
          style: {
            "font-size": "1rem",
            color: "#6c757d"
          }
        }
    },
    yAxis: {
      labels: {
        enabled: true
      },
      gridLineWidth:0,
      lineWidth: 1,
        min: 0,
        title: {
          text: null
        },

    },
    legend: {
      enabled: false
    },
    tooltip: {
      enabled: false,
    },
    series: [{
        data: $('#party-size-container').data('party-size-breakdown'),
        colorByPoint: true,
        dataLabels: {
            enabled: false,
            rotation: 0,
            color: '#FFFFFF',
            align: 'center',
            format: '{point.y}', // one decimal
            y: 30, // 10 pixels down from the top
        }
    }]
  });

}


 if (document.querySelector("#input-phone")) {
  var input = document.querySelector("#input-phone");
  var instance = intlTelInput(input, {
    initialCountry: "auto",
    nationalMode: false,
    geoIpLookup: function(success, failure) {
      $.get("https://ipinfo.io", function() {}, "jsonp").always(function(resp) {
        var countryCode = (resp && resp.country) ? resp.country : "";
        console.log(countryCode);
        success(countryCode);
      });
    }
  });
  console.log(instance)
}

  $('.select2-dropdown').select2();

});
