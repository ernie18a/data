# Q Neon Pulse

- url: https://www.tradingview.com/script/qSMs4T7b-Q-Neon-Pulse/
- type: indicator
- pine_id: PUB;4b143ef8c60f4dc398bf0080f0d820e2
- version: 1.0

## Description

Q Neon Pulse

OVERVIEW
Most signal indicators apply the same logic in every market condition: trend tools keep firing in sideways markets, while mean-reversion tools keep fading strong trends. Q Neon Pulse takes a different approach: it first classifies the current market regime, then enables only the signal logic designed for that environment. When conditions are unclear, it deliberately stays silent.

The script combines ADX/DMI, EMAs, Bollinger Bands and the Keltner Channel into one regime engine. These components are not used as independent signal generators; each has a defined role inside the regime engine, and the active regime decides which entry logic is allowed.

THE FOUR REGIMES

1. TREND (up / down)
ADX is above the threshold, the directional index agrees with the direction (+DI > −DI for up, −DI > +DI for down), the fast EMA is above/below the slow EMA, and price is on the same side of the slow EMA.
Signal: pullback continuation. Price returns to the fast EMA, then a candle closes back in the trend direction and breaks the previous bar's high (buy) or low (sell).
Marker: triangle.

2. RANGE
All of the following must be true:
- ADX is below the threshold and not rising (at or below its 5-bar average)
- the slow EMA has moved less than 1 ATR over the last 10 bars (flat slope)
- Bollinger Band width is not expanding (within 15% of its average)
- price has crossed the Bollinger basis at least twice within the band length (real rotation, not drift)
Signal: band rejection. Price touches the outer Bollinger Band and closes back inside with a directional rejection candle away from the band. Range signals are blocked while ADX is rising, to avoid fading the start of a breakout.
Marker: diamond.

3. SQUEEZE
Bollinger Bands are fully inside the Keltner Channel, so volatility is compressed. While the squeeze lasts, the indicator tracks the high and low of the compression zone ("coil") and draws them as yellow lines.
Signal: breakout. A candle closes beyond the coil high or low, either during the squeeze or within the Breakout Window after it ends. The squeeze must last a minimum number of bars, and only one breakout signal is allowed per squeeze.
Marker: flag.

4. NEUTRAL
Anything that is not a confirmed trend, a true range or a squeeze: transitions, reversals, chaotic volatility. No signals are produced, and candles keep their standard colors. Standard candles indicate that the market is not confidently classified as Trend, Range or Squeeze — a stand-aside condition.

A new regime is accepted only after it holds for a set number of bars (Regime Confirm Bars), which prevents the regime from flickering bar to bar.

SIGNALS
- All signals are calculated on bar close only and do not repaint.
- Strict Alternation (on by default): after a BUY the next signal must be a SELL, and vice versa. Turn it off to allow repeated same-direction signals, for example a second pullback in an ongoing trend.
- Each signal type (Trend / Range / Breakout) can be switched on or off individually.

VISUALS
- Regime background for TREND and SQUEEZE
- Candles colored by regime (bright for up candles, dimmed for down candles); standard candles in NEUTRAL
- Fast EMA glows during TREND, Bollinger Bands glow during RANGE, coil lines appear during SQUEEZE
- Status panel: current regime, ADX value with threshold and strength (Weak / Strong), and the last signal with its type
- Optional T / R / B letters on markers and an optional background flash on signals

ALERTS
- Buy, Sell, Any Signal
- Regime Change
- Squeeze Start (volatility compression has begun, a breakout setup is forming)

SETTINGS
Regime: ADX length and trend threshold, band length, Bollinger and Keltner widths, minimum squeeze bars, breakout window, regime confirmation bars, fast/slow EMA.
Signals: strict alternation, individual signal types.
Style: regime colors and display toggles.

HOW TO USE
- Designed for liquid markets with clear regime shifts: index futures, gold, major FX pairs, large-cap crypto.
- Typical timeframes: 15m to 4H. Lower timeframes may benefit from stricter regime confirmation, while higher timeframes may work well with more permissive thresholds. Tune settings to the instrument and timeframe being traded.
- Use the regime as context first and the signal second. A trend signal inside a clean trend regime carries different information than a range signal near the end of a range.
- Signals are not a complete trading system. Combine them with your own risk management, position sizing and higher-timeframe analysis.

