<!-- tradingview-pine-id: PUB;326492b937e740eebe88b6f4931b3e43 -->
<!-- tradingviewscripts-format: 1 -->
# Custom Fair Value Gaps [FVG]

Source: https://www.tradingview.com/script/Nf2T3xIP-Institutional-Fair-Value-Gaps/

## Description

fair value gaps with real volume. Best on the 1 hour, 4 hour and daily timeframe.

---

## Source Code

````pine
// This Pine Script(r) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) x4xzsmwf
 
//@version=6
indicator("Custom Fair Value Gaps [FVG]", overlay = true, max_boxes_count = 500, max_labels_count = 500)
 
// ============================================================================
// PATTERN RULES (custom, not the generic textbook FVG)
//
// BEARISH FVG:
//   Candle A (2 bars back) = GREEN/bullish OR DOJI, and its HIGH >= Candle B's HIGH
//   Candle B (1 bar back)  = RED/bearish
//   Candle C (current)     = either color, just needs to leave the gap
//   Gap condition: Candle C high < Candle A low   (box = [Candle C high .. Candle A low])
//
// BULLISH FVG:
//   Candle A (2 bars back) = RED/bearish OR DOJI, and its LOW <= Candle B's LOW
//   Candle B (1 bar back)  = GREEN/bullish
//   Candle C (current)     = either color, just needs to leave the gap
//   Gap condition: Candle C low > Candle A high   (box = [Candle A high .. Candle C low])
//
// Equal highs/lows between Candle A and Candle B are allowed (only a candle
// B that exceeds Candle A invalidates the pattern).
//
// A doji Candle A (open == close) has no directional bias, so it is allowed
// to serve as the first candle of EITHER a bullish or a bearish FVG, as long
// as the rest of the pattern conditions are met.
//
// MITIGATION:
//   Bullish FVG is mitigated when a candle CLOSES below the box bottom.
//   Bearish FVG is mitigated when a candle CLOSES above the box top.
//   Mitigated FVGs are deleted unless "Show Mitigated FVGs" is enabled.
// ============================================================================
 
// ============================== INPUTS ==============================
grpDisplay = "Display"
showBullish   = input.bool(true,  "Show Bullish FVG",                          group = grpDisplay)
showBearish   = input.bool(true,  "Show Bearish FVG",                         group = grpDisplay)
showForming   = input.bool(true,  "Show Forming FVG (3rd candle developing)", group = grpDisplay)
showMitigated = input.bool(false, "Show Mitigated FVGs (for backtesting)",    group = grpDisplay)
extendBoxes   = input.bool(true,  "Extend Active FVG Boxes to Current Bar",  group = grpDisplay)
maxFvg        = input.int(100, "Max Active FVGs Tracked", minval = 10, maxval = 500, group = grpDisplay)
 
grpColor = "Colors"
bullFillColor = input.color(color.new(color.teal, 80), "Bullish FVG Fill",   group = grpColor)
bullBordColor = input.color(color.new(color.teal, 0),  "Bullish FVG Border", group = grpColor)
bearFillColor = input.color(color.new(color.red, 80),  "Bearish FVG Fill",   group = grpColor)
bearBordColor = input.color(color.new(color.red, 0),   "Bearish FVG Border",group = grpColor)
 
formBullFill  = input.color(color.new(color.teal, 55), "Forming Bullish Fill", group = grpColor)
formBearFill  = input.color(color.new(color.red, 55),  "Forming Bearish Fill", group = grpColor)
 
mitBullFill   = input.color(color.new(color.gray, 88), "Mitigated Bullish Fill", group = grpColor)
mitBearFill   = input.color(color.new(color.gray, 88), "Mitigated Bearish Fill", group = grpColor)
mitBordColor  = input.color(color.new(color.gray, 40), "Mitigated Border",       group = grpColor)
 
// ============================== TYPE ==============================
type FVG
    box   b
    float top
    float bottom
    bool  isBull
    bool  mitigated
 
var array<FVG> fvgList = array.new<FVG>()
 
// ============================== CANDLE REFERENCES ==============================
// Candle A = 2 bars ago (1st candle) | Candle B = 1 bar ago (2nd candle) | Candle C = current bar (3rd candle)
oA = open[2]
cA = close[2]
hA = high[2]
lA = low[2]
 
oB = open[1]
cB = close[1]
hB = high[1]
lB = low[1]
 
hC = high
lC = low
 
haveHistory = bar_index >= 2
 
// ============================== PATTERN CONDITIONS ==============================
candleAGreen = cA > oA
candleARed   = cA < oA
candleADoji  = cA == oA
candleBGreen = cB > oB
candleBRed   = cB < oB
 
// A doji Candle A has no directional bias, so it's allowed to serve as the
// first candle of either a bullish or a bearish FVG.
bullBase = (candleARed or candleADoji) and candleBGreen and (lB >= lA) and (lC > hA)
bearBase = (candleAGreen or candleADoji) and candleBRed   and (hB <= hA) and (hC < lA)
 
