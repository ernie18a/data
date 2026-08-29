<!-- tradingview-pine-id: PUB;c287cb08a48a4fa485921c44e49a34fe -->
<!-- tradingviewscripts-format: 1 -->
# Periodic Linear Regressions [LuxAlgo]

Source: https://www.tradingview.com/script/mKEtjG7e-Periodic-Linear-Regressions-LuxAlgo/

## Description

The Periodic Linear Regressions (PLR) indicator calculates linear regressions periodically (similar to the VWAP indicator) based on a user-set period (anchor). 

This allows for estimating underlying trends in the price, as well as providing potential supports/resistances.

🔶 USAGE

[image]https://www.tradingview.com/x/JLOknjQC/[/image]

The Periodic Linear Regressions indicator calculates a linear regression over a user-selected interval determined from the selected "Anchor Period".

The PLR can be visualized as a regular linear regression (Static), with a fit readjusting for new data points until the end of the selected period, or as a moving average (Rolling), with new values obtained from the last point of a linear regression fitted over the calculation interval. While the static method line is prone to repainting, it has value since it can further emphasize the linearity of an underlying trend, as well as suggest future trend directions by extrapolating the fit.

[image]https://www.tradingview.com/x/j1sOjwMS/[/image]

Extremities are included in the indicator, these are obtained from the root mean squared error (RMSE) between the price and calculated linear regression. The Multiple setting allows the users to control how far each extremity is from the other.

Periodic Linear Regressions can be helpful in finding support/resistance areas or even opportunities when ranging in a channel.

[image]https://www.tradingview.com/x/pceT92sa/[/image]

[image]https://www.tradingview.com/x/CQqvCExm/[/image]

The anchor - where a new period starts - can be shown (in this case in the top right corner).

[image]https://www.tradingview.com/x/l3QpoE1A/[/image]

The shown bands can be visualized by enabling Show Extremities in settings (Rolling or Static method). 

[image]https://www.tradingview.com/x/goATD7u7/[/image]

The script includes a background gradient color option for the bands, which only applies when using the Rolling method.

The indicator colors can be suggestive of the detected trend and are determined as follows:

[*]Method Rolling: a gradient color between red and green indicates the trend; more green if the output is rising, suggesting an uptrend, and more red if it is decreasing, suggesting a downtrend.       
[*]Method Static: green if the slope of the line is positive, suggesting an uptrend, red if negative, suggesting a downtrend.

🔶 DETAILS

🔹 Anchor Type  

When the Anchor Type is set to Periodic, the indicator will be reset when the "Anchor Period" changes, after which calculations will start again.

An anchored rolling line set at First Bar won't reset at a new session; it will continue calculating the linear regression from the first bar to the last; in other words, every bar is included in the calculation. This can be useful to detect potential long-term tops/bottoms.

[image]https://www.tradingview.com/x/R3Z3Zr14/[/image]

Note that a linear regression needs at least two values for its calculation, which explains why you won't see a static line at the first bar of the session. The rolling linear regression will only show from the 3rd bar of the session since it also needs a previous value.

🔹 Rolling/Static  

When Anchor Type is set at Periodic, a linear regression is calculated between the first bar of the chosen session and the current bar, aiming to find the line that best fits the dataset.

[image]https://www.tradingview.com/x/lGEKtc2O/[/image]

The example above shows the lines drawn during the session. The offered script, though, shows the last calculated point connected to the previous point when the Rolling method is chosen, while the Static method shows the latest line. 

[image]https://www.tradingview.com/x/RqCjpzM0/[/image]

Note that linear regression needs at least two values, which explains why you won't see a static line at the first bar of the session. The rolling line will only show from the 3rd bar of the session since it also needs a previous value.

🔶 SETTINGS

