# Import
1) Create a project and 3 columns for desired project
2) Run the add-cards-from jira.ps1
3) Login to JIRA
    `New-JiraSession -credential netid`
4)

#### Redo Import
Purge cards
```
Get-GitHubProject -OwnerName UIUCLibrary -RepositoryName Repository name | Get-GitHubProjectColumn | Get-GitHubProjectCard | Remove-GitHubProjectCard
```
