# VCP v2

- url: https://www.tradingview.com/script/IMpFBGFd-VCP-v2/
- type: indicator
- pine_id: PUB;248b2bb3156c40b5aae8bf99c2f61529
- version: 1.0

## Description

v2 Update — BB Width Squeeze

Replaced the ADR% percentile compression calculation with a Bollinger Band Width squeeze system.

Previously the indicator ranked current ADR% within its recent historical range, which struggled to detect compression during long slow consolidations where ADR% stays flat throughout.

BB Width measures how narrow the bands are relative to the 20-period SMA, then ranks current width as a percentile against a 90-day lookback. 

Green when BB Width is in the bottom 15% of its range (true squeeze territory)

Orange at 15–25%, red above.

## Source Code

````pine
//@version=6
indicator("VCP", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
bb_len       = input.int(20,    "BB Length",               group="VCP")
bb_mult      = input.float(2.0, "BB Mult",                 group="VCP")
bbw_lookback = input.int(90,    "BB Width Lookback (Days)", group="VCP")

// ─── CALCULATIONS ─────────────────────────────────────────────────────────────
bb_basis   = ta.sma(close, bb_len)
bb_upper   = bb_basis + bb_mult * ta.stdev(close, bb_len)
bb_lower   = bb_basis - bb_mult * ta.stdev(close, bb_len)
bbw        = (bb_upper - bb_lower) / bb_basis
bbw_high   = ta.highest(bbw, bbw_lookback)
bbw_low    = ta.lowest(bbw, bbw_lookback)
bbw_pctile = bbw_high != bbw_low ? (bbw - bbw_low) / (bbw_high - bbw_low) : 0.5
vcpColor   = bbw_pctile <= 0.15 ? color.rgb(0, 255, 0) : bbw_pctile <= 0.30 ? color.rgb(255, 153, 0) : color.rgb(255, 0, 0)

// ─── DOT TABLE ────────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 1, 1)
table.cell(t, 0, 0, "⬤", text_color=vcpColor, text_size=size.small, bgcolor=color.new(color.black, 100))
````
