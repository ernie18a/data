<!-- tradingview-pine-id: PUB;e190621dbf5148d1af03afbd50b45fb1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trading ATR Framework – NQ / GC / CL

Source: https://www.tradingview.com/script/DmF840z0/

## Description

# Trading ATR Framework

**Trading ATR Framework** is a rule-based volatility and market-location tool designed primarily for intraday futures trading.

The purpose of the indicator is not to generate automatic buy or sell signals. Instead, it provides a structured way to measure how far the current market has moved relative to its recent daily volatility and to identify predefined volatility expansion zones.

## Core Concept

The framework uses two main reference values:

1. **Previous Daily Close**
   The previous completed trading day's close is used as the default reference price.

2. **Daily ATR(14)**
   The indicator calculates the Average True Range over the last 14 completed daily bars. ATR measures the average daily price range and is used as a volatility reference.

From these two values, the indicator projects symmetrical volatility levels above and below the reference price.

The calculated levels are:

* +25% ATR
* +50% ATR
* +75% ATR
* +100% ATR
* -25% ATR
* -50% ATR
* -75% ATR
* -100% ATR

For example, if the previous daily close is 20,000 and the completed Daily ATR(14) is 400 points, the +25% ATR level would be:

**20,000 + (400 × 0.25) = 20,100**

The -50% ATR level would be:

**20,000 - (400 × 0.50) = 19,800**

This creates a standardized volatility map around the previous session's closing price.

## Why I Created This Framework

Many intraday traders evaluate price levels without considering how far the market has already travelled relative to its normal daily volatility.

This framework combines:

* previous-session price anchoring,
* completed Daily ATR volatility,
* fractional ATR expansion levels,
* tick-size normalization,
* directional location,
* and risk-to-reward calculations

into one visual framework.

The goal is to make market location more objective.

Instead of simply asking whether price is bullish or bearish, traders can evaluate questions such as:

* Is price still close to the previous daily close?
* Has the market already expanded 50% of its normal daily ATR?
* Is price approaching a 75% or 100% ATR expansion?
* Is a potential entry occurring early or late within the current volatility expansion?
* Does the available distance to the next relevant level justify the risk?

## Directional Context

The indicator also displays the current position of price relative to the ATR framework.

Price trading above the reference close indicates positive expansion, while price trading below the reference close indicates negative expansion.

This directional information is intended as **market context**, not as an automatic trend or trade signal.

A market trading above +50% ATR, for example, is in a very different volatility location than a market trading only +10% above the previous close.

The trader can use this information together with market structure to determine whether the market is:

* expanding,
* consolidating,
* approaching an extended volatility area,
* or returning toward its reference price.

## How to Use the Indicator

A typical workflow is:

**1. Identify market direction and structure**

Evaluate the broader session structure, previous highs and lows, trend direction, consolidation areas, or other structural references.

**2. Check the current ATR position**

Determine where price is currently located relative to the previous daily close and the projected ATR levels.

**3. Evaluate volatility expansion**

Consider whether the market is still in an early expansion area such as 25% ATR or has already reached a more extended area such as 75% or 100% ATR.

**4. Look for confirmation**

ATR levels are not intended to be traded mechanically.

They can be combined with tools such as:

* price action,
* support and resistance,
* volume,
* volume profile,
* order flow,
* footprint charts,
* delta,
* liquidity,
* session highs and lows,
* or other trader-defined confirmation methods.

**5. Evaluate risk-to-reward**

The built-in risk-to-reward tool can be used to compare the intended stop distance with a target based on a 2.5R reward-to-risk relationship.

## Tick-Size Normalization

ATR calculations can produce prices that do not correspond exactly to the minimum tick size of a futures contract.

The indicator therefore rounds calculated ATR levels to the instrument's valid tick size.

This makes the projected levels easier to use with futures contracts such as:

* NQ / MNQ
* GC / MGC
* CL / MCL

The framework can also be applied to other instruments where ATR-based volatility mapping is useful.

## Manual Reference Mode

By default, the framework uses the automatically calculated previous daily close and Daily ATR(14).

Optional manual inputs allow traders to override:

* the reference/settlement price,
* and the ATR value.

