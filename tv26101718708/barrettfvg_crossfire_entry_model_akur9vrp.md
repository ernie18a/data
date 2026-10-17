# BarrettFVG Crossfire Entry Model

- url: https://www.tradingview.com/script/Akur9Vrp-BarrettFVG-Crossfire-Entry-Model/
- type: indicator
- pine_id: PUB;dfc913806361429cb6e4a30b604d73cd
- version: 1.0

## Description

An entry model built on top of crossfire zone detection — the price bands where an old unfilled Fair Value Gap gets struck by a newer, opposite-direction FVG. Instead of trading zone touches directly, this version requires a structural break to confirm the retest before signalling an entry, and plots stop-loss and take-profit levels for each signal.

What a crossfire zone is

A Fair Value Gap is a three-candle imbalance — a price range that got skipped over rather than traded through. Most FVG tools treat each gap as its own independent level.

A crossfire zone is different: it's the overlap between an older, still-unfilled FVG and a newer FVG pointing the opposite direction. Rather than one-sided imbalance, it marks a band where bullish and bearish inefficiency directly collide — a genuinely contested area rather than a single gap.

The star rating (★) counts how many times a zone has been flipped by a new opposing FVG. This matters for a structural reason, not just as a tally: each flip keeps only the portion of the zone that the new FVG actually overlapped, so the band narrows with every flip. A 3★ zone isn't just "tested more" — it's physically tighter and more precisely defined than a 1★ zone. That has a direct practical consequence: a stop placed beyond a high-star zone's far side is naturally tighter than the same stop on a wide, freshly-formed zone.

The entry model

The original indicator treats the retest itself as the tradeable moment. This version treats a retest as an arming event and requires confirmation before signalling:

Zone forms — an old FVG is struck by an opposite FVG, creating a contested band
Star filter — the zone must have flipped enough times to meet the minimum star setting (optional)
Retest — price leaves the zone, then returns to it. This arms a pending entry, it does not fire one
Break of Structure — within a configurable bar window, price must break the most recent 1-minute swing in the zone's direction. This is the actual trigger. BOS uses its own independent pivot tracking rather than the zone's boundaries, so the confirmation is a genuine structural event rather than a restatement of the level that produced the retest
Displacement — the triggering candle must show real conviction: range large relative to ATR, a substantial body rather than mostly wick, and optionally a close in the trade's direction
Session and cooldown gates — signals restricted to configurable trading windows, with a minimum bar spacing between same-direction entries

Turning off the BOS requirement reverts to the original behaviour, where the retest alone fires the signal.

VWAP trend filter (optional, off by default)

Longs only above the active VWAP, shorts only below. The distinguishing feature is which VWAP counts as active: the NY Session VWAP during NY hours, the True Day Open VWAP outside them — so the reference is always anchored to the session actually in play.

Because the NY VWAP anchors at 09:30 with almost no sample behind it, it whipsaws around price for the first several minutes. A configurable grace period (default 15 minutes, measured in real time rather than bar count so it holds on any timeframe) keeps the filter on the TDO VWAP until the NY VWAP has enough data to mean anything.

Risk management

Every entry signal plots a stop-loss and take-profit:

SL — Recent market structure (default): beyond the lowest low / highest high over a configurable lookback
SL — Beyond zone far side: beyond the point where the zone itself would be considered mitigated. Tighter on high-star zones, since each flip narrows the band
TP: a configurable R multiple of the stop distance
Lines are removed automatically once price reaches either level
Context included
Key levels: previous day high/low, previous week high/low, Asia session high/low, London session high/low
Dual VWAPs: True Day Open (18:00 EST anchor, runs continuously) and NY Session (09:30 EST anchor, disappears outside the session)
Origin funnel: optional lines showing which base FVG a zone came from
Retest markers: optional small arrows on every retest, including ones that never confirmed — useful for seeing how many entries are being filtered out
Alerts

Dynamic alert messages carrying direction, the zone's star count, and entry/SL/TP prices:

MNQ1! — LONG | 3★ zone | Entry 21847.25 | SL 21838.00 | TP 21856.50

Set these up via Add Alert → Condition → "Alert() function calls only". Separate static alert conditions are also available in the dropdown, and unconfirmed retests can optionally alert on their own.

Settings notes

Settings are grouped roughly in order of how often you'd change them — entry model and filters first, cosmetic and structural settings last. Every input has a tooltip explaining what it does.

Defaults are starting points, not optimised values. They have not been backtested or tuned for any particular instrument or timeframe. Expect to adjust the BOS window, displacement thresholds, and star minimum for whatever you trade.

Credit

Crossfire zone detection — the FVG pairing, overlap, flip, and star mechanics — is the original work of fluxchart, published as "FVG Crossfire" and used here under the Mozilla Public License 2.0. This version adds the entry model, confirmation filters, risk management, key levels, and VWAPs on top of that engine. Per MPL 2.0, this modified version also remains open-source under the same license.

Disclaimer 

This script is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice, nor a recommendation to buy or sell any instrument. Trading futures, forex, and other leveraged instruments carries substantial risk of loss and is not suitable for every investor. You can lose more than your initial deposit.

No indicator can predict future price movement. Signals produced by this script are pattern-based observations, not forecasts. Past performance, backtested results, and historical signals are not indicative of future results.

The default settings are starting points and have not been optimised for any specific market, timeframe, or account. Test thoroughly on historical data and in simulation before risking real capital.

