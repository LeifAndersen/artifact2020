#lang scribble/manual

@(require scribble/core)

@title{Artifact: Adding Interactive Visual Syntax to Textual Code}

Our artifact consists of a VM image that contains:
@itemlist[
 #:style 'compact
 @item{a distribution of the Racket programming language (version 7.7),}
 @item{a distribution of the interactive-syntax library for Racket,}
 @item{a copy of a preprint draft of the paper,}
 @item{and the examples described in that paper.}]

The goals of this artifact are to:
@itemlist[
 #:style 'compact
 @item{provide a simple environment to create and run interactive-syntax extensions, and}
 @item{provide an archival copy of the interactive-syntax library in this paper.}]

At the time of this artifact's creation, the
interactive-syntax library can also be found at:
@url["https://github.com/videolang/interactive-syntax"]

@section{Getting Started Guide: Setting up and installing the artifact}

The artifact is available as a virtual machine appliance for VirtualBox. If
you are already reading this README in the VM, feel free to ignore the
rest of this section.

To run the artifact image, open the given @tt{.ova} file using the
@tt{File->Import Appliance} menu item. This will create a new VM
that can be launched after import. We recommend giving the VM at least
4GB of RAM.

@nested[
 #:style (style #f (list (color-property "red")))]{
 Note that this VM is 32-bit. If you have Hyper-V
 virtualization enabled on windows, you may get a
 ``@tt{VT-x is not available}'' error. Instructions on how to disable Hyper-V can be found at:
 @url["https://support.microsoft.com/en-us/help/3204980/virtualization-applications-do-not-work-together-with-hyper-v-device-g"]}

The image is configured to automatically login to the @tt{
 oopsla} user account. The account has root privileges using
@tt{sudo} without a password. If needed however, the
password for the account is @tt{oopsla2020}.

Once in the VM, run the @filepath{~/Desktop/test-all.sh} script from
the terminal to ensure that everything is working. This
script runs every program provided by the artifact and
output ``@tt{Testing Finished}'' once it is done. It does
not open any windows to see editors in action. To
demonstrate this open and run @filepath{~/Desktop/examples/tsuro/board.rkt}
by performing the following steps:
@;
@itemlist[
 #:style 'ordered
 @item{Open the file with DrRacket. DrRacket is set as the default editor for @filepath{.rkt} files.}
 @item{Once DrRacket is loaded, click the ``@tt{Update Editors}'' button in the top right.}
 @item{Click the ``@tt{Run}'' button to run the program.}]
@;
The resulting editor will be similar to the ones on page 2 of the paper.

@section{Step by step: Artifact Evaluation}

This paper introduces the concept of interactive-syntax extensions. As such, its claims are:
@;
@itemlist[
 #:style 'ordered
 @item{Interactive-syntax is realizable.}
 @item{Various domains lend themselves well to interactive-syntax extensions.}]

To justify this, the paper provided a library for creating
and using interactive-syntax extensions, and demonstrated
several examples of interactive-syntax extensions using that
library. This artifact contains that library
(@filepath["/home/artifact/Desktop/interactive-syntax"]) and
the examples provided in the paper
(@filepath["/home/artifact/Desktop/examples"]). The rest of
this section describes how to run programs that use
interactive-syntax extensions and enumerates all of the
examples from the paper.

@subsection{Artifact Overview}

The relevant files for this artifact are in
@filepath["/home/artifact/Desktop"], which contains:
@itemlist[
 #:style 'compact
 @item{@filepath{README}--this file,}
 @item{@filepath{paper.pdf}--a draft of the paper,}
 @item{@filepath{DrRacket}--an IDE for displaying interactive-syntax extensions,}
 @item{@filepath{interactive-syntax/}--a copy of the interactive-syntax library,}
 @item{@filepath{examples/}--source for the interactive-syntax extensions discussed in the paper, and}
 @item{@filepath{test-all.sh}--a script to ensure the interactive-syntax package and environment are working,}]

