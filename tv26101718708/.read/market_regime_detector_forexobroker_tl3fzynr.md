# Market Regime Detector [forexobroker]

- url: https://www.tradingview.com/script/tL3FZynR-Market-Regime-Detector-forexobroker/
- type: indicator
- pine_id: PUB;f64fb856f1fb43b19cfb649558509464
- version: 1.0

## Description

Market Regime Detector is an overlay indicator that automatically classifies current market conditions into one of three regimes — Trending, Ranging, or Volatile — and adapts its signal logic accordingly. In trending regimes, it generates signals based on EMA crossovers in the direction of the larger trend. In ranging regimes, it switches to Bollinger Band bounce signals with RSI confirmation. In volatile regimes, it suppresses signals entirely to protect traders from whipsaws.

The core problem this solves is strategy mismatch. Most indicators use a single logic for all conditions, generating trend-following signals in sideways markets (resulting in losses) or mean-reversion signals in strong trends (resulting in missed moves). By first identifying the regime and then applying the appropriate strategy, this indicator dramatically reduces false signals caused by using the wrong tool for the current environment.

This tool is designed for traders who want their analysis to automatically adapt to changing market conditions rather than manually switching between strategies.

🔶 CONCEPTS

Market regime theory recognizes that financial markets alternate between distinct behavioral states. In trending regimes, price moves directionally with momentum — trend-following strategies work well, and mean-reversion strategies fail. In ranging regimes, price oscillates between support and resistance — mean-reversion strategies work well, and trend-following signals produce whipsaws. In volatile regimes, price moves erratically with wide ranges and frequent reversals — most strategies struggle.

The detector uses three independent measurements to classify regimes: ADX (Average Directional Index) measures trend strength, Bollinger Band width percentile measures volatility expansion relative to history, and ATR percentile rank measures absolute volatility. By combining these metrics with specific thresholds, the indicator achieves reliable regime classification that updates in real time.

🔶 HOW IT WORKS

• ADX is calculated over a configurable period — values above the trend threshold (default 25) indicate trending conditions, values below the range threshold (default 20) indicate ranging conditions
• Bollinger Band width is ranked as a percentile over 100 bars, and ATR is similarly ranked — high ATR percentile (above 80) flags volatile conditions regardless of ADX
• The regime priority is Volatile > Trending > Ranging, ensuring that extreme volatility always takes precedence
• In trending regimes, buy signals fire on EMA 9 crossing above EMA 21 with price above EMA 50 and volume confirmation; sell signals use the inverse
• In ranging regimes, buy signals fire when price touches the lower Bollinger Band with RSI below the oversold level and volume confirmation; sell signals use the inverse conditions at the upper band
• In volatile regimes, no signals are generated — the dashboard shows "NO TRADE" to protect capital

🔶 HOW TO USE

1. Add the indicator to any chart — the regime classification appears immediately in the dashboard and as a background color (green for trending, blue for ranging, red for volatile)
2. Pay attention to regime change vertical lines — dashed lines with labels mark exactly where the market shifted from one regime to another
3. When a signal fires, the label shows whether it came from a trend strategy (EMA Cross) or range strategy (BB Bounce), so you understand the logic behind it
4. In volatile regimes, respect the "NO TRADE" indication — sitting out during extreme volatility is a valid and often profitable strategy in itself

🔶 FEATURES

• Non-repainting signals (uses barstate.isconfirmed)
• Works on all timeframes and instruments
• 9 alert conditions with webhook JSON support (including individual regime change alerts)
• Professional dashboard display with ADX, BB Width, and ATR rank readings
• Regime change vertical lines for clear visual transition markers
• Dual strategy engine that automatically selects the appropriate signal logic

🔶 SETTINGS GUIDE

