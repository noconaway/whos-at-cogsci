library(shiny)
library(DBI)


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
	titlePanel("Who's at CogSci? 2016"),
  
    mainPanel(
    	textInput("name", 
    		label = "Enter all or part of an author's name. First names are not included, except for the first inital (i.e. D Gentner).", 
    		value = "gent"),
		
		# flexibly display author match output
		uiOutput("name_matches"),
		plotOutput("freq_plot", width = "100%"),
		uiOutput("coauthor_buttons"),
		dataTableOutput("focal_titles")
		
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
		# function to return coauthor informartion based on a focal author
		get_coauthors = reactive({
				# connect to db
				con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)
				
				# get counts from the db
				aid = get_focal_author()$aid
		    	cmd = paste("SELECT aid_2 FROM coauthors WHERE aid_1 = ", aid,';', sep='')
				co_aids = dbGetQuery(con, cmd)
				colnames(co_aids) = "aid"
				dbDisconnect(con)
				
				# merge data frames
				co_aids = merge(all_authors, co_aids, by="aid")
				return(co_aids)
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
		ph = plot(counts$index, counts$count, type='n',
			axes = F, xlab = NA, ylab = NA)


		# label queried name
		if ( any(values$all_authors$focal) ){

			# label focal author
			focal = get_focal_author()
			rownum = which(counts$fullname == focal$fullname)
	    	points(counts$index[rownum], counts$count[rownum], 
	    		pch=21, col='red', bg='red',cex = 1.8)
	    	text(counts$index[rownum], counts$count[rownum]+0.5, 
	    		focal$fullname, col='red')

	    	# label coauthors
	    	coauthors = get_coauthors()	
	    	if (dim(coauthors)[1] > 0) {
		    	lapply(1:dim(coauthors)[1], function(co) {
		    		rownum = which(counts$fullname == coauthors$fullname[co])
		    		points(counts$index[rownum], counts$count[rownum], 
		    			pch=21, col='blue', bg='blue',cex = 1.3)
		    		text(counts$index[rownum], counts$count[rownum]+0.5, 
		    			coauthors$lastname[co], col='blue', cex = 0.8)
		    	})
		    }

		    # if no focal author, plot all data
		} else { points(counts$index, counts$count)	}

		box()
		axis(side = 1, at=NULL, labels=FALSE, lwd.ticks = 0)
		axis(side = 2, at=1:12, las = 1, col.ticks = 0,
			mgp=c(0,0,0.4),tick = FALSE)
		mtext(side = 1, "Author (Alphabetical)", line = 0.5)
		mtext(side = 2, "Number of Presentations", line = 1.5)

    } )  

    # show buttons for focal author's coauthors
    output$coauthor_buttons = renderUI({

			# first, check for focal author
			if (any(values$all_authors$focal)) {
				coauthors = get_coauthors()	
				M = get_name_matches()
				# second, check for coauthors
				if (dim(coauthors)[1] > 0) {
				L = lapply(1:dim(coauthors)[1], function(co) {
					entry = all_authors[coauthors$aid[co],]

					if (entry$fullname %in% M & !is.null(M) & length(M) <= max_authors_listed) {
						return(HTML(entry$fullname))
					} else {
						return(actionButton(entry$object_name, entry$fullname))
					}
		    	})
				} else {return(HTML("No coauthors."))
			}
			}

		})
   

}


shinyApp(ui, server)
