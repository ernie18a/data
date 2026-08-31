<!-- tradingview-pine-id: PUB;3be02d6caf6d4e53b60090919a85f2db -->
<!-- tradingviewscripts-format: 1 -->
# Christmas Toolkit [LuxAlgo]

Source: https://www.tradingview.com/script/k6XcSuxO-Christmas-Toolkit-LuxAlgo/

## Description

It's that time of the year... and what would be more appropriate than displaying Christmas-themed elements on your chart?

The Christmas Toolkit displays a tree containing elements affected by various technical indicators. If you're lucky, you just might also find a precious reindeer trotting toward the tree, how fancy!

🔶 USAGE

Each of the 7 X-mas balls is associated with a specific condition.

Each ball has a color indicating:

[*]lime: very bullish
[*]green: bullish
[*]blue: holding the same position or sideline
[*]red: bearish
[*]darkRed: very bearish

From top to bottom:

🔹 RSI (length 14)

[*]rsi < 20 - lime (+2 points)
[*]rsi < 30 - green (+1 point)
[*]rsi > 80 - darkRed (-2 points)
[*]rsi > 70 - red (-1 point)
[*]     else - blue

🔹 Stoch (length 14)

[*]stoch < 20 - lime (+2 points)
[*]stoch < 30 - green (+1 point)
[*]stoch > 80 - darkRed (-2 points)
[*]stoch > 70 - red (-1 point)
[*]           else - blue

🔹 close vs. ema (length 20)

[*]close > ema 20 - green (+1 point)
[*]                    else - red (-1 point)

🔹 ema (length 20)

[*]ema 20 rises - green (+1 point)
[*]               else - red (-1 point)

🔹 ema (length 50)

[*]ema 50 rises - green (+1 point)
[*]               else - red (-1 point)

🔹 ema (length 100)

[*]ema 100 rises - green (+1 point)
[*]                  else - red (-1 point)

🔹 ema (length 200)

[*]ema 200 rises - green (+1 point)
[*]                  else - red (-1 point)

The above information can also be found on the right side of the tree.

[image]https://www.tradingview.com/x/UpvolX3I/[/image]

You'll see the conditions associated with the specific X-mas ball and the meaning of color changes. This can also be visualized by hovering over the labels.

All values are added together, this result is used to color the star at the top of the tree, with a specific color indicating:

[*]lime: very bullish (> 6 points)
[*]green: bullish (6 points)
[*]blue: holding the same position or sideline
[*]red: bearish (-6 points)
[*]darkRed: very bearish (< -6 points)

Switches to green/lime or red/dark red can be seen by the fallen stars at the bottom.

[image]https://www.tradingview.com/x/tCFmEDju/[/image]

The Last Switch indicates the latest green/lime or red/dark red color (not blue)

🔶 ANIMATION

Randomly moving snowflakes are added to give it a wintry character.

There are also randomly moving stars in the tree.

[image]https://www.tradingview.com/x/e2FOdHmJ/[/image]

Garland rotations, style, and color can be adjusted, together with the width and offset of the tree, put your tree anywhere on your chart!

Disabling the "static tree" setting will make the needles 'move'.

Have you happened to see the precious reindeer on the right? This proud reindeer moves towards the most recent candle. Who knows what this reindeer might be bringing to the tree?

🔶 SETTINGS

[*]Width: Width of tree.
[*]Offset: Offset of the tree.

[*]Garland rotations: Amount of rotations, a high number gives other styles.
[*]Color/Style: sets the color & style of garland stars.
[*]Needles: sets the needle color.

[*]Static Tree: Allows the tree needles to 'move' with each tick.
[*]Reindeer Speed: Controls how fast the deer moves toward the most recent bar.

🔶 MESSAGE FROM THE LUXALGO TEAM

It has been an honor to contribute to the TradingView community and we are always so happy to see your supportive messages on our scripts.

We have posted a total of 78 script publications this year, which is no small feat & was only possible thanks to our team of Wizard developers @alexgrover + @dgtrd + @fikira , the development team behind Pine Script, and of course to the support of our legendary community.

Happy Holidays to you all, and we'll see ya next year! ☃️

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator("Christmas Toolkit [LuxAlgo]", shorttitle="LuxAlgo - Christmas Toolkit"
 , max_lines_count  =  500
 , max_labels_count =  500
 , max_bars_back    = 5000
 , scale            = scale.none
 , overlay          = true
 )

//------------------------------------------------------------------------------
// Settings
//-----------------------------------------------------------------------------{
width    = input.int   ( 200,  step =  10 )
offset   = input.int   (100 ,  step =  10  )
rotation = input.int   (5, 'Garland Rotations')

