# EonMetrics Support and Resistance Zones

- url: https://www.tradingview.com/script/tL8eRqIU-EonMetrics-Support-and-Resistance-Zones/
- type: indicator
- pine_id: PUB;7d9a7b722c884db1b31f295a6a23013e
- version: 1.0

## Description

Support and Resistance Zones builds support and resistance areas from confirmed swing points. It merges nearby pivots with the same role, records separate price visits and their volume, and removes inactive zones. A configurable cap keeps the number of tracked zones bounded.

🔶[b]HOW LEVELS ARE BUILT[/b]

Each confirmed swing high is a resistance candidate and each confirmed swing low is a support candidate. Nearby pivots merge into the nearest active zone with the same role. A new candidate is discarded if a close between the pivot and confirmation has already breached its proposed boundary and break margin.

New zones start on the confirmation bar. Their initial width is 0.6 times the current 200-bar median range, with a minimum of two price ticks. Width and break margin are stored at creation, so later volatility changes alone cannot move the zone. A subsequent matching pivot may widen its boundaries; it cannot shrink them.

A zone's record has two raw numbers:

Touches — the founding pivot counts as the first observation. After creation, each separate visit counts once: a candle's high-low range overlaps the known zone after a bar whose range was outside it. Consecutive overlapping candles form one visit. A later pivot confirmation updates geometry without adding another touch for the same visit. A close that breaks the zone is recorded as a break and does not add a touch. These are visits, not proof that price bounced.

Volume — the seed pivot's candle volume plus the whole-candle volume on each subsequent entry bar. The label ranks this accumulated volume against other active zones with complete volume data. This is not volume traded specifically inside the zone. The rank is omitted if volume is missing, fewer than two eligible zones remain, or the zone has only its founding observation.

https://www.tradingview.com/x/l8LsTZ1Y/

Both numbers are shown as they are. There is no composite "strength score", because a score would require knowing how to weigh a touch against volume — and we do not pretend to know that. You see the evidence; you weigh it.

🔶[b]ZONES HAVE A LIFECYCLE[/b]

Break and role flip — a confirmed close beyond the visible boundary plus its stored margin breaks the zone. Support flips to resistance and vice versa. The break is evaluated before any newly confirmed pivot widens the zone. Broken zones remain as dashed references for the configured retention period; their touch count and volume are frozen, and they are not reactivated or merged.

Expiry — an active zone is removed after the configured number of consecutive bars without overlap. Remaining inside keeps the zone alive without increasing its touch count. Opacity reflects the visit count and time since the latest overlap.

Hard cap — the chart never holds more than a set number of zones. When the cap is hit, the zone with the fewest touches goes first. Zones die on their own; they never wait for a replacement.

🔶[b]ORIGINALITY[/b]

🔹Zone geometry — a median-based initial band grows only when a matching confirmed pivot lies outside it. Drawing, touch detection and break detection use the same boundaries.

🔹Visit records — touch count and accumulated entry-bar volume rank are shown separately, with no composite strength score.

🔹Lifecycle — same-role merging, expiry, break retention and a hard cap keep the number of objects bounded.

🔹Volatility scaling — merge tolerance follows the 200-bar median range. Initial width and break margin use that median when a zone is created and are then stored. The median is floored at the symbol's minimum tick size.

🔶[b]ALERTS[/b]

Four conditions, evaluated on closed bars: price entered an active support zone, price entered an active resistance zone, zone broken (role flipped), zone reached three touches. Alerts respect the minimum-touch visibility filter. With a filter above three, the third-touch alert is suppressed. A break bar does not also fire an entry alert for that same zone.

🔶[b]HOW TO USE[/b]

1. Load it to inspect the zones still retained on your chart. Expired zones and zones evicted by the cap are deleted; the script is not a permanent archive of every historical level.
2. Raise "Show Zones With At Least N Touches" to 2–3 for a cleaner chart; single-touch zones are still tracked and reappear when they earn their next touch.
3. Read dashed broken zones as references in their flipped role. Retests after the break do not add touches or trigger zone-entry alerts.
4. Set the zone-entry alerts on the levels you care about and stop staring at the chart.

🔶[b]SETTINGS[/b]

Detection: pivot length, merge tolerance and break margin.

Zone Lifecycle: expiry, broken-zone retention and maximum number of zones.

Display: minimum-touch filter, counter and colors.

