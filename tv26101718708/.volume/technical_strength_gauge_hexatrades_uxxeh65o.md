# Technical Strength Gauge [HexaTrades]

- url: https://www.tradingview.com/script/uxxeh65O-Technical-Strength-Gauge-HexaTrades/
- type: indicator
- pine_id: PUB;b6e5c5bf15334b99b53cdccd82644314
- version: 1.0

## Description

Most traders watch a handful of indicators and weigh them by gut feel. Technical Strength Meter does this objectively and at scale: It evaluates 74 indicator votes across 34 technical indicator families, turns each into a single Buy / Neutral / Sell vote, and aggregates those votes into three colour-graded strength gauges, each scored 0-100: Leading, Lagging, and an overall Summary. On top sits an analytics row that translates the raw votes into market context: regime, trend strength, volatility, confidence, probability and an A+ to D quality grade.


[b]HOW IT WORKS - THE VOTING ENGINE[/b]

[b]Each indicator votes[/b]: All 74 indicators are evaluated, and each casts exactly one vote:
   +1  Buy      (its bullish condition is met)
    0  Neutral  (no clear signal)
   -1  Sell     (its bearish condition is met)
The voting rule is matched to the indicator's nature:

   • Oscillators vote by mean reversion, e.g. RSI must be below the oversold level AND turning back up to vote Buy; above the overbought level AND turning down to vote Sell; otherwise Neutral. The same "stretched, then turning" logic drives Stochastic, CCI, Williams %R, MFI, Ultimate, Stochastic RSI, TSI, Fisher and CMO.

   • Moving averages vote by price location: close above the MA = Buy, below = Sell. This repeats for 10 MA families across 5 lengths (50 votes in total).

   • Trend tools vote on their own state: Supertrend direction, price vs the Ichimoku cloud, +DI vs -DI, Parabolic SAR side, Linear-Regression slope, Vortex, and so on.

[b]Votes are grouped & averaged [/b]: The votes split into a Leading set (early movers) and a Lagging set (trend confirmers). Each set is averaged into one number from -1 to +1, and the Summary is the average of the two halves.

[b]Weighting & exclusions:[/b]  By default every vote counts equally, but each gauge is a weighted average: you can scale whole categories (Oscillators / MAs / Trend) up or down, or switch any indicator off. A disabled indicator (weight 0) is dropped from both the average and the counts; it is NOT silently counted as Neutral. On symbols with no volume data, volume-based votes (VWMA, MFI) are auto-excluded the same way, so they don't dilute the score.

[b]Score & verdict :[/b] Each -1…+1 average is rescaled to a 0-100 score and mapped to a five-step verdict:
   0-25  Strong Sell  ·  25-45 Sell  ·  45-55 Neutral  ·  55-75 Buy  ·  75-100 Strong Buy
(Internally: rating <= -0.5 = Strong Sell, <= -0.1 = Sell, between = Neutral, >= 0.1 = Buy, >= 0.5 = Strong Buy.)


[b] ⭐️THREE GAUGES[/b]

• [b]LEADING (16 indicators)[/b]  momentum / early-mover tools that tend to turn before price: RSI, Stochastic, CCI, Williams %R, MFI, ROC, Momentum, Ultimate Oscillator, Awesome Oscillator, Stochastic RSI, TSI, Fisher Transform, CMO,  plus Bollinger, Donchian and Aroon.

[b]• LAGGING (58 indicators): [/b]trend-followers that confirm an established move: MACD histogram, 50 moving-average votes (10 MA types  EMA, SMA, VWMA, WMA, HMA, RMA, ALMA, DEMA, TEMA, KAMA  across 5 lengths), and Supertrend, ADX, Ichimoku, Parabolic SAR, Linear Regression, Vortex and DMI.

[b]• SUMMARY:[/b]  the balance of the Leading and Lagging halves; your one-number bias.

 When the two halves agree, conviction is high; when Leading leads Lagging, a turn may be forming.

https://www.tradingview.com/x/TGwp6vd1/


 [b]⭐️ANALYTICS ROW[/b] 

[b]• MARKET REGIME :[/b] Strong Bull / Bull / Sideways / Bear / Strong Bear. Combines five trend engines (Supertrend, Ichimoku, DMI, stacked-MA alignment, LinReg slope) into a directional bias, then gates it with ADX: low ADX = Sideways; high ADX + strong bias = a "Strong" trend.

•[b] TREND STRENGTH % :[/b] how strong and aligned the trend is, blending the size of that directional bias with ADX magnitude.

[b]• VOLATILITY : [/b]Low / Normal / High / Extreme, from the percentile rank of Bollinger Band width over the last 100 bars (so it adapts to each symbol).

[b]• CONFIDENCE % :[/b]  how trustworthy the current reading is: a blend of decisiveness (how far Summary is from neutral), Leading–Lagging agreement, and vote consistency.

• [b]BULL / BEAR PROBABILITY % : [/b]the weighted balance of all votes, always summing to 100.

•[b] SIGNAL-QUALITY GRADE :[/b] A+ to D, a composite of Confidence, Trend Strength and favourable volatility, for a quick "is this a clean setup?" read.

 https://www.tradingview.com/x/tCwdFW2v/


[b]⭐️ SETTINGS GUIDE[/b]

Layout : anchor position, total width, summary size, height, compact mode, per-gauge show/hide, the five MA lengths, and toggles for the analytics row and breakdown table.

Signals & timeframe: analysis timeframe (MTF), confirm-on-close, Strong and normal Buy/Sell arrows, the signal trigger levels, the ADX whipsaw filter, background tint and the volatility alert.

Indicator periods : lengths for RSI, Stochastic, CCI, MFI, Williams %R, ROC, Momentum, ADX/DMI, Bollinger and MACD.

Overbought / Oversold: the OB/OS thresholds for RSI, Stochastic, MFI, Ultimate Oscillator, CCI and Williams %R.

Analytics thresholds:  the ADX bands for regime and the percentile bands for volatility.

Weights & toggles:  category weights (Oscillators / MAs / Trend) and an on/off switch for all 34 named indicators.

Colors: the full Strong-Sell to Strong-Buy palette and table colours.

Signals are calculated using closed-bar data when "Confirm on Close" is enabled. The indicator does not intentionally use future data or repaint historical signals.


[b]⭐️How to use[/b]


Context first: read Market Regime and Volatility. "Strong" regimes favour trend-following; "Sideways" favours mean-reversion or standing aside; "Extreme" volatility means wider stops and more false breaks.

Bias: read the Summary gauge and its 0–100 score: your single-number lean.

