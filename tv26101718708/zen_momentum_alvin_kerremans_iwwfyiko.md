# Zen Momentum - Alvin Kerremans

- url: https://www.tradingview.com/script/IwwFYIkO-Zen-Momentum-Alvin-Kerremans/
- type: indicator
- pine_id: PUB;7ffce27e3a614e6aa11d30b1d7a29582
- version: 1.0

## Description

This indicator, Zen Momentum, is a momentum-based strategy designed to capture trend continuations using a combination of RSI levels, EMA alignment, and Fair Value Gaps (FVG).

Core Strategy Logic
Momentum Filter: Entries are only considered when the RSI is in high-momentum zones (above 65 or below 35).

Trend Confirmation: The script checks that the EMAs are clearly pointing in the direction of the trade to ensure trend alignment.

Entry Trigger: A Fair Value Gap (FVG) must be printed on the chart to validate the setup.

Execution: Traders can utilize either a Market order upon FVG confirmation or a Limit order placed specifically at the FVG level for optimized entry.

## Source Code

````pine
//@version=5
indicator("Zen Momentum — RSI + EMA + FVG (1m)", overlay=true, max_labels_count=500)

// ─── Inputs ───────────────────────────────────────────────────────────────
rsiLen      = input.int(14,  "RSI length", minval=2)
emaFastLen  = input.int(10,  "Fast EMA",   minval=1)
emaSlowLen  = input.int(20,  "Slow EMA",   minval=1)
rsiLongTh   = input.float(65, "RSI long threshold")
rsiShortTh  = input.float(35, "RSI short threshold")
rr          = input.float(2.0, "Reward:Risk", step=0.1, minval=0.1)
showFVG     = input.bool(true, "Shade FVG zones")
showLevels  = input.bool(true, "Draw entry/SL/TP lines")

// ─── Indicators ───────────────────────────────────────────────────────────
rsi     = ta.rsi(close, rsiLen)
emaF    = ta.ema(close, emaFastLen)
emaS    = ta.ema(close, emaSlowLen)

plot(emaF, "EMA10", color=color.new(color.yellow, 0), linewidth=2)
plot(emaS, "EMA20", color=color.new(color.aqua,   0), linewidth=2)

// ─── EMA alignment + direction + spread widening ─────────────────────────
spreadNow  = emaF - emaS
spreadPrev = emaF[1] - emaS[1]
emaUp      = emaF > emaF[1] and emaS > emaS[1]
emaDn      = emaF < emaF[1] and emaS < emaS[1]
expandUp   = spreadNow > spreadPrev and spreadNow > 0
expandDn   = spreadNow < spreadPrev and spreadNow < 0

longAlign  = close > emaF and close > emaS and emaUp and expandUp
shortAlign = close < emaF and close < emaS and emaDn and expandDn

// ─── FVG detection (3-bar gap between bar[-2] and bar[0]) ─────────────────
// bull at disp: high[2] < low[0]     bear at disp: low[2]  > high[0]
bullFVGdisp = high[2] < low[0]
bearFVGdisp = low[2]  > high[0]

// FVG that completed on the PREVIOUS bar  (so candle[n+1] is this bar)
bullFVGprev = high[3] < low[1]
bearFVGprev = low[3]  > high[1]

// SL reference = candle A (OLDEST) low/high
bullFVGdispSL = low[2]   // candle A of FVG ending at disp (A=bar-2, B=bar-1, C=bar-0)
bearFVGdispSL = high[2]
bullFVGprevSL = low[3]   // candle A of FVG ending at bar-1 (A=bar-3, B=bar-2, C=bar-1)
bearFVGprevSL = high[3]

// ─── Scenario A (Catalyst): RSI cross on the displacement bar ────────────
rsiCrossUp   = rsi[1] <= rsiLongTh  and rsi > rsiLongTh
rsiCrossDown = rsi[1] >= rsiShortTh and rsi < rsiShortTh

longCatalystA  = bullFVGdisp and rsiCrossUp
longCatalystB  = bullFVGprev and rsiCrossUp       // FVG at n, cross at n+1
shortCatalystA = bearFVGdisp and rsiCrossDown
shortCatalystB = bearFVGprev and rsiCrossDown

// ─── Scenario B (Runaway, RELAXED): RSI > threshold on disp bar only ─────
longRunaway  = bullFVGdisp and rsi > rsiLongTh
shortRunaway = bearFVGdisp and rsi < rsiShortTh

// ─── Combined signals ─────────────────────────────────────────────────────
longRaw   = longAlign  and (longCatalystA  or longCatalystB  or longRunaway)
shortRaw  = shortAlign and (shortCatalystA or shortCatalystB or shortRunaway)

// Pick the right SL for the winning scenario
longSL  = longCatalystB ? bullFVGprevSL : bullFVGdispSL
shortSL = shortCatalystB ? bearFVGprevSL : bearFVGdispSL

