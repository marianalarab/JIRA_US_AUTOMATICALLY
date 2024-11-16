class ZCL_JIRA_DAO definition
  public
  create public .

public section.

  types:
    BEGIN OF TY_ABAP_dATA,
    id TYPE c LENGTH 6,
    key TYPE zjira_us,
    self TYPE zs_dl_url-url,
    END OF ty_abap_data .

  data O_CLIENT type ref to IF_HTTP_CLIENT .
  data ERROR type ABAP_BOOL .

  methods CALL_SERVICE
    importing
      !I_URL type STRING
      !I_TURL_PARAM type WDY_KEY_VALUE_TABLE optional
      !I_THEADER_PARAM type WDY_KEY_VALUE_TABLE optional
      !I_TBODY_PARAM type WDY_KEY_VALUE_TABLE optional
      !I_CONTENT type ANY optional
      !I_CDATA type ANY optional
    exporting
      !E_ERROR_DETAIL type ZLAST_ERROR
      value(R_RESPONSE) type ZRESPONSE .
  methods SEND
    exporting
      !EX_ERROR_DETAIL type ZLAST_ERROR .
  methods RECEIVE
    exporting
      !EX_ERROR_DETAIL type ZLAST_ERROR .
  methods SET_REQUEST
    importing
      !I_TURL_PARAM type WDY_KEY_VALUE_TABLE
      !I_THEADER_PARAM type WDY_KEY_VALUE_TABLE
      !I_TBODY_PARAM type WDY_KEY_VALUE_TABLE
      !I_URL type STRING
      !I_CONTENT type ANY optional
      !I_CDATA type ANY optional .
  methods FETCH_RESPONSE
    returning
      value(R_RESPONSE) type ref to IF_HTTP_RESPONSE .
  methods READ_RESPONSE
    returning
      value(R_RESPONSE) type ZRESPONSE .
  methods READ_TEXT
    importing
      !ID type THEAD-TDID
      !NAME type THEAD-TDNAME
      !OBJECT type THEAD-TDOBJECT
    returning
      value(LINES) type TEXT_LINE_TAB
    raising
      CX_BAPI_EX .
  methods GET_TEAM_DATA
    importing
      !TEAM type ZVA0_TEAM
    returning
      value(TEAM_JIRA_DATA) type ZFEAT_JIRA
    raising
      CX_BAPI_EX .
  methods GET_SECRET
    returning
      value(SD_SECRET) type ZSECRET
    raising
      CX_BAPI_EX .
  methods DESERIALIZE
    importing
      !RESPONSE type ZRESPONSE 
      !ABAP_TRUE type ABAP_BOOL optional
      !LT_MAPPINGS type /UI2/CL_JSON=>NAME_MAPPINGS
    changing
      !ABAP_DATA type TY_ABAP_DATA .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JIRA_DAO IMPLEMENTATION.


  METHOD call_service.

    FREE: me->error .

    TRY .
        CHECK i_url IS NOT INITIAL.

        cl_http_client=>create_by_url( EXPORTING url = i_url   IMPORTING client = o_client ).
        set_request( i_url           = i_url
                     i_turl_param    = i_turl_param
                     i_theader_param = i_theader_param
                     i_tbody_param   = i_tbody_param
                     i_content       = i_content
                     i_cdata         = i_cdata ).



        me->send(
           IMPORTING
             ex_error_detail = e_error_detail    " Error in HTTPS Call
         ).


        me->receive(
            IMPORTING
              ex_error_detail = e_error_detail    " Error in HTTPS Call
          ).

        r_response = me->read_response( ).

      CATCH cx_root.

    ENDTRY.


  ENDMETHOD.


  METHOD fetch_response.

    CHECK me->error IS INITIAL.

    r_response = o_client->response.

  ENDMETHOD.


  METHOD read_response.

    FREE: r_response.

    DATA: l_response_jra TYPE zresponse_raw.

    CHECK me->error IS INITIAL.

    DATA(l_response) = me->fetch_response( ).

    r_response-body = l_response->get_cdata( ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = r_response-body
      CHANGING
        data             = l_response_jra
    ).

    l_response->get_status(
      IMPORTING
        code   = r_response-code_status   " HTTP status code
        reason = r_response-reason    " HTTP status description
    ).

    IF NOT l_response_jra-statuscode IS INITIAL.
      r_response-code_status = l_response_jra-statuscode.
    ENDIF.

    IF NOT l_response_jra-body IS INITIAL.
      r_response-reason  = l_response_jra-body.
    ENDIF.

  ENDMETHOD.


  METHOD read_text.

    DATA: t_lines TYPE TABLE OF tline.

    CONSTANTS: c_english TYPE thead-tdspras VALUE 'E'.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client                  = sy-mandt
        id                      = id
        language                = c_english
        name                    = name
        object                  = object
      TABLES
        lines                   = t_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_bapi_ex
        EXPORTING
          sysubrc = sy-subrc.

    ELSE.
      APPEND LINES OF t_lines TO lines.
    ENDIF.

  ENDMETHOD.


  METHOD receive.

    CHECK me->error IS INITIAL.

    o_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4
    ).
    IF sy-subrc <> 0.
      o_client->get_last_error(
        IMPORTING
          code           = ex_error_detail-code    " Return Value, Return Value After ABAP Statements
          message        = ex_error_detail-message    " Error Message
          message_class  = ex_error_detail-message_class    " Application Area
          message_number = ex_error_detail-message_number    " Message Number
      ).

      me->error = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD send.

    CHECK me->error IS INITIAL.

    o_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        http_invalid_timeout       = 4
        OTHERS                     = 5
    ).

    IF sy-subrc <> 0.
      o_client->get_last_error(
        IMPORTING
          code           = ex_error_detail-code    " Return Value, Return Value After ABAP Statements
          message        = ex_error_detail-message    " Error Message
          message_class  = ex_error_detail-message_class    " Application Area
          message_number = ex_error_detail-message_number    " Message Number
      ).

      me->error = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD set_request.
    TRY .
        CHECK o_client IS BOUND.
        DATA myurl TYPE string.
        myurl = i_url.

        LOOP AT i_turl_param INTO DATA(ls_param).
          o_client->append_field_url( EXPORTING name = ls_param-key value = ls_param-value CHANGING url = myurl ).
        ENDLOOP.
        IF myurl IS NOT INITIAL.
          cl_http_client=>create_by_url( EXPORTING url = myurl IMPORTING client = o_client ).
        ENDIF.

        LOOP AT i_theader_param INTO ls_param.
          o_client->request->set_header_field(
            EXPORTING
              name  = ls_param-key
              value = ls_param-value ).
        ENDLOOP.
        READ TABLE i_theader_param INTO ls_param WITH KEY key = 'METHOD'.
        IF sy-subrc EQ 0.
          o_client->request->set_method( ls_param-value ).
        ENDIF.

        READ TABLE i_theader_param INTO ls_param WITH KEY key = 'CONTENT-TYPE'.
        IF sy-subrc EQ 0.
          o_client->request->set_content_type( ls_param-value ).
        ENDIF.

        READ TABLE i_theader_param INTO ls_param WITH KEY key = 'AUTHORIZATION'.
        IF sy-subrc EQ 0.
          o_client->request->set_header_field( name = ls_param-key value = ls_param-value ).
        ENDIF.

        READ TABLE i_theader_param INTO ls_param WITH KEY key = 'LOGON_POPUP'.
        IF sy-subrc EQ 0.
          o_client->propertytype_logon_popup = ls_param-value.
        ENDIF.

        IF i_cdata IS NOT INITIAL.
          "          o_client->request->set_cdata( i_cdata ).
          o_client->request->set_cdata( data = CONV #( i_cdata ) ).
        ENDIF.

        IF i_content IS NOT INITIAL.
          DATA part TYPE REF TO if_http_entity.
          part = o_client->request->add_multipart( ).
          part->suppress_content_type( ).

          part->set_cdata( data = CONV #( i_content ) ).

        ENDIF.
      CATCH cx_root.

    ENDTRY.

  ENDMETHOD.


  METHOD get_team_data.

    SELECT SINGLE * FROM ZFEAT_JIRA INTO team_jira_data WHERE team = team.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_bapi_ex
        EXPORTING
          sysubrc = sy-subrc.
    ENDIF.

  ENDMETHOD.


  METHOD get_SECRET.
    SELECT SINGLE * FROM ZSECRET INTO sd_secret WHERE project EQ 'FEATURE_TOGGLE'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_bapi_ex
        EXPORTING
          sysubrc = sy-subrc.
    ENDIF.
  ENDMETHOD.


  METHOD deserialize.

    /ui2/cl_json=>deserialize(
         EXPORTING
           json             = response-body
           pretty_name      = abap_true
           name_mappings    = lt_mappings
         CHANGING
           data             = abap_data
).


  ENDMETHOD.
ENDCLASS.
