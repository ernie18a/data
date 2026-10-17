# FVG Alerts (DPM)

- url: https://www.tradingview.com/script/fAfcfLZS-FVG-Alerts-DPM/
- type: indicator
- pine_id: PUB;5419243f448a401ca8bb9b04694b3c70
- version: 1.0

## Description

Plots fair value gaps and adds an alert anytime a new gap is formed.

## Source Code

````pine
//@version=6
indicator("FVG Alerts (DPM)", shorttitle="FVG Alerts (DPM)", overlay=true, max_boxes_count=500, max_lines_count=500)
// ———————————————————— Inputs
i_fillByMid       = input.bool(false, "Delete after Mid Fill ?",                group="FVG Settings", tooltip="If enabled, the Fair Value Gap (FVG) will be removed once its midpoint is tested.")
i_deleteonfill    = input.bool(true,  "Delete after Full Fill ?",                group="FVG Settings", tooltip="If enabled, the Fair Value Gap (FVG) will be removed once it is completely filled.")
i_identifyOnClose = input.bool(true,  "Wait for candle Close to confirm FVG ?",  group="FVG Settings", tooltip="If enabled, Fair Value Gaps will only be identified after the candle has closed.")
i_sell_liquidity_color = input.color(#00fa7c1a, "Bullish FVG", group="Visual Settings")
i_buy_liquidity_color  = input.color(#ff0d3f1a, "Bearish FVG", group="Visual Settings")
// ———————————————————— Global data
var buy_liquidity_gapholder  = array.new<box>()
var sell_liquidity_gapholder = array.new<box>()
var buy_liquidity_midholder  = array.new<line>()
var sell_liquidity_midholder = array.new<line>()
var transparentcolor = color.new(color.white, 100)
// alertConditions: 0=BearFilled, 1=BullFilled, 2=NewBear, 3=NewBull
var alertConditions = array.new<bool>(4, false)
// ———————————————————— Functions
f_gapCreation(_upperlimit, _lowerlimit, _midlimit, _bar, _boxholder, _midholder, _boxcolor, _newAlertIdx) =>
    midPointColor = color.red
    if _boxcolor == i_sell_liquidity_color
        midPointColor := #00fa7c
    array.push(_boxholder, box.new(_bar, _upperlimit, _bar + 1, _lowerlimit, border_color=transparentcolor, bgcolor=_boxcolor, extend=extend.right))
    if i_fillByMid
        array.push(_midholder, line.new(_bar, _midlimit, _bar + 1, _midlimit, color=midPointColor, extend=extend.right))
    array.set(alertConditions, _newAlertIdx, true)
f_gapLogic(_close, _high, _highp2, _low, _lowp2, _open, _bar) =>
    if not i_identifyOnClose or barstate.isconfirmed
        if _open > _close
            if _high - _lowp2 < 0
                upperlimit = _close - (_close - _lowp2)
                lowerlimit = _close - (_close - _high)
                midlimit   = (upperlimit + lowerlimit) / 2
                f_gapCreation(upperlimit, lowerlimit, midlimit, _bar, buy_liquidity_gapholder, buy_liquidity_midholder, i_buy_liquidity_color, 2)
        else
            if _low - _highp2 > 0
                upperlimit = _close - (_close - _low)
                lowerlimit = _close - (_close - _highp2)
                midlimit   = (upperlimit + lowerlimit) / 2
                f_gapCreation(upperlimit, lowerlimit, midlimit, _bar, sell_liquidity_gapholder, sell_liquidity_midholder, i_sell_liquidity_color, 3)
f_gapDeletion(_currentgap, _i, _boxholder, _midholder, is_buy_liquidity) =>
    if is_buy_liquidity
        array.set(alertConditions, 0, true)
    else
        array.set(alertConditions, 1, true)
    array.remove(_boxholder, _i)
    if i_fillByMid
        currentmid = array.get(_midholder, _i)
        array.remove(_midholder, _i)
        if i_deleteonfill
            line.delete(currentmid)
        else
            line.set_extend(currentmid, extend.none)
            line.set_x2(currentmid, bar_index)
    if i_deleteonfill
        box.delete(_currentgap)
    else
        box.set_extend(_currentgap, extend.none)
        box.set_right(_currentgap, bar_index)
f_gapCheck(_high, _low) =>
    if array.size(buy_liquidity_gapholder) > 0
        for i = array.size(buy_liquidity_gapholder) - 1 to 0
            currentgap = array.get(buy_liquidity_gapholder, i)
            currenttop = box.get_top(currentgap)
            if i_fillByMid
                currentmid  = array.get(buy_liquidity_midholder, i)
                currenttop := line.get_y1(currentmid)
            if _high >= currenttop
                f_gapDeletion(currentgap, i, buy_liquidity_gapholder, buy_liquidity_midholder, true)
            else if _high > box.get_bottom(currentgap) and _high < box.get_top(currentgap)
                box.set_bottom(currentgap, _high)
    if array.size(sell_liquidity_gapholder) > 0
        for i = array.size(sell_liquidity_gapholder) - 1 to 0
            currentgap    = array.get(sell_liquidity_gapholder, i)
            currentbottom = box.get_bottom(currentgap)
            if i_fillByMid
                currentmid     = array.get(sell_liquidity_midholder, i)
                currentbottom := line.get_y1(currentmid)
            if _low <= currentbottom
                f_gapDeletion(currentgap, i, sell_liquidity_gapholder, sell_liquidity_midholder, false)
            else if _low < box.get_top(currentgap) and _low > box.get_bottom(currentgap)
                box.set_top(currentgap, _low)
// ———————————————————— Main
f_gapLogic(close[1], high, high[2], low, low[2], open[1], bar_index)
f_gapCheck(high, low)
// ———————————————————— Alerts
alertcondition(array.get(alertConditions, 1), title="Bullish FVG Filled",  message="Bullish FVG has been filled at {{close}}")
alertcondition(array.get(alertConditions, 0), title="Bearish FVG Filled",  message="Bearish FVG has been filled at {{close}}")
alertcondition(array.get(alertConditions, 3), title="New Bullish FVG",     message="New Bullish FVG formed at {{close}}")
alertcondition(array.get(alertConditions, 2), title="New Bearish FVG",     message="New Bearish FVG formed at {{close}}")
// Reset flags
array.set(alertConditions, 0, false)
array.set(alertConditions, 1, false)
array.set(alertConditions, 2, false)
array.set(alertConditions, 3, false)
````
