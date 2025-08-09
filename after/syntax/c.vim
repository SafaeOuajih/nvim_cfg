" Extra C syntax: highlight binary integer literals (e.g. 0b1010).
syn match	cNumber		display contained "0b\x\+\(u\=l\{0,2}\|ll\=u\)\>"
