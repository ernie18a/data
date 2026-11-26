# VP + Smart HiLo [I.M]

- url: https://www.tradingview.com/script/z3RDZOr0-VP-Smart-HiLo-I-M/
- type: indicator
- pine_id: PUB;03181380e49f4e1fa95a79de580836df
- version: 1.0

## Description

🟣 Overview

Volume Profile + Smart HiLo Engine ("HLS+ [I.M]") is a discretionary context tool that unifies three complementary structure components into a single overlay: a progressive HiLo Stairs structure, a clean Volume Profile reference panel (POC / VAH / VAL), and a confluence-filtered Smart HiLo Engine with adaptive ribbon and force-scored flip signals.

The screenshot below shows everything working together on BTCUSDT (Binance) on the 15-minute timeframe — refer back to it throughout the description, since each section refers to the same chart.

📊 Live example chart: https://www.tradingview.com/x/NaT14hZT/

🟣 What You See on the Chart

Looking at the example image:

- The blue / purple ribbon flowing through the candles is the Smart HiLo ribbon. Blue means HiLo state is bullish (close above the adaptive HiLo channel), purple means bearish. Rendered as a 3-layer glow for clarity without dominating the chart.
- Each "FLIP" label with a force number (e.g. "FLIP 71") is a confluence-qualified flip — the ribbon changed direction AND the move passed both the force threshold and the POC confluence filter. Low-quality flips appear as small discreet triangles only.
- A "★ STRONG BEAR ★" or "★ STRONG BULL ★" highlight (e.g. "Force 91" in the example) is a premium signal: force score reached the premium threshold (default 85), indicating strong alignment of volume, body and ATR distance.
- The horizontal stair levels labeled HH / HL / LH / LL are the HiLo Stairs — progressive swing levels. Blue stairs mean higher highs / higher lows (bullish), purple stairs mean lower highs / lower lows (bearish). Each stair has a subtle halo glow.
- The side labels "POC", "VAH" and "VAL" on the right edge show the current Point of Control and Value Area boundaries of the rolling Volume Profile, with precise prices. Their dashed/dotted lines extend back across the lookback window.
- The info panel in the top-right corner shows POC, VAH, VAL, where price sits relative to the Value Area, Stairs direction, and HiLo ribbon direction.

🟣 What Makes It Original

HLS+ [I.M] is not a wrapper around the classic Gann HiLo Activator or a standard Volume Profile. The originality is in how three independent layers are combined and filtered:

Adaptive HiLo channel with volatility-aware length
The HiLo channel length adjusts automatically to current volatility (ATR(14) vs SMA of ATR(50)). In calm regimes the channel tightens, in volatile regimes it widens. This adaptive length produces a ribbon that does not whipsaw in compressed markets and does not lag in expansion.

Force-scored flips with POC confluence filter
Every direction flip is scored 0-100 from three components — volume vs average, candle body ratio, and ATR distance. The score alone is not enough: the flip must also pass a POC confluence filter (bullish flips require price near or above the rolling POC, bearish flips require price near or below). Flips failing either gate are demoted to small discreet markers.

Progressive HiLo Stairs structure
Stairs are stored as typed arrays of pivot highs and lows. Each step is classified as HH / HL (bullish progression) or LH / LL (bearish progression) by comparing to the previous swing of the same kind. The overall stairs trend is derived from the relationship between the last two highs AND lows together, not from a single swing.

Volume Profile as silent reference
The Volume Profile rolling lookback is computed but only POC, VAH and VAL are exposed as visual references — no histogram clutter. These act as liquidity anchors that the HiLo flips reference for confluence.

🟣 How It Works — Step by Step

1. Volume Profile
The script builds a rolling volume distribution over the configurable lookback (default 150 bars, 60 rows). For each bar it spreads volume across the rows the bar's high-low range overlaps. The row with the highest volume is the POC. VAH and VAL are computed by expanding outward from the POC until cumulative volume reaches the chosen percentage (default 70%).

2. HiLo Stairs collection
Pivots are detected using ta.pivothigh and ta.pivotlow with the chosen pivot length (default 8). Each pivot is pushed into a typed array, capped at the chosen maximum (default 8 each side).

3. Stairs classification
Each pivot is compared to the previous one of the same kind:
- Higher high vs previous high → HH (blue)
- Lower high vs previous high → LH (purple)
Same logic applies to lows (HL vs LL).