[*]Method: Indicator method used, with options: "Static" (straight line) / "Rolling" (rolling linear regression).
[*]Anchor Type: "Periodic / First Bar" (the latter works only when "Method" is set to "Rolling").
[*]Anchor Period: Only applicable when "Anchor Type" is set at "Periodic".
[*]Source: open, high, low, close, ...
[*]Multiple: Alters the width of the bands when "Show Extremities" is enabled.
[*]Show Extremities: Display one upper and one lower extremity.

🔹 Color Settings

[*]Mono Color: color when "Bicolor" is disabled
[*]Bicolor: Toggle on/off + Colors
[*]Gradient: Background color when "Show extremities" is enabled + level of gradient

🔹 Dashboard

[*]Show Dashboard 
[*]Location of dashboard
[*]Text size

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator(    'Periodic Linear Regressions [LuxAlgo]'
 , shorttitle='LuxAlgo - Periodic Linear Regressions'
 , max_lines_count=500
 , overlay=true
 )

//---------------------------------------------------------------------------------------------------------------------}
// Settings
//---------------------------------------------------------------------------------------------------------------------{
choice       =                       input.string   ('Rolling', 'Method'      , options=[ 'Static', 'Rolling'])
anchor       =                       input.string   ('Periodic','Anchor Type' , options=['Periodic', 'First Bar']
             ,                       tooltip        =  "'First Bar' -> Choice: 'Rolling' "                        )