bullCond = haveHistory and bullBase
bearCond = haveHistory and bearBase
 
// ============================== FORMING (LIVE) PREVIEW ==============================
var box   formBullBox = na
var box   formBearBox = na
var label formBullLbl = na
var label formBearLbl = na
 
if showForming and not barstate.isconfirmed
    // bullish forming preview
    if not na(formBullBox)
        box.delete(formBullBox)
        label.delete(formBullLbl)
        formBullBox := na
        formBullLbl := na
    if bullCond
        fTop = lC
        fBot = hA
        formBullBox := box.new(bar_index[2], fTop, bar_index, fBot, border_color = bullBordColor, border_width = 1, border_style = line.style_dashed, bgcolor = formBullFill)
        formBullLbl := label.new(bar_index, fTop, "FVG?", style = label.style_label_down, color = color.new(color.white, 100), textcolor = bullBordColor, size = size.tiny)
 
    // bearish forming preview
    if not na(formBearBox)
        box.delete(formBearBox)
        label.delete(formBearLbl)
        formBearBox := na
        formBearLbl := na
    if bearCond
        fTop2 = lA
        fBot2 = hC
        formBearBox := box.new(bar_index[2], fTop2, bar_index, fBot2, border_color = bearBordColor, border_width = 1, border_style = line.style_dashed, bgcolor = formBearFill)
        formBearLbl := label.new(bar_index, fBot2, "FVG?", style = label.style_label_up, color = color.new(color.white, 100), textcolor = bearBordColor, size = size.tiny)
else
    if not na(formBullBox)
        box.delete(formBullBox)
        label.delete(formBullLbl)
        formBullBox := na
        formBullLbl := na
    if not na(formBearBox)
        box.delete(formBearBox)
        label.delete(formBearLbl)
        formBearBox := na
        formBearLbl := na
 
// ============================== CONFIRMED FVG CREATION ==============================
bullConfirmed = false
bearConfirmed = false
 
if barstate.isconfirmed and haveHistory
    if showBullish and bullCond
        cTop = lC
        cBot = hA
        newBoxBull = box.new(bar_index[2], cTop, bar_index, cBot, border_color = bullBordColor, bgcolor = bullFillColor)
        array.push(fvgList, FVG.new(newBoxBull, cTop, cBot, true, false))
        bullConfirmed := true
 
    if showBearish and bearCond
        cTop2 = lA
        cBot2 = hC
        newBoxBear = box.new(bar_index[2], cTop2, bar_index, cBot2, border_color = bearBordColor, bgcolor = bearFillColor)
        array.push(fvgList, FVG.new(newBoxBear, cTop2, cBot2, false, false))
        bearConfirmed := true
 
// ============================== MITIGATION + BOX MAINTENANCE ==============================
bullMitigatedNow = false
bearMitigatedNow = false
 
if barstate.isconfirmed and array.size(fvgList) > 0
    for i = array.size(fvgList) - 1 to 0
        fvg = array.get(fvgList, i)
        if not fvg.mitigated
            isMitigatedNow = fvg.isBull ? (close < fvg.bottom) : (close > fvg.top)
            if isMitigatedNow
                fvg.mitigated := true
                if fvg.isBull
                    bullMitigatedNow := true
                else
                    bearMitigatedNow := true
                if showMitigated
                    box.set_right(fvg.b, bar_index)
                    box.set_border_color(fvg.b, mitBordColor)
                    box.set_bgcolor(fvg.b, fvg.isBull ? mitBullFill : mitBearFill)
                else
                    box.delete(fvg.b)
                    array.remove(fvgList, i)
            else
                if extendBoxes
                    box.set_right(fvg.b, bar_index)
 
    // keep the tracked list from growing without bound
    while array.size(fvgList) > maxFvg
        oldFvg = array.shift(fvgList)
        box.delete(oldFvg.b)
 
// ============================== ALERTS ==============================
bullFormingNow = showForming and not barstate.isconfirmed and bullCond
bearFormingNow = showForming and not barstate.isconfirmed and bearCond
 
alertcondition(bullConfirmed,  title = "Bullish FVG Confirmed", message = "Bullish FVG confirmed on {{ticker}} ({{interval}})")
alertcondition(bearConfirmed,  title = "Bearish FVG Confirmed", message = "Bearish FVG confirmed on {{ticker}} ({{interval}})")
alertcondition(bullFormingNow, title = "Bullish FVG Forming",   message = "Potential Bullish FVG forming on {{ticker}} ({{interval}}) - 3rd candle in progress")
alertcondition(bearFormingNow, title = "Bearish FVG Forming",   message = "Potential Bearish FVG forming on {{ticker}} ({{interval}}) - 3rd candle in progress")
alertcondition(bullMitigatedNow, title = "Bullish FVG Mitigated", message = "A Bullish FVG was mitigated on {{ticker}} ({{interval}})")
alertcondition(bearMitigatedNow, title = "Bearish FVG Mitigated", message = "A Bearish FVG was mitigated on {{ticker}} ({{interval}})")
````
