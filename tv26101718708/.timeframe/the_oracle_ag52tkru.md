# The Oracle

- url: https://www.tradingview.com/script/Ag52TKrU-The-Oracle/
- type: indicator
- pine_id: PUB;3025b4af92ac4a5a87b47b60e81cbc34
- version: 1.0

## Description

THE ORACLE — ZIZO Dev% + Risk
Hard money. Don't trust. Verify.

WHAT IT IS
The Oracle is a single-pane cycle instrument for Bitcoin and other majors. It fuses
two ideas that traders normally run separately: how far price has stretched from its
mean (Dev%), and where that stretch sits on a bounded 0–100 risk scale. It then labels
every major turning point with the full readout, so past cycles become a verifiable
record rather than a memory.

THE ONE THING TO UNDERSTAND
Column HEIGHT = deviation. Column COLOUR = risk.

Each bar's height shows how far price sits above or below its moving average, as a
percentage. Each bar's colour comes from the ZIZO risk model — a dark-blue-to-red
heatmap running low risk to high risk. So you see "how stretched" and "how dangerous"
in one glance. A tall green column and a tall red column mean very different things.

WHAT PROBLEM IT SOLVES
Deviation oscillators tell you price is extended but not whether that matters this
cycle. Risk models tell you the danger level but hide the raw stretch. The Oracle shows
both at once, and pins the numbers to the actual pivots so you can check the model
against history instead of trusting it.

HOW THE MATH WORKS
Dev%: the percentage distance of close from a chosen moving average.
  Dev% = 100 × (close − MA) / MA
You choose the MA type (SMA, EMA, WMA, VWMA, HMA) and length. Default is a 200 SMA.
A "Spread" mode is also available if you prefer raw price distance over percentage.

Risk: a logarithmic position between a smoothed lower and upper band.
  Risk = (log price − log lower) / (log upper − log lower)
The bands are anchored to the asset's own long moving average and scaled by a slow
decay term, so the model ages with the market rather than refitting to it. Once the
coefficients are set, they stay fixed. That is the point — a fixed anchor is what makes
the reading verifiable.

The pane also prints Risk and Smoothed Risk (0–100) to the Data Window on every bar.

PIVOT LABELS (THE CYCLE LOG)
The Oracle finds major highs and lows in the deviation series and labels each one.
With "Enrich pivot labels" on, every label carries four lines:
  Date
  Dev%
  Risk (0–100)
  Smoothed Risk (0–100)
This turns the chart into a running log of cycle tops and bottoms with their exact
conditions attached. Read left to right and you can see whether each cycle peaked at a
similar risk level, or whether the character is shifting.

MEDIAN ENGINE
Two optional medians summarise the history:
  Peak medians — the typical magnitude of major pivot highs and lows.
  All-bar medians — the central tendency of every positive and negative deviation.
Use the peak medians as rough "this is where cycles usually turn" reference lines. A
minimum-magnitude filter keeps small noise pivots out of the peak calculation.

READABILITY
Auto-contrast picks black or white label text automatically from each background's
brightness, so labels stay legible across the full

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  THE ORACLE — ZIZO Dev% + Risk
//  Merged deviation oscillator + risk metric with enriched pivot labels.
//  Hard money. Don't trust. Verify.
// ═══════════════════════════════════════════════════════════════════════════
indicator('The Oracle', overlay = false, precision = 2)


// ─── ① DEV% CORE INPUTS ─────────────────────────────────────────────────────
src              = input.source(defval = close,        title = 'Source')
length           = input.int   (defval = 200,          title = 'Length')
calculation_type = input.string(defval = 'Percentage', title = 'Calculation Type', options = ['Spread', 'Percentage'])
ma_type          = input.string(defval = 'SMA',        title = 'MA Type',          options = ['EMA', 'SMA', 'WMA', 'VWMA', 'HMA'])

