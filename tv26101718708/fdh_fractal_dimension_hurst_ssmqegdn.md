# FDH  Fractal Dimension & Hurst

- url: https://www.tradingview.com/script/sSmQEgdn-FDH-Fractal-Dimension-Hurst/
- type: indicator
- pine_id: PUB;b909d64ef1b94dcf9d24a241c56dc4c9
- version: 1.0

## Description

FDH  Fractal Dimension & Hurst

█ OVERVIEW

FDH is a two-line market-structure indicator displayed in a separate pane. It examines recent closing prices through two different calculations:

• The blue Path Dimension line estimates how direct or jagged the recent price path has been.
• The pink Hurst Dimension line measures how the accumulated deviations of recent prices compare with the normal variation in that same window.

Both lines use closing prices and the same lookback length, but they measure different features. Comparing them can show when the two calculations describe the recent price structure differently. They are not independent confirmations, and neither line tells you whether price is moving up or down.

FDH uses the smoothed line values to display the current zones. The default lookback is 30 bars and the default EMA smoothing length is 3 bars. On 1-, 3- and 5-minute charts, a 30-bar lookback represents approximately 30, 90 and 150 minutes respectively. Those are bar counts, not fixed clock durations; session breaks, missing bars and the symbol's trading schedule can change the elapsed time.

█ HOW TO READ THE PATH DIMENSION LINE

The blue line is a normalized measurement of the path made by the last N closes. First, FDH finds the highest and lowest close in the lookback window. It then scales the prices to fit between zero and one and spaces the observations evenly along a horizontal time axis. Finally, it adds the straight-line distance between each pair of neighboring observations.

A relatively direct path has less total length than one that repeatedly changes direction. For example, a steady sequence of closes from 100 to 104 traces a more direct path than a sequence that swings between 100 and 104 before finishing at 104. Because the calculation normalizes the window, the size of the move in dollars or points does not by itself determine the reading.

The Path Dimension line is direction-neutral. A smooth rise and a smooth fall with the same normalized shape can have similar readings. A rising blue line means this estimate of path roughness is increasing; it does not mean price is rising. A lower reading describes a more direct path in the measured window, not a guaranteed trend or a trade opportunity.

FDH uses 1.50 as a theoretical reference associated with the dimension of an ideal Brownian path. This makes 1.50 a useful conceptual reference when viewing the line. The script does not test whether the market is actually following a random walk. A finite rolling window, the particular path-length formula and EMA smoothing can all affect the displayed value. A crossing of 1.50 is not, by itself, a market-regime diagnosis.

PATH DIMENSION ZONES

• Below 1.40: the lower Path Dimension zone is highlighted.
• From 1.40 through 1.50: there is no Path Dimension fill.
• Above 1.50 up to 1.60: the upper Path Dimension zone is highlighted.
• Above 1.60: the extreme zone is highlighted with its own darker default color.

The upper fill stops at 1.60. Any excursion above 1.60 belongs to the extreme fill. At a threshold itself, the corresponding fill has zero height. “Extreme” is the name of a configurable display zone, not a statistical percentile or confirmation of a market top or bottom.

█ HOW TO READ THE HURST DIMENSION LINE

The pink line gives a second view of the same closing-price window. FDH calculates the average close, measures how far each close is from that average, and adds those deviations cumulatively. It compares the range of this cumulative path with the ordinary variation of prices in the window. The result is transformed and flipped onto a dimension-style display scale.

This construction is related to rescaled-range analysis, but it is a single-window proxy calculated from price levels. It is not the familiar multi-window Hurst method that estimates a slope across several lookback sizes. The name “Hurst Dimension” describes the transformed display; it should not be read as proof that FDH has estimated a statistically validated Hurst exponent or long-memory property.

The transform runs in the opposite direction to the intermediate Hurst-style value: a lower pink-line reading corresponds to a higher intermediate value, and a higher pink-line reading corresponds to a lower one. This relationship helps explain the chosen highlight zones, but it does not make the pink line a forecast of persistence, reversal or price direction.

HURST DIMENSION ZONES

• Below 1.30: the lower Hurst zone is highlighted in the Hurst line color by default.
• From 1.30 through 1.40: there is no Hurst fill.
• Above 1.40: the upper Hurst zone is highlighted with its own selectable color.

The lower and upper Hurst thresholds are independently configurable. The Hurst reference lines can be shown or hidden together. These zones show where the calculated value sits relative to the selected levels; they do not certify persistent or anti-persistent price behavior.

