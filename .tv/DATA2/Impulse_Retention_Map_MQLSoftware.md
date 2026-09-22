<!-- tradingview-pine-id: PUB;1ddc4c5c30fe410c8c3a3d9478ef6dbf -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Impulse Retention Map [MQLSoftware]

Source: https://www.tradingview.com/script/lLMPIQx0-Impulse-Retention-Map-MQLSoftware/

## Description

OVERVIEW

Impulse Retention Map shows how much of a sharp price move remains after it forms. It automatically fixes the move's origin, halfway level and closing endpoint, then follows subsequent closes to distinguish a partial retracement, a full unwind and a recovery after a deep retracement.

The question is simple: has price kept the move, given half of it back, or returned all the way to its origin? No manual anchors, external signal source or volume feed are required.

DETECTION AND ORIGINAL CONTRIBUTION

The script measures a short close-to-close displacement. With the default settings, a qualifying impulse must satisfy all of these conditions:

1. The absolute change from the close three bars earlier to the current close is at least 2.0 times ATR, with a minimum size of two price ticks. The 20-bar ATR reading is taken at the origin bar, before the three subsequent price changes being measured. The move therefore does not increase its own volatility benchmark.
2. Path efficiency is at least 0.75: the absolute net change divided by the sum of the three absolute close-to-close changes. A reading of 1 means no closing-price retracement inside the window.
3. The final close is in the directional outer 30% of the impulse window's high-low range: near the high for an upward move or near the low for a downward move.

ATR scaling, path efficiency and halfway retracements are established concepts. The contribution here is their use in one automatic, frozen displacement episode: detection uses a pre-window volatility reference, the resulting map has fixed price boundaries, and the subsequent close-based events follow an explicit lifecycle. It measures a short move's retention rather than constructing pivot-based trend waves, projecting reversal targets or evaluating signals supplied by another indicator.

A map is admitted on the first qualifying bar of a fresh directional burst, subject to spacing of at least one impulse window since the previous admission. Consecutive qualifying bars in the same direction do not create repeated maps. A burst blocked by the spacing rule is not queued for later admission. A newly admitted map replaces any still-active previous map; replacement is not treated as a successful outcome.

READING THE MAP

The three fixed references are:

100% — the close at which the impulse was detected.
50% — halfway between that close and the origin.
0% — the closing price at the beginning of the measured move.

Move retained (%) = 100 x (evaluated close - origin) / (impulse close - origin).

The same formula works for upward and downward impulses. For an upward move from 100 to 110, a later close at 107 retains 70%; a close at 112 retains 120%. Values above 100% describe extension beyond the original move. Values below 0% mean price closed beyond the origin in the opposite direction. These percentages are price-distance measurements, not success rates or probabilities.

Teal identifies upward impulses and rose identifies downward impulses. The half between the impulse close and midpoint uses the direction colour; the half between midpoint and origin uses a quieter amber tint. These are measurement areas, not prescribed entry, stop or target zones.

The UP/DOWN label reports the initial move in units of its pre-impulse ATR. The status panel shows retained movement, the lowest retained reading observed on a confirmed close since detection, the original price distance, the initial ATR multiple and the number of bars tracked. When an episode finishes, the panel shows a final snapshot until a new map is admitted.

EVENTS AND LIFECYCLE

Subsequent evaluation starts on the bar after detection. The impulse's own formation bars cannot supply a later outcome.

HALF BACK — the first subsequent close retains 50% or less, but remains above 0%.

UNWOUND — a close retains 0% or less. Tracking ends. A direct jump through the origin is recorded as UNWOUND without inventing an earlier HALF BACK event.

RECOVERED — after a HALF BACK event, a later close reaches or exceeds 100% retention. Tracking ends. This does not mean the entire intervening path held above the halfway line.

EXPIRED — the tracking limit is reached without an earlier terminal outcome; 60 bars by default. An unwind or recovery on the final allowed bar takes precedence over expiry.

REPLACED — a fresh qualifying impulse is admitted while the earlier map is still active. The earlier map stops at that bar. Its final status is available in the original impulse label's tooltip and as an event in the Data Window. Expiry also has a Data Window event; neither creates a separate outcome label on the chart.

