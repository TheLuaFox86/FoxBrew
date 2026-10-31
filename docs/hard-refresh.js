async function runHardRefresh() {
  const status = document.querySelector('.hard-refresh-status');
  const buttons = document.querySelectorAll('.hard-refresh-button');

  buttons.forEach((item) => {
    item.disabled = true;
  });
  if (status) status.textContent = 'Clearing app cache and checking for updates...';

  try {
    const registration = 'serviceWorker' in navigator
      ? await navigator.serviceWorker.getRegistration()
      : null;
    const scope = registration?.scope || new URL('./', location.href).href;
    const scopeUrl = new URL(scope);
    const cachePrefix = `${scopeUrl.origin}${scopeUrl.pathname}`;
    const cacheNames = await caches.keys();

    await Promise.all(
      cacheNames
        .filter((name) => name.includes(cachePrefix))
        .map((name) => caches.delete(name)),
    );

    if (registration) {
      await registration.update();
      const installingWorker = registration.installing;
      if (installingWorker) {
        await new Promise((resolve, reject) => {
          const onStateChange = () => {
            if (installingWorker.state === 'activated') {
              installingWorker.removeEventListener('statechange', onStateChange);
              resolve();
            } else if (installingWorker.state === 'redundant') {
              installingWorker.removeEventListener('statechange', onStateChange);
              reject(new Error('The updated service worker failed to install.'));
            }
          };

          installingWorker.addEventListener('statechange', onStateChange);
          onStateChange();
        });
      }
    }

    const reloadUrl = new URL(location.href);
    reloadUrl.searchParams.set('foxbrew-hard-refresh', Date.now().toString());
    location.replace(reloadUrl.href);
  } catch (error) {
    console.error('Hard refresh failed:', error);
    buttons.forEach((item) => {
      item.disabled = false;
    });
    if (status) {
      status.textContent = `Could not update the app: ${error instanceof Error ? error.message : String(error)}`;
    }
  }
}

document.addEventListener('click', (event) => {
  if (!(event.target instanceof Element)) return;
  const button = event.target.closest('.hard-refresh-button');
  if (button instanceof HTMLButtonElement) {
    runHardRefresh(button);
  }
});
