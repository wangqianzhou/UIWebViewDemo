<template>
  <div class="browserStyle">
    <div style="flex-direction: row">
      <text class="textStyle" :value='page_title'>
      </text>
    </div>
    <div style="flex-direction: row">
      <text class="textStyle" :value='page_url'>
      </text>
    </div>
    <div style="flex-direction: row">
      <text class="textStyle" :value='page_keyword'>
      </text>
    </div>        
    <div style="flex-direction: row">
      <div value="网页信息" name='hello' class="buttonSytle" size="small" @click="get_page_info"></div>
      <div value="加载网页" class="buttonSytle" size="small" @click="load_url"></div>
      <div value="刷新" class="buttonSytle" size="small" @click="change_background"></div>
    </div>
  </div>
</template>

<style>

  .browserStyle
  {
    flex:1;
    background-color:#778899 ;
  }

  .textStyle
  {
    flex:1;
    height: 50;
    background-color: #D3D3D3;
  }

  .buttonSytle
  {
    width:180;
    height: 50;
    font-size: 12;
    background-color: #D3D3D3;
    margin:10;
    padding-left: 5;
    padding-right: 5;
  }


</style>

<script>
  var bridge = weex.requireModule('custom_bridge_module'); 

  module.exports = 
  {
    data: 
    {
      page_title : 'untitle',
      page_url : 'about:blank',
      page_modified : 'unknown'
    },

    methods: 
    {

      get_page_info: function (e) 
      {
         var self = this;

          bridge.runJavascriptInHost('document.title',function(param) 
          {
             self.page_title =  param; 
          });
          bridge.runJavascriptInHost('window.location.href',function(param) 
          {
             self.page_url =  param; 
          });
          bridge.runJavascriptInHost('document.lastModified',function(param) 
          {
             self.page_modified =  param; 
          });
      },

      load_url: function (e) 
      {
        bridge.loadURL('https://m.baidu.com')
      },

      change_background: function (e) {
          bridge.runJavascriptInHost("document.body.background-color='red'",function(param) 
          {

          });
       }

    }
  }
</script>