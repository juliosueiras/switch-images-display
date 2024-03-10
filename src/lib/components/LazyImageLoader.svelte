<script>
  export let src;
  export let alt;
  export let style;
  
  import IntersectionObserver from './IntersectionObserver.svelte'
  import LazyImage from './LazyImage.svelte'

  let nativeLoading = false  
</script>

<IntersectionObserver once={true} let:intersecting={intersecting}>
  {#if intersecting || nativeLoading}
    <LazyImage {alt} {src} {style} on:click />
  {/if}
</IntersectionObserver> 