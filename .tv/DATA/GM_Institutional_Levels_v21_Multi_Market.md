<!-- tradingview-pine-id: PUB;d52f54043c4e44c0be48bd90dbc135b7 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# GM Institutional Levels v2.1 - Multi Market

Source: https://www.tradingview.com/script/ry7ZH6VE-GM-Institutional-Levels/

## Description

GM Institutional Levels is a clean price-level indicator designed to highlight important psychological market levels where price may react, pause, reject or break through.

The indicator was originally built from my round-number logic on USDNOK and later adapted for Gold and other markets.

It separates levels into:

Minor Institutional Levels
Major Institutional Levels

For Gold, the default structure uses:

$50 Minor Institutional Levels
$100 Major Institutional Levels

The indicator also includes presets for Gold, Forex, Indices, Crypto and Custom markets, together with price labels, a dashboard and optional alerts when price approaches or crosses an important level.

These levels are not automatic buy or sell signals. They are intended as areas to watch for confirmation from price action, market structure, FVG/IFVG, divergence and other forms of confluence.

Main Features:

• Minor and Major Institutional Levels
• Gold, Forex, Index and Crypto presets
• Custom level spacing
• Full-chart horizontal levels
• Price labels
• Nearest-level dashboard
• Proximity alerts
• Cross alerts
• Clean and simple chart layout

The goal of GM Institutional Levels is to keep the chart simple and focus attention on important psychological price areas.

Trade the level.
Wait for confirmation.
Execute the setup.

---

## Source Code

````pine
//@version=6
indicator("GM Institutional Levels v2.1 - Multi Market", shorttitle="GM Levels 2.1", overlay=true, max_lines_count=500, max_labels_count=500)

// Original Gold/Forex/Index/Crypto 50/100 preset spacing is preserved.
// Presets are selected manually. These are price grids, not trading signals.

mode = input.string("Gold", "Preset", options=["Gold", "Forex", "Index", "Crypto", "Custom"], group="Market")

custom10 = input.float(10.0, "Custom 10 step", minval=0.00000001, group="Custom")
custom25 = input.float(25.0, "Custom 25 step", minval=0.00000001, group="Custom")
customMinor = input.float(50.0, "Custom Minor / 50 step", minval=0.00000001, group="Custom")
customMajor = input.float(100.0, "Custom Major / 100 step", minval=0.00000001, group="Custom")
customMacro = input.float(1000.0, "Custom Macro / 1000 step", minval=0.00000001, group="Custom")

float factor = mode == "Forex" ? 0.0001 : mode == "Crypto" ? 10.0 : 1.0

// Round spacing to tradable ticks; never allow a zero step.
f_step(float value) =>
    math.max(syminfo.mintick, math.round(value / syminfo.mintick) * syminfo.mintick)

float step10 = f_step(mode == "Custom" ? custom10 : 10.0 * factor)
float step25 = f_step(mode == "Custom" ? custom25 : 25.0 * factor)
float minorStep = f_step(mode == "Custom" ? customMinor : 50.0 * factor)
float majorStep = f_step(mode == "Custom" ? customMajor : 100.0 * factor)
float macroStep = f_step(mode == "Custom" ? customMacro : 1000.0 * factor)

// DISPLAY
show10 = input.bool(false, "Show 10 - Scalp", group="Display")
show25 = input.bool(false, "Show 25 - Intermediate", group="Display")
showMinor = input.bool(true, "Show 50 - Minor", group="Display")
showMajor = input.bool(true, "Show 100 - Major", group="Display")
showMacro = input.bool(true, "Show 1000 - Macro", group="Display")
showLabels = input.bool(true, "Show Price Labels", group="Display")
showScalpLabels = input.bool(true, "Show 10 / 25 Labels", group="Display")
showDashboard = input.bool(true, "Show Dashboard", group="Display")

// Five groups * (2 * 49 + 1) = 495 objects maximum.
levelsEachSide = input.int(10, "Levels Above / Below PER GROUP", minval=1, maxval=49, group="Display")

