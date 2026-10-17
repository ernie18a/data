# Footprint Sniper Entries [LuxGonAdn]

- url: https://www.tradingview.com/script/aSSICAps-Footprint-Sniper-Entries-LuxGonAdn/
- type: indicator
- pine_id: PUB;e09ce06569584d55adde3370609f26d1
- version: 1.0

## Description

Footprint for Sniper Entries , description comming.

## Source Code

````pine
//@version=6
indicator("Footprint Sniper Entries [LuxGonAdn]", overlay=true, max_labels_count=500, max_lines_count=300, max_boxes_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp_fp = "Footprint Settings"
ticksPerRow     = input.int(100,  "Ticks Per Row",          minval=1,   group=grp_fp)
vaPct           = input.int(70,   "Value Area %",           minval=1,   maxval=100, group=grp_fp)
imbalancePct    = input.int(300,  "Imbalance Threshold %",  minval=1,   group=grp_fp)
showPOC         = input.bool(true,"Show POC Line",          group=grp_fp)
showVA          = input.bool(true,"Show Value Area",        group=grp_fp)
showImbalances  = input.bool(true,"Show Imbalances",        group=grp_fp)

grp_entry = "Sniper Entry"
deltaMult   = input.float(1.5,  "Delta Strength Multiplier", minval=0.5, step=0.1, group=grp_entry)
deltaLen    = input.int(14,     "Delta Avg Length",          minval=1,   group=grp_entry)
useTrend    = input.bool(true,  "Filter by EMA Trend",       group=grp_entry)
emaLen      = input.int(50,     "EMA Length",                minval=1,   group=grp_entry)
useVAConf   = input.bool(true,  "Require Close in Value Area", group=grp_entry)
useImb      = input.bool(true,  "Require Imbalance on Signal Bar", group=grp_entry)
lblSize     = input.string("Normal", "Signal Label Size", options=["Tiny","Small","Normal","Large"], group=grp_entry)

grp_col = "Colors"
bullCol     = input.color(color.new(#00c853, 0),   "Bull / Buy",        group=grp_col)
bearCol     = input.color(color.new(#f44336, 0),   "Bear / Sell",       group=grp_col)
pocCol      = input.color(color.new(#ffeb3b, 0),   "POC Line",          group=grp_col)
vaCol       = input.color(color.new(#7e57c2, 70),  "Value Area Fill",   group=grp_col)
buyImbCol   = input.color(color.new(#00bcd4, 80),  "Buy Imbalance",     group=grp_col)
sellImbCol  = input.color(color.new(#ff9800, 80),  "Sell Imbalance",    group=grp_col)

// ─────────────────────────────────────────────
// REQUEST FOOTPRINT  (one call only — Pine limit)
// Requires TradingView Premium or Ultimate plan
// ─────────────────────────────────────────────
footprint fp = request.footprint(ticksPerRow, vaPct, imbalancePct)

// ─────────────────────────────────────────────
// EXTRACT FOOTPRINT DATA
// ─────────────────────────────────────────────
float buyVol    = not na(fp) ? fp.buy_volume()  : na
float sellVol   = not na(fp) ? fp.sell_volume() : na
float delta     = not na(fp) ? fp.delta()       : na

// Key rows
volume_row pocRow = not na(fp) ? fp.poc() : na
volume_row vahRow = not na(fp) ? fp.vah() : na
volume_row valRow = not na(fp) ? fp.val() : na

float pocHigh   = not na(pocRow) ? pocRow.up_price()   : na
float pocLow    = not na(pocRow) ? pocRow.down_price()  : na
float vahPrice  = not na(vahRow) ? vahRow.up_price()    : na
float valPrice  = not na(valRow) ? valRow.down_price()  : na

// ─────────────────────────────────────────────
// DELTA STRENGTH
// ─────────────────────────────────────────────
absDelta    = math.abs(nz(delta))
avgDelta    = ta.sma(absDelta, deltaLen)
strongBuy   = delta >  avgDelta * deltaMult
strongSell  = delta < -avgDelta * deltaMult

// ─────────────────────────────────────────────
// IMBALANCE CHECK ON SIGNAL BAR
// Scan all rows — flag if any buy/sell imbalance exists
// ─────────────────────────────────────────────
var bool hasBuyImb  = false
var bool hasSellImb = false
hasBuyImb  := false
hasSellImb := false

if not na(fp) and showImbalances
    array<volume_row> rows = fp.rows()
    for row in rows
        if row.has_buy_imbalance()
            hasBuyImb := true
        if row.has_sell_imbalance()
            hasSellImb := true

// ─────────────────────────────────────────────
// VALUE AREA CONFIRMATION
// Close must be within VAL–VAH range
// ─────────────────────────────────────────────
inValueArea = not na(vahPrice) and not na(valPrice) and close >= valPrice and close <= vahPrice

// ─────────────────────────────────────────────
// TREND FILTER
// ─────────────────────────────────────────────
ema = ta.ema(close, emaLen)
trendUp   = close > ema
trendDown = close < ema

// ─────────────────────────────────────────────
// SNIPER ENTRY CONDITIONS
// ─────────────────────────────────────────────
longCond  = strongBuy  and close > open
           and (not useTrend  or trendUp)
           and (not useVAConf or inValueArea)
           and (not useImb    or hasBuyImb)

shortCond = strongSell and close < open
           and (not useTrend  or trendDown)
           and (not useVAConf or inValueArea)
           and (not useImb    or hasSellImb)

// ─────────────────────────────────────────────
// LABEL SIZE HELPER
// ─────────────────────────────────────────────
sz = lblSize == "Tiny"  ? size.tiny  :
     lblSize == "Small" ? size.small :
     lblSize == "Large" ? size.large : size.normal

// ─────────────────────────────────────────────
// DRAW POC LINE (current bar only)
// ─────────────────────────────────────────────
if showPOC and not na(pocHigh)
    line.new(bar_index, pocHigh, bar_index + 1, pocHigh,
      color=pocCol, width=2, extend=extend.none)
    line.new(bar_index, pocLow, bar_index + 1, pocLow,
      color=color.new(pocCol, 60), width=1, extend=extend.none)

// ─────────────────────────────────────────────
// DRAW VALUE AREA (current bar)
// ─────────────────────────────────────────────
if showVA and not na(vahPrice) and not na(valPrice)
    box.new(bar_index, vahPrice, bar_index + 1, valPrice,
      border_color=color.new(vaCol, 30), bgcolor=vaCol,
      border_width=1, extend=extend.none)

// ─────────────────────────────────────────────
// DRAW IMBALANCES (current bar rows)
// ─────────────────────────────────────────────
if showImbalances and not na(fp)
    array<volume_row> iRows = fp.rows()
    for row in iRows
        float rUp = row.up_price()
        float rDn = row.down_price()
        if row.has_buy_imbalance()
            box.new(bar_index, rUp, bar_index + 1, rDn,
              border_color=color.new(buyImbCol, 0),
              bgcolor=buyImbCol, border_width=1, extend=extend.none)
        else if row.has_sell_imbalance()
            box.new(bar_index, rUp, bar_index + 1, rDn,
              border_color=color.new(sellImbCol, 0),
              bgcolor=sellImbCol, border_width=1, extend=extend.none)

// ─────────────────────────────────────────────
// ENTRY SIGNALS
// ─────────────────────────────────────────────
if longCond
    label.new(bar_index, low,
      text      = "▲ BUY\nΔ " + str.tostring(delta, format.volume),
      style     = label.style_label_up,
      color     = bullCol,
      textcolor = color.white,
      size      = sz,
      yloc      = yloc.belowbar)

if shortCond
    label.new(bar_index, high,
      text      = "▼ SELL\nΔ " + str.tostring(delta, format.volume),
      style     = label.style_label_down,
      color     = bearCol,
      textcolor = color.white,
      size      = sz,
      yloc      = yloc.abovebar)

// ─────────────────────────────────────────────
// BAR COLOR BY DELTA
// ─────────────────────────────────────────────
barcolor(strongBuy ? color.new(bullCol, 60) : strongSell ? color.new(bearCol, 60) : na,
  title="Delta Bar Color")

// ─────────────────────────────────────────────
// DELTA PLOT (sub-pane)
// ─────────────────────────────────────────────
deltaColor = delta >= 0 ? color.new(bullCol, 20) : color.new(bearCol, 20)
plot(delta,     title="Delta",      color=deltaColor,               display=display.pane, style=plot.style_histogram)
plot(avgDelta,  title="+Avg Delta", color=color.new(color.yellow,0),display=display.pane)
plot(-avgDelta, title="-Avg Delta", color=color.new(color.yellow,0),display=display.pane)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted, linewidth=1)

// ─────────────────────────────────────────────
// DATA WINDOW — key levels
// ─────────────────────────────────────────────
plot(pocHigh,  title="POC High",  display=display.data_window)
plot(pocLow,   title="POC Low",   display=display.data_window)
plot(vahPrice, title="VAH",       display=display.data_window)
plot(valPrice, title="VAL",       display=display.data_window)
plot(delta,    title="Bar Delta", display=display.data_window)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(longCond,  title="Sniper Long",  message="Footprint Sniper LONG  — {{ticker}} @ {{close}}  |  Delta: {{plot_4}}")
alertcondition(shortCond, title="Sniper Short", message="Footprint Sniper SHORT — {{ticker}} @ {{close}}  |  Delta: {{plot_4}}")
````
