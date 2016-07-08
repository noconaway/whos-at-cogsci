library(shiny)
library(DBI)
library(miniUI)


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

	# Store a vector indicating whether the author is focal
	# These values are updated when the author object is active
	all_authors$focal = FALSE
dbDisconnect(con)

# function return the currently focal author
get_focal_author = function(V) {
	return(V$all_authors[V$all_authors$focal==TRUE,])
}


# ------------------------------------------
# SET UP USER INTERFACE
ui = fluidPage(

	# page style
	theme = "bootstrap.min.css",


	headerPanel("Who's at CogSci? 2016"),
  
    mainPanel(

    	# text input and name matches
    	div(
    		textInput("name", width = "100%",
	    		label = p("Enter all or part of an author's surname. First names are not searched, except for the first inital (e.g., D Gentner).", p("Potential matches will appear as buttons below the search field.")), 
	    		value = "gent"),
			uiOutput("name_matches"),
			br()
		),

    	# presentation frequency plot
		plotOutput("freq_plot", width = "100%", height = "500px"),

		# coauthors and presentation titles for focal author
		div(
			uiOutput("coauthor_buttons"),
			dataTableOutput("focal_titles")
		),

		# Info
		div(
			titlePanel('About'),
			p("I am a recent Cognitive & Brain Sciences graduate from Binghamton University", "[", a(href = "http://bingweb.binghamton.edu/~nconawa1/", "website"),"]. I made this app to learn how to use Shiny R. You can access the code on " , a(href = "https://github.com/noconaway/whos-at-cogsci", "GitHub"), "."),
			p("My name is Nolan Conaway and ",actionLink("show_nolan", "I'll be at CogSci 2016"),"!")
		)
		
    )
)

