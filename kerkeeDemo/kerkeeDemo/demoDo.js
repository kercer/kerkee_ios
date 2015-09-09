/**
 * Created by jianhuang on 2015/3/28.
 */
define([
        'bridgeLib',
        'zepto',
        'api/device/platform',
        'api/nativeUI/widget',
        'helper/util',
        //自匹配无串参项
        'domReady!'
    ],

    function (bridgeLib, $, Platform, Widget, util) {

        function ChannelDo(){
            this.channelMainBox=$("#channelMainBox");
            this.traceBox=$("#traceBox");
            this.jsbc=jsBridgeClient;
        }

        ChannelDo.prototype.render=function(msg){
            this.channelMainBox.show();
            this.traceBox.html('util: '+msg+"<br/>");
        };

        ChannelDo.prototype._callNative=function(clz,method,data,callBack){
            this.jsbc.invoke(clz,method,data,callBack);
        };

        ChannelDo.prototype.bindEvent=function(){
            var t=this;

            $("#getNetWrok").on("click", function () {
                Platform.getNetworkType(function (data) {
                    t.traceBox.html(JSON.stringify(data));
                });
            });

            $("#getDevice").on("click", function () {
                Platform.getDevice(function (data) {
                    Widget.alertDialog("提示", JSON.stringify(data), function (clickId) {
                        if (clickId == "1") {
                            t.traceBox.html("callback with ok");
                        }
                    });
                });
            });

            $("#toast").on("click", function () {
                Widget.toast("jian");
            });

            $("#showDialog").on("click", function () {
                Widget.showDialog("提示", "内容", function (data) {
                    if (data == "1") {
                        t.traceBox.html("callback with ok");
                    } else {
                        t.traceBox.html("callback with cancel");
                    }
                });
            });

            $("#loadLocal").on("tap",function(){
                t.traceBox.empty();

                var res=util.compileTempl("listView",{
                    title: '数据遍历',
                    isAdmin: true,
                    list: ['新闻内容一', '新闻内容二', '新闻内容三']
                });

                Widget.alertDialog("提示", "加载本地模板", function (clickId) {
                    if (clickId == "1") {
                        t.traceBox.html(res);
                    }
                });
            });

            $("#loadServer").on("tap",function(){
                $.ajax({
                    type:"get",
                    url:"http://jenking.sinaapp.com/index.php/Home/Index/data",
                    data:{
                        name:"jian",
                        age:28
                    },
                    beforeSend:function(){
                        t.traceBox.html("loading data");
                    },
                    success:function(data){
                        t.traceBox.html(JSON.stringify(data));
                    },
                    error:function(xhr, textStatus, errorThrown){
                        t.traceBox.empty();
                        t.traceBox.append("<section>"+xhr.status+"</section>");
                        t.traceBox.append("<section>"+xhr.readyState+"</section>");
                        t.traceBox.append("<section>"+textStatus+"</section>");
                    }
                });
            });
        };

        ChannelDo.prototype.init=function(initTips){
            var t=this;
            this.jsbc.onDeviceReady(function () {
                t.render(initTips);
                t.bindEvent();
            });
        };

        return new ChannelDo();
    });