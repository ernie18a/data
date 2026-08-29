<!-- tradingview-pine-id: PUB;7d3224fbd0864fc18ae6f7b0f67bba06 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Past

Source: https://www.tradingview.com/script/2tennpoc-RSI-Past-Can-Turn-RSI-Into-a-Directional-Tool/

## Description

The Relative Strength Index was created by J. Welles Wilder to measure overbought and oversold conditions. It’s also found popularity as an overall measure of direction because upward-trending stocks often hit overbought conditions. The opposite can be true with underperformers. 

Today’s custom script, RSI Past, attempts to capture this secondary use of RSI as a directional indicator. 

RSI Past achieves this by comparing how many bars have passed since RSI's most recent overbought and oversold readings. It then plots a simple difference between those two numbers.

Stocks with “bullish” signals will have positive readings that will increase each time RSI hits an overbought condition. 

“Bearish” readings are just the opposite, growing more negative as oversold conditions occur.

An examination of some individual stocks may show the usefulness of this approach. 

[symbol="NASDAQ:META"]Meta Platforms[/symbol], for example, hit an oversold condition almost exactly one year ago, and has remained under heavy selling pressure since:
[image]https://www.tradingview.com/x/vsxJwmrd/[/image]

[symbol="NYSE:XOM"]Exxon Mobil[/symbol], on the other hand, flipped to a bullish reading last October and has trended higher since:
[image]https://www.tradingview.com/x/P25WWgBZ/[/image]

This raises some interesting questions for Apple, shown on the main chart above.  AAPL’s RSI Past has maintained a bullish reading for over a year -- unlike most other big technology stocks and the broader Nasdaq-100. Could this reflect bigger directional strength, especially with prices holding the $150 level that’s had relevance several times mid-2021?

TradeStation has, for decades, advanced the trading industry, providing access to stocks, options, futures and cryptocurrencies. See our [Overview](https://www.tradingview.com/broker/TradeStation/) for more.

Important Information
TradeStation Securities, Inc., TradeStation Crypto, Inc., and TradeStation Technologies, Inc. are each wholly owned subsidiaries of TradeStation Group, Inc., all operating, and providing products and services, under the TradeStation brand and trademark. You Can Trade, Inc. is also a wholly owned subsidiary of TradeStation Group, Inc., operating under its own brand and trademarks. TradeStation Crypto, Inc. offers to self-directed investors and traders cryptocurrency brokerage services.  It is neither licensed with the SEC or the CFTC nor is it a Member of NFA. When applying for, or purchasing, accounts, subscriptions, products, and services, it is important that you know which company you will be dealing with. Please [click here](https://uploads.tradestation.com/uploads/TradeStation-Group-Inc-Companies.pdf) for further important information explaining what this means.
 
This content is for informational and educational purposes only. This is not a recommendation regarding any investment or investment strategy.  Any opinions expressed herein are those of the author and do not represent the views or opinions of TradeStation or any of its affiliates.
 
Investing involves risks. Past performance, whether actual or indicated by historical tests of strategies, is no guarantee of future performance or success. There is a possibility that you may sustain a loss equal to or greater than your entire investment regardless of which asset class you trade (equities, options, futures, or digital assets); therefore, you should not invest or risk money that you cannot afford to lose. Before trading any asset class, first read the relevant risk disclosure statements on the Important Documents page, found here: [www.tradestation.com/important-information](http://www.tradestation.com/important-information).

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeStation

// RSI Past
//@version=5
indicator(title="RSI Past", shorttitle="RSI Past", overlay=false, precision=0)

// RSI input settings
rsiLength = input.int(14, title="Length", minval=2, group="RSI Settings")
rsiSource = input(close, title="Price", group="RSI Settings")
rsiOverbought = input.float(70, title="Overbought Threshold", group="RSI Settings")
rsiOversold = input.float(30, title="Oversold Threshold", group="RSI Settings")

// RSI input colors
color aboveColor = input.color(color.green, "Above 0 Color", group="Color Settings")
color belowColor = input.color(color.red, "Below 0 Color", group="Color Settings")
color zeroColor = input.color(color.black, "Zero Line Color", group="Color Settings")

var color plotColor = zeroColor
var int lastBullish = na
var int lastBearish = na
var float reading = na

rsiValue = ta.rsi(rsiSource, rsiLength)

if rsiValue < rsiOversold
    lastBearish := bar_index
else if rsiValue > rsiOverbought
    lastBullish := bar_index

if lastBullish and lastBearish
    reading := lastBullish - lastBearish

if reading
    if reading > 0
        plotColor := aboveColor
    else if reading < 0
        plotColor := belowColor
    else
        plotColor := zeroColor

readingPlot = plot(reading, title="RSI Pass", color=plotColor, style=plot.style_area, linewidth=3)
````
