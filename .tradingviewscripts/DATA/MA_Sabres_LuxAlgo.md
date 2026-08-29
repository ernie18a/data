<!-- tradingview-pine-id: PUB;591a0eafa317404585a1bb85ee439571 -->
<!-- tradingviewscripts-format: 1 -->
# MA Sabres [LuxAlgo]

Source: https://www.tradingview.com/script/viwa6CR8-MA-Sabres-LuxAlgo/

## Description

The "MA Sabres" indicator highlights potential trend reversals based on a moving average direction. Detected reversals are accompanied by an extrapolated "Sabre" looking shape that can be used as support/resistance and as a source of breakouts.

🔶 USAGE

[image]https://www.tradingview.com/x/2bCsBu4A/[/image]

If a selected moving average (MA) continues in the same direction for a certain time, a change in that direction could signify a potential reversal.

[image]https://www.tradingview.com/x/nH7ccMlB/[/image]

In this publication, when a trend change occurs, a sabre-shaped figure is drawn which can be used as support/resistance:

A sabre can be indicative of a direction, however, it can also act as a stop-loss when the price should go in the opposite direction:

[image]https://www.tradingview.com/x/ecvkbx61/[/image]

Or show potential areas of interest:

[image]https://www.tradingview.com/x/FFli9z8i/[/image]

🔶 DETAILS

This publication will look for a change in direction after the MA went in the same direction during x consecutive bars (settings: "Reversal after x bars in the same direction").

Then a circle-shaped drawing will be drawn 1 bar back, at the previous high/low, dependable of the previous direction. 

From there originates a sabre-shaped figure where the tip lies as far as the user-set MA length.

[image]https://www.tradingview.com/x/28KNCiUF/[/image]

The angle of the "sabre" relies on the ATR of the previous 14 bars.

Less volatility will create a flatter sabre while the opposite is true when there is more volatility in the previous 14 bars.

[image]https://www.tradingview.com/x/ZIlZN7Fn/[/image]

The sabre is created by the latest feature, [polylines](https://www.tradingview.com/pine-script-reference/v5/#type_polyline), which enables us to connect several 'points', resulting in a [polyline.new()](https://www.tradingview.com/pine-script-reference/v5/#fun_polyline.new) object.

Do note that sabres are offset by one bar to the past to align their locations.

🔶 SETTINGS

[*]MA Type: SMA, EMA, SMMA (RMA), HullMA, WMA, VWMA, DEMA, TEMA, NONE (off)
[*]Length: this sets the length of MA, and the length of the sabre shape
[*]Previous Trend Duration: After the MA direction is the same for x consecutive bars, the first time the direction changes, a sabre is drawn

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator('MA Sabres [LuxAlgo]', shorttitle='LuxAlgo - MA Sabres', max_polylines_count=100, overlay=true)

//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
type       = input.string(  "TEMA" ,               'MA Type'               , group=   'MA'
 , options =   ["SMA", "EMA", "SMMA (RMA)", "HullMA", "WMA", "VWMA", "DEMA", "TEMA", "NONE"])
len        = input.int   (    50   ,                'Length'               , group=   'MA'  )
count      = input.int   (    20   ,       'Previous Trend Duration'       , group=   'MA'  
 , tooltip =                    'Reversal after x bars in the same direction'               )
colUp      = input.color (#2962ff,               'Bullish'               , group='Colours')
colDn      = input.color (#f23645,               'Bearish'               , group='Colours')
colMa      = input.color (#787b86,                  'MA'                 , group='Colours')


//-----------------------------------------------------------------------------}
//Method MA
//-----------------------------------------------------------------------------{
method ma(string type, int length) =>
    //
    ema1 = ta.ema(close, length)
    ema2 = ta.ema(ema1 , length)
    ema3 = ta.ema(ema2 , length)
    //
    switch type
        "SMA"        => ta.sma (close, length)
        "EMA"        => ema1
        "SMMA (RMA)" => ta.rma (close, length)
        "HullMA"     => ta.hma (close, length)
        "WMA"        => ta.wma (close, length)
        "VWMA"       => ta.vwma(close, length)
        "DEMA"       =>  2 * ema1  -      ema2
        "TEMA"       => (3 * ema1) - (3 * ema2) + ema3
        => na


//-----------------------------------------------------------------------------}
//Calculations
//-----------------------------------------------------------------------------{
ma    =            type.ma(len)
fl    = ta.falling(ma  , count)
rs    = ta.rising (ma  , count)
up    = fl[1] and  ma  >  ma[1] 
dn    = rs[1] and  ma  <  ma[1]  
atr   = ta.atr(14)
n     = bar_index

//-----------------------------------------------------------------------------}
//Execution
//-----------------------------------------------------------------------------{
if up 
    p = array.new<chart.point>()
    p.push(chart.point.from_index(n -           1  , low [1] - atr / 15 )) 
    p.push(chart.point.from_index(n + (len / 2 -1) , low [1] + atr / 2.5)) 
    p.push(chart.point.from_index(n +  len         , low [1] + atr * 2  )) 
    p.push(chart.point.from_index(n + (len / 2 -1) , low [1] + atr / 2.5)) 
    p.push(chart.point.from_index(n -           1  , low [1] + atr / 15 )) 
    polyline.new(p
      , curved = true
      , closed = false
      , line_color = colUp
      , fill_color = color.new(colUp, 50))

if dn 
    p = array.new<chart.point>()
    p.push(chart.point.from_index(n -           1  , high[1] + atr / 15 )) 
    p.push(chart.point.from_index(n + (len / 2 -1) , high[1] - atr / 2.5)) 
    p.push(chart.point.from_index(n +  len         , high[1] - atr * 2  )) 
    p.push(chart.point.from_index(n + (len / 2 -1) , high[1] - atr / 2.5)) 
    p.push(chart.point.from_index(n -           1  , high[1] - atr / 15 )) 
    polyline.new(p
      , curved = true
      , closed = false
      , line_color = colDn
      , fill_color = color.new(colDn, 50))

    
//-----------------------------------------------------------------------------}
//Plots
//-----------------------------------------------------------------------------{
plot     (ma , 'MA'    ,         color=          colMa                                                                                   )

plotshape(up ? low [1] : na, '', color=          colUp     ,  location=location.absolute, style=shape.circle, size=size.tiny  , offset=-1)
plotshape(up ? low [1] : na, '', color=color.new(colUp, 50),  location=location.absolute, style=shape.circle, size=size.small , offset=-1)
plotshape(up ? low [1] : na, '', color=color.new(colUp, 65),  location=location.absolute, style=shape.circle, size=size.normal, offset=-1)

plotshape(dn ? high[1] : na, '', color=          colDn     ,  location=location.absolute, style=shape.circle, size=size.tiny  , offset=-1)
plotshape(dn ? high[1] : na, '', color=color.new(colDn, 50),  location=location.absolute, style=shape.circle, size=size.small , offset=-1)
plotshape(dn ? high[1] : na, '', color=color.new(colDn, 65),  location=location.absolute, style=shape.circle, size=size.normal, offset=-1)
 
//-----------------------------------------------------------------------------}
````
