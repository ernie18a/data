# Volume Nodes & Value Migration [MQLSoftware]

- url: https://www.tradingview.com/script/cZmapuQe-Volume-Nodes-Value-Migration-MQLSoftware/
- type: indicator
- pine_id: PUB;a50331fa98164661aabaed21ae1cc2f7
- version: 2.0

## Description

Volume Nodes & Value Migration is an anchored volume profile engine that rebuilds the profile construction itself and then measures how price actually behaves around the profile's own structure: the Point of Control (POC), the Value Area (VAH / VAL), high-volume nodes (HVN) and low-volume nodes (LVN). Instead of a fixed number of rows filled by spreading each bar's volume uniformly, it derives the bin height from ATR at each window anchor, weights every bar's volume toward its close with a triangular kernel, recomputes the POC and Value Area on every confirmed bar so the migration of value is visible as a trail, arms the committed POC and high-volume nodes as trackable levels with an accepted / rejected state machine, and reports measured base rates for those events from the chart's own history.

This is a visual analytical tool intended for chart reading and volume-structure mapping. It does not execute trades and does not provide financial advice.

[b]Key Features[/b]
[list]
[*]Anchored volume profiles (Day / Week / Month / Quarter, or Auto per chart timeframe) with bin height derived from ATR at the window anchor, so the bin count follows the window's range-to-ATR ratio instead of a fixed row number
[*]Close-weighted triangular distribution: each bar's volume is spread over its high-low span with the apex at the close, so the settled price carries more weight than the wick extremes
[*]Developing POC step-trail and Value Area band for the active window, recomputed on every confirmed bar; committed windows keep their final POC and Value Area lines so history stays clean, and consecutive windows are chained with dotted POC-to-POC links labelled with the migration distance in ATR and percent
[*]Committed POC and the strongest HVNs arm as horizontal levels and every return is tracked armed, then accepted (confirmed closes inside the node zone) or rejected (a probe through the node center that closes outside the zone)
[*]Thin Zones (LVN) of each committed window shaded as context — the low-volume gaps price historically transits rather than builds business in
[*]A statistics panel with the live window status, developing value, node states and measured base rates: how often price revisited the prior POC and how node retests resolved, each with its sample size
[*]Four confirmed-bar alerts: node accepted, node rejected, profile committed, prior POC revisited
[/list]

[b]Core Concept[/b]
TradingView already ships volume profile tools (Visible Range, Fixed Range, Session and periodic profiles), and most community profiles repeat the same construction: a fixed row count, each bar's volume spread uniformly across its high-low range, and a final static histogram left for the reader to interpret. This indicator rebuilds each of those stages and then closes the loop by measuring what price actually does at the profile's own levels. Five specific algorithmic elements:

[b]1. Adaptive resolution.[/b] The bin height is derived from ATR at the window anchor (Coarse 0.50, Balanced 0.25, Fine 0.125 ATR per bin), so the number of bins follows the window's range-to-ATR ratio. A quiet range window and an expansion window get structurally comparable profiles on any symbol and timeframe, with no fixed row count and no per-market tuning. If a window's range outgrows the internal cap, bins merge 2:1 and the height doubles — resolution stays bounded by construction.

[b]2. Close-weighted triangular distribution.[/b] Each bar's volume is distributed over its high-low span by a triangular kernel with its apex at the bar close: the weight a price bin receives is the integral of that kernel over the bin. For a bin [a, b] inside a bar with low L, high H and close C, the weight is F(b) - F(a), where F(x) = (x - L)^2 / ((H - L)(C - L)) below the close and F(x) = 1 - (H - x)^2 / ((H - L)(H - C)) above it. The settled price therefore carries more weight than the wick extremes, which a uniform spread treats identically to the body.

[b]3. Developing value area.[/b] POC, VAH and VAL are recomputed on every confirmed bar of the active window; the POC is drawn as a step trail and the Value Area as a developing band, so the reader sees value migrate through the window — POC ladders, value-area expansion and contraction — rather than only the final snapshot. Once a window commits, its trail retires and the final POC / VAH / VAL lines remain, so history stays readable. Committed windows are chained with dotted POC-to-POC links labelled with the migration distance in ATR units and percent.

[b]4. Node acceptance state machine.[/b] When a window commits, its POC and the strongest HVNs (local peaks holding at least half of the POC volume) arm as horizontal levels. Every return is tracked on confirmed bars only: a retest is accepted after N consecutive confirmed closes inside the node zone (node center plus/minus half an ATR, never thinner than one bin), and rejected when a probe trades through the node center and closes outside the zone, or when a visit leaves the zone before N closes. A graze of the zone edge that neither trades the center nor closes inside resolves nothing. Resolutions are latched and marked on the chart; unresolved nodes expire when the next window commits.

[b]5. Measured base rates.[/b] The panel reports observed frequencies from this chart's own loaded history: how often price traded back through the prior window's POC, how often POC retests resolved as accepted, and how often HVN retests were rejected — each with its sample size. Below a minimum sample the panel says "collecting" instead of quoting a percentage. Observed frequencies, not assumptions, and no claims attached to them.

[b]Anatomy of the Display[/b]
[b]The committed histogram[/b] is the final profile of each closed window, drawn from the window's start with bin brightness following volume share; the Value Area is shaded behind it. [b]The POC row and line[/b] mark the single price bin that traded the most volume, labelled `POC · High Volume Node`; [b]VAH and VAL[/b] are dashed lines labelled `VAH · Value Area High` and `VAL · Value Area Low`.

[b]The developing trail[/b] is a step line of the active window's POC with the developing Value Area shaded behind it, both recomputed on every confirmed bar and existing only for the window still forming. The dotted [b]migration link[/b] connects the final POCs of consecutive windows and carries a label with the shift in ATR units and percent.

[b]Node lines[/b] extend right from each commit: the POC node in the bright POC color, HVNs in the profile color, each labelled by kind. When a retest resolves, the line recolors and a mark is printed: `✓ accepted` when price held the required confirmed closes inside the zone, `✕ rejected` when it was turned away. Expired (untested) nodes fade to dotted.

[b]Thin Zones[/b] are faint dashed boxes labelled `LVN · Thin Zone` over the committed window's low-volume gaps. They carry no state machine and no alerts — context only.

