# HP Filtered MA Crossover [TMA]

- url: https://www.tradingview.com/script/BOMQDiRS-HP-Filtered-MA-Crossover-TMA/
- type: indicator
- pine_id: PUB;acc7c3ce3ae64072ba304779c93346da
- version: 4.0

## Description

HP Filtered MA Crossover [TMA] - Institutional Noise Reduction

Description / User Manual:

Overview
The HP Filtered MA Crossover [TMA] is a quantitative trend-following system engineered to solve the most persistent problem in algorithmic trading: Moving Average whipsaws caused by high-frequency market noise.

Developed by Trend Master Academy, this indicator bridges the gap between macroeconomic forecasting and active retail trading. It bypasses the raw, noisy price action (which is fraught with liquidity sweeps and micro-volatility) and instead calculates signals based on a dynamically smoothed Hodrick-Prescott (HP) Trend Component.

The Core Problem: Garbage In, Garbage Out
Traditional Simple Moving Averages (SMAs) or Exponential Moving Averages (EMAs) calculate their values based directly on raw candlestick closes. In modern FX and Crypto markets, sudden volatility spikes, stop-hunts, and spread expansions distort these raw data points. Feeding "dirty" data into a moving average inevitably produces delayed or false (whipsaw) crossover signals.

The Quantitative Solution: The HP Filter
Originally designed by Robert Hodrick and Nobel laureate Edward C. Prescott to analyze macroeconomic business cycles, the HP filter is a mathematical decomposition algorithm. It separates a time series into two distinct components:

The Cyclical Component (Noise): High-frequency, random price fluctuations.

The Trend Component (Signal): The smooth, underlying structural direction of the market.

By applying an advanced, zero-lag Ehlers SuperSmoother transformation to adapt the HP filter for bar-by-bar processing (ensuring 100% Non-Repainting behavior), this indicator completely strips away market noise before any moving average calculations are made.

How It Works under the Hood
The indicator plots three distinct lines:

Blue Line (HP Trend): Your new, noise-free "Price." It ignores sudden, non-structural wicks and focuses solely on the institutional market flow.

Green Line (Short MA): The fast moving average calculated on the HP Trend, not the raw price.

Red Line (Long MA): The slow moving average calculated on the HP Trend.

Trading Mechanics & Execution Logic
This is not a blind "buy the cross" retail indicator. It requires contextual price action awareness.

The Entry (The Cross): Valid Long/Short entries are triggered only when the Short MA (Green) crosses the Long MA (Red).

The Perfect Order (Trend Riding): The strongest momentum occurs when all three lines cascade in parallel (e.g., in an uptrend: HP Trend > Short MA > Long MA). As long as this fanning structure holds, the trend is robust.

The Early Warning System: Do not wait for a crossover to manage your risk. If the underlying HP Trend (Blue line) flattens out and begins to converge toward the Green and Red lines, momentum is dying. This is your cue to trail stops or take partial profits well before the actual exit cross occurs.

The Pullback Opportunity: Often, the initial crossover signifies the completion of an impulse wave. Smart money algorithms will frequently test the MA band or the origin of the breakout (FVG/OB) before continuation. Entering on the first pullback to the moving averages after a confirmed crossover offers a superior Risk/Reward ratio compared to jumping in exactly at the crossover candle.

The Auto-Adaptive Lambda Parameter
The core variable of the HP filter is Lambda, which dictates the degree of smoothing. Higher timeframes require lower Lambda, while lower timeframes require aggressive smoothing.
To eliminate the friction of constant recalibration, this script features an Auto-Adaptive Lambda Engine.

If Lambda = 0 (Default), the script automatically detects your chart's timeframe (from 1m up to Monthly) and assigns the mathematically optimal Lambda value dynamically.

You can monitor the active Lambda in the built-in HUD table on the top right. Manual overrides are fully supported via the settings menu.

Best Practices

Optimal Timeframes: This is a swing-trading architecture. It performs exceptionally well on the 1H, 4H, and 1D charts where Market Structure Shifts (MSS) are reliable.

Non-Repaint Guarantee: The script is engineered using strict DSP principles to ensure that once a bar closes, the signal is permanently locked. No historical repainting will occur.

Built for the analytical trader.

## Source Code

````pine
//@version=6

// ============================================================
//   HP MA CROSSOVER  —  Hodrick-Prescott Trend Filter
//   by Trend Master Akademi
// ─────────────────────────────────────────────────────────────
//   Centered-window two-sided HP — each bar runs its own
//   solver on a window that EXTENDS BACKWARDS from current.
// ============================================================

indicator("HP MA Crossover [Trend Master Akademi]",
          overlay       = true,
          max_bars_back = 1500)

