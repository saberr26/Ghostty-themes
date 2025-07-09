#!/bin/bash

# --- Icons ---
GHOST="󰊠"
SPARKLES=""
ROCKET=""
CHECKMARK=""
CROSS=""
WARNING=""
INFO=""

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# --- Directories ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
MATUGEN_CONFIG_DIR="$HOME/.config/matugen"
THEMES_DIR="$GHOSTTY_CONFIG_DIR/themes"
TEMPLATES_DIR="$MATUGEN_CONFIG_DIR/templates"

# --- Global Variables ---
DRY_RUN=false
VERBOSE=false
BACKUP_DIR="$HOME/.config/ghostty_themes_backup_$(date +%Y%m%d_%H%M%S)"

# --- Command Line Arguments ---
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}${CROSS} Unknown option: $1${RESET}"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo -e "${CYAN}${BOLD}Ghostty Themes Installer${RESET}"
    echo -e "${WHITE}Usage: $0 [OPTIONS]${RESET}"
    echo -e "${GRAY}Options:${RESET}"
    echo -e "  ${GREEN}--dry-run${RESET}     ${DIM}Show what would be done without making changes${RESET}"
    echo -e "  ${GREEN}--verbose, -v${RESET}  ${DIM}Enable verbose output${RESET}"
    echo -e "  ${GREEN}--help, -h${RESET}      ${DIM}Show this help message${RESET}"
}

# --- Utility Functions ---
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${DIM}[VERBOSE] $1${RESET}"
    fi
}

log_info() {
    echo -e "${BLUE}${INFO} $1${RESET}"
}

log_success() {
    echo -e "${GREEN}${CHECKMARK} $1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}${WARNING} $1${RESET}"
}

log_error() {
    echo -e "${RED}${CROSS} $1${RESET}"
}

log_dry_run() {
    echo -e "${PURPLE}${INFO} [DRY RUN] $1${RESET}"
}

# --- Input Validation ---
validate_choice() {
    local choice="$1"
    local max_choice="$2"
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        log_error "Invalid input. Please enter a number."
        return 1
    fi
    
    if [ "$choice" -lt 1 ] || [ "$choice" -gt "$max_choice" ]; then
        log_error "Invalid choice. Please enter a number between 1 and $max_choice."
        return 1
    fi
    
    return 0
}

