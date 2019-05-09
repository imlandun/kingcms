<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'   远程验证会员页面
'***  ***  ***  ***  ***

set king=new kingcms
king.checkplugin king.path'检查插件安装状态
king.checkremote
select case action
	case"" king_def
	case"newuser" king_newuser
	case"countuser" king_countuser
end select

set king=nothing

'def  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	dim q_name,q_pass,rs

	q_name=quest("name",0)
	q_pass=quest("pass",0)

	set rs=conn.execute("select pplanguage,islock,ppkey,pppass from kingpassport where ppname='"&safe(q_name)&"' and isdel=0;")
		if not rs.eof and not rs.bof then
			if md5(left(rs(2),3)&rs(3),1)=q_pass then
				king.txt q_name&"|"&rs(0)&"|"&rs(1)
			else
				king.txt "KingCMS "&king.systemver
			end if
		else
			king.txt "KingCMS "&king.systemver
		end if
		rs.close
	set rs=nothing
end sub
'newuser  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_newuser()
	dim rs
	set rs=conn.execute("select ppname from kingpassport where isdel=0 order by ppid desc;")
		if not rs.eof and not rs.bof then
			king.txt rs(0)
		else
			king.txt "[Not]"
		end if
		rs.close
	set rs=nothing
end sub
'countuser  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_countuser()
	king.txt conn.execute("select count(*) from kingpassport;")(0)
end sub
%>