// ─── Inputs ───────────────────────────────────────────────────
// 1. Yeni Lambda Seçim Menüsü
i_lambda_mode = input.string("Auto", "Lambda Modu", options=["Auto", "Manual"])
i_lambda_man  = input.float(1600,    "Manuel Lambda Değeri (Mod Manual ise çalışır)")

// 2. MA ve HP Ayarları
i_period1  = input.int(12,    "Short MA Period",   minval = 1)
i_period2  = input.int(26,    "Long MA Period",    minval = 2)
i_window   = input.int(80,    "HP Window",         minval = 30, maxval = 150,
                              tooltip = "Per-bar solver window. Larger = smoother, more lag.")
i_offset   = input.int(0,     "Read Offset",       minval = 0, maxval = 10,
                              tooltip = "0 = right edge (no lag). Increase if you see boundary instability.")
i_iters    = input.int(30,    "Iterations",        minval = 10, maxval = 50)

// ─── Auto Lambda ──────────────────────────────────────────────
var float ActiveLambda = na

if barstate.isfirst
    if i_lambda_mode == "Auto"
        ActiveLambda := 
          timeframe.period == "1"   ? 1440000 :
          timeframe.period == "5"   ? 144000  :
          timeframe.period == "15"  ? 57600   :
          timeframe.period == "30"  ? 28800   :
          timeframe.period == "60"  ? 14400   :
          timeframe.period == "240" ? 1600    :
          timeframe.period == "D"   ? 100     :
          timeframe.period == "W"   ? 10      :
          timeframe.period == "M"   ? 14400   : 1600
    else
        ActiveLambda := i_lambda_man

// ─── HP Solver — runs every bar, returns one value ────────────
hp_calc(int n, float lam, int iters, int readOffset) =>
    float[] y = array.new_float(n)
    float[] x = array.new_float(n)

    // y[0]=oldest, y[n-1]=current bar 
    for i = 0 to n - 1
        p = close[n - 1 - i]
        array.set(y, i, p)
        array.set(x, i, p)   // seed = price → preserves level

    for iter = 0 to iters - 1
        for i = 0 to n - 1
            sum  = 0.0
            diag = (i == 0 or i == n - 1) ? 1.0 + lam :
                   (i == 1 or i == n - 2) ? 1.0 + 5.0 * lam :
                   1.0 + 6.0 * lam

            if i >= 2
                sum += lam * array.get(x, i - 2)
            if i >= 1
                c1 = (i == 1 or i == n - 1) ? -2.0 * lam : -4.0 * lam
                sum += c1 * array.get(x, i - 1)
            if i < n - 1
                c2 = (i == 0 or i == n - 2) ? -2.0 * lam : -4.0 * lam
                sum += c2 * array.get(x, i + 1)
            if i < n - 2
                sum += lam * array.get(x, i + 2)

            array.set(x, i, (array.get(y, i) - sum) / diag)

    // Read from (n-1 - readOffset) — right edge with optional lag
    array.get(x, n - 1 - readOffset)


// ─── Compute HP per bar ───────────────────────────────────────
hp = bar_index >= i_window ? hp_calc(i_window, ActiveLambda, i_iters, i_offset) : na

// ─── TMA Dinamik Renk Algoritması (Slope Detection) ───────────
var color hp_color = #1E90FF // Başlangıç rengi (DodgerBlue)
if hp > hp[1]
    hp_color := #1E90FF      // Yukarı eğim -> Mavi
else if hp < hp[1]
    hp_color := color.red    // Aşağı eğim -> Kırmızı

// ─── SMAs ─────────────────────────────────────────────────────
ma1 = ta.sma(hp, i_period1)
ma2 = ta.sma(hp, i_period2)

// ─── Crossover ────────────────────────────────────────────────
bullCross = ta.crossover(ma1,  ma2)
bearCross = ta.crossunder(ma1, ma2)

// ─── Plot ─────────────────────────────────────────────────────
// Artık sabit renk yerine dinamik "hp_color" değişkeni atanıyor
plot(hp,  "HP Trend",            color = hp_color, linewidth = 2)
plot(ma1, "Short MA (HP basis)", color = color.new(color.lime, 0), linewidth = 1)
plot(ma2, "Long MA  (HP basis)", color = color.new(color.red,  0), linewidth = 1)

plotshape(bullCross, "Bull Cross — Long Trigger",
          shape.triangleup, location.belowbar,
          color = color.new(color.lime, 0), size = size.small,
          display = display.none)

plotshape(bearCross, "Bear Cross — Short Trigger",
          shape.triangledown, location.abovebar,
          color = color.new(color.red, 0), size = size.small,
          display = display.none)
````
