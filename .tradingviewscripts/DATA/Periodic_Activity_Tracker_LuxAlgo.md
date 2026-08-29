<!-- tradingview-pine-id: PUB;fbc09c5ea23f46988d3a2176b9380433 -->
<!-- tradingviewscripts-format: 1 -->
# Periodic Activity Tracker [LuxAlgo]

Source: https://www.tradingview.com/script/2GaipHlg-Periodic-Activity-Tracker-LuxAlgo/

## Description

The Periodic Activity Tracker tool periodically tracks the cumulative buy and sell volume in a user-defined period and draws the corresponding matching bars and volume delta for each period.

Users can select a predefined aggregation period from the following options: Hourly, Daily, Weekly, and Monthly.

🔶 USAGE

[image]https://www.tradingview.com/x/mfaioiDE/[/image]

This tool provides a simple and clear way of analyzing volumes for each aggregated period and is made up of the following elements:

[*] Buy and sell volumes by period as red and green lines with color gradient area
[*] Delta (difference) between buy & sell volume for each period
[*] Buy & sell volume bars for each period
[*] Separator between lines and bars, and period tags below each pair of bars for ease of reading

On the chart above we can see all the elements displayed, the volume level on the lines perfectly matches the volume level on the bars for each period.

In this case, the tool has the default settings so the anchor period is set to Daily and we can see how the period tag (each day of the week) is displayed below each pair of bars.

Users can disable the delta display and adjust the bar size.

🔹 Reading The Tool

[image]https://www.tradingview.com/x/wkk9gT1q/[/image]

In trading, assessing the strength of the bulls (buyers) and bears (sellers) is key to understanding the current trading environment. Which side, if any, has the upper hand? To answer this question, some traders look at volume in relation to price.

This tool provides you with a view of buy volume versus sell volume, allowing you to compare both sides of the market.

As with any volume tool, the key is to understand when the forces of the two groups are balanced or unbalanced.

As we can observe on the chart: 

[*] NOV '23: Buy volume greater than sell volume, both moving up close together, flat delta. We can see that the price is in range.
[*] DEC '23: Buy volume bigger than Sell volume, both moving up but with a bigger difference, bigger delta than last month but still flat. We can see the price in the range above last month's range.
[*] JAN '24: Buy and sell volume tied together, no delta whatsoever. We can see the price in range but testing above and below last month's range.
[*] FEB '24: Buy volume explodes higher and sell volume cannot keep up, big growing delta. Price explodes higher above last month's range.

Traders need to understand that there is always an equal number of buyers and sellers in a liquid market, the quality here is how aggressive or passive they are. Who is 'attacking' and who is 'defending', who is using market orders to move prices, and who is using limit orders waiting to be filled?

This tool gives you the following information:

[*] Lines: if the top line is green, the buyers are attacking, if it is red, the sellers are attacking.
[*] Delta: represents the difference in their strength, if it is above 0 the buyers are stronger, if it is below 0 the sellers are stronger. 
[*] Bars: help you to see the difference in strength between buyers and sellers for each period at a glance.

🔹 Anchor Period

[image]https://www.tradingview.com/x/Ll8DmMcX/[/image]

By default, the tool is set to Hourly. However, users can select from a number of predefined time periods.

Depending on the user's selection, the bars are displayed as follows:

[*] Hourly	: hours of the current day
[*] Daily	: days of the current week
[*] Weekly	: weeks of the current month
[*] Monthly	: months of the current year

On the chart above we can see the four periods displayed, starting at the top left and moving clockwise we have hourly, daily, weekly, and monthly.

🔶 DETAILS

🔹 Chart TimeFrame

The chart timeframe has a direct impact on the visualization of the tool, and the user should select a chart timeframe that is compatible with the Anchor period in the tool's settings panel.

For the chart timeframe to be compatible it must be less than the Anchor period parameter. If the user selects an incompatible chart timeframe, a warning message will be displayed.

As a rule of thumb, the smaller the chart timeframe, the more data the tool will collect, returning indications for longer-term price variations.

These are the recommended chart timeframes for each period:

[*] Hourly	: 5m charts or lower
[*] Daily	: 1H charts or lower
[*] Weekly	: 4H charts or lower
[*] Monthly	: 1D charts or lower

🔹 Warnings

