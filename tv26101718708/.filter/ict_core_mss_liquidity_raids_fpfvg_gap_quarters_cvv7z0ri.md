# ICT Core: MSS, Liquidity Raids, FPFVG & Gap Quarters

- url: https://www.tradingview.com/script/cVV7Z0rI-ICT-Core-MSS-Liquidity-Raids-FPFVG-Gap-Quarters/
- type: indicator
- pine_id: PUB;2f8a975d43b44da0b84df5b0674530c5
- version: 1.0

## Description

ICT Core is an overlay that organizes the main concepts taught by the Inner Circle Trader into one chart, with strict, non-repainting logic. It is built to help you read context — where liquidity rests, where price is imbalanced, and what time it is — not to generate buy/sell signals.

WHAT IT SHOWS

Market Structure Shift (MSS)
A structure break is labeled MSS only when it happens with displacement: a large-body candle (default: body ≥ 1.2× ATR14) that also leaves a fair value gap, within the last few bars. Breaks without displacement do not flip the structure. An optional "BMS" label marks continuation breaks.

OTE zone
After each MSS, the 62–79% retracement of the displacement leg is drawn, with a 70.5% line. The zone extends with the leg until price first retraces into it, then freezes. It is removed if price closes back through the leg's origin or after a set number of bars.

Liquidity (BSL / SSL)
Buy-side and sell-side liquidity is tracked at prior day high/low, prior week high/low, Asia and London session highs/lows, swing highs/lows, and relative equal highs/lows (REH/REL).
- Raid: price trades through a level and closes back on the original side within a short window (default 2 bars).
- Run: price trades through and holds beyond the window. Runs are not marked as raids.

PD arrays
- FVGs labeled BISI / SIBI, with consequent encroachment (50%) lines.
- Inversion FVGs: a gap that price closes through flips role and is relabeled IFVG.
- First Presented FVG (FPFVG): the first FVG whose first candle opens in the 09:30–10:00 ET window (editable). Kept as a reference for two days.
- NWOG and NDOG with quarter levels (0, 0.25, 0.50, 0.75, 1).
- Balanced price ranges (BPR), volume imbalances (consecutive ones grouped), and optional order blocks with mean threshold.

Dealing range
Premium, discount, and equilibrium of the current swing range.

Time
Killzone shading (Asia, London, NY AM, London Close, NY PM), Silver Bullet windows, and midnight / 08:30 / 09:30 opening prices. Macro windows appear as a line along the bottom of the chart. Each macro window has its own on/off, time, and "Verified" setting, so you can mark only the windows you have confirmed yourself. Verified windows draw solid; unverified ones draw faint with a "Macro?" tag.

SMT divergence
Compares swing highs/lows against a correlated symbol (default ES1!), with an optional second symbol for triad SMT.

Optional
CBDR and Asian range standard-deviation projections.

HOW IT'S BUILT

- All signals use confirmed data and do not repaint. Higher-timeframe and daily/weekly values use closed candles only.
- Anything based on swing pivots confirms N bars after the pivot forms. This lag is inherent and disclosed in the settings.
- A "nearest N" display filter shows only the FVGs closest to price, to reduce clutter. Hidden gaps keep updating in the background.
- All times are locked to New York time regardless of your chart's timezone.
- Alerts: presets for MSS, BSL/SSL raids, OTE entry, and SMT, plus detailed messages via "Any alert() function call".

PARAMETER CHOICES

ICT defines several concepts discretionarily. Where a number was needed, the choice is an input you can change, not an official definition: the displacement threshold, dealing-range pivot length, killzone hours, raid window, and the order block definition (last opposing candle body before the displacement candle).

NOTES

Designed for intraday charts, primarily index futures (NQ/MNQ, ES/MES). On equity charts such as SPY, enable extended hours and consider disabling the Asia/London features.

This script is an independent, original implementation and is not affiliated with, endorsed by, or connected to the Inner Circle Trader (ICT) or Michael J. Huddleston. It is an educational charting tool and does not provide financial advice or trading signals.

## Source Code

````pine
// =============================================================================
//  ICT Core  (v1.3.1)
//  v1.3.1: ta.change() calls moved out of conditional expressions (clears compiler warning).
//  v1.3: quarters of a gap (0.25/0.75) on NWOG/NDOG; IFVG promoted to a
//        standard option (on by default); consecutive volume imbalances
//        grouped into one zone; First Presented FVG (FPFVG).
//  v1.2: each macro window is its own input (on/off, time, verified).
//        Verified windows: solid blue line + "Macro" tag.
//        Unverified windows: faint blue line + "Macro?" tag.
//  v1.1: macros draw as a line pinned to the bottom of the chart.
//  Built only from high-confidence ICT concepts. No VWAP, no Initial Balance,
//  no SMC-community terms (BOS/CHoCH, inducement, quarterly theory).
// -----------------------------------------------------------------------------
//  Included:
//   • Market Structure Shift (MSS) — structure break that requires DISPLACEMENT
//     (optional "BMS" label for continuation breaks)
//   • OTE zone (62–79%, 70.5% line) on the displacement leg after an MSS
//   • Dealing range: premium / discount / equilibrium
//   • Liquidity: BSL / SSL at old highs/lows (PDH/PDL, PWH/PWL, Asia & London
//     H/L), swing highs/lows, relative equal highs/lows (REH/REL);
//     "raid" = taken and reclaimed, "run" = taken with acceptance
//   • PD arrays: FVG as BISI / SIBI with consequent encroachment (CE),
//     volume imbalance, BPR, NWOG / NDOG with CE, order block + mean threshold
//   • Time: killzones, Silver Bullet windows, midnight / 08:30 / 09:30 opens
//   • SMT divergence (NQ vs ES, optional YM for the triad)
//   • CBDR and Asian range standard-deviation projections (optional)
//  [verify] — off by default, check against source material first:
//   • Macro time windows (per-window 'Verified' flags)
//  Parameters that are the AUTHOR'S choices, not ICT definitions:
//   displacement threshold, dealing-range pivot length, killzone hours (editable),
//   OB = last opposing candle body before the displacement candle.
//  All signals use confirmed data; pivots confirm N bars late (disclosed lag).
//  Dynamic messages: create one alert with "Any alert() function call".
//  Sessions locked to America/New_York regardless of chart timezone.
// =============================================================================

//@version=6
indicator("ICT Core", "ICT Core", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500)

TZ = "America/New_York"
CLEAR = color.new(color.black, 100)

