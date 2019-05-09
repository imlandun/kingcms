<!--#include file="../system/plugin.asp"-->
<%
dim wf
set king=new kingcms
king.checkplugin king.path '检查插件安装状态
set wf=new webftp
	select case action
	case"" king_def
	case"edt" king_edt
	case"set" king_set
	case"create" king_create
	case"upfile" king_upfile
	case"text" king_text
	case"img","down" king_img_down
	end select
set wf=nothing
set king=nothing

'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_def()
	king.head king.path,wf.lang("title")
	dim rs,data,i,dp'lpath:linkpath
	dim but,sql,path,paths,js,inbut,dpath,filename

	wf.list

	path=quest("path",0):if len(path)=0 then path=king.inst
	'判断是否为文件
	paths=split(path,"/")
	if instr(paths(ubound(paths)),chr(46)) then'如果是文件，则进入文件操作界面
		dpath=server.urlencode(left(path,len(path)-len(paths(ubound(paths)))))
		filename=server.urlencode(paths(ubound(paths)))
		select case king_filecate(king.extension(paths(ubound(paths))))
		case"img" '浏览
			response.redirect "index.asp?action=img&path="&dpath&"&filename="&filename
		case"htm","txt","xls" '编辑
			response.redirect "index.asp?action=text&path="&dpath&"&filename="&filename
		case else '下载
			response.redirect "index.asp?action=down&path="&dpath&"&filename="&filename
		end select
	end if
	if right(path,1)<>"/" then path=path&"/"

	set dp=new record
		if king.isexist("temp/"&king.name&".inc") then inbut="|-|paste:"&encode(wf.lang("common/paste"))&"|clear:"&encode(wf.lang("common/clear"))'如果这个临时文件存在
		but=dp.sect("copy:"&encode(wf.lang("common/copy"))&"|cut:"&encode(wf.lang("common/cut"))&inbut)
		js=   "'<td>'+cklist(K[0]+'|"&path&"'+K[1])+'<a href=""index.asp?path='+encodeURIComponent('"&path&"'+K[1])+'""><img src=""../system/images/os/file/'+K[0]+'.gif""/> '+K[1]+'</a></td>'"
		js=js&"+'<td>'+K[2]+'</td>'"
		js=js&"+'<td>'+K[3]+'</td>'"
		js=js&"+'<td>'+K[4]+'</td>'"

		Il "<form name=""form1"" class=""k_form"">"
		Il "<script type=""text/javascript"">"
		Il "var but='"&htm2js(but)&"';document.write(but);"
		Il "function ll(){var K=ll.arguments;document.write('<tr>'+"&js&"+'</tr>');};var k_delete='"&htm2js(king.lang("confirm/delete"))&"';var k_clear='"&htm2js(king.lang("confirm/clear"))&"';"
		Il "function gm(url,id,obj){if (obj.options[obj.selectedIndex].value!=""""||obj.options[obj.selectedIndex].value!=""-"")"
		Il "{var I1=escape(obj.options[obj.selectedIndex].value);var isconfirm;"
		Il "if (I1=='delete'){isconfirm=confirm(k_delete);}else if (I1=='clear')"
		Il "{isconfirm=confirm(k_clear);}else{isconfirm=true};"
		Il "if (I1!='-'){var verbs=""submits=""+I1+""&path="&server.urlencode(path)&"&list=""+escape(getchecked());"
		Il "if (isconfirm){posthtm(url,id,verbs);}}}if(obj.options[obj.selectedIndex].value){obj.options[0].selected=true;}}</script>"

		Il king_table_s
		Il "<tr><th>"&wf.lang("list/name")&"</th><th>"&wf.lang("list/size")&"</th><th>"&wf.lang("list/type")&"</th><th>"&wf.lang("list/date")&"</th></tr>"
		Il "<script>"
		
		king_getfolder(path)

		Il "</script>"


		Il "</table>"
		Il "<script type=""text/javascript"">document.write(but);</script>"
		Il "</form>"
	set dp=nothing

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_getfolder(l1)
'	on error resume next
	dim l5,l6,l8,fs
	set fs=Server.CreateObject(king_fso)
	l8=server.mappath(l1)
	if fs.folderexists(l8)=false then king.error king.lang("error/foldernone")&"<br/>"&l1'判断文件夹是否存在
	set l5=fs.getfolder(l8)
	for each l6 in l5.subfolders
		Il "ll('dir','"&htm2js(l6.name)&"','--','"&htm2js(l6.type)&"','"&htm2js(l6.datecreated)&"');"
	next

	for each l6 in l5.files
		Il "ll('"&king_filecate(king.extension(l6.name))&"','"&htm2js(l6.name)&"','"&htm2js(king.formatsize(l6.size))&"','"&htm2js(l6.type)&"','"&htm2js(l6.datelastmodified)&"');"
	next
	set l5=nothing
	set l6=nothing
	set fs=nothing
	if err.number<>0 then err.clear
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
function king_filecate(l1)
	dim I1'改正后的扩展名长度必须为3
	select case lcase(l1)
	case"doc","inc","mid","pdf","ppt" I1=l1
	case"swf","fla" I1="fla"
	case"htm","html","shtml","shtm","asp","php" I1="htm"
	case"jpg","jpeg","gif","bmp","png" I1="img"
	case"mov","avi" I1="mov"
	case"zip","rar" I1="tar"
	case"txt","css","xml","js" I1="txt"
	case"wma","mp3","mp2","mp" I1="wma"
	case"xls","xslt" I1="xls"
	case else I1="sys"
	end select
	king_filecate=I1
end function
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_img_down()
	king.head king.path,wf.lang("common/"&action)

	dim path,filename,fs,item,imgsize
	path=quest("path",0)
	filename=quest("filename",0)
	wf.list

	Il "<div class=""k_form"">"
	if action="img" then
		Il "<p><a href="""&path&filename&""" target=""_blank""><img src="""&path&filename&"""/></a></p>"
	else
		Il "<p><a href="""&path&filename&""" target=""_blank""><img src=""../system/images/os/file/"&king_filecate(king.extension(filename))&".gif""/> "&path&filename&"</a></p>"
	end if
	set fs=server.createobject(king_fso)
	set item=fs.getfile(server.mappath(path&filename))
	Il "<p><label>"&wf.lang("list/name")&" : "&item.name&"</label></p>"
	Il "<p><label>"&wf.lang("list/type")&" : "&item.type&"</label></p>"
	Il "<p><label>"&wf.lang("list/size")&" : "&king.formatsize(item.size)&"</label></p>"
	if action="img" then

		imgsize=king.imgsize(path&filename)
		if len(imgsize)>0 then
			Il "<p><label>"&king.lang("brow/imgsize")&" : "&imgsize&" pixels</label></p>"
		end if

	end if
	Il "<p><label>"&wf.lang("list/datecreated")&" : "&item.datecreated&"</label></p>"
	Il "<p><label>"&wf.lang("list/date")&" : "&item.datelastmodified&"</label></p>"
	set item=nothing
	set fs=nothing
	Il "</div>"

end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_text()
	king.head king.path,wf.lang("common/text")

	dim path,filename,filetext,isfile:isfile=false'isfile：是否为文件
	dim fileext,extname

	'path
	if king.ismethod then
		path=form("path")
	else
		path=quest("path",0):if len(path)=0 then path=king.inst
	end if

	'获得filename值，并作判断
	if king.ismethod then filename=form("filename") else filename=quest("filename",0)
	if len(filename)>2 then
		if instr(mid(filename,2,len(filename)-2),".")>0 then
			isfile=true
			extname=king.extension(filename)
			select case extname'获得文件扩展名的类型
			case"htm","html","shtml","shtm","xml" fileext="html"
			case"asp" fileext="vbscript"
			case"css","php" fileext=extname
			case"js" fileext="javascript"
			case else fileext="text"
			end select
		end if
	else
		fileext="text"
	end if

	'filetext
	if king.ismethod then
		filetext=form("filetext")
	else
		if isfile then
			filetext=king.readfile(path&filename)
		end if
	end if

	wf.list


	Il "<form name=""form1"" method=""post"" action=""index.asp?action=text"" class=""k_form"">"
	king.form_input "filename",wf.lang("label/name"),filename,"filename|6|"&encode(wf.lang("check/name"))&"|3-100;"&isfile&"|13|"&encode(wf.lang("check/name"))'filename
'	Il "<script src="""&king_system&"system/codepress/codepress.js"" type=""text/javascript""></script>"
	Il "<p id=""editor""><label>"&wf.lang("label/text")&"</label><textarea name=""filetext"" rows=""25"" cols=""100"" class=""codepress "&fileext&""" id=""filetext"">"&formencode(filetext)&"</textarea></p>"
	king.form_hidden "path",path

	king.form_but "save"

	if king.ismethod and king.ischeck then
		king.savetofile path&filename,filetext
		Il "<script>alert('"&htm2js(wf.lang("alert/saveok"))&"');</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_create()
	king.nocache
	king.head king.path,0
	dim I1,wfid,rs
	wfid=quest("wfid",2)
	set rs=conn.execute("select wfid from kingwf where wfid="&wfid)
		if not rs.eof and not rs.bof then
			I1="<a href="""&king_system&"system/link.asp?url="&server.urlencode(king.inst&"/"&rs(0))&""" target=""_blank""><img src=""../system/images/os/brow.gif"" class=""os"" /></a>"
		else
			I1="<img src=""../system/images/os/error.gif"" class=""os""/>"
		end if
		rs.close
	set rs=nothing
	wf.create wfid
	king.txt I1
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_set()
	king.nocache
	king.head king.path,0
	dim list,lists,i,file,tmp,tmps,files,fls,flss,fname
	list=form("list")

	select case form("submits")
	case"copy","cut"
		if len(list)>0 then
			king.createfolder wf.temp
			king.savetofile wf.temp&"/"&king.name&".inc",form("submits")&"???"&list
			king.flo wf.lang("flo/"&form("submits")),0
		else
			king.flo wf.lang("flo/select"),0
		end if
	case"paste"
		tmp=king.readfile(wf.temp&"/"&king.name&".inc")
		tmps=split(tmp,"???")
		files=split(tmps(1),",")'文件列表
		for i=0 to ubound(files)
			fls=split(files(i),"|")
			flss=split(fls(1),"/")
			fname=flss(ubound(flss))
			if fls(0)="dir" then
				king.copyfolder fls(1),form("path")&fname
				'如果是移动，则删除原来的文件
				if tmps(0)="cut" then king.deletefolder fls(1)
			else
				king.copyfile fls(1),form("path")&fname
				if tmps(0)="cut" then king.deletefile fls(1)
			end if
		next
		'粘贴完后删除剪切板
		king.deletefile wf.temp&"/"&king.name&".inc"

		king.flo wf.lang("flo/"&tmps(0)&"paste"),1
	case"clear"
		king.deletefile wf.temp&"/"&king.name&".inc"
		king.flo wf.lang("flo/clear"),1
	case"delete"
		if len(list)>0 then
			lists=split(list,",")
			for i=0 to ubound(lists)
				file=split(lists(i),"|")
				if file(0)="dir" then
					king.deletefolder file(1)
				else
					king.deletefile file(1)
				end if
			next
			king.flo wf.lang("flo/deleteok"),1
		else
			king.flo wf.lang("flo/select"),0
		end if
	case"text"
		
	case"crtfolder"
		if len(form("fdname"))>0 then
			king.createfolder form("path")&form("fdname")
			king.flo wf.lang("flo/crtfolder")&"<br/>"&wf.lang("common/wwwroot")&":"&form("path")&"<strong>"&form("fdname")&"</strong>",1
		else
			king.ol="<div class=""k_form"">"
			king.ol="<p><label>"&wf.lang("label/fdname")&"</label><input type=""text"" id=""fdname"" class=""in3"" /></p>"
			king.ol="<div class=""k_but""><input type=""button"" value="""&wf.lang("common/create")&""" onclick=""javascript:posthtm('index.asp?action=set','flo','submits=crtfolder&fdname='+encodeURIComponent(document.getElementById('fdname').value)+'&path="&form("path")&"')"" /></div>"
			king.ol="</div>"
			king.flo king.writeol,2
		end if
	end select
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_edt()
	king.head king.path,wf.lang("title")

	dim rs,data,dataform,sql,i,wfid
	sql="wfname"
	wfid=quest("wfid",2)
	if len(wfid)=0 then:wfid=form("wfid")
	if len(wfid)>0 then'若有值的情况下
		if validate(wfid,2)=false then king.error king.lang("error/invalid")
	end if
	
	if king.ismethod or len(wfid)=0 then
		dataform=split(sql,",")
		redim data(ubound(dataform),0)
		for i=0 to ubound(dataform)
			data(i,0)=form(dataform(i))
		next
	else
		set rs=conn.execute("select "&sql&" from kingwf where wfid="&wfid&";")
			if not rs.eof and not rs.bof then
				data=rs.getrows()
			else
				king.error king.lang("error/invalid")
			end if
			rs.close
		set rs=nothing
	end if

	wf.list
	Il "<form name=""form1"" method=""post"" action=""index.asp?action=edt"">"

	king.form_input "wfname",wf.lang("label/name"),data(0,0),"wfname|6|"&encode(wf.lang("check/name"))&"|1-50"'wfname

	Il "<p><label>"&wf.lang("label/text")&"</label><textarea name=""wftext"" rows=""15"" cols=""10"" class=""in5"">"&formencode(data(1,0))&"</textarea>"
	Il king.check("wftext|0|"&encode(wf.lang("check/text")))
	Il "</p>"
	
	king.form_but "save"
	king.form_hidden "wfid",wfid

	Il "</form>"

	if king.ischeck and king.ismethod then
		if len(wfid)>0 then
			conn.execute "update kingwf set wfname='"&safe(data(0,0))&"' where wfid="&wfid&";"
		else
			conn.execute "insert into kingwf ("&sql&") values ('"&safe(data(0,0))&"')"
			wfid=king.newid("kingwf","wfid")
		end if
		'neworder：king.neworder("kingwf","wforder")
		wf.create wfid
		
		'日期js更新过程写一个函数，因为其他地方还得调用
'		king.savetofile [MODELPATH],[MODELFILE]'创建日期文件
		Il "<script>alert('"&htm2js(wf.lang("alert/saveok"))&"\n\n"&htm2js(data(0,0))&"');</script>"
	end if
end sub
'  *** Copyright &copy KingCMS.com All Rights Reserved ***
sub king_upfile()
	Server.ScriptTimeOut=600
	dim i,path,ol

	king.head king.path,wf.lang("common/up")

	wf.list

	'path
	if king.ismethod then
		path=form("path")
	else
		path=quest("path",0):if len(path)=0 then path=king.inst
	end if

	if king.ismethod then

		upload.FileType=""
		upload.SavePath=""
		ol="<div class=""k_form""><ol class=""text"">"

		for i=0 to 14
			if len(upload.form("upfile"&i&"_size"))>0 then
				ol=ol&"<li><a href=""index.asp?path="&server.urlencode(path&upload.form("upfile"&i&"_name"))&""">"&path&upload.form("upfile"&i&"_name")&"</a> "&king.formatsize(upload.form("upfile"&i&"_size"))&" &nbsp; ["&wf.lang("tip/"&upload.save("upfile"&i,path&upload.form("upfile"&i&"_name")))&"] </li>"
			else
				ol=ol&"<li>--</li>"
			end if
		next
		ol=ol&"</ol></div>"
		Il ol
		response.end
	end if

	Il "<form name=""form1"" class=""k_form"" enctype=""multipart/form-data"" method=""post"" action=""index.asp?action=upfile"">"

	Il "<ol id=""upfiles"" class=""text"">"
	for i=0 to 14
		Il "<li><input class=""in4"" type=""file"" name=""upfile"&i&""" /></li>"
	next
	Il "</ol>"
	
	king.form_hidden "path",path
	king.form_but "upfile"
	Il "</form>"

end sub
%>