Alignment:compare Leading vs Lagging. Both same side = confirmed conviction; Leading 
ahead of Lagging = possible early turn; disagreement = mixed/choppy, so smaller size or wait.

Quality: check Confidence % and the A+…D Grade. An A-grade Strong Buy in a Strong Bull regime ≠ a borderline Buy in chop.

Execute: use the Buy/Sell arrows as visual triggers, or attach the built-in alerts.

Make it yours: shorter periods/lower triggers for scalping, longer/higher for swing; re-weight or disable indicators you don't trust; set an Analysis timeframe to read a higher TF from a lower chart.


[b]⭐️ BEST USE CASES[/b]

[b]Best suited for:[/b]
• Trend confirmation and trend-following strategies
• Market regime analysis (Bull, Bear, Sideways)
• Multi-indicator consensus and bias assessment
• Swing trading and position trading
• Day trading and intraday market analysis
• Higher-timeframe directional bias and confirmation
• Identifying alignment between momentum and trend indicators

[b]Not designed for:[/b]
• Standalone trade entries without additional analysis
• Predicting exact tops, bottoms, or reversals
• Guaranteed market forecasts or future price predictions
• Fully automated trading systems without validation
• Replacing risk management, position sizing, or trading plans

Technical Strength Meter combines the signals of 74 widely used technical indicators into a single, transparent decision-support framework. By separating indicators into Leading and Lagging categories, the indicator helps traders identify potential turning points, confirm established trends, and understand the overall market bias at a glance. Rather than relying on a single indicator, it provides a structured consensus view supported by market regime, volatility, confidence, probability, and signal-quality analysis. Whether used for scalping, day trading, or swing trading, the goal is to simplify complex technical data into actionable market context while keeping every vote visible and explainable.


We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.


[i] For educational and informational purposes only. This indicator is designed to assist technical analysis and should not be considered financial, investment, or trading advice.[/i]

## Source Code

````pine
//@version=6
indicator("Technical Strength Gauge", "HexaTrades Technical Strength Gauge", overlay = true, calc_bars_count = 3000)

// ============================ INPUTS ==========
grpL  = "Layout"
posOpt   = input.string("Top right", "Gauge anchor position", group = grpL,
     options = ["Top left","Top center","Top right","Middle left","Middle center","Middle right","Bottom left","Bottom center","Bottom right"],
     tooltip = "Where the gauges are pinned on screen. They stay fixed there when you scroll or zoom.", display = display.none)
groupPct = input.float(40, "Total width (%)",  minval = 20, maxval = 100, step = 1, group = grpL, display = display.none)
sumWidth = input.float(1.0, "Summary gauge size (× others)", minval = 0.3, maxval = 1.0, step = 0.05, group = grpL, display = display.none)
nSeg     = 15   // meter segments (fixed default)
hScale   = input.float(0.6, "Height scale",    minval = 0.3, maxval = 2.5, step = 0.05, group = grpL, display = display.none)
compactMode  = input.bool(false, "Compact mode (smaller, hides breakdown)", group = grpL, display = display.none)
showLead = input.bool(true, "Leading gauge", group = grpL, inline = "g", display = display.none)
showLag  = input.bool(true, "Lagging gauge", group = grpL, inline = "g", display = display.none)
showSum  = input.bool(true, "Summary gauge", group = grpL, inline = "g", display = display.none)
maL1 = input.int(9,   "MA length 1", minval = 1, group = grpL, inline = "ma1", display = display.none)
maL2 = input.int(21,  "MA length 2", minval = 1, group = grpL, inline = "ma1", display = display.none)
maL3 = input.int(50,  "MA length 3", minval = 1, group = grpL, inline = "ma2", display = display.none)
maL4 = input.int(100, "MA length 4", minval = 1, group = grpL, inline = "ma2", display = display.none)
maL5 = input.int(200, "MA length 5", minval = 1, group = grpL, inline = "ma2", display = display.none)
showAnalytics = input.bool(true, "Show analytics row (regime / scores)", group = grpL, display = display.none)
showInfo  = input.bool(true, "Show indicators breakdown", group = grpL, display = display.none)
infoPosOpt = input.string("Bottom right", "Breakdown position", options = ["Top left","Top right","Bottom left","Bottom right"], group = grpL, display = display.none)

grpS  = "Signals & timeframe"
analysisTF  = input.timeframe("", "Analysis timeframe (blank = chart)", group = grpS,
     tooltip = "Compute the ratings on this timeframe. Blank = current chart timeframe.", display = display.none)
confirmClose = input.bool(true, "Confirm on bar close (no intrabar flicker)", group = grpS,
     tooltip = "Freeze the forming candle to its last closed reading so the verdict and signals don't repaint until the bar closes.", display = display.none)
showMarkers = input.bool(true,  "Strong Buy/Sell arrows on price", group = grpS, display = display.none)
showNormalArrows = input.bool(false, "Normal Buy/Sell arrows on price", group = grpS, display = display.none)
sigBuy    = input.float(0.1, "Buy/Sell trigger level", minval = 0.02, maxval = 0.9, step = 0.02, group = grpS,
     tooltip = "Summary must cross ± this for a normal arrow/alert. Higher = fewer, more decisive signals.", display = display.none)
sigStrong = input.float(0.5, "Strong trigger level", minval = 0.1, maxval = 0.95, step = 0.05, group = grpS, display = display.none)
chopFilter = input.bool(false, "Filter signals in chop (ADX)", group = grpS,
     tooltip = "Suppress arrows/alerts while ADX is below the level below (ranging market).", display = display.none)
chopAdx    = input.float(20, "Min ADX for signals", minval = 0, maxval = 60, step = 1, group = grpS, display = display.none)
showBg    = input.bool(false, "Color background by Summary regime", group = grpS, display = display.none)
volAlertOn = input.bool(false, "Alert on Extreme volatility", group = grpS, display = display.none)

grpP  = "Indicator periods"
rsiLen   = input.int(14, "RSI",        minval = 1, group = grpP, inline = "p1", display = display.none)
stochLen = input.int(14, "Stochastic", minval = 1, group = grpP, inline = "p1", display = display.none)
cciLen   = input.int(20, "CCI",        minval = 1, group = grpP, inline = "p2", display = display.none)
mfiLen   = input.int(14, "MFI",        minval = 1, group = grpP, inline = "p2", display = display.none)
wprLen   = input.int(14, "Williams %R",minval = 1, group = grpP, inline = "p3", display = display.none)
rocLen   = input.int(9,  "ROC",        minval = 1, group = grpP, inline = "p3", display = display.none)
momLen   = input.int(10, "Momentum",   minval = 1, group = grpP, inline = "p4", display = display.none)
adxLen   = input.int(14, "ADX / DMI",  minval = 1, group = grpP, inline = "p4", display = display.none)
bbLen    = input.int(20, "Bollinger len", minval = 1, group = grpP, inline = "p5", display = display.none)
bbMult   = input.float(2.0, "× mult", minval = 0.1, step = 0.1, group = grpP, inline = "p5", display = display.none)
macdFast = input.int(12, "MACD fast",   minval = 1, group = grpP, inline = "p6", display = display.none)
macdSlow = input.int(26, "slow",        minval = 1, group = grpP, inline = "p6", display = display.none)
macdSig  = input.int(9,  "signal",      minval = 1, group = grpP, inline = "p6", display = display.none)

