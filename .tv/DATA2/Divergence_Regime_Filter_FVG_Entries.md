<!-- tradingview-pine-id: PUB;0ddbae1573ac42eb80b1c54300cbdbcb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Divergence Regime Filter + FVG Entries

Source: https://www.tradingview.com/script/VM6iZArj-Divergence-Regime-Filter-FVG-Entries/

## Description

Divergence Regime Filter + FVG Entries

A trend-vs-range filter built on divergence behavior, with counter-trend entries confirmed by a displacement Fair Value Gap.

Concept

In strong trends, clean and meaningful divergences tend to form (bearish divergences in uptrends, bullish divergences in downtrends). In ranges, price rarely makes a proper higher high or lower low, so clean divergences don't form, or bullish and bearish ones appear together. This script uses that behavior to classify the market as Bullish Trend, Bearish Trend or Ranging, then trades the divergence against the trend once it confirms.

How it works

1. Divergence detection
The script finds regular bullish and bearish divergences using pivots on your choice of oscillator (RSI, MACD Histogram, CCI, Stoch RSI or MFI). A divergence must pass quality checks to count:

The price move between pivots must be at least a set multiple of ATR.
The oscillator difference must be at least a set multiple of the oscillator's own standard deviation.
The pivots must be within a minimum and maximum number of bars of each other.

Divergences are confirmed only after the right-side pivot bars have printed, so there is a built-in confirmation delay.

2. Dynamic regime filter

Bullish trend: price is above a rising EMA, the slope is strong relative to its own 100-bar average (so it adapts to volatility), and bearish divergences have formed recently and outnumber bullish ones.
Bearish trend: the mirror image, with bullish divergences outnumbering bearish ones.
Ranging: anything else, such as no clean divergences, mixed divergences or a weak slope.

The chart background and the EMA color show the current regime.

3. Entry signals (counter-trend)

Buy: a bullish divergence confirms during a bearish trend.
Sell: a bearish divergence confirms during a bullish trend.

A small circle marks the early signal on the bar where the divergence confirms.

4. FVG confirmation
A full BUY or SELL label prints when a significant FVG forms in the signal direction within N bars (default 10) of the divergence confirming. The FVG needs a minimum gap size and a strong displacement candle in the middle, both measured in ATR. The FVG is drawn as a box. A pending setup is cancelled if price closes beyond the divergence pivot (optional) or the window expires.

Features
Sensitivity presets: Loose, Balanced, Strict and Custom
Five oscillator choices
Divergence lines, colored by whether they align with the regime
Dashboard showing regime, divergence counts, slope strength and remaining FVG window for pending setups
Alerts for Buy, Sell, early signals and regime changes
Option to disable the FVG requirement and trade the early signal alone
Settings guide
Sensitivity preset: the fastest way to get more or fewer signals. Custom unlocks the individual inputs.
Divergence memory: how many bars back divergences count toward the regime.
Min aligned divergences: raise it to demand more evidence before calling a trend.
FVG window / size / displacement: control how strict the confirmation is.
Usage tips
Use the regime background as a filter. Signals are only generated in trending regimes, so treat a ranging background as a reason to stand aside.
Signals are counter-trend, so consider your own stop placement (for example beyond the divergence pivot or the FVG) and higher-timeframe context.
Test different oscillators and presets per market and timeframe.
Notes
Divergence signals are confirmed after the pivot forms, so entries come later than the actual pivot. This is by design, to avoid repainting.
Signals are evaluated on closed bars.

Disclaimer: This indicator is for educational and informational purposes only and is not financial advice. Past performance does not guarantee future results. Always backtest and use proper risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bhardwaj6797

