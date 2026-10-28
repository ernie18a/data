# Wyckoff Accumulation Hunter

- url: https://www.tradingview.com/script/ahOVqVbm-Wyckoff-Accumulation-Hunter/
- type: indicator
- pine_id: PUB;8dfe2462432c4bc9b6bf198ff8cb182f
- version: 12.0

## Description

Surfaces potential accumulation setups in deep-drawdown names where demand may be absorbing supply — built around classic Wyckoff structure (selling climax, spring, accumulation range) with a scored, rules-based filter.

How eligibility works
A name becomes eligible only when it's at least 30% off its 2-year high and meets a liquidity floor. Eligible names are then scored 0–10 across eight conditions: drawdown depth, position relative to the 21 and 55 EMAs, selling-climax recency, range compression, volume dry-up, StochRSI reset, and proximity to the structural demand floor.

How an entry prints
An entry marker appears only when the score clears the threshold you set AND structure confirms — either a spring (an undercut-and-reclaim of the structural low) or a retracement into the 0.618–0.786 zone at EMA confluence. A base-maturity check prevents firing during waterfalls (it requires the broken low to have actually held), and signals confirm on bar close.

Conviction tagging
A filled green triangle marks a spring at the demand floor (highest conviction — invalidation sits right at the floor). A hollow gray triangle marks a spring up in the range, with the floor still open below.

On-chart structure
Three liquidity bands map the markdown: green demand, gray range, red supply. A fibonacci ladder (0.236 → 1.272) projects from the base low as a reference for managing a position, and a red line marks the invalidation level at the spring low — volume-gated, so a low-volume test poke doesn't count, only a genuine high-volume break.

Inputs
Adjustable threshold (set your own conviction level), lookback lengths (scale to any timeframe), and all display toggles.

Notes
Works on any timeframe once lookbacks are scaled; designed and tuned on the weekly. Repaint-free — all signals confirm on close, no lookahead. This is a discretionary analysis tool to surface setups for your own research. It is not a recommendation or financial advice, and prior structure does not guarantee future behavior.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//  WYCKOFF ACCUMULATION HUNTER 2.0— cleaned (2026-07-21)
//  Aligned with the Python scanner (us_wyckoff_scan.py). Repaint-free.
//  + short-history guard: clamps long lookbacks to bars available so
//    recent IPOs don't return NaN off-high.
//
//  CLEANUP NOTES (2026-07-21): removed everything not part of the
//  validated gate or genuinely necessary visual context:
//    - Fib-retrace/pivot alternate entry path (retraceRaw) — never
//      validated, not part of the scanner's logic. entrySig is now
//      spring-only, matching the scanner exactly.
//    - Wyckoff-purist filters toggle — optional complexity, unvalidated.
//    - The 0-10 score system — explicitly shown by today's backtests to
//      carry NO edge (score 7/8/9 median edge ~flat). Removed rather
//      than kept as decorative "context".
//    - deepSpring — dead code since DEEP Monster Watch was removed.
//    - The one-off "EXPERIMENTAL: any-band spring" diamond — was a
//      throwaway visual test, not a kept feature.
//  What's left: PRIME/SECONDARY/DEEP band, spring trigger (precise
//  penetration+recovery spec), RS-vs-market, discount-zone, IDEAL+,
//  invalidation, fib EXIT ladder, liquidity bands, EMA 21/55 context.
// ════════════════════════════════════════════════════════════════════
indicator("Wyckoff Accumulation Hunter", overlay = true, max_labels_count = 100, max_boxes_count = 20, max_lines_count = 60)

isWeekly = timeframe.isweekly

