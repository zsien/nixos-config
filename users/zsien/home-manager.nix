{ config, pkgs, lib, ... }:

{
  home.file = {
    ".config/user-dirs.dirs".source = config.rootDir + /dotfiles/user-dirs/.config/user-dirs.dirs;
    ".config/user-dirs.locale".source = config.rootDir + /dotfiles/user-dirs/.config/user-dirs.locale;

    ".config/Code/User/settings.json".source = config.rootDir + /dotfiles/vscode/.config/Code/User/settings.json;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    shellAliases = {
      ls = "ls --group-directories-first --color=auto";
    };
    initExtraFirst = ''
      # Use emacs keybindings even if our EDITOR is set to vi
      bindkey -e

      if [[ "$TERM" != 'emacs' ]]
      then

          typeset -A key
          key=(
              BackSpace  "''${terminfo[kbs]}"
              Home       "''${terminfo[khome]}"
              End        "''${terminfo[kend]}"
              Insert     "''${terminfo[kich1]}"
              Delete     "''${terminfo[kdch1]}"
              Up         "''${terminfo[kcuu1]}"
              Down       "''${terminfo[kcud1]}"
              Left       "''${terminfo[kcub1]}"
              Right      "''${terminfo[kcuf1]}"
              PageUp     "''${terminfo[kpp]}"
              PageDown   "''${terminfo[knp]}"
          )

          function bind2maps () {
              local i sequence widget
              local -a maps

              while [[ "$1" != "--" ]]; do
                  maps+=( "$1" )
                  shift
              done
              shift

              sequence="''${key[$1]}"
              widget="$2"

              [[ -z "$sequence" ]] && return 1

              for i in "''${maps[@]}"; do
                  bindkey -M "$i" "$sequence" "$widget"
              done
          }

          bind2maps emacs             -- BackSpace   backward-delete-char
          bind2maps       viins       -- BackSpace   vi-backward-delete-char
          bind2maps             vicmd -- BackSpace   vi-backward-char
          bind2maps emacs             -- Home        beginning-of-line
          bind2maps       viins vicmd -- Home        vi-beginning-of-line
          bind2maps emacs             -- End         end-of-line
          bind2maps       viins vicmd -- End         vi-end-of-line
          bind2maps emacs viins       -- Insert      overwrite-mode
          bind2maps             vicmd -- Insert      vi-insert
          bind2maps emacs             -- Delete      delete-char
          bind2maps       viins vicmd -- Delete      vi-delete-char
          bind2maps emacs viins vicmd -- Up          up-line-or-history
          bind2maps emacs viins vicmd -- Down        down-line-or-history
          bind2maps emacs             -- Left        backward-char
          bind2maps       viins vicmd -- Left        vi-backward-char
          bind2maps emacs             -- Right       forward-char
          bind2maps       viins vicmd -- Right       vi-forward-char

          # Make sure the terminal is in application mode, when zle is
          # active. Only then are the values from $terminfo valid.
          if (( ''${+terminfo[smkx]} )) && (( ''${+terminfo[rmkx]} )); then
              function zle-line-init () {
                  emulate -L zsh
                  printf '%s' ''${terminfo[smkx]}
              }
              function zle-line-finish () {
                  emulate -L zsh
                  printf '%s' ''${terminfo[rmkx]}
              }
              zle -N zle-line-init
              zle -N zle-line-finish
          fi

          unfunction bind2maps

      fi # [[ "$TERM" != 'emacs' ]]

      fpath+=("${pkgs.pure-prompt}/share/zsh/site-functions")

      # pure prompt
      autoload -U promptinit && promptinit
      prompt pure
      prompt_newline='%666v'
      PROMPT=" $PROMPT"

      if [[ $UID == 0 || $EUID == 0 ]]; then
        # root
        PURE_PROMPT_SYMBOL="#"
      fi

      # turn on git stash status
      zstyle :prompt:pure:git:stash show yes

      # completions
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' show-completer true  # show message while waiting for completion
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
      zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,%cpu,tty,cputime,command -w'
    '';
    initExtra = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

      bindkey "^[[1;5C" forward-word  # Ctrl + 左方向鍵移動到上一個詞前
      bindkey "^[[1;5D" backward-word # Ctrl + 右方向鍵移動到下一個詞前

      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down

      path+=$HOME/.cargo/bin
    '';
  };

  programs.git = {
    enable = true;
    userName  = "zsien";
    userEmail = "i@zsien.cn";
  };

  programs.vscode = {
    enable = true;
    package = pkgs.master.vscode;
    extensions = with pkgs.master.vscode-extensions; [
      ms-vscode.cpptools
    ] ++pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "nix-env-selector";
        publisher = "arrterian";
        version = "1.0.9";
        sha256 = "0kdfhkdkffr3cdxmj7llb9g3wqpm13ml75rpkwlg1y0pkxcnlk2f";
      }
      {
        name = "meson";
        publisher = "asabil";
        version = "1.3.0";
        sha256 = "1q35rzn7l7n2rzm3yvgdhs0yxgz9aqlrgr0clswwps3i85s7gjj0";
      }
      {
        name = "Nix";
        publisher = "bbenoist";
        version = "1.0.1";
        sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
      }
      {
        name = "xml";
        publisher = "DotJoshJohnson";
        version = "2.5.1";
        sha256 = "1v4x6yhzny1f8f4jzm4g7vqmqg5bqchyx4n25mkgvw2xp6yls037";
      }
      {
        name = "gitlens";
        publisher = "eamodio";
        version = "12.0.6";
        sha256 = "1d7gzxsyxrhvvx2md6gbcwiawd8f3jarxfbv2qhj7xl1phd7zja3";
      }
      {
        name = "go";
        publisher = "golang";
        version = "0.33.0";
        sha256 = "1wd9zg4jnn7y75pjqhrxm4g89i15gff69hsxy7y5i6njid0x3x0w";
      }
      {
        name = "latex-workshop";
        publisher = "James-Yu";
        version = "8.26.0";
        sha256 = "1isgrxr71ylqzhg133mknkr57pf2jgx25lx17qsn5304ccs1n8b4";
      }
      {
        name = "vscode-clangd";
        publisher = "llvm-vs-code-extensions";
        version = "0.1.17";
        sha256 = "1vgk4xsdbx0v6sy09wkb63qz6i64n6qcmpiy49qgh2xybskrrzvf";
      }
      {
        name = "remote-ssh";
        publisher = "ms-vscode-remote";
        version = "0.78.0";
        sha256 = "1743rwmbqw2mi2dfy3r9qc6qkn42pjchj5cl8ayqvwwrrrvvvpxx";
      }
      {
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.80.0";
        sha256 = "0zgrd2909xpr3416cji0ha3yl6gl2ry2f38bvx4lsjfmgik0ic6s";
      }
      {
        name = "cmake-tools";
        publisher = "ms-vscode";
        version = "1.11.16";
        sha256 = "01mh063m7zxq6lics86jnmakixalb3mw8dhnfqybypyih9v20fjs";
      }
      {
        name = "tabnine-vscode";
        publisher = "TabNine";
        version = "3.5.45";
        sha256 = "0biyc7wc9nnnr3jax7d2vjnr7yp46hlyy5fm7kqdlgm6hqn4361b";
      }
      {
        name = "cmake";
        publisher = "twxs";
        version = "0.0.17";
        sha256 = "11hzjd0gxkq37689rrr2aszxng5l9fwpgs9nnglq3zhfa1msyn08";
      }
      {
        name = "vim";
        publisher = "vscodevim";
        version = "1.22.2";
        sha256 = "1d85dwlnfgn7d32ivza0bv1zf9bh36fx7gbi586dligkw202blkn";
      }
    ];
  };
}
