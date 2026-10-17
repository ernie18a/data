# Mean Reversion Setup LliterH

- url: https://www.tradingview.com/script/6XPbhz9C/
- type: strategy
- pine_id: PUB;b3cc06d99d7b442a81921f60a1b7b7c4
- version: 1.0

## Description

█ [b]OVERVIEW[/b]
The Mean Reversion Setup LliterH is an institutional-grade algorithmic system optimized for high-timeframe trading on major indices (S&P 500, Nasdaq) and Gold (XAUUSD). This strategy identifies extreme statistical price dislocations and is specifically validated for the 4-hour (4H) and Daily (1D) intervals to reduce market noise and capture significant swing moves.

█ [b]STRATEGY PERFORMANCE (Backtest 2006–2026)[/b]
In accordance with professional transparency standards, this strategy provides a robust statistical sample size of over 1,200 trades. The following metrics represent the "Risk-First" philosophy of this system:

[b]Max Drawdown [/b]: 14.82% — This is the primary risk metric. Every trader must be psychologically prepared for this "dragon" before the equity curve ascends.

[b]Profit Factor[/b]: 2.104 

[b]Win Rate[/b]: 73.05% 

[b]Total Trades[/b]: 1,232

█ [b]THE LOGIC[/b]
The system operates on the confluence of price dislocation and internal candle weakness:

[list=1]
[*][b]Volatility-Adjusted Floor[/b]: Triggers when the price drops below a threshold anchored to the 10-period highest high and a 25-period average range.
[/list]

[pine]$$Threshold = \text{Highest}(\text{High}, 10) - (2.5 \times \text{SMA}(\text{High} - \text{Low}, 25))$$[/pine]

[list=2]
[*][b]Internal Bar Strength (IBS)[/b]: Filters for entries where the close occurs in the bottom 30% of the bar's range, confirming exhaustion.
[/list]

[pine]$[symbol="EURONEXT:IBS"]EURONEXT:IBS[/symbol] = \frac{\text{Close} - \text{Low}}{\text{High} - \text{Low}}$$[/pine]

[list=3]
[*][b]Regime Filter[/b]: Utilizes a 50-period Moving Average to block entries during structural downtrends, preventing "catching the knife" in bear markets.[/list]

█ [b]EXECUTION & FEATURES[/b]

[*][b]Multi-Leg Exit[/b]: Features a momentum-based recovery exit (Leg 1) and an ATR-based trailing stop (Leg 2) to maximize profit during extended runs.

[*][b]Hard Stop Protection[/b]: A fixed $2 \times ATR$ emergency stop-loss protects the full position against extreme volatility.

[*][b]Automation Ready[/b]: Includes pre-configured alert logic for seamless integration with PineConnector (MT4/MT5)

█ [b]RECOMMENDATION & COMPLIANCE[/b]

This script adheres to all TradingView requirements for professional publication. While the Win Rate is 73.05%, it is vital to respect the[b] 14.82% Drawdown[/b] as the [b]"cost of entry."[/b] [i]Professional trading requires discipline during drawdown periods to achieve long-term statistical goals.
[/i]

█ [b]DISCLAIMER[/b]

Past performance is not indicative of future results. Trading indices and commodities involves significant risk of loss. This script is provided for educational and technical analysis purposes only. Always perform your own due diligence before live execution.

## Source Code

````pine
// // This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LliterH

// ╔══════════════════════════════════════════════════════════════╗
// ║   Mean Reversion Suite — Institutional Index Edition          ║
// ║   by @LliterH                                                  ║
// ║                                                                ║
// ║   Recommended timeframe  : 180m, 240m, Daily (1D)              ║
// ║   Recommended instruments: SPX500, NDX100, DJI30               ║
// ║                                                                ║
// ║   Logic: Buys extreme statistical dislocations below the      ║
// ║   10-bar high minus 2.5x avg range. Filtered by IBS < 0.3.    ║
// ║   Regime filter: entries blocked below MA 50.                  ║
// ║                                                                ║
// ║   Exit Strategy:                                               ║
// ║   Leg 1 (50%): close > previous bar high (momentum)            ║
// ║   Leg 2 (50%): ATR trailing stop (trend follow)                ║
// ║   Hard stop  : 2x ATR protection.                              ║
// ╚══════════════════════════════════════════════════════════════╝
//@version=5
strategy(
     "Mean Reversion Setup LliterH",
     overlay           = true,
     initial_capital   = 100000,
     default_qty_type  = strategy.percent_of_equity,
     default_qty_value = 100,
     currency          = currency.USD)

