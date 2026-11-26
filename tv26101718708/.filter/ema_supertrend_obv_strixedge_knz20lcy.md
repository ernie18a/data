# EMA + Supertrend + OBV [StrixEDGE]

- url: https://www.tradingview.com/script/KNZ20lcY-EMA-Supertrend-OBV-StrixEDGE/
- type: indicator
- pine_id: PUB;f3b59c66ac824abea8232b122d06ee98
- version: 1.0

## Description

Trend Engine EMA + Supertrend + OBV [StrixEDGE] is a multi-timeframe trend scoring system that combines EMA structure, Supertrend direction, and OBV volume flow into a single overlay with a detailed heatmap dashboard. It evaluates four timeframes simultaneously and presents the results in a color-coded, section-organized table directly on the chart.

The indicator answers three questions per timeframe: Is the structure bullish or bearish? Is the directional signal confirmed? Is volume supporting the move? It then aggregates these into a confluence score and cross-timeframe alignment reading.

Components

EMA Stack (21 / 50 / 200)

Three exponential moving averages forming a structural hierarchy. The scoring logic evaluates both the EMA order and price position:

| Condition | Score | Label |
|---|---|---|
| 21 > 50 > 200, price above all | +2 | FULL BULL ▲▲ |
| 21 > 50 > 200 | +1 | BULLISH ▲ |
| Price above 200 but EMAs not ordered | +1 | BULLISH ▲ |
| No clear alignment | 0 | MIXED ◆ |
| Price below 200 but EMAs not ordered | −1 | BEARISH ▼ |
| 21 < 50 < 200 | −1 | BEARISH ▼ |
| 21 < 50 < 200, price below all | −2 | FULL BEAR ▼▼ |

The 200 EMA is separately tracked as "Price/200" in the heatmap, since institutional participants widely use this level as the dividing line between bull and bear regimes.

On the chart, all three EMAs turn green when bull-stacked and red when bear-stacked. A ribbon fill between the fast and mid EMA visualizes alignment strength. Golden Cross (50 above 200) and Death Cross events are marked with "GC" and "DC" labels.

Supertrend (10, 3)

An ATR-based trailing stop that produces a binary directional signal. When the Supertrend line is below price, it scores +1 (BULLISH). When above, it scores −1 (BEARISH). The line also serves as a dynamic stop-loss level. Triangle markers appear at each flip point.

OBV with 20-period SMA

On Balance Volume is calculated cumulatively — adding volume on up-closes, subtracting on down-closes. The heatmap evaluates two dimensions independently: OBV position relative to its SMA (above or below) and the SMA slope direction (rising, falling, or flat). This produces six distinct flow states:

| OBV vs MA | Slope | Label | Meaning |
|---|---|---|---|
| Above | Rising | ACCUM ▲ | Active accumulation — institutional buying |
| Above | Flat | ABOVE MA | Holding above average — neutral positive |
| Above | Falling | WEAKENING | Position eroding despite being above MA |
| Below | Rising | BUILDING | Recovery underway — improving flow |
| Below | Flat | BELOW MA | Holding below average — neutral negative |
| Below | Falling | DISTRIB ▼ | Active distribution — institutional selling |

OBV scores +1 when above MA and rising, −1 when below MA and falling, and 0 for all intermediate states.

The MTF Heatmap

The heatmap table is organized into four color-coded sections:

STRUCTURE (blue header) — EMA Stack alignment and Price vs EMA 200 for each timeframe. Shows whether the market's structural foundation is bullish, bearish, or mixed.

DIRECTION (purple header) — Supertrend signal per timeframe. A clean binary reading of whether the trailing stop is bullish or bearish.

VOLUME FLOW (teal header) — OBV flow state per timeframe. Shows whether volume is confirming the price trend, diverging from it, or transitioning.

