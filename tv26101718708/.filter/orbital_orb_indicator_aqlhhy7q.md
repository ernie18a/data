# ORBITAL ORB Indicator

- url: https://www.tradingview.com/script/AQlHHy7Q-ORBITAL-ORB-Indicator/
- type: indicator
- pine_id: PUB;0b529dce6bf046729182340821afef3a
- version: 1.0

## Description

[b]ORBITAL30100 — Opening Range Breakout Indicator[/b]

[i]See the setup before the move. Trade with structure, not instinct.[/i]

The opening range is one of the most studied patterns in institutional trading. The first hour of a session concentrates liquidity, news reaction, and directional commitment into a defined price range — and what price does after that range is established has historically been one of the most reliable signals in the market. ORBITAL30100 maps that range automatically and tells you exactly where the actionable levels are.

[b]What it does[/b]
The indicator monitors a configurable early-session window — defaulting to the first hour of the New York open — and builds the opening range in real time as the session develops. The moment the window closes, it locks the range and immediately draws everything you need: the high and low as live breakout triggers, the midpoint as a stop loss reference, take profit targets projected one full range above and below the breakout levels, and breakeven markers at the halfway point of each target. When price breaks through either boundary with a confirmed close, a signal label appears on the chart.
A live dashboard sits in the corner of your chart throughout the session, showing the exact high, low, range size, midpoint, and both take profit targets, along with the current session status — building, watching, broken, or skipped.

[b]Key features[/b]
A configurable range quality filter lets you define a minimum and maximum acceptable range size in points. Sessions where the range is too tight to trade cleanly, or too wide to manage sensibly, are automatically skipped and labelled on the chart so you know exactly why. Every visual element is individually toggleable — the box, the breakout lines, the TP levels, the breakeven markers, the midpoint line, and the signal labels — so you can keep the chart as clean or as detailed as you want. Colours are fully customisable and the dashboard can be positioned in any corner.

The indicator is built in Pine Script v6 and works across any session-based market and timeframe. The ORB window, timezone, and range filter are all configurable from the settings panel.

## Source Code

````pine
// (c) NovaIQ
// ORBITAL30100 - Opening Range Breakout Indicator v4.00
// ORB window: 8:30-9:30 AM New York time
// Shows ORB box, breakout levels, TP/SL/BE lines, signals, dashboard

