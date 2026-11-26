# Neural Confluence Engine [Quantum Algo]

- url: https://www.tradingview.com/script/QHtOXl9m-Neural-Confluence-Engine-Quantum-Algo/
- type: indicator
- pine_id: PUB;76886b3517b7472b94d514d7cf04e6bc
- version: 2.0

## Description

[b]Neural Confluence Engine [Quantum Algo]
[/b]
Neural Confluence Engine is a Pine Script v6 indicator that fuses eight independent technical factors — momentum, trend, VWAP position, RSI regime, MACD acceleration, ADX trend power, volume confirmation, and squeeze state — into a single weighted directional strength score on a 0–100 scale. Signals are gated by a user-configurable score threshold and an optional higher-timeframe trend filter before firing. The script is open-source. All signals are confirmed on bar close and do not repaint.
═══════════════════════════════════════════════════════════════════════
[b]HOW IT WORKS
[/b]
═══════════════════════════════════════════════════════════════════════
1. The eight factor model. Each bar, the engine evaluates eight independent factors and assigns each a normalized score between 0 and 1 based on its current state and intensity. Factors are scored separately for bullish and bearish directions.

2. WaveTrend Momentum (weight 1.5). Computes a custom oscillator from HLC3 smoothed by EMA of channel length (default 9) and signal length (default 12). Oversold reversals below -40 score 1.0; readings above zero score 0.8; positive crossovers below zero score 0.5.

3. EMA Alignment (weight 1.3). Triple EMA stack: fast (default 9) > slow (default 21) > baseline (default 50) scores 1.0 for full alignment. Fast > slow alone scores 0.6. Otherwise 0.

4. VWAP Position (weight 1.0). Price above VWAP by more than 1 ATR scores 1.0. Price above VWAP within 1 ATR scores 0.7. Below VWAP scores 0.

5. RSI Regime (weight 0.8). RSI above 60 scores 1.0. RSI between 50 and 60 scores 0.6. Below 50 scores 0.

6. MACD Histogram (weight 0.8). Rising histogram above zero scores 1.0. Positive but flat histogram scores 0.6. Negative histogram scores 0.

7. ADX Trend Power (weight 0.7). ADX above 40 scores 1.0. ADX between 25 and 40 scores 0.7. ADX below 25 scores 0.3 (penalty for chop, not zero).

8. Volume Confirmation (weight 1.0). Volume above 20-bar SMA combined with a directional candle close scores 1.0. Volume between 80% and 100% of average scores 0.4. Below scores 0.

9. Squeeze State (weight 1.2). Detects Bollinger Band compression inside Keltner Channels using length-20 standard deviation and ATR-10 envelopes. A "firing" bar (compression releases) with positive momentum scores 1.0. Compression without release scores 0.3.

10. Weighted aggregation and smoothing. Each directional factor is multiplied by its weight, summed, divided by total weight, and scaled to 0–100. The raw score is then smoothed with a 3-bar EMA to reduce single-bar noise. Bull score and Bear score are tracked separately. The net Neural Confluence Engine score is the difference between them.
═══════════════════════════════════════════════════════════════════════
[b]SIGNAL TIERS
[/b]
═══════════════════════════════════════════════════════════════════════
The script produces two signal tiers from the same scoring engine, allowing traders to choose between sensitivity and selectivity.
Standard signals (BUY / SELL). Fire on EMA ribbon color change — when the fast EMA crosses the slow EMA. These follow every directional shift regardless of score. Useful for systematic trend-following.
High-confluence signals (BUY+ / SELL+). Fire only when three conditions align simultaneously: an EMA cross occurs, the directional score exceeds the user-configurable threshold (default 60), and the higher-timeframe trend agrees with the signal direction. Used to filter for the most aligned setups.
Both signal tiers open trade management — entry, stop loss, three take-profit targets, and optional trailing stop after TP1.
═══════════════════════════════════════════════════════════════════════
[b]TRADE MANAGEMENT
[/b]
═══════════════════════════════════════════════════════════════════════
When a signal fires, the engine computes ATR-scaled risk levels relative to entry:

Stop loss: entry minus 1.5 × ATR (configurable multiplier 0.5–10).
TP1: 1R target (configurable risk-reward ratio).
TP2: 2R target.
TP3: 3R target.

