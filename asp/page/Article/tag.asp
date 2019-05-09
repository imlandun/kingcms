<!--#include file="../system/plugin.asp"-->
<%
dim art
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set art=new article
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
	if len(space)=0 then space=0
	select case cstr(space)
	case""
		if len(tquery)>0 then
			query=king.likey("artkeywords",tquery)&"or "&king.likey("artdescription",tquery)&"or "&king.likey("artauthor",tquery)&"or "&king.likey("arttitle",tquery)
		else
			query=king.likey("artkeywords",tquery)
		end if
	case"1"
		query=king.likey("artdescription",tquery)
	case"2"
		query=king.likey("artauthor",tquery)
	case else
		query=king.likey("arttitle",tquery)
	end select

	rn=quest("rn",2)
	if int(rn)>100 then rn=100
	if int(rn)<10 then rn=10

	king.ol="<div id=""k_search"">"


	'有提交搜索值的时候，显示搜索结果
	if len(query)>0 then
		sql="select top 1000 artid,listid,arttitle,artdescription,artdate,artgrade,artpath,artauthor,artfrom from kingart where artshow=1 and "&query&" order by artdate desc;"
		qcount=conn.execute("select count(artid) from kingart where artshow=1 and "&query&";")(0)

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
					set rs=conn.execute("select listname,listpath from kingart_list where listid="&dp.data(1,i)&";")
						if not rs.eof and not rs.bof then
							listname=rs(0)
							listpath=rs(1)
						end if
						rs.close
					set rs=nothing
					king.ol="<div>"
					king.ol="<h3><a target=""_blank"" href="""&art.getpath(dp.data(0,i),dp.data(5,i),king.inst&listpath&"/"&dp.data(6,i))&""">"&keylight(htmlencode(dp.data(2,i)),tquery)&"</a></h3>"
					king.ol="<p>"&keylight(htmlencode(king.lefte(dp.data(3,i),200)),tquery)&"</p>"
					king.ol="<p><a target=""_blank"" href="""&king.inst&listpath&"/"">"&htmlencode(listname)&"</a> - <a href=""search.asp?space=2&query="&server.urlencode(dp.data(7,i))&""">"&htmlencode(dp.data(7,i))&"</a> - <span>"&dp.data(4,i)&"</span></p>"
					king.ol="</div>"
				next
				king.ol=dp.plist
			
			'没有项目符合搜索结果的时候显示
			else
				king.ol="<div><p>"&art.lang("tip/noart")&"</p></div>"
			end if
		set dp=nothing

		king.ol="</div>"

		king.value "guide",encode("<a href=""tag.asp"">TagCloud</a> &gt;&gt; "&htmlencode(quest("query",0)))
		king.value "title",encode(tquery)

	'没有提交搜索值，显示搜索框
	else
		dim data
		'获得关键字组
		set rs=conn.execute("select sitekeywords from kingsystem where systemname='KingCMS';")
			if not rs.eof and not rs.bof then
				if len(rs(0))>0 then
					data=split(rs(0),",")
					for i = 0 to ubound(data)
						king.ol="<span class=""tag""><a href=""/page/article/tag.asp?query="&data(i)&""" target=""_blank"" title="""&data(i)&""">"&data(i)&"</a></span>"
					next
				end if
			end if
			rs.close
		set rs=nothing

		king.value "guide",encode("TagCloud")
		king.value "title",encode("TagCloud")
	end if
	king.ol="</div>"

	king.value "inside",encode(replace(king.writeol,"[**timer**]",formatnumber(timer-tt,2,true)))
	king.outhtm king.stemplate,"",king.invalue

end sub

%>