█ WHAT THE MATH DOES

1. BLUE PATH DIMENSION: SCALE THE PRICE PATH, THEN MEASURE IT

The lookback length is the number of recent closes used in each raw calculation. The code finds the highest and lowest close. If the range is not flat, each close is mapped to a value from zero to one within that range. Time is also mapped evenly from zero to one, so every adjacent pair of bars has the same horizontal spacing.

For each adjacent pair, the function measures one horizontal step and the change in normalized price. It uses the Pythagorean distance for that small segment and adds all segment distances together. The total is then passed through the logarithmic transform shown in the code. The transform produces the displayed Sevcik-style path-dimension estimate.

Here is the actual path-length function from the FDH source:

[pine]
f_sevcik(float src, int n) =>
    float hi = ta.highest(src, n)
    float lo = ta.lowest(src, n)
    float rng = hi - lo
    float length = 0.0
    if rng > 0
        for i = 0 to n - 2
            float dy = (src[i + 1] - src[i]) / rng
            float dx = 1.0 / (n - 1.0)
            length += math.sqrt(dy * dy + dx * dx)
    float result = 1.5
    if rng > 0 and length > 0
        result := 1.0 + (math.log(length) + math.log(2.0)) / math.log(2.0 * (n - 1.0))
    na(src[n - 1]) ? na : result
[/pine]

The logarithmic expression includes a finite-window correction. Consequently, a perfectly straight, nonflat path does not necessarily produce a value of exactly 1.0 at a finite lookback. The lookback length is part of the calculation, so changing it can change the estimate even when the broad shape of the price path looks similar.

A completely flat window has no price range to normalize. For that case, the raw Path Dimension calculation uses 1.50 as its fallback value. For nonflat windows, adding a constant to every close or multiplying every close by the same nonzero factor leaves the normalized path shape unchanged, apart from floating-point effects. The measurement therefore does not express absolute volatility or the size of a move.

This is a path-length calculation, not a box-counting calculation. The script's historical internal variable name includes “Box,” but it does not count occupied boxes at multiple scales or fit a box-counting regression.

2. PINK HURST DIMENSION: COMPARE CUMULATIVE DEVIATION WITH PRICE VARIATION

The function starts with the average close over the window. It subtracts that average from each close. Positive deviations add to a running total; negative deviations subtract from it. The distance between the highest and lowest points reached by that running total is the cumulative-deviation range.

The function divides that range by the population standard deviation of closes in the window. In plain terms, this rescales the accumulated movement by the window's ordinary price variation. It then applies a logarithm and divides by the logarithm of the lookback length. The intermediate result is limited to the range 0.01 through 0.99, then subtracted from 2 to create the plotted Hurst Dimension value.

Here is the actual Hurst-style function from the FDH source:

[pine]
f_hurst_dimension(float src, int n) =>
    float meanVal = ta.sma(src, n)
    float cumulative = 0.0
    float maxDev = -1e10
    float minDev = 1e10
    float squared = 0.0
    for i = 0 to n - 1
        float d = src[i] - meanVal
        squared += d * d
        cumulative += d
        maxDev := math.max(maxDev, cumulative)
        minDev := math.min(minDev, cumulative)
    float sd = math.sqrt(squared / n)
    float rs = sd > 0 ? (maxDev - minDev) / sd : 1.0
    float h = rs > 0 ? math.log(rs) / math.log(n) : 0.5
    h := math.max(0.01, math.min(0.99, h))
    na(src[n - 1]) ? na : 2.0 - h
[/pine]

This implementation has important limits. It uses only one lookback window, not a family of windows. It does not remove a fitted trend before forming the ratio, and it uses closing-price levels rather than a series of returns. Drift, nonstationarity, finite-window effects and the position of observations in the window can therefore influence its output. Treat the pink line as a companion price-structure measure, not as a standard Hurst-exponent estimate or a formal test of long memory.

If the price window is completely flat, the function substitutes a ratio of 1 because the standard deviation is zero. That produces a raw Hurst Dimension fallback of 1.99 after the transform. This is a computational fallback, not an interpretation of a market condition. The blue and pink fallback values are smoothed like other raw values, so their first visible readings can transition over multiple bars.

3. EMA SMOOTHING: REDUCE NOISE, ACCEPT SOME DELAY

FDH applies an exponential moving average separately to both raw calculations. The default smoothing length is 3 bars. A shorter smoothing length follows raw changes more closely; a longer one filters more short-term movement but responds later.

