#-------------------------------------------------------------------------------
# flatten an arbitrarily nested list
def flatten(LIST):
    for i in LIST:
        if isinstance(i, (list, tuple)):
            for j in flatten(i):
                yield j
        else:
            yield i

#-------------------------------------------------------------------------------
# write a list to a file, where each item gets its own line,
# independently of nesting and data type
def writefile(filename,data,delim):
    lines = [] # open storage

    # iterate across lines
    for line in data:

        # recursive flatten until there are no more lists
        if isinstance(line, (list, tuple)):
            lines.append(delim.join(str(i) for i in flatten(line)))

        # add item to list if not a list/tuple
        else:
            lines.append(str(line))

    # write joined lines to file
    fh=open(filename,'w')
    fh.write("\n".join(lines))
    fh.close() 


#-------------------------------------------------------------------------------
# Get unique items in a list
def uniqify(seq, idfun=None): 
    # order preserving
    if idfun is None:
        def idfun(x): return x
    seen = {}
    result = []
    for item in seq:
       marker = idfun(item)
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
    return result