// ============================================================
// 1. INPUTS
// ============================================================

// -- Core logic --
GRP_CORE = "Core Strategy Logic"
lookbackHigh = input.int(10,    "Highest High Periods", group=GRP_CORE)
lookbackAvg  = input.int(25,    "Average Range Periods", group=GRP_CORE)
multiplier   = input.float(2.5, "Drop Multiplier", tooltip="Higher = more extreme entries.", group=GRP_CORE)
ibsMax       = input.float(0.3, "Max IBS Level", tooltip="0.3 = Close in the bottom 30% of the bar.", group=GRP_CORE)

// -- Regime filter --
GRP_REG = "Trend Regime Filter"
useRegime     = input.bool(true, "Enable Regime Filter", tooltip="Blocks entries below the MA.", group=GRP_REG)
regimeLength  = input.int(50,    "Regime MA Length", minval=10, group=GRP_REG)

// -- Risk Management --
GRP_RISK = "Exits & Risk Management"
atrLen    = input.int(14,     "ATR Length", group=GRP_RISK)
atrMult   = input.float(2.0,  "Hard Stop ATR Multiplier", step=0.25, group=GRP_RISK)
trailMult = input.float(1.5, "Trailing Stop ATR Multiplier (Leg 2)", step=0.25, group=GRP_RISK)

// -- Automation (PineConnector) --
GRP_PC = "PineConnector Alerts"
pcId   = input.string("YOUR_LICENSE_ID", "License ID", group=GRP_PC)
pcRisk = input.float(1.0, "Risk per trade (%)", minval=0.1, maxval=10.0, step=0.1, group=GRP_PC)

// ============================================================
// 2. CORE MATH & INDICATORS
// ============================================================
float highest10    = ta.highest(high, lookbackHigh)
float avgRange25   = ta.sma(high - low, lookbackAvg)
float buyThreshold = highest10 - (multiplier * avgRange25)
float ibs          = (high == low) ? 0.0 : (close - low) / (high - low)
float regimeMA     = ta.sma(close, regimeLength)
float atr          = ta.atr(atrLen)

// ============================================================
// 3. ENTRY & EXIT LOGIC
// ============================================================
bool condPrice  = close < buyThreshold
bool condIBS    = ibs < ibsMax
bool condRegime = useRegime ? (close > regimeMA) : true

bool longCondition = condPrice and condIBS and condRegime and strategy.position_size == 0

// Track Stop Levels
var float hardStopLevel = na
var float peakClose     = na
var float trailLevel    = na

if longCondition
    hardStopLevel := close - (atrMult  * atr)
    peakClose     := close
    trailLevel    := close - (trailMult * atr)

if strategy.position_size > 0
    peakClose  := math.max(peakClose, close)
    trailLevel := peakClose - (trailMult * atr)

if strategy.position_size == 0
    hardStopLevel := na
    peakClose     := na
    trailLevel    := na

// Exit Conditions
bool inPos = strategy.position_size > 0
bool hardStopFired = inPos and not na(hardStopLevel) and close <= hardStopLevel
bool leg1Fired     = inPos and not hardStopFired and close > high[1]
bool leg2Fired     = inPos and not hardStopFired and not leg1Fired and not na(trailLevel) and close <= trailLevel

// ============================================================
// 4. EXECUTION & ALERTS
// ============================================================
if longCondition
    strategy.entry("Buy", strategy.long)
    alert(pcId + ",buy,SPX500,sl=" + str.tostring(math.round(close - (atrMult * atr), 2)) + ",risk=" + str.tostring(pcRisk), alert.freq_once_per_bar_close)

if hardStopFired
    strategy.close("Buy", comment="Hard Stop Hit")
    alert(pcId + ",closelong,SPX500", alert.freq_once_per_bar_close)

if leg1Fired
    strategy.close("Buy", qty_percent = 50, comment = "Leg 1 (50%)")
    alert(pcId + ",closelong,SPX500,qty=50", alert.freq_once_per_bar_close)

if leg2Fired
    strategy.close("Buy", comment = "Leg 2 (Trail)")
    alert(pcId + ",closelong,SPX500", alert.freq_once_per_bar_close)

// ============================================================
// 5. VISUALS
// ============================================================
plot(buyThreshold, color=inPos ? color.red : color.green, linewidth=2, title="Buy Floor")
plot(regimeMA, color=color.new(color.orange, 50), title="Regime Filter MA")
plot(inPos ? trailLevel : na, color=color.purple, style=plot.style_linebr, title="Trailing Stop")
plotshape(longCondition, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
````
