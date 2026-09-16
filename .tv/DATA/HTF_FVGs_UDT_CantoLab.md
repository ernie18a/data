<!-- tradingview-pine-id: PUB;0ac40909f68e4afbbb535de1229a3c83 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HTF FVGs (UDT) [CantoLab]

Source: https://www.tradingview.com/script/jGvUQ2h0-HTF-FVGs-UDT-CantoLab/

## Description

A multi-timeframe extension of the FVG Detector (UDT) — plots Fair Value Gaps across up to 6 timeframes at once, still built the same way: using User-Defined Types (UDTs) so the detection, drawing, mitigation, and state-tracking logic are all just function/method calls instead of repeated inline logic.

What's different from the single-timeframe version

Instead of writing a separate request.security call for each timeframe, this uses a single reusable function that takes a timeframe as a parameter and is looped through for all 6 timeframes.

It also adds a getBar function, this solves a specific problem with HTF FVGs: the gap is detected on the higher timeframe, but if you just use the HTF bar's open time to place the box, it doesn't line up with the actual candle that created the high or low. getBar walks forward through the lower-timeframe bars to find the exact candle that produced that price, so the FVG box is drawn precisely where the gap actually formed.

Everything else is the same as the FVG Detector : 
Standard 3-candle FVG detection
Boxes with optional border, mid-line, and labels
Mitigated FVGs are removed automatically, with an option to keep them visible in a muted state

Settings
- Universal FVG Color — one color for all timeframes, or a separate color per timeframe
- Labels — toggle, size, color
- Border — toggle, color
- Mid Line — toggle, color, style, width
- Timeframe 1–6 — individually toggle, set timeframe, set color

Notes
- Open source — feel free to study, reuse, or build on this
- This indicator does not provide financial advice. You are responsible for how you build around and execute on this information

---

## Source Code

