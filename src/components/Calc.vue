<template>
  <div class="calculator">
    <div class="display">{{ current || '0' }}</div>
    <div class="buttons">
      <button
        v-for="btn in buttons"
        :key="btn"
        @click="handleClick(btn)"
      >
        {{ btn }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { evaluate } from 'mathjs'

const current = ref('')

const buttons = [
  '1', '2', '3', '4', '5', '6', '7', '8', '9',
  '-', '0', '+', '*', '.', '/', 'C', '=', '<<'
]

function handleClick(btn) {
  if (btn === 'C') {
    current.value = ''
  } else if (btn === '=') {
    try {
      current.value = evaluate(current.value).toString()
    } catch {
      current.value = 'Error'
    }
  } else if (btn === '<<') {
    if (current.value === 'Error') {
      current.value = ''
    } else {
      current.value = current.value.slice(0, -1)
    }
  } else {
    if (current.value === 'Error') current.value = ''
    current.value += btn
  }
}
</script>

<style scoped>
.calculator {
  max-width: 300px;
  margin: auto;
}

.display {
  padding: 15px;
  font-size: 24px;
  border-radius: 20px;
  background: black;
  text-align: right;
  margin-bottom: 10px;
  min-height: 40px;
}

.buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

button {
  width: 80px;
  padding: 10px;
  font-size: 18px;
  background: #444;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

button:hover {
  background: #666;
}
</style>
