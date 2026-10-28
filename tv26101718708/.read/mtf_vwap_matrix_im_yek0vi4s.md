# MTF VWAP Matrix [I.M]

- url: https://www.tradingview.com/script/yek0vI4S/
- type: indicator
- pine_id: PUB;660123afb8c0405198722e6fc06695eb
- version: 1.0

## Description

🟣 Overview

MTF VWAP Matrix [I.M] is a multi-anchor Volume Weighted Average Price visualizer designed for traders who need institutional context across timeframes — at a glance.

It plots up to five anchored VWAPs simultaneously (Session, Daily, Weekly, Monthly, Quarterly), aggregates price location into a directional confluence matrix with a 0–100 score, detects slope changes per anchor (acceleration vs deceleration), highlights divergences between short and long-term institutional flow, and lights up only the candles that show genuine impulse — through a continuous Smart Glow strength engine.

The trade-bias philosophy is simple: institutional flow tends to defend VWAP. When price aligns above multiple anchored VWAPs, longs are favored. When it aligns below, shorts are favored. Mixed alignment signals an undecided market — stand aside.

https://www.tradingview.com/x/BZ9ptFPc/

🟣 Highlights

- Five anchored VWAPs in one indicator (Session, Daily, Weekly, Monthly, Quarterly)
- Confluence matrix with directional bias and 0–100 score
- Slope detection per anchor — distinguishes accelerating trends from flattening ones
- Continuous Smart Glow — candles brighten proportionally to real strength (body × volume × alignment)
- Divergence detector — flags when short-term and long-term VWAPs disagree
- Standard deviation bands (1σ and 2σ) on the user-selected primary anchor
- Distance percentage from each VWAP for fast context
- Built-in alerts for full alignment flips, primary VWAP crossings and divergences

🟣 How It Works

▪ Anchored VWAP Construction
Each anchor maintains an independent running calculation that resets at the start of its period:
- Session: resets at the start of the regular session
- Daily / Weekly / Monthly / Quarterly: reset on each new period

For every anchor the script tracks cumulative price-volume product, cumulative volume, and squared price-volume product. From these it derives the VWAP and a running variance — the variance powers the standard deviation bands on the primary anchor.

▪ Slope Detection
For each VWAP the script computes its slope as percentage change per bar over a rolling lookback window. Slopes are translated into intuitive symbols inside the matrix:
- ↗ accelerating up
- ↑ rising
- → flat
- ↓ falling
- ↘ accelerating down

This separates a VWAP that is genuinely trending from one that is simply lateralizing — a critical distinction institutional traders rely on.

▪ Continuous Smart Glow
Instead of a binary "strong / weak" flag, every candle receives a continuous strength score (0–100) blending three weighted components:
- Body ratio: how dominant is the candle body vs the full range
- Volume surge: candle volume vs 20-bar average
- Directional alignment: does the candle's direction match overall confluence

Candle transparency varies smoothly with the score — explosive impulses glow vivid, weak indecision candles stay dim or invisible. The eye lands instantly on the bars that actually moved the market.

▪ Divergence Detector
When the Session VWAP slopes up while the Daily VWAP slopes down — or vice-versa — short-term flow is fighting long-term flow. These institutional conflict zones often precede reversals. The script flags them visually on the chart and inside the matrix.

▪ Confluence Matrix
A compact table aggregates everything: anchor name, distance from VWAP, directional bias, slope state, total alignment, 0–100 institutional score, and divergence status — all updated in real time.

🟣 How to Use

▪ Spot Institutional Alignment
When the matrix shows FULL BULLISH or FULL BEARISH with a score of 100, every active anchor agrees on direction. These are the highest-conviction regimes — countertrend trades become statistically expensive.

▪ Identify Trade Zones with Bands
The 1σ band of the primary anchor often acts as a magnet during trends. In a bullish regime, pullbacks to the lower 1σ band frequently provide entries with the trend. In a bearish regime, rallies to the upper 1σ band do the same.

▪ Read Slope to Confirm Momentum
A FULL BULLISH score with all anchors showing ↗ is a high-conviction trend. The same score but with anchors showing → suggests exhaustion — the move is losing fuel.

