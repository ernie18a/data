# ATR Trend Channel Signals [BigBeluga]

- url: https://www.tradingview.com/script/OpMBlV1E-ATR-Trend-Channel-Signals-BigBeluga/
- type: indicator
- pine_id: PUB;4dd40e2a785646e4a423a2e23322a62e
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote][b]ATR Trend Channel Signals [BigBeluga][/b] is an indicator that builds a volatility channel around price using ATR-based bands and colors every candle based on where it sits inside that channel. It solves the problem of static trend filters by turning the channel into a live visual gauge, adding inner dashed buffer bands that warn of weakening momentum before price ever reaches the outer flip level.[/quote]


[b]🔵 HOW IT WORKS[/b]
[quote]The indicator anchors an ATR-derived channel to price, tracks trend direction, and blends colors to signal pressure inside the range:

[b]1 — Channel Construction[/b]
[list]
[*] [b]ATR Bands:[/b] Upper and lower bands are calculated as the [i]Source[/i] plus or minus the [i]ATR Length[/i] multiplied by the [i]ATR Multiplier[/i].
[*] [b]Seeding:[/b] The channel is first drawn once bar index reaches the ATR length, then re-anchors whenever a trend flip occurs.
[*] [b]Inner Buffer Bands:[/b] Dashed inner lines are offset inward from each outer band by half the 50-bar average candle range, recalculated only on trend flips so their width stays stable through the trend.
[/list]

[b]2 — Trend & Flip Logic[/b]
[list]
[*] [b]Uptrend Trigger:[/b] A close above the upper band flips the trend bullish and prints a "B" marker below the bar.
[*] [b]Downtrend Trigger:[/b] A close below the lower band flips the trend bearish and prints an "S" marker above the bar.
[*] [b]Projection Line:[/b] A dashed line and label extend from the last bar, showing the exact price level that would trigger the next trend flip.
[/list]

[b]3 — Gradient Coloring[/b]
[list]
[*] [b]Position-Based Gradient:[/b] Each candle is colored by where price sits inside the channel, from 0 (lower band) to 1 (upper band).
[*] [b]Trend-Aware Palette:[/b] In an uptrend the gradient runs from transition color to bullish; in a downtrend it runs from bearish to transition color.
[*] [b]Transition Warning:[/b] The transition color brightens as price approaches the band that would trigger a flip, giving early warning of a reversal.
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]Beyond reading trend direction, the indicator can be applied in several ways:

[list=1]
[*] [b]Read Trend at a Glance:[/b] Use candle color and the corner table to instantly see whether the market is in an uptrend or downtrend.
[*] [b]Watch the Buffer Zone:[/b] Treat a move toward the dashed inner band as a momentum warning, and a move to the outer band as a flip in progress.
[*] [b]Anticipate Flips Early:[/b] Watch for candles shifting toward the transition color as price nears the opposite band, signaling a possible reversal.
[*] [b]Trade Breakout Confirmations:[/b] Use the "B" and "S" flip markers as confirmation when price closes beyond the channel.
[*] [b]Plan Targets with the Projection Line:[/b] Use the dashed projection and its price label to know exactly where the next flip would trigger.
[*] [b]Tune Sensitivity:[/b] Increase the [i]ATR Multiplier[/i] for wider, slower channels or decrease it for faster, more reactive signals.
[/list][/quote]


[b]🔔 ALERTS[/b]
[quote]The indicator ships with two built-in alert conditions that can be enabled from the alert dialog:

[list]
[*] [b]Bullish Flip (B):[/b] Fires when price closes above the upper band and the trend flips bullish.
[*] [b]Bearish Flip (S):[/b] Fires when price closes below the lower band and the trend flips bearish.
[/list]

