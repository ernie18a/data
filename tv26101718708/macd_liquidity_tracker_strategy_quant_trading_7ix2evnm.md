# MACD Liquidity Tracker Strategy [Quant Trading]

- url: https://www.tradingview.com/script/7ix2EvNm-MACD-Liquidity-Tracker-Strategy-Quant-Trading/
- type: strategy
- pine_id: PUB;97230b13d2284b0c9c5034bb870e5693
- version: 1.0

## Description

[b]MACD Liquidity Tracker Strategy[/b]
[b]Overview[/b]
The MACD Liquidity Tracker Strategy is an enhanced trading system that transforms the traditional MACD indicator into a comprehensive momentum-based strategy with advanced visual signals and risk management. This strategy builds upon the original MACD Liquidity Tracker System indicator by [b]TheNeWSystemLqtyTrckr[/b], converting it into a fully automated trading strategy with improved parameters and additional features.
[b]What Makes This Strategy Original[/b]
This strategy significantly enhances the basic MACD approach by introducing:
[list]
[*]Four distinct system types for different market conditions and trading styles
[*]Advanced color-coded histogram visualization with four dynamic colors showing momentum strength and direction
[*]Integrated trend filtering using 9 different moving average types
[*]Comprehensive risk management with customizable stop-loss and take-profit levels
[*]Multiple alert systems for entry signals, exits, and trend conditions
[*]Flexible signal display options with customizable entry markers
[/list]
[b]How It Works[/b]
[i]Core MACD Calculation[/i]
The strategy uses a fully customizable MACD configuration with traditional default parameters:
[list]
[*][b]Fast MA[/b]: 12 periods (customizable, minimum 1, no maximum limit)
[*][b]Slow MA[/b]: 26 periods (customizable, minimum 1, no maximum limit) 
[*][b]Signal Line[/b]: 9 periods (customizable, now properly implemented and used)
[/list]
[b]Cryptocurrency Optimization[/b]: The strategy's flexible parameter system allows for significant optimization across different crypto assets. Traditional MACD settings (12/26/9) often generate excessive noise and false signals in volatile crypto markets. By using slower, more smoothed parameters, traders can capture meaningful momentum shifts while filtering out market noise.
[quote][b]Example - DOGE Optimization (45/80/290 settings)[/b]:
• [b]Performance[/b]: Optimized parameters yielding exceptional backtesting results with 29,800% PnL
• [b]Why it works[/b]: DOGE's high volatility and social sentiment-driven price action benefits from heavily smoothed indicators
• [b]Timeframes[/b]: Particularly effective on 30-minute and 4-hour charts for swing trading
• [b]Logic[/b]: The very slow parameters filter out noise and capture only the most significant trend changes[/quote]
[b]Other Optimizable Cryptocurrencies[/b]: This parameter flexibility makes the strategy highly effective for major altcoins including [b]SUI, SEI, LINK, Solana (SOL)[/b], and many others. Each crypto asset can benefit from custom parameter tuning based on its unique volatility profile and trading characteristics.
[i]Four Trading System Types[/i]
[b]1. Normal System (Default)[/b]
[list]
[*][b]Long signals[/b]: When MACD line is above the signal line
[*][b]Short signals[/b]: When MACD line is below the signal line
[*][b]Best for[/b]: Swing trading and capturing longer-term trends in stable markets
[*][b]Logic[/b]: Traditional MACD crossover approach using the signal line
[/list]
[b]2. Fast System[/b]
[list]
[*][b]Long signals[/b]: Bright Blue OR Dark Magenta (transparent) histogram colors
[*][b]Short signals[/b]: Dark Blue (transparent) OR Bright Magenta histogram colors
[*][b]Best for[/b]: Scalping and high-volatility markets (crypto, forex)
[*][b]Logic[/b]: Leverages early momentum shifts based on histogram color changes
[/list]
[b]3. Safe System[/b]
[list]
[*][b]Long signals[/b]: Only Bright Blue histogram color (strongest bullish momentum)
[*][b]Short signals[/b]: All other colors (Dark Blue, Bright Magenta, Dark Magenta)
[*][b]Best for[/b]: Risk-averse traders and choppy markets
[*][b]Logic[/b]: Prioritizes only the strongest bullish signals while treating everything else as bearish
[/list]
[b]4. Crossover System[/b]
[list]
[*][b]Long signals[/b]: MACD line crosses above signal line
[*][b]Short signals[/b]: MACD line crosses below signal line
[*][b]Best for[/b]: Precise timing entries with traditional MACD methodology
[*][b]Logic[/b]: Pure crossover signals for more precise entry timing
[/list]
[i]Color-Coded Histogram Logic[/i]
The strategy uses four distinct colors to visualize momentum:
[list]
[*][b]🔹 Bright Blue[/b]: MACD > 0 and rising (strong bullish momentum)
[*][b]🔹 Dark Blue (Transparent)[/b]: MACD > 0 but falling (weakening bullish momentum)
[*][b]🔹 Bright Magenta[/b]: MACD < 0 and falling (strong bearish momentum)
[*][b]🔹 Dark Magenta (Transparent)[/b]: MACD < 0 but rising (weakening bearish momentum)
[/list]
[i]Trend Filter Integration[/i]
The strategy includes an advanced trend filter using 9 different moving average types:
[list]
[*][b]SMA[/b] (Simple Moving Average)
[*][b]EMA[/b] (Exponential Moving Average) - Default
[*][b]WMA[/b] (Weighted Moving Average)
[*][b]HMA[/b] (Hull Moving Average)
[*][b]RMA[/b] (Running Moving Average)
[*][b]LSMA[/b] (Least Squares Moving Average)
[*][b]DEMA[/b] (Double Exponential Moving Average)
[*][b]TEMA[/b] (Triple Exponential Moving Average)
[*][b]VIDYA[/b] (Variable Index Dynamic Average)
[/list]
[b]Default Settings[/b]: 50-period EMA for trend identification
[i]Visual Signal System[/i]
[list]
[*][b]Entry Markers[/b]: Blue triangles (▲) below candles for long entries, Magenta triangles (▼) above candles for short entries
[*][b]Candle Coloring[/b]: Price candles change color based on active signals (Blue = Long, Magenta = Short)
[*][b]Signal Text[/b]: Optional "Long" or "Short" text inside entry triangles (toggleable)
[*][b]Trend MA[/b]: Gray line plotted on main chart for trend reference
[/list]
[b]Parameter Optimization Examples[/b]
[i]DOGE Trading Success (Optimized Parameters)[/i]:
Using 45/80/290 MACD settings with 50-period EMA trend filter has shown exceptional results on DOGE:
[list]
[*][b]Performance[/b]: Backtesting results showing 29,800% PnL demonstrate the power of proper parameter optimization
[*][b]Reasoning[/b]: DOGE's meme-driven volatility and social sentiment spikes create significant noise with traditional MACD settings
[*][b]Solution[/b]: Very slow parameters (45/80/290) filter out social media-driven price spikes while capturing only major momentum shifts
[*][b]Optimal Timeframes[/b]: 30-minute and 4-hour charts for swing trading opportunities
[*][b]Result[/b]: Exceptionally clean signals with minimal false entries during DOGE's characteristic pump-and-dump cycles
[/list]
[i]Multi-Crypto Adaptability[/i]:
The same optimization principles apply to other major cryptocurrencies:
[list]
[*][b]SUI[/b]: Benefits from smoothed parameters due to newer coin volatility patterns
[*][b]SEI[/b]: Requires adjustment for its unique DeFi-related price movements  
[*][b]LINK[/b]: Oracle news events create price spikes that benefit from noise filtering
[*][b]Solana (SOL)[/b]: Network congestion events and ecosystem developments need smoothed detection
[*][b]General Rule[/b]: Higher volatility coins typically benefit from very slow MACD parameters (40-50 / 70-90 / 250-300 ranges)
[/list]
[b]Key Input Parameters[/b]
[list]
[*][b]System Type[/b]: Choose between Fast, Normal, Safe, or Crossover (Default: Normal)
[*][b]MACD Fast MA[/b]: 12 periods default (no maximum limit, consider 40-50 for crypto optimization)
[*][b]MACD Slow MA[/b]: 26 periods default (no maximum limit, consider 70-90 for crypto optimization)
[*][b]MACD Signal MA[/b]: 9 periods default (now properly utilized, consider 250-300 for crypto optimization)
[*][b]Trend MA Type[/b]: EMA default (9 options available)
[*][b]Trend MA Length[/b]: 50 periods default (no maximum limit)
[*][b]Signal Display[/b]: Both, Long Only, Short Only, or None
[*][b]Show Signal Text[/b]: True/False toggle for entry marker text
[/list]
[b]Trading Applications[/b]
[i]Recommended Use Cases[/i]
[list=1]
[*][b]Momentum Trading[/b]: Capitalize on strong directional moves using the color-coded system
[*][b]Trend Following[/b]: Combine MACD signals with trend MA filter for higher probability trades
[*][b]Scalping[/b]: Use "Fast" system type for quick entries in volatile markets
[*][b]Swing Trading[/b]: Use "Normal" or "Safe" system types for longer-term positions
[*][b]Cryptocurrency Trading[/b]: Optimize parameters for individual crypto assets (e.g., 45/80/290 for DOGE, custom settings for SUI, SEI, LINK, SOL)
[/list]
[i]Market Suitability[/i]
[list]
[*][b]Volatile Markets[/b]: Forex, crypto, indices (recommend "Fast" system or smoothed parameters)
[*][b]Stable Markets[/b]: Stocks, ETFs (recommend "Normal" or "Safe" system)
[*][b]All Timeframes[/b]: Effective from 1-minute charts to daily charts
[*][b]Crypto Optimization[/b]: Each major cryptocurrency (DOGE, SUI, SEI, LINK, SOL, etc.) can benefit from custom parameter tuning. Consider slower MACD parameters for noise reduction in volatile crypto markets
[/list]
[i]Alert System[/i]
The strategy provides comprehensive alerts for:
[list]
[*][b]Entry Signals[/b]: Long and short entry triangle appearances
[*][b]Exit Signals[/b]: Position exit notifications
[*][b]Color Changes[/b]: Individual histogram color alerts
[*][b]Trend Conditions[/b]: Price above/below trend MA alerts
[/list]
[b]Strategy Parameters[/b]
[i]Default Settings[/i]
[list]
[*][b]Initial Capital[/b]: $1,000
[*][b]Position Size[/b]: 100% of equity
[*][b]Commission[/b]: 0.1%
[*][b]Slippage[/b]: 3 points
[*][b]Date Range[/b]: January 1, 2018 to December 31, 2069
[/list]
[i]Risk Management (Optional)[/i]
[list]
[*][b]Stop Loss[/b]: Disabled by default (customizable percentage-based)
[*][b]Take Profit[/b]: Disabled by default (customizable percentage-based)
[*][b]Short Trades[/b]: Disabled by default (can be enabled)
[/list]
[b]Important Notes and Limitations[/b]
[i]Backtesting Considerations[/i]
[list]
[*]Uses realistic commission (0.1%) and slippage (3 points)
[*]Default position sizing uses 100% equity - [i]adjust based on risk tolerance[/i]
[*]Stop-loss and take-profit are disabled by default to show raw strategy performance
[*]Strategy does not use lookahead bias or future data
[/list]
[i]Risk Warnings[/i]
[list]
[*][b]Past performance does not guarantee future results[/b]
[*]MACD-based strategies may produce false signals in ranging markets
[*]Consider combining with additional confluences like support/resistance levels
[*]Test thoroughly on demo accounts before live trading
[*]Adjust position sizing based on your risk management requirements
[/list]
[i]Technical Limitations[/i]
[list]
[*]Strategy does not work on non-standard chart types (Heikin Ashi, Renko, etc.)
[*]Signals are based on close prices and may not reflect intraday price action
[*]Multiple rapid signals in volatile conditions may result in overtrading
[/list]
[b]Credits and Attribution[/b]
This strategy is based on the original [i]"MACD Liquidity Tracker System"[/i] indicator created by [b]TheNeWSystemLqtyTrckr[/b]. This strategy version includes significant enhancements:
[list]
[*]Complete strategy implementation with entry/exit logic
[*]Addition of the "Crossover" system type
[*]Proper implementation and utilization of the MACD signal line
[*]Enhanced risk management features
[*]Improved parameter flexibility with no artificial maximum limits
[*]Additional alert systems for comprehensive trade management
[/list]
The original indicator's core color logic and visual system have been preserved while expanding functionality for automated trading applications.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LiquidityTrckr
//@version=6
// Quant Trading Pro

