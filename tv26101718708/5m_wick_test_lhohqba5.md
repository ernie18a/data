# 5m Wick Test

- url: https://www.tradingview.com/script/LhOhQBA5-5m-Wick-Test/
- type: indicator
- pine_id: PUB;6d055003950b435fa4965be7da30680f
- version: 8.0

## Description

[b]5M WICK TEST SETUP[/b]
A 3-candle liquidity-sweep and reversal pattern detector with automatic entry, stop, and target levels.

[b]WHAT IT DOES[/b]
This indicator scans for a specific 3-candle price action pattern often referred to as a "wick test" or liquidity sweep setup — where price sweeps a recent high or low with a wicked candle, gets engulfed by a strong reversal candle, and then retests that swept level before continuing in the new direction.
When the full pattern confirms, the script automatically plots:
[list][*] [/list][b]Entry[/b] — Bar 1's wick extreme (the level Bar 3 must retest)
[list][*] [/list][b]Stop Loss[/b] — Bar 2's opposite extreme
[list][*] [/list][b]Breakeven[/b] — a reference line at your chosen distance from entry
[list][*] [/list][b]Target 1[/b] — a 1:1 risk-to-reward level
[list][*] [/list][b]Target 2[/b] — a fixed point distance from entry (fully adjustable, so it works across different instruments and volatility)
[list][*] [/list][b]Target 2R[/b] — a 1:2 risk-to-reward level

[b]HOW THE PATTERN WORKS[/b]
[b]Bar 1 (Setup Bar):[/b] Closes in the direction opposite the anticipated move (red for a bullish setup, green for a bearish setup) and has a wick on both sides — signaling a rejection at that level.
[b]Bar 2 (Engulfing Bar):[/b] A strong reversal candle that engulfs Bar 1's body and closes beyond Bar 1's wick, confirming a shift in momentum.
[b]Bar 3 (Execution Bar):[/b] Must be the bar immediately following Bar 2, and must retest back into Bar 1's wick level. If the very next candle doesn't retest, the setup is invalidated — no late or delayed "retests" get marked.
Both bullish and bearish setups are detected independently and can overlap — including cases where the same candle serves as Bar 3 of one setup and Bar 1 of the opposite setup.
[b]Features[/b]
[b]Configurable strictness[/b] — toggle whether Bar 1 needs a directional close, whether Bar 2 must close beyond Bar 1's full wick, and whether Bar 2's open must fully engulf Bar 1's close (the textbook engulfing-candle definition), so you can dial the pattern between a loose and a strict interpretation.
[b]Optional swing-point filter[/b] — require Bar 1 or Bar 2 to represent a genuine local swing high/low, filtering out reversals that occur randomly mid-trend.
[b]Individually toggleable levels[/b] — show or hide each of the six lines independently, with full color, width, and style customization.
[b]Rolling chart history[/b] — keeps your last several confirmed setups visible on the chart (configurable count), automatically removing the oldest as new ones confirm, so your chart stays readable without manual cleanup.
[b]Built-in alerts[/b] — separate alert conditions for setup confirmation and valid Bar 3 retests, for both directions.

[b]HOW TO USE[/b]
Add the indicator to a 5-minute chart (or any timeframe — the logic is timeframe-agnostic). When a BUY or SELL label appears on Bar 2, watch the very next candle for a retest of the marked entry level. If price retests, the full level set draws automatically. If it doesn't, the setup silently invalidates and no levels are drawn.
Use the Pattern Rules settings to match the strictness of the pattern to your own trading style, and the Visuals settings to customize the look to fit your chart.

[b]DISCLAIMER[/b]
This script is for educational and informational purposes only. It does not constitute financial advice, and past pattern behavior is not indicative of future results. Always use proper risk management and backtest thoroughly before trading any strategy live.

## Source Code

