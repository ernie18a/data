# Range Ninja

- url: https://www.tradingview.com/script/81OZsgUj-Range-Ninja/
- type: indicator
- pine_id: PUB;5ddd957eedff4661b6e34ae0face617f
- version: 1.0

## Description

RANGE NINJA — EMA20 Pullback & Rejection Signals

Range Ninja finds trend-following entries. It waits for a strong trend, waits for price to pull back to the orange EMA 20 line, and only signals when the candle bounces off that line.

Built mainly for SCALPING NQ (Nasdaq futures) on a Range chart such as 40R. It works on any chart type and timeframe, but only NQ 40R is the intended setup. For other markets or range sizes, please test it yourself first.

━━━━━━━━━━━━━━━━━━━━
KEY POINTS (READ THIS FIRST)
━━━━━━━━━━━━━━━━━━━━
- Best suited for scalpers trading NQ on a 40R Range chart.
- Other instruments and chart types: not tested by the author. Test on your own before relying on it.
- Combine it with a 5-minute candle chart for more context. Use the 5-minute chart to see the bigger trend and key levels, and use Range Ninja on the 40R chart to time the entry. Trading in the same direction as the 5-minute trend usually gives cleaner setups.
- Scalping target idea: many traders aim for about 20-30 ticks. On NQ, 1 tick = 0.25 points, so 20-30 ticks = 5 to 7.5 points. This is only a common idea, not a promise. Set your own target, stop loss and risk.
- Be patient. The indicator is quiet on purpose. Wait for the full setup: trend, pullback to EMA 20, then rejection candle. Do not force trades when the dashboard says NEUTRAL or TANGLED.
- Quality over quantity. A few good setups are better than many weak ones.

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS (3 STEPS)
━━━━━━━━━━━━━━━━━━━━
1. TREND: The EMAs must be lined up and Supertrend must agree.
   - Uptrend: EMA 20 > EMA 50 > EMA 100 and Supertrend is bullish
   - Downtrend: EMA 20 < EMA 50 < EMA 100 and Supertrend is bearish
2. PULLBACK: Price comes back and touches (or slightly pierces) the EMA 20.
3. REJECTION: The candle bounces away from the EMA 20 and closes in the trend direction.

If any step is missing, there is no signal. This is not an EMA crossover indicator, and it avoids chasing price when it is far from the EMA 20.

━━━━━━━━━━━━━━━━━━━━
HOW TO READ THE CHART
━━━━━━━━━━━━━━━━━━━━
🚀 = BUY signal (score shown inside the box)
🚀🚀 = STRONG BUY (the candle looks like a hammer)
🚨 = SELL signal
🚨🚨 = STRONG SELL (the candle looks like a shooting star)

The number inside the box is the signal score from 0 to 100. A higher score means the setup matches more of the rules. By default, only signals scoring 70 or higher are shown.

Lines on the chart:
- Orange = EMA 20
- Maroon = EMA 50
- Red = EMA 100
- Green / pink line = Supertrend

━━━━━━━━━━━━━━━━━━━━
THE DASHBOARD (top right)
━━━━━━━━━━━━━━━━━━━━
- MARKET STATE: Bullish, Bearish or Neutral
- EMA ALIGNMENT: shows whether the EMAs are lined up or "TANGLED"
- SUPERTREND: current direction
- EMA20 / EMA50 / EMA100: current values
- PULLBACK: WAITING, TESTING EMA20 or REJECTED
- SIGNAL and SCORE: the latest result

Tip: if the table says NEUTRAL or TANGLED, the market has no clear trend. The indicator stays quiet on purpose.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━
1. Open NQ on a 40R Range chart and add the indicator.
2. Check the 5-minute candle chart for the main direction.
3. Wait for the 40R dashboard to show a clear trend (BULLISH or BEARISH) in the same direction.
4. Wait for price to pull back to the orange EMA 20 line. Be patient.
5. Take action only when a signal box appears. Signals appear only after the candle closes (default setting), so they do not disappear or move.
6. Use your own entry, stop loss and risk rules. A common idea is to place the stop beyond the rejection candle's wick.
7. Treat a STRONG signal or a high score as extra confirmation, not a guarantee.

