# ICT SMC key Levels Execution

- url: https://www.tradingview.com/script/OkYXcS0m-ICT-SMC-key-Levels-Execution/
- type: indicator
- pine_id: PUB;0f40d30741ab4ad18531e93df23f1fcc
- version: 1.0

## Description

ICT SMC key Levels Execution
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

ICT SMC key Levels Execution is a complete Smart Money Concepts and ICT style market structure tool built to visually flag, in real time, the specific footprints that large institutional players are believed to leave on a price chart. This indicator was created because most retail price action is not random, it is a reaction to a small number of repeating institutional behaviors, and instead of forcing a trader to manually mark every swing high, every swing low, every unfilled gap, every institutional footprint candle and every stop hunt by hand, this tool automates the entire process and displays it directly on the chart as it happens. The goal is to give the trader one unified, layered view of structure, liquidity, imbalance and momentum, all working together as a single decision making framework rather than several separate indicators that do not talk to each other.

[image]https://www.tradingview.com/x/eaL1WgLX/[/image]

Why this indicator was built

The core theory behind Smart Money Concepts and ICT trading is that price does not move purely because retail traders are clicking buy and sell buttons. Large institutions, banks and major liquidity providers need enormous size to fill their orders, and because the market never has infinite resting liquidity at any single price, these large participants cannot simply place one giant order and expect a clean fill. Instead, price is deliberately engineered toward areas where retail stop losses and breakout orders are known to cluster, because every one of those resting orders is a source of opposite side liquidity that institutions can use to fill their own size. Once that liquidity has been absorbed, price frequently reverses hard, because the artificial pressure that pushed it there in the first place disappears the moment the large players have what they wanted. This indicator exists purely to expose that behavior candle by candle so it becomes visible instead of hidden inside the raw price action.

[image]https://www.tradingview.com/x/2SD7s8JE/[/image]

Intermediate high and low structure

The first layer of the indicator identifies genuinely significant swing highs and swing lows rather than every minor wiggle in price. A high is only tagged once it is confirmed to be strictly higher than every high in a full window of candles on both sides of it, and the same logic applies in reverse for lows. Because confirmation requires candles to print on both sides, these badges always appear with a short delay, painted retroactively once the market has proven the level held. These confirmed points become the structural map of the chart, the reference points every other layer of the indicator is built around.

[image]https://www.tradingview.com/x/Tr2lhPRb/[/image]

Fair value gaps

A fair value gap represents a price inefficiency. When a strong, aggressive, one directional candle appears, sometimes it moves so violently that an entire range of price gets skipped over completely, meaning no genuine two sided trading actually took place there. The theory is that markets tend to come back and revisit these unresolved zones before continuing in the original direction. The indicator checks every group of three consecutive candles, and if the low of the newest candle sits completely above the high of the oldest candle, a bullish gap is boxed and treated as a likely support zone. The mirrored bearish version is boxed as a likely resistance zone. Each box is labeled directly on the chart and continues to extend to the right for as long as it remains untouched. The moment price closes back into and through the zone, it is considered filled and the box is deleted automatically because it no longer represents anything unresolved.

[image]https://www.tradingview.com/x/5WyHExUO/[/image]

Order blocks

An order block represents an institutional footprint rather than a price gap. Right before a strong impulsive move away from a point, there is usually one candle of the opposite color sitting exactly at that turning point, and this is believed to be where large orders were quietly built just before the move launched. The indicator hunts for confirmed swing highs and lows using a separate, wider lookback window specifically tuned for this purpose, and instead of boxing the entire candle, it boxes only the real body between the open and the close, because the body represents genuine committed activity while the wick is treated as a rejected probe. Bearish order blocks are boxed at confirmed swing highs and bullish order blocks at confirmed swing lows, each one labeled directly on the chart. If price later closes fully through the zone in the wrong direction, the order block is considered broken and is deleted immediately because it can no longer be trusted.

[image]https://www.tradingview.com/x/nE439LR3/[/image]

Liquidity sweeps

This is the single most important concept in the entire indicator. Any obvious recent swing high or swing low is treated as a magnet for two kinds of resting orders, stop losses from traders positioned against that level and breakout orders from traders expecting a continuation once it breaks. The theory holds that large players deliberately push price just beyond these levels to trigger those resting orders, absorb the liquidity, and then let price reverse sharply once they have the size they need. The indicator continuously tracks the most recent unbroken swing high and low using its own dedicated sensitivity setting, and the moment a candle's wick breaches that level intrabar but its close fails to hold beyond it, a line is drawn connecting the old swing point to the current candle and a label is stamped directly on the chart identifying it as a liquidity sweep. Once a swing point has been used in a sweep, it is cleared so the same level cannot fire a duplicate signal.