staticT  = input.bool  (true  , 'Static Tree')
deerSp   = input.int   ( 1    , 'Deer Speed' 
         , minval=1   , maxval=10            )

//Theme
col      = input.color (#056656, 'Tree Color'
  , group = 'Theme')

cGar     = input.color (#f29a3685, inline='g'
 , title = 'Garland Color'
 , group = 'Theme')

gar      = input.string('✫', ''  , inline='g'
  , options   =   ['✳︎','✴︎','✫','✶','●']
  , group = 'Theme')

//-----------------------------------------------------------------------------}      
//Variables
//-----------------------------------------------------------------------------{
var  length = 1000
var  alpha  =    0.1
varip count =    0

var int leftBar  = na
var int rightBar = na
var color last   = na

var label l1 = label.new(na, na, style=label.style_none, text='⭐️', size=size.tiny)
var label l2 = label.new(na, na, style=label.style_none, text='⭐️', size=size.tiny)
var label l3 = label.new(na, na, style=label.style_none, text='⭐️', size=size.tiny)
var label l4 = label.new(na, na, style=label.style_none, text='⭐️', size=size.tiny)
var label l5 = label.new(na, na, style=label.style_none, text='⭐️', size=size.tiny)
var label l6 = label.new(na, na, style=label.style_none, text='⭐️', size=size.tiny)

var label a0 = label.new(na, na, style=label.style_none  , size=size.huge,  text='⭑') // ☆★⭑⭒✮✩
var label a1 = label.new(na, na, style=label.style_circle, size=size.tiny)
var label a2 = label.new(na, na, style=label.style_circle, size=size.tiny)
var label a3 = label.new(na, na, style=label.style_circle, size=size.tiny)
var label a4 = label.new(na, na, style=label.style_circle, size=size.tiny)
var label a5 = label.new(na, na, style=label.style_circle, size=size.tiny)
var label a6 = label.new(na, na, style=label.style_circle, size=size.tiny)
var label a7 = label.new(na, na, style=label.style_circle, size=size.tiny)

var label t0 = label.new(na, na, style=label.style_none
  , text = '⏺'
  , size = size.large
  , textalign = text.align_left
  , tooltip = 'Last switch')

var label t1 = label.new(na, na
  , style = label.style_none
  , text = 'rsi'
  , size = size.small
  , textalign = text.align_left
  , tooltip = 'rsi < 20 - lime\nrsi < 30 - green\nrsi > 80 - darkRed\nrsi > 70 - red\nelse - blue')

var label t2 = label.new(na, na, style=label.style_none
  , text='stoch'
  , size=size.small
  , textalign = text.align_left
  , tooltip = 'sto < 20 - lime\nsto < 30 - green\nsto > 80 - darkRed\nsto > 70 - red\nelse - blue')

var label t3 = label.new(na, na, style=label.style_none, text='close > ema 20', size=size.small, textalign = text.align_left, tooltip='close > ema 20 ? green : red')
var label t4 = label.new(na, na, style=label.style_none, text='ema 20'        , size=size.small, textalign = text.align_left, tooltip=  'ema 20 rises ? green : red')
var label t5 = label.new(na, na, style=label.style_none, text='ema 50'        , size=size.small, textalign = text.align_left, tooltip=  'ema 50 rises ? green : red')
var label t6 = label.new(na, na, style=label.style_none, text='ema 100'       , size=size.small, textalign = text.align_left, tooltip= 'ema 100 rises ? green : red')
var label t7 = label.new(na, na, style=label.style_none, text='ema 200'       , size=size.small, textalign = text.align_left, tooltip= 'ema 200 rises ? green : red')

var array<float> Lx  = array.new<float>() 
var array<float> Rx  = array.new<float>() 
var array<label> lab = array.new<label>() 
snowflakes           = array.from('❄️', '❆', '❊', '❋', '❉', '❅')

var r   = length / rotation
n       = bar_index 

blue    = color.blue 
lime    = color.lime 
green   = color.green
red     = color.red  
darkRed = #FF0000    

//-----------------------------------------------------------------------------}      
//Calculations
//-----------------------------------------------------------------------------{
rsi  = ta.rsi  (close           ,  14) 
sto  = ta.stoch(close, high, low,  14) 
m20  = ta.ema  (close           ,  20) 
m50  = ta.ema  (close           ,  50) 
m100 = ta.ema  (close           , 100) 
m200 = ta.ema  (close           , 200) 

