# Vestrix.ai Liquidity Atlas

- url: https://www.tradingview.com/script/NgWB7Udh-Vestrix-ai-Liquidity-Atlas/
- type: indicator
- pine_id: PUB;20710d073d384348b3d4ff9e1a595758
- version: 1.0

## Description

[b]Vestrix.ai Liquidity Atlas[/b]
Built by Vestrix.ai — Build strategies and indicators with your own words not programming

A multi-layer map of non-obvious liquidity zones — the places where stop orders actually accumulate and where institutional reactions occur. Goes beyond the standard PDH / PWH / ONH levels every chart already shows by combining seven independent zone-detection modules into a single overlay.

[b]What it does[/b]
Most "key level" indicators draw the obvious: yesterday's high, the weekly high, the overnight high. These levels matter, but they are public knowledge — every screen on every desk already shows them. The Liquidity Atlas focuses instead on the zones traders rarely chart by hand because each requires its own logic: equal highs, untouched legacy levels, isolated rejection wicks, failed breakouts, large fair-value gaps, untouched time-at-price highs, and round-number magnets.
Each zone type is a separate, individually toggleable module with its own parameters and its own mitigation behaviour. The real edge is confluence — where two or three of these zones overlap, reaction probability is meaningfully higher than at any single level.

[b]How it works[/b]
The indicator runs seven detection modules in parallel. Each module identifies its zone type, draws it as a rectangle (so the zone has thickness, not just a line), keeps it on chart while it remains relevant, and removes or fades it once it is mitigated.

[b]1. Equal Highs / Equal Lows (EQH / EQL)[/b]
Detects clusters of two or more pivot highs (or lows) that fall within a tight tolerance band. Tolerance is configurable as either an ATR multiplier or a fixed tick distance. These clusters mark resting buy-side / sell-side liquidity — pools of stop orders that have accumulated above the highs or below the lows. When price sweeps through such a zone, the liquidity grab is visible in real time.

[b]2. Naked Levels[/b]
Tracks previous-day and previous-week highs / lows that have never been retouched since their formation. The longer a level remains untouched, the stronger its pull, because more time has passed without the resting orders being addressed. Levels expire automatically after a configurable number of days / weeks if they are not retouched.

[b]3. Wick Clusters[/b]
Flags individual bars that produced a significant rejection wick — a wick larger than X × ATR, accounting for at least Y % of the bar's total range, and printed at an isolated extreme relative to the previous N bars. These wicks indicate that liquidity was defended at that price without trading occurring there, behaviour consistent with hidden iceberg-style orders.

[b]4. Failed Breakouts[/b]
A two-stage detector. First, a pivot must be exceeded by at least X × ATR (the breakout). Then, within a configurable confirmation window, price must close back behind the pivot (the failure). When both conditions are met within the window, the level is marked as a failed-breakout zone — a textbook trap that statistically tends to be retested.

[b]5. Liquidity Voids[/b]
Identifies large 3-bar fair-value gaps — only those exceeding a minimum size (X × ATR) qualify. Standard small FVGs are deliberately filtered out to avoid clutter. These voids represent vacuum areas where price moved through quickly without trading, and they tend to be filled later.

[b]6. Naked POC[/b]
For each session, the price bucket touched by the most bars is recorded as that session's time-at-price high (a TPO-style approximation of a Point of Control, since Pine Script has no access to true volume profile data). When such a POC is never retested afterwards, it becomes a "naked POC" — typically the strongest single magnet of all the level types listed here. Bucket size is configurable to suit different instruments.

[b]7. Round Quarters[/b]
Draws psychological round-number levels around the current price (e.g. every 25 points on ES, every 100 on NQ, every 1000 on BTC). Algorithms and retail stops cluster heavily at these prices. Configurable step size, count, and zone width.

Mitigation modes
Every module that can be mitigated offers three independently configurable mitigation modes:

Delete on Touch — the zone is removed as soon as a wick enters it. Best for keeping the chart clean.

Delete on Close Beyond — the zone is kept until a bar actually closes through it. More conservative, useful for slower timeframes.

Fade on Touch — the zone stays visible but is greyed out. Useful when you want to track historical liquidity events for context.

This per-module flexibility means you can, for example, fade EQH / EQL zones to study past sweeps while having Naked POC zones disappear immediately on first touch.

[b]How to use it[/b]
The intended workflow is confluence-based: a single zone alone is rarely enough to trade off. The indicator earns its keep when two or three modules align at the same price.

An EQH that overlaps with a Naked POC above current price is a high-probability magnet — both stop liquidity and an unfilled value area pull.
A Liquidity Void that runs through a Round Quarter suggests the void will likely be filled at minimum to that level.
A Failed Breakout zone right above an EQH marks a textbook stop-run-and-reverse setup.

[b]Recommended starting configuration:[/b] enable EQH / EQL, Naked Levels, and Liquidity Voids first. Add Wick Clusters and Naked POC once the chart is comfortable. Failed Breakouts and Round Quarters are best switched on situationally.
Settings

[b]Global: [/b]label visibility, label size, max age (bars), fade transparency
Per module: enable toggle, detection thresholds, color, max-zones cap, mitigation mode
Instrument tuning: ATR-based thresholds keep the indicator self-scaling across timeframes; bucket size for Naked POC and step size for Round Quarters need to be adjusted for the instrument (ES default = 0.5 / 25; suggestions in the tooltips for MNQ, BTC, EUR/USD)

[b]Alerts[/b]

EQH Sweep / EQL Sweep
Naked Level Hit
Failed Breakout Formed
Liquidity Void Filled