[b]The panel[/b] shows the window status (anchor period, bars, bins and bin height), the developing POC and Value Area, the POC migration versus the prior window, the state of each armed node, and the measured base rates with sample sizes.

[b]Notes on Repainting[/b]
[list]
[*]Volume accumulation, developing POC / VAH / VAL updates, node state transitions, base-rate counters and alerts run on confirmed bars only.
[*]A committed profile is final: it is built exclusively from the confirmed bars of a closed window and is never recalculated afterwards.
[*]Node resolutions are latched. An accepted or rejected mark cannot un-happen if price later trades back through the level.
[*]The live developing histogram, POC trail and Value Area band of the current window redraw as the window grows — they are explicitly visual context for the forming profile, not signals.
[*]The script requests no higher-timeframe data at all (no `request.security` calls); window anchors are detected with `timeframe.change` in the chart context.
[*]Alerts are gated by confirmed-bar events and fire once per closed bar, never intra-bar.
[/list]

[b]Typical Analysis Workflow[/b]
A common analytical workflow may include:
[list=1]
[*]Reading the committed profile for the prior window: where the POC sits, how wide the Value Area is, and where the Thin Zones are
[*]Watching the developing POC trail of the active window — a POC laddering in one direction reads as value migrating, a static POC as value building in place
[*]Comparing the migration link and the panel's MIGRATION row to see how far value shifted between windows in ATR terms
[*]Waiting for price to return to an armed node and letting the state machine resolve the retest into accepted or rejected on confirmed bars
[*]Consulting the measured base rates to see how often such revisits and retests actually occurred on this chart's history, then combining the read with other forms of analysis and risk management
[/list]

[b]Configuration[/b]
[b]Anchor Period[/b] - the window each profile covers (Auto, Day, Week, Month, Quarter); Auto follows the chart timeframe and a pick at or below it escalates automatically.
[b]Committed Profiles to Keep[/b] - how many closed windows keep their histogram drawn; statistics always use the full loaded history.
[b]Profile Detail[/b] - target resolution (Coarse / Balanced / Fine), expressed as ATR per bin, never a bin count.
[b]ATR Length[/b] - the ATR lookback used for bin height and migration distances.
[b]Value Area %[/b] - the share of window volume the Value Area encloses.
[b]Track POC / HVN as Nodes[/b] - arms committed levels for the accepted / rejected state machine.
[b]Acceptance Closes[/b] - confirmed closes inside the node zone required for an accepted resolution.
[b]HVN Nodes per Window[/b] - how many high-volume nodes arm besides the POC.
[b]Thin Zones (LVN)[/b] - shades the committed window's low-volume gaps.
[b]Resolved Marks to Keep[/b] - how many resolved node marks stay drawn on the chart; the measured statistics are unaffected.
[b]Rendering[/b] - committed profiles, live developing profile, profile width, the active window's POC trail and Value Area band, migration links, glow, and the four palette colors.
[b]Statistics Panel[/b] - visibility, corner and text size.

[b]Markets and Timeframes[/b]
The indicator can be applied across multiple markets and timeframes:
[list]
[*]Forex
[*]Stocks and Indices
[*]Commodities
[*]Cryptocurrencies
[/list]
Because the bin height, node zones and migration distances are all ATR-based, the visual behavior stays consistent across instruments and timeframes. On symbols that supply no volume data the script weights every bar equally (a time-at-price read) and the panel states so explicitly.

[b]Alerts[/b]
[list]
[*]Node accepted - price printed the required confirmed closes inside an armed node zone
[*]Node rejected - an armed node turned the retest away (probe through the node center with a confirmed close outside the zone)
[*]Profile committed - an anchor window closed; its profile is final and its nodes are armed
[*]Prior POC revisited - price traded back through the previous window's Point of Control
[/list]
All alerts evaluate on confirmed bars to avoid intra-bar oscillation. A dynamic alert message naming the exact event(s) is also provided.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//@version=6
//
// Volume Nodes & Value Migration [MQLSoftware]
//
// A volume-by-price engine that BUILDS the profile differently and then MEASURES how
// price actually behaves around the profile's own structure, instead of restating a
// static histogram. Original contribution (five algorithmic elements):
//   1. Adaptive resolution — bin height is derived from ATR at the window anchor, so
//      the bin COUNT follows the window's range-to-ATR ratio and calibrates itself per
//      symbol and timeframe. The input sets target detail, never a bin count.
//   2. Close-weighted triangular distribution — each bar's volume is spread over its
//      high-low span by a triangular kernel with its apex at the bar CLOSE, so the
//      settled price carries more weight than the wick extremes (a naive uniform
//      spread treats a rejection wick and the settlement identically).
//   3. Developing value area — POC / VAH / VAL are recomputed on every confirmed bar,
//      so the migration of value through the window is visible as a trail, not only
//      as a final snapshot; consecutive windows are chained with POC migration links.
//   4. Node acceptance state machine — when a window commits, its POC and HVN levels
//      arm and every return is tracked armed → accepted (N consecutive confirmed
//      closes inside the node zone) / rejected (pierce with a confirmed close outside).
//      Same arm/trigger discipline used across the MQLSoftware line.
//   5. Measured base rates — the panel reports how often price actually revisited the
//      prior POC and how node retests resolved on THIS chart's history. Observed
//      frequencies with sample sizes, not assumptions.
//
// Repaint policy: volume accumulation, node state transitions, base-rate counters and
// alerts run on CONFIRMED bars only. The live profile, the developing value plots and
// the panel update as visual context — they are not signals.

indicator("Volume Nodes & Value Migration [MQLSoftware]", shorttitle="MQLSoftware - Volume Nodes & Value Migration", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_polylines_count=10)

// ─── CONSTANTS ────────────────────────────────────────────────────────────────
// Neo Slate design tokens — MQLSoftware brand palette
color NS_WHITE = color.rgb(225, 230, 240)
color NS_LBL   = color.rgb(170, 178, 195)
color NS_SEC   = color.rgb( 90,  98, 115)
color NS_BG    = color.new(color.rgb(  8, 11, 18),  4)
color NS_ROW   = color.new(color.rgb( 16, 20, 30),  6)
color NS_INK   = color.rgb( 10,  14,  22)

