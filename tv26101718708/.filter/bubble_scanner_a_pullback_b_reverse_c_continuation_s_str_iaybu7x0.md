# Bubble Scanner - A - Pullback B- Reverse C- Continuation S - Str

- url: https://www.tradingview.com/script/IAybU7x0-Bubble-Scanner-A-Pullback-B-Reverse-C-Continuation-S-Str/
- type: indicator
- pine_id: PUB;90f789c032734785b04280265b02a3d1
- version: 1.0

## Description

ARRUDA BUBBLES

An all-in-one intraday overlay for reading order flow, trend and market structure on one chart. Built and used on XAUUSD (5m / 10m), but it works on any symbol with volume data.

━━━━━━━━━━━━━━━━━━━━
WHAT IT SHOWS
━━━━━━━━━━━━━━━━━━━━

1) VOLUME BUBBLES
Green (buy) and red (sell) bubbles placed at the price where the volume traded. Buy / sell split comes from 1-minute intrabar data. For XAUUSD the default source is COMEX gold futures (GC1!), because spot gold only has broker tick volume. Only unusual volume is shown (relative to the median), and only the strongest bubble per window, to keep the chart clean. Hover a bubble for the exact buy / sell numbers.

2) EQUAL HIGHS / EQUAL LOWS (EQH / EQL)
Liquidity zones where price made equal tops or bottoms. Zones are marked when swept.

3) EMA 5 / 13 / 89 + CLOUD
Cloud between EMA 5 and 13 (green / red). EMA 89 as the main trend filter.

4) CANDLE COLOURS
- Blue / red body = trend up / down
- Lime / orange = the candle where the cloud flips
- Green / red outline = counter-trend candle (buy candle in a downtrend / sell candle in an uptrend)

5) MARKET STRUCTURE
HH / HL / LH / LL swings, BOS (break of structure) and CHoCH (change of character), with the broken level kept as support / resistance.

6) MULTI-TIMEFRAME TREND TABLE
5m, 15m, 1H, 4H, Daily and Weekly trend, plus a Bias score (-6 to +6).

7) HULL MOVING AVERAGE
Fast, low-lag momentum line.

8) DELTA / CVD PANEL
Buy minus sell volume per candle and cumulative volume delta, with price / CVD divergences.

9) RANGE FILTER
Shades sideways markets (narrow range or repeated cloud flips) and marks the breakout with a diamond.

━━━━━━━━━━━━━━━━━━━━
SIGNAL LABELS (SCORE)
━━━━━━━━━━━━━━━━━━━━

Each label shows a score. Hover it to see which conditions passed (✓) or failed (✗), plus a suggested entry, stop and target (next liquidity zone, or a fixed R multiple).

A x/8 — Pullback with the trend after a cloud flip. Points: Bias, EMA 89 side, structure, pullback into a zone (EQH/EQL, BOS level or EMA 89), bubble, pullback candle, delta / CVD, Hull.
B x/5 — Reversal after a liquidity sweep (EQH / EQL).
C x/5 — Continuation: pullback inside an existing trend, without a cloud flip.
S x/5 — Structure break (CHoCH / BOS) after a Higher Low / Lower High that touched a zone.
R — Breakout of a sideways range with volume confirmation.

Signals are confirmed on candle close (no repaint). Entry reference = close of the signal candle.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━

Separate alerts for every signal, cloud flips, BOS / CHoCH, CVD divergences and big bubbles. "Any alert() function call" sends one combined message with entry, stop, target and R, filtered by minimum score (set in "Score trigger").

━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━

- Futures data (GC1!) is delayed ~10 minutes without a CME data subscription; the latest bubbles may appear late.
- Intrabar 1-minute history is limited by your TradingView plan, so bubbles and delta only exist on recent bars.
- After changing any setting, delete and recreate your alerts (alerts store the settings at the moment they are created).
- The scores are a checklist, not a guarantee. Use them as confluence together with your own analysis and risk management.

This script is for educational purposes only and is not financial advice.

## Source Code

