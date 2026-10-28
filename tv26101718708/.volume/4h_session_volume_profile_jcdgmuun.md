# 4H Session Volume Profile

- url: https://www.tradingview.com/script/jcdgMUUn-4H-Session-Volume-Profile/
- type: indicator
- pine_id: PUB;186269521f944b28a0002a63372cfb7f
- version: 2.0

## Description

4H Session Volume Profile (4H SVP)
 
A clean, overlay volume profile indicator that automatically anchors to each 4-hour session boundary — giving you institutional-grade volume distribution data directly on your intraday chart.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
WHAT IT DOES
 
This indicator calculates and displays a volume profile for each 4-hour trading session. Instead of viewing a single daily volume profile or manually anchoring to specific candles, 4H SVP automatically resets at every 4H boundary, showing you exactly where volume concentrated during each session.
 
For each 4H session it displays:
 
• POC (Point of Control) — the price level with the highest traded volume. Shown as a solid line spanning the session width. This is the "fair value" price for that session — where the most business was done.
 
• VAH (Value Area High) — the upper boundary of the value area. Shown as a dashed line.
 
• VAL (Value Area Low) — the lower boundary of the value area. Shown as a dashed line.
 
• Volume Histogram — horizontal bars showing relative volume at each price level within the session. The POC row is highlighted for quick visual identification.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
WHY 4H SESSIONS?
 
Daily volume profiles are useful but too broad for intraday traders. They compress an entire session into one distribution, hiding the evolving story of where institutions are active within the day.
 
4-hour sessions strike the right balance:
— Granular enough to reveal intraday institutional positioning
— Broad enough to contain statistically meaningful volume data
— Naturally aligned with major session transitions (Asia → London → NY)
— Each session's POC/VAH/VAL becomes actionable support/resistance for subsequent sessions
 
When price returns to a prior session's POC, it's returning to "fair value" as defined by actual volume — not a drawn level or indicator calculation. VAH and VAL act as natural boundaries where institutional participants have shown willingness to trade.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
HOW TO USE IT
 
Support & Resistance:
Prior session POC levels act as magnets. Price tends to revisit POC before expanding. Use POC as potential entry zones on retests and VAH/VAL as profit targets or stop-loss references.
 
Session Transition Trading:
When a new 4H session opens and immediately moves away from the previous session's value area, watch for a retest of VAH or VAL as a potential entry.
 
Value Area Breakout:
When price breaks above VAH or below VAL with volume, it signals potential expansion. If it fails to hold outside the value area, expect rotation back to POC.
 
Confluence with Price Action:
Combine with your existing methodology — order blocks, fair value gaps, or other structural patterns that align with POC/VAH/VAL levels carry higher probability.
 
Developing Session Profile:
The current 4H session shows a live, updating profile so you can see volume distribution building in real-time and identify developing POC shifts.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
SETTINGS
 
Row Size (points) — Width of each price level in the histogram. Default: 2.0. Lower values = more detail, higher values = smoother profile. Recommended: 1.0-2.0 for gold futures, 0.5-1.0 for forex, 2.0-5.0 for indices.
 
Value Area % — Percentage of total session volume that defines the value area. Default: 70% (industry standard). Higher values widen the VAH-VAL range.
 
Days to Display — How many days of historical sessions to show. Default: 3. Increase for more context, decrease for a cleaner chart.
 
Histogram Width (bars) — How far histogram bars extend horizontally from the session boundary. Default: 8. Adjust based on chart zoom level.
 
Show Histogram / POC / VAH-VAL — Toggle individual elements on or off.
 
Extend POC into Next Session — When enabled, POC lines extend forward until the next session, making it easier to see when price approaches a prior POC.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
COLOUR DEFAULTS
 
Designed for white/light chart backgrounds with subtle, non-distracting colours:
 
