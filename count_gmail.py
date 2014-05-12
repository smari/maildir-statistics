#!/usr/bin/env python

import mailbox
import rfc822
import email.utils
import time
import sys
import os.path

md_name = os.path.expanduser(sys.argv[1])

inbox = mailbox.Maildir(md_name, factory=None)

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
    
    google = "FALSE"
    recvd_list = msg.get_all("Received")

    # skip this message if there are no received headers (malformed?)
    if recvd_list == None:
        continue

    # if there is a list of received headers, skip
    for recvd in recvd_list:
        if "google.com" in recvd or "gmail.com" in recvd or "googlemail.com" in recvd:
            google = "TRUE"

    # put it together and output        
    print("\t".join([flags, str(date), precedence, google]))


