<?php

define('KC_INDEX',True);

require_once 'global.php';

function king_def(){
    global $king;

    $tmp=new KC_Template_class($king->config('templatepath').'/default.htm',$king->config('templatepath').'/inside/onepage/sitemap.htm');
    $tmp->assign('title','网站地图');
    echo $tmp->output();
}

?>
