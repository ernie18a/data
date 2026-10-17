# Triangular Hull Moving Average [BigBeluga X PineIndicators]

- url: https://www.tradingview.com/script/gMeYb8Dp-Triangular-Hull-Moving-Average-BigBeluga-X-PineIndicators/
- type: strategy
- pine_id: PUB;c3aff79ca231439db7bdfad70196c1a2
- version: 1.0

## Description

This strategy is based on the original Triangular Hull Moving Average (THMA) + Volatility indicator by BigBeluga. Full credit for the concept and design goes to BigBeluga.

The strategy blends smoothed trend-following logic using a Triangular Hull Moving Average with dynamic volatility overlays, providing actionable trade signals with responsive visual feedback. It's designed for traders who want a non-lagging trend filter while also monitoring market volatility in real time.

[b]How the Strategy Works[/b]
[b]1. Triangular Hull Moving Average (THMA) Core[/b]
At its core, the strategy uses a Triangular Hull Moving Average (THMA) — a variation of the traditional Hull Moving Average with triple-smoothing logic:
[list]
[*] It combines multiple weighted moving averages (WMAs) to create a faster and smoother trend line.
[*] This reduces lag without compromising trend accuracy.
[*] The THMA reacts more responsively to price movements than classic MAs.
[/list]

[b]THMA Formula:[/b]
thma(_src, _length) =>  
    ta.wma(ta.wma(_src,_length / 3) * 3 - ta.wma(_src, _length / 2) - ta.wma(_src, _length), _length)

This logic filters out short-term noise while still being sensitive to genuine trend shifts.

[b]2. Volatility-Enhanced Candle Plotting[/b]
An optional volatility mode overlays the chart with custom candles that incorporate volatility bands:
[list]
[*] Wicks expand and contract dynamically based on market volatility.
[*] The volatility value is computed using a HMA of high-low range over a user-defined length.
[*] The candle bodies reflect THMA values, while the wicks reflect the current volatility spread.
[/list]

This feature allows traders to visually gauge the strength of price moves and anticipate possible breakouts or slowdowns.

[b]3. Trend Reversal Signal Detection[/b]
The strategy identifies trend reversals when the THMA line crosses over/under its own past value:
[list]
[*] A bullish signal is triggered when THMA crosses above its value from two bars ago.
[*] A bearish signal is triggered when THMA crosses below its value from two bars ago.
[*] These shifts are marked on the chart with triangle-shaped signals for clear visibility.
[/list]

This logic helps detect momentum shifts early and enables reactive trade entries.

[b]Trade Entry & Exit Logic[/b]
[b]Trade Modes Supported[/b]
Users can choose between:
[list]
[*] Only Long – Enters long trades only.
[*] Only Short – Enters short trades only.
[*] Long & Short – Enables both directions.
[/list]

[b]Entry Conditions[/b]
[list]
[*] Long Entry:

Triggered when a bullish crossover is detected.

Active only if the strategy mode allows long trades.

[*] Short Entry:

Triggered when a bearish crossover is detected.

Active only if the strategy mode allows short trades.
[/list]

[b]Exit Conditions[/b]
[list]
[*] In Only Long mode, the strategy closes long positions when a bearish signal appears.
[*] In Only Short mode, the strategy closes short positions when a bullish signal appears.
[/list]

In Long & Short mode, the strategy does not auto-close positions — instead, it opens new positions on each confirmed signal.

[b]Dashboard Visualization[/b]
In the bottom-right corner of the chart, a live dashboard displays:
[list]
[*] The current trend direction (🢁 for bullish, 🢃 for bearish).
[*] The current volatility level as a percentage.
[/list]

This helps traders quickly assess market status and adjust their decisions accordingly.

[b]Customization Options[/b]
[list]
[*] THMA Length: Adjust how smooth or reactive the trend detection should be.
[*] Volatility Toggle & Length: Enable or disable volatility visualization and set sensitivity.
[*] Color Settings: Choose colors for up/down trend visualization.
[*] Trade Direction Mode: Limit the strategy to long, short, or both types of trades.
[/list]

[b]Use Cases & Strategy Strengths[/b]
[b]1. Trend Following
Use the THMA-based candles and triangle signals to enter with momentum. The indicator adapts quickly, reducing lag and improving trade timing.

[b]2. Volatility Monitoring
Visualize the strength of the trend with volatility wicks. Use expanding bands to confirm breakouts and contracting ones to detect weakening moves.