━━━━━━━━━━━━━━━━━━━━
MAIN SETTINGS
━━━━━━━━━━━━━━━━━━━━
EMAs: change the lengths (default 20 / 50 / 100). Optional: require all EMAs to slope in the trend direction.
Supertrend: ATR length 10, factor 3.0 (both adjustable).
Min EMA separation: ignores setups where the EMAs are squeezed together.
EMA20 touch tolerance / max penetration: how close price must get to the EMA 20, and how far through it is still acceptable.
Candle rules: minimum body size, minimum wick size, and the hammer / shooting-star shape.
Minimum signal score: default 70. Raise it for fewer, higher-quality signals.
Min bars between signals: stops repeated signals on neighbouring candles.
Signal only on candle close: ON by default (recommended, no repainting).
Signal symbols: change the emoji, the box colours, the size and the distance from the candle.
Dashboard: show or hide it, and change its position and text size.

Most distances are measured in ATR, so the settings adapt automatically when you change the Range size or the instrument.

━━━━━━━━━━━━━━━━━━━━
TOO MANY SIGNALS?
━━━━━━━━━━━━━━━━━━━━
- Raise the minimum score to 75-80
- Increase the minimum EMA separation
- Turn on EMA slope confirmation
- Lower the touch tolerance
- Increase the bars between signals

TOO FEW SIGNALS?
━━━━━━━━━━━━━━━━━━━━
- Lower the minimum score to 60-65
- Lower the minimum wick size
- Increase the touch tolerance
- Turn off "Previous bar must close on trend side"
- Lower the minimum EMA separation

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━
Create an alert and choose one of: BUY SETUP, STRONG BUY, SELL SETUP, STRONG SELL, BUY CONFIRMED, SELL CONFIRMED.
To get the score in the alert message, turn on "Enable dynamic alert() messages" in the settings, then create the alert with "Any alert() function call".

━━━━━━━━━━━━━━━━━━━━
GOOD TO KNOW
━━━━━━━━━━━━━━━━━━━━
- No signals in sideways or tangled markets, by design.
- Signals use only the current and past candles. There is no lookahead.
- Works best in clear trends. Quality matters more than quantity.
- Always test on a demo account or replay mode before using real money.

━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━
This indicator is for educational and informational purposes only. It is not financial advice and does not guarantee profits. Trading futures and other markets involves a high risk of loss. Past performance does not predict future results. You are responsible for your own trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tnumar

