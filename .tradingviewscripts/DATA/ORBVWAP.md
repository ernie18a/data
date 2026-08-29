<!-- tradingview-pine-id: PUB;3e315094bb4a44cda86484492b9f12da -->
<!-- tradingviewscripts-format: 1 -->
# ORB+VWAP

Source: https://www.tradingview.com/script/AiLiIDYa-ORB-VWAP/

## Description

ITSP ORB + VWAP — Opening Range Breakout with VWAP & Volume Confirmation
Overview
This indicator combines three of the most widely used intraday trading concepts into a single, non-repainting signal engine: Opening Range Breakout (ORB), session-anchored VWAP, and volume confirmation. It is built for NSE intraday trading but works on any liquid market with a defined session.
Most ORB tools only look at whether price broke the opening range. This one adds two additional filters — trend alignment via VWAP and participation via volume — so signals are less prone to false breakouts on thin, directionless moves.
How It Works
1.	Opening Range — the script automatically detects the first bar of each new regular trading session and builds a high/low range over a user-defined number of minutes (default 15). Once that window elapses, the range locks for the rest of the session.
2.	Session VWAP — a fresh volume-weighted average price is calculated from the first bar of each session, giving an accurate intraday fair-value reference rather than a rolling multi-day average.
3.	Volume Filter — breakout bars are checked against a multiple of the recent average volume, filtering out low-conviction breaks.
4.	Signal Logic — a long signal fires when price closes above the opening range high, is trading above session VWAP, and volume confirms. A short signal is the mirror condition. Each signal fires once per session per direction to avoid repeated alerts on choppy retests.
Key Features
•	Auto-resetting opening range box, visually plotted on the chart
•	Session-anchored VWAP line with configurable source
•	Optional volume confirmation filter (adjustable multiple and lookback)
•	Optional VWAP trend filter — can be disabled for raw ORB signals
•	ATR-based stop-loss and target labels auto-printed on each signal
•	Configurable info table (position, on/off) showing live ORB status, levels, and VWAP bias
•	Background tint reflecting current VWAP bias
•	Built-in alert conditions for both breakout directions, ready for webhook/Telegram/automation integration
How to Use
•	Works best on 5-minute or 15-minute charts for liquid stocks and index futures.
•	Set your chart session to Regular Trading Hours for correct daily resets.
•	Adjust the Opening Range window (default 15 minutes) to match your market's typical volatility — some traders prefer 30 minutes for less noise.
•	Use the VWAP and Volume filters as confluence checks; disabling both reduces this to a pure ORB breakout tool.
•	ATR stop/target labels are a starting reference, not a substitute for your own risk management.
Settings
•	Opening Range Minutes
•	VWAP source and on/off filter
•	Volume MA length and confirmation multiple
•	ATR length, stop multiple, target multiple
•	Info table visibility and position (9 placement options)
•	Signal color customization
Alerts
Two alert conditions are built in — Long ORB Breakout and Short ORB Breakdown — both suitable for webhook-based automation to Telegram, Discord, or other delivery channels.
Notes
•	Non-repainting: all breakout and VWAP calculations use only confirmed price/volume data at the time each bar closes.
•	This is a discretionary decision-support tool, not a standalone trading system. Always combine with your own risk management and market context.
Disclaimer
This script is for educational and informational purposes only and does not constitute financial advice. Trading involves substantial risk of loss. Past performance of any strategy or signal does not guarantee future results. Use at your own risk and always backtest/forward-test before live deployment.

---

## Source Code

````pine
//@version=6
indicator("ORB+VWAP", shorttitle="ORBV", overlay=true, max_lines_count=50, max_labels_count=50)

// ============================================================================
// ITSP v6 - Intraday ORB + VWAP Combo Indicator
// Session-based Opening Range Breakout with VWAP trend filter
// Built for NSE 500 universe intraday trading (5min/15min charts)
// ============================================================================

// ---------------- Inputs ----------------
grp_orb = "Opening Range"
orMinutes    = input.int(15, "Opening Range Minutes", minval=1, maxval=120, group=grp_orb)
sessionStart = input.session("0915-0930", "NSE Session Start Window", group=grp_orb, tooltip="Set end time = start + OR Minutes")