[image]https://www.tradingview.com/x/2QEgvSMx/[/image]

New York session highlight

Not every hour of the trading day carries equal weight. Certain sessions are known for dramatically higher genuine institutional participation and more decisive, trend driving moves, while other hours tend to be thinner and noisier. The indicator shades the chart background during the defined New York session window as a visual cue that patterns forming during this period are statistically more likely to reflect real institutional intent rather than random noise, compared to patterns forming outside of it.

[image]https://www.tradingview.com/x/WdJRM8q0/[/image]

Previous day high and low

This is a special, extremely important case of the same swing concept, except instead of pulling levels from small intraday swings, the indicator pulls the exact high and low of the entire previous completed daily candle regardless of the timeframe currently being viewed. Because essentially every trader across every strategy and every timeframe is aware of where yesterday's high and low sit, these levels are one of the most reliable magnets for the same kind of liquidity grabbing behavior already described. At the start of each new day the indicator draws these levels forward as extended lines with labels, and the instant price actually trades through either level, that line and label are deleted immediately, because once a level has been consumed it is no longer a resting, untested target.

[image]https://www.tradingview.com/x/Sc63iOYw/[/image]

Market structure shift

A liquidity sweep on its own does not prove a real reversal is happening, it could simply be a brief poke followed by continuation in the original direction. This layer exists to provide a second, independent confirmation that short term momentum has genuinely changed direction. The indicator runs its own separate, more sensitive swing detector and continuously tracks the most recent short term swing high and low. The moment a candle's closing price actually crosses back over that tracked high, a dashed line and a label mark the exact point where momentum flipped bullish, and the mirrored logic marks the moment momentum flips bearish beneath a tracked swing low.

[image]https://www.tradingview.com/x/QMeVaS2W/[/image]

How to read and use this indicator as one workflow

This indicator is designed to be read as a layered chain of evidence rather than as a single standalone signal. The trader should first look at the confirmed intermediate highs and lows to understand the broad structural map of where price has been reacting. Next, the fair value gaps and order blocks should be treated as the specific zones where a reaction is likely if price returns to test them, since these represent leftover institutional footprints and unresolved imbalances. Ideally during the higher quality New York session window that gets shaded, the trader should then watch for a liquidity sweep to occur at or near one of these zones, which suggests a stop hunt has just taken place and large players may have just finished building a position. Finally, the trader should wait for a market structure shift to confirm that short term momentum has actually flipped in the expected direction before trusting that the reversal is real rather than a temporary pause. Structure first, then zones of interest, then a trapping event at those zones, then a confirmed shift in momentum, and only when several of these line up together should the setup be considered a genuinely high probability reflection of institutional behavior rather than random noise. Every setting in the indicator, including all of the swing sensitivity lengths, the session window, the colors and the maximum number of active zones, is fully adjustable from the settings panel so the tool can be tuned to different symbols, timeframes and trading styles.

[image]https://www.tradingview.com/x/3SENA5T0/[/image]

Original script declaration and author verification

Script title, ICT SMC key Levels Execution. Author, Michael_Fx_Trader. Publisher, Michael_Fx_Trader. This is an original, from scratch implementation written entirely by Michael_Fx_Trader. It is not a copy, re upload, decompiled clone or re skin of any other author's protected or open source script, and no third party source code has been copied, translated line by line, or obfuscated and renamed to disguise its origin. The script implements well established, publicly documented Smart Money Concepts and ICT trading theory covering structure, fair value gaps, order blocks, liquidity sweeps, session timing, previous day levels and market structure shifts, all of which are general, non proprietary trading concepts described in widely available public trading education material. All of the detection logic, state management, drawing code and visual design in this script were independently written by the author using native Pine Script version six functions. All rights to this specific implementation belong to Michael_Fx_Trader, and this publication complies with TradingView House Rules on script originality, without mimicking, mashing up or rehashing any single other author's published script.

## Source Code

