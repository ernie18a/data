<!-- tradingview-pine-id: PUB;77173a1d672d4000b42448463ea78dac -->
<!-- tradingviewscripts-format: 1 -->
# Divergence-Support/Resistence

Source: https://www.tradingview.com/script/UkaoD896-Divergence-Support-Resistence/

## Description

Another script based on zigzag, divergence, and to yield support and resistence levels.

This idea started with below two concepts:

▶ Support and resistence are simply levels where price has rejected to go further down or up. Usually, we can derive this based on pivots. But, if we start looking at every pivot, there will be many of them and may be confusing to understand which one to consider.

▶ Lot of people asked about one of my previous script on divergence detector on how to use it. I believe divergence should be considered as area of support and resistence because, they only amount to temporary weakness in momentum and nothing more.  As per my understanding

Trend > Hidden Divergence > Divergence > Oscillator Levels of Overbought and Oversold

⬜  Process

▶ Now combining the above two concepts - what we are trying to do here is draw support resistence lines only on pivots which has observed either divergence or hidden divergence. Continuation and indecision pivots are ignored.
▶ Input requires only few parameters.
[https://www.tradingview.com/x/7NwMSUNj/](https://www.tradingview.com/x/7NwMSUNj/)

Zigzag lengths and oscillator to be used. Oscillator periods are automatically calculated based on zigzag length. Hence no other information required. You can also chose custom oscillator via external source.

▶ Display include horizontal lines of support/resistence which are drawn from the candle from where divergence or hidden divergence is detected. 
▶ Support resistence lines are colored based on divergence. Green shades for bullish divergence and bullish hidden divergence whereas red shades for bearish divervence and bearish hidden divergence. Please note, red and green lines does not mean they only provide resistence or support. Any lines which are below the price should be treated as support and any line which are above the price should be treated as resistence.
▶ Divergence symbols are also printed on the bar from where divergence/hidden divergence is detected.

[*] ↗ - Bullish Hidden Divergence
[*] ↘ - Bearish Hidden Divergence
[*] ⤴ - Bullish Divergence
[*] ⤵ - Bearish Divergence

▶ Script also demonstrates usage of libraries effectively. I have used following libraries in this code.

[pine]
import HeWhoMustNotBeNamed/ zigzag /2 as  zg 
import HeWhoMustNotBeNamed/enhanced_ta/8 as eta
import HeWhoMustNotBeNamed/ supertrend /4 as st
[/pine]

Can be good combination to use it with harmonic patterns.
[https://www.tradingview.com/x/Rkx0SiM5/](https://www.tradingview.com/x/Rkx0SiM5/)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//   __    __            __       __  __                  __       __                        __      __    __              __      _______             __    __                                          __ 
//  /  |  /  |          /  |  _  /  |/  |                /  \     /  |                      /  |    /  \  /  |            /  |    /       \           /  \  /  |                                        /  |
//  $$ |  $$ |  ______  $$ | / \ $$ |$$ |____    ______  $$  \   /$$ | __    __   _______  _$$ |_   $$  \ $$ |  ______   _$$ |_   $$$$$$$  |  ______  $$  \ $$ |  ______   _____  ____    ______    ____$$ |
//  $$ |__$$ | /      \ $$ |/$  \$$ |$$      \  /      \ $$$  \ /$$$ |/  |  /  | /       |/ $$   |  $$$  \$$ | /      \ / $$   |  $$ |__$$ | /      \ $$$  \$$ | /      \ /     \/    \  /      \  /    $$ |
//  $$    $$ |/$$$$$$  |$$ /$$$  $$ |$$$$$$$  |/$$$$$$  |$$$$  /$$$$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |$$$$$$/   $$    $$< /$$$$$$  |$$$$  $$ | $$$$$$  |$$$$$$ $$$$  |/$$$$$$  |/$$$$$$$ |
//  $$$$$$$$ |$$    $$ |$$ $$/$$ $$ |$$ |  $$ |$$ |  $$ |$$ $$ $$/$$ |$$ |  $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$ |  $$ | __ $$$$$$$  |$$    $$ |$$ $$ $$ | /    $$ |$$ | $$ | $$ |$$    $$ |$$ |  $$ |
//  $$ |  $$ |$$$$$$$$/ $$$$/  $$$$ |$$ |  $$ |$$ \__$$ |$$ |$$$/ $$ |$$ \__$$ | $$$$$$  |  $$ |/  |$$ |$$$$ |$$ \__$$ |  $$ |/  |$$ |__$$ |$$$$$$$$/ $$ |$$$$ |/$$$$$$$ |$$ | $$ | $$ |$$$$$$$$/ $$ \__$$ |
//  $$ |  $$ |$$       |$$$/    $$$ |$$ |  $$ |$$    $$/ $$ | $/  $$ |$$    $$/ /     $$/   $$  $$/ $$ | $$$ |$$    $$/   $$  $$/ $$    $$/ $$       |$$ | $$$ |$$    $$ |$$ | $$ | $$ |$$       |$$    $$ |
//  $$/   $$/  $$$$$$$/ $$/      $$/ $$/   $$/  $$$$$$/  $$/      $$/  $$$$$$/  $$$$$$$/     $$$$/  $$/   $$/  $$$$$$/     $$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/ $$/  $$/  $$/  $$$$$$$/  $$$$$$$/ 
//                                                                                                                                                                                                          
//                                                                                                                                                                                                          
//
//@version=5
indicator("Divergence-Support/Resistence", shorttitle="DSR", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=500)
import HeWhoMustNotBeNamed/zigzag/3 as zg
import HeWhoMustNotBeNamed/enhanced_ta/8 as eta
import HeWhoMustNotBeNamed/supertrend/4 as st

maxItems = input.int(10, step=5, title="Max Depth")

showZigzag1 = input.bool(true, "", group="Zigzag", inline="z1")
zigzag1Length = input.int(8, "", group="Zigzag", inline="z1")

showZigzag2 = input.bool(true, "", group="Zigzag", inline="z2")
zigzag2Length = input.int(13, "", group="Zigzag", inline="z2")

var useAlternativeSource = true
source = close

oscillatorType = input.string('rsi', title='Oscillator Source       ', options=["cci", "cmo", "cog", "mfi", "roc", "rsi", "stoch", "tsi", "wpr"], group='Oscillator', inline='osc')
useExternalSource = input.bool(false, title='External Source', group='Oscillator', inline="osce")
externalSource = input.source(close, title='', group='Oscillator', inline="osce")

var history = 1
var waitForClose = true
var atrMaType = "rma"
var atrMultiplier = 1

add_to_array(arr, val, maxItems)=>
    array.unshift(arr, val)
    if(array.size(arr) > maxItems)
        array.pop(arr)

add_to_line_array(arr, val, maxItems)=>
    array.unshift(arr, val)
    if(array.size(arr) > maxItems)
        line.delete(array.pop(arr))

add_to_label_array(arr, val, maxItems)=>
    array.unshift(arr, val)
    if(array.size(arr) > maxItems)
        label.delete(array.pop(arr))
        
getSentimentDetails(sentiment) =>
    [sentimentSymbol, sentimentColor] = switch sentiment
        4 => ['⬆', color.green]
        -4 => ['⬇', color.red]
        3 => ['↗', color.lime]
        -3 => ['↘', color.orange]
        2 => ['⤴',color.rgb(202, 224, 13, 0)]
        -2 => ['⤵',color.rgb(250, 128, 114, 0)] 
        => ['▣', color.silver]
    [sentimentSymbol, sentimentColor]

plot_support_resistence(showZigzag, zigzagLength, srArray, lnArray, lblArray, maxItems, largest)=>
    if(showZigzag)
        length = zigzagLength * 3
        longLength = zigzagLength*5
        atrLength = zigzagLength*5
        [oscillator, overbought, oversold] = eta.oscillator(oscillatorType, length, length, longLength)
        [dir_zigzag, supertrend] = st.supertrend_zigzag(length=zigzagLength, history = history, useAlternativeSource = useAlternativeSource, alternativeSource=source,
                                         waitForClose=waitForClose, atrlength=atrLength, multiplier=atrMultiplier, atrMaType=atrMaType)
        [zigzagpivots, zigzagpivotbars, zigzagpivotdirs, zigzagpivotratios, zigzagoscillators,
                                             zigzagoscillatordirs, zigzagtrendbias, zigzagdivergence, 
                                             newPivot, doublePivot] = 
                                             zg.zigzag(zigzagLength, oscillatorSource=useExternalSource ? externalSource : oscillator, directionBias = dir_zigzag)
        if(array.size(zigzagpivots)>1)
            price = array.get(zigzagpivots, 1)
            divergence = array.get(zigzagdivergence, 1)
            
            if(math.abs(divergence) == 2 or math.abs(divergence) == 3)
                if(array.indexof(srArray, price) == -1)
                    add_to_array(srArray, price, maxItems)
                    [sentimentSymbol, sentimentColor] = getSentimentDetails(divergence)
                    lblSize = largest? size.normal : size.small
                    lnStyle = largest? line.style_solid : line.style_dashed
                    ln = line.new(time, price, time+1, price, extend=extend.right, xloc=xloc.bar_time, color=sentimentColor, style=lnStyle, width=largest? 1 : 0)
                    lbl = label.new(time, price, sentimentSymbol, color=sentimentColor, xloc=xloc.bar_time, textcolor=sentimentColor, style=label.style_none, yloc=yloc.price, size=lblSize)
                    add_to_line_array(lnArray, ln, maxItems)
                    add_to_label_array(lblArray, lbl, maxItems)

var srArray1 = array.new_float()
var srArray2 = array.new_float()

var lnArray1 = array.new_line()
var lblArray1 = array.new_label()

var lnArray2 = array.new_line()
var lblArray2 = array.new_label()

plot_support_resistence(showZigzag1, zigzag1Length, srArray1, lnArray1, lblArray1, maxItems, zigzag1Length>zigzag2Length)
plot_support_resistence(showZigzag2, zigzag2Length, srArray2, lnArray2, lblArray2, maxItems, zigzag2Length>zigzag1Length)
````
