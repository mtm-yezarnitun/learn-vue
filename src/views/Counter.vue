<template>
  <div class="container">
    <h1>Vue Counter</h1>
    <h2>{{ count }}</h2>
    <button @click="increase">+ Add</button>
    <button @click="reset"> * Reset * </button>
    <button @click="decrease">- Subtract</button>
    <input type="number" v-model.number="incrementAdd"></input>
    <button @click="addIncrement"> Add to increase </button>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const count = ref(0)
const incrementAdd = ref(1)

function increase() {
  count.value++
}

function decrease() {
  if (count.value > 0) {
    count.value--
  }
}
function reset() {
  count.value = 0
}

function addIncrement() {
  count.value += incrementAdd.value
}

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
