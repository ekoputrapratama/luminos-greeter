
export function showLog() {
  $("#logArea").show();
}
export function hideLog() {
  $("#logArea").hide();
}
/**
 * Logs
 *
 * @export
 * @param {String} text
 */
export function log(text) {
  $("#logArea").append(text);
  $("#logArea").append("<br/>");
}
window.onerror = function (errorMsg, url, lineNumber) {
  const msg = `${errorMsg} in ${url}:${lineNumber}`;
  $('#logArea').append(msg + "<br />");
};
