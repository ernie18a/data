# Adaptive Ichimoku Equilibrium Channel

- url: https://www.tradingview.com/script/aVuJqPOL-Adaptive-Ichimoku-Equilibrium-Channel/
- type: indicator
- pine_id: PUB;52182bf7e12f48a69daac8d7836f25c3
- version: 1.0

## Description

ADAPTIVE ICHIMOKU EQUILIBRIUM CHANNEL

WHAT IT IS

A modern, single-engine extension of Ichimoku Kinko Hyo. Ichimoku's core insight is that its lines are not moving averages but EQUILIBRIUM midpoints — the centre of the recent high/low range — and that it projects that equilibrium forward as a cloud. This script keeps that DNA and rebuilds it as one adaptive object: the equilibrium adapts to trend efficiency, the channel width breathes with volatility, volume confirms or warns, momentum and breakouts flag turns, equal-high/low liquidity pools become structural targets, the cloud trend is read across four timeframes, and a past-only calibration attaches an honest hit-rate to the signals. A plain-language verdict makes it readable at a glance; an Advanced view exposes the full engine.

It is a single indicator, not a pack. Everything plots in one pane on the price chart.


WHY THESE COMPONENTS ARE COMBINED (mashup justification)

Each layer answers a different question a trend trader must answer at the same moment, and all of them share — and reinforce — the same equilibrium spine, which is why they are fused into one engine rather than left as separate studies that would each repaint the chart and never reference each other:

- EQUILIBRIUM SPINE. Fast and slow range-midpoints (the Ichimoku Tenkan/Kijun idea) blended by an efficiency ratio, so the spine tracks quickly in clean trends and slowly in chop. This is "fair value", and every other layer is measured relative to it.

- KUMO CLOUD + MULTI-TIMEFRAME TREND. The forward-displaced cloud shows trend at a glance. The same cloud trend is then sampled at 1x, 3x, 5x and 15x the chart timeframe and shown as four colour-coded cells, so higher-timeframe alignment is visible without switching charts. Alignment across the four is stronger context; conflict is a caution.

- ADAPTIVE WIDTH / PREMIUM-DISCOUNT. The dealing range around the spine expands when volatility expands and contracts when it compresses (width is ATR-based). This makes "discount" (lower half) and "premium" (upper half) mean the same thing across assets and regimes — a fixed-width channel cannot.

- VOLUME CONFIRMATION. Volume-weighted price versus its simple average shows whether volume agrees with the trend; a volume surge flags conviction. This closes the blind spot of a price-only channel. On instruments that report no volume, volume can be borrowed from a chosen proxy symbol.

- DISTANCE-FROM-EQUILIBRIUM DIVERGENCE. Ichimoku has no native oscillator, so momentum here is reconstructed as price's distance FROM the equilibrium spine: when price makes a higher high that is LESS extended from the spine than the previous high (or a lower low that is less extended), momentum is waning and a divergence is flagged at the extreme — exactly where reversals begin.

- VALIDATED BREAKOUTS. A break of a channel rail is only marked when it is confirmed by displacement beyond the rail, a dominant candle body, above-average volume, and a close that holds beyond the rail (anti-wick). This filters out the wick-pokes that fake breakouts on a naive channel.

- LIQUIDITY POOLS. Clusters of equal highs and equal lows are where stop orders rest. The script tracks the nearest unswept pool above and below price and lets trade targets snap to them, so objectives are structural rather than arbitrary.

- FUTURE BIAS + CALIBRATION. Trend, zone, slope, volume and breakouts are fused into a continuation-versus-reversion probability. Separately, the channel setups and the zone signals each carry a PAST-ONLY forward hit-rate, reported with a Wilson 95% confidence interval, measured on the current symbol.

In short: equilibrium without width gives no zones; width without volume or structure is blind; and neither tells you what is statistically likely next or whether the same setup has worked before on this symbol. Because each piece needs the others to be useful, they are one object.


HOW IT WORKS TOGETHER (reading the chart)

1. The trend-coloured band and its midline are the trend: green up, red down, gold/grey when there is no clear trend. The midline holds its colour until the trend actually reverses, so it does not flicker in chop.
2. Within the band, the lower (discount) half is where to look to engage with an uptrend; the upper (premium) half is extended. A downtrend mirrors this.
3. The short coloured level on the right is the invalidation: the current trend read fails on a close beyond it.
4. The dashboard's Ichimoku row shows the cloud trend on 1x/3x/5x/15x. The Higher-TF row tells you whether trades are permitted (setups are taken only in the higher timeframe's direction).
5. An orange "Div" marker warns of waning momentum at an extreme. A "Break" diamond marks a validated breakout. Cyan EQH/EQL lines are the nearest liquidity pools and act as targets.
6. The verdict box states the trend, where price sits, and the conviction in words. The Advanced view adds the calibrated win-rates, volume read, channel state and any optional inter-market context.


HOW TO USE IT

- Apply to any symbol and timeframe. Read the band colour for trend, the half for location, and the verdict box for the plain-language summary.
- Use the Ichimoku multi-timeframe row to gauge whether the higher timeframes agree before acting on a lower-timeframe signal.
- On-chart markers, from most to least prominent: LONG / SHORT label badges are full trade setups (entry, stop and target); Buy / Sell triangles mark price entering the discount/premium zone; the tiny orange "Div" warns of waning momentum at an extreme; the tiny "Break" diamond marks a validated breakout; cyan EQH/EQL lines are the nearest liquidity-pool targets.
- Treat all markers as context, and check their past-only win-rates in the Advanced view before relying on them.
- This is analysis context for your own decision, not a signal to act on blindly. It places no orders.


ORIGINALITY (versus standard Ichimoku)

Standard Ichimoku is a fixed-length, price-only, single-timeframe tool with no volume, no momentum oscillator, no breakout validation, no targets, and no measure of whether it has worked. This script makes the equilibrium adaptive, makes the width volatility-driven, reconstructs momentum as distance-from-equilibrium, validates breakouts against wicks, turns equal-high/low liquidity into targets, shows the cloud trend across four timeframes, adds volume confirmation, and attaches a past-only calibrated hit-rate to its signals. None of that is provided by classic Ichimoku.


UNIVERSAL DATA (works on any market)

The price source is selectable in Settings (default close; choose hl2, hlc3, or any series), every threshold is ATR-relative, and volume can be borrowed from a proxy symbol for instruments that report none — so the script runs on stocks, futures, FX, crypto and indices without re-tuning. Two optional refinements are off by default and never shown on the simple face: a spot symbol (futures-vs-spot basis) and a volatility index (e.g. VIX / India VIX), which feed conviction and channel width when supplied. The entire display — dashboard, bands, lines, labels and markers — adapts to your chart background automatically (Auto theme), or can be forced to Dark or Light, so it stays readable on any background.


SETTINGS OVERVIEW

Data source (price source, optional borrowed-volume symbol); Equilibrium (Tenkan/Kijun lengths, adaptive blend); Adaptive width; Regime (efficiency, ADX, slope); Inter-market refinement (optional); Multi-timeframe trade filter; Calibration horizon and follow-through; Trades; Breakout validation thresholds; Liquidity tolerance; and Visuals (theme, zones, signals, divergence, liquidity, multi-timeframe levels, dashboard position).


LIMITATIONS

The forward cloud is a PROJECTION of the current equilibrium, not a forecast. Calibration and hit-rates describe PAST behaviour only on the current symbol and are not predictive. Borrowed volume, futures-vs-spot basis and volatility-index refinement are approximations. Everything here is probabilistic context, not certainty.


DISCLAIMER

This is a study/indicator for chart analysis and education only. It is not a strategy, not a recommendation, and not financial advice. It places no orders and guarantees no outcome. Markets carry risk; do your own research and manage your own risk.

## Source Code

