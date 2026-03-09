# modules/kde-theme.sh - KDE Plasma Dark Teal rice

MODULE_NAME="kde-theme"
MODULE_DESCRIPTION="Dark Teal frosted glass KDE Plasma theme"

module_check() {
    [ -n "$KDE_SESSION_VERSION" ] || [ "$XDG_CURRENT_DESKTOP" = "KDE" ]
}

module_install() { return 0; }
module_update() { return 0; }
module_uninstall() { return 0; }

module_config() {
    module_check || return 0

    # Install DarkTeal color scheme
    mkdir -p "$HOME/.local/share/color-schemes"
    cp "$SCRIPT_DIR/config/kde/DarkTeal.colors" "$HOME/.local/share/color-schemes/DarkTeal.colors"
    info "Installed DarkTeal color scheme"

    # Enable KWin blur
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 12
    kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 2
    info "Enabled KWin blur (strength 12, noise 2)"

    # Enable Edna contrast effect for frosted panels
    local edna_rc="$HOME/.local/share/plasma/desktoptheme/Edna/plasmarc"
    if [ -f "$edna_rc" ]; then
        kwriteconfig6 --file "$edna_rc" --group ContrastEffect --key enabled true
        info "Enabled Edna ContrastEffect"
    fi

    # Apply color scheme to kdeglobals
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme DarkTeal
    info "Set active color scheme to DarkTeal"

    # Reload KWin
    if command -v qdbus6 &>/dev/null; then
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null && info "Reloaded KWin"
    elif command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null && info "Reloaded KWin"
    fi
}

module_aliases() { :; }
module_functions() { :; }
module_env() { :; }
module_paths() { :; }
