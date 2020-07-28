# We use some inline (immediate) if statements and those require Powershell V7 (Which you should be using anyways.)
#Requires -Version 7.0

# Dot source in helpers
. $PSScriptRoot/helpers/classes.ps1
. $PSScriptRoot/helpers/functions.ps1

# Import the JSON version of my Resume
Try
{
    $Resume = Get-Content "$PSScriptRoot/helpers/resume.json" -ErrorAction 'Stop'
}
Catch
{
    Throw "Error importing Resume JSON! $_"
}

# Create the Perfect Canidate (The one and onlu)
$Canidate = [ThePerfectCanidate]::New($Resume)

# Clear the host and enter the Main Menu loop
Clear-Host
Do
{
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input)
    {
        '1'
        {
            Clear-Host
            'Contact Details'
            $Canidate.ContactDetails() | FT
        } 
        '2'
        {
            Clear-Host
            'Current Position'
            $CurrentPosition = $Canidate.CurrentPosition()
            $CurrentPosition | FT
            $CurrentPosition.GetEmploymentHighlights()
        }
        '3'
        {
            Clear-Host
            'Work History Overview'
            $Canidate.WorkHistory | FT
            Write-Host "A combined total of $($Canidate.YearsOfExperience) years' of experience."
        }
        '4'
        {
            Clear-Host
            'Work History Details'
            $Canidate.WorkHistory | % `
            {
                $_ | FT
                $_.GetEmploymentHighlights()
            }
        
        }
        '5'
        {
            Clear-Host
            'Skills'
            $Canidate.Skills | % `
            {
                Write-Host "_______$($_.Name)________"
                $_.keywords
                Write-Host `r`n
            }
        }
        'q'
        {
            Return
        }
    }
    Pause
}
Until ($input -eq 'q')