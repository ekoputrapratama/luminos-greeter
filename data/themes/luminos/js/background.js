function onMessage({ data }) {
  const isFetch = data.fetch;
  let url = data.url;
  if (isFetch) {
    return;
  }

  if (!url) {
    url = _cache('bgsaved');
  }
  if (data.url && data.url.length > 0) {
    document.body.style.backgroundImage = `url('${data.url}')`;
    return;
  }
}
window.onbeforeunload = () => {
  window.removeEventListener('message', onMessage);
}
window.oncontextmenu = () => false;
window.addEventListener('message', onMessage, false);

/**
 * fetch doesn't work here cuz i use base64 string so need to fix that by
 * making a request from main frame
 */
const _fetch = window.fetch;
function LuminosFetch(url) {
  return new Promise((resolve, reject) => {
    const onResponse = ({ data }) => {
      const isFetch = data.fetch;
      if (isFetch) {
        if (data.error) {
          reject(data.error);
        }
        resolve(data.data);
      }
      window.removeEventListener('message', onResponse);
    };
    window.addEventListener('message', onResponse, { once: true });
    window.parent.postMessage({ fetch: true, url }, '*');
  });
}
window.fetch = LuminosFetch;
