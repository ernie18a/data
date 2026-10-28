# Kevin's swingdicators

- url: https://www.tradingview.com/script/VgpgfAHj-Kevin-s-swingdicators/
- type: indicator
- pine_id: PUB;86055bd374b248338b7aff310dfcc96d
- version: 5.0

## Description

Kevin's swingdicators

Kevin's swingdicators is a combined indicator for swing trading analysis. It includes an RSI divergence module and a configurable moving average ribbon.

The moving average module plots up to six moving averages on the price chart. By default, the first four moving averages are enabled: 20 SMA, 50 SMA, 100 SMA and 200 SMA. The fifth and sixth moving averages are disabled by default and can be configured manually. Users can change the moving average type, source, length and color.

The RSI module is displayed in a separate pane below the price chart. It includes optional detection of regular and hidden RSI divergences. Divergences are detected by comparing RSI pivots with the corresponding price highs or lows on the same bars.

Regular bullish divergence occurs when price makes a lower low while RSI makes a higher low. This can indicate weakening bearish momentum and a possible bullish reversal.

Regular bearish divergence occurs when price makes a higher high while RSI makes a lower high. This can indicate weakening bullish momentum and a possible bearish reversal.

Hidden bullish divergence occurs when price makes a higher low while RSI makes a lower low. This is generally interpreted as a possible bullish trend-continuation signal.

Hidden bearish divergence occurs when price makes a lower high while RSI makes a higher high. This is generally interpreted as a possible bearish trend-continuation signal.

The RSI divergence module includes three preset modes:
- Conservative: RSI length 14, pivot left 5, pivot right 5.
- Medium: RSI length 7 or 9, pivot left 3, pivot right 3.
- Aggressive: RSI length 5, pivot left 1, pivot right 3.

The conservative preset produces fewer signals and is intended to reduce noise. The aggressive preset produces more signals and reacts faster, but it may also produce more false signals. The medium preset is a compromise between both.

This indicator is intended for educational and analytical use only. It does not provide financial advice, buy signals or sell signals. RSI divergences should not be used in isolation. They are best interpreted together with market structure, support and resistance, trend direction, moving averages, volume, Fibonacci levels and other forms of technical analysis.

Dutch documentation is provided below.

## Nederlandse documentatie

Handig als je de gratis versie van Tradingview hebt of als je in 1 keer de setup klaar wil hebben zoals Kevin trade. Alles binnen 1 indicator, dus ruimschoots binnen de twee die je bij een gratis account van TV mag gebruiken.

De volgende indicatoren zijn hier gebundeld:

# Zes moving averages

Bij default staat dit ingesteld:
* 20SMA, blauw
* 50SMA, rood
* 100SMA, oranje
* 200SMA, grijs

Je kunt er desgewenst nog twee extra toevoegen, als je dat graag wilt. Deze staan default uit. Uiteraard kun je eventueel ook het type MA veranderen (bijv. exponentieel) en de kleuren wijzigen. Maar de defaults passen bij de instellingen die Kevin hanteert.

# Relative Strength Indicator

De RSI staat in een pane onder de chart.  

## RSI divergentie

Als extra opties kan de RSI indicator ook bearish en bullish divergences identificeren (maar dat kun je ook uit zetten). Je kunt divergenties op meerdere manieren bepalen, de default is de "conservatieve" setting:
 
* Conservatief: gebruikt de lengte 14 (de wereldwijde RSI standaard), gebruikt 5 bars links en 5 bars rechts om een relevante low of high te bepalen.
* Aggresief: lengte 5 en 1 bar links en 3 rechts. Dit geeft veel meer divergenties en dus ook meer ruis. Maar als je aggresiever wilt traden, dan is dit er voor je.

Je kunt ook zelf de diverse instellingen wijzigen naar smaak en trading stijl.

Een **RSI-divergentie** ontstaat wanneer de prijs en de RSI niet meer dezelfde richting bevestigen. De prijs maakt bijvoorbeeld een nieuwe high of low, terwijl de RSI dat niet doet. Omdat RSI momentum meet, kan zo’n verschil erop wijzen dat de kracht achter de huidige beweging afneemt of juist dat een correctie binnen een trend bijna klaar is.

RSI-divergenties worden meestal berekend door twee opeenvolgende **swing points** of **pivots** met elkaar te vergelijken:

```text
Prijs-pivot 1  versus  prijs-pivot 2
RSI-pivot 1    versus  RSI-pivot 2
```

In deze indicator worden de pivots gevonden op basis van de RSI. Daarna wordt op dezelfde bars gekeken wat de prijs deed. Een bullish divergentie gebruikt doorgaans RSI-pivot lows en prijs-lows. Een bearish divergentie gebruikt RSI-pivot highs en prijs-highs.

---

# Reguliere RSI-divergentie

Een **reguliere divergentie** wijst meestal op een mogelijke **trendomkeer**. De prijs zet de bestaande beweging nog door, maar de RSI bevestigt die nieuwe extreme niet meer.

## Regular bullish divergence

Een **regular bullish divergence** ontstaat wanneer:

```text
Prijs: lagere low
RSI:   hogere low
```

Berekening:

```text
current price low < previous price low
current RSI low   > previous RSI low
```

Interpretatie:

De prijs maakt een nieuwe lagere bodem, maar de RSI maakt juist een hogere bodem. Dat betekent dat de neerwaartse beweging in prijs niet meer volledig wordt bevestigd door momentum. De verkoopdruk kan dus afnemen.

Voorbeeld:

```text
Prijs low 1 = 100
Prijs low 2 = 95

RSI low 1 = 25
RSI low 2 = 32
```

De prijs is zwakker, maar de RSI is sterker. Dit wordt meestal gezien als een mogelijk bullish reversal-signaal.

---

## Regular bearish divergence

Een **regular bearish divergence** ontstaat wanneer:

```text
Prijs: hogere high
RSI:   lagere high
```

Berekening:

```text
current price high > previous price high
current RSI high   < previous RSI high
```

Interpretatie:

De prijs maakt een nieuwe hogere top, maar de RSI maakt een lagere top. De opwaartse beweging wordt dus niet meer volledig bevestigd door momentum. De koopdruk kan afnemen.

Voorbeeld:

```text
Prijs high 1 = 100
Prijs high 2 = 106

RSI high 1 = 75
RSI high 2 = 67
```

De prijs is sterker, maar de RSI is zwakker. Dit wordt meestal gezien als een mogelijk bearish reversal-signaal.

---

# Hidden RSI-divergentie

Een **hidden divergence** is anders. Waar een reguliere divergentie meestal op een mogelijke draai wijst, wijst een hidden divergence meestal op mogelijke **trendvoortzetting**.

Bij hidden divergence blijft de prijsstructuur in de richting van de trend intact, maar de RSI corrigeert sterker dan de prijs. Dat kan betekenen dat de markt intern momentum heeft “gereset”, terwijl de trend zelf nog niet gebroken is.

---

## Hidden bullish divergence

Een **hidden bullish divergence** ontstaat meestal binnen een bestaande uptrend.

Voorwaarde:

```text
Prijs: hogere low
RSI:   lagere low
```

Berekening:

```text
current price low > previous price low
current RSI low   < previous RSI low
```

Interpretatie:

De prijs blijft relatief sterk, omdat hij een hogere bodem maakt. De RSI maakt echter een lagere bodem, wat aangeeft dat de oscillator dieper is gecorrigeerd. Dit kan betekenen dat de pullback voldoende is afgekoeld terwijl de bullish prijsstructuur intact blijft.

Voorbeeld:

```text
Prijs low 1 = 100
Prijs low 2 = 104

RSI low 1 = 40
RSI low 2 = 31
```

De prijs maakt een hogere bodem, maar RSI maakt een lagere bodem. Dit wordt vaak gezien als een bullish continuation-signaal.

---

## Hidden bearish divergence

Een **hidden bearish divergence** ontstaat meestal binnen een bestaande downtrend.

Voorwaarde:

```text
Prijs: lagere high
RSI:   hogere high
```

Berekening:

```text
current price high < previous price high
current RSI high   > previous RSI high
```

Interpretatie:

De prijs blijft relatief zwak, omdat hij een lagere top maakt. De RSI maakt echter een hogere top, wat aangeeft dat de oscillator sterker is opgeveerd dan de prijs. Dit kan betekenen dat de tijdelijke bounce voldoende is afgekoeld, terwijl de bearish prijsstructuur intact blijft.

Voorbeeld:

```text
Prijs high 1 = 100
Prijs high 2 = 96

RSI high 1 = 58
RSI high 2 = 69
```

