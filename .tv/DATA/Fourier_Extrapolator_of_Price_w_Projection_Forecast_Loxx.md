<!-- tradingview-pine-id: PUB;5c7061572f2d45aea9d23d3b434d4481 -->
<!-- tradingviewscripts-format: 1 -->
# Fourier Extrapolator of Price w/ Projection Forecast [Loxx]

Source: https://www.tradingview.com/script/u0r2gpti-Fourier-Extrapolator-of-Price-w-Projection-Forecast-Loxx/

## Description

Due to popular demand, I'm pusblishing Fourier Extrapolator of Price w/ Projection Forecast.. As stated in it's twin indicator, this one is also  multi-harmonic (or multi-tone) trigonometric model of a price series xi, i=1..n, is given by:

xi = m + Sum( a*Cos(w*i) + b*Sin(w*i), h=1..H )

Where:

[*]xi - past price at i-th bar, total n past prices;
[*]m - bias;
[*]a and b - scaling coefficients of harmonics;
[*]w - frequency of a harmonic ;
[*]h - harmonic number;
[*]H - total number of fitted harmonics.

Fitting this model means finding m, a, b, and w that make the modeled values to be close to real values. Finding the harmonic frequencies w is the most difficult part of fitting a trigonometric model. In the case of a Fourier series, these frequencies are set at 2*pi*h/n. But, the Fourier series extrapolation means simply repeating the n past prices into the future.

This indicator uses the Quinn-Fernandes algorithm to find the harmonic frequencies. It fits harmonics of the trigonometric series one by one until the specified total number of harmonics H is reached. After fitting a new harmonic , the coded algorithm computes the residue between the updated model and the real values and fits a new harmonic to the residue.

