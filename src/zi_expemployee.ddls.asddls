@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee - Interface View'


  define view entity ZI_EXPEMPLOYEE
    as select from zexp_employee


  association to ZI_EXPDEPARTMENT as _Department 
    on $projection.DepartmentID = _Department.DepartmentID

{
  key employee_id           as EmployeeID,
      employee_name         as EmployeeName,
      department_id         as DepartmentID,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Department
}
