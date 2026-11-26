# Confluence Reaction Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/qbGaI25B-Confluence-Reaction-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;c60364f2dbe848059641cc69329fca27
- version: 1.0

## Description

Confluence Reaction Zones reads seven classic indicators as a single contrarian composite, then commits a shaded support/resistance zone only where structure and sentiment agree at an extreme. Instead of drawing yet another line at every swing, it waits for a confirmed pivot, samples the composite at that pivot, and color-classifies the level by what the composite was doing when the level formed — deep-oversold support becomes a BUY-DIP zone, overbought resistance becomes a SELL-RIP zone, and everything in between is flagged MIXED. Every zone is ranked 0–10 with a star score, re-scored on each retest, and neutralized the moment price closes through it — and a live diagnostics panel shows the full seven-signal breakdown driving the read, so you can see exactly why a zone is the color it is on the pair and timeframe you trade.

🧠 Composite Core — the central idea. Seven engines — RSI, the EMA stack (9/21/50/100/200/250), MACD, ADX/DI, Ichimoku, Bollinger Bands, and OBV — are each graded onto a 1–5 tube level, where 5 is an oversold / exhausted extreme (a contrarian BUY read), 1 is an overbought extreme (a contrarian SELL read), and 3 is neutral. The seven levels are averaged into a single 0–100 Composite: high means the market is stretched to the downside and coiled to bounce; low means it is stretched to the upside and vulnerable to fade. This is a genuine fade-the-extreme model — it leans against the crowd at the point of exhaustion, not with it.

📈 Contrarian Zone Classification — where the composite meets structure. A zone is born on a confirmed swing pivot, and its class is set by the Composite sampled at that pivot bar. A support pivot that forms while the Composite is oversold becomes a high-conviction BUY-DIP zone; a resistance pivot that forms while the Composite is overbought becomes a high-conviction SELL-RIP zone; a pivot whose structure and Composite disagree is drawn as a dimmed MIXED zone. Because pivots are confirmed and the Composite is read at the settled pivot bar, the classification is fixed once the bar closes — the zones do not repaint.

🎯 Shaded Reaction Bands + Structural Behavior. Each zone is a multi-layer, double-shaded band sized in ATR, with a center line, an inside-edge label, and a live touch counter. Bands extend forward as price develops, tally each clean retest, and re-score on every test. The instant price closes beyond the zone by an adjustable invalidation offset, the level is neutralized — recolored to a muted tone (or dropped entirely) — so a broken level reads as spent context, never as a live signal. Opacity is graded by strength, so the strongest zones sit boldest on the chart.

⭐ 0–10 Zone-Quality Score. Every zone is scored and starred across contrarian-native factors: how far the Composite was from neutral at birth (extremity / conviction), relative volume at the pivot, rejection-wick fraction at the pivot, and buy/sell pressure alignment with the zone's direction — with additional credit accruing for each confirmed retest, capped at 10. Read the score as a confluence / cleanliness rank for thinning and prioritizing zones: it describes how textbook a reaction level is, not a guaranteed outcome.

🧭 Buy/Sell Pressure Split. A rolling intrabar volume split estimates the balance of buying versus selling over a configurable window. It feeds the zone score and prints live on the dashboard as a ▲ buy / ▼ sell percentage, so the participation behind a level is visible at a glance and factored into how the level is graded.

🎚️ Declutter & Conviction Controls. A tight set of dials governs how busy and how selective the chart is: Oversold / Overbought thresholds define what counts as an extreme; a Dedupe Separation (×ATR) filter stops new pivots from stacking bands and labels on top of existing same-side zones; Max Zones caps the live set; Keep-last-N-broken caps neutralized history so gray levels never accumulate into clutter; a Show MIXED toggle hides conflicted zones for a directional-only view; and the invalidation offset sets how decisively price must close through a level to kill it. Tighten for a clean, high-conviction chart; loosen for full structural context.

📊 Live Diagnostics Dashboard. A compact institutional panel tracks, in real time on your chart: the Composite score with a fill bar; the Verdict — BUY DIPS / SELL RIPS / NEUTRAL; the buy/sell pressure split; a full signal diagnostics table showing each of the seven engines at its current tier (L1 ⇊ OVERBOUGHT → L5 ⇈ OVERSOLD), color-keyed so you see instantly which inputs are driving the composite; the active BUY-DIP and SELL-RIP zone counts; and the nearest active zone with its class, star score, and distance in ATR. It is a live read of the engine's current state on your symbol — not a printed statistic.

🎨 Clean Themed Visuals. A dark institutional palette in three schemes — Classic (teal / red / amber), Ice (cyan / pink), and Emerald (green / red / gold) — colors the zone bands, center lines, labels, dashboard, and optional candle tint into one coherent look, so class and conviction read at a glance. Candles inside a live zone are tinted to its color, and small OS / OB dots mark the exact bars where the Composite flips into an oversold or overbought extreme — the moment a fresh contrarian setup arms.

🔔 Alerts. Fires on Composite oversold / overbought flips, on BUY-DIP and SELL-RIP zone retests, and on zone invalidations — formatted for manual or automated use — so you can be pinged when sentiment reaches an extreme or when price returns to a graded level rather than watching the chart.

