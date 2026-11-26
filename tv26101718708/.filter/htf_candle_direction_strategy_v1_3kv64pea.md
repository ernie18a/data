# HTF Candle Direction Strategy V1

- url: https://www.tradingview.com/script/3kv64PEa-HTF-Candle-Direction-Strategy-V1/
- type: strategy
- pine_id: PUB;2a049ecbff1a427c8e48dbacae4436c0
- version: 1.0

## Description

🔹 Title

HTF Candle Direction Strategy V1

🔹 Short Description

Higher Timeframe (HTF) bias-based strategy with optional EMA & volume filters and controlled daily execution.

🔹 Full Description
📌 Overview

HTF Candle Direction Strategy V1 is a simple yet powerful trend-following strategy that trades in the direction of a selected Higher Timeframe (HTF) candle.

The core idea is straightforward:

If the HTF candle is bullish → look for BUY trades
If the HTF candle is bearish → look for SELL trades

This helps traders align with the broader market trend while executing trades on lower timeframes.

⚙️ How It Works
The script fetches HTF Open and Close prices
Determines directional bias:
Bullish Bias → HTF Close > HTF Open
Bearish Bias → HTF Close < HTF Open
Trades are executed only when:
Signals are enabled
Selected direction (Buy/Sell) is enabled
Filters (if enabled) are satisfied
Only one trade per day is allowed
🔍 Features

✅ Higher Timeframe Bias Trading

Trade in alignment with HTF trend
Works on any timeframe combination

✅ Lookahead Mode (Backtesting vs Real Trading)

ON → Faster signals but repaints
OFF → Realistic, non-repainting behavior

✅ EMA Filter (Optional)

Confirms trend using EMA
Buy only above EMA
Sell only below EMA

✅ Volume Filter (Optional)

Trades only when volume is strong
Helps avoid weak market conditions

✅ One Trade Per Day Logic

Prevents overtrading
Keeps strategy disciplined

✅ Built-in Alerts

BUY & SELL alerts included
Ready for automation

✅ Live Dashboard

Displays:
HTF Bias
Lookahead status
EMA filter status
Volume filter status
📊 Dashboard Information

The dashboard (top-right) provides real-time status:

HTF Bias → Current market direction
Lookahead → ON (Repainting) / OFF (Safe)
EMA Filter → Enabled / Disabled
Volume Filter → Enabled / Disabled
⚠️ Important Notes
Lookahead ON = Repainting
Use only for backtesting or analysis
For real trading, always use:
👉 Lookahead OFF
Strategy takes only one trade per day, so performance depends on HTF accuracy
🎯 Best Use Cases
Intraday trading with HTF confirmation
Trend-following strategies
Index, Forex, Crypto markets
Scalping with higher timeframe bias
💡 Recommended Settings
HTF: 4H / Daily
EMA: 50 or 200
Lookahead: OFF (for live trading)
Volume Filter: Optional
🔔 Alerts
BUY Signal → HTF Bullish + filters satisfied
SELL Signal → HTF Bearish + filters satisfied
🚀 Final Notes

This strategy is designed for simplicity, clarity, and disciplined execution.
It avoids overtrading and focuses on high-probability directional setups.

⚠️ Disclaimer

This script is provided for educational and informational purposes only and should not be considered financial advice.

Trading in financial markets involves significant risk, and you may lose all or part of your capital. Past performance of this strategy does not guarantee future results.

This strategy uses higher timeframe data and optional lookahead logic. When lookahead is enabled, signals may repaint, meaning results shown on historical data may differ from real-time performance.

Users are strongly advised to:

Test the strategy on demo accounts before using real capital
Use proper risk management
Understand how the strategy works before trading

The author is not responsible for any financial losses or damages resulting from the use of this script.

## Source Code

````pine
//@version=5
strategy(title="HTF Candle Direction Strategy V1",overlay=true,pyramiding=0,initial_capital=10000)

//====================================================================
// 🔹 DESCRIPTION
// This strategy trades based on Higher Timeframe (HTF) candle direction.
// - Takes trades aligned with HTF bullish/bearish bias
// - Optional EMA & Volume filters for improved accuracy
// - One trade per day (controlled execution)
// - Lookahead option available (for testing vs real conditions)
//====================================================================


