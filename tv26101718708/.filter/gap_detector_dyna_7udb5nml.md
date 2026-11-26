# Gap Detector [DYNA]

- url: https://www.tradingview.com/script/7UdB5nML-Gap-Detector-DYNA/
- type: indicator
- pine_id: PUB;eff3998b52dc46938808ad2e023e8648
- version: 1.0

## Description

Gap Detector finds the price gaps that form between trading sessions and tracks them visually on the chart from formation through fill. Every time a new session opens away from the previous session's close -- by more than a configurable fraction of the daily ATR -- the indicator drops a shaded rectangle covering the gap zone, color-coded green for an up-gap and red for a down-gap. The box stays on the chart, extending bar by bar, until price trades back through the prior close and fills it. When that happens, the box turns gray, a strikethrough line is drawn through the middle, and a fill alert fires.

The threshold is ATR-relative, not a fixed point amount, so the same default settings work across instruments with very different price scales. Stocks, indices, forex pairs, commodities, and crypto all use the same `0.5x daily ATR` filter -- the indicator scales itself. Up to N gaps (configurable) are kept on the chart at once, with optional fill-progress lines that show how close each open gap has come to filling.


[b]Key Features[/b]

[list]
[*] [b]ATR-Relative Threshold[/b] -- Minimum gap size is expressed as a multiple of the 14-period daily ATR, so the same setting filters appropriately on a $50 stock and a $5,000 index.
[*] [b]Color-Coded Gap Boxes[/b] -- Green for gap-up, red for gap-down, gray for filled. The box always spans from the prior session close to the new session open.
[*] [b]Fill-Progress Tracking[/b] -- A dotted line inside each open gap marks the deepest price has penetrated so far. Lets you see at a glance how close a gap is to filling.
[*] [b]Strikethrough on Fill[/b] -- When price fully retraces back through the prior close, the box recolors and a horizontal line is drawn through it -- visual confirmation the gap is closed.
[*] [b]Configurable On-Chart History[/b] -- Cap the number of gap boxes shown so the chart stays clean. Optionally hide filled gaps entirely if you only want live structure.
[*] [b]Gap Size Labels[/b] -- Each gap shows its size in points and as a multiple of the daily ATR -- you can rank gaps by relative magnitude without doing the math.
[*] [b]No Repainting[/b] -- Gap detection runs only on confirmed bars. Once a box is drawn it never relocates; it only extends rightward and recolors when filled.
[/list]


[b]How It Works[/b]

At the open of each new session, the indicator compares the session's first-bar open to the previous session's last-bar close. If the absolute difference exceeds the configured `ATR multiplier x daily ATR` threshold, a new gap is registered. A shaded rectangle is drawn between the prior close and the new open -- green if the open is above (gap up), red if below (gap down). A small label on the box reports the gap's size in points and as a multiple of the daily ATR.

From the formation bar onward, every subsequent bar is checked against the prior close. For a gap up, the gap fills the moment any bar's low touches or crosses below the prior close. For a gap down, it fills when any bar's high touches or crosses above the prior close. While the gap remains open, a dotted "fill progress" line is updated to sit at the deepest penetration so far -- the closer that line is to the prior close, the closer the gap is to filling.

When a gap fills, the box's fill and border recolor to gray, a horizontal strikethrough line is drawn through the middle of the box, and a fill alert fires. If the "Keep Filled Gaps Visible" toggle is off, the gap is removed from the chart instead. Either way, the count of on-chart gaps respects the `Max Gaps to Show` cap -- the oldest gap (filled or not) is removed when the limit is reached, so the indicator never crowds the chart.

The daily ATR used for the threshold is fetched with non-lookahead higher-timeframe security calls, so the threshold at the open of session N is sized using only data available through session N-1. There is no peeking ahead.

[image]https://www.tradingview.com/x/XhCN2fr3/[/image]
[i]Two open gaps and one filled gap on a daily chart. The green box marks an unfilled gap up, the red box an unfilled gap down (with the orange dotted line showing how far price has retraced into it), and the gray box with strikethrough marks a gap that has fully closed.[/i]


[b]Settings[/b]

[b]Min Gap Size (x Daily ATR)[/b] (default: 0.5) is the minimum gap size to qualify, expressed as a multiple of the 14-period daily ATR. Lower captures more, smaller gaps; higher filters down to large opening shocks. Set to 0 to flag every nonzero gap. [b]Daily ATR Length[/b] (default: 14) is the lookback for the daily ATR -- 14 is the Wilder standard.

[b]Max Gaps to Show[/b] (default: 5) caps the number of gap boxes (open and filled) kept on the chart at once. When the cap is hit, the oldest box is removed. [b]Keep Filled Gaps Visible[/b] (default: on) controls whether filled gaps stay on the chart with a strikethrough or are removed the moment they fill.