// Highest High / Lowest Low
show_LL = input.bool(defval = false, title = 'Lowest Low',   group = 'Highest High/Lowest Low', inline = 'High/Low')
show_HH = input.bool(defval = false, title = 'Highest High', group = 'Highest High/Lowest Low', inline = 'High/Low')

// Historic Highs / Lows
show_past_low     = input.bool (defval = true,        title = 'Lows',            group = 'Historic Highs/Lows', inline = 'High/Low')
show_past_high    = input.bool (defval = true,        title = 'Highs',           group = 'Historic Highs/Lows', inline = 'High/Low')
_lookback         = input.int  (defval = 126,         title = 'Lookback Length', group = 'Historic Highs/Lows', step = 1, minval = 0)
label_text_col_up = input.color(defval = color.white, title = 'Text Colour (+)', group = 'Historic Highs/Lows', inline = 'TextCol')
label_text_col_dn = input.color(defval = color.white, title = 'Text Colour (−)', group = 'Historic Highs/Lows', inline = 'TextCol')

// Label / Text Settings
show_labels     = input.bool  (defval = true,    title = 'Show Current Value Labels', group = 'Label Settings', inline = 'cur')
label_position  = input.int   (defval = 5,       title = 'Position Offset',           group = 'Label Settings', inline = 'cur', minval = 1, step = 1)
label_text_size = input.string(defval = 'Small', title = 'Label Text Size',           group = 'Label Settings', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = 'Applies to all labels: current value, historic pivots, and medians')
auto_contrast   = input.bool  (defval = true,    title = 'Auto-contrast label text (overrides manual text colours)', group = 'Label Settings', tooltip = 'When ON, every risk-coloured label picks black or white text automatically based on background brightness, so text is always readable. Turn OFF to use the manual Text Colour (+/−) inputs.')

// Median Labels
show_medians_all  = input.bool (defval = false, title = 'Show All-Bar Median',       group = 'Median Labels')
show_medians_peak = input.bool (defval = true,  title = 'Show Peak Median',          group = 'Median Labels')
median_offset     = input.int  (defval = 63,    title = 'Offset (bars from current)', group = 'Median Labels', minval = 1)
peak_min_mag      = input.float(defval = 5.0,   title = 'Min Peak Magnitude (%)',    group = 'Median Labels', minval = 0.0, step = 0.5, tooltip = 'Pivots with |value| below this threshold are excluded from the peak median')
show_debug        = input.bool (defval = false, title = 'Show Debug Table',          group = 'Median Labels')

