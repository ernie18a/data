# ID009 Liquidity Path [ReconHK] 

- url: https://www.tradingview.com/script/ZSe8lzOF-ID009-Liquidity-Path-ReconHK/
- type: indicator
- pine_id: PUB;ad4c61fd32424b7fbbbaf1fbde59b8ae
- version: 1.0

## Description

A liquidity-focused chart indicator designed to help traders study whether price is reclaiming or holding above a key liquidity pivot, while also checking structural liquidity, traded activity, trend context, relative volume, and buyer-pressure confirmation.

------------------------------------------------------------------------------------------------
## [b]1. [Must read as user] What this indicator is for 🧭[/b]
------------------------------------------------------------------------------------------------
Liquidity Path is designed to help traders understand whether price is moving through a healthier liquidity area instead of chasing random breakouts. The indicator builds a liquidity profile from the selected lookback period, finds the main activity area, and marks the Liquidity Pivot, also known as the profile point of control.

The main idea is simple: price action near a high-activity area can be more meaningful than price action in a thin or fragmented area. When price reclaims or holds above the Liquidity Pivot with volume, buyer pressure, and trend support, the setup may show a stronger liquidity path.

This indicator is not a buy-or-sell system by itself. It is a decision-support tool for reviewing liquidity structure, participation, and price behavior around the profile pivot.

[quote]The purpose is to help traders avoid late or weak breakouts by checking whether price is close to the main liquidity pivot and supported by participation.[/quote]

------------------------------------------------------------------------------------------------
## [b]2. [Must read as user] What you see on the chart 👀[/b]
------------------------------------------------------------------------------------------------

The indicator can show several visual elements:
[list]
[*][b]Blue liquidity profile[/b]: a right-side profile showing where more trading activity happened during the selected lookback.
[*][b]Orange Liquidity Pivot[/b]: the main profile pivot, based on the highest activity area of the profile.
[*][b]Lookback zone[/b]: the chart area used to build the liquidity profile.
[*][b]EMA 20 and EMA 50[/b]: optional trend-context lines.
[*][b]Optional bias background[/b]: subtle background showing whether price is above or below the Liquidity Pivot.
[/list]
The blue profile helps the user see where activity is concentrated. Thicker profile areas mean more activity was detected at that price zone. The orange Liquidity Pivot is the key reference level used by the path logic.

When price is above the Liquidity Pivot, the market is trading above the main activity reference. When price is below it, price is trading under that reference and may need a reclaim before the path setup improves.

------------------------------------------------------------------------------------------------
## [b]3. [Must read as user] How to read the Liquidity Pivot 🟠[/b]
------------------------------------------------------------------------------------------------

The Liquidity Pivot is the central level of this indicator. It represents the price area with the strongest smoothed activity inside the selected profile lookback.

A reclaim above the Liquidity Pivot can be useful because it shows that price has moved back above a major activity reference. A hold or retest above the pivot can also be important because it may show acceptance above that area instead of only a short-lived breakout.

The indicator checks whether price is:
[list]
[*]above the Liquidity Pivot,
[*]not too far above the pivot,
[*]not too extended from the short-term trend,
[*]supported by relative volume,
[*]showing buyer-pressure behavior,
[*]aligned with the trend filter when enabled.
[/list]
This helps separate cleaner liquidity-path situations from late, extended, or weak moves.

[quote]A reclaim is more useful when it happens near the pivot with participation. A move that is already too far above the pivot may be late and riskier.[/quote]

------------------------------------------------------------------------------------------------
## [b]4. [Must read as user] Suggested workflow ✅[/b]
------------------------------------------------------------------------------------------------

A practical workflow:
[list=1]
[*]Start with the default settings.
[*]Keep Liquidity quality on Balanced for most liquid stocks and crypto.
[*]Use the blue liquidity profile to see where activity is concentrated.
[*]Watch the orange Liquidity Pivot as the main reference level.
[*]Check whether price is reclaiming or holding above the pivot.
[*]Use the relative volume setting to require real participation.
[*]Use the trend filter if you want signals to prefer EMA trend alignment.
[*]Avoid acting when price is already too far above the pivot or too extended from the EMA.
[*]Use alerts as chart-review reminders, not automatic trade instructions.
[*]Confirm the setup with your own support, resistance, market structure, news, and risk plan.
[/list]
The indicator is most useful when the user wants to study whether price is moving from a high-activity base into a stronger continuation path. It is less useful when the market is illiquid, fragmented, or moving with large gaps and weak participation.

