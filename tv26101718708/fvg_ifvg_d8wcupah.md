# FVG + iFVG

- url: https://www.tradingview.com/script/d8wCupah-FVG-iFVG/
- type: indicator
- pine_id: PUB;670a07b912e94f56b86122b7c22d1be6
- version: 2.0

## Description

[b]❤︎ FVG + iFVG[/b]

Automatically detects Fair Value Gaps (FVGs) and tracks when they become Inverse Fair Value Gaps (iFVGs). This indicator is designed to keep charts clean while highlighting recent market imbalances and structure shifts.

[b]Features[/b]

[list]
[*]Detects bullish and bearish Fair Value Gaps.
[*]Supports any user-selected timeframe.
[*]Automatically converts disrespected FVGs into iFVGs.
[*]Option to automatically remove mitigated FVGs.
[*]Choose how many recent iFVGs remain visible.
[*]Customizable colors for FVGs and iFVGs.

[b]How It Works[/b]

A bullish FVG forms when price leaves an imbalance to the upside. A bearish FVG forms when price leaves an imbalance to the downside.

When price closes completely through an FVG, the gap can be converted into an Inverse Fair Value Gap (iFVG). These zones often become areas of interest after market structure shifts.

If an iFVG is later invalidated, it is automatically removed from the chart.

[b]Settings[/b]

[list]
[*][b]Timeframe[/b] – Choose the timeframe used to detect FVGs.
[*][b]Remove Once Mitigated[/b] – Automatically removes standard FVGs after they have been mitigated.
[*][b]Convert Recent FVGs into iFVGs[/b] – Converts disrespected FVGs into iFVGs instead of removing them immediately.
[*][b]Number of Recent iFVGs[/b] – Limits how many recent iFVGs remain visible on the chart.
[*][b]Style[/b] – Customize the colors and extension length of FVGs and iFVGs.
[/list]

This indicator is intended as a visual analysis tool for identifying market imbalances and potential areas of interest. It does not provide financial advice or guaranteed trade signals.

## Source Code

````pine
//@version=6
indicator("❤︎ FVG + iFVG", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// Settings
tf = input.timeframe("", "Timeframe")
removeMitigated = input.bool(true, "Remove Once Mitigated")

// Style
extend = input.int(10, "Extend", minval = 0, group = "FVG Style")
bullCss = input.color(color.new(#c7e8ca, 82), "Bullish FVG", group = "FVG Style")
bearCss = input.color(color.new(#ffc1cf, 82), "Bearish FVG", group = "FVG Style")
showFvgMidline = input.bool(true, "Show FVG Midline", group = "FVG Style")
fvgMidlineCss = input.color(color.new(#fe9eb3, 80), "FVG Midline Color", group = "FVG Style")

// IFVG
convertToIFVG = input.bool(true, "Convert Recent Disrespected FVGs into iFVG", group = "iFVG")
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

    bull_fvg = low > high[2] and close[1] > high[2]
    bear_fvg = high < low[2] and close[1] < low[2]

    if bull_fvg
        new_fvg := fvg.new(low, high[2], true, false)
    else if bear_fvg
        new_fvg := fvg.new(low[2], high, false, false)

    [bull_fvg, bear_fvg, new_fvg]

var int t = 0
var fvg_records = array.new<fvg>(0)
var fvg_areas = array.new<box>(0)
var fvg_midlines = array.new<line>(0)

[bull_fvg, bear_fvg, new_fvg] = request.security(syminfo.tickerid, tf, detect())

createMidline(_top, _bottom, _isIfvg) =>
    mid = (_top + _bottom) / 2
    lineColor = _isIfvg ? ifvgMidlineCss : fvgMidlineCss
    line.new(n - 2, mid, n + extend, mid, color = lineColor, width = 1)

// Bullish FVG
if bull_fvg and new_fvg.t != t
    fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, border_color = na, bgcolor = bullCss))
    fvg_midlines.unshift(createMidline(new_fvg.max, new_fvg.min, false))
    fvg_records.unshift(new_fvg)
    t := new_fvg.t

// Bearish FVG
if bear_fvg and new_fvg.t != t
    fvg_areas.unshift(box.new(n - 2, new_fvg.max, n + extend, new_fvg.min, border_color = na, bgcolor = bearCss))
    fvg_midlines.unshift(createMidline(new_fvg.max, new_fvg.min, false))
    fvg_records.unshift(new_fvg)
    t := new_fvg.t

// Update Midline Visibility
updateMidline(_line, _get) =>
    _line.set_color(_get.isifvg ? showIfvgMidline ? ifvgMidlineCss : color.new(ifvgMidlineCss, 100) : showFvgMidline ? fvgMidlineCss : color.new(fvgMidlineCss, 100))

// Convert Recent Disrespected FVGs Into IFVG
if convertToIFVG and fvg_records.size() > 0
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
if fvg_records.size() > 0
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
if removeMitigated and fvg_records.size() > 0
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
if fvg_records.size() > 0
    for i = 0 to fvg_records.size() - 1
        get = fvg_records.get(i)
        midline = fvg_midlines.get(i)
        updateMidline(midline, get)

// Alerts
alertcondition(bull_fvg, "Bullish FVG", "Bullish FVG detected")
alertcondition(bear_fvg, "Bearish FVG", "Bearish FVG detected")
````
