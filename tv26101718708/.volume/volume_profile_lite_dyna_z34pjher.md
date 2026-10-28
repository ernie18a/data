# Volume Profile Lite [DYNA]

- url: https://www.tradingview.com/script/z34PJhEr-Volume-Profile-Lite-DYNA/
- type: indicator
- pine_id: PUB;f0deedda26eb4f6caecdf93240885af4
- version: 1.0

## Description

Volume Profile Lite shows where most of the trading happened during a session. It slices the session range into a row of horizontal bins, drops each bar's volume into the bins it touches, and draws the result as a horizontal histogram on the right side of the chart. The longest bar is the [b]point of control[/b] (POC) -- the single price level with the most accumulated volume -- and the contiguous group of bins around the POC that together hold a configurable percentage of the day's volume (70% by default) is the [b]value area[/b].

Two pairs of horizontal levels are drawn. Today's developing VAH and VAL (blue dashed) bracket the live value area as it builds throughout the session. The previous session's end-of-day VAH and VAL (orange solid) are persisted as a stable reference -- a close above prevVAH or below prevVAL is the canonical market-profile breakout signal: today is finding new acceptance outside yesterday's accepted range. Built-in alerts fire on the first such close per direction per session.

A "lite" volume profile by design: one anchor (the session), one profile, five levels (POC, VAH, VAL, prevVAH, prevVAL), two alerts. Configurable bin count, value-area %, lookback sessions, session window, and timezone. No repainting -- POC and VA evolve as new volume arrives but never look back to change historical values.


[b]Key Features[/b]

[list]
[*] [b]Session-Anchored Profile[/b] -- A fresh horizontal volume histogram is built for every trading session. Resets at the configured session boundary; the previous session's profile drops off cleanly when the new one begins.
[*] [b]POC + Value Area[/b] -- The point of control (highest-volume price) is highlighted in yellow with a dedicated line; bins inside the value area are shaded blue, bins outside are dimmer grey. The 70% value-area threshold is configurable from 50% to 95%.
[*] [b]Configurable Bin Count[/b] -- 24 bins by default. Raise to 36-50 for high-resolution profiles on wide-range days; drop to 12-16 for compact charts. Bin count caps at 50 to keep recompute time bounded.
[*] [b]Multi-Session Lookback[/b] -- Default 1 session shows today's profile. Raise to 3-5 to combine the last few days into a single composite profile -- useful for swing context on intraday timeframes when daily randomness obscures the dominant POC.
[*] [b]Right-Edge Histogram + Cross-Session Levels[/b] -- The histogram sits to the right of the latest bar (offset and width are configurable). POC, VAH, VAL, prevVAH, and prevVAL lines extend leftward across the session range so they're visible as price-action levels, with right-edge labels showing the exact prices.
[*] [b]Stable Breakout Reference[/b] -- Yesterday's end-of-day VAH and VAL are locked in at session open and shown as orange solid lines. These -- not today's evolving VAH/VAL -- are the alert reference, which gives a clean, non-shifting breakout signal instead of the noisy "live cross" produced by an expanding live profile.
[*] [b]One-Shot Breakout Alerts[/b] -- Two latched alerts fire on the first close above prevVAH or below prevVAL in each session. One alert per direction per day -- no spam from re-crosses.
[*] [b]No Repainting[/b] -- All computation happens on confirmed bars. POC, VAH, and VAL evolve as new volume enters but never retroactively change. Breakout alerts only fire after a closed bar.
[/list]


[b]How It Works[/b]

The indicator maintains a rolling buffer of every bar inside the configured session window for the last N sessions (N = lookback). On each confirmed bar, the buffer's full price range is split into the configured number of bins, and every bar's volume is distributed across the bins it overlaps -- proportional to how much of the bar's high-low range falls inside each bin. Zero-range bars deposit their full volume into the single bin containing them.

The bin with the largest accumulated volume becomes the POC. The value area then expands outward from the POC one bin at a time, always taking the side (above or below) with the greater immediate volume, until the cumulative volume inside the area reaches the configured value-area percent of the session total. The top of the highest included bin is VAH, the bottom of the lowest included bin is VAL.

