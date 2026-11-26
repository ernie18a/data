# Tectonic Regime Protocol [JOAT]

- url: https://www.tradingview.com/script/AuknbPLW-Tectonic-Regime-Protocol-JOAT/
- type: strategy
- pine_id: PUB;1e84872e525c4d9aa740b778089950a2
- version: 1.0

## Description

[b]Tectonic Regime Protocol [JOAT][/b]

[b]Introduction[/b]

Tectonic Regime Protocol is an open-source Pine Script v6 strategy that combines four analytical modules into a single rule-based trading system: a four-state regime classifier, a three-layer trend filter, a six-pillar confluence entry engine, and an adaptive exit module using ATR-based partial take-profit and a regime-adaptive trailing stop.

The strategy is designed for traders who want a fully automated systematic framework to study how regime-gating affects signal quality. Its primary hypothesis is that directional entries made when (1) the market is classified as a trending regime, (2) trend filters across multiple timeframes align, and (3) multiple structural, volume, and momentum inputs agree, produce statistically better outcomes than entries based on any single condition alone.

[image]https://www.tradingview.com/x/1O8Goed1/[/image]

[b]Strategy Default Properties[/b]

[list]
[*]Initial capital: $100,000
[*]Order size: 2% of equity per trade
[*]Commission: 0.04% per side
[*]Slippage: 2 ticks
[*]Maximum open positions: 1
[/list]

These settings represent realistic conditions for a funded discretionary trader using a liquid futures or equity instrument. The 2% equity sizing limits maximum theoretical drawdown from any single trade while providing meaningful position exposure. Commission and slippage values reflect typical institutional-grade execution costs for electronically traded instruments.

[b]Core Concepts[/b]

[b]1. Four-State Regime Classifier[/b]

The regime module classifies each bar into one of four states using ADX relative to a threshold and the ATR-to-SMA(ATR) ratio: Trend Bull, Trend Bear, Range High-Vol, Range Low-Vol. Only Trend states are eligible for entry. Range classifications suppress all entries regardless of how strong the confluence score is. This is the primary market context filter.

[b]2. Three-Layer Trend Filter[/b]

Three independently computed trend conditions must all agree before a long or short entry is considered: close versus VWMA(200) determines whether price is above or below long-term value; the relationship between fast and slow HMA lines determines medium-term momentum direction; and the close versus a 50-period EMA on a higher timeframe provides multi-timeframe context.

[b]3. Six-Pillar Confluence Score[/b]

The entry engine scores six market dimensions and requires the composite bull or bear score to exceed 50 of 100 (default, configurable) with a directional lead of at least 8 points above the opposing score. The six pillars are: market structure, OBV slope direction, KAMA position + RSI + WPR composite, swing-low liquidity sweep detection, ATR ratio in productive range, and Fractal Efficiency Ratio above 0.30.

[pine]
bool longSetup = validRegime and regime == 1 and trendBull
    and bull >= confThreshold and (bull - bear) >= confGap
    and barstate.isconfirmed
[/pine]

[b]4. Adaptive Exit Module[/b]

The exit logic uses partial exits at two take-profit levels. TP1 closes 50% of the position at 1.0× risk distance. TP2 closes the remaining position at 2.0× risk distance. After TP1 is reached, the stop is moved to the entry price (breakeven). The stop before TP1 uses a regime-adaptive ATR trail — the stop multiplier is lower in low-volatility regimes (tighter) and higher in high-volatility regimes (looser). A 30-bar time-based exit closes any remaining position if neither TP nor stop is reached.

[b]5. Non-Repainting Architecture[/b]

All entry conditions are evaluated only when barstate.isconfirmed is true. The HTF EMA is requested with lookahead=barmerge.lookahead_off. Pivot-based conditions use confirmed pivot detection with symmetric lookback. No future bar references are used.


[b]Default Settings and Performance Notes[/b]

