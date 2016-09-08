#!powershell
# This file is part of Ansible
#
# Copyright 2016, Mike Fennemore <mike.fennemore@sentia.com>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.


# WANT_JSON
# POWERSHELL_COMMON

$params = Parse-Args $args;
$result = New-Object PSObject;
Set-Attr $result "changed" $false;

$name = Get-Attr -obj $params -name name -failifempty $true -emptyattributefailmessage "missing required argument: name"
$memory = Get-Attr -obj $params -name memory -default '512MB'
$hostserver = Get-Attr -obj $params -name hostserver 
$generation = Get-Attr -obj $params -name generation -default 2

$diskpath = Get-Attr -obj $params -name diskpath -default $null

$showlog = Get-Attr -obj $params -name showlog -default "false" | ConvertTo-Bool
$state = Get-Attr -obj $params -name state -default "present"

if ("present","absent","restart","start","shutdown" -notcontains $state)
{
    Fail-Json $result "state is $state; must be present or absent"
}


Function VM-Create
{
    #Check Hyper-V is installed
	
	$cmd = "New-VM -Name $name"
	
	if ($memory)
    {
        $cmd += " -MemoryStartupBytes $memory"
    }
	
	if ($hostserver)
    {
        $cmd += " -ComputerName $hostserver"
    }
	
	if ($generation)
    {
        $cmd += " -Generation $generation"
    }
	
	if ($diskpath)
    {
	#If VHD already exists then attach it, if not create it
		if (Test-Path $path)
		{
			$cmd += " -VHDPath $diskpath"
		}
		else
		{
			$cmd += " -NewVHDPath $diskpath" 
		}  
    }
	
	$results = invoke-expression $cmd
	$result.changed = $true
}


Function VM-Delete
{

    $cmd="Remove-VM -Name $name -Force"
	$results = invoke-expression $cmd
	$result.changed = $true
	
}

<#

Function VM-Restart
{

    if (-not (Choco-IsInstalled $package))
    {
        throw "$package is not installed, you cannot upgrade"
    }

    $cmd = "$executable upgrade -dv -y $package"

    if ($version)
    {
        $cmd += " -version $version"
    }

    if ($source)
    {
        $cmd += " -source $source"
    }

    if ($force)
    {
        $cmd += " -force"
    }

    if ($installargs)
    {
        $cmd += " -installargs '$installargs'"
    }

    if ($packageparams)
    {
        $cmd += " -params '$packageparams'"
    }

    if ($ignoredependencies)
    {
        $cmd += " -ignoredependencies"
    }

    $results = invoke-expression $cmd

    if ($LastExitCode -ne 0)
    {
        Set-Attr $result "choco_error_cmd" $cmd
        Set-Attr $result "choco_error_log" "$results"
        Throw "Error installing $package" 
    }

    if ("$results" -match ' upgraded (\d+)/\d+ package\(s\)\. ')
    {
        if ($matches[1] -gt 0)
        {
            $result.changed = $true
        }
    }
}

Function VM-Start 
{
    [CmdletBinding()]
    
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$package,
        [Parameter(Mandatory=$false, Position=2)]
        [string]$version,
        [Parameter(Mandatory=$false, Position=3)]
        [string]$source,
        [Parameter(Mandatory=$false, Position=4)]
        [bool]$force,
        [Parameter(Mandatory=$false, Position=5)]
        [bool]$upgrade,
        [Parameter(Mandatory=$false, Position=6)]
        [string]$installargs,
        [Parameter(Mandatory=$false, Position=7)]
        [string]$packageparams,
        [Parameter(Mandatory=$false, Position=8)]
        [bool]$ignoredependencies
    )

    if (Choco-IsInstalled $package)
    {
        if ($upgrade)
        {
            Choco-Upgrade -package $package -version $version -source $source -force $force `
                -installargs $installargs -packageparams $packageparams `
                -ignoredependencies $ignoredependencies
        }

        return
    }

    $cmd = "$executable install -dv -y $package"

    if ($version)
    {
        $cmd += " -version $version"
    }

    if ($source)
    {
        $cmd += " -source $source"
    }

    if ($force)
    {
        $cmd += " -force"
    }

    if ($installargs)
    {
        $cmd += " -installargs '$installargs'"
    }

    if ($packageparams)
    {
        $cmd += " -params '$packageparams'"
    }

    if ($ignoredependencies)
    {
        $cmd += " -ignoredependencies"
    }

    $results = invoke-expression $cmd

    if ($LastExitCode -ne 0)
    {
        Set-Attr $result "choco_error_cmd" $cmd
        Set-Attr $result "choco_error_log" "$results"
        Throw "Error installing $package" 
    }

     $result.changed = $true
}

Function VM-Stop
{
    [CmdletBinding()]
    
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$package,
        [Parameter(Mandatory=$false, Position=2)]
        [string]$version,
        [Parameter(Mandatory=$false, Position=3)]
        [bool]$force
    )

    if (-not (Choco-IsInstalled $package))
    {
        return
    }

    $cmd = "$executable uninstall -dv -y $package"

    if ($version)
    {
        $cmd += " -version $version"
    }

    if ($force)
    {
        $cmd += " -force"
    }

    $results = invoke-expression $cmd

    if ($LastExitCode -ne 0)
    {
        Set-Attr $result "choco_error_cmd" $cmd
        Set-Attr $result "choco_error_log" "$results"
        Throw "Error uninstalling $package" 
    }

     $result.changed = $true
}

#>

Try
{
    switch ($state)
	{
		"present" {VM-Create}
		"absent" {VM-Delete}
	}

    Exit-Json $result;
}
Catch
{
     Fail-Json $result $_.Exception.Message
}

