# Best MA Pair Finder (Crossover Strategy)

- url: https://www.tradingview.com/script/Wh8fQKtV-Best-MA-Pair-Finder-Crossover-Strategy/
- type: indicator
- pine_id: PUB;72646feec3064b58a94f578d20d0899f
- version: 2.0

## Description

This indicator automatically identifies the optimal pair of moving averages (MAs) for a crossover strategy using all available historical data. It offers several MA options—including SMA, EMA, and TEMA—allowing users to select the desired type in the settings. The indicator supports two strategy modes: “Long Only” and “Buy & Sell”, which can be chosen via the options.

For each MA pair combination, the indicator performs a backtest and calculates the profit factor, considering only those pairs where the total number of trades meets or exceeds the user-defined "Minimum Trades" threshold. This parameter ensures that the selected optimal pair is based on a statistically meaningful sample rather than on a limited number of trades.

[i]The results provided by this indicator are based on historical data and backtests, which may not guarantee future performance. Users should conduct their own analysis and use proper risk management before making trading decisions.[/i]

## Source Code

````pine
// @ Julien_Eche
// Description updated

//@version=5
indicator("Best MA Pair Finder (Crossover Strategy)", "Best MA Pair Finder", overlay=true)

// User inputs
ma_type       = input.string("SMA", "MA Type", options=["SMA", "EMA", "TEMA"])
strategy_type = input.string("Long Only", "Strategy Type", options=["Buy & Sell", "Long Only"])
min_trades    = input.int(50, "Minimum Trades", minval=1)

// MA functions
f_tema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    ema3 = ta.ema(ema2, len)
    3 * (ema1 - ema2) + ema3

f_ma(src, len) =>
    switch ma_type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "TEMA" => f_tema(src, len)

// Backtest function for a fast/slow pair
backtestPair(fast_len, slow_len) =>
    fastMA = f_ma(close, fast_len)
    slowMA = f_ma(close, slow_len)
    var float entry_long  = na
    var float entry_short = na
    var int trades  = 0
    var float profit = 0.0
    var float loss   = 0.0
    longCond  = ta.crossover(fastMA, slowMA)
    shortCond = ta.crossunder(fastMA, slowMA)
    if strategy_type == "Buy & Sell"
        if longCond and na(entry_long) and na(entry_short)
            entry_long := close
            trades += 1
        if shortCond and not na(entry_long)
            p = close - entry_long
            profit += p > 0 ? p : 0
            loss   += p < 0 ? -p : 0
            entry_long := na
        if shortCond and na(entry_short) and na(entry_long)
            entry_short := close
            trades += 1
        if longCond and not na(entry_short)
            p = entry_short - close
            profit += p > 0 ? p : 0
            loss   += p < 0 ? -p : 0
            entry_short := na
    else
        if longCond and na(entry_long)
            entry_long := close
            trades += 1
        if shortCond and not na(entry_long)
            p = close - entry_long
            profit += p > 0 ? p : 0
            loss   += p < 0 ? -p : 0
            entry_long := na
    pf = loss > 0 ? profit / loss : 0
    [trades, pf, fastMA, slowMA]

