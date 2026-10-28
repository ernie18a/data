# LVN Rejection / Acceptance Strategy

- url: https://www.tradingview.com/script/j35ygZIm-LVN-Rejection-Acceptance-Strategy/
- type: strategy
- pine_id: PUB;185ff3abed3a448db30ba8d698888f4d
- version: 1.0

## Description

This strategy uses a simplified proxy for low-volume node behavior by combining a rolling mean, volatility bands, and relative volume filtering.
It does not use a true volume profile. Instead, it approximates low-participation zones through statistical structure and volume contraction.
The goal is to observe how price behaves when interacting with these dynamic low-activity regions.

[b]Zone Construction[/b]
The reference level is calculated using a simple moving average over a configurable length.
A dynamic band is then created using ATR:
[list]
[*]Upper boundary = SMA + ATR × multiplier
[*]Lower boundary = SMA − ATR × multiplier
[/list]
This produces a volatility-adjusted range that expands and contracts with market conditions.

[b]Volume Filter[/b]
A relative volume condition is applied:
[list]
[*]current volume is compared against its rolling average
[*]lower-than-average activity is treated as reduced participation
[/list]
This filter is used to reduce signals during high activity spikes.

[b]Trade Logic[/b]
[b]Rejection condition[/b]
[list]
[*]Price briefly trades beyond a band boundary
[*]Closes back inside the zone
[*]Occurs under reduced volume conditions
[/list]
This behavior is treated as failure to accept value outside the range.
[b]Acceptance condition[/b]
[list]
[*]Price closes beyond the band boundary
[*]Holds beyond that level on subsequent price action
[/list]
This is treated as acceptance and directional continuation.

[b]Risk Model[/b]
[list]
[*]Stop-loss distance is based on ATR multiples
[*]Take-profit uses a fixed risk-to-reward ratio
[*]Position sizing is fixed percentage of equity per trade
[/list]
Commission and slippage are not included in this model and should be considered when evaluating performance.

[b]Testing Notes[/b]
This system is sensitive to:
[list]
[*]symbol volatility
[*]timeframe selection
[*]parameter tuning
[/list]
It should be evaluated over a sufficiently large sample of trades to reduce randomness in interpretation.
Results are not intended to represent guaranteed outcomes and will vary across market conditions.

[b]Visualization[/b]
The script plots:
[list]
[*]central moving average
[*]dynamic upper and lower volatility bands
[/list]
These are used to visually track price interaction with the defined zone structure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AIScripts


//@version=6
strategy("LVN Rejection / Acceptance Strategy", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=5)

// ───── INPUTS ─────
zoneLen    = input.int(40, "LVN Detection Length")
atrLen     = input.int(14, "ATR Length")
zoneWidth  = input.float(0.8, "LVN Width ATR")
stopMult   = input.float(1.5, "Stop ATR Multiplier")
rr         = input.float(2.0, "Risk Reward")

// ───── LVN APPROXIMATION ─────
basis   = ta.sma(close, zoneLen)
atrVal  = ta.atr(atrLen)

lvnUpper = basis + atrVal * zoneWidth
lvnLower = basis - atrVal * zoneWidth

// Relative volume check
avgVol = ta.sma(volume, zoneLen)
lowVol = volume < avgVol * 0.8

// ───── REJECTION / ACCEPTANCE LOGIC ─────
bullReject = low < lvnLower and close > lvnLower and lowVol
bearReject = high > lvnUpper and close < lvnUpper and lowVol

bullAccept = close > lvnUpper and close[1] > lvnUpper
bearAccept = close < lvnLower and close[1] < lvnLower

// ───── ENTRY CONDITIONS ─────
longCondition  = bullReject or bullAccept
shortCondition = bearReject or bearAccept

if longCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size == 0
    strategy.entry("Short", strategy.short)

// ───── RISK MANAGEMENT ─────
longStop   = strategy.position_avg_price - atrVal * stopMult
longTarget = strategy.position_avg_price + atrVal * stopMult * rr

shortStop   = strategy.position_avg_price + atrVal * stopMult
shortTarget = strategy.position_avg_price - atrVal * stopMult * rr

strategy.exit("Exit Long", from_entry="Long", stop=longStop, limit=longTarget)
strategy.exit("Exit Short", from_entry="Short", stop=shortStop, limit=shortTarget)

// ───── VISUALS ─────
plot(basis, title="LVN Mid", color=color.orange)
plot(lvnUpper, title="LVN Upper", color=color.red)
plot(lvnLower, title="LVN Lower", color=color.green)
````
