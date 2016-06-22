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
unique_authors = set(x for l in author_list for x in l)
numauthors, numpresentations = len(unique_authors), len(author_list)
print(numauthors, numpresentations)

# ------ Save authorship matrix to TSV
headers = [['name'] + ['p' + str(i+1) for i in range(numpresentations)]]
rows = [ [i] + [int(i in j) for j in author_list] for i in unique_authors]
data = headers + rows
dst = os.path.join(os.path.dirname(os.getcwd()),'authorship.tsv')
writefile(dst,data,'\t')

# ------ Save title list
headers = [["id","title"]]
ids = ['p' + str(i+1) for i in range(numpresentations)]
rows = list(zip(ids,title_list))
data = headers + rows
dst = os.path.join(os.path.dirname(os.getcwd()),'titles.tsv')
writefile(dst,data,'\t')

