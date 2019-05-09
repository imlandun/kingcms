<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%option explicit:response.charset="utf-8"
'url  *** ***  www.KingCMS.com  *** ***
king_url
sub king_url()
	dim gourl:gourl=request("url")
	dim query_string:query_string=request.servervariables("query_string")
	if len(gourl)>0 then
		if instr(query_string,"?")>0 then
			gourl=right(query_string,len(query_string)-4)
		end if
		response.write "<script type=""text/javascript""><!--"&vbcr&"eval(""parent.location='"&gourl&"'"");"&vbcr&"//--></script>"
	end if
end sub
%>
