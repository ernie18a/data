# Mr.Chartnarc EMA

- url: https://www.tradingview.com/script/8WDd19Yy-Mr-Chartnarc-EMA/
- type: indicator
- pine_id: PUB;4af25f6ed2394137986e300ccaa6f9a8
- version: 1.0

## Description

EMAAAA i created this with claude and it has been my go to !

## Source Code

````pine
//@version=6
// =============================================================================
// Mr.Chartnarc EMA — Indicator (Study)
// =============================================================================
// Two-EMA system. Defaults: Fast EMA 20 (blue), Slow EMA 50 (black).
//
// Extras can be toggled LIVE from the settings panel while trading:
//   - Bull/Bear fill between EMAs
//   - Cross markers + alerts (bullish/bearish cross)
//   - Bias panel (current trend + price vs each EMA)
//
// Built for futures (ES/NQ/CL) and forex. 24-hour operation, no session filter.
// =============================================================================

indicator("Mr.Chartnarc EMA", shorttitle="Mr.Chartnarc EMA", overlay=true, max_labels_count=50)

// ============================== INPUTS =======================================

// --- EMA settings
grpEMA  = "EMA Settings"
fastLen = input.int(20, "Fast EMA Length", minval=1, group=grpEMA)
slowLen = input.int(50, "Slow EMA Length", minval=1, group=grpEMA)
src     = input.source(close, "Source",     group=grpEMA)

// --- Appearance
grpAp     = "Appearance"
fastColor = input.color(#2196F3, "Fast EMA Color", group=grpAp)
slowColor = input.color(#000000, "Slow EMA Color", group=grpAp)
fastWidth = input.int(2, "Fast EMA Width", minval=1, maxval=5, group=grpAp)
slowWidth = input.int(2, "Slow EMA Width", minval=1, maxval=5, group=grpAp)

// --- LIVE-TOGGLE EXTRAS (flip these on/off without reloading the script)
grpEx        = "Live Toggles (flip while trading)"
showFill     = input.bool(true, "Show Bull/Bear Fill", group=grpEx)
showCrosses  = input.bool(true, "Show Cross Markers",  group=grpEx)
enableAlerts = input.bool(true, "Enable Cross Alerts", group=grpEx)
showBias     = input.bool(true, "Show Bias Panel",     group=grpEx)
biasPos      = input.string("Top Right", "Bias Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=grpEx)

// --- Fill colors
grpFill   = "Fill Colors"
bullFill  = input.color(color.new(color.green, 80), "Bull Fill", group=grpFill)
bearFill  = input.color(color.new(color.red,   80), "Bear Fill", group=grpFill)

// ============================== CALCULATIONS =================================

fastEMA = ta.ema(src, fastLen)
slowEMA = ta.ema(src, slowLen)

bullish   = fastEMA > slowEMA
bearish   = fastEMA < slowEMA
bullCross = ta.crossover(fastEMA, slowEMA)
bearCross = ta.crossunder(fastEMA, slowEMA)

// ============================== PLOTS ========================================

fp = plot(fastEMA, "Fast EMA", color=fastColor, linewidth=fastWidth)
sp = plot(slowEMA, "Slow EMA", color=slowColor, linewidth=slowWidth)

// Conditional fill (live-toggleable)
fillCol = bullish ? bullFill : bearFill
fill(fp, sp, color = showFill ? fillCol : na, title="Bull/Bear Fill")

// Cross markers (live-toggleable)
plotshape(showCrosses and bullCross, "Bullish Cross", shape.triangleup,   location.belowbar, color=color.new(color.green, 0), size=size.small, text="▲")
plotshape(showCrosses and bearCross, "Bearish Cross", shape.triangledown, location.abovebar, color=color.new(color.red,   0), size=size.small, text="▼")

// ============================== BIAS PANEL (table) ===========================

f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

var table biasTable = table.new(f_pos(biasPos), 2, 5, bgcolor=color.new(color.black, 75), border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    if showBias
        bgC  = bullish ? color.new(color.green, 70) : color.new(color.red, 70)
        txtC = color.white

        priceVsBoth = close > fastEMA and close > slowEMA ? "Above both" : close < fastEMA and close < slowEMA ? "Below both" : "Between"

        table.cell(biasTable, 0, 0, "BIAS",                                              text_color=txtC, bgcolor=bgC, text_size=size.small)
        table.cell(biasTable, 1, 0, bullish ? "BULL ▲" : bearish ? "BEAR ▼" : "FLAT",     text_color=txtC, bgcolor=bgC, text_size=size.small)

        table.cell(biasTable, 0, 1, "Fast (" + str.tostring(fastLen) + ")", text_color=txtC, text_size=size.small)
        table.cell(biasTable, 1, 1, str.tostring(fastEMA, format.mintick),  text_color=txtC, text_size=size.small)

        table.cell(biasTable, 0, 2, "Slow (" + str.tostring(slowLen) + ")", text_color=txtC, text_size=size.small)
        table.cell(biasTable, 1, 2, str.tostring(slowEMA, format.mintick),  text_color=txtC, text_size=size.small)

        table.cell(biasTable, 0, 3, "Price",       text_color=txtC, text_size=size.small)
        table.cell(biasTable, 1, 3, priceVsBoth,   text_color=txtC, text_size=size.small)

        spread = math.abs(fastEMA - slowEMA)
        table.cell(biasTable, 0, 4, "Spread",                              text_color=txtC, text_size=size.small)
        table.cell(biasTable, 1, 4, str.tostring(spread, format.mintick),  text_color=txtC, text_size=size.small)
    else
        table.clear(biasTable, 0, 0, 1, 4)

// ============================== ALERTS =======================================

alertcondition(enableAlerts and bullCross, title="Mr.Chartnarc EMA — Bullish Cross", message="Fast EMA crossed ABOVE Slow EMA — Bullish bias")
alertcondition(enableAlerts and bearCross, title="Mr.Chartnarc EMA — Bearish Cross", message="Fast EMA crossed BELOW Slow EMA — Bearish bias")
````
