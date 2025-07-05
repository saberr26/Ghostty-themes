#!/bin/bash

# Ghostty Themes Installer 🚀

# --- Emojis ---
GHOST="👻"
SPARKLES="✨"
ROCKET="🚀"
CHECKMARK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"

# --- Directories ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
MATUGEN_CONFIG_DIR="$HOME/.config/matugen"
THEMES_DIR="$GHOSTTY_CONFIG_DIR/themes"
TEMPLATES_DIR="$MATUGEN_CONFIG_DIR/templates"

# --- Dry Run Check ---
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
fi

# --- Banners ---
print_banner() {
    echo -e "
$GHOST Welcome to the Ghostty Themes Installer $SPARKLES
"
    if [ "$DRY_RUN" = true ]; then
        echo -e "$WARNING Running in dry-run mode. No files will be changed. $WARNING
"
    fi
}

# --- Functions ---
create_dir() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "$INFO [DRY RUN] Would create directory: $1"
        return
    fi
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "$CHECKMARK Created directory: $1"
    fi
}

backup_file() {
    if [ ! -f "$1" ]; then
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "$WARNING [DRY RUN] Would back up existing file to $1.bak"
        return
    fi

    mv "$1" "$1.bak"
    echo -e "$WARNING Backed up existing file to $1.bak"
}

copy_file() {
    local src="$1"
    local dest="$2"
    local type="$3"

    if [ ! -f "$src" ]; then
        echo -e "$CROSS Source file not found: $src"
        return 1
    fi

    echo -e "$INFO Installing $type..."
    if [ "$DRY_RUN" = true ]; then
        echo -e "$INFO [DRY RUN] Would copy $src to $dest"
    else
        cp "$src" "$dest"
        if [ $? -eq 0 ]; then
            echo -e "$CHECKMARK $type installed successfully!"
        else
            echo -e "$CROSS Failed to install $type."
            return 1
        fi
    fi
    return 0
}

