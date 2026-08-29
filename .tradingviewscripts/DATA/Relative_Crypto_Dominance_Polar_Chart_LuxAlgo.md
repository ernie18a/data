<!-- tradingview-pine-id: PUB;da5bbee3abdc4e36949038ed7a9aa7f6 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Crypto Dominance Polar Chart [LuxAlgo]

Source: https://www.tradingview.com/script/C8RarGoe-Relative-Crypto-Dominance-Polar-Chart-LuxAlgo/

## Description

The Relative Crypto Dominance Polar Chart tool allows traders to compare the relative dominance of up to ten different tickers in the form of a polar area chart, we define relative dominance as a combination between traded dollar volume and volatility, making it very easy to compare them at a glance.

🔶 USAGE

[image]https://www.tradingview.com/x/BznjFOYM/[/image]

The use is quite simple, traders just have to load the indicator on the chart, and the graph showing the relative dominance will appear.

The 10 tickers loaded by default are the major cryptocurrencies by market cap, but traders can select any ticker in the settings panel.

[image]https://www.tradingview.com/x/c0oORcFO/[/image]

Each area represents dominance as volatility (radius) by dollar volume (arc length); a larger area means greater dominance on that ticker.

🔹 Choosing Period

[image]https://www.tradingview.com/x/VqbP2oBa/[/image]

The tool supports up to five different periods

[*]Hourly
[*]Daily
[*]Weekly
[*]Monthly
[*]Yearly

By default, the tool period is set on auto mode, which means that the tool will choose the period depending on the chart timeframe

[*]timeframes up to 2m:  Hourly
[*]timeframes up to 15m: Daily
[*]timeframes up to 1H:  Weekly
[*]timeframes up to 4H:  Monthly
[*]larger timeframes:    Yearly

🔹 Sorting & Sizing

[image]https://www.tradingview.com/x/s1QLnmfn/[/image]

Traders can sort the graph areas by volatility (radius of each area) in ascending or descending order; by default, the tickers are sorted as they are in the settings panel.

The tool also allows you to adjust the width of the chart on a percentage basis, i.e., at 100% size, all the available width is used; if the graph is too wide, just decrease the graph size parameter in the settings panel.

🔹 Set your own style

[image]https://www.tradingview.com/x/h6eWiMwi/[/image]

The tool allows great customization from the settings panel, traders can enable/disable most of the components, and add a very nice touch with curved lines enabled for displaying the areas with a petal-like effect.

🔶 SETTINGS

[*]Period: Select up to 5 different time periods from Hourly, Daily, Weekly, Monthly and Yearly. Enable/disable Auto mode.
[*]Tickers: Enable/disable and select tickers and colors

🔹 Style

[*]Graph Order: Select sort order
[*]Graph Size: Select percentage of width used
[*]Labels Size: Select size for ticker labels
[*]Show Percent: Show dominance in % under each ticker
[*]Curved Lines: Enable/disable petal-like effect for each area
[*]Show Title: Enable/disable graph title
[*]Show Mean: Enable/disable volatility average and select color

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator('Relative Crypto Dominance Polar Chart [LuxAlgo]','LuxAlgo - Relative Crypto Dominance Polar Chart', max_labels_count = 11, max_bars_back = 5000)
//---------------------------------------------------------------------------------------------------------------------}
//CONSTANTS & STRINGS & INPUTS
//---------------------------------------------------------------------------------------------------------------------{
HOURLY              = 'Hourly'
DAILY               = 'Daily'
WEEKLY              = 'Weekly'
MONTHLY             = 'Monthly'
YEARLY              = 'Yearly'

NONE                = 'None'
ASCENDING           = 'Ascending'
DESCENDING          = 'Descending'

TINY                = 'Tiny'
SMALL               = 'Small'
NORMAL              = 'Normal'
LARGE               = 'Large'
HUGE                = 'Huge'

EM_SPACE            = ' '
SPACING             = EM_SPACE+EM_SPACE+EM_SPACE+EM_SPACE+EM_SPACE+EM_SPACE+EM_SPACE+EM_SPACE
TICKER_GROUP        = SPACING+'TICKER'+SPACING+'COLOR'
STYLE_GROUP         = 'STYLE'

periodInput         = input.string( YEARLY,         'Period',   inline = 'period', options=[HOURLY,DAILY,WEEKLY,MONTHLY,YEARLY])
autoIPeriodInput    = input.bool(   true,           'Auto',     inline = 'period')

