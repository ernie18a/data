# Mohit Strength Box - Full Confirmation Table

- url: https://www.tradingview.com/script/L5DQzoxO-Mohit-Strength-Box-Full-Confirmation-Table/
- type: indicator
- pine_id: PUB;bdfd71e1e5ad41748c7e23ef5cde7845
- version: 1.0

## Description

# Mohit Strength Box - Full Confirmation Table

## Overview

This indicator consolidates six core technical dimensions — trend, momentum, volume, volatility, and relative performance — into a single on-chart status box. Instead of switching between separate RSI, MACD, Supertrend, and ADX panels, this tool reads all of them at a glance and gives an aggregated "Overall Score" so you can quickly judge whether a stock has genuine multi-factor confirmation before entering a trade, or whether signals are conflicting.

It is built for swing and positional traders working on Indian equities (NSE/BSE) but works on any symbol, any timeframe, and any asset class supported by TradingView.

---

## What the Box Shows

**1. Relative Strength (RS) vs Benchmark**
Calculated using a Mansfield-style formula: the ratio of the stock's price to a benchmark's price (default NSE:NIFTY), smoothed and expressed as a percentage deviation from its own moving average. When this value is above zero, the stock is outperforming the benchmark; below zero, it is underperforming. This is the same concept institutional analysts use to separate market leaders from laggards, independent of whether the broader index itself is up or down.

**2. RVOL (Relative Volume / Volume Expansion)**
Current volume divided by its rolling average (default 20 periods). A reading above the configurable threshold (default 1.5x) flags genuine volume expansion — useful for spotting institutional accumulation, breakout confirmation, or unusual activity before a move.

**3. ATR Expansion**
Compares the current Average True Range to the ATR from a set number of bars back (default 5). Expanding ATR signals rising volatility and often precedes larger directional moves; this row shows both the direction (expanding/contracting) and the percentage change.

**4. VCP (Volatility Contraction Pattern)**
Flags when both ATR and Bollinger Band Width are contracting relative to their own moving averages simultaneously. This mirrors the "tightening" phase traders look for ahead of a breakout — the market coiling before a directional expansion. This is a simplified proxy for the VCP concept and does not replace manual pivot/structure analysis.

**5. Supertrend**
Standard Supertrend calculation (default factor 3, ATR length 10). Bullish when price is trading above the trailing stop line, bearish when below. The line itself is also plotted on the chart for visual trailing-stop reference.

**6. MACD**
Standard MACD (12/26/9 default). Bullish when the MACD line is above its signal line, bearish when below.

**7. RSI (50 Midline)**
Rather than using the traditional 30/70 overbought/oversold levels, this indicator treats the 50 line as the trend filter: RSI above 50 is read as bullish momentum, below 50 as bearish momentum — a common institutional approach for trend-following systems.

**8. EMA Trend Alignment**
Checks whether price is above both a fast EMA (default 20) and a slow EMA (default 50), and that the fast EMA is above the slow EMA. This requires full alignment rather than a simple single-EMA crossover, reducing false signals from choppy price action.

**9. ADX / DI Direction**
Uses +DI vs -DI to determine directional bias, and ADX value vs a threshold (default 20) to flag whether the current trend has strength or is weak/range-bound.

**10. Overall Confirmation Score**
Aggregates six directional signals — RS, Supertrend, MACD, RSI, EMA Trend, and DI direction — into a single count (e.g., "5/6 Bullish"). This gives an at-a-glance confluence read: the more signals aligned, the stronger the technical case in that direction. This score deliberately excludes RVOL and VCP, since those measure volume/volatility conditions rather than directional bias.

---

## How to Use It

- **Trend confirmation before entry**: Look for a high bullish score (5/6 or 6/6) alongside RVOL expansion and/or an active VCP flag — this combination suggests a stock with strong underlying trend and a volume/volatility setup for continuation or breakout.
- **Avoiding weak setups**: A mixed score (e.g., 3/6) suggests conflicting signals across timeframes/indicators — often better to wait for clearer alignment.
- **Relative strength as a filter**: Use RS to separate genuine leaders from stocks simply moving with the index. A stock with RS below zero is underperforming the benchmark even if its own price is rising.
- **VCP + confluence combo**: The built-in alert for "VCP + Majority Bullish Confluence" is designed to flag exactly this — a stock coiling in volatility while the majority of trend/momentum indicators are already aligned bullish.