------------------------------------------------------------------------------------------------
## [b]5. [Must read as user] Risk notes and correct expectations ⚠️[/b]
------------------------------------------------------------------------------------------------

This indicator does not guarantee that price will continue higher after reclaiming the Liquidity Pivot. A reclaim can fail, especially during weak market conditions, low-volume moves, news shocks, or broad market selloffs.

Important reminders:
[list]
[*]The Liquidity Pivot is a reference level, not a guaranteed support level.
[*]A path signal is a confirmation event, not a complete trading plan.
[*]Relative volume can confirm participation, but it does not remove risk.
[*]Trend alignment can improve context, but trends can reverse.
[*]Thin or fragmented symbols may produce less reliable readings.
[*]Always define risk, stop logic, invalidation, and exit planning separately.
[/list]
This script does not place trades, manage positions, set stops, or calculate position size. It should be used only as a decision-support tool.

[quote]Use the indicator to organize your liquidity and participation review. Do not use it as a substitute for risk management.[/quote]

------------------------------------------------------------------------------------------------
## [b]6. [Optional technical explanation] Script structure and originality[/b]
------------------------------------------------------------------------------------------------

[pine]
Liquidity Path is an overlay indicator. It is not a strategy.

The script uses:

* indicator(..., overlay = true)
* plot() for the Liquidity Pivot / POC line
* plot() for optional EMA 20 and EMA 50 lines
* bgcolor() for optional bias background
* box.new() for the right-side liquidity profile
* box.new() for the lookback zone
* label.new() for the pivot label
* alertcondition() for signal and pivot events

The script does not use:

* strategy.entry()
* strategy.exit()
* strategy.close()
* automatic order placement
* automatic risk management

The originality of the script is in how it combines several liquidity concepts into one path framework.

The main components are:

1. Structural liquidity filter
2. Continuity check
3. Profile-based Liquidity Pivot
4. Smoothed activity profile
5. Value area calculation
6. Trend context using EMA 20 and EMA 50
7. Relative volume confirmation
8. Buyer-pressure confirmation
9. POC reclaim or retest logic
10. Extension control
11. Path-mode strictness
12. Cooldown control
13. Visual profile and pivot tools
14. Alerts for reclaim, loss, and path signal

These components are not just displayed separately. They work together to answer one practical question:
Is price reclaiming or holding above an important liquidity area with enough structure, volume, trend context, and buyer pressure?

This is what makes the script different from a basic moving-average, volume, or profile-only display.
[/pine]

------------------------------------------------------------------------------------------------
## [b]7. [Optional technical explanation] Structural liquidity filter[/b]
------------------------------------------------------------------------------------------------

[pine]
The script first checks whether the symbol has acceptable structural liquidity. This helps reduce signals on thin, fragmented, or unreliable markets.

The structural liquidity data is calculated from daily data:
dClose
dOpen
dHigh
dLow
dVol

The script calculates daily dollar volume:
addvD = daily close * daily volume

Then it calculates:
addv20 = 20-period average daily dollar volume
p10Addv20 = 10th percentile of daily dollar volume over the short liquidity window

This means the script does not only check average liquidity. It also checks whether the lower-end liquidity is acceptable. A symbol can have one large-volume day and still be unreliable if many other days are weak.

The script also checks gap behavior:
gapPct = absolute difference between current daily open and prior daily close
gapHit = gap is counted when it is greater than the internal gap threshold
gapFreqPct = percentage of recent days with meaningful gaps

This helps identify symbols that move with frequent gaps instead of continuous trading behavior.

The continuity check uses the selected continuity timeframe:
contTfInput = 30, 60, 120, or 240 minutes

It checks whether volume is missing or zero on that secondary timeframe:
deadBar = continuity timeframe volume equals zero
deadBarPct = percentage of dead bars in the recent window

The script also checks stability:
cvAddv = coefficient of variation of daily dollar volume
rangeFrac = daily range divided by daily close
medRangeFrac = median range fraction

The Liquidity quality setting changes thresholds:
Strict requires higher average dollar volume, stronger lower-percentile dollar volume, fewer dead bars, fewer gaps, lower dollar-volume variation, and lower median range fraction.
Balanced uses medium thresholds and is intended for most liquid stocks and crypto.
Loose allows weaker structure and can produce more signals, but may also accept less reliable symbols.

The script creates:
structAddvOk
structP10Ok
structDeadOk
structGapOk
structCvOk
structRangeOk

The main path setup uses:
structuralQualified = structAddvOk and structP10Ok and structDeadOk

