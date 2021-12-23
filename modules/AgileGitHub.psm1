<#

.DESCRIPTION

Build and invoke lists of queries for use with Get-GitHubIssues, to help 
reliably search all repositories that are of interest to you.

Relies $ENV:GITHUB_REPOS being set in the environment.

.EXAMPLE

$ENV:GITHUB_REPOS = @('org/repo1', 'org2/repo2')

#>

<#
.SYNOPSIS

Call this to verify your $ENV:GITHUB_REPOS variable is set correctly for this 
module.

.EXAMPLE

$ENV:GITHUB_REPOS = @('org/repo1', 'org2/repo2')
Get-AgileRepos

#>
function Get-AgileRepos {
    return $ENV:GITHUB_REPOS.split(" ")
}

<#

.SYNOPSIS

Get queries to pass to Get-GitHubIssues based on your $ENV:GITHUB_REPOS
environment setting.

.EXAMPLE

$ENV:GITHUB_REPOS = @('org/repo1', 'org2/repo2')
$issues = @()
$queries = Get-AgileQuery -state 'Open'
$queries | ForEach-Object { 
    $query = $_
    $issues += Get-GitHubIssue @query
}
($issues | Measure-Object).Count


#>
function Get-AgileQuery {
    param(
        [switch]$mine,
        [string]$assignee,
        [string]$sort = "updated",
        [string]$state = 'Open',
        [string]$direction = "Descending"
    )
    $queries = @()
    Get-AgileRepos | ForEach-Object {
        $owner, $repo = $_.split('/')
        $query = @{
            OwnerName = $owner
            RepositoryName = $repo
            State = $state
            Sort = $sort
            Direction = $direction
        }
        if($mine) {
            $query['Assignee'] = $ENV:GITHUB_USERNAME
        }
        if($assignee) {
            $query['Assignee'] = $assignee
        }
        $queries += $query
    }
    return $queries
}

<#

.SYNOPSIS

Invoke queries with Get-GitHubIssues, gathering the returned issue objects.
Typically used with Get-AgileQuery.

.EXAMPLE

$ENV:GITHUB_REPOS = @('org/repo1', 'org2/repo2')
$issues = Invoke-AgileQuery -queries (Get-AgileQuery -closed)
($issues | Measure-Object).Count
$issues | Show-MarkdownFromGitHub

#>
function Invoke-AgileQuery {
    param(
        [hashtable[]]$queries
    )
    $results = @()
    $repo_count = 0
    $progress = 0
    $queries | ForEach-Object {
        $query = $_

        # Show progress
        $repo_count += 1
        $progress = ($repo_count / $queries.Count) * 100
        $name = $query.RepositoryName
        Write-Progress -Activity "Fetching Issues..." -Status $name -PercentComplete $progress

        # Fetch data
        $issues = Get-GitHubIssue @query
        $results += $issues
    }
    return $results
}

<#
.SYNOPSIS

Fetch GitHub issues starting with the oldest updated date.

.EXAMPLE

$oldest = Get-AgileOldest
$oldest[0].updated_at
$oldest[0].html_url
$oldest[0..10] | Show-MarkdownFromGitHub

#>
function Get-AgileOldest {
    $issues = Invoke-AgileQuery -queries (
        Get-AgileQuery -sort "updated" -direction "Ascending"
    )
    return $issues
}

<#
.SYNOPSIS

Select GitHub issues that are tagged to discuss at the Stand Up meeting.

#>
function Select-AgileToDiscuss {
    begin{
        $results = @()
    }
    process{
        foreach ($label in $_.labels) {
            if($label.name -Contains "DiscussAtStandUp") {
                $results += $_
            }
        }
        if($_.labels -Contains 'DiscussAtStandUp') {
        }
    }
    end{
        return $results
    }
}

<#
.SYNOPSIS

Fetch closed GitHub issues last updated within the given date range.

.EXAMPLE

$issues = Get-AgileByAge -updated 2021-07-01..2021-09-19
$issues.Count

.EXAMPLE

$issues = Get-AgileByAge -days_ago 14
$issues.Count

#>
function Select-AgileByAge {
    param(
        [string]$updated,
        [int]$days_ago
    )
    begin {
        $results = @()
        if($days_ago -And $updated) {
            thow "-Updated and -DaysAgo cannot be used together."
        }
        if($days_ago){
            $to_dt = (Get-Date).Add(900) # Set to far future to ignore.
            $from_dt = (Get-Date).AddDays(0 - $days_ago)
        }
        if($updated){
            $from, $to = $updated.replace('..', '|').split('|')
            $from_dt = Get-Date -Date $from
            $to_dt = Get-Date -Date $to
        }
    }
    process {
        if(($_.updated_at -gt $from_dt) -And ($_.updated_at -lt $to_dt)) {
            $results += $_
        }
    }
    end {
        return $results
    }
}



<#
.SYNOPSIS

Display Get-AgileToDiscuss results as Markdown.

#>
function Show-AgileToDiscuss {
    $queries = Get-AgileQuery -State 'Open'
    $issues = Invoke-AgileQuery -queries $queries
    $issues = $issues | Select-AgileToDiscuss
    $issues | Show-MarkdownFromGitHub
}

<#
.SYNOPSIS

Display Get-AgileByAge results as Markdown.

.EXAMPLE

Show-AgileByAge | Out-File SeptIssues.md


#>
function Show-AgileByAge {
    param(
        [string]$updated,
        [int]$days_ago,
        [string]$state = "Open"
    )
    $queries = Get-AgileQuery -State $state 
    $issues = Invoke-AgileQuery -queries $queries
    if($updated) {
        $issues = $issues | Select-AgileByAge -updated $updated
    }
    if($days_ago) {
        $issues = $issues | Select-AgileByAge -days_ago $days_ago 
    }
    $issues | Show-MarkdownFromGitHub
}

<#
.SYNOPSIS

Display Get-AgileOldIssues results as Markdown.

.EXAMPLE

Show-AgileOldest | Out-File OldestIssues.md

#>
function Show-AgileOldest {
    Get-AgileOldest | Show-MarkdownFromGitHub
}


# Export Core Functions
Export-ModuleMember -Function Get-AgileRepos
Export-ModuleMember -Function Get-AgileQuery
Export-ModuleMember -Function Invoke-AgileQuery

# Export Select- and Get- functions.
Export-ModuleMember -Function Select-AgileToDiscuss
Export-ModuleMember -Function Select-AgileByAge
Export-ModuleMember -Function Get-AgileOldest

# Export Show- functions.
Export-ModuleMember -Function Show-AgileToDiscuss
Export-ModuleMember -Function Show-AgileByAge
Export-ModuleMember -Function Show-AgileOldest
