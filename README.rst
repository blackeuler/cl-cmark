.. default-role:: code

###################################
 libcmark bindings for Common Lisp
###################################

This system implements bindings for the CommonMark_ reference implementation
library cmark_. It allows us to parse a CommonMark document into a tree of
nodes, which we can then transform and traverse.


Installation
############

This project uses ASDF_ as its build system. There are two systems provided:
`cmark` (what you most likely want) and `libcmark.` In either case, you will
need the following:

- A Lisp implementation which supports CFFI_
- CFFI
- The native cmark_ library installed on your system

For further dependencies please refer to the `cmark.asd`_ file.


Using
#####

There are two separate systems. The `cmark` system is a high-level lispy system
which most users will want to use. It provides most of the functionality of the
C library using idiomatic and native Common Lisp concepts. It depends on the
`libcmark` system.

The `libcmark` system is just a set of thin bindings over the C API using CFFI.
It is mostly a 1:1 binding and you will most likely only need it if you want to
create your own high-level system on top of it. The `libcmark` system can be
loaded without loading the `cmark` system.

The documentation is written in `GNU Texinfo`_, you can build it via the
provided makefile: `make doc` will build the documentation in HTML and GNU Info
formats.

Example
=======

Let us parse a small CommonMark document and print the node tree.

.. code-block:: lisp

   (defpackage #:cmark-user
     (:use #:cl #:cmark))
   (in-package #:cmark-user)

   (defvar *document-tree* (cmark::parse-document "Hello *world*!")
     "Parse the document into a tree of nodes")

   (defun print-node (node &optional (level 0))
     "Recursively print each node and its children at progressively deeper
     levels"
     (format t "~&~A~A"
             (make-string (* 2 level) :initial-element #\Space)
             (class-name (class-of node)))
     (dolist (child (cmark::node-children node))
       (print-node child (1+ level))))

   (print-node *DOCUMENT-TREE*)

This produces the following output:

.. code-block::

   DOCUMENT-NODE
     PARAGRAPH-NODE
       TEXT-NODE
       EMPH-NODE
         TEXT-NODE
       TEXT-NODE


Roadmap
#######

The project is pretty much feature complete. There are a few things that would
be nice to have, but they are by no means blockers for a stable release. Here
is a list of the remaining tasks:

- Recoverable errors, e.g. if a node needs to be an orphan offer a restart that
  orphans the node
- Maybe custom printed representation for node classes?


License
#######

Released under the `BSD-2-Clause` license. See the LICENSE_ file for details.


.. ----------------------------------------------------------------------------
.. _CommonMark: https://commonmark.org/
.. _cmark: https://github.com/commonmark/cmark
.. _GNU Texinfo: https://www.gnu.org/software/texinfo/
.. _ASDF: https://asdf.common-lisp.dev/
.. _CFFI: https://cffi.common-lisp.dev/
.. _cmark.asd: cmark.asd
.. _LICENSE: LICENSE.txt
