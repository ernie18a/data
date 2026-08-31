<!-- tradingview-pine-id: PUB;17fd544149b84c9c9c59deb3e42b1540 -->
<!-- tradingviewscripts-format: 1 -->
# Normal Heikin Ashi EMA Comparison Panel

Source: https://www.tradingview.com/script/GuVR70ZP-Normal-Heikin-Ashi-EMA-Comparison-Panel/

## Description

Normal Heikin Ashi EMA Comparison Panel
Normal Heikin Ashi EMA Comparison Panel

---

## Source Code

````pine
//@version=6
indicator(
     title = "Normal Heikin Ashi EMA Comparison Panel",
     shorttitle = "HA EMA Panel",
     overlay = false
)

//════════════════════════════════════════════════════════════
// 1. HEIKIN ASHI CANDLE SETTINGS
//════════════════════════════════════════════════════════════
string groupHA = "1. Heikin Ashi Candles"

bool showHACandles = input.bool(
     true,
     title = "Show Heikin Ashi Candles",
     group = groupHA
)

bool useTransparentCandles = input.bool(
     true,
     title = "Use Transparent HA Candles",
     group = groupHA
)

int bodyTransparency = input.int(
     20,
     title = "Body Transparency",
     minval = 0,
     maxval = 100,
     group = groupHA
)

int wickTransparency = input.int(
     0,
     title = "Wick Transparency",
     minval = 0,
     maxval = 100,
     group = groupHA
)

int borderTransparency = input.int(
     0,
     title = "Border Transparency",
     minval = 0,
     maxval = 100,
     group = groupHA
)

bool showWicks = input.bool(
     true,
     title = "Show Wicks",
     group = groupHA
)

bool showBorders = input.bool(
     true,
     title = "Show Borders",
     group = groupHA
)

//════════════════════════════════════════════════════════════
// 2. BULLISH COLORS
//════════════════════════════════════════════════════════════
string groupBull = "2. Bullish Colors"

color bullBodyColor = input.color(
     color.aqua,
     title = "Bullish Body",
     group = groupBull
)

color bullWickColor = input.color(
     color.white,
     title = "Bullish Wick",
     group = groupBull
)

color bullBorderColor = input.color(
     color.aqua,
     title = "Bullish Border",
     group = groupBull
)

//════════════════════════════════════════════════════════════
// 3. BEARISH COLORS
//════════════════════════════════════════════════════════════
string groupBear = "3. Bearish Colors"

color bearBodyColor = input.color(
     color.yellow,
     title = "Bearish Body",
     group = groupBear
)

color bearWickColor = input.color(
     color.white,
     title = "Bearish Wick",
     group = groupBear
)

color bearBorderColor = input.color(
     color.yellow,
     title = "Bearish Border",
     group = groupBear
)

//════════════════════════════════════════════════════════════
// 4. EMA SETTINGS
//════════════════════════════════════════════════════════════
string groupEMA = "4. EMA Pair"

bool showEMAs = input.bool(
     true,
     title = "Show EMA Pair",
     group = groupEMA
)

string emaPreset = input.string(
     "9 / 21",
     title = "EMA Pair",
     options = [
         "5 / 8",
         "5 / 13",
         "8 / 13",
         "9 / 21",
         "10 / 20",
         "12 / 26",
         "50 / 200",
         "100 / 200",
         "Custom"
     ],
     group = groupEMA
)

int customFastLength = input.int(
     9,
     title = "Custom Fast EMA",
     minval = 1,
     maxval = 1000,
     group = groupEMA
)

int customSlowLength = input.int(
     21,
     title = "Custom Slow EMA",
     minval = 1,
     maxval = 1000,
     group = groupEMA
)

string emaSourceChoice = input.string(
     "Heikin Ashi Close",
     title = "EMA Source",
     options = [
         "Heikin Ashi Close",
         "Regular Close"
     ],
     group = groupEMA
)

color fastEMAColor = input.color(
     color.lime,
     title = "Fast EMA Color",
     group = groupEMA
)

color slowEMAColor = input.color(
     color.blue,
     title = "Slow EMA Color",
     group = groupEMA
)

int emaWidth = input.int(
     2,
     title = "EMA Width",
     minval = 1,
     maxval = 5,
     group = groupEMA
)

int emaTransparency = input.int(
     0,
     title = "EMA Transparency",
     minval = 0,
     maxval = 100,
     group = groupEMA
)

//════════════════════════════════════════════════════════════
// 5. CROSSOVER SIGNALS
//════════════════════════════════════════════════════════════
string groupSignals = "5. EMA Cross Signals"

bool showCrossArrows = input.bool(
     true,
     title = "Show EMA Cross Arrows",
     group = groupSignals
)

bool confirmOnClose = input.bool(
     true,
     title = "Confirm Cross On Candle Close",
     group = groupSignals
)

bool useCooldown = input.bool(
     true,
     title = "Use Arrow Cooldown",
     group = groupSignals
)

