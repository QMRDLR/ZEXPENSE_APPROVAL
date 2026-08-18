@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department - Consumption View'

define view entity ZC_EXPDEPARTMENT
  as select from ZI_EXPDEPARTMENT
{
  key DepartmentID,
      DepartmentName,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt
}