This can be useful when a trader wants to work with an exchange settlement value, an externally calculated ATR value, or another manually defined session reference.

## Risk-to-Reward Calculator

The indicator includes a simple **2.5R risk-to-reward calculation**.

This feature is intended to help traders evaluate whether sufficient price space exists between a potential entry, stop level, and target.

It is a planning tool and does not automatically determine whether a trade should be taken.

## Alerts

Alerts can be configured for important ATR level crossings.

This allows traders to monitor when price enters or crosses predefined volatility expansion zones without continuously watching the chart.

## Intended Markets

The framework was primarily developed for intraday futures markets, especially:

**Nasdaq**
NQ / MNQ

**Gold**
GC / MGC

**Crude Oil**
CL / MCL

However, because the calculations are based on price and ATR rather than instrument-specific signals, the framework can also be applied to other liquid markets.

## Important Interpretation

ATR measures volatility, not direction.

Reaching +75% ATR does not automatically mean price should reverse.

Likewise, reaching -100% ATR does not automatically mean a market should be bought.

Strong directional markets can continue beyond a full Daily ATR.

The ATR levels should therefore be interpreted as **volatility and decision zones rather than standalone entry signals**.

The framework is designed to answer:

**"Where is the market currently trading relative to its normal daily volatility?"**

The final trading decision remains dependent on market structure, confirmation, execution rules, and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title              = "Trading ATR Framework – NQ / GC / CL",
     shorttitle         = "ATR-F",
     overlay            = true,
     max_labels_count   = 100,
     max_lines_count    = 100
)

// ============================================================================
// 1. FARBEN – SCHWARZ / GOLD
// ============================================================================

color gold       = color.rgb(212, 175, 55)
color lightGold  = color.rgb(238, 203, 104)
color darkGold   = color.rgb(140, 105, 20)
color black      = color.rgb(8, 8, 8)
color panelBlack = color.rgb(18, 18, 18)
color softGray   = color.rgb(155, 155, 155)
color bullish    = color.rgb(212, 175, 55)
color bearish    = color.rgb(200, 200, 200)

// ============================================================================
// 2. EINSTELLUNGEN
// ============================================================================

string groupCalculation = "01 – ATR-Berechnung"
string groupDisplay     = "02 – Darstellung"
string groupRisk        = "03 – 2,5R-Rechner"
string groupAlerts      = "04 – Alerts"

int atrLength = input.int(
     defval  = 14,
     title   = "ATR-Periode",
     minval  = 1,
     group   = groupCalculation
)

string basisMode = input.string(
     defval  = "Vorheriger Tages-Schlusskurs",
     title   = "Basispreis",
     options = [
         "Vorheriger Tages-Schlusskurs",
         "Manueller Settlementpreis"
     ],
     group = groupCalculation
)

float manualSettlement = input.float(
     defval  = 0.0,
     title   = "Manueller Settlementpreis",
     step    = 0.01,
     tooltip = "Wird nur verwendet, wenn als Basispreis 'Manueller Settlementpreis' gewählt wurde.",
     group   = groupCalculation
)

bool useManualATR = input.bool(
     defval = false,
     title  = "ATR manuell eingeben",
     group  = groupCalculation
)

float manualATR = input.float(
     defval  = 0.0,
     title   = "Manueller ATR-Wert",
     step    = 0.01,
     tooltip = "Optionaler manueller Daily-ATR-Wert.",
     group   = groupCalculation
)

bool show25 = input.bool(
     defval = true,
     title  = "±25 % ATR anzeigen",
     group  = groupDisplay
)

bool show50 = input.bool(
     defval = true,
     title  = "±50 % ATR anzeigen",
     group  = groupDisplay
)

bool show75 = input.bool(
     defval = true,
     title  = "±75 % ATR anzeigen",
     group  = groupDisplay
)

bool show100 = input.bool(
     defval = true,
     title  = "±100 % ATR anzeigen",
     group  = groupDisplay
)

bool showLabels = input.bool(
     defval = true,
     title  = "Preislabels anzeigen",
     group  = groupDisplay
)

bool showTable = input.bool(
     defval = true,
     title  = "ATR-Tabelle anzeigen",
     group  = groupDisplay
)

