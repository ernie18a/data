# PJT  Position  Risk Calculator v2.0 [Auto Signal + R]

- url: https://www.tradingview.com/script/RULp5vDf-PJT-Position-Risk-Calculator-v2-0-Auto-Signal-R/
- type: indicator
- pine_id: PUB;0e3825e9e6f241ae8b5f5549824db001
- version: 1.0

## Description

PJT Position Calculator v2.0

This tool helps you calculate position size based on risk, using a structured approach aligned with the PJT trading framework.

Features:
• Automatic entry and stop from signal candle  
• Risk-based position sizing  
• R-multiple target calculation  
• Live R tracking  
• Optional ATR stop buffer  

This is the exact calculator I use to manage risk and stay consistent in the market.

For best results, combine this with the PJT TAZ Core script.

Disclaimer: This tool is for educational purposes only. Not financial advice.

## Source Code

````pine
//@version=5
indicator("PJT  Position  Risk Calculator v2.0 [Auto Signal + R]", overlay=true, max_labels_count=50, max_lines_count=100)

//====================================================
// WHAT CHANGED FROM v1.0
// 1. Fixed version comment typo (/@version=5 → //@version=5)
// 2. pullbackLong FIXED — was checking the signal candle itself for lower highs,
//    which conflicted with bullEngulf (engulfing candles have higher highs by definition).
//    Now checks the 2 bars BEFORE the signal candle, which is the correct pullback read.
//    Before: high < high[1] and high[1] < high[2]
//    After:  high[1] < high[2] and high[2] < high[3]
// 3. validCore FIXED — no longer requires longSignal on the current bar.
//    The panel now stays live after the signal fires, so you can review it
//    after market close when planning your orders.
//    Before: validCore = ... and longSignal
//    After:  validCore = not na(sigHigh) and not na(sigLow)
//====================================================

//====================================================
// GROUPS
//====================================================
groupCore  = "PJT_TAZ_Core_v2_0 (Long Signal Logic)"
groupAuto  = "Auto (Signal Candle Wiring)"
groupRisk  = "Risk Settings"
groupUI    = "UI"
groupTrail = "Optional Trailing Stop Visual"

//====================================================
// UI
//====================================================
showPanel = input.bool(true, "Show Calculator Panel", group=groupUI)
panelPos  = input.string("Bottom Left", "Panel Position",
             options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=groupUI)

//====================================================
// ACCOUNT / RISK
//====================================================
accountSize = input.float(5000.0, "Account Size ($)",    minval=1,                            group=groupRisk)
riskPct     = input.float(1.0,    "Risk % per Trade",    minval=0.1, maxval=10.0, step=0.1,  group=groupRisk)
rrMultiple  = input.float(2.5,    "Target R Multiple",   minval=0.5, maxval=10.0, step=0.1,  group=groupRisk)

//====================================================
// AUTO SIGNAL WIRING
//====================================================
useAutoFromSignal = input.bool(true,  "Auto from last PJT Long Signal candle",       group=groupAuto)
entryBufferUSD    = input.float(0.10, "Entry Buffer $ (BuyStop above signal high)",   minval=0.0,  step=0.01, group=groupAuto)
useATRBuffer      = input.bool(true,  "Use ATR for Stop Buffer",                      group=groupAuto)
atrLen            = input.int(14,     "ATR Length",                                   minval=1,    group=groupAuto)
atrMultStop       = input.float(0.75, "ATR Mult (Stop Buffer)",                       minval=0.0,  step=0.05, group=groupAuto)

// TAZ depth rule (30%–90% inside the zone)
depthMin = input.float(0.30, "TAZ Depth Min (0.30 = 30%)", minval=0.0, maxval=1.0, step=0.01, group=groupAuto)
depthMax = input.float(0.90, "TAZ Depth Max (0.90 = 90%)", minval=0.0, maxval=1.0, step=0.01, group=groupAuto)

// Manual fallback (only used when Auto is OFF)
entryManual = input.float(1.0, "Entry Price (manual)", minval=0.0001, step=0.01, group=groupAuto)
stopManual  = input.float(0.9, "Stop Price (manual)",  minval=0.0001, step=0.01, group=groupAuto)

//====================================================
// OPTIONAL TRAIL VISUAL
//====================================================
showTrail      = input.bool(true,      "Show Trailing Stop (minimal line)", group=groupTrail)
trailMode      = input.string("Two-Bar","Trail Mode", options=["Two-Bar","None"],  group=groupTrail)
trailBars      = input.int(5,          "Time Stop Bars (visual only)",      minval=1, group=groupTrail)
showEntryLine  = input.bool(false,     "Show Entry Line",                   group=groupTrail)
showStopLine   = input.bool(false,     "Show Initial Stop Line",            group=groupTrail)
showTargetLine = input.bool(false,     "Show Target Line",                  group=groupTrail)

//====================================================
// HELPERS
//====================================================
f_yesno(x) => x ? "YES" : "NO"
f_fmt(x)   => str.tostring(x, format.mintick)