````pine
//@version=6
// Arruda Bubbles
// • EQH / EQL liquidity zones (same detection as Arruda Clean).
// • Volume bubbles: on candles with high volume, a bubble is drawn at the price where most of
//   that candle's volume traded. Green = buyers dominated, red = sellers dominated. Bubble size =
//   how big the volume is versus the average; colour strength = how one-sided it was.
//   Hover a bubble to see buy volume, sell volume, delta and the % of each side.
// • Panel below the chart: volume delta per candle and CVD (cumulative delta of the day).
// Everything except the delta / CVD panel is drawn on the price chart (force_overlay).
// Buy / sell split: each candle is broken into lower-timeframe intrabars (1m by default); the
// volume of rising intrabars counts as buying, falling as selling, flat ones are split 50/50.
indicator("Arruda Bubbles", overlay = false, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

bullCol = input.color(#089981, "Buy colour", group = "Colours", inline = "c")
bearCol = input.color(#F23645, "Sell colour", group = "Colours", inline = "c")

// ═════════════════════════════ EMAs ═════════════════════════════
grpE  = "EMAs"
e1On  = input.bool(true, "EMA 1", group = grpE, inline = "e1")
e1Len = input.int(5, "", minval = 1, group = grpE, inline = "e1")
e1Col = input.color(#FFD600, "", group = grpE, inline = "e1")
e2On  = input.bool(true, "EMA 2", group = grpE, inline = "e2")
e2Len = input.int(13, "", minval = 1, group = grpE, inline = "e2")
e2Col = input.color(#00BCD4, "", group = grpE, inline = "e2")
e3On  = input.bool(true, "EMA 3", group = grpE, inline = "e3")
e3Len = input.int(89, "", minval = 1, group = grpE, inline = "e3")
e3Col = input.color(#E040FB, "", group = grpE, inline = "e3")
cloudOn = input.bool(true, "Cloud between EMA 1 and EMA 2", group = grpE)
cUpCol  = input.color(#089981, "Cloud up / down", group = grpE, inline = "cl")
cDnCol  = input.color(#F23645, "", group = grpE, inline = "cl")
cTr     = input.int(80, "Cloud transparency", minval = 0, maxval = 100, group = grpE)
eF = ta.ema(close, e1Len)
eS = ta.ema(close, e2Len)
pE1 = plot(e1On ? eF : na, "EMA 5",  e1Col, 1, force_overlay = true)
pE2 = plot(e2On ? eS : na, "EMA 13", e2Col, 1, force_overlay = true)
// Green when the fast EMA is above the slow one, red when below
fill(pE1, pE2, cloudOn and e1On and e2On ? color.new(eF >= eS ? cUpCol : cDnCol, cTr) : na, "EMA cloud")

// Cloud colour change = EMA 1 crosses EMA 2. Marked on the candle where it happens.
paintFlip = input.bool(true, "Paint the candle where the cloud changes colour", group = grpE)
fUpCol    = input.color(#AEEA00, "Turns green / turns red", group = grpE, inline = "fc")
fDnCol    = input.color(#FF9800, "", group = grpE, inline = "fc")
showFlip  = input.bool(false, "Also mark with a triangle", group = grpE)
cloudUp  = ta.crossover(eF, eS)
cloudDn  = ta.crossunder(eF, eS)
// Trend candles: white in an uptrend, black in a downtrend (the cloud-change candle keeps its own colour)
paintTr = input.bool(true, "Paint candles by trend", group = grpE)
trSrc   = input.string("EMA cloud", "Trend for the candles", options = ["EMA cloud", "Price vs EMA 3"], group = grpE, tooltip = "EMA cloud: EMA 1 above EMA 2 = uptrend.\nPrice vs EMA 3: close above the EMA 3 (89) = uptrend.")
trUpCol = input.color(#2962FF, "Uptrend / downtrend candle", group = grpE, inline = "tc")
trDnCol = input.color(#F23645, "", group = grpE, inline = "tc")
trendUp = trSrc == "EMA cloud" ? eF >= eS : close >= ta.ema(close, e3Len)
// Counter-trend candles get a coloured outline: a buying (green) candle in a downtrend → green
// outline; a selling (red) candle in an uptrend → red outline.
ctOn    = input.bool(true, "Outline counter-trend candles", group = grpE)
ctBuy   = input.color(#00C853, "Buy candle in downtrend / sell candle in uptrend", group = grpE, inline = "ct")
ctSell  = input.color(#FF1744, "", group = grpE, inline = "ct")
nBorder = input.color(color.black, "Normal outline / wick", group = grpE)
bodyCol = paintFlip and cloudUp ? fUpCol : paintFlip and cloudDn ? fDnCol : trendUp ? trUpCol : trDnCol
ctB     = not trendUp and close > open
ctS     = trendUp and close < open
isFlip  = paintFlip and (cloudUp or cloudDn)
brdCol  = isFlip ? nBorder : ctOn and ctB ? ctBuy : ctOn and ctS ? ctSell : nBorder
// Trend candles are drawn over the chart's own candles (needed for a separate outline colour)
plotcandle(paintTr ? open : na, high, low, close, "Trend candles", color = bodyCol, wickcolor = brdCol, bordercolor = brdCol, force_overlay = true)
// Without trend candles, only the cloud-change candle is painted
barcolor(not paintTr and paintFlip and cloudUp ? fUpCol : not paintTr and paintFlip and cloudDn ? fDnCol : na, title = "Cloud change candle")
plotshape(showFlip and cloudUp, "Cloud turns green", shape.triangleup, location.belowbar, cUpCol, size = size.tiny, force_overlay = true)
plotshape(showFlip and cloudDn, "Cloud turns red", shape.triangledown, location.abovebar, cDnCol, size = size.tiny, force_overlay = true)
alertcondition(cloudUp, "Cloud turns green", "Arruda Bubbles: EMA cloud turned GREEN on {{ticker}} {{interval}} at {{close}}")
alertcondition(cloudDn, "Cloud turns red", "Arruda Bubbles: EMA cloud turned RED on {{ticker}} {{interval}} at {{close}}")
plot(e3On ? ta.ema(close, e3Len) : na, "EMA 89", e3Col, 2, force_overlay = true)

// Fast low-lag average (Hull MA or Zero-lag EMA), coloured by its slope
grpH   = "Fast low-lag average"
fastOn = input.bool(true, "Show fast average", group = grpH)
fType  = input.string("Hull", "Type", options = ["Hull", "Zero-lag EMA"], group = grpH, tooltip = "Hull and Zero-lag EMA react faster than a normal EMA of the same length, but can overshoot at turning points.")
fLen   = input.int(14, "Length", minval = 2, group = grpH)
fUp    = input.color(#00E676, "Rising / falling", group = grpH, inline = "fh")
fDn    = input.color(#FF5252, "", group = grpH, inline = "fh")
hullMA = ta.wma(2 * ta.wma(close, math.max(1, int(fLen / 2))) - ta.wma(close, fLen), math.max(1, int(math.round(math.sqrt(fLen)))))
zlLag  = int((fLen - 1) / 2)
zlema  = ta.ema(close + (close - close[zlLag]), fLen)
fastMA = fType == "Hull" ? hullMA : zlema
fastUp = fastMA >= fastMA[1]
plot(fastOn ? fastMA : na, "Fast average", fastUp ? fUp : fDn, 2, force_overlay = true)
alertcondition(fastUp and not fastUp[1], "Fast average turns up", "Arruda Bubbles: fast average turned UP on {{ticker}} {{interval}} at {{close}}")
alertcondition(not fastUp and fastUp[1], "Fast average turns down", "Arruda Bubbles: fast average turned DOWN on {{ticker}} {{interval}} at {{close}}")

// ═════════════════════════════ MARKET STRUCTURE ═════════════════════════════
// Swing highs / lows are labelled HH (higher high), LH (lower high), HL (higher low), LL (lower
// low). When a candle CLOSES beyond the last swing high / low, a dashed line marks the broken
// level: BOS = break in the direction of the trend (continuation); CHoCH = break against it
// (change of character: the first sign the trend may be turning).
grpS    = "Market structure"
showSw  = input.bool(true, "Label swing highs / lows (HH, HL, LH, LL)", group = grpS)
showBrk = input.bool(true, "Mark breaks (BOS / CHoCH)", group = grpS)
swLen   = input.int(5, "Swing strength (candles each side)", minval = 2, group = grpS, tooltip = "Higher = only the bigger swings. A swing is confirmed this many candles after it forms.")
brkSrc  = input.string("Close", "Break when", options = ["Close", "Wick"], group = grpS, tooltip = "Close: the candle must close beyond the level (fewer false breaks). Wick: touching beyond it is enough.")
msUp    = input.color(#089981, "Bullish / bearish", group = grpS, inline = "ms")
msDn    = input.color(#F23645, "", group = grpS, inline = "ms")

sPH = ta.pivothigh(high, swLen, swLen)
sPL = ta.pivotlow(low, swLen, swLen)
var float lastSH  = na
var int   lastSHb = na
var bool  shUsed  = true
var float lastSL  = na
var int   lastSLb = na
var bool  slUsed  = true
var int   msTrend = 0     // 1 = bullish structure, -1 = bearish
var float prvSH   = na
var float prvSL   = na
var float brkUpLvl = na   // last swing high broken upward (old resistance → support)
var float brkDnLvl = na   // last swing low broken downward (old support → resistance)
var bool  slHL = false    // last swing low was a higher low
var bool  shLH = false    // last swing high was a lower high

if not na(sPH)
    if showSw
        tag = na(prvSH) ? "H" : sPH > prvSH ? "HH" : "LH"
        label.new(bar_index - swLen, sPH, tag, yloc = yloc.abovebar, style = label.style_none, textcolor = tag == "HH" ? msUp : msDn, size = size.tiny, force_overlay = true)
    shLH    := not na(prvSH) and sPH < prvSH
    prvSH   := sPH
    lastSH  := sPH
    lastSHb := bar_index - swLen
    shUsed  := false
if not na(sPL)
    if showSw
        tag = na(prvSL) ? "L" : sPL > prvSL ? "HL" : "LL"
        label.new(bar_index - swLen, sPL, tag, yloc = yloc.belowbar, style = label.style_none, textcolor = tag == "HL" ? msUp : msDn, size = size.tiny, force_overlay = true)
    slHL    := not na(prvSL) and sPL > prvSL
    prvSL   := sPL
    lastSL  := sPL
    lastSLb := bar_index - swLen
    slUsed  := false

upBrkPx = brkSrc == "Close" ? close : high
dnBrkPx = brkSrc == "Close" ? close : low
bool bosUp = false
bool bosDn = false
bool chUp  = false
bool chDn  = false
if not shUsed and not na(lastSH) and upBrkPx > lastSH
    shUsed := true
    brkUpLvl := lastSH
    isCh = msTrend == -1
    chUp  := isCh
    bosUp := not isCh
    msTrend := 1
    if showBrk
        line.new(lastSHb, lastSH, bar_index, lastSH, color = msUp, style = line.style_dashed, width = 1, force_overlay = true)
        label.new(int(math.round((lastSHb + bar_index) / 2)), lastSH, isCh ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(msUp, 100), textcolor = msUp, size = size.tiny, force_overlay = true)
if not slUsed and not na(lastSL) and dnBrkPx < lastSL
    slUsed := true
    brkDnLvl := lastSL
    isCh = msTrend == 1
    chDn  := isCh
    bosDn := not isCh
    msTrend := -1
    if showBrk
        line.new(lastSLb, lastSL, bar_index, lastSL, color = msDn, style = line.style_dashed, width = 1, force_overlay = true)
        label.new(int(math.round((lastSLb + bar_index) / 2)), lastSL, isCh ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(msDn, 100), textcolor = msDn, size = size.tiny, force_overlay = true)
alertcondition(bosUp or bosDn, "BOS (break of structure)", "Arruda Bubbles: BOS on {{ticker}} {{interval}} at {{close}}")
alertcondition(chUp, "CHoCH bullish", "Arruda Bubbles: bullish CHoCH (last swing high broken in a downtrend) on {{ticker}} {{interval}} at {{close}}")
alertcondition(chDn, "CHoCH bearish", "Arruda Bubbles: bearish CHoCH (last swing low broken in an uptrend) on {{ticker}} {{interval}} at {{close}}")

// ═════════════════════════════ EQH / EQL ═════════════════════════════
// Two or more swing highs (lows) at about the same price. The zone extends right until price
// trades beyond it; then it is removed (swept).
grpW    = "EQH / EQL"
showLiq = input.bool(true, "EQH / EQL liquidity zones", group = grpW)
liqLen  = input.int(3, "Pivot length", minval = 1, group = grpW, tooltip = "3 also catches double tops / bottoms that are close together.")
eqAtr   = input.float(0.3, "Equal within (ATR)", minval = 0.05, step = 0.05, group = grpW)
liqMax  = input.int(8, "Max zones", minval = 1, maxval = 30, group = grpW)
liqLook = input.int(500, "Max bars between pivots", minval = 20, maxval = 4000, group = grpW)
eqHCol  = input.color(#F23645, "EQH colour", group = grpW, inline = "z")
eqLCol  = input.color(#2962FF, "EQL colour", group = grpW, inline = "z")
eqTol = eqAtr * ta.atr(14)
lPH = ta.pivothigh(high, liqLen, liqLen)
lPL = ta.pivotlow(low, liqLen, liqLen)

type Zone
    int   t
    float mx
    float mn
    box   bx
    label tg
var array<Zone>  zones = array.new<Zone>()
var int eqhSweepBar = na
var int eqlSweepBar = na
var array<float> sH  = array.new<float>()
var array<int>   sHb = array.new<int>()
var array<float> sL  = array.new<float>()
var array<int>   sLb = array.new<int>()

zoneNew(int t, int x0, float a, float b) =>
    c  = t == 1 ? eqHCol : eqLCol
    bx = box.new(x0, math.max(a, b), bar_index, math.min(a, b), border_color = color.new(c, 60), bgcolor = color.new(c, 85), force_overlay = true)
    tg = label.new(bar_index + 1, (a + b) / 2, t == 1 ? "EQH" : "EQL", style = label.style_label_left, color = color.new(c, 100), textcolor = color.new(c, 20), size = size.tiny, force_overlay = true)
    zones.push(Zone.new(t, math.max(a, b), math.min(a, b), bx, tg))
    if zones.size() > liqMax
        z0 = zones.shift()
        z0.bx.delete()
        z0.tg.delete()

if zones.size() > 0
    for i = zones.size() - 1 to 0
        z = zones.get(i)
        if z.t == 1 ? high > z.mx : low < z.mn
            if z.t == 1
                eqhSweepBar := bar_index
            else
                eqlSweepBar := bar_index
            z.bx.delete()
            z.tg.delete()
            zones.remove(i)
        else
            z.bx.set_right(bar_index)
            z.tg.set_x(bar_index + 1)
if sH.size() > 0
    for i = sH.size() - 1 to 0
        if high > sH.get(i) + eqTol or sHb.get(i) < bar_index - liqLook
            sH.remove(i)
            sHb.remove(i)
if sL.size() > 0
    for i = sL.size() - 1 to 0
        if low < sL.get(i) - eqTol or sLb.get(i) < bar_index - liqLook
            sL.remove(i)
            sLb.remove(i)
if showLiq and not na(lPH)
    merged = false
    for z in zones
        if z.t == 1 and lPH <= z.mx and lPH >= z.mn - eqTol
            z.mn := math.min(z.mn, lPH)
            z.bx.set_bottom(z.mn)
            merged := true
            break
    if not merged and sH.size() > 0
        for i = 0 to sH.size() - 1
            if math.abs(lPH - sH.get(i)) <= eqTol
                zoneNew(1, sHb.get(i), sH.get(i), lPH)
                break
    sH.push(lPH)
    sHb.push(bar_index - liqLen)
if showLiq and not na(lPL)
    merged = false
    for z in zones
        if z.t == -1 and lPL >= z.mn and lPL <= z.mx + eqTol
            z.mx := math.max(z.mx, lPL)
            z.bx.set_top(z.mx)
            merged := true
            break
    if not merged and sL.size() > 0
        for i = 0 to sL.size() - 1
            if math.abs(lPL - sL.get(i)) <= eqTol
                zoneNew(-1, sLb.get(i), sL.get(i), lPL)
                break
    sL.push(lPL)
    sLb.push(bar_index - liqLen)

// ═════════════════════════════ VOLUME BUBBLES ═════════════════════════════
grpB     = "Volume bubbles"
showBub  = input.bool(true, "Show volume bubbles", group = grpB)
useChart = input.bool(false, "Use the chart symbol's volume", group = grpB, tooltip = "Off: buy / sell volume comes from gold futures (real exchange volume). XAUUSD spot only has broker tick volume.")
volSym   = input.symbol("COMEX:GC1!", "Volume source", group = grpB)
ltf      = input.timeframe("1", "Intrabar timeframe", group = grpB, tooltip = "Must be lower than the chart timeframe. 1 minute works for 5m–1H charts.")
avgLen   = input.int(50, "Normal volume: length", minval = 5, group = grpB)
avgType  = input.string("Median", "Normal volume: type", options = ["Median", "Average"], group = grpB, tooltip = "Median: one news spike barely moves it, so bubbles keep showing on the candles after it. Average: a spike lifts it for the next N candles.")
minRel   = input.float(2.0, "Show bubble when volume ≥ × normal", minval = 0, step = 0.25, group = grpB, tooltip = "0 = a bubble on every candle.")
minDom   = input.int(60, "…and one side has at least (%)", minval = 50, maxval = 95, group = grpB, tooltip = "Candles where buyers and sellers were almost even get no bubble.")
bubPos   = input.string("Where the volume traded", "Bubble position", options = ["Where the volume traded", "Candle middle", "Close"], group = grpB, tooltip = "Where the volume traded = volume-weighted price of the candle's intrabars (the zone of the candle with most trading).")
showTxt  = input.bool(true, "Show the % next to the bubble", group = grpB)
maxSize  = input.string("Normal", "Biggest bubble size", options = ["Small", "Normal", "Large", "Huge"], group = grpB)
minGap   = input.int(4, "Keep only the strongest bubble within (candles)", minval = 0, maxval = 30, group = grpB, tooltip = "When several bubbles come close together, only the one with the most volume stays (per side when 'Separate buy and sell' is on). 0 = keep all.")
gapSide  = input.bool(true, "…separate buy and sell", group = grpB, tooltip = "On: one buy bubble and one sell bubble can coexist in the window (useful to see a fight). Off: only the single strongest bubble.")
bubTr    = input.int(0, "Extra transparency", minval = 0, maxval = 60, group = grpB)

// Buy / sell volume (volume source)
vSym = useChart ? syminfo.tickerid : volSym
[vO, vC, vV] = request.security_lower_tf(vSym, ltf, [open, close, volume])
float buyV  = 0.0
float sellV = 0.0
for [i, v] in vV
    o = vO.get(i)
    c = vC.get(i)
    if c > o
        buyV += v
    else if c < o
        sellV += v
    else
        buyV  += v / 2
        sellV += v / 2
totV   = buyV + sellV
hasVol = vV.size() > 0 and totV > 0

// Where in the candle the volume traded (chart symbol prices, so the bubble sits on the candle)
[pP, pV] = request.security_lower_tf(syminfo.tickerid, ltf, [hlc3, volume])
float pvSum = 0.0
float vSum  = 0.0
for [i, p] in pP
    w = nz(pV.get(i))
    pvSum += p * w
    vSum  += w
volPx = vSum > 0 ? pvSum / vSum : pP.size() > 0 ? pP.avg() : hl2
yPos  = bubPos == "Close" ? close : bubPos == "Candle middle" ? hl2 : math.max(low, math.min(high, volPx))

volSrc = hasVol ? totV : na
avgV   = avgType == "Median" ? ta.percentile_nearest_rank(volSrc, avgLen, 50) : ta.sma(volSrc, avgLen)
relV   = hasVol and avgV > 0 ? totV / avgV : 0.0
buyPct = hasVol ? 100 * buyV / totV : 50.0
isBuy  = buyPct >= 50
domPct = isBuy ? buyPct : 100 - buyPct

maxIdx = maxSize == "Small" ? 1 : maxSize == "Normal" ? 2 : maxSize == "Large" ? 3 : 4
bubSize(float r) =>
    idx = math.min(maxIdx, r >= 5 ? 4 : r >= 3.5 ? 3 : r >= 2.5 ? 2 : r >= 1.75 ? 1 : 0)
    idx == 4 ? size.huge : idx == 3 ? size.large : idx == 2 ? size.normal : idx == 1 ? size.small : size.tiny

// Last bubble kept per side (index 0 = buy, 1 = sell; with "separate" off both use 0)
var array<label> bL  = array.from(label(na), label(na))
var array<label> bT  = array.from(label(na), label(na))
var array<int>   bB  = array.from(int(na), int(na))
var array<float> bR  = array.from(0.0, 0.0)

showNow = showBub and hasVol and relV >= minRel and domPct >= minDom
// Declutter: inside the window, a weaker bubble is skipped; a stronger one replaces the old one
k      = gapSide and not isBuy ? 1 : 0
near   = minGap > 0 and not na(bB.get(k)) and bar_index - bB.get(k) <= minGap
drawIt = showNow and (not near or relV > bR.get(k))
if drawIt and near
    bL.get(k).delete()
    bT.get(k).delete()
if drawIt
    c     = isBuy ? bullCol : bearCol
    // 60% one-sided → faint, 85%+ → solid
    tr    = int(math.min(90, math.max(10, math.min(70, 70 - (domPct - 60) * 2.4)) + bubTr))
    delta = buyV - sellV
    tip   = (isBuy ? "BUYERS dominated" : "SELLERS dominated") + "\nBuy volume:  " + str.tostring(buyV, format.volume) + " (" + str.tostring(buyPct, "0") + "%)" + "\nSell volume: " + str.tostring(sellV, format.volume) + " (" + str.tostring(100 - buyPct, "0") + "%)" + "\nDelta: " + (delta >= 0 ? "+" : "") + str.tostring(delta, format.volume) + "\nVolume: " + str.tostring(relV, "0.0") + "× normal"
    bL.set(k, label.new(bar_index, yPos, "", style = label.style_circle, color = color.new(c, tr), size = bubSize(relV), tooltip = tip, force_overlay = true))
    bT.set(k, showTxt ? label.new(bar_index, yPos, "   " + str.tostring(domPct, "0") + "%", style = label.style_label_left, color = color.new(c, 100), textcolor = color.new(c, 10), size = size.tiny, tooltip = tip, force_overlay = true) : label(na))
    bB.set(k, bar_index)
    bR.set(k, relV)

// Data check. The newest 1–2 candles often have no futures data yet (COMEX data on TradingView
// is delayed ~10 min without a CME subscription), so they simply get no bubble. Only warn when
// there has been no volume data for a long stretch (wrong timeframe or symbol).
var int   lastData = na
var label warnLbl  = na
if hasVol
    lastData := bar_index
if barstate.islast
    warnLbl.delete()
    if showBub and (na(lastData) or bar_index - lastData > 20)
        warnLbl := label.new(bar_index, high, "No intrabar volume: use a chart timeframe above " + ltf + " or change the volume source.", style = label.style_label_down, color = color.new(#787B86, 20), textcolor = color.white, size = size.small, force_overlay = true)

alertcondition(drawIt and isBuy, "Big buy bubble", "Arruda Bubbles: heavy BUY volume on {{ticker}} {{interval}} at {{close}}")
alertcondition(drawIt and not isBuy, "Big sell bubble", "Arruda Bubbles: heavy SELL volume on {{ticker}} {{interval}} at {{close}}")

// ═════════════════════════════ TREND TABLE ═════════════════════════════
grpT    = "Trend table"
showTbl = input.bool(true, "Show trend table", group = grpT)
tMethod = input.string("EMA cloud", "Trend by", options = ["EMA cloud", "Supertrend", "Price vs EMA 3"], group = grpT, tooltip = "EMA cloud: EMA 1 above EMA 2 = ▲ (the same cloud as on the chart, on each timeframe).\nSupertrend: ATR 10, factor 2.5.\nPrice vs EMA 3: close above the EMA 3 (89) = ▲.")
tblPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpT)
tblSize = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)

f_trend() =>
    float r = na
    if tMethod == "EMA cloud"
        r := ta.ema(close, e1Len) >= ta.ema(close, e2Len) ? 1 : -1
    else if tMethod == "Supertrend"
        [st_, d_] = ta.supertrend(2.5, 10)
        r := d_ < 0 ? 1 : -1
    else
        r := close >= ta.ema(close, e3Len) ? 1 : -1
    r
tr5  = request.security(syminfo.tickerid, "5",   f_trend())
tr15 = request.security(syminfo.tickerid, "15",  f_trend())
tr60 = request.security(syminfo.tickerid, "60",  f_trend())
tr4h = request.security(syminfo.tickerid, "240", f_trend())
trD  = request.security(syminfo.tickerid, "D",   f_trend())
trW  = request.security(syminfo.tickerid, "W",   f_trend())

tPos = tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.top_right
tSz  = tblSize == "Tiny" ? size.tiny : tblSize == "Normal" ? size.normal : size.small
var table tbl = table.new(tPos, 7, 2, bgcolor = color.new(#131722, 15), border_color = color.new(#787B86, 80), border_width = 1, force_overlay = true)
f_cell(int c, string h, float t) =>
    table.cell(tbl, c, 0, h, text_color = #B2B5BE, text_size = tSz)
    table.cell(tbl, c, 1, na(t) ? "–" : t > 0 ? "▲" : "▼", bgcolor = na(t) ? color.new(#787B86, 50) : color.new(t > 0 ? bullCol : bearCol, 25), text_color = color.white, text_size = tSz)
if barstate.islast
    if showTbl
        f_cell(0, "5m", tr5)
        f_cell(1, "15m", tr15)
        f_cell(2, "1H", tr60)
        f_cell(3, "4H", tr4h)
        f_cell(4, "D", trD)
        f_cell(5, "W", trW)
        sumT = nz(tr5) + nz(tr15) + nz(tr60) + nz(tr4h) + nz(trD) + nz(trW)
        table.cell(tbl, 6, 0, "Bias", text_color = #B2B5BE, text_size = tSz, tooltip = "Sum of the six timeframes (−6 … +6).")
        table.cell(tbl, 6, 1, (sumT > 0 ? "+" : "") + str.tostring(sumT), bgcolor = sumT >= 4 ? color.new(bullCol, 25) : sumT <= -4 ? color.new(bearCol, 25) : color.new(#787B86, 50), text_color = color.white, text_size = tSz, tooltip = "≥ +4 green, ≤ −4 red, otherwise grey (mixed).")
    else
        table.clear(tbl, 0, 0, 6, 1)

// ═════════════════════════════ PANEL: DELTA / CVD ═════════════════════════════
// Delta = buy volume − sell volume of each candle (same split as the bubbles).
// CVD = delta added up since the start of the day: rising = buyers keep pressing, falling = sellers.
// Divergence (yellow): price makes a higher high but CVD a lower high (fewer buyers behind the
// move), or price makes a lower low but CVD a higher low.
grpP    = "Panel: delta / CVD"
pMode   = input.string("Delta + CVD", "Show", options = ["Delta + CVD", "Delta", "CVD"], group = grpP, tooltip = "Delta + CVD: delta bars, with the CVD drawn as a line scaled to fit the same panel (its shape matters, not its value).")
cvdRst  = input.string("Day", "CVD reset", options = ["Day", "Week", "Never"], group = grpP)
dSm     = input.int(5, "Delta average (line, 0 = off)", minval = 0, group = grpP)
cvdDiv  = input.bool(true, "Mark price / CVD divergences", group = grpP)
divLen  = input.int(5, "Divergence swing strength", minval = 2, group = grpP)
divCol  = input.color(#FFD600, "Divergence colour", group = grpP)

float delta = hasVol ? buyV - sellV : na
var float cvd = 0.0
if cvdRst == "Day" ? timeframe.change("D") : cvdRst == "Week" ? timeframe.change("W") : false
    cvd := 0.0
cvd += nz(delta)

// CVD scaled into the delta range for the combined view
dAbs   = ta.highest(math.abs(nz(delta)), 100)
cvdHi  = ta.highest(cvd, 100)
cvdLo  = ta.lowest(cvd, 100)
cvdMid = (cvdHi + cvdLo) / 2
cvdSc  = cvdHi > cvdLo ? (cvd - cvdMid) / ((cvdHi - cvdLo) / 2) * nz(dAbs, 1) : 0.0

showD   = pMode != "CVD"
showC   = pMode != "Delta"
cvdPlot = pMode == "CVD" ? cvd : cvdSc
plot(showD ? delta : na, "Delta", nz(delta) >= 0 ? color.new(bullCol, 30) : color.new(bearCol, 30), style = plot.style_columns)
plot(showD and dSm > 0 ? ta.ema(nz(delta), dSm) : na, "Delta average", color.new(color.white, 40), 1)
plot(showC ? cvdPlot : na, "CVD", cvd >= cvd[1] ? color.new(bullCol, 0) : color.new(bearCol, 0), 2)
hline(0, "Zero", color.new(#787B86, 60), hline.style_dotted)

// Price / CVD divergences (compared only within the same CVD period)
dPH = ta.pivothigh(high, divLen, divLen)
dPL = ta.pivotlow(low, divLen, divLen)
var float lPHp = na
var float lPHc = na
var int   lPHb = na
var float lPLp = na
var float lPLc = na
var int   lPLb = na
var int   cvdSess = 0
if cvdRst == "Day" ? timeframe.change("D") : cvdRst == "Week" ? timeframe.change("W") : false
    cvdSess += 1
var int sessPH = na
var int sessPL = na
bool bearDivC = false
bool bullDivC = false
if not na(dPH)
    cNow = cvd[divLen]
    yNow = cvdPlot[divLen]
    if not na(lPHp) and sessPH == cvdSess and dPH > lPHp and cNow < lPHc
        bearDivC := true
        if cvdDiv and showC
            line.new(lPHb, cvdPlot[bar_index - lPHb], bar_index - divLen, yNow, color = divCol, width = 1)
            label.new(bar_index - divLen, yNow, "D", style = label.style_label_down, color = color.new(divCol, 100), textcolor = divCol, size = size.small)
    lPHp := dPH
    lPHc := cNow
    lPHb := bar_index - divLen
    sessPH := cvdSess
if not na(dPL)
    cNow = cvd[divLen]
    yNow = cvdPlot[divLen]
    if not na(lPLp) and sessPL == cvdSess and dPL < lPLp and cNow > lPLc
        bullDivC := true
        if cvdDiv and showC
            line.new(lPLb, cvdPlot[bar_index - lPLb], bar_index - divLen, yNow, color = divCol, width = 1)
            label.new(bar_index - divLen, yNow, "D", style = label.style_label_up, color = color.new(divCol, 100), textcolor = divCol, size = size.small)
    lPLp := dPL
    lPLc := cNow
    lPLb := bar_index - divLen
    sessPL := cvdSess
alertcondition(bearDivC, "CVD bearish divergence", "Arruda Bubbles: price higher high, CVD lower high on {{ticker}} {{interval}}")
alertcondition(bullDivC, "CVD bullish divergence", "Arruda Bubbles: price lower low, CVD higher low on {{ticker}} {{interval}}")

// ═════════════════════════════ SCORE TRIGGER ═════════════════════════════
// Fires on the candle where the EMA cloud changes colour, and scores the setup.
// A · Pullback with the trend (BUY; SELL is the mirror image) — 1 point each, max 8:
//   1 Bias ≥ N   2 close above EMA 89   3 structure bullish (last break was up)
//   4 the pullback touched a zone in the last candles (EQL, the broken BOS/CHoCH level or EMA 89)
//   5 a buy bubble in the last candles   6 a buy candle inside the downtrend (green outline)
//   7 delta of the last 3 candles positive, or a bullish CVD divergence   8 Hull rising
// B · Reversal at liquidity (only when A is not valid) — requires an EQL sweep in the last
//   candles, then 1 point each, max 5: buy bubble · bullish CVD divergence · bullish CHoCH ·
//   Hull rising · delta of the last 3 candles positive.
grpQ    = "Score trigger"
showQ   = input.bool(true, "Show score signals", group = grpQ)
useB    = input.bool(true, "Include B (reversal at liquidity)", group = grpQ)
minA    = input.int(5, "Minimum score A (of 8)", minval = 1, maxval = 8, group = grpQ)
minB    = input.int(3, "Minimum score B (of 5)", minval = 1, maxval = 5, group = grpQ)
useC    = input.bool(true, "Include C (continuation: pullback inside the trend, no cloud flip)", group = grpQ, tooltip = "C · BUY: cloud green and price above EMA 89; in the last candles price pulled back into the cloud (touched EMA 1); now the Hull turns up or a buy bubble prints, on a green candle closing above EMA 1. Mirror for SELL.")
cLook   = input.int(6, "C: pullback within (candles)", minval = 1, maxval = 30, group = grpQ)
cGap    = input.int(10, "C: minimum candles between C signals", minval = 1, maxval = 100, group = grpQ)
alMode  = input.string("A strong + C strong + R", "'Any alert() function call' sends", options = ["A strong + C strong + R", "A strong + C strong", "Only C strong", "Only A strong", "Only R"], group = grpQ)
useR    = input.bool(true, "Include R (range breakout with volume)", group = grpQ, tooltip = "R · BUY: a candle closes above a sideways range (see Range filter), Bias positive, green candle, and volume confirms on that candle (a buy bubble, or ≥ 60% buying with ≥ 1.5× normal volume). Stop just beyond the middle of the range. Mirror for SELL.")
useS    = input.bool(true, "Include S (structure break after HL / LH at a zone)", group = grpQ, tooltip = "S · BUY: price closes above the last swing high (bullish CHoCH or BOS) while the cloud is green (EMA 1 ≥ EMA 2) and price is above EMA 89; the last swing low was a Higher Low and it touched a zone (EQL, BOS level or EMA 89). Stop below that HL. Mirror for SELL. Not backtested yet: visual only, no alert() by default.")
sLook   = input.int(30, "S: HL / LH no older than (candles)", minval = 5, maxval = 200, group = grpQ)
sMin    = input.int(0, "S: minimum score (of 5, 0 = show all)", minval = 0, maxval = 5, group = grpQ, tooltip = "S score, 1 point each: Bias with the trade · bubble on the trade side (last candles) · delta of the last 3 candles with the trade or CVD divergence · Hull with the trade · break candle with volume (≥ 1.2× normal and ≥ 55% on the trade side).")
cAlMin  = input.int(4, "C: minimum score for 'Any alert() function call'", minval = 0, maxval = 5, group = grpQ)
cMin    = input.int(0, "C: minimum score (of 5, 0 = show all)", minval = 0, maxval = 5, group = grpQ, tooltip = "C score, 1 point each: Bias with the trade · structure with the trade · pullback touched a zone (EQL/EQH, BOS level or EMA 89) · bubble on the trade side · delta of the last 3 candles with the trade or CVD divergence.")
qBias   = input.int(4, "Bias needed for A (table)", minval = 1, maxval = 6, group = grpQ)
qLook   = input.int(10, "Look back for the pullback / sweep (candles)", minval = 2, maxval = 50, group = grpQ)
qTolA   = input.float(0.3, "Zone touch tolerance (ATR)", minval = 0, step = 0.05, group = grpQ)
qLines  = input.bool(true, "Draw stop / target", group = grpQ)
qRR     = input.float(2.0, "Target when no liquidity ahead (R)", minval = 0.5, step = 0.5, group = grpQ)
qAlMin  = input.int(7, "Strong-signal alerts: minimum score A", minval = 1, maxval = 8, group = grpQ, tooltip = "Used by the 'Score A strong BUY / SELL' alerts and by 'Any alert() function call'. 7 = the only score level that was positive on both 5m and 10m in the backtest.")

qAtr    = ta.atr(14)
qTol    = qTolA * qAtr
e89     = ta.ema(close, e3Len)
biasSum = nz(tr5) + nz(tr15) + nz(tr60) + nz(tr4h) + nz(trD) + nz(trW)

// Zone touches
f_inZone(int t, float hi, float lo) =>
    bool hit = false
    for z in zones
        if z.t == t and lo <= z.mx + qTol and hi >= z.mn - qTol
            hit := true
            break
    hit
touchB = f_inZone(-1, high, low) or (not na(brkUpLvl) and low <= brkUpLvl + qTol and high >= brkUpLvl - qTol) or (low <= e89 + qTol and high >= e89 - qTol)
touchS = f_inZone(1, high, low)  or (not na(brkDnLvl) and high >= brkDnLvl - qTol and low <= brkDnLvl + qTol) or (high >= e89 - qTol and low <= e89 + qTol)
within(bool c) => nz(ta.barssince(c), 9999) <= qLook

d3 = math.sum(nz(delta), 3)
wDivB = within(bullDivC)
wDivS = within(bearDivC)
wChU  = within(chUp)
wChD  = within(chDn)
qLo   = ta.lowest(low, qLook)
qHi   = ta.highest(high, qLook)
// A · points
a1B = biasSum >= qBias
a2B = close > e89
a3B = msTrend == 1
a4B = within(touchB)
a5B = within(drawIt and isBuy)
a6B = within(not trendUp and close > open)
a7B = d3 > 0 or wDivB
a8B = fastUp
a1S = biasSum <= -qBias
a2S = close < e89
a3S = msTrend == -1
a4S = within(touchS)
a5S = within(drawIt and not isBuy)
a6S = within(trendUp and close < open)
a7S = d3 < 0 or wDivS
a8S = not fastUp
pt(bool b) => b ? 1 : 0
scAB = pt(a1B) + pt(a2B) + pt(a3B) + pt(a4B) + pt(a5B) + pt(a6B) + pt(a7B) + pt(a8B)
scAS = pt(a1S) + pt(a2S) + pt(a3S) + pt(a4S) + pt(a5S) + pt(a6S) + pt(a7S) + pt(a8S)
// B · points (needs a sweep of the opposite liquidity)
swB  = not na(eqlSweepBar) and bar_index - eqlSweepBar <= qLook
swS  = not na(eqhSweepBar) and bar_index - eqhSweepBar <= qLook
scBB = pt(a5B) + pt(wDivB) + pt(wChU) + pt(fastUp) + pt(d3 > 0)
scBS = pt(a5S) + pt(wDivS) + pt(wChD) + pt(not fastUp) + pt(d3 < 0)

// Range filter: no signals while the market is going sideways, but signals are allowed again
// as soon as price breaks out of the range (and for a few candles after the breakout).
// Sideways = the last N candles fit in a narrow band (≤ X × ATR) OR the cloud flipped colour
// many times in those candles (whipsaw).
grpRg   = "Range filter"
rgOn    = input.bool(true, "Block signals in sideways markets", group = grpRg)
rgLen   = input.int(30, "Look-back (candles)", minval = 5, maxval = 200, group = grpRg)
rgAtr   = input.float(4.0, "Sideways if the range is narrower than (× ATR)", minval = 0.5, step = 0.5, group = grpRg)
rgFlips = input.int(4, "…or the cloud flipped at least (times)", minval = 2, maxval = 20, group = grpRg)
rgKeep  = input.int(10, "After a breakout, allow signals for (candles)", minval = 1, maxval = 50, group = grpRg)
rgOnC   = input.bool(false, "Also block C signals", group = grpRg)
rgShow  = input.bool(true, "Shade sideways zones", group = grpRg)
rgHi    = ta.highest(high, rgLen)[1]
rgLo    = ta.lowest(low, rgLen)[1]
rgFlipN = math.sum((cloudUp or cloudDn) ? 1 : 0, rgLen)
sideways = (rgHi - rgLo) <= rgAtr * qAtr or rgFlipN >= rgFlips
rgOutUp  = sideways[1] and close > rgHi
rgOutDn  = sideways[1] and close < rgLo
okRgB    = not rgOn or not sideways or nz(ta.barssince(rgOutUp), 9999) <= rgKeep
okRgS    = not rgOn or not sideways or nz(ta.barssince(rgOutDn), 9999) <= rgKeep
okRgCB   = not rgOnC or okRgB
okRgCS   = not rgOnC or okRgS
bgcolor(rgOn and rgShow and sideways ? color.new(#787B86, 90) : na, title = "Sideways zone", force_overlay = true)
plotshape(rgOn and rgOutUp, "Range breakout up", shape.diamond, location.belowbar, color.new(#00C853, 0), size = size.tiny, force_overlay = true)
plotshape(rgOn and rgOutDn, "Range breakout down", shape.diamond, location.abovebar, color.new(#FF1744, 0), size = size.tiny, force_overlay = true)

sigAB = cloudUp and scAB >= minA and okRgB
sigAS = cloudDn and scAS >= minA and okRgS
sigBB = useB and cloudUp and not sigAB and swB and scBB >= minB and okRgB
sigBS = useB and cloudDn and not sigAS and swS and scBS >= minB and okRgS
// C · continuation (no cloud flip)
cPullB = nz(ta.barssince(low <= eF), 9999) <= cLook
cPullS = nz(ta.barssince(high >= eF), 9999) <= cLook
cTrigB = (fastUp and not fastUp[1]) or (drawIt and isBuy)
cTrigS = (not fastUp and fastUp[1]) or (drawIt and not isBuy)
cw(bool c) => nz(ta.barssince(c), 9999) <= cLook
c3B = cw(touchB)
c4B = cw(drawIt and isBuy)
c5B = d3 > 0 or cw(bullDivC)
c3S = cw(touchS)
c4S = cw(drawIt and not isBuy)
c5S = d3 < 0 or cw(bearDivC)
scCB = pt(biasSum >= qBias) + pt(msTrend == 1) + pt(c3B) + pt(c4B) + pt(c5B)
scCS = pt(biasSum <= -qBias) + pt(msTrend == -1) + pt(c3S) + pt(c4S) + pt(c5S)
var int lastCB = na
var int lastCS = na
sigCB = useC and not cloudUp and eF >= eS and close > e89 and cPullB and cTrigB and close > open and close > eF and (na(lastCB) or bar_index - lastCB >= cGap) and not sigAB and not sigBB and scCB >= cMin and okRgCB
sigCS = useC and not cloudDn and eF < eS and close < e89 and cPullS and cTrigS and close < open and close < eF and (na(lastCS) or bar_index - lastCS >= cGap) and not sigAS and not sigBS and scCS >= cMin and okRgCS
if sigCB
    lastCB := bar_index
if sigCS
    lastCS := bar_index
// S · structure break after a HL / LH at a zone
zSumB  = math.sum(touchB ? 1 : 0, 2 * swLen + 1)
zSumS  = math.sum(touchS ? 1 : 0, 2 * swLen + 1)
var bool slZone = false
var bool shZone = false
if not na(sPL)
    slZone := zSumB > 0
if not na(sPH)
    shZone := zSumS > 0
sVolB  = hasVol and buyPct >= 55 and relV >= 1.2
sVolS  = hasVol and buyPct <= 45 and relV >= 1.2
sBubB  = cw(drawIt and isBuy)
sBubS  = cw(drawIt and not isBuy)
sDltB  = d3 > 0 or cw(bullDivC)
sDltS  = d3 < 0 or cw(bearDivC)
scSB   = pt(biasSum > 0) + pt(sBubB) + pt(sDltB) + pt(fastUp) + pt(sVolB)
scSS   = pt(biasSum < 0) + pt(sBubS) + pt(sDltS) + pt(not fastUp) + pt(sVolS)
sigSB  = useS and (chUp or bosUp) and eF >= eS and close > e89 and close > open and slHL and slZone and not na(lastSLb) and bar_index - lastSLb <= sLook and scSB >= sMin and not sigAB and not sigBB and not sigCB
sigSS  = useS and (chDn or bosDn) and eF < eS and close < e89 and close < open and shLH and shZone and not na(lastSHb) and bar_index - lastSHb <= sLook and scSS >= sMin and not sigAS and not sigBS and not sigCS
// R · range breakout with volume
rgMid  = (rgHi + rgLo) / 2
rVolB  = (drawIt and isBuy) or (hasVol and buyPct >= 60 and relV >= 1.5)
rVolS  = (drawIt and not isBuy) or (hasVol and buyPct <= 40 and relV >= 1.5)
sigRB  = useR and rgOutUp and biasSum > 0 and close > open and rVolB and not sigAB and not sigBB and not sigCB and not sigSB
sigRS  = useR and rgOutDn and biasSum < 0 and close < open and rVolS and not sigAS and not sigBS and not sigCS and not sigSS
qBuy  = sigAB or sigBB or sigCB or sigSB or sigRB
qSell = sigAS or sigBS or sigCS or sigSS or sigRS

mk(bool b) => b ? "✓ " : "✗ "
f_nextZone(int t, float px) =>
    float best = na
    for z in zones
        if t == 1 and z.t == 1 and z.mn > px and (na(best) or z.mn < best)
            best := z.mn
        if t == -1 and z.t == -1 and z.mx < px and (na(best) or z.mx > best)
            best := z.mx
    best

if showQ and barstate.isconfirmed and (qBuy or qSell)
    isL   = qBuy
    isA   = isL ? sigAB : sigAS
    isC   = isL ? sigCB : sigCS
    isR   = isL ? sigRB : sigRS
    isS   = isL ? sigSB : sigSS
    sc    = isS ? (isL ? scSB : scSS) : isC ? (isL ? scCB : scCS) : isL ? (isA ? scAB : scBB) : (isA ? scAS : scBS)
    mx    = isA ? 8 : 5
    stp   = isS ? (isL ? lastSL - 0.2 * qAtr : lastSH + 0.2 * qAtr) : isR ? (isL ? rgMid - 0.2 * qAtr : rgMid + 0.2 * qAtr) : isL ? qLo - 0.2 * qAtr : qHi + 0.2 * qAtr
    risk  = math.abs(close - stp)
    zt    = f_nextZone(isL ? 1 : -1, close)
    tgt   = not na(zt) and math.abs(zt - close) >= risk ? zt : close + (isL ? 1 : -1) * qRR * risk
    rr    = risk > 0 ? math.abs(tgt - close) / risk : na
    tipA  = isL ? (mk(a1B) + "Bias ≥ " + str.tostring(qBias) + " (" + str.tostring(biasSum) + ")\n" + mk(a2B) + "Above EMA 89\n" + mk(a3B) + "Structure bullish\n" + mk(a4B) + "Pullback touched EQL / BOS level / EMA 89\n" + mk(a5B) + "Buy bubble\n" + mk(a6B) + "Buy candle in the pullback\n" + mk(a7B) + "Delta positive / CVD divergence\n" + mk(a8B) + "Hull rising") : (mk(a1S) + "Bias ≤ −" + str.tostring(qBias) + " (" + str.tostring(biasSum) + ")\n" + mk(a2S) + "Below EMA 89\n" + mk(a3S) + "Structure bearish\n" + mk(a4S) + "Pullback touched EQH / BOS level / EMA 89\n" + mk(a5S) + "Sell bubble\n" + mk(a6S) + "Sell candle in the pullback\n" + mk(a7S) + "Delta negative / CVD divergence\n" + mk(a8S) + "Hull falling")
    tipB  = isL ? ("✓ EQL swept\n" + mk(a5B) + "Buy bubble\n" + mk(wDivB) + "CVD divergence\n" + mk(wChU) + "Bullish CHoCH\n" + mk(fastUp) + "Hull rising\n" + mk(d3 > 0) + "Delta positive") : ("✓ EQH swept\n" + mk(a5S) + "Sell bubble\n" + mk(wDivS) + "CVD divergence\n" + mk(wChD) + "Bearish CHoCH\n" + mk(not fastUp) + "Hull falling\n" + mk(d3 < 0) + "Delta negative")
    tipC  = (isL ? (mk(biasSum >= qBias) + "Bias ≥ " + str.tostring(qBias) + " (" + str.tostring(biasSum) + ")\n" + mk(msTrend == 1) + "Structure bullish\n" + mk(c3B) + "Pullback touched EQL / BOS level / EMA 89\n" + mk(c4B) + "Buy bubble\n" + mk(c5B) + "Delta positive / CVD divergence") : (mk(biasSum <= -qBias) + "Bias ≤ −" + str.tostring(qBias) + " (" + str.tostring(biasSum) + ")\n" + mk(msTrend == -1) + "Structure bearish\n" + mk(c3S) + "Pullback touched EQH / BOS level / EMA 89\n" + mk(c4S) + "Sell bubble\n" + mk(c5S) + "Delta negative / CVD divergence")) + "\n\nTrigger: " + ((isL ? (fastUp and not fastUp[1]) : (not fastUp and fastUp[1])) ? "Hull turned" : (isL ? "buy bubble" : "sell bubble"))
    tipR  = "Sideways range " + str.tostring(rgLo, format.mintick) + " – " + str.tostring(rgHi, format.mintick) + "\nClosed " + (isL ? "above" : "below") + " the range · Bias " + str.tostring(biasSum) + "\nVolume: " + str.tostring(isL ? buyPct : 100 - buyPct, "0") + "% " + (isL ? "buying" : "selling") + " · " + str.tostring(relV, "0.0") + "× normal" + (drawIt ? " (bubble)" : "")
    tipS  = isL ? ("✓ Higher Low at a zone (" + str.tostring(lastSL, format.mintick) + ")\n✓ " + (chUp ? "Bullish CHoCH" : "Bullish BOS") + " · cloud green · above EMA 89\n\n" + mk(biasSum > 0) + "Bias positive (" + str.tostring(biasSum) + ")\n" + mk(sBubB) + "Buy bubble\n" + mk(sDltB) + "Delta positive / CVD divergence\n" + mk(fastUp) + "Hull rising\n" + mk(sVolB) + "Break candle with buying volume") : ("✓ Lower High at a zone (" + str.tostring(lastSH, format.mintick) + ")\n✓ " + (chDn ? "Bearish CHoCH" : "Bearish BOS") + " · cloud red · below EMA 89\n\n" + mk(biasSum < 0) + "Bias negative (" + str.tostring(biasSum) + ")\n" + mk(sBubS) + "Sell bubble\n" + mk(sDltS) + "Delta negative / CVD divergence\n" + mk(not fastUp) + "Hull falling\n" + mk(sVolS) + "Break candle with selling volume")
    tip   = isS ? ("S · Structure break" + (isL ? " — BUY" : " — SELL") + " (not backtested)\nScore " + str.tostring(sc) + "/5\n\n" + tipS + "\n\nEntry " + str.tostring(close, format.mintick) + " · Stop " + str.tostring(stp, format.mintick) + " · Target " + str.tostring(tgt, format.mintick) + " (" + str.tostring(rr, "0.0") + "R)") : isR ? ("R · Range breakout" + (isL ? " — BUY" : " — SELL") + "\n\n" + tipR + "\n\nEntry " + str.tostring(close, format.mintick) + " · Stop " + str.tostring(stp, format.mintick) + " · Target " + str.tostring(tgt, format.mintick) + " (" + str.tostring(rr, "0.0") + "R)") : isC ? ("C · Continuation" + (isL ? " — BUY" : " — SELL") + "\nScore " + str.tostring(sc) + "/5\n\n" + tipC + "\n\nEntry " + str.tostring(close, format.mintick) + " · Stop " + str.tostring(stp, format.mintick) + " · Target " + str.tostring(tgt, format.mintick) + " (" + str.tostring(rr, "0.0") + "R)") : ((isA ? "A · Pullback with the trend" : "B · Reversal at liquidity (smaller size)") + (isL ? " — BUY" : " — SELL") + "\nScore " + str.tostring(sc) + "/" + str.tostring(mx) + "\n\n" + (isA ? tipA : tipB) + "\n\nEntry " + str.tostring(close, format.mintick) + " · Stop " + str.tostring(stp, format.mintick) + " · Target " + str.tostring(tgt, format.mintick) + " (" + str.tostring(rr, "0.0") + "R)")
    qc    = isL ? #00C853 : #FF1744
    label.new(bar_index, isL ? low : high, (isR ? "R" : isS ? "S " + str.tostring(sc) + "/5" : isC ? "C " + str.tostring(sc) + "/5" : (isA ? "A " : "B ") + str.tostring(sc) + "/" + str.tostring(mx)), yloc = isL ? yloc.belowbar : yloc.abovebar, style = isL ? label.style_label_up : label.style_label_down, color = isA ? qc : isS ? color.new(isL ? #2962FF : #FF6D00, 10) : isC ? color.new(qc, 20) : color.new(qc, 45), textcolor = color.white, size = size.small, tooltip = tip, force_overlay = true)
    aA = isA and sc >= qAlMin and (alMode == "A strong + C strong + R" or alMode == "A strong + C strong" or alMode == "Only A strong")
    aC = isC and sc >= cAlMin and (alMode == "A strong + C strong + R" or alMode == "A strong + C strong" or alMode == "Only C strong")
    aR = isR and (alMode == "A strong + C strong + R" or alMode == "Only R")
    if aA or aC or aR
        alert("Arruda Bubbles: " + (isR ? "R range breakout " : isC ? "C " + str.tostring(sc) + "/5 " : "A " + str.tostring(sc) + "/8 ") + (isL ? "BUY " : "SELL ") + syminfo.ticker + " (" + timeframe.period + ") @ " + str.tostring(close, format.mintick) + " | stop " + str.tostring(stp, format.mintick) + " | target " + str.tostring(tgt, format.mintick) + " (" + str.tostring(rr, "0.0") + "R)", alert.freq_once_per_bar_close)
    if qLines
        line.new(bar_index, stp, bar_index + 15, stp, color = color.new(#FF1744, 0), style = line.style_dotted, width = 2, force_overlay = true)
        line.new(bar_index, tgt, bar_index + 15, tgt, color = color.new(#00C853, 0), style = line.style_dotted, width = 2, force_overlay = true)

alertcondition(sigSB, "S structure break BUY", "Arruda Bubbles: S structure break BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigSS, "S structure break SELL", "Arruda Bubbles: S structure break SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigRB, "R range breakout BUY", "Arruda Bubbles: R range breakout BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigRS, "R range breakout SELL", "Arruda Bubbles: R range breakout SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(qBuy, "Score BUY", "Arruda Bubbles: score BUY signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(qSell, "Score SELL", "Arruda Bubbles: score SELL signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigAB and scAB >= qAlMin, "Score A strong BUY", "Arruda Bubbles: STRONG score A BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigCB, "C continuation BUY", "Arruda Bubbles: C continuation BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigCB and scCB >= 4, "C continuation BUY (score 4+)", "Arruda Bubbles: C BUY score 4+ on {{ticker}} {{interval}} at {{close}}")
alertcondition((sigAB and scAB >= qAlMin) or (sigAS and scAS >= qAlMin) or (sigCB and scCB >= cAlMin) or (sigCS and scCS >= cAlMin) or sigRB or sigRS, "ALL strong signals (A + C + R, BUY + SELL)", "Arruda Bubbles: strong signal on {{ticker}} {{interval}} at {{close}} - check the chart")
alertcondition((sigCB and scCB >= cAlMin) or (sigCS and scCS >= cAlMin), "C strong BUY or SELL", "Arruda Bubbles: C strong signal (BUY or SELL) on {{ticker}} {{interval}} at {{close}} - check the chart")
alertcondition(sigCS and scCS >= 4, "C continuation SELL (score 4+)", "Arruda Bubbles: C SELL score 4+ on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigCS, "C continuation SELL", "Arruda Bubbles: C continuation SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(sigAS and scAS >= qAlMin, "Score A strong SELL", "Arruda Bubbles: STRONG score A SELL on {{ticker}} {{interval}} at {{close}}")
````
