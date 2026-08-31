<!-- tradingview-pine-id: PUB;DdlMGMZvj815bZeUYAotHozrkGMgvoN2 -->
<!-- tradingviewscripts-format: 1 -->
# (JS) Squeeze Pro Overlays

Source: https://www.tradingview.com/script/1i4BNwMU-JS-Squeeze-Pro-Overlays/

## Description

So this was something I planned on doing in the future, I knew it would take some time to put together but here it is, the Squeeze Pro 2 Overlays.

On my original Squeeze Pro, I had made several overlay indicators to go along with it, this time my goal was to combine all that stuff into a single indicator and allow the user to turn on and off the specific features they'd prefer to use. The version illustrated in the preview has everything turned on. What is "everything"? Here's the breakdown...

First of all - the color schemes in the Squeeze Pro match the color schemes in the Overlays indicator, so you can match them up (Color Scheme 3 in example). There are 6 schemes, option 1 is the original Squeeze colors.

There's also an option to make the light squeeze black, rather than white. This is for people who aren't using Dark Mode. It will flip all white to black, to make your charts better to read!

So there are 4 main overlays that can be switched on and off with this indicator, they include;

1. Early Signal Candles
2. BBMA Basis Line
3. Bollinger Bands/Keltner Channel Breaches
4. Signal Arrows

Early Signal Candles
The Early Signal Candles have two parameters, the entry smoothing period and the exit smoothing period.

There is a different type of early entry signal for each type of squeeze.

Low Squeeze generates white dots on the highs of the candles.
Mid Squeeze generates a lime green candle (or purple candle in color scheme 3).
High Squeeze generates a bigger purple circle on the high of the candle.

These three signals are made to mimic the original Early In/Out Candles from John Carter and represent the same thing (they work the same way).

As for the early exit, that would be determined by the color of the candle vs the color of the squeeze, works the same way as the original as well.

BBMA Basis Line
The BBMA (Bollinger Bands Momentum Average) was a moving average I had made to use with the squeeze on the previous version.

It is the basis line of the BB and KC used to make up the Squeeze (a 20 SMA). There are 4 different colors to it on this version.

1. Orange - This means no squeeze.
2. White/Black - Low Squeeze
3. Red - Mid Squeeze
4. Yellow - High Squeeze

You'll also notice these colors are light and dark in different spots - this is a representation of whether the Bollinger Bands are expanding or contracting. Dark means expanding, light means contracting.

Bollinger Bands/Keltner Channel Breaches
This is a pretty simple feature. If there is an ongoing squeeze, and a candle closes above or below the Bollinger Bands or Keltner Channels, a circle appears at the top or the bottom of the chart telling you which way the channel has been breached.

Signal Arrows
This is what makes up most of the overlay indicator. If you turn it on, the default is set to work just like the original. There are lots of options with this though.

First, you can turn each type of Squeeze Arrow on or off by checking/unchecking the boxes for them.

Now allow me to explain the "Signal Length", as there are several options. 
The default is "6 Dots", this generates a signal when a particular type of Squeeze reaches the 6th dot ("12 Dots" works the same way).
"End of Squeeze" generates a signal once a type of Squeeze has concluded.
"End of Early Signal" generates a signal when the early dots (or candle) finishes.
"Custom" allows you to select your own dot duration to produce a signal, you select that number in the field below.

The other portion of this is the "Signal Type", this is where you select how each signal is generated once the selected amount of time takes place. 
The default is the same as the original "+/-", this generates a signal based on whether Squeeze momentum is positive or negative.
"Rising/Falling" will only generate a signal if the Squeeze momentum maintains consistently over the last 6 bars.
"Crossed Zero" only generates a signal if the Squeeze momentum crosses above or below the zero line.
"Basis Line Momentum" is based on the BBMA. A signal is generated based on whether the current candle closes above or below the basis line.
"Divergence" only generates a signal if there is a divergence signal present at the time of the signal.
"Current Momentum" generates a signal based simply on the current direction of Squeeze momentum.
"Sum of Change" generates a signal based on the sum of the change in the Squeeze momentum being positive (long) or negative (short) over the length of time you select in the "Sum of Change Length" field.
Then "Combo" tries to take a look at everything and generates a score based on these parameters. Positive score = long, negative = short.