// Amethyst identity axis — the free hue in the MQLSoftware line (cyan, mint, blue,
// lime×magenta, ice×rose and amber are taken by other products)
color VN_BODY_DEF = #A78BFA  // profile body — amethyst
color VN_POC_DEF  = #E8DEFF  // POC — near-white violet
color VN_ACC_DEF  = #FFAF14  // accepted — house amber token
color VN_REJ_DEF  = #FF4669  // rejected — house rose token

// Hard bin ceiling. Above it the grid re-bins 2:1 (bin height doubles), which keeps
// the box budget and the per-bar workload bounded on any symbol.
int BIN_CAP = 96

// ─── INPUTS ───────────────────────────────────────────────────────────────────
var string GRP_W  = "◆ Profile Window"
var string GRP_D  = "◆ Resolution & Distribution"
var string GRP_N  = "◆ Volume Nodes"
var string GRP_R  = "◆ Rendering"
var string GRP_ST = "◆ Statistics & Panel"

string anchorMode = input.string("Auto", "Anchor Period", group = GRP_W, options = ["Auto", "Day", "Week", "Month", "Quarter"], tooltip = "Each profile covers one anchor window. Auto picks Day for charts up to 30 minutes, Week for slower intraday charts, Month for Daily charts and Year above that. A manual pick at or below the chart timeframe escalates to the next valid period automatically.")
int keepProfiles  = input.int(3, "Committed Profiles to Keep", group = GRP_W, minval = 1, maxval = 4, tooltip = "How many completed windows keep their histogram drawn on the chart. Statistics and base rates always use the full loaded history.")

string detail = input.string("Balanced", "Profile Detail", group = GRP_D, options = ["Coarse", "Balanced", "Fine"], tooltip = "Sets the TARGET resolution, not a bin count. Bin height is derived from ATR at the window anchor — Coarse 0.50 ATR, Balanced 0.25 ATR, Fine 0.125 ATR per bin — so the number of bins follows the window's range-to-ATR ratio and adapts per symbol and timeframe. If a window's range outgrows the internal cap, bins merge 2:1 and the height doubles.")
int atrLen    = input.int(14, "ATR Length", group = GRP_D, minval = 5, maxval = 50, tooltip = "ATR lookback used to derive the bin height at each window anchor and to express POC migration distance.")
int vaPct     = input.int(70, "Value Area %", group = GRP_D, minval = 50, maxval = 90, tooltip = "Share of the window's volume the Value Area encloses. Built by greedy expansion from the POC bin, one bin at a time toward the heavier side.")

bool trackNodes = input.bool(true, "Track POC / HVN as Nodes", group = GRP_N, tooltip = "When a window commits, its POC and the strongest HVNs arm as horizontal levels. Every return is then tracked on confirmed bars: armed → accepted / rejected. Unresolved nodes expire when the next window commits.")
int acceptN     = input.int(2, "Acceptance Closes", group = GRP_N, minval = 1, maxval = 6, tooltip = "Confirmed closes inside the node zone (node center ± half an ATR, never thinner than one bin) required to call a retest ACCEPTED. A probe through the node center that closes outside the zone, or an entry that leaves before the required closes, is REJECTED. Edge grazes resolve nothing.")
int hvnMax      = input.int(2, "HVN Nodes per Window", group = GRP_N, minval = 0, maxval = 3, tooltip = "How many High Volume Nodes arm per committed window, besides the POC. An HVN is a local peak of the profile holding at least half of the POC volume.")
bool showLvn    = input.bool(true, "Thin Zones (LVN)", group = GRP_N, tooltip = "Shades the committed window's Thin Zones (LVN) — contiguous runs of bins holding 20% or less of the average bin volume. Context only: no state machine, no alerts.")
int marksKeep   = input.int(12, "Resolved Marks to Keep", group = GRP_N, minval = 4, maxval = 24, tooltip = "How many resolved ✓ / ✕ node marks (and their recolored level lines) stay on the chart. Older marks are removed to keep dense stretches readable; base-rate statistics are not affected.")

bool showProf  = input.bool(true, "Committed Profiles", group = GRP_R, tooltip = "Draws the final histogram of each committed window, with the Value Area shaded behind it.")
bool showLive  = input.bool(true, "Live Developing Profile", group = GRP_R, tooltip = "Histogram of the current, still-forming window. Redraws as the window grows — visual context, not a signal.")
int profWidth  = input.int(30, "Profile Width (% of window)", group = GRP_R, minval = 10, maxval = 60, tooltip = "Horizontal footprint of the histogram as a share of its window's bar count.")
bool showDev   = input.bool(true, "Developing POC / Value Area", group = GRP_R, tooltip = "Draws the developing POC step-trail and the developing Value Area band for the ACTIVE window, recomputed on every confirmed bar. Committed windows keep their final POC / VAH / VAL lines instead, so history stays clean.")
bool showMig   = input.bool(true, "POC Migration Links", group = GRP_R, tooltip = "Dotted link and distance label between the final POCs of consecutive windows.")
int vaWidth    = input.int(1, "VAH / VAL Line Width", group = GRP_R, minval = 1, maxval = 4, tooltip = "Line thickness of the committed Value Area High (VAH) and Value Area Low (VAL) lines.")
bool glowOn    = input.bool(true, "Glow Effects", group = GRP_R, tooltip = "Soft underglow beneath POC and node lines. Purely cosmetic.")
color colBody  = input.color(VN_BODY_DEF, "Profile", group = GRP_R, inline = "c1", tooltip = "Profile body — bin brightness follows volume share.")
color colPoc   = input.color(VN_POC_DEF, "POC", group = GRP_R, inline = "c1", tooltip = "Point of Control and its migration trail.")
color colAcc   = input.color(VN_ACC_DEF, "Accepted", group = GRP_R, inline = "c2", tooltip = "Node retest resolved as accepted.")
color colRej   = input.color(VN_REJ_DEF, "Rejected", group = GRP_R, inline = "c2", tooltip = "Node retest resolved as rejected.")