bool colorBars = input.bool(
     defval = false,
     title  = "Kerzen nach ATR-Bias färben",
     group  = groupDisplay
)

// ============================================================================
// 3. ABGESCHLOSSENE TAGESDATEN
// ============================================================================

// Vorheriger abgeschlossener Tages-Schlusskurs.
// lookahead_on ist hier sicher, weil ausdrücklich close[1] abgefragt wird.
float previousDailyClose = request.security(
     syminfo.tickerid,
     "D",
     close[1],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

// ATR des letzten vollständig abgeschlossenen Handelstages.
float previousDailyATR = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength)[1],
     gaps      = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

// ============================================================================
// 4. HILFSFUNKTIONEN
// ============================================================================

// Rundet jeden Preis auf die gültige Tickgröße des aktuellen Futures.
roundToTick(float price) =>
    math.round(price / syminfo.mintick) * syminfo.mintick

// Formatiert Preise entsprechend der Tickgröße des Charts.
formatPrice(float price) =>
    str.tostring(price, format.mintick)

// ============================================================================
// 5. BASISPREIS UND ATR AUSWÄHLEN
// ============================================================================

float rawBasisPrice =
     basisMode == "Manueller Settlementpreis" and manualSettlement > 0
     ? manualSettlement
     : previousDailyClose

float rawATR =
     useManualATR and manualATR > 0
     ? manualATR
     : previousDailyATR

float basisPrice = roundToTick(rawBasisPrice)
float atrValue   = roundToTick(rawATR)

// ============================================================================
// 6. ATR-DISTANZEN
// ============================================================================

float atr25Distance  = atrValue * 0.25
float atr50Distance  = atrValue * 0.50
float atr75Distance  = atrValue * 0.75
float atr100Distance = atrValue

// ============================================================================
// 7. ATR-LEVEL
// ============================================================================

float upper25  = roundToTick(basisPrice + atr25Distance)
float upper50  = roundToTick(basisPrice + atr50Distance)
float upper75  = roundToTick(basisPrice + atr75Distance)
float upper100 = roundToTick(basisPrice + atr100Distance)

float lower25  = roundToTick(basisPrice - atr25Distance)
float lower50  = roundToTick(basisPrice - atr50Distance)
float lower75  = roundToTick(basisPrice - atr75Distance)
float lower100 = roundToTick(basisPrice - atr100Distance)

// ============================================================================
// 8. LEVEL PLOTTEN
// ============================================================================

plot(
     series    = basisPrice,
     title     = "Basispreis",
     color     = gold,
     linewidth = 4,
     style     = plot.style_stepline
)

plot(
     series    = show25 ? upper25 : na,
     title     = "+25 % ATR",
     color     = lightGold,
     linewidth = 2,
     style     = plot.style_stepline
)

plot(
     series    = show25 ? lower25 : na,
     title     = "-25 % ATR",
     color     = lightGold,
     linewidth = 2,
     style     = plot.style_stepline
)

plot(
     series    = show50 ? upper50 : na,
     title     = "+50 % ATR",
     color     = gold,
     linewidth = 3,
     style     = plot.style_stepline
)

plot(
     series    = show50 ? lower50 : na,
     title     = "-50 % ATR",
     color     = gold,
     linewidth = 3,
     style     = plot.style_stepline
)

plot(
     series    = show75 ? upper75 : na,
     title     = "+75 % ATR",
     color     = color.new(darkGold, 10),
     linewidth = 2,
     style     = plot.style_stepline
)

plot(
     series    = show75 ? lower75 : na,
     title     = "-75 % ATR",
     color     = color.new(darkGold, 10),
     linewidth = 2,
     style     = plot.style_stepline
)

plot(
     series    = show100 ? upper100 : na,
     title     = "+100 % ATR",
     color     = color.new(gold, 15),
     linewidth = 3,
     style     = plot.style_stepline
)

plot(
     series    = show100 ? lower100 : na,
     title     = "-100 % ATR",
     color     = color.new(gold, 15),
     linewidth = 3,
     style     = plot.style_stepline
)

// ============================================================================
// 9. TAGESBIAS UND ATR-POSITION
// ============================================================================

