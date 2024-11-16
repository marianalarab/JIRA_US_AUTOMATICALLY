class ZCL_JIRA definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !ZFEAT_ACTIVE type ZFEAT_ACTIVE
      !I_DAO type ref to ZCL_JIRA_DAO optional .
  methods CREATE_US
    returning
      value(US) type ZJIRA_US .
  PROTECTED SECTION.

    DATA: o_dao TYPE REF TO ZCL_JIRA_dao.

    METHODS: get_us_text RETURNING VALUE(us_description) TYPE string.

    METHODS: get_content RETURNING VALUE(content) TYPE string.

  PRIVATE SECTION.

    CONSTANTS: us_text      TYPE thead-tdname   VALUE 'ZJIRA_US_DESCR',
               content_text TYPE thead-tdname   VALUE 'ZJIRA_CONTENT',
               text_id      TYPE thead-tdid     VALUE 'ST',
               text_obj     TYPE thead-tdobject VALUE 'TEXT'.

    DATA: s_FEAT_ACTIVE     TYPE ZFEAT_ACTIVE.

ENDCLASS.



CLASS ZCL_JIRA IMPLEMENTATION.


  METHOD constructor.

    IF i_dao IS NOT INITIAL.
      O_DAO = I_DAO.

    ELSE.
    o_dao = NEW ZCL_JIRA_dao( ).

    ENDIF.

    s_FEAT_ACTIVE = ZFEAT_ACTIVE.

  ENDMETHOD.


  METHOD get_us_text.

    DATA: V_DUE_dATE TYPE c LENGTH 10.

    TRY.
        o_dao->read_text(
          EXPORTING
            id     = text_id
            name   = us_text
            object = text_obj
          RECEIVING
            lines  = DATA(lines)
        ).

        LOOP AT lines ASSIGNING FIELD-SYMBOL(<fs_lines>).

          us_description = us_description && <fs_lines>-tdline.

        ENDLOOP.

        REPLACE ALL OCCURRENCES OF '&FEATURE&'       IN us_description WITH s_FEAT_ACTIVE-feature.
        REPLACE ALL OCCURRENCES OF '&FUNCTIONALITY&' IN us_description WITH s_FEAT_ACTIVE-funct.
        V_DUE_dATE = s_feat_active-expdate+6(2) && '/' && s_feat_active-expdate+4(2) && '/' && s_feat_active-expdate(4).
        REPLACE ALL OCCURRENCES OF '&DUE_DATE&'      IN us_description WITH V_DUE_dATE.

      CATCH cx_bapi_ex.
    ENDTRY.

  ENDMETHOD.


  METHOD get_content.

    DATA: V_DUE_dATE TYPE c LENGTH 10.
    DATA: v_summary TYPE string.
    DATA(us_descr) = me->get_us_text( ).

    TRY.
        DATA(team_data)  =   o_dao->get_team_data( team = s_feat_active-team ).

        o_dao->read_text(
          EXPORTING
            id     = text_id
            name   = content_text
            object = text_obj
              RECEIVING
                lines  = DATA(lines)
        ).

        LOOP AT lines ASSIGNING FIELD-SYMBOL(<fs_lines>).

          content = content && <fs_lines>-tdline && space.

        ENDLOOP.

        REPLACE ALL OCCURRENCES OF '&US_DESCR&'      IN content WITH us_descr.
        REPLACE ALL OCCURRENCES OF '&ISSUE_TYPE&'    IN content WITH team_data-jira_issue_type.
        REPLACE ALL OCCURRENCES OF '&PARENT&'        IN content WITH team_data-jira_parent.
        REPLACE ALL OCCURRENCES OF '&JIRA_KEY&'      IN content WITH team_data-jira_key.

        v_summary = TEXT-001.
        REPLACE ALL OCCURRENCES OF '&FEAT&'          IN v_summary WITH s_feat_active-feature.
        REPLACE ALL OCCURRENCES OF '&FUNC&'          IN v_summary WITH s_feat_active-funct.
        REPLACE ALL OCCURRENCES OF '&SUMMARY&'       IN content   WITH v_summary.

        V_DUE_dATE = s_feat_active-expdate(4) && '-' && s_feat_active-expdate+4(2) && '-' && s_feat_active-expdate+6(2).
        REPLACE ALL OCCURRENCES OF '&DUE_DATE&'      IN content WITH V_DUE_dATE.

      CATCH cx_bapi_ex.
    ENDTRY.

  ENDMETHOD.


  METHOD create_us.

    TYPES: BEGIN OF ty_abap_Data,
             id   TYPE c LENGTH 6,
             key  TYPE ZJIRA_US,
             self TYPE zs_dl_url-url,
           END OF ty_abap_data.

    DATA: abap_data TYPE ty_abap_data.

    DATA token TYPE c LENGTH 1000.

    DATA: lt_mappings TYPE /ui2/cl_json=>name_mappings.

    DATA(content) = me->get_content(  ).

    DATA t_header TYPE wdy_key_value_table.

    TRY.

        DATA(secret) = o_dao->get_secret( ).

      CATCH cx_bapi_ex.
    ENDTRY.


    token = "Secret -- 

    t_header = VALUE #( ( key = 'METHOD'        value = 'POST'             )
                        ( key = 'AUTHORIZATION' value = token              )
                        ( key = 'CONTENT-TYPE'  value = 'application/json' )
                       ).

    o_dao->call_service(
      EXPORTING
        i_url           = CONV #( secret-url )
        i_theader_param = t_header                 " Sorted List of Key / Value Relations as Strings
        i_cdata         = content
      IMPORTING
        e_error_detail  =  DATA(error_det)  " Error in HTTPS Call
        r_response      =  DATA(response)   " Response from https call
    ).

    lt_mappings = VALUE #( ( abap = 'id'   json = 'id'   )
                           ( abap = 'key'  json = 'key'  )
                           ( abap = 'self' json = 'self' )
                        ).

    o_dao->deserialize(
      EXPORTING
        response    =   response               " Response from https call
        abap_true   =   'X'
        lt_mappings =    lt_mappings              " ABAP<->JSON Name Mapping Table
      CHANGING
        abap_data   =  abap_data
    ).

    us = abap_Data-key.


  ENDMETHOD.
ENDCLASS.
