# Quantum Breakout AI [AnkeAlgo] 

- url: https://www.tradingview.com/script/sZ1DVm8m-Quantum-Breakout-AI-AnkeAlgo/
- type: indicator
- pine_id: PUB;382f722f38fb4c738db0938ea9f9513e
- version: 1.0

## Description

[image]https://www.tradingview.com/x/pfMUdvzG/[/image]

[b]Why Market Structure Needs a Quantum Leap[/b]

Most breakout indicators on TradingView suffer from a fundamental problem: they treat every range the same. A two-bar consolidation gets the same visual treatment as a fifty-bar compression zone with multiple rejections and volume anomalies. The result is noise — false signals, premature entries, and a chart cluttered with levels that have no context.

Quantum Breakout AI [AnkeAlgo] was built to solve exactly this. Instead of drawing static boxes, it treats each consolidation zone as a living structure with its own lifecycle, energy signature, and directional bias. The indicator doesn't just show you where price is compressing — it tells you how mature that compression is, how much energy has accumulated, whether the smart money has been active, and which direction the breakout is most likely to take. This is the difference between reading a map and reading the weather.

[b]The Core Concept: Zones as Living Structures[/b]

At the heart of this indicator is a custom data type called MarketStructureZone. Each zone stores not just its price boundaries, but a rich set of attributes that evolve bar by bar: power score, lifecycle stage, directional bias, rejection counts at both boundaries, VWAP level, whale activity score, and quality score. This isn't a static rectangle — it's a dynamic entity that the indicator continuously updates as long as price remains within the compression range.

The zone detection logic begins with a simple compression check: when the 5-bar range falls below the ATR multiplied by the Range ATR Mult input, the indicator starts tracking a potential zone. 
[pine]
bool showSLTP = input.bool(true, "SL/TP", group = "Core", inline = "core_3")
float slAtrMult = input.float(0.5, "SL ATR Mult", minval = 0.1, maxval = 2.0, step = 0.1, group = "Core", inline = "core_3")

int atrPeriod = input.int(14, "ATR Period", minval = 5, maxval = 50, group = "Detection", inline = "det_1")
float rangeATRMult = input.float(2.5, "Range ATR Mult", minval = 1.0, maxval = 5.0, step = 0.1, group = "Detection", inline = "det_1")
int minBarsInRange = input.int(15, "Min Bars", minval = 5, maxval = 100, group = "Detection", inline = "det_2")