The script also calculates:
structuralRobust = structuralQualified and structGapOk and structCvOk and structRangeOk

This gives the script a liquidity-quality foundation before it evaluates the profile path signal.
[/pine]

------------------------------------------------------------------------------------------------
## [b]8. [Optional technical explanation] Liquidity profile and pivot calculation[/b]
------------------------------------------------------------------------------------------------

[pine]
The script builds a custom right-side liquidity profile from the selected lookback period.

The profile range is:
highs = highest high over the lookback
lows = lowest low over the lookback
priceRange = highs - lows

The profile is divided into a fixed number of bins:
BINS_COUNT = 120

Each bar in the lookback contributes activity to one price bin using hlc3:
p = hlc3[i]

The script adds volume to the selected bin:
v = volume[i] * weight

The weighting is enabled internally:
weightedInput = true

This means newer bars receive more weight than older bars:
w = 1.0 - i / lookbackInput

This creates a profile that still uses the full lookback but gives more importance to recent activity.

After raw bin activity is built, the script smooths the profile. It loops around each bin and averages nearby bins with distance-based weights. This reduces noise and avoids making the pivot depend too heavily on one single sharp bin.

The script finds the strongest smoothed bin:
maxVol = highest smoothed bin activity
pocIdx = index of strongest bin
pocRaw = price at the center of that bin

This raw pivot is then smoothed:
pocSmoothed = EMA of pocRaw

The final Liquidity Pivot is clamped inside the calculated value area:
pocPrice = clamp(pocSmoothed, value area low, value area high)

The value area is calculated from the POC outward:

1. Start at the POC bin.
2. Add the neighboring bin with more activity.
3. Continue expanding up or down until the selected value-area percentage is reached.

The script calculates:
vah = value area high
val = value area low

The plotted Liquidity Pivot is the final smoothed and clamped POC:
plot(pocPrice, title = "Liquidity Pivot / POC")

This profile design is useful because the pivot is not just the highest raw volume bin. It is smoothed, recent-weighted, and constrained by the internal value area.
[/pine]

------------------------------------------------------------------------------------------------
# [b]9. [Optional technical explanation] Liquidity Path signal logic[/b]
------------------------------------------------------------------------------------------------

[pine]
The Liquidity Path signal is built from several gates.

First, the script checks where price is relative to the Liquidity Pivot:
abovePocNow = close > pocPrice
belowPocNow = close < pocPrice

Then it measures distance from the pivot:
pocDistancePct = distance between close and pocPrice in percent

This is important because the script tries to avoid late entries. A price that is far above the pivot may already be extended.

The script also measures distance from the fast EMA:
emaDistancePct = distance between close and EMA 20 in percent

The path mode changes strictness:
Early allows more signals and a wider reclaim window.
Balanced uses medium behavior.
Strict requires tighter confirmation.

The script detects:
crossClosePoc = close crosses above the Liquidity Pivot
crossUnderPoc = close crosses below the Liquidity Pivot

It also detects recent reclaim behavior:
barsSinceReclaim
recentReclaim

The reclaim window changes by path mode:
Strict = shorter window
Balanced = medium window
Early = longer window

The script also allows a recent retest:
recentPocRetest

A retest means price recently touched near the Liquidity Pivot but closed back above it. This supports the idea that the pivot may be acting as an accepted liquidity reference.

The POC break-quality check requires:

* price above the pivot
* close meaningfully above the pivot
* high above the pivot

The POC slope check changes by mode:
Strict requires the pivot to be rising recently.
Balanced allows the pivot to be stable or rising over a short comparison.
Early allows a more flexible pivot condition.

The extension filters are:
nearPocPath = price is above POC but not too far above it
notExtendedPath = price is not too far from EMA 20

The trend filter checks:

* EMA 20 above EMA 50
* close above EMA 20
* EMA 20 not falling

This filter can be disabled by the user.

The volume confirmation checks:

* relative volume is not na
* relative volume is above the user threshold
* current volume is above volume moving average

The buyer-pressure confirmation checks:

* bullish candle
* close location value is above the bullish threshold
* delta is improving, or recent buy-share estimate is strong, or price closed above the prior high

The final setup requires:
liquidityPathSetup =
structuralQualified
and price above POC
and POC break quality
and price near POC
and price not extended
and recent reclaim, recent retest, or current reclaim

The final raw path signal requires:
liquidityPathSetup
and trendPathOk
and volumePathOk
and pressurePathOk
and path-mode slope condition

