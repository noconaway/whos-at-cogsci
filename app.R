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

# connect to the database, pre-store author names
con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)
	cmd = paste("SELECT * FROM author_names")
	all_authors = dbGetQuery( con, cmd )

	# Store an object name for each author. 
	# If any of these object names are active, then they will become focal
	all_authors$object_name = gsub(' ','_',all_authors$fullname)

	# Store a vector indicating whether the author is focal
	# These values are updated when the author object is active
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

		dataTableOutput("focal_titles"),
		plotOutput("freq_plot", width = "100%")
    )
)

# ------------------------------------------
# SET UP SERVER
server = function(input, output, session) {
	values <- reactiveValues(all_authors = NULL)

	# return author buttons currently available
	get_current_authors = reactive({
		return(names(input)[which(names(input) %in% all_authors$object_name)])
		})

	# return the currently focal author
	get_focal_author = function() {
		return(values$all_authors[values$all_authors$focal==TRUE,])
	}

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
			aid = get_focal_author()$aid

			# get paper ids (pids)
			cmd = paste("SELECT pid FROM authorship WHERE aid = ", aid,';', sep='')
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
			
			# get counts from the db
	    	cmd = "SELECT aid, count(pid) FROM authorship GROUP BY aid"
			counts = data.frame(dbGetQuery(con, cmd))
			colnames(counts) = c('aid','count')

			dbDisconnect(con)

			# merge data frames and sort
			counts = merge(all_authors, counts, by="aid")
			counts = counts[ with(counts,order(lastname, fullname)) , ]
			
			# create index based on last name
			counts$index = 1:dim(counts)[1]
			return(counts)
		})







	# -------------------------------------------------
  	# print name matches
	output$name_matches = renderUI({

			# get matches
			M = get_name_matches()

			# Return message if there are no matches
			if (is.null(M)) { HTML("No matches.") } 

			# if there are matches AND there aren't too many, return the matches
			else if (!is.null(M) & length(M) <= max_authors_listed) { 
				lapply(1:length(M), function(num) {
					entry = all_authors[all_authors$fullname==M[num],]
					actionButton(entry$object_name, entry$fullname)
				})

			# ask for more characters if there are too many matches
			} else { HTML("Enter more characters!") }
			
		})
    
    # listen for button clicks
	observe({
		# apply function to all buttons
		lapply(get_current_authors(), function(B) {

			# if button was clicked, make that the focal author
	    	observeEvent(input[[B]], {
	    		values$all_authors <- all_authors
	    		idx = all_authors$object_name == B
				values$all_authors$focal[idx] = TRUE
	    	})
	  	})
		})


    # -------------------------------------------------
    # Show presentations by author
    output$focal_titles <- renderDataTable({
    	if (any(values$all_authors$focal)) { 

			# get the titles
			titles = author_presentation_titles()

			# convert to df
			df = data.frame(Title = titles)
			colnames(df) = paste(get_focal_author()$fullname,'Presentations')
			return(df)

		} else {
			HTML("No author has been selected.")
		}
    }, options = list(dom = 't')
    )
    


	# ------------------------------------------------- 
    # presentation frequency chart
    output$freq_plot <- renderPlot({
		
		# get data from reactive
    	counts = presentation_counts()

		# plot data
	    par(family = "mono", new=TRUE) 
		ph = plot(counts$index, counts$count,
			axes = F, xlab = NA, ylab = NA)

		box()
		axis(side = 1, at=NULL, labels=FALSE, lwd.ticks = 0)
		axis(side = 2, at=1:12, las = 1, col.ticks = 0,
			mgp=c(0,0,0.4),tick = FALSE)
		mtext(side = 1, "Author (Alphabetical)", line = 0.5)
		mtext(side = 2, "Number of Presentations", line = 1.5)

		# label queried name
		if ( any(values$all_authors$focal) ){
			focal = get_focal_author()
			rownum = which(counts$fullname == focal$fullname)
			X_txt = counts$index[rownum]
	    	Y_txt = counts$count[rownum]
	    	points(X_txt, Y_txt, pch=21, col='red', bg='red',cex = 1.8)
	    	text(X_txt, Y_txt+0.5, focal$fullname, col='red')
		}

    } )  
   

}


shinyApp(ui, server)