---

## Alerts Included

- RS positive + RVOL expansion
- VCP detected
- VCP + RVOL expansion + RS positive (breakout setup)
- Supertrend + MACD + RSI all bullish (trend trio)
- VCP + majority bullish confluence
- All 6 signals bullish (unanimous)
- All 6 signals bearish (unanimous)

---

## Customizable Inputs

Every component is independently configurable: benchmark symbol, RS smoothing length, RVOL average length and threshold, ATR length and lookback, VCP contraction ratio and Bollinger settings, Supertrend factor/ATR length, MACD lengths, RSI length, EMA fast/slow lengths, ADX/DI length and strength threshold, plus table position and text size.

---

## Important Notes

- This indicator is a **decision-support tool**, not a standalone trading system. It does not predict future price movement and should be combined with price action, risk management, and your own market structure analysis.
- The VCP row is a simplified volatility-based proxy, not a full pivot/structure-based VCP detector (which typically requires identifying successive higher lows/contracting swing ranges manually).
- Relative Strength, EMA alignment, and DI direction are lagging by nature (as with any moving-average or trend-based calculation) — they confirm trend, they do not predict reversals.
- Past performance of any signal combination shown here does not guarantee future results. Always backtest on your specific universe of stocks and timeframe before relying on this for live decisions.

## Source Code

````pine
//@version=6
indicator("Mohit Strength Box - Full Confirmation Table", overlay=true, max_labels_count=500)

// =========================== INPUTS ===========================
grp1 = "Relative Strength"
benchSym   = input.symbol("NSE:NIFTY",  "Benchmark Symbol", group=grp1)
rsLen      = input.int(20, "RS Smoothing Length", minval=2, group=grp1)

grp2 = "Volume (RVOL)"
rvolLen    = input.int(20, "RVOL Average Length", minval=2, group=grp2)
rvolExpTh  = input.float(1.5, "RVOL Expansion Threshold", minval=1.0, step=0.1, group=grp2)

grp4 = "ATR Expansion"
atrLen      = input.int(14, "ATR Length", minval=1, group=grp4)
atrLookback = input.int(5,  "ATR Compare Bars Back", minval=1, group=grp4)

grp5 = "Volatility Contraction (VCP)"
vcpLen      = input.int(10, "VCP ATR SMA Length", minval=2, group=grp5)
vcpContractPct = input.float(0.80, "Contraction Ratio (ATR < X * SMA(ATR))", minval=0.1, maxval=1.0, step=0.05, group=grp5)
bbLen       = input.int(20, "Bollinger Length (for BB Width check)", minval=2, group=grp5)
bbMult      = input.float(2.0, "Bollinger Mult", group=grp5)

grp7 = "Supertrend"
stFactor   = input.float(3.0, "ATR Factor", minval=0.1, step=0.1, group=grp7)
stAtrLen   = input.int(10, "ATR Length", minval=1, group=grp7)

grp8 = "MACD"
macdFast   = input.int(12, "Fast Length", minval=1, group=grp8)
macdSlow   = input.int(26, "Slow Length", minval=1, group=grp8)
macdSig    = input.int(9,  "Signal Length", minval=1, group=grp8)

grp9 = "RSI"
rsiLen     = input.int(14, "RSI Length", minval=1, group=grp9)

grp10 = "EMA Trend"
emaFastLen = input.int(20, "Fast EMA", minval=1, group=grp10)
emaSlowLen = input.int(50, "Slow EMA", minval=1, group=grp10)

grp11 = "ADX / DI"
adxDiLen   = input.int(14, "DI Length", minval=1, group=grp11)
adxLen     = input.int(14, "ADX Smoothing", minval=1, group=grp11)
adxThresh  = input.float(20.0, "ADX 'Strong Trend' Threshold", group=grp11)

grp6 = "Table"
tblPos   = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp6)
txtSize  = input.string("Normal", "Text Size", options=["Small","Normal","Large"], group=grp6)

// =========================== CALCULATIONS ===========================

