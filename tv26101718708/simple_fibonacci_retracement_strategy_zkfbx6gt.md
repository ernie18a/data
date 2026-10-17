# Simple Fibonacci Retracement Strategy 

- url: https://www.tradingview.com/script/ZKfbX6gT-Simple-Fibonacci-Retracement-Strategy/
- type: strategy
- pine_id: PUB;9e3357c7cb9b4093a854ae987c31cf6f
- version: 2.0

## Description

This strategy uses Fibonacci retracement to identify key levels in the market and helps traders find good entry and exit points. By understanding and using this strategy, traders can improve their trading decisions and increase their chances of success in the market.

This strategy, called the "Simple Fibonacci Retracement Strategy," is designed to help traders identify potential entry and exit points in the market based on Fibonacci retracement levels. The code is written in Pine Script and runs on the TradingView platform.
Overall Function

The strategy uses Fibonacci retracement levels to identify potential support and resistance levels in the market. This helps traders find good entry and exit points for trades, as well as set stop-loss and take-profit levels to minimize risk and maximize gains.
Main Components of the Code
1. Input Parameters

    Lookback Period: The number of bars used to identify the highest high and lowest low.
    Fibonacci Direction: The choice of whether Fibonacci levels are calculated from top to bottom or bottom to top.
    Fibonacci Levels: Specific Fibonacci levels (23.6%, 38.2%, 50%, 61.8%) used to identify important price levels.
    Take Profit and Stop Loss: The number of pips used to set take profit and stop loss levels.

2. Identification of Highest and Lowest Points

The code uses the lookback period to find the highest high (highestHigh) and the lowest low (lowestLow). These levels form the basis for calculating the Fibonacci levels.

3. Calculation of Fibonacci Levels
Based on the direction chosen by the user, the code calculates the various Fibonacci levels (0%, 23.6%, 38.2%, 50%, 61.8%, 100%).

4. Trading Logic
    Long Signal: Generated when the price crosses above the 61.8% Fibonacci level from bottom to top.
    Short Signal: Generated when the price crosses below the 38.2% Fibonacci level from top to bottom.
    When a long or short signal is generated, the strategy opens a position and sets take profit and stop loss levels based on the input parameters.

5. Visualization
The strategy plots the Fibonacci levels on the chart to provide a visual representation of the calculated levels. This helps traders see where the levels are in relation to the current price.

6. Alerts
The code also has functionality to create alerts (commented out), which can notify traders of buy or sell signals.
How to Use the Strategy

    Configure Parameters: Adjust the lookback period, Fibonacci direction, and levels for take profit and stop loss to your preferences.
    View the Chart: The Fibonacci levels will be plotted on the chart, providing a visual overview of potential support and resistance levels.
    Trade Signals: Follow the generated buy and sell signals. Set your parameters in settings and adjust according to the generated buy and sell signals in the strategy tester. The strategy will automatically set your take profit and stop loss levels.
    Evaluation and Adjustment: Monitor the performance of the strategy and make adjustments as needed to optimize the results.

Norwegian
Denne strategien, kalt "Simple Fibonacci Retracement Strategy", er designet for å hjelpe tradere med å identifisere mulige inngangs- og utgangspunkter i markedet basert på Fibonacci-retracementnivåer. Koden er skrevet i Pine Script og kjøres på TradingView-plattformen.
Overordnet Funksjon

Strategien bruker Fibonacci-retracementnivåer for å identifisere potensielle støtte- og motstandsnivåer i markedet. Dette hjelper tradere med å finne gode inngangs- og utgangspunkter for handler, samt å sette stop-loss og take-profit nivåer for å minimere risiko og maksimere gevinster.
Hovedkomponenter i Koden
1. Input Parametere

    Lookback Period: Antall barer som brukes til å identifisere høyeste høydepunkt og laveste lavpunkt.
    Fibonacci Direction: Valg om Fibonacci-nivåene skal beregnes fra topp til bunn eller bunn til topp.
    Fibonacci Levels: Spesifikke Fibonacci-nivåer (23.6%, 38.2%, 50%, 61.8%) som brukes til å identifisere viktige prisnivåer.
    Take Profit og Stop Loss: Antall pips som brukes til å sette take profit og stop loss nivåer.

2. Identifikasjon av Høyeste og Laveste Punkt

Koden bruker lookback perioden for å finne det høyeste høydepunktet (highestHigh) og det laveste lavpunktet (lowestLow). Disse nivåene er grunnlaget for å beregne Fibonacci-nivåene.
3. Beregning av Fibonacci-nivåer