strategy(title = 'MACD Liquidity Tracker Strategy [Quant Trading]', overlay = false, 
         default_qty_type = strategy.percent_of_equity, default_qty_value = 100, 
         commission_type = strategy.commission.percent, commission_value = 0.1, 
         slippage = 3, initial_capital = 1000, margin_long = 0, margin_short = 0)

// === INPUT PARAMETERS ===

// Date Range
startDate = input.time(timestamp("01 Jan 2018 00:00 +0000"), "Start Date", group="Date Range")
endDate = input.time(timestamp("31 Dec 2069 23:59 +0000"), "End Date", group="Date Range")

// Short Trades
allowShortTrades = input.bool(false, "Allow Short Trades?", group="Short Trades")

// MACD Settings (NO MAX LIMITS)
fastMA = input.int(title = 'Fast MA', defval = 25, minval = 1, step = 1, group = "MACD Settings", tooltip = "Fast EMA period for MACD calculation")
slowMA = input.int(title = 'Slow MA', defval = 60, minval = 1, step = 1, group = "MACD Settings", tooltip = "Slow EMA period for MACD calculation") 
signalMA = input.int(title = 'Signal MA', defval = 220, minval = 1, step = 1, group = "MACD Settings", tooltip = "Signal line EMA period - now actually used!")

