import os
# this script simply downloads the html from cogsci.

posterurls = [
	"http://cognitivesciencesociety.org/uploads/posters_thurs.htm",
	"http://cognitivesciencesociety.org/uploads/posters_fri.htm",
	"http://cognitivesciencesociety.org/uploads/posters_sat.htm"]

talkurls = [
	"http://cognitivesciencesociety.org/uploads/details_thurs.htm",
	"http://cognitivesciencesociety.org/uploads/details_fri.htm",
	"http://cognitivesciencesociety.org/uploads/details_sat.htm"]


savelocation = "saved_html"

for i in posterurls:
	day = i.split("_")[1]
	dst = os.path.join(os.getcwd(),"source_html","posters", day)
	if os.path.exists(dst):
		os.remove(dst)
		
	cmd = "curl " + i + ' >> ' + dst
	os.system(cmd)

for i in talkurls:
	day = i.split("_")[1]
	dst = os.path.join(os.getcwd(),"source_html","talks", day)
	if os.path.exists(dst):
		os.remove(dst)

	cmd = "curl " + i + ' >> ' + dst
	os.system(cmd)