# Scripts to Count Messages from Large Mail Providers

Author: Benjamin Mako Hill (mako@atdot.cc), Smári McCarthy <smari@mailpile.is>
License: GNU General Public License version 3 or any later version
Original code by Mako: http://projects.mako.cc/source/?p=gmail-maildir-counter

## Usage

Use count_big.py instead of count_gmail.py. Otherwise the same as below.


## Original readme:

I wrote this code in order to do the analysis I posted in this blog
post:

http://mako.cc/copyrighteous/google-has-most-of-my-email-because-it-has-all-of-yours

If you want to send me patches or bugfixes, details on how to do that
are here:

http://projects.mako.cc/source/

1. Parse your mailbox using the count_gmail.py script
--------------------------------------------------------------

I ran the script like this:

$ python count_gmail.py ~/incoming/mail/default > mail_metadata.tsv

2. Parse the output using analysis.R
--------------------------------------------------------------

If have not used R, you will to install R and three libraries I use in
the script. 

First, install R. In Debian and Ubuntu, the package is r-base. 

You will then need to install three R libraries. The easiest way to do
that is from within R. To start R, just invoke it from your shell:

$ R

Once R is running, you can install the packages by running these three
commands from within the R interactive shell:

> install.packages("data.table")
> install.packages("ggplot2")
> install.packages("reshape")

Once youv'e done that, you can run the scripts.  I run R interactively
in Emacs/ESS but you might want to use RStudio if you are not familiar
with Emacs. Alternatively, if you also output into mail_metadata.tsv,
you can just run:

$ R --no-save < analysis.R

It will create the two PDFs files of graphs for you in the local directory.

The I converted the PDFs into PNGs with imagemagick's mogrify:

$ mogrify -format png *pdf
