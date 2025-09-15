<template>
  <div class="products">
    <div v-for="product in products" :key="product.id" class="product-card">
      <h3>{{ product.name }}</h3>
      <p>${{ product.price }}</p>

      <RatingStars :model-value="product.rating" />

      <button @click="$emit('add-to-cart', product)">Add to Cart</button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import RatingStars from './RatingStars.vue'

const stored = localStorage.getItem('products')
const products = ref(
  stored ? JSON.parse(stored) : [
    { id: 1, name: 'T-shirt', price: 19.99, rating: 0 },
    { id: 2, name: 'Hat', price: 9.99, rating: 0 },
    { id: 3, name: 'Shoes', price: 49.99, rating: 0 }
  ]
)
</script>

<style scoped>
.products {
  display: flex;
  gap: 1rem;
  width: 100% !important;
}
.product-card {
  border: 1px solid #ffffff;
  padding: 20px;
  width: 200px !important;
  text-align: center;
}
button {
  margin-top: 0.5rem;
}
</style>
