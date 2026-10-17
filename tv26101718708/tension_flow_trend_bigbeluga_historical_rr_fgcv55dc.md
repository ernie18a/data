# Tension Flow Trend [BigBeluga] - Historical RR

- url: https://www.tradingview.com/script/Fgcv55DC-Tension-Flow-Trend-BigBeluga-Historical-RR/
- type: indicator
- pine_id: PUB;3a69b36802cc4ef2a57fde7bf522adef
- version: 1.0

## Description

[b]Tension Flow Trend [BigBeluga][/b] is a high-performance trend-following framework that treats price action like a reactive elastic system. By moving beyond static averages, this indicator introduces "Price Tension"—a sophisticated measurement of how overstretched a trend is relative to its baseline—now enhanced with a live [b]Historical RR (Risk:Reward)[/b] backtesting engine.

By combining the ultra-low-lag properties of the Hull Moving Average (HMA) with real-time Z-Score volatility analysis, this indicator visualizes not just the direction of the market, but the mathematical "exhaustion" of every move.

[b]🔵 THE ELASTICITY FRAMEWORK[/b]
[list]
[*] [b]The Ultra-Responsive HMA Baseline:[/b] At the heart of the system is a 50-period Hull Moving Average. Specifically engineered to eliminate the lag found in traditional SMAs, the HMA provides a "true north" that reacts instantly to structural shifts without the usual delay.
[image]https://www.tradingview.com/x/ZTJr9LuX/[/image]
[*] [b]Price Tension (Z-Score Engine):[/b] The indicator measures the vertical distance between price and the HMA, normalizing it using standard deviation. This Z-Score represents the "Tension" of the trend—showing you exactly when the market has deviated too far from its mean.
[image]https://www.tradingview.com/x/dHoJB1Tb/[/image]
[*] [b]Dynamic Transparency Feedback:[/b] As price enters an extreme Z-Score range, the trend ribbon’s transparency increases. A bright, solid ribbon indicates compressed, high-probability energy, while a fading ribbon warns that the "elastic band" is stretched to its limit.
[/list]

[b]🔵 PERFORMANCE & RISK INTELLIGENCE[/b]
[list]
[*] [b]Automated RR Projection:[/b] Upon every "START" signal, the script automatically plots dynamic Risk:Reward boxes. It calculates an ATR-based stop loss and projects a take-profit target based on your custom RR ratio, visualizing the trade's path in real-time.
[image]https://www.tradingview.com/x/PkFBgzjD/[/image]
[*] [b]Rolling Performance Tracker:[/b] The indicator features a built-in backtester that tracks the win/loss history of the most recent trades. It calculates your [b]Win Rate[/b] based on a rolling sample size, allowing you to see how the strategy is performing under current market conditions.
[image]https://www.tradingview.com/x/Ro0fTLac/[/image]
[*] [b]Signal Cooldown Logic:[/b] To eliminate "whipsaw" noise, a configurable cooldown engine ensures that signals only trigger during significant structural shifts. This prevents signal clustering in sideways or choppy markets.
[/list]

[b]🔵 DUAL-DASHBOARD SYSTEM[/b]
[list]
[*] [b]Energy Monitor (Bottom-Right):[/b] Tracks the numerical Z-Score and categorizes the market status. "Strong" indicates healthy momentum, while "Overextended" warns of an imminent mean-reversion risk.
[*] [b]RR Performance Table (Top-Right):[/b] Provides an institutional-grade breakdown of your strategy performance, including total Wins, Losses, and the current Win Rate percentage for the specified trade window.
[image]https://www.tradingview.com/x/iGUOtWSb/[/image]
[/list]

[b]🔵 STRATEGIC APPLICATION[/b]

