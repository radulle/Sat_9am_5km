import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"
import AthleteCharts from "charts/athlete"
import { ruLocale } from "charts/ru"

// Connects to data-controller="athlete"
export default class extends Controller {
  connect() {
    Apex.chart = { locales: [ruLocale], defaultLocale: 'ru' }

    const athleteCharts = new AthleteCharts(document.querySelectorAll("tr.result"))

    const eventsCountChart = new ApexCharts(
      document.querySelector("#chart-events-count"),
      athleteCharts.eventsChartOptions('Количество забегов')
    )
    eventsCountChart.render()

    const eventsWhiskersChart = new ApexCharts(
      document.querySelector("#chart-events-whiskers"),
      athleteCharts.eventsWhiskersOptions('Статистика')
    )
    eventsWhiskersChart.render()

    const resultsChart = new ApexCharts(
      document.querySelector("#chart-results"),
      athleteCharts.resultsChartOptions('Недавние результаты', { max_count: 15 })
    );
    resultsChart.render();
  }
}