[image]https://www.tradingview.com/x/AWF2FaUm/[/image]

This chart shows both types of warnings the user may receive

At the top, we can see the warning that is given when the 'Bar Width' parameter exceeds the allowed value.

At the bottom is the incompatible chart timeframe warning, which prompts the user to select a smaller chart timeframe or a larger "Anchor Period" parameter.

🔶 SETTINGS

🔹 Data Gathering

[*] Anchor period: Time period representing each bar: hours of the day, days of the week, weeks of the month, and months of the year. The timeframe of the chart must be less than this parameter, otherwise a warning will be displayed.

🔹 Style

[*] Bars width: Size of each bar, there is a maximum limit so a warning will be displayed if it is reached.
[*] Volume color
[*] Delta: Enable/Disable Delta Area Display

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator('Periodic Activity Tracker [LuxAlgo]', 'LuxAlgo - Periodic Activity Tracker')
//---------------------------------------------------------------------------------------------------------------------}
//CONSTANTS & STRINGS & INPUTS
//---------------------------------------------------------------------------------------------------------------------{
HOURLY                  = 'HOURLY'
DAILY                   = 'DAILY'
WEEKLY                  = 'WEEKLY'
MONTHLY                 = 'MONTHLY'

GREEN                   = #089981
RED                     = #F23645
TEAL                    = color.new(color.teal, 80)
GRAY                    = color.new(color.gray, 80)

DATA_GROUP              = 'Data gathering'
STYLE_GROUP             = 'Style'

anchoringPeriodTooltip  = 'Time period representing each bar: hours of the day, days of the week, weeks of the month and months of the year. The timeframe of the chart must be less than this parameter, otherwise a warning will be displayed.'
barWidthTooltip         = 'Size of each bar, there is a maximum limit so a warning will be displayed if it is reached.'
showDeltaTooltip        = 'Enable/Disable Delta Area Display.'

anchoringPeriodInput    = input.string( DAILY, 'Anchor period',    tooltip = anchoringPeriodTooltip,   group = DATA_GROUP,     options = [HOURLY,DAILY,WEEKLY,MONTHLY])
barWidthInput           = input.int(    2,      'Bar width',        tooltip = barWidthTooltip,          group = STYLE_GROUP,    minval  = 2)
buyColorInput           = input.color(  GREEN,  'Volume color',     tooltip = '',                       group = STYLE_GROUP,    inline = '1')
sellColorInput          = input.color(  RED,    '',                 tooltip = '',                       group = STYLE_GROUP,    inline = '1')
showDeltaInput          = input.bool(   true,   'Delta  ',          tooltip = showDeltaTooltip,         group = STYLE_GROUP,    inline = '2')
positiveDeltaColorInput = input.color(  TEAL,   '',                 tooltip = '',                       group = STYLE_GROUP,    inline = '2')
negativeDeltaColorInput = input.color(  GRAY,   '',                 tooltip = '',                       group = STYLE_GROUP,    inline = '2')
 
//---------------------------------------------------------------------------------------------------------------------}
//DATA STRUCTURES & VARIABLES
//---------------------------------------------------------------------------------------------------------------------{
// @variable    Get chart timeframe in minutes to compare to next variable
var chartTimeframeInMinutes = timeframe.in_seconds() / 60

// @variable    Check if the user has selected an incorrect chart timeframe match for the 'Anchor period' parameter
var bool wrongTimeframe     = switch anchoringPeriodInput
    HOURLY      =>  chartTimeframeInMinutes >= 60
    DAILY       =>  chartTimeframeInMinutes >= 60 * 24
    WEEKLY      =>  chartTimeframeInMinutes >= 60 * 24 * 7 
    MONTHLY     =>  chartTimeframeInMinutes >= 60 * 24 * 30

// @type        Storage UDT for each period bar
// @field buy   (float) Buy volume
// @field sell  (float) Sell volume
// @field tag   (string) Tag identifying the bar, such as MON for Monday or JAN for January
type barVolume
    float buy   = 0
    float sell  = 0
    string tag  = ''

// @variable    Storage array for `barVolume` UDTs
var array<barVolume> bars = array.new<barVolume>()

