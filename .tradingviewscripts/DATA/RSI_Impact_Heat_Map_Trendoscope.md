<!-- tradingview-pine-id: PUB;7e009341f7ac4c4681bf3cbc823a3972 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Impact Heat Map [Trendoscope]

Source: https://www.tradingview.com/script/zsmaLEyI-RSI-Impact-Heat-Map-Trendoscope/

## Description

Here is a simple tool to measure and display outcome of certain RSI event over heat map.

🎲 Process

🎯Event
Event can be either Crossover or Crossunder of RSI on certain value. 

🎯Measuring Impact
Impact of the event after N number of bars is measured in terms of highest and lowest displacement from the last close price. Impact can be collected as either number of times of ATR or percentage of price. Impact for each trigger is recorded separately and stored in array of custom type.

🎯Plotting Heat Map

Heat map is displayed using pine tables. Users can select heat map size - which can vary from 10 to 90. Selecting optimal size is important in order to get right interpretation of data. Having higher number of cells can give more granular data. But, chart may not fit into the window. Having lower size means, stats are combined together to get less granular data which may not give right picture of the results. Default value for size is 50 - meaning data is displayed in 51X51 cells.

Range of the heat map is adjusted automatically based on min and max value of the displacement. In order to filter out or merge extreme values, range is calculated based on certain percentile of the values. This will avoid displaying lots of empty cells which can obscure the actual impact.

🎲 Settings

Settings allow users to define their event, impact duration and reference, and few display related properties. The description of these parameters are as below:
https://www.tradingview.com/x/XLHWXCbQ/

🎲 Use Cases
In this script, we have taken RSI as an example to measure impact. But, we can do this for any event. This can be price crossing over/under upper/lower bollinger bands, moving average crossovers or even complex entry or exit conditions. Overall, we can use this to plot and evaluate our trade criteria.

🎲 Interpretation

[*] Q1 - If more coloured dots appear on the top right corner of the table, then the event is considered to trigger high volatility and high risk environment.
[*] Q2 - If more coloured dots appear on the top left corner, then the events are considered to trigger bearish environment.
[*] Q3 - If more coloured dots appear on the bottom left corner of the chart, then the events are considered insignificant as they neither generate higher displacement in positive or negative side. You can further alter outlier percentage to reduce the bracket and hence have higher distribution move towards 
[*] Q4 - If more coloured dots appear on the bottom right corner, then the events are considered to trigger bullish environment.

Will also look forward to implement this as library so that any conditions or events can be plugged into it.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed
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
indicator("RSI Impact Heat Map [Trendoscope]", "RSIHM[Trendoscope]", overlay = false)

rsiSource = input.source(close, 'Source', inline='r', group='RSI')
rsiLength = input.int(14, '', 5, 200, 5, inline='r', group='RSI', tooltip = 'RSI configuration')
rsiTrigger = input.string('Crossover', 'Trigger', ['Crossover', 'Crossunder'], inline='rt', group = 'RSI')
rsiTriggerValue = input.int(70, '', 0, 100, 5, inline='rt', group = 'RSI', tooltip = 'Trigger for which we need to plot the impact')

impactDuration = input.int(20, 'Duration', 0, 500, 10, group='Impact', tooltip = 'Duration for which impact needs to be measured')
reference = input.string('ATR', 'Reference', ['ATR', 'Percentage'], group='Impact', tooltip='Reference on which the impact is measured')

matrixSize = input.int(50, 'Heat Map Size', 10, 90, 10, group='Display', tooltip = 'Number of rows, columns for heat map matrix')
outliersPercentile = input.int(95, 'Outliers Percentile', 50, 100, 5, group='Display', tooltip = 'Percentile to filter outliers. Value of 95 means, 95th percentile is considered as max displacement')

backgroundColor = input.color(color.rgb(0,0,0,0), 'Background', group='Display', tooltip = 'Background color')
heatmapColor = input.color(color.red, 'Heatmap', group='Display', tooltip = 'Heatmap color')
type Event
    float xValue
    float yValue

var array<Event> events = array.new<Event>()

rsi = ta.rsi(rsiSource, rsiLength)
trigger = rsiTrigger == 'Crossover' ? ta.crossover(rsi, rsiTriggerValue) : ta.crossunder(rsi, rsiTriggerValue)
atr = ta.atr(rsiLength)

