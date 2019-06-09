class GreeterUtil {
  constructor() {}
  /**
   * Returns the contents of directory at `path`.
   *
   * @param path
   * @returns {String[]} List of abs paths for the files and directories found in `path`.
   */
  dirlist(path) {
    // return this._mock_data.dirlist;
    return window.dirlist(path);
  }
  /**
   * Escape HTML entities in a string.
   *
   * @param {String} text
   * @returns {String}
   */
  txt2html(text) {
    let entities_map = {
      '"': "&quot;",
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;"
    };

    return text.replace(/[\"&<>]/g, a => entities_map[a]);
  }
}

if (typeof greeterutil === "undefined") {
  window.greeterutil = new GreeterUtil();
  window.greeter_util = greeterutil;
}