// COLORS
// Auto uses chart background; Manual preserves the selected line colors.
theme = input.string("Auto", "Color Theme", options=["Auto", "Dark", "Light", "Manual"], group="Colors")

manual10 = input.color(color.white, "10 Color (Manual)", group="Colors")
manual25 = input.color(color.aqua, "25 Color (Manual)", group="Colors")
manualMinor = input.color(color.yellow, "50 Color (Manual)", group="Colors")
manualMajor = input.color(color.red, "100 Color (Manual)", group="Colors")
manualMacro = input.color(color.fuchsia, "1000 Color (Manual)", group="Colors")

// Relative luminance: choose the higher-contrast black or white label text.
f_channel(float channel) =>
    float v = channel / 255.0
    v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4)

f_luma(color col) =>
    0.2126 * f_channel(color.r(col)) + 0.7152 * f_channel(color.g(col)) + 0.0722 * f_channel(color.b(col))

f_text(color bg) =>
    f_luma(bg) > 0.179 ? color.black : color.white

bool dark = theme == "Dark" or ((theme == "Auto" or theme == "Manual") and f_luma(chart.bg_color) < 0.179)

color panelBg = dark ? color.rgb(24, 27, 34) : color.rgb(245, 247, 250)
color panelText = f_text(panelBg)

color color10 = theme == "Manual" ? manual10 : dark ? color.rgb(205, 210, 220) : color.rgb(70, 75, 85)
color color25 = theme == "Manual" ? manual25 : dark ? color.aqua : color.rgb(0, 105, 125)
color minorColor = theme == "Manual" ? manualMinor : dark ? color.yellow : color.rgb(130, 90, 0)
color majorColor = theme == "Manual" ? manualMajor : dark ? color.rgb(255, 75, 95) : color.rgb(180, 20, 45)
color macroColor = theme == "Manual" ? manualMacro : dark ? color.fuchsia : color.rgb(140, 25, 165)

// ALERT SETTINGS
enable10Alerts = input.bool(false, "10 Scalp Level Alerts", group="Alerts")
enable25Alerts = input.bool(false, "25 Level Alerts", group="Alerts")
enableMinorAlerts = input.bool(false, "50 Minor Level Alerts", group="Alerts")
enableMajorAlerts = input.bool(true, "100 Major Level Alerts", group="Alerts")
enableMacroAlerts = input.bool(false, "1000 Macro Level Alerts", group="Alerts")

useNear = input.bool(true, "Near Level Alerts", group="Alerts")
useTouch = input.bool(false, "Touch / Wick Alerts", group="Alerts")
useBreak = input.bool(true, "Close Above / Below Alerts", group="Alerts")

distanceMode = input.string("Price units", "Near Distance Mode", options=["Price units", "Percent of step"], group="Alerts")
alertDistance = input.float(1.0, "Near Distance (price units, NOT pips)", minval=0.0, group="Alerts")
distancePct = input.float(5.0, "Near Distance (% of each step)", minval=0.0, maxval=49.0, group="Alerts")
confirmedOnly = input.bool(false, "Near / Touch: Wait For Candle Close", group="Alerts")

// Break alerts always require a confirmed close.
// Display switches and alert switches are independent.
// Select "Any alert() function call" for all enabled events with actual prices.
// Intrabar deduplication: at most one event per group + event type per candle.

// HELPERS
f_format(float value) =>
    str.tostring(value, format.mintick)

f_nearest(float step) =>
    math.round(close / step) * step

// DRAWING OBJECTS
var array<line> levelLines = array.new<line>()
var array<label> levelLabels = array.new<label>()
var array<int> drawnTicks = array.new<int>()

f_clear() =>
    while array.size(levelLines) > 0
        line.delete(array.pop(levelLines))
    while array.size(levelLabels) > 0
        label.delete(array.pop(levelLabels))
    array.clear(drawnTicks)

