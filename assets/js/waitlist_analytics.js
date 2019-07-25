import $ from "jquery"
import Highcharts from 'highcharts'
require('highcharts/highcharts-more')(Highcharts);

  if($('#waitlist-states-container').length >0) {
    Highcharts.chart('waitlist-states-container', {
      chart: {
        type: 'spline',
        height: '50%'
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
        height: '100%'
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
        height: '35%'
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
         }
        // dateTimeLabelFormats: { // don't display the dummy year
        //   month: '%e. %b',
        //   year: '%b'

        // }
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
        height: '35%'
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
        height: '35%'
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
        height: '35%'
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
        height: '35%'
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