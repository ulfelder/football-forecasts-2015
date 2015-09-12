library(dplyr)

setwd("~/football-forecasts/")

# DATA-PROCESSING FUNCTIONS

# Load and prep 2013 and 2014 game results data from https://github.com/devstopfix/nfl_results
scoreprep <- function(year) {
    require(dplyr)
    url <- paste0("https://raw.githubusercontent.com/devstopfix/nfl_results/master/nfl%20", year, ".csv")
    df <- url %>% 
        read.csv(., stringsAsFactors=FALSE) %>%
        mutate(netscore = home_score - visitors_score,
               homewin = ifelse(netscore > 0, 1, 0),
               date = as.Date(substr(kickoff, 1, 10), format="%Y-%m-%d") )
    return(df)
}

# Ingest and scrub the wiki scores and make lists with original, home, and visitor versions for easier melding at next step
wikiprep <- function(filename) {
    require(dplyr)
    df <- read.csv(filename, stringsAsFactors=FALSE) %>%  # get the table
        filter(User.Submitted==FALSE) %>%  # Get rid of rows for teams added by voters
        select(Idea.Text, Score) %>%  # cut down to team name and wiki score
        mutate(Idea.Text = sub("\\[redacted\\]", "Redskins", Idea.Text))  # put icky team name back for merging
    home <- transmute(df, home_team = sapply(Idea.Text, function(s) strsplit(s, " ")[[1]][length(strsplit(s, " ")[[1]])]), # extract mascot name rowwise 
        wiki_home = Score)
    visitor <- transmute(df, visiting_team = sapply(Idea.Text, function(s) strsplit(s, " ")[[1]][length(strsplit(s, " ")[[1]])]),
        wiki_visitor = Score)
    ls <- list(original = df, home = home, visitor = visitor)
    return(ls)
}

# Function to meld them and calculate difference in wiki scores
blendit <- function(listslot) {
    require(dplyr)
    df <- left_join(scores[[listslot]], wikis[[listslot]]$home) %>% # 
        left_join(., wikis[[listslot]]$visitor) %>%
        mutate(wiki_diff = wiki_home - wiki_visitor)
    return(df)
}

# DATA INGESTION AND MELDING

scores <- lapply(as.list(seq(2013, 2014)), scoreprep)
wikis <- lapply(as.list(list.files()[grep("wiki", list.files())]), wikiprep)
combos <- lapply(seq(length(scores)), blendit)
master <- Reduce(function(...) merge(..., all=TRUE), combos)

write.csv(master, "historical.data.csv", row.names=FALSE)  # make a local copy just in case

rm(scores, wikis, combos)

    