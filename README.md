#Who's at Cogsci? 2016

The [online schedule](http://cognitivesciencesociety.org/conference2016/schedule.html
) for CogSci 2016 is really clunky. I wanted a nice interface to see who's presenting, and so I took this opportunity to learn how to use Shiny R. 

As is, the app provides an interface for users to search authors and read presentation titles / co-authorship information. But there are a bunch of other things I'd like to do, and I encourage outside contributions! Below i have jotted some ideas.


###Possible additions

1. **Co-authorship network**. I put a little time into this, but the edges are really sparse and I'm not a network whiz.
2. **Author similarity plot.** MDS / Cluster the presentation title data. Is there a better distance metric than Jaccard? Are there any special procedure for dealing with sparse data? This will likely require that author word-use data is stored, rather than computed on the fly.
3. **Recommender**. Suggest N nearest talks to a given author.
6. **Distance to D Gentner**. Self explanatory.
7. Some general information at the top. How many authors are there? How many presentations? Average number of coauthors?
8. Add more info to the presentation title table (times, coauthors, etc). Will need to edit preprocessing scripts for this.

###Things to fix

1. Find some way to systematically confirm that no presentations were missed in preprocessing.
2. Reset Button. Allow users to remove the focal author without replacement.
3. More vertical padding between buttons.
4. Make sure author names do not run off screen (e.g., last names starting with A or Z)
5. Remove TBD's from presentation title table.


###Notes

- Individual authors were often listed under multiple different names. For example, Ken Kurtz (my Ph.D. advisor) was listed as "*Ken Kurtz*", "*Kenneth Kurtz*", "*Kenneth J Kurtz*", and "*Kenneth J. Kurtz*". So I took a shortcut, and now all authors are represented by the first letter of their first name and their full last name (i.e., "*K Kurtz*"). The downside is that, in at least a few cases, different people with similar names were merged.

