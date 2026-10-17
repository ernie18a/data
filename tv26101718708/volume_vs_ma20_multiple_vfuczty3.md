# Volume vs MA20 Multiple

- url: https://www.tradingview.com/script/vfUcZTY3/
- type: indicator
- pine_id: PUB;846a6b9cb642483782f06dfaacfea021
- version: 1.0

## Description

[b]Volume vs MA20 Multiple[/b]

This indicator shows how the current candle’s volume compares to its moving average volume.

Instead of only displaying raw volume, it calculates a volume multiple relative to the selected volume moving average, for example:

[list]
[*]1.0x = current volume equals the volume moving average
[*]1.2x = current volume is 20% above average
[*]1.5x = current volume is 50% above average
[*]2.0x = current volume is twice the average volume
[/list]

The default setting uses a 20-period volume moving average, which means:

[list]
[*]on the 1H chart, it compares the current hourly volume to the average of the last 20 hourly candles
[*]on the daily chart, it compares the current daily volume to the average of the last 20 daily candles
[*]on any timeframe, it automatically adapts to the selected chart timeframe
[/list]

This makes it easier to judge whether a breakout, reversal, or pullback move is supported by meaningful volume.

How I use it

For breakout trades, I usually want to see price breaking above a key level while volume is clearly above average.

Typical interpretation:

[list]
[*]Below 1.0x: weak / below-average volume
[*]Around 1.0x: normal volume
[*]1.2x – 1.5x: increased volume, potential confirmation
[*]1.5x – 2.0x: strong volume confirmation
[*]Above 2.0x: very strong participation
[/list]

The indicator can display both the multiple and the percentage above the moving average, making it useful for quickly validating whether a price move has real participation behind it.

[list]
[*]Best used for
[*]Breakout confirmation
[*]Pullback entries
[*]Reversal setups
[*]Intraday momentum analysis
[*]Comparing volume strength across different timeframes
[/list]

This indicator is not a standalone buy or sell signal. It is intended to be used together with price action, support/resistance, trend structure, and risk management.

## Source Code

````pine
//@version=6
indicator("Volume vs MA20 Multiple", shorttitle="Vol x MA20", overlay=false)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
volMaLength = input.int(20, "Volumen MA Länge", minval=1)
showPercent = input.bool(false, "Als % über MA anzeigen")
showTable   = input.bool(true, "Info-Box anzeigen")

// Schwellenwerte
level1 = input.float(1.0, "Level 1", step=0.1)
level2 = input.float(1.2, "Level 2", step=0.1)
level3 = input.float(1.5, "Level 3", step=0.1)
level4 = input.float(2.0, "Level 4", step=0.1)

// ─────────────────────────────────────────────
// Berechnung
// ─────────────────────────────────────────────
volMa = ta.sma(volume, volMaLength)
volMultiple = volMa > 0 ? volume / volMa : na
volPercentAbove = (volMultiple - 1.0) * 100

plotValue = showPercent ? volPercentAbove : volMultiple

// ─────────────────────────────────────────────
// Farben nach Stärke
// ─────────────────────────────────────────────
barColor =
     volMultiple >= 2.0 ? color.new(color.lime, 0) :
     volMultiple >= 1.5 ? color.new(color.green, 0) :
     volMultiple >= 1.2 ? color.new(color.orange, 0) :
     volMultiple >= 1.0 ? color.new(color.gray, 0) :
                          color.new(color.red, 0)

// ─────────────────────────────────────────────
// Plot
// ─────────────────────────────────────────────
plot(
     plotValue,
     title="Volumen relativ zu MA20",
     style=plot.style_columns,
     color=barColor
)

// Referenzlinien
hline(showPercent ? 0 : 1.0, "1.0x / MA20", color=color.gray, linestyle=hline.style_dotted)
hline(showPercent ? 20 : 1.2, "1.2x / +20%", color=color.orange, linestyle=hline.style_dotted)
hline(showPercent ? 50 : 1.5, "1.5x / +50%", color=color.green, linestyle=hline.style_dotted)
hline(showPercent ? 100 : 2.0, "2.0x / +100%", color=color.lime, linestyle=hline.style_dotted)

// ─────────────────────────────────────────────
// Info-Box rechts oben
// ─────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 4, border_width=1)

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "Volumen", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(infoTable, 1, 0, str.tostring(volume, format.volume), text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(infoTable, 0, 1, "Vol MA" + str.tostring(volMaLength), text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(infoTable, 1, 1, str.tostring(volMa, format.volume), text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(infoTable, 0, 2, "Multiple", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(infoTable, 1, 2, str.tostring(volMultiple, "#.##") + "x", text_color=color.white, bgcolor=barColor)

    table.cell(infoTable, 0, 3, "% über MA", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(infoTable, 1, 3, str.tostring(volPercentAbove, "#.##") + "%", text_color=color.white, bgcolor=barColor)
````
