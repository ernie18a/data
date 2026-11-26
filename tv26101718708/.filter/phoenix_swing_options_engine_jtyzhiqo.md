# PHOENIX Swing Options Engine

- url: https://www.tradingview.com/script/jtyzHIqO-PHOENIX-Swing-Options-Engine/
- type: indicator
- pine_id: PUB;5909fffd8a184abb95d35a1e4481346e
- version: 1.0

## Description

PHOENIX-SOE (Predictive Hybrid Oscillator for Energy & iNflection eXploitation — Swing Options Engine). It's built on four pillars working together:

VCI — Volatility Compression Index. A percentile-rank of Bollinger Band Width vs. its own 100-bar history. When BB Width sits in the bottom 30%, the spring is coiled — historically these resolve into expansions, which is exactly when you want to be long options (vega tailwind).
DMS — Directional Momentum Score. A composite from −5 to +5 combining EMA stack alignment (8/21/55), RSI regime, and ROC + ROC slope. Single oscillators lie; consensus across three independent momentum measurements lies less.
EBD — Energy Buildup Detector. Looks for the classic accumulation tell: ATR contracting while volume expands. That divergence is what separates a real coil from a dead market.
ATL — Adaptive Trigger Line. Donchian midline ± a buffer scaled to ATR. The actual entry trigger — we don't fire on the setup, we fire on the release.

The signals only print when all four align AND price breaks the trigger on a volume surge. Exits use ATR-based targets, ATR stops, momentum-flip protection, and a hard time-stop (because every day you hold, theta wins).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © all_hail_the_data

//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  PHOENIX  •  Swing Options Engine  (PHX-SOE)
//  Predictive Hybrid Oscillator for Energy & iNflection eXploitation
//
//  PURPOSE
//  -------
//  A swing-trading indicator built specifically for long-options traders
//  (3–10 day holds). Long options lose money to theta every day, so the
//  edge must produce moves that are:
//    • Directional enough to overcome time decay
//    • Ideally launched from compressed-IV regimes (vega tailwind)
//    • Confirmed across momentum, volume, and trend
//
//  THE FOUR PILLARS
//  ----------------
//    1) VCI  — Volatility Compression Index   (when is the spring coiled?)
//    2) DMS  — Directional Momentum Score     (which way will it spring?)
//    3) EBD  — Energy Buildup Detector        (is energy actually building?)
//    4) ATL  — Adaptive Trigger Line          (the moment of release)
//
//  Signals fire only when all four align and price breaks the trigger on a
//  volume surge. Exits use ATR-scaled targets/stops, momentum reversal,
//  and a hard time-stop (theta is undefeated over time).
//
//  Author: Sean's custom build • PineScript v6
// ════════════════════════════════════════════════════════════════════════════
 
indicator("PHOENIX Swing Options Engine", "PHOENIX-SOE",
     overlay=true, max_labels_count=500, max_lines_count=500)
 
// ── INPUTS ──────────────────────────────────────────────────────────────────
g1 = "Volatility Compression"
bbLen     = input.int(20,   "BB Length",                     group=g1)
bbMult    = input.float(2.0,"BB Multiplier",                 group=g1, step=0.1)
vciLook   = input.int(100,  "VCI Lookback (percentile bars)",group=g1)
vciThresh = input.float(70, "VCI Compression Threshold",     group=g1, minval=50, maxval=95)
 
g2 = "Momentum & Trend"
emaFast   = input.int(8,    "EMA Fast",  group=g2)
emaMid    = input.int(21,   "EMA Mid",   group=g2)
emaSlow   = input.int(55,   "EMA Slow",  group=g2)
rsiLen    = input.int(14,   "RSI Length",group=g2)
rocLen    = input.int(10,   "ROC Length",group=g2)
dmsThresh = input.int(3,    "DMS Trigger (|score|, 1-5)", minval=1, maxval=5, group=g2)
 
g3 = "Energy & Volume"
atrLen    = input.int(14,   "ATR Length",            group=g3)
volLen    = input.int(20,   "Volume MA Length",      group=g3)
volMult   = input.float(1.2,"Volume Surge Multiplier",group=g3, step=0.1)
 
