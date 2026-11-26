# GProf - FVG Alerts

- url: https://www.tradingview.com/script/nn1xPUFB-GProf-FVG-Alerts/
- type: indicator
- pine_id: PUB;37ee2428decd405e995c4612c76200c9
- version: 6.0

## Description

GProf - FVG Alerts
═══════════════════════════════════════════

OVERVIEW

This indicator detects standard 3-candle Fair Value Gaps (FVGs), draws every gap as a live zone, and fires an alert only when a gap is both large enough to matter and sits in an area with room to the left. It is built to surface displacement worth trading and stay silent on the rest.

Everything confirms on the close of the third candle — nothing is drawn or alerted intrabar, so a gap that appears mid-candle and vanishes before the close never produces a false alert.

───────────────────────────────────────────
DETECTION

• Bullish FVG — the current candle's low is above the high from two bars ago. The zone spans from that prior high (bottom) to the current low (top).
• Bearish FVG — the current candle's high is below the low from two bars ago. The zone spans from the current high (bottom) to that prior low (top).

───────────────────────────────────────────
THE ALERT FILTER — SIZE AND ROOM

Every FVG is drawn. An alert fires only when BOTH conditions are met:

1. SIZE — the gap is at least a set percentage of the daily ATR (default 2%), with a tick floor. Measuring against ATR rather than a fixed point value makes the threshold portable: it means the same thing on a fast index future and a slow one, and it adapts as volatility changes. A fixed-points mode is also available.

2. ROOM TO THE LEFT — the origin of the impulse that created the gap must be in clean territory: the anchor level (the extreme of the move) has few prior candle bodies overlapping it across a lookback window (defaults: 3 bodies over 20 bars). A gap that forms in the middle of prior congestion is drawn but does not alert.

Gaps are shown in three tiers so the chart teaches you over time:
• Full color — qualified on size AND room: these alert.
• Muted gray — big enough, but the anchor lacked room to the left: drawn, silent.
• Faint — below the size threshold: drawn, silent.

Watching which large gaps had room and which did not, and how price treats each, tells you where your own thresholds belong.

───────────────────────────────────────────
ZONE MANAGEMENT

• Zones extend right until fully filled: a bullish gap is removed when price trades down through the bottom of the zone, a bearish gap when price trades up through the top.
• Partial fills leave the zone at its original size — the original boundaries remain the reference, not the shrinking remainder.
• A configurable cap limits how many zones stay on the chart; oldest are removed first.

───────────────────────────────────────────
ALERTS — HOW TO SET UP

1. Add the indicator to your chart.
2. Open the Alert dialog and set the Condition to this indicator.
3. Select "Any alert() function call".
4. Set Expiration to Open-ended and choose your notification methods.

One alert covers everything. The Alert Direction input controls what fires: Both, Bullish Only, Bearish Only, or Off. Alert messages include the symbol, timeframe, direction, gap size in points and as a percentage of ATR, whether room-to-the-left is clean, and the exact zone boundaries.

Note: TradingView alerts snapshot the indicator's settings when created. If you change the size threshold or other settings later, edit and re-save (or recreate) the alert for the new values to take effect.

───────────────────────────────────────────
HOW TO USE IT

FVGs mark displacement — areas price moved through so fast that an imbalance was left behind. Many traders study them as zones of interest for retracement entries, targets, or invalidation. This indicator identifies and sizes the gaps, flags the significant ones that also have room to the left, and otherwise stays out of the way. Combine it with your own market structure analysis, session context, and risk management.

This indicator identifies a chart pattern. It does not generate buy/sell recommendations, does not place trades, and does not replace your own analysis and risk management.

───────────────────────────────────────────
TECHNICAL NOTES

• Non-repainting: detection, drawing, and alerts occur on confirmed bar closes only.
• Works on any symbol and timeframe. Size thresholds are a percentage of daily ATR with tick floors, so they travel across instruments and volatility regimes; a fixed-points mode is available.
• Colors, transparency, borders, size threshold, and the room-to-the-left lookback are fully configurable.