POC Line — Deep blue, solid (the most important level)
VAH / VAL Lines — Burnt orange, dashed (visible but secondary)
Histogram Bars — Blue-grey with transparency (clean background detail)
POC Row Highlight — Blue with transparency (identifies the POC bar in the histogram)
 
All colours are fully customisable in settings.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
BEST TIMEFRAMES
 
Designed for use on intraday charts where 4H session context is most valuable:
 
• 1-minute to 15-minute charts — ideal
• 30-minute charts — works well
• 1-hour charts — useful for broader context
• 4-hour and above — not recommended (profile would only show one bar per session)
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
MARKETS
 
Works on any market with volume data. Optimised and tested on:
• Gold futures (GC) — default row size of 2.0 pts
• Forex pairs — recommend row size 0.5-1.0
• Index futures (ES, NQ) — recommend row size 2.0-5.0
• Crypto — recommend row size based on asset volatility
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
TECHNICAL NOTES
 
• Volume is distributed proportionally across price rows covered by each bar's range
• Value area is calculated by expanding outward from POC until the target percentage of total volume is captured
• Drawing objects are managed efficiently — old sessions are cleaned up automatically
• Maximum 2000 histogram boxes and 500 lines supported
• Session boundaries are detected using TradingView's native 4H timeframe change detection
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
CREDITS
 
Built by @Freedombycharts
 