🔶[b]HONEST LIMITATIONS[/b]

A swing is only confirmed Pivot Length bars later. Boxes start at confirmation; visits between the original pivot and confirmation are not replayed. All state changes use confirmed bars, without higher-timeframe requests or future data.

Existing boxes can widen when later pivots confirm, change role after a break, or be deleted by expiry or the cap. Their current appearance is not a snapshot of what was visible at every earlier bar.

The median needs time to adapt after a volatility change. On markets that supply tick volume, the rank uses tick volume; missing volume suppresses the rank. Touches measure candle-range overlap, not successful rebounds, and accumulated volume covers entire entry candles. Neither metric forecasts a future reaction.

Part of the EonMetrics toolset.

## Source Code

````pine
//@version=6
indicator('EonMetrics Support and Resistance Zones', 'S&R Zones by EonMetrics', overlay=true, max_boxes_count=100, max_labels_count=100)

// ═════════════════════════════════════════════════════════════════════════════
//  DETECTION
// ═════════════════════════════════════════════════════════════════════════════
grpDet = 'Detection'

pivLen = input.int(10, 'Pivot Length', minval=2, maxval=50, group=grpDet,
  tooltip = 'Bars required on each side of a swing high/low. A zone starts on the confirmation bar, not on the earlier pivot bar. Larger = fewer swings and a longer detection delay.')

tolMult = input.float(0.5, 'Merge Tolerance (x median bar range)', minval=0.1, maxval=5.0, step=0.1, group=grpDet,
  tooltip = 'How close a new pivot must land to an existing zone to merge into it instead of creating a new one. Measured in multiples of the median bar range of the last 200 bars. Larger = fewer, wider zones.')

breakMult = input.float(0.25, 'Break Margin (x median bar range)', minval=0.0, maxval=3.0, step=0.05, group=grpDet,
  tooltip = 'How far beyond the visible zone edge a bar must CLOSE to break it. The median-based margin is fixed when the zone is created. 0 = any close beyond the edge. A break is recorded before a pivot can widen the zone.')

// ═════════════════════════════════════════════════════════════════════════════
//  ZONE LIFECYCLE
// ═════════════════════════════════════════════════════════════════════════════
grpLife = 'Zone Lifecycle'

decayBars = input.int(300, 'Expire After (bars without a touch)', minval=50, maxval=2000, group=grpLife,
  tooltip = 'A zone is removed after this many consecutive bars without price overlapping it. Staying inside keeps it alive but does not add extra touches.')

flipKeep = input.int(100, 'Keep Broken Zones (bars)', minval=10, maxval=500, group=grpLife,
  tooltip = 'How long a broken zone stays on the chart (dashed, in its flipped role) before it is removed.')

maxZones = input.int(12, 'Max Zones on Chart', minval=3, maxval=25, group=grpLife,
  tooltip = 'Hard cap. When exceeded, the zone with the fewest touches goes first (oldest on a tie). This is what keeps the chart readable after months of history.')

// ═════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═════════════════════════════════════════════════════════════════════════════
grpDisp = 'Display'

minTouchShow = input.int(2, 'Show Zones With At Least N Touches', minval=1, maxval=10, group=grpDisp,
  tooltip = 'Visibility filter — zones below this touch count are tracked but hidden. 2-3 gives a much cleaner chart; the zones are still there when they earn their next touch.')

showCounter = input.bool(true, 'Show Zone Counter', group=grpDisp,
  tooltip = 'Small corner readout: how many zones are alive and how many recently broken.')