f_pos(_s) =>
    if _s == "Top Left"
        position.top_left
    else if _s == "Top Right"
        position.top_right
    else if _s == "Bottom Right"
        position.bottom_right
    else
        position.bottom_left

//====================================================
// PJT CORE LOGIC — LONG SIGNAL
// Matches PJT_TAZ_Core_v2_0 framework:
//   - Trend confirmed by moving averages (structure)
//   - Price pulled back into TAZ
//   - Confirming candle (hammer or bullish engulfing)
//
// FIX: pullbackLong now checks the bars BEFORE the signal candle.
// Old version checked bar[0] vs bar[1] and bar[2], which broke bullEngulf
// because an engulfing candle's high is higher than the prior candle by design.
// New version checks bar[1] vs bar[2] and bar[3] — the pullback sequence
// that set up the entry, not the entry bar itself.
//====================================================
sma10  = ta.sma(close, 10)
ema30  = ta.ema(close, 30)
sma200 = ta.sma(close, 200)

// Candle patterns
bullEngulf = close > open and open[1] > close[1] and open <= close[1] and close >= open[1]

body     = math.abs(close - open)
rng0     = high - low
lowerWick = math.min(open, close) - low
isHammer = rng0 > 0
         and body      <= rng0 * 0.35
         and math.max(open, close) >= high - (rng0 * 0.20)
         and lowerWick >= body * 1.5

// TAZ condition
inTAZlong = close < sma10 and close > ema30 and sma10 > ema30 and close > sma200

// FIXED pullbackLong — checks the 2 bars before the signal candle
// This correctly identifies a pullback sequence without conflicting with bullEngulf
pullbackLong = high[1] < high[2] and high[2] < high[3]

// Long signal: TAZ + prior pullback + confirming candle
longSignal = inTAZlong and pullbackLong and (bullEngulf or isHammer)

//====================================================
// SIGNAL CANDLE CAPTURE (LAST LONG SIGNAL)
//====================================================
var float sigHigh  = na
var float sigLow   = na
var float sigClose = na
var int   sigBar   = na

if longSignal
    sigHigh  := high
    sigLow   := low
    sigClose := close
    sigBar   := bar_index

//====================================================
// AUTO ENTRY / STOP (FROM SIGNAL CANDLE)
//====================================================
atrVal = ta.atr(atrLen)

float entryAuto = na
float stopAuto  = na

if not na(sigHigh) and not na(sigLow)
    entryAuto := sigHigh + entryBufferUSD
    float stopBuf = useATRBuffer ? (atrVal * atrMultStop) : 0.0
    stopAuto  := sigLow - stopBuf

//====================================================
// TAZ DEPTH + CANDLE VALIDATION (HARD RULES)
//====================================================
// Hard rule: signal candle must be fully inside TAZ
signalInsideTAZ = not na(sigHigh) and not na(sigLow)
                  and (sigHigh <= sma10)
                  and (sigLow  >= ema30)

// Depth (0..1) from ema30 (0) to sma10 (1) using signal close
tazWidth    = sma10 - ema30
signalDepth = (not na(sigClose) and tazWidth != 0.0)
              ? ((sigClose - ema30) / tazWidth)
              : na
depthOK = not na(signalDepth)
          and (signalDepth >= depthMin)
          and (signalDepth <= depthMax)

// Candle validation
signalIsHammer  = longSignal and isHammer
signalIsEngulf  = longSignal and bullEngulf
signalPatternOK = signalIsHammer or signalIsEngulf

entryHighInsideTAZ = signalInsideTAZ

//====================================================
// CHOOSE ENTRY / STOP
//====================================================
entryPrice = useAutoFromSignal ? entryAuto : entryManual
stopPrice  = useAutoFromSignal ? stopAuto  : stopManual

//====================================================
// RISK / SHARES / TARGET / R READOUT
//====================================================
accountRisk = accountSize * (riskPct / 100.0)

riskPerShareRaw = entryPrice - stopPrice
riskPerShare    = math.abs(riskPerShareRaw)

validPrices = entryPrice > 0
              and stopPrice > 0
              and entryPrice != stopPrice
              and (stopPrice < entryPrice)

// FIXED validCore — no longer requires longSignal on current bar.
// The signal candle data (sigHigh, sigLow) is stored via var.
// Panel stays live after the signal fires so you can review
// your setup after market close before placing orders.
validCore = not useAutoFromSignal or (not na(sigHigh) and not na(sigLow))

validRules = not useAutoFromSignal
             or (entryHighInsideTAZ and depthOK and signalPatternOK)

validTrade = validPrices
             and (riskPerShare  > 0)
             and (accountRisk   > 0)
             and validCore
             and validRules

shares          = validTrade ? math.floor(accountRisk / riskPerShare) : 0
actualDollarRisk = shares * riskPerShare
targetPrice     = validTrade ? (entryPrice + riskPerShare * rrMultiple) : na

// Live R-multiple vs current price
rNow = validTrade ? ((close - entryPrice) / riskPerShare) : na

//====================================================
// OPTIONAL TRAIL VISUAL
//====================================================
var bool  inTrade  = false
var int   entryBar = na
var float trailStop = na

