<script>
  import {
    Image,
  } from "@smui/image-list/styled";

  export let src;
  export let alt;
  export let style;

</script>

<style>
  img {
    height: 200px;
    opacity: 0;
    transition: opacity 1200ms ease-out;
  }
  img.loaded {
    opacity: 1;
  }
</style>

<Image {src} {alt} {style} loading="lazy" on:click />