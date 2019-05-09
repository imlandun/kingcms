<!--#include file="../system/plugin.asp"-->
<%
dim art
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set art=new easyarticle
	select case action
	case"" king_def
	end select
set art=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()

	dim query,i,space,rn,dp,sql,qcount,selected,tt,rs,listname,listpath,tquery
	tt=timer
	
	tquery=quest("query",4)

	space=quest("space",2)
	if cstr(space)="1" then'内容
		query=king.likey("artdescription",tquery)
	else'标题搜索
		query=king.likey("arttitle",tquery)
	end if

	rn=quest("rn",2)
	if int(rn)>100 then rn=100
	if int(rn)<10 then rn=10

	king.ol="<div id=""k_select"">"


	'有提交搜索值的时候，显示搜索结果
	if len(query)>0 then
		sql="select top 1000 artid,listid,arttitle,artdescription,artdate from kingeasyart where "&query&" order by artdate desc;"
		qcount=conn.execute("select count(artid) from kingeasyart where "&query&";")(0)

		king.ol="<form name=""form1"" method=""get"" action=""search.asp"" class=""k_form"">"
		king.ol="<p><input type=""text"" name=""query"" value="""&quest("query",0)&""" maxlength=""100"" class=""k_in3"" /> "

		king.ol="<select name=""space"">"
		if cstr(space)<>"1" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""0"""&selected&">"&art.lang("label/sel/title")&"</option>"
		if cstr(space)="1" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""1"""&selected&">"&art.lang("label/sel/content")&"</option>"
		king.ol="</select> "

		king.ol="<select name=""rn"">"
		if cstr(rn)="10" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""10"""&selected&">10</option>"
		if cstr(rn)="20" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""20"""&selected&">20</option>"
		if cstr(rn)="50" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""50"""&selected&">50</option>"
		if cstr(rn)="100" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""100"""&selected&">100</option>"
		king.ol="</select> "

		king.ol="<input type=""submit"" value="""&king.lang("common/search")&""" class=""k_submit""/>"
		king.ol="</p>"
		king.ol="</form>"

		king.ol="<div class=""k_search"">"

		set dp=new record
			dp.create sql
			dp.purl="search.asp?rn="&rn&"&pid=$&query="&server.urlencode(quest("query",0))&"&space="&space
			'有符合搜索项目的时候显示
			if dp.length>=0 then
				king.ol="<p>"&replace(art.lang("tip/search"),"[***number***]",formatnumber(qcount,0,true))&"</p>"
				king.ol=dp.plist
				'循环显示搜索结果列表
				for i=0 to dp.length
					set rs=conn.execute("select listname,listpath from kingeasyart_list where listid="&dp.data(1,i)&";")
						if not rs.eof and not rs.bof then
							listname=rs(0)
							listpath=rs(1)
						end if
						rs.close
					set rs=nothing
					king.ol="<div>"
					king.ol="<h3><a target=""_blank"" href="""&king.inst&listpath&"/"&art.initially&dp.data(0,i)&""">"&keylight(htmlencode(dp.data(2,i)),tquery)&"</a></h3>"
					king.ol="<p>"&keylight(htmlencode(king.lefte(dp.data(3,i),200)),tquery)&"</p>"
					king.ol="<p><span>"&dp.data(4,i)&"</span> - <a target=""_blank"" href="""&king.inst&listpath&""">"&htmlencode(listname)&"</a></p>"
					king.ol="</div>"
				next
				king.ol=dp.plist
			
			'没有项目符合搜索结果的时候显示
			else
				king.ol="<div><p>"&art.lang("tip/noart")&"</p></div>"
			end if
		set dp=nothing

		king.ol="</div>"

		king.value "guide",encode("<a href=""search.asp"">"&king.lang("common/search")&"</a> &gt;&gt; "&htmlencode(quest("query",0)))



	'没有提交搜索值，显示搜索框
	else
		king.ol="<form name=""form1"" method=""get"" action=""search.asp"" class=""k_form"">"
		king.ol="<p><label>"&art.lang("label/key")&"</label><input type=""text"" name=""query"" maxlength=""100"" class=""k_in4""/></p>"

		king.ol="<p><label>"&art.lang("label/space")&"</label>"
		king.ol="<select name=""space"">"
		king.ol="<option value=""0"">"&art.lang("label/sel/title")&"</option>"
		king.ol="<option value=""1"">"&art.lang("label/sel/content")&"</option>"
		king.ol="</select></p>"

		king.ol="<p><label>"&art.lang("label/rn")&"</label>"
		king.ol="<select name=""rn"">"
		king.ol="<option value=""10"">10</option>"
		king.ol="<option value=""20"">20</option>"
		king.ol="<option value=""50"">50</option>"
		king.ol="<option value=""100"">100</option>"
		king.ol="</select></p>"

		king.ol="<div><input type=""submit"" value="""&king.lang("common/search")&""" /></div>"
		king.ol="</form>"

		king.value "guide",encode(king.lang("common/search"))
	end if
	king.ol="</div>"



	
	king.value "title",encode(tquery)
	king.value "inside",encode(replace(king.writeol,"[**timer**]",formatnumber(timer-tt,2,true)))
	king.outhtm king.stemplate,"",king.invalue

end sub

%>