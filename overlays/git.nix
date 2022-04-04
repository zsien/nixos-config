self: super: {
  git = super.git.override {
    svnSupport = true;
  };
}
