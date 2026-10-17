#  Trend Setup - 3 EMA + RSI Dashboard

- url: https://www.tradingview.com/script/o4V9YBtW/
- type: indicator
- pine_id: PUB;34d16cb784464cd9b5b9e6c32cace19c
- version: 1.0

## Description

📊 TREND SETUP — EMAs + Live RSI Dashboard

A clean, all-in-one trend tool combining the 3 most-used EMAs with a 
real-time RSI dashboard — no need to load multiple indicators separately.

✅ EMA 50 / 100 / 200 — fully configurable (period, source, color, on/off)
✅ Live RSI Dashboard — shows current RSI value, overbought/oversold 
   levels, and a real-time status alert, displayed in a sleek table 
   instead of a cluttered separate pane

🎯 WHY THIS COMBO
EMAs give you the big-picture trend direction, while the RSI dashboard 
tells you instantly if price is stretched (overbought/oversold) — 
without needing a second indicator slot, perfect if you're on a free 
TradingView plan and want to save your indicator limit.

🔧 FULLY CONFIGURABLE
— Toggle each EMA on/off independently
— Set your own RSI period and overbought/oversold levels
— Adjust dashboard text size

💡 HOW IT WORKS
The RSI dashboard updates live as new candles form, showing:
— Current RSI value
— Upper/Lower band levels
— Alert status (Overbought ↑ / Oversold ↓ / Neutral →)

💬 Got a suggestion for the next version? Drop a comment below — 
I'm actively building more setups based on community feedback.

If this helped your charts, a like goes a long way 🙏

## Source Code

````pine
//@version=6
indicator("[Wolfi_22] Trend Setup — EMA 50/100/200 + RSI Dashboard", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// EMA 1
// ============================================================
g_ema1 = "EMA 1"
showEma1 = input.bool(true, "Show EMA 1", group=g_ema1)
ema1Len = input.int(50, "Period", group=g_ema1)
ema1Color = input.color(color.yellow, "Color", group=g_ema1)
ema1Src = input.source(close, "Source", group=g_ema1)

ema1 = ta.ema(ema1Src, ema1Len)
plot(showEma1 ? ema1 : na, "EMA 1", color=ema1Color, linewidth=2)

// ============================================================
// EMA 2
// ============================================================
g_ema2 = "EMA 2"
showEma2 = input.bool(true, "Show EMA 2", group=g_ema2)
ema2Len = input.int(100, "Period", group=g_ema2)
ema2Color = input.color(color.orange, "Color", group=g_ema2)
ema2Src = input.source(close, "Source", group=g_ema2)

ema2 = ta.ema(ema2Src, ema2Len)
plot(showEma2 ? ema2 : na, "EMA 2", color=ema2Color, linewidth=2)

// ============================================================
// EMA 3
// ============================================================
g_ema3 = "EMA 3"
showEma3 = input.bool(true, "Show EMA 3", group=g_ema3)
ema3Len = input.int(200, "Period", group=g_ema3)
ema3Color = input.color(color.red, "Color", group=g_ema3)
ema3Src = input.source(close, "Source", group=g_ema3)

ema3 = ta.ema(ema3Src, ema3Len)
plot(showEma3 ? ema3 : na, "EMA 3", color=ema3Color, linewidth=2)

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

rsiState = rsiVal >= rsiOB ? "SOBRECOMPRA" : rsiVal <= rsiOS ? "SOBREVENTA" : "NEUTRAL"
rsiSemaforo = rsiVal >= rsiOB ? "🔴" : rsiVal <= rsiOS ? "🟢" : "⚪"
rsiStateColor = rsiVal >= rsiOB ? color.new(color.red, 0) : rsiVal <= rsiOS ? color.new(color.green, 0) : color.new(color.gray, 0)

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
    // Título
    table.merge_cells(rsiDash, 0, 0, 3, 0)
    table.cell(rsiDash, 0, 0, "📊 RSI LIVE", bgcolor=colTitleBg, text_color=colAccent, text_size=tblTextSize, text_halign=text.align_center)

    // Header de columnas
    table.cell(rsiDash, 0, 1, "Parameter", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 1, "Value", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)
    table.cell(rsiDash, 2, 1, "Live Level", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)
    table.cell(rsiDash, 3, 1, "Alert", bgcolor=colHeaderBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)

    // Fila Period
    table.cell(rsiDash, 0, 2, "Period", bgcolor=colRowBg1, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 2, str.tostring(rsiLen), bgcolor=colRowBg1, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)
    table.merge_cells(rsiDash, 2, 2, 2, 4)
    table.cell(rsiDash, 2, 2, str.tostring(rsiVal, "#.##"), bgcolor=color.new(#0D1B26, 0), text_color=colAccent, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(rsiDash, 3, 2, 3, 4)
    table.cell(rsiDash, 3, 2, rsiSemaforo + "\n" + alertText, bgcolor=alertBg, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_center)

    // Fila Upper Band
    table.cell(rsiDash, 0, 3, "Upper Band", bgcolor=colRowBg2, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 3, str.tostring(rsiOB), bgcolor=colRowBg2, text_color=color.new(color.red, 0), text_size=tblTextSize, text_halign=text.align_center)

    // Fila Lower Band
    table.cell(rsiDash, 0, 4, "Lower Band", bgcolor=colRowBg1, text_color=colTextWhite, text_size=tblTextSize, text_halign=text.align_left)
    table.cell(rsiDash, 1, 4, str.tostring(rsiOS), bgcolor=colRowBg1, text_color=color.new(color.green, 0), text_size=tblTextSize, text_halign=text.align_center)
````
