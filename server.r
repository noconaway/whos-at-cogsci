library(shiny)

source("functions.r")

# load authorship data
authorship <- read.table(file.path("data", "authorship.tsv"),
	quote = "", sep="\t", row.names = 1, header=TRUE)

lastnames = unlist(lapply(row.names(authorship), getlastname))
sortorder = sort(lastnames, index.return = TRUE)$ix
allnames = row.names(authorship)[sortorder]
lastnames = lastnames[sortorder]
numpresentations = rowSums(authorship)[sortorder]
index = 1:length(numpresentations)

freqplot_clickannote = FALSE

shinyServer(
  function(input, output) {

  	# -------------------------------------------------
  	# print name matches
    output$name_matches <- renderUI({
    	M = matchnames(input$name,allnames)
    	if (length(M) < 15) { 
    		out = paste(M, collapse="<br/>" )
		} else { out = 'Enter more characters!'
		}
    	HTML(out)
    })

	# ------------------------------------------------- 
    # presentation frequency chart
    output$freq_plot <- renderPlot({
	
		# plot base data
	    par(family = "mono", new=TRUE) 
		ph = plot(index, numpresentations,
			axes = F, xlab = NA, ylab = NA)

		box()
		axis(side = 1, at=NULL, labels=FALSE, lwd.ticks = 0)
		axis(side = 2, at=1:12, las = 1, col.ticks = 0,
			mgp=c(0,0,0.4),tick = FALSE)
		mtext(side = 1, "Author (Alphabetical)", line = 0.5)
		mtext(side = 2, "Number of Presentations", line = 1.5)


		# label queried name
		M = matchnames(input$name,allnames)
		if (length(M) == 1) { 
	    	X_txt = which(allnames == M)
	    	Y_txt = numpresentations[X_txt]
	    	points(X_txt, Y_txt, pch=21, col='red', bg='red',cex = 1.8)
	    	text(X_txt, Y_txt+0.5, M, col='red')
	    }
    } )  

    # Information about clicked authors
    output$freq_info <- renderText({
    	df = data.frame(x = index, y = numpresentations)
	    point = nearPoints(df, input$freq_click, xvar = "x", yvar="y", 
	    	threshold = 10, maxpoints = 5)
	    pointexists = dim(point)[1] > 0
	    if (pointexists) {
	    	T_clk = row.names(point)[1]
	    	return(paste("Selected author: ",T_clk,sep=''))
    	} 
    })
    print(format(Sys.time(), "%r"))

  }
)






