<!-- tradingview-pine-id: PUB;c9369578e78d48699999a71923d63778 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Tide [JOAT]

Source: https://www.tradingview.com/script/hGGxsbCv-Volume-Tide-JOAT/

## Description

Reads participation like an ocean tide — from drained to institutional surge — and carves volume-weighted zones during the bursts.

◆ WHAT IT IS

Volume Tide reframes volume as a tide: it measures how strongly current participation is running against its own long-term baseline and classifies the market into four intuitive states. It is a pure market-context tool — it maps where real activity is entering the market and builds structure from it. It does not print buy/sell signals.

This is 100% original code, written from scratch. It is not a repackaged volume oscillator.

◆ HOW IT WORKS

1. The tide ratio. A short-term volume average is divided by a long-term baseline. This ratio — incoming wave versus sea level — tells you whether participation is expanding or draining, independent of the raw volume scale of the symbol.

2. Four tide states. The ratio is banded into:
 • EBB — participation drained out
 • RISING — filling back up
 • FLOOD — active participation
 • SURGE — institutional-scale bursts
All four are painted as a seamless aquatic gradient in the lower pane.

3. Tide pools. When a SURGE begins, the tool carves a tide pool onto the price chart across the traded range. As price continues to trade inside that pool, it accumulates volume by price overlap and computes:
 • a volume-weighted anchor line (a natural magnet level), and
 • a live buy/sell pressure split with a total-volume readout.

◆ WHAT YOU SEE

 • A gradient tide histogram with Ebb / Flood / Surge threshold guides
 • Tide pools on the price chart during surges, each with a volume-weighted anchor and live buy/sell delta stats
 • A resizable dashboard showing the tide state and direction (coming in / going out), the tide ratio with a wave meter, fast-versus-baseline volume, live pool count, the newest pool's volume and delta, and surge history

◆ HOW TO USE IT

 • Use the tide state as a conviction filter: breakouts and trends that develop during FLOOD or SURGE have real participation behind them, while moves during EBB are thin and prone to reversal.
 • The volume-weighted anchor inside a tide pool often acts as support/resistance when price returns to it.
 • The buy/sell delta inside a pool shows which side did the heavy lifting during the surge.
 • Works on all symbols and timeframes that provide volume.

◆ NOTES & LIMITATIONS

Volume Tide requires a genuine volume feed — on symbols without one the tide ratio is not meaningful. It describes participation conditions and structure; it is not financial advice and does not predict direction on its own. Use it alongside a directional method and your own risk management.

