# Session Close +-ATR(14)

- url: https://www.tradingview.com/script/sqZbulxW-Session-Close-ATR-14/
- type: indicator
- pine_id: PUB;1703434597544abbac1df446bff51911
- version: 1.0

## Description

This indicator plots three horizontal levels on the chart based on the current ticker:

• Solid line — the regular session closing price (09:30–16:00 ET, Mon–Fri)
• Dashed line above — Close + ATR(14, 1D)
• Dashed line below — Close − ATR(14, 1D)

Each level is labeled with the ticker symbol, the exact price, and the ATR value in brackets.

Customizable via the Inputs panel:
• ATR period (default: 14)
• Line width and label font size
• Separate colors for the Close line and the ±ATR lines

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YuriShirov

//@version=6
indicator("Session Close ±ATR(14)", overlay=true, max_lines_count=50, max_labels_count=20)

// ─── SETTINGS ─────────────────────────────────────────────────────────────────
atr_len   = input.int(14, "ATR Period", minval=1, group="ATR")
line_w    = input.int(2,  "Line Width", minval=1, maxval=4, group="Display")
lbl_size  = input.string(size.normal, "Font Size",
              options=[size.tiny, size.small, size.normal, size.large, size.huge],
              group="Display")
col_close = input.color(color.blue,                  "Color — Close", group="Colors")
col_atr   = input.color(color.new(color.orange, 20), "Color — ±ATR",  group="Colors")

// ─── 1D DATA ──────────────────────────────────────────────────────────────────
[d_close, d_atr] = request.security(
     syminfo.tickerid, "1D",
     [close, ta.atr(atr_len)],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on)

lvl_close = d_close
lvl_hi    = d_close + d_atr
lvl_lo    = d_close - d_atr

// ─── DRAW ON LAST BAR ─────────────────────────────────────────────────────────
if barstate.islast
    for ln in line.all
        line.delete(ln)
    for lb in label.all
        label.delete(lb)

    if not na(lvl_close) and not na(d_atr)
        // Lines
        line.new(bar_index - 1, lvl_close, bar_index, lvl_close,
             extend=extend.both, color=col_close,
             width=line_w, style=line.style_solid)

        line.new(bar_index - 1, lvl_hi, bar_index, lvl_hi,
             extend=extend.both, color=col_atr,
             width=line_w, style=line.style_dashed)

        line.new(bar_index - 1, lvl_lo, bar_index, lvl_lo,
             extend=extend.both, color=col_atr,
             width=line_w, style=line.style_dashed)

        // Labels
        label.new(bar_index, lvl_close,
             syminfo.ticker + "  Close: " + str.tostring(lvl_close, "#.##"),
             xloc=xloc.bar_index, yloc=yloc.price,
             color=color.new(col_close, 80), textcolor=col_close,
             style=label.style_label_lower_left, size=lbl_size)

        label.new(bar_index, lvl_hi,
             "+ATR(" + str.tostring(atr_len) + ")  " +
             str.tostring(lvl_hi, "#.##") + "  [+" + str.tostring(d_atr, "#.##") + "]",
             xloc=xloc.bar_index, yloc=yloc.price,
             color=color.new(col_atr, 80), textcolor=col_atr,
             style=label.style_label_lower_left, size=lbl_size)

        label.new(bar_index, lvl_lo,
             "-ATR(" + str.tostring(atr_len) + ")  " +
             str.tostring(lvl_lo, "#.##") + "  [-" + str.tostring(d_atr, "#.##") + "]",
             xloc=xloc.bar_index, yloc=yloc.price,
             color=color.new(col_atr, 80), textcolor=col_atr,
             style=label.style_label_lower_left, size=lbl_size)
````
