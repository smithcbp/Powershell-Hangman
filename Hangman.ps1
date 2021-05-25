<#
.SYNOPSIS
  Powershell Hangman game that uses Wheel of Fortune clues. 
.DESCRIPTION
  Uses puzzles downloaded from https://wheeloffortuneanswer.com/ and saved to a CSV located here: https://github.com/smithcbp/Powershell-Hangman/blob/main/puzzles.csv.
  Must have the script and puzzles.csv in the same folder.
  Created by Chris Smith (smithcbp on github)
#>
$title = '
    __  __                                      
   / / / /___ _____  ____ _____ ___  ____ _____ 
  / /_/ / __ `/ __ \/ __ `/ __ `__ \/ __ `/ __ \
 / __  / /_/ / / / / /_/ / / / / / / /_/ / / / /
/_/ /_/\__,_/_/ /_/\__, /_/ /_/ /_/\__,_/_/ /_/ 
                  /____/                        '
#Puzzlepath
$puzzlepath = "$PSScriptRoot\puzzles.csv"
if (!(Test-Path $puzzlepath)){Write-Error "puzzles.csv can't be found. Please download from https://github.com/smithcbp/Powershell-Hangman/blob/main/puzzles.csv and place in script folder." ; break}
$puzzles = Import-Csv $puzzlepath
#Placeholder
$ph = '▬'

##Hangman drawing function
Function Show-Hangman {
    param ($numberofturns)
    1..6 | ForEach-Object { Set-Variable -Name "t$_" -Value ' ' -Force -Scope script }
    if ($numberofturns -ge 1) { $t1 = 'O' }
    if ($numberofturns -ge 2) { $t2 = '|' }
    if ($numberofturns -ge 3) { $t3 = '/' }
    if ($numberofturns -ge 4) { $t4 = '\' }
    if ($numberofturns -ge 5) { $t5 = '/' }
    if ($numberofturns -ge 6) { $t6 = '\' } 
    Write-Host "
  +------+
     |    |
     $t1    |
    $t3$t2$t4   |
    $t5 $t6   |
          |
          |
  ==========
"
}

##Start Play Again loop
$playagain = 'y'
While ($playagain -like 'y') {
    $puzzle = $puzzles | get-random -Count 1
    $puzzlearray = $puzzle.puzzle.ToCharArray()
    
    #Initialize up some variables
    $AZ = [char[]](65..90)
    $letterguess = $null
    $MainBoard = "$ph"
    $incorrectcount = -1
    $guessedletterarray = @()
    $wrongletterarray = @()
    $correctletterarray = @()
    
    ##Start Game Loop
    While (($MainBoard -like "*$ph*") -and ($incorrectcount -lt 6)) {
        Clear-Host
        ##Track right/wrong guesses
        if (!($puzzlearray -contains $letterguess )) { $incorrectcount++ ; $wrongletterarray += $letterguess }
        if ($puzzlearray -contains $letterguess ) { $correctletterarray += $letterguess }
        ##Draw title and gameboard
        Write-Host -ForegroundColor Blue $title
        Write-Host ""
        Write-Host -ForegroundColor Cyan "Category: $($puzzle.category)"
        Show-Hangman $incorrectcount
        ##Break if 6 incorrect answers. You lose
        if ($incorrectcount -eq 6) { break }
        ##Create then display Main Letter Game Board
        $MainBoard = foreach ($character in $puzzlearray) {
            if ($guessedletterarray -match "$character") { $character = $character }
            elseif ($AZ -match $character) { $character = "$ph" }
            $character
        }
        $MainBoard -join ''
        ##Display Guessed Letters
        Write-Host ''
        Write-Host -ForegroundColor Gray "Correct Guesses: $($correctletterarray -join'')"
        Write-Host -ForegroundColor Gray "Incorrect Guesses: $($wrongletterarray -join'')"
        ##If there are still $ph in the game board, guess a letter. Loop if already guessed.
        if ($MainBoard -like "*$ph*") {
            $letterguess = Read-Host "Guess a letter"
            $letterguess = $letterguess.ToCharArray() | select -First 1
            while ($guessedletterarray -match $letterguess) { $letterguess = Read-Host "Guess a letter" }
            $guessedletterarray += $letterguess
        }
    }
    ##Loser/Winner endings
    if ($incorrectcount -eq 6) {
        Write-Host -ForegroundColor Green "$($puzzle.puzzle)"
        Write-Host -ForegroundColor Red "You Lose!"
    }
    if (!($MainBoard -like "*$ph*")) { Write-Host -ForegroundColor Yellow "Winner! The man will live!!!" }
    ##Ask to play again
    $playagain = Read-Host "Would you like to play again?(y/n)"
}