# ------------------------------------------
# SET UP SERVER
server = function(input, output, session) {
	values <- reactiveValues(all_authors = NULL)

	# -------------------------------------------------
    # listen for button clicks
	observe({ 

		active_buttons = isolate(get_author_buttons())


		# apply function to all buttons
		lapply(1:nrow(active_buttons), function(N) {
			B = active_buttons[N,]

			# if button was clicked, make that the focal author
	    	observeEvent(input[[B$object_name]], {
	    		values$all_authors = all_authors
	    		idx = all_authors$aid == B$aid
				values$all_authors$focal = idx
	    	})
	  	})
		})





	# special case to show N Conaway
	observeEvent(input$show_nolan, {
			values$all_authors <- all_authors
	    	idx = all_authors$fullname == "N Conaway"
			values$all_authors$focal = idx
		})

	# -------------------------------------------------

	# -------------------------------------------------
	# function to query the DB for name matches
	get_name_matches =  reactive ({ 

			# connect to db
			con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)

			# construct command and query the db
			cmd = paste("SELECT * FROM author_names WHERE fullname LIKE '%", input$name, "%';", sep = '')
		    result = dbGetQuery( con, cmd )
		    dbDisconnect(con)

		    # return null if there are no matches
		    if (length(result$fullname) == 0) {return(NULL)}

		    # otherwise, return the names
		    return(result)
		})

	# -------------------------------------------------
	# function to return coauthor information based on a focal author
	get_coauthors = reactive({
			# connect to db
			con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)
			
			# get counts from the db
			aid = get_focal_author(values)$aid
	    	cmd = paste("SELECT aid_2 FROM coauthors WHERE aid_1 = ", aid,';', sep='')
			co_aids = dbGetQuery(con, cmd)
			colnames(co_aids) = "aid"
			dbDisconnect(con)
			
			# merge data frames
			co_aids = merge(all_authors, co_aids, by="aid")
			return(co_aids)
		})

	# -------------------------------------------------
	# return author buttons
	get_author_buttons = reactive({

		# data for authors in search field
		matches_exist = !is.null(get_name_matches()$aid)
		if (matches_exist) {
			search_items = all_authors[all_authors$aid %in% get_name_matches()$aid,]
			search_items$location = 'search'
			search_items$object_name = paste(search_items$object_name,'_Search',sep='')
		}

		# data for focal author's coauthors
		focal_exists = !is.null(get_focal_author(values))
		if (focal_exists) {
			focal_coauth = get_coauthors()
			coauthors_exist = nrow(focal_coauth) > 0
			if (coauthors_exist) {
				focal_coauth$location = 'coauth'
				focal_coauth$object_name = paste(focal_coauth$object_name,'_Coauth',sep='')
			}
		} else {
			coauthors_exist = FALSE
		}

		# return the appropriate df
		if	(matches_exist & coauthors_exist) {
			return(rbind(search_items,focal_coauth))
		} else if (matches_exist & !coauthors_exist) {
			return(search_items)
		} else if (!matches_exist & coauthors_exist) {
			return(focal_coauth)
		} else {
			return(NULL)
		}
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
	# function to return relevant presentation titles
	author_presentation_titles = reactive({

			# connect to db
			con = dbConnect(RSQLite::SQLite(), dbname=dbfilepath)

			# get author id (aid)
			aid = get_focal_author(values)$aid

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
  	# print name matches
	output$name_matches = renderUI({
			B = get_author_buttons()

			# return if there are no names
			if (is.null(B)) {
				return(HTML("No matches."))
			}

			# return if there are no matches, even if there are coauthors
			B = subset(B, location=='search')
			if (nrow(B) == 0) {	
				return(HTML("No matches."))
			}

			# return message if there are too many matches
			if (nrow(B) > max_authors_listed) {
				return(HTML("Too many matches! Enter more characters."))
			}

			# otherwise, make the buttons!
			match_buttons = lapply(1:nrow(B), function(num) {
					actionButton(B[num,]$object_name, B[num,]$fullname)
				})
			return(match_buttons)
		})	

	# ------------------------------------------------- 
    # presentation frequency chart
    output$freq_plot <- renderPlot({

		# get data from reactive
    	counts = presentation_counts()

		# plot data
	    par(family = "mono", new=TRUE, cex.axis = 1.2, cex = 1.5,
	    	mai = c(0.5,0.75,0.25,0)) 

	    # make empty base plot to set axes
	    X = c(0,dim(all_authors)[1])
	    Y = c(1,max(counts$count)+0.75)
		ph = plot(X,Y, type='n',axes = F, xlab = NA, ylab = NA)

		# label queried name
		if ( any(values$all_authors$focal) ){

			# label focal author
			focal = get_focal_author(values)
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

		# set up axes
		box()
		axis(side = 1, at=NULL, labels=FALSE, lwd.ticks = 0)
		axis(side = 2, at=1:13, las = 1, col.ticks = 0,
			mgp=c(0,0,0.4), tick = FALSE)
		mtext(side = 1, "Author (Alphabetical)", line = 0.5, cex = 1.5)
		mtext(side = 2, "Number of Presentations", line = 1.5, cex = 1.5)

    } )  

    # -------------------------------------------------
	# show buttons for focal author's coauthors
    output$coauthor_buttons = renderUI({
    	
	    	# return nothing if there is no focal author
	    	if (is.null(get_focal_author(values))) {
	    		return(NULL)
	    	}

	    	# return message there are no active buttons
	    	tpanel = titlePanel('Co-Authors & Presentations')
	    	B = get_author_buttons()
	    	if (is.null(B)) {
	    		return(c(tpanel,HTML("No coauthors.")))
	    	}

	    	# return message there are no coauthors
	    	B = subset(B, location=='coauth')
	    	if (nrow(B)==0) {
	    		return(c(tpanel,HTML("No coauthors.")))
	    	}

	    	# otherwise, make the buttons!
			coauth_buttons = lapply(1:nrow(B), function(num) {
					actionButton(B[num,]$object_name, B[num,]$fullname)
				})
			return(c(tpanel,coauth_buttons))
		})


    # -------------------------------------------------
    # Show presentations by author
    output$focal_titles <- renderDataTable({

    	if (any(values$all_authors$focal)) { 

			# get the titles
			titles = author_presentation_titles()

			# convert to df
			df = data.frame(Title = titles)
			return(df)

		} else {
			HTML("No author has been selected.")
		}
    }, options = list(dom = 't')
    )
    

}


shinyApp(ui, server)
