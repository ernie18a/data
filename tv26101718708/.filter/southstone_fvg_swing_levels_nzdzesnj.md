# SouthStone FVG Swing Levels

- url: https://www.tradingview.com/script/NZDzEsnJ-SouthStone-FVG-Swing-Levels/
- type: indicator
- pine_id: PUB;c4c7cda6e54e4ffbac1b73ac38ec5bb4
- version: 1.0

## Description

// Highlights swing highs/lows on a user-selected higher timeframe (default H1)
// that have had a Fair Value Gap (3-bar imbalance) form through them. These
// levels tend to act as high-probability retest targets because price
// "gapped" away from them and liquidity remains.
//
// All detection runs on the selected HTF. Lines use time-based x-coordinates
// so they render identically on ANY chart timeframe. On M5 / M15 / M1 the
// H1 levels remain visible, anchored at the actual pivot times.
//
// Logic (runs on HTF, results piped to chart TF):
//   1. Detect pivot highs and pivot lows on HTF via ta.pivothigh/low.
//   2. Store each pivot as "pending".
//   3. On each HTF bar, check if a new 3-bar FVG has formed:
//        Bullish FVG: low[0] > high[2]  -> gap = [high[2], low[0]]
//        Bearish FVG: high[0] < low[2]  -> gap = [high[0], low[2]]
//   4. For each pending pivot:
//      a) If this HTF bar forms a valid FVG whose gap contains the pivot
//         AND the FVG direction matches (bullish for swing highs, bearish
//         for swing lows) -> draw line, pivot done.
//      b) Else if the PREVIOUS HTF bar's range touched the pivot level
//         without being claimed by an FVG here -> discard pivot forever.
//      c) Else -> stay pending.
//   5. Lines extend forward until max line age (in HTF bars) is reached,
//      then stop extending with a fixed right endpoint.
//
// Non-repainting HTF pattern: uses [1] offset with lookahead_on per v6
// best practice. Signals appear at the start of the NEXT HTF bar after
// the confirming one.
//
//   - Default colours split: swing-high lines (bullish FVG break) now blue
//     (#2196f3); swing-low lines (bearish FVG break) remain red (#ef5350).
//     Both remain user-configurable.
//
//   - Major rewrite for HTF support. All detection logic runs inside a
//     request.security() function on the selected HTF, so H1 levels stay
//     anchored in time across all chart timeframes.
//   - Line x-coordinates switched to xloc.bar_time for cross-TF consistency.
//   - maxAge / maxLineAge thresholds now expressed in HTF bars, converted
//     internally to milliseconds for time-based comparisons.
//   - Added HTF input (default "60" = H1).

## Source Code

