<template>
  <div v-if="announcements.length" class="announcement-ticker">
    <div class="scroll-text">
      <span v-for="a in announcements" :key="a.id" class="ticker-msg">
        🔔 {{ a.title }} — {{ a.message }} &nbsp;&nbsp;&nbsp;
      </span>
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from "vue";
import { useStore } from "vuex";

const store = useStore();
const announcements = computed(() => store.getters["announcements/allAnnouncements"]);

onMounted(() => {
  store.dispatch("announcements/fetchActiveAnnouncements");
  setInterval(() => store.dispatch("announcements/fetchActiveAnnouncements"), 60000);
});
</script>

<style scoped>
.announcement-ticker {
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
  overflow: hidden;
  white-space: nowrap;
  background: #222;
  color: #fff;
  padding: 8px 0;
  font-size: 16px;
  font-weight: 500;
  z-index: 9999;
  border-top: 2px solid #444;
}

.scroll-text {
  display: inline-block;
  padding-left: 100%;
  animation: scroll-left 20s linear infinite;
}

@keyframes scroll-left {
  0% {
    transform: translateX(0%);
  }
  100% {
    transform: translateX(-100%);
  }
}

.ticker-msg {
  margin-right: 40px;
}
</style>