grpO  = "Overbought / Oversold"
rsiOB   = input.int(70, "RSI OB",   group = grpO, inline = "o1", display = display.none)
rsiOS   = input.int(30, "OS",       group = grpO, inline = "o1", display = display.none)
stochOB = input.int(80, "Stoch OB", group = grpO, inline = "o2", display = display.none)
stochOS = input.int(20, "OS",       group = grpO, inline = "o2", display = display.none)
mfiOB   = input.int(80, "MFI OB",   group = grpO, inline = "o3", display = display.none)
mfiOS   = input.int(20, "OS",       group = grpO, inline = "o3", display = display.none)
uoOB    = input.int(70, "UltOsc OB",group = grpO, inline = "o4", display = display.none)
uoOS    = input.int(30, "OS",       group = grpO, inline = "o4", display = display.none)
cciLevel = input.int(100, "CCI level (±)", group = grpO, display = display.none)
wprOB   = input.int(-20, "W%R OB",  group = grpO, inline = "o5", display = display.none)
wprOS   = input.int(-80, "OS",      group = grpO, inline = "o5", display = display.none)

grpA  = "Analytics thresholds"
adxSideways = input.float(18, "Regime: max ADX for Sideways", minval = 5, maxval = 40, group = grpA, display = display.none)
adxStrong   = input.float(25, "Regime: min ADX for Strong",   minval = 15, maxval = 50, group = grpA, display = display.none)
volLowTh    = input.int(25, "Volatility: Low below %",    minval = 1, maxval = 99, group = grpA, display = display.none)
volNormTh   = input.int(60, "Volatility: Normal below %",  minval = 1, maxval = 99, group = grpA, display = display.none)
volHighTh   = input.int(85, "Volatility: High below %",    minval = 1, maxval = 99, group = grpA, display = display.none)