All alerts fire on confirmed bar close (no repainting).

[b]Notes[/b]

Pivot-based modules (EQH / EQL, Failed Breakouts) confirm pivots with a Right Bars delay (default 5). New zones therefore appear with that delay relative to the pivot bar — this is normal and avoids repainting.
Wick Clusters, Voids, and Naked POC are computed in real time on the developing bar; only after bar close is the zone state final.
Naked POC is approximated through bar-count buckets, not true tick volume. It correlates strongly with a real Volume Profile POC on most instruments, but is not identical.
Concepts such as Equal Highs / Equal Lows, Liquidity Sweeps, Fair Value Gaps, and Naked POC are public Smart Money / ICT and Market Profile concepts. The contribution of this indicator is the unified detection, mitigation handling, and confluence visualization across all seven modules in a single tool.

[b]Disclaimer[/b]
This indicator is provided for educational and analytical purposes only. It is not financial advice and does not predict future price movement. Past performance does not guarantee future results. Trade at your own risk.

Built by Vestrix.ai — Build strategies and indicators with your own words not programming
© 2026 Vestrix.ai. Released for educational use on TradingView.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════
//  VESTRIX.AI LIQUIDITY ATLAS
//  Automatically built by Vestrix.ai 
//  Web: https://vestrix.ai
// ═══════════════════════════════════════════════════════════════════════
//
//  A multi-layer map of non-obvious liquidity zones — the places where
//  stops actually accumulate and where institutional reactions occur.
//  Goes beyond the standard PDH/PWH/ONH levels every screen displays.
//
//  Seven toggleable modules:
//    1) Equal Highs / Equal Lows  — clustered pivots = stop pools (BSL/SSL)
//    2) Naked Levels              — untouched D/W highs/lows = price magnets
//    3) Wick Clusters             — significant rejection wicks = hidden OB
//    4) Failed Breakouts          — bull/bear traps = retest candidates
//    5) Liquidity Voids           — large FVGs = vacuum zones to be filled
//    6) Naked POC                 — untouched time-at-price highs (TPO-style)
//    7) Round Quarters            — psychological round-number levels
//
//  Mitigation modes (per module):
//    • Delete on Touch        — zone removed as soon as a wick enters
//    • Delete on Close Beyond — zone kept until a bar closes through it
//    • Fade on Touch          — zone visually faded but kept for context
//
//  The real edge is confluence: where two or three of these align,
//  reaction probability is meaningfully higher than at any single zone.
//
//  ─────────────────────────────────────────────────────────────────────

//  ─────────────────────────────────────────────────────────────────────
//  © 2026 Vestrix.ai. Released for educational use on TradingView.
//  Not financial advice. 
// ═══════════════════════════════════════════════════════════════════════

//@version=6
indicator("Vestrix.ai Liquidity Atlas", shorttitle="Vestrix.ai Liq Atlas", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=100)


// ──────────────────────── GLOBAL ─────────────────────────────────────
gG = "▶ Global"
showLabels  = input.bool(true, "Show Labels", group=gG)
labelSizeIn = input.string("tiny", "Label Size", options=["tiny", "small", "normal"], group=gG)
maxAgeBars  = input.int(500, "Max Age (Bars)", minval=50, group=gG, tooltip="How far back pivots/wicks/voids are considered. Higher = more zones, but heavier on rendering.")
fadeTransp  = input.int(94, "Fade Transparency (%)", minval=70, maxval=99, group=gG, tooltip="Used by all 'Fade on Touch' modes. Higher = more invisible.")

labelSize = labelSizeIn == "tiny" ? size.tiny : labelSizeIn == "normal" ? size.normal : size.small
atr14 = ta.atr(14)
toPx(int n) => n * syminfo.mintick

// Mitigation mode constants (used as input options across modules)
MIT_TOUCH = "Delete on Touch"
MIT_CLOSE = "Delete on Close Beyond"
MIT_FADE  = "Fade on Touch"