showTicker00Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '00')
ticker00Input       = input.symbol( 'BTCUSDT',      '', group = TICKER_GROUP, inline = '00')
ticker00ColorInput  = input(        color.yellow, '', group = TICKER_GROUP, inline = '00')

showTicker01Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '01')
ticker01Input       = input.symbol( 'ETHUSDT',      '', group = TICKER_GROUP, inline = '01')
ticker01ColorInput  = input(        color.aqua,   '', group = TICKER_GROUP, inline = '01')

showTicker02Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '02')
ticker02Input       = input.symbol( 'XRPUSDT',      '', group = TICKER_GROUP, inline = '02')
ticker02ColorInput  = input(        color.blue,   '', group = TICKER_GROUP, inline = '02')

showTicker03Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '03')
ticker03Input       = input.symbol( 'BNBUSDT',      '', group = TICKER_GROUP, inline = '03')
ticker03ColorInput  = input(        color.fuchsia,'', group = TICKER_GROUP, inline = '03')

showTicker04Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '04')
ticker04Input       = input.symbol( 'SOLUSDT',      '', group = TICKER_GROUP, inline = '04')
ticker04ColorInput  = input(        color.green,  '', group = TICKER_GROUP, inline = '04')

showTicker05Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '05')
ticker05Input       = input.symbol( 'DOGEUSDT',     '', group = TICKER_GROUP, inline = '05')
ticker05ColorInput  = input(        color.lime,   '', group = TICKER_GROUP, inline = '05')

showTicker06Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '06')
ticker06Input       = input.symbol( 'ADAUSDT',      '', group = TICKER_GROUP, inline = '06')
ticker06ColorInput  = input(        color.maroon, '', group = TICKER_GROUP, inline = '06')

showTicker07Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '07')
ticker07Input       = input.symbol( 'TRXUSDT',      '', group = TICKER_GROUP, inline = '07')
ticker07ColorInput  = input(        color.silver, '', group = TICKER_GROUP, inline = '07')

showTicker08Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '08')
ticker08Input       = input.symbol( 'LINKUSDT',     '', group = TICKER_GROUP, inline = '08')
ticker08ColorInput  = input(        color.olive,  '', group = TICKER_GROUP, inline = '08')

showTicker09Input   = input.bool(   true,           '', group = TICKER_GROUP, inline = '09')
ticker09Input       = input.symbol( 'AVAXUSDT',     '', group = TICKER_GROUP, inline = '09')
ticker09ColorInput  = input(        color.orange, '', group = TICKER_GROUP, inline = '09')

orderInput          = input.string( NONE,   'Graph Order',  group = STYLE_GROUP, options=[NONE,ASCENDING,DESCENDING])
sizeInput           = input.int(    80,     'Graph Size',   group = STYLE_GROUP, minval = 10, maxval = 100) * 0.01
labelSizeInput      = input.string( SMALL,  'Labels Size',  group = STYLE_GROUP, options = [TINY,SMALL,NORMAL,LARGE,HUGE])
percentInput        = input.bool(   true,   'Show Percent', group = STYLE_GROUP)
curvedInput         = input.bool(   false,  'Curved Lines', group = STYLE_GROUP)
showTitleInput      = input(        true,   'Show Title',   group = STYLE_GROUP)
showMeanInput       = input(        true,   'Show Mean',    group = STYLE_GROUP, inline = 'mean')
meanColorInput      = input(color.gray,   '',             group = STYLE_GROUP, inline = 'mean')

//---------------------------------------------------------------------------------------------------------------------}
//DATA STRUCTURES & VARIABLES
//---------------------------------------------------------------------------------------------------------------------{
type ticker
    string      tickerID
    color       c_olor    
    label       l_abel
    string      tag         = ''
    float       cumVol      = na
    float       cumDelta    = na
    polyline    l_ine       = na

var array<ticker> t_ickers      = array.new<ticker>()
array<float> cumulativeVolumes  = array.new<float>()
array<float> cumulativeDeltas   = array.new<float>()
array<float> normalizedVolumes  = array.new<float>()
array<float> normalizedDeltas   = array.new<float>()
var int left_visible_bar_index  = 0
var int right_visible_bar_index = last_bar_index
int visibleWidthInBars          = 0
int circleAnchor                = 0

