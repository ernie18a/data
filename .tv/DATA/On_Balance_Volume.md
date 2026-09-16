<!-- tradingview-pine-id: PUB;d3074287d91e42a9838bf53b4b721be8 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# On Balance Volume

Source: https://www.tradingview.com/script/PoevtH59/

## Description

Overview

This indicator is based on On Balance Volume (OBV) and is designed to analyze the relationship between price and volume, helping traders identify potential accumulation, distribution, trend confirmation, and changes in volume flow.

In addition to the traditional OBV, the indicator allows users to apply different moving-average types to smooth the OBV and, optionally, add Bollinger Bands around the smoothed OBV.

The indicator also uses dynamic colors, making it easier to visually identify the direction of both the OBV and its moving average.

1. On Balance Volume (OBV)

OBV accumulates or subtracts volume according to price movement:

If the current closing price is higher than the previous close, volume is added to OBV.
If the current closing price is lower than the previous close, volume is subtracted from OBV.
If there is no change in price, OBV remains unchanged.
Interpretation

Rising OBV:

May indicate increasing buying pressure, accumulation, or confirmation of an uptrend.

Falling OBV:

May indicate increasing selling pressure, distribution, or confirmation of a downtrend.

OBV should not be used in isolation. Combining it with price action, trend structure, support and resistance, and other technical factors may improve the quality of the analysis.

2. OBV Dynamic Colors

The main OBV line uses three colors:

🟢 Green

OBV is increasing compared with the previous period.

This indicates positive volume flow.

🔴 Red

OBV is decreasing compared with the previous period.

This indicates negative volume flow.

🟡 Yellow

OBV has not changed compared with the previous period.

3. Smoothing

The Type setting allows users to apply a moving average to the OBV.

Available options:

None
SMA
SMA + Bollinger Bands
EMA
SMMA (RMA)
WMA
VWMA

Smoothing can be used to reduce short-term fluctuations and make the underlying direction of OBV easier to identify.

4. Moving Average Type
None

No moving average is applied.

Only the original OBV is displayed.

Useful for:

Faster analysis;
Immediate identification of OBV changes;
Traders who prefer raw volume-flow information.
SMA — Simple Moving Average

Calculates the arithmetic average of OBV over the selected number of periods.

Characteristics:

Smoother than the raw OBV;
Slower to react to sudden changes;
Useful for identifying the broader direction of volume flow.
SMA + Bollinger Bands

Applies an SMA to OBV and adds Bollinger Bands.

This option displays:

A central moving average;
An upper Bollinger Band;
A lower Bollinger Band.

The bands help identify periods when OBV is moving relatively far from its recent average.

EMA — Exponential Moving Average

The EMA gives greater weight to recent OBV values.

Characteristics:

Responds faster to changes in OBV;
Useful for short- and medium-term analysis;
Generally more responsive than an equivalent SMA.
SMMA (RMA)

The SMMA/RMA is a smoother moving average designed to reduce short-term fluctuations.

It can be useful for traders who want a more stable view of the underlying OBV trend.

WMA — Weighted Moving Average

The WMA assigns greater weight to more recent values.

It generally responds faster to changes in OBV than an equivalent SMA.

VWMA — Volume Weighted Moving Average

The VWMA weights values according to volume.

Because OBV itself is already volume-based, this option may produce a different smoothing behavior compared with traditional moving averages and should be evaluated according to the trader's strategy.

5. Length

The Length parameter determines the number of periods used to calculate the moving average.

The default value is:

14 periods

Shorter Length

Examples: 5, 9, or 10.

The moving average becomes faster and more sensitive.

Potentially useful for:

Short-term trading;
Faster detection of changes in volume flow;
Scalping and intraday strategies, depending on the market.

However, shorter lengths can also generate more noise and false signals.

Longer Length

Examples: 20, 50, or 100.

The moving average becomes slower and smoother.

Potentially useful for:

Trend analysis;
Swing trading;
Identifying the dominant volume-flow direction.

The longer the length, the greater the delay in reacting to changes in OBV.

6. Moving Average Dynamic Colors

The OBV moving average also changes color dynamically.