bool showPanel   = input.bool(true, "Statistics Panel", group = GRP_ST, tooltip = "Window status, developing value, node states and the measured base rates.")
string panelPos  = input.string("Top Right", "Position", group = GRP_ST, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], tooltip = "Corner of the chart the panel is pinned to.")
string panelSize = input.string("Small", "Text Size", group = GRP_ST, options = ["Tiny", "Small", "Normal"], tooltip = "Panel text size.")

// ─── ANCHOR RESOLUTION ────────────────────────────────────────────────────────
// Main chart context only — this script contains NO request.security calls, so the
// timeframe.in_seconds() HTF-context trap cannot occur here.
int CHART_SEC = timeframe.in_seconds()
string anchorPick = anchorMode == "Auto" ? (timeframe.isintraday ? (CHART_SEC <= 1800 ? "D" : "W") : timeframe.isdaily ? "M" : "12M") : anchorMode == "Day" ? "D" : anchorMode == "Week" ? "W" : anchorMode == "Month" ? "M" : "3M"
string ANCHOR = anchorPick
if ANCHOR == "D" and timeframe.in_seconds("D") <= CHART_SEC
    ANCHOR := "W"
if ANCHOR == "W" and timeframe.in_seconds("W") <= CHART_SEC
    ANCHOR := "M"
if ANCHOR == "M" and timeframe.in_seconds("M") <= CHART_SEC
    ANCHOR := "3M"
if ANCHOR == "3M" and timeframe.in_seconds("3M") <= CHART_SEC
    ANCHOR := "12M"
string anchName = ANCHOR == "D" ? "Daily" : ANCHOR == "W" ? "Weekly" : ANCHOR == "M" ? "Monthly" : ANCHOR == "3M" ? "Quarterly" : "Yearly"
bool newWindow = timeframe.change(ANCHOR)

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

// Below minN the sample is too small to quote a percentage — say so instead of
// printing statistical noise.
f_rate(int c, int n, int minN) =>
    n >= minN ? str.tostring(100.0 * c / n, "#") + "%" : "collecting"

f_trimBoxes(array<box> a, int maxN) =>
    while a.size() > maxN
        box.delete(a.shift())

f_trimLines(array<line> a, int maxN) =>
    while a.size() > maxN
        line.delete(a.shift())

f_trimLabels(array<label> a, int maxN) =>
    while a.size() > maxN
        label.delete(a.shift())

// Close-weighted triangular distribution: CDF of a triangular kernel on [L, H] with
// its apex at the bar close C. The weight a price bin [a, b] receives from the bar is
// f_triCdf(b) - f_triCdf(a). For x <= C: F(x) = (x-L)^2 / ((H-L)(C-L)); for x > C:
// F(x) = 1 - (H-x)^2 / ((H-L)(H-C)). Degenerate legs (C == L or C == H) reduce to the
// correct half-triangle automatically; a zero-range bar drops all volume in one bin.
f_triCdf(float L, float H, float C, float x) =>
    float r = H - L
    float out = na
    if r <= 0
        out := x > H ? 1.0 : 0.0
    else if x <= L
        out := 0.0
    else if x >= H
        out := 1.0
    else if x <= C
        out := (x - L) * (x - L) / (r * (C - L))
    else
        out := 1.0 - (H - x) * (H - x) / (r * (H - C))
    out

f_stateTxt(int st) =>
    st == 2 ? "testing" : st == 3 ? "accepted" : st == 4 ? "rejected" : "armed"

// ─── TYPES ────────────────────────────────────────────────────────────────────
// Node retest lifecycle: 0 dormant (price still inside the zone at arm time — waits
// for a clean confirmed close outside) · 1 armed · 2 testing · 3 accepted · 4 rejected
type VNode
    string kind
    float  lvl
    float  zLo
    float  zHi
    int    state
    int    streak
    line   ln
    line   glow
    label  tag

// ─── STATE ────────────────────────────────────────────────────────────────────
var array<float> binVol = array.new<float>()
var float gridLo = na
var float binH   = na
var int   wStart = na
var float devPoc = na
var float devVah = na
var float devVal = na

var float priorPoc = na            // final POC of the previous committed window
var bool  fRevisit = false
var int   cRevisit = 0
var int   nRevisit = 0
var float lastPocPrice = na        // for migration links
var int   lastPocBar   = na
var bool  sawVol = false
var bool  everCommitted = false

// node retest counters — measured base rates
var int cPocT = 0
var int cPocA = 0
var int cHvnT = 0
var int cHvnR = 0

var array<VNode> liveNodes  = array.new<VNode>()
var array<box>   profBoxes  = array.new<box>()
var array<int>   profCounts = array.new<int>()
var array<box>   lvnBoxes   = array.new<box>()
var array<box>   liveBoxes  = array.new<box>()
var array<line>  winLines   = array.new<line>()
var array<label> winLabels  = array.new<label>()
var array<line>  nodeLines  = array.new<line>()
var array<label> nodeLabels = array.new<label>()
var label tagVah = label(na)
var label tagVal = label(na)
var label tagPoc = label(na)

// developing-POC step trail — ACTIVE window only (redrawn as one polyline on the
// last bar; committed windows keep their final value lines, so history stays clean)
var array<chart.point> trailPts = array.new<chart.point>()
var float lastTrailPoc = na
var polyline trailPl = na
var box devVaBx = box(na)

var string TT_NODE = "Armed when its window committed. Returns are tracked on confirmed bars only: " + str.tostring(acceptN) + " confirmed close(s) inside the zone (center ± half an ATR, never thinner than one bin) = accepted · a probe through the node CENTER that closes outside the zone, or an entry that leaves before that, = rejected. A graze of the zone edge that neither trades the center nor closes inside resolves nothing. Unresolved nodes expire when the next window commits."

float atr = ta.atr(atrLen)
float detailK = detail == "Coarse" ? 0.5 : detail == "Balanced" ? 0.25 : 0.125

// per-bar event flags
bool committedNow = false
bool accNow       = false
bool rejNow       = false
bool revisitNow   = false
string accTxt     = ""
string rejTxt     = ""

