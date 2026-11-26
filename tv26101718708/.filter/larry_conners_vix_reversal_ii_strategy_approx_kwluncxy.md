# Larry Conners Vix Reversal II Strategy (approx.)

- url: https://www.tradingview.com/script/kWluNCXY/
- type: strategy
- pine_id: PUB;55cd71cdb6c8457790bf002a7adff072
- version: 1.0

## Description

This Pine Script™ strategy is a modified version of the original Larry Connors VIX Reversal II Strategy, designed for short-term trading in market indices like the S&P 500. The strategy utilizes the Relative Strength Index (RSI) of the VIX (Volatility Index) to identify potential overbought or oversold market conditions. The logic is based on the assumption that extreme levels of market volatility often precede reversals in price.

How the Strategy Works

The strategy calculates the RSI of the VIX using a 25-period lookback window. The RSI is a momentum oscillator that measures the speed and change of price movements. It ranges from 0 to 100 and is often used to identify overbought and oversold conditions in assets.

Overbought Signal: When the RSI of the VIX rises above 61, it signals a potential overbought condition in the market. The strategy looks for a RSI downtick (i.e., when RSI starts to fall after reaching this level) as a trigger to enter a long position.

Oversold Signal: Conversely, when the RSI of the VIX drops below 42, the market is considered oversold. A RSI uptick (i.e., when RSI starts to rise after hitting this level) serves as a signal to enter a short position.

The strategy holds the position for a minimum of 7 days and a maximum of 12 days, after which it exits automatically.

Larry Connors: Background

Larry Connors is a prominent figure in quantitative trading, specializing in short-term market strategies. He is the co-author of several influential books on trading, such as Street Smarts (1995), co-written with Linda Raschke, and How Markets Really Work. Connors' work focuses on developing rules-based systems using volatility indicators like the VIX and oscillators such as RSI to exploit mean-reversion patterns in financial markets.
Risks of the Strategy

While the Larry Connors VIX Reversal II Strategy can capture reversals in volatile market environments, it also carries significant risks:

Over-Optimization: This modified version adjusts RSI levels and holding periods to fit recent market data. If market conditions change, the strategy might no longer be effective, leading to false signals.

Drawdowns in Trending Markets: This is a mean-reversion strategy, designed to profit when markets return to a previous mean. However, in strongly trending markets, especially during extended bull or bear phases, the strategy might generate losses due to early entries or exits.
Volatility Risk: Since this strategy is linked to the VIX, an instrument that reflects market volatility, large spikes in volatility can lead to unexpected, fast-moving market conditions, potentially leading to larger-than-expected losses.

Scientific Literature and Supporting Research

The use of RSI and VIX in trading strategies has been widely discussed in academic research. RSI is one of the most studied momentum oscillators, and numerous studies show that it can capture mean-reversion effects in various markets, including equities and derivatives.

Wong et al. (2003) investigated the effectiveness of technical trading rules such as RSI, finding that it has predictive power in certain market conditions, particularly in mean-reverting markets .
The VIX, often referred to as the “fear index,” reflects market expectations of volatility and has been a focal point in research exploring volatility-based strategies. Whaley (2000) extensively reviewed the predictive power of VIX, noting that extreme VIX readings often correlate with turning points in the stock market .

Modified Version of Original Strategy

This script is a modified version of Larry Connors' original VIX Reversal II strategy. The key differences include:

    Adjusted RSI period to 25 (instead of 2 or 4 commonly used in Connors’ other work).
    Overbought and oversold levels modified to 61 and 42, respectively.
    Specific holding period (7 to 12 days) is predefined to reduce holding risk.

These modifications aim to adapt the strategy to different market environments, potentially enhancing performance under specific volatility conditions. However, as with any system, constant evaluation and testing in live markets are crucial.

References

Wong, W. K., Manzur, M., & Chew, B. K. (2003). How rewarding is technical analysis? Evidence from Singapore stock market. Applied Financial Economics, 13(7), 543-551.
    
Whaley, R. E. (2000). The investor fear gauge. Journal of Portfolio Management, 26(3), 12-17.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EdgeTools

//@version=5
strategy("Larry Conners Vix Reversal II Strategy (approx.)", overlay=false)

// Input parameters
vixSymbol = input.symbol("CBOE:VIX", "VIX Symbol")  // VIX symbol input
rsiPeriod = input.int(25, title="RSI Period", minval=1)  // RSI period for the VIX
overboughtLevel = input.int(61, title="RSI Overbought Level", minval=1)  // RSI level to signal overbought
oversoldLevel = input.int(42, title="RSI Oversold Level", minval=1)  // RSI level to signal oversold
minHoldingDays = input.int(7, title="Minimum Holding Days", minval=1)  // Minimum holding period
maxHoldingDays = input.int(12, title="Maximum Holding Days", minval=1)  // Maximum holding period

// Colors for visualization (RGB)
buyColor = color.rgb(0, 255, 0)  // Green for buy signals
sellColor = color.rgb(255, 0, 0)  // Red for sell signals
vixLineColor = color.rgb(0, 0, 255)  // Blue for VIX plot

// Get VIX data
vixClose = request.security(vixSymbol, "D", close)

// Calculate RSI of VIX
vixRSI = ta.rsi(vixClose, rsiPeriod)

// Conditions
isOverbought = vixRSI >= overboughtLevel
isOversold = vixRSI <= oversoldLevel

// Detect RSI downtick after being overbought (Buy Condition)
rsiDowntick = isOverbought and ta.crossover(vixRSI, overboughtLevel)

// Detect RSI uptick after being oversold (Sell Condition)
rsiUptick = isOversold and ta.crossunder(vixRSI, oversoldLevel)

// Track holding days
var int holdingDays = 0

// Buy when RSI downtick after overbought condition
if (rsiDowntick and holdingDays == 0)
    strategy.entry("Buy", strategy.long)
    holdingDays := 1

// Sell when RSI uptick after oversold condition
if (rsiUptick and holdingDays == 0)
    strategy.entry("Sell", strategy.short)
    holdingDays := 1

// Exit after 5 to 8 days
if (holdingDays > 0)
    holdingDays += 1
    if (holdingDays >= minHoldingDays and holdingDays <= maxHoldingDays)
        strategy.close("Buy")
        strategy.close("Sell")
        holdingDays := 0

// Plot VIX close and RSI for reference
plot(vixRSI, color=vixLineColor, title="VIX Close")
hline(overboughtLevel, "Overbought Level", color=color.new(buyColor, 0))
hline(oversoldLevel, "Oversold Level", color=color.new(sellColor, 0))

// Highlight buy and sell conditions using color.new() for transparency
bgcolor(rsiDowntick ? color.new(buyColor, 90) : na, title="Buy Condition Background")
bgcolor(rsiUptick ? color.new(sellColor, 90) : na, title="Sell Condition Background")
````
