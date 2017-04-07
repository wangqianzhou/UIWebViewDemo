<template>
    <div>
      <web id="webview" :src="src" class="webStyle"></web>
    </div>
</template>

<style>
  .webStyle
  {
    flex:1;
    height: 700;
    background-color: #8B0000;
  }

</style>

<script>

  var web_module = weex.requireModule('@weex-module/webview');

  module.exports = {
    data: {
      src : "https://h5.m.taobao.com",
    },

    methods: {
      onappear (event) {
      }
    }
  }
</script>