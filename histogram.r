if(dev.cur() != 1) {dev.off()}
rm(list=ls())
options(width=100)



# load data
master <- read.table('data.tsv', quote = "", sep="\t", 
	row.names = 1, header=TRUE)

numpresentations = rowSums(master)
names = row.names(master)


# get hover info
hovertxt = c('','','','','','','','','','')
for (i in 1:10) {
	N = sum(numpresentations==i)
	if (N<20 & N>0) { 
		hovertxt[i] = paste(names[numpresentations==i],collapse='<br>')
	}
}






library(plotly)

font <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#000000"
)

xlab <- list(
  title = "Number of Presentations",
  titlefont = font,
  tickfont = font,
  dtick = 1
)
ylab <- list(
  title = "#",
  titlefont = font,
  tickfont = font
)


p = plot_ly(x = numpresentations, type="histogram", 
	nbinsx = 10, nticks = 10,
	borderwidth = 2, opacity = 0.9, 
	hoverinfo = 'text', text = hovertxt) %>%
	layout(xaxis = xlab, yaxis = ylab)
print(p)
# htmlwidgets::saveWidget(as.widget(p), "index.html")