grp_vwap = "VWAP Filter"
useVwapFilter = input.bool(true, "Require VWAP Alignment for Signals", group=grp_vwap)
vwapSrc       = input.source(hlc3, "VWAP Source", group=grp_vwap)

grp_vol = "Volume Confirmation"
useVolFilter = input.bool(true, "Require Volume Confirmation", group=grp_vol)
volMaLen     = input.int(20, "Volume MA Length", minval=1, group=grp_vol)
volMultiple  = input.float(1.2, "Min Volume vs Avg (x)", minval=0.5, step=0.1, group=grp_vol)

grp_risk = "Risk / Targets"
useAtrStop = input.bool(true, "Show ATR-based Stop/Target", group=grp_risk)
atrLen     = input.int(14, "ATR Length", minval=1, group=grp_risk)
atrStopMul = input.float(1.0, "Stop = ATR x", minval=0.1, step=0.1, group=grp_risk)
atrTgtMul  = input.float(2.0, "Target = ATR x", minval=0.1, step=0.1, group=grp_risk)

grp_style = "Style"
showOrbBox   = input.bool(true, "Show Opening Range Box", group=grp_style)
showVwapLine = input.bool(true, "Show VWAP Line", group=grp_style)
colLong      = input.color(color.new(color.teal, 0), "Long Signal Color", group=grp_style)
colShort     = input.color(color.new(color.maroon, 0), "Short Signal Color", group=grp_style)

grp_table = "Info Table"
showInfoTable = input.bool(true, "Show Info Table", group=grp_table)
tablePosInput = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grp_table)

tablePos = tablePosInput == "Top Left" ? position.top_left :
     tablePosInput == "Top Center" ? position.top_center :
     tablePosInput == "Top Right" ? position.top_right :
     tablePosInput == "Middle Left" ? position.middle_left :
     tablePosInput == "Middle Center" ? position.middle_center :
     tablePosInput == "Middle Right" ? position.middle_right :
     tablePosInput == "Bottom Left" ? position.bottom_left :
     tablePosInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

// ---------------- New Session Detection ----------------
// NOTE: We use session.isfirstbar_regular (not an edge-detect on session.ismarket).
// Most intraday charts hide non-market bars entirely, so session.ismarket stays
// true continuously with no gap to detect a "new day" - which caused ORB/VWAP
// to lock once on the very first loaded bar and never reset again.
newSession = session.isfirstbar_regular
var float orHigh = na
var float orLow = na
var bool  orLocked = false
var int   orStartBar = na

inOrbWindow = session.ismarket and not orLocked

if newSession
    orHigh := high
    orLow := low
    orLocked := false
    orStartBar := bar_index

if inOrbWindow and not newSession
    orHigh := math.max(orHigh, high)
    orLow := math.min(orLow, low)

// Lock the range once orMinutes have elapsed since session start
barsSinceStart = bar_index - orStartBar
timeframeMinutes = timeframe.in_seconds(timeframe.period) / 60
barsNeeded = math.max(1, math.round(orMinutes / timeframeMinutes))

if inOrbWindow and barsSinceStart >= barsNeeded
    orLocked := true

// ---------------- VWAP (session-anchored) ----------------
var float cumVolSrc = 0.0
var float cumVol = 0.0

if newSession
    cumVolSrc := 0.0
    cumVol := 0.0

cumVolSrc := cumVolSrc + vwapSrc * volume
cumVol := cumVol + volume
sessionVwap = cumVol > 0 ? cumVolSrc / cumVol : na

// ---------------- Volume Confirmation ----------------
volAvg = ta.sma(volume, volMaLen)
volOk = not useVolFilter or volume >= volAvg * volMultiple

// ---------------- ATR for stop/target ----------------
atrVal = ta.atr(atrLen)

// ---------------- Breakout Logic ----------------
aboveVwap = close > sessionVwap
belowVwap = close < sessionVwap
vwapOkLong = not useVwapFilter or aboveVwap
vwapOkShort = not useVwapFilter or belowVwap