Between events, the panel can show NEW IMPULSE, HOLDING, EXTENDED, DEEP RETRACE or REBUILDING. REBUILDING means a map that previously returned at least half has moved back above 50% but has not yet recovered the full original move.

The old episode is evaluated before a new one is admitted. Consequently, an outcome for the old map and a new impulse can occur on the same closed bar.

CONFIRMED BARS AND DISPLAY CHANGES

Detection, retained readings, outcome flags and alerts update only on confirmed chart bars. The script uses no higher-timeframe requests, future-bar data, pivots or backward-shifted event markers. A map starts at the detection bar, although its origin price comes from the earlier close. It is not drawn across the formation window as if it had been known then.

The display does evolve: an active map extends to each newly confirmed bar; finishing a map dims its existing drawings and updates its tooltip; older maps and their outcome labels are removed as the retention limits are reached. The latest reference labels move with the chart's right edge. These presentation changes do not move the recorded event bars or change a map's fixed price boundaries. They also mean the final historical appearance is not a literal recording of how bright each zone looked at every earlier moment.

Changing inputs, symbol, timeframe, feed or available history recalculates the script. Provider corrections and price adjustments can change past input data. Closed-bar processing does not prevent those external changes.

SETTINGS AND ALERTS

Detection controls the impulse window, minimum ATR-scaled move, minimum path efficiency, ATR baseline length and tracking duration. Defaults are 3 bars, 2.0 ATR, 0.75 efficiency, 20-bar ATR and a 60-bar tracking limit. The directional closing-location filter stays fixed at 70%.

Display controls how many maps remain visible (six by default), outcome labels, the status panel and its position, latest-map reference labels, and colours. Display settings do not alter detection or outcomes. The panel distinguishes initial warmup, unavailable price data, a flat price range and waiting for a qualifying move when no map has yet been created.

Five alert conditions are available: new up impulse, new down impulse, half of impulse returned, impulse fully unwound, and impulse recovered. Create the desired TradingView alert and select Once Per Bar Close. Alerts must be configured by the user; adding the indicator does not create them automatically.

USE AND LIMITATIONS

Add the indicator to a standard candlestick chart and read the latest fixed references alongside the panel. Higher movement or efficiency thresholds generally select fewer impulses. The parameters are heuristic filters, not optimized probabilities. The tool can use price data across crypto, forex, indices and stocks; it does not require traded or tick volume.

Only closes resolve the tracked outcomes. A wick through halfway or origin that closes back beyond it does not establish the corresponding close-based event. Session gaps are included in close-to-close displacement and can qualify as impulses. The script does not reconstruct intrabar order, identify participants, estimate order flow or distinguish a session gap from continuously traded movement.

Only one episode is active at a time. New impulses can replace unresolved ones, so the displayed map history is not a complete sample of every possible retracement. No aggregate win rate, trading expectancy, order fills, fees, slippage or profitability backtest is calculated. Synthetic chart types produce measurements of synthetic prices and should not be interpreted as execution-price evidence.

This is a descriptive chart-analysis tool, not a prediction of recovery or a recommendation to enter or exit a position.

---

## Source Code

````pine
// This Source Code Form is subject to the Mozilla Public License, v. 2.0.
// https://mozilla.org/MPL/2.0/  Copyright MQLSoftware.
//@version=6
indicator("Impulse Retention Map [MQLSoftware]", shorttitle="MQLSoftware - Impulse Retention Map", overlay=true, behind_chart=false, max_bars_back=500, max_boxes_count=60, max_lines_count=60, max_labels_count=120)

