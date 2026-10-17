# Non-Repainting Renko Emulation Strategy [PineIndicators]

- url: https://www.tradingview.com/script/cwGp0ul5-Non-Repainting-Renko-Emulation-Strategy-PineIndicators/
- type: strategy
- pine_id: PUB;edfe9e83fe234192a15bf5555df3d0df
- version: 1.0

## Description

[b]Introduction: The Repainting Problem in Renko Strategies[/b]
Renko charts are widely used in technical analysis for their ability to filter out market noise and emphasize price trends. Unlike traditional candlestick charts, which are based on fixed time intervals, Renko charts construct bricks only when price moves by a predefined amount. This makes them useful for trend identification while reducing small fluctuations.

However, Renko-based trading strategies often fail in live trading due to a fundamental issue: [b]repainting[/b].

[b]Why Do Renko Strategies Repaint?[/b]
Most trading platforms, including TradingView, generate Renko charts retrospectively based on historical price data. This leads to the following issues:

[list]
[*] Renko bricks can change or disappear when new data arrives.
[*] Backtesting results do not reflect real market conditions. Strategies may appear highly profitable in backtests because historical data is recalculated with hindsight.
[*] Live trading produces different results than backtesting. Traders cannot know in advance whether a new Renko brick will form until price moves far enough.
[/list]

[b]Objective of the Renko Emulator[/b]
This script simulates Renko behavior on a standard time-based chart without repainting. Instead of using TradingView’s built-in Renko charting, which recalculates past bricks, this approach ensures that once a Renko brick is formed, [b]it remains unchanged[/b].

[b]Key benefits:[/b]
[list]
[*] No past bricks are recalculated or removed.
[*] Trading strategies can execute reliably without false signals.
[*] Renko-based logic can be applied on a time-based chart.
[/list]

[b]How the Renko Emulator Works[/b]
[b]1. Parameter Configuration & Initialization[/b]
The script defines key user inputs and variables:

[list]
[*] [b]brickSize[/b]: Defines the Renko brick size in price points, adjustable by the user.
[*] [b]renkoPrice[/b]: Stores the closing price of the last completed Renko brick.
[*] [b]prevRenkoPrice[/b]: Stores the price level of the previous Renko brick.
[*] [b]brickDir[/b]: Tracks the direction of Renko bricks (1 = up, -1 = down).
[*] [b]newBrick[/b]: A boolean flag that indicates whether a new Renko brick has been formed.
[*] [b]brickStart[/b]: Stores the bar index at which the current Renko brick started.
[/list]

[b]2. Identifying Renko Brick Formation Without Repainting[/b]
To ensure that the strategy does not repaint, Renko calculations are performed only on confirmed bars.

[list=1]
[*] The script calculates the difference between the current price and the last Renko brick level.
[*] If the absolute price difference meets or exceeds the brick size, a new Renko brick is formed.
[*] The [b]new Renko price level is updated[/b] based on the number of bricks that would fit within the price movement.
[*] The [b]direction (brickDir) is updated[/b], and a flag ([b]newBrick[/b]) is set to indicate that a new brick has been formed.
[/list]

[b]3. Visualizing Renko Bricks on a Time-Based Chart[/b]
Since TradingView does not support live Renko charts without repainting, the script uses graphical elements to draw Renko-style bricks on a standard chart.

Each time a new Renko brick forms, a colored rectangle (box) is drawn:

[list]
[*] [b]Green boxes[/b] → Represent [b]bullish[/b] Renko bricks.
[*] [b]Red boxes[/b] → Represent [b]bearish[/b] Renko bricks.
[/list]

This allows traders to see Renko-like formations on a time-based chart, while ensuring that past bricks do not change.

[b]Trading Strategy Implementation[/b]
Since the Renko emulator provides a stable price structure, it is possible to apply a consistent trading strategy that would otherwise fail on a traditional Renko chart.

[b]1. Entry Conditions[/b]
A long trade is entered when:
[list]
[*] The previous Renko brick was [b]bearish[/b].
[*] The new Renko brick confirms an [b]upward trend[/b].
[*] There is no existing [b]long position[/b].
[/list]

A short trade is entered when:
[list]
[*] The previous Renko brick was [b]bullish[/b].
[*] The new Renko brick confirms a [b]downward trend[/b].
[*] There is no existing [b]short position[/b].
[/list]

[b]2. Exit Conditions[/b]
Trades are closed when a trend reversal is detected:

[list]
[*] Long trades are closed when a new bearish brick forms.
[*] Short trades are closed when a new bullish brick forms.
[/list]

[b]Key Characteristics of This Approach[/b]
[b]1. No Historical Recalculation[/b]
[list]
[*] Once a Renko brick forms, it remains fixed and does not change.
[*] Past price action does not shift based on future data.
[/list]

