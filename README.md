#Who's at Cogsci? 2016

##Todo:

1. **Create a co-authorship network, what are the clusters of connected authors?** I put a little time into this, but the edges are really sparse and I'm not a network whiz.
2. **Author similarity plot.** Cluster the author title keywords data. Is there a better distance metric than Jaccard? Are there any special procedure for dealing with sparse data? This will likely require that author word-use data is stored, rather than computed on the fly.
3. **Recommender**! Suggest N nearest talks to a given author.
4. **Better CSS / Layout.**
5. **Presentation frequency plot fixes**. Make sure names are not terribly overlapping, except in extreme cases (e.g., J Tenenbaum).
6. **Reset Button**. Allow users to remove the focal author without replacement.


##Annoying little things:

1. How to set plot margins in shiny?
2. How to set axis *limits* using the `axis()` command?
3. I spotted a `</span>` in one of the names: `C </span>Behme`, `aid=1311`. Better check that out.
4. Find some way to systematically confirm that no presentations were missed in preprocessing.
5. Prevent error when # presentations figure looks for coordinates and has none.
6. Need some salient message about who the focal author is
