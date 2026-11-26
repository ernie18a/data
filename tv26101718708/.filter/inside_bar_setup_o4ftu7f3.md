# Inside Bar Setup

- url: https://www.tradingview.com/script/O4fTu7F3-Inside-Bar-Setup/
- type: indicator
- pine_id: PUB;a1528b4d74d04fcd90e4979c87afbbd1
- version: 1.0

## Description

[b]Script Details[/b]

- This script plots Inside Bar for given day in selected time-frame (applicable only for Timeframes < Day)
- Basis plotted inside bar, relevant targets are marked on the chart
- Targets can be customised from script settings. Example, if range of mother candle is 10 points, then T1 is 10 * x above/below mother candle and T2 is 10 * y above/below mother candle. This x & y are configured via script settings

[b]How to use this script ?[/b]

- This script works well on 10-15 mins timeframe for stocks, 15/30 mins timeframe for nifty index and 30/60 mins time frame for bank nifty index
- If mother candle high is broken, take long trade with SL of mother candle low and if low is broken, take short trade with SL of mother candle high

[b]Remember:[/b] 
1. Above logic is to be combined with support/resistances i.e. price action. This script is an add-on to price action analysis giving you more conviction.
2. If range of mother candle is very high, it is recommended to avoid the trade.
3. Basis inside bar formed on higher time frame, take trade on basis of lower time frame i.e if inside bar is formed on 60 mins, take trade on the basis of 10-15 mins time frame

[i]Example:[/i] 
1. As seen in the chart, Nifty is near it's resistance and we are seeing Inside Bar being formed, In such scenario, even if High of Mother Candle is broken, we should be more interested to short as we are near resistance and probability of getting our targets in long side is less.
2. So, if I see breakdown of mother candle i.e. price going below low of mother candle, we will short with SL of high of mother candle.
3. As seen in the chart, both the targets are achieved. 

[b]Additional Info:[/b]
1. Targets on Long/Short Side can be configured via settings. For indices 1 times/1.5 times the range works well.
2. This script plots targets basis the first inside bar formed in the day for selected time frame.
3. Inside bars formed through out the day are coloured separately but lines are plotted only on the basis of 1st formed inside bar as this strategy works well for the first formed inside bar)
4. Don't forget to check volume in case of breakout/breakdown.

Note:
1. Mother Candle - First Candle of Inside Bar
2. Child Candle - Candle formed inside Mother Candle (Second Candle of Inside Bar)

Happy Trading :)

## Source Code

````pine
//@version=5
indicator('Inside Bar Setup', overlay=true)

bullishBar = 1
bearishBar = -1

var inside_bar = array.new_int(0)
var inside_bar_high = array.new_float(0)
var inside_bar_low = array.new_float(0)
var motherCandleIndex = 0
var motherCandleHigh = 0.0
var motherCandleLow = 0.0
var motherCandleRange = 0.0
var target1Buy = 0.0
var target2Buy = 0.0
var target1Sell = 0.0
var target2Sell = 0.0

var motherCandleH = line.new(na, na, na, na, extend=extend.right, color=color.green)
var motherCandleL = line.new(na, na, na, na, extend=extend.right, color=color.red)
var motherCandleHLabel = label.new(na, na, style=label.style_none, textcolor=color.green)
var motherCandleLLabel = label.new(na, na, style=label.style_none, textcolor=color.red)

var longT1 = line.new(na, na, na, na, extend=extend.right)
var longT2 = line.new(na, na, na, na, extend=extend.right)
var shortT1 = line.new(na, na, na, na, extend=extend.right)
var shortT2 = line.new(na, na, na, na, extend=extend.right)

var longT1Label = label.new(na, na, textcolor=color.blue, style=label.style_none)
var longT2Label = label.new(na, na, textcolor=color.blue, style=label.style_none)
var shortT1Label = label.new(na, na, textcolor=color.blue, style=label.style_none)
var shortT2Label = label.new(na, na, textcolor=color.blue, style=label.style_none)


var bullBarColor = input.color(title='Bull Bar Color', defval=color.lime, group='Colors')
var bearBarColor = input.color(title='Bear Bar Color', defval=color.maroon, group='Colors')

var longT1Line = input.bool(title='Show Long T1', defval=true, group='Long')
var longT2Line = input.bool(title='Show Long T2', defval=true, group='Long')

var shortT1Line = input.bool(title='Show Short T1', defval=true, group='Short')
var shortT2Line = input.bool(title='Show Short T2', defval=true, group='Short')

