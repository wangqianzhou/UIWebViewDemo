<template>
  <div class="wrapper" @click="fetch_web_info">
    <image :src="logoUrl" class="logo"></image>
    <text class="title">{{title}}</text>
  </div>
</template>

<style>
  .wrapper { align-items: center;   display: inline; }
  .title { font-size: 20px; }
  .logo { width: 50%; height: 100%; }
</style>

<script>
  export default 
  {
    data: 
    {
      logoUrl: 'https://alibaba.github.io/weex/img/weex_logo_blue@3x.png',
      title: 'Hello World'
    },

    methods: 
    {
      fetch_web_info : function(param)
      {
          var self = this;
          var bridge = weex.requireModule('custom_bridge_module'); 
          bridge.runJavascriptInHost('window.location.href',function(param) 
          {
             self.title =  param; 
          });
      },

      open_url : function(param)
      {
           var bridge = weex.requireModule('custom_bridge_module');
           bridge.openURL('https//m.baidu.com',function(ret) {
           });
      }
    }
  }
</script>
