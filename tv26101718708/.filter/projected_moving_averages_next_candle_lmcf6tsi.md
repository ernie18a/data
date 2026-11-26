# Projected Moving Averages (Next Candle)

- url: https://www.tradingview.com/script/LmcF6TsI-Projected-Moving-Averages-Next-Candle/
- type: indicator
- pine_id: PUB;8f7f19a6117c410ca81221f45e246902
- version: 3.0

## Description

[b]What this indicator does[/b]
This indicator plots four fully customizable moving averages (default lengths: 9, 21, 50, 200), but with a twist — instead of showing you where the average has been, it shows you where the average would sit if the current candle's price simply repeated on the next bar.
In other words, each moving average is projected one candle into the future. It simulates the "next" value of the MA by treating the current bar's close as if it also became the next bar's close, then plots that projected value directly under/over where the next candle will form.
This gives you a forward-looking reference line instead of a lagging one — useful for seeing exactly what level the MA needs to cross, or how far the average might shift, before the next candle has even closed.

[b]Features[/b]
[list]
[*]4 independent moving averages, each with adjustable length, type (SMA, EMA, WMA, RMA), and color
[*]Shared, changeable source input (default: close)
[*]Toggle to shift the plotted lines forward onto the next candle's position, or keep them aligned with the current bar
[*]Fully overlay-based, works on any timeframe or instrument
[/list]

[b]How to use it[/b]
Turn on the offset setting to see each MA line drawn one bar ahead, right where the next candle will print. This makes it easier to visually anticipate MA crosses, support/resistance retests, or trend-following entries before they happen, rather than reacting after the fact.

[b]Important notes[/b]
[list]
[*]This is a smoothing/projection technique, not a predictive or forecasting tool. It does not predict future price — it only shows what the moving average would equal if the most recent price were to repeat. Actual future prices will differ, and the true MA will update once the next candle closes.
[*]Works with all four supported MA types (SMA, EMA, WMA, RMA); each is projected using logic specific to how that MA type weights new data.
[*]Best used alongside your existing strategy/trend-following framework, not as a standalone signal generator.
[/list]

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon (With Projection)", shorttitle = "MA Ribbon Pro", overlay = true, max_lines_count = 40)

// ============================================================================
// PROJECTION SETTINGS
// ============================================================================
proj_on      = input.bool(false, "Project Ahead",                 inline = "proj",  group = "Projection")
proj_bars    = input.int(1, "Candles Ahead", inline = "proj",     options = [1, 2], group = "Projection")
keep_history = input.bool(true, "Keep historical MA intact (only project the unknown future)", group = "Projection")

// ============================================================================
// MA CALCULATION
// ============================================================================