highest = ta.highest(impactDuration-1)
lowest = ta.lowest(impactDuration-1)

var array<float> displacements = array.new<float>()

if(trigger[impactDuration])
    price = close[impactDuration]
    positiveDisplacement = math.abs(highest-price)
    negativeDisplacement = math.abs(price-lowest)
    xValue = reference == 'ATR'? positiveDisplacement/atr[impactDuration] : reference == 'Percentage' ? positiveDisplacement/price : positiveDisplacement
    yValue = reference == "ATR"? negativeDisplacement/atr[impactDuration] : reference == 'Percentage' ? negativeDisplacement/price : negativeDisplacement
    array.push(displacements, xValue)
    array.push(displacements, yValue)

    Event event = Event.new(xValue, yValue)
    array.push(events, event)

if(barstate.isfirst)
    var titleTable = table.new(position.top_center, 2, 3, color.maroon, color.maroon, 1, color.maroon, 1)
    title = 'Impact of RSI('+str.tostring(rsiLength)+') '+rsiTrigger+' '+str.tostring(rsiTriggerValue)+ ' after '+str.tostring(impactDuration)+ ' bars measured in terms of '+reference
    table.cell(titleTable, 0, 0, title, text_color = color.white)

if(barstate.islast)
    matrix<int> counts = matrix.new<int>(matrixSize+1, matrixSize+1, 0)
    maxRange = array.percentile_linear_interpolation(displacements, outliersPercentile)
    for event in events
        xIndex = math.min(int(event.xValue*matrixSize/maxRange), matrixSize)
        yIndex = matrixSize - math.min(int(event.yValue*matrixSize/maxRange), matrixSize)
        matrix.set(counts, xIndex, yIndex, matrix.get(counts, xIndex, yIndex)+1)

    var heatmap = table.new(position.middle_center, matrixSize+1, matrixSize+1, backgroundColor, color.yellow, 1, backgroundColor, 0)
    table.clear(heatmap, 0, 0, matrixSize, matrixSize)
    maxCount = matrix.max(counts)
    totalCount = array.size(events)
    sums = array.new<int>(4,0)
    for [i, columns] in counts
        for [j, count] in columns
            countPercent = int(count*90/maxCount)
            sumIndex = 2*(i < ((matrixSize+1)/2) ? 0 : 1) + (j < ((matrixSize+1)/2)? 0: 1)
            array.set(sums, sumIndex, array.get(sums, sumIndex)+count)
            xRange = 'Positive Displaecment : ' + (reference == 'Percentage'? str.tostring(maxRange*i*100/matrixSize, format.percent) : (str.tostring(maxRange*i/matrixSize, format.mintick) + 'X'))
                                              + ' - '+ ((i==matrixSize)? '' : 
                                             (reference == 'Percentage'? str.tostring(maxRange*(i+1)*100/matrixSize, format.percent) : (str.tostring(maxRange*(i+1)/matrixSize, format.mintick) + 'X')))
            yRange = 'Negative Displacement : ' + (reference == 'Percentage'? str.tostring(maxRange*(matrixSize-j)*100/matrixSize, format.percent) : (str.tostring(maxRange*(matrixSize-j)/matrixSize, format.mintick) + 'X'))
                                              + ' - '+ ((j==matrixSize)? '' : 
                                             (reference == 'Percentage'? str.tostring(maxRange*(matrixSize-j+1)*100/matrixSize, format.percent) : (str.tostring(maxRange*(matrixSize-j+1)/matrixSize, format.mintick) + 'X')))
            tooltip = 'Count '+str.tostring(count)+'/'+str.tostring(totalCount)+'\n'+xRange+'\n'+yRange+'\n('+str.tostring(i)+','+str.tostring(j)+')'
            table.cell(heatmap, i, j, '', width=1, height = 1, text_color=color.yellow, bgcolor = color.new(heatmapColor, countPercent==0? 100 : 90-countPercent), text_size = size.tiny, tooltip = tooltip)

    var positions = array.from(position.top_left, position.bottom_left, position.top_right, position.bottom_right)
    for [i, sum] in sums
        tab = table.new(array.get(positions, i), 1,1, color.teal, color.teal, 1, color.teal, 1)
        table.cell(tab, 0, 0, str.tostring(sum), text_color = color.white, text_size = size.large)
````