DISCLAIMER

This script is provided for educational and informational purposes only. It does not constitute financial advice. Past behavior of any indicator does not guarantee future results. Always test on your own markets and timeframes before using it in live trading.

[i]Trade with clarity — stay for quality.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quantora

//@version=6
indicator("Q Neon Pulse", shorttitle="QNPulse Regime", overlay=true)

// ═══════════════════════════════════════════════════════════════
// Q Neon Pulse
//
// The market is not always trending. This indicator first classifies
// the current regime, then applies the logic that fits it:
//
//   TREND   (ADX strong + DI + EMAs aligned)     → pullback continuation  ▲▼
//   RANGE   (ADX weak & falling, flat EMA,
//            stable band width, ≥2 basis crosses) → fade at Bollinger edge  ◆
//   SQUEEZE (Bollinger inside Keltner)           → breakout of the coil    ⚑
//   NEUTRAL (none of the above)                  → no signals, stand aside
//
// • Optional strict alternation: BUY → SELL → BUY
// • Calculated on bar close only — no repainting
// ═══════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────
// INPUTS
// ───────────────────────────────────────────────────────────────
grpR = "Regime"
adxLen      = input.int(14,    "ADX Length",          minval=1,   group=grpR)
adxTrend    = input.float(22,  "ADX Trend Threshold", minval=1,   step=1,   group=grpR,
     tooltip="ADX above this + aligned EMAs = TREND. Below = RANGE or NEUTRAL.")
bbLen       = input.int(20,    "Bands Length",        minval=2,   group=grpR)
bbMult      = input.float(2.0, "Bollinger Width",     minval=0.1, step=0.1, group=grpR)
kcMult      = input.float(1.5, "Keltner Width",       minval=0.1, step=0.1, group=grpR,
     tooltip="SQUEEZE = Bollinger Bands fully inside Keltner Channel.")
minSqzBars  = input.int(5,     "Min Squeeze Bars",    minval=1,   maxval=50, group=grpR,
     tooltip="Squeeze must last at least this many bars before a breakout signal is allowed. One breakout per squeeze.")
boWindowLen = input.int(8,     "Breakout Window",     minval=1,   maxval=30, group=grpR,
     tooltip="Bars after the squeeze ends during which a breakout signal is still valid.")
confirmBars = input.int(2,     "Regime Confirm Bars", minval=1,   maxval=10, group=grpR,
     tooltip="Bars a new regime must hold before it is accepted. Filters flicker.")
fastLen     = input.int(21,    "Fast EMA",            minval=1,   group=grpR)
slowLen     = input.int(55,    "Slow EMA",            minval=1,   group=grpR)

grpS = "Signals"
useAlt       = input.bool(true, "Strict Alternation (BUY → SELL → BUY)", group=grpS,
     tooltip="ON: a signal in the same direction as the last one is skipped.\nOFF: repeated same-direction signals are allowed (e.g. a second trend pullback).")
showTrendSig = input.bool(true, "Trend signals  ▲▼",  group=grpS)
showRangeSig = input.bool(true, "Range signals  ◆",   group=grpS)
showBoSig    = input.bool(true, "Breakout signals  ⚑", group=grpS)