confirm_action() {
    local message="$1"
    local default="${2:-n}"
    local response
    local prompt

    if [[ "$default" =~ ^[Yy]$ ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    while true; do
        read -r -p "$(echo -e "${CYAN}$message ${DIM}$prompt${RESET} ")" response
        response=${response:-$default}

        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                log_error "Invalid response. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

# --- Banner ---
print_banner() {
    echo -e "${PURPLE}${BOLD}
╔══════════════════════════════════════════════════════════════╗
║         ${GHOST} ${WHITE}Welcome to the Ghostty Themes Installer ${SPARKLES}${PURPLE}          ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}${WARNING} Running in dry-run mode. No files will be changed. ${WARNING}${RESET}"
        echo
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${DIM}Verbose mode enabled${RESET}"
        echo
    fi
}

# --- Directory Operations ---
create_dir() {
    local dir="$1"
    log_verbose "Checking directory: $dir"
    
    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would create directory: $dir"
        return 0
    fi
    
    if [ ! -d "$dir" ]; then
        if mkdir -p "$dir" 2>/dev/null; then
            log_success "Created directory: $dir"
        else
            log_error "Failed to create directory: $dir"
            return 1
        fi
    else
        log_verbose "Directory already exists: $dir"
    fi
    return 0
}

create_backup_dir() {
    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would create backup directory: $BACKUP_DIR"
        return 0
    fi
    
    if [ ! -d "$BACKUP_DIR" ]; then
        if mkdir -p "$BACKUP_DIR" 2>/dev/null; then
            log_success "Created backup directory: $BACKUP_DIR"
        else
            log_error "Failed to create backup directory: $BACKUP_DIR"
            return 1
        fi
    fi
    return 0
}

# --- File Operations ---
backup_file() {
    local file="$1"
    local backup_name="$(basename "$file")"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -f "$file" ]; then
        log_verbose "No existing file to backup: $file"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would backup $file to $backup_path"
        return 0
    fi

    create_backup_dir
    if cp "$file" "$backup_path" 2>/dev/null; then
        log_warning "Backed up existing file: $file -> $backup_path"
    else
        log_error "Failed to backup file: $file"
        return 1
    fi
    return 0
}

copy_file() {
    local src="$1"
    local dest="$2"
    local description="$3"

    log_verbose "Copying: $src -> $dest"

    if [ ! -f "$src" ]; then
        log_error "Source file not found: $src"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would copy $src to $dest"
        return 0
    fi

    local dest_dir="$(dirname "$dest")"
    create_dir "$dest_dir"

    if cp "$src" "$dest" 2>/dev/null; then
        log_success "${description:-File} installed successfully: $(basename "$dest")"
    else
        log_error "Failed to copy ${description:-file}: $src"
        return 1
    fi
    return 0
}

install_all_files() {
    local src_dir="$1"
    local dest_dir="$2"
    local description="$3"
    local count=0
    local success_count=0

    if [ ! -d "$src_dir" ]; then
        log_error "Source directory not found: $src_dir"
        return 1
    fi

    log_info "Installing all $description from $src_dir..."

    for file in "$src_dir"/*; do
        if [ -f "$file" ]; then
            count=$((count + 1))
            local filename="$(basename "$file")"
            local dest_file="$dest_dir/$filename"
            
            if copy_file "$file" "$dest_file" "$filename"; then
                success_count=$((success_count + 1))
            fi
        fi
    done

    if [ $count -eq 0 ]; then
        log_warning "No files found in $src_dir"
        return 1
    fi

    log_success "Installed $success_count out of $count $description"
    return 0
}

# --- Configuration Updates ---
update_ghostty_config() {
    local theme_name="$1"
    local tabs_location="$2"
    local config_file="$GHOSTTY_CONFIG_DIR/config"
    local theme_path="$THEMES_DIR/$theme_name"

    log_verbose "Updating Ghostty config: theme=$theme_name, tabs=$tabs_location"

    if [ ! -f "$config_file" ]; then
        log_warning "Ghostty config file not found at: $config_file"
        if ! confirm_action "Create a new Ghostty config file?"; then
            return 1
        fi
        
        if [ "$DRY_RUN" = true ]; then
            log_dry_run "Would create new Ghostty config file"
            return 0
        fi
        
        create_dir "$GHOSTTY_CONFIG_DIR"
        touch "$config_file"
    fi

    if ! confirm_action "Update Ghostty config to use theme '$theme_name'?"; then
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would update Ghostty config with theme: $theme_name"
        log_dry_run "Would set tabs location to: $tabs_location"
        return 0
    fi

    backup_file "$config_file"

    if grep -q "^gtk-custom-css =" "$config_file"; then
        sed -i "s#^gtk-custom-css = .*#gtk-custom-css = $theme_path#" "$config_file"
        log_verbose "Updated existing gtk-custom-css setting"
    else
        echo "gtk-custom-css = $theme_path" >> "$config_file"
        log_verbose "Added new gtk-custom-css setting"
    fi

    if grep -q "^gtk-tabs-location =" "$config_file"; then
        sed -i "s#^gtk-tabs-location = .*#gtk-tabs-location = $tabs_location#" "$config_file"
        log_verbose "Updated existing gtk-tabs-location setting"
    else
        echo "gtk-tabs-location = $tabs_location" >> "$config_file"
        log_verbose "Added new gtk-tabs-location setting"
    fi

    log_success "Ghostty config updated successfully!"
    return 0
}

update_matugen_config() {
    local template_name="$1"
    local config_file="$MATUGEN_CONFIG_DIR/config.toml"
    local template_path="$TEMPLATES_DIR/$template_name"
    local output_path="$THEMES_DIR/matugen.css"

    log_verbose "Updating Matugen config: template=$template_name"

    if [ ! -f "$config_file" ]; then
        log_warning "Matugen config file not found at: $config_file"
        if ! confirm_action "Create a new Matugen config file?"; then
            return 1
        fi
        
        if [ "$DRY_RUN" = true ]; then
            log_dry_run "Would create new Matugen config file"
            return 0
        fi
        
        create_dir "$MATUGEN_CONFIG_DIR"
        touch "$config_file"
    fi

    if ! confirm_action "Update Matugen config to use template '$template_name'?"; then
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would update Matugen config to use template: $template_name"
        return 0
    fi

    backup_file "$config_file"

    if grep -q "^\\[templates\\.ghostty\\]" "$config_file"; then
        sed -i "/^\\[templates\\.ghostty\\]/,/^\\[/ {
            s#input_path = .*#input_path = \"$template_path\"#
            s#output_path = .*#output_path = \"$output_path\"#
        }" "$config_file"
        log_verbose "Updated existing Matugen ghostty template section"
    else
        {
            echo ""
            echo "[templates.ghostty]"
            echo "input_path = \"$template_path\""
            echo "output_path = \"$output_path\""
            echo "post_hook = \"ydotool key 29:1 42:1 51:1 51:0 42:0 29:0\""
        } >> "$config_file"
        log_verbose "Added new Matugen ghostty template section"
    fi

    log_success "Matugen config updated successfully!"
    log_info "Run 'matugen' to generate the theme with your current wallpaper"
    return 0
}

# --- Menu Functions ---
show_main_menu() {
    echo -e "${BOLD}${CYAN}
╔══════════════════════════════════════════════════════════════╗
║                         ${WHITE}Main Menu${CYAN}                         ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    echo -e "${GREEN}1)${RESET} Install Default Themes"
    echo -e "${GREEN}2)${RESET} Install Matugen Templates"
    echo -e "${GREEN}3)${RESET} Install Config Files"
    echo -e "${GREEN}4)${RESET} Install Everything"
    echo -e "${GREEN}5)${RESET} Manage Existing Installations"
    echo -e "${GREEN}6)${RESET} Show System Information"
    echo -e "${RED}7)${RESET} Exit"
    echo
}

show_theme_menu() {
    echo -e "${BOLD}${BLUE}
╔══════════════════════════════════════════════════════════════╗
║                      ${WHITE}Default Themes${BLUE}                       ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    echo -e "${GREEN}1)${RESET} Ghostty-Tabs.css ${DIM}(Tabs on top)${RESET}"
    echo -e "${GREEN}2)${RESET} Ghostty.css ${DIM}(Standard - Tabs on bottom)${RESET}"
    echo -e "${GREEN}3)${RESET} Install All Default Themes"
    echo -e "${GREEN}4)${RESET} Preview Theme File"
    echo -e "${YELLOW}5)${RESET} Back to Main Menu"
    echo
}

show_template_menu() {
    echo -e "${BOLD}${PURPLE}
╔══════════════════════════════════════════════════════════════╗
║                    ${WHITE}Matugen Templates${PURPLE}                     ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    echo -e "${GREEN}1)${RESET} Ghostty-matugen-tabs-top.css ${DIM}(Tabs on top)${RESET}"
    echo -e "${GREEN}2)${RESET} Ghostty-matugen-tabs.css ${DIM}(Tabs on bottom)${RESET}"
    echo -e "${GREEN}3)${RESET} Ghostty-matugen.css ${DIM}(Standard)${RESET}"
    echo -e "${GREEN}4)${RESET} Install All Matugen Templates"
    echo -e "${GREEN}5)${RESET} Preview Template File"
    echo -e "${YELLOW}6)${RESET} Back to Main Menu"
    echo
}

show_config_menu() {
    echo -e "${BOLD}${YELLOW}
╔══════════════════════════════════════════════════════════════╗
║                       ${WHITE}Config Files${YELLOW}                        ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    echo -e "${GREEN}1)${RESET} Ghostty Config"
    echo -e "${GREEN}2)${RESET} Matugen Config"
    echo -e "${GREEN}3)${RESET} Install All Config Files"
    echo -e "${GREEN}4)${RESET} Preview Config File"
    echo -e "${YELLOW}5)${RESET} Back to Main Menu"
    echo
}

show_manage_menu() {
    echo -e "${BOLD}${CYAN}
╔══════════════════════════════════════════════════════════════╗
║                  ${WHITE}Manage Installations${CYAN}                  ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    echo -e "${GREEN}1)${RESET} List Installed Themes"
    echo -e "${GREEN}2)${RESET} List Installed Templates"
    echo -e "${GREEN}3)${RESET} Remove Themes"
    echo -e "${GREEN}4)${RESET} Remove Templates"
    echo -e "${GREEN}5)${RESET} Restore from Backup"
    echo -e "${GREEN}6)${RESET} Clean Up Old Backups"
    echo -e "${YELLOW}7)${RESET} Back to Main Menu"
    echo
}

# --- System Information ---
show_system_info() {
    echo -e "${BOLD}${CYAN}
╔══════════════════════════════════════════════════════════════╗
║                    ${WHITE}System Information${CYAN}                    ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
    echo -e "${BLUE}Ghostty Config Directory:${RESET} $GHOSTTY_CONFIG_DIR"
    echo -e "${BLUE}Matugen Config Directory:${RESET} $MATUGEN_CONFIG_DIR"
    echo -e "${BLUE}Themes Directory:${RESET} $THEMES_DIR"
    echo -e "${BLUE}Templates Directory:${RESET} $TEMPLATES_DIR"
    echo -e "${BLUE}Repository Root:${RESET} $REPO_ROOT"
    echo -e "${BLUE}Backup Directory:${RESET} $BACKUP_DIR"
    echo
    
    local dirs=("$GHOSTTY_CONFIG_DIR" "$MATUGEN_CONFIG_DIR" "$THEMES_DIR" "$TEMPLATES_DIR")
    local dir_names=("Ghostty Config" "Matugen Config" "Themes" "Templates")
    
    for i in "${!dirs[@]}"; do
        if [ -d "${dirs[$i]}" ]; then
            echo -e "${GREEN}${CHECKMARK} ${dir_names[$i]} directory exists${RESET}"
        else
            echo -e "${RED}${CROSS} ${dir_names[$i]} directory missing${RESET}"
        fi
    done
    
    echo
    echo -e "${DIM}Press Enter to return to the main menu...${RESET}"
    read -r
}

# --- File Management ---
list_files() {
    local dir="$1"
    local type="$2"
    
    if [ ! -d "$dir" ]; then
        log_warning "No $type directory found"
        return 1
    fi
    
    local files=("$dir"/*)
    if [ ${#files[@]} -eq 1 ] && [ ! -f "${files[0]}" ]; then
        log_warning "No $type files found"
        return 1
    fi
    
    echo -e "${BOLD}${BLUE}Installed $type:${RESET}"
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}${CHECKMARK} $(basename "$file")${RESET}"
        fi
    done
    echo
}

preview_file() {
    local file="$1"
    local lines="${2:-20}"
    
    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi
    
    echo -e "${BOLD}${CYAN}Preview of $(basename "$file"):${RESET}"
    echo -e "${DIM}$(head -n "$lines" "$file")${RESET}"
    
    local total_lines
    total_lines=$(wc -l < "$file")
    if [ "$total_lines" -gt "$lines" ]; then
        echo -e "${DIM}... (showing first $lines of $total_lines lines)${RESET}"
    fi
    echo
}

remove_files() {
    local dir="$1"
    local type="$2"
    
    if [ ! -d "$dir" ]; then
        log_warning "No $type directory found"
        return 1
    fi
    
    list_files "$dir" "$type"
    
    if ! confirm_action "Are you sure you want to remove all $type files?"; then
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would remove all files from $dir"
        return 0
    fi
    
    local count=0
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            if rm "$file" 2>/dev/null; then
                count=$((count + 1))
                log_success "Removed $(basename "$file")"
            else
                log_error "Failed to remove $(basename "$file")"
            fi
        fi
    done
    
    log_success "Removed $count $type files"
}

# --- Enhanced Menu Handlers ---
handle_theme_menu() {
    while true; do
        clear
        show_theme_menu
        local choice
        read -r -p "$(echo -e "${CYAN}Enter your choice: ${RESET}")" choice
        choice="${choice//[^[:digit:]]/}" # Sanitize input
        
        if ! validate_choice "$choice" 5; then
            echo -e "\n${DIM}Press Enter to try again...${RESET}"
            read -r
            continue
        fi
        
        clear
        case $choice in
            1)
                if copy_file "$REPO_ROOT/Default-Themes/Ghostty-Tabs.css" "$THEMES_DIR/Ghostty-Tabs.css" "Ghostty-Tabs.css"; then
                    update_ghostty_config "Ghostty-Tabs.css" "top"
                fi
                log_success "Done!"
                ;;
            2)
                if copy_file "$REPO_ROOT/Default-Themes/Ghostty.css" "$THEMES_DIR/Ghostty.css" "Ghostty.css"; then
                    update_ghostty_config "Ghostty.css" "bottom"
                fi
                log_success "Done!"
                ;;
            3)
                install_all_files "$REPO_ROOT/Default-Themes" "$THEMES_DIR" "default themes"
                log_info "You can now manually update your Ghostty config to use one of the installed themes"
                log_success "Done!"
                ;;
            4)
                echo -e "${CYAN}Available theme files:${RESET}"
                for file in "$REPO_ROOT/Default-Themes"/*; do
                    if [ -f "$file" ]; then
                        echo -e "${GREEN}$(basename "$file")${RESET}"
                    fi
                done
                echo
                local filename
                read -r -p "$(echo -e "${CYAN}Enter filename to preview: ${RESET}")" filename
                preview_file "$REPO_ROOT/Default-Themes/$filename"
                ;;
            5)
                return
                ;;
        esac

        echo -e "\n${DIM}Press Enter to return to the theme menu...${RESET}"
        read -r
    done
}

handle_template_menu() {
    while true; do
        clear
        show_template_menu
        local choice
        read -r -p "$(echo -e "${CYAN}Enter your choice: ${RESET}")" choice
        choice="${choice//[^[:digit:]]/}" # Sanitize input
        
        if ! validate_choice "$choice" 6; then
            echo -e "\n${DIM}Press Enter to try again...${RESET}"
            read -r
            continue
        fi
        
        clear
        case $choice in
            1)
                if copy_file "$REPO_ROOT/Matugen-Templates/Ghostty-matugen-tabs-top.css" "$TEMPLATES_DIR/Ghostty-matugen-tabs-top.css" "Ghostty-matugen-tabs-top.css"; then
                    update_matugen_config "Ghostty-matugen-tabs-top.css"
                    update_ghostty_config "matugen.css" "top"
                fi
                log_success "Done!"
                ;;
            2)
                if copy_file "$REPO_ROOT/Matugen-Templates/Ghostty-matugen-tabs.css" "$TEMPLATES_DIR/Ghostty-matugen-tabs.css" "Ghostty-matugen-tabs.css"; then
                    update_matugen_config "Ghostty-matugen-tabs.css"
                    update_ghostty_config "matugen.css" "bottom"
                fi
                log_success "Done!"
                ;;
            3)
                if copy_file "$REPO_ROOT/Matugen-Templates/Ghostty-matugen.css" "$TEMPLATES_DIR/Ghostty-matugen.css" "Ghostty-matugen.css"; then
                    update_matugen_config "Ghostty-matugen.css"
                    update_ghostty_config "matugen.css" "bottom"
                fi
                log_success "Done!"
                ;;
            4)
                install_all_files "$REPO_ROOT/Matugen-Templates" "$TEMPLATES_DIR" "Matugen templates"
                log_info "You can now manually update your Matugen and Ghostty configs"
                log_success "Done!"
                ;;
            5)
                echo -e "${CYAN}Available template files:${RESET}"
                for file in "$REPO_ROOT/Matugen-Templates"/*; do
                    if [ -f "$file" ]; then
                        echo -e "${GREEN}$(basename "$file")${RESET}"
                    fi
                done
                echo
                local filename
                read -r -p "$(echo -e "${CYAN}Enter filename to preview: ${RESET}")" filename
                preview_file "$REPO_ROOT/Matugen-Templates/$filename"
                ;;
            6)
                return
                ;;
        esac

        echo -e "\n${DIM}Press Enter to return to the template menu...${RESET}"
        read -r
    done
}

handle_config_menu() {
    while true; do
        clear
        show_config_menu
        local choice
        read -r -p "$(echo -e "${CYAN}Enter your choice: ${RESET}")" choice
        choice="${choice//[^[:digit:]]/}" # Sanitize input
        
        if ! validate_choice "$choice" 5; then
            echo -e "\n${DIM}Press Enter to try again...${RESET}"
            read -r
            continue
        fi
        
        clear
        case $choice in
            1)
                backup_file "$GHOSTTY_CONFIG_DIR/config"
                copy_file "$REPO_ROOT/configs/config-Ghostty" "$GHOSTTY_CONFIG_DIR/config" "Ghostty Config"
                log_success "Done!"
                ;;
            2)
                backup_file "$MATUGEN_CONFIG_DIR/config.toml"
                copy_file "$REPO_ROOT/configs/config.toml" "$MATUGEN_CONFIG_DIR/config.toml" "Matugen Config"
                log_success "Done!"
                ;;
            3)
                backup_file "$GHOSTTY_CONFIG_DIR/config"
                copy_file "$REPO_ROOT/configs/config-Ghostty" "$GHOSTTY_CONFIG_DIR/config" "Ghostty Config"
                backup_file "$MATUGEN_CONFIG_DIR/config.toml"
                copy_file "$REPO_ROOT/configs/config.toml" "$MATUGEN_CONFIG_DIR/config.toml" "Matugen Config"
                log_success "Done!"
                ;;
            4)
                echo -e "${CYAN}Available config files:${RESET}"
                echo -e "${GREEN}config-Ghostty${RESET}"
                echo -e "${GREEN}config.toml${RESET}"
                echo
                local filename
                read -r -p "$(echo -e "${CYAN}Enter filename to preview: ${RESET}")" filename
                preview_file "$REPO_ROOT/configs/$filename"
                ;;
            5)
                return
                ;;
        esac

        echo -e "\n${DIM}Press Enter to return to the config menu...${RESET}"
        read -r
    done
}

handle_manage_menu() {
    while true; do
        clear
        show_manage_menu
        local choice
        read -r -p "$(echo -e "${CYAN}Enter your choice: ${RESET}")" choice
        choice="${choice//[^[:digit:]]/}" # Sanitize input
        
        if ! validate_choice "$choice" 7; then
            echo -e "\n${DIM}Press Enter to try again...${RESET}"
            read -r
            continue
        fi
        
        clear
        case $choice in
            1)
                list_files "$THEMES_DIR" "themes"
                ;;
            2)
                list_files "$TEMPLATES_DIR" "templates"
                ;;
            3)
                remove_files "$THEMES_DIR" "themes"
                log_success "Done!"
                ;;
            4)
                remove_files "$TEMPLATES_DIR" "templates"
                log_success "Done!"
                ;;
            5)
                log_info "Backup directory: $BACKUP_DIR"
                if [ -d "$BACKUP_DIR" ]; then
                    list_files "$BACKUP_DIR" "backup files"
                    log_info "Manually copy files from backup directory to restore them"
                else
                    log_warning "No backup directory found"
                fi
                ;;
            6)
                log_info "Cleaning up old backups..."
                local backup_base="$HOME/.config/ghostty_themes_backup_*"
                local count=0
                for backup_dir in $backup_base; do
                    if [ -d "$backup_dir" ] && [ "$backup_dir" != "$BACKUP_DIR" ]; then
                        if confirm_action "Remove old backup directory $(basename "$backup_dir")?"; then
                            if [ "$DRY_RUN" = true ]; then
                                log_dry_run "Would remove $backup_dir"
                            else
                                rm -rf "$backup_dir"
                                log_success "Removed old backup: $(basename "$backup_dir")"
                            fi
                            count=$((count + 1))
                        fi
                    fi
                done
                if [ $count -eq 0 ]; then
                    log_info "No old backups found to clean up"
                fi
                log_success "Done!"
                ;;
            7)
                return
                ;;
        esac
        
        echo -e "\n${DIM}Press Enter to return to the management menu...${RESET}"
        read -r
    done
}

# --- Main Logic ---
main() {
    parse_args "$@"
    clear
    print_banner
    
    create_dir "$GHOSTTY_CONFIG_DIR"
    create_dir "$MATUGEN_CONFIG_DIR"
    create_dir "$THEMES_DIR"
    create_dir "$TEMPLATES_DIR"
    echo

    while true; do
        clear
        show_main_menu
        local choice
        read -r -p "$(echo -e "${CYAN}Enter your choice: ${RESET}")" choice
        # Sanitize input to remove any non-digit characters (like carriage returns)
        choice="${choice//[^[:digit:]]/}"
        
        if ! validate_choice "$choice" 7; then
            echo -e "\n${DIM}Press Enter to try again...${RESET}"
            read -r
            continue
        fi

        case $choice in
            1)
                handle_theme_menu
                ;;
            2)
                handle_template_menu
                ;;
            3)
                handle_config_menu
                ;;
            4) 
                clear
                log_info "Installing everything..."
                echo
                
                if install_all_files "$REPO_ROOT/Default-Themes" "$THEMES_DIR" "default themes"; then
                    log_success "All default themes installed"
                fi
                
                if install_all_files "$REPO_ROOT/Matugen-Templates" "$TEMPLATES_DIR" "Matugen templates"; then
                    log_success "All Matugen templates installed"
                fi
                
                if confirm_action "Install Ghostty config file?"; then
                    backup_file "$GHOSTTY_CONFIG_DIR/config"
                    copy_file "$REPO_ROOT/configs/config-Ghostty" "$GHOSTTY_CONFIG_DIR/config" "Ghostty Config"
                fi
                
                if confirm_action "Install Matugen config file?"; then
                    backup_file "$MATUGEN_CONFIG_DIR/config.toml"
                    copy_file "$REPO_ROOT/configs/config.toml" "$MATUGEN_CONFIG_DIR/config.toml" "Matugen Config"
                fi
                
                echo
                log_success "Installation complete!"
                log_info "You can now manually update your Ghostty and Matugen configs to use the installed themes"
                echo -e "\n${DIM}Press Enter to return to the main menu...${RESET}"
                read -r
                ;;
            5) 
                handle_manage_menu
                ;;
            6) 
                clear
                show_system_info
                ;;
            7) 
                clear
                echo -e "${PURPLE}${BOLD}
╔══════════════════════════════════════════════════════════════╗
║      ${ROCKET} ${WHITE}Thanks for using Ghostty Themes Installer!${SPARKLES} ${PURPLE}      ║
║                                                              ║
║    ${WHITE}Your themes are ready to make your terminal awesome!${PURPLE}     ║
╚══════════════════════════════════════════════════════════════╝${RESET}
"
                exit 0
                ;;
        esac
    done
}

# --- Error Handling ---
set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

# --- Entry Point ---
main "$@"
