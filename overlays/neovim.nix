self: super: {
  neovim = super.neovim.override {
    viAlias = true;
    vimAlias = true;
  };
}