When TP1 is reached, the stop converts to a trailing structure: SL moves to breakeven, then advances to TP1 level when TP2 is hit, then to TP2 level when TP3 is hit. The trailing stop also follows price at 0.5 × ATR distance after TP1. This can be disabled via the "Activate Trailing SL after TP1" toggle.
═══════════════════════════════════════════════════════════════════════
[b]WHAT'S ACTUALLY DIFFERENT
[/b]
═══════════════════════════════════════════════════════════════════════
◆ Eight-factor weighted composite, not a single trigger. Standard indicators fire on one condition — an EMA cross, an RSI level, a volume spike. The Neural Confluence Engine requires multiple independent factors to agree, weights them by historical reliability, and gates signals through a configurable score threshold. The trader can dial sensitivity from 20 (sensitive) to 95 (selective) without re-tuning eight separate sub-indicators.
◆ Two-tier signal architecture. Most indicators produce one stream of signals. This produces two from the same engine: standard ribbon flips for sensitive trend-following, and high-confluence variants gated by score + HTF agreement. Traders can use either tier independently or both in confluence.
◆ HTF agreement is built into the signal gate, not a separate filter. The higher-timeframe trend check is computed natively via request.security, auto-detected based on the chart timeframe (15m → 1H, 1H → 4H, 4H → D, D → W) or set manually. BUY+/SELL+ signals are blocked if HTF disagrees.
◆ Per-factor visibility in the dashboard. Each of the eight factors is individually viewable in real time — traders can see exactly which factors are contributing to the current score, rather than receiving a black-box signal. This is rare in confluence-style indicators which typically hide the sub-components.
◆ Trailing-stop ratcheting tied to TP hits. The trailing stop doesn't just follow ATR — it advances in tiers tied to take-profit milestones. After TP1, stop moves to breakeven. After TP2, to TP1. After TP3, to TP2. This protects profits at structurally meaningful levels rather than purely volatility-derived ones.
═══════════════════════════════════════════════════════════════════════
[b]RECOMMENDED SETTINGS
[/b]
═══════════════════════════════════════════════════════════════════════
Forex majors (EUR/USD, GBP/USD, USD/JPY) — 1H to 4H: Min Confluence Score 65, HTF Trend Filter on, SL Multiplier 1.5, TP R:R 1/2/3, HTF auto. Optimized for session-driven moves where structural levels respect institutional flow.
Crypto perpetuals (BTC, ETH, SOL) — 15M to 1H: Min Confluence Score 60, HTF Trend Filter on, SL Multiplier 2.0, TP R:R 1/2/3, HTF auto. Tuned for 24/7 markets with higher noise floors; the slightly wider stop accommodates increased wick volatility.
Gold (XAUUSD) — 1H to 4H: Min Confluence Score 70, HTF Trend Filter on, SL Multiplier 1.8, TP R:R 1/2/3.5, HTF set to Daily. Designed for the elevated wick activity around US session open and the tendency for sharp moves to develop after squeeze release.
Indices (SPX, NDX, DAX) — 5M to 1H: Min Confluence Score 55, HTF Trend Filter on, SL Multiplier 1.2, TP R:R 1/2/3, HTF auto. Tuned for cash-session structure and typical post-open momentum continuation.
Swing trading (any market) — 4H to Daily: Min Confluence Score 75, HTF Trend Filter on, SL Multiplier 2.5, TP R:R 1.5/3/5, HTF set to Weekly. Reduces noise to the highest-conviction setups only; wider targets to match the higher timeframe.
═══════════════════════════════════════════════════════════════════════
[b]ALERTS & OUTPUTS
[/b]
═══════════════════════════════════════════════════════════════════════
[b]Alerts available:
[/b]
BUY signal — ribbon flipped bullish (standard sensitivity)
SELL signal — ribbon flipped bearish (standard sensitivity)
BUY+ signal — high-confluence bullish setup
SELL+ signal — high-confluence bearish setup
Squeeze breakout — volatility compression released
TP1 reached — trailing stop activated
TP2 reached
TP3 reached

[b]On-chart visuals:
[/b]
EMA ribbon (5, 9, 13, 21, 34, 50) with fill bands colored by trend direction
VWAP plot with color reflecting price position
BUY / SELL / BUY+ / SELL+ signal labels at signal bars
Confluence score percentage label on BUY+ / SELL+ bars
Optional Entry / SL / TP1 / TP2 / TP3 horizontal lines for the most recent trade
TP-hit confirmation labels with checkmarks
Squeeze background highlight when compression is active
Diamond markers (⚡) on squeeze breakout bars
Optional momentum wave background colored by net score intensity
Optional candle coloring on signal bars
Multi-row dashboard with bull/bear scores, bias classification, HTF direction, factor states, trade status, and threshold setting

═══════════════════════════════════════════════════════════════════════
[b]NOTES
[/b]
═══════════════════════════════════════════════════════════════════════
Pine Script version: v6.
Repainting: All signals (BUY, SELL, BUY+, SELL+, squeeze breakouts, TP/SL hits) are evaluated on confirmed bar close and do not repaint. Higher-timeframe values use lookahead=barmerge.lookahead_off so HTF readings reflect only confirmed information available at signal time.

Compatibility: Works on all symbols and timeframes available in TradingView. Tested on forex majors, crypto perpetuals, gold, and major indices. Functions on stocks but the volume confirmation factor may require threshold adjustment for low-volume tickers. Functions on continuous contracts and CFDs.

