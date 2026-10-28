# Stockbee Momentum Burst

- url: https://www.tradingview.com/script/6h74IRYK-Stockbee-Momentum-Burst/
- type: indicator
- pine_id: PUB;5afdfd9d15094924a292973578d38ea9
- version: 4.0

## Description

[b]This is a script to color code bars based on the bullish- and bearish combination.[/b]

[b]Bullish Combination[/b]
Percent: Price >= 4% from yesterday and Volume today > Yesterday
Dollar: Price >= 0.9 dollar from open

Base Requirements
- Price > Yesterday's close
- Price > Open
- Price is within 30% of high
- Todays price range >= Yesterdays price range
- Yesterday's move <= 2%
- Volume >= 100 000

[b]Bearish Combination[/b]
Percent: Price <= 4% from yesterday and Volume today > Yesterday
Dollar: Price <= 0.9 dollar from open

Base Requirements
- Price < Yesterday's close
- Price < Open
- Price is within 30% of low
- Todays price range >= Yesterdays price range
- Yesterday's move >= -2%
- Minimum volume for each of last 3 days >= 100 000

[b]Momentum Filter[/b]
These are based on the 10 and 20 EMA crossover, where the former above would indicate upward momentum and below downward momentum. This can help to narrow down the color code to continuation phases. The linked option will override all other momentum filters, bullish candles will be displayed when EMA 10 > 20 and bearish candles when EMA 10 < 20.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shaaah10

//@version=5
indicator(title="Stockbee", overlay=true)

// INPUT
var string GP1 = 'MOMENTUM BURST'
input_percent_breakout = input.bool(defval=true, title="4 % Breakout", inline = "1", group = GP1)
color_percent_breakout = input.color(defval=color.rgb(27, 94 ,32), title = "", inline = "1", group = GP1)

input_dollar_breakout = input.bool(defval=true, title="Dollar Breakout", inline = "2", group = GP1)
color_dollar_breakout = input.color(defval=color.green, title = "", inline = "2", group = GP1)

input_percent_breakdown = input.bool(defval=true, title="4 % Breakdown", inline = "3", group = GP1)
color_percent_breakdown = input.color(defval=color.rgb(178, 40, 51), title = "", inline = "3", group = GP1)

input_dollar_breakdown = input.bool(defval=true, title="Dollar Breakdown", inline = "4", group = GP1)
color_dollar_breakdown = input.color(defval=color.red, title = "", inline = "4", group = GP1)

color_neutral_bullish = input.color(defval=color.rgb(200, 230, 201, 80), title = "Neutral Color ", inline = "5", group = GP1)
color_neutral_bearish = input.color(defval=color.rgb(252, 203, 205, 80), title = "", inline = "5", group = GP1)

var string GP2 = 'MOMENTUM FILTER'
input_momentum_bull = input.bool(defval=false, title="TI 65 > 1.05", group = GP2)
input_momentum_bear = input.bool(defval=false, title="TI 65 < 0.95", group = GP2)
input_momentum_linked = input.bool(defval=false, title="Linked", tooltip = "This will override all other momentum filters. Bullish candles will be displayed when TI65 is above 1.05 and bearish below 0.95.", group = GP2)

var string GP3 = "REVERSAL"
input_bull_reversal = input.bool(defval = false, title="Bullish", group = GP3)
input_bear_reversal = input.bool(defval = false, title="Bearish", group = GP3)
input_remove = input.bool(defval = false, title="Remove P/V", tooltip = "Check to remove the price and volume requirement.", group = GP3)
label_size = input.string("auto", "Label Size", options = ["huge", "large", "normal", "small", "tiny", "auto"], group = GP3)

// MOMENTUM BURST
percent_breakout = (close/close[1]>=1.04) and (close>open) and ((close-open)>=(close[1]-open[1])) and (close>close[1]) and (volume>=100000) and (volume>volume[1]) and ((close-low)/(high-low)>=0.7) and (close[1]/close[2]<=1.02)
dollar_breakout = (close-open>=0.9) and (close>open) and ((close-open)>=(close[1]-open[1])) and (close>close[1]) and (volume>=100000) and ((close-low)/(high-low)>=0.7) and (close[1]/close[2]<=1.02)
percent_breakdown = (close/close[1]<=0.96) and (close<open) and (close<close[1]) and (volume>=100000) and (volume>volume[1]) and (close[1]/close[2]>=0.98) and (ta.lowest(volume, 3) >= 100000) and (math.abs(open-close) >= math.abs(open[1]-close[1])) and ((close-low)/(high-low)<=0.3)
dollar_breakdown = (open-close>=0.9) and (close<open) and (close<close[1]) and (volume>=100000) and (close[1]/close[2]>=0.98) and (ta.lowest(volume, 3) >= 100000) and (math.abs(open-close) >= math.abs(open[1]-close[1])) and ((close-low)/(high-low)<=0.3)

