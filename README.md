<p># JIRA_US_AUTOMATICALLY<br />Creates Jira US automatically when the Feature Toggle is defined with a due date.</p>
<p>This program was developed in Jul/2024<br />SAP version: S/4 Hana<br />HANA Database</p>
<ul>
<li>ZCL_JIRA.abap -&gt; Is the main class</li>
<li>ZCL_JIRA_DAO.abap -&gt; Is needed so the test class can work without accessing de actual database and run its unit tests with coverage.</li>
<li>lcl_jira_tests.abap -&gt; Is the local implementation of the DAO class that simulates de access to the database and also the unit test class</li>
</ul>
<p>&nbsp;</p>
<p>The feature toggle table already existed. This was to create Jira's User Story in the backlog of the team so they know that there were some code that needed to be refactured because the feature toggle was no longer needed.</p>
<p>&nbsp;</p>
<p>Feature Toggle table ( second screen of the automatic maintanence generator )</p>
![image](https://github.com/user-attachments/assets/2feb802b-8052-4e5e-a0ea-44bd8d694769)

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>It is necessary to configure the following events in SM30 for the solution to work properly. The include can be found in /src/LZ_FG_FEAT_ACTF01</p>
![image](https://github.com/user-attachments/assets/01487a11-436a-4f65-81f6-1d3a1698903c)

<p>&nbsp;</p>
