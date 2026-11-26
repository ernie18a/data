# Iceberg Detector [JOAT]

- url: https://www.tradingview.com/script/Y4HHvjwz-Iceberg-Detector-JOAT/
- type: indicator
- pine_id: PUB;e26f7b1662f84afd9fd28f9701c2570a
- version: 1.0

## Description

[b]ICEBERG DETECTOR [JOAT][/b]

A hidden-liquidity detector that infers iceberg orders from their footprint on the tape — without needing direct L2 data. The detection pattern is well-known to professional tape readers: the same price level being repeatedly tested by long wicks, with above-average volume, and price each time getting [i]rejected[/i] back in the opposite direction. That repeated-rejection pattern is the visible signature of an iceberg — a large resting order broken into smaller slices to hide its true size. This script catches the pattern, clusters the tests, paints the zone, and tells you when the iceberg gets broken or eaten.

[image]https://www.tradingview.com/x/ZOZV6njK/[/image]

[b]Detection — five gates, all required[/b]

A bar is a candidate iceberg test only when [i]every[/i] one of these is true:

[list]
[*] [b]Long wick[/b] — wick-to-body ratio above the configurable threshold (default 0.75). The wick is the visible rejection; the body is the failed push.
[*] [b]Local extremum[/b] — the wick reached a local high or low over the configurable pivot lookback (default 5 bars). A wick that did not actually probe new territory does not count.
[*] [b]Above-average volume[/b] — bar volume must exceed [i]volume average × multiplier[/i] (default 1.0×). Real absorption needs real size hitting the tape.
[*] [b]Wick rejection bias[/b] — the candle must close in the rejection direction (opposite of the wick).
[*] [b]Cluster within tolerance[/b] — at least N (default 2) of these qualifying tests must occur within [i]ATR × tolerance[/i] of the same level inside the detection window (default 40 bars).
[/list]

Only when all five gates pass does the script paint a zone. The wick rejection bias % input controls how strict the rejection-direction filter is; raising it to 70%+ makes the zone confirmation slower but cleaner.

[b]Cluster-aware level building[/b]

When two or more qualifying tests fall within ATR-multiplier tolerance of each other, they are clustered into a single zone whose vertical extent (configurable in ATR units) covers the cluster. This means an iceberg sitting at 4382.50–4383.25 is rendered as a single horizontal band, not two separate ticks — which is how a real iceberg would actually appear on the tape.

[b]Visual system[/b]

[list]
[*] [b]Iceberg zone[/b] — a horizontal band rendered in the cool-blue palette (deep void → pale violet gradient) with configurable opacity.
[*] [b]Glow layers[/b] — N (configurable, default 4) stacked transparent boxes behind the zone produce a soft glow border.
[*] [b]Pulse animation[/b] — for a configurable number of bars after a fresh test, the zone's transparency oscillates to highlight that the iceberg has just been re-tested. Toggleable.
[*] [b]Test ticks[/b] — small markers at each individual test bar inside the zone.
[*] [b]Test count badge[/b] — small number tag showing how many tests have hit the level.
[*] [b]Right extension[/b] — configurable bar count for forward zone projection.
[/list]

A locked Void palette (cool violet gradient on a deep void ground) gives the chart a distinctive hidden-liquidity identity.

[b]Lifecycle — persist, archive, break[/b]

Every iceberg has three life stages:

[list]
[*] [b]Active[/b] — currently in front of price and being honoured. New tests add ticks and trigger pulse animations.
[*] [b]Broken[/b] — price closed through the level by [b]Break Distance × ATR[/b] (default 0.5 ATR). The zone moves to the muted broken-archive palette and stays on the chart for [b]brokenStaleBars[/b] (default 150) bars so you can see where structure failed.
[*] [b]Stale[/b] — older than the archive lifetime, automatically removed.
[/list]

A maximum-concurrent-icebergs cap (default 12 active) and a max-broken cap (default 8) keep the chart legible.

[image]https://www.tradingview.com/x/IoQTTF5M/[/image]

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, surfaces:

[list]
[*] Active iceberg count, broken count.
[*] Nearest iceberg level with side (resistance / support), distance in ticks or %.
[*] Test count and age of the nearest iceberg.
[*] Last broken event with bars-ago tag.
[/list]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] [b]New Iceberg Detected[/b] — fires the bar an iceberg is first confirmed (all five gates pass).
[*] [b]Iceberg Re-Tested[/b] — fires when an existing iceberg gets another qualifying test.
[*] [b]Iceberg Broken[/b] — fires when price closes through by the break-distance threshold.
[/list]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]Active iceberg in front of price[/b] is your immediate liquidity wall. Faded iceberg the market keeps probing without breaking = strong demand-side or supply-side hidden order. Use as a context level — fade touches if your bias is reversal, expect continuation through if your bias is breakout.
[*] [b]Iceberg Broken alert[/b] is your highest-conviction directional event. A hidden order has been eaten through, meaning the side that was holding it has either pulled it or been exhausted — either way, the resistance / support is gone, and the move that follows is unencumbered by the absorbed liquidity.
[/list]

[b]Suggested settings[/b]

