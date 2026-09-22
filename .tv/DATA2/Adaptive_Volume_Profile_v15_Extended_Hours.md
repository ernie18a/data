<!-- tradingview-pine-id: PUB;e1eb32d55e464b4d9ef1bb2944d18178 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Volume Profile v1.5 • Extended Hours

Source: https://www.tradingview.com/script/i8IAjLKw-Adaptive-Volume-Profile-v1-5/

## Description

[*]
Adaptive Volume Profile — Extended Hours

A customizable volume profile that shows where trading volume was concentrated across the latest chart periods. Gray horizontal bars extend left from a shared right edge, with volume totals displayed at each bar’s left tip.

### Automatic lookback
The default lookback follows your chart timeframe:

[*] **Daily:** last 150 trading days.
[*] **Weekly:** last 150 weeks.
[*] **Other time-based intervals:** last 150 chart bars.

The current developing bar is included. Changing the timeframe rebuilds the profile; scrolling or zooming does not change the lookback.

Features

[*] 30 adjustable price rows.
[*] Extended-session intraday data requested where available.
[*] Volume labels in millions, such as **50M**.
[*] Thin outlines and adjustable bar transparency.
[*] Automatic label contrast for light and dark backgrounds.
[*] Adjustable profile width and right-side position.
[*] Optional minimum-volume filter that hides smaller rows while preserving gaps at their price levels.
[*] Data-coverage status to help identify missing history.

Calculation
The profile uses hourly candles by default. Each candle’s volume is distributed proportionally across the price rows overlapping its high–low range. Smaller sampling intervals are available for finer detail, subject to historical data availability.

This produces an **estimated volume-at-price distribution**, not exact trade-by-trade volume at each price. Results can differ from TradingView’s built-in profiles and daily volume totals.

Setup
Leave space to the right of the latest candle for the profile. Appearance controls are grouped under **Inputs → Style**. Reduce the profile width or increase transparency if bars overlap your candles.

Standard time-based charts and Heikin Ashi are supported. On Heikin Ashi charts, calculations use underlying market prices rather than synthetic candle prices. For intraday charts, enable extended hours on the chart to include those periods in the lookback.

Data notes
Extended-hours coverage depends on the symbol, data feed, and account access. Coverage counts periods containing usable data; it cannot guarantee every intraday interval is available. Developing periods update as data becomes available.

Volume uses the symbol’s reported units—for example, shares for stocks—not dollar value.

---

## Source Code

````pine
//@version=6
indicator("Adaptive Volume Profile v1.5 • Extended Hours", overlay = true, max_boxes_count = 100, max_labels_count = 100)

int periods = input.int(150, "Lookback (chart bars)", minval = 1, maxval = 300, tooltip = "1D: trading days. 1W: weeks. Includes the current developing bar. Zooming or scrolling does not change the lookback.", group = "Calculation")
int rows = input.int(30, "Price rows", minval = 5, maxval = 100, group = "Calculation")
string sourceTf = input.timeframe("60", "Intraday sampling", options = ["15", "30", "60", "120"], tooltip = "Smaller intervals improve price detail but require more historical data. 60 minutes is the default for long weekly lookbacks.", group = "Calculation")
int width = input.int(24, "Maximum profile width (bar spaces)", minval = 1, maxval = 200, group = "Style")
int rightOffset = input.int(9, "Right edge after latest candle (bar spaces)", minval = 0, maxval = 100, tooltip = "The shared right edge is this many spaces after the latest candle. Bars extend LEFT from it. Leave at least this much chart margin. Increasing width does not move the right edge.", group = "Style")
color fill = input.color(color.rgb(145, 145, 145), "Bar color", group = "Style")
int fillTransparency = input.int(65, "Bar fill transparency (%)", minval = 0, maxval = 100, tooltip = "0 = solid gray; 100 = invisible fill. Outlines and volume labels stay visible.", group = "Style")
color outline = input.color(color.black, "Bar outline color", group = "Style")
float minVolumeM = input.float(0.0, "Minimum row volume (M)", minval = 0.0, step = 1.0, tooltip = "0 shows every nonzero row. Set 10 to hide rows below 10 million. Hidden rows leave gaps; calculations and total volume do not change.", group = "Calculation")
bool autoTextContrast = input.bool(true, "Automatic label contrast", group = "Style")
color customInk = input.color(color.white, "Custom volume text color", tooltip = "Used when Automatic label contrast is off.", group = "Style")
bool showStatus = input.bool(true, "Show data coverage", group = "Data coverage")
string labelSize = input.string(size.small, "Volume label size", options = [size.tiny, size.small, size.normal], group = "Style")

// Estimate the displayed fill over the chart background; labels stay opaque.
float fillOpacity = 1.0 - fillTransparency / 100.0
float blendedR = color.r(fill) * fillOpacity + color.r(chart.bg_color) * (1.0 - fillOpacity)
float blendedG = color.g(fill) * fillOpacity + color.g(chart.bg_color) * (1.0 - fillOpacity)
float blendedB = color.b(fill) * fillOpacity + color.b(chart.bg_color) * (1.0 - fillOpacity)
float brightness = 0.299 * blendedR + 0.587 * blendedG + 0.114 * blendedB
color ink = autoTextContrast ? (brightness >= 140.0 ? color.black : color.white) : color.new(customInk, 0)
// Heikin Ashi is time-based too; retrieve real OHLCV via the standard ticker.
if not (chart.is_standard or chart.is_heikinashi)
    runtime.error("Use a time-based chart (Candles, Bars, Line, or Heikin Ashi). Renko, Range, Kagi, Line Break and Point & Figure are not supported.")

