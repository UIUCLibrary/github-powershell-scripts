#Prerequisite modules
# JiraPS: https://atlassianps.org/module/JiraPS/
# GIthub Module: https://duckduckgo.com/?q=github+powershell+module&ia=web
#Example usage
# .\add-issues.ps1 -ownername uiuclibrary -repositoryname feed-business-office -JIRAProject BINF

param ( $OwnerName, $RepositoryName, $JIRAProject )

$issues = Get-JiraIssue -Query "project = $JIRAProject" | select-object summary, status, Key

foreach ($issue in $issues) {
    
    if ($issue.Status -eq "Closed" -or $issue.Status -eq "Resolved" -or $issue.Status -eq "Done") { $ProjectColumn = "Done" }
    elseif ($issue.Status -eq "Open" -or $issue.Status -eq "To Do") {
        $ProjectColumn = "To Do"
    }
    
    #I don't think this is necessary, but left it in anyways.
    $summary = $Issue.summary | out-string

    Get-GitHubProject -OwnerName $OwnerName -RepositoryName $RepositoryName | Get-GitHubProjectColumn | where-object { $_.name -eq $ProjectColumn } | New-GitHubProjectCard -Note $summary
}
