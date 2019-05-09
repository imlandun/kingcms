<%
class tools
private r_doc,r_path

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
private sub class_initialize()

	r_path = "tools"

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
public sub list()
	Il "<h2>"
	Il lang("title")

	Il "<span class=""listmenu"">"
	Il "<a href=""index.asp"">["&lang("common/info")&"]</a>"
	Il "<a href=""index.asp?action=sql"">["&lang("common/sql")&"]</a>"
	Il "<a href=""index.asp?action=advsql"">["&lang("common/advsql")&"]</a>"
	if king_dbtype=0 then
		Il "<a href=""index.asp?action=backup"">["&lang("common/backup")&"]</a>"
	end if
	Il "<a href=""index.asp?action=included"">["&lang("common/included")&"]</a>"
	Il "<a href="""&king_system&"system/link.asp?url="&server.urlencode("http://www.alexa.com/data/details/traffic_details?url="&king.siteurl&"")&""" target=""_blank"">["&lang("common/alexa")&"]</a>"
	Il "</span>"

	Il "</span>"
	Il "</h2>"

end sub

end class


%>