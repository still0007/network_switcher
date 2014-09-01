#!/bin/bash

export PATH="$PATH:/usr/sbin:/usr/bin"
~/.rvm/rubies/ruby-1.9.3-p545/bin/ruby /data/network_switcher/lib/switcher.rb $1 $2
