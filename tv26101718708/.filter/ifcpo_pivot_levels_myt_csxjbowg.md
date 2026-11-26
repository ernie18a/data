# iFCPO Pivot Levels MYT

- url: https://www.tradingview.com/script/cSxjbOwg-iFCPO-Pivot-Levels-MYT/
- type: indicator
- pine_id: PUB;8f03b0b77e1b4b7fab9ae355071dc2b4
- version: 2.0

## Description

iFCPO Pivot Levels MYT — Daily floor pivots reset on Bursa session boundary.

Levels: PP, R1-R3, S1-S3 plus optional Camarilla H1-H4/L1-L4.

Uses prior trading day's H/L/C in MYT (Asia/Kuala_Lumpur). Auto-skips holiday data via TV's daily candle resolution. Right-edge labels with rounded values.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Pivot Levels MYT — Daily floor pivots reset on Bursa session boundary
// Tier: FREE | Category: Support & Resistance
// Levels: PP, R1–R3, S1–S3, plus optional Camarilla H/L
// FCPO twist: pivots use prior trading day's H/L/C in MYT; auto-skips holiday data
indicator("iFCPO Pivot Levels MYT", "iFCPO Pvts", overlay = true)

// ── Inputs ──
show_pp        = input.bool(true,  "Show PP",          group = "Floor Pivots")
show_r1_s1     = input.bool(true,  "Show R1/S1",       group = "Floor Pivots")
show_r2_s2     = input.bool(true,  "Show R2/S2",       group = "Floor Pivots")
show_r3_s3     = input.bool(false, "Show R3/S3",       group = "Floor Pivots")
show_camarilla = input.bool(false, "Show Camarilla H1–H4 / L1–L4", group = "Camarilla")
show_labels    = input.bool(true,  "Print level labels on right edge", group = "Display")
extend_lines   = input.bool(true,  "Extend lines across day", group = "Display")

// Colors
pp_col   = input.color(#E0B544,        "PP color",         group = "Colors")
r_col    = input.color(#FF3B5C,        "R-side color",     group = "Colors")
s_col    = input.color(#1FC77E,        "S-side color",     group = "Colors")
cam_col  = input.color(color.new(#3B82F6, 30), "Camarilla", group = "Colors")

// ── Prior day H/L/C ──
// QA-2026-05-10: removed dead `TZ` var. For MYX:FCPO1!, TradingView's "D" resolution
// already aligns to the symbol's exchange session (Asia/Kuala_Lumpur), so daily bars
// are MYT-correct without an explicit TZ argument to request.security().
[dh, dl, dc] = request.security(syminfo.tickerid, "D",
   [high[1], low[1], close[1]],
   lookahead = barmerge.lookahead_off)

// Floor pivots
pp = (dh + dl + dc) / 3.0
r1 = 2 * pp - dl
s1 = 2 * pp - dh
r2 = pp + (dh - dl)
s2 = pp - (dh - dl)
r3 = dh + 2 * (pp - dl)
s3 = dl - 2 * (dh - pp)

// Camarilla (prefixed to avoid identifier reuse warnings)
range_d = dh - dl
camH4 = dc + range_d * 1.1 / 2.0
camH3 = dc + range_d * 1.1 / 4.0
camH2 = dc + range_d * 1.1 / 6.0
camH1 = dc + range_d * 1.1 / 12.0
camL1 = dc - range_d * 1.1 / 12.0
camL2 = dc - range_d * 1.1 / 6.0
camL3 = dc - range_d * 1.1 / 4.0
camL4 = dc - range_d * 1.1 / 2.0

// ── Plots ──
// Use plot() with show_last=1 if not extending; else continuous lines.
plot_style = extend_lines ? plot.style_line : plot.style_circles

plot(show_pp                ? pp : na, "PP",  color = pp_col, linewidth = 2, style = plot.style_line)
plot(show_r1_s1             ? r1 : na, "R1",  color = r_col,  linewidth = 1, style = plot_style)
plot(show_r1_s1             ? s1 : na, "S1",  color = s_col,  linewidth = 1, style = plot_style)
plot(show_r2_s2             ? r2 : na, "R2",  color = r_col,  linewidth = 1, style = plot_style)
plot(show_r2_s2             ? s2 : na, "S2",  color = s_col,  linewidth = 1, style = plot_style)
plot(show_r3_s3             ? r3 : na, "R3",  color = color.new(r_col, 50), linewidth = 1, style = plot_style)
plot(show_r3_s3             ? s3 : na, "S3",  color = color.new(s_col, 50), linewidth = 1, style = plot_style)

plot(show_camarilla         ? camH1 : na, "H1",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camH2 : na, "H2",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camH3 : na, "H3",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camH4 : na, "H4",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camL1 : na, "L1",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camL2 : na, "L2",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camL3 : na, "L3",  color = cam_col, linewidth = 1, style = plot_style)
plot(show_camarilla         ? camL4 : na, "L4",  color = cam_col, linewidth = 1, style = plot_style)

// ── Right-edge labels ──
if show_labels and barstate.islast
    label_offset = bar_index + 5
    if show_pp
        label.new(label_offset, pp, "PP " + str.tostring(pp, "#.##"),
           color = color.new(pp_col, 70), textcolor = pp_col, style = label.style_label_left, size = size.tiny)
    if show_r1_s1
        label.new(label_offset, r1, "R1 " + str.tostring(r1, "#.##"),
           color = color.new(r_col, 70), textcolor = r_col, style = label.style_label_left, size = size.tiny)
        label.new(label_offset, s1, "S1 " + str.tostring(s1, "#.##"),
           color = color.new(s_col, 70), textcolor = s_col, style = label.style_label_left, size = size.tiny)
    if show_r2_s2
        label.new(label_offset, r2, "R2 " + str.tostring(r2, "#.##"),
           color = color.new(r_col, 80), textcolor = r_col, style = label.style_label_left, size = size.tiny)
        label.new(label_offset, s2, "S2 " + str.tostring(s2, "#.##"),
           color = color.new(s_col, 80), textcolor = s_col, style = label.style_label_left, size = size.tiny)
    if show_r3_s3
        label.new(label_offset, r3, "R3 " + str.tostring(r3, "#.##"),
           color = color.new(r_col, 85), textcolor = color.new(r_col, 30), style = label.style_label_left, size = size.tiny)
        label.new(label_offset, s3, "S3 " + str.tostring(s3, "#.##"),
           color = color.new(s_col, 85), textcolor = color.new(s_col, 30), style = label.style_label_left, size = size.tiny)
````
