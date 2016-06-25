

getlastname <- function(s) {return(substr(s, start = 3, stop = nchar(s)))}

# function to return name matches
matchnames <- function(S,L) {	
	return (L[ grep(S, L, ignore.case = TRUE) ])
	
}
