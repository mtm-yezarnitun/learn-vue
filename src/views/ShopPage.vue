<template>
    <h1>Shop</h1>
  <div class="shop-container">
    <div class="products">
        <ProductList @add-to-cart="addToCart" />
    </div>
    <div class="side-cart">
        <ShoppingCart :cart="cart" @remove="removeFromCart" @checkout="handleCheckout" />
    </div>
  </div>
</template>

<script setup>
import { ref , watch , onMounted } from 'vue'
import ProductList from '../components/ProductList.vue'
import ShoppingCart from '../components/ShoppingCart.vue'

const cart = ref([])

watch(cart , (newCart) => {
    localStorage.setItem('cart', JSON.stringify(newCart))
}, { deep: true });

onMounted(() => {
  const saved = localStorage.getItem('cart')
  if (saved) {
    cart.value = JSON.parse(saved)
  }
})
function handleCheckout(order) {
  console.log("New order:", order)
  alert(`Thanks ${order.customer.name}, your order total is $${order.total}`)
  cart.value = [] 
}

function addToCart(product) {
  const item = cart.value.find(p => p.id === product.id)
  if (item) {
    item.quantity += 1
  } else {
    cart.value.push({ ...product, quantity: 1 })
  }
}

function removeFromCart(productId) {
  cart.value = cart.value.filter(item => item.id !== productId)
}
</script>

<style scoped>

.shop-container {
  display: flex;
  flex-direction: row;
  gap: 20px;
}

.products {
    width: 70%;
}
.side-cart {
    width: 30%;
}

</style>
