'检查CC数据采集结果，本vbs使用32位ORACLE ODBC驱动，须使用c:\windows\syswow64\cscript.exe解释执行
'date1=Year(date())&Right("0"&Month(date()),2)&Right("0"&Day(date()),2)
'date1="20170518"


if WScript.Arguments.count>0 then
	showdebug=1
else
	showdebug=0
end if

TriStateTrue =-1
connectionString = "Provider=MSDASQL.1;Persist Security Info=False;User ID=XXXXXXXXXXX;Password=XXXXXXXX;Data Source=XXXX"

Set connection = CreateObject("ADODB.Connection")
set rs = CreateObject("ADODB.Recordset")
rs.cursorlocation = 3

connection.Open connectionString

sql = "select a.etldate,a.errorid from etl_log a where a.etldate=(select max(b.etldate) from etl_log b) and instr(a.procname,'STEP')=0"
if showdebug then
	wscript.echo "SQL = " & sql
end if

rs.open sql, connection 

cc_msg=""
cc_etldate=""

if rs.recordcount>0 then
	do while not rs.EOF
		cc_etldate = rs.fields(0).value
		cc_errid = conv(rs.fields(1).value)
		cc_msg = cc_msg  & ", " & cc_errid & "\n"
		if showdebug then
			wscript.echo cc_etldate & "=" & cc_errid
		end if
		rs.movenext
	loop
	etl_msg = cc_etldate & "结果: \n" & cc_msg
end if
if showdebug then
	wscript.echo cc_msg
end if
	
connection.close
Set connection = Nothing
Set rs = Nothing

wscript.echo etl_msg
''Set fso = CreateObject ("Scripting.FileSystemObject")
''Set stdout = fso.GetStandardStream (1)
''stdout.WriteLine etl_msg

Function conv(strIn)
    Set adoStream = CreateObject("ADODB.Stream")
	adoStream.Charset = "utf-8"
    adoStream.Type = 2 'adTypeText 
    adoStream.Open  
    adoStream.WriteText strIn
    adoStream.Position = 0  
    adoStream.Charset = "_autodetect_all"  
    adoStream.Type = 2 'adTypeBinary  
    conv = adoStream.ReadText()  
    adoStream.Close  
      
	''conv = Mid(conv, 1)  
End Function  