// ───────────── INPUTS ─────────────
ddPrimeHi    = input.float(-30.0, "PRIME band: shallow edge (% off high)", group="Edge (validated)", tooltip="-30 to -45% off high = the validated PRIME band.")
ddPrimeLo    = input.float(-45.0, "PRIME band: deep edge", group="Edge (validated)")
ddSecLo      = input.float(-60.0, "SECONDARY floor (neutral below PRIME)", group="Edge (validated)", tooltip="-45 to -60% = weaker/neutral. Below -60% = DEEP, no demonstrated edge for single stocks.")
emaFastLen   = input.int(21,  "Fast EMA", minval = 5)
emaSlowLen   = input.int(55,  "Slow EMA", minval = 20)
lenHigh      = input.int(104, "Major-high lookback (bars)", minval = 20, tooltip = "Weekly: 104 (~2y).")
lenMid       = input.int(52,  "52-bar floor lookback", minval = 10, tooltip = "Weekly: 52 (~1y).")
structLow    = input.int(52,  "Structural low (band + spring)", minval = 20)
ddGatePct    = input.float(30.0, "GATE: min % off 2y high", minval = 10, step = 5)
minDollarVol = input.float(5.0,  "GATE: min avg $ vol (M/d)", minval = 0, step = 1)
cooldownBars = input.int(12, "Signal cooldown (bars)", minval = 0)
maxNewLows   = input.int(1, "Base maturity: max new lows /10 bars", minval = 0)
agedBars     = input.int(8, "Spring level age (bars)", minval = 0)
springWin    = input.int(4, "Spring reclaim window (weeks)", minval = 1, maxval = 10, group = "Triggers")
invalVolZ    = input.float(1.0, "Invalidation min volume z-score", step = 0.25)
invalPct     = input.float(12.0, "Invalidation: % below spring low", step = 1.0, minval = 1.0, maxval = 40.0, tooltip = "Matches the scanner's own validated exit-rule backtest (scale 50% at +12%, invalidate at -12%).")
maxTradeBars = input.int(26, "Invalidation expires after N bars", minval = 4, maxval = 104, group = "Triggers")
maxStopDist  = input.float(40.0, "Max stop distance below price (%)", minval = 10, maxval = 70, group = "Triggers")
showEMAs     = input.bool(true,  "Show 21/55 EMA lines")
showFibs     = input.bool(true,  "Draw fib exit ladder on entry")
showTable    = input.bool(true,  "Show status table")
showBands    = input.bool(true,  "Show liquidity bands (demand/range/supply)")
showInval    = input.bool(true,  "Show invalidation line (spring-low stop)")
showSetup    = input.bool(false, "Highlight setup state (edge band at floor)", group = "Display")
showDiag     = input.bool(false, "Show live gate diagnostic (debug)", group = "Display")

benchSymbol   = input.symbol("AMEX:SPY", "Relative-strength benchmark", group = "New signals (validated, matches scanner)")
rsLookback    = input.int(40, "RS-vs-market lookback (bars)", minval = 10, group = "New signals (validated, matches scanner)")
discLookback  = input.int(40, "Discount-zone lookback (bars)", minval = 10, group = "New signals (validated, matches scanner)")

// ───────────── SHORT-HISTORY GUARD ─────────────
barsAvail  = bar_index + 1
effHigh    = math.min(lenHigh,   barsAvail)
effMid     = math.min(lenMid,    barsAvail)
effStruct  = math.min(structLow, barsAvail)
enoughHist = barsAvail >= math.max(lenHigh, emaSlowLen)

// ───────────── CORE ─────────────
emaF = ta.ema(close, emaFastLen)
emaS = ta.ema(close, emaSlowLen)
hi104  = ta.highest(close, effHigh)
ddPct  = (close - hi104) / hi104 * 100.0
volMu  = ta.sma(volume, effMid)
volSd  = ta.stdev(volume, effMid)
volZ   = volSd > 0 ? (volume - volMu) / volSd : 0.0
dollarVolM = close * volume / 5.0 / 1e6
avgDolVolM = ta.sma(dollarVolM, 12)

floorLo = ta.lowest(low, effStruct)
floorHi = floorLo * 1.12

// ───────────── GATES ─────────────
gateDD   = ddPct <= -ddGatePct
gateLiq  = avgDolVolM >= minDollarVol
eligible = gateDD and gateLiq

