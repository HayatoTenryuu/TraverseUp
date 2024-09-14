/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*  The functions here are to show the branches of Collatz,  */
/*  from 1 to a set limit, in the terminal, and it will 	 */
/*  return a List of each number in the chain.               */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/


/*--------------------------------*/
/*         Useful Headers         */
/*--------------------------------*/

:- set_prolog_flag(answer_write_options,[max_depth(0)]).			% Make Prolog print all values in a list, instead of truncating the list [a, b, c, | ...].
:- set_prolog_flag(double_quotes, chars).							% Converts strings into character lists.
:- set_prolog_flag(verbose, silent).								% Stop the banner from appearing in other terminals.

:- use_module(library(clpfd)).										% Load the library including "#=" integer arithmetic.
:- use_module(library(lists)).										% Load the library for list manipulation, including reversing the list.


/*--------------------------------*/
/*         Useful Things          */
/*--------------------------------*/

/* Test if Input is odd */
odd(Input) :-
	integer(Input),
	Input #> 0,
	Input>>1 #= (Input-1) rdiv 2.
	
	%% Note: I was hoping this could be used as a definition if used in reverse, but it cannot be because the last bit of the Input binary is lost.
	%% I made a thread on SWI-Prolog forum to see if we could make a reversible odd/3, but I'm not sure I'd know what to do with it even if we can.
	

/* Convert a list to a balanced binary tree */
/* Source: https://stackoverflow.com/questions/69876440/creating-binary-tree-in-prolog */
listToBBT(List, Tree) :-
	(List = [] ->  Tree = 0; 
	(
		Tree = t(Left, Root, Right),
		append(Prefix, [Root | Suffix], List),
		length(Prefix, Size1),
		length(Suffix, Size2),
		abs(Size1 - Size2) =< 1,
		listToBBT(Prefix, Left),
		listToBBT(Suffix, Right)
	)).
	
	
/*--------------------------------------------------------------------------------------------*/
/* Convert a balanced binary tree to a list */
/* Source: https://stackoverflow.com/questions/59150239/how-to-convert-tree-to-list-in-prolog */

/* Stopping case for 0 */
bbtToList(0, List) :-
	List = [0],
	!.


/* Stopping case for when we reach a number */ 
bbtToList(Num, List) :-
	integer(Num),
	List = [Num],
	!.


/* Actual list-making function */
bbtToList(t(L, Root, R), List) :-
	bbtToList(L, LList),
	bbtToList(R, RList),
	append(LList, [Root | RList], List),
	!.


/*---------------------------------------------------*/
/* Binary tree to Source and Target lists for MATLAB */

/* Overall handler for these functions */
bbtHandler(Tree, SourceList, TargetList) :-
	Target = [_Head | TargetList],
	bbtToST(Tree, SourceList, Target).
	
	
/* Stopping case for final node */
bbtToST(t(0, Root, 0), Source, Target) :-
	Source = [],
	Target = [Root],
	!.
	
	
/* Stopping case for right side only */
bbtToST(t(0, Root, R), Source, Target) :-
	(\+ integer(R) ->
	(
		bbtToST(R, SourceR, TargetR),
		append([Root], SourceR, Source),
		append([Root], TargetR, Target)
	);
	(
		Source = [Root],
		Target = [R]
	)),
	!.
	
	
/* Stopping case for left side only */
bbtToST(t(L, Root, 0), Source, Target) :-
	(\+ integer(L) ->
	(
		bbtToST(L, SourceL, TargetL),
		append([Root], SourceL, Source),
		append([Root], TargetL, Target)
	);
	(
		Source = [Root],
		Target = [L]
	)),
	!.


/* General case */
bbtToST(t(L, Root, R), Source, Target) :-
	(\+ integer(R) ->
	(
		bbtToST(R, SourceR1, Target2),
		append([], Target2, TargetR),
		append([Root], SourceR1, SourceR)
	);
	(
		SourceR = [Root],
		TargetR = [R]
	)),
	(\+ integer(L) ->
	(
		bbtToST(L, SourceL1, Target1),
		append([], Target1, TargetL),
		append([Root], SourceL1, SourceL)
	);
	(
		SourceL = [Root],
		TargetL = [L]
	)),

	append([Root], TargetR, TargetR2),
	append(TargetR2, TargetL, Target),
	append(SourceR, SourceL, Source).
	
/*---------------------------------------------------------------------------------------------*/
/* Convert bbt to an actual image in the terminal (carries to CMD and MATLAB terminal too lol) */

/* Handler */
show(T) :-
	nl,
    show(T, 0),
	nl.


/* Stopping case for 0 */
show(0, _) :-
	!.
	
	% Note: the cut exists because the tree thinks plotting zeros is a reasonable alternative answer.
	% And I don't. So I said "stop that".


/* Stopping case for repeat integers, while still plotting them accordingly */
show(X, Indent) :-
	integer(X),
    format('~*c~w\n', [Indent, 32, X]).
	
	% Note: the integer check prevents us from subsuming all tree plotting.


/* Actual drawing function for the tree */
show(t(Left, Root, Right), Indent) :-
    Indent1 is Indent + 3,
    show(Right, Indent1),
    format('~*c~w\n', [Indent, 32, Root]),
    show(Left, Indent1).
	
	
/*-----------------------------------------*/
/*       Clean list and save to file       */
/*-----------------------------------------*/	
	