Both alerts include the ticker and close price in their default message, and can be set to trigger once per bar close for confirmed signals.[/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] Turns a standard ATR channel into a live visual gauge by coloring candles based on their position inside the range.
[*] Adds inner dashed buffer bands that act as a softer momentum warning zone before price reaches the outer flip level.
[*] Uses a trend-aware gradient that blends into a transition color to warn of flips before they occur.
[*] Includes a forward projection line and label showing the exact flip trigger price on the last bar.
[*] Built-in alert conditions for bullish and bearish flips.
[*] Fully customizable colors, source, ATR length, and multiplier to match any market or timeframe.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("ATR Trend Channel Signals [BigBeluga]", overlay = true)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

int   length      = input.int(100, "ATR Length", minval = 1, tooltip = "Number of bars used to calculate the ATR. This also sets the initial bar index where the channel is first seeded.")
float mult        = input.float(2.5, "ATR Multiplier", minval = 0.1, step = 0.1, tooltip = "Multiplier applied to the ATR to widen or narrow the channel. 1.0 = raw ATR.")
float src         = input.source(hl2, "Source", tooltip = "Price source used as the channel center. Default is hl2 = (high + low) / 2.")

// Colors on one inline row
color bullCol     = input.color(color.rgb(12, 190, 137), "Colors", inline = "col", tooltip = "BULLISH color.\n\nApplied when price is near the trend-side band: at the upper band during an uptrend, at the lower band during a downtrend. Also used for the bullish flip marker.")
color bearCol     = input.color(color.rgb(233, 52, 52),  "",       inline = "col", tooltip = "BEARISH color.\n\nApplied when price sits on the far side of the channel against the current trend: near the lower band during an uptrend, near the upper band during a downtrend. Also used for the bearish flip marker.")
color transCol    = input.color(color.yellow,            "",       inline = "col", tooltip = "TRANSITION color.\n\nBlended between the bull/bear extremes to warn of an approaching trend flip. Brightest right before price reaches the band that would trigger a flip.")

// } 
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

atr_ = ta.atr(length)
atr_dist = atr_ * mult

var float upper = na
var float lower = na
var float mid   = na
var bool  trend = false

if bar_index == length
    upper := src + atr_dist
    lower := src - atr_dist
    mid   := math.avg(upper, lower)

bool flipUp      = false
bool flipDn      = false
// NEW: inner-band offset, recalculated on each trend flip only.
// Keeps the dashed inner line a stable width for the duration of a trend.
var sizeBand = 0.

if close > upper
    flipUp := not trend
    trend  := true
    upper  := src + atr_dist
    lower  := src - atr_dist
    mid    := math.avg(upper, lower)

if close < lower
    flipDn := trend
    trend  := false
    upper  := src + atr_dist
    lower  := src - atr_dist
    mid    := math.avg(upper, lower)

// NEW: average candle range over 50 bars — used as the basis for the inner band offset.
dist = ta.sma(high - low, 50)

// NEW: on every trend flip, recompute the inner band offset.
// Using half the average range keeps the inner line visually proportional to volatility.
if trend != trend[1]
    sizeBand := dist * 0.5

// Gradient
// pos = position of price inside the channel: 0 = lower band, 1 = upper band.
// Clamped so overshoots stay at the extremes. Falls back to 0.5 if channel is degenerate.
float pos      = na(mid) or upper == lower ? 0.5 : math.max(0.0, math.min(1.0, (close - lower) / (upper - lower)))

// Gradient flips with trend direction:
//  Uptrend   → pos 0 = transition, pos 1 = bull
//  Downtrend → pos 0 = bear,       pos 1 = transition
color gradCol  = trend
     ? color.from_gradient(pos, 0.0, 0.3, transCol, bullCol)
     : color.from_gradient(pos, 0.3, 1.0, bearCol,  transCol)

color mCol   = gradCol

// } 
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// CHANGED: outer bands now use full-opacity bull/bear (was mCol with 50% transparency).
// Using pure bull/bear here makes the outer level stand out against the gradient candles.
plot((upper != upper[1] or not trend) ? na : upper, "Upper Band", style = plot.style_linebr, color = color.new(bullCol, 0), linewidth = 1)
plot((lower != lower[1] or trend)     ? na : lower, "Lower Band", style = plot.style_linebr, color = color.new(bearCol, 0), linewidth = 1)

