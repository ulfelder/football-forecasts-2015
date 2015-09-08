setwd("~/football-forecasts")

set.seed(20912)

library(merTools)
library(dplyr)  # order matters here; merTools loads plyr, and you should load dplyr after plyr to avoid some function name clashes
library(tidyr)

# Create a model object based on the historical data, including playoffs but not SB (week 21) b/c no home team
Prior <- read.csv("historical.data.csv", stringsAsFactors=FALSE)
Prior <- Prior[Prior$week <= 20,]
mod0 <- lmer(netscore ~ wiki_diff + (1 | home_team), data = Prior)

# Get current-season data
Current <- read.csv("current.data.csv", stringsAsFactors=FALSE)

# Generate distributions of score forecasts using predictInterval() from merTools
nsims = 1000  # set number of simulations
sims <- predictInterval(mod0, n.sims = nsims, newdata = Current, returnSims=TRUE) # run sims on new data, keeping all results (returnSims=T)
yhats <- as.data.frame(attr(sims, "sim.results"))  # extract those simulation results as a data frame
names(yhats) <- paste0(rep("simscore.", nsims), seq(nsims))  # give the columns in that data frame proper names

# Merge the simulation results with the game id variables from Current
Sims.2015 <- cbind(Current, yhats)

# Add probability of home-team win as a new column
Sims.2015$p.home <- rowSums((Sims.2015[,(ncol(Current)+1):(ncol(Current)+nsims)] > 0))/1000

# Write that table to the working directory as a csv with a date stamp. The first step in the server.R part of the Shiny app
# that uses this data set involves converting the data from wide to long and mutating a few variables. I planned to do that
# here, but it dramatically increases the size of the resulting .csv, from ~4,000KB to > ~30,000KB. So I'm leaving the tidying
# for the app after all.
outputname <- paste("nfl.2015.simulations", gsub("-", "", Sys.Date()), "csv", sep=".") 
write.csv(Sims.2015, outputname, row.names=FALSE)
