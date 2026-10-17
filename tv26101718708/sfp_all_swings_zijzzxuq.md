# SFP All Swings

- url: https://www.tradingview.com/script/ziJzzXUQ/
- type: indicator
- pine_id: PUB;85031a913af04802a8f8e99bbda8e476
- version: 1.0

## Description

This is a simplified and raw price action focused version of the SFP (Swing Failure Pattern) algorithm originally published by LuxAlgo.

📝 Inspiration & Attribution
This script is built upon the professional SFP detection logic developed by LuxAlgo. In this specific version, we have streamlined the code to focus entirely on core technical SFP requirements and confirmation mechanics. Credit goes to the LuxAlgo team for their original framework.

🛠 Technical Highlights
Raw Price Action Focus: It monitors major swing high and low violations (liquidity grabs) without any external noise, focusing strictly on price behavior.

Wick & Close Logic: Automatically identifies scenarios where the price wicks beyond a prior level but fails to sustain the breakout, closing back inside the range.

Confirmation Engine: Tracks an internal "Confirmation Line." A valid setup is only confirmed once the price closes beyond this specific structural level (marked with ▲/▼).

Auto-Cleanup: To maintain a clean trading environment, the script automatically removes lines and labels for invalidated or expired setups.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator( 'SFP (All Swings - No Filter)', 'SFP ', max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, overlay = true)

//---------------------------------------------------------------------------------------------------------------------}
//Settings
//---------------------------------------------------------------------------------------------------------------------{
len         = input.int      (   5       ,    'Swings'      , minval=  1                                )
bull       = input.bool     ( true      ,  'Bullish SFP'                                               )
bear       = input.bool     ( true      ,  'Bearish SFP'                                               )

dSwingLine = input.bool     (true    ,  'Swing Lines'                      , group=      'Style'       )
dOpposLine = input.bool     (true    ,  'Confirmation Lines'               , group=      'Style'       )
dSFP_Line  = input.bool     (true    ,  'Swing Failure Wick'               , group=      'Style'       )
dSFP_Label = input.bool     (true    ,  'Swing Failure Label'              , group=      'Style'       )
colBl      = input.color     ( #089981  , 'Lines / Labels' , inline='lin' , group=      'Style'       )
colBr      = input.color     ( #f23645  ,  ''              , inline='lin' , group=      'Style'       )
colBl2     = input.color     ( #08998180, 'SFP Wicks      ', inline='wic' , group=      'Style'       )
colBr2     = input.color     ( #f2364580,  ''              , inline='wic' , group=      'Style'       )

//-----------------------------------------------------------------------------}      
//UDT & Variables
//-----------------------------------------------------------------------------{
type piv
    float swing_prc 
    int   swing_bix 
    float oppos_prc 
    int   oppos_bix 
    bool  active    
    bool  confirmed 
    line  swing_line 
    line  oppos_line 
    line  wicky_line
    label wicky_label

type swing 
    int   bix 
    float prc 

n   = bar_index 
INV = color(na)

var swing swingH = swing.new() 
var swing swingL = swing.new() 
var piv pivH     = piv.new()
var piv pivL     = piv.new()

method n(float piv) => not na(piv)

//---------------------------------------------------------------------------------------------------------------------}
//Execution
//---------------------------------------------------------------------------------------------------------------------{
ph = ta.pivothigh(len, 1)
pl = ta.pivotlow (len, 1)

// Mum kapanışı onayı kontrolü (LTF)
is_confirmed = barstate.isconfirmed

//---------------------------------------------------------------------------------------------------------------------}
//Bearish Pattern (Short SFP)
//---------------------------------------------------------------------------------------------------------------------{
if bear
    if ph.n() 
        swingH.bix := n-1 
        swingH.prc := ph 

    sw = swingH.prc
    bx = swingH.bix
    
    // Braid filtresi kaldırıldı: Sadece SFP teknik şartı aranır
    if is_confirmed and high > sw and open < sw and close < sw
        opposL = sw 
        opposB = n
        for i = 1 to n - bx -1
            if low [i] < opposL 
                opposL := low [i]
                opposB := n  - i

        if not pivH.confirmed
            pivH.swing_line .delete()
            pivH.oppos_line .delete()
            pivH.wicky_line .delete()                
            pivH.wicky_label.delete()

        pivH := piv.new(sw, bx, opposL, opposB, true, false)

        if dSwingLine 
            pivH.swing_line  := line.new (bx    , sw    , n, sw    , color=colBr)
        if dOpposLine 
            pivH.oppos_line  := line.new (opposB, opposL, n, opposL, color=colBr, style=line.style_dotted)
        if dSFP_Line 
            pivH.wicky_line  := line.new (n     , high  , n, sw    , color=colBr2, width=3)
        if dSFP_Label  
            pivH.wicky_label := label.new(n     , high, style=label.style_label_down, text='SFP', textcolor=colBr, color=INV, size=size.normal)

    // Onay Çizgisi Kırılımı
    if pivH.active and not pivH.confirmed 
        pivH.swing_line.set_x2(n)
        pivH.oppos_line.set_x2(n)
        if is_confirmed and close < pivH.oppos_prc
            pivH.confirmed := true
            label.new(n, high, style=label.style_label_down, text='▼', textcolor=colBr, color=INV, size=size.normal)

    // İptal Şartı
    if n - pivH.swing_bix > 500 or close > pivH.swing_prc
        pivH.active := false 
        if not pivH.confirmed
            pivH.swing_line .delete(), pivH.oppos_line .delete(), pivH.wicky_line .delete(), pivH.wicky_label.delete() 

//---------------------------------------------------------------------------------------------------------------------}
//Bullish Pattern (Long SFP)
//---------------------------------------------------------------------------------------------------------------------{
if bull
    if pl.n() 
        swingL.bix := n-1 
        swingL.prc := pl 

    sw = swingL.prc
    bx = swingL.bix
    
    // Braid filtresi kaldırıldı: Sadece SFP teknik şartı aranır
    if is_confirmed and low < sw and open > sw and close > sw
        opposH = sw 
        opposB = n
        for i = 1 to n - bx -1
            if high[i] > opposH 
                opposH := high[i]
                opposB := n - i

        if not pivL.confirmed
            pivL.swing_line .delete()
            pivL.oppos_line .delete()
            pivL.wicky_line .delete()                
            pivL.wicky_label.delete()

        pivL := piv.new(sw, bx, opposH, opposB, true, false)

        if dSwingLine 
            pivL.swing_line  := line.new (bx    , sw    , n, sw    , color=colBl )
        if dOpposLine 
            pivL.oppos_line  := line.new (opposB, opposH, n, opposH, color=colBl , style=line.style_dotted)
        if dSFP_Line 
            pivL.wicky_line  := line.new (n     , low   , n, sw    , color=colBl2, width=3)
        if dSFP_Label  
            pivL.wicky_label := label.new(n     , low, style=label.style_label_up, text='SFP', textcolor=colBl, color=INV, size=size.normal)

    if pivL.active and not pivL.confirmed 
        pivL.swing_line.set_x2(n)
        pivL.oppos_line.set_x2(n)
        if is_confirmed and close > pivL.oppos_prc
            pivL.confirmed := true
            label.new(n, low, style=label.style_label_up, text='▲', textcolor=colBl, color=INV, size=size.normal)

    if n - pivL.swing_bix > 500 or close < pivL.swing_prc
        pivL.active := false 
        if not pivL.confirmed
            pivL.swing_line .delete(), pivL.oppos_line .delete(), pivL.wicky_line .delete(), pivL.wicky_label.delete()
````
