# Wyckoff Range Detector 3D [Neblok]

- url: https://www.tradingview.com/script/PYoxpj6Y-Wyckoff-Range-Detector-3D-Neblok/
- type: indicator
- pine_id: PUB;f52fba6c627b412b86533565f19f5b01
- version: 1.0

## Description

WYCKOFF RANGE DETECTOR 3D [Neblok]

Wyckoff analysis is one of the most respected ways to read what large players are doing, but drawing the ranges and labeling the events by hand is slow and subjective. Wyckoff Range Detector 3D does it automatically. It finds accumulation and distribution ranges, labels each Wyckoff event as it happens, tracks the current phase, and shows how often the key signals have actually worked on the chart you're viewing.

The chart is kept clean on purpose: short labels, only recent ranges, and failed setups removed automatically. You see the structure that matters without the clutter.

━━━━━━━━━━━━━━━━━━━━
WYCKOFF IN 60 SECONDS
━━━━━━━━━━━━━━━━━━━━

Large operators can't buy or sell their full size at once, so they build positions inside trading ranges. Wyckoff mapped the typical sequence of events inside those ranges.

ACCUMULATION (smart money buying, before a move up)
- SC – Selling Climax: panic selling on huge volume that marks the low.
- AR – Automatic Rally: the bounce after the climax. The SC low and AR high set the range.
- ST – Secondary Test: price retests the SC area, ideally on lower volume.
- SPRING – a break below the range that quickly snaps back inside. It traps late sellers and shakes out weak holders.
- TEST – a retest of the spring area on lower volume, confirming selling has dried up.
- SOS – Sign of Strength: a strong breakout above the range.
- LPS – Last Point of Support: the first pullback that holds after the breakout.

DISTRIBUTION (smart money selling, before a move down)
- BC – Buying Climax, AR – Automatic Reaction, ST – Secondary Test
- UTAD – Upthrust After Distribution: a break above the range that quickly fails back inside
- TEST – a retest of the UTAD area on lower volume
- SOW – Sign of Weakness: a strong breakdown below the range
- LPSY – Last Point of Supply: the first rally that fails after the breakdown

PHASES
- Phase A: climax, AR, and first secondary tests. The prior trend stops.
- Phase B: building the cause. Price rotates inside the range.
- Phase C: the Spring or UTAD. The final shakeout.
- Phase D: SOS or SOW. Price leaves the range.
- Phase E: markup or markdown. The new trend is underway.

━━━━━━━━━━━━━━━━━━━━
HOW THE DETECTOR WORKS
━━━━━━━━━━━━━━━━━━━━

1. CLIMAX
The script scans for a climax bar that meets all of these:
- Unusually high volume (measured against recent volume).
- A wide bar in ATR terms.
- A fresh low (SC) or high (BC) over the lookback period.
- A close on the trend side of the EMA.
If price pushes past the climax in the next few bars, the label moves to the true extreme.

2. RANGE CONFIRMATION
The first pivot that moves far enough away from the climax (Min Range Height) becomes the AR. The range is drawn between the climax and the AR. If no valid AR forms within the time limit, the climax is discarded and its label removed.

3. EVENTS
- ST: pivots that retest the climax side of the range without breaking it.
- SPRING / UTAD: price breaks the range edge and closes back inside within the Reclaim Window. By default, a Spring or UTAD only counts after at least one ST has formed, matching Wyckoff's Phase C. A break-and-reclaim before the first ST just extends the climax low or high, as happens naturally in Phase A.
- TEST: the first lower-volume pivot back near the spring area that holds above the spring low.
- SOS / SOW: a close beyond the opposite side of the range on a bar with real effort (above-average volume or a full-ATR range). Low-volume drift through the range edge does not count. A projected target is drawn at 1× the range height (adjustable).
- LPS / LPSY: the first pullback after the breakout that holds beyond the range midline. This is the classic Wyckoff entry.

4. FAILURES
- A decisive close past the range edge without a reclaim, or a breakout that falls back below the midline, ends the range as failed.
- By default, failed and expired ranges are removed from the chart to keep it clean, but they are still counted in the dashboard. Turn on "Show Failed / Expired Ranges" to see them with ✖ labels.

━━━━━━━━━━━━━━━━━━━━
HOW TO READ THE CHART
━━━━━━━━━━━━━━━━━━━━

RANGE BLOCKS
- Green 3D block = accumulation range.
- Pink 3D block = distribution range.
- The phase label at the top-left shows the live phase, e.g. "ACCUMULATION · PHASE C". Completed ranges show their outcome: MARKUP or MARKDOWN.
- Dashed midline = the middle of the range. Breakouts that fall back past it count as failed.
- Dashed target line = projected breakout target with its price.

LABELS
- Cyan = climax (SC / BC).
- Green / pink = range events (AR, ST, TEST, SOS / SOW).
- Larger ▲ LPS / ▼ LPSY labels = entry zones after a confirmed breakout.
- Orange ✖ = failures (only when failed ranges are shown).
Each range's labels are removed together with the range, so old history never piles up.