// =====================================================================
//  1) EQH / EQL — Equal Highs / Equal Lows = Stop Cluster Pools
// =====================================================================
g1 = "1) EQH / EQL"
m1Use     = input.bool(true, "Enable EQH/EQL", group=g1, tooltip="Clusters of 2+ pivot highs/lows within a tight tolerance. These are where buy-side / sell-side stops stack up - classic ICT BSL/SSL pools.")
m1Left    = input.int(5,  "Pivot Left",  minval=2, group=g1)
m1Right   = input.int(5,  "Pivot Right", minval=2, group=g1, tooltip="Pivots are confirmed with Right-Bars delay.")
m1TolMode = input.string("ATR", "Tolerance Mode", options=["ATR", "Ticks"], group=g1, tooltip="How close two pivots must be to count as 'equal'.")
m1TolATR  = input.float(0.15, "  Tolerance (ATR mult)", minval=0.05, step=0.05, group=g1)
m1TolTk   = input.int(8,  "  Tolerance (Ticks)", minval=1, group=g1)
m1MinHits = input.int(2,  "Min Pivots in Cluster", minval=2, maxval=5, group=g1)
m1MaxZ    = input.int(6,  "Max Zones (per side)", minval=1, maxval=20, group=g1)
m1ColH    = input.color(#ef5350, "EQH Color", group=g1)
m1ColL    = input.color(#26a69a, "EQL Color", group=g1)
m1MitMode = input.string(MIT_TOUCH, "Mitigation Mode", options=[MIT_TOUCH, MIT_CLOSE, MIT_FADE], group=g1, tooltip="Touch: deleted on wick sweep. Close Beyond: deleted only when a bar closes past the zone. Fade: stays visible but greyed out after touch.")

m1Tol = m1TolMode == "ATR" ? atr14 * m1TolATR : toPx(m1TolTk)

type EQZone
    box   b
    label l
    float lvl
    bool  isHigh
    bool  mitigated

var array<EQZone> m1Zones = array.new<EQZone>()
var array<float>  m1PHs   = array.new<float>()
var array<int>    m1PHB   = array.new<int>()
var array<float>  m1PLs   = array.new<float>()
var array<int>    m1PLB   = array.new<int>()

ph = ta.pivothigh(m1Left, m1Right)
pl = ta.pivotlow(m1Left, m1Right)

// --- Process new pivot HIGH ---
if m1Use and not na(ph) and not na(m1Tol)
    pivotBar = bar_index - m1Right
    array.push(m1PHs, ph)
    array.push(m1PHB, pivotBar)
    if array.size(m1PHs) > 30
        array.shift(m1PHs)
        array.shift(m1PHB)

    bool extended = false
    if array.size(m1Zones) > 0
        for i = 0 to array.size(m1Zones) - 1
            z = array.get(m1Zones, i)
            if z.isHigh and not z.mitigated and not extended and math.abs(ph - z.lvl) <= m1Tol
                box.set_right(z.b, bar_index)
                if not na(z.l)
                    label.set_x(z.l, bar_index + 5)
                extended := true

    if not extended
        matchCount = 1
        leftMost   = pivotBar
        if array.size(m1PHs) > 1
            for i = 0 to array.size(m1PHs) - 2
                p  = array.get(m1PHs, i)
                bb = array.get(m1PHB, i)
                if bar_index - bb <= maxAgeBars and math.abs(p - ph) <= m1Tol
                    matchCount += 1
                    leftMost := math.min(leftMost, bb)
        if matchCount >= m1MinHits
            top_ = ph + m1Tol * 0.5
            bot_ = ph - m1Tol * 0.5
            b_ = box.new(left=leftMost, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m1ColH, 75), border_color=color.new(m1ColH, 40), border_width=1, extend=extend.right)
            label l_ = na
            if showLabels
                l_ := label.new(x=bar_index + 5, y=top_, text="EQH", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m1ColH, style=label.style_label_left, size=labelSize)
            array.push(m1Zones, EQZone.new(b_, l_, ph, true, false))
            if array.size(m1Zones) > m1MaxZ * 2
                old = array.shift(m1Zones)
                box.delete(old.b)
                if not na(old.l)
                    label.delete(old.l)

// --- Process new pivot LOW ---
if m1Use and not na(pl) and not na(m1Tol)
    pivotBar = bar_index - m1Right
    array.push(m1PLs, pl)
    array.push(m1PLB, pivotBar)
    if array.size(m1PLs) > 30
        array.shift(m1PLs)
        array.shift(m1PLB)

    bool extended = false
    if array.size(m1Zones) > 0
        for i = 0 to array.size(m1Zones) - 1
            z = array.get(m1Zones, i)
            if not z.isHigh and not z.mitigated and not extended and math.abs(pl - z.lvl) <= m1Tol
                box.set_right(z.b, bar_index)
                if not na(z.l)
                    label.set_x(z.l, bar_index + 5)
                extended := true

    if not extended
        matchCount = 1
        leftMost   = pivotBar
        if array.size(m1PLs) > 1
            for i = 0 to array.size(m1PLs) - 2
                p  = array.get(m1PLs, i)
                bb = array.get(m1PLB, i)
                if bar_index - bb <= maxAgeBars and math.abs(p - pl) <= m1Tol
                    matchCount += 1
                    leftMost := math.min(leftMost, bb)
        if matchCount >= m1MinHits
            top_ = pl + m1Tol * 0.5
            bot_ = pl - m1Tol * 0.5
            b_ = box.new(left=leftMost, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m1ColL, 75), border_color=color.new(m1ColL, 40), border_width=1, extend=extend.right)
            label l_ = na
            if showLabels
                l_ := label.new(x=bar_index + 5, y=bot_, text="EQL", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m1ColL, style=label.style_label_left, size=labelSize)
            array.push(m1Zones, EQZone.new(b_, l_, pl, false, false))
            if array.size(m1Zones) > m1MaxZ * 2
                old = array.shift(m1Zones)
                box.delete(old.b)
                if not na(old.l)
                    label.delete(old.l)

// --- Mitigation ---
var bool m1JustSweptH = false
var bool m1JustSweptL = false
m1JustSweptH := false
m1JustSweptL := false
if m1Use and array.size(m1Zones) > 0
    i = array.size(m1Zones) - 1
    while i >= 0
        z = array.get(m1Zones, i)
        if not z.mitigated
            zTop = z.lvl + m1Tol * 0.5
            zBot = z.lvl - m1Tol * 0.5
            touched      = z.isHigh ? high > zTop : low < zBot
            closedBeyond = z.isHigh ? close > zTop : close < zBot
            trigger = m1MitMode == MIT_CLOSE ? closedBeyond : touched
            if trigger
                if z.isHigh
                    m1JustSweptH := true
                else
                    m1JustSweptL := true
                if m1MitMode == MIT_FADE
                    z.mitigated := true
                    col_ = z.isHigh ? m1ColH : m1ColL
                    box.set_bgcolor(z.b, color.new(col_, fadeTransp))
                    box.set_border_color(z.b, color.new(col_, math.min(99, fadeTransp + 4)))
                else
                    box.delete(z.b)
                    if not na(z.l)
                        label.delete(z.l)
                    array.remove(m1Zones, i)
        i -= 1


