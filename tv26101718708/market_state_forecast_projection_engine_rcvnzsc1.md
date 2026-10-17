# Market State Forecast Projection Engine

- url: https://www.tradingview.com/script/RCvnZSc1-Market-State-Forecast-Projection-Engine/
- type: indicator
- pine_id: PUB;69d4b5b91a65454c8ba097a2a1856dd0
- version: 1.0

## Description

This indicator is a **forecast projection tool**. It looks at the current market environment, searches history for the most similar environments, then plots what usually happened afterward. It is not trying to predict the future with certainty. It is saying: “When the market looked like this before, what tended to happen next?” 

The engine defines the current market environment using three things:

* **Trend**, based on moving averages.
* **Momentum**, based on RSI.
* **Volatility**, based on ATR.

Then it finds the closest historical matches, studies their future paths, and draws a forecast line with optional upper and lower bands.

---

## What You See on the Chart

### Forecast Midline

The main forecast line shows the **average path** of the selected historical matches.

In simple terms:

* If similar past situations usually moved higher, the line slopes up.
* If similar past situations usually moved lower, the line slopes down.
* If similar past situations were mixed, the line may be flat or choppy.

### Upper Band

The upper band shows the stronger side of historical outcomes.

It means:

* Some similar historical setups moved better than the average.
* The upper band gives you a visual idea of the upside range from those past examples.
* It is not a guaranteed target.

### Lower Band

The lower band shows the weaker side of historical outcomes.

It means:

* Some similar historical setups moved worse than the average.
* The lower band gives you a visual idea of downside risk from those past examples.
* It is not a guaranteed support level.

### Band Width

The space between the bands matters.

* Tight bands mean historical outcomes were more consistent.
* Wide bands mean historical outcomes were scattered and less reliable.
* A forecast with wide bands should be treated with more caution.

---

## Main Inputs

### Non-Repaint Mode

**Default: On**

This controls whether the forecast uses the live candle or the last completed candle.

Use **Non-Repaint Mode On** when:

* You want more stable signals.
* You want the forecast to update only after the candle closes.
* You care about cleaner historical testing.

Use **Non-Repaint Mode Off** when:

* You want the forecast to react during the current live candle.
* You accept that the forecast may change before the candle closes.

For most use cases, leave this **On**.

---

## Model Group

### Forecast Horizon

This controls how far into the future the indicator projects.

Example:

* On a daily chart, `20` means 20 trading days.
* On a 1-hour chart, `20` means 20 hours.
* On a 5-minute chart, `20` means 20 five-minute candles.

Use a lower value when:

* You are trading short-term moves.
* You want a tighter forecast window.
* You do not want the projection stretched too far.

Use a higher value when:

* You are looking for swing-trade context.
* You want to see the broader projected path.
* You are using higher timeframes.

A practical range is usually:

* `10–20` for shorter-term analysis.
* `20–50` for swing-style analysis.

---

### Search Depth

This controls how much history the engine searches.

Example:

* `1000` means the engine searches roughly 1,000 prior bars.
* `2000` means it searches more history.
* `500` means it searches less history.

Use a higher Search Depth when:

* You want a larger historical sample.
* You are on a short timeframe with lots of bars.
* You want more possible market-state comparisons.

Use a lower Search Depth when:

* You want the model to focus on more recent market behavior.
* You are on a slower chart like daily or weekly.
* You want less influence from older market regimes.

The tradeoff is simple:

* More history gives more examples.
* Less history may be more relevant to the current market regime.

---

### Pattern Matches

This controls how many of the closest historical matches are used.

This is one of the most important inputs.

If set to `30`, the engine finds the **30 closest historical market states** and builds the forecast from those.

Use fewer matches when:

* You want stricter, more specific comparisons.
* You want only the closest historical examples.
* You are okay with a forecast that may be more reactive.

Use more matches when:

* You want a smoother forecast.
* You want less noise from individual examples.
* You want a broader historical sample.

General interpretation:

* `10–20` = stricter, more selective.
* `25–40` = balanced.
* `50+` = broader, smoother, but less specific.

---

### Weight Closer Matches

This controls whether the best matches receive more influence.

When turned **On**:

* The closest historical matches matter more.
* Weaker matches still count, but less heavily.
* The forecast becomes more focused on the most similar examples.

When turned **Off**:

* Every selected match is treated equally.
* The forecast becomes more democratic.
* A very close match and a weaker match have the same influence.

For most users, leave this **On**.

---

## Advanced Model Inputs

### Forecast Model

This chooses how the engine defines the market environment.

All models use:

* EMA trend.
* RSI momentum.
* ATR volatility.