````pine
// © Michael_Fx_Trader — All rights reserved.
//
// ============================================================================================
// ORIGINAL SCRIPT DECLARATION / AUTHOR VERIFICATION
// ============================================================================================
// Script Title      : ICT SMC key Levels Execution
// Author            : Michael_Fx_Trader
// Publisher         : Michael_Fx_Trader
// Original Work     : YES. This script is an original, from-scratch implementation written
//                      entirely by Michael_Fx_Trader. It is NOT a copy, re-upload, decompiled
//                      clone, or re-skin of any other author's protected or open-source script.
//                      No third-party source code has been copied, translated line-by-line, or
//                      obfuscated/renamed to disguise its origin.
// Concept Basis     : The script implements well-established, publicly documented Smart Money
//                      Concepts / ICT trading theory (structure, fair value gaps, order blocks,
//                      liquidity sweeps, session timing, previous day levels, market structure
//                      shifts). These are general, non-proprietary trading concepts described in
//                      widely available public trading education material. All detection logic,
//                      state management, drawing code, and visual design in this script were
//                      independently written by the author using Pine Script v6 native functions.
// Rights            : All rights to this specific implementation belong to Michael_Fx_Trader.
// Declaration       : The author confirms this publication complies with TradingView House
//                      Rules on script originality and does not mimic, mash up, or rehash any
//                      single other author's published script.
// ============================================================================================

