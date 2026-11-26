# EMA 9/21 GoldenX Pro-TSL

- url: https://www.tradingview.com/script/97P2VJ5W-EMA-9-21-GoldenX-Pro-TSL/
- type: strategy
- pine_id: PUB;20e9c554c1e74134bd3ed85420d9554e
- version: 1.0

## Description

█ OVERVIEW

EMA GoldenX Pro-TS is a trend-following strategy built around the classic EMA crossover (Golden Cross / Death Cross), enhanced with multi-layer confirmation filters and dynamic risk management. It is designed for traders who want clean, rule-based entries while avoiding choppy, low-conviction signals.


█ HOW IT WORKS

ENTRY LOGIC
 • A Long entry triggers when the Fast EMA crosses above the Slow EMA (Golden Cross), confirmed by rising volume OR rising price action, AND a trending market condition (ADX filter).
 • A Short entry triggers when the Fast EMA crosses below the Slow EMA (Death Cross), confirmed by rising volume OR falling price action, AND a trending market condition.

POSITION FLIPPING
 • When already in a position and the opposite EMA cross occurs, the strategy can instantly close and reverse (flip). The "Flip on EMA cross only" option lets you bypass the volume/ADX filters on reversal signals — useful for fast-moving markets where waiting for full confirmation may cause late entries.

STOP-LOSS MANAGEMENT
 • A dynamic ATR-based trailing stop is calculated each bar.
 • A hard percentage-based maximum stop loss acts as a safety net.
 • The tighter of the two is always used, providing adaptive risk control that respects both volatility and absolute drawdown limits.


█ FEATURES

 • Dual EMA Crossover — Configurable Fast (default 9) and Slow (default 21) EMA periods.
 • ADX Trend Filter — Filters out entries during range-bound / low-momentum conditions (ADX threshold + DI spread).
 • Volume Confirmation — Requires volume above its 5-bar SMA for fresh entries.
 • Price Momentum Check — Validates price direction relative to a 5-bar SMA for additional confluence.
 • ATR Trailing Stop — Volatility-adjusted stop that adapts to current market conditions.
 • Max Stop Loss % — Hard cap on per-trade risk as a percentage of entry price.
 • Trade Direction Control — Choose Long only, Short only, or Both.
 • Instant Position Flip — Optionally reverses on EMA cross without waiting for all filters to align.
 • Alert Conditions — Built-in alerts for Golden Cross (Long) and Death Cross (Short) signals.


█ SETTINGS

 • Fast EMA (default: 9) — Period for the fast EMA line.
 • Slow EMA (default: 21) — Period for the slow EMA line.
 • Trade Direction (default: Both) — Restrict to Long, Short, or trade Both sides.
 • ADX Length (default: 14) — Lookback period for the ADX/DMI calculation.
 • ADX Threshold (default: 20) — Minimum ADX value to qualify as a trending market.
 • ATR Length (default: 14) — Lookback period for the ATR calculation.
 • ATR Multiplier (default: 2.0) — Distance of the ATR trailing stop from the current close.
 • Max Stop Loss % (default: 1.0%) — Maximum allowable stop distance as a % of entry price.
 • Flip on EMA Cross Only (default: true) — When enabled, position reversals only require the EMA cross, bypassing volume/ADX filters for faster flips.


█ VISUAL OUTPUTS

 • Orange line — Fast EMA
 • Blue line — Slow EMA
 • Red line — Active trailing stop level (visible only while in a position)


█ USAGE NOTES

 • Originally designed and tested on TFEX SET50 Index Futures but applicable to any liquid instrument.
 • Best suited for trending markets on intraday to swing timeframes.
 • Adjust EMA periods and ATR multiplier to match the volatility profile of your instrument.
 • Backtest thoroughly on your target market before live deployment.


█ DISCLAIMER

This strategy is provided for educational and research purposes only. Past performance does not guarantee future results. Always manage your risk and trade responsibly.

## Source Code

````pine
// EMA GoldenX Pro-TS Fixed
//@version=5
strategy("EMA 9/21 GoldenX Pro-TSL", overlay = true, initial_capital = 30000)

// --- INPUTS ---
emaFast     = input.int(9, "Fast EMA", minval=1)
emaSlow     = input.int(21, "Slow EMA", minval=1)
tradeDir    = input.string("Both", "Trade Direction", options=["Long", "Short", "Both"])
adxLen      = input.int(14, "ADX Length")
adxThresh   = input.int(20, "ADX Threshold")
useAdxFlip  = input.bool(true, "Exit & flip on DMI reversal (needs ADX > threshold)")