At every new session boundary the indicator captures the previous session's final VAH and VAL and locks them in as prevVAH/prevVAL -- the alert reference. Today's developing VAH/VAL are visualized but intentionally not used for alerts: a live volume profile's value area expands as the session unfolds, which makes "live cross" alerts extremely noisy. Yesterday's end-of-day VAH/VAL is fixed and stable, and a close beyond it is the canonical "today is finding new acceptance outside yesterday's range" signal.

For instruments with no published volume (e.g., some cash indices), the indicator falls back to a flat per-bar weight of 1.0. This produces a bar-count "TPO-style" profile rather than a true volume profile -- the shapes and POC location still reflect where price spent the most time and remain useful as structural reference.

Each confirmed bar redraws the histogram boxes and all five level lines (POC, VAH, VAL, prevVAH, prevVAL) from scratch using fresh data. Two alert conditions watch for a close above prevVAH and a close below prevVAL respectively; each latches after firing and only resets at the next session boundary.

[image]https://www.tradingview.com/x/oNCk9h0U/[/image]
[i]A 30-minute chart with a 24-bin profile: yellow POC line through the highest-volume price level, blue dashed VAH/VAL lines bracketing today's developing value area, orange solid prevVAH/prevVAL lines marking yesterday's end-of-day breakout reference, and the right-edge histogram showing the bin-by-bin volume distribution.[/i]


[b]Settings[/b]

[b]Number of Bins[/b] (default: 24, range 8-50) controls the granularity of the profile. 24 bins on a typical session range produces readable, evenly sized bins, which is a good balance. Raise toward 50 for wide-range trending days where you want fine-grained POC location; drop to 12-16 for compact charts.

[b]Value Area %[/b] (default: 70.0, range 50-95) is the cumulative-volume threshold that defines the value area. 70% is the market-profile textbook standard. Lower values produce a tighter "core" with sharper VAH/VAL fade signals; higher values produce a wider band more like an outer envelope.

[b]Lookback Sessions[/b] (default: 1, range 1-5) sets how many trailing sessions are merged into a single profile. 1 = today only (the standard intraday view). Raising to 3-5 produces a composite multi-session profile that smooths daily randomness -- useful when you want the dominant POC across a recent range rather than just today's.

[b]Session Time[/b] (default: 0915-1530) and [b]Timezone[/b] (default: Asia/Kolkata) define the session window. Adjust both to match the regular trading hours of your instrument and exchange.

The visual section ([b]Show Histogram[/b], [b]Histogram Width (bars)[/b], [b]Histogram Offset (bars)[/b], [b]Show POC Line[/b], [b]Show Value Area Lines[/b], [b]Show Previous Session VAH/VAL[/b], [b]Extend POC/VA Across Session[/b], [b]Show Price Labels[/b]) controls the layout. Width and offset are pure layout knobs and do not change any signal -- if the histogram overlaps price, increase the offset; if it's too narrow to read, increase the width. The two alert toggles enable or disable the prevVAH-break and prevVAL-break alerts independently.


[b]Alerts[/b]

[list]
[*] [b]Break Above Previous VAH[/b] -- Fires on the first close above the previous session's VAH. [i]"Volume Profile Lite [DYNA]: Price closed above the previous session's value area high."[/i]
[*] [b]Break Below Previous VAL[/b] -- Fires on the first close below the previous session's VAL. [i]"Volume Profile Lite [DYNA]: Price closed below the previous session's value area low."[/i]
[/list]

To configure: open TradingView's Alerts panel, choose "Volume Profile Lite [DYNA]" from the condition dropdown, pick the desired alert type, and select your notification channel. Each alert latches once per session per direction; you cannot get a flood of repeat triggers from price oscillating around a level.


[b]Best Practices[/b]

