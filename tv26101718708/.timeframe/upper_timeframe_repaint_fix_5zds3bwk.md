# Upper Timeframe - Repaint Fix

- url: https://www.tradingview.com/script/5zds3bWk-Upper-Timeframe-Repaint-Fix/
- type: strategy
- pine_id: PUB;iNmdWLQIQEPGwpuRIPEYZb6cNf2bsSZH
- version: 1.0

## Description

This script is a proof of concept and one possible solution for how to deal with upper timeframe repainting issues. It works for [b]Strategies only[/b]. 

Strategies that utilize data from upper timeframes can still be subject to repainting issues when forward testing. Users can copy the code and use a similar solution in your own scripts. 

For full code commentary, explanations and examples visit the backtest-rookies (.com) website.

## Source Code

````pine
//@version=3
strategy("Dual RSI - RPB Study")

// Other time frame
otf = input(defval="15", title="Second Momentum Timeframe", type=resolution)
otf_period = input(defval=14, title="Look Back Period (2nd Timeframe)", type=integer)
ctf_period = input(defval=14, title="Look Back Period (Chart Timeframe)", type=integer)
ob = input(defval=70, title="Overbought Area", type=integer)
os = input(defval=30, title="Oversold Area", type=integer)

// Function to dectect a new bar
is_newbar(res) =>
    t = time(res)
    change(t) != 0 ? true : false

// Check how many bars are in our upper timeframe
since_new_bar = barssince(is_newbar(otf))
otf_total_bars = na
otf_total_bars := since_new_bar == 0 ? since_new_bar[1] : otf_total_bars[1]

//Get the data
otf_rsi = security(tickerid, otf, rsi(close, otf_period))

//Calculate RSI Values
ctf_rsi = rsi(close, ctf_period)

final_otf_rsi = na
final_otf_rsi := barstate.isrealtime ? since_new_bar == otf_total_bars ? otf_rsi : final_otf_rsi[1] : otf_rsi

//Plot
hline(ob, title='Overbought Line', color=black, linestyle=dashed, linewidth=1)
hline(os, title='Oversold Line', color=black, linestyle=dashed, linewidth=1)
plot(final_otf_rsi, title='OTF RSI', color=blue, style=line, linewidth=3)
plot(ctf_rsi, title='CTF RSI', color=green, style=line, linewidth=3)
//plot(otf_rsi, title='Non Adjusted OTF', color=blue, linewidth=3)
````
