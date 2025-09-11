<template>
  <div class="container">
    <h1>Calculator</h1>
    <Calc />
  </div>
</template>

<script setup>
import Calc from '../components/Calc.vue'
</script>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem;
}
</style>
