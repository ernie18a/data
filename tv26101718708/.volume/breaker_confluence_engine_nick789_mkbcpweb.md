# Breaker Confluence Engine [Nick789]

- url: https://www.tradingview.com/script/MkbcPweb-Breaker-Confluence-Engine-Nick789/
- type: indicator
- pine_id: PUB;244df9fd08df4aa587c929f5564d0904
- version: 12.0

## Description

Breaker Confluence Engine [Nick789]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Breaker Confluence Engine is built to map out breaker-style zones, Fair Value Gaps, and key confluence areas without making the chart look like a Christmas tree.

The idea is simple:

Use a higher source timeframe to find the important breaker and FVG structure, then project those zones onto the chart you are actually trading from.

So instead of constantly switching timeframes, you can sit on your lower timeframe and still see where the bigger structure is sitting.

This tool is not about throwing random buy and sell labels everywhere. It is designed to help you see where price has shifted, where imbalance is sitting, and where price may react if it comes back for a retest.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Breaker Zone Detection

The script detects bullish and bearish breaker-style zones using pivot-based swing structure.

These zones help show areas where price has broken through previous structure and may later come back to test that area.

- Bullish breaker zones can act as support
- Bearish breaker zones can act as resistance
- Zones extend forward until tested, filled, or invalidated
- Overlap prevention helps avoid stacking too many similar zones
- Zone limits help keep the chart clean

2. Fair Value Gap Mapping

The script can detect 3-candle Fair Value Gaps from the selected source timeframe and project them onto the current chart.

There is also an optional current-timeframe FVG layer for traders who want more lower-timeframe detail.

Use the source FVGs for the cleaner main view.  
Turn on current-timeframe FVGs when you want to dig deeper or review price action.

3. Breaker + FVG Confluence

This is where the tool starts to get interesting.

When a breaker zone lines up with a source-timeframe FVG, the zone is highlighted as a stronger confluence area.

Not every breaker matters.  
Not every FVG matters.  
But when structure shift and imbalance show up together, that area is worth paying attention to.

4. Zone Rating System

Each zone can be rated using a mix of confluence factors:

- Displacement
- Relative volume
- Directional delta proxy
- Sweep context
- FVG alignment

The rating scale is:

Weak → Interest → Momentum → Absorption → Institutional

This gives you a quick way to separate basic zones from the ones that actually have a bit more story behind them.

Weak zones can stay simple by default, or you can turn on full weak rating details if you want to study everything.

5. Tested and Mitigated Tracking

The script tracks whether a zone is fresh, tested, or already used up.

- Fresh zones show areas price has not returned to yet
- Tested zones show areas price has touched
- Filled or invalidated zones can be hidden automatically
- Or you can fade them for review and back testing

This helps you avoid treating an old used-up zone like it is still fresh.

6. Potential Breaker Zones

The optional Potential Breaker layer gives an early heads-up when price is approaching a prior swing level before a confirmed breaker forms.

It uses an ATR-based proximity threshold.

Think of it as:

“Price is getting close. Something may be building here.”

Potential zones are removed once the breaker confirms or the level gets invalidated.

7. Source Timeframe & Session Control

Choose the source timeframe you want the main logic to come from.

Examples:
- 5m / 15m / 30m for scalping
- 1H / 4H for intraday structure
- 4H / Daily for bigger context

There is also an optional New York session filter for traders who want to focus only on a specific liquidity window.

8. Alerts

The script includes alerts for:

- Bullish breaker events
- Bearish breaker events
- Source-timeframe FVGs
- Current-timeframe FVGs
- Potential breaker events
- Mitigation and fill events
- Master alert for combining events into one cleaner message

The master alert is useful if you do not want a massive alert list or you are setting up webhook-style workflows.

9. Status Table

A small table on the chart shows the main tool status at a glance:

- Source timeframe
- Current chart timeframe
- Session filter
- Source FVG status
- Current-timeframe FVG status
- Potential Breaker status
- Rating status

Simple, clean, and easy to check.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Pick Your Source Timeframe

Choose the timeframe you want the important structure to come from.

For example, you might trade on the 1m or 5m chart, but use 15m or 1H as the source timeframe.

That lets you trade lower-timeframe entries while still respecting the bigger zones.

2. Watch the Breaker Zones

Breaker zones show where price has shifted through prior structure.

If price comes back to that area, it may react, reject, continue, or fail. The zone gives you a place to focus, not a guaranteed trade.

3. Look for Confluence

The best zones usually have more than one thing going for them.

A breaker by itself is okay.  
A breaker with FVG alignment, displacement, sweep context, volume, and delta support is much more interesting.

That is the whole point of the tool.

4. Pay Attention to Tested Status

Fresh zones are usually cleaner.

Once price has already tapped, filled, or invalidated a zone, it may not carry the same weight anymore.

The tested and mitigated tracking helps keep that clear.

5. Keep the Chart Clean

For live trading, less is usually better.

A clean setup could be:

- Source FVGs: On
- Current-timeframe FVGs: Optional
- Hide Mitigated: On
- Prevent Overlap: On
- Potential Breakers: Off
- Weak Ratings: Off

For review and back testing, turn more layers on and study how price reacts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BEST USE CASE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This tool is best used as a structure and confluence map.

It helps answer questions like:

- Where is the higher-timeframe breaker?
- Is there an FVG sitting with it?
- Has the zone already been tested?
- Did price sweep before forming the zone?
- Is the move away strong or weak?
- Is this area actually worth watching?

It is not meant to replace your own trading plan.  
It is meant to make the important areas easier to see.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- Source-timeframe logic confirms after the source candle closes
- The tool uses lookahead-off source timeframe logic
- Current-timeframe FVGs are optional and can add more visual load
- Zone ratings are guides, not guarantees
- Best used on liquid markets with clean price action
- Keep your chart clean if you are using it live

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is for educational and informational use only.

It does not provide financial advice, guaranteed signals, or automatic trade decisions.

