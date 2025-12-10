# AngryRaphi PWA - Copilot Entwicklungsanleitung

---

## 🔥 FLUTTER PWA IMPLEMENTATION STATUS - COMPLETED! ✅

### Current Flutter PWA Setup (January 2025)

**✅ PWA Configuration Complete!** Your AngryRaphi Flutter app is now fully configured as a Progressive Web App.

#### 📱 **Implemented PWA Features:**
- **App Name**: "AngryRaphi - Rate People with Raphcons" 
- **Theme Colors**: `#FF4500` (flames), `#8B0000` (dark red)
- **Standalone Display**: Full-screen native app experience
- **Service Worker**: `web/pwa.js` with offline support & install prompts
- **PWA Manifest**: `web/manifest.json` with proper icon configuration
- **Enhanced HTML**: `web/index.html` with all PWA meta tags

#### 🚀 **Ready for Deployment:**
1. **Icons**: Place AngryRaphi logo in `/web/icons/` (192x192, 512x512, maskable versions)
2. **Build**: `flutter build web --release`
3. **Deploy**: Upload to your web server

**Users can now install AngryRaphi from their browser like a native app!** 📱🔥

---

## Projektübersicht
Eine Progressive Web App (PWA) zur Verwaltung von "Raphcons" - einem Bewertungssystem für Personen. Die App verwendet Firebase Firestore als Backend mit rollenbasierter Zugriffskontrolle und wird über Firebase Hosting bereitgestellt.

## Technologie-Stack
- **Frontend**: HTML5, CSS3, Vanilla JavaScript (oder Vue.js)
- **Backend**: Firebase Firestore
- **Authentifizierung**: Firebase Auth
- **Storage**: Firebase Storage (für Bilder)
- **Hosting**: Firebase Hosting
- **PWA**: Service Worker, Web App Manifest

## Projektstruktur

```
angry-raphi-pwa/
├── public/
│   ├── index.html
│   ├── manifest.json
│   ├── sw.js (Service Worker)
│   ├── css/
│   │   └── styles.css
│   ├── js/
│   │   ├── app.js
│   │   ├── firebase-config.js
│   │   ├── auth.js
│   │   ├── localization.js
│   │   └── components/
│   │       ├── user-list.js
│   │       ├── user-card.js
│   │       └── admin-panel.js
│   ├── animations/
│   │   ├── angry-face.json
│   │   ├── loading-spinner.json
│   │   ├── success-checkmark.json
│   │   └── user-avatar.json
│   ├── locales/
│   │   ├── de-ch.json
│   │   └── de-de.json
│   ├── images/
│   │   └── icons/
│   └── offline.html
├── firebase.json
├── .firebaserc
└── package.json
```

## Firebase Setup

### 1. Firebase Initialisierung
```bash
npm install -g firebase-tools
firebase login
firebase init
```

### 2. firebase.json Konfiguration
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

### 3. Firestore Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users - Lesen für alle, Schreiben nur für Admins
    match /users/{userId} {
      allow read: if true;
      allow write: if isAdmin(request.auth.uid);
    }
    
    // Raphcons - Lesen für alle, Schreiben nur für Admins
    match /raphcons/{raphconId} {
      allow read: if true;
      allow write: if isAdmin(request.auth.uid);
    }
    
    // Admins - Nur Admins können lesen/schreiben
    match /admins/{adminId} {
      allow read, write: if isAdmin(request.auth.uid);
    }
    
    // Helper function
    function isAdmin(userId) {
      return exists(/databases/$(database)/documents/admins/$(userId));
    }
  }
}
```

### 4. Firebase Storage Security Rules
```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // User profile images - Admins können hochladen, alle können lesen
    match /users/{imageId} {
      allow read: if true;
      allow write: if isAdmin() && isValidImage();
    }
    
    // Raphcon images - Admins können hochladen, alle können lesen
    match /raphcons/{imageId} {
      allow read: if true;
      allow write: if isAdmin() && isValidImage();
    }
    
    // Helper functions
    function isAdmin() {
      return request.auth != null && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    function isValidImage() {
      return request.resource.contentType.matches('image/.*') &&
             request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
  }
}
```

## PWA Implementation

### 1. HTML Structure (index.html)
```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AngryRaphi</title>
    <link rel="manifest" href="manifest.json">
    <meta name="theme-color" content="#8B0000">
    <link rel="stylesheet" href="css/styles.css">
    
    <!-- PWA Meta Tags -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <meta name="apple-mobile-web-app-title" content="AngryRaphi">
    
    <!-- Icons -->
    <link rel="apple-touch-icon" href="assets/angry-raphi-icon.png">
