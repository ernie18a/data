<!-- tradingview-pine-id: PUB;86b48cbd603246a4a78b3f3ba2f019cd -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Money Flow Index Glau

Source: https://www.tradingview.com/script/inZxfUwO/

## Description

Money Flow Index Glau (MFI)
Description

The Money Flow Index (MFI) is a technical analysis oscillator that combines price and volume to evaluate buying and selling pressure in an asset.

This indicator uses the typical price (HLC3 = (High + Low + Close) / 3) and calculates the MFI on a scale from 0 to 100.

In this version, in addition to the traditional MFI line, the line color changes according to its direction:

Green: MFI is rising compared with the previous period, indicating increasing buying pressure.
Red: MFI is falling compared with the previous period, indicating increasing selling pressure.
Yellow: MFI remains unchanged compared with the previous period.

The indicator displays three main levels:

80: Overbought
50: Middle Band
20: Oversold
How to Adjust the Length Parameter

The Length parameter determines the number of periods used to calculate the MFI.

The default value is 14, which is the traditional MFI setting.

Shorter Length

Examples: 5, 7, or 9

A shorter Length makes the MFI more responsive to recent price and volume changes.

It can be useful for:

Short-term trading
Scalping
Identifying faster changes in buying and selling pressure

However, shorter settings can also produce more fluctuations and potentially more false signals, especially in highly volatile markets.

Default Length

14 periods

This is the traditional MFI setting and provides a balanced starting point for different markets and timeframes.

Longer Length

Examples: 21, 30, or 50

A longer Length makes the indicator smoother and less sensitive to short-term price and volume fluctuations.

It can be useful for:

Swing trading
Broader trend analysis
Reducing short-term market noise

Keep in mind that a longer Length can also make the indicator react more slowly to changes.

How to Interpret the Levels
MFI Above 80

When the MFI moves above 80, the asset is traditionally considered to be in an overbought condition.

This does not automatically mean that the price will decline.

The MFI can remain above 80 during a strong uptrend. Therefore, price action and other technical factors should be considered before making a trading decision.

MFI Below 20

When the MFI moves below 20, the asset is traditionally considered to be in an oversold condition.

This does not automatically mean that the price will rise.

During a strong downtrend, the MFI can remain below 20 for an extended period.

MFI Between 20 and 80

When the MFI remains between 20 and 80, it is outside the traditional overbought and oversold zones.

The 50 level can be used as an additional reference to evaluate the relative balance between buying and selling pressure.

How to Use the Color Direction

One of the main visual features of this version is the color change of the MFI line according to its direction.

Green Line

When the MFI line is green, the current MFI value is higher than the previous value.

This indicates that money flow is increasing compared with the previous period.

It can be used as confirmation of increasing bullish momentum.

Red Line

When the MFI line is red, the current MFI value is lower than the previous value.

This indicates that money flow is decreasing compared with the previous period.

It can be used as confirmation of increasing bearish momentum.

Yellow Line

When the MFI line is yellow, the current MFI value is equal to the previous value.

In this situation, there has been no change in the MFI value between the two periods.

Example of a Potential Bullish Scenario

A possible bullish setup can occur when:

The MFI moves near or below 20.
The MFI begins to rise.
The line changes to green.
The MFI recovers above 20.
Price action provides additional confirmation of a potential recovery.

This combination can be used as part of a broader analysis of a potential reversal or recovery.

Example of a Potential Bearish Scenario

A possible bearish setup can occur when:

The MFI moves near or above 80.
The MFI begins to decline.
The line changes to red.
The MFI moves back below 80.
Price action provides additional confirmation of potential weakness.

This combination can be used as part of a broader analysis of a potential correction or reversal.

Failure Swings

The MFI can also be analyzed using patterns commonly known as Failure Swings.

Bullish Failure Swing

A traditional interpretation can occur when:

The MFI falls below 20.
The MFI moves back above 20.
The MFI pulls back again but remains above 20.
The MFI breaks above the previous high.

