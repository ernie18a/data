<!-- tradingview-pine-id: PUB;b93df3ed4e9644c79b241a88c0d19c52 -->
<!-- tradingviewscripts-format: 1 -->
# Peak Trading Activity Graphs [LuxAlgo]

Source: https://www.tradingview.com/script/TsTSP9sk-Peak-Trading-Activity-Graphs-LuxAlgo/

## Description

The Peak Trading Activity Graphs displays four graphs that allow traders to see at a glance the times of the highest and lowest volume and volatility for any month, day of the month, day of the week, or hour of the day. By default, it plots the median values of the selected data for each period. Traders can enable the Median Delta feature to further highlight differences in the data. The graphs are customizable in width and height and feature gradient colors by default.

🔶 USAGE
[image]https://www.tradingview.com/x/rSk48QiN/[/image]
The tool is simple yet powerful. Using the three main parameters on the settings panel, traders can display up to four different graphs and up to 16 different configurations.

There are two main types of data: volume and volatility. There are also four different time periods: months, days of the month, days of the week, and hours of the day. There is also the possibility of displaying the raw medians or the delta between them.

Understanding which time periods have the most and least volume and volatility is essential for any trader. From avoiding trading during periods of low volume to properly sizing positions during periods of high volatility, there are multiple use cases directly related to improving execution and risk management.

🔹 Months
[image]https://www.tradingview.com/x/lKzG26EW/[/image]
This chart shows the monthly volume and volatility of NQ as medians at the top and as the delta of medians at the bottom.

As we can see on the left-hand chart, the volume is fairly consistent throughout the year. January, March, and October have the highest volume, and December has the lowest volume for obvious reasons. Note the bottom chart with the delta feature enabled, which clearly shows the top and bottom periods.

On the right, we have volatility, which is also evenly distributed throughout most months. October is the most volatile month, and March is the least volatile month. The differences are also very clear on the bottom chart with delta enabled.

Traders may want to compare median volatility and volume by month to size positions and favor exposure during historically high-activity months.

🔹 Days of Month
[image]https://www.tradingview.com/x/HInS1JAq/[/image]
The same NQ charts are shown, but in this case, the Days of Month period has been selected. As you can see, this displays a calendar-like graph. The volume is on the left, the volatility is on the right, and the delta feature is enabled on the bottom charts. This feature allows for stronger differences in gradient.

The top charts show that the raw medians of both volume and volatility are evenly distributed. We need to enable the delta feature on the bottom charts to see where the most and least volume and volatility are.

Traders can use median activity by calendar day to anticipate liquidity expansions or contractions and adjust trade frequency.

🔹 Days of Week
[image]https://www.tradingview.com/x/qnUpkV3Q/[/image]
In this case, we have BTC charts with the same layout as before. Notably, the difference in volume on weekends is not as pronounced from a volatility perspective on those same days.

A practical use case can be differentiate high-risk, high-participation weekdays from low-activity sessions to select trend or range-based strategies.

🔹 Hours of Day
[image]https://www.tradingview.com/x/s0Y2jkn7/[/image]
This shows the volume and volatility of each hour of the day for gold futures. As we can see, the most volume and volatility occur during the three hours around the RTH open at 8:00, 9:00, and 10:00 a.m.

Traders may want to isolate hours with the highest median volatility and volume to concentrate execution and avoid low-liquidity periods.

🔹 Assets Comparison
[image]https://www.tradingview.com/x/hmXDqAqN/[/image]
This tool allows us to compare different assets over the same period. In this case, we are comparing the hours of the day for 10-year notes, the S&P 500, silver, and the yen. Each asset has a different volatility profile throughout the day.
[image]https://www.tradingview.com/x/r1RmozlI/[/image]
With the Delta feature enabled, we can clearly see the differences. The 10Y Notes move from 7:00 to 9:00 and from 2:00 to 9:00. The Yen moves from 7:00 to 9:00 and from 2:00 to 9:00. Silver moves from 8:00 to 10:00. The S&P 500 moves from 8:00 to 9:00 and from 14:00 to 15:00. All times are in exchange time.

🔹 Sizing & Coloring Graphs
[image]https://www.tradingview.com/x/wg1eZHjo/[/image]
Traders can adjust the width and height of the graphs, as well as the text size, at will.
[image]https://www.tradingview.com/x/sy0yXnV9/[/image]
Traders can choose from four different color configurations in the settings panel.