````pine
// =============================================================================
//  ADAPTIVE ICHIMOKU EQUILIBRIUM CHANNEL                              Pine Script v6
//  shorttitle: IchiEqCh
// -----------------------------------------------------------------------------
//  WHAT THIS IS
//    An evolution of Ichimoku. Ichimoku's genius is that its lines are not moving
//    averages but EQUILIBRIUM midpoints — the centre of the recent range — and
//    that it projects that equilibrium into the future as a cloud. This script
//    keeps that idea and modernises it: the equilibrium adapts to trend
//    efficiency, the channel WIDTH breathes with volatility (and, optionally, a
//    volatility index), and a calibrated future-bias estimates whether the path
//    is more likely to continue or revert. A plain-language verdict, a coloured
//    cloud, and shaded buy/sell zones make it readable at a glance; an Advanced
//    view exposes the full engine for those who want it.
//
//  WHY THE COMPONENTS ARE COMBINED  (mashup rationale)
//    Each piece answers a different question, and a trader needs all of them at
//    once, so they are fused into one object rather than stacked as separate
//    studies:
//      * EQUILIBRIUM SPINE — fast and slow range-midpoints (Ichimoku Tenkan/Kijun
//        idea), blended by an efficiency ratio so the spine tracks faster in clean
//        trends and slower in chop. This is fair value.
//      * KUMO CLOUD — the forward-displaced fill between the equilibria; its
//        colour is the trend at a glance, exactly as in Ichimoku.
//      * ADAPTIVE WIDTH — the dealing range around the spine expands in volatility
//        expansion and contracts in compression, so the zones mean the same thing
//        across assets and regimes (fixed-width channels do not).
//      * PREMIUM / DISCOUNT — the zones of that range: where, within the trend, an
//        entry is favourable versus extended.
//      * TREND STATE + QUALITY — slope, cloud orientation and efficiency turn the
//        picture into one state and a clean/noisy quality read.
//      * FUTURE BIAS — projects the equilibrium forward and estimates continuation
//        versus reversion, calibrated past-only on the current symbol.
//      * VOLUME CONFIRMATION — volume-weighted price vs its average shows whether
//        volume agrees with the trend; a surge flags conviction (volume is borrowed
//        from a chosen symbol where the asset reports none).
//      * DISTANCE-FROM-EQUILIBRIUM DIVERGENCE — Ichimoku has no oscillator, so
//        momentum is read as price's distance from the spine: a higher high that is
//        less extended than the prior one warns of waning momentum at the extreme.
//      * VALIDATED BREAKOUTS — a rail break counts only with displacement, a strong
//        candle body, above-average volume and a holding close, filtering wick fakes.
//      * LIQUIDITY POOLS — clusters of equal highs/lows (resting stops) are tracked
//        as the nearest unswept pools, and trade targets snap to them.
//      * MULTI-TIMEFRAME CLOUD — the Ichimoku cloud trend is sampled at 1x/3x/5x/15x
//        the chart timeframe so higher-timeframe alignment is visible at a glance.
//      * CALIBRATION — channel setups and zone signals each carry a past-only forward
//        hit-rate with a Wilson confidence interval, on the current symbol.
//    Equilibrium without width gives no zones; width without volume or structure is
//    blind; neither tells you what is likely next or whether it has worked before —
//    which is why these are one engine, not eight indicators.
//
//  HOW TO USE IT  (plain language)
//    1. The trend-coloured band and its midline are the trend: green up, red down,
//       gold/grey = range. The midline holds its colour until the trend reverses.
//    2. In an uptrend the lower (discount) half is where to look to buy; the upper
//       (premium) half is extended. A downtrend mirrors this.
//    3. The short coloured level on the right is the invalidation: the trend read
//       fails on a close beyond it.
//    4. The dashboard's Ichimoku row shows cloud trend on 1x/3x/5x/15x; aligned
//       colours are stronger context, conflict is caution.
//    5. On-chart markers, by importance (largest to smallest):
//         LONG / SHORT label badges  = full trade setups (entry, stop, target).
//         Buy / Sell triangles       = price entered the discount/premium zone.
//         orange "Div" (tiny)        = waning momentum at an extreme.
//         "Break" diamond (tiny)     = a validated channel breakout.
//       Cyan EQH/EQL lines are the nearest liquidity-pool targets.
//    6. The verdict box states trend, location and conviction in words; the Advanced
//       view adds past-only win-rates. This is context for your decision, not a
//       signal to act on blindly. No tool removes risk; manage your own.
//
//  UNIVERSAL + OPTIONAL REFINEMENT
//    Runs on ANY asset on its own raw data (all thresholds are ATR-relative, and
//    volume is borrowed where a symbol reports none). It is REFINED if you add a
//    spot symbol (futures-vs-spot basis confirms conviction) and/or a volatility
//    index such as VIX (drives width and caution). Both are optional and off by
//    default; the simple face never shows them.
//
//  ORIGINALITY
//    Not an Ichimoku clone: the equilibrium is adaptive, the width is volatility-
//    driven, momentum is reconstructed as distance-from-equilibrium (Ichimoku has no
//    oscillator), breakouts are validated against wicks, equal-high/low liquidity
//    pools become targets, the cloud trend is shown across 1x/3x/5x/15x, volume
//    confirms the bias, and every signal carries a past-only calibrated hit-rate —
//    none of which standard Ichimoku provides.
//
//  LIMITATIONS (honest)
//    The forward cloud is a PROJECTION of current equilibrium, not a forecast.
//    Calibration describes PAST behaviour only. Basis/volatility refinement is
//    market-specific. Everything here is probabilistic context.
//
//  DISCLAIMER
//    Study / indicator for chart analysis and education only. NOT a strategy, NOT
//    a recommendation, NOT financial advice. It places no orders and guarantees no
//    outcome. Markets carry risk. Do your own research and manage your own risk.
// =============================================================================

//@version=6
indicator("Adaptive Ichimoku Equilibrium Channel", "IchiEqCh", overlay = true, max_labels_count = 100, max_lines_count = 100, max_bars_back = 1000)

// ───────────────────────────── INPUTS ──────────────────────────────────────
gSrc = "Data Source (any asset)"
srcPrice = input.source(close, "Price source", group = gSrc)
volBorrowSym = input.symbol("", "Borrow volume from symbol (no-volume fix)", group = gSrc)

gEq = "Equilibrium (Ichimoku DNA)"
tenkanLen = input.int(9,  "Fast equilibrium (Tenkan)", minval = 2, group = gEq)
kijunLen  = input.int(26, "Slow equilibrium (Kijun)", minval = 2, group = gEq)
senkouLen = input.int(52, "Cloud base (Senkou B)", minval = 2, group = gEq)
disp      = input.int(26, "Forward projection (bars)", minval = 1, maxval = 100, group = gEq)
adaptEq   = input.bool(true, "Adaptive spine (efficiency-blended)", group = gEq)

gW = "Adaptive Channel Width"
widthMult = input.float(1.5, "Base width (x ATR)", minval = 0.3, maxval = 6.0, step = 0.1, group = gW)
widthFromVol = input.bool(true, "Breathe with volatility", group = gW)

gReg = "Regime"
erLen = input.int(20, "Efficiency-ratio length", minval = 2, group = gReg)
adxLen = input.int(14, "ADX length", minval = 2, group = gReg)
slopeLen = input.int(5, "Spine slope length", minval = 1, group = gReg)

gIM = "Inter-Market Refinement (optional)"
spotSym = input.symbol("", "Spot symbol (futures-vs-spot basis)", group = gIM, tooltip = "Leave blank to ignore. If your chart is a future, add the cash/spot symbol; the basis confirms conviction.")
vixSym  = input.symbol("", "Volatility index (e.g. VIX / India VIX)", group = gIM, tooltip = "Leave blank to ignore. Drives channel width and caution.")

gMTF = "Multi-Timeframe (trade filter)"
useHTF = input.bool(true, "Confirm trades with higher timeframe", group = gMTF)
htfTF = input.timeframe("", "Higher timeframe (blank = auto)", group = gMTF)
useLTF = input.bool(true, "Refine entry timing with lower timeframe", group = gMTF, tooltip = "Uses the lower timeframe's current momentum to time entries. Reflects current state, not fully aggregated history.")
ltfTF = input.timeframe("", "Lower timeframe (blank = auto)", group = gMTF)
requireAlignedTrend = input.bool(true, "Only trade a clear, aligned trend (skip range/conflict)", group = gMTF)
clearThr = input.float(0.30, "Minimum trend clarity (efficiency)", minval = 0.1, maxval = 0.8, step = 0.05, group = gMTF, tooltip = "No setups unless efficiency (trend clarity) is above this — stops trades in chop.")

