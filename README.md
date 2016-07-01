#Who's at Cogsci? 2016

##Ideas for additions:

1. **Create a co-authorship network**. I put a little time into this, but the edges are really sparse and I'm not a network whiz.
2. **Author similarity plot.** MDS / Cluster the presentation title data. Is there a better distance metric than Jaccard? Are there any special procedure for dealing with sparse data? This will likely require that author word-use data is stored, rather than computed on the fly.
3. **Recommender**! Suggest N nearest talks to a given author.
6. **Distance to D Gentner!**.


##Things to fix:

1. How to set axis *limits* using the `axis()` command? Need to make the y axis extend to 13 so that M Frank's name is not cut off.
2. I spotted a `</span>` in one of the names: `C </span>Behme`, `aid=1311`. Better check that out.
3. Find some way to systematically confirm that no presentations were missed in preprocessing.
4. Sort coauthors alphabetically
5. Reset Button. Allow users to remove the focal author without replacement.
6. Make sure names are not terribly overlapping in the presentation frequency plot, except in extreme cases (e.g., J Tenenbaum). G Honke suggests looking into Jitter.

