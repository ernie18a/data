# Oscillator Scatterplot Analysis [Trendoscope®]

- url: https://www.tradingview.com/script/hLKTlpwc-Oscillator-Scatterplot-Analysis-Trendoscope/
- type: indicator
- pine_id: PUB;9c1ee606cbc24f5c81cb48aeeb796ad2
- version: 1.0

## Description

In this indicator, we demonstrate how to plot oscillator behavior of oversold-overbought against price movements in the form of scatterplots and perform analysis. Scatterplots are drawn on a graph containing x and y-axis, where x represent one measure whereas y represents another. We use the library [url=https://www.tradingview.com/script/gktUKXwo-Graph/]Graph[/url] to collect the data and plot it as scatterplot.

Pictorial explanation of components is defined in the chart below.
https://www.tradingview.com/x/O2AN72rK/

[b]🎲 This indicator performs following tasks[/b]

[list=1]
[*] Calculate and plot oscillator
[*] Identify oversold and overbought areas based on various methods
[*] Measure the price and bar movement from overbought to oversold and vice versa and plot them on the chart.
[/list]

[b]In our example, [/b]
[list]
[*] The x-axis represents price movement. The plots found on the right side of the graph has positive price movements, whereas the plots found on the left side of the graph has negative price movements.
[*] The y-axis represents the number of bars it took for reaching overbought to oversold and/or oversold to overbought. Positive bars mean we are measuring oversold to overbought, whereas negative bars are a measure of overbought to oversold.
[/list]

[b]🎲 Graph is divided into 4 equal quadrants[/b]

[list]
[*] [b]Quadrant 1[/b] is the top right portion of the graph. Plots in this quadrant represent the instances where positive price movement is observed when the oscillator moved from oversold to overbought
[*] [b]Quadrant 2[/b] is the top left portion of the graph. Plots in this quadrant represent the instances where negative price movement is observed when the oscillator moved from oversold to overbought.
[*] [b]Quadrant 3[/b] is the bottom left portion of the chart. Plots in this quadrant represent the instances where negative price movement is observed when the oscillator moved from overbought to oversold.
[*] [b]Quadrant 4[/b] is the bottom right portion of the chart. Plots in this quadrant represent the instances where positive price movement is observed when the oscillator moved from overbought to oversold.
[/list]

[b]🎲 Indicator components in Detail[/b]
Let's dive deep into the indicator.

[b]🎯 Oscillator Selection [/b]
Select the Oscillator and define the overbought oversold conditions through input settings
https://www.tradingview.com/x/INufVxjx/

[list]
[*] [b]Indicator[/b] - Oscillator base used for performing analysis
[*] [b]Length[/b] - Loopback length on which the oscillator is calculated
[*] [b]OB/OS Method[/b] - We use Bollinger Bands, Keltener Channel and Donchian channel to calculate dynamic overbought and oversold levels instead of static 80-10. This is also useful as other type of indicators may not be within 0-100 range.
[*] [b]Length and Multiplier[/b] are used for the bands for calculating Overbought/Oversold boundaries.
[/list]

[b]🎯 Define Graph Properties [/b]
Select different graph properties from the input settings that will instruct how to display the scatterplot.
https://www.tradingview.com/x/uRxGPhqn/

[list]
[*] [b]Type[/b] - this can be either scatterplot or heatmap. Scatterplot will display plots with specific transparency to indicate the data, whereas heatmap will display background with different transparencies.
[*] [b]Plot Color[/b] - this is the color in which the scatterplot or heatmap is drawn
[*] [b]Plot Size[/b] - applicable mainly for scatterplot. Since the character we use for scatterplot is very tiny, the large at present looks optimal. But, based on the user's screen size, we may need to select different sizes so that it will render properly.
[*] [b]Rows and Columns[/b] - Number of rows and columns allocated per quadrant. This means, the total size of the chart is 2X rows and 2X columns. Data sets are divided into buckets based on the number of available rows and columns. Hence, changing this can change the appearance of the overall chart, even though they are representing the same data. Also, please note that tables can have max 10000 cells. If we increase the rows and columns by too much, we may get runtime errors.
[*] [b]Outliers[/b] - this is used to exclude the extreme data. 20% outlier means, the chart will ignore bottom 20% and top 20% when defining the chart boundaries. However, the extreme data is still added to the boundaries.
[/list]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒                        
//@version=5
indicator("Oscillator Scatterplot Analysis [Trendoscope®]")
import TradingView/ta/7
import HeWhoMustNotBeNamed/ta/1 as eta
import Trendoscope/Graph/2 as gr

sourceType = input.string('rsi', 'Indicator', ['rsi', 'cci', 'cmo', 'cog', 'mfi', 'roc', 'price'], tooltip = 'Indicator Source',
                 group='Oscillator', display = display.none)
length = input.int(14, 'Length', minval=5, step=5, tooltip = 'Oscillator Length', group = 'Oscillator', display = display.none)
bandType = input.string('bb', 'OB/OS Method', ['bb', 'kc', 'dc1', 'dc2'], tooltip = 'Different ways to identify overbought-oversold criteria. Here we are using bands instead of constant values',
                         group = 'Band', display = display.none)
bandLength = input.int(20, 'Length', minval=5, step=5, tooltip = 'Band Length', group = 'Band', display = display.none)
multiplier = input.float(2, 'Multiplier', minval=0.5, step=0.5, tooltip = 'Band multiplier to be used for BB and KC', group = 'Band', display = display.none)

graphType = input.enum(gr.GraphType.scatterplot, 'Type', group='Graph', display = display.none, tooltip = 'Graph Type - scatterlpot or heatmap')
plotColor = input.color(color.yellow, 'Plot Color', group='Graph', display = display.none, tooltip = 'Color in which the graph needs to be plotted')
plotsize = input.string(size.large, 'Plot Size', [size.tiny, size.small, size.normal, size.large, size.huge], 'Size of the cells in the table', group = 'Graph', display = display.none)
rows = input.int(30, 'Rows', display = display.none, group = 'Graph', tooltip = 'Number of rows per quadrant')
columns = input.int(30, 'Columns', display = display.none, group='Graph', tooltip = 'Number of columns per quadrant')
outliers = input.int(20, 'Outliers', minval=0, maxval=30, step=5, group='Graph', display = display.none,
                 tooltip = 'Data outlier as percentage. The graph will ignore first and last X% of data for the calculation of min and max range for plotting')

oscillator(simple string oscillatorType="rsi", simple int length=14, simple int shortLength = 13, simple int longLength = 25,
                     float source = close, float highSource = high, float lowSource = low)=>
    oscillator =  switch oscillatorType
        "cci" => ta.cci(source, length)
    	"cmo" => ta.cmo(source, length)
    	"cog" => ta.cog(source, length)
    	"mfi" => ta.mfi(source, length)
    	"roc" => ta.roc(source, length)
    	"rsi" => ta.rsi(source, length)
    	=> ta.rsi(source, length)

dc(float source, float highSource, float lowSource, simple int length)=> [source, ta.highest(highSource, length), ta.lowest(lowSource, length)]
dc(float source, simple int length)=> dc(source, source, source, length)
kc(float source, float highSource, float lowSource, simple int length, simple float multiplier)=>
    iTr = math.max(source, highSource, lowSource) - math.min(source, highSource, lowSource)
    iAtr = ta.sma(iTr, length)
    middle = ta.sma(source, length)
    [middle, middle+iAtr*multiplier, middle-iAtr*multiplier]

oscillatorBands(simple string bandType = 'bb', float source, float highSource, float lowSource, simple int bandLength, simple float bandMultiplier)=>
    [middle, upperBand, lowerBand] = switch bandType
        'bb' => ta.bb(source, bandLength, bandMultiplier)
        'kc' => kc(source, highSource, lowSource, bandLength, bandMultiplier)
        'dc1' => dc(source, bandLength)
        'dc2' => dc(source, highSource, lowSource, bandLength)

osc = sourceType == 'price'? close : oscillator(sourceType, length)
oscHigh = sourceType == 'price'? high : oscillator(sourceType, length, source = high)
oscLow = sourceType == 'price'? low: oscillator(sourceType, length, source=low)

[middle, overbought, oversold] = oscillatorBands(bandType, osc, oscHigh, oscLow, bandLength, multiplier)
plot(osc, 'Oscillator', color=color.purple)
plot(overbought, 'Overbought', color=color.red)
plot(oversold, 'Oversold', color=color.green)

var trend = 0
crossover = ta.crossover(osc, oversold)
crossunder = ta.crossunder(osc, overbought)
trend := crossover? 1 : crossunder? -1 : trend

var lastPriceRef = close
var lastBarRef = 0

var gr.Graph graph = gr.Graph.new(gr.GraphProperties.new(rows, columns, graphType, plotColor, plotsize, outliers = outliers)).init()

      
if (math.abs (ta.change(trend)) == 2)
    priceDiff = lastPriceRef - close
    barDiff = bar_index - lastBarRef
    dir = math.sign(-trend)

    float x = priceDiff
    float y = dir*barDiff

    graph.add(gr.Coordinate.new(x, y))

    lastPriceRef := close
    lastBarRef := bar_index


if(barstate.islast)
    graph.calculate().paint().paintQuadrantSummary()
````