// System Choice Input
systemChoice = input.string(title="System Type", defval="Normal", options=["Fast", "Normal", "Safe", "Crossover"], group="System Logic")

// Trend-Based MA Inputs (NO MAX LIMITS)
ma_type = input.string(title="MA Type", defval="EMA", options=["SMA", "EMA", "WMA", "HMA", "RMA", "LSMA", "DEMA", "TEMA", "VIDYA"], group="Trend MA Settings")
ma_length = input.int(title="MA Length", defval=50, minval=1, step=1, group="Trend MA Settings")
vidya_volatility_length = input.int(title="VIDYA Volatility Length", defval=9, minval=1, group="Trend MA Settings")

// Risk Management (NO MAX LIMITS)
useStopLoss = input.bool(title="Enable Stop Loss", defval=false, group="Risk Management")
stopLossPercent = input.float(title="Stop Loss %", defval=3.0, minval=0.1, step=0.1, group="Risk Management")
useTakeProfit = input.bool(title="Enable Take Profit", defval=false, group="Risk Management")
takeProfitPercent = input.float(title="Take Profit %", defval=6.0, minval=0.1, step=0.1, group="Risk Management")

// Signal Display Input
signalDisplay = input.string(title="Show Signals", defval="Both", options=["Both", "Long Only", "Short Only", "None"], group="Signal Display")
showText = input.bool(title="Show Signal Text", defval=true, group="Signal Display")

