jQuery(function($){
	$("h2 span a").wrapInner('<i class=yc></i>').prepend("<i class=y1/><i class=y2><b/></i>").append("<i class=y2><b/></i><i class=y1/>");

	$(".k_table_form tbody:first tr td, .k_table_form tbody:first tr th").addClass('noborder');

	$('#bottom').prepend("<em/>");

	$('.k_menu li ul li.hr').prepend("<i/>");

	$('.k_table_form , .k_table_list').before("<i class=\"y1_table yc_top\"/><i class=y2_table><b/></i>").after("<i class=y2_table><b/></i><i class=\"y1_table yc_bottom\"/>");

	//IE6
	if($.browser.msie && $.browser.version<7){
		$("h2 span a").each(function(){
			$(this).width($(this).text().length * 12 + 42);
		});
	}

});

