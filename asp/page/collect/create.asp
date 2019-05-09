<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set kc=new collectclass
	select case action
	case"" king_def
	end select
set kc=nothing
set king=nothing
'def  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	king.nocache
	dim jslistid,jstime,rs
	dim this_url,id_url

	jstime=form("time")
	jslistid=form("list")


	if validate(jstime,2)=false or validate(jslistid,2)=false then
		king.error king.lang("error/invalid")&"|"&jstime&"|"&jslistid
	else
		if validate(jstime,2)=false then
			jstime=kc.uptime
		end if
	end if

	set rs=conn.execute("select listid from kingcollect_list where listid="&jslistid&";")
		if not rs.eof and not rs.bof then
		else
			exit sub
		end if
		rs.close
	set rs=nothing

	set rs=conn.execute("select top 1 id,urlpath from kingcollect_url_"&jslistid&" where isok=0 and urlpath like '%"&safe(kc.datalist(11))&"%' order by id asc;")
		if not rs.eof and not rs.bof then
			this_url=rs(1)
			id_url=rs(0)
		else
			conn.execute "update kingcollect_url_"&jslistid&" set isok=0 where urlpath='"&safe(kc.datalist(7))&"';"
			exit sub
		end if
		rs.close
	set rs=nothing

	conn.execute "update kingcollect_url_"&jslistid&" set isok="&kc.getcontent(this_url,kc.datalist(0),jslistid)&" where id="&id_url&";"

	king.savetofile "update.js",kc.updatejs(jstime,jslistid)'创建日期文件

	king.txt ""
end sub
%>