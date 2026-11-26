# Adaptive S/R Breaks & Retests [NeBlok]

- url: https://www.tradingview.com/script/ulIgkgTP-Adaptive-S-R-Breaks-Retests-NeBlok/
- type: indicator
- pine_id: PUB;7312076445694f23a91548dfbd147b78
- version: 1.0

## Description

ADAPTIVE S/R BREAKS & RETESTS [NeBlok]

Most support/resistance tools stop at one question: did price break the level? This one keeps going. It grades the quality of every break, then follows the level after the break to show whether the move was confirmed by a retest, rejected as a trap, or faked out with a liquidity sweep. The goal is to help you separate real breakouts from noise, and to show you where the higher-quality entries tend to form: after the break, not during it.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1) PIVOT-BASED LEVELS AND ZONES
Swing highs become resistance (red) and swing lows become support (blue). Each level is drawn as a zone rather than a single thin line. The zone's width scales with ATR, so it adapts to the volatility of whatever market and timeframe you're on. A new swing replaces the previous live level on that side.

Each live level carries a price tag on the right showing its price and how many times it has been tested (for example, "R 642.10 ×3"). Every fresh test also makes the line visibly thicker, so heavily defended levels stand out at a glance.

2) SCORED BREAKOUTS (TIER A / B / C)
A break occurs when a candle CLOSES beyond a level (wicks alone don't count). Each break is scored on three independent factors, one point each:

 - Participation: relative volume (RVOL) is above your threshold. On symbols with no volume data, such as some indices and forex pairs, the script automatically switches to a range-expansion check (candle range vs. ATR).
 - Conviction: the candle has a strong body in the direction of the break, not a long-wicked indecision bar.
 - Displacement: price closed a meaningful distance past the level, measured in ATR.

3 points = Tier A, 2 points = Tier B, 1 point = Tier C.
Bullish breaks print as ▲ below the bar. Bearish breaks print as ▼ above the bar. Hover over any break label to see its full scorecard: the RVOL reading, body percentage, and close distance, each marked ✓ or ✗.

3) ROLE REVERSAL: THE FLIP ZONE
When a qualified break occurs, the level doesn't simply disappear. It flips roles. Broken resistance becomes potential support (and vice versa), drawn as a dashed zone in the opposite color with a tag such as "R→S". The script then watches this flip zone for a set number of bars (the Retest Watch Window).

4) RETESTS (RT)
If price returns into the flip zone and closes back on the breakout side, an RT label prints. This shows the old level being defended in its new role. Many traders consider this the more reliable entry point compared with chasing the initial break.

5) TRAPS (TRAP)
If price instead closes back through the flip zone, a TRAP label prints. The breakout has failed, and traders who chased it are now offside. Failed breaks often lead to sharp moves in the opposite direction.

6) LIQUIDITY SWEEPS (SW)
When price wicks through a live level but closes back inside it, an SW label prints. This often marks stop-runs above resistance or below support. A sweep is not a break, and the level stays live.

7) HISTORY
Once a level is replaced, retested, trapped, or expires, it is archived and faded into the background. You keep the historical context without the clutter.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A simple workflow:

 1. Note the live zones. The dashboard shows the nearest resistance and support and how far away each is in ATR, which helps you judge how much room price has to move.
 2. Watch for a break and check its tier. Tier A breaks had volume, conviction, and displacement all at once. Tier C breaks passed only one test and deserve more skepticism.
 3. Don't chase. Wait to see how price treats the flip zone.
 4. An RT (retest held) confirms the new structure and gives a defined area to plan around. A logical invalidation sits on the far side of the flip zone.
 5. A TRAP tells you the break failed. Consider standing aside, or look for opportunities in the opposite direction.
 6. Use SW sweeps as context. A sweep against a strong level often shows liquidity being taken before a reversal, or before a genuine break later on.

Ideas for combining it:
 - Filter signals with a higher-timeframe trend tool, and favor breaks in the direction of the larger trend.
 - Raise "Minimum Tier to Signal" to B or A for fewer, higher-quality signals.
 - Use the ATR distance readings in the dashboard to size stops and targets consistently across markets.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STRUCTURE
 - Pivot Left / Right Bars (default 15 / 15): how significant a swing must be to create a level. Lower values give more, shorter-term levels; higher values give fewer, major levels. On lower timeframes, 8 to 10 is often a better starting point.
 - ATR Length (default 14): the volatility measure used for zones and scoring.
 - Zone Half-Width (default 0.20 × ATR): how thick each zone is. It also sets the tolerance for touches, retests, and traps.

