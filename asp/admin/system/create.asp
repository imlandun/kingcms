<!--#include file="plugin.asp" -->
<%
set king=new kingcms
dim createtimespan:createtimespan=1
select case action
case"" king_def
case"create" king_create
end Select
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	server.scripttimeout=86400
	king.nocache
	king.head "0",king.lang("create/title")

	dim kplugin:kplugin=quest("kplugin",0)
	if len(kplugin)=0 then kplugin="article"

	Il "<h2>"&king.lang("create/title")&"</h2>"
	if king.instre(king.plugin,"onepage")=false then
		Il "<script>alert('对不起!!!您还未安装任何模块,请先安装模块!!!');eval(""parent.location='manage.asp?action=plugin'"");</script>"
	else
		Il "<div class=""k_form""><div>"
		Il "<input type=""button"" value="""&king.lang("common/createhome")&"""  onClick=""javascript:posthtm('create.asp?action=create', 'flo','submits=createhome');""><input type=""button"" value=""更新Google站点地图""  onClick=""javascript:posthtm('create.asp?action=create', 'flo','submits=createmaps');""><input type=""button"" value=""生成所有广告""  onClick=""javascript:posthtm('../ad/index.asp?action=set', 'progress', 'submits=creates');""><input type=""button"" value=""生成所有单页面""  onClick=""javascript:posthtm('../onepage/index.asp?action=set', 'progress', 'submits=creates');"">"
		Il "<script type=""text/javascript"">function jumpmenu(obj){eval(""parent.location='?kplugin=""+obj.options[obj.selectedIndex].value+""'"");}</script>"
		Il "<p><label>"&king.lang("create/kplugin")&"</label>"
		Il "<select name=""kplugin"" id=""kplugin""  onChange=""jumpmenu(this);"">"
		form_select king__plugin(),kplugin
		Il "</select>"
		Il "</p>"
		king.form_select "klist",king.lang("create/klist"),king__list(kplugin),""
		Il "<input type=""button"" value="""&king.lang("create/list")&"""  onClick=""javascript:posthtm('../"&kplugin&"/index.asp?action=set', 'progress', 'submits=createlist&list='+document.getElementById('klist').options[document.getElementById('klist').selectedIndex].value);""><input type=""button"" value="""&king.lang("create/page")&"""  onClick=""javascript:posthtm('../"&kplugin&"/index.asp?action=set', 'progress', 'submits=createpage&list='+document.getElementById('klist').options[document.getElementById('klist').selectedIndex].value);""><input type=""button"" value="""&king.lang("create/list1")&"""  onClick=""javascript:posthtm('../"&kplugin&"/index.asp?action=set', 'progress', 'submits=createlists');""><input type=""button"" value="""&king.lang("create/page1")&"""  onClick=""javascript:posthtm('../"&kplugin&"/index.asp?action=set', 'progress', 'submits=createpages');"">"
		Il "</div></div>"
	end if

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function managedir()
	dim dir
	'if Request.ServerVariables("SERVER_PORT")<>"80" then
    	'dir = "http://"&Request.ServerVariables("SERVER_NAME")& ":" & Request.ServerVariables("SERVER_PORT")& Request.ServerVariables("PATH_INFO")
    'else
    	'dir = "http://"&Request.ServerVariables("SERVER_NAME")& Request.ServerVariables("PATH_INFO")
	'end if
	dir=Request.ServerVariables("PATH_INFO")
	dir=left(dir,instrrev(dir,"/system/"))
	managedir=dir
end function
'  *** copyright &copy kingcms.com all rights reserved ***
sub king_create()
	server.scripttimeout=86400
	king.nocache
	king.head 0,0

	select case form("submits")
	case "createhome"
		king.createhome
		king.flo king.lang("common/home")&" <a href="""&king.inst&""" target=""_blank"">["&king.lang("common/brow")&"]</a>",0
	case "createmaps"
		dim data,i,rs,I1,I2,sql,map
		I1=array("article","download","easyarticle","movie")
		for i=0 to ubound(I1)
			if I1(i)="easyarticle" then
				sql="kingeasyart"
			elseif I1(i)="article" then
				sql="kingart"
			else
				sql="king__"&I1(i)&"_page"
			end if
			if king.instre(king.plugin,I1(i)) then
				if king.checkcolumn(sql) then
					if I1(i)= "download" or I1(i)="movie" then I1(i)=I1(i)&"class"
					execute "set I2=new "&I1(i)
						I2.createmap
						if king.isexist("../../"&I2.path&".xml") then
							king.ol="<a href="""&king.siteurl&king.inst&I2.path&".xml"&""" target=""_blank"">"&king.siteurl&king.inst&I2.path&".xml"&"</a><br />"
						end if
					set I2=nothing
				end if 
			end if
		next
		if king.instre(king.plugin,"oo_public") and king.checkcolumn("kingoo") then
			set rs=conn.execute("select oocolumn from kingoo;")
				if not rs.eof and not rs.bof then
					data=rs.getrows()
					for i=0 to ubound(data,2)
						if king.checkcolumn("king__"&data(0,i)&"_page")>0 then
							execute "set I2=new "&data(0,i)&"class"
								I2.createmap
								if king.isexist("../../"&I2.path&".xml") then
									king.ol="<a href="""&king.siteurl&king.inst&I2.path&".xml"&""" target=""_blank"">"&king.siteurl&king.inst&I2.path&".xml"&"</a><br />"
								end if
							set I2=nothing
						end if
					next
				end if
				rs.close
			set rs=nothing
		end if
		king.createmap
		map=conn.execute("select sitemap from kingsystem")(0)
		map=king.siteurl&king.inst&map&".xml"
		king.ol="<a href="""&map&""" target=""_blank"">"&map&"</a>"
		king.flo king.writeol,0
	end select
end sub
'  *** copyright &copy kingcms.com all rights reserved ***
function king__plugin()
	dim data,i,rs,I1,I2,I3
	I2=array("article","download","easyarticle","movie")
	for i=0 to ubound(I2)
		if king.instre(king.plugin,I2(i)) then
			if len(I1)>0 then
				I1=I1&"|"&I2(i)&":"&encode(king.xmlang(I2(i),"title")&"|"&I2(i))
			else
				I1=I2(i)&":"&encode(king.xmlang(I2(i),"title")&"|"&I2(i))
			end if
			if lcase(I2(i))=lcase("download") or lcase(I2(i))=lcase("movie") then I2(i)=I2(i)&"class"
			execute "set I3=new "&I2(i):set I3=nothing
		end if
	next
	if king.instre(king.plugin,"oo_public") and king.checkcolumn("kingoo") then
	set rs=conn.execute("select oocolumn from kingoo;")
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if len(I1)>0 then
					I1=I1&"|"&data(0,i)&":"&encode(king.xmlang(data(0,i),"title")&"|"&data(0,i))
				else
					I1=data(0,i)&":"&encode(king.xmlang(data(0,i),"title")&"|"&data(0,i))
				end if
			execute "set I3=new "&data(0,i)&"class":set I3=nothing
			next
		end if
		rs.close
	set rs=nothing
	end if
	king__plugin=I1
end function
'  *** copyright &copy kingcms.com all rights reserved ***
function king__list(l1)
	dim data,i,rs,I1,sql,l2
	if l1="article" then
		l2="kingart"
	else
		l2="king__"&l1
	end if
	if l1="easyarticle" then
		sql="select listid,listname from kingeasyart_list;"
	else
		sql="select listid,listname from "&l2&"_list;"
	end if
	set rs=conn.execute(sql)
		if not rs.eof and not rs.bof then
			data=rs.getrows()
			for i=0 to ubound(data,2)
				if len(I1)>0 then
					I1=I1&"|"&data(0,i)&":"&encode(data(1,i)&"|"&data(0,i))
				else
					I1=data(0,i)&":"&encode(data(1,i)&"|"&data(0,i))
				end if
			next
		end if
		rs.close
	set rs=nothing
	king__list=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub form_select(l3,l4)
	dim I2,I3,I4,i
	I3=split(l3,"|")
	for i=0 to ubound(I3)
		if len(I3(i))>0 then
			I2=split(I3(i),":")
			if ubound(I2)=1 then
				if cstr(decode(I2(0)))=cstr(l4) then I4=" selected=""selected""" else I4=""
				Il "<option value="""&decode(I2(0))&""""&I4&">"&decode(I2(1))&"</option>"
			else
				if cstr(decode(I3(i)))=cstr(l4) then I4=" selected=""selected""" else I4=""
				Il "<option value="""&decode(I3(i))&""""&I4&">"&decode(I3(i))&"</option>"
			end if
		end if
	next
end sub

%>