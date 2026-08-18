@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approval Log - Interface View'


define view entity ZI_EXPAPPRLOG
  as select from zexp_apprlog


  association to parent ZI_EXPENSEREPORT as _Report 
    on $projection.ParentUUID = _Report.ReportUUID

{
  key log_uuid              as LogUUID,
      parent_uuid           as ParentUUID,
      log_id                as LogID,
      approver_id           as ApproverID,
      action                as Action,
      action_comment        as ActionComment,
      action_at             as ActionAt,

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

      _Report
}
