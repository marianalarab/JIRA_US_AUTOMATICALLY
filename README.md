# JIRA_US_AUTOMATICALLY

Creates Jira US automatically when the Feature Toggle is defined with a due date.
This program was developed in Jul/2024

SAP version: S/4 Hana
HANA Database

ZCL_JIRA.abap - Is the main class
ZCL_JIRA_DAO.abap - Is needed so the test class can work without accessing de actual database and run its unit tests with coverage.
lcl_jira_tests.abap - Is the local implementation of the DAO class that simulates de access to the database and also the unit test class

The feature toggle table already existed. This was to create Jira's User Story in the backlog of the team so they know that there were some code that needed to be refactured because the feature toggle was no longer needed.

Feature Toggle table ( second screen of the automatic maintanence generator )
![image](https://github.com/user-attachments/assets/2feb802b-8052-4e5e-a0ea-44bd8d694769)


It is necessary to configure the following events in SM30 for the solution to work properly. The include can be found in /src/LZ_FG_FEAT_ACTF01
![image](https://github.com/user-attachments/assets/01487a11-436a-4f65-81f6-1d3a1698903c)