colSup = input.color(#089981, 'Support',    inline='c', group=grpDisp)
colRes = input.color(#f23645, 'Resistance', inline='c', group=grpDisp)
colBrk = input.color(#787b86, 'Broken',     inline='c', group=grpDisp)

// ═════════════════════════════════════════════════════════════════════════════
//  ENGINE — global-scope series (execution-model rule: all ta.* unconditional)
// ═════════════════════════════════════════════════════════════════════════════
medianRange = ta.median(high - low, 200)
unit = na(medianRange) ? na : math.max(medianRange, syminfo.mintick)
ph   = ta.pivothigh(high, pivLen, pivLen)
pl   = ta.pivotlow(low, pivLen, pivLen)

type Zone
    float top
    float bot
    int   touches
    float volAcc
    int   lastTouchBar
    int   createdBar
    int   createdTime
    bool  isSupport
    bool  broken
    int   brokenBar
    bool  inZone
    float breakMargin
    bool  volumeComplete
    box   bx
    label lb

var array<Zone> zones = array.new<Zone>()

// index of the nearest unbroken zone whose tolerance band contains p; -1 if none
f_findZone(float p, float tol, bool support) =>
    int idx = -1
    float bestDist = na
    int n = zones.size()
    if n > 0
        for i = 0 to n - 1
            Zone z = zones.get(i)
            if not z.broken and z.isSupport == support and p >= z.bot - tol and p <= z.top + tol
                float dist = math.abs(p - (z.top + z.bot) / 2)
                if na(bestDist) or dist < bestDist
                    idx := i
                    bestDist := dist
    idx

// Reject a delayed pivot if a close invalidated its proposed zone between the
// pivot and confirmation. It must not resurrect an already broken level.
f_validSeed(float p, bool support, float halfWidth, float margin) =>
    bool valid = true
    for k = 0 to pivLen - 1
        if (support and close[k] < p - halfWidth - margin) or (not support and close[k] > p + halfWidth + margin)
            valid := false
    valid

f_addPivot(float p, bool support, float tol, float halfWidth, float margin) =>
    int idx = f_findZone(p, tol, support)
    if idx >= 0
        Zone z = zones.get(idx)
        // Live re-entries already account for visits. Pivot confirmation only
        // widens geometry; counting it again would duplicate the same visit.
        z.top := math.max(z.top, p)
        z.bot := math.min(z.bot, p)
        // Widening must not manufacture a re-entry on the following bar.
        z.inZone := low <= z.top and high >= z.bot
        if z.inZone
            z.lastTouchBar := bar_index
    else if f_validSeed(p, support, halfWidth, margin)
        // The founding pivot supplies one observation. Subsequent visits are
        // counted only after the zone is known, without retrospective replay.
        float top = p + halfWidth
        float bot = p - halfWidth
        bool inNow = low <= top and high >= bot
        zones.push(Zone.new(top, bot, 1, nz(volume[pivLen]), bar_index, bar_index, time,
             support, false, 0, inNow, margin, not na(volume[pivLen]),
             box.new(time, top, time, bot, xloc=xloc.bar_time, border_width=1),
             label.new(bar_index, p, '', style=label.style_label_left, size=size.small)))
    idx

// per-bar event flags (consumed by alertconditions at the end)
bool evSupTouch = false
bool evResTouch = false
bool evBreak    = false
bool evStrong   = false

if barstate.isconfirmed and not na(unit)
    float tol = unit * tolMult

    // Evaluate known boundaries before delayed pivots can widen them.
    int n = zones.size()
    if n > 0
        for i = n - 1 to 0
            Zone z = zones.get(i)
            bool remove = false
            if z.broken
                if bar_index - z.brokenBar >= flipKeep
                    remove := true
            else
                bool inNow = low <= z.top and high >= z.bot
                bool breaks = (z.isSupport and close < z.bot - z.breakMargin) or (not z.isSupport and close > z.top + z.breakMargin)
                // Break-through bars do not increase the visit count or strength.
                if breaks
                    z.broken    := true
                    z.brokenBar := bar_index
                    z.isSupport := not z.isSupport
                    evBreak     := evBreak or z.touches >= minTouchShow
                else if inNow
                    z.lastTouchBar := bar_index
                    if not z.inZone
                        z.touches += 1
                        z.volAcc += nz(volume)
                        z.volumeComplete := z.volumeComplete and not na(volume)
                        if z.touches >= minTouchShow
                            if z.isSupport
                                evSupTouch := true
                            else
                                evResTouch := true
                            if z.touches == 3
                                evStrong := true
                z.inZone := inNow
                if not z.broken and bar_index - z.lastTouchBar >= decayBars
                    remove := true
            if remove
                box.delete(z.bx)
                label.delete(z.lb)
                zones.remove(i)

    // Capture thickness and break margin when a zone is created. Later
    // volatility changes alone cannot move its boundaries or break threshold.
    float halfWidth = math.max(unit * 0.3, syminfo.mintick)
    float margin = unit * breakMult
    if not na(ph)
        f_addPivot(ph, false, tol, halfWidth, margin)
    if not na(pl)
        f_addPivot(pl, true, tol, halfWidth, margin)

    // ── hard cap: drop the weakest (fewest touches, oldest on a tie) ─────────
    while zones.size() > maxZones
        int wi = 0
        Zone w = zones.get(0)
        for i = 1 to zones.size() - 1
            Zone c = zones.get(i)
            if c.touches < w.touches or (c.touches == w.touches and c.createdBar < w.createdBar)
                wi := i
                w  := c
        box.delete(w.bx)
        label.delete(w.lb)
        zones.remove(wi)

    // ── restyle: geometry, colors, opacity by touches + age, labels ──────────
    // `for i = 0 to size - 1` on an empty array counts DOWN from 0 and still runs
    // one iteration in Pine, so every unguarded loop over `zones` needs this check.
    if zones.size() > 0
        int alive = 0
        for i = 0 to zones.size() - 1
            if not zones.get(i).broken and zones.get(i).volumeComplete
                alive += 1
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            // Time coordinates keep frequently visited old zones valid even
            // when their origin is more than 10,000 chart bars back.
            box.set_lefttop(z.bx, z.createdTime, z.top)
            box.set_rightbottom(z.bx, time, z.bot)
            bool hidden = z.touches < minTouchShow
            color base = z.broken ? colBrk : z.isSupport ? colSup : colRes
            int age  = bar_index - z.lastTouchBar
            int bgT  = math.min(96, math.max(76, 94 - z.touches * 3 + math.round(10.0 * age / decayBars)))
            box.set_bgcolor(z.bx, hidden ? color.new(base, 100) : color.new(base, bgT))
            box.set_border_color(z.bx, hidden ? color.new(base, 100) : color.new(base, math.max(bgT - 35, 0)))
            box.set_border_style(z.bx, z.broken ? line.style_dashed : line.style_solid)
            box.set_border_width(z.bx, z.touches >= 5 and not z.broken ? 2 : 1)
            // volume percentile vs the other living zones — raw, not a composite score
            int cnt = 0
            for j = 0 to zones.size() - 1
                if j != i and not zones.get(j).broken and zones.get(j).volumeComplete and zones.get(j).volAcc < z.volAcc
                    cnt += 1
            // volume rank is only meaningful once a zone has been tested more than once
            int pct = alive > 1 and not z.broken and z.volumeComplete and z.touches > 1 ? math.round(100.0 * cnt / (alive - 1)) : na
            string txt = z.broken ?
                 'BROKEN · now ' + (z.isSupport ? 'S' : 'R') :
                 (z.isSupport ? 'S' : 'R') + ' · ' + str.tostring(z.touches) + (z.touches == 1 ? ' touch' : ' touches') + (na(pct) ? '' : ' · vol ' + str.tostring(pct) + '%')
            label.set_xy(z.lb, bar_index + 2, (z.top + z.bot) / 2)
            label.set_text(z.lb, hidden ? '' : txt)
            label.set_color(z.lb, color.new(base, 100))
            label.set_textcolor(z.lb, hidden ? color.new(base, 100) : color.new(base, math.max(bgT - 55, 0)))

// ═════════════════════════════════════════════════════════════════════════════
//  COUNTER
// ═════════════════════════════════════════════════════════════════════════════
var table cTbl = table.new(position.bottom_right, 1, 1)
if showCounter and barstate.islast
    int aliveN = 0
    int brokeN = 0
    // counts what is actually drawn — zones below the touch filter are tracked but hidden
    if zones.size() > 0
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            if z.touches >= minTouchShow
                if z.broken
                    brokeN += 1
                else
                    aliveN += 1
    table.cell(cTbl, 0, 0, 'S&R · ' + str.tostring(aliveN) + ' active · ' + str.tostring(brokeN) + ' broken',
         text_color=color.new(color.gray, 20), text_size=size.tiny, bgcolor=color.new(color.gray, 92))

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(evSupTouch, title='1. Price entered a support zone',    message='S&R Zones: price entered a support zone.')
alertcondition(evResTouch, title='2. Price entered a resistance zone', message='S&R Zones: price entered a resistance zone.')
alertcondition(evBreak,    title='3. Zone broken (role flipped)',      message='S&R Zones: a zone was broken by a close and flipped its role.')
alertcondition(evStrong,   title='4. Zone reached 3 touches',          message='S&R Zones: a zone just recorded its third touch.')
````
