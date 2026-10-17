# Sathish SMA Ribbon 5/10/20/50/100/150/200

- url: https://www.tradingview.com/script/zOtCgk90-Sathish-SMA-Ribbon-5-10-20-50-100-150-200/
- type: indicator
- pine_id: PUB;8713885c62cd4283b13c5bfaa6442401
- version: 1.0

## Description

SMA RIBBON, a multi–moving average ribbon using 7 Simple Moving Averages (SMAs): 5, 10, 20, 50, 100, 150, and 200 periods.

It allows custom color inputs for each SMA, so you can visually distinguish short-term momentum (like SMA 5, 10, 20) from longer-term trend indicators (50–200). Each SMA is calculated using ta.sma(close, length) and plotted with a consistent line width for clarity.

The purpose of this script is to give a quick visual hierarchy of trend strength and alignment—when shorter SMAs are above longer ones, it suggests a strong uptrend (bullish stacking), and the opposite indicates a downtrend.

## Source Code

````pine
//@version=6
indicator("Sathish SMA Ribbon 5/10/20/50/100/150/200", overlay = true)

// --- Inputs (so you can fine‑tune colors later) ---
c_sma5   = input.color(color.teal,   "SMA 5 color")      // 320.15 style
c_sma10  = input.color(color.blue,   "SMA 10 color")     // 313.85 style
c_sma20  = input.color(color.red,    "SMA 20 color")     // use same as 200 if you like
c_sma50  = input.color(color.orange, "SMA 50 color")     // 287.56 style
c_sma100 = input.color(color.white,  "SMA 100 color")
c_sma150 = input.color(color.silver, "SMA 150 color")
c_sma200 = input.color(color.red,    "SMA 200 color")    // 243.66 style

// --- SMAs ---
sma5   = ta.sma(close, 5)
sma10  = ta.sma(close, 10)
sma20  = ta.sma(close, 20)
sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

// --- Plots ---
plot(sma5,   title = "SMA 5",   color = c_sma5,   linewidth = 2)
plot(sma10,  title = "SMA 10",  color = c_sma10,  linewidth = 2)
plot(sma20,  title = "SMA 20",  color = c_sma20,  linewidth = 2)
plot(sma50,  title = "SMA 50",  color = c_sma50,  linewidth = 2)
plot(sma100, title = "SMA 100", color = c_sma100, linewidth = 2)
plot(sma150, title = "SMA 150", color = c_sma150, linewidth = 2)
plot(sma200, title = "SMA 200", color = c_sma200, linewidth = 2)
````