— made with passion by officialjackofalltrade

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator('Volume Tide [JOAT]', shorttitle='TIDE [JOAT]', overlay = false,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════ INPUTS ═══════════════════════════════════

// ── Tide Engine ──
shortLen = input.int(5, 'Fast Tide Period', minval = 1, group = 'Tide Engine',
     tooltip = 'Short volume average — the incoming wave.')
longLen = input.int(100, 'Baseline Period', minval = 2, group = 'Tide Engine',
     tooltip = 'Long volume baseline — sea level. The tide ratio is fast ÷ baseline.')
ebbLevel = input.float(0.7, 'Ebb Threshold', minval = 0.1, step = 0.05, group = 'Tide Engine',
     tooltip = 'Below this ratio the market is in EBB — participation drained out.')
floodLevel = input.float(1.2, 'Flood Threshold', minval = 0.5, step = 0.05, group = 'Tide Engine',
     tooltip = 'Above this ratio the market is in FLOOD — active participation.')
surgeLevel = input.float(1.8, 'Surge Threshold', minval = 1.0, step = 0.05, group = 'Tide Engine',
     tooltip = 'Above this ratio the market is in SURGE — institutional bursts. Surge bars carve tide pools onto the chart.')

// ── Tide Pools (chart zones) ──
showPools = input.bool(true, 'Carve Tide Pools On Chart', group = 'Tide Pools',
     tooltip = 'During SURGE, a zone is built across the traded range and pinned to the price chart.')
poolMaxAge = input.int(300, 'Pool Lifetime (bars)', minval = 20, maxval = 500, group = 'Tide Pools')
maxPools = input.int(6, 'Max Pools On Chart', minval = 1, maxval = 25, group = 'Tide Pools')
showPoolStats = input.bool(true, 'Show Pool Volume Stats', group = 'Tide Pools',
     tooltip = 'Prints total volume and buy/sell delta beside each pool.')
showAnchorLine = input.bool(true, 'Show Volume-Weighted Anchor Line', group = 'Tide Pools',
     tooltip = 'Horizontal line at the volume-weighted average price of each pool — a natural magnet level.')
poolTransp = input.int(80, 'Pool Transparency', minval = 0, maxval = 100, group = 'Tide Pools')

// ── Ocean Palette ──
abyssColor = input.color(#0b3d4d, 'Abyss (Ebb) Color', group = 'Ocean Palette')
deepColor = input.color(#0e7490, 'Deep (Rising) Color', group = 'Ocean Palette')
floodColor = input.color(#06b6d4, 'Flood Color', group = 'Ocean Palette')
foamColor = input.color(#67e8f9, 'Foam (Surge) Color', group = 'Ocean Palette')
poolBullColor = input.color(#2dd4bf, 'Pool Bull Pressure Color', group = 'Ocean Palette')
poolBearColor = input.color(#f43f5e, 'Pool Bear Pressure Color', group = 'Ocean Palette')
showSeaLevel = input.bool(true, 'Show Sea Level Guides', group = 'Ocean Palette')

// ── Tide Dashboard ──
showDash = input.bool(true, 'Show Tide Dashboard', group = 'Tide Dashboard')
dashPos = input.string('Bottom Right', 'Dashboard Position',
     options = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Top Center', 'Bottom Center', 'Middle Left', 'Middle Right'],
     group = 'Tide Dashboard')
dashSize = input.string('Normal', 'Dashboard Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Tide Dashboard')
dashOnChart = input.bool(false, 'Pin Dashboard To Price Chart', group = 'Tide Dashboard')

// ══════════════════════════════ TIDE ENGINE ═════════════════════════════════

float volFast = ta.sma(volume, shortLen)
float volBase = ta.sma(volume, longLen)
float tide = volBase > 0 ? volFast / volBase : 1.0

// Tide state: 0 = Ebb, 1 = Rising, 2 = Flood, 3 = Surge
int tideState = tide < ebbLevel ? 0 : tide < floodLevel ? 1 : tide < surgeLevel ? 2 : 3

// ─── Ocean gradient column color ───
f_blend(color c1, color c2, float frac) =>
    float f = math.max(0.0, math.min(1.0, frac))
    color.rgb(
         math.round(color.r(c1) + (color.r(c2) - color.r(c1)) * f),
         math.round(color.g(c1) + (color.g(c2) - color.g(c1)) * f),
         math.round(color.b(c1) + (color.b(c2) - color.b(c1)) * f))

color tideColor = tideState == 0 ? f_blend(abyssColor, deepColor, tide / math.max(ebbLevel, 0.01)) :
     tideState == 1 ? f_blend(deepColor, floodColor, (tide - ebbLevel) / math.max(floodLevel - ebbLevel, 0.01)) :
     tideState == 2 ? f_blend(floodColor, foamColor, (tide - floodLevel) / math.max(surgeLevel - floodLevel, 0.01)) :
     f_blend(foamColor, color.white, math.min((tide - surgeLevel) / math.max(surgeLevel, 0.01), 1.0))

// ─── Pane plots ───
plot(tide, 'Tide Ratio', color = tideColor, style = plot.style_columns)
plot(tide, 'Tide Crest', color = color.new(color.white, 78), linewidth = 1)

hEbb = hline(ebbLevel, 'Ebb Level', color = color.new(#0e7490, 55), linestyle = hline.style_dotted)
hFlood = hline(floodLevel, 'Flood Level', color = color.new(#06b6d4, 50), linestyle = hline.style_dotted)
hSurge = hline(surgeLevel, 'Surge Level', color = color.new(#67e8f9, 45), linestyle = hline.style_dotted)
hZero = hline(0, '', color = color.new(color.gray, 100))
fill(hZero, hEbb, color = showSeaLevel ? color.new(abyssColor, 88) : na, title = 'Ebb Basin')
fill(hSurge, hline(math.max(surgeLevel * 2, 4), '', color = color.new(color.gray, 100)), color = showSeaLevel ? color.new(foamColor, 92) : na, title = 'Surge Sky')

// ═══════════════════════════ TIDE POOL ENGINE ═══════════════════════════════

type TidePool
    box bx
    line anchor
    label stats
    float top
    float bottom
    float sumPV
    float sumV
    float bullV
    float bearV
    int born
    bool building

var array<TidePool> pools = array.new<TidePool>()

bool surgeNow = tideState == 3
bool surgeStart = surgeNow and not surgeNow[1]
var int surgeCount = 0
var int lastSurgeBar = na
if surgeStart
    surgeCount += 1
    lastSurgeBar := bar_index

f_fmtVol(float v) =>
    v >= 1e9 ? str.tostring(v / 1e9, '#.##') + 'B' :
         v >= 1e6 ? str.tostring(v / 1e6, '#.##') + 'M' :
         v >= 1e3 ? str.tostring(v / 1e3, '#.##') + 'K' : str.tostring(math.round(v))

// Start a new pool on surge onset
if showPools and surgeStart
    box b = box.new(bar_index, high, bar_index + 1, low,
         border_color = color.new(foamColor, 45), border_width = 1,
         bgcolor = color.new(floodColor, poolTransp), force_overlay = true)
    line a = na
    if showAnchorLine
        a := line.new(bar_index, hl2, bar_index + 1, hl2, color = color.new(#94a3b8, 30), width = 2, force_overlay = true)
    label st = na
    if showPoolStats
        st := label.new(bar_index + 2, hl2, '', style = label.style_label_left,
             color = color.new(color.white, 100), textcolor = color.new(#67e8f9, 12), size = size.small, force_overlay = true)
    array.push(pools, TidePool.new(b, a, st, high, low, 0.0, 0.0, 0.0, 0.0, bar_index, true))
    if array.size(pools) > maxPools
        TidePool old = array.shift(pools)
        box.delete(old.bx)
        line.delete(old.anchor)
        label.delete(old.stats)

// Update pools
if array.size(pools) > 0
    for i = array.size(pools) - 1 to 0
        TidePool p = array.get(pools, i)
        // expire old pools
        if bar_index - p.born > poolMaxAge
            box.delete(p.bx)
            line.delete(p.anchor)
            label.delete(p.stats)
            array.remove(pools, i)
            continue
        // grow while surge continues (only most recent pool can be building)
        if p.building
            if surgeNow
                p.top := math.max(p.top, high)
                p.bottom := math.min(p.bottom, low)
            else
                p.building := false
        // accumulate volume while price trades inside the pool
        float rng = math.max(high - low, syminfo.mintick)
        if high > p.bottom and low < p.top
            float overlapHi = math.min(high, p.top)
            float overlapLo = math.max(low, p.bottom)
            float frac = math.max(overlapHi - overlapLo, 0.0) / rng
            float addV = volume * frac
            float bullPart = (close - low) / rng
            p.sumPV := p.sumPV + addV * (overlapHi + overlapLo) / 2
            p.sumV := p.sumV + addV
            p.bullV := p.bullV + addV * bullPart
            p.bearV := p.bearV + addV * (1 - bullPart)
        // redraw geometry
        box.set_top(p.bx, p.top)
        box.set_bottom(p.bx, p.bottom)
        box.set_right(p.bx, bar_index + 1)
        float anchorPrice = p.sumV > 0 ? p.sumPV / p.sumV : (p.top + p.bottom) / 2
        anchorPrice := math.min(math.max(anchorPrice, p.bottom), p.top)
        if not na(p.anchor)
            line.set_xy1(p.anchor, p.born, anchorPrice)
            line.set_xy2(p.anchor, bar_index + 1, anchorPrice)
        if not na(p.stats)
            float deltaV = p.bullV - p.bearV
            float deltaPct = p.sumV > 0 ? deltaV / p.sumV * 100 : 0.0
            string txt = 'Vol ' + f_fmtVol(p.sumV) + '  Δ ' + (deltaPct >= 0 ? '+' : '') + str.tostring(deltaPct, '#.#') + '%'
            label.set_xy(p.stats, bar_index + 2, anchorPrice)
            label.set_text(p.stats, txt)
            label.set_textcolor(p.stats, deltaPct >= 0 ? poolBullColor : poolBearColor)

// ═══════════════════════════ TIDE DASHBOARD ═════════════════════════════════

finalDashPos =
     dashPos == 'Top Left' ? position.top_left :
     dashPos == 'Top Right' ? position.top_right :
     dashPos == 'Bottom Left' ? position.bottom_left :
     dashPos == 'Bottom Right' ? position.bottom_right :
     dashPos == 'Top Center' ? position.top_center :
     dashPos == 'Bottom Center' ? position.bottom_center :
     dashPos == 'Middle Left' ? position.middle_left :
     dashPos == 'Middle Right' ? position.middle_right : position.bottom_right
finalDashSize =
     dashSize == 'Tiny' ? size.tiny :
     dashSize == 'Small' ? size.small :
     dashSize == 'Large' ? size.large : size.normal

// tide meter: 10-segment wave gauge
f_tideMeter(float t) =>
    int seg = math.round(math.min(t / 2.5, 1.0) * 10)
    string m = ''
    for i = 1 to 10
        m += i <= seg ? '≈' : '·'
    m

var table dash = na
if barstate.islast and showDash
    if not na(dash)
        table.delete(dash)
        dash := na
    if dashOnChart
        dash := table.new(finalDashPos, columns = 3, rows = 10, bgcolor = color.new(#062028, 8),
             border_width = 1, border_color = color.new(#000000, 100),
             frame_width = 2, frame_color = color.new(floodColor, 35), force_overlay = true)
    else
        dash := table.new(finalDashPos, columns = 3, rows = 10, bgcolor = color.new(#062028, 8),
             border_width = 1, border_color = color.new(#000000, 100),
             frame_width = 2, frame_color = color.new(floodColor, 35))

    color rowBg = color.new(#07262f, 22)
    color rowBgAlt = color.new(#052029, 22)
    color lblCol = color.new(color.white, 18)

    string stateTxt = tideState == 0 ? 'EBB — drained' :
         tideState == 1 ? 'RISING — filling' :
         tideState == 2 ? 'FLOOD — active' : 'SURGE — institutional'
    color stateCol = tideState == 0 ? color.new(#5eead4, 55) :
         tideState == 1 ? deepColor :
         tideState == 2 ? floodColor : foamColor

    float tideSlope = tide - tide[10]
    string tideDir = tideSlope > 0.05 ? 'coming in ↑' : tideSlope < -0.05 ? 'going out ↓' : 'slack —'

    // ── Title band (abyss → foam ocean gradient) ──
    table.cell(dash, 0, 0, '〜 VOLUME TIDE', text_color = color.white, bgcolor = color.new(abyssColor, 15), text_size = finalDashSize)
    table.cell(dash, 1, 0, '', bgcolor = color.new(floodColor, 30), text_size = finalDashSize)
    table.cell(dash, 2, 0, syminfo.ticker + ' · ' + timeframe.period, text_color = color.rgb(4, 28, 36), bgcolor = color.new(foamColor, 20), text_size = finalDashSize)
    // ── Gradient accent strip ──
    table.cell(dash, 0, 1, '', bgcolor = color.new(deepColor, 55), text_size = size.tiny)
    table.cell(dash, 1, 1, '', bgcolor = color.new(floodColor, 45), text_size = size.tiny)
    table.cell(dash, 2, 1, '', bgcolor = color.new(foamColor, 35), text_size = size.tiny)
    // ── Tide state ──
    table.cell(dash, 0, 2, 'Tide State', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 2, stateTxt, text_color = tideState == 3 ? color.rgb(4, 28, 36) : color.white, bgcolor = color.new(stateCol, tideState == 3 ? 20 : 55), text_size = finalDashSize)
    table.cell(dash, 2, 2, tideDir, text_color = color.new(color.white, 30), bgcolor = rowBg, text_size = finalDashSize)
    // ── Tide ratio + wave meter ──
    table.cell(dash, 0, 3, 'Tide Ratio', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 3, str.tostring(tide, '0.00') + 'x', text_color = tideColor, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 3, f_tideMeter(tide), text_color = tideColor, bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Fast vs baseline volume ──
    table.cell(dash, 0, 4, 'Fast Volume', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 4, f_fmtVol(volFast), text_color = color.new(foamColor, 15), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 4, 'base ' + f_fmtVol(volBase), text_color = color.new(color.white, 40), bgcolor = rowBg, text_size = finalDashSize)
    // ── Live pools ──
    table.cell(dash, 0, 5, 'Live Pools', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 5, str.tostring(array.size(pools)) + ' / ' + str.tostring(maxPools), text_color = color.new(foamColor, 15), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 5, showPools ? 'carving on' : 'carving off', text_color = color.new(color.white, 45), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Newest pool stats ──
    string poolVolTxt = '—'
    string poolDeltaTxt = ''
    color poolDeltaCol = color.new(color.white, 40)
    if array.size(pools) > 0
        TidePool newest = array.get(pools, array.size(pools) - 1)
        float dV = newest.bullV - newest.bearV
        float dPct = newest.sumV > 0 ? dV / newest.sumV * 100 : 0.0
        poolVolTxt := f_fmtVol(newest.sumV)
        poolDeltaTxt := 'Δ ' + (dPct >= 0 ? '+' : '') + str.tostring(dPct, '#.#') + '%'
        poolDeltaCol := dPct >= 0 ? poolBullColor : poolBearColor
    table.cell(dash, 0, 6, 'Newest Pool', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 6, poolVolTxt, text_color = color.new(color.white, 15), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 6, poolDeltaTxt, text_color = poolDeltaCol, bgcolor = rowBg, text_size = finalDashSize)
    // ── Surge history ──
    string lastSurgeTxt = na(lastSurgeBar) ? '—' : str.tostring(bar_index - lastSurgeBar) + ' bars ago'
    table.cell(dash, 0, 7, 'Surges Seen', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 7, str.tostring(surgeCount), text_color = foamColor, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 7, 'last ' + lastSurgeTxt, text_color = color.new(color.white, 35), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Thresholds ──
    string thresholds = str.tostring(ebbLevel, '0.0#') + ' / ' + str.tostring(floodLevel, '0.0#') + ' / ' + str.tostring(surgeLevel, '0.0#')
    table.cell(dash, 0, 8, 'Ebb/Flood/Surge', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 8, thresholds, text_color = color.new(color.white, 30), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 8, '', bgcolor = rowBg, text_size = finalDashSize)
    // ── Periods ──
    table.cell(dash, 0, 9, 'Fast / Baseline', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 9, str.tostring(shortLen) + ' / ' + str.tostring(longLen) + ' bars', text_color = color.new(color.white, 30), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 9, '', bgcolor = rowBgAlt, text_size = finalDashSize)

// ════════════════════════════════ ALERTS ════════════════════════════════════

alertcondition(tideState == 3 and tideState[1] != 3, title = 'Tide Surge Began', message = '[JOAT] Volume Tide — SURGE participation on {{ticker}} ({{interval}})')
alertcondition(tideState != 3 and tideState[1] == 3, title = 'Tide Surge Ended', message = '[JOAT] Volume Tide — surge ended on {{ticker}} ({{interval}})')
alertcondition(tideState == 0 and tideState[1] != 0, title = 'Tide Ebb Began', message = '[JOAT] Volume Tide — participation drained to EBB on {{ticker}} ({{interval}})')
alertcondition(ta.crossover(tide, floodLevel), title = 'Tide Crossed Into Flood', message = '[JOAT] Volume Tide — tide crossed into FLOOD on {{ticker}} ({{interval}})')
````