string parsedPeriod         = switch
    timeframe.in_seconds() <= timeframe.in_seconds('2')     =>  HOURLY
    timeframe.in_seconds() <= timeframe.in_seconds('15')    =>  DAILY
    timeframe.in_seconds() <= timeframe.in_seconds('60')    =>  WEEKLY
    timeframe.in_seconds() <= timeframe.in_seconds('240')   =>  MONTHLY
    =>  YEARLY
	
bool isNewPeriod            = switch (autoIPeriodInput ? parsedPeriod : periodInput)
    HOURLY      => ta.change(hour)              != 0
    DAILY       => ta.change(time_tradingday)   != 0
    WEEKLY      => ta.change(weekofyear)        != 0
    MONTHLY     => ta.change(month)             != 0
    YEARLY      => ta.change(year)              != 0

int millisecondsPerHour = 3600000
int millisecondPerDay   = 86400000

bool executionWindow        = switch (autoIPeriodInput ? parsedPeriod : periodInput)
    HOURLY      => time >= (last_bar_time - millisecondsPerHour)
    DAILY       => time >= (last_bar_time - millisecondsPerHour * 25)
    WEEKLY      => time >= (last_bar_time - millisecondPerDay   * 8)
    MONTHLY     => time >= (last_bar_time - millisecondPerDay   * 32)
    YEARLY      => time >= (last_bar_time - millisecondPerDay   * 366)

var parsedSize = switch labelSizeInput
    TINY            => size.tiny
    SMALL           => size.small
    NORMAL          => size.normal
    LARGE           => size.large
    HUGE            => size.huge

var titleSize = switch labelSizeInput
    TINY            => 13
    SMALL           => 16
    NORMAL          => 18
    LARGE           => 24
    HUGE            => 30