4. Adaptive HiLo channel
The base HiLo length (default 14) is multiplied by a volatility factor:
adaptLen = base × (1 + (1 - ATR/SMA(ATR,50)) × adaptiveFactor)
The result is used to compute SMA(high) and SMA(low) — the upper and lower bands. The ribbon is the midpoint.

5. Direction state machine
Internal state: +1 when close crosses above the upper band, -1 when close crosses below the lower band. The ribbon color follows this state. Any change triggers a flip candidate.

6. Force Score
On each flip, three sub-scores are computed:
- Volume score (0-40): current volume vs 20-bar SMA
- Body score (0-30): |close - open| / (high - low) × 30
- ATR distance score (0-30): |close - open| / ATR × 15
Total is the sum (0-100).

7. POC confluence gate
Bullish flips require (close - POC) / ATR > -0.3 (price at or above POC, or at most 0.3 ATR below).
Bearish flips require (close - POC) / ATR < 0.3 (price at or below POC, or at most 0.3 ATR above).
Flips passing both force threshold AND confluence get the FLIP label. Flips passing the premium threshold (default 85) get the ★ STRONG ★ highlight. Flips failing either gate appear as small triangles only.

🟣 How to Use

HLS+ [I.M] is designed as a context tool, not a black-box buy/sell system.

1. Read the panel first. Stairs direction and HiLo direction together give you the structural bias. When both agree, the environment is aligned.
2. Use POC / VAH / VAL as liquidity anchors. Trade decisions tend to make more sense at or near these levels than in the middle of the Value Area.
3. Treat the FLIP signal as a confluence event, not a trigger. A FLIP means structure, force and POC confluence agreed — but you still apply your own entry rules, sizing and risk management.
4. STRONG signals (Force ≥ 85) are intentionally rare. They indicate strong alignment of volume, momentum and structure. Use them as higher-conviction entries when they appear with the broader stairs direction.
5. Mismatch is information. If the HiLo flips bullish but Stairs is still BEAR, treat it as an early signal needing confirmation — not a full reversal.

The script does not place orders, does not include backtest results, and does not claim a win rate. All decisions remain with the trader.

🟣 Inputs

Volume Profile Levels
- Lookback (bars) — rolling window for the profile (default 150)
- Profile Rows — vertical resolution of the distribution (default 60)
- Value Area % — VAH/VAL coverage of total volume (default 70)

HiLo Stairs
- Pivot Length — bars on each side required for a pivot (default 8)
- Max stairs steps — array cap to keep the script light (default 8)
- Show HH/HL/LH/LL labels — toggle the stair labels

Smart HiLo Engine
- Show Ribbon — toggle the adaptive ribbon
- HiLo Length — base length of the HiLo channel (default 14)
- ATR Adaptive Factor — how much the length reacts to volatility (default 1.0)
- Min Force Score for label — flip threshold for the FLIP label (default 65)
- Premium Force Threshold — flip threshold for the ★ STRONG ★ highlight (default 85)
- Show HiLo Bands — optional channel bands (off by default)

Visual
- Full color customization (POC, VAH/VAL, Bull, Bear)
- Show Info Panel — toggle the top-right context table

🟣 Alerts

Built-in alerts:
- Qualified Bull Flip — confluence-qualified bullish flip
- Qualified Bear Flip — confluence-qualified bearish flip
- Premium Bull Flip — premium-grade bullish flip (Force ≥ 85)
- Premium Bear Flip — premium-grade bearish flip (Force ≥ 85)

🟣 Notes and Limitations

- All structural logic is evaluated on bar close. Intra-bar values may differ from the final, confirmed reading.
- Volume-based force scoring depends on the symbol providing usable volume data. On instruments without reliable volume, the force component will be less informative.
- The Force Score is a heuristic aid, not a probability. Different markets and timeframes will live in different score ranges, and that is expected.
- POC / VAH / VAL are computed from a rolling lookback and will shift as new data arrives. This is by design — they are dynamic liquidity references, not fixed levels.

🟣 Disclaimer

This script is published for educational and informational purposes only. It is not financial advice and does not guarantee any particular outcome. Past behaviour of the indicator on historical data does not imply future performance. Trade at your own risk and size positions according to your own risk management.

## Source Code

````pine
//@version=6
indicator("HiLo Stairs + VP + Smart HiLo [I.M]", shorttitle="HLS+ [I.M]", overlay=true, max_bars_back=500, max_lines_count=400, max_labels_count=100)

