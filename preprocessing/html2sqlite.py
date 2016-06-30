from bs4 import BeautifulSoup
import os, io
with open("functions.py") as fh:
	exec(fh.read())

#  ---------------------------------------
# read source data
allfiles = []
for path, subdirs, files in os.walk(os.path.join(os.getcwd(),'source_html')):
    for name in files:
        if '.htm' in name:
        	allfiles.append(os.path.join(path, name))

#  ---------------------------------------
# Specify classes associated with author and title information.
# Established by manually checking that there were no more presentations left, 
# after accouting for the known classes.
authorclasses = ["xl105","xl106","xl107","xl115","xl116","xl119","xl140","xl164","xl165"]
titleclasses  = ["xl104","xl111","xl114","xl117","xl118","xl120","xl139","xl148","xl163","xl166"]

#  ---------------------------------------
# iterate over files
author_list, title_list = [], []
for file in allfiles:

	with io.open(file, 'r', encoding='ISO-8859-1') as fh:
		soup = BeautifulSoup(fh, "html.parser")

	rows = soup.findAll('tr')
	for row in rows:

		#  ---------------------------------------
		# find elements associated with title and author
		authors = row.findAll("td", { "class" : authorclasses })
		title = row.findAll("td", { "class" : titleclasses })

		#  ---------------------------------------
		# make sure row has both a title AND an author
		if len(title) != len(authors):
			print("\nThere is an author without a title. Or vice-versa. Skipping...\nFILE\t" + file)
			continue

		# make sure there is only one author/title cell
		if len(authors) > 1 or len(title) > 1:
			print("More than one author or title. Skipping... \nFILE\t" + file)
			continue

		# skip if there is no title or author
		if not authors:
			continue

		#  ---------------------------------------
		# process authors: convert to ascii, ignoring incompaible characters
		authors = authors[0].renderContents().strip().decode('ascii','ignore')
		authors = str(authors).replace('\n ','').split(', ')

		# use only first letter of first name, and last name
		authors = [name.split(' ')[0][0] + ' ' + name.split(' ')[-1] for name in authors]
		author_list.append(authors)

		#  ---------------------------------------
		# process title: convert to ascii, ignoring incompaible characters
		title = title[0].renderContents().strip().decode('ascii','ignore')
		title = str(title).replace('\n ','')

		# deal with weird <span> elements coversing spaces in some titles
		if '<span' in title:
			pre_span = title.split("<span")[0]
			post_span = title.split("</span>")[1]
			title = pre_span + ' ' + post_span
		title_list.append(title)

#  ---------------------------------------
# process scraped data
unique_authors = list(set(x for l in author_list for x in l))
numauthors, numpresentations = len(unique_authors), len(author_list)


#  ---------------------------------------
# DESIGN SQLITE ---
# 	Table 1, presentation_titles: [pid, title]
# 	Table 2, author_names: [aid, fullname, lastname]
# 	Table 3, authorship: [pid, aid]
# 	Table 4, coauthors: [aid_1, aid_2]

import sqlite3
dbfile = os.path.join(os.path.dirname(os.getcwd()),'data','cogsci.db')
conn = sqlite3.connect(dbfile)
c = conn.cursor()

# start by dropping all tables
tablenames = ["presentation_titles","author_names","authorship", "coauthors"]
for i in tablenames:
	cmd= "DROP TABLE IF EXISTS " + i + ";"
	c.execute(cmd)


# -------- set up presentation_titles:
c.execute('CREATE TABLE presentation_titles (pid INTEGER, title TEXT)')
rows = [(i+1, title_list[i]) for i in range(numpresentations)]
c.executemany('INSERT INTO presentation_titles VALUES (?,?)', rows)
print("Wrote " + str(len(rows)) + " rows to presentation_titles...")

# -------- set up author_names:
c.execute('CREATE TABLE author_names (aid INTEGER, fullname TEXT, lastname TEXT)')
rows = [(i+1, unique_authors[i], unique_authors[i][2:]) for i in range(numauthors)]
c.executemany('INSERT INTO author_names VALUES (?,?,?)', rows)
print("Wrote " + str(len(rows)) + " rows to author_names...")


# -------- set up authorship:
c.execute('CREATE TABLE authorship (pid INTEGER, aid INTEGER)')
rows = []
for pid in range(numpresentations):
	for j in author_list[pid]:
		aid = unique_authors.index(j)
		rows.append( (pid + 1,aid + 1) )
c.executemany('INSERT INTO authorship VALUES (?,?)', rows)
print("Wrote " + str(len(rows)) + " rows to authorship...")


# -------- set up coauthors:
c.execute('CREATE TABLE coauthors (aid_1 INTEGER, aid_2 INTEGER)')
rows = []
for aid_1 in range(numauthors):
	pids = [i for i in range(numpresentations) if unique_authors[aid_1] in author_list[i]]
	coauthors = [unique_authors.index(j) for i in pids for j in author_list[i] if j != unique_authors[aid_1]]
	coauthors = [( aid_1+1, aid_2+1 ) for aid_2 in uniqify(coauthors)]
	rows += coauthors
c.executemany('INSERT INTO coauthors VALUES (?,?)', rows)
print("Wrote " + str(len(rows)) + " rows to coauthors...")


conn.commit()
conn.close()