▪ Use Smart Glow as an Impulse Filter
Glowing candles mark institutional participation. Entries placed on glowing impulse candles in the direction of confluence have a structural edge. Entries placed on dim consolidation candles are statistically weaker.

▪ Watch Divergences as Reversal Warnings
When Session ↑ and Daily ↓ appear simultaneously, short-term traders are pushing one direction while the day's overall flow goes the other way. This conflict often resolves in favor of the longer timeframe — useful as an early warning.

🟣 Settings

- Anchors — toggle individual VWAPs on/off
- Primary Anchor — selects which VWAP receives standard deviation bands
- VWAP Ribbon — optional fill between Session and Daily
- Smart Glow — enable/disable, plus minimum strength threshold
- Divergence Detector — toggle visual divergence markers
- Source — input price source (default hlc3)
- Visual — fully customizable colors for every element
- Confluence Matrix — toggle the table and choose its position

🟣 Alerts

- Full Bullish Alignment — every active anchor flipped bullish
- Full Bearish Alignment — every active anchor flipped bearish
- Cross Above Primary VWAP — price crossed above the selected anchor
- Cross Below Primary VWAP — price crossed below the selected anchor
- VWAP Divergence Detected — short-term and long-term flow conflict

----------------

Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendation, or solicitation to buy or sell any financial instrument. Past performance does not guarantee future results. All trading involves risk and decisions should be made based on individual financial circumstances, risk tolerance, and after consultation with qualified professionals where applicable.

Open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=6
indicator("MTF VWAP Matrix [I.M]", shorttitle="MTFVWAP", overlay=true, max_lines_count=500, max_labels_count=500)

// ═════════════════════════════════════════════════════════════════════════════
//                          MTF VWAP MATRIX [I.M]
// ─────────────────────────────────────────────────────────────────────────────
// Multi-anchor Volume Weighted Average Price visualizer with:
//   • Five anchored VWAPs (Session, Daily, Weekly, Monthly, Quarterly)
//   • Confluence matrix with directional bias and 0-100 score
//   • Slope detection per anchor (trend acceleration/deceleration)
//   • Continuous Smart Glow — candle brightness proportional to real strength
//   • Divergence detector — flags conflicts between short and long-term VWAPs
//
// Trade-bias philosophy: institutional flow tends to defend VWAP. When price
// aligns above multiple anchored VWAPs, longs are favored; below them, shorts.
// Mixed alignment signals an undecided market — stand aside.
//
// @author  igormena
// @version 2.0.0
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const string ANCHOR_SESSION   = "Session"
const string ANCHOR_DAILY     = "Daily"
const string ANCHOR_WEEKLY    = "Weekly"
const string ANCHOR_MONTHLY   = "Monthly"
const string ANCHOR_QUARTERLY = "Quarterly"

const float STDEV_BAND_INNER  = 1.0
const float STDEV_BAND_OUTER  = 2.0

const int   RESET_BUFFER_BARS = 1
const int   TABLE_MAX_ROWS    = 10
const int   TABLE_COLS        = 4
const int   VOLUME_LOOKBACK   = 20
const int   SLOPE_LOOKBACK    = 10

const string TIMEFRAME_DAY    = "D"
const string TIMEFRAME_WEEK   = "W"
const string TIMEFRAME_MONTH  = "M"
const string TIMEFRAME_QUART  = "3M"

const float SCORE_MAX             = 100.0
const float STRENGTH_BODY_WEIGHT  = 40.0
const float STRENGTH_VOL_WEIGHT   = 35.0
const float STRENGTH_ALIGN_WEIGHT = 25.0

const float SLOPE_STRONG_PCT      = 0.04
const float SLOPE_FLAT_PCT        = 0.01

// ─────────────────────────────────────────────────────────────────────────────
// USER-DEFINED TYPES
// ─────────────────────────────────────────────────────────────────────────────
type Anchor
    string id
    float  value
    float  variance
    int    bias
    float  slope
    color  lineColor
    bool   enabled
    bool   justReset

type Confluence
    int    active
    int    bullish
    int    bearish
    string label
    color  tone
    float  score

// ─────────────────────────────────────────────────────────────────────────────
// METHODS — Anchor
// ─────────────────────────────────────────────────────────────────────────────
method distancePct(Anchor self) =>
    na(self.value) or self.value == 0.0 ? 0.0 : (close - self.value) / self.value * 100.0

