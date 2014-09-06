## zsh-config

My personal `zsh` config (to be put in `~/.zsh.d`)

# This is no longer a shell

According to Wikipedia (8/14/14)

> In computing, a shell is a user interface for access to an operating system's services.

The magic of `zsh` is it's fantastically powerful scripting ability. `zsh` isn't so much a shell as it is a way to _make your own shell_.

This is my goal: to make a highly customized and tailored enviroment for my work. In adittion, I'd love to distill more intelligence into the shell (the kinds of things you wouldn't expect a shell to do).

* Enter a version control repository and it will automatically spawn an `inotify` service, start watching your files and live stream async version control information (like git dirty status) into the righthand prompt.
* Suffix aliases for all associated filetypes are generated from the environment MIME handler (via `zsh-mime-handler`)
* When completing remote filenames, `zsh` will fetch a list of remote files and complete them (via `zsh-url-httplink`)
* Automatically extract options and their descriptions from manpages and stream them to the completion system.
* etc.

My goal is to continue adding features and deep integration with other tools. I also want this to be portable to other forms of Linux (Mac OS is a much more distant goal, as I don't own a Mac). Currently being tested on:

* Arch Linux 64
* Fedora 16 stable 64
* Fedora 20 stable 32
* Fedora rawhide 64
* Ubuntu 64

And with the following zsh versions

* `zsh` 4.3 (broken)
* `zsh` 4.6 (mostly broken)
* `zsh` 5.0+
