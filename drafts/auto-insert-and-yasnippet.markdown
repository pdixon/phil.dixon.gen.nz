---
title: Combining Auto Insert and Yasnippet
description: Use auto insert to trigger a yasnippet to template new files.
tags: emacs
---

Over the years I have used a range of "real" editors. I started off
with [Textmate][textmate] back in about 2006. For the last few years
I've been using [emacs] as my main editor[^fn1]. Two things I found
particularly good in Textmate were it's snippets, and it's file
templates. [yasnippet] is a fine snippet package for emacs, but I've
never found a solution I was happy with for the file templates.

Emacs actually ships with support for templating newly created files,
[auto-insert][autoinsert]. By default it has [skeleton] templates for
common file types. This system works, but I wasn't happy with a couple
of aspects of skeleton in particular. Skeleton templates are written
as lisp code with strings in it. I find this awkward to work with. I
much prefer templates where the default is literal text. The second
issue was how it queries the user. Skeleton can ask the user for
content to insert, but it does this prompting in the mini-buffer.

yasnippets handles defining snippets and expanding them in a way that
I like. The snippets are literal text with escaping for any calculate
bits. Any user enter is handled as insertion points that are stepped
through with tab key.


[^fn1]: In between Textmate and emacs I spent time using vim. I seem
        to recall I had file templating I was happy with while I was
        using vim.

[textmate]: <http://macromates.org>
[emacs]: <http://www.gnu.org/software/emacs/>
[yasnippet]: <http://code.google.com/p/yasnippet/>
[gist]: <https://gist.github.com/675584>
[autoinsert]: <http://www.gnu.org/software/emacs/manual/html_node/autotype/Autoinserting.html>
[autotyping]: <http://www.gnu.org/software/emacs/manual/html_mono/autotype.html>
[skeleton]: <http://www.gnu.org/software/emacs/manual/html_node/autotype/Skeleton-Language.html#Skeleton-Language>
