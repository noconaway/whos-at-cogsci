# Create a plot showing the authors clusters

if(dev.cur() != 1) {dev.off()}
rm(list=ls())
options(width=150)

# read data
authorship <- read.table(file.path(dirname(getwd()), "authorship.tsv")
	, quote = "", sep="\t", row.names = 1, header=TRUE)
titles <- read.table(file.path(dirname(getwd()), "titles.tsv"), 
	quote = "", sep="\t", row.names = 1, header=TRUE)
nauthors = dim(authorship)[1]
npresentations = dim(authorship)[2]

# mine the text data
library(tm)
source <- VectorSource(titles$title)
corpus <- Corpus(source)

# clean corpus
corpus <- tm_map(corpus, content_transformer(tolower)) # lower case only
corpus <- tm_map(corpus, removePunctuation) # no punctuation
corpus <- tm_map(corpus, removeNumbers) # remove numbers
corpus <- tm_map(corpus, removeWords, stopwords()) # remove common stop words

# remove custom stops 
custom_stop = c("can","like","effects","effect","data","tbd","way","affects")
numbers = c('one','two','three','four','five','six','seven','eight','nine')
corpus <- tm_map(corpus, removeWords, custom_stop)  
corpus <- tm_map(corpus, removeWords, numbers) 

for (j in seq(corpus)) {
	corpus[[j]] <- gsub("adults", "adult", corpus[[j]])
	corpus[[j]] <- gsub("biases", "bias", corpus[[j]])
	corpus[[j]] <- gsub("categories", "category", corpus[[j]])
	corpus[[j]] <- gsub("categorisation", "categorization", corpus[[j]])
	corpus[[j]] <- gsub("changes", "change", corpus[[j]])
	corpus[[j]] <- gsub("childrens", "children", corpus[[j]])
	corpus[[j]] <- gsub("concepts", "concept", corpus[[j]])
	corpus[[j]] <- gsub("contexts", "context", corpus[[j]])
	corpus[[j]] <- gsub("cues", "cue", corpus[[j]])
	corpus[[j]] <- gsub("decisions", "decision", corpus[[j]])
	corpus[[j]] <- gsub("dependencies", "dependency", corpus[[j]])
	corpus[[j]] <- gsub("developmental", "development", corpus[[j]])
	corpus[[j]] <- gsub("differences", "difference", corpus[[j]])
	corpus[[j]] <- gsub("dynamics", "dynamic", corpus[[j]])
	corpus[[j]] <- gsub("environments", "environment", corpus[[j]])
	corpus[[j]] <- gsub("events", "event", corpus[[j]])
	corpus[[j]] <- gsub("exploration", "explore", corpus[[j]])
	corpus[[j]] <- gsub("exploring", "explore", corpus[[j]])
	corpus[[j]] <- gsub("expressions", "expression", corpus[[j]])
	corpus[[j]] <- gsub("features", "feature", corpus[[j]])
	corpus[[j]] <- gsub("individuals", "individual", corpus[[j]])
	corpus[[j]] <- gsub("infants", "infant", corpus[[j]])
	corpus[[j]] <- gsub("influences", "influence", corpus[[j]])
	corpus[[j]] <- gsub("investigating", "investigate", corpus[[j]])
	corpus[[j]] <- gsub("investigation", "investigate", corpus[[j]])
	corpus[[j]] <- gsub("judgements", "judgement", corpus[[j]])
	corpus[[j]] <- gsub("judgment", "judgement", corpus[[j]])
	corpus[[j]] <- gsub("judgments", "judgement", corpus[[j]])
	corpus[[j]] <- gsub("labels", "label", corpus[[j]])
	corpus[[j]] <- gsub("mechanisms", "mechanism", corpus[[j]])
	corpus[[j]] <- gsub("metaphors", "metaphor", corpus[[j]])
	corpus[[j]] <- gsub("modeling", "model", corpus[[j]])
	corpus[[j]] <- gsub("models", "model", corpus[[j]])
	corpus[[j]] <- gsub("narratives", "narrative", corpus[[j]])
	corpus[[j]] <- gsub("networks", "network", corpus[[j]])
	corpus[[j]] <- gsub("objects", "object", corpus[[j]])
	corpus[[j]] <- gsub("predictions", "prediction", corpus[[j]])
	corpus[[j]] <- gsub("predicts", "predict", corpus[[j]])
	corpus[[j]] <- gsub("problems", "problem", corpus[[j]])
	corpus[[j]] <- gsub("processes", "process", corpus[[j]])
	corpus[[j]] <- gsub("processing", "process", corpus[[j]])
	corpus[[j]] <- gsub("relations", "relation", corpus[[j]])
	corpus[[j]] <- gsub("representations", "representation", corpus[[j]])
	corpus[[j]] <- gsub("rules", "rule", corpus[[j]])
	corpus[[j]] <- gsub("semantics", "semantic", corpus[[j]])
	corpus[[j]] <- gsub("skills", "skill", corpus[[j]])
	corpus[[j]] <- gsub("strategies", "strategy", corpus[[j]])
	corpus[[j]] <- gsub("systems", "system", corpus[[j]])
	corpus[[j]] <- gsub("tasks", "task", corpus[[j]])
	corpus[[j]] <- gsub("words", "word", corpus[[j]])
}

# finish cleaning
corpus <- tm_map(corpus, stripWhitespace) # strip whitespace
corpus <- tm_map(corpus, PlainTextDocument) # convert to plain text

# convert to document term matrix
dtm <- as.matrix(DocumentTermMatrix(corpus))

# get frequency of useage of each word
frequency <- colSums(dtm)
frequency <- sort(frequency, decreasing=TRUE)

# plot wordcloud as png
library(wordcloud)
library(wesanderson)

dst = file.path(dirname(getwd()),"www", "wordcloud.png")
png(dst, width = 1000, height = 500)
wordcloud(names(frequency), frequency, min.freq=9, scale = c(7,.5),
	colors = wes_palette("Darjeeling"),
	fixed.asp = FALSE, rot.per = 0)   
dev.off()



