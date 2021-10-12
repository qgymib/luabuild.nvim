#!/bin/bash

nvim --headless --noplugin -u test/init.vim -c "PlenaryBustedDirectory test/spec/ { minimal_init = 'test/init.vim' }"
