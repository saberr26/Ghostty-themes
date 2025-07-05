#!/bin/bash

# Enhanced Ghostty Themes Installer
# Customizable, Safe, and Fun!

# --- Color Configuration ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# --- UI Elements ---
CHECKMARK="✓"
CROSS="✗"
ARROW="➤"
STAR="★"
ROCKET="🚀"
GHOST="👻"
SPARKLES="✨"

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
MATUGEN_CONFIG_DIR="$HOME/.config/matugen"
THEMES_DIR="$GHOSTTY_CONFIG_DIR/themes"
TEMPLATES_DIR="$MATUGEN_CONFIG_DIR/templates"
LOG_FILE="$HOME/.config/ghostty-installer.log"

# --- Logging ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# --- Display Functions ---
print_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo -e "  ║  ${GHOST} ${WHITE}GHOSTTY THEMES INSTALLER${PURPLE} ${SPARKLES}                        ║"
    echo -e "  ║  ${CYAN}Enhanced • Customizable • Safe • Fun${PURPLE}                   ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} $1${NC}"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}${CROSS} $1${NC}"
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    log "WARNING: $1"
}

print_info() {
    echo -e "${BLUE}${ARROW} $1${NC}"
}

print_step() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

print_menu_header() {
    echo -e "${PURPLE}${BOLD}$1${NC}"
    echo -e "${PURPLE}$(printf '─%.0s' $(seq 1 ${#1}))${NC}"
}

# --- Safety Functions ---
create_directories() {
    print_step "Creating necessary directories..."
    
    local dirs=("$THEMES_DIR" "$TEMPLATES_DIR" "$(dirname "$LOG_FILE")")
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                print_success "Created: $dir"
            else
                print_error "Failed to create: $dir"
                return 1
            fi
        else
            print_info "Directory already exists: $dir"
        fi
    done
}

validate_repo_structure() {
    print_step "Validating repository structure..."
    
    local required_dirs=("Default-Themes" "Matugen-Templates" "configs")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$REPO_ROOT/$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        print_error "Missing required directories: ${missing_dirs[*]}"
        print_error "Please run this script from the install directory of the Ghostty themes repo."
        print_error "Current repo root: $REPO_ROOT"
        return 1
    fi
    
    print_success "Repository structure validated"
    return 0
}

backup_existing_config() {
    local config_file="$1"
    local backup_suffix=".bak.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$config_file" ]]; then
        print_warning "Backing up existing config: $(basename "$config_file")"
        if cp "$config_file" "$config_file$backup_suffix"; then
            print_success "Backup created: $config_file$backup_suffix"
        else
            print_error "Failed to create backup"
            return 1
        fi
    fi
}

# --- Installation Functions ---
install_single_theme() {
    local theme_file="$1"
    local theme_path="$REPO_ROOT/Default-Themes/$theme_file"
    
    if [[ ! -f "$theme_path" ]]; then
        print_error "Theme file not found: $theme_file"
        return 1
    fi
    
    print_step "Installing theme: $theme_file"
    
    if cp "$theme_path" "$THEMES_DIR/"; then
        print_success "Successfully installed: $theme_file"
        print_info "Location: $THEMES_DIR/$theme_file"
    else
        print_error "Failed to install: $theme_file"
        return 1
    fi
}

