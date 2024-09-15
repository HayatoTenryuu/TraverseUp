classdef Collatz_Up < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        CircularDigraphvideoCheckBox   matlab.ui.control.CheckBox
        StatusInactiveLabel            matlab.ui.control.Label
        ShowdisconnectednodesCheckBox  matlab.ui.control.CheckBox
        DigraphvideoCheckBox           matlab.ui.control.CheckBox
        CircularplotCheckBox           matlab.ui.control.CheckBox
        DigraphplotCheckBox            matlab.ui.control.CheckBox
        StopafterEditField             matlab.ui.control.NumericEditField
        StopafterEditFieldLabel        matlab.ui.control.Label
        StartingfromEditField          matlab.ui.control.NumericEditField
        StartingfromEditFieldLabel     matlab.ui.control.Label
        LetsGoButton                   matlab.ui.control.Button
        TraverseUpDataEntryLabel       matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LetsGoButton
        function LetsGoButtonPushed(app, event)
            if (~isinteger(app.StartingfromEditField.Value))
                 app.StartingfromEditField.Value = round(app.StartingfromEditField.Value, 1);
            end
            
            if (~isinteger(app.StopafterEditField.Value))
                app.StopafterEditField.Value = round(app.StopafterEditField.Value, 1);
            end

            treeGraph(app.StartingfromEditField.Value, app.StopafterEditField.Value, ...
                app.DigraphplotCheckBox.Value, app.ShowdisconnectednodesCheckBox.Value, ...
                app.CircularplotCheckBox.Value, app.DigraphvideoCheckBox.Value, ...
                app.CircularDigraphvideoCheckBox.Value, app.StatusInactiveLabel);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get screen size info for app positioning
            ScrSize = get(0, "ScreenSize");
            UISize = 480;
            UIPosX = (ScrSize(3)/2) - (UISize/2);
            UIPosY = (ScrSize(4)/2) - (UISize/2);

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [UIPosX UIPosY UISize UISize];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.WindowStyle = 'alwaysontop';

            % Create TraverseUpDataEntryLabel
            app.TraverseUpDataEntryLabel = uilabel(app.UIFigure);
            app.TraverseUpDataEntryLabel.FontSize = 28;
            app.TraverseUpDataEntryLabel.Position = [84 401 301 37];
            app.TraverseUpDataEntryLabel.Text = 'Traverse Up Data Entry:';

            % Create LetsGoButton
            app.LetsGoButton = uibutton(app.UIFigure, 'push');
            app.LetsGoButton.ButtonPushedFcn = createCallbackFcn(app, @LetsGoButtonPushed, true);
            app.LetsGoButton.FontSize = 16;
            app.LetsGoButton.Position = [145 94 171 48];
            app.LetsGoButton.Text = 'Let''s Go!';

            % Create StartingfromEditFieldLabel
            app.StartingfromEditFieldLabel = uilabel(app.UIFigure);
            app.StartingfromEditFieldLabel.HorizontalAlignment = 'center';
            app.StartingfromEditFieldLabel.FontSize = 14;
            app.StartingfromEditFieldLabel.Position = [89 343 100 22];
            app.StartingfromEditFieldLabel.Text = 'Starting from:';

            % Create StartingfromEditField
            app.StartingfromEditField = uieditfield(app.UIFigure, 'numeric');
            app.StartingfromEditField.ValueDisplayFormat = '%.0f';
            app.StartingfromEditField.HorizontalAlignment = 'center';
            app.StartingfromEditField.Position = [89 321 100 22];
            app.StartingfromEditField.Value = 1;

            % Create StopafterEditFieldLabel
            app.StopafterEditFieldLabel = uilabel(app.UIFigure);
            app.StopafterEditFieldLabel.HorizontalAlignment = 'center';
            app.StopafterEditFieldLabel.FontSize = 14;
            app.StopafterEditFieldLabel.Position = [272 343 100 22];
            app.StopafterEditFieldLabel.Text = 'Stop after:';

            % Create StopafterEditField
            app.StopafterEditField = uieditfield(app.UIFigure, 'numeric');
            app.StopafterEditField.ValueDisplayFormat = '%.0f';
            app.StopafterEditField.HorizontalAlignment = 'center';
            app.StopafterEditField.Position = [272 321 100 22];
            app.StopafterEditField.Value = 10000;

            % Create DigraphplotCheckBox
            app.DigraphplotCheckBox = uicheckbox(app.UIFigure);
            app.DigraphplotCheckBox.Text = 'Digraph plot';
            app.DigraphplotCheckBox.Position = [178 273 86 22];

            % Create CircularplotCheckBox
            app.CircularplotCheckBox = uicheckbox(app.UIFigure);
            app.CircularplotCheckBox.Text = 'Circular plot';
            app.CircularplotCheckBox.Position = [178 219 86 22];

            % Create DigraphvideoCheckBox
            app.DigraphvideoCheckBox = uicheckbox(app.UIFigure);
            app.DigraphvideoCheckBox.Text = 'Digraph video';
            app.DigraphvideoCheckBox.Position = [178 192 96 22];

            % Create ShowdisconnectednodesCheckBox
            app.ShowdisconnectednodesCheckBox = uicheckbox(app.UIFigure);
            app.ShowdisconnectednodesCheckBox.Text = 'Show disconnected nodes';
            app.ShowdisconnectednodesCheckBox.Position = [178 246 162 22];

            % Create StatusInactiveLabel
            app.StatusInactiveLabel = uilabel(app.UIFigure);
            app.StatusInactiveLabel.HorizontalAlignment = 'center';
            app.StatusInactiveLabel.FontSize = 14;
            app.StatusInactiveLabel.Position = [81 40 306 34];
            app.StatusInactiveLabel.Text = '< Status: Inactive >';

            % Create CircularDigraphvideoCheckBox
            app.CircularDigraphvideoCheckBox = uicheckbox(app.UIFigure);
            app.CircularDigraphvideoCheckBox.Text = 'Circular Digraph video';
            app.CircularDigraphvideoCheckBox.Position = [178 165 140 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Collatz_Up

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
            delete(app)
        end
    end
end