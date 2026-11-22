# Geometric Brownian Motion Band

- url: https://www.tradingview.com/script/dPUa0oqf-Geometric-Brownian-Motion-Band/
- type: indicator
- pine_id: PUB;ShRqmWE8M07vV57Pd385C8J22n8x7un3
- version: 1.0

## Description

If you are an option trader, who are constantly searching opportunities to set up inverse iron condor position or other strategies, you must be familiar in estimating the range induced by Geometric Brownian Motion (GBM), or Lognormal distribution someone may call.

The theory behind is adopted in the Black Scholes Option Pricing model, this assumes the asset price follows the GBM, shown below, and estimates the range where the price will fall into on the specific date and probability. 

    dS = a dt + v dW

Assuming the drift term is zero, this [b]GBM Band[/b] applies the same model and helps you to quickly assess the suitable range to set up your option strategies with simple setting: 
Length – number of bars covered
Vol Multiple - the z-score of the probability

Default values of the Length and Vol Multiple are set to 20 bars and 2.0 z-score respectively.
You can find an example how the [b]GMB Band[/b] work. 

You can also applies this [b]GMB Band[/b] like how Bollinger's Band does for swing trade or breakaway trade. 


If you find this indicator is useful to you, Star it, Follow, Donate, Like and Share.
Your support is a highly motivation for me.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © earnSmartAlgorithm
// All Right Reserved @2020

//@version=4
study("Geometric Brownian Motion Band", shorttitle = "GBM Band", overlay = true)


// Getting inputs
Len  = input(title = "Length", type = input.integer, defval = 20)
K    = input(title = "Volatility Multiple", type = input.float, defval = 2.0)


xCr  = log(close / close[1])
gb   = sma(close, Len)
gbmp = gb * exp(K  * stdev(xCr, Len - 1) * sqrt(Len))
gbmm = gb * exp(-K * stdev(xCr, Len - 1) * sqrt(Len))


// Plot
b0 = plot(gb,   title = "GMB 0", color = #f44336, transp = 0, linewidth = 1)
bp = plot(gbmp, title = "GBM +", color = #2a21f3, transp = 100, display = display.none)
bm = plot(gbmm, title = "GBM -", color = #2a21f3, transp = 100, display = display.none)

fill(bp, bm, title = "GBM Band", color = #ffffff, transp = 90)
````