CONFLUENCE (gold header) — The aggregated output:
- Score: total from −4 to +4 per timeframe
- Strength: visual dot bar (● ● ● ● ○) representing signal intensity
- Regime: classification label (STRONG BULL https://www.tradingview.com/x/Ao1eRZny/, BULLISH https://www.tradingview.com/x/g78Y18UA/, NEUTRAL https://www.tradingview.com/x/HAeNssBe/, BEARISH https://www.tradingview.com/x/9kDZBDgw/, STRONG BEAR https://www.tradingview.com/x/lzMAg43O/)

At the bottom, an MTF Alignment summary shows how many timeframes agree (e.g., "▲ 3/4 BULLISH — Strong alignment https://www.tradingview.com/x/Ku9zQY6V/" or "◆ SPLIT 2/2 — No clear bias https://www.tradingview.com/x/AT3Ed4LH/").

Every cell uses heatmap coloring — bright green for strong bullish, through gray for neutral, to deep red for strong bearish — providing an instant visual scan of market conditions.

| Component | Max bullish | Neutral | Max bearish |
|---|---|---|---|
| EMA Stack | +2 | 0 | −2 |
| Supertrend | +1 | — | −1 |
| OBV Flow | +1 | 0 | −1 |
| **Total** | +4 | 0 | −4 |

Classification per timeframe:
- +3 to +4 → STRONG BULL
- +1 to +2 → BULLISH
- 0 → NEUTRAL
- −1 to −2 → BEARISH
- −3 to −4 → STRONG BEAR

Reading the heatmap

The heatmap's primary value is showing cross-timeframe agreement at a glance:

All columns green — Full alignment across timeframes. This is the highest-probability environment for trend-following trades.

Higher TFs green, lower TFs red — A pullback within a larger uptrend. The structural trend is intact; the short-term weakness may represent an entry opportunity.

Lower TFs green, higher TFs red — A rally within a larger downtrend. Unless the higher timeframes are shifting, this is likely a counter-trend bounce.

Mixed colors — No clear directional edge. Reduce position size or wait for alignment to develop.

Section-level reading — If STRUCTURE and DIRECTION are green but VOLUME FLOW is red, the trend lacks volume confirmation and may be fragile. If VOLUME shows ACCUM but DIRECTION is bearish, smart money may be accumulating before a reversal.

Alerts

Seven alert conditions are available:

- Strong bullish trend detected (current TF)
- Strong bearish trend detected (current TF)
- Golden Cross — EMA 50 crosses above EMA 200
- Death Cross — EMA 50 crosses below EMA 200
- Supertrend flip bullish
- Supertrend flip bearish
- Any trend classification change

Disclaimer: This indicator is a technical analysis tool for educational and informational purposes. It does not constitute financial advice or a recommendation to buy or sell any security. No trading indicator can predict future price movements. Past performance is not indicative of future results. Always conduct your own analysis and consider your risk tolerance before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("EMA + Supertrend + OBV [StrixEDGE]", shorttitle="EMA + Supertrend + OBV [StrixEDGE]", overlay=true, max_labels_count=50)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

i_emaFast   = input.int(21, "Fast EMA", minval=1, group="⚙ EMA Stack")
i_emaMid    = input.int(50, "Mid EMA", minval=1, group="⚙ EMA Stack")
i_emaSlow   = input.int(200, "Slow EMA", minval=1, group="⚙ EMA Stack")
i_emaFill   = input.bool(true, "Show ribbon fill", group="⚙ EMA Stack")

i_stFactor  = input.float(3.0, "Factor", minval=0.5, step=0.1, group="⚙ Supertrend")
i_stAtr     = input.int(10, "ATR Period", minval=1, group="⚙ Supertrend")
i_stShow    = input.bool(true, "Show Supertrend line", group="⚙ Supertrend")

i_obvMaLen  = input.int(20, "OBV MA Length", minval=2, group="⚙ OBV")
i_obvLook   = input.int(5, "Slope lookback", minval=1, group="⚙ OBV")

i_tf1       = input.timeframe("15", "Timeframe 1", group="📊 MTF Heatmap")
i_tf2       = input.timeframe("60", "Timeframe 2", group="📊 MTF Heatmap")
i_tf3       = input.timeframe("240", "Timeframe 3", group="📊 MTF Heatmap")
i_tf4       = input.timeframe("1D", "Timeframe 4", group="📊 MTF Heatmap")
i_showHM    = input.bool(true, "Show heatmap", group="📊 MTF Heatmap")
i_hmPos     = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group="📊 MTF Heatmap")
i_hmSize    = input.string("Normal", "Text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="📊 MTF Heatmap")

i_showCross = input.bool(true, "Show GC / DC labels", group="📊 Chart")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS (evaluated per-TF via request.security)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// --- EMA ---
emaF = ta.ema(close, i_emaFast)
emaM = ta.ema(close, i_emaMid)
emaS = ta.ema(close, i_emaSlow)

bullStack = emaF > emaM and emaM > emaS
bearStack = emaF < emaM and emaM < emaS
pAboveAll = close > emaF and close > emaM and close > emaS
pBelowAll = close < emaF and close < emaM and close < emaS

goldenCross = ta.crossover(emaM, emaS)
deathCross  = ta.crossunder(emaM, emaS)

emaScore   = bullStack and pAboveAll ? 2 : bullStack ? 1 : bearStack and pBelowAll ? -2 : bearStack ? -1 : close > emaS ? 1 : close < emaS ? -1 : 0
pVs200     = close > emaS ? 1 : -1

// --- Supertrend ---
[stValue, stDir] = ta.supertrend(i_stFactor, i_stAtr)
stBull     = stDir == -1
stFlipBull = stBull and not stBull[1]
stFlipBear = not stBull and stBull[1]
stScore    = stBull ? 1 : -1

// --- OBV (ta.cum — MTF safe) ---
obvRaw     = ta.cum(ta.change(close) > 0 ? volume : ta.change(close) < 0 ? -volume : 0.0)
obvMa      = ta.sma(obvRaw, i_obvMaLen)
obvAbv     = obvRaw > obvMa
obvSlope   = ta.change(obvMa, i_obvLook)
obvRise    = obvSlope > 0
obvFall    = obvSlope < 0
obvScore   = obvAbv and obvRise ? 1 : not obvAbv and obvFall ? -1 : 0

// Extra data for detailed table
obvAbvInt  = obvAbv ? 1 : 0
obvSlopeN  = obvRise ? 1 : obvFall ? -1 : 0

// --- Totals ---
totalScore = emaScore + stScore + obvScore

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF DATA (6 values per timeframe)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[e1, s1, o1, p1, oa1, os1] = request.security(syminfo.tickerid, i_tf1, [emaScore, stScore, obvScore, pVs200, obvAbvInt, obvSlopeN], barmerge.gaps_off, barmerge.lookahead_off)
[e2, s2, o2, p2, oa2, os2] = request.security(syminfo.tickerid, i_tf2, [emaScore, stScore, obvScore, pVs200, obvAbvInt, obvSlopeN], barmerge.gaps_off, barmerge.lookahead_off)
[e3, s3, o3, p3, oa3, os3] = request.security(syminfo.tickerid, i_tf3, [emaScore, stScore, obvScore, pVs200, obvAbvInt, obvSlopeN], barmerge.gaps_off, barmerge.lookahead_off)
[e4, s4, o4, p4, oa4, os4] = request.security(syminfo.tickerid, i_tf4, [emaScore, stScore, obvScore, pVs200, obvAbvInt, obvSlopeN], barmerge.gaps_off, barmerge.lookahead_off)

t1 = math.round(e1 + s1 + o1)
t2 = math.round(e2 + s2 + o2)
t3 = math.round(e3 + s3 + o3)
t4 = math.round(e4 + s4 + o4)

// Alignment
bullTFs = (t1 > 0 ? 1 : 0) + (t2 > 0 ? 1 : 0) + (t3 > 0 ? 1 : 0) + (t4 > 0 ? 1 : 0)
bearTFs = (t1 < 0 ? 1 : 0) + (t2 < 0 ? 1 : 0) + (t3 < 0 ? 1 : 0) + (t4 < 0 ? 1 : 0)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REGIME
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isStrongBull = totalScore >= 3
isBull       = totalScore >= 1 and totalScore < 3
isNeutral    = totalScore == 0
isBear       = totalScore <= -1 and totalScore > -3
isStrongBear = totalScore <= -3

var int prevC = 0
currC        = isStrongBull ? 4 : isBull ? 3 : isNeutral ? 2 : isBear ? 1 : 0
trendChanged = currC != prevC
prevC       := currC

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER FUNCTIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Heatmap palette
cBS = #00E676    // strong bull
cBM = #4CAF50    // bull
cBW = #81C784    // weak bull
cN  = #546E7A    // neutral
cRW = #E57373    // weak bear
cRM = #F44336    // bear
cRS = #FF1744    // strong bear

hmCol(int score, int mx) =>
    r = mx != 0 ? score / mx : 0.0
    r >= 0.8 ? cBS : r >= 0.4 ? cBM : r > 0 ? cBW : r == 0 ? cN : r > -0.4 ? cRW : r > -0.8 ? cRM : cRS

// EMA stack label
emaLbl(int sc) =>
    sc == 2 ? "FULL BULL ▲▲" : sc == 1 ? "BULLISH ▲" : sc == -1 ? "BEARISH ▼" : sc == -2 ? "FULL BEAR ▼▼" : "MIXED ◆"

// Supertrend label
stLbl(int sc) =>
    sc == 1 ? "BULLISH ▲" : "BEARISH ▼"

// Price vs 200 label
p200Lbl(int sc) =>
    sc == 1 ? "ABOVE ▲" : "BELOW ▼"

// OBV flow label
obvFlowLbl(int abv, int slope) =>
    abv == 1 and slope == 1  ? "ACCUM ▲" :
     abv == 0 and slope == -1 ? "DISTRIB ▼" :
     abv == 1 and slope == 0  ? "ABOVE MA" :
     abv == 0 and slope == 0  ? "BELOW MA" :
     abv == 1 and slope == -1 ? "WEAKENING" :
     abv == 0 and slope == 1  ? "BUILDING" :
     "NEUTRAL"

obvFlowCol(int abv, int slope) =>
    abv == 1 and slope == 1  ? cBS :
     abv == 0 and slope == -1 ? cRS :
     abv == 1                 ? cBW :
     abv == 0 and slope == 1  ? cBW :
     abv == 0                 ? cRW :
     cN

// Regime label
regLbl(int sc) =>
    sc >= 3 ? "STRONG BULL" : sc >= 1 ? "BULLISH" : sc == 0 ? "NEUTRAL" : sc >= -2 ? "BEARISH" : "STRONG BEAR"

// Strength bar (5 dots)
strBar(int sc) =>
    a = math.abs(sc)
    a >= 4 ? "● ● ● ● ●" : a >= 3 ? "● ● ● ● ○" : a >= 2 ? "● ● ● ○ ○" : a >= 1 ? "● ● ○ ○ ○" : "○ ○ ○ ○ ○"

// Score text with sign
scoreTxt(int sc) =>
    (sc > 0 ? "+" : "") + str.tostring(sc)

// TF display name
tfN(simple string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "1D"  => "Daily"
        "1W"  => "Weekly"
        "1M"  => "Monthly"
        => tf

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHART OVERLAY
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cEF = #42A5F5
cEM = #FFA726
cES = #EF5350

eFCol = bullStack ? cBS : bearStack ? cRS : cEF
eMCol = bullStack ? cBS : bearStack ? cRS : cEM
eSCol = bullStack ? color.new(cBS, 40) : bearStack ? color.new(cRS, 40) : color.new(cES, 40)

pF = plot(emaF, "EMA Fast", color=eFCol, linewidth=2)
pM = plot(emaM, "EMA Mid", color=eMCol, linewidth=2)
pS = plot(emaS, "EMA Slow", color=eSCol, linewidth=3)

ribC = bullStack ? color.new(cBS, 85) : bearStack ? color.new(cRS, 85) : color.new(cN, 93)
fill(pF, pM, color=i_emaFill ? ribC : na, title="EMA Ribbon")

stC = stBull ? cBS : cRS
plot(i_stShow ? stValue : na, "Supertrend", color=stC, linewidth=2, style=plot.style_linebr)
plotshape(i_stShow and stFlipBull, "ST↑", shape.triangleup, location.belowbar, cBS, size=size.tiny)
plotshape(i_stShow and stFlipBear, "ST↓", shape.triangledown, location.abovebar, cRS, size=size.tiny)

if i_showCross and goldenCross
    label.new(bar_index, emaS, "GC", color=color.new(cBS, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
if i_showCross and deathCross
    label.new(bar_index, emaS, "DC", color=color.new(cRS, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF HEATMAP TABLE — Professional Layout
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tPos = switch i_hmPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left"  => position.middle_left
    => position.top_right

tSz = switch i_hmSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

hSz = switch i_hmSize
    "Tiny"   => size.tiny
    "Small"  => size.tiny
    "Normal" => size.small
    "Large"  => size.normal
    "Huge"   => size.large
    => size.small

// Table colors
cDark  = color.new(#0d1117, 0)
cRow1  = color.new(#161b22, 0)
cRow2  = color.new(#0d1117, 0)
cBrd   = color.new(#21262d, 0)
cHead  = color.new(#1c2128, 0)
cDim   = color.new(#6e7681, 0)
cWht   = color.new(#e6edf3, 0)
cWhtD  = color.new(#8b949e, 0)

// Section header colors
cSecBlue   = color.new(#1f3a5f, 0)
cSecPurple = color.new(#3b1f5f, 0)
cSecTeal   = color.new(#1a3f3f, 0)
cSecGold   = color.new(#3f351a, 0)

if i_showHM and barstate.islast
    var tbl = table.new(tPos, 5, 15, bgcolor=cDark, border_width=1, border_color=cBrd, frame_width=2, frame_color=color.new(#30363d, 0))

    // ── ROW 0 — Title ──
    table.cell(tbl, 0, 0, "  T R E N D   E N G I N E StrixEDGE  ", text_color=cWht, text_size=hSz, bgcolor=color.new(#010409, 0), text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 4, 0)

    // ── ROW 1 — TF Headers ──
    table.cell(tbl, 0, 1, "",           text_color=cDim, text_size=hSz, bgcolor=cHead, text_halign=text.align_center)
    table.cell(tbl, 1, 1, tfN(i_tf1),   text_color=cWht, text_size=hSz, bgcolor=cHead, text_halign=text.align_center)
    table.cell(tbl, 2, 1, tfN(i_tf2),   text_color=cWht, text_size=hSz, bgcolor=cHead, text_halign=text.align_center)
    table.cell(tbl, 3, 1, tfN(i_tf3),   text_color=cWht, text_size=hSz, bgcolor=cHead, text_halign=text.align_center)
    table.cell(tbl, 4, 1, tfN(i_tf4),   text_color=cWht, text_size=hSz, bgcolor=cHead, text_halign=text.align_center)

    // ── ROW 2 — Section: STRUCTURE ──
    table.cell(tbl, 0, 2, "  S T R U C T U R E  ", text_color=color.new(cEF, 0), text_size=size.tiny, bgcolor=cSecBlue, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 2, 4, 2)

    // ── ROW 3 — EMA Stack ──
    table.cell(tbl, 0, 3, " EMA Stack ", text_color=cEF, text_size=tSz, bgcolor=cRow1, text_halign=text.align_left)
    table.cell(tbl, 1, 3, emaLbl(int(e1)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(e1), 2), 25), text_halign=text.align_center)
    table.cell(tbl, 2, 3, emaLbl(int(e2)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(e2), 2), 25), text_halign=text.align_center)
    table.cell(tbl, 3, 3, emaLbl(int(e3)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(e3), 2), 25), text_halign=text.align_center)
    table.cell(tbl, 4, 3, emaLbl(int(e4)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(e4), 2), 25), text_halign=text.align_center)

    // ── ROW 4 — Price vs EMA 200 ──
    table.cell(tbl, 0, 4, " Price/200 ", text_color=cWhtD, text_size=tSz, bgcolor=cRow2, text_halign=text.align_left)
    table.cell(tbl, 1, 4, p200Lbl(int(p1)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(p1), 1), 35), text_halign=text.align_center)
    table.cell(tbl, 2, 4, p200Lbl(int(p2)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(p2), 1), 35), text_halign=text.align_center)
    table.cell(tbl, 3, 4, p200Lbl(int(p3)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(p3), 1), 35), text_halign=text.align_center)
    table.cell(tbl, 4, 4, p200Lbl(int(p4)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(p4), 1), 35), text_halign=text.align_center)

    // ── ROW 5 — Section: DIRECTION ──
    table.cell(tbl, 0, 5, "  D I R E C T I O N  ", text_color=color.new(#AB47BC, 0), text_size=size.tiny, bgcolor=cSecPurple, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 5, 4, 5)

    // ── ROW 6 — Supertrend ──
    table.cell(tbl, 0, 6, " SuperTrend ", text_color=#AB47BC, text_size=tSz, bgcolor=cRow1, text_halign=text.align_left)
    table.cell(tbl, 1, 6, stLbl(int(s1)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(s1), 1), 25), text_halign=text.align_center)
    table.cell(tbl, 2, 6, stLbl(int(s2)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(s2), 1), 25), text_halign=text.align_center)
    table.cell(tbl, 3, 6, stLbl(int(s3)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(s3), 1), 25), text_halign=text.align_center)
    table.cell(tbl, 4, 6, stLbl(int(s4)), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(int(s4), 1), 25), text_halign=text.align_center)

    // ── ROW 7 — Section: VOLUME ──
    table.cell(tbl, 0, 7, "  V O L U M E   F L O W  ", text_color=color.new(#26A69A, 0), text_size=size.tiny, bgcolor=cSecTeal, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 7, 4, 7)

    // ── ROW 8 — OBV Flow ──
    table.cell(tbl, 0, 8, " OBV Flow ", text_color=#26A69A, text_size=tSz, bgcolor=cRow1, text_halign=text.align_left)
    table.cell(tbl, 1, 8, obvFlowLbl(int(oa1), int(os1)), text_color=cWht, text_size=tSz, bgcolor=color.new(obvFlowCol(int(oa1), int(os1)), 25), text_halign=text.align_center)
    table.cell(tbl, 2, 8, obvFlowLbl(int(oa2), int(os2)), text_color=cWht, text_size=tSz, bgcolor=color.new(obvFlowCol(int(oa2), int(os2)), 25), text_halign=text.align_center)
    table.cell(tbl, 3, 8, obvFlowLbl(int(oa3), int(os3)), text_color=cWht, text_size=tSz, bgcolor=color.new(obvFlowCol(int(oa3), int(os3)), 25), text_halign=text.align_center)
    table.cell(tbl, 4, 8, obvFlowLbl(int(oa4), int(os4)), text_color=cWht, text_size=tSz, bgcolor=color.new(obvFlowCol(int(oa4), int(os4)), 25), text_halign=text.align_center)

    // ── ROW 9 — Section: CONFLUENCE ──
    table.cell(tbl, 0, 9, "  C O N F L U E N C E  ", text_color=color.new(#FFB74D, 0), text_size=size.tiny, bgcolor=cSecGold, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 9, 4, 9)

    // ── ROW 10 — Score ──
    table.cell(tbl, 0, 10, " Score ", text_color=cWht, text_size=tSz, bgcolor=cRow1, text_halign=text.align_left)
    table.cell(tbl, 1, 10, scoreTxt(t1), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t1, 4), 15), text_halign=text.align_center)
    table.cell(tbl, 2, 10, scoreTxt(t2), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t2, 4), 15), text_halign=text.align_center)
    table.cell(tbl, 3, 10, scoreTxt(t3), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t3, 4), 15), text_halign=text.align_center)
    table.cell(tbl, 4, 10, scoreTxt(t4), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t4, 4), 15), text_halign=text.align_center)

    // ── ROW 11 — Strength Bar ──
    table.cell(tbl, 0, 11, " Strength ", text_color=cWhtD, text_size=tSz, bgcolor=cRow2, text_halign=text.align_left)
    table.cell(tbl, 1, 11, strBar(t1), text_color=hmCol(t1, 4), text_size=tSz, bgcolor=cRow2, text_halign=text.align_center)
    table.cell(tbl, 2, 11, strBar(t2), text_color=hmCol(t2, 4), text_size=tSz, bgcolor=cRow2, text_halign=text.align_center)
    table.cell(tbl, 3, 11, strBar(t3), text_color=hmCol(t3, 4), text_size=tSz, bgcolor=cRow2, text_halign=text.align_center)
    table.cell(tbl, 4, 11, strBar(t4), text_color=hmCol(t4, 4), text_size=tSz, bgcolor=cRow2, text_halign=text.align_center)

    // ── ROW 12 — Regime ──
    table.cell(tbl, 0, 12, " Regime ", text_color=cWht, text_size=tSz, bgcolor=cRow1, text_halign=text.align_left)
    table.cell(tbl, 1, 12, regLbl(t1), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t1, 4), 10), text_halign=text.align_center)
    table.cell(tbl, 2, 12, regLbl(t2), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t2, 4), 10), text_halign=text.align_center)
    table.cell(tbl, 3, 12, regLbl(t3), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t3, 4), 10), text_halign=text.align_center)
    table.cell(tbl, 4, 12, regLbl(t4), text_color=cWht, text_size=tSz, bgcolor=color.new(hmCol(t4, 4), 10), text_halign=text.align_center)

    // ── ROW 13 — Divider ──
    for col = 0 to 4
        table.cell(tbl, col, 13, "", bgcolor=color.new(#30363d, 0), text_size=size.tiny)

    // ── ROW 14 — MTF Alignment Summary ──
    alignText = bullTFs == 4 ? "◆ 4/4 BULLISH — Full alignment" :
     bullTFs == 3 ? "▲ 3/4 BULLISH — Strong alignment" :
     bearTFs == 4 ? "◆ 4/4 BEARISH — Full alignment" :
     bearTFs == 3 ? "▼ 3/4 BEARISH — Strong alignment" :
     bullTFs == 2 and bearTFs == 2 ? "◆ SPLIT 2/2 — No clear bias" :
     bullTFs > bearTFs ? "▲ " + str.tostring(bullTFs) + "/4 Bullish — Partial" :
     bearTFs > bullTFs ? "▼ " + str.tostring(bearTFs) + "/4 Bearish — Partial" :
     "◆ MIXED — Wait for clarity"

    alignCol = bullTFs >= 3 ? cBS : bearTFs >= 3 ? cRS : cN
    table.cell(tbl, 0, 14, alignText, text_color=alignCol, text_size=hSz, bgcolor=color.new(#010409, 0), text_halign=text.align_center)
    table.merge_cells(tbl, 0, 14, 4, 14)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(trendChanged and isStrongBull, "Strong bullish", "Trend Engine: STRONG BULLISH — All components aligned.")
alertcondition(trendChanged and isStrongBear, "Strong bearish", "Trend Engine: STRONG BEARISH — All components aligned.")
alertcondition(goldenCross, "Golden cross", "Trend Engine: GOLDEN CROSS detected.")
alertcondition(deathCross, "Death cross", "Trend Engine: DEATH CROSS detected.")
alertcondition(stFlipBull, "ST flip bull", "Trend Engine: Supertrend flipped BULLISH.")
alertcondition(stFlipBear, "ST flip bear", "Trend Engine: Supertrend flipped BEARISH.")
alertcondition(trendChanged, "Trend change", "Trend Engine: Classification changed — check heatmap.")
````