method standardDeviation(Anchor self) =>
    self.variance <= 0.0 ? 0.0 : math.sqrt(self.variance)

method upperBand(Anchor self, float multiplier) =>
    self.value + self.standardDeviation() * multiplier

method lowerBand(Anchor self, float multiplier) =>
    self.value - self.standardDeviation() * multiplier

method biasSymbol(Anchor self) =>
    self.bias > 0 ? "▲" : self.bias < 0 ? "▼" : "─"

// @function Visual symbol representing slope state
method slopeSymbol(Anchor self) =>
    result = "→"
    if self.slope >  SLOPE_STRONG_PCT
        result := "↗"
    else if self.slope >  SLOPE_FLAT_PCT
        result := "↑"
    else if self.slope < -SLOPE_STRONG_PCT
        result := "↘"
    else if self.slope < -SLOPE_FLAT_PCT
        result := "↓"
    result

method shouldRender(Anchor self) =>
    self.enabled and not self.justReset and not na(self.value)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
GROUP_ANCHORS = "Anchors"
showSession   = input.bool(true,  "Show Session",   group=GROUP_ANCHORS, inline="row1")
showDaily     = input.bool(true,  "Show Daily",     group=GROUP_ANCHORS, inline="row1")
showWeekly    = input.bool(true,  "Show Weekly",    group=GROUP_ANCHORS, inline="row2")
showMonthly   = input.bool(true,  "Show Monthly",   group=GROUP_ANCHORS, inline="row2")
showQuarterly = input.bool(false, "Show Quarterly", group=GROUP_ANCHORS, inline="row2")

GROUP_PRIMARY = "Primary Anchor (with deviation bands)"
primaryId = input.string(ANCHOR_DAILY, "Primary",
                         options=[ANCHOR_SESSION, ANCHOR_DAILY, ANCHOR_WEEKLY, ANCHOR_MONTHLY, ANCHOR_QUARTERLY],
                         group=GROUP_PRIMARY,
                         tooltip="Anchor selected as primary will receive 1σ and 2σ bands")
showBands = input.bool(true, "Show Deviation Bands", group=GROUP_PRIMARY)

GROUP_RIBBON = "VWAP Ribbon"
showRibbon   = input.bool(false, "Show Ribbon (Session ↔ Daily)", group=GROUP_RIBBON,
                          tooltip="Optional. Fill between Session and Daily VWAPs.")

GROUP_GLOW       = "Smart Glow Candles (continuous strength)"
glowCandles      = input.bool(true,  "Enable Smart Glow", group=GROUP_GLOW,
                              tooltip="Candles light up proportionally to real strength: body size, volume surge, and alignment with confluence. Strong candles glow vivid, weak candles stay dim.")
glowMinStrength  = input.int(40, "Minimum Strength to Glow", minval=0, maxval=80, step=5, group=GROUP_GLOW,
                              tooltip="Candles below this strength score (0-100) won't light up at all. Higher = stricter, fewer glowing candles.")

GROUP_DIVERGENCE = "Divergence Detector"
showDivergence   = input.bool(true, "Show VWAP Divergences", group=GROUP_DIVERGENCE,
                              tooltip="Marks bars where short-term and long-term VWAPs disagree directionally — institutional conflict zones often precede reversals.")

GROUP_SOURCE = "Source"
src = input.source(hlc3, "Price Source", group=GROUP_SOURCE)

GROUP_VISUAL = "Visual"
sessionColor   = input.color(color.rgb(255, 152,   0), "Session",   group=GROUP_VISUAL, inline="c1")
dailyColor     = input.color(color.rgb( 33, 150, 243), "Daily",     group=GROUP_VISUAL, inline="c1")
weeklyColor    = input.color(color.rgb(156,  39, 176), "Weekly",    group=GROUP_VISUAL, inline="c2")
monthlyColor   = input.color(color.rgb( 38, 166, 154), "Monthly",   group=GROUP_VISUAL, inline="c2")
quarterlyColor = input.color(color.rgb(255, 110, 130), "Quarterly", group=GROUP_VISUAL, inline="c3")
bullColor      = input.color(color.rgb( 80, 230, 200), "Bull tone", group=GROUP_VISUAL, inline="c4")
bearColor      = input.color(color.rgb(255, 110, 130), "Bear tone", group=GROUP_VISUAL, inline="c4")
neutralColor   = input.color(color.rgb(120, 130, 140), "Neutral",   group=GROUP_VISUAL, inline="c4")