int cooldownBars = input.int(
     5,
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
// NORMAL HEIKIN ASHI CALCULATION
//════════════════════════════════════════════════════════════
float haClose = (open + high + low + close) / 4.0

var float haOpen = na

haOpen := na(haOpen[1]) ?
     (open + close) / 2.0 :
     (haOpen[1] + haClose[1]) / 2.0

float haHigh = math.max(
     high,
     math.max(haOpen, haClose)
)

float haLow = math.min(
     low,
     math.min(haOpen, haClose)
)

//════════════════════════════════════════════════════════════
// CANDLE APPEARANCE
//════════════════════════════════════════════════════════════
bool isBullish = haClose >= haOpen

int activeBodyTransparency = useTransparentCandles ?
     bodyTransparency :
     0

color selectedBodyColor = isBullish ?
     color.new(bullBodyColor, activeBodyTransparency) :
     color.new(bearBodyColor, activeBodyTransparency)

color selectedWickColor = isBullish ?
     color.new(bullWickColor, wickTransparency) :
     color.new(bearWickColor, wickTransparency)

color selectedBorderColor = isBullish ?
     color.new(bullBorderColor, borderTransparency) :
     color.new(bearBorderColor, borderTransparency)

color finalWickColor = showWicks ?
     selectedWickColor :
     color.new(selectedWickColor, 100)

color finalBorderColor = showBorders ?
     selectedBorderColor :
     color.new(selectedBorderColor, 100)

//════════════════════════════════════════════════════════════
// PLOT NORMAL HEIKIN ASHI CANDLES
//════════════════════════════════════════════════════════════
plotcandle(
     showHACandles ? haOpen : na,
     showHACandles ? haHigh : na,
     showHACandles ? haLow : na,
     showHACandles ? haClose : na,
     title = "Normal Heikin Ashi",
     color = selectedBodyColor,
     wickcolor = finalWickColor,
     bordercolor = finalBorderColor
)

//════════════════════════════════════════════════════════════
// RESOLVE EMA PRESET
//════════════════════════════════════════════════════════════
int selectedFastLength = switch emaPreset
    "5 / 8"     => 5
    "5 / 13"    => 5
    "8 / 13"    => 8
    "9 / 21"    => 9
    "10 / 20"   => 10
    "12 / 26"   => 12
    "50 / 200"  => 50
    "100 / 200" => 100
    => customFastLength

int selectedSlowLength = switch emaPreset
    "5 / 8"     => 8
    "5 / 13"    => 13
    "8 / 13"    => 13
    "9 / 21"    => 21
    "10 / 20"   => 20
    "12 / 26"   => 26
    "50 / 200"  => 200
    "100 / 200" => 200
    => customSlowLength

int fastLength = math.min(
     selectedFastLength,
     selectedSlowLength
)

int slowLength = math.max(
     selectedFastLength,
     selectedSlowLength
)

//════════════════════════════════════════════════════════════
// EMA CALCULATIONS
//════════════════════════════════════════════════════════════
float emaSource = emaSourceChoice == "Heikin Ashi Close" ?
     haClose :
     close

float fastEMA = ta.ema(
     emaSource,
     fastLength
)

float slowEMA = ta.ema(
     emaSource,
     slowLength
)

//════════════════════════════════════════════════════════════
// PLOT ONLY THE SELECTED EMA PAIR
//════════════════════════════════════════════════════════════
plot(
     showEMAs ? fastEMA : na,
     title = "Fast HA EMA",
     color = color.new(fastEMAColor, emaTransparency),
     linewidth = emaWidth
)

plot(
     showEMAs ? slowEMA : na,
     title = "Slow HA EMA",
     color = color.new(slowEMAColor, emaTransparency),
     linewidth = emaWidth
)

//════════════════════════════════════════════════════════════
// CONFIRMED CROSSOVER CONDITIONS
//════════════════════════════════════════════════════════════
bool confirmed = not confirmOnClose or barstate.isconfirmed

bool rawBullCross =
     ta.crossover(fastEMA, slowEMA) and
     confirmed

bool rawBearCross =
     ta.crossunder(fastEMA, slowEMA) and
     confirmed

//════════════════════════════════════════════════════════════
// ARROW COOLDOWN
//════════════════════════════════════════════════════════════
var int lastArrowBar = na

bool cooldownPassed =
     not useCooldown or
     na(lastArrowBar) or
     bar_index - lastArrowBar >= cooldownBars

bool bullCross =
     rawBullCross and
     cooldownPassed

bool bearCross =
     rawBearCross and
     cooldownPassed

if bullCross or bearCross
    lastArrowBar := bar_index

//════════════════════════════════════════════════════════════
// SMALL CROSSOVER ARROWS
//════════════════════════════════════════════════════════════
plotshape(
     showCrossArrows and bullCross,
     title = "Bullish HA EMA Cross",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullArrowColor,
     size = size.tiny
)

plotshape(
     showCrossArrows and bearCross,
     title = "Bearish HA EMA Cross",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearArrowColor,
     size = size.tiny
)

//════════════════════════════════════════════════════════════
// ALERT CONDITIONS
//════════════════════════════════════════════════════════════
alertcondition(
     enableCrossAlerts and bullCross,
     title = "Bullish Normal HA EMA Cross",
     message = "The fast Heikin Ashi EMA crossed above the slow EMA on {{ticker}} — {{interval}}."
)

alertcondition(
     enableCrossAlerts and bearCross,
     title = "Bearish Normal HA EMA Cross",
     message = "The fast Heikin Ashi EMA crossed below the slow EMA on {{ticker}} — {{interval}}."
)

//════════════════════════════════════════════════════════════
// DYNAMIC COMBINED ALERTS
// Select “Any alert() function call”
//════════════════════════════════════════════════════════════
if enableCrossAlerts and bullCross
    alert(
         "Bullish Normal HA EMA cross " +
         str.tostring(fastLength) +
         "/" +
         str.tostring(slowLength) +
         " — " +
         syminfo.ticker +
         " — " +
         timeframe.period,
         alert.freq_once_per_bar_close
    )

if enableCrossAlerts and bearCross
    alert(
         "Bearish Normal HA EMA cross " +
         str.tostring(fastLength) +
         "/" +
         str.tostring(slowLength) +
         " — " +
         syminfo.ticker +
         " — " +
         timeframe.period,
         alert.freq_once_per_bar_close
    )
````
