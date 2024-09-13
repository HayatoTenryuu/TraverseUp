## Quick info

### Purpose:
1. I wanted to see how things looked, and I am bad at making tree plots. 
2. Different plots gave different info, so this did turn out as a thing of beauty.
3. I found alimit on what it was doing, so I wanted to figure that out.

### How to use:
1. In case of a serious break, check the reference files. The .exe files that MATLAB uses can be regenerated from those.
2. If you have some dire need to go back, or if the MATLAB file is the problem, we are using Github, so you can go to an earlier version (which is also what inspired me to use Github for this).
3. This can be easily kept up to date; however, .exe files may need to be regenerated from the source files any time they are updated.
4. To recompile the .exe, use command `swipl-ld -o traverseUp term.c termy.pl`.
5. Updates to term.c or termy.pl are rare as the functionality is very well defined, so consider those highly stable points of reference.
6. Compendium files are just output data being passed from Prolog to MATLAB.
7. Needless to say, this program starts from 1 and goes up, as far as 1000 currently.