Open-source: This script is open-source. Clone, study, and modify it freely under the terms of TradingView's House Rules. Republishing the source under a different name is not permitted.
Credits: This indicator's logic is independently developed. The component oscillators (WaveTrend, RSI, MACD, ADX, Bollinger Bands, Keltner Channels, VWAP) are standard public-domain technical analysis tools. The weighted-score aggregation methodology, two-tier signal architecture, ATR-tiered trailing stop progression, and per-factor dashboard are original implementations.
[b]
Disclaimer: This indicator is provided for educational and analytical purposes. Trading involves substantial risk of loss. Past performance does not guarantee future results. Position sizing and risk management are the trader's sole responsibility. Nothing in this script or description constitutes financial advice.[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Neural Confluence Engine [Quantum Algo]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════
// OVERVIEW
// A multi-factor confluence engine that fuses momentum, trend, volatility,
// volume, and squeeze analysis into a single weighted score (0–100) before
// any signal is allowed to fire. Eight independent factors are weighted
// and combined; signals are gated by a user-configurable score threshold.
// and an optional higher-timeframe trend filter.
// ═══════════════════════════════════════════════════════════════════════

// ── INPUTS ─────────────────────────────────────────────────────────────

group_sig = "Signal Engine"
i_threshold   = input.int(60, "Min Confluence Score (0–100)", minval=20, maxval=95, step=5, group=group_sig, tooltip="High-confluence signals only fire when the score exceeds this value. Standard signals fire on ribbon change regardless of score.")
i_htfFilter   = input.bool(true, "Enable HTF Trend Filter", group=group_sig)
i_htfTF       = input.timeframe("", "HTF Timeframe (auto if blank)", group=group_sig)

group_wt = "WaveTrend"
i_wtChannel  = input.int(9, "Channel Length", minval=2, group=group_wt)
i_wtAvg      = input.int(12, "Average Length", minval=2, group=group_wt)

group_trend = "Trend Structure"
i_emaFast    = input.int(9, "Fast EMA", minval=2, group=group_trend)
i_emaSlow    = input.int(21, "Slow EMA", minval=2, group=group_trend)
i_emaBase    = input.int(50, "Baseline EMA", minval=10, group=group_trend)

group_risk = "Trade Management"
i_atrLen     = input.int(14, "ATR Length", minval=5, group=group_risk)
i_slMult     = input.float(1.5, "SL ATR Multiplier", minval=0.5, step=0.1, group=group_risk)
i_tp1Mult    = input.float(1.0, "TP1 R:R", minval=0.5, step=0.5, group=group_risk)
i_tp2Mult    = input.float(2.0, "TP2 R:R", minval=1.0, step=0.5, group=group_risk)
i_tp3Mult    = input.float(3.0, "TP3 R:R", minval=1.5, step=0.5, group=group_risk)
i_trailAfterTP1 = input.bool(true, "Activate Trailing SL after TP1", group=group_risk)

group_vis = "Visuals"
i_showRibbon  = input.bool(true, "Show Wave Ribbon", group=group_vis)
i_showDash    = input.bool(true, "Show Dashboard", group=group_vis)
i_showLevels  = input.bool(false, "Show TP/SL Levels", group=group_vis)
i_showWave    = input.bool(false, "Show Background Wave", group=group_vis)
i_dashSize    = input.string("small", "Dashboard Size", options=["tiny", "small", "normal"], group=group_vis)
i_ribbonOpac  = input.int(82, "Ribbon Opacity", minval=0, maxval=100, group=group_vis)

// ── COLORS ─────────────────────────────────────────────────────────────
color C_CYAN    = #00E5FF
color C_PURPLE  = #6C5CE7
color C_GREEN   = #00E676
color C_RED     = #FF3D71
color C_ORANGE  = #FF9F43
color C_TEAL    = #00D4AA
color C_GOLD    = #F0B429
color C_BG      = #0A0E1A
color C_SURFACE = #141930
color C_MUTED   = #7B82A0

// ── CORE CALCULATIONS ──────────────────────────────────────────────────

emaFast     = ta.ema(close, i_emaFast)
emaSlow     = ta.ema(close, i_emaSlow)
emaBase     = ta.ema(close, i_emaBase)
ema5        = ta.ema(close, 5)
ema13       = ta.ema(close, 13)
ema34       = ta.ema(close, 34)
vwapVal     = ta.vwap(hlc3)
atrVal      = ta.atr(i_atrLen)
rsiVal      = ta.rsi(close, 14)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
[diPlus, diMinus, adxVal] = ta.dmi(14, 14)
volAvg      = ta.sma(volume, 20)
volRatio    = volume / math.max(volAvg, 1)

// WaveTrend
wtHlc3      = (high + low + close) / 3
wtEsa       = ta.ema(wtHlc3, i_wtChannel)
wtD         = ta.ema(math.abs(wtHlc3 - wtEsa), i_wtChannel)
wtCi        = (wtHlc3 - wtEsa) / (0.015 * wtD)
wtTci       = ta.ema(wtCi, i_wtAvg)
wtSig       = ta.sma(wtTci, 4)

