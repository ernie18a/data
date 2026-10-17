# VWAP Deviation Trend [BackQuant]

- url: https://www.tradingview.com/script/aP7Yf1gT-VWAP-Deviation-Trend-BackQuant/
- type: indicator
- pine_id: PUB;a478a7d095f94d3bad6f433c3a667a2f
- version: 1.0

## Description

[b]VWAP Deviation Trend [BackQuant][/b]

[b]Overview[/b]  
VWAP Deviation Trend is a volume-weighted trend-following overlay that transforms VWAP and its surrounding price distribution into a directional trailing structure.

Rather than using VWAP only as a fair-value line, the indicator calculates:
[list]
[*]A configurable anchored or rolling VWAP.
[*]The volume-weighted standard deviation of price around that VWAP.
[*]Adaptive upper and lower deviation bands.
[*]One-sided trailing boundaries used to confirm bullish and bearish regimes.
[/list]

The indicator is designed to identify when price has moved far enough away from accepted volume-weighted value to establish a meaningful directional shift.

Unlike a simple VWAP crossover, price can move through VWAP without immediately changing the active trend. A new regime requires price to break the opposite trailing deviation boundary, optionally with confirmation from the direction of VWAP itself.

The updated visual engine also measures trend strength and uses it to control:
[list]
[*]Gradient intensity.
[*]Trail glow width.
[*]Post-flip bloom effects.
[*]The visual separation between price and the active trail.
[/list]

[b]Core concept[/b]  
VWAP represents the average price paid over a selected period, weighted by trading volume.

The basic formula is:

[list]
[*]VWAP = Sum of Price × Volume / Sum of Volume
[/list]

Prices associated with greater volume contribute more heavily to the final value. This makes VWAP a useful approximation of:
[list]
[*]Volume-weighted fair value.
[*]The center of traded activity.
[*]The average position of market participants.
[*]An institutional execution benchmark.
[/list]

However, VWAP alone does not explain how widely price has been distributed around that value.

VWAP Deviation Trend treats VWAP as the center of a volume-weighted price distribution and measures the dispersion around it. That dispersion is then used to create trailing trend boundaries.

[b]VWAP calculation modes[/b]  
The indicator supports five VWAP windows:
[list]
[*]4 Hours
[*]Daily
[*]Weekly
[*]Rolling Lookback Bars
[*]Rolling Lookback Days
[/list]

[b]4 Hours[/b]  
Resets VWAP at fixed four-hour intervals.

This can be useful for:
[list]
[*]Cryptocurrency markets.
[*]Intraday futures.
[*]Continuously traded markets.
[*]Shorter fair-value regimes.
[/list]

[b]Daily[/b]  
Resets at the beginning of each calendar day.

This is the traditional intraday VWAP structure and is useful for:
[list]
[*]Session bias.
[*]Intraday mean reversion.
[*]Day-trading trend confirmation.
[/list]

[b]Weekly[/b]  
Accumulates volume and price across the current week.

This creates a slower structural anchor suited to:
[list]
[*]Swing trading.
[*]Weekly positioning.
[*]Broader accepted-value analysis.
[/list]

[b]Rolling Lookback Bars[/b]  
Calculates VWAP over a fixed number of candles.

The window moves forward continuously and does not reset at a calendar boundary.

This is useful for:
[list]
[*]Systematic trend models.
[*]Consistent multi-timeframe analysis.
[*]Markets where daily sessions are less important.
[/list]

[b]Rolling Lookback Days[/b]  
Includes bars that fall within a selected number of calendar days.

This keeps the analytical window tied to elapsed time instead of a fixed candle count.

[b]Anchored versus rolling VWAP[/b]  
Anchored modes begin at a fixed boundary and accumulate until the next reset.

Rolling modes continually remove old observations as new observations arrive.

Anchored VWAP is useful when a particular session or week has structural meaning. Rolling VWAP is useful when the trader wants a stable and continuously adapting lookback.

[b]Volume-weighted deviation[/b]  
The indicator calculates more than the VWAP mean.

It also measures volume-weighted price variance using:

[list]
[*]Weighted Mean Square = Sum of Price² × Volume / Sum of Volume
[*]Weighted Variance = Weighted Mean Square - VWAP²
[*]Weighted Deviation = Square Root of Weighted Variance
[/list]

This measures how widely prices associated with meaningful trading volume are distributed around VWAP.

A small deviation suggests:
[list]
[*]Trading is concentrated near fair value.
[*]The market is relatively balanced.
[*]Price acceptance is narrow.
[/list]

A large deviation suggests:
[list]
[*]Trading is spread across a wider range.
[*]Price discovery is more active.
[*]The market is less tightly centered around VWAP.
[/list]

Because the calculation is volume weighted, high-volume prices influence the bands more than low-volume excursions.

[b]Fallback when volume is unavailable[/b]  
If usable volume is not available, the indicator falls back to an unweighted arithmetic mean and variance.

This allows it to function on synthetic or limited-volume symbols, although the result should then be interpreted as a rolling or anchored mean rather than a true VWAP.

[b]Deviation bands[/b]  
The raw width is calculated as:

[list]
[*]Deviation Width = Weighted Deviation × Deviation Multiplier
[/list]

The upper and lower raw bands are:

[list]
[*]Upper Band = VWAP + Band Width
[*]Lower Band = VWAP - Band Width
[/list]

Higher deviation multipliers create wider bands and fewer trend changes.

Lower multipliers create tighter bands and faster, more frequent flips.

[b]ATR minimum width[/b]  
During low-dispersion periods, volume-weighted deviation can become extremely narrow.

This can cause small and insignificant movements to trigger repeated reversals.

The optional ATR floor calculates:

[list]
[*]ATR Floor = ATR × ATR Minimum Multiplier
[/list]

The final width becomes:

[list]
[*]Band Width = Maximum of Deviation Width and ATR Floor
[/list]

This preserves volume-weighted deviation as the primary band engine while preventing the channel from collapsing below a practical volatility threshold.

[b]Trailing-band construction[/b]  
The raw deviation bands move freely with VWAP and dispersion.

The indicator converts them into one-sided trailing levels.

[b]Lower trail[/b]  
While the selected trigger remains above the lower trail:
[list]
[*]The trail can rise.
[*]It cannot move downward.
[/list]

This creates a ratcheting support structure.

[b]Upper trail[/b]  
While the trigger remains below the upper trail:
[list]
[*]The trail can fall.
[*]It cannot move upward.
[/list]

This creates a ratcheting resistance structure.

The active trend trail is:
[list]
[*]The lower trail during bullish regimes.
[*]The upper trail during bearish regimes.
[/list]

[b]Why trailing logic matters[/b]  
A raw VWAP band can move toward price and create unstable signals.

The one-sided trail preserves trend structure and creates hysteresis.

Hysteresis means the threshold required to enter a bullish regime is different from the threshold required to enter a bearish regime.

This allows price to rotate around VWAP without constantly changing the active trend.

[b]Trend initialization[/b]  
When the first valid VWAP is available:
[list]
[*]The trend initializes bullish if the trigger is at or above VWAP.
[*]The trend initializes bearish if the trigger is below VWAP.
[/list]

After initialization, a full break of the opposite trail is required to change regimes.

[b]Bullish trend flip[/b]  
A bullish flip requires:
[list]
[*]The selected trigger to move above the upper trailing band.
[*]The current trend not already to be bullish.
[*]VWAP slope confirmation to pass if enabled.
[/list]

Once confirmed:
[list]
[*]The trend becomes bullish.
[*]The active trail moves beneath the market.
[*]A bullish signal marker is displayed.
[/list]

[b]Bearish trend flip[/b]  
A bearish flip requires:
[list]
[*]The selected trigger to move below the lower trailing band.
[*]The current trend not already to be bearish.
[*]VWAP slope confirmation to pass if enabled.
[/list]

Once confirmed:
[list]
[*]The trend becomes bearish.
[*]The active trail moves above the market.
[*]A bearish signal marker is displayed.
[/list]

[b]Flip trigger[/b]  
The trend can be triggered using:
[list]
[*]Close
[*]The selected VWAP price source
[/list]

Close is the more conventional option.

Using the price source, such as HLC3, can produce a slightly smoother trigger because it reflects more of the bar than the close alone.

