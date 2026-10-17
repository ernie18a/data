# BTC Power Law + SD Bands

- url: https://www.tradingview.com/script/TxTU74tD-BTC-Power-Law-SD-Bands/
- type: indicator
- pine_id: PUB;11db251c585943e0a0a9fd3737f3208e
- version: 1.0

## Description

Bitcoin Power Law indicator + SD Bands.

The Bitcoin Power Law Theory suggests Bitcoin’s price growth is not random or merely exponential, but follows a predictable, long-term mathematical power law relative to time.

## Source Code

````pine
//@version=6
indicator(title = 'BTC Power Law + SD Bands', shorttitle = 'BTC Power Law', overlay = true, max_bars_back = 5000)

// ─────────────────────────────────────────────────────────────────────────────
// BTC POWER LAW CORRIDOR  (Harold Christopher Burger / PlanB methodology)
//
// The Bitcoin Power Law describes price as a function of days since genesis:
//   log10(Price) = A * log10(Days) + B
//
// Where:
//   A ≈ 5.82  (slope)
//   B ≈ -17.0 (intercept)
//
// Genesis block date: January 3, 2009
//
// Standard Deviation bands are computed in log10 space, symmetric around
// the regression line, at ±1, ±2, and ±3 sigma.
// ─────────────────────────────────────────────────────────────────────────────

// ── User Inputs ───────────────────────────────────────────────────────────────
grp_model = 'Power Law Model Parameters'
slope = input.float(5.82, title = 'Slope (A)', group = grp_model, step = 0.01, tooltip = 'Log-log regression slope. Default: 5.82')
intercept = input.float(-17.01, title = 'Intercept (B)', group = grp_model, step = 0.01, tooltip = 'Log-log regression intercept. Default: -17.01')
sigma = input.float(0.46, title = '1σ Width (log10 units)', group = grp_model, step = 0.01, tooltip = 'Standard deviation of residuals in log10 space. ~0.45-0.47 historically.')

grp_disp = 'Display'
show1sd = input.bool(true, title = 'Show ±1σ Bands', group = grp_disp)
show2sd = input.bool(true, title = 'Show ±2σ Bands', group = grp_disp)
show3sd = input.bool(true, title = 'Show ±3σ Bands', group = grp_disp)
showMid = input.bool(true, title = 'Show Fair Value Line', group = grp_disp)
showFill = input.bool(true, title = 'Fill Bands', group = grp_disp)
fillAlpha = input.int(12, title = 'Fill Opacity (0-100)', group = grp_disp, minval = 0, maxval = 100)

// ── Genesis Block Timestamp ───────────────────────────────────────────────────
// January 3, 2009 00:00:00 UTC  → Unix timestamp
genesis_ts = 1230940800000 // milliseconds

// ── Power Law Calculation ─────────────────────────────────────────────────────
// Days elapsed since genesis (using bar's open time)
days_elapsed = (time - genesis_ts) / 86400000.0

// Guard: only compute for bars after genesis
valid = days_elapsed > 0

// Fair value in log10 space
log10_fv = slope * math.log10(days_elapsed) + intercept

// Convert from log10 to price
fv = valid ? math.pow(10.0, log10_fv) : na
fv_1up = valid ? math.pow(10.0, log10_fv + 1 * sigma) : na
fv_1dn = valid ? math.pow(10.0, log10_fv - 1 * sigma) : na
fv_2up = valid ? math.pow(10.0, log10_fv + 2 * sigma) : na
fv_2dn = valid ? math.pow(10.0, log10_fv - 2 * sigma) : na
fv_3up = valid ? math.pow(10.0, log10_fv + 3 * sigma) : na
fv_3dn = valid ? math.pow(10.0, log10_fv - 3 * sigma) : na

