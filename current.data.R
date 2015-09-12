# Load required packages
library(readxl)
library(dplyr)
library(stringr)
library(tidyr)

setwd("~/football-forecasts")

# Ingest Excel schedule downloaded on 2015-08-11 from:
# https://excelfantasyfootball.wordpress.com/2015/04/26/nfl-2015-schedule-free-excel-spreadsheet/,
Schedule <- read_excel("nfl-2015-schedule.xlsx")[,1:6] %>%  # cut Bye Week column, which is not tidy
    mutate(Home = sub("@", "", Home),  # get rid of @ in front of home team's name
           Week = as.numeric(sub("WEEK ", "", Week)))  # get rid of "WEEK " in week column and make it a number
Schedule$Date <- strsplit(Schedule$Date, " ") %>%  # get list of date parts
    sapply(., function(x) paste(x[1], sub("[a-z]{2}", "", x[2]), ifelse(x[1]=="January", 2016, 2015), sep=" "))  # assemble date from parts
Schedule$Date <- with(Schedule, as.POSIXct(paste(Date, sub(" ET", "", Time), sep=" "), format="%B %d %Y %I:%M %p"))  # convert to POSIXct format
Schedule$Time <- NULL  # drop time column, which is now redundant
names(Schedule) <- c("visiting_team", "home_team", "week", "day", "date")

# Load final preseason wiki survey scores, drop user-added idea, and subset to just team
# names & scores. (A user added a "San Francisco" idea, probably not understanding how the
# survey worked. This added idea was not approved, so it never appeared in the voting, but 
# the survey platform still includes it in the final set of ideas.)
wiki2015 <- read.csv("nfl.2015.wiki.scores.20150908.csv", stringsAsFactors=FALSE)
wiki2015 <- subset(wiki2015, User.Submitted==FALSE)
wiki2015 <- subset(wiki2015, select = c(Idea.Text, Score))
wiki2015$Idea.Text[wiki2015$Idea.Text=="Washington [redacted]"] <- "Washington Redskins"
wiki2015$Idea.Text[wiki2015$Idea.Text=="St. Louis Rams"] <- "St Louis Rams"

# Make identical copies with mascots only and teams IDed as both home and visitor.
teamset <- strsplit(wiki2015$Idea.Text, " ")
wiki2015.home <- data.frame(home_team = sapply(teamset, function(x) x[length(x)]), wiki_home = wiki2015$Score, stringsAsFactors=FALSE)
wiki2015.visitor <- data.frame(visiting_team = sapply(teamset, function(x) x[length(x)]), wiki_visitor = wiki2015$Score, stringsAsFactors=FALSE)
rm(teamset)

# Merge those copies with the schedule data. This will put the right survey score
# in the right column for each game.
Current <- left_join(Schedule, wiki2015.visitor) %>%  # merge visitor wiki score into schedule
    left_join(., wiki2015.home) %>%  # add home team score
    arrange(week, date, home_team) %>%  # order by week, then date/time, then home team
    mutate(wiki_diff = wiki_home - wiki_visitor)  # create column for ordered difference in strength scores

# Write the result to the working directory
write.csv(Current, "current.data.csv", row.names=FALSE)
