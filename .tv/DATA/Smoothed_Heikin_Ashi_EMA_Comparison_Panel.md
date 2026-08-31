<!-- tradingview-pine-id: PUB;64c300ec121d404d968a042c2bce12f1 -->
<!-- tradingviewscripts-format: 1 -->
# Smoothed Heikin Ashi EMA Comparison Panel

Source: https://www.tradingview.com/script/k0hMrHAZ-Smoothed-Heikin-Ashi-EMA-Comparison-Panel/

## Description

Smoothed Heikin Ashi EMA Comparison Panel
Smoothed Heikin Ashi EMA Comparison Panel

---

## Source Code

````pine
//@version=6
indicator(
     title = "Smoothed Heikin Ashi EMA Comparison Panel",
     shorttitle = "Smoothed HA EMA Panel",
     overlay = false
)

//════════════════════════════════════════════════════════════
// SMOOTHED HEIKIN ASHI SETTINGS
//════════════════════════════════════════════════════════════
string groupHA = "1. Smoothed Heikin Ashi"

int firstSmoothing = input.int(
     10,
     title = "First EMA Smoothing",
     minval = 1,
     group = groupHA
)

int secondSmoothing = input.int(
     10,
     title = "Second EMA Smoothing",
     minval = 1,
     group = groupHA
)

bool showWicks = input.bool(
     true,
     title = "Show Wicks",
     group = groupHA
)

bool showBorders = input.bool(
     true,
     title = "Show Candle Borders",
     group = groupHA
)

//════════════════════════════════════════════════════════════
// BULLISH CANDLE COLORS
//════════════════════════════════════════════════════════════
string groupBull = "2. Bullish Candle Colors"

color bullBodyColor = input.color(
     color.lime,
     title = "Bullish Body",
     group = groupBull
)

color bullWickColor = input.color(
     color.lime,
     title = "Bullish Wick",
     group = groupBull
)

color bullBorderColor = input.color(
     color.lime,
     title = "Bullish Border",
     group = groupBull
)

int bullBodyTransparency = input.int(
     10,
     title = "Bullish Body Transparency",
     minval = 0,
     maxval = 100,
     group = groupBull
)

int bullWickTransparency = input.int(
     0,
     title = "Bullish Wick Transparency",
     minval = 0,
     maxval = 100,
     group = groupBull
)

int bullBorderTransparency = input.int(
     0,
     title = "Bullish Border Transparency",
     minval = 0,
     maxval = 100,
     group = groupBull
)

//════════════════════════════════════════════════════════════
// BEARISH CANDLE COLORS
//════════════════════════════════════════════════════════════
string groupBear = "3. Bearish Candle Colors"

color bearBodyColor = input.color(
     color.red,
     title = "Bearish Body",
     group = groupBear
)

color bearWickColor = input.color(
     color.red,
     title = "Bearish Wick",
     group = groupBear
)

color bearBorderColor = input.color(
     color.red,
     title = "Bearish Border",
     group = groupBear
)

int bearBodyTransparency = input.int(
     10,
     title = "Bearish Body Transparency",
     minval = 0,
     maxval = 100,
     group = groupBear
)

int bearWickTransparency = input.int(
     0,
     title = "Bearish Wick Transparency",
     minval = 0,
     maxval = 100,
     group = groupBear
)

int bearBorderTransparency = input.int(
     0,
     title = "Bearish Border Transparency",
     minval = 0,
     maxval = 100,
     group = groupBear
)

//════════════════════════════════════════════════════════════
// EMA PRESET SETTINGS
//════════════════════════════════════════════════════════════
string groupEMA = "4. EMA Settings"

bool showEMAs = input.bool(
     true,
     title = "Show EMA Pair",
     group = groupEMA
)

string emaPreset = input.string(
     "5 / 13",
     title = "EMA Pair",
     options = [
         "5 / 8",
         "5 / 13",
         "8 / 13",
         "9 / 21",
         "10 / 20",
         "12 / 26",
         "100 / 200",
         "Custom"
     ],
     group = groupEMA
)

int customFastLength = input.int(
     5,
     title = "Custom Fast EMA",
     minval = 1,
     maxval = 1000,
     group = groupEMA
)

int customSlowLength = input.int(
     13,
     title = "Custom Slow EMA",
     minval = 1,
     maxval = 1000,
     group = groupEMA
)

color fastEMAColor = input.color(
     color.aqua,
     title = "Fast EMA Color",
     group = groupEMA
)

color slowEMAColor = input.color(
     color.orange,
     title = "Slow EMA Color",
     group = groupEMA
)

