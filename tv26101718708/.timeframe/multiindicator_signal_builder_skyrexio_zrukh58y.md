# Multi-indicator Signal Builder [Skyrexio]

- url: https://www.tradingview.com/script/ZruKH58y-Multi-indicator-Signal-Builder-Skyrexio/
- type: indicator
- pine_id: PUB;20064ab66135461db5a074bdf388d152
- version: 1.0

## Description

[b]Overview[/b]
[list][*][b]Multi-Indicator Signal Builder[/b] is a versatile, [b]all-in-one[/b] script designed to streamline your trading workflow by combining multiple popular technical indicators under a single roof. 
[*]It features a [b]single-entry, single-exit logic, intrabar stop-loss/take-profit[/b] handling, an optional time filter, a visually accessible condition table, and a built-in statistics label.
[*]Traders can choose any combination of [b]12+ indicators[/b] (RSI, Ultimate Oscillator, Bollinger %B, Moving Averages, ADX, Stochastic, MACD, PSAR, MFI, CCI, Heikin Ashi, and a “TV Screener” placeholder) to form entry or exit conditions. 
[*]This [b]script aims to simplify strategy creation and analysis[/b], making it a powerful toolkit for technical traders.[/list]
[b]Indicators Overview[/b]
[list=1][*][b]RSI (Relative Strength Index)[/b]
Measures recent price changes to evaluate overbought or oversold conditions on a 0–100 scale.
[*][b]Ultimate Oscillator (UO)[/b]
Uses weighted averages of three different timeframes, aiming to confirm price momentum while avoiding false divergences.
[*][b]Bollinger %B[/b]
Expresses price relative to Bollinger Bands, indicating whether price is near the upper band (overbought) or lower band (oversold).
[*][b]Moving Average (MA)[/b]
Smooths price data over a specified period. The script supports both SMA and EMA to help identify trend direction and potential crossovers.
[*][b]ADX (Average Directional Index)[/b]
Gauges the strength of a trend (0–100). Higher ADX signals stronger momentum, while lower ADX indicates a weaker trend.
[*][b]Stochastic[/b]
Compares a closing price to a price range over a given period to identify momentum shifts and potential reversals.
[*][b]MACD (Moving Average Convergence/Divergence)[/b]
Tracks the difference between two EMAs plus a signal line, commonly used to spot momentum flips through crossovers.
[*][b]PSAR (Parabolic SAR)[/b]
Plots a trailing stop-and-reverse dot that moves with the trend. Often used to signal potential reversals when price crosses PSAR.
[*][b]MFI (Money Flow Index)[/b]
Similar to RSI but incorporates volume data. A reading above 80 can suggest overbought conditions, while below 20 may indicate oversold.
[*][b]CCI (Commodity Channel Index)[/b]
Identifies cyclical trends or overbought/oversold levels by comparing current price to an average price over a set timeframe.
[*][b]Heikin Ashi[/b]
A type of candlestick charting that filters out market noise. The script uses a streak-based approach (multiple consecutive bullish or bearish bars) to gauge mini-trends.
[*][b]TV Screener[/b]
A placeholder condition designed to integrate external buy/sell logic (like a TradingView “Buy” or “Sell” rating). Users can override or reference external signals if desired.[/list]
[b]Unique Features[/b]
[list=1][*][b]Multi-Indicator Entry and Exit[/b]
You can selectively enable any subset of 12+ classic indicators, each with customizable parameters and conditions. A position opens only if all enabled entry conditions are met, and it closes only when all enabled exit conditions are satisfied, helping reduce false triggers.
[*][b]Single-Entry / Single-Exit with Intrabar SL/TP[/b]
The script supports a single position at a time. Once a position is open, it monitors intrabar to see if the price hits your stop-loss or take-profit levels before the bar closes, making results more realistic for fast-moving markets.
[*][b]Time Window Filter[/b]
Users may specify a start/end date range during which trades are allowed, making it convenient to focus on specific market cycles for backtesting or live trading.
[*][b]Condition Table and Statistics[/b]
A table at the bottom of the chart lists all active entry/exit indicators. Upon each closed trade, an integrated statistics label displays net profit, total trades, win/loss count, average and median PnL, etc.
[*][b]Seamless Alerts and Automation[/b]
• Configure alerts in TradingView using “Any alert() function call.”
• The script sends JSON alert messages you can route to your own webhook.
• The indicator can be integrated with Skyrexio alert bots to automate execution on major cryptocurrency exchanges.
[*][b]Optional MA/PSAR Plots[/b]
For added visual clarity, optionally plot the chosen moving averages or PSAR on the chart to confirm signals without stacking multiple indicators.[/list]
[b]Methodology[/b]
[list=1][*][b]Multi-Indicator Entry Logic[/b]
When multiple entry indicators are enabled (e.g., RSI + Stochastic + MACD), the script requires all signals to align before generating an entry. Each indicator can be set for crossovers, crossunders, thresholds (above/below), etc. This “AND” logic aims to filter out low-confidence triggers.
[*][b]Single-Entry Intrabar SL/TP[/b]
• [b]One Position At a Time:[/b] Once an entry signal triggers, a trade opens at the bar’s close.
• [b]Intrabar Checks:[/b] Stop-loss and take-profit levels (if enabled) are monitored on every tick. If either is reached, the position closes immediately, without waiting for the bar to end.
[*][b]Exit Logic[/b]
[b]All Conditions Must Agree:[/b] If the trade is still open (SL/TP not triggered), then all enabled exit indicators must confirm a closure before the script exits on the bar’s close.
[*][b]Time Filter[/b]
[b]Optional Trading Window:[/b] You can activate a date/time range to constrain entries and exits strictly to that interval.[/list]
[b]Justification of Methodology[/b]
[list][*][b]Indicator Confluence:[/b] Combining multiple tools (RSI, MACD, etc.) can reduce noise and false signals.
[*][b]Intrabar SL/TP:[/b] Capturing real-time spikes or dips provides a more precise reflection of typical live trading scenarios.
[*][b]Single-Entry Model:[/b] Straightforward for both manual and automated tracking (especially important in bridging to bots).
[*][b]Custom Date Range:[/b] Helps refine backtesting for specific market conditions or to avoid known irregular data periods.[/list]
[b]How to Use[/b]
[list=1][*][b]Add the Script to Your Chart[/b]
• In TradingView, open [b]Indicators[/b], search for [b]“Multi-indicator Signal Builder”[/b].
• Click to add it to your chart.
[*][b]Configure Inputs[/b]
• [b]Time Filter:[/b] Set a start and end date for trades.
• [b]Alerts Messages:[/b] Input any JSON or text payload needed by your external service or bot.
• [b]Entry Conditions:[/b] Enable and configure any indicators (e.g., RSI, MACD) for a confluence-based entry.
• [b]Close Conditions:[/b] Enable exit indicators, along with optional SL (negative %) and TP (positive %) levels.
[*][b]Set Up Alerts[/b]
• In TradingView, select “Create Alert” → Condition = “Any alert() function call” → choose this script.
• [b]Entry Alert:[/b] Triggers on the script’s entry signal.
• [b]Close Alert:[/b] Triggers on the script’s close signal (or if SL/TP is hit).
• [b]Skyrexio Alert Bots:[/b] You can route these alerts via webhook to Skyrexio alert bots to automate order execution on major crypto exchanges (or any other supported broker).
[*][b]Visual Reference[/b]
• A condition table at the bottom summarizes active signals.
• Statistics Label updates automatically as trades are closed, showing PnL stats and distribution metrics.[/list]
[b]Backtesting Guidelines[/b]
[list][*][b]Symbol/Timeframe:[/b] Works on multiple assets and timeframes; always do thorough testing.
[*][b]Realistic Costs:[/b] Adjust commissions and potential slippage to match typical exchange conditions.
[*][b]Risk Management:[/b] If using the built-in stop-loss/take-profit, set percentages that reflect your personal risk tolerance.
[*][b]Longer Test Horizons:[/b] Verify performance across diverse market cycles to gauge reliability.[/list]
[b]Example of statistic calculation[/b]
[list][*][b]Test Period:[/b] 2023-01-01 to 2025-12-31
[*][b]Initial Capital:[/b] $1,000
[*][b]Commission: [/b]0.1%, Slippage ~5 ticks
[*][b]Trade Count:[/b] 680 (varies by strategy conditions)
[*][b]Win rate: 75.44%[/b] (varies by strategy conditions)
[*][b]Net Profit:[/b] +90.14% (varies by strategy conditions)[/list]
[b]Disclaimer[/b]
[list][*]This indicator is provided strictly for informational and educational purposes.
[*]It does not constitute financial or trading advice.
[*]Past performance never guarantees future results.
[*]Always test thoroughly in demo environments before using real capital.[/list]
Enjoy exploring the Multi-Indicator Signal Builder! Experiment with different indicator combinations and adjust parameters to align with your trading preferences, whether you trade manually or link your alerts to external automation services. Happy trading and stay safe!

