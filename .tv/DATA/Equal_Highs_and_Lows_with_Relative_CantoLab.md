<!-- tradingview-pine-id: PUB;4077df9d58c94eedaa123b5b00677b74 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Equal Highs and Lows with Relative [CantoLab]

Source: https://www.tradingview.com/script/3BeHr2qT-Equal-Highs-and-Lows-with-Relative-CantoLab/

## Description

What it does

This indicator tracks swing highs and lows and flags when price returns to touch a prior swing within a configurable tick tolerance — a classic "equal highs / equal lows" liquidity concept, extended to also mark near-misses as "relative" levels.

When a new touch lands on the exact same price as the original swing, it's labelled EQH (Equal High) / EQL (Equal Low). When the touch is close but not identical (within your tolerance setting), it's labelled REH (Relative High) / REL (Relative Low) instead.

Merging

If price keeps retesting the same level across multiple swings in succession, the indicator merges those touches into a single continuous line rather than drawing overlapping duplicates — so one clean line represents the full history of a level being retested, extending forward each time it's touched again.

Sweep detection

Once price moves decisively through a level (beyond the tolerance band), that level is marked as swept:

visuals:

[*]A dashed/dotted line extends from the level out to the sweeping candle
[*]An "✖" mark is plotted above/below the candle that swept it
[*]The original EQH/EQL line itself is left untouched by default, so you can still see where the level was

Settings

[*]Tolerance (Ticks) — how close a touch needs to be to count as equal/relative
[*]Minimum Bars Before EQ Check — how many bars must pass after a swing forms before it's eligible to be matched
[*]Labels — size and font for the EQH/EQL/REH/REL text
[*]Color — single color control for all equal/relative lines and labels
[*]Line Width / Style — for the main EQH/EQL/REH/REL lines
[*]Sweep Line Width / Style — separate control for the sweep indicator line (default: dotted)
[*]Show Swept EQ/RE Lines — toggle whether swept levels (and their sweep markers) stay visible or get hidden once swept

Notes

[*]Designed as a visual liquidity-mapping tool, not a standalone signal generator
[*]Works on any symbol/timeframe; tolerance should be tuned to the instrument's typical tick size and volatility
[*]This indicator does not provide financial advice. You are responsible for how you interpret and act on the levels it plots.

---

## Source Code

````pine
//@version=6
indicator("Equal Highs and Lows with Relative [CantoLab]"
         , shorttitle       = "EQ & RE [CantoLab]"
         , overlay          = true
         , max_bars_back    = 5000
         , max_lines_count  = 500
         )

//#region[USER INPUTS]
groupAppearance = "Equal and Relative Swings"
toleranceTicks = input.int(16, title = "Tolerance (Ticks)", minval = 0, group = groupAppearance)
labelSize = input.string("Small", title = "Labels", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "label", group = groupAppearance)
labelFont = input.string("Monospace", title = "", options = ["Default", "Monospace"], inline = "label", group = groupAppearance)
colorEQRE = input.color(color.new(color.red, 0), title = "Equal Highs and Lows (Relative)", group = groupAppearance)
lineWidth      = input.int(1, title = "Line Width", options = [1, 2, 3, 4], inline = "line", group = groupAppearance)
lineStyleInput = input.string("Solid", title = "", options = ["Solid", "Dashed", "Dotted"], inline = "line", group = groupAppearance)

groupBehavior = "Behavior"
minGapBars = input.int(3, title = "Minimum Bars Before EQ Check", minval = 1, group = groupBehavior,
     tooltip = "Number of bars that must pass after a swing point becomes checkable before it can qualify as an Equal High/Low.\n\nIf price touches the tolerance band before this many bars have passed, the point is treated as broken (swept) instead - it will never be marked equal.\n\nExample: with this set to 1, a touch on the very first checkable bar is ignored as an equal match (though it can still break the point if it goes past the band); it must wait 1 more bar before it can be marked equal.")

groupSweep = "Sweep"
sweepLineWidth = input.int(1, title = "Sweep Line Width", options = [1, 2, 3, 4], inline = "sweepLine", group = groupSweep)
sweepLineStyle = input.string("Dotted", title = "", options = ["Solid", "Dashed", "Dotted"], inline = "sweepLine", group = groupSweep)
showSweptLines = input.bool(false, title = "Show Swept EQ/RE Lines", group = groupSweep)
//#endregion


//#region[PLOT HELPERS]
NOCOLOR = color.new(color.white, 100)