The difference is how each model emphasizes those ingredients.

---

### Conservative

Use **Conservative** when you want a slower, smoother model.

It is designed to:

* React less aggressively.
* Favor more stable market environments.
* Put more importance on trend and volatility.
* Reduce noisy forecast changes.

Best for:

* Daily charts.
* Swing trading.
* Slower-moving stocks or ETFs.
* Users who want fewer false shifts.

---

### Balanced

Use **Balanced** as the general-purpose default.

It is designed to:

* Give trend, momentum, and volatility a normal balance.
* Work across many markets.
* Avoid being too slow or too fast.

Best for:

* Most users.
* Most chart timeframes.
* General market forecasting.
* Starting point before testing other models.

---

### Aggressive

Use **Aggressive** when you want a faster model.

It is designed to:

* React more quickly to changing momentum.
* Give more influence to short-term market shifts.
* Be more sensitive to fresh moves.

Best for:

* Intraday trading.
* Fast-moving markets.
* Crypto.
* Momentum names.
* Traders who want earlier, more responsive shifts.

The downside is that it may be noisier.

---

### Trend Following

Use **Trend Following** when you want the model to emphasize persistent directional moves.

It is designed to:

* Care more about trend structure.
* Care less about short-term momentum noise.
* Favor markets that continue moving in the same direction.

Best for:

* Strong trending stocks.
* Indexes.
* Breakout environments.
* Higher-timeframe directional trading.

This model is less ideal in sideways or choppy markets.

---

### Mean Reversion

Use **Mean Reversion** when you want the model to focus on stretched conditions.

It is designed to:

* Emphasize momentum extremes.
* Look for environments where price may snap back or reverse.
* Care less about long-term trend persistence.

Best for:

* Range-bound markets.
* Overbought/oversold setups.
* Countertrend analysis.
* Shorter-term reversal ideas.

This model may fight strong trends, so use it carefully in momentum-heavy markets.

---

## Historical Lookback Inputs

### Lookback Bars

This lets you move the forecast backward in time.

Example:

* `0` means current forecast.
* `50` means show what the forecast would have looked like 50 bars ago.
* `250` means show what the forecast would have looked like 250 bars ago.

Use this for:

* Visual backtesting.
* Studying old setups.
* Checking whether the forecast was useful historically.
* Comparing forecast paths against what actually happened.

This is one of the most valuable testing features.

---

### Lock to Candle

This lets you anchor the forecast to a specific candle time instead of a simple bar offset.

Use it when:

* You want to test a specific time of day.
* You trade a regular session open.
* You want repeatable historical anchors.

Example:

* You can lock to the 13:30 UTC candle, which often corresponds to the U.S. stock market open during daylight saving time.

When this is off, the indicator uses **Lookback Bars** instead.

---

### Days Back

This works with **Lock to Candle**.

It tells the indicator how many matching anchor candles to go back.

Example:

* `0` = most recent matching candle.
* `1` = one matching session back.
* `2` = two matching sessions back.

Use this when:

* You want to test the most recent open.
* You want to test yesterday’s open.
* You want to step through past sessions one by one.

---

### Hour UTC

This is the UTC hour used for candle locking.

Use it with **Minute UTC** to identify the exact candle you want.

Example:

* `13` means 13:00 UTC.
* Combined with `30`, it means 13:30 UTC.

This is useful because TradingView symbols and sessions can vary, but UTC gives a consistent anchor.

---

### Minute UTC

This is the UTC minute used for candle locking.

Example:

* Hour UTC = `13`
* Minute UTC = `30`

Together, that means:

* Lock to the 13:30 UTC candle.

Use this for precise historical testing.

---

### Auto Previous Session

This controls what happens if today’s target candle has not printed yet.

When turned **On**:

* The indicator automatically uses the most recent previous matching candle.
* This keeps the forecast visible even before today’s target time exists.

When turned **Off**:

* If today’s target candle has not printed, the lock may show no match and fall back.

For most users, leave this **On**.

---

## Bias Logic Inputs

### Bias Threshold %

This controls how strong the bull or bear probability must be before the indicator labels the forecast bullish or bearish.

Example:

* If Bias Threshold is `60`, Bull Probability must be at least 60% before a bullish label can appear.
* If Bear Probability is at least 60%, a bearish label can appear.

Use a lower threshold when:

* You want more frequent bias labels.
* You are okay with weaker directional evidence.

Use a higher threshold when:

* You want stricter signals.
* You only want stronger historical agreement.

Practical range:

* `60%` = balanced.
* `70%+` = more conservative.
* `50–55%` = loose and more signal-heavy.

---

### Minimum Bull/Bear Edge %

