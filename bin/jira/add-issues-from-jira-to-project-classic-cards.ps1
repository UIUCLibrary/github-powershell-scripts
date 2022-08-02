#Prerequisite modules
# JiraPS: https://atlassianps.org/module/JiraPS/
# GIthub Module: https://github.com/Microsoft/PowerShellForGitHub
#Example usage
# New-JiraSession -credential netid

# .\add-cards-from-jira.ps1 -ownername uiuclibrary -repositoryname feed-business-office -JIRAProject BINF

param ( $OwnerName, $RepositoryName, $JIRAProject )

$issues = Get-JiraIssue -Query "project = $JIRAProject" | select-object summary, status, Description

foreach ($issue in $issues) {
    
    if ($issue.Status -eq "Closed" -or $issue.Status -eq "Resolved" -or $issue.Status -eq "Done") { $ProjectColumn = "Done" }
    elseif ($issue.Status -eq "Open" -or $issue.Status -eq "To Do" -or $issue.Status -eq "Backlog") { $ProjectColumn = "To Do" }
    elseif ($issue.Status -eq "Selected for Development" -or $issue.status -eq "In Progress") {$ProjectColumn = "In Progress"}
    else {$StatusUnknown}
    
    #I don't think this is necessary, but left it in anyways.
    $summary = $Issue.summary | out-string

    if ($StatusUnknown) {Write-Output "Status is $issue.status which is not mapped to a value in the script."}
    elseif ($ProjectColumn -ne "Done") {
        
    }
    elseif ($ProjectColumn -eq "Done"){ 
    Get-GitHubProject -OwnerName $OwnerName -RepositoryName $RepositoryName | Get-GitHubProjectColumn | where-object { $_.name -eq $ProjectColumn } | New-GitHubProjectCard -Note $summary
    }
}