GROUP_TABLE = "Confluence Matrix"
showTable = input.bool(true, "Show Matrix", group=GROUP_TABLE)
tablePosId = input.string("top_right", "Position",
                          options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"],
                          group=GROUP_TABLE)

// ─────────────────────────────────────────────────────────────────────────────
// PURE FUNCTIONS — Period Detection
// ─────────────────────────────────────────────────────────────────────────────
isNewPeriod(string anchorId) =>
    switch anchorId
        ANCHOR_SESSION   => session.isfirstbar_regular
        ANCHOR_DAILY     => timeframe.change(TIMEFRAME_DAY)
        ANCHOR_WEEKLY    => timeframe.change(TIMEFRAME_WEEK)
        ANCHOR_MONTHLY   => timeframe.change(TIMEFRAME_MONTH)
        ANCHOR_QUARTERLY => timeframe.change(TIMEFRAME_QUART)
        =>                  false

// ─────────────────────────────────────────────────────────────────────────────
// PURE FUNCTIONS — Helpers
// ─────────────────────────────────────────────────────────────────────────────
positionFromString(string posId) =>
    switch posId
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        "middle_right" => position.middle_right
        =>               position.top_right

priceBias(float vwapValue) =>
    na(vwapValue) ? 0 : close > vwapValue ? 1 : close < vwapValue ? -1 : 0

ribbonFillColor(bool render, int sessionBias, int dailyBias) =>
    result = color.new(neutralColor, 92)
    if not render
        result := na
    else if sessionBias > 0 and dailyBias > 0
        result := color.new(bullColor, 88)
    else if sessionBias < 0 and dailyBias < 0
        result := color.new(bearColor, 88)
    result

// @function Maps a 0-100 strength score to color transparency
strengthToTransparency(float strength) =>
    int(math.max(0.0, math.min(95.0, 95.0 - strength * 0.95)))

candleGlowColor(int transparency) =>
    close >= open ? color.new(bullColor, transparency) : color.new(bearColor, transparency)

// @function Continuous candle strength (0-100)
candleStrength(int alignmentVotes, int activeAnchors) =>
    candleRange = high - low
    bodySize    = math.abs(close - open)
    bodyRatio   = candleRange > 0 ? bodySize / candleRange : 0.0
    volAvg      = ta.sma(volume, VOLUME_LOOKBACK)
    volRatio    = volAvg > 0 ? volume / volAvg : 1.0

    bodyComponent = math.min(1.0, bodyRatio) * STRENGTH_BODY_WEIGHT

    volNormalized = math.min(1.0, math.max(0.0, (volRatio - 0.5) / 1.5))
    volComponent  = volNormalized * STRENGTH_VOL_WEIGHT

    candleDirection = close >= open ? 1 : -1
    alignRatio = activeAnchors > 0 ? alignmentVotes / float(activeAnchors) : 0.5
    directionalAlign = candleDirection > 0 ? alignRatio : 1.0 - alignRatio
    alignComponent   = directionalAlign * STRENGTH_ALIGN_WEIGHT

    bodyComponent + volComponent + alignComponent

// @function Slope as percentage change per bar
calcSlope(float currentValue, float pastValue) =>
    na(pastValue) or pastValue == 0.0 ? 0.0 : (currentValue - pastValue) / pastValue * 100.0 / SLOPE_LOOKBACK