labelSizeFromString(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

labelFontFromString(string s) =>
    s == "Monospace" ? font.family_monospace : font.family_default

lineStyleFromString(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted
//#endregion


//#region[TYPES]
type SwingPoint
    float price       = na
    int   time        = na
    int   formBarIdx  = na
    bool  referenced  = false

type ActiveLine
    line  ln         = na
    label lb         = na
    int   startTime  = na
    float startPrice = na
    int   endTime    = na
    float endPrice   = na
//#endregion


//#region[FUNCTIONS AND METHODS]
method isFarEnough(SwingPoint sp, int currentBarIdx, int minGap) =>
    (currentBarIdx - sp.formBarIdx) > minGap

method checkLevel(SwingPoint sp, float level, float tolerance, bool isHigh, int currentBarIdx, int minGap) =>
    string state = "none"
    if not sp.referenced
        bool farEnough = sp.isFarEnough(currentBarIdx, minGap)
        if isHigh
            if level > sp.price + tolerance
                state := "break"
            else if farEnough and level <= sp.price + tolerance and level >= sp.price - tolerance
                state := "equal"
        else
            if level < sp.price - tolerance
                state := "break"
            else if farEnough and level >= sp.price - tolerance and level <= sp.price + tolerance
                state := "equal"
        if state != "none"
            sp.referenced := true
    state

method mergeOrCreate(ActiveLine[] arr, SwingPoint sp, int endTime, float endPrice, float tolerance, bool isHigh, color lineColor) =>
    int matchIdx = -1
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            ActiveLine al = arr.get(i)
            if al.endTime == sp.time and math.abs(al.endPrice - sp.price) <= tolerance
                matchIdx := i
                break
    if matchIdx == -1
        ActiveLine al = ActiveLine.new()
        al.ln         := line.new(sp.time, sp.price, endTime, endPrice, xloc = xloc.bar_time, color = lineColor, width = lineWidth, style = lineStyleFromString(lineStyleInput))
        al.startTime  := sp.time
        al.startPrice := sp.price
        arr.push(al)
        matchIdx := arr.size() - 1
    ActiveLine al = arr.get(matchIdx)
    al.endTime  := endTime
    al.endPrice := endPrice
    line.set_x2(al.ln, endTime)
    line.set_y2(al.ln, endPrice)
    bool   exact       = al.startPrice == endPrice
    string labelText   = isHigh ? (exact ? "EQH" : "REH") : (exact ? "EQL" : "REL")
    string labelStyle  = isHigh ? label.style_label_down : label.style_label_up
    int    midTime     = int(math.round((al.startTime + endTime) / 2))
    if na(al.lb)
        al.lb := label.new(midTime, endPrice, labelText, xloc = xloc.bar_time, style = labelStyle, color = NOCOLOR, textcolor = lineColor, size = labelSizeFromString(labelSize), text_font_family = labelFontFromString(labelFont))
    if not na(al.lb)
        al.lb.set_x(midTime)
        al.lb.set_y(endPrice)
        al.lb.set_text(labelText)

method checkSweep(ActiveLine[] arr, float level, int sweepTime, bool isHigh, float tolerance, color lineColor, int sweepWidth, string sweepStyle, bool showSwept) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            ActiveLine al = arr.get(i)
            float extreme = isHigh ? math.max(al.startPrice, al.endPrice) : math.min(al.startPrice, al.endPrice)
            bool  swept   = isHigh ? level > extreme + tolerance : level < extreme - tolerance
            if swept
                if showSwept
                    line.new(al.endTime, extreme, sweepTime, extreme, xloc = xloc.bar_time, color = lineColor, style = lineStyleFromString(sweepStyle), width = sweepWidth)
                    yl = isHigh ? yloc.abovebar : yloc.belowbar
                    label.new(sweepTime, extreme, "✖", xloc = xloc.bar_time, yloc = yl, color = NOCOLOR, textcolor = lineColor, size = size.small)
                if not showSwept
                    line.delete(al.ln)
                    if not na(al.lb)
                        label.delete(al.lb)
                arr.remove(i)
//#endregion


//#region[LOGIC]
var SwingPoint[] swingHighs = array.new<SwingPoint>()
var SwingPoint[] swingLows  = array.new<SwingPoint>()

var ActiveLine[] activeHighs = array.new<ActiveLine>()
var ActiveLine[] activeLows  = array.new<ActiveLine>()

float tolerancePrice = toleranceTicks * syminfo.mintick

float h1 = high[1]
float l1 = low[1]
int   t1 = time[1]

activeHighs.checkSweep(h1, t1, true, tolerancePrice, colorEQRE, sweepLineWidth, sweepLineStyle, showSweptLines)
activeLows.checkSweep(l1, t1, false, tolerancePrice, colorEQRE, sweepLineWidth, sweepLineStyle, showSweptLines)

int recentEQHIdx  = -1
int recentEQHTime = -1

if swingHighs.size() > 0
    for i = 0 to swingHighs.size() - 1
        SwingPoint sp = swingHighs.get(i)
        string state = sp.checkLevel(h1, tolerancePrice, true, bar_index, minGapBars)
        if state == "equal" and sp.time > recentEQHTime
            recentEQHTime := sp.time
            recentEQHIdx  := i

int recentEQLIdx  = -1
int recentEQLTime = -1

if swingLows.size() > 0
    for i = 0 to swingLows.size() - 1
        SwingPoint sp = swingLows.get(i)
        string state = sp.checkLevel(l1, tolerancePrice, false, bar_index, minGapBars)
        if state == "equal" and sp.time > recentEQLTime
            recentEQLTime := sp.time
            recentEQLIdx  := i

if ta.highestbars(3) == -1
    swingHighs.push(SwingPoint.new(high[1], time[1], bar_index, false))

if ta.lowestbars(3) == -1
    swingLows.push(SwingPoint.new(low[1], time[1], bar_index, false))
//#endregion


//#region[VISUALS]
if recentEQHIdx != -1
    activeHighs.mergeOrCreate(swingHighs.get(recentEQHIdx), t1, h1, tolerancePrice, true, colorEQRE)

if recentEQLIdx != -1
    activeLows.mergeOrCreate(swingLows.get(recentEQLIdx), t1, l1, tolerancePrice, false, colorEQRE)
//#endregion
````
