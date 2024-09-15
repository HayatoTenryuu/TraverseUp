function treeGraph(StartVal, LimitVal, diPlot, disconPlot, cirPlot, diVid, cirVid, statusLabel)
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
    statusLabel.Text = "< Status: Working >";

    SeeUntouched = disconPlot;
    Start = StartVal;
    Limit = LimitVal;
    
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
    
    %% Format data as source and target arrays, create standard plot color.
    source1 = str2num( newA(1) );
    target1 = str2num( newA(2) );
    
    colorR = 13.6;
    colorG = 116.9;
    colorB = 188.9;
    
    RGB = [colorR/255, colorG/255, colorB/255];
    
    ScrSize = get(0, 'ScreenSize');
    FigSize = 0.75 * ScrSize(4);

    FigPosX = (ScrSize(3)/2) - (FigSize);
    FigPosY = (ScrSize(4)/2) - (FigSize/2);
    
    %% Interesting other questions
    
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
    
    fprintf("There are " + length(outcast) + " numbers not accounted for, out of " + ...
        max(target1) + " numbers represented." + newline);
    fprintf("That's " + (100 * (length(outcast) / max(target1))) + "%% " + ...
        "of the values unattached so far!" + newline);
    fprintf(newline + "You might be surprised to learn that the smallest " + ...
        "unattached number is " + min(outcast) + "." + newline);
    
    %% Plot results as digraph
    
    %{
    The more data we have, the more pointless a graph is.
    The plots don't change, they just get fuller.
    Feel free to test this from 10 to 100,000.
    Plotting does take a lot of time though, so it is better to skip it
    once we know it will be data intensive (roughly 10,000 - 100,000 currently).
    %}

    statusLabel.Text = "< Status: Plotting Digraph >";
    
    if (length(target1) ~= length(source1))
        for x = 1:(length(source1)-length(target1))
            target1(end+1) = floor(source1(end)/2);
        end
    end
    

    if (diPlot == 1)

        %{---------------------------%}
        %{     Digraph data plot     %}
        %{---------------------------%}
        
        G = figure(1);
        G.Visible = "off";
        G.WindowState = "minimized";
        G.Position = [10, 10, 15360, 8640];
       
        T = tiledlayout(1, 1);
        title(T, "Why is this so amazing?");        
        set( get(T,'XLabel'), 'String', 'Data cleaned for duplication' );
        
        if (SeeUntouched)
            t1 = plot( digraph(source1, target1), ArrowSize = 5, Layout="layered");
            t1.NodeLabelMode = "auto";
        else
            [u, ~, w] = unique( [source1, target1] );

            t1 = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), ...
                ArrowSize = 5, Layout="layered");
            t1.NodeLabelMode = "auto";
        end 

        exportgraphics(G, "Digraph Tree Plot.emf", "ContentType", "vector");

        delete(G);
    end

    %% Plot results as circle
    
    %{
    The more data we have, the more pointless a graph is.
    The plots don't change, they just get fuller.
    Feel free to test this from 10 to 100,000.
    Plotting does take a lot of time though, so it is better to skip it
    once we know it will be data intensive (roughly 10,000 - 100,000 currently).
    %}

    statusLabel.Text = "< Status: Plotting Circle >";
    
    if (cirPlot == 1)

        %{---------------------------%}
        %{     Digraph data plot     %}
        %{---------------------------%}
        
        C = figure(2);
        C.Visible = "off";
        C.WindowState = "minimized";
        C.Position = [10, 10, 15360, 8640];
       
        M = tiledlayout(1, 1);
        title(M, "Why is this the coolest thing ever?");      
        set( get(M,'XLabel'), 'String', 'Data cleaned for duplication' );
        
        if (SeeUntouched)
            o1 = plot( digraph(source1, target1), ArrowSize = 5, Layout="circle");
            o1.NodeLabelMode = "auto";
        else
            [u, ~, w] = unique( [source1, target1] );

            o1 = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), ...
                ArrowSize = 5, Layout="circle");
            o1.NodeLabelMode = "auto";
        end 

        exportgraphics(C, "Digraph Circle Plot.emf", "ContentType", "vector");

        delete(C);
    end


    %% Create video of digraph being drawn.
    
    % I also want it to slowly zoom out if necessary.
    % Also constrain the size differently than you do for the other plots.

    statusLabel.Text = "< Status: Recording Tree >";
    
    if (diVid == 1)
        
        if (isfile("Fast Digraph Plot.mp4"))
            delete("Fast Digraph Plot.mp4");
        end

        vid = VideoWriter("Fast Digraph Plot", "MPEG-4");
        open(vid);

        V = figure(3);
        V.WindowState = "normal";
        V.Position = [FigPosX, FigPosY, 2*FigSize, FigSize];
        
        T = tiledlayout(1, 1);
        title(T, "Why is this so satisfying?");
        set( get(T,'XLabel'), 'String', 'Data cleaned for duplication' );

        axis padded;

        if (SeeUntouched)        
            for (i = 1:length(target1))                
                t1 = plot( digraph( source1(1:i), target1(1:i) ), ArrowSize = 5, ...
                    EdgeColor=RGB, NodeColor=RGB, Layout="layered");        
                t1.NodeLabelMode = "auto";
                
                writeVideo(vid, getframe(V));
            end
        else
            for (i = 1:length(target1))               
                [u, ~, w] = unique( [source1(1:i), target1(1:i)] );

                t1 = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), ...
                    ArrowSize= 5, EdgeColor=RGB, NodeColor=RGB, Layout="layered");
                t1.NodeLabelMode = "auto";
                
                writeVideo(vid, getframe(V));
            end
        end 

        close(vid);
    end

    %% Create video of circle being drawn.
    
    % I also want it to slowly zoom out if necessary.
    % Also constrain the size differently than you do for the other plots.

    statusLabel.Text = "< Status: Recording Circle >";
    
    if (cirVid == 1)
        
        if (isfile("Fast Circular Plot.mp4"))
            delete("Fast Circular Plot.mp4");
        end

        vid = VideoWriter("Fast Circular Plot", "MPEG-4");
        open(vid);

        J = figure(4);
        J.WindowState = "normal";
        J.Position = [FigPosX, FigPosY, 2*FigSize, FigSize];
        
        D = tiledlayout(1, 1);
        title(D, "Why is this so pretty?");
        set( get(D,'XLabel'), 'String', 'Data cleaned for duplication' );

        axis padded;

        if (SeeUntouched)        
            for (i = 1:length(target1))                
                d1 = plot( digraph( source1(1:i), target1(1:i) ), ArrowSize = 5, ...
                    EdgeColor=RGB, NodeColor=RGB, Layout="circle");        
                d1.NodeLabelMode = "auto";
                
                writeVideo(vid, getframe(J));
            end
        else
            for (i = 1:length(target1))               
                [u, ~, w] = unique( [source1(1:i), target1(1:i)] );

                d1 = plot( digraph( w(1:floor(end/2)), w(ceil(end/2)+1:end), [], cellstr(num2str(u.')) ), ...
                    ArrowSize= 5, EdgeColor=RGB, NodeColor=RGB, Layout="circle");
                d1.NodeLabelMode = "auto";
                
                writeVideo(vid, getframe(J));
            end
        end 

        close(vid);
    end

    beep;
    statusLabel.Text = "< Status: Complete! >";
end