SIGNAL TRIANGLES
- Yellow ▲ below a bar = Spring confirmed.
- Yellow ▼ above a bar = UTAD confirmed.
- Green ▲ = LPS confirmed. Pink ▼ = LPSY confirmed.
Springs and UTADs are shown as triangles by default. Turn on "Show Spring / UTAD Labels" if you also want text labels.

DASHBOARD
- STATUS: scanning for a climax, climax found, or the live range and its phase.
- RANGE: range low and high, and its height in ATRs.
- EVENTS: checklist of which events have printed in the current range.
- SPRING → SOS: how often springs led to an SOS breakout on this chart.
- UTAD → SOW: how often UTADs led to an SOW breakdown.
- RANGES: total accumulation and distribution ranges found, and how many held vs. failed.

The dashboard statistics are the most important part of the tool. They show whether Wyckoff structure is actually working on the instrument and timeframe you're trading.

━━━━━━━━━━━━━━━━━━━━
SIGNAL TIMING
━━━━━━━━━━━━━━━━━━━━

- SPRING, UTAD, SOS, SOW, and failures confirm on the bar they happen, at bar close.
- AR, ST, TEST, LPS, and LPSY use pivots, so they confirm "Pivot Strength" bars after the actual turning point. The label is placed on the true pivot bar.
- Nothing repaints after it prints.

━━━━━━━━━━━━━━━━━━━━
SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━

CLIMAX DETECTION
- Climax Effort (z-score): how extreme volume must be. Higher = fewer, stronger climaxes. Default 2.5.
- Climax Bar Range (× ATR): minimum size of the climax bar.
- Fresh Extreme Lookback: the climax must make the lowest low or highest high of this many bars.
- Trend EMA Length: SC must close below the EMA, BC above it.
- Effort Baseline Length: how many bars define "normal" volume.
On symbols without volume, bar range is used as effort instead.

RANGE RULES
- Pivot Strength: bars on each side needed to confirm a pivot. Higher = cleaner but later.
- Min Range Height (× ATR): filters out ranges too small to trade. Default 3.0.
- Max Bars To Find AR / Max Range Duration: time limits that discard stale setups.

EVENT RULES
- ST Zone / Test Zone: how close to the climax side of the range a pivot must be to count.
- Require ST Before Spring / UTAD: on by default. Keeps springs in Phase C where they belong.
- Spring / UTAD Reclaim Window: bars allowed for price to close back inside after breaking the edge.
- Decisive Break Distance: a close this far outside the range ends it as failed.
- SOS / SOW Close Beyond Range: how far past the range a close must be to count as a breakout.
- Min SOS / SOW Effort: the breakout bar needs at least this much volume effort, or a full ATR range.
- Max Bars To Find LPS / LPSY: after this, the range is marked as markup or markdown without an LPS.
- Target Projection: target distance as a multiple of the range height.

DISPLAY
- Past Ranges To Keep: how many completed ranges stay on the chart (default 3).
- Show Failed / Expired Ranges: off by default for a clean chart.
- Show Spring / UTAD Labels: off by default (yellow triangles still mark them).
- Detailed Labels: adds a second line with extra info, such as effort z-score, spring depth in ATRs, and "low vol" vs. "shakeout".
- Midline, target, and triangles can each be turned on or off.
- Event Label Size and Signal Label Size: Small, Normal, Large, or Huge.

3D / COLORS / DASHBOARD
- 3D Depth / Lift: size of the 3D effect.
- All colors are flat neon and fully adjustable.
- Dashboard position and text size are adjustable.

━━━━━━━━━━━━━━━━━━━━
CHOOSING A TIMEFRAME
━━━━━━━━━━━━━━━━━━━━

Wyckoff structure needs enough bars for a real range to develop. On 1-minute charts, ordinary volume spikes can look like climaxes, so you'll get more ranges and weaker signals.

Suggested starting points:
- Index futures intraday (5m to 15m): default settings.
- Intraday swing (30m to 4H): Pivot Strength 5, Max Range Duration 300 to 500.
- Swing / position (Daily): Pivot Strength 5 to 8, Climax z 2.0 to 2.5, Max Range Duration 200+.

If you trade a 1-minute chart, raise Climax Effort to 3.0 and Min Range Height to 4 ATR. Check the dashboard: if Spring → SOS and UTAD → SOW stay low, move up a timeframe. Let the statistics decide where the tool works best on your market.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT IN YOUR TRADING
━━━━━━━━━━━━━━━━━━━━

1. CONTEXT FIRST
A live range means the market is in balance. Avoid chasing moves in Phase A and B; this is where most false breakouts happen.

2. SPRINGS AND UTADS
These are the highest-reward events, but also the riskiest. A low-volume spring (little selling pressure) is the classic setup. Many traders wait for the TEST before acting. The spring low (or UTAD high) gives a natural stop location.

3. LPS / LPSY ENTRIES
The most conservative Wyckoff entry. The breakout has already happened, and price has pulled back and held. Stops typically go below the LPS (or above the LPSY), with the projected target as a reference.

4. FAILED RANGES
Turn on failed ranges occasionally to study them. A failed accumulation often leads to continuation of the prior downtrend, and a failed distribution to continuation of the prior uptrend.

