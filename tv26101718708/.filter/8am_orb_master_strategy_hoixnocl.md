# 8AM ORB Master Strategy

- url: https://www.tradingview.com/script/HOiXNOCL-8AM-ORB-Master-Strategy/
- type: indicator
- pine_id: PUB;6b0acb8c48424bf8a0066dd91f4f13cc
- version: 4.0

## Description

8AM ORB Master Strategy
This indicator automates the full 8AM Opening Range Breakout (ORB) strategy, built around a midpoint bounce and reversal setup. The opening range is defined by the 8:00–8:15 AM Eastern session, and the indicator handles everything from range detection to trade management levels — all plotted automatically on your chart.
How it works:
The indicator builds the ORB High, Low, and Midpoint from the first three 5-minute candles of the session. It then monitors for price to interact with the midpoint level and confirm a reversal in either direction. When a valid setup forms, it fires a Long or Short signal and marks all relevant levels instantly.
What gets plotted automatically:

ORB build box (8:00–8:15 window)
ORB High, Low, and Midpoint lines with price labels
Entry arrow with entry price
Stop loss line (ORB Low for longs / ORB High for shorts)
TP1, TP2, and TP3 at 1:1, 1:2, and 1:3 risk/reward
Live entry checklist panel (top-right corner)

Checklist panel includes:
ORB built confirmation, news filter status, midpoint bounce detection, reversal candle confirmation, direction clarity, and a manual reminder to confirm on the 1-minute and 3-minute charts.
Settings:

🚫 News filter toggle — manually disable all signals around high-impact news events
Adjustable bounce zone sensitivity
Toggle TP1/TP2/TP3 individually
Customizable line length and colors

Recommended use: Apply to a 5-minute chart with New York timezone. Use the 1-minute and 3-minute charts alongside this indicator for entry confirmation.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════╗
// ║      8AM ORB MASTER STRATEGY — Pine Script v6            ║
// ║  Logic Enhanced: 1 Trade/Day | Trend & Volume Filters    ║
// ╚══════════════════════════════════════════════════════════╝
//@version=6
indicator("8AM ORB Master Strategy", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=10)

// ═══════════════════════════════════════════════════════════════
// ░░  INPUTS (Visuals Unchanged)
// ═══════════════════════════════════════════════════════════════
var string G1 = "⚙️  Strategy"
newsOff    = input.bool(false, "🚫  News Filter — Disable All Signals", group=G1)
midZonePct = input.float(0.25, "Bounce Zone (% of ORB range)", minval=0.05, maxval=0.5, step=0.05, group=G1)

var string G2 = "📊  Display"
showTP1   = input.bool(true, "Show TP1  (1:1 R)",       group=G2)
showTP2   = input.bool(true, "Show TP2  (1:2 R)",       group=G2)
showTP3   = input.bool(true, "Show TP3  (1:3 R)",       group=G2)
showBox   = input.bool(true, "Show ORB Build Box",      group=G2)
showPanel = input.bool(true, "Show Checklist Panel",    group=G2)
extLen    = input.int(50,    "Level Line Length (bars)", minval=10, maxval=300, group=G2)