🔶 SETTINGS

[*]Data: Select the type of data to display: Volume or Volatility.
[*]Period: Select the time period to display: Month, Day of Month, Day of Week, or Hours.
[*]Display delta between medians. Display the difference between the medians as a percentage. The smaller median is 0 and the larger median is 100. Enabling this feature highlights the differences between values.

🔹 Graph

[*]Graph: Select the graph location.
[*]Size: Select the graph size.
[*]Width: Select the graph width.
[*]Height: Select the height of the graph.

🔹 Style

[*] Colors: Select a color map: Viridis, Plasma, Magma, or Custom.
[*]Custom Cold: Select a custom color for cold (low values).
[*] Custom Lukewarm: Select a custom color for lukewarm (medium values).
[*] Custom Hot: Select a custom color for hot (high values).

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator('Peak Trading Activity Graphs [LuxAlgo]','LuxAlgo - PTAG', overlay = true)
//---------------------------------------------------------------------------------------------------------------------}
//CONSTANTS & STRINGS & INPUTS
//---------------------------------------------------------------------------------------------------------------------{
GREEN                   = #089981
RED                     = #F23645
YELLOW                  = #F2E805
DATA                    = #DBDBDB
BACKGROUND              = #161616
BORDERS                 = #2E2E2E
ORANGE                  = #FF5D00
ORANGE_LIGHT            = #FEF1E8

COLD_VIRIDIS            = #400A53
LUKEWARM_VIRIDIS        = #408E8B
HOT_VIRIDIS             = #F8E650

COLD_PLASMA             = #110A81
LUKEWARM_PLASMA         = #B8487D
HOT_PLASMA              = #F1F455

COLD_MAGMA              = #000005
LUKEWARM_MAGMA          = #9D3B7A
HOT_MAGMA               = #FCF7BE

VIRIDIS                 = 'Viridis'
PLASMA                  = 'Plasma'
MAGMA                   = 'Magma'
CUSTOM                  = 'Custom'

TOP_RIGHT               = 'Top Right'
BOTTOM_RIGHT            = 'Bottom Right'
BOTTOM_LEFT             = 'Bottom Left'

TINY                    = 'Tiny'
SMALL                   = 'Small'
NORMAL                  = 'Normal'
LARGE                   = 'Large'
HUGE                    = 'Huge'

VOLUME                  = 'Volume'
VOLATILITY              = 'Volatility'

DAYOFWEEK               = 'Days of Week'
DAYOFMONTH              = 'Days of Month'
MONTH                   = 'Months'
HOURS                   = 'Hours'

DASHBOARD_GROUP         = 'Graph'
STYLE_GROUP             = 'Style'

deltaTooltip            = 'Display the difference between the medians as a percentage. The smaller median is 0, and the larger median is 100. Enabling this feature highlights the differences between values.'
dashboardPositionTooltip= 'Select the graph location.'
dashboardSizeTooltip    = 'Select the graph text size.'
dashboardWidthTooltip   = 'Select the graph width.'
dashboardHeightTooltip  = 'Select the graph height.'

baseDataInput           = input.string( VOLUME,     'Data',     options = [VOLATILITY,VOLUME])
periodInput             = input.string( DAYOFMONTH, 'Period',   options = [MONTH,DAYOFMONTH,DAYOFWEEK,HOURS])
deltaInput              = input.bool(   false,      'Display Delta Between Medians', tooltip = deltaTooltip)

dashboardPositionInput  = input.string( TOP_RIGHT,  'Position', group = DASHBOARD_GROUP, tooltip = dashboardPositionTooltip ,   options = [TOP_RIGHT,BOTTOM_RIGHT,BOTTOM_LEFT])
dashboardSizeInput      = input.string( SMALL,      'Size',     group = DASHBOARD_GROUP, tooltip = dashboardSizeTooltip,        options = [TINY,SMALL,NORMAL,LARGE,HUGE])
dashboardWidthInput     = input.float(  1.0,        'Width',    group = DASHBOARD_GROUP, tooltip = dashboardWidthTooltip ,      minval = 1, step = 0.25)
dashboardHeightInput    = input.float(  1.0,        'Height',   group = DASHBOARD_GROUP, tooltip = dashboardHeightTooltip,      minval = 1, step = 0.25)