You are solely responsible for your own trading decisions and any resulting outcomes. The author accepts no liability for any losses incurred through use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©fluxchart — original author, "FVG Crossfire"
// Modified by BarrettFVG. Per MPL 2.0 (file-level copyleft), this modified file
// remains under MPL 2.0 and must stay open-source.
//
// MODIFICATIONS vs. the original:
//   1. Key levels: PDH/PDL, PWH/PWL, Asia High/Low, London High/Low
//   2. TDO VWAP (18:00 EST anchor) and NY Session VWAP (09:30 EST anchor)
//   3. Alerts rewritten: dynamic, retest-focused, with zone star count
//   4. ENTRY MODEL: retest alone is no longer the signal. A retest arms a
//      pending state; a 1m BOS in the zone's direction within N bars is the
//      actual entry trigger. Own dedicated BOS pivot tracking, independent
//      of the zone geometry.
//   5. SL/TP: SL at recent market structure (default) or beyond the zone's
//      far side; TP at a configurable R multiple.
//   6. VWAP trend filter: uses NY VWAP during the NY session and TDO VWAP
//      outside it. Longs only above the active VWAP, shorts only below.

//@version=6
indicator("BarrettFVG Crossfire Entry Model", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region CONSTANTS
int snapBars = 3
int maxFVGs = 80
int maxSegments = 120
int maxRetestMarks = 20
disp = display.none
//#endregion CONSTANTS

//#region INPUTS
string grpEntry = "1 · Entry Model"
string grpFilt  = "2 · Filters"
string grpRisk  = "3 · Risk"
string grpKey   = "4 · Key Levels"
string grpVwap  = "5 · VWAPs"
string grpSess  = "6 · Sessions"
string grpBase  = "7 · Base FVG"
string grpZone  = "8 · Crossfire Zone"
string grpAlert = "9 · Alerts"

// ---------- 1 · ENTRY MODEL ----------
bool useBosEntry = input.bool(true, "Require BOS after retest", tooltip = "The retest alone only ARMS a pending entry. A 1m Break of Structure in the zone's direction within the window below is what actually fires the signal. Turn off to treat the raw retest as the entry, as the original indicator does.", group = grpEntry)
int bosPivotLen = input.int(3, "BOS Pivot Length", minval = 2, maxval = 20, tooltip = "Pivot lookback for the swing that must break to confirm. Independent of the zone geometry — this tracks its own 1m swings.", group = grpEntry)
int bosWindow = input.int(10, "Max Bars From Retest to BOS", minval = 1, maxval = 50, tooltip = "How many bars after a retest the pending entry stays live waiting for BOS. Expires unfired after this.", group = grpEntry)
int bosBufferTicks = input.int(1, "BOS Buffer (ticks)", minval = 0, tooltip = "Close must clear the BOS pivot by this many ticks rather than an exact zero-distance cross.", group = grpEntry)
int cooldownBars = input.int(15, "Signal Cooldown Bars", minval = 0, tooltip = "Minimum bars between two signals in the same direction.", group = grpEntry)
int minStars = input.int(1, "Minimum Zone Stars", minval = 1, maxval = 10, tooltip = "A zone must have flipped enough times to reach this star count before its retests can fire an entry. Each flip narrows the zone to only the overlapping portion, so higher star counts mean tighter, more precisely contested bands. 1 = any zone qualifies.", group = grpEntry)

// ---------- 2 · FILTERS ----------
bool useVwapTrend = input.bool(false, "VWAP Trend Filter", tooltip = "Longs only fire above the active VWAP, shorts only below. Uses the NY Session VWAP during NY hours and the TDO VWAP outside them, so the reference is always the one anchored to the session actually in play.", group = grpFilt)
int nyVwapGraceMins = input.int(15, "    ↳ NY VWAP Grace Period (minutes)", minval = 0, maxval = 240, tooltip = "The NY VWAP anchors at 09:30 with almost no data behind it, so it whipsaws for the first several minutes. For this many minutes after the anchor the filter keeps using TDO VWAP instead. Measured in real minutes, so it means the same thing on any chart timeframe.", group = grpFilt)

bool useDisp = input.bool(true, "Require Displacement on Trigger Candle", tooltip = "MASTER SWITCH. Requires the candle that fires the signal (the BOS candle, or the retest candle if BOS is off) to show real conviction rather than drifting through on low energy.", group = grpFilt)
float dispRangeAtr = input.float(1.0, "    ↳ Min Range (ATR)", minval = 0.1, step = 0.1, tooltip = "Trigger candle's high-low range must be at least this multiple of ATR(14).", group = grpFilt)
float dispBodyRatio = input.float(0.5, "    ↳ Min Body Ratio", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "Trigger candle's body must be at least this fraction of its full range.", group = grpFilt)
bool dispDirClose = input.bool(true, "    ↳ Require Directional Close", tooltip = "Trigger candle must close in the signal's direction.", group = grpFilt)

// ---------- 3 · RISK ----------
string slMethod = input.string("Recent market structure", "SL Method", options = ["Recent market structure", "Beyond zone far side"], tooltip = "Recent market structure: SL beyond the lowest low / highest high over the lookback below. Beyond zone far side: SL beyond the point where the zone itself would be mitigated — tighter on high-star zones, since each flip narrows the band.", group = grpRisk)
int slLookbackBars = input.int(20, "Structure Lookback Bars", minval = 1, tooltip = "Only used with Recent market structure — how many bars back to scan.", group = grpRisk)
int slBufferTicks = input.int(2, "SL Buffer (ticks)", minval = 0, tooltip = "Extra ticks beyond the SL reference.", group = grpRisk)
float rrRatio = input.float(1.0, "Take-Profit R Multiple", minval = 0.1, step = 0.1, tooltip = "Take-profit distance as a multiple of risk (the SL distance).", group = grpRisk)
bool showTracker = input.bool(true, "Show Visual SL/TP Tracker", tooltip = "Draws SL and TP lines when a signal fires, removed once the trade closes.", group = grpRisk)
bool onlyLastEntry = input.bool(true, "Show Only Last Entry Per Side", tooltip = "ON keeps just the most recent LONG and most recent SHORT marker on the chart. OFF keeps past entry markers visible so you can review signal history — useful for backtesting by eye, but adds clutter.", group = grpRisk)
int maxEntryLabels = input.int(50, "    ↳ Max Stored Entry Markers", minval = 5, maxval = 200, tooltip = "Only applies when Show Only Last Entry Per Side is OFF. Caps how many past markers stay on the chart before the oldest are deleted, so the label budget doesn't run out and start silently dropping other drawings.", group = grpRisk)

// ---------- 4 · KEY LEVELS ----------
bool showKeyLevels = input.bool(true, "Show Key Levels", tooltip = "PDH, PDL, PWH, PWL, Asia High/Low, London High/Low as dotted reference lines.", group = grpKey)
bool includePw = input.bool(true, "Include Prev Week High/Low", group = grpKey)
string asiaSess = input.session("2000-0000", "Asia Session (EST)", group = grpKey)
string londonSess = input.session("0200-0500", "London Session (EST)", group = grpKey)

// ---------- 5 · VWAPS ----------
bool showVwaps = input.bool(true, "Show VWAPs", group = grpVwap)
color tdoColor = input.color(color.blue, "TDO VWAP Color (18:00 EST)", tooltip = "Anchors at 18:00 EST and runs continuously until the next day's anchor.", group = grpVwap)
color nyColor = input.color(#9c27b0, "NY Session VWAP Color", tooltip = "Anchors at 09:30 EST and disappears outside the NY session.", group = grpVwap)

// ---------- 6 · SESSIONS ----------
bool useSess = input.bool(true, "Gate signals by session", tooltip = "Restricts entries to the two windows below. Zones and levels still draw around the clock.", group = grpSess)
string sess1 = input.session("1800-0000", "Trading Time Window 1 (EST)", group = grpSess)
string sess2 = input.session("0700-1600", "Trading Time Window 2 (EST)", group = grpSess)

// ---------- 7 · BASE FVG ----------
string fvgMitig = input.string("Close", "Base FVG mitigation", options = ["Wick", "Close"], tooltip = "How a waiting FVG gets filled: by wicks, or only by candle closes. A fully filled FVG can no longer create a zone.", group = grpBase, display = disp)
float minGap = input.float(0.0, "Min FVG gap (% of price)", minval = 0.0, step = 0.01, tooltip = "Skip tiny FVGs. 0 = keep every FVG.", group = grpBase, display = disp)
bool showFunnel = input.bool(true, "Show origin funnel", tooltip = "Draw lines from the old FVG into its zone, showing where the zone came from.", group = grpBase, display = disp)
bool fvgBorder = input.bool(false, "Border", tooltip = "Show or hide the funnel's edge lines.", inline = "fvgLine", group = grpBase, display = disp)
string fvgStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "fvgLine", group = grpBase, display = disp)
color bullFvgCol = input.color(color.new(#0ecb81, 86), "Bullish", tooltip = "Transparency here sets the fill strength.", inline = "fvgCol", group = grpBase, display = disp)
color bearFvgCol = input.color(color.new(#f6465d, 86), "Bearish", inline = "fvgCol", group = grpBase, display = disp)

// ---------- 8 · CROSSFIRE ZONE ----------
int lookback = input.int(3000, "Lookback (candles)", minval = 100, maxval = 10000, tooltip = "Only build FVGs and zones inside the most recent N candles.", group = grpZone, display = disp)
string zoneMitig = input.string("Close", "Zone mitigation", options = ["Wick", "Close"], tooltip = "A zone is finished when price trades through its far side — by wick, or only by close.", group = grpZone, display = disp)
bool zoneBorder = input.bool(false, "Border", tooltip = "Show or hide the zone's outline.", inline = "zoneLine", group = grpZone, display = disp)
string zoneStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "zoneLine", group = grpZone, display = disp)
bool showMid = input.bool(false, "Midline", inline = "mid", group = grpZone, display = disp)
string midStyle = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "mid", group = grpZone, display = disp)
color bullZoneCol = input.color(color.new(#0ecb81, 80), "Bullish", tooltip = "Transparency here sets the zone fill strength.", inline = "zoneCol", group = grpZone, display = disp)
color bearZoneCol = input.color(color.new(#f6465d, 80), "Bearish", inline = "zoneCol", group = grpZone, display = disp)
bool retestMarks = input.bool(false, "Retest markers", tooltip = "Draws a small arrow every time price re-enters a zone after leaving it. OFF by default — these mark retests, not entries, and a retest only becomes tradeable once BOS confirms it. Turn on if you want to see every arming event, including ones that never confirmed.", group = grpZone, display = disp)
bool combineZones = input.bool(false, "Combine overlapping zones", tooltip = "Merge overlapping zones of the same color into one bigger zone.", group = grpZone, display = disp)
bool showMitigated = input.bool(true, "Show mitigated zones", tooltip = "Keep finished zones on the chart, faded out.", group = grpZone, display = disp)

// ---------- 9 · ALERTS ----------
bool alertEntry = input.bool(true, "Entry signals", tooltip = "Fires when a retest is confirmed by BOS (or on the raw retest if BOS is off). This is the tradeable event.", group = grpAlert, display = disp)
bool alertRetestOnly = input.bool(false, "Retests (unconfirmed)", tooltip = "Fires on every zone retest regardless of whether it goes on to confirm. Noisier — off by default.", group = grpAlert, display = disp)
color longEntryColor = input.color(color.green, "Long Entry Color", group = grpAlert)
color shortEntryColor = input.color(color.red, "Short Entry Color", group = grpAlert)
//#endregion INPUTS

//#region UDTs
type FVG
    int dir
    float top
    float bottom
    float lagTop
    float lagBottom
    int startBar

type Segment
    int dir
    float top
    float bottom
    int createBar
    bool active
    bool done
    bool touching
    int chainId
    int flips
    box bx
    line fvgTop
    line fvgBot
    linefill fvgFill
    line eq
    label mark
    array<label> retestLbs
//#endregion UDTs

//#region VARIABLES
bool fvgWick = fvgMitig == "Wick"
bool zoneWick = zoneMitig == "Wick"
fvgStyl = fvgStyle == "Solid" ? line.style_solid : fvgStyle == "Dashed" ? line.style_dashed : line.style_dotted
zoneStyl = zoneStyle == "Solid" ? line.style_solid : zoneStyle == "Dashed" ? line.style_dashed : line.style_dotted
midStyl = midStyle == "Solid" ? line.style_solid : midStyle == "Dashed" ? line.style_dashed : line.style_dotted
var int chainSeq = 0
bool evRetest = false

float atr14 = ta.atr(14)

// Retest details captured for the entry model: which direction, the zone's
// star count, and the zone's far side (the mitigation edge) for SL use.
int  retestDir   = 0
int  retestStars = 0
float retestFar  = na
//#endregion VARIABLES

//#region ARRAYS
var array<FVG> fvgs = array.new<FVG>()
var array<Segment> segs = array.new<Segment>()
//#endregion ARRAYS

//#region FUNCTION DECLARATIONS
// Fills a base FVG on a delay so the move that strikes it can't erase it before the overlap test.
lagMitigate(FVG f) =>
    if f.startBar < bar_index - snapBars
        if f.dir == 1
            sl = fvgWick ? low[snapBars] : close[snapBars]
            if sl < f.lagTop
                f.lagTop := math.max(sl, f.lagBottom)
        else
            sh = fvgWick ? high[snapBars] : close[snapBars]
            if sh > f.lagBottom
                f.lagBottom := math.min(sh, f.lagTop)

dimmed(color c) =>
    color.new(c, math.min(97, color.t(c) + 10))

starText(int n) =>
    n <= 4 ? str.repeat("★", n) + str.repeat("    ", n) : str.tostring(n) + " ★    "

// Grows a same-direction live zone to swallow an overlapping band; returns true if it merged.
mergeZone(int dir, float t, float bot) =>
    merged = false
    for s in segs
        if s.active and not s.done and s.dir == dir and bot <= s.top and s.bottom <= t
            s.top := math.max(s.top, t)
            s.bottom := math.min(s.bottom, bot)
            box.set_top(s.bx, s.top)
            box.set_bottom(s.bx, s.bottom)
            if not na(s.eq)
                m = math.avg(s.top, s.bottom)
                line.set_y1(s.eq, m)
                line.set_y2(s.eq, m)
            merged := true
            break
    merged

// Builds the live box (+ optional midline) for a new zone segment and registers it.
newSegment(int dir, float t, float bot, int cid, int flips, int handoff) =>
    zoneCol = dir == 1 ? bullZoneCol : bearZoneCol
    bordCol = zoneBorder ? color.new(zoneCol, 0) : color.new(zoneCol, 100)
    bx = box.new(handoff, t, handoff, bot, border_color = bordCol, border_width = 1, border_style = zoneStyl, bgcolor = zoneCol, xloc = xloc.bar_index)
    line eq = na
    if showMid
        m = math.avg(t, bot)
        eq := line.new(handoff, m, handoff, m, xloc = xloc.bar_index, color = color.new(zoneCol, 0), width = 1, style = midStyl)
    s = Segment.new(dir, t, bot, bar_index, true, false, false, cid, flips, bx, na, na, na, eq, na, array.new<label>())
    array.push(segs, s)
    s

// Opens a brand-new crossfire chain from a base FVG and its opposite striker, with the origin funnel.
makeChain(FVG a, FVG b, int cid) =>
    t = math.min(a.lagTop, b.top)
    bot = math.max(a.lagBottom, b.bottom)
    made = false
    created = false
    if bot < t
        made := true
        if not (combineZones and mergeZone(b.dir, t, bot))
            created := true
            handoff = b.startBar - 1
            s = newSegment(b.dir, t, bot, cid, 1, handoff)
            if showFunnel
                fvgCol = a.dir == 1 ? bullFvgCol : bearFvgCol
                edgeCol = fvgBorder ? color.new(fvgCol, 0) : color.new(fvgCol, 100)
                topAnchor = a.dir == 1 ? a.startBar : a.startBar - 2
                botAnchor = a.dir == 1 ? a.startBar - 2 : a.startBar
                s.fvgTop := line.new(topAnchor, a.top, handoff, t, xloc = xloc.bar_index, color = edgeCol, width = 1, style = fvgStyl)
                s.fvgBot := line.new(botAnchor, a.bottom, handoff, bot, xloc = xloc.bar_index, color = edgeCol, width = 1, style = fvgStyl)
                s.fvgFill := linefill.new(s.fvgTop, s.fvgBot, fvgCol)
    [made, created]

// Freezes the live segment at the strike bar and opens the flipped segment on the striker/zone overlap.
flipSegment(Segment z, FVG b) =>
    t = math.min(b.top, z.top)
    bot = math.max(b.bottom, z.bottom)
    did = false
    if bot < t
        did := true
        handoff = b.startBar - 1
        box.set_right(z.bx, handoff)
        if not na(z.eq)
            line.set_x2(z.eq, handoff)
        if not na(z.mark)
            label.delete(z.mark)
            z.mark := na
        z.active := false
        newSegment(b.dir, t, bot, z.chainId, z.flips + 1, handoff)
    did

clearSegment(Segment s) =>
    if not na(s.bx)
        box.delete(s.bx)
        s.bx := na
    if not na(s.fvgFill)
        linefill.delete(s.fvgFill)
        s.fvgFill := na
    if not na(s.fvgTop)
        line.delete(s.fvgTop)
        s.fvgTop := na
    if not na(s.fvgBot)
        line.delete(s.fvgBot)
        s.fvgBot := na
    if not na(s.eq)
        line.delete(s.eq)
        s.eq := na
    if not na(s.mark)
        label.delete(s.mark)
        s.mark := na
    for lb in s.retestLbs
        label.delete(lb)
    array.clear(s.retestLbs)

// Fades every drawing of a segment once its chain is fully mitigated.
dimSegment(Segment s) =>
    zoneCol = s.dir == 1 ? bullZoneCol : bearZoneCol
    fvgCol = s.dir == 1 ? bearFvgCol : bullFvgCol
    if not na(s.bx)
        box.set_bgcolor(s.bx, dimmed(zoneCol))
        if zoneBorder
            box.set_border_color(s.bx, color.new(zoneCol, 45))
    if not na(s.eq)
        line.set_color(s.eq, color.new(zoneCol, 45))
    if not na(s.fvgFill)
        linefill.set_color(s.fvgFill, dimmed(fvgCol))
    if fvgBorder
        if not na(s.fvgTop)
            line.set_color(s.fvgTop, color.new(fvgCol, 45))
        if not na(s.fvgBot)
            line.set_color(s.fvgBot, color.new(fvgCol, 45))

// Ends a whole chain: freeze & dim it (retest arrows removed), or wipe it, depending on the setting.
finishChain(int cid) =>
    for s in segs
        if s.chainId == cid and not s.done
            s.done := true
            if not na(s.mark)
                label.delete(s.mark)
                s.mark := na
            if showMitigated
                for lb in s.retestLbs
                    label.delete(lb)
                array.clear(s.retestLbs)
                if s.active
                    if not na(s.bx)
                        box.set_right(s.bx, bar_index)
                    if not na(s.eq)
                        line.set_x2(s.eq, bar_index)
                dimSegment(s)
            else
                clearSegment(s)
            s.active := false

trimFvgs() =>
    while array.size(fvgs) > maxFVGs
        array.shift(fvgs)

trimSegments() =>
    while array.size(segs) > maxSegments
        clearSegment(array.shift(segs))

compactSegments() =>
    if array.size(segs) > 0
        for i = array.size(segs) - 1 to 0
            s = array.get(segs, i)
            if s.done and na(s.bx) and na(s.fvgFill)
                array.remove(segs, i)
//#endregion FUNCTION DECLARATIONS

//#region KEY LEVELS
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

var float asiaHigh = na
var float asiaLow = na
int asiaTime = time(timeframe.period, asiaSess, "America/New_York")
bool inAsiaSession = not na(asiaTime)
bool asiaStarted = inAsiaSession and na(asiaTime[1])
if asiaStarted
    asiaHigh := high
    asiaLow := low
else if inAsiaSession
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

var float londonHigh = na
var float londonLow = na
int londonTime = time(timeframe.period, londonSess, "America/New_York")
bool inLondonSession = not na(londonTime)
bool londonStarted = inLondonSession and na(londonTime[1])
if londonStarted
    londonHigh := high
    londonLow := low
else if inLondonSession
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)

var array<line> keyLines = array.new_line()
var array<label> keyLabels = array.new_label()

f_drawKey(float price, string txt, color col) =>
    if not na(price)
        keyLines.push(line.new(bar_index, price, bar_index + 5, price, xloc = xloc.bar_index, extend = extend.left, color = col, style = line.style_dotted, width = 2))
        keyLabels.push(label.new(bar_index + 6, price, txt, color = color.new(color.white, 100), textcolor = col, style = label.style_label_left, size = size.small))

if barstate.islast and showKeyLevels
    while keyLines.size() > 0
        line.delete(keyLines.pop())
    while keyLabels.size() > 0
        label.delete(keyLabels.pop())
    f_drawKey(pdh, "PDH", color.black)
    f_drawKey(pdl, "PDL", color.black)
    if includePw
        f_drawKey(pwh, "PWH", color.new(color.gray, 0))
        f_drawKey(pwl, "PWL", color.new(color.gray, 0))
    if not inAsiaSession
        f_drawKey(asiaHigh, "Asia High", color.new(#f23645, 0))
        f_drawKey(asiaLow, "Asia Low", color.new(#f23645, 0))
    if not inLondonSession
        f_drawKey(londonHigh, "London High", color.new(#2962ff, 0))
        f_drawKey(londonLow, "London Low", color.new(#2962ff, 0))
//#endregion KEY LEVELS

//#region VWAPS
get_anchored_vwap(cond) =>
    var float sumSrcVol = 0.0
    var float sumVol = 0.0
    if cond
        sumSrcVol := hlc3 * volume
        sumVol := volume
    else
        sumSrcVol += hlc3 * volume
        sumVol += volume
    sumVol > 0 ? sumSrcVol / sumVol : na

isTdoStart = hour(time, "America/New_York") >= 18 and hour(time[1], "America/New_York") < 18
isNyStart = hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 30
isNySession = not na(time(timeframe.period, "0930-1600", "America/New_York"))

tdoVwap = get_anchored_vwap(isTdoStart or barstate.isfirst)
nyVwap = get_anchored_vwap(isNyStart or barstate.isfirst)

plot(showVwaps ? tdoVwap : na, title = "TDO VWAP", color = tdoColor, linewidth = 2)
plot(showVwaps and isNySession ? nyVwap : na, title = "NY Session VWAP", color = nyColor, linewidth = 2)

// Active VWAP for the trend filter: NY during the NY session, TDO outside it.
// The grace period matters — the NY VWAP anchors at 09:30 with almost no
// sample behind it, so for the first several minutes it sits nearly on top of
// price and flips sides on noise. Until it has enough data to mean anything,
// the filter keeps using TDO.
//
// Measured against the anchor's timestamp rather than counting bars, so the
// setting means the same thing on any chart timeframe.
var int nyAnchorTime = na
if isNyStart
    nyAnchorTime := time

bool nyGracePassed = not na(nyAnchorTime) and (time - nyAnchorTime) >= nyVwapGraceMins * 60 * 1000
bool nyVwapReady = isNySession and nyGracePassed
float activeVwap = nyVwapReady ? nyVwap : tdoVwap
bool vwapLongOk  = not useVwapTrend or (not na(activeVwap) and close > activeVwap)
bool vwapShortOk = not useVwapTrend or (not na(activeVwap) and close < activeVwap)
//#endregion VWAPS

//#region SESSION GATE
bool inSess1 = not na(time(timeframe.period, sess1, "America/New_York"))
bool inSess2 = not na(time(timeframe.period, sess2, "America/New_York"))
bool inSession = not useSess or inSess1 or inSess2
//#endregion SESSION GATE

//#region CALCULATIONS
if barstate.isconfirmed
    dGap = timeframe.isintraday and (timeframe.change("D") or timeframe.change("D")[1])
    wGap = (timeframe.isintraday or timeframe.isdaily) and (timeframe.change("W") or timeframe.change("W")[1])
    blockGap = dGap or wGap
    bool inWindow = last_bar_index - bar_index <= lookback

    // Delayed fill of base FVGs; fully filled ones drop out of the candidate pool.
    if array.size(fvgs) > 0
        for i = array.size(fvgs) - 1 to 0
            f = array.get(fvgs, i)
            lagMitigate(f)
            if f.lagTop <= f.lagBottom
                array.remove(fvgs, i)

    FVG newFvg = na
    if not blockGap and inWindow
        if low > high[2]
            t = low
            b = high[2]
            if (t - b) / close * 100.0 >= minGap
                newFvg := FVG.new(1, t, b, t, b, bar_index)
        else if high < low[2]
            t = low[2]
            b = high
            if (t - b) / close * 100.0 >= minGap
                newFvg := FVG.new(-1, t, b, t, b, bar_index)

    if not na(newFvg)
        consumed = false

        // The striker first flips any opposite live zone it overlaps...
        nSeg = array.size(segs)
        if nSeg > 0
            for i = 0 to nSeg - 1
                s = array.get(segs, i)
                if s.active and not s.done and s.dir == -newFvg.dir
                    if flipSegment(s, newFvg)
                        consumed := true

        // ...then strikes any remaining opposite base FVGs; a struck base is spent.
        if array.size(fvgs) > 0
            for i = array.size(fvgs) - 1 to 0
                f = array.get(fvgs, i)
                if f.dir == -newFvg.dir
                    [made, created] = makeChain(f, newFvg, chainSeq)
                    if created
                        chainSeq += 1
                    if made
                        consumed := true
                        array.remove(fvgs, i)

        // A striker that produced or flipped a zone is spent too; otherwise it waits as a base.
        if not consumed
            array.push(fvgs, newFvg)

    // Retest + full mitigation of live zones. A retest fires every time price re-enters after being outside.
    hiSrc = zoneWick ? high : close
    loSrc = zoneWick ? low : close
    for s in segs
        if s.active and not s.done and s.createBar < bar_index
            touch = high >= s.bottom and low <= s.top
            if touch and not s.touching
                evRetest := true
                // Capture retest details for the entry model. The zone's FAR
                // side is its mitigation edge — bottom for bullish, top for
                // bearish — which is what the zone-based SL option uses.
                retestDir := s.dir
                retestStars := s.flips
                retestFar := s.dir == 1 ? s.bottom : s.top
                if retestMarks
                    lb = label.new(bar_index, na, s.dir == 1 ? "▲" : "▼", xloc = xloc.bar_index, yloc = s.dir == 1 ? yloc.belowbar : yloc.abovebar, style = label.style_none, textcolor = color.new(s.dir == 1 ? bullZoneCol : bearZoneCol, 0), size = size.tiny)
                    array.push(s.retestLbs, lb)
                    if array.size(s.retestLbs) > maxRetestMarks
                        label.delete(array.shift(s.retestLbs))
            s.touching := touch
            mitigated = s.dir == 1 ? loSrc <= s.bottom : hiSrc >= s.top
            if mitigated
                finishChain(s.chainId)

    compactSegments()
    trimFvgs()
    trimSegments()
//#endregion CALCULATIONS

//#region ENTRY MODEL
// A retest ARMS a pending entry; BOS in the zone's direction FIRES it.
// Independent 1m pivot tracking — deliberately not reusing the zone geometry,
// so the confirmation is a genuine structural break rather than a restatement
// of the same zone boundary that produced the retest.
float bosPh = ta.pivothigh(high, bosPivotLen, bosPivotLen)
float bosPl = ta.pivotlow(low, bosPivotLen, bosPivotLen)
var float lastBosPH = na
var float lastBosPL = na
if not na(bosPh)
    lastBosPH := bosPh
if not na(bosPl)
    lastBosPL := bosPl

float bosBuffer = bosBufferTicks * syminfo.mintick

var int pendLongBar = na
var int pendShortBar = na
var int pendLongStars = 0
var int pendShortStars = 0
var float pendLongFar = na
var float pendShortFar = na

// Only zones meeting the star minimum can arm an entry.
if evRetest and retestStars >= minStars
    if retestDir == 1
        pendLongBar := bar_index
        pendLongStars := retestStars
        pendLongFar := retestFar
    else
        pendShortBar := bar_index
        pendShortStars := retestStars
        pendShortFar := retestFar

if not na(pendLongBar) and bar_index - pendLongBar > bosWindow
    pendLongBar := na
if not na(pendShortBar) and bar_index - pendShortBar > bosWindow
    pendShortBar := na

// Displacement on the trigger candle.
float dispRange = high - low
float dispBody = math.abs(close - open)
float dispBodyPct = dispRange > 0 ? dispBody / dispRange : 0.0
bool dispRangeOk = not na(atr14) and atr14 > 0 and dispRange >= atr14 * dispRangeAtr
bool dispBodyOk = dispBodyPct >= dispBodyRatio
bool dispLongOk = not useDisp or (dispRangeOk and dispBodyOk and (not dispDirClose or close > open))
bool dispShortOk = not useDisp or (dispRangeOk and dispBodyOk and (not dispDirClose or close < open))

bool bosLong = not na(lastBosPH) and ta.crossover(close, lastBosPH + bosBuffer)
bool bosShort = not na(lastBosPL) and ta.crossunder(close, lastBosPL - bosBuffer)

// With BOS off, the retest itself is the trigger (original behavior).
bool longTrigger = useBosEntry ? (not na(pendLongBar) and bosLong) : (evRetest and retestDir == 1 and retestStars >= minStars)
bool shortTrigger = useBosEntry ? (not na(pendShortBar) and bosShort) : (evRetest and retestDir == -1 and retestStars >= minStars)

var int lastLongBar = na
var int lastShortBar = na
bool longCooldownOk = na(lastLongBar) or bar_index - lastLongBar >= cooldownBars
bool shortCooldownOk = na(lastShortBar) or bar_index - lastShortBar >= cooldownBars

bool longEntry = longTrigger and dispLongOk and vwapLongOk and inSession and longCooldownOk and barstate.isconfirmed
bool shortEntry = shortTrigger and dispShortOk and vwapShortOk and inSession and shortCooldownOk and barstate.isconfirmed
//#endregion ENTRY MODEL

//#region RISK
float slBuffer = slBufferTicks * syminfo.mintick

// ta.lowest()/ta.highest() must run unconditionally every bar for Pine's
// history tracking — never nested inside a conditional or a function that
// only executes on signal bars.
float structLow = ta.lowest(low[1], slLookbackBars)
float structHigh = ta.highest(high[1], slLookbackBars)

var float tradeEntry = na
var float tradeSL = na
var float tradeTP = na
var int tradeDir = 0
var int tradeEntryBar = na
var line lineSL = na
var line lineTP = na
var label lblSL = na
var label lblTP = na
var label lastLongLbl = na
var label lastShortLbl = na
// Used only when onlyLastEntry is off — a capped FIFO of past entry markers.
var array<label> entryLabels = array.new<label>()

// Creates the marker and, in history mode, manages the capped FIFO. Returns
// the new label so the caller can assign it to lastLongLbl/lastShortLbl at
// global scope — Pine functions cannot reassign globals (CE10088), so that
// assignment has to happen outside.
//
// The history cap matters: entry markers share the 500-label budget with the
// zone star labels and retest arrows, and when that budget runs out
// TradingView silently drops the oldest drawings — which would start eating
// the zone visuals rather than just old entries.
f_entryLabel(bool isLong, float y, string txt, color col) =>
    label lb = label.new(bar_index, y, txt, yloc = isLong ? yloc.belowbar : yloc.abovebar, style = isLong ? label.style_label_up : label.style_label_down, color = col, textcolor = color.white, size = size.small)
    if not onlyLastEntry
        entryLabels.push(lb)
        while entryLabels.size() > maxEntryLabels
            label.delete(entryLabels.shift())
    lb

f_calcTrade(bool isLong, float zoneFar) =>
    float entry = close
    float structRef = isLong ? structLow : structHigh
    float zoneRef = na(zoneFar) ? structRef : zoneFar
    float rawSL = slMethod == "Recent market structure" ? structRef : zoneRef
    float sl = isLong ? rawSL - slBuffer : rawSL + slBuffer
    sl := isLong and sl >= entry ? entry - syminfo.mintick : sl
    sl := not isLong and sl <= entry ? entry + syminfo.mintick : sl
    float risk = math.abs(entry - sl)
    float tp = isLong ? entry + risk * rrRatio : entry - risk * rrRatio
    [entry, sl, tp]

if longEntry
    lastLongBar := bar_index
    [e, s, t] = f_calcTrade(true, pendLongFar)
    tradeEntry := e
    tradeSL := s
    tradeTP := t
    tradeDir := 1
    tradeEntryBar := bar_index
    if showTracker
        line.delete(lineSL), line.delete(lineTP)
        label.delete(lblSL), label.delete(lblTP)
        lineSL := line.new(bar_index, tradeSL, bar_index + 5, tradeSL, color = color.orange, style = line.style_solid, width = 2)
        lineTP := line.new(bar_index, tradeTP, bar_index + 5, tradeTP, color = color.blue, style = line.style_solid, width = 2)
        lblSL := label.new(bar_index + 5, tradeSL, "SL " + str.tostring(tradeSL, format.mintick), color = color.new(color.orange, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
        lblTP := label.new(bar_index + 5, tradeTP, "TP " + str.tostring(tradeTP, format.mintick) + " (" + str.tostring(rrRatio) + "R)", color = color.new(color.blue, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
    if onlyLastEntry
        label.delete(lastLongLbl)
    lastLongLbl := f_entryLabel(true, low, "▲", longEntryColor)
    pendLongBar := na

if shortEntry
    lastShortBar := bar_index
    [e, s, t] = f_calcTrade(false, pendShortFar)
    tradeEntry := e
    tradeSL := s
    tradeTP := t
    tradeDir := -1
    tradeEntryBar := bar_index
    if showTracker
        line.delete(lineSL), line.delete(lineTP)
        label.delete(lblSL), label.delete(lblTP)
        lineSL := line.new(bar_index, tradeSL, bar_index + 5, tradeSL, color = color.orange, style = line.style_solid, width = 2)
        lineTP := line.new(bar_index, tradeTP, bar_index + 5, tradeTP, color = color.blue, style = line.style_solid, width = 2)
        lblSL := label.new(bar_index + 5, tradeSL, "SL " + str.tostring(tradeSL, format.mintick), color = color.new(color.orange, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
        lblTP := label.new(bar_index + 5, tradeTP, "TP " + str.tostring(tradeTP, format.mintick) + " (" + str.tostring(rrRatio) + "R)", color = color.new(color.blue, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
    if onlyLastEntry
        label.delete(lastShortLbl)
    lastShortLbl := f_entryLabel(false, high, "▼", shortEntryColor)
    pendShortBar := na

// Trade completion cleanup
if not na(tradeEntry)
    if showTracker
        line.set_x2(lineSL, bar_index + 5)
        line.set_x2(lineTP, bar_index + 5)
        label.set_x(lblSL, bar_index + 5)
        label.set_x(lblTP, bar_index + 5)
    bool closed = false
    if bar_index > tradeEntryBar
        if tradeDir == 1
            closed := low <= tradeSL or high >= tradeTP
        else if tradeDir == -1
            closed := high >= tradeSL or low <= tradeTP
    if closed
        if showTracker
            line.delete(lineSL), line.delete(lineTP)
            label.delete(lblSL), label.delete(lblTP)
        tradeEntry := na
        tradeDir := 0
        tradeEntryBar := na
//#endregion RISK

//#region VISUALS
if barstate.islast
    for s in segs
        if s.active and not s.done
            if not na(s.bx)
                box.set_right(s.bx, bar_index)
            if not na(s.eq)
                line.set_x2(s.eq, bar_index)
            zoneCol = s.dir == 1 ? bullZoneCol : bearZoneCol
            txt = s.dir == 1 ? "\n" + starText(s.flips) : starText(s.flips)
            markY = s.dir == 1 ? s.bottom : s.top
            if na(s.mark)
                s.mark := label.new(bar_index, markY, txt, xloc = xloc.bar_index, style = label.style_none, textcolor = color.new(zoneCol, 0), size = size.small)
            else
                label.set_xy(s.mark, bar_index, markY)
                label.set_text(s.mark, txt)
                label.set_textcolor(s.mark, color.new(zoneCol, 0))
//#endregion VISUALS

//#region ALERTS
if alertEntry and longEntry
    alert(syminfo.ticker + " — LONG | " + str.tostring(pendLongStars) + "★ zone | Entry " + str.tostring(tradeEntry, format.mintick) + " | SL " + str.tostring(tradeSL, format.mintick) + " | TP " + str.tostring(tradeTP, format.mintick), alert.freq_once_per_bar_close)

if alertEntry and shortEntry
    alert(syminfo.ticker + " — SHORT | " + str.tostring(pendShortStars) + "★ zone | Entry " + str.tostring(tradeEntry, format.mintick) + " | SL " + str.tostring(tradeSL, format.mintick) + " | TP " + str.tostring(tradeTP, format.mintick), alert.freq_once_per_bar_close)

if alertRetestOnly and evRetest
    alert(syminfo.ticker + " — " + (retestDir == 1 ? "BULLISH" : "BEARISH") + " zone retest | " + str.tostring(retestStars) + "★ (unconfirmed)", alert.freq_once_per_bar_close)

alertcondition(longEntry, title = "Crossfire — LONG Entry", message = "{{ticker}} Crossfire: LONG entry")
alertcondition(shortEntry, title = "Crossfire — SHORT Entry", message = "{{ticker}} Crossfire: SHORT entry")
//#endregion ALERTS
````
