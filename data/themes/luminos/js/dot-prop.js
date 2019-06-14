/**
 *
 *
 * @param {any} value
 * @returns {Boolean}
 */
function isObj(value) {
  const type = typeof value;
  return value !== null && (type === 'object' || type === 'function');
};
/**
 *
 *
 * @param {String} path
 * @returns {String}
 */
function getPathSegments(path) {
  const pathArray = path.split('.');
  const parts = [];

  for (let i = 0; i < pathArray.length; i++) {
    let p = pathArray[i];

    while (p[p.length - 1] === '\\' && pathArray[i + 1] !== undefined) {
      p = p.slice(0, -1) + '.';
      p += pathArray[++i];
    }

    parts.push(p);
  }

  return parts;
}
/**
 *
 *
 * @export
 * @param {Object} object
 * @param {String} path
 * @param {any} defautlValue
 * @returns
 */
export function get(object, path, defautlValue) {
  if (!isObj(object) || typeof path !== 'string') {
    return defautlValue === undefined ? object : defautlValue;
  }

  const pathArray = getPathSegments(path);

  for (let i = 0; i < pathArray.length; i++) {
    if (!Object.prototype.propertyIsEnumerable.call(object, pathArray[i])) {
      return defautlValue;
    }

    object = object[pathArray[i]];

    if (object === undefined || object === null) {
      // `object` is either `undefined` or `null` so we want to stop the loop, and
      // if this is not the last bit of the path, and
      // if it did't return `undefined`
      // it would return `null` if `object` is `null`
      // but we want `get({foo: null}, 'foo.bar')` to equal `undefined`, or the supplied value, not `null`
      if (i !== pathArray.length - 1) {
        return defautlValue;
      }

      break;
    }
  }

  return object;
}
/**
 *
 *
 * @export
 * @param {Object} object
 * @param {String} path
 * @param {any} value
 * @returns {any}
 */
export function set(object, path, value) {
  if (!isObj(object) || typeof path !== 'string') {
    return object;
  }

  const root = object;
  const pathArray = getPathSegments(path);

  for (let i = 0; i < pathArray.length; i++) {
    const p = pathArray[i];

    if (!isObj(object[p])) {
      object[p] = {};
    }

    if (i === pathArray.length - 1) {
      object[p] = value;
    }

    object = object[p];
  }

  return root;
}
/**
 *
 *
 * @export
 * @param {Object} object
 * @param {String} path
 * @returns {void}
 */
export function remove(object, path) {
  if (!isObj(object) || typeof path !== 'string') {
    return;
  }

  const pathArray = getPathSegments(path);

  for (let i = 0; i < pathArray.length; i++) {
    const p = pathArray[i];

    if (i === pathArray.length - 1) {
      delete object[p];
      return;
    }

    object = object[p];

    if (!isObj(object)) {
      return;
    }
  }
}
/**
 *
 *
 * @export
 * @param {Object} object
 * @param {String} path
 * @returns {Boolean}
 */
export function has(object, path) {
  if (!isObj(object) || typeof path !== 'string') {
    return false;
  }

  const pathArray = getPathSegments(path);

  for (let i = 0; i < pathArray.length; i++) {
    if (isObj(object)) {
      if (!(pathArray[i] in object)) {
        return false;
      }

      object = object[pathArray[i]];
    } else {
      return false;
    }
  }

  return true;
}