───────────────────────────────────────────
DISCLAIMER

This script is for informational and educational purposes only. It does not constitute financial, investment, or trading advice. Fair Value Gaps are a chart pattern, not a guarantee of future price behavior. All trading decisions made using this tool are solely the responsibility of the user.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  GProf - FVG Alerts  v1.10.2
//  Companion tool for the Golden Zone Reload strategy
//
//  ---- CONDENSED HISTORY (full notes live in PROJECT_HANDOFF.md) ----
//  v1.0  3-candle FVG detection, bar-close confirmation, fixed-point
//        size filter, two-tier drawing, full fill = box removed.
//  v1.1  "% of Daily ATR" threshold mode (default 2.0% of ATR(14d),
//        10-tick floor). ATR from COMPLETED daily bars — never repaints.
//  v1.2  Room to the Left (F2) alert gate. Anchor = candle-1 extreme,
//        count prior overlapping BODIES in the previous Y bars.
//  v1.3  Anchor moved OFF candle-1 to the highest high / lowest low of
//        the last N bars (M2K Jul 10: displacement lagged the sweep top).
//  v1.4  Anchor becomes the IMPULSE ORIGIN via walk-back. Session-break
//        exclusion added (a window spanning the daily halt is a calendar
//        artifact, not displacement).
//  v1.5  Walk-back made scale-aware (stop on a 25% retrace of the leg).
//        RTL window CENTRED on the origin. ANCHOR BAND introduced.
//  v1.6  CHAIN AWARENESS: RTL identifies a chain START, not gap quality.
//  v1.7  Chains die at the 18:00 ET session boundary. MIN IMPULSE LEG
//        added. Colour keyed to whether a gap actually alerts. Late in
//        v1.7 the chain veto was REMOVED.
//  v1.8  RTL window no longer counts the FVG's own three candles
//        (lo clamped to FVG_SPAN). DEBUG gained `win` and `hits`.
//  v1.9  RTL IS MEASURED AT THE GAP'S OWN CANDLE 1 (c1 low for bullish,
//        c1 high for bearish). Walk-back removed from the RTL path.
//        Window = offsets FVG_SPAN .. FVG_SPAN + rtlBars - 1 (3..22).
//        Min Impulse Leg default 0 (off). No chain veto. Alert = size
//        AND room to the left.
//  v1.9.1 Max Overlapping Bodies -> 0, Anchor Band -> 1.5.
//  v1.9.2 Max Overlapping Bodies back to 3 (0 silenced valid reversal
//        setups, e.g. MCL Aug 28 bullish +3R).
//
//  v1.10 — BREAKOUT EXCEPTION TO RTL + ANCHOR BAND DEFAULT 1.0.
//
//         THE PROBLEM. MNQ Oct 7, ~11:00 ET bullish gap. Candle 1's low
//         sat inside the 07:00-10:30 range under the Previous ATH line,
//         so range bodies filled the RTL window at that level and the
//         gap went silent. But the impulse was BREAKING OUT of that
//         range: the bodies to the left were the base it launched from,
//         not congestion in its way. Price had last traded at the gap's
//         level 57 bars earlier (~06:00).
//
//         THE RULE (trader's definition). A breakout means price has
//         left an area it has NOT just been at. When RTL fails, the gap
//         still alerts if it sits beyond every candle BODY in the
//         previous `brkBars` bars (default 40 x 5m). (v1.10 tested the
//         gap's NEAR edge — see v1.10.2 for the current edge.)
//         Bodies only, as everywhere else in RTL — a wick into the zone
//         is a probe, not acceptance. The FVG's own three candles are
//         never scanned. 40 was chosen by the trader as "more than 20,
//         not necessarily 57": inside 40 bars, "we were just there".
//
//         Gaps that pass RTL normally are UNCHANGED. The breakout path
//         is consulted only when RTL fails. The alert text says
//         "RTL breakout above/below X" instead of "RTL clean at X",
//         where X = the highest (lowest) body in the breakout window.
//
//         TOGGLE: "Breakout overrides RTL" (default ON). OFF = exactly
//         v1.9.2 alert behaviour.
//
//         ANCHOR BAND DEFAULT 1.5 -> 1.0, to match the engine and the
//         value already on the trader's charts. Input default only.
//
//         TO REVERT: Breakout toggle OFF + Anchor Band 1.5 = v1.9.2.
//
//  v1.10.1 — BREAKOUT GAPS GET A VISIBLE BORDER. DISPLAY ONLY.
//         Breakout alerts use the same green/red fill as every other
//         alert. They are told apart by a solid, fully opaque border
//         (width 3) drawn in the same colour. New input "Always border
//         breakout gaps" (default ON) works independently of "Show Box
//         Borders", which still governs all other boxes.
//         NOTE: if "Show Box Borders" is turned ON, every alert box gets
//         a border and breakouts no longer stand out.
//         TO REVERT: "Always border breakout gaps" OFF = v1.10.
//
//  v1.10.2 — BREAKOUT TESTED AT THE GAP'S FAR EDGE.
//
//         THE PROBLEM. MES Oct 12, ~04:30 ET bearish gap 7878.25 -
//         ~7875.75, breaking down out of the 01:00-04:30 consolidation.
//         DEBUG: "overlaps 6 (max 3)", "brk body btm 7876.50 @28 vs gap
//         top 7878.25", "breakout no" -> silent. The impulse broke out
//         of the range, but candle 1 started just inside it, so the top
//         1.75 pts of the gap were still inside the range bodies.
//         The trader reads this as a breakout: the gap launched from the
//         edge of the range and ENDED outside it.
//
//         THE RULE. The breakout window's extreme body is now compared
//         with the gap's FAR edge (candle 3) instead of its near edge
//         (candle 1):
//           bullish: highest body top in offsets 3..3+brkBars-1
//                    < candle 3 LOW  (the gap TOP)
//           bearish: lowest body bottom in that window
//                    > candle 3 HIGH (the gap BOTTOM)
//         i.e. "the gap ENDS beyond the range" instead of "the gap
//         STARTS beyond the range". Strictly additive: every gap that
//         passed v1.10.1's test passes this one. MNQ Oct 7 still alerts;
//         MES Oct 12 now alerts.
//
//         TRADE-OFF TO WATCH. A gap that starts deep inside the range
//         and only just pokes out at its far edge also counts. If those
//         prove poor, add a minimum clearance beyond the range.
//
//         ENGINE: NOT YET MIRRORED. Engine spec for the algo thread:
//           bull: max(max(open,close)) over offsets 3..42 < candle 3 LOW
//           bear: min(min(open,close)) over offsets 3..42 > candle 3 HIGH
//
//         TO REVERT to v1.10.1: set brkEdgeBull = high[2] and
//         brkEdgeBear = low[2] (the near edges) in the Detection block.
// ─────────────────────────────────────────────────────────────
indicator("GProf - FVG Alerts", shorttitle = "GProf FVG", overlay = true, max_boxes_count = 500, max_labels_count = 300, max_bars_back = 500)

