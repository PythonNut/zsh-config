# =========
# Autoloads
# =========
{
  function a(){ autoload -Uz $@}
  alias a='autoload -Uz'
  
  a zargs              # a more integrated xargs
  a zmv                # concise file renaming/moving 
  a zed                # edit files right in the shell
  a zsh/mathfunc       # common mathematical functions
  a zcalc              # a calculator right in the shell
  a zkbd               # automatic keybinding detection
  a zsh-mime-setup     # automatic MIME type suffixes 
  a colors             # collor utility functions
  a vcs_info           # integrate with version control
  a copy-earlier-word  # navigate backwards with C-. C-,
  a url-quote-magic    # automatically%20escape%20characters
  a add-zsh-hook       # a more modular way to hook
  
} always {
  unfunction a
} &>> ~/.zsh.d/startup.log