inPrime = ddPct <= ddPrimeHi and ddPct > ddPrimeLo
inSec   = ddPct <= ddPrimeLo and ddPct > ddSecLo
inDeep  = ddPct <= ddSecLo
inEdge  = inPrime or inSec
ddBand  = inPrime ? "PRIME" : inSec ? "SECONDARY" : inDeep ? "DEEP" : "shallow"

// ───────────── TRIGGER (spring only — matches the scanner exactly) ─────────────
isNewLow52 = low <= ta.lowest(low, effMid)[1]
newLows10  = math.sum(isNewLow52 ? 1 : 0, 10)
baseMature = newLows10 <= maxNewLows + 1

agedWin   = math.min(40, math.max(barsAvail - agedBars, 1))
sup_ref   = ta.lowest(low, agedWin)[agedBars]
reclaimQ  = close > open and (high - low > 0 ? (close - low) / (high - low) : 0) >= 0.5

lowestLowW  = ta.lowest(low, springWin)
lowestClsW  = ta.lowest(close, springWin)
springThisBar = low      < sup_ref      and close > sup_ref      and reclaimQ
springPrevBar = low[1]   < sup_ref[1]   and close[1] < sup_ref[1] and close > sup_ref[1] and reclaimQ
springMultiWk = lowestLowW[1] < sup_ref and lowestClsW[1] < sup_ref and close > sup_ref and close[1] <= sup_ref and reclaimQ
springTrig  = springThisBar or springPrevBar or springMultiWk
springRaw   = eligible and inEdge and baseMature and barstate.isconfirmed and springTrig

var int lastSigBar = -9999
cooldownOK = bar_index - lastSigBar >= cooldownBars
entrySig   = springRaw and cooldownOK
if entrySig
    lastSigBar := bar_index

inDemand = close <= floorHi
topEntry = entrySig and inDemand and inPrime

// ═══════════════════════════════════════════════════════════════════════
// ── RS-vs-market + discount-zone (matches scanner) ────────────────────────
// ═══════════════════════════════════════════════════════════════════════
benchClose = request.security(benchSymbol, timeframe.period, close)
rsLine     = benchClose > 0 ? close / benchClose : na

priceLo    = ta.lowest(low, rsLookback)
priceHi    = ta.highest(high, rsLookback)
pricePos   = (priceHi > priceLo) ? (close - priceLo) / (priceHi - priceLo) : 0.5
rsLo       = ta.lowest(rsLine, rsLookback)
rsHi       = ta.highest(rsLine, rsLookback)
rsPos      = (rsHi > rsLo) ? (rsLine - rsLo) / (rsHi - rsLo) : 0.5
rsBullDiv  = not na(rsLine) and pricePos <= 0.40 and (rsPos - pricePos) >= 0.15

discHi     = ta.highest(high, discLookback)
discLo     = ta.lowest(low, discLookback)
rangePos   = (discHi > discLo) ? (close - discLo) / (discHi - discLo) : 0.5
inDiscount = rangePos < 0.5

idealPlus  = topEntry and rsBullDiv and inDiscount

topEntryLive   = eligible and inEdge and baseMature and springTrig and inDemand and inPrime
idealPlusLive  = topEntryLive and rsBullDiv and inDiscount and not barstate.isconfirmed