//@version=6
indicator("ICT SMC key Levels Execution", shorttitle = "ICT SMC KLE", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ============================================================================================
// USER-DEFINED TYPES
// ============================================================================================
// A Fair Value Gap zone: an unfilled three-candle imbalance box that is tracked until mitigated.
type FVGZone
    box   zoneBox
    label zoneLabel
    float top
    float bottom
    bool  isBull

// An Order Block zone: the real body of a confirmed swing pivot candle, tracked until invalidated.
type OBZone
    box   zoneBox
    label zoneLabel
    float top
    float bottom
    bool  isBull

// ============================================================================================
// INPUTS
// ============================================================================================

// ---- Structure (Intermediate High / Low) ----
grpStruct        = "Structure  ·  Intermediate High / Low"
structLen        = input.int(15, "Swing Length (Structure)", minval = 2, group = grpStruct, tooltip = "Number of bars checked on each side of a candle to confirm it as a significant swing high/low.")
showStruct       = input.bool(true, "Show Intermediate High / Low Badges", group = grpStruct)
ithColor         = input.color(color.new(color.red, 0),   "Intermediate High Badge Color", group = grpStruct)
itlColor         = input.color(color.new(color.green, 0), "Intermediate Low Badge Color",  group = grpStruct)

// ---- Fair Value Gaps ----
grpFVG           = "Fair Value Gaps"
showFVG          = input.bool(true, "Show Fair Value Gaps", group = grpFVG)
bullFVGColor     = input.color(color.new(color.teal, 80),  "Bullish FVG Fill", group = grpFVG)
bearFVGColor     = input.color(color.new(color.red, 80),   "Bearish FVG Fill", group = grpFVG)
bullFVGBorder    = input.color(color.new(color.teal, 0),   "Bullish FVG Border", group = grpFVG)
bearFVGBorder    = input.color(color.new(color.red, 0),    "Bearish FVG Border", group = grpFVG)
maxFVGCount      = input.int(15, "Max Active FVG Boxes", minval = 1, maxval = 60, group = grpFVG)

// ---- Order Blocks ----
grpOB            = "Order Blocks"
showOB           = input.bool(true, "Show Order Blocks", group = grpOB)
obLen            = input.int(25, "Swing Length (Order Blocks)", minval = 2, group = grpOB, tooltip = "Wider lookback used specifically to hunt for order block origin candles.")
bullOBColor      = input.color(color.new(color.blue, 80),  "Bullish OB Fill", group = grpOB)
bearOBColor      = input.color(color.new(color.orange, 80),"Bearish OB Fill", group = grpOB)
bullOBBorder     = input.color(color.new(color.blue, 0),   "Bullish OB Border", group = grpOB)
bearOBBorder     = input.color(color.new(color.orange, 0), "Bearish OB Border", group = grpOB)
maxOBCount       = input.int(10, "Max Active OB Boxes", minval = 1, maxval = 60, group = grpOB)

// ---- Liquidity Sweeps ----
grpSweep         = "Liquidity Sweeps"
showSweep        = input.bool(true, "Show Liquidity Sweeps", group = grpSweep)
sweepLen         = input.int(10, "Swing Length (Liquidity Sweeps)", minval = 2, group = grpSweep)
sweepBullColor   = input.color(color.new(color.green, 0), "Bullish Sweep Color", group = grpSweep)
sweepBearColor   = input.color(color.new(color.red, 0),   "Bearish Sweep Color", group = grpSweep)

// ---- Market Structure Shift ----
grpMSS           = "Market Structure Shift (MSS)"
showMSS          = input.bool(true, "Show Market Structure Shift", group = grpMSS)
mssLen           = input.int(5, "Swing Length (MSS)", minval = 1, group = grpMSS, tooltip = "More sensitive/short-term lookback used purely for momentum confirmation.")
mssBullColor     = input.color(color.new(color.green, 0), "Bullish MSS Color", group = grpMSS)
mssBearColor     = input.color(color.new(color.red, 0),   "Bearish MSS Color", group = grpMSS)

// ---- New York Session Highlight ----
grpSession       = "New York Session Highlight"
showSession      = input.bool(true, "Highlight New York Session", group = grpSession)
nySession        = input.session("1330-2000", "New York Session Window (Exchange Time, UTC-based)", group = grpSession)
sessionColor     = input.color(color.new(color.teal, 90), "Session Background Color", group = grpSession)

// ---- Previous Day High / Low ----
grpPDHL          = "Previous Day High / Low"
showPDHL         = input.bool(true, "Show Previous Day High / Low", group = grpPDHL)
pdhColor         = input.color(color.new(color.red, 0),   "Previous Day High Color", group = grpPDHL)
pdlColor         = input.color(color.new(color.green, 0), "Previous Day Low Color",  group = grpPDHL)

// ============================================================================================
// GLOBAL STATE VARIABLES
// ============================================================================================

var array<FVGZone> fvgZones = array.new<FVGZone>()
var array<OBZone>  obZones  = array.new<OBZone>()

// Liquidity sweep tracked levels (own dedicated sensitivity, cleared once used).
var float sweepHighVal = na
var int   sweepHighBar = na
var float sweepLowVal  = na
var int   sweepLowBar  = na

// Market structure shift tracked levels (short-term, own dedicated sensitivity).
var float mssHighVal = na
var int   mssHighBar = na
var float mssLowVal  = na
var int   mssLowBar  = na

// Previous day high/low bookkeeping.
var float dayHigh   = na
var float dayLow    = na
var float pdh       = na
var float pdl       = na
var line  pdhLine   = na
var line  pdlLine   = na
var label pdhLabel  = na
var label pdlLabel  = na

// ============================================================================================
// 1) STRUCTURE — INTERMEDIATE HIGH / LOW BADGES
// ============================================================================================
// A candle is confirmed as a significant swing point only once "structLen" bars have printed
// on both sides without breaking it, so these badges always appear retroactively.

structPH = ta.pivothigh(high, structLen, structLen)
structPL = ta.pivotlow(low, structLen, structLen)

if not na(structPH)
    if showStruct
        label.new(bar_index - structLen, structPH, "ITH", style = label.style_label_down, color = ithColor, textcolor = color.white, size = size.small)
    // feed the confirmed swing high into the liquidity sweep tracker (dedicated sweepLen pivots handled separately below)

if not na(structPL)
    if showStruct
        label.new(bar_index - structLen, structPL, "ITL", style = label.style_label_up, color = itlColor, textcolor = color.white, size = size.small)

// ============================================================================================
// 2) FAIR VALUE GAPS (3-candle imbalance)
// ============================================================================================

bullFVGCond = low > high[2]
bearFVGCond = high < low[2]

if bullFVGCond and showFVG
    zoneTop    = low
    zoneBottom = high[2]
    newBox = box.new(bar_index - 2, zoneTop, bar_index, zoneBottom, border_color = bullFVGBorder, bgcolor = bullFVGColor, border_width = 1)
    newLabel = label.new(bar_index, zoneTop, "FVG", style = label.style_label_left, color = color.new(color.white, 100), textcolor = bullFVGBorder, size = size.tiny)
    newZone = FVGZone.new(newBox, newLabel, zoneTop, zoneBottom, true)
    array.push(fvgZones, newZone)
    if array.size(fvgZones) > maxFVGCount
        oldest = array.shift(fvgZones)
        box.delete(oldest.zoneBox)
        label.delete(oldest.zoneLabel)

if bearFVGCond and showFVG
    zoneTop    = low[2]
    zoneBottom = high
    newBox = box.new(bar_index - 2, zoneTop, bar_index, zoneBottom, border_color = bearFVGBorder, bgcolor = bearFVGColor, border_width = 1)
    newLabel = label.new(bar_index, zoneTop, "FVG", style = label.style_label_left, color = color.new(color.white, 100), textcolor = bearFVGBorder, size = size.tiny)
    newZone = FVGZone.new(newBox, newLabel, zoneTop, zoneBottom, false)
    array.push(fvgZones, newZone)
    if array.size(fvgZones) > maxFVGCount
        oldest = array.shift(fvgZones)
        box.delete(oldest.zoneBox)
        label.delete(oldest.zoneLabel)

// Extend active FVG boxes (and their "FVG" tag) to the right edge, and delete any that have been mitigated.
if array.size(fvgZones) > 0
    for i = array.size(fvgZones) - 1 to 0
        zone = array.get(fvgZones, i)
        mitigated = zone.isBull ? close < zone.bottom : close > zone.top
        if mitigated
            box.delete(zone.zoneBox)
            label.delete(zone.zoneLabel)
            array.remove(fvgZones, i)
        else
            box.set_right(zone.zoneBox, bar_index)
            label.set_x(zone.zoneLabel, bar_index)

// ============================================================================================
// 3) ORDER BLOCKS
// ============================================================================================
// Uses its own wider lookback ("obLen") to hunt for confirmed swing pivots, then boxes only the
// real body (open-to-close) of that pivot candle — the wick is treated as a rejected probe.

obPH = ta.pivothigh(high, obLen, obLen)
obPL = ta.pivotlow(low, obLen, obLen)

if not na(obPH) and showOB
    pivotBarIdx = bar_index - obLen
    obTop    = math.max(open[obLen], close[obLen])
    obBottom = math.min(open[obLen], close[obLen])
    newBox = box.new(pivotBarIdx, obTop, bar_index, obBottom, border_color = bearOBBorder, bgcolor = bearOBColor, border_width = 1)
    newLabel = label.new(bar_index, obTop, "ORDER BLOCK", style = label.style_label_left, color = color.new(color.white, 100), textcolor = bearOBBorder, size = size.tiny)
    newZone = OBZone.new(newBox, newLabel, obTop, obBottom, false)
    array.push(obZones, newZone)
    if array.size(obZones) > maxOBCount
        oldest = array.shift(obZones)
        box.delete(oldest.zoneBox)
        label.delete(oldest.zoneLabel)

if not na(obPL) and showOB
    pivotBarIdx = bar_index - obLen
    obTop    = math.max(open[obLen], close[obLen])
    obBottom = math.min(open[obLen], close[obLen])
    newBox = box.new(pivotBarIdx, obTop, bar_index, obBottom, border_color = bullOBBorder, bgcolor = bullOBColor, border_width = 1)
    newLabel = label.new(bar_index, obBottom, "ORDER BLOCK", style = label.style_label_left, color = color.new(color.white, 100), textcolor = bullOBBorder, size = size.tiny)
    newZone = OBZone.new(newBox, newLabel, obTop, obBottom, true)
    array.push(obZones, newZone)
    if array.size(obZones) > maxOBCount
        oldest = array.shift(obZones)
        box.delete(oldest.zoneBox)
        label.delete(oldest.zoneLabel)

// Extend active OB boxes (and their "ORDER BLOCK" tag) to the right edge, and delete any that have
// been invalidated by a close through the wrong side of the zone.
if array.size(obZones) > 0
    for i = array.size(obZones) - 1 to 0
        zone = array.get(obZones, i)
        invalidated = zone.isBull ? close < zone.bottom : close > zone.top
        if invalidated
            box.delete(zone.zoneBox)
            label.delete(zone.zoneLabel)
            array.remove(obZones, i)
        else
            box.set_right(zone.zoneBox, bar_index)
            label.set_x(zone.zoneLabel, bar_index)

// ============================================================================================
// 4) LIQUIDITY SWEEPS
// ============================================================================================
// Tracks the most recent unbroken swing high/low (dedicated "sweepLen" sensitivity). A sweep
// fires when a candle's wick breaches the level intrabar but the close fails to hold beyond it.

sweepPH = ta.pivothigh(high, sweepLen, sweepLen)
sweepPL = ta.pivotlow(low, sweepLen, sweepLen)

if not na(sweepPH)
    sweepHighVal := sweepPH
    sweepHighBar := bar_index - sweepLen

if not na(sweepPL)
    sweepLowVal := sweepPL
    sweepLowBar := bar_index - sweepLen

// Bearish sweep: wick pokes above the tracked high, close fails back below it.
if not na(sweepHighVal) and high > sweepHighVal and close < sweepHighVal
    if showSweep
        line.new(sweepHighBar, sweepHighVal, bar_index, sweepHighVal, color = sweepBearColor, width = 1, style = line.style_solid)
        label.new(bar_index, sweepHighVal, "Liquidity Sweep", style = label.style_label_down, color = sweepBearColor, textcolor = color.white, size = size.tiny)
    sweepHighVal := na
    sweepHighBar := na

// Bullish sweep: wick pokes below the tracked low, close fails back above it.
if not na(sweepLowVal) and low < sweepLowVal and close > sweepLowVal
    if showSweep
        line.new(sweepLowBar, sweepLowVal, bar_index, sweepLowVal, color = sweepBullColor, width = 1, style = line.style_solid)
        label.new(bar_index, sweepLowVal, "Liquidity Sweep", style = label.style_label_up, color = sweepBullColor, textcolor = color.white, size = size.tiny)
    sweepLowVal := na
    sweepLowBar := na

// ============================================================================================
// 5) NEW YORK SESSION HIGHLIGHT
// ============================================================================================

inSession = not na(time(timeframe.period, nySession))
bgcolor(showSession and inSession ? sessionColor : na)

// ============================================================================================
// 6) PREVIOUS DAY HIGH / LOW (self-deleting once touched)
// ============================================================================================

isNewDay = ta.change(time("D")) != 0

if isNewDay
    // Finalize yesterday's completed high/low into the tracked previous-day levels.
    if not na(dayHigh) and not na(dayLow)
        pdh := dayHigh
        pdl := dayLow
        if not na(pdhLine)
            line.delete(pdhLine)
        if not na(pdlLine)
            line.delete(pdlLine)
        if not na(pdhLabel)
            label.delete(pdhLabel)
        if not na(pdlLabel)
            label.delete(pdlLabel)
        if showPDHL
            pdhLine  := line.new(bar_index, pdh, bar_index, pdh, color = pdhColor, width = 1, style = line.style_dashed)
            pdlLine  := line.new(bar_index, pdl, bar_index, pdl, color = pdlColor, width = 1, style = line.style_dashed)
            pdhLabel := label.new(bar_index, pdh, "PDH", style = label.style_label_left, color = pdhColor, textcolor = color.white, size = size.tiny)
            pdlLabel := label.new(bar_index, pdl, "PDL", style = label.style_label_left, color = pdlColor, textcolor = color.white, size = size.tiny)
    dayHigh := high
    dayLow  := low
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow  := na(dayLow)  ? low  : math.min(dayLow, low)

// Extend active lines to the current bar.
if not na(pdhLine)
    line.set_x2(pdhLine, bar_index)
if not na(pdlLine)
    line.set_x2(pdlLine, bar_index)

// Delete the level the instant price actually trades through it — it is no longer a resting target.
if not na(pdh) and high >= pdh
    line.delete(pdhLine)
    label.delete(pdhLabel)
    pdhLine  := na
    pdhLabel := na
    pdh      := na

if not na(pdl) and low <= pdl
    line.delete(pdlLine)
    label.delete(pdlLabel)
    pdlLine  := na
    pdlLabel := na
    pdl      := na

// ============================================================================================
// 7) MARKET STRUCTURE SHIFT (MSS) — short-term momentum confirmation layer
// ============================================================================================

mssPH = ta.pivothigh(high, mssLen, mssLen)
mssPL = ta.pivotlow(low, mssLen, mssLen)

if not na(mssPH)
    mssHighVal := mssPH
    mssHighBar := bar_index - mssLen

if not na(mssPL)
    mssLowVal := mssPL
    mssLowBar := bar_index - mssLen

// Bullish shift: close crosses up and over the tracked short-term swing high.
if not na(mssHighVal) and close > mssHighVal
    if showMSS
        line.new(mssHighBar, mssHighVal, bar_index, mssHighVal, color = mssBullColor, width = 1, style = line.style_dashed)
        label.new(math.round(math.avg(mssHighBar, bar_index)), mssHighVal, "MSS", style = label.style_label_down, color = color.new(color.white, 100), textcolor = mssBullColor, size = size.tiny)
    mssHighVal := na
    mssHighBar := na

// Bearish shift: close crosses down and under the tracked short-term swing low.
if not na(mssLowVal) and close < mssLowVal
    if showMSS
        line.new(mssLowBar, mssLowVal, bar_index, mssLowVal, color = mssBearColor, width = 1, style = line.style_dashed)
        label.new(math.round(math.avg(mssLowBar, bar_index)), mssLowVal, "MSS", style = label.style_label_up, color = color.new(color.white, 100), textcolor = mssBearColor, size = size.tiny)
    mssLowVal := na
    mssLowBar := na
````
