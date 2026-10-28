# TR / ATR / DATR Combined by Anupam Anand

- url: https://www.tradingview.com/script/ITRsddEe-TR-ATR-DATR-Combined-by-Anupam-Anand/
- type: indicator
- pine_id: PUB;f4f876addbed44e0aed4f80286238ff8
- version: 1.0

## Description

Here's the combined TR / ATR / DATR indicator, which is very useful for validating Zone Trading and Range Analysis at one single indicator, that will provide ease of use.

TR ( blue) — the raw True Range bar for each candle, so you can instantly see volatility spikes
ATR (solid amber line) — smoothed average over your chosen length (default 14) on the current chart timeframe

DATR (dashed coral line) — the Daily ATR, fetched from the D timeframe and overlaid on any chart — so even on a 5-minute chart, you always see where the daily ATR sits

The DATR line is especially useful on intraday charts — you can see at a glance whether the current move has already consumed most of the day's typical range.

This indicator is open to all.

## Source Code

````pine
// ============================================================
//  TR / ATR / DATR  —  Combined Indicator (all lines)
//  Displays True Range, ATR, and Daily ATR as lines
//  on a single sub-panel.
// ============================================================
//@version=5
indicator(title = "TR / ATR / DATR Combined by Anupam Anand", shorttitle = "TR+ATR+DATR",
     overlay = false, precision = 5)

// ── Inputs ──────────────────────────────────────────────────
atrLen  = input.int(14,  title = "ATR Length",         minval = 1, group = "ATR")
datrLen = input.int(14,  title = "DATR Length (days)",  minval = 1, group = "DATR")

atrMa  = input.string("RMA", title = "ATR MA Type",
     options = ["RMA","EMA","SMA","WMA"], group = "ATR")
datrMa = input.string("RMA", title = "DATR MA Type",
     options = ["RMA","EMA","SMA","WMA"], group = "DATR")

// Appearance
showTR    = input.bool(true, title = "Show TR Line",    group = "Display")
showATR   = input.bool(true, title = "Show ATR Line",   group = "Display")
showDATR  = input.bool(true, title = "Show DATR Line",  group = "Display")
showTable = input.bool(true, title = "Show Values Table", group = "Display")

trColor   = input.color(color.new(#378ADD, 0), title = "TR Color",   group = "Colors")
atrColor  = input.color(color.new(#EF9F27, 0), title = "ATR Color",  group = "Colors")
datrColor = input.color(color.new(#D85A30, 0), title = "DATR Color", group = "Colors")

tablePos  = input.string("Bottom Right", title = "Table Position",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"],
     group = "Display")

// ── Helper: flexible MA ──────────────────────────────────────
ma(src, len, typ) =>
    switch typ
        "EMA"  => ta.ema(src, len)
        "SMA"  => ta.sma(src, len)
        "WMA"  => ta.wma(src, len)
        =>        ta.rma(src, len)

// ── True Range ───────────────────────────────────────────────
tr = ta.tr(true)

// ── ATR ──────────────────────────────────────────────────────
atr = ma(tr, atrLen, atrMa)

// ── DATR ─────────────────────────────────────────────────────
dailyTR = request.security(syminfo.tickerid, "D", ta.tr(true),
     lookahead = barmerge.lookahead_off)
datr = ma(dailyTR, datrLen, datrMa)

// ── Plots  (all lines) ───────────────────────────────────────
plot(showTR   ? tr   : na,
     title     = "TR",
     color     = trColor,
     linewidth  = 1,
     style     = plot.style_line)

plot(showATR  ? atr  : na,
     title     = "ATR",
     color     = atrColor,
     linewidth  = 2,
     style     = plot.style_line)

plot(showDATR ? datr : na,
     title     = "DATR",
     color     = datrColor,
     linewidth  = 2,
     style     = plot.style_line)

// Zero baseline
hline(0, color = color.new(color.gray, 80), linestyle = hline.style_dotted)

// ── Values table ─────────────────────────────────────────────
if showTable and barstate.islast
    pos = switch tablePos
        "Top Right"   => position.top_right
        "Top Left"    => position.top_left
        "Bottom Left" => position.bottom_left
        =>               position.bottom_right

    tbl = table.new(pos, columns = 2, rows = 4,
         bgcolor      = color.new(color.black, 75),
         border_color = color.new(color.gray, 60),
         border_width = 1,
         frame_color  = color.new(color.gray, 50),
         frame_width  = 1)

    table.cell(tbl, 0, 0, "Indicator", text_color = color.new(color.white, 20),
         text_size = size.small, bgcolor = color.new(color.gray, 70))
    table.cell(tbl, 1, 0, "Value",     text_color = color.new(color.white, 20),
         text_size = size.small, bgcolor = color.new(color.gray, 70))

    table.cell(tbl, 0, 1, "TR",
         text_color = trColor,   text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(tr,   format.mintick),
         text_color = color.white, text_size = size.small)

    table.cell(tbl, 0, 2, "ATR (" + str.tostring(atrLen) + ")",
         text_color = atrColor,  text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(atr,  format.mintick),
         text_color = color.white, text_size = size.small)

    table.cell(tbl, 0, 3, "DATR (" + str.tostring(datrLen) + "D)",
         text_color = datrColor, text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(datr, format.mintick),
         text_color = color.white, text_size = size.small)
````