[b]VWAP slope confirmation[/b]  
Optional slope confirmation requires VWAP itself to move in the direction of the proposed new trend.

For a bullish flip:
[list]
[*]Current VWAP must be above VWAP from the selected lookback.
[/list]

For a bearish flip:
[list]
[*]Current VWAP must be below its prior value.
[/list]

This can help reject:
[list]
[*]Temporary band breaks.
[*]Low-volume price spikes.
[*]Liquidity sweeps against flat fair value.
[/list]

The tradeoff is additional confirmation delay.

[b]Breaking the trail on flips[/b]  
The active trail changes from one side of the market to the other during a regime transition.

The Break Trail On Flips option inserts a visual gap on the flip bar so the previous and new trails are not connected by a misleading line segment.

This affects presentation only.

[b]Visual trend-strength engine[/b]  
The updated script includes a visual-strength model that controls the intensity of the gradient and glow.

It combines two measurements:
[list]
[*]Distance between price and the active trail.
[*]Slope of VWAP relative to the current band width.
[/list]

[b]Distance strength[/b]  
The script measures:

[list]
[*]Absolute Distance = |Close - Trend Trail|
[/list]

This is normalized by the current band width.

A larger distance indicates stronger separation between price and the structural trail.

[b]Slope strength[/b]  
VWAP movement across the slope lookback is also normalized by the band width.

This measures whether volume-weighted fair value itself is moving meaningfully relative to the size of the current deviation structure.

[b]Combined trend strength[/b]  
The final visual strength is weighted:
[list]
[*]70% price-to-trail distance.
[*]30% VWAP slope strength.
[/list]

This produces a value between zero and one.

It does not change trend logic or signals. It controls the visual intensity of the indicator.

[b]Layered gradient fill[/b]  
Instead of using one flat gradient, the updated indicator divides the space between the trail and price into six visual layers.

The levels are placed progressively between:
[list]
[*]The active trend trail.
[*]The current closing price.
[/list]

The gradient is:
[list]
[*]Most concentrated near the structural trail.
[*]Progressively softer toward price.
[/list]

The opacity adapts to trend strength.

When price is strongly separated from the trail and VWAP is moving with the regime:
[list]
[*]The gradient becomes more vivid.
[/list]

When the trend is weak:
[list]
[*]The fill becomes softer and more transparent.
[/list]

This makes the visual ribbon encode more than direction. It also reflects the current strength of the price-to-structure relationship.

[b]Flip bloom[/b]  
After a confirmed trend flip, the indicator creates a temporary bloom around the new trail.

The bloom is strongest immediately after the transition and fades over the following bars.

Its intensity follows this general sequence:
[list]
[*]First bar after flip: strongest bloom.
[*]Second bar: reduced bloom.
[*]Third bar: light residual bloom.
[*]Afterward: bloom disappears.
[/list]

This visually emphasizes fresh regime changes without permanently increasing chart brightness.

The bloom is cosmetic and does not affect calculation.

[b]Adaptive trail glow[/b]  
The glow surrounding the trail also changes with trend strength.

The base width is ATR-scaled, then increases slightly as the visual trend-strength score rises.

This creates:
[list]
[*]A broader glow during stronger regimes.
[*]A narrower glow when trend structure is weaker.
[/list]

The glow contains:
[list]
[*]An inner, more visible layer.
[*]A wider, softer outer layer.
[/list]

[b]Visual interpretation[/b]  
The updated presentation provides several pieces of information simultaneously:

[list]
[*]Color shows the active trend direction.
[*]The trail shows the structural regime boundary.
[*]Gradient intensity reflects trend strength.
[*]Glow width reinforces structural conviction.
[*]The bloom highlights fresh regime transitions.
[/list]

[b]How to use the indicator[/b]

[b]Trend regime filter[/b]  
Use the active color and trail position as directional context:
[list]
[*]Favor longs during bullish regimes.
[*]Favor shorts during bearish regimes.
[/list]

[b]Pullback structure[/b]  
In a bullish regime:
[list]
[*]VWAP represents volume-weighted fair value.
[*]The lower trail represents deeper structural support.
[/list]

