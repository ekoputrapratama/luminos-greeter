/**
 *
 *
 * @class CacheUtil
 */
class CacheUtil {
  constructor() { }
  /**
   *
   *
   * @param {String} name
   * @param {String|Number} value
   * @memberof CacheUtil
   */
  set(name, value) {
    localStorage.setItem(name, value);
  }
  /**
   *
   *
   * @param {String} name
   * @param {String|Number} defaultValue
   * @returns
   * @memberof CacheUtil
   */
  get(name, defaultValue) {
    const val = localStorage.getItem(name);
    if (!val) return defaultValue;
    return localStorage.getItem(name);
  }
  /**
   *
   *
   * @readonly
   * @memberof CacheUtil
   */
  get keys() {
    let keys = [];
    for (var i = 0; i < localStorage.length; i++) {
      keys.push(localStorage.key(i));
    }
    return keys;
  }
  /**
   *
   *
   * @param {String} name
   * @returns {Boolean}
   * @memberof CacheUtil
   */
  has(name) {
    const val = localStorage.getItem(name);
    return val !== null && val !== undefined;
  }
  /**
   *
   *
   * @param {String} name
   * @memberof CacheUtil
   */
  delete(name) {
    localStorage.removeItem(name);
  }
}
window._cache = new CacheUtil();