// ─────────────────────────────────────────────────────────────────────────────
// PURE FUNCTIONS — Anchor Builders
// ─────────────────────────────────────────────────────────────────────────────
buildSessionAnchor() =>
    var float sumPV  = 0.0
    var float sumV   = 0.0
    var float sumPV2 = 0.0
    if isNewPeriod(ANCHOR_SESSION)
        sumPV  := 0.0
        sumV   := 0.0
        sumPV2 := 0.0
    vol = nz(volume, 0.0)
    sumPV  += src * vol
    sumV   += vol
    sumPV2 += src * src * vol
    vwap = sumV > 0 ? sumPV / sumV : src
    variance = sumV > 0 ? math.max(0.0, (sumPV2 / sumV) - (vwap * vwap)) : 0.0
    slope = calcSlope(vwap, vwap[SLOPE_LOOKBACK])
    Anchor.new(ANCHOR_SESSION, vwap, variance, priceBias(vwap), slope, sessionColor, showSession,
              isNewPeriod(ANCHOR_SESSION) or bar_index < RESET_BUFFER_BARS)

buildDailyAnchor() =>
    var float sumPV  = 0.0
    var float sumV   = 0.0
    var float sumPV2 = 0.0
    if isNewPeriod(ANCHOR_DAILY)
        sumPV  := 0.0
        sumV   := 0.0
        sumPV2 := 0.0
    vol = nz(volume, 0.0)
    sumPV  += src * vol
    sumV   += vol
    sumPV2 += src * src * vol
    vwap = sumV > 0 ? sumPV / sumV : src
    variance = sumV > 0 ? math.max(0.0, (sumPV2 / sumV) - (vwap * vwap)) : 0.0
    slope = calcSlope(vwap, vwap[SLOPE_LOOKBACK])
    Anchor.new(ANCHOR_DAILY, vwap, variance, priceBias(vwap), slope, dailyColor, showDaily,
              isNewPeriod(ANCHOR_DAILY) or bar_index < RESET_BUFFER_BARS)

buildWeeklyAnchor() =>
    var float sumPV  = 0.0
    var float sumV   = 0.0
    var float sumPV2 = 0.0
    if isNewPeriod(ANCHOR_WEEKLY)
        sumPV  := 0.0
        sumV   := 0.0
        sumPV2 := 0.0
    vol = nz(volume, 0.0)
    sumPV  += src * vol
    sumV   += vol
    sumPV2 += src * src * vol
    vwap = sumV > 0 ? sumPV / sumV : src
    variance = sumV > 0 ? math.max(0.0, (sumPV2 / sumV) - (vwap * vwap)) : 0.0
    slope = calcSlope(vwap, vwap[SLOPE_LOOKBACK])
    Anchor.new(ANCHOR_WEEKLY, vwap, variance, priceBias(vwap), slope, weeklyColor, showWeekly,
              isNewPeriod(ANCHOR_WEEKLY) or bar_index < RESET_BUFFER_BARS)

buildMonthlyAnchor() =>
    var float sumPV  = 0.0
    var float sumV   = 0.0
    var float sumPV2 = 0.0
    if isNewPeriod(ANCHOR_MONTHLY)
        sumPV  := 0.0
        sumV   := 0.0
        sumPV2 := 0.0
    vol = nz(volume, 0.0)
    sumPV  += src * vol
    sumV   += vol
    sumPV2 += src * src * vol
    vwap = sumV > 0 ? sumPV / sumV : src
    variance = sumV > 0 ? math.max(0.0, (sumPV2 / sumV) - (vwap * vwap)) : 0.0
    slope = calcSlope(vwap, vwap[SLOPE_LOOKBACK])
    Anchor.new(ANCHOR_MONTHLY, vwap, variance, priceBias(vwap), slope, monthlyColor, showMonthly,
              isNewPeriod(ANCHOR_MONTHLY) or bar_index < RESET_BUFFER_BARS)

buildQuarterlyAnchor() =>
    var float sumPV  = 0.0
    var float sumV   = 0.0
    var float sumPV2 = 0.0
    if isNewPeriod(ANCHOR_QUARTERLY)
        sumPV  := 0.0
        sumV   := 0.0
        sumPV2 := 0.0
    vol = nz(volume, 0.0)
    sumPV  += src * vol
    sumV   += vol
    sumPV2 += src * src * vol
    vwap = sumV > 0 ? sumPV / sumV : src
    variance = sumV > 0 ? math.max(0.0, (sumPV2 / sumV) - (vwap * vwap)) : 0.0
    slope = calcSlope(vwap, vwap[SLOPE_LOOKBACK])
    Anchor.new(ANCHOR_QUARTERLY, vwap, variance, priceBias(vwap), slope, quarterlyColor, showQuarterly,
              isNewPeriod(ANCHOR_QUARTERLY) or bar_index < RESET_BUFFER_BARS)