grpC  = "Colors"
colSSell = input.color(#d23b3b, "Strong sell", group = grpC, display = display.none)
colSell  = input.color(#e8833a, "Sell",        group = grpC, display = display.none)
colNeut  = input.color(#e8b93a, "Neutral",     group = grpC, display = display.none)
colBuy   = input.color(#5abf5a, "Buy",         group = grpC, display = display.none)
colSBuy  = input.color(#2a9d4f, "Strong buy",  group = grpC, display = display.none)
colHdr   = input.color(#3c3f4a, "Header bg",   group = grpC, display = display.none)
colDark  = input.color(#33363f, "Panel bg",    group = grpC, display = display.none)
colTxt   = input.color(#ffffff, "Text",        group = grpC, display = display.none)
colMute  = input.color(#9aa0aa, "Muted text",  group = grpC, display = display.none)

grpW  = "Weights & toggles"
wOsc   = input.float(1.0, "Oscillators weight", minval = 0, maxval = 3, step = 0.1, group = grpW, inline = "w", display = display.none)
wMA    = input.float(1.0, "MAs weight",         minval = 0, maxval = 3, step = 0.1, group = grpW, inline = "w", display = display.none)
wTrend = input.float(1.0, "Trend weight",       minval = 0, maxval = 3, step = 0.1, group = grpW, inline = "w", display = display.none)
// Leading on/off
enRsi   = input.bool(true, "RSI",         group = grpW, inline = "l1", display = display.none)
enStoch = input.bool(true, "Stochastic",  group = grpW, inline = "l1", display = display.none)
enCci   = input.bool(true, "CCI",         group = grpW, inline = "l2", display = display.none)
enWpr   = input.bool(true, "Williams %R", group = grpW, inline = "l2", display = display.none)
enMfi   = input.bool(true, "MFI",         group = grpW, inline = "l3", display = display.none)
enRoc   = input.bool(true, "ROC",         group = grpW, inline = "l3", display = display.none)
enMom   = input.bool(true, "Momentum",    group = grpW, inline = "l4", display = display.none)
enUo    = input.bool(true, "Ultimate",    group = grpW, inline = "l4", display = display.none)
enAo    = input.bool(true, "Awesome",     group = grpW, inline = "l5", display = display.none)
enBb    = input.bool(true, "Bollinger",   group = grpW, inline = "l5", display = display.none)
enDon   = input.bool(true, "Donchian",    group = grpW, inline = "l6", display = display.none)
enAroon = input.bool(true, "Aroon",       group = grpW, inline = "l6", display = display.none)
enSrsi  = input.bool(true, "Stoch RSI",   group = grpW, inline = "l7", display = display.none)
enTsi   = input.bool(true, "TSI",         group = grpW, inline = "l7", display = display.none)
enFish  = input.bool(true, "Fisher",      group = grpW, inline = "l8", display = display.none)
enCmo   = input.bool(true, "CMO",         group = grpW, inline = "l8", display = display.none)
// Lagging on/off
enMacd  = input.bool(true, "MACD Hist", group = grpW, inline = "g0", display = display.none)
enEma   = input.bool(true, "EMA",  group = grpW, inline = "g1", display = display.none)
enSma   = input.bool(true, "SMA",  group = grpW, inline = "g1", display = display.none)
enVwma  = input.bool(true, "VWMA", group = grpW, inline = "g2", display = display.none)
enWma   = input.bool(true, "WMA",  group = grpW, inline = "g2", display = display.none)
enHma   = input.bool(true, "HMA",  group = grpW, inline = "g3", display = display.none)
enRma   = input.bool(true, "RMA",  group = grpW, inline = "g3", display = display.none)
enAlma  = input.bool(true, "ALMA", group = grpW, inline = "g4", display = display.none)
enDema  = input.bool(true, "DEMA", group = grpW, inline = "g4", display = display.none)
enTema  = input.bool(true, "TEMA", group = grpW, inline = "g5", display = display.none)
enKama  = input.bool(true, "KAMA", group = grpW, inline = "g5", display = display.none)
enSt    = input.bool(true, "Supertrend",    group = grpW, inline = "g6", display = display.none)
enAdx   = input.bool(true, "ADX",           group = grpW, inline = "g6", display = display.none)
enIchi  = input.bool(true, "Ichimoku",      group = grpW, inline = "g7", display = display.none)
enSar   = input.bool(true, "Parabolic SAR", group = grpW, inline = "g7", display = display.none)
enLr    = input.bool(true, "LinReg",        group = grpW, inline = "g8", display = display.none)
enVtx   = input.bool(true, "Vortex",        group = grpW, inline = "g8", display = display.none)
enDmi   = input.bool(true, "DMI",           group = grpW, inline = "g9", display = display.none)

// ============ VOTE HELPERS ====================================
// Each indicator votes +1 (buy) / 0 (neutral) / -1 (sell).
vote(buy, sell) => buy ? 1 : sell ? -1 : 0
maVote(m)       => na(m) ? 0 : close > m ? 1 : close < m ? -1 : 0

// custom moving averages (no v6 built-in)
f_dema(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    2 * e1 - e2
f_tema(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    3 * e1 - 3 * e2 + e3
f_kama(src, len) =>
    fast = 2.0 / (2 + 1)
    slow = 2.0 / (30 + 1)
    chg  = math.abs(src - src[len])
    vol  = math.sum(math.abs(src - src[1]), len)
    er   = vol != 0 ? chg / vol : 0.0
    sc   = math.pow(er * (fast - slow) + slow, 2)
    var float k = na
    k := na(k[1]) ? src : k[1] + sc * (src - k[1])
    k

// extra LEADING-oscillator helpers
f_dsmooth(src, l1, l2) => ta.ema(ta.ema(src, l1), l2)
f_cmo(src, len) =>
    m   = src - src[1]
    up  = math.sum(m > 0 ?  m : 0.0, len)
    dn  = math.sum(m < 0 ? -m : 0.0, len)
    den = up + dn
    den != 0 ? 100 * (up - dn) / den : 0.0
f_fisher(len) =>
    src = hl2
    mh  = ta.highest(src, len)
    ml  = ta.lowest(src, len)
    rng = mh - ml
    var float v = 0.0
    v := rng != 0 ? 0.66 * ((src - ml) / rng - 0.5) + 0.67 * nz(v[1]) : nz(v[1])
    v := math.max(math.min(v, 0.999), -0.999)
    var float fish = 0.0
    fish := 0.5 * math.log((1 + v) / (1 - v)) + 0.5 * nz(fish[1])
    fish

// the 10 moving-average-family votes at a given length (all LAGGING).
// VWMA needs volume — on volumeless symbols it votes na (excluded) not a fake neutral.
maFamilyVotes(L, hasVol) =>
    array.from(
         maVote(ta.ema(close, L)),  maVote(ta.sma(close, L)),  hasVol ? maVote(ta.vwma(close, L)) : int(na),
         maVote(ta.wma(close, L)),  maVote(ta.hma(close, L)),  maVote(ta.rma(close, L)),
         maVote(ta.alma(close, L, 0.85, 6)), maVote(f_dema(close, L)),
         maVote(f_tema(close, L)),  maVote(f_kama(close, L)))

// All 74 votes: osc(0-9) | MA×5 lengths(10-59) | trend(60-69) | extra leading(70-73)
// Periods & OB/OS levels come from the input globals above.
calcVotes(l1, l2, l3, l4, l5) =>
    hasVol = not na(volume)
    rsi = ta.rsi(close, rsiLen)
    vRsi = vote(rsi < rsiOS and rsi > rsi[1], rsi > rsiOB and rsi < rsi[1])
    kk = ta.sma(ta.stoch(close, high, low, stochLen), 3)
    dd = ta.sma(kk, 3)
    vStoch = vote(kk < stochOS and dd < stochOS and ta.crossover(kk, dd), kk > stochOB and dd > stochOB and ta.crossunder(kk, dd))
    [_macd, _sig, hist] = ta.macd(close, macdFast, macdSlow, macdSig)
    vMacdH = vote(hist > 0 and hist > hist[1], hist < 0 and hist < hist[1])
    cci = ta.cci(close, cciLen)
    vCci = vote(cci < -cciLevel and cci > cci[1], cci > cciLevel and cci < cci[1])
    wpr = ta.wpr(wprLen)
    vWpr = vote(wpr < wprOS and wpr > wpr[1], wpr > wprOB and wpr < wpr[1])
    mfi = ta.mfi(hlc3, mfiLen)
    vMfi = hasVol ? vote(mfi < mfiOS and mfi > mfi[1], mfi > mfiOB and mfi < mfi[1]) : int(na)
    roc = ta.roc(close, rocLen)
    vRoc = vote(roc > 0, roc < 0)
    mom = ta.mom(close, momLen)
    vMom = vote(mom > mom[1], mom < mom[1])
    bpu = close - math.min(low, close[1])
    tru = math.max(high, close[1]) - math.min(low, close[1])
    s7  = math.sum(tru, 7)
    s14 = math.sum(tru, 14)
    s28 = math.sum(tru, 28)
    uo  = (s7 != 0 and s14 != 0 and s28 != 0) ? 100 * (4 * math.sum(bpu, 7) / s7 + 2 * math.sum(bpu, 14) / s14 + math.sum(bpu, 28) / s28) / 7 : na
    vUo = vote(uo < uoOS and uo > uo[1], uo > uoOB and uo < uo[1])
    ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
    vAo = vote(ta.crossover(ao, 0) or (ao > 0 and ao[2] > ao[1] and ao[1] < ao),
               ta.crossunder(ao, 0) or (ao < 0 and ao[2] < ao[1] and ao[1] > ao))
    oscArr = array.from(vRsi, vStoch, vMacdH, vCci, vWpr, vMfi, vRoc, vMom, vUo, vAo)

    [_st, dir] = ta.supertrend(3, 10)
    vSt = vote(dir < 0, dir > 0)
    [pdi, mdi, adx] = ta.dmi(adxLen, adxLen)
    vAdx = vote(adx > 20 and pdi > mdi, adx > 20 and pdi < mdi)
    conv  = (ta.highest(high, 9)  + ta.lowest(low, 9))  / 2
    base  = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
    lead1 = (conv + base) / 2
    lead2 = (ta.highest(high, 52) + ta.lowest(low, 52)) / 2
    vIchi = vote(lead1 > lead2 and close > lead1 and close > base and conv > base and close > conv,
                 lead1 < lead2 and close < lead2 and close < base and conv < base and close < conv)
    psar = ta.sar(0.02, 0.02, 0.2)
    vSar = vote(close > psar, close < psar)
    [bbMid, _bbU, _bbL] = ta.bb(close, bbLen, bbMult)
    vBb = vote(close > bbMid, close < bbMid)
    dcm = (ta.highest(high, 20) + ta.lowest(low, 20)) / 2
    vDon = vote(close > dcm, close < dcm)
    aUp = 100 * (14 + ta.highestbars(high, 15)) / 14
    aDn = 100 * (14 + ta.lowestbars(low, 15)) / 14
    vAroon = vote(aUp > aDn, aUp < aDn)
    lr = ta.linreg(close, 20, 0)
    vLr = vote(lr > lr[1], lr < lr[1])
    vmP = math.sum(math.abs(high - low[1]), 14)
    vmM = math.sum(math.abs(low - high[1]), 14)
    trS = math.sum(math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1]))), 14)
    vVortex = vote(trS != 0 and vmP > vmM, trS != 0 and vmP < vmM)
    vDmi = vote(pdi > mdi, pdi < mdi)
    trendArr = array.from(vSt, vAdx, vIchi, vSar, vBb, vDon, vAroon, vLr, vVortex, vDmi)

    // extra LEADING oscillators (appended at indices 70-73; oversold = buy)
    srsi  = ta.sma(ta.stoch(rsi, rsi, rsi, stochLen), 3)
    vSrsi = vote(srsi < 20 and srsi > srsi[1], srsi > 80 and srsi < srsi[1])
    pc     = close - close[1]
    tsiDen = f_dsmooth(math.abs(pc), 25, 13)
    tsi    = tsiDen != 0 ? 100 * f_dsmooth(pc, 25, 13) / tsiDen : 0.0
    tsiSig = ta.ema(tsi, 13)
    vTsi   = vote(tsi > tsiSig and tsi > tsi[1], tsi < tsiSig and tsi < tsi[1])
    fish   = f_fisher(9)
    vFish  = vote(fish > 0 and fish > fish[1], fish < 0 and fish < fish[1])
    cmo    = f_cmo(close, 9)
    vCmo   = vote(cmo < -50 and cmo > cmo[1], cmo > 50 and cmo < cmo[1])
    leadExtra = array.from(vSrsi, vTsi, vFish, vCmo)

    out = array.new<int>()
    array.concat(out, oscArr)
    array.concat(out, maFamilyVotes(l1, hasVol))
    array.concat(out, maFamilyVotes(l2, hasVol))
    array.concat(out, maFamilyVotes(l3, hasVol))
    array.concat(out, maFamilyVotes(l4, hasVol))
    array.concat(out, maFamilyVotes(l5, hasVol))
    array.concat(out, trendArr)
    array.concat(out, leadExtra)
    out

// ======== ========= ANALYTICS METRICS (regime / vol / trend) =============
M_ADX     = 0
M_PDI     = 1
M_MDI     = 2
M_BBWPR   = 3
M_STDIR   = 4
M_MAALIGN = 5
M_ICHI    = 6
M_LRSLP   = 7
calcMetrics() =>
    [pdi, mdi, adx] = ta.dmi(adxLen, adxLen)
    [bbMid, bbU, bbL] = ta.bb(close, bbLen, bbMult)
    bbW   = bbMid != 0 ? (bbU - bbL) / bbMid : 0.0
    bbWpr = ta.percentrank(bbW, 100)
    [_stl, dir] = ta.supertrend(3, 10)
    stDir = dir < 0 ? 1.0 : -1.0
    eA = ta.ema(close, 20)
    eB = ta.ema(close, 50)
    eC = ta.ema(close, 100)
    eD = ta.ema(close, 200)
    alignBull = (close > eA ? 1 : 0) + (eA > eB ? 1 : 0) + (eB > eC ? 1 : 0) + (eC > eD ? 1 : 0)
    maAlign = alignBull / 4.0 * 2 - 1
    conv  = (ta.highest(high, 9)  + ta.lowest(low, 9))  / 2
    base  = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
    spanA = (conv + base) / 2
    spanB = (ta.highest(high, 52) + ta.lowest(low, 52)) / 2
    cloudTop = math.max(spanA, spanB)
    cloudBot = math.min(spanA, spanB)
    ichi = close > cloudTop ? 1.0 : close < cloudBot ? -1.0 : 0.0
    lr = ta.linreg(close, 20, 0)
    lrSlp = lr - lr[1]
    array.from(adx, pdi, mdi, bbWpr, stDir, maAlign, ichi, lrSlp)

// ========== LEADING / LAGGING SETS ==============
var leadIdx = array.from(0, 1, 3, 4, 5, 6, 7, 8, 9, 64, 65, 66, 70, 71, 72, 73)
var lagIdx  = array.new<int>()
if barstate.isfirst
    array.push(lagIdx, 2)                                         // MACD Hist
    for _i = 10 to 59                                             // all 50 moving-average votes
        array.push(lagIdx, _i)
    array.push(lagIdx, 60)   // Supertrend
    array.push(lagIdx, 61)   // ADX
    array.push(lagIdx, 62)   // Ichimoku
    array.push(lagIdx, 63)   // Parabolic SAR
    array.push(lagIdx, 67)   // LinReg
    array.push(lagIdx, 68)   // Vortex
    array.push(lagIdx, 69)   // DMI

// Per-indicator weights (category weight × enabled), index-aligned with the votes.
// 0 = disabled/excluded. Category: osc+extras → wOsc, MAs → wMA, trend(60-69) → wTrend.
var wArr = array.new<float>(74, 0.0)
if barstate.isfirst
    array.set(wArr, 0, enRsi   ? wOsc : 0.0)
    array.set(wArr, 1, enStoch ? wOsc : 0.0)
    array.set(wArr, 2, enMacd  ? wOsc : 0.0)
    array.set(wArr, 3, enCci   ? wOsc : 0.0)
    array.set(wArr, 4, enWpr   ? wOsc : 0.0)
    array.set(wArr, 5, enMfi   ? wOsc : 0.0)
    array.set(wArr, 6, enRoc   ? wOsc : 0.0)
    array.set(wArr, 7, enMom   ? wOsc : 0.0)
    array.set(wArr, 8, enUo    ? wOsc : 0.0)
    array.set(wArr, 9, enAo    ? wOsc : 0.0)
    maEn = array.from(enEma, enSma, enVwma, enWma, enHma, enRma, enAlma, enDema, enTema, enKama)
    for k = 0 to 4
        for t = 0 to 9
            array.set(wArr, 10 + 10 * k + t, array.get(maEn, t) ? wMA : 0.0)
    array.set(wArr, 60, enSt    ? wTrend : 0.0)
    array.set(wArr, 61, enAdx   ? wTrend : 0.0)
    array.set(wArr, 62, enIchi  ? wTrend : 0.0)
    array.set(wArr, 63, enSar   ? wTrend : 0.0)
    array.set(wArr, 64, enBb    ? wTrend : 0.0)
    array.set(wArr, 65, enDon   ? wTrend : 0.0)
    array.set(wArr, 66, enAroon ? wTrend : 0.0)
    array.set(wArr, 67, enLr    ? wTrend : 0.0)
    array.set(wArr, 68, enVtx   ? wTrend : 0.0)
    array.set(wArr, 69, enDmi   ? wTrend : 0.0)
    array.set(wArr, 70, enSrsi  ? wOsc : 0.0)
    array.set(wArr, 71, enTsi   ? wOsc : 0.0)
    array.set(wArr, 72, enFish  ? wOsc : 0.0)
    array.set(wArr, 73, enCmo   ? wOsc : 0.0)

// weight-aware rating / count helpers (w == 0 → excluded)
ratingIdx(arr, idx, w) =>
    s   = 0.0
    den = 0.0
    if not na(arr)
        for i = 0 to array.size(idx) - 1
            j  = array.get(idx, i)
            x  = array.get(arr, j)
            wi = array.get(w, j)
            if not na(x) and wi > 0
                s   += x * wi
                den += wi
    den > 0 ? s / den : 0.0
cntIdx(arr, idx, target, w) =>
    c = 0
    if not na(arr)
        for i = 0 to array.size(idx) - 1
            j = array.get(idx, i)
            x = array.get(arr, j)
            if not na(x) and array.get(w, j) > 0 and x == target
                c += 1
    c
cntActive(arr, idx, w) =>
    c = 0
    if not na(arr)
        for i = 0 to array.size(idx) - 1
            j = array.get(idx, i)
            if not na(array.get(arr, j)) and array.get(w, j) > 0
                c += 1
    c

// Only route through request.security when an alternate timeframe is actually
// chosen — returning a collection from request.security on every bar risks
// "Memory limits exceeded" on long-history symbols (pinescriptv6 common_errors).
htf      = analysisTF == "" ? timeframe.period : analysisTF
allRaw   = analysisTF == "" ? calcVotes(maL1, maL2, maL3, maL4, maL5)
     : request.security(syminfo.tickerid, analysisTF, calcVotes(maL1, maL2, maL3, maL4, maL5), lookahead = barmerge.lookahead_off)
metRaw   = analysisTF == "" ? calcMetrics()
     : request.security(syminfo.tickerid, analysisTF, calcMetrics(), lookahead = barmerge.lookahead_off)
allVotes = confirmClose and not barstate.isconfirmed ? allRaw[1] : allRaw
metHeld  = confirmClose and not barstate.isconfirmed ? metRaw[1] : metRaw
met      = na(metHeld) ? array.new<float>(8, na) : metHeld

leadRating = ratingIdx(allVotes, leadIdx, wArr)
lagRating  = ratingIdx(allVotes, lagIdx, wArr)
sumRating  = (leadRating + lagRating) / 2

leadS = cntIdx(allVotes, leadIdx, -1, wArr)
leadN = cntIdx(allVotes, leadIdx, 0, wArr)
leadB = cntIdx(allVotes, leadIdx, 1, wArr)
lagS  = cntIdx(allVotes, lagIdx, -1, wArr)
lagN  = cntIdx(allVotes, lagIdx, 0, wArr)
lagB  = cntIdx(allVotes, lagIdx, 1, wArr)
sumS = leadS + lagS
sumN = leadN + lagN
sumB = leadB + lagB

// =========================== VERDICT MAPPING =================================
verdictCol(r) =>
    r <= -0.5 ? colSSell : r <= -0.1 ? colSell : r < 0.1 ? colNeut : r < 0.5 ? colBuy : colSBuy
verdictTxt(r) =>
    r <= -0.5 ? "Strong Sell" : r <= -0.1 ? "Sell" : r < 0.1 ? "Neutral" : r < 0.5 ? "Buy" : "Strong Buy"

segColor(f) =>
    f < 0.25 ? color.from_gradient(f, 0.0,  0.25, colSSell, colSell) :
     f < 0.5  ? color.from_gradient(f, 0.25, 0.5,  colSell,  colNeut) :
     f < 0.75 ? color.from_gradient(f, 0.5,  0.75, colNeut,  colBuy)  :
     color.from_gradient(f, 0.75, 1.0, colBuy, colSBuy)

voteGlyph(v) => v > 0 ? "▲" : v < 0 ? "▼" : "–"
voteCol(v)   => v > 0 ? colBuy : v < 0 ? colSSell : colMute
sgnF(x)      => x > 0.05 ? 1 : x < -0.05 ? -1 : 0
scoreSz = compactMode ? size.large : size.huge

// =========================== ANALYTICS LAYER =================================
mAdx    = array.get(met, M_ADX)
mPdi    = array.get(met, M_PDI)
mMdi    = array.get(met, M_MDI)
mBbwpr  = array.get(met, M_BBWPR)
mStDir  = array.get(met, M_STDIR)
mMaAln  = array.get(met, M_MAALIGN)
mIchi   = array.get(met, M_ICHI)
mLrSlp  = array.get(met, M_LRSLP)

trendBull = nz((mStDir + mIchi + sgnF(mPdi - mMdi) + sgnF(mMaAln) + sgnF(mLrSlp)) / 5.0)
adxScale  = na(mAdx) ? 0.0 : math.min(mAdx / 40.0, 1.0)
trendStr  = int(math.round((0.55 * math.abs(trendBull) + 0.45 * adxScale) * 100))

regimeTxt = na(mAdx) or mAdx < adxSideways ? "Sideways" :
             trendBull >= 0.55 and mAdx >= adxStrong ? "Strong Bull Trend" :
             trendBull >  0.10 ? "Bull Trend" :
             trendBull <= -0.55 and mAdx >= adxStrong ? "Strong Bear Trend" :
             trendBull < -0.10 ? "Bear Trend" : "Sideways"
regimeCol = verdictCol(trendBull)

volTxt = na(mBbwpr) ? "n/a" : mBbwpr < volLowTh ? "Low" : mBbwpr < volNormTh ? "Normal" : mBbwpr < volHighTh ? "High" : "Extreme"
volCol = volTxt == "Extreme" ? colSSell : volTxt == "High" ? colSell : volTxt == "Normal" ? colBuy : colMute

totV         = sumB + sumS + sumN
decisiveness = math.abs(sumRating)
leadLagAgree = 1 - math.abs(leadRating - lagRating) / 2
consistency  = totV > 0 ? math.max(sumB, sumS) / totV : 0.0
confidence   = int(math.round((0.40 * decisiveness + 0.30 * leadLagAgree + 0.30 * consistency) * 100))

bullProb = totV > 0 ? int(math.round(100 * (sumB + 0.5 * sumN) / totV)) : 50
bearProb = 100 - bullProb

volFav   = volTxt == "Normal" or volTxt == "High" ? 100.0 : volTxt == "Low" ? 55.0 : 30.0
qualityS = 0.40 * confidence + 0.35 * trendStr + 0.25 * volFav
grade    = qualityS >= 88 ? "A+" : qualityS >= 78 ? "A" : qualityS >= 66 ? "B" : qualityS >= 52 ? "C" : "D"
gradeCol = qualityS >= 78 ? colSBuy : qualityS >= 66 ? colBuy : qualityS >= 52 ? colNeut : colSSell

// =========================== SIGNALS / ALERTS ================================
trendingOK = not chopFilter or (not na(mAdx) and mAdx >= chopAdx)
bgcolor(showBg ? color.new(verdictCol(sumRating), 88) : na, title = "Regime background")
plotshape(showMarkers and trendingOK and ta.crossover(sumRating, sigStrong),  "Strong Buy",  shape.triangleup,   location.belowbar, colSBuy,  size = size.small)
plotshape(showMarkers and trendingOK and ta.crossunder(sumRating, -sigStrong), "Strong Sell", shape.triangledown, location.abovebar, colSSell, size = size.small)
plotshape(showNormalArrows and trendingOK and ta.crossover(sumRating, sigBuy),  "Buy",  shape.triangleup,   location.belowbar, colBuy,  size = size.tiny)
plotshape(showNormalArrows and trendingOK and ta.crossunder(sumRating, -sigBuy), "Sell", shape.triangledown, location.abovebar, colSell, size = size.tiny)
plot((sumRating + 1) * 50, "Summary score (0-100)", display = display.data_window, editable = false)
plot(bullProb,  "Bullish probability %", display = display.data_window, editable = false)
plot(trendStr,  "Trend strength %",      display = display.data_window, editable = false)
plot(confidence,"Confidence %",          display = display.data_window, editable = false)

alertcondition(ta.crossover(sumRating, sigBuy),     "Summary → Buy",         "Technical Summary turned Buy")
alertcondition(ta.crossover(sumRating, sigStrong),  "Summary → Strong Buy",  "Technical Summary turned Strong Buy")
alertcondition(ta.crossunder(sumRating, -sigBuy),   "Summary → Sell",        "Technical Summary turned Sell")
alertcondition(ta.crossunder(sumRating, -sigStrong),"Summary → Strong Sell", "Technical Summary turned Strong Sell")
alertcondition(volAlertOn and mBbwpr >= volHighTh and (na(mBbwpr[1]) or mBbwpr[1] < volHighTh), "Volatility → Extreme", "Volatility entered the Extreme zone")

// =========================== GAUGE TABLE GEOMETRY ============================
tablePos = posOpt == "Top left"      ? position.top_left      : posOpt == "Top center"    ? position.top_center    :
           posOpt == "Top right"     ? position.top_right     : posOpt == "Middle left"   ? position.middle_left   :
           posOpt == "Middle center" ? position.middle_center : posOpt == "Middle right"  ? position.middle_right  :
           posOpt == "Bottom left"   ? position.bottom_left   : posOpt == "Bottom right"  ? position.bottom_right  :
           position.top_right
infoPos = infoPosOpt == "Top left" ? position.top_left : infoPosOpt == "Top right" ? position.top_right :
          infoPosOpt == "Bottom left" ? position.bottom_left : position.bottom_right

SPW   = 1.5
nO    = nSeg
nM    = nSeg
nU    = math.max(7, int(math.round(nSeg * sumWidth)))
nActive = (showLead ? 1 : 0) + (showLag ? 1 : 0) + (showSum ? 1 : 0)
totSeg  = (showLead ? nO : 0) + (showLag ? nM : 0) + (showSum ? nU : 0)
nSpace  = math.max(0, nActive - 1)
NCOLS   = totSeg + nSpace
NCOLS   := NCOLS < 1 ? (showAnalytics ? 12 : 1) : NCOLS
SEGW    = (groupPct - nSpace * SPW) / math.max(totSeg, 1)

effH = compactMode ? hScale * 0.7 : hScale
HH = 4.0 * effH
HN = 3.5 * effH
HS = 8.0 * effH
HM = 4.5 * effH
HF = 3.5 * effH
HA = 4.0 * effH
rowH(r) => r == 0 ? HH : r == 1 ? HN : r == 2 ? HS : r == 3 ? HM : HF

buildPanel(t, c0, seg, rating, ttl, sN, nN, bN) =>
    cE    = c0 + seg - 1
    vcol  = verdictCol(rating)
    score = int(math.round((rating + 1) * 50))
    arrow = rating > 0.05 ? "▲" : rating < -0.05 ? "▼" : "►"

    table.cell(t, c0, 0, ttl, bgcolor = colHdr, text_color = colTxt, text_size = size.normal, text_halign = text.align_center)
    table.merge_cells(t, c0, 0, cE, 0)
    table.cell(t, c0, 1, "Now:  " + verdictTxt(rating), bgcolor = colDark, text_color = colTxt, text_size = size.normal, text_halign = text.align_center)
    table.merge_cells(t, c0, 1, cE, 1)
    table.cell(t, c0, 2, str.tostring(score) + "   " + arrow, bgcolor = vcol, text_color = colTxt, text_size = scoreSz, text_halign = text.align_center)
    table.merge_cells(t, c0, 2, cE, 2)

    active = c0 + int(math.round(score / 100.0 * (seg - 1)))
    for i = 0 to seg - 1
        c = c0 + i
        f = seg <= 1 ? 0.0 : i / (seg - 1.0)
        table.cell(t, c, 3, c == active ? "●" : "", width = SEGW, height = HM,
             bgcolor = segColor(f), text_color = color.new(#ffffff, 0), text_size = size.large, text_halign = text.align_center)

    t1 = c0 + int(seg / 3.0)
    t2 = c0 + int(2 * seg / 3.0)
    table.cell(t, c0, 4, "Sell " + str.tostring(sN), bgcolor = colHdr, text_color = colMute, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(t, c0, 4, t1 - 1, 4)
    table.cell(t, t1, 4, "Neut " + str.tostring(nN), bgcolor = colHdr, text_color = colMute, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(t, t1, 4, t2 - 1, 4)
    table.cell(t, t2, 4, "Buy " + str.tostring(bN), bgcolor = colHdr, text_color = colMute, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(t, t2, 4, cE, 4)

// Analytics rows beneath the gauges (rows 5-7, full width).
addAnalytics(t) =>
    lastC = NCOLS - 1
    third = math.max(1, int(NCOLS / 3.0))
    cB = third
    cC = 2 * third
    table.cell(t, 0, 5, "Market Regime:   " + regimeTxt, bgcolor = regimeCol, text_color = colTxt, text_size = size.normal, text_halign = text.align_center, height = HA)
    table.merge_cells(t, 0, 5, lastC, 5)
    table.cell(t, 0,  6, "Confidence " + str.tostring(confidence) + "%", bgcolor = colDark, text_color = colTxt,  text_size = size.small, text_halign = text.align_center, height = HA)
    table.merge_cells(t, 0, 6, cB - 1, 6)
    table.cell(t, cB, 6, "Trend " + str.tostring(trendStr) + "%", bgcolor = colDark, text_color = verdictCol(trendBull), text_size = size.small, text_halign = text.align_center, height = HA)
    table.merge_cells(t, cB, 6, cC - 1, 6)
    table.cell(t, cC, 6, "Volatility: " + volTxt, bgcolor = colDark, text_color = volCol, text_size = size.small, text_halign = text.align_center, height = HA)
    table.merge_cells(t, cC, 6, lastC, 6)
    table.cell(t, 0,  7, "Bull " + str.tostring(bullProb) + "%", bgcolor = colHdr, text_color = colBuy,  text_size = size.small, text_halign = text.align_center, height = HA)
    table.merge_cells(t, 0, 7, cB - 1, 7)
    table.cell(t, cB, 7, "Bear " + str.tostring(bearProb) + "%", bgcolor = colHdr, text_color = colSSell, text_size = size.small, text_halign = text.align_center, height = HA)
    table.merge_cells(t, cB, 7, cC - 1, 7)
    table.cell(t, cC, 7, "Grade  " + grade, bgcolor = gradeCol, text_color = colTxt, text_size = size.normal, text_halign = text.align_center, height = HA)
    table.merge_cells(t, cC, 7, lastC, 7)

// =========================== BREAKDOWN TABLE =================================
leadNames = array.from("RSI", "Stochastic", "CCI", "Williams %R", "MFI",
     "ROC", "Momentum", "Ultimate Osc", "Awesome Osc", "Bollinger", "Donchian", "Aroon",
     "Stoch RSI", "TSI", "Fisher", "CMO")

infoCell(t, c, r, label, v, en) =>
    txt = en ? (" " + label + "  " + voteGlyph(v)) : (" " + label + "  ·")
    col = en ? voteCol(v) : color.new(colMute, 35)
    table.cell(t, c, r, txt, bgcolor = #2b2e36, text_color = col, text_size = size.small, text_halign = text.align_left)

buildInfo(allV, tfLabel, w) =>
    maTypes = array.from("EMA", "SMA", "VWMA", "WMA", "HMA", "RMA", "ALMA", "DEMA", "TEMA", "KAMA")

    lagNames = array.new<string>()
    lagVotes = array.new<int>()
    lagEn    = array.new<bool>()
    array.push(lagNames, "MACD Hist")
    array.push(lagVotes, array.get(allV, 2))
    array.push(lagEn, array.get(w, 2) > 0)
    for ti = 0 to 9
        sumv = 0
        cnt  = 0
        for k = 0 to 4
            x = array.get(allV, 10 + 10 * k + ti)
            if not na(x)
                sumv += x
                cnt  += 1
        array.push(lagNames, array.get(maTypes, ti))
        array.push(lagVotes, cnt > 0 ? sgnF(sumv / cnt) : 0)
        array.push(lagEn, array.get(w, 10 + ti) > 0)
    trNm = array.from("Supertrend", "ADX", "Ichimoku", "Parabolic SAR", "LinReg", "Vortex", "DMI")
    trIx = array.from(60, 61, 62, 63, 67, 68, 69)
    for j = 0 to 6
        ix = array.get(trIx, j)
        array.push(lagNames, array.get(trNm, j))
        array.push(lagVotes, array.get(allV, ix))
        array.push(lagEn, array.get(w, ix) > 0)

    it = table.new(infoPos, 2, 20, frame_color = color.new(color.black, 60), frame_width = 1,
         border_color = color.new(color.black, 60), border_width = 1)
    table.cell(it, 0, 0, "Indicators · " + tfLabel, bgcolor = colHdr, text_color = colTxt, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(it, 0, 0, 1, 0)
    nLead = array.size(leadIdx)
    table.cell(it, 0, 1, "Leading (" + str.tostring(cntActive(allV, leadIdx, w)) + ")", bgcolor = colDark, text_color = colTxt, text_size = size.small, text_halign = text.align_center)
    table.cell(it, 1, 1, "Lagging (" + str.tostring(cntActive(allV, lagIdx, w)) + ")", bgcolor = colDark, text_color = colTxt, text_size = size.small, text_halign = text.align_center)
    for i = 0 to 17
        r = i + 2
        if i < nLead
            li = array.get(leadIdx, i)
            infoCell(it, 0, r, array.get(leadNames, i), array.get(allV, li), array.get(w, li) > 0)
        else
            table.cell(it, 0, r, "", bgcolor = #2b2e36)
        infoCell(it, 1, r, array.get(lagNames, i), array.get(lagVotes, i), array.get(lagEn, i))

// =========================== RENDER ==========================================
if barstate.islast and not na(allVotes)
    nRows = showAnalytics ? 8 : 5
    T = table.new(tablePos, NCOLS, nRows,
         frame_color = color.new(color.black, 100), frame_width = 0,
         border_color = color.new(color.black, 100), border_width = 0)
    col = 0
    first = true
    spacerCols = array.new<int>()
    if showLead
        buildPanel(T, col, nO, leadRating, "Leading", leadS, leadN, leadB)
        col := col + nO
        first := false
    if showLag
        if not first
            array.push(spacerCols, col)
            col := col + 1
        buildPanel(T, col, nM, lagRating, "Lagging", lagS, lagN, lagB)
        col := col + nM
        first := false
    if showSum
        if not first
            array.push(spacerCols, col)
            col := col + 1
        buildPanel(T, col, nU, sumRating, "Summary", sumS, sumN, sumB)
        col := col + nU
        first := false
    for si = 0 to array.size(spacerCols) - 1
        sc = array.get(spacerCols, si)
        for r = 0 to 4
            table.cell(T, sc, r, "", width = SPW, height = rowH(r), bgcolor = color.new(color.gray, 100))
    if showAnalytics
        addAnalytics(T)
    if showInfo and not compactMode
        buildInfo(allVotes, htf, wArr)
````
