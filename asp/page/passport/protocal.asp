<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'       注册协议
'***  ***  ***  ***  ***

dim pp
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set pp=new passport
	select case action
	case"" king_def
	end select
set pp=nothing
set king=nothing
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	dim rs,protocal

	if king_remoteurl<>"../" then response.redirect king_remoteurl&"passport/protocal.asp"

	set rs=conn.execute("select protocal from kingpassport_config where systemname='KingCMS';")
		if not rs.eof and not rs.bof then
			protocal=rs(0)
		else
			king.error king.lang("error/invalid")
		end if
		rs.close
	set rs=nothing
	king.ol="<div class=""k_form"">"
	king.ol=protocal
	king.ol="</div>"

	king.value "title",encode(pp.lang("common/protocal"))
	king.value "inside",encode(king.writeol)
	king.outhtm pp.template,"",king.invalue

end sub


%>