//---------------------------------------------------------------------------------------------------------------------}
//USER-DEFINED FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------{
// @function        Draw a table with custom text
// @param message   (string) Text to display
// @returns         void
showInfoPanel(string message) =>
    var table t_able = table.new(position.top_center, 1, 1)
    table.cell(t_able, 0, 0, message, text_color = chart.fg_color)

// @function        Get day of week as text from `time`
// @param bar_time (int) Milliseconds from 1970
// @param isCrypto (bool) Check if the ticker is crypto
// @returns         string
getDayofweek(int bar_time, bool isCrypto = false) =>
    if isCrypto
        switch dayofweek(bar_time)
            1   => 'SUN'
            2   => 'MON'
            3   => 'TUE'
            4   => 'WED'
            5   => 'THU'
            6   => 'FRI'
            7   => 'SAT'
    else
        switch dayofweek(bar_time)
            1   => 'MON'
            2   => 'TUE'
            3   => 'WED'
            4   => 'THU'
            5   => 'FRI'

// @function        Get week of the month as string
// @returns         string
getWeek() => str.tostring(array.size(bars) + 1)

// @function        Get month as string
// @param           (int)
// @returns         string
getMonth(int bar_time) =>    
    switch month(bar_time)
        1   => 'JAN'
        2   => 'FEB'
        3   => 'MAR'
        4   => 'APR'
        5   => 'MAY'
        6   => 'JUN'
        7   => 'JUL'
        8   => 'AUG'
        9   => 'SEP'
        10  => 'OCT'
        11  => 'NOV'
        12  => 'DEC'

// @function        Volume of bullish candle
// @returns         float
buyVolume() => close > open ? volume : 0

// @function        Volume of bearish candle
// @returns         float
sellVolume() => close < open ? volume : 0

// @function        Get tag parameter for bar as hour of day, day of week, week of month or month of year
// @returns         string
barTag() =>
    switch anchoringPeriodInput
        HOURLY      =>  str.tostring(hour(time))
        DAILY       =>  getDayofweek(time_tradingday, syminfo.type == 'crypto')
        WEEKLY      =>  getWeek()
        MONTHLY     =>  getMonth(time_close)

// @function        Create a new `barVolume` and store it in the array
// @returns         void
createNewBar() => array.push(bars, barVolume.new(buyVolume(), sellVolume(), barTag()))

// @function        Update volume on last `barVolume` object
// @returns         float
updateLastBar() =>
    size = array.size(bars)
    if size > 0
        barVolume lastBar   = array.get(bars, size-1)
        lastBar.buy         += buyVolume()
        lastBar.sell        += sellVolume()

// @function        Get buy and sell volume values from the last `barVolume` object
// @returns         float tuple
getLastValues() =>
    size = array.size(bars)
    if size > 0
        barVolume lastBar = array.get(bars,size-1)
        [lastBar.buy,lastBar.sell]
    else
        [na,na]

// @function        Draw two boxes and a label for each `barVolume` object (sell volume, buy volume and bar tag)
// @returns         last label ID
plotBars() =>    
    for eachBox in box.all
        box.delete(eachBox)
    for eachLabel in label.all
        label.delete(eachLabel)
    
    // PineScript has a limit of 500 bars beyond last_bar_index for drawings using xloc.bar_index
    // So we get the rightmost bar_index and then check if it is less than or equal to 500.
    rightMostIndex = 4 * barWidthInput + (array.size(bars) - 1) * (3 * barWidthInput)

    // We are within the parameters, so we continue the execution and draw the boxes and labels.
    if rightMostIndex <= 500

        for [index,eachBar] in bars
                        
            leftIndex           = 2 * barWidthInput + index * (3 * barWidthInput)

            topLeftPoint1       = chart.point.new(na,   last_bar_index + leftIndex,                             eachBar.sell)
            bottomRightPoint1   = chart.point.new(na,   last_bar_index + leftIndex + barWidthInput,             0)

            topLeftPoint2       = chart.point.new(na,   last_bar_index + leftIndex + barWidthInput,             eachBar.buy)
            bottomRightPoint2   = chart.point.new(na,   last_bar_index + leftIndex + barWidthInput * 2,         0)

            labelPoint          = chart.point.new(na,   last_bar_index + leftIndex + barWidthInput,             0)

            box.new(    topLeftPoint1,  bottomRightPoint1,  border_width    = 0,            bgcolor     = sellColorInput)
            box.new(    topLeftPoint2,  bottomRightPoint2,  border_width    = 0,            bgcolor     = buyColorInput)
            label.new(  labelPoint,     eachBar.tag,        color           = color(na),    textcolor   = chart.fg_color,   style = label.style_label_up)

    // Instead of having the runtime environment throw an error, we display a custom message.
    else
        showInfoPanel('Oops... The `Bar width` parameter is much too large.\nChoose a smaller parameter.')
        na

