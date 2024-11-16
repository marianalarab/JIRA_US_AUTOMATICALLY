*----------------------------------------------------------------------*
***INCLUDE LZ_FG_FEAT_ACTF01.
*----------------------------------------------------------------------*
FORM calc_date.

  IF  zfeat_active-erdat IS INITIAL.
    zfeat_active-erdat = sy-datum.
    zfeat_active-uname = sy-uname.

    "Expiration Date is set for 45 days after Feature Flag is created.
    zfeat_active-expdate = zfeat_active-erdat + 45.

  ELSEIF zfeat_active-erdat NE sy-datum.
    zfeat_active-aedat = sy-datum.
  ENDIF.

  " Do not let record the data with blank expiration date
  IF zfeat_active-expdate IS INITIAL.
    MESSAGE e000(zva0_sd) WITH TEXT-001.
  ENDIF.

  "Get Team Description
  SELECT SINGLE team_name FROM zfeat_team INTO zfeat_active-team_name WHERE team EQ zfeat_active-team.

  IF  zfeat_active-jira_us IS INITIAL AND sy-ucomm EQ 'SAVE'.

    SELECT SINGLE *
      FROM zfeat_active
      INTO @DATA(LS_FEAT_ACTIVE)
      WHERE feature EQ @zfeat_active-feature
        AND funct   EQ @zfeat_active-funct
        AND type    EQ @zfeat_active-type.

    "New entry
    IF sy-subrc NE 0.

      "Check if this is production box
      DATA(logsys) = sy-sysid && sy-mandt && 'ALE'.

      SELECT cccategory
          UP TO 1 ROWS
          FROM t000
          INTO @DATA(box)
          WHERE logsys EQ @logsys.
      ENDSELECT.

      IF box EQ 'P'."Production

        "Create US automatically to remove feature toggle after the expiration date
        DATA(o_jira) = NEW zcl_zva0_sd_jira( zfeat_active = zfeat_active ).

        zfeat_active-jira_us =  o_jira->create_us( ).

        IF zfeat_active-jira_us IS INITIAL.
          MESSAGE w000(zva0_sd) WITH TEXT-002.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDIF.

ENDFORM.
