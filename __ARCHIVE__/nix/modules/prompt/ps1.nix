{ config, lib, ... }:

let
  cfg = config.dotfiles;

  # Git branch parsing function (no external dependencies)
  gitBranchFn = ''
    __git_branch() {
      local branch
      if branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
        echo " ($branch)"
      elif branch=$(git rev-parse --short HEAD 2>/dev/null); then
        echo " ($branch)"
      fi
    }
  '';

  # PS1 for bash: user@host:path (branch) $
  bashPS1 = ''
    ${gitBranchFn}
    __set_ps1() {
      local last_exit=$?
      local reset='\[\e[0m\]'
      local green='\[\e[1;32m\]'
      local red='\[\e[1;31m\]'
      local blue='\[\e[1;34m\]'
      local magenta='\[\e[1;35m\]'

      local prompt_color
      if [ $last_exit -eq 0 ]; then
        prompt_color="$green"
      else
        prompt_color="$red"
      fi

      PS1="$green\u@\h$reset:$blue\w$reset$magenta\$(__git_branch)$reset\n''${prompt_color}\$''${reset} "
    }
    PROMPT_COMMAND="__set_ps1''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  '';

  # PROMPT for zsh: user@host:path (branch) $
  zshPrompt = ''
    ${gitBranchFn}
    __set_prompt() {
      local last_exit=$?
      local prompt_color
      if [ $last_exit -eq 0 ]; then
        prompt_color="%F{green}"
      else
        prompt_color="%F{red}"
      fi
      PROMPT="%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b%F{magenta}$(__git_branch)%f
''${prompt_color}%(!.#.$)%f "
    }
    precmd_functions+=(__set_prompt)
  '';

  # Fish prompt
  fishPrompt = ''
    function fish_prompt
      set -l last_status $status
      set_color green --bold
      echo -n (whoami)"@"(hostname)
      set_color normal
      echo -n ":"
      set_color blue --bold
      echo -n (prompt_pwd)
      set_color normal

      # Git branch
      set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
      if test -n "$branch"
        set_color magenta
        echo -n " ($branch)"
        set_color normal
      end

      echo
      if test $last_status -eq 0
        set_color green
      else
        set_color red
      end
      echo -n '$ '
      set_color normal
    end
  '';
in
{
  config = lib.mkIf (cfg.prompt == "ps1") {
    programs.bash.initExtra = lib.mkIf (cfg.shell == "bash") (lib.mkAfter bashPS1);
    programs.zsh.initExtra = lib.mkIf (cfg.shell == "zsh") (lib.mkAfter zshPrompt);
    programs.fish.interactiveShellInit = lib.mkIf (cfg.shell == "fish") (lib.mkAfter fishPrompt);
  };
}
