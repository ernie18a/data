# RSI Area Bias - Multi-Timeframe Dashboard

- url: https://www.tradingview.com/script/1y3bsd3r/
- type: indicator
- pine_id: PUB;382f0a514ca8413fac15a104a6b3dda4
- version: 1.0

## Description

RSI Area Bias - Multi-Timeframe Dashboard is a momentum dominance indicator that quantifies the balance of bullish and bearish pressure across four independent timeframes simultaneously. Rather than plotting a raw RSI line, it measures the cumulative area between the RSI and its moving average over a rolling window, converts that area into a normalized score between −100 and +100, and presents the results in a color-coded dashboard table — giving traders an objective, cross-timeframe view of market bias at a glance.

What Problem This Solves
Standard RSI indicators are single-timeframe tools. A trader looking at a 15-minute chart has no immediate way to know whether the 1H, 4H, or Daily RSI structure is bullish or bearish without switching timeframes manually. This indicator solves that by computing a normalized momentum score for each of four user-defined timeframes and displaying them all in one persistent table — regardless of which timeframe the chart is currently set to.

How It Works — Technical Details
Area Score Calculation:
For each timeframe, the script computes ta.rsi(close, rsiLen) and smooths it with ta.ema(rsiVal, maLen) to produce a dynamic baseline. The gap between the RSI and its EMA is split into a bullish component (RSI above EMA) and a bearish component (RSI below EMA). Each component is accumulated using ta.sma() * lookback over the user-defined lookback window, producing a raw area value that reflects cumulative momentum pressure — not just the current RSI reading.
Normalization to −100 / +100:
Raw area scores vary enormously across different assets and timeframes (a crypto score might be 800 while a forex score is 3). To make STRONG/WEAK classifications meaningful across any symbol, the raw score is normalized using a rolling min/max window (ta.highest and ta.lowest over normLen bars). The result is always between −100 and +100, where +100 means maximum historical bullish dominance and −100 means maximum historical bearish dominance.
Timeframe Independence:
All calculations — RSI, EMA, area accumulation, normalization, and trend duration counting — are executed inside a single master function f_all() and called via request.security() for each timeframe. This means every timeframe's score is computed using its own bars, not the chart's bars. The table values remain identical regardless of which timeframe the chart is set to.
Trend Duration:
Inside f_all(), the script iterates backward through up to 499 bars of that timeframe's history to count how many consecutive bars the current direction (bull/bear) has been maintained. This bar count is returned alongside the score and displayed in the BARS column of the table.
Overall Bias Row:
A weighted average of all four timeframe scores is computed as (score1×1 + score2×2 + score3×3 + score4×4) / 10, giving progressively more weight to higher timeframes. This single value represents the aggregate directional bias across the entire timeframe stack.

Dashboard Table
The top-right table displays five columns for each timeframe plus an OVERALL row:

TF — the timeframe label
DIR — BULL or BEAR, colored green or red
SCORE — normalized value from −100 to +100, color intensity reflects magnitude
POWER — VERY STRONG / STRONG / MEDIUM / WEAK / NEUTRAL, color-matched to direction and intensity (dark green = strong bull, faded green = weak bull, dark red = strong bear, faded red = weak bear)
BARS — number of consecutive bars the current direction has held; longer streaks shown in yellow


Chart Panel
The current chart timeframe's normalized score is plotted as a line, alongside its EMA (Score MA). The area between the two lines is filled green when the score is above the MA (momentum accelerating) and red when below (momentum fading). Five horizontal reference lines mark the key thresholds at 0, ±50, and ±75.

How To Use

Set the four timeframes from short to long (e.g. 15m, 1H, 4H, Daily) to build a complete timeframe stack
When all four DIR cells show BULL and OVERALL is BULL STRONG or higher, conditions favor long momentum trades
When higher timeframes (4H, Daily) are BEAR but lower timeframes are BULL, expect pullbacks rather than trend reversals
Use the BARS column to assess trend maturity — a very high bar count may indicate an overextended move
The chart panel fill turning green (score crossing above its MA) can serve as an early signal of momentum shift before the score crosses zero
Adjust Touch Sensitivity per asset class:

Crypto: normLen 150–300
Forex: normLen 100–200
Equities: normLen 100–250




