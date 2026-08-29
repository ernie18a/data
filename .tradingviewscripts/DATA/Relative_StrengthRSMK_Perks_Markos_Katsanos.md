<!-- tradingview-pine-id: PUB;f8sm8BBvNyFdDrmCkg8I6yZMytzk8tOf -->
<!-- tradingviewscripts-format: 1 -->
# Relative Strength(RSMK) + Perks - Markos Katsanos

Source: https://www.tradingview.com/script/qhNCXBmL-Relative-Strength-RSMK-Perks-Markos-Katsanos/

## Description

If you are desperately looking for a novel RSI, this isn't that. This is another lesser known novel species of indicator. Hot off the press, in multiple stunning color schemes, I present my version of "Relative Strength (RSMK)" employing PSv4.0, originally formulated by Markos Katsanos for TASC - March 2020 Traders Tips. This indicator is used to compare performance of an asset to a market index of your choosing. I included the S&P 500 index along side the Dow Jones and the NASDAQ indices selectively by an input() in "Settings". You may comparatively analyze other global market indices by adapting the code, if you are skilled enough in Pine to do so.

With this contribution to the Tradingview community, also included is MY twin algorithmic formulation of "Comparative Relative Strength" as a supplementary companion indicator. They are eerily similar, so I decided to include it. You may easily disable my algorithm within the indicator "Settings". I do hope you may find both of them useful. Configurations are displayed above in multiple scenarios that should be suitable for most traders.

As always, I have included advanced Pine programming techniques that conform to proper "Pine Etiquette". For those of you who are newcomers to Pine Script, this script may also help you understand advanced programming techniques in Pine and how they may be utilized in a most effective manner. Utilizing the "Power of Pine", I included the maximum amount of features I could surmise in an ultra small yet powerful package, being less than a 60 line implementation at initial release.

Unfortunately, there are so many Pine mastery techniques included, I don't have time to write about all of them. I will have to let you discover them for yourself, excluding the following Pine "Tricks and Tips" described next. Of notable mention with this release, I have "overwritten" the Pine built-in function ema(). You may overwrite other built-in functions too. If you weren't aware of this Pine capability, you now know! Just heed caution when doing so to ensure your replacement algorithms are 100% sound. My ema() will also accept a floating point number for the period having ultimate adjustability. Yep, you heard all of that properly. Pine is becoming more impressive than `impressive` was originally thought of...

Features List Includes:
Dark Background - Easily disabled in indicator Settings->Style for "Light" charts or with Pine commenting
AND much, much more... You have the source!

The comments section below is solely just for commenting and other remarks, ideas, compliments, etc... regarding only this indicator, not others. When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members, I may implement more ideas when they present themselves as worthy additions. As always, "Like" it if you simply just like it with a proper thumbs up, and also return to my scripts list occasionally for additional postings. Have a profitable future everyone!

---

## Source Code

````pine
//@version=4
study("Relative Strength(RSMK) + Perks - Markos Katsanos", "RMSK", false, format.price, 2)

