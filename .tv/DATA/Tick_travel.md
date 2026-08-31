<!-- tradingview-pine-id: PUB;3e0324aeef334c24b40e3c74cdeb86ba -->
<!-- tradingviewscripts-format: 1 -->
# Tick travel ⍗

Source: https://www.tradingview.com/script/CtWzT4VA-Tick-travel/

## Description

This script is a further exploration of 'ticks' (only on realtime - live bars), based on my previous script:
-[https://www.tradingview.com/script/CFxw8CK3-Tick-up-down/?utm_source=notification_email&utm_medium=email&utm_campaign=notification_comment#tc8272921](https://www.tradingview.com/script/CFxw8CK3-Tick-up-down/?utm_source=notification_email&utm_medium=email&utm_campaign=notification_comment#tc8272921)- 
 
What are 'ticks'?
... Once the script’s execution reaches the rightmost bar in the dataset, if trading is currently active on the chart’s symbol, 
then Pine indicators will execute once every time an update occurs, i.e., price or volume changes ...
(https://www.tradingview.com/pine-script-docs/en/v5/language/Execution_model.html)

This script has 2 parts:

[*] 1) Option: ' Tick up/down'
This is a further progression of previous work.
During bar development, every time there is an update (tick), a dot is placed.
If for example there is 1 tick (first of new bar), a dot will be placed on 1,
if it is the 8th tick off that bar, there will be a dot placed on 8.

While my previous script had the issue that there was an upper limit per bar (max 32), 
this script (because it is working with labels) can place max 500 dots.
[https://www.tradingview.com/x/iL8zKlTw/](https://www.tradingview.com/x/iL8zKlTw/)
[https://www.tradingview.com/x/wo6TogRZ/](https://www.tradingview.com/x/wo6TogRZ/)

For each bar this is better, it has to be mentioned though that looking in history, once the limit of 500 has been reached, 
you'll notice the last ones are being deleted. This is one of the reasons the script is not suitable for higher timeframes 
(1h and higher, even higher than 5 minutes can give some issues if it is a highly traded ticker), if a bar would have more 
than 500 ticks, they won't be drawn anymore (which is not desirable of course)

[*] 2) Option: ' Tick progression'
These are the same ticks, but placed on the candle itself, or you can show the candle:
[https://www.tradingview.com/x/Ytbrl1LQ/](https://www.tradingview.com/x/Ytbrl1LQ/)
[https://www.tradingview.com/x/p4ZSujGE/](https://www.tradingview.com/x/p4ZSujGE/)
Or 'without' candle (or 'black' colour):
[https://www.tradingview.com/x/J4lrBUFK/](https://www.tradingview.com/x/J4lrBUFK/)
[https://www.tradingview.com/x/Hd1tS7ht/](https://www.tradingview.com/x/Hd1tS7ht/)
[https://www.tradingview.com/x/aiCTJzBX/](https://www.tradingview.com/x/aiCTJzBX/)

When 'No candles' are enabled, the 'candles' get the colour at the right.

At the moment it is not possible to drawn between 2 candles, this technique uses labels with 'text', 
each tick on a candle will have a 'space' added, so you can see a progression to the right.
[https://www.tradingview.com/x/bpKZvn7l/](https://www.tradingview.com/x/bpKZvn7l/)
[https://www.tradingview.com/x/WvwhqDXw/](https://www.tradingview.com/x/WvwhqDXw/)

Colours
- if price is higher than previous tick price -> green
- if price is lower than previous tick price -> red
- otherwise -> blue (dimmed)

There are options to choose the 'dot', when choosing 'custom', 
just enter (copy/paste) your symbol of your choice in the 'custom' field:
[https://www.tradingview.com/x/tADKTWnB/](https://www.tradingview.com/x/tADKTWnB/)
[https://www.tradingview.com/x/V7VC91nd/](https://www.tradingview.com/x/V7VC91nd/)

Caveats:
- Labels and text will not always be exactly on the price itself
- The scripts needs more testings, possibly some ticks don't always get drawn as they should.
The lower the timeframe, the more possible issues can occur
- Since (candle option) the dots move to the right, the higher the timeframe and/or the more ticks,
the sooner ticks will go in the area of next candle.
That's why I made a separate 'start symbol' 
-> This is the very first tick on each candle, then you can zoom in/out more easily until the dots don't merge into each other candle area:
[https://www.tradingview.com/x/0xx1IH3Q/](https://www.tradingview.com/x/0xx1IH3Q/)
[https://www.tradingview.com/x/YaJMnk8X/](https://www.tradingview.com/x/YaJMnk8X/)

A timeframe higher than 5 minutes mostly won't be feasible I believe

This script wouldn't be possible without the help of @LucF, also because of his script 
[https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/](https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/)

With very much respect I am hugely inspired by him! Many Thanks to him, Tradingview, and everything associated with them!

Cheers!

---

## Source Code

````pine
//@version=5
indicator(title="Tick travel ⍗", overlay=false, max_labels_count = 500, max_lines_count = 500)

// ———————[ variables ]———————

varip     priceP = array.new_float ()
varip     priceB = array.new_int   ()
varip     priceC = array.new_int   ()
varip     priceT = array.new_string()
var label[]   priceL = array.new_label()
varip t   = 0
varip tC  = 0
varip cl  = close
varip pcl = close

// ———————[ input ]———————

// ⧔ ⟜  ●
str_o   = input.string('̣'                       , title=''        , options=['̣','.','˛','᱾','。', '●', 'custom']                                  , group='symbol'        , inline='string')
str_c   = input.string('ᛧ'                       , title='custom'                                                                                 , group='symbol'        , inline='string')
start_o = input.string('𐏓'                     , title=''        , options=['ᚦ', '𐏓', '𐫳', 'Ⳟ', 'Ⲳ', '⎿', '⏊', '⧔', '⟜', '☾', '☉', 'custom'], group='start symbol'  , inline='string2', 
 tooltip='First symbol of each candle')
start_c = input.string('♞'                      , title='custom'                                                                                  , group='start symbol'  , inline='string2')


str     = str_o != 'custom' ? str_o : str_c
start   = start_o != 'custom' ? start_o : start_c

s_      = input.string(size.auto                , title='size'         , options=[size.tiny, size.small, size.normal, size.large, size.huge, size.auto])
aSize   = input.int   (500                      , title='array size'   , minval=10, maxval=500)

option  = input.string('tick progression ~ candles (no candles)'       ,
                                                  title='options'      , group  ='options'       , 
 options=['tick progression ~ candles', 'tick progression ~ candles (no candles)', 'tick up/down'])

black   = input.bool  (true                     , title='no candles'   , group  ='candle color'              , tooltip='only tick dots')
c_up    = input.color (#26a69a                  , title=''             , group  ='candle color'  , inline='1')
c_dn    = input.color (#ef5350                  , title=''             , group  ='candle color'  , inline='1')
c_blk   = input.color (color.new(color.black,25), title=''             , group  ='candle color'  , inline='1', tooltip='no candles'    )

// ———————[ the work ]———————

while array.size(priceL) >= aSize
    label.delete(array.pop(priceL))

if array.size(priceL) >= aSize
    array.pop(priceP)
    array.pop(priceB)
    array.pop(priceC)
    array.pop(priceT)
    
t  += 1

if barstate.isnew
    t := 0
    array.clear(priceP)
    array.clear(priceB)
    array.clear(priceC)
    array.clear(priceT)

if ta.change(t)
    pcl := cl
    cl  := close
    array.unshift(priceP, option == 'tick up/down' ?  t : cl)
    array.unshift(priceB, bar_index)
    array.unshift(priceC, cl > pcl ? 1 : cl < pcl  ? -1 :  0)
    //
    if option != 'tick up/down' 
        txt = ''
        for j = 0 to t
            txt += ' '
        if barstate.isnew
            txt += start
        else    
            txt += str  
        array.unshift(priceT, txt)

if barstate.isrealtime
    tC += 1
    if array.size(priceP) > 1
        for i = 0 to math.min(aSize, array.size(priceP) -1)
            array.unshift(priceL, 
             label.new(
             array.get(priceB, i), 
             array.get(priceP, i), 
             text= 
              option == 'tick up/down' ? '.' : 
              array.get(priceT, i)  , color=na, 
              style=label.style_none, size =s_,
             textcolor=
              array.get(priceC, i) ==  1 ? color.lime : 
              array.get(priceC, i) == -1 ? color.red  : 
                                           color.blue))

// ———————[ plotcandle ]———————

c_wick   =
 option == 'tick progression ~ candles'              ? close > open ? c_up : c_dn :
 option == 'tick progression ~ candles (no candles)' ?                c_blk       : na

c_border =
 option == 'tick progression ~ candles'              ? close > open ? c_up : c_dn :
 option == 'tick progression ~ candles (no candles)' ?                c_blk       : na

ope = option == 'tick up/down' ? na : open
hi_ = option == 'tick up/down' ? na : high
lo_ = option == 'tick up/down' ? na : low
clo = option == 'tick up/down' ? na : close

plotcandle(ope, hi_, lo_, clo, '', color = color.new(color.black, 100), wickcolor   = c_wick, bordercolor = c_border)

// ———————[ debug ]———————

//plotchar(tC, "tC", "", location.top, size = size.tiny)
//plotchar(array.size(priceL), "size array labels", "", location.top, size = size.tiny)
````
