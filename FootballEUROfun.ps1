################################################################
# The examples below require an api key from football-data.org #
################################################################


#################################################################
#SHOW ALL GAMES IN TABLE FORMAT INCLUDING GROUPS AND DATES
#################################################################

# Define the API endpoint and your API key
$apiUrl = "https://api.football-data.org/v2/competitions/EC/matches"
$apiKey = "Your api key here"

# Set the headers
$headers = @{
    "X-Auth-Token" = $apiKey
}

# Fetch live match data
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers

# Prepare the data for the table
$matches = $response.matches | ForEach-Object {
    $matchDate = [DateTime]::Parse($_.utcDate).ToLocalTime()
    [PSCustomObject]@{
        "Date" = $matchDate.ToString("yyyy-MM-dd")
        "Day" = $matchDate.DayOfWeek
        "Group" = $_.group
        "Home Team" = $_.homeTeam.name
        "Away Team" = $_.awayTeam.name
        "Home Score" = $_.score.fullTime.homeTeam
        "Away Score" = $_.score.fullTime.awayTeam
        "Status" = $_.status
    }
}

# Display the data in a table format
$matches | Format-Table -AutoSize

#############################################################################################
#SHOW GAMES BASED ON STATUS IN TABLE FORMAT INCLUDING GROUP AND DATE
#############################################################################################

# Define the API endpoint and your API key
$apiBaseUrl = "https://api.football-data.org/v2"
$apiKey = "Your api key here"

# Set the headers
$headers = @{
    "X-Auth-Token" = $apiKey
}

# Function to fetch match data
function Get-MatchData {
    param (
        [string]$competitionId = "EC",
        [string]$status
    )
    $url = "$apiBaseUrl/competitions/$competitionId/matches?status=$status"
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    return $response.matches
}

# Function to display match data in a table format
function Display-MatchData {
    param (
        [array]$matches
    )

    $table = @()

    $matches | ForEach-Object {
        $matchDate = [DateTime]::Parse($_.utcDate).ToLocalTime()
        $table += [PSCustomObject]@{
            Date = $matchDate.ToString("yyyy-MM-dd")
            Day = $matchDate.DayOfWeek
            Group     = $_.group
            HomeTeam  = $_.homeTeam.name
            AwayTeam  = $_.awayTeam.name
            HomeScore = $_.score.fullTime.homeTeam
            AwayScore = $_.score.fullTime.awayTeam
            Status    = $_.status
        }
    }

    $table | Format-Table -AutoSize
}

# Main script logic
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("FINISHED", "IN_PLAY", "SCHEDULED")]
    [string]$matchStatus
)

# Fetch and display match data based on the provided status
$matches = Get-MatchData -status $matchStatus
Display-MatchData -matches $matches

#############################################################################################
#SHOW TOP 10 SCORERS IN TABLE FORMAT
#############################################################################################


# Define the API endpoint and your API key
$apiBaseUrl = "https://api.football-data.org/v2"
$apiKey = "Your api key here"

# Set the headers
$headers = @{
    "X-Auth-Token" = $apiKey
}

# Function to fetch top scorers
function Get-TopScorers {
    param (
        [string]$competitionId = "EC"
    )
    $url = "$apiBaseUrl/competitions/$competitionId/scorers"
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    return $response.scorers
}

# Function to display top scorers in a table format
function Show-TopScorers {
    param (
        [array]$scorers,
        [int]$topN = 10
    )

    $topScorers = $scorers | Select-Object -First $topN

    $table = @()
    foreach ($scorer in $topScorers) {
        $table += [PSCustomObject]@{
            Position = ($topScorers.IndexOf($scorer) + 1)
            Player   = $scorer.player.name
            Team     = $scorer.team.name
            Goals    = $scorer.numberOfGoals
        }
    }

    $table | Format-Table -AutoSize
}

# Fetch top scorers
$topScorers = Get-TopScorers

# Show top 10 scorers
Show-TopScorers -scorers $topScorers

#############################################################################################
#SHOW TOP 10 GAMES THE MOST GOALS SCORED AS A TABLE
#############################################################################################

# Define the API endpoint and your API key
$apiBaseUrl = "https://api.football-data.org/v2"
$apiKey = "your api key here"


# Set the headers
$headers = @{
    "X-Auth-Token" = $apiKey
}

# Function to fetch match data
function Get-MatchData {
    param (
        [string]$competitionId = "EC"
    )
    $url = "$apiBaseUrl/competitions/$competitionId/matches"
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    return $response.matches
}

# Function to display games with the most goals scored as a table
function Show-GamesWithMostGoals {
    param (
        [array]$matches,
        [int]$top = 10
    )

    # Create an array of custom objects with match details and total goals
    $matchDetails = $matches | ForEach-Object {
        [PSCustomObject]@{
            Date       = (Get-Date $_.utcDate).ToString("yyyy-MM-dd")
            WeekDay    = (Get-Date $_.utcDate).DayOfWeek
            Group      = $_.group
            HomeTeam   = $_.homeTeam.name
            HomeGoals  = $_.score.fullTime.homeTeam
            AwayTeam   = $_.awayTeam.name
            AwayGoals  = $_.score.fullTime.awayTeam
            TotalGoals = ($_.score.fullTime.homeTeam + $_.score.fullTime.awayTeam)
        }
    }

    # Sort matches by the total number of goals in descending order
    $sortedMatches = $matchDetails | Sort-Object -Property TotalGoals -Descending

    # Select the top matches
    $topMatches = $sortedMatches | Select-Object -First $top

    # Display the matches as a table
    $topMatches | Format-Table -AutoSize
}

# Script execution starts here

# Specify the competition ID (example: "EC" for European Championship)
$competitionId = "EC"  # Replace with the actual competition ID if needed

# Fetch match data
$matches = Get-MatchData -competitionId $competitionId

# Show the top games with the most goals scored
Show-GamesWithMostGoals -matches $matches -top 10

#################################################################################################
