# 4H Touch Test

- url: https://www.tradingview.com/script/kpJUPeQo-4H-Touch-Test/
- type: indicator
- pine_id: PUB;a94f85e43c0e4939941f1d0822408256
- version: 1.0

## Description

What should happen:
Whenever price trades at or above the previous 4H high, a blue dot appears at that previous 4H high price.
Whenever price trades at or below the previous 4H low, a blue dot appears at that previous 4H low price.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dre4169

//@version=6
indicator("4H Touch Test", overlay=true, max_labels_count=500)

// Previous 4H levels
prev4HHigh = request.security(syminfo.tickerid, "240", high[1], lookahead=barmerge.lookahead_on)
prev4HLow  = request.security(syminfo.tickerid, "240", low[1], lookahead=barmerge.lookahead_on)

// Touch conditions
touchHigh = high >= prev4HHigh
touchLow  = low <= prev4HLow

// Blue dots at actual level
if touchHigh
    label.new(
         bar_index,
         prev4HHigh,
         "●",
         style=label.style_none,
         textcolor=color.blue,
         size=size.small)

if touchLow
    label.new(
         bar_index,
         prev4HLow,
         "●",
         style=label.style_none,
         textcolor=color.blue,
         size=size.small)
````