string bias =
     close > upper25 ? "BULLISCH" :
     close < lower25 ? "BÄRISCH" :
     "NEUTRAL"

color biasColor =
     bias == "BULLISCH" ? bullish :
     bias == "BÄRISCH" ? bearish :
     softGray

string currentZone =
     close >= upper100 ? "Über +100 % ATR" :
     close >= upper75  ? "+75 bis +100 % ATR" :
     close >= upper50  ? "+50 bis +75 % ATR" :
     close >= upper25  ? "+25 bis +50 % ATR" :
     close >= basisPrice ? "Basis bis +25 % ATR" :
     close >= lower25  ? "Basis bis -25 % ATR" :
     close >= lower50  ? "-25 bis -50 % ATR" :
     close >= lower75  ? "-50 bis -75 % ATR" :
     close >= lower100 ? "-75 bis -100 % ATR" :
     "Unter -100 % ATR"

// ATR-Ausdehnung vom Basispreis in Prozent.
float currentATRPercent =
     atrValue > 0
     ? ((close - basisPrice) / atrValue) * 100
     : na

// Optionale Kerzenfärbung.
color candleColor =
     close > upper25 ? color.new(gold, 0) :
     close < lower25 ? color.new(color.gray, 15) :
     na

barcolor(colorBars ? candleColor : na)

// ============================================================================
// 10. LABELS AM RECHTEN CHARTENDE
// ============================================================================

var label labelUpper100 = na
var label labelUpper75  = na
var label labelUpper50  = na
var label labelUpper25  = na
var label labelBasis    = na
var label labelLower25  = na
var label labelLower50  = na
var label labelLower75  = na
var label labelLower100 = na

if barstate.islast
    label.delete(labelUpper100)
    label.delete(labelUpper75)
    label.delete(labelUpper50)
    label.delete(labelUpper25)
    label.delete(labelBasis)
    label.delete(labelLower25)
    label.delete(labelLower50)
    label.delete(labelLower75)
    label.delete(labelLower100)

    if showLabels
        if show100
            labelUpper100 := label.new(
                 bar_index + 1,
                 upper100,
                 "+100 %  |  " + formatPrice(upper100),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = gold,
                 size      = size.small
            )

        if show75
            labelUpper75 := label.new(
                 bar_index + 1,
                 upper75,
                 "+75 %  |  " + formatPrice(upper75),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = gold,
                 size      = size.small
            )

        if show50
            labelUpper50 := label.new(
                 bar_index + 1,
                 upper50,
                 "+50 %  |  " + formatPrice(upper50),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = lightGold,
                 size      = size.small
            )

        if show25
            labelUpper25 := label.new(
                 bar_index + 1,
                 upper25,
                 "+25 %  |  " + formatPrice(upper25),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = lightGold,
                 size      = size.small
            )

        labelBasis := label.new(
             bar_index + 1,
             basisPrice,
             "BASIS  |  " + formatPrice(basisPrice),
             xloc      = xloc.bar_index,
             style     = label.style_label_left,
             color     = gold,
             textcolor = black,
             size      = size.normal
        )

        if show25
            labelLower25 := label.new(
                 bar_index + 1,
                 lower25,
                 "-25 %  |  " + formatPrice(lower25),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = lightGold,
                 size      = size.small
            )

        if show50
            labelLower50 := label.new(
                 bar_index + 1,
                 lower50,
                 "-50 %  |  " + formatPrice(lower50),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = lightGold,
                 size      = size.small
            )

        if show75
            labelLower75 := label.new(
                 bar_index + 1,
                 lower75,
                 "-75 %  |  " + formatPrice(lower75),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = gold,
                 size      = size.small
            )

        if show100
            labelLower100 := label.new(
                 bar_index + 1,
                 lower100,
                 "-100 %  |  " + formatPrice(lower100),
                 xloc      = xloc.bar_index,
                 style     = label.style_label_left,
                 color     = black,
                 textcolor = gold,
                 size      = size.small
            )

// ============================================================================
// 11. 2,5R RISIKORECHNER
// ============================================================================

bool showRiskCalculator = input.bool(
     defval = false,
     title  = "2,5R-Rechner aktivieren",
     group  = groupRisk
)