</head>
<body>
    <div id="app">
        <!-- Header -->
        <header class="app-header">
            <div class="header-left">
                <lottie-player 
                    id="angry-logo" 
                    src="animations/angry-face.json" 
                    background="transparent" 
                    speed="1" 
                    style="width: 40px; height: 40px;" 
                    loop 
                    autoplay>
                </lottie-player>
                <h1 data-i18n="app.title">AngryRaphi</h1>
            </div>
            <div class="header-actions">
                <button id="google-signin-btn" class="btn-secondary" style="display: none;" data-i18n="auth.signInGoogle">Mit Google anmelden</button>
                <div id="user-info" style="display: none;">
                    <img id="user-avatar" class="user-avatar-small" src="" alt="">
                    <span id="user-name"></span>
                    <button id="logout-btn" class="btn-secondary" data-i18n="auth.logout">Logout</button>
                </div>
                <button id="admin-panel-btn" class="btn-primary" style="display: none;" data-i18n="admin.panel">Admin</button>
                <select id="language-selector" class="language-selector">
                    <option value="de-de">Deutsch (DE)</option>
                    <option value="de-ch">Deutsch (CH)</option>
                </select>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <div id="loading" class="loading">
                <lottie-player 
                    src="animations/loading-spinner.json" 
                    background="transparent" 
                    speed="1" 
                    style="width: 100px; height: 100px;" 
                    loop 
                    autoplay>
                </lottie-player>
                <p data-i18n="common.loading">Laden...</p>
            </div>
            <div id="user-list" class="user-list"></div>
        </main>

        <!-- Admin Panel Modal -->
        <div id="admin-modal" class="modal">
            <div class="modal-content">
                <span class="close">&times;</span>
                <h2>Admin Panel</h2>
                <div id="admin-content"></div>
            </div>
        </div>
    </div>

    <!-- Firebase Scripts -->
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-storage-compat.js"></script>
    
    <!-- Google Identity Services -->
    <script src="https://accounts.google.com/gsi/client" async defer></script>
    
    <!-- Lottie Animation Library -->
    <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>
    
    <!-- App Scripts -->
    <script src="js/localization.js"></script>
    <script src="js/firebase-config.js"></script>
    <script src="js/auth.js"></script>
    <script src="js/components/user-card.js"></script>
    <script src="js/components/user-list.js"></script>
    <script src="js/components/admin-panel.js"></script>
    <script src="js/app.js"></script>