see here: [A Fast Efficient Technique for the Estimation of Frequency](https://www.jstor.org/stable/2337018) , B. G. Quinn and J. M. Fernandes, Biometrika, Vol. 78, No. 3 (Sep., 1991), pp . 489-497 (9 pages) Published By: Oxford University Press

The indicator has the following input parameters:

[*]src - input source
[*]npast - number of past bars, to which trigonometric series is fitted;
[*]Nfut - number of predicted future bars;
[*]nharm - total number of harmonics in model;
[*]frqtol - tolerance of frequency calculations.

The indicator plots two curves: the green/red curve indicates modeled past values and the yellow/fuchsia curve indicates the modeled future values.

The purpose of this indicator is to showcase the Fourier Extrapolator method to be used in future indicators.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2. at https://mozilla.org/MPL/2./
// © loxx

//@version=5
indicator("Fourier Extrapolator of Price w/ Projection Forecast [Loxx]", shorttitle = "FEPFP [Loxx]", overlay = true, max_lines_count = 500)

greencolor = #2DD204
redcolor = #D2042D 

src = input.source(open, "Source", group = "Basic Settings")
npast = input.int(300, "Caculation Bars", maxval = 500, group = "Fourier Extrapolator Settings")
nharm = input.int(20, "Harmonic Period", minval = 1, group = "Fourier Extrapolator Settings")
frqtol = input.float(0.0001, "Frequency Tolerance", group = "Fourier Extrapolator Settings")
nfut = input.int(100, "Forecast Bars", group = "Fourier Extrapolator Settings")
backbars = input.int(100, "Bars back to start forecast", group = "Fourier Extrapolator Settings", minval = 0)

allcolorbars = input.bool(false, "Mute all bar colors?", group = "UI Options")
fcolorbars = input.bool(false, "Mute forecast bar colors?", group = "UI Options")

plinewidth = input.int(5, "Past Line width", group = "UI Options")
flinewidth = input.int(5, "Forecast Line width", group = "UI Options")

x = array.new<float>(npast, 0.)
xm = array.new<float>(npast, 0.)
ym = array.new<float>(nfut + 1, 0.)

if npast + nfut > 500 
    runtime.error("You must adjust nfut and npast so that they add up to 500 or less") 
    
var pvlines = array.new_line(0)
var fvlines = array.new_line(0)

if barstate.isfirst
    for i = 0 to npast - 2 
        array.push(pvlines, line.new(na, na, na, na))
    for i = 0 to nfut - 2 
        array.push(fvlines, line.new(na, na, na, na))

if barstate.islast
    av = 0.
    for i = 0 to npast - 1 
        array.set(x, i, nz(src[i + backbars])) 
        av += array.get(x, i)
    av /= npast
    
    //--- initialize model outputs
    for i = 0 to npast - 1
        array.set(xm, i, av)
        if (i <= nfut) 
            array.set(ym, i,  av)
            
    beta = 0.
    alpha = 0.
    w = 0., m= 0., a= 0., b= 0.
    z = array.new<float>(npast, 0.)
    
    array.set(z, 0, array.get(x, 0))
    //--- fit trigonometric model and calculate predictions
    for harm = 1 to nharm
        //+------------------------------------------------------------------+
        //| Quinn and Fernandes algorithm for finding frequency              |
        //+------------------------------------------------------------------+
        alpha := 0.
        beta := 2.
        array.set(z, 0, array.get(x, 0) - array.get(xm, 0))
        while math.abs(alpha - beta) > frqtol  
            alpha := beta
            array.set(z, 1, array.get(x, 1) - array.get(xm, 1) + alpha * array.get(z, 0))
            num = array.get(z, 0) * array.get(z, 1)
            den = array.get(z, 0) * array.get(z, 0)
            for i = 2 to npast - 1
                array.set(z, i, array.get(x, i) - array.get(xm, i) + alpha * array.get(z, i - 1) - array.get(z, i - 2))
                num += array.get(z, i - 1) * (array.get(z, i) + array.get(z, i - 2))
                den += array.get(z, i - 1) * array.get(z, i - 1)
            beta := num / den
        w := math.acos(math.min(math.max(beta / 2.0, -1), 1))
    
        //+------------------------------------------------------------------+
        //| Least-squares fitting of trigonometric series                    |
        //+------------------------------------------------------------------+
        Sc = 0.,  Ss = 0., Scc = 0.
        Sss = 0., Scs = 0., Sx = 0.
        Sxc = 0., Sxs = 0., den = 0.
        n = npast
        for i = 0 to npast - 1
            c = math.cos(w * i)
            s = math.sin(w * i)
            dx = array.get(x, i) - array.get(xm, i)
            Sc += c
            Ss += s
            Scc += c * c
            Sss += s * s
            Scs += c * s
            Sx += dx
            Sxc += dx * c
            Sxs += dx * s
        Sc /= n
        Ss /= n
        Scc /= n
        Sss /= n
        Scs /= n
        Sx /= n
        Sxc /= n
        Sxs /= n
        if (w == 0.) 
            m := Sx
            a := 0.
            b := 0.
        else 
            den := math.pow(Scs - Sc * Ss, 2) - (Scc - Sc * Sc) * (Sss - Ss * Ss)
            a := ((Sxs - Sx * Ss) * (Scs - Sc * Ss) - (Sxc - Sx * Sc) * (Sss - Ss * Ss)) / den
            b := ((Sxc - Sx * Sc) * (Scs - Sc * Ss) - (Sxs - Sx * Ss) * (Scc - Sc * Sc)) / den
            m := Sx - a * Sc - b * Ss
        
        for i = 0 to  npast - 1
            array.set(xm, i, array.get(xm, i) + m + a * math.cos(w * i) + b * math.sin(w * i))
            if (i <= nfut) 
                array.set(ym, nfut - i, array.get(ym, nfut - i) + m + a * math.cos(w * i) - b * math.sin(w * i))

    //+------------------------------------------------------------------+
    //| Draw lines           |
    //+------------------------------------------------------------------+
 
    for i = 0 to npast - 2 
        pvline = array.get(pvlines, i)
        colorout = i < array.size(xm) - 2 ? array.get(xm, i) > array.get(xm, i + 1) ? greencolor : redcolor : na
        line.set_xy1(pvline, bar_index - i - 1 - backbars, array.get(xm, i + 1))
        line.set_xy2(pvline, bar_index - i - backbars, array.get(xm, i))
        line.set_color(pvline, colorout)
        line.set_style(pvline, line.style_solid)
        line.set_width(pvline, plinewidth)

    array.reverse(ym)
    for i = 0 to nfut - 2 
        fvline = array.get(fvlines, i)
        colorout = i < array.size(ym) - 2 ? array.get(ym, i) > array.get(ym, i + 1) ? color.fuchsia : color.yellow : na
        line.set_xy1(fvline, bar_index + i - backbars, array.get(ym, i))
        line.set_xy2(fvline, bar_index + i + 1 - backbars, array.get(ym, i + 1))
        line.set_color(fvline, colorout)
        line.set_style(fvline, line.style_dotted)
        line.set_width(fvline, flinewidth)


forecastbars = last_bar_index - bar_index < backbars and fcolorbars

barcolor(allcolorbars ? color.gray : forecastbars ? color.gray : na)
````
