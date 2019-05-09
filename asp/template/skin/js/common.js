$(window).load(function(){
	//计算导航的位置
	function setNavPostion(){
		var w = $(window).width();
		var fp_lw = $(".fp_nav").outerWidth(true);
		var fp_rw = $(".fp_left").outerWidth(true);
		var fp_tw = $(".fp_title").outerWidth(true);
		var fp_w = fp_lw+fp_rw+fp_tw;
		if(w<fp_w){
			var navClone = $(".fp_nav").html();
			$(".sys_info").html(navClone);
			$(".sys_info").find("span").html("|");
		} else {
			$(".sys_info").html("");	
		}
		
	}
	$(window).bind("resize",function(){
		setNavPostion()
	});
	setNavPostion();
	
	//
});