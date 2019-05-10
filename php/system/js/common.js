var browser = function () {
    //检测浏览器
    var iUserAgent = navigator.userAgent;
    var iAppVersion = parseFloat(navigator.appVersion);
    var isOpera = iUserAgent.indexOf("Opera") > -1;
    var isKHTML = iUserAgent.indexOf("KHTML") > -1 || iUserAgent.indexOf("Konqueror") > -1 || iUserAgent.indexOf("AppleWebKit") > -1;
    if (isKHTML) {
        var isChrome = iUserAgent.indexOf("Chrome") > -1;
        var isSafari = iUserAgent.indexOf("AppleWebKit") > -1 && !isChrome;
        var isKonq = iUserAgent.indexOf("Konqueror") > -1;
    }
    var isIE = iUserAgent.indexOf("compatible") > -1 && iUserAgent.indexOf("MSIE") > -1 && !isOpera;
    var isMoz = iUserAgent.indexOf("Gecko") > -1 && !isKHTML;
    var isNS4 = !isOpera && !isMoz && !isKHTML && !isIE && (iUserAgent.indexOf("Mozilla") == 0) && (navigator.appName == "Netscape") && (fAppVersion >= 4.0 && fAppVersion <= 5.0);
    //此处为检测平台
    var isWin = (navigator.platform == "Win32") || (navigator.platform == "Windows");
    var isMac = (navigator.platform == "Mac68K") || (navigator.platform == "MacPPC") || (navigator.platform == "Macintosh");
    var isUnix = (navigator.platform == "X11") && !isWin && !isMac;
    if (isOpera) {
        return "opera";
    } else if (isChrome) {
        return "chrome";
    } else if (isSafari) {
        return "safari";
    } else if (isKonq) {
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

/*!
* jQuery Cookie Plugin v1.3.1
* https://github.com/carhartl/jquery-cookie
*
* Copyright 2013 Klaus Hartl
* Released under the MIT license
*/
(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as anonymous module.
        define(['jquery'], factory);
    } else {
        // Browser globals.
        factory(jQuery);
    }
} (function ($) {

    var pluses = /\+/g;

    function raw(s) {
        return s;
    }

    function decoded(s) {
        return decodeURIComponent(s.replace(pluses, ' '));
    }

    function converted(s) {
        if (s.indexOf('"') === 0) {
            // This is a quoted cookie as according to RFC2068, unescape
            s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
        }
        try {
            return config.json ? JSON.parse(s) : s;
        } catch (er) { }
    }

    var config = $.cookie = function (key, value, options) {

        // write
        if (value !== undefined) {
            options = $.extend({},
            config.defaults, options);

            if (typeof options.expires === 'number') {
                var days = options.expires,
                t = options.expires = new Date();
                t.setDate(t.getDate() + days);
            }

            value = config.json ? JSON.stringify(value) : String(value);

            return (document.cookie = [config.raw ? key : encodeURIComponent(key), '=', config.raw ? value : encodeURIComponent(value), options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
            options.path ? '; path=' + options.path : '', options.domain ? '; domain=' + options.domain : '', options.secure ? '; secure' : ''].join(''));
        }

        // read
        var decode = config.raw ? raw : decoded;
        var cookies = document.cookie.split('; ');
        var result = key ? undefined : {};
        for (var i = 0,
        l = cookies.length; i < l; i++) {
            var parts = cookies[i].split('=');
            var name = decode(parts.shift());
            var cookie = decode(parts.join('='));

            if (key && key === name) {
                result = converted(cookie);
                break;
            }

            if (!key) {
                result[name] = converted(cookie);
            }
        }

        return result;
    };

    config.defaults = {};

    $.removeCookie = function (key, options) {
        if ($.cookie(key) !== undefined) {
            // Must not alter options, thus extending a fresh object...
            $.cookie(key, '', $.extend({},
            options, {
                expires: -1
            }));
            return true;
        }
        return false;
    };
}));
$(window).load(function () {
    $("h2 span a").wrapInner('<i class=yc></i>').prepend("<i class=y1/><i class=y2><b/></i>").append("<i class=y2><b/></i><i class=y1/>");
    $(".k_table_form tbody:first tr td, .k_table_form tbody:first tr th").addClass('noborder');
    $('#bottom').prepend("<em/>");
    $('.k_menu li ul li.hr').prepend("<i/>");
    $('.k_table_form , .k_table_list').before("<i class=\"y1_table yc_top\"/><i class=y2_table><b/></i>").after("<i class=y2_table><b/></i><i class=\"y1_table yc_bottom\"/>");
    //IE6
    if ($.browser.msie && $.browser.version < 7) {
        $("h2 span a").each(function () {
            $(this).width($(this).text().length * 12 + 42);
        });
    }
    set_menu();
    //定位左侧菜单
    function set_menu() {
        var tab_index = jQuery.cookie("current_menu"),
            tab_index_a = jQuery.cookie("current_menu_a"),
            menu_a = $("li.k_menu_i>ul>li>a"),
            main_text = $.trim($("#main_title").text());
        if (tab_index != "") {
            var current_ul = $("li.k_menu_i").eq(tab_index).find("ul");
            current_ul.show();
            var current_li = current_ul.find("li").eq(tab_index_a);
            current_li.addClass("current");
            //单击主区域内容时，定位左侧菜单
            menu_a.each(function () {
                if ($(this).closest("li.k_menu_i").index() != tab_index) {
                    return;
                };
                if ($.trim($(this).text()) == main_text) {
                    current_ul.find("li").eq(tab_index_a).removeClass("current");
                    $(this).parent().addClass("current");
                    $("li.k_menu_i").find("ul").hide();
                    $(this).closest("li.k_menu_i").find("ul").show();

                }
            });
        } else {
            $(".current").removeClass("current");
        }
        //单击，存储当前页面的index进cookie
        menu_a.on("click", function () {
            var index = $(this).closest("li.k_menu_i").index();
            jQuery.cookie("current_menu", index, { path: "/" });
            jQuery.cookie("current_menu_a", $(this).closest("li").index(), { path: "/" });
        });
        //菜单切换
        $("li.k_menu_i>a").on("click", function () {
            $("li.k_menu_i>ul").hide();
            $(this).nextAll("ul").fadeIn(500);
        });
        //返回管理首页时，清除cookie
        $("#back_home").on("click", function () {
            jQuery.cookie("current_menu", "", { path: "/" });
            jQuery.cookie("current_menu_a", "", { path: "/" });
            var href = $(this).attr("href");
            setTimeout(function () {
                location.href = href;
            }, 500);
            return false;
        });
        //隐藏下拉菜单
        $("#k_cmd_Fly").on("mouseleave", function () {
            $(this).fadeOut(300);
        });
    };
    //计算导航的位置
    function setNavPostion() {
        var w = $(window).width();
        var fp_lw = $(".fr").outerWidth(true);
        var fp_rw = $(".fp_left").outerWidth(true);
        var fp_tw = $(".fp_title").outerWidth(true);
        var fp_w = fp_lw + fp_rw + fp_tw;
        if (w < fp_w) {
            $(".fr").addClass("sys_info");
        } else {
            $(".fr").removeClass("sys_info");
        }
    }
    $(window).bind("resize", function () {
        setNavPostion()
    });
    setNavPostion();

    //计算中间部分高度
    function set_container_height() {
        var h = $(window).height() - 51 - 27 - 50;
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
    //全选
    $('a.k_aselect').on("click", function () {
        $("#k_table_list input[name=list]").prop('checked', true)
    }); 
    //反选
    $('a.k_rselect').on("click", function () {
        $("#k_form_list input[name=list]").each(function (i) {
            $(this).prop('checked', !$(this).prop('checked'))
        })
    });
});