#  Reversion Setup - Bollinger Bands + RSI Live Dashboard

- url: https://www.tradingview.com/script/TCxK0Zhp/
- type: indicator
- pine_id: PUB;3a9bd16d4e0747dda9bd2f4f8e922473
- version: 1.0

## Description

📊 REVERSION SETUP — Bollinger Bands + Live RSI Dashboard

A focused mean-reversion tool combining Bollinger Bands with a real-time 
RSI dashboard — built to spot potential reversal zones without cluttering 
your chart or burning extra indicator slots.

✅ Bollinger Bands — fully configurable (period, deviation, source, color)
✅ Live RSI Dashboard — current RSI value, overbought/oversold levels, 
   and real-time alert status, shown in a clean table instead of a 
   separate pane

🎯 WHY THIS COMBO
Bollinger Bands highlight when price stretches to a statistical extreme, 
while the RSI dashboard confirms whether momentum actually backs up that 
move. When price tags a band AND RSI flags overbought/oversold at the 
same time, that's your reversion signal — two confirmations, one chart.

🔧 FULLY CONFIGURABLE
— Adjust Bollinger period, deviation, source, and color
— Set your own RSI period and overbought/oversold levels
— Adjust dashboard text size

💡 HOW IT WORKS
The RSI dashboard updates live as new candles form, showing:
— Current RSI value
— Upper/Lower band levels
— Alert status (Overbought ↑ / Oversold ↓ / Neutral →)

🔗 PAIRS WELL WITH
Check out my Trend Setup (EMA 50/100/200 + RSI Dashboard) for the 
trend-following counterpart to this mean-reversion tool.

💬 Suggestions for the next setup? Drop a comment below — more tools 
coming based on community feedback.

If this helped your charts, a like goes a long way 🙏

## Source Code

````pine
//@version=6
indicator("[Wolfi_22] Reversion Setup - Bollinger Bands + RSI Live Dashboard", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// BOLLINGER BANDS
// ============================================================
g_bb = "Bollinger Bands"
showBB = input.bool(true, "Show Bollinger Bands", group=g_bb)
bbLen = input.int(20, "Period", group=g_bb)
bbMult = input.float(2.0, "Standard Deviation", step=0.1, group=g_bb)
bbSrc = input.source(close, "Source", group=g_bb)
bbColor = input.color(color.blue, "Color", group=g_bb)

bbBasis = ta.sma(bbSrc, bbLen)
bbDev = bbMult * ta.stdev(bbSrc, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

bbBasisPlot = plot(showBB ? bbBasis : na, "BB Basis", color=color.new(bbColor, 40), linewidth=1)
bbUpperPlot = plot(showBB ? bbUpper : na, "BB Upper", color=bbColor, linewidth=1)
bbLowerPlot = plot(showBB ? bbLower : na, "BB Lower", color=bbColor, linewidth=1)
fill(bbUpperPlot, bbLowerPlot, color=showBB ? color.new(bbColor, 90) : na, title="BB Fill")

// ============================================================
// RSI DASHBOARD
// ============================================================
g_rsi = "RSI Dashboard"
showRsiDash = input.bool(true, "Show RSI dashboard", group=g_rsi)
rsiLen = input.int(14, "RSI Period", group=g_rsi)
rsiSrc = input.source(close, "Source", group=g_rsi)
rsiOB = input.int(70, "Overbought Level", group=g_rsi)
rsiOS = input.int(30, "Oversold Level", group=g_rsi)
tblSize = input.string("normal", "Text Size", options=["small", "normal", "large"], group=g_rsi)

rsiVal = ta.rsi(rsiSrc, rsiLen)

rsiState = rsiVal >= rsiOB ? "OVERBOUGHT" : rsiVal <= rsiOS ? "OVERSOLD" : "NEUTRAL"
rsiSemaforo = rsiVal >= rsiOB ? "🔴" : rsiVal <= rsiOS ? "🟢" : "⚪"

tblTextSize = tblSize == "small" ? size.small : tblSize == "large" ? size.large : size.normal

// Paleta estilo "Market Structure Dashboard" (navy + cyan + acentos)
colTitleBg = color.new(#0D1B2A, 0)
colHeaderBg = color.new(#1B3A4B, 0)
colRowBg1 = color.new(#13242F, 0)
colRowBg2 = color.new(#0D1B26, 0)
colTextWhite = color.new(color.white, 0)
colAccent = color.new(#2EC4B6, 0)

alertText = rsiVal >= rsiOB ? "Overbought ↑" : rsiVal <= rsiOS ? "Oversold ↓" : "Neutral →"
alertBg = rsiVal >= rsiOB ? color.new(color.red, 20) : rsiVal <= rsiOS ? color.new(color.green, 20) : color.new(#2C3E50, 0)

var table rsiDash = table.new(position.bottom_right, 4, 5, border_width=2, frame_color=colAccent, frame_width=2)

if barstate.islast and showRsiDash
    // Title
    table.merge_cells(rsiDash, 0, 0, 3, 0)
    table.cell(rsiDash, 0, 0, "📊 RSI LIVE", bgcolor=colTitleBg, text_color=colAccent, text_size=tblTextSize, text_halign=text.align_center)

    // Column headers
    table.cell(rsiDash, 0, 1, "Parameter", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 1, "Value", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)
    table.cell(rsiDash, 2, 1, "Live Level", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)
    table.cell(rsiDash, 3, 1, "Alert", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)

    // Period row
    table.cell(rsiDash, 0, 2, "Period", bgcolor=colRowBg1, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 2, str.tostring(rsiLen), bgcolor=colRowBg1, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)
    table.merge_cells(rsiDash, 2, 2, 2, 4)
    table.cell(rsiDash, 2, 2, str.tostring(rsiVal, "#.##"), bgcolor=color.new(#0D1B26, 0), text_color=colAccent, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(rsiDash, 3, 2, 3, 4)
    table.cell(rsiDash, 3, 2, rsiSemaforo + "\n" + alertText, bgcolor=alertBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)

    // Upper Band row
    table.cell(rsiDash, 0, 3, "Upper Band", bgcolor=colRowBg2, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 3, str.tostring(rsiOB), bgcolor=colRowBg2, text_color=color.new(color.red, 0), text_size=tblTextSize, text_halign=text.align_center)

    // Lower Band row
    table.cell(rsiDash, 0, 4, "Lower Band", bgcolor=colRowBg1, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 4, str.tostring(rsiOS), bgcolor=colRowBg1, text_color=color.new(color.green, 0), text_size=tblTextSize, text_halign=text.align_center)
````