// --- Define pairs explicitly ---
// Fast = 20
[tr_20_30,  pf_20_30,  fastMA_20_30,  slowMA_20_30]   = backtestPair(20, 30)
[tr_20_40,  pf_20_40,  fastMA_20_40,  slowMA_20_40]   = backtestPair(20, 40)
[tr_20_50,  pf_20_50,  fastMA_20_50,  slowMA_20_50]   = backtestPair(20, 50)
[tr_20_60,  pf_20_60,  fastMA_20_60,  slowMA_20_60]   = backtestPair(20, 60)
[tr_20_70,  pf_20_70,  fastMA_20_70,  slowMA_20_70]   = backtestPair(20, 70)
[tr_20_80,  pf_20_80,  fastMA_20_80,  slowMA_20_80]   = backtestPair(20, 80)
[tr_20_90,  pf_20_90,  fastMA_20_90,  slowMA_20_90]   = backtestPair(20, 90)
[tr_20_100, pf_20_100, fastMA_20_100, slowMA_20_100]  = backtestPair(20, 100)
// Fast = 30
[tr_30_40,  pf_30_40,  fastMA_30_40,  slowMA_30_40]   = backtestPair(30, 40)
[tr_30_50,  pf_30_50,  fastMA_30_50,  slowMA_30_50]   = backtestPair(30, 50)
[tr_30_60,  pf_30_60,  fastMA_30_60,  slowMA_30_60]   = backtestPair(30, 60)
[tr_30_70,  pf_30_70,  fastMA_30_70,  slowMA_30_70]   = backtestPair(30, 70)
[tr_30_80,  pf_30_80,  fastMA_30_80,  slowMA_30_80]   = backtestPair(30, 80)
[tr_30_90,  pf_30_90,  fastMA_30_90,  slowMA_30_90]   = backtestPair(30, 90)
[tr_30_100, pf_30_100, fastMA_30_100, slowMA_30_100]  = backtestPair(30, 100)
// Fast = 40
[tr_40_50,  pf_40_50,  fastMA_40_50,  slowMA_40_50]   = backtestPair(40, 50)
[tr_40_60,  pf_40_60,  fastMA_40_60,  slowMA_40_60]   = backtestPair(40, 60)
[tr_40_70,  pf_40_70,  fastMA_40_70,  slowMA_40_70]   = backtestPair(40, 70)
[tr_40_80,  pf_40_80,  fastMA_40_80,  slowMA_40_80]   = backtestPair(40, 80)
[tr_40_90,  pf_40_90,  fastMA_40_90,  slowMA_40_90]   = backtestPair(40, 90)
[tr_40_100, pf_40_100, fastMA_40_100, slowMA_40_100]  = backtestPair(40, 100)
// Fast = 50
[tr_50_60,  pf_50_60,  fastMA_50_60,  slowMA_50_60]  = backtestPair(50, 60)
[tr_50_70,  pf_50_70,  fastMA_50_70,  slowMA_50_70]  = backtestPair(50, 70)
[tr_50_80,  pf_50_80,  fastMA_50_80,  slowMA_50_80]  = backtestPair(50, 80)
[tr_50_90,  pf_50_90,  fastMA_50_90,  slowMA_50_90]  = backtestPair(50, 90)
[tr_50_100, pf_50_100, fastMA_50_100, slowMA_50_100] = backtestPair(50, 100)
[tr_50_110, pf_50_110, fastMA_50_110, slowMA_50_110] = backtestPair(50, 110)
[tr_50_120, pf_50_120, fastMA_50_120, slowMA_50_120] = backtestPair(50, 120)
[tr_50_130, pf_50_130, fastMA_50_130, slowMA_50_130] = backtestPair(50, 130)
[tr_50_140, pf_50_140, fastMA_50_140, slowMA_50_140] = backtestPair(50, 140)
[tr_50_150, pf_50_150, fastMA_50_150, slowMA_50_150] = backtestPair(50, 150)
[tr_50_160, pf_50_160, fastMA_50_160, slowMA_50_160] = backtestPair(50, 160)
[tr_50_170, pf_50_170, fastMA_50_170, slowMA_50_170] = backtestPair(50, 170)
[tr_50_180, pf_50_180, fastMA_50_180, slowMA_50_180] = backtestPair(50, 180)
[tr_50_190, pf_50_190, fastMA_50_190, slowMA_50_190] = backtestPair(50, 190)
// Fast = 60
[tr_60_70,  pf_60_70,  fastMA_60_70,  slowMA_60_70]  = backtestPair(60, 70)
[tr_60_80,  pf_60_80,  fastMA_60_80,  slowMA_60_80]  = backtestPair(60, 80)
[tr_60_90,  pf_60_90,  fastMA_60_90,  slowMA_60_90]  = backtestPair(60, 90)
[tr_60_100, pf_60_100, fastMA_60_100, slowMA_60_100] = backtestPair(60, 100)
[tr_60_110, pf_60_110, fastMA_60_110, slowMA_60_110] = backtestPair(60, 110)
[tr_60_120, pf_60_120, fastMA_60_120, slowMA_60_120] = backtestPair(60, 120)
[tr_60_130, pf_60_130, fastMA_60_130, slowMA_60_130] = backtestPair(60, 130)
[tr_60_140, pf_60_140, fastMA_60_140, slowMA_60_140] = backtestPair(60, 140)
[tr_60_150, pf_60_150, fastMA_60_150, slowMA_60_150] = backtestPair(60, 150)
[tr_60_160, pf_60_160, fastMA_60_160, slowMA_60_160] = backtestPair(60, 160)
[tr_60_170, pf_60_170, fastMA_60_170, slowMA_60_170] = backtestPair(60, 170)
[tr_60_180, pf_60_180, fastMA_60_180, slowMA_60_180] = backtestPair(60, 180)
[tr_60_190, pf_60_190, fastMA_60_190, slowMA_60_190] = backtestPair(60, 190)
// Fast = 70
[tr_70_80,  pf_70_80,  fastMA_70_80,  slowMA_70_80]  = backtestPair(70, 80)
[tr_70_90,  pf_70_90,  fastMA_70_90,  slowMA_70_90]  = backtestPair(70, 90)
[tr_70_100, pf_70_100, fastMA_70_100, slowMA_70_100] = backtestPair(70, 100)
[tr_70_110, pf_70_110, fastMA_70_110, slowMA_70_110] = backtestPair(70, 110)
[tr_70_120, pf_70_120, fastMA_70_120, slowMA_70_120] = backtestPair(70, 120)
[tr_70_130, pf_70_130, fastMA_70_130, slowMA_70_130] = backtestPair(70, 130)
[tr_70_140, pf_70_140, fastMA_70_140, slowMA_70_140] = backtestPair(70, 140)
[tr_70_150, pf_70_150, fastMA_70_150, slowMA_70_150] = backtestPair(70, 150)
[tr_70_160, pf_70_160, fastMA_70_160, slowMA_70_160] = backtestPair(70, 160)
[tr_70_170, pf_70_170, fastMA_70_170, slowMA_70_170] = backtestPair(70, 170)
[tr_70_180, pf_70_180, fastMA_70_180, slowMA_70_180] = backtestPair(70, 180)
[tr_70_190, pf_70_190, fastMA_70_190, slowMA_70_190] = backtestPair(70, 190)
// Fast = 80
[tr_80_90,  pf_80_90,  fastMA_80_90,  slowMA_80_90]  = backtestPair(80, 90)
[tr_80_100, pf_80_100, fastMA_80_100, slowMA_80_100] = backtestPair(80, 100)
[tr_80_110, pf_80_110, fastMA_80_110, slowMA_80_110] = backtestPair(80, 110)
[tr_80_120, pf_80_120, fastMA_80_120, slowMA_80_120] = backtestPair(80, 120)
[tr_80_130, pf_80_130, fastMA_80_130, slowMA_80_130] = backtestPair(80, 130)
[tr_80_140, pf_80_140, fastMA_80_140, slowMA_80_140] = backtestPair(80, 140)
[tr_80_150, pf_80_150, fastMA_80_150, slowMA_80_150] = backtestPair(80, 150)
[tr_80_160, pf_80_160, fastMA_80_160, slowMA_80_160] = backtestPair(80, 160)
[tr_80_170, pf_80_170, fastMA_80_170, slowMA_80_170] = backtestPair(80, 170)
[tr_80_180, pf_80_180, fastMA_80_180, slowMA_80_180] = backtestPair(80, 180)
[tr_80_190, pf_80_190, fastMA_80_190, slowMA_80_190] = backtestPair(80, 190)
// Fast = 90
[tr_90_100, pf_90_100, fastMA_90_100, slowMA_90_100] = backtestPair(90, 100)
[tr_90_110, pf_90_110, fastMA_90_110, slowMA_90_110] = backtestPair(90, 110)
[tr_90_120, pf_90_120, fastMA_90_120, slowMA_90_120] = backtestPair(90, 120)
[tr_90_130, pf_90_130, fastMA_90_130, slowMA_90_130] = backtestPair(90, 130)
[tr_90_140, pf_90_140, fastMA_90_140, slowMA_90_140] = backtestPair(90, 140)
[tr_90_150, pf_90_150, fastMA_90_150, slowMA_90_150] = backtestPair(90, 150)
[tr_90_160, pf_90_160, fastMA_90_160, slowMA_90_160] = backtestPair(90, 160)
[tr_90_170, pf_90_170, fastMA_90_170, slowMA_90_170] = backtestPair(90, 170)
[tr_90_180, pf_90_180, fastMA_90_180, slowMA_90_180] = backtestPair(90, 180)
[tr_90_190, pf_90_190, fastMA_90_190, slowMA_90_190] = backtestPair(90, 190)
// Fast = 100
[tr_100_110, pf_100_110, fastMA_100_110, slowMA_100_110] = backtestPair(100, 110)
[tr_100_120, pf_100_120, fastMA_100_120, slowMA_100_120] = backtestPair(100, 120)
[tr_100_130, pf_100_130, fastMA_100_130, slowMA_100_130] = backtestPair(100, 130)
[tr_100_140, pf_100_140, fastMA_100_140, slowMA_100_140] = backtestPair(100, 140)
[tr_100_150, pf_100_150, fastMA_100_150, slowMA_100_150] = backtestPair(100, 150)
[tr_100_160, pf_100_160, fastMA_100_160, slowMA_100_160] = backtestPair(100, 160)
[tr_100_170, pf_100_170, fastMA_100_170, slowMA_100_170] = backtestPair(100, 170)
[tr_100_180, pf_100_180, fastMA_100_180, slowMA_100_180] = backtestPair(100, 180)
[tr_100_190, pf_100_190, fastMA_100_190, slowMA_100_190] = backtestPair(100, 190)
// Fast = 110
[tr_110_120, pf_110_120, fastMA_110_120, slowMA_110_120] = backtestPair(110, 120)
[tr_110_130, pf_110_130, fastMA_110_130, slowMA_110_130] = backtestPair(110, 130)
[tr_110_140, pf_110_140, fastMA_110_140, slowMA_110_140] = backtestPair(110, 140)
[tr_110_150, pf_110_150, fastMA_110_150, slowMA_110_150] = backtestPair(110, 150)
[tr_110_160, pf_110_160, fastMA_110_160, slowMA_110_160] = backtestPair(110, 160)
[tr_110_170, pf_110_170, fastMA_110_170, slowMA_110_170] = backtestPair(110, 170)
[tr_110_180, pf_110_180, fastMA_110_180, slowMA_110_180] = backtestPair(110, 180)
// Fast = 120
[tr_120_130, pf_120_130, fastMA_120_130, slowMA_120_130] = backtestPair(120, 130)
[tr_120_140, pf_120_140, fastMA_120_140, slowMA_120_140] = backtestPair(120, 140)
[tr_120_150, pf_120_150, fastMA_120_150, slowMA_120_150] = backtestPair(120, 150)
[tr_120_160, pf_120_160, fastMA_120_160, slowMA_120_160] = backtestPair(120, 160)
[tr_120_170, pf_120_170, fastMA_120_170, slowMA_120_170] = backtestPair(120, 170)
[tr_120_180, pf_120_180, fastMA_120_180, slowMA_120_180] = backtestPair(120, 180)
// Fast = 130
[tr_130_140, pf_130_140, fastMA_130_140, slowMA_130_140] = backtestPair(130, 140)
[tr_130_150, pf_130_150, fastMA_130_150, slowMA_130_150] = backtestPair(130, 150)
[tr_130_160, pf_130_160, fastMA_130_160, slowMA_130_160] = backtestPair(130, 160)
[tr_130_170, pf_130_170, fastMA_130_170, slowMA_130_170] = backtestPair(130, 170)
[tr_130_180, pf_130_180, fastMA_130_180, slowMA_130_180] = backtestPair(130, 180)
[tr_130_190, pf_130_190, fastMA_130_190, slowMA_130_190] = backtestPair(130, 190)
// Fast = 140
[tr_140_150, pf_140_150, fastMA_140_150, slowMA_140_150] = backtestPair(140, 150)
[tr_140_160, pf_140_160, fastMA_140_160, slowMA_140_160] = backtestPair(140, 160)
[tr_140_170, pf_140_170, fastMA_140_170, slowMA_140_170] = backtestPair(140, 170)
[tr_140_180, pf_140_180, fastMA_140_180, slowMA_140_180] = backtestPair(140, 180)
[tr_140_190, pf_140_190, fastMA_140_190, slowMA_140_190] = backtestPair(140, 190)
// Fast = 150
[tr_150_160, pf_150_160, fastMA_150_160, slowMA_150_160] = backtestPair(150, 160)
[tr_150_170, pf_150_170, fastMA_150_170, slowMA_150_170] = backtestPair(150, 170)
[tr_150_180, pf_150_180, fastMA_150_180, slowMA_150_180] = backtestPair(150, 180)
[tr_150_190, pf_150_190, fastMA_150_190, slowMA_150_190] = backtestPair(150, 190)
// Fast = 160
[tr_160_170, pf_160_170, fastMA_160_170, slowMA_160_170] = backtestPair(160, 170)
[tr_160_180, pf_160_180, fastMA_160_180, slowMA_160_180] = backtestPair(160, 180)
[tr_160_190, pf_160_190, fastMA_160_190, slowMA_160_190] = backtestPair(160, 190)
// Fast = 170
[tr_170_180, pf_170_180, fastMA_170_180, slowMA_170_180] = backtestPair(170, 180)
[tr_170_190, pf_170_190, fastMA_170_190, slowMA_170_190] = backtestPair(170, 190)
// Fast = 180
[tr_180_190, pf_180_190, fastMA_180_190, slowMA_180_190] = backtestPair(180, 190)