• ADX Length — Period for ADX calculation (default: 14)
• ADX Trend Threshold — ADX above this classifies as trending (default: 25)
• ADX Range Threshold — ADX below this classifies as ranging (default: 20)
• Bollinger Length / Multiplier — Parameters for BB width and bounce signals (default: 20 / 2.0)
• ATR Length — Period for ATR volatility measurement (default: 14)
• ATR Volatility Percentile — ATR rank above this classifies as volatile (default: 80)
• EMA Fast / Slow — EMA periods for trending signal crossovers (default: 9 / 21)
• RSI Length — RSI period for ranging signal confirmation (default: 14)
• RSI Overbought / Oversold — RSI levels for ranging signal triggers (default: 65 / 35)
• Signal Cooldown — Minimum bars between consecutive signals (default: 15)
• Volume Multiplier — Volume must exceed SMA by this factor (default: 1.0)
• Show Regime Background / Change Lines / Dashboard — Visual toggles

🔶 ALERTS

• MRD Buy Signal — Fires on any confirmed buy signal (trend or range strategy)
• MRD Sell Signal — Fires on any confirmed sell signal
• MRD Any Signal — Fires on any confirmed signal
• Regime Change: Trending — Fires when market shifts to trending regime
• Regime Change: Ranging — Fires when market shifts to ranging regime
• Regime Change: Volatile — Fires when market shifts to volatile regime
• Strong Trend ADX>35 — Fires when ADX exceeds 35, indicating a powerful trend
• Extreme Volatility — Fires when ATR rank exceeds the 90th percentile
• Low Volatility Squeeze — Fires when BB width rank is below 10% and ADX below 15, signaling a potential breakout setup
• Webhook JSON — JSON-formatted alert for automated bot trading

🔶 LIMITATIONS & DISCLAIMER

• This is a technical analysis tool, not financial advice
• Past patterns do not guarantee future results
• Best used alongside price action context and proper risk management
• Regime transitions can be noisy near threshold boundaries, causing brief flickers between states
• The ranging strategy performs best in clearly defined ranges — during slow, drifting markets that are technically "ranging" by ADX but lack clear boundaries, BB bounce signals may be less reliable

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Market Regime Detector [forexobroker]", shorttitle="MRD [fob]", overlay=true, max_labels_count=500)

// ── Inputs: Regime Detection ──
adxLen       = input.int(14, "ADX Length", minval=2, group="Regime Detection")
adxTrendThr  = input.int(25, "ADX Trend Threshold", minval=15, maxval=50, group="Regime Detection", tooltip="ADX above this = trending")
adxRangeThr  = input.int(20, "ADX Range Threshold", minval=5, maxval=40, group="Regime Detection", tooltip="ADX below this = ranging")
bbLen        = input.int(20, "Bollinger Length", minval=5, group="Regime Detection")
bbMult       = input.float(2.0, "Bollinger Multiplier", minval=0.5, step=0.1, group="Regime Detection")
atrLen       = input.int(14, "ATR Length", minval=2, group="Regime Detection")
atrVolPct    = input.int(80, "ATR Volatility Percentile", minval=50, maxval=99, group="Regime Detection", tooltip="ATR rank above this = volatile")

// ── Inputs: Trend Signals ──
emaFast      = input.int(9, "EMA Fast", minval=2, group="Trending Signals")
emaSlow      = input.int(21, "EMA Slow", minval=5, group="Trending Signals")

// ── Inputs: Range Signals ──
rsiLen       = input.int(14, "RSI Length", minval=2, group="Ranging Signals")
rsiOB        = input.int(65, "RSI Overbought", minval=55, maxval=90, group="Ranging Signals")
rsiOS        = input.int(35, "RSI Oversold", minval=10, maxval=45, group="Ranging Signals")

// ── Inputs: Filters ──
cooldownBars = input.int(15, "Signal Cooldown", minval=1, group="Filters")
volMulti     = input.float(1.0, "Volume Multiplier", minval=0.5, step=0.1, group="Filters")

// ── Inputs: Display ──
showDash     = input.bool(true, "Show Dashboard", group="Display")
showRegimeBG = input.bool(true, "Show Regime Background", group="Display")
showChanges  = input.bool(true, "Show Regime Change Lines", group="Display")

