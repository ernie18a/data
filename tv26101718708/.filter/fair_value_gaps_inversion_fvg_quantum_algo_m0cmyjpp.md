# Fair Value Gaps + Inversion FVG [Quantum Algo]

- url: https://www.tradingview.com/script/m0cMyJpp-Fair-Value-Gaps-Inversion-FVG-Quantum-Algo/
- type: indicator
- pine_id: PUB;5cee2a293f764382bd4d55e0d05d37da
- version: 3.0

## Description

Fair Value Gaps + Inversion FVG [Quantum Algo]

█ OVERVIEW

Most FVG indicators stop at drawing boxes. This one tracks the complete lifecycle of every gap — fresh → midline-tested → filled → INVERTED → retested — and automates the part of the model that traders actually trade: the Inversion Fair Value Gap (IFVG).

A Fair Value Gap is a 3-candle imbalance left behind when price moves too fast for two-sided trade to occur. Price frequently returns to these zones. But when price closes through a gap instead of respecting it, the zone does not die — it flips polarity. A violated bullish gap becomes resistance; a violated bearish gap becomes support. The first retest of that inverted zone is one of the cleanest entry models in the Smart Money Concepts framework, and this script detects, restyles, and signals it automatically.

█ FEATURES

Gap detection
— Bullish and bearish FVGs detected on confirmed bars only (non-repainting).
— ATR minimum-size filter removes insignificant micro-gaps.
— Optional displacement filter: the middle candle must be a genuine expansion bar (range greater than a configurable multiple of ATR), keeping only gaps created by aggressive participation.

Volume strength score
Every gap is stamped with a 0–100 score comparing the displacement candle's volume against its 20-bar average. A 90% gap and a 20% gap are not the same zone — now you can see the difference at a glance.

Consequent Encroachment (CE)
Each gap carries its 50% midline. The first touch of the CE is detected, the gap is visually dimmed to separate tested zones from fresh ones, and an alert is available.

Inversion engine (IFVG)
— A close through the gap converts it into an inverted zone with distinct styling.
— The first retest of an inverted zone prints an on-chart signal (long model for inverted bearish gaps, short model for inverted bullish gaps).
— A close back through the far side invalidates and removes the zone.
— Inversion can be disabled, in which case gaps simply fill and are removed or frozen (wick-fill or close-fill modes).

Multi-timeframe mode
Display gaps from one higher timeframe directly on your chart as dashed boxes. HTF gaps are built exclusively from closed higher-timeframe bars, so they do not repaint.

Dashboard
A compact panel shows active bullish gaps, bearish gaps, inverted zones, plus the nearest demand level below price and the nearest supply level above it.

Alerts
Eight alert conditions cover the full lifecycle: new bullish/bearish gap, CE touch, fill, bullish/bearish inversion, and long/short IFVG retest.

█ HOW DETECTION WORKS

A bullish FVG forms when the current bar's low sits entirely above the high from two bars earlier — the zone spans that void. A bearish FVG is the mirror image. Detection runs only on bar close, so a gap that appears never disappears or redraws. Lifecycle state changes (CE touches, fills, inversions, retests) are likewise evaluated on confirmed bars.

█ HOW TO USE IT

1. Classic continuation: in a trend, wait for price to retrace into a fresh high-strength gap aligned with the trend; the CE midline is the standard entry refinement.
2. Inversion reversal: when a gap is closed through, stop looking for the old reaction — wait for the retest of the inverted zone in the new direction. The on-chart IFVG markers identify exactly this moment.
3. Multi-timeframe confluence: enable HTF mode and prioritize chart-timeframe signals that occur inside a higher-timeframe gap.
4. Use the dashboard's nearest demand/supply readout for quick situational awareness of where the next reaction zones sit.

Works on all symbols and timeframes. Crypto and index futures tend to produce the cleanest gaps on 5m–1H; forex gaps are more frequent on 15m and above.

█ SETTINGS

Detection — minimum gap size (× ATR), displacement filter, maximum zones kept on chart.
Mitigation & Inversion — inversion on/off, fill source (close or wick), removal of filled gaps, retest signals.
Multi-Timeframe — HTF on/off and timeframe selection.
Visuals — colors for bullish / bearish / inverted zones, fill transparency, CE line, labels, dimming of tested gaps, dashboard.

