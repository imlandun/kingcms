<!--#include file="../system/plugin.asp"-->
<%
'***  ***  ***  ***  ***
'     更 新 生 成
'***  ***  ***  ***  ***

dim kc
set king=new kingcms
king.checkplugin king.path'检查插件安装状态
set kc=new movieclass
	select case action
	case"" kc.uptoday
	end select
set kc=nothing
set king=nothing
%>