var bool longFired = false
var bool shortFired = false

if newSession
    longFired := false
    shortFired := false

longBreak = orLocked and not longFired and ta.crossover(close, orHigh) and vwapOkLong and volOk
shortBreak = orLocked and not shortFired and ta.crossunder(close, orLow) and vwapOkShort and volOk

if longBreak
    longFired := true
if shortBreak
    shortFired := true

// ---------------- Plotting: ORB Box ----------------
var box orbBox = na
if newSession
    if not na(orbBox)
        box.delete(orbBox)
    orbBox := na

if orLocked and na(orbBox) and showOrbBox
    orbBox := box.new(orStartBar, orHigh, bar_index, orLow, border_color=color.new(color.gray, 40), bgcolor=color.new(color.gray, 90), extend=extend.right)

if orLocked and not na(orbBox) and showOrbBox
    box.set_top(orbBox, orHigh)
    box.set_bottom(orbBox, orLow)
    box.set_right(orbBox, bar_index)

plot(orLocked and showOrbBox ? orHigh : na, "ORB High", color=color.new(color.blue, 0), style=plot.style_linebr, linewidth=1)
plot(orLocked and showOrbBox ? orLow : na, "ORB Low", color=color.new(color.orange, 0), style=plot.style_linebr, linewidth=1)

plot(showVwapLine ? sessionVwap : na, "Session VWAP", color=color.new(color.purple, 0), linewidth=2)

// ---------------- Signal Markers ----------------
plotshape(longBreak, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=colLong, size=size.small, text="ORB+")
plotshape(shortBreak, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=colShort, size=size.small, text="ORB-")

// ---------------- Stop/Target Labels ----------------
if longBreak and useAtrStop
    stopLvl = close - atrVal * atrStopMul
    tgtLvl = close + atrVal * atrTgtMul
    label.new(bar_index, low - atrVal * 0.5, "SL:" + str.tostring(stopLvl, format.mintick) + "\nTGT:" + str.tostring(tgtLvl, format.mintick), style=label.style_label_up, color=color.new(colLong, 70), textcolor=color.white, size=size.small)

if shortBreak and useAtrStop
    stopLvl = close + atrVal * atrStopMul
    tgtLvl = close - atrVal * atrTgtMul
    label.new(bar_index, high + atrVal * 0.5, "SL:" + str.tostring(stopLvl, format.mintick) + "\nTGT:" + str.tostring(tgtLvl, format.mintick), style=label.style_label_down, color=color.new(colShort, 70), textcolor=color.white, size=size.small)

// ---------------- Background Bias Tint ----------------
bgcolor(useVwapFilter and aboveVwap ? color.new(color.teal, 95) : useVwapFilter and belowVwap ? color.new(color.maroon, 95) : na, title="VWAP Bias")

// ---------------- Alerts ----------------
alertcondition(longBreak, title="ORB Long Breakout", message="ITSP: Long ORB breakout with VWAP+Volume confirmation")
alertcondition(shortBreak, title="ORB Short Breakdown", message="ITSP: Short ORB breakdown with VWAP+Volume confirmation")

// ---------------- Info Table ----------------
var table infoTbl = table.new(tablePos, 2, 4, bgcolor=color.new(color.black, 80), border_width=1)
if barstate.islast and showInfoTable
    table.cell(infoTbl, 0, 0, "ORB Status", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 0, orLocked ? "Locked" : "Building", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 0, 1, "ORB High", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 1, str.tostring(orHigh, format.mintick), text_color=color.blue, text_size=size.small)
    table.cell(infoTbl, 0, 2, "ORB Low", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 2, str.tostring(orLow, format.mintick), text_color=color.orange, text_size=size.small)
    table.cell(infoTbl, 0, 3, "VWAP Bias", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 3, aboveVwap ? "Bullish" : belowVwap ? "Bearish" : "Flat", text_color=aboveVwap ? color.teal : belowVwap ? color.maroon : color.gray, text_size=size.small)
````
