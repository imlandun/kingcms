$(window).load(function () {
    //计算导航的位置
    function setNavPostion() {
        var w = $(window).width();
        var fp_lw = $(".fr").outerWidth(true);
        var fp_rw = $(".fp_left").outerWidth(true);
        var fp_tw = $(".fp_title").outerWidth(true);
        var fp_w = fp_lw + fp_rw + fp_tw;
        if (w < fp_w) {
            var navClone = $(".fr").html();
            $(".sys_info").html(navClone);
            $(".sys_info").find("span").html("|");
        } else {
            $(".sys_info").html("");
        }

    }
    $(window).bind("resize", function () {
        setNavPostion()
    });
    setNavPostion();

    //菜单伸缩
    var handle = $(".k_menu>li>a");
    var url = document.URL.replace("/", "");
    var showObj = $(".k_menu>li>ul").first();
    $(".k_menu>li>ul>li>a").each(function () {
        aurl = $.trim($(this).attr("href")).replace("../", "");
        if (aurl == url) {
            showObj = $(this).closest("ul");
            $(this).parent().css({ "background": "#f5f5f5" });
            $(this).css({ "color": "#990000" });
            return false;
        }
    });
    $(showObj).show();
    $(handle).bind("click", function () {
        var list = $(this).next();
        if (list.is($(showObj))) {
            list.is(":visible") ? list.fadeOut(200) : list.fadeIn(200);
            return;
        } else {
            $(list).fadeIn(200);
        }
        if (showObj) { $(showObj).hide(); }
        showObj = list;
    });
    //计算中间部分高度
    function set_container_height() {
        var h = $(window).height() - 51 - 27 -70;
        $(".sys_container").height(h);
    };
    set_container_height();
    //窗口resize,resize里头添加了一个setTimeout，修正resize多次执行的问题
    var resize_timer = 0;
    $(window).resize(function () {
        clearTimeout(resize_timer);
        resize_timer = setTimeout(function () {
            set_container_height();
        }, 200);
    });

});