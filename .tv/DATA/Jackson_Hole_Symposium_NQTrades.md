<!-- tradingview-pine-id: PUB;bc404b60ff91495996dfc4fc5fc84a85 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Jackson Hole Symposium [NQTrades]

Source: https://www.tradingview.com/script/L2mQJAaj/

## Description

Jackson Hole Symposium [NQTrades]

This indicator highlights the historical dates of the Jackson Hole Economic Policy Symposium directly on the chart.

The Jackson Hole Symposium is one of the most closely watched annual central banking events, bringing together policymakers, economists, academics, and financial market participants. Speeches and comments from Federal Reserve officials during the event can generate significant volatility across equities, bonds, currencies, and other financial markets.

Features
Highlights the full Jackson Hole Symposium period directly on the chart.
Includes historical editions from 2020 to 2026.
Differentiates the 2020 and 2021 virtual editions from regular symposiums.
Optional background highlighting.
Optional vertical lines marking the start and end of each symposium.
Optional labels identifying each edition.
Fully customizable colors.
Manual option to add a future Jackson Hole edition without modifying the code.
Alerts available for the start and end of the symposium period.
All event times are handled using New York time for consistency with U.S. financial markets.
Purpose

The indicator is designed as a market context tool, allowing traders to quickly identify how price behaved before, during, and after previous Jackson Hole Symposiums.

It can be particularly useful for studying volatility, liquidity, directional expansion, reversals, and market reactions around major Federal Reserve communication events.

The indicator does not generate buy or sell signals. It is intended to provide historical and contextual information to complement your own trading analysis.

Developed by NQTrades.

---

## Source Code

````pine
//@version=6
indicator("Jackson Hole Symposium [NQTrades]", shorttitle="JH Symposium", overlay=true, max_lines_count=100, max_labels_count=100)

// ── Inputs ──────────────────────────────────────────────────────────────
grpVis = "Visualization"
showBackground = input.bool(true, "Highlight symposium range (background)", group=grpVis)
showLines      = input.bool(true, "Start/end vertical lines", group=grpVis)
showLabels     = input.bool(true, "Year labels", group=grpVis)

grpCol = "Colors"
bgColor        = input.color(color.new(color.orange, 85), "Background (regular edition)", group=grpCol)
bgColorVirtual = input.color(color.new(color.gray, 85),   "Background (virtual edition 2020-21)", group=grpCol)
lineColor      = input.color(color.new(color.orange, 20), "Lines", group=grpCol)
labelColor     = input.color(color.orange,                "Label text", group=grpCol)

grpCustom = "Next edition (manual)"
enableCustom = input.bool(false, "Add a future edition manually", group=grpCustom)

// input.time() requires a const int as its default value.
// The single-string timestamp() overload returns const int, unlike the
// timestamp(timezone, year, month, day, ...) overload, which returns simple/series int.
const int DEFAULT_CUSTOM_START = timestamp("01 Jan 2027 00:00 -0500")
const int DEFAULT_CUSTOM_END   = timestamp("01 Jan 2027 23:59 -0500")

customStart = input.time(DEFAULT_CUSTOM_START, "Start", group=grpCustom)
customEnd   = input.time(DEFAULT_CUSTOM_END,   "End", group=grpCustom)
customLabel = input.string("Jackson Hole (next)", "Label", group=grpCustom)

bool customRangeValid = customEnd >= customStart

// ── Data structure ──────────────────────────────────────────────────────
type JHEvent
    string txt
    int    t1
    int    t2
    bool   virtual

var JHEvent[] events = na

if barstate.isfirst
    events := array.new<JHEvent>()

    // Known dates: start at 00:00 New York time on the first day and
    // end at 23:59 New York time on the final day.
    array.push(events, JHEvent.new("Jackson Hole 2020 (virtual)", timestamp("America/New_York", 2020, 8, 27, 0, 0), timestamp("America/New_York", 2020, 8, 28, 23, 59), true))
    array.push(events, JHEvent.new("Jackson Hole 2021 (virtual)", timestamp("America/New_York", 2021, 8, 26, 0, 0), timestamp("America/New_York", 2021, 8, 28, 23, 59), true))
    array.push(events, JHEvent.new("Jackson Hole 2022",           timestamp("America/New_York", 2022, 8, 25, 0, 0), timestamp("America/New_York", 2022, 8, 27, 23, 59), false))
    array.push(events, JHEvent.new("Jackson Hole 2023",           timestamp("America/New_York", 2023, 8, 24, 0, 0), timestamp("America/New_York", 2023, 8, 26, 23, 59), false))
    array.push(events, JHEvent.new("Jackson Hole 2024",           timestamp("America/New_York", 2024, 8, 22, 0, 0), timestamp("America/New_York", 2024, 8, 24, 23, 59), false))
    array.push(events, JHEvent.new("Jackson Hole 2025",           timestamp("America/New_York", 2025, 8, 21, 0, 0), timestamp("America/New_York", 2025, 8, 23, 23, 59), false))
    array.push(events, JHEvent.new("Jackson Hole 2026",           timestamp("America/New_York", 2026, 8, 27, 0, 0), timestamp("America/New_York", 2026, 8, 29, 23, 59), false))

    // Ignore an invalid manual range instead of creating a broken event.
    if enableCustom and customRangeValid
        array.push(events, JHEvent.new(customLabel, customStart, customEnd, false))

// ── Background shading ─────────────────────────────────────────────────
color bgColorFinal = na
bool  inRangeAny   = false

if not na(events)
    for evt in events
        if time >= evt.t1 and time <= evt.t2
            inRangeAny := true
            if showBackground
                bgColorFinal := evt.virtual ? bgColorVirtual : bgColor

bgcolor(bgColorFinal)

// ── Vertical lines and labels ──────────────────────────────────────────
// Objects are created once. xloc.bar_time places them at the event timestamps.
var label[] labels = na

if barstate.isfirst and not na(events)
    labels := array.new<label>()

    for evt in events
        evtColor = evt.virtual ? bgColorVirtual : lineColor

        if showLines
            line.new(x1=evt.t1, y1=0, x2=evt.t1, y2=1, xloc=xloc.bar_time, extend=extend.both, color=evtColor, style=line.style_dashed, width=1)
            line.new(x1=evt.t2, y1=0, x2=evt.t2, y2=1, xloc=xloc.bar_time, extend=extend.both, color=evtColor, style=line.style_dashed, width=1)

        if showLabels
            lb = label.new(x=evt.t1, y=0, xloc=xloc.bar_time, yloc=yloc.price, text=evt.txt, style=label.style_label_down, color=color.new(evtColor, 0), textcolor=labelColor, size=size.small)
            array.push(labels, lb)

// Keep labels above the highest visible historical price reached by the script.
var float runningHigh = high
runningHigh := math.max(runningHigh, high)

if showLabels and not na(labels)
    for lb in labels
        label.set_y(lb, runningHigh * 1.01)

// ── Alerts ─────────────────────────────────────────────────────────────
var bool prevInRange = false
bool startEvent = inRangeAny and not prevInRange
bool endEvent   = not inRangeAny and prevInRange
prevInRange := inRangeAny

alertcondition(startEvent, title="Jackson Hole Start", message="Jackson Hole Symposium has started")
alertcondition(endEvent,   title="Jackson Hole End",   message="Jackson Hole Symposium has ended")
````