This behavior may indicate increasing buying pressure.

Bearish Failure Swing

A traditional interpretation can occur when:

The MFI rises above 80.
The MFI moves back below 80.
The MFI rebounds but remains below 80.
The MFI breaks below the previous low.

This behavior may indicate increasing selling pressure.

Suggested Settings

These settings are only general references and should be tested according to the asset and timeframe being used.

Short-Term / Scalping

Length: 5–9
Levels: 20 / 50 / 80

Day Trading

Length: 9–14
Levels: 20 / 50 / 80

Swing Trading

Length: 14–21
Levels: 20 / 50 / 80

Trend Analysis

Length: 21–50
Levels: 20 / 50 / 80

There is no universally optimal setting. MFI behavior depends on the asset, volume, volatility, and timeframe.

Recommended Use

The MFI should be used as a confirmation tool, rather than as a standalone source of buy or sell signals.

It can be combined with:

Market structure
Support and resistance
Trend analysis
Price action
Volume analysis
Moving averages
Divergences
Chart patterns

A touch or cross of the 20 or 80 levels should not automatically be interpreted as a buy or sell signal.

The MFI is generally more useful when combined with other technical analysis methods and price structure.

Limitations

The MFI is calculated from historical price and volume data. Therefore, it does not predict the future and can remain in overbought or oversold conditions during strong trends.

The line color only represents the direction of the MFI compared with the previous period. It does not, by itself, represent a confirmed buy or sell signal.

Parameters should be adapted and tested according to the asset and timeframe being analyzed.

TradingView Publishing Guidelines

This indicator was developed using Pine Script® v6.

For public publication on TradingView, the description should clearly explain the script's purpose, functionality, usage, and limitations.

The script should be presented accurately without misleading performance claims or guarantees of profitability.

Avoid claims such as:

Guaranteed profits
Guaranteed winning signals
Guaranteed accuracy
Unrealistic win rates
Promises of future performance

This indicator is intended as a technical analysis tool and should not be presented as financial advice.

Risk Disclaimer

This indicator is provided for educational and informational purposes only.

It is not financial, investment, or trading advice.

Past market behavior does not guarantee future results. Always conduct your own analysis and consider appropriate risk management before making any trading decision.

Trade responsibly.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/

// © Canhoto-Medium

//@version=6
indicator(title="Money Flow Index Glau", shorttitle="MFI", format=format.price, precision=2)

length = input.int(title="MFI Line Length", defval=14, group="🔔 Sound Alerts", minval=2)

src = hlc3
mf = ta.mfi(src, length)

// Direção do MFI
delta = mf - mf[1]

// Definição de cores
colorMFI = delta > 0 ? color.green : color.red

// Plot
plot(mf, "MF", color=colorMFI, linewidth=2)

// Níveis
overbought = hline(80, title="Overbought", color=#787B86)
hline(50, "Middle Band", color=color.new(#787B86, 50))
oversold = hline(20, title="Oversold", color=#787B86)

// Fundo
fill(overbought, oversold, color=color.rgb(126, 87, 194, 90), title="Background")

// Alertas Time Real
mfiUpRT = delta > 0
mfiDownRT = delta < 0

// Alertas Past / Confirmados
mfiUpPast = delta > 0 and barstate.isconfirmed
mfiDownPast = delta < 0 and barstate.isconfirmed

// 2 Alertas Time Real
alertcondition(mfiUpRT, title="MFI Up — Real Time", message="MFI is moving UP in real time.")
alertcondition(mfiDownRT, title="MFI Down — Real Time", message="MFI is moving DOWN in real time.")

// 2 Alertas Past
alertcondition(mfiUpPast, title="MFI Up — Past", message="MFI moved UP — candle confirmed.")
alertcondition(mfiDownPast, title="MFI Down — Past", message="MFI moved DOWN — candle confirmed.")
````
