# Zones min | jjart

- url: https://www.tradingview.com/script/ILl0rOKo-zones-min-jjart/
- type: indicator
- pine_id: PUB;4bea256f8bd04ac39618e7459e73d9df
- version: 1.0

## Description

Supply Demand + Imbalances Mini

A focused chart overlay for supply and demand zones, fair value gaps, imbalance clusters, and inverse fair value gaps. It combines local zones with optional 1-hour and daily supply/demand context in a single display.

HOW ZONES ARE BUILT

Demand starts with a bearish origin candle followed by 2 to 10 consecutive bullish or doji candles. The final candle in the sequence must close above the origin candle's open, without an earlier candle in that sequence already completing the same break. The zone extends from the origin open down to the lowest wick in the pattern. Supply uses the mirrored rules.

FVG detection uses a three-candle price gap with an additional middle-candle high/low condition. Gap size is filtered against the 200-bar standard deviation of the corresponding raw gap series. A gap receives the BAG label when the detection candle also closes beyond the middle candle's high for a bullish gap, or below its low for a bearish gap.

Overlapping gaps in the same direction can merge into a cluster when their overlap covers at least half the smaller gap. The combined range must not exceed four times the 14-bar ATR. The cluster label counts the gaps combined into that zone; this count is not a strength score.

An imbalance broken by a closing price can remain eligible for inversion for up to 8 chart bars. An iFVG forms only when a new opposing gap overlaps it by at least 25% of the smaller range. The resulting zone is their intersection. A closing-price break alone does not create an iFVG.

ZONE LIFECYCLE

Supply and demand zones are removed when a confirmed candle's wick moves beyond their far boundary. Imbalances are removed when price closes beyond their far boundary or their maximum fill reaches the selected threshold, which defaults to 65%.

The unfilled-portion setting progressively trims the visible zone as price trades into it. Original boundaries remain the basis for fill and invalidation calculations. Clusters can expand when new qualifying gaps are added.

Zones expire after 1,500 chart bars from creation. The active-zone limit also removes older entries when necessary.

HIGHER TIMEFRAMES AND TIMING

Optional 1H and 1D supply/demand patterns are calculated on their own source timeframes and displayed only on lower chart timeframes.

Zone creation, fill updates, and invalidation are committed at chart-bar close. Supply/demand detection uses completed candles and becomes available on the following chart candle's close. Higher-timeframe detection also uses completed source candles.

Boxes extend back to the pattern's origin for visual context. This does not mean the zone was known at that earlier candle. This script shows active zones rather than a permanent history of every past setup, so historical screenshots should not be treated as a record of signals available at each moment.

PRACTICAL TIPS

For a cleaner chart, raise Minimum imbalance size from 0.2 to 0.4 or 0.6. This filters out smaller gaps relative to the same 200-bar gap-size history. Lower values show more gaps.

Turn off Show only the unfilled portion when you want to inspect the original zone boundaries. Turn it on when you want the chart to emphasize what remains unfilled. The deletion rules stay the same in both modes.

To compare individual gaps with combined areas, temporarily disable cluster merging. This helps explain why a cluster's boundaries expanded and why its label count increased.

On lower timeframes, disable either the 1H or 1D layer if overlapping boxes make the chart difficult to read. Each layer has its own color settings.

DEFAULT COLORS

Local demand: green. Local supply: pink.
Higher-timeframe demand: light blue. Higher-timeframe supply: purple.
Bullish imbalances: cyan. Bearish imbalances: light pink.

This is a visual analysis indicator. It does not place orders, generate trade alerts, or provide webhook messages. A zone marks a price pattern, not a guaranteed reaction or an entry instruction.

## Source Code

````pine
//@version=6
indicator('Zones min | jjart', overlay = true, max_boxes_count = 500, max_bars_back = 1500)

