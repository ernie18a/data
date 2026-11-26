# iFCPO Key Levels Lite

- url: https://www.tradingview.com/script/6KA3JHlg-iFCPO-Key-Levels-Lite/
- type: indicator
- pine_id: PUB;57e81d4d6c2e4256b794d54a148d3952
- version: 2.0

## Description

iFCPO Key Levels Lite — prior day high/low, prior week high/low, prior settlement.

Plots:
- PDH (prior day high) — magnet/resistance
- PDL (prior day low) — magnet/support
- PWH/PWL (prior week high/low) — major levels
- Settlement (prior 16:30 close) — institutional reference

FCPO settlement is the daily 16:30 close. Right-edge labels with rounded values.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Key Levels Lite — PDH, PDL, PWH, PWL, prior 16:30 settlement
// Tier: FREE | Category: Support & Resistance
// QA-2026-05-10: settlement now actually computed from 16:30 MYT bar (was generic close[1])
indicator("iFCPO Key Levels Lite", "iFCPO Lvls", overlay = true)

show_pdh = input.bool(true, "Show PDH",  group = "Daily")
show_pdl = input.bool(true, "Show PDL",  group = "Daily")
show_pwh = input.bool(true, "Show PWH",  group = "Weekly")
show_pwl = input.bool(true, "Show PWL",  group = "Weekly")
show_set = input.bool(true, "Show prior 16:30 settlement", group = "Daily")

col_pdh = input.color(#FF3B5C, "PDH",  group = "Colors")
col_pdl = input.color(#1FC77E, "PDL",  group = "Colors")
col_pwh = input.color(color.new(#FF3B5C, 30), "PWH", group = "Colors")
col_pwl = input.color(color.new(#1FC77E, 30), "PWL", group = "Colors")
col_set = input.color(#E0B544, "Settlement", group = "Colors")

// Daily H/L for prior trading day
[pdh, pdl] = request.security(syminfo.tickerid, "D",
   [high[1], low[1]], lookahead = barmerge.lookahead_off)
// Weekly H/L for prior week
[pwh, pwl] = request.security(syminfo.tickerid, "W",
   [high[1], low[1]], lookahead = barmerge.lookahead_off)

// Bursa FCPO official settlement time = 16:30 MYT closing of T-day (per Bursa Malaysia Derivatives rules).
// On charts that include the 21:00-23:30 night session, daily close[1] is NOT the same as 16:30 settlement.
// Below: capture the close of the bar that contains 16:30 MYT, on M5 or finer charts.
TZ = "Asia/Kuala_Lumpur"
is_settlement_bar = hour(time, TZ) == 16 and minute(time, TZ) >= 25 and minute(time, TZ) < 30
var float captured_settle = na
var float prior_settle = na
if is_settlement_bar
    prior_settle := captured_settle
    captured_settle := close
// Fallback for higher-TF charts (M30+, where 16:25-16:30 might not align): use daily close[1]
fallback_close = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)
settle = na(prior_settle) ? fallback_close : prior_settle

plot(show_pdh ? pdh : na, "PDH", color = col_pdh, linewidth = 2, style = plot.style_line)
plot(show_pdl ? pdl : na, "PDL", color = col_pdl, linewidth = 2, style = plot.style_line)
plot(show_pwh ? pwh : na, "PWH", color = col_pwh, linewidth = 1, style = plot.style_circles)
plot(show_pwl ? pwl : na, "PWL", color = col_pwl, linewidth = 1, style = plot.style_circles)
plot(show_set ? settle : na, "Settle 16:30", color = col_set, linewidth = 1, style = plot.style_line)

if barstate.islast
    if show_pdh
        label.new(bar_index + 5, pdh, "PDH " + str.tostring(pdh, "#.##"),
           color = color.new(col_pdh, 80), textcolor = col_pdh, style = label.style_label_left, size = size.tiny)
    if show_pdl
        label.new(bar_index + 5, pdl, "PDL " + str.tostring(pdl, "#.##"),
           color = color.new(col_pdl, 80), textcolor = col_pdl, style = label.style_label_left, size = size.tiny)
    if show_pwh
        label.new(bar_index + 5, pwh, "PWH " + str.tostring(pwh, "#.##"),
           color = color.new(col_pwh, 80), textcolor = col_pwh, style = label.style_label_left, size = size.tiny)
    if show_pwl
        label.new(bar_index + 5, pwl, "PWL " + str.tostring(pwl, "#.##"),
           color = color.new(col_pwl, 80), textcolor = col_pwl, style = label.style_label_left, size = size.tiny)
    if show_set
        label.new(bar_index + 5, settle, "Settle " + str.tostring(settle, "#.##") + " (16:30)",
           color = color.new(col_set, 80), textcolor = col_set, style = label.style_label_left, size = size.tiny)
````