//-----------------------------------------------------------------------------}      
//Conditions
//-----------------------------------------------------------------------------{

method c(color col) => color.new(col, 20)

b1    = rsi < 20 ? 2 : rsi < 30 ? 1 : rsi > 80 ? -2 : rsi > 70 ? -1 : rsi > 55 ? 1 : rsi < 45 ? -1 : 0
c1    = b1 ==  2 ? lime : b1 == 1 ? green : b1 == -2 ? darkRed : b1 == -1 ? red : blue

b2    = sto < 20 ? 2 : sto < 30 ? 1 : sto > 80 ? -2 : sto > 70 ? -1 : sto > 55 ? 1 : sto < 45 ? -1 : 0
c2    = b2 ==  2 ? lime : b2 == 1 ? green : b2 == -2 ? darkRed : b2 == -1 ? red : blue

b3    =   close > m20      ? 1 : -1, c3 = b3 == 1 ? green : red 
b4    = ta.rising(m20 , 1) ? 1 : -1, c4 = b4 == 1 ? green : red 
b5    = ta.rising(m50 , 1) ? 1 : -1, c5 = b5 == 1 ? green : red 
b6    = ta.rising(m100, 1) ? 1 : -1, c6 = b6 == 1 ? green : red 
b7    = ta.rising(m200, 1) ? 1 : -1, c7 = b7 == 1 ? green : red 

sm    = b1 + b2 + b3 + b4 + b5 + b6 + b7

dr    = sm > 6 ? 2 : sm > 5 ? 1 : sm < -6 ? -2 : sm < -5 ? -1 : 0

c0    = dr > 1 ? lime : dr > 0 ? green : dr < -1 ? darkRed : dr < 0 ? red : blue

last := dr > 1 ? lime : dr > 0 ? green : dr < -1 ? darkRed : dr < 0 ? red : last

//-----------------------------------------------------------------------------}
// Execution
//-----------------------------------------------------------------------------{
if time == chart.left_visible_bar_time
    leftBar := n
    for i = 0 to 500 
        lab.unshift(label.new(na, na, text=snowflakes.get(int(math.random(0, 5))), textcolor=color.silver, color=color.new(na, na)))

    if staticT
        for i = 0 to length-1
            Lx.push(math.random(0, i, 14))
            Rx.push(math.random(0, i, 28))
        
