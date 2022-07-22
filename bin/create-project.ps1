<#
 .Synopsis
  Creates a Project page for selected repository with 3 columns

 .Description
 Creates a Project page for selected repository with 3 columns (To do, In progress, Done)
 
 .Parameter OwnerName
 Name of the Github Owner.
 
 .Parameter Repositories
 List of repositories
 
 .Example
   # Add a single repository project
    new-GithubKanban -OwnerName UIUCLibrary -Repositories example-repository
 .Example
   # Add Projects to all Team repositories
   Get-GithubTeamRepositories -OrganizationName UIUClibrary -TeamName ims | New-GithubKanban -OwnerName UIUCLibrary
#>
function New-GithubKanban {
    param (
        [Parameter(Mandatory = $true)]
        $OwnerName,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias(, 'Name')]
        $Repositories
    )

    Begin {}

    Process {

    foreach ($Repository in $Repositories) {
        
        if (!(Get-GitHubProject -ownername uiuclibrary -RepositoryName $Repository | Where-Object { $_.name -eq $Repository })) {
                #Initialize the Project
                $ProjectName = New-GitHubProject -OwnerName $OwnerName -ProjectName $Repository -RepositoryName $Repository
                # Get-GitHubProject -OwnerName UIUCLibrary -ProjectName library-inventory-database -RepositoryName library-inventory-database 

                #Add Kanban Columns
                New-GitHubProjectColumn -Project $ProjectName.id -ColumnName 'To do'  
                New-GitHubProjectColumn -Project $ProjectName.id -ColumnName 'In progress'
                New-GitHubProjectColumn -Project $ProjectName.id -ColumnName 'Done'
            }
            else {
                Write-Output "Repository Project with the name $Repository already exists!"
            }
       }

    }   

    End {}
}