Basert på retningen valgt av brukeren, beregner koden de forskjellige Fibonacci-nivåene (0%, 23.6%, 38.2%, 50%, 61.8%, 100%).
4. Handelslogikk
Long Signal: Genereres når prisen krysser over 61.8% Fibonacci-nivået fra bunn til topp.
 Short Signal: Genereres når prisen krysser under 38.2% Fibonacci-nivået fra topp til bunn.
Når et long eller short signal genereres, åpner strategien en posisjon og setter take profit og stop loss nivåer basert på inputparametrene.

5. Visualisering
Strategien plottet Fibonacci-nivåene på chartet for å gi en visuell representasjon av de beregnede nivåene. Dette hjelper tradere med å se hvor nivåene er i forhold til den nåværende prisen.

6. Varsler
Koden har også funksjonalitet for å lage varsler (kommentert ut), som kan varsle tradere om kjøps- eller salgssignaler.

Slik Bruker Du Strategien
    Konfigurer Parametere: Juster lookback perioden, Fibonacci-retningen, og nivåene for take profit og stop loss til dine preferanser.

    Se på Chartet: Fibonacci-nivåene vil bli plottet på chartet, noe som gir deg en visuell oversikt over potensielle støtte- og motstandsnivåer.

    Handle Signaler: Sett dine parametere i innstillinger og juster etter genererte kjøps- og salgssignalene i strategy testeren.  Strategien vil automatisk sette dine take profit og stop loss nivåer.

    Evaluering og Justering: Overvåk ytelsen til strategien og gjør justeringer etter behov for å optimalisere resultatene.

## Source Code

