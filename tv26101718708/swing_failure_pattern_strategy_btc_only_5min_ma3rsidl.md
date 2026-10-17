# Swing Failure Pattern Strategy Btc Only 5min

- url: https://www.tradingview.com/script/Ma3rSidl-Swing-Failure-Pattern-Strategy-Btc-Only-5min/
- type: strategy
- pine_id: PUB;f0ab2144a1a64da39ec9af3cb9b121e0
- version: 1.0

## Description

[b]🔍 Overview
[/b]
The Swing Failure Pattern (SFP) Strategy is a pure price-action trading system designed to capture liquidity sweeps and market reversals around key swing highs and lows.
It is based on the concept that price often briefly breaks a swing level to trigger stop-losses, then reverses in the opposite direction.

This strategy trades only confirmed SFP setups, ensuring disciplined entries with clearly defined risk.

[b]📈 Bullish SFP (Long Setup)
[/b]
A Bullish Swing Failure Pattern forms when:

A valid swing low is created

Price wicks below the swing low

The candle closes back above the swing level

Confirmation occurs when price closes above the opposing high

➡️ Action: Enter LONG on the confirmation candle close

[b]📉 Bearish SFP (Short Setup)
[/b]
A Bearish Swing Failure Pattern forms when:

A valid swing high is created

Price wicks above the swing high

The candle closes back below the swing level

Confirmation occurs when price closes below the opposing low

➡️ Action: Enter SHORT on the confirmation candle close

🛑 Risk Management

Stop Loss

Long → Low of the SFP wick

Short → High of the SFP wick

Take Profit

Fixed Risk : Reward = 1 : 2

All SL and TP levels are fixed at entry (no repainting)

[b]🔁 Trailing Take Profit (Optional)
[/b]
Trailing TP can be enabled from settings

Trailing starts after 1R profit

Trail distance is R-based and fully adjustable

Works for both long and short trades

[b]⏰ Time Filters
[/b]
Optional No-Trade on Saturday & Sunday

Prevents new entries during weekends

Active trades continue to manage SL & TP normally

[b]⚙️ Strategy Features
[/b]
Price-action based (no indicators)

Confirmation-only entries

No repainting logic

Works on all markets and timeframes

Orders executed on candle close

[b]🎯 Best Use Cases
[/b]
Forex

Indices

[b]Crypto
[/b]
Futures

Best performance during London & New York sessions

[b]⚠️ Disclaimer
[/b]
This strategy is intended for educational and backtesting purposes only.
Always test and manage risk appropriately before live trading.

## Source Code

````pine
//@version=5
strategy("Swing Failure Pattern Strategy RR 1 to 2 + Trail TP + No Weekend", overlay=true, process_orders_on_close=true)

//==============================
// Inputs
//==============================
len        = input.int(5, "Swings", minval=1)
bull       = input.bool(true, "Bullish SFP")
bear       = input.bool(true, "Bearish SFP")
rr         = input.float(2.0, "Risk Reward", minval=0.5)

// Trailing TP
useTrail   = input.bool(true, "Enable Trailing TP")
trailRR   = input.float(0.5, "Trail Distance (R)", step=0.1)
startRR   = input.float(1.0, "Start Trailing After (R)", step=0.1)

// Weekend filter
noWeekend = input.bool(true, "No Trade on Saturday & Sunday")

//==============================
// Time Filter
//==============================
allowTrade = not (noWeekend and (dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday))

//==============================
// Types
//==============================
type piv
    float swing_prc
    int   swing_bix
    float oppos_prc
    int   oppos_bix
    float wick_prc
    bool  active
    bool  confirmed

type swing
    int   bix
    float prc

//==============================
// Variables
//==============================
n = bar_index
var swing swingH = swing.new()
var swing swingL = swing.new()
var piv pivH = piv.new()
var piv pivL = piv.new()

//==============================
// Pivot detection
//==============================
ph = ta.pivothigh(len, 1)
pl = ta.pivotlow(len, 1)

//==============================
// BEARISH SFP (SHORT)
//==============================
if bear
    if not na(ph)
        swingH.bix := n - 1
        swingH.prc := ph

    sw = swingH.prc
    bx = swingH.bix

    if allowTrade and high > sw and open < sw and close < sw
        opposL = sw
        opposB = n
        for i = 1 to n - bx - 1
            if low[i] < opposL
                opposL := low[i]
                opposB := n - i
        pivH := piv.new(sw, bx, opposL, opposB, high, true, false)

    if allowTrade and pivH.active and not pivH.confirmed
        if close < pivH.oppos_prc
            pivH.confirmed := true
            entry = close
            stop  = pivH.wick_prc
            risk  = stop - entry
            tp    = entry - risk * rr
            strategy.entry("Short", strategy.short)
            if useTrail
                strategy.exit("Short Exit", from_entry="Short", stop=stop, limit=tp,
                              trail_price=entry - risk * startRR, trail_offset=risk * trailRR)
            else
                strategy.exit("Short Exit", from_entry="Short", stop=stop, limit=tp)

    if n - pivH.swing_bix > 500 or close > pivH.swing_prc
        pivH.active := false

//==============================
// BULLISH SFP (LONG)
//==============================
if bull
    if not na(pl)
        swingL.bix := n - 1
        swingL.prc := pl

    sw = swingL.prc
    bx = swingL.bix

    if allowTrade and low < sw and open > sw and close > sw
        opposH = sw
        opposB = n
        for i = 1 to n - bx - 1
            if high[i] > opposH
                opposH := high[i]
                opposB := n - i
        pivL := piv.new(sw, bx, opposH, opposB, low, true, false)

    if allowTrade and pivL.active and not pivL.confirmed
        if close > pivL.oppos_prc
            pivL.confirmed := true
            entry = close
            stop  = pivL.wick_prc
            risk  = entry - stop
            tp    = entry + risk * rr
            strategy.entry("Long", strategy.long)
            if useTrail
                strategy.exit("Long Exit", from_entry="Long", stop=stop, limit=tp,
                              trail_price=entry + risk * startRR, trail_offset=risk * trailRR)
            else
                strategy.exit("Long Exit", from_entry="Long", stop=stop, limit=tp)

    if n - pivL.swing_bix > 500 or close < pivL.swing_prc
        pivL.active := false
````
