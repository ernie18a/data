# FVG + iFVG (Static)

- url: https://www.tradingview.com/script/uUsiK29B-FVG-iFVG-Static/
- type: indicator
- pine_id: PUB;600c3298d6e34e659867aafb2940f896
- version: 1.0

## Description

[b]❤︎ FVG + iFVG (Static)[/b]

Automatically detects confirmed Fair Value Gaps (FVGs) from a static user-selected timeframe, making it easy to view them on lower-timeframe charts.

[b]Features[/b]
[list]
[*]Projects confirmed FVGs from a static timeframe onto lower-timeframe charts.
[*]Optional conversion of disrespected FVGs into iFVGs.
[*]Optional 50% equilibrium (midline) for FVGs and iFVGs.
[*]Automatic mitigation removal.
[*]Customizable display, colors, and extension length.
[/list]

[b]How It Works[/b]
[list]
[*]Bullish FVGs form after an imbalance to the upside.
[*]Bearish FVGs form after an imbalance to the downside.
[*]Confirmed FVGs are projected from the selected timeframe onto lower-timeframe charts.
[*]Disrespected FVGs can optionally convert into Inverse Fair Value Gaps (iFVGs).
[/list]


This indicator is intended as a visual analysis tool for identifying market imbalances and potential areas of interest. It does not provide financial advice or guaranteed trade signals.

## Source Code