[list]
[*] Use intraday timeframes (5m, 15m, 30m, 1h). The profile needs 30-100+ bars per session to resolve a meaningful distribution. Avoid daily charts.
[*] The orange prevVAH/prevVAL lines are the breakout reference. A close above prevVAH on the open says "today is accepting price above yesterday" -- a directional/trend day cue. Similarly for prevVAL. The alerts fire on these.
[*] Inside today's value area = balance, outside = potential trend. Today's blue dashed VAH/VAL are the live fair-value envelope; fades back to the POC at these levels are clean mean-reversion setups in balanced sessions.
[*] Treat the POC as a magnet. Late-session price far from the POC often gets pulled back to it; holding above the POC is a meaningful bullish signature even before prevVAH breaks.
[*] Today's VAH/VAL stabilize after the first 2-3 hours; the early-session profile is necessarily noisier. Treat early-session VAH/VAL fades as lower-conviction; the second half of the session produces the cleanest reads.
[*] Look for confluence. A prevVAH or prevVAL that aligns with the previous day's close, prior-day high/low, or a moving average is far more reliable as a breakout level than the value area in isolation.
[*] On cash indices where exchange volume is published as zero, the profile is bar-count based. The shapes and POC are still useful as time-at-price proxies. Switch to futures or individual stocks for a true volume profile.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Volume Profile Lite is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Volume Profile Lite [DYNA]
// Per-session horizontal volume histogram with point of control and value area.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Volume Profile Lite [DYNA]", shorttitle = "VPL [DYNA]", overlay = true,
         max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

color POC_COLOR     = #ffeb3b   // Yellow — point of control bin / line
color VA_COLOR      = #2962ff   // Blue   — value area bins / VAH / VAL lines
color OUT_COLOR     = NEUTRAL_COLOR   // Grey  — bins outside the value area

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
int    i_bins      = input.int(24, "Number of Bins", minval = 8, maxval = 50, group = GRP_CORE,
                                tooltip = "How many horizontal price bins to divide the session range into. More bins = finer-grained profile but smaller per-bin volume contrast. 24 is a good balance for intraday timeframes; raise to 36-50 for high-resolution profiles on large-range sessions, drop to 12-16 for compact charts.")
float  i_vaPct     = input.float(70.0, "Value Area %", minval = 50.0, maxval = 95.0, step = 1.0,
                                  group = GRP_CORE,
                                  tooltip = "Percentage of total session volume that defines the value area. Standard market profile uses 70%. Raise to 80-90% for a wider 'fair value' band, lower to 60-65% for a tighter core.")
int    i_lookback  = input.int(1, "Lookback Sessions", minval = 1, maxval = 5, group = GRP_CORE,
                                tooltip = "How many trailing sessions of bars to combine into a single profile. Default 1 = today only (the standard intraday view). Raise to 3-5 to merge several recent days into a composite profile that smooths daily randomness — useful for swing-context POC/VA on intraday charts.")
string i_session   = input.session("0915-1530", "Session Time", group = GRP_CORE,
                                    tooltip = "Session window during which the profile is built. Volume from bars outside this window is excluded. Default matches NSE cash hours; adjust for your instrument.")
string i_timezone  = input.string("Asia/Kolkata", "Timezone",
                                   options = ["Asia/Kolkata", "America/New_York", "America/Chicago",
                                              "Europe/London", "UTC", "Asia/Tokyo", "Asia/Singapore",
                                              "Australia/Sydney"],
                                   group = GRP_CORE,
                                   tooltip = "Timezone used to interpret the session window. Match the exchange's local time to avoid DST drift.")

// --- Visual ---
bool i_showHist      = input.bool(true, "Show Histogram", group = GRP_VIS,
                                   tooltip = "Draw the horizontal volume histogram boxes to the right of the latest bar.")
int  i_histWidthBars = input.int(30, "Histogram Width (bars)", minval = 5, maxval = 100, group = GRP_VIS,
                                  tooltip = "Maximum width (in bar widths) of the histogram. The largest bin (POC) reaches this width; other bins scale proportionally.")
int  i_histOffset    = input.int(2, "Histogram Offset (bars)", minval = 0, maxval = 20, group = GRP_VIS,
                                  tooltip = "Gap between the latest bar and the left edge of the histogram, in bar widths.")
bool i_showPOC       = input.bool(true, "Show POC Line", group = GRP_VIS,
                                   tooltip = "Draw a horizontal line at the point of control (the price level with the highest traded volume in the profile).")
bool i_showVA        = input.bool(true, "Show Value Area Lines", group = GRP_VIS,
                                   tooltip = "Draw horizontal lines at the value area high (VAH) and value area low (VAL) — the upper and lower bounds of the value area %.")
bool i_showPrevVA    = input.bool(true, "Show Previous Session VAH/VAL", group = GRP_VIS,
                                   tooltip = "Draw horizontal lines at the previous session's end-of-day VAH and VAL. These are the breakout-alert reference levels — a close above prevVAH or below prevVAL fires the alert.")