De prijs maakt een lagere top, maar RSI maakt een hogere top. Dit wordt vaak gezien als een bearish continuation-signaal.

---

# Belangrijkste verschil tussen regular en hidden divergence

Het verschil zit zowel in de **berekening** als in de **interpretatie**.

| Type            |       Prijs |         RSI | Meestal geïnterpreteerd als      |
| --------------- | ----------: | ----------: | -------------------------------- |
| Regular bullish |  lagere low |  hogere low | mogelijke omkeer omhoog          |
| Regular bearish | hogere high | lagere high | mogelijke omkeer omlaag          |
| Hidden bullish  |  hogere low |  lagere low | mogelijke voortzetting uptrend   |
| Hidden bearish  | lagere high | hogere high | mogelijke voortzetting downtrend |

Kort gezegd:

```text
Regular divergence = prijs maakt een nieuw extreme, RSI bevestigt niet.
Hidden divergence  = prijsstructuur blijft intact, RSI corrigeert dieper.
```

Of nog compacter:

```text
Regular divergence = mogelijke reversal
Hidden divergence  = mogelijke continuation
```

---

# Gebruik in de praktijk

Een RSI-divergentie is geen zelfstandig koop- of verkoopsignaal. In Kevin's aanpak gebruiken we divergenties als contextsignaal.

Een reguliere bullish divergence is sterker wanneer die verschijnt rond steun, na een duidelijke daling, of wanneer daarna een hogere high in prijs ontstaat. Een reguliere bearish divergence is sterker rond weerstand, na een duidelijke stijging, of wanneer daarna een lagere low in prijs ontstaat.

Hidden bullish divergence is vooral relevant in een bestaande uptrend. Hidden bearish divergence is vooral relevant in een bestaande downtrend. Zonder trendcontext zijn hidden divergences minder betrouwbaar, omdat ze bedoeld zijn als voortzettingssignalen.

Gebruik RSI-divergenties alleen in combinatie met sterke levels, ronde getallen, Fibonacci, tend, moving averages, et cetera.

## Source Code

````pine
//@version=6
// =============================================================================
// Kevin's swingdicators
// Author / Owner: ScubaRo
//
// English summary:
// This indicator combines a moving average ribbon with RSI 
// and RSI divergence detection (incl hidden divergence).
// Full documentation is provided separately.
// =============================================================================

indicator(
     title="Kevin's swingdicators",
     shorttitle="Kevin's swingdicators",
     overlay=false
     )

//==============================================================================
// RSI DIVERGENCE SETTINGS
//==============================================================================

rsiGroup = "RSI Divergence"
customRsiGroup = "Custom RSI Settings - only used when RSI Preset = Custom"
pivotRangeGroup = "Pivot Distance Filter"

preset = input.string(
     "Conservatief",
     "RSI Preset",
     options=["Conservatief", "Medium", "Agressief", "Custom"],
     group=rsiGroup,
     display=display.none
     )

src = input.source(
     close,
     "RSI Source",
     group=rsiGroup,
     display=display.none
     )

plotBull = input.bool(
     true,
     "Plot Regular Bullish",
     group=rsiGroup,
     display=display.none
     )

plotHiddenBull = input.bool(
     false,
     "Plot Hidden Bullish",
     group=rsiGroup,
     display=display.none
     )

plotBear = input.bool(
     true,
     "Plot Regular Bearish",
     group=rsiGroup,
     display=display.none
     )

plotHiddenBear = input.bool(
     false,
     "Plot Hidden Bearish",
     group=rsiGroup,
     display=display.none
     )

customActive = preset == "Custom"

customRsiLen = input.int(
     14,
     "RSI Period",
     minval=1,
     active=customActive,
     group=customRsiGroup,
     display=display.none
     )

customLbL = input.int(
     5,
     "Lookback Left",
     minval=1,
     active=customActive,
     group=customRsiGroup,
     display=display.none
     )

customLbR = input.int(
     5,
     "Lookback Right",
     minval=1,
     active=customActive,
     group=customRsiGroup,
     display=display.none
     )

rangeLower = input.int(
     5,
     "Min Bars Between Pivots",
     minval=1,
     group=pivotRangeGroup,
     display=display.none
     )

rangeUpper = input.int(
     60,
     "Max Bars Between Pivots",
     minval=1,
     group=pivotRangeGroup,
     display=display.none
     )