string tradeDirection = input.string(
     defval  = "Long",
     title   = "Trade-Richtung",
     options = ["Long", "Short"],
     group   = groupRisk
)

float plannedEntry = input.float(
     defval = 0.0,
     title  = "Geplanter Entry",
     step   = 0.01,
     group  = groupRisk
)

float plannedStop = input.float(
     defval = 0.0,
     title  = "Struktureller Stop-Loss",
     step   = 0.01,
     group  = groupRisk
)

float targetRR = input.float(
     defval = 2.5,
     title  = "Ziel-CRV",
     minval = 0.1,
     step   = 0.1,
     group  = groupRisk
)

float riskDistance = math.abs(plannedEntry - plannedStop)

float calculatedTarget =
     tradeDirection == "Long"
     ? plannedEntry + riskDistance * targetRR
     : plannedEntry - riskDistance * targetRR

float roundedTarget = roundToTick(calculatedTarget)

bool validLongRisk =
     tradeDirection == "Long" and
     plannedEntry > 0 and
     plannedStop > 0 and
     plannedStop < plannedEntry

bool validShortRisk =
     tradeDirection == "Short" and
     plannedEntry > 0 and
     plannedStop > 0 and
     plannedStop > plannedEntry

bool validRiskSetup = validLongRisk or validShortRisk

plot(
     series    = showRiskCalculator and validRiskSetup ? plannedEntry : na,
     title     = "Geplanter Entry",
     color     = color.white,
     linewidth = 2,
     style     = plot.style_linebr
)

plot(
     series    = showRiskCalculator and validRiskSetup ? plannedStop : na,
     title     = "Struktureller Stop",
     color     = color.gray,
     linewidth = 2,
     style     = plot.style_linebr
)

plot(
     series    = showRiskCalculator and validRiskSetup ? roundedTarget : na,
     title     = "2,5R Take-Profit",
     color     = gold,
     linewidth = 3,
     style     = plot.style_linebr
)

// ============================================================================
// 12. INFORMATIONSTABELLE
// ============================================================================

var table atrTable = table.new(
     position.top_right,
     2,
     17,
     bgcolor      = panelBlack,
     frame_color  = gold,
     frame_width  = 2,
     border_color = darkGold,
     border_width = 1
)

if barstate.islast and showTable
    table.clear(atrTable, 0, 0, 1, 16)

    table.cell(
         atrTable, 0, 0,
         "ATR FRAMEWORK",
         bgcolor    = gold,
         text_color = black,
         text_size  = size.normal
    )

    table.cell(
         atrTable, 1, 0,
         syminfo.ticker,
         bgcolor    = gold,
         text_color = black,
         text_size  = size.normal
    )

    table.cell(atrTable, 0, 1, "+100 %", text_color = gold)
    table.cell(atrTable, 1, 1, formatPrice(upper100), text_color = gold)

    table.cell(atrTable, 0, 2, "+75 %", text_color = gold)
    table.cell(atrTable, 1, 2, formatPrice(upper75), text_color = gold)

    table.cell(atrTable, 0, 3, "+50 %", text_color = lightGold)
    table.cell(atrTable, 1, 3, formatPrice(upper50), text_color = lightGold)

    table.cell(atrTable, 0, 4, "+25 %", text_color = lightGold)
    table.cell(atrTable, 1, 4, formatPrice(upper25), text_color = lightGold)

    table.cell(
         atrTable, 0, 5,
         "BASIS",
         bgcolor    = darkGold,
         text_color = color.white
    )

    table.cell(
         atrTable, 1, 5,
         formatPrice(basisPrice),
         bgcolor    = darkGold,
         text_color = color.white
    )

    table.cell(atrTable, 0, 6, "-25 %", text_color = lightGold)
    table.cell(atrTable, 1, 6, formatPrice(lower25), text_color = lightGold)

    table.cell(atrTable, 0, 7, "-50 %", text_color = lightGold)
    table.cell(atrTable, 1, 7, formatPrice(lower50), text_color = lightGold)

    table.cell(atrTable, 0, 8, "-75 %", text_color = gold)
    table.cell(atrTable, 1, 8, formatPrice(lower75), text_color = gold)

    table.cell(atrTable, 0, 9, "-100 %", text_color = gold)
    table.cell(atrTable, 1, 9, formatPrice(lower100), text_color = gold)

    table.cell(atrTable, 0, 10, "Daily ATR", text_color = softGray)
    table.cell(atrTable, 1, 10, formatPrice(atrValue), text_color = color.white)

    table.cell(atrTable, 0, 11, "Bias", text_color = softGray)
    table.cell(
         atrTable, 1, 11,
         bias,
         bgcolor    = color.new(biasColor, 75),
         text_color = biasColor
    )

    table.cell(atrTable, 0, 12, "Aktuelle Zone", text_color = softGray)
    table.cell(atrTable, 1, 12, currentZone, text_color = color.white)

    table.cell(atrTable, 0, 13, "ATR-Ausdehnung", text_color = softGray)
    table.cell(
         atrTable, 1, 13,
         str.tostring(currentATRPercent, "#.0") + " %",
         text_color = color.white
    )

    table.cell(atrTable, 0, 14, "Tickgröße", text_color = softGray)
    table.cell(
         atrTable, 1, 14,
         str.tostring(syminfo.mintick),
         text_color = color.white
    )

    string dataSource =
         basisMode == "Manueller Settlementpreis"
         ? "Manuell"
         : "Vorheriger D-Close"

    table.cell(atrTable, 0, 15, "Datenbasis", text_color = softGray)
    table.cell(atrTable, 1, 15, dataSource, text_color = color.white)

    string riskText =
         not showRiskCalculator ? "Deaktiviert" :
         not validRiskSetup ? "Eingaben prüfen" :
         formatPrice(roundedTarget)

    table.cell(atrTable, 0, 16, str.tostring(targetRR, "#.0") + "R-Ziel", text_color = softGray)
    table.cell(atrTable, 1, 16, riskText, text_color = gold)