Inputs Summary
InputDefaultDescriptionRSI Length14RSI calculation periodMA Length14EMA applied to RSI for gap measurementArea Lookback100Window for accumulating bull/bear areaScore MA Length21EMA of the normalized score for the chart panelNormalization Lookback200Rolling window for min/max normalizationTF 1–415m/1H/4H/DFour independent timeframes for the dashboard

Originality
This script is an original work combining RSI-EMA area integration, rolling normalization, and timeframe-independent multi-security computation into a unified momentum dashboard. While RSI divergence and multi-timeframe analysis are well-established concepts, the specific implementation — measuring the signed cumulative area between RSI and its EMA, normalizing it dynamically using a rolling historical range, computing trend duration in native timeframe bars via request.security(), and weighting a four-timeframe bias into a single overall score — represents the author's own methodology for transforming RSI from a single oscillator into a quantified, cross-timeframe momentum scoring system.

Disclaimer
This indicator is intended for educational and analytical purposes only. No indicator can predict future price movements with certainty. Always combine multiple forms of analysis and apply proper risk management before making any trading decisions.

Short Description :
Measures the cumulative area between RSI and its EMA across four independent timeframes, normalizes each score to −100/+100, and displays direction, strength, and trend duration in a persistent dashboard table. All timeframe calculations run natively in their own bars, ensuring consistent readings regardless of the chart timeframe.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('RSI Area Bias - Multi-Timeframe Dashboard', overlay = false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiLen = input.int(14, 'RSI Length', minval = 1)
maLen = input.int(14, 'MA Length', minval = 1)
lookback = input.int(100, 'Area Lookback', minval = 10)
scoreMALen = input.int(21, 'Score MA Length', minval = 1)
normLen = input.int(200, 'Normalization Lookback', minval = 50)

tf1 = input.timeframe('15', 'TF 1')
tf2 = input.timeframe('60', 'TF 2')
tf3 = input.timeframe('240', 'TF 3')
tf4 = input.timeframe('D', 'TF 4')

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Master function — tümü kendi TF'inde hesaplanır
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_all() =>
    // Area score
    rsiVal = ta.rsi(close, rsiLen)
    rsiMA = ta.ema(rsiVal, maLen)
    gap = rsiVal - rsiMA
    bullArea = ta.sma(math.max(gap, 0.0), lookback) * lookback
    bearArea = ta.sma(math.max(-gap, 0.0), lookback) * lookback
    raw = bullArea - bearArea

    // Normalize -100 / +100
    hi = ta.highest(raw, normLen)
    lo = ta.lowest(raw, normLen)
    denom = hi - lo
    score = denom == 0 ? 0.0 : (raw - lo) / denom * 200.0 - 100.0

    // Trend duration — kendi TF barlarıyla sayılır
    isBull = score > 0
    bars = 0
    for i = 1 to 499 by 1
        if score[i] > 0 != isBull
            break
        bars := i
        bars

    [score, bars]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// request.security — her TF kendi barlarında
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[score1, bars1] = request.security(syminfo.tickerid, tf1, f_all())
[score2, bars2] = request.security(syminfo.tickerid, tf2, f_all())
[score3, bars3] = request.security(syminfo.tickerid, tf3, f_all())
[score4, bars4] = request.security(syminfo.tickerid, tf4, f_all())

overallScore = (score1 * 1 + score2 * 2 + score3 * 3 + score4 * 4) / 10.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Classification Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_strength(score) =>
    absScore = math.abs(score)
    absScore >= 75 ? 'VERY STRONG' : absScore >= 50 ? 'STRONG' : absScore >= 25 ? 'MEDIUM' : absScore >= 10 ? 'WEAK' : 'NEUTRAL'

f_direction(score) =>
    score > 0 ? 'BULL' : score < 0 ? 'BEAR' : 'NEUTRAL'

f_bg(score) =>
    score > 0 ? color.new(color.green, 0) : score < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)

f_powerBg(score) =>
    absScore = math.abs(score)
    isBull = score > 0
    if isBull
        absScore >= 75 ? color.new(color.green, 0) : absScore >= 50 ? color.new(color.green, 25) : absScore >= 25 ? color.new(color.green, 50) : absScore >= 10 ? color.new(color.green, 70) : color.new(color.gray, 60)
    else
        absScore >= 75 ? color.new(color.red, 0) : absScore >= 50 ? color.new(color.red, 25) : absScore >= 25 ? color.new(color.red, 50) : absScore >= 10 ? color.new(color.red, 70) : color.new(color.gray, 60)