g4 = "Adaptive Trigger"
donchLen  = input.int(20,   "Donchian Length",       group=g4)
trigBuf   = input.float(0.5,"Trigger Buffer (× ATR)",group=g4, step=0.1)
 
g5 = "Risk & Exits"
targetATR = input.float(2.5,"Profit Target (× ATR)", group=g5, step=0.1)
stopATR   = input.float(1.5,"Stop Loss (× ATR)",     group=g5, step=0.1)
timeStop  = input.int(10,   "Time Stop (bars in trade)", group=g5)
armWindow = input.int(15,   "Setup Arm Window (bars)",   group=g5)
 
g6 = "Display"
showTable    = input.bool(true,  "Show Status Table",         group=g6)
showLabels   = input.bool(true,  "Show Entry / Exit Labels",  group=g6)
showTrigger  = input.bool(true,  "Show Adaptive Trigger Lines",group=g6)
showSqueeze  = input.bool(true,  "Highlight Squeeze Bars",    group=g6)
showTargets  = input.bool(true,  "Plot Target / Stop Lines",  group=g6)
 
// ── PILLAR 1: VOLATILITY COMPRESSION INDEX (VCI) ────────────────────────────
bbBasis    = ta.sma(close, bbLen)
bbDev      = bbMult * ta.stdev(close, bbLen)
bbUpper    = bbBasis + bbDev
bbLower    = bbBasis - bbDev
bbWidth    = (bbUpper - bbLower) / bbBasis
bbWidthMin = ta.lowest(bbWidth, vciLook)
bbWidthMax = ta.highest(bbWidth, vciLook)
bbWidthPct = (bbWidth - bbWidthMin) / math.max(bbWidthMax - bbWidthMin, 1e-10) * 100
vci        = 100 - bbWidthPct                          // 100 = max compression
isSqueeze  = vci >= vciThresh
 
// ── PILLAR 2: DIRECTIONAL MOMENTUM SCORE (DMS) ──────────────────────────────
emaF = ta.ema(close, emaFast)
emaM = ta.ema(close, emaMid)
emaS = ta.ema(close, emaSlow)
 
trendScore = emaF > emaM and emaM > emaS ?  2 :
             emaF < emaM and emaM < emaS ? -2 :
             emaF > emaM                 ?  1 :
             emaF < emaM                 ? -1 : 0
 
rsi      = ta.rsi(close, rsiLen)
rsiScore = rsi > 55 ? 1 : rsi < 45 ? -1 : 0
 
roc      = ta.roc(close, rocLen)
rocSlope = roc - roc[3]
rocScore = roc > 0 and rocSlope > 0 ?  2 :
           roc > 0                  ?  1 :
           roc < 0 and rocSlope < 0 ? -2 :
           roc < 0                  ? -1 : 0
 
dms = trendScore + rsiScore + rocScore                  // range −5 … +5
 
// ── PILLAR 3: ENERGY BUILDUP DETECTOR (EBD) ─────────────────────────────────
atr        = ta.atr(atrLen)
atrSmooth  = ta.sma(atr, 5)
volMa      = ta.sma(volume, volLen)
atrFalling = atrSmooth < atrSmooth[5]
volRising  = volMa > volMa[5]
ebd        = atrFalling and volRising
 
// ── PILLAR 4: ADAPTIVE TRIGGER LINE (ATL) ───────────────────────────────────
donchHigh = ta.highest(high, donchLen)
donchLow  = ta.lowest(low,  donchLen)
donchMid  = (donchHigh + donchLow) / 2
trigUp    = donchMid + trigBuf * atr
trigDn    = donchMid - trigBuf * atr
 
volSurge  = volume > volMult * volMa
 
// ── SETUP STATE: ARM-THEN-FIRE LOGIC ────────────────────────────────────────
// Setup conditions arm a directional bias. We then wait (up to armWindow bars)
// for the trigger break. This avoids firing inside the squeeze itself.
bullSetup = isSqueeze and dms >=  dmsThresh and ebd
bearSetup = isSqueeze and dms <= -dmsThresh and ebd
 
var bool bullArmed = false
var bool bearArmed = false
var int  armBar    = na
 
if bullSetup and not bullArmed
    bullArmed := true
    armBar    := bar_index