// Draw higher-priority groups first. Deduplicate only actually drawn prices,
// so a disabled or out-of-range group cannot leave holes in a smaller grid.
f_draw(bool enabled, float step, color col, int width, string name) =>
    if enabled
        float anchor = f_nearest(step)
        for i = -levelsEachSide to levelsEachSide
            int tick = int(math.round((anchor + i * step) / syminfo.mintick))
            float price = tick * syminfo.mintick

            if not array.includes(drawnTicks, tick)
                array.push(drawnTicks, tick)

                array.push(levelLines, line.new(x1=bar_index, y1=price, x2=bar_index + 1, y2=price, xloc=xloc.bar_index, extend=extend.both, color=col, width=width))

                if showLabels and (showScalpLabels or (name != "10" and name != "25"))
                    array.push(levelLabels, label.new(x=chart.left_visible_bar_time, y=price, xloc=xloc.bar_time, text=name + " | " + f_format(price), style=label.style_label_left, color=color.new(col, 0), textcolor=f_text(col), size=size.tiny))

if barstate.islast
    f_clear()
    f_draw(showMacro, macroStep, macroColor, 4, "1000")
    f_draw(showMajor, majorStep, majorColor, 3, "100")
    f_draw(showMinor, minorStep, minorColor, 2, "50")
    f_draw(show25, step25, color25, 1, "25")
    f_draw(show10, step10, color10, 1, "10")

// ALERT LOGIC
// Integer tick arithmetic avoids floating-point errors at grid boundaries.
f_events(float step) =>
    int s = int(math.round(step / syminfo.mintick))
    int ct = int(math.round(close / syminfo.mintick))
    int pt = int(math.round(close[1] / syminfo.mintick))
    int lo = int(math.round(low / syminfo.mintick))
    int hi = int(math.round(high / syminfo.mintick))

    float distance = distanceMode == "Price units" ? alertDistance : step * distancePct / 100.0

    int nt = int(math.round(float(ct) / s)) * s
    int pnt = int(math.round(float(pt) / s)) * s

    bool nearNow = math.abs(ct - nt) * syminfo.mintick <= distance
    bool wasNear = not na(pt) and math.abs(pt - pnt) * syminfo.mintick <= distance
    bool proximityReady = not confirmedOnly or barstate.isconfirmed
    bool nearEvent = proximityReady and nearNow and (not wasNear or nt != pnt)

    // A gap over a level without that level inside this candle is NOT a touch.
    int touched = int(math.ceil(float(lo) / s)) * s
    bool touchEvent = proximityReady and touched <= hi

    // Strict close beyond a boundary; closing exactly ON it is not a break.
    int upLevel = int(math.floor(float(ct - 1) / s)) * s
    int downLevel = int(math.ceil(float(ct + 1) / s)) * s

    bool upEvent = barstate.isconfirmed and not na(pt) and ct > pt and pt <= upLevel
    bool downEvent = barstate.isconfirmed and not na(pt) and ct < pt and pt >= downLevel

    [nearEvent, touchEvent, upEvent, downEvent, nt * syminfo.mintick, touched * syminfo.mintick, upLevel * syminfo.mintick, downLevel * syminfo.mintick]

// Remember sent events during the live candle.
varip array<bool> sent = array.new<bool>(20, false)

if barstate.isnew
    array.fill(sent, false)

array<string> messages = array.new<string>()

f_emit(int slot, bool event, string groupName, string action, float level) =>
    if barstate.isrealtime and event and not array.get(sent, slot)
        array.set(sent, slot, true)
        array.push(messages, groupName + " " + action + " " + f_format(level))

// 10 SCALP ALERTS
[nearScalp10, touchScalp10, upScalp10, downScalp10, nearestScalp10, touchedScalp10, upperScalp10, lowerScalp10] = f_events(step10)

