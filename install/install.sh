#!/bin/bash

# Create necessary directories
mkdir -p ~/.config/ghostty/themes
mkdir -p ~/.config/matugen/templates

# --- Installation Functions ---

# Install a specific default theme
install_default_theme() {
    local theme_file=$1
    echo "Installing $theme_file..."
    cp -v "../Default-Themes/$theme_file" ~/.config/ghostty/themes/
}

# Install all default themes
install_all_default_themes() {
    echo "Installing all default themes..."
    cp -v ../Default-Themes/* ~/.config/ghostty/themes/
}

# Install a specific Matugen template
install_matugen_template() {
    local template_file=$1
    echo "Installing $template_file..."
    cp -v "../Matugen-Templates/$template_file" ~/.config/matugen/templates/
}

# Install all Matugen templates
install_all_matugen_templates() {
    echo "Installing all Matugen templates..."
    cp -v ../Matugen-Templates/* ~/.config/matugen/templates/
}

# Install example configuration files
install_configs() {
    echo "Installing example configuration files..."
    if [ -f ~/.config/ghostty/config ]; then
        echo "Backing up existing Ghostty config to ~/.config/ghostty/config.bak"
        mv ~/.config/ghostty/config ~/.config/ghostty/config.bak
    fi
    cp -v ../configs/config-Ghostty ~/.config/ghostty/config

    if [ -f ~/.config/matugen/config.toml ]; then
        echo "Backing up existing matugen config to ~/.config/matugen/config.toml.bak"
        mv ~/.config/matugen/config.toml ~/.config/matugen/config.toml.bak
    fi
    cp -v ../configs/config.toml ~/.config/matugen/config.toml
    echo "Example configuration files installed."
}

# --- Menus ---

# Menu for default themes
show_default_themes_menu() {
    echo "
Select a Default Theme to install:
-----------------------------------"    
    local i=1
    for theme in $(ls ../Default-Themes); do
        echo "$i. $theme"
        i=$((i+1))
    done
    echo "$i. Install All Default Themes"
    echo "$((i+1)). Back to Main Menu"
    echo "-----------------------------------"
    echo -n "Enter your choice: "
}

# Menu for Matugen templates
show_matugen_templates_menu() {
    echo "
Select a Matugen Template to install:
-------------------------------------"    
    local i=1
    for template in $(ls ../Matugen-Templates); do
        echo "$i. $template"
        i=$((i+1))
    done
    echo "$i. Install All Matugen Templates"
    echo "$((i+1)). Back to Main Menu"
    echo "-------------------------------------"
    echo -n "Enter your choice: "
}

# Main menu
show_main_menu() {
    echo "
Ghostty Themes Installer
------------------------
1. Install a Default Theme
2. Install a Matugen Template
3. Install ALL Themes and Templates
4. Install Example Configuration Files
5. Exit
------------------------"
    echo -n "Enter your choice: "
}

# --- Post-installation Message ---

show_post_install_message() {
    echo "
-----------------------------------------------------------------
IMPORTANT: To use a theme, you must update your Ghostty config!

Edit your ~/.config/ghostty/config file and set the
'gtk-custom-css' option to the path of your desired theme.

For example:
  gtk-custom-css = ~/.config/ghostty/themes/Ghostty-Tabs.css

For Matugen themes, the default output path is:
  gtk-custom-css = ~/.config/ghostty/themes/matugen.css
-----------------------------------------------------------------
"
}

# --- Script Logic ---

while true; do
    show_main_menu
    read main_choice
    case $main_choice in
        1) # Install a Default Theme
            while true; do
                show_default_themes_menu
                read theme_choice
                themes=($(ls ../Default-Themes))
                if [[ "$theme_choice" -ge 1 && "$theme_choice" -le ${#themes[@]} ]]; then
                    install_default_theme "${themes[$((theme_choice-1))]}"
                    show_post_install_message
                    break
                elif [ "$theme_choice" -eq $((${#themes[@]}+1)) ]; then
                    install_all_default_themes
                    show_post_install_message
                    break
                elif [ "$theme_choice" -eq $((${#themes[@]}+2)) ]; then
                    break
                else
                    echo "Invalid choice. Please try again."
                fi
            done
            ;;
        2) # Install a Matugen Template
            while true; do
                show_matugen_templates_menu
                read template_choice
                templates=($(ls ../Matugen-Templates))
                if [[ "$template_choice" -ge 1 && "$template_choice" -le ${#templates[@]} ]]; then
                    install_matugen_template "${templates[$((template_choice-1))]}"
                    show_post_install_message
                    break
                elif [ "$template_choice" -eq $((${#templates[@]}+1)) ]; then
                    install_all_matugen_templates
                    show_post_install_message
                    break
                elif [ "$template_choice" -eq $((${#templates[@]}+2)) ]; then
                    break
                else
                    echo "Invalid choice. Please try again."
                fi
            done
            ;;
        3) # Install ALL
            install_all_default_themes
            install_all_matugen_templates
            show_post_install_message
            ;;
        4) # Install Configs
            install_configs
            show_post_install_message
            ;;
        5) # Exit
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done