🔧 Fully Customizable. Every component is exposed: the seven signal parameters (RSI length/source, EMA stack, MACD lengths and MA types, ADX/DI length and tolerance, Ichimoku periods, Bollinger length/MA/source, and the full OBV rise/fall/spike model); the oversold/overbought composite thresholds and pressure lookback; pivot strength, ATR length, zone height, dedupe separation, max zones, invalidation offset, MIXED visibility, broken-zone tone and history cap; gradient fill, candle tint, extreme dots; dashboard position and size; and all three themes.

🎯 Why this is different. Most support/resistance tools draw lines at pivots and leave interpretation to you — every level looks the same whether the market was exhausted or trending into it. This engine reads seven indicators as one contrarian composite, only commits a zone where a confirmed pivot lines up with a sentiment extreme, color-codes the level by that agreement, ranks it 0–10, re-scores it on every retest, and neutralizes it the instant it fails — then surfaces the entire seven-signal rationale on a live panel. You are looking at classified, ranked, self-invalidating levels with the reasoning attached, not an undifferentiated ladder of lines.

🚀 Where to use it. Symbol- and timeframe-agnostic — it runs on forex, indices, metals, crypto, and equities across intraday and higher timeframes. Because the score and pressure split use volume (OBV, relative volume, buy/sell balance), it is sharpest on instruments where volume is meaningful and degrades gracefully where it is only tick volume. Larger Pivot Strength yields fewer, more significant zones on higher timeframes; smaller values give a more reactive intraday map.

🎯 How to trade it
Apply it to a liquid instrument and let the zones and dashboard populate. Read the Composite and Verdict for the prevailing contrarian bias, and use the signal-diagnostics table to see which of the seven engines are actually stretched.

Favor BUY-DIP zones for longs and SELL-RIP zones for shorts, prioritizing higher star scores and, ideally, a Composite already leaning the same way — a fresh OS / OB dot near a matching graded zone is the intended confluence.

Treat each zone as a decision level: plan entries on a controlled retest into the band, define invalidation by a decisive close through it (the same event that neutralizes the zone on the chart), and manage targets against the next opposing zone or your own R model.
Use Dedupe Separation, Max Zones, Show MIXED, and Keep-last-N-broken to set chart density — stricter for a clean, high-conviction map; looser for full structure — and use the star score to focus on the cleanest reaction levels.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. The 0–10 score is a confluence / cleanliness rank that describes how textbook a reaction level is; it is not a probability or a promise of outcome, and the dashboard is a live read of the engine's current state, not a backtest or forecast. Zones and their classification confirm on the closed pivot bar, so pivots print with the built-in confirmation lag and you should always wait for a settled level. Contrarian logic fades extremes and will be wrong in strong trends — always pair it with higher-timeframe context, your own analysis, and disciplined risk management, and test it on your market and timeframe before trading it live.

## Source Code

````pine
//@version=6
indicator('Confluence Reaction Zones', overlay = true, max_boxes_count = 500, max_lines_count = 300, max_labels_count = 500, max_bars_back = 1000)

string G_THEME = 'Theme'
string themeInput = input.string('Classic', 'Color Theme', options = ['Classic', 'Ice', 'Emerald'], group = G_THEME, tooltip = 'Swaps the buy-dip / sell-rip / mixed accent colors. Logic is unchanged.')

color C_BUY  = themeInput == 'Ice' ? #00E5FF : themeInput == 'Emerald' ? #22E06A : #00E5C3
color C_SELL = themeInput == 'Ice' ? #FF4D6D : themeInput == 'Emerald' ? #FF3131 : #FF3B4E
color C_MIX  = themeInput == 'Ice' ? #9AA6C8 : themeInput == 'Emerald' ? #E8B23C : #FFB020

color PANEL_BG = #0A0E17
color STEEL    = #2A3550
color GHOST    = #7C8BB0
color WHITE_TX = #DCE6FF
color GOLD_TX  = #FFD23C

string G_CONTRA = 'Contrarian Composite'
int   buyThreshInput  = input.int(60, 'Oversold → BUY-DIP threshold', minval = 51, maxval = 90, group = G_CONTRA, tooltip = 'Composite ≥ this (across the 7 signals) = deep-oversold. A support pivot born here becomes a high-conviction BUY-DIP zone.')
int   sellThreshInput = input.int(40, 'Overbought → SELL-RIP threshold', minval = 10, maxval = 49, group = G_CONTRA, tooltip = 'Composite ≤ this = overbought. A resistance pivot born here becomes a high-conviction SELL-RIP zone.')
int   pressLenInput   = input.int(20, 'Buy/Sell Pressure Lookback', minval = 2, maxval = 200, group = G_CONTRA, tooltip = 'Rolling window for the intrabar buy/sell volume split.')

