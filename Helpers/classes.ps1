Class ThePerfectCanidate
{
    Hidden [String]$FirstName
    Hidden [String]$LastName
    [String]$FullName
    [String]$Phone
    [String]$Email
    [String]$Location
    [Int]$YearsOfExperience
    [Array]$WorkHistory
    [Array]$Skills
    Hidden $RawData
    
    # Constructor
    ThePerfectCanidate($Resume)
    {
        $Resume = $Resume | ConvertFrom-Json -Depth 5
        $This.FirstName = $Resume.basics.FirstName
        $This.LastName = $Resume.basics.LastName
        $This.FullName = $This.FirstName + " " + $This.LastName
        $This.Phone = $Resume.basics.phone
        $This.Email = $Resume.basics.email
        $This.Location = $Resume.basics.location.city + ", " + $Resume.basics.location.state
        $This.WorkHistory = $Resume.experience | % {[WorkHistoryEntry]::New($_)}
        $This.YearsOfExperience = $This.CalculateTotalYearsOfExperience()
        $This.Skills = $Resume.skills
    }

    Hidden [Int]CalculateTotalYearsOfExperience()
    {
        Return [Math]::Ceiling((($This.WorkHistory.EmploymentLengthMonths | Measure-Object -Sum).Sum /12))
    }

    [Object]ContactDetails()
    {
        Return [PSCustomObject]`
        @{
            Name = $This.FullName
            Phone = $This.Phone
            Email = $This.Email
        }
    }
    [WorkHistoryEntry]CurrentPosition()
    {
        Return $This.WorkHistory | Where {$_.endDate -eq 'Present'}
    }
}

Class WorkHistoryEntry
{
    [String]$Company
    [String]$Location
    [String]$Position
    [String]$StartDate
    [String]$EndDate
    [String]$EmploymentLength
    Hidden [Int]$EmploymentLengthYears
    Hidden [Int]$EmploymentLengthMonths
    Hidden $EmploymentHighlights

    WorkHistoryEntry($WorkHistoryInput)
    {
        $This.Company = $WorkHistoryInput.company
        $This.Location = $WorkHistoryInput.location
        $This.Position = $WorkHistoryInput.position
        $This.StartDate = $WorkHistoryInput.startDate
        $This.EndDate = $WorkHistoryInput.endDate
        $This.EmploymentLength = $This.GetEmploymentLength()
        $This.EmploymentHighlights = $WorkHistoryInput.highlights
    }

    [String]GetEmploymentLength()
    {
        $Years = 0
        $Months = [Math]::Round((New-TimeSpan -Start $This.StartDate -End ($This.EndDate -eq 'Present' ? [DateTime]::Now : $This.EndDate)).TotalDays /30)
        $This.EmploymentLengthMonths = $Months
        While ($Months -gt 12)
        {
            $Years ++
            $Months = $Months - 12
        }
        $This.EmploymentLengthYears = $Years
        
        Return $Years -Ge 1 ? "$Years Year(s) $Months Month(s)" : "$Months Month(s)"
    }
    
    [String]GetEmploymentHighlights()
    {
        $FormattedOutput = $This.EmploymentHighlights | % `
        {
           "`n- $($_)"
        }
        Return $FormattedOutput
    }

    [String]ToString()
    {
        Return "$($This.Position) ($($This.StartDate)-$($This.EndDate))"
    }
}
