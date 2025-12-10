// AngryRaphi PWA Service Worker
  // Service Worker Registration for PWA functionality
  if ('serviceWorker' in navigator) {
    window.addEventListener('flutter-first-frame', function () {
      navigator.serviceWorker.register('flutter_service_worker.js', {
        scope: '/'
      }).then(function(registration) {
        console.log('AngryRaphi SW registered successfully');
      }).catch(function(error) {
        console.log('AngryRaphi SW registration failed');
      });
    });
  }

  // PWA Install Prompt
  let deferredPrompt;
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    // Show install button or banner
    console.log('AngryRaphi can be installed as PWA');
  });

  // Handle PWA installation
  function installPWA() {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      deferredPrompt.userChoice.then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('User accepted AngryRaphi PWA install');
        }
        deferredPrompt = null;
      });
    }
  }

  // PWA Theme Color based on AngryRaphi branding
  function updateThemeColor(color) {
    const metaThemeColor = document.querySelector("meta[name=theme-color]");
    if (metaThemeColor) {
      metaThemeColor.setAttribute("content", color || "#FF4500");
    }
  }

  // Initialize AngryRaphi theme
  document.addEventListener('DOMContentLoaded', function() {
    updateThemeColor("#FF4500");
  });