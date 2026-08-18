@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Department - Interface View'


define view entity ZI_EXPDEPARTMENT
  as select from zexp_depart_od
  
{
  key department_id         as DepartmentID,
      department_name       as DepartmentName,

      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt
}