## Source Code

````pine
//@version=6
//  -----------------------------------------------------------------------------
//  Copyright © 2025 Skyrexio. All rights reserved.
//  -----------------------------------------------------------------------------
//
//  Title:    Signal Builder [Skyrexio]
//  Version:  v1.2
//  Release:  January 31, 2025
//
//  This script merges:
//    • The multi-indicator approach of the old Signal Builder (12+ indicators).
//    • A single-entry/single-exit logic (with intrabar SL/TP) + stats.
//    • A time window filter.
//    • A summary table of Entry & Close conditions.
//    • A final combined stats label showing trade performance.
//
//  Usage:
//    1) Under "🗓 Time Filter," specify start/end date to restrict trades.
//    2) Under "🎛️ ENTRY CONDITIONS," enable and configure any subset of indicators for entry.
//       If multiple are enabled, **all** must be true to trigger an entry.
//       We only look for entry signals if NOT in a trade (single-entry).
//       At least 1 entry condition is needed for any entry.
//    3) Under "🏁 CLOSE CONDITIONS," configure optional Stop-Loss & Take-Profit, plus checkboxes
//       for each indicator to close a position. We only look for close signals if ALREADY in a trade.
//    4) Create two TradingView alerts referencing this script. For the "Condition," choose either
//       "Entry Alert" or "Close Alert." and direct it to your webhook address
//    5) The script draws a condition table (bottom-center), trade markers, and a **single** stats label.
//
//  Disclaimer:
//    Use at your own risk. Past performance is not necessarily indicative of future results.
//
//  -----------------------------------------------------------------------------

indicator(
 title            = "Multi-indicator Signal Builder [Skyrexio]",
 shorttitle       = "Signal Builder [Skyrexio]",
 overlay          = true,
 max_labels_count = 500,
 max_bars_back    = 500
 )

// ──────────────────────────────────────────────────────────────────────────
// (1) TIME FILTER (Start/End Date)
// ──────────────────────────────────────────────────────────────────────────
timeGroup       = "🗓 Time Filter"
startDate       = input.time(
 title   = "Start Date/Time",
 defval  = timestamp("2023-01-01T00:00:00"),
 group   = timeGroup
 )
endDate         = input.time(
 title   = "End Date/Time",
 defval  = timestamp("2030-01-01T00:00:00"),
 group   = timeGroup
 )
inTimeWindow    = (time >= startDate and time <= endDate)

// ──────────────────────────────────────────────────────────────────────────
// SINGLE-ENTRY TRADE STATE
// ──────────────────────────────────────────────────────────────────────────
var bool inTrade           = false
var float entryPrice       = na
var float exitPrice        = na
var float stopLossPrice2   = na
var float takeProfitPrice2 = na
var bool  slTriggered      = false
var bool  tpTriggered      = false
var int   barsInTrade      = 0

// For TV Screener triggers (Buy/Sell)
var string tvTrigBuy  = "Buy"
var string tvTrigSell = "Sell"

// ──────────────────────────────────────────────────────────────────────────
// (2) ENTRY CONDITIONS
// ──────────────────────────────────────────────────────────────────────────
entryGroup = "🎛️ ENTRY CONDITIONS"

