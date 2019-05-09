<!--#include file="../system/plugin.asp"-->
<%
dim kc
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set kc=new linkclass
	select case action
	case"" king_def
	case"nextpage" king_nextpage
	case"hit" king_hit
	end select
set kc=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()

	dim rs,irs,data,i,listpath
	dim pid,kid,kpath

	kid=quest("kid",2)
	pid=quest("pid",2)

	set rs=conn.execute("select listid,kgrade,kpath from king__link_page where kshow=1 and kid="&kid&";")
		if not rs.eof and not rs.bof then

			kc.head rs(1)

			set irs=conn.execute("select listpath from king__link_list where listid="&rs(0)&";")
				if not irs.eof and not irs.bof then
					listpath=irs(0)
				else
					king.error king.lang("error/invalid")
				end if
				irs.close
			set irs=nothing

			kpath=kc.pagepath(king.inst&listpath&"/"&rs(2),pid)

			if king.isfile(rs(2))=false then'file
				kpath=kpath&"/"&king_ext
			end if
			if king.isexist(kpath)=false then
				kc.createpage kid
				if king.isexist(kpath)=false then
					king.error kc.lang("error/notart")
				end if
			end if
			king.txt king.readfile(kpath)

		else
			king.error kc.lang("error/notart")
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_nextpage()
	dim rs,kid,listid,korder,listpath,listname

	kid=form("kid")
	if validate(kid,2)=false then king.txt king.lang("error/invalid")

	set rs=conn.execute("select listid,korder from king__link_page where kid="&kid&";")
		if not rs.eof and not rs.bof then
			listid=rs(0)
			korder=rs(1)
		else
			king.txt kc.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	set rs=conn.execute("select listpath,listname from king__link_list where listid="&listid&";")
		if not rs.eof and not rs.bof then
			listpath=rs(0)
			listname=rs(1)
		else
			king.txt king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing

	set rs=conn.execute("select top 1 ktitle,kgrade,kpath from king__link_page where kshow=1 and listid="&listid&" and korder>"&korder&" order by korder asc,kid asc;")
		if not rs.eof and not rs.bof then
			kc.createpage kid
			king.txt "<a href="""&kc.getpath(kid,rs(1),king.inst&listpath&"/"&rs(2))&""">"&htmlencode(rs(0))&"</a>"
		else'如果不存在，则输出js加载来验证
			king.txt "<a href="""&king.inst&listpath&"/"">["&htmlencode(listname)&"]</a>"
		end if
		rs.close
	set rs=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_hit()
	dim kid,rs,cookie

	kid=form("kid")
	if validate(kid,2)=false then king.txt king.lang("error/invalid")

	set rs=conn.execute("select khit from king__link_page where kid="&kid&";")
		if not rs.eof and not rs.bof then

			cookie=request.cookies("link")("count")
			if king.instre(cookie,kid)=false then'如果列表中没有这个id就++
				conn.execute "update king__link_page set khit=khit+1 where kid="&kid&";"
				if len(cookie)>0 then
					response.cookies("link")("count")=cookie&","&kid
				else
					response.cookies("link")("count")=kid
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