// Intraday feeds are necessary: EOD feeds do not represent extended hours.
string extendedTicker = ticker.modify(ticker.standard(syminfo.tickerid), session = session.extended)
// Never request an interval larger than the chart interval.
string effectiveTf = timeframe.in_seconds(sourceTf) <= timeframe.in_seconds() ? sourceTf : timeframe.period
[hs, ls, vs] = request.security_lower_tf(extendedTicker, effectiveTf, [high, low, volume], calc_bars_count = 100000)

type PeriodData
    array<float> highs
    array<float> lows
    array<float> volumes

var array<PeriodData> history = array.new<PeriodData>()
// Normal rollback replaces the developing period on every realtime execution.
// Store only the requested tail to avoid accumulating the full chart dataset.
if bar_index >= last_bar_index - periods + 1
    history.push(PeriodData.new(hs, ls, vs))
    if history.size() > periods
        history.shift()

formatVolume(float value) =>
    value >= 1e9 ? str.tostring(value / 1e9, "#.##") + "b" : value >= 1e6 ? str.tostring(value / 1e6, "#.##") + "m" : value >= 1e3 ? str.tostring(value / 1e3, "#.##") + "k" : str.tostring(value, "#")

var array<box> drawings = array.new<box>()
var array<label> volumeLabels = array.new<label>()
var table status = table.new(position.bottom_right, 1, 1)

if barstate.islast
    for drawing in drawings
        box.delete(drawing)
    drawings.clear()
    for volumeLabel in volumeLabels
        label.delete(volumeLabel)
    volumeLabels.clear()
    float bottom = na
    float top = na
    int covered = 0
    int samples = 0
    int missingVolume = 0
    for p in history
        bool validPeriod = false
        if p.highs.size() > 0
            for i = 0 to p.highs.size() - 1
                float h = p.highs.get(i)
                float l = p.lows.get(i)
                float v = p.volumes.get(i)
                if not na(h) and not na(l) and not na(v) and v >= 0
                    bottom := na(bottom) ? l : math.min(bottom, l)
                    top := na(top) ? h : math.max(top, h)
                    samples += 1
                    validPeriod := true
                else
                    missingVolume += 1
        if validPeriod
            covered += 1
    float total = 0.0
    int displayedRows = 0
    if samples > 0
        if top <= bottom
            bottom -= syminfo.mintick * 0.5
            top += syminfo.mintick * 0.5
        float step = (top - bottom) / rows
        array<float> bins = array.new_float(rows, 0.0)
        for p in history
            if p.highs.size() > 0
                for i = 0 to p.highs.size() - 1
                    float h = p.highs.get(i)
                    float l = p.lows.get(i)
                    float v = p.volumes.get(i)
                    if not na(h) and not na(l) and not na(v) and v >= 0
                        int first = math.max(0, math.min(rows - 1, int(math.floor((l - bottom) / step))))
                        int last = math.max(0, math.min(rows - 1, int(math.floor((h - bottom) / step))))
                        total += v
                        if h == l
                            bins.set(first, bins.get(first) + v)
                        else
                            for r = first to last
                                float rowLow = bottom + r * step
                                float overlap = math.max(0.0, math.min(h, rowLow + step) - math.max(l, rowLow))
                                bins.set(r, bins.get(r) + v * overlap / (h - l))
        float peak = bins.max()
        int rightEdge = bar_index + rightOffset
        if peak > 0
            for r = 0 to rows - 1
                float amount = bins.get(r)
                if amount > 0 and amount >= minVolumeM * 1e6
                    int barWidth = math.max(1, int(math.round(width * amount / peak)))
                    int leftEdge = rightEdge - barWidth
                    float rowLow = bottom + r * step
                    box drawing = box.new(left = leftEdge, top = rowLow + step, right = rightEdge, bottom = rowLow, border_color = outline, border_width = 1, bgcolor = color.new(fill, fillTransparency))
                    drawings.push(drawing)
                    // Anchor at the variable left tip; text extends right into the bar.
                    string rowText = str.tostring(amount / 1e6, "0.#") + "M"
                    label volumeLabel = label.new(x = leftEdge, y = rowLow + step * 0.5, text = rowText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(fill, 100), textcolor = ink, size = labelSize, textalign = text.align_left, tooltip = str.tostring(amount, "#,###.##") + " volume")
                    volumeLabels.push(volumeLabel)
                    displayedRows += 1
    string unit = timeframe.period == "1D" ? " trading days" : timeframe.period == "1W" ? " weeks" : " chart bars (" + timeframe.period + ")"
    bool incomplete = covered < periods or missingVolume > 0
    string message = str.tostring(covered) + "/" + str.tostring(periods) + unit + " • " + formatVolume(total) + " total\nExtended session requested • estimated price allocation"
    if minVolumeM > 0
        message += "\n" + str.tostring(displayedRows) + "/" + str.tostring(rows) + " rows at or above " + str.tostring(minVolumeM, "0.#") + "M"
        if displayedRows == 0
            message += " — lower Minimum row volume to show bars"
    if incomplete
        message += "\nINCOMPLETE DATA: available history only"
    else
        message += "\nCoverage counts periods with data; feed gaps may remain"
    table.cell(status, 0, 0, showStatus ? message : "", text_color = incomplete ? color.orange : color.silver, text_size = size.small, bgcolor = showStatus ? color.new(color.black, 25) : na)
````