// Colour Scheme
hist_colour_mode = input.string(defval = 'Risk Spectrum', title = 'Histogram Colour Mode', options = ['Risk Spectrum', 'Dev% Gradient'], group = 'Colour Scheme', tooltip = 'Risk Spectrum = full dark-blue→red heatmap driven by the per-bar Risk model. Dev% Gradient = legacy upside/downside soft/strong colouring.')
col_up_strong    = input.color (defval = #e6392d,         title = 'Upside (strong)',   group = 'Colour Scheme', inline = 'up')
col_up_soft      = input.color (defval = #ffcc33,         title = 'Upside (soft)',     group = 'Colour Scheme', inline = 'up')
col_dn_strong    = input.color (defval = #0a4d8c,         title = 'Downside (strong)', group = 'Colour Scheme', inline = 'dn')
col_dn_soft      = input.color (defval = #a6d96e,         title = 'Downside (soft)',   group = 'Colour Scheme', inline = 'dn')
use_gradient     = input.bool  (defval = true,            title = 'Use gradient (else solid)', group = 'Colour Scheme')

// Cycle Log
enrich_labels     = input.bool  (defval = true,         title = 'Enrich pivot labels with Risk data', group = 'Cycle Log')
enrich_label_size = input.string(defval = 'Small',      title = 'Enriched label text size',           group = 'Cycle Log', options = ['Tiny', 'Small', 'Normal', 'Large'])
enrich_date_fmt   = input.string(defval = 'yyyy-MM-dd', title = 'Date format',                        group = 'Cycle Log', tooltip = 'Uses str.format_time')

// Risk Metric Core
rm_smaLen              = input.int   (defval = 200,   title = 'SMA length',            group = 'Risk Metric', inline = 'UI_1')
rm_sfTimeOffset        = input.int   (defval = 126,   title = 'Time offset',           group = 'Risk Metric', inline = 'UI_1', minval = 0)
rm_sfDecay             = input.float (defval = -0.85, title = 'Decay',                 group = 'Risk Metric', inline = 'UI_2')
rm_sfSensitivity       = input.float (defval = 0.006, title = 'Sensitivity',           group = 'Risk Metric', inline = 'UI_2')
rm_sfBaselineControl   = input.float (defval = 1.024, title = 'Baseline control',      group = 'Risk Metric', inline = '1')
rm_upperbound          = input.float (defval = 3.0,   title = 'Upper bound',           group = 'Risk Metric', inline = '2')
rm_lowerbound          = input.float (defval = 0.35,  title = 'Lower bound',           group = 'Risk Metric', inline = '2')
rm_lowerboundIsDynamic = input.bool  (defval = false, title = 'Lowerbound is dynamic', group = 'Risk Metric', inline = '2')
rm_timeframeInput      = input.string(defval = 'D',   title = 'Timeframe (D/W/M/Chart)', group = 'Risk Metric', inline = '3', options = ['D', 'W', 'M', 'Chart'])


// ─── RISK SPECTRUM PALETTE (ZIZO official 10 stops, LOW → HIGH risk) ─────────
spec_c0 = #0a4d8c   // dark blue  (lowest risk)
spec_c1 = #1e7cc2
spec_c2 = #2eb8d9
spec_c3 = #3ed9a6
spec_c4 = #a6d96e
spec_c5 = #e6e64c   // yellow     (mid risk)
spec_c6 = #ffcc33
spec_c7 = #ff9933
spec_c8 = #ff6633
spec_c9 = #e6392d   // red        (highest risk)


// ─── ② DEV% CALCULATION ─────────────────────────────────────────────────────
GetMA = switch ma_type
    'EMA'  => ta.ema (src, length)
    'SMA'  => ta.sma (src, length)
    'WMA'  => ta.wma (src, length)
    'VWMA' => ta.vwma(src, length)
    'HMA'  => ta.hma (src, length)

GetSeries = switch calculation_type
    'Spread'     => close - GetMA
    'Percentage' => 100 * (close - GetMA) / GetMA

GetLowestLow() =>
    if show_LL
        var float lowest_low = 0.0
        if GetSeries < lowest_low
            lowest_low := GetSeries
        lowest_low

GetHighestHigh() =>
    if show_HH
        var float highest_high = 0.0
        if GetSeries > highest_high
            highest_high := GetSeries
        highest_high

GetLabelSize() =>
    switch label_text_size
        'Auto'   => size.auto
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        'Huge'   => size.huge

GetEnrichLabelSize() =>
    switch enrich_label_size
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large

// Auto-contrast text: black on bright backgrounds, white on dark
ContrastText(bgCol) =>
    float lum = 0.299 * color.r(bgCol) + 0.587 * color.g(bgCol) + 0.114 * color.b(bgCol)
    lum > 150 ? color.black : color.white

SetLabel(show_label, textValue, percentage, col) =>
    if not na(percentage) and barstate.islast and show_label
        dt   = time - time[1]
        newX = time + label_position * dt

        string percentageString = str.tostring(percentage, format.percent)
        string textLabel        = textValue != '' ? textValue + ' (' + percentageString + ')' : percentageString

        label l = label.new(x = newX, y = percentage, xloc = xloc.bar_time, style = label.style_label_left)
        label.set_color    (id = l, color     = color.new(col, 0))
        label.set_text     (id = l, text      = textLabel)
        label.set_textcolor(id = l, textcolor = auto_contrast ? ContrastText(col) : color.white)
        label.set_textalign(id = l, textalign = text.align_right)
        label.set_size     (id = l, size      = GetLabelSize())
        label.set_style    (id = l, style     = label.style_label_left)

series_now = GetSeries

// Median accumulation
var array<float> pos_devs      = array.new<float>()
var array<float> neg_devs      = array.new<float>()
var array<float> pos_peak_devs = array.new<float>()
var array<float> neg_peak_devs = array.new<float>()

if barstate.isconfirmed and not na(series_now)
    if series_now > 0
        array.push(pos_devs, series_now)
    else if series_now < 0
        array.push(neg_devs, series_now)

_pl = ta.pivotlow (series_now, _lookback, _lookback)
_ph = ta.pivothigh(series_now, _lookback, _lookback)

if barstate.isconfirmed
    if not na(_ph) and _ph >= peak_min_mag
        array.push(pos_peak_devs, _ph)
    if not na(_pl) and _pl <= -peak_min_mag
        array.push(neg_peak_devs, _pl)

ref_up = ta.highest(math.max(series_now, 0), 252)
ref_dn = ta.lowest (math.min(series_now, 0), 252)

GetDevGradientCol(value) =>
    if value >= 0
        use_gradient ? color.from_gradient(value, 0, nz(ref_up, 1), col_up_soft, col_up_strong) : col_up_strong
    else
        use_gradient ? color.from_gradient(value, nz(ref_dn, -1), 0, col_dn_strong, col_dn_soft) : col_dn_strong


// ─── ③ RISK METRIC CALCULATION (v6 timeframe mapping) ───────────────────────
resolvedTimeframe = switch rm_timeframeInput
    'Chart' => ''
    'D'     => 'D'
    'W'     => 'W'
    'M'     => 'M'
    => 'D'

riskMetricFrom(float price, float upperBound, float lowerBound) =>
    float logUpperBound = math.log(upperBound)
    float logLowerBound = math.log(lowerBound)
    float logPrice      = math.log(price)
    (logPrice - logLowerBound) / (logUpperBound - logLowerBound)

float rm_assetSMA = request.security(syminfo.tickerid, resolvedTimeframe, expression = ta.sma(close, rm_smaLen))

var int rm_effectiveTimeOffset = rm_sfTimeOffset
if barstate.isfirst and rm_sfTimeOffset > last_bar_index
    rm_effectiveTimeOffset := last_bar_index

float rm_scalingFactor      = math.pow(math.e, rm_sfDecay * ((bar_index - rm_effectiveTimeOffset) * rm_sfSensitivity)) + rm_sfBaselineControl
float rm_smoothedUpperbound = rm_upperbound * rm_assetSMA * rm_scalingFactor
float rm_smoothedLowerbound = rm_lowerbound * rm_assetSMA * (rm_lowerboundIsDynamic ? rm_scalingFactor : 1)

float rm_riskMetric         = riskMetricFrom(close,       rm_smoothedUpperbound, rm_smoothedLowerbound)
float rm_smoothedRiskMetric = riskMetricFrom(rm_assetSMA, rm_smoothedUpperbound, rm_smoothedLowerbound)


// ─── RISK SPECTRUM COLOUR (10-stop, takes a 0–1 risk fraction) ──────────────
SpectrumCol(riskFrac) =>
    float x   = math.max(0.0, math.min(1.0, riskFrac))
    float seg = x * 9.0
    int   i   = math.min(8, int(math.floor(seg)))
    float f   = seg - i
    color a = switch i
        0 => spec_c0
        1 => spec_c1
        2 => spec_c2
        3 => spec_c3
        4 => spec_c4
        5 => spec_c5
        6 => spec_c6
        7 => spec_c7
        => spec_c8
    color b = switch i
        0 => spec_c1
        1 => spec_c2
        2 => spec_c3
        3 => spec_c4
        4 => spec_c5
        5 => spec_c6
        6 => spec_c7
        7 => spec_c8
        => spec_c9
    color.from_gradient(f, 0.0, 1.0, a, b)

ResolveCol(devValue, riskFrac) =>
    hist_colour_mode == 'Risk Spectrum' ? SpectrumCol(riskFrac) : GetDevGradientCol(devValue)

bar_col = ResolveCol(series_now, rm_riskMetric)


// ─── ④ HISTORIC PIVOT LABELS ────────────────────────────────────────────────
// Label order: DATE → DEV → RISK → SMOOTHED RISK (each on its own line)
EnrichedPivotText(devValue, riskFrac, smoothedFrac) =>
    string dateStr   = str.format_time(time[_lookback], enrich_date_fmt)
    string devStr    = str.tostring(math.round(devValue, 2), format.percent)
    string riskStr   = str.tostring(math.round(riskFrac * 100, 2))
    string smoothStr = str.tostring(math.round(smoothedFrac * 100, 2))
    dateStr + '\nDev: ' + devStr + '\nRisk: ' + riskStr + '\nSmoothed Risk: ' + smoothStr

if bar_index >= _lookback
    if not na(_pl) and show_past_low
        color  lowBg   = ResolveCol(_pl, rm_riskMetric[_lookback])
        string lowText = enrich_labels ? EnrichedPivotText(_pl, rm_riskMetric[_lookback], rm_smoothedRiskMetric[_lookback]) : str.tostring(math.round(_pl, 2), format.percent)
        color  lowTxt  = auto_contrast ? ContrastText(lowBg) : label_text_col_dn
        label.new(x = bar_index[_lookback], y = math.round(_pl, 2),
                  text = lowText,
                  style = label.style_label_up, color = color.new(lowBg, 0),
                  textcolor = lowTxt, size = enrich_labels ? GetEnrichLabelSize() : GetLabelSize())

    if not na(_ph) and show_past_high
        color  highBg   = ResolveCol(_ph, rm_riskMetric[_lookback])
        string highText = enrich_labels ? EnrichedPivotText(_ph, rm_riskMetric[_lookback], rm_smoothedRiskMetric[_lookback]) : str.tostring(math.round(_ph, 2), format.percent)
        color  highTxt  = auto_contrast ? ContrastText(highBg) : label_text_col_up
        label.new(x = bar_index[_lookback], y = math.round(_ph, 2),
                  text = highText,
                  style = label.style_label_down, color = color.new(highBg, 0),
                  textcolor = highTxt, size = enrich_labels ? GetEnrichLabelSize() : GetLabelSize())

lowest_low   = GetLowestLow()
highest_high = GetHighestHigh()


// ─── ⑤ PLOTS ────────────────────────────────────────────────────────────────
plot(GetSeries,    title = 'Deviation', color = bar_col,       style = plot.style_columns)
plot(lowest_low,   title = 'Low',       color = col_dn_strong, style = plot.style_line)
plot(highest_high, title = 'High',      color = col_up_strong, style = plot.style_line)
hline(0, 'Zero', color = color.new(color.gray, 40), linestyle = hline.style_dotted)

// Data Window helpers
plot(series = rm_riskMetric * 100,         title = 'Risk (0-100)',          display = display.data_window)
plot(series = rm_smoothedRiskMetric * 100, title = 'Smoothed Risk (0-100)', display = display.data_window)

if show_labels
    SetLabel(true, 'LL',  math.round(lowest_low,   2), col_dn_strong)
    SetLabel(true, 'HH',  math.round(highest_high, 2), col_up_strong)
    SetLabel(true, 'Dev', math.round(GetSeries,    2), bar_col)


// ─── ⑥ MEDIAN LABELS ────────────────────────────────────────────────────────
var label med_pos_all_lbl  = na
var label med_neg_all_lbl  = na
var label med_pos_peak_lbl = na
var label med_neg_peak_lbl = na

DrawMedianLabel(existing_lbl, value, txt_prefix, fill_col, text_col, x_coord) =>
    label.delete(existing_lbl)
    na(value) ? na : label.new(x = x_coord, y = value, xloc = xloc.bar_time,
                                text = txt_prefix + ' (' + str.tostring(math.round(value, 2), format.percent) + ')',
                                style = label.style_label_left,
                                color = color.new(fill_col, 0),
                                textcolor = auto_contrast ? ContrastText(fill_col) : text_col,
                                size = GetLabelSize(),
                                textalign = text.align_right)

if barstate.islast
    dt_med   = time - time[1]
    newX_med = time + median_offset * dt_med

    if show_medians_all
        float med_pos_all = array.size(pos_devs) > 0 ? array.median(pos_devs) : na
        float med_neg_all = array.size(neg_devs) > 0 ? array.median(neg_devs) : na
        med_pos_all_lbl := DrawMedianLabel(med_pos_all_lbl, med_pos_all, 'Median+', col_up_soft, label_text_col_up, newX_med)
        med_neg_all_lbl := DrawMedianLabel(med_neg_all_lbl, med_neg_all, 'Median−', col_dn_soft, label_text_col_dn, newX_med)

    if show_medians_peak
        float med_pos_peak = array.size(pos_peak_devs) > 0 ? array.median(pos_peak_devs) : na
        float med_neg_peak = array.size(neg_peak_devs) > 0 ? array.median(neg_peak_devs) : na
        med_pos_peak_lbl := DrawMedianLabel(med_pos_peak_lbl, med_pos_peak, 'Peak Med+', col_up_strong, label_text_col_up, newX_med)
        med_neg_peak_lbl := DrawMedianLabel(med_neg_peak_lbl, med_neg_peak, 'Peak Med−', col_dn_strong, label_text_col_dn, newX_med)


// ─── ⑦ DEBUG TABLE ──────────────────────────────────────────────────────────
var table dbg = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast and show_debug
    table.cell(dbg, 0, 0, 'Array',         bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(dbg, 1, 0, 'Size / Median', bgcolor = color.new(color.black, 0), text_color = color.white, text_size = size.small)
    table.cell(dbg, 0, 1, 'pos_devs',  text_color = color.white, text_size = size.small)
    table.cell(dbg, 1, 1, str.tostring(array.size(pos_devs)) + ' / ' + (array.size(pos_devs) > 0 ? str.tostring(math.round(array.median(pos_devs), 2)) + '%' : 'n/a'), text_color = color.white, text_size = size.small)
    table.cell(dbg, 0, 2, 'neg_devs',  text_color = color.white, text_size = size.small)
    table.cell(dbg, 1, 2, str.tostring(array.size(neg_devs)) + ' / ' + (array.size(neg_devs) > 0 ? str.tostring(math.round(array.median(neg_devs), 2)) + '%' : 'n/a'), text_color = color.white, text_size = size.small)
    table.cell(dbg, 0, 3, 'pos_peaks', text_color = color.white, text_size = size.small)
    table.cell(dbg, 1, 3, str.tostring(array.size(pos_peak_devs)) + ' / ' + (array.size(pos_peak_devs) > 0 ? str.tostring(math.round(array.median(pos_peak_devs), 2)) + '%' : 'n/a'), text_color = color.white, text_size = size.small)
    table.cell(dbg, 0, 4, 'neg_peaks', text_color = color.white, text_size = size.small)
    table.cell(dbg, 1, 4, str.tostring(array.size(neg_peak_devs)) + ' / ' + (array.size(neg_peak_devs) > 0 ? str.tostring(math.round(array.median(neg_peak_devs), 2)) + '%' : 'n/a'), text_color = color.white, text_size = size.small)
````