// Calculate the best profit factor:
best_pf = math.max( tr_20_30>=min_trades ? pf_20_30 : 0, tr_20_40>=min_trades ? pf_20_40 : 0, tr_20_50>=min_trades ? pf_20_50 : 0, tr_20_60>=min_trades ? pf_20_60 : 0, tr_20_70>=min_trades ? pf_20_70 : 0, tr_20_80>=min_trades ? pf_20_80 : 0, tr_20_90>=min_trades ? pf_20_90 : 0, tr_20_100>=min_trades ? pf_20_100 : 0,   tr_30_40>=min_trades ? pf_30_40 : 0, tr_30_50>=min_trades ? pf_30_50 : 0, tr_30_60>=min_trades ? pf_30_60 : 0, tr_30_70>=min_trades ? pf_30_70 : 0, tr_30_80>=min_trades ? pf_30_80 : 0, tr_30_90>=min_trades ? pf_30_90 : 0, tr_30_100>=min_trades ? pf_30_100 : 0,   tr_40_50>=min_trades ? pf_40_50 : 0, tr_40_60>=min_trades ? pf_40_60 : 0, tr_40_70>=min_trades ? pf_40_70 : 0, tr_40_80>=min_trades ? pf_40_80 : 0, tr_40_90>=min_trades ? pf_40_90 : 0, tr_40_100>=min_trades ? pf_40_100 : 0,    tr_50_60>=min_trades ? pf_50_60 : 0, tr_50_70>=min_trades ? pf_50_70 : 0, tr_50_80>=min_trades ? pf_50_80 : 0, tr_50_90>=min_trades ? pf_50_90 : 0,  tr_60_70>=min_trades ? pf_60_70 : 0, tr_60_80>=min_trades ? pf_60_80 : 0, tr_60_90>=min_trades ? pf_60_90 : 0,    tr_70_80>=min_trades ? pf_70_80 : 0, tr_70_90>=min_trades ? pf_70_90 : 0,    tr_80_90>=min_trades ? pf_80_90 : 0,    tr_50_100>=min_trades ? pf_50_100 : 0, tr_50_110>=min_trades ? pf_50_110 : 0, tr_50_120>=min_trades ? pf_50_120 : 0, tr_50_130>=min_trades ? pf_50_130 : 0, tr_50_140>=min_trades ? pf_50_140 : 0, tr_50_150>=min_trades ? pf_50_150 : 0, tr_50_160>=min_trades ? pf_50_160 : 0, tr_50_170>=min_trades ? pf_50_170 : 0, tr_50_180>=min_trades ? pf_50_180 : 0, tr_50_190>=min_trades ? pf_50_190 : 0,      tr_60_100>=min_trades ? pf_60_100 : 0, tr_60_110>=min_trades ? pf_60_110 : 0, tr_60_120>=min_trades ? pf_60_120 : 0, tr_60_130>=min_trades ? pf_60_130 : 0, tr_60_140>=min_trades ? pf_60_140 : 0, tr_60_150>=min_trades ? pf_60_150 : 0, tr_60_160>=min_trades ? pf_60_160 : 0, tr_60_170>=min_trades ? pf_60_170 : 0, tr_60_180>=min_trades ? pf_60_180 : 0, tr_60_190>=min_trades ? pf_60_190 : 0,     tr_70_100>=min_trades ? pf_70_100 : 0, tr_70_110>=min_trades ? pf_70_110 : 0, tr_70_120>=min_trades ? pf_70_120 : 0, tr_70_130>=min_trades ? pf_70_130 : 0, tr_70_140>=min_trades ? pf_70_140 : 0, tr_70_150>=min_trades ? pf_70_150 : 0, tr_70_160>=min_trades ? pf_70_160 : 0, tr_70_170>=min_trades ? pf_70_170 : 0, tr_70_180>=min_trades ? pf_70_180 : 0, tr_70_190>=min_trades ? pf_70_190 : 0,     tr_80_100>=min_trades ? pf_80_100 : 0, tr_80_110>=min_trades ? pf_80_110 : 0, tr_80_120>=min_trades ? pf_80_120 : 0, tr_80_130>=min_trades ? pf_80_130 : 0, tr_80_140>=min_trades ? pf_80_140 : 0, tr_80_150>=min_trades ? pf_80_150 : 0, tr_80_160>=min_trades ? pf_80_160 : 0, tr_80_170>=min_trades ? pf_80_170 : 0, tr_80_180>=min_trades ? pf_80_180 : 0, tr_80_190>=min_trades ? pf_80_190 : 0,      tr_90_100>=min_trades ? pf_90_100 : 0, tr_90_110>=min_trades ? pf_90_110 : 0, tr_90_120>=min_trades ? pf_90_120 : 0, tr_90_130>=min_trades ? pf_90_130 : 0, tr_90_140>=min_trades ? pf_90_140 : 0, tr_90_150>=min_trades ? pf_90_150 : 0, tr_90_160>=min_trades ? pf_90_160 : 0, tr_90_170>=min_trades ? pf_90_170 : 0, tr_90_180>=min_trades ? pf_90_180 : 0, tr_90_190>=min_trades ? pf_90_190 : 0)

