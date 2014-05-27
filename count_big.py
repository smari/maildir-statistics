#!/usr/bin/env python

import mailbox
import rfc822
import email.utils
import time
import sys
import os.path
import os

base = os.path.expanduser(sys.argv[1])
mds = os.listdir(base)
mbcount = 0

# Do not count these towards the total:
ignore = [
    "root@localhost",
    "localhost",
]

domains = [
    "google.com",
    "gmail.com",
    "googlemail.com",
    "outlook.com",
    "hotmail.com",
    "live.com",
    "msn.com",
    "yahoo.com",
    "facebook.com",
    "twitter.com",
    "mail.com",
    "aol.com", # LOL
]

socialmedia = [
    "facebook.com",
    "twitter.com",
]

for md_name in mds:
    inbox = mailbox.Maildir(base+"/"+md_name, factory=None)
    mbcount += 1
    sys.stderr.flush()
    total = len(inbox)
    msgcount = 0

    for msg in inbox:
        flags = msg.get_flags()
        #date = msg.get_date()
        date = msg.get("Date")

        if date == None:
            continue
        else:
            date = email.utils.parsedate(date)
            if date == None:
                continue
            else:
                date = time.mktime(date)

        precedence = msg.get("Precedence")
        if precedence == None:
            precedence = "NA"
        
        big = "FALSE"
        soc = "FALSE"
        recvd_list = msg.get_all("Received")

        # skip this message if there are no received headers (malformed?)
        if recvd_list == None:
            continue

        # if there is a list of received headers, skip
        for recvd in recvd_list:
            for remove in ignore:
                if remove in recvd:
                    print "Removed mail because %s was found" % remove
                    continue

            for dom in domains:
                if dom in recvd:
                    big = "TRUE"
                    break

            for socmed in socialmedia:
                if socmed in recvd:
                    soc = "TRUE"

        # put it together and output        
        print("\t".join([flags, str(date), precedence, big, soc]))

        msgcount += 1
        sys.stderr.write("\r%3d%% - %60s: %d%%" % (100*float(mbcount)/len(mds), md_name, 100*float(msgcount)/total))

    sys.stderr.write("\n")