alertcondition(enable10Alerts and useNear and nearScalp10, "10 Scalp: Near", "{{ticker}} 10 Scalp: Near. Close: {{close}}")
f_emit(0, enable10Alerts and useNear and nearScalp10, "10 Scalp", "Near", nearestScalp10)

alertcondition(enable10Alerts and useTouch and touchScalp10, "10 Scalp: Touch", "{{ticker}} 10 Scalp: Touch. Close: {{close}}")
f_emit(1, enable10Alerts and useTouch and touchScalp10, "10 Scalp", "Touch", touchedScalp10)

alertcondition(enable10Alerts and useBreak and upScalp10, "10 Scalp: Close Above", "{{ticker}} 10 Scalp: Close Above. Close: {{close}}")
f_emit(2, enable10Alerts and useBreak and upScalp10, "10 Scalp", "Close Above", upperScalp10)

alertcondition(enable10Alerts and useBreak and downScalp10, "10 Scalp: Close Below", "{{ticker}} 10 Scalp: Close Below. Close: {{close}}")
f_emit(3, enable10Alerts and useBreak and downScalp10, "10 Scalp", "Close Below", lowerScalp10)

// 25 ALERTS
[nearLevel25, touchLevel25, upLevel25, downLevel25, nearestLevel25, touchedLevel25, upperLevel25, lowerLevel25] = f_events(step25)

alertcondition(enable25Alerts and useNear and nearLevel25, "25: Near", "{{ticker}} 25: Near. Close: {{close}}")
f_emit(4, enable25Alerts and useNear and nearLevel25, "25", "Near", nearestLevel25)

alertcondition(enable25Alerts and useTouch and touchLevel25, "25: Touch", "{{ticker}} 25: Touch. Close: {{close}}")
f_emit(5, enable25Alerts and useTouch and touchLevel25, "25", "Touch", touchedLevel25)

alertcondition(enable25Alerts and useBreak and upLevel25, "25: Close Above", "{{ticker}} 25: Close Above. Close: {{close}}")
f_emit(6, enable25Alerts and useBreak and upLevel25, "25", "Close Above", upperLevel25)

alertcondition(enable25Alerts and useBreak and downLevel25, "25: Close Below", "{{ticker}} 25: Close Below. Close: {{close}}")
f_emit(7, enable25Alerts and useBreak and downLevel25, "25", "Close Below", lowerLevel25)

// 50 MINOR ALERTS
[nearMinor, touchMinor, upMinor, downMinor, nearestMinor, touchedMinor, upperMinor, lowerMinor] = f_events(minorStep)

alertcondition(enableMinorAlerts and useNear and nearMinor, "50 Minor: Near", "{{ticker}} 50 Minor: Near. Close: {{close}}")
f_emit(8, enableMinorAlerts and useNear and nearMinor, "50 Minor", "Near", nearestMinor)

alertcondition(enableMinorAlerts and useTouch and touchMinor, "50 Minor: Touch", "{{ticker}} 50 Minor: Touch. Close: {{close}}")
f_emit(9, enableMinorAlerts and useTouch and touchMinor, "50 Minor", "Touch", touchedMinor)

alertcondition(enableMinorAlerts and useBreak and upMinor, "50 Minor: Close Above", "{{ticker}} 50 Minor: Close Above. Close: {{close}}")
f_emit(10, enableMinorAlerts and useBreak and upMinor, "50 Minor", "Close Above", upperMinor)

alertcondition(enableMinorAlerts and useBreak and downMinor, "50 Minor: Close Below", "{{ticker}} 50 Minor: Close Below. Close: {{close}}")
f_emit(11, enableMinorAlerts and useBreak and downMinor, "50 Minor", "Close Below", lowerMinor)

// 100 MAJOR ALERTS
[nearMajor, touchMajor, upMajor, downMajor, nearestMajor, touchedMajor, upperMajor, lowerMajor] = f_events(majorStep)