// Determine the best pair
best_pair = switch best_pf

    pf_20_30  => tr_20_30>=min_trades ? "20 / 30" : "n/a"
    pf_20_40  => tr_20_40>=min_trades ? "20 / 40" : "n/a"
    pf_20_50  => tr_20_50>=min_trades ? "20 / 50" : "n/a"
    pf_20_60  => tr_20_60>=min_trades ? "20 / 60" : "n/a"
    pf_20_70  => tr_20_70>=min_trades ? "20 / 70" : "n/a"
    pf_20_80  => tr_20_80>=min_trades ? "20 / 80" : "n/a"
    pf_20_90  => tr_20_90>=min_trades ? "20 / 90" : "n/a"
    pf_20_100 => tr_20_100>=min_trades ? "20 / 100" : "n/a"

    pf_30_40  => tr_30_40>=min_trades ? "30 / 40" : "n/a"
    pf_30_50  => tr_30_50>=min_trades ? "30 / 50" : "n/a"
    pf_30_60  => tr_30_60>=min_trades ? "30 / 60" : "n/a"
    pf_30_70  => tr_30_70>=min_trades ? "30 / 70" : "n/a"
    pf_30_80  => tr_30_80>=min_trades ? "30 / 80" : "n/a"
    pf_30_90  => tr_30_90>=min_trades ? "30 / 90" : "n/a"
    pf_30_100 => tr_30_100>=min_trades ? "30 / 100" : "n/a"

    pf_40_50  => tr_40_50>=min_trades ? "40 / 50" : "n/a"
    pf_40_60  => tr_40_60>=min_trades ? "40 / 60" : "n/a"
    pf_40_70  => tr_40_70>=min_trades ? "40 / 70" : "n/a"
    pf_40_80  => tr_40_80>=min_trades ? "40 / 80" : "n/a"
    pf_40_90  => tr_40_90>=min_trades ? "40 / 90" : "n/a"
    pf_40_100 => tr_40_100>=min_trades ? "40 / 100" : "n/a"

    pf_50_60  => tr_50_60>=min_trades ? "50 / 60" : "n/a"
    pf_50_70  => tr_50_70>=min_trades ? "50 / 70" : "n/a"
    pf_50_80  => tr_50_80>=min_trades ? "50 / 80" : "n/a"
    pf_50_90  => tr_50_90>=min_trades ? "50 / 90" : "n/a"
    
    pf_50_100 => tr_50_100>=min_trades ? "50 / 100" : "n/a"
    pf_50_110 => tr_50_110>=min_trades ? "50 / 110" : "n/a"
    pf_50_120 => tr_50_120>=min_trades ? "50 / 120" : "n/a"
    pf_50_130 => tr_50_130>=min_trades ? "50 / 130" : "n/a"
    pf_50_140 => tr_50_140>=min_trades ? "50 / 140" : "n/a"
    pf_50_150 => tr_50_150>=min_trades ? "50 / 150" : "n/a"
    pf_50_160 => tr_50_160>=min_trades ? "50 / 160" : "n/a"
    pf_50_170 => tr_50_170>=min_trades ? "50 / 170" : "n/a"
    pf_50_180 => tr_50_180>=min_trades ? "50 / 180" : "n/a"
    pf_50_190 => tr_50_190>=min_trades ? "50 / 190" : "n/a"
    
    pf_60_70  => tr_60_70>=min_trades ? "60 / 70" : "n/a"
    pf_60_80  => tr_60_80>=min_trades ? "60 / 80" : "n/a"
    pf_60_90  => tr_60_90>=min_trades ? "60 / 90" : "n/a"
    
    pf_60_100 => tr_60_100>=min_trades ? "60 / 100" : "n/a"
    pf_60_110 => tr_60_110>=min_trades ? "60 / 110" : "n/a"
    pf_60_120 => tr_60_120>=min_trades ? "60 / 120" : "n/a"
    pf_60_130 => tr_60_130>=min_trades ? "60 / 130" : "n/a"
    pf_60_140 => tr_60_140>=min_trades ? "60 / 140" : "n/a"
    pf_60_150 => tr_60_150>=min_trades ? "60 / 150" : "n/a"
    pf_60_160 => tr_60_160>=min_trades ? "60 / 160" : "n/a"
    pf_60_170 => tr_60_170>=min_trades ? "60 / 170" : "n/a"
    pf_60_180 => tr_60_180>=min_trades ? "60 / 180" : "n/a"
    pf_60_190 => tr_60_190>=min_trades ? "60 / 190" : "n/a"
    
    pf_70_80  => tr_70_80>=min_trades ? "70 / 80" : "n/a"
    pf_70_90  => tr_70_90>=min_trades ? "70 / 90" : "n/a"
    
    pf_70_100 => tr_70_100>=min_trades ? "70 / 100" : "n/a"
    pf_70_110 => tr_70_110>=min_trades ? "70 / 110" : "n/a"
    pf_70_120 => tr_70_120>=min_trades ? "70 / 120" : "n/a"
    pf_70_130 => tr_70_130>=min_trades ? "70 / 130" : "n/a"
    pf_70_140 => tr_70_140>=min_trades ? "70 / 140" : "n/a"
    pf_70_150 => tr_70_150>=min_trades ? "70 / 150" : "n/a"
    pf_70_160 => tr_70_160>=min_trades ? "70 / 160" : "n/a"
    pf_70_170 => tr_70_170>=min_trades ? "70 / 170" : "n/a"
    pf_70_180 => tr_70_180>=min_trades ? "70 / 180" : "n/a"
    pf_70_190 => tr_70_190>=min_trades ? "70 / 190" : "n/a"
    
    pf_80_90  => tr_80_90>=min_trades ? "80 / 90" : "n/a"
    
    pf_80_100 => tr_80_100>=min_trades ? "80 / 100" : "n/a"
    pf_80_110 => tr_80_110>=min_trades ? "80 / 110" : "n/a"
    pf_80_120 => tr_80_120>=min_trades ? "80 / 120" : "n/a"
    pf_80_130 => tr_80_130>=min_trades ? "80 / 130" : "n/a"
    pf_80_140 => tr_80_140>=min_trades ? "80 / 140" : "n/a"
    pf_80_150 => tr_80_150>=min_trades ? "80 / 150" : "n/a"
    pf_80_160 => tr_80_160>=min_trades ? "80 / 160" : "n/a"
    pf_80_170 => tr_80_170>=min_trades ? "80 / 170" : "n/a"
    pf_80_180 => tr_80_180>=min_trades ? "80 / 180" : "n/a"
    pf_80_190 => tr_80_190>=min_trades ? "80 / 190" : "n/a"
    
    pf_90_100 => tr_90_100>=min_trades ? "90 / 100" : "n/a"
    pf_90_110 => tr_90_110>=min_trades ? "90 / 110" : "n/a"
    pf_90_120 => tr_90_120>=min_trades ? "90 / 120" : "n/a"
    pf_90_130 => tr_90_130>=min_trades ? "90 / 130" : "n/a"
    pf_90_140 => tr_90_140>=min_trades ? "90 / 140" : "n/a"
    pf_90_150 => tr_90_150>=min_trades ? "90 / 150" : "n/a"
    pf_90_160 => tr_90_160>=min_trades ? "90 / 160" : "n/a"
    pf_90_170 => tr_90_170>=min_trades ? "90 / 170" : "n/a"
    pf_90_180 => tr_90_180>=min_trades ? "90 / 180" : "n/a"
    pf_90_190 => tr_90_190>=min_trades ? "90 / 190" : "n/a"
    
    pf_100_110 => tr_100_110>=min_trades ? "100 / 110" : "n/a"
    pf_100_120 => tr_100_120>=min_trades ? "100 / 120" : "n/a"
    pf_100_130 => tr_100_130>=min_trades ? "100 / 130" : "n/a"
    pf_100_140 => tr_100_140>=min_trades ? "100 / 140" : "n/a"
    pf_100_150 => tr_100_150>=min_trades ? "100 / 150" : "n/a"
    pf_100_160 => tr_100_160>=min_trades ? "100 / 160" : "n/a"
    pf_100_170 => tr_100_170>=min_trades ? "100 / 170" : "n/a"
    pf_100_180 => tr_100_180>=min_trades ? "100 / 180" : "n/a"
    pf_100_190 => tr_100_190>=min_trades ? "100 / 190" : "n/a"

    pf_110_120 => tr_110_120>=min_trades ? "110 / 120" : "n/a"
    pf_110_130 => tr_110_130>=min_trades ? "110 / 130" : "n/a"
    pf_110_140 => tr_110_140>=min_trades ? "110 / 140" : "n/a"
    pf_110_150 => tr_110_150>=min_trades ? "110 / 150" : "n/a"
    pf_110_160 => tr_110_160>=min_trades ? "110 / 160" : "n/a"
    pf_110_170 => tr_110_170>=min_trades ? "110 / 170" : "n/a"
    pf_110_180 => tr_110_180>=min_trades ? "110 / 180" : "n/a"
    
    pf_120_130 => tr_120_130>=min_trades ? "120 / 130" : "n/a"
    pf_120_140 => tr_120_140>=min_trades ? "120 / 140" : "n/a"
    pf_120_150 => tr_120_150>=min_trades ? "120 / 150" : "n/a"
    pf_120_160 => tr_120_160>=min_trades ? "120 / 160" : "n/a"
    pf_120_170 => tr_120_170>=min_trades ? "120 / 170" : "n/a"
    pf_120_180 => tr_120_180>=min_trades ? "120 / 180" : "n/a"
    
    pf_130_140 => tr_130_140>=min_trades ? "130 / 140" : "n/a"
    pf_130_150 => tr_130_150>=min_trades ? "130 / 150" : "n/a"
    pf_130_160 => tr_130_160>=min_trades ? "130 / 160" : "n/a"
    pf_130_170 => tr_130_170>=min_trades ? "130 / 170" : "n/a"
    pf_130_180 => tr_130_180>=min_trades ? "130 / 180" : "n/a"
    pf_130_190 => tr_130_190>=min_trades ? "130 / 190" : "n/a"
    
    pf_140_150 => tr_140_150>=min_trades ? "140 / 150" : "n/a"
    pf_140_160 => tr_140_160>=min_trades ? "140 / 160" : "n/a"
    pf_140_170 => tr_140_170>=min_trades ? "140 / 170" : "n/a"
    pf_140_180 => tr_140_180>=min_trades ? "140 / 180" : "n/a"
    pf_140_190 => tr_140_190>=min_trades ? "140 / 190" : "n/a"
    
    pf_150_160 => tr_150_160>=min_trades ? "150 / 160" : "n/a"
    pf_150_170 => tr_150_170>=min_trades ? "150 / 170" : "n/a"
    pf_150_180 => tr_150_180>=min_trades ? "150 / 180" : "n/a"
    pf_150_190 => tr_150_190>=min_trades ? "150 / 190" : "n/a"
    
    pf_160_170 => tr_160_170>=min_trades ? "160 / 170" : "n/a"
    pf_160_180 => tr_160_180>=min_trades ? "160 / 180" : "n/a"
    pf_160_190 => tr_160_190>=min_trades ? "160 / 190" : "n/a"
    
    pf_170_180 => tr_170_180>=min_trades ? "170 / 180" : "n/a"
    pf_170_190 => tr_170_190>=min_trades ? "170 / 190" : "n/a"
    
    pf_180_190 => tr_180_190>=min_trades ? "180 / 190" : "n/a"
    => "n/a"