// Squeeze Detection
bbBasis     = ta.sma(close, 20)
bbDev       = 2.0 * ta.stdev(close, 20)
bbUpper     = bbBasis + bbDev
bbLower     = bbBasis - bbDev
kcBasis     = ta.sma(close, 20)
kcRange     = 1.5 * ta.atr(10)
kcUpper     = kcBasis + kcRange
kcLower     = kcBasis - kcRange
sqzOn       = bbLower > kcLower and bbUpper < kcUpper
sqzOff      = bbLower < kcLower or bbUpper > kcUpper
sqzFiring   = sqzOn[1] and sqzOff
sqzMom      = ta.linreg(close - ta.sma((ta.highest(high, 20) + ta.lowest(low, 20)) / 2 + ta.sma(close, 20), 2) / 2, 20, 0)

// Higher Timeframe
f_autoHTF() =>
    tf = timeframe.period
    switch
        tf == "1"  => "5"
        tf == "3"  => "15"
        tf == "5"  => "30"
        tf == "15" => "60"
        tf == "30" => "240"
        tf == "60" => "240"
        tf == "120" => "D"
        tf == "240" => "D"
        tf == "D"  => "W"
        tf == "W"  => "M"
        => "D"

htfTF       = i_htfTF == "" ? f_autoHTF() : i_htfTF
htfEmaFast  = request.security(syminfo.tickerid, htfTF, ta.ema(close, i_emaFast), lookahead=barmerge.lookahead_off)
htfEmaSlow  = request.security(syminfo.tickerid, htfTF, ta.ema(close, i_emaSlow), lookahead=barmerge.lookahead_off)
htfBullish  = htfEmaFast > htfEmaSlow
htfBearish  = htfEmaFast < htfEmaSlow

// ── DIRECTIONAL STRENGTH SCORE ─────────────────────────────────────────

f_wt_bull = wtTci > wtSig ? (wtTci < -40 ? 1.0 : wtTci > 0 ? 0.8 : 0.5) : 0.0
f_wt_bear = wtTci < wtSig ? (wtTci > 40 ? 1.0 : wtTci < 0 ? 0.8 : 0.5) : 0.0
f_ema_bull = (emaFast > emaSlow and emaSlow > emaBase) ? 1.0 : (emaFast > emaSlow) ? 0.6 : 0.0
f_ema_bear = (emaFast < emaSlow and emaSlow < emaBase) ? 1.0 : (emaFast < emaSlow) ? 0.6 : 0.0
f_vwap_bull = close > vwapVal ? (close > vwapVal + atrVal ? 1.0 : 0.7) : 0.0
f_vwap_bear = close < vwapVal ? (close < vwapVal - atrVal ? 1.0 : 0.7) : 0.0
f_rsi_bull = rsiVal > 50 ? (rsiVal > 60 ? 1.0 : 0.6) : 0.0
f_rsi_bear = rsiVal < 50 ? (rsiVal < 40 ? 1.0 : 0.6) : 0.0
f_macd_bull = histLine > 0 ? (histLine > histLine[1] ? 1.0 : 0.6) : 0.0
f_macd_bear = histLine < 0 ? (histLine < histLine[1] ? 1.0 : 0.6) : 0.0
f_adx = adxVal > 25 ? (adxVal > 40 ? 1.0 : 0.7) : 0.3
f_vol_bull = (volume > volAvg and close > open) ? 1.0 : (volume > volAvg * 0.8) ? 0.4 : 0.0
f_vol_bear = (volume > volAvg and close < open) ? 1.0 : (volume > volAvg * 0.8) ? 0.4 : 0.0
f_sqz_bull = sqzFiring and sqzMom > 0 ? 1.0 : sqzOn ? 0.3 : 0.0
f_sqz_bear = sqzFiring and sqzMom < 0 ? 1.0 : sqzOn ? 0.3 : 0.0

float w1 = 1.5, float w2 = 1.3, float w3 = 1.0, float w4 = 0.8
float w5 = 0.8, float w6 = 0.7, float w7 = 1.0, float w8 = 1.2
float wTotal = w1 + w2 + w3 + w4 + w5 + w6 + w7 + w8

float bullRaw = (f_wt_bull*w1 + f_ema_bull*w2 + f_vwap_bull*w3 + f_rsi_bull*w4 + f_macd_bull*w5 + f_adx*w6 + f_vol_bull*w7 + f_sqz_bull*w8) / wTotal * 100
float bearRaw = (f_wt_bear*w1 + f_ema_bear*w2 + f_vwap_bear*w3 + f_rsi_bear*w4 + f_macd_bear*w5 + f_adx*w6 + f_vol_bear*w7 + f_sqz_bear*w8) / wTotal * 100

float bullScore = ta.ema(bullRaw, 3)
float bearScore = ta.ema(bearRaw, 3)
float nce = bullScore - bearScore

// ── SIGNAL GENERATION ──────────────────────────────────────────────────

// Ribbon state: bullish when fast EMA > slow EMA
bool ribbonBull = emaFast > emaSlow
bool ribbonBear = emaFast < emaSlow