//@version=6
indicator("Divergence Regime Filter + FVG Entries", "DivRegime", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════
//  IDEA
//  1) Proper (regular) divergences are detected on an oscillator.
//  2) A "dynamic regime filter" decides TRENDING (bull/bear) vs RANGING:
//       - Trending  = ATR-normalised EMA slope is strong (self-scaling)
//                     AND counter-trend divergences are forming in the
//                     direction of that trend (bull divs in a downtrend,
//                     bear divs in an uptrend), and they outnumber the
//                     opposite type.
//       - Ranging   = no clean divergences, mixed divergences, or weak slope.
//  3) Entries are counter-trend, fired when the divergence is CONFIRMED:
//       - BUY  : bearish trend + bullish divergence confirmed
//       - SELL : bullish trend + bearish divergence confirmed
//  4) Extra confirmation: a significant displacement FVG in the signal
//     direction must form within N bars (default 10) of the confirmation.
// ═══════════════════════════════════════════════════════════════

// ───────────── Inputs ─────────────
preset = input.string("Balanced", "Sensitivity preset", options=["Loose", "Balanced", "Strict", "Custom"], group="Preset", tooltip="Loose = most signals, Strict = fewest. 'Custom' uses the individual values in the groups below; other presets override pivot lengths, min price/oscillator move, slope sensitivity and FVG size/displacement.")
cancelOnBreak = input.bool(true, "Cancel setup if price closes beyond divergence pivot", group="Preset")

g1 = "Oscillator & Divergence"
oscType     = input.string("RSI", "Oscillator", options=["RSI", "MACD Hist", "CCI", "Stoch RSI", "MFI"], group=g1)
oscLen      = input.int(14, "Oscillator length", minval=2, group=g1)
pivL_in     = input.int(5, "Pivot left bars", minval=1, group=g1)
pivR_in     = input.int(5, "Pivot right bars (confirmation delay)", minval=1, group=g1)
minBars     = input.int(5, "Min bars between pivots", minval=1, group=g1)
maxBars     = input.int(60, "Max bars between pivots", minval=5, group=g1)
minPriceATR_in = input.float(0.5, "Min price move between pivots (x ATR)", minval=0.0, step=0.1, group=g1, tooltip="Filters out tiny/equal highs & lows. Ranges rarely make a clean, meaningful HH/LL.")
oscDiffMult_in = input.float(0.15, "Min oscillator difference (x oscillator stdev)", minval=0.0, step=0.05, group=g1, tooltip="Dynamic threshold, so it works for any oscillator/market.")

g2 = "Regime Filter (Trend vs Range)"
trendLen    = input.int(50, "Trend EMA length", minval=5, group=g2)
slopeLen    = input.int(10, "Slope lookback", minval=2, group=g2)
slopeSens_in = input.float(0.8, "Slope sensitivity (x avg slope)", minval=0.1, step=0.1, group=g2, tooltip="Trend slope must exceed this multiple of its own 100-bar average. Higher = stricter, self-adjusting to volatility.")
regimeLen   = input.int(60, "Divergence memory (bars)", minval=10, group=g2, tooltip="How far back divergences count toward the regime.")
minDivs     = input.int(1, "Min aligned divergences to call a trend", minval=1, group=g2)

g3 = "FVG Confirmation"
useFVG      = input.bool(true, "Require FVG for confirmed signal", group=g3)
fvgWindow   = input.int(10, "Max bars after divergence confirms", minval=1, group=g3)
fvgMinATR_in = input.float(0.3, "Min FVG size (x ATR)", minval=0.0, step=0.05, group=g3)
dispATR_in   = input.float(1.0, "Min displacement candle body (x ATR)", minval=0.0, step=0.1, group=g3, tooltip="The middle candle of the FVG must be a strong move.")
boxExt      = input.int(20, "FVG box extension (bars)", minval=1, group=g3)

g4 = "Display"
showBg      = input.bool(true, "Regime background", group=g4)
showEma     = input.bool(true, "Trend EMA (colored by regime)", group=g4)
showDivs    = input.bool(true, "Divergence lines", group=g4)
showEarly   = input.bool(true, "Early signal (divergence confirmed)", group=g4)
showTable   = input.bool(true, "Dashboard", group=g4)
bullCol     = input.color(color.new(#26a69a, 0), "Bull color", group=g4)
bearCol     = input.color(color.new(#ef5350, 0), "Bear color", group=g4)

// ───────────── Effective settings (preset overrides) ─────────────
//                         Loose  Balanced  Strict
int   pivL        = preset == "Loose" ? 3    : preset == "Balanced" ? 4    : preset == "Strict" ? 5    : pivL_in
int   pivR        = preset == "Loose" ? 3    : preset == "Balanced" ? 4    : preset == "Strict" ? 5    : pivR_in
float minPriceATR = preset == "Loose" ? 0.1  : preset == "Balanced" ? 0.25 : preset == "Strict" ? 0.5  : minPriceATR_in
float oscDiffMult = preset == "Loose" ? 0.0  : preset == "Balanced" ? 0.05 : preset == "Strict" ? 0.15 : oscDiffMult_in
float slopeSens   = preset == "Loose" ? 0.3  : preset == "Balanced" ? 0.5  : preset == "Strict" ? 0.8  : slopeSens_in
float fvgMinATR   = preset == "Loose" ? 0.05 : preset == "Balanced" ? 0.1  : preset == "Strict" ? 0.3  : fvgMinATR_in
float dispATR     = preset == "Loose" ? 0.5  : preset == "Balanced" ? 0.7  : preset == "Strict" ? 1.0  : dispATR_in

// ───────────── Core series ─────────────
atr = ta.atr(14)

rsiV = ta.rsi(close, oscLen)
[macdL, macdS, macdH] = ta.macd(close, 12, 26, 9)
cciV = ta.cci(hlc3, oscLen)
stochV = ta.sma(ta.stoch(rsiV, rsiV, rsiV, oscLen), 3)
mfiV = ta.mfi(hlc3, oscLen)

osc = switch oscType
    "RSI"       => rsiV
    "MACD Hist" => macdH
    "CCI"       => cciV
    "Stoch RSI" => stochV
    "MFI"       => mfiV
    => rsiV

oscStd = ta.stdev(osc, 100)

// ───────────── Divergence detection (confirmed after pivR bars) ─────────────
pl = ta.pivotlow(osc, pivL, pivR)
ph = ta.pivothigh(osc, pivL, pivR)

var int   pLowBar  = na
var float pLowOsc  = na
var float pLowPx   = na
var int   pHighBar = na
var float pHighOsc = na
var float pHighPx  = na

bool  bullDiv = false
bool  bearDiv = false
int   bdPrevBar = na
float bdPrevPx  = na
int   bdCurBar  = na
float bdCurPx   = na
int   sdPrevBar = na
float sdPrevPx  = na
int   sdCurBar  = na
float sdCurPx   = na

if not na(pl) and barstate.isconfirmed
    curBar = bar_index - pivR
    curPx  = low[pivR]
    if not na(pLowBar)
        gap     = curBar - pLowBar
        pxMove  = pLowPx - curPx          // price made a LOWER low
        oscMove = pl - pLowOsc            // oscillator made a HIGHER low
        if gap >= minBars and gap <= maxBars and pxMove >= minPriceATR * atr[pivR] and oscMove >= oscDiffMult * oscStd
            bullDiv   := true
            bdPrevBar := pLowBar
            bdPrevPx  := pLowPx
            bdCurBar  := curBar
            bdCurPx   := curPx
    pLowBar := curBar
    pLowOsc := pl
    pLowPx  := curPx

if not na(ph) and barstate.isconfirmed
    curBar = bar_index - pivR
    curPx  = high[pivR]
    if not na(pHighBar)
        gap     = curBar - pHighBar
        pxMove  = curPx - pHighPx         // price made a HIGHER high
        oscMove = pHighOsc - ph           // oscillator made a LOWER high
        if gap >= minBars and gap <= maxBars and pxMove >= minPriceATR * atr[pivR] and oscMove >= oscDiffMult * oscStd
            bearDiv   := true
            sdPrevBar := pHighBar
            sdPrevPx  := pHighPx
            sdCurBar  := curBar
            sdCurPx   := curPx
    pHighBar := curBar
    pHighOsc := ph
    pHighPx  := curPx

// ───────────── Dynamic regime filter ─────────────
emaT     = ta.ema(close, trendLen)
slope    = (emaT - emaT[slopeLen]) / atr
avgSlope = ta.sma(math.abs(slope), 100)
strongSlope = math.abs(slope) >= slopeSens * avgSlope

bullTrend = close > emaT and slope > 0 and strongSlope
bearTrend = close < emaT and slope < 0 and strongSlope

bullDivCnt = math.sum(bullDiv ? 1 : 0, regimeLen)
bearDivCnt = math.sum(bearDiv ? 1 : 0, regimeLen)

// Downtrend is "proper" when bullish divergences are forming and outnumber bearish ones
bearAligned = bullDivCnt >= minDivs and bullDivCnt > bearDivCnt
// Uptrend is "proper" when bearish divergences are forming and outnumber bullish ones
bullAligned = bearDivCnt >= minDivs and bearDivCnt > bullDivCnt

// 1 = bullish trend, -1 = bearish trend, 0 = ranging
int regime = bullTrend and bullAligned ? 1 : bearTrend and bearAligned ? -1 : 0

// ───────────── FVG (significant, displacement-driven) ─────────────
bodyMid = math.abs(close[1] - open[1])
bullFVG = low > high[2] and close[1] > open[1] and (low - high[2]) >= fvgMinATR * atr and bodyMid >= dispATR * atr
bearFVG = high < low[2] and close[1] < open[1] and (low[2] - high) >= fvgMinATR * atr and bodyMid >= dispATR * atr

// ───────────── Signal state machine ─────────────
var int   bullSetupBar = na
var float bullSetupLvl = na
var int   bearSetupBar = na
var float bearSetupLvl = na

bool earlyBuy  = false
bool earlySell = false
bool buySig    = false
bool sellSig   = false

// Arm setups when a divergence confirms against the prevailing trend
if bullDiv and regime == -1
    bullSetupBar := bar_index
    bullSetupLvl := bdCurPx
    earlyBuy := true
if bearDiv and regime == 1
    bearSetupBar := bar_index
    bearSetupLvl := sdCurPx
    earlySell := true

// Look for the FVG within the window, cancel if the divergence pivot is broken
if not na(bullSetupBar)
    age = bar_index - bullSetupBar
    if (cancelOnBreak and close < bullSetupLvl) or age > fvgWindow
        bullSetupBar := na
    else if age >= 1 and bullFVG and barstate.isconfirmed
        buySig := true
        bullSetupBar := na

if not na(bearSetupBar)
    age = bar_index - bearSetupBar
    if (cancelOnBreak and close > bearSetupLvl) or age > fvgWindow
        bearSetupBar := na
    else if age >= 1 and bearFVG and barstate.isconfirmed
        sellSig := true
        bearSetupBar := na

// If FVG isn't required, the early signal IS the confirmed signal
if not useFVG
    buySig  := earlyBuy
    sellSig := earlySell

// ───────────── Drawing ─────────────
if showDivs and bullDiv
    c = regime == -1 ? bullCol : color.new(color.gray, 40)
    line.new(bdPrevBar, bdPrevPx, bdCurBar, bdCurPx, color=c, width=2)
if showDivs and bearDiv
    c = regime == 1 ? bearCol : color.new(color.gray, 40)
    line.new(sdPrevBar, sdPrevPx, sdCurBar, sdCurPx, color=c, width=2)

if useFVG and buySig
    box.new(bar_index - 2, low, bar_index + boxExt, high[2], border_color=bullCol, bgcolor=color.new(bullCol, 85))
if useFVG and sellSig
    box.new(bar_index - 2, low[2], bar_index + boxExt, high, border_color=bearCol, bgcolor=color.new(bearCol, 85))

bgcolor(showBg ? (regime == 1 ? color.new(bullCol, 92) : regime == -1 ? color.new(bearCol, 92) : color.new(color.gray, 94)) : na)
plot(showEma ? emaT : na, "Trend EMA", color=regime == 1 ? bullCol : regime == -1 ? bearCol : color.gray, linewidth=2)

plotshape(showEarly and useFVG and earlyBuy,  "Early Buy",  shape.circle, location.belowbar, color=color.new(bullCol, 30), size=size.tiny)
plotshape(showEarly and useFVG and earlySell, "Early Sell", shape.circle, location.abovebar, color=color.new(bearCol, 30), size=size.tiny)
plotshape(buySig,  "BUY",  shape.labelup,   location.belowbar, color=bullCol, textcolor=color.white, text="BUY",  size=size.small)
plotshape(sellSig, "SELL", shape.labeldown, location.abovebar, color=bearCol, textcolor=color.white, text="SELL", size=size.small)

// ───────────── Dashboard ─────────────
var table tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 60))
if showTable and barstate.islast
    regTxt = regime == 1 ? "BULL TREND" : regime == -1 ? "BEAR TREND" : "RANGING"
    regCol = regime == 1 ? bullCol : regime == -1 ? bearCol : color.gray
    bAge = na(bullSetupBar) ? "-" : str.tostring(fvgWindow - (bar_index - bullSetupBar)) + " bars left"
    sAge = na(bearSetupBar) ? "-" : str.tostring(fvgWindow - (bar_index - bearSetupBar)) + " bars left"
    table.cell(tbl, 0, 0, "Regime", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 0, regTxt, text_color=color.white, bgcolor=regCol, text_size=size.small)
    table.cell(tbl, 0, 1, "Bull divs (memory)", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(bullDivCnt), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 2, "Bear divs (memory)", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(bearDivCnt), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 3, "Slope strength", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 3, strongSlope ? "Strong" : "Weak", text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 4, "Buy setup (FVG window)", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 4, bAge, text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 5, "Sell setup (FVG window)", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 5, sAge, text_color=color.white, text_size=size.small)

// ───────────── Alerts ─────────────
alertcondition(buySig,    "BUY signal",  "Bullish divergence in bearish trend (+FVG) confirmed")
alertcondition(sellSig,   "SELL signal", "Bearish divergence in bullish trend (+FVG) confirmed")
alertcondition(earlyBuy,  "Early BUY (divergence confirmed)",  "Bullish divergence confirmed in bearish trend")
alertcondition(earlySell, "Early SELL (divergence confirmed)", "Bearish divergence confirmed in bullish trend")
alertcondition(regime != regime[1], "Regime change", "Market regime changed")
````