Trading involves risk. Always use your own analysis, confirmation, risk management, and testing before making any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator("Breaker Confluence Engine [NICK789]", shorttitle="BCE [NICK789]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=1000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GROUP DEFINITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string G1 = "Breaker Structure"
string G2 = "Source Timeframe & Session"
string G3 = "Visual Display"
string G4 = "Alert System"
string G5 = "Fair Value Gaps"
string G6 = "Potential Breakers"
string G7 = "Projection Tool"
string G8 = "Zone Rating"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string tfInput            = input.timeframe("15", "Source Timeframe", group=G2, tooltip="Breaker and source FVG logic are calculated on this timeframe, then projected onto any chart timeframe.")
int    pivotLen           = input.int(3, "Pivot Length", minval=1, group=G1, tooltip="Sensitivity for detecting pivots.")
int    ictMssLen          = input.int(5, "ICT/MSS Length", minval=1, maxval=10, group=G1, tooltip="Only applies to ICT Candle Run mode. Controls the MSS swing sensitivity used before scanning the candle run.")
string breakerDrawMode    = input.string("Pivot Candle", "Breaker Draw Mode", options=["Pivot Candle", "ICT Candle Run"], group=G1, tooltip="Pivot Candle = pivot-based breaker drawing. ICT Candle Run = MSS swing-break logic that scans the D-to-C swing leg for the consecutive same-colour candle run.")
bool   breakerUseBody     = input.bool(false, "Use Breaker Candle Body", group=G1, tooltip="Only applies to ICT Candle Run mode. When enabled, breaker zones are drawn from candle bodies instead of full wick range.")
int    breakerSearchBars  = input.int(80, "Breaker Candle Search Depth", minval=10, maxval=500, group=G1, tooltip="Only applies to ICT Candle Run mode. Maximum source-timeframe candles to scan between the swing origin and the structure break.")
bool   useSession         = input.bool(false, "Filter by New York Session", group=G2)
string sessionTime        = input.session("0800-1300", "NY Session Time", group=G2, tooltip="Session interpreted in America/New_York.")

// Main display preset
string displayMode       = input.string("Desktop", "Display Mode", options=["Desktop", "Mobile", "Clean"], group=G3, tooltip="Desktop = full zone text. Mobile = compact zone text. Clean = watermark-style zone text.")
string zoneLabelPosition = input.string("Right", "Zone Label Position", options=["Left", "Middle", "Right"], group=G3, tooltip="Controls the horizontal position of text inside zone boxes.")

bool   showFvgAlign       = input.bool(true, "Highlight Breaker + Source FVG Alignment", group=G3)
bool   hideMitigated      = input.bool(true, "Hide Mitigated Blocks & FVGs", group=G3, tooltip="Remove mitigated zone drawings from the chart. Breaker confirmation triangles can be preserved separately below.")
bool   keepHistoricalBreakerSignals = input.bool(true, "Keep Historical Breaker Signal Triangles", group=G3, tooltip="Keeps the +BB / +BB+FVG confirmation triangle after its breaker is mitigated, even when the breaker box is hidden. Historical triangles are visual only and are removed from live calculations.")
int    maxHistoricalBreakerSignals  = input.int(150, "Max Historical Breaker Triangles", minval=10, maxval=400, group=G3, tooltip="Maximum number of completed breaker confirmation triangles to keep on chart. Oldest triangles are deleted first to stay within TradingView label limits.")
bool   hideOverlap        = input.bool(true, "Prevent Overlapping Breakers", group=G3, tooltip="Do not create a new breaker if it overlaps an existing active breaker of the same direction.")
bool   showLabels         = input.bool(true, "Show Confirmation Labels", group=G3)
bool   showBreakerMidline   = input.bool(false, "Show Breaker Midline", group=G3, tooltip="Optional breaker midpoint guide. Disabled by default for a cleaner chart.")
bool   showBreakerRetestSignals = input.bool(false, "Show Breaker Retest Signals", group=G3, tooltip="Optional UP/DN reaction signals after price retests a breaker. Disabled by default for a cleaner chart.")
string breakerRetestLabelMode = input.string("Latest Only", "Retest Signal Label History", options=["Latest Only", "All Historical"], group=G3, tooltip="Latest Only keeps only the newest UP/DN/Cancel retest label on chart. All Historical keeps every retest signal label.")
int    extendBars         = input.int(5, "Initial Zone Extension", minval=1, maxval=100, group=G3)
int    liveExtendBars     = input.int(25, "Live Zone Extension", minval=1, maxval=200, group=G3, tooltip="Keeps active breaker and FVG zones extended to the right.")
int    maxBreakersPerSide = input.int(5, "Max Breaker Zones Per Side", minval=1, maxval=20, group=G3)
string tableSizeInput     = input.string("small", "UI Table Text Size", options=["tiny", "small", "normal", "large", "huge"], group=G3)

color  bullColor          = input.color(color.new(#089981, 85), "Bullish Breaker Color", group=G3)
color  bearColor          = input.color(color.new(#f23645, 85), "Bearish Breaker Color", group=G3)
color  fvgAlignColor      = input.color(color.new(#5b9cf6, 60), "Confluence Border Color", group=G3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FAIR VALUE GAP INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool   showFvgZones       = input.bool(true, "Show Source Timeframe FVGs", group=G5)
bool   showChartFvgZones  = input.bool(true, "Show Current Timeframe FVGs", group=G5, tooltip="Optional current-chart FVG layer. Keep off for heavier Replay testing.")
bool   mergeOverlapFvgLabels = input.bool(true, "Merge Overlapping FVG Labels", group=G5, tooltip="When current TF and source TF FVGs overlap in the same direction, merge the label into the source FVG.")
bool   hideMergedChildText   = input.bool(true, "Hide Merged Child FVG Text", group=G5, tooltip="Keeps overlapping current TF boxes visible but hides their text.")
int    maxFvgsPerSide     = input.int(5, "Max Source FVGs Per Side", minval=1, maxval=20, group=G5)
int    maxChartFvgsPerSide = input.int(3, "Max Current FVGs Per Side", minval=1, maxval=10, group=G5)

// Ranked chart-timeframe FVG filter.
// When the Source Timeframe matches the chart, the source FVG layer is the chart-TF layer,
// so this same ranking filter is applied there instead of double-printing a second local layer.
bool   rankChartTfFvgs       = input.bool(true, "Rank Current / Chart TF FVGs", group=G5, tooltip="Filters chart-timeframe FVGs by relative gap size and displacement volume before they are displayed. Source FVGs on a different timeframe remain unchanged.")
string rankGapStrictness     = input.string("Low", "Chart FVG Gap Strictness", options=["None", "Low", "Medium", "High", "Extreme"], group=G5, tooltip="Ranks gap size against FVGs formed around the same time of day. Low = Z ≥ 0, Medium = 0.5, High = 1.0, Extreme = 2.0.")
string rankVolumeStrictness  = input.string("Low", "Chart FVG Volume Strictness", options=["None", "Low", "Medium", "High", "Extreme"], group=G5, tooltip="Ranks the displacement-candle volume against volume around the same time of day.")
int    rankTodLength         = input.int(5, "Chart FVG Time-of-Day Memory", minval=1, group=G5, tooltip="Number of prior observations stored for each time-of-day bucket.")

color  bullFvgColor       = input.color(color.new(#089981, 88), "Source Bullish FVG Color", group=G5)
color  bearFvgColor       = input.color(color.new(#f23645, 88), "Source Bearish FVG Color", group=G5)

color  chartBullFvgColor  = input.color(color.new(#22c55e, 90), "Current TF Bull FVG Color", group=G5)
color  chartBearFvgColor  = input.color(color.new(#ef4444, 90), "Current TF Bear FVG Color", group=G5)
bool   hideLocalFvgText   = input.bool(true, "Hide Current TF FVG Labels", group=G5, tooltip="Current timeframe FVGs become a silent precision layer. Source timeframe FVGs keep the main label.")
bool   showLocalFvgMidline = input.bool(true, "Show Current TF FVG Midline", group=G5, tooltip="Draws a middle line through current timeframe FVGs for cleaner visual guidance.")
int    localWeakTransp    = input.int(92, "Current TF Weak Transparency", minval=70, maxval=100, group=G5)
int    localStrongTransp  = input.int(82, "Current TF Strong Transparency", minval=50, maxval=100, group=G5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POTENTIAL BREAKER INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool   showPotentialBreakers = input.bool(false, "Show Potential Breakers", group=G6)
int    potentialATRLen       = input.int(14, "Potential ATR Length", minval=1, group=G6)
float  potentialATRMult      = input.float(0.15, "Potential Breaker ATR Threshold", minval=0.01, step=0.01, group=G6)
int    maxPotentialsPerSide  = input.int(3, "Max Potentials Per Side", minval=1, maxval=20, group=G6)
color  potentialBullColor    = input.color(color.new(#089981, 92), "Potential Bull Color", group=G6)
color  potentialBearColor    = input.color(color.new(#f23645, 92), "Potential Bear Color", group=G6)
bool   enablePotentialAlerts = input.bool(true, "Enable Potential Breaker Alerts", group=G6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROJECTION TOOL INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool   showTradePlan         = input.bool(false, "Show Projection Tool", group=G7, tooltip="Displays a visual risk/reward projection from the confirmation close. This is a visual planning aid only.")
int    tradePlanExtendBars   = input.int(20, "Projection Extension Bars", minval=1, maxval=500, group=G7)
float  rr1                   = input.float(1.0, "R1 Multiple", minval=0.1, step=0.1, group=G7, tooltip="Example: 1.0 = 1:1, 2.0 = 1:2, 3.0 = 1:3")
float  rr2                   = input.float(2.0, "R2 Multiple", minval=0.1, step=0.1, group=G7, tooltip="Example: 1.0 = 1:1, 2.0 = 1:2, 3.0 = 1:3")
float  rr3                   = input.float(3.0, "R3 Multiple", minval=0.1, step=0.1, group=G7, tooltip="Example: 1.0 = 1:1, 2.0 = 1:2, 3.0 = 1:3")
color  tradeEntryBullColor   = input.color(color.new(#089981, 88), "Bull Projection Box", group=G7)
color  tradeEntryBearColor   = input.color(color.new(#f23645, 88), "Bear Projection Box", group=G7)
color  tradeEntryLineColor   = input.color(color.new(color.white, 0), "Confirmation Line Color", group=G7)
color  tradeSLColor          = input.color(color.new(color.red, 0), "Invalidation Line Color", group=G7)
color  tradeTP1Color         = input.color(color.new(color.lime, 0), "R1 Line Color", group=G7)
color  tradeTP2Color         = input.color(color.new(color.lime, 0), "R2 Line Color", group=G7)
color  tradeTP3Color         = input.color(color.new(color.lime, 0), "R3 Line Color", group=G7)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE RATING INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool  showZoneRating     = input.bool(true, "Show Zone Rating", group=G8)
bool  showDeltaOnZone    = input.bool(true, "Show Delta Tag", group=G8)
bool  showTestStatus     = input.bool(true, "Show Tested Status", group=G8)
bool  showWeakRatings    = input.bool(false, "Show Weak Ratings", group=G8, tooltip="When enabled, even Weak FVGs and Breakers show rating, delta, and tested status.")

float ratingDispThresh = input.float(1.25, "Displacement Threshold", minval=0.1, step=0.05, group=G8)
float ratingVolThresh  = input.float(1.20, "Relative Volume Threshold", minval=0.1, step=0.05, group=G8)
int   ratingSweepLen   = input.int(10, "Sweep Lookback", minval=2, maxval=100, group=G8)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool   enableAlerts       = input.bool(false, "Enable Individual alert() Messages", group=G4)
bool   useMasterAlert     = input.bool(true, "Enable Master Combined alert()", group=G4, tooltip="Triggers a single alert message containing all detected events on the current bar.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CUSTOM DATA TYPES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Time-of-day statistics used for FVG quality filtering.
// Ranking data is kept separate from breaker and FVG zone objects.
type RankKey
    int minuteValue = minute
    int hourValue   = hour

type RankVec
    float[] values

type RankDataArray
    RankVec[] data
    bool[] valid

type Breaker
    float top
    float bottom
    bool  isBull
    bool  isFvgAlign
    box   boxId
    label labelId
    line  midLine
    color baseColor
    bool  mitigated
    bool  isTested
    bool  isBroken
    bool  hasRetestSignal
    string rating
    string context
    float birthDelta
    string baseText

type FvgZone
    float top
    float bottom
    bool  isBull
    box   boxId
    label labelId
    line  midLine
    color baseColor
    bool  mitigated
    bool  isTested
    string rating
    string context
    float birthDelta
    string baseText

type PotentialBreaker
    float top
    float bottom
    bool  isBull
    box   boxId
    label labelId
    color baseColor
    bool  invalidated

type EngineOut
    int   bullEventTime
    float bullTop
    float bullBottom
    int   bullOriginTime
    bool  bullFvgAlign
    float bullEntryPrice

    int   bearEventTime
    float bearTop
    float bearBottom
    int   bearOriginTime
    bool  bearFvgAlign
    float bearEntryPrice

    int   bullFvgEventTime
    float bullFvgTop
    float bullFvgBottom
    int   bullFvgOriginTime

    int   bearFvgEventTime
    float bearFvgTop
    float bearFvgBottom
    int   bearFvgOriginTime

    int   bullPotentialTime
    float bullPotentialTop
    float bullPotentialBottom

    int   bearPotentialTime
    float bearPotentialTop
    float bearPotentialBottom

    float tfAtr
    float tfVol
    float tfVolAvg
    float tfDelta
    bool  bullSweepContext
    bool  bearSweepContext
    float eventClose

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UTILITY FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Ranked FVG strictness thresholds:
// None = bypass, Low = Z >= 0, Medium = 0.5, High = 1.0, Extreme = 2.0.
f_rank_to_z(string strictness) =>
    switch strictness
        "Extreme" => 2.0
        "High"    => 1.0
        "Medium"  => 0.5
        "Low"     => 0.0
        => -99.0

method rankMaintain(float[] self, int length) =>
    if length > 0 and self.size() >= length
        self.pop()

method rankAddPop(float[] self, float value, int length) =>
    self.rankMaintain(length)
    self.unshift(value)

f_rank_init_data() =>
    int slots = math.max(1, int(1440 / math.max(1, timeframe.multiplier)))
    RankVec[] data = array.new<RankVec>(slots)
    bool[] valid = array.new<bool>(slots, false)
    RankDataArray.new(data, valid)

f_rank_key_to_hash(RankKey key, int size) =>
    int rawHash = int((key.hourValue * 60 + key.minuteValue) / math.max(1, timeframe.multiplier))
    math.max(0, math.min(size - 1, rawHash))

f_rank_hash_now(int size) =>
    f_rank_key_to_hash(RankKey.new(), size)

method rankAddElement(RankDataArray self, float source, int length) =>
    if not na(source)
        int index = f_rank_hash_now(self.valid.size())
        if self.valid.get(index)
            self.data.get(index).values.rankAddPop(source, length)
        else
            self.data.set(index, RankVec.new(array.from(source)))
            self.valid.set(index, true)

method rankGetAverage(RankDataArray self, RankKey key) =>
    float result = na
    int index = f_rank_key_to_hash(key, self.valid.size())
    if self.valid.get(index)
        result := self.data.get(index).values.avg()
    result

method rankGetStdev(RankDataArray self, RankKey key) =>
    float result = 0.0
    int index = f_rank_key_to_hash(key, self.valid.size())
    if self.valid.get(index)
        float[] values = self.data.get(index).values
        result := values.size() > 1 ? values.stdev() : 0.0
    result

f_update_rank_statistics(RankDataArray volumeData, RankDataArray gapData, int memoryLength) =>
    float gapHeight = low > high[2] ? low - high[2] : high < low[2] ? low[2] - high : 0.0
    volumeData.rankAddElement(volume, memoryLength)
    if barstate.isconfirmed and gapHeight > 0.0
        gapData.rankAddElement(gapHeight, memoryLength)

f_get_ranked_chart_fvg_pass(RankDataArray gapData, RankDataArray volumeData, string gapStrictness, string volumeStrictness) =>
    bool bullishFvg = low > high[2]
    bool bearishFvg = high < low[2]
    bool isGap = bullishFvg or bearishFvg

    float gapHeight = bullishFvg ? low - high[2] : bearishFvg ? low[2] - high : 0.0
    float fvgVolume = nz(volume[1], 0.0)
    int fvgTime = time[1]
    RankKey key = RankKey.new(minute(fvgTime), hour(fvgTime))

    float expectedVolume = nz(volumeData.rankGetAverage(key))
    float expectedGap = nz(gapData.rankGetAverage(key))
    float volumeStdev = volumeData.rankGetStdev(key)
    float gapStdev = gapData.rankGetStdev(key)

    float volumeZ = volumeStdev > 0.0 ? (fvgVolume - expectedVolume) / volumeStdev : 0.0
    float gapZ = gapStdev > 0.0 ? (gapHeight - expectedGap) / gapStdev : 0.0

    float volumeThreshold = f_rank_to_z(volumeStrictness)
    float gapThreshold = f_rank_to_z(gapStrictness)

    bool volumePass = volumeThreshold < -10.0 or (fvgVolume > 0.0 and volumeZ >= volumeThreshold)
    bool gapPass = gapThreshold < -10.0 or (gapHeight > 0.0 and gapZ >= gapThreshold)

    [isGap and volumePass and gapPass, gapZ, volumeZ]

f_getSize(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

sizeTable = f_getSize(tableSizeInput)

bool isMobileMode  = displayMode == "Mobile"
bool isCleanMode   = displayMode == "Clean"
bool useBoxText     = true
bool useMiniText    = isMobileMode
bool useEventLabels = showLabels and not isCleanMode
zoneTextSize        = isCleanMode ? size.normal : isMobileMode ? size.tiny : sizeTable
color zoneTextColor = color.new(chart.fg_color, isCleanMode ? 75 : 0)

zoneTextHalign = switch zoneLabelPosition
    "Left"   => text.align_left
    "Middle" => text.align_center
    => text.align_right

f_formatTf(string tf) =>
    string out = tf
    if tf == "1"
        out := "1m"
    else if tf == "3"
        out := "3m"
    else if tf == "5"
        out := "5m"
    else if tf == "10"
        out := "10m"
    else if tf == "15"
        out := "15m"
    else if tf == "30"
        out := "30m"
    else if tf == "45"
        out := "45m"
    else if tf == "60"
        out := "1H"
    else if tf == "120"
        out := "2H"
    else if tf == "180"
        out := "3H"
    else if tf == "240"
        out := "4H"
    else if tf == "360"
        out := "6H"
    else if tf == "480"
        out := "8H"
    else if tf == "720"
        out := "12H"
    else if tf == "D"
        out := "1D"
    else if tf == "W"
        out := "1W"
    else if tf == "M"
        out := "1M"
    else
        out := tf
    out

f_safe_div(float a, float b) =>
    float out = 0.0
    if b != 0.0
        out := a / b
    out

f_fmt_vol(float v) =>
    float absV = math.abs(v)
    string out = ""
    if absV >= 1000000
        out := str.tostring(v / 1000000.0, "#.##") + "M"
    else if absV >= 1000
        out := str.tostring(v / 1000.0, "#.##") + "K"
    else
        out := str.tostring(v, "#")
    out

f_get_zone_rating(bool isBull, float top, float bottom, float anchorClose, float atrVal, float volVal, float volAvg, float deltaVal, bool sweepContext, bool fvgAlign) =>
    float zTop = math.max(top, bottom)
    float zBot = math.min(top, bottom)

    float moveAway = isBull ? math.max(anchorClose - zTop, 0.0) : math.max(zBot - anchorClose, 0.0)
    float disp     = f_safe_div(moveAway, nz(atrVal, 1.0))
    float rVol     = f_safe_div(volVal, nz(volAvg, 1.0))

    bool dispOk  = disp > ratingDispThresh
    bool volOk   = rVol > ratingVolThresh
    bool deltaOk = isBull ? deltaVal > 0 : deltaVal < 0

    int score = 0
    score += dispOk ? 1 : 0
    score += volOk ? 1 : 0
    score += deltaOk ? 1 : 0
    score += sweepContext ? 1 : 0
    score += fvgAlign ? 1 : 0

    string rating = "Weak"
    string context = "[Low]"

    if score <= 1
        rating := "Weak"
        context := "[Low]"
    else if score == 2
        rating := "Interest"
        context := "[High Interest]"
    else if score == 3
        rating := "Momentum"
        context := "[Moderate]"
    else if score == 4
        rating := "Absorp."
        context := "[Strong]"
    else
        rating := "Inst."
        context := "[Ultra]"

    [rating, context]

f_simple_rating(string rating) =>
    switch rating
        "Interest" => "Watch"
        "Momentum" => "Active"
        "Absorp."  => "Strong"
        "Inst."    => "Elite"
        => ""

f_zone_text(string baseTxt, string rating, string context, float deltaVal, bool isTested) =>
    string out = ""

    if useBoxText and baseTxt != ""
        string srcTf   = f_formatTf(tfInput)
        string chartTf = f_formatTf(timeframe.period)

        string zoneType =
             str.contains(baseTxt, "BB + FVG")      ? "BB+FVG" :
             str.contains(baseTxt, "Breaker + FVG") ? "BB+FVG" :
             str.contains(baseTxt, "ICT BB")        ? "BB" :
             str.contains(baseTxt, "Breaker")       ? "BB" :
             str.contains(baseTxt, "FVG")           ? "FVG" :
             "Z"

        string zoneTf =
             str.contains(baseTxt, srcTf)   ? srcTf :
             str.contains(baseTxt, chartTf) ? chartTf :
             ""

        bool isChartTf = zoneTf == "" or zoneTf == chartTf
        string cleanType = isChartTf ? zoneType : zoneTf + " " + zoneType

        string simpleRating = f_simple_rating(rating)
        string deltaTag =
             deltaVal > 0 ? "Δ +" + f_fmt_vol(math.abs(deltaVal)) :
             deltaVal < 0 ? "Δ -" + f_fmt_vol(math.abs(deltaVal)) :
             "Δ 0"

        string testTag = isTested ? "Tested" : "Fresh"

        if isCleanMode
            out := cleanType
        else
            out := cleanType

            if simpleRating != ""
                out += " • " + simpleRating

            if showDeltaOnZone
                out += " • " + deltaTag

            if showTestStatus
                out += " • " + testTag

    out

f_overlap_zone(float topA, float botA, float topB, float botB) =>
    float aTop = math.max(topA, botA)
    float aBot = math.min(topA, botA)
    float bTop = math.max(topB, botB)
    float bBot = math.min(topB, botB)
    math.max(aBot, bBot) < math.min(aTop, bTop)

bool useBreakerCandleRun = breakerDrawMode == "ICT Candle Run"

// Breaker source detection:
// Pivot Candle mode uses the pivot-based zone source.
// ICT Candle Run mode scans the MSS leg and uses the full consecutive same-colour candle run.
f_breaker_candle_top(int idx) =>
    breakerUseBody ? math.max(open[idx], close[idx]) : high[idx]

f_breaker_candle_bottom(int idx) =>
    breakerUseBody ? math.min(open[idx], close[idx]) : low[idx]

f_find_breaker_run(bool isBull, int searchOffset) =>
    float runTop = na
    float runBottom = na
    int   runOriginTime = na
    bool  foundRun = false
    bool  inRun = false
    int   maxOffset = math.min(searchOffset, breakerSearchBars)

    // Scan from the swing origin toward the confirmation candle, excluding the confirmation candle itself.
    // Count forward and convert into a reverse offset.
    if maxOffset > 0
        for step = 0 to maxOffset - 1
            int i = maxOffset - step
            bool sameColour = isBull ? close[i] > open[i] : close[i] < open[i]
            if sameColour
                float cTop = f_breaker_candle_top(i)
                float cBot = f_breaker_candle_bottom(i)
                if not inRun
                    inRun := true
                    foundRun := true
                    runOriginTime := time[i]
                    runTop := cTop
                    runBottom := cBot
                else
                    runTop := math.max(runTop, cTop)
                    runBottom := math.min(runBottom, cBot)
            else if inRun
                break

    [runTop, runBottom, runOriginTime, foundRun]

f_find_breaker_run_latest(bool isBull, int nearOffset, int farOffset) =>
    float runTop = na
    float runBottom = na
    int   runOriginTime = na
    bool  foundRun = false

    if not na(nearOffset) and not na(farOffset)
        int startOffset = math.max(math.min(nearOffset, farOffset), 1)
        int endOffset   = math.min(math.max(nearOffset, farOffset), breakerSearchBars)

        if endOffset >= startOffset
            for i = startOffset to endOffset
                bool sameColour = isBull ? close[i] > open[i] : close[i] < open[i]
                if sameColour
                    foundRun := true
                    runTop := f_breaker_candle_top(i)
                    runBottom := f_breaker_candle_bottom(i)
                    runOriginTime := time[i]

                    if i < endOffset
                        for j = i + 1 to endOffset
                            bool sameNext = isBull ? close[j] > open[j] : close[j] < open[j]
                            if sameNext
                                float cTop = f_breaker_candle_top(j)
                                float cBot = f_breaker_candle_bottom(j)
                                runTop := math.max(runTop, cTop)
                                runBottom := math.min(runBottom, cBot)
                                runOriginTime := time[j]
                            else
                                break

                    break

    [runTop, runBottom, runOriginTime, foundRun]

f_offset_from_time(int targetTime) =>
    int out = na
    if not na(targetTime)
        for i = 1 to breakerSearchBars
            if time[i] == targetTime
                out := i
                break
    out

f_mss_push_swing(array<int> dirs, array<int> times, array<float> prices, int newDir, int newTime, float newPrice) =>
    int curDir = array.get(dirs, 0)
    float curPrice = array.get(prices, 0)
    bool replaceSame = curDir == newDir and (na(curPrice) or (newDir == 1 ? newPrice > curPrice : newPrice < curPrice))
    bool changed = false

    if curDir != newDir
        array.unshift(dirs, newDir)
        array.unshift(times, newTime)
        array.unshift(prices, newPrice)
        array.pop(dirs)
        array.pop(times)
        array.pop(prices)
        changed := true
    else if replaceSame
        array.set(dirs, 0, newDir)
        array.set(times, 0, newTime)
        array.set(prices, 0, newPrice)
        changed := true

    changed

f_merge_fvg_label(bool isBull, float top, float bottom, string addTf, array<FvgZone> arr) =>
    bool merged = false
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            FvgZone z = array.get(arr, i)
            if not z.mitigated and z.isBull == isBull and f_overlap_zone(top, bottom, z.top, z.bottom)
                string addTag = " + " + addTf
                string mergedBase = str.contains(z.baseText, addTag) ? z.baseText : z.baseText + addTag
                z.baseText := mergedBase
                z.boxId.set_text(f_zone_text(mergedBase, z.rating, z.context, z.birthDelta, z.isTested))
                array.set(arr, i, z)
                merged := true
                break
    merged

checkOverlap(float top, float bot, bool isBull, array<Breaker> arr) =>
    bool overlapFound = false
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Breaker br = array.get(arr, i)
            if not br.mitigated and br.isBull == isBull
                if top > br.bottom and bot < br.top
                    overlapFound := true
                    break
    overlapFound

countActiveBreakers(bool isBullSide, array<Breaker> arr) =>
    int count = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Breaker br = array.get(arr, i)
            if not br.mitigated and br.isBull == isBullSide
                count += 1
    count

trimOldestBreakers(bool isBullSide, int maxKeep, array<Breaker> arr) =>
    int activeCount = countActiveBreakers(isBullSide, arr)
    while activeCount > maxKeep
        int oldestIdx = na
        int oldestTime = na
        if array.size(arr) > 0
            for i = 0 to array.size(arr) - 1
                Breaker br = array.get(arr, i)
                if not br.mitigated and br.isBull == isBullSide
                    int thisTime = br.boxId.get_left()
                    if na(oldestTime) or thisTime < oldestTime
                        oldestTime := thisTime
                        oldestIdx := i
        if not na(oldestIdx)
            Breaker oldBr = array.get(arr, oldestIdx)
            if not na(oldBr.boxId)
                oldBr.boxId.delete()
            if not na(oldBr.labelId)
                oldBr.labelId.delete()
            if not na(oldBr.midLine)
                oldBr.midLine.delete()
            array.remove(arr, oldestIdx)
        else
            break
        activeCount := countActiveBreakers(isBullSide, arr)

countActiveFvgs(bool isBullSide, array<FvgZone> arr) =>
    int count = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            FvgZone z = array.get(arr, i)
            if not z.mitigated and z.isBull == isBullSide
                count += 1
    count

trimOldestFvgs(bool isBullSide, int maxKeep, array<FvgZone> arr) =>
    int activeCount = countActiveFvgs(isBullSide, arr)
    while activeCount > maxKeep
        int oldestIdx = na
        int oldestTime = na
        if array.size(arr) > 0
            for i = 0 to array.size(arr) - 1
                FvgZone z = array.get(arr, i)
                if not z.mitigated and z.isBull == isBullSide
                    int thisTime = z.boxId.get_left()
                    if na(oldestTime) or thisTime < oldestTime
                        oldestTime := thisTime
                        oldestIdx := i
        if not na(oldestIdx)
            FvgZone oldZ = array.get(arr, oldestIdx)
            if not na(oldZ.boxId)
                oldZ.boxId.delete()
            if not na(oldZ.labelId)
                oldZ.labelId.delete()
            if not na(oldZ.midLine)
                oldZ.midLine.delete()
            array.remove(arr, oldestIdx)
        else
            break
        activeCount := countActiveFvgs(isBullSide, arr)

countActivePotentials(bool isBullSide, array<PotentialBreaker> arr) =>
    int count = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            PotentialBreaker p = array.get(arr, i)
            if not p.invalidated and p.isBull == isBullSide
                count += 1
    count

trimOldestPotentials(bool isBullSide, int maxKeep, array<PotentialBreaker> arr) =>
    int activeCount = countActivePotentials(isBullSide, arr)
    while activeCount > maxKeep
        int oldestIdx = na
        int oldestTime = na
        if array.size(arr) > 0
            for i = 0 to array.size(arr) - 1
                PotentialBreaker p = array.get(arr, i)
                if not p.invalidated and p.isBull == isBullSide
                    int thisTime = p.boxId.get_left()
                    if na(oldestTime) or thisTime < oldestTime
                        oldestTime := thisTime
                        oldestIdx := i
        if not na(oldestIdx)
            PotentialBreaker oldP = array.get(arr, oldestIdx)
            if not na(oldP.boxId)
                oldP.boxId.delete()
            if not na(oldP.labelId)
                oldP.labelId.delete()
            array.remove(arr, oldestIdx)
        else
            break
        activeCount := countActivePotentials(isBullSide, arr)

removePotentialsByDirection(bool isBullSide, array<PotentialBreaker> arr) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            PotentialBreaker p = array.get(arr, i)
            if p.isBull == isBullSide
                if not na(p.boxId)
                    p.boxId.delete()
                if not na(p.labelId)
                    p.labelId.delete()
                array.remove(arr, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOURCE TIMEFRAME ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tfEngine() =>
    bool sessionOk = not useSession or not na(time(timeframe.period, sessionTime + ":1234567", "America/New_York"))

    float ph = ta.pivothigh(high, pivotLen, pivotLen)
    float pl = ta.pivotlow(low, pivotLen, pivotLen)

    float mssPh = ta.pivothigh(high, ictMssLen, 1)
    float mssPl = ta.pivotlow(low, ictMssLen, 1)

    bool fvgUp = low > high[2]
    bool fvgDn = high < low[2]

    float atrVal = ta.atr(potentialATRLen)
    float atrBuf = atrVal * potentialATRMult

    float tfVol    = volume
    float tfVolAvg = ta.sma(volume, 20)
    float tfDelta  = volume * (close > open ? 1 : close < open ? -1 : 0)

    bool bullSweepContext = low < ta.lowest(low[1], ratingSweepLen)
    bool bearSweepContext = high > ta.highest(high[1], ratingSweepLen)

    var float lastPhHigh  = na
    var float lastPhLow   = na
    var int   lastPhTime  = na
    var bool  lastPhFvgDn = false

    var float lastPlHigh  = na
    var float lastPlLow   = na
    var int   lastPlTime  = na
    var bool  lastPlFvgUp = false

    if not na(ph)
        lastPhHigh  := high[pivotLen]
        lastPhLow   := low[pivotLen]
        lastPhTime  := time[pivotLen]
        lastPhFvgDn := fvgDn

    if not na(pl)
        lastPlHigh  := high[pivotLen]
        lastPlLow   := low[pivotLen]
        lastPlTime  := time[pivotLen]
        lastPlFvgUp := fvgUp

    // Own MSS swing map for the optional candle-run mode.
    // Uses alternating pivots so the breaker location comes from the same kind of swing leg structure.
    var array<int>   mssSwingDir   = array.new_int(12, 0)
    var array<int>   mssSwingTime  = array.new_int(12, na)
    var array<float> mssSwingPrice = array.new_float(12, na)

    if not na(mssPh)
        f_mss_push_swing(mssSwingDir, mssSwingTime, mssSwingPrice, 1, time[1], high[1])

    if not na(mssPl)
        f_mss_push_swing(mssSwingDir, mssSwingTime, mssSwingPrice, -1, time[1], low[1])

    int iH = array.get(mssSwingDir, 2) == 1 ? 2 : 1
    int iL = array.get(mssSwingDir, 2) == -1 ? 2 : 1

    int   bullDTime = array.get(mssSwingTime, iH)
    float bullDPrice = array.get(mssSwingPrice, iH)
    int   bullCTime = array.get(mssSwingTime, iH + 1)
    float bullCPrice = array.get(mssSwingPrice, iH + 1)
    int   bullETime = array.get(mssSwingTime, iH - 1)
    float bullEPrice = array.get(mssSwingPrice, iH - 1)

    int   bearDTime = array.get(mssSwingTime, iL)
    float bearDPrice = array.get(mssSwingPrice, iL)
    int   bearCTime = array.get(mssSwingTime, iL + 1)
    float bearCPrice = array.get(mssSwingPrice, iL + 1)
    int   bearETime = array.get(mssSwingTime, iL - 1)
    float bearEPrice = array.get(mssSwingPrice, iL - 1)

    var int mssDir = 0

    // Pivot-based trigger.
    bool pivotBullSignalTf = sessionOk and not na(lastPlHigh) and ta.crossover(close, lastPlHigh)
    bool pivotBearSignalTf = sessionOk and not na(lastPhLow) and ta.crossunder(close, lastPhLow)

    // Optional MSS trigger: break of the selected swing,
    // then only accept the setup when the surrounding swing sequence is valid.
    bool mssBullBreakTf = sessionOk and array.get(mssSwingDir, iH) == 1 and not na(bullDPrice) and close > bullDPrice and mssDir < 1
    bool mssBearBreakTf = sessionOk and array.get(mssSwingDir, iL) == -1 and not na(bearDPrice) and close < bearDPrice and mssDir > -1

    bool mssBullPatternTf = mssBullBreakTf and not na(bullEPrice) and not na(bullCPrice) and bullEPrice < bullCPrice and bullCTime != bullDTime
    bool mssBearPatternTf = mssBearBreakTf and not na(bearEPrice) and not na(bearCPrice) and bearEPrice > bearCPrice and bearCTime != bearDTime

    bool bullRawSignalTf = useBreakerCandleRun ? mssBullPatternTf : pivotBullSignalTf
    bool bearRawSignalTf = useBreakerCandleRun ? mssBearPatternTf : pivotBearSignalTf

    bool bullPotentialCond = sessionOk and not na(lastPlHigh) and close < lastPlHigh and close >= (lastPlHigh - atrBuf)
    bool bearPotentialCond = sessionOk and not na(lastPhLow) and close > lastPhLow and close <= (lastPhLow + atrBuf)

    bool bullPotentialTf = bullPotentialCond and not bullPotentialCond[1]
    bool bearPotentialTf = bearPotentialCond and not bearPotentialCond[1]

    // Pivot mode scans from the selected pivot candle.
    int bullPivotOffset = nz(f_offset_from_time(lastPlTime), breakerSearchBars)
    int bearPivotOffset = nz(f_offset_from_time(lastPhTime), breakerSearchBars)

    [bullPivotRunTop, bullPivotRunBottom, bullPivotRunOriginTime, bullPivotRunFound] = f_find_breaker_run(true, bullPivotOffset)
    [bearPivotRunTop, bearPivotRunBottom, bearPivotRunOriginTime, bearPivotRunFound] = f_find_breaker_run(false, bearPivotOffset)

    // ICT Candle Run mode scans latest-to-older across the MSS D-to-C swing leg.
    int bullNearOffset = f_offset_from_time(bullDTime)
    int bullFarOffset  = f_offset_from_time(bullCTime)
    int bearNearOffset = f_offset_from_time(bearDTime)
    int bearFarOffset  = f_offset_from_time(bearCTime)

    [bullMssRunTop, bullMssRunBottom, bullMssRunOriginTime, bullMssRunFound] = f_find_breaker_run_latest(true, bullNearOffset, bullFarOffset)
    [bearMssRunTop, bearMssRunBottom, bearMssRunOriginTime, bearMssRunFound] = f_find_breaker_run_latest(false, bearNearOffset, bearFarOffset)

    bool bullSignalTf = bullRawSignalTf and (not useBreakerCandleRun or bullMssRunFound)
    bool bearSignalTf = bearRawSignalTf and (not useBreakerCandleRun or bearMssRunFound)

    float bullRunTop = useBreakerCandleRun ? bullMssRunTop : bullPivotRunTop
    float bullRunBottom = useBreakerCandleRun ? bullMssRunBottom : bullPivotRunBottom
    int   bullRunOriginTime = useBreakerCandleRun ? bullMssRunOriginTime : bullPivotRunOriginTime
    bool  bullRunFound = useBreakerCandleRun ? bullMssRunFound : bullPivotRunFound

    float bearRunTop = useBreakerCandleRun ? bearMssRunTop : bearPivotRunTop
    float bearRunBottom = useBreakerCandleRun ? bearMssRunBottom : bearPivotRunBottom
    int   bearRunOriginTime = useBreakerCandleRun ? bearMssRunOriginTime : bearPivotRunOriginTime
    bool  bearRunFound = useBreakerCandleRun ? bearMssRunFound : bearPivotRunFound

    bool bullUseRunZone = useBreakerCandleRun and bullRunFound
    bool bearUseRunZone = useBreakerCandleRun and bearRunFound

    int   bullEventTime  = bullSignalTf ? time : na
    float bullTop        = bullSignalTf ? (bullUseRunZone ? bullRunTop : lastPlHigh) : na
    float bullBottom     = bullSignalTf ? (bullUseRunZone ? bullRunBottom : lastPlLow) : na
    int   bullOriginTime = bullSignalTf ? (bullUseRunZone ? bullRunOriginTime : lastPlTime) : na
    bool  bullFvgAlign   = bullSignalTf ? (useBreakerCandleRun ? fvgUp : lastPlFvgUp) : false
    float bullEntryPrice = bullSignalTf ? close : na

    int   bearEventTime  = bearSignalTf ? time : na
    float bearTop        = bearSignalTf ? (bearUseRunZone ? bearRunTop : lastPhHigh) : na
    float bearBottom     = bearSignalTf ? (bearUseRunZone ? bearRunBottom : lastPhLow) : na
    int   bearOriginTime = bearSignalTf ? (bearUseRunZone ? bearRunOriginTime : lastPhTime) : na
    bool  bearFvgAlign   = bearSignalTf ? (useBreakerCandleRun ? fvgDn : lastPhFvgDn) : false
    float bearEntryPrice = bearSignalTf ? close : na

    int   bullFvgEventTime  = sessionOk and fvgUp ? time : na
    float bullFvgTop        = sessionOk and fvgUp ? low : na
    float bullFvgBottom     = sessionOk and fvgUp ? high[2] : na
    int   bullFvgOriginTime = sessionOk and fvgUp ? time[2] : na

    int   bearFvgEventTime  = sessionOk and fvgDn ? time : na
    float bearFvgTop        = sessionOk and fvgDn ? low[2] : na
    float bearFvgBottom     = sessionOk and fvgDn ? high : na
    int   bearFvgOriginTime = sessionOk and fvgDn ? time[2] : na

    int   bullPotentialTime   = bullPotentialTf ? time : na
    float bullPotentialTop    = bullPotentialTf ? lastPlHigh : na
    float bullPotentialBottom = bullPotentialTf ? lastPlLow : na

    int   bearPotentialTime   = bearPotentialTf ? time : na
    float bearPotentialTop    = bearPotentialTf ? lastPhHigh : na
    float bearPotentialBottom = bearPotentialTf ? lastPhLow : na

    if useBreakerCandleRun and mssBullBreakTf
        mssDir := 1

    if useBreakerCandleRun and mssBearBreakTf
        mssDir := -1

    // Potential BB remains tied to the pivot-based logic.
    // ICT Candle Run does not clear the stored BCE pivot source.
    if pivotBullSignalTf
        lastPlHigh  := na
        lastPlLow   := na
        lastPlTime  := na
        lastPlFvgUp := false

    if pivotBearSignalTf
        lastPhHigh  := na
        lastPhLow   := na
        lastPhTime  := na
        lastPhFvgDn := false

    EngineOut.new(
         bullEventTime,
         bullTop,
         bullBottom,
         bullOriginTime,
         bullFvgAlign,
         bullEntryPrice,
         bearEventTime,
         bearTop,
         bearBottom,
         bearOriginTime,
         bearFvgAlign,
         bearEntryPrice,
         bullFvgEventTime,
         bullFvgTop,
         bullFvgBottom,
         bullFvgOriginTime,
         bearFvgEventTime,
         bearFvgTop,
         bearFvgBottom,
         bearFvgOriginTime,
         bullPotentialTime,
         bullPotentialTop,
         bullPotentialBottom,
         bearPotentialTime,
         bearPotentialTop,
         bearPotentialBottom,
         atrVal,
         tfVol,
         tfVolAvg,
         tfDelta,
         bullSweepContext,
         bearSweepContext,
         close
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOURCE DATA REQUEST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EngineOut eng = request.security(syminfo.tickerid, tfInput, f_tfEngine(), lookahead=barmerge.lookahead_off)
EngineOut engPrev = eng[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string tfLabel      = f_formatTf(tfInput)
string chartTfLabel = f_formatTf(timeframe.period)

int tfMs       = timeframe.in_seconds(tfInput) * 1000
int chartTfMs  = timeframe.in_seconds(timeframe.period) * 1000

// Local/current timeframe FVGs are only used when the selected source timeframe
// is different from the chart timeframe. If Source Timeframe = Chart/current,
// the chart FVG layer stays hidden so the chart does not double-print the same idea.
bool sourceTfDifferent = tfMs != chartTfMs

int boxExtendMs           = tfMs * extendBars
int chartBoxExtendMs      = chartTfMs * extendBars
int liveBoxExtendMs       = tfMs * liveExtendBars
int liveChartBoxExtendMs  = chartTfMs * liveExtendBars

bool bullSignal = false
bool bearSignal = false
bool bullFvgSignal = false
bool bearFvgSignal = false
bool bullPotentialSignal = false
bool bearPotentialSignal = false

if not na(eng)
    bool engPrevBullTimeNa = na(engPrev) or na(engPrev.bullEventTime)
    bullSignal := not na(eng.bullEventTime) and (engPrevBullTimeNa or eng.bullEventTime != engPrev.bullEventTime)

    bool engPrevBearTimeNa = na(engPrev) or na(engPrev.bearEventTime)
    bearSignal := not na(eng.bearEventTime) and (engPrevBearTimeNa or eng.bearEventTime != engPrev.bearEventTime)

    bool engPrevBullFvgTimeNa = na(engPrev) or na(engPrev.bullFvgEventTime)
    bullFvgSignal := not na(eng.bullFvgEventTime) and (engPrevBullFvgTimeNa or eng.bullFvgEventTime != engPrev.bullFvgEventTime)

    bool engPrevBearFvgTimeNa = na(engPrev) or na(engPrev.bearFvgEventTime)
    bearFvgSignal := not na(eng.bearFvgEventTime) and (engPrevBearFvgTimeNa or eng.bearFvgEventTime != engPrev.bearFvgEventTime)

    bool engPrevBullPotTimeNa = na(engPrev) or na(engPrev.bullPotentialTime)
    bullPotentialSignal := not na(eng.bullPotentialTime) and (engPrevBullPotTimeNa or eng.bullPotentialTime != engPrev.bullPotentialTime)

    bool engPrevBearPotTimeNa = na(engPrev) or na(engPrev.bearPotentialTime)
    bearPotentialSignal := not na(eng.bearPotentialTime) and (engPrevBearPotTimeNa or eng.bearPotentialTime != engPrev.bearPotentialTime)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT TIMEFRAME FVG DATA
// Hidden automatically when the selected source timeframe matches the chart timeframe.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool chartSessionOk = not useSession or not na(time(timeframe.period, sessionTime + ":1234567", "America/New_York"))

float chartAtr    = ta.atr(14)
float chartVol    = volume
float chartVolAvg = ta.sma(volume, 20)
float chartDelta  = volume * (close > open ? 1 : close < open ? -1 : 0)

bool chartBullSweep = low < ta.lowest(low[1], ratingSweepLen)
bool chartBearSweep = high > ta.highest(high[1], ratingSweepLen)

// Maintain time-of-day ranking memory for FVG quality filtering.
// Statistics update first, then the current confirmed FVG is tested against those distributions.
var RankDataArray rankVolumeData = f_rank_init_data()
var RankDataArray rankGapData    = f_rank_init_data()
f_update_rank_statistics(rankVolumeData, rankGapData, rankTodLength)

[chartFvgRankPass, chartFvgGapZ, chartFvgVolumeZ] = f_get_ranked_chart_fvg_pass(rankGapData, rankVolumeData, rankGapStrictness, rankVolumeStrictness)

bool chartRankGate = not rankChartTfFvgs or chartFvgRankPass

bool chartBullFvgSignal = showChartFvgZones and sourceTfDifferent and barstate.isconfirmed and chartSessionOk and low > high[2] and chartRankGate
bool chartBearFvgSignal = showChartFvgZones and sourceTfDifferent and barstate.isconfirmed and chartSessionOk and high < low[2] and chartRankGate

// If Source TF == Chart TF, the source layer is the chart-timeframe layer.
// Gate only that case with the ranked filter; higher/lower source-TF FVGs remain untouched.
bool sourceBullFvgPrintSignal = bullFvgSignal and (sourceTfDifferent or chartRankGate)
bool sourceBearFvgPrintSignal = bearFvgSignal and (sourceTfDifferent or chartRankGate)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EVENT STATE FLAGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool bullMitigatedThisBar = false
bool bearMitigatedThisBar = false

bool sourceBullFvgMitigatedThisBar = false
bool sourceBearFvgMitigatedThisBar = false

bool chartBullFvgMitigatedThisBar = false
bool chartBearFvgMitigatedThisBar = false

bool bullPotentialInvalidatedThisBar = false
bool bearPotentialInvalidatedThisBar = false

bool bullRetestSignalThisBar = false
bool bearRetestSignalThisBar = false
bool bullBreakerCancelThisBar = false
bool bearBreakerCancelThisBar = false

var array<Breaker> breakerArray = array.new<Breaker>()
var array<FvgZone> sourceFvgArray = array.new<FvgZone>()
var array<FvgZone> chartFvgArray = array.new<FvgZone>()
var array<PotentialBreaker> potentialArray = array.new<PotentialBreaker>()

// Completed breaker confirmation triangles are kept separately from the live breaker engine.
// Preserves clean signal history without keeping mitigated zones in active arrays.
var array<label> historicalBreakerSignalLabels = array.new<label>()

f_store_historical_breaker_signal(label signalLabel, bool keepSignal, int maxKeep, array<label> historyArr) =>
    if keepSignal and not na(signalLabel)
        array.push(historyArr, signalLabel)
        while array.size(historyArr) > maxKeep
            label oldest = array.shift(historyArr)
            if not na(oldest)
                oldest.delete()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG VISUAL HIERARCHY
// Source TF owns labels. Current TF becomes a silent layer when overlapping.
// If source/source overlaps, the newest source label wins.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_has_tag(string txt, string tag) =>
    str.contains(txt, tag)

f_add_tf_tag(string txt, string tf) =>
    string out = txt
    if not f_has_tag(out, tf)
        out += " + " + tf
    out

f_apply_fvg_hierarchy(bool isBullSide) =>
    string sourceBase = (isBullSide ? "Bull FVG " : "Bear FVG ") + tfLabel
    string chartBase  = (isBullSide ? "Bull FVG " : "Bear FVG ") + chartTfLabel

    if array.size(sourceFvgArray) > 0
        for i = 0 to array.size(sourceFvgArray) - 1
            FvgZone z = array.get(sourceFvgArray, i)
            if not z.mitigated and z.isBull == isBullSide
                z.baseText := sourceBase
                z.boxId.set_text(f_zone_text(z.baseText, z.rating, z.context, z.birthDelta, z.isTested))
                array.set(sourceFvgArray, i, z)

    if array.size(chartFvgArray) > 0
        for i = 0 to array.size(chartFvgArray) - 1
            FvgZone z = array.get(chartFvgArray, i)
            if not z.mitigated and z.isBull == isBullSide
                z.baseText := hideLocalFvgText ? "" : chartBase
                z.boxId.set_text(z.baseText == "" ? "" : f_zone_text(z.baseText, z.rating, z.context, z.birthDelta, z.isTested))
                array.set(chartFvgArray, i, z)

    if mergeOverlapFvgLabels and array.size(chartFvgArray) > 0 and array.size(sourceFvgArray) > 0
        for c = 0 to array.size(chartFvgArray) - 1
            FvgZone cz = array.get(chartFvgArray, c)
            if not cz.mitigated and cz.isBull == isBullSide
                int leader = na
                for src = array.size(sourceFvgArray) - 1 to 0
                    FvgZone sz = array.get(sourceFvgArray, src)
                    if not sz.mitigated and sz.isBull == isBullSide and f_overlap_zone(cz.top, cz.bottom, sz.top, sz.bottom)
                        leader := src
                        break
                if not na(leader)
                    FvgZone sz = array.get(sourceFvgArray, leader)
                    sz.baseText := f_add_tf_tag(sz.baseText, chartTfLabel)
                    sz.boxId.set_text(f_zone_text(sz.baseText, sz.rating, sz.context, sz.birthDelta, sz.isTested))
                    array.set(sourceFvgArray, leader, sz)
                    if hideMergedChildText
                        cz.baseText := ""
                        cz.boxId.set_text("")
                        array.set(chartFvgArray, c, cz)

    if mergeOverlapFvgLabels and hideMergedChildText and array.size(sourceFvgArray) > 1
        for old = 0 to array.size(sourceFvgArray) - 1
            FvgZone oz = array.get(sourceFvgArray, old)
            if not oz.mitigated and oz.isBull == isBullSide and old < array.size(sourceFvgArray) - 1
                bool hiddenByNewer = false
                for newer = array.size(sourceFvgArray) - 1 to old + 1
                    FvgZone nz = array.get(sourceFvgArray, newer)
                    if not nz.mitigated and nz.isBull == isBullSide and f_overlap_zone(oz.top, oz.bottom, nz.top, nz.bottom)
                        hiddenByNewer := true
                        break
                if hiddenByNewer
                    oz.baseText := ""
                    oz.boxId.set_text("")
                    array.set(sourceFvgArray, old, oz)


var box   latestEntryBox   = na
var line  latestEntryLine  = na
var line  latestSLLine     = na
var line  latestTP1Line    = na
var line  latestTP2Line    = na
var line  latestTP3Line    = na
var label latestEntryLabel = na
var label latestSLLabel    = na
var label latestTP1Label   = na
var label latestTP2Label   = na
var label latestTP3Label   = na

var label latestRetestSignalLabel = na
var label latestCancelSignalLabel = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POTENTIAL BREAKER CREATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showPotentialBreakers and bullPotentialSignal and not na(eng.bullPotentialTop) and not na(eng.bullPotentialBottom)
    box pBull = box.new(
         eng.bullPotentialTime,
         eng.bullPotentialTop,
         eng.bullPotentialTime + boxExtendMs,
         eng.bullPotentialBottom,
         xloc         = xloc.bar_time,
         border_color = potentialBullColor,
         bgcolor      = potentialBullColor,
         text         = isCleanMode ? "BB" : useBoxText ? (useMiniText ? "POT BB" : "Potential Bull BB " + tfLabel) : "",
         text_size    = zoneTextSize,
         text_color   = zoneTextColor,
         text_halign  = zoneTextHalign,
         text_valign  = text.align_center
     )

    label pBullLabel = na
    if useEventLabels
        pBullLabel := label.new(
             eng.bullPotentialTime,
             eng.bullPotentialTop,
             "POT BB",
             xloc      = xloc.bar_time,
             color     = color.new(potentialBullColor, 20),
             textcolor = chart.fg_color,
             style     = label.style_triangleup,
             size      = size.tiny
         )

    array.push(potentialArray, PotentialBreaker.new(
         eng.bullPotentialTop, eng.bullPotentialBottom, true, pBull, pBullLabel, potentialBullColor, false))

    trimOldestPotentials(true, maxPotentialsPerSide, potentialArray)

if showPotentialBreakers and bearPotentialSignal and not na(eng.bearPotentialTop) and not na(eng.bearPotentialBottom)
    box pBear = box.new(
         eng.bearPotentialTime,
         eng.bearPotentialTop,
         eng.bearPotentialTime + boxExtendMs,
         eng.bearPotentialBottom,
         xloc         = xloc.bar_time,
         border_color = potentialBearColor,
         bgcolor      = potentialBearColor,
         text         = isCleanMode ? "BB" : useBoxText ? (useMiniText ? "POT BB" : "Potential Bear BB " + tfLabel) : "",
         text_size    = zoneTextSize,
         text_color   = zoneTextColor,
         text_halign  = zoneTextHalign,
         text_valign  = text.align_center
     )

    label pBearLabel = na
    if useEventLabels
        pBearLabel := label.new(
             eng.bearPotentialTime,
             eng.bearPotentialTop,
             "POT BB",
             xloc      = xloc.bar_time,
             color     = color.new(potentialBearColor, 20),
             textcolor = chart.fg_color,
             style     = label.style_triangledown,
             size      = size.tiny
         )

    array.push(potentialArray, PotentialBreaker.new(
         eng.bearPotentialTop, eng.bearPotentialBottom, false, pBear, pBearLabel, potentialBearColor, false))

    trimOldestPotentials(false, maxPotentialsPerSide, potentialArray)

if bullSignal and breakerDrawMode == "Pivot Candle"
    removePotentialsByDirection(true, potentialArray)

if bearSignal and breakerDrawMode == "Pivot Candle"
    removePotentialsByDirection(false, potentialArray)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKER CREATION & PROJECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bullSignal and not na(eng.bullTop) and not na(eng.bullBottom)
    bool overlapBull = hideOverlap ? checkOverlap(eng.bullTop, eng.bullBottom, true, breakerArray) : false
    if not overlapBull
        bool isFvgAlign = showFvgAlign and eng.bullFvgAlign

        [brRating, brContext] = f_get_zone_rating(true, eng.bullTop, eng.bullBottom, eng.eventClose, eng.tfAtr, eng.tfVol, eng.tfVolAvg, eng.tfDelta, eng.bullSweepContext, isFvgAlign)
        string bullBaseText = isFvgAlign ? "Breaker + FVG " + tfLabel : "Breaker " + tfLabel
        string bullText = f_zone_text(bullBaseText, brRating, brContext, eng.tfDelta, false)

        box bBull = box.new(
             eng.bullOriginTime,
             eng.bullTop,
             eng.bullEventTime + boxExtendMs,
             eng.bullBottom,
             xloc         = xloc.bar_time,
             border_color = isFvgAlign ? fvgAlignColor : bullColor,
             bgcolor      = bullColor,
             text         = bullText,
             text_size    = zoneTextSize,
             text_color   = zoneTextColor,
             text_halign  = zoneTextHalign,
             text_valign  = text.align_center
         )

        float bullMid = math.avg(math.max(eng.bullTop, eng.bullBottom), math.min(eng.bullTop, eng.bullBottom))
        line bullMidLine = na
        if showBreakerMidline
            bullMidLine := line.new(
                 eng.bullOriginTime,
                 bullMid,
                 eng.bullEventTime + boxExtendMs,
                 bullMid,
                 xloc  = xloc.bar_time,
                 color = color.new(chart.fg_color, 75),
                 style = line.style_dashed,
                 width = 1
             )

        label bullBreakLabel = na
        if useEventLabels
            bullBreakLabel := label.new(
                eng.bullEventTime,
                low,
                isFvgAlign ? "+BB+FVG" : "+BB",
                xloc      = xloc.bar_time,
                yloc      = yloc.belowbar,
                color     = color.new(bullColor, 40),
                textcolor = chart.fg_color,
                style     = label.style_triangleup,
                size      = size.tiny
            )

        array.push(breakerArray, Breaker.new(
             eng.bullTop, eng.bullBottom, true, isFvgAlign, bBull, bullBreakLabel, bullMidLine, bullColor, false,
             false, false, false, brRating, brContext, eng.tfDelta, bullBaseText))

        trimOldestBreakers(true, maxBreakersPerSide, breakerArray)

        if showTradePlan
            float bullEntry = eng.bullEntryPrice
            float bullSL    = eng.bullBottom
            float bullRisk  = bullEntry - bullSL

            if bullRisk > 0
                int tradeRight = bar_index + tradePlanExtendBars

                if not na(latestEntryBox)
                    box.delete(latestEntryBox)
                if not na(latestEntryLine)
                    line.delete(latestEntryLine)
                if not na(latestSLLine)
                    line.delete(latestSLLine)
                if not na(latestTP1Line)
                    line.delete(latestTP1Line)
                if not na(latestTP2Line)
                    line.delete(latestTP2Line)
                if not na(latestTP3Line)
                    line.delete(latestTP3Line)
                if not na(latestEntryLabel)
                    label.delete(latestEntryLabel)
                if not na(latestSLLabel)
                    label.delete(latestSLLabel)
                if not na(latestTP1Label)
                    label.delete(latestTP1Label)
                if not na(latestTP2Label)
                    label.delete(latestTP2Label)
                if not na(latestTP3Label)
                    label.delete(latestTP3Label)

                latestEntryBox  := box.new(bar_index, bullEntry, tradeRight, bullSL, xloc=xloc.bar_index, border_color=tradeEntryBullColor, bgcolor=tradeEntryBullColor)
                latestEntryLine := line.new(bar_index, bullEntry, tradeRight, bullEntry, xloc=xloc.bar_index, color=tradeEntryLineColor, style=line.style_solid)
                latestSLLine    := line.new(bar_index, bullSL, tradeRight, bullSL, xloc=xloc.bar_index, color=tradeSLColor, style=line.style_solid)
                float bullTP1 = bullEntry + bullRisk * rr1
                float bullTP2 = bullEntry + bullRisk * rr2
                float bullTP3 = bullEntry + bullRisk * rr3

                latestTP1Line   := line.new(bar_index, bullTP1, tradeRight, bullTP1, xloc=xloc.bar_index, color=tradeTP1Color, style=line.style_dashed)
                latestTP2Line   := line.new(bar_index, bullTP2, tradeRight, bullTP2, xloc=xloc.bar_index, color=tradeTP2Color, style=line.style_dashed)
                latestTP3Line   := line.new(bar_index, bullTP3, tradeRight, bullTP3, xloc=xloc.bar_index, color=tradeTP3Color, style=line.style_dashed)

                latestEntryLabel := label.new(tradeRight, bullEntry, "CONFIRM", xloc=xloc.bar_index, style=label.style_label_left, color=tradeEntryLineColor, textcolor=chart.bg_color, size=size.tiny)
                latestSLLabel    := label.new(tradeRight, bullSL, "INVALID", xloc=xloc.bar_index, style=label.style_label_left, color=tradeSLColor, textcolor=chart.fg_color, size=size.tiny)
                latestTP1Label   := label.new(tradeRight, bullTP1, "R1 " + str.tostring(rr1, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=tradeTP1Color, textcolor=chart.fg_color, size=size.tiny)
                latestTP2Label   := label.new(tradeRight, bullTP2, "R2 " + str.tostring(rr2, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=tradeTP2Color, textcolor=chart.fg_color, size=size.tiny)
                latestTP3Label   := label.new(tradeRight, bullTP3, "R3 " + str.tostring(rr3, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=tradeTP3Color, textcolor=chart.fg_color, size=size.tiny)

if bearSignal and not na(eng.bearTop) and not na(eng.bearBottom)
    bool overlapBear = hideOverlap ? checkOverlap(eng.bearTop, eng.bearBottom, false, breakerArray) : false
    if not overlapBear
        bool isFvgAlign = showFvgAlign and eng.bearFvgAlign

        [brRating, brContext] = f_get_zone_rating(false, eng.bearTop, eng.bearBottom, eng.eventClose, eng.tfAtr, eng.tfVol, eng.tfVolAvg, eng.tfDelta, eng.bearSweepContext, isFvgAlign)
        string bearBaseText = isFvgAlign ? "Breaker + FVG " + tfLabel : "Breaker " + tfLabel
        string bearText = f_zone_text(bearBaseText, brRating, brContext, eng.tfDelta, false)

        box bBear = box.new(
             eng.bearOriginTime,
             eng.bearTop,
             eng.bearEventTime + boxExtendMs,
             eng.bearBottom,
             xloc         = xloc.bar_time,
             border_color = isFvgAlign ? fvgAlignColor : bearColor,
             bgcolor      = bearColor,
             text         = bearText,
             text_size    = zoneTextSize,
             text_color   = zoneTextColor,
             text_halign  = zoneTextHalign,
             text_valign  = text.align_center
         )

        float bearMid = math.avg(math.max(eng.bearTop, eng.bearBottom), math.min(eng.bearTop, eng.bearBottom))
        line bearMidLine = na
        if showBreakerMidline
            bearMidLine := line.new(
                 eng.bearOriginTime,
                 bearMid,
                 eng.bearEventTime + boxExtendMs,
                 bearMid,
                 xloc  = xloc.bar_time,
                 color = color.new(chart.fg_color, 75),
                 style = line.style_dashed,
                 width = 1
             )

        label bearBreakLabel = na
        if useEventLabels
            bearBreakLabel := label.new(
                eng.bearEventTime,
                high,
                isFvgAlign ? "-BB+FVG" : "-BB",
                xloc      = xloc.bar_time,
                yloc      = yloc.abovebar,
                color     = color.new(bearColor, 40),
                textcolor = chart.fg_color,
                style     = label.style_triangledown,
                size      = size.tiny
            )

        array.push(breakerArray, Breaker.new(
             eng.bearTop, eng.bearBottom, false, isFvgAlign, bBear, bearBreakLabel, bearMidLine, bearColor, false,
             false, false, false, brRating, brContext, eng.tfDelta, bearBaseText))

        trimOldestBreakers(false, maxBreakersPerSide, breakerArray)

        if showTradePlan
            float bearEntry = eng.bearEntryPrice
            float bearSL    = eng.bearTop
            float bearRisk  = bearSL - bearEntry

            if bearRisk > 0
                int tradeRight = bar_index + tradePlanExtendBars

                if not na(latestEntryBox)
                    box.delete(latestEntryBox)
                if not na(latestEntryLine)
                    line.delete(latestEntryLine)
                if not na(latestSLLine)
                    line.delete(latestSLLine)
                if not na(latestTP1Line)
                    line.delete(latestTP1Line)
                if not na(latestTP2Line)
                    line.delete(latestTP2Line)
                if not na(latestTP3Line)
                    line.delete(latestTP3Line)
                if not na(latestEntryLabel)
                    label.delete(latestEntryLabel)
                if not na(latestSLLabel)
                    label.delete(latestSLLabel)
                if not na(latestTP1Label)
                    label.delete(latestTP1Label)
                if not na(latestTP2Label)
                    label.delete(latestTP2Label)
                if not na(latestTP3Label)
                    label.delete(latestTP3Label)

                latestEntryBox  := box.new(bar_index, bearSL, tradeRight, bearEntry, xloc=xloc.bar_index, border_color=tradeEntryBearColor, bgcolor=tradeEntryBearColor)
                latestEntryLine := line.new(bar_index, bearEntry, tradeRight, bearEntry, xloc=xloc.bar_index, color=tradeEntryLineColor, style=line.style_solid)
                latestSLLine    := line.new(bar_index, bearSL, tradeRight, bearSL, xloc=xloc.bar_index, color=tradeSLColor, style=line.style_solid)
                float bearTP1 = bearEntry - bearRisk * rr1
                float bearTP2 = bearEntry - bearRisk * rr2
                float bearTP3 = bearEntry - bearRisk * rr3

                latestTP1Line   := line.new(bar_index, bearTP1, tradeRight, bearTP1, xloc=xloc.bar_index, color=tradeTP1Color, style=line.style_dashed)
                latestTP2Line   := line.new(bar_index, bearTP2, tradeRight, bearTP2, xloc=xloc.bar_index, color=tradeTP2Color, style=line.style_dashed)
                latestTP3Line   := line.new(bar_index, bearTP3, tradeRight, bearTP3, xloc=xloc.bar_index, color=tradeTP3Color, style=line.style_dashed)

                latestEntryLabel := label.new(tradeRight, bearEntry, "CONFIRM", xloc=xloc.bar_index, style=label.style_label_left, color=tradeEntryLineColor, textcolor=chart.bg_color, size=size.tiny)
                latestSLLabel    := label.new(tradeRight, bearSL, "INVALID", xloc=xloc.bar_index, style=label.style_label_left, color=tradeSLColor, textcolor=chart.fg_color, size=size.tiny)
                latestTP1Label   := label.new(tradeRight, bearTP1, "R1 " + str.tostring(rr1, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=tradeTP1Color, textcolor=chart.fg_color, size=size.tiny)
                latestTP2Label   := label.new(tradeRight, bearTP2, "R2 " + str.tostring(rr2, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=tradeTP2Color, textcolor=chart.fg_color, size=size.tiny)
                latestTP3Label   := label.new(tradeRight, bearTP3, "R3 " + str.tostring(rr3, "#.##") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=tradeTP3Color, textcolor=chart.fg_color, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOURCE TIMEFRAME FVG CREATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showFvgZones and sourceBullFvgPrintSignal and not na(eng.bullFvgTop) and not na(eng.bullFvgBottom) and eng.bullFvgTop > eng.bullFvgBottom
    [fvgRating, fvgContext] = f_get_zone_rating(true, eng.bullFvgTop, eng.bullFvgBottom, eng.eventClose, eng.tfAtr, eng.tfVol, eng.tfVolAvg, eng.tfDelta, eng.bullSweepContext, false)

    string bullFvgBaseText = "Bull FVG " + tfLabel + (rankChartTfFvgs and not sourceTfDifferent ? " • Ranked" : "")
    string bullFvgText = f_zone_text(bullFvgBaseText, fvgRating, fvgContext, eng.tfDelta, false)

    box zBull = box.new(
         eng.bullFvgOriginTime,
         eng.bullFvgTop,
         eng.bullFvgEventTime + boxExtendMs,
         eng.bullFvgBottom,
         xloc         = xloc.bar_time,
         border_color = bullFvgColor,
         bgcolor      = bullFvgColor,
         text         = bullFvgText,
         text_size    = zoneTextSize,
         text_color   = zoneTextColor,
         text_halign  = zoneTextHalign,
         text_valign  = text.align_center
     )

    label bullFvgLabel = na
    array.push(sourceFvgArray, FvgZone.new(
         eng.bullFvgTop, eng.bullFvgBottom, true, zBull, bullFvgLabel, na, bullFvgColor, false,
         false, fvgRating, fvgContext, eng.tfDelta, bullFvgBaseText))

    trimOldestFvgs(true, maxFvgsPerSide, sourceFvgArray)
    f_apply_fvg_hierarchy(true)

if showFvgZones and sourceBearFvgPrintSignal and not na(eng.bearFvgTop) and not na(eng.bearFvgBottom) and eng.bearFvgTop > eng.bearFvgBottom
    [fvgRating, fvgContext] = f_get_zone_rating(false, eng.bearFvgTop, eng.bearFvgBottom, eng.eventClose, eng.tfAtr, eng.tfVol, eng.tfVolAvg, eng.tfDelta, eng.bearSweepContext, false)

    string bearFvgBaseText = "Bear FVG " + tfLabel + (rankChartTfFvgs and not sourceTfDifferent ? " • Ranked" : "")
    string bearFvgText = f_zone_text(bearFvgBaseText, fvgRating, fvgContext, eng.tfDelta, false)

    box zBear = box.new(
         eng.bearFvgOriginTime,
         eng.bearFvgTop,
         eng.bearFvgEventTime + boxExtendMs,
         eng.bearFvgBottom,
         xloc         = xloc.bar_time,
         border_color = bearFvgColor,
         bgcolor      = bearFvgColor,
         text         = bearFvgText,
         text_size    = zoneTextSize,
         text_color   = zoneTextColor,
         text_halign  = zoneTextHalign,
         text_valign  = text.align_center
     )

    label bearFvgLabel = na
    array.push(sourceFvgArray, FvgZone.new(
         eng.bearFvgTop, eng.bearFvgBottom, false, zBear, bearFvgLabel, na, bearFvgColor, false,
         false, fvgRating, fvgContext, eng.tfDelta, bearFvgBaseText))

    trimOldestFvgs(false, maxFvgsPerSide, sourceFvgArray)
    f_apply_fvg_hierarchy(false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT TIMEFRAME FVG CREATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Local/current TF FVGs are a silent precision layer:
// - no text label by default
// - middle line through the imbalance
// - stronger colour when rating is above Weak
if chartBullFvgSignal and low > high[2]
    [chRating, chContext] = f_get_zone_rating(true, low, high[2], close, chartAtr, chartVol, chartVolAvg, chartDelta, chartBullSweep, false)

    bool isStrongLocal = chRating != "Weak"
    color localBullBoxColor = color.new(#22c55e, 100)
    color localBullMidColor = color.new(#22c55e, isStrongLocal ? 0 : 55)
    int   localBullMidWidth = isStrongLocal ? 2 : 1

    bool mergedWithSource = mergeOverlapFvgLabels and f_merge_fvg_label(true, low, high[2], chartTfLabel, sourceFvgArray)

    // Current timeframe FVG stays as a silent precision layer.
    // It prints the midpoint line only and never adds a zone label.
    string chartBullBase = ""
    string chartBullText = ""
    float bullMid = (low + high[2]) / 2.0

    box zChartBull = box.new(
         time[2],
         low,
         time + chartBoxExtendMs,
         high[2],
         xloc         = xloc.bar_time,
         border_color = localBullBoxColor,
         bgcolor      = localBullBoxColor,
         text         = chartBullText,
         text_size    = zoneTextSize,
         text_color   = zoneTextColor,
         text_halign  = zoneTextHalign,
         text_valign  = text.align_center
     )

    line bullMidLine = na
    if showLocalFvgMidline
        bullMidLine := line.new(
             time[2],
             bullMid,
             time + chartBoxExtendMs,
             bullMid,
             xloc  = xloc.bar_time,
             color = localBullMidColor,
             style = line.style_dashed,
             width = localBullMidWidth
         )

    array.push(chartFvgArray, FvgZone.new(
         low, high[2], true, zChartBull, na, bullMidLine, localBullBoxColor, false,
         false, chRating, chContext, chartDelta, chartBullBase))

    trimOldestFvgs(true, maxChartFvgsPerSide, chartFvgArray)
    f_apply_fvg_hierarchy(true)

if chartBearFvgSignal and low[2] > high
    [chRating, chContext] = f_get_zone_rating(false, low[2], high, close, chartAtr, chartVol, chartVolAvg, chartDelta, chartBearSweep, false)

    bool isStrongLocal = chRating != "Weak"
    color localBearBoxColor = color.new(#ef4444, 100)
    color localBearMidColor = color.new(#ef4444, isStrongLocal ? 0 : 55)
    int   localBearMidWidth = isStrongLocal ? 2 : 1

    bool mergedWithSource = mergeOverlapFvgLabels and f_merge_fvg_label(false, low[2], high, chartTfLabel, sourceFvgArray)

    // Current timeframe FVG stays as a silent precision layer.
    // It prints the midpoint line only and never adds a zone label.
    string chartBearBase = ""
    string chartBearText = ""
    float bearMid = (low[2] + high) / 2.0

    box zChartBear = box.new(
         time[2],
         low[2],
         time + chartBoxExtendMs,
         high,
         xloc         = xloc.bar_time,
         border_color = localBearBoxColor,
         bgcolor      = localBearBoxColor,
         text         = chartBearText,
         text_size    = zoneTextSize,
         text_color   = zoneTextColor,
         text_halign  = zoneTextHalign,
         text_valign  = text.align_center
     )

    line bearMidLine = na
    if showLocalFvgMidline
        bearMidLine := line.new(
             time[2],
             bearMid,
             time + chartBoxExtendMs,
             bearMid,
             xloc  = xloc.bar_time,
             color = localBearMidColor,
             style = line.style_dashed,
             width = localBearMidWidth
         )

    array.push(chartFvgArray, FvgZone.new(
         low[2], high, false, zChartBear, na, bearMidLine, localBearBoxColor, false,
         false, chRating, chContext, chartDelta, chartBearBase))

    trimOldestFvgs(false, maxChartFvgsPerSide, chartFvgArray)
    f_apply_fvg_hierarchy(false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POTENTIAL BREAKER MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color fadedLabelText = color.new(chart.fg_color, 80)

if array.size(potentialArray) > 0
    for i = array.size(potentialArray) - 1 to 0
        PotentialBreaker p = array.get(potentialArray, i)
        bool wasInvalidated = p.invalidated

        if not p.invalidated
            p.boxId.set_right(time + liveBoxExtendMs)

            bool invalidated = (p.isBull and low < p.bottom) or ((not p.isBull) and high > p.top)
            if invalidated
                p.invalidated := true

                if hideMitigated
                    if not na(p.boxId)
                        p.boxId.delete()
                    if not na(p.labelId)
                        p.labelId.delete()
                else
                    p.boxId.set_border_style(line.style_dotted)
                    p.boxId.set_bgcolor(color.new(p.baseColor, 96))
                    if not na(p.labelId)
                        p.labelId.set_color(color.new(p.baseColor, 96))
                        p.labelId.set_textcolor(fadedLabelText)

        array.set(potentialArray, i, p)

        if not wasInvalidated and p.invalidated
            bullPotentialInvalidatedThisBar := bullPotentialInvalidatedThisBar or p.isBull
            bearPotentialInvalidatedThisBar := bearPotentialInvalidatedThisBar or (not p.isBull)

        // Terminal records leave the live array regardless of visual-history preference.
        // If Hide Mitigated is OFF, the faded drawing remains on chart as a static object.
        if p.invalidated
            array.remove(potentialArray, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKER ZONE MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(breakerArray) > 0
    for i = array.size(breakerArray) - 1 to 0
        Breaker br = array.get(breakerArray, i)
        bool wasMitigated = br.mitigated

        float zTop = math.max(br.top, br.bottom)
        float zBot = math.min(br.top, br.bottom)
        float zMid = math.avg(zTop, zBot)

        if not br.mitigated
            br.boxId.set_right(time + liveBoxExtendMs)
            if not na(br.midLine)
                br.midLine.set_x2(time + liveBoxExtendMs)

            bool touched = false
            if br.isBull and low <= zTop
                touched := true
            if not br.isBull and high >= zBot
                touched := true

            if touched and not br.isTested
                br.isTested := true
                br.boxId.set_text(f_zone_text(br.baseText, br.rating, br.context, br.birthDelta, br.isTested))

            // Retest signal layer: breaker forms first, then price returns into the zone and confirms away.
            if showBreakerRetestSignals and not br.hasRetestSignal and not br.isBroken
                if br.isBull
                    bool bullRetestSignal = open > zMid and open < zTop and close > zTop
                    bool bullCancel       = close < zMid and close > zBot
                    if bullRetestSignal
                        br.hasRetestSignal := true
                        bullRetestSignalThisBar := true
                        if useEventLabels
                            if breakerRetestLabelMode == "Latest Only" and not na(latestRetestSignalLabel)
                                label.delete(latestRetestSignalLabel)
                            latestRetestSignalLabel := label.new(time, low, "UP", xloc=xloc.bar_time, style=label.style_triangleup, color=color.new(br.baseColor, 25), textcolor=chart.fg_color, size=size.tiny)
                    else if bullCancel
                        br.isBroken := true
                        bullBreakerCancelThisBar := true
                        if useEventLabels
                            if breakerRetestLabelMode == "Latest Only" and not na(latestCancelSignalLabel)
                                label.delete(latestCancelSignalLabel)
                            latestCancelSignalLabel := label.new(time, low, "×", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.orange, 20), textcolor=chart.fg_color, size=size.tiny)
                else
                    bool bearRetestSignal = open < zMid and open > zBot and close < zBot
                    bool bearCancel       = close > zMid and close < zTop
                    if bearRetestSignal
                        br.hasRetestSignal := true
                        bearRetestSignalThisBar := true
                        if useEventLabels
                            if breakerRetestLabelMode == "Latest Only" and not na(latestRetestSignalLabel)
                                label.delete(latestRetestSignalLabel)
                            latestRetestSignalLabel := label.new(time, high, "DN", xloc=xloc.bar_time, style=label.style_triangledown, color=color.new(br.baseColor, 25), textcolor=chart.fg_color, size=size.tiny)
                    else if bearCancel
                        br.isBroken := true
                        bearBreakerCancelThisBar := true
                        if useEventLabels
                            if breakerRetestLabelMode == "Latest Only" and not na(latestCancelSignalLabel)
                                label.delete(latestCancelSignalLabel)
                            latestCancelSignalLabel := label.new(time, high, "×", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.orange, 20), textcolor=chart.fg_color, size=size.tiny)

            bool invalidated = useBreakerCandleRun ? ((br.isBull and close < zBot) or ((not br.isBull) and close > zTop)) : ((br.isBull and low < zBot) or ((not br.isBull) and high > zTop))
            if invalidated
                br.mitigated := true

                // Preserve the confirmation triangle independently from the zone box.
                // Once stored here, the triangle is visual history only and no longer participates in live calculations.
                if keepHistoricalBreakerSignals and not na(br.labelId)
                    f_store_historical_breaker_signal(br.labelId, keepHistoricalBreakerSignals, maxHistoricalBreakerSignals, historicalBreakerSignalLabels)
                else if not na(br.labelId)
                    br.labelId.delete()

                if hideMitigated
                    if not na(br.boxId)
                        br.boxId.delete()
                    if not na(br.midLine)
                        br.midLine.delete()
                else
                    br.boxId.set_border_style(line.style_dotted)
                    br.boxId.set_bgcolor(color.new(br.baseColor, 95))
                    if not na(br.midLine)
                        br.midLine.set_color(color.new(br.baseColor, 75))
                        br.midLine.set_style(line.style_dotted)

        array.set(breakerArray, i, br)

        if not wasMitigated and br.mitigated
            bullMitigatedThisBar := bullMitigatedThisBar or br.isBull
            bearMitigatedThisBar := bearMitigatedThisBar or (not br.isBull)

        // Always remove completed breakers from the live engine.
        // Their box may remain visible when Hide Mitigated is OFF, while the +BB triangle
        // can remain independently through historicalBreakerSignalLabels.
        if br.mitigated
            array.remove(breakerArray, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SOURCE FVG MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(sourceFvgArray) > 0
    for i = array.size(sourceFvgArray) - 1 to 0
        FvgZone z = array.get(sourceFvgArray, i)
        bool wasMitigated = z.mitigated

        if not z.mitigated
            z.boxId.set_right(time + liveBoxExtendMs)
            if not na(z.midLine)
                z.midLine.set_x2(time + liveBoxExtendMs)

            bool touched = false
            if z.isBull and low <= z.top
                touched := true
            if not z.isBull and high >= z.bottom
                touched := true

            if touched and not z.isTested
                z.isTested := true
                if z.baseText != ""
                    z.boxId.set_text(f_zone_text(z.baseText, z.rating, z.context, z.birthDelta, z.isTested))

            bool filled = (z.isBull and low <= z.bottom) or ((not z.isBull) and high >= z.top)
            if filled
                z.mitigated := true

                if hideMitigated
                    if not na(z.boxId)
                        z.boxId.delete()
                    if not na(z.labelId)
                        z.labelId.delete()
                    if not na(z.midLine)
                        z.midLine.delete()
                else
                    z.boxId.set_border_style(line.style_dotted)
                    z.boxId.set_bgcolor(color.new(z.baseColor, 95))
                    if not na(z.midLine)
                        z.midLine.set_color(color.new(z.baseColor, 75))
                        z.midLine.set_style(line.style_dotted)
                    if not na(z.labelId)
                        z.labelId.set_color(color.new(z.baseColor, 95))
                        z.labelId.set_textcolor(fadedLabelText)

        array.set(sourceFvgArray, i, z)

        if not wasMitigated and z.mitigated
            sourceBullFvgMitigatedThisBar := sourceBullFvgMitigatedThisBar or z.isBull
            sourceBearFvgMitigatedThisBar := sourceBearFvgMitigatedThisBar or (not z.isBull)

        // Completed FVGs leave the live array even when their faded drawing is kept on chart.
        if z.mitigated
            array.remove(sourceFvgArray, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT TIMEFRAME FVG MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(chartFvgArray) > 0
    for i = array.size(chartFvgArray) - 1 to 0
        FvgZone z = array.get(chartFvgArray, i)
        bool wasMitigated = z.mitigated

        if not z.mitigated
            z.boxId.set_right(time + liveChartBoxExtendMs)
            if not na(z.midLine)
                z.midLine.set_x2(time + liveChartBoxExtendMs)

            bool touched = false
            if z.isBull and low <= z.top
                touched := true
            if not z.isBull and high >= z.bottom
                touched := true

            if touched and not z.isTested
                z.isTested := true
                if z.baseText != ""
                    z.boxId.set_text(f_zone_text(z.baseText, z.rating, z.context, z.birthDelta, z.isTested))

            bool filled = (z.isBull and low <= z.bottom) or ((not z.isBull) and high >= z.top)
            if filled
                z.mitigated := true

                if hideMitigated
                    if not na(z.boxId)
                        z.boxId.delete()
                    if not na(z.labelId)
                        z.labelId.delete()
                    if not na(z.midLine)
                        z.midLine.delete()
                else
                    z.boxId.set_border_style(line.style_dotted)
                    z.boxId.set_bgcolor(color.new(z.baseColor, 95))
                    if not na(z.midLine)
                        z.midLine.set_color(color.new(z.baseColor, 75))
                        z.midLine.set_style(line.style_dotted)
                    if not na(z.labelId)
                        z.labelId.set_color(color.new(z.baseColor, 95))
                        z.labelId.set_textcolor(fadedLabelText)

        array.set(chartFvgArray, i, z)

        if not wasMitigated and z.mitigated
            chartBullFvgMitigatedThisBar := chartBullFvgMitigatedThisBar or z.isBull
            chartBearFvgMitigatedThisBar := chartBearFvgMitigatedThisBar or (not z.isBull)

        // Completed current-TF FVGs leave the live array even when their faded drawing is kept on chart.
        if z.mitigated
            array.remove(chartFvgArray, i)

if mergeOverlapFvgLabels
    f_apply_fvg_hierarchy(true)
    f_apply_fvg_hierarchy(false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string masterAlertText = ""

if bullPotentialSignal and showPotentialBreakers
    masterAlertText += "Potential Bull Breaker Forming! "
    if enablePotentialAlerts
        alert("Potential Bull Breaker forming on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if bearPotentialSignal and showPotentialBreakers
    masterAlertText += "Potential Bear Breaker Forming! "
    if enablePotentialAlerts
        alert("Potential Bear Breaker forming on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if bullSignal
    masterAlertText += "Bullish Breaker Signal! "
    if enableAlerts
        alert("Bullish Breaker signal on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if bearSignal
    masterAlertText += "Bearish Breaker Signal! "
    if enableAlerts
        alert("Bearish Breaker signal on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if sourceBullFvgPrintSignal and showFvgZones
    masterAlertText += "Source Bullish FVG Printed! "
    if enableAlerts
        alert("Source Bullish FVG on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if sourceBearFvgPrintSignal and showFvgZones
    masterAlertText += "Source Bearish FVG Printed! "
    if enableAlerts
        alert("Source Bearish FVG on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if chartBullFvgSignal
    masterAlertText += "Current TF Bullish FVG Printed! "

if chartBearFvgSignal
    masterAlertText += "Current TF Bearish FVG Printed! "

if bullMitigatedThisBar
    masterAlertText += "Bullish Breaker Mitigated. "
    if enableAlerts
        alert("Bullish breaker mitigated on " + syminfo.tickerid, alert.freq_once_per_bar_close)

if bearMitigatedThisBar
    masterAlertText += "Bearish Breaker Mitigated. "
    if enableAlerts
        alert("Bearish breaker mitigated on " + syminfo.tickerid, alert.freq_once_per_bar_close)

if bullRetestSignalThisBar
    masterAlertText += "Bullish Breaker Retest Signal. "
    if enableAlerts
        alert("Bullish breaker retest signal on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if bearRetestSignalThisBar
    masterAlertText += "Bearish Breaker Retest Signal. "
    if enableAlerts
        alert("Bearish breaker retest signal on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if bullBreakerCancelThisBar
    masterAlertText += "Bullish Breaker Cancelled. "
    if enableAlerts
        alert("Bullish breaker cancelled on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if bearBreakerCancelThisBar
    masterAlertText += "Bearish Breaker Cancelled. "
    if enableAlerts
        alert("Bearish breaker cancelled on " + syminfo.tickerid + " (" + tfInput + ")", alert.freq_once_per_bar_close)

if sourceBullFvgMitigatedThisBar
    masterAlertText += "Source Bullish FVG Filled. "
    if enableAlerts
        alert("Source bullish FVG filled on " + syminfo.tickerid, alert.freq_once_per_bar_close)

if sourceBearFvgMitigatedThisBar
    masterAlertText += "Source Bearish FVG Filled. "
    if enableAlerts
        alert("Source bearish FVG filled on " + syminfo.tickerid, alert.freq_once_per_bar_close)

if chartBullFvgMitigatedThisBar
    masterAlertText += "Current TF Bullish FVG Filled. "

if chartBearFvgMitigatedThisBar
    masterAlertText += "Current TF Bearish FVG Filled. "

if useMasterAlert and masterAlertText != ""
    alert(masterAlertText + "on " + syminfo.tickerid + " | Source TF: " + tfInput, alert.freq_once_per_bar_close)

alertcondition(bullPotentialSignal and showPotentialBreakers, "Potential Bull Breaker", "Potential Bull Breaker Forming")
alertcondition(bearPotentialSignal and showPotentialBreakers, "Potential Bear Breaker", "Potential Bear Breaker Forming")
alertcondition(bullSignal, "Bullish Breaker Signal", "Bullish breaker signal")
alertcondition(bearSignal, "Bearish Breaker Signal", "Bearish breaker signal")
alertcondition(sourceBullFvgPrintSignal and showFvgZones, "Source Bullish FVG", "Source bullish FVG printed")
alertcondition(sourceBearFvgPrintSignal and showFvgZones, "Source Bearish FVG", "Source bearish FVG printed")
alertcondition(chartBullFvgSignal, "Current TF Bullish FVG", "Current TF bullish FVG printed")
alertcondition(chartBearFvgSignal, "Current TF Bearish FVG", "Current TF bearish FVG printed")
alertcondition(bullMitigatedThisBar, "Bullish Breaker Mitigated", "Bullish breaker mitigated")
alertcondition(bearMitigatedThisBar, "Bearish Breaker Mitigated", "Bearish breaker mitigated")
alertcondition(sourceBullFvgMitigatedThisBar, "Source Bullish FVG Filled", "Source bullish FVG filled")
alertcondition(sourceBearFvgMitigatedThisBar, "Source Bearish FVG Filled", "Source bearish FVG filled")
alertcondition(chartBullFvgMitigatedThisBar, "Current TF Bullish FVG Filled", "Current TF bullish FVG filled")
alertcondition(chartBearFvgMitigatedThisBar, "Current TF Bearish FVG Filled", "Current TF bearish FVG filled")
alertcondition(masterAlertText != "", "Master Alert (Any Event)", "A potential breaker, breaker, or FVG event occurred")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table uiTable = table.new(position.bottom_right, 8, 1, bgcolor=color.new(chart.bg_color, 50), border_width=1)

if barstate.islast
    table.cell(uiTable, 0, 0, "SRC: " + tfLabel, text_color=chart.fg_color, text_size=sizeTable)
    table.cell(uiTable, 1, 0, "CH: " + chartTfLabel, text_color=chart.fg_color, text_size=sizeTable)
    table.cell(uiTable, 2, 0, useSession ? "NY FILTER" : "SESSION OFF", text_color=useSession ? #089981 : #eab308, text_size=sizeTable)
    table.cell(uiTable, 3, 0, showFvgZones ? "SRC FVG ON" : "SRC FVG OFF", text_color=showFvgZones ? #5b9cf6 : chart.fg_color, text_size=sizeTable)
    table.cell(uiTable, 4, 0,
         not sourceTfDifferent
             ? (showFvgZones ? (rankChartTfFvgs ? "CH FVG RANKED" : "CH FVG SRC") : "CH FVG OFF")
             : (showChartFvgZones ? (rankChartTfFvgs ? "CH FVG RANKED" : "CH FVG ON") : "CH FVG OFF"),
         text_color=(not sourceTfDifferent ? showFvgZones : showChartFvgZones) ? #22c55e : chart.fg_color,
         text_size=sizeTable)
    table.cell(uiTable, 5, 0, showPotentialBreakers ? "POT BB ON" : "POT BB OFF", text_color=showPotentialBreakers ? color.orange : chart.fg_color, text_size=sizeTable)
    table.cell(uiTable, 6, 0, breakerDrawMode == "Pivot Candle" ? "BB: PIVOT" : "BB: MSS RUN", text_color=breakerDrawMode == "Pivot Candle" ? #eab308 : #5b9cf6, text_size=sizeTable)
    table.cell(uiTable, 7, 0, showZoneRating ? "RATING ON" : "RATING OFF", text_color=showZoneRating ? color.lime : chart.fg_color, text_size=sizeTable)
````