// LIMIT entry = near edge of the FVG that caused the displacement (candle C)
// bull FVG disp-ended: C = bar 0 -> low[0]    prev-ended: C = bar 1 -> low[1]
// bear FVG disp-ended: C = bar 0 -> high[0]   prev-ended: C = bar 1 -> high[1]
longEntry  = longCatalystB ? low[1]  : low[0]
shortEntry = shortCatalystB ? high[1] : high[0]
longRisk   = longEntry  - longSL
shortRisk  = shortSL    - shortEntry

longSetup  = longRaw  and longRisk  > 0
shortSetup = shortRaw and shortRisk > 0

longTP  = longEntry  + rr * longRisk
shortTP = shortEntry - rr * shortRisk

// ─── Plot signals on chart ────────────────────────────────────────────────
// Plot BUY/SELL at the LIMIT price inside the FVG (not above/below next bar)
plotshape(longSetup  ? longEntry  : na, title="BUY",  style=shape.triangleup,
          location=location.absolute, color=color.new(color.lime, 0),
          size=size.small, text="BUY")
plotshape(shortSetup ? shortEntry : na, title="SELL", style=shape.triangledown,
          location=location.absolute, color=color.new(color.red,  0),
          size=size.small, text="SELL")

// ─── FVG shading (visual aid) ─────────────────────────────────────────────
var box bullBox = na
var box bearBox = na
if showFVG and bullFVGdisp
    bullBox := box.new(bar_index[2], high[2], bar_index, low[0],
                       bgcolor=color.new(color.green, 80), border_color=color.new(color.green, 50))
if showFVG and bearFVGdisp
    bearBox := box.new(bar_index[2], low[2], bar_index, high[0],
                       bgcolor=color.new(color.red, 80), border_color=color.new(color.red, 50))

// ─── Entry / SL / TP levels drawn on signal ──────────────────────────────
if showLevels and longSetup
    line.new(bar_index, longEntry, bar_index + 20, longEntry, color=color.blue,  width=1, extend=extend.none)
    line.new(bar_index, longSL,    bar_index + 20, longSL,    color=color.red,   width=1, extend=extend.none)
    line.new(bar_index, longTP,    bar_index + 20, longTP,    color=color.green, width=1, extend=extend.none)
    label.new(bar_index, longTP, "TP " + str.tostring(longTP, "#.##"),
              style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny)
    label.new(bar_index, longSL, "SL " + str.tostring(longSL, "#.##"),
              style=label.style_label_left, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny)

if showLevels and shortSetup
    line.new(bar_index, shortEntry, bar_index + 20, shortEntry, color=color.blue,  width=1, extend=extend.none)
    line.new(bar_index, shortSL,    bar_index + 20, shortSL,    color=color.red,   width=1, extend=extend.none)
    line.new(bar_index, shortTP,    bar_index + 20, shortTP,    color=color.green, width=1, extend=extend.none)
    label.new(bar_index, shortTP, "TP " + str.tostring(shortTP, "#.##"),
              style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny)
    label.new(bar_index, shortSL, "SL " + str.tostring(shortSL, "#.##"),
              style=label.style_label_left, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny)

// ─── Status table (top-right) ────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast
    table.cell(t, 0, 0, "RSI",        bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, str.tostring(rsi, "#.##"),      bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 1, "EMA10/20",   bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(emaF, "#.##") + " / " + str.tostring(emaS, "#.##"), bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "Spread",     bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(spreadNow, "+#.##"), bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "EMA dir",    bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    dirTxt = emaUp ? "UP" : emaDn ? "DOWN" : "FLAT"
    table.cell(t, 1, 3, dirTxt,       bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 4, "FVG",        bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    fvgTxt = bullFVGdisp ? "BULL" : bearFVGdisp ? "BEAR" : "-"
    table.cell(t, 1, 4, fvgTxt,       bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 5, "Setup",      bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)
    setupTxt = longSetup ? "LONG" : shortSetup ? "SHORT" : "none"
    table.cell(t, 1, 5, setupTxt,     bgcolor=color.new(color.black, 70), text_color=color.white, text_size=size.small)

// ─── Alerts ──────────────────────────────────────────────────────────────
alertcondition(longSetup,  title="Zen Momentum — BUY",
     message='{"action":"BUY","symbol":"{{ticker}}","price":"{{close}}","sl":"{{plot_0}}","tp":"{{plot_1}}","tf":"{{interval}}"}')
alertcondition(shortSetup, title="Zen Momentum — SELL",
     message='{"action":"SELL","symbol":"{{ticker}}","price":"{{close}}","sl":"{{plot_0}}","tp":"{{plot_1}}","tf":"{{interval}}"}')

// Simple human-readable alerts
alertcondition(longSetup,  title="Zen Momentum — BUY (simple)",
     message="BUY {{ticker}} @ {{close}} on {{interval}} — Zen Momentum")
alertcondition(shortSetup, title="Zen Momentum — SELL (simple)",
     message="SELL {{ticker}} @ {{close}} on {{interval}} — Zen Momentum")
````