res          =                       input.timeframe(   'W'   ,'Anchor Period'                                     )
src          =                       input.source   (close   , 'Source'                                             )
mult         =                       input.float    (1      ,  'Multiple'     , step=0.1 , minval=0.1                )
bands        =                       input.bool     (true  ,   'Show Extremities'                                     )
col          =                       input.color(#FF5D00 ,'Mono color          ', group='Color Settings', inline='1')
bicolor      =                       input.bool     (true   ,   'Bicolor        ' , group='Color Settings', inline='a')
colA         =                       input.color    (#089981,       ''          , group='Color Settings', inline='a')
colB         =                       input.color    (#F23645 ,      ''          , group='Color Settings', inline='a')
grad         =                       input.bool     (    true   , 'Gradient'      , group='Color Settings', inline='c')
grade        =                       input.int      (15,'    ' ,minval=0,maxval=50, group='Color Settings', inline='c')
showDash     =                       input.bool     (    true , 'Show Dashboard'  , group=    'Dashboard'           )
dashLoc      = str.replace(str.lower(input.string   (  'Top Right'                ,           'Location'  
   , options =                      ['Top Right' , 'Bottom Right', 'Bottom Left'] , group=  'Dashboard'        ))
   , ' ', '_')
textSize     =             str.lower(input.string   ( 'Normal'                    ,             'Size'      
   , options =                      ['Tiny', 'Small', 'Normal']                   , group='Dashboard'    ))

//---------------------------------------------------------------------------------------------------------------------}
//Variables
//---------------------------------------------------------------------------------------------------------------------{
var tb = table.new(dashLoc, 2, 3
  , bgcolor      = #1e222d
  , border_color = #373a46
  , border_width = 1
  , frame_color  = #373a46
  , frame_width  = 1)

lbi = last_bar_index
n   = bar_index
INV = color(na)

//---------------------------------------------------------------------------------------------------------------------}
//Function
//---------------------------------------------------------------------------------------------------------------------{
draw(res, src, choice, anchor, bands, col, idx) =>

    float yMx    = na
    float dist   = na

    ch = timeframe.change(res)

    var line ln  = na
    var line lnU = na
    var line lnD = na

    var aX  = array.new< int >()        
    var aY  = array.new<float>()
    var Ex  = 0.   , var Ey  = 0. 
    var Ex2 = 0.   , var Exy = 0.  
    var N   = 0

    Ex   += n                //sum x
    Ey   += src              //sum y 
    Ex2  += math.pow(n, 2)   //sum x²
    Exy  += n * src          //sum x*y
    N    += 1                //population size

    //add x & y values to array
    aX.unshift( n )
    aY.unshift(src)

    cov   = aY. covariance(aX)
    x_var = aX.   variance(  )
    a_    =            cov / x_var
    b_    = aY.avg() - a_  * aX.avg()
    r2    = math.pow(  cov / (aY.stdev() 
                           *  aX.stdev()), 2)
    rss   = aY.variance()  
          - r2 
          * aY.variance()         

    dist := math.sqrt(rss) 
          * mult

    m = (N * Exy - Ex * Ey) / (N * Ex2 - math.pow(Ex, 2))
    b = (Ey - m * Ex) / N

    yMx := m * n + b
    
    if choice == 'Static'    
        cl = bicolor 
           ? ln.get_y2() > ln.get_y1() 
           ? colA : colB : col

        x1 =      ln.get_x1()    
        ln.set_xy2(n ,   yMx ) 
        ln.set_y1 (m * x1 + b)

        if bicolor 
            ln.set_color(cl)

        if bands 
            lnU.set_xy2(n , yMx   +   dist)
            lnU.set_y1 (m * x1  + b + dist)
            lnU.set_color(cl)

            lnD.set_xy2(n , yMx   -   dist)
            lnD.set_y1 (m * x1  + b - dist)
            lnD.set_color(cl)

    if ch
        if  anchor == 'Periodic' 
         or choice == 'Static' 
            Ex  := 0. 
            Ey  := 0. 
            Ex2 := 0. 
            Exy := 0. 
            aX.clear() 
            aY.clear()
        N   := 0
        if choice == 'Static'    
            ln      := line.new(n, src       , n, src       , color=col)
            if bands 
                lnU := line.new(n, src + dist, n, src + dist, color=col)
                lnD := line.new(n, src - dist, n, src - dist, color=col)

    R = cov / (aX.stdev() * aY.stdev())

    [  choice == 'Rolling'           ? yMx        : na
     , choice == 'Rolling' and bands ? yMx + dist : na
     , choice == 'Rolling' and bands ? yMx - dist : na 
     , R
     ]
            
//---------------------------------------------------------------------------------------------------------------------}
//Execution
//---------------------------------------------------------------------------------------------------------------------{
[yMx, yMx_pos, yMx_min, R]    =    draw(res, src, choice, anchor, bands, col, 0)

//---------------------------------------------------------------------------------------------------------------------}
//Plot
//---------------------------------------------------------------------------------------------------------------------{
rolling    =    bicolor and choice == 'Rolling'
m = plot(yMx    , color=rolling ? color.from_gradient(R, -1, 1, colB, colA) : col, style=plot.style_linebr)
b = plot(yMx_min, color=rolling ? color              (         na         ) : col, style=plot.style_linebr)
t = plot(yMx_pos, color=rolling ? color              (         na         ) : col, style=plot.style_linebr)

fill(m, t, yMx, yMx_pos,  grad  ? color.new          ( 
                                  color.from_gradient(R, -1, 1, colB, colA) , 100                    ) : na
                       ,  grad  ? color.new          ( 
                                  color.from_gradient(R, -1, 1, colB, colA) , 100  -     grade       ) : na)
fill(m, b, yMx, yMx_min,  grad  ? color.new          ( 
                                  color.from_gradient(R, -1, 1, colB, colA) , 100                    ) : na
                       ,  grad  ? color.new          ( 
                                  color.from_gradient(R, -1, 1, colB, colA) , 100  -     grade       ) : na)

//---------------------------------------------------------------------------------------------------------------------}
//Dashboard
//---------------------------------------------------------------------------------------------------------------------{
if barstate.islast
    if showDash
        tb.cell(0, 0,     'HTF'        , text_color=color.white, text_size=textSize)
        tb.cell(1, 0, str.tostring(res), text_color=color.white, text_size=textSize)

//---------------------------------------------------------------------------------------------------------------------}
````
