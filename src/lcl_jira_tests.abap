*"* use this source file for your ABAP unit test classes


CLASS lcl_jira_dao2 DEFINITION INHERITING FROM zcl_jira_dao.

  PUBLIC SECTION.
    METHODS get_secret    REDEFINITION.
    METHODS read_text REDEFINITION.

ENDCLASS.

CLASS lcl_jira_dao2 IMPLEMENTATION.

  METHOD get_secret.

    RAISE EXCEPTION TYPE cx_bapi_ex.

  ENDMETHOD.

  METHOD read_text.

    RAISE EXCEPTION TYPE cx_bapi_ex.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_zcl_jira_dao DEFINITION INHERITING FROM zcl_jira_dao.


  PUBLIC SECTION.
    METHODS call_service    REDEFINITION.
    METHODS send            REDEFINITION.
    METHODS receive         REDEFINITION.
    METHODS set_request     REDEFINITION.
    METHODS fetch_response  REDEFINITION.
    METHODS read_response   REDEFINITION.
    METHODS read_text       REDEFINITION.
    METHODS get_team_data   REDEFINITION.
    METHODS get_secret      REDEFINITION.
    METHODS deserialize     REDEFINITION.

ENDCLASS.

CLASS lcl_zcl_jira_dao IMPLEMENTATION.

  METHOD call_service.

    e_error_detail = VALUE #( code            = '00'
                              message         = 'Default Call Service'
                              message_class   = 'Mock Warning'
                              message_number  = '123'             ).

  ENDMETHOD.

  METHOD send.

    ex_error_detail = VALUE #( code            = '01'
                               message         = 'Default Send'
                               message_class   = 'Mock Warning'
                               message_number  = '123'             ).

  ENDMETHOD.

  METHOD receive.

    ex_error_detail = VALUE #( code            = '01'
                               message         = 'Default Receive'
                               message_class   = 'Mock Warning'
                               message_number  = '123'             ).


  ENDMETHOD.

  METHOD set_request.

  ENDMETHOD.


  METHOD fetch_response.
    DATA o_client TYPE REF TO if_http_client.

    r_response = o_client->response.

  ENDMETHOD.

  METHOD read_response.

    r_response = VALUE #( body        = 'Default Response'
                          code_status = '200'
                          reason      = 'The Reason is You' ).

  ENDMETHOD.

  METHOD read_text.

    lines = VALUE #( ( tdformat = 'A1'
                       tdline   = '&US_DESCR&' )
                     ( tdline   = '&FEATURE&' )
                     ( tdline   = '&DUE_DATE&' ) ).

  ENDMETHOD.

  METHOD get_team_data.

    team_jira_data = VALUE #( team            = 'TEAM'
                              jira_key        = 'TEAM'
                              jira_parent     = 'PARENT'
                              jira_issue_type = '10001'    ).

  ENDMETHOD.

  METHOD get_secret.

    sd_secret = VALUE #( project = 'feature toggle'
                         url     = 'https://jira.atlassian.net/rest/api/3/issue'
                         secret  = 'Basic YTJxMDIzMUBqb2huZGVlcmUuY29tOkFUQVRUM3hGZkdGMGplS1psY1ViM09uTnZkdTRlNWpIYkp5R1RLbFpsZFJmUGZlM2xaUE9MVjQ4TzZpRlZIWklMRWNZX1' ).


  ENDMETHOD.

  METHOD deserialize.

    abap_data-id = 'FFSDAO'.
    abap_data-key = 'TEAM'.
    abap_data-self = 'https://jira.atlassian.net/rest/api/3/issue'.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_zcl_jira DEFINITION DEFERRED.
CLASS zcl_jira DEFINITION LOCAL FRIENDS lcl_zcl_jira.

CLASS lcl_zcl_jira DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>lcl_zcl_jira
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>zcl_jira
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE>X
*?</GENERATE_CLASS_FIXTURE>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
    DATA:
      f_Cut TYPE REF TO zcl_jira,  "class under test
      i_dao TYPE REF TO lcl_zcl_jira_dao. "mocked dao

    CLASS-METHODS: class_Setup.
    CLASS-METHODS: class_Teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: create_Us FOR TESTING.
    METHODS: get_Content FOR TESTING.
    METHODS: get_Us_Text FOR TESTING.
    METHODS: negative_test FOR TESTING.

ENDCLASS.       "lcl_zcl_jira


CLASS lcl_zcl_jira IMPLEMENTATION.

  METHOD class_Setup.



  ENDMETHOD.


  METHOD class_Teardown.



  ENDMETHOD.


  METHOD setup.

    DATA zFeat_Active TYPE zFeat_Active.

    CREATE OBJECT i_dao.

    CREATE OBJECT f_Cut
      EXPORTING
        zFeat_Active = zFeat_Active
        i_dao            = i_dao.



  ENDMETHOD.


  METHOD teardown.



  ENDMETHOD.


  METHOD create_Us.

    DATA us TYPE zJira_Us.

    us = f_Cut->create_Us(  ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = us
      exp   = 'TEAM'          "<--- please adapt expected value
      msg   = 'Testing value us'
    ).
  ENDMETHOD.


  METHOD get_Content.

    DATA content TYPE string.

    content = f_Cut->get_Content(  ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = content
      exp   = '&US_DESCR&00/00/0000&FEATURE&0000-00-00'         "<--- please adapt expected value
      msg   = 'Testing value content'
    ).
  ENDMETHOD.


  METHOD get_Us_Text.

    DATA us_Description TYPE string.

    us_Description = f_Cut->get_Us_Text(  ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = us_Description
      exp   = '&US_DESCR&00/00/0000'          "<--- please adapt expected value
      msg   = 'Testing value us_Description' ).
  ENDMETHOD.

  METHOD negative_test.

    DATA: zFeat_Active TYPE zFeat_Active,
          g_cut            TYPE REF TO zcl_jira,
          h_cut            TYPE REF TO zcl_jira,
          u_dao            TYPE REF TO lcl_jira_dao2.

    CREATE OBJECT u_dao.

    CREATE OBJECT g_cut
      EXPORTING
        zFeat_Active = zFeat_Active
        i_dao            = u_dao.

    g_cut->create_us(
*      RECEIVING
*        us =
    ).

    CREATE OBJECT h_cut
      EXPORTING
        zFeat_Active = zFeat_Active.
*        i_dao            =                  " CALL JIRA API TO OPEN ISSUES


  ENDMETHOD.


ENDCLASS.
