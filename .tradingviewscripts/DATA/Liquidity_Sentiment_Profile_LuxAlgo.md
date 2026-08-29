<!-- tradingview-pine-id: PUB;71a29148daa540918974b7a345527800 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sentiment Profile [LuxAlgo]

Source: https://www.tradingview.com/script/asr7nOb2-Liquidity-Sentiment-Profile-LuxAlgo/

## Description

The Liquidity Sentiment Profile is an advanced charting tool that measures by combining PRICE and VOLUME data over specified anchored periods and highlights within a sequence of profiles the distribution of the liquidity and the market sentiment at specific price levels.

The Liquidity Sentiment Profile allows traders to reveal significant price levels, dominant market sentiment, support and resistance levels, supply and demand zones, liquidity availability levels, liquidity gaps, consolidation zones, and more based on price and volume data.

Liquidity refers to the availability of orders at specific price levels in the market, allowing transactions to occur smoothly.

🔶 USAGE

[image]https://www.tradingview.com/x/CjLLbGwZ/[/image]

A Liquidity Sentiment Profile is a combination of a liquidity and a sentiment profile, where the right part of the profile displays the distribution of the traded activity at different price levels and the left part displays the market sentiment at those price levels.

The Liquidity Sentiment Profiles are visualized with different colors, where each color has a different meaning.

[image]https://www.tradingview.com/x/ryYKRArD/[/image]

The Liquidity Sentiment Profiles aim to present Value Areas based on the significance of price levels, thus allowing users to identify value areas that can be formed more than once within the range of a single profile.

[image]https://www.tradingview.com/x/lAbsEsl5/[/image]

Level of Significance Line - displays the changes in the price levels with the highest traded activity (developing POC)

[image]https://www.tradingview.com/x/mFyAOgJx/[/image]

🔶 SETTINGS

The script takes into account user-defined parameters and plots the profiles, where detailed usage for each user-defined input parameter in indicator settings is provided with the related input's tooltip.

🔹 Liquidity Sentiment Profiles

[*]Anchor Period: The indicator resolution is set by the input of the Anchor Period, the default option is AUTO. 

🔹 Liquidity Profile Settings

[*]Liquidity Profile: Toggles the visibility of the Liquidity Profiles 
[*]High Traded Nodes: Threshold and Color option for High Traded Nodes
[*]Average Traded Nodes: Color option for Average Traded Nodes
[*]Low Traded Nodes: Threshold and Color option for Low Traded Nodes

🔹 Sentiment Profile Settings

[*]Sentiment Profile: Toggles the visibility of the Sentiment Profiles
[*]Bullish Nodes: Color option for Bullish Nodes
[*]Bearish Nodes: Color option for Bearish Nodes

🔹 Other Settings

[*]Level of Significance: Toggles the visibility of the Level of Significance Line
[*]Profile Price Levels: Toggles the visibility of the Profile Price Levels
[*]Number of Rows: Specify how many rows each profile histogram will have. Caution, having it set to high values will quickly hit Pine Script™ drawing objects limit and fewer historical profiles will be displayed  
[*]Profile Width %: Alters the width of the rows in the histogram, relative to the profile length
[*]Profile Range Background Fill: Toggles the visibility of the Profiles Range

🔶 LIMITATIONS

The amount of drawing objects that can be used is limited, as such using a high number of rows can display fewer historical profiles and occasionally incomplete profiles.

🔶 RELATED SCRIPTS