</body>
</html>
```

### 2. Web App Manifest (manifest.json)
```json
{
  "name": "AngryRaphi",
  "short_name": "AngryRaphi",
  "description": "Raphcon Bewertungssystem",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#8B0000",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "96x96",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "128x128",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "152x152",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "384x384",
      "type": "image/png"
    },
    {
      "src": "assets/angry-raphi-icon.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 3. Service Worker (sw.js)
```javascript
const CACHE_NAME = 'angry-raphi-v1';
const urlsToCache = [
  '/',
  '/css/styles.css',
  '/js/app.js',
  '/js/firebase-config.js',
  '/js/auth.js',
  '/offline.html',
  '/assets/angry-raphi-icon.png'
];

// Install Event
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

// Fetch Event
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        if (response) {
          return response;
        }
        return fetch(event.request).catch(() => {
          if (event.request.destination === 'document') {
            return caches.match('/offline.html');
          }
        });
      })
  );
});
```

## JavaScript Implementation

### 1. Firebase Konfiguration (js/firebase-config.js)
```javascript
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};

firebase.initializeApp(firebaseConfig);

const db = firebase.firestore();
const auth = firebase.auth();
const storage = firebase.storage();

const usersCollection = db.collection('users');
const raphconsCollection = db.collection('raphcons');
const adminsCollection = db.collection('admins');

// Localization setup
let currentLocale = localStorage.getItem('locale') || 'de-ch';
let translations = {};

// Load translations
async function loadTranslations(locale) {
  try {
    const response = await fetch(`locales/${locale}.json`);
    translations = await response.json();
    updateUI();
  } catch (error) {
    console.error('Failed to load translations:', error);
  }
}

function t(key) {
  const keys = key.split('.');
  let value = translations;
  for (const k of keys) {
    value = value?.[k];
  }
  return value || key;
}

function updateUI() {
  document.querySelectorAll('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    element.textContent = t(key);
  });
}

// Initialize translations
loadTranslations(currentLocale);
```

### 2. Authentifizierung (js/auth.js)
```javascript
class AuthManager {
  constructor() {
    this.currentUser = null;
    this.isAdmin = false;
    this.provider = new firebase.auth.GoogleAuthProvider();
    this.init();
  }

  init() {
    auth.onAuthStateChanged(async (user) => {
      this.currentUser = user;
      if (user) {
        this.isAdmin = await this.checkAdminStatus(user.uid);
        this.updateUI();
      } else {
        this.isAdmin = false;
        this.updateUI();
      }
    });
  }

  async checkAdminStatus(userId) {
    try {
      const adminDoc = await adminsCollection.doc(userId).get();
      return adminDoc.exists;
    } catch (error) {
      console.error('Admin check failed:', error);
      return false;
    }
  }

  async signInWithGoogle() {
    try {
      // Show loading animation
      this.showSignInLoading(true);
      const result = await auth.signInWithPopup(this.provider);
      console.log('User signed in:', result.user.displayName);
      
      // Show success animation
      this.showSuccessAnimation();
    } catch (error) {
      console.error('Google sign-in failed:', error);
      alert(t('auth.signInFailed') + ': ' + error.message);
    } finally {
      this.showSignInLoading(false);
    }
  }

  showSignInLoading(show) {
    const btn = document.getElementById('google-signin-btn');
    if (show) {
      btn.innerHTML = `
        <lottie-player 
          src="animations/loading-spinner.json" 
          background="transparent" 
          speed="1" 
          style="width: 20px; height: 20px; display: inline-block;" 
          loop 
          autoplay>
        </lottie-player>
        ${t('auth.signingIn')}
      `;
      btn.disabled = true;
    } else {
      btn.textContent = t('auth.signInGoogle');
      btn.disabled = false;
    }
  }

  showSuccessAnimation() {
    const successDiv = document.createElement('div');
    successDiv.className = 'success-animation';
    successDiv.innerHTML = `
      <lottie-player 
        src="animations/success-checkmark.json" 
        background="transparent" 
        speed="1" 
        style="width: 50px; height: 50px;" 
        autoplay>
      </lottie-player>
    `;
    document.body.appendChild(successDiv);
    
    setTimeout(() => {
      successDiv.remove();
    }, 2000);
  }

  async signOut() {
    try {
      await auth.signOut();
    } catch (error) {
      console.error('Sign-out failed:', error);
    }
  }

  updateUI() {
    const googleSignInBtn = document.getElementById('google-signin-btn');
    const userInfo = document.getElementById('user-info');
    const userAvatar = document.getElementById('user-avatar');
    const userName = document.getElementById('user-name');
    const logoutBtn = document.getElementById('logout-btn');
    const adminBtn = document.getElementById('admin-panel-btn');

    if (this.currentUser) {
      // Hide Google sign-in button
      googleSignInBtn.style.display = 'none';
      
      // Show user info
      userInfo.style.display = 'flex';
      userAvatar.src = this.currentUser.photoURL || '';
      userName.textContent = this.currentUser.displayName || this.currentUser.email;
      
      // Setup logout
      logoutBtn.onclick = () => this.signOut();
      
      // Show admin panel if user is admin
      if (this.isAdmin) {
        adminBtn.style.display = 'block';
      } else {
        adminBtn.style.display = 'none';
      }
    } else {
      // Show Google sign-in button
      googleSignInBtn.style.display = 'block';
      googleSignInBtn.onclick = () => this.signInWithGoogle();
      
      // Hide user info and admin panel
      userInfo.style.display = 'none';
      adminBtn.style.display = 'none';
    }
  }
}
```

### 3. User Card Component (js/components/user-card.js)
```javascript
class UserCard {
  constructor(user) {
    this.user = user;
    this.raphconCount = 0;
    this.raphconListener = null;
    this.setupRaphconStream();
  }

  setupRaphconStream() {
    // Listen to real-time changes in raphcons for this user
    this.raphconListener = raphconsCollection
      .where('userId', '==', this.user.id)
      .onSnapshot((snapshot) => {
        this.raphconCount = snapshot.size;
        this.updateCountDisplay();
      }, (error) => {
        console.error('Failed to load raphcon count:', error);
      });
  }

  destroy() {
    // Clean up listener when card is removed
    if (this.raphconListener) {
      this.raphconListener();
    }
  }

  render() {
    const card = document.createElement('div');
    card.className = 'user-card';
    card.innerHTML = `
      <div class="user-avatar">
        ${this.user.profileImage ? 
          `<img src="${this.user.profileImage}" alt="${this.user.name}">` :
          `<lottie-player 
             src="animations/user-avatar.json" 
             background="transparent" 
             speed="1" 
             style="width: 50px; height: 50px;" 
             loop 
             autoplay>
           </lottie-player>`
        }
      </div>
      <div class="user-info">
        <h3>${this.user.name}</h3>
        <p class="raphcon-count">${this.raphconCount} ${t('user.raphcons')}</p>
      </div>
      <div class="user-actions">
        ${authManager?.isAdmin ? 
          `<button class="add-raphcon-btn" onclick="showAddRaphconDialog('${this.user.id}')" title="${t('raphcon.add')}">
             <lottie-player 
               src="animations/angry-face.json" 
               background="transparent" 
               speed="1" 
               style="width: 20px; height: 20px;" 
               loop 
               autoplay>
             </lottie-player>
           </button>` :
          ''
        }
      </div>
    `;

    card.addEventListener('click', () => {
      this.showUserDetails();
    });

    return card;
  }

  updateCountDisplay() {
    const countElement = document.querySelector(`[data-user-id="${this.user.id}"] .raphcon-count`);
    if (countElement) {
      countElement.textContent = `${this.raphconCount} Raphcons`;
    }
  }

  showUserDetails() {
    window.location.hash = `#user/${this.user.id}`;
  }
}
```

### 4. User List Component (js/components/user-list.js)
```javascript
class UserList {
  constructor() {
    this.users = [];
    this.userCards = new Map(); // Track user cards for cleanup
    this.container = document.getElementById('user-list');
    this.usersListener = null;
    this.loadUsers();
  }