In a bearish regime:
[list]
[*]VWAP represents the mean-reversion anchor.
[*]The upper trail represents deeper structural resistance.
[/list]

[b]Trend-strength context[/b]  
A vivid gradient and broader glow suggest:
[list]
[*]Price is well separated from the trail.
[*]VWAP is moving in the trend direction.
[*]The regime has stronger structural momentum.
[/list]

A weak or faded gradient suggests:
[list]
[*]Price is closer to the trail.
[*]VWAP slope is weaker.
[*]The trend may be consolidating or losing strength.
[/list]

[b]Fresh transitions[/b]  
The bloom helps identify newly established regimes.

A fresh flip with:
[list]
[*]Strong bloom.
[*]Growing price separation.
[*]VWAP slope alignment.
[/list]

generally represents stronger early trend structure than a flip that immediately loses visual intensity.

[b]Dynamic risk management[/b]  
The active trail may be used as:
[list]
[*]A trailing stop reference.
[*]A regime invalidation boundary.
[*]A position-management guide.
[/list]

Because the trail responds to both volume-weighted dispersion and volatility, it adjusts as market conditions change.

[b]How this differs from a standard VWAP[/b]  
A standard VWAP:
[list]
[*]Plots only volume-weighted mean price.
[*]Usually resets once per session.
[*]Does not maintain trend state.
[/list]

VWAP Deviation Trend:
[list]
[*]Supports anchored and rolling windows.
[*]Calculates volume-weighted dispersion.
[*]Creates adaptive raw bands.
[*]Converts them into directional trailing boundaries.
[*]Maintains persistent bullish and bearish regimes.
[*]Adds a strength-reactive visual system.
[/list]

[b]How this differs from Supertrend[/b]  
A traditional Supertrend normally uses a central price such as HL2 and ATR-based bands.

VWAP Deviation Trend uses:
[list]
[*]Volume-weighted fair value as the center.
[*]Volume-weighted standard deviation as the primary width.
[*]ATR only as an optional minimum floor.
[/list]

This means the trail responds not only to range volatility, but also to where trading volume has been concentrated.

[b]How this differs from Bollinger Bands[/b]  
Bollinger Bands normally use:
[list]
[*]A moving average.
[*]Unweighted standard deviation.
[*]Symmetrical non-trailing bands.
[/list]

This indicator uses:
[list]
[*]A volume-weighted mean.
[*]Volume-weighted variance.
[*]One-sided trailing bands.
[*]Persistent trend-state logic.
[/list]

It is therefore a trend-regime model rather than a standard mean-reversion envelope.

[b]Input guide[/b]

[b]VWAP Mode[/b]  
Selects the anchored or rolling calculation window.

[b]Deviation Multiplier[/b]  
Controls the width of the statistical bands.

Higher values produce wider, slower regimes. Lower values produce tighter and faster regimes.

[b]ATR Minimum Width[/b]  
Prevents excessive narrowing during compressed conditions.

[b]VWAP Slope Confirmation[/b]  
Requires volume-weighted fair value to move with the proposed trend.

[b]Flip Trigger[/b]  
Selects whether close or the chosen price source must cross the trail.

[b]Visual settings[/b]  
Allow the trader to display:
[list]
[*]The trend trail.
[*]VWAP.
[*]Raw deviation bands.
[*]Layered gradient.
[*]Adaptive glow.
[*]Signals.
[*]Trend candles.
[/list]

[b]Strengths[/b]  
[list]
[*]Combines fair value, dispersion, and trend structure.
[*]Uses volume-weighted mean and variance.
[*]Supports multiple anchored and rolling VWAP windows.
[*]Uses ATR protection against narrow-band whipsaws.
[*]Creates persistent regimes with hysteresis.
[*]Provides optional VWAP slope confirmation.
[*]Includes a trend-strength-reactive visual system.
[*]Clearly emphasizes fresh trend transitions.
[/list]

[b]Limitations[/b]  
[list]
[*]Volume quality varies between instruments.
[*]Anchored VWAP modes may be unstable immediately after a reset.
[*]Long windows can react slowly to sudden regime changes.
[*]Tight settings can increase whipsaws.
[*]Wide settings can delay reversals.
[*]Slope confirmation can add additional lag.
[*]Visual strength is contextual and is not a separate trading signal.
[/list]

