# EMA's, VWAP, Inside Day, Slingshot

- url: https://www.tradingview.com/script/KyTEJa5K-EMA-s-VWAP-Inside-Day-Slingshot/
- type: indicator
- pine_id: PUB;f31434d7d3264758a739229636f79e50
- version: 3.0

## Description

EMA's, VWAP, Slingshot & Inside Day
An all-in-one price action overlay combining four tools:
🔹 4 Customizable EMAs — Default lengths 5, 8, 20 & 50. Adjust lengths in Settings, colors in the Style tab.
🔹 VWAP — Only displays on intraday timeframes. Auto-hides on daily and above.
🔹 Slingshot — Uses an EMA of highs rather than closes, making it a tougher level to break above. When price closes above it after 3 consecutive bars below, it signals a momentum shift — like a slingshot snapping back. Paints the bar, plots a marker, and includes an alert.
🔹 Inside Day — Highlights bars fully contained within the prior bar's range.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trxits

//@version=6
indicator(title="EMA's, VWAP, Slingshot, Inside Day", shorttitle="EMA/VWAP/Sling/Inside", overlay=true)

// ===================== Inside Day =====================
showInsideDay = input.bool(true, "Highlight Inside Bar?", group="Inside Day")
insideColor   = input.color(color.new(#9c9c9c, 0), "Inside Bar Color", group="Inside Day")

insideDay = high <= high[1] and low >= low[1]

// ===================== Slingshot Settings =====================
C_Paintbar = input.color(color.new(color.orange, 0), "Bar Color", group="Slingshot")

ShowEMA   = input.bool(false, "Show Slingshot EMA Line?", group="Slingshot")
Paintbar  = input.bool(true,  "Paint Bar?", group="Slingshot")
ShowShape = input.bool(false, "Show SlingShot Marker?", group="Slingshot")
EMAlen    = input.int(4, minval=1, title="Slingshot EMA Length", group="Slingshot")

EMALine = ta.ema(high, EMAlen)
plot(ShowEMA ? EMALine : na, title="Slingshot EMA", color=color.new(color.orange, 0))

slingshot = close > EMALine and close[1] < EMALine[1] and close[2] < EMALine[2] and close[3] < EMALine[3]

alertcondition(slingshot, title="Slingshot", message="Slingshot Triggered!")

plotshape(ShowShape and slingshot ? 1 : na, style=shape.labelup, location=location.belowbar, size=size.tiny, color=color.new(color.orange, 0), title="Slingshot Marker")

// ===================== Bar Coloring =====================
barColorToUse = (Paintbar and slingshot) ? C_Paintbar : (showInsideDay and insideDay) ? insideColor : na
barcolor(barColorToUse, title="Bar Color")

// ===================== Custom EMAs =====================
showEMA1 = input.bool(true, "EMA 1", inline="ema1", group="EMAs")
len1     = input.int(5, "", minval=1, inline="ema1", group="EMAs")

showEMA2 = input.bool(true, "EMA 2", inline="ema2", group="EMAs")
len2     = input.int(9, "", minval=1, inline="ema2", group="EMAs")

showEMA3 = input.bool(true, "EMA 3", inline="ema3", group="EMAs")
len3     = input.int(21, "", minval=1, inline="ema3", group="EMAs")

showEMA4 = input.bool(true, "EMA 4", inline="ema4", group="EMAs")
len4     = input.int(50, "", minval=1, inline="ema4", group="EMAs")

showEMA5 = input.bool(true, "EMA 5", inline="ema5", group="EMAs")
len5     = input.int(150, "", minval=1, inline="ema5", group="EMAs")

ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)
ema4 = ta.ema(close, len4)
ema5 = ta.ema(close, len5)

plot(showEMA1 ? ema1 : na, title="EMA 1 ",   color=color.new(#fccbcd, 65), linewidth=1)
plot(showEMA2 ? ema2 : na, title="EMA 2 ",   color=color.new(#57fff5, 35), linewidth=1)
plot(showEMA3 ? ema3 : na, title="EMA 3 ",  color=color.new(#ffe92a, 35), linewidth=1)
plot(showEMA4 ? ema4 : na, title="EMA 4 ",  color=color.new(#ffffff, 35), linewidth=1)
plot(showEMA5 ? ema5 : na, title="EMA 5 ", color=color.new(#808080, 65), linewidth=1)

// ===================== Custom SMA =====================
showSMA1 = input.bool(true, "SMA 1", inline="sma1", group="SMAs")
lenSMA1  = input.int(200, "", minval=1, inline="sma1", group="SMAs")

sma1 = ta.sma(close, lenSMA1)

plot(showSMA1 ? sma1 : na, title="SMA 1", color=color.new(#00ffaa, 35), linewidth=1)

// ===================== Daily-Anchored VWAP (Intraday Only) =====================
showVWAP = input.bool(true, "Show Day-Anchored VWAP (intraday only)", group="VWAP")

isIntraday = timeframe.isintraday

// Anchor VWAP to the start of each new day
isNewDay = timeframe.change("D")
[dayAVWAP, _, _] = ta.vwap(hlc3, isNewDay, 1)

// Only plot bars that belong to TODAY using timenow (wall-clock time)
// This hides all previous days' VWAP lines completely
isToday = dayofmonth(time) == dayofmonth(timenow) and
         month(time)      == month(timenow)      and
         year(time)       == year(timenow)

plot(showVWAP and isIntraday and isToday ? dayAVWAP : na, title="Day AVWAP", color=color.new(#ee88ff, 32), linewidth=1)

// ===================== Crossing Alerts for all MAs =====================
alertcondition(ta.cross(close, ema1),  title="Cross EMA 1",  message="Price crossed EMA 1")
alertcondition(ta.cross(close, ema2),  title="Cross EMA 2",  message="Price crossed EMA 2")
alertcondition(ta.cross(close, ema3),  title="Cross EMA 3",  message="Price crossed EMA 3")
alertcondition(ta.cross(close, ema4),  title="Cross EMA 4",  message="Price crossed EMA 4")
alertcondition(ta.cross(close, ema5),  title="Cross EMA 5",  message="Price crossed EMA 5")
alertcondition(ta.cross(close, sma1),  title="Cross SMA 1",  message="Price crossed SMA 1")

alertcondition(ta.crossover(close, ema1),  title="Cross Up EMA 1",  message="Price crossed up through EMA 1")
alertcondition(ta.crossunder(close, ema1), title="Cross Down EMA 1", message="Price crossed down through EMA 1")

alertcondition(ta.crossover(close, ema2),  title="Cross Up EMA 2",  message="Price crossed up through EMA 2")
alertcondition(ta.crossunder(close, ema2), title="Cross Down EMA 2", message="Price crossed down through EMA 2")

alertcondition(ta.crossover(close, ema3),  title="Cross Up EMA 3",  message="Price crossed up through EMA 3")
alertcondition(ta.crossunder(close, ema3), title="Cross Down EMA 3", message="Price crossed down through EMA 3")

alertcondition(ta.crossover(close, ema4),  title="Cross Up EMA 4",  message="Price crossed up through EMA 4")
alertcondition(ta.crossunder(close, ema4), title="Cross Down EMA 4", message="Price crossed down through EMA 4")

alertcondition(ta.crossover(close, ema5),  title="Cross Up EMA 5",  message="Price crossed up through EMA 5")
alertcondition(ta.crossunder(close, ema5), title="Cross Down EMA 5", message="Price crossed down through EMA 5")

alertcondition(ta.crossover(close, sma1),  title="Cross Up SMA 1",  message="Price crossed up through SMA 1")
alertcondition(ta.crossunder(close, sma1), title="Cross Down SMA 1", message="Price crossed down through SMA 1")
````
