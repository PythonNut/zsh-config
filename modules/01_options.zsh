# ===========
# ZSH options
# ===========

{
  function s(){ setopt $@}

  # general
  s zle                    # magic stuff
  s no_beep                # beep is annoying
  s rm_star_wait           # are you REALLY sure?
  s auto_resume            # running a suspended program
  s check_jobs             # check jobs before exiting
  s auto_continue          # send CONT to disowned processes
  s function_argzero       # $0 contains the function name
  s interactive_comments   # shell comments (for presenting)

  # correction
  s correct_all            # autocorrect misspelled command
  s auto_list              # list if multiple matches
  s complete_in_word       # complete at cursor
  s menu_complete          # add first of multiple
  s auto_remove_slash      # remove extra slashes if needed
  s auto_param_slash       # completed directory ends in /
  s auto_param_keys        # smart insert spaces " "
  s list_packed            # conserve space

  # globbing
  s numeric_glob_sort      # sort globs numerically
  s extended_glob          # awesome globs
  s ksh_glob               # allow modifiers before regex ()
  s rc_expand_param        # a$abc ==> aa ab ac
  s no_case_glob           # lazy case for globs
  s glob_dots              # don't require a dot
  s no_case_match          # lazy case for regex matches
  s bare_glob_qual         # can use qualifirs by themselves
  s mark_dirs              # glob directories end in "/"
  s list_types             # append type chars to files
  s null_glob              # don't err on null globs
  s brace_ccl              # extended brace expansion

  # history
  s hist_reduce_blanks     # collapse extra whitespace
  s hist_ignore_space      # ignore lines starting with " "
  s hist_ignore_dups       # ignore immediate duplicates
  s hist_find_no_dups      # ignore all search duplicates
  s extended_history       # timestamps are nice, really
  s append_history         # append is good, append!
  s inc_append_history     # append in real time
  s share_history          # share history between terminals
  s hist_no_store          # don't store history commands
  s hist_expire_dups_first # kill the dups! kill the dups!
  s hist_verify            # verify history expansions

  # i/o and syntax
  s multios                # redirect to globs!
  s multibyte              # Unicode!
  s noclobber              # don't overwrite with > use !>
  s rc_quotes              # 'Isn''t' ==> Isn't
  s equals                 # "=ps" ==> "/usr/bin/ps"
  s hash_list_all          # more accurate correction
  s list_rows_first        # rows are way better
  s hash_cmds              # don't search for commands
  s cdable_vars            # in p, cd x ==> ~/x if x not p
  s short_loops            # sooo lazy: for x in y do cmd
  s chase_links            # resolve links to their location
  s notify                 # I want to know NOW!

  # navigation
  s auto_cd                # just "dir" instead of "cd dir"
  s auto_pushd             # push everything to the dirstack
  s pushd_silent           # don't tell me though, I know.
  s pushd_ignore_dups      # duplicates are redundant (duh)
  s pushd_minus            # invert pushd behavior
  s pushd_to_home          # pushd == pushd ~
  s auto_name_dirs         # if I set a=/usr/bin, cd a works
  s magic_equal_subst      # expand expressions after =

  s prompt_subst           # Preform live prompt substitution
  s transient_rprompt      # Get rid of old rprompts
  s csh_junkie_history     # single instead of dual bang
  s csh_junkie_loops       # use end instead of done
  s continue_on_error      # don't stop! stop = bad

} always {
  unfunction s
} &>> ~/.zsh.d/startup.log
