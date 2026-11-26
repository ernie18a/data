# Reversal Trading Bot Strategy[BullByte]

- url: https://www.tradingview.com/script/cXVnf1WH-Reversal-Trading-Bot-Strategy-BullByte/
- type: strategy
- pine_id: PUB;465b6bc4cc7943079e4d3fa8c1e11090
- version: 8.0

## Description

[b]Overview[/b]:

The indicator [b]Reversal Trading Bot Strategy[BullByte][/b] is crafted to capture potential market reversal points by combining momentum, volatility, and trend alignment filters. It uses a blend of technical indicators to identify both bullish and bearish reversal setups, ensuring that multiple market conditions are met before entering a trade.

[b]Core Components[/b]:

[b]Technical Indicators Used[/b]:

[b]RSI (Relative Strength Index)[/b]:

[b]Purpose[/b]: Detects divergence conditions by comparing recent lows/highs in price with the RSI.

[b]Parameter[/b]: Length of 8.

[b]Bollinger Bands (BB)[/b]:

[b]Purpose[/b]: Measures volatility and identifies price levels that are statistically extreme.

[b]Parameter[/b]: Length of 20 and a 2-standard deviation multiplier.

[b]ADX (Average Directional Index)[/b] & [b]DMI (Directional Movement Index)[/b]:

[b]Purpose[/b]: Quantifies the strength of the trend. The ADX threshold is set at 20, and additional filters check for the alignment of the directional indicators (DI+ and DI–).

[b]ATR (Average True Range)[/b]:

[b]Purpose[/b]: Provides a volatility measure used to set stop levels and determine risk through trailing stops.

[b]Volume SMA (Simple Moving Average of Volume[/b]):

[b]Purpose[/b]: Helps confirm strength by comparing the current volume against a 20-period average, with an optional filter to ensure volume is at least twice the SMA.

[b]User-Defined Toggle Filters[/b]:

[b]Volume Filter[/b]: Confirms that the volume is above average (or twice the SMA) before taking trades.

[b]ADX Trend Alignment Filter[/b]: Checks that the ADX’s directional indicators support the trade direction.

[b]BB Close Confirmation[/b]: Optionally refines the entry by requiring price to be beyond the upper or lower Bollinger Band rather than just above or below.

[b]RSI Divergence Exit[/b]: Allows the script to close positions if RSI divergence is detected.

[b]BB Mean Reversion Exit[/b]: Closes positions if the price reverts to the Bollinger Bands’ middle line.

[b]Risk/Reward Filter[/b]: Ensures that the potential reward is at least twice the risk by comparing the distance to the Bollinger Band with the ATR.

[b]Candle Movement Filter[/b]: Optional filter to require a minimum percentage move in the candle to confirm momentum.

[b]ADX Trend Exit[/b]: Closes positions if the ADX falls below the threshold and the directional indicators reverse.

[b]Entry Conditions[/b]:

[b]Bullish Entry[/b]:

[b]RSI Divergence[/b]: Checks if the current close is lower than a previous low while the RSI is above the previous low, suggesting bullish divergence.

[b]Bollinger Confirmation[/b]: Requires that the price is above the lower (or upper if confirmation is toggled) Bollinger Band.

[b]Volume & Trend Filters[/b]: Combines volume condition, ADX strength, and an optional candle momentum condition.

[b]Risk/Reward Check[/b]: Validates that the trade meets a favorable risk-to-reward ratio.

[b]Bearish Entry[/b]:

Uses a mirror logic of the bullish entry by checking for bearish divergence, ensuring the price is below the appropriate Bollinger level, and confirming volume, trend strength, candle pattern, and risk/reward criteria.

[b]Trade Execution and Exit Strateg[/b]y:

[b]Trade Execution[/b]:

Upon meeting the entry conditions, the strategy initiates a long or short position.

[b]Stop Loss & Trailing Stops[/b]:

A stop-loss is dynamically set using the ATR value, and trailing stops are implemented as a percentage of the close price.

[b]Exit Conditions[/b]:

Additional exit filters can trigger early closures based on RSI divergence, mean reversion (via the middle Bollinger Band), or a weakening trend as signaled by ADX falling below its threshold.

This multi-layered exit strategy is designed to lock in gains or minimize losses if the market begins to reverse unexpectedly.

[b]How the Strategy Works in Different Market Conditions[/b]:

[b]Trending Markets[/b]:

The ADX filter ensures that trades are only taken when the trend is strong. When the market is trending, the directional movement indicators help confirm the momentum, making the reversal signal more reliable.

[b]Ranging Markets[/b]:

In choppy markets, the Bollinger Bands expand and contract, while the RSI divergence can highlight potential turning points. The optional filters can be adjusted to avoid false signals in low-volume or low-volatility conditions.

[b]Volatility Management[/b]:

With ATR-based stop-losses and a risk/reward filter, the strategy adapts to current market volatility, ensuring that risk is managed consistently.

[b]Recommendation on using this Strategy with a Trading Bot[/b]:
This strategy is well-suited for high-frequency trading (HFT) due to its ability to quickly identify reversal setups and execute trades dynamically with automated stop-loss and trailing exits. By integrating this script with a TradingView webhook-based bot or an API-driven execution system, traders can automate trade entries and exits in real-time, reducing manual execution delays and capitalizing on fast market movements.

[b]Disclaimer[/b]:
This script is provided for educational and informational purposes only. It is not intended as investment advice. Trading involves significant risk, and you should always conduct your own research and analysis before making any trading decisions. The author is not responsible for any losses incurred while using this script.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte

//@version=6
strategy("Reversal Trading Bot Strategy [BullByte] Final Version",
     overlay=true,
     initial_capital=1000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=30,
     calc_on_every_tick=false,
     process_orders_on_close=true,
     max_lines_count=500,
     max_labels_count=500)


// === USER INPUTS ===
rsiLength         = input.int(8,    "RSI Length", tooltip="Number of bars used to calculate the Relative Strength Index (RSI).")
fastRsiLength     = input.int(14,   "Fast RSI Length", tooltip="Number of bars for fast RSI crossover confirmation.")
slowRsiLength     = input.int(21,   "Slow RSI Length", tooltip="Number of bars for slow RSI crossover confirmation.")
bbLength          = input.int(20,   "BB Length", tooltip="Number of bars used to calculate Bollinger Bands (BB).")
adxThreshold      = input.int(20,   "ADX Threshold", tooltip="Minimum ADX value to confirm trend strength.")
divLookback       = input.int(5,    "Divergence Lookback", tooltip="Number of past bars to analyze for RSI divergence.")
volumeFilter      = input.bool(false, "Volume ≥ 2× SMA", tooltip="If enabled, requires volume to be at least twice its 20-bar SMA.")
adxFilter         = input.bool(false, "ADX Strength & Alignment", tooltip="If enabled, requires ADX above threshold and DI+ > DI- for longs, DI- > DI+ for shorts.")
bbFilter          = input.bool(false, "BB Close Confirmation", tooltip="If enabled, requires close below lower BB for longs, above upper BB for shorts.")
rsiCrossFilter    = input.bool(false, "RSI Crossover Confirmation", tooltip="If enabled, requires fast RSI to cross over slow RSI for longs, cross under for shorts.")
stopLossPct       = input.float(1.0, "Stop-Loss %", step=0.1, tooltip="Percentage below/above entry price for stop-loss.") / 100
takeProfitPct     = input.float(2.0, "Take-Profit %", step=0.1, tooltip="Percentage above/below entry price for take-profit.") / 100

// === INDICATORS ===
rsi               = ta.rsi(close, rsiLength)[1]
[diP_raw, diM_raw, adx_raw] = ta.dmi(14, 14)
diP               = diP_raw[1]
diM               = diM_raw[1]
adx               = adx_raw[1]
[ub, mb, lb]      = ta.bb(close, bbLength, 2)
upperBB           = ub[1]
midBB             = mb[1]
lowerBB           = lb[1]
volSma            = ta.sma(volume, 20)[1]