// ── Inputs ───────────────────────────────────────────────────
grpD = "Detection"
thrMode   = input.string("% of Daily ATR", "Threshold Mode", options = ["Fixed Points", "% of Daily ATR"], group = grpD,
     tooltip = "Fixed Points: minimum gap size is a constant, set per chart. % of Daily ATR: minimum gap scales with the instrument's volatility — portable across products and regimes. After changing mode, RECREATE your TradingView alert (alerts snapshot settings at creation).")
minGapPts = input.float(5.0, "Minimum Gap Size (points) — Fixed mode", minval = 0.0, step = 0.25, group = grpD,
     tooltip = "Used only in Fixed Points mode.")
atrPctIn  = input.float(2.0, "Minimum Gap (% of Daily ATR) — ATR mode", minval = 0.1, maxval = 20.0, step = 0.05, group = grpD,
     tooltip = "Used only in ATR mode. 2.0% of a 755-pt ATR = ~15 pts on MNQ. A qualified GZ-setup gap measured ~2.9%.")
atrLenIn  = input.int(14, "ATR Length (days) — ATR mode", minval = 1, maxval = 100, group = grpD,
     tooltip = "ATR computed from COMPLETED daily bars only — the threshold is stable all day and never repaints.")
minTicks  = input.int(10, "Minimum Threshold (ticks) — ATR mode floor", minval = 0, group = grpD,
     tooltip = "Floor for fine-tick / low-ATR products where a pure percentage would sit inside spread noise (e.g. lifts MES to ~2.5 pts).")
