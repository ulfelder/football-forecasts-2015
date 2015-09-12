library(dplyr)
library(tidyr)
library(ggplot2)

simdat <- read.csv("nfl.2015.simulations.20150908.csv", stringsAsFactors=FALSE)

plotdat <- simdat %>%
  gather(variable, value, simscore.1:simscore.1000) %>%
  mutate(game = paste(visiting_team, home_team, sep=" at "),
         variable = as.character(variable))

rm(simdat)

shinyServer(function(input, output) {
  
  # STUFF FOR GAME TAB
  
  output$game <- renderUI ({
    games <- plotdat[plotdat[,"week"]==input$week1 & plotdat[,"variable"]=="simscore.1",]
    games <- games[,"game"]
    selectInput("game", "Pick a game:", games)
  })
  
  output$team <- renderUI ({
    teams <- sort(unique(plotdat[,"home_team"]))
    selectInput("team", "Pick a team:", teams, selected="Ravens")
  })
  
  Gamedat <- reactive ({
    plotdat %>%
      filter(week==as.numeric(input$week1) & game==input$game) %>%
      mutate(., homewin = as.factor((value > 0)*1))
  })
  
  output$gameplot <- renderPlot({
    ggplot(Gamedat(), aes(value, fill=homewin)) +
      geom_histogram(binwidth=1, color="black") +
      annotate("text", x=-Inf, y=Inf,
               label=paste0("Probability of home-team win: ", round(Gamedat()[,"p.home"][1], 2)),
               fontface="italic", colour="black", vjust=2, hjust=-0.05, size=5) +
      annotate("text", x=-Inf, y=Inf,
               label=paste("Implied line:", ifelse(Gamedat()[,"p.home"][1] >= 0.5, Gamedat()[,"home_team"][1], Gamedat()[,"visiting_team"][1]), "by", abs(round(median(Gamedat()[,"value"]), 1)), sep=" "),
               fontface="italic", colour="black", vjust=4, hjust=-0.05, size=5) +
      labs(x="predicted net score (home - visitor)", y="count of simulations (n = 1,000)") +
      scale_fill_discrete(name="Who wins?", labels=c("visitor", "home")) +
      theme_bw() +
      theme(axis.text.x=element_text(size=rel(1.5)), axis.text.y=element_text(size=rel(1.5)), axis.title.x=element_text(size=rel(1.25)), axis.title.y=element_text(size=rel(1.25)))
  })
  
  # STUFF FOR TEAM TAB
  
  Wins <- reactive({
    plotdat %>%
      filter(home_team==input$team | visiting_team==input$team) %>%
      select(home_team, visiting_team, variable, value) %>%
      mutate(predictedwin = ifelse((home_team==input$team & value > 0) | (visiting_team==input$team & value < 0), 1, 0)) %>%
      group_by(variable) %>%
      summarise(totalwins = sum(predictedwin))
  })
  
  output$seasonplot <- renderPlot({
    ggplot(Wins(), aes(x = totalwins)) +
      geom_histogram(binwidth=1, aes(y=(100 * ..count../sum(..count..))), fill="cornflowerblue", colour="white") +
      scale_y_continuous(labels=function(x) { paste0(x, "%") }) + 
      labs(x = "total regular-season wins", y = "probability of occurrence", title = "2015 Total Wins Forecast") +
      theme_bw() +
      theme(axis.text.x = element_text(size=rel(1.5)), axis.text.y = element_text(size=rel(1.5)),
            axis.title.x = element_text(size=rel(1.25)), axis.title.y = element_text(size=rel(1.25)),
            plot.title = element_text(size=rel(1.5)))
  })
  
  output$winprob <- renderText({ sum(as.vector(Wins()[,"totalwins"]) >= input$wincount)/1000 })
  
  # STUFF FOR WEEK TAB
  
  output$weekplot <- renderPlot({
    df <- plotdat[plotdat[,"week"]==input$week2,]
    p <- ggplot(df, aes(x=factor(game), y=value)) + geom_boxplot() +
      labs(x = NULL, y = "distribution of simulated net scores") +
      theme(axis.text.x = element_text(size=rel(1.5)), axis.text.y = element_text(size=rel(1.5)), axis.title.y = element_text(size=rel(1.25))) +
      coord_flip()
    print(p)
  })
})
