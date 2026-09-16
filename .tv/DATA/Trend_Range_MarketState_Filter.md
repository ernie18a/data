<!-- tradingview-pine-id: PUB;3e2d9fde0c524861825d5efef697b120 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend / Range Market-State Filter

Source: https://www.tradingview.com/script/kT81GU6l-TRMSF-Trend-Range-Market-State-Filter-v1-0/

## Description

The Trend / Range Market-State Filter is a TradingView Pine Script indicator designed to label XAUUSD and BTCUSD market conditions as BULLISH, BEARISH, or SIDEWAY. It gives your webhook system a market-state rule that decides whether BUY and SELL signals should be delivered to the Telegram group or paused.

The script combines two technical tools. First, it uses the Directional Movement Index (DMI). DMI provides the Average Directional Index (ADX), which measures trend strength, plus the positive and negative Directional Indicators (+DI and -DI), which indicate directional pressure. A BULLISH condition requires ADX to be above the trend threshold and +DI to be above -DI. A BEARISH condition requires ADX above the trend threshold and -DI above +DI. The default trend-strength threshold is ADX above 25.

Second, the script optionally uses the Choppiness Index (CHOP). CHOP does not determine bullish or bearish direction. Instead, it checks whether price action is relatively directional or ranging. Low CHOP readings support a trend, while high readings support a sideways market. With the default settings, CHOP below 38.2 confirms a directional trend and CHOP above 61.8 supports a SIDEWAY classification.

The script labels a market SIDEWAY when ADX is below 20 or CHOP is high. It intentionally keeps the last market state when readings fall in the middle zone, such as ADX between 20 and 25. This prevents frequent switching between states when the indicators hover near their thresholds.

A state change is confirmed only at the close of a candle. When the state changes, TradingView can send one of six exact webhook messages: BULLISH, BEARISH, or SIDEWAY for either XAUUSD or BTCUSD. BULLISH and BEARISH pause BUY/SELL messages for it; SIDEWAY re-enables them. XAUUSD and BTCUSD remain independent, so a BTCUSD pause does not affect XAUUSD signals.

---

## Source Code

````pine
//@version=6
indicator("Trend / Range Market-State Filter", shorttitle = "TR State", overlay = true, max_labels_count = 100)

// =============================================================================
// PURPOSE
// =============================================================================
// Classifies an XAUUSD or BTCUSD chart as BULLISH, BEARISH, or SIDEWAY.
// It sends an alert only when the classified state changes on a confirmed bar.
//
// Classification:
// • BULLISH: ADX is strong, +DI is above -DI, and CHOP confirms a trend.
// • BEARISH: ADX is strong, -DI is above +DI, and CHOP confirms a trend.
// • SIDEWAY: ADX is weak OR CHOP confirms a choppy/ranging market.
// • NEUTRAL: the state is retained between the configured thresholds, helping
//   prevent repeated BULLISH/BEARISH/SIDEWAY flips near a boundary.
//
// Create this indicator separately on an XAUUSD chart and on a BTCUSD chart.
// TradingView will expose all six named alert conditions. Only the three that
// match the active chart's symbol can trigger.

// =============================================================================
// INPUTS
// =============================================================================
groupDmi = "DMI / ADX settings"
diLength = input.int(14, "DI length", minval = 1, group = groupDmi)
adxSmoothing = input.int(14, "ADX smoothing", minval = 1, group = groupDmi)
trendAdxThreshold = input.float(25.0, "Minimum ADX for BULLISH / BEARISH", minval = 1.0, maxval = 100.0, step = 0.5, group = groupDmi)
sidewayAdxThreshold = input.float(20.0, "Maximum ADX for SIDEWAY", minval = 1.0, maxval = 100.0, step = 0.5, group = groupDmi)

groupChop = "Choppiness Index settings"
useChopConfirmation = input.bool(true, "Use CHOP confirmation", group = groupChop)
chopLength = input.int(14, "CHOP length", minval = 2, group = groupChop)
trendChopThreshold = input.float(38.2, "Maximum CHOP for BULLISH / BEARISH", minval = 0.0, maxval = 100.0, step = 0.1, group = groupChop)
sidewayChopThreshold = input.float(61.8, "Minimum CHOP for SIDEWAY", minval = 0.0, maxval = 100.0, step = 0.1, group = groupChop)

groupDisplay = "Display"
showBackground = input.bool(true, "Colour chart background", group = groupDisplay)
showStateTable = input.bool(true, "Show state table", group = groupDisplay)

// =============================================================================
// CALCULATIONS
// =============================================================================
[plusDI, minusDI, adx] = ta.dmi(diLength, adxSmoothing)

// Choppiness Index (CHOP): high readings indicate a range; low readings
// indicate directional/trending movement.
trSum = math.sum(ta.tr(true), chopLength)
priceRange = ta.highest(high, chopLength) - ta.lowest(low, chopLength)
chop = priceRange > 0 ? 100 * math.log10(trSum / priceRange) / math.log10(chopLength) : na