The strategy is published with the default Properties values listed above. Results shown on the publication chart are generated using these exact settings. Commission of 0.04% per side is representative of typical electronic execution on liquid instruments.

Win rate alone does not characterize strategy performance. The strategy is designed around a two-tier partial exit structure targeting positive expectancy (wins × average win greater than losses × average loss) rather than high win rate. The profit factor and average R-multiple are the more relevant metrics for this type of system.

[b]Input Parameters[/b]

[b]Regime Module:[/b]
[list]
[*]ADX Trend Threshold (default: 20)
[*]ATR Ratio High-Vol Threshold (default: 1.2)
[/list]

[b]Trend Filter:[/b]
[list]
[*]VWMA Length (default: 200)
[*]Ribbon Fast HMA and Slow HMA lengths
[*]HTF Timeframe for EMA(50) filter (default: 240)
[*]Enable HTF Filter toggle
[/list]

[b]Confluence Engine:[/b]
[list]
[*]Min Score (default: 50, range 50–95)
[*]Min Direction Lead (default: 8)
[*]Min FER (default: 0.30)
[*]FER Lookback (default: 14)
[*]Individual pillar weights (Structure, Volume, Momentum, Liquidity, Volatility, FER)
[/list]

[b]Exit Module:[/b]
[list]
[*]TP1 RR Multiple (default: 1.0)
[*]TP2 RR Multiple (default: 2.0)
[*]Stop Multiplier for Low / Med / High Volatility Regimes
[*]Max Bars Hold (default: 30)
[/list]

[b]How to Evaluate This Strategy[/b]

Apply it to a liquid instrument with sufficient historical data to generate more than 100 trades. Compare profit factor, Sharpe ratio, average R-multiple, and maximum drawdown — not win rate in isolation. Test it across at least two different instruments or timeframes to assess whether the results reflect genuine structural edge or data-fitting to one specific market.

The strategy is not optimized for any single market. Default parameters are deliberately conservative to avoid overfitting. Users who adjust parameters to improve backtested results should recognize that improvement on historical data does not guarantee improvement on future data.

[b]Strategy Limitations[/b]

[list]
[*]On lower-timeframe charts with short histories, fewer than 100 trades may result, reducing the statistical reliability of the backtest
[*]The HTF filter uses request.security() with a higher timeframe EMA. In live trading, the HTF value updates when the higher timeframe bar closes, which may differ slightly from live server-side execution
[*]ATR-based stops and targets mean position sizes and outcomes scale with volatility. In abnormally low-volatility environments, commission costs represent a larger proportion of expected gain
[*]The time-based exit at 30 bars may close profitable positions before TP2 is reached in slow-moving markets
[*]Backtested performance on any instrument does not predict future performance. Markets change, and parameters that produced edge historically may not do so in future regimes
[/list]

[b]Originality Statement[/b]

[list]
[*]Combining a four-state regime classifier, a three-layer multi-timeframe trend filter, a six-pillar confluence score including Fractal Efficiency Ratio, and a partial-exit adaptive trailing stop system in a single non-repainting open-source strategy is an original integration of methods
[*]The Fractal Efficiency Ratio as a pillar in a multi-factor entry score, and as a required gate condition for entry, is not present in existing open-source Pine Script v6 strategy publications as of this writing
[*]The regime-adaptive stop multiplier — loosening in high-volatility regimes and tightening in low-volatility regimes — is an original stop calibration approach within this strategic framework
[*]The dual entry mode (edge transition OR re-entry when flat with elevated score) increases signal frequency without compromising the fundamental regime and trend filter requirements
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Backtested results are simulated and do not represent real trading. Simulated results have inherent limitations and may not reflect actual trading outcomes due to market impact, execution differences, and changing market conditions. Past backtested performance does not guarantee future results. Trading involves substantial risk of loss. Always conduct independent due diligence and apply proper risk management before using any strategy with real capital. The author accepts no responsibility for trading losses resulting from use of this strategy.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Tectonic Regime Protocol [JOAT]",
     overlay                = true,
     initial_capital        = 100000,
     default_qty_type       = strategy.percent_of_equity,
     default_qty_value      = 2,
     commission_type        = strategy.commission.percent,
     commission_value       = 0.04,
     slippage               = 2,
     max_boxes_count        = 20,
     max_lines_count        = 20,
     max_labels_count       = 20)