entryTriggered = validTrade and not inTrade and (high >= entryPrice)

if entryTriggered
    inTrade   := true
    entryBar  := bar_index
    trailStop := stopPrice

// 1R break-even rule: once close ≥ entry + 1R, trail to entry
oneRHit = inTrade and validTrade and (close >= entryPrice + riskPerShare)
if oneRHit
    trailStop := math.max(trailStop, entryPrice)

// Two-bar trail: raise stop to min(low, low[1]), never lower
twoBarLow = math.min(low, low[1])
if inTrade and validTrade and showTrail and (trailMode == "Two-Bar")
    trailStop := math.max(trailStop, twoBarLow)

// Time stop flag
barsInTrade = (inTrade and not na(entryBar)) ? (bar_index - entryBar) : na
timeStopHit = inTrade and not na(barsInTrade) and (barsInTrade >= trailBars)

// Plots
plot(showTrail      and inTrade    ? trailStop   : na, title="PJT Trail Stop (visual)", linewidth=2)
plot(showEntryLine  and validTrade ? entryPrice  : na, title="Entry (visual)",           linewidth=1)
plot(showStopLine   and validTrade ? stopPrice   : na, title="Stop (visual)",            linewidth=1)
plot(showTargetLine and validTrade ? targetPrice : na, title="Target (visual)",          linewidth=1)

//====================================================
// PANEL
//====================================================
int COLS = 2
int ROWS = 12
var table panel = table.new(f_pos(panelPos), COLS, ROWS, border_width=1)

if showPanel and barstate.islast
    table.clear(panel, 0, 0, COLS - 1, ROWS - 1)

    // Row 0 — Header
    table.cell(panel, 0, 0, "PJT POSITION CALC v2.0",
         text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(panel, 1, 0, useAutoFromSignal ? "AUTO" : "MANUAL",
         text_color=color.white,
         bgcolor=useAutoFromSignal ? color.new(color.green,0) : color.new(color.orange,0))

    // Row 1 — Ticker / timeframe
    table.cell(panel, 0, 1, "Ticker / TF",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 1, syminfo.ticker + " / " + timeframe.period,
         text_color=color.white, bgcolor=color.new(color.black,70))

    // Row 2 — Signal detected?
    table.cell(panel, 0, 2, "Last Long Signal?",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 2, f_yesno(not na(sigBar)),
         text_color=color.white,
         bgcolor=(not na(sigBar)) ? color.new(color.green,0) : color.new(color.red,0))

    // Row 3 — Signal inside TAZ?
    table.cell(panel, 0, 3, "Signal Inside TAZ?",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 3, useAutoFromSignal ? f_yesno(signalInsideTAZ) : "N/A",
         text_color=color.white,
         bgcolor=useAutoFromSignal
                 ? (signalInsideTAZ ? color.new(color.green,0) : color.new(color.red,0))
                 : color.new(color.black,70))

    // Row 4 — TAZ depth (30–90%)?
    table.cell(panel, 0, 4, "TAZ Depth (30–90)?",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 4,
         useAutoFromSignal
         ? (depthOK ? "YES (" + f_fmt(signalDepth) + ")" : "NO (" + f_fmt(signalDepth) + ")")
         : "N/A",
         text_color=color.white,
         bgcolor=useAutoFromSignal
                 ? (depthOK ? color.new(color.green,0) : color.new(color.red,0))
                 : color.new(color.black,70))

    // Row 5 — Entry
    table.cell(panel, 0, 5, "Entry",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 5, validPrices ? f_fmt(entryPrice) : "N/A",
         text_color=color.white, bgcolor=color.new(color.black,70))

    // Row 6 — Stop
    table.cell(panel, 0, 6, "Stop",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 6, validPrices ? f_fmt(stopPrice) : "N/A",
         text_color=color.white, bgcolor=color.new(color.black,70))

    // Row 7 — Risk per share
    table.cell(panel, 0, 7, "Risk / Share",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 7, validPrices ? ("$" + f_fmt(riskPerShare)) : "N/A",
         text_color=color.white, bgcolor=color.new(color.black,70))

    // Row 8 — Trade valid?
    table.cell(panel, 0, 8, "Trade Valid?",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 8, validTrade ? "YES" : "NO",
         text_color=color.white,
         bgcolor=validTrade ? color.new(color.green,0) : color.new(color.red,0))

    // Row 9 — Shares to buy
    table.cell(panel, 0, 9, "Shares",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 9, str.tostring(shares),
         text_color=color.white, bgcolor=color.new(color.black,70))

    // Row 10 — Target price
    table.cell(panel, 0, 10, "Target (" + str.tostring(rrMultiple) + "R)",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 10, validTrade ? f_fmt(targetPrice) : "N/A",
         text_color=color.white, bgcolor=color.new(color.black,70))

    // Row 11 — Live R readout
    table.cell(panel, 0, 11, "R Now (vs entry)",
         text_color=color.white, bgcolor=color.new(color.black,70))
    table.cell(panel, 1, 11, validTrade ? f_fmt(rNow) : "N/A",
         text_color=color.white, bgcolor=color.new(color.black,70))
````
