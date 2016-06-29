library(shiny)
library(DBI)
source('helpers.r')



# make console a little prettier
cat(rep("\n",2))
print(format(Sys.time(), "%r"))

# store relative path to db
dbfilepath = file.path("data", "cogsci.db")

# limit the number of author possibilities
max_authors_listed = 15

# store page parameters
params = reactiveValues(max_authors_listed = 15)

# connect to the database, print out the table names.
con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)
print(dbListTables(con))

# construct df containing whether each author is focal
cmd = paste("SELECT * FROM author_names")
all_authors = dbGetQuery( con, cmd )
all_authors$focal = FALSE

dbDisconnect(con)


# ------------------------------------------
# SET UP USER INTERFACE
ui = fluidPage(
	titlePanel("Who's at CogSci?"),
  
    mainPanel(
    	textInput("name", 
    		label = "Enter all or part of an author's name. First names are not included, except for the first inital (i.e. D Gentner).", 
    		value = "gent"),
		
		# flexibly display author match output
		uiOutput("name_matches"),

		dataTableOutput("select_titles"),
		plotOutput("freq_plot", click="freq_click", width = "100%"),
		uiOutput("freq_info")

    )
)


# ------------------------------------------
# SET UP SERVER
server = function(input, output, session) {
	v <- reactiveValues(data = NULL)

	get_focal_author = reactive({
		return(all_authors[all_authors$focal == TRUE,])
	})

	# -------------------------------------------------
	# function to query the DB for name matches
	get_name_matches =  reactive ({ 

		# connect to db
		con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)

		# construct command and query the db
		cmd = paste("SELECT fullname FROM author_names WHERE fullname LIKE '%", input$name, "%';", sep = '')
	    result = dbGetQuery( con, cmd )
	    dbDisconnect(con)

	    # return null if there are no matches
	    if (length(result$fullname) == 0) {return(NULL)}

	    # otherwise, return the names
	    return(result$fullname)
	})

	# -------------------------------------------------
	# function to return relevant presentation titles
	author_presentation_titles = reactive({

		# connect to db
		con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)
		
		# get author id (aid)
		cmd = paste("SELECT aid FROM author_names WHERE fullname = '", input$author_choice, "'", sep = '')
		aid = dbGetQuery(con, cmd)$aid

		# get paper ids (pids)
		cmd = paste("SELECT pid FROM authorship WHERE aid = ", aid, sep='')
		pid = dbGetQuery(con, cmd)$pid

		# get paper titles
		cmd = paste("SELECT title FROM presentation_titles WHERE pid IN (", 
					paste(pid, collapse = ','), ")")
		titles = dbGetQuery(con, cmd)$title
		dbDisconnect(con)

		return(titles)

	})

	# -------------------------------------------------
	# function to construct an author-by-presentation count data frame
	presentation_counts = reactive({
			# connect to db
			con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)

			# get counts  and names of authors from the db
	    	cmd = "SELECT aid, count(pid) FROM authorship GROUP BY aid"
			counts = data.frame(dbGetQuery(con, cmd))
			colnames(counts) = c('aid','count')

			cmd = "SELECT * FROM author_names"
			names = data.frame(dbGetQuery(con, cmd))
			dbDisconnect(con)

			# merge data frames and sort
			counts = merge(names, counts, by="aid")
			counts = counts[ with(counts,order(lastname, fullname)) , ]
			
			# create index based on last name
			counts$index = 1:dim(counts)[1]
			return(counts)
		})







	# -------------------------------------------------
  	# print name matches
	output$name_matches = renderUI({
			M = get_name_matches()

			if (is.null(M)) { HTML("No matches.") } 
			else if (!is.null(M) & length(M) <= max_authors_listed) { 
				lapply(1:length(M), function(num) {
					linkname = gsub(' ','_',M[num])
					actionButton(linkname, M[num])
				})				
			} else { HTML("Enter more characters!") }
		})

	# listen for button clicks
	


  	

    
 #    # -------------------------------------------------
 #    # Show presentations by author
 #    output$select_titles <- renderDataTable({

 #    	if ( check_name_selected() ) {

 #    		# get the titles
	# 		titles = author_presentation_titles()

	# 		# convert to df
	# 		df = data.frame(Title = titles)
	# 	}
 #    }, options = list(dom = 't'))


	# # ------------------------------------------------- 
 #    # presentation frequency chart
 #    output$freq_plot <- renderPlot({
		
	# 	# get data from reactive
 #    	counts = presentation_counts()

	# 	# plot data
	#     par(family = "mono", new=TRUE) 
	# 	ph = plot(counts$index, counts$count,
	# 		axes = F, xlab = NA, ylab = NA)

	# 	box()
	# 	axis(side = 1, at=NULL, labels=FALSE, lwd.ticks = 0)
	# 	axis(side = 2, at=1:12, las = 1, col.ticks = 0,
	# 		mgp=c(0,0,0.4),tick = FALSE)
	# 	mtext(side = 1, "Author (Alphabetical)", line = 0.5)
	# 	mtext(side = 2, "Number of Presentations", line = 1.5)

	# 	# label queried name
	# 	if ( check_name_selected() ){
	# 		selected_name = input$author_choice
	# 		rownum = which(counts$fullname == selected_name)
	# 		X_txt = counts$index[rownum]
	#     	Y_txt = counts$count[rownum]
	#     	points(X_txt, Y_txt, pch=21, col='red', bg='red',cex = 1.8)
	#     	text(X_txt, Y_txt+0.5, selected_name, col='red')
	# 	}

 #    } )  

 #    # Information about clicked authors
 #    output$freq_info <- renderUI({
 #    	# get data from reactive
 #    	counts = presentation_counts()

 #    	# get nearPoints()
	#     point = nearPoints(counts, input$freq_click, xvar = "index", yvar="count", 
	#     	threshold = 10, maxpoints = 1)

	#     # display information if available
	#     pointexists = dim(point)[1] > 0
	#     if (pointexists) {
	#     	actionLink("freqClickLink", point$fullname[1])
 #    	} 
 #    })

 #   	# handle user clicking on names
 #    observeEvent(input$freqClickLink, {

 #    	# determine who was clicked on
 #    	counts = presentation_counts()
	#     point = nearPoints(counts, input$freq_click, xvar = "index", yvar="count", 
	#     	threshold = 10, maxpoints = 1)

	#     # update name box
	#     get_focal_author()
	#     # updateTextInput(session, "name", value = point$fullname[1])	

 # 	})
    

}


shinyApp(ui, server)
