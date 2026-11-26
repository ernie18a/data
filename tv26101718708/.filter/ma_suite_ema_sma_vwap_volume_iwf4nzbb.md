# MA Suite (EMA SMA VWAP Volume)

- url: https://www.tradingview.com/script/iWf4nZbb-MA-Suite-EMA-SMA-VWAP-Volume/
- type: indicator
- pine_id: PUB;0010508597814400b44699adefe746f5
- version: 3.0

## Description

[b]MA Suite — EMA / SMA / VWAP + Volume[/b]

  An all-in-one trend and context toolkit that overlays the moving averages traders actually watch onto your price chart, while keeping volume in its own clean pane
  below.

  [b]What's included[/b]
  [list]
  [*][b]Three EMAs[/b] — short, medium, long (defaults 8 / 21 / 50) for fast trend and momentum reads
  [*][b]Two SMAs[/b] — short and long (defaults 50 / 200) for the classic institutional trend and golden/death-cross levels
  [*][b]VWAP[/b] — session volume-weighted average price, a key intraday fair-value reference
  [*][b]Volume[/b] — true histogram anchored at zero in its own pane, colored green/red by up/down bars, so it never squashes your price scale
  [/list]

  [b]Features[/b]
  [list]
  [*]Every line and the volume histogram has its own [b]show/hide toggle[/b] — display only what you need
  [*]Fully [b]customizable colors[/b] for each MA, VWAP, and up/down volume
  [*]All lengths are [b]adjustable inputs[/b] — tune the EMAs, SMAs, and volume to your style and timeframe
  [*]Moving averages and VWAP draw directly on the price chart; volume sits in a dedicated pane with a proper y=0 baseline
  [/list]

  [b]How to use[/b]
  [list]
  [*]Use the EMA stack (8/21/50) for short-term trend alignment — price above a rising stack favors longs, below a falling stack favors shorts
  [*]Watch the 50/200 SMAs for major trend bias and crossover signals
  [*]Trade intraday around [b]VWAP[/b] as dynamic support/resistance and a mean-reversion anchor
  [*]Confirm moves with [b]volume[/b] — breakouts and reversals on rising volume carry more weight
  [/list]

  Works on any symbol and timeframe. Adjust the lengths and colors in settings to fit your setup.

## Source Code

````pine
// @version=6
indicator(title="MA Suite (EMA SMA VWAP Volume)", shorttitle="MA Suite", overlay=false)

// Works like the built-in Volume indicator: it's a separate-scale indicator, so
// volume draws as a true y=0 histogram on its own scale. The EMAs/SMAs/VWAP are
// force-overlaid onto the price chart. To show everything (incl. the name) on the
// main chart without squishing price, right-click the indicator on the chart ->
// "Move to" -> "Existing pane above" — it keeps its own scale, just like Volume.

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------

// EMA lengths
lenES = input.int(8,  minval=1, title="EMA Short",  group="EMA")
lenEM = input.int(21, minval=1, title="EMA Medium", group="EMA")
lenEL = input.int(50, minval=1, title="EMA Long",   group="EMA")

// SMA lengths
lenSS = input.int(50,  minval=1, title="SMA Short", group="SMA")
lenSL = input.int(200, minval=1, title="SMA Long",  group="SMA")

// Volume moving average
lenVolMA = input.int(20, minval=1, title="Volume MA Length", group="Volume")

// Show/hide toggles
show_emaS = input.bool(true, title="Show EMA Short",  group="Visibility")
show_emaM = input.bool(true, title="Show EMA Medium", group="Visibility")
show_emaL = input.bool(true, title="Show EMA Long",   group="Visibility")
show_smaS = input.bool(true, title="Show SMA Short",  group="Visibility")
show_smaL = input.bool(true, title="Show SMA Long",   group="Visibility")
show_vwap   = input.bool(true, title="Show VWAP",       group="Visibility")
show_vol    = input.bool(true, title="Show Volume",     group="Visibility")
show_vol_ma = input.bool(true, title="Show Volume MA",  group="Visibility")

// Hide the value labels each plot prints on the price/volume axis
hide_axis_labels = input.bool(true, title="Hide Value Labels on Axis", group="Display")

// Colors
emaS_color = input.color(color.aqua,    title="EMA Short Color",  group="Colors")
emaM_color = input.color(color.orange,  title="EMA Medium Color", group="Colors")
emaL_color = input.color(color.red,     title="EMA Long Color",   group="Colors")
smaS_color = input.color(color.yellow,  title="SMA Short Color",  group="Colors")
smaL_color = input.color(color.fuchsia, title="SMA Long Color",   group="Colors")
vwap_color = input.color(color.white,   title="VWAP Color",       group="Colors")
volUp_color   = input.color(color.new(color.green, 50), title="Volume Up Color",   group="Colors")
volDown_color = input.color(color.new(color.red, 50),   title="Volume Down Color", group="Colors")
volMA_color   = input.color(color.new(color.white, 80), title="Volume MA Color",   group="Colors")