showSub   = input.bool(true, "Show Sub-Threshold Gaps (muted)", group = grpD)

grpF = "Room to the Left (F2)"
useRTL   = input.bool(true, "Require Room to the Left for Alerts", group = grpF,
     tooltip = "All FVGs still draw. Only qualified gaps (>= size threshold) that ALSO pass room-to-the-left (or the breakout exception below) fire an alert. Matches F2 in the GZ Developer Spec.")
rtlBars  = input.int(20, "Lookback (bars) — Y", minval = 3, maxval = 200, group = grpF,
     tooltip = "How many bars BEFORE the gap to check for prior interaction at candle 1's extreme. Spec F2 starting value: 20.")
rtlMax   = input.int(3, "Max Overlapping Bodies — X", minval = 0, maxval = 20, group = grpF,
     tooltip = "Anchor level = the UPPER WICK of candle 1 (bearish) / the LOWER WICK of candle 1 (bullish) — the candle that starts the gap. Fewer than or equal to this many prior candle BODIES may overlap that level for it to count as clean. DEFAULT 3. 0 silenced valid reversal setups (MCL Aug 28 bullish +3R reads 4 overlaps). Both under live test.")
anchorBand = input.float(1.0, "Anchor Band (% of Daily ATR)", minval = 0.0, maxval = 20.0, step = 0.5, group = grpF,
     tooltip = "An extreme is a ZONE, not a tick. Bodies are tested against candle 1's extreme +/- this band, on BOTH sides. DEFAULT 1.0 as of v1.10 (matches the engine). The width scales with ATR, so the same percentage is a different distance per instrument (1.0% of a 457-pt MNQ ATR = ~4.6 pts). Wicks are never counted; only bodies are tested. Set to 0 for an exact-tick test.")
useBrk   = input.bool(true, "Breakout overrides RTL", group = grpF,
     tooltip = "When RTL fails, the gap still alerts if it ENDS beyond every candle BODY in the breakout lookback — i.e. price has left an area it has not just been at. Bullish: highest body top in the window is below the gap TOP (candle 3 low). Bearish: lowest body bottom is above the gap BOTTOM (candle 3 high). OFF = v1.9.2 behaviour.")
brkBars  = input.int(40, "Breakout Lookback (bars)", minval = 3, maxval = 400, group = grpF,
     tooltip = "Bars BEFORE the gap whose bodies the gap must end beyond. DEFAULT 40 (5m). MNQ Oct 7: price last traded at the gap's level 57 bars earlier — a breakout. Inside 40 bars, 'we were just there'.")
minLegPct = input.float(0.0, "Min Impulse Leg (% of Daily ATR) — 0 = off", minval = 0.0, maxval = 50.0, step = 0.5, group = grpF,
     tooltip = "DEFAULT OFF since v1.9. Measures candle 1's extreme to the gap, which is roughly the gap itself, so any non-zero value silences almost everything. Kept for the case where counter-trend gaps become a problem again.")
showDebug = input.bool(false, "DEBUG: show anchor + overlap count", group = grpF,
     tooltip = "Prints a label on every qualified gap showing the anchor price (candle 1's extreme), the RTL window scanned, which offsets scored an overlap, the total, and the breakout test. Offset 0 is the current bar; the FVG occupies offsets 0-2 and is never scanned.")