f_trendColor(bars) =>
    bars >= 100 ? color.new(color.yellow, 0) : bars >= 50 ? color.new(color.yellow, 30) : bars >= 20 ? color.new(color.white, 20) : color.new(color.white, 60)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table tbl = table.new(position.top_right, 5, 7, border_width = 1)

if barstate.islast
    hdrBg = color.new(color.gray, 20)

    table.cell(tbl, 0, 0, 'TF', bgcolor = hdrBg, text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 0, 'DIR', bgcolor = hdrBg, text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 2, 0, 'SCORE', bgcolor = hdrBg, text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 3, 0, 'POWER', bgcolor = hdrBg, text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 4, 0, 'BARS', bgcolor = hdrBg, text_color = color.white, text_size = size.tiny)

    scores = array.from(score1, score2, score3, score4)
    barsArr = array.from(float(bars1), float(bars2), float(bars3), float(bars4))
    tfNames = array.from(tf1, tf2, tf3, tf4)

    for i = 0 to 3 by 1
        s = array.get(scores, i)
        tb = int(array.get(barsArr, i))
        tfn = array.get(tfNames, i)
        row = i + 1

        table.cell(tbl, 0, row, tfn, text_color = color.white, text_size = size.tiny)
        table.cell(tbl, 1, row, f_direction(s), bgcolor = f_bg(s), text_color = color.white, text_size = size.tiny)
        table.cell(tbl, 2, row, str.tostring(s, '#.0'), bgcolor = f_powerBg(s), text_color = color.white, text_size = size.tiny)
        table.cell(tbl, 3, row, f_strength(s), bgcolor = f_powerBg(s), text_color = color.white, text_size = size.tiny)
        table.cell(tbl, 4, row, str.tostring(tb), bgcolor = f_trendColor(tb), text_color = color.black, text_size = size.tiny)

    // Overall row
    overallBg = color.new(color.navy, 10)
    overallBars = int((bars1 + bars2 + bars3 + bars4) / 4)
    table.cell(tbl, 0, 5, 'OVERALL', bgcolor = overallBg, text_color = color.yellow, text_size = size.tiny)
    table.cell(tbl, 1, 5, f_direction(overallScore), bgcolor = f_bg(overallScore), text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 2, 5, str.tostring(overallScore, '#.0'), bgcolor = f_powerBg(overallScore), text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 3, 5, f_strength(overallScore), bgcolor = f_powerBg(overallScore), text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 4, 5, str.tostring(overallBars), bgcolor = f_trendColor(overallBars), text_color = color.black, text_size = size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Current Chart Score Plot + Fill
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiVal = ta.rsi(close, rsiLen)
rsiMA = ta.ema(rsiVal, maLen)
gap = rsiVal - rsiMA
bullArea = ta.sma(math.max(gap, 0.0), lookback) * lookback
bearArea = ta.sma(math.max(-gap, 0.0), lookback) * lookback
rawCurrent = bullArea - bearArea
hiC = ta.highest(rawCurrent, normLen)
loC = ta.lowest(rawCurrent, normLen)
denomC = hiC - loC
currentScore = denomC == 0 ? 0.0 : (rawCurrent - loC) / denomC * 200.0 - 100.0
scoreMA = ta.ema(currentScore, scoreMALen)

pScore = plot(currentScore, title = 'RSI-MA Area Dominance (Normalized)', linewidth = 2, color = currentScore >= scoreMA ? color.lime : color.red)

pMA = plot(scoreMA, title = 'Score MA', linewidth = 1, color = color.yellow)

fill(pScore, pMA, color = currentScore >= scoreMA ? color.new(color.green, 70) : color.new(color.red, 70))

hline(0, 'Zero Line', color = color.gray, linestyle = hline.style_dotted)
hline(50, 'Strong Bull', color = color.new(color.green, 50), linestyle = hline.style_dotted)
hline(-50, 'Strong Bear', color = color.new(color.red, 50), linestyle = hline.style_dotted)
hline(75, 'Very Strong Bull', color = color.new(color.green, 20), linestyle = hline.style_dotted)
hline(-75, 'Very Strong Bear', color = color.new(color.red, 20), linestyle = hline.style_dotted)
````