install_all_themes() {
    print_step "Installing all default themes..."
    
    local theme_count=0
    local failed_count=0
    
    for theme in "$REPO_ROOT/Default-Themes"/*; do
        if [[ -f "$theme" ]]; then
            local theme_name=$(basename "$theme")
            if cp "$theme" "$THEMES_DIR/"; then
                print_success "Installed: $theme_name"
                ((theme_count++))
            else
                print_error "Failed to install: $theme_name"
                ((failed_count++))
            fi
        fi
    done
    
    print_info "Successfully installed $theme_count themes"
    [[ $failed_count -gt 0 ]] && print_warning "$failed_count themes failed to install"
}

install_single_template() {
    local template_file="$1"
    local template_path="$REPO_ROOT/Matugen-Templates/$template_file"
    
    if [[ ! -f "$template_path" ]]; then
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    print_step "Installing template: $template_file"
    
    if cp "$template_path" "$TEMPLATES_DIR/"; then
        print_success "Successfully installed: $template_file"
        print_info "Location: $TEMPLATES_DIR/$template_file"
    else
        print_error "Failed to install: $template_file"
        return 1
    fi
}

install_all_templates() {
    print_step "Installing all Matugen templates..."
    
    local template_count=0
    local failed_count=0
    
    for template in "$REPO_ROOT/Matugen-Templates"/*; do
        if [[ -f "$template" ]]; then
            local template_name=$(basename "$template")
            if cp "$template" "$TEMPLATES_DIR/"; then
                print_success "Installed: $template_name"
                ((template_count++))
            else
                print_error "Failed to install: $template_name"
                ((failed_count++))
            fi
        fi
    done
    
    print_info "Successfully installed $template_count templates"
    [[ $failed_count -gt 0 ]] && print_warning "$failed_count templates failed to install"
}

install_configs() {
    print_step "Installing configuration files..."
    
    # Install Ghostty config
    local ghostty_config="$GHOSTTY_CONFIG_DIR/config"
    local ghostty_source="$REPO_ROOT/configs/config-Ghostty"
    
    if [[ ! -f "$ghostty_source" ]]; then
        print_error "Ghostty config source not found: $ghostty_source"
        return 1
    fi
    
    backup_existing_config "$ghostty_config"
    
    if cp "$ghostty_source" "$ghostty_config"; then
        print_success "Installed Ghostty config"
    else
        print_error "Failed to install Ghostty config"
        return 1
    fi
    
    # Install Matugen config
    local matugen_config="$MATUGEN_CONFIG_DIR/config.toml"
    local matugen_source="$REPO_ROOT/configs/config.toml"
    
    if [[ ! -f "$matugen_source" ]]; then
        print_error "Matugen config source not found: $matugen_source"
        return 1
    fi
    
    backup_existing_config "$matugen_config"
    
    if cp "$matugen_source" "$matugen_config"; then
        print_success "Installed Matugen config"
    else
        print_error "Failed to install Matugen config"
        return 1
    fi
}

# --- Menu Functions ---
list_themes() {
    local themes=()
    if [[ -d "$REPO_ROOT/Default-Themes" ]]; then
        while IFS= read -r -d '' theme; do
            themes+=("$(basename "$theme")")
        done < <(find "$REPO_ROOT/Default-Themes" -name "*.css" -print0)
    fi
    printf '%s\n' "${themes[@]}"
}

list_templates() {
    local templates=()
    if [[ -d "$REPO_ROOT/Matugen-Templates" ]]; then
        while IFS= read -r -d '' template; do
            templates+=("$(basename "$template")")
        done < <(find "$REPO_ROOT/Matugen-Templates" -name "*.css" -print0)
    fi
    printf '%s\n' "${templates[@]}"
}

show_themes_menu() {
    print_menu_header "Select a Default Theme to install:"
    echo ""
    
    local themes=($(list_themes))
    local i=1
    
    for theme in "${themes[@]}"; do
        echo -e "${WHITE}$i.${NC} $theme"
        ((i++))
    done
    
    echo -e "${YELLOW}$i.${NC} Install All Default Themes"
    echo -e "${CYAN}$((i+1)).${NC} Back to Main Menu"
    echo ""
    echo -e "${WHITE}Enter your choice:${NC} "
}

show_templates_menu() {
    print_menu_header "Select a Matugen Template to install:"
    echo ""
    
    local templates=($(list_templates))
    local i=1
    
    for template in "${templates[@]}"; do
        echo -e "${WHITE}$i.${NC} $template"
        ((i++))
    done
    
    echo -e "${YELLOW}$i.${NC} Install All Matugen Templates"
    echo -e "${CYAN}$((i+1)).${NC} Back to Main Menu"
    echo ""
    echo -e "${WHITE}Enter your choice:${NC} "
}

show_main_menu() {
    print_menu_header "Ghostty Themes Installer"
    echo ""
    echo -e "${WHITE}1.${NC} Install a Default Theme"
    echo -e "${WHITE}2.${NC} Install a Matugen Template"
    echo -e "${WHITE}3.${NC} Install ALL Themes and Templates"
    echo -e "${WHITE}4.${NC} Install Configuration Files"
    echo -e "${WHITE}5.${NC} Show Installation Status"
    echo -e "${WHITE}6.${NC} Show Usage Instructions"
    echo -e "${RED}7.${NC} Exit"
    echo ""
    echo -e "${WHITE}Enter your choice:${NC} "
}

show_installation_status() {
    print_step "Installation Status:"
    echo ""
    
    # Check themes
    echo -e "${WHITE}${BOLD}Default Themes:${NC}"
    if [[ -d "$THEMES_DIR" ]]; then
        local theme_count=0
        for theme in "$THEMES_DIR"/*.css; do
            if [[ -f "$theme" ]]; then
                echo -e "  ${GREEN}${CHECKMARK}${NC} $(basename "$theme")"
                ((theme_count++))
            fi
        done
        [[ $theme_count -eq 0 ]] && echo -e "  ${YELLOW}No themes installed${NC}"
    else
        echo -e "  ${RED}Themes directory not found${NC}"
    fi
    
    echo ""
    # Check templates
    echo -e "${WHITE}${BOLD}Matugen Templates:${NC}"
    if [[ -d "$TEMPLATES_DIR" ]]; then
        local template_count=0
        for template in "$TEMPLATES_DIR"/*.css; do
            if [[ -f "$template" ]]; then
                echo -e "  ${GREEN}${CHECKMARK}${NC} $(basename "$template")"
                ((template_count++))
            fi
        done
        [[ $template_count -eq 0 ]] && echo -e "  ${YELLOW}No templates installed${NC}"
    else
        echo -e "  ${RED}Templates directory not found${NC}"
    fi
    
    echo ""
    # Check configs
    echo -e "${WHITE}${BOLD}Configuration Files:${NC}"
    [[ -f "$GHOSTTY_CONFIG_DIR/config" ]] && echo -e "  ${GREEN}${CHECKMARK}${NC} Ghostty config" || echo -e "  ${RED}${CROSS}${NC} Ghostty config"
    [[ -f "$MATUGEN_CONFIG_DIR/config.toml" ]] && echo -e "  ${GREEN}${CHECKMARK}${NC} Matugen config" || echo -e "  ${RED}${CROSS}${NC} Matugen config"
}

show_usage_instructions() {
    echo ""
    echo -e "${YELLOW}${BOLD}${STAR} USAGE INSTRUCTIONS ${STAR}${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}1. For Default Themes:${NC}"
    echo -e "   Edit ${CYAN}~/.config/ghostty/config${NC} and add:"
    echo -e "   ${GREEN}gtk-custom-css = ~/.config/ghostty/themes/THEME_NAME.css${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}2. For Matugen Themes:${NC}"
    echo -e "   Run: ${CYAN}matugen image /path/to/wallpaper.jpg${NC}"
    echo -e "   Then set: ${GREEN}gtk-custom-css = ~/.config/ghostty/themes/matugen.css${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}3. Available Themes:${NC}"
    if [[ -d "$THEMES_DIR" ]]; then
        for theme in "$THEMES_DIR"/*.css; do
            [[ -f "$theme" ]] && echo -e "   ${PURPLE}•${NC} $(basename "$theme")"
        done
    fi
    echo ""
    echo -e "${WHITE}${BOLD}4. Available Templates:${NC}"
    if [[ -d "$TEMPLATES_DIR" ]]; then
        for template in "$TEMPLATES_DIR"/*.css; do
            [[ -f "$template" ]] && echo -e "   ${PURPLE}•${NC} $(basename "$template")"
        done
    fi
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}${SPARKLES} Happy theming! ${SPARKLES}${NC}"
    echo ""
    echo -e "${WHITE}Press Enter to continue...${NC}"
    read -r
}

# --- Main Script Logic ---
main() {
    # Initialize log
    log "=== Ghostty Themes Installer Started ==="
    
    while true; do
        print_header
        
        # Initial setup and validation
        if ! validate_repo_structure; then
            echo -e "${RED}Setup failed. Check the log: $LOG_FILE${NC}"
            exit 1
        fi
        
        if ! create_directories; then
            echo -e "${RED}Directory creation failed. Check the log: $LOG_FILE${NC}"
            exit 1
        fi
        
        show_main_menu
        read -r main_choice
        
        case $main_choice in
            1) # Install a Default Theme
                while true; do
                    print_header
                    show_themes_menu
                    read -r theme_choice
                    
                    local themes=($(list_themes))
                    local themes_count=${#themes[@]}
                    
                    if [[ "$theme_choice" -ge 1 && "$theme_choice" -le $themes_count ]]; then
                        install_single_theme "${themes[$((theme_choice-1))]}"
                        echo -e "${WHITE}Press Enter to continue...${NC}"
                        read -r
                        break
                    elif [[ "$theme_choice" -eq $((themes_count+1)) ]]; then
                        install_all_themes
                        echo -e "${WHITE}Press Enter to continue...${NC}"
                        read -r
                        break
                    elif [[ "$theme_choice" -eq $((themes_count+2)) ]]; then
                        break
                    else
                        print_error "Invalid choice. Please try again."
                        sleep 2
                    fi
                done
                ;;
            2) # Install a Matugen Template
                while true; do
                    print_header
                    show_templates_menu
                    read -r template_choice
                    
                    local templates=($(list_templates))
                    local templates_count=${#templates[@]}
                    
                    if [[ "$template_choice" -ge 1 && "$template_choice" -le $templates_count ]]; then
                        install_single_template "${templates[$((template_choice-1))]}"
                        echo -e "${WHITE}Press Enter to continue...${NC}"
                        read -r
                        break
                    elif [[ "$template_choice" -eq $((templates_count+1)) ]]; then
                        install_all_templates
                        echo -e "${WHITE}Press Enter to continue...${NC}"
                        read -r
                        break
                    elif [[ "$template_choice" -eq $((templates_count+2)) ]]; then
                        break
                    else
                        print_error "Invalid choice. Please try again."
                        sleep 2
                    fi
                done
                ;;
            3) # Install ALL
                print_step "Installing everything..."
                install_all_themes
                install_all_templates
                echo -e "${WHITE}Press Enter to continue...${NC}"
                read -r
                ;;
            4) # Install Configs
                install_configs
                echo -e "${WHITE}Press Enter to continue...${NC}"
                read -r
                ;;
            5) # Show Status
                print_header
                show_installation_status
                echo -e "${WHITE}Press Enter to continue...${NC}"
                read -r
                ;;
            6) # Show Instructions
                print_header
                show_usage_instructions
                ;;
            7) # Exit
                echo -e "${GREEN}${ROCKET} Thanks for using Ghostty Themes Installer! ${ROCKET}${NC}"
                log "=== Ghostty Themes Installer Ended ==="
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                sleep 2
                ;;
        esac
    done
}

# --- Error Handling ---
trap 'print_error "Script interrupted"; log "Script interrupted"; exit 1' INT TERM

# --- Entry Point ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
