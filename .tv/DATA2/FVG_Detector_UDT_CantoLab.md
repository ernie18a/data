<!-- tradingview-pine-id: PUB;0cbd72897e374593b671ccc3b35d4eb4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FVG Detector (UDT) [CantoLab]

Source: https://www.tradingview.com/script/BoXuXgzt-FVG-Detector-UDT-CantoLab/

## Description

A straightforward Fair Value Gap (FVG) detector — this script doesn't do anything special in terms of trading logic. It's just a standard FVG marker

It's open-sourced as a reference for other developers (and non-developers curious about the code) on how to structure indicator logic using User-Defined Types (UDTs).

This is my attempt at a clean, minimal, properly organized version of FVG detection logic

Why UDTs?

UDT - user defined types

Normally, FVG detection is written inline wherever it's needed:

bullFVG = low[1] > high[3]
bearFVG = high[1] < low[3]

This works fine for a small script, but in larger, more complex indicators — the kind that span thousands of lines and check for patterns across many different bar indexes — repeating this logic everywhere gets messy fast.

With a UDT, the FVG becomes a defined structure (top, bottom, kind, indexes, drawings, etc.), and the detection logic becomes a single function. Instead of rewriting the comparison every time, you just call the function and pass in a bar index — it returns the same result. The same approach is used for plotting: drawing, mitigating, and deleting an FVG are each just method calls on the type.

This cuts what would normally be repeated blocks of logic down to just a few reusable lines, and keeps larger scripts far more organized and readable.

What it actually does

- Detects standard 3-candle bullish and bearish FVGs
- Plots them as boxes, with optional borders, mid-line, and labels
- Tracks each FVG and checks for mitigation every bar
- Mitigated FVGs are removed by default, with an option to keep them visible in a muted "failed" state instead

Settings

- Labels — toggle, size, color
- Bull FVG / Bear FVG — toggle, color, optional border
- Mid Line — toggle, color, style, width
- Show Mitigated FVGs — toggle, color

Notes

- Open source — feel free to study, reuse, or build on this
- This indicator does not provide financial advice. You are responsible for how you build around and execute on this information

---

## Source Code