//@version=6
indicator("Range Ninja", shorttitle="40RangeNinja", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
G_EMA   = "1. EMAs"
G_ST    = "2. Supertrend"
G_ALIGN = "3. Alignment / Separation"
G_PB    = "4. EMA20 Pullback"
G_CAN   = "5. Rejection Candle"
G_SIG   = "6. Signals / Score"
G_SYM   = "6b. Signal Symbols"
G_DASH  = "7. Dashboard & Messages"
G_ALRT  = "8. Alerts"

emaFastLen = input.int(20,  "EMA Fast",   minval=1, group=G_EMA)
emaMedLen  = input.int(50,  "EMA Medium", minval=1, group=G_EMA)
emaSlowLen = input.int(100, "EMA Slow",   minval=1, group=G_EMA)
reqSlope   = input.bool(false, "Require EMA slope confirmation", group=G_EMA)

stAtrLen   = input.int(10, "Supertrend ATR Length", minval=1, group=G_ST)
stFactor   = input.float(3.0, "Supertrend Factor", minval=0.1, step=0.1, group=G_ST)
stBullCol  = input.color(color.green, "Supertrend bullish colour", group=G_ST)
stBearCol  = input.color(color.fuchsia, "Supertrend bearish colour", group=G_ST)

atrLen       = input.int(14, "ATR length (distance unit)", minval=1, group=G_ALIGN)
useMinSep    = input.bool(true, "Use minimum EMA separation", group=G_ALIGN)
minSepAtr    = input.float(0.10, "Min EMA separation (x ATR)", minval=0.0, step=0.01, group=G_ALIGN)
strongSepAtr = input.float(0.40, "Strong separation for score (x ATR)", minval=0.01, step=0.01, group=G_ALIGN)

tolAtr       = input.float(0.10, "EMA20 touch tolerance (x ATR)", minval=0.0, step=0.01, group=G_PB)
maxPenAtr    = input.float(0.60, "Max penetration through EMA20 (x ATR)", minval=0.0, step=0.05, group=G_PB)
maxExtAtr    = input.float(1.50, "Max close distance from EMA20 (x ATR)", minval=0.1, step=0.05, group=G_PB)
reqPrevSide  = input.bool(true, "Previous bar must close on trend side of EMA20", group=G_PB)

minBodyPct   = input.float(15.0, "Min candle body (% of range)", minval=0.0, maxval=100.0, group=G_CAN)
minRejPct    = input.float(15.0, "Min rejection wick (% of range)", minval=0.0, maxval=100.0, group=G_CAN)
minClosePos  = input.float(50.0, "Min close position in range (%)", minval=0.0, maxval=100.0, group=G_CAN)
maxOppNormal = input.float(1.0, "Max opposite wick / body (normal)", minval=0.0, step=0.1, group=G_CAN)
hamWickBody  = input.float(1.5, "Hammer/Star: min rejection wick / body", minval=0.0, step=0.1, group=G_CAN)
hamMaxOpp    = input.float(0.5, "Hammer/Star: max opposite wick / body", minval=0.0, step=0.1, group=G_CAN)

enableBuy     = input.bool(true, "Enable BUY signals", group=G_SIG)
enableSell    = input.bool(true, "Enable SELL signals", group=G_SIG)
signalOnClose = input.bool(true, "Signal only on candle close", group=G_SIG)
useScore      = input.bool(true, "Use signal score filter", group=G_SIG)
minScore      = input.int(70, "Minimum signal score", minval=0, maxval=100, group=G_SIG)
cooldownBars  = input.int(3, "Min bars between same-side signals", minval=0, group=G_SIG)

// Signal symbols (customisable)
showLabels    = input.bool(true, "Show signal symbols", group=G_SYM)
buySym        = input.string("🚀",   "BUY symbol",         group=G_SYM)
strongBuySym  = input.string("🚀🚀", "STRONG BUY symbol",  group=G_SYM)
sellSym       = input.string("🚨",   "SELL symbol",        group=G_SYM)
strongSellSym = input.string("🚨🚨", "STRONG SELL symbol", group=G_SYM)
showScoreTxt  = input.bool(true, "Show score below symbol", group=G_SYM)
useBox        = input.bool(true, "Show box behind symbol", group=G_SYM)
boxBuyCol     = input.color(#2e7d32, "BUY box colour",         group=G_SYM)
boxStrongBuyCol  = input.color(#00c853, "STRONG BUY box colour",  group=G_SYM)
boxSellCol    = input.color(#d32f2f, "SELL box colour",        group=G_SYM)
boxStrongSellCol = input.color(#7f0000, "STRONG SELL box colour", group=G_SYM)
boxTransp     = input.int(10, "Box transparency (0 = solid)", minval=0, maxval=90, group=G_SYM)
boxTextCol    = input.color(color.white, "Text colour inside box", group=G_SYM)
buyScoreCol   = input.color(color.green, "BUY text colour (box off)",  group=G_SYM)
sellScoreCol  = input.color(color.red,   "SELL text colour (box off)", group=G_SYM)
normalSizeIn  = input.string("Small", "Symbol size (normal signals)", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_SYM)
strongSizeIn  = input.string("Small",  "Symbol size (strong signals)", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_SYM)
symOffsetAtr  = input.float(0.8, "Distance from candle (x ATR)", minval=0.0, step=0.1, group=G_SYM)
showTriangles = input.bool(false, "Also show triangle markers", group=G_SYM)

showDash     = input.bool(true, "Show dashboard", group=G_DASH)
dashPosIn    = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group=G_DASH)
dashSizeIn   = input.string("Small", "Table / text size", options=["Tiny", "Small", "Normal", "Large"], group=G_DASH)
showMessages = input.bool(true, "Show status message on last bar", group=G_DASH)

useDynAlerts = input.bool(false, "Enable dynamic alert() messages (incl. score)", group=G_ALRT)

// Dashboard / symbol settings (declared BEFORE the helper functions that use them)
tblPos = dashPosIn == "Top Right" ? position.top_right : dashPosIn == "Top Left" ? position.top_left : dashPosIn == "Bottom Right" ? position.bottom_right : dashPosIn == "Bottom Left" ? position.bottom_left : dashPosIn == "Middle Right" ? position.middle_right : position.middle_left
dashTxtSize = dashSizeIn == "Tiny" ? size.tiny : dashSizeIn == "Small" ? size.small : dashSizeIn == "Normal" ? size.normal : size.large
normalSym = normalSizeIn == "Tiny" ? size.tiny : normalSizeIn == "Small" ? size.small : normalSizeIn == "Normal" ? size.normal : normalSizeIn == "Large" ? size.large : size.huge
strongSym = strongSizeIn == "Tiny" ? size.tiny : strongSizeIn == "Small" ? size.small : strongSizeIn == "Normal" ? size.normal : strongSizeIn == "Large" ? size.large : size.huge

// Label styles: boxed (with pointer toward the candle) or plain text
buyLblStyle  = useBox ? label.style_label_up   : label.style_none
sellLblStyle = useBox ? label.style_label_down : label.style_none
buyTxtCol    = useBox ? boxTextCol : buyScoreCol
sellTxtCol   = useBox ? boxTextCol : sellScoreCol

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════
f_clamp(float x) =>
    math.max(0.0, math.min(1.0, x))

// Score 0-100: trend 25, supertrend 20, separation+slope 15, pullback 15, rejection 15, hammer 10
f_score(bool aligned, bool stOk, float sepMin, float strongSep, int slopeCnt, bool touched, bool inTol, float wickPct, bool rejOk, bool hammer) =>
    float s = 0.0
    s += aligned ? 25.0 : 0.0
    s += stOk ? 20.0 : 0.0
    s += 10.0 * f_clamp(sepMin / strongSep)
    s += 5.0 * slopeCnt / 3.0
    s += touched ? 15.0 : (inTol ? 10.0 : 0.0)
    s += rejOk ? 15.0 * f_clamp(wickPct / 0.4) : 0.0
    s += hammer ? 10.0 : 0.0
    math.round(s)

// Symbol on first line, score on the line below it
f_symText(string sym, int sc) =>
    showScoreTxt ? sym + "\n" + str.tostring(sc) : sym

f_alertMsg(string sig, string align, string stTxt, int sc) =>
    syminfo.ticker + "\n" + timeframe.period + "\n" + sig + "\n" + align + "\n" + stTxt + "\nScore: " + str.tostring(sc)

f_row(table t, int r, string k, string v, color c) =>
    table.cell(t, 0, r, k, text_color=color.new(color.white, 10), text_halign=text.align_left, bgcolor=color.new(#131722, 5), text_size=dashTxtSize)
    table.cell(t, 1, r, v, text_color=c, text_halign=text.align_left, bgcolor=color.new(#131722, 5), text_size=dashTxtSize)

// ═══════════════════════════════════════════════════════════════
//  CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════
ema1 = ta.ema(close, emaFastLen)
ema2 = ta.ema(close, emaMedLen)
ema3 = ta.ema(close, emaSlowLen)
atrV = ta.atr(atrLen)
[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)   // stDir < 0 = bullish, > 0 = bearish

stBull = stDir < 0
stBear = stDir > 0

// Trend alignment
emaBull = ema1 > ema2 and ema2 > ema3
emaBear = ema1 < ema2 and ema2 < ema3

sepMin = math.min(math.abs(ema1 - ema2), math.abs(ema2 - ema3)) / atrV
sepOk  = not useMinSep or sepMin >= minSepAtr

slopeBullCnt = (ema1 > ema1[1] ? 1 : 0) + (ema2 > ema2[1] ? 1 : 0) + (ema3 > ema3[1] ? 1 : 0)
slopeBearCnt = (ema1 < ema1[1] ? 1 : 0) + (ema2 < ema2[1] ? 1 : 0) + (ema3 < ema3[1] ? 1 : 0)

bullAligned = emaBull and stBull and sepOk and (not reqSlope or slopeBullCnt == 3)
bearAligned = emaBear and stBear and sepOk and (not reqSlope or slopeBearCnt == 3)

// Candle structure
body      = math.abs(close - open)
rng       = high - low
safeRng   = rng > 0 ? rng : syminfo.mintick
safeBody  = math.max(body, syminfo.mintick)
bodyPct   = body / safeRng * 100.0
lowW      = math.min(open, close) - low
upW       = high - math.max(open, close)
lowPct    = lowW / safeRng
upPct     = upW / safeRng
closePosBull = (close - low) / safeRng * 100.0
closePosBear = (high - close) / safeRng * 100.0

tol    = tolAtr * atrV
maxPen = maxPenAtr * atrV
maxExt = maxExtAtr * atrV

// ─────────────── BUY SIDE ───────────────
touchedBuy = low <= ema1
inTolBuy   = low <= ema1 + tol
zoneBuy    = inTolBuy and low >= ema1 - maxPen                 // wick/body reached EMA20 area
prevOkBuy  = not reqPrevSide or close[1] > ema1[1]
extOkBuy   = (close - ema1) <= maxExt                          // do not chase extension

rejBuy = close > open and bodyPct >= minBodyPct and lowPct * 100.0 >= minRejPct and upW / safeBody <= maxOppNormal and closePosBull >= minClosePos
hamBuy = rejBuy and lowW / safeBody >= hamWickBody and upW / safeBody <= hamMaxOpp

candBuy   = enableBuy and bullAligned and zoneBuy and close > ema1 and close > ema2 and extOkBuy and prevOkBuy and rejBuy
scoreBuy  = f_score(bullAligned, stBull, sepMin, strongSepAtr, slopeBullCnt, touchedBuy, inTolBuy, lowPct, rejBuy, hamBuy)
scoreOkBuy = not useScore or scoreBuy >= minScore

// ─────────────── SELL SIDE (mirror) ───────────────
touchedSell = high >= ema1
inTolSell   = high >= ema1 - tol
zoneSell    = inTolSell and high <= ema1 + maxPen
prevOkSell  = not reqPrevSide or close[1] < ema1[1]
extOkSell   = (ema1 - close) <= maxExt

rejSell = close < open and bodyPct >= minBodyPct and upPct * 100.0 >= minRejPct and lowW / safeBody <= maxOppNormal and closePosBear >= minClosePos
hamSell = rejSell and upW / safeBody >= hamWickBody and lowW / safeBody <= hamMaxOpp

candSell   = enableSell and bearAligned and zoneSell and close < ema1 and close < ema2 and extOkSell and prevOkSell and rejSell
scoreSell  = f_score(bearAligned, stBear, sepMin, strongSepAtr, slopeBearCnt, touchedSell, inTolSell, upPct, rejSell, hamSell)
scoreOkSell = not useScore or scoreSell >= minScore

// ═══════════════════════════════════════════════════════════════
//  SIGNALS (no lookahead; confirmed on bar close by default)
// ═══════════════════════════════════════════════════════════════
var int lastBuyBar  = na
var int lastSellBar = na
cdBuyOk  = na(lastBuyBar)  or (bar_index - lastBuyBar  > cooldownBars)
cdSellOk = na(lastSellBar) or (bar_index - lastSellBar > cooldownBars)
closeGate = not signalOnClose or barstate.isconfirmed

buySignal  = candBuy  and scoreOkBuy  and cdBuyOk  and closeGate
sellSignal = candSell and scoreOkSell and cdSellOk and closeGate
strongBuy  = buySignal  and hamBuy
strongSell = sellSignal and hamSell
buyNormal  = buySignal  and not strongBuy
sellNormal = sellSignal and not strongSell

if buySignal
    lastBuyBar := bar_index
if sellSignal
    lastSellBar := bar_index

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
plot(ema1, "EMA 20",  color.orange, 2)
plot(ema2, "EMA 50",  color.maroon, 2)
plot(ema3, "EMA 100", color.red,    2)
plot(stBull ? stLine : na, "Supertrend Bull", stBullCol, 1, style=plot.style_linebr)
plot(stBear ? stLine : na, "Supertrend Bear", stBearCol, 1, style=plot.style_linebr)

// Optional triangle markers (off by default)
plotshape(showTriangles and buyNormal,  "BUY",         shape.triangleup,   location.belowbar, color.green,  size=size.tiny)
plotshape(showTriangles and strongBuy,  "STRONG BUY",  shape.triangleup,   location.belowbar, color.lime,   size=size.large)
plotshape(showTriangles and sellNormal, "SELL",        shape.triangledown, location.abovebar, color.red,    size=size.tiny)
plotshape(showTriangles and strongSell, "STRONG SELL", shape.triangledown, location.abovebar, color.maroon, size=size.large)

// Emoji + score inside a coloured box (box colour depends on normal / strong)
if showLabels and buySignal
    color bc = useBox ? color.new(strongBuy ? boxStrongBuyCol : boxBuyCol, boxTransp) : color.new(color.white, 100)
    label.new(bar_index, low - atrV * symOffsetAtr, f_symText(strongBuy ? strongBuySym : buySym, scoreBuy), style=buyLblStyle, color=bc, textcolor=buyTxtCol, size=strongBuy ? strongSym : normalSym)

if showLabels and sellSignal
    color sc = useBox ? color.new(strongSell ? boxStrongSellCol : boxSellCol, boxTransp) : color.new(color.white, 100)
    label.new(bar_index, high + atrV * symOffsetAtr, f_symText(strongSell ? strongSellSym : sellSym, scoreSell), style=sellLblStyle, color=sc, textcolor=sellTxtCol, size=strongSell ? strongSym : normalSym)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
var table dash = table.new(tblPos, 2, 9, border_width=1, frame_width=1, frame_color=color.new(color.gray, 40), border_color=color.new(color.gray, 60))

if barstate.islast and showDash
    mState  = bullAligned ? "BULLISH" : bearAligned ? "BEARISH" : "NEUTRAL"
    mCol    = bullAligned ? color.lime : bearAligned ? color.red : color.gray
    aText   = emaBull ? "20 > 50 > 100" : emaBear ? "20 < 50 < 100" : "TANGLED"
    stText  = stBull ? "BULLISH" : stBear ? "BEARISH" : "N/A"
    pbText  = bullAligned ? (rejBuy and zoneBuy and close > ema1 ? "REJECTED" : zoneBuy ? "TESTING EMA20" : "WAITING") : bearAligned ? (rejSell and zoneSell and close < ema1 ? "REJECTED" : zoneSell ? "TESTING EMA20" : "WAITING") : "WAITING"
    sigText = strongBuy ? "STRONG BUY" : buySignal ? "BUY" : strongSell ? "STRONG SELL" : sellSignal ? "SELL" : "WAITING"
    sigCol  = (buySignal) ? color.lime : (sellSignal ? color.red : color.gray)
    scText  = str.tostring(bullAligned ? scoreBuy : bearAligned ? scoreSell : 0)

    f_row(dash, 0, "MARKET STATE", mState, mCol)
    f_row(dash, 1, "EMA ALIGNMENT", aText, emaBull ? color.lime : emaBear ? color.red : color.gray)
    f_row(dash, 2, "SUPERTREND", stText, stBull ? color.lime : stBear ? color.red : color.gray)
    f_row(dash, 3, "EMA20", str.tostring(ema1, format.mintick), color.orange)
    f_row(dash, 4, "EMA50", str.tostring(ema2, format.mintick), color.maroon)
    f_row(dash, 5, "EMA100", str.tostring(ema3, format.mintick), color.red)
    f_row(dash, 6, "PULLBACK", pbText, color.white)
    f_row(dash, 7, "SIGNAL", sigText, sigCol)
    f_row(dash, 8, "SCORE", scText, color.white)

// ═══════════════════════════════════════════════════════════════
//  STATUS MESSAGE (single label, last bar only)
// ═══════════════════════════════════════════════════════════════
var label msgLbl = na
if barstate.islast
    label.delete(msgLbl)
    msgLbl := na
    if showMessages and bullAligned
        string t = (buySignal or buySignal[1]) ? "BUY CONFIRMED" : zoneBuy ? "BUY ZONE — WAIT FOR CONFIRMATION" : "WAITING FOR BUY PULLBACK"
        msgLbl := label.new(bar_index, high + atrV * 1.2, t, style=label.style_label_down, color=color.new(color.green, 20), textcolor=color.white, size=size.small)
    else if showMessages and bearAligned
        string t = (sellSignal or sellSignal[1]) ? "SELL CONFIRMED" : zoneSell ? "SELL ZONE — WAIT FOR CONFIRMATION" : "WAITING FOR SELL PULLBACK"
        msgLbl := label.new(bar_index, low - atrV * 1.2, t, style=label.style_label_up, color=color.new(color.red, 20), textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
// alertcondition() messages must be constant -> use placeholders (no score here).
alertcondition(buySignal,   "BUY SETUP",      "{{ticker}} | {{interval}} | BUY SETUP | EMA20 > EMA50 > EMA100 | Supertrend Bullish")
alertcondition(strongBuy,   "STRONG BUY",     "{{ticker}} | {{interval}} | STRONG BUY | EMA20 > EMA50 > EMA100 | Supertrend Bullish")
alertcondition(sellSignal,  "SELL SETUP",     "{{ticker}} | {{interval}} | SELL SETUP | EMA20 < EMA50 < EMA100 | Supertrend Bearish")
alertcondition(strongSell,  "STRONG SELL",    "{{ticker}} | {{interval}} | STRONG SELL | EMA20 < EMA50 < EMA100 | Supertrend Bearish")
alertcondition(buySignal and barstate.isconfirmed,  "BUY CONFIRMED",  "{{ticker}} | {{interval}} | BUY CONFIRMED | EMA20 > EMA50 > EMA100 | Supertrend Bullish")
alertcondition(sellSignal and barstate.isconfirmed, "SELL CONFIRMED", "{{ticker}} | {{interval}} | SELL CONFIRMED | EMA20 < EMA50 < EMA100 | Supertrend Bearish")

// Dynamic alert() messages include the score. Create alert -> "Any alert() function call".
if useDynAlerts and buySignal
    if signalOnClose
        alert(f_alertMsg(strongBuy ? "STRONG BUY" : "BUY", "EMA20 > EMA50 > EMA100", "Supertrend Bullish", scoreBuy), alert.freq_once_per_bar_close)
    else
        alert(f_alertMsg(strongBuy ? "STRONG BUY" : "BUY", "EMA20 > EMA50 > EMA100", "Supertrend Bullish", scoreBuy), alert.freq_once_per_bar)

if useDynAlerts and sellSignal
    if signalOnClose
        alert(f_alertMsg(strongSell ? "STRONG SELL" : "SELL", "EMA20 < EMA50 < EMA100", "Supertrend Bearish", scoreSell), alert.freq_once_per_bar_close)
    else
        alert(f_alertMsg(strongSell ? "STRONG SELL" : "SELL", "EMA20 < EMA50 < EMA100", "Supertrend Bearish", scoreSell), alert.freq_once_per_bar)
````
