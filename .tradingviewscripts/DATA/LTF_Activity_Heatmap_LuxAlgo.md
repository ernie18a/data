<!-- tradingview-pine-id: PUB;bfc3f73fdd814dfcbe6966c3728035c0 -->
<!-- tradingviewscripts-format: 1 -->
# LTF Activity Heatmap [LuxAlgo]

Source: https://www.tradingview.com/script/ZX1z1Z2r-Liquidity-Heatmap-LTF-LuxAlgo/

## Description

This indicator displays column heatmaps highlighting candle bodies with the highest associated volume from a lower user selected timeframe. 

Settings

[*]LTF Timeframe: Lower timeframe used to retrieve the closing/opening price and volume data. Must be lower than the current chart timeframe.

Other settings control the style of the displayed graphical elements.

Usage

It can be of interest to show which candles from a lower timeframe had the highest associated volume, this allows for the highlighting of areas where a candle body was the most traded by market participants.

The area with the highest activity is highlighted in the script with a yellow color (or another user selected color) and additionally by two lines forming an interval.

[image]https://www.tradingview.com/x/HOQs0f8S/[/image]

When the candle body with the highest volume is overlapped by a candle body with lower volume this one will be highlighted instead, hence why certain areas of high activity might not be highlighted by the heatmap.

[image]https://www.tradingview.com/x/gR3LqMRu/[/image]

It is recommended to hide regular candles or use a more discrete graphical presentation of prices when using this tool. Lines are also displayed to highlight the full candle range as well as if a candle was bullish (in green) or bearish (in red). These lines can be hidden if the user is only interested in the heatmap.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator("LTF Activity Heatmap [LuxAlgo]"
  , overlay = true
  , max_boxes_count = 500
  , max_lines_count = 500)

//------------------------------------------------------------------------------
//Settings
//------------------------------------------------------------------------------

res = input.timeframe('1','LTF Timeframe')

//--------------
//Style settings
//--------------

heatmap_color0  = input(#0a0032,'Heatmap'
  , group  = 'Style'
  , inline = 'inline0')

heatmap_color1  = input(#880e4f,''
  , group  = 'Style'
  , inline = 'inline0')

heatmap_color2  = input(#ffeb3b,''
  , group  = 'Style'
  , inline = 'inline0')

bull_color = input(#0cb51a,'Lines'
  , group  = 'Style'
  , inline = 'inline1')
  
bear_color = input(#ff1100,''
  , group  = 'Style'
  , inline = 'inline1')

//------------------------------------------------------------------------------
//Requests ltf open, close, volume series
//------------------------------------------------------------------------------

n = bar_index

c = request.security_lower_tf(syminfo.tickerid, res, close)
o = request.security_lower_tf(syminfo.tickerid, res, open)
v = request.security_lower_tf(syminfo.tickerid, res, volume)

//------------------------------------------------------------------------------
//Display heatmaps
//------------------------------------------------------------------------------

css1 = close > open ? bull_color : bear_color

if array.size(c) != 0
    
    //--------------------------------------------------------------------------
    //Highlight candle range
    //--------------------------------------------------------------------------
    
    line.new(n
     , high
     , n
     , low
     , color = css1)
    
    //--------------------------------------------------------------------------
    //Display heatmap
    //--------------------------------------------------------------------------
    
    for i = 0 to array.size(c)-1
        get_v = array.get(v,i)
        get_o = array.get(o,i)
        get_c = array.get(c,i)
        
        css0 = color.from_gradient(
          get_v
          , array.min(v)
          , array.max(v)
          , heatmap_color0
          , heatmap_color1)
        
        box.new(
          n
          , get_o
          , n+1
          , get_c
          , bgcolor = get_v == array.max(v) ? heatmap_color2 : css0
          , border_color = na)
          
        //----------------------------------------------------------------------
        //Highest body with highest volume
        //----------------------------------------------------------------------
    
        if get_v == array.max(v)
            line.new(
              n
              , get_c
              , n+1
              , get_c
              , color = css1)
            
            line.new(
              n
              , get_o
              , n+1
              , get_o
              , color = css1)
````