alertcondition(enableMajorAlerts and useNear and nearMajor, "100 Major: Near", "{{ticker}} 100 Major: Near. Close: {{close}}")
f_emit(12, enableMajorAlerts and useNear and nearMajor, "100 Major", "Near", nearestMajor)

alertcondition(enableMajorAlerts and useTouch and touchMajor, "100 Major: Touch", "{{ticker}} 100 Major: Touch. Close: {{close}}")
f_emit(13, enableMajorAlerts and useTouch and touchMajor, "100 Major", "Touch", touchedMajor)

alertcondition(enableMajorAlerts and useBreak and upMajor, "100 Major: Close Above", "{{ticker}} 100 Major: Close Above. Close: {{close}}")
f_emit(14, enableMajorAlerts and useBreak and upMajor, "100 Major", "Close Above", upperMajor)

alertcondition(enableMajorAlerts and useBreak and downMajor, "100 Major: Close Below", "{{ticker}} 100 Major: Close Below. Close: {{close}}")
f_emit(15, enableMajorAlerts and useBreak and downMajor, "100 Major", "Close Below", lowerMajor)

// 1000 MACRO ALERTS
[nearMacro, touchMacro, upMacro, downMacro, nearestMacro, touchedMacro, upperMacro, lowerMacro] = f_events(macroStep)

alertcondition(enableMacroAlerts and useNear and nearMacro, "1000 Macro: Near", "{{ticker}} 1000 Macro: Near. Close: {{close}}")
f_emit(16, enableMacroAlerts and useNear and nearMacro, "1000 Macro", "Near", nearestMacro)

alertcondition(enableMacroAlerts and useTouch and touchMacro, "1000 Macro: Touch", "{{ticker}} 1000 Macro: Touch. Close: {{close}}")
f_emit(17, enableMacroAlerts and useTouch and touchMacro, "1000 Macro", "Touch", touchedMacro)

alertcondition(enableMacroAlerts and useBreak and upMacro, "1000 Macro: Close Above", "{{ticker}} 1000 Macro: Close Above. Close: {{close}}")
f_emit(18, enableMacroAlerts and useBreak and upMacro, "1000 Macro", "Close Above", upperMacro)

alertcondition(enableMacroAlerts and useBreak and downMacro, "1000 Macro: Close Below", "{{ticker}} 1000 Macro: Close Below. Close: {{close}}")
f_emit(19, enableMacroAlerts and useBreak and downMacro, "1000 Macro", "Close Below", lowerMacro)

// One combined message per update. Per-event varip flags prevent repeats.
// Near and touch may happen before a later confirmed close-break in the same bar.
if array.size(messages) > 0
    alert(syminfo.tickerid + " | TF " + timeframe.period + "\n" + array.join(messages, "\n"), alert.freq_all)

// DASHBOARD
var table dash = table.new(position.top_right, 3, 6, border_width=1)

f_row(int row, string name, float step, color col, bool enabled) =>
    table.cell(dash, 0, row, name + (enabled ? "" : " OFF"), text_color=f_text(col), bgcolor=color.new(col, 0))
    table.cell(dash, 1, row, f_format(step), text_color=panelText, bgcolor=panelBg)
    table.cell(dash, 2, row, f_format(f_nearest(step)), text_color=panelText, bgcolor=panelBg)

if barstate.islast
    if showDashboard
        table.cell(dash, 0, 0, mode, text_color=panelText, bgcolor=panelBg)
        table.cell(dash, 1, 0, "Step", text_color=panelText, bgcolor=panelBg)
        table.cell(dash, 2, 0, "Nearest", text_color=panelText, bgcolor=panelBg)

        f_row(1, "10 Scalp", step10, color10, show10)
        f_row(2, "25", step25, color25, show25)
        f_row(3, "50 Minor", minorStep, minorColor, showMinor)
        f_row(4, "100 Major", majorStep, majorColor, showMajor)
        f_row(5, "1000 Macro", macroStep, macroColor, showMacro)
    else
        table.clear(dash, 0, 0, 2, 5)
````