// Close-to-close displacement, not order flow. A new map starts when detected,
// never at the earlier origin bar. ATR is sampled BEFORE the impulse window.
// All prices, state transitions and alerts use confirmed chart bars only.
string G1 = "Detection"
int span = input.int(3, "Impulse window (bars)", minval=1, maxval=12, group=G1)
float minMove = input.float(2.0, "Minimum move / pre-impulse ATR", minval=0.5, maxval=8, step=0.1, group=G1)
float minEff = input.float(0.75, "Minimum path efficiency", minval=0.3, maxval=1.0, step=0.05, group=G1, tooltip="Absolute net close-to-close move divided by the sum of absolute close changes. 1 means no closing-price retracement inside the window.")
int atrLen = input.int(20, "ATR baseline", minval=5, maxval=100, group=G1)
int life = input.int(60, "Track for at most (bars)", minval=5, maxval=250, group=G1)
string G2 = "Display"
int keep = input.int(6, "Maps to keep", minval=1, maxval=20, group=G2)
bool marks = input.bool(true, "Outcome labels", group=G2)
bool panelOn = input.bool(true, "Status panel", group=G2)
string panelPlace = input.string("Bottom left", "Panel position", options=["Bottom left", "Top right", "Bottom right"], group=G2)
bool rails = input.bool(true, "Latest map price labels", group=G2)
color upCol = input.color(#26C6AD, "Up impulse", group=G2, inline="c")
color dnCol = input.color(#EA7884, "Down impulse", group=G2, inline="c")
color halfCol = input.color(#D8AE63, "Half returned", group=G2, inline="c")
color textCol = #DDE3EC
color muted = #8794A8
color bg = #101722

type Map
    int born
    int dir
    float origin
    float tip
    float atrSize
    float retained
    float worst
    int age
    bool halfSeen
    bool active
    string status
    box strong
    box weak
    line mid
    label tag

var array<Map> maps = array.new<Map>()
var array<label> events = array.new<label>()
var int lastBorn = na
var int priorCandidate = 0
float baseAtr = ta.atr(atrLen)[span]
float delta = close - close[span]
float path = math.sum(math.abs(ta.change(close)), span)
float winHigh = ta.highest(high, span)
float winLow = ta.lowest(low, span)
float winRange = winHigh - winLow
bool valid = not na(close) and not na(high) and not na(low) and not na(close[span]) and not na(path)
bool ready = valid and not na(baseAtr) and baseAtr > 0 and winRange > 0
float eff = ready and path > 0 ? math.abs(delta) / path : 0.0
int direction = delta > 0 ? 1 : delta < 0 ? -1 : 0
float location = ready ? (direction > 0 ? close - winLow : winHigh - close) / winRange : 0.0
bool qualified = ready and math.abs(delta) >= math.max(minMove * baseAtr, syminfo.mintick * 2) and eff >= minEff and location >= 0.7
int candidate = qualified ? direction : 0

bool newUp = false
bool newDn = false
bool halfEvent = false
bool unwindEvent = false
bool recoverEvent = false
bool expireEvent = false
bool replaceEvent = false

eventMark(float y, string msg, color col, bool above) =>
    if marks
        label e = label.new(bar_index, y, msg, style=above ? label.style_label_down : label.style_label_up, color=color.new(bg, 8), textcolor=col, size=size.small)
        array.push(events, e)
        if array.size(events) > 60
            label.delete(array.shift(events))

retire(Map m) =>
    box.set_bgcolor(m.strong, color.new(m.dir > 0 ? upCol : dnCol, 94))
    box.set_bgcolor(m.weak, color.new(halfCol, 96))
    box.set_border_color(m.strong, color.new(m.dir > 0 ? upCol : dnCol, 75))
    box.set_border_color(m.weak, color.new(halfCol, 82))
    line.set_color(m.mid, color.new(halfCol, 72))
    label.set_tooltip(m.tag, m.status + " | Final retained: " + str.tostring(m.retained * 100, "#.0") + "% of original move | Worst close: " + str.tostring(m.worst * 100, "#.0") + "% | Bars: " + str.tostring(m.age))

if barstate.isconfirmed
    // Process the old map before admitting a new one. The detection bar itself
    // never supplies a future outcome. Wick order is never inferred from OHLC.
    if array.size(maps) > 0
        Map m = array.last(maps)
        if m.active
            m.age := bar_index - m.born
            box.set_right(m.strong, bar_index)
            box.set_right(m.weak, bar_index)
            line.set_x2(m.mid, bar_index)
            if valid
                m.retained := (close - m.origin) / (m.tip - m.origin)
                m.worst := math.min(m.worst, m.retained)
                if m.retained <= 0
                    m.status := "UNWOUND"
                    m.active := false
                    unwindEvent := true
                    eventMark(close, "UNWOUND", dnCol, m.dir > 0)
                else if m.halfSeen and m.retained >= 1
                    m.status := "RECOVERED"
                    m.active := false
                    recoverEvent := true
                    eventMark(close, "RECOVERED", upCol, m.dir < 0)
                else if not m.halfSeen and m.retained <= 0.5
                    m.halfSeen := true
                    halfEvent := true
                    eventMark(close, "HALF BACK", halfCol, m.dir > 0)
                if m.active
                    m.status := m.retained <= 0.5 ? "DEEP RETRACE" : m.halfSeen ? "REBUILDING" : m.retained >= 1 ? "EXTENDED" : "HOLDING"
            if m.active and m.age >= life
                m.status := "EXPIRED"
                m.active := false
                expireEvent := true
            if not m.active
                retire(m)

    // One admission per fresh qualifying burst, non-overlapping detection
    // windows. A newer burst retires the previous map as REPLACED, never as a win.
    bool fresh = candidate != 0 and candidate != priorCandidate
    bool spaced = na(lastBorn) or bar_index - lastBorn >= span
    if fresh and spaced
        if array.size(maps) > 0
            Map old = array.last(maps)
            if old.active
                old.active := false
                old.status := "REPLACED"
                replaceEvent := true
                retire(old)
        float origin = close[span]
        float tip = close
        float middle = (origin + tip) * 0.5
        color col = direction > 0 ? upCol : dnCol
        box strong = box.new(bar_index, math.max(tip, middle), bar_index, math.min(tip, middle), border_color=color.new(col, 35), bgcolor=color.new(col, 86))
        box weak = box.new(bar_index, math.max(origin, middle), bar_index, math.min(origin, middle), border_color=color.new(halfCol, 55), bgcolor=color.new(halfCol, 94))
        line mid = line.new(bar_index, middle, bar_index, middle, color=color.new(halfCol, 20), style=line.style_dashed)
        label tag = label.new(bar_index, tip, (direction > 0 ? "UP " : "DOWN ") + str.tostring(math.abs(delta) / baseAtr, "#.0") + " ATR", style=direction > 0 ? label.style_label_down : label.style_label_up, color=color.new(col, 12), textcolor=bg, size=size.small)
        Map m = Map.new(bar_index, direction, origin, tip, math.abs(delta) / baseAtr, 1.0, 1.0, 0, false, true, "NEW IMPULSE", strong, weak, mid, tag)
        array.push(maps, m)
        if array.size(maps) > keep
            Map first = array.shift(maps)
            box.delete(first.strong)
            box.delete(first.weak)
            line.delete(first.mid)
            label.delete(first.tag)
            int oldest = array.first(maps).born
            while array.size(events) > 0
                if label.get_x(array.first(events)) < oldest
                    label.delete(array.shift(events))
                else
                    break
        lastBorn := bar_index
        newUp := direction > 0
        newDn := direction < 0
    priorCandidate := candidate

var label tipLabel = label.new(na, na, "", style=label.style_label_right, color=color.new(bg, 10), size=size.small)
var label midLabel = label.new(na, na, "", style=label.style_label_right, color=color.new(bg, 10), size=size.small)
var label originLabel = label.new(na, na, "", style=label.style_label_right, color=color.new(bg, 10), size=size.small)
var table hud = table.new(panelPlace == "Top right" ? position.top_right : panelPlace == "Bottom right" ? position.bottom_right : position.bottom_left, 2, 7, bgcolor=bg, border_color=#253143, border_width=1)

if barstate.islast
    if panelOn
        table.cell(hud, 0, 0, "IMPULSE RETENTION", text_color=textCol, text_size=size.small)
        table.cell(hud, 1, 0, "CLOSED BARS", text_color=muted, text_size=size.tiny)
    if array.size(maps) > 0
        Map m = array.last(maps)
        color col = m.dir > 0 ? upCol : dnCol
        if panelOn
            table.cell(hud, 0, 1, m.dir > 0 ? "UP IMPULSE" : "DOWN IMPULSE", text_color=col, text_size=size.small)
            table.cell(hud, 1, 1, m.status, text_color=m.active ? (m.retained <= 0.5 ? halfCol : col) : muted, text_size=size.small)
            table.cell(hud, 0, 2, "Move retained", text_color=textCol, text_size=size.small)
            table.cell(hud, 1, 2, str.tostring(m.retained * 100, "#.0") + "%", text_color=m.retained <= 0.5 ? halfCol : col, text_size=size.large)
            table.cell(hud, 0, 3, "Worst close", text_color=muted, text_size=size.small)
            table.cell(hud, 1, 3, str.tostring(m.worst * 100, "#.0") + "% retained", text_color=muted, text_size=size.small)
            table.cell(hud, 0, 4, "Original " + str.tostring(span) + "-bar move", text_color=muted, text_size=size.small)
            table.cell(hud, 1, 4, str.tostring(math.abs(m.tip - m.origin), format.mintick) + " / " + str.tostring(m.atrSize, "#.0") + " ATR", text_color=textCol, text_size=size.small)
            table.cell(hud, 0, 5, "Bars tracked", text_color=muted, text_size=size.small)
            table.cell(hud, 1, 5, str.tostring(m.age) + " / " + str.tostring(life), text_color=textCol, text_size=size.small)
            table.cell(hud, 0, 6, "100% = original move", text_color=muted, text_size=size.tiny)
            table.cell(hud, 1, 6, m.active ? "0% = fully returned" : "FINAL SNAPSHOT", text_color=muted, text_size=size.tiny)
        if rails and m.active
            label.set_xy(tipLabel, bar_index + 3, m.tip)
            label.set_text(tipLabel, "100%  Impulse close")
            label.set_tooltip(tipLabel, str.tostring(m.tip, format.mintick))
            label.set_textcolor(tipLabel, col)
            label.set_xy(midLabel, bar_index + 3, (m.tip + m.origin) * 0.5)
            label.set_text(midLabel, "50%  Half back")
            label.set_tooltip(midLabel, str.tostring((m.tip + m.origin) * 0.5, format.mintick))
            label.set_textcolor(midLabel, halfCol)
            label.set_xy(originLabel, bar_index + 3, m.origin)
            label.set_text(originLabel, "0%  Origin")
            label.set_tooltip(originLabel, str.tostring(m.origin, format.mintick))
            label.set_textcolor(originLabel, muted)
        else
            label.set_xy(tipLabel, na, na)
            label.set_xy(midLabel, na, na)
            label.set_xy(originLabel, na, na)
    else if panelOn
        string emptyState = na(baseAtr) ? "WARMING UP" : not valid ? "MISSING PRICE DATA" : not ready ? "NO PRICE RANGE" : "WAITING FOR IMPULSE"
        table.cell(hud, 0, 1, emptyState, text_color=halfCol, text_size=size.small)
        table.cell(hud, 1, 1, na(baseAtr) ? str.tostring(atrLen + span) + " bars needed" : ">= " + str.tostring(minMove, "#.0") + " ATR", text_color=muted, text_size=size.small)
        table.cell(hud, 0, 6, "No qualifying move yet", text_color=muted, text_size=size.tiny)
        table.cell(hud, 1, 6, "Chart timeframe", text_color=muted, text_size=size.tiny)

// Data Window outputs support exact on-chart calculation checks and CSV export.
Map latest = array.size(maps) > 0 ? array.last(maps) : na
plot(not na(latest) ? latest.origin : na, "Map origin", display=display.data_window)
plot(not na(latest) ? latest.tip : na, "Map impulse close", display=display.data_window)
plot(not na(latest) ? latest.retained * 100 : na, "Move retained (%)", display=display.data_window)
plot(newUp ? 1 : newDn ? -1 : 0, "New impulse direction", display=display.data_window)
plot(halfEvent ? 1 : 0, "Half back event", display=display.data_window)
plot(unwindEvent ? 1 : 0, "Unwound event", display=display.data_window)
plot(recoverEvent ? 1 : 0, "Recovered event", display=display.data_window)
plot(expireEvent ? 1 : 0, "Expired event", display=display.data_window)
plot(replaceEvent ? 1 : 0, "Replaced event", display=display.data_window)
alertcondition(newUp, "New up impulse", "New confirmed up impulse on {{ticker}} {{interval}}.")
alertcondition(newDn, "New down impulse", "New confirmed down impulse on {{ticker}} {{interval}}.")
alertcondition(halfEvent, "Half of impulse returned", "Confirmed close returned at least half of the mapped impulse on {{ticker}} {{interval}}.")
alertcondition(unwindEvent, "Impulse fully unwound", "Confirmed close reached or crossed the impulse origin on {{ticker}} {{interval}}.")
alertcondition(recoverEvent, "Impulse recovered", "After returning at least half, a confirmed close recovered the original impulse on {{ticker}} {{interval}}.")
````
