# Meanward Revert Zones

- url: https://www.tradingview.com/script/5wGAD8Rp-Meanward-Revert-Zones/
- type: indicator
- pine_id: PUB;b1e4cd6a9ca0491b86000a76a7fef22e
- version: 1.0

## Description

A mean-reversion channel with four depth zones and a statistics table that answers one question: when price stretched this far from its mean on this symbol and timeframe, how did it come back?

[b]What it shows[/b]
[list]
[*]The channel. A SuperSmoother mean line (default: hlc3, 200 bars) with an inner and an outer band built from the smoothed true range.
[*]Four zones on each side of the mean: Ultra-small (the inner band), Small, Central (the outer band) and Deep. Each boundary sits at a fixed distance from the outer band, measured in units of smoothed range.
[*]The table. One row per zone, counted over the bars loaded on your chart.
[*]A "Now" row: whether a stretch is open right now, how deep it went and how many bars it has lasted.
[/list]

[b]How episodes are counted[/b]
An episode starts when a bar's high touches the first upper zone (or its low touches the first lower zone) and ends when price touches the mean line again. Each zone row includes every finished episode that reached that zone, measured from the bar of the touch. Only closed bars are counted, so the numbers don't repaint.

[b]The columns[/b]
[list]
[*]Episodes: how many finished episodes reached the zone.
[*]Returned ≤ N bars: the share that got back to the mean within N bars of the touch (N is a setting, 50 by default).
[*]Favorable: the share where the mean, at the moment of return, was on the better side of the touch level. Below it for upper zones, above it for lower ones.
[*]Median bars, Max bars: how long the return took.
[*]Median excursion, Max excursion: how far price kept going past the touch level before it returned, in percent.
[/list]

[b]How to read it[/b]
[list]
[*]Check Episodes first. Five episodes aren't statistics.
[*]A low Favorable share means price "returned" mostly because the mean caught up with it. Touching the mean isn't the same as getting a better price.
[*]Max bars and Max excursion are the tail. That's the row to study before you plan any averaging, not the median.
[*]Compare symbols and timeframes. The same zone behaves very differently on a 5m small-cap and a 4h major.
[/list]

[b]How to use it in a trading plan[/b]
The table doesn't tell you when to enter. It tells you what a mean-reversion plan has to survive on this symbol and timeframe. Five checks before you put money on a channel:
[list]
[*]Where to trade. Run the table over your shortlist of symbols and timeframes. A market with plenty of episodes, a high Favorable share and a short Max bars fits the channel better than one where returns are slow and mostly unfavorable.
[*]Which zone. Compare the rows. A deeper zone gives fewer episodes, and it doesn't automatically give a better Favorable share. Choose by the row, not by the name of the zone.
[*]Where the target is. Favorable is roughly the share of episodes where "enter at the zone, exit at the mean" closed in profit before fees. At 60%, four touches out of ten came back to the mean at a worse price than the entry, so the mean line alone is a weak target there.
[*]How much room the position needs. Excursion is how far price went against an entry at the touch level, in percent of price, before leverage. Size the position and space any averaging steps against Max excursion, not the median: the median is the usual case, the max is the one your margin has to cover.
[*]How long it can take. Multiply Median bars and Max bars by the timeframe. 250 bars on 15m is about 2.5 days in a position. If that's longer than you're ready to hold, change the timeframe or plan a time limit.
[/list]
The "Now" row is context, not a trigger. An open episode that's already past the median bars and excursion for its zone is in the tail, and the tail is where the table has the least data.

[b]What it isn't[/b]
There are no buy or sell signals and no alerts in this script. It describes what already happened on the loaded history. How a channel behaved before says nothing certain about the next touch.

[b]Settings[/b]
Price source, channel length and the two band multipliers control the channel. Return window sets N. Side limits the table to upper or lower zones, which is useful when a symbol stretches up and down differently. The table can be hidden or moved to any corner.

[b]Limits[/b]
The table covers only the bars your chart loads, so deeper history gives steadier numbers. The first bars, while the filter warms up, start no episodes. The open episode isn't included until it finishes.

