# Divider [odnac]

- url: https://www.tradingview.com/script/rA0I7MWy/
- type: indicator
- pine_id: PUB;48345f1b05784776aae1ef0e7284f2fa
- version: 6.0

## Description

📌 Overview
Auto Divider automatically detects the current chart timeframe and draws vertical divider lines at higher timeframe boundaries.
For example, on a 1-minute chart it draws a line every 15 minutes, and on a 1-hour chart it marks each daily boundary — giving you a clear visual reference of the higher timeframe structure without switching charts.


✅ Features
[b]Automatic Timeframe Detection[/b]
Automatically recognizes the current chart timeframe and applies the corresponding settings. No manual timeframe selection needed.

[b]Custom Divider Interval[/b]
For each supported timeframe (1m / 5m / 15m / 1h / 4h / Daily / Weekly), you can independently choose which higher timeframe boundary to use as the divider.

[b]Future Divider Prediction[/b]
Calculates and displays where the next divider line will appear based on the current bar, so you always know how far the next boundary is.

[b]Exception Timeframe Support[/b]
Timeframes not in the default list (e.g. 2m, 3m, 45m, 2h) are handled by a dedicated exception setting, so the indicator works on any chart.

[b]Style Customization[/b]
Line color, style (solid / dashed / dotted), and width are fully customizable.


📐 Supported Timeframes & Defaults
Chart Timeframe - Default Divider Basis
1m - 15m
5m - 1h
15m - 4h
1h - D1
4h - W1
Daily - M1
Weekly - Y1
Exception - 1h (customizable)

[image]https://www.tradingview.com/x/98bskNRC/[/image][image]https://www.tradingview.com/x/BHcccGSD/[/image]

## Source Code

````pine
//@version=6
indicator("Divider [odnac]", overlay = true, max_lines_count = 500)

var string GEX  = "⚠️ Exception Timeframe"
var string G1   = "1m Settings"
var string G5   = "5m Settings"
var string G15  = "15m Settings"
var string G60  = "1h Settings"
var string G240 = "4h Settings"
var string GD   = "Daily Settings"
var string GW   = "Weekly Settings"
var string GST  = "🎨 Style"
var string GGEN = "⚙️ General"

// ─── General ──────────────────────────────────────────────────────────────────
showWeekend = input.bool(true, title = "Show Weekend", group = GGEN, display = display.all - display.status_line)
showFuture = input.bool(true, title = "Show Next Divider", group = GGEN, display = display.all - display.status_line)

// ─── Style ────────────────────────────────────────────────────────────────────
lineColor      = input.color(color.rgb(255, 255, 255, 80), title = "Line Color", group = GST, display = display.all - display.status_line)
lineStyleInput = input.string("Dotted (···)", title = "Line Style", options = ["Solid (───)", "Dashed (---)", "Dotted (···)"], group = GST, display = display.all - display.status_line)
lineWidth      = input.int(1, title = "Line Width", minval = 1, maxval = 4, group = GST, display = display.all - display.status_line)

// ─── Exception Timeframe ──────────────────────────────────────────────────────
useEx = input.bool(true,      title = "Enable", group = GEX,
        tooltip = "Applied when the current chart is not 1m/5m/15m/1h/4h/Daily/Weekly", display = display.all - display.status_line)
divEx = input.string("1h", title = "Divider Basis", group = GEX,
        options = ["15m","1h","4h","D1","W1","M1","Y1"],
        tooltip = "Select the divider interval to use for exception timeframes.", display = display.all - display.status_line)

// ─── Timeframe Settings ───────────────────────────────────────────────────────
use1m = input.bool(true,    title = "Enable", group = G1, display = display.all - display.status_line)
div1m = input.string("15m", title = "Divider Basis", group = G1, options = ["15m","1h","4h","D1","W1","M1"], display = display.all - display.status_line)

use5m = input.bool(true,   title = "Enable", group = G5, display = display.all - display.status_line)
div5m = input.string("1h", title = "Divider Basis", group = G5, options = ["15m","1h","4h","D1","W1","M1"], display = display.all - display.status_line)

use15m = input.bool(true,   title = "Enable", group = G15, display = display.all - display.status_line)
div15m = input.string("4h", title = "Divider Basis", group = G15, options = ["15m","1h","4h","D1","W1","M1"], display = display.all - display.status_line)

use60m = input.bool(true,   title = "Enable", group = G60, display = display.all - display.status_line)
div60m = input.string("D1", title = "Divider Basis", group = G60, options = ["4h","D1","W1","M1"], display = display.all - display.status_line)

use240m = input.bool(true,   title = "Enable", group = G240, display = display.all - display.status_line)
div240m = input.string("W1", title = "Divider Basis", group = G240, options = ["D1","W1","M1"], display = display.all - display.status_line)

useD = input.bool(true,   title = "Enable", group = GD, display = display.all - display.status_line)
divD = input.string("M1", title = "Divider Basis", group = GD, options = ["W1","M1"], display = display.all - display.status_line)

useW = input.bool(true,   title = "Enable", group = GW, display = display.all - display.status_line)
divW = input.string("Y1", title = "Divider Basis", group = GW, options = ["M1","Y1"], display = display.all - display.status_line)

// ─── Line Style ─────────────────
var string lineStyle = lineStyleInput == "Solid (───)"  ? line.style_solid  :
                         lineStyleInput == "Dotted (···)" ? line.style_dotted :
                         line.style_dashed

// ─── Resolve Active Settings for Current Timeframe ───────────────────────────
var bool   isActive = false
var string divSel   = "D1"

if barstate.isfirst
    if timeframe.isweekly
        isActive := useW,   divSel := divW
    else if timeframe.isdaily
        isActive := useD,   divSel := divD
    else if timeframe.isintraday
        switch timeframe.multiplier
            1   => isActive := use1m,   divSel := div1m
            5   => isActive := use5m,   divSel := div5m
            15  => isActive := use15m,  divSel := div15m
            60  => isActive := use60m,  divSel := div60m
            240 => isActive := use240m, divSel := div240m
            =>     isActive := useEx,   divSel := divEx

// ─── Weekend Filter ───────────────────────────────────────────────────────────
isWeekendBar = dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday
weekendOK    = showWeekend or not isWeekendBar

// ─── Historical Dividers ──────────────────────────────────────────────────────
if isActive
    bool trigger = switch divSel
        "15m" => timeframe.change("15")
        "1h"  => timeframe.change("60")
        "4h"  => timeframe.change("240")
        "D1"  => timeframe.change("D")
        "W1"  => timeframe.change("W")
        "M1"  => timeframe.change("M")
        "Y1"  => timeframe.change("12M")
        =>       false

    if trigger and weekendOK
        line.new(bar_index, close + syminfo.mintick, bar_index, close - syminfo.mintick,
                 color = lineColor, width = lineWidth, extend = extend.both, style = lineStyle)

// ─── Next (Future) Divider ────────────────────────────────────────────────────
string divTf = switch divSel
    "15m" => "15"
    "1h"  => "60"
    "4h"  => "240"
    "D1"  => "D"
    "W1"  => "W"
    "M1"  => "M"
    "Y1"  => "12M"
    =>       "15"

int nextDivT = time_close(divTf)

var line futureLine = na
if barstate.islast
    line.delete(futureLine)
    futureLine := na
    if isActive and showFuture and not na(nextDivT)
        futureLine := line.new(nextDivT, close + syminfo.mintick, nextDivT, close - syminfo.mintick,
                     xloc = xloc.bar_time, extend = extend.both,
                     color = lineColor, width = lineWidth, style = lineStyle)
````