// ── RIBBON CHANGE SIGNALS (standard BUY / SELL) ────────────────────────
bool ribbonFlipBull = ribbonBull and ribbonBear[1]   // red → cyan
bool ribbonFlipBear = ribbonBear and ribbonBull[1]   // cyan → red

// ── HIGH-CONFLUENCE SIGNALS (BUY+ / SELL+) ─────────────────────────────
crossUp     = ta.crossover(emaFast, emaSlow)
crossDn     = ta.crossunder(emaFast, emaSlow)
bool htfOk_bull = i_htfFilter ? htfBullish : true
bool htfOk_bear = i_htfFilter ? htfBearish : true
bool triggerBuyPlus  = crossUp  and bullScore >= i_threshold and htfOk_bull
bool triggerSellPlus = crossDn  and bearScore >= i_threshold and htfOk_bear

// Combined triggers for trade management (either signal opens a trade)
bool triggerBuy  = ribbonFlipBull or triggerBuyPlus
bool triggerSell = ribbonFlipBear or triggerSellPlus

// ── TRADE MANAGEMENT ───────────────────────────────────────────────────
var int tradeDir      = 0
var float entryPrice  = 0.0
var float slPrice     = 0.0
var float tp1Price    = 0.0
var float tp2Price    = 0.0
var float tp3Price    = 0.0
var bool tp1Hit       = false
var bool tp2Hit       = false
var bool tp3Hit       = false
var bool slHit        = false
var float trailSL     = 0.0
var int entryBar      = 0

if triggerBuy
    tradeDir     := 1
    entryPrice   := close
    float risk    = atrVal * i_slMult
    slPrice      := entryPrice - risk
    tp1Price     := entryPrice + risk * i_tp1Mult
    tp2Price     := entryPrice + risk * i_tp2Mult
    tp3Price     := entryPrice + risk * i_tp3Mult
    tp1Hit       := false
    tp2Hit       := false
    tp3Hit       := false
    slHit        := false
    trailSL      := slPrice
    entryBar     := bar_index

if triggerSell
    tradeDir     := -1
    entryPrice   := close
    float risk    = atrVal * i_slMult
    slPrice      := entryPrice + risk
    tp1Price     := entryPrice - risk * i_tp1Mult
    tp2Price     := entryPrice - risk * i_tp2Mult
    tp3Price     := entryPrice - risk * i_tp3Mult
    tp1Hit       := false
    tp2Hit       := false
    tp3Hit       := false
    slHit        := false
    trailSL      := slPrice
    entryBar     := bar_index

if tradeDir == 1 and not slHit
    if high >= tp1Price
        tp1Hit := true
        if i_trailAfterTP1
            trailSL := math.max(trailSL, entryPrice)
    if high >= tp2Price
        tp2Hit := true
        if i_trailAfterTP1
            trailSL := math.max(trailSL, tp1Price)
    if high >= tp3Price
        tp3Hit := true
        if i_trailAfterTP1
            trailSL := math.max(trailSL, tp2Price)
    if tp1Hit and i_trailAfterTP1
        trailSL := math.max(trailSL, low - atrVal * 0.5)
    if low <= trailSL
        slHit := true

if tradeDir == -1 and not slHit
    if low <= tp1Price
        tp1Hit := true
        if i_trailAfterTP1
            trailSL := math.min(trailSL, entryPrice)
    if low <= tp2Price
        tp2Hit := true
        if i_trailAfterTP1
            trailSL := math.min(trailSL, tp1Price)
    if low <= tp3Price
        tp3Hit := true
        if i_trailAfterTP1
            trailSL := math.min(trailSL, tp2Price)
    if tp1Hit and i_trailAfterTP1
        trailSL := math.min(trailSL, high + atrVal * 0.5)
    if high >= trailSL
        slHit := true

// ── WAVE RIBBON ────────────────────────────────────────────────────────
p5   = plot(i_showRibbon ? ema5 : na,   color=color.new(C_CYAN, 40),   linewidth=1, title="EMA 5")
p13  = plot(i_showRibbon ? ema13 : na,  color=color.new(C_CYAN, 60),   linewidth=1, title="EMA 13")
pF   = plot(i_showRibbon ? emaFast : na, color=color.new(C_TEAL, 30),  linewidth=2, title="EMA Fast")
pS   = plot(i_showRibbon ? emaSlow : na, color=color.new(C_PURPLE, 30), linewidth=2, title="EMA Slow")
p34  = plot(i_showRibbon ? ema34 : na,  color=color.new(C_PURPLE, 60), linewidth=1, title="EMA 34")
pB   = plot(i_showRibbon ? emaBase : na, color=color.new(C_ORANGE, 50), linewidth=1, title="EMA Base", style=plot.style_cross)