This controls how large the gap must be between Bull Probability and Bear Probability.

Example:

* Bull Probability = 65%
* Bear Probability = 35%
* Edge = 30 percentage points

If the minimum edge is `15`, this would qualify.

But:

* Bull Probability = 58%
* Bear Probability = 42%
* Edge = 16 percentage points

This may still fail if Bull Probability is below the Bias Threshold.

This input prevents weak differences from being labeled as strong directional bias.

Use a higher edge when:

* You want cleaner bias labels.
* You want the model to avoid borderline calls.

Use a lower edge when:

* You want more frequent directional bias.
* You accept more uncertainty.

---

## Display Inputs

### Show Forecast Midline

This turns the main forecast line on or off.

Turn it **On** when:

* You want to see the projected average path.

Turn it **Off** when:

* You only want the info box probabilities.
* You want a cleaner chart.

---

### Show Confidence Bands

This turns the upper and lower forecast bands on or off.

Turn it **On** when:

* You want to see the historical range of outcomes.
* You care about uncertainty.
* You want to know whether the forecast is tight or messy.

Turn it **Off** when:

* You only want the central forecast.
* The chart feels too cluttered.

---

### Band Width Multiplier

This controls how wide the bands are.

Higher values make the bands wider.

Lower values make the bands tighter.

Use lower values when:

* You want a cleaner, tighter visual range.
* You want bands closer to the average forecast.

Use higher values when:

* You want to see a broader range of historical outcomes.
* You want a more conservative uncertainty envelope.

Default `1.0` is a good starting point.

---

## Forecast Midline Style Inputs

### Forecast Midline Color

Controls the color of the main projection line.

The default aqua color makes it visually distinct from price candles.

### Forecast Midline Width

Controls how thick the midline is.

Use a thicker line when:

* You want the forecast to stand out.
* You are using a busy chart.

Use a thinner line when:

* You want a cleaner chart.
* You use many overlays.

### Forecast Midline Type

Controls whether the line is:

* Solid.
* Dashed.
* Dotted.

Solid is usually best for the main forecast line.

---

## Upper Band Style Inputs

### Upper Band Color

Controls the color of the upper forecast band.

The default green tone suggests upside range.

### Upper Band Width

Controls how thick the upper band is.

A thin dashed line usually works best because it should be secondary to the midline.

### Upper Band Type

Controls whether the upper band is solid, dashed, or dotted.

Dashed is usually best because it visually communicates “range” rather than “target.”

---

## Lower Band Style Inputs

### Lower Band Color

Controls the color of the lower forecast band.

The default red tone suggests downside range.

### Lower Band Width

Controls how thick the lower band is.

A thin line keeps it useful without dominating the chart.

### Lower Band Type

Controls whether the lower band is solid, dashed, or dotted.

Dashed is usually best for the same reason as the upper band.

---

## Info Box Inputs

### Show Info Box

This turns the dashboard on or off.

Turn it **On** when:

* You want the probabilities and diagnostics visible.
* You are actively evaluating the forecast.

Turn it **Off** when:

* You only want the chart projection.
* You want a cleaner visual layout.

---

### Info Box Position

Controls where the dashboard appears.

Options:

* Top Left.
* Top Right.
* Bottom Left.
* Bottom Right.

Use the position that interferes least with price action on your chart.

---

### Text Size

Controls the dashboard text size.

Use:

* **Tiny** for compact charts.
* **Small** for normal use.
* **Normal** if you want easier reading.
* **Large** for presentations or large monitors.

---

### Background

Controls the info box background color.

A darker background usually works best on most TradingView chart themes.

### Border

Controls the info box border color.

This helps separate the dashboard from the chart.

### Header Text

Controls the title/header text color.

### Header Background

Controls the top header row background.

This gives the dashboard its polished look.

---

## Info Box Metrics

### Bull Prob %

This shows the weighted percentage of selected historical matches that ended bullish.

Simple meaning:

> Of the similar historical market states, how many tended to move up?

A high number means bullish outcomes dominated the selected historical matches.

---

### Bear Prob %

This shows the weighted percentage of selected historical matches that ended bearish.

Simple meaning:

> Of the similar historical market states, how many tended to move down?

A high number means bearish outcomes dominated the selected historical matches.

---

### Direction Bias

This shows the final label after applying the bias rules.

Possible outputs:

* Bullish.
* Bearish.
* None.
* Weak Data.
* No Matches.

A bullish or bearish label only appears when the probability and edge requirements are met.

---

### Bull/Bear/Flat

This shows how many selected matches ended:

* Bullish.
* Bearish.
* Flat.

Example:

* `18 / 9 / 3`

This means:

* 18 bullish historical outcomes.
* 9 bearish historical outcomes.
* 3 flat historical outcomes.

This gives you a quick look at the underlying distribution.

---

### Match Count

This shows how many historical matches were actually used.

If Pattern Matches is set to `30`, Match Count should usually show `30`.

If it shows less, there may not have been enough valid historical data.

---

### Fit Quality

This tells you how closely the selected historical matches resemble the current market state.

High Fit Quality means:

* The current market environment closely resembles the selected historical examples.

Low Fit Quality means:

* The engine found matches, but they were not very close.

Important:

* Fit Quality is not win rate.
* Fit Quality is not probability.
* Fit Quality is not accuracy.
* It only measures how good the historical comparisons are.

Best interpretation:

* High Fit Quality + strong Bull/Bear Probability = more compelling.
* High Fit Quality + split probabilities = similar markets existed, but outcomes were mixed.
* Low Fit Quality = be cautious.

---

### Model

This shows which Forecast Model is active.

Examples:

* Balanced.
* Conservative.
* Aggressive.
* Trend Following.
* Mean Reversion.

This is useful for screenshots and reviewing past setups.

---

### Anchor

This tells you where the forecast is anchored.

Examples:

* `0 bars · NR` means current forecast using Non-Repaint Mode.
* `50 bars · NR` means historical forecast from 50 bars ago.
* `Locked` means it is anchored to a specific UTC candle.

This helps you know whether you are looking at a current forecast or a historical replay.

---

### Search Depth

This shows the actual number of bars being searched.

It may be lower than your input if the chart does not have enough loaded history.

---

## Best Practical Way to Use It

A clean workflow would be:

* Start with **Balanced** model.
* Keep **Non-Repaint Mode On**.
* Use **Pattern Matches around 30**.
* Use **Search Depth around 1000**.
* Watch **Fit Quality**.
* Watch **Bull/Bear Probability**.
* Treat the forecast line as a scenario path, not a guaranteed prediction.
* Use **Lookback Bars** to test whether the forecast was historically useful.
* Avoid trusting any forecast where the bands are very wide and probabilities are split.

The strongest setup is usually when:

* Fit Quality is high.
* Bull or Bear Probability is clearly dominant.
* The forecast bands are not extremely wide.
* The projection agrees with price structure.

## Source Code

````pine
//@version=6
indicator("Market State Forecast Projection Engine", shorttitle="Forecast Engine", overlay=true, max_lines_count=500, max_bars_back=5000)

//────────────────────────────────────
// Inputs
//────────────────────────────────────
nonRepaint = input.bool(true, "Non-Repaint Mode", tooltip="When enabled, the forecast is anchored to the last fully closed candle.")

//────────────────────────────────────
// Model
//────────────────────────────────────
grpMain = "Model"

horizon = input.int(20, "Forecast Horizon", minval=1, maxval=100, group=grpMain, tooltip="Number of future bars to project.")
searchBars = input.int(1000, "Search Depth", minval=100, maxval=4000, group=grpMain, tooltip="How far back the engine searches for similar historical market states.")
patternMatches = input.int(30, "Pattern Matches", minval=5, maxval=200, group=grpMain, tooltip="Number of closest historical market-state matches to use in the forecast. The engine ranks all candidates and keeps only the closest matches.")
useWeighting = input.bool(true, "Weight Closer Matches", group=grpMain, tooltip="When enabled, closer historical state matches receive more influence in the projection.")

//────────────────────────────────────
// Advanced Model Inputs
//────────────────────────────────────
grpAdvanced = "Advanced Model Inputs"

forecastModel = input.string(
     "Balanced",
     "Forecast Model",
     options=["Conservative", "Balanced", "Aggressive", "Trend Following", "Mean Reversion"],
     group=grpAdvanced,
     tooltip="Selects the internal model used to compare market states.\n\nAll models use EMA trend, RSI momentum, and ATR volatility.\n\nConservative: EMA 34/89, RSI 21, ATR 21, higher trend + vol weight.\nBalanced: EMA 21/55, RSI 14, ATR 14, standard weights.\nAggressive: EMA 10/34, RSI 7, ATR 10, higher momentum, lower vol weight.\nTrend Following: EMA 21/100, RSI 21, ATR 14, highest trend weight.\nMean Reversion: EMA 10/34, RSI 5, ATR 14, highest momentum, lower trend weight."
)

//────────────────────────────────────
// Historical Lookback
//────────────────────────────────────
grpLookback = "Historical Lookback"