string G_ZONE = 'Reaction Zones'
int   pivotLenInput   = input.int(8, 'Pivot Strength (bars each side)', minval = 2, maxval = 50, group = G_ZONE, tooltip = 'Swing-pivot lookback. Larger = fewer, more significant zones (confirmation lag = this many bars).')
float zoneWInput      = input.float(1.0, 'Zone Height (x ATR)', minval = 0.2, maxval = 4.0, step = 0.1, group = G_ZONE)
int   atrLenInput     = input.int(14, 'ATR Length', minval = 1, group = G_ZONE)
int   maxZonesInput   = input.int(10, 'Max Zones (total)', minval = 2, maxval = 40, group = G_ZONE)
float mergeDedupeInput= input.float(0.6, 'Dedupe Separation (x ATR)', minval = 0.0, maxval = 5.0, step = 0.1, group = G_ZONE, tooltip = 'Gentle overlap filter: a new pivot within this distance of an existing ACTIVE same-side zone is skipped, so bands/labels stop stacking at the same price. Small keeps most zones; 0 = off.')
float invOffInput     = input.float(0.15, 'Invalidation Offset %', minval = 0.0, maxval = 2.0, step = 0.05, group = G_ZONE) / 100.0
bool  showMixedInput  = input.bool(true, 'Show MIXED (conflicted) zones', group = G_ZONE, tooltip = 'Zones where structure and contrarian composite disagree. Dimmed.')
bool  keepBrokenInput = input.bool(true, 'Keep broken zones (neutralized tone)', group = G_ZONE, tooltip = 'On invalidation, recolor to a muted tone instead of deleting.')
int   maxBrokenInput  = input.int(2, 'Keep last N broken zones', minval = 0, maxval = 20, group = G_ZONE, tooltip = 'History cap for neutralized zones. Older broken zones beyond this are removed so they stop cluttering the chart. 0 = drop broken zones as soon as they break.')

string G_VIZ = 'Visuals & Dashboard'
bool   gradFillInput  = input.bool(true, 'Gradient (double-shaded) fill', group = G_VIZ)
bool   candleTintInput= input.bool(true, 'Tint candles inside zones', group = G_VIZ)
bool   showSigDots    = input.bool(true, 'Contrarian extreme dots', group = G_VIZ, tooltip = 'Marks bars where the composite flips into an oversold/overbought extreme.')
bool   showDashInput  = input.bool(true, 'Show Dashboard', group = G_VIZ)
string dashPosInput   = input.string('Top Right', 'Dashboard Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Middle Right'], group = G_VIZ)
string dashSizeInput  = input.string('Normal', 'Dashboard Size', options = ['Small', 'Normal', 'Large'], group = G_VIZ)

string G_SIG = 'Signal Parameters'
int   rsiLenInput   = input.int(14, 'RSI Length', minval = 2, group = G_SIG)
float rsiSrcInput   = input.source(close, 'RSI Source', group = G_SIG)
int   adxLenInput   = input.int(14, 'ADX / DI Length', minval = 2, group = G_SIG)
int   adxSmoothInput= input.int(14, 'ADX Smoothing', minval = 1, group = G_SIG)
float adxEqTolInput = input.float(5.0, 'DI Equal Tolerance', minval = 0.0, maxval = 20.0, step = 0.5, group = G_SIG)
int   macdFastInput = input.int(12, 'MACD Fast', minval = 1, group = G_SIG, inline = 'm1')
int   macdSlowInput = input.int(26, 'Slow', minval = 2, group = G_SIG, inline = 'm1')
int   macdSigInput  = input.int(9, 'Signal', minval = 1, group = G_SIG, inline = 'm1')
string macdSrcMA    = input.string('EMA', 'MACD MA', options = ['EMA', 'SMA'], group = G_SIG, inline = 'm2')
string macdSigMA    = input.string('EMA', 'Signal MA', options = ['EMA', 'SMA'], group = G_SIG, inline = 'm2')

string G_IKH = 'Ichimoku'
int conversionPeriods   = input.int(9, 'Conversion Line', minval = 1, group = G_IKH)
int basePeriods         = input.int(26, 'Base Line', minval = 1, group = G_IKH)
int laggingSpan2Periods = input.int(52, 'Leading Span B', minval = 1, group = G_IKH)
int displacement        = input.int(26, 'Displacement', minval = 1, group = G_IKH)

string G_BB = 'Bollinger'
int    bbLenInput  = input.int(20, 'BB Length', minval = 1, group = G_BB, inline = 'bb1')
float  bbMultInput = input.float(2.0, 'StdDev', minval = 0.001, maxval = 50, group = G_BB, inline = 'bb1')
string bbMAType    = input.string('SMA', 'Basis MA', options = ['SMA', 'EMA', 'SMMA (RMA)', 'WMA', 'VWMA'], group = G_BB)
float  bbSrcInput  = input.source(close, 'BB Source', group = G_BB)

string G_OBV = 'OBV'
int    obvMaLenInput  = input.int(20, 'OBV MA Length', minval = 1, group = G_OBV, inline = 'obv1')
string obvMaType      = input.string('SMA', 'MA Type', options = ['SMA', 'EMA', 'SMMA (RMA)', 'WMA', 'VWMA'], group = G_OBV, inline = 'obv1')
int    obvRiseShort   = input.int(3, 'Rise (short)', minval = 1, group = G_OBV)
int    obvRiseLong    = input.int(5, 'Rise (long)', minval = 2, group = G_OBV)
int    obvFallShort   = input.int(3, 'Fall (short)', minval = 1, group = G_OBV)
float  obvNearTol     = input.float(0.02, 'Near MA Tol %', minval = 0.0, maxval = 0.2, step = 0.005, group = G_OBV)
float  obvSpikeK      = input.float(1.8, 'Spike k*avg|Δ|', minval = 0.5, maxval = 5.0, step = 0.1, group = G_OBV)
int    obvSpikeAvgLen = input.int(50, 'Spike Avg Len', minval = 5, group = G_OBV)

