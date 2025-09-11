<template>
  <div>
    <nav>
      <ul>
        <li>
          <router-link to="/counter">Counter</router-link>
        </li>
        <li>
          <router-link to="/todos">Todo List</router-link>
        </li>
        <li>
          <router-link to="/calculator">Calculator</router-link>
        </li>
        <li>
          <router-link to="/shop">Shop</router-link>
        </li>
      </ul>
    </nav>

    <router-view />
  </div>
</template>

<style>
* {
  color: #43e192;
}

a {
  text-decoration: none;
  color:#ebf1ee;
}
a:hover {
  color: grey;
}

nav {
  position: absolute;
  background: #080808;
  top: 0;
  right: 0;
  width: 100%;  
}
ul {
  display: flex;
  justify-content: center;
  padding: 20px;
  gap: 100px;
}
ul li {
  list-style: none;
}
router-link {
  text-decoration: none;
  font-weight: bold;
  color: #ebf1ee;
}

.router-link-active {
  font-weight: bold;
  color: #43e192;
}
</style>
