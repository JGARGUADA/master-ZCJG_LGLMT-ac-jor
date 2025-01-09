CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhc_master AS data.
    TYPES: flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY e_name.

    CLASS-DATA mt_buffer_master TYPE tt_master.

ENDCLASS.



CLASS lhc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR HCMMaster RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE HCMMaster.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE HCMMaster.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE HCMMaster.

    METHODS read FOR READ
      IMPORTING keys FOR READ HCMMaster RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK HCMMaster.

ENDCLASS.

CLASS lhc_HCMMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA ls_buffer TYPE lcl_buffer=>ty_buffer_master.

    GET TIME STAMP FIELD DATA(lv_tsl).

    SELECT MAX( e_number ) AS e_number
        FROM zhc_mast_us_9194
        INTO @DATA(lv_e_number).


    LOOP AT entities INTO DATA(ls_entities).

      ls_buffer-data-e_number = lv_e_number + 1.
      ls_buffer-data-crea_date_time = lv_tsl.
      ls_buffer-data-crea_uname = sy-uname.
      ls_buffer-data-e_name = ls_entities-%data-EmployeeName.
      ls_buffer-data-e_department = ls_entities-%data-EmployeeDepartment.
      ls_buffer-data-status = ls_entities-%data-EmployeeStatus.
      ls_buffer-data-job_title = ls_entities-%data-JobTitle.
      ls_buffer-data-start_date = ls_entities-%data-StartDate.
      ls_buffer-data-end_date = ls_entities-%data-EndDate.
      ls_buffer-data-email = ls_entities-%data-Email.
      ls_buffer-data-m_number = ls_entities-%data-ManagerNumber.
      ls_buffer-data-m_name = ls_entities-%data-ManagerName.
      ls_buffer-data-m_department = ls_entities-%data-ManagerDepartment.
      ls_buffer-data-crea_date_time = ls_entities-%data-CreatedOn.
      ls_buffer-data-crea_uname = ls_entities-%data-CreatedBy.

      ls_buffer-flag = lcl_buffer=>created.

      INSERT ls_buffer INTO TABLE lcl_buffer=>mt_buffer_master.

      IF ls_entities-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid            = ls_entities-%cid
                        EmployeeNumber  = ls_entities-EmployeeNumber ) INTO TABLE mapped-hcmmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    LOOP AT entities INTO DATA(ls_entities).
      GET TIME STAMP FIELD ls_entities-%data-ChangedOn.
      ls_entities-%data-ChangedBy = sy-uname.

      SELECT SINGLE * FROM zhc_master
          WHERE e_number EQ @ls_entities-EmployeeNumber
          INTO @DATA(ls_ddbb).

      IF sy-subrc EQ 0.

        INSERT VALUE #( flag = lcl_buffer=>updated
                        data = VALUE #( e_name = COND #( WHEN ls_entities-%control-EmployeeName = if_abap_behv=>mk-on
                                                         THEN ls_entities-EmployeeName
                                                         ELSE ls_ddbb-e_name )
                                        e_department = COND #( WHEN ls_entities-%control-EmployeeDepartment = if_abap_behv=>mk-on
                                                            THEN ls_entities-EmployeeDepartment
                                                            ELSE ls_ddbb-e_department )
                                        status = COND #( WHEN ls_entities-%control-EmployeeStatus = if_abap_behv=>mk-on
                                                            THEN ls_entities-EmployeeStatus
                                                            ELSE ls_ddbb-status )
                                        job_title = COND #( WHEN ls_entities-%control-JobTitle = if_abap_behv=>mk-on
                                                            THEN ls_entities-JobTitle
                                                            ELSE ls_ddbb-job_title )
                                        start_date = COND #( WHEN ls_entities-%control-StartDate = if_abap_behv=>mk-on
                                                            THEN ls_entities-StartDate
                                                            ELSE ls_ddbb-start_date )
                                        end_date = COND #( WHEN ls_entities-%control-EndDate = if_abap_behv=>mk-on
                                                            THEN ls_entities-EndDate
                                                            ELSE ls_ddbb-end_date )
                                        email = COND #( WHEN ls_entities-%control-Email = if_abap_behv=>mk-on
                                                        THEN ls_entities-Email
                                                        ELSE ls_ddbb-email )
                                        m_number = COND #( WHEN ls_entities-%control-ManagerNumber = if_abap_behv=>mk-on
                                                            THEN ls_entities-ManagerNumber
                                                            ELSE ls_ddbb-m_number )
                                        m_name = COND #( WHEN ls_entities-%control-ManagerName = if_abap_behv=>mk-on
                                                            THEN ls_entities-ManagerName
                                                            ELSE ls_ddbb-m_name )
                                        m_department = COND #( WHEN ls_entities-%control-ManagerDepartment = if_abap_behv=>mk-on
                                                                THEN ls_entities-ManagerDepartment
                                                                ELSE ls_ddbb-m_department )

                                        e_number = ls_entities-EmployeeNumber
                                        crea_date_time = ls_ddbb-crea_date_time
                                        crea_uname = ls_ddbb-crea_uname
                                        ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

        IF ls_entities-EmployeeNumber IS NOT INITIAL.
          INSERT VALUE #( %cid    = ls_entities-EmployeeNumber
                          EmployeeNumber = ls_entities-EmployeeNumber ) INTO TABLE mapped-hcmmaster.

        ENDIF.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    loop at keys into data(ls_entities).
        insert value #( flag = lcl_buffer=>deleted
                        data = value #( e_number = ls_entities-EmployeeNumber ) ) into table lcl_buffer=>mt_buffer_master.
        if ls_entities-EmployeeNumber is not initial.
            insert value #( %cid    = ls_entities-EmployeeNumber
                            EmployeeNumber = ls_entities-EmployeeNumber ) into table mapped-hcmmaster.
        endif.
    endloop.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_R_HC_MASTER_9194 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_R_HC_MASTER_9194 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    data: lt_data_created type standard table of zhc_master,
          lt_data_updated type standard table of zhc_master,
          lt_data_deleted type standard table of zhc_master.

    lt_data_created = value #( for <row> in lcl_buffer=>mt_buffer_master where ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    if lt_data_created is not initial.
        insert zhc_master from table @lt_data_created.
    endif.

    lt_data_updated = value #( for <row> in lcl_buffer=>mt_buffer_master where ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    if lt_data_updated is not initial.
        update zhc_master from table @lt_data_updated.
    endif.

    lt_data_deleted = value #( for <row> in lcl_buffer=>mt_buffer_master where ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    if lt_data_deleted is not initial.
        delete zhc_master from table @lt_data_deleted.
    endif.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
