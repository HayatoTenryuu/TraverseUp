
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

%% Call Prolog and Load data
SeeUntouched = false;

Start = 1;
Limit = 1000;

startString = string(Start);
limitString = string(Limit);

% Clean Data
command = sprintf(' "traverseUp.exe" %s %s', startString, limitString);
yn = system(command);

if (yn ~= 0)
    fprintf("The system call didn't work!" + newline);
    return
end

fileID = fopen("binary tree.compendium","r"); 

if (fileID == -1)
    fprintf("Error: Cannot find Compendium." + newline + newline);
    return;
end

data1 = textscan(fileID, "%s");
temp1 = string(data1{1});
newA = strsplit(temp1, "[;]");
fclose(fileID);

% Ugly data
if (Limit <= 1000)
    command2 = sprintf(' "uglyTraverseUp.exe" %s %s', startString, limitString);
    yn2 = system(command2);

    if (yn2 ~= 0)
        fprintf("The system call didn't work!" + newline);
        return
    end

    fileID2 = fopen("unclean binary tree.compendium","r"); 
    
    if (fileID2 == -1)
        fprintf("Error: Cannot find Compendium." + newline + newline);
        return;
    end
    
    data2 = textscan(fileID2, "%s");
    temp2 = string(data2{1});
    newB = strsplit(temp2, "[;]");
    fclose(fileID2);

end

%% Format data as source and target arrays
source1 = str2num( newA(1) );
target1 = str2num( newA(2) );

if (Limit <= 1000)
    source2 = str2num( newB(1) );
    target2 = str2num( newB(2) );
end

%% Plot results as digraph

if (length(target1) ~= length(source1))
    for x = 1:(length(source1)-length(target1))
        target1(end+1) = floor(source1(end)/2);
    end
end

if (Limit <= 1000)
    if (length(target2) ~= length(source2))
        for x = 1:(length(source2)-length(target2))
            target2(end+1) = floor(source2(end)/2);
        end
    end
end

%{---------------------------%}
%{  Clean digraph data plot  %}
%{---------------------------%}

G = figure(1);

sgtitle("Connected Points Shown as Network" + newline);

if (SeeUntouched)
    if (Limit <= 1000)
        T = subplot(1, 2, 1);
    else
        T = subplot(1, 1, 1);
    end

    t1 = plot( digraph(source1, target1), ArrowSize = 5 );

    title("Why is this a neural net?")

    set( get(T,'XLabel'), 'String', 'Data cleaned for duplication' );

    t1.NodeLabelMode = "auto";
else
    [u, ~, w] = unique( [source1, target1] );

    if (Limit <= 1000)
        T = subplot(1, 2, 1);
    else
        T = subplot(1, 1, 1);
    end

    t1 = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), ArrowSize = 5 );

    title("Why is this a neural net?")

    set( get(T,'XLabel'), 'String', 'Data cleaned for duplication' );

    t1.NodeLabelMode = "auto";
end


%{---------------------------%}
%{  Dirty digraph data plot  %}
%{---------------------------%}

if (Limit <= 1000)
    if (SeeUntouched)
        W = subplot(1, 2, 2); 
        w1 = plot( digraph(source2, target2), ArrowSize = 5 );
    
        title("Why is this biological?")
    
        set( get(W,'XLabel'), 'String', 'Data not cleaned for duplication' );
    
        w1.NodeLabelMode = "auto";
    else
        [g, ~, h] = unique( [source2, target2] );
    
        W = subplot(1, 2, 2);
        w1 = plot( digraph( h(1:floor(end/2)), h(ceil(end/2)+1:end), [], cellstr(num2str(g.')) ), ArrowSize = 3 );
    
        title("Why is this biological?")
    
        set( get(W,'XLabel'), 'String', 'Data not cleaned for duplication' );
    
        w1.NodeLabelMode = "auto";
    end
end


%% Plot results as tree

%{
countTargs = 0;

for (n = 1:length(target1))
    yesno = ismember(target1(n), source1);
    if (yesno == 1)
        countTargs = countTargs + 1;
    end
end 
%}

countNode = length(target1);     % + countTargs;

treeFrame = [1:countNode];

for (n = 1:length(source1))
    for (m = 2:length(source1))
        if (n == length(source1))   
            continue;
        else
            % This is probably not specific enough to go through and correct everything a single time and leave it.
            % I suspect it acts as an equalizer, changing things multiple times as they begin to match each other after their initial change.
            % The way to fix this would be to have a changed[] array with 1 if a number was changed and 0 if not. 
            % If changed is 0, you can change this number. If changed is not zero, leave it alone.
            if (source1(m) == source1(n))
                treeFrame(m) = min(m,n);
            else
                continue;
            end
        end
    end
end

treeFrame = [0, treeFrame];

%{------------------------%}
%{  Clean tree data plot  %}
%{------------------------%}

G2 = figure(2);

sgtitle("Connected Points Shown as Tree" + newline);

treeplot(treeFrame);

