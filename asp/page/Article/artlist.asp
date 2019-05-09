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

	dim rs,pid,listid

	listid=quest("listid",2)
	pid=quest("pid",2):if len(pid)=0 then pid=1

	set rs=conn.execute("select listid from kingart_list where listid="&listid&";")
		if not rs.eof and not rs.bof Then
		
			king.txt art.artlist(listid)',pid)

		else
			king.error art.lang("error/notart")
		end if
		rs.close
	set rs=nothing

end sub

%>