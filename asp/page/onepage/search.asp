<!--#include file="../system/plugin.asp"-->
<%
dim one
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set one=new onepage
	select case action
	case"" king_def
	end select
set one=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()

	dim query,i,space,rn,dp,sql,qcount,selected,tt,tquery
	tt=timer
	
	tquery=quest("query",4)

	space=quest("space",2)
	if cstr(space)="1" then'内容
		query=king.likey("onedescription",tquery)
	else'标题搜索
		query=king.likey("onetitle",tquery)
	end if

	rn=quest("rn",2)
	if int(rn)>100 then rn=100
	if int(rn)<10 then rn=10

	king.ol="<div id=""k_select"">"


	'有提交搜索值的时候，显示搜索结果
	if len(query)>0 then
		sql="select top 1000 oneid,onetitle,onedescription,onepath,onename from kingonepage where "&query&" order by oneid desc;"
		qcount=conn.execute("select count(oneid) from kingonepage where "&query&";")(0)

		king.ol="<form name=""form1"" method=""get"" action=""search.asp"" class=""k_form"">"
		king.ol="<p><input type=""text"" name=""query"" value="""&quest("query",0)&""" maxlength=""100"" /> "

		king.ol="<select name=""space"">"
		if cstr(space)<>"1" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""0"""&selected&">标题</option>"
		if cstr(space)="1" then selected=" selected=""selected""" else selected=""
		king.ol="<option value=""1"""&selected&">内容</option>"
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

		king.ol="<input type=""submit"" value=""搜索"" class=""k_submit"" />"
		king.ol="</form>"

		king.ol="<div class=""k_search"">"
		king.ol="<p>约有"&qcount&"项符合 "&htmlencode(quest("query",0))&" 的查询结果，以下是第1-"&rn&"项。 （搜索用时 [**timer**] 秒）</p>"

		set dp=new record
			dp.create sql
			dp.purl="search.asp?rn="&rn&"&pid=$&query="&server.urlencode(quest("query",0))&"&space="&space
			'有符合搜索项目的时候显示
			if dp.length>=0 then
				king.ol=dp.plist
				'循环显示搜索结果列表
				for i=0 to dp.length
					king.ol="<div>"
					king.ol="<h3><a target=""_blank"" href="""&king.inst&dp.data(3,i)&""">"&keylight(htmlencode(dp.data(1,i)),tquery)&"</a></h3>"
					king.ol="<p>"&keylight(htmlencode(king.lefte(dp.data(2,i),200)),tquery)&"</p>"
					king.ol="<p><span>"&dp.data(4,i)&"</span> - <a target=""_blank"" href="""&king.inst&dp.data(3,i)&"/"">"&king.inst&dp.data(3,i)&"</a></p>"
					king.ol="</div>"
				next
				king.ol=dp.plist
			
			'没有项目符合搜索结果的时候显示
			else
				king.ol="<div><p>没有符合要求的内容，请重新搜索！</p></div>"
			end if
		set dp=nothing

		king.value "guide",encode("<a href=""search.asp"">搜索</a> &gt;&gt; "&htmlencode(quest("query",0)))

	'没有提交搜索值，显示搜索框
	else
		king.ol="<form name=""form1"" method=""get"" action=""search.asp"" class=""k_form"">"
		king.ol="<p><label>关键字：</label><input type=""text"" name=""query"" maxlength=""100"" /></p>"

		king.ol="<p><label>搜索范围：</label>"
		king.ol="<select name=""space"">"
		king.ol="<option value=""0"">标题</option>"
		king.ol="<option value=""1"">内容</option>"
		king.ol="</select></p>"

		king.ol="<p><label>每页显示：</label>"
		king.ol="<select name=""rn"">"
		king.ol="<option value=""10"">10</option>"
		king.ol="<option value=""20"">20</option>"
		king.ol="<option value=""50"">50</option>"
		king.ol="<option value=""100"">100</option>"
		king.ol="</select></p>"

		king.ol="<p><input type=""submit"" value=""搜索"" /></p>"
		king.ol="</form>"

		king.value "guide",encode("搜索")
	end if
	king.ol="</div>"

	king.value "title",encode("页面搜索")
	king.value "inside",encode(replace(king.writeol,"[**timer**]",formatnumber(timer-tt,2,true)))
	king.outhtm king.stemplate,"",king.invalue

end sub
%>