install_all() {
    local src_dir="$1"
    local dest_dir="$2"
    local type="$3"

    if [ ! -d "$src_dir" ]; then
        echo -e "$CROSS Source directory not found: $src_dir"
        return 1
    fi

    echo -e "$INFO Installing all $type..."
    for file in "$src_dir"/*; do
        copy_file "$file" "$dest_dir/" "$(basename "$file")"
    done
}

# --- Menus ---
show_main_menu() {
    echo -e "
$INFO What would you like to do?"
    echo "  1) Install Default Themes"
    echo "  2) Install Matugen Templates"
    echo "  3) Install Config Files"
    echo "  4) Install Everything"
    echo "  5) Exit"
    echo -n "Enter your choice: "
}

show_theme_menu() {
    echo -e "
$INFO Which theme would you like to install?"
    echo "  1) Ghostty-Tabs.css (Tabs on top)"
    echo "  2) Ghostty.css (Standard)"
    echo "  3) All Default Themes"
    echo "  4) Back to Main Menu"
    echo -n "Enter your choice: "
}

show_template_menu() {
    echo -e "
$INFO Which Matugen template would you like to install?"
    echo "  1) Ghostty-matugen-tabs-top.css (Tabs on top)"
    echo "  2) Ghostty-matugen-tabs.css (Tabs on bottom)"
    echo "  3) Ghostty-matugen.css (Standard)"
    echo "  4) All Matugen Templates"
    echo "  5) Back to Main Menu"
    echo -n "Enter your choice: "
}

show_config_menu() {
    echo -e "
$INFO Which config file would you like to install?"
    echo "  1) Ghostty Config"
    echo "  2) Matugen Config"
    echo "  3) All Config Files"
    echo "  4) Back to Main Menu"
    echo -n "Enter your choice: "
}

# --- Main Logic ---
main() {
    print_banner
    create_dir "$THEMES_DIR"
    create_dir "$TEMPLATES_DIR"

    while true; do
        show_main_menu
        read -r choice

        case $choice in
            1) # Themes
                while true; do
                    show_theme_menu
                    read -r theme_choice
                    case $theme_choice in
                        1) copy_file "$REPO_ROOT/Default-Themes/Ghostty-Tabs.css" "$THEMES_DIR/" "Ghostty-Tabs.css"; break ;;
                        2) copy_file "$REPO_ROOT/Default-Themes/Ghostty.css" "$THEMES_DIR/" "Ghostty.css"; break ;;
                        3) install_all "$REPO_ROOT/Default-Themes" "$THEMES_DIR" "Default Themes"; break ;;
                        4) break ;;
                        *) echo -e "$CROSS Invalid choice." ;;
                    esac
                done
                ;;
            2) # Templates
                while true; do
                    show_template_menu
                    read -r template_choice
                    case $template_choice in
                        1) copy_file "$REPO_ROOT/Matugen-Templates/Ghostty-matugen-tabs-top.css" "$TEMPLATES_DIR/" "Ghostty-matugen-tabs-top.css"; break ;;
                        2) copy_file "$REPO_ROOT/Matugen-Templates/Ghostty-matugen-tabs.css" "$TEMPLATES_DIR/" "Ghostty-matugen-tabs.css"; break ;;
                        3) copy_file "$REPO_ROOT/Matugen-Templates/Ghostty-matugen.css" "$TEMPLATES_DIR/" "Ghostty-matugen.css"; break ;;
                        4) install_all "$REPO_ROOT/Matugen-Templates" "$TEMPLATES_DIR" "Matugen Templates"; break ;;
                        5) break ;;
                        *) echo -e "$CROSS Invalid choice." ;;
                    esac
                done
                ;;
            3) # Configs
                while true; do
                    show_config_menu
                    read -r config_choice
                    case $config_choice in
                        1) 
                            backup_file "$GHOSTTY_CONFIG_DIR/config"
                            copy_file "$REPO_ROOT/configs/config-Ghostty" "$GHOSTTY_CONFIG_DIR/config" "Ghostty Config"
                            break
                            ;;
                        2) 
                            backup_file "$MATUGEN_CONFIG_DIR/config.toml"
                            copy_file "$REPO_ROOT/configs/config.toml" "$MATUGEN_CONFIG_DIR/config.toml" "Matugen Config"
                            break
                            ;;
                        3) 
                            backup_file "$GHOSTTY_CONFIG_DIR/config"
                            copy_file "$REPO_ROOT/configs/config-Ghostty" "$GHOSTTY_CONFIG_DIR/config" "Ghostty Config"
                            backup_file "$MATUGEN_CONFIG_DIR/config.toml"
                            copy_file "$REPO_ROOT/configs/config.toml" "$MATUGEN_CONFIG_DIR/config.toml" "Matugen Config"
                            break
                            ;;
                        4) break ;;
                        *) echo -e "$CROSS Invalid choice." ;;
                    esac
                done
                ;;
            4) # Everything
                install_all "$REPO_ROOT/Default-Themes" "$THEMES_DIR" "Default Themes"
                install_all "$REPO_ROOT/Matugen-Templates" "$TEMPLATES_DIR" "Matugen Templates"
                backup_file "$GHOSTTY_CONFIG_DIR/config"
                copy_file "$REPO_ROOT/configs/config-Ghostty" "$GHOSTTY_CONFIG_DIR/config" "Ghostty Config"
                backup_file "$MATUGEN_CONFIG_DIR/config.toml"
                copy_file "$REPO_ROOT/configs/config.toml" "$MATUGEN_CONFIG_DIR/config.toml" "Matugen Config"
                ;;
            5) # Exit
                echo -e "
$ROCKET Enjoy your new themes! $SPARKLES
"
                break
                ;;
            *) echo -e "$CROSS Invalid choice." ;;
        esac
    done
}

main