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
lastnames = vector(mode="character", length = nauthors)
for (i in 1:nauthors) {
	name = row.names(authorship)[i]
	lastnames[i] = substr(name,start = 2, stop = nchar(name))
}


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

# get frequency of useage of each word
frequency <- colSums(dtm)
frequency <- sort(frequency, decreasing=TRUE)

# use only words with some frequency. 
features = dtm[,frequency >= 5]









# from http://www.cognitivesciencesociety.org/journal_csj_submission_keywords.html
# keywords = ["Analogy", "Animal cognition", "Attention", "Artificial Life", "Case-based reasoning", 
# 	"Causal reasoning", "Cognitive architecture", "Cognitive development", "Communication", 
# 	"Complex systems", "Computer vision", "Concepts", "Consciousness", "Creativity", "Culture", 
# 	"Decision making", "Distributed cognition", "Discourse", "Emotion", "Epistemology", 
# 	"Evolutionary psychology", "Human-computer interaction", "Human factors", "Information", 
# 	"Instruction", "Intelligent agents", "Language acquisition", "Language understanding", 
# 	"Learning", "Machine learning", "Memory", "Motor control", "Music", "Reasoning", "Representation", 
# 	"Pattern recognition", "Perception", "Philsosophy of computation", "Philosophy of mind", 
# 	"Philosophy of science", "Problem Solving", "Pragmatics", "Semantics", "Situated cognition", 
# 	"Skill acquisition and learning", "Social cognition", "Speech recognition", "Syntax", "Translation"]