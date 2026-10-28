# Intraday Bias Engine

- url: https://www.tradingview.com/script/XcSs7PtH-Intraday-Bias-Engine/
- type: indicator
- pine_id: PUB;a7cf345a7df7425bb50a95d66075e1bb
- version: 1.0

## Description

Intraday Bias Engine

OVERVIEW
A probability-based intraday decision dashboard. After the opening auction it
estimates the highest-probability scenario for the session (bullish, bearish or
sideways), the likely day-type, an expected range and a confidence grade - by
combining several classic intraday models into one read. It is a context and
decision-support tool, not a buy/sell signal generator.

WHAT IT COMBINES
- Opening Range: high/low/mid, width vs the day's ATR, classified Narrow / Normal
  / Wide / Extreme.
- Gap: size and direction vs the previous close, with a transparent gap-fill
  estimate (smaller gaps tend to fill more often).
- CPR: pivot, TC, BC, width classification and directional bias.
- VWAP: position, distance and who is in control.
- Market structure: higher-high / higher-low vs lower-high / lower-low.
- Smart-money pressure: a 0-100 score from a volume-delta approximation, relative
  volume, range expansion, momentum and VWAP distance.
- Directional probability: a weighted blend of the above, normalised so Bull,
  Bear and Sideways always total 100%.
- Day-type, expected range, confidence grade and a basic risk read.

DASHBOARD
A movable panel shows session classification, confidence and grade, Bull/Bear/
Sideways probability meters, the individual engine reads, opening-range and gap
context, the expected range, a no-trade (compression) status and a simple
directional hit-rate over the recent sessions.

ON-CHART
Opening Range, CPR (P/TC/BC), VWAP and expected-range bands are drawn for the
current day only. Compression conditions are highlighted as a faint no-trade zone.

HOW TO USE
1. Use an intraday timeframe on a symbol with reliable volume.
2. The read finalises after the opening-range window closes.
3. Favour setups that agree with the dominant probability and a higher confidence
   grade; stand aside when the no-trade zone is active.
4. Treat the levels and probabilities as context for your own plan and risk
   management.

NOTES
- Daily anchors use confirmed prior sessions; current-day levels draw forward
  only and do not repaint historical bars. The live read updates as the day
  develops, which is expected for an intraday model.
- The gap-fill figure and the directional hit-rate are simple estimates, not
  performance guarantees.
- This script is for research and education only and is not financial advice.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//   INTRADAY BIAS ENGINE
//   ──────────────────────────────────────────────────────────────────────────
//   A probability-based intraday decision engine. After the opening auction it
//   estimates the highest-probability scenario for the day and a confidence
//   grade, by combining: Opening Range, Gap, CPR, VWAP, market structure,
//   smart-money pressure, volatility/ATR expansion and trend alignment.
//   ──────────────────────────────────────────────────────────────────────────
//   No lookahead, no future leaks. Daily anchors use confirmed prior sessions.
//   Forecast levels are drawn for the current day only. Research/education only,
//   not investment advice.
// ════════════════════════════════════════════════════════════════════════════
indicator("Intraday Bias Engine", overlay = true, max_lines_count = 60, max_labels_count = 60, max_boxes_count = 20)

// ─────────────────────────────── INPUTS ────────────────────────────────────
gS = "Session"
tz      = input.string("Asia/Kolkata", "Timezone", group = gS)
orSess  = input.session("0915-0930", "Opening Range Session", group = gS)

gC = "Classification Thresholds"
orNarrow = input.float(0.15, "OR Narrow (× day ATR)", step = 0.05, group = gC)
orWide   = input.float(0.35, "OR Wide (× day ATR)",   step = 0.05, group = gC)
orExtreme= input.float(0.55, "OR Extreme (× day ATR)",step = 0.05, group = gC)
gapBig   = input.float(0.40, "Significant Gap %",     step = 0.05, group = gC)

gV = "Visuals"
showOR   = input.bool(true, "Opening Range", group = gV)
showCPR  = input.bool(true, "CPR (P / TC / BC)", group = gV)
showVWAP = input.bool(true, "VWAP", group = gV)
showER   = input.bool(true, "Expected Range Bands", group = gV)
showNT   = input.bool(true, "Highlight No-Trade (compression)", group = gV)
rightX   = input.int(10, "Level Extend Right", minval = 0, group = gV)

gD = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group = gD)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gD)
accTrack = input.int(50, "Accuracy Window (days)", minval = 10, maxval = 200, group = gD)