[b]Alerts[/b]  
The indicator includes alerts for:
[list]
[*]Confirmed bullish trend flips.
[*]Confirmed bearish trend flips.
[/list]

These represent complete VWAP deviation regime changes, not ordinary crosses of VWAP.

[b]Summary[/b]  
VWAP Deviation Trend converts volume-weighted fair value and price dispersion into a directional trend trail.

It calculates VWAP over a configurable anchored or rolling window, measures volume-weighted standard deviation around that VWAP, and builds upper and lower deviation bands. An optional ATR floor prevents the structure from becoming excessively narrow during quiet conditions.

The raw bands are transformed into one-sided trails. The lower trail ratchets upward during bullish regimes, while the upper trail ratchets downward during bearish regimes. Trend changes occur only when price breaks the opposite trail, optionally with confirmation from the slope of VWAP.

The updated visual engine measures price separation and VWAP slope to dynamically control the layered gradient, trail glow, and temporary post-flip bloom. This creates a clearer representation of direction, structural strength, and fresh regime transitions without changing the underlying signal logic.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BackQuant

//@version=6
indicator(
 "VWAP Deviation Trend [BackQuant]", 
 overlay = true
 )

// Groups 
const string g1 = "VWAP Calculation", const string g2 = "Deviation Bands", const string g3 = "Trend Settings", const string g4 = "UI Settings"

// calc settings
string sessionType = input.string("Rolling (Lookback: Bars)", "VWAP Mode", options = ["4 Hours", "Daily", "Weekly", "Rolling (Lookback: Bars)", "Rolling (Lookback: Days)"], group = g1, tooltip = "Select the anchored or rolling window used for the VWAP calculation.")
int rollingPeriod = input.int(50, "Rolling Lookback Bars", minval = 2, maxval = 2000, group = g1)
int rollingDays = input.int(30, "Rolling Lookback Days", minval = 1, maxval = 365, group = g1)
float src = input.source(hlc3, "Price Source", group = g1)