var string G3 = "🎨  Colors"
cLong  = input.color(#00c853, "Long",       group=G3)
cShort = input.color(#d50000, "Short",      group=G3)
cORB   = input.color(#ff9800, "ORB Levels", group=G3)
cSL    = input.color(#ef5350, "Stop Loss",  group=G3)
cTP1c  = input.color(#81c784, "TP1",        group=G3)
cTP2c  = input.color(#43a047, "TP2",        group=G3)
cTP3c  = input.color(#1b5e20, "TP3",        group=G3)

// ═══════════════════════════════════════════════════════════════
// ░░  BEHIND-THE-SCENES FILTERS (PRO LOGIC)
// ═══════════════════════════════════════════════════════════════
ema200 = ta.ema(close, 200)
vSMA   = ta.sma(volume, 20)
volOK  = volume > (vSMA * 1.2) // Must have 20% more volume than average

// ═══════════════════════════════════════════════════════════════
// ░░  ORB RANGE — TRUE 8:00–8:15 AM NEW YORK TIME (FIXED)
// ═══════════════════════════════════════════════════════════════

// Get New York time (handles DST automatically)
tNY = time(timeframe.period, "America/New_York")
hourNY = hour(tNY)
minuteNY = minute(tNY)

// Define ORB window
isInORB  = (hourNY == 8 and minuteNY >= 0 and minuteNY < 15)
endORB   = (hourNY == 8 and minuteNY == 15)

var float orbH     = na
var float orbL     = na
var float orbMid   = na
var bool  orbReady = false
var bool  drawn    = false
var int   tradesToday = 0

// Reset daily
if ta.change(dayofmonth) != 0
    orbH        := na
    orbL        := na
    orbMid      := na
    orbReady    := false
    drawn       := false
    tradesToday := 0

// Build ONLY during 8:00–8:15 and ONLY once
if isInORB and not orbReady
    orbH := na(orbH) ? high : math.max(orbH, high)
    orbL := na(orbL) ? low  : math.min(orbL, low)

// Lock ORB EXACTLY at 8:15
if endORB and not orbReady
    orbMid   := (orbH + orbL) / 2
    orbReady := true

float orbRange = na(orbH) or na(orbL) ? na : orbH - orbL
float bZone    = na(orbRange) ? 0.0 : orbRange * midZonePct

// ═══════════════════════════════════════════════════════════════
// ░░  DRAW ORB LEVELS
// ═══════════════════════════════════════════════════════════════
if orbReady and not drawn
    drawn := true
    if showBox
        box.new(bar_index - 3, orbH, bar_index, orbL, bgcolor=color.new(cORB, 88), border_color=color.new(cORB, 45), border_width=1)

    line.new(bar_index, orbH,   bar_index + extLen, orbH,   color=cORB, width=1, style=line.style_dashed)
    line.new(bar_index, orbL,   bar_index + extLen, orbL,   color=cORB, width=1, style=line.style_dashed)
    line.new(bar_index, orbMid, bar_index + extLen, orbMid, color=color.new(cORB, 35), width=2, style=line.style_dotted)

    label.new(bar_index, orbH,   "ORB High  " + str.tostring(orbH,   format.mintick), color=color.new(cORB, 55), textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index, orbMid, "Midpoint  " + str.tostring(orbMid, format.mintick), color=color.new(cORB, 68), textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index, orbL,   "ORB Low   " + str.tostring(orbL,   format.mintick), color=color.new(cORB, 55), textcolor=color.white, style=label.style_label_left, size=size.small)

// ═══════════════════════════════════════════════════════════════
// ░░  SIGNAL LOGIC — IMPROVED BEHIND THE SCENES
// ═══════════════════════════════════════════════════════════════
canTrade    = orbReady and not newsOff and not isInORB and tradesToday == 0
prevNearMid = not na(orbMid) and ((low[1] <= orbMid and high[1] >= orbMid) or math.abs(low[1] - orbMid) <= bZone or math.abs(high[1] - orbMid) <= bZone)

// RP'S LOGIC: Signal only fires if Trend + Volume agree
longSig     = canTrade and prevNearMid and close > orbMid and close > open and close > ema200 and volOK
shortSig    = canTrade and prevNearMid and close < orbMid and close < open and close < ema200 and volOK

// ═══════════════════════════════════════════════════════════════
// ░░  MARK ENTRIES, SL, TP LEVELS
// ═══════════════════════════════════════════════════════════════
if longSig
    tradesToday := 1 // Lock the script for the day
    en   = close
    sl   = orbL
    risk = en - sl
    tp1  = en + risk
    tp2  = en + risk * 2.0
    tp3  = en + risk * 3.0
    pad  = na(orbRange) ? syminfo.mintick * 3 : orbRange * 0.04

    label.new(bar_index, low - pad, "▲  LONG\n" + str.tostring(en, format.mintick), color=cLong, textcolor=color.white, style=label.style_label_up, size=size.normal)
    line.new(bar_index, sl, bar_index + extLen, sl, color=cSL, width=1, style=line.style_dashed)
    label.new(bar_index + extLen, sl, "SL  " + str.tostring(sl, format.mintick), color=cSL, textcolor=color.white, style=label.style_label_left, size=size.small)

    if showTP1
        line.new(bar_index, tp1, bar_index + extLen, tp1, color=cTP1c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp1, "TP1  " + str.tostring(tp1, format.mintick), color=cTP1c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP2
        line.new(bar_index, tp2, bar_index + extLen, tp2, color=cTP2c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp2, "TP2  " + str.tostring(tp2, format.mintick), color=cTP2c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP3
        line.new(bar_index, tp3, bar_index + extLen, tp3, color=cTP3c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp3, "TP3  " + str.tostring(tp3, format.mintick), color=cTP3c, textcolor=color.white, style=label.style_label_left, size=size.small)

if shortSig
    tradesToday := 1 // Lock the script for the day
    en   = close
    sl   = orbH
    risk = sl - en
    tp1  = en - risk
    tp2  = en - risk * 2.0
    tp3  = en - risk * 3.0
    pad  = na(orbRange) ? syminfo.mintick * 3 : orbRange * 0.04

    label.new(bar_index, high + pad, "▼  SHORT\n" + str.tostring(en, format.mintick), color=cShort, textcolor=color.white, style=label.style_label_down, size=size.normal)
    line.new(bar_index, sl, bar_index + extLen, sl, color=cSL, width=1, style=line.style_dashed)
    label.new(bar_index + extLen, sl, "SL  " + str.tostring(sl, format.mintick), color=cSL, textcolor=color.white, style=label.style_label_left, size=size.small)

    if showTP1
        line.new(bar_index, tp1, bar_index + extLen, tp1, color=cTP1c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp1, "TP1  " + str.tostring(tp1, format.mintick), color=cTP1c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP2
        line.new(bar_index, tp2, bar_index + extLen, tp2, color=cTP2c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp2, "TP2  " + str.tostring(tp2, format.mintick), color=cTP2c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP3
        line.new(bar_index, tp3, bar_index + extLen, tp3, color=cTP3c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp3, "TP3  " + str.tostring(tp3, format.mintick), color=cTP3c, textcolor=color.white, style=label.style_label_left, size=size.small)


alertcondition(longSig,  "ORB Long Signal",  "8AM ORB ▲ LONG signal fired")
alertcondition(shortSig, "ORB Short Signal", "8AM ORB ▼ SHORT signal fired")

f_chk(b) => b ? "✅" : "❌"
f_col(b) => b ? color.new(#00c853, 0) : color.new(#ef5350, 0)

var table T = table.new(position.top_right, 3, 10, bgcolor=color.new(#0f172a, 60), border_width=1, border_color=color.new(#334155, 55), frame_width=1, frame_color=#334155)

if showPanel and barstate.islast
    hasSig  = longSig or shortSig
    dirOK   = (longSig and close > orbMid) or (shortSig and close < orbMid)
    allGood = orbReady and not newsOff and prevNearMid and hasSig and dirOK

    sigText = longSig ? "▲   LONG" : shortSig ? "▼   SHORT" : "—   NO TRADE"
    sigBg   = longSig ? color.new(#00c853, 68) : shortSig ? color.new(#d50000, 68) : color.new(#1e293b, 55)
    sigCol  = longSig ? color.new(#00c853, 0)  : shortSig ? color.new(#ef5350, 0)  : color.new(#9e9e9e, 0)

    cBg    = color.new(#1e293b, 50)
    cBgAlt = color.new(#1e293b, 65)
    cHead  = color.new(#1e3a5f, 15)
    cMuted = color.new(color.white, 45)

    table.cell(T, 0, 0, "  8AM ORB — ENTRY CHECKLIST  ", text_color=color.white, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)
    table.merge_cells(T, 0, 0, 2, 0)

    table.cell(T, 0, 1, "📡  SIGNAL", text_color=color.new(color.white, 15), text_size=size.small, bgcolor=sigBg)
    table.cell(T, 1, 1, sigText, text_color=sigCol, text_size=size.small, bgcolor=sigBg, text_halign=text.align_center)
    table.cell(T, 2, 1, "", bgcolor=sigBg)

    orbInfo = orbReady ? str.tostring(orbH, format.mintick) + " / " + str.tostring(orbL, format.mintick) : "Waiting 8:00–8:15..."
    table.cell(T, 0, 2, "  ORB Built",     text_color=color.white, text_size=size.small, bgcolor=cBg)
    table.cell(T, 1, 2, f_chk(orbReady),   text_color=f_col(orbReady), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
    table.cell(T, 2, 2, orbInfo,           text_color=cMuted, text_size=size.tiny, bgcolor=cBg)

    noNews   = not newsOff
    newsInfo = noNews ? "Clear" : "⚠️ FILTER ON"
    newsCol  = noNews ? color.new(#00c853, 0) : color.new(#ffd600, 0)
    table.cell(T, 0, 3, "  No News Event", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
    table.cell(T, 1, 3, f_chk(noNews),     text_color=f_col(noNews), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
    table.cell(T, 2, 3, newsInfo,          text_color=newsCol, text_size=size.tiny, bgcolor=cBgAlt)

    midInfo = orbReady ? "Mid: " + str.tostring(orbMid, format.mintick) : "–"
    table.cell(T, 0, 4, "  Bounce @ Mid",  text_color=color.white, text_size=size.small, bgcolor=cBg)
    table.cell(T, 1, 4, f_chk(prevNearMid), text_color=f_col(prevNearMid), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
    table.cell(T, 2, 4, midInfo,           text_color=cMuted, text_size=size.tiny, bgcolor=cBg)

    revInfo = hasSig ? (longSig ? "Bullish close ↑" : "Bearish close ↓") : "Watching..."
    table.cell(T, 0, 5, "  Reversal Candle", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
    table.cell(T, 1, 5, f_chk(hasSig),       text_color=f_col(hasSig), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
    table.cell(T, 2, 5, revInfo,             text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)

    dirInfo = dirOK ? (longSig ? "Above mid ↑" : "Below mid ↓") : "–"
    table.cell(T, 0, 6, "  Direction Clear", text_color=color.white, text_size=size.small, bgcolor=cBg)
    table.cell(T, 1, 6, f_chk(dirOK),        text_color=f_col(dirOK), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
    table.cell(T, 2, 6, dirInfo,             text_color=cMuted, text_size=size.tiny, bgcolor=cBg)

    table.cell(T, 0, 7, "  1min & 3min Agree", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
    table.cell(T, 1, 7, "👁", text_color=color.new(#ffd600, 0), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
    table.cell(T, 2, 7, "Manual check", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)

    hml = orbReady ? str.tostring(orbH, format.mintick) + "  |  " + str.tostring(orbMid, format.mintick) + "  |  " + str.tostring(orbL, format.mintick) : "Building..."
    table.cell(T, 0, 8, "  H | Mid | L", text_color=color.new(cORB, 0), text_size=size.tiny, bgcolor=color.new(#0f172a, 50))
    table.cell(T, 1, 8, hml, text_color=color.white, text_size=size.tiny, bgcolor=color.new(#0f172a, 50), text_halign=text.align_center)
    table.cell(T, 2, 8, "", bgcolor=color.new(#0f172a, 50))

    footTxt = newsOff ? "⚠️  News filter ON — signals disabled" : allGood ? "✅  All checks passed — confirm 1min/3min" : "ℹ️  Waiting for setup..."
    footCol = newsOff ? color.new(#ffd600, 0) : allGood ? color.new(#00c853, 0) : color.new(#9e9e9e, 0)
    table.cell(T, 0, 9, footTxt, text_color=footCol, text_size=size.tiny, bgcolor=color.new(#0f172a, 50), text_halign=text.align_center)
    table.merge_cells(T, 0, 9, 2, 9)
````