colormapInput           = input.string( VIRIDIS,    'Colors',           group = STYLE_GROUP,    options = [VIRIDIS,PLASMA,MAGMA,CUSTOM])
coldColorInput          = input.color(  RED,        'Custom Cold',      group = STYLE_GROUP)
lukewarmColorInput      = input.color(  YELLOW,     'Custom Lukewarm',  group = STYLE_GROUP)
hotColorInput           = input.color(  GREEN,      'Custom Hot',       group = STYLE_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
//DATA STRUCTURES & VARIABLES
//---------------------------------------------------------------------------------------------------------------------{
type data
    array<float> values
    string tag = ''

var array<data> fullMonth = array.from(data.new(array.new<float>()),
     data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),
     data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),
     data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),
     data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),
     data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),
     data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()),data.new(array.new<float>()))

var array<data> fullWeek = syminfo.type == 'crypto' ? array.from(
     data.new(array.new<float>(),'SUN'),
     data.new(array.new<float>(),'MON'),
     data.new(array.new<float>(),'TUE'),
     data.new(array.new<float>(),'WED'),
     data.new(array.new<float>(),'THU'),
     data.new(array.new<float>(),'FRI'),
     data.new(array.new<float>(),'SAT')) : array.from(
     data.new(array.new<float>(),'MON'),
     data.new(array.new<float>(),'TUE'),
     data.new(array.new<float>(),'WED'),
     data.new(array.new<float>(),'THU'),
     data.new(array.new<float>(),'FRI'))

var array<data> fullYear = array.from(
     data.new(array.new<float>(),'JAN'),
     data.new(array.new<float>(),'FEB'),
     data.new(array.new<float>(),'MAR'),
     data.new(array.new<float>(),'APR'),
     data.new(array.new<float>(),'MAY'),
     data.new(array.new<float>(),'JUN'),
     data.new(array.new<float>(),'JUL'),
     data.new(array.new<float>(),'AUG'),
     data.new(array.new<float>(),'SEP'),
     data.new(array.new<float>(),'OCT'),
     data.new(array.new<float>(),'NOV'),
     data.new(array.new<float>(),'DEC'))

var array<data> fullDay = array.from(
     data.new(array.new<float>(),'0'),
     data.new(array.new<float>(),'1'),
     data.new(array.new<float>(),'2'),
     data.new(array.new<float>(),'3'),
     data.new(array.new<float>(),'4'),
     data.new(array.new<float>(),'5'),
     data.new(array.new<float>(),'6'),
     data.new(array.new<float>(),'7'),
     data.new(array.new<float>(),'8'),
     data.new(array.new<float>(),'9'),
     data.new(array.new<float>(),'10'),
     data.new(array.new<float>(),'11'),
     data.new(array.new<float>(),'12'),
     data.new(array.new<float>(),'13'),
     data.new(array.new<float>(),'14'),
     data.new(array.new<float>(),'15'),
     data.new(array.new<float>(),'16'),
     data.new(array.new<float>(),'17'),
     data.new(array.new<float>(),'18'),
     data.new(array.new<float>(),'19'),
     data.new(array.new<float>(),'20'),
     data.new(array.new<float>(),'21'),
     data.new(array.new<float>(),'22'),
     data.new(array.new<float>(),'23'))

parsedDayofweek     = dayofweek(time_tradingday)
parsedDayofmonth    = syminfo.type == 'crypto' ? dayofmonth : dayofmonth(time_close)
parsedMonth         = syminfo.type == 'crypto' ? month      : month(time_close)

var parsedDashboardPosition = switch dashboardPositionInput
    TOP_RIGHT       => position.top_right
    BOTTOM_RIGHT    => position.bottom_right
    BOTTOM_LEFT     => position.bottom_left

var parsedDashboardSize     = switch dashboardSizeInput
    TINY            => size.tiny
    SMALL           => size.small
    NORMAL          => size.normal
    LARGE           => size.large
    HUGE            => size.huge

var int optimalTimeframe    = switch periodInput
    DAYOFWEEK   => timeframe.in_seconds('1D')
    DAYOFMONTH  => timeframe.in_seconds('1D')
    MONTH       => timeframe.in_seconds('1M')
    HOURS       => timeframe.in_seconds('60')