int fastEMATransparency = input.int(
     0,
     title = "Fast EMA Transparency",
     minval = 0,
     maxval = 100,
     group = groupEMA
)

int slowEMATransparency = input.int(
     0,
     title = "Slow EMA Transparency",
     minval = 0,
     maxval = 100,
     group = groupEMA
)

int fastEMAWidth = input.int(
     2,
     title = "Fast EMA Width",
     minval = 1,
     maxval = 5,
     group = groupEMA
)

int slowEMAWidth = input.int(
     2,
     title = "Slow EMA Width",
     minval = 1,
     maxval = 5,
     group = groupEMA
)

//════════════════════════════════════════════════════════════
// CROSSOVER ARROWS AND ALERTS
//════════════════════════════════════════════════════════════
string groupSignals = "5. EMA Cross Signals"

bool showCrossArrows = input.bool(
     true,
     title = "Show Small Cross Arrows",
     group = groupSignals
)

bool confirmOnClose = input.bool(
     true,
     title = "Confirm Cross After Candle Closes",
     group = groupSignals
)

bool useCooldown = input.bool(
     true,
     title = "Use Arrow Cooldown",
     group = groupSignals
)

int cooldownBars = input.int(
     8,
     title = "Minimum Bars Between Arrows",
     minval = 1,
     maxval = 100,
     group = groupSignals
)

color bullArrowColor = input.color(
     color.lime,
     title = "Bullish Arrow Color",
     group = groupSignals
)

color bearArrowColor = input.color(
     color.red,
     title = "Bearish Arrow Color",
     group = groupSignals
)

bool enableCrossAlerts = input.bool(
     true,
     title = "Enable EMA Cross Alerts",
     group = groupSignals
)

//════════════════════════════════════════════════════════════
// FIRST PRICE SMOOTHING
// Matches the original Smoothed Heikin Ashi method
//════════════════════════════════════════════════════════════
float smoothedOpen = ta.ema(open, firstSmoothing)
float smoothedHigh = ta.ema(high, firstSmoothing)
float smoothedLow = ta.ema(low, firstSmoothing)
float smoothedClose = ta.ema(close, firstSmoothing)

//════════════════════════════════════════════════════════════
// HEIKIN ASHI CALCULATION
//════════════════════════════════════════════════════════════
float haClose = (
     smoothedOpen +
     smoothedHigh +
     smoothedLow +
     smoothedClose
) / 4.0

var float haOpen = na

haOpen := na(haOpen[1]) ?
     (smoothedOpen + smoothedClose) / 2.0 :
     (haOpen[1] + haClose[1]) / 2.0

float haHigh = math.max(
     smoothedHigh,
     math.max(haOpen, haClose)
)

float haLow = math.min(
     smoothedLow,
     math.min(haOpen, haClose)
)

//════════════════════════════════════════════════════════════
// SECOND SMOOTHING
//════════════════════════════════════════════════════════════
float finalOpen = ta.ema(haOpen, secondSmoothing)
float finalHigh = ta.ema(haHigh, secondSmoothing)
float finalLow = ta.ema(haLow, secondSmoothing)
float finalClose = ta.ema(haClose, secondSmoothing)

//════════════════════════════════════════════════════════════
// CANDLE DIRECTION AND APPEARANCE
//════════════════════════════════════════════════════════════
bool isBullish = finalClose >= finalOpen

color selectedBodyColor = isBullish ?
     color.new(bullBodyColor, bullBodyTransparency) :
     color.new(bearBodyColor, bearBodyTransparency)

color selectedWickColor = isBullish ?
     color.new(bullWickColor, bullWickTransparency) :
     color.new(bearWickColor, bearWickTransparency)

color selectedBorderColor = isBullish ?
     color.new(bullBorderColor, bullBorderTransparency) :
     color.new(bearBorderColor, bearBorderTransparency)

color finalWickColor = showWicks ?
     selectedWickColor :
     color.new(selectedWickColor, 100)

color finalBorderColor = showBorders ?
     selectedBorderColor :
     color.new(selectedBorderColor, 100)

//════════════════════════════════════════════════════════════
// PLOT SMOOTHED HEIKIN ASHI CANDLES
//════════════════════════════════════════════════════════════
plotcandle(
     finalOpen,
     finalHigh,
     finalLow,
     finalClose,
     title = "Smoothed Heikin Ashi",
     color = selectedBodyColor,
     wickcolor = finalWickColor,
     bordercolor = finalBorderColor
)

