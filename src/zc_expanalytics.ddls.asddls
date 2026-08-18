@EndUserText.label: 'Expense Analytics - Department Spending'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI.chart: [{
  chartType: #BAR,
  dimensions: ['Department'],
  measures: ['TotalAmount'],
  dimensionAttributes: [{ dimension: 'Department', role: #CATEGORY }],
  measureAttributes: [{ measure: 'TotalAmount', role: #AXIS_1 }]
}]

@UI.presentationVariant: [{
  visualizations: [{ type: #AS_CHART }],
  sortOrder: [{ by: 'TotalAmount', direction: #DESC }]
}]

define view entity ZC_EXPANALYTICS
  as select from zexp_report
{
  @UI.lineItem: [{ position: 10 }]
  key department as Department,

      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 20 }]
      sum( total_amount ) as TotalAmount,

//      @Semantics.currencyCode: true
      currency as Currency
}
group by
  department,
  currency
