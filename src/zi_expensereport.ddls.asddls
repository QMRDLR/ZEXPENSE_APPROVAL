@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Expense Report - Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_EXPENSEREPORT
  as select from zexp_report


  composition [0..*] of ZI_EXPENSEITEM as _Item

  composition [0..*] of ZI_EXPAPPRLOG  as _ApprovalLog



  association to ZI_EXPEMPLOYEE        as _Employee   on $projection.EmployeeID = _Employee.EmployeeID

  association to ZI_EXPDEPARTMENT      as _Department on $projection.Department = _Department.DepartmentID

  association to ZI_EXPSTATUS          as _Status     on $projection.Status = _Status.StatusCode


{

  key report_uuid            as ReportUUID,
      report_id              as ReportID,
      employee_id            as EmployeeID,
      _Employee.EmployeeName as EmployeeName,
      department             as Department,
      period_start           as PeriodStart,
      @Semantics.amount.currencyCode: 'Currency'
      total_amount           as TotalAmount,
      currency               as Currency,
      status                 as Status,

      case
        when status = '06' then cast( 3 as abap.int1 )
        when status = '05' then cast( 1 as abap.int1 )
        else cast( 2 as abap.int1 )
      end                    as StatusCriticality,


      _Status.StatusText     as StatusText,
      @Semantics.user.createdBy: true
      local_created_by       as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at       as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by  as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,


      _Item,
      _ApprovalLog,
      _Employee,
      _Department,
      _Status
}
