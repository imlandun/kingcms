<%
dim datetime
datetime=request("datetime")
if len(datetime)>0 then response.write datediff("h",datetime,now())
%>