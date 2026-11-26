# VRoC 2-Bar Alert NQ

- url: https://www.tradingview.com/script/xQzGhbsr-VRoC-2-Bar-Alert-NQ/
- type: indicator
- pine_id: PUB;ebe54ba8c13545ecacba395c0b014e03
- version: 1.0

## Description

2 Days VRoC above 10, indicates institutional selling pressure and an opportunity for index option shorts as opposed to trend sentiment. Use on /NQ1!! D bar aggregation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ArmbrustCapital

//@version=5
indicator("VRoC 2-Bar Alert — NQ1! D", overlay=false)

length    = input.int(14, "VRoC Length", minval=1)
threshold = input.float(10.0, "VRoC Threshold")

vol = request.security("CME_MINI:NQ1!", "D", volume, barmerge.gaps_off, barmerge.lookahead_off)
vroc = ta.roc(vol, length)

cond = vroc[1] >= threshold and vroc[2] >= threshold

plot(vroc, "VRoC", color=color.blue)
hline(threshold, "Threshold", color=color.red)
bgcolor(cond ? color.new(color.green, 85) : na)

alertcondition(cond, "VRoC 2-Bar Alert — NQ1! D",
     "Previous 2 NQ1! D closes both had VRoC ≥ 10")
````
