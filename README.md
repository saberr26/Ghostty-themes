# Ghostty Themes

This repository contains a collection of themes for the [Ghostty](https://github.com/ghostty-org/ghostty) terminal emulator.

## Features

*   **Default Themes:** Ready-to-use themes with pre-defined colors.
*   **Matugen Templates:** Templates for `matugen` to generate themes based on your wallpaper.
*   **Customizable:** Themes can be easily customized to your liking.
*   **Tabs:** Themes with both top and bottom tab styles.

## Themes

### Default Themes

The `Default-Themes` directory contains two themes:

*   **Ghostty-Tabs.css:** A theme with tabs at the top of the window.
*   **Ghostty.css:** A standard theme that respects your system's GTK theme.

### Matugen Themes

The `Matugen-Templates` directory contains templates for `matugen`, a tool for generating color schemes from your wallpaper.

*   **Ghostty-matugen-tabs-top.css:** A template for a theme with tabs at the top of the window.
*   **Ghostty-matugen-tabs.css:** A template for a theme with tabs at the bottom of the window.
*   **Ghostty-matugen.css:** A standard theme template.

## Installation

### Dependencies

To use the Matugen templates, you will need to install the following:

*   **matugen:** A tool for generating color schemes from your wallpaper. You can find installation instructions [here](https://github.com/InioX/matugen).
*   **ydotool:** A command-line tool for simulating keyboard and mouse events. You can find installation instructions [here](https://github.com/ReimuNotMoe/ydotool).

### Default Themes

1.  Create a `themes` directory in your Ghostty configuration directory if it doesn't already exist:
    ```bash
    mkdir -p ~/.config/ghostty/themes
    ```
2.  Copy the theme file you want to use to the `themes` directory. For example, to use the `Ghostty-Tabs.css` theme:
    ```bash
    cp Default-Themes/Ghostty-Tabs.css ~/.config/ghostty/themes/
    ```
3.  Open the Ghostty configuration file (`~/.config/ghostty/config`) and add or modify the `gtk-custom-css` option to point to your theme file:
    ```
    gtk-custom-css = ~/.config/ghostty/themes/Ghostty-Tabs.css
    ```
4.  Restart Ghostty to apply the new theme.

### Matugen Themes

1.  Create a `templates` directory in your `matugen` configuration directory if it doesn't already exist:
    ```bash
    mkdir -p ~/.config/matugen/templates
    ```
2.  Copy the Matugen templates to the `templates` directory:
    ```bash
    cp Matugen-Templates/* ~/.config/matugen/templates/
    ```
3.  Configure `matugen` to use the templates by adding the following to your `config.toml` file. You can use the `configs/config.toml` file in this repository as a starting point.

    ```toml
    [templates.ghostty]
    input_path = "~/.config/matugen/templates/Ghostty-matugen.css"
    output_path = "~/.config/ghostty/themes/matugen.css"
    post_hook = "ydotool key 29:1 42:1 51:1 51:0 42:0 29:0"
    ```

    **Note:** The `post_hook` command simulates pressing `Ctrl+Shift+R` to reload the Ghostty theme. You may need to adjust this command depending on your system and keyboard layout.

4.  Run `matugen` to generate the theme from your wallpaper. For example:
    ```bash
    matugen -w /path/to/your/wallpaper.jpg
    ```
5.  Open the Ghostty configuration file (`~/.config/ghostty/config`) and add or modify the `gtk-custom-css` option to point to your generated theme file:
    ```
    gtk-custom-css = ~/.config/ghostty/themes/matugen.css
    ```
6.  Restart Ghostty to apply the new theme.

## Configuration

The `configs` directory contains example configuration files:

*   **config-Ghostty:** An example Ghostty configuration file.
*   **config.toml:** An example `matugen` configuration file.

You can use these files as a starting point for your own configurations. To use the example Ghostty configuration, copy it to your Ghostty configuration directory:

```bash
cp configs/config-Ghostty ~/.config/ghostty/config
```

To use the example `matugen` configuration, copy it to your `matugen` configuration directory:

```bash
cp configs/config.toml ~/.config/matugen/config.toml
```