// NEW: inner dashed bands — offset inward by sizeBand from the active outer band.
// These act as a softer "buffer zone" marker: price crossing inward is still safe,
// but approaching the dashed line hints at weakening momentum toward the outer band.
plot((upper != upper[1] or not trend) ? na : upper - sizeBand, "Upper Band 1", style = plot.style_linebr, color = color.new(mCol, 50), linestyle = plot.linestyle_dashed)
plot((lower != lower[1] or trend)     ? na : lower + sizeBand, "Lower Band 1", style = plot.style_linebr, color = color.new(mCol, 50), linestyle = plot.linestyle_dashed)

plot(mid == mid[1] ? mid : na, "Midline", style = plot.style_linebr, color = color.new(color.gray, 0), linewidth = 1, linestyle = plot.linestyle_dashed, display = display.none)

plotcandle(open, high, low, close, title = "Candles", color = mCol, wickcolor = mCol, bordercolor = mCol)

barcolor(not na(mid) ? mCol : na, title = "Bar Color")

// Flip markers
plotchar(flipUp ? low - atr_ : na, "Bullish Flip", "B", location = location.absolute, color = bullCol, size = size.tiny)
plotchar(flipDn ? high + atr_ : na, "Bearish Flip", "S", location = location.absolute, color = bearCol, size = size.tiny)


// Last-bar projection
var line  projLine  = na
var label projLabel = na

if barstate.islast and not na(mid)
    float projLevel = trend ? lower : upper
    string projTxt  = trend ? "Bearish Flip" : "Bullish Flip"
    color  projCol  = trend ? bearCol : bullCol

    int startX = bar_index
    int endX   = bar_index + 10

    if na(projLine)
        projLine := line.new(startX, projLevel, endX, projLevel,
             xloc  = xloc.bar_index,
             color = color.new(projCol, 0),
             style = line.style_dashed,
             width = 1)
    else
        line.set_xy1(projLine, startX, projLevel)
        line.set_xy2(projLine, endX,   projLevel)
        line.set_color(projLine, color.new(projCol, 0))

    if na(projLabel)
        projLabel := label.new(endX, projLevel,
             text      = projTxt + "  " + str.tostring(projLevel, "#.####"),
             xloc      = xloc.bar_index,
             style     = label.style_label_left,
             color     = color.new(projCol, 20),
             textcolor = color.white,
             size      = size.small)
    else
        label.set_xy(projLabel, endX, projLevel)
        label.set_text(projLabel, projTxt + "  " + str.tostring(projLevel, "#.####"))
        label.set_color(projLabel, color.new(projCol, 20))

// Trend table
// CHANGED: position moved to bottom_right, 5 rows tall, and "CLOSE" label renamed to "PRICE".
// bgcolor stays fully transparent (100% transparency) so only the text is visible on the chart.
var table trendTbl = table.new(position.bottom_right, 2, 5, bgcolor = color.new(color.black, 100), border_width = 0)
if barstate.islast
    table.cell(trendTbl, 0, 0, "TREND",  text_color = mCol, text_size = size.small)
    table.cell(trendTbl, 1, 0, trend ? "UP" : "DOWN", text_color = mCol, text_size = size.small)
    table.cell(trendTbl, 0, 1, "PRICE",  text_color = mCol, text_size = size.small)
    table.cell(trendTbl, 1, 1, str.tostring(close, format.mintick), text_color = mCol, text_size = size.small)

// }
// ＡＬＥＲＴＳ ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

alertcondition(flipUp, title = "Bullish Flip (B)", message = "ATR Trend Channel: Bullish Flip (B) on {{ticker}} at {{close}}")
alertcondition(flipDn, title = "Bearish Flip (S)", message = "ATR Trend Channel: Bearish Flip (S) on {{ticker}} at {{close}}")

// }
````