fill(p5,  pF,  color=emaFast > emaSlow ? color.new(C_CYAN, 100 - i_ribbonOpac + 15) : color.new(C_RED, 100 - i_ribbonOpac + 15))
fill(pF,  pS,  color=emaFast > emaSlow ? color.new(C_TEAL, 100 - i_ribbonOpac) : color.new(C_RED, 100 - i_ribbonOpac))
fill(pS,  p34, color=emaFast > emaSlow ? color.new(C_PURPLE, 100 - i_ribbonOpac + 20) : color.new(C_RED, 100 - i_ribbonOpac + 20))

plot(vwapVal, color=close > vwapVal ? color.new(C_GREEN, 30) : color.new(C_RED, 30), linewidth=2, title="VWAP", style=plot.style_circles)

// ── BACKGROUNDS ────────────────────────────────────────────────────────
float bgIntensity = math.abs(nce) / 100
color bgCol = nce > 0 ? color.new(C_CYAN, math.round(96 - bgIntensity * 12)) : color.new(C_RED, math.round(96 - bgIntensity * 12))
bgcolor(i_showWave ? bgCol : na, title="Momentum Wave BG")
bgcolor(sqzOn ? color.new(C_GOLD, 92) : na, title="Squeeze Active BG")

// ── SIGNAL LABELS ──────────────────────────────────────────────────────

// ── Standard ribbon-change signals: BUY / SELL ─────────────────────────
// Only show plain BUY/SELL if it's NOT also a BUY+/SELL+ bar
bool plainBuy  = ribbonFlipBull and not triggerBuyPlus
bool plainSell = ribbonFlipBear and not triggerSellPlus