if bearSetup and not bearArmed
    bearArmed := true
    armBar    := bar_index
 
// disarm if direction flips or window expires
if bullArmed and (dms < 0 or bar_index - armBar > armWindow)
    bullArmed := false
if bearArmed and (dms > 0 or bar_index - armBar > armWindow)
    bearArmed := false
 
// ── ENTRY TRIGGERS ──────────────────────────────────────────────────────────
buyCalls = bullArmed and ta.crossover(close, trigUp)  and volSurge
buyPuts  = bearArmed and ta.crossunder(close, trigDn) and volSurge
 
if buyCalls
    bullArmed := false
if buyPuts
    bearArmed := false
 
// ── POSITION TRACKING & EXIT LOGIC ──────────────────────────────────────────
var int   posDir     = 0          // +1 = long calls, -1 = long puts, 0 = flat
var float entryPrice = na
var float entryATR   = na
var int   entryBar   = na
 
if buyCalls
    posDir     := 1
    entryPrice := close
    entryATR   := atr
    entryBar   := bar_index
if buyPuts
    posDir     := -1
    entryPrice := close
    entryATR   := atr
    entryBar   := bar_index
 
exitTarget = posDir ==  1 ? entryPrice + targetATR * entryATR :
             posDir == -1 ? entryPrice - targetATR * entryATR : na
exitStop   = posDir ==  1 ? entryPrice - stopATR   * entryATR :
             posDir == -1 ? entryPrice + stopATR   * entryATR : na
 
hitTarget = (posDir ==  1 and high >= exitTarget) or (posDir == -1 and low  <= exitTarget)
hitStop   = (posDir ==  1 and low  <= exitStop)   or (posDir == -1 and high >= exitStop)
flipDir   = (posDir ==  1 and dms <= -dmsThresh)  or (posDir == -1 and dms >=  dmsThresh)
timeOut   =  posDir != 0  and bar_index - entryBar >= timeStop
 
exitLong  = posDir ==  1 and (hitTarget or hitStop or flipDir or timeOut)
exitShort = posDir == -1 and (hitTarget or hitStop or flipDir or timeOut)
 
if exitLong or exitShort
    posDir := 0
 
// ── SETUP QUALITY SCORE (0-100) ─────────────────────────────────────────────
// Composite "how good is this setup right now" gauge for the table.
qVCI    = math.min(vci / vciThresh * 30, 30)               // up to 30 pts
qDMS    = math.min(math.abs(dms) / 5 * 30, 30)             // up to 30 pts
qEBD    = ebd ? 20 : 0                                     // 20 pts
qVol    = math.min(volume / volMa, 2) / 2 * 20             // up to 20 pts
quality = qVCI + qDMS + qEBD + qVol
 
// ── PLOTS ───────────────────────────────────────────────────────────────────
plot(showTrigger ? trigUp : na, "Trigger Up", color=color.new(color.green, 40), style=plot.style_linebr)
plot(showTrigger ? trigDn : na, "Trigger Dn", color=color.new(color.red,   40), style=plot.style_linebr)
plot(showTrigger ? donchMid : na, "Donch Mid", color=color.new(color.gray, 70))
 
bgcolor(showSqueeze and isSqueeze ? color.new(color.yellow, 92) : na, title="Squeeze BG")
 
plotshape(showLabels and buyCalls,  "BUY CALLS", shape.labelup,   location.belowbar,
     color=color.new(color.green, 0),  text="CALLS", textcolor=color.white, size=size.small)
plotshape(showLabels and buyPuts,   "BUY PUTS",  shape.labeldown, location.abovebar,
     color=color.new(color.red,   0),  text="PUTS",  textcolor=color.white, size=size.small)
plotshape(showLabels and exitLong,  "EXIT CALLS",shape.xcross,    location.abovebar,
     color=color.new(color.lime,  0),  size=size.tiny)
plotshape(showLabels and exitShort, "EXIT PUTS", shape.xcross,    location.belowbar,
     color=color.new(color.orange,0),  size=size.tiny)
 
// "armed" pulse markers (small dots on the bar where bias arms)
plotshape(bullArmed and not bullArmed[1], "Bull Armed", shape.circle, location.belowbar,
     color=color.new(color.aqua,    30), size=size.tiny)