The final signal also uses a cooldown:
pathCooldownBars depends on Early, Balanced, or Strict mode
pathSignal = pathSignalRaw and pathCooldownOk

This makes the signal more selective than a simple POC cross. It must pass liquidity quality, pivot location, extension control, trend context, participation, buyer pressure, and cooldown logic.
[/pine]

------------------------------------------------------------------------------------------------
## [b]10. [Optional technical explanation] Inputs, visuals, alerts, and publication notes[/b]
------------------------------------------------------------------------------------------------

[pine]
The script includes user inputs grouped into four sections.

Core inputs:

1. Liquidity quality
   Controls the structural liquidity filter.
   Strict = cleaner but fewer symbols and signals.
   Balanced = recommended default.
   Loose = more permissive.

2. Continuity timeframe
   Secondary timeframe used to check whether trading activity is continuous or fragmented.

3. Use trend filter
   When enabled, path signals prefer EMA 20 above EMA 50, close above EMA 20, and non-falling EMA 20.

Liquidity Profile inputs:
4. Profile lookback
Number of bars used to build the blue profile and calculate the Liquidity Pivot.

5. Value area %
   Percent of profile activity used to define the value area.

6. Show blue liquidity profile
   Displays the right-side profile.

7. Show pivot label
   Displays the right-side label for the Liquidity Pivot.

8. Show lookback zone
   Highlights the exact chart area used to build the profile.

Liquidity Path inputs:
9. Path signal mode
Early, Balanced, or Strict.

10. Max distance above POC %
    Prevents late signals when price is already too far above the pivot.

11. Min RVOL confirmation
    Minimum relative volume required for participation confirmation.

Visual inputs:
12. Show EMA lines
Displays EMA 20 and EMA 50.

13. Show PATH labels
    This input exists in the current script, but the uploaded version does not show a plotted path label command. If a visible label is intended, a plotshape() or label.new() condition should be added for pathSignal.

14. Show subtle bias background
    Optional green or red background based on price above or below the Liquidity Pivot.

15. Pivot name
    Custom name shown beside the pivot label.

Visual drawing:
The right-side profile is drawn using boxes. Each box represents one price bin. Wider boxes mean more normalized activity at that price area.

The lookback zone is drawn with a box covering:

* selected lookback bars
* highest high and lowest low of that lookback

The pivot label is drawn on the right side at the current Liquidity Pivot price.

Alerts:
The script includes three alert conditions:

1. Liquidity Path Signal
   Triggered when price reclaimed or held above the POC with liquidity, volume, and buyer-pressure confirmation.

2. POC Reclaim
   Triggered when price crosses above the Liquidity Pivot.

3. POC Lost
   Triggered when price crosses below the Liquidity Pivot.

Important distinction:

* POC Reclaim is a simple pivot-cross event.
* POC Lost is a simple pivot-loss event.
* Liquidity Path Signal is more selective because it requires structural liquidity, pivot position, extension control, trend context, relative volume, buyer pressure, and cooldown logic.

Publication note:
This description explains how the combined parts work together so users do not need to read Pine code to understand the tool. It also clarifies that the script is a liquidity and participation review indicator, not an automated trading strategy.
[/pine]

[quote]Open-source transparency note: if any external open-source code, function, or logic was reused, the original author and source should be credited clearly in the publication.[/quote]

## Source Code

