<template>
  <div class="cart">
    <h2>Shopping Cart</h2>
    <div v-if="cart.length === 0">Cart is empty</div>
    <ul v-else>
      <li v-for="item in cart" :key="item.id">
        {{ item.name }} × {{ item.quantity }} — ${{ (item.price * item.quantity).toFixed(2) }}
        <button @click="$emit('remove', item.id)">Remove</button>
      </li>
    </ul>
    <p v-if="cart.length">Total: ${{ total }}</p>

    <button v-if="cart.length && !showForm" @click="showForm = true" class="checkout-btn"> Check Out -> </button>

    <form v-if="showForm" @submit.prevent="submitCheckout" class="checkout-form">
        <h3>CheckOut</h3>
        <input v-model="name" placeholder="name" name="name" />
        <input v-model="email" placeholder="Email" name="email"/>
        <textarea v-model="address" placeholder="Address" name="address" required ></textarea>
        <button class="checkout-btn" type="submit"> Confirm Purchase </button>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  cart: Array,
  total: Number
})

const emit = defineEmits(['remove', 'checkout'])

const showForm = ref(false)
const name = ref('')
const email = ref('')
const address = ref('')

function submitCheckout() {
  const order = {
    customer: { name: name.value, email: email.value, address: address.value },
    items: props.cart,
    total: props.total
  }
  emit('checkout', order)

  name.value = ''
  email.value = ''
  address.value = ''
  showForm.value = false
}
</script>


<style scoped>
.cart {
  margin-top: 2rem;
  border-top: 1px solid #eee;
  padding-top: 1rem;
}

.checkout-btn {
  margin-top: 1rem;
  background-color: #43e192;
  color: white;
  padding: 0.5rem 1rem;
  border: none;
  cursor: pointer;
  border-radius: 5px;
}

.checkout-form {
  margin-top: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.checkout-form input,
.checkout-form textarea {
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 5px;
}

ul {
    display: flex;
    flex-direction: column;
}
li {
  margin-bottom: 0.5rem;
}
button {
  margin-left: 1rem;
  background: red;
  color: white;
  border: none;
  padding: 0.2rem 0.5rem;
  cursor: pointer;
}
</style>