I hope I gave a detailed enough explanation on how everything works, let me know if you have any questions! Hope you like it!

---

## Source Code

````pine
//@version=4
study("(JS) Squeeze Pro Overlays", shorttitle="(JS)SqzPro-O", overlay=true)
//--------------------------------{ Inputs }------------------------------------
int     cs          = input(defval=2,title="Color Scheme",minval=1,maxval=6)
bool    lowsqzwht   = input(defval=true, title="Low Squeeze White")
bool    earsigc     = input(defval=true,title="Early Signal Candles")
bool    bbma        = input(defval=false,title="BBMA Basis Line")
bool    bbkcs       = input(defval=false, title="Bollinger Bands/Keltner Channel Breaches")
bool    sigarrows   = input(defval=false, title="Signal Arrows")
int     entrysmooth = input(defval=7,title="Early Entry Smoothing Period")
int     exitsmooth  = input(defval=9,title="Early Exit Smoothing Period")
bool    lowarr      = input(defval=true, title="Low Squeeze Signal")
bool    midarr      = input(defval=true, title="Mid Squeeze Signal")
bool    hgharr      = input(defval=true, title="High Squeeze Signal")
string  custsqz     = input(defval="6 Dots",title="Squeeze Signal Length",options=["End of Early Signal", "6 Dots","12 Dots","End of Squeeze","Custom"])
int     sqzsig      = input(defval=8,title="Custom Squeeze Signal Duration")
string  sigt        = input(defval="+/-",title="Signal Type",options=["Current Momentum","Sum of Change","+/-","Rising/Falling","Crossed Zero","Basis Line Momentum","Divergence","Combo"])
int     sumofc      = input(defval=20,title="Sum of Change Length")
//-------------------------{ Early Signal Candles }-----------------------------
//Squeeze Variables
float   bb          = 2.0
float   kch         = 1.0
float   kcm         = 1.5
float   kcl         = 2.0
float   sqz         = linreg(close - avg(avg(highest(high, 20), lowest(low, 20)), ema(close, 20)), 20, 0)
float   momo        = linreg((sqz-sqz[1]), exitsmooth,0)
//Basis Line
float   basis       = sma(close,20)
//Bollinger Bands
float   dev         = bb * stdev(close, 20)
float   upperbb     = basis + dev
float   lowerbb     = basis - dev
//Keltner Channels Range
float   kcrange     = sma(tr,20)
//Keltner Channels High
float   kcuph       = basis + kcrange * kch
float   kcdnh       = basis - kcrange * kch
//Keltner Channels Mid
float   kcupm       = basis + kcrange * kcm
float   kcdnm       = basis - kcrange * kcm
//Keltner Channels Low
float   kcupl       = basis + kcrange * kcl
float   kcdnl       = basis - kcrange * kcl
//Early Signal Variables
float   bkhigh      = upperbb - kcuph
float   bkmid       = upperbb - kcupm
float   bklow       = upperbb - kcupl
float   bkhema      = ema(bkhigh,entrysmooth)
float   bkmema      = ema(bkmid,entrysmooth)
float   bklema      = ema(bklow,entrysmooth)
//Early Signal Candle Colors
color   esqz        = cs == 3 ? #9c27b0 : #15ff00
color   up          = cs == 1 ? #00eeff : cs == 2 ? #00bcd4 : 
   cs == 3 ? #15ff00 : cs == 4 ? #fff59d : cs == 5 ? #2196f3 : cs == 6 ? #fff176 : na 
color   upneg       = cs == 1 ? #000eff : cs == 2 ? #0d47a1 : 
   cs == 3 ? #388e3c : cs == 4 ? #ffd600 : cs == 5 ? #0d47a1 : cs == 6 ? #ffd600 : na  
color   down        = cs == 1 ? #ff0000 : cs == 2 ? #ba68c8 : 
   cs == 3 ? #f44336 : cs == 4 ? #ffcc80 : cs == 5 ? #ef9a9a : cs == 6 ? #ef9a9a : na  
color   downpos     = cs == 1 ? #ffe500 : cs == 2 ? #9c27b0 : 
   cs == 3 ? #b71c1c : cs == 4 ? #ff9800 : cs == 5 ? #d32f2f : cs == 6 ? #d32f2f : na  
