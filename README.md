#Who's at Cogsci? 2016

##Todo:

1. **Additions to author info table**. Show presentation time, coauthors.
2. **Create a co-authorship network, what are the clusters of connected authors?** I put a little time into this, but the edges are really sparse and I'm not a network whiz.
3. **Re-make the author similarity plot.** Cluster the author similarity figure and illustrate each cluster's most common terms. Is there a better distance metric than Jaccard? Are there any special procedure for dealing with sparse data? This will likely require that author word-use data is stored, rather than computed on the fly.
4. **Fixing the presentation frequency plot.**. Ideally, the user should be able to click on specific points to identify the name. I have made some progress with this (using `nearPoints()` but for some unknown reason the plot marker vanishes a split-second after it appears. Failing to make that work, the possible matches field can be updated to show the nearest points to the mouse click, and users can select one as the focal author. 
5. **Recommender**! Suggest N nearest talks to a given author.
6. **Better CSS / Layout.**
7. **Show and hide author info**. The page should not shift focus based on the author selection.


##Annoying little things:

1. How to set plot margins in shiny?
2. How to set axis *limits* using the `axis()` command?
3. I spotted a `</span>` in one of the names: `C </span>Behme`, `aid=1311`. Better check that out.
4. Find some way to systematically confirm that no presentations were missed in preprocessing.
5. Weird SQLite error (i believe) generated when making the author title table: `Error: error in statement: near " ": syntax error.`
6. Prevent error when # presentations figure looks for coordinates and has none.
7. Need some salient message about who the focal author is