````pine
//@version=6
// ============================================================================
// SouthStone FVG Swing Levels
// ----------------------------------------------------------------------------
// Highlights swing highs/lows on a user-selected higher timeframe (default H1)
// that have had a Fair Value Gap (3-bar imbalance) form through them. These
// levels tend to act as high-probability retest targets because price
// "gapped" away from them and liquidity remains.
//
// All detection runs on the selected HTF. Lines use time-based x-coordinates
// so they render identically on ANY chart timeframe. On M5 / M15 / M1 the
// H1 levels remain visible, anchored at the actual pivot times.
//
// Logic (runs on HTF, results piped to chart TF):
//   1. Detect pivot highs and pivot lows on HTF via ta.pivothigh/low.
//   2. Store each pivot as "pending".
//   3. On each HTF bar, check if a new 3-bar FVG has formed:
//        Bullish FVG: low[0] > high[2]  -> gap = [high[2], low[0]]
//        Bearish FVG: high[0] < low[2]  -> gap = [high[0], low[2]]
//   4. For each pending pivot:
//      a) If this HTF bar forms a valid FVG whose gap contains the pivot
//         AND the FVG direction matches (bullish for swing highs, bearish
//         for swing lows) -> draw line, pivot done.
//      b) Else if the PREVIOUS HTF bar's range touched the pivot level
//         without being claimed by an FVG here -> discard pivot forever.
//      c) Else -> stay pending.
//   5. Lines extend forward until max line age (in HTF bars) is reached,
//      then stop extending with a fixed right endpoint.
//
// Non-repainting HTF pattern: uses [1] offset with lookahead_on per v6
// best practice. Signals appear at the start of the NEXT HTF bar after
// the confirming one.
//
// Version: 2.02
//
// v2.02 (Apr 2026):
//   - Default colours split: swing-high lines (bullish FVG break) now blue
//     (#2196f3); swing-low lines (bearish FVG break) remain red (#ef5350).
//     Both remain user-configurable.
//
// v2.01 (Apr 2026):
//   - Compile fix: Pine v6 compiler rejects [1] offset on a tuple-returning
//     function call directly. Moved the [1] offsets INSIDE the f_htf()
//     function per the official Pine library pattern — each value carries
//     its own offset. External call site now uses plain f_htf() with
//     lookahead_on outside.
//
// v2.00 (Apr 2026):
//   - Major rewrite for HTF support. All detection logic runs inside a
//     request.security() function on the selected HTF, so H1 levels stay
//     anchored in time across all chart timeframes.
//   - Line x-coordinates switched to xloc.bar_time for cross-TF consistency.
//   - maxAge / maxLineAge thresholds now expressed in HTF bars, converted
//     internally to milliseconds for time-based comparisons.
//   - Added HTF input (default "60" = H1).
//
// v1.05: touch-based discard rule.
// v1.04: close-crossing discard (replaced by v1.05).
// v1.02: fixed inverted direction mapping.
// v1.01: line age cutoff.
// v1.00: initial release.
// ============================================================================