gK = "Colors"
bullC = input.color(#26a69a, "Bull", group = gK)
bearC = input.color(#ef5350, "Bear", group = gK)
neuC  = input.color(#78909c, "Neutral", group = gK)
accC  = input.color(#7e57c2, "Accent", group = gK)

// ─────────────────────────── DAILY ANCHORS ─────────────────────────────────
[pdh, pdl, pdc, pdo] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1], open[1]], barmerge.gaps_off, barmerge.lookahead_on)
dAtr  = request.security(syminfo.tickerid, "D", ta.atr(14)[1], barmerge.gaps_off, barmerge.lookahead_on)
dopen = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_on)

tchD  = ta.change(time("D"))
isNew = na(tchD) or tchD != 0

var int dayStartBar = na
if isNew
    dayStartBar := bar_index

// ─────────────────────────── OPENING RANGE ─────────────────────────────────
inOR = not na(time(timeframe.period, orSess, tz))
var float orH = na, var float orL = na
var bool orLocked = false
var int  orPredDir = 0
if isNew
    orH := na
    orL := na
    orLocked := false
if inOR
    orH := na(orH) ? high : math.max(orH, high)
    orL := na(orL) ? low  : math.min(orL, low)

orMid    = na(orH) ? na : (orH + orL) / 2
orWidth  = na(orH) ? na : orH - orL
orPct    = na(orWidth) or dopen == 0 ? na : orWidth / dopen * 100
orVsAtr  = na(orWidth) or na(dAtr) or dAtr == 0 ? na : orWidth / dAtr
orClass  = na(orVsAtr) ? "—" : orVsAtr < orNarrow ? "Narrow" : orVsAtr < orWide ? "Normal" : orVsAtr < orExtreme ? "Wide" : "Extreme"

// ─────────────────────────── GAP ENGINE ────────────────────────────────────
gap     = dopen - pdc
gapPct  = pdc != 0 ? gap / pdc * 100 : 0.0
gapUp   = gap > 0
insideGap = dopen <= pdh and dopen >= pdl
gapClass  = math.abs(gapPct) < gapBig * 0.5 ? "Neutral" : gapUp ? "Bullish Gap" : "Bearish Gap"
// transparent heuristic: smaller gaps fill more often
gapFillProb = math.round(math.max(20, 90 - math.abs(gapPct) * 35))

// ─────────────────────────── CPR ENGINE ────────────────────────────────────
P  = (pdh + pdl + pdc) / 3
BC = (pdh + pdl) / 2
TC = 2 * P - BC
cprHi = math.max(TC, BC)
cprLo = math.min(TC, BC)
cprW  = math.abs(TC - BC)
cprPct = dopen != 0 ? cprW / dopen * 100 : 0.0
cprClass = cprPct < 0.10 ? "Narrow (trend)" : cprPct > 0.30 ? "Wide (range)" : "Normal"
cprBias  = close > cprHi ? 1 : close < cprLo ? -1 : 0

// ─────────────────────────── VWAP ENGINE ───────────────────────────────────
var float sPV = 0.0, var float sV = 0.0
if isNew
    sPV := 0.0
    sV  := 0.0
sPV += hlc3 * volume
sV  += volume
vwap = sV > 0 ? sPV / sV : na
vwapDist = not na(vwap) and vwap != 0 ? (close - vwap) / vwap * 100 : 0.0
aboveVWAP = not na(vwap) and close > vwap

// crossovers computed every bar (avoids conditional-execution warnings)
xUpOR = ta.crossover(close, orH)
xDnOR = ta.crossunder(close, orL)
xUpVW = ta.crossover(close, vwap)
xDnVW = ta.crossunder(close, vwap)

// ─────────────────────────── STRUCTURE ENGINE ──────────────────────────────
ph = ta.pivothigh(5, 5)
pl = ta.pivotlow(5, 5)
var float lastPH = na, var float prevPH = na
var float lastPL = na, var float prevPL = na
if not na(ph)
    prevPH := lastPH
    lastPH := ph
if not na(pl)
    prevPL := lastPL
    lastPL := pl
hh = not na(lastPH) and not na(prevPH) and lastPH > prevPH
hl = not na(lastPL) and not na(prevPL) and lastPL > prevPL
lh = not na(lastPH) and not na(prevPH) and lastPH < prevPH
ll = not na(lastPL) and not na(prevPL) and lastPL < prevPL
structBias = (hh and hl) ? 1 : (lh and ll) ? -1 : 0

