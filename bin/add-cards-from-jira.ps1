#Prerequisite modules
# JiraPS: https://atlassianps.org/module/JiraPS/
# GIthub Module: https://github.com/Microsoft/PowerShellForGitHub
#Example usage
# New-JiraSession -credential netid
# .\add-cards-from-jira.ps1 -ownername uiuclibrary -repositoryname feed-business-office -JIRAProject BINF -ProjectName nameofproject

param ( $OwnerName, $RepositoryName, $ProjectName, $JIRAProject )

$issues = Get-JiraIssue -Query "project = $JIRAProject" | select-object summary, status, Key

#Define ProjectName if not defined
if (!$ProjectName) {$ProjectName = $RepositoryName}

foreach ($issue in $issues) {
    
    if ($issue.Status -eq "Closed" -or $issue.Status -eq "Resolved" -or $issue.Status -eq "Done") { $ProjectColumn = "Done" }
    elseif ($issue.Status -eq "Open" -or $issue.Status -eq "To Do" -or $issue.Status -eq "Backlog") { $ProjectColumn = "To Do" }
    elseif ($issue.Status -eq "Selected for Development" -or $issue.status -eq "In Progress") {$ProjectColumn = "In Progress"}
    else {$StatusUnknown}
    
    #I don't think this is necessary, but left it in anyways.
    $summary = $Issue.summary | out-string


    if ($StatusUnknown) {Write-Output "Status is $issue.status which is not mapped to a value in the script."}
    else {
        Get-GitHubProject -OwnerName $OwnerName -RepositoryName $RepositoryName | where-object name -eq $ProjectName | Get-GitHubProjectColumn | where-object { $_.name -eq $ProjectColumn } | New-GitHubProjectCard -Note $summary
    }
}