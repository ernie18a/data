# Wilder’s Moving Average Strategy

- url: https://www.tradingview.com/script/wXtQeoOg/
- type: strategy
- pine_id: PUB;WESoV1lrFa2no5xbMQxPGer14j1HAhSg
- version: 2.0

## Description

The Wilder’s Moving Average indicator (Wilder’s Smoothed Moving Average ) was developed by Welles Wilder and introduced in his 1978 book, “New Concepts in Technical Trading Systems.” Mr. Wilder did not use the standard EMA formula; instead, the following formula is used: EMA = Input * K + EMA * (1-K), where K = 2 / (N+1). Then to find the Wilder’s Moving Average, the following calculation is performed: Input * K + EMA * (1-K), where K =1/N.

Type to use

Moving averages are commonly used to identify trends and reversals as well as identifying support and resistance levels. Moving averages such the WMA and EMA , which are more sensitive to recent prices (experience less lag with price) will turn before an SMA . They are therefore more suitable for dynamic trades, which are reactive to short term price movements. Moving averages such as the SMA move more slowly providing valuable information on the long dominant trend. They can however be prone to giving late signals causing the trader to miss significant parts of the price movement.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("Wilder’s Moving Average Strategy", overlay=true)

malength = input(36, "length", minval=1)

longd = false
shortd = false
lineColor = color.yellow
wild = 0.0

wild := nz(wild[1]) + (close -nz(wild[1]))/malength

longd := wild > wild[1]

shortd := wild < wild[1]

lineColor := longd ? color.green : shortd ? color.red : color.yellow

plot(wild, color=lineColor, linewidth=2, title="WILD")

if longd
    strategy.entry("long", strategy.long, when = strategy.position_size <= 0)
else
    if shortd
        strategy.entry("short", strategy.short, when = strategy.position_size >= 0)
````
