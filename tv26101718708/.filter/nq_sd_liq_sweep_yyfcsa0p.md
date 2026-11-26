# NQ S&D + Liq Sweep

- url: https://www.tradingview.com/script/YYFCsa0p-NQ-S-D-Liq-Sweep/
- type: indicator
- pine_id: PUB;d469c361ceaf43ffb6e05ac6e1600298
- version: 1.0

## Description

takes high interest areas off 4h chart and imposes them onto the chart. Combines liquidity sweet indicator by showing large sell or buy volume as volume bubbles on the chart. Hope here is to give better entry to identify false breakouts/breakdowns

## Source Code

````pine
//@version=6
indicator("NQ S&D + Liq Sweep", shorttitle="SD Liq", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ─────────────────────────────────────
show_zones   = input.bool(true,  "Show S&D Zones", group="Supply & Demand")
zone_extend  = input.int(50,    "Zone Extend (bars)", minval=10, group="Supply & Demand")
pivot_left   = input.int(5,     "4H Pivot Left", minval=1, group="Supply & Demand")
pivot_right  = input.int(5,     "4H Pivot Right", minval=1, group="Supply & Demand")

show_bubbles = input.bool(true, "Show Liquidity Bubbles", group="Liquidity Sweeps")
vol_mult     = input.float(2.5, "Volume Multiplier", minval=1.0, group="Liquidity Sweeps")
bubble_size  = input.int(5,     "Bubble Size (1-10)", minval=1, maxval=10, group="Liquidity Sweeps")

// ── Get 4H Data ───────────────────────────────
htf_high  = request.security(syminfo.tickerid, "240", high)
htf_low   = request.security(syminfo.tickerid, "240", low)

// Detect 4H Pivots
ph = ta.pivothigh(htf_high, pivot_left, pivot_right)
pl = ta.pivotlow(htf_low,  pivot_left, pivot_right)

// ── Supply Zones (Red) ────────────────────────
var line[] supply_lines = array.new<line>()

if not na(ph)
    new_line = line.new(
         x1 = bar_index - pivot_right,
         y1 = ph,
         x2 = bar_index + zone_extend,
         y2 = ph,
         color = color.red,
         width = 2,
         style = line.style_solid
    )
    array.push(supply_lines, new_line)

// ── Demand Zones (Green) ──────────────────────
var line[] demand_lines = array.new<line>()

if not na(pl)
    new_line = line.new(
         x1 = bar_index - pivot_right,
         y1 = pl,
         x2 = bar_index + zone_extend,
         y2 = pl,
         color = color.green,
         width = 2,
         style = line.style_solid
    )
    array.push(demand_lines, new_line)

// Cleanup old lines
if array.size(supply_lines) > 20
    line.delete(array.shift(supply_lines))
if array.size(demand_lines) > 20
    line.delete(array.shift(demand_lines))

// ── Liquidity Sweep Bubbles ───────────────────
vol_avg   = ta.sma(volume, 20)
high_vol  = volume > vol_avg * vol_mult

bull_sweep = high_vol and close > open and close > high[1]
bear_sweep = high_vol and close < open and close < low[1]

// Green Bubble - Strong Buy Volume
if show_bubbles and bull_sweep
    label.new(bar_index, low - ta.atr(10) * 0.6, "🟢",
              color=color.new(color.green, 0),
              textcolor=color.white,
              size = bubble_size >= 7 ? size.large : size.normal,
              style=label.style_label_up,
              yloc=yloc.belowbar)

// Red Bubble - Strong Sell Volume
if show_bubbles and bear_sweep
    label.new(bar_index, high + ta.atr(10) * 0.6, "🔴",
              color=color.new(color.red, 0),
              textcolor=color.white,
              size = bubble_size >= 7 ? size.large : size.normal,
              style=label.style_label_down,
              yloc=yloc.abovebar)

// High volume background tint
bgcolor(high_vol ? color.new(color.yellow, 92) : na)

// Alerts
alertcondition(bull_sweep, "Bullish Liquidity Sweep", "🟢 High Buy Volume Sweep Detected")
alertcondition(bear_sweep, "Bearish Liquidity Sweep", "🔴 High Sell Volume Sweep Detected")
````