// -- RSI (Entry) --
rsiEnableEntry   = input.bool(true,  "🔸 Enable RSI (Relative Strength Index) (Entry)?", group=entryGroup, display = display.none)
rsiCondEntry     = input.string("Crossover", "RSI Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
rsiLevelEntry    = input.float(70,  "RSI Level", group=entryGroup, display = display.none)
rsiLenE          = input.int(7,     "RSI Length", group=entryGroup, display = display.none)
rsiTfE           = input.timeframe("", "RSI Timeframe Override", group=entryGroup, display = display.none)

// -- Ultimate Oscillator (Entry) --
uoEnableEntry    = input.bool(false, "🔸 Enable Ultimate Oscillator (UO) (Entry)?", group=entryGroup, display = display.none)
uoCondEntry      = input.string("Crossunder", "UO Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
uoLvlEntry       = input.float(50,  "UO Level", group=entryGroup, display = display.none)
uoFastLenE       = input.int(7,     "UO FastLen", group=entryGroup, display = display.none)
uoMidLenE        = input.int(14,    "UO MidLen",  group=entryGroup, display = display.none)
uoSlowLenE       = input.int(28,    "UO SlowLen", group=entryGroup, display = display.none)
uoTfE            = input.timeframe("", "UO Timeframe Override", group=entryGroup, display = display.none)

// -- Bollinger %B (Entry) --
bbEnableEntry    = input.bool(false, "🔸 Enable Bollinger %B? (Entry)", group=entryGroup, display = display.none)
bbCondEntry      = input.string("Crossunder", "Bollinger %B Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
bbLvlEntry       = input.float(0.5,  "%B Level", group=entryGroup, display = display.none)
bbLenE           = input.int(20,     "BB Length", group=entryGroup, display = display.none)
bbMultE          = input.float(2.0,  "BB Deviation", group=entryGroup, display = display.none)
bbTfE            = input.timeframe("", "BB Timeframe Override", group=entryGroup, display = display.none)

// -- Moving Average (Entry) --
maEnableEntry    = input.bool(false, "🔸 Enable Moving Average (MA) (Entry)?", group=entryGroup, display = display.none)
maCondEntry      = input.string("Fast Above Slow", "MA Condition", options=["Fast Crossover Slow","Fast Crossunder Slow","Fast Above Slow","Fast Below Slow"], group=entryGroup, display = display.none)
maFastLenE       = input.int(9,  "MA FastLen", group=entryGroup, display = display.none)
maSlowLenE       = input.int(26, "MA SlowLen", group=entryGroup, display = display.none)
maTypeE          = input.string("EMA", "MA Type", options=["SMA","EMA"], group=entryGroup, display = display.none)
maTfE            = input.timeframe("", "MA Timeframe Override", group=entryGroup, display = display.none)
maPlotEnable     = input.bool(false, "Plot MA (Fast/Slow)?", group=entryGroup, display = display.none)

// -- ADX (Entry) --
adxEnableEntry   = input.bool(false, "🔸 Enable ADX (Entry)?", group=entryGroup, display = display.none)
adxCondEntry     = input.string("Crossover", "ADX Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
adxLvlEntry      = input.float(25, "ADX Level", group=entryGroup, display = display.none)
adxLenE          = input.int(14,  "ADX Length", group=entryGroup, display = display.none)
adxTfE           = input.timeframe("", "ADX Timeframe Override", group=entryGroup, display = display.none)

// -- Stochastic (Entry) --
stochEnableEntry1 = input.bool(false, "🔸 Enable Stochastic K vs Lvl (Entry)?", group=entryGroup, display = display.none)
stochCond1E        = input.string("Below", "Stoch K vs Lvl Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
stochLvl1E         = input.float(20, "K Level #1", group=entryGroup, display = display.none)
stochEnableEntry2  = input.bool(false, "🔸 Enable Stochastic K vs D (Entry)?", group=entryGroup, display = display.none)
stochCond2E        = input.string("K Crossover D", "Stoch K vs D Condition", options=["K Crossover D","K Crossunder D"], group=entryGroup, display = display.none)
stLenKE            = input.int(14,  "Stoch K Length", group=entryGroup, display = display.none)
stDLenE            = input.int(3,   "Stoch D Length", group=entryGroup, display = display.none)
stTfE              = input.timeframe("", "Stoch Timeframe Override", group=entryGroup, display = display.none)

// -- MACD (Entry) --
macdEnableEntry1 = input.bool(false, "🔸 Enable MACD 0 line signal (Entry)?", group=entryGroup, display = display.none)
macdCond1E       = input.string("MACD Above 0", "MACD 0 line signal", options=["MACD Above 0","MACD Below 0"], group=entryGroup, display = display.none)
macdEnableEntry2 = input.bool(false, "🔸 Enable MACD cross signal?", group=entryGroup, display = display.none)
macdCond2E       = input.string("MACD Crossover Signal", "MACD cross signal", options=["MACD Crossover Signal","MACD Crossunder Signal"], group=entryGroup, display = display.none)
macdFastLenE     = input.int(12, "MACD FastLen",   group=entryGroup, display = display.none)
macdSlowLenE     = input.int(26, "MACD SlowLen",   group=entryGroup, display = display.none)
macdSigLenE      = input.int(9,  "MACD SignalLen", group=entryGroup, display = display.none)
macdTfE          = input.timeframe("", "MACD Timeframe Override", group=entryGroup, display = display.none)

// -- PSAR (Entry) --
psarEnableEntry  = input.bool(false, "🔸 Enable Parabolic SAR (PSAR) (Entry)?", group=entryGroup, display = display.none)
psarStartE       = input.float(0.02, "PSAR Start",     group=entryGroup, display = display.none)
psarIncE         = input.float(0.02, "PSAR Increment", group=entryGroup, display = display.none)
psarMaxE         = input.float(0.2,  "PSAR Max",       group=entryGroup, display = display.none)
psarCondEntry    = input.string("Above", "PSAR Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
psarTfE          = input.timeframe("", "PSAR Timeframe Override", group=entryGroup, display = display.none)
psarPlotEnable   = input.bool(false, "Plot PSAR?", group=entryGroup, display = display.none)

// -- MFI (Entry) --
mfiEnableEntry   = input.bool(false, "🔸 Enable Money Flow Index (MFI) (Entry)?", group=entryGroup, display = display.none)
mfiCondEntry     = input.string("Crossunder", "MFI Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
mfiLvlEntry      = input.float(20, "MFI Level", group=entryGroup, display = display.none)
mfiLenE          = input.int(14,  "MFI Length", group=entryGroup, display = display.none)
mfiTfE           = input.timeframe("", "MFI Timeframe Override", group=entryGroup, display = display.none)

// -- CCI (Entry) --
cciEnableEntry   = input.bool(false, "🔸 Enable Commodity Channel Index (CCI) (Entry)?", group=entryGroup, display = display.none)
cciCondEntry     = input.string("Crossunder", "CCI Condition", options=["Crossover","Crossunder","Above","Below"], group=entryGroup, display = display.none)
cciLvlEntry      = input.float(-100, "CCI Level", group=entryGroup, display = display.none)
cciLenE          = input.int(20,     "CCI Length", group=entryGroup, display = display.none)
cciTfE           = input.timeframe("", "CCI Timeframe Override", group=entryGroup, display = display.none)

// -- Heikin Ashi (Entry) --
haEnableEntry    = input.bool(false, "🔸 Enable Heikin Ashi Streak (Entry)?", group=entryGroup, display = display.none)
haBullBarsEntry  = input.int(2, "Streak of Bull Bars", group=entryGroup, display = display.none)
haBearBarsEntry  = input.int(2, "Streak of Bear Bars", group=entryGroup, display = display.none)
haTrendEntry     = input.string("Bullish", "Heikin Ashi Trend", options=["Bullish","Bearish"], group=entryGroup, display = display.none)

// -- TV Screener (Entry) --
tvEnableEntry2   = input.bool(false, "🔸 Enable TradingView Screener (Entry)?", group=entryGroup, display = display.none)
tvCondEntry      = input.string("Buy", "TV Screener Condition", options=["Buy","Sell","Strong Buy","Strong Sell"], group=entryGroup, display = display.none)

// ──────────────────────────────────────────────────────────────────────────
// (3) CLOSE CONDITIONS
// ──────────────────────────────────────────────────────────────────────────
closeGroup = "🏁 CLOSE CONDITIONS"

// Take Profit & Stop Loss
takeProfitPerc  = input.float(0.0, "💰 Take Profit (+%) (0=disabled)", group=closeGroup, minval=0.0, display = display.none)
stopLossPerc    = input.float(0.0, "🛑 Stop Loss (-%) (0=disabled)",   group=closeGroup, maxval=0.0, display = display.none)

// -- RSI (Close) --
rsiEnableClose  = input.bool(false, "🔸 Enable RSI (Relative Strength Index) (Close)?", group=closeGroup, display = display.none)
rsiCondClose    = input.string("Crossunder", "RSI Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
rsiLevelClose   = input.float(80,  "RSI Level", group=closeGroup, display = display.none)
rsiLenC         = input.int(7,     "RSI Length", group=closeGroup, display = display.none)
rsiTfC          = input.timeframe("", "RSI Timeframe Override", group=closeGroup, display = display.none)

// -- UO (Close) --
uoEnableClose   = input.bool(false, "🔸 Enable Ultimate Oscillator (UO) (Close)?", group=closeGroup, display = display.none)
uoCondClose     = input.string("Crossover", "UO Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
uoLvlClose      = input.float(50,  "UO Level", group=closeGroup, display = display.none)
uoFastLenC      = input.int(7,     "UO FastLen", group=closeGroup, display = display.none)
uoMidLenC       = input.int(14,    "UO MidLen",  group=closeGroup, display = display.none)
uoSlowLenC      = input.int(28,    "UO SlowLen", group=closeGroup, display = display.none)
uoTfC           = input.timeframe("", "UO Timeframe Override", group=closeGroup, display = display.none)

// -- Bollinger %B (Close) --
bbEnableClose   = input.bool(false, "🔸 Enable Bollinger %B (Close)?", group=closeGroup, display = display.none)
bbCondClose     = input.string("Crossover", "%B Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
bbLvlClose      = input.float(1.0,  "%B Level", group=closeGroup, display = display.none)
bbLenC          = input.int(20,     "BB Length", group=closeGroup, display = display.none)
bbMultC         = input.float(2.0,  "BB Deviation", group=closeGroup, display = display.none)
bbTfC           = input.timeframe("", "BB Timeframe Override", group=closeGroup, display = display.none)

// -- MA (Close) --
maEnableClose   = input.bool(false, "🔸 Enable MA (Close)?", group=closeGroup, display = display.none)
maCondClose     = input.string("Fast Crossunder Slow", "MA Condition", options=["Fast Crossover Slow","Fast Crossunder Slow","Fast Above Slow","Fast Below Slow"], group=closeGroup, display = display.none)
maFastLenC      = input.int(9,  "MA FastLen", group=closeGroup, display = display.none)
maSlowLenC      = input.int(26, "MA SlowLen", group=closeGroup, display = display.none)
maTypeC         = input.string("EMA", "MA Type", options=["SMA","EMA"], group=closeGroup, display = display.none)
maTfC           = input.timeframe("", "MA Timeframe Override", group=closeGroup, display = display.none)

// -- ADX (Close) --
adxEnableClose  = input.bool(false, "🔸 Enable ADX (Close)?", group=closeGroup, display = display.none)
adxCondClose    = input.string("Crossunder", "ADX Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
adxLvlClose     = input.float(25, "ADX Level", group=closeGroup, display = display.none)
adxLenC         = input.int(14,  "ADX Length", group=closeGroup, display = display.none)
adxTfC          = input.timeframe("", "ADX Timeframe Override", group=closeGroup, display = display.none)

// -- Stochastic (Close) --
stochEnableClose1 = input.bool(false, "🔸 Enable Stochastic K vs Lvl (Close)?", group=closeGroup, display = display.none)
stochCond1C        = input.string("Above", "Stoch K vs Lvl Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
stochLvl1C         = input.float(80, "K Level #1", group=closeGroup, display = display.none)
stochEnableClose2  = input.bool(false, "🔸 Enable Stochastic K vs D (Close)?", group=closeGroup, display = display.none)
stochCond2C        = input.string("K Crossunder D", "Stoch K vs D Condition", options=["K Crossover D","K Crossunder D"], group=closeGroup, display = display.none)
stLenKC            = input.int(14,  "Stoch K Length", group=closeGroup, display = display.none)
stDLenC            = input.int(3,   "Stoch D Length", group=closeGroup, display = display.none)
stTfC              = input.timeframe("", "Stoch Timeframe Override", group=closeGroup, display = display.none)

// -- MACD (Close) --
macdEnableClose1= input.bool(false, "🔸 Enable MACD 0 line signal (Close)?", group=closeGroup, display = display.none)
macdCond1C      = input.string("MACD Above 0", "MACD 0 line signal", options=["MACD Above 0","MACD Below 0"], group=closeGroup, display = display.none)
macdEnableClose2= input.bool(false, "🔸 Enable MACD cross signal (Close)?", group=closeGroup, display = display.none)
macdCond2C      = input.string("MACD Crossunder Signal", "MACD cross signal", options=["MACD Crossover Signal","MACD Crossunder Signal"], group=closeGroup, display = display.none)
macdFastLenC    = input.int(12, "MACD FastLen",   group=closeGroup, display = display.none)
macdSlowLenC    = input.int(26, "MACD SlowLen",   group=closeGroup, display = display.none)
macdSigLenC     = input.int(9,  "MACD SignalLen", group=closeGroup, display = display.none)
macdTfC         = input.timeframe("", "MACD Timeframe Override", group=closeGroup, display = display.none)

// -- PSAR (Close) --
psarEnableClose = input.bool(false, "🔸 Enable PSAR (Close)?", group=closeGroup, display = display.none)
psarStartC      = input.float(0.02, "PSAR Start",     group=closeGroup, display = display.none)
psarIncC        = input.float(0.02, "PSAR Increment", group=closeGroup, display = display.none)
psarMaxC        = input.float(0.2,  "PSAR Max",       group=closeGroup, display = display.none)
psarCondClose   = input.string("Crossunder", "PSAR Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
psarTfC         = input.timeframe("", "PSAR Timeframe Override", group=closeGroup, display = display.none)

// -- MFI (Close) --
mfiEnableClose  = input.bool(false, "🔸 Enable MFI (Close)?", group=closeGroup, display = display.none)
mfiCondClose    = input.string("Crossover", "MFI Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
mfiLvlClose     = input.float(80,  "MFI Level", group=closeGroup, display = display.none)
mfiLenC         = input.int(14,   "MFI Length", group=closeGroup, display = display.none)
mfiTfC          = input.timeframe("", "MFI Timeframe Override", group=closeGroup, display = display.none)

// -- CCI (Close) --
cciEnableClose  = input.bool(false, "🔸 Enable CCI (Close)?", group=closeGroup, display = display.none)
cciCondClose    = input.string("Crossover", "CCI Condition", options=["Crossover","Crossunder","Above","Below"], group=closeGroup, display = display.none)
cciLvlClose     = input.float(100, "CCI Level", group=closeGroup, display = display.none)
cciLenC         = input.int(20,    "CCI Length", group=closeGroup, display = display.none)
cciTfC          = input.timeframe("", "CCI Timeframe Override", group=closeGroup, display = display.none)

// -- Heikin Ashi (Close) --
haEnableClose   = input.bool(false, "🔸 Enable Heikin Ashi Streak (Close)?", group=closeGroup, display = display.none)
haBullBarsClose = input.int(2, "Streak of Bull Bars (Close)", group=closeGroup, display = display.none)
haBearBarsClose = input.int(2, "Streak of Bear Bars (Close)", group=closeGroup, display = display.none)
haTrendClose    = input.string("Bearish", "Heikin Ashi Trend (Close)", options=["Bullish","Bearish"], group=closeGroup, display = display.none)

// -- TV Screener (Close) --
tvEnableClose2  = input.bool(false, "🔸 Enable TV Screener (Close)?", group=closeGroup, display = display.none)
tvCondClose     = input.string("Sell", "TV Screener Condition", options=["Buy","Sell","Strong Buy","Strong Sell"], group=closeGroup, display = display.none)

// ──────────────────────────────────────────────────────────────────────────
// ARRAYS & HELPER FUNCTIONS for Condition Table
// ──────────────────────────────────────────────────────────────────────────
var string[] entryTableArr = array.new_string()
var string[] closeTableArr = array.new_string()

// Rebuild the textual lists on each new bar (so the table updates if inputs change)
if barstate.isnew
    array.clear(entryTableArr)
    array.clear(closeTableArr)

    // Build the list of enabled entry indicators
    if rsiEnableEntry
        array.push(entryTableArr, "RSI " + rsiCondEntry + " " + str.tostring(rsiLevelEntry))
    if uoEnableEntry
        array.push(entryTableArr, "UO " + uoCondEntry + " " + str.tostring(uoLvlEntry))
    if bbEnableEntry
        array.push(entryTableArr, "%B " + bbCondEntry + " " + str.tostring(bbLvlEntry))
    if maEnableEntry
        array.push(entryTableArr, "MA " + maCondEntry)
    if adxEnableEntry
        array.push(entryTableArr, "ADX " + adxCondEntry + " " + str.tostring(adxLvlEntry))

    // Stochastic #1 and #2 for Entry
    if stochEnableEntry1
        array.push(entryTableArr, "Stoch #1(K " + stochCond1E + " " + str.tostring(stochLvl1E) + ")")
    if stochEnableEntry2
        array.push(entryTableArr, "Stoch #2(K " + stochCond2E + " D)")

    if macdEnableEntry1
        array.push(entryTableArr, "MACD 1 (" + macdCond1E + ")")
    if macdEnableEntry2
        array.push(entryTableArr, "MACD 2 (" + macdCond2E + ")")
    if psarEnableEntry
        array.push(entryTableArr, "PSAR " + psarCondEntry)
    if mfiEnableEntry
        array.push(entryTableArr, "MFI " + mfiCondEntry + " " + str.tostring(mfiLvlEntry))
    if cciEnableEntry
        array.push(entryTableArr, "CCI " + cciCondEntry + " " + str.tostring(cciLvlEntry))
    if haEnableEntry
        array.push(entryTableArr, "Heikin Ashi Streak(Entry)")
    if tvEnableEntry2
        array.push(entryTableArr, "TV Screener " + tvCondEntry)

    // Build the list of enabled close indicators
    if rsiEnableClose
        array.push(closeTableArr, "RSI " + rsiCondClose + " " + str.tostring(rsiLevelClose))
    if uoEnableClose
        array.push(closeTableArr, "UO " + uoCondClose + " " + str.tostring(uoLvlClose))
    if bbEnableClose
        array.push(closeTableArr, "%B " + bbCondClose + " " + str.tostring(bbLvlClose))
    if maEnableClose
        array.push(closeTableArr, "MA " + maCondClose)
    if adxEnableClose
        array.push(closeTableArr, "ADX " + adxCondClose + " " + str.tostring(adxLvlClose))

    // Stochastic #1 and #2 for Close
    if stochEnableClose1
        array.push(closeTableArr, "Stoch #1(K " + stochCond1C + " " + str.tostring(stochLvl1C) + ")")
    if stochEnableClose2
        array.push(closeTableArr, "Stoch #2(K " + stochCond2C + " D)")

    if macdEnableClose1
        array.push(closeTableArr, "MACD 1(" + macdCond1C + ")")
    if macdEnableClose2
        array.push(closeTableArr, "MACD 2(" + macdCond2C + ")")
    if psarEnableClose
        array.push(closeTableArr, "PSAR " + psarCondClose)
    if mfiEnableClose
        array.push(closeTableArr, "MFI " + mfiCondClose + " " + str.tostring(mfiLvlClose))
    if cciEnableClose
        array.push(closeTableArr, "CCI " + cciCondClose + " " + str.tostring(cciLvlClose))
    if haEnableClose
        array.push(closeTableArr, "Heikin Ashi Streak(Close)")
    if tvEnableClose2
        array.push(closeTableArr, "TV Screener " + tvCondClose)

    // If user set SL or TP, add them to the close table text
    if stopLossPerc < 0
        array.push(closeTableArr, "Stop Loss " + str.tostring(stopLossPerc, format.mintick) + "%")
    if takeProfitPerc > 0
        array.push(closeTableArr, "Take Profit " + str.tostring(takeProfitPerc, format.mintick) + "%")

// For each bar, store booleans in arrays to decide if “all conditions are true”.
var bool[] entryLogicArr = array.new_bool()
var bool[] closeLogicArr = array.new_bool()

if barstate.isnew
    array.clear(entryLogicArr)
    array.clear(closeLogicArr)

f_pushEntrySignal(signalValue) =>
    if not inTrade
        array.push(entryLogicArr, signalValue)

f_pushCloseSignal(signalValue) =>
    if inTrade
        array.push(closeLogicArr, signalValue)

f_allTrueSignals(sigArray) =>
    array.size(sigArray) > 0 and array.includes(sigArray, true) and not array.includes(sigArray, false)

// ──────────────────────────────────────────────────────────────────────────
// INDICATOR-SPECIFIC HELPER FUNCTIONS
// ──────────────────────────────────────────────────────────────────────────
f_checkOscSingle(_val, _cond, _lvl) =>
    switch _cond
        "Crossover"  => ta.crossover(_val, _lvl)
        "Crossunder" => ta.crossunder(_val, _lvl)
        "Above"      => _val > _lvl
        "Below"      => _val < _lvl
        => false

f_checkMacdCond1(_macdLine, _cond) =>
    switch _cond
        "MACD Above 0" => _macdLine > 0
        "MACD Below 0" => _macdLine < 0
        => false

f_checkMacdCond2(_macdLine, _macdSig, _cond) =>
    switch _cond
        "MACD Crossover Signal"  => ta.crossover(_macdLine, _macdSig)
        "MACD Crossunder Signal" => ta.crossunder(_macdLine, _macdSig)
        => false

// Separate checks for Stochastic
f_checkStCond1(_kVal, _cond, _lvl) =>
    f_checkOscSingle(_kVal, _cond, _lvl)

f_checkStCond2(_kVal, _dVal, _cond) =>
    switch _cond
        "K Crossover D"  => ta.crossover(_kVal, _dVal)
        "K Crossunder D" => ta.crossunder(_kVal, _dVal)
        => false

// (A) RSI
rsiValE = request.security(syminfo.tickerid, (rsiTfE == "" ? timeframe.period : rsiTfE), ta.rsi(close, rsiLenE), lookahead=barmerge.lookahead_off)
rsiValC = request.security(syminfo.tickerid, (rsiTfC == "" ? timeframe.period : rsiTfC), ta.rsi(close, rsiLenC), lookahead=barmerge.lookahead_off)

if rsiEnableEntry
    bool rsiSigE = f_checkOscSingle(rsiValE, rsiCondEntry, rsiLevelEntry)
    f_pushEntrySignal(rsiSigE)

if rsiEnableClose
    bool rsiSigC = f_checkOscSingle(rsiValC, rsiCondClose, rsiLevelClose)
    f_pushCloseSignal(rsiSigC)

// (B) UO
f_uo(_f,_m,_s) =>
    _hi2 = math.max(high, close[1])
    _lo2 = math.min(low,  close[1])
    _bp  = close - _lo2
    _tr  = _hi2 - _lo2
    sumFa= math.sum(_bp,_f) / math.sum(_tr,_f)
    sumMa= math.sum(_bp,_m) / math.sum(_tr,_m)
    sumSa= math.sum(_bp,_s) / math.sum(_tr,_s)
    100 * (4*sumFa + 2*sumMa + sumSa) / 7

uoValE = request.security(syminfo.tickerid, (uoTfE == "" ? timeframe.period : uoTfE), f_uo(uoFastLenE, uoMidLenE, uoSlowLenE), lookahead=barmerge.lookahead_off)
uoValC = request.security(syminfo.tickerid, (uoTfC == "" ? timeframe.period : uoTfC), f_uo(uoFastLenC, uoMidLenC, uoSlowLenC), lookahead=barmerge.lookahead_off)

if uoEnableEntry
    bool uoSigE = f_checkOscSingle(uoValE, uoCondEntry, uoLvlEntry)
    f_pushEntrySignal(uoSigE)

if uoEnableClose
    bool uoSigC = f_checkOscSingle(uoValC, uoCondClose, uoLvlClose)
    f_pushCloseSignal(uoSigC)

// (C) %B
f_bbperc(_l,_m) =>
    b = ta.sma(close, _l)
    d = _m * ta.stdev(close, _l)
    up= b + d
    lw= b - d
    (close - lw) / (up - lw)

bbValE = request.security(syminfo.tickerid, (bbTfE == "" ? timeframe.period : bbTfE), f_bbperc(bbLenE, bbMultE), lookahead=barmerge.lookahead_off)
bbValC = request.security(syminfo.tickerid, (bbTfC == "" ? timeframe.period : bbTfC), f_bbperc(bbLenC, bbMultC), lookahead=barmerge.lookahead_off)

if bbEnableEntry
    bool bbSigE = f_checkOscSingle(bbValE, bbCondEntry, bbLvlEntry)
    f_pushEntrySignal(bbSigE)

if bbEnableClose
    bool bbSigC = f_checkOscSingle(bbValC, bbCondClose, bbLvlClose)
    f_pushCloseSignal(bbSigC)

// (D) MA
f_ma(_src,_len,_type) =>
    _type == "SMA" ? ta.sma(_src,_len) : ta.ema(_src,_len)

f_checkMA(_fast,_slow,_c) =>
    switch _c
        "Fast Crossover Slow"  => ta.crossover(_fast, _slow)
        "Fast Crossunder Slow" => ta.crossunder(_fast, _slow)
        "Fast Above Slow"      => (_fast > _slow)
        "Fast Below Slow"      => (_fast < _slow)
        => false

maFastE = request.security(syminfo.tickerid, (maTfE == "" ? timeframe.period : maTfE), f_ma(close, maFastLenE, maTypeE), lookahead=barmerge.lookahead_off)
maSlowE = request.security(syminfo.tickerid, (maTfE == "" ? timeframe.period : maTfE), f_ma(close, maSlowLenE, maTypeE), lookahead=barmerge.lookahead_off)

if maEnableEntry
    bool maSigE = f_checkMA(maFastE, maSlowE, maCondEntry)
    f_pushEntrySignal(maSigE)

maFastC = request.security(syminfo.tickerid, (maTfC == "" ? timeframe.period : maTfC), f_ma(close, maFastLenC, maTypeC), lookahead=barmerge.lookahead_off)
maSlowC = request.security(syminfo.tickerid, (maTfC == "" ? timeframe.period : maTfC), f_ma(close, maSlowLenC, maTypeC), lookahead=barmerge.lookahead_off)

if maEnableClose
    bool maSigC = f_checkMA(maFastC, maSlowC, maCondClose)
    f_pushCloseSignal(maSigC)

// Optionally plot MAs
plot(maPlotEnable ? maFastE : na, color=color.new(#2ECD99,0),   title="MA Fast", display=display.all)
plot(maPlotEnable ? maSlowE : na, color=color.new(#2ECD99,80),  title="MA Slow", display=display.all)

// (E) ADX
[_,_,adxRawE] = ta.dmi(adxLenE, adxLenE)
adxValE       = request.security(syminfo.tickerid, (adxTfE == "" ? timeframe.period : adxTfE), adxRawE, lookahead=barmerge.lookahead_off)

if adxEnableEntry
    bool adxSigE = f_checkOscSingle(adxValE, adxCondEntry, adxLvlEntry)
    f_pushEntrySignal(adxSigE)

[_,_,adxRawC] = ta.dmi(adxLenC, adxLenC)
adxValC       = request.security(syminfo.tickerid, (adxTfC == "" ? timeframe.period : adxTfC), adxRawC, lookahead=barmerge.lookahead_off)

if adxEnableClose
    bool adxSigC = f_checkOscSingle(adxValC, adxCondClose, adxLvlClose)
    f_pushCloseSignal(adxSigC)

// (F) Stochastic
f_stoch(_kLen,_dLen) =>
    _rk = ta.stoch(close, high, low, _kLen)
    _sk = ta.sma(_rk, 1)
    ta.sma(_sk, _dLen)

stE_k = request.security(syminfo.tickerid, (stTfE == "" ? timeframe.period : stTfE), f_stoch(stLenKE, stDLenE), lookahead=barmerge.lookahead_off)
stE_d = ta.sma(stE_k, 1)

// Entry: Stoch #1 / #2
if stochEnableEntry1
    bool stE1 = f_checkStCond1(stE_k, stochCond1E, stochLvl1E)
    f_pushEntrySignal(stE1)

if stochEnableEntry2
    bool stE2 = f_checkStCond2(stE_k, stE_d, stochCond2E)
    f_pushEntrySignal(stE2)

// Close: Stoch #1 / #2
stC_k = request.security(syminfo.tickerid, (stTfC == "" ? timeframe.period : stTfC), f_stoch(stLenKC, stDLenC), lookahead=barmerge.lookahead_off)
stC_d = ta.sma(stC_k, 1)

if stochEnableClose1
    bool stC1 = f_checkStCond1(stC_k, stochCond1C, stochLvl1C)
    f_pushCloseSignal(stC1)

if stochEnableClose2
    bool stC2 = f_checkStCond2(stC_k, stC_d, stochCond2C)
    f_pushCloseSignal(stC2)

// (G) MACD
[macLE, macSE, _] = ta.macd(close, macdFastLenE, macdSlowLenE, macdSigLenE)  
macdE_line        = request.security(syminfo.tickerid, (macdTfE==""?timeframe.period:macdTfE), macLE, lookahead=barmerge.lookahead_off)
macdE_sig         = request.security(syminfo.tickerid, (macdTfE==""?timeframe.period:macdTfE), macSE, lookahead=barmerge.lookahead_off)

if macdEnableEntry1
    bool macdE1 = f_checkMacdCond1(macdE_line, macdCond1E)
    f_pushEntrySignal(macdE1)
if macdEnableEntry2
    bool macdE2 = f_checkMacdCond2(macdE_line, macdE_sig, macdCond2E)
    f_pushEntrySignal(macdE2)

[macLC, macSC, _] = ta.macd(close, macdFastLenC, macdSlowLenC, macdSigLenC)
macdC_line        = request.security(syminfo.tickerid, (macdTfC==""?timeframe.period:macdTfC), macLC, lookahead=barmerge.lookahead_off)
macdC_sig         = request.security(syminfo.tickerid, (macdTfC==""?timeframe.period:macdTfC), macSC, lookahead=barmerge.lookahead_off)

if macdEnableClose1
    bool macdE1C = f_checkMacdCond1(macdC_line, macdCond1C)
    f_pushCloseSignal(macdE1C)
if macdEnableClose2
    bool macdE2C = f_checkMacdCond2(macdC_line, macdC_sig, macdCond2C)
    f_pushCloseSignal(macdE2C)

// (H) PSAR
psarE_raw = ta.sar(psarStartE, psarIncE, psarMaxE)
psarE     = request.security(syminfo.tickerid, (psarTfE==""?timeframe.period:psarTfE), psarE_raw, lookahead=barmerge.lookahead_off)

if psarEnableEntry
    bool psarEok = f_checkOscSingle(close, psarCondEntry, psarE)
    f_pushEntrySignal(psarEok)

psarC_raw = ta.sar(psarStartC, psarIncC, psarMaxC)
psarC     = request.security(syminfo.tickerid, (psarTfC==""?timeframe.period:psarTfC), psarC_raw, lookahead=barmerge.lookahead_off)

if psarEnableClose
    bool psarCok = f_checkOscSingle(close, psarCondClose, psarC)
    f_pushCloseSignal(psarCok)

// Optionally plot PSAR
plot(psarPlotEnable ? psarE : na, style=plot.style_cross, color=color.new(#2ECD99,0), title="PSAR", display=display.all)

// (I) MFI
mfiEraw = ta.mfi((high+low+close)/3, mfiLenE)
mfiEval = request.security(syminfo.tickerid, (mfiTfE==""?timeframe.period:mfiTfE), mfiEraw, lookahead=barmerge.lookahead_off)

if mfiEnableEntry
    bool mfiEok = f_checkOscSingle(mfiEval, mfiCondEntry, mfiLvlEntry)
    f_pushEntrySignal(mfiEok)

mfiCraw = ta.mfi((high+low+close)/3, mfiLenC)
mfiCval = request.security(syminfo.tickerid, (mfiTfC==""?timeframe.period:mfiTfC), mfiCraw, lookahead=barmerge.lookahead_off)

if mfiEnableClose
    bool mfiCok = f_checkOscSingle(mfiCval, mfiCondClose, mfiLvlClose)
    f_pushCloseSignal(mfiCok)

// (J) CCI
cciEraw = ta.cci(hlc3, cciLenE)
cciEval = request.security(syminfo.tickerid, (cciTfE==""?timeframe.period:cciTfE), cciEraw, lookahead=barmerge.lookahead_off)

if cciEnableEntry
    bool cciEok = f_checkOscSingle(cciEval, cciCondEntry, cciLvlEntry)
    f_pushEntrySignal(cciEok)

cciCraw = ta.cci(hlc3, cciLenC)
cciCval = request.security(syminfo.tickerid, (cciTfC==""?timeframe.period:cciTfC), cciCraw, lookahead=barmerge.lookahead_off)

if cciEnableClose
    bool cciCok = f_checkOscSingle(cciCval, cciCondClose, cciLvlClose)
    f_pushCloseSignal(cciCok)

// (K) Heikin Ashi (Entry & Close) - real HA feed
haTicker = ticker.heikinashi(syminfo.tickerid)

// For ENTRY
haCloseE = request.security(haTicker, timeframe.period, close, lookahead=barmerge.lookahead_off)
haOpenE  = request.security(haTicker, timeframe.period, open,  lookahead=barmerge.lookahead_off)
bool isBullE = haCloseE > haOpenE
bool isBearE = haCloseE < haOpenE

f_stBull(n)=>
    sumBull=0
    for i=0 to n-1
        sumBull += (isBullE[i] ? 1 : 0)
    sumBull == n

f_stBear(n)=>
    sumBear=0
    for i=0 to n-1
        sumBear += (isBearE[i] ? 1 : 0)
    sumBear == n

if haEnableEntry
    bool haEok = (haTrendEntry == "Bullish") ? f_stBull(haBullBarsEntry) : f_stBear(haBearBarsEntry)
    f_pushEntrySignal(haEok)

// For CLOSE
haCloseC = request.security(haTicker, timeframe.period, close, lookahead=barmerge.lookahead_off)
haOpenC  = request.security(haTicker, timeframe.period, open,  lookahead=barmerge.lookahead_off)
bool isBullC = haCloseC > haOpenC
bool isBearC = haCloseC < haOpenC

f_stBullC(n)=>
    c2=0
    for i=0 to n-1
        c2 += (isBullC[i] ? 1 : 0)
    c2 == n

f_stBearC(n)=>
    d2=0
    for i=0 to n-1
        d2 += (isBearC[i] ? 1 : 0)
    d2 == n

if haEnableClose
    bool haCok = (haTrendClose == "Bullish") ? f_stBullC(haBullBarsClose) : f_stBearC(haBearBarsClose)
    f_pushCloseSignal(haCok)

// (L) TV Screener
if tvEnableEntry2
    bool tvE = (tvCondEntry == tvTrigBuy)
    f_pushEntrySignal(tvE)

if tvEnableClose2
    bool tvC = (tvCondClose == tvTrigSell)
    f_pushCloseSignal(tvC)

// ──────────────────────────────────────────────────────────────────────────
// ENTRY / EXIT LOGIC + STATS
// ──────────────────────────────────────────────────────────────────────────
var float   cumulativePNLperc = 0.0
var int     closedTrades      = 0
var int     winsCount         = 0
var int     lossesCount       = 0
var float[] allPNLs           = array.new_float()
var int[]   allBars           = array.new_int()

var bool justEnt = false
var bool justEx  = false

if barstate.isnew
    justEnt := false
    justEx  := false

// Check if we have ANY entry signals
bool entrySignal = inTimeWindow 
                   and not inTrade 
                   and f_allTrueSignals(entryLogicArr)

// Check if we have close signals
bool closeSignal = inTimeWindow 
                   and inTrade 
                   and f_allTrueSignals(closeLogicArr)

// Intrabar SL/TP calculations
f_calcSLTP(_ent)=>
    float sPrice = stopLossPerc < 0 ? _ent * (1.0 + stopLossPerc / 100.0) : na
    float tPrice = takeProfitPerc > 0 ? _ent * (1.0 + takeProfitPerc / 100.0) : na
    [sPrice, tPrice]

// On new bar
if inTimeWindow
    barsInTrade := inTrade ? barsInTrade + 1 : 0

    // Intrabar check for SL/TP triggers
    if inTrade
        if not na(stopLossPrice2) and (low <= stopLossPrice2)
            slTriggered := true
        if not na(takeProfitPrice2) and (high >= takeProfitPrice2)
            tpTriggered := true

    // ENTRY or EXIT
    if not inTrade and entrySignal
        // ENTRY
        inTrade     := true
        entryPrice  := close
        exitPrice   := na
        barsInTrade := 1

        // set SL/TP
        [tmpSL, tmpTP] = f_calcSLTP(entryPrice)
        stopLossPrice2   := tmpSL
        takeProfitPrice2 := tmpTP

        justEnt := true

    else if inTrade and (closeSignal or slTriggered or tpTriggered)
        // EXIT
        inTrade   := false
        exitPrice := slTriggered ? stopLossPrice2 : tpTriggered ? takeProfitPrice2 : close
        justEx    := true

        float tradePnL = (exitPrice - entryPrice)/entryPrice * 100.
        cumulativePNLperc += tradePnL
        closedTrades += 1

        if tradePnL >= 0
            winsCount += 1
        else
            lossesCount += 1

        array.push(allPNLs, tradePnL)
        array.push(allBars, barsInTrade)

        // reset
        stopLossPrice2   := na
        takeProfitPrice2 := na
        barsInTrade      := 0

if barstate.isconfirmed
    slTriggered := false
    tpTriggered := false

// Alert conditions with default messages
alertcondition(justEnt, title="Entry Alert", message="Paste entry message JSON from your bot")
alertcondition(justEx,  title="Close Alert", message="Paste close message JSON from your bot")

// Optional chart markers for the single-entry logic
if justEnt
    label.new(
     bar_index, low, 
     "E",
     style=label.style_label_up,
     color=color.new(#056757,0),
     textcolor=color.white,
     size=size.tiny
     )
    // Reset so we don't repeatedly draw multiple labels in real-time:
    justEnt := false

if justEx
    label.new(
     bar_index, high, 
     "C",
     style=label.style_label_down,
     color=color.new(#B22932,0),
     textcolor=color.white,
     size=size.tiny
     )
    // Reset so we don't repeatedly draw multiple labels in real-time:
    justEx := false

// Draw lines for SL/TP if inTrade
plot(
 inTrade and not na(stopLossPrice2) ? stopLossPrice2 : na,
 color=color.red,
 linewidth=1,
 style=plot.style_linebr,
 title="Stop Loss"
 )
plot(
 inTrade and not na(takeProfitPrice2) ? takeProfitPrice2 : na,
 color=color.lime,
 linewidth=1,
 style=plot.style_linebr,
 title="Take Profit"
 )

// ──────────────────────────────────────────────────────────────────────────
// COMBINED STATISTICS LABEL (BACKTESTING)
// ──────────────────────────────────────────────────────────────────────────
SHOW_STATISTICS_LABEL = input.bool(
 title  = "👀 Show Combined Statistics Label",
 defval = true,
 group  = "STATISTIC SETTINGS"
 )

STATS_LABEL_BACKGROUND_COLOR = input.color(
 title  = "Stats Label BG Color",
 defval = color.new(#434651, 0),
 group  = "STATISTIC SETTINGS"
 )

STATS_LABEL_TEXT_COLOR = input.color(
 title  = "Stats Label Text Color",
 defval = color.new(#D1D4DC, 10),
 group  = "STATISTIC SETTINGS"
 )

STATS_LABEL_TEXT_SIZE = input.string(
 title   = "Stats Label Text Size",
 defval  = "normal",
 options = ["tiny", "small", "normal", "large", "huge"],
 group   = "STATISTIC SETTINGS",
 display = display.none
 )

var label statsLab = na

f_buildStats() =>
    // For closed trades:
    float sPNL = array.size(allPNLs) > 0 ? array.sum(allPNLs) : 0
    float aPNL = array.size(allPNLs) > 0 ? array.avg(allPNLs) : 0
    float mdPNL= array.size(allPNLs) > 0 ? array.median(allPNLs) : 0
    float moPNL= array.size(allPNLs) > 0 ? array.mode(allPNLs) : 0
    float mnPNL= array.size(allPNLs) > 0 ? array.min(allPNLs) : 0
    float mxPNL= array.size(allPNLs) > 0 ? array.max(allPNLs) : 0
    float stPNL= array.size(allPNLs) > 0 ? array.stdev(allPNLs) : 0

    float aBars= array.size(allBars) > 0 ? array.avg(allBars) : 0
    float mdBars= array.size(allBars) > 0 ? array.median(allBars) : 0
    float moBars= array.size(allBars) > 0 ? array.mode(allBars) : 0
    float mnBars= array.size(allBars) > 0 ? array.min(allBars) : 0
    float mxBars= array.size(allBars) > 0 ? array.max(allBars) : 0
    float stBars= array.size(allBars) > 0 ? array.stdev(allBars) : 0

    float netP = sPNL
    float wRate= (closedTrades > 0) ? (winsCount * 100. / closedTrades) : 0

    // If there's currently an open trade (not closed yet), count it
    int openTrades = inTrade ? 1 : 0
    int totalTrades = closedTrades + openTrades

    string txt =
       "BACKTESTING STATISTIC\n"
       + "===================\n"
       + "Trades: "         + str.tostring(totalTrades)
       + "(Closed: "        + str.tostring(closedTrades) + ", Open: " + str.tostring(openTrades) + ")"
       + "\nWins: "         + str.tostring(winsCount)
       + "\nLosses: "       + str.tostring(lossesCount)
       + "\nWin Rate: "     + str.tostring(wRate, format.mintick) + "%"
       + "\n--------------------------------\n"
       + "Net Profit(%): "  + str.tostring(netP, format.mintick)
       + "\nAvg PnL: "      + str.tostring(aPNL, format.mintick)
       + "\nMedian PnL: "   + str.tostring(mdPNL, format.mintick)
       + "\nMode PnL: "     + str.tostring(moPNL, format.mintick)
       + "\nMin PnL: "      + str.tostring(mnPNL, format.mintick)
       + "\nMax PnL: "      + str.tostring(mxPNL, format.mintick)
       + "\nStdDev PnL: "   + str.tostring(stPNL, format.mintick)
       + "\n--------------------------------\n"
       + "Avg Bars/Trade: " + str.tostring(aBars, format.mintick)
       + "\nMedian Bars: "  + str.tostring(mdBars, format.mintick)
       + "\nMode Bars: "    + str.tostring(moBars, format.mintick)
       + "\nMin Bars: "     + str.tostring(mnBars, format.mintick)
       + "\nMax Bars: "     + str.tostring(mxBars, format.mintick)
       + "\nStdDev Bars: "  + str.tostring(stBars, format.mintick)
    txt

if SHOW_STATISTICS_LABEL
    // Delete old label each bar
    label.delete(statsLab)

    // Determine label text size
    label_size = switch STATS_LABEL_TEXT_SIZE
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.normal

    // Place near the middle-right of the current bar
    float statsY = (high + low) / 2.0
    statsLab := label.new(
     x        = bar_index + 1,
     y        = statsY,
     text     = f_buildStats(),
     xloc     = xloc.bar_index,
     yloc     = yloc.price,
     color    = STATS_LABEL_BACKGROUND_COLOR,
     style    = label.style_label_left,
     textcolor= STATS_LABEL_TEXT_COLOR,
     size     = label_size,
     textalign= text.align_left
     )

// ──────────────────────────────────────────────────────────────────────────
// CONDITION TABLE listing entry & close conditions
// ──────────────────────────────────────────────────────────────────────────
var table condTab = na

if barstate.isnew
    // Rebuild the table each bar so it updates if user changes inputs
    if not na(condTab)
        table.delete(condTab)
    condTab := table.new(position.bottom_center, 2, 50, border_width=1, border_color=color.new(color.black,100))

    // Table header
    table.cell(condTab, 0, 0, "🎛️ Entry conditions", text_color=color.white, bgcolor=color.new(#2A2E39,0), text_halign=text.align_center)
    table.cell(condTab, 1, 0, "🏁 Close conditions", text_color=color.white, bgcolor=color.new(#2A2E39,0), text_halign=text.align_center)

    bool noEntry = (array.size(entryTableArr) == 0)
    bool noClose = (array.size(closeTableArr) == 0)
    if noEntry and noClose
        table.cell(condTab, 0, 1, "No indicators selected", text_color=color.white, bgcolor=color.new(#056757,0), text_halign=text.align_left)
        table.cell(condTab, 1, 1, "No indicators selected", text_color=color.white, bgcolor=color.new(#B22932,0), text_halign=text.align_left)
    else
        int maxLn = math.max(array.size(entryTableArr), array.size(closeTableArr))
        for i=0 to maxLn-1
            string eTxt = i < array.size(entryTableArr) ? array.get(entryTableArr,i) : ""
            string cTxt = i < array.size(closeTableArr) ? array.get(closeTableArr,i) : ""
            table.cell(condTab, 0, i+1, eTxt, text_color=color.white, bgcolor=color.new(#056757,0), text_halign=text.align_left)
            table.cell(condTab, 1, i+1, cTxt, text_color=color.white, bgcolor=color.new(#B22932,0), text_halign=text.align_left)
````