// @function        Update the height of the last two boxes drawn with volume values from the last `barVolume` object
// @returns         void
updateLastPlottedBar() =>
    [buyVolume,sellVolume] = getLastValues()
    
    size    = array.size(box.all)
    if size >= 2

        box lastBuyVolumeBar    = array.get(box.all, size - 1)
        box lastSellVolumeBar   = array.get(box.all, size - 2)
        
        box.set_top(    lastSellVolumeBar,  sellVolume)
        box.set_top(    lastBuyVolumeBar,   buyVolume)

//---------------------------------------------------------------------------------------------------------------------}
//MUTABLE VARIABLES & EXECUTION
//---------------------------------------------------------------------------------------------------------------------{
// @variable        Check if the current bar is the start of a new period (aka `barVolume` object)
bool newPeriod = switch anchoringPeriodInput
    HOURLY      => ta.change(hour)          != 0 
    DAILY       => ta.change(dayofmonth)    != 0 
    WEEKLY      => ta.change(weekofyear)    != 0 
    MONTHLY     => ta.change(month)         != 0 

// @variable        Check if the current bar is the start of a new set of `barVolume` objects
bool newBarSet = switch anchoringPeriodInput
    HOURLY      => ta.change(dayofmonth)    != 0 
    DAILY       => ta.change(weekofyear)    != 0
    WEEKLY      => ta.change(month)         != 0
    MONTHLY     => ta.change(month)         != 0 and month == 1

// If the user has selected a chart timeframe equal to or greater than the 'Anchor Period' parameter, a message will be displayed.
if wrongTimeframe
    showInfoPanel('Oops... The chart timeframe must be smaller than the `Anchor period` parameter.\nSelect a smaller chart timeframe or a larger `Anchor period` parameter.')

// If the chart timeframe is a valid one, we will continue the execution.
else    
    if newPeriod
        createNewBar()
    else    
        updateLastBar()

    if newBarSet
        array.clear(bars)
        
        // This createNewBar() call is here to store a new weekly bar at the start of each new month, for the rest of the periods it does not matter because they are the same: 
        // each new day is the start of a new hour, each new week is the start of a new day, each new year is the start of a new month, but each new month is not the start of a new week.        
        createNewBar()
    
    if barstate.islastconfirmedhistory or (barstate.isrealtime and barstate.isconfirmed)
        plotBars()
    if barstate.isrealtime
        updateLastPlottedBar()

// We get current volume values to plot as lines
[buyVolume,sellVolume] = getLastValues()

// We plot the buy and sell volumes with a break effect between the periods provided by setting the colour to 'na' on the first bar of a new period or a new set of periods (bars).
buyVolumePlot   = plot(not wrongTimeframe ? buyVolume  : na, '', newBarSet or newPeriod ? color(na) : buyColorInput)
sellVolumePlot  = plot(not wrongTimeframe ? sellVolume : na, '', newBarSet or newPeriod ? color(na) : sellColorInput)

// Gradient fill between the two plots
fill(buyVolumePlot, sellVolumePlot, math.max(buyVolume, sellVolume), math.min(buyVolume, sellVolume), newBarSet or newPeriod ? color(na) : buyVolume > sellVolume ? color.new(GREEN, 50) : color.new(RED, 50), color.new(chart.bg_color, 100))

// We plot the delta between the volumes as an area.
plot(showDeltaInput ? (buyVolume - sellVolume) / 2 : na, style = plot.style_area, color = newBarSet or newPeriod ? color(na) : buyVolume > sellVolume ? positiveDeltaColorInput : negativeDeltaColorInput)

// Separation between plots and bars for real-time execution
bgcolor(wrongTimeframe ? na : barstate.islast and not barstate.isconfirmed ? chart.fg_color : na, barWidthInput - 1)

//---------------------------------------------------------------------------------------------------------------------}
````
