<!-- tradingview-pine-id: PUB;a0621bf0ea92454c84817df504c0d7ee -->
<!-- tradingviewscripts-format: 1 -->
# FVGDetectorLibrary

Source: https://www.tradingview.com/script/xtPwNZUu/

## Description

Library  "FVGDetectorLibrary"
TODO: add library description here

FVGDetector(FVGFilter, FVGFilterType, ShowDeFVG, ShowSuFVG, DeFVGColor, SuFVGColor, ShowMitigatedFVG)
  Parameters:
    FVGFilter (string)
    FVGFilterType (string)
    ShowDeFVG (bool)
    ShowSuFVG (bool)
    DeFVGColor (color)
    SuFVGColor (color)
    ShowMitigatedFVG (bool)

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab (modified: added customizable FVG colors + show/hide mitigated FVG toggle)

//@version=6

// @description TODO: add library description here
library('FVGDetectorLibrary', overlay = true)

// 追加した引数:
//   DeFVGColor       : Demand(買い)FVGのゾーン色。デフォルトは元コードと同じ #a9d60580
//   SuFVGColor       : Supply(売り)FVGのゾーン色。デフォルトは元コードと同じ #ff7d044d
//   ShowMitigatedFVG : true = 埋まった(ミティゲートされた)FVGもそのまま表示し続ける(元の挙動)
//                      false = 価格がFVGの近い境界まで戻ってきた時点でそのFVGを削除して非表示にする
export FVGDetector(string FVGFilter, string FVGFilterType, bool ShowDeFVG, bool ShowSuFVG, color DeFVGColor = #a9d60580, color SuFVGColor = #ff7d044d, bool ShowMitigatedFVG = true) =>
    var float DDFVG = 0.0 //Demand Distal Fair Value Gap
    var float DPFVG = 0.0 //Demand Proximal Fair Value Gap
    var int BarDFVG = 0 //Bar Index Demand Fair Value Gap

    var float SDFVG = 0.0 //Supply Distal Fair Value Gap
    var float SPFVG = 0.0 //Supply Proximal Fair Value Gap
    var int BarSFVG = 0 //Bar Index Supply Fair Value Gap

    var line DDistal = na
    var line DProximal = na
    var linefill Dfillline = na

    var line SDistal = na
    var line SProximal = na
    var linefill Sfillline = na

    var label DFVGLabel = na
    var label SFVGLabel = na

    var bool DMitigated = true
    var bool SMitigated = true

    var bool DConditionFVG = false
    var bool SConditionFVG = false
    //ATR
    ATR = ta.atr(55)
    //Demand FVG Filter Method {Choose and switch}
    DConditionFVG := if FVGFilter == 'Off'
        if low > high[2]
            true
        else
            false

    else if FVGFilter == 'On'
        if FVGFilterType == 'Very Aggressive' and low > high[2] and high > high[1]
            true
        else if FVGFilterType == 'Aggressive' and low > high[2] and high[1] - low[1] >= 1.0 * ATR and high > high[1]
            true
        else if FVGFilterType == 'Defensive' and low > high[2] and high[1] - low[1] >= 1.5 * ATR and high > high[1] and (close[2] - open[2] > 0 and close[1] - open[1] > 0 or math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7)
            true
        else if FVGFilterType == 'Very Defensive' and low > high[2] and high[1] - low[1] >= 1.5 * ATR and high > high[1] and close[2] - open[2] > 0 and close[1] - open[1] > 0 and math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7 and math.abs((close[2] - open[2]) / (high[2] - low[2])) > 0.35 and math.abs((close - open) / (high - low)) > 0.35
            true
        else
            false

    //Supply FVG Filter Method {Choose and switch}
    SConditionFVG := if FVGFilter == 'Off'
        if high < low[2]
            true
        else
            false
    else if FVGFilter == 'On'
        if FVGFilterType == 'Very Aggressive' and high < low[2] and low[1] > low
            true
        else if FVGFilterType == 'Aggressive' and high < low[2] and high[1] - low[1] >= 1.0 * ATR and low[1] > low
            true
        else if FVGFilterType == 'Defensive' and high < low[2] and high[1] - low[1] >= 1.5 * ATR and low[1] > low and (close[2] - open[2] < 0 and close[1] - open[1] < 0 or math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7)
            true
        else if FVGFilterType == 'Very Defensive' and high < low[2] and high[1] - low[1] >= 1.5 * ATR and low[1] > low and close[2] - open[2] < 0 and close[1] - open[1] < 0 and math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7 and math.abs((close[2] - open[2]) / (high[2] - low[2])) > 0.35 and math.abs((close - open) / (high - low)) > 0.35
            true
        else
            false
    //Supply and Demand Fair Value Gap Detector
    //Demand FVG Detector
    if DConditionFVG
        DDFVG := high[2]
        DPFVG := low
        BarDFVG := bar_index
        BarDFVG

    //Supply FVG Detector
    if SConditionFVG
        SDFVG := low[2]
        SPFVG := high
        BarSFVG := bar_index
        BarSFVG


    if DConditionFVG and ShowDeFVG
        DDistal := line.new(BarDFVG, DDFVG, BarDFVG, DDFVG, color = color.rgb(0, 0, 0), style = line.style_dotted, width = 1)
        DProximal := line.new(BarDFVG, DPFVG, BarDFVG, DPFVG, color = color.rgb(0, 0, 0), style = line.style_dotted, width = 1)
        Dfillline := linefill.new(DDistal, DProximal, color = DeFVGColor)
        DFVGLabel := label.new(BarDFVG, DDFVG, text = 'FVG', style = label.style_label_up, color = color.rgb(255, 255, 255, 100), textcolor = #000000, textalign = text.align_center, size = size.small)
        DFVGLabel
    if (low > DDFVG or DDFVG == DDFVG[1]) and DMitigated == true
        line.set_x2(DDistal, bar_index + 1)
        line.set_x2(DProximal, bar_index + 1)
        label.set_x(DFVGLabel, math.round((BarDFVG + bar_index) / 2))
    if low[1] >= DPFVG and low <= DPFVG
        DMitigated := false
        // 埋まったFVGを非表示にする設定の場合、ここで削除する
        if not ShowMitigatedFVG
            line.delete(DDistal)
            line.delete(DProximal)
            linefill.delete(Dfillline)
            label.delete(DFVGLabel)
    if DConditionFVG
        DMitigated := true
        DMitigated
    //Supply FVG Detector
    if SConditionFVG and ShowSuFVG

        SDistal := line.new(BarSFVG, SDFVG, BarSFVG + 10, SDFVG, color = color.rgb(0, 0, 0), style = line.style_dotted, width = 1)
        SProximal := line.new(BarSFVG, SPFVG, BarSFVG + 10, SPFVG, color = color.rgb(0, 0, 0), style = line.style_dotted, width = 1)
        Sfillline := linefill.new(SDistal, SProximal, color = SuFVGColor)
        SFVGLabel := label.new(BarSFVG, SDFVG, text = 'FVG', style = label.style_label_down, color = color.rgb(255, 255, 255, 100), textcolor = #000000, textalign = text.align_center, size = size.small)
        SFVGLabel
    if (high < SDFVG or SDFVG == SDFVG[1]) and SMitigated == true
        line.set_x2(SDistal, bar_index + 1)
        line.set_x2(SProximal, bar_index + 1)
        label.set_x(SFVGLabel, math.round((BarSFVG + bar_index) / 2))
    if high >= SPFVG and high[1] <= SPFVG
        SMitigated := false
        // 埋まったFVGを非表示にする設定の場合、ここで削除する
        if not ShowMitigatedFVG
            line.delete(SDistal)
            line.delete(SProximal)
            linefill.delete(Sfillline)
            label.delete(SFVGLabel)
    if SConditionFVG
        SMitigated := true
        SMitigated
    [DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG]
````