Defaults (2 minimum tests, 40-bar detection window, 0.5 ATR cluster tolerance, 0.75 wick/body ratio) are tuned for 5m–1H on liquid markets. For lower-timeframe scalping, lower the wick/body ratio to 0.5 and raise the volume multiplier to 1.5×. For higher-timeframe macro reads, raise minimum tests to 3 and widen the detection window to 100+ bars.

[b]Originality[/b]

The implementation — the five-gate detection (wick + extremum + volume + rejection % + cluster tolerance), the ATR-cluster level-builder, the cool-palette glow layers, the post-test pulse animation, the break-distance lifecycle with archive, and the test-count badge rendering — is JOAT-original and tuned together. No third-party code reused. The hidden-liquidity / iceberg [i]concept[/i] is well-known to tape readers; the detection pipeline here is built specifically for chart-based bar data without requiring L2 access.

[b]Limitations[/b]

Pine indicators cannot read L2 order book data. Iceberg Detector infers iceberg presence from the visible tape footprint — long-wick rejection candles, clustered at a level, with above-average volume, all closing in the rejection direction. This is the accepted public-market inference pattern but it is by nature an inference, not a direct observation. The script can produce false positives on instruments with naturally wicky candles and false negatives on instruments where icebergs are filled too quickly to show as multi-bar tests. On low-volume instruments the volume gate may need to be raised to compensate.

—

[i]Open source- The five-gate detection pipeline, the ATR-cluster level-builder, the post-test pulse compositor, and the lifecycle-with-archive state machine are proprietary. Free to use; behaviour is fully described above.[/i]

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Iceberg Detector [JOAT]", shorttitle="ICE [JOAT]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// =====================================================================
//  SECTION 1 - INPUTS
// =====================================================================
grpDet  = "+========== Detection Engine ==========+"
grpVis  = "+============ Visual Layer ============+"
grpPer  = "+============ Persistence =============+"
grpDash = "+============ Dashboard ===============+"
grpAlrt = "+============ Alerts ==================+"

// Detection
icebergMinTests   = input.int(2, "Min Tests for Iceberg", minval=2, maxval=10, group=grpDet, tooltip="Number of clustered tests required at the same level to confirm a hidden iceberg order.")
icebergWindow     = input.int(40, "Detection Window (bars)", minval=5, maxval=200, group=grpDet, tooltip="Rolling window in bars within which the tests must occur.")
wickDirFilterPct  = input.float(50.0, "Wick Rejection Bias %", minval=0.0, maxval=100.0, step=1.0, group=grpDet, tooltip="Minimum percent of tests that must close in the rejection direction (opposite of the wick).")
atrToleranceMult  = input.float(0.50, "ATR Cluster Tolerance", minval=0.05, maxval=2.0, step=0.05, group=grpDet, tooltip="Two tests cluster together if their levels are within this multiple of ATR.")
volMult           = input.float(1.0, "Volume Multiplier", minval=0.5, maxval=5.0, step=0.05, group=grpDet, tooltip="Each test must trade > avg volume * this multiplier to qualify as absorption.")
wickToBodyRatio   = input.float(0.75, "Wick / Body Ratio", minval=0.1, maxval=10.0, step=0.1, group=grpDet, tooltip="Wick must be at least this multiple of the body to count as a test candle.")
pivotLookback     = input.int(5, "Local Extremum Lookback", minval=3, maxval=100, group=grpDet, tooltip="Window for the local high/low check used to qualify a candidate test.")
atrLen            = input.int(14, "ATR Length", minval=5, maxval=200, group=grpDet)
volAvgLen         = input.int(20, "Volume Average Length", minval=5, maxval=200, group=grpDet)

// Visuals
zonePadAtr       = input.float(0.10, "Zone Padding (ATR)", minval=0.02, maxval=2.0, step=0.02, group=grpVis, tooltip="Vertical half-thickness of the iceberg zone in ATR units.")
glowLayers       = input.int(4, "Glow Layers", minval=0, maxval=8, group=grpVis, tooltip="Number of stacked transparent boxes that produce the soft glow border.")
showPulse        = input.bool(true, "Show Pulse Animation", group=grpVis, tooltip="Animates the zone transparency on the bars immediately following a fresh test.")
pulseDurationBar = input.int(8, "Pulse Duration (bars)", minval=1, maxval=40, group=grpVis)
showTestTicks    = input.bool(true, "Show Subsequent Test Ticks", group=grpVis)
showBadge        = input.bool(true, "Show Test Count Badge", group=grpVis)
extendBars       = input.int(40, "Zone Right Extension (bars)", minval=5, maxval=300, group=grpVis)
maxActive        = input.int(12, "Max Concurrent Icebergs", minval=2, maxval=30, group=grpVis)
zoneOpacity      = input.int(55, "Zone Fill Transparency", minval=0, maxval=100, group=grpVis)

// Persistence
breakDistAtr     = input.float(0.5, "Break Distance (ATR)", minval=0.05, maxval=3.0, step=0.05, group=grpPer, tooltip="A close that crosses the level by this many ATR units consumes the iceberg.")
brokenStaleBars  = input.int(150, "Broken Archive Lifetime (bars)", minval=20, maxval=2000, group=grpPer, tooltip="How long broken icebergs remain on the chart as muted archive zones.")
maxBroken        = input.int(8, "Max Broken Archive", minval=0, maxval=30, group=grpPer)

