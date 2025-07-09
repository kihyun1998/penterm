enum SVGAsset {
  theme("assets/icons/ico_theme.svg"),
  language("assets/icons/ico_language.svg"),
  plus("assets/icons/ico_plus.svg"),
  elipsisVertical("assets/icons/ico_elipsis_vertical.svg"),

  /// title bar
  windowClose('assets/icons/titlebar/ico_window_close.svg'),
  windowMinimize('assets/icons/titlebar/ico_window_minimize.svg'),
  windowMaximize('assets/icons/titlebar/ico_window_maximize.svg'),
  windowRestore('assets/icons/titlebar/ico_window_restore.svg'),
  ;

  final String path;

  const SVGAsset(this.path);
}