bool showSD = input.bool(true, 'Supply / Demand', group = 'Zones')
bool showFvg = input.bool(true, 'FVG / BAG', group = 'Zones')
bool showBPR = input.bool(true, 'Merge overlapping imbalances into clusters', group = 'Zones')
bool enableInv = input.bool(true, 'iFVG confirmed by an opposing gap', group = 'Zones')
float gapFilter = input.float(0.2, 'Minimum imbalance size (standard deviations)', minval = 0, maxval = 10, step = 0.05, group = 'Zones')
float overlapPct = input.float(65, 'Remove imbalance at fill (%)', minval = 10, maxval = 100, step = 5, group = 'Zones')
bool shrinkZones = input.bool(true, 'Show only the unfilled portion', group = 'Zones')
bool showSD1H = input.bool(true, 'Show 1H supply / demand', group = 'Higher Timeframes')
bool showSD1D = input.bool(true, 'Show 1D supply / demand', group = 'Higher Timeframes')
int maxZones = input.int(150, 'Maximum active zones', minval = 10, maxval = 450, group = 'Appearance')
bool showNames = input.bool(true, 'Show labels', group = 'Appearance')
color cDemand = input.color(color.new(#22AB94, 74), 'Demand', group = 'Appearance')
color cSupply = input.color(color.new(#EC407A, 78), 'Supply', group = 'Appearance')
color cDemandHtf = input.color(color.new(#90BFF9, 80), 'Demand HTF', group = 'Appearance')
color cSupplyHtf = input.color(color.new(#BA68C8, 80), 'Supply HTF', group = 'Appearance')
color cFvgBull = input.color(color.new(#00BCD4, 87), 'Bullish imbalance', group = 'Appearance')
color cFvgBear = input.color(color.new(#F06292, 87), 'Bearish imbalance', group = 'Appearance')

const int MIN_SPAN = 3
const int MAX_SPAN = 11
int chartSec = nz(timeframe.in_seconds(), 0)
int msBar = math.max(1, chartSec) * 1000
float atr14 = ta.atr(14)

type zone
    float origTop
    float origBot
    float drawTop
    float drawBot
    int leftTime
    int bornBar
    bool isBull
    int kind
    bool inverted = false
    int grp = 1
    float maxFill = 0
    box bx = na

var array<zone> zones = array.new<zone>()
var array<zone> broken = array.new<zone>()
var array<int> brokenAt = array.new_int()

f_newZone(float top, float bot, int t0, bool bull, int kind) =>
    zone z = zone.new(top, bot, top, bot, t0, bar_index, bull, kind)
    zones.push(z)
    z

// Match an origin candle followed by 2-10 opposing candles; use closed bars only.
f_sdSpan(bool _isDemand) =>
    int sb = na
    for n = MAX_SPAN to MIN_SPAN
        bool originOk = _isDemand ? close[n] < open[n] : close[n] > open[n]
        if originOk
            float o_n = open[n]
            bool ok = _isDemand ? close[1] > o_n : close[1] < o_n
            if ok
                for j = 1 to n - 1
                    bool contOk = _isDemand ? close[j] >= open[j] : close[j] <= open[j]
                    if not contOk
                        ok := false
                        break
            if ok and n > 2
                for j = 2 to n - 1
                    if _isDemand ? close[j] >= o_n : close[j] <= o_n
                        ok := false
                        break
            if ok
                sb := n
                break
    sb

// Demand: origin open to the lowest wick. Supply: highest wick to origin open.
f_sdZone(bool _isDemand) =>
    int   sb = f_sdSpan(_isDemand)
    float zt = na
    float zb = na
    int   t0 = na
    if not na(sb)
        if _isDemand
            zt := open[sb]
            zb := low[1]
            for j = 1 to sb
                zb := math.min(zb, low[j])
        else
            zb := open[sb]
            zt := high[1]
            for j = 1 to sb
                zt := math.max(zt, high[j])
        t0 := time[sb]
    [zt, zb, t0]

[locDzt, locDzb, locDt0] = f_sdZone(true)
[locSzt, locSzb, locSt0] = f_sdZone(false)
bool okLoc = showSD and barstate.isconfirmed

bool use1H = showSD1H and chartSec < 3600
bool use1D = showSD1D and chartSec < 86400

// HTF lookahead reads only completed source candles, indexed [1] through [11].
f_sdBoth() =>
    [dzt, dzb, dt0] = f_sdZone(true)
    [szt, szb, st0] = f_sdZone(false)
    [dzt, dzb, dt0, szt, szb, st0]
[h_Dzt, h_Dzb, h_Dt0, h_Szt, h_Szb, h_St0] = request.security(syminfo.tickerid, '60', f_sdBoth(), lookahead = barmerge.lookahead_on)
[d_Dzt, d_Dzb, d_Dt0, d_Szt, d_Szb, d_St0] = request.security(syminfo.tickerid, 'D',  f_sdBoth(), lookahead = barmerge.lookahead_on)

float rawGapBull = low - high[2]
float rawGapBear = low[2] - high
float sdGapBull  = ta.stdev(rawGapBull, 200)
float sdGapBear  = ta.stdev(rawGapBear, 200)
float gapSigBull = na(sdGapBull) or sdGapBull <= 0 ? na : rawGapBull / sdGapBull
float gapSigBear = na(sdGapBear) or sdGapBear <= 0 ? na : rawGapBear / sdGapBear

// Exclude three-candle patterns spanning a time gap longer than 2.5 chart bars.
bool timeGap = chartSec > 0 and not na(time[1]) and not na(time[2]) and math.max(time - time[1], time[1] - time[2]) > chartSec * 2500.0
bool newFvgBull = showFvg and barstate.isconfirmed and not timeGap and low > high[2] and high[1] > high[2] and not na(gapSigBull) and gapSigBull > gapFilter
bool newFvgBear = showFvg and barstate.isconfirmed and not timeGap and high < low[2] and low[1] < low[2] and not na(gapSigBear) and gapSigBear > gapFilter

var int barD_loc = 0
var int barS_loc = 0
var int barD_1h = 0
var int barS_1h = 0
var int barD_1d = 0
var int barS_1d = 0

if barstate.isconfirmed
    while brokenAt.size() > 0
        if bar_index - brokenAt.get(0) > 8 or brokenAt.size() > 100
            brokenAt.shift()
            broken.shift()
        else
            break

zone freshFvg = na
if newFvgBull
    freshFvg := f_newZone(low, high[2], time[2], true, close > high[1] ? 1 : 0)
if newFvgBear
    freshFvg := f_newZone(low[2], high, time[2], false, close < low[1] ? 1 : 0)

// Inversion requires an opposing gap within 8 bars and at least 25% overlap.
// Clusters require 50% overlap of the smaller gap and a union no larger than 4 ATR.
if not na(freshFvg)
    if enableInv and broken.size() > 0
        for k = broken.size() - 1 to 0
            zone old = broken.get(k)
            if old.isBull != freshFvg.isBull
                float top = math.min(freshFvg.origTop, old.origTop)
                float bot = math.max(freshFvg.origBot, old.origBot)
                float h = math.min(freshFvg.origTop - freshFvg.origBot, old.origTop - old.origBot)
                if top > bot and top - bot >= 0.25 * h
                    freshFvg.origTop := top
                    freshFvg.origBot := bot
                    freshFvg.drawTop := top
                    freshFvg.drawBot := bot
                    freshFvg.kind := 0
                    freshFvg.inverted := true
                    broken.remove(k)
                    brokenAt.remove(k)
                    break
    if showBPR and zones.size() > 1
        for k = zones.size() - 2 to 0
            zone old = zones.get(k)
            if old.kind < 3 and old.isBull == freshFvg.isBull
                float overlap = math.min(freshFvg.origTop, old.origTop) - math.max(freshFvg.origBot, old.origBot)
                float h = math.min(freshFvg.origTop - freshFvg.origBot, old.origTop - old.origBot)
                float unionH = math.max(freshFvg.origTop, old.origTop) - math.min(freshFvg.origBot, old.origBot)
                if overlap > 0 and overlap >= 0.5 * h and unionH <= nz(atr14, unionH) * 4
                    float oldH = old.origTop - old.origBot
                    old.origTop := math.max(old.origTop, freshFvg.origTop)
                    old.origBot := math.min(old.origBot, freshFvg.origBot)
                    old.maxFill := old.maxFill * oldH / (old.origTop - old.origBot)
                    old.drawTop := math.max(old.drawTop, freshFvg.drawTop)
                    old.drawBot := math.min(old.drawBot, freshFvg.drawBot)
                    old.leftTime := math.min(old.leftTime, freshFvg.leftTime)
                    old.grp += 1
                    old.kind := 2
                    zones.pop()
                    break
if okLoc and not na(locDt0) and locDzt > locDzb and locDt0 > barD_loc
    barD_loc := locDt0
    f_newZone(locDzt, locDzb, locDt0, true, 3)
if okLoc and not na(locSt0) and locSzt > locSzb and locSt0 > barS_loc
    barS_loc := locSt0
    f_newZone(locSzt, locSzb, locSt0, false, 3)

if use1H and barstate.isconfirmed
    if not na(h_Dt0) and h_Dzt > h_Dzb and h_Dt0 > barD_1h
        barD_1h := h_Dt0
        f_newZone(h_Dzt, h_Dzb, h_Dt0, true, 4)
    if not na(h_St0) and h_Szt > h_Szb and h_St0 > barS_1h
        barS_1h := h_St0
        f_newZone(h_Szt, h_Szb, h_St0, false, 4)
if use1D and barstate.isconfirmed
    if not na(d_Dt0) and d_Dzt > d_Dzb and d_Dt0 > barD_1d
        barD_1d := d_Dt0
        f_newZone(d_Dzt, d_Dzb, d_Dt0, true, 5)
    if not na(d_St0) and d_Szt > d_Szb and d_St0 > barS_1d
        barS_1d := d_St0
        f_newZone(d_Szt, d_Szb, d_St0, false, 5)

// Update fill and invalidation only at bar close. S/D uses wick breaches; gaps use closes or fill.
if barstate.isconfirmed and zones.size() > 0
    for i = zones.size() - 1 to 0
        zone z = zones.get(i)
        float h = z.origTop - z.origBot
        float fill = z.isBull ? (z.origTop - math.max(low, z.origBot)) / h * 100 : (math.min(high, z.origTop) - z.origBot) / h * 100
        z.maxFill := math.max(z.maxFill, math.max(0, fill))
        if shrinkZones
            if z.isBull
                z.drawTop := math.max(math.min(z.drawTop, math.max(low, z.origBot)), z.origBot)
            else
                z.drawBot := math.min(math.max(z.drawBot, math.min(high, z.origTop)), z.origTop)
        bool closedOut = z.isBull ? close < z.origBot : close > z.origTop
        bool wickedOut = z.isBull ? low < z.origBot : high > z.origTop
        bool dead = z.kind >= 3 ? wickedOut : closedOut or z.maxFill >= overlapPct
        if dead or h <= 0 or bar_index - z.bornBar > 1500
            if dead and closedOut and z.kind < 3 and enableInv
                broken.push(z)
                brokenAt.push(bar_index)
            box.delete(z.bx)
            zones.remove(i)
    while zones.size() > maxZones
        zone oldest = zones.shift()
        box.delete(oldest.bx)

if zones.size() > 0
    for z in zones
        bool sd = z.kind >= 3
        color bg = sd ? (z.kind > 3 ? (z.isBull ? cDemandHtf : cSupplyHtf) : (z.isBull ? cDemand : cSupply)) : (z.isBull ? cFvgBull : cFvgBear)
        string name = sd ? (z.isBull ? 'Demand' : 'Supply') + (z.kind == 4 ? ' 1H' : z.kind == 5 ? ' 1D' : '') : (z.kind == 2 ? 'Cluster ×' + str.tostring(z.grp) : z.inverted ? 'iFVG' : z.kind == 1 ? 'BAG' : 'FVG')
        float top = shrinkZones ? z.drawTop : z.origTop
        float bot = shrinkZones ? z.drawBot : z.origBot
        int rightTime = time + msBar * (sd ? 20 : 10)
        if na(z.bx)
            z.bx := box.new(left = z.leftTime, top = top, right = rightTime, bottom = bot, xloc = xloc.bar_time, bgcolor = bg, border_color = color.new(bg, 25), text = showNames ? name : '', text_color = color.new(bg, 0), text_size = size.tiny, text_halign = text.align_right)
        else
            box.set_lefttop(z.bx, z.leftTime, top)
            box.set_rightbottom(z.bx, rightTime, bot)
            box.set_bgcolor(z.bx, bg)
            box.set_text(z.bx, showNames ? name : '')
````