grpS = "Display"
maxGaps      = input.int(20, "Max Gaps Displayed (per side)", minval = 1, maxval = 200, group = grpS,
     tooltip = "Oldest boxes are removed first once the limit is reached. Applied separately to bullish and bearish gaps.")
bullColor    = input.color(color.new(#00E676, 45), "ALERTS — Bullish", group = grpS,
     tooltip = "These are the only gaps that fire an alert: qualified size AND (room to the left at candle 1's extreme OR breakout).")
bearColor    = input.color(color.new(#FF1744, 45), "ALERTS — Bearish", group = grpS)
subBullColor = input.color(color.new(color.teal, 93), "Sub-Threshold Bullish", group = grpS)
subBearColor = input.color(color.new(color.red, 93), "Sub-Threshold Bearish", group = grpS)
noRoomBull   = input.color(color.new(color.teal, 88), "Silent — no room (Bull)", group = grpS,
     tooltip = "Big enough to alert on size, but bodies already sit at candle 1's extreme and it is not a breakout — drawn, not alerted.")
noRoomBear   = input.color(color.new(color.red, 88), "Silent — no room (Bear)", group = grpS)
showBorder   = input.bool(false, "Show Box Borders", group = grpS)
brkBorder    = input.bool(true, "Always border breakout gaps", group = grpS,
     tooltip = "v1.10.1. Breakout alerts keep the normal alert colour and get a solid opaque border so they can be told apart at a glance. Independent of 'Show Box Borders' — but if that is ON, all alert boxes are bordered and breakouts no longer stand out.")
showThr      = input.bool(true, "Show Effective Threshold Readout", group = grpS,
     tooltip = "Small corner readout displaying the current minimum gap size in points for this chart.")

grpA = "Alerts"
alertMode = input.string("Both", "Alert Direction", options = ["Both", "Bullish Only", "Bearish Only", "Off"], group = grpA,
     tooltip = "In the TradingView alert dialog, select this indicator and the condition 'Any alert() function call'.")

// ── Constants ────────────────────────────────────────────────
// The FVG occupies bar offsets 0, 1 and 2 at confirmation:
//   offset 2 = candle 1 — ITS EXTREME IS THE RTL ANCHOR (v1.9)
//   offset 1 = the displacement candle
//   offset 0 = candle 3, the confirming bar — ITS EXTREME IS THE
//              BREAKOUT EDGE (v1.10.2)
// Room is measured STRICTLY BEFORE the pattern.
int FVG_SPAN = 3

// ── Effective threshold ──────────────────────────────────────
atrDaily = request.security(syminfo.tickerid, "D", ta.atr(atrLenIn)[1], lookahead = barmerge.lookahead_off)

float effThreshold = thrMode == "Fixed Points" ? minGapPts :
     na(atrDaily) ? na : math.max(atrPctIn / 100.0 * atrDaily, minTicks * syminfo.mintick)

// ── State ────────────────────────────────────────────────────
var array<box> bullBoxes = array.new<box>()
var array<box> bearBoxes = array.new<box>()

// ── Helpers ──────────────────────────────────────────────────
borderCol(color c) =>
    showBorder ? c : color.new(color.gray, 100)

trimOldest(array<box> boxes) =>
    while boxes.size() > maxGaps
        box.delete(boxes.shift())

// ── ROOM TO THE LEFT (v1.9) ──────────────────────────────────
// Anchor = candle 1's own extreme, WICK INCLUDED. Window = the rtlBars
// bars immediately before the pattern. BODIES ONLY, tested against a
// two-sided band. Returns [overlaps, loUsed, hiUsed, hitOffsets].
roomToLeftScan(float anchor) =>
    int    overlaps = 0
    string hits     = ""
    int    lo       = FVG_SPAN
    int    hi       = FVG_SPAN + rtlBars - 1
    float  band     = na(atrDaily) ? 0.0 : anchorBand / 100.0 * atrDaily
    float  bandHi   = anchor + band
    float  bandLo   = anchor - band
    for j = lo to hi
        bodyTop = math.max(open[j], close[j])
        bodyBot = math.min(open[j], close[j])
        if bodyTop >= bandLo and bodyBot <= bandHi
            overlaps += 1
            hits := hits + (str.length(hits) == 0 ? "" : ",") + str.tostring(j)
    [overlaps, lo, hi, hits]

roomToLeft(float anchor) =>
    [n, wLo, wHi, hitStr] = roomToLeftScan(anchor)
    n <= rtlMax

rtlDebugText(float anchor) =>
    [n, wLo, wHi, hitStr] = roomToLeftScan(anchor)
    "\nwin " + str.tostring(wLo) + ".." + str.tostring(wHi) +
     "\nhits " + (str.length(hitStr) == 0 ? "none" : hitStr) +
     "\noverlaps " + str.tostring(n) + " (max " + str.tostring(rtlMax) + ")"

// ── BREAKOUT EXCEPTION (v1.10, far edge since v1.10.2) ───────
// Bullish: the highest body top in the breakout window must be BELOW the
// gap's far edge (gap TOP = candle 3 low). Bearish: the lowest body
// bottom must be ABOVE the gap's far edge (gap BOTTOM = candle 3 high).
// The gap therefore ENDS in territory price has not traded (on a body
// basis) for brkBars bars.
// Returns [isBreakout, extreme, extremeOffset, lo, hi].
breakoutScan(bool isBull, float gapEdge) =>
    int   lo     = FVG_SPAN
    int   hi     = FVG_SPAN + brkBars - 1
    float ext    = na
    int   extOff = na
    for j = lo to hi
        bodyTop = math.max(open[j], close[j])
        bodyBot = math.min(open[j], close[j])
        if isBull
            if na(ext) or bodyTop > ext
                ext    := bodyTop
                extOff := j
        else
            if na(ext) or bodyBot < ext
                ext    := bodyBot
                extOff := j
    bool ok = na(ext) ? false : (isBull ? ext < gapEdge : ext > gapEdge)
    [ok, ext, extOff, lo, hi]

brkDebugText(bool isBull, float gapEdge) =>
    [ok, ext, extOff, wLo, wHi] = breakoutScan(isBull, gapEdge)
    "\nbrk win " + str.tostring(wLo) + ".." + str.tostring(wHi) +
     "\nbrk " + (isBull ? "body top " : "body btm ") + str.tostring(ext, format.mintick) +
     " @" + str.tostring(extOff) +
     (isBull ? " vs gap top " : " vs gap btm ") + str.tostring(gapEdge, format.mintick) +
     "\nbreakout " + (ok ? "YES" : "no") + (useBrk ? "" : " (toggle off)")

// ── Mitigation: full fill = remove ───────────────────────────
if barstate.isconfirmed
    if bullBoxes.size() > 0
        for i = bullBoxes.size() - 1 to 0
            b = bullBoxes.get(i)
            if low <= box.get_bottom(b)
                box.delete(b)
                bullBoxes.remove(i)
    if bearBoxes.size() > 0
        for i = bearBoxes.size() - 1 to 0
            b = bearBoxes.get(i)
            if high >= box.get_top(b)
                box.delete(b)
                bearBoxes.remove(i)

// ── CHAIN STATE ──────────────────────────────────────────────
// Tracked and reported in DEBUG only. It vetoes NOTHING. Kept because the
// reload logic downstream (max 3 per impulse chain) wants to know who has
// control.
var int   chainDir    = 0     // +1 long, -1 short, 0 none
var float chainOrigin = na    // anchor of the gap that started the chain
var int   chainCount  = 0     // reload gaps seen since the chain started

// ── Detection (evaluated on confirmed bars only) ─────────────
bool sessionBreak = (time - time[1]) > 6 * 60 * 1000 or (time[1] - time[2]) > 6 * 60 * 1000
bool  bullFVG  = low > high[2] and not sessionBreak
bool  bearFVG  = high < low[2] and not sessionBreak
float bullSize = bullFVG ? low - high[2] : na
float bearSize = bearFVG ? low[2] - high : na

// RTL ANCHORS — candle 1's extreme, wick included.
float anchBull = low[2]
float anchBear = high[2]

// BREAKOUT EDGES (v1.10.2) — the gap's FAR edge, i.e. candle 3.
// v1.10/v1.10.1 used the near edge: high[2] (bull) / low[2] (bear).
float brkEdgeBull = low      // bullish gap TOP
float brkEdgeBear = high     // bearish gap BOTTOM

newSessionDay = ta.change(dayofmonth(time + 6 * 60 * 60 * 1000,
     "America/New_York")) != 0

if barstate.isconfirmed
    if newSessionDay and chainDir != 0
        chainDir    := 0
        chainOrigin := na
        chainCount  := 0

    if chainDir != 0 and not na(chainOrigin)
        if (chainDir > 0 and close < chainOrigin) or (chainDir < 0 and close > chainOrigin)
            chainDir    := 0
            chainOrigin := na
            chainCount  := 0

    // ── Bullish FVG: zone high[2] (bottom) .. low (top) ──
    if bullFVG
        bool qualified = not na(effThreshold) and bullSize >= effThreshold
        bool rtlClean  = not useRTL or roomToLeft(anchBull)
        [brkYes, brkExt, brkOff, brkLo, brkHi] = breakoutScan(true, brkEdgeBull)
        bool viaBrk    = useRTL and useBrk and not rtlClean and brkYes
        bool hasRoom   = rtlClean or viaBrk
        float legBull  = math.abs(low - anchBull)
        bool  bigLeg   = minLegPct <= 0.0 or (na(atrDaily) ? false : legBull >= minLegPct / 100.0 * atrDaily)
        bool willAlert = qualified and hasRoom and bigLeg
        if qualified or showSub
            color c = not qualified ? subBullColor : (willAlert ? bullColor : noRoomBull)
            if showDebug and qualified
                label.new(bar_index, high[2],
                     "anchor " + str.tostring(anchBull, format.mintick) + " (c1 low)" +
                     rtlDebugText(anchBull) +
                     "\nband +/-" + str.tostring(anchorBand / 100.0 * atrDaily, "#.##") +
                     brkDebugText(true, brkEdgeBull) +
                     (minLegPct > 0.0 ? "\nleg " + str.tostring(legBull, "#.##") + " / min " +
                     str.tostring(minLegPct / 100.0 * atrDaily, "#.##") : "") +
                     "\nchain " + (chainDir == 0 ? "none" : chainDir > 0 ? "LONG" : "SHORT") +
                     (chainDir == 0 ? "" : " from " + str.tostring(chainOrigin, format.mintick)) +
                     "\n" + (willAlert ? (viaBrk ? "-> ALERTS (breakout)" : "-> ALERTS") : "-> silent"),
                     style = label.style_label_up, size = size.small,
                     color = color.new(color.gray, 20), textcolor = color.white)
            color bc = willAlert and viaBrk and brkBorder ? color.new(c, 0) : borderCol(c)
            box nb = box.new(bar_index - 2, low, bar_index, high[2],
                 border_color = bc, bgcolor = c,
                 border_style = willAlert ? line.style_solid : line.style_dashed,
                 border_width = willAlert ? 3 : 1, extend = extend.right)
            bullBoxes.push(nb)
            trimOldest(bullBoxes)
        if willAlert
            chainDir    := 1
            chainOrigin := anchBull
            chainCount  := 0
            if alertMode == "Both" or alertMode == "Bullish Only"
                string why = viaBrk ? "RTL breakout above " + str.tostring(brkExt, format.mintick) :
                     "RTL clean at " + str.tostring(anchBull, format.mintick)
                alert(syminfo.ticker + " " + timeframe.period + " BULLISH FVG " +
                     str.tostring(bullSize, "#.##") + " pts (min " + str.tostring(effThreshold, "#.##") +
                     "), " + why + ": " +
                     str.tostring(high[2], format.mintick) + " - " + str.tostring(low, format.mintick),
                     alert.freq_once_per_bar)
        else if qualified and chainDir == 1
            chainCount := chainCount + 1

    // ── Bearish FVG: zone high (bottom) .. low[2] (top) ──
    if bearFVG
        bool qualified = not na(effThreshold) and bearSize >= effThreshold
        bool rtlClean  = not useRTL or roomToLeft(anchBear)
        [brkYes, brkExt, brkOff, brkLo, brkHi] = breakoutScan(false, brkEdgeBear)
        bool viaBrk    = useRTL and useBrk and not rtlClean and brkYes
        bool hasRoom   = rtlClean or viaBrk
        float legBear  = math.abs(anchBear - high)
        bool  bigLeg   = minLegPct <= 0.0 or (na(atrDaily) ? false : legBear >= minLegPct / 100.0 * atrDaily)
        bool willAlert = qualified and hasRoom and bigLeg
        if qualified or showSub
            color c = not qualified ? subBearColor : (willAlert ? bearColor : noRoomBear)
            if showDebug and qualified
                label.new(bar_index, low[2],
                     "anchor " + str.tostring(anchBear, format.mintick) + " (c1 high)" +
                     rtlDebugText(anchBear) +
                     "\nband +/-" + str.tostring(anchorBand / 100.0 * atrDaily, "#.##") +
                     brkDebugText(false, brkEdgeBear) +
                     (minLegPct > 0.0 ? "\nleg " + str.tostring(legBear, "#.##") + " / min " +
                     str.tostring(minLegPct / 100.0 * atrDaily, "#.##") : "") +
                     "\nchain " + (chainDir == 0 ? "none" : chainDir > 0 ? "LONG" : "SHORT") +
                     (chainDir == 0 ? "" : " from " + str.tostring(chainOrigin, format.mintick)) +
                     "\n" + (willAlert ? (viaBrk ? "-> ALERTS (breakout)" : "-> ALERTS") : "-> silent"),
                     style = label.style_label_down, size = size.small,
                     color = color.new(color.gray, 20), textcolor = color.white)
            color bc = willAlert and viaBrk and brkBorder ? color.new(c, 0) : borderCol(c)
            box nb = box.new(bar_index - 2, low[2], bar_index, high,
                 border_color = bc, bgcolor = c,
                 border_style = willAlert ? line.style_solid : line.style_dashed,
                 border_width = willAlert ? 3 : 1, extend = extend.right)
            bearBoxes.push(nb)
            trimOldest(bearBoxes)
        if willAlert
            chainDir    := -1
            chainOrigin := anchBear
            chainCount  := 0
            if alertMode == "Both" or alertMode == "Bearish Only"
                string why = viaBrk ? "RTL breakout below " + str.tostring(brkExt, format.mintick) :
                     "RTL clean at " + str.tostring(anchBear, format.mintick)
                alert(syminfo.ticker + " " + timeframe.period + " BEARISH FVG " +
                     str.tostring(bearSize, "#.##") + " pts (min " + str.tostring(effThreshold, "#.##") +
                     "), " + why + ": " +
                     str.tostring(high, format.mintick) + " - " + str.tostring(low[2], format.mintick),
                     alert.freq_once_per_bar)
        else if qualified and chainDir == -1
            chainCount := chainCount + 1

// ── Effective threshold readout ──────────────────────────────
var table thrTbl = na
if showThr and barstate.islast
    if na(thrTbl)
        thrTbl := table.new(position.bottom_right, 1, 1,
             bgcolor = color.new(color.black, 55),
             border_color = color.new(color.gray, 50), border_width = 1)
    modeTag = thrMode == "Fixed Points" ? "fixed" : str.tostring(atrPctIn, "#.##") + "% ATR"
    thrStr  = na(effThreshold) ? "FVG min: N/A (ATR warmup)" : "FVG min: " + str.tostring(effThreshold, "#.##") + " pts (" + modeTag + ")"
    thrTbl.cell(0, 0, thrStr, text_color = color.new(color.white, 20), text_size = size.small,
         bgcolor = color.new(color.black, 55))
````
