<!-- tradingview-pine-id: PUB;03d86dce01354711b1d229d30fc51242 -->
<!-- tradingviewscripts-format: 1 -->
# LiquidityFinderLibrary

Source: https://www.tradingview.com/script/C8l4pS83/

## Description

Library  "LiquidityFinderLibrary"

LLF(sPP, dPP, SRs, SRd, ShowHLLs, ShowLLLs, ShowHLLd, ShowLLLd, LabelSize)
  Parameters:
    sPP (int)
    dPP (int)
    SRs (float)
    SRd (float)
    ShowHLLs (bool)
    ShowLLLs (bool)
    ShowHLLd (bool)
    ShowLLLd (bool)
    LabelSize (string)

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab (modified: added customizable label font size)

//@version=6

library('LiquidityFinderLibrary', overlay = true)

// 追加した引数: LabelSize（ラベルのフォントサイズ）
// size.tiny / size.small / size.normal / size.large / size.huge のいずれかを渡す
export LLF(int sPP, int dPP, float SRs, float SRd, bool ShowHLLs, bool ShowLLLs, bool ShowHLLd, bool ShowLLLd, string LabelSize = size.small) => //StaticsLiquidityLineFunction  {p = Previous , c = Current , s = Statics , d = Dynamics, SR = Sensitivity Range}
    //get data
    //Average true Range
    ATR = ta.atr(55)
    STSHighPivot = ta.pivothigh(sPP, sPP) // Short term Statics High Pivot Price {True or False}
    STSLowPivot = ta.pivotlow(sPP, sPP) // Short term Statics Low Pivot Price {True or False}
    STSHVc = ta.valuewhen(bool(STSHighPivot), high[sPP], 0) // Short term Statics High
    STSLVc = ta.valuewhen(bool(STSLowPivot), low[sPP], 0) // Short term Statics Low
    STSHIc = ta.valuewhen(bool(STSHighPivot), bar_index[sPP], 0) // Short term Statics High
    STSLIc = ta.valuewhen(bool(STSLowPivot), bar_index[sPP], 0) // Short term Statics Low
    STSHVp = ta.valuewhen(bool(STSHighPivot), high[sPP], 1) // Short term Statics High
    STSLVp = ta.valuewhen(bool(STSLowPivot), low[sPP], 1) // Short term Statics Low
    STSHIp = ta.valuewhen(bool(STSHighPivot), bar_index[sPP], 1) // Short term Statics High
    STSLIp = ta.valuewhen(bool(STSLowPivot), bar_index[sPP], 1) // Short term Statics Low
    DTSHighPivot = ta.pivothigh(dPP, dPP) // Short term Dynamics High Pivot Price {True or False}
    DTSLowPivot = ta.pivotlow(dPP, dPP) // Short term Dynamics Low Pivot Price {True or False}
    DTSHVc = ta.valuewhen(bool(DTSHighPivot), high[dPP], 0) // Short term Dynamics High
    DTSLVc = ta.valuewhen(bool(DTSLowPivot), low[dPP], 0) // Short term Dynamics Low
    DTSHIc = ta.valuewhen(bool(DTSHighPivot), bar_index[dPP], 0) // Short term Dynamics High
    DTSLIc = ta.valuewhen(bool(DTSLowPivot), bar_index[dPP], 0) // Short term Dynamics Low
    DTSHVp = ta.valuewhen(bool(DTSHighPivot), high[dPP], 1) // Short term Dynamics High
    DTSLVp = ta.valuewhen(bool(DTSLowPivot), low[dPP], 1) // Short term Dynamics Low
    DTSHIp = ta.valuewhen(bool(DTSHighPivot), bar_index[dPP], 1) // Short term Dynamicss High
    DTSLIp = ta.valuewhen(bool(DTSLowPivot), bar_index[dPP], 1) // Short term Dynamics Low   
    var line sHLL = na
    var line sLLL = na
    var label sHLLl = na
    var label sLLLl = na
    var line dHLL = na
    var line dLLL = na
    var label dHLLl = na
    var label dLLLl = na
    //STATICS/////////////////////////////////////////////////////////////////////////
    if STSHIc != STSHIc[1] and STSHVc <= STSHVp and STSHIc - STSHIp >= 8 and ShowHLLs
        if math.abs((STSHVp - STSHVc) / ATR[sPP]) <= SRs
            sHLL := line.new(x1 = STSHIp, y1 = STSHVp, x2 = STSHIc, y2 = STSHVp, color = color.rgb(18, 123, 184, 43), style = line.style_dotted)
            sHLLl := label.new(x = math.round((STSHIp + STSHIc) / 2), y = STSHVp - ATR / 2, text = '2 Top Liq', color = color.rgb(255, 255, 255, 100), textcolor = color.rgb(18, 123, 184), style = label.style_label_down, size = LabelSize)
            sHLLl
    if STSLIc != STSLIc[1] and STSLVc >= STSLVp and STSLIc - STSLIp >= 8 and ShowLLLs
        if math.abs((STSLVp - STSLVc) / ATR[sPP]) <= SRs
            sLLL := line.new(x1 = STSLIp, y1 = STSLVp, x2 = STSLIc, y2 = STSLVp, color = color.rgb(162, 10, 233, 45), style = line.style_dotted)
            sLLLl := label.new(x = math.round((STSLIp + STSLIc) / 2), y = STSLVp + ATR / 2, text = '2 Bottom Liq', color = color.rgb(255, 255, 255, 100), textcolor = color.rgb(162, 10, 233), style = label.style_label_up, size = LabelSize)
            sLLLl
    //DYNAMICS/////////////////////////////////////////////////////////////////////////
    if DTSHIc != DTSHIc[1] and DTSHVc <= DTSHVp and DTSHIc - DTSHIp >= 4 and ShowHLLd
        if math.abs((DTSHVp - DTSHVc) / ATR[dPP]) >= SRd and math.abs((DTSHVp - DTSHVc) / ATR[dPP]) <= 1.95
            dHLL := line.new(x1 = DTSHIp, y1 = DTSHVp, x2 = DTSHIc, y2 = DTSHVc, color = color.rgb(18, 123, 184, 44), style = line.style_dotted)
            dHLLl := label.new(x = math.round((DTSHIp + DTSHIc) / 2) + 2, y = (DTSHVp + DTSHVc) / 2 - ATR / 4, text = 'DLiq', color = color.rgb(255, 255, 255, 100), textcolor = color.rgb(18, 123, 184), style = label.style_label_down, size = LabelSize)
            dHLLl

    if DTSLIc != DTSLIc[1] and DTSLVc >= DTSLVp and DTSLIc - DTSLIp >= 4 and ShowLLLd
        if math.abs((DTSLVp - DTSLVc) / ATR[dPP]) >= SRd and math.abs((DTSLVp - DTSLVc) / ATR[dPP]) <= 1.95
            dLLL := line.new(x1 = DTSLIp, y1 = DTSLVp, x2 = DTSLIc, y2 = DTSLVc, color = color.rgb(162, 10, 233, 45), style = line.style_dotted)
            dLLLl := label.new(x = math.round((DTSLIp + DTSLIc) / 2) + 2, y = (DTSLVp + DTSLVp) / 2 + ATR / 4, text = 'DLiq', color = color.rgb(255, 255, 255, 100), textcolor = color.rgb(162, 10, 233), style = label.style_label_up, size = LabelSize)
            dLLLl

    if math.abs(line.get_x2(sHLL[1]) - line.get_x1(sHLL)) <= 2
        line.delete(sHLL)
        label.delete(sHLLl[1])
        line.set_x2(sHLL[1], STSHIc)
        label.set_text(sHLLl, '3 Top Liq')
        label.set_x(sHLLl, math.abs((line.get_x1(sHLL[1]) + line.get_x2(sHLL[1])) / 2))
        label.set_size(sHLLl, LabelSize)

    if math.abs(line.get_x2(sLLL[1]) - line.get_x1(sLLL)) <= 2
        line.delete(sLLL)
        label.delete(sLLLl[1])
        line.set_x2(sLLL[1], STSLIc)
        label.set_text(sLLLl, '3 Top Liq')
        label.set_x(sLLLl, math.abs((line.get_x1(sLLL[1]) + line.get_x2(sLLL[1])) / 2))
        label.set_size(sLLLl, LabelSize)

    if math.abs(line.get_x2(dHLL[1]) - line.get_x1(dHLL)) <= dPP * 2 + 1
        line.delete(dHLL)
        label.delete(dHLLl[1])
        line.set_xy2(dHLL[1], DTSHIc, DTSHVc)
        label.set_xy(dHLLl, math.abs((line.get_x1(dHLL[1]) + line.get_x2(dHLL[1])) / 2 + 2), (line.get_y1(dHLL[1]) + line.get_y2(dHLL[1])) / 2)
        label.set_size(dHLLl, LabelSize)

    if math.abs(line.get_x2(dLLL[1]) - line.get_x1(dLLL)) <= dPP * 2 + 1
        line.delete(dLLL)
        label.delete(dLLLl[1])
        line.set_xy2(dLLL[1], DTSLIc, DTSLVc)
        label.set_xy(dLLLl, math.abs((line.get_x1(dLLL[1]) + line.get_x2(dLLL[1])) / 2 + 2), (line.get_y1(dLLL[1]) + line.get_y2(dLLL[1])) / 2)
        label.set_size(dLLLl, LabelSize)
````