// ─────────────────────────── PRESSURE ENGINE (0-100) ───────────────────────
rngB  = high - low
deltaB = rngB > 0 ? volume * (2 * close - high - low) / rngB : 0.0
var float cvd = 0.0
cvd := isNew ? deltaB : cvd + deltaB
avgVol = ta.sma(volume, 20)
relVol = avgVol > 0 ? volume / avgVol : 1.0
atrV   = ta.atr(14)
atrAvg = ta.sma(atrV, 50)
mom    = ta.roc(close, 10)
pScore = 50.0
pScore += aboveVWAP ? 10 : -10
pScore += cvd > 0 ? 10 : -10
pScore += mom > 0 ? math.min(math.abs(mom) / 0.5, 1) * 10 : -math.min(math.abs(mom) / 0.5, 1) * 10
pScore += relVol > 1.2 ? (close > open ? 10 : -10) : 0
pScore += close > dopen ? 10 : -10
pressure = math.max(math.min(pScore, 100), 0)
pressTxt = pressure >= 70 ? "Strong Buy" : pressure >= 58 ? "Moderate Buy" : pressure > 42 ? "Neutral" : pressure > 30 ? "Moderate Sell" : "Strong Sell"

// ─────────────────────────── DIRECTIONAL PROBABILITY ───────────────────────
f_clamp01(v) => math.max(math.min(v, 1.0), 0.0)
bullPts = 0.0, bearPts = 0.0, sidePts = 0.0
// gap
if gapPct > 0
    bullPts += f_clamp01(gapPct / gapBig)
else
    bearPts += f_clamp01(-gapPct / gapBig)
// vwap
if vwapDist > 0
    bullPts += f_clamp01(vwapDist / 0.3)
else
    bearPts += f_clamp01(-vwapDist / 0.3)
// opening range breakout
if not na(orH)
    if close > orH
        bullPts += 1.0
    else if close < orL
        bearPts += 1.0
// cpr
bullPts += cprBias > 0 ? 1.0 : 0.0
bearPts += cprBias < 0 ? 1.0 : 0.0
// structure
bullPts += structBias > 0 ? 1.0 : 0.0
bearPts += structBias < 0 ? 1.0 : 0.0
// momentum
if mom > 0
    bullPts += f_clamp01(mom / 0.5)
else
    bearPts += f_clamp01(-mom / 0.5)
// pressure
if pressure > 50
    bullPts += (pressure - 50) / 50
else
    bearPts += (50 - pressure) / 50
// trend alignment
trendAl = dAtr != 0 ? (close - dopen) / (dAtr * 0.5) : 0.0
if trendAl > 0
    bullPts += f_clamp01(trendAl)
else
    bearPts += f_clamp01(-trendAl)
// sideways evidence (compression)
sidePts += not na(orVsAtr) and orVsAtr < orNarrow ? 1.2 : 0.0
sidePts += relVol < 0.8 ? 0.8 : 0.0
sidePts += math.abs(vwapDist) < 0.1 ? 0.8 : 0.0
sidePts += atrV < atrAvg * 0.85 ? 0.8 : 0.0

totPts = bullPts + bearPts + sidePts
bullPct = totPts > 0 ? bullPts / totPts * 100 : 33.3
bearPct = totPts > 0 ? bearPts / totPts * 100 : 33.3
sidePct = totPts > 0 ? sidePts / totPts * 100 : 33.4

// ─────────────────────────── DAY-TYPE + SESSION ────────────────────────────
volExp = atrAvg != 0 ? atrV / atrAvg : 1.0
dirConv = math.max(bullPct, bearPct)
isExpansion = (orClass == "Wide" or orClass == "Extreme") and relVol > 1.2
isTrend = dirConv > 55 and math.abs(vwapDist) > 0.2 and not (orClass == "Narrow")
isRange = sidePct > 40 or orClass == "Narrow"
dayType = isExpansion ? "Expansion Day" : isTrend ? (bullPct > bearPct ? "Trend Up Day" : "Trend Down Day") : isRange ? "Range Day" : "Neutral Day"

todayRange = high - low
insideDay  = high <= pdh and low >= pdl
outsideDay = high > pdh and low < pdl
sessClass = insideDay ? "Inside Day" : outsideDay ? "Outside Day" : dayType

