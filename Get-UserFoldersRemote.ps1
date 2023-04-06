# Get-UserFoldersRemote.ps1
# A script to get the names of all user folder names on remote computers and save them to a CSV file

# Set the path to the Users directory
$UsersPath = "C:\Users"

# Set the file paths
$OutputFile = "UserFolders.csv"
$ComputerHostnamesFile = "ComputerHostnames.txt"

# Get the list of remote computer hostnames from the text file
$RemoteComputers = Get-Content -Path $ComputerHostnamesFile

# Initialize an empty array for the output data
$OutputData = @()

# Loop through each remote computer
foreach ($Computer in $RemoteComputers) {
    # Check if the remote computer is accessible
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
        # Get the list of user folders on the remote computer
        $UserFolders = Invoke-Command -ComputerName $Computer -ScriptBlock {
            Get-ChildItem -Path $Using:UsersPath -Directory
        }

        # Save the hostnames and user folders to the output data
        foreach ($Folder in $UserFolders) {
            $OutputData += [PSCustomObject]@{
                'Hostname'   = $Computer
                'UserFolder' = $Folder.Name
            }
        }
    } else {
        Write-Warning "Unable to connect to $Computer."
    }
}

# Write the output data to the CSV file
$OutputData | Export-Csv -Path $OutputFile -NoTypeInformation