🔹 [Buyside-Sellside-Liquidity](https://www.tradingview.com/script/Qk4vBbfL-Buyside-Sellside-Liquidity-LuxAlgo/)
🔹 [ICT-Concepts](https://www.tradingview.com/script/ib4uqBJx-ICT-Concepts-LuxAlgo/)
🔹 [Swing-Volume-Profiles](https://www.tradingview.com/script/Ai8Heos2-Swing-Volume-Profiles-LuxAlgo/)

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo
 
//@version=5

indicator("Liquidity Sentiment Profile [LuxAlgo]", "LuxAlgo - Liquidity Sentiment Profile", true, max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 500)

//------------------------------------------------------------------------------
// Settings
//-----------------------------------------------------------------------------{

rpGR   = 'Rainbow Profiles'
tfTP   = 'The indicator resolution is set by the input of the Anchor Period. If the Anchor Period is set to AUTO (the default value), then the increased resolution is determined by the following algorithm:\n\n' +
          ' - for intraday resolutions up to 4 Hour, DAY (1D) is used\n - for intraday resolutions equal to 4 Hour, WEEK (1W) is used\n - for daily resolutions MONTH is used (1M)\n - for weekly resolution, 3-MONTH (3M) is used\n - for monthly resolution, 12-MONTH (12M) is used\n\n' +
          'Note : Difference between Session and Day\n - Day will take into account extended hours (if present on the chart), whereas\n - Session will assume only regular trading hours. Session is default value for AUTO Anchor Period'
tfIN   = input.string('Auto', 'Anchor Period', options=['Auto', 'Session', 'Day', 'Week', 'Month', 'Quarter', 'Year'], group = rpGR, tooltip = tfTP)
tfOT   = tfIN == 'Session' or tfIN == 'Day' ? 'D' : tfIN == 'Week' ? 'W' : tfIN == 'Month' ? 'M' : tfIN == 'Quarter' ? '3M' : tfIN == 'Year' ? '12M' : timeframe.isintraday and timeframe.period != '240' ? 'D' : timeframe.period == '240' ? 'W' : timeframe.isdaily ? 'M' : timeframe.isweekly ? '3M' : '12M'

vpGR   = 'Liquidity Profile Settings'
vpTP   = 'displays total trading activity (common interest, both buying and selling trading activity) over a specified time period at specific price levels\n\n' +
          ' - high traded node rows : high trading activity price levels - usually represents consolidation levels (value areas)\n' +
          ' - average traded node rows : average trading activity price levels\n' +
          ' - low traded node rows : low trading activity price levels - usually represents supply & demand levels or liquidity levels\n\n' +
          'row lengths, indicates the amount of the traded activity at specific price levels' 
vpSH   = input.bool(true, 'Liquidity Profile', group = vpGR, tooltip = vpTP)
vpHVC  = input.color(color.new(#ff9800, 81), 'High Traded Nodes', inline='VP1', group = vpGR)
vpHVT  = input.int(73, 'Threshold %' , minval = 50, maxval = 99 , step = 1,inline='VP1', group = vpGR, tooltip = 'option range [50-99]') / 100
vpAVC  = input.color(color.new(#787b86, 81), 'Average Traded Nodes', group = vpGR)
vpLVC  = input.color(color.new(#2962ff, 81), 'Low Traded Nodes', inline='VP2', group = vpGR)
vpLVT  = input.int(21, 'Threshold %' , minval = 10, maxval = 40 , step = 1,inline='VP2', group = vpGR, tooltip = 'option range [10-40]') / 100

spGR   = 'Sentiment Profile Settings'
spTP   = 'displays the sentiment, the dominat party over a specified time period at the specific price levels\n\n' +
          ' - bullish node rows : buying trading activity is higher\n'  +
          ' - barish node rows : selling trading activity is higher\n\n' +
          'row lengths, indicates the strength of the buyers/sellers at the specific price levels' 
spSH   = input.bool(true, 'Sentiment Profile', group = spGR, tooltip = spTP)
spBLC  = input.color(color.new(#26a69a, 81), 'Bullish Nodes', inline='SP', group = spGR)
spBRC  = input.color(color.new(#ef5350, 81), 'Bearish Nodes', inline='SP', group = spGR)

othGR  = 'Other Settings'
pcTP   = 'displays the changes of the price levels with the highest traded activity'
rpPC   = input.bool(false, 'Level of Significance', inline='PoC', group = othGR, tooltip = pcTP)
rpPCC  = input.color(color.new(#ff0000, 0), '', inline='PoC', group = othGR)
rpPCW  = input.int(2, '', inline='PoC', group = othGR)

rpPL   = input.bool(false, 'Profile Price Levels', inline = 'BBe', group = othGR)
rpPLC  = input.color(color.new(#00bcd4, 0), '', inline = 'BBe', group = othGR)
rpLS   = input.string('Small', "", options=['Tiny', 'Small', 'Normal'], inline = 'BBe', group = othGR)

rpNR   = input.int(25, 'Number of Rows' , minval = 10, maxval = 100 ,step = 5, group = othGR, tooltip = 'option range [10-100]')
rpW    = input.int(50, 'Profile Width %', minval = 10, maxval = 50, group = othGR, tooltip = 'option range [10-50]') / 100

rpBG   = input.bool(true, 'Profile Range Background Fill', inline = 'BG', group = othGR)
rpBGC  = input.color(color.new(#00bcd4, 95), '', inline = 'BG', group = othGR)

//-----------------------------------------------------------------------------}
// User Defined Types
//-----------------------------------------------------------------------------{

// @type        bar properties with their values 
//
// @field o     (float) open price of the bar
// @field h     (float) high price of the bar
// @field l     (float) low price of the bar
// @field c     (float) close price of the bar
// @field v     (float) volume of the bar
// @field i     (int) index of the bar

type bar
    float o = open
    float h = high
    float l = low
    float c = close
    float v = volume
    int   i = bar_index

//-----------------------------------------------------------------------------}
// Variables
//-----------------------------------------------------------------------------{

bar b = bar.new()

rpVST = array.new_float(rpNR + 1, 0.)
rpVSB = array.new_float(rpNR + 1, 0.)
rpVSD = array.new_float(rpNR + 1, 0.)

aRP   = array.new_box()
aPC   = array.new_line()
lRP   = array.new_label()
var dRP = array.new_box()
var dPC = array.new_line()

var x1 = 0
var x2 = 0
var float pir = na, var float eki = na

//-----------------------------------------------------------------------------}
// Functions/methods
//-----------------------------------------------------------------------------{

// @function        calculates htf highest and lowest price value 
//                     
// @param _tf       (strings) timeframe value
// @param _tfi      (strings) session specific timeframe value
//
// @returns         [float, float] highest and lowest price value

f_htfHL(_tf, _tfi) =>
    var h  = 0., var l  = 0.
    var hx = 0., var lx = 0.

    chg = _tf == 'D' and _tfi == 'Day' ? dayofweek != dayofweek[1] : ta.change(time(_tf))
    if chg
        hx := h
        h  := b.h
        lx := l
        l  := b.l
    else
        h := math.max(b.h, h)
        l := math.min(b.l, l)

    [hx, lx]

// @function        creates new label object and updates existing label objects 
//                     
// @param           details in Pine Script™ language reference manual
//
// @returns         none, updated visual objects (labels)

f_drawLabelX(_x, _y, _text, _style, _textcolor, _size, _tooltip) =>
    var lb = label.new(_x, _y, _text, xloc.bar_index, yloc.price, color(na), _style, _textcolor, _size, text.align_left, _tooltip)
    lb.set_xy(_x, _y)
    lb.set_text(_text)
    lb.set_tooltip(_tooltip)
    lb.set_textcolor(_textcolor)

//-----------------------------------------------------------------------------}
// Calculations
//-----------------------------------------------------------------------------{

bull = b.c > b.o
nzV  = nz(b.v)

rpS = switch rpLS
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal

if tfOT == 'D' and tfIN == 'Day' ? dayofweek != dayofweek[1] : ta.change(time(tfOT))
    x1 := x2
    x2 := b.i

rpLN = x2 - x1
[pHST, pLST] = f_htfHL(tfOT, tfIN)
pSTP = (pHST - pLST) / rpNR

vRPI = last_bar_index - b.i <= (math.round(500 / (spSH ? rpNR * 2 : rpNR)) - 1) * rpLN

proceed = tfOT == 'D' and tfIN == 'Day' ? dayofweek != dayofweek[1] : ta.change(time(tfOT))

if proceed and nzV and timeframe.period != tfOT and not timeframe.isseconds and pSTP > 0 and b.i > rpLN
    
    if dRP.size() > 0
        for i = 0 to dRP.size() - 1
            box.delete(dRP.shift())

    for bI = rpLN to 1 //1 to rpLN
        l = 0
        for pLL = pLST to pHST by pSTP
            if b.h[bI] >= pLL and b.l[bI] < pLL + pSTP
                rpVST.set(l, rpVST.get(l) + nzV[bI] * ((b.h[bI] - b.l[bI]) == 0 ? 1 : pSTP / (b.h[bI] - b.l[bI])) )
                
                if bull[bI] and spSH
                    rpVSB.set(l, rpVSB.get(l) + nzV[bI] * ((b.h[bI] - b.l[bI]) == 0 ? 1 : pSTP / (b.h[bI] - b.l[bI])) )
            l += 1
            
        if rpPC and vRPI
            if bI == rpLN
                aPC.push(line.new(b.i[bI] - 1, eki, b.i[bI], pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP, color = rpPCC, width = rpPCW))
                pir := pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP
            else
                aPC.push(line.new(b.i[bI] - 1, pir, b.i[bI], pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP, color = rpPCC, width = rpPCW))
                pir := pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP
            
    eki := pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP

    for l = 0 to rpNR - 1
        bbp = 2 * rpVSB.get(l) - rpVST.get(l)
        rpVSD.set(l, rpVSD.get(l) + bbp * (bbp > 0 ? 1 : -1) )

    if rpBG
        aRP.push(box.new(b.i - rpLN, pLST, b.i, pHST, rpBGC, 1, line.style_dotted, bgcolor = rpBGC ))
    
    if rpPL and vRPI
        lRP.push(label.new(b.i - rpLN / 2, pHST, str.tostring(pHST, format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_down, rpPLC, rpS, text.align_left, 'Profile High - ' + str.tostring(pHST, format.mintick) + '\n %' + str.tostring((pHST - pLST) / pLST * 100, '#.##') + ' higher than the Profile Low\n\n# bars : ' + str.tostring(rpLN) ))
        lRP.push(label.new(b.i - rpLN / 2, pLST, str.tostring(pLST, format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_up  , rpPLC, rpS, text.align_left, 'Profile Low - '  + str.tostring(pLST, format.mintick) + '\n %' + str.tostring((pHST - pLST) / pHST * 100, '#.##') + ' lower than the Profile High\n\n# bars : ' + str.tostring(rpLN) ))

    for l = 0 to rpNR - 1
        if vpSH
            sBI = b.i - rpLN / 2
            eBI = sBI + int( rpVST.get(l) / rpVST.max() * rpLN * rpW)
            llC = rpVST.get(l) / rpVST.max() > vpHVT ? vpHVC : rpVST.get(l) / rpVST.max() < vpLVT ? vpLVC : vpAVC
            aRP.push(box.new(sBI, pLST + (l + 0.) * pSTP, eBI, pLST + (l + 1.) * pSTP, llC, bgcolor = llC))

        if spSH
            bbp = 2 * rpVSB.get(l) - rpVST.get(l)
            sBI = b.i - rpLN / 2
            eBI = sBI - int( rpVSD.get(l) / rpVSD.max() * rpLN * rpW)
            aRP.push(box.new(sBI, pLST + (l + 0.) * pSTP, eBI, pLST + (l + 1.) * pSTP, bbp > 0 ? spBLC : spBRC, bgcolor = bbp > 0 ? spBLC : spBRC ))
    
rpLN := barstate.islast ? last_bar_index - x2 : 1
pHST := ta.highest(high, rpLN > 0 ? rpLN : 1)
pLST := ta.lowest (low , rpLN > 0 ? rpLN : 1)
pSTP := (pHST - pLST) / rpNR

if  barstate.islast and nzV and timeframe.period != tfOT and not timeframe.isseconds and rpLN > 0 and pSTP > 0

    if dRP.size() > 0
        for i = 0 to dRP.size() - 1
            box.delete(dRP.shift())

    if dPC.size() > 0
        for i = 0 to dPC.size() - 1
            line.delete(dPC.shift())

    for bI = rpLN to 0
        l = 0
        for pLL = pLST to pHST by pSTP
            if b.h[bI] >= pLL and b.l[bI] < pLL + pSTP
                rpVST.set(l, rpVST.get(l) + nzV[bI] * ((b.h[bI] - b.l[bI]) == 0 ? 1 : pSTP / (b.h[bI] - b.l[bI])) )
                
                if bull[bI] and spSH
                    rpVSB.set(l, rpVSB.get(l) + nzV[bI] * ((b.h[bI] - b.l[bI]) == 0 ? 1 : pSTP / (b.h[bI] - b.l[bI])) )
            l += 1

        if rpPC
            if bI == rpLN
                dPC.push(line.new(b.i[bI] - 1, eki, b.i[bI], pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP, color = rpPCC, width = rpPCW))
                pir := pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP
            else
                dPC.push(line.new(b.i[bI] - 1, pir, b.i[bI], pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP, color = rpPCC, width = rpPCW))
                pir := pLST + (rpVST.indexof(rpVST.max()) + .50) * pSTP

    for l = 0 to rpNR - 1
        bbp  = 2 * rpVSB.get(l) - rpVST.get(l)
        rpVSD.set(l, rpVSD.get(l) + bbp * (bbp > 0 ? 1 : -1) )

    if rpBG
        dRP.push(box.new(b.i - rpLN, pLST, b.i, pHST, rpBGC, bgcolor = rpBGC ))

    if rpPL
        f_drawLabelX(b.i - rpLN / 2, pHST, str.tostring(pHST, format.mintick), label.style_label_down, rpPLC, rpS, 'Profile High - ' + str.tostring(pHST, format.mintick) + '\n %' + str.tostring((pHST - pLST) / pLST * 100, '#.##') + ' higher than the Profile Low\n\nNumber of bars : ' + str.tostring(rpLN))
        f_drawLabelX(b.i - rpLN / 2, pLST, str.tostring(pLST, format.mintick), label.style_label_up  , rpPLC, rpS, 'Profile Low - '  + str.tostring(pLST, format.mintick) + '\n %' + str.tostring((pHST - pLST) / pHST * 100, '#.##') + ' lower than the Profile High\n\nNumber of bars : ' + str.tostring(rpLN))

    for l = 0 to rpNR - 1
        if vpSH
            sBI = b.i - rpLN / 2
            eBI = sBI + int( rpVST.get(l) / rpVST.max() * rpLN * rpW)
            llC = rpVST.get(l) / rpVST.max() > vpHVT ? vpHVC : rpVST.get(l) / rpVST.max() < vpLVT ? vpLVC : vpAVC
            dRP.push(box.new(sBI, pLST + (l + 0.) * pSTP, eBI, pLST + (l + 1.) * pSTP, llC, bgcolor = llC ))

        if spSH
            bbp = 2 * rpVSB.get(l) - rpVST.get(l)
            sBI = b.i - rpLN / 2
            eBI = sBI - int( rpVSD.get(l) / rpVSD.max() * rpLN * rpW)
            dRP.push(box.new(sBI, pLST + (l + 0.) * pSTP, eBI, pLST + (l + 1.) * pSTP, bbp > 0 ? spBLC : spBRC, bgcolor = bbp > 0 ? spBLC : spBRC ))

//-----------------------------------------------------------------------------}
````