If you find this useful, follow for more institutional-grade trading tools.

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=5
indicator("4H Session Volume Profile", "4H SVP", overlay=true, max_boxes_count=2000, max_lines_count=500, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════

var GRP_VP = "Volume Profile"
i_rowSize   = input.float(2.0, "Row Size (points)", minval=0.5, maxval=10.0, step=0.5, group=GRP_VP, tooltip="Price width of each volume row. 2.0 recommended for GC on 10m chart.")
i_vaPerc    = input.float(70.0, "Value Area %", minval=50, maxval=95, step=5, group=GRP_VP, tooltip="Standard: 70%. Percentage of volume defining the value area.")
i_days      = input.int(3, "Days to Display", minval=1, maxval=5, group=GRP_VP)
i_histW     = input.int(8, "Histogram Width (bars)", minval=2, maxval=25, group=GRP_VP, tooltip="How far histogram bars extend from session boundary.")
i_histSide  = input.string("Right", "Histogram Position", options=["Left", "Right"], group=GRP_VP, tooltip="Which side of the session the histogram is drawn from.")

var GRP_SHOW = "Display"
i_showHist  = input.bool(true, "Show Histogram", group=GRP_SHOW)
i_showPOC   = input.bool(true, "Show POC Line", group=GRP_SHOW)
i_showVA    = input.bool(true, "Show VAH / VAL Lines", group=GRP_SHOW)
i_pocExt    = input.bool(false, "Extend POC into Next Session", group=GRP_SHOW, tooltip="Extend POC line forward until next session.")

var GRP_COL = "Colors (White Background)"
i_pocCol    = input.color(color.new(#1565C0, 0),  "POC Line", group=GRP_COL)
i_vaCol     = input.color(color.new(#E65100, 20), "VAH / VAL Lines", group=GRP_COL)
i_histCol   = input.color(color.new(#B0BEC5, 60), "Histogram Bars", group=GRP_COL)
i_pocHCol   = input.color(color.new(#1565C0, 45), "POC Row Highlight", group=GRP_COL)

var GRP_STYLE = "Line Style"
i_pocStyle  = input.string("Solid", "POC Style", options=["Solid", "Dashed", "Dotted"], group=GRP_STYLE)
i_pocW      = input.int(2, "POC Width", minval=1, maxval=4, group=GRP_STYLE)
i_vaStyle   = input.string("Dashed", "VAH / VAL Style", options=["Solid", "Dashed", "Dotted"], group=GRP_STYLE)
i_vaW       = input.int(1, "VAH / VAL Width", minval=1, maxval=4, group=GRP_STYLE)

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════
var int MAX_ROWS = 200
var int MAX_SESSIONS = 30

getLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_pocStyle = getLineStyle(i_pocStyle)
f_vaStyle  = getLineStyle(i_vaStyle)
isRight    = i_histSide == "Right"

// ═══════════════════════════════════════════════════════════════
// 4H SESSION BOUNDARY DETECTION
// ═══════════════════════════════════════════════════════════════
new4H = ta.change(time("240"))
cutoffMs = timenow - i_days * 86400000
inRange = time >= cutoffMs

// ═══════════════════════════════════════════════════════════════
// SESSION DATA STORAGE
// ═══════════════════════════════════════════════════════════════

var float[] curVol = array.new_float(MAX_ROWS, 0.0)
var float curBase = na
var float curHigh = na
var float curLow = na
var int curStart = na
var bool curActive = false

var float[] sPOC  = array.new_float(0)
var float[] sVAH  = array.new_float(0)
var float[] sVAL  = array.new_float(0)
var float[] sHigh = array.new_float(0)
var float[] sLow  = array.new_float(0)
var float[] sBase = array.new_float(0)
var int[]   sStrt = array.new_int(0)
var int[]   sEnd  = array.new_int(0)
var float[] sVols = array.new_float(0)
var int sCount = 0

var box[]  myBoxes = array.new_box(0)
var line[] myLines = array.new_line(0)

// ═══════════════════════════════════════════════════════════════
// PROFILE CALCULATION
// ═══════════════════════════════════════════════════════════════
calcVA(float[] vol, int numRows, float vaPct) =>
    float maxV = 0.0
    int pocR = 0
    float totV = 0.0

    if numRows > 0 and array.size(vol) >= numRows
        for i = 0 to numRows - 1
            float v = array.get(vol, i)
            totV += v
            if v > maxV
                maxV := v
                pocR := i

    float vaTarget = totV > 0 ? totV * vaPct / 100.0 : 0.0
    float vaVol = maxV
    int upper = pocR
    int lower = pocR

    if totV > 0 and numRows > 1
        int safety = 0
        while vaVol < vaTarget and safety < numRows
            float upV = 0.0
            float dnV = 0.0
            if upper < numRows - 1 and (upper + 1) < array.size(vol)
                upV := array.get(vol, upper + 1)
            if lower > 0
                dnV := array.get(vol, lower - 1)
            if upper >= numRows - 1 and lower <= 0
                break
            if upV >= dnV and upper < numRows - 1
                upper += 1
                vaVol += upV
            else if lower > 0
                lower -= 1
                vaVol += dnV
            else if upper < numRows - 1
                upper += 1
                vaVol += upV
            else
                break
            safety += 1

    [pocR, lower, upper]

// ═══════════════════════════════════════════════════════════════
// PER-BAR PROCESSING
// ═══════════════════════════════════════════════════════════════

if inRange
    if new4H or not curActive
        if curActive and not na(curBase) and not na(curStart) and not na(curHigh) and not na(curLow) and curHigh > curLow
            int numR = math.min(MAX_ROWS, math.max(1, int(math.ceil((curHigh - curBase) / i_rowSize)) + 1))

            if numR > 0 and array.size(curVol) >= numR
                [pocR, loR, hiR] = calcVA(curVol, numR, i_vaPerc)

                float pocP = curBase + (pocR + 0.5) * i_rowSize
                float vahP = curBase + (hiR + 1) * i_rowSize
                float valP = curBase + loR * i_rowSize

                pocP := math.max(curLow, math.min(curHigh, pocP))
                vahP := math.max(curLow, math.min(curHigh, vahP))
                valP := math.max(curLow, math.min(curHigh, valP))

                array.push(sPOC, pocP)
                array.push(sVAH, vahP)
                array.push(sVAL, valP)
                array.push(sHigh, curHigh)
                array.push(sLow, curLow)
                array.push(sBase, curBase)
                array.push(sStrt, curStart)
                array.push(sEnd, bar_index - 1)

                for i = 0 to MAX_ROWS - 1
                    if i < array.size(curVol)
                        array.push(sVols, array.get(curVol, i))
                    else
                        array.push(sVols, 0.0)
                sCount += 1

                if sCount > MAX_SESSIONS
                    array.remove(sPOC, 0)
                    array.remove(sVAH, 0)
                    array.remove(sVAL, 0)
                    array.remove(sHigh, 0)
                    array.remove(sLow, 0)
                    array.remove(sBase, 0)
                    array.remove(sStrt, 0)
                    array.remove(sEnd, 0)
                    if array.size(sVols) >= MAX_ROWS
                        for i = 0 to MAX_ROWS - 1
                            array.remove(sVols, 0)
                    sCount -= 1

        curBase := math.floor(low / i_rowSize) * i_rowSize - i_rowSize * 10
        curHigh := high
        curLow  := low
        curStart := bar_index
        curActive := true
        for i = 0 to MAX_ROWS - 1
            array.set(curVol, i, 0.0)

    if curActive
        curHigh := math.max(curHigh, high)
        curLow  := math.min(curLow, low)

        if not na(curBase) and i_rowSize > 0 and not na(volume) and volume > 0
            int loRow = math.max(0, int(math.floor((low - curBase) / i_rowSize)))
            int hiRow = math.min(MAX_ROWS - 1, int(math.floor((high - curBase) / i_rowSize)))
            if hiRow >= loRow
                int covered = hiRow - loRow + 1
                float vpr = volume / covered
                for i = loRow to hiRow
                    if i >= 0 and i < array.size(curVol)
                        array.set(curVol, i, array.get(curVol, i) + vpr)

// ═══════════════════════════════════════════════════════════════
// DRAWING — LAST BAR ONLY
// ═══════════════════════════════════════════════════════════════

if barstate.islast
    // Clean up
    while array.size(myBoxes) > 0
        box.delete(array.pop(myBoxes))
    while array.size(myLines) > 0
        line.delete(array.pop(myLines))

    // Safe lookback limit — clamp all bar references to within buffer
    int safeMinBar = bar_index - 4900

    // ── Completed sessions ──
    if sCount > 0
        for s = 0 to sCount - 1
            if s < array.size(sStrt) and s < array.size(sEnd) and s < array.size(sBase) and s < array.size(sHigh) and s < array.size(sLow) and s < array.size(sPOC) and s < array.size(sVAH) and s < array.size(sVAL)
                int rawStart = array.get(sStrt, s)
                int rawEnd   = array.get(sEnd, s)

                // Skip sessions entirely outside buffer
                if rawEnd < safeMinBar
                    continue

                // Clamp start to safe range
                int startIdx = math.max(rawStart, safeMinBar)
                int endIdx   = rawEnd
                float base   = array.get(sBase, s)
                float hi     = array.get(sHigh, s)
                float lo     = array.get(sLow, s)
                float poc    = array.get(sPOC, s)
                float vah    = array.get(sVAH, s)
                float val    = array.get(sVAL, s)

                int numR = math.min(MAX_ROWS, math.max(1, int(math.ceil((hi - base) / i_rowSize)) + 1))

                float maxV = 0.0
                int volOffset = s * MAX_ROWS
                for r = 0 to numR - 1
                    int idx = volOffset + r
                    if idx >= 0 and idx < array.size(sVols)
                        float v = array.get(sVols, idx)
                        maxV := math.max(maxV, v)

                if maxV > 0
                    if i_showHist
                        for r = 0 to numR - 1
                            int idx = volOffset + r
                            if idx >= 0 and idx < array.size(sVols)
                                float v = array.get(sVols, idx)
                                if v > 0
                                    float rowBot = base + r * i_rowSize
                                    float rowTop = rowBot + i_rowSize
                                    if rowTop >= lo and rowBot <= hi
                                        float ratio = v / maxV
                                        int barW = int(math.max(1, math.round(ratio * i_histW)))
                                        bool isPocRow = rowBot <= poc and rowTop >= poc
                                        color hCol = isPocRow ? i_pocHCol : i_histCol
                                        int anchorBar = isRight ? endIdx : startIdx
                                        int boxL = isRight ? math.max(anchorBar - barW, safeMinBar) : anchorBar
                                        int boxR = isRight ? anchorBar : math.min(anchorBar + barW, bar_index)
                                        box b = box.new(boxL, rowTop, boxR, rowBot, border_color=color.new(hCol, 85), bgcolor=hCol, border_width=0)
                                        array.push(myBoxes, b)

                    if i_showPOC
                        int pocEnd = i_pocExt ? bar_index : endIdx
                        line l = line.new(startIdx, poc, pocEnd, poc, color=i_pocCol, width=i_pocW, style=f_pocStyle)
                        array.push(myLines, l)

                    if i_showVA
                        line lh = line.new(startIdx, vah, endIdx, vah, color=i_vaCol, width=i_vaW, style=f_vaStyle)
                        line ll = line.new(startIdx, val, endIdx, val, color=i_vaCol, width=i_vaW, style=f_vaStyle)
                        array.push(myLines, lh)
                        array.push(myLines, ll)

    // ── Current developing session ──
    if curActive and not na(curBase) and not na(curHigh) and not na(curLow) and curHigh > curLow
        int numR = math.min(MAX_ROWS, math.max(1, int(math.ceil((curHigh - curBase) / i_rowSize)) + 1))

        if numR > 0 and array.size(curVol) >= numR
            [pocR, loR, hiR] = calcVA(curVol, numR, i_vaPerc)

            float pocP = curBase + (pocR + 0.5) * i_rowSize
            float vahP = curBase + (hiR + 1) * i_rowSize
            float valP = curBase + loR * i_rowSize

            pocP := math.max(curLow, math.min(curHigh, pocP))
            vahP := math.max(curLow, math.min(curHigh, vahP))
            valP := math.max(curLow, math.min(curHigh, valP))

            int safeStart = math.max(curStart, safeMinBar)

            float maxV = 0.0
            for r = 0 to numR - 1
                if r < array.size(curVol)
                    maxV := math.max(maxV, array.get(curVol, r))

            if maxV > 0
                if i_showHist
                    for r = 0 to numR - 1
                        if r < array.size(curVol)
                            float v = array.get(curVol, r)
                            if v > 0
                                float rowBot = curBase + r * i_rowSize
                                float rowTop = rowBot + i_rowSize
                                if rowTop >= curLow and rowBot <= curHigh
                                    float ratio = v / maxV
                                    int barW = int(math.max(1, math.round(ratio * i_histW)))
                                    bool isPocRow = rowBot <= pocP and rowTop >= pocP
                                    color hCol = isPocRow ? i_pocHCol : i_histCol
                                    int anchorBar = isRight ? bar_index : safeStart
                                    int boxL = isRight ? math.max(bar_index - barW, safeMinBar) : anchorBar
                                    int boxR = isRight ? bar_index : math.min(anchorBar + barW, bar_index)
                                    box b = box.new(boxL, rowTop, boxR, rowBot, border_color=color.new(hCol, 85), bgcolor=hCol, border_width=0)
                                    array.push(myBoxes, b)

                if i_showPOC
                    line l = line.new(safeStart, pocP, bar_index, pocP, color=i_pocCol, width=i_pocW, style=f_pocStyle)
                    array.push(myLines, l)

                if i_showVA
                    line lh = line.new(safeStart, vahP, bar_index, vahP, color=i_vaCol, width=i_vaW, style=f_vaStyle)
                    line ll = line.new(safeStart, valP, bar_index, valP, color=i_vaCol, width=i_vaW, style=f_vaStyle)
                    array.push(myLines, lh)
                    array.push(myLines, ll)

// ═══════════════════════════════════════════════════════════════
// END
// ═══════════════════════════════════════════════════════════════
````