````pine
//@version=6
indicator("HTF FVGs (UDT) [CantoLab]", shorttitle = "HTF FVGs", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region[USER INPUTS]
groupGlobal = "Global Settings"

labelBool  = input.bool(true, "Labels?", inline = "lblRow", group = groupGlobal), labelSize = input.string("Small", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "lblRow", group = groupGlobal), labelColor = input.color(color.new(#000000, 0), "", inline = "lblRow", group = groupGlobal)

useUniversalFvgColor = input.bool(true, "Global FVG color", inline = "fvg", group = groupGlobal), universalFvgColor = input.color(color.new(#5B9CF6, 70), "", inline = "fvg", group = groupGlobal)
showBorder = input.bool(false, "Border", inline = "fvg", group = groupGlobal), borderColor = input.color(color.new(#000000, 0), "", inline = "fvg", group = groupGlobal)
midLineBool  = input.bool(false, "Mid", inline = "midRow", group = groupGlobal), midLineColor = input.color(color.new(color.gray, 0), "", inline = "midRow", group = groupGlobal), midLineStyle = input.string("Dotted", "", inline = "midRow", group = groupGlobal, options = ["Solid", "Dashed", "Dotted"]), midLineWidth = input.int(1, "", inline = "midRow", group = groupGlobal, options = [1, 2, 3, 4])


groupTF = "[Turn off Global fvg color to enable individual colors]"
show1 = input.bool(true, "Timeframe 1", group = groupTF, inline = "tf1"), tf1 = input.timeframe("15", "", group = groupTF, inline = "tf1"), color1 = input.color(color.new(color.blue, 70), "", group = groupTF, inline = "tf1")
show2 = input.bool(true, "Timeframe 2", group = groupTF, inline = "tf2"), tf2 = input.timeframe("60", "", group = groupTF, inline = "tf2"), color2 = input.color(color.new(color.green, 70), "", group = groupTF, inline = "tf2")
show3 = input.bool(true, "Timeframe 3", group = groupTF, inline = "tf3"), tf3 = input.timeframe("240", "", group = groupTF, inline = "tf3"), color3 = input.color(color.new(color.orange, 70), "", group = groupTF, inline = "tf3")
show4 = input.bool(true, "Timeframe 4", group = groupTF, inline = "tf4"), tf4 = input.timeframe("D", "", group = groupTF, inline = "tf4"), color4 = input.color(color.new(color.purple, 70), "", group = groupTF, inline = "tf4")
show5 = input.bool(true, "Timeframe 5", group = groupTF, inline = "tf5"), tf5 = input.timeframe("W", "", group = groupTF, inline = "tf5"), color5 = input.color(color.new(color.red, 70), "", group = groupTF, inline = "tf5")
show6 = input.bool(true, "Timeframe 6", group = groupTF, inline = "tf6"), tf6 = input.timeframe("M", "", group = groupTF, inline = "tf6"), color6 = input.color(color.new(color.yellow, 70), "", group = groupTF, inline = "tf6")
//#endregion



//#region[TYPES]
type FVG
    bool   found  = false
    string kind   = na
    float  top    = na
    float  bottom = na
    int    t3     = na
    int    t1     = na
    box    b      = na
    line   mid    = na
    label  lbl    = na

type TFState
    array<FVG> active
    int        lastT1 = na
//#endregion



//#region[FUNCTIONS AND METHODS]
labelSizeFromString(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

lineStyleFromString(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

tfToReadable(string tf) =>
    string out = tf
    if tf == "M"
        out := "1M"
    else if tf == "W"
        out := "1W"
    else if tf == "D"
        out := "1D"
    else
        int mins = int(str.tonumber(tf))
        out := mins % 1440 == 0 ? str.tostring(mins / 1440) + "D" : mins % 60 == 0 ? str.tostring(mins / 60) + "h" : str.tostring(mins) + "m"
    out

getHTFBars(string tf) =>
    request.security(syminfo.tickerid, tf, [high[3], low[3], high[1], low[1], time[3], time[1]], lookahead = barmerge.lookahead_off)

checkFVG(float h3, float l3, float h1, float l1, int t3, int t1) =>
    FVG result = FVG.new()

    if l3 > h1
        result.found  := true
        result.kind   := "bear"
        result.top    := l3
        result.bottom := h1
        result.t3     := t3
        result.t1     := t1
    else if h3 < l1
        result.found  := true
        result.kind   := "bull"
        result.top    := l1
        result.bottom := h3
        result.t3     := t3
        result.t1     := t1

    result

// Walks LTF bars forward from an HTF bar's open time (t0) looking for the exact
// LTF bar whose high/low matches the HTF reference price, and returns that
// bar's own timestamp. This is what lets the FVG box start on the precise LTF
// candle that made the high/low, instead of the HTF bar's open time.
getBar(float price, int t0, bool useHigh) =>
    int msPerBar = timeframe.in_seconds() * 1000
    int result = t0
    int span   = (time - t0) / msPerBar
    if span > 0 and span < 5000
        for j = 0 to span
            if (useHigh ? high[j] : low[j]) == price
                result := time[j]
                break
    result

method draw(FVG f, color col, string tfLabel) =>
    if f.found
        color brdColor = showBorder ? borderColor : na

        // Bull FVG top/bottom = l1/h3, bear FVG top/bottom = l3/h1, so which
        // side (bar3 vs bar1) is a high vs a low flips depending on kind
        float leftPrice   = f.kind == "bull" ? f.bottom : f.top
        bool  leftIsHigh  = f.kind == "bull"
        int   preciseLeft = getBar(leftPrice, f.t3, leftIsHigh)

        float rightPrice   = f.kind == "bull" ? f.top : f.bottom
        bool  rightIsHigh  = f.kind == "bear"
        int   preciseRight = getBar(rightPrice, f.t1, rightIsHigh)

        float midPrice = (f.top + f.bottom) / 2

        f.b := box.new(left = preciseLeft, top = f.top, right = preciseRight, bottom = f.bottom, xloc = xloc.bar_time, bgcolor = col, border_color = brdColor, extend = extend.none)
        if midLineBool
            f.mid := line.new(x1 = preciseLeft, y1 = midPrice, x2 = preciseRight, y2 = midPrice, xloc = xloc.bar_time, color = midLineColor, width = midLineWidth, style = lineStyleFromString(midLineStyle), extend = extend.none)
        if labelBool
            f.lbl := label.new(x = preciseRight, y = midPrice, text = (f.kind == "bull" ? "+" : "-") + tfLabel, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = labelColor, size = labelSizeFromString(labelSize), text_font_family = font.family_monospace)

method isMitigated(FVG f) =>
    f.kind == "bear" ? close[1] > f.top : close[1] < f.bottom

method delete(FVG f) =>
    f.b.delete()
    f.mid.delete()
    f.lbl.delete()

// Handles one timeframe slot end-to-end: detect a new FVG, draw it once per
// HTF bar, then prune any FVGs that have since been mitigated.
method process(TFState st, string tf, bool show, color col) =>
    if show
        [h3, l3, h1, l1, t3, t1] = getHTFBars(tf)
        newFvg = checkFVG(h3, l3, h1, l1, t3, t1)

        // t1 only changes when a new HTF bar closes, so this guards against
        // redrawing the same FVG on every LTF bar while it's still forming
        bool isNewHtfBar = na(st.lastT1) or t1 != st.lastT1

        if newFvg.found and isNewHtfBar
            color useColor = useUniversalFvgColor ? universalFvgColor : col
            string tfLabel = tfToReadable(tf)
            newFvg.draw(useColor, tfLabel)
            array.push(st.active, newFvg)
            st.lastT1 := t1

        if array.size(st.active) > 0
            for j = array.size(st.active) - 1 to 0
                FVG f = array.get(st.active, j)
                if f.isMitigated()
                    f.delete()
                    array.remove(st.active, j)
//#endregion



//#region[LOGIC]
var TFState[] states = array.new<TFState>()
if barstate.isfirst
    for i = 0 to 5
        array.push(states, TFState.new(active = array.new<FVG>()))

var string[] tfs   = array.from(tf1, tf2, tf3, tf4, tf5, tf6)
var bool[]   shows  = array.from(show1, show2, show3, show4, show5, show6)
var color[]  cols   = array.from(color1, color2, color3, color4, color5, color6)

for i = 0 to 5
    array.get(states, i).process(array.get(tfs, i), array.get(shows, i), array.get(cols, i))
//#endregion
````