bool i_extendLevels  = input.bool(true, "Extend POC/VA Across Session", group = GRP_VIS,
                                   tooltip = "When on, POC/VAH/VAL and prevVAH/prevVAL lines extend leftward across the session range so they're visible as price-action levels. When off, lines sit only at the right edge next to the histogram.")
bool i_showLabels    = input.bool(true, "Show Price Labels", group = GRP_VIS,
                                   tooltip = "Show POC/VAH/VAL/prevVAH/prevVAL price tags at the right edge of the lines.")

// --- Alerts ---
bool i_alertVAH = input.bool(true, "Alert: Break Above Previous VAH", group = GRP_ALERT,
                              tooltip = "Fire on the first close above the previous session's value area high. Uses yesterday's end-of-day VAH as a stable, non-shifting reference (classical market-profile breakout). Latches per session — one alert per direction per day.")
bool i_alertVAL = input.bool(true, "Alert: Break Below Previous VAL", group = GRP_ALERT,
                              tooltip = "Fire on the first close below the previous session's value area low. Uses yesterday's end-of-day VAL as a stable, non-shifting reference (classical market-profile breakout). Latches per session — one alert per direction per day.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Session anchoring (robust to TradingView hiding off-hours bars) ---
int  sessionDay = time("D", i_session, i_timezone)
bool inSession  = not na(sessionDay)
bool newSession = inSession and (na(sessionDay[1]) or sessionDay != sessionDay[1])

// --- Persistent rolling buffer of in-window bars for the lookback window ---
var array<float> bufHigh   = array.new<float>()
var array<float> bufLow    = array.new<float>()
var array<float> bufVol    = array.new<float>()
var array<int>   bufSesId  = array.new<int>()

// Track unique session IDs in the buffer + each session's start bar.
var array<int> sessIds       = array.new<int>()
var array<int> sessStartBars = array.new<int>()

// --- One-shot signal latches (reset each session) ---
var bool vahBrokenToday = false
var bool valBrokenToday = false

// --- Per-bar signal flags ---
bool vahBreak = false
bool valBreak = false

// --- Cached profile outputs (read by alert + visual layer) ---
var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var int   profileSessionStart = na

// --- Previous session's end-of-day VAH/VAL (used as the stable, non-shifting
//     breakout reference; locked in at the start of every new session). ---
var float prevVAH = na
var float prevVAL = na

// --- Drawing handles (single set, redrawn fresh each bar) ---
var array<box> binBoxes = array.new<box>()
var line  pocLine     = na
var line  vahLine     = na
var line  valLine     = na
var line  prevVAHLine = na
var line  prevVALLine = na
var label pocLabel    = na
var label vahLabel    = na
var label valLabel    = na
var label prevVAHLabel = na
var label prevVALLabel = na

// --- Helper: drop oldest session from buffer until lookback budget is met ---
trimBufferToLookback(int lookback) =>
    while array.size(sessIds) > lookback
        int oldId = array.shift(sessIds)
        array.shift(sessStartBars)
        while array.size(bufSesId) > 0 and array.get(bufSesId, 0) == oldId
            array.shift(bufHigh)
            array.shift(bufLow)
            array.shift(bufVol)
            array.shift(bufSesId)

// --- Helper: clear all draw handles before redrawing the profile ---
clearProfileDrawings() =>
    while array.size(binBoxes) > 0
        box b = array.pop(binBoxes)
        if not na(b)
            box.delete(b)
    line.delete(pocLine)
    line.delete(vahLine)
    line.delete(valLine)
    line.delete(prevVAHLine)
    line.delete(prevVALLine)
    label.delete(pocLabel)
    label.delete(vahLabel)
    label.delete(valLabel)
    label.delete(prevVAHLabel)
    label.delete(prevVALLabel)

// --- Bar-driven state machine (gated on confirmed bars only) ---
if barstate.isconfirmed and inSession
    if newSession
        // Lock in the previous session's end-of-day VAH/VAL BEFORE buffer trim.
        // These are the stable breakout references for today's alerts.
        prevVAH := vahPrice
        prevVAL := valPrice
        array.push(sessIds, sessionDay)
        array.push(sessStartBars, bar_index)
        trimBufferToLookback(i_lookback)
        vahBrokenToday := false
        valBrokenToday := false

    // Append current bar to the buffer. Volume falls back to 1.0 on zero-volume
    // instruments (cash indices) so the profile still reflects price coverage.
    array.push(bufHigh,  high)
    array.push(bufLow,   low)
    array.push(bufVol,   math.max(nz(volume, 0.0), 1.0))
    array.push(bufSesId, sessionDay)

    // --- Determine the profile's price range from the rolling buffer ---
    int n = array.size(bufHigh)
    float sessHigh = na
    float sessLow  = na
    for i = 0 to n - 1
        float h = array.get(bufHigh, i)
        float l = array.get(bufLow,  i)
        sessHigh := na(sessHigh) ? h : math.max(sessHigh, h)
        sessLow  := na(sessLow)  ? l : math.min(sessLow,  l)

    if not na(sessHigh) and not na(sessLow) and sessHigh - sessLow > syminfo.mintick
        float binWidth = (sessHigh - sessLow) / i_bins

        // --- Distribute each bar's volume across the bins it overlaps ---
        // Volume is split proportional to how much of the bar's [low, high]
        // overlaps each bin. Zero-range bars deposit their full volume into
        // the single bin containing them.
        array<float> binVol = array.new_float(i_bins, 0.0)
        for i = 0 to n - 1
            float h   = array.get(bufHigh, i)
            float l   = array.get(bufLow,  i)
            float v   = array.get(bufVol,  i)
            float rng = h - l
            if rng <= 0
                int idx = math.min(i_bins - 1, math.max(0, math.floor((l - sessLow) / binWidth)))
                array.set(binVol, idx, array.get(binVol, idx) + v)
            else
                for k = 0 to i_bins - 1
                    float bb = sessLow + k * binWidth
                    float bt = bb + binWidth
                    float overlap = math.max(0.0, math.min(h, bt) - math.max(l, bb))
                    if overlap > 0
                        array.set(binVol, k, array.get(binVol, k) + v * overlap / rng)

        // --- Find POC bin (bin with the highest volume) ---
        int   pocBin   = 0
        float pocVol   = 0.0
        float totalVol = 0.0
        for k = 0 to i_bins - 1
            float bv = array.get(binVol, k)
            totalVol := totalVol + bv
            if bv > pocVol
                pocVol := bv
                pocBin := k

        // --- Expand value area outward from POC until threshold is met ---
        // 1-bin lookahead (lite version of the standard market-profile rule):
        // at each step, add the side with the greater immediate volume.
        float vaThreshold = totalVol * i_vaPct / 100.0
        int   vaTop = pocBin
        int   vaBot = pocBin
        float vaVol = pocVol
        bool  done  = false
        while vaVol < vaThreshold and not done
            float upVol = vaTop < i_bins - 1 ? array.get(binVol, vaTop + 1) : -1.0
            float dnVol = vaBot > 0          ? array.get(binVol, vaBot - 1) : -1.0
            if upVol < 0 and dnVol < 0
                done := true
            else if upVol >= dnVol
                vaTop := vaTop + 1
                vaVol := vaVol + upVol
            else
                vaBot := vaBot - 1
                vaVol := vaVol + dnVol

        // --- Cache scalar outputs so alerts and visuals can read them ---
        pocPrice := sessLow + (pocBin + 0.5) * binWidth
        vahPrice := sessLow + (vaTop  + 1) * binWidth
        valPrice := sessLow +  vaBot       * binWidth
        profileSessionStart := array.size(sessStartBars) > 0 ? array.get(sessStartBars, 0) : bar_index

        // --- Redraw the histogram + level lines from scratch ---
        clearProfileDrawings()

        if i_showHist and pocVol > 0
            int leftX = bar_index + i_histOffset
            for k = 0 to i_bins - 1
                float bv = array.get(binVol, k)
                if bv > 0
                    int   barLen = math.max(1, int(math.round(bv / pocVol * i_histWidthBars)))
                    int   rightX = leftX + barLen
                    float bb     = sessLow + k * binWidth
                    float bt     = bb + binWidth
                    bool  isPOC  = k == pocBin
                    bool  inVA   = k >= vaBot and k <= vaTop
                    color binColor = isPOC ? POC_COLOR : (inVA ? VA_COLOR : OUT_COLOR)
                    int   trans    = isPOC ? 25 : (inVA ? 55 : 75)
                    box   bx       = box.new(leftX, bt, rightX, bb,
                                              border_color = color.new(binColor, trans),
                                              bgcolor      = color.new(binColor, trans),
                                              border_width = 1)
                    array.push(binBoxes, bx)

        // --- Determine the X-extent for POC/VA lines and labels ---
        int leftLine  = i_extendLevels and not na(profileSessionStart) ? profileSessionStart : bar_index
        int rightLine = bar_index + (i_showHist ? i_histOffset + i_histWidthBars + 1 : 1)

        if i_showPOC
            pocLine := line.new(leftLine, pocPrice, rightLine, pocPrice,
                                color = POC_COLOR, width = 2, style = line.style_solid)
            if i_showLabels
                pocLabel := label.new(rightLine, pocPrice,
                                       "POC " + str.tostring(pocPrice, format.mintick),
                                       style     = label.style_label_left,
                                       color     = color.new(POC_COLOR, 25),
                                       textcolor = color.black,
                                       size      = size.small)

        if i_showVA
            vahLine := line.new(leftLine, vahPrice, rightLine, vahPrice,
                                color = VA_COLOR, width = 1, style = line.style_dashed)
            valLine := line.new(leftLine, valPrice, rightLine, valPrice,
                                color = VA_COLOR, width = 1, style = line.style_dashed)
            if i_showLabels
                vahLabel := label.new(rightLine, vahPrice,
                                       "VAH " + str.tostring(vahPrice, format.mintick),
                                       style     = label.style_label_left,
                                       color     = color.new(VA_COLOR, 25),
                                       textcolor = color.white,
                                       size      = size.small)
                valLabel := label.new(rightLine, valPrice,
                                       "VAL " + str.tostring(valPrice, format.mintick),
                                       style     = label.style_label_left,
                                       color     = color.new(VA_COLOR, 25),
                                       textcolor = color.white,
                                       size      = size.small)

        // --- Previous-session VAH/VAL (the breakout-alert reference) ---
        if i_showPrevVA and not na(prevVAH) and not na(prevVAL)
            prevVAHLine := line.new(leftLine, prevVAH, rightLine, prevVAH,
                                     color = WARNING_COLOR, width = 1, style = line.style_solid)
            prevVALLine := line.new(leftLine, prevVAL, rightLine, prevVAL,
                                     color = WARNING_COLOR, width = 1, style = line.style_solid)
            if i_showLabels
                prevVAHLabel := label.new(rightLine, prevVAH,
                                           "prevVAH " + str.tostring(prevVAH, format.mintick),
                                           style     = label.style_label_left,
                                           color     = color.new(WARNING_COLOR, 25),
                                           textcolor = color.white,
                                           size      = size.small)
                prevVALLabel := label.new(rightLine, prevVAL,
                                           "prevVAL " + str.tostring(prevVAL, format.mintick),
                                           style     = label.style_label_left,
                                           color     = color.new(WARNING_COLOR, 25),
                                           textcolor = color.white,
                                           size      = size.small)

        // --- One-shot breakout detection vs. the previous session's VAH/VAL ---
        // Yesterday's end-of-day value area is a stable, non-shifting reference
        // — the canonical market-profile breakout semantic. Today's developing
        // VAH/VAL evolve as new volume arrives, so they are not used for alerts.
        if not na(close[1]) and not na(prevVAH) and not na(prevVAL)
            if not vahBrokenToday and close[1] <= prevVAH and close > prevVAH
                vahBrokenToday := true
                vahBreak       := true
            if not valBrokenToday and close[1] >= prevVAL and close < prevVAL
                valBrokenToday := true
                valBreak       := true

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// All visuals (histogram boxes, POC/VAH/VAL lines and labels) are managed via
// the persistent draw-handle vars in Section 3 and rebuilt fresh each confirmed
// bar. No additional plot calls are required for this overlay indicator.

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(vahBreak and i_alertVAH, title = "Break Above Previous VAH",
    message = "Volume Profile Lite [DYNA]: Price closed above the previous session's value area high.")
alertcondition(valBreak and i_alertVAL, title = "Break Below Previous VAL",
    message = "Volume Profile Lite [DYNA]: Price closed below the previous session's value area low.")
````
