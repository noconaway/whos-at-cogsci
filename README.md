#Who's at Cogsci? 2016

##Todo:

1. **Author matching**. Set it up so that users can select one of the possible matches, rather than forcing them to reduce to one. Users should be able to see the presentation titles of the presentations for the selected author.
2. **Create a co-authorship network, what are the clusters of connected authors?** I put a little time into this, but the edges are really sparse and I'm not a network whiz.
3. **Re-make the author similarity plot.** Cluster the author similarity figure and illustrate each cluster's most common terms. Is there a better distance metric than Jaccard? Are there any special procedure for dealing with sparse data? This will likely require that author word-use data is stored, rather than computed on the fly.
4. **Fixing the presentation frequency plot.**. Ideally, the user should be able to click on specific points to identify the name. I have made some progress with this (using `nearPoints()` but for some unknown reason the plot marker vanishes a split-second after it appears. Failing to make that work, the possible matches field can be updated to show the nearest points to the mouse click, and users can select one as the focal author. 
5. **Recommender**! Suggest N nearest talks to a given author.
6. **Better CSS / Layout.**

##Annoying little things:

1. How to set plot margins in shiny?
2. How to set axis *limits* using the `axis()` command?