lookbackBars = input.int(0, "Lookback Bars", minval=0, maxval=2000, step=5, group=grpLookback, tooltip="Shifts the entire forecast backward in time by this many bars.")
lockCandle = input.bool(false, "Lock to Candle", group=grpLookback, tooltip="When enabled, anchors the forecast to the candle matching the selected UTC hour and minute.")
daysBack = input.int(0, "Days Back", minval=0, maxval=30, group=grpLookback, tooltip="Number of matching anchor candles to step back. 0 = most recent match.")
lockHour = input.int(13, "Hour UTC", minval=0, maxval=23, group=grpLookback, tooltip="UTC hour of the candle to anchor to.")
lockMinute = input.int(30, "Minute UTC", minval=0, maxval=59, group=grpLookback, tooltip="UTC minute of the candle to anchor to.")
autoPrevSession = input.bool(true, "Auto Previous Session", group=grpLookback, tooltip="If today's target candle has not printed, use the most recent prior matching candle.")

//────────────────────────────────────
// Bias Logic
//────────────────────────────────────
grpBias = "Bias Logic"

biasThreshold = input.float(60.0, "Bias Threshold %", minval=50.0, maxval=90.0, step=1.0, group=grpBias, tooltip="Minimum bull or bear probability required before the indicator can label the forecast Bullish or Bearish.")
edgeThreshold = input.float(15.0, "Minimum Bull/Bear Edge %", minval=0.0, maxval=50.0, step=1.0, group=grpBias, tooltip="Minimum percentage-point gap required between bull and bear probabilities.")

//────────────────────────────────────
// Display
//────────────────────────────────────
grpDisplay = "Display"

showForecast = input.bool(true, "Show Forecast Midline", group=grpDisplay)
showBands = input.bool(true, "Show Confidence Bands", group=grpDisplay)
bandMult = input.float(1.0, "Band Width Multiplier", minval=0.1, maxval=3.0, step=0.1, group=grpDisplay)

//────────────────────────────────────
// Forecast Midline
//────────────────────────────────────
grpForecast = "Forecast Midline"

midColor = input.color(color.aqua, "Color", group=grpForecast)
midWidth = input.int(3, "Width", minval=1, maxval=5, group=grpForecast)
midTypeIn = input.string("Solid", "Type", options=["Solid", "Dashed", "Dotted"], group=grpForecast)

//────────────────────────────────────
// Forecast Midline — Upper Band
//────────────────────────────────────
grpUpper = "Forecast Midline — Upper Band"

upperColor = input.color(color.new(color.lime, 25), "Color", group=grpUpper)
upperWidth = input.int(1, "Width", minval=1, maxval=5, group=grpUpper)
upperTypeIn = input.string("Dashed", "Type", options=["Solid", "Dashed", "Dotted"], group=grpUpper)

//────────────────────────────────────
// Forecast Midline — Lower Band
//────────────────────────────────────
grpLower = "Forecast Midline — Lower Band"

lowerColor = input.color(color.new(color.red, 25), "Color", group=grpLower)
lowerWidth = input.int(1, "Width", minval=1, maxval=5, group=grpLower)
lowerTypeIn = input.string("Dashed", "Type", options=["Solid", "Dashed", "Dotted"], group=grpLower)

//────────────────────────────────────
// Info Box
//────────────────────────────────────
grpInfo = "Info Box"

showInfoBox = input.bool(true, "Show Info Box", group=grpInfo)
infoBoxPosition = input.string("Bottom Left", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpInfo)
infoTextSizeIn = input.string("Tiny", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpInfo)
infoBgColor = input.color(color.new(color.black, 10), "Background", group=grpInfo)
infoBorderColor = input.color(color.new(color.gray, 20), "Border", group=grpInfo)
infoHeaderColor = input.color(color.white, "Header Text", group=grpInfo)
infoHeaderBgColor = input.color(color.new(color.blue, 20), "Header Background", group=grpInfo)

//────────────────────────────────────
// Style Mapping
//────────────────────────────────────
f_line_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_table_pos(string s) =>
    switch s
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_text_size(string s) =>
    switch s
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.tiny

midStyle = f_line_style(midTypeIn)
upperStyle = f_line_style(upperTypeIn)
lowerStyle = f_line_style(lowerTypeIn)

//────────────────────────────────────
// Helpers
//────────────────────────────────────
f_clear_lines(line[] arr) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

f_weighted_mean(array<float> vals, array<float> weights) =>
    int n = array.size(vals)
    if n == 0 or array.size(weights) != n
        na
    else
        float weightedSum = 0.0
        float weightSum = 0.0
        for i = 0 to n - 1
            float v = array.get(vals, i)
            float w = array.get(weights, i)
            weightedSum += v * w
            weightSum += w
        weightSum == 0.0 ? na : weightedSum / weightSum

