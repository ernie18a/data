# CBBI Rainbow Approximation (BTC Only)

- url: https://www.tradingview.com/script/3oFMwCqQ-CBBI-Rainbow-Approximation-BTC-Only/
- type: indicator
- pine_id: PUB;a2c2ec1091fc4ea0af53b1a093d287f3
- version: 1.0

## Description

# CBBI Rainbow Approximation

## Overview

This indicator is a Pine Script **approximation inspired by the ColinTalksCrypto Bitcoin Bull Run Index (CBBI)** methodology. It is **not** the official CBBI and does not claim to reproduce its behavior — it follows the same general philosophy of combining multiple complementary valuation metrics into a single 0–100 confidence score, but uses a different set of inputs adapted to what is computable directly in Pine Script.

The original CBBI relies on 9 on-chain metrics (RHODL Ratio, Reserve Risk, Terminal Price, etc.) that are not available in Pine Script. This script substitutes those with 6 widely studied technical metrics and packages them into a single rainbow-colored oscillator for cycle context.

## Why a Composite Index Rather Than Individual Metrics

Each Bitcoin valuation metric has known weaknesses when used in isolation:

- The **Mayer Multiple** can stay elevated for months during strong bull runs without marking a top
- The **Pi Cycle Top** has fired only a handful of times historically — small sample size
- The **200-Week MA** is too slow to react during fast cycles
- The **Monthly RSI** is purely momentum-based with no valuation anchor
- The **Power Law** ignores cyclical behavior entirely
- The **Golden Ratio Multiplier** depends heavily on calibration

A composite score smooths out the individual weaknesses by requiring **broad agreement** across different methodological families before signaling a cycle extreme. A single metric flashing red is a weak signal; five or six aligning is a stronger one.

## Why These 6 Metrics Specifically

The metrics were chosen so that each one measures a **different dimension** of the market cycle, minimizing redundancy:

| Metric | Dimension Measured | Time Horizon |
|---|---|---|
| Mayer Multiple | Price extension above baseline | Medium term (200d) |
| Pi Cycle Top | Trend acceleration / MA convergence | Medium-long term |
| 200-Week MA Heatmap | Distance from multi-year support | Very long term |
| Golden Ratio Multiplier | Fibonacci-based cycle expansion | Long term |
| Monthly RSI | Pure momentum, no MA dependency | Macro |
| Power Law Regression | Log-log valuation anchor (no MA) | All-history |

Four of the six rely on moving averages of different lengths (111, 200, 350, 1400 days), but each one transforms that information in a structurally different way (ratio, crossover convergence, distance, multiplier band, regression). The remaining two (RSI, Power Law) intentionally bypass moving averages entirely to avoid over-weighting MA-based behavior.

## How the Score Is Built