// ─── WINDOW COMMIT ────────────────────────────────────────────────────────────
// Fires on the first bar of a new anchor window. Everything below uses only the
// CONFIRMED bars of the window that just ended, so a committed profile is final.
if newWindow and not na(wStart) and binVol.size() > 0 and not na(devPoc)
    committedNow  := true
    everCommitted := true
    int nB   = binVol.size()
    int wEnd = bar_index - 1
    // final profile statistics
    int   pocI = 0
    float vMax = 0.0
    float vSum = 0.0
    int   nnz  = 0
    int i0 = 0
    while i0 < nB
        float v = binVol.get(i0)
        vSum += v
        if v > 0
            nnz += 1
        if v > vMax
            vMax := v
            pocI := i0
        i0 += 1
    // base rate: did the ended window revisit the PREVIOUS window's POC
    if not na(priorPoc)
        nRevisit += 1
        if fRevisit
            cRevisit += 1
    // POC migration link between consecutive committed windows
    float aRef = nz(atr, binH * 4)
    if showMig and not na(lastPocPrice) and aRef > 0
        string mGl  = devPoc > lastPocPrice ? "▲" : devPoc < lastPocPrice ? "▼" : "◆"
        string mTxt = "POC " + mGl + " " + str.tostring(math.abs(devPoc - lastPocPrice) / aRef, "#.##") + " ATR · " + str.tostring(100.0 * math.abs(devPoc - lastPocPrice) / lastPocPrice, "#.##") + "% vs prior"
        winLines.push(line.new(lastPocBar, lastPocPrice, wEnd, devPoc, color = color.new(colPoc, 50), style = line.style_dotted))
        winLabels.push(label.new(wEnd, (devPoc + lastPocPrice) / 2, mTxt, style = label.style_none, color = color.new(colPoc, 100), textcolor = color.new(colPoc, 30), size = size.small, tooltip = "How far the Point of Control migrated between the previous committed window and this one, in ATR units. Value building higher or lower is the window-to-window read of this profile."))
    // committed histogram + value area shading
    int winBars = wEnd - wStart
    int rowSpan = math.max(4, int(math.round(winBars * profWidth / 100.0)))
    if showProf and vMax > 0
        int rows = 0
        profBoxes.push(box.new(wStart, devVah, wEnd, devVal, border_color = color.new(colBody, 100), bgcolor = color.new(colBody, 95)))
        rows += 1
        int i1 = 0
        while i1 < nB
            float v = binVol.get(i1)
            if v > 0
                int rowLen = math.max(1, int(math.round(rowSpan * v / vMax)))
                float yLo  = gridLo + i1 * binH
                bool isPoc = i1 == pocI
                int  rowTr = int(math.round(86.0 - 62.0 * v / vMax))
                profBoxes.push(box.new(wStart, yLo + binH, wStart + rowLen, yLo, border_color = color.new(colBody, 100), bgcolor = color.new(isPoc ? colPoc : colBody, isPoc ? 20 : rowTr)))
                rows += 1
            i1 += 1
        profCounts.push(rows)
        while profCounts.size() > keepProfiles
            int k0 = profCounts.shift()
            int j0 = 0
            while j0 < k0
                box.delete(profBoxes.shift())
                j0 += 1
    // committed value lines + tags (tags only for the latest window to avoid clutter)
    label.delete(tagVah)
    label.delete(tagVal)
    label.delete(tagPoc)
    winLines.push(line.new(wStart, devPoc, wEnd, devPoc, color = color.new(colPoc, 15), width = 2))
    if glowOn
        winLines.push(line.new(wStart, devPoc, wEnd, devPoc, color = color.new(colPoc, 86), width = 6))
    winLines.push(line.new(wStart, devVah, wEnd, devVah, color = color.new(colBody, 45), style = line.style_dashed, width = vaWidth))
    winLines.push(line.new(wStart, devVal, wEnd, devVal, color = color.new(colBody, 45), style = line.style_dashed, width = vaWidth))
    tagVah := label.new(wEnd, devVah, "VAH · Value Area High", style = label.style_label_right, color = color.new(colBody, 100), textcolor = color.new(colBody, 35), size = size.tiny, tooltip = "Upper edge of the price band holding " + str.tostring(vaPct) + "% of the committed window's volume.")
    tagVal := label.new(wEnd, devVal, "VAL · Value Area Low", style = label.style_label_right, color = color.new(colBody, 100), textcolor = color.new(colBody, 35), size = size.tiny, tooltip = "Lower edge of the price band holding " + str.tostring(vaPct) + "% of the committed window's volume.")
    if not trackNodes
        tagPoc := label.new(wEnd, devPoc, "POC · High Volume Node", style = label.style_label_right, color = color.new(colPoc, 100), textcolor = color.new(colPoc, 25), size = size.tiny, tooltip = "Point of Control — the single price bin that traded the most volume in the committed window.")
    // thin zones (LVN) — context shading, no state machine
    if showLvn and nnz > 0
        float thrLvn = 0.2 * vSum / nnz
        int runS   = -1
        int bestS1 = -1
        int bestL1 = 0
        int bestS2 = -1
        int bestL2 = 0
        int i2 = 1
        while i2 < nB - 1
            bool thin = binVol.get(i2) <= thrLvn
            if thin and runS < 0
                runS := i2
            if runS >= 0 and (not thin or i2 == nB - 2)
                int runE = thin ? i2 : i2 - 1
                int rl = runE - runS + 1
                if rl > bestL1
                    bestS2 := bestS1
                    bestL2 := bestL1
                    bestS1 := runS
                    bestL1 := rl
                else if rl > bestL2
                    bestS2 := runS
                    bestL2 := rl
                runS := -1
            i2 += 1
        if bestL1 > 1
            lvnBoxes.push(box.new(wStart, gridLo + (bestS1 + bestL1) * binH, wEnd, gridLo + bestS1 * binH, border_color = color.new(colBody, 88), border_style = line.style_dashed, bgcolor = color.new(colBody, 96), text = "LVN · Thin Zone", text_size = size.tiny, text_color = color.new(colBody, 55), text_halign = text.align_left))
        if bestL2 > 1
            lvnBoxes.push(box.new(wStart, gridLo + (bestS2 + bestL2) * binH, wEnd, gridLo + bestS2 * binH, border_color = color.new(colBody, 88), border_style = line.style_dashed, bgcolor = color.new(colBody, 96), text = "LVN · Thin Zone", text_size = size.tiny, text_color = color.new(colBody, 55), text_halign = text.align_left))
        f_trimBoxes(lvnBoxes, keepProfiles * 2)
    // expire unresolved nodes of the previous window
    while liveNodes.size() > 0
        VNode nd0 = liveNodes.pop()
        line l0 = nd0.ln
        line g0 = nd0.glow
        if not na(l0)
            l0.set_style(line.style_dotted)
            l0.set_color(color.new(colBody, 80))
            nodeLines.push(l0)
        if not na(g0)
            g0.set_color(color.new(colBody, 96))
            nodeLines.push(g0)
        label.delete(nd0.tag)
    // arm this window's nodes: POC + strongest HVNs. Zone half-height = half an ATR,
    // never thinner than one bin — a zone of one bin is too thin for a bar to close
    // inside and turns the state machine into a constant "rejected" printer.
    if trackNodes
        float zHalf = math.max(binH, 0.5 * aRef)
        line pLn = line.new(bar_index, devPoc, bar_index + 1, devPoc, color = color.new(colPoc, 20), width = 2)
        line pGl = glowOn ? line.new(bar_index, devPoc, bar_index + 1, devPoc, color = color.new(colPoc, 84), width = 6) : line(na)
        label pTg = label.new(bar_index + 1, devPoc, "POC · High Volume Node", style = label.style_label_left, color = color.new(colPoc, 100), textcolor = color.new(colPoc, 20), size = size.tiny, tooltip = TT_NODE)
        liveNodes.push(VNode.new("POC", devPoc, devPoc - zHalf, devPoc + zHalf, 0, 0, pLn, pGl, pTg))
        if hvnMax > 0
            array<int> cand = array.new<int>()
            int i3 = 1
            while i3 < nB - 1
                float v = binVol.get(i3)
                if v >= binVol.get(i3 - 1) and v >= binVol.get(i3 + 1) and v >= 0.5 * vMax and math.abs(i3 - pocI) > 2
                    cand.push(i3)
                i3 += 1
            array<int> armedIdx = array.new<int>()
            int taken = 0
            while taken < hvnMax and cand.size() > 0
                int best = 0
                int j1 = 1
                while j1 < cand.size()
                    if binVol.get(cand.get(j1)) > binVol.get(cand.get(best))
                        best := j1
                    j1 += 1
                int bi = cand.get(best)
                cand.remove(best)
                bool clash = false
                int j2 = 0
                while j2 < armedIdx.size()
                    if math.abs(armedIdx.get(j2) - bi) <= 2
                        clash := true
                    j2 += 1
                if not clash
                    armedIdx.push(bi)
                    float hLvl = gridLo + (bi + 0.5) * binH
                    line hLn = line.new(bar_index, hLvl, bar_index + 1, hLvl, color = color.new(colBody, 30), width = 1)
                    line hGl = glowOn ? line.new(bar_index, hLvl, bar_index + 1, hLvl, color = color.new(colBody, 88), width = 5) : line(na)
                    label hTg = label.new(bar_index + 1, hLvl, "HVN · High Volume Node", style = label.style_label_left, color = color.new(colBody, 100), textcolor = color.new(colBody, 30), size = size.tiny, tooltip = TT_NODE)
                    liveNodes.push(VNode.new("HVN", hLvl, hLvl - zHalf, hLvl + zHalf, 0, 0, hLn, hGl, hTg))
                    taken += 1
    // roll the window-to-window references
    priorPoc     := devPoc
    fRevisit     := false
    lastPocPrice := devPoc
    lastPocBar   := wEnd
    f_trimLines(winLines, keepProfiles * 6)
    f_trimLabels(winLabels, keepProfiles * 2)
    f_trimLines(nodeLines, marksKeep * 2)
    f_trimLabels(nodeLabels, marksKeep)