// Fast & Slow RSI for crossover confirmation
efastRSI          = ta.rsi(close, fastRsiLength)[1]
eslowRSI          = ta.rsi(close, slowRsiLength)[1]
fastCrossUp       = ta.crossover(efastRSI, eslowRSI)
fastCrossDown     = ta.crossunder(efastRSI, eslowRSI)
rsiCrossOKBull    = not rsiCrossFilter or fastCrossUp
rsiCrossOKBear    = not rsiCrossFilter or fastCrossDown

// === DIVERGENCE DETECTION ===
prevLow           = ta.lowest(low, divLookback)[1]
prevLow_1         = ta.lowest(low, divLookback)[2]
prevRsi           = ta.lowest(rsi, divLookback)[1]
prevRsi_1         = ta.lowest(rsi, divLookback)[2]
bullDiv           = prevLow < prevLow_1 and prevRsi > prevRsi_1

prevHigh          = ta.highest(high, divLookback)[1]
prevHigh_1        = ta.highest(high, divLookback)[2]
prevRsiH          = ta.highest(rsi, divLookback)[1]
prevRsiH_1        = ta.highest(rsi, divLookback)[2]
bearDiv           = prevHigh > prevHigh_1 and prevRsiH < prevRsiH_1

// === SIGNAL FILTERS ===
volOKBull         = not volumeFilter or volume[1] >= 2 * volSma
adxOKBull         = not adxFilter or (adx > adxThreshold and diP > diM)
bbOKBull          = not bbFilter or close[1] <= lowerBB

volOKBear         = not volumeFilter or volume[1] >= 2 * volSma
adxOKBear         = not adxFilter or (adx > adxThreshold and diM > diP)
bbOKBear          = not bbFilter or close[1] >= upperBB

// === ENTRY SIGNALS ===
bullEntry         = bullDiv and volOKBull and adxOKBull and bbOKBull and rsiCrossOKBull
bearEntry         = bearDiv and volOKBear and adxOKBear and bbOKBear and rsiCrossOKBear

// === TP/SL AND EXECUTION ===
var line tpLine = na
var line slLine = na
var float prevPosSize = 0.0
var float tpPrice = na
var float slPrice = na

if barstate.isconfirmed
    if bullEntry
        strategy.entry("Long", strategy.long)
    if bearEntry
        strategy.entry("Short", strategy.short)

    if strategy.position_size > 0
        strategy.exit("Long Exit", from_entry="Long",
                      stop=strategy.position_avg_price * (1 - stopLossPct),
                      limit=strategy.position_avg_price * (1 + takeProfitPct))
    if strategy.position_size < 0
        strategy.exit("Short Exit", from_entry="Short",
                      stop=strategy.position_avg_price * (1 + stopLossPct),
                      limit=strategy.position_avg_price * (1 - takeProfitPct))

    if strategy.position_size != prevPosSize and strategy.position_size != 0
        line.delete(tpLine)
        line.delete(slLine)
        entryPrice = strategy.opentrades.entry_price(0)
        if strategy.position_size > 0
            tpPrice := entryPrice * (1 + takeProfitPct)
            slPrice := entryPrice * (1 - stopLossPct)
        else
            tpPrice := entryPrice * (1 - takeProfitPct)
            slPrice := entryPrice * (1 + stopLossPct)
        tpLine := line.new(bar_index, tpPrice, bar_index + 1, tpPrice, extend=extend.right, style=line.style_dashed, color=color.green)
        slLine := line.new(bar_index, slPrice, bar_index + 1, slPrice, extend=extend.right, style=line.style_dashed, color=color.red)

    if strategy.position_size == 0 and prevPosSize != 0
        line.delete(tpLine)
        line.delete(slLine)
        tpLine := na
        slLine := na
        tpPrice := na
        slPrice := na

    prevPosSize := strategy.position_size

// === ALERTS ===
alertcondition(bullEntry, title="BullByte Long Entry", message="Long entry signal detected at {{close}}")
alertcondition(bearEntry, title="BullByte Short Entry", message="Short entry signal detected at {{close}}")
````
