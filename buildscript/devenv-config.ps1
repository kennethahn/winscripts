function Get-Batchfile ($file) 
{
    $cmd = "echo off & `"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split(’=')
        Set-Item -path env:$p -value $v
    }
}

function Run-Batchfile ($file) 
{
    $cmd = "echo off & `"$file`" & set"
    cmd /c $cmd 
}

function LoadEnvVars( [string]$EnvVarsFile ) 
{
    if( !$EnvVarsFile ){ throw "No filename provided" }   
    ## Prepare environment for devenv
    ## should be automated/dynamic so it can find whatever VS install there is
    cmd /c "echo off & `"$EnvVarsFile`" & set" | 
    Foreach-Object {
            $p, $v = $_.split('=')
            Set-Item -path env:$p -value $v
    }
}

LoadEnvVars "C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat"

#  $version='10.0'
#  $VSKey = $null
#  if (test-path HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$version)
#  {
#    $VSKey = get-itemproperty HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$version
#  }
#  else
#  {
#    if (test-path HKCU:SOFTWARE\Microsoft\VisualStudio\$version)
#    {
#        $VSKey = get-itemproperty HKCU:SOFTWARE\Microsoft\VisualStudio\$version
#    }
#  }

#  if ($VSKey -eq $null) { throw “Visual Studio not installed” }
 

#  $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
#  $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
#  $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, “Tools”)
#  $BatchFile = [System.IO.Path]::Combine($VsToolsDir, “vsvars32.bat”)
#  $BatchFile
#  Get-Batchfile $BatchFile
#  [System.Console]::Title = “Visual Studio shell”

#set-alias devenv ((VsInstallDir)+”\devenv.exe”) -scope global