// ─── WINDOW RESET ─────────────────────────────────────────────────────────────
if newWindow or barstate.isfirst
    wStart := bar_index
    binVol.clear()
    trailPts.clear()
    lastTrailPoc := na
    float aBase = nz(atr, math.max(high - low, syminfo.mintick * 10.0))
    binH   := math.max(aBase * detailK, syminfo.mintick)
    gridLo := low
    devPoc := na
    devVah := na
    devVal := na

// ─── ACCUMULATION + DEVELOPING VALUE (confirmed bars only) ────────────────────
if barstate.isconfirmed and not na(binH)
    if nz(volume) > 0
        sawVol := true
    // grid growth on demand — bin height stays fixed, the grid extends
    while low < gridLo
        binVol.unshift(0.0)
        gridLo := gridLo - binH
    while high >= gridLo + binH * binVol.size()
        binVol.push(0.0)
    // 2:1 re-bin when the window's range outgrows the cap (adaptive-resolution guard)
    if binVol.size() > BIN_CAP
        int n0 = binVol.size()
        array<float> merged = array.new<float>()
        int im = 0
        while im < n0
            float v2 = im + 1 < n0 ? binVol.get(im + 1) : 0.0
            merged.push(binVol.get(im) + v2)
            im += 2
        binVol.clear()
        for vm in merged
            binVol.push(vm)
        binH := binH * 2
    // close-weighted triangular distribution of this bar's volume
    int nBd = binVol.size()
    float Cw = math.min(math.max(close, low), high)
    float barVol = nz(volume) > 0 ? volume : 1.0
    int iLo = math.max(0, int(math.floor((low - gridLo) / binH)))
    int iHi = math.min(nBd - 1, int(math.floor((high - gridLo) / binH)))
    int id = iLo
    while id <= iHi
        float aEdge = gridLo + id * binH
        float w = f_triCdf(low, high, Cw, aEdge + binH) - f_triCdf(low, high, Cw, aEdge)
        if w > 0
            binVol.set(id, binVol.get(id) + barVol * w)
        id += 1
    // developing POC / Value Area — the value-migration trail
    float total = 0.0
    float pocV  = -1.0
    int   pocId = 0
    int iv = 0
    while iv < nBd
        float v = binVol.get(iv)
        total += v
        if v > pocV
            pocV  := v
            pocId := iv
        iv += 1
    if total > 0
        devPoc := gridLo + (pocId + 0.5) * binH
        float accV = pocV
        int up = pocId
        int dn = pocId
        float tgt = total * vaPct / 100.0
        while accV < tgt and (up < nBd - 1 or dn > 0)
            float vUp = up < nBd - 1 ? binVol.get(up + 1) : -1.0
            float vDn = dn > 0 ? binVol.get(dn - 1) : -1.0
            if vUp >= vDn
                up += 1
                accV += vUp
            else
                dn -= 1
                accV += vDn
        devVah := gridLo + (up + 1) * binH
        devVal := gridLo + dn * binH
        // step-trail bookkeeping: two corner points per POC change keeps the point
        // count tiny (changes only), while the polyline renders as clean steps
        if na(lastTrailPoc)
            trailPts.push(chart.point.from_index(bar_index, devPoc))
            lastTrailPoc := devPoc
        else if devPoc != lastTrailPoc
            trailPts.push(chart.point.from_index(bar_index, lastTrailPoc))
            trailPts.push(chart.point.from_index(bar_index, devPoc))
            lastTrailPoc := devPoc
        while trailPts.size() > 800
            trailPts.shift()
    // prior-POC revisit (base-rate numerator + alert event)
    if not na(priorPoc) and not fRevisit and high >= priorPoc and low <= priorPoc
        fRevisit   := true
        revisitNow := true