/* Create a temp file to get our list as a string */
cleanUpList(InList, OutString) :-
	(InList = [] -> OutString = "";
	(
		string_chars(In, "tmp.compendium"),
		open(In, write, Input), 									% Create or remake List file.
		write(Input, InList),										% Write the List to the file
		close(Input),												% Close the file.
		
		%% Writing to a temporary file so we get a string.
		
		open(In, read, Input2),
		read_line_to_codes(Input2, InCodes),					    % Read the data to character codes.
		close(Input2),
		delete_file("tmp.compendium"),
		
		%% Reading and deleting the temporary file.
		
		string_codes(InString, InCodes),							% Convert codes to string.
		zeroReplaceUp(InString, OutString1),						% Remove the zeros.
		pipeReplaceUp(OutString1, OutString)						% Fix the string.
		
		%% Correcting the string and leaving it as-is so that we don't have to debug as much.
		
	)).
	
	
/* Remove zeros */
zeroReplaceUp(InString, OutString) :-
	(re_match("(,0,)", InString) -> 								% Gets rid of zeros in the middle.
	(
		re_replace("(,0,)", ",", InString, MidString),
		zeroReplaceUp(MidString, OutString)
	);	
	(re_match("([^0-9,]0,)", InString) -> 							% Gets rid of zeros in the beginning.
	(
		re_replace("([^0-9,]0,)", "[", InString, MidString),
		zeroReplaceUp(MidString, OutString)
	);
	(re_match("(,0[^0-9,])", InString) -> 							% Gets rid of zeros in the end.
	(
		re_replace("(,0[^0-9,])", "]", InString, MidString),
		zeroReplaceUp(MidString, OutString)
	);
	(																% Else do nothing.
		OutString = InString
	)))).
	
	
/* Replace pipes with commas */
pipeReplaceUp(InString, OutString) :-
	(re_match("[|]", InString) -> 
	(
		re_replace("[|]", ",", InString, MidString),
		pipeReplaceUp(MidString, OutString)
	);
	(
		OutString = InString
	)).
	
	
/* Save our binary tree list to a file */
saveUpList(SourceList, TargetList) :-
	cleanUpList(SourceList, OutSourceString),						% Get rid of pipes in source.
	cleanUpList(TargetList, OutTargetString),						% Get rid of pipes in target.
	
	string_chars(In, "binary tree.compendium"),
	open(In, write, Input), 										% Create or remake List file.
	write(Input, OutSourceString),									% Write the Source List to the file
	write(Input, ";"),
	write(Input, OutTargetString),									% Write the Target List to the file
	close(Input).													% Close the file.


/*-------------------------------------*/
/*  Upward Traversal (Must Be Limited) */
/*-------------------------------------*/

/* Take a number and traverse up from Input to Limit */
traverseUp(Input, Limit, Tree) :-
	% write_canonical(Input),
	% nl,
	(atom(Input) ->  
	(
		atom_string(Input, String), 
		term_string(T, String)
	);
	(
		T = Input
	)),
	(atom(Limit) ->  
	(
		atom_string(Limit, String2), 
		term_string(T2, String2)
	);
	(
		T2 = Limit
	)),
	increment(T, T2, [], Tree),
	%% show(Tree),
	bbtHandler(Tree, Source, Target),
	
	/*
	write(Source),
	nl,														% Checking that source and target lists have proper values
	write(Target),
	nl,
	bbtToList(Tree, List),
	*/
	
	saveUpList(Source, Target).


/* Stop condition for input = 0 */
increment(0, _, _, Tree) :-
	Tree #= 0,
	!.


/* Increment the input upwards to the limit, which also checks for repeats and stops that branch if it finds them */
increment(Input, Limit, InList, Tree) :-
	List2 = [Input | InList],
	(Input #> Limit -> Tree = t(0, Input, 0);  
	(
		Tree = t(L, Input, R),
		
		pathUpA(Input, R1), 
		pathUpB(Input, L1),

		/*
		write(List2),
		nl,
		write(Input),
		nl,													% Checking that trees are truncated properly
		write(R1),
		nl,
		write(L1),
		nl,
		*/

		(member(R1, List2) -> 
		(
			R #= R1,
			increment(L1, Limit, List2, L)
		);
		(member(L1, List2) -> 
		(
			L #= L1,
			increment(R1, Limit, List2, R)
		);
		(R1 #= 0 ->
		(
			R #= 0,
			increment(L1, Limit, List2, L)
		);
		(
			increment(R1, Limit, List2, R),
			increment(L1, Limit, List2, L)
		))))
	)).

	
/* Find the next value of the Collatz chain when odd */
pathUpA(Input, Output) :-
	X is (Input - 1) rdiv 3,
	(integer(X) -> 
	(
		(odd(X) ->
		(
			Output #= X
		); 
		(
			Output #= 0
		))
	);
	(
		Output #= 0
	)).
	
	% Note, since we are going up, we are inputting the 3x+1 value and outputting x. 
	% We have included an if-statement in case this leads to non-integers (like the case of input = 2).
	
	
/* Find the next value of the Collatz chain when even */
pathUpB(Input, Output) :-
	Input #= X rdiv 2,
	integer(X) -> Output #= X; Output #= 0.
	
	% Note that this version of pathUpB works both backwards and forwards, since we are using rdiv. 
	% If we used div, /, regardless of what equal sign we use, it will not go in reverse.

	% Final note, since we are going up, we are inputting the x/2 and outputting x.
	% We have included an if-statement in case this leads to non-integers (which should never happen).