best_total_trades = switch best_pf

    pf_20_30  => tr_20_30>=min_trades ? tr_20_30 : na
    pf_20_40  => tr_20_40>=min_trades ? tr_20_40 : na
    pf_20_50  => tr_20_50>=min_trades ? tr_20_50 : na
    pf_20_60  => tr_20_60>=min_trades ? tr_20_60 : na
    pf_20_70  => tr_20_70>=min_trades ? tr_20_70 : na
    pf_20_80  => tr_20_80>=min_trades ? tr_20_80 : na
    pf_20_90  => tr_20_90>=min_trades ? tr_20_90 : na
    pf_20_100 => tr_20_100>=min_trades ? tr_20_100 : na
    pf_30_40  => tr_30_40>=min_trades ? tr_30_40 : na
    pf_30_50  => tr_30_50>=min_trades ? tr_30_50 : na
    pf_30_60  => tr_30_60>=min_trades ? tr_30_60 : na
    pf_30_70  => tr_30_70>=min_trades ? tr_30_70 : na
    pf_30_80  => tr_30_80>=min_trades ? tr_30_80 : na
    pf_30_90  => tr_30_90>=min_trades ? tr_30_90 : na
    pf_30_100 => tr_30_100>=min_trades ? tr_30_100 : na
    pf_40_50  => tr_40_50>=min_trades ? tr_40_50 : na
    pf_40_60  => tr_40_60>=min_trades ? tr_40_60 : na
    pf_40_70  => tr_40_70>=min_trades ? tr_40_70 : na
    pf_40_80  => tr_40_80>=min_trades ? tr_40_80 : na
    pf_40_90  => tr_40_90>=min_trades ? tr_40_90 : na
    pf_40_100 => tr_40_100>=min_trades ? tr_40_100 : na
    pf_50_60  => tr_50_60>=min_trades ? tr_50_60 : na
    pf_50_70  => tr_50_70>=min_trades ? tr_50_70 : na
    pf_50_80  => tr_50_80>=min_trades ? tr_50_80 : na
    pf_50_90  => tr_50_90>=min_trades ? tr_50_90 : na
    pf_50_100 => tr_50_100>=min_trades ? tr_50_100 : na
    pf_50_110 => tr_50_110>=min_trades ? tr_50_110 : na
    pf_50_120 => tr_50_120>=min_trades ? tr_50_120 : na
    pf_50_130 => tr_50_130>=min_trades ? tr_50_130 : na
    pf_50_140 => tr_50_140>=min_trades ? tr_50_140 : na
    pf_50_150 => tr_50_150>=min_trades ? tr_50_150 : na
    pf_50_160 => tr_50_160>=min_trades ? tr_50_160 : na
    pf_50_170 => tr_50_170>=min_trades ? tr_50_170 : na
    pf_50_180 => tr_50_180>=min_trades ? tr_50_180 : na
    pf_50_190 => tr_50_190>=min_trades ? tr_50_190 : na
    pf_60_70  => tr_60_70>=min_trades ? tr_60_70 : na
    pf_60_80  => tr_60_80>=min_trades ? tr_60_80 : na
    pf_60_90  => tr_60_90>=min_trades ? tr_60_90 : na
    pf_60_100 => tr_60_100>=min_trades ? tr_60_100 : na
    pf_60_110 => tr_60_110>=min_trades ? tr_60_110 : na
    pf_60_120 => tr_60_120>=min_trades ? tr_60_120 : na
    pf_60_130 => tr_60_130>=min_trades ? tr_60_130 : na
    pf_60_140 => tr_60_140>=min_trades ? tr_60_140 : na
    pf_60_150 => tr_60_150>=min_trades ? tr_60_150 : na
    pf_60_160 => tr_60_160>=min_trades ? tr_60_160 : na
    pf_60_170 => tr_60_170>=min_trades ? tr_60_170 : na
    pf_60_180 => tr_60_180>=min_trades ? tr_60_180 : na
    pf_60_190 => tr_60_190>=min_trades ? tr_60_190 : na
    pf_70_80  => tr_70_80>=min_trades ? tr_70_80 : na
    pf_70_90  => tr_70_90>=min_trades ? tr_70_90 : na
    pf_70_100 => tr_70_100>=min_trades ? tr_70_100 : na
    pf_70_110 => tr_70_110>=min_trades ? tr_70_110 : na
    pf_70_120 => tr_70_120>=min_trades ? tr_70_120 : na
    pf_70_130 => tr_70_130>=min_trades ? tr_70_130 : na
    pf_70_140 => tr_70_140>=min_trades ? tr_70_140 : na
    pf_70_150 => tr_70_150>=min_trades ? tr_70_150 : na
    pf_70_160 => tr_70_160>=min_trades ? tr_70_160 : na
    pf_70_170 => tr_70_170>=min_trades ? tr_70_170 : na
    pf_70_180 => tr_70_180>=min_trades ? tr_70_180 : na
    pf_70_190 => tr_70_190>=min_trades ? tr_70_190 : na
    pf_80_90  => tr_80_90>=min_trades ? tr_80_90 : na
    pf_80_100 => tr_80_100>=min_trades ? tr_80_100 : na
    pf_80_110 => tr_80_110>=min_trades ? tr_80_110 : na
    pf_80_120 => tr_80_120>=min_trades ? tr_80_120 : na
    pf_80_130 => tr_80_130>=min_trades ? tr_80_130 : na
    pf_80_140 => tr_80_140>=min_trades ? tr_80_140 : na
    pf_80_150 => tr_80_150>=min_trades ? tr_80_150 : na
    pf_80_160 => tr_80_160>=min_trades ? tr_80_160 : na
    pf_80_170 => tr_80_170>=min_trades ? tr_80_170 : na
    pf_80_180 => tr_80_180>=min_trades ? tr_80_180 : na
    pf_80_190 => tr_80_190>=min_trades ? tr_80_190 : na
    pf_90_100 => tr_90_100>=min_trades ? tr_90_100 : na
    pf_90_110 => tr_90_110>=min_trades ? tr_90_110 : na
    pf_90_120 => tr_90_120>=min_trades ? tr_90_120 : na
    pf_90_130 => tr_90_130>=min_trades ? tr_90_130 : na
    pf_90_140 => tr_90_140>=min_trades ? tr_90_140 : na
    pf_90_150 => tr_90_150>=min_trades ? tr_90_150 : na
    pf_90_160 => tr_90_160>=min_trades ? tr_90_160 : na
    pf_90_170 => tr_90_170>=min_trades ? tr_90_170 : na
    pf_90_180 => tr_90_180>=min_trades ? tr_90_180 : na
    pf_90_190 => tr_90_190>=min_trades ? tr_90_190 : na
    pf_100_110 => tr_100_110>=min_trades ? tr_100_110 : na
    pf_100_120 => tr_100_120>=min_trades ? tr_100_120 : na
    pf_100_130 => tr_100_130>=min_trades ? tr_100_130 : na
    pf_100_140 => tr_100_140>=min_trades ? tr_100_140 : na
    pf_100_150 => tr_100_150>=min_trades ? tr_100_150 : na
    pf_100_160 => tr_100_160>=min_trades ? tr_100_160 : na
    pf_100_170 => tr_100_170>=min_trades ? tr_100_170 : na
    pf_100_180 => tr_100_180>=min_trades ? tr_100_180 : na
    pf_100_190 => tr_100_190>=min_trades ? tr_100_190 : na
    pf_110_120 => tr_110_120>=min_trades ? tr_110_120 : na
    pf_110_130 => tr_110_130>=min_trades ? tr_110_130 : na
    pf_110_140 => tr_110_140>=min_trades ? tr_110_140 : na
    pf_110_150 => tr_110_150>=min_trades ? tr_110_150 : na
    pf_110_160 => tr_110_160>=min_trades ? tr_110_160 : na
    pf_110_170 => tr_110_170>=min_trades ? tr_110_170 : na
    pf_110_180 => tr_110_180>=min_trades ? tr_110_180 : na
    pf_120_130 => tr_120_130>=min_trades ? tr_120_130 : na
    pf_120_140 => tr_120_140>=min_trades ? tr_120_140 : na
    pf_120_150 => tr_120_150>=min_trades ? tr_120_150 : na
    pf_120_160 => tr_120_160>=min_trades ? tr_120_160 : na
    pf_120_170 => tr_120_170>=min_trades ? tr_120_170 : na
    pf_120_180 => tr_120_180>=min_trades ? tr_120_180 : na
    pf_130_140 => tr_130_140>=min_trades ? tr_130_140 : na
    pf_130_150 => tr_130_150>=min_trades ? tr_130_150 : na
    pf_130_160 => tr_130_160>=min_trades ? tr_130_160 : na
    pf_130_170 => tr_130_170>=min_trades ? tr_130_170 : na
    pf_130_180 => tr_130_180>=min_trades ? tr_130_180 : na
    pf_130_190 => tr_130_190>=min_trades ? tr_130_190 : na
    pf_140_150 => tr_140_150>=min_trades ? tr_140_150 : na
    pf_140_160 => tr_140_160>=min_trades ? tr_140_160 : na
    pf_140_170 => tr_140_170>=min_trades ? tr_140_170 : na
    pf_140_180 => tr_140_180>=min_trades ? tr_140_180 : na
    pf_140_190 => tr_140_190>=min_trades ? tr_140_190 : na
    pf_150_160 => tr_150_160>=min_trades ? tr_150_160 : na
    pf_150_170 => tr_150_170>=min_trades ? tr_150_170 : na
    pf_150_180 => tr_150_180>=min_trades ? tr_150_180 : na
    pf_150_190 => tr_150_190>=min_trades ? tr_150_190 : na
    pf_160_170 => tr_160_170>=min_trades ? tr_160_170 : na
    pf_160_180 => tr_160_180>=min_trades ? tr_160_180 : na
    pf_160_190 => tr_160_190>=min_trades ? tr_160_190 : na
    pf_170_180 => tr_170_180>=min_trades ? tr_170_180 : na
    pf_170_190 => tr_170_190>=min_trades ? tr_170_190 : na
    pf_180_190 => tr_180_190>=min_trades ? tr_180_190 : na
    => na