Visual toggles independently control the fill-progress line, the gap-size label, and the colors used for gap-up, gap-down, and filled boxes. [b]Box Transparency[/b] (default: 80) sets how see-through the box fills are; filled-gap boxes use a slightly higher transparency so they recede into the background. The two alert toggles enable or disable the new-gap and gap-filled alerts individually.


[b]Alerts[/b]

[list]
[*] [b]New Gap Up[/b] -- Fires on the formation bar of a qualifying gap UP. [i]"Gap Detector [DYNA]: A new bullish session gap UP has formed above the configured ATR threshold."[/i]
[*] [b]New Gap Down[/b] -- Fires on the formation bar of a qualifying gap DOWN. [i]"Gap Detector [DYNA]: A new bearish session gap DOWN has formed above the configured ATR threshold."[/i]
[*] [b]Gap Up Filled[/b] -- Fires when an open gap UP fills. [i]"Gap Detector [DYNA]: A bullish gap UP has been fully filled -- price traded back down to the prior session close."[/i]
[*] [b]Gap Down Filled[/b] -- Fires when an open gap DOWN fills. [i]"Gap Detector [DYNA]: A bearish gap DOWN has been fully filled -- price traded back up to the prior session close."[/i]
[/list]

To set up alerts: click TradingView's Alerts button, choose "Gap Detector [DYNA]" from the condition dropdown, pick the gap event you want, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Use the daily timeframe for the cleanest gap-by-gap reading. Drop to intraday timeframes (15m through 60m) when you want to watch a specific gap fill in real time during the session that's reacting to it.
[*] Tune the ATR multiplier to your style: 0.2-0.3 for stocks with small absolute gaps, 0.5 for the default moderate filter, 0.8-1.0 for only large opening shocks.
[*] The prior close (the far edge of the gap) is a natural reference level -- many traders watch it as a potential target when studying gap behavior. Use it as a level of interest if you're observing how a gap reacts.
[*] The new session open (the near edge) often acts as the first support/resistance test. Use it as your structure for entries and stops.
[*] If a gap doesn't fill for several sessions, you can study it as a structural reference -- a support/resistance level worth watching until price tests it again.
[*] Reduce [b]Max Gaps to Show[/b] to 3 on instruments that gap often (single-name stocks). Increase to 10-20 on instruments that gap rarely (FX majors).
[/list]


[b]Part of the DYNA Ecosystem[/b]

Gap Detector is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past gap behavior does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Gap Detector [DYNA]
// Identifies session-to-session price gaps, draws them as shaded boxes, and tracks fill progress.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Gap Detector [DYNA]", shorttitle = "Gap [DYNA]", overlay = true,
         max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

color GAP_UP_COLOR    = #26a69a
color GAP_DOWN_COLOR  = #ef5350
color FILLED_COLOR    = #787b86
color PROGRESS_COLOR  = #ff9800

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
float i_atrMult       = input.float(0.5, "Min Gap Size (× Daily ATR)", minval = 0.0, maxval = 10.0, step = 0.1, group = GRP_CORE, tooltip = "Minimum gap size between the prior session close and the new session open, expressed as a multiple of the 14-period daily ATR. Lower = more gaps detected (smaller gaps qualify). Higher = only large, tradeable gaps are flagged. Set to 0 to flag every nonzero gap.")
int   i_atrLength     = input.int(14, "Daily ATR Length", minval = 5, maxval = 50, group = GRP_CORE, tooltip = "Lookback period for the daily ATR used to size the gap threshold. 14 is the standard.")
int   i_maxGaps       = input.int(5, "Max Gaps to Show", minval = 1, maxval = 50, group = GRP_CORE, tooltip = "Maximum number of gap boxes to keep on the chart at once. When exceeded, the oldest gap (filled or not) is removed.")
bool  i_keepFilled    = input.bool(true, "Keep Filled Gaps Visible", group = GRP_CORE, tooltip = "When ON, filled gaps remain on the chart (with a strikethrough line) until they age out via the Max Gaps cap. When OFF, gaps are removed the moment they fill — useful if you only care about live, open gaps.")

// --- Visual ---
bool  i_showProgress  = input.bool(true, "Show Fill Progress", group = GRP_VIS, tooltip = "Draw a dotted horizontal line at the deepest price penetration into each open gap. Lets you see how close a gap is to filling at a glance.")
bool  i_showLabel     = input.bool(true, "Show Gap Size Label", group = GRP_VIS, tooltip = "Place a small label on each gap showing its size in points and as a multiple of the daily ATR.")
color i_gapUpColor    = input.color(GAP_UP_COLOR,   "Gap Up Color",   group = GRP_VIS, tooltip = "Fill and border color for gap-up rectangles.")
color i_gapDownColor  = input.color(GAP_DOWN_COLOR, "Gap Down Color", group = GRP_VIS, tooltip = "Fill and border color for gap-down rectangles.")
color i_filledColor   = input.color(FILLED_COLOR,   "Filled Gap Color", group = GRP_VIS, tooltip = "Fill, border, and strikethrough color used after a gap fills.")
int   i_boxTransp     = input.int(80, "Box Transparency", minval = 50, maxval = 95, step = 1, group = GRP_VIS, tooltip = "Higher = more transparent fill. Filled-gap boxes use a higher transparency so they fade into the background.")