[b]2. Trading Strategies Operate Consistently[/b]
[list]
[*] Since the Renko structure is stable, strategies can execute without unexpected changes in signals.
[*] Live trading results align more closely with backtesting performance.
[/list]

[b]3. Allows Renko Analysis Without Switching Chart Types[/b]
[list]
[*] Traders can apply Renko logic without leaving a standard time-based chart.
[*] This enables integration with indicators that normally cannot be used on traditional Renko charts.
[/list]

[b]Considerations When Using This Strategy[/b]
[list]
[*] Trade execution may be delayed compared to standard Renko charts. Since new bricks are only confirmed on closed bars, entries may occur slightly later.
[*] Brick size selection is important. A smaller [b]brickSize[/b] results in more frequent trades, while a larger [b]brickSize[/b] reduces signals.
[/list]

[b]Conclusion[/b]
This Renko Emulation Strategy provides a method for using Renko-based trading strategies on a time-based chart without repainting. By ensuring that bricks do not change once formed, it allows traders to use stable Renko logic while avoiding the issues associated with traditional Renko charts.

This approach enables accurate backtesting and reliable live execution, making it suitable for trend-following and swing trading strategies that rely on Renko price action.

## Source Code

````pine
//@version=5
strategy("Non-Repainting Renko Emulation Strategy [PineIndicators]", overlay=true, calc_on_every_tick=false, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, initial_capital = 10000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.01, slippage = 2)

// Parameter: Brick-Größe (z.B. 10 Punkte)
brickSize = input.float(3.0, "Brick Size", step=0.1)

// Persistente Variablen
var float renkoPrice     = na    // Aktueller Renko-Level (Schlusswert des letzten Bricks)
var float prevRenkoPrice = na    // Vorheriger Renko-Level (für Box-Berechnung)
var int   brickDir       = 0     // 1 = Aufwärts, -1 = Abwärts
var bool  newBrick       = false // Signalisiert, dass ein neuer Brick abgeschlossen wurde
var int   brickStart     = bar_index  // Beginn des aktuellen Bricks (x-Achse)

// Berechnungen nur auf abgeschlossenen Candles
if barstate.isconfirmed
    newBrick := false
    // Initialisierung: Beim ersten Candle setzen wir den Renko-Level
    if na(renkoPrice)
        renkoPrice := close
        brickStart := bar_index
    // Berechne die Differenz zum letzten Renko-Level
    diff = close - renkoPrice
    // Prüfen, ob der Unterschied mindestens der Brick-Größe entspricht
    if math.abs(diff) >= brickSize
        // Anzahl kompletter Bricks (kann > 1 sein)
        numBricks = math.floor(math.abs(diff) / brickSize)
        prevRenkoPrice := renkoPrice
        // Aktualisieren des Renko-Levels
        renkoPrice := renkoPrice + numBricks * brickSize * math.sign(diff)
        // Brick-Richtung (konvertiere math.sign-Ergebnis in int)
        brickDir := int(math.sign(diff))
        newBrick := true

        // Bestimme die obere und untere Grenze des abgeschlossenen Bricks:
        lowLevel  = brickDir == 1 ? prevRenkoPrice : renkoPrice
        highLevel = brickDir == 1 ? renkoPrice     : prevRenkoPrice

        // Zeichne einen farbigen Kasten (Box) für den Brick:
        // Parameter: left, top, right, bottom
        box.new(brickStart, highLevel, bar_index, lowLevel,border_width = 1, border_color = brickDir == 1 ? color.green : color.red, bgcolor = brickDir == 1 ? color.new(color.green, 70) : color.new(color.red, 70))
            
        // Setze den Start für den nächsten Brick
        brickStart := bar_index


// Handelslogik: Einstieg/Ausstieg nur, wenn ein neuer Brick abgeschlossen wurde
if barstate.isconfirmed and newBrick
    // Bei Aufwärts-Brick: Long-Signal
    if brickDir[brickSize] < brickDir and renkoPrice[brickSize] < renkoPrice[brickSize*2] and renkoPrice < renkoPrice[brickSize] and renkoPrice[brickSize*2] < renkoPrice[brickSize*3] and strategy.position_size <= 0
        // Bestehende Short-Position schließen, falls vorhanden
        strategy.entry("Long", strategy.long)

    // Bei Abwärts-Brick: Short-Signal
    else if brickDir[brickSize] > brickDir and renkoPrice[brickSize] > renkoPrice[brickSize*2] and renkoPrice > renkoPrice[brickSize] and renkoPrice[brickSize*2] > renkoPrice[brickSize*3] and strategy.position_size >= 0
        // Bestehende Long-Position schließen, falls vorhanden
        strategy.entry("Short", strategy.short)

if barstate.isconfirmed and newBrick
    if brickDir[brickSize] < brickDir
        strategy.close("Short")

    else if brickDir[brickSize] > brickDir
        strategy.close("Long")
````
