from bs4 import BeautifulSoup
import os, io

with open("functions.py") as fh:
	exec(fh.read())

# ----------------------------
# function to scrape the html
def scrapehtml(src, tag):
	with io.open(src, 'r', encoding='ISO-8859-1') as fh:
		soup = BeautifulSoup(fh, "html.parser")
	
	data = soup.findAll("td", { "class" : tag })
	result = []
	for row in data:

		# ignore non ascii characters
		authors = row.renderContents().strip().decode('ascii','ignore')
		authors = str(authors).replace('\n ','').split(', ')

		# use only first letter of first name, and last name
		authors = [name.split(' ')[0][0] + ' ' + name.split(' ')[-1] for name in authors]
		result.append(authors)
	return result
# ----------------------------

# read source data
posterhtml = os.path.join(os.getcwd(),'source_html','posters')
talkhtml = os.path.join(os.getcwd(),'source_html','talks')

posters = []
for file in os.listdir(posterhtml):
	src = os.path.join(posterhtml, file)
	posters.extend(scrapehtml(src, "xl140"))

talks = []
for file in os.listdir(talkhtml):
	src = os.path.join(talkhtml, file)
	talks.extend(scrapehtml(src, ["xl119","xl105"]))

# mega list of all records
records = posters + talks
unique_authors = set(x for l in records for x in l)
numauthors, numpresentations = len(unique_authors), len(records)

# ------ Save as TSV
headers = [['name'] + ['p' + str(i+1) for i in range(numpresentations)]]
rows = [ [i] + [int(i in j) for j in records] for i in unique_authors]
data = headers + rows
dst = os.path.join(os.path.dirname(os.getcwd()),'data.tsv')
writefile(dst,data,'\t')