f_weighted_std(array<float> vals, array<float> weights, float meanVal) =>
    int n = array.size(vals)
    if n <= 1 or na(meanVal) or array.size(weights) != n
        0.0
    else
        float weightedSq = 0.0
        float weightSum = 0.0
        for i = 0 to n - 1
            float v = array.get(vals, i)
            float w = array.get(weights, i)
            float d = v - meanVal
            weightedSq += w * d * d
            weightSum += w
        weightSum == 0.0 ? 0.0 : math.sqrt(weightedSq / weightSum)

f_array_mean(array<float> arr) =>
    int n = array.size(arr)
    if n == 0
        na
    else
        float s = 0.0
        for i = 0 to n - 1
            s += array.get(arr, i)
        s / n

//────────────────────────────────────
// Forecast Model Mapping
//────────────────────────────────────
int modelFastLen = switch forecastModel
    "Conservative" => 34
    "Aggressive" => 10
    "Trend Following" => 21
    "Mean Reversion" => 10
    => 21

int modelSlowLen = switch forecastModel
    "Conservative" => 89
    "Aggressive" => 34
    "Trend Following" => 100
    "Mean Reversion" => 34
    => 55

int modelRsiLen = switch forecastModel
    "Conservative" => 21
    "Aggressive" => 7
    "Trend Following" => 21
    "Mean Reversion" => 5
    => 14

int modelAtrLen = switch forecastModel
    "Conservative" => 21
    "Aggressive" => 10
    "Trend Following" => 14
    "Mean Reversion" => 14
    => 14

float trendWeight = switch forecastModel
    "Conservative" => 1.25
    "Aggressive" => 0.80
    "Trend Following" => 1.70
    "Mean Reversion" => 0.35
    => 1.00

float momentumWeight = switch forecastModel
    "Conservative" => 0.75
    "Aggressive" => 1.40
    "Trend Following" => 0.45
    "Mean Reversion" => 1.80
    => 1.00

float volatilityWeight = switch forecastModel
    "Conservative" => 15.0
    "Aggressive" => 5.0
    "Trend Following" => 6.0
    "Mean Reversion" => 12.0
    => 10.0

//────────────────────────────────────
// Market State Engine
//────────────────────────────────────
baseAnchor = nonRepaint ? 1 : 0

emaFast = ta.ema(close, modelFastLen)
emaSlow = ta.ema(close, modelSlowLen)
rsiVal = ta.rsi(close, modelRsiLen)
atrPct = ta.atr(modelAtrLen) / close

trendState = ((emaFast - emaSlow) / close) * trendWeight
momentumState = ((rsiVal - 50.0) / 50.0) * momentumWeight
volState = atrPct * volatilityWeight

stateScore = trendState + momentumState - volState

//────────────────────────────────────
// Lock to Candle Resolution
//────────────────────────────────────
var int[] matchedBars = array.new<int>()
var int[] matchedTimes = array.new<int>()
var int targetBarIndex = na

if lockCandle
    if hour(time, "UTC") == lockHour and minute(time, "UTC") == lockMinute
        array.push(matchedBars, bar_index)
        array.push(matchedTimes, time)
else
    array.clear(matchedBars)
    array.clear(matchedTimes)
    targetBarIndex := na

int anchorOffset = 0
string anchorStatus = ""

if lockCandle
    int totalMatches = array.size(matchedBars)
    int pickIndex = totalMatches - 1 - daysBack

    if pickIndex >= 0
        int candidateBar = array.get(matchedBars, pickIndex)
        int candidateTime = array.get(matchedTimes, pickIndex)

        bool isToday = year(candidateTime, "UTC") == year(timenow, "UTC") and month(candidateTime, "UTC") == month(timenow, "UTC") and dayofmonth(candidateTime, "UTC") == dayofmonth(timenow, "UTC")

        if not autoPrevSession and not isToday and daysBack == 0
            targetBarIndex := na
            anchorOffset := lookbackBars
            anchorStatus := "⚠ No Match"
        else
            targetBarIndex := candidateBar
            anchorOffset := bar_index - targetBarIndex
            anchorStatus := "Locked"
    else
        targetBarIndex := na
        anchorOffset := lookbackBars
        anchorStatus := "⚠ No Match"
else
    anchorOffset := lookbackBars
    anchorStatus := "Lookback"

anchor = baseAnchor + anchorOffset

currentState = stateScore[anchor]
basePrice = close[anchor]

//────────────────────────────────────
// State
//────────────────────────────────────
var line[] midLines = array.new<line>()
var line[] upperLines = array.new<line>()
var line[] lowerLines = array.new<line>()