type VolumeProfile
    float poc
    float vah
    float val
    int   pocRow
    int   vaHighRow
    int   vaLowRow
    float maxVolume
    float rangeLow
    float rangeHigh

g1 = "── Volume Profile Levels ──"
vpLookback = input.int(150,  "Lookback (bars)", minval=20, maxval=500, group=g1)
vpRows     = input.int(60,   "Profile Rows",    minval=20, maxval=100, group=g1)
vaPercent  = input.float(70.0, "Value Area %",  minval=50.0, maxval=90.0, step=5.0, group=g1)

g2 = "── HiLo Stairs ──"
pivotLen     = input.int(8, "Pivot Length",         minval=2, maxval=30, group=g2)
maxSteps     = input.int(8, "Max stairs steps",     minval=3, maxval=15, group=g2)
showStepTag  = input.bool(true, "Show HH/HL/LH/LL labels", group=g2)

g3 = "── Smart HiLo Engine ──"
showRibbon    = input.bool(true, "Show Ribbon",            group=g3)
hiloLen       = input.int(14, "HiLo Length",               minval=3, maxval=50, group=g3)
atrAdjust     = input.float(1.0, "ATR Adaptive Factor",    minval=0.0, maxval=3.0, step=0.1, group=g3)
forceThresh   = input.int(65, "Min Force Score for label", minval=40, maxval=90, group=g3)
premiumThresh = input.int(85, "Premium Force Threshold",   minval=70, maxval=95, group=g3)
showBands     = input.bool(false, "Show HiLo Bands",       group=g3, tooltip="HiLo channel bands (subtle)")