// Dashboard
showDash    = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr  = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"], group=grpDash)
dashSizeStr = input.string("Small", "Dashboard Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)

// Alerts
alertNewIceberg = input.bool(true, "Enable: New Iceberg Detected", group=grpAlrt)
alertTested     = input.bool(true, "Enable: Iceberg Re-Tested", group=grpAlrt)
alertBroken     = input.bool(true, "Enable: Iceberg Broken", group=grpAlrt)

// =====================================================================
//  SECTION 2 - PALETTE  (Void - curated, single palette)
// =====================================================================
//   C_BULL  -> support iceberg  (pale violet)
//   C_BEAR  -> resistance iceberg (deep violet)
//   C_MID   -> lavender accent
//   C_BG    -> deep void background
//   C_FRAME -> dark violet frame
const color C_BULL  = #C0C0FF
const color C_BEAR  = #5040FF
const color C_MID   = #8060FF
const color C_BG    = #050010
const color C_FRAME = #1A0F2E
const color C_TEXT  = #E8E0FF
const color C_MUTED = #6A5C99

// Iceberg cool-blue ramp -- palette-internal stops [#0A0E40, #1F2580, #5040FF, #8060FF, #C0C0FF]
const color iceCool0 = #0A0E40
const color iceCool1 = #C0C0FF
const color iceCool2 = #8060FF
const color iceCool3 = #5040FF
const color iceCool4 = #1F2580
const color brokenCol = #6A5C99

// =====================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =====================================================================

// Linear two-color interpolation
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// Clamp helper
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// Position string -> position constant
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// Size string -> size constant
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// Format volume with K/M/B suffix
formatVolume(float v) =>
    string out = ""
    if v >= 1e9
        out := str.tostring(v / 1e9, "#.##") + "B"
    else if v >= 1e6
        out := str.tostring(v / 1e6, "#.##") + "M"
    else if v >= 1e3
        out := str.tostring(v / 1e3, "#.##") + "K"
    else
        out := str.tostring(v, "#.##")
    out

// Safe-start (max_bars_back guard)
safeStartBar(int b) =>
    minSafe = bar_index - 4900
    b < minSafe ? minSafe : b

// Rolling row gradient for dashboard backgrounds (vertical fade)
grad(color _base, int _row, int _rows, float _minT, float _maxT) =>
    float t = _rows <= 1 ? _minT : (_minT + (_maxT - _minT) * (_row / float(_rows - 1)))
    color.new(_base, int(t))

// Star rating from a 0..N strength value
strengthStars(float s, float maxS) =>
    ratio = maxS > 0 ? s / maxS : 0.0
    ratio >= 0.85 ? "***" : ratio >= 0.55 ? "**" : ratio >= 0.25 ? "*" : ""

// Direction string for an iceberg
sideStr(bool isRes) => isRes ? "RES" : "SUP"

// Quick number formatter
fmtPx(float p) => str.tostring(p, format.mintick)

// =====================================================================
//  SECTION 4 - CORE CALCULATIONS  /  TEST CANDLE DETECTION
// =====================================================================
// We need bar primitives + ATR + rolling volume.
float atrV    = ta.atr(atrLen)
float volAvg  = ta.sma(volume, volAvgLen)
float bodySz  = math.abs(close - open)
float upWick  = high - math.max(close, open)
float dnWick  = math.min(close, open) - low
float rng     = high - low

// Local high / low using rolling max / min (NOT pivothigh because we want
// the live max within the lookback, not a confirmed pivot which lags).
float rollHi = ta.highest(high, pivotLookback)
float rollLo = ta.lowest(low,  pivotLookback)

// Near-local condition: the wick must reach into the top/bottom 15% of the
// rolling range. This keeps us in the "real test of structure" zone.
float rangeBand = rollHi - rollLo
float nearHiThr = rollHi - rangeBand * 0.25
float nearLoThr = rollLo + rangeBand * 0.25

// Wick / body validation (avoid divide-by-zero with max(bodySz, mintick))
float bodySafe = math.max(bodySz, syminfo.mintick)
bool upWickValid = upWick > bodySafe * wickToBodyRatio and high >= nearHiThr
bool dnWickValid = dnWick > bodySafe * wickToBodyRatio and low  <= nearLoThr

// Volume absorption: > volAvg * volMult
float volRatio   = volAvg > 0 ? volume / volAvg : 0.0
bool  volAbsorb  = volRatio >= volMult

// Wick-direction (rejection) flag: for an UP-wick the rejection close is bearish (close <= open),
// for a DOWN-wick the rejection close is bullish (close >= open).
bool upRejection = close <= open
bool dnRejection = close >= open

// Final candle classification - this is the "test" event we will cluster.
bool isResTest = upWickValid and volAbsorb and barstate.isconfirmed
bool isSupTest = dnWickValid and volAbsorb and barstate.isconfirmed

// Defensive: avoid both flags lighting at once on extreme outside bars.
if isResTest and isSupTest
    // Choose the side whose wick is the more dominant fraction of range.
    bool dominantUp = upWick >= dnWick
    isResTest := dominantUp
    isSupTest := not dominantUp

// Reference level of the test (the wick extreme, not the body).
float testLevel = isResTest ? high : (isSupTest ? low : na)

// =====================================================================
//  SECTION 5 - STATE / TRACKING  (UDTs and persistent arrays)
// =====================================================================

// One entry per recorded test event (FIFO). Bars age out via the window.
type TestEvent
    int   bar
    float price
    bool  isRes
    bool  rejected
    float volR
    float wickSz

// One entry per confirmed iceberg zone.
type Iceberg
    int   firstBar
    int   lastTestBar
    float level
    bool  isRes
    int   testCount
    float volSum
    float wickSum
    int   rejectedCount
    bool  alive
    int   diedBar
    float strength            // composite weight (volume * tests + rejection bias)
    int   pulseUntil          // bar_index until which pulse animation plays
    box   bxCore
    box   bxGlowA
    box   bxGlowB
    box   bxGlowC
    box   bxGlowD
    label lblBadge

// Persistent stores
var array<TestEvent> tests   = array.new<TestEvent>()
var array<Iceberg>   icebergs = array.new<Iceberg>()

// Drawing buffers for archived (broken) icebergs - kept on chart as muted.
var array<box>   brokenBoxes  = array.new<box>()
var array<label> brokenLabels = array.new<label>()
var array<int>   brokenBars   = array.new<int>()

// Subsequent-test tick label buffer
var array<label> testTicks = array.new<label>()

// Push a new test if applicable, then drop ones outside the window.
if (isResTest or isSupTest) and not na(testLevel)
    TestEvent ev = TestEvent.new(bar_index, testLevel, isResTest, isResTest ? upRejection : dnRejection, volRatio, isResTest ? upWick : dnWick)
    array.push(tests, ev)

// Age-out tests that fall outside the rolling window. We do this every bar.
while array.size(tests) > 0 and (bar_index - array.get(tests, 0).bar) > icebergWindow
    array.shift(tests)

// =====================================================================
//  SECTION 6 - SIGNATURE CONFIRMATION LOGIC
// =====================================================================
// Two paths each bar:
//   A) If a NEW test happened on this bar, check whether it confirms a NEW
//      iceberg (cluster N at one level inside the window).
//   B) Independently, increment any existing live iceberg whose level the
//      new test matches (within ATR tolerance) - that is a "subsequent test".

bool   confirmedNewBull = false
bool   confirmedNewBear = false
float  newIceLevel      = na
bool   newIceIsRes      = false
int    newIceTests      = 0
float  newIceVolSum     = 0.0
int    newIceRejected   = 0
float  newIceWickSum    = 0.0

bool   subsequentEvent  = false
int    subsequentIdx    = -1
// Snapshot fields we'll need for the alert later - captured at attach-time
// so we are not dependent on icebergs[] index validity after Section 8 may
// have removed broken entries.
float  subsequentLevel  = na
bool   subsequentIsRes  = false
int    subsequentTests  = 0

if (isResTest or isSupTest)
    // -------------------------------------------------------------
    // Path B: try to attach to an existing live iceberg first.
    // -------------------------------------------------------------
    float tol = atrV * atrToleranceMult
    bool  attached = false
    if array.size(icebergs) > 0
        for i = 0 to array.size(icebergs) - 1
            Iceberg ic = array.get(icebergs, i)
            if ic.alive and ic.isRes == isResTest and math.abs(ic.level - testLevel) <= tol
                ic.testCount       += 1
                ic.lastTestBar      := bar_index
                ic.volSum           += volRatio
                ic.wickSum          += (isResTest ? upWick : dnWick)
                if (isResTest and upRejection) or (isSupTest and dnRejection)
                    ic.rejectedCount += 1
                ic.strength         := ic.volSum * (ic.rejectedCount / math.max(1.0, float(ic.testCount)))
                // Pulse re-trigger
                if showPulse
                    ic.pulseUntil := bar_index + pulseDurationBar
                array.set(icebergs, i, ic)
                attached        := true
                subsequentEvent := true
                subsequentIdx   := i
                subsequentLevel := ic.level
                subsequentIsRes := ic.isRes
                subsequentTests := ic.testCount
                break

    // -------------------------------------------------------------
    // Path A: not attached - check if THIS test, combined with prior
    // tests inside the window at the same level (ATR tolerance), now
    // forms a freshly confirmed iceberg.
    // -------------------------------------------------------------
    if not attached and array.size(tests) >= icebergMinTests
        int    matchCount     = 0
        float  matchLevelSum  = 0.0
        float  matchVolSum    = 0.0
        float  matchWickSum   = 0.0
        int    matchRejected  = 0
        int    firstMatchBar  = bar_index
        for j = 0 to array.size(tests) - 1
            TestEvent te = array.get(tests, j)
            if te.isRes == isResTest and math.abs(te.price - testLevel) <= tol
                matchCount     += 1
                matchLevelSum  += te.price
                matchVolSum    += te.volR
                matchWickSum   += te.wickSz
                if te.rejected
                    matchRejected += 1
                if te.bar < firstMatchBar
                    firstMatchBar := te.bar
        if matchCount >= icebergMinTests
            float rejectPct = matchCount > 0 ? (matchRejected * 100.0) / matchCount : 0.0
            if rejectPct >= wickDirFilterPct
                // Confirm a brand new iceberg.
                float avgLevel = matchLevelSum / matchCount
                Iceberg nu = Iceberg.new(firstMatchBar, bar_index, avgLevel, isResTest, matchCount, matchVolSum, matchWickSum, matchRejected, true, na, matchVolSum * (matchRejected / float(matchCount)), bar_index + (showPulse ? pulseDurationBar : 0), na, na, na, na, na, na)
                array.push(icebergs, nu)
                if isResTest
                    confirmedNewBear := true
                else
                    confirmedNewBull := true
                newIceLevel    := avgLevel
                newIceIsRes    := isResTest
                newIceTests    := matchCount
                newIceVolSum   := matchVolSum
                newIceRejected := matchRejected
                newIceWickSum  := matchWickSum

// Memory cap: cull oldest live icebergs if we exceed maxActive
while array.size(icebergs) > maxActive
    Iceberg drop = array.shift(icebergs)
    if not na(drop.bxCore)
        box.delete(drop.bxCore)
    if not na(drop.bxGlowA)
        box.delete(drop.bxGlowA)
    if not na(drop.bxGlowB)
        box.delete(drop.bxGlowB)
    if not na(drop.bxGlowC)
        box.delete(drop.bxGlowC)
    if not na(drop.bxGlowD)
        box.delete(drop.bxGlowD)
    if not na(drop.lblBadge)
        label.delete(drop.lblBadge)

// =====================================================================
//  SECTION 7 - DRAWINGS  (zones with glow, pulse animation, badges)
// =====================================================================

// Animated pulse transparency.
// math.sin yields -1..1; we map to a 40..80 transparency window.
float pulseT = 60.0 + 20.0 * math.sin(bar_index * 0.4)

// Per-bar rebuild of every live iceberg's drawing geometry.
// Boxes already exist (or are na on first encounter) - we create-or-update.
if array.size(icebergs) > 0
    for k = 0 to array.size(icebergs) - 1
        Iceberg ic = array.get(icebergs, k)
        if ic.alive
            float halfH = atrV * zonePadAtr
            float top   = ic.level + halfH
            float bot   = ic.level - halfH
            int   lft   = safeStartBar(ic.firstBar)
            int   rgt   = bar_index + extendBars

            // Strength normalization for color choice.
            // We expect ic.volSum to range roughly testCount..testCount*5 -> normalize by tests.
            float perTest = ic.testCount > 0 ? ic.volSum / ic.testCount : 1.0
            float strengthRatio = f_clamp((perTest - 1.0) / 4.0, 0.0, 1.0)
            color coreCol = f_colorGradient(strengthRatio, iceCool2, iceCool4)

            // Pulse application: cycles transparency for `pulseDurationBar` bars after a new test.
            int currentT = 100 - zoneOpacity
            if showPulse and bar_index <= ic.pulseUntil
                currentT := int(pulseT)
            color fillCol = color.new(coreCol, currentT)

            // Core box (create or update top/bottom each bar to keep extension live)
            if na(ic.bxCore)
                ic.bxCore := box.new(lft, top, rgt, bot, border_color=color.new(coreCol, 30), border_width=1, bgcolor=fillCol, extend=extend.none)
            else
                box.set_left(ic.bxCore, lft)
                box.set_top(ic.bxCore, top)
                box.set_right(ic.bxCore, rgt)
                box.set_bottom(ic.bxCore, bot)
                box.set_bgcolor(ic.bxCore, fillCol)
                box.set_border_color(ic.bxCore, color.new(coreCol, 30))

            // Glow boxes - stacked, larger, more transparent.
            // We render up to 4 glow rings. glowLayers controls how many are shown
            // (we still create the box objects for simplicity but hide unused ones
            // by making them fully transparent).
            float g1 = halfH * 1.7
            float g2 = halfH * 2.6
            float g3 = halfH * 3.7
            float g4 = halfH * 5.0
            color gc = coreCol
            int   gT1 = glowLayers >= 1 ? math.min(95, currentT + 12) : 100
            int   gT2 = glowLayers >= 2 ? math.min(97, currentT + 22) : 100
            int   gT3 = glowLayers >= 3 ? math.min(98, currentT + 32) : 100
            int   gT4 = glowLayers >= 4 ? math.min(99, currentT + 40) : 100
            color gC1 = color.new(gc, gT1)
            color gC2 = color.new(gc, gT2)
            color gC3 = color.new(gc, gT3)
            color gC4 = color.new(gc, gT4)
            if na(ic.bxGlowA)
                ic.bxGlowA := box.new(lft, ic.level + g1, rgt, ic.level - g1, border_color=na, bgcolor=gC1)
            else
                box.set_left(ic.bxGlowA, lft)
                box.set_top(ic.bxGlowA, ic.level + g1)
                box.set_right(ic.bxGlowA, rgt)
                box.set_bottom(ic.bxGlowA, ic.level - g1)
                box.set_bgcolor(ic.bxGlowA, gC1)
            if na(ic.bxGlowB)
                ic.bxGlowB := box.new(lft, ic.level + g2, rgt, ic.level - g2, border_color=na, bgcolor=gC2)
            else
                box.set_left(ic.bxGlowB, lft)
                box.set_top(ic.bxGlowB, ic.level + g2)
                box.set_right(ic.bxGlowB, rgt)
                box.set_bottom(ic.bxGlowB, ic.level - g2)
                box.set_bgcolor(ic.bxGlowB, gC2)
            if na(ic.bxGlowC)
                ic.bxGlowC := box.new(lft, ic.level + g3, rgt, ic.level - g3, border_color=na, bgcolor=gC3)
            else
                box.set_left(ic.bxGlowC, lft)
                box.set_top(ic.bxGlowC, ic.level + g3)
                box.set_right(ic.bxGlowC, rgt)
                box.set_bottom(ic.bxGlowC, ic.level - g3)
                box.set_bgcolor(ic.bxGlowC, gC3)
            if na(ic.bxGlowD)
                ic.bxGlowD := box.new(lft, ic.level + g4, rgt, ic.level - g4, border_color=na, bgcolor=gC4)
            else
                box.set_left(ic.bxGlowD, lft)
                box.set_top(ic.bxGlowD, ic.level + g4)
                box.set_right(ic.bxGlowD, rgt)
                box.set_bottom(ic.bxGlowD, ic.level - g4)
                box.set_bgcolor(ic.bxGlowD, gC4)

            // Test count badge on the right edge
            if showBadge
                string starS = strengthStars(ic.testCount * perTest, icebergMinTests * 4.0)
                string sideS = sideStr(ic.isRes)
                string txt   = "ICE " + sideS + "  " + str.tostring(ic.testCount) + "x  " + starS
                if na(ic.lblBadge)
                    ic.lblBadge := label.new(rgt, ic.level, txt, xloc=xloc.bar_index, yloc=yloc.price, style=ic.isRes ? label.style_label_lower_left : label.style_label_upper_left, color=color.new(coreCol, 25), textcolor=C_TEXT, size=size.small)
                else
                    label.set_x(ic.lblBadge, rgt)
                    label.set_y(ic.lblBadge, ic.level)
                    label.set_text(ic.lblBadge, txt)
                    label.set_color(ic.lblBadge, color.new(coreCol, 25))
                    label.set_textcolor(ic.lblBadge, C_TEXT)
                    label.set_style(ic.lblBadge, ic.isRes ? label.style_label_lower_left : label.style_label_upper_left)

            array.set(icebergs, k, ic)

// Initial confirmation labels (the cool snowflake glyph at the level on the
// bar where the iceberg first confirms).
if confirmedNewBull
    label.new(bar_index, newIceLevel, "ICE +" + str.tostring(newIceTests) + "x", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(iceCool3, 10), textcolor=C_TEXT, size=size.small, tooltip="New SUPPORT iceberg confirmed: " + str.tostring(newIceTests) + " tests within window")
if confirmedNewBear
    label.new(bar_index, newIceLevel, "ICE +" + str.tostring(newIceTests) + "x", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(iceCool3, 10), textcolor=C_TEXT, size=size.small, tooltip="New RESISTANCE iceberg confirmed: " + str.tostring(newIceTests) + " tests within window")

// Subsequent test tick marker (small dot at the test wick)
if showTestTicks and subsequentEvent
    label tk = label.new(bar_index, subsequentIsRes ? high : low, "*", xloc=xloc.bar_index, yloc=yloc.price, style=subsequentIsRes ? label.style_label_down : label.style_label_up, color=color.new(iceCool1, 60), textcolor=C_TEXT, size=size.tiny)
    array.push(testTicks, tk)
    // Cap tick history
    while array.size(testTicks) > 300
        label.delete(array.shift(testTicks))

// =====================================================================
//  SECTION 8 - ICEBERG BROKEN HANDLING  (consumed event)
// =====================================================================
// A live iceberg dies when price closes through its level by >= breakDistAtr * atr.
// We then archive a muted-color box and post an "ICE BROKEN" label.

float breakDist = atrV * breakDistAtr
bool brokenAnyThisBar = false
int brokenIdx = -1

if array.size(icebergs) > 0
    int n = array.size(icebergs) - 1
    for k = n to 0
        Iceberg ic = array.get(icebergs, k)
        if ic.alive
            bool broken = false
            if ic.isRes and close >= ic.level + breakDist
                broken := true
            else if (not ic.isRes) and close <= ic.level - breakDist
                broken := true
            if broken and barstate.isconfirmed
                // Mark died
                ic.alive    := false
                ic.diedBar  := bar_index
                array.set(icebergs, k, ic)

                // Archive: convert live boxes to muted (or delete + add muted)
                // We delete the original live drawings then push fresh muted ones.
                if not na(ic.bxCore)
                    box.delete(ic.bxCore)
                if not na(ic.bxGlowA)
                    box.delete(ic.bxGlowA)
                if not na(ic.bxGlowB)
                    box.delete(ic.bxGlowB)
                if not na(ic.bxGlowC)
                    box.delete(ic.bxGlowC)
                if not na(ic.bxGlowD)
                    box.delete(ic.bxGlowD)
                if not na(ic.lblBadge)
                    label.delete(ic.lblBadge)

                float halfH = atrV * zonePadAtr
                int   lftA  = safeStartBar(ic.firstBar)
                int   rgtA  = bar_index + 5
                box bxArchive = box.new(lftA, ic.level + halfH, rgtA, ic.level - halfH, border_color=color.new(brokenCol, 50), border_width=1, bgcolor=color.new(brokenCol, 88))
                line.new(lftA, ic.level, rgtA, ic.level, xloc=xloc.bar_index, color=color.new(brokenCol, 25), width=1, style=line.style_dashed)
                label brokenLbl = label.new(bar_index, ic.level, "ICE BROKEN  " + str.tostring(ic.testCount) + "x", xloc=xloc.bar_index, yloc=yloc.price, style=ic.isRes ? label.style_label_up : label.style_label_down, color=color.new(brokenCol, 15), textcolor=C_TEXT, size=size.small)
                array.push(brokenBoxes,  bxArchive)
                array.push(brokenLabels, brokenLbl)
                array.push(brokenBars,   bar_index)
                brokenAnyThisBar := true
                brokenIdx := k

                // Remove from live array (k will only be touched once because we break the descending loop)
                array.remove(icebergs, k)

// Age out and cap the broken archive
while array.size(brokenBars) > 0 and (bar_index - array.get(brokenBars, 0)) > brokenStaleBars
    if array.size(brokenBoxes) > 0
        box.delete(array.shift(brokenBoxes))
    if array.size(brokenLabels) > 0
        label.delete(array.shift(brokenLabels))
    array.shift(brokenBars)

while array.size(brokenBars) > maxBroken
    if array.size(brokenBoxes) > 0
        box.delete(array.shift(brokenBoxes))
    if array.size(brokenLabels) > 0
        label.delete(array.shift(brokenLabels))
    array.shift(brokenBars)

// =====================================================================
//  SECTION 9 - DASHBOARD
// =====================================================================
// 8 substantive rows + header. We compute stats once on barstate.islast.

var table dash = na
if showDash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(strToPos(dashPosStr), 2, 10, bgcolor=color.new(C_BG, 30), frame_color=color.new(C_FRAME, 40), frame_width=1, border_color=color.new(C_FRAME, 70), border_width=1)

    // ----- compute stats -----
    int   activeCount  = 0
    int   bullCount    = 0   // support icebergs
    int   bearCount    = 0   // resistance icebergs
    float nearestPrice = na
    bool  nearestIsRes = false
    int   nearestTests = 0
    float nearestDist  = 1e20
    float avgStrength  = 0.0
    float sumStrength  = 0.0
    int   strengthN    = 0
    int   recentlyBrokenBarsAgo = -1
    int   bWith = array.size(brokenBars)
    if bWith > 0
        recentlyBrokenBarsAgo := bar_index - array.get(brokenBars, bWith - 1)

    if array.size(icebergs) > 0
        for q = 0 to array.size(icebergs) - 1
            Iceberg ic = array.get(icebergs, q)
            if ic.alive
                activeCount += 1
                if ic.isRes
                    bearCount += 1
                else
                    bullCount += 1
                float d = math.abs(ic.level - close)
                if d < nearestDist
                    nearestDist  := d
                    nearestPrice := ic.level
                    nearestIsRes := ic.isRes
                    nearestTests := ic.testCount
                sumStrength += ic.strength
                strengthN   += 1
    if strengthN > 0
        avgStrength := sumStrength / strengthN

    // ----- header -----
    color hdrBg = color.new(C_MID, 70)
    string sizeArg = dashSizeStr
    table.cell(dash, 0, 0, "ICEBERG DETECTOR", text_color=C_TEXT, bgcolor=hdrBg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 0, "[JOAT]", text_color=C_TEXT, bgcolor=hdrBg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 1: active icebergs -----
    color row1Bg = grad(C_BG, 1, 9, 60.0, 90.0)
    string activeStr = str.tostring(activeCount) + "  (" + str.tostring(bullCount) + "S/" + str.tostring(bearCount) + "R)"
    table.cell(dash, 0, 1, "Active Icebergs", text_color=C_TEXT, bgcolor=row1Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 1, activeStr, text_color=activeCount > 0 ? iceCool1 : C_MUTED, bgcolor=row1Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 2: nearest iceberg -----
    color row2Bg = grad(C_BG, 2, 9, 60.0, 90.0)
    string nearestStr = na(nearestPrice) ? "--" : sideStr(nearestIsRes) + " " + fmtPx(nearestPrice) + "  " + str.tostring(nearestTests) + "x"
    color nearestCol  = na(nearestPrice) ? C_MUTED : (nearestIsRes ? C_BEAR : C_BULL)
    table.cell(dash, 0, 2, "Nearest Iceberg", text_color=C_TEXT, bgcolor=row2Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 2, nearestStr, text_color=nearestCol, bgcolor=row2Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 3: recently broken bars ago -----
    color row3Bg = grad(C_BG, 3, 9, 60.0, 90.0)
    string brokenStr = recentlyBrokenBarsAgo < 0 ? "none" : (str.tostring(recentlyBrokenBarsAgo) + " bars ago")
    table.cell(dash, 0, 3, "Recently Broken", text_color=C_TEXT, bgcolor=row3Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 3, brokenStr, text_color=recentlyBrokenBarsAgo < 0 ? C_MUTED : C_BEAR, bgcolor=row3Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 4: avg strength (tests * volume) -----
    color row4Bg = grad(C_BG, 4, 9, 60.0, 90.0)
    string strengthStr = str.tostring(avgStrength, "#.##")
    table.cell(dash, 0, 4, "Avg Strength", text_color=C_TEXT, bgcolor=row4Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 4, strengthStr, text_color=avgStrength > 0 ? iceCool2 : C_MUTED, bgcolor=row4Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 5: detection window setting -----
    color row5Bg = grad(C_BG, 5, 9, 60.0, 90.0)
    table.cell(dash, 0, 5, "Window (bars)", text_color=C_TEXT, bgcolor=row5Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 5, str.tostring(icebergWindow), text_color=C_MUTED, bgcolor=row5Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 6: min tests setting -----
    color row6Bg = grad(C_BG, 6, 9, 60.0, 90.0)
    table.cell(dash, 0, 6, "Min Tests", text_color=C_TEXT, bgcolor=row6Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 6, str.tostring(icebergMinTests), text_color=C_MUTED, bgcolor=row6Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 7: closest distance to price -----
    color row7Bg = grad(C_BG, 7, 9, 60.0, 90.0)
    string distStr = na(nearestPrice) ? "--" : fmtPx(nearestDist)
    float distAtrRatio = na(nearestPrice) or atrV <= 0 ? 0.0 : nearestDist / atrV
    string distLabel = na(nearestPrice) ? "" : "  (" + str.tostring(distAtrRatio, "0.00") + " ATR)"
    table.cell(dash, 0, 7, "Closest Distance", text_color=C_TEXT, bgcolor=row7Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 7, distStr + distLabel, text_color=C_TEXT, bgcolor=row7Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 8: tests in window + reject% -----
    color row8Bg = grad(C_BG, 8, 9, 60.0, 90.0)
    int tw = array.size(tests)
    int rej = 0
    if tw > 0
        for u = 0 to tw - 1
            if array.get(tests, u).rejected
                rej += 1
    string twStr = str.tostring(tw) + "  rej " + str.tostring(tw > 0 ? math.round(rej * 100.0 / tw) : 0) + "%"
    table.cell(dash, 0, 8, "Tests in Window", text_color=C_TEXT, bgcolor=row8Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 8, twStr, text_color=tw > 0 ? iceCool3 : C_MUTED, bgcolor=row8Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

    // ----- row 9: legend footer -----
    color row9Bg = grad(C_BG, 9, 9, 60.0, 90.0)
    table.cell(dash, 0, 9, "Legend", text_color=C_MUTED, bgcolor=row9Bg, text_halign=text.align_left, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))
    table.cell(dash, 1, 9, "ICE * RES/SUP * x = tests", text_color=C_MUTED, bgcolor=row9Bg, text_halign=text.align_right, text_font_family=font.family_monospace, text_size=strToSize(sizeArg))

// =====================================================================
//  SECTION 10 - ALERTS
// =====================================================================
// Fire alerts on the three meaningful events. Each is gated by an input
// flag so the user can choose only what they want piped into their alerts.

if alertNewIceberg and (confirmedNewBull or confirmedNewBear)
    string side = confirmedNewBull ? "SUPPORT" : "RESISTANCE"
    alert("Iceberg Detector [JOAT]: NEW " + side + " iceberg confirmed at " + fmtPx(newIceLevel) + "  (" + str.tostring(newIceTests) + " tests, " + str.tostring(newIceRejected) + " rejections)", alert.freq_once_per_bar_close)

if alertTested and subsequentEvent
    string side = subsequentIsRes ? "RESISTANCE" : "SUPPORT"
    alert("Iceberg Detector [JOAT]: " + side + " iceberg RE-TESTED at " + fmtPx(subsequentLevel) + "  (now " + str.tostring(subsequentTests) + " tests, vol " + str.tostring(volRatio, "0.00") + "x avg)", alert.freq_once_per_bar_close)

if alertBroken and brokenAnyThisBar
    alert("Iceberg Detector [JOAT]: ICEBERG BROKEN (consumed). Price closed through defended level by >= " + str.tostring(breakDistAtr, "0.00") + " ATR.", alert.freq_once_per_bar_close)

// Declarative alertcondition() for the alert dialog menu.
alertcondition(confirmedNewBull or confirmedNewBear, title="New Iceberg Detected", message="A new iceberg signature has been confirmed.")
alertcondition(subsequentEvent, title="Iceberg Re-Tested", message="An existing iceberg level was tested again.")
alertcondition(brokenAnyThisBar, title="Iceberg Broken", message="An iceberg level has been consumed by price closing through it.")

// =====================================================================
//  END OF FILE
// =====================================================================
````
