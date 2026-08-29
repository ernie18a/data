<!-- tradingview-pine-id: PUB;62dd5b72451f47b784d7029311f4fda6 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Delta Compare [Ticks ~ LTF data]

Source: https://www.tradingview.com/script/zn9dhLPS-Volume-Delta-Compare-Ticks-LTF-data/

## Description

The "Volume Delta Compare [Ticks ~ LTF data]" publication shows 2 different techniques to show into-depth details of Volume, using Tick and Lower-Time-Frame (LTF) data.

🔶 USAGE

Check for divergences between price and volume movement
[image]https://www.tradingview.com/x/Wo1U5c3O/[/image]

Check details (why and when a ΔV developed)
[image]https://www.tradingview.com/x/HIxaX6u4/[/image]
[image]https://www.tradingview.com/x/0BkwlSj9/[/image]

Or if you want to see a lot of data stacked on each other )
[image]https://www.tradingview.com/x/O0S8ik1n/[/image]

🔶 CONCEPTS

🔹 Tick vs. LTF data

a [Tick](https://www.tradingview.com/pine-script-docs/en/v5/language/Execution_model.html#execution-model) is an measure of (upward or downward) movement in price OR volume. 
We can use this data by using [varip](https://www.tradingview.com/pine-script-docs/en/v5/language/Variable_declarations.html#varip) in the code.

Advantage:

• Detail, detail, detail
• Accurate, per tick
Disadvantage:

• Only realtime
• Can reset 'easily' -> loss of data
• Will reset when settings are changed

LTF data, through the [request.security_lower_tf()](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Other_timeframes_and_data.html#request-security-lower-tf) function, measures the OHLCV data per LTF bar

Advantage:

• Access to history when loading a chart
• No 'loss' of data when chart resets
Disadvantage:

• Less detailed
• Less accurate

This script makes it possible to compare the 2 techniques and enables you to show different values.

🔹 Values

There are mainly 3 important values:

• UP volume (uV): volume when price rises
• DOWN volume (dV): volume when price falls
• NEUTRAL volume (nV): volume when price stays the same

From this, additional data is calculated:

• Volume Delta (ΔV): uV minus dV
• Cumulative Delta Volume (cΔV): sum of ΔV

One typical nV is at open: at that moment there isn't a base price to compare with,
so when the first trade doesn't fully fill the first supply (up or down), volume will rise, but price just is 'open', no movement -> no uV or dV. 

• Tick data: every volume changement    per tick    will be added to the concerning variable (uV, dV or nV)
• LTF data:   every volume changement of each bar will be added to the concerning variable (uV, dV or nV) 

-> this can easily give a difference, for example (Tick vs. 1 minute LTF), when most of the ticks caused a rise of price, but at the last few seconds, a few ticks causes the close to come below open, with Tick data this could give more UP Volume, while LTF data will show 1 value of DOWN Volume.

🔶 EXAMPLES

🔹 Details

In these examples you can see:

• grey line: Total volume (higher precision)

• UP/DOWN/NEUTRAL Volume

• green columns: uV
• orange columns: dV
• blue pillars: nV

• coloured stepline: reflects ΔV 

• close > open and  positive ΔV -> green
• close > open but negative ΔV -> fuchsia
• close < open and negative ΔV -> orange
• close < open but  positive ΔV -> bright lime green

• Right side -> indication of used data (Tick/LTF data) + last ΔV

• labels (can be disabled)

Above 0 (only with Tick data):  data from EVERY tick (ΔV [ΔP]):
• first the amount of Volume (0 when the amount is very minimal)
• between brackets: price movement

Below 0:
• Σ  V: sum of uV, dV and nV, for that bar
• Σ up: sum of uV for that bar
• Σ dn: sum of dV for that bar
• Σ nt: sum of nV for that bar
• Σ  P: sum of price movement, for that bar (only at Tick data)

[image]https://www.tradingview.com/x/RB8iHOyn/[/image]
(At the right you'll see a new bar just started)

[image]https://www.tradingview.com/x/0xIH7fLp/[/image]

Here is a detail of the first second at opening:
[image]https://www.tradingview.com/x/V7JaChKU/[/image]

🔹 Cumulative Volume Delta (CVD)

Difference CVD based on Tick vs. LTF data:
[image]https://www.tradingview.com/x/KXSyx9HK/[/image]
[image]https://www.tradingview.com/x/Ne09sWWc/[/image]
(horizontal lines added for reference)

🔶 FEATURES

🔹 Minimal plotting of na values 

Data window and status line only show what is applicable (tick or LTF data) to diminish clutter of data values:
[image]https://www.tradingview.com/x/L1HyaBsR/[/image]

The Tick option has a label above 0 which includes details of every Tick.
If data is added every tick, that label on a 10 minute chart will be filled beyond limitations pretty quickly (string max_length = 4096 limit). 
To prevent the script stopping to execute, at a certain limit, this label will stop updating and show the message "Too much data".
[image]https://www.tradingview.com/x/ZidrVKwD/[/image]

The label below the 0-line won't reach that limit, so it will keep on updating.
Timeframes closer to 1 second will have less risk to reach that 4096 limit. Details will remain to show in this case.

🔹 Automatic label colour adaption when changing between dark/light mode values 

Label background/text-colour will adapt according to the dark/light-mode by using [chart.fg_color](https://www.tradingview.com/pine-script-reference/v5/#var_chart.fg_color)/[chart.bg_color](https://www.tradingview.com/pine-script-reference/v5/#var_chart.bg_color) 
[image]https://www.tradingview.com/x/eAiYMMWL/[/image]
[image]https://www.tradingview.com/x/Ay44Hfid/[/image]

🔶 SETTINGS

🔹 Data from: Ticks vs. LTF data

🔹 LTF: Lower Time-Frame for when LTF option is chosen: 1, 5, 10, 15, 30 Seconds or 1 minute

🔹 Also start when bar already has data: only for tick data -> when disabled calculations only start on a new bar.

🔹 CVD, Only show Cumulative Delta Volume: enable to just display CVD

🔹 Colours: colour at the right is for price/volume direction divergences

🔹 Label: choose what you want to display + size labels

🔹 0-line: The label under the 0-line sometimes goes below the chart. this can be adjusted with this setting.
[image]https://www.tradingview.com/x/rwJAHja5/[/image]

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fikira

//@version=5
indicator("Volume Delta Compare [Ticks ~ LTF data]", max_labels_count=500, max_lines_count=500)

_                                                                                                                                                                                                                                        ='  
                                                     ------------        
                           ––––––––––––––––––––––––––  SETTINGS  ––––––––––––––––––––––––––– 
                                                     ------------                                                                                                                                                                        '                                                              

tick      = input.string('Ticks', 'Data from: ', options=[   'Ticks'       ,        'LTF'     ])
res       = input.string(  '1'  ,    'LTF'     , options=['1S', '5S', '10S', '15S', '30S', '1'])
onlyN     = input.bool  (      true, 'Also start when bar already has data') 
iCumV     = input.bool  (     false, 'only show Cumulative Delta Volume'       , group= 'CVD'  )
cBull     = input.color(color.rgb( 57, 196, 157, 25), 'Up'      , inline='up', group='colour')
cBull_    = input.color(color.rgb(105, 255,  60    ), ''        , inline='up', group='colour')
cBear     = input.color(color.rgb(230,  92,   0, 25), 'Down'    , inline='dn', group='colour')
cBear_    = input.color(color.rgb(230,   0, 199    ), ''        , inline='dn', group='colour')
cNeut     = input.color(color.rgb(  0, 207, 230,  0), 'Neutral' , inline='nt', group='colour')

sDetail   = input.bool  (      true, 'Show details'                            , group='Label' )
sTotVol   = input.bool  (      true, 'Show Total Volume'                       , group='Label' )
sUpDnNt   = input.bool  (      true, 'Show Up/Dn/Nt Volume'                    , group='Label' )
sPriceDf  = input.bool  (      true, 'Show Price Delta'                        , group='Label' )
size      = input.string(size.small, 'size labels'
 , options=  [size.tiny, size.small,  size.normal, size.large, size.auto]      , group='Label' )
move      = 10   / input.int  (  5 , 'move centerline', minval = 1, maxval = 20, group='0-line')

isTick    =      tick  ==     'Ticks'
Tdisplay1 =     iCumV and     isTick ? display.all : display.none
Tdisplay2 = not iCumV and     isTick ? display.all : display.none

Ldisplay1 =     iCumV and not isTick ? display.all : display.none
Ldisplay2 = not iCumV and not isTick ? display.all : display.none

_                                                                                                                                                                                                                                        ='  
                                                     -------------       
                           ––––––––––––––––––––––––––  VARIABLES  –––––––––––––––––––––––––– 
                                                     -------------                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                       
                                                       tick data 
                                                      -----------                                                                                                                                                                         '                                                              

varip float volBl = na
varip float volBr = na
varip float volNt = na

varip float  vl   = na
varip float  cl   = na
varip float  eq   = na

varip float  dfP  = na
varip float  dfV  = na

varip float  TdfP = na
varip float  TdfV = na

varip bool  print = true
varip string txt  = ''

var label lab     = label.new(na, na)
var label labTot  = label.new(na, na)
_                                                                                                                                                                                                                                        ='                                                                 
                                                      LTF data 
                                                     -----------                                                                                                                                                                          '                                                              
float       upV   = na 
float       dnV   = na
float       ntV   = na 
float       dV    = na 
float       ttV   = na 
var float  cumV   = 0

_                                                                                                                                                                                                                                        ='                                                                 
                                                     -----------                                                                                                                                                                          '                                                              

onlyStartWhenCleanSlate = onlyN ? onlyN : barstate.isrealtime[1]

_                                                                                                                                                                                                                                        ='  
                                                   --------------       
                           –––––––––––––––––––––––– CALCULATIONS –––––––––––––––––––––––––– 
                                                   --------------                                                                                                                                                                                                                                    
                                                                                                                                                                                                                              
                                                      tick data 
                                                     -----------                                                                                                                                                                         '                                                              
if isTick
    if barstate.isrealtime 
        if not iCumV 
            if onlyStartWhenCleanSlate
                if sDetail
                    lab    := label.new(bar_index, 0, color=color.new(chart.bg_color, 50), textcolor=chart.fg_color, size=size)
                if sTotVol or sUpDnNt or sPriceDf
                    labTot := label.new(bar_index, 0, color=color.new(chart.bg_color, 50), textcolor=chart.fg_color, size=size
                           ,                          style=          label.style_label_up                                    )
            else 
                if not barstate.isrealtime[1] 
                    line.new(bar_index, 0, bar_index, syminfo.mintick, extend=extend.both)

    if barstate.isnew 
        // ----------------------------------------------------------
        cl    :=  open , dfP  :=   0   , TdfP :=   0    // "open" 
        vl    := volume, dfV  := volume, TdfV := volume // "volume" at first tick
        if not iCumV and sDetail
            txt   := 'Δ V [Δ P]\n\n'
        print := true

        switch 
            dfP > 0 =>
                volBl := dfV, volBr :=  0 , volNt :=  0
            dfP < 0 =>
                volBl :=  0 , volBr := dfV, volNt :=  0
            =>
                volBl :=  0 , volBr :=  0 , volNt := dfV
        // ----------------------------------------------------------

        if not iCumV
            txt 
              +=  (sDetail ?             str.tostring(      dfV   )                       // Δ volume - volume(previous tick) 
              +              ' ['     +  str.tostring(      dfP   ) + ']\n'        : na)  // Δ price  - volume(previous tick) 
            lab   .set_text(                     txt   )
            labTot.set_text(
                  (sTotVol ? 'Σ  V: ' +  str.tostring(      TdfV  ) +  '\n'        : na)  // Σ     volume
              +   (sUpDnNt ? 'Σ up: ' +  str.tostring(      volBl ) +  '\n'        : na)  // Σ   up  volume
              +   (sUpDnNt ? 'Σ dn: ' +  str.tostring(      volBr ) +  '\n'        : na)  // Σ  down  volume
              +   (sUpDnNt ? 'Σ nt: ' +  str.tostring(      volNt ) +  '\n' + '\n' : na)  // Σ neutral volume   
              +   (sPriceDf? 'Σ  P: ' +  str.tostring(      TdfP  )                : na)) // Σ  close - open
   
    else
        dfP  := close  - cl
        dfV  := volume - vl

        switch 
            dfP > 0 => volBl += dfV
            dfP < 0 => volBr += dfV
            =>         volNt += dfV

        TdfV += dfV 
        TdfP += dfP 

        if not iCumV 
            if str.length(txt) < 4000
                txt += 
                  (sDetail ?             str.tostring(      dfV   )                       // Δ volume - volume(previous tick) 
                  +          ' ['     +  str.tostring(      dfP   ) + ']\n'        : na)  // Δ price  - volume(previous tick) 
            else 
                if print
                    txt  += '\nToo much data\n-------------'
                    print := false

            lab   .set_text(                     txt   )
            labTot.set_text(
                  (sTotVol ? 'Σ  V: ' +  str.tostring(      TdfV  ) +  '\n'        : na)  // Σ     volume
              +   (sUpDnNt ? 'Σ up: ' +  str.tostring(      volBl ) +  '\n'        : na)  // Σ   up  volume
              +   (sUpDnNt ? 'Σ dn: ' +  str.tostring(      volBr ) +  '\n'        : na)  // Σ  down  volume
              +   (sUpDnNt ? 'Σ nt: ' +  str.tostring(      volNt ) +  '\n' + '\n' : na)  // Σ neutral volume   
              +   (sPriceDf? 'Σ  P: ' +  str.tostring(      TdfP  )                : na)) // Σ  close - open

    eq     := volBl - volBr 
    cl     := close
    vl     := volume
_                                                                                                                                                                                                                                        ='                                                                 
                                                      LTF data 
                                                     ----------                                                                                                                                                                           '                                                              

[bV, sV, nV, tV] = request.security_lower_tf(
  syminfo.tickerid,   res  , 
 [
   close >  open ? volume : 0
 , close <  open ? volume : 0
 , close == open ? volume : 0
 , volume
 ]                                          )

if not isTick

    if not iCumV and (sTotVol or sUpDnNt or sPriceDf) 
        labTot := label.new(bar_index, 0, color=color.new(chart.bg_color, 50), textcolor=chart.fg_color, size=size
               ,                          style=          label.style_label_up                                    )    

    upV := bV  .sum() 
    dnV := sV  .sum() 
    ntV := nV  .sum() 
    dV  := upV - dnV 
    ttV := upV + dnV + ntV

    if not iCumV 
        labTot.set_text(
              (sTotVol ? 'Σ  V: ' +  str.tostring(      ttV   ) +  '\n'        : na)  // Σ     volume
          +   (sUpDnNt ? 'Σ up: ' +  str.tostring(      upV   ) +  '\n'        : na)  // Σ   up  volume
          +   (sUpDnNt ? 'Σ dn: ' +  str.tostring(      dnV   ) +  '\n'        : na)  // Σ  down  volume
          +   (sUpDnNt ? 'Σ nt: ' +  str.tostring(      ntV   ) +  '\n' + '\n' : na)) // Σ neutral volume   

_                                                                                                                                                                                                                                        ='  
                                                   --------------       
                           ––––––––––––––––––––––––    DISPLAY   –––––––––––––––––––––––––– 
                                                   --------------                                                                                                                                                                                                                                   
                                                                                                                       
                                                      tick data 
                                                     -----------                                                                                                                                                                          '                                                              

cTick = 
 eq > 0 ? close > open ? cBull : cBull_ 
 :        close < open ? cBear : cBear_ 

plot(barstate.isrealtime and onlyStartWhenCleanSlate and not iCumV ?  volBl : na, 'Σ Volume up'     , color= color.new(cBull, 75), style=plot.style_columns                , display= Tdisplay2)
plot(barstate.isrealtime and onlyStartWhenCleanSlate and not iCumV ? -volBr : na, 'Σ Volume down'   , color= color.new(cBear, 75), style=plot.style_columns                , display= Tdisplay2)
plot(barstate.isrealtime and onlyStartWhenCleanSlate and not iCumV ?  volNt : na, 'Σ Volume neutral', color= color.new(cNeut, 50), style=plot.style_histogram , linewidth=5, display= Tdisplay2)
plot(barstate.isrealtime and onlyStartWhenCleanSlate and not iCumV ?   eq   : na, 'Σ Δ Volume'      , color= cTick               , style=plot.style_steplinebr, linewidth=3, display= Tdisplay2)
                                                                                         
hline(not iCumV ?   0  : na, color=color.silver)
last20Vol = ta.highest(volume, 20)
plot(not iCumV and isTick ? -(last20Vol / move) : na, 'move drawings (Tick data)', color=color(na), display= Tdisplay2) // creates an invisible line that pushes everything up/down (~ visibility labels)

_                                                                                                                                                                                                                                        ='                                                                 
                                                      LTF data 
                                                     -----------                                                                                                                                                                          '                                                              
cLTF  = 
 dV > 0 ? close > open ? cBull : cBull_ 
 :        close < open ? cBear : cBear_ 
 
plot (not iCumV ?  upV  : na, 'Σ Volume up'     , color=  color.new(cBull, 75) , style=plot.style_columns               , display= Ldisplay2)
plot (not iCumV ? -dnV  : na, 'Σ Volume down'   , color=  color.new(cBear, 75) , style=plot.style_columns               , display= Ldisplay2)
plot (not iCumV ?  ntV  : na, 'Σ Volume neutral', color=  color.new(cNeut, 50) , style=plot.style_histogram, linewidth=5, display= Ldisplay2)
plot (not iCumV ?   dV  : na, 'Σ Δ Volume'      , color=            cLTF       , style=plot.style_stepline , linewidth=3, display= Ldisplay2)

_                                                                                                                                                                                                                                        ='                                                                 
                                                   --------------       
                           ––––––––––––––––––––––––  Σ Δ Volume  –––––––––––––––––––––––––– 
                                                   --------------                                                                                                                                                                         '                                                              

cumV   += isTick ? nz(eq) : nz(dV)

cCumV   = cumV > nz(  cumV[1]) ? cBull : cBear

plot(    iCumV ? isTick ? barstate.isrealtime ? cumV[1] : na : cumV[1] : na, 'cumulative Volume Delta', color=cCumV       , style=plot.style_stepline, display= isTick ? Tdisplay1 : Ldisplay1)
plot(    iCumV ? isTick ? barstate.isrealtime ? cumV    : na : cumV    : na, 'cumulative Volume Delta', color=cCumV       , style=plot.style_stepline, display= isTick ? Tdisplay1 : Ldisplay1)
plot(not iCumV ? isTick ?                       TdfV    :       ttV    : na, 'Total Volume'           , color=color.gray, style=plot.style_stepline, display= isTick ? Tdisplay2 : Ldisplay2)

if iCumV and (isTick ? barstate.isrealtime : true)
    line.new(bar_index, cumV, bar_index, cumV[1], color= cCumV,  width=20)

_                                                                                                                                                                                                                                        ='                                                                 
                                                   --------------       
                           ––––––––––––––––––––––––     Table    –––––––––––––––––––––––––– 
                                                   --------------                                                                                                                                                                         '   
var table tab = table.new(position.top_right, 1, 2, chart.bg_color, chart.bg_color)
if barstate.islast
    table.cell(tab, 0, 0,           isTick ? 'Tick data' : 'LTF data'           , text_color=  chart.fg_color     )
    table.cell(tab, 0, 1,  str.tostring(math.round_to_mintick(isTick ? eq : dV)), text_color=isTick ? cTick : cLTF)

_                                                                                                                                                                                                                                        ='                                                                 
 --------------------------------------------------------------------------------------------------------------------                                                                                                                     '
````