f_ma(string method, float src, int len) =>
    method == 'EMA' ? ta.ema(src, len) : ta.sma(src, len)

f_ma_full(string method, float src, int len) =>
    switch method
        'SMA'        => ta.sma(src, len)
        'EMA'        => ta.ema(src, len)
        'SMMA (RMA)' => ta.rma(src, len)
        'WMA'        => ta.wma(src, len)
        =>              ta.vwma(src, len)

f_grpRSI(float r) =>
    r < 20 ? 5 : r < 30 ? 4 : r > 80 ? 1 : r > 70 ? 2 : 3

f_grpEMA(float e9, float e21, float e50, float e100, float e200, float e250) =>
    bool bullFull = e9 > e21 and e21 > e50 and e50 > e100 and e100 > e200 and e200 > e250
    bool bull4    = e9 > e21 and e21 > e50 and e50 > e100 and not bullFull
    bool bull3    = e9 > e21 and e21 > e50 and e50 < e100
    bool bull2    = e9 > e21 and e21 < e50
    bool bearFull = e9 < e21 and e21 < e50 and e50 < e100 and e100 < e200 and e200 < e250
    bearFull ? 1 : bull2 ? 2 : bull3 ? 3 : bull4 ? 4 : bullFull ? 5 : 3

f_grpMACD(float macd, float sig, float hist) =>
    bool g1 = macd < 0 and hist < 0 and ta.falling(hist, 3)
    bool g2 = macd < 0 and (hist >= 0 or ta.rising(hist, 3))
    bool g3 = (ta.crossover(macd, sig) and macd <= 0) or (ta.crossunder(macd, sig) and macd >= 0)
    bool g4 = macd > 0 and hist > 0 and (macd > sig or ta.rising(hist, 3))
    bool g5 = macd > 0 and hist > 0 and ta.rising(macd, 5) and ta.rising(hist, 3)
    g1 ? 1 : g2 ? 2 : g3 ? 3 : g5 ? 5 : g4 ? 4 : 3

f_grpADX(float adx, float dip, float dim, float tol) =>
    bool g1 = adx < 20 and dim > dip
    bool g2 = adx >= 20 and adx < 25 and dim > dip
    bool nearEq = math.abs(dip - dim) <= tol
    bool g3 = adx >= 20 and adx < 25 and nearEq
    bool g4 = adx >= 25 and adx <= 40 and dip > dim
    bool g5 = adx > 40 and dip > dim
    g5 ? 5 : g4 ? 4 : g3 ? 3 : g2 ? 2 : g1 ? 1 : 3

f_grpIKH(float tenkan, float kijun, float spanA, float spanB, int disp) =>
    bool hasCloud = not na(spanA[disp]) and not na(spanB[disp]) and bar_index >= disp
    float top = hasCloud ? math.max(spanA[disp], spanB[disp]) : na
    float bot = hasCloud ? math.min(spanA[disp], spanB[disp]) : na
    bool belowKumo = hasCloud and close < bot
    bool aboveKumo = hasCloud and close > top
    bool inKumo    = hasCloud and not aboveKumo and not belowKumo
    bool tenUp     = tenkan > kijun
    bool tenDown   = tenkan < kijun
    bool tenCross  = ta.cross(tenkan, kijun)
    bool chikouAbove = bar_index >= disp and close > close[disp]
    bool chikouBelow = bar_index >= disp and close < close[disp]
    bool futBull = spanA > spanB and (spanA - spanB) > (spanA[1] - spanB[1])
    int grp = 3
    grp := tenDown and belowKumo and chikouBelow ? 1 : tenDown and (inKumo or not chikouBelow) ? 2 : tenCross and inKumo ? 3 : tenUp and aboveKumo and chikouAbove and futBull ? 5 : tenUp and aboveKumo and chikouAbove ? 4 : 3
    grp

f_grpBB(float price, float basis, float upper, float lower) =>
    bool g1 = price < lower or (price <= lower and (ta.falling(lower, 3) or ta.falling(basis, 3)))
    bool g5 = price > upper or (price >= upper and (ta.rising(upper, 3) or ta.rising(basis, 3)))
    bool g2 = price >= lower and price < basis
    bool g4 = price > basis and price <= upper
    g1 ? 1 : g5 ? 5 : g2 ? 2 : g4 ? 4 : 3

f_grpOBV(float obv, float obvMa, int riseS, int riseL, int fallS, float delta, float absAvg, float kSpike, float nearTol) =>
    bool isAbove = obv > obvMa
    bool isBelow = obv < obvMa
    bool risingS = ta.rising(obv, riseS)
    bool risingL = ta.rising(obv, riseL)
    bool fallingS = ta.falling(obv, fallS)
    bool nearMa  = math.abs(obvMa) > 0 ? math.abs(obv - obvMa) <= math.abs(obvMa) * nearTol : math.abs(obv - obvMa) <= nearTol
    bool spikeBuy = delta > kSpike * absAvg
    isBelow and fallingS ? 1 : (isBelow and (risingS or obv >= obvMa * (1.0 - nearTol))) ? 2 : nearMa ? 3 : (isAbove and risingS) ? 4 : (isAbove and risingL and spikeBuy) ? 5 : 3

