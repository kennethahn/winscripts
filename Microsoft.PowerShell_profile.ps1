# Place this in C:\Users\<username>\Documents and 
# powershell.exe will run it upon startup
# 
# The exact location of the profile is in the PS-variable PROFILE
# get-variable PROFILE

write-output "Loading profile"
. C:\tfs\sandbox\Powershell\buildscript\devenv-config.ps1