// ── Core Calculations ──
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
ema9   = ta.ema(close, emaFast)
ema21  = ta.ema(close, emaSlow)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
rsiVal = ta.rsi(close, rsiLen)

// Bollinger Bands
bbBasis = ta.sma(close, bbLen)
bbDev   = ta.stdev(close, bbLen) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbWidth = (bbUpper - bbLower) / bbBasis * 100

// ATR
atrVal = ta.atr(atrLen)

// ── Percentile Rank Functions ──
bbWidthRank = ta.percentrank(bbWidth, 100)
atrRank     = ta.percentrank(atrVal, 100)

// Volume filter
volAvg = ta.sma(volume, 20)
volOk  = volume > volAvg * volMulti

// ── Regime Classification ──
isTrending = adxVal > adxTrendThr and bbWidthRank > 30 and atrRank < atrVolPct
isVolatile = atrRank > atrVolPct or bbWidthRank > 80
isRanging  = adxVal < adxRangeThr and bbWidthRank < 30

// Priority: Volatile > Trending > Ranging > default Ranging
// 0 = Ranging, 1 = Trending, 2 = Volatile
regime = isVolatile ? 2 : isTrending ? 1 : isRanging ? 0 : 0
var int prevRegime = 0
regimeChanged = regime != prevRegime
prevRegime := regime

// Trend direction
trendDir = close > ema50 and ema50 > ema200 ? 1 : close < ema50 and ema50 < ema200 ? -1 : 0

// ── Signal Cooldown ──
var int lastBuy  = 0
var int lastSell = 0
lastBuy  := lastBuy + 1
lastSell := lastSell + 1

// ── Regime-Adaptive Signals ──
// Trending signals: EMA cross in trend direction with volume
trendBullCross = ta.crossover(ema9, ema21) and close > ema50 and volOk
trendBearCross = ta.crossunder(ema9, ema21) and close < ema50 and volOk

// Ranging signals: BB bounce + RSI
rangeBuy  = close <= bbLower and rsiVal < rsiOS and volOk
rangeSell = close >= bbUpper and rsiVal > rsiOB and volOk

// Apply regime filter + confirmation + cooldown
buySignal  = barstate.isconfirmed and lastBuy > cooldownBars and ((regime == 1 and trendBullCross) or (regime == 0 and rangeBuy))
sellSignal = barstate.isconfirmed and lastSell > cooldownBars and ((regime == 1 and trendBearCross) or (regime == 0 and rangeSell))

if buySignal
    lastBuy := 0
if sellSignal
    lastSell := 0

// Signal source text
buySource  = regime == 1 ? "TREND: EMA Cross" : "RANGE: BB Bounce"
sellSource = regime == 1 ? "TREND: EMA Cross" : "RANGE: BB Bounce"