// Normal MA - identical to a standard MA ribbon
normalMA(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

// Projected MA - simulates the MA N candles ahead, assuming price (and volume,
// for VWMA) repeat the current bar's values for those N future candles.
// Uses only current/past bar data - no lookahead.
projectedMA(source, length, MAtype, N) =>
    float result = na
    realcount = math.max(length - N, 0)
    dupcount  = length - realcount
    if MAtype == "SMA"
        sumPart = 0.0
        if realcount > 0
            for k = 0 to realcount - 1
                sumPart += source[k]
        result := (sumPart + dupcount * source) / length
    else if MAtype == "EMA"
        alpha = 2.0 / (length + 1)
        val = ta.ema(source, length)
        for i = 1 to N
            val := val + alpha * (source - val)
        result := val
    else if MAtype == "SMMA (RMA)"
        alpha = 1.0 / length
        val = ta.rma(source, length)
        for i = 1 to N
            val := val + alpha * (source - val)
        result := val
    else if MAtype == "WMA"
        wsum = 0.0
        wtot = 0.0
        for j = 1 to dupcount
            w = length - dupcount + j
            wsum += source * w
            wtot += w
        if realcount > 0
            for k = 0 to realcount - 1
                w = realcount - k
                wsum += source[k] * w
                wtot += w
        result := wsum / wtot
    else if MAtype == "VWMA"
        num = 0.0
        den = 0.0
        if realcount > 0
            for k = 0 to realcount - 1
                num += source[k] * volume[k]
                den += volume[k]
        num += dupcount * source * volume
        den += dupcount * volume
        result := num / den
    result

// ============================================================================
// MA #1
// ============================================================================
show_ma1   = input(true,         "MA #1", inline = "MA #1", display = display.none)
ma1_type   = input.string("SMA", "",      inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close,        "",      inline = "MA #1", active = show_ma1, display = display.none)
ma1_length = input.int(9,        "",      inline = "MA #1", active = show_ma1, minval  = 1)
ma1_color  = input(#ffeb3b,      "",      inline = "MA #1", active = show_ma1, display = display.none)
ma1_width  = input.int(2, "",             inline = "MA #1", active = show_ma1, minval = 1, maxval = 6)

// ============================================================================
// MA #2
// ============================================================================
show_ma2   = input(true,         "MA #2", inline = "MA #2", display = display.none)
ma2_type   = input.string("SMA", "",      inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close,        "",      inline = "MA #2", active = show_ma2, display = display.none)
ma2_length = input.int(21,       "",      inline = "MA #2", active = show_ma2, minval  = 1)
ma2_color  = input(#2962ff,      "",      inline = "MA #2", active = show_ma2, display = display.none)
ma2_width  = input.int(2, "",             inline = "MA #2", active = show_ma2, minval = 1, maxval = 6)

// ============================================================================
// MA #3
// ============================================================================
show_ma3   = input(true,         "MA #3", inline = "MA #3", display = display.none)
ma3_type   = input.string("SMA", "",      inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close,        "",      inline = "MA #3", active = show_ma3, display = display.none)
ma3_length = input.int(50,       "",      inline = "MA #3", active = show_ma3, minval  = 1)
ma3_color  = input(#e65100,      "",      inline = "MA #3", active = show_ma3, display = display.none)
ma3_width  = input.int(2, "",             inline = "MA #3", active = show_ma3, minval = 1, maxval = 6)

// ============================================================================
// MA #4
// ============================================================================
show_ma4   = input(true,         "MA #4", inline = "MA #4", display = display.none)
ma4_type   = input.string("SMA", "",      inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close,        "",      inline = "MA #4", active = show_ma4, display = display.none)
ma4_length = input.int(200,      "",      inline = "MA #4", active = show_ma4, minval  = 1)
ma4_color  = input(#f60c0c,      "",      inline = "MA #4", active = show_ma4, display = display.none)
ma4_width  = input.int(2, "",             inline = "MA #4", active = show_ma4, minval = 1, maxval = 6)

// ============================================================================
// COMPUTE VALUES
// ============================================================================
N = proj_on ? proj_bars : 0
isLastBar = bar_index == last_bar_index

hist_ma1 = show_ma1 ? normalMA(ma1_source, ma1_length, ma1_type) : na
hist_ma2 = show_ma2 ? normalMA(ma2_source, ma2_length, ma2_type) : na
hist_ma3 = show_ma3 ? normalMA(ma3_source, ma3_length, ma3_type) : na
hist_ma4 = show_ma4 ? normalMA(ma4_source, ma4_length, ma4_type) : na

// legacy full-shift projection (used only when keep_history is off)
proj_ma1 = (show_ma1 and proj_on) ? projectedMA(ma1_source, ma1_length, ma1_type, N) : na
proj_ma2 = (show_ma2 and proj_on) ? projectedMA(ma2_source, ma2_length, ma2_type, N) : na
proj_ma3 = (show_ma3 and proj_on) ? projectedMA(ma3_source, ma3_length, ma3_type, N) : na
proj_ma4 = (show_ma4 and proj_on) ? projectedMA(ma4_source, ma4_length, ma4_type, N) : na

// per-step projections (t+1 and t+2), used when keep_history is on
ma1_t1 = (show_ma1 and proj_on) ? projectedMA(ma1_source, ma1_length, ma1_type, 1) : na
ma1_t2 = (show_ma1 and proj_on) ? projectedMA(ma1_source, ma1_length, ma1_type, 2) : na
ma2_t1 = (show_ma2 and proj_on) ? projectedMA(ma2_source, ma2_length, ma2_type, 1) : na
ma2_t2 = (show_ma2 and proj_on) ? projectedMA(ma2_source, ma2_length, ma2_type, 2) : na
ma3_t1 = (show_ma3 and proj_on) ? projectedMA(ma3_source, ma3_length, ma3_type, 1) : na
ma3_t2 = (show_ma3 and proj_on) ? projectedMA(ma3_source, ma3_length, ma3_type, 2) : na
ma4_t1 = (show_ma4 and proj_on) ? projectedMA(ma4_source, ma4_length, ma4_type, 1) : na
ma4_t2 = (show_ma4 and proj_on) ? projectedMA(ma4_source, ma4_length, ma4_type, 2) : na

// ============================================================================
// MODE A: legacy behavior - whole series shifted forward (history included)
// Only active when proj_on is true AND keep_history is false.
// ============================================================================
legacyOffsetMode = proj_on and not keep_history
legacyN = legacyOffsetMode ? N : 0

plot(legacyOffsetMode ? proj_ma1 : hist_ma1, "MA #1", ma1_color, linewidth = ma1_width, display = show_ma1 ? display.all : display.none, offset = legacyN)
plot(legacyOffsetMode ? proj_ma2 : hist_ma2, "MA #2", ma2_color, linewidth = ma2_width, display = show_ma2 ? display.all : display.none, offset = legacyN)
plot(legacyOffsetMode ? proj_ma3 : hist_ma3, "MA #3", ma3_color, linewidth = ma3_width, display = show_ma3 ? display.all : display.none, offset = legacyN)
plot(legacyOffsetMode ? proj_ma4 : hist_ma4, "MA #4", ma4_color, linewidth = ma4_width, display = show_ma4 ? display.all : display.none, offset = legacyN)

// ============================================================================
// MODE B: keep history intact - historical plot stays at offset 0 (already
// handled above via hist_maX when legacyOffsetMode is false).
//
// The projected candle(s) are exposed as REAL plot data (visible in the Data
// Window and on the price scale) via dedicated offset plots, one per future
// candle. A connecting line (line.new) is drawn only at the last bar purely
// for the visual stroke joining anchor -> t+1 -> t+2, using the identical
// color/width as the main MA so any style change applies everywhere.
// ============================================================================
segmentMode = proj_on and keep_history

ma1_hard1 = (show_ma1 and segmentMode and isLastBar) ? ma1_t1 : na
ma1_hard2 = (show_ma1 and segmentMode and proj_bars == 2 and isLastBar) ? ma1_t2 : na
ma2_hard1 = (show_ma2 and segmentMode and isLastBar) ? ma2_t1 : na
ma2_hard2 = (show_ma2 and segmentMode and proj_bars == 2 and isLastBar) ? ma2_t2 : na
ma3_hard1 = (show_ma3 and segmentMode and isLastBar) ? ma3_t1 : na
ma3_hard2 = (show_ma3 and segmentMode and proj_bars == 2 and isLastBar) ? ma3_t2 : na
ma4_hard1 = (show_ma4 and segmentMode and isLastBar) ? ma4_t1 : na
ma4_hard2 = (show_ma4 and segmentMode and proj_bars == 2 and isLastBar) ? ma4_t2 : na

plot(ma1_hard1, "MA #1 Projected (t+1)", ma1_color, linewidth = ma1_width, offset = 1, display = display.data_window + display.price_scale)
plot(ma1_hard2, "MA #1 Projected (t+2)", ma1_color, linewidth = ma1_width, offset = 2, display = display.data_window + display.price_scale)
plot(ma2_hard1, "MA #2 Projected (t+1)", ma2_color, linewidth = ma2_width, offset = 1, display = display.data_window + display.price_scale)
plot(ma2_hard2, "MA #2 Projected (t+2)", ma2_color, linewidth = ma2_width, offset = 2, display = display.data_window + display.price_scale)
plot(ma3_hard1, "MA #3 Projected (t+1)", ma3_color, linewidth = ma3_width, offset = 1, display = display.data_window + display.price_scale)
plot(ma3_hard2, "MA #3 Projected (t+2)", ma3_color, linewidth = ma3_width, offset = 2, display = display.data_window + display.price_scale)
plot(ma4_hard1, "MA #4 Projected (t+1)", ma4_color, linewidth = ma4_width, offset = 1, display = display.data_window + display.price_scale)
plot(ma4_hard2, "MA #4 Projected (t+2)", ma4_color, linewidth = ma4_width, offset = 2, display = display.data_window + display.price_scale)

// --- visual connecting segments (line objects, redrawn each bar at the tip) ---
var line ln1a = na
var line ln1b = na
var line ln2a = na
var line ln2b = na
var line ln3a = na
var line ln3b = na
var line ln4a = na
var line ln4b = na

if not na(ln1a)
    line.delete(ln1a)
    ln1a := na
if not na(ln1b)
    line.delete(ln1b)
    ln1b := na
if not na(ln2a)
    line.delete(ln2a)
    ln2a := na
if not na(ln2b)
    line.delete(ln2b)
    ln2b := na
if not na(ln3a)
    line.delete(ln3a)
    ln3a := na
if not na(ln3b)
    line.delete(ln3b)
    ln3b := na
if not na(ln4a)
    line.delete(ln4a)
    ln4a := na
if not na(ln4b)
    line.delete(ln4b)
    ln4b := na

if isLastBar and segmentMode
    if show_ma1 and not na(hist_ma1) and not na(ma1_t1)
        ln1a := line.new(bar_index, hist_ma1, bar_index + 1, ma1_t1, xloc = xloc.bar_index, color = ma1_color, width = ma1_width, style = line.style_solid)
        if proj_bars == 2 and not na(ma1_t2)
            ln1b := line.new(bar_index + 1, ma1_t1, bar_index + 2, ma1_t2, xloc = xloc.bar_index, color = ma1_color, width = ma1_width, style = line.style_solid)
    if show_ma2 and not na(hist_ma2) and not na(ma2_t1)
        ln2a := line.new(bar_index, hist_ma2, bar_index + 1, ma2_t1, xloc = xloc.bar_index, color = ma2_color, width = ma2_width, style = line.style_solid)
        if proj_bars == 2 and not na(ma2_t2)
            ln2b := line.new(bar_index + 1, ma2_t1, bar_index + 2, ma2_t2, xloc = xloc.bar_index, color = ma2_color, width = ma2_width, style = line.style_solid)
    if show_ma3 and not na(hist_ma3) and not na(ma3_t1)
        ln3a := line.new(bar_index, hist_ma3, bar_index + 1, ma3_t1, xloc = xloc.bar_index, color = ma3_color, width = ma3_width, style = line.style_solid)
        if proj_bars == 2 and not na(ma3_t2)
            ln3b := line.new(bar_index + 1, ma3_t1, bar_index + 2, ma3_t2, xloc = xloc.bar_index, color = ma3_color, width = ma3_width, style = line.style_solid)
    if show_ma4 and not na(hist_ma4) and not na(ma4_t1)
        ln4a := line.new(bar_index, hist_ma4, bar_index + 1, ma4_t1, xloc = xloc.bar_index, color = ma4_color, width = ma4_width, style = line.style_solid)
        if proj_bars == 2 and not na(ma4_t2)
            ln4b := line.new(bar_index + 1, ma4_t1, bar_index + 2, ma4_t2, xloc = xloc.bar_index, color = ma4_color, width = ma4_width, style = line.style_solid)
````
