'EZOES上海报盘PBU状态检查

file_path="c:\zabbix_x64\ASHR_status.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
if not fso.fileexists(file_path) then
	wscript.echo "File Not Found! - " & file_path
	wscript.quit
end if

Ops=0
Status_OK=0
Status_STOP=0

set ts=fso.opentextfile(file_path,1,false)
Do Until ts.AtEndOfStream
	statusline = ts.ReadLine
'	Wscript.Echo statusline
	if trim(statusline)<>"" then
		status1=split(statusline,"=")
		if trim(status1(0))="OperatorTotal" then
			OperatorTotal = cint(trim(status1(1)))
		end if
		if trim(status1(0))="Operator" then
			Ops=Ops+1
			Operator1=trim(status1(1))
			statusline1 = ts.ReadLine
			status2=split(statusline1,"=")
			if trim(status2(0))="Status" then
				if trim(status2(1)) = "3" then
					Status_OK=Status_OK+1
				else
					if trim(status2(1)) = "1" then
						Status_STOP=Status_STOP+1
					end if
				end if
			end if
		end if
	end if
Loop
ts.Close 
wscript.echo "PBU Totals=" & Ops & ", Running=" & Status_OK & ", Stop=" & Status_STOP
