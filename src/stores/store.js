import { createStore } from 'vuex';
import todo from './modules/todo'
import weather from './modules/weather'

const store = createStore({
  modules: {
    todo,
    weather
    },

});

export default store;