  loadUsers() {
    // Listen to real-time changes in users collection
    this.usersListener = usersCollection
      .orderBy('name')
      .onSnapshot((snapshot) => {
        this.users = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        this.render();
      }, (error) => {
        console.error('Failed to load users:', error);
      });
  }

  render() {
    // Clean up existing user cards
    this.userCards.forEach(userCard => {
      userCard.destroy();
    });
    this.userCards.clear();
    
    this.container.innerHTML = '';
    
    if (this.users.length === 0) {
      this.container.innerHTML = `
        <div class="no-users">
          <lottie-player 
            src="animations/user-avatar.json" 
            background="transparent" 
            speed="0.5" 
            style="width: 80px; height: 80px; opacity: 0.5;" 
            loop 
            autoplay>
          </lottie-player>
          <p data-i18n="user.noUsers">${t('user.noUsers')}</p>
        </div>
      `;
      return;
    }

    this.users.forEach(user => {
      const userCard = new UserCard(user);
      const cardElement = userCard.render();
      cardElement.setAttribute('data-user-id', user.id);
      this.container.appendChild(cardElement);
      
      // Store reference for cleanup
      this.userCards.set(user.id, userCard);
    });
  }

  destroy() {
    // Clean up all listeners
    if (this.usersListener) {
      this.usersListener();
    }
    this.userCards.forEach(userCard => {
      userCard.destroy();
    });
    this.userCards.clear();
  }
}
```

### 5. Admin Panel (js/components/admin-panel.js)
```javascript
class AdminPanel {
  constructor() {
    this.modal = document.getElementById('admin-modal');
    this.content = document.getElementById('admin-content');
    this.init();
  }

