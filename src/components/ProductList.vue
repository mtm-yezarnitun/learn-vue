<template>
  <div class="products">
    <div v-for="product in products" :key="product.id" class="product-card">
      <h3>{{ product.name }}</h3>
      <p>${{ product.price }}</p>
      <button @click="$emit('add-to-cart', product)">Add to Cart</button>
    </div>
  </div>
</template>

<script setup>
const products = [
  { id: 1, name: 'T-shirt', price: 19.99 },
  { id: 2, name: 'Hat', price: 9.99 },
  { id: 3, name: 'Shoes', price: 49.99 }
]
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
