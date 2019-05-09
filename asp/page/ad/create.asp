<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'     用户中心首页
'***  ***  ***  ***  ***

dim ad
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set ad=new advertising
	select case action
	case"" king_def
	end select
set ad=nothing
set king=nothing
'def  *** Copyright &copy KingCMS.com All Rights Reserved. ***
sub king_def()
	king.nocache
	ad.create "*"
	dim jstime
	jstime=quest("time",0)
	king.savetofile "../../"&ad.path&"/update.js",ad.updatejs(jstime)'创建日期文件
end sub
%>