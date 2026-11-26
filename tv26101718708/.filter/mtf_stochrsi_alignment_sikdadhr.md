# MTF StochRSI Alignment

- url: https://www.tradingview.com/script/sikDaDhr-MTF-StochRSI-Alignment/
- type: indicator
- pine_id: PUB;b56b34296386437fb303eef6683936e1
- version: 1.0

## Description

Multi-Timeframe StochRSI Alignment

This indicator monitors the Stochastic RSI across three user-defined timeframes simultaneously and alerts you when they all align in the same direction — a classic sign of a strong, multi-timeframe overbought or oversold condition.

How it works

The script calculates Stochastic RSI independently on each of the three selected timeframes (default: 1-minute, 15-minute, and 1-hour) rather than approximating it from the chart timeframe. Each timeframe is then classified as:

- OB — Overbought (K ≥ 80, adjustable)
- OS — Oversold (K ≤ 20, adjustable)
- N — Neutral (in between)

A clean table in the corner of your chart displays all three timeframes and their current status at a glance, along with an overall **Signal** row:

- All three Overbought → SELL (box shades red)
- All three Oversold → BUY (box shades green)
- Mixed → WAIT (neutral shading)

Features

- Fully customizable timeframes — not locked to 1m/15m/1h, set any three you like
- Adjustable RSI length, Stochastic length, K/D smoothing, and OB/OS thresholds
- Configurable table position (all four corners) and text size
- Built-in alert conditions for both aligned Buy and aligned Sell signals, so you don't have to watch the chart

How to use it

This tool is designed to help you spot moments where short-term, medium-term, and longer-term momentum are all stretched in the same direction — often a precursor to a pullback or reversal. It works well as a confluence filter alongside your existing entry/exit strategy, rather than as a standalone signal generator.

Note: Multi-timeframe indicators reference higher-timeframe data that can update intra-bar. Signals on the lowest configured timeframe are most reliable once that candle has closed. This script is for informational purposes only and does not constitute financial advice — always combine it with your own risk management and analysis.

## Source Code

````pine
//@version=6
indicator("MTF StochRSI Alignment", overlay=true, max_labels_count=500)

// ───────────────────────────── Inputs ─────────────────────────────
grp_tf = "Timeframes"
tf1 = input.timeframe("1",  "Timeframe 1", group=grp_tf)
tf2 = input.timeframe("15", "Timeframe 2", group=grp_tf)
tf3 = input.timeframe("60", "Timeframe 3", group=grp_tf)

grp_stoch = "Stochastic RSI Settings"
rsiLength   = input.int(14, "RSI Length", group=grp_stoch)
stochLength = input.int(14, "Stochastic Length", group=grp_stoch)
smoothK     = input.int(3,  "K Smoothing", group=grp_stoch)
smoothD     = input.int(3,  "D Smoothing", group=grp_stoch)
obLevel     = input.int(80, "Overbought Level", group=grp_stoch)
osLevel     = input.int(20, "Oversold Level", group=grp_stoch)