  init() {
    const adminBtn = document.getElementById('admin-panel-btn');
    adminBtn.addEventListener('click', () => this.show());

    const closeBtn = this.modal.querySelector('.close');
    closeBtn.addEventListener('click', () => this.hide());

    window.addEventListener('click', (e) => {
      if (e.target === this.modal) {
        this.hide();
      }
    });
  }

  show() {
    this.render();
    this.modal.style.display = 'block';
  }

  hide() {
    this.modal.style.display = 'none';
  }

  render() {
    if (!authManager.isAdmin) {
      this.content.innerHTML = '<p class="no-admin">Nur Administratoren haben Zugriff auf diesen Bereich.</p>';
      return;
    }
    
    this.content.innerHTML = `
      <div class="admin-actions">
        <button onclick="adminPanel.showAddUserForm()" class="btn-primary">
          ${t('admin.addUser')}
        </button>
        <button onclick="adminPanel.showStats()" class="btn-secondary">
          ${t('admin.statistics')}
        </button>
        <button onclick="adminPanel.showManageAdmins()" class="btn-secondary">
          ${t('admin.manageAdmins')}
        </button>
      </div>
      <div id="admin-dynamic-content"></div>
    `;
  }

  showAddUserForm() {
    const dynamicContent = document.getElementById('admin-dynamic-content');
    dynamicContent.innerHTML = `
      <form id="admin-add-user-form">
        <h3>Neue Person hinzufügen</h3>
        <input type="text" id="admin-user-name" placeholder="Name" required>
        <input type="file" id="admin-user-image" accept="image/*">
        <button type="submit">Hinzufügen</button>
      </form>
    `;

    const form = document.getElementById('admin-add-user-form');
    form.addEventListener('submit', (e) => this.handleAddUser(e));
  }

  async handleAddUser(e) {
    e.preventDefault();
    
    const name = document.getElementById('admin-user-name').value;
    const imageFile = document.getElementById('admin-user-image').files[0];

    try {
      let profileImage = null;

      if (imageFile) {
        const imageRef = storage.ref(`users/${Date.now()}_${imageFile.name}`);
        await imageRef.put(imageFile);
        profileImage = await imageRef.getDownloadURL();
      }

      await usersCollection.add({
        name: name,
        profileImage: profileImage,
        createdAt: firebase.firestore.FieldValue.serverTimestamp()
      });

      alert('Person erfolgreich hinzugefügt!');
      this.hide();
    } catch (error) {
      console.error('Failed to add user:', error);
      alert('Fehler beim Hinzufügen der Person');
    }
  }

  async showStats() {
    try {
      const usersSnapshot = await usersCollection.get();
      const raphconsSnapshot = await raphconsCollection.get();
      const adminsSnapshot = await adminsCollection.get();
      
      const dynamicContent = document.getElementById('admin-dynamic-content');
      dynamicContent.innerHTML = `
        <div class="stats">
          <h3>Statistiken</h3>
          <p>Personen: ${usersSnapshot.size}</p>
          <p>Raphcons: ${raphconsSnapshot.size}</p>
          <p>Admins: ${adminsSnapshot.size}</p>
        </div>
      `;
    } catch (error) {
      console.error('Failed to load stats:', error);
    }
  }