indicator("SouthStone FVG Swing Levels", shorttitle = "Southstone Swings", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ----------------------------------------------------------------------------
// Inputs
// ----------------------------------------------------------------------------
grpHTF    = "Timeframe"
htfTF     = input.timeframe("60", "Detection Timeframe", group = grpHTF, tooltip = "All pivots and FVGs are detected on this timeframe. Lines render on any lower chart timeframe anchored to the actual HTF bar times.")

grpPivot  = "Pivots"
pivLeft   = input.int(5, "Pivot Left Bars",  minval = 1, maxval = 50, group = grpPivot, tooltip = "Number of HTF bars to the left required to confirm a pivot.")
pivRight  = input.int(5, "Pivot Right Bars", minval = 1, maxval = 50, group = grpPivot, tooltip = "Number of HTF bars to the right required to confirm a pivot. Lines appear this many HTF bars after the pivot prints.")

grpFVG    = "Cutoffs"
maxAgeHTF     = input.int(1000, "Max Pending-Pivot Age (HTF bars)", minval = 10, maxval = 10000, group = grpFVG, tooltip = "A pivot that has not been touched or matched within this many HTF bars is discarded. Safety net only — touch-discard normally fires first.")
maxLineAgeHTF = input.int(300,  "Max Line Age (HTF bars)",          minval = 10, maxval = 10000, group = grpFVG, tooltip = "A drawn line stops extending after this many HTF bars. Historical line remains visible with fixed right endpoint.")
maxLines      = input.int(100,  "Max Active Lines",                 minval = 5,  maxval = 500,   group = grpFVG, tooltip = "Cap on how many lines can still be actively extending. Oldest is expired (endpoint fixed) when exceeded.")

grpStyle  = "Style"
bullCol   = input.color(color.new(#2196f3, 0), "Swing-High Line Color", group = grpStyle, tooltip = "Color for swing highs gapped UP through (bullish FVG) — support levels below.")
bearCol   = input.color(color.new(#ef5350, 0), "Swing-Low  Line Color", group = grpStyle, tooltip = "Color for swing lows gapped DOWN through (bearish FVG) — resistance levels above.")
lineWid   = input.int(2, "Line Width", minval = 1, maxval = 4, group = grpStyle)
lineStyl  = input.string("solid", "Line Style", options = ["solid", "dashed", "dotted"], group = grpStyle)
showLabel = input.bool(false, "Show Price Label at Line", group = grpStyle)

grpDebug   = "Debug"
showAllFVG = input.bool(false, "Draw ALL detected FVGs (HTF)", group = grpDebug, tooltip = "Draws every 3-bar HTF FVG regardless of matching. Use to verify detection.")
showMatched= input.bool(false, "Draw FVGs that matched a swing (HTF)", group = grpDebug, tooltip = "Draws only the HTF FVG boxes that triggered a line.")
fvgBullC   = input.color(color.new(color.lime, 80), "Bullish FVG Fill", group = grpDebug)
fvgBearC   = input.color(color.new(color.red,  80), "Bearish FVG Fill", group = grpDebug)

// ----------------------------------------------------------------------------
// Derived
// ----------------------------------------------------------------------------
lStyle = lineStyl == "dashed" ? line.style_dashed : lineStyl == "dotted" ? line.style_dotted : line.style_solid

// Runtime guard: chart TF must be <= HTF
if timeframe.in_seconds() > timeframe.in_seconds(htfTF)
    runtime.error("Chart timeframe must be less than or equal to the Detection Timeframe.")

int htfSec = timeframe.in_seconds(htfTF)  // HTF bar duration in seconds

// ----------------------------------------------------------------------------
// HTF detection function
// Returns, for the HTF bar being read:
//   ph        : pivot-high price (na if no pivot confirmed on this HTF bar)
//   pl        : pivot-low  price (na if none)
//   pivTime   : time of the pivot bar itself, pivRight HTF bars before confirmation
//   fvgTop    : top of gap range if an FVG formed, else na
//   fvgBot    : bottom of gap range if an FVG formed, else na
//   fvgDir    : +1 bullish, -1 bearish, 0 none
//   htfTime   : start time of this HTF bar (for line anchors + FVG box coordinates)
//   prevHigh  : high of the PREVIOUS HTF bar (for touch-discard check)
//   prevLow   : low  of the previous HTF bar
// ----------------------------------------------------------------------------
f_htf() =>
    float _ph = ta.pivothigh(high, pivLeft, pivRight)[1]
    float _pl = ta.pivotlow(low,  pivLeft, pivRight)[1]
    int   _pivTime = not na(_ph) or not na(_pl) ? time[pivRight + 1] : na
    bool  _bull = low[1]  > high[3]
    bool  _bear = high[1] < low[3]
    float _fvgTop = _bull ? low[1] : _bear ? low[3] : na
    float _fvgBot = _bull ? high[3] : _bear ? high[1] : na
    int   _fvgDir = _bull ? 1 : _bear ? -1 : 0
    [_ph, _pl, _pivTime, _fvgTop, _fvgBot, _fvgDir, time[1], high[2], low[2]]

[htfPh, htfPl, htfPivTime, htfFvgTop, htfFvgBot, htfFvgDir, htfTime, htfPrevHigh, htfPrevLow] = request.security(syminfo.tickerid, htfTF, f_htf(), lookahead = barmerge.lookahead_on)

// Detect when a new confirmed HTF bar's data arrives (data-change, TF-independent)
bool newHTF = ta.change(htfTime) != 0

// ----------------------------------------------------------------------------
// Pending-pivot storage (time-based for cross-TF line placement)
// ----------------------------------------------------------------------------
var array<float> pPrice = array.new<float>()
var array<int>   pTime  = array.new<int>()    // time (ms) of the pivot bar itself
var array<int>   pSide  = array.new<int>()    // +1 high, -1 low

// Live line tracking for age expiry + max-count cull
var array<line>  liveLines    = array.new<line>()
var array<int>   liveLineTime = array.new<int>()  // time (ms) line was created

// ----------------------------------------------------------------------------
// Process ONLY on new confirmed HTF bars.
// ----------------------------------------------------------------------------
if newHTF
    // Register newly confirmed HTF pivots
    if not na(htfPh) and not na(htfPivTime)
        pPrice.push(htfPh)
        pTime.push(htfPivTime)
        pSide.push(1)
    if not na(htfPl) and not na(htfPivTime)
        pPrice.push(htfPl)
        pTime.push(htfPivTime)
        pSide.push(-1)

    // DEBUG: draw every detected HTF FVG
    if showAllFVG and htfFvgDir != 0
        color bcAll = htfFvgDir == 1 ? fvgBullC : fvgBearC
        int boxLeft  = htfTime - 2 * htfSec * 1000
        int boxRight = htfTime + htfSec * 1000
        box.new(left = boxLeft, top = htfFvgTop, right = boxRight, bottom = htfFvgBot, bgcolor = bcAll, border_color = color.new(bcAll, 50), border_width = 1, xloc = xloc.bar_time)

    // ------------------------------------------------------------------------
    // Process each pending pivot
    //   (A) FVG match on this HTF bar -> draw line
    //   (B) Previous HTF bar touched pivot without FVG -> discard
    //   (C) Neither -> stay pending
    // ------------------------------------------------------------------------
    if pPrice.size() > 0
        for i = pPrice.size() - 1 to 0
            float pr = pPrice.get(i)
            int   sd = pSide.get(i)
            int   pt = pTime.get(i)

            bool fvgMatch = false
            if htfFvgDir != 0
                bool dirOK  = (sd == 1 and htfFvgDir == 1) or (sd == -1 and htfFvgDir == -1)
                bool inside = pr > htfFvgBot and pr < htfFvgTop
                fvgMatch := dirOK and inside

            bool touchedPrev = htfPrevLow <= pr and htfPrevHigh >= pr

            if fvgMatch
                color lc = sd == 1 ? bullCol : bearCol
                line newL = line.new(x1 = pt, y1 = pr, x2 = htfTime, y2 = pr, xloc = xloc.bar_time, extend = extend.right, color = lc, style = lStyle, width = lineWid)
                liveLines.push(newL)
                liveLineTime.push(htfTime)

                if showLabel
                    label.new(x = htfTime, y = pr, text = str.tostring(pr, format.mintick), xloc = xloc.bar_time, color = color.new(color.black, 100), textcolor = lc, style = label.style_label_left, size = size.small)

                if showMatched
                    color bc = htfFvgDir == 1 ? fvgBullC : fvgBearC
                    int boxLeft  = htfTime - 2 * htfSec * 1000
                    int boxRight = htfTime + htfSec * 1000
                    box.new(left = boxLeft, top = htfFvgTop, right = boxRight, bottom = htfFvgBot, bgcolor = bc, border_color = color.new(bc, 50), border_width = 1, xloc = xloc.bar_time)

                pPrice.remove(i)
                pTime.remove(i)
                pSide.remove(i)
            else if touchedPrev
                pPrice.remove(i)
                pTime.remove(i)
                pSide.remove(i)

    // Age out stale pivots (safety net)
    if pPrice.size() > 0
        int maxAgeMs = maxAgeHTF * htfSec * 1000
        for i = pPrice.size() - 1 to 0
            if htfTime - pTime.get(i) > maxAgeMs
                pPrice.remove(i)
                pTime.remove(i)
                pSide.remove(i)

    // Expire aged lines — stop extending, fix endpoint at current HTF time
    if liveLines.size() > 0
        int maxLineAgeMs = maxLineAgeHTF * htfSec * 1000
        for i = liveLines.size() - 1 to 0
            if htfTime - liveLineTime.get(i) >= maxLineAgeMs
                line expired = liveLines.get(i)
                line.set_extend(expired, extend.none)
                line.set_x2(expired, htfTime)
                liveLines.remove(i)
                liveLineTime.remove(i)

    // Cap active lines — expire oldest when over limit
    if liveLines.size() > maxLines
        line oldest = liveLines.shift()
        int  oldestTime = liveLineTime.shift()
        line.set_extend(oldest, extend.none)
        line.set_x2(oldest, htfTime)
````
