<!-- tradingview-pine-id: PUB;108bcb4aadf440f0b9e83b06296a75bd -->
<!-- tradingviewscripts-format: 1 -->
# Timeframe Loop

Source: https://www.tradingview.com/script/bIaZM7ps-Timeframe-Loop/

## Description

The Timeframe Loop publication aims to visualize intrabar price progression in a new, different way.
[image]https://www.tradingview.com/x/Lgo9PalS/[/image]

🔶 CONCEPTS and USAGE

I got inspiration from the Pressure/Volume loop, which is used in Mechanical Ventilation with Critical Care patients to visualize pressure/volume evolution during inhalation/exhalation.
[image]https://www.tradingview.com/x/hlNbkz0W/[/image]

The main idea is that intrabar prices are visualized by a loop, going to the right during the first half and returning to the left towards its closing point. Here, the main chart timeframe (CTF) is 4 hours, and we see the movements of eight 30-minute lower timeframe (LTF) periods, highlighted by four yellow dots/lines (first 2 hours -> "Right") and four blue dots/lines (last 2 hours <- "Left"):
[image]https://www.tradingview.com/x/8A2iaR74/[/image]

🔹 BTF

If "Show Lowest TF" is enabled, the LTF is split into another lower TF (BTF - "Base TF"); in this case, the 30-minute LTF is split into 10 parts of 3 minutes (BTF):
[image]https://www.tradingview.com/x/tcZdEYue/[/image]

Enabling "Loop Lowest TF" will enable the BTF to react similarly to the largest loop; from halfway, it will return to its startpoint:
[image]https://www.tradingview.com/x/rCrNKOWa/[/image]

Here is a more detailed example:
[image]https://www.tradingview.com/x/9uifnWto/[/image]

🔹 Mini-Candles

The included option "Mini-Candles" will bring even more detail, showing the LTF as Japanese candlesticks with user-defined colors and adjustable body width; in this example, the mini-candles associated with the first half (yellow lines/dots) are green/red, while blue/fuchsia in the second half (blue lines/dots):

CTF 10 minutes, LTF 1 minute, BTF 5 seconds
[image]https://www.tradingview.com/x/haCwg5py/[/image]
One can see the detailed intrabar price progression in one glance.

CTF 5 minutes, LTF 1 minute, BTF 5 seconds
[image]https://www.tradingview.com/x/VSOavNpT/[/image]

If the LTF/BTF ratio, divided by two, results in a non-integer number, the right side will be a vertical line instead of just a turning point. In that case, the smaller, most right blue loop will be situated at the right of that line.

[*]10 minutes / 1 minute = 10 -> 10 / 2 =    5 parts
[*]    5 minutes / 1 minute =   5 ->   5 / 2 = 2.5 parts

🔶 SETTINGS

🔹 Timeframes

[*]Lower Timeframe 1
[*]Lower Timeframe 2

No need to worry about the order of both timeframes; BTF will be the lowest TF of the 2, LTF the highest; both have to be lower than the main chart TF (CTF); otherwise, it will result in the error: "`Lower Timeframes` should be lower than current chart timeframe".

[image]https://www.tradingview.com/x/kBLlvoD9/[/image]
The ratio LTF / BTF should be equal or higher than 2; otherwise, this error will show: "`Lower Timeframe` should minimally be twice the `Base (smallest) Timeframe`"

Lastly, the ratio CTF / BTF should be lower than 500; otherwise, this error will pop up: "`Current Chart timeframe` / `Lower Timeframe` should be less than 500."

I have tried to capture runtime errors as best I could. If one should be triggered (red exclamation mark next to the title), it is best to increase the lowest TF.

🔹 Options

[*]Show Lowest TF: Show BTF progression.
[*]Loop Lowest TF: Enabling will let the BTF line return halfway.
[*]Show Mini-Candles
[*]Show Steps

"Show Steps" can be useful to see how the script works, where the location of the current price is compared against the position of the left (L) and right (R) labels:
[image]https://www.tradingview.com/x/AjzETN2f/[/image]

🔹 Style
[image]https://www.tradingview.com/x/XhFoIHGA/[/image]

---

## Source Code

````pine
fi(ki)=>'ra' 
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fikira
//@version=6