These are the actual smoothing lines from the script:

[pine]
float dBox = ta.ema(f_sevcik(close, len), smoothLen)
float dHurst = ta.ema(f_hurst_dimension(close, len), smoothLen)
[/pine]

The zone conditions use these smoothed values. The raw calculations need a complete lookback window before a normal value is available. The source contains no future-bar lookahead, centered pivot confirmation or negative plot offsets. On a live, still-forming bar, however, the close can change; both lines and their fills can move until that bar closes. Compare completed bars when you want stable readings.

4. HOW ZONE HIGHLIGHTS ARE ACTIVATED

Each zone is a visual fill between its threshold and the relevant line. It is not a background tint for the whole pane. For example, the Box lower zone fills only the space from the 1.40 level down to the blue line while that line is below the level. The Hurst upper zone fills only the space from 1.40 up to the pink line while that line is above its level.

The actual source conditions for those two zones are:

[pine]
bool lowerActive = showFill and showLowerZone and dBox < lowerLevel
bool hurstUpperActive = showHurstFill and showHurstHighZone and dHurst > hurstHigh
[/pine]

If the blue line reads 1.36 and its visibility controls are on, the lower Box highlight is active. If the pink line reads 1.43 and its controls are on, the upper Hurst highlight is active. These examples describe the display only; neither condition creates a trading signal.

Each fill uses a gradient that grows more visible as the line moves farther beyond its threshold. Gradient strength and color affect appearance, not the calculated values. Exact-threshold touches have no visible fill area. In the Box upper zone, the fill is capped at 1.60 so the darker extreme zone can take over above that level.

█ COLOR AND INPUT CONTROLS

The existing zone layout is retained. The calculation levels, colors and gradients can be adjusted in the script settings:

• Fractal Lookback: number of recent closes used by both calculations; default 30.
• EMA Smoothing: smoothing length for both plotted lines; default 3.
• Lower Level: bottom threshold for the blue Path Dimension highlight; default 1.40.
• Upper / Brownian Reference: threshold for the blue upper zone; default 1.50.
• Extreme Level: start of the blue extreme zone; default 1.60.
• Hurst Low Zone: threshold for the lower pink zone; default 1.30.
• Hurst High Zone: threshold for the upper pink zone; default 1.40.
• Path Dimension Color: blue line and upper zone from 1.50 to 1.60.
• Box Below 1.40 Color: independent lower-zone color, visibility and gradient-strength controls. The global Smooth Pane Gradients switch also governs Box fills.
• Extreme Zone Color: independent, darker default color for the blue zone above 1.60.
• Hurst Dimension Color: pink line and lower zone below 1.30.
• Hurst Above 1.40 Color: independent upper Hurst-zone color and gradient strength, with its own visibility switch.
• Hurst Zone Gradients: master switch for the lower and upper pink fills.
• Show Hurst References: show or hide the two Hurst threshold lines.

The lower Box highlight and upper Hurst highlight can each be colored and adjusted independently. Adjusting a color, visibility toggle or gradient strength does not change the underlying line calculation.

█ READING THE TWO LINES TOGETHER

Start with the blue line's location relative to 1.40, 1.50 and 1.60. Then compare the pink line with its 1.30 and 1.40 levels. Agreement means the two calculations are describing the window in a similar way; disagreement means their different constructions are producing different readings. Neither case is a probability, an entry condition or an independent confirmation.

For example, a blue value above 1.50 says that the normalized path-length estimate is on the higher side of its Brownian reference. It does not establish that price is random or directionless. A pink value below 1.30 sits on the high side of the intermediate Hurst-style scale after the transform. Under idealized fractional-Brownian assumptions, that side is associated with persistence; this single-window proxy does not establish that those assumptions fit the market. Always compare the pane with price action, timeframe context and a separately defined trade plan.

█ TIMEFRAME AND PRACTICAL LIMITS

FDH was developed and tested as a visual analysis tool on lower timeframes, particularly 1-, 3- and 5-minute charts. “Tested for trading use” refers to chart-based evaluation. This indicator is not a strategy script: it places no orders, provides no entry or exit markers, and makes no claim of formal backtesting, positive returns, accuracy or predictive advantage.

On short timeframes, bid-ask bounce, tick size, thin trading, feed differences and ordinary bar-to-bar noise can affect the closes. Because the blue estimate uses every close in its window, a run of noisy back-and-forth bars can raise its roughness reading. The pink estimate can be affected by drift and by which closes fall inside its window. The same thresholds may behave differently across symbols, sessions, feeds and timeframes. Include spread, commissions, slippage, liquidity and execution timing when evaluating any trading use.

