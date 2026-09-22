<!-- tradingview-pine-id: PUB;13c0e0983b474f48b0c281dc71073492 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Smoothed Chaikin Oscillator

Source: https://www.tradingview.com/script/jDu5RMg8/

## Description

This indicator is a smoothed version of the standard Chaikin Oscillator.

It calculates the difference between the fast and slow exponential moving averages of the Accumulation/Distribution line. An additional smoothing setting has been added to reduce noise and provide a clearer view of momentum.

When the Smoothing Length is set to 1, the indicator produces the same values as the standard Chaikin Oscillator. Increasing this value creates a smoother oscillator, but may slightly delay its response.

The area between the oscillator and the zero line is colored green when the value is positive and red when it is negative.

---

## Source Code

````pine
//@version=6
indicator(
     title="Smoothed Chaikin Oscillator",
     shorttitle="Smoothed Chaikin Osc",
     format=format.volume,
     timeframe="",
     timeframe_gaps=true
)

// Hacim kontrolü
var float cumVol = 0.0
cumVol += nz(volume)

if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

// Ayarlar
fastLength       = input.int(3, minval=1, title="Fast Length")
slowLength       = input.int(10, minval=1, title="Slow Length")
smoothLength     = input.int(1, minval=1, title="Smoothing Length")
fillTransparency = input.int(80, minval=0, maxval=100, title="Fill Transparency")

// Orijinal Chaikin Oscillator
rawOsc = ta.ema(ta.accdist, fastLength) -
         ta.ema(ta.accdist, slowLength)

// İlave yumuşatma
osc = smoothLength == 1 ? rawOsc : ta.ema(rawOsc, smoothLength)

// Renkler
oscColor = osc >= 0 ? color.green : color.red

areaColor = osc >= 0
     ? color.new(color.green, fillTransparency)
     : color.new(color.red, fillTransparency)

// Osilatör çizgisi
oscPlot = plot(
     osc,
     title="Smoothed Chaikin Oscillator",
     color=oscColor,
     linewidth=2
)

// Dolgu için görünmez sıfır grafiği
zeroPlot = plot(
     0,
     title="Zero Fill Reference",
     color=na,
     editable=false
)

// Görünen kesik sıfır çizgisi
hline(
     0,
     title="Zero",
     color=#787B86,
     linestyle=hline.style_dashed
)

// Osilatör ile sıfır seviyesi arasındaki dolgu
fill(
     oscPlot,
     zeroPlot,
     color=areaColor,
     title="Positive / Negative Area"
)
````