// Tabelle ausblenden.
if barstate.islast and not showTable
    table.clear(atrTable, 0, 0, 1, 16)

// ============================================================================
// 13. ALERTS
// ============================================================================

bool enableAlerts = input.bool(
     defval = true,
     title  = "Level-Alerts aktivieren",
     group  = groupAlerts
)

alertcondition(
     enableAlerts and ta.crossover(close, basisPrice),
     title   = "Basispreis bullisch zurückerobert",
     message = "{{ticker}} hat den ATR-Basispreis bullisch zurückerobert."
)

alertcondition(
     enableAlerts and ta.crossunder(close, basisPrice),
     title   = "Basispreis bärisch verloren",
     message = "{{ticker}} ist unter den ATR-Basispreis gefallen."
)

alertcondition(
     enableAlerts and ta.crossover(close, upper25),
     title   = "+25 % ATR überschritten",
     message = "{{ticker}} hat das +25-%-ATR-Level überschritten."
)

alertcondition(
     enableAlerts and ta.crossunder(close, lower25),
     title   = "-25 % ATR unterschritten",
     message = "{{ticker}} hat das -25-%-ATR-Level unterschritten."
)

alertcondition(
     enableAlerts and ta.crossover(close, upper50),
     title   = "+50 % ATR überschritten",
     message = "{{ticker}} hat das +50-%-ATR-Level überschritten."
)

alertcondition(
     enableAlerts and ta.crossunder(close, lower50),
     title   = "-50 % ATR unterschritten",
     message = "{{ticker}} hat das -50-%-ATR-Level unterschritten."
)

alertcondition(
     enableAlerts and ta.crossover(close, upper75),
     title   = "+75 % ATR überschritten",
     message = "{{ticker}} hat das +75-%-ATR-Level überschritten."
)

alertcondition(
     enableAlerts and ta.crossunder(close, lower75),
     title   = "-75 % ATR unterschritten",
     message = "{{ticker}} hat das -75-%-ATR-Level unterschritten."
)

alertcondition(
     enableAlerts and ta.crossover(close, upper100),
     title   = "+100 % ATR überschritten",
     message = "{{ticker}} hat das +100-%-ATR-Level überschritten."
)

alertcondition(
     enableAlerts and ta.crossunder(close, lower100),
     title   = "-100 % ATR unterschritten",
     message = "{{ticker}} hat das -100-%-ATR-Level unterschritten."
)
````