// --- Alerts ---
bool i_alertGapUp       = input.bool(true, "Alert: New Gap Up",      group = GRP_ALERT, tooltip = "Fire on the first confirmed bar of a new session when a qualifying gap UP forms.")
bool i_alertGapDown     = input.bool(true, "Alert: New Gap Down",    group = GRP_ALERT, tooltip = "Fire on the first confirmed bar of a new session when a qualifying gap DOWN forms.")
bool i_alertUpFilled    = input.bool(true, "Alert: Gap Up Filled",   group = GRP_ALERT, tooltip = "Fire when a gap UP fills (price trades back down to the prior session close).")
bool i_alertDownFilled  = input.bool(true, "Alert: Gap Down Filled", group = GRP_ALERT, tooltip = "Fire when a gap DOWN fills (price trades back up to the prior session close).")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Daily ATR (lookahead off so the value at session N is computed from
//     completed daily bars up to and including session N-1, which is the
//     correct reference for sizing a gap forming at the open of session N).
float dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(i_atrLength), lookahead = barmerge.lookahead_off)

// --- New-session detection ---
// `time("D")` returns the same daily-anchor value for every bar inside the
// symbol's daily session. When that anchor changes, we are on the first bar of
// a new session. This works on daily charts (every bar is a new session) and
// on intraday charts (the first bar after the overnight gap).
// See memory file pine_session_detection.md for the rationale.
int  dayAnchor   = time("D")
bool isNewSession = not na(dayAnchor) and (na(dayAnchor[1]) or dayAnchor != dayAnchor[1])

// --- Gap UDT ---
type Gap
    box   bx
    line  strikeLine
    line  progressLine
    label tag
    float top
    float bottom
    float priorClose
    bool  isUp
    bool  filled
    int   formBar
    float deepest
    float gapPts
    float gapAtr

// --- Persistent state ---
var array<Gap> gaps = array.new<Gap>()

// --- Per-bar signals (set inside the confirmed-bar block below) ---
bool newGapUp     = false
bool newGapDown   = false
bool gapUpFilled  = false
bool gapDownFilled = false

// --- Visual helpers ---
buildBgColor(color base, int transp) =>
    color.new(base, transp)

deleteGap(Gap g) =>
    if not na(g.bx)
        box.delete(g.bx)
    if not na(g.strikeLine)
        line.delete(g.strikeLine)
    if not na(g.progressLine)
        line.delete(g.progressLine)
    if not na(g.tag)
        label.delete(g.tag)