█ NOTES

— All state changes occur on closed bars; the developing bar can always change until it closes.
— This is an analysis tool for mapping imbalance and inversion zones, intended as a confluence layer within a complete trading plan. It is not a standalone buy/sell system.

█ DISCLAIMER

This script is provided for educational and informational purposes only and does not constitute financial advice. Trading involves substantial risk of loss. Past behavior does not guarantee future results. Always do your own research and apply sound risk management.

## Source Code

````pine
// Fair Value Gaps + Inversion FVG
//
// Original implementation, zero library dependencies.
//
// ── What it does ──────────────────────────────────────────────────────────────
// Detects Fair Value Gaps (3-candle imbalances), tracks their full lifecycle —
// fresh → CE-tested → filled → INVERTED — and trades the part most scripts
// ignore: the Inversion FVG (IFVG). When price closes through a gap, the zone
// flips polarity (old bullish gap becomes resistance, old bearish gap becomes
// support). The first retest of an inverted gap is one of the cleanest ICT
// entry models, and this script marks it automatically.
//
// ── Feature set ───────────────────────────────────────────────────────────────
//  • Bullish & bearish FVG detection with ATR minimum-size filter and an
//    optional displacement filter (middle candle must be an expansion bar)
//  • Volume strength score (0–100) printed on every gap — displacement volume
//    vs. its 20-bar average, so you instantly see which gaps carry real flow
//  • Consequent Encroachment (CE) midline per gap, with touch detection
//  • Full mitigation tracking: wick-fill or close-fill modes
//  • Inversion engine: close-through converts the gap to an IFVG, restyles it,
//    and watches for the first retest → prints a signal marker
//  • IFVG invalidation: a close back through the far side removes the zone
//  • Multi-timeframe mode: gaps from one higher timeframe drawn on the chart
//    (non-repainting — built from closed HTF bars only)
//  • Live dashboard: active gap counts, IFVG count, nearest zones.
//  • 8 alert types covering the entire gap lifecycle.