// ---- 1. Relative Strength (Mansfield-style), oscillator around 0 ----
benchClose = request.security(benchSym, timeframe.period, close, lookahead=barmerge.lookahead_off)
rsRatio    = close / benchClose
rsBase     = ta.sma(rsRatio, rsLen)
rsLine     = (rsRatio / rsBase - 1) * 100
rsAboveZero = rsLine > 0
rsRising    = rsLine > rsLine[1]

// ---- 2. RVOL (Volume Expansion) ----
volAvg   = ta.sma(volume, rvolLen)
rvol     = volAvg != 0 ? volume / volAvg : na
rvolExpanding = rvol >= rvolExpTh

// ---- 3. ATR Expansion ----
atrVal = ta.atr(atrLen)
atrExpanding = atrVal > atrVal[atrLookback]
atrPctChange = atrVal[atrLookback] != 0 ? (atrVal / atrVal[atrLookback] - 1) * 100 : na

// ---- 4. Volatility Contraction (VCP) ----
atrSmaVcp = ta.sma(atrVal, vcpLen)
atrContracting = atrVal < (atrSmaVcp * vcpContractPct)

basis = ta.sma(close, bbLen)
dev   = bbMult * ta.stdev(close, bbLen)
bbUpper = basis + dev
bbLower = basis - dev
bbWidth = basis != 0 ? (bbUpper - bbLower) / basis * 100 : na
bbWidthAvg = ta.sma(bbWidth, bbLen)
bbContracting = bbWidth < bbWidthAvg

vcpActive = atrContracting and bbContracting