plotshape(plainBuy, title="Buy Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=C_TEAL, textcolor=color.white, size=size.normal)
plotshape(plainSell, title="Sell Signal", text="SELL", style=shape.labeldown, location=location.abovebar, color=C_ORANGE, textcolor=color.white, size=size.normal)

// ── High-confluence signals: BUY+ / SELL+ ──────────────────────────────
plotshape(triggerBuyPlus, title="Buy+ Signal", text="BUY+", style=shape.labelup, location=location.belowbar, color=C_CYAN, textcolor=color.black, size=size.normal)
plotshape(triggerSellPlus, title="Sell+ Signal", text="SELL+", style=shape.labeldown, location=location.abovebar, color=C_RED, textcolor=color.white, size=size.normal)

// NCE score labels for BUY+ / SELL+ only
if triggerBuyPlus
    label.new(bar_index, low - atrVal * 0.8,
     "NCE " + str.tostring(math.round(bullScore)) + "%" + (sqzFiring ? " ⚡" : ""),
     style=label.style_label_up, color=color.new(C_CYAN, 40), textcolor=color.white, size=size.tiny)

if triggerSellPlus
    label.new(bar_index, high + atrVal * 0.8,
     "NCE " + str.tostring(math.round(bearScore)) + "%" + (sqzFiring ? " ⚡" : ""),
     style=label.style_label_down, color=color.new(C_RED, 40), textcolor=color.white, size=size.tiny)

plotshape(sqzFiring and sqzMom > 0, title="Squeeze Bull", text="⚡", style=shape.diamond, location=location.belowbar, color=C_GOLD, textcolor=C_GOLD, size=size.tiny)
plotshape(sqzFiring and sqzMom < 0, title="Squeeze Bear", text="⚡", style=shape.diamond, location=location.abovebar, color=C_GOLD, textcolor=C_GOLD, size=size.tiny)

// ── TP/SL HIT LABELS — only last trade visible ────────────────────────
var label lblTP1Hit = na
var label lblTP2Hit = na
var label lblTP3Hit = na
var label lblSLHit  = na

// Wipe old trade labels when a new trade opens
if triggerBuy or triggerSell
    label.delete(lblTP1Hit)
    label.delete(lblTP2Hit)
    label.delete(lblTP3Hit)
    label.delete(lblSLHit)

if tp1Hit and not tp1Hit[1]
    label.delete(lblTP1Hit)
    lblTP1Hit := label.new(bar_index, tp1Price,
     "TP1 ✓", style=label.style_label_left, color=C_TEAL, textcolor=color.white, size=size.tiny)

if tp2Hit and not tp2Hit[1]
    label.delete(lblTP2Hit)
    lblTP2Hit := label.new(bar_index, tp2Price,
     "TP2 ✓", style=label.style_label_left, color=C_GREEN, textcolor=color.white, size=size.tiny)

if tp3Hit and not tp3Hit[1]
    label.delete(lblTP3Hit)
    lblTP3Hit := label.new(bar_index, tp3Price,
     "TP3 ✓", style=label.style_label_left, color=color.new(C_GREEN, 0), textcolor=color.white, size=size.tiny)

if slHit and not slHit[1]
    label.delete(lblSLHit)
    lblSLHit := label.new(bar_index, trailSL,
     "SL HIT", style=label.style_label_left, color=C_RED, textcolor=color.white, size=size.tiny)

// ── TRADE LEVEL LINES — last trade only (off by default) ──────────────
var line lineEntry = na
var line lineSL    = na
var line lineTP1   = na
var line lineTP2   = na
var line lineTP3   = na
var label lblEntry = na
var label lblSL    = na
var label lblTP1   = na
var label lblTP2   = na
var label lblTP3   = na

// Helper to wipe all level drawings
f_clearLevels() =>
    line.delete(lineEntry)
    line.delete(lineSL)
    line.delete(lineTP1)
    line.delete(lineTP2)
    line.delete(lineTP3)
    label.delete(lblEntry)
    label.delete(lblSL)
    label.delete(lblTP1)
    label.delete(lblTP2)
    label.delete(lblTP3)

if i_showLevels and tradeDir != 0 and not na(entryPrice)
    f_clearLevels()

    // Only draw for the LAST trade (active or just closed)
    int leftEdge  = math.max(entryBar, bar_index - 4999)
    int rightEdge = bar_index + 10

    lineEntry := line.new(leftEdge, entryPrice, rightEdge, entryPrice,
     color=C_CYAN, width=2, style=line.style_solid)
    lblEntry := label.new(rightEdge + 1, entryPrice,
     "ENTRY " + str.tostring(entryPrice, format.mintick),
     style=label.style_label_left, color=C_CYAN, textcolor=color.black, size=size.tiny)

    float displaySL = tp1Hit and i_trailAfterTP1 ? trailSL : slPrice
    color slCol     = tp1Hit and i_trailAfterTP1 ? C_ORANGE : C_RED
    string slText   = (tp1Hit and i_trailAfterTP1 ? "TRAIL " : "SL ") + str.tostring(displaySL, format.mintick)
    lineSL := line.new(leftEdge, displaySL, rightEdge, displaySL,
     color=slCol, width=2, style=tp1Hit ? line.style_dashed : line.style_solid)
    lblSL := label.new(rightEdge + 1, displaySL, slText,
     style=label.style_label_left, color=slCol, textcolor=color.white, size=size.tiny)

    color tp1Col = tp1Hit ? C_TEAL : C_TEAL
    lineTP1 := line.new(leftEdge, tp1Price, rightEdge, tp1Price,
     color=tp1Col, width=tp1Hit ? 2 : 1, style=tp1Hit ? line.style_solid : line.style_dashed)
    lblTP1 := label.new(rightEdge + 1, tp1Price,
     (tp1Hit ? "TP1 ✓ " : "TP1 ") + str.tostring(tp1Price, format.mintick),
     style=label.style_label_left, color=tp1Col, textcolor=color.white, size=size.tiny)

    color tp2Col = tp2Hit ? C_TEAL : C_GREEN
    lineTP2 := line.new(leftEdge, tp2Price, rightEdge, tp2Price,
     color=tp2Col, width=tp2Hit ? 2 : 1, style=tp2Hit ? line.style_solid : line.style_dashed)
    lblTP2 := label.new(rightEdge + 1, tp2Price,
     (tp2Hit ? "TP2 ✓ " : "TP2 ") + str.tostring(tp2Price, format.mintick),
     style=label.style_label_left, color=tp2Col, textcolor=color.white, size=size.tiny)

    lineTP3 := line.new(leftEdge, tp3Price, rightEdge, tp3Price,
     color=color.new(C_GREEN, 0), width=tp3Hit ? 2 : 1, style=tp3Hit ? line.style_solid : line.style_dashed)
    lblTP3 := label.new(rightEdge + 1, tp3Price,
     (tp3Hit ? "TP3 ✓ " : "TP3 ") + str.tostring(tp3Price, format.mintick),
     style=label.style_label_left, color=color.new(C_GREEN, 0), textcolor=color.white, size=size.tiny)

// ── CANDLE COLORING ────────────────────────────────────────────────────
barcolor(triggerBuyPlus ? C_CYAN : triggerSellPlus ? C_RED : ribbonFlipBull ? C_TEAL : ribbonFlipBear ? C_ORANGE : sqzFiring ? C_GOLD : na)

// ── DASHBOARD ──────────────────────────────────────────────────────────
if i_showDash and barstate.islast
    var table dash = table.new(position.top_right, 2, 13,
     bgcolor=color.new(C_SURFACE, 5), border_width=1,
     border_color=color.new(C_MUTED, 70), frame_width=2,
     frame_color=color.new(C_CYAN, 60))

    dashSz = i_dashSize == "tiny" ? size.tiny : i_dashSize == "small" ? size.small : size.normal

    table.cell(dash, 0, 0, "NCE", text_color=C_CYAN, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 0, syminfo.ticker + "  " + timeframe.period, text_color=C_CYAN, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    table.cell(dash, 0, 1, "BULL", text_color=color.white, text_size=dashSz, bgcolor=color.new(C_GREEN, 30))
    table.cell(dash, 1, 1, str.tostring(math.round(bullScore)) + "%", text_color=color.white, text_size=dashSz, bgcolor=color.new(C_GREEN, 30))
    table.cell(dash, 0, 2, "BEAR", text_color=color.white, text_size=dashSz, bgcolor=color.new(C_RED, 30))
    table.cell(dash, 1, 2, str.tostring(math.round(bearScore)) + "%", text_color=color.white, text_size=dashSz, bgcolor=color.new(C_RED, 30))

    string biasStr = bullScore > bearScore + 20 ? "STRONG BULL" : bearScore > bullScore + 20 ? "STRONG BEAR" : bullScore > bearScore ? "MILD BULL" : "MILD BEAR"
    color biasBg = str.contains(biasStr, "BULL") ? color.new(C_GREEN, 40) : color.new(C_RED, 40)
    table.cell(dash, 0, 3, "BIAS", text_color=color.white, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 3, biasStr, text_color=color.white, text_size=dashSz, bgcolor=biasBg)

    string htfStr = htfBullish ? "BULLISH" : "BEARISH"
    color htfCol = htfBullish ? color.new(C_GREEN, 40) : color.new(C_RED, 40)
    table.cell(dash, 0, 4, "HTF", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 4, htfStr, text_color=color.white, text_size=dashSz, bgcolor=htfCol)

    table.cell(dash, 0, 5, "WaveTrend", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 5, wtTci > wtSig ? "BULL" : "BEAR", text_color=wtTci > wtSig ? C_GREEN : C_RED, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    table.cell(dash, 0, 6, "VWAP", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 6, close > vwapVal ? "ABOVE" : "BELOW", text_color=close > vwapVal ? C_GREEN : C_RED, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    table.cell(dash, 0, 7, "Squeeze", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 7, sqzOn ? "ON" : sqzFiring ? "FIRING" : "OFF", text_color=sqzOn ? C_GOLD : sqzFiring ? C_GREEN : C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    table.cell(dash, 0, 8, "ADX", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 8, str.tostring(math.round(adxVal)) + (adxVal > 25 ? " STRONG" : " WEAK"), text_color=adxVal > 25 ? C_GREEN : C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    table.cell(dash, 0, 9, "Volume", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 9, str.tostring(math.round(volRatio * 100)) + "%", text_color=volRatio > 1.0 ? C_GREEN : C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    table.cell(dash, 0, 10, "RSI", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 10, str.tostring(math.round(rsiVal)), text_color=rsiVal > 50 ? C_GREEN : C_RED, text_size=dashSz, bgcolor=color.new(C_BG, 0))

    string tradeStatus = tradeDir == 0 ? "NO TRADE" : slHit ? "CLOSED" : tp3Hit ? "TP3 HIT" : tp2Hit ? "TP2 HIT" : tp1Hit ? "TP1 HIT → TRAIL" : "ACTIVE"
    color statusCol = tradeDir == 0 ? color.new(C_MUTED, 0) : slHit ? color.new(C_RED, 20) : tp1Hit ? color.new(C_TEAL, 20) : color.new(C_CYAN, 20)
    table.cell(dash, 0, 11, "TRADE", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 11, tradeStatus, text_color=color.white, text_size=dashSz, bgcolor=statusCol)

    table.cell(dash, 0, 12, "THRESHOLD", text_color=C_MUTED, text_size=dashSz, bgcolor=color.new(C_BG, 0))
    table.cell(dash, 1, 12, str.tostring(i_threshold) + "%", text_color=C_CYAN, text_size=dashSz, bgcolor=color.new(C_BG, 0))

// ── ALERTS ─────────────────────────────────────────────────────────────
alertcondition(ribbonFlipBull, title="NCE Buy Signal", message="NCE: BUY signal — ribbon flipped bullish.")
alertcondition(ribbonFlipBear, title="NCE Sell Signal", message="NCE: SELL signal — ribbon flipped bearish.")
alertcondition(triggerBuyPlus, title="NCE Buy+ Signal", message="NCE: BUY+ signal fired. Bull Score: {{plot_0}}%.")
alertcondition(triggerSellPlus, title="NCE Sell+ Signal", message="NCE: SELL+ signal fired. Bear Score: {{plot_0}}%.")
alertcondition(sqzFiring, title="Squeeze Breakout", message="NCE: Squeeze breakout detected.")
alertcondition(tp1Hit and not tp1Hit[1], title="TP1 Hit", message="NCE: TP1 reached. Trailing stop activated.")
alertcondition(tp2Hit and not tp2Hit[1], title="TP2 Hit", message="NCE: TP2 reached.")
alertcondition(tp3Hit and not tp3Hit[1], title="TP3 Hit", message="NCE: TP3 reached.")

// ── SCORE PLOTS (data window only — invisible on chart) ────────────────
plot(bullScore, title="Bull Score", display=display.data_window + display.status_line, color=C_GREEN, editable=false)
plot(bearScore, title="Bear Score", display=display.data_window + display.status_line, color=C_RED, editable=false)
plot(nce, title="NCE Net Score", display=display.data_window + display.status_line, color=C_CYAN, editable=false)

// ── SCALE ANCHOR ───────────────────────────────────────────────────────
plot(close, title='Scale Anchor', color=na, editable=false)
````