🟢 Green

The moving average is rising.

🔴 Red

The moving average is falling.

🟡 Yellow

The moving average is unchanged.

This allows traders to quickly identify the direction of the smoothed OBV.

7. Bollinger Bands

Bollinger Bands are available only when:

Type = SMA + Bollinger Bands

The bands are calculated using the standard deviation of OBV.

The indicator displays:

Upper Bollinger Band
SMA / Middle Band
Lower Bollinger Band

The distance between the bands expands or contracts according to changes in OBV volatility.

8. BB StdDev

The BB StdDev parameter controls the distance of the Bollinger Bands from the moving average.

Default value:

2.0

Lower value

Example: 1.0–1.5.

The bands become narrower.

This increases sensitivity and causes OBV to reach the bands more frequently.

Higher value

Example: 2.5–3.0.

The bands become wider.

This reduces the frequency of band touches and can help highlight more extreme OBV movements.

9. How to Interpret the Indicator

The indicator can primarily be used for four types of analysis:

1. Trend Confirmation

During an uptrend:

Price rising + OBV rising

may indicate volume confirmation of the bullish trend.

During a downtrend:

Price falling + OBV falling

may indicate confirmation of selling pressure.

2. Bullish Divergence

A potential bullish divergence occurs when:

Price makes lower lows while OBV makes higher lows.

This may indicate weakening selling pressure and a possible loss of bearish momentum.

3. Bearish Divergence

A potential bearish divergence occurs when:

Price makes higher highs while OBV makes lower highs.

This may indicate weakening buying pressure.

Important: Divergences do not guarantee a reversal. They should be considered warning signals and ideally confirmed by price action or other technical factors.

10. Using Bollinger Bands on OBV

When Bollinger Bands are enabled, they can help identify unusual movements in volume flow.

OBV near or above the Upper Band

May indicate an unusually strong positive OBV movement relative to its recent average.

OBV near or below the Lower Band

May indicate an unusually strong negative OBV movement.

However, touching or crossing a Bollinger Band does not automatically mean buy or sell.

During strong trends, OBV may remain near one of the bands for extended periods.

11. Suggested Settings

There is no universally optimal configuration. The appropriate settings depend on the asset, timeframe, volatility, and trading strategy.

Short-Term Analysis

A possible starting configuration:

Type: EMA
Length: 9 or 14

This provides a faster response to changes in OBV.

Medium-Term Analysis

A possible starting configuration:

Type: SMA
Length: 20

This provides a balance between responsiveness and smoothing.

Longer-Term Trend Analysis

A possible starting configuration:

Type: SMA
Length: 50

This provides greater smoothing and reduces sensitivity to short-term fluctuations.

Bollinger Band Analysis

A possible starting configuration:

Type: SMA + Bollinger Bands
Length: 20
BB StdDev: 2.0

These settings are reference points for testing and are not investment recommendations.

12. Practical Usage

One possible approach is to use the indicator together with price structure.

Potential Bullish Setup

Look for a combination such as:

Price showing a bullish market structure;
OBV rising;
OBV moving average turning green;
OBV confirming upward price movements;
A breakout or recovery of an important price level.
Potential Bearish Setup

Look for a combination such as:

Price showing a bearish market structure;
OBV falling;
OBV moving average turning red;
OBV confirming downward price movements;
A breakdown or rejection of an important price level.

The indicator is best used as a confirmation tool, rather than as the sole reason to enter a trade.

13. Recommended Starting Configuration

For traders who are new to the indicator, a simple starting configuration is:

Type: SMA
Length: 14

Then compare it with:

Type: EMA
Length: 14

Observe which configuration better represents the behavior of the asset and timeframe being analyzed.

For Bollinger Band analysis:

Type: SMA + Bollinger Bands
Length: 20
BB StdDev: 2.0

14. Important Notes

OBV is a cumulative indicator. Therefore, its absolute values can vary significantly depending on the available historical data and the asset being analyzed.

Signals should be interpreted in the context of:

Market trend;
Price structure;
Support and resistance;
Volume;
Volatility;
Timeframe;
Overall market conditions.

No parameter should be considered universally superior.

