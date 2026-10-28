# FVG Crossfire

- url: https://www.tradingview.com/script/uTeXKnH4-FVG-Crossfire/
- type: indicator
- pine_id: PUB;5efe3c3efecb462898f78c0864b9a681
- version: 2.0

## Description

[b]GENERAL OVERVIEW:[/b]
FVG Crossfire identifies and plots the exact price bands where a bullish and a bearish imbalance have overlapped. These overlap bands,  called crossfire zones, are the only objects the indicator draws. Ordinary Fair Value Gaps are tracked in the background as inputs, but a standalone gap is never rendered on the chart; a zone is created only when a fresh FVG overlaps an older, still-unfilled FVG of the opposite direction. From that point the zone remains on the chart, reversing direction each time an opposing FVG overlaps it, recording each transition with a star counter, marking every retest with  an arrow, and being removed only when price trades fully through it.

[image]https://www.tradingview.com/x/Rd2YUi03/[/image]

[b]What is the theory behind the indicator?[/b]
A Fair Value Gap records a price imbalance: price moved quickly enough that a gap was left between the wicks of the surrounding candles. The problem is that FVGs are common. On a fast chart dozens print every session, most of them noise, and drawing them all obscures the few levels that actually matter.

FVG Crossfire is built on a stricter criterion: the event worth displaying is the overlap. When a new imbalance prints in the opposite direction directly on top of an older, still-unfilled one, that price band is no longer one-sided; buyers have left an imbalance there, and now sellers have as well (or the reverse). That overlap marks a contested level, one the market has already reacted to from both directions.

The sequence often continues. Each additional opposing FVG flips the zone again, and because a flip keeps only the portion of the zone where the imbalances actually overlap, the contested band becomes tighter and more precise with each transition. What remains is a narrow, repeatedly tested level with a visible history, which is among the strongest forms of support or resistance an imbalance structure can produce.

The FVG Crossfire indicator includes 5 main features:
[list=1]
[*][b]FVG CROSSFIRE FEATURES[/b]
[*]Crossfire Zone Detection
[*]Zone Flipping & Flip Counter
[*]Retest Detection
[*]Zone Mitigation
[*]Alerts
[/list]

[b]CROSSFIRE ZONE DETECTION:[/b]

🔹What Is a Crossfire Zone?
A crossfire zone is the price band shared by two opposite imbalances: an older, still-unfilled Fair Value Gap and a newly formed FVG in the opposite direction that printed on top of it. The zone covers only the overlap, and it takes the direction and color of the newer FVG, the most recent side to print. An optional "origin funnel" draws converging lines from the older gap into the zone, so the source of the overlap remains visible.

[image]https://www.tradingview.com/x/6lAiuDH9/[/image]

🔹What Is a Fair Value Gap?
For background: an FVG is a three-candle pattern where the middle candle moves so strongly that a gap is left between the first candle and the third: the low of candle three above the high of candle one (bullish), or the high of candle three below the low of candle one (bearish). In this indicator FVGs are inputs, not output: they are detected and tracked entirely in the background, and one that never overlaps an opposite gap is discarded without ever being drawn.

🔹Why Are Crossfire Zones Important?
A single gap indicates one-sided aggression at a price. A crossfire zone indicates that both sides were aggressive at the same prices and disagreed. These contested bands tend to attract price repeatedly, which makes them stronger candidates for support, resistance, and reaction trades than any single gap. And because only overlaps are drawn, every object on the chart is already a filtered, higher-significance level.