BREAK SCORING
 - Min Close-Through (default 0.05 × ATR): how far past the level a close must be to count as a break at all.
 - RVOL Length / Threshold (default 20 / 1.3): the volume participation test.
 - No-Volume Fallback Range (default 1.2 × ATR): used automatically when the symbol has no volume data.
 - Body / Range (default 0.55): the conviction test.
 - Close Beyond Level (default 0.35 × ATR): the displacement test.
 - Minimum Tier to Signal (default C): breaks below this tier still end the level, but are not labeled and do not start a retest watch.

EVENTS
 - Toggle Retests, Traps, and Sweeps on or off.
 - Retest Watch Window (default 20 bars): how long a flip zone stays active while waiting for a retest or trap.

VISUALS
 - 3D Depth Rendering: layered glow, drop shadow, and highlight on each level. Turn it off for a minimal look.
 - Fade Historical Levels, Price Tags, Extend Right, Historical Levels Kept, and full color customization.

DASHBOARD
 - Live resistance and support with their distance in ATR, current RVOL, the last signal and how many bars ago it occurred, and how many flip zones are currently on retest watch.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

There are two ways to set alerts:
 - "Any alert() function call" gives you one alert covering every event, with detailed messages that include the tier, level price, ticker, timeframe, and close.
 - Individual conditions are also available: Bullish Break, Bearish Break, Retest Held, Trap (Failed Break), and Liquidity Sweep.

All alerts fire once per bar, on bar close.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REPAINTING AND LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 - Pivots can only be confirmed after the "Right Bars" count has passed. For readability, levels are drawn back to the actual swing bar, but no signal can fire until the level is confirmed. Signals are evaluated on bar close only, so once printed they do not repaint.
 - Because of that confirmation delay, a level appears on the chart several bars after the swing that created it. This is a property of all pivot-based tools, not a bug.
 - Volume data varies by exchange and data feed, so RVOL readings on the same asset can differ between symbols.
 - No indicator is right every time. Breakouts fail, retests fail, and tiers describe the quality of a candle, not the certainty of an outcome.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is provided free of charge for educational and informational purposes only. It is NOT financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, cryptocurrency, or other financial instrument.

Trading involves substantial risk of loss and is not suitable for every investor. You can lose some or all of your capital, and leveraged products such as futures, options, and margined crypto can lose more than your initial deposit. Past performance, whether actual or backtested, does not guarantee future results. Signals shown by this indicator on historical data do not represent actual trades.

You are solely responsible for your own trading decisions. Always do your own research, use proper risk management, and consult a licensed financial professional before making investment decisions. The author and NeBlok accept no liability for any losses arising from the use of this script.

© NeBlok

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

// Adaptive S/R Breaks & Retests [NeBlok]
// ─────────────────────────────────────────────────────────────────────────────
// Pivot-anchored support/resistance ZONES (ATR-scaled) with:
//   • Scored breakouts — 3-point quality model → Tier A / B / C
//       1) Participation : relative volume ≥ threshold (range expansion fallback on no-volume symbols)
//       2) Conviction    : candle body/range ≥ threshold, in the direction of the break
//       3) Displacement  : close beyond the level ≥ X × ATR
//   • Role reversal — a qualified break ARMS a retest watch: broken resistance becomes support
//     (and vice versa), drawn as a dashed flip-zone
//   • Retests (RT) — price returns to the flipped zone and holds
//   • Traps — price closes back through the flipped zone (failed breakout / breakdown)
//   • Liquidity sweeps (SW) — wick through a live level, close back inside
//   • Touch counting — live level thickens with each fresh test
//   • Pseudo-3D rendering — layered glow, drop shadow and specular highlight
//   • Dashboard + alert() hooks
// Signals evaluate on bar close only. Levels are back-drawn to the pivot bar for readability,
// but nothing can fire until the pivot is confirmed, so signals do not repaint.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Adaptive S/R Breaks & Retests [NeBlok]", shorttitle = "S/R Breaks [NeBlok]", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
G_STR = "Structure"
int   leftBars   = input.int(15, "Pivot Left Bars", minval = 1, group = G_STR)
int   rightBars  = input.int(15, "Pivot Right Bars", minval = 1, group = G_STR, tooltip = "Pivots confirm this many bars after the swing. Levels are back-drawn to the pivot bar, but no signal can fire until the pivot is confirmed.")
int   atrLen     = input.int(14, "ATR Length", minval = 1, group = G_STR)
float zoneMult   = input.float(0.20, "Zone Half-Width (× ATR)", minval = 0.0, step = 0.05, group = G_STR)