````pine
//@version=6
indicator("ID009 Liquidity Path [ReconHK] ", "Liquidity Path", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

//==================================================================================================
// COLORS
//==================================================================================================
color C_BULL         = #16C784
color C_BEAR         = #EA3943
color C_NEUTRAL      = #F0B90B
color C_POC          = #FF9F1A
color C_PROFILE_BLUE = #3B82F6
color C_LOOKBACK     = #3B82F6
color C_TEXT_DIM     = #A9B4C5

//==================================================================================================
// GROUPS
//==================================================================================================
string G_MAIN    = "1. Core"
string G_PROFILE = "2. Liquidity Profile"
string G_PATH    = "3. Liquidity Path"
string G_VIS     = "4. Visuals"

//==================================================================================================
// GUI INPUTS — CLEAN PUBLISH VERSION
//==================================================================================================
liqModeInput = input.string(
     "Balanced",
     "Liquidity quality",
     options = ["Strict", "Balanced", "Loose"],
     group = G_MAIN,
     tooltip = "Controls how strict the structural liquidity filter is. Balanced is recommended for most liquid stocks and crypto."
)

contTfInput = input.string(
     "60",
     "Continuity timeframe",
     options = ["30", "60", "120", "240"],
     group = G_MAIN,
     tooltip = "Secondary timeframe used to check whether trading activity is continuous or fragmented."
)

useTrendFilterInput = input.bool(
     true,
     "Use trend filter",
     group = G_MAIN,
     tooltip = "When enabled, bullish path signals prefer EMA trend alignment."
)

lookbackInput = input.int(
     300,
     "Profile lookback",
     minval = 80,
     maxval = 800,
     group = G_PROFILE,
     tooltip = "Number of bars used to build the blue liquidity profile and calculate the Liquidity Pivot / POC."
)

vaPercentInput = input.float(
     70.0,
     "Value area %",
     minval = 50,
     maxval = 95,
     step = 5,
     group = G_PROFILE,
     tooltip = "Percent of profile activity used to define the internal value area. 70% is the standard default."
)

showProfileInput = input.bool(
     true,
     "Show blue liquidity profile",
     group = G_PROFILE,
     tooltip = "Displays the right-side blue liquidity profile. Thicker bars mean more traded activity at that price area."
)

showPivotLabelInput = input.bool(
     true,
     "Show pivot label",
     group = G_PROFILE,
     tooltip = "Shows the right-side label for the orange Liquidity Pivot / POC line."
)

showLookbackZoneInput = input.bool(
     true,
     "Show lookback zone",
     group = G_PROFILE,
     tooltip = "Highlights the exact chart area used to build the liquidity profile: the selected lookback bars and their high-low price range."
)

pathModeInput = input.string(
     "Balanced",
     "Path signal mode",
     options = ["Early", "Balanced", "Strict"],
     group = G_PATH,
     tooltip = "Controls how strict the liquidity-path entry signal is. Early gives more signals, Strict gives fewer signals."
)

maxPocDistanceInput = input.float(
     2.5,
     "Max distance above POC %",
     minval = 0.5,
     maxval = 8.0,
     step = 0.1,
     group = G_PATH,
     tooltip = "Prevents late entries that are already too far above the Liquidity Pivot / POC."
)

rvolConfirmInput = input.float(
     1.15,
     "Min RVOL confirmation",
     minval = 0.5,
     maxval = 5.0,
     step = 0.05,
     group = G_PATH,
     tooltip = "Minimum relative volume used to confirm participation behind the POC reclaim."
)

showEmaLinesInput = input.bool(
     true,
     "Show EMA lines",
     group = G_VIS,
     tooltip = "Displays EMA 20 and EMA 50 used for trend context."
)

showPathLabelsInput = input.bool(
     true,
     "Show PATH labels",
     group = G_VIS,
     tooltip = "Displays the green PATH label when price reclaims or holds above the Liquidity Pivot with confirmation."
)

showBiasBackgroundInput = input.bool(
     false,
     "Show subtle bias background",
     group = G_VIS,
     tooltip = "Optional subtle background: green above POC, red below POC. Off by default to keep the chart clean."
)

pivotNameInput = input.string(
     "Liquidity Pivot",
     "Pivot name",
     group = G_VIS,
     tooltip = "Custom label name shown next to the POC line."
)

//==================================================================================================
// HARD-CODED INTERNAL SETTINGS
//==================================================================================================
string dailyTFInput   = "D"

int addvLenInput      = 20
int longLenInput      = 63
int gapLookbackInput  = 20
int deadBarWinInput   = 12

int rvolLenInput      = 20
int deltaEmaLenInput  = 5
int emaFastLenInput   = 20
int emaSlowLenInput   = 50

float clvBullInput    = 0.58
float clvBearInput    = 0.42

bool weightedInput    = true
int smoothInput       = 5
int pocSmoothLen      = 5
int BINS_COUNT        = 120

int shadowOffsetBars  = 38
int shadowWidthBars   = 26
float shadowMinNorm   = 0.03

int pathCooldownEarly = 6
int pathCooldownBalanced = 10
int pathCooldownStrict = 14

//==================================================================================================
// HELPERS
//==================================================================================================
f_safeDiv(float a, float b) =>
    na(a) or na(b) or b == 0.0 ? na : a / b

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_clv(float c, float h, float l) =>
    float rng = h - l
    rng == 0.0 ? 0.5 : f_clamp((c - l) / rng, 0.0, 1.0)

f_shadowColor(float normVol) =>
    int alpha =
         normVol >= 0.75 ? 18 :
         normVol >= 0.50 ? 35 :
         normVol >= 0.25 ? 55 :
         78
    color.new(C_PROFILE_BLUE, alpha)

//==================================================================================================
// STRUCTURAL LIQUIDITY DATA
//==================================================================================================
dClose = request.security(syminfo.tickerid, dailyTFInput, close)
dOpen  = request.security(syminfo.tickerid, dailyTFInput, open)
dHigh  = request.security(syminfo.tickerid, dailyTFInput, high)
dLow   = request.security(syminfo.tickerid, dailyTFInput, low)
dVol   = request.security(syminfo.tickerid, dailyTFInput, volume)

addvD        = dClose * dVol
addv20       = ta.sma(addvD, addvLenInput)
p10Addv20    = ta.percentile_linear_interpolation(addvD, addvLenInput, 10.0)

gapPct       = math.abs(dOpen - nz(dClose[1])) / math.max(nz(dClose[1]), syminfo.mintick)
gapHit       = gapPct > 0.015 ? 1.0 : 0.0
gapFreqPct   = 100.0 * f_safeDiv(math.sum(gapHit, gapLookbackInput), gapLookbackInput)

contVol      = request.security(syminfo.tickerid, contTfInput, volume)
deadBar      = contVol == 0.0 ? 1.0 : 0.0
deadBarPct   = 100.0 * f_safeDiv(math.sum(deadBar, deadBarWinInput), deadBarWinInput)

cvAddv       = f_safeDiv(ta.stdev(addvD, longLenInput), ta.sma(addvD, longLenInput))
rangeFrac    = (dHigh - dLow) / math.max(dClose, syminfo.mintick)
medRangeFrac = ta.median(rangeFrac, addvLenInput)

//==================================================================================================
// STRUCTURAL THRESHOLDS
//==================================================================================================
float minAddv20  = na
float minP10     = na
float maxDeadPct = na
float maxGapPct  = na
float maxCvAddv  = na
float maxMedRng  = na

if liqModeInput == "Strict"
    minAddv20  := 50e6
    minP10     := 20e6
    maxDeadPct := 1.0
    maxGapPct  := 12.0
    maxCvAddv  := 1.10
    maxMedRng  := 0.08
else if liqModeInput == "Balanced"
    minAddv20  := 20e6
    minP10     := 8e6
    maxDeadPct := 3.0
    maxGapPct  := 18.0
    maxCvAddv  := 1.40
    maxMedRng  := 0.11
else
    minAddv20  := 8e6
    minP10     := 3e6
    maxDeadPct := 6.0
    maxGapPct  := 25.0
    maxCvAddv  := 1.80
    maxMedRng  := 0.15

structAddvOk        = not na(addv20) and addv20 >= minAddv20
structP10Ok         = not na(p10Addv20) and p10Addv20 >= minP10
structDeadOk        = not na(deadBarPct) and deadBarPct <= maxDeadPct
structGapOk         = not na(gapFreqPct) and gapFreqPct <= maxGapPct
structCvOk          = na(cvAddv) or cvAddv <= maxCvAddv
structRangeOk       = not na(medRangeFrac) and medRangeFrac <= maxMedRng

structuralQualified = structAddvOk and structP10Ok and structDeadOk
structuralRobust    = structuralQualified and structGapOk and structCvOk and structRangeOk

//==================================================================================================
// PARTICIPATION / TREND / FLOW
//==================================================================================================
volMa20      = ta.sma(volume, rvolLenInput)
rvol         = f_safeDiv(volume, volMa20)
volTrendUp   = ta.ema(volume, 5) > ta.ema(volume, 20)

rawDelta     = close > open ? volume : close < open ? -volume : 0.0
smoothDelta  = ta.ema(rawDelta, deltaEmaLenInput)
deltaBase    = ta.ema(smoothDelta, 5)
deltaUp      = smoothDelta > deltaBase
deltaDn      = smoothDelta < deltaBase

clv          = f_clv(close, high, low)
buyShareBar  = clv
sellShareBar = 1.0 - clv
buyShare5    = ta.sma(buyShareBar, 5)
sellShare5   = ta.sma(sellShareBar, 5)

emaFast      = ta.ema(close, emaFastLenInput)
emaSlow      = ta.ema(close, emaSlowLenInput)

trendBull    = emaFast > emaSlow
trendBear    = emaFast < emaSlow

plot(showEmaLinesInput ? emaFast : na, title = "EMA Fast 20", color = color.new(C_BULL, 65), linewidth = 1)
plot(showEmaLinesInput ? emaSlow : na, title = "EMA Slow 50", color = color.new(C_BEAR, 65), linewidth = 1)

//==================================================================================================
// PROFILE / LIQUIDITY MAP
//==================================================================================================
highs      = ta.highest(high, lookbackInput)
lows       = ta.lowest(low, lookbackInput)
priceRange = highs - lows
binStep    = priceRange > 0.0 ? priceRange / BINS_COUNT : syminfo.mintick

var float[] rawBins    = array.new_float(BINS_COUNT, 0.0)
var float[] smoothBins = array.new_float(BINS_COUNT, 0.0)

float pocRaw   = na
float pocPrice = na
float vah      = na
float val      = na

hasProfileData = bar_index >= lookbackInput - 1 and priceRange > 0.0

if hasProfileData
    array.fill(rawBins, 0.0)
    array.fill(smoothBins, 0.0)

    for i = 0 to lookbackInput - 1
        float w = weightedInput ? 1.0 - float(i) / float(lookbackInput) : 1.0
        float p = hlc3[i]
        float v = nz(volume[i]) * w
        int idx = math.min(BINS_COUNT - 1, math.max(0, int((p - lows) / binStep)))
        array.set(rawBins, idx, array.get(rawBins, idx) + v)

    for k = 0 to BINS_COUNT - 1
        float sumVol = 0.0
        float wsum = 0.0

        for s = -smoothInput to smoothInput
            int x = k + s
            if x >= 0 and x < BINS_COUNT
                float sw = 1.0 / (1.0 + math.abs(s))
                sumVol += array.get(rawBins, x) * sw
                wsum += sw

        array.set(smoothBins, k, wsum > 0.0 ? sumVol / wsum : 0.0)

    float maxVol = array.max(smoothBins)
    float totalSmoothVol = array.sum(smoothBins)

    if totalSmoothVol > 0.0 and maxVol > 0.0
        int pocIdx = array.indexof(smoothBins, maxVol)
        pocRaw := lows + pocIdx * binStep + binStep / 2.0

        float vaTarget = totalSmoothVol * (vaPercentInput / 100.0)
        float vaAccum = array.get(smoothBins, pocIdx)

        int upIdx = pocIdx
        int dnIdx = pocIdx

        while vaAccum < vaTarget and (upIdx < BINS_COUNT - 1 or dnIdx > 0)
            float upVol = upIdx < BINS_COUNT - 1 ? array.get(smoothBins, upIdx + 1) : 0.0
            float dnVol = dnIdx > 0 ? array.get(smoothBins, dnIdx - 1) : 0.0

            if upVol >= dnVol and upIdx < BINS_COUNT - 1
                upIdx += 1
                vaAccum += upVol
            else if dnIdx > 0
                dnIdx -= 1
                vaAccum += dnVol
            else
                break

        vah := lows + (upIdx + 1) * binStep
        val := lows + dnIdx * binStep

//==================================================================================================
// SMOOTHED CONTINUOUS POC
//==================================================================================================
pocSmoothed = ta.ema(pocRaw, pocSmoothLen)
pocPrice := hasProfileData and not na(pocSmoothed) and not na(val) and not na(vah) ? f_clamp(pocSmoothed, val, vah) : na

plot(pocPrice, title = "Liquidity Pivot / POC", color = color.new(C_POC, 0), linewidth = 3)

//==================================================================================================
// LIQUIDITY PATH LOGIC
//==================================================================================================
abovePocNow = not na(pocPrice) and close > pocPrice
belowPocNow = not na(pocPrice) and close < pocPrice

pocDistancePct = not na(pocPrice) and pocPrice != 0.0 ? math.abs(close - pocPrice) / pocPrice * 100.0 : na
emaDistancePct = emaFast != 0.0 ? math.abs(close - emaFast) / emaFast * 100.0 : na

crossClosePoc = ta.crossover(close, pocPrice)
crossUnderPoc = ta.crossunder(close, pocPrice)

barsSinceReclaim = ta.barssince(crossClosePoc)
int reclaimWindowBars = pathModeInput == "Strict" ? 2 : pathModeInput == "Early" ? 5 : 3
recentReclaim = not na(barsSinceReclaim) and barsSinceReclaim <= reclaimWindowBars

recentPocRetest =
     not na(pocPrice) and
     ta.lowest(low, 3) <= pocPrice * 1.004 and
     ta.lowest(low, 3) >= pocPrice * 0.975 and
     close > pocPrice

pocBreakQuality =
     abovePocNow and
     close > pocPrice + syminfo.mintick and
     high > pocPrice

pocSlopeOk =
     pathModeInput == "Strict" ? not na(pocPrice[2]) and pocPrice > pocPrice[1] and pocPrice[1] >= pocPrice[2] :
     pathModeInput == "Early" ? not na(pocPrice[1]) and pocPrice >= pocPrice[1] :
     not na(pocPrice[2]) and pocPrice >= pocPrice[2]

maxEmaDistance = pathModeInput == "Strict" ? 1.25 : pathModeInput == "Early" ? 3.00 : 2.00
nearPocPath = abovePocNow and not na(pocDistancePct) and pocDistancePct <= maxPocDistanceInput
notExtendedPath = not na(emaDistancePct) and emaDistancePct <= maxEmaDistance

trendPathOk =
     not useTrendFilterInput or
     (
         emaFast > emaSlow and
         close > emaFast and
         emaFast >= emaFast[1]
     )

volumePathOk =
     not na(rvol) and
     rvol >= rvolConfirmInput and
     volume >= volMa20

pressurePathOk =
     close > open and
     clv >= clvBullInput and
     (
         deltaUp or
         buyShare5 >= 0.55 or
         close > high[1]
     )

liquidityPathSetup =
     structuralQualified and
     abovePocNow and
     pocBreakQuality and
     nearPocPath and
     notExtendedPath and
     (
         recentReclaim or
         recentPocRetest or
         crossClosePoc
     )

pathSignalRaw =
     liquidityPathSetup and
     trendPathOk and
     volumePathOk and
     pressurePathOk and
     (
         pathModeInput == "Early" or pocSlopeOk
     )

int pathCooldownBars = pathModeInput == "Strict" ? pathCooldownStrict : pathModeInput == "Early" ? pathCooldownEarly : pathCooldownBalanced
var int lastPathBar = na
pathCooldownOk = na(lastPathBar) or bar_index - lastPathBar > pathCooldownBars

pathSignal = pathSignalRaw and pathCooldownOk

if pathSignal
    lastPathBar := bar_index

//==================================================================================================
// OPTIONAL BIAS BACKGROUND
//==================================================================================================
biasBg = abovePocNow ? color.new(C_BULL, 65) : belowPocNow ? color.new(C_BEAR, 65) : na
bgcolor(showBiasBackgroundInput ? biasBg : na, title = "POC Bias Background")


//==================================================================================================
// DRAW ONLY: BLUE PROFILE + PIVOT LABEL
//==================================================================================================
var box[] shadowBoxes = array.new<box>()
var box lookbackZoneBox = na
var label pocLbl = na

profileReady = not na(pocPrice)

if barstate.islast and profileReady
    for b in shadowBoxes
        box.delete(b)
    array.clear(shadowBoxes)

    box.delete(lookbackZoneBox)
    label.delete(pocLbl)

    int xRight = bar_index + shadowOffsetBars 
    int xLabel = xRight + shadowWidthBars + 3

    if showLookbackZoneInput
        lookbackZoneBox := box.new(bar_index - lookbackInput + 1, highs, bar_index, lows, border_color = color.new(C_LOOKBACK, 78), bgcolor = color.new(C_LOOKBACK, 82))

    float maxVol = array.max(smoothBins)

    if showProfileInput and maxVol > 0.0
        for k = 0 to BINS_COUNT - 1
            float volHere = array.get(smoothBins, k)
            float norm = volHere / maxVol

            if norm >= shadowMinNorm
                float y1 = lows + k * binStep
                float y2 = y1 + binStep
                int wBars = math.max(1, int(math.round(norm * shadowWidthBars)))
                int xLeft = xRight - wBars
                color baseCol = f_shadowColor(norm)
                array.push(shadowBoxes, box.new(xLeft, y2, xRight, y1, border_color = na, bgcolor = baseCol))

    if showPivotLabelInput
        pocLbl := label.new(xLabel, pocPrice, pivotNameInput + "  " + str.tostring(pocPrice, format.mintick), style = label.style_label_left, color = C_POC, textcolor = color.white, size = size.small)

//==================================================================================================
// ALERTS
//==================================================================================================
alertcondition(pathSignal, "Liquidity Path Signal", "Liquidity Path: price reclaimed/held above the POC with liquidity, volume, and buyer-pressure confirmation on {{ticker}}")
alertcondition(crossClosePoc, "POC Reclaim", "Price reclaimed the Liquidity Pivot / POC on {{ticker}}")
alertcondition(crossUnderPoc, "POC Lost", "Price lost the Liquidity Pivot / POC on {{ticker}}")
````