//════════════════════════════════════════════════════════════
// RESOLVE EMA PRESET
//════════════════════════════════════════════════════════════
int fastLength = switch emaPreset
    "5 / 8"     => 5
    "5 / 13"    => 5
    "8 / 13"    => 8
    "9 / 21"    => 9
    "10 / 20"   => 10
    "12 / 26"   => 12
    "100 / 200" => 100
    => customFastLength

int slowLength = switch emaPreset
    "5 / 8"     => 8
    "5 / 13"    => 13
    "8 / 13"    => 13
    "9 / 21"    => 21
    "10 / 20"   => 20
    "12 / 26"   => 26
    "100 / 200" => 200
    => customSlowLength

// Prevent an accidental reversed Custom pair
int resolvedFastLength = math.min(fastLength, slowLength)
int resolvedSlowLength = math.max(fastLength, slowLength)

//════════════════════════════════════════════════════════════
// EMA CALCULATIONS
// Calculated from the final Smoothed HA close
//════════════════════════════════════════════════════════════
float fastEMA = ta.ema(finalClose, resolvedFastLength)
float slowEMA = ta.ema(finalClose, resolvedSlowLength)

//════════════════════════════════════════════════════════════
// PLOT SELECTED EMA PAIR
// Only two EMA lines are drawn
//════════════════════════════════════════════════════════════
plot(
     showEMAs ? fastEMA : na,
     title = "Fast Smoothed HA EMA",
     color = color.new(fastEMAColor, fastEMATransparency),
     linewidth = fastEMAWidth
)

plot(
     showEMAs ? slowEMA : na,
     title = "Slow Smoothed HA EMA",
     color = color.new(slowEMAColor, slowEMATransparency),
     linewidth = slowEMAWidth
)

//════════════════════════════════════════════════════════════
// CONFIRMED EMA CROSSOVER CONDITIONS
//════════════════════════════════════════════════════════════
bool confirmed = not confirmOnClose or barstate.isconfirmed

bool rawBullCross = ta.crossover(fastEMA, slowEMA) and confirmed
bool rawBearCross = ta.crossunder(fastEMA, slowEMA) and confirmed

//════════════════════════════════════════════════════════════
// ARROW COOLDOWN
//════════════════════════════════════════════════════════════
var int lastArrowBar = na

bool cooldownPassed =
     not useCooldown or
     na(lastArrowBar) or
     bar_index - lastArrowBar >= cooldownBars

bool bullCross = rawBullCross and cooldownPassed
bool bearCross = rawBearCross and cooldownPassed

if bullCross or bearCross
    lastArrowBar := bar_index

//════════════════════════════════════════════════════════════
// SMALL CROSSOVER ARROWS
//════════════════════════════════════════════════════════════
plotshape(
     showCrossArrows and bullCross,
     title = "Bullish EMA Cross",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullArrowColor,
     size = size.tiny
)

plotshape(
     showCrossArrows and bearCross,
     title = "Bearish EMA Cross",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearArrowColor,
     size = size.tiny
)

//════════════════════════════════════════════════════════════
// INDIVIDUAL TRADINGVIEW ALERT CONDITIONS
//════════════════════════════════════════════════════════════
alertcondition(
     enableCrossAlerts and bullCross,
     title = "Bullish Smoothed HA EMA Cross",
     message = "The fast Smoothed Heikin Ashi EMA crossed above the slow EMA on {{ticker}} — {{interval}}."
)

alertcondition(
     enableCrossAlerts and bearCross,
     title = "Bearish Smoothed HA EMA Cross",
     message = "The fast Smoothed Heikin Ashi EMA crossed below the slow EMA on {{ticker}} — {{interval}}."
)

//════════════════════════════════════════════════════════════
// COMBINED DYNAMIC ALERTS
// Select “Any alert() function call” in TradingView
//════════════════════════════════════════════════════════════
if enableCrossAlerts and bullCross
    alert(
         "Bullish Smoothed HA EMA cross " +
         str.tostring(resolvedFastLength) +
         "/" +
         str.tostring(resolvedSlowLength) +
         " — " +
         syminfo.ticker +
         " — " +
         timeframe.period,
         alert.freq_once_per_bar_close
    )

if enableCrossAlerts and bearCross
    alert(
         "Bearish Smoothed HA EMA cross " +
         str.tostring(resolvedFastLength) +
         "/" +
         str.tostring(resolvedSlowLength) +
         " — " +
         syminfo.ticker +
         " — " +
         timeframe.period,
         alert.freq_once_per_bar_close
    )
````
