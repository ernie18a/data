# Multi-Timeframe EMA 15m 1H

- url: https://www.tradingview.com/script/gUbmhS5n-Multi-Timeframe-EMA-15m-1H/
- type: indicator
- pine_id: PUB;b9fd65a856a94506be9ebd0d611dd261
- version: 1.0

## Description

[b]Multi-Timeframe EMA 15m 1H[/b]

Multi-Timeframe EMA 15m 1H is a simple trend and pullback framework designed specifically for traders using the [b]5-minute chart[/b].

The indicator displays two smooth EMA lines:

[list]
[*]Dark Blue — 15-minute EMA
[*]Red — 1-hour EMA
[/list]

The default EMA length is [b]20[/b], and the length can be adjusted from the settings.

The purpose of the indicator is to provide a clean visual framework for studying EMA structure, price direction, pullbacks, retests, and potential trend continuation on the 5-minute chart.

It does [b]not[/b] generate automatic buy or sell signals.

[b]Key Features[/b]

[list]
[*]15-minute EMA
[*]1-hour EMA
[*]Adjustable EMA length
[*]Default EMA length of 20
[*]Independent visibility controls
[*]Customizable EMA colors
[*]Smooth EMA lines
[*]Designed specifically for the 5-minute chart
[*]Clean and minimal chart presentation
[/list]

[b]How to Use[/b]

The indicator can be used to study two primary EMA-based setup scenarios.

[b]Scenario 1 — EMA Compression / No Cross[/b]

This setup occurs when the 15-minute and 1-hour EMA move close to each other but do not cross.

[b]Bullish Setup[/b]

1. The two EMA lines move close together.
2. The EMAs remain on the same side relative to each other and do not cross.
3. Price moves back above both EMA lines.
4. Wait for a 5-minute candle to close above both EMAs.
5. The close can be used as confirmation for a potential long setup.

https://www.tradingview.com/x/TQRa4MOV/

[b]Bearish Setup[/b]

The same concept can be applied in reverse:

1. The two EMA lines move close together.
2. The EMAs do not cross.
3. Price moves below both EMA lines.
4. Wait for a 5-minute candle to close below both EMAs.
5. The close can be used as confirmation for a potential short setup.

https://www.tradingview.com/x/GwLZzJze/

[b]Scenario 2 — EMA Cross + Retest[/b]

The second setup occurs when the two EMA lines cross.

Rather than entering immediately after the crossover, the approach is to wait for price to return to the EMA area and look for confirmation.

[b]Bullish Setup[/b]

1. The 15-minute and 1-hour EMAs cross.
2. Price establishes itself on the bullish side of the EMA structure.
3. Wait for price to return and retest the EMA area.
4. Look for price to react from the area.
5. Enter only after a 5-minute candle closes back in the direction of the trend.

https://www.tradingview.com/x/mArw3XVh/

[b]Bearish Setup[/b]

The same process applies in reverse:

1. The EMAs cross in a bearish direction.
2. Price establishes itself below the EMA structure.
3. Wait for a retest of the EMA area.
4. Look for bearish rejection or reaction.
5. Wait for a 5-minute candle to close back in the bearish direction before considering the setup.

https://www.tradingview.com/x/RY9CUzKQ/

[b]Recommended Use[/b]

This indicator is designed for traders who want a simple visual framework for:

[list]
[*]Trend analysis
[*]EMA compression
[*]EMA crossovers
[*]Pullback analysis
[*]Retest setups
[*]Potential trend continuation
[*]5-minute price-action confirmation
[/list]

The EMA structure should be considered together with market structure, key levels, volatility, session context, and price action rather than used as a standalone trading system.

[b]Limitations[/b]

EMA-based setups can produce false signals, particularly during sideways or highly volatile market conditions.

Possible situations include:

[list]
[*]Failed EMA crosses
[*]Failed retests
[*]False breakouts
[*]Temporary moves above or below the EMA structure
[*]Rapid reversals
[*]Extended periods of EMA compression
[/list]

[i]The indicator does not guarantee trade outcomes and does not provide financial advice or automatic buy/sell recommendations.[/i]

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe EMA 15m 1H", overlay=true)

//────────────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────────────
length = input.int(20, "EMA Length", minval=1)

show_15min = input.bool(true, "Show 15-minute EMA")
show_60min = input.bool(true, "Show 1-hour EMA")

color_15min = input.color(#00008B, "15-minute EMA Color")
color_60min = input.color(#FF0000, "1-hour EMA Color")

//────────────────────────────────────────────────────────────
// Smooth EMA calculation
//────────────────────────────────────────────────────────────
f_smooth_ema(src, len) =>
    alpha = 2.0 / (len + 1.0)
    float emaValue = na
    emaValue := na(emaValue[1]) ? src : alpha * src + (1.0 - alpha) * emaValue[1]
    emaValue

//────────────────────────────────────────────────────────────
// Higher-timeframe-equivalent smooth EMAs on 5-minute data
//
// 15 minutes = 3 × 5-minute candles
// 1 hour    = 12 × 5-minute candles
//
// This preserves the smooth continuous-line behavior of the
// original indicator while keeping the calculation on 5m data.
//────────────────────────────────────────────────────────────
ema_15 = f_smooth_ema(close, length * 3)
ema_60 = f_smooth_ema(close, length * 12)

//────────────────────────────────────────────────────────────
// Plotting
//────────────────────────────────────────────────────────────
plot(
     show_15min ? ema_15 : na,
     color=color_15min,
     title="15-minute EMA",
     linewidth=2)

plot(
     show_60min ? ema_60 : na,
     color=color_60min,
     title="1-hour EMA",
     linewidth=2)
````
