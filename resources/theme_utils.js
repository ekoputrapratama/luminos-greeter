var time_language = null,
  time_format = null,
  manual_time_format;

class ThemeUtils {
  constructor() { }
  /**
   * Returns the contents of directory found at `path` provided that the (normalized) `path`
   * meets at least one of the following conditions:
   *   * Is located within the greeter themes' root directory.
   *   * Has been explicitly allowed in the greeter's config file.
   *   * Is located within the greeter's shared data directory (`/var/lib/lightdm-data`).
   *   * Is located in `/tmp`.
   *
   * @param {string}              path        The abs path to desired directory.
   * @param {boolean}             only_images Include only images in the results. Default `true`.
   * @param {function(string[])}  callback    Callback function to be called with the result.
   */
  dirlist(path, only_images = true, callback) {
    if ("" === path || "string" !== typeof path) {
      console.error(
        "[ERROR] theme_utils.dirlist(): path must be a non-empty string!"
      );
      return callback([]);
    } else if (null !== path.match(/^[^/].+/)) {
      console.error("[ERROR] theme_utils.dirlist(): path must be absolute!");
      return callback([]);
    }

    if (null !== path.match(/\/\.+(?=\/)/)) {
      // No special directory names allowed (eg ../../)
      path = path.replace(/\/\.+(?=\/)/g, "");
    }

    try {
      return dirlist(path, only_images, callback);
    } catch (err) {
      console.error(`[ERROR] theme_utils.dirlist(): ${err}`);
      return callback([]);
    }
  }

  /**
   * Get the current time in a localized format. Time format and language are auto-detected
   * by default, but can be set manually in the greeter config file.
   *   * `language` defaults to the system's language, but can be set manually in the config file.
   *   * When `time_format` config file option has a valid value, time will be formatted
   *     according to that value.
   *   * When `time_format` does not have a valid value, the time format will be `LT`
   *     which is `1:00 PM` or `13:00` depending on the system's locale.
   *
   * @return {string} The current localized time.
   */
  get_current_localized_time() {
    if (time_language === null) {
      let config = greeter_config.greeter,
        manual_language =
          "" !== config.time_language && "auto" !== config.time_language,
        manual_time_format =
          "" !== config.time_format && "auto" !== config.time_format;

      time_language = manual_language
        ? config.time_language
        : window.navigator.language;
      time_format = manual_time_format ? config.time_format : "LT";

      if (manual_language) {
        moment.locale(time_language);
      }
    }

    let local_time = moment().format(time_format);
    let localized_invalid_date = "Invalid Date";

    if (local_time === localized_invalid_date) {
      local_time = moment().format("LT");
    }

    return local_time;
  }
}

if (typeof theme_utils === "undefined") {
  theme_utils = new ThemeUtils();
}
