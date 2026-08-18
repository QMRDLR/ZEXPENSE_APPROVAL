@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee - Consumption View'

define view entity ZC_EXPEMPLOYEE
  as select from ZI_EXPEMPLOYEE

{
  key EmployeeID,
      EmployeeName,
      DepartmentID,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Department
}