// ─── NODE ACCEPTANCE STATE MACHINE (confirmed bars only) ──────────────────────
if trackNodes and liveNodes.size() > 0
    int k = 0
    while k < liveNodes.size()
        VNode nd = liveNodes.get(k)
        line nLn = nd.ln
        line nGl = nd.glow
        label nTg = nd.tag
        if not na(nLn)
            nLn.set_x2(bar_index)
        if not na(nGl)
            nGl.set_x2(bar_index)
        if not na(nTg)
            nTg.set_x(bar_index + 1)
        bool resolved = false
        if barstate.isconfirmed
            if nd.state == 0
                if close > nd.zHi or close < nd.zLo
                    nd.state := 1
            else if nd.state == 1 or nd.state == 2
                bool touch  = high >= nd.zLo and low <= nd.zHi
                bool pierce = high >= nd.lvl and low <= nd.lvl
                bool inside = close >= nd.zLo and close <= nd.zHi
                if nd.state == 1 and touch
                    if inside
                        nd.state  := 2
                        nd.streak := 1
                    else if pierce
                        nd.state := 4
                    // edge graze: zone touched but the center never traded and the close
                    // stayed outside — not a test of the node, stays armed
                else if nd.state == 2
                    if inside
                        nd.streak := nd.streak + 1
                    else
                        nd.state := 4
                if nd.state == 2 and nd.streak >= acceptN
                    nd.state := 3
                if nd.state == 3 or nd.state == 4
                    resolved := true
                    bool isAcc = nd.state == 3
                    color oc = isAcc ? colAcc : colRej
                    if not na(nLn)
                        nLn.set_color(color.new(oc, 25))
                        nodeLines.push(nLn)
                    if not na(nGl)
                        nGl.set_color(color.new(oc, 86))
                        nodeLines.push(nGl)
                    label.delete(nTg)
                    string oTxt = (isAcc ? "✓ " : "✕ ") + nd.kind + (isAcc ? " accepted" : " rejected")
                    nodeLabels.push(label.new(bar_index, nd.lvl, oTxt, style = label.style_none, color = color.new(oc, 100), textcolor = oc, size = size.small, tooltip = isAcc ? "Price returned to this volume node and printed " + str.tostring(acceptN) + " confirmed close(s) inside its zone — the market is accepting business at this price again." : "Price probed this volume node and was turned away — it traded through the node center and closed outside the zone, or entered and could not hold " + str.tostring(acceptN) + " confirmed close(s) inside."))
                    f_trimLabels(nodeLabels, marksKeep)
                    f_trimLines(nodeLines, marksKeep * 2)
                    if nd.kind == "POC"
                        cPocT += 1
                        if isAcc
                            cPocA += 1
                    else
                        cHvnT += 1
                        if not isAcc
                            cHvnR += 1
                    if isAcc
                        accNow := true
                        accTxt := accTxt == "" ? nd.kind + " accepted" : accTxt + " + " + nd.kind + " accepted"
                    else
                        rejNow := true
                        rejTxt := rejTxt == "" ? nd.kind + " rejected" : rejTxt + " + " + nd.kind + " rejected"
        if resolved
            liveNodes.remove(k)
        else
            k += 1

// ─── LIVE DEVELOPING PROFILE (last bar only — visual context) ─────────────────
if barstate.islast
    while liveBoxes.size() > 0
        box.delete(liveBoxes.shift())
    int nBL = binVol.size()
    if showLive and nBL > 0 and not na(wStart) and not na(binH)
        float vMaxL = 0.0
        int pocL = 0
        int i6 = 0
        while i6 < nBL
            float v = binVol.get(i6)
            if v > vMaxL
                vMaxL := v
                pocL  := i6
            i6 += 1
        if vMaxL > 0
            int rowSpanL = math.max(4, int(math.round((bar_index - wStart + 1) * profWidth / 100.0)))
            int i7 = 0
            while i7 < nBL
                float v = binVol.get(i7)
                if v > 0
                    int rowLen = math.max(1, int(math.round(rowSpanL * v / vMaxL)))
                    float yLo = gridLo + i7 * binH
                    int rowTr = int(math.round(90.0 - 50.0 * v / vMaxL))
                    liveBoxes.push(box.new(wStart, yLo + binH, wStart + rowLen, yLo, border_color = color.new(colBody, 100), bgcolor = color.new(i7 == pocL ? colPoc : colBody, i7 == pocL ? 45 : rowTr)))
                i7 += 1

// ─── DEVELOPING VALUE (active window only — drawn, not plotted) ───────────────
// Plots would leave a permanent trail on every past window and bury the committed
// histograms under stepped noise. Instead the POC trail is ONE polyline and the
// developing Value Area is ONE band box, both existing only for the active window;
// committed windows keep their final POC / VAH / VAL lines. Price scale stays clean.
if barstate.islast
    polyline.delete(trailPl)
    box.delete(devVaBx)
    if showDev and not na(devPoc) and trailPts.size() > 0 and not na(wStart)
        array<chart.point> pts = trailPts.copy()
        pts.push(chart.point.from_index(bar_index, devPoc))
        trailPl := polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(colPoc, 10), line_width = 2)
        if not na(devVah) and not na(devVal)
            devVaBx := box.new(wStart, devVah, bar_index, devVal, border_color = color.new(colBody, 70), border_style = line.style_dotted, bgcolor = color.new(colBody, 93))