//==============================================================================
// EFFECTIVE RSI SETTINGS
//==============================================================================

len = switch preset
    "Conservatief" => 14
    "Medium"       => 9
    "Agressief"    => 5
    => customRsiLen

lbL = switch preset
    "Conservatief" => 5
    "Medium"       => 3
    "Agressief"    => 1
    => customLbL

lbR = switch preset
    "Conservatief" => 5
    "Medium"       => 3
    "Agressief"    => 3
    => customLbR

//==============================================================================
// DISPLAY SETTINGS
//==============================================================================

displayGroup = "Display"

rsiColor = input.color(
     color.purple,
     "RSI Color",
     group=displayGroup,
     display=display.none
     )

showMiddleLine = input.bool(
     false,
     "Show Middle Line",
     group=displayGroup,
     display=display.none
     )

showOverbought = input.bool(
     false,
     "Show Overbought Line",
     group=displayGroup,
     display=display.none
     )

showOversold = input.bool(
     false,
     "Show Oversold Line",
     group=displayGroup,
     display=display.none
     )

showCurrentRsiLabel = input.bool(
     true,
     "Show Current RSI Label",
     group=displayGroup,
     display=display.none
     )

// Entire RSI pane background: true black
bgcolor(color.black, title="RSI Background")

paneDisplay = display.pane

//==============================================================================
// COLORS
//==============================================================================

bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

//==============================================================================
// RSI CALCULATION
//==============================================================================

osc = ta.rsi(src, len)

plot(
     osc,
     title="RSI",
     linewidth=2,
     color=rsiColor,
     display=paneDisplay
     )

hline(
     50,
     title="Middle Line",
     color=color.gray,
     linestyle=hline.style_dotted,
     display=showMiddleLine ? display.all : display.none
     )

obLevel = hline(
     70,
     title="Overbought",
     color=color.gray,
     linestyle=hline.style_dotted,
     display=showOverbought ? display.all : display.none
     )

osLevel = hline(
     30,
     title="Oversold",
     color=color.gray,
     linestyle=hline.style_dotted,
     display=showOversold ? display.all : display.none
     )

fill(
     obLevel,
     osLevel,
     title="RSI Background Fill",
     color=color.black
     )

//==============================================================================
// CURRENT RSI VALUE LABEL
//==============================================================================

var label currentRsiLabel = na

if barstate.islast
    if not na(currentRsiLabel)
        label.delete(currentRsiLabel)

    if showCurrentRsiLabel and not na(osc)
        currentRsiLabel := label.new(
             x=bar_index + 1,
             y=osc,
             text="RSI " + str.tostring(osc, "#.##"),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color.new(color.purple, 0),
             textcolor=color.white,
             size=size.small
             )

//==============================================================================
// RSI DIVERGENCE LOGIC - BASED ON SCRIPT A
//==============================================================================

plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

//------------------------------------------------------------------------------
// Regular Bullish
// Oscillator: Higher Low
// Price: Lower Low
//------------------------------------------------------------------------------

inRangePl = _inRange(plFound[1])

oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)

bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert

plot(
     plFound ? osc[lbR] : na,
     offset=-lbR,
     title="Regular Bullish",
     linewidth=2,
     color=bullCond ? bullColor : noneColor,
     display=paneDisplay
     )

plotshape(
     bullCond ? osc[lbR] : na,
     offset=-lbR,
     title="Regular Bullish Label",
     text=" Bull ",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     textcolor=textColor,
     display=paneDisplay
     )

//------------------------------------------------------------------------------
// Hidden Bullish
// Oscillator: Lower Low
// Price: Higher Low
//------------------------------------------------------------------------------

oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)

hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

plot(
     plFound ? osc[lbR] : na,
     offset=-lbR,
     title="Hidden Bullish",
     linewidth=2,
     color=hiddenBullCond ? hiddenBullColor : noneColor,
     display=paneDisplay
     )

plotshape(
     hiddenBullCond ? osc[lbR] : na,
     offset=-lbR,
     title="Hidden Bullish Label",
     text=" H Bull ",
     style=shape.labelup,
     location=location.absolute,
     color=bullColor,
     textcolor=textColor,
     display=paneDisplay
     )

//------------------------------------------------------------------------------
// Regular Bearish
// Oscillator: Lower High
// Price: Higher High
//------------------------------------------------------------------------------

inRangePh = _inRange(phFound[1])

oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)

bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert

plot(
     phFound ? osc[lbR] : na,
     offset=-lbR,
     title="Regular Bearish",
     linewidth=2,
     color=bearCond ? bearColor : noneColor,
     display=paneDisplay
     )

plotshape(
     bearCond ? osc[lbR] : na,
     offset=-lbR,
     title="Regular Bearish Label",
     text=" Bear ",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     textcolor=textColor,
     display=paneDisplay
     )

//------------------------------------------------------------------------------
// Hidden Bearish
// Oscillator: Higher High
// Price: Lower High
//------------------------------------------------------------------------------

oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)

hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

plot(
     phFound ? osc[lbR] : na,
     offset=-lbR,
     title="Hidden Bearish",
     linewidth=2,
     color=hiddenBearCond ? hiddenBearColor : noneColor,
     display=paneDisplay
     )

plotshape(
     hiddenBearCond ? osc[lbR] : na,
     offset=-lbR,
     title="Hidden Bearish Label",
     text=" H Bear ",
     style=shape.labeldown,
     location=location.absolute,
     color=bearColor,
     textcolor=textColor,
     display=paneDisplay
     )

//==============================================================================
// RSI DIVERGENCE ALERTS
//==============================================================================

alertcondition(
     bullCondAlert,
     title="Regular Bullish Divergence",
     message="Found a new Regular Bullish Divergence, Pivot Lookback Right bars to the left of the current bar."
     )

alertcondition(
     hiddenBullCondAlert,
     title="Hidden Bullish Divergence",
     message="Found a new Hidden Bullish Divergence, Pivot Lookback Right bars to the left of the current bar."
     )

alertcondition(
     bearCondAlert,
     title="Regular Bearish Divergence",
     message="Found a new Regular Bearish Divergence, Pivot Lookback Right bars to the left of the current bar."
     )

alertcondition(
     hiddenBearCondAlert,
     title="Hidden Bearish Divergence",
     message="Found a new Hidden Bearish Divergence, Pivot Lookback Right bars to the left of the current bar."
     )

//==============================================================================
// MOVING AVERAGE RIBBON
//==============================================================================

maGroup = "Moving Averages"

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)
        => na

maDisplay(show) =>
    show ? display.all - display.price_scale - display.status_line : display.none

//------------------------------------------------------------------------------
// MA #1
//------------------------------------------------------------------------------

show_ma1 = input.bool(
     true,
     "MA #1",
     inline="MA #1",
     group=maGroup,
     display=display.none
     )

ma1_type = input.string(
     "SMA",
     "",
     inline="MA #1",
     active=show_ma1,
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=maGroup,
     display=display.none
     )

ma1_source = input.source(
     close,
     "",
     inline="MA #1",
     active=show_ma1,
     group=maGroup,
     display=display.none
     )

ma1_length = input.int(
     20,
     "",
     inline="MA #1",
     active=show_ma1,
     minval=1,
     group=maGroup,
     display=display.none
     )

ma1_color = input.color(
     color.blue,
     "",
     inline="MA #1",
     active=show_ma1,
     group=maGroup,
     display=display.none
     )

//------------------------------------------------------------------------------
// MA #2
//------------------------------------------------------------------------------

show_ma2 = input.bool(
     true,
     "MA #2",
     inline="MA #2",
     group=maGroup,
     display=display.none
     )

ma2_type = input.string(
     "SMA",
     "",
     inline="MA #2",
     active=show_ma2,
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=maGroup,
     display=display.none
     )

ma2_source = input.source(
     close,
     "",
     inline="MA #2",
     active=show_ma2,
     group=maGroup,
     display=display.none
     )

ma2_length = input.int(
     50,
     "",
     inline="MA #2",
     active=show_ma2,
     minval=1,
     group=maGroup,
     display=display.none
     )

ma2_color = input.color(
     color.red,
     "",
     inline="MA #2",
     active=show_ma2,
     group=maGroup,
     display=display.none
     )

//------------------------------------------------------------------------------
// MA #3
//------------------------------------------------------------------------------

show_ma3 = input.bool(
     true,
     "MA #3",
     inline="MA #3",
     group=maGroup,
     display=display.none
     )

ma3_type = input.string(
     "SMA",
     "",
     inline="MA #3",
     active=show_ma3,
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=maGroup,
     display=display.none
     )