````pine
//@version=5
strategy("Simple Fibonacci Retracement Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Input period for high and low points identification
lookback = input.int(100, title="Lookback Period", minval=10)

// Input to choose Fibonacci calculation direction
fib_direction = input.string(title="Fibonacci Direction", defval="Top to Bottom", options=["Top to Bottom", "Bottom to Top"])

// Input for Fibonacci levels
fib_level_236 = input.float(0.236, title="Fib 23.6% Level")
fib_level_382 = input.float(0.382, title="Fib 38.2% Level")
fib_level_50 = input.float(0.5, title="Fib 50% Level")
fib_level_618 = input.float(0.618, title="Fib 61.8% Level")

// Input to choose the level for entry signals
buy_entry_level = input.string(title="Buy Entry Level", defval="Fib 61.8%", options=["Fib 23.6%", "Fib 38.2%", "Fib 50%", "Fib 61.8%"])
sell_entry_level = input.string(title="Sell Entry Level", defval="Fib 38.2%", options=["Fib 23.6%", "Fib 38.2%", "Fib 50%", "Fib 61.8%"])

// Input for take profit and stop loss in pips
take_profit_pips = input.int(50, title="Take Profit (pips)")
stop_loss_pips = input.int(20, title="Stop Loss (pips)")

// Identify high and low points within the lookback period
highestHigh = ta.highest(high, lookback)
lowestLow = ta.lowest(low, lookback)

// Calculate Fibonacci levels based on the selected direction
var float fib_0 = na
var float fib_100 = na
var float fib_236 = na
var float fib_382 = na
var float fib_50 = na
var float fib_618 = na

if fib_direction == "Top to Bottom"
    fib_0 := highestHigh
    fib_100 := lowestLow
    fib_236 := highestHigh - (highestHigh - lowestLow) * fib_level_236
    fib_382 := highestHigh - (highestHigh - lowestLow) * fib_level_382
    fib_50 := highestHigh - (highestHigh - lowestLow) * fib_level_50
    fib_618 := highestHigh - (highestHigh - lowestLow) * fib_level_618
else
    fib_0 := lowestLow
    fib_100 := highestHigh
    fib_236 := lowestLow + (highestHigh - lowestLow) * fib_level_236
    fib_382 := lowestLow + (highestHigh - lowestLow) * fib_level_382
    fib_50 := lowestLow + (highestHigh - lowestLow) * fib_level_50
    fib_618 := lowestLow + (highestHigh - lowestLow) * fib_level_618

// Determine which level to use for buy and sell signals based on user input
var float buy_fib_level = na
var float sell_fib_level = na

if buy_entry_level == "Fib 23.6%"
    buy_fib_level := fib_236
if buy_entry_level == "Fib 38.2%"
    buy_fib_level := fib_382
if buy_entry_level == "Fib 50%"
    buy_fib_level := fib_50
if buy_entry_level == "Fib 61.8%"
    buy_fib_level := fib_618

if sell_entry_level == "Fib 23.6%"
    sell_fib_level := fib_236
if sell_entry_level == "Fib 38.2%"
    sell_fib_level := fib_382
if sell_entry_level == "Fib 50%"
    sell_fib_level := fib_50
if sell_entry_level == "Fib 61.8%"
    sell_fib_level := fib_618

// Convert pips to price units (assuming 1 pip = 0.0001 for currency pairs like EURUSD)
pip_value = syminfo.mintick * 10
take_profit = take_profit_pips * pip_value
stop_loss = stop_loss_pips * pip_value

// Trading signals
var bool longSignal = na
var bool shortSignal = na

if fib_direction == "Top to Bottom"
    longSignal := ta.crossover(close, buy_fib_level) and close > buy_fib_level
    shortSignal := ta.crossunder(close, sell_fib_level) and close < sell_fib_level
else
    longSignal := ta.crossover(close, buy_fib_level) and close > buy_fib_level
    shortSignal := ta.crossunder(close, sell_fib_level) and close < sell_fib_level

// Execute trades based on signals with take profit and stop loss
if (longSignal)
    strategy.entry("Long", strategy.long, comment="BUY")
    strategy.exit("Take Profit/Stop Loss", "Long", limit=close + take_profit, stop=close - stop_loss)

if (shortSignal)
    strategy.entry("Short", strategy.short, comment="SELL")
    strategy.exit("Take Profit/Stop Loss", "Short", limit=close - take_profit, stop=close + stop_loss)

// Plot Fibonacci levels
plot(fib_0, title="Fib 0%", color=color.blue, linewidth=1, style=plot.style_line)
plot(fib_236, title="Fib 23.6%", color=color.green, linewidth=1, style=plot.style_line)
plot(fib_382, title="Fib 38.2%", color=color.green, linewidth=1, style=plot.style_line)
plot(fib_50, title="Fib 50%", color=color.red, linewidth=1, style=plot.style_line)
plot(fib_618, title="Fib 61.8%", color=color.green, linewidth=1, style=plot.style_line)
plot(fib_100, title="Fib 100%", color=color.blue, linewidth=1, style=plot.style_line)

// Create labels for Fibonacci levels with white text
var label fibLabel0 = na
var label fibLabel236 = na
var label fibLabel382 = na
var label fibLabel50 = na
var label fibLabel618 = na
var label fibLabel100 = na

if (na(fibLabel0))
    fibLabel0 := label.new(bar_index, fib_0, text="Fib 0%", color=na, textcolor=color.white, style=label.style_label_right, yloc=yloc.price)
    fibLabel236 := label.new(bar_index, fib_236, text="Fib 23.6%", color=na, textcolor=color.white, style=label.style_label_right, yloc=yloc.price)
    fibLabel382 := label.new(bar_index, fib_382, text="Fib 38.2%", color=na, textcolor=color.white, style=label.style_label_right, yloc=yloc.price)
    fibLabel50 := label.new(bar_index, fib_50, text="Fib 50%", color=na, textcolor=color.white, style=label.style_label_right, yloc=yloc.price)
    fibLabel618 := label.new(bar_index, fib_618, text="Fib 61.8%", color=na, textcolor=color.white, style=label.style_label_right, yloc=yloc.price)
    fibLabel100 := label.new(bar_index, fib_100, text="Fib 100%", color=na, textcolor=color.white, style=label.style_label_right, yloc=yloc.price)
else
    label.set_xy(fibLabel0, bar_index, fib_0)
    label.set_xy(fibLabel236, bar_index, fib_236)
    label.set_xy(fibLabel382, bar_index, fib_382)
    label.set_xy(fibLabel50, bar_index, fib_50)
    label.set_xy(fibLabel618, bar_index, fib_618)
    label.set_xy(fibLabel100, bar_index, fib_100)

// Plot signals
plotshape(series=longSignal, location=location.belowbar, color=color.green, style=shape.labelup, title="Buy Signal", text="BUY")
plotshape(series=shortSignal, location=location.abovebar, color=color.red, style=shape.labeldown, title="Sell Signal", text="SELL")

// Plot highest and lowest points
plot(highestHigh, title="Highest High", color=color.purple, linewidth=2, offset=-lookback)
plot(lowestLow, title="Lowest Low", color=color.purple, linewidth=2, offset=-lookback)
````