  async showManageAdmins() {
    try {
      const adminsSnapshot = await adminsCollection.get();
      const adminsList = adminsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      const dynamicContent = document.getElementById('admin-dynamic-content');
      dynamicContent.innerHTML = `
        <div class="admin-management">
          <h3>Admin Verwaltung</h3>
          <form id="add-admin-form">
            <input type="email" id="admin-email" placeholder="Admin E-Mail" required>
            <button type="submit">Admin hinzufügen</button>
          </form>
          <div class="admin-list">
            <h4>Aktuelle Admins:</h4>
            ${adminsList.map(admin => `
              <div class="admin-item">
                <span>${admin.email || admin.name}</span>
                ${admin.id !== authManager.currentUser.uid ? 
                  `<button onclick="adminPanel.removeAdmin('${admin.id}')" class="btn-danger">Entfernen</button>` : 
                  '<span class="current-admin">(Du)</span>'
                }
              </div>
            `).join('')}
          </div>
        </div>
      `;
      
      const addAdminForm = document.getElementById('add-admin-form');
      addAdminForm.addEventListener('submit', (e) => this.handleAddAdmin(e));
    } catch (error) {
      console.error('Failed to load admins:', error);
    }
  }

  async handleAddAdmin(e) {
    e.preventDefault();
    const email = document.getElementById('admin-email').value;
    
    try {
      await adminsCollection.doc().set({
        email: email,
        addedBy: authManager.currentUser.uid,
        addedAt: firebase.firestore.FieldValue.serverTimestamp()
      });
      
      alert('Admin erfolgreich hinzugefügt!');
      this.showManageAdmins(); // Refresh the list
    } catch (error) {
      console.error('Failed to add admin:', error);
      alert('Fehler beim Hinzufügen des Admins');
    }
  }

  async removeAdmin(adminId) {
    if (confirm('Möchten Sie diesen Admin wirklich entfernen?')) {
      try {
        await adminsCollection.doc(adminId).delete();
        alert('Admin erfolgreich entfernt!');
        this.showManageAdmins(); // Refresh the list
      } catch (error) {
        console.error('Failed to remove admin:', error);
        alert('Fehler beim Entfernen des Admins');
      }
    }
  }
}

function showAddRaphconDialog(userId) {
  if (!authManager.isAdmin) return;

  const modal = document.createElement('div');
  modal.className = 'modal';
  modal.innerHTML = `
    <div class="modal-content">
      <span class="close" onclick="this.closest('.modal').remove()">&times;</span>
      <h3>Raphcon hinzufügen</h3>
      <form id="add-raphcon-form">
        <textarea placeholder="Beschreibung (optional)" id="raphcon-description"></textarea>
        <input type="file" accept="image/*" id="raphcon-image">
        <button type="submit">Raphcon hinzufügen</button>
      </form>
    </div>
  `;

  document.body.appendChild(modal);
  modal.style.display = 'block';

  const form = modal.querySelector('#add-raphcon-form');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const description = document.getElementById('raphcon-description').value;
    const imageFile = document.getElementById('raphcon-image').files[0];

    try {
      let imagePath = null;

      if (imageFile) {
        const imageRef = storage.ref(`raphcons/${Date.now()}_${imageFile.name}`);
        await imageRef.put(imageFile);
        imagePath = await imageRef.getDownloadURL();
      }

      await raphconsCollection.add({
        userId: userId,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        createdBy: authManager.currentUser.uid,
        imagePath: imagePath,
        description: description
      });

      alert('Raphcon erfolgreich hinzugefügt!');
      modal.remove();
    } catch (error) {
      console.error('Failed to add raphcon:', error);
      alert('Fehler beim Hinzufügen des Raphcons');
    }
  });
}
```

### 6. Main App (js/app.js)
```javascript
let authManager;
let userList;
let adminPanel;

document.addEventListener('DOMContentLoaded', () => {
  // Register Service Worker
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js')
      .then(registration => console.log('SW registered'))
      .catch(error => console.log('SW registration failed'));
  }

  // Initialize app components
  authManager = new AuthManager();
  userList = new UserList();
  adminPanel = new AdminPanel();

  // Setup language selector
  const languageSelector = document.getElementById('language-selector');
  languageSelector.value = currentLocale;
  languageSelector.addEventListener('change', (e) => {
    currentLocale = e.target.value;
    localStorage.setItem('locale', currentLocale);
    loadTranslations(currentLocale);
  });

  // Hide loading with delay for animation
  setTimeout(() => {
    document.getElementById('loading').style.display = 'none';
  }, 1500);
});