// ─── PANEL ────────────────────────────────────────────────────────────────────
var table pnl = table(na)
if barstate.islast
    if not na(pnl)
        table.delete(pnl)
    if showPanel
        string pPos = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left
        string pSz  = panelSize == "Tiny" ? size.tiny : panelSize == "Small" ? size.small : size.normal
        pnl := table.new(pPos, 3, 9, bgcolor = NS_BG, border_width = 1, border_color = color.new(NS_SEC, 80))
        pnl.cell(0, 0, "VOLUME NODES & VALUE MIGRATION", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
        pnl.merge_cells(0, 0, 2, 0)
        string volNote = sawVol ? "" : " · no volume data (bars weighted equally)"
        pnl.cell(0, 1, "WINDOW", text_color = NS_INK, text_size = pSz, text_halign = text.align_left, bgcolor = color.new(colBody, 25))
        pnl.cell(1, 1, anchName + " · " + str.tostring(bar_index - nz(wStart, bar_index) + 1) + " bars", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW)
        pnl.cell(2, 1, (binVol.size() == 0 ? "forming · " : str.tostring(binVol.size()) + " bins · ") + f_px(binH) + " / bin" + volNote, text_color = NS_LBL, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW, tooltip = "Bin height is derived from ATR at the window anchor, so the bin count follows the window's range-to-ATR ratio. On the first bar of a fresh window the profile has no confirmed bars yet — it says forming.")
        pnl.cell(0, 2, "VALUE", text_color = NS_INK, text_size = pSz, text_halign = text.align_left, bgcolor = color.new(colBody, 25))
        pnl.cell(1, 2, "POC " + f_px(devPoc), text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW)
        pnl.cell(2, 2, "VA " + f_px(devVal) + " — " + f_px(devVah), text_color = NS_LBL, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW)
        string migTxt = na(priorPoc) or na(devPoc) or na(atr) or atr <= 0 ? "collecting" : "POC " + (devPoc > priorPoc ? "▲" : devPoc < priorPoc ? "▼" : "◆") + " " + str.tostring(math.abs(devPoc - priorPoc) / atr, "#.##") + " ATR · " + str.tostring(100.0 * math.abs(devPoc - priorPoc) / priorPoc, "#.##") + "% vs prior"
        string revTxt = na(priorPoc) ? "—" : fRevisit ? "prior POC revisited" : "prior POC untouched"
        pnl.cell(0, 3, "MIGRATION", text_color = NS_INK, text_size = pSz, text_halign = text.align_left, bgcolor = color.new(colBody, 25))
        pnl.cell(1, 3, migTxt, text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW)
        pnl.cell(2, 3, revTxt, text_color = NS_LBL, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW)
        string ndTxt = ""
        for nd in liveNodes
            ndTxt := ndTxt == "" ? nd.kind + " " + f_stateTxt(nd.state) : ndTxt + " · " + nd.kind + " " + f_stateTxt(nd.state)
        pnl.cell(0, 4, "NODES", text_color = NS_INK, text_size = pSz, text_halign = text.align_left, bgcolor = color.new(colBody, 25))
        pnl.cell(1, 4, ndTxt == "" ? (trackNodes ? (everCommitted ? "all resolved · re-arms at next commit" : "waiting for first commit") : "off") : ndTxt, text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left, bgcolor = NS_ROW)
        pnl.merge_cells(1, 4, 2, 4)
        pnl.cell(0, 5, "BASE RATES · measured on this chart", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left, tooltip = "Counted on confirmed bars over the loaded history. Revisit = price traded back through the previous window's POC. A node retest resolves ACCEPTED after " + str.tostring(acceptN) + " confirmed close(s) inside the node zone, REJECTED when a probe trades through the node center and closes outside the zone, or when an entry leaves before the required closes. Edge grazes resolve nothing. Percentages appear once the sample reaches 10.")
        pnl.merge_cells(0, 5, 2, 5)
        pnl.cell(0, 6, "prior POC revisited", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
        pnl.cell(1, 6, f_rate(cRevisit, nRevisit, 10) + "  (n=" + str.tostring(nRevisit) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
        pnl.cell(2, 6, "", text_color = NS_LBL, text_size = pSz)
        pnl.cell(0, 7, "POC retest → accepted", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
        pnl.cell(1, 7, f_rate(cPocA, cPocT, 10) + "  (n=" + str.tostring(cPocT) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
        pnl.cell(2, 7, "", text_color = NS_LBL, text_size = pSz)
        pnl.cell(0, 8, "HVN retest → rejected", text_color = NS_LBL, text_size = pSz, text_halign = text.align_left)
        pnl.cell(1, 8, f_rate(cHvnR, cHvnT, 10) + "  (n=" + str.tostring(cHvnT) + ")", text_color = NS_WHITE, text_size = pSz, text_halign = text.align_left)
        pnl.cell(2, 8, "", text_color = NS_LBL, text_size = pSz)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
// Rich notification naming the exact event(s). All events are confirmed-bar gated.
if committedNow or accNow or rejNow or revisitNow
    array<string> parts = array.new<string>()
    if committedNow
        parts.push("profile committed (" + anchName + " window)")
    if revisitNow
        parts.push("prior POC revisited")
    if accNow
        parts.push(accTxt)
    if rejNow
        parts.push(rejTxt)
    alert(syminfo.ticker + " " + timeframe.period + " — " + parts.join(", "), alert.freq_once_per_bar_close)

alertcondition(accNow,       "Node accepted",       "Price built acceptance at a committed volume node (confirmed closes inside the node zone) — see the node line on the chart")
alertcondition(rejNow,       "Node rejected",       "A committed volume node turned the retest away (probe through the node center with a confirmed close outside the zone)")
alertcondition(committedNow, "Profile committed",   "An anchor window closed — its profile is final and its POC / HVN nodes are armed")
alertcondition(revisitNow,   "Prior POC revisited", "Price traded back through the previous window's Point of Control (confirmed bar)")
````