[cold,lukewarm,hot] = switch colormapInput
    VIRIDIS => [COLD_VIRIDIS,LUKEWARM_VIRIDIS,HOT_VIRIDIS]
    PLASMA  => [COLD_PLASMA,LUKEWARM_PLASMA,HOT_VIRIDIS]
    MAGMA   => [COLD_MAGMA,LUKEWARM_MAGMA,HOT_MAGMA]
    CUSTOM  => [coldColorInput,lukewarmColorInput,hotColorInput]

//---------------------------------------------------------------------------------------------------------------------}
//USER-DEFINED FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------{
error() =>
    var table t_able= table.new(position.top_center,1,1
     , bgcolor      = ORANGE_LIGHT
     , border_color = ORANGE
     , border_width = 1
     , frame_color  = ORANGE
     , frame_width  = 1)

    t_able.cell(0,0,'⚠ Warning: The tool will not display the dashboard on higher timeframes.\nPlease select a chart timeframe that is equal to or lower than the period parameter in the settings panel.',text_color = ORANGE, text_size = 0)

gatherDaysOfWeek(float output) =>    
    [dailyData,currentDay] = request.security(syminfo.tickerid, '1D', [output,parsedDayofweek])
    data current = fullWeek.get(currentDay - 1)
    if not na(current)
        current.values.push(nz(dailyData))    

gatherMonths(float output) =>
    [montlhyData,currentMonth] = request.security(syminfo.tickerid, '1M', [output,parsedMonth])
    data current = fullYear.get(currentMonth - 1)
    if not na(current)
        current.values.push(nz(montlhyData))    

gatherDayOfMonth(float output) =>
    [dailyData,dayOfMonth] = request.security(syminfo.tickerid, '1D', [output,parsedDayofmonth])
    data current = fullMonth.get(dayOfMonth - 1)
    if not na(current)
        current.values.push(nz(dailyData))    

gatherHours(float output) =>
    [hourlyData,currentHour] = request.security(syminfo.tickerid, '60', [output,hour])
    data current = fullDay.get(currentHour)
    if not na(current)
        current.values.push(nz(hourlyData))    
         
gatherData() =>
    float output = baseDataInput == VOLUME ? volume : ta.tr
    switch periodInput
        DAYOFWEEK   => gatherDaysOfWeek(output)
        DAYOFMONTH  => gatherDayOfMonth(output)
        MONTH       => gatherMonths(output)
        HOURS       => gatherHours(output)

