# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

export PATH=/opt/homebrew/bin:$PATH

#export NVM_DIR="$HOME/.nvm"
#  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
#  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. 
#"/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim='nvim'
alias cat='bat'
alias dcu='docker compose up -d'
alias dclo='docker compose logs -f'
alias ls="eza --icons=always"
# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"
alias dc='docker compose'
alias dcubl='docker compose up -d && docker compose logs -f backend'
alias cls="printf '\33c\e[3J'"
alias gfast='gfa && gst'

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/Users/andreas.vanhelden/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# bun completions
[ -s "/Users/andreas.vanhelden/.bun/_bun" ] && source "/Users/andreas.vanhelden/.bun/_bun"

# Add user's private bin directory to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export LC_ALL=en_US.UTF-8
export PATH="$PATH:$(perl -MConfig -e 'print $Config{sitebin}')"

# local bin scripts
export PATH="$HOME/.local/bin:$PATH"

# Docker export
export COMPOSE_BAKE=true


# history setup
HISTFILE=$HOME/.zsh_history
# history on disk
SAVEHIST=100000
# current shell session
HISTSIZE=99999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

vv() {
  # Assumes all configs exist in directories named ~/.config/nvim-*
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)
 
  # If I exit fzf without selecting a config, don't open Neovim
  [[ -z $config ]] && echo "No config selected" && return
 
  # Open Neovim with the selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}

# Smart tmux starter function
# Call it something like 'tmx', 'ts' (tmux start), or even alias 'tmux' to it.
start_tmux_sensibly() {
    # Check if we're already inside a tmux session
    if [ -n "$TMUX" ]; then
        echo "Already inside a tmux session."
        # If you want to allow creating nested sessions or switching,
        # you could call `command tmux "$@"` here.
        # For now, we'll just exit, as the common case is to avoid nesting.
        return 0
    fi

    # Check if a tmux server is running and has sessions
    if tmux has-session 2>/dev/null; then
        # Server is running, and it has sessions. Attach to one.
        # `tmux attach-session` will attach to the last used session by default.
        # You can pass arguments to target a specific session, e.g., `start_tmux_sensibly -t main_work`
        echo "Tmux server already running. Attaching..."
        command tmux attach-session "$@"
    else
        # No server running, or server is up but has no sessions (e.g., after 'tmux kill-server').
        echo "No active tmux sessions found."

        # Check if Resurrect has saved data (this is a good hint Continuum *should* restore)
        # The default path is ~/.tmux/resurrect/last
        # Your config specifies: set -g @resurrect-dir '~/.tmux/resurrect'
        local resurrect_last_file="$HOME/.tmux/resurrect/last"
        if [ -f "$resurrect_last_file" ]; then
            echo "Tmux Resurrect data found. Starting server (Continuum should auto-restore)..."
            # Start the server WITHOUT creating a session.
            # This gives Continuum a chance to run its restore hook on a "clean" server.
            command tmux start-server

            # At this point, tmux-continuum's hook should have triggered and run the restore script.
            # Now, try to attach. If Continuum restored sessions, this should pick one up.
            # If Continuum failed or had nothing to restore, the `|| command tmux new-session "$@"` will create a new one.
            echo "Attempting to attach to a restored session (or creating a new one if restore fails/is empty)..."
            command tmux attach-session "$@" || command tmux new-session "$@"
        else
            # No Resurrect data found, so Continuum has nothing to restore.
            # Just start a new tmux session as usual.
            echo "No Tmux Resurrect data found. Starting a new session..."
            command tmux new-session "$@"
        fi
    fi
}

# Create an alias. You can choose 'tmux' if you want to override the default command.
# Using a different alias like 'tm' or 'tx' is safer initially.
alias t="start_tmux_sensibly"