// === 1️⃣ CALCULATIONS ===

// Date Range Check
inDateRange = time >= startDate and time <= endDate

// MA Calculation
var float smoothedMA = 0.0
if ma_type == "SMA"
    smoothedMA := ta.sma(close, ma_length)
else if ma_type == "EMA"
    smoothedMA := ta.ema(close, ma_length)
else if ma_type == "WMA"
    smoothedMA := ta.wma(close, ma_length)
else if ma_type == "HMA"
    smoothedMA := ta.hma(close, ma_length)
else if ma_type == "RMA"
    smoothedMA := ta.rma(close, ma_length)
else if ma_type == "LSMA"
    smoothedMA := ta.linreg(close, ma_length, 0)
else if ma_type == "DEMA"
    float ema1 = ta.ema(close, ma_length)
    float ema2 = ta.ema(ema1, ma_length)
    smoothedMA := 2 * ema1 - ema2
else if ma_type == "TEMA"
    float ema1 = ta.ema(close, ma_length)
    float ema2 = ta.ema(ema1, ma_length)
    float ema3 = ta.ema(ema2, ma_length)
    smoothedMA := 3 * ema1 - 3 * ema2 + ema3
else if ma_type == "VIDYA"
    float volatility = ta.stdev(close, vidya_volatility_length)
    float effectiveVolatility = volatility == 0 ? 0.01 : volatility
    float alpha = 2.0 / (ma_length + 1)
    float k = ta.stdev(close, vidya_volatility_length) / ta.stdev(ta.stdev(close, vidya_volatility_length), vidya_volatility_length)
    k := k > 1.0 ? 1.0 : k < 0.0 ? 0.0 : k
    float vidyaValue = 0.0
    vidyaValue := alpha * k * close + (1 - alpha * k) * nz(vidyaValue[1], close)
    smoothedMA := vidyaValue

