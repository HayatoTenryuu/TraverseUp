
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

%}

%% Call Prolog and Load data
SeeUntouched = false;

Start = 1;
Limit = 30000;

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

%% Format data as source and target arrays
source1 = str2num( newA(1) );
target1 = str2num( newA(2) );


%% Intersting other questions

top = max(target1);
all = [1:top];
outcast = [];

for (n = 1:length(all))
    if (ismember(all(n), target1))
        all(n) = 0;
    else
        continue;
    end
end

for (n = 1:length(all))
    if (all(n) == 0)
        continue;
    else
        outcast = [outcast, all(n)];
    end
end

smallestOutcast = min(outcast);
fprintf("There are " + length(outcast) + " outcasts out of " + ...
    max(target1) + " numbers" + newline);

%% Plot results as digraph

%{
The more data we have, the more pointless a graph is.
The plots don't change, they just get fuller.
Feel free to test this from 10 to 100,000.
Plotting does take a lot of time though, so it is better to skip it
once we know it will be data intensive (roughly 10,000 - 100,000 currently).
%}

if (Limit > 20000)
    return;
end

if (length(target1) ~= length(source1))
    for x = 1:(length(source1)-length(target1))
        target1(end+1) = floor(source1(end)/2);
    end
end


%{---------------------------%}
%{  Clean digraph data plot  %}
%{---------------------------%}

G = figure(1);
G.WindowState = "maximized";

sgtitle("Connected Points Shown as Network" + newline);

if (SeeUntouched)
    T = subplot(1, 1, 1);

    t1 = plot( digraph(source1, target1), ArrowSize = 5 );

    title("Why is this a neural net?")

    set( get(T,'XLabel'), 'String', 'Data cleaned for duplication' );

    t1.NodeLabelMode = "auto";
else
    [u, ~, w] = unique( [source1, target1] );

    T = subplot(1, 1, 1);

    t1 = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), ArrowSize = 5 );

    title("Why is this a tri-line with tags?")

    set( get(T,'XLabel'), 'String', 'Data cleaned for duplication' );

    t1.NodeLabelMode = "auto";
end


%% Plot results as tree

countNode = length(target1);     

treeFrame = [1:countNode];
changed = zeros(1, length(treeFrame));

for (n = 1:length(source1))
    for (m = 2:length(source1))
        if (n == length(source1))   
            continue;
        else
            if (source1(m) == source1(n))
                if (changed(m) == 0)
                    treeFrame(m) = min(m,n);
                    changed(m) = 1;
                else
                    continue;
                end
            else
                continue;
            end
        end
    end
end

treeFrame = [0, treeFrame];
changed = [0, changed];
totalList = string([1, target1]);


%{------------------------%}
%{  Clean tree data plot  %}
%{------------------------%}

G2 = figure(2);
G2.WindowState = "maximized";

sgtitle("Connected Points Shown as Tree" + newline);

treeplot(treeFrame, "or");
[x,y] = treelayout(treeFrame);
text(x + 1/(2*Limit), y + 1/(2*Limit), totalList);
