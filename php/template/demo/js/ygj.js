var ygj = ygj || {};
ygj = {
	//确定当前导航位置
	menu:function(){
		var menu = $(".menu");
		var subMenu = $(".sub-menu");
		if(menu[0] || subMenu[0]){
			var menuId = menu.data("id");
			var menuTopId = menu.data("topid");
			//top nav
			var menuCurrent = menu.find("li[data-id="+menuTopId+"]")[0] ? menu.find("li[data-id="+menuTopId+"]") : menu.find("li[data-id="+menuId+"]");
			menuCurrent.find("a").addClass("current");
			//sub nav
			var subMenuId = subMenu.data("id");
			subMenu.find("li[data-id="+subMenuId+"]").find("a").addClass("current");
		}
	}
}
$(function(){
	ygj.menu();
});