5. TRUST THE NUMBERS
If springs on your instrument and timeframe rarely lead to an SOS, give them less weight there. The dashboard tells you which signals deserve your attention on that market.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━

Create an alert on the indicator and select "Any alert() function call." Two groups can be turned on or off:
- Signals: Spring, UTAD, SOS, SOW, LPS, LPSY
- Structure: climax detected, range confirmed, range failed
All alerts fire once per bar close and include the price and symbol.

━━━━━━━━━━━━━━━━━━━━
NOTES & LIMITATIONS
━━━━━━━━━━━━━━━━━━━━

- Wyckoff analysis is interpretive. This script applies fixed, transparent rules to a framework that experienced traders read with discretion. Not every range will match a textbook schematic.
- One range is tracked at a time. A new climax is not searched for until the current range finishes.
- Pivot-based events confirm with a delay equal to Pivot Strength.
- Statistics are based on the loaded chart history. More history = more meaningful results.
- This is a free script. Feedback and suggestions are welcome in the comments.

━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━

This indicator is provided for educational and informational purposes only. It is NOT financial advice, investment advice, trading advice, or a recommendation to buy, sell, or hold any security, futures contract, option, cryptocurrency, or other financial instrument.

All events, signals, targets, and statistics are generated from historical price and volume data using fixed rules, and they do not guarantee future results. Past performance is not indicative of future performance.

Trading involves substantial risk of loss and is not suitable for every investor. Leveraged products such as futures and options can result in losses greater than your initial investment. Only trade with money you can afford to lose.

You are solely responsible for your own trading decisions. Always do your own research, test any tool thoroughly on a demo or paper account before using it with real money, and consult a licensed financial professional if you need personalized advice. The author accepts no liability for any losses or damages arising from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
indicator("Wyckoff Range Detector 3D [Neblok]", shorttitle = "Wyckoff 3D [Neblok]", overlay = true, max_boxes_count = 200, max_lines_count = 300, max_labels_count = 500, max_polylines_count = 100)

// =====================================================================
//  Wyckoff Range Detector 3D [Neblok]
//  Automatically finds Wyckoff accumulation and distribution ranges and
//  labels their events as they happen:
//
//  ACCUMULATION: SC → AR → ST → SPRING → TEST → SOS → LPS
//  DISTRIBUTION: BC → AR → ST → UTAD   → TEST → SOW → LPSY
//
//  One state machine runs both schematics. Distribution is handled by
//  mirroring prices (x → -x), so both sides use identical rules.
//  "Effort" = volume, or bar range on symbols without volume.
// =====================================================================

// ── Input groups ──────────────────────────────────────────────────────
string G_CLM = "Climax Detection"
string G_RNG = "Range Rules"
string G_EVT = "Event Rules"
string G_DSP = "Display"
string G_3D  = "3D Rendering"
string G_COL = "Neon Colors"
string G_TBL = "Dashboard"
string G_ALR = "Alerts"

// ── Climax ────────────────────────────────────────────────────────────
climaxZ   = input.float(2.5, "Climax Effort (z-score)", minval = 0.5, step = 0.1, group = G_CLM, tooltip = "How unusual the volume (or range, if no volume) must be versus its recent average. Higher = fewer, stronger climaxes.")
climaxRng = input.float(1.2, "Climax Bar Range (× ATR)", minval = 0.0, step = 0.1, group = G_CLM)
trendLook = input.int(50, "Fresh Extreme Lookback (bars)", minval = 5, group = G_CLM, tooltip = "A selling climax must make the lowest low (buying climax: highest high) of this many bars.")
emaLen    = input.int(50, "Trend EMA Length", minval = 5, group = G_CLM, tooltip = "Selling climax must close below this EMA (downtrend); buying climax above it (uptrend).")
volLen    = input.int(50, "Effort Baseline Length", minval = 10, group = G_CLM)
atrLen    = input.int(14, "ATR Length", minval = 1, group = G_CLM)

// ── Range ─────────────────────────────────────────────────────────────
pivLen       = input.int(5, "Pivot Strength (bars each side)", minval = 2, maxval = 20, group = G_RNG, tooltip = "Pivot-based events (AR, ST, TEST, LPS/LPSY) are confirmed this many bars after the pivot.")
minRangeAtr  = input.float(3.0, "Min Range Height (× ATR)", minval = 0.5, step = 0.25, group = G_RNG)
arMaxBars    = input.int(60, "Max Bars To Find AR", minval = 5, group = G_RNG)
maxRangeBars = input.int(400, "Max Range Duration (bars)", minval = 20, group = G_RNG)

