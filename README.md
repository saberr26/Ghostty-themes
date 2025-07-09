# Ghostty Themes 👻

Welcome to the Ghostty Themes repository! This collection of themes is designed to work with the [Ghostty](https://github.com/ghostty-org/ghostty) terminal emulator.

## Features&nbsp;<img src="assets/sparkles.svg" width="18" style="vertical-align: middle;" />

*   **Default Themes:** A set of ready-to-use themes with pre-defined colors.
*   **Matugen Templates:** Templates for `matugen` to generate themes based on your wallpaper.
*   **Customizable:** All themes can be easily customized to your liking.
*   **Tabs:** Themes with both top and bottom tab styles.

## Installation&nbsp;<img src="assets/line-md--download-loop.svg" width="18" style="vertical-align: middle;" />

This repository includes an interactive installation script to make setting up your themes a breeze. To get started, follow these steps:

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/your-username/Ghostty-Themes.git
    ```

2.  **Navigate to the `install` directory:**

    ```bash
    cd Ghostty-Themes/install
    ```

3.  **Run the installation script:**

    ```bash
    ./install.sh
    ```

### Dry Run

If you want to see what the script will do without making any changes to your system, you can use the `--dry-run` flag:

```bash
./install.sh --dry-run
```

## Themes&nbsp;<img src="assets/material-symbols--package-2-sharp.svg" width="18" style="vertical-align: middle;" />

### Default Themes

The `Default-Themes` directory contains two themes:

*   **Ghostty-Tabs.css:** A theme with tabs at the top of the window.
*   **Ghostty.css:** A standard theme that respects your system's GTK theme and has tabs at the bottom of the window.

### Matugen Templates

The `Matugen-Templates` directory contains templates for `matugen`, a tool for generating color schemes from your wallpaper.

*   **Ghostty-matugen-tabs-top.css:** A template for a theme with tabs at the top of the window.
*   **Ghostty-matugen-tabs.css:** A template for a theme with tabs at the bottom of the window.
*   **Ghostty-matugen.css:** A standard theme template.

## Configuration&nbsp;<img src="assets/line-md--cog-loop.svg" width="18" style="vertical-align: middle;" />

The `configs` directory contains example configuration files:

*   **config-Ghostty:** An example Ghostty configuration file.
*   **config.toml:** An example `matugen` configuration file.

The installation script can install these files for you, or you can copy them manually.

## Dependencies&nbsp;<img src="assets/material-symbols--package-2-sharp.svg" width="18" style="vertical-align: middle;" />

To use the Matugen templates, you will need to install the following:

*   **matugen:** A tool for generating color schemes from your wallpaper. You can find installation instructions [here](https://github.com/InioX/matugen).
*   **ydotool:** A command-line tool for simulating keyboard and mouse events. You can find installation instructions [here](https://github.com/ReimuNotMoe/ydotool).