g4 = "── Visual ──"
pocColor    = input.color(color.rgb(255, 193, 7),    "POC Color",     group=g4)
vaEdgeColor = input.color(color.rgb(129, 212, 250),  "VAH/VAL Color", group=g4)
bullColor   = input.color(#2962FF, "Bull Color", group=g4)
bearColor   = input.color(#D946EF, "Bear Color", group=g4)
showPanel   = input.bool(true, "Show Info Panel", group=g4)

// ═════════════════════════════════════════════════════════════════════════════
// VOLUME PROFILE
// ═════════════════════════════════════════════════════════════════════════════
buildDist(int lb, int rows, float rLow, float rHigh) =>
    dist = array.new<float>(rows, 0.0)
    rowH = (rHigh - rLow) / rows
    if rowH > 0
        for i = 0 to lb - 1
            bHi = high[i]
            bLo = low[i]
            bV  = volume[i]
            if not na(bHi) and not na(bLo) and not na(bV)
                loR = math.max(0, math.floor((bLo - rLow) / rowH))
                hiR = math.min(rows - 1, math.floor((bHi - rLow) / rowH))
                span = math.max(1, hiR - loR + 1)
                vpb  = bV / span
                for r = loR to hiR
                    array.set(dist, r, array.get(dist, r) + vpb)
    dist

computeVP() =>
    rHigh = ta.highest(high, vpLookback)
    rLow  = ta.lowest(low,   vpLookback)
    rowH  = (rHigh - rLow) / vpRows
    dist  = buildDist(vpLookback, vpRows, rLow, rHigh)

    pocRow = 0
    maxVol = 0.0
    totVol = 0.0
    for r = 0 to vpRows - 1
        v = array.get(dist, r)
        totVol += v
        if v > maxVol
            maxVol := v
            pocRow := r

    target  = totVol * vaPercent / 100.0
    vaVol   = maxVol
    vaHiRow = pocRow
    vaLoRow = pocRow
    while vaVol < target and (vaHiRow < vpRows - 1 or vaLoRow > 0)
        above = vaHiRow < vpRows - 1 ? array.get(dist, vaHiRow + 1) : 0.0
        below = vaLoRow > 0          ? array.get(dist, vaLoRow - 1) : 0.0
        if above >= below and vaHiRow < vpRows - 1
            vaHiRow += 1
            vaVol   += above
        else if vaLoRow > 0
            vaLoRow -= 1
            vaVol   += below
        else
            break

    poc = rLow + (pocRow + 0.5) * rowH
    vah = rLow + (vaHiRow + 1)  * rowH
    val = rLow + vaLoRow         * rowH

    VolumeProfile.new(poc, vah, val, pocRow, vaHiRow, vaLoRow, maxVol, rLow, rHigh)

vp = computeVP()

// ═════════════════════════════════════════════════════════════════════════════
// HILO STAIRS
// ═════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)

var float[] swingHighs   = array.new<float>(0)
var int[]   swingHighBar = array.new<int>(0)
var float[] swingLows    = array.new<float>(0)
var int[]   swingLowBar  = array.new<int>(0)

if not na(ph)
    array.push(swingHighs,   ph)
    array.push(swingHighBar, bar_index - pivotLen)
    if array.size(swingHighs) > maxSteps
        array.shift(swingHighs)
        array.shift(swingHighBar)

if not na(pl)
    array.push(swingLows,   pl)
    array.push(swingLowBar, bar_index - pivotLen)
    if array.size(swingLows) > maxSteps
        array.shift(swingLows)
        array.shift(swingLowBar)

trendBull = false
trendBear = false
szH = array.size(swingHighs)
szL = array.size(swingLows)
if szH >= 2 and szL >= 2
    lastH  = array.get(swingHighs, szH - 1)
    prevH  = array.get(swingHighs, szH - 2)
    lastL  = array.get(swingLows,  szL - 1)
    prevL  = array.get(swingLows,  szL - 2)
    trendBull := lastH > prevH and lastL > prevL
    trendBear := lastH < prevH and lastL < prevL

// ═════════════════════════════════════════════════════════════════════════════
// SMART HILO ENGINE — ribbon única + filtros de confluência
// ═════════════════════════════════════════════════════════════════════════════
atrVal    = ta.atr(14)
atrSMA    = ta.sma(atrVal, 50)
volRatio  = atrSMA > 0 ? atrVal / atrSMA : 1.0
adaptLen  = math.max(3, math.round(hiloLen * (1.0 + (1.0 - volRatio) * atrAdjust)))

hiloHigh = ta.sma(high, adaptLen)
hiloLow  = ta.sma(low,  adaptLen)
hiloMid  = (hiloHigh + hiloLow) / 2

// State machine
var int hiloDir = 0
if close > hiloHigh
    hiloDir := 1
else if close < hiloLow
    hiloDir := -1

// Flip detection
var int prevDir = 0
flipBull = hiloDir == 1 and prevDir != 1
flipBear = hiloDir == -1 and prevDir != -1
prevDir := hiloDir

// FORCE SCORE
calcForce() =>
    volAvg    = ta.sma(volume, 20)
    volScore  = math.min(40.0, (volume / math.max(volAvg, 1)) * 20.0)
    range_    = high - low
    bodyRatio = range_ > 0 ? math.abs(close - open) / range_ : 0.0
    bodyScore = math.min(30.0, bodyRatio * 30.0)
    atrDist   = atrVal > 0 ? math.abs(close - open) / atrVal : 0.0
    atrScore  = math.min(30.0, atrDist * 15.0)
    int(math.round(volScore + bodyScore + atrScore))

flipScore = 0
if flipBull or flipBear
    flipScore := calcForce()

// CONFLUÊNCIA COM POC — filtro silencioso
// Flip bull "forte" se acontece NO POC ou ACIMA
// Flip bear "forte" se acontece NO POC ou ABAIXO
pocDistAtr = atrVal > 0 ? (close - vp.poc) / atrVal : 0.0
nearOrAbovePOC = pocDistAtr > -0.3
nearOrBelowPOC = pocDistAtr < 0.3

confluenceOK = (flipBull and nearOrAbovePOC) or (flipBear and nearOrBelowPOC)

// Classificação do sinal
qualifiedFlip = (flipBull or flipBear) and flipScore >= forceThresh and confluenceOK
premiumFlip   = (flipBull or flipBear) and flipScore >= premiumThresh and confluenceOK

// ═════════════════════════════════════════════════════════════════════════════
// VISUALS
// ═════════════════════════════════════════════════════════════════════════════
var line[]  stairLn  = array.new<line>()
var label[] stairLbl = array.new<label>()
var line    pocLine  = na
var line    vahLine  = na
var line    valLine  = na
var label   pocLbl   = na
var label   vahLbl   = na
var label   valLbl   = na

drawStair(int b1, int b2, float p, color baseCol) =>
    halo = line.new(b1, p, b2, p, color=color.new(baseCol, 88), width=4, style=line.style_solid)
    array.push(stairLn, halo)
    core = line.new(b1, p, b2, p, color=color.new(baseCol, 30), width=1, style=line.style_solid)
    array.push(stairLn, core)

// ── Ribbon ÚNICA com gradient direcional + glow ──
ribbonCol = hiloDir == 1 ? bullColor : hiloDir == -1 ? bearColor : color.gray

plot(showRibbon ? hiloMid : na, "Ribbon Glow Outer", color=color.new(ribbonCol, 90), linewidth=8)
plot(showRibbon ? hiloMid : na, "Ribbon Glow Mid",   color=color.new(ribbonCol, 75), linewidth=4)
plot(showRibbon ? hiloMid : na, "Ribbon Core",       color=color.new(ribbonCol, 20), linewidth=1)

// Bandas Hi/Lo (sutis, opcionais)
plot(showRibbon and showBands ? hiloHigh : na, "Hi Band", color=color.new(ribbonCol, 80), linewidth=1, style=plot.style_line)
plot(showRibbon and showBands ? hiloLow  : na, "Lo Band", color=color.new(ribbonCol, 80), linewidth=1, style=plot.style_line)

// ── Flip signals — apenas QUALIFIED flips recebem label ──
// Flip fraco: só pequeno marker discreto
weakFlip = (flipBull or flipBear) and not qualifiedFlip
plotshape(weakFlip and flipBull, "Weak Bull Flip", style=shape.triangleup,
     location=location.belowbar, color=color.new(bullColor, 60), size=size.tiny)
plotshape(weakFlip and flipBear, "Weak Bear Flip", style=shape.triangledown,
     location=location.abovebar, color=color.new(bearColor, 60), size=size.tiny)

// Flip QUALIFIED: label com Force
if qualifiedFlip and not premiumFlip and flipBull
    label.new(bar_index, low - atrVal * 0.8,
         text="▲ FLIP  " + str.tostring(flipScore),
         color=bullColor, textcolor=color.white,
         style=label.style_label_up, size=size.small)

if qualifiedFlip and not premiumFlip and flipBear
    label.new(bar_index, high + atrVal * 0.8,
         text="▼ FLIP  " + str.tostring(flipScore),
         color=bearColor, textcolor=color.white,
         style=label.style_label_down, size=size.small)

// Flip PREMIUM: label maior com estrela
if premiumFlip and flipBull
    label.new(bar_index, low - atrVal * 1.0,
         text="★ STRONG BULL ★\nForce " + str.tostring(flipScore),
         color=bullColor, textcolor=color.white,
         style=label.style_label_up, size=size.normal)

if premiumFlip and flipBear
    label.new(bar_index, high + atrVal * 1.0,
         text="★ STRONG BEAR ★\nForce " + str.tostring(flipScore),
         color=bearColor, textcolor=color.white,
         style=label.style_label_down, size=size.normal)

// ── VP Labels + Stairs (barstate.islast) ──
if barstate.islast
    if array.size(stairLn) > 0
        for i = 0 to array.size(stairLn) - 1
            line.delete(array.get(stairLn, i))
        array.clear(stairLn)
    if array.size(stairLbl) > 0
        for i = 0 to array.size(stairLbl) - 1
            label.delete(array.get(stairLbl, i))
        array.clear(stairLbl)
    line.delete(pocLine), line.delete(vahLine), line.delete(valLine)
    label.delete(pocLbl), label.delete(vahLbl), label.delete(valLbl)

    leftA  = bar_index - vpLookback
    rightA = bar_index + 5
    lblX   = rightA + 2

    pocLine := line.new(leftA, vp.poc, rightA, vp.poc,
         color=color.new(pocColor, 30), width=1, style=line.style_solid)
    vahLine := line.new(leftA, vp.vah, rightA, vp.vah,
         color=color.new(vaEdgeColor, 40), width=1, style=line.style_dotted)
    valLine := line.new(leftA, vp.val, rightA, vp.val,
         color=color.new(vaEdgeColor, 40), width=1, style=line.style_dotted)

    pocLbl := label.new(lblX, vp.poc, "POC " + str.tostring(vp.poc, format.mintick),
         color=color.new(color.black, 100), textcolor=pocColor,
         style=label.style_label_left, size=size.small)
    vahLbl := label.new(lblX, vp.vah, "VAH " + str.tostring(vp.vah, format.mintick),
         color=color.new(color.black, 100), textcolor=vaEdgeColor,
         style=label.style_label_left, size=size.small)
    valLbl := label.new(lblX, vp.val, "VAL " + str.tostring(vp.val, format.mintick),
         color=color.new(color.black, 100), textcolor=vaEdgeColor,
         style=label.style_label_left, size=size.small)

    if array.size(swingHighs) > 0
        for i = 0 to array.size(swingHighs) - 1
            p   = array.get(swingHighs, i)
            b1  = array.get(swingHighBar, i)
            b2  = i < array.size(swingHighs) - 1 ? array.get(swingHighBar, i + 1) : bar_index
            isHH = i > 0 and p > array.get(swingHighs, i - 1)
            isLH = i > 0 and p < array.get(swingHighs, i - 1)
            stepColor = isHH ? bullColor : isLH ? bearColor : color.gray
            drawStair(b1, b2, p, stepColor)
            if showStepTag
                tag = isHH ? "HH" : isLH ? "LH" : "H"
                lb = label.new(b1, p, tag, color=color.new(color.black, 100), textcolor=stepColor, style=label.style_label_down, size=size.tiny)
                array.push(stairLbl, lb)

    if array.size(swingLows) > 0
        for i = 0 to array.size(swingLows) - 1
            p   = array.get(swingLows, i)
            b1  = array.get(swingLowBar, i)
            b2  = i < array.size(swingLows) - 1 ? array.get(swingLowBar, i + 1) : bar_index
            isHL = i > 0 and p > array.get(swingLows, i - 1)
            isLL = i > 0 and p < array.get(swingLows, i - 1)
            stepColor = isHL ? bullColor : isLL ? bearColor : color.gray
            drawStair(b1, b2, p, stepColor)
            if showStepTag
                tag = isHL ? "HL" : isLL ? "LL" : "L"
                lb = label.new(b1, p, tag, color=color.new(color.black, 100), textcolor=stepColor, style=label.style_label_up, size=size.tiny)
                array.push(stairLbl, lb)

// ═════════════════════════════════════════════════════════════════════════════
// PANEL
// ═════════════════════════════════════════════════════════════════════════════
if showPanel and barstate.islast
    var table panel = table.new(position.top_right, 2, 6,
                               bgcolor=color.new(color.black, 70),
                               border_width=1, border_color=color.new(color.gray, 70))

    locTxt = close > vp.vah ? "ABOVE VA" : close < vp.val ? "BELOW VA" : "INSIDE VA"
    locCol = close > vp.vah ? bullColor : close < vp.val ? bearColor : vaEdgeColor
    trendTxt = trendBull ? "BULL ▲" : trendBear ? "BEAR ▼" : "—"
    trendCol = trendBull ? bullColor : trendBear ? bearColor : color.gray
    hiloTxt = hiloDir == 1 ? "BULL ▲" : hiloDir == -1 ? "BEAR ▼" : "—"
    hiloColTxt = hiloDir == 1 ? bullColor : hiloDir == -1 ? bearColor : color.gray

    table.cell(panel, 0, 0, "POC",      text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 0, str.tostring(vp.poc, format.mintick), text_color=pocColor, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 1, "VAH",      text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 1, str.tostring(vp.vah, format.mintick), text_color=vaEdgeColor, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 2, "VAL",      text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 2, str.tostring(vp.val, format.mintick), text_color=vaEdgeColor, text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 3, "Price",    text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 3, locTxt,     text_color=locCol,       text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 4, "Stairs",   text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 4, trendTxt,   text_color=trendCol,     text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 0, 5, "HiLo",     text_color=color.white,  text_size=size.small, bgcolor=color.new(color.black, 50))
    table.cell(panel, 1, 5, hiloTxt,    text_color=hiloColTxt,   text_size=size.small, bgcolor=color.new(color.black, 50))

alertcondition(qualifiedFlip and flipBull, "Qualified Bull Flip", "Smart HiLo: Qualified bullish flip")
alertcondition(qualifiedFlip and flipBear, "Qualified Bear Flip", "Smart HiLo: Qualified bearish flip")
alertcondition(premiumFlip and flipBull, "Premium Bull Flip",     "Smart HiLo: PREMIUM bullish flip")
alertcondition(premiumFlip and flipBear, "Premium Bear Flip",     "Smart HiLo: PREMIUM bearish flip")
````
