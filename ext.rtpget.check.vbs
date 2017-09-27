'上交所eztrans文件检查

if WScript.Arguments.count<2 then
	wscript.echo "Use ext.rtpget.checks.vbs eztrans_stats_file_path type"
	wscript.quit
else
'	wscript.echo WScript.Arguments(0)
end if
file_path=WScript.Arguments(0)
'file_path="Z:\QS\RptFile\"
file_path=left(file_path,instr(file_path,"eztrans_stats.txt")-1)

check_type=WScript.Arguments(1)
date1=CStr(Year(Now()))&Right("0"&Month(Now()),2)&Right("0"&Day(Now()),2)
if WScript.Arguments.count>2 then
	Wscript.Echo "Today="&date1
end if
file_rpt=file_path&"eztrans_stats.txt"
if WScript.Arguments.count>2 then
	Wscript.Echo "File="&file_rpt
end if

a=0	'已下载数量'
b=0 '未下载数量'
c=0 '完成状态数量'
d=0 'IPOGH\GH\ZQY数量'
e=0 'IPOGH\GH\ZQY完成状态数量'
f=0 '下载出错数量'
g="" 'IPOGH\GH\ZQY解压出错文件'

Set fso2 = CreateObject("Scripting.FileSystemObject")
if not fso2.fileexists(file_rpt) then
'	rptfile 不存在
	return_code="9999" 
else
    set stats_file=fso2.opentextfile(file_rpt,1)
    Do While stats_file.AtEndOfStream = False
		str_AllFile=stats_file.ReadAll
		if WScript.Arguments.count>2 then
			Wscript.Echo str_AllFile
		end if
		if str_AllFile<>"" then
			strarry=split(str_AllFile,vbcrlf)  
			for each   strLine   in   strarry
				strLine=replace(strLine," ","")
				if WScript.Arguments.count>2 then
					Wscript.Echo strLine
				end if
				str_split=split(strLine,"|")
				if ubound(str_split)>7 then
					if str_split(1)=date1 then
						c=c+1
						if str_split(4)="2" then
							a=a+1
						end if
						if str_split(4)="1" then
							b=b+1
						end if
						if str_split(4)="3" then
							f=f+1
						end if
						if left(str_split(0),2)="GH" then
							d=d+1
							if str_split(4)="2" then
								e=e+1
								g=g & check_zip(str_split(0))
							end if
						end if
						if left(str_split(0),5)="IPOGH" then
							d=d+1
							if str_split(4)="2" then
								e=e+1
								g=g & check_zip(str_split(0))
							end if
						end if
						if left(str_split(0),3)="ZQY" then
							d=d+1
							if str_split(4)="2" then
								e=e+1
								g=g & check_zip(str_split(0))
							end if
						end if
					end if
				end if
			next
		end if
    Loop	
	stats_file.close
end if
if check_type="1" then
  rem 未下载数量返回
  return_code=b
end if
if check_type="2" then
  rem 已下载数量返回
  return_code=a
end if
if check_type="3" then
	rem 返回完成状态：1、已全部完成，0、未全部完成
	if c=a and c>0 then
		return_code=1
	else
		return_code=0
	end if
end if
if check_type="4" then
	rem 返回IPOGH\GH\ZQY完成状态：>1、已全部完成，=0、未全部完成
	if d=e and d>0 then
		return_code=e
	else
		return_code=0
	end if
end if
if check_type="5" then
  rem 下载出错数量返回
  return_code=f
end if
if check_type="6" then
  rem 下载ZIP出错数量返回
  return_code=mid(g,3)
end if

wscript.echo return_code

function UnZip(ByVal myZipFile, ByVal myTargetDir)
	Set fso = CreateObject("Scripting.FileSystemObject")
	If NOT fso.FileExists(myZipFile) Then
		wscript.echo "zip not found=" & myZipFile
		Exit function
	ElseIf LCase(fso.GetExtensionName(myZipFile)) <> "zip" Then
		wscript.echo "zip not found=" & myZipFile
		Exit function
	ElseIf NOT fso.FolderExists(myTargetDir) Then
		wscript.echo "Target not found=" & myTargetDir
		fso.CreateFolder(myTargetDir)
	End If
	Set objShell = CreateObject("Shell.Application")
	Set objSource = objShell.NameSpace(myZipFile)
	Set objFolderItem = objSource.Items()
	Set objTarget = objShell.NameSpace(myTargetDir)
	intOptions = 256
	objTarget.CopyHere objFolderItem, intOptions
End function

function check_zip(rpt_File)
	'检查压缩文件内容是否匹配，匹配返回(null)，不匹配返回文件名
	temp_dir="d:\temp\"
	file_prefix=lcase(left(rpt_File,len(rpt_File)-4))
	Set fso1 = CreateObject("Scripting.FileSystemObject")
	If fso1.FileExists(file_path&date1&"\"&rpt_File) Then
		a=Unzip(file_path&date1&"\"&rpt_File, temp_dir )
		if left(rpt_file,2)="GH" then
			target_file=temp_dir&file_prefix&".dbf"
		end if
		if left(rpt_file,5)="IPOGH" then
			target_file=temp_dir&file_prefix&".txt"
		end if
		if left(rpt_file,3)="ZQY" then
			target_file=temp_dir&file_prefix&".dbf"
		end if
		if fso1.FileExists(target_file) then
			if WScript.Arguments.count>2 then
				Wscript.Echo "ZIP_File="&target_file
			end if
			check_zip="" 
			fso1.deletefile target_file
		else
			if WScript.Arguments.count>2 then
				Wscript.Echo "ZIP_File error="&target_file
			end if
			check_zip=" ," & rpt_file
		end if
	else
		check_zip=""
	end if
end function