It is recommended to test different configurations using historical data, Bar Replay, and paper trading before applying any strategy to live trading.

This indicator is a technical analysis tool and does not constitute financial, investment, or trading advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/

// © Canhoto-Medium

//@version=6
indicator(title="On Balance Volume", shorttitle="OBV", format=format.volume, timeframe="", timeframe_gaps=true)

var cumVol = 0.

cumVol += nz(volume)

if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

src = close

obv = ta.cum(math.sign(ta.change(src)) * volume)

// ===== DYNAMIC COLOR =====

deltaObv = ta.change(obv)

obvColor = deltaObv > 0 ? color.green :
           deltaObv < 0 ? color.red :
           color.yellow

plot(obv, color=obvColor, title="OnBalanceVolume", linewidth=2)

// ================= SMOOTHING =================

GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected."
maTypeInput = input.string("None", "Type", options=["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="GRP - 🔔 Sound Alerts")
isBB = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group="GRP - 🔔 Sound Alerts", active=maTypeInput != "None")
bbMultInput = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5, tooltip=TT_BB, group="GRP - 🔔 Sound Alerts", active=isBB)
enableMA = maTypeInput != "None"

// ===== MA FUNCTION =====

ma(source, length, MAtype) =>
    switch MAtype
        "SMA" => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

// ===== CALCULATION =====

smoothingMA = enableMA ? ma(obv, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(obv, maLengthInput) * bbMultInput : na

// ===== MA COLOR =====

deltaMA = ta.change(smoothingMA)

maColor = deltaMA > 0 ? color.green :
          deltaMA < 0 ? color.red :
          color.yellow

plot(smoothingMA, "OBV-based MA", color=maColor, display=enableMA ? display.all : display.none)

// ===== BANDS =====

bbUpperBand = plot(smoothingMA + smoothingStDev, title="Upper Bollinger Band", color=color.green, display=isBB ? display.all : display.none)
bbLowerBand = plot(smoothingMA - smoothingStDev, title="Lower Bollinger Band", color=color.green, display=isBB ? display.all : display.none)

fill(bbUpperBand, bbLowerBand, color=isBB ? color.new(color.green, 90) : na)


// ================= ALERTS =================

// ===== ALERT SOURCE =====
// If no MA is selected, use OBV color.
// If an MA is selected, use MA color.

alertLong = enableMA ? deltaMA > 0 : deltaObv > 0
alertShort = enableMA ? deltaMA < 0 : deltaObv < 0
alertNeutral = enableMA ? deltaMA == 0 : deltaObv == 0

// ===== REAL-TIME ALERTS =====

alertcondition(alertLong, title="OBV Long Real-Time", message="OBV Line LONG Real-Time")
alertcondition(alertNeutral, title="OBV Neutral Real-Time", message="OBV Line NEUTRAL Real-Time")
alertcondition(alertShort, title="OBV Short Real-Time", message="OBV Line SHORT Real-Time")

// ===== CONFIRMED ALERTS =====

pastLong = alertLong and barstate.isconfirmed
pastShort = alertShort and barstate.isconfirmed

alertcondition(pastLong, title="Confirmed OBV Bull", message="Confirmed OBV Line Bull")
alertcondition(pastShort, title="Confirmed OBV Bear", message="Confirmed OBV Line Bear")


// ===== MOVING AVERAGE REAL-TIME ALERTS =====

maLongExtra = enableMA and deltaMA > 0
maShortExtra = enableMA and deltaMA < 0

alertcondition(maLongExtra, title="MA Long Real-Time", message="Moving Average LONG Real-Time")
alertcondition(maShortExtra, title="MA Short Real-Time", message="Moving Average SHORT Real-Time")

// ===== CONFIRMED MOVING AVERAGE ALERTS =====

pastMALong = maLongExtra and barstate.isconfirmed
pastMAShort = maShortExtra and barstate.isconfirmed

alertcondition(pastMALong, title="Confirmed MA Long", message="Confirmed Moving Average LONG")
alertcondition(pastMAShort, title="Confirmed MA Short", message="Confirmed Moving Average SHORT")
````