We recommend using DrRacket to view the files in this
artifact. Only files that begin with @tt{#lang editor} at
the top use interactive-syntax. The remaining files use plain-text.

To open a file that uses interactive-syntax in its implementation,
such as @filepath{examples/tsuro/board.rkt}, perform the following steps:
@;
@itemlist[
 #:style 'ordered
 @item{Open the file with DrRacket. DrRacket is set as the default editor for @filepath{.rkt} files.}
 @item{Once DrRacket is loaded, click the ``@tt{Update Editors}'' button in the top right.}
 @item{Click the ``@tt{Run}'' button to run the program.}]

If a file is entirely plain text, we still recommend using
DrRacket. These files may have editor tests that only appear
when run in DrRacket. For these files, such as
@filepath{examples/tsuro/tsuro.rkt}, perform the following
steps:
@;
@itemlist[
 #:style 'ordered
 @item{Open the file with DrRacket. DrRacket is set as the default editor for @filepath{.rkt} files.}
 @item{Click the ``@tt{Run}'' button to run the program.}]

@nested[
 #:style (style #f (list (color-property "red")))]{
 A few things to note:

 @itemlist[
 #:style 'compact
 @item{The startup can take up to 30 seconds, most of which is DrRacket's startup time.}
 @item{If you open the examples in a plain text editor you will see the raw-text version of each editor.}
 @item{The entire @filepath{examples/} folder is a git repo, if something breaks, you can always run @tt{git reset --hard}}]} 

@subsection{Examples from Section 1}

All samples from Section 1 are in @filepath{examples/tsuro/}. The contents of this directory are:

@itemlist[
 #:style 'compact
 @item{@filepath{examples/tsuro/tsuro.rkt} -- The implementation of the Tsuro Interactive Syntax Extension}
 @item{@filepath{examples/tsuro/tile.rkt} -- Examples of the tile editor}
 @item{@filepath{examples/tsuro/board.rkt} -- Examples of the board editor}
 @item{@filepath{examples/tsuro/mixed.rkt} -- Examples of mixed graphical and textual Tsuro board}]

Specifically each example can be found as follows:

@itemlist[
 #:style 'compact
 @item{Lines 35--42 -- @filepath{examples/tsuro/tile.rkt}}
 @item{Lines 53--58 -- @filepath{examples/tsuro/tile.rkt}}
 @item{Lines 60--67 -- @filepath{examples/tsuro/board.rkt}}
 @item{Lines 70--75 -- @filepath{examples/tsuro/board.rkt}}
 @item{Figure 1 -- @filepath{examples/tsuro/board.rkt}}
 @item{Lines 90--94 -- @filepath{examples/tsuro/mixed.rkt}}
 @item{Lines 129--138 -- @filepath{examples/tsuro/mixed.rkt}}]

@subsection{Examples from Section 2}

Section 2 had no code examples.

@subsection{Examples from Section 3}

Samples for Sections 3.1-3.3 can be found in the @filepath{
 examples/phases} folder. The examples for Section 3.4 is
found in @filepath{examples/tsuro/tsuro.rkt}.

The contents of the @filepath{examples/phases} folder is: 

@itemlist[
 #:style 'compact
 @item{@filepath{examples/phases/compile.rkt} -- Traditional compile-time phases as described in Section 3.1}
 @item{@filepath{examples/phases/edit.rkt} -- Edit time phases as described in section 3.2}
 @item{@filepath{examples/phases/simple.rkt} -- The basic editor described in section 3.3}
 @item{@filepath{examples/phases/submodule.rkt} -- Use of submodules, code from the appendix.}]

Specifically each example can be found as follows:

@itemlist[
 #:style 'compact
 @item{Lines 223--227 -- @filepath{examples/phases/compile.rkt}}
 @item{Lines 238--240 -- @filepath{examples/phases/compile.rkt}}
 @item{Lines 246--252 -- @filepath{examples/phases/compile.rkt}}
 @item{Lines 274--280 -- @filepath{examples/phases/edit.rkt}}
 @item{Lines 303--311 -- @filepath{examples/phases/simple.rkt}}
 @item{Lines 324--333 -- @filepath{examples/phases/simple.rkt}}
 @item{Figure 3 -- @filepath{examples/tsuro/tsuro.rkt}}
 @item{Lines 442--455 -- @filepath{examples/phases/simple.rkt}}]
 
@subsection{Examples from Section 4}

The examples in section 4 are split into three folders:

@itemlist[
 #:style 'compact
 @item{@filepath{examples/expressive/} -- The examples described in Sections 4.1 and 4.2}
 @item{@filepath{examples/rbtree/} -- The red-black tree described in Section 4.3}
 @item{@filepath{examples/meta/} -- The meta-form extension described in Section 4.4}]

Sections 4.1 and 4.2 describe several examples, each of
which can be run and edited slightly differently. The
subsections below show how to run the most interesting
examples.

@subsubsection{TCP Parser}

To run, open @filepath{examples/expressive/tcpheader.rkt}
and press @tt{Update Editors}, you will see a graphical
representation of the TCP spec.


A test is at the bottom of this file, press @tt{Run} and it
will parse a sample TCP packet. You can use the
@racket[parse-header] function to parse additional packets.

The relevant files are:
@itemlist[
 #:style 'compact
 @item{@filepath{examples/expressive/tcpheader.rkt} -- The
        graphical TCP parser, test at the bottom of the file}
 @item{@filepath{examples/expressive/spec.rkt} -- The
        implementation of the bitsyntax editor used by the tcp parser}
 @item{@filepath{examples/expressive/tcpheader-text.rkt} --
        A purely textual TCP parser for comparison}]

@subsubsection{Images as Bindings}

Open @filepath{examples/expressive/binder-test.rkt} and
press @tt{Update Editors}. You will see a stick figure being
bound to the name @racket["Bob"], and later used in a string
append. Press @tt{Run} to evaluate the program.

You can use the @racket[define/vis] form to bind new images.
You can insert new images, either uses or bindings, into the
file by pressing @tt{Insert Editor} and selecting the
@racket[binder$] editor from @racket["binder.rkt"]. Use
small @tt{.png} file for the images themselves.

The relevant files are:
@itemlist[
 #:style 'compact
 @item{@filepath{examples/expressive/binder.rkt} -- The images as bindings editor implementation}
 @item{@filepath{examples/expressive/binder-test.rkt} -- A use of the images as bindings editor}
 @item{@filepath{examples/expressive/image.rkt} -- A helper image
        selection editor used by @filepath{binder.rkt}.}]

@subsubsection{Circuit}

To run the circuit editor tests, open @filepath{
 examples/expressive/circuit.rkt} and press @tt{Run}. A
simple circuit editor will pop up in a new window.

Interactive-syntax extensions are also used in the
implementation of the circuit editor. Images are used in
@racket[component$] objects. Press the @tt{Update Editors}
button to see them.

The relevant files are:
@itemlist[
 #:style 'compact
 @item{@filepath{examples/expressive/circuit.rkt} -- The circuit editor and its tests}
 @item{@filepath{examples/expressive/image.rkt} -- A helper for the implementation of circuit components}]

@subsubsection{Red-Black Trees}

To see the red-black tree example from the figure open
@filepath{examples/rbtree/use.rkt} and press @tt{Update Editors}.
You will be able to add new nodes and move
existing ones around. To add new trees press @tt{Insert Editor} and insert the @racket[tree$]
extension from @racket["tree.rkt"].

The relevant files are:
@itemlist[
 #:style 'compact
 @item{@filepath{examples/rbtree/rbtree.rkt} -- A textual tree implementation}
 @item{@filepath{examples/rbtree/tree.rkt} -- The graphical red-black tree implementation}
 @item{@filepath{examples/rbtree/use.rkt} -- A use of the @filepath{tree.rkt} file}
 @item{@filepath{examples/rbtree/text.rkt} -- A purely textual tree-rotate}]

@subsubsection{Meta Forms}

To see example uses of the meta-forms open @filepath{
 examples/meta/forms.rkt} and press @tt{Update Editors}. To
see examples of @emph{those} forms, open @filepath{
 examples/meta/assignments.rkt} and press
@tt{Update Editors}. You can also run @filepath{assignments.rkt}
to see the resulting dictionary they evaluate to.

The relevant files are:
@itemlist[
 #:style 'compact
 @item{@filepath{examples/meta/implementation.rkt} -- The meta-form implementation.}
 @item{@filepath{examples/meta/forms.rkt} -- Form implementations using the meta-form}
 @item{@filepath{examples/meta/assignments.rkt} -- Instances of the forms in @filepath{forms.rkt}}]

@subsubsection{Samples from the paper}
 
Finally, the samples from Sections 4.3 and 4.4 are as follows:
@itemlist[
 #:style 'compact
 @item{Figure 5 -- @filepath{examples/rbtree/text.rkt}}
 @item{Lines 633--637 -- @filepath{examples/meta/assignments.rkt}}
 @item{Figure 6 -- @filepath{examples/rbtree/use.rkt}}
 @item{Figure 7 -- @filepath{examples/meta/implementation.rkt}}
 @item{Lines 687--690 -- @filepath{examples/meta/assignments.rkt}}
 @item{Lines 693--699 -- @filepath{examples/meta/forms.rkt}}
 @item{Lines 707--712 -- @filepath{examples/meta/forms.rkt} and @filepath{examples/meta/assignments.rkt}}]

@subsection{Examples from Section 5}

Section 5 describes the implementation for
interactive-syntax extensions. This implementation can be
found in the @filepath{interactive-syntax} folder. Some of
the basic files in the folder are:

@itemlist[
 #:style 'compact
 @item{@filepath{interactive-syntax/editor/private/read-editor.rkt} -- The language extension described in section 5.1}
 @item{@filepath{interactive-syntax/editor/private/context.rkt} -- Part of the IDE plugin described in Section 5.2}
 @item{@filepath{interactive-syntax/editor/private/surrogate.rkt} -- The rest of the IDE plugin described in Section 5.2}
 @item{@filepath{interactive-syntax/editor/private/editor.rkt} -- The elaborator described in Section 5.3.}]

Finally, the elaboration shown in Figure 6 can be seen by:
@itemlist[
 #:style 'ordered
 @item{Opening @filepath{examples/phases/simple.rkt} in DrRacket}
 @item{Clicking on the ``@tt{Macro Stepper}'' button in the top bar.}
 @item{Hitting ``@tt{Step}'' 35 times.}]

@subsection{Examples from Section 6}

Section 6 had no code examples.

@subsection{Examples from Section 7}

Section 7 had no code examples.

@subsection{Examples from Section 8}

Section 8 had no code examples.

@subsection{Examples from Appendix A}

The code sample from Appendix A is:

@itemlist[
 #:style 'compact
 @item{Lines 1208--1219 -- @filepath{examples/phases/submodule.rkt}}]