ma3_source = input.source(
     close,
     "",
     inline="MA #3",
     active=show_ma3,
     group=maGroup,
     display=display.none
     )

ma3_length = input.int(
     100,
     "",
     inline="MA #3",
     active=show_ma3,
     minval=1,
     group=maGroup,
     display=display.none
     )

ma3_color = input.color(
     color.orange,
     "",
     inline="MA #3",
     active=show_ma3,
     group=maGroup,
     display=display.none
     )

//------------------------------------------------------------------------------
// MA #4
//------------------------------------------------------------------------------

show_ma4 = input.bool(
     true,
     "MA #4",
     inline="MA #4",
     group=maGroup,
     display=display.none
     )

ma4_type = input.string(
     "SMA",
     "",
     inline="MA #4",
     active=show_ma4,
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=maGroup,
     display=display.none
     )

ma4_source = input.source(
     close,
     "",
     inline="MA #4",
     active=show_ma4,
     group=maGroup,
     display=display.none
     )

ma4_length = input.int(
     200,
     "",
     inline="MA #4",
     active=show_ma4,
     minval=1,
     group=maGroup,
     display=display.none
     )

ma4_color = input.color(
     color.gray,
     "",
     inline="MA #4",
     active=show_ma4,
     group=maGroup,
     display=display.none
     )

//------------------------------------------------------------------------------
// MA #5 - disabled by default
//------------------------------------------------------------------------------

show_ma5 = input.bool(
     false,
     "MA #5",
     inline="MA #5",
     group=maGroup,
     display=display.none
     )

ma5_type = input.string(
     "SMA",
     "",
     inline="MA #5",
     active=show_ma5,
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=maGroup,
     display=display.none
     )

ma5_source = input.source(
     close,
     "",
     inline="MA #5",
     active=show_ma5,
     group=maGroup,
     display=display.none
     )

ma5_length = input.int(
     20,
     "",
     inline="MA #5",
     active=show_ma5,
     minval=1,
     group=maGroup,
     display=display.none
     )

ma5_color = input.color(
     color.gray,
     "",
     inline="MA #5",
     active=show_ma5,
     group=maGroup,
     display=display.none
     )

//------------------------------------------------------------------------------
// MA #6 - disabled by default
//------------------------------------------------------------------------------

show_ma6 = input.bool(
     false,
     "MA #6",
     inline="MA #6",
     group=maGroup,
     display=display.none
     )

ma6_type = input.string(
     "SMA",
     "",
     inline="MA #6",
     active=show_ma6,
     options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     group=maGroup,
     display=display.none
     )

ma6_source = input.source(
     close,
     "",
     inline="MA #6",
     active=show_ma6,
     group=maGroup,
     display=display.none
     )

ma6_length = input.int(
     20,
     "",
     inline="MA #6",
     active=show_ma6,
     minval=1,
     group=maGroup,
     display=display.none
     )

ma6_color = input.color(
     color.gray,
     "",
     inline="MA #6",
     active=show_ma6,
     group=maGroup,
     display=display.none
     )

//==============================================================================
// MA CALCULATIONS
//==============================================================================

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na
ma5 = show_ma5 ? ma(ma5_source, ma5_length, ma5_type) : na
ma6 = show_ma6 ? ma(ma6_source, ma6_length, ma6_type) : na

//==============================================================================
// MA PLOTS ON PRICE CHART
//==============================================================================

plot(
     ma1,
     title="MA #1",
     color=ma1_color,
     linewidth=2,
     display=maDisplay(show_ma1),
     force_overlay=true
     )

plot(
     ma2,
     title="MA #2",
     color=ma2_color,
     linewidth=2,
     display=maDisplay(show_ma2),
     force_overlay=true
     )

plot(
     ma3,
     title="MA #3",
     color=ma3_color,
     linewidth=2,
     display=maDisplay(show_ma3),
     force_overlay=true
     )

plot(
     ma4,
     title="MA #4",
     color=ma4_color,
     linewidth=2,
     display=maDisplay(show_ma4),
     force_overlay=true
     )

plot(
     ma5,
     title="MA #5",
     color=ma5_color,
     linewidth=2,
     display=maDisplay(show_ma5),
     force_overlay=true
     )

plot(
     ma6,
     title="MA #6",
     color=ma6_color,
     linewidth=2,
     display=maDisplay(show_ma6),
     force_overlay=true
     )
````