// ─────────────────────────────────────────────────────────────────────────────
// PURE FUNCTIONS — Confluence Aggregation
// ─────────────────────────────────────────────────────────────────────────────
computeScore(int bullish, int active) =>
    active <= 0 ? 50.0 : (bullish / float(active)) * SCORE_MAX

aggregateConfluence(Anchor s, Anchor d, Anchor w, Anchor m, Anchor q) =>
    active   = (s.enabled ? 1 : 0) + (d.enabled ? 1 : 0) + (w.enabled ? 1 : 0) +
               (m.enabled ? 1 : 0) + (q.enabled ? 1 : 0)
    bullish  = (s.enabled and s.bias > 0 ? 1 : 0) +
               (d.enabled and d.bias > 0 ? 1 : 0) +
               (w.enabled and w.bias > 0 ? 1 : 0) +
               (m.enabled and m.bias > 0 ? 1 : 0) +
               (q.enabled and q.bias > 0 ? 1 : 0)
    bearish  = active - bullish

    label = bullish == active and active > 0 ? "FULL BULLISH"
          : bearish == active and active > 0 ? "FULL BEARISH"
          : bullish > bearish                ? "BULLISH"
          : bearish > bullish                ? "BEARISH"
          :                                    "MIXED"

    tone  = bullish == active and active > 0 ? bullColor
          : bearish == active and active > 0 ? bearColor
          : bullish > bearish                ? color.new(bullColor, 30)
          : bearish > bullish                ? color.new(bearColor, 30)
          :                                    neutralColor

    score = computeScore(bullish, active)

    Confluence.new(active, bullish, bearish, label, tone, score)

selectPrimary(string id, Anchor s, Anchor d, Anchor w, Anchor m, Anchor q) =>
    switch id
        ANCHOR_SESSION   => s
        ANCHOR_DAILY     => d
        ANCHOR_WEEKLY    => w
        ANCHOR_MONTHLY   => m
        ANCHOR_QUARTERLY => q
        =>                  d

// @function Detects directional divergence between short and long-term VWAPs
detectDivergence(Anchor short, Anchor long) =>
    result = 0
    if short.enabled and long.enabled
        if short.slope > SLOPE_FLAT_PCT and long.slope < -SLOPE_FLAT_PCT
            result := 1
        else if short.slope < -SLOPE_FLAT_PCT and long.slope > SLOPE_FLAT_PCT
            result := -1
    result

// ─────────────────────────────────────────────────────────────────────────────
// MAIN — Build All Anchors
// ─────────────────────────────────────────────────────────────────────────────
sessionA   = buildSessionAnchor()
dailyA     = buildDailyAnchor()
weeklyA    = buildWeeklyAnchor()
monthlyA   = buildMonthlyAnchor()
quarterlyA = buildQuarterlyAnchor()

primary    = selectPrimary(primaryId, sessionA, dailyA, weeklyA, monthlyA, quarterlyA)
confluence = aggregateConfluence(sessionA, dailyA, weeklyA, monthlyA, quarterlyA)
divergence = detectDivergence(sessionA, dailyA)

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING — VWAP Lines
// ─────────────────────────────────────────────────────────────────────────────
pSession = plot(sessionA.shouldRender()   ? sessionA.value   : na, "Session",   color=sessionA.lineColor,                  linewidth=2)
pDaily   = plot(dailyA.shouldRender()     ? dailyA.value     : na, "Daily",     color=color.new(dailyA.lineColor,     20), linewidth=2)
plot(weeklyA.shouldRender()    ? weeklyA.value    : na, "Weekly",    color=color.new(weeklyA.lineColor,    65), linewidth=1)
plot(monthlyA.shouldRender()   ? monthlyA.value   : na, "Monthly",   color=color.new(monthlyA.lineColor,   75), linewidth=1)
plot(quarterlyA.shouldRender() ? quarterlyA.value : na, "Quarterly", color=color.new(quarterlyA.lineColor, 80), linewidth=1)

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING — VWAP Ribbon
// ─────────────────────────────────────────────────────────────────────────────
ribbonShouldRender = showRibbon and sessionA.shouldRender() and dailyA.shouldRender()
ribbonColor        = ribbonFillColor(ribbonShouldRender, sessionA.bias, dailyA.bias)
fill(pSession, pDaily, color=ribbonColor, title="VWAP Ribbon")

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING — Standard Deviation Bands
// ─────────────────────────────────────────────────────────────────────────────
showPrimaryBands = showBands and primary.shouldRender() and primary.standardDeviation() > 0
upperOuter = showPrimaryBands ? primary.upperBand(STDEV_BAND_OUTER) : na
upperInner = showPrimaryBands ? primary.upperBand(STDEV_BAND_INNER) : na
lowerInner = showPrimaryBands ? primary.lowerBand(STDEV_BAND_INNER) : na
lowerOuter = showPrimaryBands ? primary.lowerBand(STDEV_BAND_OUTER) : na

