<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
dim fs,l1,l2,l3
l1="system/install.asp"
set fs=createObject("Scripting.FileSystemObject")
l2=server.mappath(l1)
l3=fs.folderexists(l2)
if l3=false then l3=fs.fileexists(l2)
set fs=nothing

if l3 then
response.Redirect(l1)
else
response.Redirect("system/login.asp")
end if
%>