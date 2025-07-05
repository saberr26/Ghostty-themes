#!/bin/bash

# Enhanced Ghostty Themes Installer
# More automated, safer, and fun!

set -euo pipefail  # Exit on error, undefined vars, pipe failures

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

# --- Fancy UI Elements ---
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
BACKUP_DIR="$HOME/.config/ghostty-themes-backup-$(date +%Y%m%d_%H%M%S)"

# --- Logging ---
LOG_FILE="$HOME/.config/ghostty-installer.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# --- Display Functions ---
print_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║  ${GHOST} ${WHITE}GHOSTTY THEMES INSTALLER${PURPLE} ${SPARKLES}                        ║"
    echo "  ║  ${CYAN}Enhanced • Automated • Safe • Fun${PURPLE}                     ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}${ARROW} $1${NC}"
}

print_step() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

animate_progress() {
    local duration=$1
    local message=$2
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    
    for ((i=0; i<duration; i++)); do
        for ((j=0; j<${#progress_chars}; j++)); do
            echo -ne "\r${CYAN}${progress_chars:$j:1} ${message}${NC}"
            sleep 0.1
        done
    done
    echo -ne "\r${GREEN}${CHECKMARK} ${message}${NC}\n"
}

# --- Safety Functions ---
create_backup() {
    if [[ -d "$GHOSTTY_CONFIG_DIR" ]]; then
        print_step "Creating backup..."
        mkdir -p "$BACKUP_DIR"
        cp -r "$GHOSTTY_CONFIG_DIR" "$BACKUP_DIR/ghostty" 2>/dev/null || true
        [[ -d "$MATUGEN_CONFIG_DIR" ]] && cp -r "$MATUGEN_CONFIG_DIR" "$BACKUP_DIR/matugen" 2>/dev/null || true
        print_success "Backup created at: $BACKUP_DIR"
        log "Backup created at: $BACKUP_DIR"
    fi
}

validate_repo_structure() {
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
        exit 1
    fi
}

check_dependencies() {
    local deps=("cp" "mkdir" "mv")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# --- Core Installation Functions ---
create_directories() {
    print_step "Setting up directories..."
    
    local dirs=("$THEMES_DIR" "$TEMPLATES_DIR" "$(dirname "$LOG_FILE")")
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_success "Created: $dir"
            log "Created directory: $dir"
        fi
    done
}

install_themes() {
    print_step "Installing default themes..."
    
    local theme_count=0
    for theme in "$REPO_ROOT/Default-Themes"/*; do
        if [[ -f "$theme" ]]; then
            local theme_name=$(basename "$theme")
            cp "$theme" "$THEMES_DIR/"
            print_success "Installed: $theme_name"
            log "Installed theme: $theme_name"
            ((theme_count++))
        fi
    done
    
    print_info "Installed $theme_count default themes"
}

install_matugen_templates() {
    print_step "Installing Matugen templates..."
    
    local template_count=0
    for template in "$REPO_ROOT/Matugen-Templates"/*; do
        if [[ -f "$template" ]]; then
            local template_name=$(basename "$template")
            cp "$template" "$TEMPLATES_DIR/"
            print_success "Installed: $template_name"
            log "Installed template: $template_name"
            ((template_count++))
        fi
    done
    
    print_info "Installed $template_count Matugen templates"
}

install_configs() {
    print_step "Installing configuration files..."
    
    # Install Ghostty config
    local ghostty_config="$GHOSTTY_CONFIG_DIR/config"
    if [[ -f "$ghostty_config" ]]; then
        print_warning "Backing up existing Ghostty config"
        mv "$ghostty_config" "$ghostty_config.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp "$REPO_ROOT/configs/config-Ghostty" "$ghostty_config"
    print_success "Installed Ghostty config"
    log "Installed Ghostty config"
    
    # Install Matugen config
    local matugen_config="$MATUGEN_CONFIG_DIR/config.toml"
    if [[ -f "$matugen_config" ]]; then
        print_warning "Backing up existing Matugen config"
        mv "$matugen_config" "$matugen_config.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp "$REPO_ROOT/configs/config.toml" "$matugen_config"
    print_success "Installed Matugen config"
    log "Installed Matugen config"
}

# --- Interactive Functions ---
show_installation_summary() {
    print_step "Installation Summary:"
    echo ""
    echo -e "${WHITE}${BOLD}Themes installed:${NC}"
    for theme in "$THEMES_DIR"/*; do
        [[ -f "$theme" ]] && echo -e "  ${GREEN}${CHECKMARK}${NC} $(basename "$theme")"
    done
    
    echo ""
    echo -e "${WHITE}${BOLD}Templates installed:${NC}"
    for template in "$TEMPLATES_DIR"/*; do
        [[ -f "$template" ]] && echo -e "  ${GREEN}${CHECKMARK}${NC} $(basename "$template")"
    done
    
    echo ""
    echo -e "${WHITE}${BOLD}Configs installed:${NC}"
    [[ -f "$GHOSTTY_CONFIG_DIR/config" ]] && echo -e "  ${GREEN}${CHECKMARK}${NC} Ghostty config"
    [[ -f "$MATUGEN_CONFIG_DIR/config.toml" ]] && echo -e "  ${GREEN}${CHECKMARK}${NC} Matugen config"
}

show_usage_instructions() {
    echo ""
    echo -e "${YELLOW}${BOLD}${STAR} USAGE INSTRUCTIONS ${STAR}${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}1. For Default Themes:${NC}"
    echo -e "   Edit ${CYAN}~/.config/ghostty/config${NC} and set:"
    echo -e "   ${GREEN}gtk-custom-css = ~/.config/ghostty/themes/Ghostty-Tabs.css${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}2. For Matugen Themes:${NC}"
    echo -e "   Run ${CYAN}matugen image /path/to/your/wallpaper.jpg${NC}"
    echo -e "   The theme will be generated at: ${GREEN}~/.config/ghostty/themes/matugen.css${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}3. Available Default Themes:${NC}"
    for theme in "$THEMES_DIR"/*.css; do
        [[ -f "$theme" ]] && echo -e "   ${PURPLE}•${NC} $(basename "$theme")"
    done
    echo ""
    echo -e "${WHITE}${BOLD}4. Available Matugen Templates:${NC}"
    for template in "$TEMPLATES_DIR"/*.css; do
        [[ -f "$template" ]] && echo -e "   ${PURPLE}•${NC} $(basename "$template")"
    done
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}${SPARKLES} Happy theming! ${SPARKLES}${NC}"
}

ask_confirmation() {
    echo ""
    echo -e "${YELLOW}${BOLD}This will install all themes, templates, and configs.${NC}"
    echo -e "${YELLOW}Any existing configs will be backed up.${NC}"
    echo ""
    echo -e "${WHITE}Do you want to proceed? ${GREEN}[Y/n]${NC}"
    read -r -n 1 response
    echo ""
    
    case "$response" in
        [nN]) 
            echo -e "${RED}Installation cancelled.${NC}"
            exit 0
            ;;
        *)
            return 0
            ;;
    esac
}

# --- Main Installation Flow ---
main() {
    print_header
    
    # Pre-flight checks
    print_step "Running pre-flight checks..."
    check_dependencies
    validate_repo_structure
    print_success "All checks passed!"
    
    # Show confirmation
    ask_confirmation
    
    # Create backup
    create_backup
    
    # Installation steps with progress animation
    animate_progress 2 "Preparing installation..."
    
    create_directories
    install_themes
    install_matugen_templates
    install_configs
    
    # Final steps
    animate_progress 2 "Finalizing installation..."
    
    log "Installation completed successfully"
    
    # Show results
    echo ""
    echo -e "${GREEN}${BOLD}${ROCKET} INSTALLATION COMPLETE! ${ROCKET}${NC}"
    echo ""
    
    show_installation_summary
    show_usage_instructions
    
    echo ""
    echo -e "${PURPLE}${BOLD}Log file: ${NC}${LOG_FILE}"
    echo -e "${PURPLE}${BOLD}Backup location: ${NC}${BACKUP_DIR}"
}

# --- Error Handling ---
cleanup() {
    if [[ $? -ne 0 ]]; then
        print_error "Installation failed! Check the log file: $LOG_FILE"
        if [[ -d "$BACKUP_DIR" ]]; then
            print_info "You can restore from backup: $BACKUP_DIR"
        fi
    fi
}

trap cleanup EXIT

# --- Script Entry Point ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
