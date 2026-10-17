# Dual Valuation Bands (P/E & P/B) with Z-Score Analysis

- url: https://www.tradingview.com/script/1wU17QL0/
- type: indicator
- pine_id: PUB;b34553c3e3794544a6c3dcd8177684b2
- version: 1.0

## Description

# P/E + P/B Valuation Bands with ±2 Standard Deviation

A dual fundamental valuation indicator that applies statistical Standard Deviation bands to both P/E and P/B ratios, helping investors identify mean-reversion opportunities and extreme valuation zones.

## 📊 What It Does

This indicator calculates rolling Mean and Standard Deviation for both P/E and P/B ratios over a customizable lookback period (default: 252 bars = 1 trading year). It then plots ±1 SD and ±2 SD bands around the mean, providing a statistical framework for identifying:

- **Overvalued zones** (above +2 SD): Statistically expensive — top 2.5% of historical valuations
- **Undervalued zones** (below -2 SD): Statistically cheap — bottom 2.5% of historical valuations
- **Normal range** (within ±1 SD): Where the ratio trades 68% of the time

## ✨ Key Features

### 1. Dual Indicator Display
Plots both P/E and P/B ratios on the same chart, allowing direct comparison and dual-confirmation signals.

### 2. Z-Score Normalization Mode
Toggle between two display modes:
- **Normalized (Z-Score)**: Both ratios plotted on the same scale (number of SDs from mean) — ideal for direct comparison
- **Absolute Values**: Original ratio values with separate SD bands for each — ideal for precise level analysis

### 3. Outlier Filtering
Automatically filters extreme P/E values (negative earnings, P/E > 100) that would distort the standard deviation calculation. Common in cyclical companies during loss periods.

### 4. Dynamic Length Adjustment
Indicator works correctly even with limited historical data by automatically adjusting the calculation window during the warm-up period.

### 5. Dual Confirmation Signals
Background highlights appear only when **both** P/E and P/B simultaneously reach extreme zones (±2 SD), filtering out single-indicator false signals.

### 6. Comprehensive Info Table
Real-time display of:
- Current P/E and P/B values
- Z-Score (number of SDs from mean)
- Valuation status (Very Expensive / Expensive / Average / Cheap / Very Cheap)
- Combined signal summary

## ⚙️ How to Use

### Setup
1. Add a P/E ratio indicator to your chart
2. Add a P/B ratio indicator to your chart
3. Add this "P/E + P/B Valuation Bands" indicator
4. In Settings → Inputs:
   - Set "P/E Source" to the P/E ratio output
   - Set "P/B Source" to the P/B ratio output

### Recommended Settings by Stock Type

| Stock Type | Length | Notes |
|------------|--------|-------|
| Stable (banks, utilities) | 252–504 | 1–2 years |
| Cyclical (real estate, steel, oil) | 504–1260 | 2–5 years (full cycle) |
| Growth (tech) | 252 | Valuation changes quickly |
| Newly listed | 60–120 | Limited history |

## 🎯 Trading Signals

| P/E | P/B | Signal | Action |
|-----|-----|--------|--------|
| < -2 SD | < -2 SD | **Extremely Cheap (Dual Confirmation)** | Strong accumulation zone |
| < -1 SD | < -1 SD | Cheap | Consider buying |
| Within ±1 SD | Within ±1 SD | Average | Hold / Observe |
| > +1 SD | > +1 SD | Expensive | Consider taking profits |
| > +2 SD | > +2 SD | **Extremely Expensive (Dual Confirmation)** | Strong profit-taking zone |
| Divergent | Divergent | Conflicting signal | Requires deeper analysis |

## 🔍 Interpreting Divergence

When P/E and P/B give conflicting signals:

- **Low P/E + High P/B**: Recent earnings spike not yet reflected in book value growth — verify earnings sustainability
- **High P/E + Low P/B**: Temporary earnings decline but stable assets — potential opportunity if earnings recover

The most reliable signals occur when **both P/E and P/B simultaneously confirm** (background highlights).

## ⚠️ Important Notes

1. **Statistical bands ≠ guaranteed reversal**: A stock can stay overvalued/undervalued for extended periods. Use with other analysis.

2. **Length matters for cyclical stocks**: For commodity, real estate, or banking stocks, use longer lookback periods (504–1260 bars) to capture a full economic cycle.

3. **Outlier filter is critical for P/E**: Without filtering, a single quarter of near-zero earnings can spike P/E to 1000+ and distort the SD calculation for years.

4. **Not a standalone strategy**: This is a fundamental valuation tool. Combine with technical analysis, business fundamentals, and macroeconomic context.

5. **Warm-up period**: The first N bars (where N = length) will not display SD bands due to insufficient data for statistical calculation.

## 📈 Methodology

The indicator applies the empirical rule (68-95-99.7 rule) of normal distribution to fundamental ratios:
- ~68% of values fall within ±1 SD of the mean
- ~95% of values fall within ±2 SD of the mean
- ~99.7% of values fall within ±3 SD of the mean