//@version=6
indicator("ORBITAL30100 - ORB Indicator", shorttitle="ORBITAL30100", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ===================================================================
// INPUTS
// ===================================================================
i_orbStart  = input.session("0830-0930",       "ORB Window",       group="Session")
i_timezone  = input.string("America/New_York",  "Timezone",         group="Session",
              options=["America/New_York","Europe/London","Asia/Tokyo","America/Chicago"])

i_useFilter = input.bool(true,   "Enable range filter",             group="Range Filter")
i_minRange  = input.float(50.0,  "Min range (pts)",                 group="Range Filter", minval=0)
i_maxRange  = input.float(400.0, "Max range (pts)",                 group="Range Filter", minval=0)

i_showBox   = input.bool(true,  "Show ORB box",                    group="Display")
i_showTP    = input.bool(true,  "Show take profit levels",          group="Display")
i_showBE    = input.bool(true,  "Show breakeven levels",            group="Display")
i_showMid   = input.bool(true,  "Show midpoint / SL line",          group="Display")
i_showSig   = input.bool(true,  "Show signal labels",               group="Display")
i_tablePos  = input.string("top_right", "Table position",           group="Display",
              options=["top_right","top_left","bottom_right","bottom_left"])

i_bullColor = input.color(color.new(#26a69a, 0),     "Bullish",      group="Colors")
i_bearColor = input.color(color.new(#ef5350, 0),     "Bearish",      group="Colors")
i_boxColor  = input.color(color.new(color.blue, 88), "Box fill",     group="Colors")
i_midColor  = input.color(color.new(color.gray, 40), "Midpoint/SL",  group="Colors")
i_tpColor   = input.color(color.orange,              "Take profit",  group="Colors")

// ===================================================================
// STATE
// ===================================================================
var float orbHigh    = na
var float orbLow     = na
var float orbMid     = na
var float orbRange   = na
var bool  orbFormed  = false
var bool  orbSkipped = false
var bool  bullBreak  = false
var bool  bearBreak  = false

// ===================================================================
// DAY RESET
// ===================================================================
newDay = timeframe.change("D")

if newDay
    orbHigh    := na
    orbLow     := na
    orbMid     := na
    orbRange   := na
    orbFormed  := false
    orbSkipped := false
    bullBreak  := false
    bearBreak  := false

// ===================================================================
// BUILD ORB
// ===================================================================
inSess = not na(time(timeframe.period, i_orbStart, i_timezone))

if inSess
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

sessEnd = not inSess and inSess[1] and not orbFormed and not newDay

if sessEnd and not na(orbHigh) and not na(orbLow)
    rng = orbHigh - orbLow
    pts = rng / syminfo.mintick
    if i_useFilter and (pts < i_minRange or pts > i_maxRange)
        orbSkipped := true
    else
        orbRange  := rng
        orbMid    := orbLow + rng * 0.5
        orbFormed := true

// ===================================================================
// DRAW LEVELS
// ===================================================================
ext = bar_index + 60

if orbFormed and not orbFormed[1]
    if i_showBox
        box.new(bar_index, orbHigh, ext, orbLow,
            border_color=color.new(i_bullColor, 50),
            border_width=1, bgcolor=i_boxColor)

    line.new(bar_index, orbHigh, ext, orbHigh,
        color=i_bullColor, width=2, style=line.style_solid)
    line.new(bar_index, orbLow,  ext, orbLow,
        color=i_bearColor, width=2, style=line.style_solid)

    if i_showMid
        line.new(bar_index, orbMid, ext, orbMid,
            color=i_midColor, width=1, style=line.style_dashed)

    if i_showTP
        line.new(bar_index, orbHigh + orbRange, ext, orbHigh + orbRange,
            color=i_tpColor, width=1, style=line.style_dotted)
        line.new(bar_index, orbLow  - orbRange, ext, orbLow  - orbRange,
            color=i_tpColor, width=1, style=line.style_dotted)

    if i_showBE
        line.new(bar_index, orbHigh + orbRange * 0.5, ext, orbHigh + orbRange * 0.5,
            color=color.new(i_bullColor, 65), width=1, style=line.style_dotted)
        line.new(bar_index, orbLow  - orbRange * 0.5, ext, orbLow  - orbRange * 0.5,
            color=color.new(i_bearColor, 65), width=1, style=line.style_dotted)

// ===================================================================
// SIGNALS
// ===================================================================
bullSig = orbFormed and not orbSkipped and not bullBreak and close > orbHigh and close[1] <= orbHigh
bearSig = orbFormed and not orbSkipped and not bearBreak and close < orbLow  and close[1] >= orbLow

if bullSig
    bullBreak := true
    if i_showSig
        label.new(bar_index, low, "ORB BULL",
            style=label.style_label_up,
            color=i_bullColor, textcolor=color.white, size=size.small)

if bearSig
    bearBreak := true
    if i_showSig
        label.new(bar_index, high, "ORB BEAR",
            style=label.style_label_down,
            color=i_bearColor, textcolor=color.white, size=size.small)

if orbSkipped and not orbSkipped[1]
    label.new(bar_index, high, "SKIP - range filter",
        style=label.style_label_down,
        color=color.gray, textcolor=color.white, size=size.tiny)

// ===================================================================
// PLOTS
// ===================================================================
plotshape(bullSig, "Bull", shape.triangleup,   location.belowbar, i_bullColor, size=size.small)
plotshape(bearSig, "Bear", shape.triangledown, location.abovebar, i_bearColor, size=size.small)
bgcolor(inSess ? color.new(color.blue, 92) : na, title="ORB window")

// ===================================================================
// DASHBOARD
// ===================================================================
// Helper: format a float as string or dash if na - must be at top level
f(v, fmt) => na(v) ? "-" : str.tostring(v, fmt)

tPos = i_tablePos == "top_right"    ? position.top_right    :
       i_tablePos == "top_left"     ? position.top_left     :
       i_tablePos == "bottom_right" ? position.bottom_right :
       position.bottom_left

var table t = table.new(tPos, 2, 9,
    border_color=chart.fg_color, border_width=1,
    frame_color=chart.fg_color, frame_width=1)

if barstate.islast
    C0 = color.new(chart.bg_color, 0)
    C1 = color.new(chart.bg_color, 15)
    FG = chart.fg_color
    GR = color.gray

    table.cell(t, 0, 0, "ORBITAL30100  v4.00",
        text_color=FG, bgcolor=C0,
        text_size=size.small, text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

    table.cell(t, 0, 1, "ORB High",    text_color=GR, bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 1, f(orbHigh, format.mintick),
        text_color=i_bullColor, bgcolor=C1, text_size=size.tiny)

    table.cell(t, 0, 2, "ORB Low",     text_color=GR, bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 2, f(orbLow, format.mintick),
        text_color=i_bearColor, bgcolor=C1, text_size=size.tiny)

    table.cell(t, 0, 3, "Range pts",   text_color=GR, bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 3, na(orbRange) ? "-" : str.tostring(math.round(orbRange / syminfo.mintick)),
        text_color=FG, bgcolor=C1, text_size=size.tiny)

    table.cell(t, 0, 4, "Mid / SL",    text_color=GR, bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 4, f(orbMid, format.mintick),
        text_color=i_midColor, bgcolor=C1, text_size=size.tiny)

    table.cell(t, 0, 5, "Bull TP",     text_color=GR, bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 5, na(orbHigh) ? "-" : str.tostring(orbHigh + orbRange, format.mintick),
        text_color=i_tpColor, bgcolor=C1, text_size=size.tiny)

    table.cell(t, 0, 6, "Bear TP",     text_color=GR, bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 6, na(orbLow) ? "-" : str.tostring(orbLow - orbRange, format.mintick),
        text_color=i_tpColor, bgcolor=C1, text_size=size.tiny)

    sStr = orbSkipped        ? "SKIPPED"    :
           not orbFormed and inSess ? "BUILDING"   :
           not orbFormed     ? "WAITING"    :
           bullBreak         ? "BULL BREAK" :
           bearBreak         ? "BEAR BREAK" : "WATCHING"

    sClr = orbSkipped   ? GR          :
           bullBreak    ? i_bullColor  :
           bearBreak    ? i_bearColor  :
           orbFormed    ? color.orange : GR

    table.cell(t, 0, 7, "Status",      text_color=GR,   bgcolor=C1, text_size=size.tiny)
    table.cell(t, 1, 7, sStr,          text_color=sClr, bgcolor=C1, text_size=size.tiny)

    table.cell(t, 0, 8, "(c) NovaIQ",
        text_color=color.new(GR, 50), bgcolor=C0,
        text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(t, 0, 8, 1, 8)
````
