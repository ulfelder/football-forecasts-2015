shinyUI(pageWithSidebar(
  
  headerPanel("Dart-Throwing Chimp's 2015 NFL Forecasts"),
  
  sidebarPanel(
    
    conditionalPanel(condition="input.options==1",
                     p("Pick a week and a game to see the simulation results and resulting forecast for that game.",
                       style = "font-family: 'georgia';"),  
                     selectInput("week1", "Pick a week:", choices=c("1"=1, "2"=2, "3"=3, "4"=4, "5"=5, "6"=6, "7"=7, "8"=8,
                                                                    "9"=9, "10"=10, "11"=11, "12"=12, "13"=13, "14"=14, "15"=15, "16"=16, "17"=17)),
                     uiOutput("game")),
    
    conditionalPanel(condition="input.options==2",
                     p("Pick a team to see how many games we should expect the team to win. The labels along the bottom are associated with the bars to their
                       immediate right.", style = "font-family: 'georgia';"),
                     uiOutput("team"),
                     numericInput("wincount", "Probability of winning at least this many games:", 8, min=1, max=16, step=1),
                     textOutput("winprob")),
    
    conditionalPanel(condition="input.options==3",
                     p("Pick a week to see a summary of game forecasts for that week in the form of box plots.", style = "font-family: 'georgia';"),
                     selectInput("week2", "Pick a week:", choices=c("1"=1, "2"=2, "3"=3, "4"=4, "5"=5, "6"=6, "7"=7, "8"=8,
                                                                    "9"=9, "10"=10, "11"=11, "12"=12, "13"=13, "14"=14, "15"=15, "16"=16, "17"=17)),
                     p("In each box plot, the box covers the middle 50% of the simulated scores --- a.k.a. the inter-quartile range, or IQR. The vertical line in
                       the middle of the box marks the median, while the horizontal lines running out from the box extend to the furthest simulated score that lies
                       within 1.5 times the IQR. Any simulated scores more extreme than those are shown as points.", style = "font-family: 'georgia';")),
    
    conditionalPanel(condition="input.options==4",
                     img(src = "chimppic.jpg", height=380, width=380))
    
                     ),
  
  mainPanel(
    
    tabsetPanel(id="options", position="above", type="tabs", selected=1,
                
                tabPanel("By Game", value=1,
                         plotOutput("gameplot", width="800px", height="450px")),
                
                tabPanel("By Team", value=2,
                         plotOutput("seasonplot", width="800px", height="450px")),
                
                tabPanel("By Week", value=3,
                         plotOutput("weekplot", width="600px", height="500px")),
                
                tabPanel("Under the Hood", value=4,
                         br(),
                         p("The forecasts displayed here come from a combination of statistical modeling and crowdsourcing, and they are based solely on information gathered
                           before the start of the 2015 regular season.",
                           style = "font-family: 'georgia';"),
                         p("Each game forecast summarizes 1,000 simulations from a",
                           a("linear mixed-effects model", href="https://en.wikipedia.org/wiki/Mixed_model"),
                           "that uses net score (home points - visitor points) as its target and the difference in team strength (home strength -
                           visitor strength) as its principal input. To account for",
                           a("significant variation in home-field advantage across NFL teams,",
                             href="https://dartthrowingchimp.wordpress.com/2015/01/24/estimating-nfl-team-specific-home-field-advantage/"),
                           "the model also includes random intercepts for each team as the home team. I used the",
                           a("lme4 package", href="https://cran.r-project.org/web/packages/lme4/vignettes/lmer.pdf"),
                           "in R to estimate the model and the recently-released",
                           a("merTools package", href="https://github.com/jknowles/merTools"),
                           "to generate the predictive simulations.",
                           style = "font-family: 'georgia';"),
                         p("Those team strength scores come from a",
                           a("pairwise wiki survey,", href="http://www.allourideas.org/about"),
                           "an instrument developed by",
                           a("All Our Ideas.", href="http://www.allourideas.org/"),
                           "Participants were shown randomly selected pairs of teams and asked: 'In the 2015 NFL season, which team will be better?' 
                           Participants could cast as many of those pairwise votes as they liked in as many sessions as they liked. The survey was launched on
                           August 10. Participants were primarily recruited via the
                           r/nfl subreddit and Twitter, and they cast more than 12,000 votes. This year is the third time that I have run this survey --- see",
                           a("here", href="https://dartthrowingchimp.wordpress.com/2014/08/11/turning-crowdsourced-preseason-nfl-strength-ratings-into-game-level-forecasts/"),
                           "and",
                           a("here", href="https://dartthrowingchimp.wordpress.com/2014/02/09/howd-those-football-forecasts-turn-out/"),
                           "for more on the previous iterations --- and the data from those earlier seasons were used to estimate the
                           statistical model on which the simulations are based.", style = "font-family: 'georgia';"),
                         p("This app was built by",
                           a("Jay Ulfelder", href="https://dartthrowingchimp.wordpress.com/about/"),
                           "using R Studio's",
                           a("Shiny", href="http://shiny.rstudio.com/"),
                           "web application framework. It is generously hosted on a server maintained by",
                           a("Tony Boyles.", href="http://anthony.boyles.cc/bio/"),
                           style = "font-family: 'georgia';"))
))))