gCal = "Calibration (past-only)"
calEnable = input.bool(true, "Track future-bias follow-through", group = gCal)
calHorizon = input.int(20, "Evaluation horizon (bars)", minval = 3, maxval = 100, group = gCal)
calMoveATR = input.float(1.0, "Min follow-through (x ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = gCal)

gT = "Trades (channel-based setups)"
showTrades = input.bool(true, "Show trade setups (entry / stop / target)", group = gT, tooltip = "Setups are derived from the channel: in an uptrend, buy the discount zone with a stop beyond the cloud and a target at the range high. Context, not guaranteed signals — manage your own risk.")
showSignals = input.bool(true, "Show entry signals (zone entries)", group = gT, tooltip = "Marks when price enters the discount buy zone in an uptrend or the premium sell zone in a downtrend. These are not gated by the higher timeframe, so they appear more often than the full trade setups.")
stopBuf = input.float(0.25, "Stop buffer beyond cloud (x ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = gT)
minRR = input.float(1.2, "Minimum reward:risk to take a setup", minval = 0.3, maxval = 5.0, step = 0.1, group = gT)

gBrk = "Breakout validation"
showBrk = input.bool(true, "Validated channel breakouts", group = gBrk, tooltip = "Marks a rail breakout only when it is confirmed by displacement, a dominant candle body, above-average volume and a close that holds beyond the rail (anti-wick) — filters out wick fakes.")
brkDisp = input.float(0.25, "Min displacement beyond rail (x ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gBrk)
brkBody = input.float(0.5, "Min body fraction of range", minval = 0.1, maxval = 1.0, step = 0.05, group = gBrk)
brkVol = input.float(1.2, "Min volume vs 20-bar average", minval = 0.5, maxval = 5.0, step = 0.1, group = gBrk)

gLiq = "Liquidity targets"
showLiq = input.bool(true, "Equal-high / equal-low liquidity pools", group = gLiq, tooltip = "Detects clusters of equal highs/lows (resting liquidity) and draws the nearest unswept pool above and below in cyan. Trade targets snap to these pools when available.")
useLiq = input.bool(true, "Use liquidity pools as trade targets", group = gLiq, tooltip = "When on, a long targets the nearest equal-high pool (and a short the nearest equal-low), falling back to the channel rail if none exists.")
liqLb = input.int(5, "Liquidity pivot length", minval = 2, maxval = 30, group = gLiq)
eqTol = input.float(0.10, "Equal-level tolerance (x ATR)", minval = 0.02, maxval = 1.0, step = 0.02, group = gLiq)

gV = "Visuals"
showAdvanced = input.bool(false, "Advanced view (extra bands, cone, detail)", group = gV)
themeMode = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)", "Dark", "Light"], group = gV)
bullCol = input.color(#089981, "Bullish", group = gV)
bearCol = input.color(#f23645, "Bearish", group = gV)
showZones = input.bool(true, "Buy / sell zone shading", group = gV)
showCloud = input.bool(false, "Forward cloud (Kumo / Ichimoku)", group = gV)
showVerdict = input.bool(true, "Plain-language verdict + dashboard", group = gV)
showSR = input.bool(true, "Support / resistance level (right-side line)", group = gV, tooltip = "Draws the trend's invalidation level as a colour-coded line on the right: green support in an uptrend, red resistance in a downtrend.")
showIchiTrend = input.bool(true, "Ichimoku trend triangles (bottom)", group = gV, tooltip = "Tiny triangles along the bottom show the cloud trend: green ▲ when bullish (Senkou A above B), red ▼ when bearish — keeps the Ichimoku read even with the cloud hidden.")
showHtfSR = input.bool(true, "3× / 5× / 15× equilibrium S/R levels", group = gV, tooltip = "Draws the equilibrium at 3×, 5× and 15× the chart timeframe as colour-coded support/resistance lines, each labelled with its multiple and value. Heavier line = higher timeframe.")
showDiv = input.bool(true, "Equilibrium-distance divergence markers", group = gV, tooltip = "Flags when price makes a higher high (or lower low) but its distance from the equilibrium is shrinking — a momentum-waning warning at the extreme. Drawn in orange.")
divLb = input.int(5, "Divergence pivot length", minval = 2, maxval = 30, group = gV)
dashPosStr = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gV)
showId = input.bool(true, "Identity strip", group = gV)
smoothDisp = input.bool(true, "Smooth lines for display (logic stays raw)", group = gV, tooltip = "Renders the spine, rails and cloud as smooth curves. The trend state, zones, conviction and trades are still computed on the raw Ichimoku equilibrium values underneath.")
smoothLen = input.int(10, "Display smoothing amount", minval = 2, maxval = 80, group = gV)
smoothStyle = input.string("Curve (smoothest)", "Curve style", options = ["Curve (smoothest)", "Smooth (EMA)"], group = gV, tooltip = "Curve uses an ALMA filter for a flowing, polynomial-like band; Smooth uses an EMA. Display only — the trend, zones and trades stay on raw Ichimoku values.")

// ───────────────────────────── PURE HELPERS ────────────────────────────────
f_luma(color c) => na(c) ? 0.0 : color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right
f_wilson(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p = hits / float(total)
        float z = 1.96
        float den = 1.0 + z * z / total
        float c = (p + z * z / (2.0 * total)) / den
        float h = z * math.sqrt(p * (1.0 - p) / total + z * z / (4.0 * total * total)) / den
        lo := math.max(0.0, c - h)
        hi := math.min(1.0, c + h)
    [lo, hi]

// multi-timeframe helpers (pure)
f_autoHTF() =>
    float s = timeframe.in_seconds(timeframe.period)
    s <= 60 ? "15" : s <= 300 ? "60" : s <= 900 ? "240" : s <= 3600 ? "D" : s <= 86400 ? "W" : "M"
f_autoLTF() =>
    float s = timeframe.in_seconds(timeframe.period)
    s >= 86400 ? "60" : s >= 3600 ? "15" : s >= 900 ? "5" : "1"
f_mult(int m) =>
    float s = timeframe.in_seconds(timeframe.period) * m
    s < 60 ? str.tostring(math.round(s)) + "S" : s < 86400 ? str.tostring(math.round(s / 60.0)) : s < 604800 ? str.tostring(math.round(s / 86400.0)) + "D" : str.tostring(math.round(s / 604800.0)) + "W"
// higher-timeframe equilibrium (adaptive spine) value — pure: built-ins + inputs
f_equi() =>
    float tk = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2.0
    float kj = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2.0
    float en = math.abs(close - close[erLen])
    float ed = math.sum(math.abs(close - close[1]), erLen)
    float e2 = ed > 0 ? en / ed : 0.0
    float eqv = adaptEq ? e2 * tk + (1.0 - e2) * kj : kj
    float sb = (ta.highest(high, senkouLen) + ta.lowest(low, senkouLen)) / 2.0
    float sa = (tk + kj) / 2.0
    float ctp = math.max(sa, sb)
    float cbt = math.min(sa, sb)
    bool cbull = sa > sb
    int ich = close > ctp ? (cbull ? 2 : 1) : close < cbt ? (cbull ? -1 : -2) : 0
    [eqv, ich]
f_iar(int i) =>
    i >= 2 ? "▲" : i == 1 ? "△" : i == -1 ? "▽" : i <= -2 ? "▼" : "–"
f_trendProxy() =>
    float tk = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2.0
    float kj = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2.0
    float sb = (ta.highest(high, senkouLen) + ta.lowest(low, senkouLen)) / 2.0
    float sa = (tk + kj) / 2.0
    bool cb = sa > sb
    float ctp = math.max(sa, sb)
    float cbt = math.min(sa, sb)
    bool ab = close > ctp
    bool bl = close < cbt
    float sl = kj - kj[slopeLen]
    float en = math.abs(close - close[erLen])
    float ed = math.sum(math.abs(close - close[1]), erLen)
    float e2 = ed > 0 ? en / ed : 0.0
    [dp, dm, ax] = ta.dmi(adxLen, adxLen)
    bool sr = e2 > 0.4 and ax > 22
    int ts = ab and cb and sl > 0 and sr ? 2 : ab and (cb or sl > 0) ? 1 : bl and not cb and sl < 0 and sr ? -2 : bl and (not cb or sl < 0) ? -1 : 0
    ts
f_ltfConfirm() =>
    float e9 = ta.ema(close, 9)
    close > e9 ? 1 : close < e9 ? -1 : 0
// display curve: ALMA for a polynomial-like band, EMA for plain smooth, raw when off
f_disp(float x) =>
    float e = ta.ema(x, smoothLen)
    float a = ta.alma(x, smoothLen, 0.85, 6)
    not smoothDisp ? x : (smoothStyle == "Curve (smoothest)" ? a : e)

// ───────────────────────────── THEME ───────────────────────────────────────
_luma = f_luma(chart.bg_color)
uiDark = themeMode == "Dark" ? true : themeMode == "Light" ? false : (na(chart.bg_color) or _luma < 140)
uiBull = bullCol
uiBear = bearCol
cPanel = uiDark ? color.rgb(10, 14, 26)   : color.rgb(244, 246, 248)
cSub   = uiDark ? color.rgb(22, 27, 34)   : color.rgb(233, 237, 242)
cAlt   = uiDark ? color.rgb(16, 20, 32)   : color.rgb(238, 241, 245)
cTxt   = uiDark ? color.rgb(226, 232, 240): color.rgb(20, 26, 38)
cDim   = uiDark ? color.rgb(150, 160, 174): color.rgb(96, 104, 116)
cFrame = uiDark ? color.rgb(42, 52, 88)   : color.rgb(196, 204, 212)
cBord  = uiDark ? color.rgb(26, 34, 56)   : color.rgb(210, 216, 224)
uiGold = uiDark ? color.rgb(255, 196, 0)  : color.rgb(176, 120, 0)

// ───────────────────────────── VOLUME + INTER-MARKET (unconditional) ────────
var bool nativeVolSeen = false
if volume > 0
    nativeVolSeen := true
useBorrow = str.length(volBorrowSym) > 0 and not nativeVolSeen
volBorrowResolved = str.length(volBorrowSym) > 0 ? volBorrowSym : syminfo.tickerid
volBorrowRaw = request.security(volBorrowResolved, timeframe.period, volume, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
volEff = useBorrow and not na(volBorrowRaw) ? volBorrowRaw : volume
bool volOk = not na(volEff) and volEff > 0

spotOn = str.length(spotSym) > 0
spotResolved = spotOn ? spotSym : syminfo.tickerid
spotClose = request.security(spotResolved, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

vixOn = str.length(vixSym) > 0
vixResolved = vixOn ? vixSym : syminfo.tickerid
vixClose = request.security(vixResolved, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

htfRes = str.length(htfTF) > 0 ? htfTF : f_autoHTF()
ltfRes = str.length(ltfTF) > 0 ? ltfTF : f_autoLTF()
int htfTrend = request.security(syminfo.tickerid, htfRes, f_trendProxy(), lookahead = barmerge.lookahead_off)
int ltfBias = request.security(syminfo.tickerid, ltfRes, f_ltfConfirm(), lookahead = barmerge.lookahead_off)
tf3 = f_mult(3)
tf5 = f_mult(5)
tf15 = f_mult(15)
[eq3, ich3]   = request.security(syminfo.tickerid, tf3,  f_equi(), lookahead = barmerge.lookahead_off)
[eq5, ich5]   = request.security(syminfo.tickerid, tf5,  f_equi(), lookahead = barmerge.lookahead_off)
[eq15, ich15] = request.security(syminfo.tickerid, tf15, f_equi(), lookahead = barmerge.lookahead_off)

// ───────────────────────────── CORE SERIES ─────────────────────────────────
atr = ta.atr(14)
atrSafe = atr > 0 ? atr : close * 0.001
atrAvg = ta.sma(atr, 100)
erNum = math.abs(srcPrice - srcPrice[erLen])
erDen = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
er = erDen > 0 ? erNum / erDen : 0.0
[diP, diM, adx] = ta.dmi(adxLen, adxLen)

// ───────────────────────────── EQUILIBRIUM SPINE + CLOUD ───────────────────
tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2.0
kijun  = (ta.highest(high, kijunLen)  + ta.lowest(low, kijunLen))  / 2.0
senkB  = (ta.highest(high, senkouLen) + ta.lowest(low, senkouLen)) / 2.0
senkA  = (tenkan + kijun) / 2.0
// adaptive spine: track fast equilibrium in clean trends, slow in chop
spine = adaptEq ? er * tenkan + (1.0 - er) * kijun : kijun

bool cloudBull = senkA > senkB
float cloudTop = math.max(senkA, senkB)
float cloudBot = math.min(senkA, senkB)
bool aboveCloud = close > cloudTop
bool belowCloud = close < cloudBot
int ich1 = aboveCloud ? (cloudBull ? 2 : 1) : belowCloud ? (cloudBull ? -1 : -2) : 0
float spineSlope = spine - spine[slopeLen]

// ───────────────────────────── VIX / BASIS REFINEMENT ──────────────────────
float vixNorm = 1.0
bool vixRising = false
float vAvg = ta.sma(vixClose, 50)
if vixOn and not na(vixClose)
    vixNorm := vAvg > 0 ? f_clamp(vixClose / vAvg, 0.6, 2.0) : 1.0
    vixRising := vixClose > nz(vixClose[5], vixClose)
float basisAtr = 0.0
bool basisOn = spotOn and not na(spotClose) and spotClose > 0
if basisOn
    basisAtr := (close - spotClose) / atrSafe
float basisSlope = basisOn ? basisAtr - nz(basisAtr[5], basisAtr) : 0.0

// ───────────────────────────── ADAPTIVE WIDTH + DEALING RANGE ──────────────
float volFactor = widthFromVol and atrAvg > 0 ? f_clamp(atr / atrAvg, 0.6, 2.2) : 1.0
float vixFactor = vixOn ? f_clamp(vixNorm, 0.7, 1.8) : 1.0
float width = atrSafe * widthMult * volFactor * vixFactor
float rangeHigh = spine + width
float rangeLow  = spine - width
float premBound = spine + 0.5 * width
float discBound = spine - 0.5 * width
float rangeHi2 = spine + 2.0 * width
float rangeLo2 = spine - 2.0 * width
float posInRange = (rangeHigh - rangeLow) > 0 ? f_clamp((close - rangeLow) / (rangeHigh - rangeLow), 0.0, 1.0) : 0.5
string zoneTxt = posInRange > 0.75 ? "Premium" : posInRange < 0.25 ? "Discount" : "Equilibrium"

// ── DISPLAY SMOOTHING (cosmetic only — every calculation above uses raw values) ──
spineDisp  = f_disp(spine)
rangeHighD = f_disp(rangeHigh)
rangeLowD  = f_disp(rangeLow)
rangeHi2D  = f_disp(rangeHi2)
rangeLo2D  = f_disp(rangeLo2)
senkAD     = f_disp(senkA)
senkBD     = f_disp(senkB)
cloudBotD  = f_disp(cloudBot)
cloudTopD  = f_disp(cloudTop)

// ───────────────────────────── TREND STATE + QUALITY ───────────────────────
bool strongReg = er > 0.4 and adx > 22
int trendState = 0
if aboveCloud and cloudBull and spineSlope > 0 and strongReg
    trendState := 2
else if aboveCloud and (cloudBull or spineSlope > 0)
    trendState := 1
else if belowCloud and not cloudBull and spineSlope < 0 and strongReg
    trendState := -2
else if belowCloud and (not cloudBull or spineSlope < 0)
    trendState := -1
else
    trendState := 0
string stateTxt = trendState == 2 ? "Strong Uptrend" : trendState == 1 ? "Uptrend" : trendState == -1 ? "Downtrend" : trendState == -2 ? "Strong Downtrend" : "No Trend / Range"
int qualityPct = int(math.round(f_clamp(er, 0.0, 1.0) * 100.0))
bool expanding = atr > atr[slopeLen]

// ── VOLUME CONFIRMATION (borrowed-volume aware) ──
float volSma20 = ta.sma(volEff, 20)
bool volSurge = volOk and not na(volSma20) and volEff > volSma20 * 1.5
float vwmaNum = math.sum(srcPrice * volEff, 20)
float vwmaDen = math.sum(volEff, 20)
float vwmaVal = vwmaDen > 0 ? vwmaNum / vwmaDen : srcPrice
float smaVal20 = ta.sma(srcPrice, 20)
float volBias = vwmaVal - smaVal20
bool volUp = volOk and volBias >= 0
bool volDn = volOk and volBias < 0
string volTxt = not volOk ? "no volume" : (volBias > 0 ? "supports up" : volBias < 0 ? "supports down" : "neutral") + (volSurge ? " · surge" : "")
color volCellC = not volOk ? cDim : volBias > 0 ? uiBull : volBias < 0 ? uiBear : cDim

// ── EQUILIBRIUM-DISTANCE DIVERGENCE (Ichimoku-appropriate momentum read) ──
phPv = ta.pivothigh(high, divLb, divLb)
plPv = ta.pivotlow(low, divLb, divLb)
var float lastPHh = na
var float lastPHd = na
var float lastPLl = na
var float lastPLd = na
bool bearDiv = false
bool bullDiv = false
if not na(phPv)
    float dH = high[divLb] - spine[divLb]
    if not na(lastPHh) and high[divLb] > lastPHh and dH < lastPHd
        bearDiv := true
    lastPHh := high[divLb]
    lastPHd := dH
if not na(plPv)
    float dL = spine[divLb] - low[divLb]
    if not na(lastPLl) and low[divLb] < lastPLl and dL < lastPLd
        bullDiv := true
    lastPLl := low[divLb]
    lastPLd := dL

// ── VALIDATED CHANNEL BREAKOUT (displacement + body + volume + anti-wick) ──
float barRange = math.max(high - low, atrSafe * 0.01)
float bodyFrac = math.abs(close - open) / barRange
float volRatio = (volOk and not na(volSma20) and volSma20 > 0) ? volEff / volSma20 : 1.0
bool rawUpBreak = close > rangeHigh and close[1] <= rangeHigh[1]
bool rawDnBreak = close < rangeLow and close[1] >= rangeLow[1]
float upDisp = (close - rangeHigh) / atrSafe
float dnDisp = (rangeLow - close) / atrSafe
bool upHold = (close - low) / barRange >= 0.5        // anti-wick: close holds in upper half
bool dnHold = (high - close) / barRange >= 0.5
bool brkUp = showBrk and rawUpBreak and upDisp >= brkDisp and bodyFrac >= brkBody and volRatio >= brkVol and upHold
bool brkDn = showBrk and rawDnBreak and dnDisp >= brkDisp and bodyFrac >= brkBody and volRatio >= brkVol and dnHold
float brkRawDisp = rawUpBreak ? upDisp : rawDnBreak ? dnDisp : 0.0
int brkScore = (brkUp or brkDn) ? int(math.round(f_clamp((math.min(bodyFrac / brkBody, 2.0) + math.min(volRatio / brkVol, 2.0) + math.min(brkRawDisp / math.max(brkDisp, 0.05), 2.0)) / 6.0, 0.0, 1.0) * 100.0)) : 0

// ───────────────────────────── FUTURE BIAS / PROBABILITY ───────────────────
float bullEv = 0.0
bullEv += trendState > 0 ? trendState * 0.5 : 0.0
bullEv += (trendState > 0 and posInRange < 0.4) ? 0.6 : 0.0      // discount in uptrend = continuation-friendly
bullEv += spineSlope > 0 ? 0.4 : 0.0
bullEv += volUp ? 0.3 : 0.0
bullEv += (volSurge and trendState > 0) ? 0.2 : 0.0
bullEv += brkUp ? 0.5 : 0.0
bullEv += (basisOn and basisAtr > 0) ? 0.4 : 0.0                  // futures premium confirms
bullEv += (basisOn and basisSlope > 0) ? 0.3 : 0.0
bullEv += (vixOn and not vixRising) ? 0.2 : 0.0
float bearEv = 0.0
bearEv += trendState < 0 ? -trendState * 0.5 : 0.0
bearEv += (trendState < 0 and posInRange > 0.6) ? 0.6 : 0.0
bearEv += spineSlope < 0 ? 0.4 : 0.0
bearEv += volDn ? 0.3 : 0.0
bearEv += (volSurge and trendState < 0) ? 0.2 : 0.0
bearEv += brkDn ? 0.5 : 0.0
bearEv += (basisOn and basisAtr < 0) ? 0.4 : 0.0
bearEv += (basisOn and basisSlope < 0) ? 0.3 : 0.0
bearEv += (vixOn and vixRising) ? 0.3 : 0.0
int bullProb = int(math.round(100.0 * bullEv / (bullEv + bearEv + 0.001)))
int bearProb = 100 - bullProb
string convTxt = math.max(bullProb, bearProb) >= 66 ? "Strong" : math.max(bullProb, bearProb) >= 55 ? "Moderate" : "Weak"
color convCol = convTxt == "Strong" ? (bullProb >= bearProb ? uiBull : uiBear) : convTxt == "Moderate" ? uiGold : cDim

// calibration: did a strong directional bias follow through?
var int calTot = 0
var int calHit = 0
var int[] pBar = array.new_int(0)
var float[] pRef = array.new_float(0)
var int[] pDir = array.new_int(0)
if calEnable and barstate.isconfirmed and (bullProb >= 66 or bullProb <= 34)
    array.push(pBar, bar_index)
    array.push(pRef, close)
    array.push(pDir, bullProb >= 66 ? 1 : -1)
if calEnable and array.size(pBar) > 0
    int idx = 0
    while idx < array.size(pBar)
        if bar_index - array.get(pBar, idx) >= calHorizon
            float p0 = array.get(pRef, idx)
            int dr = array.get(pDir, idx)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * atrSafe : mv <= -calMoveATR * atrSafe
            calTot += 1
            calHit += hit ? 1 : 0
            array.remove(pBar, idx)
            array.remove(pRef, idx)
            array.remove(pDir, idx)
        else
            idx += 1
    while array.size(pBar) > 300
        array.shift(pBar)
        array.shift(pRef)
        array.shift(pDir)

// ───────────────────────────── TRADE ENGINE (channel-based) ────────────────
bool htfOKL = (not useHTF) or htfTrend > 0
bool htfOKS = (not useHTF) or htfTrend < 0
bool ltfOKL = (not useLTF) or nz(ltfBias, 0) > 0
bool ltfOKS = (not useLTF) or nz(ltfBias, 0) < 0
bool trendClear = (not requireAlignedTrend) or er > clearThr
bool clearL = trendClear and ((not requireAlignedTrend) or (useHTF ? htfTrend > 0 : trendState >= 2))
bool clearS = trendClear and ((not requireAlignedTrend) or (useHTF ? htfTrend < 0 : trendState <= -2))

// ── EQUAL-HIGH / EQUAL-LOW LIQUIDITY POOLS & TARGETS ──
float phL = ta.pivothigh(high, liqLb, liqLb)
float plL = ta.pivotlow(low, liqLb, liqLb)
var float[] phArr = array.new_float(0)
var float[] plArr = array.new_float(0)
var float[] eqhArr = array.new_float(0)
var float[] eqlArr = array.new_float(0)
if not na(phL)
    if array.size(phArr) > 0
        for i = 0 to array.size(phArr) - 1
            if math.abs(phL - array.get(phArr, i)) <= eqTol * atrSafe
                array.push(eqhArr, math.max(phL, array.get(phArr, i)))
    array.push(phArr, phL)
    if array.size(phArr) > 20
        array.shift(phArr)
if not na(plL)
    if array.size(plArr) > 0
        for i = 0 to array.size(plArr) - 1
            if math.abs(plL - array.get(plArr, i)) <= eqTol * atrSafe
                array.push(eqlArr, math.min(plL, array.get(plArr, i)))
    array.push(plArr, plL)
    if array.size(plArr) > 20
        array.shift(plArr)
if array.size(eqhArr) > 0
    int gi = 0
    while gi < array.size(eqhArr)
        if high > array.get(eqhArr, gi)
            array.remove(eqhArr, gi)
        else
            gi += 1
if array.size(eqlArr) > 0
    int gj = 0
    while gj < array.size(eqlArr)
        if low < array.get(eqlArr, gj)
            array.remove(eqlArr, gj)
        else
            gj += 1
if array.size(eqhArr) > 30
    array.shift(eqhArr)
if array.size(eqlArr) > 30
    array.shift(eqlArr)
float liqAbove = na
float liqBelow = na
if array.size(eqhArr) > 0
    for i = 0 to array.size(eqhArr) - 1
        float lv = array.get(eqhArr, i)
        if lv > close and (na(liqAbove) or lv < liqAbove)
            liqAbove := lv
if array.size(eqlArr) > 0
    for i = 0 to array.size(eqlArr) - 1
        float lv = array.get(eqlArr, i)
        if lv < close and (na(liqBelow) or lv > liqBelow)
            liqBelow := lv

var int   tDir = 0
var float tEntry = na
var float tStop = na
var float tTarget = na
var int   tEntryBar = na
var bool  tActive = false
var int   tWins = 0
var int   tLosses = 0
bool longEntered = false
bool shortEntered = false
bool tWon = false
bool tLost = false
if barstate.isconfirmed
    // manage an open setup at the close (non-repainting)
    if tActive and tDir == 1
        if low <= tStop
            tActive := false
            tLosses += 1
            tLost := true
        else if high >= tTarget
            tActive := false
            tWins += 1
            tWon := true
        else if trendState < 0
            tActive := false
            if close > tEntry
                tWins += 1
                tWon := true
            else
                tLosses += 1
                tLost := true
    else if tActive and tDir == -1
        if high >= tStop
            tActive := false
            tLosses += 1
            tLost := true
        else if low <= tTarget
            tActive := false
            tWins += 1
            tWon := true
        else if trendState > 0
            tActive := false
            if close < tEntry
                tWins += 1
                tWon := true
            else
                tLosses += 1
                tLost := true
    // open a new setup from the channel geometry
    if showTrades and not tActive
        if trendState > 0 and posInRange < 0.25 and close > open and htfOKL and ltfOKL and clearL
            float e = close
            float s = cloudBot - stopBuf * atrSafe
            float tg = (useLiq and not na(liqAbove) and liqAbove > e) ? liqAbove : rangeHigh
            if e > s and (tg - e) >= minRR * (e - s)
                tDir := 1
                tEntry := e
                tStop := s
                tTarget := tg
                tEntryBar := bar_index
                tActive := true
                longEntered := true
        else if trendState < 0 and posInRange > 0.75 and close < open and htfOKS and ltfOKS and clearS
            float e = close
            float s = cloudTop + stopBuf * atrSafe
            float tg = (useLiq and not na(liqBelow) and liqBelow < e) ? liqBelow : rangeLow
            if s > e and (e - tg) >= minRR * (s - e)
                tDir := -1
                tEntry := e
                tStop := s
                tTarget := tg
                tEntryBar := bar_index
                tActive := true
                shortEntered := true
float tradeRR = tActive and not na(tStop) and not na(tEntry) ? (tDir == 1 ? (tTarget - tEntry) / math.max(atrSafe * 0.1, tEntry - tStop) : (tEntry - tTarget) / math.max(atrSafe * 0.1, tStop - tEntry)) : na

// ───────────────────────────── DATA HEALTH ─────────────────────────────────
bool warmedUp = bar_index >= senkouLen + 60
int healthCode = not (high > low) ? 2 : not warmedUp ? 1 : 0
string healthTxt = healthCode == 2 ? "CRITICAL" : healthCode == 1 ? "WARMING" : "OK"

// ───────────────────────────── PLOTS: CLOUD (forward) + SPINE + RANGE ───────
color cloudFill = cloudBull ? color.new(uiBull, 78) : color.new(uiBear, 78)
pA = plot(showCloud ? senkAD : na, "Senkou A", color = color.new(cloudBull ? uiBull : uiBear, 60), offset = disp)
pB = plot(showCloud ? senkBD : na, "Senkou B", color = color.new(cloudBull ? uiBull : uiBear, 60), offset = disp)
fill(pA, pB, color = showCloud ? cloudFill : na)

color railC = trendState > 0 ? color.new(uiBull, 25) : trendState < 0 ? color.new(uiBear, 25) : color.new(cDim, 45)
var int trendDir = 0
if trendState > 0
    trendDir := 1
else if trendState < 0
    trendDir := -1
color spineC = trendDir > 0 ? uiBull : trendDir < 0 ? uiBear : uiGold
pSpine = plot(spineDisp, "Equilibrium spine", color = color.new(spineC, 0), linewidth = 2)
pHi = plot(rangeHighD, "Range high", color = railC, linewidth = 1)
pLo = plot(rangeLowD,  "Range low",  color = railC, linewidth = 1)
pHi2 = plot(showAdvanced ? rangeHi2D : na, "Outer high", color = color.new(trendState > 0 ? uiBull : trendState < 0 ? uiBear : cDim, 70))
pLo2 = plot(showAdvanced ? rangeLo2D : na, "Outer low", color = color.new(trendState > 0 ? uiBull : trendState < 0 ? uiBear : cDim, 70))

// trend-coloured band, split at the equilibrium: upper half = premium, lower half = discount
color upHalfC = not showZones ? na : trendState < 0 ? color.new(uiBear, 76) : trendState > 0 ? color.new(uiBull, 90) : color.new(cDim, 93)
color loHalfC = not showZones ? na : trendState > 0 ? color.new(uiBull, 76) : trendState < 0 ? color.new(uiBear, 90) : color.new(cDim, 93)
fill(pHi, pSpine, color = upHalfC)
fill(pSpine, pLo, color = loHalfC)

// support / resistance level: the trend's invalidation, drawn as a right-side line
float invalLevel = trendState > 0 ? cloudBotD : trendState < 0 ? cloudTopD : na
var line srLine = na
var label srLabel = na
if barstate.islast
    line.delete(srLine)
    label.delete(srLabel)
    if showSR and trendState != 0 and not na(invalLevel)
        color srC = trendState > 0 ? uiBull : uiBear
        srLine := line.new(bar_index - 1, invalLevel, bar_index + 9, invalLevel, xloc = xloc.bar_index, color = color.new(srC, 0), width = 2)
        srLabel := label.new(bar_index + 9, invalLevel, (trendState > 0 ? "Support " : "Resistance ") + str.tostring(math.round_to_mintick(invalLevel)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(srC, 10), textcolor = color.white, size = size.small)

// 3× / 5× / 15× equilibrium support/resistance levels (colour-coded, legended)
var line[] hsLines = array.new_line(0)
var label[] hsLabels = array.new_label(0)
if barstate.islast
    if array.size(hsLines) > 0
        for k = 0 to array.size(hsLines) - 1
            line.delete(array.get(hsLines, k))
        array.clear(hsLines)
    if array.size(hsLabels) > 0
        for k = 0 to array.size(hsLabels) - 1
            label.delete(array.get(hsLabels, k))
        array.clear(hsLabels)
    if showHtfSR
        float[] hsLv = array.from(eq3, eq5, eq15)
        int[]   hsMl = array.from(3, 5, 15)
        for k = 0 to 2
            float v = array.get(hsLv, k)
            int m = array.get(hsMl, k)
            if not na(v)
                bool sup = close >= v
                color rc = sup ? uiBull : uiBear
                int w = m == 15 ? 3 : m == 5 ? 2 : 1
                line ln = line.new(bar_index, v, bar_index + 9, v, xloc = xloc.bar_index, color = color.new(rc, 0), width = w)
                array.push(hsLines, ln)
                label lb = label.new(bar_index + 9, v, str.tostring(m) + "× Eq  " + str.tostring(math.round_to_mintick(v)) + (sup ? "  · support" : "  · resistance"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(rc, 12), textcolor = color.white, size = size.small)
                array.push(hsLabels, lb)

// equal-high / equal-low liquidity pools (nearest unswept above & below)
var line liqLnA = na
var line liqLnB = na
var label liqLbA = na
var label liqLbB = na
if barstate.islast
    line.delete(liqLnA)
    line.delete(liqLnB)
    label.delete(liqLbA)
    label.delete(liqLbB)
    if showLiq and not na(liqAbove)
        liqLnA := line.new(bar_index - 1, liqAbove, bar_index + 9, liqAbove, xloc = xloc.bar_index, color = color.new(#26c6da, 20), style = line.style_dotted, width = 1)
        liqLbA := label.new(bar_index + 9, liqAbove, "EQH liq  " + str.tostring(math.round_to_mintick(liqAbove)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#00838f, 10), textcolor = color.white, size = size.tiny)
    if showLiq and not na(liqBelow)
        liqLnB := line.new(bar_index - 1, liqBelow, bar_index + 9, liqBelow, xloc = xloc.bar_index, color = color.new(#26c6da, 20), style = line.style_dotted, width = 1)
        liqLbB := label.new(bar_index + 9, liqBelow, "EQL liq  " + str.tostring(math.round_to_mintick(liqBelow)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#00838f, 10), textcolor = color.white, size = size.tiny)

// ───────────────────────────── TRADE VISUALS ───────────────────────────────
plotshape(showTrades and longEntered, "Long setup", style = shape.labelup, location = location.belowbar, color = color.new(uiBull, 0), text = "LONG", textcolor = color.white, size = size.large)
plotshape(showTrades and shortEntered, "Short setup", style = shape.labeldown, location = location.abovebar, color = color.new(uiBear, 0), text = "SHORT", textcolor = color.white, size = size.large)
plotshape(showTrades and showAdvanced and tWon, "Target hit", style = shape.xcross, location = location.belowbar, color = color.new(uiBull, 0), size = size.tiny)
plotshape(showTrades and showAdvanced and tLost, "Stop hit", style = shape.xcross, location = location.abovebar, color = color.new(uiBear, 0), size = size.tiny)
bool ichiFlipUp = cloudBull and not cloudBull[1]
bool ichiFlipDn = not cloudBull and cloudBull[1]
plotshape(showIchiTrend and ichiFlipUp, "Ichimoku turned +", style = shape.triangleup, location = location.belowbar, color = color.new(uiBull, 0), size = size.tiny)
plotshape(showIchiTrend and ichiFlipDn, "Ichimoku turned -", style = shape.triangledown, location = location.abovebar, color = color.new(uiBear, 0), size = size.tiny)

var line tlE = na
var line tlS = na
var line tlT = na
var label tlLbl = na
if showTrades and barstate.islast
    line.delete(tlE)
    line.delete(tlS)
    line.delete(tlT)
    label.delete(tlLbl)
    if tActive
        tlE := line.new(tEntryBar, tEntry, bar_index + 6, tEntry, xloc = xloc.bar_index, color = color.new(uiGold, 10), style = line.style_solid, width = 1)
        tlS := line.new(tEntryBar, tStop, bar_index + 6, tStop, xloc = xloc.bar_index, color = color.new(uiBear, 10), style = line.style_dashed, width = 1)
        tlT := line.new(tEntryBar, tTarget, bar_index + 6, tTarget, xloc = xloc.bar_index, color = color.new(uiBull, 10), style = line.style_dashed, width = 1)
        tlLbl := label.new(bar_index + 6, tTarget, "target", xloc = xloc.bar_index, style = label.style_label_left, size = size.tiny, textcolor = uiBull, color = color.new(cPanel, 30))

// ───────────────────────────── FORWARD CONE (advanced) ─────────────────────
var line coneUp = na
var line coneDn = na
var line coneMid = na
if showAdvanced and barstate.islast
    line.delete(coneUp)
    line.delete(coneDn)
    line.delete(coneMid)
    float projMid = spine + spineSlope / slopeLen * disp
    float widen = width * math.sqrt(1.0 + disp / 10.0)
    coneMid := line.new(bar_index, spine, bar_index + disp, projMid, xloc = xloc.bar_index, color = color.new(uiGold, 40), style = line.style_dashed)
    coneUp := line.new(bar_index, rangeHigh, bar_index + disp, projMid + widen, xloc = xloc.bar_index, color = color.new(cDim, 50), style = line.style_dotted)
    coneDn := line.new(bar_index, rangeLow, bar_index + disp, projMid - widen, xloc = xloc.bar_index, color = color.new(cDim, 50), style = line.style_dotted)

// ───────────────────────────── ALERTS ──────────────────────────────────────
bool enterBuyZone = trendState > 0 and posInRange < 0.25 and not (posInRange[1] < 0.25)
bool enterSellZone = trendState < 0 and posInRange > 0.75 and not (posInRange[1] > 0.75)
plotshape(showSignals and enterBuyZone, "Buy signal", style = shape.triangleup, location = location.belowbar, color = color.new(uiBull, 0), text = "Buy", textcolor = cTxt, size = size.normal)
plotshape(showSignals and enterSellZone, "Sell signal", style = shape.triangledown, location = location.abovebar, color = color.new(uiBear, 0), text = "Sell", textcolor = cTxt, size = size.normal)
plotshape(showDiv and bearDiv, "Bearish divergence", style = shape.triangledown, location = location.abovebar, color = color.new(#ff6d00, 0), text = "Div", textcolor = cTxt, size = size.tiny)
plotshape(showDiv and bullDiv, "Bullish divergence", style = shape.triangleup, location = location.belowbar, color = color.new(#ff6d00, 0), text = "Div", textcolor = cTxt, size = size.tiny)
plotshape(brkUp, "Validated breakout up", style = shape.diamond, location = location.belowbar, color = color.new(uiBull, 0), text = "Break", textcolor = cTxt, size = size.tiny)
plotshape(brkDn, "Validated breakout down", style = shape.diamond, location = location.abovebar, color = color.new(uiBear, 0), text = "Break", textcolor = cTxt, size = size.tiny)

// zone-signal calibration: do the Buy/Sell zone triggers actually follow through?
var int sigTot = 0
var int sigHit = 0
var int[] sBar = array.new_int(0)
var float[] sRef = array.new_float(0)
var int[] sDir = array.new_int(0)
if calEnable and barstate.isconfirmed and (enterBuyZone or enterSellZone)
    array.push(sBar, bar_index)
    array.push(sRef, close)
    array.push(sDir, enterBuyZone ? 1 : -1)
if array.size(sBar) > 0
    int si = 0
    while si < array.size(sBar)
        if bar_index - array.get(sBar, si) >= calHorizon
            float p0 = array.get(sRef, si)
            int dr = array.get(sDir, si)
            float mv = close - p0
            bool hit = dr == 1 ? mv >= calMoveATR * atrSafe : mv <= -calMoveATR * atrSafe
            sigTot += 1
            sigHit += hit ? 1 : 0
            array.remove(sBar, si)
            array.remove(sRef, si)
            array.remove(sDir, si)
        else
            si += 1
bool flipUp = trendState > 0 and trendState[1] <= 0
bool flipDn = trendState < 0 and trendState[1] >= 0
alertcondition(enterBuyZone, "Price entered BUY zone (uptrend)", "Ichimoku Eq Channel: price in the discount buy zone during an uptrend")
alertcondition(enterSellZone, "Price entered SELL zone (downtrend)", "Ichimoku Eq Channel: price in the premium sell zone during a downtrend")
alertcondition(flipUp, "Trend flipped UP", "Ichimoku Eq Channel: trend turned up")
alertcondition(flipDn, "Trend flipped DOWN", "Ichimoku Eq Channel: trend turned down")
alertcondition(brkUp, "Validated breakout UP", "Ichimoku Eq Channel: confirmed breakout above the channel (displacement + body + volume)")
alertcondition(brkDn, "Validated breakout DOWN", "Ichimoku Eq Channel: confirmed breakout below the channel (displacement + body + volume)")
alertcondition(longEntered, "Long setup", "Ichimoku Eq Channel: long setup — buy zone, stop below cloud, target range high")
alertcondition(shortEntered, "Short setup", "Ichimoku Eq Channel: short setup — sell zone, stop above cloud, target range low")
alertcondition(tWon, "Target reached", "Ichimoku Eq Channel: setup reached its target")
alertcondition(tLost, "Stop reached", "Ichimoku Eq Channel: setup hit its stop")

// ───────────────────────────── VERDICT + DASHBOARD ─────────────────────────
string actionTxt = trendState > 0 ? (zoneTxt == "Discount" ? "Uptrend — price in BUY zone" : "Uptrend — wait for the buy zone") : trendState < 0 ? (zoneTxt == "Premium" ? "Downtrend — price in SELL zone" : "Downtrend — wait for the sell zone") : "No trend — stand aside"
color stateC = trendState > 0 ? uiBull : trendState < 0 ? uiBear : cDim

var table dash = table.new(f_pos(dashPosStr), 5, 14, border_width = 0, frame_width = 1)
if showVerdict and barstate.islast
    table.set_bgcolor(dash, cPanel)
    table.set_frame_color(dash, cFrame)
    table.set_border_color(dash, cBord)
    // ---------- precompute ----------
    bool htfAligned = (htfTrend > 0 and trendState > 0) or (htfTrend < 0 and trendState < 0)
    string htfTxt = not useHTF ? "off" : htfTrend > 0 ? "Up" + (trendState > 0 ? " — aligned" : trendState < 0 ? " — conflict" : "") : htfTrend < 0 ? "Down" + (trendState < 0 ? " — aligned" : trendState > 0 ? " — conflict" : "") : "Range — no clear trend"
    color htfCol = not useHTF ? cDim : htfAligned ? (htfTrend > 0 ? uiBull : uiBear) : htfTrend == 0 ? cDim : uiGold
    string tradeTxt = tActive ? (tDir == 1 ? "LONG" : "SHORT") + " · stop " + str.tostring(math.round_to_mintick(tStop)) + " · target " + str.tostring(math.round_to_mintick(tTarget)) + (na(tradeRR) ? "" : " · " + str.tostring(math.round(tradeRR * 10) / 10.0) + "R") : showTrades ? "none — wait for a zone" : "off"
    string convFull = convTxt + "    ▲" + str.tostring(bullProb) + "%   ▼" + str.tostring(bearProb) + "%"
    int tradeN = tWins + tLosses
    string swTxt = tradeN < 5 ? "warming up" : str.tostring(math.round(tWins * 100.0 / tradeN)) + "%  (" + str.tostring(tradeN) + " trades)"
    [wlo, whi] = f_wilson(calHit, calTot)
    string calTxt = calTot < 5 ? "warming up" : str.tostring(math.round(calHit * 100.0 / calTot)) + "%  [" + (na(wlo) ? "—" : str.tostring(math.round(wlo * 100)) + "-" + str.tostring(math.round(whi * 100))) + "]"
    [sglo, sghi] = f_wilson(sigHit, sigTot)
    string sigTxt = sigTot < 5 ? "warming up" : str.tostring(math.round(sigHit * 100.0 / sigTot)) + "%  [" + (na(sglo) ? "—" : str.tostring(math.round(sglo * 100)) + "-" + str.tostring(math.round(sghi * 100))) + "]"
    string imTxt = (basisOn ? "basis " + str.tostring(math.round(basisAtr * 100) / 100.0) : "") + (basisOn and vixOn ? " · " : "") + (vixOn ? "VIX×" + str.tostring(math.round(vixNorm * 100) / 100.0) : "") + (not basisOn and not vixOn ? healthTxt : "")
    color ic1  = ich1 > 0 ? uiBull : ich1 < 0 ? uiBear : cAlt
    color ic3  = ich3 > 0 ? uiBull : ich3 < 0 ? uiBear : cAlt
    color ic5  = ich5 > 0 ? uiBull : ich5 < 0 ? uiBear : cAlt
    color ic15 = ich15 > 0 ? uiBull : ich15 < 0 ? uiBear : cAlt
    color tc1  = ich1 == 0 ? cDim : color.white
    color tc3  = ich3 == 0 ? cDim : color.white
    color tc5  = ich5 == 0 ? cDim : color.white
    color tc15 = ich15 == 0 ? cDim : color.white
    // ---------- header ----------
    color hb = color.new(stateC, 0)
    table.cell(dash, 0, 0, "ICHIMOKU EQ", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = hb)
    table.cell(dash, 1, 0, "", bgcolor = hb)
    table.cell(dash, 2, 0, "", bgcolor = hb)
    table.cell(dash, 3, 0, "", bgcolor = hb)
    table.cell(dash, 4, 0, stateTxt, text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = hb)
    // ---------- core read ----------
    table.cell(dash, 0, 1, "What to do", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(dash, 1, 1, actionTxt, text_color = stateC, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
    table.cell(dash, 2, 1, "", bgcolor = cSub)
    table.cell(dash, 3, 1, "", bgcolor = cSub)
    table.cell(dash, 4, 1, "", bgcolor = cSub)
    table.cell(dash, 0, 2, "Ichimoku", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Ichimoku cloud trend at 1× (chart), 3×, 5× and 15× the chart timeframe. ▲ price above the cloud, ▼ below. Solid colour = strong (price clear of the cloud and cloud bullish/bearish the same way), faded = price beyond the cloud but cloud the other way.")
    table.cell(dash, 1, 2, "1× " + f_iar(ich1), text_color = tc1, text_size = size.small, bgcolor = ic1)
    table.cell(dash, 2, 2, "3× " + f_iar(ich3), text_color = tc3, text_size = size.small, bgcolor = ic3)
    table.cell(dash, 3, 2, "5× " + f_iar(ich5), text_color = tc5, text_size = size.small, bgcolor = ic5)
    table.cell(dash, 4, 2, "15× " + f_iar(ich15), text_color = tc15, text_size = size.small, bgcolor = ic15)
    table.cell(dash, 0, 3, "Higher TF", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Trades are only taken in the higher timeframe's direction. 'Conflict' or 'Range' means setups are blocked.")
    table.cell(dash, 1, 3, htfTxt, text_color = htfCol, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
    table.cell(dash, 2, 3, "", bgcolor = cSub)
    table.cell(dash, 3, 3, "", bgcolor = cSub)
    table.cell(dash, 4, 3, "", bgcolor = cSub)
    table.cell(dash, 0, 4, "Price zone", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 1, 4, zoneTxt, text_color = zoneTxt == "Discount" ? uiBull : zoneTxt == "Premium" ? uiBear : cDim, text_size = size.small, text_halign = text.align_left, bgcolor = cAlt)
    table.cell(dash, 2, 4, "", bgcolor = cAlt)
    table.cell(dash, 3, 4, "", bgcolor = cAlt)
    table.cell(dash, 4, 4, "", bgcolor = cAlt)
    table.cell(dash, 0, 5, "Conviction", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Blended directional bias from trend, zone, slope, volume, breakouts and inter-market. ▲/▼ are the bull/bear probabilities.")
    table.cell(dash, 1, 5, convFull, text_color = convCol, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
    table.cell(dash, 2, 5, "", bgcolor = cSub)
    table.cell(dash, 3, 5, "", bgcolor = cSub)
    table.cell(dash, 4, 5, "", bgcolor = cSub)
    table.cell(dash, 0, 6, "Trade", text_color = cDim, text_size = size.small, bgcolor = cAlt)
    table.cell(dash, 1, 6, tradeTxt, text_color = tActive ? (tDir == 1 ? uiBull : uiBear) : cDim, text_size = size.small, text_halign = text.align_left, bgcolor = cAlt)
    table.cell(dash, 2, 6, "", bgcolor = cAlt)
    table.cell(dash, 3, 6, "", bgcolor = cAlt)
    table.cell(dash, 4, 6, "", bgcolor = cAlt)
    table.cell(dash, 0, 7, "Equilibrium", text_color = cDim, text_size = size.small, bgcolor = cSub)
    table.cell(dash, 1, 7, str.tostring(math.round_to_mintick(spine)), text_color = cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
    table.cell(dash, 2, 7, "", bgcolor = cSub)
    table.cell(dash, 3, 7, "", bgcolor = cSub)
    table.cell(dash, 4, 7, "", bgcolor = cSub)
    // ---------- advanced stats ----------
    if showAdvanced
        table.cell(dash, 0, 8, "Setup win", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Past-only: share of channel setups that reached target before stop, on this symbol. Not a backtest; context only.")
        table.cell(dash, 1, 8, swTxt, text_color = tradeN < 5 ? cDim : cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cAlt)
        table.cell(dash, 2, 8, "", bgcolor = cAlt)
        table.cell(dash, 3, 8, "", bgcolor = cAlt)
        table.cell(dash, 4, 8, "", bgcolor = cAlt)
        table.cell(dash, 0, 9, "Signal win", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Past-only: how often a Buy/Sell zone trigger was followed by a " + str.tostring(calMoveATR) + "x ATR move in its direction within " + str.tostring(calHorizon) + " bars. Wilson 95% CI.")
        table.cell(dash, 1, 9, sigTxt, text_color = sigTot < 5 ? cDim : cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
        table.cell(dash, 2, 9, "", bgcolor = cSub)
        table.cell(dash, 3, 9, "", bgcolor = cSub)
        table.cell(dash, 4, 9, "", bgcolor = cSub)
        table.cell(dash, 0, 10, "Follow-thru", text_color = cDim, text_size = size.small, bgcolor = cAlt, tooltip = "Past-only: how often a strong bias was followed by a " + str.tostring(calMoveATR) + "x ATR move within " + str.tostring(calHorizon) + " bars. Wilson 95% CI.")
        table.cell(dash, 1, 10, calTxt, text_color = calTot < 5 ? cDim : cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cAlt)
        table.cell(dash, 2, 10, "", bgcolor = cAlt)
        table.cell(dash, 3, 10, "", bgcolor = cAlt)
        table.cell(dash, 4, 10, "", bgcolor = cAlt)
        table.cell(dash, 0, 11, "Volume", text_color = cDim, text_size = size.small, bgcolor = cSub, tooltip = "Volume-weighted price vs its simple average (borrowed-volume aware). 'Surge' = volume above 1.5x its 20-bar average.")
        table.cell(dash, 1, 11, volTxt, text_color = volCellC, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
        table.cell(dash, 2, 11, "", bgcolor = cSub)
        table.cell(dash, 3, 11, "", bgcolor = cSub)
        table.cell(dash, 4, 11, "", bgcolor = cSub)
        table.cell(dash, 0, 12, "Channel", text_color = cDim, text_size = size.small, bgcolor = cAlt)
        table.cell(dash, 1, 12, (expanding ? "Expanding" : "Compressing") + " · quality " + str.tostring(qualityPct) + "%", text_color = cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cAlt)
        table.cell(dash, 2, 12, "", bgcolor = cAlt)
        table.cell(dash, 3, 12, "", bgcolor = cAlt)
        table.cell(dash, 4, 12, "", bgcolor = cAlt)
        table.cell(dash, 0, 13, basisOn or vixOn ? "Inter-market" : "Data", text_color = cDim, text_size = size.small, bgcolor = cSub)
        table.cell(dash, 1, 13, imTxt, text_color = cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cSub)
        table.cell(dash, 2, 13, "", bgcolor = cSub)
        table.cell(dash, 3, 13, "", bgcolor = cSub)
        table.cell(dash, 4, 13, "", bgcolor = cSub)

// ───────────────────────────── IDENTITY STRIP ──────────────────────────────
var table idTbl = table.new(position.bottom_center, 1, 1)
if showId and barstate.islast
    table.cell(idTbl, 0, 0, "Adaptive Ichimoku Equilibrium Channel   /   " + syminfo.ticker + "   /   " + timeframe.period, text_color = cDim, text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────────── EXP_* EXPORTS ───────────────────────────────
float frRate = calTot > 0 ? calHit / float(calTot) : na
plot(trendState,            "EXP_TrendState",   color = color.new(color.gray, 100), display = display.data_window)
plot(spine,                 "EXP_Equilibrium",  color = color.new(color.gray, 100), display = display.data_window)
plot(posInRange,            "EXP_PosInRange",   color = color.new(color.gray, 100), display = display.data_window)
plot(bullProb,              "EXP_BullProb",     color = color.new(color.gray, 100), display = display.data_window)
plot(volOk ? volBias : na,  "EXP_VolBias",      color = color.new(color.gray, 100), display = display.data_window)
plot(bearDiv ? -1 : bullDiv ? 1 : 0, "EXP_Divergence", color = color.new(color.gray, 100), display = display.data_window)
plot(sigTot >= 5 ? sigHit * 100.0 / sigTot : na, "EXP_SignalWinRate", color = color.new(color.gray, 100), display = display.data_window)
plot(brkUp ? brkScore : brkDn ? -brkScore : 0, "EXP_BreakoutQuality", color = color.new(color.gray, 100), display = display.data_window)
````
