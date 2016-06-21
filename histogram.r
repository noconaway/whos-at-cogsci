if(dev.cur() != 1) {dev.off()}
rm(list=ls())
options(width=100)



# load data
master <- read.table('data.tsv', quote = "", sep="\t", 
	row.names = 1, header=TRUE)
numpresentations = rowSums(master)
numpresentations = apply(master,1,sum)

names = row.names(master)

counts = matrix(0,1,max(numpresentations))
for (i in 1:max(numpresentations)) {
	counts[i] = sum(numpresentations==i)
}

# barplot(counts, xlab="Number of Presentations", ylab = '#',
# 	names.arg = 1:max(numpresentations))
library(plotly)
p = plot_ly(x = numpresentations, type="histogram", nbinsx = 10,
		borderwidth = 2, opacity = 0.6)
print(p)
# htmlwidgets::saveWidget(as.widget(p), "index.html")