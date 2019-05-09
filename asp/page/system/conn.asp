<%
dim objconn,conn,king,action,tdiff,tnow,upload


'  --- 数据库连接 开始 -------------------------------------------------


Rem  数据库类型,默认是ACCESS数据库

const king_dbtype = 0  Rem  0代表ACCESS数据库类型,1代表MSSQL数据库


Rem  以下参数只设置一种数据库即可


	Rem  ACCESS数据库路径设置

	const king_db = "../../db/King#Content#Management#System.mdb"



	Rem  MSSQL 链接设置

'	SQL服务器地址
	const king_sql_server = "127.0.0.1"

'	数据库名称
	const king_sql_db     = "KingCMS"

'	数据库登录帐号
	const king_sql_user   = "sa"

'	数据库密码
	const king_sql_pwd    = ""


'  --- 数据库连接 结束-------------------------------------------------



if king_dbtype=0 then
	objconn="Provider=Microsoft.Jet.OLEDB.4.0;Data Source="&server.mapPath(king_db)
'	objconn="Driver={Microsoft Access Driver(*.mdb)};DBQ="&server.mapPath(king_db)
else
	objconn="Provider=SQLOLEDB.1;Data Source=" & king_sql_server & ";Initial Catalog=" & king_sql_db & ";User ID=" & king_sql_user & ";Password=" & king_sql_pwd & ";"
end if

action=lcase(request("action"))
tnow=formatdate(now(),0)
tdiff=timer()

%>