________________________________________________________________________________________________________________________                                                                                                                                                                                                 ='
 ⎞  UDT  ⎛
 (__---__)                                                                                                                                                                                                                                                                                                                        '

type ln 
    line wTop 
    line body 
    line wBot 
    float op

indicator("Timeframe Loop", max_polylines_count = 100, max_labels_count = 500, overlay=true)
________________________________________________________________________________________________________________________                                                                                                                                                                                                 :='
 ⎞  Settings  ⎛
 (__--------__)                                                                                                                                                                                                                                                                                                                        '

c1=#f1ee2f5d,c2=#2fd7f176,c3=#f1ee2f,c4=#2fd7f1,c5=#53f11e1a,c6=#bc0c0c1a
c7=#40b526,c8=#bc0c0c,c9=#0c73bc,c10=#bc0cbc 
TT         =                        'Color - Style - Linewidth'
res        = input.timeframe('1'  , 'Lower Timeframe 1'                  , group='Timeframes')
res2       = input.timeframe('1S' , 'Lower Timeframe 2'                  , group='Timeframes')
showBTF    = input.bool  (true    , 'Show Lowest TF'                     , group='Options')
loopBTF    = input.bool  (true    , 'Loop Lowest TF'                     , group='Options')
candles    = input.bool  (true    , 'Show Mini Candles'                  , group='Options')
show       = input.bool  (false   , 'Show Steps'                         , group='Options')
cLarge1    = input.color (c1      , 'Linestyle Large Loop ', inline='L'  , group='Style'  )
cLarge2    = input.color (c2      , ''                     , inline='L'  , group='Style'  )
lineStyleL = str.replace (str.lower(str.substring(
             input.string('Dotted', '', tooltip=TT         , inline='L'  , group='Style'  , options=['Solid', 'Dotted', 'Dashed']), 0, 3)), 'as', 'sh')
lineWidthL = input.int   (2       , '', minval=1           , inline='L'  , group='Style'  )
cSmall1    = input.color (c3      , 'Linestyle Small Loops', inline='S'  , group='Style'  )
cSmall2    = input.color (c4      , ''                     , inline='S'  , group='Style'  )
lineStyleS = str.replace (str.lower(str.substring(
             input.string('Solid' , '', tooltip=TT         , inline='S'  , group='Style'  , options=['Solid', 'Dotted', 'Dashed']), 0, 3)), 'as', 'sh')
lineWidthS = input.int   (1       , '', minval=1           , inline='S'  , group='Style'  )
cUp        = input.color (c5      , 'Fill color'           , inline='F'  , group='Style'  )
cDn        = input.color (c6      , ''                     , inline='F'  , group='Style'  )
candUp1    = input.color (c7      , 'Mini Candles -> Right', inline='C1' , group='Style'  )
candDn1    = input.color (c8      , ''                     , inline='C1' , group='Style'  )
candUp2    = input.color (c9      , 'Mini Candles <- Left' , inline='C2' , group='Style'  )
candDn2    = input.color (c10     , ''                     , inline='C2' , group='Style'  )
candW      = input.int   (11      , 'Mini Candles, body width', minval= 1, group='Style'  )
________________________________________________________________________________________________________________________                                                                                                                                                                                                :='
 ⎞  Functions  ⎛
 (__---------__)                                                                                                                                                                                                                                                                                                                       '

method lb( chart.point  point
             ,   int    textcolor 
           ) =>  label.new(
                 point
             ,   text      = '●'
             ,   size      = 8
             ,   textcolor = textcolor == 1 ? cSmall1 : cSmall2
             ,   style     = label.style_label_center
             ,   color     = color(na)
             )

method update(ln lin, chart.point c, int i) => 
    if candles
        up = i == 1 ? candUp1 : candUp2 
        dn = i == 1 ? candDn1 : candDn2
        mn = math.min(lin.op, c.price), mx = math.max(lin.op, c.price)
        lin.wTop.set_y1(math.max(lin.wTop.get_y1(), c.price)), lin.wTop.set_y2(mx)
        lin.wBot.set_y1(math.min(lin.wBot.get_y1(), c.price)), lin.wBot.set_y2(mn)
        lin.body.set_y1(mx), lin.body.set_y2(mn)
        lin.wTop.set_color(c.price > lin.op ? up : dn)                                  
        lin.body.set_color(c.price > lin.op ? up : dn)
        lin.wBot.set_color(c.price > lin.op ? up : dn)

