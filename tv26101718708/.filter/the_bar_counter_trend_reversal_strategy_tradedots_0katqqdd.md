# The Bar Counter Trend Reversal Strategy [TradeDots]

- url: https://www.tradingview.com/script/0KAtQQDD-The-Bar-Counter-Trend-Reversal-Strategy-TradeDots/
- type: strategy
- pine_id: PUB;5ac70a223eed41a991aa7f2140d06d9b
- version: 1.0

## Description

[b]Overview[/b]
The Bar Counter Trend Reversal Strategy is designed to identify potential counter-trend reversal points in the market after a series of consecutive rising or falling bars. 

By analyzing price movements in conjunction with optional volume confirmation and channel bands (Bollinger Bands or Keltner Channels), this strategy aims to detect overbought or oversold conditions where a trend reversal may occur.

[b]🔹How it Works[/b]

[i]Consecutive Price Movements[/i]
[b]Rising Bars:[/b] The strategy detects when there are a specified number of consecutive rising bars (No. of Rises).
[b]Falling Bars:[/b] Similarly, it identifies a specified number of consecutive falling bars (No. of Falls).

[image]https://www.tradingview.com/x/MM6q3XUB/[/image]

[i]Volume Confirmation (Optional)[/i]
When enabled, the strategy checks for increasing volume during the consecutive price movements, adding an extra layer of confirmation to the potential reversal signal.

[i]Channel Confirmation (Optional)[/i]
[b]Channel Type:[/b] Choose between Bollinger Bands ("BB") or Keltner Channels ("KC").
[b]Channel Interaction:[/b] The strategy checks if the price interacts with the upper or lower [b]channel lines:[/b] For short signals, it looks for price moving above the upper channel line. For long signals, it looks for price moving below the lower channel line.

[i]Customization:[/i]
[b]No. of Rises/Falls:[/b] Set the number of consecutive bars required to trigger a signal.
[b]Volume Confirmation:[/b] Enable or disable volume as a confirmation factor.
[b]Channel Confirmation:[/b] Enable or disable channel bands as a confirmation factor.
[b]Channel Settings:[/b] Adjust the length and multiplier for the Bollinger Bands or Keltner Channels.

[i]Visual Indicators:[/i]
[b]Entry Signals:[/b] Triangles plotted on the chart indicate potential entry points:
Green upward triangle for long entries.
Red downward triangle for short entries.
[b]Channel Bands:[/b] The upper and lower bands are plotted for visual reference.

[i]Strategy Parameters:[/i]
Initial Capital: $10,000.
Position Sizing: 80% of equity per trade.
Commission: 0.01% per trade to simulate realistic trading costs.

[b]🔹Usage[/b]
Set up the number of Rises/Falls and choose whether if you want to use channel indicators and volume as the confirmation. 

Monitor the chart for triangles indicating potential entry points.

Consider the context of the overall market trend and other technical factors.

[i]Backtesting and Optimization:[/i]
Use TradingView's Strategy Tester to evaluate performance.
Adjust parameters to optimize results for different market conditions.

[b]🔹 Considerations and Recommendations[/b]

[i]Risk Management:[/i]
The strategy does not include built-in stop-loss or take-profit levels. It's recommended to implement your own risk management techniques.

[i]Market Conditions:[/i]
Performance may vary in different market environments. Testing and adjustments are advised when applying the strategy to new instruments or timeframes.

[i]No Guarantee of Future Results:[/i]
Past performance is not indicative of future results. Always perform due diligence and consider the risks involved in trading.

## Source Code

````pine
//@version=5
strategy(title="The Bar Counter Trend Reversal Strategy [TradeDots]", overlay=true, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 80, commission_type = strategy.commission.percent, commission_value = 0.01)

// Initialize variables
var bool rise_triangle_ready = false
var bool fall_triangle_ready = false
var bool rise_triangle_plotted = false
var bool fall_triangle_plotted = false

//Strategy condition setup
noOfRises = input.int(3, "No. of Rises", minval=1, group="STRATEGY")
noOfFalls = input.int(3, "No. of Falls", minval=1, group="STRATEGY")
volume_confirm = input.bool(false, "Volume Confirmation", group="STRATEGY")

channel_confirm = input.bool(true, "", inline="CHANNEL", group="STRATEGY")
channel_type = input.string("KC", "", inline="CHANNEL", options=["BB", "KC"],group="STRATEGY")
channel_source = input(close, "", inline="CHANNEL", group="STRATEGY")
channel_length = input.int(20, "", inline="CHANNEL", minval=1,group="STRATEGY")
channel_mult = input.int(2, "", inline="CHANNEL", minval=1,group="STRATEGY")

//Get channel line information
[_, upper, lower] = if channel_type == "KC"
    ta.kc(channel_source, channel_length,channel_mult)
else 
    ta.bb(channel_source, channel_length,channel_mult)

//Entry Condition Check
if channel_confirm and volume_confirm
    rise_triangle_ready := ta.falling(close, noOfFalls) and ta.rising(volume, noOfFalls) and high > upper
    fall_triangle_ready := ta.rising(close, noOfRises) and ta.rising(volume, noOfRises) and low < lower

else if channel_confirm
    rise_triangle_ready := ta.falling(close, noOfFalls) and low < lower
    fall_triangle_ready := ta.rising(close, noOfRises) and high > upper 

else if volume_confirm
    rise_triangle_ready := ta.falling(close, noOfFalls) and ta.rising(volume, noOfFalls)
    fall_triangle_ready := ta.rising(close, noOfRises) and ta.rising(volume, noOfRises)
else
    rise_triangle_ready := ta.falling(close, noOfFalls)
    fall_triangle_ready := ta.rising(close, noOfRises)

// Check if trend is reversed
if close > close[1]
    rise_triangle_plotted := false  // Reset triangle plotted flag

if close < close[1]
    fall_triangle_plotted := false

//Wait for bar close and enter trades
if barstate.isconfirmed
    // Plot triangle when ready and counts exceed threshold
    if rise_triangle_ready and not rise_triangle_plotted 
        label.new(bar_index, low, yloc = yloc.belowbar, style=label.style_triangleup, color=color.new(#9CFF87,10))
        strategy.entry("Long", strategy.long)
        rise_triangle_plotted := true
        rise_triangle_ready := false  // Prevent plotting again until reset

    if fall_triangle_ready and not fall_triangle_plotted
        label.new(bar_index, low, yloc = yloc.abovebar, style=label.style_triangledown, color=color.new(#F9396A,10))
        strategy.entry("Short", strategy.short)
        fall_triangle_plotted := true
        fall_triangle_ready := false

// plot channel bands
plot(upper, color = color.new(#56CBF9, 70), linewidth = 3, title = "Upper Channel Line")
plot(lower, color = color.new(#56CBF9, 70), linewidth = 3, title = "Lower Channel Line")
````
