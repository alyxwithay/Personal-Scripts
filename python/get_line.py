import sys
ids = open(sys.argv[1], 'r')
myfile = open(sys.argv[2], 'r')

ids = []
for line in ids:
	print ids.append(line.strip())
header = myfile.next()
print header
for line in myfile:
	if line.split("\t")[0] in ids:
		print line