// ───────────── SETUP STATE (persistent, optional) ──────────────
atFloor    = close >= floorLo * 0.90 and close <= floorHi
setupState = eligible and inEdge and atFloor and baseMature
aplusState = setupState and inPrime
bgcolor(showSetup ? (aplusState ? color.new(#D4AF37, 92) : setupState ? color.new(#00BCD4, 95) : na) : na, title = "Setup state")

// ── LIVE GATE DIAGNOSTIC (optional debug) ──────────────────────────────────
var label diagLbl = na
if showDiag and barstate.islast
    label.delete(diagLbl)
    gDD     = ddPct <= -ddGatePct
    gBand   = inEdge
    gBase   = baseMature
    gFloor  = inDemand
    gSpring = springTrig
    gConf   = barstate.isconfirmed
    block = (gDD ? "" : "drawdown ") + (gBand ? "" : (inDeep ? "DEEP-trap " : "shallow ")) + (gBase ? "" : "base ") + (gFloor ? "" : "floor ") + (gSpring ? "" : "no-spring ")
    verdict = entrySig ? "ENTRY FIRING NOW" : (gDD and gBand and gBase and gFloor and gSpring and not gConf) ? "ARMED - fires on this week's close" : "no entry - blocked by: " + block
    txt = "WYCKOFF GATES (live)\n"
         + "drawdown " + str.tostring(ddPct, "#") + "%   " + (gDD ? "OK" : "no") + "\n"
         + "edge band " + ddBand + "  " + (gBand ? "OK" : "no") + "\n"
         + "base matured   " + (gBase ? "OK" : "no") + "\n"
         + "at the floor   " + (gFloor ? "OK" : "no") + "\n"
         + "spring event   " + (gSpring ? "OK" : "no") + "\n"
         + "bar confirmed   " + (gConf ? "OK" : "forming") + "\n"
         + "RS-vs-market   " + (rsBullDiv ? "OK" : "no") + "\n"
         + "discount zone   " + (inDiscount ? "OK" : "no") + "\n"
         + "-> " + verdict
    diagLbl := label.new(bar_index, high, txt, style = label.style_label_left,
                 color = color.new(color.black, 15), textcolor = color.white,
                 size = size.small, textalign = text.align_left)

// ───────────── INVALIDATION TRACKING ─────────────
var bool  inTrade   = false
var float invalLvl  = na
var int   invalBar  = na
if entrySig
    inTrade  := true
    rawLow    = ta.lowest(low, 12)
    springLow = (na(rawLow) or rawLow <= 0) ? low : rawLow
    cand      = springLow * (1.0 - invalPct / 100.0)
    floorLvl  = close * (1.0 - maxStopDist / 100.0)
    ceilLvl   = close * 0.98
    invalLvl := math.min(math.max(cand, floorLvl), ceilLvl)
    invalBar := bar_index
stopHit = inTrade and not na(invalLvl) and barstate.isconfirmed and close < invalLvl and volZ >= invalVolZ
tradeStale = inTrade and not na(invalBar) and (bar_index - invalBar) > maxTradeBars
if stopHit or tradeStale
    inTrade  := false
    if tradeStale and not stopHit
        invalLvl := na
        invalBar := na

// ───────────── DISPLAY: EMAs ─────────────
plot(showEMAs ? emaF : na, "21 EMA", color = #7FFF00, linewidth = 1)
plot(showEMAs ? emaS : na, "55 EMA", color = #722F37, linewidth = 1)

// ───────────── DISPLAY: entry markers ─────────────
plotchar(entrySig and inDemand, "Floor spring (hist)", "▲", location.belowbar, color = color.new(#7FFF00, 60), size = size.tiny)

plotshape(idealPlus, "IDEAL+ ENTRY (validated, strict)", shape.triangleup, location.belowbar, color = color.new(#D4AF37, 0), size = size.tiny)

plotshape(idealPlusLive, "IDEAL+ forming (provisional)", shape.triangleup, location.belowbar, color = color.new(#D4AF37, 50), size = size.tiny)

// ── Signal strength score (1-10) — based ONLY on validated criteria ─────
// Not the old 0-10 score (shown today to carry no edge). This scores how
// many of the VALIDATED signals are present at entry: spring itself (base),
// RS-vs-market, discount-zone, and a bonus if both hit together (IDEAL+).
var int   lastEntryBar2 = na
var float lastEntryLow  = na
var bool  lastInDemand  = false
var int   lastSigStrength = 0
if entrySig
    lastEntryBar2 := bar_index
    lastEntryLow  := low
    lastInDemand  := inDemand
    sigStrength = 5 + (rsBullDiv ? 2 : 0) + (inDiscount ? 2 : 0) + ((rsBullDiv and inDiscount) ? 1 : 0)
    lastSigStrength := sigStrength
var label liveArrow = na
if barstate.islast and not na(lastEntryBar2)
    label.delete(liveArrow)
    arrowColor = lastSigStrength >= 10 ? color.new(#D4AF37, 0) : color.new(#7FFF00, 0)
    liveArrow := label.new(lastEntryBar2, lastEntryLow,
                 "▲ " + str.tostring(lastSigStrength) + "/10",
                 style = label.style_label_up, yloc = yloc.belowbar,
                 color = arrowColor, textcolor = color.black, size = size.normal)

// ───────────── DISPLAY: invalidation line ─────────────
var line  invalLine  = na
var label invalLabel = na
greenFire = entrySig
if showInval and greenFire
    if not na(invalLine)
        line.delete(invalLine)
        label.delete(invalLabel)
    invalLine  := line.new(invalBar, invalLvl, bar_index + 10, invalLvl, color = #722F37, width = 2, style = line.style_solid)
    invalLabel := label.new(bar_index + 10, invalLvl, "invalidation", style = label.style_label_left, color = color.new(color.black, 100), textcolor = #722F37, size = size.small)
if showInval and inTrade and not na(invalLine) and barstate.isconfirmed
    line.set_x2(invalLine, bar_index + 10)
    label.set_x(invalLabel, bar_index + 10)
    label.set_y(invalLabel, invalLvl)
if tradeStale and not stopHit and not na(invalLine)
    line.delete(invalLine)
    label.delete(invalLabel)
    invalLine  := na
    invalLabel := na
if showInval and stopHit
    if not na(invalLine)
        line.delete(invalLine)
        label.delete(invalLabel)
        invalLine  := na
        invalLabel := na

// ───────────── DISPLAY: fib exit ladder ──
var line[]  fibLines  = array.new<line>()
var label[] fibLabels = array.new<label>()
f_clearFibs() =>
    while array.size(fibLines) > 0
        line.delete(array.pop(fibLines))
    while array.size(fibLabels) > 0
        label.delete(array.pop(fibLabels))
if entrySig and showFibs
    f_clearFibs()
    loA = ta.lowest(low, 12)
    hiA = hi104
    fibArr = array.from(0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272)
    for i = 0 to array.size(fibArr) - 1
        fr  = array.get(fibArr, i)
        lvl = loA + (hiA - loA) * fr
        col = fr >= 1.0 ? color.new(color.red, 30) : color.new(color.red, 55)
        array.push(fibLines, line.new(bar_index, lvl, bar_index + 60, lvl, color = col, style = (fr == 0.618 or fr == 0.5 ? line.style_solid : line.style_dashed), width = (fr == 0.618 ? 2 : 1)))
        array.push(fibLabels, label.new(bar_index + 60, lvl, str.tostring(fr, "#.###") + "  " + str.tostring(lvl, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = col, size = size.small))

// ───────────── DISPLAY: liquidity bands ─────────────
var box demandBand = na
var box rangeBand  = na
var box supplyBand = na
if showBands and barstate.islast
    mLo  = floorLo
    mHi  = hi104
    span = mHi - mLo
    dTop = mLo + span * 0.30
    rTop = mLo + span * 0.618
    sTop = mHi
    L = bar_index - 60
    R = bar_index + 10
    if na(demandBand)
        demandBand := box.new(L, dTop, R, mLo,  border_color=color.new(color.red,40), bgcolor=color.new(color.red,82))
        rangeBand  := box.new(L, rTop, R, dTop, border_color=color.new(color.red,55), bgcolor=color.new(color.red,88))
        supplyBand := box.new(L, sTop, R, rTop, border_color=color.new(color.red,70), bgcolor=color.new(color.red,92))
    else
        box.set_lefttop(demandBand, L, dTop)
        box.set_rightbottom(demandBand, R, mLo)
        box.set_lefttop(rangeBand, L, rTop)
        box.set_rightbottom(rangeBand, R, dTop)
        box.set_lefttop(supplyBand, L, sTop)
        box.set_rightbottom(supplyBand, R, rTop)

// ───────────── STATUS TABLE ─────────────
var table tbl = table.new(position.top_right, 2, 6, border_width = 1)
if barstate.islast and showTable
    ddTxt    = not isWeekly ? "0%" : na(ddPct) ? "n/a" : str.tostring(ddPct, "#.0") + "%" + (enoughHist ? "" : "*")
    bandTxt  = not isWeekly ? "-" : not eligible ? "-" : inPrime ? "PRIME" : inSec ? "SECONDARY" : inDeep ? "DEEP" : "shallow"
    bandBg   = not isWeekly ? color.new(color.gray,50) : inPrime ? color.new(color.green,0) : inSec ? color.new(color.olive,20) : inDeep ? color.new(color.maroon,0) : color.new(color.gray,50)
    table.cell(tbl, 0, 0, "WYCKOFF AH", text_color = color.white, bgcolor = color.new(color.navy, 0))
    table.cell(tbl, 1, 0, bandTxt, text_color = color.white, bgcolor = bandBg)
    table.cell(tbl, 0, 1, "Off high", text_color = color.white, bgcolor = color.new(color.gray, 40))
    table.cell(tbl, 1, 1, ddTxt, text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(tbl, 0, 2, "Entry @", text_color = color.white, bgcolor = color.new(color.gray, 40))
    table.cell(tbl, 1, 2, not isWeekly ? "-" : "PRIME/SEC", text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(tbl, 0, 3, "Invalid @", text_color = color.white, bgcolor = color.new(color.gray, 40))
    table.cell(tbl, 1, 3, not isWeekly ? "-" : na(invalLvl) ? "-" : str.tostring(invalLvl, "#.##"), text_color = color.white, bgcolor = color.new(color.gray, 60))
    qualTxt = not isWeekly ? "-" : idealPlus ? "IDEAL+ 64%" : "-"
    qualBg  = not isWeekly ? color.new(color.gray,50) : idealPlus ? color.new(#D4AF37,0) : color.new(color.gray,60)
    table.cell(tbl, 0, 4, "Quality (scanner)", text_color = color.white, bgcolor = color.new(color.gray, 40))
    table.cell(tbl, 1, 4, qualTxt, text_color = idealPlus ? color.black : color.white, bgcolor = qualBg)
    sigTxt = not isWeekly ? "-" : (rsBullDiv ? "RS " : "") + (inDiscount ? "Disc" : "")
    sigTxt := sigTxt == "" ? "-" : sigTxt
    table.cell(tbl, 0, 5, "Signals hit", text_color = color.white, bgcolor = color.new(color.gray, 40))
    table.cell(tbl, 1, 5, sigTxt, text_color = color.white, bgcolor = color.new(color.teal, 60))

// ───────────── ALERTS ─────────────
alertcondition(entrySig and inDemand, "Wyckoff AH — FLOOR spring", "FLOOR spring on {{ticker}} | {{close}} (highest conviction)")
alertcondition(topEntry, "Wyckoff AH — PRIME entry", "PRIME entry on {{ticker}} | {{close}} — PRIME band at demand floor")
alertcondition(idealPlus, "Wyckoff AH — IDEAL+ ENTRY", "IDEAL+ ENTRY on {{ticker}} | {{close}} — matches scanner's highlight tier. Holdout: 64.3% win, n=126.")
alertcondition(entrySig and not inDemand, "Wyckoff AH — RANGE spring", "RANGE spring on {{ticker}} | {{close}}")
alertcondition(stopHit, "Wyckoff AH — INVALIDATED", "Setup invalidated on {{ticker}} — closed below spring low on volume")
````