G_BRK = "Break Scoring  (1 pt each → Tier C / B / A)"
float minThru    = input.float(0.05, "Min Close-Through to Count as Break (× ATR)", minval = 0.0, step = 0.05, group = G_BRK)
int   volLen     = input.int(20, "Relative Volume Length", minval = 2, group = G_BRK)
float rvolMin    = input.float(1.3, "Pt 1 · RVOL ≥", minval = 0.1, step = 0.1, group = G_BRK)
float rangeMult  = input.float(1.2, "Pt 1 · No-Volume Fallback: Range ≥ × ATR", minval = 0.1, step = 0.1, group = G_BRK)
float bodyMin    = input.float(0.55, "Pt 2 · Body / Range ≥", minval = 0.0, maxval = 1.0, step = 0.05, group = G_BRK)
float distStrong = input.float(0.35, "Pt 3 · Close Beyond Level ≥ × ATR", minval = 0.0, step = 0.05, group = G_BRK)
string minTier   = input.string("C", "Minimum Tier to Signal", options = ["A", "B", "C"], group = G_BRK, tooltip = "Breaks below this tier still end the level, but are not labeled and do not arm a retest watch.")

G_EVT = "Events"
bool showRetest  = input.bool(true, "Retests of Broken Levels (RT)", group = G_EVT)
bool showTraps   = input.bool(true, "Failed Breaks (TRAP)", group = G_EVT)
int  retestWin   = input.int(20, "Retest Watch Window (bars)", minval = 1, group = G_EVT)
bool showSweeps  = input.bool(true, "Liquidity Sweeps (SW)", group = G_EVT)

G_VIS = "Visuals"
bool use3D       = input.bool(true, "3D Depth Rendering (glow · shadow · highlight)", group = G_VIS)
bool fadeHist    = input.bool(true, "Fade Historical Levels", group = G_VIS)
bool showTags    = input.bool(true, "Price Tags on Live Levels", group = G_VIS)
int  extendRight = input.int(8, "Extend Live Levels Right (bars)", minval = 0, maxval = 100, group = G_VIS)
int  maxHist     = input.int(30, "Historical Levels Kept", minval = 1, maxval = 100, group = G_VIS)

