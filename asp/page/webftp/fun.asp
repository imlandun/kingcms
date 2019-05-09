<%
class webftp
private r_doc,r_path,r_temp

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_path = "webftp"

	r_temp = "temp" '粘贴板临时目录

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public function lang(l1)
	on error resume next
	if isobject(r_doc)=false then
		set r_doc=Server.CreateObject(king_xmldom)
		r_doc.async=false
		'判断是否存在所设置的语言包,如果没有就调用默认设置的语言包
		if king.isexist(king_system&r_path&"/language/"&king.language&".xml") then
			r_doc.load(server.mappath(king_system&r_path&"/language/"&king.language&".xml"))
		else
			r_doc.load(server.mappath(king_system&r_path&"/language/"&king_language&".xml"))
		end if
	end if
	lang=r_doc.documentElement.SelectSingleNode("//kingcms/"&l1).text
	if err.number<>0 then
		lang="["&l1&"]"
		err.clear
	end if
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public property get temp
	temp=r_temp
end property
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
public sub list()
	dim I1,path,paths,i,I2
	I1=king.sect(request.servervariables("script_name"),king.inst,"/"&r_path,0)
	if king.ismethod then
		path=form("path")
	else
		path=quest("path",0):if len(path)=0 then path=king.inst
	end if
	if right(path,1)<>"/" then path=path&"/"

	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"
	Il "[<a href=""index.asp?path=%2F"">"&lang("common/root")&"</a>"
	Il "<a href=""index.asp?path="&server.urlencode(king.inst&king.system)&""">"&lang("common/page")&"</a>"
	Il "<a href=""index.asp?path="&server.urlencode(king.inst&I1)&""">"&lang("common/admin")&"</a>"
	Il "<a href=""index.asp?path="&server.urlencode(king.inst&king_templates)&""">"&lang("common/template")&"</a>]"
	Il "[<a href=""javascript:;"" onclick=""javascrit:posthtm('index.asp?action=set','flo','submits=crtfolder&path="&server.urlencode(path)&"');"">"&lang("common/crtfolder")&"</a>"
	Il "<a href=""index.asp?action=text&path="&server.urlencode(path)&""">"&lang("common/crttext")&"</a>]"
	Il "[<a href=""index.asp?action=upfile&path="&server.urlencode(path)&""">"&lang("common/up")&"</a>]"
	Il "</span>"

	Il "</span>"
	Il "</h2>"

	paths=split(path,"/")

	Il "<p><img src=""../system/images/os/dir2.gif""/> <a href=""index.asp"">"&lang("common/wwwroot")&"</a>: "
	for i=1 to ubound(paths)-2
		I2=I2&"/"&paths(i)
		Il " / <a href=""index.asp?path="&server.urlencode(I2)&""">"&paths(i)&"</a>"
	next

	if king.instre("text,upfile,img,down",action) then
		Il " / <a href=""index.asp?path="&server.urlencode(path)&""">"&paths(i)&"</a>"
	else
		Il " / "&paths(i)
	end if
	Il "</p>"

end sub

'fdarray=split(fd,"/")
'for i=1 to ubound(fdarray)-2
'	fdlink=fdlink&"/"&fdarray(i)
'	fdout=fdout&"<a href="""&king.page&"?code="&king.code&"&fd="&server.urlencode(fdlink)&""">"&fdarray(i)&"</a>/"
'next


end class

%>