//@version=6
indicator('Fair Value Gaps + Inversion FVG [Quantum Algo]', 'Fair Value Gaps + Inversion FVG [Quantum Algo]', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════
// ── Detection
minSizeAtr   = input.float(0.15, 'Min Gap Size (× ATR)', minval = 0, step = 0.05, group = 'Detection', tooltip = 'Gaps smaller than this many ATRs are ignored. 0 = detect everything.')
useDispl     = input.bool(false, 'Displacement Filter', inline = 'd', group = 'Detection')
displMult    = input.float(1.2, '× ATR', minval = 0.5, step = 0.1, inline = 'd', group = 'Detection', tooltip = 'Require the middle candle range to exceed this many ATRs — keeps only gaps created by genuine displacement.')
maxGaps      = input.int(10, 'Max Gaps On Chart', minval = 5, maxval = 100, group = 'Detection', tooltip = 'Oldest gaps are removed beyond this count.')

// ── Mitigation & Inversion
useInversion = input.bool(false, 'Enable Inversion FVGs (IFVG)', group = 'Mitigation & Inversion', tooltip = 'A close through a gap flips it into an opposite-polarity zone instead of removing it.')
fillMode     = input.string('Close', 'Fill / Mitigation Source', options = ['Close', 'Wick'], group = 'Mitigation & Inversion', tooltip = 'How a gap counts as traded-through. Inversion always requires a CLOSE through the gap (standard ICT definition).')
hideFilled   = input.bool(true, 'Remove Filled Gaps (when inversion off)', group = 'Mitigation & Inversion')
showSignals  = input.bool(true, 'IFVG Retest Signals', group = 'Mitigation & Inversion', tooltip = 'Marks the FIRST retest of an inverted gap — the IFVG entry model.')

// ── Multi-Timeframe
useHtf = input.bool(false, 'Show Higher-Timeframe FVGs', inline = 'h', group = 'Multi-Timeframe')
htfTf  = input.timeframe('240', '', inline = 'h', group = 'Multi-Timeframe', tooltip = 'Gaps from this timeframe drawn as hollow boxes. Built from CLOSED HTF bars only — non-repainting.')

// ── Visuals
bullCol   = input.color(color.new(#089981, 0), 'Bullish', inline = 'c1', group = 'Visuals')
bearCol   = input.color(color.new(#F23645, 0), 'Bearish', inline = 'c1', group = 'Visuals')
ifvgCol   = input.color(color.new(#C77DFF, 0), 'IFVG', inline = 'c1', group = 'Visuals')
fillTransp  = input.int(82, 'Fill Transparency', minval = 50, maxval = 98, group = 'Visuals')
showCE      = input.bool(true, 'Consequent Encroachment (50%) Line', group = 'Visuals')
showText    = input.bool(true, 'Gap Labels (type + strength %)', group = 'Visuals')
dimFilled   = input.bool(true, 'Dim CE-Tested Gaps', group = 'Visuals', tooltip = 'Gaps whose midline has been touched are drawn more transparent — visually separating fresh zones from tested ones.')
showDash    = input.bool(true, 'Dashboard', group = 'Visuals')

// ════════════════════════════════════════
// TYPES & STATE
// ════════════════════════════════════════
type Gap
    box bx
    line ce
    bool isBull       // original gap direction
    bool inverted     // has flipped into an IFVG
    bool ceHit        // CE midline touched while fresh
    bool retested     // IFVG first retest already fired
    bool isHtf
    float top
    float bottom
    float strength
    int invertedBar

var array<Gap> gaps = array.new<Gap>()

// Event flags (reset every bar, set during processing → drive plots & alerts)
bool evNewBull     = false
bool evNewBear     = false
bool evCeTouch     = false
bool evFilled      = false
bool evInvertBull  = false   // bullish gap flipped → now bearish IFVG
bool evInvertBear  = false   // bearish gap flipped → now bullish IFVG
bool evRetestBear  = false   // price retesting a bearish IFVG (short model)
bool evRetestBull  = false   // price retesting a bullish IFVG (long model)

// ════════════════════════════════════════
// SHARED SERIES
// ════════════════════════════════════════
atr     = ta.atr(14)
volBase = ta.sma(volume, 20)
mid(float t, float b) => (t + b) / 2.0

strengthScore(float v, float base) =>
    base > 0 ? math.min(100.0, v / base * 50.0) : 50.0

// ════════════════════════════════════════
// STYLING HELPERS
// ════════════════════════════════════════
gapFill(Gap g) =>
    baseCol = g.inverted ? ifvgCol : g.isBull ? bullCol : bearCol
    t = g.ceHit and dimFilled and not g.inverted ? math.min(96, fillTransp + 10) : fillTransp
    color.new(baseCol, t)

gapBorder(Gap g) =>
    baseCol = g.inverted ? ifvgCol : g.isBull ? bullCol : bearCol
    color.new(baseCol, g.isHtf ? 25 : 55)

gapText(Gap g) =>
    tag = g.inverted ? (g.isBull ? 'IFVG ▼' : 'IFVG ▲') : (g.isBull ? 'FVG ▲' : 'FVG ▼')
    pre = g.isHtf ? htfTf + ' ' : ''
    str_ = showText ? pre + tag + (g.isHtf ? '' : ' · ' + str.tostring(math.round(g.strength)) + '%') : ''
    str_

restyle(Gap g) =>
    box.set_bgcolor(g.bx, gapFill(g))
    box.set_border_color(g.bx, gapBorder(g))
    box.set_text(g.bx, gapText(g))
    box.set_text_color(g.bx, gapBorder(g))
    line.set_color(g.ce, color.new(g.inverted ? ifvgCol : g.isBull ? bullCol : bearCol, 60))

// ════════════════════════════════════════
// GAP CREATION
// ════════════════════════════════════════
newGap(bool isBull, float top, float bottom, float strength, bool isHtf, int leftBar) =>
    bx = box.new(leftBar, top, bar_index, bottom, border_color = color.new(color.white, 100), border_width = 1, border_style = isHtf ? line.style_dashed : line.style_solid, bgcolor = color.new(color.white, 100), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
    ce = line.new(leftBar, mid(top, bottom), bar_index, mid(top, bottom), style = line.style_dotted, width = 1, color = color.new(color.white, 100))
    if not showCE
        line.set_color(ce, color.new(color.white, 100))
    g = Gap.new(bx, ce, isBull, false, false, false, isHtf, top, bottom, strength, -1)
    restyle(g)
    array.push(gaps, g)
    if array.size(gaps) > maxGaps
        old = array.shift(gaps)
        box.delete(old.bx)
        line.delete(old.ce)
    g

removeGap(int idx) =>
    g = array.get(gaps, idx)
    box.delete(g.bx)
    line.delete(g.ce)
    array.remove(gaps, idx)

// ════════════════════════════════════════
// DETECTION — chart timeframe (confirmed bars only → non-repainting)
// ════════════════════════════════════════
gapOkSize(float t, float b) => (t - b) >= minSizeAtr * atr
displOk = not useDispl or (high[1] - low[1]) > displMult * atr

if barstate.isconfirmed
    // Bullish FVG: current low above the high two bars back
    if low > high[2] and gapOkSize(low, high[2]) and displOk
        newGap(true, low, high[2], strengthScore(volume[1], volBase), false, bar_index - 1)
        evNewBull := true
    // Bearish FVG: current high below the low two bars back
    if high < low[2] and gapOkSize(low[2], high) and displOk
        newGap(false, low[2], high, strengthScore(volume[1], volBase), false, bar_index - 1)
        evNewBear := true

// ════════════════════════════════════════
// DETECTION — higher timeframe (closed HTF bars only)
// ════════════════════════════════════════
htfDetect() =>
    bull = low[1] > high[3]
    bear = high[1] < low[3]
    [bull, low[1], high[3], bear, low[3], high[1]]

[hBull, hBullTop, hBullBot, hBear, hBearTop, hBearBot] = request.security(syminfo.tickerid, htfTf, htfDetect(), lookahead = barmerge.lookahead_off)
htfValid = useHtf and timeframe.in_seconds(htfTf) > timeframe.in_seconds()

if htfValid and timeframe.change(htfTf) and barstate.isconfirmed
    if hBull and gapOkSize(hBullTop, hBullBot)
        newGap(true, hBullTop, hBullBot, 50, true, bar_index)
        evNewBull := true
    if hBear and gapOkSize(hBearTop, hBearBot)
        newGap(false, hBearTop, hBearBot, 50, true, bar_index)
        evNewBear := true

// ════════════════════════════════════════
// LIFECYCLE ENGINE
// fresh → CE test → fill → inversion → retest → invalidation
// ════════════════════════════════════════
if barstate.isconfirmed and array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        g = array.get(gaps, i)
        gMid = mid(g.top, g.bottom)
        if not g.inverted
            // ── Active gap ──
            ceTouched = g.isBull ? low <= gMid : high >= gMid
            if ceTouched and not g.ceHit
                g.ceHit := true
                evCeTouch := true
                restyle(g)
            closedThrough = g.isBull ? close < g.bottom : close > g.top
            wickThrough   = g.isBull ? low  <= g.bottom : high >= g.top
            if useInversion
                if closedThrough
                    // ── INVERSION ──
                    g.inverted := true
                    g.invertedBar := bar_index
                    restyle(g)
                    if g.isBull
                        evInvertBull := true
                    else
                        evInvertBear := true
            else
                filled = fillMode == 'Close' ? closedThrough : wickThrough
                if filled
                    evFilled := true
                    if hideFilled
                        removeGap(i)
                    else
                        box.set_bgcolor(g.bx, color.new(color.gray, 94))
                        box.set_border_color(g.bx, color.new(color.gray, 80))
                        line.delete(g.ce)
                        array.remove(gaps, i)   // frozen — drop from active tracking
        else
            // ── Inverted gap (IFVG) ──
            // Old bullish gap → now bearish supply; old bearish gap → now bullish demand
            invalidated = g.isBull ? close > g.top : close < g.bottom
            if invalidated
                removeGap(i)
            else if bar_index > g.invertedBar and not g.retested
                retest = g.isBull ? high >= g.bottom : low <= g.top
                if retest
                    g.retested := true
                    if g.isBull
                        evRetestBear := true   // short model
                    else
                        evRetestBull := true   // long model

// Extend live zones to the current bar
if array.size(gaps) > 0
    for i = 0 to array.size(gaps) - 1
        g = array.get(gaps, i)
        box.set_right(g.bx, bar_index)
        line.set_x2(g.ce, bar_index)

// ════════════════════════════════════════
// SIGNAL MARKERS
// ════════════════════════════════════════
plotshape(showSignals and evRetestBull ? low : na, 'IFVG Long Retest', shape.triangleup, location.belowbar, color = bullCol, size = size.small, text = 'IFVG', textcolor = bullCol)
plotshape(showSignals and evRetestBear ? high : na, 'IFVG Short Retest', shape.triangledown, location.abovebar, color = bearCol, size = size.small, text = 'IFVG', textcolor = bearCol)

// ════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════
if showDash and barstate.islast
    int nBull = 0
    int nBear = 0
    int nIfvg = 0
    float nearestSup = na   // nearest demand below price
    float nearestRes = na   // nearest supply above price
    if array.size(gaps) > 0
        for i = 0 to array.size(gaps) - 1
            g = array.get(gaps, i)
            bullishZone = g.inverted ? not g.isBull : g.isBull
            if g.inverted
                nIfvg += 1
            else if g.isBull
                nBull += 1
            else
                nBear += 1
            if bullishZone and g.top < close
                nearestSup := na(nearestSup) ? g.top : math.max(nearestSup, g.top)
            if not bullishZone and g.bottom > close
                nearestRes := na(nearestRes) ? g.bottom : math.min(nearestRes, g.bottom)
    var tbl = table.new(position.bottom_right, 2, 6, bgcolor = color.new(#0B1020, 15), frame_color = color.new(#00E5FF, 70), frame_width = 1, border_color = color.new(#FFFFFF, 92), border_width = 1)
    txtC = color.new(#E6EDF7, 0)
    table.cell(tbl, 0, 0, 'FVG + IFVG', text_color = color.new(#FFC247, 0), text_size = size.small)
    table.cell(tbl, 1, 0, useHtf ? 'TF + ' + htfTf : timeframe.period, text_color = color.new(#787B86, 0), text_size = size.tiny)
    table.cell(tbl, 0, 1, 'Bullish FVGs', text_color = txtC, text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(nBull), text_color = bullCol, text_size = size.small)
    table.cell(tbl, 0, 2, 'Bearish FVGs', text_color = txtC, text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(nBear), text_color = bearCol, text_size = size.small)
    table.cell(tbl, 0, 3, 'Inverted (IFVG)', text_color = txtC, text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(nIfvg), text_color = ifvgCol, text_size = size.small)
    table.cell(tbl, 0, 4, 'Demand Below', text_color = txtC, text_size = size.small)
    table.cell(tbl, 1, 4, na(nearestSup) ? '—' : str.tostring(nearestSup, format.mintick), text_color = bullCol, text_size = size.small)
    table.cell(tbl, 0, 5, 'Supply Above', text_color = txtC, text_size = size.small)
    table.cell(tbl, 1, 5, na(nearestRes) ? '—' : str.tostring(nearestRes, format.mintick), text_color = bearCol, text_size = size.small)

// ════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════
alertcondition(evNewBull,    'New Bullish FVG',        'New Bullish FVG | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evNewBear,    'New Bearish FVG',        'New Bearish FVG | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evCeTouch,    'CE (50%) Touched',       'FVG midline tested | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evFilled,     'FVG Filled',             'FVG filled | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evInvertBull, 'Bullish FVG Inverted ▼', 'Bullish FVG inverted — now resistance | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evInvertBear, 'Bearish FVG Inverted ▲', 'Bearish FVG inverted — now support | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evRetestBull, 'IFVG Retest — Long ▲',   'IFVG retest (long model) | {{ticker}}@{{close}} | ({{interval}})')
alertcondition(evRetestBear, 'IFVG Retest — Short ▼',  'IFVG retest (short model) | {{ticker}}@{{close}} | ({{interval}})')
````