🔹How Crossfire Zones Are Detected:
Every candle close, the engine scans the last three candles for a new FVG (gaps smaller than your minimum size are skipped, and candles around daily or weekly session breaks are excluded so overnight gaps don't create false patterns). Each stored gap is also tracked as later candles fill it (by wick or by close, depending on the setting), and a fully filled gap is dropped from the pool. When a fresh FVG confirms, it is compared against every waiting opposite gap: wherever it overlaps the unfilled part of one, a crossfire zone is created on the overlap and the origin funnel appears. Every FVG participates exactly once; after creating (or flipping) a zone it is consumed, so one price move never produces duplicate zones. Live zones extend to the right edge of the chart, and an optional "Combine" mode merges same-direction zones that overlap in price into one bigger zone.

[image]https://www.tradingview.com/x/pp3ZbiTz/[/image]

🔹Settings: Base FVG Group (the detection engine)
[list]
[*]Base FVG mitigation: whether wicks or only candle closes fill a waiting gap before it can participate in an overlap.
[*]Min FVG gap (% of price): ignore gaps below this size; 0 keeps every gap.
[*]Show origin funnel: draw the converging lines from the source gap into its zone.
[*]Border, Style, Colors: visual control of the funnel; color transparency sets the fill strength.
[/list]

🔹Settings: Crossfire Zone Group
[list]
[*]Lookback (candles): zones are only built inside the most recent N candles (default 3000); every zone created in the window is shown.
[*]Border, Style, Midline: outline and optional equilibrium line for each zone.
[*]Bullish / Bearish colors: transparency sets the zone fill strength.
[*]Combine overlapping zones: merge same-color zones that overlap in price.
[/list]

[b]ZONE FLIPPING & FLIP COUNTER:[/b]

🔹What Is a Zone Flip?
If a live crossfire zone is overlapped by another FVG in the opposite direction, the zone flips: the current box is frozen in place and a new, opposite-colored box continues from that point. Read left to right, a flipped zone forms a timeline of directional control over that price band.

[image]https://www.tradingview.com/x/5h51SvR8/[/image]

🔹Why Do Flips Matter?
Every flip is another change of direction at the same level, evidence that the market continues to react to that price. And because each flip keeps only the part of the zone that the new FVG actually overlapped, the contested band tightens with every flip. A zone that has flipped three times is a narrow, precise, repeatedly contested level, exactly the kind of area worth planning trades around.

🔹How the Flip Counter Works:
Each live zone shows a star counter on its edge at the latest candle: green stars touching the bottom edge of bullish zones, red stars touching the top edge of bearish zones. One star means the zone has formed once, two stars means one flip, and so on; zones with five or more entries display a compact count instead (for example "6 ★"). There is no limit on flips; the chain only ends when the zone is fully mitigated.

[b]RETEST DETECTION:[/b]

🔹What Is a Retest?
A retest is price leaving a live crossfire zone and then coming back to touch it again. The indicator marks every single retest: a small green ▲ below the candle that re-entered a bullish zone, a small red ▼ above the candle that re-entered a bearish zone.

[image]https://www.tradingview.com/x/ZjVAqi0M/[/image]

🔹Why Are Retests Important?
The retest is usually the tradeable moment. A contested zone holding on a return visit is the confirmation many traders wait for before entering, and repeated successful retests indicate the level continues to hold.

🔹How Retests Are Detected:
On every candle close, the indicator checks whether the candle touched the zone (any wick contact counts) while the previous candle did not. Each fresh re-entry counts; price must leave the zone before the next retest can register, so a candle sitting inside the zone for several bars only counts once. Every retest can also fire an alert.

🔹Settings:
[list]
[*]Retest markers: show or hide the ▲/▼ arrows.
[/list]

[b]ZONE MITIGATION:[/b]

🔹What Is Zone Mitigation?
A crossfire zone is complete (fully mitigated) when price trades all the way through it: through the bottom of a bullish zone, or through the top of a bearish zone. At that point the zone and its whole flip history are removed from the chart, or kept and faded out if you prefer to study them.

[image]https://www.tradingview.com/x/PjQaoII6/[/image]

🔹Why Does Mitigation Matter?
A zone that price has completely passed through has served its purpose: the imbalance on both sides is resolved. Removing finished zones keeps the chart focused on levels that still matter, while the optional faded view lets you review how past zones resolved.

🔹How Mitigation Is Detected:
You choose what counts as trading through the far side: any wick, or only a candle close. Until that happens, the zone stays live no matter how many times it flips or gets retested.

🔹Settings:
[list]
[*]Zone mitigation: Wick or Close.
[*]Show mitigated zones: keep finished chains on the chart, frozen and dimmed.
[/list]

[b]ALERTS:[/b]
FVG Crossfire covers the full life of a zone with four alert events, each with its own on/off switch. Create one alert on the indicator using "Any alert() function call" and every enabled event will come through with the symbol and timeframe in the message:
[list]
[*]New crossfire zone: two opposite FVGs overlapped and a new zone was created.
[*]Zone flipped: a live zone changed direction (bullish ↔ bearish).
[*]Zone retested: price re-entered a live zone after being outside it (fires on every re-entry).
[*]Zone mitigated: a zone was fully traded through and completed.
[/list]

[b]IMPORTANT NOTES:[/b]
[list]
[*]Plain FVGs are never drawn. Gaps are tracked in the background, and a gap only becomes visible, through its origin funnel, at the moment it produces a crossfire zone. Every object drawn on the chart is already an overlap.
[*]All detections are evaluated on candle close. Zones, flips, retests, and mitigations are confirmed events; they do not repaint.
[*]Background gaps are filled on a three-candle delay. This is deliberate: the same impulsive move that creates the new FVG is often the move that fills the old one, and without the delay the overlap could never be detected.
[*]Each FVG participates exactly once. After creating or flipping a zone it is consumed, so one price move never produces duplicate zones.
[*]A flip requires the new FVG to overlap the currently visible zone, and the flipped zone keeps only the overlapping part; zones tighten as they flip.
[*]A retest requires price to leave the zone first. Consecutive candles inside the zone count as one visit.
[*]Candles around daily and weekly session breaks are excluded from gap detection so overnight gaps don't create false patterns.
[*]Internal drawing limits keep the script within TradingView's object budget; on extremely gap-dense charts the oldest zones are released first.
[/list]

[b]UNIQUENESS:[/b]
Most FVG tools draw every gap and leave the trader to determine which ones matter; inversion (IFVG) tools go one step further and record a single change of direction. FVG Crossfire does not draw ordinary gaps at all. It uses them purely as inputs and puts only one thing on the chart: the price bands where opposite imbalances have overlapped, and it then tracks the full lifecycle of each contested level. Zones flip an unlimited number of times, each previous state freezes into a left-to-right timeline, the band tightens to the true overlap on every flip, a star counter records the number of transitions, every individual re-entry is flagged with a retest arrow and alert, and the level is only removed when price fully trades through it. The result is not another gap plotter: it is a filtered map of where opposing imbalances keep forming at the same prices, how many transitions each level has recorded, and exactly how tight the contested band has become.

[image]https://www.tradingview.com/x/weD7QPY4/[/image]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©fluxchart

//@version=6
indicator("FVG Crossfire | Flux Charts", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region CONSTANTS
int snapBars = 3
int maxFVGs = 80
int maxSegments = 120
int maxRetestMarks = 20
disp = display.none
//#endregion CONSTANTS

//#region INPUTS
string grpBase = "Base FVG"
string grpZone = "Crossfire Zone"
string grpAlert = "Alerts"

string fvgMitig = input.string("Close", "Base FVG mitigation", options = ["Wick", "Close"], tooltip = "How a waiting FVG gets filled: by wicks, or only by candle closes. A fully filled FVG can no longer create a zone.", group = grpBase, display = disp)
float minGap = input.float(0.0, "Min FVG gap (% of price)", minval = 0.0, step = 0.01, tooltip = "Skip tiny FVGs. 0 = keep every FVG.", group = grpBase, display = disp)
bool showFunnel = input.bool(true, "Show origin funnel", tooltip = "Draw lines from the old FVG into its zone, showing where the zone came from.", group = grpBase, display = disp)
bool fvgBorder = input.bool(false, "Border", tooltip = "Show or hide the funnel's edge lines.", inline = "fvgLine", group = grpBase, display = disp)
string fvgStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "fvgLine", group = grpBase, display = disp)
color bullFvgCol = input.color(color.new(#0ecb81, 86), "Bullish", tooltip = "Transparency here sets the fill strength.", inline = "fvgCol", group = grpBase, display = disp)
color bearFvgCol = input.color(color.new(#f6465d, 86), "Bearish", inline = "fvgCol", group = grpBase, display = disp)

int lookback = input.int(3000, "Lookback (candles)", minval = 100, maxval = 10000, tooltip = "Only build FVGs and zones inside the most recent N candles. All zones born in this window are shown.", group = grpZone, display = disp)
string zoneMitig = input.string("Close", "Zone mitigation", options = ["Wick", "Close"], tooltip = "A zone is finished when price trades through its far side — by wick, or only by close.", group = grpZone, display = disp)
bool zoneBorder = input.bool(false, "Border", tooltip = "Show or hide the zone's outline.", inline = "zoneLine", group = grpZone, display = disp)
string zoneStyle = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "zoneLine", group = grpZone, display = disp)
bool showMid = input.bool(false, "Midline", inline = "mid", group = grpZone, display = disp)
string midStyle = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "mid", group = grpZone, display = disp)
color bullZoneCol = input.color(color.new(#0ecb81, 80), "Bullish", tooltip = "Transparency here sets the zone fill strength.", inline = "zoneCol", group = grpZone, display = disp)
color bearZoneCol = input.color(color.new(#f6465d, 80), "Bearish", inline = "zoneCol", group = grpZone, display = disp)
bool retestMarks = input.bool(true, "Retest markers", tooltip = "Draw a small arrow every time price re-enters a zone after leaving it.", group = grpZone, display = disp)
bool combineZones = input.bool(false, "Combine overlapping zones", tooltip = "Merge overlapping zones of the same color into one bigger zone.", group = grpZone, display = disp)
bool showMitigated = input.bool(true, "Show mitigated zones", tooltip = "Keep finished zones on the chart, faded out.", group = grpZone, display = disp)

bool alertNew = input.bool(true, "New crossfire zone", tooltip = "Alerts when two opposite FVGs overlap and a new zone appears.", group = grpAlert, display = disp)
bool alertFlip = input.bool(true, "Zone flipped", tooltip = "Alerts when a zone changes color (bullish ↔ bearish).", group = grpAlert, display = disp)
bool alertRetest = input.bool(false, "Zone retested", tooltip = "Alerts every time price re-enters a zone after leaving it.", group = grpAlert, display = disp)
bool alertMitig = input.bool(false, "Zone mitigated", tooltip = "Alerts when a zone is finished.", group = grpAlert, display = disp)
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
bool evNew = false
bool evFlip = false
bool evRetest = false
bool evMitig = false
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
                        evFlip := true

        // ...then strikes any remaining opposite base FVGs; a struck base is spent.
        if array.size(fvgs) > 0
            for i = array.size(fvgs) - 1 to 0
                f = array.get(fvgs, i)
                if f.dir == -newFvg.dir
                    [made, created] = makeChain(f, newFvg, chainSeq)
                    if created
                        evNew := true
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
                if retestMarks
                    lb = label.new(bar_index, na, s.dir == 1 ? "▲" : "▼", xloc = xloc.bar_index, yloc = s.dir == 1 ? yloc.belowbar : yloc.abovebar, style = label.style_none, textcolor = color.new(s.dir == 1 ? bullZoneCol : bearZoneCol, 0), size = size.tiny)
                    array.push(s.retestLbs, lb)
                    if array.size(s.retestLbs) > maxRetestMarks
                        label.delete(array.shift(s.retestLbs))
            s.touching := touch
            mitigated = s.dir == 1 ? loSrc <= s.bottom : hiSrc >= s.top
            if mitigated
                evMitig := true
                finishChain(s.chainId)

    compactSegments()
    trimFvgs()
    trimSegments()
//#endregion CALCULATIONS

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
string alertSym = syminfo.ticker + " " + timeframe.period
if alertNew and evNew
    alert("FVG Crossfire [" + alertSym + "]: new crossfire zone formed.", alert.freq_once_per_bar)
if alertFlip and evFlip
    alert("FVG Crossfire [" + alertSym + "]: zone flipped direction.", alert.freq_once_per_bar)
if alertRetest and evRetest
    alert("FVG Crossfire [" + alertSym + "]: price retested a live zone.", alert.freq_once_per_bar)
if alertMitig and evMitig
    alert("FVG Crossfire [" + alertSym + "]: zone mitigated.", alert.freq_once_per_bar)
//#endregion ALERTS
````