````pine
//@version=6
indicator("❤︎ FVG (Static)", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// Settings
tf = input.timeframe("15", "FVG Timeframe", group = "Display")

displayUpToTf = input.timeframe("5", "Display Up To Chart Timeframe", group = "Display")
showOnChart = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(displayUpToTf)

removeMitigated = input.bool(true, "Remove Once Mitigated", group = "Display")

// Style
extend = input.int(100, "Extend", minval = 0, group = "FVG Style")
bullCss = input.color(color.new(#bbd9fb, 88), "Bullish FVG", group = "FVG Style")
bearCss = input.color(color.new(#FCB45B, 88), "Bearish FVG", group = "FVG Style")
showFvgMidline = input.bool(true, "Show FVG Midline", group = "FVG Style")
fvgMidlineCss = input.color(color.new(#fe9eb3, 80), "FVG Midline Color", group = "FVG Style")

// IFVG
convertToIFVG = input.bool(false, "Convert Recent Disrespected FVGs into iFVG", group = "iFVG")
maxRecentIFVGs = input.int(3, "Number of Recent iFVGs to Show", minval = 1, maxval = 50, group = "iFVG")
ifvgCss = input.color(color.new(#A8A2BA, 92), "iFVG Color", group = "iFVG")
showIfvgMidline = input.bool(false, "Show iFVG Midline", group = "iFVG")
ifvgMidlineCss = input.color(color.new(#A8A2BA, 80), "iFVG Midline Color", group = "iFVG")

type fvg
    float max
    float min
    bool isbull
    bool isifvg
    int t = time

n = bar_index

detect() =>
    fvg new_fvg = fvg.new(na, na, false, false, na)

    bull_fvg = barstate.isconfirmed and low > high[2] and close[1] > high[2]
    bear_fvg = barstate.isconfirmed and high < low[2] and close[1] < low[2]

    if bull_fvg
        new_fvg := fvg.new(low, high[2], true, false, time)
    else if bear_fvg
        new_fvg := fvg.new(low[2], high, false, false, time)

    [bull_fvg, bear_fvg, new_fvg]

var int t = 0
var fvg_records = array.new<fvg>(0)
var fvg_areas = array.new<box>(0)
var fvg_midlines = array.new<line>(0)

[bull_fvg, bear_fvg, new_fvg] = request.security(
     syminfo.tickerid,
     tf,
     detect(),
     barmerge.gaps_off,
     barmerge.lookahead_off)

createMidline(_top, _bottom, _isIfvg) =>
    mid = (_top + _bottom) / 2
    lineColor = _isIfvg ? ifvgMidlineCss : fvgMidlineCss
    line.new(n - 2, mid, n + extend, mid, color = lineColor, width = 1)

updateMidline(_line, _get) =>
    _line.set_color(_get.isifvg ? showIfvgMidline ? ifvgMidlineCss : color.new(ifvgMidlineCss, 100) : showFvgMidline ? fvgMidlineCss : color.new(fvgMidlineCss, 100))

// Bullish FVG
if showOnChart and bull_fvg and new_fvg.t != t
    fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, border_color = na, bgcolor = bullCss))
    fvg_midlines.unshift(createMidline(new_fvg.max, new_fvg.min, false))
    fvg_records.unshift(new_fvg)
    t := new_fvg.t

// Bearish FVG
if showOnChart and bear_fvg and new_fvg.t != t
    fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, border_color = na, bgcolor = bearCss))
    fvg_midlines.unshift(createMidline(new_fvg.max, new_fvg.min, false))
    fvg_records.unshift(new_fvg)
    t := new_fvg.t

// Convert Recent FVGs Into IFVG
if showOnChart and convertToIFVG and fvg_records.size() > 0
    for i = 0 to fvg_records.size() - 1
        get = fvg_records.get(i)

        if not get.isifvg
            if get.isbull and close < get.min
                area = fvg_areas.get(i)
                midline = fvg_midlines.get(i)

                area.set_bgcolor(ifvgCss)

                get.isbull := false
                get.isifvg := true
                fvg_records.set(i, get)
                updateMidline(midline, get)

            else if not get.isbull and close > get.max
                area = fvg_areas.get(i)
                midline = fvg_midlines.get(i)

                area.set_bgcolor(ifvgCss)

                get.isbull := true
                get.isifvg := true
                fvg_records.set(i, get)
                updateMidline(midline, get)

// Keep only selected number of recent iFVGs
if showOnChart and fvg_records.size() > 0
    ifvgCount = 0

    for i = 0 to fvg_records.size() - 1
        get = fvg_records.get(i)

        if get.isifvg
            ifvgCount += 1

            if ifvgCount > maxRecentIFVGs
                area = fvg_areas.remove(i)
                midline = fvg_midlines.remove(i)

                area.delete()
                midline.delete()
                fvg_records.remove(i)
                break

// Remove Once Mitigated
if showOnChart and removeMitigated and fvg_records.size() > 0
    for i = fvg_records.size() - 1 to 0
        get = fvg_records.get(i)

        if not get.isifvg and get.isbull and close < get.min
            area = fvg_areas.remove(i)
            midline = fvg_midlines.remove(i)

            area.delete()
            midline.delete()
            fvg_records.remove(i)

        else if not get.isifvg and not get.isbull and close > get.max
            area = fvg_areas.remove(i)
            midline = fvg_midlines.remove(i)

            area.delete()
            midline.delete()
            fvg_records.remove(i)

        else if get.isifvg and get.isbull and close < get.min
            area = fvg_areas.remove(i)
            midline = fvg_midlines.remove(i)

            area.delete()
            midline.delete()
            fvg_records.remove(i)

        else if get.isifvg and not get.isbull and close > get.max
            area = fvg_areas.remove(i)
            midline = fvg_midlines.remove(i)

            area.delete()
            midline.delete()
            fvg_records.remove(i)

// Apply Midline Visibility Every Bar
if showOnChart and fvg_records.size() > 0
    for i = 0 to fvg_records.size() - 1
        get = fvg_records.get(i)
        midline = fvg_midlines.get(i)
        updateMidline(midline, get)

// Alerts
alertcondition(showOnChart and bull_fvg, "Bullish FVG", "Confirmed Bullish FVG detected")
alertcondition(showOnChart and bear_fvg, "Bearish FVG", "Confirmed Bearish FVG detected")
````
