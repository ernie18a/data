# RSI Trap [XWiseTrade]

- url: https://www.tradingview.com/script/Mhnbdzpm-RSI-Trap-XWiseTrade/
- type: indicator
- pine_id: PUB;367293277afd4073a0cf484de3082d34
- version: 1.0

## Description

[b]RSI Trap[/b]
Most traders read RSI the textbook way: above 70 means overbought, expect a pullback; below 30 means oversold, expect a bounce. RSI Trap is built on the opposite read — and on the one thing the textbook ignores: volume.

[b]The idea[/b]
When RSI is overbought and price keeps making new highs, but volume is fading, the conventional trader shorts the "overbought" market. They get trapped. Here's why: if price advances to new highs without volume, there is no one selling into it — no resistance, no defense above. A market that climbs on thin volume isn't exhausted; it's meeting no opposition, and tends to keep going. The trap is sprung on everyone who faded the extreme.
The mirror applies to the downside: oversold, new lows, fading volume — no buyers stepping in, no support below — and the dip-buyers get trapped.

[b]What it shows[/b]
[list]
[*]Bull Trap — overbought + new highs + fading volume → no resistance above, uptrend likely continues (traps shorts)
[*]Bear Trap — oversold + new lows + fading volume → no support below, downtrend likely continues (traps dip-buyers)
[*]Labels on the candle, with a cooldown to avoid clustering
[/list]

Why three conditions, not one
RSI alone fires on every extreme and stays pinned in trends — pure noise. 
This requires the extreme to coincide with (a) price still breaking to new highs/lows and (b) contracting volume, isolating the specific case where an "overbought/oversold" reading actually signals continuation rather than reversal.
Inputs

RSI length, overbought/oversold levels, volume average length, low-volume fraction, new-high/low lookback, cooldown.

Built-in alerts both directions. These are descriptive market-structure signals for discretionary use, not buy/sell recommendations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

//@version=6
indicator("RSI Trap [XWiseTrade]", overlay=true, max_labels_count=500)

// ===== Inputs =====
rsiLen   = input.int(14, "RSI length", group="RSI")
rsiOB    = input.int(70, "Overbought level", group="RSI")
rsiOS    = input.int(30, "Oversold level", group="RSI")
volLen   = input.int(20, "Volume average length", group="Volume")
volFrac  = input.float(0.7, "Low-volume fraction", step=0.05, minval=0.1, maxval=1.0, group="Volume",
     tooltip="Bar volume must be < average volume x this value to count as fading (no opposing side). 0.7 = below 70% of average")
hhllLen  = input.int(10, "New high/low lookback", minval=1, group="Breakout",
     tooltip="Price must make a new high/low over this many bars to count as advancing with no defense")
cooldown = input.int(5, "Signal cooldown (bars)", minval=0, group="Display")

// ===== RSI & Volume =====
rsi    = ta.rsi(close, rsiLen)
avgVol = ta.sma(volume, volLen)
lowVol = volume < avgVol * volFrac   // Fading volume = no opposing side

// ===== Price still advancing (breaking out with no defense) =====
newHigh = high >= ta.highest(high, hhllLen)   // New high over N bars: price still pushing up
newLow  = low  <= ta.lowest(low,  hhllLen)    // New low over N bars: price still pushing down

// ===== Trap logic (RSI used in reverse) =====
// Overbought + fading volume + still new highs: crowd expects a pullback,
//   but price keeps rising on thin volume -> no resistance above
//   -> uptrend likely continues -> Bull Trap (traps the shorts)
// Oversold + fading volume + still new lows: crowd expects a bounce,
//   but price keeps falling on thin volume -> no support below
//   -> downtrend likely continues -> Bear Trap (traps the dip-buyers)
bullTrap = rsi > rsiOB and lowVol and newHigh
bearTrap = rsi < rsiOS and lowVol and newLow

// ===== Cooldown =====
var int lastBull = -1000
var int lastBear = -1000
fireBull = bullTrap and (bar_index - lastBull > cooldown)
fireBear = bearTrap and (bar_index - lastBear > cooldown)
if fireBull
    lastBull := bar_index
if fireBear
    lastBear := bar_index

// ===== Labels (Bull = continuation up, Bear = continuation down; consistent with sweep script) =====
if fireBull
    label.new(bar_index, high, "Bull\nTrap", yloc=yloc.abovebar,
         color=color.new(#d90000, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small)
if fireBear
    label.new(bar_index, low, "Bear\nTrap", yloc=yloc.belowbar,
         color=color.new(#04b501, 0), textcolor=color.white,
         style=label.style_label_up, size=size.small)

// ===== Alerts =====
alertcondition(fireBull, "Bullish RSI Trap", "Overbought on fading volume but price still making new highs - no resistance above, uptrend likely to continue")
alertcondition(fireBear, "Bearish RSI Trap", "Oversold on fading volume but price still making new lows - no support below, downtrend likely to continue")
````