// ── Visual: EMA Plots with Glow ──
emaColor = close > ema50 ? #39ff14 : #ff2d78
plot(ema50, "EMA50 Glow", color=color.new(emaColor, 75), linewidth=5)
plot(ema50, "EMA50 Core", color=color.new(emaColor, 20), linewidth=2)
plot(ema9, "EMA Fast", color=color.new(#00d4ff, 40), linewidth=1)
plot(ema21, "EMA Slow", color=color.new(#ffaa00, 40), linewidth=1)

// Bollinger Bands (subtle, for ranging context)
p1 = plot(bbUpper, "BB Upper", color=color.new(#888888, 70), linewidth=1)
p2 = plot(bbLower, "BB Lower", color=color.new(#888888, 70), linewidth=1)
fill(p1, p2, color=regime == 0 ? color.new(#00d4ff, 94) : color.new(#888888, 96), title="BB Fill")

// ── 3-Layer Glow Arrows ──
plotshape(buySignal, "Buy Glow3", shape.labelup, location.belowbar, color=color.new(#39ff14, 70), size=size.huge)
plotshape(buySignal, "Buy Glow2", shape.labelup, location.belowbar, color=color.new(#39ff14, 40), size=size.large)
plotshape(buySignal, "Buy Core", shape.labelup, location.belowbar, color=#39ff14, size=size.normal, text="BUY", textcolor=color.white)
plotshape(sellSignal, "Sell Glow3", shape.labeldown, location.abovebar, color=color.new(#ff2d78, 70), size=size.huge)
plotshape(sellSignal, "Sell Glow2", shape.labeldown, location.abovebar, color=color.new(#ff2d78, 40), size=size.large)
plotshape(sellSignal, "Sell Core", shape.labeldown, location.abovebar, color=#ff2d78, size=size.normal, text="SELL", textcolor=color.white)

// ── Signal Labels with Regime Context ──
if buySignal
    label.new(bar_index, low, buySource, style=label.style_label_up, color=color.new(#39ff14, 50), textcolor=color.white, size=size.tiny)
if sellSignal
    label.new(bar_index, high, sellSource, style=label.style_label_down, color=color.new(#ff2d78, 50), textcolor=color.white, size=size.tiny)

// ── Regime Background ──
regimeColorBG = regime == 1 ? color.new(#39ff14, 96) : regime == 2 ? color.new(#ff2d78, 96) : color.new(#00d4ff, 96)
bgcolor(showRegimeBG ? regimeColorBG : na, title="Regime Background")

// ── Bar Coloring ──
regimeBarCol = regime == 1 ? color.new(#39ff14, 60) : regime == 2 ? color.new(#ff2d78, 60) : color.new(#00d4ff, 60)
barcolor(regimeBarCol, title="Regime Bar Color")

// ── Regime Change Vertical Lines ──
if showChanges and regimeChanged
    regLabel = regime == 1 ? "TRENDING" : regime == 2 ? "VOLATILE" : "RANGING"
    regCol = regime == 1 ? #39ff14 : regime == 2 ? #ff2d78 : #00d4ff
    line.new(bar_index, low, bar_index, high, color=regCol, width=2, style=line.style_dashed)
    label.new(bar_index, high, regLabel, style=label.style_label_down, color=color.new(regCol, 30), textcolor=color.white, size=size.tiny)

// ── Dashboard Table ──
if showDash and barstate.islastconfirmedhistory
    var table t = table.new(position.top_right, 3, 7, bgcolor=color.new(color.black, 20), frame_width=1, frame_color=color.gray)

    // Row 0: Header
    table.cell(t, 0, 0, "MARKET REGIME", text_color=#00d4ff, text_size=size.small)
    table.cell(t, 1, 0, "DETECTOR", text_color=#00d4ff, text_size=size.small)
    table.cell(t, 2, 0, syminfo.ticker, text_color=color.white, text_size=size.small)

    // Row 1: Current Regime
    regText = regime == 1 ? "TRENDING" : regime == 2 ? "VOLATILE" : "RANGING"
    regCol2 = regime == 1 ? #39ff14 : regime == 2 ? #ff2d78 : #00d4ff
    table.cell(t, 0, 1, "Regime", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, regText, text_color=regCol2, text_size=size.small)
    regIcon = regime == 1 ? ">>>" : regime == 2 ? "!!!" : "==="
    table.cell(t, 2, 1, regIcon, text_color=regCol2, text_size=size.small)

    // Row 2: ADX
    adxCol = adxVal > adxTrendThr ? #39ff14 : adxVal < adxRangeThr ? #00d4ff : #ffaa00
    table.cell(t, 0, 2, "ADX", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(adxVal, "#.#"), text_color=adxCol, text_size=size.small)
    adxBar = adxVal > 40 ? "||||" : adxVal > 30 ? "|||" : adxVal > 20 ? "||" : "|"
    table.cell(t, 2, 2, adxBar, text_color=adxCol, text_size=size.small)

    // Row 3: BB Width Rank
    bbCol = bbWidthRank > 70 ? #ff2d78 : bbWidthRank < 30 ? #00d4ff : #ffaa00
    table.cell(t, 0, 3, "BB Width", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(bbWidthRank, "#") + "%", text_color=bbCol, text_size=size.small)
    bbBar = bbWidthRank > 75 ? "||||" : bbWidthRank > 50 ? "|||" : bbWidthRank > 25 ? "||" : "|"
    table.cell(t, 2, 3, bbBar, text_color=bbCol, text_size=size.small)

    // Row 4: ATR Rank
    atrCol = atrRank > atrVolPct ? #ff2d78 : atrRank < 30 ? #00d4ff : #ffaa00
    table.cell(t, 0, 4, "ATR Rank", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(atrRank, "#") + "%", text_color=atrCol, text_size=size.small)
    atrBar = atrRank > 75 ? "||||" : atrRank > 50 ? "|||" : atrRank > 25 ? "||" : "|"
    table.cell(t, 2, 4, atrBar, text_color=atrCol, text_size=size.small)

    // Row 5: Trend Direction
    dirText = trendDir == 1 ? "BULL" : trendDir == -1 ? "BEAR" : "FLAT"
    dirCol = trendDir == 1 ? #39ff14 : trendDir == -1 ? #ff2d78 : #ffaa00
    table.cell(t, 0, 5, "Trend", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 5, dirText, text_color=dirCol, text_size=size.small)
    table.cell(t, 2, 5, str.tostring(close, format.mintick), text_color=color.white, text_size=size.small)

    // Row 6: Signal Status
    sigText = buySignal ? "BUY" : sellSignal ? "SELL" : regime == 2 ? "NO TRADE" : "WAIT"
    sigCol = buySignal ? #39ff14 : sellSignal ? #ff2d78 : regime == 2 ? #ff2d78 : #ffaa00
    table.cell(t, 0, 6, "Signal", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 6, sigText, text_color=sigCol, text_size=size.small)
    sigReason = regime == 2 ? "High Vol" : regime == 1 ? "EMA Cross" : "BB+RSI"
    table.cell(t, 2, 6, sigReason, text_color=color.gray, text_size=size.small)

// ── Dynamic JSON Alerts ──
if buySignal
    alert('{"indicator":"MRD","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","action":"BUY","regime":"' + (regime == 1 ? "TRENDING" : "RANGING") + '","source":"' + buySource + '","adx":"' + str.tostring(adxVal, "#.#") + '","price":"' + str.tostring(close, format.mintick) + '"}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"indicator":"MRD","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","action":"SELL","regime":"' + (regime == 1 ? "TRENDING" : "RANGING") + '","source":"' + sellSource + '","adx":"' + str.tostring(adxVal, "#.#") + '","price":"' + str.tostring(close, format.mintick) + '"}', alert.freq_once_per_bar_close)

// ── Alert Conditions ──
alertcondition(buySignal, "MRD Buy Signal", "BUY {{ticker}} {{interval}} @ {{close}}")
alertcondition(sellSignal, "MRD Sell Signal", "SELL {{ticker}} {{interval}} @ {{close}}")
alertcondition(buySignal or sellSignal, "MRD Any Signal", "Signal on {{ticker}} {{interval}} @ {{close}}")
alertcondition(regime == 1 and regime[1] != 1, "Regime Change: Trending", "Trending regime on {{ticker}} {{interval}}")
alertcondition(regime == 0 and regime[1] != 0, "Regime Change: Ranging", "Ranging regime on {{ticker}} {{interval}}")
alertcondition(regime == 2 and regime[1] != 2, "Regime Change: Volatile", "Volatile regime on {{ticker}} {{interval}}")
alertcondition(adxVal > 35, "Strong Trend ADX>35", "ADX > 35 strong trend on {{ticker}} {{interval}}")
alertcondition(atrRank > 90, "Extreme Volatility", "Extreme ATR rank on {{ticker}} {{interval}}")
alertcondition(bbWidthRank < 10 and adxVal < 15, "Low Volatility Squeeze", "BB squeeze detected on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal, "Webhook JSON", '{"ticker":"{{ticker}}","interval":"{{interval}}","price":"{{close}}","time":"{{time}}"}')
````
