## zsh-config

My personal `zsh` config (to be put in `~/.zsh.d`)

# This is no longer a shell

According to Wikipedia (8/14/14)

> In computing, a shell is a user interface for access to an operating system's services.

The magic of `zsh` is it's fantastically powerful scripting ability. `zsh` isn't so much a shell as it is a way to _make your own shell_.

**I've done so.**

However, while I'm at it, I may as well try to go a level up. This is not a shell in the sense that Notepad is a text editor, this is a shell in the sense that `emacs` or `vim` are text editors. _They do so much more_. For example:

* Enter a version control repository and it will automatically spawn an `inotify` service, start watching your files and live stream async version control information (like git dirty status) into the righthand prompt.
* Suffix aliases for all associated filetypes are generated from the environment MIME handler (via `zsh-mime-handler`)
* When completing remote filenames, `zsh` will fetch a list of remote files and complete them (via `zsh-url-httplink`)
* Automatically extract options and their descriptions from manpages and stream them to the completion system.
* etc.

An ordinary shell is boring. The future (and the future of this project) is to create a deepy integrated and intelligent environment.
