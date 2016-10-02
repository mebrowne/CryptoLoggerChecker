[CmdletBinding()]
# Declare Variables

#Check for Existing Files

# Prompt for Information
param(
	[Paramater(Mandatory=$True)]
		[string[]]$Path,
	[Paramater(Mandatory=$True)]
		[string]$EncryptionExtension,
	[Switch]$LeaveFiles,
	[Switch]$Force,
	[Switch]$MultipleDirectories,
	[Switch]$AlternateTempDirectory
)

New-Item -ItemType 'Directory' $Path\Temp
New-Item $Path\Temp\MissingFiles.txt
New-Item $Path\Temp\FoundFiles.txt
New-Item $Path\Temp\CleanFiles.txt
New-Item $Path\Temp\EncryptedFiles.txt

# Old Version
# $Path = Read-Host -prompt 'Path?'
# $EncryptionExtension = Read-Host -prompt 'Encryption Extension without period?'

#Ensure that Extension does not contain .
if (
	$EncryptionExtension.contains(“.”)
	) {Write-Error "Please rerun script and specify the file extension without the period. e.g. If the file is foo.exe.LOL! enter LOL!"
	Exit
}

#Exports a list of Encrypted and non-encrypted files for comparison purposes. 
$CleanFiles = Get-ChildItem -name -file -exclude *.$EncryptionExtension -path $Path |
	Out-File $Path\CleanFiles.txt
$EncryptedFiles = Get-ChildItem -name -file -filter *.$EncryptionExtension -path $Path |
	Out-File $Path\EncryptedFiles.txt
		
#Comparing File counts to inform whether there are missing/extra files
$FilesDifference = $EncryptedFiles.count - $CleanFiles.count
if ($FilesDifference -eq 0)
	{Write-Output "Same number of clean and encrypted files"}
	Elseif ($FilesDifference -lt 0)
		{Write-Error "More Clean Files than Encrypted files."}
	Else
		{Write-output "There are $FilesDifference extra encrypted files in the directory."
	
#Create set of file names with Encrypted Extension
$CleanFiles |
	ForEach {
		Write-Verbose $_'.$EncryptionExtension'
		} | Out-File $Path\Temp\CleanFilesWithExtension.txt
$CleanFilesWithExtension = Get-Content $Path\Temp\CleanFilesWithExtension.txt

$CleanFilesWithExtension | 
	ForEach {
		$Status = $EncryptedFiles -contains "$_"
		if ($Status = $True) {
			Write-Verbose "$_ found" |
			Add-Content $Path\FoundFiles.txt
		}
		Else {
			Write-Output "$_ not present!" |
			Add-Content $Path\MissingFiles.txt
		}
	}
		
if ($LeaveFiles -eq $False) {
	Remove-Item $Path\Temp\CleanFiles.txt 
	Remove-Item $Path\Temp\EncryptedFiles.txt
	Remove-Item $Path\Temp\CleanFilesWithExtension.txt
}

Write-Output "Operation Completed. A list of files with an encrypted analog are found in $Path\FoundFiles.txt. A list of all files without an encrypted analog can be found in $Path\MissingFiles.txt"
