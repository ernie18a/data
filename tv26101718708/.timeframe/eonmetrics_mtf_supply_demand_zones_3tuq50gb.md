# EonMetrics MTF Supply & Demand Zones

- url: https://www.tradingview.com/script/3Tuq50gB-EonMetrics-MTF-Supply-Demand-Zones/
- type: indicator
- pine_id: PUB;32c6a8e8f7404edc89613143daaf65bd
- version: 1.0

## Description

MTF SUPPLY & DEMAND ZONES

[b]What it does[/b]

A "supply and demand zone" is a small area on the chart where price paused quietly for a few candles, and was then immediately followed by one strong, decisive candle that shot away from it in one direction. That quiet pause is where this indicator draws its zone — the idea being that this is where a large amount of buying or selling built up right before the big move, so price is likely to react again if it ever comes back to that exact area.

The key part of this tool is that it does this search across up to six different timeframes at the same time — your current chart's timeframe plus up to five higher ones (like 15-minute, 1-hour, 4-hour, Daily) — and draws all of them directly onto the chart you're actually looking at. This means if you trade on a 5-minute chart, you can still see a major 4-hour or Daily zone approaching, without ever switching your chart away from the 5-minute view.

https://www.tradingview.com/x/0Rnnm2rk/

[b]How to actually use it (step by step)[/b]

Watch price as it approaches a colored box. Green boxes are "demand" zones (expect a possible bounce upward). Red boxes are "supply" zones (expect a possible bounce downward).
Pay more attention to boxes tagged with a bigger timeframe (like "4H" or "D") — these represent more significant, longer-term levels than a box tagged "5m" or "15m".
When price actually returns into a box, a small "R" letter appears — that's your cue that a retest is happening right now, worth watching closely for a reaction.
If a box's tag shows more than one timeframe at once (for example "15m, 1H"), it means multiple timeframes agree on almost the exact same price level — generally a stronger, more meaningful zone than one confirmed by only a single timeframe.
If a box gets fully broken through (depending on your settings, either by a wick or by a candle closing past its far edge), that zone has failed and should no longer be trusted — either it disappears from the chart or stays visible dimmed out, depending on your setting.
Every setting explained

https://www.tradingview.com/x/O85pyRmD/

[b]Detection group[/b]

Sensitivity — controls how strong and sudden the "breakout candle" must be before its pause area counts as a zone. Lower numbers require a much stronger candle (fewer zones, but stronger ones); higher numbers accept weaker candles (more zones, more frequent but less significant).
Min Base Candles — the minimum number of small pause candles required right before the strong candle for it to count as a real zone. A higher number demands a proper, visible pause; a lower number (like 1) also accepts a zone built from just a single quiet candle.
Max Base Candles — how far back the script is allowed to look for pause candles. This mostly just prevents extremely long pauses from creating unusually oversized zones.
Base Candle Max Size (x impulse) — how small each pause candle must be compared to the strong breakout candle to actually count as "part of the pause." Lower values demand a very obvious size difference between the quiet candles and the big one.
Zone Size Multiplier — makes every drawn zone box slightly bigger or smaller than its natural measured size, without changing where it's centered.
Min Zone Height (x ATR) — throws out zones that are too thin/flat to be meaningful (basically just noise). Raise this if you keep seeing tiny, unhelpful zones.
Max Zone Height (x ATR) — throws out zones that are too tall — a pause that large usually isn't really a tight pause, just a wide sideways range, and produces low-quality zones.
Timeframes group

Six on/off + timeframe pairs — turn each timeframe slot on or off, and pick which timeframe it should scan. Leaving a timeframe box empty means "use whatever timeframe my chart is currently on."
Zone Behavior group