pUpperOuter = plot(upperOuter, "Upper 2σ", color=color.new(primary.lineColor, 96), linewidth=1)
pUpperInner = plot(upperInner, "Upper 1σ", color=color.new(primary.lineColor, 88), linewidth=1)
pLowerInner = plot(lowerInner, "Lower 1σ", color=color.new(primary.lineColor, 88), linewidth=1)
pLowerOuter = plot(lowerOuter, "Lower 2σ", color=color.new(primary.lineColor, 96), linewidth=1)

fill(pUpperInner, pUpperOuter, color=color.new(primary.lineColor, 98), title="Upper Band Fill")
fill(pLowerInner, pLowerOuter, color=color.new(primary.lineColor, 98), title="Lower Band Fill")

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING — Smart Glow Candles (continuous strength)
// ─────────────────────────────────────────────────────────────────────────────
strength    = candleStrength(confluence.bullish, confluence.active)
glowActive  = glowCandles and strength >= glowMinStrength
glowTrans   = strengthToTransparency(strength)
glowTone    = glowActive ? candleGlowColor(glowTrans) : na

barcolor(glowTone, title="Smart Glow Bars")

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING — Divergence Markers
// ─────────────────────────────────────────────────────────────────────────────
if showDivergence and barstate.isconfirmed
    if divergence != 0 and divergence[1] == 0
        labelText  = divergence > 0 ? "⚠ ST↑ / LT↓" : "⚠ ST↓ / LT↑"
        labelColor = divergence > 0 ? color.new(bearColor, 30) : color.new(bullColor, 30)
        labelStyle = divergence > 0 ? label.style_label_down : label.style_label_up
        labelY     = divergence > 0 ? high : low
        label.new(bar_index, labelY, labelText,
                 color=labelColor, textcolor=color.white, style=labelStyle, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING — Confluence Matrix Table
// ─────────────────────────────────────────────────────────────────────────────
renderAnchorRow(table t, int row, Anchor a, bool isPrimary) =>
    distTxt   = str.tostring(a.distancePct(), "+0.00;-0.00") + "%"
    statusCol = a.bias > 0 ? bullColor : a.bias < 0 ? bearColor : neutralColor
    slopeCol  = a.slope > SLOPE_FLAT_PCT ? bullColor : a.slope < -SLOPE_FLAT_PCT ? bearColor : neutralColor
    nameTxt   = isPrimary ? a.id + " ★" : a.id
    bgCol     = color.new(color.black, 50)

    table.cell(t, 0, row, nameTxt,         text_color=color.white, text_size=size.small,  bgcolor=bgCol)
    table.cell(t, 1, row, distTxt,         text_color=statusCol,   text_size=size.small,  bgcolor=bgCol)
    table.cell(t, 2, row, a.biasSymbol(),  text_color=statusCol,   text_size=size.normal, bgcolor=bgCol)
    table.cell(t, 3, row, a.slopeSymbol(), text_color=slopeCol,    text_size=size.normal, bgcolor=bgCol)

if showTable and barstate.islast
    var table matrix = table.new(positionFromString(tablePosId), TABLE_COLS, TABLE_MAX_ROWS,
                                 bgcolor=color.new(color.black, 70),
                                 border_width=1,
                                 border_color=color.new(color.gray, 70))

    headerBg = color.new(color.black, 30)
    table.cell(matrix, 0, 0, "MTF VWAP MATRIX", text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(matrix, 1, 0, "Distance",        text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(matrix, 2, 0, "Bias",            text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.cell(matrix, 3, 0, "Slope",           text_color=color.white, text_size=size.small, bgcolor=headerBg)

    rowIndex = 1
    if sessionA.enabled
        renderAnchorRow(matrix, rowIndex, sessionA, primaryId == ANCHOR_SESSION)
        rowIndex += 1
    if dailyA.enabled
        renderAnchorRow(matrix, rowIndex, dailyA, primaryId == ANCHOR_DAILY)
        rowIndex += 1
    if weeklyA.enabled
        renderAnchorRow(matrix, rowIndex, weeklyA, primaryId == ANCHOR_WEEKLY)
        rowIndex += 1
    if monthlyA.enabled
        renderAnchorRow(matrix, rowIndex, monthlyA, primaryId == ANCHOR_MONTHLY)
        rowIndex += 1
    if quarterlyA.enabled
        renderAnchorRow(matrix, rowIndex, quarterlyA, primaryId == ANCHOR_QUARTERLY)
        rowIndex += 1

    scoreTxt = str.tostring(confluence.score, "0") + "/100"
    table.cell(matrix, 0, rowIndex, "SCORE",   text_color=color.white,    text_size=size.small, bgcolor=headerBg)
    table.merge_cells(matrix, 1, rowIndex, 3, rowIndex)
    table.cell(matrix, 1, rowIndex, scoreTxt,  text_color=confluence.tone, text_size=size.small, bgcolor=headerBg)
    rowIndex += 1

    summaryTxt = str.tostring(confluence.bullish) + "/" + str.tostring(confluence.active) + "  " + confluence.label
    table.cell(matrix, 0, rowIndex, "ALIGN",   text_color=color.white,     text_size=size.small, bgcolor=headerBg)
    table.merge_cells(matrix, 1, rowIndex, 3, rowIndex)
    table.cell(matrix, 1, rowIndex, summaryTxt, text_color=confluence.tone, text_size=size.small, bgcolor=headerBg)
    rowIndex += 1

    divLabel = divergence == 1 ? "ST↑ vs LT↓" : divergence == -1 ? "ST↓ vs LT↑" : "ALIGNED"
    divCol   = divergence != 0 ? color.new(color.orange, 0) : neutralColor
    table.cell(matrix, 0, rowIndex, "DIVERG",  text_color=color.white, text_size=size.small, bgcolor=headerBg)
    table.merge_cells(matrix, 1, rowIndex, 3, rowIndex)
    table.cell(matrix, 1, rowIndex, divLabel,  text_color=divCol,      text_size=size.small, bgcolor=headerBg)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
bullishCount  = confluence.bullish
bearishCount  = confluence.bearish
activeCount   = confluence.active
primaryValue  = primary.value
divergenceVal = divergence

fullBullishFlip    = bullishCount == activeCount and activeCount > 0 and bullishCount[1] != activeCount
fullBearishFlip    = bearishCount == activeCount and activeCount > 0 and bearishCount[1] != activeCount
divergenceAppeared = divergenceVal != 0 and divergenceVal[1] == 0

alertcondition(fullBullishFlip, title="Full Bullish Alignment",
              message="MTF VWAP Matrix: ALL anchors flipped BULLISH — institutional alignment achieved")
alertcondition(fullBearishFlip, title="Full Bearish Alignment",
              message="MTF VWAP Matrix: ALL anchors flipped BEARISH — institutional alignment achieved")
alertcondition(ta.crossover(close,  primaryValue), title="Cross Above Primary VWAP",
              message="MTF VWAP Matrix: Price crossed ABOVE primary VWAP")
alertcondition(ta.crossunder(close, primaryValue), title="Cross Below Primary VWAP",
              message="MTF VWAP Matrix: Price crossed BELOW primary VWAP")
alertcondition(divergenceAppeared, title="VWAP Divergence Detected",
              message="MTF VWAP Matrix: Short-term and long-term VWAPs are diverging — institutional conflict")
````
