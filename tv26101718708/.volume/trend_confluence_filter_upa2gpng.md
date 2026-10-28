# Trend Confluence Filter

- url: https://www.tradingview.com/script/upA2gpng-Trend-Confluence-Filter/
- type: indicator
- pine_id: PUB;9ecff3d52f304c4f9a337a959d97eb99
- version: 2.0

## Description

Trend Confluence Filter

This is scripted to combine multiple separate indicators — moving average alignment, VWAP, and yesterday's levels — that are often used together into a single overlay, each with adjustable inputs.

What's on the chart:
Session VWAP — Primary signal and institutional reference
EMA 9 / 21 ribbon — 9 and 21 EMA lines with a green/red dynamic ribbon that flips from green or red when EMA is 9/21 or 21/9
SMA 20 / 50 / 200 — Long-term structure at a glance
Yesterday's high, low, and close — Benchmark reference
Dashboard table — Color-coded based on current price vs. each MA and VWAP

Signals:
Bullish: SMAs stacked up 20/50/200, 1-5M (Intraday) or 15M (Swing) candle closing above the VWAP with a green ribbon, very bullish on an expanding ribbon (9 EMA trending up more strongly than the 21)
Bearish: Mirror the above
Trade in the direction of the SMA stack. Take the pullback signal when it holds near VWAP or a prior-day level — that confluence is part of the whole idea.

No advanced logic or PT's/SL's built in to keep it simpler and more generalized.

Script by // © TylerisTrading

## Source Code

````pine
//@version=6
indicator("Trend Confluence", overlay = true)

// --- Inputs ---
g_ma = "Moving Averages"
showSmas = input.bool(true, "Show SMA Stack", group = g_ma)
showEmas = input.bool(true, "Show EMA Cross", group = g_ma)
showVwap = input.bool(true, "Show VWAP", group = g_ma)

len1 = input.int(20, "SMA 20", inline = "s1", group = g_ma)
len2 = input.int(50, "SMA 50", inline = "s1", group = g_ma)
len3 = input.int(200, "SMA 200", inline = "s2", group = g_ma)
lenE1 = input.int(9, "EMA 9", inline = "e1", group = g_ma)
lenE2 = input.int(21, "EMA 21", inline = "e1", group = g_ma)