// ── Events ────────────────────────────────────────────────────────────
stZone      = input.float(0.35, "ST Zone (fraction of range)", minval = 0.05, maxval = 0.9, step = 0.05, group = G_EVT, tooltip = "Secondary tests must form within this fraction of the range height from the climax side.")
maxST       = input.int(2, "Max ST Labels Per Range", minval = 0, maxval = 5, group = G_EVT)
requireST   = input.bool(true, "Require ST Before Spring / UTAD", group = G_EVT, tooltip = "Wyckoff springs happen in Phase C, after the range has been tested. With this on, a break-and-reclaim before the first ST just extends the climax low/high instead of counting as a Spring/UTAD.")
reclaimBars = input.int(5, "Spring / UTAD Reclaim Window (bars)", minval = 1, maxval = 30, group = G_EVT, tooltip = "After price breaks the range edge, it must close back inside within this many bars to count as a Spring / UTAD.")
breakAtr    = input.float(0.5, "Decisive Break Distance (× ATR)", minval = 0.1, step = 0.1, group = G_EVT, tooltip = "A close this far beyond the range edge ends the range as failed.")
testZone    = input.float(0.4, "Test Zone (fraction of range)", minval = 0.05, maxval = 0.9, step = 0.05, group = G_EVT)
sosBufAtr   = input.float(0.1, "SOS / SOW Close Beyond Range (× ATR)", minval = 0.0, step = 0.05, group = G_EVT)
sosMinZ     = input.float(0.5, "Min SOS / SOW Effort (z-score)", step = 0.1, group = G_EVT, tooltip = "The breakout bar needs at least this much effort, or a range of 1 ATR or more. Filters out drifting, low-volume breakouts.")
lpsMaxBars  = input.int(60, "Max Bars To Find LPS / LPSY", minval = 5, group = G_EVT)
projMult    = input.float(1.0, "Target Projection (× range height)", minval = 0.25, step = 0.25, group = G_EVT)
projBars    = input.int(40, "Target Line Length (bars)", minval = 5, maxval = 300, group = G_EVT)

// ── Display ───────────────────────────────────────────────────────────
maxRanges     = input.int(3, "Past Ranges To Keep", minval = 1, maxval = 40, group = G_DSP, tooltip = "Each range's labels are removed together with the range.")
showFailed    = input.bool(false, "Show Failed / Expired Ranges", group = G_DSP, tooltip = "Off = failed and expired ranges are removed from the chart (they are still counted in the dashboard).")
showSpringLbl = input.bool(false, "Show Spring / UTAD Labels", group = G_DSP, tooltip = "Off = Springs / UTADs are marked only by yellow triangles.")
detailLbl     = input.bool(false, "Detailed Labels", group = G_DSP, tooltip = "Adds a second line to labels (effort z-score, spring depth, etc.).")
showMid       = input.bool(true, "Show Range Midline", group = G_DSP)
showTarget    = input.bool(true, "Show Breakout Target", group = G_DSP)
showMarkers   = input.bool(true, "Show Signal Triangles", group = G_DSP)
labelSizeIn   = input.string("Normal", "Event Label Size", options = ["Small", "Normal", "Large", "Huge"], group = G_DSP)
signalSizeIn  = input.string("Large", "LPS / LPSY / Spring Label Size", options = ["Small", "Normal", "Large", "Huge"], group = G_DSP)

// ── 3D ────────────────────────────────────────────────────────────────
show3D    = input.bool(true, "3D Range Blocks", group = G_3D)
depthBars = input.int(6, "3D Depth (bars)", minval = 1, maxval = 40, group = G_3D)
liftAtr   = input.float(0.4, "3D Lift (× ATR)", minval = 0.0, step = 0.05, group = G_3D)

