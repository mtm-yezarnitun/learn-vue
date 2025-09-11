<template>
  <div class="container">
    <h1>Vue Counter</h1>
    <Counter />
  </div>
</template>


<script setup>
import Counter from '../components/Counter.vue'
</script>

<style>
.container {
  text-align: center;
  padding-top: 50px;
}
button {
  margin: 5px;
  padding: 10px 20px;
  font-size: 16px;
}
</style>
