
get_name_matches =  reactive ({ 
	cmd = paste("SELECT fullname FROM author_names WHERE fullname LIKE '%", input$name, "%';", sep = '')
    result = dbGetQuery( con, cmd )
    return(result$fullname)
} )