// ---- 5. Supertrend ----
[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
stBullish = stDir < 0   // built-in: direction < 0 means uptrend

// ---- 6. MACD ----
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBullish = macdLine > macdSignal

// ---- 7. RSI (50 midline) ----
rsiVal = ta.rsi(close, rsiLen)
rsiBullish = rsiVal > 50

// ---- 8. EMA Trend Alignment ----
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaBullish = close > emaFast and emaFast > emaSlow

// ---- 9. ADX / DI Direction ----
[diPlus, diMinus, adxVal] = ta.dmi(adxDiLen, adxLen)
diBullish = diPlus > diMinus
adxStrong = adxVal > adxThresh

// ---- 10. Overall Confirmation Score ----
bullCount = (rsAboveZero ? 1 : 0) + (stBullish ? 1 : 0) + (macdBullish ? 1 : 0) + (rsiBullish ? 1 : 0) + (emaBullish ? 1 : 0) + (diBullish ? 1 : 0)
totalSignals = 6
majorityBullish = bullCount >= math.round(totalSignals / 2) + 1

// =========================== TABLE ===========================
getPos(p) =>
    p == "Top Right" ? position.top_right :
     p == "Top Left" ? position.top_left :
     p == "Bottom Right" ? position.bottom_right : position.bottom_left

getSize(s) =>
    s == "Small" ? size.small : s == "Large" ? size.large : size.normal

var table box = table.new(getPos(tblPos), 2, 11, border_width=1, border_color=color.gray, frame_color=color.gray, frame_width=1)

colGood  = color.new(color.green, 0)
colBad   = color.new(color.red, 0)
colNeut  = color.new(color.gray, 0)
colHead  = color.new(color.new(#1e1e1e, 0), 0)

cellBg(cond) => cond ? colGood : colBad

if barstate.islast
    table.cell(box, 0, 0, "Metric", bgcolor=colHead, text_color=color.white, text_size=getSize(txtSize))
    table.cell(box, 1, 0, "Status", bgcolor=colHead, text_color=color.white, text_size=getSize(txtSize))

    // Relative Strength
    table.cell(box, 0, 1, "RS vs " + syminfo.ticker(benchSym), text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 1, (rsAboveZero ? "▲ " : "▼ ") + str.tostring(rsLine, "#.##"),
         bgcolor=cellBg(rsAboveZero), text_color=color.white, text_size=getSize(txtSize))

    // RVOL
    table.cell(box, 0, 2, "RVOL", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 2, str.tostring(rvol, "#.##") + "x" + (rvolExpanding ? " ⚡" : ""),
         bgcolor=cellBg(rvolExpanding), text_color=color.white, text_size=getSize(txtSize))

    // ATR Expansion
    table.cell(box, 0, 3, "ATR Expansion", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 3, (atrExpanding ? "▲ " : "▼ ") + str.tostring(atrPctChange, "#.#") + "%",
         bgcolor=cellBg(atrExpanding), text_color=color.white, text_size=getSize(txtSize))

    // VCP
    table.cell(box, 0, 4, "VCP (Contraction)", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 4, vcpActive ? "YES ✔" : "No",
         bgcolor=vcpActive ? colGood : colBad, text_color=color.white, text_size=getSize(txtSize))

    // Supertrend
    table.cell(box, 0, 5, "Supertrend", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 5, stBullish ? "Bullish ▲" : "Bearish ▼",
         bgcolor=cellBg(stBullish), text_color=color.white, text_size=getSize(txtSize))

    // MACD
    table.cell(box, 0, 6, "MACD", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 6, macdBullish ? "Bullish ▲" : "Bearish ▼",
         bgcolor=cellBg(macdBullish), text_color=color.white, text_size=getSize(txtSize))

    // RSI
    table.cell(box, 0, 7, "RSI (50 line)", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 7, str.tostring(rsiVal, "#.#") + (rsiBullish ? " Bullish ▲" : " Bearish ▼"),
         bgcolor=cellBg(rsiBullish), text_color=color.white, text_size=getSize(txtSize))

    // EMA Trend
    table.cell(box, 0, 8, "EMA Trend (" + str.tostring(emaFastLen) + "/" + str.tostring(emaSlowLen) + ")", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 8, emaBullish ? "Bullish ▲" : "Bearish ▼",
         bgcolor=cellBg(emaBullish), text_color=color.white, text_size=getSize(txtSize))

    // ADX / DI
    table.cell(box, 0, 9, "ADX/DI (" + str.tostring(adxVal, "#.#") + ")", text_size=getSize(txtSize), text_color=color.white, bgcolor=colNeut)
    table.cell(box, 1, 9, (diBullish ? "+DI ▲" : "-DI ▼") + (adxStrong ? " Strong" : " Weak"),
         bgcolor=cellBg(diBullish), text_color=color.white, text_size=getSize(txtSize))

    // Overall Confirmation Score
    table.cell(box, 0, 10, "Overall Score", text_size=getSize(txtSize), text_color=color.white, bgcolor=colHead)
    table.cell(box, 1, 10, str.tostring(bullCount) + "/" + str.tostring(totalSignals) + (majorityBullish ? " Bullish ▲" : " Bearish ▼"),
         bgcolor=majorityBullish ? colGood : colBad, text_color=color.white, text_size=getSize(txtSize))

// =========================== PLOTS / ALERTS ===========================
plot(stLine, "Supertrend", color=stBullish ? color.new(color.green, 0) : color.new(color.red, 0), linewidth=2)
plot(emaFast, "EMA Fast", color=color.new(color.blue, 40), display=display.pane)
plot(emaSlow, "EMA Slow", color=color.new(color.orange, 40), display=display.pane)

alertcondition(rsAboveZero and rvolExpanding, "RS Positive + RVOL Expansion", "{{ticker}}: RS above 0 and RVOL expanding")
alertcondition(vcpActive, "VCP Detected", "{{ticker}}: Volatility Contraction Pattern active")
alertcondition(vcpActive and rvolExpanding and rsAboveZero, "VCP Breakout Setup", "{{ticker}}: VCP + RVOL expansion + RS positive - possible breakout")
alertcondition(stBullish and macdBullish and rsiBullish, "Trend Trio Bullish", "{{ticker}}: Supertrend, MACD, and RSI all bullish")
alertcondition(majorityBullish and vcpActive, "VCP + Majority Bullish Confluence", "{{ticker}}: VCP contraction with majority of indicators bullish - watch for breakout")
alertcondition(bullCount == totalSignals, "All Signals Bullish", "{{ticker}}: All 6 core signals (RS, Supertrend, MACD, RSI, EMA, DI) are bullish")
alertcondition(bullCount == 0, "All Signals Bearish", "{{ticker}}: All 6 core signals (RS, Supertrend, MACD, RSI, EMA, DI) are bearish")
````
