### Helper functions for scripting against SQL Server ###

## Open a db connection 
function OpenServerConnection( [string]$servername, [string]$dbname, [string]$dblogin, [string]$dbpasswd  )
{
    $conn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
    $conn.ServerInstance = $servername
    $conn.DatabaseName = $dbname	
    if( $dblogin -and $dbpasswd )
    {
        $conn.LoginSecure = false
        $conn.Login = $dblogin
        $conn.Password = $dbpasswd
    }
    [void]$conn.Connect()
    if( $conn.IsOpen )
    {
        return $conn
    }
    throw "Connection not open"
}

# Open a database
function OpenDb( [string]$servername, [string]$dbname, [string]$dblogin, [string]$dbpasswd )
{
    $conn = OpenServerConnection $servername $dbname $dblogin $dbpasswd
    $srvr = new-object Microsoft.SqlServer.Management.Smo.Server $conn
    #$db=$srvr.Databases[$dbname]
    if( $srvr.Databases.Contains($dbname) )
    {
        return $srvr.Databases[$dbname]
    }
    throw "Database $dbname not found"
}


### Load the Server Management Object assemblies
function LoadSMOAssemblies()
{
    if( $SMOAssembliesLoaded ){  return  }

    #
    # Loads the SQL Server Management Objects (SMO)
    #
    $ErrorActionPreference = "Stop"
    $sqlpsreg="HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps"

    if (Get-ChildItem $sqlpsreg -ErrorAction "SilentlyContinue")
    {
        throw "SQL Server Provider is not installed."
    }
    else
    {
        $item = Get-ItemProperty $sqlpsreg
        $sqlpsPath = [System.IO.Path]::GetDirectoryName($item.Path)
    }

    $assemblylist = 
        "Microsoft.SqlServer.Smo",
        "Microsoft.SqlServer.Dmf ",
        "Microsoft.SqlServer.SqlWmiManagement ",
        "Microsoft.SqlServer.ConnectionInfo ",
        "Microsoft.SqlServer.SmoExtended ",
        "Microsoft.SqlServer.Management.RegisteredServers ",
        "Microsoft.SqlServer.Management.Sdk.Sfc ",
        "Microsoft.SqlServer.SqlEnum ",
        "Microsoft.SqlServer.RegSvrEnum ",
        "Microsoft.SqlServer.WmiEnum ",
        "Microsoft.SqlServer.ServiceBrokerEnum ",
        "Microsoft.SqlServer.ConnectionInfoExtended ",
        "Microsoft.SqlServer.Management.Collector ",
        "Microsoft.SqlServer.Management.CollectorEnum"
    
    foreach ($asm in $assemblylist)
    {
        $asm = [Reflection.Assembly]::LoadWithPartialName($asm)
    }

#    Push-Location
#    cd $sqlpsPath
#    update-FormatData -prependpath SQLProvider.Format.ps1xml 
#    Pop-Location

    Set-Variable SMOAssembliesLoaded -Value $true -scope Global -Option ReadOnly -Description 'Shows if the LoadSMOAssemblies function has run' 
}


### Load the SQL Server powershell snap-ind and cmd-lets
function InitializeSqlProvider()
{
    if( $SqlProviderInitialized ) { return }
    
    $null = LoadSMOAssemblies
    
    #
    # Add the SQL Server provider.
    #
    $ErrorActionPreference = "Stop"
    $sqlpsreg="HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps"

    if (Get-ChildItem $sqlpsreg -ErrorAction "SilentlyContinue")
    {
        throw "SQL Server Provider is not installed."
    }
    else
    {
        $item = Get-ItemProperty $sqlpsreg
        $sqlpsPath = [System.IO.Path]::GetDirectoryName($item.Path)
    }
    
    #
    # Set mandatory variables for the SQL Server rovider
    #
    Set-Variable -scope Global -name SqlServerMaximumChildItems -Value 0
    Set-Variable -scope Global -name SqlServerConnectionTimeout -Value 30
    Set-Variable -scope Global -name SqlServerIncludeSystemObjects -Value $false
    Set-Variable -scope Global -name SqlServerMaximumTabCompletion -Value 1000

    #
    # Load the snapins, type data, format data
    #
    Push-Location
    cd $sqlpsPath
    Add-PSSnapin SqlServerCmdletSnapin100
    Add-PSSnapin SqlServerProviderSnapin100
    Update-TypeData -PrependPath SQLProvider.Types.ps1xml 
    update-FormatData -prependpath SQLProvider.Format.ps1xml 
    Pop-Location
    

}

if( !($SqlProviderInitialized) ) 
{
    . InitializeSqlProvider
    Set-Variable SqlProviderInitialized -Value $true -scope Global -Option ReadOnly -Description 'Shows if the InitializeSqlProvider function has run' 
}