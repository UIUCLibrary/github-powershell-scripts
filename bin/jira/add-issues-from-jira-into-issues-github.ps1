#Prerequisite modules
# JiraPS: https://atlassianps.org/module/JiraPS/
# GIthub Module: https://github.com/Microsoft/PowerShellForGitHub
#Example usage
# New-JiraSession -credential netid
# .\add-issues-from-jira-issues-github -ownername uiuclibrary -repositoryname feed-business-office -JIRAProject BINF

param ( $OwnerName, $RepositoryName, $JIRAProject )

$issues = Get-JiraIssue -Query "project = $JIRAProject" | select-object summary, status, Description

foreach ($issue in $issues) {
    
    if ($issue.Status -eq "Closed" -or $issue.Status -eq "Resolved" -or $issue.Status -eq "Done") { $issuestatus = "Closed" }
    elseif ($issue.Status -eq "Open" -or $issue.Status -eq "To Do" -or $issue.Status -eq "Backlog" -or $issue.Status -eq "Selected for Development" -or $issue.status -eq "In Progress") { $issuestatus = "Open" }
    else {$issuestatus = "Open"}
    
    $summary = $Issue.summary | out-string
    $description = $issue.Description | out-string
    # $Issue = get-githubissue -OwnerName $OwnerName -RepositoryName $RepositoryName | where-object title -like $summary 
    
    if ($issue = get-githubissue -OwnerName $OwnerName -RepositoryName $RepositoryName | where-object title -like $summary) {
        write-host "Issue already created at: $($issue.html_url)"
    }
    elseif ($issue = get-githubissue -OwnerName $OwnerName -RepositoryName $RepositoryName -State closed | where-object title -like $summary) {
        write-host "Issue already created at: $($issue.html_url)"
    }
    else{
        # write-host "creating issue"
        try {
            Get-GitHubRepository -OwnerName $OwnerName -RepositoryName $RepositoryName | New-GitHubIssue -Title $summary -Body $description
        }
        catch {
            start-sleep -Seconds 60
            Get-GitHubRepository -OwnerName $OwnerName -RepositoryName $RepositoryName | New-GitHubIssue -Title $summary -Body $description
        }
    }

    Get-Githubissue -OwnerName $OwnerName -RepositoryName $RepositoryName | Where-Object title -like $summary | Set-GitHubIssue -State $issuestatus
}