cell(table t_able, int column, int row, string data, color = #FFFFFF, align = text.align_center, color background = na, float height = 0) => t_able.cell(column,row,data,text_color = color, text_size = parsedDashboardSize, text_halign = align, bgcolor = background, height = height)

divider(table t_able, int row, int column) =>    
    string rowDivider = '━━━━━━━━━━━'
    t_able.merge_cells(0,row,column,row)    
    cell(t_able,0,row,rowDivider,align = text.align_center, height = 0.5*dashboardHeightInput, color = DATA)

displayColumns(array<data> fullData) =>
    var table t_able    = table.new(parsedDashboardPosition,fullData.size()*2 + 1,104,
        bgcolor          = BACKGROUND,
        border_width     = 0,
        frame_color      = BORDERS,
        frame_width      = 1,
        force_overlay    = false)

    var array<float> parsedData = array.new<float>()   

    for [index,eachDataPoint] in fullData
        parsedData.push(eachDataPoint.values.median())

    t_able.merge_cells(0,0,fullData.size()*2 - 2,0)
    t_able.merge_cells(0,1,fullData.size()*2 - 2,1)    
    string min = str.tostring(parsedData.min(),baseDataInput == VOLATILITY ? format.mintick : format.volume)
    string max = str.tostring(parsedData.max(),baseDataInput == VOLATILITY ? format.mintick : format.volume)

    string periodTag = switch periodInput
        MONTH   => 'Monthly'
        HOURS   => 'Hourly'
        => 'Daily'
    string header = deltaInput ? '(Delta)' : ''
    cell(t_able,0,0,str.format('{0} Median {1} {2}\nMin: {3}  Max: {4}',periodTag,baseDataInput,header,min,max),align = text.align_center, color = DATA)

    int column = 0
    for [index,eachDataPoint] in parsedData
        if index > 0
            column += 2

        t_able.merge_cells(column,2,column,103)            
        t_able.cell_set_height(column,2,0.2*dashboardHeightInput)

        float scale = deltaInput ? (eachDataPoint-parsedData.min())/parsedData.range() : eachDataPoint/parsedData.max()
        int value = math.max(1,math.floor(100*scale))        
        color customColor = value >= 50 ? color.from_gradient(value,50,100,color.new(lukewarm,0),color.new(hot,0)) : color.from_gradient(value,1,50,color.new(cold,0),color.new(lukewarm,0))

        int topRow = 101-value
        for row = 1 to 100
            t_able.cell(column + 1,row + 1,height = 0.1*dashboardHeightInput)
            if row >= topRow
                t_able.cell_set_bgcolor(column + 1,row + 1,customColor)
        
        t_able.cell(column + 1,103,fullData.get(index).tag,width = dashboardWidthInput, text_color = DATA, text_size = parsedDashboardSize)           
        
        if index == (parsedData.size() - 1)
            t_able.merge_cells(column + 2,2,column + 2,103)            
            t_able.cell_set_height(column + 2,2,0.2*dashboardHeightInput)

displayMonth() =>
    var table t_able    = table.new(parsedDashboardPosition,9,7,
     bgcolor          = BACKGROUND,
     border_width     = 0,
     frame_color      = BORDERS,
     frame_width      = 1,
     force_overlay    = false)

    var array<float> parsedData = array.new<float>()

    for [index,eachDataPoint] in fullMonth
        parsedData.push(eachDataPoint.values.median())

    t_able.merge_cells(0,0,6,0)
    string min = str.tostring(parsedData.min(),baseDataInput == VOLATILITY ? format.mintick : format.volume)
    string max = str.tostring(parsedData.max(),baseDataInput == VOLATILITY ? format.mintick : format.volume)

    string periodTag = switch periodInput
        MONTH   => 'Monthly'
        HOURS   => 'Hourly'
        => 'Daily'

    string header = deltaInput ? '(Delta)' : ''
    cell(t_able,0,0,str.format('{0} Median {1} {2}\nMax: {3}\nMin: {4}',periodTag,baseDataInput,header,max,min),align = text.align_center, color = DATA)

    divider(t_able,1,6)
        
    int row = 2
    array<int> column0 = array.from(1,8,15,22,29)
    array<int> column1 = array.from(2,9,16,23,30)
    array<int> column2 = array.from(3,10,17,24,31)
    array<int> column3 = array.from(4,11,18,25)
    array<int> column4 = array.from(5,12,19,26)
    array<int> column5 = array.from(6,13,20,27)
    array<int> column6 = array.from(7,14,21,28)

    bool nextRow = false

    for [index,eachDataPoint] in parsedData
        int column = switch
            column0.includes(index + 1) => 0
            column1.includes(index + 1) => 1
            column2.includes(index + 1) => 2
            column3.includes(index + 1) => 3
            column4.includes(index + 1) => 4
            column5.includes(index + 1) => 5
            column6.includes(index + 1) => 6            

        if nextRow
            row += 1
            nextRow := false

        if (index + 1) % 7 == 0 and not nextRow
            nextRow := true         

        float scale = deltaInput ? (eachDataPoint-parsedData.min())/parsedData.range() : eachDataPoint/parsedData.max()
        int value = math.max(1,math.floor(100*scale))        
        color customColor = value >= 50 ? color.from_gradient(value,50,100,color.new(lukewarm,0),color.new(hot,0)) : color.from_gradient(value,1,50,color.new(cold,0),color.new(lukewarm,0))
        cell(t_able,column,row,str.tostring(index + 1),background = customColor)   

displayData() =>
    switch periodInput
        DAYOFWEEK   => displayColumns(fullWeek)
        DAYOFMONTH  => displayMonth()
        MONTH       => displayColumns(fullYear)
        HOURS       => displayColumns(fullDay)

//---------------------------------------------------------------------------------------------------------------------}
//MUTABLE VARIABLES & EXECUTION
//---------------------------------------------------------------------------------------------------------------------{
if timeframe.in_seconds() > optimalTimeframe
    error()
else
    gatherData()

    if barstate.islastconfirmedhistory
        displayData()

//---------------------------------------------------------------------------------------------------------------------}
````
