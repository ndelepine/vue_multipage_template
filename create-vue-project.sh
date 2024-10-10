#!/bin/bash

# Nom du projet
PROJECT_NAME=$1

# Créer le projet avec Vite
npm create vite@latest $PROJECT_NAME -- --template vue-ts

# Naviguer dans le dossier du projet
cd $PROJECT_NAME

# Installer les dépendances supplémentaires
npm install vue-router@4 pinia vuetify@next @mdi/font

# Créer les dossiers nécessaires
mkdir -p src/{components,plugins,router,store,views}

# Créer le fichier main.ts
cat <<EOL > src/main.ts
import { createApp } from 'vue';
import App from './App.vue';
import { createPinia } from 'pinia';
import router from './router';
import vuetify from './plugins/vuetify'
import 'vuetify/styles'  // Vuetify styles

const app = createApp(App);

// Initialiser Pinia et l'attacher à l'application
const pinia = createPinia();
app.use(pinia);
app.use(router);
app.use(vuetify);

app.mount('#app');
EOL

# Créer le fichier plugins/vuetify.ts
cat <<EOL > src/plugins/vuetify.ts
import 'vuetify/styles';
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases, mdi } from 'vuetify/iconsets/mdi'  // Import des icônes Material Design
import '@mdi/font/css/materialdesignicons.css'  // Styles pour les icônes MDI

const vuetify = createVuetify({
  components,
  directives,
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    },
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        dark: false,
        colors: {
          primary: '#1976D2',
        },
      },
      dark: {
        dark: true,
        colors: {
          primary: '#2196F3',
        },
      },
    },
  },
});

export default vuetify
EOL

# Créer le fichier router/index.ts
cat <<EOL > src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router';
import Workflow from '../views/Workflow.vue';
import Table from '../views/Table.vue';
import Owners from '../views/Owners.vue';

const routes = [
  { path: '/', redirect: '/workflow' },
  { path: '/workflow', component: Workflow },
  { path: '/table', component: Table },
  { path: '/owners', component: Owners },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
EOL

# Créer le fichier store/index.ts
cat <<EOL > src/store/index.ts
import { defineStore } from 'pinia';

export const useStore = defineStore('main', {
  state: () => ({
    lastDataUpdate: new Date(),
    upwardDepth: 1,
    downwardDepth: 1,
    darkTheme: false,
  }),
  actions: {
    setUpwardDepth(value: number) {
      this.upwardDepth = value;
    },
    setDownwardDepth(value: number) {
      this.downwardDepth = value;
    },
    updateLastDataUpdate(date: Date) {
      this.lastDataUpdate = date;
    },
    toggleTheme() {
      this.darkTheme = !this.darkTheme;
    },
  },
});
EOL

# Créer le composant HeaderBar.vue
cat <<EOL > src/components/HeaderBar.vue
<template>
  <v-app-bar app>
    <v-toolbar-title>My Application</v-toolbar-title>
    <v-spacer></v-spacer>
    <v-btn to="/workflow">Workflow</v-btn>
    <v-btn to="/table">Table</v-btn>
    <v-btn to="/owners">Owners</v-btn>
  </v-app-bar>
</template>

<script setup lang="ts">
// No additional logic needed for this component yet
</script>
EOL

# Créer le composant RightDrawer.vue
cat <<EOL > src/components/RightDrawer.vue
<template>
  <v-navigation-drawer v-model="drawer" temporary left app :width="400">
    <v-list>
      <v-list-item>
        <v-list-item-title>Last Data Update: {{ lastDataUpdate.toLocaleString() }}</v-list-item-title>
      </v-list-item>
      <v-list-item>
        <div class="text-caption">Upward depth in graph</div>
        <div class="slider-container">
          <v-slider
            v-model="upwardDepth"
            :min="1"
            :max="3"
            :step="1"
            show-ticks="always"
            tick-size="4"
            max-width="300px"
            class="slider"
            thumb-label
          ></v-slider>
        </div>
      </v-list-item>
      <v-list-item>
        <div class="text-caption">Downward depth in graph</div>
        <div class="slider-container">
          <v-slider
            v-model="downwardDepth"
            :min="1"
            :max="5"
            :step="1"
            show-ticks="always"
            tick-size="4"
            max-width="300px"
            thumb-label
          ></v-slider>
        </div>
      </v-list-item>
      <v-list-item>
        Changer de thème :
        <v-btn
          @click="toggleTheme"
          :style="themeButtonStyle"
          icon
        >
          <v-icon>{{ themeIcon }}</v-icon>
        </v-btn>
      </v-list-item>
    </v-list>
  </v-navigation-drawer>
  <v-btn
    @click="drawer = !drawer"
    fab
    absolute
    bottom
    left
    color="grey-lighten-1"
    class="drawer-toggle-btn"
    icon="mdi-wrench"
  >
  </v-btn>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useStore } from '../store';