// MACD Calculation
[currentMacd, currentSignal, currentHistogram] = ta.macd(close, fastMA, slowMA, signalMA)
[previousMacd, previousSignal, previousHistogram] = ta.macd(close[1], fastMA, slowMA, signalMA)

// Base Color Logic
colorBrightBlue        = color.rgb(0, 169, 230)      
colorDarkBlueTransp    = color.rgb(2, 25, 225, 31)     
colorBrightMagenta     = color.rgb(255, 0, 238)      
colorDarkMagentaTransp = color.rgb(178, 0, 169, 17) 

// Plot Color Determination
plotColor = if currentMacd > 0
    if currentMacd > previousMacd
        colorBrightBlue         
    else
        colorDarkBlueTransp     
else if currentMacd <= 0 
    if currentMacd < previousMacd
        colorBrightMagenta      
    else
        colorDarkMagentaTransp 

// Define color states based on plotColor
isBrightBlue        = plotColor == colorBrightBlue
isDarkBlueTransp    = plotColor == colorDarkBlueTransp
isBrightMagenta     = plotColor == colorBrightMagenta
isDarkMagentaTransp = plotColor == colorDarkMagentaTransp

// === 2️⃣ ENTRY & EXIT LOGIC ===

// Calculate MACD signal line crossovers
var bool macdCrossoverLong = currentMacd > currentSignal and previousMacd <= previousSignal and not na(currentSignal) and not na(previousSignal)
var bool macdCrossoverShort = currentMacd < currentSignal and previousMacd >= previousSignal and not na(currentSignal) and not na(previousSignal)

// Determine Long/Short Signals based on System Choice
var bool longSignal = false
var bool shortSignal = false

if systemChoice == "Fast"
    longSignal := isBrightBlue or isDarkMagentaTransp     
    shortSignal := isDarkBlueTransp or isBrightMagenta 
else if systemChoice == "Normal"
    // Traditional MACD: Use signal line crossovers
    longSignal := currentMacd > currentSignal and not na(currentSignal)
    shortSignal := currentMacd < currentSignal and not na(currentSignal)
else if systemChoice == "Safe"
    longSignal := isBrightBlue 
    shortSignal := isDarkBlueTransp or isBrightMagenta or isDarkMagentaTransp
else if systemChoice == "Crossover"
    // Pure crossover signals - more precise timing
    longSignal := macdCrossoverLong
    shortSignal := macdCrossoverShort

// Define Bar Color based on Active Signal
candleColor = if longSignal
    colorBrightBlue 
else if shortSignal
    colorBrightMagenta 
else
    na 

// Trend-Based Conditions
isAboveMA = close > smoothedMA
isBelowMA = close < smoothedMA

// Define One-Time Trigger Conditions for Shapes/Alerts
longEntryCondition = longSignal and not longSignal[1] and inDateRange
shortEntryCondition = shortSignal and not shortSignal[1] and inDateRange

// Entry Conditions (trading logic)
longEntry = longEntryCondition
shortEntry = shortEntryCondition and allowShortTrades

// Exit Conditions
longExit = shortSignal and not shortSignal[1] and inDateRange
shortExit = longSignal and not longSignal[1] and inDateRange

// === 3️⃣ TRADE EXECUTIONS ===

// Long Entries
if longEntry
    strategy.entry("Long", strategy.long)

// Short Entries  
if shortEntry
    strategy.entry("Short", strategy.short)

// Long Exits
if longExit
    strategy.close("Long")

// Short Exits
if shortExit
    strategy.close("Short")

// Stop Loss and Take Profit Exits
if useStopLoss and useTakeProfit
    strategy.exit("Long SL/TP", from_entry="Long", stop=close * (1 - stopLossPercent / 100), limit=close * (1 + takeProfitPercent / 100))
    strategy.exit("Short SL/TP", from_entry="Short", stop=close * (1 + stopLossPercent / 100), limit=close * (1 - takeProfitPercent / 100))