// ── Colors (flat neon, no gradients) ──────────────────────────────────
accCol   = input.color(#39FF14, "Accumulation Neon", group = G_COL)
distCol  = input.color(#FF1E8C, "Distribution Neon", group = G_COL)
sigCol   = input.color(#FFF01F, "Spring / UTAD Neon", group = G_COL)
climCol  = input.color(#00F0FF, "Climax Neon", group = G_COL)
failCol  = input.color(#FF7A00, "Failure Neon", group = G_COL)
panelCol = input.color(#05060D, "Panel Background", group = G_COL)

// ── Dashboard ─────────────────────────────────────────────────────────
showTable   = input.bool(true, "Show Dashboard", group = G_TBL)
tablePosIn  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_TBL)
tableSizeIn = input.string("Normal", "Text Size", options = ["Small", "Normal", "Large", "Huge"], group = G_TBL)

// ── Alerts ────────────────────────────────────────────────────────────
alertSig    = input.bool(true, "Alert: Spring / UTAD / SOS / SOW / LPS / LPSY", group = G_ALR)
alertStruct = input.bool(true, "Alert: Climax, Range Confirmed, Range Failed", group = G_ALR)

// =====================================================================
//  Types & state
// =====================================================================
type RangeDraw
    box          b
    line         mid
    line         tgt
    label        tgtLbl
    label        ph
    polyline     p1
    polyline     p2
    array<label> lbls

var int   state    = 0     // 0 scanning, 1 awaiting AR, 2 range active
var int   dir      = 0     // +1 accumulation, -1 distribution
var int   phase    = 0     // 1..5 = Phase A..E
var float rTop     = na    // range edges in mirrored space
var float rBot     = na
var int   climBar  = 0
var float climEffZ = 0.0
var label climLbl  = na
var int   arBar    = 0

var bool  brkPending = false
var float brkLow     = na
var int   brkStart   = 0
var int   brkLowBar  = 0
var float brkLowEffZ = 0.0

var bool  springSeen = false
var bool  testSeen   = false
var bool  sosSeen    = false
var float springLow  = na
var float springEffZ = 0.0
var int   stCount    = 0
var int   sosBar     = 0

var box   rangeBox = na
var line  midLine  = na
var label phaseLbl = na
var line  tgtLine  = na
var label tgtLbl   = na

var array<label>     curLbls   = array.new<label>()   // labels of the live range
var array<RangeDraw> history   = array.new<RangeDraw>()
var array<polyline>  livePolys = array.new<polyline>()
var table            tbl       = na

// Outcome counters
var int nAcc      = 0
var int nDist     = 0
var int accHeld   = 0
var int accFail   = 0
var int distHeld  = 0
var int distFail  = 0
var int springN   = 0
var int springWin = 0
var int utadN     = 0
var int utadWin   = 0

// =====================================================================
//  Helpers
// =====================================================================
f_size(string s) =>
    switch s
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_nm(string acc, string dist) =>
    dir == 1 ? acc : dist

f_phase(int p) =>
    p == 1 ? "A" : p == 2 ? "B" : p == 3 ? "C" : p == 4 ? "D" : "E"

f_chk(bool b) =>
    b ? "✓" : "–"

// Event label, registered to the live range so it is removed with it.
// tx is in mirrored space; atLowT = event sits on the climax side
// of the range (lows for accumulation, highs for distribution)
f_ev(int x, float tx, string txt, bool atLowT, color bg, string sz) =>
    bool  below = atLowT == (dir == 1)
    label lb    = label.new(x, dir * tx, txt, xloc = xloc.bar_index, color = bg, style = below ? label.style_label_up : label.style_label_down, textcolor = color.black, size = sz, text_font_family = font.family_monospace)
    curLbls.push(lb)
    lb

// 3D top face + side face for a range block
f_faces(int l, int r, float topR, float botR, color c, float a) =>
    float dy = a * liftAtr
    int   dx = depthBars
    array<chart.point> tp = array.new<chart.point>()
    tp.push(chart.point.from_index(l, topR))
    tp.push(chart.point.from_index(r, topR))
    tp.push(chart.point.from_index(r + dx, topR + dy))
    tp.push(chart.point.from_index(l + dx, topR + dy))
    array<chart.point> sp = array.new<chart.point>()
    sp.push(chart.point.from_index(r, topR))
    sp.push(chart.point.from_index(r + dx, topR + dy))
    sp.push(chart.point.from_index(r + dx, botR + dy))
    sp.push(chart.point.from_index(r, botR))
    polyline p1 = polyline.new(points = tp, curved = false, closed = true, xloc = xloc.bar_index, line_color = c, fill_color = color.new(c, 62), line_width = 1)
    polyline p2 = polyline.new(points = sp, curved = false, closed = true, xloc = xloc.bar_index, line_color = c, fill_color = color.new(c, 80), line_width = 1)
    [p1, p2]

// =====================================================================
//  Core series
// =====================================================================
float atr       = ta.atr(atrLen)
float ema       = ta.ema(close, emaLen)
float eff       = nz(volume) > 0 ? volume : high - low
float effMean   = ta.sma(eff, volLen)
float effSd     = ta.stdev(eff, volLen)
float effZ      = effSd > 0 ? (eff - effMean) / effSd : 0.0
float ph        = ta.pivothigh(high, pivLen, pivLen)
float pl        = ta.pivotlow(low, pivLen, pivLen)
float priorLow  = ta.lowest(low, trendLook)[1]
float priorHigh = ta.highest(high, trendLook)[1]
bool  wideBar   = (high - low) >= climaxRng * atr
bool  scBar     = effZ >= climaxZ and wideBar and low < priorLow and close < ema
bool  bcBar     = effZ >= climaxZ and wideBar and high > priorHigh and close > ema

string lblSize  = f_size(labelSizeIn)
string sigSize  = f_size(signalSizeIn)
string tfTxt    = syminfo.ticker + " " + timeframe.period

string alertMsg    = ""
bool   sigSpring   = false
bool   sigUtad     = false
bool   sigLps      = false
bool   sigLpsy     = false
bool   finalizeNow = false
bool   hideRange   = false
string finalTag    = ""

// =====================================================================
//  State 0: scan for a selling / buying climax
// =====================================================================
if state == 0 and (scBar or bcBar)
    dir      := scBar ? 1 : -1
    state    := 1
    rBot     := dir == 1 ? low : -high
    climBar  := bar_index
    climEffZ := effZ
    climLbl  := label.new(bar_index, dir == 1 ? low : high, dir == 1 ? "SC" : "BC", xloc = xloc.bar_index, color = climCol, style = dir == 1 ? label.style_label_up : label.style_label_down, textcolor = color.black, size = lblSize, text_font_family = font.family_monospace)
    if alertStruct
        alertMsg += (dir == 1 ? "Selling Climax (SC)" : "Buying Climax (BC)") + " detected | " + tfTxt + "\n"

// Mirrored values: accumulation uses prices as-is, distribution uses -price
float tH   = dir == 1 ? high : -low
float tL   = dir == 1 ? low : -high
float tC   = dir == 1 ? close : -close
float tPH  = dir == 1 ? ph : -pl
float tPL  = dir == 1 ? pl : -ph
int   pb   = bar_index - pivLen
color dCol = dir == 1 ? accCol : distCol

// =====================================================================
//  State 1: climax found, waiting for the Automatic Rally / Reaction
// =====================================================================
if state == 1 and bar_index > climBar
    if tL < rBot
        rBot     := tL
        climBar  := bar_index
        climEffZ := math.max(climEffZ, effZ)
        label.set_xy(climLbl, bar_index, dir * tL)
    if not na(tPH) and pb > climBar and tPH - rBot >= minRangeAtr * atr
        rTop       := tPH
        arBar      := pb
        state      := 2
        phase      := 1
        brkPending := false
        springSeen := false
        testSeen   := false
        sosSeen    := false
        stCount    := 0
        tgtLine    := na
        tgtLbl     := na
        curLbls.push(climLbl)
        f_ev(pb, tPH, "AR", false, dCol, lblSize)
        float topR = math.max(dir * rTop, dir * rBot)
        float botR = math.min(dir * rTop, dir * rBot)
        rangeBox := box.new(climBar, topR, bar_index, botR, xloc = xloc.bar_index, border_color = dCol, border_width = 2, bgcolor = color.new(dCol, 88))
        midLine  := showMid ? line.new(climBar, (topR + botR) / 2.0, bar_index, (topR + botR) / 2.0, xloc = xloc.bar_index, color = color.new(dCol, 30), style = line.style_dashed, width = 1) : na
        phaseLbl := label.new(climBar, topR, "", xloc = xloc.bar_index, color = color.new(panelCol, 10), style = label.style_label_lower_left, textcolor = dCol, size = lblSize, text_font_family = font.family_monospace)
        if dir == 1
            nAcc += 1
        else
            nDist += 1
        if alertStruct
            alertMsg += f_nm("ACCUMULATION", "DISTRIBUTION") + " range confirmed (AR) | " + str.tostring(botR, format.mintick) + " – " + str.tostring(topR, format.mintick) + " | " + tfTxt + "\n"
    else if bar_index - climBar > arMaxBars
        label.delete(climLbl)
        state := 0
        dir   := 0

// =====================================================================
//  State 2: range active — hunt the Wyckoff events
// =====================================================================
if state == 2 and bar_index > arBar + pivLen
    float height = rTop - rBot
    float rMid   = (rTop + rBot) / 2.0

    // ── Pivot-confirmed events: ST, TEST, LPS / LPSY ──────────────────
    if not na(tPL) and pb > arBar
        float pEffZ = effZ[pivLen]
        if sosSeen
            if pb > sosBar and tPL >= rMid
                f_ev(pb, tPL, f_nm("▲ LPS", "▼ LPSY") + (detailLbl ? "\nentry zone" : ""), true, dCol, sigSize)
                if dir == 1
                    sigLps  := true
                    accHeld += 1
                else
                    sigLpsy  := true
                    distHeld += 1
                if alertSig
                    alertMsg += f_nm("LPS (Last Point of Support)", "LPSY (Last Point of Supply)") + " confirmed at " + str.tostring(dir * tPL, format.mintick) + " | " + tfTxt + "\n"
                phase       := 5
                finalizeNow := true
                finalTag    := f_nm("MARKUP", "MARKDOWN")
        else if springSeen
            if not testSeen and tPL > springLow and tPL <= rBot + testZone * height and pEffZ < springEffZ
                f_ev(pb, tPL, "TEST", true, dCol, lblSize)
                testSeen := true
        else if stCount < maxST and tPL >= rBot and tPL <= rBot + stZone * height
            f_ev(pb, tPL, detailLbl and pEffZ >= climEffZ ? "ST\nhi vol" : "ST", true, dCol, lblSize)
            stCount += 1
            if phase < 2
                phase := 2

    // ── Bar-level events: Spring / UTAD, failure, SOS / SOW ───────────
    if not sosSeen and not finalizeNow
        if tL < rBot and not brkPending
            brkPending := true
            brkStart   := bar_index
            brkLow     := tL
            brkLowBar  := bar_index
            brkLowEffZ := effZ
        if brkPending
            if tL < brkLow
                brkLow     := tL
                brkLowBar  := bar_index
                brkLowEffZ := effZ
            if tC > rBot
                brkPending := false
                if requireST and stCount == 0
                    // Still Phase A: the climax extreme is being extended, not sprung
                    rBot     := brkLow
                    climEffZ := math.max(climEffZ, brkLowEffZ)
                    label.set_xy(climLbl, brkLowBar, dir * brkLow)
                    float topX = math.max(dir * rTop, dir * rBot)
                    float botX = math.min(dir * rTop, dir * rBot)
                    box.set_top(rangeBox, topX)
                    box.set_bottom(rangeBox, botX)
                    if not na(midLine)
                        line.set_y1(midLine, (topX + botX) / 2.0)
                        line.set_y2(midLine, (topX + botX) / 2.0)
                    label.set_y(phaseLbl, topX)
                else
                    // Price reclaimed the range: Spring (acc) / UTAD (dist)
                    springSeen := true
                    testSeen   := false
                    springLow  := brkLow
                    springEffZ := brkLowEffZ
                    phase      := 3
                    float  depth = (rBot - brkLow) / atr
                    string note  = brkLowEffZ < 1.0 ? "low vol" : "shakeout"
                    if showSpringLbl
                        f_ev(brkLowBar, brkLow, f_nm("SPRING", "UTAD") + (detailLbl ? "\n" + note + " · " + str.tostring(depth, "#.##") + " ATR" : ""), true, sigCol, sigSize)
                    if dir == 1
                        sigSpring := true
                        springN   += 1
                    else
                        sigUtad := true
                        utadN   += 1
                    if alertSig
                        alertMsg += f_nm("SPRING", "UTAD") + " confirmed (" + note + ") at " + str.tostring(dir * brkLow, format.mintick) + " | " + tfTxt + "\n"
            else if tC < rBot - breakAtr * atr or bar_index - brkStart >= reclaimBars
                f_ev(bar_index, tL, f_nm("✖ BREAKDOWN", "✖ BREAKOUT") + (detailLbl ? "\nrange failed" : ""), true, failCol, lblSize)
                if dir == 1
                    accFail += 1
                else
                    distFail += 1
                if alertStruct
                    alertMsg += f_nm("Accumulation", "Distribution") + " range FAILED | " + tfTxt + "\n"
                brkPending  := false
                finalizeNow := true
                hideRange   := not showFailed
                finalTag    := "FAILED"

        bool strongBar = effZ >= sosMinZ or (high - low) >= atr
        if not finalizeNow and not brkPending and tC > rTop + sosBufAtr * atr and strongBar
            f_ev(bar_index, tH, f_nm("SOS", "SOW") + (detailLbl ? "\neffort z " + str.tostring(effZ, "#.#") : ""), false, dCol, lblSize)
            sosSeen := true
            sosBar  := bar_index
            phase   := 4
            if springSeen
                if dir == 1
                    springWin += 1
                else
                    utadWin += 1
            if showTarget
                float tgtR = dir * (rTop + height * projMult)
                tgtLine := line.new(bar_index, tgtR, bar_index + projBars, tgtR, xloc = xloc.bar_index, color = dCol, style = line.style_dashed, width = 2)
                tgtLbl  := label.new(bar_index + projBars, tgtR, "TARGET  " + str.tostring(tgtR, format.mintick), xloc = xloc.bar_index, color = color.new(panelCol, 10), style = label.style_label_left, textcolor = dCol, size = lblSize, text_font_family = font.family_monospace)
            if alertSig
                alertMsg += f_nm("SOS (Sign of Strength) breakout", "SOW (Sign of Weakness) breakdown") + " at " + str.tostring(close, format.mintick) + " | " + tfTxt + "\n"

    else if sosSeen and not finalizeNow
        if bar_index > sosBar and tC < rMid
            f_ev(bar_index, tL, f_nm("✖ FAILED SOS", "✖ FAILED SOW"), true, failCol, lblSize)
            if dir == 1
                accFail += 1
            else
                distFail += 1
            if alertStruct
                alertMsg += f_nm("SOS", "SOW") + " FAILED — back inside range | " + tfTxt + "\n"
            finalizeNow := true
            hideRange   := not showFailed
            finalTag    := "FAILED BREAKOUT"
        else if bar_index - sosBar > lpsMaxBars
            if dir == 1
                accHeld += 1
            else
                distHeld += 1
            phase       := 5
            finalizeNow := true
            finalTag    := f_nm("MARKUP (no LPS)", "MARKDOWN (no LPSY)")

    // ── Range timeout ─────────────────────────────────────────────────
    if not finalizeNow and not sosSeen and bar_index - climBar > maxRangeBars
        finalizeNow := true
        hideRange   := not showFailed
        finalTag    := "EXPIRED"

    // ── Extend / update the live range ────────────────────────────────
    box.set_right(rangeBox, bar_index)
    if not na(midLine)
        line.set_x2(midLine, bar_index)
    label.set_text(phaseLbl, f_nm("ACCUMULATION", "DISTRIBUTION") + " · PHASE " + f_phase(phase))

    // ── Finalize a completed range ────────────────────────────────────
    if finalizeNow
        if hideRange
            // Failed / expired range: remove everything (still counted in stats)
            box.delete(rangeBox)
            if not na(midLine)
                line.delete(midLine)
            if not na(tgtLine)
                line.delete(tgtLine)
            if not na(tgtLbl)
                label.delete(tgtLbl)
            label.delete(phaseLbl)
            while curLbls.size() > 0
                curLbls.pop().delete()
        else
            label.set_text(phaseLbl, f_nm("ACCUMULATION", "DISTRIBUTION") + " · " + finalTag)
            polyline fp1 = na
            polyline fp2 = na
            if show3D
                float topR = math.max(dir * rTop, dir * rBot)
                float botR = math.min(dir * rTop, dir * rBot)
                [a1, a2] = f_faces(climBar, bar_index, topR, botR, dCol, nz(atr))
                fp1 := a1
                fp2 := a2
            history.push(RangeDraw.new(rangeBox, midLine, tgtLine, tgtLbl, phaseLbl, fp1, fp2, curLbls.copy()))
            curLbls.clear()
            if history.size() > maxRanges
                RangeDraw old = history.shift()
                if not na(old.b)
                    old.b.delete()
                if not na(old.mid)
                    old.mid.delete()
                if not na(old.tgt)
                    old.tgt.delete()
                if not na(old.tgtLbl)
                    old.tgtLbl.delete()
                if not na(old.ph)
                    old.ph.delete()
                if not na(old.p1)
                    old.p1.delete()
                if not na(old.p2)
                    old.p2.delete()
                for lb in old.lbls
                    lb.delete()
        state      := 0
        dir        := 0
        rangeBox   := na
        midLine    := na
        phaseLbl   := na
        tgtLine    := na
        tgtLbl     := na
        brkPending := false

// =====================================================================
//  Live 3D block + dashboard (last bar)
// =====================================================================
if barstate.islast
    while livePolys.size() > 0
        livePolys.pop().delete()
    if state == 2 and show3D
        float topR = math.max(dir * rTop, dir * rBot)
        float botR = math.min(dir * rTop, dir * rBot)
        [l1, l2] = f_faces(climBar, bar_index, topR, botR, dCol, nz(atr))
        livePolys.push(l1)
        livePolys.push(l2)

    if showTable
        tSize = f_size(tableSizeIn)
        if na(tbl)
            tbl := table.new(f_pos(tablePosIn), 2, 7, bgcolor = panelCol, frame_color = climCol, frame_width = 2, border_color = color.new(climCol, 70), border_width = 1)
            table.merge_cells(tbl, 0, 0, 1, 0)

        string stTxt  = "SCANNING FOR CLIMAX"
        color  stCol  = color.white
        string rngTxt = "—"
        string evTxt  = "—"
        if state == 1
            stTxt := (dir == 1 ? "SC" : "BC") + " FOUND · AWAITING AR"
            stCol := climCol
        else if state == 2
            float topR = math.max(dir * rTop, dir * rBot)
            float botR = math.min(dir * rTop, dir * rBot)
            stTxt  := f_nm("ACCUMULATION", "DISTRIBUTION") + " · PHASE " + f_phase(phase)
            stCol  := dCol
            rngTxt := str.tostring(botR, format.mintick) + " – " + str.tostring(topR, format.mintick) + "  (" + str.tostring((topR - botR) / atr, "#.#") + " ATR)"
            evTxt  := f_nm("SC", "BC") + " ✓  AR ✓  ST " + str.tostring(stCount) + "  " + f_nm("SPRING ", "UTAD ") + f_chk(springSeen) + "  TEST " + f_chk(testSeen) + "  " + f_nm("SOS ", "SOW ") + f_chk(sosSeen)

        string sprTxt  = springN > 0 ? str.tostring(100.0 * springWin / springN, "#") + "%  (" + str.tostring(springWin) + "/" + str.tostring(springN) + ")" : "no springs yet"
        string utTxt   = utadN > 0 ? str.tostring(100.0 * utadWin / utadN, "#") + "%  (" + str.tostring(utadWin) + "/" + str.tostring(utadN) + ")" : "no UTADs yet"
        string histTxt = "ACC " + str.tostring(nAcc) + " (held " + str.tostring(accHeld) + " / failed " + str.tostring(accFail) + ")   DIST " + str.tostring(nDist) + " (held " + str.tostring(distHeld) + " / failed " + str.tostring(distFail) + ")"

        table.cell(tbl, 0, 0, "WYCKOFF RANGE DETECTOR 3D", text_color = sigCol, text_size = tSize, bgcolor = panelCol)
        table.cell(tbl, 0, 1, "STATUS", text_color = color.white, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 1, 1, stTxt, text_color = stCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 0, 2, "RANGE", text_color = color.white, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 1, 2, rngTxt, text_color = stCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 0, 3, "EVENTS", text_color = color.white, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 1, 3, evTxt, text_color = stCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 0, 4, "SPRING → SOS", text_color = accCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 1, 4, sprTxt, text_color = accCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 0, 5, "UTAD → SOW", text_color = distCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 1, 5, utTxt, text_color = distCol, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 0, 6, "RANGES", text_color = color.white, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)
        table.cell(tbl, 1, 6, histTxt, text_color = color.white, text_size = tSize, bgcolor = panelCol, text_halign = text.align_left)

// =====================================================================
//  Signal markers & alerts
// =====================================================================
plotshape(showMarkers and sigSpring, title = "Spring", style = shape.triangleup, location = location.belowbar, color = sigCol, size = size.small)
plotshape(showMarkers and sigUtad, title = "UTAD", style = shape.triangledown, location = location.abovebar, color = sigCol, size = size.small)
plotshape(showMarkers and sigLps, title = "LPS", style = shape.triangleup, location = location.belowbar, color = accCol, size = size.small)
plotshape(showMarkers and sigLpsy, title = "LPSY", style = shape.triangledown, location = location.abovebar, color = distCol, size = size.small)

if alertMsg != ""
    alert(alertMsg, alert.freq_once_per_bar_close)
````
