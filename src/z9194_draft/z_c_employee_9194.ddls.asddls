@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HC Master - Consumption'
@Metadata.allowExtensions: true
define root view entity Z_C_EMPLOYEE_9194 
    provider contract transactional_query
    as projection on Z_I_EMPLOYEE_LOG_9194
{
        @ObjectModel.text.element: ['EmployeeName']
    key EmployeeNumber,
    EmployeeName,
    EmployeeDepartment,
    EmployeeStatus,
    JobTitle,
    StartDate,
    EndDate,
    Email,
    @ObjectModel.text.element: ['ManagerName']
    ManagerNumber,
    ManagerName,
    ManagerDepartment,
    CreatedOn,
    @Semantics.user.createdBy: true
    CreatedBy,
    ChangedOn,
    @Semantics.user.lastChangedBy: true
    ChangedBy

}