G_COL = "Colors"
color resCol     = input.color(#FF4D6D, "Resistance", inline = "c1", group = G_COL)
color supCol     = input.color(#3D8BFF, "Support", inline = "c1", group = G_COL)
color bullCol    = input.color(#16C784, "Bull Break", inline = "c2", group = G_COL)
color bearCol    = input.color(#EA3943, "Bear Break", inline = "c2", group = G_COL)
color retestCol  = input.color(#F5B942, "Retest", inline = "c3", group = G_COL)
color trapCol    = input.color(#FF8C42, "Trap", inline = "c3", group = G_COL)
color sweepCol   = input.color(#B26BFF, "Sweep", inline = "c4", group = G_COL)
color shadowCol  = input.color(#000000, "Shadow", inline = "c4", group = G_COL)
color accentCol  = input.color(#00E5FF, "Accent", inline = "c5", group = G_COL)

G_DSH = "Dashboard"
bool   showDash  = input.bool(true, "Show Dashboard", group = G_DSH)
string dashPos   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_DSH)

int  minScore  = minTier == "A" ? 3 : minTier == "B" ? 2 : 1
bool armRetest = showRetest or showTraps

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// state: 0 = live, 1 = broken & watching for retest/trap, 2 = archived
type Level
    float price
    float zh
    bool  isRes    = true
    int   state    = 0
    int   startBar
    int   breakBar
    int   touches  = 0
    box   glowOuter
    box   glowInner
    line  shadow
    line  core
    line  hilite
    box   flipBox
    line  flipLine
    label tag

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE SERIES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float atr     = ta.atr(atrLen)
float volSma  = ta.sma(volume, volLen)
bool  hasVol  = not na(volSma) and volSma > 0
float rvol    = hasVol ? volume / volSma : na
float rng     = high - low
float bodyPct = rng > 0 ? math.abs(close - open) / rng : 0.0
bool  conf    = barstate.isconfirmed

float ph = ta.pivothigh(high, leftBars, rightBars)
float pl = ta.pivotlow(low, leftBars, rightBars)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var Level        activeRes = na
var Level        activeSup = na
var array<Level> flipped   = array.new<Level>()
var array<Level> history   = array.new<Level>()

var string lastSig    = "—"
var int    lastSigBar = na
var color  lastSigCol = color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tier(int s) =>
    s >= 3 ? "A" : s == 2 ? "B" : "C"

f_tierCol(bool up, int s) =>
    color base = up ? bullCol : bearCol
    color.new(base, s >= 3 ? 0 : s == 2 ? 25 : 50)

f_signed(float d) =>
    (d >= 0 ? "+" : "") + str.tostring(d, "0.00")

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// 3-point break quality score + tooltip breakdown
f_score(bool up, float lvl) =>
    bool  volOk  = hasVol ? rvol >= rvolMin : rng >= rangeMult * atr
    bool  bodyOk = bodyPct >= bodyMin and (up ? close > open : close < open)
    float dist   = (up ? close - lvl : lvl - close) / atr
    bool  distOk = dist >= distStrong
    int   s      = (volOk ? 1 : 0) + (bodyOk ? 1 : 0) + (distOk ? 1 : 0)
    string volTxt = hasVol ? "RVOL " + str.tostring(rvol, "0.00") + "×" : "Range " + str.tostring(rng / atr, "0.00") + " ATR (no volume)"
    string tip = volTxt + (volOk ? "  ✓" : "  ✗") + "\nBody " + str.tostring(bodyPct * 100, "0") + "%" + (bodyOk ? "  ✓" : "  ✗") + "\nClose beyond " + str.tostring(dist, "0.00") + " ATR" + (distOk ? "  ✓" : "  ✗")
    [s, tip]

f_sig(bool below, string txt, color c, string tip, string sz) =>
    label.new(bar_index, below ? low : high, txt, xloc = xloc.bar_index, yloc = below ? yloc.belowbar : yloc.abovebar, color = c, style = below ? label.style_label_up : label.style_label_down, textcolor = color.white, size = sz, tooltip = tip)

f_newLevel(float p, bool isRes, int startX, float zh) =>
    Level l  = Level.new(price = p, zh = zh, isRes = isRes, startBar = startX)
    int   x2 = bar_index + extendRight
    color c  = isRes ? resCol : supCol
    if use3D
        // outer glow → inner glow → drop shadow (drawn first, so they sit underneath)
        l.glowOuter := box.new(startX, p + zh, x2, p - zh, border_color = color(na), border_width = 0, bgcolor = color.new(c, 88))
        l.glowInner := box.new(startX, p + zh * 0.45, x2, p - zh * 0.45, border_color = color(na), border_width = 0, bgcolor = color.new(c, 76))
        l.shadow    := line.new(startX, p - zh * 0.22, x2, p - zh * 0.22, color = color.new(shadowCol, 35), width = 3)
    l.core := line.new(startX, p, x2, p, color = c, width = 2)
    if use3D
        // specular highlight on top edge of the core
        l.hilite := line.new(startX, p + zh * 0.10, x2, p + zh * 0.10, color = color.new(color.white, 70), width = 1)
    if showTags
        l.tag := label.new(x2, p, "", style = label.style_label_left, color = color.new(c, 15), textcolor = color.white, size = size.small)
    l

f_setRight(Level l, int x) =>
    if l.state == 0
        if not na(l.glowOuter)
            l.glowOuter.set_right(x)
        if not na(l.glowInner)
            l.glowInner.set_right(x)
        if not na(l.shadow)
            l.shadow.set_x2(x)
        if not na(l.core)
            l.core.set_x2(x)
        if not na(l.hilite)
            l.hilite.set_x2(x)
    else if l.state == 1
        if not na(l.flipBox)
            l.flipBox.set_right(x)
        if not na(l.flipLine)
            l.flipLine.set_x2(x)
    if not na(l.tag)
        l.tag.set_x(x)

f_width(Level l) =>
    int w = math.min(2 + l.touches, 5)
    if not na(l.core)
        l.core.set_width(w)
    if not na(l.shadow)
        l.shadow.set_width(w + 1)

f_tagText(Level l) =>
    if not na(l.tag)
        string role = l.state == 1 ? (l.isRes ? "R→S " : "S→R ") : (l.isRes ? "R " : "S ")
        string t    = role + str.tostring(l.price, format.mintick) + (l.touches > 0 ? "  ×" + str.tostring(l.touches) : "")
        l.tag.set_text(t)

f_fade(Level l) =>
    color c  = l.isRes ? resCol : supCol
    color fc = l.isRes ? supCol : resCol
    if not na(l.glowOuter)
        l.glowOuter.set_bgcolor(color.new(c, 95))
    if not na(l.glowInner)
        l.glowInner.set_bgcolor(color.new(c, 91))
    if not na(l.shadow)
        l.shadow.set_color(color.new(shadowCol, 80))
    if not na(l.hilite)
        l.hilite.set_color(color.new(color.white, 94))
    if not na(l.core)
        l.core.set_color(color.new(c, 45))
        l.core.set_width(1)
    if not na(l.flipBox)
        l.flipBox.set_bgcolor(color.new(fc, 94))
    if not na(l.flipLine)
        l.flipLine.set_color(color.new(fc, 50))
        l.flipLine.set_width(1)

f_kill(Level l) =>
    if not na(l.glowOuter)
        l.glowOuter.delete()
    if not na(l.glowInner)
        l.glowInner.delete()
    if not na(l.shadow)
        l.shadow.delete()
    if not na(l.core)
        l.core.delete()
    if not na(l.hilite)
        l.hilite.delete()
    if not na(l.flipBox)
        l.flipBox.delete()
    if not na(l.flipLine)
        l.flipLine.delete()
    if not na(l.tag)
        l.tag.delete()

f_freeze(Level l) =>
    f_setRight(l, bar_index)
    l.state := 2
    if not na(l.tag)
        l.tag.delete()
        l.tag := na
    if fadeHist
        f_fade(l)
    history.push(l)
    if history.size() > maxHist
        f_kill(history.shift())

// Qualified break → end the original segment, start a dashed flip-zone in the opposite role color
f_arm(Level l) =>
    f_setRight(l, bar_index)
    l.state    := 1
    l.breakBar := bar_index
    color fc = l.isRes ? supCol : resCol
    int   x2 = bar_index + extendRight
    if use3D
        l.flipBox := box.new(bar_index, l.price + l.zh, x2, l.price - l.zh, border_color = color(na), border_width = 0, bgcolor = color.new(fc, 85))
    l.flipLine := line.new(bar_index, l.price, x2, l.price, color = fc, width = 2, style = line.style_dashed)
    if not na(l.tag)
        l.tag.set_color(color.new(fc, 15))
    f_tagText(l)
    flipped.push(l)

f_row(table t, int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_color = color.new(color.white, 35), text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PER-BAR EVENT FLAGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool  bullBrk    = false
bool  bearBrk    = false
int   brkScore   = 0
float brkPrice   = na
bool  bullRetest = false
bool  bearRetest = false
bool  bullTrap   = false   // failed bullish break (bearish event)
bool  bearTrap   = false   // failed bearish break (bullish event)
bool  bullSweep  = false   // sweep below support (bullish event)
bool  bearSweep  = false   // sweep above resistance (bearish event)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1) LIVE RESISTANCE — break / touch / sweep
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if conf and not na(activeRes) and atr > 0
    float lvl = activeRes.price
    float tol = math.max(activeRes.zh, syminfo.mintick)
    if close > lvl + minThru * atr
        [s, tip] = f_score(true, lvl)
        if s >= minScore
            bullBrk  := true
            brkScore := s
            brkPrice := lvl
            f_sig(true, "▲ " + f_tier(s), f_tierCol(true, s), "Bullish break · Tier " + f_tier(s) + " (" + str.tostring(s) + "/3)\nLevel " + str.tostring(lvl, format.mintick) + "\n" + tip, size.small)
            if armRetest
                f_arm(activeRes)
            else
                f_freeze(activeRes)
        else
            f_freeze(activeRes)
        activeRes := na
    else
        if high >= lvl - tol and high[1] < lvl - tol
            activeRes.touches += 1
            f_width(activeRes)
        if showSweeps and high > lvl and close < lvl and high[1] <= lvl
            bearSweep := true
            f_sig(false, "SW", sweepCol, "Liquidity sweep above resistance " + str.tostring(lvl, format.mintick) + " — wicked through, closed back below", size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2) LIVE SUPPORT — break / touch / sweep
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if conf and not na(activeSup) and atr > 0
    float lvl = activeSup.price
    float tol = math.max(activeSup.zh, syminfo.mintick)
    if close < lvl - minThru * atr
        [s, tip] = f_score(false, lvl)
        if s >= minScore
            bearBrk  := true
            brkScore := s
            brkPrice := lvl
            f_sig(false, "▼ " + f_tier(s), f_tierCol(false, s), "Bearish break · Tier " + f_tier(s) + " (" + str.tostring(s) + "/3)\nLevel " + str.tostring(lvl, format.mintick) + "\n" + tip, size.small)
            if armRetest
                f_arm(activeSup)
            else
                f_freeze(activeSup)
        else
            f_freeze(activeSup)
        activeSup := na
    else
        if low <= lvl + tol and low[1] > lvl + tol
            activeSup.touches += 1
            f_width(activeSup)
        if showSweeps and low < lvl and close > lvl and low[1] >= lvl
            bullSweep := true
            f_sig(true, "SW", sweepCol, "Liquidity sweep below support " + str.tostring(lvl, format.mintick) + " — wicked through, closed back above", size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3) FLIPPED LEVELS — retest or trap within the watch window
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if conf and flipped.size() > 0
    for i = flipped.size() - 1 to 0
        Level l    = flipped.get(i)
        int   age  = bar_index - l.breakBar
        bool  done = age >= retestWin
        if age > 0
            float lvl = l.price
            float tol = math.max(l.zh, syminfo.mintick)
            if l.isRes
                // broken resistance, now acting as support
                if close < lvl - tol
                    done := true
                    if showTraps
                        bullTrap := true
                        f_sig(false, "TRAP", trapCol, "Failed bullish break — closed back below " + str.tostring(lvl, format.mintick), size.small)
                else if low <= lvl + tol and close > lvl
                    done := true
                    if showRetest
                        bullRetest := true
                        f_sig(true, "RT", retestCol, "Broken resistance retested and held as support at " + str.tostring(lvl, format.mintick), size.small)
            else
                // broken support, now acting as resistance
                if close > lvl + tol
                    done := true
                    if showTraps
                        bearTrap := true
                        f_sig(true, "TRAP", trapCol, "Failed bearish break — closed back above " + str.tostring(lvl, format.mintick), size.small)
                else if high >= lvl - tol and close < lvl
                    done := true
                    if showRetest
                        bearRetest := true
                        f_sig(false, "RT", retestCol, "Broken support retested and held as resistance at " + str.tostring(lvl, format.mintick), size.small)
        if done
            flipped.remove(i)
            f_freeze(l)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4) NEW PIVOTS → NEW LIVE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if conf and not na(ph) and atr > 0
    if not na(activeRes)
        f_freeze(activeRes)
    activeRes := f_newLevel(ph, true, bar_index - rightBars, atr * zoneMult)

if conf and not na(pl) and atr > 0
    if not na(activeSup)
        f_freeze(activeSup)
    activeSup := f_newLevel(pl, false, bar_index - rightBars, atr * zoneMult)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5) EXTEND LIVE DRAWINGS + TAGS (every tick)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int xr = bar_index + extendRight
if not na(activeRes)
    f_setRight(activeRes, xr)
    f_tagText(activeRes)
if not na(activeSup)
    f_setRight(activeSup, xr)
    f_tagText(activeSup)
if flipped.size() > 0
    for l in flipped
        f_setRight(l, xr)
        f_tagText(l)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6) LAST-SIGNAL TRACKING (lowest priority first; last write wins)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bullSweep
    lastSig    := "SW below support"
    lastSigBar := bar_index
    lastSigCol := sweepCol
if bearSweep
    lastSig    := "SW above resistance"
    lastSigBar := bar_index
    lastSigCol := sweepCol
if bullRetest
    lastSig    := "RT held (bull)"
    lastSigBar := bar_index
    lastSigCol := retestCol
if bearRetest
    lastSig    := "RT held (bear)"
    lastSigBar := bar_index
    lastSigCol := retestCol
if bullTrap
    lastSig    := "Bull trap"
    lastSigBar := bar_index
    lastSigCol := trapCol
if bearTrap
    lastSig    := "Bear trap"
    lastSigBar := bar_index
    lastSigCol := trapCol
if bullBrk
    lastSig    := "▲ Break · Tier " + f_tier(brkScore)
    lastSigBar := bar_index
    lastSigCol := bullCol
if bearBrk
    lastSig    := "▼ Break · Tier " + f_tier(brkScore)
    lastSigBar := bar_index
    lastSigCol := bearCol

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7) DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, 6, bgcolor = color.new(#0B0F17, 8), frame_color = color.new(accentCol, 30), frame_width = 1, border_color = color.new(#1F2937, 0), border_width = 1)
        table.cell(dash, 0, 0, "◆ S/R BREAKS  [NeBlok]", text_color = accentCol, text_size = size.small, bgcolor = color.new(#111827, 0))
        table.merge_cells(dash, 0, 0, 1, 0)

    string resTxt = "—"
    if not na(activeRes) and atr > 0
        resTxt := str.tostring(activeRes.price, format.mintick) + "   " + f_signed((activeRes.price - close) / atr) + " ATR"
    string supTxt = "—"
    if not na(activeSup) and atr > 0
        supTxt := str.tostring(activeSup.price, format.mintick) + "   " + f_signed((activeSup.price - close) / atr) + " ATR"
    string volTxt = hasVol ? str.tostring(rvol, "0.00") + "×" : "n/a (range mode)"
    string sigTxt = na(lastSigBar) ? "—" : lastSig + " · " + str.tostring(bar_index - lastSigBar) + " bars ago"

    f_row(dash, 1, "Resistance", resTxt, resCol)
    f_row(dash, 2, "Support", supTxt, supCol)
    f_row(dash, 3, "RVOL", volTxt, hasVol and rvol >= rvolMin ? bullCol : color.new(color.white, 20))
    f_row(dash, 4, "Last Signal", sigTxt, na(lastSigBar) ? color.gray : lastSigCol)
    f_row(dash, 5, "Retest Watch", str.tostring(flipped.size()) + " level(s)", retestCol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float resP = na
float supP = na
if not na(activeRes)
    resP := activeRes.price
if not na(activeSup)
    supP := activeSup.price
plot(resP, "Live Resistance", color = resCol, display = display.data_window)
plot(supP, "Live Support", color = supCol, display = display.data_window)
plot(bullBrk or bearBrk ? brkScore : na, "Break Score (0-3)", color = accentCol, display = display.data_window)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string ctx = " | " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick)
if bullBrk
    alert("NeBlok S/R: Bullish break · Tier " + f_tier(brkScore) + " of resistance " + str.tostring(brkPrice, format.mintick) + ctx, alert.freq_once_per_bar_close)
if bearBrk
    alert("NeBlok S/R: Bearish break · Tier " + f_tier(brkScore) + " of support " + str.tostring(brkPrice, format.mintick) + ctx, alert.freq_once_per_bar_close)
if bullRetest
    alert("NeBlok S/R: Broken resistance retested & held as support" + ctx, alert.freq_once_per_bar_close)
if bearRetest
    alert("NeBlok S/R: Broken support retested & held as resistance" + ctx, alert.freq_once_per_bar_close)
if bullTrap
    alert("NeBlok S/R: Bull trap — failed breakout" + ctx, alert.freq_once_per_bar_close)
if bearTrap
    alert("NeBlok S/R: Bear trap — failed breakdown" + ctx, alert.freq_once_per_bar_close)
if bullSweep
    alert("NeBlok S/R: Liquidity sweep below support" + ctx, alert.freq_once_per_bar_close)
if bearSweep
    alert("NeBlok S/R: Liquidity sweep above resistance" + ctx, alert.freq_once_per_bar_close)

alertcondition(bullBrk, "Bullish Break", "{{ticker}} {{interval}}: bullish S/R break at {{close}}")
alertcondition(bearBrk, "Bearish Break", "{{ticker}} {{interval}}: bearish S/R break at {{close}}")
alertcondition(bullRetest or bearRetest, "Retest Held", "{{ticker}} {{interval}}: flipped level retested and held at {{close}}")
alertcondition(bullTrap or bearTrap, "Trap (Failed Break)", "{{ticker}} {{interval}}: failed break at {{close}}")
alertcondition(bullSweep or bearSweep, "Liquidity Sweep", "{{ticker}} {{interval}}: liquidity sweep at {{close}}")
````
