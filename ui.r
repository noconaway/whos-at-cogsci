library(shiny)

shinyUI(fluidPage(

titlePanel("Who's at CogSci?"),
  
    
    mainPanel(
    	img(src = 'wordcloud.png',width = "100%"),
    	textInput("name", 
    		label = "Enter all or part of your last name:", 
    		value = "d gen"),
		
		strong("Possible matches:"),
		htmlOutput("name_matches"),
		
		# First plot
		plotOutput("freq_plot", click="freq_click", width = "100%"),
		verbatimTextOutput("freq_info"),
		p("This plot organizes each authors total number of presentations (talks+posters) alphabetically. You can query authors using the text input above. Clicking on a point will return the name in the field above.")

    )
))