method loop(string ltf, string btf) => 
    n = bar_index
    INV = color(na)
    CTF = timeframe.in_seconds(timeframe.period) // C - Current TF
    BTF_= timeframe.in_seconds(btf)              // B - Bottom TF
    LTF_= timeframe.in_seconds(ltf)              // L - Lower TF
    BTF = math.min(BTF_, LTF_)
    LTF = math.max(BTF_, LTF_)

    ratio_C_B = CTF / BTF    
    ratio_C_L = CTF / LTF
    ratio_L_B = LTF / BTF
    mod = ratio_C_L % 2 , even = mod == 0

    ratio_C_B2 = even ? ratio_C_B / 2 : ratio_C_B / 2 - ((ratio_C_B / 2) % ratio_L_B)
    ratio_C_L2 = ratio_C_L / 2

    int counter = 0
    int   i     = na
    float avg   = na      
    color col   = close > open ? cUp : cDn

    ln lin = na 
    if candles 
        lin := ln.new(line.new(n+1, open, n+1, open), line.new(n+1, open, n+1, open, width=candW), line.new(n+1, open, n+1, open), open)

    polyline polyL1 = na, aPointsLTF1 = array.new<chart.point>(), aPointsLTF1.push(chart.point.from_index(n            , open))
    polyline polyL2 = na, aPointsLTF2 = array.new<chart.point>(), aPointsLTF1.push(chart.point.from_index(n + ratio_L_B, open))           
    polyline polyB  = na, aPointsBTF  = array.new<chart.point>()
    if showBTF 
        aPointsBTF.push(chart.point.from_index(n, open))
    polyline polyLF = na

    p  = chart.point.from_index(na, na)              // general reusable point
    lp = chart.point.from_index(na, na)              // general reusable point
    z  = chart.point.from_index(n, na)               // point for "test" label and for progress of price
    l  = chart.point.from_index(n, high)             // point for "left" label
    r  = chart.point.from_index(n + ratio_L_B, high) // point for "right" label

    label test  = na, label left  = na, label right = na 
    if show
        test  := label.new(z, "", style=label.style_label_up)
        left  := label.new(l, "L", color=color.yellow, textcolor=color.black)
        right := label.new(r, "R", color=color.yellow, textcolor=color.black)


    if barstate.islast      
        label  lab = chart.point.from_index(n, open).lb(1)  //highlights latest price (dot)
        string txt = ''                                     //gathers error info
        if BTF < CTF and LTF < CTF
            //error
            if ratio_C_B2 > 500 or LTF < BTF * 2
                if ratio_C_B2 > 500
                    txt += str.format("\n`Current Chart timeframe` / `Lower Timeframe` should be less then 500 ({0}/{1}/2 = {2})", CTF, BTF, ratio_C_B)
                if LTF < BTF * 2
                    txt += "\n`Lower Timeframe` should minimal be twice the `Base (smallest) Timeframe`"
                0
            else                            
                res_ = timeframe.from_seconds(math.min(CTF, BTF))
                points = request.security_lower_tf('', res_, chart.point.from_time(time_close, close)) // close + time of LTF
                idx = n
                ix = n
                //
                if points.size() > 0
                    for [x, c] in points
                        //to the right
                        if counter == 0
                            i   := math.round((c.time - time) * 0.001 / BTF)                                      
                            avg := math.avg(l.index, r.index)
                            //small point    
                            z.index := n + i, z.price := c.price  
                            test.set_point(z), test.set_text(str.tostring(i))
                            //
                            //if beyond right limit, go to next code block
                            if i > ratio_C_B2            
                                p := aPointsBTF.last()
                                p := chart.point.from_index(r.index, p.price)
                                aPointsBTF.clear(), aPointsBTF.push(p), lab := p.lb(2)
                                aPointsLTF2.push(p)
                                aPointsLTF2.push(chart.point.from_index(p.index - (even ? ratio_L_B : 0), p.price))
                                if candles
                                    if even 
                                        lp := chart.point.from_index(r.index - 1, p.price)
                                    else 
                                        lp := chart.point.from_index(r.index + 1, p.price)
                                    lin := ln.new(line.new(lp, lp), line.new(lp, lp, width=candW), line.new(lp, lp), p.price)

                                if showBTF
                                    polyB := polyline.new(aPointsBTF, line_color=cSmall2, line_style=lineStyleS, line_width=lineWidthS)
                                counter += even ? 2 : 1 //if even -> skip "else if counter == 1" block
                                if not even
                                    l.index += ratio_L_B
                                    r.index += ratio_L_B 
                                if show 
                                    left .set_point(l), left .set_color(even ? color.blue : color.gray), left .set_textcolor(color.white)
                                    right.set_point(r), right.set_color(even ? color.blue : color.gray), right.set_textcolor(color.white)
                                //p := aPointsLTF1.last()
                                //aPointsLTF2.push(chart.point.from_index(p.index, p.price))
                                //aPointsLTF2.push(chart.point.from_index(p.index - (even ? ratio_L_B : 0), c.price))
                            //
                            //still before right limit
                            else
                                //exceeds right
                                if z.index > r.index
                                    //add last point to new small loop with r index 
                                    p   := aPointsBTF.last()
                                    p   := chart.point.from_index(r.index, p.price)
                                    aPointsBTF.clear(), aPointsBTF.push(p), lab := p.lb(1)   
                                    if candles                                  
                                        lp  := chart.point.from_index(r.index + 1, p.price)
                                        lin := ln.new(line.new(lp, lp), line.new(lp, lp, width=candW), line.new(lp, lp), p.price)

                                    if showBTF
                                        polyB := polyline.new(aPointsBTF, line_color=cSmall1, line_style=lineStyleS, line_width=lineWidthS)
                                    l.index += ratio_L_B 
                                    r.index += ratio_L_B
                                    if show 
                                        left .set_point(l)
                                        right.set_point(r)
                                    p := chart.point.from_index(r.index, c.price)
                                    aPointsLTF1.push(p)
                                else 
                                    p := aPointsLTF1.last(), p.price := c.price
                                    if z.index <= avg or not loopBTF or not showBTF
                                        p := chart.point.from_index(z.index, z.price)
                                        aPointsBTF.push(p), lab.set_point(p)
                                    else 
                                        p := chart.point.from_index(l.index + (r.index - z.index), z.price)
                                        aPointsBTF.push(p), lab.set_point(p)
                                    if showBTF
                                        polyB.delete(), polyB := polyline.new(aPointsBTF, line_color=cSmall1, line_style=lineStyleS, line_width=lineWidthS)

                                    lin.update(c, 1)

                            //
                            polyL1.delete(), polyL1 := polyline.new(aPointsLTF1, line_color=cLarge1, line_style=lineStyleL, line_width=lineWidthL)    
                            //
                            0

                        //right side
                        else if counter == 1 
                            //update large loop
                            //p := aPointsLTF2.last(), p.price := c.price
                            //
                            i := math.round(((c.time - time) * 0.001 / BTF))  
                            avg := math.avg(l.index, r.index)       
                            //
                            if n + i < avg
                                z.index := n + i 
                            else 
                                z.index := math.round((r.index - (n + i)) + l.index) // n + i 
                            z.price := c.price  
                            test.set_point(z) , test.set_text(str.tostring(i))
                            //
                            //beyond limit when returning -> next code block
                            if z.index < l.index 
                                //add last point to new small loop with r index 
                                p   := aPointsBTF.last()
                                p   := chart.point.from_index(l.index, p.price)
                                aPointsBTF.clear(), aPointsBTF.push(p), lab := p.lb(2)                                       
                                if candles
                                    lp  := chart.point.from_index(l.index - 1, p.price)      
                                    lin := ln.new(line.new(lp, lp), line.new(lp, lp, width=candW), line.new(lp, lp), p.price)
                                    
                                if showBTF
                                    polyB := polyline.new(aPointsBTF, line_color=cSmall2, line_style=lineStyleS, line_width=lineWidthS)
                                counter += 1 // 2
                                l.index -= ratio_L_B                                    
                                r.index -= ratio_L_B
                                if show 
                                    left .set_point(l), left .set_color(color.blue)
                                    right.set_point(r), right.set_color(color.blue)
                                aPointsLTF2.push(chart.point.from_index(l.index, c.price))
                            else
                                p := aPointsLTF2.last(), p.price := c.price
                                p := chart.point.from_index(z.index, z.price)
                                aPointsBTF.push(p), lab.set_point(p)
                                if showBTF
                                    polyB.delete(), polyB := polyline.new(aPointsBTF, line_color=cSmall2, line_style=lineStyleS, line_width=lineWidthS)
                                
                                lin.update(c, 2)
                            //
                            polyL2.delete(), polyL2 := polyline.new(aPointsLTF2, line_color=cLarge2, line_style=lineStyleL, line_width=lineWidthL)   
                            //
                            0

                        //to the left
                        else                                             
                            avg := math.avg(l.index, r.index)   
                            i := math.round(((time_close - c.time) * 0.001 / BTF))  
                            z.index := n + i 
                            z.price := c.price  
                            test.set_point(z) 
                            test.set_text(str.tostring(i))
                            //
                            if i >= 0 
                                //exceeds left
                                if z.index < l.index 
                                    //add last point to new small loop with r index 
                                    p := aPointsBTF.last()
                                    p := chart.point.from_index(l.index, p.price)
                                    aPointsBTF.clear(), aPointsBTF.push(p), lab := p.lb(2)                                    
                                    if candles
                                        lp  := chart.point.from_index(l.index - 1, p.price)      
                                        lin := ln.new(line.new(lp, lp), line.new(lp, lp, width=candW), line.new(lp, lp), p.price)
                                   
                                    if showBTF
                                        polyB := polyline.new(aPointsBTF, line_color=cSmall2, line_style=lineStyleS, line_width=lineWidthS)
                                    l.index -= ratio_L_B
                                    r.index -= ratio_L_B 
                                    if show 
                                        left .set_point(l)      
                                        right.set_point(r)                                     
                                    aPointsLTF2.push(chart.point.from_index(l.index, c.price))
                                else 
                                    p := aPointsLTF2.last(), p.price := c.price
                                    //point before middle L-R
                                    if z.index >= avg or not loopBTF or not showBTF
                                        p := chart.point.from_index(z.index, c.price)
                                        aPointsBTF.push(p), lab.set_point(p)
                                    else       
                                        p := chart.point.from_index(math.round(r.index - (z.index - l.index)), c.price)                                       
                                        aPointsBTF.push(p), lab.set_point(p)
                                    if showBTF
                                        polyB.delete(), polyB := polyline.new(aPointsBTF, line_color=cSmall2, line_style=lineStyleS, line_width=lineWidthS)
                                
                                    lin.update(c, 2)
                            //
                            polyL2.delete(), polyL2 := polyline.new(aPointsLTF2, line_color=cLarge2, line_style=lineStyleL, line_width=lineWidthL)   
                            //
                            0

                        if aPointsLTF1.size() > 0   
                            aPointsFill = aPointsLTF1.copy() 
                            if aPointsLTF2.size() > 0 
                                aPointsFill := aPointsFill.concat(aPointsLTF2)
                            polyLF.delete(), polyLF := polyline.new(aPointsFill, line_color=INV, fill_color = col)  
                0
        else 
            //error
            txt += "\n`Lower Timeframes` should be lower then current chart timeframe"
            0
        if txt != "" 
            var tab = table.new(position.top_right, 1, 1, color(na), color(na))
            tab.cell(0, 0, txt, text_size=20, text_color=#ff0000)
________________________________________________________________________________________________________________________                                                                                                                                                                                                :='
 ⎞  Exec  ⎛
 (__----__)                                                                                                                                                                                                                                                                                                                       '

for pol in polyline.all 
    pol.delete() 
for lin in line.all 
    lin.delete() 
for lab in label.all 
    lab.delete()

res.loop(res2)  
________________________________________________________________________________________________________________________                                                                                                                                                                                                :='
 ⎞  End  ⎛
 (__---__)                                                                                                                                                                                                                                                                                                                        '
````
