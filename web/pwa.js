
  // Mobile Device Detection
  function isMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || 
           (window.innerWidth <= 768) ||
           ('ontouchstart' in window);
  }

  // iOS Device Detection
  function isIOS() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
  }

  // Check if running in Safari (not in PWA mode)
  function isSafari() {
    return /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  }

  // Check if app is already installed
  function isAppInstalled() {
    return window.matchMedia && window.matchMedia('(display-mode: standalone)').matches;
  }

  // PWA Install Prompt
  let deferredPrompt;
  let installBanner = null;

  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    console.log('AngryRaphi can be installed as PWA');
    
    // Show install banner on mobile if not already installed
    if (isMobile() && !isAppInstalled()) {
      showInstallBanner();
    }
  });

  // Create and show install banner
  function showInstallBanner() {
    // Don't show if already dismissed recently
    const dismissed = localStorage.getItem('angryraphi-install-dismissed');
    const dismissedTime = dismissed ? parseInt(dismissed) : 0;
    const daysSinceDismissed = (Date.now() - dismissedTime) / (1000 * 60 * 60 * 24);
    
    if (daysSinceDismissed < 7) return; // Don't show again for 7 days

    // Create install banner
    installBanner = document.createElement('div');
    installBanner.id = 'install-banner';
    installBanner.style.cssText = `
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: linear-gradient(135deg, #FF4500, #FF6347);
      color: white;
      padding: 16px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      box-shadow: 0 -2px 10px rgba(0,0,0,0.3);
      z-index: 10000;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      animation: slideUp 0.3s ease-out;
    `;

    installBanner.innerHTML = `
      <div style="flex: 1;">
        <div style="font-weight: bold; margin-bottom: 4px;">📱 AngryRaphi App installieren</div>
        <div style="font-size: 14px; opacity: 0.9;">Für beste Erfahrung als App nutzen</div>
      </div>
      <div style="display: flex; gap: 12px; align-items: center;">
        <button id="install-btn" style="
          background: rgba(255,255,255,0.2);
          border: 1px solid rgba(255,255,255,0.3);
          color: white;
          padding: 8px 16px;
          border-radius: 20px;
          font-weight: bold;
          cursor: pointer;
          font-size: 14px;
        ">Installieren</button>
        <button id="close-banner" style="
          background: transparent;
          border: none;
          color: white;
          font-size: 18px;
          cursor: pointer;
          padding: 4px;
        ">✕</button>
      </div>
    `;

    // Add slide up animation
    const style = document.createElement('style');
    style.textContent = `
      @keyframes slideUp {
        from { transform: translateY(100%); }
        to { transform: translateY(0); }
      }
    `;
    document.head.appendChild(style);

    document.body.appendChild(installBanner);

    // Event listeners
    document.getElementById('install-btn').addEventListener('click', installPWA);
    document.getElementById('close-banner').addEventListener('click', dismissBanner);

    // Auto-hide after 10 seconds
    setTimeout(() => {
      if (installBanner && installBanner.parentNode) {
        dismissBanner();
      }
    }, 10000);
  }

  // Dismiss install banner
  function dismissBanner() {
    if (installBanner) {
      installBanner.style.animation = 'slideDown 0.3s ease-in';
      setTimeout(() => {
        if (installBanner && installBanner.parentNode) {
          installBanner.parentNode.removeChild(installBanner);
        }
        installBanner = null;
      }, 300);
      
      // Remember dismissal
      localStorage.setItem('angryraphi-install-dismissed', Date.now().toString());
    }
  }

  // Handle PWA installation
  function installPWA() {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      deferredPrompt.userChoice.then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('User accepted AngryRaphi PWA install');
          dismissBanner();
        }
        deferredPrompt = null;
      });
    }
  }

  // Check for install prompt on page load (for mobile users)
  window.addEventListener('load', function() {
    if (isMobile() && !isAppInstalled() && !deferredPrompt) {
      // Show a delayed prompt for iOS users (who don't get beforeinstallprompt)
      setTimeout(() => {
        if (/iPhone|iPad|iPod/i.test(navigator.userAgent) && !isAppInstalled()) {
          showIOSInstallHint();
        }
      }, 3000);
    }
  });

  // iOS Install Hint (since iOS doesn't support beforeinstallprompt)
  function showIOSInstallHint() {
    const dismissed = localStorage.getItem('angryraphi-ios-hint-dismissed');
    const dismissedTime = dismissed ? parseInt(dismissed) : 0;
    const daysSinceDismissed = (Date.now() - dismissedTime) / (1000 * 60 * 60 * 24);
    
    if (daysSinceDismissed < 14) return; // Don't show again for 14 days

    const iosHint = document.createElement('div');
    iosHint.style.cssText = `
      position: fixed;
      bottom: 20px;
      left: 20px;
      right: 20px;
      background: rgba(0,0,0,0.9);
      color: white;
      padding: 16px;
      border-radius: 12px;
      text-align: center;
      z-index: 10000;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      animation: slideUp 0.3s ease-out;
    `;

    iosHint.innerHTML = `
      <div style="margin-bottom: 8px;">📱 AngryRaphi als App installieren</div>
      <div style="font-size: 14px; margin-bottom: 12px; opacity: 0.8;">
        Tippe auf <strong>Teilen</strong> → <strong>Zum Home-Bildschirm</strong>
      </div>
      <button onclick="this.parentNode.style.display='none'; localStorage.setItem('angryraphi-ios-hint-dismissed', Date.now());" 
              style="background: #FF4500; border: none; color: white; padding: 8px 16px; border-radius: 20px; cursor: pointer;">
        Verstanden
      </button>
    `;

    document.body.appendChild(iosHint);

    // Auto-hide after 8 seconds
    setTimeout(() => {
      if (iosHint && iosHint.parentNode) {
        iosHint.style.display = 'none';
      }
    }, 8000);
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