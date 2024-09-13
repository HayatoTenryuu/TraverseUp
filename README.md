# TraverseUp

### Purpose:
1. I wanted to see how things looked, and I am bad at making tree plots. 
2. Different plots gave different senses, so this did turn out as a thing of beauty.
3. I found a limit on what it was doing, so I wanted to figure that out.

### How to use:
1. In case of a serious break, the .exe files that MATLAB uses can be regenerated from the reference files.
2. If you have some dire need to go back, or if the MATLAB file is the problem, we are using Github, so you can go to an earlier version (which is also what inspired me to use Github for this).
3. The .exe files need to be regenerated from the source files any time they are updated.
4. To recompile the .exe, use command `swipl-ld -o traverseUp term.c termy.pl`.
5. Updates to term.c or termy.pl are rare, so consider those highly stable points of reference.
6. Compendium files are just output data being passed from Prolog to MATLAB.

### How it works:
1. This program starts from 1 and goes up, as far as 1000 currently.
2. It cleans the data some, but not perfectly. But then the output is saved.
3. MATLAB imports the output and plots it.
4. The "dirty" version involves duplicate arrivals to a set of numbers because, when graphed, they look very pretty.
5. The "clean" version tries to remove duplication wherever possible.
