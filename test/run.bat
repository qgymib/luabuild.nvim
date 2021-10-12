@echo on

nvim --headless --noplugin -u test/init.vim -c "PlenaryBustedDirectory test/spec/"