// Récupération du store après que Pinia a été initialisé
const store = useStore();
const drawer = ref(false);

const lastDataUpdate = computed(() => store.lastDataUpdate);
const upwardDepth = computed({
  get: () => store.upwardDepth,
  set: (value: number) => store.setUpwardDepth(value),
});

const downwardDepth = computed({
  get: () => store.downwardDepth,
  set: (value: number) => store.setDownwardDepth(value),
});

// Gestion du thème
const isDark = computed(() => store.darkTheme);
const toggleTheme = () => {
  store.toggleTheme();
};

// Style dynamique pour le bouton selon le thème
const themeButtonStyle = computed(() => ({
  backgroundColor: !isDark.value ? '#000000' : '#ffffff', // Noir si sombre, blanc si clair
  color: !isDark.value ? '#ffffff' : '#000000',           // Texte blanc si sombre, noir si clair
  border: '1px solid',
  borderColor: !isDark.value ? '#ffffff' : '#000000',     // Bordure de couleur opposée pour contraste
}));

// Choisir l'icône à afficher en fonction du thème
const themeIcon = computed(() => (isDark.value ? 'mdi-weather-sunny' : 'mdi-moon-waxing-crescent'));


</script>

<style scoped>
.drawer-toggle-btn {
  position: fixed; /* Position fixe pour le bouton flottant */
  bottom: 16px;    /* Distance par rapport au bas de l'écran */
  left: 16px;      /* Distance par rapport au côté gauche de l'écran */
  z-index: 2000;   /* Pour s'assurer que le bouton est au-dessus des autres éléments */
}

/* Style pour le bouton quand le mode clair est activé */
.btn-light-theme {
  background-color: black;
  color: white;
}

/* Style pour le bouton quand le mode sombre est activé */
.btn-dark-theme {
  background-color: white;
  color: black;
}

.text-caption {
  margin-bottom: 15px;
}

.slider-container {
  display: flex;
  justify-content: center;
}

</style>
EOL

# Créer le fichier App.vue
cat <<EOL > src/App.vue
<template>
  <v-app :theme="isDark ? 'dark' : 'light'">
    <HeaderBar />
    <RightDrawer />
    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useStore } from './store';
import HeaderBar from './components/HeaderBar.vue';
import RightDrawer from './components/RightDrawer.vue';

// Access the store after Pinia is initialized
const store = useStore();
const isDark = computed(() => store.darkTheme);

</script>

<style scoped>
/* Add any global styles if needed */
</style>
EOL

# Créer les vues Workflow.vue, Table.vue et Owners.vue
for view in Workflow Table Owners
do
cat <<EOL > src/views/$view.vue
<template>
  <v-container fluid>
    <h1>$view Page</h1>
  </v-container>
</template>

<script setup lang="ts">
// You can add any Composition API logic here as needed
</script>
EOL
done

# Installer les dépendances et lancer le projet
cd $PROJECT_NAME
npm install
npm run dev
