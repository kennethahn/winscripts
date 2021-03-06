### config section
# Where to store the temporary checked out files and do the building etc.
$BASEDIR="C:\temp\test\"

# TFS server 
$TFS_SERVER="http://mytfs.server:8080"

# Path to solution dir on TFS
$TFS_PROJECT_DIR="$/Path/To/My/Solution/Directory"

# Path to solution file (relative to _TFS_PROJECT_DIR)
$SLNFILE="My.App.sln"

# Path to unit test dll (relative to _TFS_PROJECT_DIR)
$UNIT_TEST_DLL="Relative/Path/To/My.App.Test.dll"

### end config

$TSTAMP=get-date -Format yyyy-MM-dd_HH-mm-ss

$TESTNAME="tfstest." + $TSTAMP
$WORKDIR=$BASEDIR + $TESTNAME
$LOG=$BASEDIR + $TESTNAME + ".log"

function Log()
{
    $input | write-host
}


function GetFromTFS()
{
    write-host "Getting source from TFS"
    mkdir $WORKDIR
    pushd $WORKDIR
    tf workspace /new /noprompt /server:$TFS_SERVER $TESTNAME 
    tf workfold /map /server:$TFS_SERVER /workspace:$TESTNAME $TFS_PROJECT_DIR $WORKDIR
    tf get /recursive /force /noprompt $TFS_PROJECT_DIR
    popd
}

function CheckOutFile()
{
    write-host "Checking out file $SLNFILE" 
    pushd $WORKDIR
    tf checkout $SLNFILE
    popd
}

function UndoCheckOut()
{
    write-host "Undoing checkout"
    pushd $WORKDIR
    tf undo /noprompt $SLNFILE 
    popd
}

function CleanUp()
{
    write-host "Cleaning up mess"
    pushd $BASEDIR
    tf workfold /unmap /workspace:$TESTNAME $WORKDIR
    tf workspace /delete /noprompt $TESTNAME
    rmdir -recurse -force $WORKDIR
    popd
}

function BuildSolution()
{
    write-host "Starting build process"
    pushd $WORKDIR
    msbuild $SLNFILE /target:clean 
    msbuild $SLNFILE /target:build 
    popd
}

function RunModelTests()
{
    write-host "Running tests"
    pushd $WORKDIR
    mstest /testcontainer:"$UNIT_TEST_DLL" 
    popd
}

$TFSTIME=(measure-command { GetFromTFS 2>&1 | Log }).TotalSeconds
$CHKOUTTIME=(measure-command { CheckOutFile 2>&1 | Log } ).TotalSeconds
$UNDOTIME=(measure-command { UndoCheckOut 2>&1 | Log } ).TotalSeconds
$VSTIME=(measure-command { BuildSolution 2>&1 | Log }).TotalSeconds
$TESTTIME=(measure-command { RunModelTests 2>&1 | Log }).TotalSeconds

CleanUp 

$TOTALTIME=$TFSTIME + $CHKOUTTIME + $UNDOTIME + $VSTIME + $TESTTIME 

write-host "----- Results -----"
write-host "Spent $TFSTIME seconds getting stuff from TFS"
write-host "Spent $CHKOUTTIME seconds checking out 1 file from TFS"
write-host "Spent $UNDOTIME seconds undoing checkout from TFS"
write-host "Spent $VSTIME seconds building in VS"
write-host "Spent $TESTTIME seconds running tests"
write-host "Spent $TOTALTIME seconds in total"