color   eeh         = #e91e63
color   eel         = lowsqzwht ? color.white : #000000
//Early Entry Candle Conditions
bool    earlyentrymid   = bkmid > bkmema and bkmid <=0
bool    earlyentryhigh  = bkhigh > bkhema and bkhigh <=0
bool    earlyentrylow   = bklow > bklema and bklow <=0
bool    endofmid        = barssince(earlyentrymid) == 1
bool    endofhigh       = barssince(earlyentryhigh) == 1
bool    endoflow        = barssince(earlyentrylow) == 1
//Early Exit Candle Conditions
bool    upcol       = sqz >= 0 and sqz > sqz[1] and (momo > 0 or (momo <= 0 and bkmid < 0))
bool    upncol      = sqz >= 0
bool    downcol     = sqz < sqz[1] and (momo < 0 or (momo >= 0 and bkmid < 0))
colors              = earlyentrymid ? esqz : upcol ? up : upncol ? upneg : downcol ? down : downpos
//Paint Bars For Early Exit
barcolor(earsigc ? colors : na)
//Early Signal Candle Plots
plot(earlyentryhigh ? high : na, title="Early Entry High", color=eeh, linewidth=5, style=plot.style_circles, transp=0)
plot(earlyentryhigh ? na : earlyentrylow ? high : na, title="Early Entry Low", color=eel, linewidth=3, style=plot.style_circles, transp=0)
//---------------------------------{ BBMA }-------------------------------------
//Each Squeeze Type
bool    lowsqz      = upperbb < kcupl and lowerbb > kcdnl
bool    midsqz      = upperbb < kcupm and lowerbb > kcdnm
bool    highsqz     = upperbb < kcuph and lowerbb > kcdnh
//Bollinger Bands Expanding
bool    expand      = (upperbb - lowerbb) > (upperbb[1] - lowerbb[1])
//Expand and Contract Colors
color   lowc        = lowsqzwht ? color.white : #000000
color   lowe        = #b2b5be
color   midc        = #ff0000
color   mide        = #891919
color   highc       = #ffe500
color   highe       = #a67b10
color   normc       = #ff6902
color   norme       = #9e3800
//Final Color Condition
bbmacolor           = highsqz and expand ? highe : highsqz ? highc : midsqz and expand ? mide : midsqz ? midc : lowsqz and expand ? lowe : lowsqz ? lowc : expand ? norme : normc
//BBMA Plot
plot(bbma ? basis : na,title="BBMA Basis Line", color=bbmacolor, linewidth=3)
//-------------------------{ BB and/or KC Breaches }----------------------------
//BB and KC Signal Formulas
bool    ksm         = close < kcdnm or close > kcupm
bool    ksh         = close < kcdnh or close > kcuph
bool    ksl         = close < kcdnl or close > kcupl
bool    bbsmh       = close < lowerbb or close > upperbb
//Individual KC Formulas
bool    kcllong     = ksl and lowsqz[1] and close > basis and (barssince(ksl)[1] > 20)
bool    kclshort    = ksl and lowsqz[1] and close < basis and (barssince(ksl)[1] > 20)
bool    kcmlong     = ksm and midsqz[1] and close > basis and (barssince(ksm)[1] > 20)
bool    kcmshort    = ksm and midsqz[1] and close < basis and (barssince(ksm)[1] > 20)
bool    kchlong     = ksh and highsqz[1] and close > basis and (barssince(ksh)[1] > 20)
bool    kchshort    = ksh and highsqz[1] and close < basis and (barssince(ksh)[1] > 20)
//Individual BB Formulas
bool    bbllong     = bbsmh and lowsqz[1] and close > basis and (barssince(bbsmh)[1] > 20)
bool    bblshort    = bbsmh and lowsqz[1] and close < basis and (barssince(bbsmh)[1] > 20)
bool    bbmlong     = bbsmh and midsqz[1] and close > basis and (barssince(bbsmh)[1] > 20)
bool    bbmshort    = bbsmh and midsqz[1] and close < basis and (barssince(bbsmh)[1] > 20)
bool    bbhlong     = bbsmh and highsqz[1] and close > basis and (barssince(bbsmh)[1] > 20)
bool    bbhshort    = bbsmh and highsqz[1] and close < basis and (barssince(bbsmh)[1] > 20)
//KC and BB Plot Formulas
bool    bbplotl     = bbkcs ? (bbhlong ? bbhlong : bbmlong ? bbmlong : bbllong) : na
bool    bbplots     = bbkcs ? (bbhshort ? bbhshort : bbmshort ? bbmshort : bblshort) : na
bool    kcplotl     = bbkcs ? (bbplotl ? na : kchlong ? kchlong : kcmlong ? kcmlong : kcllong) : na
bool    kcplots     = bbkcs ? (bbplots ? na : kchshort ? kchshort : kcmshort ? kcmshort : kclshort) : na
color   kcbbcol     = lowsqzwht ? color.white : #000000 
//KC and BB Plots
plotshape(bbplotl, color=kcbbcol, style=shape.circle, location=location.bottom, size=size.tiny, title="BB Breach Long", text="BB↑")
plotshape(bbplots, color=kcbbcol, style=shape.circle, location=location.top, size=size.tiny, title="BB Breach Short", text="BB↓")
plotshape(kcplotl, color=kcbbcol, style=shape.circle, location=location.bottom, size=size.tiny, title="KC Breach Long", text="KC↑")
plotshape(kcplots, color=kcbbcol, style=shape.circle, location=location.top, size=size.tiny, title="KC Breach Short", text="KC↓")
//----------------------------{ Signal Arrows }---------------------------------
//Signal Types
bool  cmom          = sigt == "Current Momentum"
bool  soc           = sigt == "Sum of Change"
bool  momom         = sigt == "+/-"
bool  rf            = sigt == "Rising/Falling"
bool  czero         = sigt == "Crossed Zero"
bool  blma          = sigt == "Basis Line Momentum"
bool  diverg        = sigt == "Divergence"
bool  combo         = sigt == "Combo"
//Signal Durations
bool  sigeoe        = custsqz == "End of Early Signal"
bool  sigreg        = custsqz == "6 Dots"
bool  sigpro        = custsqz == "12 Dots"
bool  sigeos        = custsqz == "End of Squeeze"
bool  sigcus        = custsqz == "Custom"
//Sum of Change
float   change     = sum((sqz-sqz[1]),sumofc)
bool    changel    = change > 0
bool    changes    = change < 0
//Basis Line Filter
bool    bbmal       = close >= basis
bool    bbmas       = close < basis
//Basic Signal Conditions
bool    sc1         = sqz > 0
bool    sc2         = sqz < 0
//Rising/Falling Conditions
bool    sqzlongreg  = sqz > sqz[1] and sqz[1] > sqz[2] and sqz[2] > sqz[3] and sqz[3] > sqz[4] and sqz[4] > sqz[5] and sqz[5] > sqz[6]
bool    sqzshortreg = sqz < sqz[1] and sqz[1] < sqz[2] and sqz[2] < sqz[3] and sqz[3] < sqz[4] and sqz[4] < sqz[5] and sqz[5] < sqz[6]
//Zero Line Conditions
bool    sqzzerolong = sqz > 0 and sqz[6] < 0
bool    sqzzeroshort= sqz < 0 and sqz[6] > 0
//Divergence Formula
ftf(_src)=>_src[4] < _src[2] and _src[3] < _src[2] and _src[2] > _src[1] and _src[2] > _src[0]
fbf(_src)=>_src[4] > _src[2] and _src[3] > _src[2] and _src[2] < _src[1] and _src[2] < _src[0]
ffract(_src)=>ftf(_src) ? 1 : fbf(_src) ? -1 : 0
//Divergence Variables
float   fractaltop = ffract(sqz) > 0 ? sqz[2] : na
float   fractalbot = ffract(sqz) < 0 ? sqz[2] : na
float   high_prev  = valuewhen(fractaltop, sqz[2], 1) 
float   high_price = valuewhen(fractaltop, high[2], 1)
float   low_prev   = valuewhen(fractalbot, sqz[2], 1) 
float   low_price  = valuewhen(fractalbot, low[2], 1)
bool    regbeardiv = fractaltop and high[2] > high_price and sqz[2] < high_prev
bool    regbulldiv = fractalbot and low[2] < low_price and sqz[2] > low_prev
//Current Momentum
bool    cmolong         = sqz > sqz[1]
bool    cmoshort        = sqz <= sqz[1]
//False Signals
bool    lsf             = lowsqz == false
bool    msf             = midsqz == false
bool    hsf             = highsqz == false
//End of Early Signal
bool    eoel            = sigeoe ? endoflow : na
bool    eoem            = sigeoe ? endofmid : na
bool    eoeh            = sigeoe ? endofhigh : na
//Dot Count Regular
bool    ll6             = sigreg ? lowsqz and (barssince(lsf) == 6) : na
bool    ml6             = sigreg ? midsqz and (barssince(msf) == 6) : na
bool    hl6             = sigreg ? highsqz and (barssince(hsf) == 6) : na
//Dot Count Prolonged
bool    ll12            = sigpro ? lowsqz and (barssince(lsf) == 12) : na
bool    ml12            = sigpro ? midsqz and (barssince(msf) == 12) : na
bool    hl12            = sigpro ? highsqz and (barssince(hsf) == 12) : na
//End Of Squeeze
bool    eol             = sigeos ? lsf and (barssince(lowsqz) == 1) : na
bool    eom             = sigeos ? msf and (barssince(midsqz) == 1) : na
bool    eoh             = sigeos ? hsf and (barssince(highsqz) == 1) : na
//Custom Squeeze
bool    custl           = sigcus ? lowsqz and (barssince(lsf) == sqzsig) : na
bool    custm           = sigcus ? midsqz and (barssince(msf) == sqzsig) : na
bool    custh           = sigcus ? highsqz and (barssince(hsf) == sqzsig) : na
//Dot Count Signals
bool    squeezesignall  = eoel or ll6 or ll12 or eol or custl
bool    squeezesignalm  = eoem or ml6 or ml12 or eom or custm
bool    squeezesignalh  = eoeh or hl6 or hl12 or eoh or custh
//Sum of Change Formulas
bool    llchg           = squeezesignall and changel
bool    lschg           = squeezesignall and changes
bool    mlchg           = squeezesignalm and changel
bool    mschg           = squeezesignalm and changes
bool    hlchg           = squeezesignalh and changel
bool    hschg           = squeezesignalh and changes
//Basic Signal Formulas
bool    llbsc           = squeezesignall and sc1
bool    lsbsc           = squeezesignall and sc2
bool    mlbsc           = squeezesignalm and sc1
bool    msbsc           = squeezesignalm and sc2
bool    hlbsc           = squeezesignalh and sc1
bool    hsbsc           = squeezesignalh and sc2
//Rising/Falling Signal Formulas
bool    llrf            = squeezesignall and sqzlongreg
bool    lsrf            = squeezesignall and sqzshortreg
bool    mlrf            = squeezesignalm and sqzlongreg
bool    msrf            = squeezesignalm and sqzshortreg
bool    hlrf            = squeezesignalh and sqzlongreg
bool    hsrf            = squeezesignalh and sqzshortreg
//Zero Line Signal Formulas
bool    llz             = squeezesignall and sqzzerolong
bool    lsz             = squeezesignall and sqzzeroshort
bool    mlz             = squeezesignalm and sqzzerolong
bool    msz             = squeezesignalm and sqzzeroshort
bool    hlz             = squeezesignalh and sqzzerolong
bool    hsz             = squeezesignalh and sqzzeroshort
//Basis Line Signal Formulas
bool    llbl            = squeezesignall and bbmal
bool    lsbl            = squeezesignall and bbmas
bool    mlbl            = squeezesignalm and bbmal
bool    msbl            = squeezesignalm and bbmas
bool    hlbl            = squeezesignalh and bbmal
bool    hsbl            = squeezesignalh and bbmas
//Divergence Signal Formulas
bool    lldv            = squeezesignall and regbulldiv
bool    lsdv            = squeezesignall and regbeardiv
bool    mldv            = squeezesignalm and regbulldiv
bool    msdv            = squeezesignalm and regbeardiv
bool    hldv            = squeezesignalh and regbulldiv
bool    hsdv            = squeezesignalh and regbeardiv
//Current Momentum Signal Formulas
bool    llcm            = squeezesignall and cmolong
bool    lscm            = squeezesignall and cmoshort
bool    mlcm            = squeezesignalm and cmolong
bool    mscm            = squeezesignalm and cmoshort
bool    hlcm            = squeezesignalh and cmolong
bool    hscm            = squeezesignalh and cmoshort
//Combo Scoring
int     basicscore      = sc1 ? 6 : -6
int     rfscore         = sqzlongreg ? 3 : sqzshortreg ? -3 : 0
int     zlscore         = sqzzerolong ? 4 : sqzzeroshort ? -4 : 0
int     bbmascore       = bbmal ? 3 : bbmas ? -3 : 0
int     divscore        = regbulldiv ? 3 : regbeardiv ? -3 : 0
int     sumscore        = changel ? 4 : -4
int     currentmo       = cmolong ? 3 : -3
int     comboscore      = basicscore + rfscore + zlscore + bbmascore + divscore + sumscore + currentmo
bool    longcombo       = comboscore > 0
bool    shortcombo      = comboscore < 0
//Combo Signal Formulas
bool    llcombo         = squeezesignall and longcombo
bool    lscombo         = squeezesignall and shortcombo
bool    mlcombo         = squeezesignalm and longcombo
bool    mscombo         = squeezesignalm and shortcombo
bool    hlcombo         = squeezesignalh and longcombo
bool    hscombo         = squeezesignalh and shortcombo
//Final Signals
bool    longlow         = (soc and llchg) or (momom and llbsc) or (rf and llrf) or (czero and llz) or (blma and llbl) or (diverg and lldv) or (llcm and cmom) or (combo and llcombo)
bool    shortlow        = (soc and lschg) or (momom and lsbsc) or (rf and lsrf) or (czero and lsz) or (blma and lsbl) or (diverg and lsdv) or (lscm and cmom) or (combo and lscombo)
bool    longmid         = (soc and mlchg) or (momom and mlbsc) or (rf and mlrf) or (czero and mlz) or (blma and mlbl) or (diverg and mldv) or (mlcm and cmom) or (combo and mlcombo)
bool    shortmid        = (soc and mschg) or (momom and msbsc) or (rf and msrf) or (czero and msz) or (blma and msbl) or (diverg and msdv) or (mscm and cmom) or (combo and mscombo)
bool    longhigh        = (soc and hlchg) or (momom and hlbsc) or (rf and hlrf) or (czero and hlz) or (blma and hlbl) or (diverg and hldv) or (hlcm and cmom) or (combo and hlcombo)
bool    shorthigh       = (soc and hschg) or (momom and hsbsc) or (rf and hsrf) or (czero and hsz) or (blma and hsbl) or (diverg and hsdv) or (hscm and cmom) or (combo and hscombo)
//Final Plots
plotshape(sigarrows ? (lowarr ? (longhigh ? na : longmid ? na : longlow ? longlow : na) :na ) : na, color=kcbbcol, style=shape.triangleup, location=location.belowbar, size=size.small, title="Low Squeeze Signal - Long")
plotshape(sigarrows ? (lowarr ? (shorthigh ? na : shortmid ? na : shortlow ? shortlow : na) : na) : na, color=kcbbcol, style=shape.triangledown, location=location.abovebar, size=size.small, title="Low Squeeze Signal - Short")
plotshape(sigarrows ? (midarr ? (longhigh ? na : longmid ? longmid : na) : na) : na, color=#ff0000, style=shape.triangleup, location=location.belowbar, size=size.small, title="Mid Squeeze Signal - Long")
plotshape(sigarrows ? (midarr ? (shorthigh ? na : shortmid ? shortmid : na) : na) : na, color=#ff0000, style=shape.triangledown, location=location.abovebar, size=size.small, title="Mid Squeeze Signal - Short")
plotshape(sigarrows ? (hgharr ? (longhigh ? longhigh : na) : na) : na, color=#ffe500, style=shape.triangleup, location=location.belowbar, size=size.small, title="High Squeeze Signal - Long")
plotshape(sigarrows ? (hgharr ? (shorthigh ? shorthigh : na) : na) : na, color=#ffe500, style=shape.triangledown, location=location.abovebar, size=size.small, title="High Squeeze Signal - Short")
````
