# Hedge Fund Engine v4 [Gold vs USD Lead-Lag]

- url: https://www.tradingview.com/script/Zl2H8ntO-Hedge-Fund-Engine-v4-Gold-vs-USD-Lead-Lag/
- type: indicator
- pine_id: PUB;c37bc1fef1cd4d948caae55b2ca0c1ad
- version: 1.0

## Description

Real macro driver overlay
US10Y yields (real rates driver of gold)
2. Session intelligence
Only trade during:
London open
NY open
3. Smart confirmation
Combine with your v3 execution engine:
sweep + absorption + lead/lag

## Source Code

````pine
//@version=5
indicator("Hedge Fund Engine v4 [Gold vs USD Lead-Lag]", overlay=true, max_labels_count=300)

// ═════════════════════════════════════
// INPUTS
// ═════════════════════════════════════
usdSymbol = input.symbol("TVC:DXY", "USD Index")
zLen      = input.int(50, "Z Length")
lagLen    = input.int(10, "Lag Lookback")
volLen    = input.int(20, "Volume Length")

showSignals = input.bool(true, "Show Signals")

// ═════════════════════════════════════
// DATA
// ═════════════════════════════════════
gold = close
usd  = request.security(usdSymbol, timeframe.period, close)

// Normalize both (so they are comparable)
goldRet = math.log(gold / gold[1])
usdRet  = math.log(usd / usd[1])

// ═════════════════════════════════════
// LEAD-LAG ENGINE
// ═════════════════════════════════════

// Correlation (should be negative)
corr = ta.correlation(goldRet, usdRet, zLen)

// Lag detection (USD leads)
usdLead = usdRet - usdRet[lagLen]
goldLag = goldRet - goldRet[lagLen]

// Dislocation (core signal)
dislocation = usdLead + goldLag  // inverse relationship

// Z-score normalization
meanDis = ta.sma(dislocation, zLen)
stdDis  = ta.stdev(dislocation, zLen)
zDis    = stdDis != 0 ? (dislocation - meanDis) / stdDis : 0

// ═════════════════════════════════════
// VOLATILITY FILTER
// ═════════════════════════════════════
atr = ta.atr(14)
volFilter = atr / close > 0.002

// ═════════════════════════════════════
// EXECUTION LOGIC
// ═════════════════════════════════════

// Gold should go UP (USD already dropped)
longSignal =
     zDis < -1.5
 and corr < -0.3
 and usdLead < 0
 and volFilter

// Gold should go DOWN (USD already pumped)
shortSignal =
     zDis > 1.5
 and corr < -0.3
 and usdLead > 0
 and volFilter

// ═════════════════════════════════════
// VISUALS
// ═════════════════════════════════════
plot(zDis, "Dislocation Z", color=color.orange)
hline(1.5)
hline(-1.5)

// Signals
if showSignals and longSignal
    label.new(bar_index, low, "🟢 GOLD LONG\nUSD Led ↓",
         style=label.style_label_up,
         color=color.lime, textcolor=color.black)

if showSignals and shortSignal
    label.new(bar_index, high, "🔴 GOLD SHORT\nUSD Led ↑",
         style=label.style_label_down,
         color=color.red, textcolor=color.white)

// ═════════════════════════════════════
// ALERTS
// ═════════════════════════════════════
alertcondition(longSignal, "Gold Long (USD Lead)", "USD dropped first → Gold lagging")
alertcondition(shortSignal, "Gold Short (USD Lead)", "USD pumped first → Gold lagging")
````