````pine
//@version=6
indicator("5m Wick Test", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────────────────────────────────
// Bundles every drawing object that belongs to one confirmed setup, so a
// whole setup can be deleted together when it ages out of the history queue.
type SetupDraw
    line  entryLine
    line  slLine
    line  tp1Line
    line  tp2Line
    line  tp2RLine
    line  beLine
    label entryLbl
    label slLbl
    label tp1Lbl
    label tp2Lbl
    label tp2RLbl
    label beLbl
    label dirLbl   // the BUY / SELL marker from Bar 2
    label posSizeLblEntry // position-sizing label anchored at Entry
    label posSizeLblSL    // position-sizing label anchored at Stop Loss

// ─────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────
grpPattern    = "Pattern Rules"
strictBar1Col = input.bool(true, "Require Bar 1 Directional Close (strict)",
                 tooltip = "ON (default): Bar 1 must close red for bullish / green for bearish, exactly as originally specified. OFF: Bar 1 only needs a wick in the relevant direction — lets a shared candle qualify as Bar 3 of one setup and Bar 1 of the opposite setup, regardless of its close color.",
                 group = grpPattern)
strictBar2Wick = input.bool(true, "Require Bar 2 Close Beyond Bar 1's Full Wick (strict)",
                 tooltip = "ON (default): Bar 2 must close beyond Bar 1's full high/low (wick tip included) — the original strict rule. OFF: Bar 2 only needs to engulf Bar 1's body.",
                 group = grpPattern)
strictBar2Open = input.bool(false, "Require Bar 2 Open to Fully Engulf Bar 1's Close (strict)",
                 tooltip = "ON (default): Bar 2's open must be at or below Bar 1's close (bullish) / at or above Bar 1's close (bearish) — the textbook engulfing-candle definition. OFF: Bar 2 only needs its close to clear Bar 1's opposite side; its open can sit slightly inside Bar 1's body without disqualifying the setup.",
                 group = grpPattern)
useSwingFilter = input.bool(false, "Require Bar 1 or Bar 2 to be a Genuine Swing Point",
                 tooltip = "OFF (default): no swing-point requirement. ON: the setup only qualifies if either (a) Bar 1 is the swing point — the candle to its left has a higher low for bullish / lower high for bearish, or (b) Bar 2 is the swing point — Bar 2's low is lower than Bar 1's low for bullish / Bar 2's high is higher than Bar 1's high for bearish. Filters out reversals that occur randomly mid-trend rather than at a true local extreme.",
                 group = grpPattern)

grpTargets   = "Target Settings"
targetPoints = input.float(10.0, "Target 2 Points", minval = 0.0, group = grpTargets,
                 tooltip = "Raw price points added to (or subtracted from) the entry price for Target 2.")
bePoints     = input.float(5.0, "Breakeven Line Distance (points from entry)", minval = 0.0, group = grpTargets,
                 tooltip = "Distance used to draw the informational Breakeven line on the chart.")

grpRisk       = "Position Sizing"
showPosSize   = input.bool(true, "Show Position Size Label", group = grpRisk,
                 tooltip = "Calculates contracts to risk based on the Entry-to-Stop distance and displays it as a label, independent of the 'Show Level Price Labels' setting.")
riskMode      = input.string("Dollar Amount", "Risk Mode", options = ["Dollar Amount", "Percent of Account"], group = grpRisk)
riskDollars   = input.float(500.0, "Risk Amount ($)", minval = 0.0, group = grpRisk,
                 tooltip = "Used when Risk Mode is set to Dollar Amount.")
accountSize   = input.float(50000.0, "Account Size ($)", minval = 0.0, group = grpRisk,
                 tooltip = "Used when Risk Mode is set to Percent of Account.")
riskPercent   = input.float(1.0, "Risk Percent (%)", minval = 0.0, group = grpRisk,
                 tooltip = "Used when Risk Mode is set to Percent of Account.")
posSizeContract = input.string("Chart Symbol (Current)", "Position Sizing Contract", options = ["Chart Symbol (Current)", "Micro Equivalent", "Custom Point Value"], group = grpRisk,
                 tooltip = "Chart Symbol: uses the point value of whatever you're currently watching (e.g. NQ). Micro Equivalent: divides that by 10 — correct for standard-to-micro CME pairs (NQ->MNQ, ES->MES, YM->MYM, RTY->M2K, CL->MCL, GC->MGC all use a 10x ratio). Custom: enter any point value manually below for pairs that aren't a 10x ratio.")
customPointValue = input.float(2.0, "Custom Point Value ($/point)", minval = 0.0, group = grpRisk,
                 tooltip = "Only used when Position Sizing Contract is set to 'Custom Point Value'.")
posSizeLoc    = input.string("BUY/SELL Flag", "Position Size Label Location", options = ["BUY/SELL Flag", "Entry Line", "Stop Loss Line", "Both (Entry & SL)"], group = grpRisk,
                 tooltip = "BUY/SELL Flag: shows the contract count inside the existing BUY/SELL marker on Bar 2, rather than as a separate label.")
colPosSize    = input.color(color.white, "Position Size Label Color", group = grpRisk)
posSizeFontSel = input.string("Tiny", "Position Size Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpRisk)

// Convert the font size dropdown into the actual size constant
posSizeFont() =>
    sz = size.tiny
    if posSizeFontSel == "Small"
        sz := size.small
    else if posSizeFontSel == "Normal"
        sz := size.normal
    else if posSizeFontSel == "Large"
        sz := size.large
    else if posSizeFontSel == "Huge"
        sz := size.huge
    sz

// Resolve which dollar-per-point value to actually use for sizing
posSizePointValue() =>
    pv = syminfo.pointvalue
    if posSizeContract == "Micro Equivalent"
        pv := syminfo.pointvalue / 10
    else if posSizeContract == "Custom Point Value"
        pv := customPointValue
    pv

// Contracts = risk dollars / (stop distance in points * the selected contract's dollar value per point)
// Rounded to 2 decimals rather than floored, since micro contracts allow finer sizing.
calcContracts(entryPx, slPx) =>
    dist = math.abs(entryPx - slPx)
    riskAmt = riskMode == "Percent of Account" ? accountSize * riskPercent / 100 : riskDollars
    pv = posSizePointValue()
    dist > 0 and pv > 0 ? math.round(riskAmt / (dist * pv), 1) : na

posSizeText(contracts) =>
    str.tostring(contracts, "#.#") + " contract" + (contracts == 1.0 ? "" : "s")

grpHistory    = "Chart History"
maxSetupsKeep = input.int(10, "Setups to Keep on Chart (per direction)", minval = 1, maxval = 20, group = grpHistory,
                 tooltip = "Confirmed setups remain drawn on the chart. Once more than this many bullish (or bearish) setups exist, the oldest one is removed to make room for the newest.")

grpVisual     = "Visuals"
showBuyLabel  = input.bool(true, "Show BUY / SELL Labels on Bar 2", group = grpVisual)
showEntryLine = input.bool(true, "Show Entry Line", group = grpVisual)
colEntry      = input.color(#000000,                     "Entry Line Color (Bar 1 High / Low)", group = grpVisual)
showSLLine    = input.bool(true, "Show Stop Loss Line", group = grpVisual)
colSL         = input.color(color.red,                    "Stop Loss Line Color (Bar 2 Low / High)", group = grpVisual)
showBELine    = input.bool(false, "Show Breakeven Line", group = grpVisual)
colBE         = input.color(color.new(color.blue, 0),      "Breakeven Line Color (Entry \u00b1 BE Points)", group = grpVisual)
showTP1Line   = input.bool(true, "Show Target 1 (1:1 RR) Line", group = grpVisual)
colTP1        = input.color(color.new(#2962FF, 0),         "Target 1 Line Color", group = grpVisual)
showTP2Line   = input.bool(true, "Show Target 2 (Points) Line", group = grpVisual)
colTP2        = input.color(color.new(#D4AF37, 0),          "Target 2 Line Color", group = grpVisual)
showTP2RLine  = input.bool(true, "Show Target 2R (1:2 RR) Line", group = grpVisual)
colTP2R       = input.color(color.new(#9C27B0, 0),           "Target 2R Line Color", group = grpVisual)
showLevelText = input.bool(false, "Show Level Price Labels", group = grpVisual)
lineStyleSel  = input.string("Solid", "Level Line Style", options = ["Solid", "Dashed", "Dotted"], group = grpVisual)
lineWidthSel  = input.int(2, "Level Line Width (px)", minval = 1, maxval = 4, group = grpVisual)

// Convert the dropdown selection into the actual line.style constant
lineStyle() =>
    style = line.style_solid
    if lineStyleSel == "Dashed"
        style := line.style_dashed
    else if lineStyleSel == "Dotted"
        style := line.style_dotted
    style

// x1/x2 for level lines, confined to the current bar's width using the
// same xloc.bar_index system the price labels already use successfully.
barBoundsX() =>
    [bar_index, bar_index + 1]

// Delete every drawing that belongs to one setup
deleteSetupDraw(SetupDraw sd) =>
    line.delete(sd.entryLine)
    line.delete(sd.slLine)
    line.delete(sd.tp1Line)
    line.delete(sd.tp2Line)
    line.delete(sd.tp2RLine)
    line.delete(sd.beLine)
    label.delete(sd.entryLbl)
    label.delete(sd.slLbl)
    label.delete(sd.tp1Lbl)
    label.delete(sd.tp2Lbl)
    label.delete(sd.tp2RLbl)
    label.delete(sd.beLbl)
    label.delete(sd.dirLbl)
    label.delete(sd.posSizeLblEntry)
    label.delete(sd.posSizeLblSL)

// Push a newly confirmed setup into the history queue; trim the oldest if over capacity
pushAndTrim(array<SetupDraw> hist, SetupDraw sd, int maxKeep) =>
    array.push(hist, sd)
    if array.size(hist) > maxKeep
        oldest = array.shift(hist)
        deleteSetupDraw(oldest)

// ─────────────────────────────────────────────────────────────────────────
// STATE (persists across bars) — separate tracks for bullish / bearish
// ─────────────────────────────────────────────────────────────────────────
var float entryPriceBull  = na
var float slPriceBull     = na
var float tp1PriceBull    = na
var float tp2PriceBull    = na
var float tp2RPriceBull   = na
var SetupDraw pendingBullDraw = na   // Bar 2's preview drawing, awaiting Bar 3 confirmation

var float entryPriceBear  = na
var float slPriceBear     = na
var float tp1PriceBear    = na
var float tp2PriceBear    = na
var float tp2RPriceBear   = na
var SetupDraw pendingBearDraw = na   // Bar 2's preview drawing, awaiting Bar 3 confirmation

var array<SetupDraw> bullHistory = array.new<SetupDraw>()
var array<SetupDraw> bearHistory = array.new<SetupDraw>()

var int bullResolvedBar = -1   // bar_index of the last Bar 3 already resolved for bull, prevents re-processing on later ticks of the same bar
var int bearResolvedBar = -1

// ─────────────────────────────────────────────────────────────────────────
// PATTERN LOGIC
// Bar 1 = bar[1] (setup bar)   Bar 2 = current bar (engulfing/confirmation bar)
// ─────────────────────────────────────────────────────────────────────────

// --- Bar 1 (Setup Bar) conditions ---
bar1Red        = close[1] < open[1]                        // must close red
bar1Green      = close[1] > open[1]                         // must close green
bar1UpperWick  = high[1] > math.max(open[1], close[1])      // has an upper wick
bar1LowerWick  = low[1]  < math.min(open[1], close[1])      // has a lower wick
bar1BothWicks  = bar1UpperWick and bar1LowerWick             // has BOTH a wick high and a wick low
bar1SetupBull  = strictBar1Col ? (bar1Red and bar1BothWicks) : bar1UpperWick
bar1SetupBear  = strictBar1Col ? (bar1Green and bar1BothWicks) : bar1LowerWick

// --- Bar 2 (Engulfing Bar) conditions ---
bar2Bullish         = close > open                           // bullish candle
bar2Bearish         = close < open                            // bearish candle
bar2EngulfsBody     = (strictBar2Open ? open <= close[1] : true) and close >= open[1]   // engulfs bar1's body (bullish direction)
bar2EngulfsBodyBear = (strictBar2Open ? open >= close[1] : true) and close <= open[1]   // engulfs bar1's body (bearish direction)
bar2ClosesAboveWick = close > high[1]                          // closes strictly above bar1's high (wick top)
bar2ClosesBelowWick = close < low[1]                            // closes strictly below bar1's low (wick bottom)

// --- Swing Point filter (optional) ---
// Bullish: valid if Bar 1 is the swing low (candle to its left has a higher
// low), OR Bar 2 is the swing low (Bar 2's low undercuts Bar 1's low).
// Bearish: mirrored using highs.
swingOKBull = not useSwingFilter or (low[2] > low[1]) or (low[1] > low)
swingOKBear = not useSwingFilter or (high[2] < high[1]) or (high[1] < high)

setupTriggeredBull = bar1SetupBull and bar2Bullish and bar2EngulfsBody     and (strictBar2Wick ? bar2ClosesAboveWick : true) and swingOKBull
setupTriggeredBear = bar1SetupBear and bar2Bearish and bar2EngulfsBodyBear and (strictBar2Wick ? bar2ClosesBelowWick : true) and swingOKBear

// ─────────────────────────────────────────────────────────────────────────
// BAR 3 CHECK — runs FIRST each bar, using LAST bar's trigger (setupTriggeredBull[1]).
// Bar 3 must be exactly the bar immediately after Bar 2. If it doesn't retest
// Bar 1's level right here, the setup is invalid and the entire preview gets
// deleted. This must execute before the "Bar 2 new setup" block below so a
// fresh setup on this same bar doesn't overwrite pending data before it's read.
// ─────────────────────────────────────────────────────────────────────────
bar3ChanceBull = setupTriggeredBull[1]
bar3ChanceBear = setupTriggeredBear[1]

if bar3ChanceBull and bar_index != bullResolvedBar
    if low <= entryPriceBull
        // Valid Bar 3 retest — extend the Bar 2 preview lines to also cover
        // this bar and confirm the setup into history
        line.set_x2(pendingBullDraw.entryLine, bar_index + 1)
        line.set_x2(pendingBullDraw.slLine, bar_index + 1)
        line.set_x2(pendingBullDraw.beLine, bar_index + 1)
        line.set_x2(pendingBullDraw.tp1Line, bar_index + 1)
        line.set_x2(pendingBullDraw.tp2Line, bar_index + 1)
        line.set_x2(pendingBullDraw.tp2RLine, bar_index + 1)

        pushAndTrim(bullHistory, pendingBullDraw, maxSetupsKeep)
        bullResolvedBar := bar_index
        pendingBullDraw := na
    else if barstate.isconfirmed
        // Bar 3 has FULLY CLOSED and never retested — only now is it safe to
        // invalidate. Checking on every intrabar tick would delete the preview
        // the instant Bar 3 opens, before it's had any chance to dip and retest.
        deleteSetupDraw(pendingBullDraw)
        bullResolvedBar := bar_index
        pendingBullDraw := na

if bar3ChanceBear and bar_index != bearResolvedBar
    if high >= entryPriceBear
        line.set_x2(pendingBearDraw.entryLine, bar_index + 1)
        line.set_x2(pendingBearDraw.slLine, bar_index + 1)
        line.set_x2(pendingBearDraw.beLine, bar_index + 1)
        line.set_x2(pendingBearDraw.tp1Line, bar_index + 1)
        line.set_x2(pendingBearDraw.tp2Line, bar_index + 1)
        line.set_x2(pendingBearDraw.tp2RLine, bar_index + 1)

        pushAndTrim(bearHistory, pendingBearDraw, maxSetupsKeep)
        bearResolvedBar := bar_index
        pendingBearDraw := na
    else if barstate.isconfirmed
        deleteSetupDraw(pendingBearDraw)
        bearResolvedBar := bar_index
        pendingBearDraw := na

// ─────────────────────────────────────────────────────────────────────────
// BAR 2 — NEW SETUP CONFIRMATION. Runs after the Bar 3 check above so it
// can't clobber a still-pending preview before that block reads it.
// Draws a live preview of all levels immediately — this preview either gets
// extended and confirmed on Bar 3, or fully deleted if Bar 3 doesn't retest.
// ─────────────────────────────────────────────────────────────────────────
if setupTriggeredBull
    entryPriceBull := high[1]                                            // Bar 1 High
    slPriceBull    := low                                                 // Bar 2 Low
    tp1PriceBull   := entryPriceBull + (entryPriceBull - slPriceBull)     // 1:1 RR
    tp2PriceBull   := entryPriceBull + targetPoints
    tp2RPriceBull  := entryPriceBull + 2 * (entryPriceBull - slPriceBull) // 1:2 RR

    contractsBull = calcContracts(entryPriceBull, slPriceBull)
    showContractsInFlag = showPosSize and posSizeLoc == "BUY/SELL Flag" and not na(contractsBull)
    buyText = showContractsInFlag ? "BUY\n" + posSizeText(contractsBull) : "BUY"

    dirLblBull = showBuyLabel ? label.new(bar_index, low - (high - low) * 0.75, text = buyText,
                 style = label.style_label_up, color = color.green, textcolor = color.white, size = size.small) : na

    [lx1, lx2] = barBoundsX()
    bePriceBull = entryPriceBull + bePoints

    entryLine = showEntryLine ? line.new(lx1, entryPriceBull, lx2, entryPriceBull,
         xloc = xloc.bar_index, extend = extend.none, color = colEntry, width = lineWidthSel, style = lineStyle()) : na
    slLine = showSLLine ? line.new(lx1, slPriceBull, lx2, slPriceBull,
         xloc = xloc.bar_index, extend = extend.none, color = colSL, width = lineWidthSel, style = lineStyle()) : na
    beLine = showBELine ? line.new(lx1, bePriceBull, lx2, bePriceBull,
         xloc = xloc.bar_index, extend = extend.none, color = colBE, width = lineWidthSel, style = lineStyle()) : na
    tp1Line = showTP1Line ? line.new(lx1, tp1PriceBull, lx2, tp1PriceBull,
         xloc = xloc.bar_index, extend = extend.none, color = colTP1, width = lineWidthSel, style = lineStyle()) : na
    tp2Line = showTP2Line ? line.new(lx1, tp2PriceBull, lx2, tp2PriceBull,
         xloc = xloc.bar_index, extend = extend.none, color = colTP2, width = lineWidthSel, style = lineStyle()) : na
    tp2RLine = showTP2RLine ? line.new(lx1, tp2RPriceBull, lx2, tp2RPriceBull,
         xloc = xloc.bar_index, extend = extend.none, color = colTP2R, width = lineWidthSel, style = lineStyle()) : na

    entryLbl = (showLevelText and showEntryLine) ? label.new(bar_index, entryPriceBull, text = "Entry " + str.tostring(entryPriceBull, format.mintick),
         style = label.style_none, textcolor = colEntry, size = size.tiny, textalign = text.align_left) : na
    slLbl = (showLevelText and showSLLine) ? label.new(bar_index, slPriceBull, text = "SL " + str.tostring(slPriceBull, format.mintick),
         style = label.style_none, textcolor = colSL, size = size.tiny, textalign = text.align_left) : na
    beLbl = (showLevelText and showBELine) ? label.new(bar_index, bePriceBull, text = "BE " + str.tostring(bePriceBull, format.mintick),
         style = label.style_none, textcolor = colBE, size = size.tiny, textalign = text.align_left) : na
    tp1Lbl = (showLevelText and showTP1Line) ? label.new(bar_index, tp1PriceBull, text = "TP1 " + str.tostring(tp1PriceBull, format.mintick),
         style = label.style_none, textcolor = colTP1, size = size.tiny, textalign = text.align_left) : na
    tp2Lbl = (showLevelText and showTP2Line) ? label.new(bar_index, tp2PriceBull, text = "TP2 " + str.tostring(tp2PriceBull, format.mintick),
         style = label.style_none, textcolor = colTP2, size = size.tiny, textalign = text.align_left) : na
    tp2RLbl = (showLevelText and showTP2RLine) ? label.new(bar_index, tp2RPriceBull, text = "TP 2R " + str.tostring(tp2RPriceBull, format.mintick),
         style = label.style_none, textcolor = colTP2R, size = size.tiny, textalign = text.align_left) : na

    label posSizeLblEntryBull = na
    label posSizeLblSLBull = na
    if showPosSize and not na(contractsBull) and posSizeLoc != "BUY/SELL Flag"
        posTxt = posSizeText(contractsBull)
        if posSizeLoc == "Entry Line" or posSizeLoc == "Both (Entry & SL)"
            posSizeLblEntryBull := label.new(bar_index, entryPriceBull, text = posTxt,
                 style = label.style_none, textcolor = colPosSize, size = posSizeFont(), textalign = text.align_right)
        if posSizeLoc == "Stop Loss Line" or posSizeLoc == "Both (Entry & SL)"
            posSizeLblSLBull := label.new(bar_index, slPriceBull, text = posTxt,
                 style = label.style_none, textcolor = colPosSize, size = posSizeFont(), textalign = text.align_right)

    pendingBullDraw := SetupDraw.new(entryLine, slLine, tp1Line, tp2Line, tp2RLine, beLine, entryLbl, slLbl, tp1Lbl, tp2Lbl, tp2RLbl, beLbl, dirLblBull, posSizeLblEntryBull, posSizeLblSLBull)

if setupTriggeredBear
    entryPriceBear := low[1]                                             // Bar 1 Low
    slPriceBear    := high                                                // Bar 2 High
    tp1PriceBear   := entryPriceBear - (slPriceBear - entryPriceBear)     // 1:1 RR
    tp2PriceBear   := entryPriceBear - targetPoints
    tp2RPriceBear  := entryPriceBear - 2 * (slPriceBear - entryPriceBear) // 1:2 RR

    contractsBear = calcContracts(entryPriceBear, slPriceBear)
    showContractsInFlagBear = showPosSize and posSizeLoc == "BUY/SELL Flag" and not na(contractsBear)
    sellText = showContractsInFlagBear ? "SELL\n" + posSizeText(contractsBear) : "SELL"

    dirLblBear = showBuyLabel ? label.new(bar_index, high + (high - low) * 0.75, text = sellText,
                 style = label.style_label_down, color = color.red, textcolor = color.white, size = size.small) : na

    [lx1, lx2] = barBoundsX()
    bePriceBear = entryPriceBear - bePoints

    entryLine = showEntryLine ? line.new(lx1, entryPriceBear, lx2, entryPriceBear,
         xloc = xloc.bar_index, extend = extend.none, color = colEntry, width = lineWidthSel, style = lineStyle()) : na
    slLine = showSLLine ? line.new(lx1, slPriceBear, lx2, slPriceBear,
         xloc = xloc.bar_index, extend = extend.none, color = colSL, width = lineWidthSel, style = lineStyle()) : na
    beLine = showBELine ? line.new(lx1, bePriceBear, lx2, bePriceBear,
         xloc = xloc.bar_index, extend = extend.none, color = colBE, width = lineWidthSel, style = lineStyle()) : na
    tp1Line = showTP1Line ? line.new(lx1, tp1PriceBear, lx2, tp1PriceBear,
         xloc = xloc.bar_index, extend = extend.none, color = colTP1, width = lineWidthSel, style = lineStyle()) : na
    tp2Line = showTP2Line ? line.new(lx1, tp2PriceBear, lx2, tp2PriceBear,
         xloc = xloc.bar_index, extend = extend.none, color = colTP2, width = lineWidthSel, style = lineStyle()) : na
    tp2RLine = showTP2RLine ? line.new(lx1, tp2RPriceBear, lx2, tp2RPriceBear,
         xloc = xloc.bar_index, extend = extend.none, color = colTP2R, width = lineWidthSel, style = lineStyle()) : na

    entryLbl = (showLevelText and showEntryLine) ? label.new(bar_index, entryPriceBear, text = "Entry " + str.tostring(entryPriceBear, format.mintick),
         style = label.style_none, textcolor = colEntry, size = size.tiny, textalign = text.align_left) : na
    slLbl = (showLevelText and showSLLine) ? label.new(bar_index, slPriceBear, text = "SL " + str.tostring(slPriceBear, format.mintick),
         style = label.style_none, textcolor = colSL, size = size.tiny, textalign = text.align_left) : na
    beLbl = (showLevelText and showBELine) ? label.new(bar_index, bePriceBear, text = "BE " + str.tostring(bePriceBear, format.mintick),
         style = label.style_none, textcolor = colBE, size = size.tiny, textalign = text.align_left) : na
    tp1Lbl = (showLevelText and showTP1Line) ? label.new(bar_index, tp1PriceBear, text = "TP1 " + str.tostring(tp1PriceBear, format.mintick),
         style = label.style_none, textcolor = colTP1, size = size.tiny, textalign = text.align_left) : na
    tp2Lbl = (showLevelText and showTP2Line) ? label.new(bar_index, tp2PriceBear, text = "TP2 " + str.tostring(tp2PriceBear, format.mintick),
         style = label.style_none, textcolor = colTP2, size = size.tiny, textalign = text.align_left) : na
    tp2RLbl = (showLevelText and showTP2RLine) ? label.new(bar_index, tp2RPriceBear, text = "TP 2R " + str.tostring(tp2RPriceBear, format.mintick),
         style = label.style_none, textcolor = colTP2R, size = size.tiny, textalign = text.align_left) : na

    label posSizeLblEntryBear = na
    label posSizeLblSLBear = na
    if showPosSize and not na(contractsBear) and posSizeLoc != "BUY/SELL Flag"
        posTxt = posSizeText(contractsBear)
        if posSizeLoc == "Entry Line" or posSizeLoc == "Both (Entry & SL)"
            posSizeLblEntryBear := label.new(bar_index, entryPriceBear, text = posTxt,
                 style = label.style_none, textcolor = colPosSize, size = posSizeFont(), textalign = text.align_right)
        if posSizeLoc == "Stop Loss Line" or posSizeLoc == "Both (Entry & SL)"
            posSizeLblSLBear := label.new(bar_index, slPriceBear, text = posTxt,
                 style = label.style_none, textcolor = colPosSize, size = posSizeFont(), textalign = text.align_right)

    pendingBearDraw := SetupDraw.new(entryLine, slLine, tp1Line, tp2Line, tp2RLine, beLine, entryLbl, slLbl, tp1Lbl, tp2Lbl, tp2RLbl, beLbl, dirLblBear, posSizeLblEntryBear, posSizeLblSLBear)

// ─────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(setupTriggeredBull, title = "Bullish Setup Locked In",
     message = "5m Wick Test Setup: Bullish pattern confirmed. Bar 3 must retest the entry level immediately or the setup is invalid.")

alertcondition(bar3ChanceBull and low <= entryPriceBull,
     title = "Bullish Retest Entry Trigger",
     message = "5m Wick Test Setup: Bar 3 retested the entry level (Bar 1 High). Valid entry.")

alertcondition(setupTriggeredBear, title = "Bearish Setup Locked In",
     message = "5m Wick Test Setup: Bearish pattern confirmed. Bar 3 must retest the entry level immediately or the setup is invalid.")

alertcondition(bar3ChanceBear and high >= entryPriceBear,
     title = "Bearish Retest Entry Trigger",
     message = "5m Wick Test Setup: Bar 3 retested the entry level (Bar 1 Low). Valid entry.")
````