// ── Colors ────────────────────────────────────────────────────────────────────
col_mid = color.new(color.white, 0)
col_1sd = color.new(#00c853, 0) // green
col_2sd = color.new(#ffab00, 0) // amber
col_3sd = color.new(#f44336, 0) // red
col_3dn = color.new(#2196f3, 0) // blue (oversold)
col_2dn = color.new(#40c4ff, 0) // light blue
col_1dn = color.new(#80deea, 0) // cyan

alpha = 100 - fillAlpha // plot.style fill uses 0=opaque

// ── Plots ─────────────────────────────────────────────────────────────────────
p_fv = plot(showMid ? fv : na, title = 'Fair Value', color = col_mid, linewidth = 2, style = plot.style_line)

p_1up = plot(show1sd ? fv_1up : na, title = '+1σ', color = col_1sd, linewidth = 1)
p_1dn = plot(show1sd ? fv_1dn : na, title = '-1σ', color = col_1dn, linewidth = 1)

p_2up = plot(show2sd ? fv_2up : na, title = '+2σ', color = col_2sd, linewidth = 1)
p_2dn = plot(show2sd ? fv_2dn : na, title = '-2σ', color = col_2dn, linewidth = 1)

p_3up = plot(show3sd ? fv_3up : na, title = '+3σ', color = col_3sd, linewidth = 1)
p_3dn = plot(show3sd ? fv_3dn : na, title = '-3σ', color = col_3dn, linewidth = 1)

// ── Band Fills ────────────────────────────────────────────────────────────────
// fill() must be at global scope — visibility controlled via fully transparent color
fill(p_fv, p_1up, color = showFill ? color.new(col_1sd, alpha) : color.new(col_1sd, 100), title = 'Fill 0 to +1σ')
fill(p_fv, p_1dn, color = showFill ? color.new(col_1dn, alpha) : color.new(col_1dn, 100), title = 'Fill 0 to -1σ')
fill(p_1up, p_2up, color = showFill ? color.new(col_2sd, alpha) : color.new(col_2sd, 100), title = 'Fill +1σ to +2σ')
fill(p_1dn, p_2dn, color = showFill ? color.new(col_2dn, alpha) : color.new(col_2dn, 100), title = 'Fill -1σ to -2σ')
fill(p_2up, p_3up, color = showFill ? color.new(col_3sd, alpha) : color.new(col_3sd, 100), title = 'Fill +2σ to +3σ')
fill(p_2dn, p_3dn, color = showFill ? color.new(col_3dn, alpha) : color.new(col_3dn, 100), title = 'Fill -2σ to -3σ')

// ── Labels (right-edge price labels via line/label on last bar) ───────────────
if barstate.islast and showMid and valid
    label.new(bar_index, fv, text = '⬦ Fair Value: $' + str.tostring(math.round(fv), '#,###'), color = color.new(color.white, 80), textcolor = color.white, style = label.style_label_left, size = size.small)

if barstate.islast and show3sd and valid
    label.new(bar_index, fv_3up, text = '+3σ  $' + str.tostring(math.round(fv_3up), '#,###'), color = color.new(col_3sd, 80), textcolor = col_3sd, style = label.style_label_left, size = size.small)
    label.new(bar_index, fv_3dn, text = '-3σ  $' + str.tostring(math.round(fv_3dn), '#,###'), color = color.new(col_3dn, 80), textcolor = col_3dn, style = label.style_label_left, size = size.small)

if barstate.islast and show2sd and valid
    label.new(bar_index, fv_2up, text = '+2σ  $' + str.tostring(math.round(fv_2up), '#,###'), color = color.new(col_2sd, 80), textcolor = col_2sd, style = label.style_label_left, size = size.small)
    label.new(bar_index, fv_2dn, text = '-2σ  $' + str.tostring(math.round(fv_2dn), '#,###'), color = color.new(col_2dn, 80), textcolor = col_2dn, style = label.style_label_left, size = size.small)

if barstate.islast and show1sd and valid
    label.new(bar_index, fv_1up, text = '+1σ  $' + str.tostring(math.round(fv_1up), '#,###'), color = color.new(col_1sd, 80), textcolor = col_1sd, style = label.style_label_left, size = size.small)
    label.new(bar_index, fv_1dn, text = '-1σ  $' + str.tostring(math.round(fv_1dn), '#,###'), color = color.new(col_1dn, 80), textcolor = col_1dn, style = label.style_label_left, size = size.small)

// ── Background Coloring: highlight when price is extreme ─────────────────────
// Colors the background red when price > +2σ, blue when price < -2σ
above2 = valid and close > fv_2up
below2 = valid and close < fv_2dn

bgcolor(above2 ? color.new(color.red, 90) : na, title = 'Overbought Zone (>+2σ)')
bgcolor(below2 ? color.new(color.blue, 90) : na, title = 'Oversold Zone (<-2σ)')

// ── Info Table ────────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 7, border_width = 1, border_color = color.new(color.gray, 60), frame_color = color.new(color.gray, 40), frame_width = 1, bgcolor = color.new(color.black, 70))

if barstate.islast and valid
    // Header
    table.cell(tbl, 0, 0, 'BTC Power Law', text_color = color.white, bgcolor = color.new(color.gray, 50), text_size = size.small, text_halign = text.align_center)
    table.cell(tbl, 1, 0, 'Price (USD)', text_color = color.white, bgcolor = color.new(color.gray, 50), text_size = size.small, text_halign = text.align_center)

    // Current price
    table.cell(tbl, 0, 1, 'Current Price', text_color = color.silver, text_size = size.small)
    table.cell(tbl, 1, 1, '$' + str.tostring(math.round(close), '#,###'), text_color = color.yellow, text_size = size.small, text_halign = text.align_right)

    // Fair value
    table.cell(tbl, 0, 2, 'Fair Value (0σ)', text_color = color.silver, text_size = size.small)
    table.cell(tbl, 1, 2, '$' + str.tostring(math.round(fv), '#,###'), text_color = color.white, text_size = size.small, text_halign = text.align_right)

    // Premium/Discount
    prem = (math.log10(close) - log10_fv) / sigma
    prem_col = prem > 2 ? color.red : prem < -2 ? color.aqua : prem > 0 ? color.orange : color.green
    table.cell(tbl, 0, 3, 'Z-Score (σ)', text_color = color.silver, text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(prem, '#.##') + 'σ', text_color = prem_col, text_size = size.small, text_halign = text.align_right)

    // Days since genesis
    table.cell(tbl, 0, 4, 'Days Since Genesis', text_color = color.silver, text_size = size.small)
    table.cell(tbl, 1, 4, str.tostring(math.round(days_elapsed), '#,###'), text_color = color.white, text_size = size.small, text_halign = text.align_right)

    // Model params
    table.cell(tbl, 0, 5, 'Slope / Intercept', text_color = color.silver, text_size = size.small)
    table.cell(tbl, 1, 5, str.tostring(slope) + ' / ' + str.tostring(intercept), text_color = color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(tbl, 0, 6, '1σ Width (log10)', text_color = color.silver, text_size = size.small)
    table.cell(tbl, 1, 6, str.tostring(sigma), text_color = color.white, text_size = size.small, text_halign = text.align_right)
````
