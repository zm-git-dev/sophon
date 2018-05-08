#rsync cmd:
rsync -e "ssh -p 3222" -r -c -v * 202.120.45.101:/share/home/fzyan/hGT

#-e :specify the remote shell to use
#-r :recursive
#-c :skipi based on checksum
#-v :verbose output  (opposite argument: -q, quiet and no error messages)