float rsiV   = ta.rsi(rsiSrcInput, rsiLenInput)
float ema9   = ta.ema(close, 9),   ema21 = ta.ema(close, 21),  ema50 = ta.ema(close, 50)
float ema100 = ta.ema(close, 100), ema200 = ta.ema(close, 200), ema250 = ta.ema(close, 250)
float macdLine = f_ma(macdSrcMA, close, macdFastInput) - f_ma(macdSrcMA, close, macdSlowInput)
float macSig   = f_ma(macdSigMA, macdLine, macdSigInput)
float macHist  = macdLine - macSig
[diP, diM, adxV] = ta.dmi(adxLenInput, adxSmoothInput)
float tenkan = math.avg(ta.lowest(conversionPeriods), ta.highest(conversionPeriods))
float kijun  = math.avg(ta.lowest(basePeriods), ta.highest(basePeriods))
float spanA  = math.avg(tenkan, kijun)
float spanB  = math.avg(ta.lowest(laggingSpan2Periods), ta.highest(laggingSpan2Periods))
float bbBasis = f_ma_full(bbMAType, bbSrcInput, bbLenInput)
float bbDev   = bbMultInput * ta.stdev(bbSrcInput, bbLenInput)
float bbUpper = bbBasis + bbDev
float bbLower = bbBasis - bbDev
float obvV    = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
float obvMa   = f_ma_full(obvMaType, obvV, obvMaLenInput)
float obvDelta = obvV - obvV[1]
float obvAbsAvg = ta.sma(math.abs(obvDelta), obvSpikeAvgLen)

int grpRSI  = f_grpRSI(rsiV)
int grpEMA  = f_grpEMA(ema9, ema21, ema50, ema100, ema200, ema250)
int grpMACD = f_grpMACD(macdLine, macSig, macHist)
int grpADX  = f_grpADX(adxV, diP, diM, adxEqTolInput)
int grpIKH  = f_grpIKH(tenkan, kijun, spanA, spanB, displacement)
int grpBB   = f_grpBB(close, bbBasis, bbUpper, bbLower)
int grpOBV  = f_grpOBV(obvV, obvMa, obvRiseShort, obvRiseLong, obvFallShort, obvDelta, obvAbsAvg, obvSpikeK, obvNearTol)

int   sumLvls   = grpRSI + grpEMA + grpMACD + grpADX + grpIKH + grpBB + grpOBV
float avgLvl    = sumLvls / 7.0
float uThr      = math.min(1.0, math.max(0.0, (avgLvl - 1.0) / 4.0))
float activePct = uThr * 100.0

f_buySell(float o, float h, float l, float c, float v) =>
    float bv = 0.0
    float sv = 0.0
    if h > l
        bv := v * (c - l) / (h - l)
        sv := v * (h - c) / (h - l)
    else
        bv := v * 0.5
        sv := v * 0.5
    [math.max(0.0, bv), math.max(0.0, sv)]

[bvBar, svBar] = f_buySell(open, high, low, close, volume)
float rollBuy  = math.sum(bvBar, pressLenInput)
float rollSell = math.sum(svBar, pressLenInput)
float buyPct   = (rollBuy + rollSell) > 0 ? rollBuy / (rollBuy + rollSell) * 100.0 : 50.0
float sellPct  = 100.0 - buyPct

float atrVal = ta.atr(atrLenInput)
float volSma = ta.sma(volume, 20)
float mergeDist = atrVal * mergeDedupeInput

var box[]   zOuter   = array.new_box()
var box[]   zMid     = array.new_box()
var box[]   zCore    = array.new_box()
var line[]  zCtr     = array.new_line()
var label[] zLbl     = array.new_label()
var float[] zTop     = array.new_float()
var float[] zBot     = array.new_float()
var float[] zAnchor  = array.new_float()
var int[]   zClass   = array.new_int()
var bool[]  zSupport = array.new_bool()
var float[] zBase    = array.new_float()
var int[]   zTouch   = array.new_int()
var bool[]  zBroken  = array.new_bool()

f_classCol(int cls) =>
    cls == 1 ? C_BUY : cls == 2 ? C_SELL : C_MIX

f_classTag(int cls) =>
    cls == 1 ? '▲ BUY DIP' : cls == 2 ? '▼ SELL RIP' : '≈ MIXED'

f_stars(float s) =>
    int n = int(math.round(s / 2.0))
    n := math.max(0, math.min(5, n))
    str.substring('★★★★★☆☆☆☆☆', 5 - n, 10 - n)

f_score(bool isBuy, float comp, float relVol, float wickFrac, float pressure) =>
    float ext  = isBuy ? math.max(0.0, (comp - 50.0) / 50.0) : math.max(0.0, (50.0 - comp) / 50.0)
    float sExt = ext * 4.0
    float sVol = math.min(2.0, math.max(0.0, (relVol - 1.0) * 2.0))
    float sWk  = math.min(2.0, wickFrac * 2.0)
    float sPr  = math.min(2.0, pressure / 100.0 * 2.0)
    math.min(10.0, math.max(0.0, sExt + sVol + sWk + sPr))

f_display(int i) =>
    float d = array.get(zBase, i) + math.min(2.0, array.get(zTouch, i) * 0.5)
    math.min(10.0, d)