// Stats table (ADR% / ATR / LoD distance) — upper right of the price chart.
// Credit: ArmerSchlucker; ADR% formula from MikeC / TheScrutiniser & GlinckEastwoot.
show_adrp     = input.bool(true,  title="Show ADR%",      group="Table")
show_atr      = input.bool(false, title="Show ATR",       group="Table")
show_lod_dist = input.bool(true,  title="Show LoD dist.", group="Table")
adrp_len      = input.int(20, title="ADR% Length", group="Table", tooltip="Number of daily bars used in the ADR% calculation")
atr_len       = input.int(14, title="ATR Length",  group="Table", tooltip="Number of daily bars used in the ATR calculation")
bg_col        = input.color(#00000000,    title="Table Background Color", group="Table")
adrp_col      = input.color(color.white,  title="Text Color (ADR%)",      group="Table")
atr_col       = input.color(color.orange, title="Text Color (ATR)",       group="Table")
lod_dist_col  = input.color(color.orange, title="Text Color (LoD dist.)", group="Table")
show_empty_row = input.bool(true, title="Add an empty row above the values", group="Table", tooltip="Keeps the pane icons from overlapping the table text when multiple panes are shown")

// ---------------------------------------------------------------------------
// Calculations
// ---------------------------------------------------------------------------

emaS = ta.ema(close, lenES)
emaM = ta.ema(close, lenEM)
emaL = ta.ema(close, lenEL)

smaS = ta.sma(close, lenSS)
smaL = ta.sma(close, lenSL)

vwapVal = ta.vwap

// Volume moving average
volMA = ta.sma(volume, lenVolMA)

// Daily stats for the table
arp      = 100 * (ta.sma(high / low, adrp_len) - 1)
adrp     = request.security(syminfo.tickerid, 'D', arp)
atrVal   = request.security(syminfo.tickerid, 'D', ta.atr(atr_len))
lod_dist = request.security(syminfo.tickerid, 'D', 100 * (close - low) / ta.atr(atr_len))

// ---------------------------------------------------------------------------
// Plots
// ---------------------------------------------------------------------------

// display mode: drop the price-scale value labels when requested, but keep the
// series visible in the pane, status line, and data window
disp = hide_axis_labels ? display.all - display.price_scale : display.all

// Volume histogram in this pane, bottom fixed at y=0
volColor = close >= open ? volUp_color : volDown_color
plot(show_vol ? volume : na, title="Volume", color=volColor, style=plot.style_columns, display=disp)

// Volume moving average as a filled area (fill below the line down to y=0)
plot(show_vol_ma ? volMA : na, title="Volume MA", color=volMA_color, linewidth=2, style=plot.style_area, display=disp)

// Moving averages and VWAP forced onto the price chart (price scale)
plot(show_emaS ? emaS : na, title="EMA Short",  color=emaS_color, linewidth=1, force_overlay=true, display=disp)
plot(show_emaM ? emaM : na, title="EMA Medium", color=emaM_color, linewidth=1, force_overlay=true, display=disp)
plot(show_emaL ? emaL : na, title="EMA Long",   color=emaL_color, linewidth=2, force_overlay=true, display=disp)
plot(show_smaS ? smaS : na, title="SMA Short",  color=smaS_color, linewidth=1, force_overlay=true, display=disp)
plot(show_smaL ? smaL : na, title="SMA Long",   color=smaL_color, linewidth=2, force_overlay=true, display=disp)
plot(show_vwap ? vwapVal : na, title="VWAP",    color=vwap_color, linewidth=2, force_overlay=true, display=disp)

// ---------------------------------------------------------------------------
// Stats table (upper right of the price chart)
// ---------------------------------------------------------------------------
var table t = table.new(position.top_right, 2, 4, bgcolor=bg_col, force_overlay=true)
if barstate.islast and timeframe.period != "W" and timeframe.period != "M"
    if show_empty_row
        table.cell(t, 0, 0, "")
        table.cell(t, 1, 0, "")
    if show_adrp
        table.cell(t, 0, 1, "ADR%", text_color=adrp_col)
        table.cell(t, 1, 1, str.tostring(math.round(adrp, 2)) + "%", text_color=adrp_col)
    if show_atr
        table.cell(t, 0, 2, "ATR", text_color=atr_col)
        table.cell(t, 1, 2, str.tostring(math.round(atrVal, 2)), text_color=atr_col)
    if show_lod_dist
        table.cell(t, 0, 3, "LoD dist.", text_color=lod_dist_col)
        table.cell(t, 1, 3, str.tostring(math.round(lod_dist)) + "%", text_color=lod_dist_col)
````