var table infoTbl = table.new(f_table_pos(infoBoxPosition), 2, 11, border_width=1)
var string lastInfoPos = infoBoxPosition

var bool bullForecastAlert = false
var bool bearForecastAlert = false
var bool directionalForecastAlert = false

bullForecastAlert := false
bearForecastAlert := false
directionalForecastAlert := false

//────────────────────────────────────
// Execution
//────────────────────────────────────
if barstate.islast
    f_clear_lines(midLines)
    f_clear_lines(upperLines)
    f_clear_lines(lowerLines)

    if lastInfoPos != infoBoxPosition
        table.delete(infoTbl)
        infoTbl := table.new(f_table_pos(infoBoxPosition), 2, 11, border_width=1)
        lastInfoPos := infoBoxPosition

    int maxSearch = math.min(searchBars, bar_index - anchor - horizon - modelSlowLen - 5)

    selectedOffsets = array.new<int>()
    selectedDiffs = array.new<float>()

    if maxSearch > horizon and not na(currentState) and not na(basePrice)
        for off = horizon to maxSearch
            float histState = stateScore[off + anchor]
            float diff = math.abs(currentState - histState)

            if not na(histState)
                int selectedSize = array.size(selectedDiffs)
                bool inserted = false

                if selectedSize == 0
                    array.push(selectedDiffs, diff)
                    array.push(selectedOffsets, off)
                    inserted := true
                else
                    for pos = 0 to selectedSize - 1
                        if diff < array.get(selectedDiffs, pos)
                            array.insert(selectedDiffs, pos, diff)
                            array.insert(selectedOffsets, pos, off)
                            inserted := true
                            break

                    if not inserted
                        array.push(selectedDiffs, diff)
                        array.push(selectedOffsets, off)

                if array.size(selectedDiffs) > patternMatches
                    array.pop(selectedDiffs)
                    array.pop(selectedOffsets)

    int matchCount = array.size(selectedOffsets)
    int filteredOut = math.max(0, maxSearch - matchCount)

    selectedWeights = array.new<float>()

    if matchCount > 0
        for i = 0 to matchCount - 1
            float d = array.get(selectedDiffs, i)
            float w = useWeighting ? 1.0 / math.max(d, 0.0001) : 1.0
            array.push(selectedWeights, w)

    avgPath = array.new<float>()
    upperPath = array.new<float>()
    lowerPath = array.new<float>()

    int bullCount = 0
    int bearCount = 0
    int flatCount = 0

    float bullWeight = 0.0
    float bearWeight = 0.0

    if matchCount > 0
        for step = 1 to horizon
            stepReturns = array.new<float>()
            stepWeights = array.new<float>()

            for k = 0 to matchCount - 1
                int off = array.get(selectedOffsets, k)
                float w = array.get(selectedWeights, k)

                float startPrice = close[off + anchor]
                float futurePrice = close[off + anchor - step]
                float r = futurePrice / startPrice - 1.0

                array.push(stepReturns, r)
                array.push(stepWeights, w)

            float avgRet = f_weighted_mean(stepReturns, stepWeights)
            float stdRet = f_weighted_std(stepReturns, stepWeights, avgRet)

            array.push(avgPath, basePrice * (1.0 + avgRet))
            array.push(upperPath, basePrice * (1.0 + avgRet + stdRet * bandMult))
            array.push(lowerPath, basePrice * (1.0 + avgRet - stdRet * bandMult))

        for k = 0 to matchCount - 1
            int off = array.get(selectedOffsets, k)
            float w = array.get(selectedWeights, k)

            float finalStart = close[off + anchor]
            float finalEnd = close[off + anchor - horizon]
            float finalRet = finalEnd / finalStart - 1.0

            if finalRet > 0.0001
                bullCount += 1
                bullWeight += w
            else if finalRet < -0.0001
                bearCount += 1
                bearWeight += w
            else
                flatCount += 1

        if showForecast
            int linesPerStep = showBands ? 3 : 1
            int drawSteps = math.min(horizon, int(math.floor(500 / linesPerStep)))

            for i = 0 to drawSteps - 1
                int x1 = bar_index - anchor + i
                int x2 = x1 + 1

                float prevMid = i == 0 ? basePrice : array.get(avgPath, i - 1)
                float thisMid = array.get(avgPath, i)

                if not na(prevMid) and not na(thisMid)
                    array.push(midLines, line.new(x1, prevMid, x2, thisMid, color=midColor, width=midWidth, style=midStyle))

                if showBands
                    float prevUp = i == 0 ? basePrice : array.get(upperPath, i - 1)
                    float thisUp = array.get(upperPath, i)

                    float prevDn = i == 0 ? basePrice : array.get(lowerPath, i - 1)
                    float thisDn = array.get(lowerPath, i)

                    if not na(prevUp) and not na(thisUp)
                        array.push(upperLines, line.new(x1, prevUp, x2, thisUp, color=upperColor, width=upperWidth, style=upperStyle))

                    if not na(prevDn) and not na(thisDn)
                        array.push(lowerLines, line.new(x1, prevDn, x2, thisDn, color=lowerColor, width=lowerWidth, style=lowerStyle))

    float totalProbWeight = bullWeight + bearWeight
    float probBull = totalProbWeight > 0.0 ? 100.0 * bullWeight / totalProbWeight : 0.0
    float probBear = totalProbWeight > 0.0 ? 100.0 * bearWeight / totalProbWeight : 0.0

    float bullEdge = probBull - probBear
    float bearEdge = probBear - probBull

    string biasText = "None"
    color biasColor = color.yellow

    if matchCount == 0
        biasText := "No Matches"
        biasColor := color.gray
    else if matchCount < patternMatches
        biasText := "Weak Data"
        biasColor := color.orange
    else if probBull >= biasThreshold and bullEdge >= edgeThreshold
        biasText := "Bullish"
        biasColor := color.lime
    else if probBear >= biasThreshold and bearEdge >= edgeThreshold
        biasText := "Bearish"
        biasColor := color.red

    bullForecastAlert := matchCount >= patternMatches and probBull >= biasThreshold and bullEdge >= edgeThreshold
    bearForecastAlert := matchCount >= patternMatches and probBear >= biasThreshold and bearEdge >= edgeThreshold
    directionalForecastAlert := bullForecastAlert or bearForecastAlert

    float avgDiff = f_array_mean(selectedDiffs)
    float fitQuality = na(avgDiff) ? na : 100.0 / (1.0 + avgDiff)

    color bullPctColor = matchCount == 0 ? color.gray : probBull >= biasThreshold ? color.lime : color.yellow
    color bearPctColor = matchCount == 0 ? color.gray : probBear >= biasThreshold ? color.red : color.yellow
    color matchColor = matchCount >= patternMatches ? color.lime : matchCount > 0 ? color.orange : color.red
    color fitQualityColor = na(fitQuality) ? color.gray : fitQuality >= 85.0 ? color.lime : fitQuality >= 70.0 ? color.yellow : fitQuality >= 55.0 ? color.orange : color.red
    color anchorColor = lockCandle ? anchorStatus == "Locked" ? color.lime : color.orange : color.gray

    if showInfoBox
        table.cell(infoTbl, 0, 0, "Forecast Engine", text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        table.merge_cells(infoTbl, 0, 0, 1, 0)

        table.cell(infoTbl, 0, 1, "Metric", text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 1, "Value", text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 2, "Bull Prob %", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 2, str.tostring(probBull, "#.0") + "%", text_color=bullPctColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 3, "Bear Prob %", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 3, str.tostring(probBear, "#.0") + "%", text_color=bearPctColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 4, "Direction Bias", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 4, biasText, text_color=biasColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 5, "Bull/Bear/Flat", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 5, str.tostring(bullCount) + " / " + str.tostring(bearCount) + " / " + str.tostring(flatCount), text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 6, "Match Count", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 6, str.tostring(matchCount), text_color=matchColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 7, "Fit Quality", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 7, na(fitQuality) ? "n/a" : str.tostring(fitQuality, "#.0") + "%", text_color=fitQualityColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 8, "Model", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 8, forecastModel, text_color=color.aqua, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 9, "Anchor", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 9, lockCandle ? anchorStatus : str.tostring(lookbackBars) + " bars" + (nonRepaint ? " · NR" : " · Live"), text_color=anchorColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.cell(infoTbl, 0, 10, "Search Depth", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 10, str.tostring(maxSearch), text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.set_border_color(infoTbl, infoBorderColor)
        table.set_frame_color(infoTbl, infoBorderColor)
        table.set_frame_width(infoTbl, 1)
    else
        table.clear(infoTbl, 0, 0, 1, 10)

//────────────────────────────────────
// Alerts
//────────────────────────────────────
alertcondition(bullForecastAlert, "Bullish Forecast Alert", "Forecast engine bullish probability threshold and bull/bear edge requirement met.")
alertcondition(bearForecastAlert, "Bearish Forecast Alert", "Forecast engine bearish probability threshold and bull/bear edge requirement met.")
alertcondition(directionalForecastAlert, "Directional Forecast Alert", "Forecast engine bullish or bearish threshold condition met.")
````