countValid() =>
    int c = 0
    if zClass.size() > 0
        for k = 0 to zClass.size() - 1
            if not array.get(zBroken, k)
                c += 1
    c

f_nearbyActive(float anchor, bool isSupport) =>
    bool found = false
    if mergeDist > 0 and zClass.size() > 0
        for k = 0 to zClass.size() - 1
            if not array.get(zBroken, k) and array.get(zSupport, k) == isSupport
                if math.abs(array.get(zAnchor, k) - anchor) < mergeDist
                    found := true
                    break
    found

zoneDel(int i) =>
    box.delete(array.get(zOuter, i))
    box.delete(array.get(zMid, i))
    box.delete(array.get(zCore, i))
    line.delete(array.get(zCtr, i))
    label.delete(array.get(zLbl, i))
    array.remove(zOuter, i)
    array.remove(zMid, i)
    array.remove(zCore, i)
    array.remove(zCtr, i)
    array.remove(zLbl, i)
    array.remove(zTop, i)
    array.remove(zBot, i)
    array.remove(zAnchor, i)
    array.remove(zClass, i)
    array.remove(zSupport, i)
    array.remove(zBase, i)
    array.remove(zTouch, i)
    array.remove(zBroken, i)

evictOldest() =>
    if zClass.size() > 0
        zoneDel(0)

f_refreshLabel(int i) =>
    int   cls = array.get(zClass, i)
    float sc  = f_display(i)
    string txt = f_classTag(cls) + '  ' + f_stars(sc) + '  ' + str.tostring(sc, '#.#') + '/10  [' + str.tostring(array.get(zTouch, i)) + 'x]' + (array.get(zBroken, i) ? '  ✝' : '') + '\n' + str.tostring(array.get(zAnchor, i), format.mintick)
    label.set_text(array.get(zLbl, i), txt)

createZone(float anchor, bool isSupport, int cls, float score, float wickFrac) =>
    float zh   = atrVal * zoneWInput
    float topP = isSupport ? anchor + zh * 0.12 : anchor + zh
    float botP = isSupport ? anchor - zh        : anchor - zh * 0.12
    color baseC = f_classCol(cls)
    int   sInt  = int(math.round(score))
    int   opOut = gradFillInput ? math.max(70, 92 - sInt * 2) : 84
    int   opMid = gradFillInput ? math.max(55, 82 - sInt * 2) : 72
    int   opCor = gradFillInput ? math.max(38, 72 - sInt * 3) : 60
    int   rx    = bar_index + pivotLenInput + 20
    int   lx    = bar_index - pivotLenInput
    box bOut = box.new(lx, topP, rx, botP, bgcolor = color.new(baseC, opOut), border_color = color.new(baseC, 100), border_width = 0)
    box bMid = box.new(lx, anchor + (topP - anchor) * 0.5, rx, anchor + (botP - anchor) * 0.5, bgcolor = color.new(baseC, opMid), border_color = color.new(baseC, 100), border_width = 0)
    box bCor = box.new(lx, anchor + (topP - anchor) * 0.22, rx, anchor + (botP - anchor) * 0.22, bgcolor = color.new(baseC, opCor), border_color = color.new(baseC, 35), border_width = 1)
    line ctr = line.new(lx, anchor, rx, anchor, color = color.new(baseC, 15), style = line.style_solid, width = 2)
    label lb = label.new(rx, anchor, '', color = color.new(baseC, 78), textcolor = WHITE_TX, style = label.style_label_left, size = size.small)
    array.push(zOuter, bOut)
    array.push(zMid, bMid)
    array.push(zCore, bCor)
    array.push(zCtr, ctr)
    array.push(zLbl, lb)
    array.push(zTop, topP)
    array.push(zBot, botP)
    array.push(zAnchor, anchor)
    array.push(zClass, cls)
    array.push(zSupport, isSupport)
    array.push(zBase, score)
    array.push(zTouch, 0)
    array.push(zBroken, false)
    f_refreshLabel(zClass.size() - 1)

float ph = ta.pivothigh(pivotLenInput, pivotLenInput)
float pl = ta.pivotlow(pivotLenInput, pivotLenInput)

float compAtBirth = activePct[pivotLenInput]
float buyAtBirth  = buyPct[pivotLenInput]
float sellAtBirth = sellPct[pivotLenInput]
float relVolBirth = volSma[pivotLenInput] > 0 ? volume[pivotLenInput] / volSma[pivotLenInput] : 1.0
float rngBirth    = high[pivotLenInput] - low[pivotLenInput]

if not na(pl)
    float wick = rngBirth > 0 ? (math.min(open[pivotLenInput], close[pivotLenInput]) - low[pivotLenInput]) / rngBirth : 0.0
    int   cls  = compAtBirth >= buyThreshInput ? 1 : 0
    if (cls == 1 or showMixedInput) and not f_nearbyActive(pl, true)
        float sc = f_score(true, compAtBirth, relVolBirth, wick, buyAtBirth)
        if countValid() >= maxZonesInput
            evictOldest()
        createZone(pl, true, cls, sc, wick)

