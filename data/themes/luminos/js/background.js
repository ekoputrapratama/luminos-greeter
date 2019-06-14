function onMessage({ data }) {

  let url = data.url;
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