FDH is an analytical display, not a complete trading system. It has no chart markers, volume calculations, regression channels, alerts or strategy orders. The colored zones show where the estimates sit relative to configurable thresholds; they do not state what the market must do next.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Drizzel_Algo56
//@version=6
indicator("FDH | Fractal Dimension & Hurst", overlay = false, behind_chart = false, max_bars_back = 500, precision = 3)

int len = input.int(30, "Fractal Lookback", minval = 10, maxval = 500, group = "Calculation")
int smoothLen = input.int(3, "EMA Smoothing", minval = 1, group = "Calculation")
float lowerLevel = input.float(1.40, "Lower Level", step = 0.01, group = "Levels")
float upperLevel = input.float(1.50, "Upper / Brownian Reference", step = 0.01, group = "Levels")
float extremeLevel = input.float(1.60, "Extreme Level", step = 0.01, group = "Levels")
float hurstLow = input.float(1.30, "Hurst Low Zone", step = 0.01, group = "Levels")
float hurstHigh = input.float(1.40, "Hurst High Zone", step = 0.01, group = "Levels")
bool showHurstRefs = input.bool(true, "Show Hurst References", group = "Levels")
bool showFill = input.bool(true, "Smooth Pane Gradients", group = "Style")
int opacity = input.int(65, "Gradient Strength (%)", minval = 0, maxval = 100, group = "Style")
bool showLowerZone = input.bool(true, "Show Box Below 1.40", group = "Box Lower Zone")
color lowerZoneColor = input.color(#2962FF, "Box Below 1.40 Color", group = "Box Lower Zone")
int lowerZoneOpacity = input.int(65, "Box Below 1.40 Gradient Strength (%)", minval = 0, maxval = 100, group = "Box Lower Zone")
color boxColor = input.color(#2962FF, "Path Dimension Color", group = "Line Colors")
color extremeColor = input.color(#123A8C, "Extreme Zone Color", group = "Zone Colors")
color hurstColor = input.color(#E040FB, "Hurst Dimension Color", group = "Line Colors")
bool showHurstHighZone = input.bool(true, "Show Hurst Above 1.40", group = "Hurst Upper Zone")
color hurstHighColor = input.color(#9C27B0, "Hurst Above 1.40 Color", group = "Hurst Upper Zone")
int hurstHighOpacity = input.int(40, "Hurst Above 1.40 Gradient Strength (%)", minval = 0, maxval = 100, group = "Hurst Upper Zone")
bool showHurstFill = input.bool(true, "Hurst Zone Gradients", group = "Hurst Style")
int hOpacity = input.int(40, "Hurst Gradient Strength (%)", minval = 0, maxval = 100, group = "Hurst Style")

if barstate.isfirst and not (lowerLevel < upperLevel and upperLevel < extremeLevel)
    runtime.error("Levels must satisfy Lower < Upper < Extreme.")
if barstate.isfirst and not (hurstLow < hurstHigh)
    runtime.error("Hurst Low Zone must be below Hurst High Zone.")

f_sevcik(float src, int n) =>
    float hi = ta.highest(src, n)
    float lo = ta.lowest(src, n)
    float rng = hi - lo
    float length = 0.0
    if rng > 0
        for i = 0 to n - 2
            float dy = (src[i + 1] - src[i]) / rng
            float dx = 1.0 / (n - 1.0)
            length += math.sqrt(dy * dy + dx * dx)
    float result = 1.5
    if rng > 0 and length > 0
        result := 1.0 + (math.log(length) + math.log(2.0)) / math.log(2.0 * (n - 1.0))
    na(src[n - 1]) ? na : result

f_hurst_dimension(float src, int n) =>
    float meanVal = ta.sma(src, n)
    float cumulative = 0.0
    float maxDev = -1e10
    float minDev = 1e10
    float squared = 0.0
    for i = 0 to n - 1
        float d = src[i] - meanVal
        squared += d * d
        cumulative += d
        maxDev := math.max(maxDev, cumulative)
        minDev := math.min(minDev, cumulative)
    float sd = math.sqrt(squared / n)
    float rs = sd > 0 ? (maxDev - minDev) / sd : 1.0
    float h = rs > 0 ? math.log(rs) / math.log(n) : 0.5
    h := math.max(0.01, math.min(0.99, h))
    na(src[n - 1]) ? na : 2.0 - h

float dBox = ta.ema(f_sevcik(close, len), smoothLen)
float dHurst = ta.ema(f_hurst_dimension(close, len), smoothLen)

// Each zone uses one continuous opacity ramp, equivalent to the old
// three adjoining linear ramps, with fewer hidden plots and fill calls.

bool upperActive = showFill and dBox > upperLevel
float upperBase = upperActive ? upperLevel : na
float upperEdge = upperActive ? math.min(dBox, extremeLevel) : na
upperBasePlot = plot(upperBase, "Upper Fill Base", color = na, display = display.none)
upperEdgePlot = plot(upperEdge, "Upper Fill Edge", color = na, display = display.none)
fill(upperEdgePlot, upperBasePlot,
     upperEdge, upperBase,
     color.new(boxColor, 100 - opacity), color.new(boxColor, 100),
     title = "Upper Gradient", fillgaps = false)

bool extremeActive = showFill and dBox > extremeLevel
float extremeBase = extremeActive ? extremeLevel : na
float extremeEdge = extremeActive ? dBox : na
extremeBasePlot = plot(extremeBase, "Extreme Fill Base", color = na, display = display.none)
extremeEdgePlot = plot(extremeEdge, "Extreme Fill Edge", color = na, display = display.none)
fill(extremeEdgePlot, extremeBasePlot,
     extremeEdge, extremeBase,
     color.new(extremeColor, 100 - opacity), color.new(extremeColor, 100),
     title = "Extreme Gradient", fillgaps = false)

bool lowerActive = showFill and showLowerZone and dBox < lowerLevel
float lowerBase = lowerActive ? lowerLevel : na
float lowerEdge = lowerActive ? dBox : na
lowerBasePlot = plot(lowerBase, "Lower Fill Base", color = na, display = display.none)
lowerEdgePlot = plot(lowerEdge, "Lower Fill Edge", color = na, display = display.none)
fill(lowerBasePlot, lowerEdgePlot,
     lowerBase, lowerEdge,
     color.new(lowerZoneColor, 100), color.new(lowerZoneColor, 100 - lowerZoneOpacity),
     title = "Lower Gradient", fillgaps = false)

bool hurstLowerActive = showHurstFill and dHurst < hurstLow
float hurstLowerBase = hurstLowerActive ? hurstLow : na
float hurstLowerEdge = hurstLowerActive ? dHurst : na
hurstLowerBasePlot = plot(hurstLowerBase, "Hurst Low Fill Base", color = na, display = display.none)
hurstLowerEdgePlot = plot(hurstLowerEdge, "Hurst Low Fill Edge", color = na, display = display.none)
fill(hurstLowerBasePlot, hurstLowerEdgePlot,
     hurstLowerBase, hurstLowerEdge,
     color.new(hurstColor, 100), color.new(hurstColor, 100 - hOpacity),
     title = "Hurst Low Gradient", fillgaps = false)

bool hurstUpperActive = showHurstFill and showHurstHighZone and dHurst > hurstHigh
float hurstUpperBase = hurstUpperActive ? hurstHigh : na
float hurstUpperEdge = hurstUpperActive ? dHurst : na
hurstUpperBasePlot = plot(hurstUpperBase, "Hurst High Fill Base", color = na, display = display.none)
hurstUpperEdgePlot = plot(hurstUpperEdge, "Hurst High Fill Edge", color = na, display = display.none)
fill(hurstUpperEdgePlot, hurstUpperBasePlot,
     hurstUpperEdge, hurstUpperBase,
     color.new(hurstHighColor, 100 - hurstHighOpacity), color.new(hurstHighColor, 100),
     title = "Hurst High Gradient", fillgaps = false)

plot(dBox, "Path Dimension | Sevcik", color = boxColor, linewidth = 2)
plot(dHurst, "Hurst Dimension Proxy", color = hurstColor, linewidth = 2)
hline(lowerLevel, "Lower Level", color.new(boxColor, 35), hline.style_dashed)
hline(upperLevel, "Upper Level", color.new(boxColor, 35), hline.style_dashed)
hline(extremeLevel, "Extreme Level", color.new(boxColor, 25), hline.style_dashed)
hline(hurstLow, "Hurst Low Threshold", color.new(hurstColor, 35), hline.style_dotted, display = showHurstRefs ? display.all : display.none)
hline(hurstHigh, "Hurst High Threshold", color.new(hurstHighColor, 35), hline.style_dotted, display = showHurstRefs ? display.all : display.none)
````