// =====================================================================
//  2) NAKED LEVELS — Untouched D/W Highs/Lows = strongest magnets
// =====================================================================
g2 = "2) Naked Levels"
m2Use      = input.bool(true, "Enable Naked Levels", group=g2, tooltip="Tracks old PDH/PDL/PWH/PWL that have NEVER been retouched since formation. Older = stronger magnet because more unaddressed liquidity.")
m2Daily    = input.bool(true, "Track Daily Levels",  group=g2)
m2Weekly   = input.bool(true, "Track Weekly Levels", group=g2)
m2MaxBackD = input.int(10, "Max Days back",  minval=2, maxval=30, group=g2)
m2MaxBackW = input.int(8,  "Max Weeks back", minval=2, maxval=20, group=g2)
m2ColD     = input.color(#ffa726, "Daily Color",  group=g2)
m2ColW     = input.color(#7e57c2, "Weekly Color", group=g2)
m2ZW       = input.float(0.05, "Zone Width (ATR mult)", minval=0.01, step=0.01, group=g2)
m2MitMode  = input.string(MIT_TOUCH, "Mitigation Mode", options=[MIT_TOUCH, MIT_CLOSE, MIT_FADE], group=g2, tooltip="Touch: deleted as soon as a wick reaches the level. Close Beyond: only when a candle closes past it. Fade: stays visible but greyed out after touch.")

m2Width = atr14 * m2ZW

type NakedLvl
    box   b
    label l
    float lvl
    bool  isHigh
    bool  isWeekly
    int   birth
    bool  mitigated

var array<NakedLvl> m2Lvls = array.new<NakedLvl>()
var float m2CurDH = na
var float m2CurDL = na
var float m2CurWH = na
var float m2CurWL = na
var int   m2DayC  = 0
var int   m2WeekC = 0

newD = timeframe.change("D")
newW = timeframe.change("W")
if newD
    m2DayC += 1
if newW
    m2WeekC += 1

if m2Use
    if newD
        if m2Daily and not na(m2CurDH)
            top_ = m2CurDH + m2Width
            bot_ = m2CurDH
            b_ = box.new(left=bar_index, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m2ColD, 80), border_color=color.new(m2ColD, 50), border_width=1, extend=extend.right)
            label l_ = na
            if showLabels
                l_ := label.new(x=bar_index + 5, y=top_, text="nPDH", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m2ColD, style=label.style_label_left, size=labelSize)
            array.push(m2Lvls, NakedLvl.new(b_, l_, m2CurDH, true, false, m2DayC, false))
        if m2Daily and not na(m2CurDL)
            top_ = m2CurDL
            bot_ = m2CurDL - m2Width
            b_ = box.new(left=bar_index, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m2ColD, 80), border_color=color.new(m2ColD, 50), border_width=1, extend=extend.right)
            label l_ = na
            if showLabels
                l_ := label.new(x=bar_index + 5, y=bot_, text="nPDL", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m2ColD, style=label.style_label_left, size=labelSize)
            array.push(m2Lvls, NakedLvl.new(b_, l_, m2CurDL, false, false, m2DayC, false))
        m2CurDH := high
        m2CurDL := low
    else
        m2CurDH := math.max(nz(m2CurDH, high), high)
        m2CurDL := math.min(nz(m2CurDL, low),  low)

    if newW
        if m2Weekly and not na(m2CurWH)
            top_ = m2CurWH + m2Width
            bot_ = m2CurWH
            b_ = box.new(left=bar_index, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m2ColW, 75), border_color=color.new(m2ColW, 45), border_width=1, extend=extend.right)
            label l_ = na
            if showLabels
                l_ := label.new(x=bar_index + 5, y=top_, text="nPWH", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m2ColW, style=label.style_label_left, size=labelSize)
            array.push(m2Lvls, NakedLvl.new(b_, l_, m2CurWH, true, true, m2WeekC, false))
        if m2Weekly and not na(m2CurWL)
            top_ = m2CurWL
            bot_ = m2CurWL - m2Width
            b_ = box.new(left=bar_index, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m2ColW, 75), border_color=color.new(m2ColW, 45), border_width=1, extend=extend.right)
            label l_ = na
            if showLabels
                l_ := label.new(x=bar_index + 5, y=bot_, text="nPWL", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m2ColW, style=label.style_label_left, size=labelSize)
            array.push(m2Lvls, NakedLvl.new(b_, l_, m2CurWL, false, true, m2WeekC, false))
        m2CurWH := high
        m2CurWL := low
    else
        m2CurWH := math.max(nz(m2CurWH, high), high)
        m2CurWL := math.min(nz(m2CurWL, low),  low)

// Mitigation + age eviction
var bool m2JustHit = false
m2JustHit := false
if m2Use and array.size(m2Lvls) > 0
    i = array.size(m2Lvls) - 1
    while i >= 0
        z = array.get(m2Lvls, i)
        age    = z.isWeekly ? m2WeekC - z.birth : m2DayC - z.birth
        maxAge = z.isWeekly ? m2MaxBackW : m2MaxBackD
        if age > maxAge
            box.delete(z.b)
            if not na(z.l)
                label.delete(z.l)
            array.remove(m2Lvls, i)
        else if not z.mitigated
            touched      = z.isHigh ? high >= z.lvl : low <= z.lvl
            closedBeyond = z.isHigh ? close > z.lvl : close < z.lvl
            trigger = m2MitMode == MIT_CLOSE ? closedBeyond : touched
            if trigger
                m2JustHit := true
                if m2MitMode == MIT_FADE
                    z.mitigated := true
                    col_ = z.isWeekly ? m2ColW : m2ColD
                    box.set_bgcolor(z.b, color.new(col_, fadeTransp))
                    box.set_border_color(z.b, color.new(col_, math.min(99, fadeTransp + 4)))
                else
                    box.delete(z.b)
                    if not na(z.l)
                        label.delete(z.l)
                    array.remove(m2Lvls, i)
        i -= 1


