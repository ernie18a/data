# AA Momentum Confirmation Engine

- url: https://www.tradingview.com/script/vECSvoX6-AA-Momentum-Confirmation-Engine/
- type: indicator
- pine_id: PUB;d355b0c6f3194a589c755a985bb1deab
- version: 3.0

## Description

AA Momentum Confirmation Engine
AA MCE IND is a trend-following indicator designed to simplify market momentum and structure analysis directly on the chart. The script combines Hull Moving Average dynamics with EMA trend confirmation to identify bullish and bearish market phases while maintaining a clean and easy-to-read visual layout.

The main purpose of this indicator is to reduce unnecessary chart noise and focus on the beginning of new momentum phases. Instead of generating repetitive signals throughout an ongoing trend, BUY and SELL labels appear only on the first confirmed candle of a new bullish or bearish regime.

━━━━━━━━━━━━━━━━━━
🔹 How the Indicator Works
━━━━━━━━━━━━━━━━━━

The indicator combines three core components:

• Hull Moving Average (HMA)
Used to determine market direction and trend acceleration through Hull slope analysis.

• Fast EMA and Slow EMA Confirmation
Trend conditions are additionally filtered using the relationship between fast and slow EMA values.

• Hull Acceleration Logic
Beyond simple trend direction, the script also evaluates Hull slope acceleration to help filter weaker or indecisive market movements.

Bullish conditions:

Price above Hull MA
Fast EMA above Slow EMA
Positive and rising Hull slope

Bearish conditions:

Price below Hull MA
Fast EMA below Slow EMA
Negative and falling Hull slope

━━━━━━━━━━━━━━━━━━
🔹 BUY and SELL Signals
━━━━━━━━━━━━━━━━━━

BUY signals appear only on the first green candle after transitioning into a bullish regime.

SELL signals appear only on the first red candle after transitioning into a bearish regime.

This approach helps reduce repeated signals during strong trends and keeps the chart visually cleaner and easier to interpret.

━━━━━━━━━━━━━━━━━━
🔹 Visual Features
━━━━━━━━━━━━━━━━━━

• Automatic candle coloring based on trend direction
• Optional Hull MA visualization
• Optional Fast and Slow EMA display
• BUY/SELL label signals
• Built-in alert support
• Confirmed candle close logic for more stable signals

━━━━━━━━━━━━━━━━━━
🔹 Indicator Usage
━━━━━━━━━━━━━━━━━━

The indicator can be useful for:

Trend confirmation
Momentum trading
Swing trading
Trend continuation setups
Filtering noisy market conditions

The script performs best in trending market environments. During strong sideways conditions, more frequent regime changes may occur, which is normal behavior for most trend-following indicators.

━━━━━━━━━━━━━━━━━━
🔹 Important Note
━━━━━━━━━━━━━━━━━━

This script uses confirmed candle close conditions and does not rely on repainting signal logic after bar close. However, the indicator is not intended to be a complete trading system or financial advice.

Always combine it with additional market analysis, price action confirmation, and proper risk management.

## Source Code

````pine
//@version=6
indicator("AA MCE IND", shorttitle="AA MCE IND", overlay=true)

//====================================================
// INPUTS
//====================================================

// HULL
hmaLen = input.int(20, "Hull Length")

// EMA
emaFastLen = input.int(5, "Fast EMA")
emaSlowLen = input.int(7, "Slow EMA")

// CONFIRMATION MODE
useConfirmed = input.bool(false, "Use Candle Close Confirmation")

// VISUALS
showEMA   = input.bool(false, "Show EMA")
showHull  = input.bool(true, "Show Hull")
paintBars = input.bool(true, "Paint Bars")

// SIGNALS
showSignals = input.bool(true, "Show BUY/SELL Signals")

//====================================================
// CUSTOM COLORS
//====================================================

bullColor    = input.color(color.lime, "Bullish Candle Color")
bearColor    = input.color(color.red, "Bearish Candle Color")
neutralColor = input.color(color.rgb(57, 57, 58), "Neutral Candle Color")

hullBullColor = input.color(color.rgb(72, 255, 0), "Hull Bull Color")
hullBearColor = input.color(color.red, "Hull Bear Color")

//====================================================
// HULL MA
//====================================================

hma(src, len) =>
    ta.wma(
         2 * ta.wma(src, math.round(len / 2)) -
         ta.wma(src, len),
         math.round(math.sqrt(len))
     )

hull = hma(close, hmaLen)

hullSlope = hull - hull[1]

//====================================================
// HULL ACCELERATION
//====================================================

bullAccel =
     hullSlope > hullSlope[1] and
     hullSlope > 0

bearAccel =
     hullSlope < hullSlope[1] and
     hullSlope < 0

//====================================================
// EMA
//====================================================

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

//====================================================
// TREND FILTER
//====================================================

bullTrend =
     close > hull and
     emaFast > emaSlow

bearTrend =
     close < hull and
     emaFast < emaSlow

//====================================================
// CONFIRMATION FILTER
//====================================================

confirmFilter =
     not useConfirmed or barstate.isconfirmed

//====================================================
// FINAL CONDITIONS
//====================================================

bullCondition =
     bullTrend and
     bullAccel and
     confirmFilter

bearCondition =
     bearTrend and
     bearAccel and
     confirmFilter

//====================================================
// SIGNAL FILTER LOGIC
//====================================================

//  1  = poslednji signal BUY
// -1  = poslednji signal SELL
//  0  = nema signala još

var int lastSignal = 0

// Osnovni signal
rawBuySignal =
     bullCondition and
     not bullCondition[1]

rawSellSignal =
     bearCondition and
     not bearCondition[1]

// Finalni signal:
// BUY se prikazuje samo ako poslednji signal nije BUY
// SELL se prikazuje samo ako poslednji signal nije SELL

buySignal =
     rawBuySignal and
     lastSignal != 1

sellSignal =
     rawSellSignal and
     lastSignal != -1

// Update poslednjeg signala
if buySignal
    lastSignal := 1

if sellSignal
    lastSignal := -1

//====================================================
// TREND COLORS
//====================================================

trendColor =
     bullCondition ? bullColor :
     bearCondition ? bearColor :
     neutralColor

hullColor =
     bullCondition ? hullBullColor :
     bearCondition ? hullBearColor :
     neutralColor

//====================================================
// VISUALS
//====================================================

// BAR COLORS
barcolor(
     paintBars
     ? trendColor
     : na)

// HULL
plot(
     showHull ? hull : na,
     color = hullColor,
     linewidth = 3,
     title = "Hull")

// EMA
plot(
     showEMA ? emaFast : na,
     color = color.orange,
     linewidth = 2,
     title = "EMA Fast")

plot(
     showEMA ? emaSlow : na,
     color = color.blue,
     linewidth = 2,
     title = "EMA Slow")

//====================================================
// BUY / SELL SIGNALS
//====================================================

plotshape(
     showSignals and buySignal,
     title = "BUY",
     style = shape.labelup,
     location = location.belowbar,
     color = color.lime,
     text = "BUY",
     textcolor = color.black,
     size = size.small)

plotshape(
     showSignals and sellSignal,
     title = "SELL",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     text = "SELL",
     textcolor = color.white,
     size = size.small)

//====================================================
// ALERTS
//====================================================

alertcondition(
     buySignal,
     title = "BUY Signal",
     message = "AA MCE IND BUY Signal")

alertcondition(
     sellSignal,
     title = "SELL Signal",
     message = "AA MCE IND SELL Signal")

//====================================================
````