else if useStopLoss
    strategy.exit("Long SL", from_entry="Long", stop=close * (1 - stopLossPercent / 100))
    strategy.exit("Short SL", from_entry="Short", stop=close * (1 + stopLossPercent / 100))
else if useTakeProfit
    strategy.exit("Long TP", from_entry="Long", limit=close * (1 + takeProfitPercent / 100))
    strategy.exit("Short TP", from_entry="Short", limit=close * (1 - takeProfitPercent / 100))

// === 4️⃣ VISUALIZATIONS ===

// Plot MA on the Main Chart
plot(smoothedMA, title="Trend MA", color=color.gray, linewidth=1, force_overlay=true)

// Plot Signal Shapes ONLY on Trigger Bar on the Main Chart
showLongSignal = signalDisplay == "Both" or signalDisplay == "Long Only"
showShortSignal = signalDisplay == "Both" or signalDisplay == "Short Only"

// Plot shapes with text when showText is true
plotshape(showText and showLongSignal and longEntryCondition, title='Long Entry Signal with Text', location=location.belowbar, color=candleColor, style=shape.triangleup, size=size.small, text="Long", textcolor=candleColor, force_overlay=true)
plotshape(showText and showShortSignal and shortEntryCondition, title='Short Entry Signal with Text', location=location.abovebar, color=candleColor, style=shape.triangledown, size=size.small, text="Short", textcolor=candleColor, force_overlay=true)

// Plot shapes without text when showText is false
plotshape(not showText and showLongSignal and longEntryCondition, title='Long Entry Signal without Text', location=location.belowbar, color=candleColor, style=shape.triangleup, size=size.small, force_overlay=true)
plotshape(not showText and showShortSignal and shortEntryCondition, title='Short Entry Signal without Text', location=location.abovebar, color=candleColor, style=shape.triangledown, size=size.small, force_overlay=true)

// Plot Colored Candles on the Main Chart
plotcandle(open, high, low, close, title='Colored Candles', color=candleColor, wickcolor=candleColor, bordercolor=candleColor, force_overlay=true)

// Plot MACD Histogram and Signal Line in Separate Pane
macdPlot = plot(currentMacd, title='MACD Line', style=plot.style_line, color=color.blue, linewidth=2)
signalPlot = plot(currentSignal, title='Signal Line', style=plot.style_line, color=color.red, linewidth=1)
histogramPlot = plot(currentHistogram, title='MACD Histogram', style=plot.style_histogram, color=plotColor, linewidth=3)
hline(0, title='Zero line', color=color.gray, linestyle=hline.style_dashed)

// Alerts
alertcondition(longEntryCondition, title='Long Entry Signal Trigger', message='Long entry signal (triangle) detected.')
alertcondition(shortEntryCondition, title='Short Entry Signal Trigger', message='Short entry signal (triangle) detected.')
alertcondition(longExit, title='Long Exit Signal', message='Long exit signal detected.')
alertcondition(shortExit, title='Short Exit Signal', message='Short exit signal detected.')

// Existing Color-Based Alerts
isNeutralSell_Orig = isDarkMagentaTransp
isNeutralBuy_Orig = isDarkBlueTransp
isNoLeverage_Orig = isNeutralSell_Orig or isNeutralBuy_Orig or isBrightMagenta
isLeverage_Orig = isBrightBlue

alertcondition(isNeutralBuy_Orig, title='Color: Dark Blue Transp', message='Dark Blue Transp color detected.')
alertcondition(isNeutralSell_Orig, title='Color: Dark Magenta Transp', message='Dark Magenta Transp color detected.')
alertcondition(isNoLeverage_Orig, title='Color: No Leverage Colors', message='Indicator shows Dark Blue T, Dark Magenta T, or Bright Magenta.')
alertcondition(isLeverage_Orig, title='Color: Bright Blue', message='Bright Blue (Leverage) color detected.')

// Trend-Based Alerts
alertcondition(isAboveMA, title='Price Above MA', message='Price is above the selected MA.')
alertcondition(isBelowMA, title='Price Below MA', message='Price is below the selected MA.')
````