// =============================================================================
// COLOR THEMES
// =============================================================================
string themeInput = input.string("Phantom", "Color Theme",
     options = ["Phantom", "Neon", "Classic", "Solar"],
     group   = "◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// =============================================================================
// INPUTS
// =============================================================================

// ── Regime Module ─────────────────────────────────────────────────────────────
var string G_REG      = "◈ Regime Module"
int    adxRegimeThres = input.int(20,   "ADX Trend Threshold",   group = G_REG)
float  atrRatioHVol   = input.float(1.2,"ATR Ratio HVol Thresh", step  = 0.1, group = G_REG)

// ── Trend Filter ──────────────────────────────────────────────────────────────
var string G_TREND    = "◈ Trend Filter"
int    vwmaLen        = input.int(200,  "VWMA Length",           group = G_TREND)
int    ribbonFast     = input.int(20,   "Ribbon Fast HMA",       group = G_TREND)
int    ribbonSlow     = input.int(150,  "Ribbon Slow HMA",       group = G_TREND)
simple string htfRes  = input.timeframe("240", "HTF Timeframe",  group = G_TREND)
bool   useHTF         = input.bool(true,"Enable HTF Filter",     group = G_TREND)

// ── Confluence Engine ─────────────────────────────────────────────────────────
var string G_CONF     = "◈ Confluence Engine"
int    confThreshold  = input.int(50,    "Min Score",           50, 95,  group = G_CONF)
int    confGap        = input.int(8,     "Min Direction Lead",  0,  50,  group = G_CONF)
float  ferMinThres    = input.float(0.3, "Min FER",   0.1, 1.0, step = 0.05, group = G_CONF)
int    ferLenConf     = input.int(14,    "FER Lookback",                  group = G_CONF)
// Pillar weights
int    wStr           = input.int(20, "Structure Weight",  group = G_CONF)
int    wVol           = input.int(15, "Volume Weight",     group = G_CONF)
int    wMom           = input.int(15, "Momentum Weight",   group = G_CONF)
int    wLiq           = input.int(15, "Liquidity Weight",  group = G_CONF)
int    wVlt           = input.int(15, "Volatility Weight", group = G_CONF)
int    wFER           = input.int(20, "FER Weight",        group = G_CONF)

// ── Exit Module ───────────────────────────────────────────────────────────────
var string G_EXIT     = "◈ Exit Module"
float  tp1RR          = input.float(1.0, "TP1 RR Multiple",       step = 0.5, group = G_EXIT)
float  tp2RR          = input.float(2.0, "TP2 RR Multiple",       step = 0.5, group = G_EXIT)
float  stopLowMult    = input.float(1.5, "Stop Mult (Low Vol)",   step = 0.1, group = G_EXIT)
float  stopMedMult    = input.float(2.0, "Stop Mult (Med Vol)",   step = 0.1, group = G_EXIT)
float  stopHighMult   = input.float(2.5, "Stop Mult (High Vol)",  step = 0.1, group = G_EXIT)
int    maxBarsHold    = input.int(30,    "Max Bars Hold",    10, 200,   group = G_EXIT)

// ── Visual ────────────────────────────────────────────────────────────────────
var string G_VIS      = "◈ Visual"
bool   showRibbon     = input.bool(true,  "Show HMA Ribbon",   group = G_VIS)
bool   showBG         = input.bool(true,  "Show Regime Tint",  group = G_VIS)
bool   showBarCol     = input.bool(true,  "Show Bar Color",    group = G_VIS)

// ── Dashboard ─────────────────────────────────────────────────────────────────
var string G_DASH     = "◈ Dashboard"
bool   showDash       = input.bool(true,          "Show Dashboard", group = G_DASH)
string dashPos        = input.string("Top Right",  "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group   = G_DASH)
string dashSize       = input.string("Small", "Size",
     options = ["Tiny", "Small", "Normal"],
     group   = G_DASH)

// =============================================================================
// USER-DEFINED FUNCTIONS
// =============================================================================

// Kaufman Adaptive Moving Average
kamaF(simple int kLen) =>
    float diff = math.abs(ta.change(close, kLen))
    float vola = math.sum(math.abs(ta.change(close)), kLen)
    float er   = vola != 0.0 ? diff / vola : 0.0
    float sc   = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2.0)
    var float k = na
    k := nz(k[1], close) + sc * (close - nz(k[1], close))
    k

// Fractal Efficiency Ratio
ferF(simple int len) =>
    float net  = math.abs(close - close[len])
    float path = math.sum(math.abs(ta.change(close)), len)
    path > 0.0 ? net / path : 0.0

// =============================================================================
// MODULE 1: REGIME CLASSIFIER (ADX + ATR Ratio)
// =============================================================================

float atr14     = ta.atr(14)
float atrSMA50  = ta.sma(atr14, 50)
float atrRatio  = atrSMA50 > 0.0 ? atr14 / atrSMA50 : 1.0

[diP, diM, adxVal] = ta.dmi(14, 14)

float ema50     = ta.ema(close, 50)
bool  isTrend   = adxVal > float(adxRegimeThres)
bool  isHVol    = atrRatio > atrRatioHVol

// Regime codes: 1=TrendBull  2=TrendBear  3=RangeHVol  4=RangeLVol
int regime = isTrend and close > ema50 ? 1 : isTrend and close < ema50 ? 2 : isHVol ? 3 : 4

bool validRegime = regime == 1 or regime == 2

// Regime-adaptive stop multiplier
float activeStopMult = atrRatio < 0.85 ? stopLowMult : atrRatio > 1.35 ? stopHighMult : stopMedMult

// Regime background tint
color regTint = na
if showBG
    regTint := regime == 1 ? color.new(colorBULL, 97) :
               regime == 2 ? color.new(colorBEAR, 97) :
               color.new(colorNEUTR, 97)
bgcolor(regTint)

// =============================================================================
// MODULE 2: TREND FILTER (VWMA + HMA Ribbon + HTF EMA)
// =============================================================================

float vwmaVal = ta.vwma(close, vwmaLen)
float hmaFast = ta.hma(close, ribbonFast)
float hmaSlow = ta.hma(close, ribbonSlow)

float htfEma  = useHTF
     ? request.security(syminfo.tickerid, htfRes, ta.ema(close, 50),
         lookahead = barmerge.lookahead_off)
     : ema50

bool trendBull = close > vwmaVal and hmaFast > hmaSlow and close > htfEma
bool trendBear = close < vwmaVal and hmaFast < hmaSlow and close < htfEma

// HMA ribbon gradient (5-line, colour-graded)
float rSpread  = hmaFast - hmaSlow
float rAbsSpr  = math.abs(rSpread)
float rAvgSpr  = ta.ema(rAbsSpr, 200)
float rFactor  = math.max(-1.0, math.min(1.0,
     nz(rSpread / (rAvgSpr * 1.5 + 1e-9), 0.0)))
color rCol     = color.from_gradient(rFactor, -1.0, 1.0, colorBEAR, colorBULL)

int rStep1 = ribbonFast + (ribbonSlow - ribbonFast) / 4
int rStep2 = ribbonFast + (ribbonSlow - ribbonFast) / 2
int rStep3 = ribbonFast + (ribbonSlow - ribbonFast) * 3 / 4

rp1 = plot(showRibbon ? ta.hma(close, ribbonFast) : na, "R1", color.new(rCol, 10),  1)
rp2 = plot(showRibbon ? ta.hma(close, rStep1)     : na, "R2", color.new(rCol, 30),  1)
rp3 = plot(showRibbon ? ta.hma(close, rStep2)     : na, "R3", color.new(rCol, 50),  1)
rp4 = plot(showRibbon ? ta.hma(close, rStep3)     : na, "R4", color.new(rCol, 70),  1)
rp5 = plot(showRibbon ? ta.hma(close, ribbonSlow) : na, "R5", color.new(rCol, 88),  1)

fill(rp1, rp2, color=color.new(rCol, 92))
fill(rp2, rp3, color=color.new(rCol, 93))
fill(rp3, rp4, color=color.new(rCol, 95))
fill(rp4, rp5, color=color.new(rCol, 97))

// =============================================================================
// MODULE 3: CONFLUENCE ENTRY ENGINE (6-Pillar Scoring)
// =============================================================================

// ── Core indicators ───────────────────────────────────────────────────────────
float rsiVal   = ta.rsi(close, 14)
float wprVal   = ta.wpr(14)
float kamaVal  = kamaF(21)
float ferVal   = ferF(ferLenConf)

float obvV     = ta.cum(math.sign(ta.change(close)) * volume)
float obvSlope = ta.linreg(obvV, 20, 0) - ta.linreg(obvV, 20, 1)

float atrRel   = atr14 / math.max(ta.sma(atr14, 100), 0.0001)
float volMA    = ta.ema(volume, 20)

// ── Pivot tracking for Structure + Liquidity pillars ──────────────────────────
float ph = ta.pivothigh(high, 5, 5)
float pl = ta.pivotlow(low,   5, 5)

var float lPH = na
var float lPL = na
var bool  iHH = false
var bool  iHL = false
var bool  iLH = false
var bool  iLL = false

if not na(ph)
    iHH := ph > nz(lPH, 0.0)
    iLH := ph < nz(lPH, 999999.0)
    lPH := ph

if not na(pl)
    iHL := pl > nz(lPL, 0.0)
    iLL := pl < nz(lPL, 999999.0)
    lPL := pl

// ── Pillar 1: Market Structure ────────────────────────────────────────────────
float bStr = (iHH or iHL) and close > nz(lPL, close) ? float(wStr) : 0.0
float eStr = (iLH or iLL) and close < nz(lPH, close) ? float(wStr) : 0.0

// ── Pillar 2: Volume (OBV slope direction) ────────────────────────────────────
float bVol = obvSlope > 0 ? float(wVol) : 0.0
float eVol = obvSlope < 0 ? float(wVol) : 0.0

// ── Pillar 3: Momentum (KAMA + RSI + WPR tri-confirmation) ───────────────────
float bMomR = (close   > kamaVal ? 1.0 : 0.0) +
              (rsiVal  > 50      ? 1.0 : 0.0) +
              (wprVal  > -40     ? 1.0 : 0.0)
float eMomR = (close   < kamaVal ? 1.0 : 0.0) +
              (rsiVal  < 50      ? 1.0 : 0.0) +
              (wprVal  < -60     ? 1.0 : 0.0)
float bMom  = (bMomR / 3.0) * float(wMom)
float eMom  = (eMomR / 3.0) * float(wMom)

// ── Pillar 4: Liquidity (stop-hunt sweep reversal) ────────────────────────────
float bLiq = not na(lPL) and low  < lPL and close > lPL ? float(wLiq) : 0.0
float eLiq = not na(lPH) and high > lPH and close < lPH ? float(wLiq) : 0.0

// ── Pillar 5: Volatility (ATR ratio sweet-spot gate) ─────────────────────────
float bVlt = (atrRel > 0.8 and atrRel < 1.6) ? float(wVlt) : 0.0
float eVlt = (atrRel > 0.8 and atrRel < 1.6) ? float(wVlt) : 0.0

// ── Pillar 6: FER (fractal efficiency gate) ───────────────────────────────────
float bFER = ferVal >= ferMinThres ? float(wFER) : 0.0
float eFER = ferVal >= ferMinThres ? float(wFER) : 0.0

// ── Composite scores (max possible = sum of weights = 100) ───────────────────
float bull = bStr + bVol + bMom + bLiq + bVlt + bFER
float bear = eStr + eVol + eMom + eLiq + eVlt + eFER

// =============================================================================
// MODULE 4: ENTRY SIGNALS
// =============================================================================

bool longSetup  = validRegime and regime == 1 and trendBull and
                  bull >= confThreshold and (bull - bear) >= confGap and
                  barstate.isconfirmed

bool shortSetup = validRegime and regime == 2 and trendBear and
                  bear >= confThreshold and (bear - bull) >= confGap and
                  barstate.isconfirmed

// Enter on setup edge transition OR when flat with high-conviction score
bool enterLong  = (longSetup  and not longSetup[1])  or
                  (longSetup  and strategy.position_size == 0 and bull  >= confThreshold + 10)
bool enterShort = (shortSetup and not shortSetup[1]) or
                  (shortSetup and strategy.position_size == 0 and bear >= confThreshold + 10)

// =============================================================================
// STOP, TP AND TRADE STATE TRACKING
// =============================================================================

var float stopLong    = na
var float stopShort   = na
var float tp1Long     = na
var float tp2Long     = na
var float tp1Short    = na
var float tp2Short    = na
var bool  tp1LongHit  = false
var bool  tp1ShortHit = false
var int   barsInTrade = 0

float stopDist = atr14 * activeStopMult

// ── Long entry ────────────────────────────────────────────────────────────────
if enterLong
    stopLong      := close - stopDist
    tp1Long       := close + stopDist * tp1RR
    tp2Long       := close + stopDist * tp2RR
    tp1LongHit    := false
    barsInTrade   := 0
    strategy.entry("Long", strategy.long)

// ── Short entry ───────────────────────────────────────────────────────────────
if enterShort
    stopShort     := close + stopDist
    tp1Short      := close - stopDist * tp1RR
    tp2Short      := close - stopDist * tp2RR
    tp1ShortHit   := false
    barsInTrade   := 0
    strategy.entry("Short", strategy.short)

// ── Ratchet trailing stop for open long ───────────────────────────────────────
if strategy.position_size > 0 and not na(stopLong)
    float ratchetLong = close - atr14 * activeStopMult
    if ratchetLong > stopLong
        stopLong := ratchetLong
    // Move to break-even after TP1 hit
    if tp1LongHit and stopLong < strategy.position_avg_price
        stopLong := strategy.position_avg_price

// ── Ratchet trailing stop for open short ─────────────────────────────────────
if strategy.position_size < 0 and not na(stopShort)
    float ratchetShort = close + atr14 * activeStopMult
    if ratchetShort < stopShort
        stopShort := ratchetShort
    // Move to break-even after TP1 hit
    if tp1ShortHit and stopShort > strategy.position_avg_price
        stopShort := strategy.position_avg_price

// ── TP1 hit detection ─────────────────────────────────────────────────────────
if strategy.position_size > 0 and not na(tp1Long)
    if high >= tp1Long
        tp1LongHit := true

if strategy.position_size < 0 and not na(tp1Short)
    if low <= tp1Short
        tp1ShortHit := true

// ── Bar counter for time-based exit ──────────────────────────────────────────
if strategy.position_size != 0
    barsInTrade += 1

// ── Exit orders ───────────────────────────────────────────────────────────────
if strategy.position_size > 0 and not na(stopLong) and not na(tp1Long) and not na(tp2Long)
    strategy.exit("Long-TP1", "Long", qty_percent = 50,  limit = tp1Long, stop = stopLong, comment = "TP1")
    strategy.exit("Long-TP2", "Long", qty_percent = 100, limit = tp2Long, stop = stopLong, comment = "TP2")
    if barsInTrade >= maxBarsHold
        strategy.close("Long", comment = "Time Exit")

if strategy.position_size < 0 and not na(stopShort) and not na(tp1Short) and not na(tp2Short)
    strategy.exit("Short-TP1", "Short", qty_percent = 50,  limit = tp1Short, stop = stopShort, comment = "TP1")
    strategy.exit("Short-TP2", "Short", qty_percent = 100, limit = tp2Short, stop = stopShort, comment = "TP2")
    if barsInTrade >= maxBarsHold
        strategy.close("Short", comment = "Time Exit")

// =============================================================================
// VISUALS
// =============================================================================

// VWMA anchor line
plot(vwmaVal, "VWMA 200", color.new(colorELITE, 40), 1)

// ── Active TP / SL projection lines (last bar only) ───────────────────────────
var line lnStop = na
var line lnTP1  = na
var line lnTP2  = na

if barstate.islast
    line.delete(lnStop)
    line.delete(lnTP1)
    line.delete(lnTP2)
    int extR = bar_index + 10

    if strategy.position_size > 0 and not na(stopLong)
        lnStop := line.new(bar_index, stopLong, extR, stopLong,
             color = colorBEAR, width = 1, style = line.style_dashed)
        if not na(tp1Long) and not tp1LongHit
            lnTP1 := line.new(bar_index, tp1Long, extR, tp1Long,
                 color = color.rgb(0, 200, 100), width = 1)
        if not na(tp2Long)
            lnTP2 := line.new(bar_index, tp2Long, extR, tp2Long,
                 color = color.rgb(0, 255, 110), width = 2)

    if strategy.position_size < 0 and not na(stopShort)
        lnStop := line.new(bar_index, stopShort, extR, stopShort,
             color = colorBEAR, width = 1, style = line.style_dashed)
        if not na(tp1Short) and not tp1ShortHit
            lnTP1 := line.new(bar_index, tp1Short, extR, tp1Short,
                 color = color.rgb(0, 200, 100), width = 1)
        if not na(tp2Short)
            lnTP2 := line.new(bar_index, tp2Short, extR, tp2Short,
                 color = color.rgb(0, 255, 110), width = 2)

// ── Bar colouring by position + RSI gradient ─────────────────────────────────
color barCol = na
if showBarCol
    barCol := strategy.position_size > 0
         ? color.from_gradient(rsiVal, 50, 80, color.new(colorBULL, 50), colorBULL)
         : strategy.position_size < 0
         ? color.from_gradient(rsiVal, 20, 50, colorBEAR, color.new(colorBEAR, 50))
         : na
barcolor(barCol)

// =============================================================================
// DASHBOARD (11 data rows + header + footer = 12 rows, 2 columns)
// =============================================================================

string dashPosVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    =>          size.small

var table dash = table.new(dashPosVal, 2, 12,
     bgcolor       = color.new(#0d1117, 10),
     border_color  = color.new(#30363d, 20),
     border_width  = 1,
     frame_color   = color.new(#30363d, 40),
     frame_width   = 1)

// Helper: fill one dashboard cell
f_dc(int col, int row, string txt, color tcol, color bg) =>
    table.cell(dash, col, row, txt,
         text_color  = tcol,
         text_size   = dSz,
         bgcolor     = bg,
         text_halign = col == 0 ? text.align_left : text.align_right)

if showDash and barstate.islast
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // Row 0 — header
    f_dc(0, 0, "Tectonic Regime Protocol [JOAT]", colorELITE, hBg)
    f_dc(1, 0, timeframe.period + " | v1.0",       cMut,       hBg)

    // Row 1 — Regime
    string regTxt = regime == 1 ? "Trend Bull" : regime == 2 ? "Trend Bear" : regime == 3 ? "Range HVol" : "Range LVol"
    color  regCol = regime == 1 ? colorBULL : regime == 2 ? colorBEAR : colorNEUTR
    f_dc(0, 1, "Regime",  cMut,   pBg)
    f_dc(1, 1, regTxt,    regCol, dBg)

    // Row 2 — Trend Alignment
    bool tfAlign = (regime == 1 and trendBull) or (regime == 2 and trendBear)
    f_dc(0, 2, "Trend Filter", cMut, pBg)
    f_dc(1, 2, tfAlign ? "ALIGNED" : "SPLIT",
         tfAlign ? colorBULL : colorBEAR, dBg)

    // Row 3 — Bull Score
    f_dc(0, 3, "Bull Score", cMut, pBg)
    f_dc(1, 3, str.tostring(math.round(bull)) + " / 100",
         bull >= confThreshold ? colorBULL : cMut, dBg)

    // Row 4 — Bear Score
    f_dc(0, 4, "Bear Score", cMut, pBg)
    f_dc(1, 4, str.tostring(math.round(bear)) + " / 100",
         bear >= confThreshold ? colorBEAR : cMut, dBg)

    // Row 5 — FER
    color ferDispCol = ferVal >= ferMinThres ? colorBULL : colorBEAR
    f_dc(0, 5, "FER", cMut, pBg)
    f_dc(1, 5, str.tostring(ferVal, "#.###"), ferDispCol, dBg)

    // Row 6 — Open P&L
    float openPL = strategy.openprofit
    color plCol  = openPL >= 0.0 ? colorBULL : colorBEAR
    f_dc(0, 6, "Open P&L", cMut, pBg)
    f_dc(1, 6, (openPL >= 0.0 ? "+" : "") + "$" +
         str.tostring(math.round(openPL)), plCol, dBg)

    // Row 7 — Net Profit
    float netPL  = strategy.netprofit
    color npCol  = netPL >= 0.0 ? colorBULL : colorBEAR
    f_dc(0, 7, "Net Profit", cMut, pBg)
    f_dc(1, 7, (netPL >= 0.0 ? "+" : "") + "$" +
         str.tostring(math.round(netPL)), npCol, dBg)

    // Row 8 — Win Rate
    float wr    = strategy.closedtrades > 0 ? float(strategy.wintrades) / float(strategy.closedtrades) * 100.0 : 0.0
    color wrCol = wr >= 55.0 ? colorBULL : wr >= 40.0 ? colorNEUTR : strategy.closedtrades > 0 ? colorBEAR : cMut
    f_dc(0, 8, "Win Rate", cMut, pBg)
    f_dc(1, 8,
         strategy.closedtrades > 0 ? str.tostring(wr, "#.#") + "%" : "─",
         wrCol, dBg)

    // Row 9 — Closed Trades
    f_dc(0, 9, "Trades", cMut, pBg)
    f_dc(1, 9, str.tostring(strategy.closedtrades), cMut, dBg)

    // Row 10 — Max Drawdown (as % of initial capital)
    float maxDD    = strategy.equity > 0.0 ? strategy.max_drawdown / strategy.initial_capital * 100.0 : 0.0
    color ddCol    = maxDD < 5.0 ? colorBULL : maxDD < 15.0 ? colorNEUTR : colorBEAR
    f_dc(0, 10, "Max Drawdown", cMut, pBg)
    f_dc(1, 10, str.tostring(maxDD, "#.#") + "%", ddCol, dBg)

    // Row 11 — Footer / branding
    f_dc(0, 11, "[JOAT]",           color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 11, "jackofalltrades",  cMut,                  color.new(#0d1117, 20))

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(enterLong,
     "Tectonic Long Entry",
     "Tectonic Regime Protocol: Regime-gated long entry confirmed.")

alertcondition(enterShort,
     "Tectonic Short Entry",
     "Tectonic Regime Protocol: Regime-gated short entry confirmed.")

alertcondition(regime != regime[1] and validRegime,
     "Tectonic Regime Trend",
     "Tectonic Regime Protocol: Trending regime detected.")

// =============================================================================
// END OF SCRIPT — Tectonic Regime Protocol [JOAT] v1.0
// =============================================================================
````