best_fast = switch best_pair
    "20 / 30"  => fastMA_20_30
    "20 / 40"  => fastMA_20_40
    "20 / 50"  => fastMA_20_50
    "20 / 60"  => fastMA_20_60
    "20 / 70"  => fastMA_20_70
    "20 / 80"  => fastMA_20_80
    "20 / 90"  => fastMA_20_90
    "20 / 100" => fastMA_20_100
    "30 / 40"  => fastMA_30_40
    "30 / 50"  => fastMA_30_50
    "30 / 60"  => fastMA_30_60
    "30 / 70"  => fastMA_30_70
    "30 / 80"  => fastMA_30_80
    "30 / 90"  => fastMA_30_90
    "30 / 100" => fastMA_30_100
    "40 / 50"  => fastMA_40_50
    "40 / 60"  => fastMA_40_60
    "40 / 70"  => fastMA_40_70
    "40 / 80"  => fastMA_40_80
    "40 / 90"  => fastMA_40_90
    "40 / 100" => fastMA_40_100
    "50 / 60"   => fastMA_50_60
    "50 / 70"   => fastMA_50_70
    "50 / 80"   => fastMA_50_80
    "50 / 90"   => fastMA_50_90
    "50 / 100"  => fastMA_50_100
    "50 / 110"  => fastMA_50_110
    "50 / 120"  => fastMA_50_120
    "50 / 130"  => fastMA_50_130
    "50 / 140"  => fastMA_50_140
    "50 / 150"  => fastMA_50_150
    "50 / 160"  => fastMA_50_160
    "50 / 170"  => fastMA_50_170
    "50 / 180"  => fastMA_50_180
    "50 / 190"  => fastMA_50_190
    "60 / 70"   => fastMA_60_70
    "60 / 80"   => fastMA_60_80
    "60 / 90"   => fastMA_60_90
    "60 / 100"  => fastMA_60_100
    "60 / 110"  => fastMA_60_110
    "60 / 120"  => fastMA_60_120
    "60 / 130"  => fastMA_60_130
    "60 / 140"  => fastMA_60_140
    "60 / 150"  => fastMA_60_150
    "60 / 160"  => fastMA_60_160
    "60 / 170"  => fastMA_60_170
    "60 / 180"  => fastMA_60_180
    "60 / 190"  => fastMA_60_190
    "70 / 80"   => fastMA_70_80
    "70 / 90"   => fastMA_70_90
    "70 / 100"  => fastMA_70_100
    "70 / 110"  => fastMA_70_110
    "70 / 120"  => fastMA_70_120
    "70 / 130"  => fastMA_70_130
    "70 / 140"  => fastMA_70_140
    "70 / 150"  => fastMA_70_150
    "70 / 160"  => fastMA_70_160
    "70 / 170"  => fastMA_70_170
    "70 / 180"  => fastMA_70_180
    "70 / 190"  => fastMA_70_190
    "80 / 90"   => fastMA_80_90
    "80 / 100"  => fastMA_80_100
    "80 / 110"  => fastMA_80_110
    "80 / 120"  => fastMA_80_120
    "80 / 130"  => fastMA_80_130
    "80 / 140"  => fastMA_80_140
    "80 / 150"  => fastMA_80_150
    "80 / 160"  => fastMA_80_160
    "80 / 170"  => fastMA_80_170
    "80 / 180"  => fastMA_80_180
    "80 / 190"  => fastMA_80_190
    "90 / 100"  => fastMA_90_100
    "90 / 110"  => fastMA_90_110
    "90 / 120"  => fastMA_90_120
    "90 / 130"  => fastMA_90_130
    "90 / 140"  => fastMA_90_140
    "90 / 150"  => fastMA_90_150
    "90 / 160"  => fastMA_90_160
    "90 / 170"  => fastMA_90_170
    "90 / 180"  => fastMA_90_180
    "90 / 190"  => fastMA_90_190
    "100 / 110"  => fastMA_100_110
    "100 / 120"  => fastMA_100_120
    "100 / 130"  => fastMA_100_130
    "100 / 140"  => fastMA_100_140
    "100 / 150"  => fastMA_100_150
    "100 / 160"  => fastMA_100_160
    "100 / 170"  => fastMA_100_170
    "100 / 180"  => fastMA_100_180
    "100 / 190"  => fastMA_100_190
    "110 / 120" => fastMA_110_120
    "110 / 130" => fastMA_110_130
    "110 / 140" => fastMA_110_140
    "110 / 150" => fastMA_110_150
    "110 / 160" => fastMA_110_160
    "110 / 170" => fastMA_110_170
    "110 / 180" => fastMA_110_180
    "120 / 130" => fastMA_120_130
    "120 / 140" => fastMA_120_140
    "120 / 150" => fastMA_120_150
    "120 / 160" => fastMA_120_160
    "120 / 170" => fastMA_120_170
    "120 / 180" => fastMA_120_180
    "130 / 140" => fastMA_130_140
    "130 / 150" => fastMA_130_150
    "130 / 160" => fastMA_130_160
    "130 / 170" => fastMA_130_170
    "130 / 180" => fastMA_130_180
    "130 / 190" => fastMA_130_190
    "140 / 150" => fastMA_140_150
    "140 / 160" => fastMA_140_160
    "140 / 170" => fastMA_140_170
    "140 / 180" => fastMA_140_180
    "140 / 190" => fastMA_140_190
    "150 / 160" => fastMA_150_160
    "150 / 170" => fastMA_150_170
    "150 / 180" => fastMA_150_180
    "150 / 190" => fastMA_150_190
    "160 / 170" => fastMA_160_170
    "160 / 180" => fastMA_160_180
    "160 / 190" => fastMA_160_190
    "170 / 180" => fastMA_170_180
    "170 / 190" => fastMA_170_190
    "180 / 190" => fastMA_180_190
    => na

