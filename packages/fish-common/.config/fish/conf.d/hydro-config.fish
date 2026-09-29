# Hydro prompt customization (https://github.com/jorgebucaran/hydro)
# Global (not universal) so the config lives in the dotfiles, not in fish_variables.

status is-interactive; or exit

# Symbols
set -g hydro_symbol_start ""
set -g hydro_symbol_prompt "❯"
set -g hydro_symbol_git_dirty "*"
set -g hydro_symbol_git_ahead "⇡"
set -g hydro_symbol_git_behind "⇣"

# Colors (anything accepted by `set_color`)
set -g hydro_color_start brblack
set -g hydro_color_pwd blue
set -g hydro_color_git magenta
set -g hydro_color_prompt green
set -g hydro_color_error red
set -g hydro_color_duration yellow

# Behavior
set -g hydro_fetch true # fetch the git remote in the background
set -g hydro_multiline true # prompt symbol on its own line
set -g hydro_cmd_duration_threshold 2000 # show duration after 2s
set -g fish_prompt_pwd_dir_length 1
