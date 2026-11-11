# =============================================================================
# ~/.config/fish/config.fish
# =============================================================================

# Disable default Fish greeting
set -g fish_greeting

# -----------------------------------------------------------------------------
# 1. Environment Variables
# -----------------------------------------------------------------------------
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
set -gx GTK_MODULES "unity-gtk-module"
set -gx QT_QPA_PLATFORMTHEME "qt6ct"
set -gx DOTNET_ROOT "$HOME/.dotnet"
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx BUN_INSTALL "$HOME/.bun"
set -gx DENO_INSTALL "$HOME/.deno"

# Load private secrets if the file exists
if test -f ~/.secrets.fish
    source ~/.secrets.fish
end

# -----------------------------------------------------------------------------
# 2. PATH Configuration
# fish_add_path automatically deduplicates and checks existence
# -----------------------------------------------------------------------------
fish_add_path \
    $HOME/.local/bin \
    $PNPM_HOME/bin \
    $HOME/.rbenv/bin \
    $BUN_INSTALL/bin \
    $DENO_INSTALL/bin \
    $HOME/.config/emacs/bin \
    $HOME/.opencode/bin \
    $HOME/.spicetify \
    $HOME/.cargo/bin \
    $HOME/.dotnet \
    $HOME/go/bin

# Linuxbrew
if test -d /home/linuxbrew/.linuxbrew/bin
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# -----------------------------------------------------------------------------
# 3. Tool Initializations
# -----------------------------------------------------------------------------
# rbenv
if type -q rbenv
    rbenv init - fish | source
end

# Starship Prompt
if type -q starship
    starship init fish | source
end

# -----------------------------------------------------------------------------
# 4. Aliases
# -----------------------------------------------------------------------------
alias code='code --enable-features=UseOzonePlatform'

# -----------------------------------------------------------------------------
# 5. Functions
# -----------------------------------------------------------------------------

# Neovim smart launcher
function nv
    if test (count $argv) -eq 0
        nvim .
    else if test -d $argv[1]
        cd $argv[1]; and nvim .
    else
        nvim $argv
    end
end

# LazyVim smart launcher
function nvl
    if test (count $argv) -eq 0
        env NVIM_APPNAME=nvim-lazyvim nvim .
    else if test -d $argv[1]
        cd $argv[1]; and env NVIM_APPNAME=nvim-lazyvim nvim .
    else
        env NVIM_APPNAME=nvim-lazyvim nvim $argv
    end
end

# Yazi directory switcher (Official Fish wrapper)
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end

# 3-Tab Tmux dev workspace
function dev
    set session "work"
    if tmux has-session -t $session 2>/dev/null
        tmux attach-session -t $session
        return
    end

    tmux new-session -d -s $session -n "editor" -c (pwd)
    tmux new-window -t $session:2 -n "build" -c (pwd)
    tmux new-window -t $session:3 -n "misc" -c (pwd)

    tmux select-window -t $session:1
    tmux attach-session -t $session
end
