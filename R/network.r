# Create a plot showing the authors clusters

if(dev.cur() != 1) {dev.off()}
rm(list=ls())
options(width=520)

# read data
master <- read.table('../authorship.tsv', quote = "", sep="\t", 
	row.names = 1, header=TRUE)
nauthors = dim(master)[1]
npresentations = dim(master)[2]

# get list of last names for display
lastnames = vector(mode="character", length = nauthors)
for (i in 1:nauthors) {
	name = row.names(master)[i]
	lastnames[i] = substr(name,start = 2, stop = nchar(name))
}

# compute pairwise matrix of coauthorship
coauthors = diag(nauthors) 
for (i in 1:npresentations) {
	authorinds = which(master[,i] == 1, arr.ind = TRUE)
	authorpairs = expand.grid(authorinds, authorinds)
	for (j in 1:dim(authorpairs)[1]) {
		coauthors[authorpairs[j,1],authorpairs[j,2]] = 1
	}
}



row.names(coauthors) = lastnames
colnames(coauthors) = lastnames


for (i in 1:100) {
	in_network = rowSums(coauthors) > 4
	coauthors = coauthors[in_network,in_network]
}


library(igraph)
g <- graph.adjacency(coauthors, weighted = NULL,
	mode = "undirected", diag = FALSE)

plot(g)