if not na(ph)
    float wick = rngBirth > 0 ? (high[pivotLenInput] - math.max(open[pivotLenInput], close[pivotLenInput])) / rngBirth : 0.0
    int   cls  = compAtBirth <= sellThreshInput ? 2 : 0
    if (cls == 2 or showMixedInput) and not f_nearbyActive(ph, false)
        float sc = f_score(false, compAtBirth, relVolBirth, wick, sellAtBirth)
        if countValid() >= maxZonesInput
            evictOldest()
        createZone(ph, false, cls, sc, wick)

var int lastTouchBar = -999
bool touchBuy  = false
bool touchSell = false
bool brokeBuy  = false
bool brokeSell = false

if barstate.isconfirmed and zClass.size() > 0
    int i = 0
    while i < zClass.size()
        float topZ = array.get(zTop, i)
        float botZ = array.get(zBot, i)
        float anc  = array.get(zAnchor, i)
        int   cls  = array.get(zClass, i)
        bool  brk  = array.get(zBroken, i)
        bool  removed = false
        if not brk
            int rx2 = bar_index + 20
            box.set_right(array.get(zOuter, i), rx2)
            box.set_right(array.get(zMid, i), rx2)
            box.set_right(array.get(zCore, i), rx2)
            line.set_x2(array.get(zCtr, i), rx2)
            label.set_x(array.get(zLbl, i), rx2)
            bool touched = low <= topZ and high >= botZ
            if touched and (bar_index - lastTouchBar) > 2
                array.set(zTouch, i, array.get(zTouch, i) + 1)
                lastTouchBar := bar_index
                if cls == 1
                    touchBuy := true
                if cls == 2
                    touchSell := true
                f_refreshLabel(i)
            bool sup = array.get(zSupport, i)
            float invLine = sup ? botZ * (1.0 - invOffInput) : topZ * (1.0 + invOffInput)
            bool violated = sup ? close < invLine : close > invLine
            if violated
                if cls == 1
                    brokeBuy := true
                if cls == 2
                    brokeSell := true
                if keepBrokenInput
                    color muted = color.new(GHOST, 82)
                    box.set_bgcolor(array.get(zOuter, i), color.new(GHOST, 92))
                    box.set_bgcolor(array.get(zMid, i), muted)
                    box.set_bgcolor(array.get(zCore, i), color.new(GHOST, 74))
                    box.set_border_color(array.get(zCore, i), color.new(GHOST, 55))
                    line.set_color(array.get(zCtr, i), color.new(GHOST, 40))
                    label.set_color(array.get(zLbl, i), color.new(GHOST, 82))
                    array.set(zBroken, i, true)
                    f_refreshLabel(i)
                else
                    zoneDel(i)
                    removed := true
        if not removed
            i += 1
    bool pruning = zClass.size() > 0
    while pruning
        int   bc   = 0
        int   oldB = -1
        for k = 0 to zClass.size() - 1
            if array.get(zBroken, k)
                bc += 1
                if oldB == -1
                    oldB := k
        if bc > maxBrokenInput and oldB != -1
            zoneDel(oldB)
            pruning := zClass.size() > 0
        else
            pruning := false

color candleC = na
if candleTintInput and zClass.size() > 0
    for k = 0 to zClass.size() - 1
        if not array.get(zBroken, k)
            if low <= array.get(zTop, k) and high >= array.get(zBot, k)
                int cls = array.get(zClass, k)
                candleC := cls == 1 ? color.new(C_BUY, 25) : cls == 2 ? color.new(C_SELL, 25) : color.new(C_MIX, 45)
barcolor(candleC, title = 'Zone Candle Tint')

bool osFlip = activePct >= buyThreshInput and activePct[1] < buyThreshInput
bool obFlip = activePct <= sellThreshInput and activePct[1] > sellThreshInput
plotshape(showSigDots and osFlip, title = 'Oversold flip', style = shape.triangleup, location = location.belowbar, color = C_BUY, size = size.tiny, text = 'OS', textcolor = C_BUY)
plotshape(showSigDots and obFlip, title = 'Overbought flip', style = shape.triangledown, location = location.abovebar, color = C_SELL, size = size.tiny, text = 'OB', textcolor = C_SELL)

f_tierCol(int g) =>
    g >= 5 ? C_BUY : g == 4 ? color.new(C_BUY, 25) : g == 3 ? C_MIX : g == 2 ? #FF8A3C : C_SELL

f_tierTxt(int g) =>
    g == 5 ? 'L5 ⇈ OVERSOLD' : g == 4 ? 'L4 ↑ buy-lean' : g == 3 ? 'L3 — neutral' : g == 2 ? 'L2 ↓ sell-lean' : 'L1 ⇊ OVERBOUGHT'

f_bar(float pct) =>
    int f = int(math.round(pct / 10.0))
    f := math.max(0, math.min(10, f))
    str.substring('██████████░░░░░░░░░░', 10 - f, 20 - f)

string dashPos = dashPosInput == 'Top Left' ? position.top_left : dashPosInput == 'Bottom Right' ? position.bottom_right : dashPosInput == 'Bottom Left' ? position.bottom_left : dashPosInput == 'Middle Right' ? position.middle_right : position.top_right
string dashTsz = dashSizeInput == 'Small' ? size.tiny : dashSizeInput == 'Large' ? size.normal : size.small
var table dash = table.new(dashPos, 2, 16, bgcolor = color.new(PANEL_BG, 4), frame_color = STEEL, frame_width = 1, border_color = STEEL, border_width = 1)

