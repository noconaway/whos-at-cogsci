# Create a plot showing the authors clusters

if(dev.cur() != 1) {dev.off()}
rm(list=ls())
options(width=150)

# read data
authorship <- read.table('../authorship.tsv', quote = "", sep="\t", 
	row.names = 1, header=TRUE)
titles <- read.table('../titles.tsv', quote = "", sep="\t", 
	row.names = 1, header=TRUE)
nauthors = dim(authorship)[1]
npresentations = dim(authorship)[2]


# get list of last names for display
getlastname <- function(s) {return(substr(s, start = 3, stop = nchar(s)))}
lastnames = unlist(lapply(row.names(authorship), getlastname))

# mine the text data
library(tm)
source <- VectorSource(titles$title)
corpus <- Corpus(source)

# clean corpus
corpus <- tm_map(corpus, content_transformer(tolower)) # lower case only
corpus <- tm_map(corpus, removePunctuation) # no punctuation
corpus <- tm_map(corpus, removeNumbers) # remove numbers
corpus <- tm_map(corpus, removeWords, stopwords()) # remove common stop words
corpus <- tm_map(corpus, stemDocument)   # coonvert words to stems

# remove custom stops 
custom_stop = c("can","like","effect","data","tbd","way","affect")
numbers = c('one','two','three','four','five','six','seven','eight','nine')
corpus <- tm_map(corpus, removeWords, custom_stop)  
corpus <- tm_map(corpus, removeWords, numbers) 

corpus <- tm_map(corpus, stripWhitespace) # strip whitespace
corpus <- tm_map(corpus, PlainTextDocument) # convert to plain text

# convert to document term matrix
dtm <- as.matrix(DocumentTermMatrix(corpus))
row.names(dtm) = colnames(authorship)


# get frequency of useage of each word,
# use only words with some frequency. 
frequency <- colSums(dtm)
features = dtm[,frequency >= 10]
nfeatures = dim(features)[2]

# create author-by feature data frame
authornums = apply(authorship, 1, function(u) which(u==1,arr.ind=TRUE))
authordata = data.frame(matrix(0,nauthors,nfeatures))
row.names(authordata) = row.names(authorship)
colnames(authordata) = colnames(features)
for (i in 1:nauthors) {
	docs =  unlist(authornums[i])
	ndocs = length(docs)
	dbt = matrix(features[docs,],ndocs,nfeatures)
	authordata[i,] = apply(dbt, 2, function(u) any(u==1))
}

# do not include authors without any used keywords
used_keywords = rowSums(authordata) > 0
authordata = authordata[used_keywords,]

# measure distance between authors, conduct MDS
library(proxy)
doc_distance <- function(x,y) { return = acos(x %*% y / sqrt((x %*% x) * (y %*% y))) }

D = dist(authordata,method = doc_distance)
coords = cmdscale(D,2)

# plot the data
require(rCharts)
df <- data.frame(x = coords[,1], y = coords[,2], z = row.names(authordata))

# create plot object
p <- hPlot(y ~ x, data = df, type = "scatter")

# set turbothreshold
p$plotOptions(series=list(turboThreshold = 2000))

# # fix formatting
p$params$series[[1]]$data <- toJSONArray(df, json = F)

# # set tooltip
p$tooltip(formatter = "#! function() {return(this.point.z);} !#")

# # axis formatting
p$yAxis(title = NULL, labels = list(enabled = FALSE),
	minorGridLineWidth=0, gridLineWidth = 0)
p$xAxis(title = NULL, labels = list(enabled = FALSE),
	minorGridLineWidth=0, gridLineWidth = 0, visible = FALSE)

p$params$width = 500
p$params$height = 500
p$chart(plotBorderWidth=3)
print(p)
p$save('../plots/similarity.html', standalone = TRUE)