````pine
//@version=6
indicator("FVG Detector (UDT) [CantoLab]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region[USER INPUTS]
groupFVG = "Fair Value Gaps"

labelBool  = input.bool(true, "Labels?", inline = "lblRow", group = groupFVG)
labelSize  = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "lblRow", group = groupFVG)
labelColor = input.color(color.new(#000000, 0), "", inline = "lblRow", group = groupFVG)

showBullFVG     = input.bool(true, "Bull FVG", inline = "fvgRowBull", group = groupFVG)
bullFVGColor    = input.color(color.new(#5B9CF6, 70), "", inline = "fvgRowBull", group = groupFVG)
showBullBorder  = input.bool(false, "Border", inline = "fvgRowBull", group = groupFVG)
bullBorderColor = input.color(#000000, "", inline = "fvgRowBull", group = groupFVG)

showBearFVG     = input.bool(true, "Bear FVG", inline = "fvgRowBear", group = groupFVG)
bearFVGColor    = input.color(color.new(#5B9CF6, 70), "", inline = "fvgRowBear", group = groupFVG)
showBearBorder  = input.bool(false, "Border", inline = "fvgRowBear", group = groupFVG)
bearBorderColor = input.color(#000000, "", inline = "fvgRowBear", group = groupFVG)

midLineBool  = input.bool(false, "Mid Line", inline = "midRow", group = groupFVG)
midLineColor = input.color(color.gray, "", inline = "midRow", group = groupFVG)
midLineStyle = input.string("Dotted", "", inline = "midRow", group = groupFVG, options = ["Solid", "Dashed", "Dotted"])
midLineWidth = input.int(1, "", inline = "midRow", group = groupFVG, options = [1, 2, 3, 4])

showMitigated  = input.bool(false, "Show Mitigated FVG's?", inline = "mitRow", group = groupFVG)
mitigatedColor = input.color(color.new(#787b86, 85), "", inline = "mitRow", group = groupFVG)
//#endregion



//#region[TYPES]
type FVG
    bool   found   = false
    string kind    = na
    float  top     = na
    float  bottom  = na
    int    bar3Idx = na
    int    bar1Idx = na
    box    b       = na
    line   mid     = na
    label  lbl     = na
//#endregion



//#region[HELPERS]
// Converts the "Label Size" dropdown string into the size.* constant label.new() expects.
labelSizeFromString(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

// Converts the "Mid Line" style dropdown string into the line.style_* constant line.new() expects.
lineStyleFromString(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid
//#endregion



//#region[FUNCTIONS AND METHODS]
// Scans for an FVG using offset as the "middle" reference bar: compares the older
// candle at offset+1 against the newer candle at offset-1, skipping the candle in
// between. Called with offset = 2, so it always compares bar 3 vs bar 1 (skipping
// bar 2), matching the standard 3-candle FVG pattern without touching the still-
// forming current bar.
fvgCheck(int offset = 2) =>
    float hiOlder = high[offset + 1]
    float loOlder = low[offset + 1]
    float hiNewer = high[offset - 1]
    float loNewer = low[offset - 1]

    FVG result = FVG.new()

    if loOlder > hiNewer
        result.found   := true
        result.kind    := "bear"
        result.top     := loOlder
        result.bottom  := hiNewer
        result.bar3Idx := bar_index[offset + 1]
        result.bar1Idx := bar_index[offset - 1]
    else if hiOlder < loNewer
        result.found   := true
        result.kind    := "bull"
        result.top     := loNewer
        result.bottom  := hiOlder
        result.bar3Idx := bar_index[offset + 1]
        result.bar1Idx := bar_index[offset - 1]

    result

// Mitigation check run against every active FVG on close[1]: a bear FVG is
// mitigated once price closes back above its top, a bull FVG once price closes
// back below its bottom.
method isMitigated(FVG f) =>
    f.kind == "bear" ? close[1] > f.top : close[1] < f.bottom

// Draws a newly found FVG: the box spans bar 3 to bar 1 (+1), with an optional
// mid line and an optional +FVG/-FVG label placed to the right of the box.
method draw(FVG f) =>
    if f.found
        color boxColor = f.kind == "bull" ? bullFVGColor : bearFVGColor
        color brdColor = f.kind == "bull" ? (showBullBorder ? bullBorderColor : na) : (showBearBorder ? bearBorderColor : na)
        float midPrice = (f.top + f.bottom) / 2
        f.b := box.new(left = f.bar3Idx, top = f.top, right = f.bar1Idx + 1, bottom = f.bottom, border_color = brdColor, bgcolor = boxColor, extend = extend.none)
        if midLineBool
            f.mid := line.new(x1 = f.bar3Idx, y1 = midPrice, x2 = f.bar1Idx + 1, y2 = midPrice, color = midLineColor, width = midLineWidth, style = lineStyleFromString(midLineStyle), extend = extend.none)
        if labelBool
            f.lbl := label.new(x = f.bar1Idx + 1, y = midPrice, text = f.kind == "bull" ? "+FVG" : "-FVG", style = label.style_label_left, color = color.new(color.white, 100), textcolor = labelColor, size = labelSizeFromString(labelSize), text_font_family = font.family_monospace)

// Fully removes an FVG's drawings (box, mid line, label) from the chart.
method delete(FVG f) =>
    f.b.delete()
    f.mid.delete()
    f.lbl.delete()

// Keeps a mitigated FVG visible instead of deleting it: strips the border,
// repaints the box in the muted "failed" color, drops the mid line, and
// relabels it +Mit/-Mit (short form for mitigated).
method markMitigated(FVG f) =>
    box.set_border_color(f.b, na)
    box.set_bgcolor(f.b, mitigatedColor)
    if not na(f.mid)
        f.mid.delete()
    if not na(f.lbl)
        label.set_text(f.lbl, f.kind == "bull" ? "+Mit" : "-Mit")
        label.set_textcolor(f.lbl, labelColor)
//#endregion



//#region[LOGIC]
var FVG[] activeFVGs = array.new<FVG>()

// offset = 2 is always passed to fvgCheck so the comparison is fixed at bar 3
// vs bar 1 (skipping bar 2, the middle/displacement candle) on every bar,
// rather than re-checking other bar spacings.
_fvg = fvgCheck(2)

if bar_index >= 3 and _fvg.found and ((_fvg.kind == "bull" and showBullFVG) or (_fvg.kind == "bear" and showBearFVG))
    _fvg.draw()
    array.push(activeFVGs, _fvg)

// Every bar, each still-active FVG is passed through isMitigated(). If
// mitigated: either keep it on chart in its "failed" muted state (if
// showMitigated is on) or delete it outright, then drop it from tracking
// either way since a mitigated FVG never needs checking again.
if array.size(activeFVGs) > 0
    for i = array.size(activeFVGs) - 1 to 0
        FVG f = array.get(activeFVGs, i)
        if f.isMitigated()
            if showMitigated
                f.markMitigated()
            else
                f.delete()
            array.remove(activeFVGs, i)
//#endregion
````
