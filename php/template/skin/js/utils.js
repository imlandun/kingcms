var browser = function(){
	//检测浏览器
	var iUserAgent = navigator.userAgent;
	var iAppVersion = parseFloat(navigator.appVersion);
	var isOpera = iUserAgent.indexOf("Opera") > -1;
	var isKHTML = iUserAgent.indexOf("KHTML") > -1 || iUserAgent.indexOf("Konqueror") > -1 || iUserAgent.indexOf("AppleWebKit") > -1;	
	if(isKHTML){
		var isChrome = iUserAgent.indexOf("Chrome") > -1;
		var isSafari = iUserAgent.indexOf("AppleWebKit") > -1 && !isChrome;
		var isKonq = iUserAgent.indexOf("Konqueror") > -1;
	}
	var isIE = iUserAgent.indexOf("compatible") > -1 && iUserAgent.indexOf("MSIE") > -1 && !isOpera;
	var isMoz = iUserAgent.indexOf("Gecko") > -1 && !isKHTML;
	var isNS4 = !isOpera && !isMoz && !isKHTML && !isIE && (iUserAgent.indexOf("Mozilla") ==0) && (navigator.appName == "Netscape") && (fAppVersion >=4.0 && fAppVersion <= 5.0);
	//此处为检测平台
	var isWin = (navigator.platform == "Win32") || (navigator.platform == "Windows");
	var isMac = (navigator.platform == "Mac68K") || (navigator.platform == "MacPPC") || (navigator.platform == "Macintosh");
	var isUnix = (navigator.platform == "X11") && !isWin && !isMac;
	if(isOpera){
		return "opera";	
	} else if(isChrome) {
		return "chrome";
	} else if(isSafari){
		return "safari";
	} else if(isKonq){
		return "konq";	
	} else
	if (isIE) {
		//此处没用userAgent来检测，主要是考虑IE9浏览器按F12可以切换到IE7，IE8;用userAgent会检测不出来
		if (parseInt(iAppVersion, 10) <= 6) {
			return "IE6";
		} else if (document.all && !document.querySelector) {
			return "IE7";
		} else if (document.all && document.querySelector && !document.addEventListener) {
			return "IE8";
		} else {
			return "IE9+";
		}
	} else if (isMoz) {
		return "mozilla";
	} else if (isNS4) {
		return "ns4";
	}
	
}