plotshape(bearArmed and not bearArmed[1], "Bear Armed", shape.circle, location.abovebar,
     color=color.new(color.fuchsia, 30), size=size.tiny)
 
// in-trade target/stop lines
plot(showTargets and posDir != 0 ? exitTarget : na, "Target", color=color.new(color.green, 30), style=plot.style_linebr, linewidth=1)
plot(showTargets and posDir != 0 ? exitStop   : na, "Stop",   color=color.new(color.red,   30), style=plot.style_linebr, linewidth=1)
 
// ── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(buyCalls,  "PHOENIX • Buy Calls",  "PHX-SOE: BUY CALLS — squeeze release bullish")
alertcondition(buyPuts,   "PHOENIX • Buy Puts",   "PHX-SOE: BUY PUTS — squeeze release bearish")
alertcondition(exitLong,  "PHOENIX • Exit Calls", "PHX-SOE: EXIT CALLS")
alertcondition(exitShort, "PHOENIX • Exit Puts",  "PHX-SOE: EXIT PUTS")
alertcondition(bullSetup and not bullSetup[1], "PHOENIX • Bull Setup Forming", "PHX-SOE: bullish squeeze setup forming — get ready")
alertcondition(bearSetup and not bearSetup[1], "PHOENIX • Bear Setup Forming", "PHX-SOE: bearish squeeze setup forming — get ready")
 
// ── STATUS TABLE ────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 9, border_width=1, border_color=color.gray)
    table.cell(t, 0, 0, "PHOENIX-SOE", bgcolor=color.new(color.navy, 0), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, "Live",         bgcolor=color.new(color.navy, 0), text_color=color.white, text_size=size.small)
 
    vciCol = vci >= vciThresh ? color.new(color.yellow, 50) : color.new(color.gray, 80)
    table.cell(t, 0, 1, "VCI (compression)")
    table.cell(t, 1, 1, str.tostring(vci, "#.0"), bgcolor=vciCol)
 
    dmsCol = dms >=  dmsThresh ? color.new(color.green, 50) :
             dms <= -dmsThresh ? color.new(color.red,   50) :
                                 color.new(color.gray,  80)
    table.cell(t, 0, 2, "DMS (direction)")
    table.cell(t, 1, 2, str.tostring(dms), bgcolor=dmsCol)
 
    table.cell(t, 0, 3, "EBD (energy)")
    table.cell(t, 1, 3, ebd ? "BUILDING" : "—",
         bgcolor = ebd ? color.new(color.aqua, 60) : color.new(color.gray, 80))
 
    table.cell(t, 0, 4, "Squeeze")
    table.cell(t, 1, 4, isSqueeze ? "YES" : "no",
         bgcolor = isSqueeze ? color.new(color.yellow, 50) : color.new(color.gray, 80))
 
    biasTxt = bullArmed ? "ARMED LONG"  :
              bearArmed ? "ARMED SHORT" :
              dms > 0   ? "lean long"   :
              dms < 0   ? "lean short"  : "neutral"
    biasCol = bullArmed ? color.new(color.green, 30) :
              bearArmed ? color.new(color.red,   30) : color.new(color.gray, 80)
    table.cell(t, 0, 5, "Bias")
    table.cell(t, 1, 5, biasTxt, bgcolor=biasCol)
 
    posTxt = posDir ==  1 ? "LONG CALLS" :
             posDir == -1 ? "LONG PUTS"  : "FLAT"
    posCol = posDir ==  1 ? color.new(color.green, 30) :
             posDir == -1 ? color.new(color.red,   30) : color.new(color.gray, 80)
    table.cell(t, 0, 6, "Position")
    table.cell(t, 1, 6, posTxt, bgcolor=posCol)
 
    qCol = quality >= 75 ? color.new(color.green,  40) :
           quality >= 50 ? color.new(color.yellow, 40) :
                           color.new(color.gray,   80)
    table.cell(t, 0, 7, "Setup Quality")
    table.cell(t, 1, 7, str.tostring(quality, "#") + "/100", bgcolor=qCol)
 
    table.cell(t, 0, 8, "ATR (1× move)")
    table.cell(t, 1, 8, str.tostring(atr, "#.##"))
````