atrLen      = input.int(14, "ATR Length")
atrMult     = input.float(2.0, "ATR Multiplier", step=0.1)
maxLossPerc = input.float(1.0, "Max Stop Loss %", minval=0.1)

// --- CALCULATIONS ---
fastEMA = ta.ema(close, emaFast)
slowEMA = ta.ema(close, emaSlow)
[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)
// Confirm genuine trend, NOT sideways "whipsaw" 
isTrending = adxValue > adxThresh or math.abs(diPlus - diMinus) > 10

volRising    = volume > ta.sma(volume,5)
priceRising  = close > ta.sma(close, 5)
priceFalling = close < ta.sma(close, 5)

atr       = ta.atr(atrLen)
longStop  = close - (atr * atrMult)
shortStop = close + (atr * atrMult)


// --- SIGNALS ---
longOK      = (tradeDir == "Long") or (tradeDir == "Both")
shortOK     = (tradeDir == "Short") or (tradeDir == "Both")
longSignal  = ta.crossover(fastEMA, slowEMA) and (volRising or priceRising) and isTrending
shortSignal = ta.crossunder(fastEMA, slowEMA) and (volRising or priceFalling) and isTrending


// DMI reversal: trend direction flips when +DI / -DI cross (gated by ADX strength)
dmiBearishFlip   = ta.crossunder(diPlus, diMinus)
dmiBullishFlip   = ta.crossover(diPlus, diMinus)
adxConfirmsTrend = adxValue > adxThresh
flipLongToShort  = useAdxFlip and adxConfirmsTrend and dmiBearishFlip and shortOK
flipShortToLong  = useAdxFlip and adxConfirmsTrend and dmiBullishFlip and longOK

// --- EXECUTION LOGIC ---
qty = 1

//GoldenX & DeathX
if longSignal and longOK
    log.info("isTrending : {0}, adxValue : {1}, DMI+: {2}, DMI-: {3}, DMI diff:{4}   ", str.tostring(isTrending),adxValue, diPlus, diMinus, math.abs(diPlus - diMinus)) 
    if strategy.position_size < 0
        strategy.close("Short", comment="Close S")
        strategy.entry("Long", strategy.long, qty=qty, comment="GoldenX->L")

    else if strategy.position_size == 0
        strategy.entry("Long", strategy.long, qty=qty, comment="GoldenX->L")

// else if strategy.position_size < 0 and flipShortToLong
//     strategy.close("Short", comment="ADX DMI Rev")
//     strategy.entry("Long", strategy.long, qty=qty, comment="DMI Flip->L")
      

if shortSignal and shortOK
    if strategy.position_size > 0
        strategy.close("Long", comment="Close L")
        strategy.entry("Short", strategy.short, qty=qty, comment="DeathX->S")
    else if strategy.position_size == 0
        strategy.entry("Short", strategy.short, qty=qty, comment="DeathX->S")

// // --- ADX / DMI: exit and flip when directional trend reverses ---
// else if strategy.position_size > 0 and flipLongToShort
//     strategy.close("Long", comment="ADX DMI Rev")
//     strategy.entry("Short", strategy.short, qty=qty, comment="DMI Flip->S")


// --- DYNAMIC EXIT (Handled globally for efficiency) ---
// check if there are open position
if strategy.position_size > 0 // Long position
    hardStopPrice = strategy.position_avg_price * (1 - (maxLossPerc / 100))
    finalStop   = math.min(longStop, hardStopPrice)
    strategy.exit("Exit Long", from_entry="Long", stop=finalStop, comment="SL-Long")
    

if strategy.position_size < 0 //Short positiion
    hardStopPrice = strategy.position_avg_price * (1 + (maxLossPerc / 100))
    finalStop   = math.max(shortStop, hardStopPrice)
    strategy.exit("Exit Short", from_entry="Short", stop=finalStop, comment="SL-Short")
    

// EXIT ON OPPOSITE handled above by close()
// alertcondition(longSignal, title="LONG Signal", message="LONG")
// alertcondition(shortSignal, title="SHORT Signal", message="SHORT")

// --- VISUALS ---
plot(fastEMA, color=color.orange)
plot(slowEMA, color=color.blue)
//plot(strategy.position_size != 0 ? finalStop : na, "Final Stop", color=color.red, style=plot.style_linebr)
````
