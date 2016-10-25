from bs4 import BeautifulSoup
import pandas as pd
import os, itertools, sqlite3

dbfile = 'data.db'
source_dir = os.path.join('cogsci2016','papers')

# make sure website has been downloaded
if not os.path.exists(source_dir):
	S = 'Website not downloaded! This command should fix things :)\n' 
	S += "  wget -r -np -k -R 'pdf' https://mindmodeling.org/cogsci2016/"
	raise Exception(S)

# get list of papers
paperdirs = os.listdir(source_dir)
paperdirs = [i for i in paperdirs if os.path.isdir(os.path.join(source_dir, i))]

# ---- DATABASE DESIGN
# - authors table
# 	cols: author_name (TEXT), author (INTEGER)
authors = pd.DataFrame(data = None, columns = ['author_name', 'author'])

# - authorship table
# 	cols: author (INTEGER), paper(INTEGER)
authorship = pd.DataFrame(data = None, columns = ['author', 'paper'])

# - coauthors table
# 	cols: author1 (INTEGER), author2 (INTEGER)
coauthors = pd.DataFrame(data = None, columns = ['author1', 'author2'])

# - papers table
# 	cols: paper(INTEGER), title(TEXT), abstract(TEXT)
papers = pd.DataFrame(data = None, columns = ['paper', 'title', 'abstract'])

# iterate over paper directories
for p in paperdirs:

	# read html
	htmlfile = os.path.join(source_dir, p, 'index.html')
	if not os.path.exists(htmlfile):
		raise Exception('Not found: ' + p)

	print 'Processing paper: ' + p

	with open(htmlfile, 'r') as fh:
		html = fh.read()

	# cook up the soup
	soup = BeautifulSoup(html ,'lxml')
	
	# ----------------------------------------------------
	# get authors out of soup
	pauthors = []
	for i in soup('ul')[1]('li'):
		author = i.contents[0]
		author =  author.split('<em>')[0]
		author = author.replace(',','').strip()
		pauthors.append(author)

	# get title out of soup
	ptitle = soup('h1')[0].text

	# get abstract out of soup
	pabstract = soup('p', {"id": "abstract"})[0].text
	pabstract = ' '.join(pabstract.split())
	# pabstract = pabstract.encode('utf8','replace')

	# ----------------------------------------------------
	# add row to papers table
	papernum = papers.shape[0]+1
	row = {'paper': papernum, 'title': ptitle, 'abstract': pabstract}
	papers = papers.append(row, ignore_index = True)

	# add rows to authors and authorship tables
	for i in pauthors:
		
		# make new row in authors table if the author is new
		if i not in list(authors.author_name):
			authornum = authors.shape[0]+1
			row = {'author_name': i, 'author': authornum}
			authors = authors.append(row, ignore_index = True)

		# otherwise, just get the existing author number
		else: 
			authornum = int(authors.loc[authors.author_name==i, 'author' ])

		# add row to authorship table
		row = {'paper': papernum, 'author': authornum}
		authorship = authorship.append(row, ignore_index = True)

	# add paper to coauthors
	authornums = [int(authors.loc[authors.author_name==i, 'author' ]) for i in pauthors]
	pairs = itertools.product(authornums, repeat=2)
	for i in pairs:
		if i[0] == i[1]: continue

		# skip if coauthors are already known
		pair = sorted(i)
		if ((coauthors.author1==pair[0]) & (coauthors.author2==pair[1])).any():
			continue

		row = {'author1': pair[0], 'author2': pair[1]}
		coauthors = coauthors.append(row, ignore_index = True)


# write tables to sqlite

con = sqlite3.connect(dbfile)
papers.to_sql('papers', con, if_exists = 'replace', index = False,
	dtype = dict(paper = 'INTEGER', title = 'TEXT', abstract = 'TEXT'))
authors.to_sql('authors', con, if_exists = 'replace', index = False,
	dtype = dict(author_name = 'TEXT', author = 'INTEGER'))
authorship.to_sql('authorship', con, if_exists = 'replace', index = False,
	dtype = dict(author = 'INTEGER', paper = 'INTEGER'))
coauthors.to_sql('coauthors', con, if_exists = 'replace', index = False,
	dtype = dict(author1 = 'INTEGER', author2 = 'INTEGER'))
con.close()

print 'DONE'