var label title = label.new(na, na, text = (autoIPeriodInput ? parsedPeriod : periodInput)+' Relative Dominance',textcolor = chart.fg_color  ,color = #00000000, size = titleSize, style = label.style_label_down)

addTicker(bool enabled, string tickerID, color c_olor) =>
    if enabled
        t_ickers.push(ticker.new(tickerID,c_olor,label.new(na, na, color = #00000000, size = parsedSize)))

if barstate.isfirst
    addTicker(showTicker00Input,ticker00Input,ticker00ColorInput)
    addTicker(showTicker01Input,ticker01Input,ticker01ColorInput)
    addTicker(showTicker02Input,ticker02Input,ticker02ColorInput)
    addTicker(showTicker03Input,ticker03Input,ticker03ColorInput)
    addTicker(showTicker04Input,ticker04Input,ticker04ColorInput)
    addTicker(showTicker05Input,ticker05Input,ticker05ColorInput)
    addTicker(showTicker06Input,ticker06Input,ticker06ColorInput)
    addTicker(showTicker07Input,ticker07Input,ticker07ColorInput)
    addTicker(showTicker08Input,ticker08Input,ticker08ColorInput)
    addTicker(showTicker09Input,ticker09Input,ticker09ColorInput)

//---------------------------------------------------------------------------------------------------------------------}
//USER-DEFINED FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------{
fetchData() =>
    for eachTicker in t_ickers
        [v_olume,c_lose,o_pen,t_ag,v_alue]  = request.security(eachTicker.tickerID, timeframe.period, [volume, close, open,syminfo.ticker,syminfo.pointvalue])
        eachTicker.tag                      := t_ag
        delta                               = math.abs(c_lose - o_pen) / o_pen

        if isNewPeriod
            eachTicker.cumVol   := v_olume * c_lose * v_alue
            eachTicker.cumDelta := delta
        else
            eachTicker.cumVol   += v_olume * c_lose * v_alue
            eachTicker.cumDelta += delta

        cumulativeVolumes.push(eachTicker.cumVol)
        cumulativeDeltas.push(eachTicker.cumDelta)

normalizeData() =>
    volumeRatio = array.sum(cumulativeVolumes) / 360    
    deltaRatio  = (2 * cumulativeDeltas.max()) / (visibleWidthInBars * sizeInput)

    for eachVolume in cumulativeVolumes
        array.push(normalizedVolumes, eachVolume / volumeRatio)
    
    for eachDelta in cumulativeDeltas
        array.push(normalizedDeltas, eachDelta / deltaRatio)

orderData() =>
    if orderInput != NONE
        parsedOrder             = orderInput == ASCENDING ? order.ascending : order.descending
        normalizedVolumesTmp    = normalizedVolumes.copy()
        t_ickersTmp             = t_ickers.copy()

        normalizedVolumes.clear()
        t_ickers.clear()

        for index in normalizedDeltas.sort_indices(parsedOrder)
            normalizedVolumes.push(normalizedVolumesTmp.get(index))
            t_ickers.push(t_ickersTmp.get(index))        

        normalizedDeltas.sort(parsedOrder)

circleCoordinates(float position, float radius)=>
    x = math.max(math.min(circleAnchor + int(math.sin(math.toradians(position)) * radius), last_bar_index + 500), last_bar_index - 5000)
    y = math.cos(math.toradians(position)) * radius

    [x, y]        

drawCircle() =>
    float cumulativeVolume = 0.
    float totalArea = 0.

    if showTitleInput
        [titleX,titleY] = circleCoordinates(0, normalizedDeltas.max() * 1.01)
        title.set_point(chart.point.new(na,titleX,titleY))    

    for eachTicker in t_ickers
        eachTicker.l_ine.delete()
        if percentInput
            totalArea += eachTicker.cumDelta * eachTicker.cumVol

    for [index, eachVolume] in normalizedVolumes
        ticker currentTicker        = t_ickers.get(index)
        array<chart.point> points   = array.new<chart.point>()
        points.push(chart.point.new(na,circleAnchor,0.))        

        for innerIndex = cumulativeVolume to cumulativeVolume + eachVolume
            [x, y] = circleCoordinates(innerIndex, normalizedDeltas.get(index))
            points.push(chart.point.new(na,x,y))

            if innerIndex > math.avg(cumulativeVolume, cumulativeVolume + eachVolume) and innerIndex - 1 <= math.avg(cumulativeVolume, cumulativeVolume + eachVolume)
                labelStyle = innerIndex < 180 and y > 0 ? label.style_label_lower_left 
                     : innerIndex < 180 and y < 0 ? label.style_label_upper_left
                     : innerIndex > 180 and y > 0 ? label.style_label_lower_right
                     : label.style_label_upper_right

                labelText = currentTicker.tag
                if percentInput
                    labelText := labelText + '\n' + str.tostring((currentTicker.cumDelta*currentTicker.cumVol) / totalArea,'0.00%')
                currentTicker.l_abel.set_xy(x,y)
                currentTicker.l_abel.set_text(labelText)
                currentTicker.l_abel.set_textcolor(currentTicker.c_olor)
                currentTicker.l_abel.set_style(labelStyle)
                
        currentTicker.l_ine := polyline.new(points,curvedInput,true,line_color = currentTicker.c_olor,fill_color = color.new(currentTicker.c_olor,80))        
        cumulativeVolume    += eachVolume

drawMean() =>
    var polyline meanLine = na        
    int     x1 = na
    float   y1 = na
    array<chart.point> averagePoints = array.new<chart.point>()

    radius = array.avg(normalizedDeltas)
    averagePoints.push(chart.point.new(na,x1,y1))
    
    for index = 0 to 360
        [x, y] = circleCoordinates(index, radius)
        averagePoints.push(chart.point.new(na,x,y))

    meanLine.delete()
    meanLine := polyline.new(averagePoints,curvedInput,true,line_color = meanColorInput,fill_color = color.new(meanColorInput,80),line_style = line.style_dashed)
            
//---------------------------------------------------------------------------------------------------------------------}
//MUTABLE VARIABLES & EXECUTION
//---------------------------------------------------------------------------------------------------------------------{
left_visible_bar_index  := time == chart.left_visible_bar_time  ? bar_index : left_visible_bar_index
right_visible_bar_index := time == chart.right_visible_bar_time ? bar_index : right_visible_bar_index
visibleWidthInBars      := right_visible_bar_index - left_visible_bar_index
circleAnchor            := right_visible_bar_index - math.round(0.5 * visibleWidthInBars)

if executionWindow    

    if barstate.isconfirmed    
        fetchData()

        if barstate.islastconfirmedhistory or barstate.isrealtime     
            normalizeData()
            orderData()        
            drawCircle()

            if showMeanInput
                drawMean()            

//---------------------------------------------------------------------------------------------------------------------}
````
