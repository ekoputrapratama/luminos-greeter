import { get as get_val, set, remove } from './dot-prop.js';
/** @type {Object} */
const cfg = theme_config.read("config.json");
/**
 *
 *
 * @export
 * @returns {Object}
 */
export function getConfig() {
  return cfg;
}
/**
 *
 *
 * @export
 * @param {String} key
 * @param {any} defaultValue
 * @returns {any}
 */
export function get(key, defaultValue) {
  return get_val(cfg, key, defaultValue);
}