g_levels = "Previous Day Levels"
showPdh = input.bool(true, "Yesterday's High", inline = "pdh", group = g_levels)
pdhColor = input.color(#089981, "", inline = "pdh", group = g_levels)
showPdl = input.bool(true, "Yesterday's Low", inline = "pdl", group = g_levels)
pdlColor = input.color(#f23645, "", inline = "pdl", group = g_levels)
showPdc = input.bool(true, "Yesterday's Close", inline = "pdc", group = g_levels)
pdcColor = input.color(#5b9cf6, "", inline = "pdc", group = g_levels)

g_style = "Visuals"
vwapColor = input.color(#00ffff, "VWAP Color", group = g_style)
sma20Color = input.color(#ffffff, "20 SMA Color", group = g_style)
sma50Color = input.color(#ffff00, "50 SMA Color", group = g_style)
sma200Color = input.color(#ff0000, "200 SMA Color", group = g_style)
ema9Color = input.color(#089981, "EMA 9 Color", group = g_style)
ema21Color = input.color(#f23645, "EMA 21 Color", group = g_style)
bullColor = input.color(#089981, "Bullish Shading/Signal", group = g_style)
bearColor = input.color(#f23645, "Bearish Shading/Signal", group = g_style)
zoneTransparency = input.int(80, "Zone Transparency", minval = 0, maxval = 100, group = g_style)

g_dash = "Dashboard"
showDash = input.bool(true, "Show Dashboard Table", group = g_dash)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = g_dash)
dashSize = input.string("Small", "Size", options = ["Tiny", "Small", "Normal"], group = g_dash)

// --- Calculations ---
sma20  = ta.sma(close, len1)
sma50  = ta.sma(close, len2)
sma200 = ta.sma(close, len3)
ema9   = ta.ema(close, lenE1)
ema21  = ta.ema(close, lenE2)
vwapVal = ta.vwap(hlc3)

// Previous Day Data
[dOpen, pdh, pdl, pdc] = request.security(syminfo.tickerid, "D", [open, high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

// Trend Logic
isBullishStack = sma20 > sma50 and sma50 > sma200
isBearishStack = sma20 < sma50 and sma50 < sma200

// --- Alert Conditions ---
vwapCrossUp   = barstate.isconfirmed and ta.crossover(close, vwapVal)
vwapCrossDown = barstate.isconfirmed and ta.crossunder(close, vwapVal)
emaCrossUp    = barstate.isconfirmed and ta.crossover(ema9, ema21)
emaCrossDown  = barstate.isconfirmed and ta.crossunder(ema9, ema21)

alertcondition(vwapCrossUp,   title = "VWAP Cross Up",    message = "▲ {{ticker}} crossed ABOVE VWAP")
alertcondition(vwapCrossDown, title = "VWAP Cross Down",  message = "▼ {{ticker}} crossed BELOW VWAP")
alertcondition(emaCrossUp,    title = "EMA 9/21 Cross Up",   message = "▲ {{ticker}} EMA 9 crossed ABOVE EMA 21")
alertcondition(emaCrossDown,  title = "EMA 9/21 Cross Down", message = "▼ {{ticker}} EMA 9 crossed BELOW EMA 21")

// --- Visuals: Moving Averages ---
p20 = plot(showSmas ? sma20 : na, "SMA 20", color = sma20Color, linewidth = 1)
p50 = plot(showSmas ? sma50 : na, "SMA 50", color = sma50Color, linewidth = 1)
plot(showSmas ? sma200 : na, "SMA 200", color = sma200Color, linewidth = 2)

pEma9 = plot(showEmas ? ema9 : na, "EMA 9", color = ema9Color, linewidth = 1)
pEma21 = plot(showEmas ? ema21 : na, "EMA 21", color = ema21Color, linewidth = 1)

fill(pEma9, pEma21, ema9 > ema21 ? color.new(bullColor, zoneTransparency) : color.new(bearColor, zoneTransparency), "EMA 9/21 Ribbon")

plot(showVwap ? vwapVal : na, "VWAP", color = vwapColor, linewidth = 2, style = plot.style_linebr)

// --- Signals ---
zoneUpper = math.max(sma20, vwapVal)
zoneLower = math.min(sma20, vwapVal)
bullEntry = isBullishStack and low < zoneUpper and close > zoneUpper and close > open
bearEntry = isBearishStack and high > zoneLower and close < zoneLower and close < open

// --- Daily Levels ---
plot(showPdh ? pdh : na, "Yesterday High", color = pdhColor, style = plot.style_circles, linewidth = 1)
plot(showPdl ? pdl : na, "Yesterday Low", color = pdlColor, style = plot.style_circles, linewidth = 1)
plot(showPdc ? pdc : na, "Yesterday Close", color = pdcColor, style = plot.style_circles, linewidth = 1)

// --- Dashboard Table ---
get_pos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left

get_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal

var table dash = table.new(get_pos(dashPos), 3, 7, bgcolor = #1e222d, border_color = #363c4e, border_width = 1)

update_dash(row, name, val) =>
    status_txt = close > val ? "Above" : "Below"
    status_col = close > val ? bullColor : bearColor
    table.cell(dash, 0, row, name, text_color = color.white, text_size = get_size(dashSize))
    table.cell(dash, 1, row, str.tostring(math.round_to_mintick(val)), text_color = color.white, text_size = get_size(dashSize))
    table.cell(dash, 2, row, status_txt, bgcolor = status_col, text_color = color.white, text_size = get_size(dashSize))

if barstate.islast and showDash
    table.cell(dash, 0, 0, "Indicator", text_color = color.gray, text_size = get_size(dashSize))
    table.cell(dash, 1, 0, "Value", text_color = color.gray, text_size = get_size(dashSize))
    table.cell(dash, 2, 0, "Status", text_color = color.gray, text_size = get_size(dashSize))
    
    update_dash(1, "EMA " + str.tostring(lenE1), ema9)
    update_dash(2, "EMA " + str.tostring(lenE2), ema21)
    update_dash(3, "SMA " + str.tostring(len1), sma20)
    update_dash(4, "SMA " + str.tostring(len2), sma50)
    update_dash(5, "SMA " + str.tostring(len3), sma200)
    update_dash(6, "VWAP", vwapVal)
````