bool showTP2 = input.bool(true, "Show TP2 (1.5R)", group = "Targets", inline = "tp_1")
bool showTP3 = input.bool(true, "Show TP3 (2R)", group = "Targets", inline = "tp_1")
int tp1CloseRatio = input.int(2, "TP1 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
int tp2CloseRatio = input.int(1, "TP2 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
int tp3CloseRatio = input.int(1, "TP3 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
color slColor = input.color(#FF6D00, "SL Color", group = "Targets", inline = "tp_3")
color tpColor = input.color(#00BFA5, "TP Color", group = "Targets", inline = "tp_3")
[/pine]
 This threshold is critical — it determines how sensitive the indicator is to consolidation patterns. A lower multiplier means more zones will be detected, including weaker ones. A higher multiplier filters for only the tightest compressions, which tend to produce more explosive breakouts but occur less frequently.

Once a zone is active, the indicator tracks every bar that stays within the boundaries (with a small tolerance buffer). Each bar extends the zone's duration and triggers a full recalculation of its attributes. The power score is computed from four components: squeeze ratio (how tight the range is relative to volatility), duration score (longer compressions accumulate more energy), age bonus for zones exceeding 30 bars, and tightness bonus for exceptionally narrow ranges. This multi-factor approach prevents the indicator from overvaluing long but loose consolidations or short but extremely tight ones.

[b]Directional Bias: Reading the Market's Intentions[/b]

One of the most sophisticated features is the directional bias analysis, which combines two independent signals. The first is VWAP positioning — by calculating the volume-weighted mean price within the zone and comparing it to the zone's midpoint, the indicator determines whether volume is concentrated toward the top or bottom. The second is rejection wick analysis, which counts how many times price touched each boundary but closed back inside the zone, with a significant wick. A high number of top rejections with long upper wicks suggests sellers are defending that level, while bottom rejections indicate buyer support.

These two signals are weighted 55% and 45% respectively to produce a final bias score. 
[pine]
bool showTP2 = input.bool(true, "Show TP2 (1.5R)", group = "Targets", inline = "tp_1")
bool showTP3 = input.bool(true, "Show TP3 (2R)", group = "Targets", inline = "tp_1")
int tp1CloseRatio = input.int(2, "TP1 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
int tp2CloseRatio = input.int(1, "TP2 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
int tp3CloseRatio = input.int(1, "TP3 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
color slColor = input.color(#FF6D00, "SL Color", group = "Targets", inline = "tp_3")
color tpColor = input.color(#00BFA5, "TP Color", group = "Targets", inline = "tp_3")

float energyHighThresh = input.float(60.0, "High Threshold", minval = 30.0, maxval = 80.0, group = "Energy", inline = "en_1")
float energyCriticalThresh = input.float(80.0, "Critical Threshold", minval = 50.0, maxval = 100.0, group = "Energy", inline = "en_1")
[/pine]
 The weighting reflects the developer's research that volume positioning is slightly more reliable than wick analysis, but both are necessary — volume tells you where the money is, while wicks tell you where the resistance is. The confidence score is then clamped between 50 and 100, with the Min Confidence % input filtering out zones where the bias isn't strong enough to display a directional marker.

[b]Whale Activity and Zone Quality[/b]

The whale activity detection adds another layer of sophistication. The indicator scans each zone for bars where volume exceeds the configured multiplier times the 20-bar average volume, but only if price stayed within the zone boundaries. This filters out volume spikes caused by breakouts or breakdowns and focuses on accumulation or distribution within the range. Each anomalous volume bar contributes to a score that combines the frequency of spikes with their intensity.

The final quality score is a weighted composite of four factors: power score (35%), whale activity (20%), lifecycle stage value (25%), and directional confidence (20%). The lifecycle stage value peaks at the Mature phase (80 points), reflecting the developer's observation that zones typically reach maximum breakout potential just before they begin to exhaust. This scoring system allows the indicator to rank zones by quality, which is particularly useful when multiple zones are visible on the chart.

[b]Visual Design[/b]

The visual presentation is deliberately cinematic. Each zone is rendered as a two-layer stereo box — a shadow layer offset slightly downward in price to create a 3D depth effect, and a main layer with a semi-transparent cyan fill and border. This isn't just aesthetic; the depth effect helps zones stand out against the price action, making it immediately obvious which areas of the chart have been analyzed.

The energy bar sits below each zone and provides a real-time visual of the power score. The bar's fill color transitions through four stages: green for low energy (below 40), blue for medium (40 to high threshold), purple for high (high threshold to critical threshold), and red for critical (above critical threshold). This color coding creates an intuitive heat map — the eye is drawn to zones where the energy is building toward critical levels.

Directional bias markers appear as "B" or "S" labels with colored backgrounds, positioned relative to the zone's energy bar. These only display when the confidence score meets the minimum threshold, preventing the chart from becoming cluttered with low-conviction signals.

[b]Trade Management: From Detection to Execution[/b]

When a breakout occurs, the indicator automatically calculates complete trade management levels. The entry is set at the breached boundary, the stop loss is placed on the opposite side of the zone plus an ATR buffer, and take-profit levels are calculated at 1R, 1.5R, and 2R. The ATR buffer on the stop is critical — it prevents the stop from being placed exactly at the zone boundary, where it could be triggered by a wick or a false breakout retest.

The partial position closing logic is particularly sophisticated. The indicator tracks three separate close ratios for TP1, TP2, and TP3, allowing traders to scale out of positions. For example, with TP1 Close Ratio set to 2, TP2 to 1, and TP3 to 1, the trader would close 50% of the position at TP1, 25% at TP2, and 25% at TP3. The statistics system tracks these partial closes independently, calculating weighted P&L contributions for each target.

[pine]
bool showStatsTable = input.bool(true, "Stats Table", group = "Stats")
string statsRangePreset = input.string("Last 90 Days", "Range Preset", options = ["All", "Custom", "Last 30 Days", "Last 90 Days", "Last 180 Days", "Year 2025"], group = "Stats")
const int defaultStatsStart = 1704067200000
const int defaultStatsEnd = 4102358400000
int statsStartTime = input.time(defaultStatsStart, "Start", group = "Stats", inline = "stats_1")
int statsEndTime = input.time(defaultStatsEnd, "End", group = "Stats", inline = "stats_1")

int maxDisplayBars = input.int(2000, "Max Lookback Bars", minval = 300, maxval = 20000, step = 100, group = "Advanced")
int maxZonesToKeep = input.int(1500, "Max Stored Zones", minval = 50, maxval = 5000, group = "Advanced", inline = "adv_1")
int maxZonesToDraw = input.int(400, "Max Drawn Zones", minval = 50, maxval = 500, group = "Advanced", inline = "adv_1")
int activeExtendBars = input.int(5, "Active Extend Bars", minval = 0, maxval = 100, group = "Advanced", inline = "adv_2")
int maxBoxBudget = input.int(450, "Max Box Objects", minval = 50, maxval = 500, group = "Advanced", inline = "adv_2")
int maxLineBudget = input.int(450, "Max Line Objects", minval = 50, maxval = 500, group = "Advanced")
float volAnomalyMult = input.float(2.0, "Volume Anomaly Multiplier", minval = 1.5, maxval = 4.0, step = 0.1, group = "Advanced")
[/pine]
 The trade exit logic handles three scenarios: hitting the stop loss, hitting the final take-profit level, or a new zone forming while a trade is active. This last case is important — if price consolidates again after a breakout, the indicator closes the existing trade to avoid holding through another compression phase.

[b]The Statistics Engine: Honest Performance Tracking[/b]

The statistics table is not a backtesting engine, but it provides honest, transparent tracking of every zone that triggered a trade. It filters trades by the configured time range (Last 30 Days, Last 90 Days, Year 2025, or custom dates) and displays total orders, long/short breakdown, TP wins, stop losses, total return percentage, and win rate.

The total return calculation uses equity curve compounding — each trade's P&L percentage is applied multiplicatively to a starting equity of 1.0. This is more accurate than simple summation because it accounts for the compounding effect of consecutive wins and losses. The win rate is calculated only against closed trades (those that hit either a target or the stop), excluding trades that are still active or were closed by new zone formation.

[b]Limitations and Realistic Expectations[/b]

No indicator is perfect, and Quantum Breakout AI has specific conditions where it performs best and worst. The zone detection relies on compression, which means it will generate fewer signals during strong trending markets where price rarely consolidates. The energy scoring system can produce high scores for zones that ultimately fail — energy is a measure of potential, not certainty.

The ATR-based parameters need careful tuning for each instrument. A Range ATR Mult of 2.5 that works well on Bitcoin may be too tight for Apple stock or too loose for a low-volatility forex pair. Similarly, the SL ATR Mult of 0.5 may need adjustment based on how much noise the instrument typically has at the zone boundaries.

The statistics table should be interpreted with caution. It reflects historical performance within the configured range, but market regimes change. A 70% win rate over the last 90 days does not guarantee the next 90 days will be similar. The indicator is a tool for analysis and visualization, not a crystal ball.

[b]Best Use Cases and Practical Application[/b]

This indicator shines in range-bound and consolidating markets where traditional trend-following tools struggle. Swing traders can use the zone quality score to prioritize the strongest setups, focusing on zones that reach the Mature lifecycle stage with high energy and strong directional bias. The imminent breakout alert provides a warning when a zone reaches critical energy levels, allowing traders to prepare for the move without watching the chart constantly.

The partial position closing system is ideal for traders who want to lock in profits while letting runners develop. By configuring the close ratios, traders can create custom risk management profiles — conservative traders might close 70% at TP1, while aggressive traders might close only 30% and let the rest ride to TP3.

For quantitative traders, the zone attributes provide rich data for further analysis. The power score, quality score, and directional confidence can be exported or used as inputs to other systems. The whale activity detection offers insights into institutional behavior that most retail tools miss entirely.

## Source Code

````pine
    //@version=6

indicator("Quantum Breakout AI [AnkeAlgo] ", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100, max_bars_back = 2000)

bool showBreakoutArrows = input.bool(true, "Breakout Arrows", group = "Core", inline = "core_1")
bool showDirection = input.bool(true, "Direction Marker", group = "Core", inline = "core_1")

bool showEnergyBar = input.bool(true, "Energy Bar", group = "Core", inline = "core_2")
bool showEnergyPercent = input.bool(true, "Show %", group = "Core", inline = "core_2")

bool showSLTP = input.bool(true, "SL/TP", group = "Core", inline = "core_3")
float slAtrMult = input.float(0.5, "SL ATR Mult", minval = 0.1, maxval = 2.0, step = 0.1, group = "Core", inline = "core_3")

int atrPeriod = input.int(14, "ATR Period", minval = 5, maxval = 50, group = "Detection", inline = "det_1")
float rangeATRMult = input.float(2.5, "Range ATR Mult", minval = 1.0, maxval = 5.0, step = 0.1, group = "Detection", inline = "det_1")
int minBarsInRange = input.int(15, "Min Bars", minval = 5, maxval = 100, group = "Detection", inline = "det_2")

bool showTP2 = input.bool(true, "Show TP2 (1.5R)", group = "Targets", inline = "tp_1")
bool showTP3 = input.bool(true, "Show TP3 (2R)", group = "Targets", inline = "tp_1")
int tp1CloseRatio = input.int(2, "TP1 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
int tp2CloseRatio = input.int(1, "TP2 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
int tp3CloseRatio = input.int(1, "TP3 Close Ratio", minval = 1, maxval = 10, group = "Targets", inline = "tp_2")
color slColor = input.color(#FF6D00, "SL Color", group = "Targets", inline = "tp_3")
color tpColor = input.color(#00BFA5, "TP Color", group = "Targets", inline = "tp_3")

float energyHighThresh = input.float(60.0, "High Threshold", minval = 30.0, maxval = 80.0, group = "Energy", inline = "en_1")
float energyCriticalThresh = input.float(80.0, "Critical Threshold", minval = 50.0, maxval = 100.0, group = "Energy", inline = "en_1")

bool showStatsTable = input.bool(true, "Stats Table", group = "Stats")
string statsRangePreset = input.string("Last 90 Days", "Range Preset", options = ["All", "Custom", "Last 30 Days", "Last 90 Days", "Last 180 Days", "Year 2025"], group = "Stats")
const int defaultStatsStart = 1704067200000
const int defaultStatsEnd = 4102358400000
int statsStartTime = input.time(defaultStatsStart, "Start", group = "Stats", inline = "stats_1")
int statsEndTime = input.time(defaultStatsEnd, "End", group = "Stats", inline = "stats_1")

int maxDisplayBars = input.int(2000, "Max Lookback Bars", minval = 300, maxval = 20000, step = 100, group = "Advanced")
int maxZonesToKeep = input.int(1500, "Max Stored Zones", minval = 50, maxval = 5000, group = "Advanced", inline = "adv_1")
int maxZonesToDraw = input.int(400, "Max Drawn Zones", minval = 50, maxval = 500, group = "Advanced", inline = "adv_1")
int activeExtendBars = input.int(5, "Active Extend Bars", minval = 0, maxval = 100, group = "Advanced", inline = "adv_2")
int maxBoxBudget = input.int(450, "Max Box Objects", minval = 50, maxval = 500, group = "Advanced", inline = "adv_2")
int maxLineBudget = input.int(450, "Max Line Objects", minval = 50, maxval = 500, group = "Advanced")
float volAnomalyMult = input.float(2.0, "Volume Anomaly Multiplier", minval = 1.5, maxval = 4.0, step = 0.1, group = "Advanced")

float dirConfidenceMin = input.float(55.0, "Min Confidence %", minval = 50.0, maxval = 90.0, group = "Advanced")

color bullColor = input.color(#00E676, "Bullish Color", group = "Colors")
color bearColor = input.color(#FF5252, "Bearish Color", group = "Colors")
color neutralColor = input.color(#9E9E9E, "Neutral Color", group = "Colors")
color boxMainColor = input.color(#00E5FF, "Box Main Color", group = "Colors")
color energyLowColor = input.color(#4CAF50, "Energy Low", group = "Colors")
color energyMedColor = input.color(#2979FF, "Energy Medium", group = "Colors")
color energyHighColor = input.color(#AA00FF, "Energy High", group = "Colors")
color energyCritColor = input.color(#F44336, "Energy Critical", group = "Colors")

bool alertNewZone = input.bool(true, "Alert: New Zone", group = "Alerts")
bool alertImminent = input.bool(true, "Alert: Imminent Breakout", group = "Alerts")
bool alertBreakout = input.bool(true, "Alert: Breakout", group = "Alerts")

const float tp1Ratio = 1.0
const float tp2Ratio = 1.5
const float tp3Ratio = 2.0

var string PHASE_FORMING = "Forming"
var string PHASE_GROWTH = "Growth"
var string PHASE_MATURE = "Mature"
var string PHASE_EXHAUSTION = "Exhaustion"

var string DIR_BULLISH = "Bullish"
var string DIR_BEARISH = "Bearish"
var string DIR_NEUTRAL = "Neutral"

// ══════════════════════════════════════════════════════════════════════════════
// ████████  Data Structure | 数据结构  ████████
// ══════════════════════════════════════════════════════════════════════════════

type MarketStructureZone
    int startIdx
    int endIdx
    float upperLevel
    float lowerLevel
    float powerScore
    string lifeCycle
    string biasDir
    float biasStrength
    float qualityScore
    int topRejections
    int btmRejections
    float vwapLevel
    float whaleActivity
    bool isLive
    bool isBreached
    string breakSide
    float entryPx
    float stopPx
    float takeProfit1
    float takeProfit2
    float takeProfit3
    float rrr
    float labelY

var array<MarketStructureZone> zoneHistory = array.new<MarketStructureZone>()
var MarketStructureZone currentZone = na

var array<box> drawnBoxes = array.new<box>()
var array<line> drawnLines = array.new<line>()
var array<polyline> drawnPolys = array.new<polyline>()
var array<label> drawnLabels = array.new<label>()

float atrVal = ta.atr(atrPeriod)
float avgVol = ta.sma(volume, 20)

var float rangeHigh = na
var float rangeLow = na
var int rangeStartBar = na
var int barsInRange = 0

var float entryPlot = na
var float slPlot = na
var float tp1Plot = na
var float tp2Plot = na
var float tp3Plot = na

var bool tradeActive = false
var bool tradeIsBull = false
var int tradeExitBar = na
var int lastTradeZoneStart = na
var int lastTradeBreakBar = na

var array<int> statEntryTimes = array.new<int>()
var array<bool> statIsLongArr = array.new<bool>()
var array<int> statStatusArr = array.new<int>()
var array<float> statEntryPriceArr = array.new<float>()
var array<float> statPnLPctArr = array.new<float>()
var array<float> statTP1PnLArr = array.new<float>()
var array<float> statTP2PnLArr = array.new<float>()
var array<float> statTP3PnLArr = array.new<float>()

var int statActiveIdx = na
var bool statActive = false
var bool statIsLong = false
var float statEntry = na
var float statSL = na
var float statTP1 = na
var float statTP2 = na
var float statTP3 = na

int totalRatio = tp1CloseRatio + tp2CloseRatio + tp3CloseRatio
var int statTP1Closed = 0
var int statTP2Closed = 0
var int statTP3Closed = 0
var int statRemainingPos = totalRatio

clearAllDrawings() =>
    for b in drawnBoxes
        box.delete(b)
    drawnBoxes.clear()
    for ln in drawnLines
        line.delete(ln)
    drawnLines.clear()
    for p in drawnPolys
        polyline.delete(p)
    drawnPolys.clear()
    for lb in drawnLabels
        label.delete(lb)
    drawnLabels.clear()

isInDisplayRange(int startBar) =>
    bar_index - startBar <= maxDisplayBars

computeCompressionScore(int dur, float h, float volatility) =>
    if h <= 0 or volatility <= 0 or dur <= 0
        0.0
    else
        // 调整系数：50 -> 45
        float squeezeRatio = volatility / h
        float squeezeScore = math.min(squeezeRatio * 45, 40)
        float durationScore = math.min(dur * 2, 35)
        float ageBonus = dur >= 30 ? 15 : dur >= 20 ? 10 : dur >= 15 ? 5 : 0
        float tightBonus = h < volatility * 0.5 ? 10 : h < volatility * 0.75 ? 5 : 0
        float rawPower = squeezeScore + durationScore + ageBonus + tightBonus
        math.min(math.max(rawPower, 5), 100)

getVolumeWeightedMean(float upper, float lower, int t1, int t2) =>
    float priceVolSum = 0.0
    float volSum = 0.0
    int len = math.min(math.min(t2 - t1, 500), t2)
    if len > 0
        for i = 0 to len - 1
            float mp = (high[i] + low[i] + close[i]) / 3
            if mp <= upper and mp >= lower
                priceVolSum += mp * volume[i]
                volSum += volume[i]
    volSum > 0 ? priceVolSum / volSum : (upper + lower) / 2

getRejectionCount(float lvl, float tol, int t1, int t2, bool checkHigh) =>
    int cnt = 0
    int len = math.min(math.min(t2 - t1, 500), t2)
    if len > 0
        for i = 0 to len - 1
            bool isTouch = checkHigh ? (high[i] >= lvl - tol and high[i] <= lvl + tol) : (low[i] >= lvl - tol and low[i] <= lvl + tol)
            bool isWick = checkHigh ? (close[i] < high[i] - tol) : (close[i] > low[i] + tol)
            if isTouch and isWick
                cnt += 1
    cnt

analyzeBreakoutBias(float vwap, float upper, float lower, int topRej, int btmRej) =>
    float h = upper - lower
    float mid = (upper + lower) / 2
    // 调整权重：0.6 -> 0.55, 0.4 -> 0.45
    float volBias = (vwap - mid) / (h / 2)
    float wickBias = topRej > 0 or btmRej > 0 ? (btmRej - topRej) / math.max(topRej + btmRej, 1) : 0.0
    float totalBias = volBias * 0.55 + wickBias * 0.45
    float conf = math.abs(totalBias) * 100
    string side = totalBias > 0.1 ? DIR_BULLISH : totalBias < -0.1 ? DIR_BEARISH : DIR_NEUTRAL
    [side, math.min(conf + 50, 100.0)]

scanWhaleActivity(int t1, int t2, float upper, float lower) =>
    float score = 0.0
    int spikes = 0
    float spikeVol = 0.0
    int len = math.min(math.min(t2 - t1, 500), t2)
    if len > 0
        for i = 0 to len - 1
            if high[i] <= upper and low[i] >= lower
                if volume[i] > avgVol * volAnomalyMult
                    spikes += 1
                    spikeVol += volume[i]
    float spikeRatio = len > 0 ? spikes / len * 100 : 0
    float intensity = avgVol > 0 and spikes > 0 ? spikeVol / (avgVol * spikes) : 0
    // 调整系数
    score := spikeRatio * 0.6 + math.min(intensity * 8, 50)
    math.min(score, 100.0)

determineLifecycle(int d) =>
    d < 10 ? PHASE_FORMING : d < 25 ? PHASE_GROWTH : d < 50 ? PHASE_MATURE : PHASE_EXHAUSTION

evaluateZoneQuality(float pwr, float whale, string cycle, float conf) =>
    float cycleVal = switch cycle
        PHASE_FORMING => 20.0
        PHASE_GROWTH => 50.0
        PHASE_MATURE => 80.0
        PHASE_EXHAUSTION => 60.0
        => 50.0
    // 调整权重
    float q = pwr * 0.35 + whale * 0.2 + cycleVal * 0.25 + conf * 0.2
    math.min(q, 100.0)

getEnergyColor(float energy) =>
    energy >= energyCriticalThresh ? energyCritColor : energy >= energyHighThresh ? energyHighColor : energy >= 40 ? energyMedColor : energyLowColor

getDirectionColor(string dir) =>
    dir == DIR_BULLISH ? bullColor : dir == DIR_BEARISH ? bearColor : neutralColor

getPhaseText(string phase) =>
    switch phase
        PHASE_FORMING => "⚒ Forming"
        PHASE_GROWTH => "📈 Growth"
        PHASE_MATURE => "✅ Mature"
        PHASE_EXHAUSTION => "⚠ Exhaustion"
        => "Unknown"

// 3D 科技感箱体绘制（带阴影立体效果 + 背景填充）
drawStereoBox(int leftBar, int rightBar, float top, float bottom, bool isActive, bool isBroken, string breakDir, string direction, float dirConfidence, float minConfidence) =>
    // 需要 2 个 Box 的预算 (阴影 + 主体)
    if isInDisplayRange(leftBar) and drawnBoxes.size() + 2 <= maxBoxBudget
        float h = top - bottom
        // 1. 阴影层：向右下偏移，深色半透明
        // 注意：Pine Script box 坐标是 Bar Index，无法做小数偏移，只能偏移价格
        // 这里我们做一个简单的价格偏移模拟 "厚度"
        float shadowOffset = h * 0.05
        box shadow = box.new(leftBar, top - shadowOffset, rightBar, bottom - shadowOffset, border_color = na, border_width = 0, bgcolor = color.new(color.black, 60))
        drawnBoxes.push(shadow)

        // 2. 主体层：带背景色和边框
        // 背景色：使用主色调，但透明度较高 (85%)
        color mainBg = color.new(boxMainColor, 85)
        color mainBorder = color.new(boxMainColor, 0)
        
        box mainBox = box.new(leftBar, top, rightBar, bottom, border_color = mainBorder, border_width = 1, bgcolor = mainBg)
        drawnBoxes.push(mainBox)

// 能量条优化：增强对比度与视觉效果
drawEnergyBar(int leftBar, int rightBar, float bottom, float energy, float rangeHeight, bool showPercent) =>
    int neededBoxes = 1 + (energy > 0 ? 1 : 0)
    if isInDisplayRange(leftBar) and drawnBoxes.size() + neededBoxes <= maxBoxBudget
        int barWidth = rightBar - leftBar
        int filledWidth = math.round(barWidth * (energy / 100))
        // 增加高度：0.18 -> 0.25 (更厚实)
        float barHeight = rangeHeight * 0.25
        float barBottom = bottom - barHeight * 2
        float barTop = barBottom + barHeight

        string pctText = showPercent ? str.tostring(energy, "#") + "%" : ""
        // 1. 背景框：纯背景，不带文字
        box bg = box.new(leftBar, barTop, rightBar, barBottom, border_color = color.new(color.gray, 50), border_width = 1, bgcolor = color.new(color.black, 20))
        drawnBoxes.push(bg)

        // 2. 填充条：中间层
        if filledWidth > 0
            color barColor = getEnergyColor(energy)
            drawnBoxes.push(box.new(leftBar, barTop, leftBar + filledWidth, barBottom, border_color = na, border_width = 0, bgcolor = color.new(barColor, 20)))

        // 3. 文字层：最顶层，透明背景，确保文字不被遮挡
        if showPercent
            box txtBox = box.new(leftBar, barTop, rightBar, barBottom, border_color = na, border_width = 0, bgcolor = color.new(color.white, 100), text = pctText, text_size = size.normal, text_color = color.white, text_halign = text.align_center, text_valign = text.align_center)
            drawnBoxes.push(txtBox)

drawPressureLines(int leftBar, int rightBar, float top, float bottom, float gravityCenter) =>
    if isInDisplayRange(leftBar)
        float rangeH = top - bottom
        float mid = (top + bottom) / 2
        int numLines = 5

        for i = 1 to numLines
            float ratio = i / (numLines + 1.0)
            float y = bottom + rangeH * ratio

            float distFromGravity = math.abs(y - gravityCenter) / rangeH
            int transp = math.round(70 + distFromGravity * 25)

            color lineColor = y > mid ? color.new(bearColor, transp) : color.new(bullColor, transp)
            drawnLines.push(line.new(leftBar, y, rightBar, y, color = lineColor, style = line.style_dotted, width = 1))

drawSLTPLines(int leftBar, int rightBar, float slPrice, float tp1Price, float tp2Price, float tp3Price, float entryPrice, string breakDir, bool isWin) =>
    int needLines = 3 + (showTP2 ? 1 : 0) + (showTP3 ? 1 : 0)
    int needLabels = needLines
    // 需要额外的 Box 预算用于渐变填充 (如果获胜)
    int needBoxes = isWin ? 1 : 0

    if isInDisplayRange(leftBar) and drawnLines.size() + needLines <= maxLineBudget and drawnLabels.size() + needLabels <= 500 and drawnBoxes.size() + needBoxes <= maxBoxBudget
        int lineEnd = rightBar

        // 1. 如果获胜，绘制渐变背景 (Entry 到 TP1/2/3)
        // 这里简化为绘制到 TP1 或最终 TP，根据实际触达情况比较复杂，这里暂且绘制到 TP1 作为获胜区域示意
        // 或者如果 isWin 为真，我们假设至少到达了 TP1，绘制 Entry 到 TP1 的区域
        if isWin
            // 渐变填充：使用 Box 模拟 (Pine 6 支持 fill，但这里用 box 更方便控制生命周期)
            // 使用 TP1 作为填充目标
            color fillCol = breakDir == DIR_BULLISH ? color.new(bullColor, 80) : color.new(bearColor, 80)
            drawnBoxes.push(box.new(leftBar, entryPrice, lineEnd, tp1Price, border_color = na, bgcolor = fillCol))

        // 2. 绘制线条和标签
        // Entry
        drawnLines.push(line.new(leftBar, entryPrice, lineEnd, entryPrice, color = color.new(color.white, 50), style = line.style_dashed, width = 1))
        
        // SL
        drawnLines.push(line.new(leftBar, slPrice, lineEnd, slPrice, color = slColor, style = line.style_solid, width = 2))
        drawnLabels.push(label.new(leftBar, slPrice, str.tostring(slPrice, format.mintick), style = label.style_none, textcolor = slColor, size = size.small, textalign = text.align_right))

        // TP1
        drawnLines.push(line.new(leftBar, tp1Price, lineEnd, tp1Price, color = color.new(tpColor, 30), style = line.style_dashed, width = 1))
        drawnLabels.push(label.new(leftBar, tp1Price, str.tostring(tp1Price, format.mintick), style = label.style_none, textcolor = tpColor, size = size.small, textalign = text.align_right))

        // TP2
        if showTP2
            drawnLines.push(line.new(leftBar, tp2Price, lineEnd, tp2Price, color = color.new(tpColor, 20), style = line.style_dashed, width = 1))
            drawnLabels.push(label.new(leftBar, tp2Price, str.tostring(tp2Price, format.mintick), style = label.style_none, textcolor = tpColor, size = size.small, textalign = text.align_right))

        // TP3
        if showTP3
            drawnLines.push(line.new(leftBar, tp3Price, lineEnd, tp3Price, color = color.new(tpColor, 10), style = line.style_solid, width = 2))
            drawnLabels.push(label.new(leftBar, tp3Price, str.tostring(tp3Price, format.mintick), style = label.style_none, textcolor = tpColor, size = size.small, textalign = text.align_right))

bool onClose = barstate.isconfirmed

bool breakoutUp = onClose and not na(currentZone) and currentZone.isLive and close > currentZone.upperLevel
bool breakoutDn = onClose and not na(currentZone) and currentZone.isLive and close < currentZone.lowerLevel
bool isBreakout = breakoutUp or breakoutDn

bool longArrow = showBreakoutArrows and breakoutUp
bool shortArrow = showBreakoutArrows and breakoutDn

if isBreakout and not na(currentZone)
    if statActive and not na(statActiveIdx)
        float pnlPct = statIsLong ? (close - statEntry) / statEntry * 100.0 : (statEntry - close) / statEntry * 100.0
        float weightedPnL = pnlPct * statRemainingPos / totalRatio
        float tp1PnL = statTP1PnLArr.get(statActiveIdx)
        float tp2PnL = statTP2PnLArr.get(statActiveIdx)
        float tp3PnL = statTP3PnLArr.get(statActiveIdx)
        float tpSum = (na(tp1PnL) ? 0.0 : tp1PnL) + (na(tp2PnL) ? 0.0 : tp2PnL) + (na(tp3PnL) ? 0.0 : tp3PnL)
        float totalPnL = tpSum + weightedPnL
        int status = totalPnL >= 0 ? 1 : -1
        statStatusArr.set(statActiveIdx, status)
        statPnLPctArr.set(statActiveIdx, totalPnL)
        
        statActive := false
        statActiveIdx := na
        statIsLong := false
        statEntry := na
        statSL := na
        statTP1 := na
        statTP2 := na
        statTP3 := na

    currentZone.isLive := false
    currentZone.isBreached := true
    currentZone.breakSide := breakoutUp ? DIR_BULLISH : DIR_BEARISH
    currentZone.endIdx := bar_index

    float atrBuffer = atrVal * slAtrMult

    if breakoutUp
        currentZone.entryPx := currentZone.upperLevel
        currentZone.stopPx := currentZone.lowerLevel - atrBuffer
        float riskAmount = currentZone.entryPx - currentZone.stopPx
        currentZone.takeProfit1 := currentZone.entryPx + (riskAmount * tp1Ratio)
        currentZone.takeProfit2 := currentZone.entryPx + (riskAmount * tp2Ratio)
        currentZone.takeProfit3 := currentZone.entryPx + (riskAmount * tp3Ratio)
        currentZone.rrr := tp2Ratio
        float yOffset = math.max(syminfo.mintick * 20.0, atrVal * 0.1)
        if showDirection and currentZone.biasDir == DIR_BULLISH and currentZone.biasStrength >= dirConfidenceMin
            // 多头信号绘制在能量条下方 (能量条底部 = lower - 0.5 * height)
            float rangeH = currentZone.upperLevel - currentZone.lowerLevel
            float energyBottom = currentZone.lowerLevel - (rangeH * 0.5)
            currentZone.labelY := energyBottom - yOffset
    else
        currentZone.entryPx := currentZone.lowerLevel
        currentZone.stopPx := currentZone.upperLevel + atrBuffer
        float riskAmount = currentZone.stopPx - currentZone.entryPx
        currentZone.takeProfit1 := currentZone.entryPx - (riskAmount * tp1Ratio)
        currentZone.takeProfit2 := currentZone.entryPx - (riskAmount * tp2Ratio)
        currentZone.takeProfit3 := currentZone.entryPx - (riskAmount * tp3Ratio)
        currentZone.rrr := tp2Ratio
        float yOffset = math.max(syminfo.mintick * 20.0, atrVal * 0.1)
        if showDirection and currentZone.biasDir == DIR_BEARISH and currentZone.biasStrength >= dirConfidenceMin
            currentZone.labelY := currentZone.stopPx + yOffset

    entryPlot := currentZone.entryPx
    slPlot := currentZone.stopPx
    tp1Plot := currentZone.takeProfit1
    tp2Plot := currentZone.takeProfit2
    tp3Plot := currentZone.takeProfit3

    tradeActive := true
    tradeIsBull := breakoutUp
    tradeExitBar := na
    lastTradeZoneStart := currentZone.startIdx
    lastTradeBreakBar := bar_index

    int newIdx = statEntryTimes.size()
    statEntryTimes.push(time)
    statIsLongArr.push(breakoutUp)
    statStatusArr.push(0)
    statEntryPriceArr.push(currentZone.entryPx)
    statPnLPctArr.push(na)
    statTP1PnLArr.push(0.0)
    statTP2PnLArr.push(0.0)
    statTP3PnLArr.push(0.0)
    statActiveIdx := newIdx
    statActive := true
    statIsLong := breakoutUp
    statEntry := currentZone.entryPx
    statSL := currentZone.stopPx
    statTP1 := currentZone.takeProfit1
    statTP2 := currentZone.takeProfit2
    statTP3 := currentZone.takeProfit3
    statTP1Closed := 0
    statTP2Closed := 0
    statTP3Closed := 0
    statRemainingPos := totalRatio

if onClose and tradeActive and not na(slPlot)
    bool hitSL = tradeIsBull ? low <= slPlot : high >= slPlot
    float finalTp = showTP3 and not na(tp3Plot) ? tp3Plot : showTP2 and not na(tp2Plot) ? tp2Plot : tp1Plot
    bool hitFinalTP = not na(finalTp) and (tradeIsBull ? high >= finalTp : low <= finalTp)
    if hitSL or hitFinalTP
        tradeExitBar := bar_index
        tradeActive := false
        entryPlot := na
        slPlot := na
        tp1Plot := na
        tp2Plot := na
        tp3Plot := na

float lookbackHigh = ta.highest(high, 5)
float lookbackLow = ta.lowest(low, 5)
float currentRange = lookbackHigh - lookbackLow
bool isCompressed = currentRange < atrVal * rangeATRMult

if onClose
    if isCompressed
        if na(rangeHigh)
            rangeHigh := lookbackHigh
            rangeLow := lookbackLow
            rangeStartBar := bar_index - 4
            barsInRange := 5
        else
            if high <= rangeHigh + atrVal * 0.1 and low >= rangeLow - atrVal * 0.1
                rangeHigh := math.max(rangeHigh, high)
                rangeLow := math.min(rangeLow, low)
                barsInRange += 1
            else
                rangeHigh := na
                rangeLow := na
                barsInRange := 0
    else
        if not na(rangeHigh) and barsInRange >= minBarsInRange
            if not na(currentZone)
                currentZone.isLive := false
                currentZone.endIdx := bar_index - 1
        rangeHigh := na
        rangeLow := na
        barsInRange := 0

bool newZoneFormed = onClose and barsInRange == minBarsInRange and not na(rangeHigh)

if onClose and tradeActive and newZoneFormed and bar_index > lastTradeBreakBar
    tradeExitBar := bar_index
    tradeActive := false
    entryPlot := na
    slPlot := na
    tp1Plot := na
    tp2Plot := na
    tp3Plot := na

// if onClose and statActive and newZoneFormed and not na(statActiveIdx)
//     statStatusArr.set(statActiveIdx, 2)
//     statPnLPctArr.set(statActiveIdx, na)
//     statActive := false
//     statActiveIdx := na
//     statIsLong := false
//     statEntry := na
//     statSL := na
//     statTP1 := na

if onClose and statActive and not na(statActiveIdx) and not na(statEntry) and not na(statSL) and not na(statTP1)
    bool slHit = statIsLong ? low <= statSL : high >= statSL
    bool tp1Hit = statIsLong ? high >= statTP1 : low <= statTP1
    bool tp2Hit = not na(statTP2) and (statIsLong ? high >= statTP2 : low <= statTP2)
    bool tp3Hit = not na(statTP3) and (statIsLong ? high >= statTP3 : low <= statTP3)
    
    bool anyClosed = false
    
    if tp1Hit and statTP1Closed < tp1CloseRatio
        int closeCount = math.min(tp1CloseRatio - statTP1Closed, statRemainingPos)
        if closeCount > 0
            float pnlPct = statIsLong ? (statTP1 - statEntry) / statEntry * 100.0 : (statEntry - statTP1) / statEntry * 100.0
            float weightedPnL = pnlPct * closeCount / totalRatio
            statTP1PnLArr.set(statActiveIdx, statTP1PnLArr.get(statActiveIdx) + weightedPnL)
            statTP1Closed := statTP1Closed + closeCount
            statRemainingPos := statRemainingPos - closeCount
            anyClosed := true
    
    if tp2Hit and showTP2 and statTP2Closed < tp2CloseRatio
        int closeCount = math.min(tp2CloseRatio - statTP2Closed, statRemainingPos)
        if closeCount > 0
            float pnlPct = statIsLong ? (statTP2 - statEntry) / statEntry * 100.0 : (statEntry - statTP2) / statEntry * 100.0
            float weightedPnL = pnlPct * closeCount / totalRatio
            statTP2PnLArr.set(statActiveIdx, statTP2PnLArr.get(statActiveIdx) + weightedPnL)
            statTP2Closed := statTP2Closed + closeCount
            statRemainingPos := statRemainingPos - closeCount
            anyClosed := true
    
    if tp3Hit and showTP3 and statTP3Closed < tp3CloseRatio
        int closeCount = math.min(tp3CloseRatio - statTP3Closed, statRemainingPos)
        if closeCount > 0
            float pnlPct = statIsLong ? (statTP3 - statEntry) / statEntry * 100.0 : (statEntry - statTP3) / statEntry * 100.0
            float weightedPnL = pnlPct * closeCount / totalRatio
            statTP3PnLArr.set(statActiveIdx, statTP3PnLArr.get(statActiveIdx) + weightedPnL)
            statTP3Closed := statTP3Closed + closeCount
            statRemainingPos := statRemainingPos - closeCount
            anyClosed := true
    
    if slHit and statRemainingPos > 0
        float pnlPct = statIsLong ? (statSL - statEntry) / statEntry * 100.0 : (statEntry - statSL) / statEntry * 100.0
        float weightedPnL = pnlPct * statRemainingPos / totalRatio
        float currentPnL = statPnLPctArr.get(statActiveIdx)
        float totalPnL = na(currentPnL) ? weightedPnL : currentPnL + weightedPnL
        statPnLPctArr.set(statActiveIdx, totalPnL)
        statStatusArr.set(statActiveIdx, -1)
        statActive := false
        statActiveIdx := na
        statIsLong := false
        statEntry := na
        statSL := na
        statTP1 := na
        statTP2 := na
        statTP3 := na
    
    if statRemainingPos <= 0
        statStatusArr.set(statActiveIdx, 1)
        float tp1PnL = statTP1PnLArr.get(statActiveIdx)
        float tp2PnL = statTP2PnLArr.get(statActiveIdx)
        float tp3PnL = statTP3PnLArr.get(statActiveIdx)
        float totalPnL = (na(tp1PnL) ? 0.0 : tp1PnL) + (na(tp2PnL) ? 0.0 : tp2PnL) + (na(tp3PnL) ? 0.0 : tp3PnL)
        statPnLPctArr.set(statActiveIdx, totalPnL)
        statActive := false
        statActiveIdx := na
        statIsLong := false
        statEntry := na
        statSL := na
        statTP1 := na
        statTP2 := na
        statTP3 := na

if newZoneFormed
    MarketStructureZone newZone = MarketStructureZone.new()
    newZone.startIdx := rangeStartBar
    newZone.endIdx := bar_index
    newZone.upperLevel := rangeHigh
    newZone.lowerLevel := rangeLow
    newZone.isLive := true
    newZone.isBreached := false
    newZone.breakSide := ""
    newZone.topRejections := 0
    newZone.btmRejections := 0
    newZone.entryPx := na
    newZone.stopPx := na
    newZone.takeProfit1 := na
    newZone.takeProfit2 := na
    newZone.takeProfit3 := na
    newZone.rrr := 0
    newZone.labelY := na

    if not na(currentZone) and currentZone.isLive
        currentZone.isLive := false

    currentZone := newZone
    zoneHistory.push(newZone)

    while zoneHistory.size() > maxZonesToKeep
        zoneHistory.shift()

if onClose and not na(currentZone) and currentZone.isLive and not isBreakout
    int duration = bar_index - currentZone.startIdx
    float rangeHeight = currentZone.upperLevel - currentZone.lowerLevel
    float tolerance = rangeHeight * 0.1

    if high <= currentZone.upperLevel + tolerance and low >= currentZone.lowerLevel - tolerance
        currentZone.endIdx := bar_index

        currentZone.powerScore := computeCompressionScore(duration, rangeHeight, atrVal)
        currentZone.vwapLevel := getVolumeWeightedMean(currentZone.upperLevel, currentZone.lowerLevel, currentZone.startIdx, bar_index)
        currentZone.topRejections := getRejectionCount(currentZone.upperLevel, tolerance, currentZone.startIdx, bar_index, true)
        currentZone.btmRejections := getRejectionCount(currentZone.lowerLevel, tolerance, currentZone.startIdx, bar_index, false)
        currentZone.whaleActivity := scanWhaleActivity(currentZone.startIdx, bar_index, currentZone.upperLevel, currentZone.lowerLevel)
        currentZone.lifeCycle := determineLifecycle(duration)

        [dir, conf] = analyzeBreakoutBias(currentZone.vwapLevel, currentZone.upperLevel, currentZone.lowerLevel, currentZone.topRejections, currentZone.btmRejections)
        currentZone.biasDir := dir
        currentZone.biasStrength := conf
        currentZone.qualityScore := evaluateZoneQuality(currentZone.powerScore, currentZone.whaleActivity, currentZone.lifeCycle, currentZone.biasStrength)

bool imminentBreakout = onClose and not na(currentZone) and currentZone.isLive and currentZone.powerScore >= energyCriticalThresh and currentZone.qualityScore >= 70

var int lastRenderBar = na
bool renderNow = barstate.islast and (onClose or na(lastRenderBar) or lastRenderBar != bar_index)

if renderNow
    lastRenderBar := bar_index
    clearAllDrawings()

    int drawn = 0
    bool sltpDrawn = false

    if zoneHistory.size() > 0
        for idx = 0 to zoneHistory.size() - 1
            if drawn >= maxZonesToDraw
                break
            int i = zoneHistory.size() - 1 - idx

            MarketStructureZone z = zoneHistory.get(i)
            if na(z)
                continue

            if not isInDisplayRange(z.startIdx)
                continue

            int rightBar = z.isLive ? (bar_index + activeExtendBars) : z.endIdx

            // 统一使用科技感3D框
            drawStereoBox(z.startIdx, rightBar, z.upperLevel, z.lowerLevel, z.isLive, z.isBreached, z.breakSide, z.biasDir, z.biasStrength, dirConfidenceMin)

            bool isLastTradeZone = not na(lastTradeZoneStart) and z.startIdx == lastTradeZoneStart and z.endIdx == lastTradeBreakBar
            // 限制：只有最后一个交易区域（也就是最新产生的）才显示 SL/TP 线和标签
            // 之前的逻辑是 isLastTradeZone，这实际上已经是"最新的一笔交易"了
            // 但如果用户想要的是"全图只显示最后一笔"，那么我们需要确保只绘制一次
            // 由于 loop 是倒序的 (从 zones.size()-1 开始)，我们可以加个标志位
            
            if showSLTP and z.isBreached and isLastTradeZone and not sltpDrawn and not na(z.stopPx) and not na(z.entryPx)
                int sltpRight = tradeActive ? bar_index : (not na(tradeExitBar) ? tradeExitBar : bar_index)
                
                // 判断是否获胜：检查是否有对应的 stats 记录
                bool isWin = false
                if statStatusArr.size() > 0
                    int lastIdx = statStatusArr.size() - 1
                    float lastEntry = statEntryPriceArr.get(lastIdx)
                    int lastStatus = statStatusArr.get(lastIdx)
                    
                    // 检查最后一条统计记录是否属于当前 Zone (通过入场价匹配) 且是否获利
                    if math.abs(lastEntry - z.entryPx) < syminfo.mintick * 10 and lastStatus == 1
                        isWin := true
                
                drawSLTPLines(z.startIdx, sltpRight, z.stopPx, z.takeProfit1, z.takeProfit2, z.takeProfit3, z.entryPx, z.breakSide, isWin)
                sltpDrawn := true

            if showEnergyBar
                float rangeH = z.upperLevel - z.lowerLevel
                drawEnergyBar(z.startIdx, rightBar, z.lowerLevel, z.powerScore, rangeH, showEnergyPercent)

            if not na(z.labelY)
                int midBar = math.round((z.startIdx + z.endIdx) / 2)
                string txt = z.breakSide == DIR_BULLISH ? "B" : "S"
                color txtColor = z.breakSide == DIR_BULLISH ? bullColor : bearColor
                // 使用带背景的样式以提高可见度
                string style = z.breakSide == DIR_BULLISH ? label.style_label_up : label.style_label_down
                color bgColor = color.new(txtColor, 80)
                drawnLabels.push(label.new(midBar, z.labelY, txt, color=bgColor, style=style, textcolor=txtColor, size=size.small, textalign=text.align_center))

            drawn += 1

plot(showSLTP ? entryPlot : na, "Entry (History)", color = color.new(color.white, 50), linewidth = 1, style = plot.style_steplinebr, offset = 1)
plot(showSLTP ? slPlot : na, "SL (History)", color = slColor, linewidth = 2, style = plot.style_steplinebr, offset = 1)
plot(showSLTP ? tp1Plot : na, "TP1 (History)", color = color.new(tpColor, 30), linewidth = 1, style = plot.style_steplinebr, offset = 1)
plot(showSLTP and showTP2 ? tp2Plot : na, "TP2 (History)", color = color.new(tpColor, 20), linewidth = 1, style = plot.style_steplinebr, offset = 1)
plot(showSLTP and showTP3 ? tp3Plot : na, "TP3 (History)", color = color.new(tpColor, 10), linewidth = 2, style = plot.style_steplinebr, offset = 1)

// 计算绝对位置
float longArrowY = na
float shortArrowY = na
if longArrow and not na(currentZone)
    float h = currentZone.upperLevel - currentZone.lowerLevel
    // Energy Bar 高度为 0.25 * rangeHeight
    // Energy Bar 底部位置为 activeZone.bottom - 2 * barHeight = activeZone.bottom - 0.5 * rangeHeight
    // 所以我们需要绘制在 activeZone.bottom - 0.5 * h 下方
    // 我们多给一点余量，放在 bottom - 0.6 * h
    float barTotalHeight = h * 0.25
    float barBottomY = currentZone.lowerLevel - barTotalHeight * 2
    longArrowY := barBottomY - (h * 0.1) // 在能量条底部再往下 10% 箱体高度的位置

if shortArrow and not na(currentZone)
    float atrBuf = atrVal * slAtrMult
    // 空单止损在上方，我们希望箭头在止损线更上方
    // activeZone.slPrice 大概是 top + atrBuf
    // 我们放在 slPrice + 一点点
    shortArrowY := currentZone.stopPx + (atrVal * 0.2)

plotchar(longArrow ? longArrowY : na, title = "Breakout Long Arrow", char = "▲", location = location.absolute, color = bullColor, size = size.tiny, textcolor = bullColor)
plotchar(shortArrow ? shortArrowY : na, title = "Breakout Short Arrow", char = "▼", location = location.absolute, color = bearColor, size = size.tiny, textcolor = bearColor)

getStatsRange() =>
    int endT = time
    int startT = statsStartTime
    int endT2 = statsEndTime
    if statsRangePreset == "Last 30 Days"
        startT := endT - 30 * 86400000
        endT2 := endT
    else if statsRangePreset == "Last 90 Days"
        startT := endT - 90 * 86400000
        endT2 := endT
    else if statsRangePreset == "Last 180 Days"
        startT := endT - 180 * 86400000
        endT2 := endT
    else if statsRangePreset == "Year 2025"
        startT := timestamp("GMT+0", 2025, 01, 01, 00, 00)
        endT2 := timestamp("GMT+0", 2025, 12, 31, 23, 59)
    else if statsRangePreset == "All"
        startT := 0
        endT2 := 4102358400000 // 2099-12-31

    int minT = math.min(startT, endT2)
    int maxT = math.max(startT, endT2)
    [minT, maxT]

inStatRange(int t) =>
    [st, en] = getStatsRange()
    t >= st and t <= en

if barstate.islast and showStatsTable
    var table statsTbl = table.new(position.top_right, 2, 8, bgcolor = color.new(#0B1020, 10), frame_color = color.new(#00E5FF, 0), frame_width = 2, border_width = 1, border_color = color.new(#00E5FF, 70))

    int totalOrders = 0
    int longOrders = 0
    int shortOrders = 0
    int winOrders = 0
    int stopOrders = 0
    int closedOrders = 0
    float totalEquity = 1.0

    bool canLoop = statEntryTimes.size() > 0 and statEntryTimes.size() == statStatusArr.size() and statEntryTimes.size() == statIsLongArr.size() and statEntryTimes.size() == statEntryPriceArr.size() and statEntryTimes.size() == statPnLPctArr.size() and statEntryTimes.size() == statTP1PnLArr.size() and statEntryTimes.size() == statTP2PnLArr.size() and statEntryTimes.size() == statTP3PnLArr.size()
    [stT, enT] = getStatsRange()

    if canLoop
        for i = 0 to statEntryTimes.size() - 1
            int et = statEntryTimes.get(i)
            if et >= stT and et <= enT
                totalOrders += 1
                bool isL = statIsLongArr.get(i)
                if isL
                    longOrders += 1
                else
                    shortOrders += 1
                int st = statStatusArr.get(i)
                if st == 1
                    winOrders += 1
                    closedOrders += 1
                else if st == -1
                    stopOrders += 1
                    closedOrders += 1
                float p = statPnLPctArr.get(i)
                if st == 1 or st == -1
                    if not na(p)
                        totalEquity := totalEquity * (1.0 + p / 100.0)

    float totalReturnPct = closedOrders > 0 ? (totalEquity - 1.0) * 100.0 : na

    color titleBg = color.new(#131A2A, 0)
    color keyColor = color.new(color.white, 0)
    color valColor = color.new(#00E5FF, 0)
    color rowBgA = color.new(#0B1020, 0)
    color rowBgB = color.new(#0E1630, 0)

    table.cell(statsTbl, 0, 0, "ankealgo®", text_color = color.white, text_size = size.normal, bgcolor = titleBg)
    table.merge_cells(statsTbl, 0, 0, 1, 0)

    table.cell(statsTbl, 0, 1, "Total Orders", text_color = keyColor, bgcolor = rowBgA)
    table.cell(statsTbl, 1, 1, str.tostring(totalOrders), text_color = valColor, bgcolor = rowBgA)

    table.cell(statsTbl, 0, 2, "Long Orders", text_color = keyColor, bgcolor = rowBgB)
    table.cell(statsTbl, 1, 2, str.tostring(longOrders), text_color = color.new(bullColor, 0), bgcolor = rowBgB)

    table.cell(statsTbl, 0, 3, "Short Orders", text_color = keyColor, bgcolor = rowBgA)
    table.cell(statsTbl, 1, 3, str.tostring(shortOrders), text_color = color.new(bearColor, 0), bgcolor = rowBgA)

    table.cell(statsTbl, 0, 4, "TP Wins", text_color = keyColor, bgcolor = rowBgB)
    table.cell(statsTbl, 1, 4, str.tostring(winOrders), text_color = color.new(#00E676, 0), bgcolor = rowBgB)

    table.cell(statsTbl, 0, 5, "Stop Losses", text_color = keyColor, bgcolor = rowBgA)
    table.cell(statsTbl, 1, 5, str.tostring(stopOrders), text_color = color.new(#FF5252, 0), bgcolor = rowBgA)

    table.cell(statsTbl, 0, 6, "Total Return %", text_color = keyColor, bgcolor = rowBgB)
    color pnlColor = na(totalReturnPct) ? valColor : totalReturnPct >= 0 ? color.new(#00E676, 0) : color.new(#FF5252, 0)
    table.cell(statsTbl, 1, 6, na(totalReturnPct) ? "n/a" : str.tostring(totalReturnPct, "#.##") + "%", text_color = pnlColor, bgcolor = rowBgB)

    float profitRatioPct = closedOrders > 0 ? (winOrders * 100.0 / closedOrders) : na
    table.cell(statsTbl, 0, 7, "Win Rate", text_color = keyColor, bgcolor = rowBgA)
    table.cell(statsTbl, 1, 7, na(profitRatioPct) ? "n/a" : str.tostring(profitRatioPct, "#.00") + "%", text_color = color.new(#00E676, 0), bgcolor = rowBgA)

alertcondition(newZoneFormed and alertNewZone, "New Zone", "🔔 New consolidation zone - Energy accumulating")
alertcondition(imminentBreakout and alertImminent, "Imminent Breakout", "⚠️ CRITICAL: Breakout imminent!")
alertcondition(breakoutUp and alertBreakout, "Bullish Breakout", "🚀 Bullish breakout confirmed!")
alertcondition(breakoutDn and alertBreakout, "Bearish Breakout", "🔻 Bearish breakout confirmed!")


plot(close)
plot(close)
````