Retest Trigger — decide what counts as price "returning" to a zone: any wick poking into it ("Wick" — earliest, most sensitive), or a full candle close inside it ("Close" — stricter, fewer false signals).
Zone Invalidation — decide what counts as a zone being broken/failed: a candle closing all the way through the far edge ("Close" — recommended, survives brief stop-hunt wicks), or any wick trading through it ("Wick" — kills the zone immediately, more sensitive).
Skip Overlapping Zones — when a new zone from one timeframe lands on almost the same price as an existing zone from another timeframe, this merges them into a single box (showing both timeframe tags) instead of drawing two overlapping duplicates.
Overlap Threshold — how much two zones need to overlap before they're considered "the same level" and merged together. Lower values merge more aggressively; higher values keep each timeframe's version separate more often.
Max Active Zones per Timeframe — the maximum number of zones from a single timeframe kept on the chart at once (the oldest one is dropped once you go over this). Since several timeframes can be active at once, the total on-screen count adds up across all of them.
Keep Broken Zones on Chart — when turned on, a zone that fails stays visible but dimmed with a dashed border (useful for reviewing which levels didn't hold). When off, failed zones are removed immediately.
Zone Display Range (x ATR) — temporarily hides zones that are currently very far away from price, just to reduce clutter. Hidden zones keep working in the background and reappear automatically once price gets close again. Set to 0 to always show every zone regardless of distance.
Style group

Supply / Demand — the fill colors for red (supply) and green (demand) zones.
Show Timeframe Label — prints which timeframe each zone came from directly inside the box.
Show Zone Mid-Line — adds a dotted line through the exact middle of every zone, sometimes used as a more precise reaction point.
Show Retest Markers — turns the small "R" touch-markers on or off.
Alerts group

New Zone / Zone Retest / Zone Break — turn each alert type on or off individually. In TradingView's own "Create Alert" window, choose "Any alert() function call" to receive the full, detailed messages (direction, timeframe, exact prices) for all of them at once.

## Source Code

````pine
//@version=6
indicator('EonMetrics MTF Supply & Demand Zones', 'MTF S&D Zones by EonMetrics', overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// MTF Supply & Demand Zones by EonMetrics — momentum-base zones from up to 6 timeframes.
//
// Detects supply/demand zones with the momentum-base method: a strong impulse candle
// (ATR-graded) preceded by a small consolidation base. The base becomes the zone —
// demand (green) when the impulse left it upward, supply (red) when downward. Zones from
// up to six timeframes (chart TF + higher TFs) are drawn on the current chart so HTF
// levels are visible without switching intervals. Non-repainting: a zone is only ever
// emitted from a closed bar of its own timeframe.

// ═════════════════════════════════════════════════════════════════════════════
//  DETECTION SETTINGS
// ═════════════════════════════════════════════════════════════════════════════
grpDet = 'Detection'

sens = input.int(3, 'Sensitivity', minval=1, maxval=10,
  group   = grpDet,
  tooltip = 'How strong a departure candle must be for its base to register as a zone. Internally the impulse candle range must exceed (2.8 − 0.2 × Sensitivity) × ATR(14). Lower = fewer but stronger zones; higher = more zones. 3 requires a ~2.2 × ATR candle (default, tuned to avoid clutter); 5 requires ~1.8 × ATR.')

minBase = input.int(2, 'Min Base Candles', minval=1, maxval=10,
  group   = grpDet,
  tooltip = 'Minimum number of small consolidation candles that must sit directly before the impulse. The base IS the zone, so at least this many candles define its bounds. 2 (default) requires a real consolidation, not just one candle; 1 = also accept single-candle bases (many more, weaker zones).')

maxBase = input.int(5, 'Max Base Candles', minval=1, maxval=15,
  group   = grpDet,
  tooltip = 'How far back the base scan extends. The scan walks left from the impulse and stops at the first candle that is NOT small — this cap only limits very long consolidations from producing oversized zones.')

baseRatio = input.float(0.5, 'Base Candle Max Size (x impulse)', minval=0.1, maxval=1.0, step=0.05,
  group   = grpDet,
  tooltip = 'A candle counts as part of the base only when its full range is at most this fraction of the impulse candle range. 0.5 = base candles must be at most half the impulse — the visual contrast a manual S&D trader looks for.')

zoneMult = input.float(1.0, 'Zone Size Multiplier', minval=0.5, maxval=3.0, step=0.1,
  group   = grpDet,
  tooltip = 'Scales the zone height around its midpoint. 1.0 = exact base high-to-low. Values above 1 widen the zone (more retests catch, less precision), below 1 tighten it.')

minHeightAtr = input.float(0.3, 'Min Zone Height (x ATR)', minval=0.0, maxval=2.0, step=0.05,
  group   = grpDet,
  tooltip = 'Zones thinner than this (before the multiplier) are skipped — filters out the tiny, low-information zones a flat or near-doji base would otherwise produce. Raise it if you\'re still seeing zones that look too small; 0 = no minimum.')

maxHeightAtr = input.float(3.5, 'Max Zone Height (x ATR)', minval=0.5, maxval=10.0, step=0.5,
  group   = grpDet,
  tooltip = 'Zones taller than this are skipped — a base this tall is a range, not a consolidation, and produces low-quality zones.')

// ═════════════════════════════════════════════════════════════════════════════
//  TIMEFRAMES  (6 slots — toggle + timeframe; empty = the chart timeframe)
// ═════════════════════════════════════════════════════════════════════════════
grpTf = 'Timeframes'

tfE1 = input.bool(true,  '', inline='tf1', group=grpTf)
tfS1 = input.timeframe('',    '1', inline='tf1', group=grpTf, tooltip='Empty = the chart timeframe. Slots set LOWER than the chart timeframe are ignored (TradingView cannot reliably build lower-TF zones on a higher-TF chart). Duplicate slots are harmless — the overlap filter removes the copies.')
tfE2 = input.bool(true,  '', inline='tf2', group=grpTf)
tfS2 = input.timeframe('15',  '2', inline='tf2', group=grpTf)
tfE3 = input.bool(false, '', inline='tf3', group=grpTf)
tfS3 = input.timeframe('30',  '3', inline='tf3', group=grpTf)
tfE4 = input.bool(true,  '', inline='tf4', group=grpTf)
tfS4 = input.timeframe('60',  '4', inline='tf4', group=grpTf)
tfE5 = input.bool(true,  '', inline='tf5', group=grpTf)
tfS5 = input.timeframe('240', '5', inline='tf5', group=grpTf)
tfE6 = input.bool(false, '', inline='tf6', group=grpTf)
tfS6 = input.timeframe('D',   '6', inline='tf6', group=grpTf)

// ═════════════════════════════════════════════════════════════════════════════
//  ZONE BEHAVIOR
// ═════════════════════════════════════════════════════════════════════════════
grpBeh = 'Zone Behavior'

retestMode = input.string('Wick', 'Retest Trigger', options=['Wick', 'Close'],
  group   = grpBeh,
  tooltip = 'What counts as price returning to a zone. Wick = any trade into the zone (earliest signal). Close = a candle must CLOSE inside the zone (stricter, fewer false touches). A zone re-arms for the next retest once price fully leaves it again.')

invMode = input.string('Close', 'Zone Invalidation', options=['Wick', 'Close'],
  group   = grpBeh,
  tooltip = 'What breaks a zone. Close = a candle must close through the FAR edge (survives stop-hunt wicks — recommended). Wick = any trade through the far edge kills the zone immediately.')

mergeOn = input.bool(true, 'Skip Overlapping Zones',
  group   = grpBeh,
  tooltip = 'When a new zone overlaps an existing ACTIVE zone of the same direction (from any timeframe) beyond the threshold below, the new one is skipped and the established zone is kept — one level, one box, no stacked duplicates across timeframes.')

mergeTh = input.float(0.45, 'Overlap Threshold', minval=0.1, maxval=1.0, step=0.05,
  group   = grpBeh,
  tooltip = 'Overlap fraction (relative to the smaller zone) above which the new zone counts as a duplicate. 0.45 (default) aggressively collapses the near-identical zones adjacent timeframes tend to produce. Raise toward 1.0 to see each timeframe\'s own version of a level separately.')

maxPerTf = input.int(5, 'Max Active Zones per Timeframe', minval=1, maxval=20,
  group   = grpBeh,
  tooltip = 'Cap of ACTIVE zones kept per timeframe slot — when exceeded, the oldest zone of that slot is dropped. With several timeframes enabled the totals add up (e.g. 4 TFs × 5 = up to 20 zones on screen); lower this further for a sparser chart. Keeps the chart readable and stays well inside the TradingView 500-box limit.')

showBroken = input.bool(false, 'Keep Broken Zones on Chart',
  group   = grpBeh,
  tooltip = 'ON = invalidated zones stay visible, dimmed with a dashed border, frozen at the break bar (useful to review which levels failed). OFF = broken zones are removed immediately. At most the 40 most recent broken zones are kept.')

distAtr = input.float(0.0, 'Zone Display Range (x ATR, 0 = all)', minval=0.0, maxval=50.0, step=0.5,
  group   = grpBeh,
  tooltip = 'Hides zones whose midpoint is farther than this many chart-ATRs from the current price — declutters when many HTF zones are far away. Hidden zones are only invisible: they keep tracking and reappear when price approaches. 0 = always show everything.')

// ═════════════════════════════════════════════════════════════════════════════
//  STYLE
// ═════════════════════════════════════════════════════════════════════════════
grpSty = 'Style'

supC = input.color(color.new(#f23645, 78), 'Supply', inline='cols', group=grpSty, tooltip='Zone fill colors — transparency of the picked color is used as-is. Borders and labels derive from the same color automatically.')
demC = input.color(color.new(#089981, 78), 'Demand', inline='cols', group=grpSty)

showTfTag = input.bool(true, 'Show Timeframe Label', group=grpSty,
  tooltip = 'Prints the originating timeframe (15m / 1H / 4H / D) inside each zone so you always know which perspective the level comes from.')

showMid = input.bool(false, 'Show Zone Mid-Line', group=grpSty,
  tooltip = 'Dotted line through the middle of each zone — a common refined-entry / partial-fill reference.')

showRetestLbl = input.bool(true, 'Show Retest Markers', group=grpSty,
  tooltip = 'Prints a small R marker on the candle that retests a zone.')

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════
grpAl = 'Alerts'

alNew = input.bool(true, 'New Zone',     group=grpAl, tooltip='Fires an alert() when a zone confirms on any enabled timeframe. In the Create Alert dialog choose "Any alert() function call" for the detailed per-zone messages, or pick one of the three named conditions for generic pings.')
alRt  = input.bool(true, 'Zone Retest',  group=grpAl, tooltip='Fires when price returns into an active zone (per the Retest Trigger rule).')
alBr  = input.bool(true, 'Zone Break',   group=grpAl, tooltip='Fires when a zone is invalidated (per the Zone Invalidation rule).')

// ═════════════════════════════════════════════════════════════════════════════
//  ENGINE — global-scope, drawing-free; evaluated once per security context.
//  Momentum-base detection: impulse candle graded vs ATR, base = the run of
//  small candles directly before it; the base extremes are the zone.
// ═════════════════════════════════════════════════════════════════════════════
g_atr = ta.atr(14)

impMult = 2.8 - 0.2 * sens
g_range = high - low
g_body  = math.abs(close - open)
g_impUp = close > open and g_range > g_atr * impMult and g_body > g_range * 0.55
g_impDn = close < open and g_range > g_atr * impMult and g_body > g_range * 0.55

float     g_sig = 0.0
var float g_top = na
var float g_bot = na
var float g_id  = na
var float g_t1  = na

if (g_impUp or g_impDn) and bar_index > maxBase + 1
    int nBase = 0
    for k = 1 to maxBase
        if high[k] - low[k] <= g_range * baseRatio
            nBase += 1
        else
            break
    if nBase >= minBase
        float bTop = na
        float bBot = na
        for k = 1 to nBase
            bTop := na(bTop) ? high[k] : math.max(bTop, high[k])
            bBot := na(bBot) ? low[k]  : math.min(bBot, low[k])
        float h = bTop - bBot
        if h > 0 and h >= g_atr * minHeightAtr and h <= g_atr * maxHeightAtr
            float mid  = (bTop + bBot) / 2
            float half = h / 2 * zoneMult
            g_top := mid + half
            g_bot := mid - half
            g_sig := g_impUp ? 1.0 : -1.0
            g_id  := time
            g_t1  := time[nBase]

// ═════════════════════════════════════════════════════════════════════════════
//  MTF REQUESTS — 6 calls × 5-tuple = 30/127 budget. expr[1] + lookahead_on =
//  confirmed-bar values only (reads PAST data — the standard non-repaint form).
// ═════════════════════════════════════════════════════════════════════════════
[sg1, tp1, bt1, id1, st1] = request.security(syminfo.tickerid, tfS1,
  [g_sig[1], g_top[1], g_bot[1], g_id[1], g_t1[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sg2, tp2, bt2, id2, st2] = request.security(syminfo.tickerid, tfS2,
  [g_sig[1], g_top[1], g_bot[1], g_id[1], g_t1[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sg3, tp3, bt3, id3, st3] = request.security(syminfo.tickerid, tfS3,
  [g_sig[1], g_top[1], g_bot[1], g_id[1], g_t1[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sg4, tp4, bt4, id4, st4] = request.security(syminfo.tickerid, tfS4,
  [g_sig[1], g_top[1], g_bot[1], g_id[1], g_t1[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sg5, tp5, bt5, id5, st5] = request.security(syminfo.tickerid, tfS5,
  [g_sig[1], g_top[1], g_bot[1], g_id[1], g_t1[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sg6, tp6, bt6, id6, st6] = request.security(syminfo.tickerid, tfS6,
  [g_sig[1], g_top[1], g_bot[1], g_id[1], g_t1[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// ═════════════════════════════════════════════════════════════════════════════
//  CHART-SIDE STATE & HELPERS
// ═════════════════════════════════════════════════════════════════════════════
type Zone
    box    bx
    line   mid
    int    dir       // 1 = demand · -1 = supply
    float  top
    float  bot
    int    slot
    string tf        // display tag, e.g. '4H'
    bool   broken
    bool   wasOut    // price fully outside since creation / last retest → armed
    array<label> lbls // retest markers belonging to this zone, deleted with it
    label  tagLbl    // trailing timeframe tag, kept at the live right edge

// deletes a zone's drawings (box, mid-line, tag label, all its retest labels)
f_wipeZone(Zone z) =>
    box.delete(z.bx)
    if not na(z.mid)
        line.delete(z.mid)
    if not na(z.tagLbl)
        label.delete(z.tagLbl)
    if array.size(z.lbls) > 0
        for j = 0 to array.size(z.lbls) - 1
            label.delete(array.get(z.lbls, j))

var array<Zone>  zones   = array.new<Zone>()
var array<float> lastIds = array.new<float>(6, na)

// per-bar event flags (index 0 = new zone, 1 = retest, 2 = break) — an array so
// f_ingest() can set them (functions cannot reassign global primitives)
evts = array.new<bool>(3, false)

chartSec = timeframe.in_seconds(timeframe.period)

// '15' → '15m', '240' → '4H', 'D' stays 'D'
f_tfName(simple string tf) =>
    float mins = str.tonumber(tf)
    na(mins) ? tf : mins >= 60 and mins % 60 == 0 ? str.tostring(mins / 60, '#') + 'H' : str.tostring(mins, '#') + 'm'

f_px(float p) =>
    na(p) ? '?' : math.abs(p) >= 1000 ? str.tostring(p, '#,###.##') : math.abs(p) >= 10 ? str.tostring(p, '#.####') : str.tostring(p, '#.#####')

// overlap fraction of two price ranges, relative to the smaller zone
f_overlap(float t1, float b1, float t2, float b2) =>
    inter = math.min(t1, t2) - math.max(b1, b2)
    hMin  = math.min(t1 - b1, t2 - b2)
    (hMin > 0 and inter > 0) ? inter / hMin : 0.0

// ingest one timeframe slot: dedupe by impulse-bar id, overlap filter, create
// the drawing, enforce the per-slot cap. Called unconditionally every bar.
f_ingest(int slot, simple bool en, simple string tfStr, float sg, float tp, float bt, float idv, float stv) =>
    if en and not na(sg) and sg != 0 and not na(tp) and not na(bt) and not na(idv) and not na(stv)
        string tfEff = tfStr == '' ? timeframe.period : tfStr
        if timeframe.in_seconds(tfEff) >= chartSec
            float lastId = array.get(lastIds, slot)
            if na(lastId) or lastId != idv
                array.set(lastIds, slot, idv)
                int dir = sg > 0 ? 1 : -1
                string tag = f_tfName(tfEff)
                int dupIdx = -1
                if mergeOn and array.size(zones) > 0
                    for i = 0 to array.size(zones) - 1
                        Zone z = array.get(zones, i)
                        if not z.broken and z.dir == dir
                            if f_overlap(tp, bt, z.top, z.bot) > mergeTh
                                dupIdx := i
                                break
                if dupIdx >= 0
                    // same level from another timeframe — merge the tag into the
                    // existing zone instead of silently dropping the new one
                    Zone dz = array.get(zones, dupIdx)
                    if not str.contains(dz.tf, tag)
                        dz.tf := dz.tf + ', ' + tag
                        // tagLbl text refreshes automatically next bar via the
                        // per-bar trailing-label update in the lifecycle loop
                    int _ = na  // matches the else branch's implicit return type
                else
                    color  baseC = dir == 1 ? demC : supC
                    box bx = box.new(int(stv), tp, time, bt,
                      xloc         = xloc.bar_time,
                      extend       = extend.none,
                      bgcolor      = baseC,
                      border_color = color.new(baseC, 45),
                      border_width = 1)
                    line md = na
                    if showMid
                        md := line.new(int(stv), (tp + bt) / 2, time, (tp + bt) / 2,
                          xloc   = xloc.bar_time,
                          extend = extend.none,
                          color  = color.new(baseC, 45),
                          style  = line.style_dotted)
                    // trailing tag label — kept at the live right edge (see the
                    // per-bar update loop below), showing every merged TF's name
                    label tagLbl = na
                    if showTfTag
                        tagLbl := label.new(bar_index, (tp + bt) / 2, tag,
                          style     = label.style_label_left,
                          color     = color.new(baseC, 100),
                          textcolor = color.new(baseC, 15),
                          size      = size.small)
                    bool wOut = dir == 1 ? low > tp : high < bt
                    array.push(zones, Zone.new(bx, md, dir, tp, bt, slot, tag, false, wOut, array.new<label>(), tagLbl))
                    array.set(evts, 0, true)
                    if alNew and barstate.isconfirmed
                        alert('MTF S&D · ' + syminfo.ticker + ' — new ' + (dir == 1 ? 'Demand' : 'Supply') + ' zone [' + tag + '] ' + f_px(bt) + ' - ' + f_px(tp), alert.freq_once_per_bar)
                    // per-slot cap — drop the oldest ACTIVE zone of this slot
                    int cnt = 0
                    for i = 0 to array.size(zones) - 1
                        Zone z = array.get(zones, i)
                        if z.slot == slot and not z.broken
                            cnt += 1
                    if cnt > maxPerTf
                        for i = 0 to array.size(zones) - 1
                            Zone z = array.get(zones, i)
                            if z.slot == slot and not z.broken
                                f_wipeZone(z)
                                array.remove(zones, i)
                                break
                    int _ = na  // matches the dupIdx>=0 branch's implicit return type

f_ingest(0, tfE1, tfS1, sg1, tp1, bt1, id1, st1)
f_ingest(1, tfE2, tfS2, sg2, tp2, bt2, id2, st2)
f_ingest(2, tfE3, tfS3, sg3, tp3, bt3, id3, st3)
f_ingest(3, tfE4, tfS4, sg4, tp4, bt4, id4, st4)
f_ingest(4, tfE5, tfS5, sg5, tp5, bt5, id5, st5)
f_ingest(5, tfE6, tfS6, sg6, tp6, bt6, id6, st6)

// ═════════════════════════════════════════════════════════════════════════════
//  LIFECYCLE — chart-side, tick-accurate: invalidation first, then re-arm /
//  retest. Runs over every zone on every bar.
// ═════════════════════════════════════════════════════════════════════════════
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        if not z.broken
            bool  isDem  = z.dir == 1
            color baseC  = isDem ? demC : supC
            // trail the box, mid-line and tag to the live right edge, updated
            // every bar the zone stays alive — freezes in place the bar it breaks
            box.set_right(z.bx, time)
            if not na(z.mid)
                line.set_x2(z.mid, time)
            if not na(z.tagLbl)
                label.set_x(z.tagLbl, bar_index)
                label.set_y(z.tagLbl, (z.top + z.bot) / 2)
                label.set_text(z.tagLbl, z.tf)
            float brkSrc = invMode == 'Close' ? close : (isDem ? low : high)
            bool  broke  = isDem ? brkSrc < z.bot : brkSrc > z.top
            if broke
                z.broken := true
                array.set(evts, 2, true)
                if alBr and barstate.isconfirmed
                    alert('MTF S&D · ' + syminfo.ticker + ' — ' + (isDem ? 'Demand' : 'Supply') + ' zone [' + z.tf + '] BROKEN at ' + f_px(close), alert.freq_once_per_bar)
                if showBroken
                    box.set_bgcolor(z.bx, color.new(baseC, 94))
                    box.set_border_style(z.bx, line.style_dashed)
                    box.set_border_color(z.bx, color.new(baseC, 80))
                    if not na(z.tagLbl)
                        label.set_textcolor(z.tagLbl, color.new(baseC, 70))
                    if not na(z.mid)
                        line.set_color(z.mid, color.new(baseC, 85))
                else
                    f_wipeZone(z)
                    array.remove(zones, i)
            else
                if isDem
                    if low > z.top
                        z.wasOut := true
                    else if z.wasOut
                        float rtSrc = retestMode == 'Close' ? close : low
                        if rtSrc <= z.top
                            z.wasOut := false
                            array.set(evts, 1, true)
                            if showRetestLbl
                                array.push(z.lbls, label.new(bar_index, low, 'R', style=label.style_label_up, color=color.new(demC, 20), textcolor=color.white, size=size.tiny))
                            if alRt and barstate.isconfirmed
                                alert('MTF S&D · ' + syminfo.ticker + ' — Demand zone [' + z.tf + '] retest at ' + f_px(close), alert.freq_once_per_bar)
                else
                    if high < z.bot
                        z.wasOut := true
                    else if z.wasOut
                        float rtSrc = retestMode == 'Close' ? close : high
                        if rtSrc >= z.bot
                            z.wasOut := false
                            array.set(evts, 1, true)
                            if showRetestLbl
                                array.push(z.lbls, label.new(bar_index, high, 'R', style=label.style_label_down, color=color.new(supC, 20), textcolor=color.white, size=size.tiny))
                            if alRt and barstate.isconfirmed
                                alert('MTF S&D · ' + syminfo.ticker + ' — Supply zone [' + z.tf + '] retest at ' + f_px(close), alert.freq_once_per_bar)

// broken-zone housekeeping — keep at most the 40 most recent broken zones
if showBroken and array.size(zones) > 0
    int bCnt = 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        if z.broken
            bCnt += 1
    while bCnt > 40
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if z.broken
                f_wipeZone(z)
                array.remove(zones, i)
                break
        bCnt -= 1

// ═════════════════════════════════════════════════════════════════════════════
//  DISPLAY RANGE — visual filter only (zones keep tracking while hidden);
//  runs on the last bar only, restores full style when price comes back.
// ═════════════════════════════════════════════════════════════════════════════
if barstate.islast and distAtr > 0 and array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        color baseC = z.dir == 1 ? demC : supC
        bool  vis   = math.abs((z.top + z.bot) / 2 - close) <= g_atr * distAtr
        if not vis
            box.set_bgcolor(z.bx, color.new(baseC, 100))
            box.set_border_color(z.bx, color.new(baseC, 100))
            if not na(z.tagLbl)
                label.set_textcolor(z.tagLbl, color.new(baseC, 100))
            if not na(z.mid)
                line.set_color(z.mid, color.new(baseC, 100))
        else if z.broken
            box.set_bgcolor(z.bx, color.new(baseC, 94))
            box.set_border_color(z.bx, color.new(baseC, 80))
            if not na(z.tagLbl)
                label.set_textcolor(z.tagLbl, color.new(baseC, 70))
            if not na(z.mid)
                line.set_color(z.mid, color.new(baseC, 85))
        else
            box.set_bgcolor(z.bx, baseC)
            box.set_border_color(z.bx, color.new(baseC, 45))
            if not na(z.tagLbl)
                label.set_textcolor(z.tagLbl, color.new(baseC, 15))
            if not na(z.mid)
                line.set_color(z.mid, color.new(baseC, 45))

// ═════════════════════════════════════════════════════════════════════════════
//  NAMED ALERT CONDITIONS (generic; detailed messages come from alert() calls)
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(array.get(evts, 0), 'New S&D Zone',  'MTF S&D Zones: a new supply/demand zone confirmed')
alertcondition(array.get(evts, 1), 'Zone Retest',   'MTF S&D Zones: price retested an active zone')
alertcondition(array.get(evts, 2), 'Zone Break',    'MTF S&D Zones: an active zone was invalidated')
````