// REVERSAL
bullish_reversal = (low == ta.lowest(low, 5)) and ((open-low) > (close-open)) and (((close-low)/(high-low)) >= 0.6) and (volume >= 900000) and (close >= 10) and (ta.lowest(volume, 3) >= 100000)
bullish_reversal_bypass = (low == ta.lowest(low, 5)) and ((open-low) > (close-open)) and (((close-low)/(high-low)) >= 0.6)
bearish_reversal = (volume >= 1000000) and (close >= 10) and (ta.lowest(volume, 3) >= 100000) and ((close[0]/close[1]) > 0.99) and (((close-low)/(high-low)) <= 0.8) and (ta.rsi(close, 3) >= 80)
bearish_reversal_bypass = ((close[0]/close[1]) > 0.99) and (((close-low)/(high-low)) <= 0.8) and (ta.rsi(close, 3) >= 80)

// MOMENTUM FILTER
bull_momentum = ta.sma(close, 7) / ta.sma(close, 65) >= 1.05 ? 1 : 0
bear_momentum = ta.sma(close, 7) / ta.sma(close, 65) <= 0.95 ? 1 : 0

// COLOR BAR
color_neutral = close > open ? color_neutral_bullish : close < open ? color_neutral_bearish : na
color_percent = percent_breakout ? color_percent_breakout : percent_breakdown ? color_percent_breakdown : color_neutral
color_dollar = dollar_breakout ? color_dollar_breakout : dollar_breakdown ? color_dollar_breakdown : color_neutral

color_bar = if ((input_percent_breakout and percent_breakout) or (input_percent_breakdown and percent_breakdown) == true)
    color_percent
else if ((input_dollar_breakout and dollar_breakout) or (input_dollar_breakdown and dollar_breakdown) == true)
    color_dollar
else
    color_neutral

color_momentum_combo = bull_momentum or bear_momentum ? color_bar : color_neutral
color_momentum_bull = bull_momentum ? color_bar : color_neutral
color_momentum_bear = bear_momentum ? color_bar : color_neutral
color_momentum_linked = bull_momentum and ((input_percent_breakout and percent_breakout) or (input_dollar_breakout and dollar_breakout)) ? color_bar : bear_momentum and ((input_percent_breakdown and percent_breakdown) or (input_dollar_breakdown and dollar_breakdown)) ? color_bar : color_neutral

print_color = if (input_momentum_linked == true)
    color_momentum_linked
else if (input_momentum_bull and input_momentum_bear == true)
    color_momentum_combo
else if (input_momentum_bull == true)
    color_momentum_bull
else if (input_momentum_bear == true)
    color_momentum_bear
else
    color_bar

// PLOT MOMENTUM BURST
barcolor(print_color)

// PLOT REVERSAL
if ((input_bull_reversal and bullish_reversal == true) and (input_remove == false))
    label_bull = label.new(bar_index[0], high, style=label.style_triangleup, size=label_size), label.set_yloc(label_bull, yloc.belowbar), label.set_color(label_bull, color.green), label.set_tooltip(label_bull, "Bullish Reversal")

if ((input_bear_reversal and bearish_reversal == true) and (input_remove == false))
    label_bear = label.new(bar_index[0], high, style=label.style_triangledown, size=label_size), label.set_yloc(label_bear, yloc.abovebar), label.set_color(label_bear, color.red), label.set_tooltip(label_bear, "Bearish Reversal")

if (input_bull_reversal and bullish_reversal_bypass and input_remove)
    label_bull_bypass = label.new(bar_index[0], high, style=label.style_triangleup, size=label_size), label.set_yloc(label_bull_bypass, yloc.belowbar), label.set_color(label_bull_bypass, color.green), label.set_tooltip(label_bull_bypass, "Bullish Reversal")

if (input_bear_reversal and bearish_reversal_bypass and input_remove)
    label_bear_bypass = label.new(bar_index[0], high, style=label.style_triangledown, size=label_size), label.set_yloc(label_bear_bypass, yloc.abovebar), label.set_color(label_bear_bypass, color.red), label.set_tooltip(label_bear_bypass, "Bearish Reversal")
````