//------------- INPUTS --------------------------------------//
period = input.timeframe("720", title="Higher Timeframe")

enableSignalsInput = input.bool(true,  title="Enable Signal Generation")
enableBuy          = input.bool(true,  title="Enable BUY Signals")
enableSell         = input.bool(true,  title="Enable SELL Signals")

// Lookahead Control (⚠️ Repainting when ON)
useLookahead = input.bool(true, title="Enable Lookahead (Repainting)")
lookaheadSetting = useLookahead ? barmerge.lookahead_on : barmerge.lookahead_off

//------------- FILTERS -------------------------------------//
useEMAFilter = input.bool(true, title="Enable EMA Filter")
emaLength    = input.int(50, title="EMA Length")

useVolFilter = input.bool(false, title="Enable Volume Filter")
volMultiplier = input.float(1.0, title="Volume Multiplier")

//------------- DAILY CONTROL -------------------------------//
isNewDay = ta.change(time("D"))

var bool signalActive = false
if (isNewDay)
    signalActive := false

//------------- HTF DATA ------------------------------------//
closeData = request.security(syminfo.tickerid, period, close, lookahead=lookaheadSetting)
openData  = request.security(syminfo.tickerid, period, open,  lookahead=lookaheadSetting)

longCondition  = closeData > openData
shortCondition = closeData < openData

//------------- FILTER LOGIC --------------------------------//
emaValue = ta.ema(close, emaLength)
volAvg   = ta.sma(volume, 20)

emaLong  = close > emaValue
emaShort = close < emaValue

volOk = volume > volAvg * volMultiplier

filterLong  = (not useEMAFilter or emaLong) and (not useVolFilter or volOk)
filterShort = (not useEMAFilter or emaShort) and (not useVolFilter or volOk)

//------------- ENTRY CONDITIONS ----------------------------//
enterLong  = enableSignalsInput and enableBuy  and longCondition  and filterLong  and not signalActive and barstate.isconfirmed
enterShort = enableSignalsInput and enableSell and shortCondition and filterShort and not signalActive and barstate.isconfirmed

if (enterLong)
    strategy.entry("BUY", strategy.long)
    signalActive := true

if (enterShort)
    strategy.entry("SELL", strategy.short)
    signalActive := true

//------------- ALERTS --------------------------------------//
alertcondition(enterLong, title="BUY Signal", message="BUY Signal - HTF Strategy")
alertcondition(enterShort, title="SELL Signal", message="SELL Signal - HTF Strategy")

//------------- DASHBOARD -----------------------------------//
var table dashboard = table.new(position.top_right, 2, 5, border_width=1)

htfBias   = longCondition ? "BULLISH" : shortCondition ? "BEARISH" : "NEUTRAL"
biasColor = longCondition ? color.green : shortCondition ? color.red : color.gray

lookText  = useLookahead ? "ON" : "OFF"
lookColor = useLookahead ? color.orange : color.green

emaText   = useEMAFilter ? "ON" : "OFF"
volText   = useVolFilter ? "ON" : "OFF"

// Update only on last bar (performance safe)
if (barstate.islastconfirmedhistory or barstate.islast)

    table.cell(dashboard, 0, 0, "HTF STRATEGY", text_color=color.white, bgcolor=color.black)
    table.cell(dashboard, 1, 0, "STATUS", text_color=color.white, bgcolor=color.black)

    table.cell(dashboard, 0, 1, "HTF Bias", text_color=color.white)
    table.cell(dashboard, 1, 1, htfBias, text_color=color.white, bgcolor=biasColor)

    table.cell(dashboard, 0, 2, "Lookahead", text_color=color.white)
    table.cell(dashboard, 1, 2, lookText, text_color=color.white, bgcolor=lookColor)

    table.cell(dashboard, 0, 3, "EMA Filter", text_color=color.white)
    table.cell(dashboard, 1, 3, emaText, text_color=color.white, bgcolor=color.blue)

    table.cell(dashboard, 0, 4, "Volume Filter", text_color=color.white)
    table.cell(dashboard, 1, 4, volText, text_color=color.white, bgcolor=color.purple)
````