var longT1Range = input.float(title='Long T1', defval=1, group='Long (x times above range of mother candle)', tooltip='Line will be plotted above high of mother candle. If value entered is 1, then T1 = range of mother candle x 1')
var longT2Range = input.float(title='Long T2', defval=1.5, group='Long (x times above range of mother candle)', tooltip='Line will be plotted above high of mother candle. If value entered is 2, then T2 = range of mother candle x 2')

var shortT1Range = input.float(title='Short T1', defval=1, group='Short (x times below range of mother candle)', tooltip='Line will be plotted below low of mother candle. If value entered is 1, then T1 = range of mother candle x 1')
var shortT2Range = input.float(title='Short T2', defval=1.5, group='Short (x times below range of mother candle)', tooltip='Line will be plotted below low of mother candle. If value entered is 2, then T2 = range of mother candle x 1')


hi = high
lo = low
op = open
cl = close

isInside() =>
    previousBar = 1
    bodyStatus = cl >= op ? 1 : -1
    isInsidePattern = hi < hi[previousBar] and lo > lo[previousBar]
    isInsidePattern ? bodyStatus : 0


newDay = ta.change(time('D'))
bgcolor(newDay ? color.blue : na, transp=90)

barcolor(isInside() == bullishBar ? bullBarColor : na)
barcolor(isInside() == bearishBar ? bearBarColor : na)

if newDay
    array.clear(inside_bar)
    array.clear(inside_bar_high)
    array.clear(inside_bar_low)


if isInside() and array.size(inside_bar) <= 0
    array.push(inside_bar, bar_index)
    array.push(inside_bar_high, hi[1])
    array.push(inside_bar_low, lo[1])


if barstate.islast and array.size(inside_bar) > 0

    motherCandleIndex := array.get(inside_bar, 0) - 1
    motherCandleHigh := array.get(inside_bar_high, 0)
    motherCandleLow := array.get(inside_bar_low, 0)
    motherCandleRange := motherCandleHigh - motherCandleLow

    target1Buy := motherCandleHigh + longT1Range * motherCandleRange
    target2Buy := motherCandleHigh + longT2Range * motherCandleRange

    target1Sell := motherCandleLow - shortT1Range * motherCandleRange
    target2Sell := motherCandleLow - shortT2Range * motherCandleRange

    // mother candle high
    line.set_xy1(motherCandleH, motherCandleIndex, motherCandleHigh)
    line.set_xy2(motherCandleH, bar_index, motherCandleHigh)
    label.set_xy(motherCandleHLabel, bar_index + 5, motherCandleHigh)
    label.set_text(id=motherCandleHLabel, text='Range High - ' + str.tostring(motherCandleHigh))


    //mother candle low
    line.set_xy1(motherCandleL, motherCandleIndex, motherCandleLow)
    line.set_xy2(motherCandleL, bar_index, motherCandleLow)
    label.set_xy(motherCandleLLabel, bar_index + 5, motherCandleLow)
    label.set_text(id=motherCandleLLabel, text='Range Low - ' + str.tostring(motherCandleLow))

    //long target 1
    if longT1Line
        line.set_xy1(longT1, motherCandleIndex, target1Buy)
        line.set_xy2(longT1, bar_index, target1Buy)
        label.set_xy(longT1Label, bar_index + 5, target1Buy)
        label.set_text(id=longT1Label, text='T1 - ' + str.tostring(target1Buy) + ' (' + str.tostring(longT1Range * motherCandleRange) + ') points')

    //long target 2
    if longT2Line
        line.set_xy1(longT2, motherCandleIndex, target2Buy)
        line.set_xy2(longT2, bar_index, target2Buy)
        label.set_xy(longT2Label, bar_index + 5, target2Buy)
        label.set_text(id=longT2Label, text='T2 - ' + str.tostring(target2Buy) + ' (' + str.tostring(longT2Range * motherCandleRange) + ') points')

    //short target 1
    if shortT1Line
        line.set_xy1(shortT1, motherCandleIndex, target1Sell)
        line.set_xy2(shortT1, bar_index, target1Sell)
        label.set_xy(shortT1Label, bar_index + 5, target1Sell)
        label.set_text(id=shortT1Label, text='T1 - ' + str.tostring(target1Sell) + ' (' + str.tostring(shortT1Range * motherCandleRange) + ') points')

    //short target 2
    if shortT2Line
        line.set_xy1(shortT2, motherCandleIndex, target2Sell)
        line.set_xy2(shortT2, bar_index, target2Sell)
        label.set_xy(shortT2Label, bar_index + 5, target2Sell)
        label.set_text(id=shortT2Label, text='T2 - ' + str.tostring(target2Sell) + ' (' + str.tostring(shortT2Range * motherCandleRange) + ') points')
````