// PWA Install prompt
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  
  const installBtn = document.createElement('button');
  installBtn.textContent = 'App installieren';
  installBtn.className = 'install-btn';
  installBtn.addEventListener('click', () => {
    deferredPrompt.prompt();
    deferredPrompt.userChoice.then((choiceResult) => {
      deferredPrompt = null;
      installBtn.remove();
    });
  });
  
  document.querySelector('.header-actions').appendChild(installBtn);
});
```

## CSS Styling (css/styles.css)

```css
/* Base Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f5f5f5;
  color: #333;
}

/* Header */
.app-header {
  background-color: #8B0000;
  color: white;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.header-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

#user-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.user-avatar-small {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 2px solid white;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.language-selector {
  background-color: transparent;
  color: white;
  border: 1px solid white;
  border-radius: 4px;
  padding: 0.25rem 0.5rem;
  font-size: 0.9rem;
}

.language-selector option {
  background-color: #8B0000;
  color: white;
}

/* Buttons */
.btn-primary {
  background-color: #8B0000;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}

.btn-secondary {
  background-color: transparent;
  color: white;
  border: 1px solid white;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}

/* User List */
.main-content {
  padding: 1rem;
  max-width: 800px;
  margin: 0 auto;
}

.user-list {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
}

/* User Card */
.user-card {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  display: flex;
  align-items: center;
  gap: 1rem;
  cursor: pointer;
  transition: transform 0.2s;
}

.user-card:hover {
  transform: translateY(-2px);
}

.user-avatar img,
.avatar-placeholder {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background-color: #8B0000;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.user-info h3 {
  margin-bottom: 0.25rem;
}

.raphcon-count {
  color: #666;
  font-size: 0.9rem;
}

.add-raphcon-btn {
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 50%;
  width: 30px;
  height: 30px;
  cursor: pointer;
  font-size: 1.2rem;
}

/* Modal */
.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0,0,0,0.4);
}

.modal-content {
  background-color: white;
  margin: 15% auto;
  padding: 2rem;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
}

.close {
  color: #aaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
  cursor: pointer;
}

.close:hover {
  color: black;
}

/* Forms */
form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