// ── Inputs: time ──────────────────────────────────────────────────────────────
grpT = "Time — killzones & windows (ET)"
kzShow = input.bool(true, "Killzone shading", group = grpT)
kzAsiaOn = input.bool(true, "Asia", inline = "k1", group = grpT)
kzAsia = input.session("2000-0000", "", inline = "k1", group = grpT)
cAsia = input.color(color.new(#c678dd, 0), "", inline = "k1", group = grpT)
kzLonOn = input.bool(true, "London", inline = "k2", group = grpT)
kzLon = input.session("0200-0500", "", inline = "k2", group = grpT)
cLon = input.color(color.new(#56b6c2, 0), "", inline = "k2", group = grpT)
kzNYAOn = input.bool(true, "NY AM", inline = "k3", group = grpT)
kzNYA = input.session("0700-1000", "", inline = "k3", group = grpT)
cNYA = input.color(color.new(#e5c07b, 0), "", inline = "k3", group = grpT)
kzLCOn = input.bool(false, "London Close", inline = "k4", group = grpT)
kzLC = input.session("1000-1200", "", inline = "k4", group = grpT)
cLC = input.color(color.new(#e06c75, 0), "", inline = "k4", group = grpT)
kzNYPOn = input.bool(true, "NY PM", inline = "k5", group = grpT)
kzNYP = input.session("1330-1600", "", inline = "k5", group = grpT)
cNYP = input.color(color.new(#98c379, 0), "", inline = "k5", group = grpT)
sbShow = input.bool(true, "Silver Bullet windows (03–04, 10–11, 14–15)", group = grpT)
cSB = input.color(color.new(#ffffff, 0), "Silver Bullet color", group = grpT)

grpMC = "Macro windows (ET) — on/off · time · verified"
macroShow = input.bool(true, "Show macros (line at bottom of chart)", group = grpMC)
cMacro = input.color(color.new(#2196f3, 0), "Macro color", group = grpMC)
mcOn1 = input.bool(true, "", inline = "m1", group = grpMC)
mcS1 = input.session("0233-0300", "", inline = "m1", group = grpMC)
mcV1 = input.bool(false, "Verified", inline = "m1", group = grpMC)
mcOn2 = input.bool(true, "", inline = "m2", group = grpMC)
mcS2 = input.session("0403-0430", "", inline = "m2", group = grpMC)
mcV2 = input.bool(false, "Verified", inline = "m2", group = grpMC)
mcOn3 = input.bool(true, "", inline = "m3", group = grpMC)
mcS3 = input.session("0850-0910", "", inline = "m3", group = grpMC)
mcV3 = input.bool(false, "Verified", inline = "m3", group = grpMC)
mcOn4 = input.bool(true, "", inline = "m4", group = grpMC)
mcS4 = input.session("0950-1010", "", inline = "m4", group = grpMC)
mcV4 = input.bool(false, "Verified", inline = "m4", group = grpMC)
mcOn5 = input.bool(true, "", inline = "m5", group = grpMC)
mcS5 = input.session("1050-1110", "", inline = "m5", group = grpMC)
mcV5 = input.bool(true, "Verified", inline = "m5", group = grpMC)
mcOn6 = input.bool(true, "", inline = "m6", group = grpMC)
mcS6 = input.session("1150-1210", "", inline = "m6", group = grpMC)
mcV6 = input.bool(false, "Verified", inline = "m6", group = grpMC)
mcOn7 = input.bool(true, "", inline = "m7", group = grpMC)
mcS7 = input.session("1310-1340", "", inline = "m7", group = grpMC)
mcV7 = input.bool(false, "Verified", inline = "m7", group = grpMC)
mcOn8 = input.bool(true, "", inline = "m8", group = grpMC)
mcS8 = input.session("1515-1545", "", inline = "m8", group = grpMC)
mcV8 = input.bool(false, "Verified", inline = "m8", group = grpMC)

grpO = "Opening prices"
showMidOpen = input.bool(true, "Midnight open (true day open)", group = grpO)
show830 = input.bool(true, "08:30 open", group = grpO)
show930 = input.bool(true, "09:30 open", group = grpO)
cMidO = input.color(color.new(#1abc9c, 0), "Midnight open color", group = grpO)
c830 = input.color(color.new(#bdc3c7, 0), "08:30 color", group = grpO)
c930 = input.color(color.new(#ecf0f1, 0), "09:30 color", group = grpO)

// ── Inputs: liquidity ─────────────────────────────────────────────────────────
grpLQ = "Liquidity — BSL / SSL"
showLiq = input.bool(true, "Track liquidity & raids", group = grpLQ)
showPD = input.bool(true, "PDH / PDL", group = grpLQ)
showPW = input.bool(true, "PWH / PWL", group = grpLQ)
showAsiaHL = input.bool(true, "Asia high / low", group = grpLQ)
showLonHL = input.bool(true, "London high / low", group = grpLQ)
showSwingPools = input.bool(false, "Show resting swing liquidity (dotted)", group = grpLQ)
lqLen = input.int(10, "Swing liquidity pivot length", minval = 2, maxval = 50, group = grpLQ)
reTol = input.float(0.10, "Relative equal highs/lows tolerance (× ATR14, 0 = off)", minval = 0.0, step = 0.05, group = grpLQ)
raidWin = input.int(2, "Raid reclaim window (bars, incl. breach bar)", minval = 1, maxval = 10, group = grpLQ)
raidPen = input.int(1, "Min penetration (ticks)", minval = 1, group = grpLQ)
swingMax = input.int(15, "Max swing pools per side", minval = 3, maxval = 60, group = grpLQ)
raidKeep = input.int(30, "Max raid marks kept", minval = 5, maxval = 150, group = grpLQ)
showRuns = input.bool(false, "Keep 'run' levels (taken with acceptance), faded", group = grpLQ)
cBSL = input.color(color.new(#e74c3c, 0), "BSL (resting above)", group = grpLQ)
cSSL = input.color(color.new(#2ecc71, 0), "SSL (resting below)", group = grpLQ)
cRaidBSL = input.color(color.new(#ff5d8f, 0), "BSL raid", group = grpLQ)
cRaidSSL = input.color(color.new(#00e676, 0), "SSL raid", group = grpLQ)

// ── Inputs: structure / OTE / dealing range ──────────────────────────────────
grpMS = "Market Structure Shift (displacement required)"
showMSS = input.bool(true, "Show MSS", group = grpMS)
showBMS = input.bool(false, "Label continuation breaks (BMS)", group = grpMS)
msLen = input.int(5, "Swing pivot length (bars each side)", minval = 2, maxval = 50, group = grpMS)
dispATR = input.float(1.2, "Displacement: candle body ≥ × ATR14", minval = 0.3, step = 0.1, tooltip = "ICT does not define displacement numerically — this threshold is a parameter choice.", group = grpMS)
dispBars = input.int(3, "Displacement must occur within last N bars", minval = 1, maxval = 10, group = grpMS)
dispNeedFvg = input.bool(true, "Displacement must leave an FVG", group = grpMS)
cMSSBull = input.color(color.new(#2ecc71, 0), "Bullish MSS", group = grpMS)
cMSSBear = input.color(color.new(#e74c3c, 0), "Bearish MSS", group = grpMS)

grpOTE = "OTE (after MSS)"
showOTE = input.bool(true, "Show OTE zone (62–79%, 70.5%)", group = grpOTE)
oteMaxBars = input.int(120, "OTE expires after N bars", minval = 10, group = grpOTE)
cOTE = input.color(color.new(#f39c12, 85), "OTE color", group = grpOTE)

grpDR = "Dealing range"
showDR = input.bool(true, "Premium / discount / equilibrium", group = grpDR)
drLen = input.int(20, "Dealing range pivot length", minval = 5, maxval = 100, group = grpDR)
cPrem = input.color(color.new(#e74c3c, 94), "Premium", group = grpDR)
cDisc = input.color(color.new(#2ecc71, 94), "Discount", group = grpDR)

// ── Inputs: PD arrays ─────────────────────────────────────────────────────────
grpPD = "PD arrays"
showFVG = input.bool(true, "FVG (BISI / SIBI)", group = grpPD)
showCE = input.bool(true, "Consequent encroachment (50%) lines", group = grpPD)
fvgMinATR = input.float(0.25, "Min FVG height (× ATR14)", minval = 0.0, step = 0.05, group = grpPD)
fvgMax = input.int(15, "Max FVGs per side", minval = 3, maxval = 60, group = grpPD)
ifvgOn = input.bool(true, "Invert violated FVGs into IFVGs", group = grpPD)
showVI = input.bool(false, "Volume imbalances", group = grpPD)
groupVI = input.bool(true, "Group consecutive volume imbalances", group = grpPD)
showBPR = input.bool(true, "Balanced price ranges (BPR)", group = grpPD)
showOG = input.bool(true, "Opening gaps (NWOG / NDOG)", group = grpPD)
showQuarters = input.bool(true, "Quarters of a gap (0.25 / 0.75) on NWOG / NDOG", group = grpPD)
ogKeep = input.int(3, "Opening gaps kept (each type)", minval = 1, maxval = 10, group = grpPD)
showOB = input.bool(false, "Order block at MSS (body, mean threshold)", group = grpPD)
fltN = input.int(4, "Show nearest N FVGs/VIs per side (0 = all)", minval = 0, maxval = 30, group = grpPD)
cBISI = input.color(color.new(#2ecc71, 85), "BISI (bullish FVG)", group = grpPD)
cSIBI = input.color(color.new(#e74c3c, 85), "SIBI (bearish FVG)", group = grpPD)
cIFbull = input.color(color.new(#3498db, 82), "Bullish IFVG", group = grpPD)
cIFbear = input.color(color.new(#e67e22, 82), "Bearish IFVG", group = grpPD)
cVI = input.color(color.new(#95a5a6, 80), "Volume imbalance", group = grpPD)
cBPR = input.color(color.new(#9b59b6, 80), "BPR", group = grpPD)
cNWOG = input.color(color.new(#f1c40f, 85), "NWOG", group = grpPD)
cNDOG = input.color(color.new(#1abc9c, 88), "NDOG", group = grpPD)
cOBbull = input.color(color.new(#26a69a, 80), "Bullish OB", group = grpPD)
cOBbear = input.color(color.new(#ef5350, 80), "Bearish OB", group = grpPD)
showFP = input.bool(true, "First Presented FVG (FPFVG)", group = grpPD)
fpSess = input.session("0930-1000", "FPFVG search window (ET)", tooltip = "The first FVG whose first candle opens inside this window is marked FPFVG. Kept for 2 days.", group = grpPD)
cFP = input.color(color.new(#ff9800, 75), "FPFVG", group = grpPD)

// ── Inputs: SMT ───────────────────────────────────────────────────────────────
grpX = "SMT divergence"
showSMT = input.bool(true, "SMT vs symbol 1", group = grpX)
smtSym1 = input.symbol("CME_MINI:ES1!", "Symbol 1", group = grpX)
smtTag1 = input.string("ES", "Symbol 1 tag", group = grpX)
showSMT2 = input.bool(false, "SMT vs symbol 2 (triad)", group = grpX)
smtSym2 = input.symbol("CBOT_MINI:YM1!", "Symbol 2", group = grpX)
smtTag2 = input.string("YM", "Symbol 2 tag", group = grpX)
smtLen = input.int(5, "SMT pivot length", minval = 2, maxval = 50, group = grpX)
smtTol = input.int(20, "Pivot alignment tolerance (bars)", minval = 1, group = grpX)
cSMT = input.color(color.new(#f1c40f, 0), "SMT color", group = grpX)

// ── Inputs: standard deviation projections ───────────────────────────────────
grpSD = "Standard deviation projections"
showCBDR = input.bool(false, "CBDR projections", group = grpSD)
cbdrSess = input.session("1400-2000", "CBDR session (ET)", group = grpSD)
cCBDR = input.color(color.new(#7f8c8d, 0), "CBDR color", group = grpSD)
showASD = input.bool(false, "Asian range projections", group = grpSD)
sdN = input.int(3, "Number of deviations", minval = 1, maxval = 5, group = grpSD)

// ── Inputs: alerts ────────────────────────────────────────────────────────────
grpAl = "alert() messages — use condition 'Any alert() function call'"
alMSS = input.bool(true, "MSS", group = grpAl)
alRaid = input.bool(true, "BSL / SSL raid", group = grpAl)
alOTE = input.bool(true, "Price enters OTE", group = grpAl)
alCE = input.bool(false, "FVG consequent encroachment touched", group = grpAl)
alSMT = input.bool(true, "SMT divergence", group = grpAl)

// ── Common ────────────────────────────────────────────────────────────────────
intra = timeframe.isintraday
atr14 = ta.atr(14)

f_in(string s) =>
    not na(time(timeframe.period, s, TZ))

// ── Time: killzones, Silver Bullet, macros ────────────────────────────────────
inAsia = f_in(kzAsia)
inLon = f_in(kzLon)
inNYA = f_in(kzNYA)
inLC = f_in(kzLC)
inNYP = f_in(kzNYP)

kzOK = kzShow and intra
bgcolor(kzOK and kzAsiaOn and inAsia ? color.new(cAsia, 93) : na, title = "Asia KZ")
bgcolor(kzOK and kzLonOn and inLon ? color.new(cLon, 93) : na, title = "London KZ")
bgcolor(kzOK and kzNYAOn and inNYA ? color.new(cNYA, 93) : na, title = "NY AM KZ")
bgcolor(kzOK and kzLCOn and inLC ? color.new(cLC, 93) : na, title = "London Close KZ")
bgcolor(kzOK and kzNYPOn and inNYP ? color.new(cNYP, 93) : na, title = "NY PM KZ")

sb1 = f_in("0300-0400")
sb2 = f_in("1000-1100")
sb3 = f_in("1400-1500")
inSB = sb1 or sb2 or sb3
bgcolor(sbShow and intra and inSB ? color.new(cSB, 92) : na, title = "Silver Bullet")

r1 = f_in(mcS1)
r2 = f_in(mcS2)
r3 = f_in(mcS3)
r4 = f_in(mcS4)
r5 = f_in(mcS5)
r6 = f_in(mcS6)
r7 = f_in(mcS7)
r8 = f_in(mcS8)
m1 = mcOn1 and r1
m2 = mcOn2 and r2
m3 = mcOn3 and r3
m4 = mcOn4 and r4
m5 = mcOn5 and r5
m6 = mcOn6 and r6
m7 = mcOn7 and r7
m8 = mcOn8 and r8
inMacroV = (m1 and mcV1) or (m2 and mcV2) or (m3 and mcV3) or (m4 and mcV4) or (m5 and mcV5) or (m6 and mcV6) or (m7 and mcV7) or (m8 and mcV8)
inMacroU = not inMacroV and ((m1 and not mcV1) or (m2 and not mcV2) or (m3 and not mcV3) or (m4 and not mcV4) or (m5 and not mcV5) or (m6 and not mcV6) or (m7 and not mcV7) or (m8 and not mcV8))
mcOK = macroShow and intra
plotchar(mcOK and inMacroV, title = "Macro line (verified)", char = "━", location = location.bottom, color = cMacro, size = size.small)
plotchar(mcOK and inMacroU, title = "Macro line (unverified)", char = "━", location = location.bottom, color = color.new(cMacro, 65), size = size.small)
plotshape(mcOK and inMacroV and not inMacroV[1], title = "Macro tag (verified)", style = shape.labelup, location = location.bottom, color = color.new(cMacro, 15), text = "Macro", textcolor = color.white, size = size.tiny)
plotshape(mcOK and inMacroU and not inMacroU[1], title = "Macro tag (unverified)", style = shape.labelup, location = location.bottom, color = color.new(cMacro, 70), text = "Macro?", textcolor = color.white, size = size.tiny)

// Asia / London ranges (for liquidity and projections)
var float aHi = na
var float aLo = na
if inAsia and not inAsia[1]
    aHi := high
    aLo := low
else if inAsia
    aHi := math.max(nz(aHi, high), high)
    aLo := math.min(nz(aLo, low), low)
asiaEnd = (not inAsia) and inAsia[1]

var float lHi = na
var float lLo = na
if inLon and not inLon[1]
    lHi := high
    lLo := low
else if inLon
    lHi := math.max(nz(lHi, high), high)
    lLo := math.min(nz(lLo, low), low)
lonEnd = (not inLon) and inLon[1]

// ── Opening prices ────────────────────────────────────────────────────────────
newNYDay = nz(ta.change(dayofmonth(time, TZ))) != 0
var float midOpen = na
var int midT = na
if newNYDay
    midOpen := open
    midT := time

in830 = f_in("0830-0930")
var float o830 = na
var int t830 = na
if in830 and not in830[1]
    o830 := open
    t830 := time

in930 = f_in("0930-1600")
var float o930 = na
var int t930 = na
if in930 and not in930[1]
    o930 := open
    t930 := time

// Daily / weekly references (confirmed prior values — non-repainting idiom)
pdhV = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pdlV = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_on)
pwhV = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pwlV = request.security(syminfo.tickerid, "W", low[1], barmerge.gaps_off, barmerge.lookahead_on)
chgD = nz(ta.change(time("D")))
chgW = nz(ta.change(time("W")))
newDayBar = intra and chgD != 0
newWeekBar = intra and chgW != 0

// ── PD array engine ───────────────────────────────────────────────────────────
//  kind: 1 FVG, 2 VI, 3 BPR, 4 NWOG, 5 NDOG, 6 OB
type Zone
    box bx
    line ce
    float top
    float bot
    int bornT
    int kind
    bool bull
    int state
    bool ceHit
    int invT
    color bg
    color bd
    color tx
    color ceCol
    line q1
    line q3

f_mkZone(int leftT, float top, float bot, int kind, bool bull, color c, string txt, bool withCE, int bw) =>
    color bd = color.new(c, 45)
    color tx = color.new(c, 0)
    color cc = color.new(c, 25)
    box b = box.new(leftT, top, time, bot, xloc = xloc.bar_time, bgcolor = c, border_color = bd, border_width = bw, text = txt, text_color = tx, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
    float mid = (top + bot) / 2.0
    line l = withCE ? line.new(leftT, mid, time, mid, xloc = xloc.bar_time, color = cc, style = line.style_dotted, width = 1) : na
    Zone.new(b, l, top, bot, time, kind, bull, 0, false, na, c, bd, tx, cc, na, na)

f_qLine(float top, float bot, float frac, int leftT, color c) =>
    float y = bot + frac * (top - bot)
    line.new(leftT, y, time, y, xloc = xloc.bar_time, color = color.new(c, 40), style = line.style_dotted, width = 1)

f_trimZones(array<Zone> arr, int maxN) =>
    while array.size(arr) > maxN
        Zone o = array.shift(arr)
        box.delete(o.bx)
        if not na(o.ce)
            line.delete(o.ce)
        if not na(o.q1)
            line.delete(o.q1)
        if not na(o.q3)
            line.delete(o.q3)

f_maintainZones(array<Zone> arr) =>
    int i = array.size(arr) - 1
    while i >= 0
        Zone z = array.get(arr, i)
        bool kill = false
        box.set_right(z.bx, time)
        if not na(z.ce)
            line.set_x2(z.ce, time)
        if not na(z.q1)
            line.set_x2(z.q1, time)
        if not na(z.q3)
            line.set_x2(z.q3, time)
        if time > z.bornT and z.kind != 4 and z.kind != 5 and z.kind != 7
            float mid = (z.top + z.bot) / 2.0
            if z.state == 0
                if not z.ceHit
                    bool hit = z.bull ? low <= mid : high >= mid
                    if hit
                        z.ceHit := true
                        if alCE and z.kind == 1
                            alert(syminfo.ticker + ": " + (z.bull ? "BISI" : "SIBI") + " CE touched @ " + str.tostring(mid, format.mintick), alert.freq_once_per_bar)
                bool viol = z.bull ? close < z.bot : close > z.top
                if viol
                    if ifvgOn and z.kind == 1
                        z.state := 1
                        z.invT := time
                        color ci = z.bull ? cIFbear : cIFbull
                        z.bg := ci
                        z.bd := color.new(ci, 35)
                        z.tx := color.new(ci, 0)
                        z.ceCol := color.new(ci, 25)
                        box.set_bgcolor(z.bx, z.bg)
                        box.set_border_color(z.bx, z.bd)
                        box.set_text_color(z.bx, z.tx)
                        box.set_text(z.bx, "IFVG")
                        if not na(z.ce)
                            line.set_color(z.ce, z.ceCol)
                    else
                        kill := true
            else if time > z.invT
                bool viol2 = z.bull ? close > z.top : close < z.bot
                if viol2
                    kill := true
        if kill
            box.delete(z.bx)
            if not na(z.ce)
                line.delete(z.ce)
            if not na(z.q1)
                line.delete(z.q1)
            if not na(z.q3)
                line.delete(z.q3)
            array.remove(arr, i)
        i -= 1

var array<Zone> fvgBull = array.new<Zone>()
var array<Zone> fvgBear = array.new<Zone>()
var array<Zone> viArr = array.new<Zone>()
var array<Zone> bprArr = array.new<Zone>()
var array<Zone> fpArr = array.new<Zone>()
var array<Zone> nwogArr = array.new<Zone>()
var array<Zone> ndogArr = array.new<Zone>()
var array<Zone> obArr = array.new<Zone>()
var array<Zone> emptyZ = array.new<Zone>()

// Maintain existing arrays first (new zones are never checked on their birth bar)
f_maintainZones(fvgBull)
f_maintainZones(fvgBear)
f_maintainZones(viArr)
f_maintainZones(bprArr)
f_maintainZones(nwogArr)
f_maintainZones(ndogArr)
f_maintainZones(obArr)
f_maintainZones(fpArr)

// Raw FVG detection (always computed — also used by the displacement test)
rawBullFvg = high[2] < low and (low - high[2]) >= fvgMinATR * atr14
rawBearFvg = low[2] > high and (low[2] - high) >= fvgMinATR * atr14
var int lastBullFvgBar = na
var int lastBearFvgBar = na
if rawBullFvg
    lastBullFvgBar := bar_index
if rawBearFvg
    lastBearFvgBar := bar_index

if showFVG and rawBullFvg
    Zone zb = f_mkZone(time[2], low, high[2], 1, true, cBISI, "BISI", showCE, 1)
    if showBPR
        for s in fvgBear
            if s.state == 0
                float t = math.min(s.top, zb.top)
                float b = math.max(s.bot, zb.bot)
                if t > b
                    array.push(bprArr, f_mkZone(time[2], t, b, 3, true, cBPR, "BPR", showCE, 1))
    array.push(fvgBull, zb)
    f_trimZones(fvgBull, fvgMax)
    f_trimZones(bprArr, 10)

if showFVG and rawBearFvg
    Zone zs = f_mkZone(time[2], low[2], high, 1, false, cSIBI, "SIBI", showCE, 1)
    if showBPR
        for s in fvgBull
            if s.state == 0
                float t = math.min(s.top, zs.top)
                float b = math.max(s.bot, zs.bot)
                if t > b
                    array.push(bprArr, f_mkZone(time[2], t, b, 3, false, cBPR, "BPR", showCE, 1))
    array.push(fvgBear, zs)
    f_trimZones(fvgBear, fvgMax)
    f_trimZones(bprArr, 10)

// Volume imbalance: gap between consecutive candle bodies while wicks overlap
bTop1 = math.max(open[1], close[1])
bBot1 = math.min(open[1], close[1])
bTop0 = math.max(open, close)
bBot0 = math.min(open, close)
rawBullVI = close > open and close[1] > open[1] and bBot0 > bTop1 and low <= high[1]
rawBearVI = close < open and close[1] < open[1] and bTop0 < bBot1 and high >= low[1]
var Zone lastVI = na
var int lastVIBar = na
var bool lastVIBull = false
if showVI and (rawBullVI or rawBearVI)
    float vTop = rawBullVI ? bBot0 : bBot1
    float vBot = rawBullVI ? bTop1 : bTop0
    bool mergeVI = groupVI and not na(lastVI) and not na(lastVIBar) and lastVIBar == bar_index - 1 and lastVIBull == rawBullVI
    if mergeVI
        lastVI.top := math.max(lastVI.top, vTop)
        lastVI.bot := math.min(lastVI.bot, vBot)
        box.set_top(lastVI.bx, lastVI.top)
        box.set_bottom(lastVI.bx, lastVI.bot)
        box.set_text(lastVI.bx, "VIs")
    else
        lastVI := f_mkZone(time[1], vTop, vBot, 2, rawBullVI, cVI, "VI", false, 1)
        array.push(viArr, lastVI)
        f_trimZones(viArr, 20)
    lastVIBar := bar_index
    lastVIBull := rawBullVI

// Opening gaps: NWOG (Friday close → Sunday open), NDOG (17:00 close → 18:00 open)
if showOG and newWeekBar and not na(close[1]) and open != close[1]
    float gT = math.max(open, close[1])
    float gB = math.min(open, close[1])
    Zone zw = f_mkZone(time[1], gT, gB, 4, open > close[1], cNWOG, "NWOG", true, 1)
    if showQuarters
        zw.q1 := f_qLine(gT, gB, 0.25, time[1], cNWOG)
        zw.q3 := f_qLine(gT, gB, 0.75, time[1], cNWOG)
    array.push(nwogArr, zw)
    f_trimZones(nwogArr, ogKeep)
if showOG and newDayBar and not newWeekBar and not na(close[1]) and open != close[1]
    float dT = math.max(open, close[1])
    float dB = math.min(open, close[1])
    Zone zd = f_mkZone(time[1], dT, dB, 5, open > close[1], cNDOG, "NDOG", true, 1)
    if showQuarters
        zd.q1 := f_qLine(dT, dB, 0.25, time[1], cNDOG)
        zd.q3 := f_qLine(dT, dB, 0.75, time[1], cNDOG)
    array.push(ndogArr, zd)
    f_trimZones(ndogArr, ogKeep)

// First Presented FVG: first FVG whose first candle opens inside the search window
inFP = f_in(fpSess)
var bool fpFound = false
if inFP and not inFP[1]
    fpFound := false
if showFP and intra and inFP and inFP[2] and not fpFound
    bool fpBull = high[2] < low
    bool fpBear = low[2] > high
    if fpBull or fpBear
        fpFound := true
        Zone zf = na
        if fpBull
            zf := f_mkZone(time[2], low, high[2], 7, true, cFP, "FPFVG", true, 2)
        else
            zf := f_mkZone(time[2], low[2], high, 7, false, cFP, "FPFVG", true, 2)
        array.push(fpArr, zf)
        f_trimZones(fpArr, 2)

// ── Market Structure Shift (displacement required) ───────────────────────────
ph = ta.pivothigh(high, msLen, msLen)
pl = ta.pivotlow(low, msLen, msLen)

var float sHi = na
var int sHiT = na
var int sHiBar = na
var bool sHiBroken = true
var float sLo = na
var int sLoT = na
var int sLoBar = na
var bool sLoBroken = true
var int trend = 0

if not na(ph)
    sHi := ph
    sHiT := time[msLen]
    sHiBar := bar_index - msLen
    sHiBroken := false
if not na(pl)
    sLo := pl
    sLoT := time[msLen]
    sLoBar := bar_index - msLen
    sLoBroken := false

bodySz = math.abs(close - open)
var int lastBigBullBar = na
var int lastBigBearBar = na
if close > open and bodySz >= dispATR * atr14
    lastBigBullBar := bar_index
if close < open and bodySz >= dispATR * atr14
    lastBigBearBar := bar_index

dispUp = not na(lastBigBullBar) and bar_index - lastBigBullBar < dispBars and (not dispNeedFvg or (not na(lastBullFvgBar) and bar_index - lastBullFvgBar < dispBars))
dispDn = not na(lastBigBearBar) and bar_index - lastBigBearBar < dispBars and (not dispNeedFvg or (not na(lastBearFvgBar) and bar_index - lastBearFvgBar < dispBars))

bool evMSSBull = false
bool evMSSBear = false
float legLow = na
float legHigh = na

if not sHiBroken and not na(sHi) and close > sHi
    sHiBroken := true
    if trend == -1
        if dispUp
            evMSSBull := true
            trend := 1
            if showMSS
                line.new(sHiT, sHi, time, sHi, xloc = xloc.bar_time, color = cMSSBull, style = line.style_solid, width = 2)
                label.new(time, sHi, "MSS", xloc = xloc.bar_time, style = label.style_label_up, textcolor = color.white, color = color.new(cMSSBull, 20), size = size.tiny)
            int n = math.min(bar_index - sHiBar, 400)
            float lg = low
            for k = 0 to n
                lg := math.min(lg, low[k])
            legLow := lg
            if showOB
                int dOff = na(lastBigBullBar) ? 0 : bar_index - lastBigBullBar
                int found = -1
                for k = dOff + 1 to dOff + 10
                    if close[k] < open[k]
                        found := k
                        break
                if found >= 0
                    array.push(obArr, f_mkZone(time[found], open[found], close[found], 6, true, cOBbull, "OB", true, 1))
                    f_trimZones(obArr, 6)
    else
        if trend == 1 and showBMS
            line.new(sHiT, sHi, time, sHi, xloc = xloc.bar_time, color = color.new(cMSSBull, 40), style = line.style_dotted, width = 1)
            label.new(time, sHi, "BMS", xloc = xloc.bar_time, style = label.style_label_up, textcolor = color.white, color = color.new(cMSSBull, 60), size = size.tiny)
        trend := 1

if not sLoBroken and not na(sLo) and close < sLo
    sLoBroken := true
    if trend == 1
        if dispDn
            evMSSBear := true
            trend := -1
            if showMSS
                line.new(sLoT, sLo, time, sLo, xloc = xloc.bar_time, color = cMSSBear, style = line.style_solid, width = 2)
                label.new(time, sLo, "MSS", xloc = xloc.bar_time, style = label.style_label_down, textcolor = color.white, color = color.new(cMSSBear, 20), size = size.tiny)
            int n2 = math.min(bar_index - sLoBar, 400)
            float hg = high
            for k = 0 to n2
                hg := math.max(hg, high[k])
            legHigh := hg
            if showOB
                int dOff2 = na(lastBigBearBar) ? 0 : bar_index - lastBigBearBar
                int found2 = -1
                for k = dOff2 + 1 to dOff2 + 10
                    if close[k] > open[k]
                        found2 := k
                        break
                if found2 >= 0
                    array.push(obArr, f_mkZone(time[found2], close[found2], open[found2], 6, false, cOBbear, "OB", true, 1))
                    f_trimZones(obArr, 6)
    else
        if trend == -1 and showBMS
            line.new(sLoT, sLo, time, sLo, xloc = xloc.bar_time, color = color.new(cMSSBear, 40), style = line.style_dotted, width = 1)
            label.new(time, sLo, "BMS", xloc = xloc.bar_time, style = label.style_label_down, textcolor = color.white, color = color.new(cMSSBear, 60), size = size.tiny)
        trend := -1

if alMSS and evMSSBull
    alert(syminfo.ticker + ": bullish MSS with displacement @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if alMSS and evMSSBear
    alert(syminfo.ticker + ": bearish MSS with displacement @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

// ── OTE on the displacement leg ──────────────────────────────────────────────
var int oteDir = 0
var float oteA = na
var float oteB = na
var bool oteFrozen = false
var int oteBar = na
var bool oteHit = false
var box oteBx = na
var line oteLn = na
bool evOTE = false

if evMSSBull or evMSSBear
    if not na(oteBx)
        box.delete(oteBx)
    if not na(oteLn)
        line.delete(oteLn)
    oteBx := na
    oteLn := na
    oteDir := 0
    if showOTE
        oteDir := evMSSBull ? 1 : -1
        oteA := evMSSBull ? legLow : legHigh
        oteB := evMSSBull ? high : low
        oteFrozen := false
        oteBar := bar_index
        oteHit := false
        oteBx := box.new(time, oteB, time, oteB, xloc = xloc.bar_time, bgcolor = cOTE, border_color = color.new(cOTE, 40), text = "OTE", text_color = color.new(cOTE, 0), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
        oteLn := line.new(time, oteB, time, oteB, xloc = xloc.bar_time, color = color.new(cOTE, 10), style = line.style_dashed, width = 1)
else if oteDir != 0 and not oteFrozen
    oteB := oteDir == 1 ? math.max(oteB, high) : math.min(oteB, low)

if oteDir != 0 and not na(oteBx)
    float r = math.abs(oteB - oteA)
    float z62 = oteDir == 1 ? oteB - 0.62 * r : oteB + 0.62 * r
    float z79 = oteDir == 1 ? oteB - 0.79 * r : oteB + 0.79 * r
    float z705 = oteDir == 1 ? oteB - 0.705 * r : oteB + 0.705 * r
    box.set_top(oteBx, math.max(z62, z79))
    box.set_bottom(oteBx, math.min(z62, z79))
    box.set_right(oteBx, time)
    line.set_y1(oteLn, z705)
    line.set_y2(oteLn, z705)
    line.set_x2(oteLn, time)
    if bar_index > oteBar
        bool inZone = oteDir == 1 ? low <= z62 : high >= z62
        if inZone
            oteFrozen := true
            if not oteHit
                oteHit := true
                evOTE := true
    bool invalid = (oteDir == 1 ? close < oteA : close > oteA) or bar_index - oteBar > oteMaxBars
    if invalid
        box.delete(oteBx)
        line.delete(oteLn)
        oteBx := na
        oteLn := na
        oteDir := 0

if alOTE and evOTE
    alert(syminfo.ticker + ": price entered " + (oteDir == 1 ? "bullish" : "bearish") + " OTE @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

// ── Liquidity: BSL / SSL, raids vs runs ──────────────────────────────────────
type Pool
    float price
    int t
    bool isHigh
    string name
    bool key
    line ln
    label lb
    int brk
    float ext
    int bornT
    color col

var array<Pool> swH = array.new<Pool>()
var array<Pool> swL = array.new<Pool>()
var array<Pool> keyH = array.new<Pool>()
var array<Pool> keyL = array.new<Pool>()
var array<label> raidLbs = array.new<label>()
var array<line> raidLns = array.new<line>()

f_killPool(Pool p) =>
    if not na(p.lb)
        label.delete(p.lb)
    if not na(p.ln)
        line.delete(p.ln)

f_scanPools(array<Pool> arr, bool isHigh, float pen, int win) =>
    bool ev = false
    string names = ""
    int i = array.size(arr) - 1
    while i >= 0
        Pool p = array.get(arr, i)
        bool dead = false
        if time > p.bornT
            if isHigh
                if na(p.brk)
                    if high > p.price + pen
                        p.brk := bar_index
                        p.ext := high
                else
                    p.ext := math.max(p.ext, high)
            else
                if na(p.brk)
                    if low < p.price - pen
                        p.brk := bar_index
                        p.ext := low
                else
                    p.ext := math.min(p.ext, low)
            if not na(p.brk)
                bool reclaimed = isHigh ? close < p.price : close > p.price
                string side = isHigh ? "BSL" : "SSL"
                if reclaimed
                    dead := true
                    ev := true
                    string nm = p.name == "" ? side : side + " · " + p.name
                    names := names == "" ? nm : names + ", " + nm
                    color rc = isHigh ? cRaidBSL : cRaidSSL
                    if not na(p.lb)
                        label.delete(p.lb)
                    line sl = na
                    if not na(p.ln)
                        sl := p.ln
                        line.set_x2(sl, time)
                        line.set_color(sl, rc)
                        line.set_style(sl, line.style_solid)
                    else
                        sl := line.new(p.t, p.price, time, p.price, xloc = xloc.bar_time, color = rc, style = line.style_solid, width = 1)
                    array.push(raidLns, sl)
                    string txt = p.name == "" ? side + " raid" : side + " raid · " + p.name
                    array.push(raidLbs, label.new(time, p.ext, txt, xloc = xloc.bar_time, style = isHigh ? label.style_label_down : label.style_label_up, textcolor = color.white, color = color.new(rc, 20), size = size.tiny))
                else if bar_index - p.brk >= win - 1
                    dead := true
                    if showRuns and not na(p.ln)
                        line.set_x2(p.ln, time)
                        line.set_color(p.ln, color.new(color.gray, 75))
                        line.set_style(p.ln, line.style_dashed)
                        if not na(p.lb)
                            label.set_text(p.lb, (p.name == "" ? side : p.name) + " run")
                            label.set_textcolor(p.lb, color.new(color.gray, 50))
                    else
                        f_killPool(p)
        if dead
            array.remove(arr, i)
        else
            if not na(p.ln)
                line.set_x2(p.ln, time)
            if p.key and not na(p.lb)
                label.set_x(p.lb, time)
        i -= 1
    while array.size(raidLbs) > raidKeep
        label.delete(array.shift(raidLbs))
    while array.size(raidLns) > raidKeep
        line.delete(array.shift(raidLns))
    [ev, names]

f_addSwing(array<Pool> arr, float price, int t, bool isHigh, float tol) =>
    bool merged = false
    if tol > 0
        for p in arr
            if na(p.brk) and math.abs(p.price - price) <= tol
                p.name := isHigh ? "REH" : "REL"
                p.price := isHigh ? math.max(p.price, price) : math.min(p.price, price)
                if not na(p.ln)
                    line.set_y1(p.ln, p.price)
                    line.set_y2(p.ln, p.price)
                    line.set_width(p.ln, 2)
                    line.set_style(p.ln, line.style_solid)
                if na(p.lb)
                    p.lb := label.new(p.t, p.price, p.name, xloc = xloc.bar_time, style = isHigh ? label.style_label_down : label.style_label_up, textcolor = color.new(p.col, 0), color = CLEAR, size = size.tiny)
                else
                    label.set_y(p.lb, p.price)
                merged := true
                break
    if not merged
        color pc = color.new(isHigh ? cBSL : cSSL, 60)
        line ln = showSwingPools ? line.new(t, price, time, price, xloc = xloc.bar_time, color = pc, style = line.style_dotted, width = 1) : na
        array.push(arr, Pool.new(price, t, isHigh, "", false, ln, na, na, na, time, pc))
        while array.size(arr) > swingMax
            Pool o = array.shift(arr)
            f_killPool(o)

f_addKey(array<Pool> arr, float price, bool isHigh, string nm, bool show) =>
    int i = array.size(arr) - 1
    while i >= 0
        Pool p = array.get(arr, i)
        if p.name == nm
            f_killPool(p)
            array.remove(arr, i)
        i -= 1
    if show and not na(price)
        color pc = isHigh ? cBSL : cSSL
        line ln = line.new(time, price, time, price, xloc = xloc.bar_time, color = pc, style = line.style_dashed, width = 1)
        label lb = label.new(time, price, nm + (isHigh ? " · BSL" : " · SSL"), xloc = xloc.bar_time, style = label.style_label_left, textcolor = pc, color = CLEAR, size = size.tiny)
        array.push(arr, Pool.new(price, time, isHigh, nm, true, ln, lb, na, na, time, pc))

bool evBSL = false
bool evSSL = false
string bslNames = ""
string sslNames = ""

if showLiq
    float pen = raidPen * syminfo.mintick
    [a1, b1] = f_scanPools(swH, true, pen, raidWin)
    [a2, b2] = f_scanPools(keyH, true, pen, raidWin)
    [a3, b3] = f_scanPools(swL, false, pen, raidWin)
    [a4, b4] = f_scanPools(keyL, false, pen, raidWin)
    evBSL := a1 or a2
    evSSL := a3 or a4
    bslNames := b1 == "" ? b2 : b2 == "" ? b1 : b1 + ", " + b2
    sslNames := b3 == "" ? b4 : b4 == "" ? b3 : b3 + ", " + b4

lqPH = ta.pivothigh(high, lqLen, lqLen)
lqPL = ta.pivotlow(low, lqLen, lqLen)

if showLiq
    float tol = reTol * atr14
    if not na(lqPH)
        f_addSwing(swH, lqPH, time[lqLen], true, tol)
    if not na(lqPL)
        f_addSwing(swL, lqPL, time[lqLen], false, tol)
    if newDayBar
        f_addKey(keyH, pdhV, true, "PDH", showPD)
        f_addKey(keyL, pdlV, false, "PDL", showPD)
    if newWeekBar
        f_addKey(keyH, pwhV, true, "PWH", showPW)
        f_addKey(keyL, pwlV, false, "PWL", showPW)
    if asiaEnd and intra
        f_addKey(keyH, aHi, true, "Asia H", showAsiaHL)
        f_addKey(keyL, aLo, false, "Asia L", showAsiaHL)
    if lonEnd and intra
        f_addKey(keyH, lHi, true, "London H", showLonHL)
        f_addKey(keyL, lLo, false, "London L", showLonHL)

if alRaid and evBSL
    alert(syminfo.ticker + ": BSL raid — " + bslNames + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if alRaid and evSSL
    alert(syminfo.ticker + ": SSL raid — " + sslNames + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

// ── Dealing range: premium / discount / equilibrium ──────────────────────────
drPH = ta.pivothigh(high, drLen, drLen)
drPL = ta.pivotlow(low, drLen, drLen)
var float drHi = na
var int drHiT = na
var float drLo = na
var int drLoT = na
if not na(drPH)
    drHi := drPH
    drHiT := time[drLen]
if not na(drPL)
    drLo := drPL
    drLoT := time[drLen]
if not na(drHi) and high > drHi
    drHi := high
    drHiT := time
if not na(drLo) and low < drLo
    drLo := low
    drLoT := time

var box prBx = na
var box dsBx = na
var line eqLn = na
if barstate.islast
    if not na(prBx)
        box.delete(prBx)
    if not na(dsBx)
        box.delete(dsBx)
    if not na(eqLn)
        line.delete(eqLn)
    prBx := na
    dsBx := na
    eqLn := na
    if showDR and not na(drHi) and not na(drLo) and drHi > drLo
        float eq = (drHi + drLo) / 2.0
        int lt = math.min(drHiT, drLoT)
        prBx := box.new(lt, drHi, time, eq, xloc = xloc.bar_time, bgcolor = cPrem, border_color = CLEAR, text = "Premium", text_color = color.new(cPrem, 20), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)
        dsBx := box.new(lt, eq, time, drLo, xloc = xloc.bar_time, bgcolor = cDisc, border_color = CLEAR, text = "Discount", text_color = color.new(cDisc, 20), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom)
        eqLn := line.new(lt, eq, time, eq, xloc = xloc.bar_time, color = color.new(color.gray, 30), style = line.style_dashed, width = 1)

// ── SMT divergence ────────────────────────────────────────────────────────────
f_smt(float cH, float cL, bool enabled, string tag) =>
    float myPH = ta.pivothigh(high, smtLen, smtLen)
    float myPL = ta.pivotlow(low, smtLen, smtLen)
    float cpPH = ta.pivothigh(cH, smtLen, smtLen)
    float cpPL = ta.pivotlow(cL, smtLen, smtLen)
    var float mh1 = na
    var float mh0 = na
    var int mh1t = na
    var int mh0t = na
    var float ml1 = na
    var float ml0 = na
    var int ml1t = na
    var int ml0t = na
    var float ch1 = na
    var float ch0 = na
    var int ch1t = na
    var int ch0t = na
    var float cl1 = na
    var float cl0 = na
    var int cl1t = na
    var int cl0t = na
    var int lastHi = na
    var int lastLo = na
    bool nh = false
    bool nl = false
    if not na(myPH)
        mh0 := mh1
        mh0t := mh1t
        mh1 := myPH
        mh1t := time[smtLen]
        nh := true
    if not na(cpPH)
        ch0 := ch1
        ch0t := ch1t
        ch1 := cpPH
        ch1t := time[smtLen]
        nh := true
    if not na(myPL)
        ml0 := ml1
        ml0t := ml1t
        ml1 := myPL
        ml1t := time[smtLen]
        nl := true
    if not na(cpPL)
        cl0 := cl1
        cl0t := cl1t
        cl1 := cpPL
        cl1t := time[smtLen]
        nl := true
    int tolMs = smtTol * timeframe.in_seconds(timeframe.period) * 1000
    bool evBear = false
    bool evBull = false
    if enabled and nh and not na(mh0) and not na(ch0)
        bool al = math.abs(mh1t - ch1t) <= tolMs and math.abs(mh0t - ch0t) <= tolMs
        bool dv = (mh1 > mh0 and ch1 < ch0) or (mh1 < mh0 and ch1 > ch0)
        int sig = mh1t + ch1t
        if al and dv and sig != lastHi
            lastHi := sig
            evBear := true
            line.new(mh0t, mh0, mh1t, mh1, xloc = xloc.bar_time, color = cSMT, style = line.style_dashed, width = 2)
            label.new(mh1t, mh1, "SMT " + tag + " ▼", xloc = xloc.bar_time, style = label.style_label_down, textcolor = color.black, color = color.new(cSMT, 15), size = size.tiny)
    if enabled and nl and not na(ml0) and not na(cl0)
        bool al2 = math.abs(ml1t - cl1t) <= tolMs and math.abs(ml0t - cl0t) <= tolMs
        bool dv2 = (ml1 < ml0 and cl1 > cl0) or (ml1 > ml0 and cl1 < cl0)
        int sig2 = ml1t + cl1t
        if al2 and dv2 and sig2 != lastLo
            lastLo := sig2
            evBull := true
            line.new(ml0t, ml0, ml1t, ml1, xloc = xloc.bar_time, color = cSMT, style = line.style_dashed, width = 2)
            label.new(ml1t, ml1, "SMT " + tag + " ▲", xloc = xloc.bar_time, style = label.style_label_up, textcolor = color.black, color = color.new(cSMT, 15), size = size.tiny)
    [evBear, evBull]

[c1H, c1L] = request.security(smtSym1, timeframe.period, [high, low], barmerge.gaps_off, barmerge.lookahead_off)
[c2H, c2L] = request.security(smtSym2, timeframe.period, [high, low], barmerge.gaps_off, barmerge.lookahead_off)
[smt1Bear, smt1Bull] = f_smt(c1H, c1L, showSMT, smtTag1)
[smt2Bear, smt2Bull] = f_smt(c2H, c2L, showSMT2, smtTag2)
smtBear = smt1Bear or smt2Bear
smtBull = smt1Bull or smt2Bull

if alSMT and smtBear
    alert(syminfo.ticker + ": bearish SMT divergence", alert.freq_once_per_bar)
if alSMT and smtBull
    alert(syminfo.ticker + ": bullish SMT divergence", alert.freq_once_per_bar)

// ── Standard deviation projections (CBDR, Asian range) ───────────────────────
f_sdProj(bool enabled, bool inS, string nm, color c, int n) =>
    var float hi = na
    var float lo = na
    var array<line> lns = array.new<line>()
    var array<label> lbs = array.new<label>()
    bool began = inS and not inS[1]
    bool ended = (not inS) and inS[1]
    if began
        hi := high
        lo := low
    else if inS
        hi := math.max(nz(hi, high), high)
        lo := math.min(nz(lo, low), low)
    if enabled and ended and not na(hi) and hi > lo
        while array.size(lns) > 0
            line.delete(array.pop(lns))
        while array.size(lbs) > 0
            label.delete(array.pop(lbs))
        float rg = hi - lo
        for k = 1 to n
            float up = hi + k * rg
            float dn = lo - k * rg
            array.push(lns, line.new(time, up, time + 60000, up, xloc = xloc.bar_time, extend = extend.right, color = color.new(c, 40), style = line.style_dotted, width = 1))
            array.push(lns, line.new(time, dn, time + 60000, dn, xloc = xloc.bar_time, extend = extend.right, color = color.new(c, 40), style = line.style_dotted, width = 1))
            array.push(lbs, label.new(time, up, nm + " +" + str.tostring(k) + " SD", xloc = xloc.bar_time, style = label.style_label_right, textcolor = color.new(c, 20), color = CLEAR, size = size.tiny))
            array.push(lbs, label.new(time, dn, nm + " −" + str.tostring(k) + " SD", xloc = xloc.bar_time, style = label.style_label_right, textcolor = color.new(c, 20), color = CLEAR, size = size.tiny))

inCBDR = f_in(cbdrSess)
f_sdProj(showCBDR and intra, inCBDR, "CBDR", cCBDR, sdN)
f_sdProj(showASD and intra, inAsia, "Asia", cAsia, sdN)

// ── Opening price lines ───────────────────────────────────────────────────────
var array<line> opLns = array.new<line>()
var array<label> opLbs = array.new<label>()

f_op(bool show, float y, int t0, string nm, color c) =>
    if show and not na(y) and not na(t0)
        int lblT = time + 5 * timeframe.in_seconds(timeframe.period) * 1000
        array.push(opLns, line.new(t0, y, time, y, xloc = xloc.bar_time, extend = extend.right, color = c, style = line.style_dotted, width = 1))
        array.push(opLbs, label.new(lblT, y, nm + "  " + str.tostring(y, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, textcolor = c, color = CLEAR, size = size.small))

if barstate.islast
    while array.size(opLns) > 0
        line.delete(array.pop(opLns))
    while array.size(opLbs) > 0
        label.delete(array.pop(opLbs))
    if intra
        f_op(showMidOpen, midOpen, midT, "00:00 Open", cMidO)
        f_op(show830, o830, t830, "08:30 Open", c830)
        f_op(show930, o930, t930, "09:30 Open", c930)

// ── Display filter (nearest N) — display only, lifecycle untouched ───────────
f_viewSetZ(array<Zone> a, float px, int n, float thrUp, float thrDn) =>
    for z in a
        bool above = z.bot > px
        bool below = z.top < px
        float d = above ? z.bot - px : below ? px - z.top : 0.0
        bool vis = n == 0 ? true : (not above and not below) or (above and d <= nz(thrUp, -1.0)) or (below and d <= nz(thrDn, -1.0))
        box.set_bgcolor(z.bx, vis ? z.bg : CLEAR)
        box.set_border_color(z.bx, vis ? z.bd : CLEAR)
        box.set_text_color(z.bx, vis ? z.tx : CLEAR)
        if not na(z.ce)
            line.set_color(z.ce, vis ? z.ceCol : CLEAR)

f_viewZ(array<Zone> a1, array<Zone> a2, float px, int n) =>
    array<float> up = array.new<float>()
    array<float> dn = array.new<float>()
    for z in a1
        if z.bot > px
            array.push(up, z.bot - px)
        else if z.top < px
            array.push(dn, px - z.top)
    for w in a2
        if w.bot > px
            array.push(up, w.bot - px)
        else if w.top < px
            array.push(dn, px - w.top)
    array.sort(up, order.ascending)
    array.sort(dn, order.ascending)
    float thrUp = n == 0 or array.size(up) == 0 ? na : array.get(up, math.min(n, array.size(up)) - 1)
    float thrDn = n == 0 or array.size(dn) == 0 ? na : array.get(dn, math.min(n, array.size(dn)) - 1)
    f_viewSetZ(a1, px, n, thrUp, thrDn)
    f_viewSetZ(a2, px, n, thrUp, thrDn)

f_viewPools(array<Pool> a, float px, int n) =>
    array<float> ds = array.new<float>()
    for p in a
        array.push(ds, math.abs(p.price - px))
    array.sort(ds, order.ascending)
    float thr = n == 0 or array.size(ds) == 0 ? na : array.get(ds, math.min(n, array.size(ds)) - 1)
    for q in a
        bool vis = n == 0 ? true : math.abs(q.price - px) <= nz(thr, -1.0)
        if not na(q.ln)
            line.set_color(q.ln, vis ? q.col : CLEAR)
        if not na(q.lb)
            label.set_textcolor(q.lb, vis ? color.new(q.col, 0) : CLEAR)

if barstate.islast
    f_viewZ(fvgBull, fvgBear, close, fltN)
    f_viewZ(viArr, emptyZ, close, fltN)
    f_viewPools(swH, close, fltN)
    f_viewPools(swL, close, fltN)

// ── alertcondition() presets ─────────────────────────────────────────────────
alertcondition(evMSSBull, "MSS — Bullish", "Bullish market structure shift with displacement")
alertcondition(evMSSBear, "MSS — Bearish", "Bearish market structure shift with displacement")
alertcondition(evBSL, "BSL raid", "Buy-side liquidity raided and reclaimed")
alertcondition(evSSL, "SSL raid", "Sell-side liquidity raided and reclaimed")
alertcondition(evOTE, "Price enters OTE", "Price entered the OTE zone of the latest displacement leg")
alertcondition(smtBear, "SMT — Bearish", "Bearish SMT divergence")
alertcondition(smtBull, "SMT — Bullish", "Bullish SMT divergence")
````