[b]3. Signal Confirmation
Combine this tool with other indicators or use the trend shift triangles as confirmations for manual entries.

[b]Conclusion[/b]
The THMA + Volatility Strategy is a [b]non-repainting trend-following system[/b] that integrates:
[list]
[*] Triangular Hull MA for advanced trend detection.
[*] Real-time volatility visualization.
[*] Clear entry signals based on trend reversals.
[*] Configurable trade direction settings.
[/list]

It is ideal for traders who:
[list]
[*] Prefer smoothed price analysis.
[*] Want to follow trends with precision.
[*] Value visual volatility feedback for breakout detection.
[/list]

[b]Full credit for the original concept and indicator goes to BigBeluga.[/b]

## Source Code

````pine
//@version=6
strategy("Triangular Hull Moving Average [BigBeluga X PineIndicators]", "THMA [BigBeluga X PineIndicators]", overlay = true, commission_value = 0.01, slippage = 2, initial_capital = 1000, margin_long = 0, margin_short = 0, default_qty_value = 1)

// ＩＮＰＵＴＳ
int  len_  = input.int(40, "Length")
float source = input.source(close, "Source")
bool volat = input.bool(true, "Volatility", inline = "vola"), len_vol = input.int(15, "", inline = "vola")
color_u = input.color(#16e5a0, "", inline = "colors")
color_d = input.color(#741ddd, "", inline = "colors")

// Neue Option: Entry Direction Auswahl
entry_mode = input.string("Long & Short", "Trade Direction", options = ["Only Long", "Only Short", "Long & Short"])

// ＣＡＬＣＵＬＡＴＩＯＮＳ
float volatility = ta.hma(high - low, len_vol)
var string trend = ""

vv = ta.percentile_nearest_rank(volatility, 1000, 100)
vol = volatility / vv

// THMA-Funktion
thma(_src, _length) =>  
    ta.wma(ta.wma(_src, _length / 3) * 3 - ta.wma(_src, _length / 2) - ta.wma(_src, _length), _length)

float thma  = thma(source, len_)
float thma1 = thma[2]

bool signal_up = ta.crossover(thma, thma1)
bool signal_dn = ta.crossunder(thma, thma1)

switch
    signal_up => trend := "🢁"
    signal_dn => trend := "🢃"

color  = thma > thma1 ? color_u : color_d
color1 = color

atr = ta.atr(200)

// ＰＬＯＴ
plotcandle(thma, thma + volatility, thma1 - volatility, thma1, "", color.new(color1, volat ? 40 : 0), color.new(color1, volat ? 40 : 100), bordercolor = color.new(color1,0))

plotshape(signal_up ? thma1 - atr : na, "Up", shape.triangleup, location.absolute, color = color.new(color, 60), size = size.small, force_overlay = true)
plotshape(signal_up ? thma1 - atr : na, "Up", shape.triangleup, location.absolute, color = color.new(color, 0), size = size.tiny, force_overlay = true)

plotshape(signal_dn ? thma1 + atr : na, "Dn", shape.triangledown, location.absolute, color = color.new(color, 60), size = size.small, force_overlay = true)
plotshape(signal_dn ? thma1 + atr : na, "Dn", shape.triangledown, location.absolute, color = color.new(color, 0), size = size.tiny, force_overlay = true)

if barstate.islast
    dash = table.new(position.bottom_right, 10, 10, bgcolor = color.new(chart.fg_color, 90), border_color = chart.bg_color, border_width = 5)
    dash.cell(0, 0, "Trend: " + trend, text_color = trend == "🢃" ? color_d : color_u)
    dash.cell(0, 1, "Volatility: " + str.tostring(vol * 100, format.percent), text_color = chart.fg_color)

// Entry- und Close-Logik
bool allow_long  = entry_mode == "Only Long" or entry_mode == "Long & Short"
bool allow_short = entry_mode == "Only Short" or entry_mode == "Long & Short"

// Long & Short-Modus: Positions eröffnen
if signal_up and allow_long
    strategy.entry("Long", strategy.long)

if signal_dn and allow_short
    strategy.entry("Short", strategy.short)

// Spezielle Schließlogik für "Only Long" und "Only Short"
if entry_mode == "Only Long"
    // Bei Short-Signal bestehende Long-Position schließen
    if signal_dn
        strategy.close("Long")

if entry_mode == "Only Short"
    // Bei Long-Signal bestehende Short-Position schließen
    if signal_up
        strategy.close("Short")
````
