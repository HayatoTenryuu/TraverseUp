
%% TraverseUp
% Summary:
% This runs Collatz up from X capping it at Y, with the syntax:
%       system(' "traverseUp.exe" X Y');
%
% It then loads the COMPENDIUM file that is created and graphs
% the numerical relationships as a directed graph.
%
% Note: The default behavior is to filter out extra nodes, but
% I have left in code to include them if you want that.

%{

1. Optimize Prolog code to be faster and prune earlier (currently doesn't much).
    This is to deal with issues regarding higher numbers than 1000 taking forever
    to process, which may be a bug in the Prolog code, or is due to the higher 
    number of branches in the trees when it takes that long to return to 1.

2. See if we can't carefully optimize the ugly code to handle higher numbers too.
    Both have issues over 1000, so it may indeed be an infinite loop bug, or it
    is again a time complexity issue with high recursion. Either way, when you solve
    it for the clean code, see if you can solve it for the ugly one too without making
    it lose its organic sense.

%}

%% Load data
SeeUntouched = false;

system(' "traverseUp.exe" 1 1000');
fileID = fopen("binary tree.compendium","r"); 
data1 = textscan(fileID, "%s");
temp1 = string(data1{1});
newA = strsplit(temp1, "[;]");
fclose(fileID);

system(' "uglyTraverseUp.exe" 1 1000');
fileID2 = fopen("unclean binary tree.compendium","r"); 
data2 = textscan(fileID2, "%s");
temp2 = string(data2{1});
newB = strsplit(temp2, "[;]");
fclose(fileID2);

%% Format data as source and target arrays
source1 = str2num( newA(1) );
target1 = str2num( newA(2) );

source2 = str2num( newB(1) );
target2 = str2num( newB(2) );

%% Plot results

if (length(target1) ~= length(source1))
    for x = 1:(length(source1)-length(target1))
        target1(end+1) = floor(source1(end)/2);
    end
end

if (length(target2) ~= length(source2))
    for x = 1:(length(source2)-length(target2))
        target2(end+1) = floor(source2(end)/2);
    end
end

% Clean data plot
F1 = figure(1);

if (SeeUntouched)
    T = plot( digraph (source1, target1), "ArrowSize", 5);
    T.NodeLabelMode = "auto";
else
    [u, ~, w] = unique( [source1, target1] );

    T = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), "ArrowSize", 5 );
    T.NodeLabelMode = "auto";
end

% Dirty data plot
F2 = figure(2);

if (SeeUntouched)
    W = plot( digraph (source2, target2), "ArrowSize", 5);
    W.NodeLabelMode = "auto";
else
    [g, ~, h] = unique( [source2, target2] );

    W = plot( digraph( h(1:floor(end/2)), h(ceil(end/2)+1:end), [], cellstr(num2str(g.')) ), "ArrowSize", 3 );
    W.NodeLabelMode = "auto";
end