// Identify the chart symbol. syminfo.ticker excludes the exchange prefix.
chartTicker = str.upper(syminfo.ticker)
isXauUsd = str.contains(chartTicker, "XAUUSD")
isBtcUsd = str.contains(chartTicker, "BTCUSD")
isSupportedSymbol = isXauUsd or isBtcUsd

// SIDEWAY takes priority whenever the market is explicitly weak or choppy.
chopTrendConfirmed = not useChopConfirmation or (not na(chop) and chop < trendChopThreshold)
chopSidewayConfirmed = useChopConfirmation and not na(chop) and chop > sidewayChopThreshold

isSideway = adx < sidewayAdxThreshold or chopSidewayConfirmed
isBullish = not isSideway and adx > trendAdxThreshold and plusDI > minusDI and chopTrendConfirmed
isBearish = not isSideway and adx > trendAdxThreshold and minusDI > plusDI and chopTrendConfirmed

// State codes: 1 = BULLISH, -1 = BEARISH, 0 = SIDEWAY.
var int marketState = 0
int nextState = isBullish ? 1 : isBearish ? -1 : isSideway ? 0 : marketState

// Update only once a candle closes. This avoids state changes based on an
// unconfirmed live candle that can later reverse.
if barstate.isconfirmed
    marketState := nextState

stateChanged = barstate.isconfirmed and marketState != marketState[1]
bullishChanged = stateChanged and marketState == 1
bearishChanged = stateChanged and marketState == -1
sidewayChanged = stateChanged and marketState == 0

xauBullishAlert = isXauUsd and bullishChanged
xauBearishAlert = isXauUsd and bearishChanged
xauSidewayAlert = isXauUsd and sidewayChanged
btcBullishAlert = isBtcUsd and bullishChanged
btcBearishAlert = isBtcUsd and bearishChanged
btcSidewayAlert = isBtcUsd and sidewayChanged

// =============================================================================
// WEBHOOK ALERT CONDITIONS
// =============================================================================
// Create three alerts on the XAUUSD chart and three on the BTCUSD chart.
// Each alert sends the exact plain-text message that your webhook server expects.
alertcondition(xauBullishAlert, title = "XAUUSD Market turned BULLISH", message = "XAUUSD Market turned BULLISH")
alertcondition(xauBearishAlert, title = "XAUUSD Market turned BEARISH", message = "XAUUSD Market turned BEARISH")
alertcondition(xauSidewayAlert, title = "XAUUSD Market entered SIDEWAY", message = "XAUUSD Market entered SIDEWAY")
alertcondition(btcBullishAlert, title = "BTCUSD Market turned BULLISH", message = "BTCUSD Market turned BULLISH")
alertcondition(btcBearishAlert, title = "BTCUSD Market turned BEARISH", message = "BTCUSD Market turned BEARISH")
alertcondition(btcSidewayAlert, title = "BTCUSD Market entered SIDEWAY", message = "BTCUSD Market entered SIDEWAY")

// =============================================================================
// CHART DISPLAY
// =============================================================================
stateText = marketState == 1 ? "BULLISH" : marketState == -1 ? "BEARISH" : "SIDEWAY"
stateColor = marketState == 1 ? color.lime : marketState == -1 ? color.red : color.aqua
bgColour = marketState == 1 ? color.new(color.green, 90) : marketState == -1 ? color.new(color.red, 90) : color.new(color.blue, 92)

bgcolor(showBackground and isSupportedSymbol ? bgColour : na, title = "Market State Background")
plotshape(xauBullishAlert or btcBullishAlert, title = "Market turned BULLISH", style = shape.labelup, location = location.belowbar, color = color.green, text = "BULL", textcolor = color.white, size = size.tiny)
plotshape(xauBearishAlert or btcBearishAlert, title = "Market turned BEARISH", style = shape.labeldown, location = location.abovebar, color = color.red, text = "BEAR", textcolor = color.white, size = size.tiny)
plotshape(xauSidewayAlert or btcSidewayAlert, title = "Market entered SIDEWAY", style = shape.labeldown, location = location.abovebar, color = color.blue, text = "RANGE", textcolor = color.white, size = size.tiny)

var table stateTable = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast and showStateTable
    table.cell(stateTable, 0, 0, "Market State", text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 1, 0, isSupportedSymbol ? stateText : "UNSUPPORTED", text_color = color.white, bgcolor = isSupportedSymbol ? stateColor : color.gray)
    table.cell(stateTable, 0, 1, "ADX", text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 1, 1, str.tostring(adx, "#.0"), text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 0, 2, "+DI / -DI", text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 1, 2, str.tostring(plusDI, "#.0") + " / " + str.tostring(minusDI, "#.0"), text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 0, 3, "CHOP", text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 1, 3, str.tostring(chop, "#.0"), text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 0, 4, "Symbol", text_color = color.white, bgcolor = color.black)
    table.cell(stateTable, 1, 4, chartTicker, text_color = color.white, bgcolor = color.black)
````