// ─────────────────────────── CONFIDENCE + RISK ─────────────────────────────
dominance = math.max(math.max(bullPct, bearPct), sidePct)
clarity = not na(orVsAtr) ? f_clamp01(math.abs(orVsAtr - orNarrow) / orWide) : 0.5
conf = math.round(math.max(math.min(dominance * 0.7 + clarity * 30, 100), 0))
confGrade = conf >= 86 ? "ELITE" : conf >= 71 ? "Strong" : conf >= 51 ? "Moderate" : conf >= 31 ? "Neutral" : "Weak"

falseBrkRisk = (orClass == "Narrow" and relVol < 1.0) or sidePct > 45
riskLvl = falseBrkRisk ? "High" : volExp > 1.5 ? "Elevated (vol)" : conf >= 71 ? "Low" : "Moderate"

// ─────────────────────────── EXPECTED RANGE ────────────────────────────────
erC = na(dAtr) ? na : dAtr * 0.6
erN = na(dAtr) ? na : dAtr * 1.0
erE = na(dAtr) ? na : dAtr * 1.4
expHi = dopen + erN
expLo = dopen - erN
expHiE = dopen + erE
expLoE = dopen - erE

// ─────────────────────────── ACCURACY TRACKER ──────────────────────────────
// Capture prediction at OR close (uses only info up to 09:30 → no leak).
if inOR[1] and not inOR and not orLocked
    orLocked := true
    orPredDir := bullPct > bearPct ? 1 : bearPct > bullPct ? -1 : 0
var int[] hits = array.new_int()
var int yPred = 0
if isNew
    if yPred != 0
        actual = pdc > pdo ? 1 : pdc < pdo ? -1 : 0
        array.push(hits, yPred == actual and actual != 0 ? 1 : 0)
        if array.size(hits) > accTrack
            array.shift(hits)
    yPred := 0
if orLocked and yPred == 0
    yPred := orPredDir
accPct = array.size(hits) > 0 ? array.avg(hits) * 100 : na

// ─────────────────────────── NO-TRADE HIGHLIGHT ────────────────────────────
noTrade = sidePct > 45 and orLocked
bgcolor(showNT and noTrade ? color.new(neuC, 92) : na)