When a ratio reaches ±2 SD, it represents a statistically significant deviation from its historical norm — a potential mean-reversion opportunity if the underlying business fundamentals remain intact.

## 🛠️ Inputs

- **Length**: SD calculation period (default 252)
- **P/E Source**: Source for P/E ratio data
- **P/B Source**: Source for P/B ratio data
- **Show P/E**: Toggle P/E display
- **Show P/B**: Toggle P/B display
- **Z-Score Normalization**: Plot both ratios on the same scale
- **P/E Outlier Filter**: Filter P/E values outside (0, 100) range

## 🔔 Alerts Available

- Both P/E and P/B above +2 SD (extremely overvalued)
- Both P/E and P/B below -2 SD (extremely undervalued)

---
[image]https://www.tradingview.com/x/nHnxRqlx/[/image]

**Disclaimer**: This indicator is for educational and analytical purposes only. It does not constitute investment advice. Past valuation patterns do not guarantee future performance. Always conduct your own research and consult with a qualified financial advisor before making investment decisions.

## Source Code

````pine
//@version=5
indicator("P/E + P/B Valuation Bands (±2 SD)", overlay=false)

// === INPUT ===
length = input.int(252, "SD Calculation Period", minval=20, group="General Settings")

// Data sources
pe_src = input.source(close, "P/E Source", group="Data Sources")
pb_src = input.source(close, "P/B Source", group="Data Sources")

// Display options
show_pe   = input.bool(true,  "Show P/E", group="Display")
show_pb   = input.bool(true,  "Show P/B", group="Display")
normalize = input.bool(true,  "Normalize to Z-Score (direct comparison)", group="Display", tooltip="Enable to plot both ratios on the same scale (number of SDs from mean)")
filter_pe = input.bool(true,  "Filter P/E outliers (0 < P/E < 100)", group="Data Filtering")

// === FILTER OUTLIERS FOR P/E ===
pe_clean = filter_pe ? ((pe_src > 0 and pe_src < 100) ? pe_src : na) : pe_src
pb_clean = pb_src

// === DYNAMIC LENGTH ===
actual_length = math.min(length, bar_index + 1)

// === CALCULATE MEAN & SD ===
pe_mean = ta.sma(pe_clean, actual_length)
pe_sd   = ta.stdev(pe_clean, actual_length)
pb_mean = ta.sma(pb_clean, actual_length)
pb_sd   = ta.stdev(pb_clean, actual_length)

// === Z-SCORE (number of SDs from mean) ===
pe_zscore = (pe_clean - pe_mean) / pe_sd
pb_zscore = (pb_clean - pb_mean) / pb_sd

// === DISPLAY VALUES ===
pe_plot = normalize ? pe_zscore : pe_clean
pb_plot = normalize ? pb_zscore : pb_clean

pe_upper2 = normalize ?  2 : pe_mean + 2 * pe_sd
pe_lower2 = normalize ? -2 : pe_mean - 2 * pe_sd
pe_mid    = normalize ?  0 : pe_mean

pb_upper2 = normalize ?  2 : pb_mean + 2 * pb_sd
pb_lower2 = normalize ? -2 : pb_mean - 2 * pb_sd
pb_mid    = normalize ?  0 : pb_mean

// === PLOTS ===
// P/E - blue
plot(show_pe ? pe_plot : na, "P/E",      color=color.new(color.blue, 0),  linewidth=2)
plot(show_pe ? pe_mid  : na, "P/E Mean", color=color.new(color.blue, 60), style=plot.style_line)
plot(show_pe and not normalize ? pe_upper2 : na, "P/E +2SD", color=color.new(color.blue, 40), style=plot.style_circles)
plot(show_pe and not normalize ? pe_lower2 : na, "P/E -2SD", color=color.new(color.blue, 40), style=plot.style_circles)

// P/B - orange
plot(show_pb ? pb_plot : na, "P/B",      color=color.new(color.orange, 0),  linewidth=2)
plot(show_pb ? pb_mid  : na, "P/B Mean", color=color.new(color.orange, 60), style=plot.style_line)
plot(show_pb and not normalize ? pb_upper2 : na, "P/B +2SD", color=color.new(color.orange, 40), style=plot.style_circles)
plot(show_pb and not normalize ? pb_lower2 : na, "P/B -2SD", color=color.new(color.orange, 40), style=plot.style_circles)

// === REFERENCE LINES (only when normalized) ===
hline_up2  = hline(normalize ?  2 : na, "+2 SD", color=color.red,    linestyle=hline.style_dashed)
hline_up1  = hline(normalize ?  1 : na, "+1 SD", color=color.new(color.red, 70))
hline_zero = hline(normalize ?  0 : na, "Mean",  color=color.gray)
hline_low1 = hline(normalize ? -1 : na, "-1 SD", color=color.new(color.green, 70))
hline_low2 = hline(normalize ? -2 : na, "-2 SD", color=color.green,  linestyle=hline.style_dashed)

