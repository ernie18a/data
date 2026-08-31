<!-- tradingview-pine-id: PUB;ec44c9ba302742509692201feb7337a9 -->
<!-- tradingviewscripts-format: 1 -->
# TASC 2022.06 Ehlers Loops

Source: https://www.tradingview.com/script/5WXLRdaQ-TASC-2022-06-Ehlers-Loops/

## Description

█ OVERVIEW

[TASC's June 2022 edition Traders' Tips](https://traders.com/Documentation/FEEDbk_docs/2022/06/TradersTips.html) includes an article by John ​Ehlers titled "Ehlers Loops. Part 1". This is the code implementing the price-volume Ehlers Loops he introduced in the publication.

█ CONCEPTS

John ​Ehlers developed Ehlers loops as a tool to visualize the performance of one data stream versus another, both filtered and scaled. In this article, the author applies his concept to exploit and/or dispel the dogmatic principles of reliable price-volume relationships.

The script offers two different ways to visualize ​Ehlers Loops:

Oscillators (default option)

In this implementation, filtered and scaled ​volume is plotted along with filtered and scaled price as zero-mean oscillators. Observation of the relative direction of ​volume and price oscillators can be discretionarily used to interpret and predict market conditions. For example, it is generally assumed that an increase in ​volume and an increase in price define a ​bullish condition. Similarly, decreasing ​volume and increasing price are generally considered ​bearish. A decrease in ​volume and a decrease in price is considered a ​bullish condition. The increase in ​volume and decrease in price is often thought to be ​​bearish.

Scatterplot

This Crocker-style visualization displays filtered and scaled price against filtered and scaled ​volume for the selected timespan. Fluctuations in ​volume are plotted along the x-axis, while price changes along the y-axis. This way of visualizing the ​Ehlers Loop allows you to analyze the curvature and directional path of the price in relation to ​volume, offering a different comparative perspective. The boundaries of the price and ​volume scale on the ​Ehlers Loop Crocker-chart are presented in standard deviations. Deviations can be used to predict possible future price or ​volume fluctuations. The expected probability of potential reversals is 68%, 95% and 99.7% at one, two and three standard deviations, respectively.

█ CALCULATIONS

The following steps are used to build an ​Ehlers Loop:
 • Both price and ​volume are filtered to be [band-limited](https://en.wikipedia.org/wiki/Bandlimiting) signals. This is done by applying the [high-pass](https://en.wikipedia.org/wiki/High-pass_filter) Butterworth filter in combination with the [low-pass](https://en.wikipedia.org/wiki/Low-pass_filter) SuperSmooth filter.
  The cutoff wavelengths of the high-pass and low-pass filters are defined by the input parameters HPPeriod and LPPeriod, respectively.
  These values change the appearance of the ​Ehlers Loops and can be customized to your trading style.
 • The filtered price and ​volume time series are then scaled in terms of [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) by dividing each by their root-mean-square values.
 • The resultant price and ​volume data are plotted as zero-mean oscillators or as a scatterplot.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PineCodersTASC

//  TASC Issue: June 2022 - Vol. 40, Issue 7
//     Article: Ehlers Loops
//  Article By: John F. Ehlers
//    Language: TradingView's Pine Script v5
// Provided By: PineCoders, for tradingview.com

//@version=5
indicator("TASC 2022.06 Ehlers Loops", "ELs", precision=3, max_lines_count=300, max_labels_count=300, max_boxes_count=300)

// Crocker chart constants:
string _B0_ = '✸', _B1_ = '✜', _B2_ = '◉', _B3_= '・', _B4_ = 'x'
string _LS0_ = 'dashed', _LS1_ = 'dotted', _LS2_ = 'solid'
_lineStyleHelper(style)=>
    switch style
        'dashed' => line.style_dashed
        'dotted' => line.style_dotted
        'solid'  => line.style_solid
color  c_devbox_border = color.rgb(  250, 250, 100, 60)
color  c_devbox_bg     = #00000020
int    i_barScale      = 100 

source    = input.source(close,      "Source")
mode      = input.string(defval='Oscillators', options=['Oscillators', 'Scatter Plot'], title = 'Output mode')
periodLP  = input.int( 20,  "Low-Pass Period", minval= 7)
periodHP  = input.int(125, "High-Pass Period", minval=20)
periodRMS = input.int( 80,       "RMS Period",   step=10)
// Crocker graph inputs:
string ig_graph = 'Scatterplot Options:'
i_depth         = input.int(    20,          title = 'Scatter Plot Timespan',      group=ig_graph)
i_col_devbox    = input.color(  #ffffa080,   title = 'Box Color', group=ig_graph)
i_bul0          = input.string( defval=_B2_, title = 'Symbol', options=[_B0_, _B1_, _B2_, _B3_, _B4_], group=ig_graph)
i_col0          = input.color(  color.red,   title = 'Symbol Color', group=ig_graph)
i_size          = input.string( size.small,  title = 'Symbol Size', options=[size.small, size.normal, size.large, size.huge], group = ig_graph)
i_ls0           = _lineStyleHelper(input.string(defval=_LS0_, options=[_LS0_, _LS1_, _LS2_], title='Line', group=ig_graph))


//== 2 Pole Butterworth Highpass Filter ==//
butterworthHP(float Series, float Period) =>
    var float ALPHA =  math.pi * math.sqrt(2.0) / Period
    var float BETA  =  math.exp(-ALPHA )
    var float COEF2 = -math.pow(BETA, 2)
    var float COEF1 =  math.cos( ALPHA ) * 2.0 * BETA
    var float COEF0 =  (1.0 + COEF1 - COEF2) * 0.25
    float tmp    = nz(Series[1],  Series)
    float whiten =    Series + nz(Series[2], tmp) - 2.0 * tmp 
    float smooth = na, smooth := COEF0 *     whiten     +
                                 COEF1 *  nz(smooth[1]) +
                                 COEF2 *  nz(smooth[2])

//===== 2 Pole Super Smoother Filter =====//
superSmoother(float Series, float Period) =>
    var float ALPHA =  math.pi * math.sqrt(2.0) / Period
    var float BETA  =  math.exp(-ALPHA )
    var float COEF2 = -math.pow(BETA, 2)
    var float COEF1 =  math.cos( ALPHA ) * 2.0 * BETA
    var float COEF0 =  1.0 - COEF1 - COEF2
    float sma2   = math.avg(Series, nz(Series[1], Series))
    float smooth = na, smooth := COEF0 *      sma2      +
                                 COEF1 *  nz(smooth[1]) +
                                 COEF2 *  nz(smooth[2])

//===== Faster Root Mean Square =====//
fastRMS(float Series, float Period) =>
    if Period < 1
        runtime.error("Err: fastRMS(Period=) is less than 1")
    var float COEF0 = 2.0 / (Period + 1)
    var float COEF1 = 1.0 -  COEF0
    float pow = math.pow(Series, 2)
    float ema = na, ema := COEF0 *    pow +
                           COEF1 * nz(ema[1], pow)
    nz(Series / math.sqrt(ema))

//==== Normalized Roofing Filter for Price ====//
float HP       = butterworthHP(source, periodHP )
float Price    = superSmoother(    HP, periodLP )
float PriceRMS =       fastRMS( Price, periodRMS)

//=== Normalized Roofing Filter for Volume ==//
float VolHP  = butterworthHP(volume, periodHP )
float Vol    = superSmoother( VolHP, periodLP )
float VolRMS =       fastRMS(   Vol, periodRMS)


//=== Output/Visualization ==//
bool isOsc = mode=='Oscillators'

// Option 1: Visalize the data as two separate oscillator time series
plot(isOsc?PriceRMS:na, "Area", #0077FF40, style=plot.style_area)
plot(isOsc?PriceRMS:na, "PRMS", #0077FF, 2)
plot(  isOsc?VolRMS:na, "VRMS", #FF7700)
hline(     2.0,   "2σ", #FF0000CC)
hline(     1.0,   "1σ", #FF000055, hline.style_dotted, 2)
hline(     0.0, "Zero", #808080)
hline(    -1.0,  "-1σ", #00FF0055, hline.style_dotted, 2)
hline(    -2.0,  "-2σ", #00FF00CC)

// Option 2: Visualize the data as a scatterplot (Crocker chart)
// @function Draws deviation boxes
DrawDeviationBox (int deviations, color bgcolor, int bar_scale=100) =>
    int halfWidth = int(deviations * bar_scale)
    if  halfWidth > 500
        runtime.error('Width must be less than 500.')
    if barstate.islast
        var Box = box.new(
          bar_index, deviations, bar_index, -deviations,
         border_color=bgcolor, border_style=line.style_dotted,
         bgcolor=color.new(bgcolor, 96), text_size=size.small,
           text=str.tostring(deviations)   +  ' deviations',
           text_color=bgcolor,  text_valign=text.align_bottom)
        box.set_left( Box, bar_index - halfWidth)
        box.set_right(Box, bar_index + halfWidth)
//
// @function Draws the labels
DrawDeviationBoxLabels (color text_color=#ffffa080, color bg_color=#00000020, int bar_scale=100, string size=size.small) =>
    int right = bar_index + 3 * bar_scale
    int  left = bar_index - 3 * bar_scale
    var label l_top_right = label.new(right,  3.0, 'Up Price | Up Volume'    , color=bg_color, style=label.style_label_down, textcolor=text_color, size=size)
    var label l_bot_right = label.new(right, -3.0, 'Down Price | Up Volume'  , color=bg_color, style=label.style_label_up  , textcolor=text_color, size=size)
    var label l_top_left  = label.new(left ,  3.0, 'Up Price | Down Volume'  , color=bg_color, style=label.style_label_down, textcolor=text_color, size=size)
    var label l_bot_left  = label.new(left , -3.0, 'Down Price | Down Volume', color=bg_color, style=label.style_label_up  , textcolor=text_color, size=size)
    label.set_x(l_top_right, right)
    label.set_x(l_bot_right, right)
    label.set_x(l_top_left,  left)
    label.set_x(l_bot_left,  left)
//
// @function Helper method to draw the symbol data over the cartesian space, where 1 unit == 1 deviation.
DrawCrockerSegment (
  string symbol, float vol, float price, 
  int depth=5, 
  color tcolor=color.blue, 
  string style=line.style_dashed, 
  string bullet='⦿', 
  string size=size.small,
  int bar_scale=100
  ) => //
  //
    var _Li = array.new<line>(depth)
    var _La = array.new<label>(depth+1)
    float _sump = 0.0
    float _sumv = 0.0
    if bar_index > depth
        for _i = depth to 0
            float _cv = vol[_i+1]
            float _cp = price[_i+1]
            if _i < depth
                int _x1 = bar_index + math.min(500, int(_sumv * bar_scale))
                int _x2 = bar_index + math.min(500, int(_cv * bar_scale))
                //
                line _line = line.new(
                     x1=_x1, y1=_sump, 
                     x2=_x2, y2=_cp, 
                     color=tcolor,
                     style=style, 
                     width=1//math.max(1, int((_i / depth) * 5.0))
                     )
                label _lab = label.new(
                     x=_x2, y=_cp, 
                     text=bullet, 
                     color=color.rgb(0,0,0,99), 
                     style=label.style_label_center, 
                     textcolor=tcolor, size=size)
                //
                line.delete(array.get(_Li, _i))
                array.set(_Li, _i, _line)
                label.delete(array.get(_La, _i+1))
                array.set(_La, _i+1, _lab)
                if _i == depth-1
                    label.delete(array.get(_La, 0))
                    label _lab1 = label.new(
                         x=_x1, y=_sump, 
                         text=symbol, 
                         color=color.rgb(0,0,0,60), 
                         style=label.style_label_center, 
                         textcolor=tcolor, size=size.small)
                    array.set(_La, 0, _lab1)
            _sump := _cp
            _sumv := _cv
//
if not isOsc
    DrawDeviationBox(3, i_col_devbox, i_barScale)
    DrawDeviationBox(2, i_col_devbox, i_barScale)
    DrawDeviationBox(1, i_col_devbox, i_barScale)
    DrawDeviationBoxLabels(c_devbox_border, c_devbox_bg, i_barScale, size.small)
    DrawCrockerSegment(array.get(str.split(syminfo.tickerid, ':'), 1), VolRMS, PriceRMS, i_depth, i_col0, i_ls0, i_bul0, i_size, i_barScale)
````
