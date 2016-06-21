if(dev.cur() != 1) {dev.off()}
rm(list=ls())
options(width=100)

# load data
master <- read.table('data.tsv', quote = "", sep="\t", 
	row.names = 1, header=TRUE)
numpresentations = rowSums(master)

# get list of last names for sorting
lastnames = vector(mode="character", length = length(numpresentations))
for (i in 1:length(numpresentations)) {
	name = row.names(master)[i]
	lastnames[i] = substr(name,start = 2, stop = nchar(name))
}
sortorder = sort(lastnames, index.return = TRUE)$ix


# sosrt data fields
fullnames = row.names(master)[sortorder]
numpresentations = numpresentations[sortorder]
index = 1:length(numpresentations)

require(rCharts)

# data
df <- data.frame(x = index, y = numpresentations, z = fullnames)


# create plot object
p <- hPlot(y ~ x, data = df, type = "scatter")

# set turbothreshold
p$plotOptions(series=list(turboThreshold = 2000))

# fix formatting
p$params$series[[1]]$data <- toJSONArray(df, json = F)

# set tooltip
p$tooltip(formatter = "#! function() {return(this.point.z);} !#")

# axis formatting
p$yAxis(title = list(text = "Number of Presentations"), categories = 0:10)
p$xAxis(title = list(text = "Author") )

p$save('plots/frequency.html', cdn = TRUE)