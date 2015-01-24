function global_bindkey () {
  bindkey -M command $@
  bindkey -M emacs   $@
  bindkey -M main    $@
  bindkey            $@
}
