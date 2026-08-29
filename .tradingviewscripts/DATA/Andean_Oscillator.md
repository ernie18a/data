<!-- tradingview-pine-id: PUB;7441081de58e4d2eaa5d9f6038caedec -->
<!-- tradingviewscripts-format: 1 -->
# Andean Oscillator

Source: https://www.tradingview.com/script/x9qYvBYN-Andean-Oscillator/

## Description

The following script is an original creation originally posted on the blog section of the broker Alpaca.

The proposed indicator aims to measure the degree of variations of individual up-trends and down-trends in the price, thus allowing to highlight the direction and amplitude of a current trend.

Settings

[*]Length : Determines the significance of the trends degree of variations measured by the indicator.
[*]Signal Length : Moving average period of the signal line.

Usage

[image]https://www.tradingview.com/x/OlvAvo5W/[/image]

The Andean Oscillator can return multiple information to the user, with its core interpretation revolving around the bull and bear components.

A rising bull component (in green) indicates the presence of bullish price variations while a rising bear component (in red) indicates the presence of bearish price variations.

When the bull component is over the bear component market is up-trending, and the user can expect new higher highs. When the bear component is over the bull component market is down-trending, and the user can expect new lower lows.

The signal line (in orange) allows a more developed interpretation of the indicator and can be used in several ways.

It is possible to use it to filter out potential false signals given by the crosses between the bullish and bearish components. As such the user might want to enter a position once the bullish or bearish component crosses over the signal line instead.

Details

Measuring the degree of variations of trends in the price by their direction (up-trend/down-trend) can be done in several way. 
The approach taken by the proposed indicator makes use of exponential envelopes and the naive computation of standard deviation. 

First, exponential envelopes are obtained from both the regular prices and squared prices, thus giving two upper extremities, and two lower extremities.

The bullish component is obtained by first subtracting the upper extremity of the squared prices with the squared upper extremity of regular prices, the square root is then applied to this result.

The bearish component is obtained in the same way, but makes use of the lower extremities of the exponential envelopes.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © alexgrover

//Original post : Alpaca.markets/learn/andean-oscillator-a-new-technical-indicator-based-on-an-online-algorithm-for-trend-analysis/

//@version=5
indicator("Andean Oscillator")
//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
length     = input(50)

sig_length = input(9,'Signal Length')

//-----------------------------------------------------------------------------}
//Exponential Envelopes
//-----------------------------------------------------------------------------{
var alpha = 2/(length+1)

var up1 = 0.,var up2 = 0.
var dn1 = 0.,var dn2 = 0.

C = close
O = open

up1 := nz(math.max(C, O, up1[1] - (up1[1] - C) * alpha), C)
up2 := nz(math.max(C * C, O * O, up2[1] - (up2[1] - C * C) * alpha), C * C)

dn1 := nz(math.min(C, O, dn1[1] + (C - dn1[1]) * alpha), C)
dn2 := nz(math.min(C * C, O * O, dn2[1] + (C * C - dn2[1]) * alpha), C * C)

//Components
bull = math.sqrt(dn2 - dn1 * dn1)
bear = math.sqrt(up2 - up1 * up1)

signal = ta.ema(math.max(bull, bear), sig_length)

//-----------------------------------------------------------------------------}
//Plots
//-----------------------------------------------------------------------------{
plot(bull, 'Bullish Component', #089981)

plot(bear, 'Bearish Component', #f23645)

plot(signal, 'Signal', #ff9800)

//-----------------------------------------------------------------------------}
````