bgcolor(color.new(#000000,15), title="Dark Background")

ema(Series, fPeriod) => // Overwrites Pine built-in ema() - Accepts a float for fPeriod
    alpha = 2.0 / (max(1.0, fPeriod) + 1.0)
    float return = na, return := alpha * Series + (1.0 - alpha) * nz(return[1], Series)
	return

rsmk(Asset, Index, iPeriod, fSmooth, iSignalPeriod) =>
    RSMK = ema(mom(log(Asset / Index), iPeriod), fSmooth) * 100.0
    signalRSMK = ema(RSMK, iSignalPeriod)
    [RSMK, signalRSMK]

mcrs(Asset, Index, iPeriod, fSmooth, iSignalPeriod) => // @midtownsk8rguy Comparative Relative Strength
    CRS = ema((-1.0 + (Asset * nz(Index[iPeriod])) / (nz(Asset[iPeriod]) * Index)), fSmooth) * 100.0
    signalCRS = ema(CRS, iSignalPeriod)
    [CRS, signalCRS]

relativeIndex = input("Manual Input",      "Comparative Market Index List", input.string , options=["Dow Jones","NASDAQ","RUSSEL 1000","RUSSEL 2000","RUSSEL 3000","Nifty","Manual Input"])
manualInput   = input(   "SPCFD:SPX",                 "      Manual Input", input.symbol ) // TRADINGVIEW MARKET INDICES LIST - https://www.tradingview.com/markets/indices/quotes-major/
source        = input(         close, "============= Source =============", input.source )
periodRSMK    = input(            90,                   " RSMK/CRS Period", input.integer,  minval=  5, step=5  )
smoothRSMK    = input(           3.0,                   " Smooth RSMK/CRS", input.float  ,  minval=1.0, step=0.5)
periodSignal  = input(            20,                     " Signal Period", input.integer,  minval= 10)
colorScheme   = input(    "Lime/Red", "========== Color Scheme ==========", input.string , options=["Lime/Red","Blue/Orange"])
showMCRS      = input(         "CRS", "Show Comparative Relative Strength", input.string , options=["Hidden","CRS","CRS + Signal"])
showCorrColor = input(         false,             "Show Correlation Color", input.bool   )
var SHOW_MCRS_SIGNAL = showMCRS=="CRS + Signal"
var SHOW_MCRS        = showMCRS=="CRS" or SHOW_MCRS_SIGNAL

//===== Comparative Index Selector
var COMPARE_TO = relativeIndex=="Dow Jones"   ? tickerid(    "DJ",   "DJI", session.regular) :
                 relativeIndex=="NASDAQ"      ? tickerid("NASDAQ",  "IXIC", session.regular) : 
                 relativeIndex=="RUSSEL 1000" ? tickerid("RUSSEL",   "RUI", session.regular) : 
                 relativeIndex=="RUSSEL 2000" ? tickerid("RUSSEL",   "RUT", session.regular) :
                 relativeIndex=="RUSSEL 3000" ? tickerid("RUSSEL",   "RUA", session.regular) :
                 relativeIndex=="Nifty"       ? tickerid(   "NSE", "NIFTY", session.regular) : manualInput
sMarketIndex = security(COMPARE_TO, timeframe.period, source)

//===== Markos Katsanos' Relative Strength (RSMK)
[RSMK, signalRSMK] = rsmk(source, sMarketIndex, periodRSMK, smoothRSMK, periodSignal)

colorRSMK = colorScheme=="Lime/Red" ?  RSMK>0.0 ? #00C000 : #C00000 :
                                       RSMK>0.0 ? #0099FF : #FF6600
colorSgnl = colorScheme=="Lime/Red" ? #FFCC00ff : #FF00C0ff
plot(      RSMK, color=colorRSMK,    transp=70, editable=false, style=plot.style_area     )
plot(      RSMK, color=colorRSMK,    transp= 0, editable=false, style=plot.style_histogram)
plot(      RSMK, color=colorRSMK,    transp= 0, editable=false, title="RSMK"  )
plot(signalRSMK, color=colorSgnl, linewidth= 2, editable=false, title="Signal")

//===== @midtownsk8rguy Comparative Relative Strength
[MCRS, signalCRS] = mcrs(source, sMarketIndex, periodRSMK, smoothRSMK, periodSignal)

colorMCRS =  MCRS>0.0 ? #00FF00ff : #FF0000ff
plot(SHOW_MCRS        ?      MCRS : na, color=colorMCRS, linewidth=2, editable=false, title="CRS")
plot(SHOW_MCRS_SIGNAL ? signalCRS : na, color=#0080FFff, linewidth=2, editable=false, title="CRS Signal")

//===== Correlation Color
correlate = correlation(source, sMarketIndex, periodRSMK)
colorCorrelate = correlate> 0.75 ? #00FF00ff :
                 correlate> 0.50 ? #00C000ff :
                 correlate> 0.25 ? #008000ff :
                 correlate> 0.0  ? #004000ff :
                 correlate>-0.25 ? #400000ff :
                 correlate>-0.50 ? #800000ff :
                 correlate>-0.75 ? #C00000ff : #FF0000ff
plot( showCorrColor ? 0.0 : na, color=colorCorrelate, style=plot.style_circles, editable=false, linewidth=2, title="CorrColor")

//===== Zero Lines
plot( showCorrColor ? na : 0.0, color=#FFFF0022, linewidth=7, title="Zero" , editable=false)
hline(                     0.0, color=showCorrColor ? color(na) : #FFFFFFff, editable=false)
````