fill(hline_up2, hline_low2, color=normalize ? color.new(color.gray, 95) : na, title="±2 SD Zone")

// === BACKGROUND: dual confirmation signals ===
both_overvalued  = (pe_zscore >  2) and (pb_zscore >  2)
both_undervalued = (pe_zscore < -2) and (pb_zscore < -2)
bgcolor(both_overvalued  ? color.new(color.red,   80) : na, title="Both Ratios Overvalued")
bgcolor(both_undervalued ? color.new(color.green, 80) : na, title="Both Ratios Undervalued")

// === COMPARISON TABLE ===
var table info = table.new(position.top_right, 4, 6, border_width=1)
if barstate.islast
    // Header
    table.cell(info, 0, 0, "Metric",   bgcolor=color.gray, text_color=color.white)
    table.cell(info, 1, 0, "Current",  bgcolor=color.gray, text_color=color.white)
    table.cell(info, 2, 0, "Z-Score",  bgcolor=color.gray, text_color=color.white)
    table.cell(info, 3, 0, "Status",   bgcolor=color.gray, text_color=color.white)
    
    // P/E row
    pe_status = pe_zscore >  2 ? "Very Expensive" : pe_zscore >  1 ? "Expensive" : pe_zscore < -2 ? "Very Cheap" : pe_zscore < -1 ? "Cheap" : "Average"
    pe_color  = pe_zscore >  2 ? color.red : pe_zscore < -2 ? color.green : color.gray
    table.cell(info, 0, 1, "P/E", text_color=color.blue)
    table.cell(info, 1, 1, str.tostring(pe_clean, "#.##"))
    table.cell(info, 2, 1, str.tostring(pe_zscore, "#.##"), text_color=pe_color)
    table.cell(info, 3, 1, pe_status, text_color=pe_color)
    
    // P/E Mean & SD
    table.cell(info, 0, 2, "  Mean / SD", text_color=color.new(color.blue, 40))
    table.cell(info, 1, 2, str.tostring(pe_mean, "#.##") + " / " + str.tostring(pe_sd, "#.##"))
    table.cell(info, 2, 2, "")
    table.cell(info, 3, 2, "")
    
    // P/B row
    pb_status = pb_zscore >  2 ? "Very Expensive" : pb_zscore >  1 ? "Expensive" : pb_zscore < -2 ? "Very Cheap" : pb_zscore < -1 ? "Cheap" : "Average"
    pb_color  = pb_zscore >  2 ? color.red : pb_zscore < -2 ? color.green : color.gray
    table.cell(info, 0, 3, "P/B", text_color=color.orange)
    table.cell(info, 1, 3, str.tostring(pb_clean, "#.##"))
    table.cell(info, 2, 3, str.tostring(pb_zscore, "#.##"), text_color=pb_color)
    table.cell(info, 3, 3, pb_status, text_color=pb_color)
    
    // P/B Mean & SD
    table.cell(info, 0, 4, "  Mean / SD", text_color=color.new(color.orange, 40))
    table.cell(info, 1, 4, str.tostring(pb_mean, "#.##") + " / " + str.tostring(pb_sd, "#.##"))
    table.cell(info, 2, 4, "")
    table.cell(info, 3, 4, "")
    
    // Combined signal
    combined = both_overvalued ? "BOTH OVERVALUED" : both_undervalued ? "BOTH UNDERVALUED" : "Divergent"
    cb_color = both_overvalued ? color.red : both_undervalued ? color.green : color.gray
    table.cell(info, 0, 5, "Summary", bgcolor=color.new(color.black, 80), text_color=color.white)
    table.cell(info, 1, 5, combined, bgcolor=color.new(cb_color, 70), text_color=color.white)
    table.cell(info, 2, 5, "", bgcolor=color.new(color.black, 80))
    table.cell(info, 3, 5, "", bgcolor=color.new(color.black, 80))

// === ALERTS ===
alertcondition(both_overvalued,  "Both P/E and P/B above +2SD", "Extreme overvaluation - both P/E and P/B exceed +2 SD")
alertcondition(both_undervalued, "Both P/E and P/B below -2SD", "Extreme undervaluation - both P/E and P/B fall below -2 SD")
alertcondition(ta.crossover(pe_zscore,  2), "P/E crosses above +2SD", "P/E ratio crossed above +2 SD - overvalued")
alertcondition(ta.crossunder(pe_zscore, -2), "P/E crosses below -2SD", "P/E ratio crossed below -2 SD - undervalued")
alertcondition(ta.crossover(pb_zscore,  2), "P/B crosses above +2SD", "P/B ratio crossed above +2 SD - overvalued")
alertcondition(ta.crossunder(pb_zscore, -2), "P/B crosses below -2SD", "P/B ratio crossed below -2 SD - undervalued")
````
