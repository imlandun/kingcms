<!--#include file="../system/plugin.asp"-->
<%
dim art
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set art=new article
	select case action
	case"" king_def
	case"nextpage" king_nextpage
	case"hit" king_hit
	end select
set art=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()

	dim rs,irs,data,i,listpath
	dim pid,artid,artpath

	artid=quest("artid",2)
	pid=quest("pid",2)

	

	set rs=conn.execute("select listid,artgrade,artpath from kingart where artshow=1 and artid="&artid&";")
		if not rs.eof and not rs.bof then

			art.head rs(1)

			set irs=conn.execute("select listpath from kingart_list where listid="&rs(0)&";")
				if not irs.eof and not irs.bof then
					listpath=irs(0)
				else
					king.error king.lang("error/invalid")
				end if
				irs.close
			set irs=nothing

			artpath=art.pagepath(king.inst&listpath&"/"&rs(2),pid)

			if king.isfile(rs(2))=false then'file
				artpath=artpath&"/"&king_ext
			end if
			if king.isexist(artpath)=false then
				art.createpage artid
				if king.isexist(artpath)=false then
					king.error art.lang("error/notart")
				end if
			end if
			king.txt king.readfile(artpath)

		else
			king.error art.lang("error/notart")
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_nextpage()
	dim rs,artid,listid,artorder,listpath,listname

	artid=form("artid")
	if validate(artid,2)=false then king.txt king.lang("error/invalid")

	set rs=conn.execute("select listid,artorder from kingart where artid="&artid&";")
		if not rs.eof and not rs.bof then
			listid=rs(0)
			artorder=rs(1)
		else
			king.txt art.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	set rs=conn.execute("select listpath,listname from kingart_list where listid="&listid&";")
		if not rs.eof and not rs.bof then
			listpath=rs(0)
			listname=rs(1)
		else
			king.txt king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	set rs=conn.execute("select top 1 arttitle,artgrade,artpath from kingart where artshow=1 and listid="&listid&" and artorder>"&artorder&" order by artorder asc,artid asc;")
		if not rs.eof and not rs.bof then
			art.createpage artid
			king.txt "<a href="""&art.getpath(artid,rs(1),king.inst&listpath&"/"&rs(2))&""">"&htmlencode(rs(0))&"</a>"
		else'如果不存在，则输出js加载来验证
			king.txt "<a href="""&king.inst&listpath&"/"">["&htmlencode(listname)&"]</a>"
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_hit()
	dim artid,rs,cookie

	artid=form("artid")
	if validate(artid,2)=false then king.txt king.lang("error/invalid")

	set rs=conn.execute("select arthit from kingart where artid="&artid&";")
		if not rs.eof and not rs.bof then

			cookie=request.cookies("article")("count")
			if king.instre(cookie,artid)=false then'如果列表中没有这个id就++
				conn.execute "update kingart set arthit=arthit+1 where artid="&artid&";"
				if len(cookie)>0 then
					response.cookies("article")("count")=cookie&","&artid
				else
					response.cookies("article")("count")=artid
				end if
			end if

			king.txt rs(0)
		else
			king.txt 1
		end if
		rs.close
	set rs=nothing
	

end sub
%>