1. Each metric is computed in **daily timeframe** (regardless of the chart's display timeframe)
2. Each metric is normalized to a **0–100 scale** based on its historical extremes
3. Available metrics are averaged into a raw composite score
4. The raw score is smoothed by a configurable SMA (default: 7 days)

When some metrics return NaN (e.g. the 200-week MA before mid-2014 because Bitcoin lacked the historical data), the script averages only the available ones. The "Metrics OK: X/6" cell in the info table shows how many metrics contributed to the current score.

## Rainbow Zones

The score is plotted against six color-coded zones derived from historical CBBI patterns:

- **0–20 (Blue)** — Capitulation: extreme value, historical accumulation zones
- **20–40 (Cyan)** — Accumulation: still undervalued
- **40–60 (Green)** — Neutral: fair value range
- **60–75 (Yellow)** — Bullish: trending toward overheated
- **75–85 (Orange)** — Overheated: caution advised
- **85–100 (Red)** — Blow-off Top: historical sell zones

Triangle markers print automatically when the score crosses 85 upward (probable top) or 15 downward (probable bottom).

## Multi-Timeframe Behavior

A common issue with Bitcoin cycle indicators is that switching from daily to weekly or monthly view distorts moving-average-based metrics. To prevent this, **all six metrics are computed in daily resolution via a single grouped `request.security` call**, regardless of the timeframe shown on the chart. The score therefore stays consistent whether you view it on the 1D, 1W, 1M, or higher timeframes — the line you see is always the daily score.

## Key Features

- 6 normalized metrics combined into a 0–100 composite score
- Multi-timeframe consistent (calculations forced to daily)
- Safe NaN handling for early Bitcoin history
- Live metrics table showing each component's contribution
- Built-in alerts for top (>85) and bottom (<15) crossovers
- Toggleable rainbow bands, score line, signals, and table

## How to Use

1. Apply the indicator to a Bitcoin chart (default symbol: `INDEX:BTCUSD`)
2. View on any timeframe — the score is computed in daily and remains consistent
3. The score entering the red zone (>85) historically aligns with cycle peaks
4. The score entering the blue zone (<20) historically aligns with cycle bottoms
5. Use as macro cycle context, not as a short-term timing tool

## Important Notes

- **This is not the official CBBI.** It is an open-source approximation. The official CBBI is maintained at colintalkscrypto.com and uses proprietary on-chain data feeds not accessible from Pine Script.
- **Past patterns may not repeat.** The thresholds and metric calibrations are based on Bitcoin's prior cycles. Future cycle behavior may differ as the market matures.
- **This is not financial advice.** The indicator provides cycle context only. Always combine multiple tools and conduct your own research before making investment decisions.
- **Not suitable for short-term trading.** The metrics are macro by design and update slowly.

## Credits

Conceptual inspiration from **Colin Talks Crypto** for the original CBBI methodology of combining multiple valuation metrics into a composite confidence score. Individual metrics (Mayer Multiple, Pi Cycle Top, 200-Week MA Heatmap, Golden Ratio Multiplier) are well-known public-domain Bitcoin cycle tools, none of which are reproduced from any specific TradingView script.

## Source Code

````pine
//@version=6
// =====================================================================
// CBBI Rainbow Approximation (ColinTalksCrypto Bitcoin Bull Run Index)
// =====================================================================
// DISCLAIMER: This is an APPROXIMATION inspired by the CBBI methodology.
// It does not reproduce the official CBBI behavior. The official CBBI
// uses 9 on-chain metrics, several of which (RHODL Ratio, Reserve Risk,
// Terminal Price, etc.) are not available in Pine Script.
//
// This script combines 6 macro Bitcoin valuation metrics that ARE
// available on TradingView, normalized to a 0-100 scale, into a single
// composite score. Each metric measures a different aspect of the
// market cycle (price extension, momentum, long-term trend, etc.) so
// they complement rather than duplicate each other.
//
// Multi-timeframe robust: all calculations are forced to daily via a
// single grouped request.security call, so the score remains consistent
// when viewed on weekly, monthly, or higher timeframes.
// =====================================================================

indicator("CBBI Rainbow Approximation (BTC Only)", "CBBI",
     overlay = false, scale = scale.right, max_bars_back = 5000)

// ----------------------- INPUTS -----------------------
showRainbow = input.bool(true,  "Show Rainbow bands")
showScore   = input.bool(true,  "Show CBBI score (0-100)")
showSignals = input.bool(true,  "Show Top / Bottom signals")
showTable   = input.bool(true,  "Show metrics table")
smoothLen   = input.int(7, "Score smoothing (days)", minval = 1, maxval = 50)
btcSymbol   = input.symbol("INDEX:BTCUSD", "BTC symbol")

// ----------------------- DATA -------------------------
// All calculations are done in DAILY, regardless of display TF.
// This ensures the score stays consistent on weekly, monthly, etc.

[btcD, sma200D, sma111D, sma350D, wma200wD, rsiMonthlyD, dayCount] =
     request.security(btcSymbol, "1D",
         [close,
          ta.sma(close, 200),
          ta.sma(close, 111),
          ta.sma(close, 350),
          ta.sma(close, 1400),  // 200 weeks = 1400 days
          ta.rsi(close, 14),
          (time - timestamp("2010-07-18")) / 86400000.0],
         barmerge.gaps_off, barmerge.lookahead_off)

// ===================== METRICS =====================

// --- 1) Mayer Multiple = Price / 200 SMA ---
// Captures short-to-medium term price extension above/below the
// 200-day baseline. Historical tops cluster above 2.4, bottoms near 0.5.
mayer = not na(sma200D) and sma200D > 0 ? btcD / sma200D : na
mayerScore = na(mayer) ? na :
     math.max(0, math.min(100, (mayer - 0.5) / (2.4 - 0.5) * 100))

// --- 2) Pi Cycle Top: 111 DMA vs 350 DMA * 2 ---
// Long-standing cycle-top detector. Crossover of these two MAs has
// historically marked Bitcoin cycle tops within a few days.
sma350x2 = sma350D * 2
piRatio = not na(sma111D) and not na(sma350x2) and sma350x2 > 0 ?
     sma111D / sma350x2 : na
piScore = na(piRatio) ? na : math.max(0, math.min(100, piRatio * 100))

// --- 3) 200 Week Moving Average Heatmap ---
// Long-term trend baseline. Bitcoin's price has historically respected
// the 200-week SMA as multi-year support during deep bear markets.
mult200w = not na(wma200wD) and wma200wD > 0 ? btcD / wma200wD : na
score200w = na(mult200w) ? na :
     math.max(0, math.min(100, (mult200w - 1) / (5 - 1) * 100))

// --- 4) Golden Ratio Multiplier (based on 350 DMA) ---
// Multi-band expansion model where the 350 DMA scales by Fibonacci-like
// multipliers. 1.6x indicates early bull, 21x indicates blow-off top.
grMult = not na(sma350D) and sma350D > 0 ? btcD / sma350D : na
grScore = na(grMult) ? na :
     math.max(0, math.min(100, (grMult - 1.6) / (21 - 1.6) * 100))

// --- 5) Monthly RSI (macro momentum) ---
// Macro momentum filter. Monthly RSI above 90 has historically
// coincided with Bitcoin cycle peaks.
rsiScore = na(rsiMonthlyD) ? na :
     math.max(0, math.min(100, (rsiMonthlyD - 50) / (95 - 50) * 100))

// --- 6) Power Law / Logarithmic regression (valuation proxy) ---
// Long-term price expectation derived from log-log regression of price
// against days since genesis. Acts as a non-MA-based valuation anchor.
safeDays = math.max(dayCount, 1)
logRegr = math.pow(10, -17.01 + 5.84 * math.log10(safeDays))
mvrvProxy = not na(logRegr) and logRegr > 0 ? btcD / logRegr : na
mvrvScore = na(mvrvProxy) ? na :
     math.max(0, math.min(100, (mvrvProxy - 0.5) / (3 - 0.5) * 100))

// ===================== COMPOSITE SCORE =====================
// Average of available metrics (skips NaN values during early history,
// e.g. before the 200-week SMA has enough data points).
sumScores = 0.0
countScores = 0

if not na(mayerScore)
    sumScores += mayerScore
    countScores += 1
if not na(piScore)
    sumScores += piScore
    countScores += 1
if not na(score200w)
    sumScores += score200w
    countScores += 1
if not na(grScore)
    sumScores += grScore
    countScores += 1
if not na(rsiScore)
    sumScores += rsiScore
    countScores += 1
if not na(mvrvScore)
    sumScores += mvrvScore
    countScores += 1

rawScore = countScores > 0 ? sumScores / countScores : na
cbbiScore = ta.sma(rawScore, smoothLen)

// ===================== PLOT =====================

// Horizontal Rainbow zone bands
band0   = plot(showRainbow ? 0   : na, "0",   color = color.new(color.blue,   90))
band20  = plot(showRainbow ? 20  : na, "20",  color = color.new(color.aqua,   90))
band40  = plot(showRainbow ? 40  : na, "40",  color = color.new(color.green,  90))
band60  = plot(showRainbow ? 60  : na, "60",  color = color.new(color.yellow, 90))
band75  = plot(showRainbow ? 75  : na, "75",  color = color.new(color.orange, 90))
band85  = plot(showRainbow ? 85  : na, "85",  color = color.new(color.red,    90))
band100 = plot(showRainbow ? 100 : na, "100", color = color.new(color.maroon, 90))

// Rainbow zone fills
fill(band0,   band20,  color = color.new(color.blue,   85), title = "Capitulation")
fill(band20,  band40,  color = color.new(color.aqua,   85), title = "Accumulation")
fill(band40,  band60,  color = color.new(color.green,  85), title = "Neutral")
fill(band60,  band75,  color = color.new(color.yellow, 85), title = "Bullish")
fill(band75,  band85,  color = color.new(color.orange, 80), title = "Overheated")
fill(band85,  band100, color = color.new(color.red,    75), title = "Blow-off Top")

// Dynamic score color (rainbow effect)
scoreColor = na(cbbiScore) ? color.gray :
             cbbiScore >= 85 ? color.red :
             cbbiScore >= 75 ? color.orange :
             cbbiScore >= 60 ? color.yellow :
             cbbiScore >= 40 ? color.green :
             cbbiScore >= 20 ? color.aqua :
                               color.blue

plot(showScore ? cbbiScore : na, "CBBI Score",
     color = scoreColor, linewidth = 3)

// Top / Bottom signals
topSignal    = ta.crossover(cbbiScore,  85)
bottomSignal = ta.crossunder(cbbiScore, 15)

plotshape(showSignals and topSignal, "Probable Top",
     shape.triangledown, location.top, color.red,
     text = "TOP", textcolor = color.white, size = size.small)

plotshape(showSignals and bottomSignal, "Probable Bottom",
     shape.triangleup, location.bottom, color.green,
     text = "BOTTOM", textcolor = color.white, size = size.small)

// ===================== INFO TABLE =====================
var table info = table.new(position.top_right, 2, 9,
     bgcolor = color.new(color.black, 80), border_width = 1)

f_fmt(float v) => na(v) ? "N/A" : str.tostring(v, "#.0")

if barstate.islast and showTable
    table.cell(info, 0, 0, "Metric",       text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info, 1, 0, "Score",        text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(info, 0, 1, "Mayer Mult.",  text_color = color.white)
    table.cell(info, 1, 1, f_fmt(mayerScore), text_color = color.white)
    table.cell(info, 0, 2, "Pi Cycle",     text_color = color.white)
    table.cell(info, 1, 2, f_fmt(piScore), text_color = color.white)
    table.cell(info, 0, 3, "200WMA Heat",  text_color = color.white)
    table.cell(info, 1, 3, f_fmt(score200w), text_color = color.white)
    table.cell(info, 0, 4, "Golden Ratio", text_color = color.white)
    table.cell(info, 1, 4, f_fmt(grScore), text_color = color.white)
    table.cell(info, 0, 5, "Monthly RSI",  text_color = color.white)
    table.cell(info, 1, 5, f_fmt(rsiScore), text_color = color.white)
    table.cell(info, 0, 6, "Power Law",    text_color = color.white)
    table.cell(info, 1, 6, f_fmt(mvrvScore), text_color = color.white)
    table.cell(info, 0, 7, "Metrics OK",   text_color = color.white)
    table.cell(info, 1, 7, str.tostring(countScores) + "/6", text_color = color.white)
    table.cell(info, 0, 8, "CBBI TOTAL",   text_color = color.white, bgcolor = scoreColor)
    table.cell(info, 1, 8, f_fmt(cbbiScore), text_color = color.white, bgcolor = scoreColor)

// ===================== ALERTS =====================
alertcondition(topSignal,    "CBBI Top",    "CBBI > 85 - Probable cycle top")
alertcondition(bottomSignal, "CBBI Bottom", "CBBI < 15 - Probable cycle bottom")
````
