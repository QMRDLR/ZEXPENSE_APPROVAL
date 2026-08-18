@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Analytics - Status Distribution'
@Metadata.ignorePropagatedAnnotations: true


@UI.chart: [{
  chartType: #DONUT,
  dimensions: ['Status'],
  measures: ['ReportCount'],
  dimensionAttributes: [{ dimension: 'Status', role: #CATEGORY }],
  measureAttributes: [{ measure: 'ReportCount', role: #AXIS_1 }]
}]
@UI.presentationVariant: [{
  visualizations: [{ type: #AS_CHART }]
}]

define view entity ZC_EXPSTATUSANALYTICS
  as select from zexp_report
{
  @UI.lineItem: [{ position: 10 }]
  key status as Status,

      @UI.lineItem: [{ position: 20 }]
      count( distinct report_uuid ) as ReportCount
}
group by
  status
