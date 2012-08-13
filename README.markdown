# mutt_vim_wrapper - Mutt VIm reply preprocessing script.

+ [github project] (https://github.com/geronime/mutt_vim_wrapper)

This script is fitted for users of [mutt] (http://www.mutt.org/)
mail client writing their e-mails in [VIm] (http://www.vim.org/).

## Features

* all the signatures are removed only in case of group/reply
  (determined by `/^subject: ?re:/i` line)
* trailing empty lines are removed (cited ones as well)

## Usage

To start using this wrapper just make the script executable and configure
your `muttrc` with a line like:

    set editor="~/bin/mutt_vim_wrapper.pl %s"

You are also advised to adjust the final VIm exec command to suit your needs
(I have some VIm options overriden there because I do not want the devel
behaviour when writing e-mails).

## License

mutt_vim_wrapper is copyright (c)2011 Jiri Nemecek

You can re/distribute and/or modify any parts of the script and its modules
under the same terms as Perl itself.

## Under the hood

This script edits the e-mail text file prepared by mutt just before executing
the VIm editor. Such a file contains e-mail header and cited body in case
of reply/forward.

The goal is to remove all signatures (but only in case of group/reply).
To determine the e-mail is a group/reply the presence of `/^subject: ?re:/i`
line is required.

The script should cover following scenarios:

* regular correct signature on the bottom of the e-mail
* any regular signature in deeper citation levels
* signature in top-posting above the citations

The algorithm in a nutshell:

* signature is detected by a line containing just two hyphens and a space.
  * the space is optional because of some non-standard signatures
  * such a line can be found on all citation levels
* when the signature line is found, the citation level is saved and
  consecutive lines are skipped until:
  * two or more empty lines within the same level of citation are found
  * higher citation level is reached
    (the line beginning does not match the saved citation level string)
  * deeper citation level is reached (the line beginning matches more
    citation characters than just the saved ones)
  * in the last case the preceding line is given back as it is probably
    the next citation header