// =====================================================================
//  3) WICK CLUSTERS — Significant Rejection Wicks
// =====================================================================
g3 = "3) Wick Clusters"
m3Use     = input.bool(true, "Enable Wick Clusters", group=g3, tooltip="Bars with a significant rejection wick (>X*ATR). Evidence that liquidity was defended without price trading there - hidden order block / iceberg.")
m3WickATR = input.float(0.7, "Min Wick (ATR mult)", minval=0.2, step=0.1, group=g3)
m3WickPct = input.float(60, "Min Wick % of Range", minval=30, maxval=90, group=g3, tooltip="Wick must be at least X% of the bar range.")
m3IsoLook = input.int(3, "Isolation Lookback", minval=1, maxval=10, group=g3, tooltip="Bar must be higher (upper wick) or lower (lower wick) than the previous N bars for the wick to count as an isolated rejection.")
m3MaxZ    = input.int(15, "Max Zones", minval=2, maxval=30, group=g3)
m3ColUp   = input.color(#ec407a, "Upper Wick Color", group=g3)
m3ColDn   = input.color(#5c6bc0, "Lower Wick Color", group=g3)
m3MitMode = input.string(MIT_CLOSE, "Mitigation Mode", options=[MIT_TOUCH, MIT_CLOSE, MIT_FADE], group=g3, tooltip="Touch: deleted as soon as price re-enters the wick zone. Close Beyond: only when a candle closes past the wick extreme (rejection overcome). Fade: stays visible but greyed out.")

type WickZone
    box   b
    label l
    float top
    float bot
    bool  isUpper
    int   birthBar
    bool  mitigated

var array<WickZone> m3Zones = array.new<WickZone>()

if m3Use and not na(atr14)
    bodyHi = math.max(open, close)
    bodyLo = math.min(open, close)
    upWick = high - bodyHi
    dnWick = bodyLo - low
    rng    = high - low

    isoUp = high > ta.highest(high, m3IsoLook)[1]
    if upWick > atr14 * m3WickATR and rng > 0 and (upWick / rng) * 100 >= m3WickPct and isoUp
        b_ = box.new(left=bar_index, top=high, right=bar_index, bottom=bodyHi, bgcolor=color.new(m3ColUp, 80), border_color=color.new(m3ColUp, 50), border_width=1, extend=extend.right)
        label l_ = na
        if showLabels
            l_ := label.new(x=bar_index + 5, y=high, text="WkU", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m3ColUp, style=label.style_label_left, size=labelSize)
        array.push(m3Zones, WickZone.new(b_, l_, high, bodyHi, true, bar_index, false))
        if array.size(m3Zones) > m3MaxZ * 2
            old = array.shift(m3Zones)
            box.delete(old.b)
            if not na(old.l)
                label.delete(old.l)

    isoDn = low < ta.lowest(low, m3IsoLook)[1]
    if dnWick > atr14 * m3WickATR and rng > 0 and (dnWick / rng) * 100 >= m3WickPct and isoDn
        b_ = box.new(left=bar_index, top=bodyLo, right=bar_index, bottom=low, bgcolor=color.new(m3ColDn, 80), border_color=color.new(m3ColDn, 50), border_width=1, extend=extend.right)
        label l_ = na
        if showLabels
            l_ := label.new(x=bar_index + 5, y=low, text="WkL", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m3ColDn, style=label.style_label_left, size=labelSize)
        array.push(m3Zones, WickZone.new(b_, l_, bodyLo, low, false, bar_index, false))
        if array.size(m3Zones) > m3MaxZ * 2
            old = array.shift(m3Zones)
            box.delete(old.b)
            if not na(old.l)
                label.delete(old.l)

// Mitigation
if m3Use and array.size(m3Zones) > 0
    i = array.size(m3Zones) - 1
    while i >= 0
        z = array.get(m3Zones, i)
        if bar_index > z.birthBar and not z.mitigated
            // Touch = wick re-enters the zone
            touched      = z.isUpper ? high >= z.bot : low <= z.top
            // Close Beyond = bar closes past the wick extreme
            closedBeyond = z.isUpper ? close > z.top : close < z.bot
            trigger = m3MitMode == MIT_CLOSE ? closedBeyond : touched
            if trigger
                if m3MitMode == MIT_FADE
                    z.mitigated := true
                    col_ = z.isUpper ? m3ColUp : m3ColDn
                    box.set_bgcolor(z.b, color.new(col_, fadeTransp))
                    box.set_border_color(z.b, color.new(col_, math.min(99, fadeTransp + 4)))
                else
                    box.delete(z.b)
                    if not na(z.l)
                        label.delete(z.l)
                    array.remove(m3Zones, i)
        i -= 1


// =====================================================================
//  4) FAILED BREAKOUTS — Bull/Bear Traps
// =====================================================================
g4 = "4) Failed Breakouts"
m4Use      = input.bool(true, "Enable Failed Breakouts", group=g4, tooltip="A pivot is briefly broken but not held -> classic trap. Statistically retested often.")
m4Left     = input.int(5, "Pivot Left",  minval=2, group=g4)
m4Right    = input.int(5, "Pivot Right", minval=2, group=g4)
m4Window   = input.int(15, "Confirm Window (Bars)", minval=3, maxval=50, group=g4, tooltip="Within how many bars after breakout the price must return behind the pivot to count as 'failed'.")
m4MinBreak = input.float(0.05, "Min Breakout (ATR mult)", minval=0.0, step=0.05, group=g4, tooltip="How much the pivot must be exceeded.")
m4MaxZ     = input.int(10, "Max Zones", minval=1, maxval=20, group=g4)
m4ZW       = input.float(0.10, "Zone Width (ATR mult)", minval=0.02, step=0.02, group=g4)
m4ColH     = input.color(#ff5722, "Failed High Color", group=g4)
m4ColL     = input.color(#00bcd4, "Failed Low Color",  group=g4)
m4MitMode  = input.string(MIT_TOUCH, "Mitigation Mode", options=[MIT_TOUCH, MIT_CLOSE, MIT_FADE], group=g4, tooltip="Touch: deleted on first retest of the level (trap played out). Close Beyond: only when a bar closes past it (trap overcome). Fade: stays visible after retest.")

m4Width = atr14 * m4ZW

type FBPending
    float lvl
    bool  isHigh
    int   pivotBar
    int   breakBar

type FBZone
    box   b
    label l
    float lvl
    bool  isHigh
    int   birthBar
    bool  mitigated

var array<FBPending> m4Pend  = array.new<FBPending>()
var array<FBZone>    m4Zones = array.new<FBZone>()

ph4 = ta.pivothigh(m4Left, m4Right)
pl4 = ta.pivotlow(m4Left, m4Right)

if m4Use and not na(ph4)
    array.push(m4Pend, FBPending.new(ph4, true, bar_index - m4Right, -1))
if m4Use and not na(pl4)
    array.push(m4Pend, FBPending.new(pl4, false, bar_index - m4Right, -1))

var bool m4JustFormed = false
m4JustFormed := false
if m4Use and array.size(m4Pend) > 0 and not na(atr14)
    i = array.size(m4Pend) - 1
    while i >= 0
        p = array.get(m4Pend, i)
        if p.breakBar < 0
            broke  = p.isHigh ? high > p.lvl + atr14 * m4MinBreak : low < p.lvl - atr14 * m4MinBreak
            tooOld = bar_index - p.pivotBar > 100
            if broke
                p.breakBar := bar_index
            else if tooOld
                array.remove(m4Pend, i)
        else
            reclaimed = p.isHigh ? close < p.lvl : close > p.lvl
            withinWin = bar_index - p.breakBar <= m4Window
            if reclaimed and withinWin
                col_ = p.isHigh ? m4ColH : m4ColL
                txt_ = p.isHigh ? "FailH" : "FailL"
                top_ = p.isHigh ? p.lvl + m4Width : p.lvl
                bot_ = p.isHigh ? p.lvl : p.lvl - m4Width
                b_ = box.new(left=p.pivotBar, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(col_, 75), border_color=color.new(col_, 40), border_width=1, extend=extend.right)
                label l_ = na
                if showLabels
                    l_ := label.new(x=bar_index + 5, y=p.isHigh ? top_ : bot_, text=txt_, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=col_, style=label.style_label_left, size=labelSize)
                array.push(m4Zones, FBZone.new(b_, l_, p.lvl, p.isHigh, bar_index, false))
                m4JustFormed := true
                if array.size(m4Zones) > m4MaxZ * 2
                    old = array.shift(m4Zones)
                    box.delete(old.b)
                    if not na(old.l)
                        label.delete(old.l)
                array.remove(m4Pend, i)
            else if not withinWin
                array.remove(m4Pend, i)
        i -= 1

// Mitigation
if m4Use and array.size(m4Zones) > 0
    i = array.size(m4Zones) - 1
    while i >= 0
        z = array.get(m4Zones, i)
        if bar_index > z.birthBar and not z.mitigated
            touched      = z.isHigh ? high >= z.lvl : low <= z.lvl
            closedBeyond = z.isHigh ? close > z.lvl : close < z.lvl
            trigger = m4MitMode == MIT_CLOSE ? closedBeyond : touched
            if trigger
                if m4MitMode == MIT_FADE
                    z.mitigated := true
                    col_ = z.isHigh ? m4ColH : m4ColL
                    box.set_bgcolor(z.b, color.new(col_, fadeTransp))
                    box.set_border_color(z.b, color.new(col_, math.min(99, fadeTransp + 4)))
                else
                    box.delete(z.b)
                    if not na(z.l)
                        label.delete(z.l)
                    array.remove(m4Zones, i)
        i -= 1


// =====================================================================
//  5) LIQUIDITY VOIDS — Large FVGs (>X*ATR)
// =====================================================================
g5 = "5) Liquidity Voids"
m5Use     = input.bool(true, "Enable Liquidity Voids", group=g5, tooltip="Large FVGs (>X*ATR). Areas where price ran through without trading. Vacuum zones that tend to be filled later.")
m5MinSize = input.float(0.5, "Min Void Size (ATR mult)", minval=0.1, step=0.1, group=g5, tooltip="FVG must be at least X*ATR in size to count as a 'void'. Standard small FVGs are filtered out.")
m5MaxZ    = input.int(20, "Max Zones", minval=2, maxval=40, group=g5)
m5ColUp   = input.color(#66bb6a, "Bull Void Color", group=g5)
m5ColDn   = input.color(#ef5350, "Bear Void Color", group=g5)
m5MitMode = input.string(MIT_TOUCH, "Mitigation Mode", options=[MIT_TOUCH, MIT_CLOSE, MIT_FADE], group=g5, tooltip="Touch: deleted on first wick into the void. Close Beyond: only when a bar closes past the far edge (void fully filled). Fade: stays visible after first touch.")

type VoidZone
    box   b
    label l
    float top
    float bot
    bool  isBull
    bool  mitigated

var array<VoidZone> m5Zones = array.new<VoidZone>()

if m5Use and bar_index > 2 and not na(atr14)
    bullVoid = low > high[2] and (low - high[2]) > atr14 * m5MinSize
    bearVoid = high < low[2] and (low[2] - high) > atr14 * m5MinSize

    if bullVoid
        top_ = low
        bot_ = high[2]
        b_ = box.new(left=bar_index - 2, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m5ColUp, 80), border_color=color.new(m5ColUp, 50), border_width=1, extend=extend.right)
        label l_ = na
        if showLabels
            l_ := label.new(x=bar_index + 5, y=(top_ + bot_) / 2, text="Void↑", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m5ColUp, style=label.style_label_left, size=labelSize)
        array.push(m5Zones, VoidZone.new(b_, l_, top_, bot_, true, false))
        if array.size(m5Zones) > m5MaxZ * 2
            old = array.shift(m5Zones)
            box.delete(old.b)
            if not na(old.l)
                label.delete(old.l)

    if bearVoid
        top_ = low[2]
        bot_ = high
        b_ = box.new(left=bar_index - 2, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m5ColDn, 80), border_color=color.new(m5ColDn, 50), border_width=1, extend=extend.right)
        label l_ = na
        if showLabels
            l_ := label.new(x=bar_index + 5, y=(top_ + bot_) / 2, text="Void↓", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m5ColDn, style=label.style_label_left, size=labelSize)
        array.push(m5Zones, VoidZone.new(b_, l_, top_, bot_, false, false))
        if array.size(m5Zones) > m5MaxZ * 2
            old = array.shift(m5Zones)
            box.delete(old.b)
            if not na(old.l)
                label.delete(old.l)

// Mitigation
var bool m5JustFilled = false
m5JustFilled := false
if m5Use and array.size(m5Zones) > 0
    i = array.size(m5Zones) - 1
    while i >= 0
        z = array.get(m5Zones, i)
        if not z.mitigated
            // Touch = first wick into the void
            touched      = z.isBull ? low <= z.top : high >= z.bot
            // Close Beyond = bar closes past the far edge (void fully filled)
            closedBeyond = z.isBull ? close < z.bot : close > z.top
            trigger = m5MitMode == MIT_CLOSE ? closedBeyond : touched
            if trigger
                m5JustFilled := true
                if m5MitMode == MIT_FADE
                    z.mitigated := true
                    col_ = z.isBull ? m5ColUp : m5ColDn
                    box.set_bgcolor(z.b, color.new(col_, fadeTransp))
                    box.set_border_color(z.b, color.new(col_, math.min(99, fadeTransp + 4)))
                else
                    box.delete(z.b)
                    if not na(z.l)
                        label.delete(z.l)
                    array.remove(m5Zones, i)
        i -= 1


// =====================================================================
//  6) NAKED POC — Untouched Time-at-Price High of past sessions
// =====================================================================
g6 = "6) Naked POC"
m6Use     = input.bool(true, "Enable Naked POC", group=g6, tooltip="One Point of Control per session = the price bucket touched by the most bars (Time-at-Price high). When never retested -> Naked POC = often the strongest magnet of all levels. Approximated via bar-count buckets since Pine has no Volume Profile.")
m6Bucket  = input.float(0.5, "Bucket Size (Points)", minval=0.05, step=0.05, group=g6, tooltip="Granularity of price buckets. ES: 0.25-1.0 ; MNQ: 1-5 ; BTC: 50-200.")
m6MaxBack = input.int(10, "Max Sessions back", minval=2, maxval=30, group=g6)
m6ZW      = input.float(0.05, "Zone Width (ATR mult)", minval=0.01, step=0.01, group=g6)
m6Col     = input.color(#ffd54f, "POC Color", group=g6)
m6MitMode = input.string(MIT_TOUCH, "Mitigation Mode", options=[MIT_TOUCH, MIT_CLOSE, MIT_FADE], group=g6, tooltip="Touch: deleted as soon as a bar's range crosses the POC line. Close Beyond: only when a bar closes outside the zone box. Fade: stays visible after first touch.")

m6Width = atr14 * m6ZW

type POCZone
    box   b
    label l
    float lvl
    int   birthDay
    int   birthBar
    bool  mitigated

var map<int, int>  m6Buckets = map.new<int, int>()
var array<POCZone> m6Zones   = array.new<POCZone>()
var int m6DayC = 0

newDay6 = timeframe.change("D")
if newDay6
    m6DayC += 1

if m6Use and not na(atr14)
    if newDay6 and map.size(m6Buckets) > 0
        keys = map.keys(m6Buckets)
        maxKey   = array.get(keys, 0)
        maxCount = map.get(m6Buckets, maxKey)
        if array.size(keys) > 1
            for i = 1 to array.size(keys) - 1
                k = array.get(keys, i)
                c = map.get(m6Buckets, k)
                if c > maxCount
                    maxCount := c
                    maxKey   := k
        pocPrice = maxKey * m6Bucket
        top_ = pocPrice + m6Width
        bot_ = pocPrice - m6Width
        b_ = box.new(left=bar_index, top=top_, right=bar_index, bottom=bot_, bgcolor=color.new(m6Col, 75), border_color=color.new(m6Col, 40), border_width=1, extend=extend.right)
        label l_ = na
        if showLabels
            l_ := label.new(x=bar_index + 5, y=pocPrice, text="nPOC", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m6Col, style=label.style_label_left, size=labelSize)
        array.push(m6Zones, POCZone.new(b_, l_, pocPrice, m6DayC, bar_index, false))
        map.clear(m6Buckets)

    loB = int(math.round(low / m6Bucket))
    hiB = int(math.round(high / m6Bucket))
    span = math.min(hiB - loB, 200)
    for b = loB to loB + span
        prev = map.contains(m6Buckets, b) ? map.get(m6Buckets, b) : 0
        map.put(m6Buckets, b, prev + 1)

    // Mitigation + age eviction
    if array.size(m6Zones) > 0
        i = array.size(m6Zones) - 1
        while i >= 0
            z = array.get(m6Zones, i)
            ageDays = m6DayC - z.birthDay
            if ageDays > m6MaxBack
                box.delete(z.b)
                if not na(z.l)
                    label.delete(z.l)
                array.remove(m6Zones, i)
            else if bar_index > z.birthBar and not z.mitigated
                zTop = z.lvl + m6Width
                zBot = z.lvl - m6Width
                // Touch = bar range crosses the POC line
                touched      = low <= z.lvl and high >= z.lvl
                // Close Beyond = close exits the zone box on either side
                closedBeyond = close > zTop or close < zBot
                trigger = m6MitMode == MIT_CLOSE ? closedBeyond : touched
                if trigger
                    if m6MitMode == MIT_FADE
                        z.mitigated := true
                        box.set_bgcolor(z.b, color.new(m6Col, fadeTransp))
                        box.set_border_color(z.b, color.new(m6Col, math.min(99, fadeTransp + 4)))
                    else
                        box.delete(z.b)
                        if not na(z.l)
                            label.delete(z.l)
                        array.remove(m6Zones, i)
            i -= 1


// =====================================================================
//  7) ROUND QUARTERS — Psychological round-number levels
//  (no mitigation - zones simply follow current price)
// =====================================================================
g7 = "7) Round Quarters"
m7Use   = input.bool(true, "Enable Round Quarters", group=g7, tooltip="Psychological round-number levels. Algos and retail stops cluster here. Defaults: ES = 25 (Quarters). MNQ = 100. EUR/USD = 0.005. BTC = 1000.")
m7Step  = input.float(25.0, "Step (Points)", minval=0.25, step=0.25, group=g7)
m7Count = input.int(4, "Levels above/below", minval=1, maxval=10, group=g7)
m7ZW    = input.float(0.02, "Zone Width (ATR mult)", minval=0.005, step=0.005, group=g7)
m7Col   = input.color(#9e9e9e, "Color", group=g7)

m7Width = atr14 * m7ZW

var array<box>   m7Boxes = array.new<box>()
var array<label> m7Labs  = array.new<label>()
var float m7PrevNearest  = na

if m7Use and barstate.islast and not na(atr14)
    nearest = math.round(close / m7Step) * m7Step
    if na(m7PrevNearest) or nearest != m7PrevNearest
        if array.size(m7Boxes) > 0
            for i = 0 to array.size(m7Boxes) - 1
                box.delete(array.get(m7Boxes, i))
            array.clear(m7Boxes)
        if array.size(m7Labs) > 0
            for i = 0 to array.size(m7Labs) - 1
                label.delete(array.get(m7Labs, i))
            array.clear(m7Labs)
        for i = -m7Count to m7Count
            lvl = nearest + i * m7Step
            b_ = box.new(left=bar_index - 50, top=lvl + m7Width, right=bar_index, bottom=lvl - m7Width, bgcolor=color.new(m7Col, 85), border_color=color.new(m7Col, 65), border_width=1, extend=extend.right)
            array.push(m7Boxes, b_)
            if showLabels
                l_ = label.new(x=bar_index + 5, y=lvl, text=str.tostring(lvl, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.black, 100), textcolor=m7Col, style=label.style_label_left, size=labelSize)
                array.push(m7Labs, l_)
        m7PrevNearest := nearest


// =====================================================================
//  ALERTS
// =====================================================================
alertcondition(m1JustSweptH, title="EQH Sweep",       message="Vestrix.ai Liquidity Atlas: EQH swept on {{ticker}} {{interval}} @ {{close}}")
alertcondition(m1JustSweptL, title="EQL Sweep",       message="Vestrix.ai Liquidity Atlas: EQL swept on {{ticker}} {{interval}} @ {{close}}")
alertcondition(m2JustHit,    title="Naked Level Hit", message="Vestrix.ai Liquidity Atlas: Naked Level hit on {{ticker}} {{interval}} @ {{close}}")
alertcondition(m4JustFormed, title="Failed Breakout", message="Vestrix.ai Liquidity Atlas: Failed Breakout formed on {{ticker}} {{interval}} @ {{close}}")
alertcondition(m5JustFilled, title="Liquidity Void Filled", message="Vestrix.ai Liquidity Atlas: Liquidity Void filled on {{ticker}} {{interval}} @ {{close}}")

if m1JustSweptH
    alert("Vestrix.ai Liquidity Atlas: EQH swept on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
if m1JustSweptL
    alert("Vestrix.ai Liquidity Atlas: EQL swept on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
````