[list]
[*] [b]The Momentum Breakout:[/b] Look for [b]"START"[/b] labels that appear when the HMA slope aligns with a price crossover. These represent the birth of a new trend cycle where tension is low and expansion is likely.
[image]https://www.tradingview.com/x/bGU7X3Ky/[/image]
[*] [b]Managing Trend Exhaustion:[/b] When the ribbon begins to fade and the Energy Dashboard hits "Overextended," it is time to tighten stops or take partial profits. High tension usually precedes a sharp snap-back to the baseline.
[*] [b]Confirming with Win Rate:[/b] Use the Performance Dashboard to gauge market regime. If the rolling Win Rate is high, the market is respecting the trend envelopes; if it drops, the market may be entering a consolidation phase where you should wait for better alignment.
[*] [b]Mean Reversion Targets:[/b] For contrarian traders, the HMA baseline serves as a natural "magnet." When price is significantly overextended, look for price to be pulled back into the HMA "Neutral Zone."
[/list]

[b]Tension Flow Trend[/b] transforms your chart into a map of market stress and opportunity. By visualizing the tension behind every candle and providing real-time performance feedback, it ensures you stay on the right side of the trend while trading with professional-grade risk management.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga
//@version=6

indicator('Tension Flow Trend [BigBeluga] - Historical RR', overlay = true, max_boxes_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

hmaLen     = input.int(50,  'HMA Length',            minval = 1,   group = "Settings",         tooltip = "Length of the Hull Moving Average used as the trend baseline.")
zLen       = input.int(50,  'Z-Score Length',         minval = 1,   group = "Settings",         tooltip = "Lookback period for the Z-Score standard deviation calculation.")
offsetMult = input.float(0.5,'Ribbon Width',          step   = 0.1, group = "Settings",         tooltip = "ATR multiplier that controls how wide the trend ribbon is drawn around the HMA.")

signalGap  = input.int(30,  'Signal Cooldown (Bars)', minval = 1,                               tooltip = "Minimum number of bars that must pass before a new signal can trigger. Prevents signal clustering.")
showLabels = input.bool(true,'Show Trend Start Labels',              group = "Visibility",       tooltip = "Display START labels on the chart when a new trend signal is detected.")
showTable  = input.bool(true,'Show Energy Dashboard',                group = "Visibility",       tooltip = "Show the Z-Score and trend status dashboard in the bottom-right corner.")
showRRTable= input.bool(true,'Show RR Performance Dashboard',        group = "Visibility",       tooltip = "Show the win/loss backtest performance table.")

atrMultSL  = input.float(2,'Stop Loss ATR Multiplier', step = 0.1, group = "Risk Management", tooltip = "Multiplier applied to ATR(200) to calculate the stop loss distance from entry.")
rrRatio    = input.float(1.0,'Risk:Reward Ratio',         step = 0.1, group = "Risk Management", tooltip = "Take profit is set at this multiple of the stop loss distance from entry.")

maxTrades  = input.int(100, 'Backtest Trade Window',  minval = 1,   group = "Backtest",         tooltip = "Maximum number of closed trades to include in the win/loss performance calculation. Only the most recent N closed trades are counted.")

colorBull  = input.color(#00ffbb, 'Bullish Color', group = "Appearance", tooltip = "Color used for bullish signals, TP boxes, and uptrend ribbon.")
colorBear  = input.color(#ff0055, 'Bearish Color', group = "Appearance", tooltip = "Color used for bearish signals, SL boxes, and downtrend ribbon.")
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
hmaValue      = ta.hma(close, hmaLen)
hmaSlopeUp    = hmaValue > hmaValue[1]
priceDist     = close - hmaValue
stdDev        = ta.stdev(priceDist, zLen)
zScore        = priceDist / stdDev
absZ          = math.abs(zScore)
dynamicTransp = math.min(90, math.max(10, absZ * 25))

upperRibbon = hmaValue + ta.atr(14) * offsetMult
lowerRibbon = hmaValue - ta.atr(14) * offsetMult

// Signals
var int lastSignalBar = -100
canTrigger = (bar_index - lastSignalBar) >= signalGap

crossUp = ta.crossover(close, hmaValue[0])
crossDn = ta.crossunder(close, hmaValue[0])

bullSignal = hmaSlopeUp   and crossUp     and canTrigger
bearSignal = not hmaSlopeUp and crossDn  and canTrigger

if bullSignal or bearSignal
    lastSignalBar := bar_index
// }

// ———————————————————— HISTORICAL BOX LOGIC ———————————————————— {

// Rolling trade outcome history (true = win, false = loss)
var tradeHistory = array.new_bool()

// Active trade tracking arrays
var activeSLBoxes = array.new_box()
var activeTPBoxes = array.new_box()
var entryPrices   = array.new_float()
var slPrices      = array.new_float()
var tpPrices      = array.new_float()
var directions    = array.new_int()

float atr = ta.atr(200)

trendChange = hmaSlopeUp != hmaSlopeUp[1]


if (bullSignal or bearSignal) and not trendChange and not trendChange[1]
    float entry = close
    int   dir   = bullSignal ? 1 : -1
    float sl    = dir == 1 ? entry - (atr * atrMultSL) : entry + (atr * atrMultSL)
    float risk  = math.abs(entry - sl)
    float tp    = dir == 1 ? entry + (risk * rrRatio)  : entry - (risk * rrRatio)

    box newSL = box.new(
         left         = bar_index,
         top          = dir == 1 ? entry : sl,
         right        = bar_index,
         bottom       = dir == 1 ? sl    : entry,
         bgcolor      = color.new(colorBear, 85),
         border_color = color.new(colorBear, 40))

    box newTP = box.new(
         left         = bar_index,
         top          = dir == 1 ? tp    : entry,
         right        = bar_index,
         bottom       = dir == 1 ? entry : tp,
         bgcolor      = color.new(colorBull, 85),
         border_color = color.new(colorBull, 40),
         text         = "RR: " + str.tostring(rrRatio),
         text_color   = color.white,
         text_size    = size.normal)

    array.push(activeSLBoxes, newSL)
    array.push(activeTPBoxes, newTP)
    array.push(entryPrices,   entry)
    array.push(slPrices,      sl)
    array.push(tpPrices,      tp)
    array.push(directions,    dir)

// Update all active boxes and check exits
if array.size(activeSLBoxes) > 0
    for i = array.size(activeSLBoxes) - 1 to 0
        box   currSL = array.get(activeSLBoxes, i)
        box   currTP = array.get(activeTPBoxes, i)
        float sL     = array.get(slPrices,      i)
        float tP     = array.get(tpPrices,      i)
        int   d      = array.get(directions,    i)

        box.set_right(currSL, bar_index)
        box.set_right(currTP, bar_index)

        bool hitSL = d == 1 ? low  <= sL : high >= sL
        bool hitTP = d == 1 ? high >= tP : low  <= tP

        if hitTP or hitSL
            // Push outcome into rolling history
            array.push(tradeHistory, hitTP)
            // Trim to the user-defined window
            if array.size(tradeHistory) > maxTrades
                array.shift(tradeHistory)

            array.remove(activeSLBoxes, i)
            array.remove(activeTPBoxes, i)
            array.remove(entryPrices,   i)
            array.remove(slPrices,      i)
            array.remove(tpPrices,      i)
            array.remove(directions,    i)
// }

// ———————————————————— DERIVE STATS FROM ROLLING HISTORY ———————————————————— {

int   totalWins   = 0
int   totalLosses = 0

if array.size(tradeHistory) > 0
    for i = 0 to array.size(tradeHistory) - 1
        if array.get(tradeHistory, i)
            totalWins   += 1
        else
            totalLosses += 1

int   totalClosed = totalWins + totalLosses
float winRate     = totalClosed > 0 ? (totalWins / totalClosed) * 100 : 0.0
// }

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
p1 = plot(upperRibbon, color = color.new(hmaSlopeUp ? colorBull : colorBear, 60), display = display.none)
p2 = plot(lowerRibbon, color = color.new(hmaSlopeUp ? colorBull : colorBear, 60), display = display.none)
fillColor = hmaSlopeUp ? colorBull : colorBear
fill(p1, p2, upperRibbon, hmaValue, color.new(fillColor, 80 - dynamicTransp), color.new(fillColor, 100))
fill(p1, p2, hmaValue, lowerRibbon, color.new(fillColor, 100), color.new(fillColor, 80 - dynamicTransp))
plot(hmaValue, 'Trend Baseline', color = color.new(fillColor, 0), linewidth = 2)

plotshape(showLabels ? bullSignal : false, style = shape.labelup,   location = location.belowbar, color = color.new(colorBull, 50), text = 'START', size = size.tiny, textcolor = chart.fg_color)
plotshape(showLabels ? bearSignal : false, style = shape.labeldown, location = location.abovebar, color = color.new(colorBear, 50), text = 'START', size = size.tiny, textcolor = chart.fg_color)
// }

// ———————————————————— ENERGY DASHBOARD (bottom-right) ———————————————————— {
if showTable
    var table trendTable = table.new(position.bottom_right, 2, 2, border_width = 1)
    statusText  = absZ > 2.0 ? 'Overextended' : 'Strong'
    statusColor = absZ > 2.0 ? color.orange : hmaSlopeUp ? colorBull : colorBear
    table.cell(trendTable, 0, 0, 'Z-Score',  bgcolor = #131722, text_color = color.white)
    table.cell(trendTable, 1, 0, str.tostring(zScore, '#.##'), bgcolor = #131722, text_color = statusColor)
    table.cell(trendTable, 0, 1, 'Status',   bgcolor = #131722, text_color = color.white)
    table.cell(trendTable, 1, 1, statusText, bgcolor = #131722, text_color = statusColor)
// }

// ———————————————————— RR PERFORMANCE DASHBOARD (top-right) ———————————————————— {
if showRRTable
    var table rrTable = table.new(position.top_right, 2, 5, border_width = 1, border_color = color.new(color.gray, 60))

    winRateColor = winRate >= 55 ? color.new(#22c55e, 15) : winRate >= 40 ? color.orange : color.new(#ef4444, 15)

    // Header row
    table.cell(rrTable, 0, 0, 'RR Performance',
         bgcolor    = color.new(#1e222d, 0),
         text_color = color.white,
         text_size  = size.normal)
    table.cell(rrTable, 1, 0, 'RR ' + str.tostring(rrRatio, '#.#') + ':1',
         bgcolor    = color.new(#1e222d, 0),
         text_color = color.new(color.gray, 20),
         text_size  = size.normal)

    // Wins row
    table.cell(rrTable, 0, 1, '✔  Wins',
         bgcolor    = color.new(#131722, 0),
         text_color = color.white,
         text_size  = size.normal)
    table.cell(rrTable, 1, 1, str.tostring(totalWins),
         bgcolor    = color.new(#22c55e, 75),
         text_color = color.white,
         text_size  = size.normal)

    // Losses row
    table.cell(rrTable, 0, 2, 'X  Losses',
         bgcolor    = color.new(#131722, 0),
         text_color = color.white,
         text_size  = size.normal)
    table.cell(rrTable, 1, 2, str.tostring(totalLosses),
         bgcolor    = color.new(#ef4444, 75),
         text_color = color.white,
         text_size  = size.normal)

    // Win Rate row
    table.cell(rrTable, 0, 3, 'Win Rate',
         bgcolor    = color.new(#131722, 0),
         text_color = color.white,
         text_size  = size.normal)
    table.cell(rrTable, 1, 3, str.tostring(winRate, '#.##') + '%',
         bgcolor    = winRateColor,
         text_color = color.white,
         text_size  = size.normal)

    // Sample size row
    table.cell(rrTable, 0, 4, 'Sample  (last)',
         bgcolor    = color.new(#131722, 0),
         text_color = color.new(color.gray, 20),
         text_size  = size.normal)
    table.cell(rrTable, 1, 4, str.tostring(totalClosed) + ' / ' + str.tostring(maxTrades),
         bgcolor    = color.new(#131722, 0),
         text_color = color.new(color.gray, 20),
         text_size  = size.normal)
// }
````
