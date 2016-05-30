function plotBehavioralDataWM_CAP_PSYPHY(parametersStudy.indexWorkingMemoryCapacity, pathDefinition, subjectArray, parametersParadigm, computedBehavioralData); 
%%%
%%% Creates a plot depicting the behavioral results
parametersPlot.xLabel                   = 'ITI';
parametersPlot.xLabelFontName           = 'times';
parametersPlot.xLabelFontWeight         = 'bold';
parametersPlot.xLabelFontSize           = 8;

parametersPlot.xLimitOffset             = 0.5; 
parametersPlot.xLimit                   = [1 - parametersPlot.xLimitOffset, parametersParadigm.nOfConditions + parametersPlot.xLimitOffset]; 
parametersPlot.xTick                    = 1:parametersParadigm.nOfConditions;
parametersPlot.xTickLabel               = {  
    '33 msec'
    '67 msec'
    '100 msec'
    '467 msec'
    };
parametersPlot.xColor                   = 'w';



parametersPlot.yLabel                   = 'Accuracy';
parametersPlot.yLabelFontName           = 'times';
parametersPlot.yLabelFontWeight         = 'bold';
parametersPlot.yLabelFontSize           = 8;

parametersPlot.yLimit                   = [50 100]; 
parametersPlot.yTick                    = parametersPlot.yLimit(1):10:parametersPlot.yLimit(2);
parametersPlot.yTickLabel               = sprintf('%.0f %%|', parametersPlot.yTick);
parametersPlot.yColor                   = 'w';
parametersPlot.yGridSwitch              = 'on';

parametersPlot.axesFontName             = 'times'; 
parametersPlot.axesFontWeight           = 'bold'; 
parametersPlot.axesFontSize             = 8;

parametersPlot.graphLineType             = '-';
parametersPlot.graphLineWidth            = 0.5;
parametersPlot.graphLineColor            = [0 0 1];

parametersPlot.plotTitle                = sprintf('Performance');
parametersPlot.plotColorSurround        = 'black';
parametersPlot.plotColorBackground      = [0 0 0];


parametersPlot.titleFontName            = 'times';
parametersPlot.titleFontWeigth          = 'bold';
parametersPlot.titleFontSize            = 10;
parametersPlot.titleFontColor           = 'w';

parametersPlot.legendVector             = 'AccuracyLoad3';
parametersPlot.legendColorBackground    = parametersPlot.plotColorBackground;
parametersPlot.legendFontColor          = [1 1 1];
parametersPlot.legendFontSize           = 4;
parametersPlot.legendLocation           = 'South';



scrsz = get(0, 'ScreenSize');
    behavioralDataPlot = figure('color', parametersPlot.plotColorSurround, 'Position', [1 scrsz(4)/2.2 scrsz(3) scrsz(4)/2.2]);
    handleAxes = axes;
    
    set(handleAxes, 'Color', parametersPlot.plotColorBackground) 
    set(handleAxes, 'FontName', parametersPlot.axesFontName)
    set(handleAxes, 'FontWeight', parametersPlot.axesFontWeight)
    set(handleAxes, 'FontSize', parametersPlot.axesFontSize)

    set(handleAxes, 'XColor', parametersPlot.xColor)
    set(handleAxes, 'XLim', parametersPlot.xLimit)
    set(handleAxes, 'XTick', parametersPlot.xTick)
    set(handleAxes, 'XTickLabel', parametersPlot.xTickLabel)
    
    set(handleAxes, 'YColor', parametersPlot.yColor)
    set(handleAxes, 'YLim', parametersPlot.yLimit)
    set(handleAxes, 'YTick', parametersPlot.yTick)
    set(handleAxes, 'YTickLabel', parametersPlot.yTickLabel)
    set(handleAxes, 'YGrid', parametersPlot.yGridSwitch)
    
    set(get(handleAxes, 'XLabel'), 'String', parametersPlot.xLabel)
    set(get(handleAxes, 'XLabel'), 'FontName', parametersPlot.xLabelFontName)
    set(get(handleAxes, 'XLabel'), 'FontWeight', parametersPlot.xLabelFontWeight)
    set(get(handleAxes, 'XLabel'), 'FontSize', parametersPlot.xLabelFontSize)
    
    set(get(handleAxes, 'YLabel'), 'String', parametersPlot.yLabel)
    set(get(handleAxes, 'YLabel'), 'FontName', parametersPlot.yLabelFontName)
    set(get(handleAxes, 'YLabel'), 'FontWeight', parametersPlot.yLabelFontWeight)
    set(get(handleAxes, 'YLabel'), 'FontSize', parametersPlot.yLabelFontSize)
    

    hold on
    
    handleTitle = title(parametersPlot.plotTitle);
    
    set(handleTitle, 'Color', parametersPlot.titleFontColor, 'FontName', parametersPlot.titleFontName, 'FontWeight', parametersPlot.titleFontWeigth, 'FontSize', parametersPlot.titleFontSize);
    



    %%% The data points and standard error bars are defined / plotted
    %%% Accuracy and standard error values are multiplied by 100 to fit
    %%% into the percent scale
    graph = errorbar(computedBehavioralData.meanConditionAccuracy * 100, computedBehavioralData.standardErrorConditionAccuracy * 100, parametersPlot.graphLineType);
    set(graph, 'color', parametersPlot.graphLineColor);
    set(graph, 'LineWidth', parametersPlot.graphLineWidth);
    
%    test = computedBehavioralData.meanConditionAccuracy
%     computedBehavioralData.meanConditionAccuracy{c} =
%     mean(computedBehavioralData.conditionAccuracy(:, c)); 
% computedBehavioralData.standardErrorConditionAccuracy{c} = std(computedBehavioralData.conditionAccuracy(:, c) * 100) / sqrt(length(subjectArray));

    handleLegend = legend(parametersPlot.legendVector);
    set(handleLegend, 'Color', parametersPlot.legendColorBackground)
    set(handleLegend, 'TextColor', parametersPlot.legendFontColor)
    set(handleLegend, 'FontSize', parametersPlot.legendFontSize)
    set(handleLegend, 'Location', parametersPlot.legendLocation)
    
    %%% Save Behavioral Data Plot as PNG
    set(gcf,'PaperPosition',[-1.17 1.82 13.33 4.85],'PaperType','A4', 'PaperOrientation', 'portrait')
    set(gcf, 'InvertHardCopy', 'off');
    plotFileName = sprintf('%s_%s_Performance_%i_subj', parametersStudy.indexWorkingMemoryCapacity, parametersParadigm.indexExperiment, length(subjectArray));
    formatGraphicsFile = 'png';
    print(behavioralDataPlot,['-d' formatGraphicsFile],'-r600', plotFileName);
    movefile([pathDefinition.matlab, plotFileName, ['.' formatGraphicsFile]], pathDefinition.behavioralData);
    close all
