import $ from "jquery"
import Highcharts from 'highcharts'
require('highcharts/highcharts-more')(Highcharts);

Highcharts.setOptions({
  chart: {
    style: {
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";'
    }
  },
  colors: [
    '#4D9DE0',
    '#e9c46a',
    '#2a9d8f',
    '#f09d51',
    '#313638',
  ]
});


if($('#party-size-container').length >0) {
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
        format: "<i class='fas fa-users'></i> {value}",
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

if($('#waitlist-states-container').length >0) {
  Highcharts.chart('waitlist-states-container', {
    chart: {
      type: 'spline',
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    xAxis: {
      type: 'datetime',
      dateTimeLabelFormats: {
        day: '%d %b %Y'    //ex- 01 Jan 2016
      },
      labels: {
        formatter: function () {
          let date = new Date(this.value * 1000);
          let options = {weekday: 'short', month: 'short', day: 'numeric', year: '2-digit'};
          return date.toLocaleString('en-IE', options)
        }
      }
    },
    yAxis: {
      title: {
        text: 'Customers'
      },
      labels: {
        formatter: function () {
          return this.value + '';
        }
      }
    },
    tooltip: {
        headerFormat: '<b>{series.name}</b><br>',
      pointFormatter: function() {
        let date = new Date(this.x * 1000);
        let options = {weekday: 'short', month: 'short', day: 'numeric', year: '2-digit'};
        return `${this.y} customers on ${date.toLocaleString('en-IE', options)}`
      }
    },
    plotOptions: {
      series: {
        marker: {
          radius: 1,
          lineColor: 'black',
          lineWidth: 1
        }
      }
    },
    series: [
      $('#waitlist-states-container').data('served-data'),
      $('#waitlist-states-container').data('no-show-data'),
      $('#waitlist-states-container').data('cancellation-data'),
      $('#waitlist-states-container').data('waitlisted-data')
    ]
  });
}

if($('#container').length >0) {
  Highcharts.chart('container', {
    chart: {
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false,
      type: 'pie',
    },
    title: {
      text: null
    },
    tooltip: {
      pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        center: ['50%', '50%'],
        cursor: 'pointer',
        dataLabels: {
          enabled: false
        },
        showInLegend: true
      }
    },
    series: [{
      innerSize: '70%',
      colorByPoint: true,
      data: $('#container').data('percentages-data'),
      dataLabels: {
        enabled: true,
        distance: -20,
        formatter: function () {
          // display only if larger than 1
          return `${this.y}%`
        }
      }
    }]
  });

}

if($('#waitlist-average-wait-time-over-time-container').length >0) {
  Highcharts.chart('waitlist-average-wait-time-over-time-container', {
    chart: {
      type: 'spline',
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    xAxis: {
      type: 'datetime',
      dateTimeLabelFormats: {
        day: '%d %b %Y'    //ex- 01 Jan 2016
      },
      labels: {
        formatter: function () {
          let date = new Date(this.value * 1000);
          let options = {weekday: 'short', month: 'short', day: 'numeric', year: '2-digit'};
          return date.toLocaleString('en-IE', options)
        }
      }
    },
    yAxis: {
      title: {
        text: 'Wait time (mins)'
      },
      labels: {
        formatter: function () {
          return this.value + '';
        }
      }
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    plotOptions: {
      spline: {
        marker: {
          radius: 1,
          lineColor: 'black',
          lineWidth: 1
        }
      }
    },
    series: [$('#waitlist-average-wait-time-over-time-container').data('average-wait-time-over-time-data')]
  });

}



if($('#waitlist-average-served-per-day-of-week-container').length >0) {
  Highcharts.chart('waitlist-average-served-per-day-of-week-container', {
    chart: {
      type: 'column',
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    legend: {
      enabled: false
    },
    xAxis: {
      type: 'category',
    },
    yAxis: {
      title: {
        text: 'Customers'
      },
      labels: {
        formatter: function () {
          return this.value + '';
        }
      }
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    plotOptions: {
      spline: {
        marker: {
          radius: 1,
          lineColor: 'black',
          lineWidth: 1
        }
      }
    },
    series: [
      $('#waitlist-average-served-per-day-of-week-container').data('waitlist-average-served-per-day-of-week-data')]
  });
}


if($('#waitlist-average-served-per-hour-container').length >0) {

  Highcharts.chart('waitlist-average-served-per-hour-container', {
    chart: {
      type: 'column',
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    legend: {
      enabled: false
    },
    xAxis: {
      type: 'category',
    },
    yAxis: {
      title: {
        text: 'Customers'
      },
      labels: {
        formatter: function () {
          return this.value + '';
        }
      }
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    plotOptions: {
      spline: {
        marker: {
          radius: 1,
          lineColor: 'black',
          lineWidth: 1
        }
      }
    },
    series: [
      $('#waitlist-average-served-per-hour-container').data('waitlist-average-served-per-hour-data')]
  });

}


if($('#waitlist-average-served-per-hour-per-day-container').length >0) {

  Highcharts.chart("waitlist-average-served-per-hour-per-day-container", {
    chart: {
      type: 'column',
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    legend: {
      enabled: true
    },
    xAxis: {
      type: 'category',
    },
    yAxis: {
      title: {
        text: 'Customers'
      }
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    plotOptions: {
      spline: {
        marker: {
          radius: 1,
          lineColor: 'black',
          lineWidth: 1
        }
      }
    },
    series: $('#waitlist-average-served-per-hour-per-day-container').data('waitlist-average-served-per-hour-per-day-data')
  });

}


console.log($('#waitlist-average-served-per-hour-for-day-container').length);

if($('#waitlist-average-served-per-hour-for-day-container').length >0) {
  Highcharts.chart("waitlist-average-served-per-hour-for-day-container", {
    chart: {
      type: 'column',
    },
    title: {
      text: null
    },
    subtitle: {
      text: null
    },
    legend: {
      enabled: true
    },
    xAxis: {
      type: 'category',
    },
    yAxis: {
      title: {
        text: 'Customers'
      }
    },
    tooltip: {
      crosshairs: true,
      shared: true
    },
    plotOptions: {
      spline: {
        marker: {
          radius: 1,
          lineColor: 'black',
          lineWidth: 1
        }
      }
    },
    series: $('#waitlist-average-served-per-hour-for-day-container').data('waitlist-average-served-per-hour-for-day-data')
  });

}