// deviations
float devMult = input.float(1.5, "Deviation Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = g2, tooltip = "Multiplier applied to the volume-weighted standard deviation.")
bool useAtrFloor = input.bool(true, "ATR Minimum Width", group = g2, tooltip = "Prevents the deviation bands becoming excessively narrow during low-dispersion periods.")
int atrLen = input.int(14, "ATR Length", minval = 1, maxval = 200, group = g2)
float atrFloorMult = input.float(0.35, "ATR Minimum Multiplier", minval = 0.0, maxval = 5.0, step = 0.05, group = g2)

// trend
bool useSlopeConfirm = input.bool(false, "VWAP Slope Confirmation", group = g3, tooltip = "Requires the VWAP to slope in the direction of a new trend before allowing the trail to flip.")
int slopeLen = input.int(2, "VWAP Slope Lookback", minval = 1, maxval = 50, group = g3)
string triggerMode = input.string("Close", "Flip Trigger", options = ["Close", "Price Source"], group = g3)
bool breakTrailOnFlip = input.bool(true, "Break Trail On Flips", group = g3)

// plotting
bool showTrail = input.bool(true, "Show Deviation Trail", group = g4), bool showVwap = input.bool(false, "Show VWAP", group = g4)
bool showBands = input.bool(false, "Show Raw Deviation Bands", group = g4), bool showFill = input.bool(true, "Gradient Fill", group = g4)
bool showGlow = input.bool(true, "Trail Glow", group = g4), bool showSig = input.bool(true, "Show Signals", group = g4)
bool paintBar = input.bool(true, "Color Candles", group = g4)
// extra coloring
color longCol = input.color(#00ff00, "Bullish", inline = "c", group = g4), color shortCol = input.color(#ff0000, "Bearish", inline = "c", group = g4)
color vwapCol = input.color(#ffffff, "VWAP", inline = "c", group = g4), int lineW = input.int(3, "Line Width", minval = 1, maxval = 6, group = g4)

// Period ID
getPeriodId(int barTime, string session) =>
    float seconds = barTime / 1000.0
    float periodId = na
    if session == "4 Hours"
        periodId := math.floor(math.floor(seconds / 3600.0) / 4.0)
    else if session == "Daily"
        periodId := math.floor(seconds / 86400.0)
    else if session == "Weekly"
        periodId := math.floor((math.floor(seconds / 86400.0) + 3.0) / 7.0)
    periodId

// VWAP Window
bool rollingBarsMode = sessionType == "Rolling (Lookback: Bars)"
bool rollingDaysMode = sessionType == "Rolling (Lookback: Days)"

var float lastPeriodId = na
var int currentPeriodStart = na
int period = 1

if rollingBarsMode
    period := rollingPeriod
else if rollingDaysMode
    int cutoff = time - rollingDays * 86400000
    int bars = 0
    for i = 0 to 4999
        if not na(time[i]) and time[i] >= cutoff
            bars += 1
        else
            break
    period := math.max(bars, 1)
else
    float periodId = getPeriodId(time, sessionType)
    if na(lastPeriodId) or periodId != lastPeriodId
        lastPeriodId := periodId
        currentPeriodStart := bar_index
    period := math.max(1, bar_index - currentPeriodStart + 1)

// Volume-Weighted Mean and Deviation
float vol = nz(volume, 0.0)
float sumVol = math.sum(vol, period)
float sumPrice = math.sum(src, period)
float sumPriceVol = math.sum(src * vol, period)
float sumSquaredPrice = math.sum(src * src, period)
float sumSquaredPriceVol = math.sum(src * src * vol, period)

float vwapValue = sumVol > 0.0 ? sumPriceVol / sumVol : sumPrice / period
float weightedMeanSquare = sumVol > 0.0 ? sumSquaredPriceVol / sumVol : sumSquaredPrice / period
float weightedVariance = math.max(weightedMeanSquare - vwapValue * vwapValue, 0.0)
float weightedDeviation = math.sqrt(weightedVariance)

// Deviation Bands
float deviationWidth = weightedDeviation * devMult
float atrFloor = ta.atr(atrLen) * atrFloorMult
float bandWidth = useAtrFloor ? math.max(deviationWidth, atrFloor) : deviationWidth

float rawUpper = vwapValue + bandWidth
float rawLower = vwapValue - bandWidth

// Trailing Bands
float trigger = triggerMode == "Close" ? close : src

var float trailUpper = na
var float trailLower = na

trailLower := not na(trailLower[1]) and trigger[1] > trailLower[1] ? math.max(rawLower, trailLower[1]) : rawLower
trailUpper := not na(trailUpper[1]) and trigger[1] < trailUpper[1] ? math.min(rawUpper, trailUpper[1]) : rawUpper

// Trend Logic
bool bullSlopePass = not useSlopeConfirm or vwapValue > vwapValue[slopeLen]
bool bearSlopePass = not useSlopeConfirm or vwapValue < vwapValue[slopeLen]

var int trend = 0

if trend == 0 and not na(vwapValue)
    trend := trigger >= vwapValue ? 1 : -1

bool rawBullFlip = trigger > trailUpper and trend != 1 and bullSlopePass
bool rawBearFlip = trigger < trailLower and trend != -1 and bearSlopePass

if rawBullFlip
    trend := 1
else if rawBearFlip
    trend := -1

bool bullFlip = trend == 1 and trend[1] == -1
bool bearFlip = trend == -1 and trend[1] == 1
bool trendFlip = bullFlip or bearFlip

float trendTrail = trend == 1 ? trailLower : trend == -1 ? trailUpper : na
float plottedTrail = breakTrailOnFlip and trendFlip ? na : trendTrail
color trendCol = trend == 1 ? longCol : trend == -1 ? shortCol : color.gray

// Visual Strength
float visualDistance = not na(trendTrail) ? math.abs(close - trendTrail) : 0.0
float distanceStrength = bandWidth > 0.0 ? math.min(visualDistance / bandWidth, 2.0) / 2.0 : 0.0
float slopeStrength = not na(vwapValue[slopeLen]) and bandWidth > 0.0 ? math.min(math.abs(vwapValue - vwapValue[slopeLen]) / bandWidth, 1.0) : 0.0
float trendStrength = math.min(distanceStrength * 0.70 + slopeStrength * 0.30, 1.0)

int barsSinceFlip = nz(ta.barssince(trendFlip), 100000)
float bloomStrength = barsSinceFlip == 1 ? 1.0 : barsSinceFlip == 2 ? 0.55 : barsSinceFlip == 3 ? 0.25 : 0.0
int fillBoost = int(math.round(trendStrength * 12.0))
int bloomBoost = int(math.round(bloomStrength * 12.0))
int mediumBoost = int(math.round(fillBoost * 0.65))
int bloomMedium = int(math.round(bloomBoost * 0.60))
int softBoost = int(math.round(fillBoost * 0.35))
int bloomSoft = int(math.round(bloomBoost * 0.25))

// Gradient Levels
bool fillReady = showTrail and showFill and not na(plottedTrail)
bool priceAboveTrail = close >= trendTrail

float grad1 = trendTrail + (close - trendTrail) * 0.12
float grad2 = trendTrail + (close - trendTrail) * 0.28
float grad3 = trendTrail + (close - trendTrail) * 0.46
float grad4 = trendTrail + (close - trendTrail) * 0.64
float grad5 = trendTrail + (close - trendTrail) * 0.82

color gradInner1 = color.new(trendCol, math.max(28, 56 - fillBoost - bloomBoost))
color gradOuter1 = color.new(trendCol, math.max(60, 84 - softBoost - bloomSoft))
color gradInner2 = color.new(trendCol, math.max(46, 72 - mediumBoost - bloomMedium))
color gradOuter2 = color.new(trendCol, math.max(74, 91 - softBoost - bloomSoft))
color gradInner3 = color.new(trendCol, math.max(60, 82 - mediumBoost - bloomMedium))
color gradOuter3 = color.new(trendCol, math.max(82, 95 - softBoost))
color gradInner4 = color.new(trendCol, math.max(72, 89 - softBoost - bloomSoft))
color gradOuter4 = color.new(trendCol, math.max(88, 97 - softBoost))
color gradInner5 = color.new(trendCol, math.max(80, 94 - softBoost))
color gradOuter5 = color.new(trendCol, math.max(92, 98 - softBoost))
color gradInner6 = color.new(trendCol, math.max(86, 97 - softBoost))
color gradOuter6 = color.new(trendCol, math.max(95, 99 - softBoost))

// Plots
pTrail = plot(showTrail ? plottedTrail : na, "VWAP Deviation Trail", color = trendCol, linewidth = lineW, style = plot.style_linebr)
pPrice = plot(fillReady ? close : na, "Price Ref", display = display.none, editable = false)
pGrad1 = plot(fillReady ? grad1 : na, "Gradient Ref 1", display = display.none, editable = false)
pGrad2 = plot(fillReady ? grad2 : na, "Gradient Ref 2", display = display.none, editable = false)
pGrad3 = plot(fillReady ? grad3 : na, "Gradient Ref 3", display = display.none, editable = false)
pGrad4 = plot(fillReady ? grad4 : na, "Gradient Ref 4", display = display.none, editable = false)
pGrad5 = plot(fillReady ? grad5 : na, "Gradient Ref 5", display = display.none, editable = false)

plot(showVwap ? vwapValue : na, "VWAP", color = color.new(vwapCol, 25), linewidth = 1)
plot(showBands ? rawUpper : na, "Upper Deviation Band", color = color.new(trendCol, 75), linewidth = 1)
plot(showBands ? rawLower : na, "Lower Deviation Band", color = color.new(trendCol, 75), linewidth = 1)

// Layered Gradient Fill
fill(pTrail, pGrad1, priceAboveTrail ? grad1 : trendTrail, priceAboveTrail ? trendTrail : grad1, fillReady ? (priceAboveTrail ? gradOuter1 : gradInner1) : na, fillReady ? (priceAboveTrail ? gradInner1 : gradOuter1) : na, title = "Gradient Layer 1")
fill(pTrail, pGrad2, priceAboveTrail ? grad2 : trendTrail, priceAboveTrail ? trendTrail : grad2, fillReady ? (priceAboveTrail ? gradOuter2 : gradInner2) : na, fillReady ? (priceAboveTrail ? gradInner2 : gradOuter2) : na, title = "Gradient Layer 2")
fill(pTrail, pGrad3, priceAboveTrail ? grad3 : trendTrail, priceAboveTrail ? trendTrail : grad3, fillReady ? (priceAboveTrail ? gradOuter3 : gradInner3) : na, fillReady ? (priceAboveTrail ? gradInner3 : gradOuter3) : na, title = "Gradient Layer 3")
fill(pTrail, pGrad4, priceAboveTrail ? grad4 : trendTrail, priceAboveTrail ? trendTrail : grad4, fillReady ? (priceAboveTrail ? gradOuter4 : gradInner4) : na, fillReady ? (priceAboveTrail ? gradInner4 : gradOuter4) : na, title = "Gradient Layer 4")
fill(pTrail, pGrad5, priceAboveTrail ? grad5 : trendTrail, priceAboveTrail ? trendTrail : grad5, fillReady ? (priceAboveTrail ? gradOuter5 : gradInner5) : na, fillReady ? (priceAboveTrail ? gradInner5 : gradOuter5) : na, title = "Gradient Layer 5")
fill(pTrail, pPrice, priceAboveTrail ? close : trendTrail, priceAboveTrail ? trendTrail : close, fillReady ? (priceAboveTrail ? gradOuter6 : gradInner6) : na, fillReady ? (priceAboveTrail ? gradInner6 : gradOuter6) : na, title = "Gradient Layer 6")

// Trail Glow
float glow = ta.atr(14) * (0.045 + trendStrength * 0.025)
float outerGlow = glow * 2.4
bool glowReady = showTrail and showGlow and not na(plottedTrail)

pGlowOuterLower = plot(glowReady ? trendTrail - outerGlow : na, "Outer Glow Lower Ref", display = display.none, editable = false)
pGlowOuterUpper = plot(glowReady ? trendTrail + outerGlow : na, "Outer Glow Upper Ref", display = display.none, editable = false)
pGlowLower = plot(glowReady ? trendTrail - glow : na, "Glow Lower Ref", display = display.none, editable = false)
pGlowUpper = plot(glowReady ? trendTrail + glow : na, "Glow Upper Ref", display = display.none, editable = false)

fill(pGlowOuterLower, pGlowOuterUpper, glowReady ? color.new(trendCol, math.max(82, 95 - softBoost - bloomSoft)) : na, title = "Outer Trail Glow")
fill(pGlowLower, pGlowUpper, glowReady ? color.new(trendCol, math.max(60, 84 - fillBoost - bloomBoost)) : na, title = "Inner Trail Glow")

// Flip Bloom
float bloomWidth = ta.atr(14) * (0.12 + bloomStrength * 0.08)
bool bloomReady = showTrail and showGlow and bloomStrength > 0.0 and not na(trendTrail)

pBloomLower = plot(bloomReady ? trendTrail - bloomWidth : na, "Bloom Lower Ref", display = display.none, editable = false)
pBloomUpper = plot(bloomReady ? trendTrail + bloomWidth : na, "Bloom Upper Ref", display = display.none, editable = false)

fill(pBloomLower, pBloomUpper, bloomReady ? color.new(trendCol, 88 - int(math.round(bloomStrength * 16.0))) : na, title = "Flip Bloom")

// Candle
plotcandle(open,high,low,close, "Trend Candles", trendCol, trendCol, true, bordercolor = trendCol, display = paintBar?display.all:display.none)


// Signals
plotshape(showSig and bullFlip ? trendTrail : na, "Bull Flip", shape.labelup, location.absolute, longCol, text = "▲", textcolor = chart.bg_color, size = size.small)
plotshape(showSig and bearFlip ? trendTrail : na, "Bear Flip", shape.labeldown, location.absolute, shortCol, text = "▼", textcolor = chart.bg_color, size = size.small)

// Alerts
alertcondition(bullFlip, "VWAP Deviation Trail Bullish", "VWAP Deviation Trail turned bullish on {{ticker}}")
alertcondition(bearFlip, "VWAP Deviation Trail Bearish", "VWAP Deviation Trail turned bearish on {{ticker}}")
````
