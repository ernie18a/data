<!-- tradingview-pine-id: PUB;824de13f5cbc477abb74d0221915be32 -->
<!-- tradingviewscripts-format: 1 -->
# Quantified Relative Volume

Source: https://www.tradingview.com/script/5m9w9M3y-Quantified-Relative-Volume/

## Description

Quantified Relative Volume (QRVOL) highlights unusually high volume bars and quantifies exactly how strong they are - directly on the chart.

[*] Plots real volume with a configurable moving average filter (SMA, EMA, WMA, RMA, VWMA)
[*] Highlights bars where relative volume exceeds a user-defined threshold
[*] Displays the exact RVol % above each signal bar
[*] Automatically marks new volume records: HVE (Highest Volume Ever), HVY (Highest Volume of the Year), HVQ1–HVQ4 (Highest Volume per Quarter)
[*] All colors, thresholds, and label visibility are fully customizable

---

## Source Code

````pine
//@version=6
indicator('Quantified Relative Volume', 'QRVol', format = format.volume, max_labels_count = 500)

volratio = input.float(3.0, 'Volume Ratio', minval = 0.1, group = 'Volume')
normal_color = input.color(color.new(color.gray, 70), 'Normal Volume Color', group = 'Volume')
signal_color = input.color(color.rgb(255, 213, 0, 50), 'High RVol Volume Color', group = 'Volume')

show_filter = input.bool(true, 'Show Filter', group = 'Filter')
filterType = input.string('SMA', 'Filter Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA'], group = 'Filter')
filterLength = input.int(20, 'Filter Length', minval = 1, group = 'Filter')
filter_color = input.color(color.rgb(255, 255, 255, 50), 'Filter Color', group = 'Filter')

show_labels = input.bool(true, 'Show RVol Labels', group = 'Labels')
label_offset_pct = input.float(8.0, 'Label Offset %', minval = 0.0, step = 0.5, group = 'Labels')
label_text_color = input.color(color.white, 'Label Text Color', group = 'Labels')
label_bg_color = input.color(color.new(color.black, 100), 'Label Background', group = 'Labels')
show_hve = input.bool(true, 'Show HVE', group = 'Labels')
show_hvy = input.bool(true, 'Show HVY', group = 'Labels')
show_hvq = input.bool(true, 'Show HVQ1-4', group = 'Labels')

import TradingView/ta/6
[currentVolume, pastVolume, _] = ta.relativeVolume(10, '1D', true)

rvol = pastVolume > 0 ? currentVolume / pastVolume : na
volFilter = switch filterType
    'SMA' => ta.sma(volume, filterLength)
    'EMA' => ta.ema(volume, filterLength)
    'WMA' => ta.wma(volume, filterLength)
    'RMA' => ta.rma(volume, filterLength)
    'VWMA' => ta.vwma(volume, filterLength)

currentQuarter = math.ceil(month / 3)
newYear = year != year[1]
newQuarter = month != month[1] and (month - 1) % 3 == 0

var float hveVol = na
var float hvyVol = na
var float hvqVol = na

var label hveLbl = na
var label hvyLbl = na
var label hvqLbl = na

is_high_rvol = not na(rvol) and rvol > volratio
vol_color = is_high_rvol ? signal_color : normal_color
label_y = volume * (1 + label_offset_pct / 100)

plot(volume, 'Volume', vol_color, 1, plot.style_columns)
plot(show_filter ? volFilter : na, 'Volume Filter', filter_color, 1)

if show_labels and is_high_rvol
    label.new(bar_index, label_y, str.tostring(rvol, '#%'), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = label_text_color, size = size.tiny, color = label_bg_color)

// --- HVQ: beim Quartalswechsel neues Label starten, altes bleibt fix ---
if newQuarter
    hvqVol := volume
    hvqLbl := na
    hvqLbl
else if na(hvqVol) or volume > hvqVol
    hvqVol := volume
    hvqVol

isNewHVQ = newQuarter or volume == hvqVol
if show_hvq and isNewHVQ and is_high_rvol
    if na(hvqLbl)
        hvqLbl := label.new(bar_index, label_y * 1.08, 'HVQ' + str.tostring(currentQuarter), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = label_text_color, size = size.tiny, color = label_bg_color)
        hvqLbl
    else
        label.set_xy(hvqLbl, bar_index, label_y * 1.08)

// --- HVY: beim Jahreswechsel neues Label starten, altes bleibt fix ---
if newYear
    hvyVol := volume
    hvyLbl := na
    hvyLbl
else if na(hvyVol) or volume > hvyVol
    hvyVol := volume
    hvyVol

isNewHVY = newYear or volume == hvyVol
if show_hvy and isNewHVY and is_high_rvol
    if na(hvyLbl)
        hvyLbl := label.new(bar_index, label_y * 1.16, 'HVY', xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = label_text_color, size = size.tiny, color = label_bg_color)
        hvyLbl
    else
        label.set_xy(hvyLbl, bar_index, label_y * 1.16)

// --- HVE: läuft über die gesamte Historie, bekommt daher immer nur EIN Label ---
if na(hveVol) or volume > hveVol
    hveVol := volume
    if show_hve and is_high_rvol
        if na(hveLbl)
            hveLbl := label.new(bar_index, label_y * 1.24, 'HVE', xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = label_text_color, size = size.tiny, color = label_bg_color)
            hveLbl
        else
            label.set_xy(hveLbl, bar_index, label_y * 1.24)
````