grpV = "Style"
cBull    = input.color(#00FFC6, "Trend Bull", group=grpV, inline="c1")
cBear    = input.color(#FF2BD6, "Trend Bear", group=grpV, inline="c1")
cRange   = input.color(#8C7CFF, "Range",      group=grpV, inline="c2")
cSqz     = input.color(#FFE600, "Squeeze",    group=grpV, inline="c2")
showLetters = input.bool(false, "Signal Letters (T / R / B)", group=grpV)
showBg      = input.bool(true, "Regime Background", group=grpV)
showLines   = input.bool(true, "Neon Lines",        group=grpV)
showCandles = input.bool(true, "Color Candles",     group=grpV)
showFlash   = input.bool(false, "Signal Flash",     group=grpV)
showTable   = input.bool(true, "Status Panel",      group=grpV)

// ───────────────────────────────────────────────────────────────
// REGIME ENGINE
// ───────────────────────────────────────────────────────────────
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

fastMa = ta.ema(close, fastLen)
slowMa = ta.ema(close, slowLen)

basis = ta.sma(close, bbLen)
dev   = ta.stdev(close, bbLen) * bbMult
bbUp  = basis + dev
bbLo  = basis - dev
kcRng = ta.atr(bbLen) * kcMult
kcUp  = basis + kcRng
kcLo  = basis - kcRng

squeeze = bbUp < kcUp and bbLo > kcLo

// True range-ness: weak & non-rising ADX, flat slow EMA, stable band width, price rotating around basis
atrV      = math.max(ta.atr(adxLen), syminfo.mintick)
bbw       = basis != 0 ? (bbUp - bbLo) / basis : 0.0
adxCalm   = adx < adxTrend and adx <= ta.sma(adx, 5)
flatSlope = math.abs(slowMa - slowMa[10]) / atrV <= 1.0
bbwStable = bbw <= ta.sma(bbw, bbLen) * 1.15
crossCnt  = math.sum(ta.cross(close, basis) ? 1 : 0, bbLen)
rotating  = crossCnt >= 2
isRange   = adxCalm and flatSlope and bbwStable and rotating

// 1 = trend up, -1 = trend down, 0 = range, 2 = squeeze, 3 = neutral
rawReg = squeeze ? 2 :
     adx >= adxTrend and diPlus > diMinus and fastMa > slowMa and close > slowMa ?  1 :
     adx >= adxTrend and diMinus > diPlus and fastMa < slowMa and close < slowMa ? -1 :
     isRange ? 0 : 3

// Regime with confirmation (hysteresis)
var int regime  = 3
var int pending = 3
var int pendCnt = 0
if rawReg == regime
    pendCnt := 0
else if rawReg == pending
    pendCnt += 1
else
    pending := rawReg
    pendCnt := 1
if pendCnt >= confirmBars
    regime  := pending
    pendCnt := 0

// ───────────────────────────────────────────────────────────────
// SIGNAL LOGIC PER REGIME
// ───────────────────────────────────────────────────────────────
rng       = high - low
bodyRatio = rng > 0 ? math.abs(close - open) / rng : 0.0

// TREND: pullback to fast EMA, strong bar, breaks previous bar
trendL = regime ==  1 and (low  <= fastMa or low[1]  <= fastMa[1]) and close > fastMa and close > open and close > high[1]
trendS = regime == -1 and (high >= fastMa or high[1] >= fastMa[1]) and close < fastMa and close < open and close < low[1]

// RANGE: band touch + rejection back inside, ADX not rising
adxFlat = adx <= adx[1]
rangeL = regime == 0 and adxFlat and (low  <= bbLo or low[1]  <= bbLo[1]) and close > bbLo and close > open and close > close[1] and bodyRatio >= 0.4
rangeS = regime == 0 and adxFlat and (high >= bbUp or high[1] >= bbUp[1]) and close < bbUp and close < open and close < close[1] and bodyRatio >= 0.4

// SQUEEZE: track the coil, signal on close beyond it (during or within Breakout Window after)
var float sqHi     = na
var float sqLo     = na
var int   sqLen    = 0
var int   sqEndBar = na
var bool  sqArmed  = false   // one breakout per squeeze
boWindow = squeeze or (not na(sqEndBar) and bar_index - sqEndBar <= boWindowLen)
boL = sqArmed and boWindow and sqLen >= minSqzBars and close > sqHi and close > open
boS = sqArmed and boWindow and sqLen >= minSqzBars and close < sqLo and close < open

if squeeze and not squeeze[1]
    sqHi    := high
    sqLo    := low
    sqLen   := 1
    sqArmed := true
else if squeeze
    sqHi  := math.max(sqHi, high)
    sqLo  := math.min(sqLo, low)
    sqLen += 1
if squeeze[1] and not squeeze
    sqEndBar := bar_index
if boL or boS or (not boWindow)
    sqArmed := false

// Combine (priority: breakout → trend → range)
rawBuy  = barstate.isconfirmed and ((showBoSig and boL) or (showTrendSig and trendL) or (showRangeSig and rangeL))
rawSell = barstate.isconfirmed and ((showBoSig and boS) or (showTrendSig and trendS) or (showRangeSig and rangeS))

// ───────────────────────────────────────────────────────────────
// ALTERNATION
// ───────────────────────────────────────────────────────────────
var int    lastDir  = 0
var string lastType = "—"
buySig  = rawBuy  and (not useAlt or lastDir != 1)
sellSig = rawSell and (not useAlt or lastDir != -1) and not buySig

buyType  = showBoSig and boL ? "B" : showTrendSig and trendL ? "T" : "R"
sellType = showBoSig and boS ? "B" : showTrendSig and trendS ? "T" : "R"

if buySig
    lastDir  := 1
    lastType := buyType
if sellSig
    lastDir  := -1
    lastType := sellType

// ───────────────────────────────────────────────────────────────
// NEON VISUALS
// ───────────────────────────────────────────────────────────────
cNeutral = #5C6B8A
regCol = regime == 1 ? cBull : regime == -1 ? cBear : regime == 2 ? cSqz : regime == 0 ? cRange : cNeutral

// Regime background
bgcolor(showBg and (regime == 1 or regime == -1 or regime == 2) ? color.new(regCol, 95) : na, title="Regime Background")

// Candles by regime
barcolor(showCandles and regime != 3 ? (close >= open ? color.new(regCol, 0) : color.new(regCol, 60)) : na, title="Candle Color")

// Fast EMA — trend spine (bright in trend, dim otherwise)
inTrend = regime == 1 or regime == -1
emaCol  = inTrend ? regCol : color.new(#00E5FF, 55)
plot(showLines ? fastMa : na, "Fast EMA Glow", color=inTrend ? color.new(regCol, 78) : na, linewidth=8, display=display.pane)
plot(showLines ? fastMa : na, "Fast EMA",      color=emaCol, linewidth=2)
plot(showLines ? slowMa : na, "Slow EMA",      color=color.new(#B388FF, 45), linewidth=1)

// Bollinger edges — bright in range, faint otherwise
inRange = regime == 0
bandCol = inRange ? cRange : color.new(cRange, 80)
plot(showLines ? bbUp : na, "Upper Band Glow", color=inRange ? color.new(cRange, 80) : na, linewidth=6, display=display.pane)
plot(showLines ? bbUp : na, "Upper Band",      color=bandCol, linewidth=1)
plot(showLines ? bbLo : na, "Lower Band Glow", color=inRange ? color.new(cRange, 80) : na, linewidth=6, display=display.pane)
plot(showLines ? bbLo : na, "Lower Band",      color=bandCol, linewidth=1)

// Squeeze coil box
plot(showLines and squeeze and sqArmed ? sqHi : na, "Coil High", color=cSqz, linewidth=2, style=plot.style_linebr)
plot(showLines and squeeze and sqArmed ? sqLo : na, "Coil Low",  color=cSqz, linewidth=2, style=plot.style_linebr)

// Signal flash
bgcolor(showFlash and (buySig or sellSig) ? color.new(buySig ? cBull : cBear, 78) : na, title="Signal Flash")

// Markers by type
isT_L = buySig  and buyType  == "T"
isT_S = sellSig and sellType == "T"
isR_L = buySig  and buyType  == "R"
isR_S = sellSig and sellType == "R"
isB_L = buySig  and buyType  == "B"
isB_S = sellSig and sellType == "B"

plotshape(isT_L and not showLetters, "Trend Buy",     shape.triangleup,   location.belowbar, cBull, size=size.small)
plotshape(isT_S and not showLetters, "Trend Sell",    shape.triangledown, location.abovebar, cBear, size=size.small)
plotshape(isR_L and not showLetters, "Range Buy",     shape.diamond,      location.belowbar, cBull, size=size.small)
plotshape(isR_S and not showLetters, "Range Sell",    shape.diamond,      location.abovebar, cBear, size=size.small)
plotshape(isB_L and not showLetters, "Breakout Buy",  shape.labelup,      location.belowbar, cBull, size=size.small)
plotshape(isB_S and not showLetters, "Breakout Sell", shape.labeldown,    location.abovebar, cBear, size=size.small)

plotshape(isT_L and showLetters, "Trend Buy T",     shape.triangleup,   location.belowbar, cBull, size=size.small, text="T", textcolor=cBull, display=display.pane)
plotshape(isT_S and showLetters, "Trend Sell T",    shape.triangledown, location.abovebar, cBear, size=size.small, text="T", textcolor=cBear, display=display.pane)
plotshape(isR_L and showLetters, "Range Buy R",     shape.diamond,      location.belowbar, cBull, size=size.small, text="R", textcolor=cRange, display=display.pane)
plotshape(isR_S and showLetters, "Range Sell R",    shape.diamond,      location.abovebar, cBear, size=size.small, text="R", textcolor=cRange, display=display.pane)
plotshape(isB_L and showLetters, "Breakout Buy B",  shape.labelup,      location.belowbar, cBull, size=size.small, text="B", textcolor=cSqz, display=display.pane)
plotshape(isB_S and showLetters, "Breakout Sell B", shape.labeldown,    location.abovebar, cBear, size=size.small, text="B", textcolor=cSqz, display=display.pane)

// ───────────────────────────────────────────────────────────────
// ALERTS
// ───────────────────────────────────────────────────────────────
alertcondition(buySig,  "QNPulse Buy",  "QNPulse ▲ BUY | {{ticker}} {{interval}} | {{close}}")
alertcondition(sellSig, "QNPulse Sell", "QNPulse ▼ SELL | {{ticker}} {{interval}} | {{close}}")
alertcondition(buySig or sellSig, "QNPulse Any Signal", "QNPulse signal | {{ticker}} {{interval}} | {{close}}")
alertcondition(regime != regime[1], "QNPulse Regime Change", "QNPulse regime changed | {{ticker}} {{interval}}")
alertcondition(squeeze and not squeeze[1], "QNPulse Squeeze Start", "QNPulse squeeze — breakout loading | {{ticker}} {{interval}}")

// ───────────────────────────────────────────────────────────────
// STATUS PANEL
// ───────────────────────────────────────────────────────────────
var table panel = table.new(position.top_right, 2, 4, bgcolor=color.new(#0A0E1A, 5),
     frame_color=color.new(regCol, 20), frame_width=1, border_color=color.new(#1C2440, 0), border_width=1)

if barstate.islast and showTable
    cDim    = #8A93B2
    regTxt  = regime == 1 ? "TREND ▲" : regime == -1 ? "TREND ▼" : regime == 2 ? "SQUEEZE" : regime == 0 ? "RANGE" : "NEUTRAL"
    adxTxt  = str.tostring(adx, "#.0") + " / " + str.tostring(adxTrend, "#") + (adx >= adxTrend ? " · Strong" : " · Weak")
    typeTxt = lastType == "T" ? "Trend" : lastType == "R" ? "Range" : lastType == "B" ? "Breakout" : ""
    sigTxt  = lastDir == 1 ? "▲ BUY " + typeTxt : lastDir == -1 ? "▼ SELL " + typeTxt : "—"
    sigCol  = lastDir == 1 ? cBull : lastDir == -1 ? cBear : cDim

    table.cell(panel, 0, 0, "Q NEON PULSE", text_color=#00E5FF, text_size=size.small)
    table.cell(panel, 1, 0, "REGIME",       text_color=cDim,    text_size=size.small)
    table.cell(panel, 0, 1, "Regime",       text_color=cDim,    text_size=size.small)
    table.cell(panel, 1, 1, regTxt,         text_color=regCol,  text_size=size.small)
    table.cell(panel, 0, 2, "ADX",          text_color=cDim,    text_size=size.small)
    table.cell(panel, 1, 2, adxTxt,         text_color=adx >= adxTrend ? regCol : cDim, text_size=size.small)
    table.cell(panel, 0, 3, "Last Signal",  text_color=cDim,    text_size=size.small)
    table.cell(panel, 1, 3, sigTxt,         text_color=sigCol,  text_size=size.small)
````