input, textarea {
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

button[type="submit"] {
  background-color: #8B0000;
  color: white;
  border: none;
  padding: 0.75rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

/* Loading */
.loading {
  text-align: center;
  padding: 2rem;
}

/* Responsive */
@media (max-width: 768px) {
  .user-list {
    grid-template-columns: 1fr;
  }
  
  .app-header {
    padding: 0.75rem;
  }
  
  .user-card {
    padding: 0.75rem;
  }
}

/* PWA Install Button */
.install-btn {
  background-color: #4caf50;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
}

/* Admin Management */
.admin-management {
  margin-top: 1rem;
}

.admin-list {
  margin-top: 1rem;
}

.admin-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-bottom: 0.5rem;
}

.btn-danger {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
}

.current-admin {
  font-style: italic;
  color: #666;
}

.no-admin {
  text-align: center;
  padding: 2rem;
  color: #666;
}

/* Lottie Animations */
.success-animation {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 9999;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 50%;
  padding: 1rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.no-users {
  text-align: center;
  padding: 3rem 1rem;
  color: #666;
}

.add-raphcon-btn {
  background-color: transparent !important;
  border: none !important;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.2s;
}

.add-raphcon-btn:hover {
  transform: scale(1.1);
}

/* Loading animation styling */
.loading {
  text-align: center;
  padding: 3rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}
```

## Localization Files

### Swiss German (locales/de-ch.json)
```json
{
  "app": {
    "title": "AngryRaphi"
  },
  "auth": {
    "signInGoogle": "Mit Google aamelde",
    "logout": "Abmelde",
    "signingIn": "Wird aameldet...",
    "signInFailed": "Aameldung fählgschlage"
  },
  "user": {
    "raphcons": "Raphcons",
    "noUsers": "Kei Persone gfunde"
  },
  "admin": {
    "panel": "Admin",
    "addUser": "Person hinzuefüege",
    "statistics": "Statistike",
    "manageAdmins": "Admins verwalte"
  },
  "raphcon": {
    "add": "Raphcon hinzuefüege",
    "addSuccess": "Raphcon erfolgriich hinzuegfüegt!",
    "addFailed": "Fähler bim Hinzuefüege vom Raphcon"
  },
  "common": {
    "loading": "Am lade...",
    "save": "Speichere",
    "cancel": "Abbreche",
    "confirm": "Bestätige"
  }
}
```

### German (locales/de-de.json)
```json
{
  "app": {
    "title": "AngryRaphi"
  },
  "auth": {
    "signInGoogle": "Mit Google anmelden",
    "logout": "Abmelden",
    "signingIn": "Wird angemeldet...",
    "signInFailed": "Anmeldung fehlgeschlagen"
  },
  "user": {
    "raphcons": "Raphcons",
    "noUsers": "Keine Personen gefunden"
  },
  "admin": {
    "panel": "Admin",
    "addUser": "Person hinzufügen",
    "statistics": "Statistiken",
    "manageAdmins": "Admins verwalten"
  },
  "raphcon": {
    "add": "Raphcon hinzufügen",
    "addSuccess": "Raphcon erfolgreich hinzugefügt!",
    "addFailed": "Fehler beim Hinzufügen des Raphcons"
  },
  "common": {
    "loading": "Laden...",
    "save": "Speichern",
    "cancel": "Abbrechen",
    "confirm": "Bestätigen"
  }
}
```

## Lottie Animations

### Empfohlene Animationen
- **angry-face.json**: Wütender Gesichtsausdruck für Logo und Raphcon-Button
- **loading-spinner.json**: Eleganter Ladespinner
- **success-checkmark.json**: Erfolgshaken für erfolgreiche Aktionen
- **user-avatar.json**: Animierter Benutzer-Avatar als Platzhalter

### Lottie-Quellen
- [LottieFiles.com](https://lottiefiles.com) - Kostenlose Animationen
- [Lordicon.com](https://lordicon.com) - Premium-Animationen
- Eigene Animationen mit After Effects + Bodymovin Plugin

## Deployment

### Firebase Hosting Setup
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

## Copilot Entwicklungsschritte

### Phase 1: Setup
- "Erstelle eine neue PWA mit Firebase Hosting"
- "Konfiguriere Firebase Firestore, Authentication und Storage"
- "Implementiere Firestore und Storage Security Rules"
- "Implementiere Service Worker für Offline-Funktionalität"

### Phase 2: Core Features
- "Erstelle HTML Template mit responsivem Design"
- "Implementiere Firebase Authentication für Admin-Zugriff"
- "Erstelle UserCard Component für Personenliste"
- "Integriere Lottie-Animationen für bessere UX"

### Phase 3: Admin Features
- "Erstelle Admin Panel Modal mit Verwaltungsfunktionen"
- "Implementiere Raphcon hinzufügen Funktionalität"
- "Füge sicheren Bildupload mit Firebase Storage hinzu"
- "Implementiere Mehrsprachigkeit (DE/CH)"

### Phase 4: PWA Enhancement
- "Implementiere Push-Benachrichtigungen"
- "Füge Offline-Unterstützung mit Cache hinzu"
- "Erstelle App Install Prompt"
- "Optimiere Performance und Sicherheit"

### Copilot Prompt Beispiele

```
"Erstelle eine PWA mit Firebase Firestore Integration und Admin-Panel"

"Implementiere Firebase Storage Security Rules für sichere Bilduploads"

"Erstelle responsives CSS Grid Layout für Personenkarten mit Lottie-Animationen"

"Füge Firebase Storage Bildupload mit Größen- und Typvalidierung hinzu"

"Implementiere Firestore und Storage Security Rules mit rollenbasierter Zugriffskontrolle"

"Erstelle Modal-Dialog für Admin-Funktionen mit Vanilla JavaScript"

"Integriere Lottie-Animationen für Ladezustände und Erfolgsbestätigungen"

"Implementiere Mehrsprachigkeit mit Schweizerdeutsch und Hochdeutsch"

"Optimiere PWA für Mobile Performance und sichere App-Installation"
```

---

**Diese Anleitung erstellt eine vollständige PWA mit Firebase Backend, die als native App installiert werden kann und offline funktioniert.**