if barstate.islast and showDashInput
    string tsz = dashTsz
    color verdCol = activePct >= buyThreshInput ? C_BUY : activePct <= sellThreshInput ? C_SELL : C_MIX
    string verdTx = activePct >= buyThreshInput ? '▲ BUY DIPS' : activePct <= sellThreshInput ? '▼ SELL RIPS' : '— NEUTRAL'
    int nBuy = 0
    int nSell = 0
    if zClass.size() > 0
        for k = 0 to zClass.size() - 1
            if not array.get(zBroken, k)
                int c = array.get(zClass, k)
                nBuy  := nBuy + (c == 1 ? 1 : 0)
                nSell := nSell + (c == 2 ? 1 : 0)
    float nDist = 1.0e18
    int   nCls  = -1
    float nSc   = 0.0
    if zClass.size() > 0
        for k = 0 to zClass.size() - 1
            if not array.get(zBroken, k)
                float d = math.abs(close - array.get(zAnchor, k))
                if d < nDist
                    nDist := d
                    nCls  := array.get(zClass, k)
                    nSc   := f_display(k)
    string nearTx = nCls == -1 ? '—' : (f_classTag(nCls) + ' ' + str.tostring(nSc, '#.#') + '/10  @' + str.tostring(nDist / (atrVal > 0 ? atrVal : 1.0), '#.#') + ' ATR')
    color  nearCol = nCls == 1 ? C_BUY : nCls == 2 ? C_SELL : nCls == 0 ? C_MIX : GHOST
    table.cell(dash, 0, 0, 'CONFLUENCE REACTION ZONES', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 0))
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 1, 'COMPOSITE', text_color = GHOST, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 1, str.tostring(activePct, '#') + '%  ' + f_bar(activePct), text_color = verdCol, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 2, 'VERDICT', text_color = GHOST, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 2, verdTx, text_color = verdCol, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 3, 'PRESSURE', text_color = GHOST, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 3, '▲' + str.tostring(buyPct, '#') + '%   ▼' + str.tostring(sellPct, '#') + '%', text_color = buyPct >= 50 ? C_BUY : C_SELL, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 4, '— SIGNAL DIAGNOSTICS —', text_color = GOLD_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 4))
    table.merge_cells(dash, 0, 4, 1, 4)
    table.cell(dash, 0, 5, 'RSI', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 5, f_tierTxt(grpRSI), text_color = f_tierCol(grpRSI), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 6, 'EMA Stack', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 6, f_tierTxt(grpEMA), text_color = f_tierCol(grpEMA), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 7, 'MACD', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 7, f_tierTxt(grpMACD), text_color = f_tierCol(grpMACD), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 8, 'ADX/DI', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 8, f_tierTxt(grpADX), text_color = f_tierCol(grpADX), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 9, 'Ichimoku', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 9, f_tierTxt(grpIKH), text_color = f_tierCol(grpIKH), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 10, 'Bollinger', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 10, f_tierTxt(grpBB), text_color = f_tierCol(grpBB), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 11, 'OBV', text_color = WHITE_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 11, f_tierTxt(grpOBV), text_color = f_tierCol(grpOBV), text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 12, '— REACTION ZONES —', text_color = GOLD_TX, text_size = tsz, bgcolor = color.new(PANEL_BG, 4))
    table.merge_cells(dash, 0, 12, 1, 12)
    table.cell(dash, 0, 13, '▲ BUY DIP zones', text_color = C_BUY, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 13, str.tostring(nBuy), text_color = C_BUY, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 14, '▼ SELL RIP zones', text_color = C_SELL, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 14, str.tostring(nSell), text_color = C_SELL, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 0, 15, 'NEAREST', text_color = GHOST, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))
    table.cell(dash, 1, 15, nearTx, text_color = nearCol, text_size = tsz, bgcolor = color.new(PANEL_BG, 12))

alertcondition(osFlip, 'Composite Oversold Flip', 'Reaction Zones: composite flipped OVERSOLD (contrarian BUY bias) on {{ticker}} {{interval}}')
alertcondition(obFlip, 'Composite Overbought Flip', 'Reaction Zones: composite flipped OVERBOUGHT (contrarian SELL bias) on {{ticker}} {{interval}}')
alertcondition(touchBuy,  'BUY-DIP Zone Retest',  'Reaction Zones: price retesting a BUY-DIP zone on {{ticker}}')
alertcondition(touchSell, 'SELL-RIP Zone Retest', 'Reaction Zones: price retesting a SELL-RIP zone on {{ticker}}')
alertcondition(brokeBuy,  'BUY-DIP Zone Broken',  'Reaction Zones: a BUY-DIP zone was invalidated on {{ticker}}')
alertcondition(brokeSell, 'SELL-RIP Zone Broken', 'Reaction Zones: a SELL-RIP zone was invalidated on {{ticker}}')

plot(activePct, 'Composite %', display = display.data_window, format = format.percent)
plot(buyPct,    '% Buy Pressure',  display = display.data_window, format = format.percent)
plot(sellPct,   '% Sell Pressure', display = display.data_window, format = format.percent)
plot(avgLvl,    'Avg Signal Level',  display = display.data_window)
````