[b]Credits[/b]
The channel core is a Pine v6 port of "Mean Reversion Channel - (fareid's MRI Variant)" by fareidzulkifli, reused with credit as its author allows. The SuperSmoother filter comes from John Ehlers' work. New here: the named zones, episode tracking and the return statistics table.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sergey Fedorov (meanward)
//@version=6

// Channel core: a Pine v6 port of "Mean Reversion Channel - (fareid's MRI Variant)" by fareidzulkifli (MPL 2.0),
// reused with credit as its author allows. The SuperSmoother filter comes from John Ehlers' work.
// New in this script: the named depth zones, episode tracking and the return statistics table.
indicator("Meanward Revert Zones v1.0", overlay = true)

const color COL_MEAN = #B59E54
const color COL_RES  = #A8626F
const color COL_SUP  = #5E9B8A

// ============================================================================
// Inputs
// ============================================================================

const string GRP_CH = "Channel"
float srcPrice  = input.source(hlc3, "Price source",
     tooltip = "Price the mean line is built from.", group = GRP_CH)
int   chLength  = input.int(200, "Channel length", minval = 1,
     tooltip = "Smoothing period of the mean line and the range. Longer is smoother and slower.", group = GRP_CH)
float innerMult = input.float(1.0, "Inner multiplier", minval = 0.1, step = 0.1,
     tooltip = "Width of the inner band in units of smoothed range. The inner band is the Ultra-small zone boundary, so keep it well below the outer multiplier.",
     group = GRP_CH)
float outerMult = input.float(2.415, "Outer multiplier", minval = 0.1, step = 0.001,
     tooltip = "Width of the outer band. The Small, Central and Deep zones are measured from it.", group = GRP_CH)
bool  showMean  = input.bool(true, "Show mean line", group = GRP_CH)
bool  showInner = input.bool(true, "Show inner channel", group = GRP_CH)
bool  showZones = input.bool(true, "Show zones",
     tooltip = "The outer band plus the Small and Deep zone boundaries.", group = GRP_CH)

const string GRP_STATS = "Statistics"
const string SIDE_BOTH = "Both"
const string SIDE_UP   = "Upper"
const string SIDE_LO   = "Lower"
int    returnWindow = input.int(50, "Return window, bars", minval = 1,
     tooltip = "N for the \"Returned ≤ N bars\" column: the share of episodes that got back to the mean within N bars of touching the zone.",
     group = GRP_STATS)
string side         = input.string(SIDE_BOTH, "Side", options = [SIDE_BOTH, SIDE_UP, SIDE_LO],
     tooltip = "Which zones the table counts: above the mean, below it, or both together.", group = GRP_STATS)