if barstate.isconfirmed
    // --- 1. Detect a new gap on the first bar of a new session ---
    if isNewSession and bar_index > 0 and not na(close[1]) and not na(dailyAtr) and dailyAtr > 0
        float pClose = close[1]
        float oOpen  = open
        float gSize  = oOpen - pClose
        float thresh = i_atrMult * dailyAtr

        if math.abs(gSize) >= thresh and math.abs(gSize) > syminfo.mintick
            bool  isUp = gSize > 0
            float top  = math.max(pClose, oOpen)
            float bot  = math.min(pClose, oOpen)
            color base = isUp ? i_gapUpColor : i_gapDownColor
            box bx = box.new(bar_index, top, bar_index, bot,
                 border_color = base, border_width = 1, bgcolor = buildBgColor(base, i_boxTransp))

            // Optional gap-size label, anchored at the formation bar / top of the box.
            label tag = na
            if i_showLabel
                string txt = str.tostring(math.abs(gSize), format.mintick) + " pt (" + str.tostring(math.abs(gSize) / dailyAtr, "#.##") + "× ATR)"
                tag := label.new(bar_index, isUp ? top : bot, txt,
                     yloc = yloc.price, style = isUp ? label.style_label_lower_left : label.style_label_upper_left,
                     color = base, textcolor = color.white, size = size.small)

            // Push the new gap onto the persistent array.
            Gap g = Gap.new(bx, na, na, tag, top, bot, pClose, isUp, false, bar_index,
                 isUp ? top : bot,        // deepest penetration starts at the far edge (no progress yet)
                 math.abs(gSize),
                 math.abs(gSize) / dailyAtr)
            array.push(gaps, g)
            if isUp
                newGapUp := true
            else
                newGapDown := true

            // Cap the number of gaps shown.
            while array.size(gaps) > i_maxGaps
                Gap old = array.shift(gaps)
                deleteGap(old)

    // --- 2. Update existing gaps: extend right, track fill progress, mark fills ---
    if array.size(gaps) > 0
        for i = 0 to array.size(gaps) - 1
            Gap g = array.get(gaps, i)

            // Always extend the right edge so the box stays current with the chart.
            if not na(g.bx)
                box.set_right(g.bx, bar_index)

            if not g.filled
                // Fill check runs every bar — including the formation bar, since
                // the opening bar's wick can already round-trip through the prior
                // close when an opening gap is rejected immediately.
                bool justFilled = false
                if g.isUp
                    // Gap UP fills when price trades back down to the prior close.
                    if low <= g.priorClose
                        justFilled := true
                        g.deepest := g.priorClose
                    else if low < g.deepest
                        g.deepest := low
                else
                    // Gap DOWN fills when price trades back up to the prior close.
                    if high >= g.priorClose
                        justFilled := true
                        g.deepest := g.priorClose
                    else if high > g.deepest
                        g.deepest := high

                if justFilled
                    g.filled := true
                    if i_keepFilled
                        // Re-color the box to "filled" appearance and draw the strikethrough line.
                        box.set_bgcolor(g.bx, buildBgColor(i_filledColor, math.min(i_boxTransp + 10, 95)))
                        box.set_border_color(g.bx, i_filledColor)
                        float midY = (g.top + g.bottom) / 2
                        g.strikeLine := line.new(g.formBar, midY, bar_index, midY,
                             color = i_filledColor, width = 2, style = line.style_solid)
                        // Drop any progress line — fully filled.
                        if not na(g.progressLine)
                            line.delete(g.progressLine)
                            g.progressLine := na
                    else
                        deleteGap(g)
                        // Mark slot for cleanup below by zeroing handles.
                        g.bx := na
                        g.strikeLine := na
                        g.progressLine := na
                        g.tag := na
                    if g.isUp
                        gapUpFilled := true
                    else
                        gapDownFilled := true

                // Update or draw the progress line at the deepest penetration so far.
                if not g.filled and i_showProgress and not na(g.bx)
                    // Only draw progress once price has actually entered the gap.
                    bool entered = g.isUp ? g.deepest < g.top : g.deepest > g.bottom
                    if entered
                        if na(g.progressLine)
                            g.progressLine := line.new(g.formBar, g.deepest, bar_index, g.deepest,
                                 color = PROGRESS_COLOR, width = 1, style = line.style_dotted)
                        else
                            line.set_xy1(g.progressLine, g.formBar, g.deepest)
                            line.set_xy2(g.progressLine, bar_index, g.deepest)

            // Persist any field mutations back into the array slot.
            array.set(gaps, i, g)

        // Sweep out any slots that got cleared above (filled with i_keepFilled = false).
        int idx = array.size(gaps) - 1
        while idx >= 0
            Gap gg = array.get(gaps, idx)
            if na(gg.bx) and na(gg.strikeLine) and na(gg.progressLine) and na(gg.tag)
                array.remove(gaps, idx)
            idx := idx - 1

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// Boxes, strikethrough lines, progress lines, and labels are managed in
// Section 3 (they require persistent handles). Below are the per-bar markers.

plotshape(newGapUp      ? true : false, title = "New Gap Up",      style = shape.triangleup,   location = location.belowbar, color = i_gapUpColor,   size = size.tiny)
plotshape(newGapDown    ? true : false, title = "New Gap Down",    style = shape.triangledown, location = location.abovebar, color = i_gapDownColor, size = size.tiny)
plotshape(gapUpFilled   ? true : false, title = "Gap Up Filled",   style = shape.xcross,       location = location.abovebar, color = i_filledColor,  size = size.tiny)
plotshape(gapDownFilled ? true : false, title = "Gap Down Filled", style = shape.xcross,       location = location.belowbar, color = i_filledColor,  size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(newGapUp      and i_alertGapUp,      title = "New Gap Up",      message = "Gap Detector [DYNA]: A new bullish session gap UP has formed above the configured ATR threshold.")
alertcondition(newGapDown    and i_alertGapDown,    title = "New Gap Down",    message = "Gap Detector [DYNA]: A new bearish session gap DOWN has formed above the configured ATR threshold.")
alertcondition(gapUpFilled   and i_alertUpFilled,   title = "Gap Up Filled",   message = "Gap Detector [DYNA]: A bullish gap UP has been fully filled — price traded back down to the prior session close.")
alertcondition(gapDownFilled and i_alertDownFilled, title = "Gap Down Filled", message = "Gap Detector [DYNA]: A bearish gap DOWN has been fully filled — price traded back up to the prior session close.")
````