varip dir = 1    
var int w = na    
if time == chart.right_visible_bar_time 
    rightBar      := n 
    mid            = n + offset
    w             := rightBar - leftBar     
    left           = array.new<chart.point>(0)
    right          = array.new<chart.point>(0)
    base           = array.new<chart.point>(0)
    float prev_sin = na

    width := math.min(250, width * w / 1000)

    if count  >   w - deerSp   
        dir   *= -1 
        count :=  0
    count     += deerSp

    a0.set_xy(mid               , - 0 ), a0.set_textcolor( c0     ), t0.set_xy(int(mid + (width * 1.5)), - 0 ), t0.set_textcolor(last)
    a1.set_xy(mid - (width / 20), -270), a1.set_color    ( c1.c() ), t1.set_xy(int(mid + (width * 1.5)), -270), t1.set_textcolor( c1 )
    a2.set_xy(mid + (width / 10), -350), a2.set_color    ( c2.c() ), t2.set_xy(int(mid + (width * 1.5)), -350), t2.set_textcolor( c2 )
    a3.set_xy(mid - (width /  6), -520), a3.set_color    ( c3.c() ), t3.set_xy(int(mid + (width * 1.5)), -520), t3.set_textcolor( c3 )
    a4.set_xy(mid + (width /  7), -570), a4.set_color    ( c4.c() ), t4.set_xy(int(mid + (width * 1.5)), -570), t4.set_textcolor( c4 )
    a5.set_xy(mid - (width /  2), -780), a5.set_color    ( c5.c() ), t5.set_xy(int(mid + (width * 1.5)), -780), t5.set_textcolor( c5 )
    a6.set_xy(mid + (width /  3), -850), a6.set_color    ( c6.c() ), t6.set_xy(int(mid + (width * 1.5)), -850), t6.set_textcolor( c6 )
    a7.set_xy(mid - (width /  4), -920), a7.set_color    ( c7.c() ), t7.set_xy(int(mid + (width * 1.5)), -920), t7.set_textcolor( c7 )

    l1.set_xy(count %  2 == 0                   ? int(mid - (width / math.random(10, 50))) : na, -math.random(120, 170)) 
    l2.set_xy(count %  3 == 0                   ? int(mid + (width / math.random( 4, 30))) : na, -math.random(220, 370)) 
    l3.set_xy(count %  5 == 0                   ? int(mid - (width / math.random( 2, 45))) : na, -math.random(385, 485))
    l4.set_xy(count %  7 == 0 or count % 3 == 0 ? int(mid + (width / math.random( 3, 35))) : na, -math.random(500, 600))

    l5.set_xy(count %  1 == 0 or count % 2 == 0 ? int(mid - (width / math.random( 2, 50))) : na, -math.random(620, 680))
    l6.set_xy(count %  1 == 0                   ? int(mid + (width / math.random( 2, 45))) : na, -math.random(700, 880))

    base.push(chart.point.from_index(mid - (width / 10), -length -50))
    base.push(chart.point.from_index(mid - (width / 10), -length -1 ))
    base.push(chart.point.from_index(mid + (width / 10), -length -1 ))
    base.push(chart.point.from_index(mid + (width / 10), -length -50))
    polyline.new(base, line_color = color.new(#845817, 90), fill_color=color.new(#845817, 50))

    for i = 0 to length-1
        left_x      = staticT ? Lx.get(i) : math.random(0, i, 14)
        right_x     = staticT ? Rx.get(i) : math.random(0, i, 28)
        slope_left  = ((500 - left_x ) + 1) * alpha
        slope_right = ((500 - right_x) + 1) * alpha
        
        left .push(chart.point.from_index(mid                                  ,          -i                            ))
        left .push(chart.point.from_index(mid + (int(left_x ) / length) * width, math.max(-i - slope_left , -length -25)))
        right.push(chart.point.from_index(mid                                  ,          -i                            ))
        right.push(chart.point.from_index(mid - (int(right_x) / length) * width, math.max(-i - slope_right, -length -25)))

        sinx = math.sin(2*math.pi*i/r) * (i/length*width)

        if sinx > prev_sin and i > 100

            label.new(math.round(mid + sinx), -i * (1 + (length / 2 - i) / 7500) 
             , gar, color = color(na), textcolor =cGar, style = label.style_label_center) // ✴︎ ●  ✳︎ ✶  ✶

        prev_sin := sinx

    polyline.new(left, line_color = col)
    polyline.new(right, line_color = col)

    for i = 0 to lab.size() -1 
        lb   =   lab.get(i)
        plus = width + offset
        x    = n + plus - int(math.random(0, w + plus))
        y    =         math.random(0, -length), lb.set_xy(x, y)
        lb.set_textcolor(color.new(color.silver, math.random(15, 50)))


    keci = array.new<chart.point>(0)

    startPoint = dir > 0 ? leftBar : rightBar
    dirCount   = dir * count
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  3))    , -length +  0))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  3))    , -length +100))
    keci.push(chart.point.from_index(startPoint + dirCount - (dir > 0 ?  1 :  0 )    , -length +100))
    keci.push(chart.point.from_index(startPoint + dirCount - (dir > 0 ?  1 :  0 )    , -length +  0))
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir * 15))    , -length - 50)) //
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir *  6))    , -length +  0)) 
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir *  6))    , -length +240))
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir *  5))    , -length +300))
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir *  4))    , -length +360))
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir *  3))    , -length + (count %  3 == 0 ? 380 : 400))) //
    keci.push(chart.point.from_index(startPoint + dirCount - (width / (dir *  8))    , -length +240)) 
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  4))    , -length +230))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  3))    , -length +240))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  3))    , -length +450))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  4))    , -length +550)) //
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  6))    , -length +650)) 
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  5))    , -length +450))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  7))    , -length +400))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  8))    , -length +250))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir * 10))    , -length +350)) //
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  7))    , -length +450)) 
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  6))    , -length +500))
    keci.push(chart.point.from_index(startPoint + dirCount + (width * (dir *  2) / 3), -length + (count %  2 == 0 ? 450 : 470)))
    keci.push(chart.point.from_index(startPoint + dirCount + (width * (dir *  2) / 3), -length + (count %  2 == 0 ? 400 : 420)))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  2))    , -length +400)) //
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  2))    , -length +350))
    keci.push(chart.point.from_index(startPoint + dirCount + (width / (dir *  2))    , -length +  0))

    polyline.new(keci, true, true, line_color = color(na), fill_color=color.new(#5f3b04, 23))

//-----------------------------------------------------------------------------}
// Fallen stars
//-----------------------------------------------------------------------------{
ch = ta.change(dr)

plotchar(ch and dr != 0 ? high : na, location=location.bottom, color=c0)

//-----------------------------------------------------------------------------}
````