bool   showTable    = input.bool(true, "Show statistics table", group = GRP_STATS)
string tablePos     = input.string("Bottom right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GRP_STATS)

// ============================================================================
// Channel and zones
// ============================================================================

// SuperSmoother (Ehlers): a two-pole low-pass filter
supersmoother(float _src, simple int _length) =>
    float a1 = math.exp(-math.sqrt(2.0) * math.pi / _length)
    float b1 = 2.0 * a1 * math.cos(math.sqrt(2.0) * math.pi / _length)
    float c3 = -math.pow(a1, 2.0)
    float c2 = b1
    float c1 = 1.0 - c2 - c3
    float ss = 0.0
    ss := c1 * _src + c2 * nz(ss[1], _src[1]) + c3 * nz(ss[2], _src[2])
    ss

float meanline  = supersmoother(srcPrice, chLength)
float meanrange = supersmoother(ta.tr, chLength)
float upInner = meanline + meanrange * math.pi * innerMult
float loInner = meanline - meanrange * math.pi * innerMult
float upOuter = meanline + meanrange * math.pi * outerMult
float loOuter = meanline - meanrange * math.pi * outerMult

// Zone boundaries, from the mean outwards:
//   1 Ultra-small = the inner band
//   2 Small       = the outer band minus 2 smoothed ranges
//   3 Central     = the outer band
//   4 Deep        = the outer band plus 2 smoothed ranges
float upSmall = upOuter - 2.0 * meanrange
float loSmall = loOuter + 2.0 * meanrange
float upDeep  = upOuter + 2.0 * meanrange
float loDeep  = loOuter - 2.0 * meanrange

plot(showMean ? meanline : na, "Mean line", color = color.new(COL_MEAN, 30))
plot(showInner ? upInner : na, "Upper inner band (Ultra-small zone)", color = color.new(COL_RES, 70))
plot(showInner ? loInner : na, "Lower inner band (Ultra-small zone)", color = color.new(COL_SUP, 70))
plot(showZones ? upOuter : na, "Upper outer band (Central zone)", color = color.new(COL_RES, 45), linewidth = 3)
plot(showZones ? loOuter : na, "Lower outer band (Central zone)", color = color.new(COL_SUP, 45), linewidth = 3)
plot(showZones ? upDeep : na, "Upper Deep zone boundary", color = color.new(COL_RES, 55), linewidth = 9)
plot(showZones ? loDeep : na, "Lower Deep zone boundary", color = color.new(COL_SUP, 55), linewidth = 9)
plot(showZones ? upSmall : na, "Upper Small zone boundary", color = color.new(COL_RES, 70), linewidth = 9)
plot(showZones ? loSmall : na, "Lower Small zone boundary", color = color.new(COL_SUP, 70), linewidth = 9)

// ============================================================================
// Episodes
// ============================================================================
// An episode is one stretch away from the mean and the return to it. It starts on the bar
// that touches the first zone and ends on the first later bar that touches the mean line.
// Upper and lower sides are tracked independently. Only closed bars are counted.

// Finished episodes that reached one zone
type ZoneStats
    array<int>   bars              // bars from the touch to the return
    array<float> excursion         // furthest move past the touch level, %
    int          inWindow  = 0     // returned within the return window
    int          favorable = 0     // the mean was on the better side of the touch level at the return

// The open episode of one side; arrays hold one slot per zone
type Episode
    bool         active   = false
    int          startBar = na
    array<int>   touchBar          // bar of the first touch, na if the zone wasn't reached
    array<float> touchLevel        // zone boundary on that bar
    array<float> maxExcursion      // furthest move past the touch level so far, %

var array<string> ZONE_NAMES = array.from("Ultra-small", "Small", "Central", "Deep")

var array<ZoneStats> stats = array.new<ZoneStats>()
if barstate.isfirst
    for k = 0 to 3
        stats.push(ZoneStats.new(array.new<int>(), array.new<float>()))
var Episode epUp = Episode.new(touchBar = array.new<int>(4, na), touchLevel = array.new<float>(4, na),
     maxExcursion = array.new<float>(4, na))
var Episode epLo = Episode.new(touchBar = array.new<int>(4, na), touchLevel = array.new<float>(4, na),
     maxExcursion = array.new<float>(4, na))

// _dir = 1 for the upper side (_extreme = high, _opposite = low), -1 for the lower side.
f_track(Episode _ep, array<float> _levels, float _extreme, float _opposite, int _dir, bool _canStart) =>
    if not _ep.active and _canStart and _dir * (_extreme - _levels.get(0)) >= 0
        _ep.active := true
        _ep.startBar := bar_index
        _ep.touchBar.fill(na)
    if _ep.active
        for k = 0 to 3
            if na(_ep.touchBar.get(k)) and _dir * (_extreme - _levels.get(k)) >= 0
                _ep.touchBar.set(k, bar_index)
                _ep.touchLevel.set(k, _levels.get(k))
                _ep.maxExcursion.set(k, 0.0)
            if not na(_ep.touchBar.get(k))
                float level = _ep.touchLevel.get(k)
                float exc = _dir * (_extreme - level) / level * 100.0
                _ep.maxExcursion.set(k, math.max(_ep.maxExcursion.get(k), exc))
        // The start bar can't end the episode, even if it spans the mean.
        if bar_index > _ep.startBar and _dir * (_opposite - meanline) <= 0
            for k = 0 to 3
                if not na(_ep.touchBar.get(k))
                    ZoneStats z = stats.get(k)
                    int n = bar_index - _ep.touchBar.get(k)
                    z.bars.push(n)
                    z.excursion.push(_ep.maxExcursion.get(k))
                    if n <= returnWindow
                        z.inWindow += 1
                    if _dir * (meanline - _ep.touchLevel.get(k)) < 0
                        z.favorable += 1
            _ep.active := false
    _ep.active

if barstate.isconfirmed
    // Skip the filter warm-up and the rare bars where the smoothed range dips below zero.
    bool canStart = bar_index >= chLength and meanrange > 0
    if side != SIDE_LO
        f_track(epUp, array.from(upInner, upSmall, upOuter, upDeep), high, low, 1, canStart)
    if side != SIDE_UP
        f_track(epLo, array.from(loInner, loSmall, loOuter, loDeep), low, high, -1, canStart)

// ============================================================================
// Statistics table
// ============================================================================

f_cell(table _t, int _col, int _row, string _txt, string _tip = "") =>
    table.cell(_t, _col, _row, _txt, text_color = chart.fg_color, text_size = size.small, tooltip = _tip)

f_pct(int _count, int _total) =>
    str.tostring(100.0 * _count / _total, "0") + "%"

// The open episode of one side, measured from the touch of the deepest zone it reached
f_now(Episode _ep, string _name) =>
    string s = ""
    if _ep.active
        int deepest = 0
        for k = 0 to 3
            if not na(_ep.touchBar.get(k))
                deepest := k
        s := _name + " episode open · deepest zone: " + ZONE_NAMES.get(deepest) + " · " +
             str.tostring(bar_index - _ep.touchBar.get(deepest)) + " bars since touch · excursion so far " +
             str.tostring(_ep.maxExcursion.get(deepest), "0.00") + "%"
    s

string tablePosition = switch tablePos
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

if showTable and barstate.islast
    var table tbl = table.new(tablePosition, 8, 6, bgcolor = color.new(chart.bg_color, 15),
         frame_color = color.new(chart.fg_color, 70), frame_width = 1,
         border_color = color.new(chart.fg_color, 85), border_width = 1)
    string sideNote = side == SIDE_BOTH ? "upper + lower" : side == SIDE_UP ? "upper" : "lower"
    f_cell(tbl, 0, 0, "Zone\n(" + sideNote + ")")
    f_cell(tbl, 1, 0, "Episodes", "Finished episodes that reached the zone.")
    f_cell(tbl, 2, 0, "Returned\n≤ " + str.tostring(returnWindow) + " bars",
         "Share of episodes that got back to the mean within the return window, counted from the touch.")
    f_cell(tbl, 3, 0, "Favorable",
         "Share of episodes where the mean, at the moment of return, was on the better side of the touch level: below it for upper zones, above it for lower ones.")
    f_cell(tbl, 4, 0, "Median\nbars", "Bars from the touch to the return, median.")
    f_cell(tbl, 5, 0, "Max\nbars", "Bars from the touch to the return, longest episode.")
    f_cell(tbl, 6, 0, "Median\nexcursion", "How far price went past the touch level before it returned, in % of the level. Median.")
    f_cell(tbl, 7, 0, "Max\nexcursion", "How far price went past the touch level before it returned, in % of the level. Worst episode.")
    for k = 0 to 3
        ZoneStats z = stats.get(k)
        int n = z.bars.size()
        f_cell(tbl, 0, k + 1, ZONE_NAMES.get(k))
        f_cell(tbl, 1, k + 1, str.tostring(n))
        f_cell(tbl, 2, k + 1, n > 0 ? f_pct(z.inWindow, n) : "—")
        f_cell(tbl, 3, k + 1, n > 0 ? f_pct(z.favorable, n) : "—")
        f_cell(tbl, 4, k + 1, n > 0 ? str.tostring(z.bars.median(), "0.#") : "—")
        f_cell(tbl, 5, k + 1, n > 0 ? str.tostring(z.bars.max()) : "—")
        f_cell(tbl, 6, k + 1, n > 0 ? str.tostring(z.excursion.median(), "0.00") + "%" : "—")
        f_cell(tbl, 7, k + 1, n > 0 ? str.tostring(z.excursion.max(), "0.00") + "%" : "—")
    string nowUp = f_now(epUp, "upper")
    string nowLo = f_now(epLo, "lower")
    string nowText = nowUp != "" and nowLo != "" ? nowUp + "\n" + nowLo :
         nowUp != "" ? nowUp : nowLo != "" ? nowLo : "no open episode"
    f_cell(tbl, 0, 5, "Now: " + nowText, "The open episode isn't in the statistics until it finishes.")
    table.merge_cells(tbl, 0, 5, 7, 5)
````