// ─────────────────────────── VWAP PLOT (continuous) ────────────────────────
plot(showVWAP ? vwap : na, "VWAP", color = color.new(#ffb300, 0), linewidth = 2)

// ─────────────────────────── TODAY-ONLY LEVELS ─────────────────────────────
f_fmt(p) => str.tostring(p, format.mintick)
var line[]  L = array.new<line>()
var label[] LB = array.new<label>()

f_lvl(float price, color c, string style, string txt) =>
    if not na(price) and not na(dayStartBar)
        array.push(L, line.new(dayStartBar, price, bar_index + rightX, price, color = c, style = style, width = 1))
        array.push(LB, label.new(bar_index + rightX + 1, price, txt, style = label.style_label_left, color = color.new(c, 10), textcolor = color.white, size = size.tiny))

if barstate.islast
    for ln in L
        line.delete(ln)
    array.clear(L)
    for lb in LB
        label.delete(lb)
    array.clear(LB)
    if showOR
        f_lvl(orH,   accC, line.style_solid, "OR High " + f_fmt(orH))
        f_lvl(orL,   accC, line.style_solid, "OR Low " + f_fmt(orL))
        f_lvl(orMid, color.new(accC, 40), line.style_dotted, "OR Mid")
    if showCPR
        f_lvl(P,  color.new(#90a4ae, 0), line.style_solid,  "Pivot " + f_fmt(P))
        f_lvl(TC, color.new(#90a4ae, 30), line.style_dashed, "TC")
        f_lvl(BC, color.new(#90a4ae, 30), line.style_dashed, "BC")
    if showER
        f_lvl(expHi, color.new(bullC, 20), line.style_dashed, "Exp High " + f_fmt(expHi))
        f_lvl(expLo, color.new(bearC, 20), line.style_dashed, "Exp Low " + f_fmt(expLo))

// ─────────────────────────── DASHBOARD ─────────────────────────────────────
f_pos() =>
    switch dashPos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_meter(float v) =>
    n = math.round(math.max(math.min(v, 100), 0) / 10)
    s = ""
    for i = 1 to 10
        s += i <= n ? "█" : "░"
    s

var table d = table.new(f_pos(), 2, 22, border_width = 1, border_color = color.new(color.gray, 75), frame_width = 1, frame_color = color.new(color.gray, 60))

f_hdr(int r, string t) =>
    table.cell(d, 0, r, t, text_color = color.white, bgcolor = color.new(accC, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(d, 1, r, "", bgcolor = color.new(accC, 0))
f_row(int r, string k, string v, color vc) =>
    table.cell(d, 0, r, k, text_color = color.new(color.white, 15), bgcolor = color.new(#15151f, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(d, 1, r, v, text_color = color.white, bgcolor = vc, text_size = size.small, text_halign = text.align_right)

if showDash and barstate.islast
    dk = color.new(#10101a, 0)
    leadC = bullPct > bearPct and bullPct > sidePct ? bullC : bearPct > bullPct and bearPct > sidePct ? bearC : neuC
    cgC = conf >= 71 ? bullC : conf >= 51 ? #ffb300 : conf >= 31 ? neuC : bearC

    f_hdr(0, "  INTRADAY BIAS ENGINE")
    f_row(1, "Session", orLocked ? sessClass : "Forming…", color.new(leadC, 15))
    f_row(2, "Confidence", str.tostring(conf) + " · " + confGrade, color.new(cgC, 0))
    f_row(3, "Risk", riskLvl, color.new(riskLvl == "Low" ? bullC : riskLvl == "High" ? bearC : neuC, 20))

    f_hdr(4, "  PROBABILITY")
    f_row(5, "Bull " + str.tostring(math.round(bullPct)) + "%", f_meter(bullPct), color.new(bullC, 20))
    f_row(6, "Bear " + str.tostring(math.round(bearPct)) + "%", f_meter(bearPct), color.new(bearC, 20))
    f_row(7, "Sideways " + str.tostring(math.round(sidePct)) + "%", f_meter(sidePct), color.new(neuC, 20))
    f_row(8, "Day Type", dayType, color.new(leadC, 20))

    f_hdr(9, "  ENGINES")
    f_row(10, "VWAP", aboveVWAP ? "Buyers (" + str.tostring(vwapDist, "0.00") + "%)" : "Sellers (" + str.tostring(vwapDist, "0.00") + "%)", color.new(aboveVWAP ? bullC : bearC, 20))
    f_row(11, "Pressure", pressTxt, color.new(pressure >= 58 ? bullC : pressure <= 42 ? bearC : neuC, 20))
    f_row(12, "Structure", structBias > 0 ? "Bullish" : structBias < 0 ? "Bearish" : "Neutral", color.new(structBias > 0 ? bullC : structBias < 0 ? bearC : neuC, 20))
    f_row(13, "CPR", cprClass + (cprBias > 0 ? " ▲" : cprBias < 0 ? " ▼" : ""), color.new(cprBias > 0 ? bullC : cprBias < 0 ? bearC : neuC, 20))

    f_hdr(14, "  OPENING & GAP")
    f_row(15, "Open Range", orClass + (na(orPct) ? "" : " (" + str.tostring(orPct, "0.00") + "%)"), dk)
    f_row(16, "Gap", gapClass + " (" + str.tostring(gapPct, "0.00") + "%)", color.new(gapUp ? bullC : bearC, 25))
    f_row(17, "Gap Fill (est)", str.tostring(gapFillProb) + "%", dk)

    f_hdr(18, "  TARGETS")
    f_row(19, "Expected Range", na(expLo) ? "—" : f_fmt(expLo) + " – " + f_fmt(expHi), dk)
    f_row(20, "No-Trade Zone", noTrade ? "ACTIVE — avoid" : "Clear", color.new(noTrade ? bearC : bullC, 25))
    f_row(21, "Dir. Hit " + str.tostring(array.size(hits)) + "d", na(accPct) ? "building…" : str.tostring(math.round(accPct)) + "%", dk)

// ─────────────────────────── ALERTS ────────────────────────────────────────
alertcondition(orLocked and bullPct > 55 and conf >= 71, "Bull Bias Confirmed", "Bull bias confirmed {{ticker}}")
alertcondition(orLocked and bearPct > 55 and conf >= 71, "Bear Bias Confirmed", "Bear bias confirmed {{ticker}}")
alertcondition(not na(orH) and xUpOR, "OR Breakout Up", "OR breakout up {{ticker}}")
alertcondition(not na(orL) and xDnOR, "OR Breakdown", "OR breakdown {{ticker}}")
alertcondition(not na(vwap) and xUpVW, "VWAP Reclaim", "VWAP reclaimed {{ticker}}")
alertcondition(not na(vwap) and xDnVW, "VWAP Rejection", "VWAP lost {{ticker}}")
alertcondition(noTrade, "No-Trade Zone", "Compression — no-trade zone {{ticker}}")
````
