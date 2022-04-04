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
        version = "1.0.7";
        sha256 = "0mralimyzhyp4x9q98x3ck64ifbjqdp8cxcami7clvdvkmf8hxhf";
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
        version = "12.0.5";
        sha256 = "0zfawv9nn88x8m30h7ryax0c7p68najl23a51r88a70hqppzxshw";
      }
      {
        name = "go";
        publisher = "golang";
        version = "0.32.0";
        sha256 = "0a3pmpmmr8gd0p8zw984a73cp2yyi4lvz0s03msvkrxmn5k9xhis";
      }
      {
        name = "latex-workshop";
        publisher = "James-Yu";
        version = "8.24.1";
        sha256 = "075ym4f1ajfaxnpyvqi0jwk3079lng1qnr24hhpw3z2yd433vx4i";
      }
      {
        name = "vscode-clangd";
        publisher = "llvm-vs-code-extensions";
        version = "0.1.15";
        sha256 = "0skasnc490wp0l5xzpdmwdzjr4qiy63kg2qi27060m5yqkq3h8xn";
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
        version = "0.78.0";
        sha256 = "0vfzz6k4hk7m5r6l7hszbf4fwhxq6hxf8f8gimphkc57v4z376ls";
      }
      {
        name = "cmake-tools";
        publisher = "ms-vscode";
        version = "1.11.3";
        sha256 = "1iarzd0h43hw5ncvl9fw50i67ha7migrs36h7wdrnsrcm8d1sjvl";
      }
      {
        name = "tabnine-vscode";
        publisher = "TabNine";
        version = "3.5.39";
        sha256 = "1376xyf62sl25rilbqwrzc2nr5kxhs7m3kh3alhbc28wjlsh3xac";
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