best_slow = switch best_pair
    "20 / 30"  => slowMA_20_30
    "20 / 40"  => slowMA_20_40
    "20 / 50"  => slowMA_20_50
    "20 / 60"  => slowMA_20_60
    "20 / 70"  => slowMA_20_70
    "20 / 80"  => slowMA_20_80
    "20 / 90"  => slowMA_20_90
    "20 / 100" => slowMA_20_100
    "30 / 40"  => slowMA_30_40
    "30 / 50"  => slowMA_30_50
    "30 / 60"  => slowMA_30_60
    "30 / 70"  => slowMA_30_70
    "30 / 80"  => slowMA_30_80
    "30 / 90"  => slowMA_30_90
    "30 / 100" => slowMA_30_100
    "40 / 50"  => slowMA_40_50
    "40 / 60"  => slowMA_40_60
    "40 / 70"  => slowMA_40_70
    "40 / 80"  => slowMA_40_80
    "40 / 90"  => slowMA_40_90
    "40 / 100" => slowMA_40_100
    "50 / 60"   => slowMA_50_60
    "50 / 70"   => slowMA_50_70
    "50 / 80"   => slowMA_50_80
    "50 / 90"   => slowMA_50_90
    "50 / 100"  => slowMA_50_100
    "50 / 110"  => slowMA_50_110
    "50 / 120"  => slowMA_50_120
    "50 / 130"  => slowMA_50_130
    "50 / 140"  => slowMA_50_140
    "50 / 150"  => slowMA_50_150
    "50 / 160"  => slowMA_50_160
    "50 / 170"  => slowMA_50_170
    "50 / 180"  => slowMA_50_180
    "50 / 190"  => slowMA_50_190
    "60 / 70"   => slowMA_60_70
    "60 / 80"   => slowMA_60_80
    "60 / 90"   => slowMA_60_90
    "60 / 100"  => slowMA_60_100
    "60 / 110"  => slowMA_60_110
    "60 / 120"  => slowMA_60_120
    "60 / 130"  => slowMA_60_130
    "60 / 140"  => slowMA_60_140
    "60 / 150"  => slowMA_60_150
    "60 / 160"  => slowMA_60_160
    "60 / 170"  => slowMA_60_170
    "60 / 180"  => slowMA_60_180
    "60 / 190"  => slowMA_60_190
    "70 / 80"   => slowMA_70_80
    "70 / 90"   => slowMA_70_90
    "70 / 100"  => slowMA_70_100
    "70 / 110"  => slowMA_70_110
    "70 / 120"  => slowMA_70_120
    "70 / 130"  => slowMA_70_130
    "70 / 140"  => slowMA_70_140
    "70 / 150"  => slowMA_70_150
    "70 / 160"  => slowMA_70_160
    "70 / 170"  => slowMA_70_170
    "70 / 180"  => slowMA_70_180
    "70 / 190"  => slowMA_70_190
    "80 / 90"   => slowMA_80_90
    "80 / 100"  => slowMA_80_100
    "80 / 110"  => slowMA_80_110
    "80 / 120"  => slowMA_80_120
    "80 / 130"  => slowMA_80_130
    "80 / 140"  => slowMA_80_140
    "80 / 150"  => slowMA_80_150
    "80 / 160"  => slowMA_80_160
    "80 / 170"  => slowMA_80_170
    "80 / 180"  => slowMA_80_180
    "80 / 190"  => slowMA_80_190
    "90 / 100"  => slowMA_90_100
    "90 / 110"  => slowMA_90_110
    "90 / 120"  => slowMA_90_120
    "90 / 130"  => slowMA_90_130
    "90 / 140"  => slowMA_90_140
    "90 / 150"  => slowMA_90_150
    "90 / 160"  => slowMA_90_160
    "90 / 170"  => slowMA_90_170
    "90 / 180"  => slowMA_90_180
    "90 / 190"  => slowMA_90_190
    "100 / 110"  => slowMA_100_110
    "100 / 120"  => slowMA_100_120
    "100 / 130"  => slowMA_100_130
    "100 / 140"  => slowMA_100_140
    "100 / 150"  => slowMA_100_150
    "100 / 160"  => slowMA_100_160
    "100 / 170"  => slowMA_100_170
    "100 / 180"  => slowMA_100_180
    "100 / 190"  => slowMA_100_190
    "110 / 120" => slowMA_110_120
    "110 / 130" => slowMA_110_130
    "110 / 140" => slowMA_110_140
    "110 / 150" => slowMA_110_150
    "110 / 160" => slowMA_110_160
    "110 / 170" => slowMA_110_170
    "110 / 180" => slowMA_110_180
    "120 / 130" => slowMA_120_130
    "120 / 140" => slowMA_120_140
    "120 / 150" => slowMA_120_150
    "120 / 160" => slowMA_120_160
    "120 / 170" => slowMA_120_170
    "120 / 180" => slowMA_120_180
    "130 / 140" => slowMA_130_140
    "130 / 150" => slowMA_130_150
    "130 / 160" => slowMA_130_160
    "130 / 170" => slowMA_130_170
    "130 / 180" => slowMA_130_180
    "130 / 190" => slowMA_130_190
    "140 / 150" => slowMA_140_150
    "140 / 160" => slowMA_140_160
    "140 / 170" => slowMA_140_170
    "140 / 180" => slowMA_140_180
    "140 / 190" => slowMA_140_190
    "150 / 160" => slowMA_150_160
    "150 / 170" => slowMA_150_170
    "150 / 180" => slowMA_150_180
    "150 / 190" => slowMA_150_190
    "160 / 170" => slowMA_160_170
    "160 / 180" => slowMA_160_180
    "160 / 190" => slowMA_160_190
    "170 / 180" => slowMA_170_180
    "170 / 190" => slowMA_170_190
    "180 / 190" => slowMA_180_190
    => na

var table stats_table = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 90))
if barstate.islast
    table.cell(stats_table, 0, 0, "Optimal MA Pair", text_color=color.white)
    table.cell(stats_table, 1, 0, best_pair, text_color=color.white)
    table.cell(stats_table, 0, 1, "Total Trades", text_color=color.white)
    table.cell(stats_table, 1, 1, str.tostring(best_total_trades), text_color=color.white)
    table.cell(stats_table, 0, 2, "Profit Factor", text_color=color.white)
    table.cell(stats_table, 1, 2, str.tostring(best_pf, "#.##"), text_color=color.white)

plot(best_fast, color=color.blue, title="Optimal Fast MA")
plot(best_slow, color=color.orange, title="Optimal Slow MA")
````