grp_disp = "Display"
tablePos = input.string("Bottom Right", "Table Position",
     options=["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group=grp_disp)
textSize = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=grp_disp)
showAlerts = input.bool(true, "Enable Alerts", group=grp_disp)

// ───────────────────────────── Core calc ─────────────────────────────
f_stochRsi(rsiLen, stochLen, kSmooth, dSmooth) =>
    rsiVal  = ta.rsi(close, rsiLen)
    stochVal = ta.stoch(rsiVal, rsiVal, rsiVal, stochLen)
    k = ta.sma(stochVal, kSmooth)
    d = ta.sma(k, dSmooth)
    [k, d]

[k1, _d1] = request.security(syminfo.tickerid, tf1, f_stochRsi(rsiLength, stochLength, smoothK, smoothD), lookahead=barmerge.lookahead_off)
[k2, _d2] = request.security(syminfo.tickerid, tf2, f_stochRsi(rsiLength, stochLength, smoothK, smoothD), lookahead=barmerge.lookahead_off)
[k3, _d3] = request.security(syminfo.tickerid, tf3, f_stochRsi(rsiLength, stochLength, smoothK, smoothD), lookahead=barmerge.lookahead_off)

f_status(k) =>
    k >= obLevel ? "OB" : k <= osLevel ? "OS" : "N"

status1 = f_status(k1)
status2 = f_status(k2)
status3 = f_status(k3)

allOB = status1 == "OB" and status2 == "OB" and status3 == "OB"
allOS = status1 == "OS" and status2 == "OS" and status3 == "OS"

// ───────────────────────────── Table setup ─────────────────────────────
tablePosition = tablePos == "Bottom Right" ? position.bottom_right :
     tablePos == "Bottom Left" ? position.bottom_left :
     tablePos == "Top Right" ? position.top_right : position.top_left

cellTextSize = textSize == "Small" ? size.small : textSize == "Large" ? size.large : size.normal

var table infoTable = table.new(tablePosition, 2, 5, border_width=1, border_color=color.gray, frame_width=1, frame_color=color.gray)

f_cellColor(stat, alignedColor) =>
    color result = alignedColor
    result

if barstate.islast
    // Overall signal background
    color signalBg = allOB ? color.new(color.red, 60) : allOS ? color.new(color.green, 60) : color.new(color.gray, 85)
    string signalText = allOB ? "SELL" : allOS ? "BUY" : "WAIT"

    // Header row
    table.cell(infoTable, 0, 0, "Timeframe", bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=cellTextSize)
    table.cell(infoTable, 1, 0, "StochRSI", bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=cellTextSize)

    // Row per timeframe
    color row1Color = status1 == "OB" ? color.new(color.red, 70) : status1 == "OS" ? color.new(color.green, 70) : color.new(color.gray, 90)
    color row2Color = status2 == "OB" ? color.new(color.red, 70) : status2 == "OS" ? color.new(color.green, 70) : color.new(color.gray, 90)
    color row3Color = status3 == "OB" ? color.new(color.red, 70) : status3 == "OS" ? color.new(color.green, 70) : color.new(color.gray, 90)

    table.cell(infoTable, 0, 1, tf1, bgcolor=row1Color, text_color=color.white, text_size=cellTextSize)
    table.cell(infoTable, 1, 1, status1, bgcolor=row1Color, text_color=color.white, text_size=cellTextSize)

    table.cell(infoTable, 0, 2, tf2, bgcolor=row2Color, text_color=color.white, text_size=cellTextSize)
    table.cell(infoTable, 1, 2, status2, bgcolor=row2Color, text_color=color.white, text_size=cellTextSize)

    table.cell(infoTable, 0, 3, tf3, bgcolor=row3Color, text_color=color.white, text_size=cellTextSize)
    table.cell(infoTable, 1, 3, status3, bgcolor=row3Color, text_color=color.white, text_size=cellTextSize)

    // Overall signal row (merged look via two cells same color)
    table.cell(infoTable, 0, 4, "Signal", bgcolor=signalBg, text_color=color.white, text_size=cellTextSize)
    table.cell(infoTable, 1, 4, signalText, bgcolor=signalBg, text_color=color.white, text_size=cellTextSize)

// ───────────────────────────── Alerts ─────────────────────────────
alertcondition(allOB, title="All Timeframes Overbought (Sell)", message="StochRSI aligned Overbought on {{ticker}} — SELL signal")
alertcondition(allOS, title="All Timeframes Oversold (Buy)", message="StochRSI aligned Oversold on {{ticker}} — BUY signal")

if showAlerts and allOB and not allOB[1]
    alert("StochRSI aligned Overbought — SELL signal on " + syminfo.ticker, alert.freq_once_per_bar_close)
if showAlerts and allOS and not allOS[1]
    alert("StochRSI aligned Oversold — BUY signal on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
