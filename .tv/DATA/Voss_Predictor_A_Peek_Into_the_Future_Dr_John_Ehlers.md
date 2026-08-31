<!-- tradingview-pine-id: PUB;Mtdo06erQMaQfKQ0TPAau4dTyxAli38m -->
<!-- tradingviewscripts-format: 1 -->
# Voss Predictor (A Peek Into the Future) - Dr. John Ehlers

Source: https://www.tradingview.com/script/ekkb1vlg-Voss-Predictor-A-Peek-Into-the-Future-Dr-John-Ehlers/

## Description

I have been sitting on this for over a year, but I now present this "Voss Predictive Filter" multicator employing PSv4.0 upon initial release, originally formulated by the great and empowering Dr. John Ehlers for TASC - August 2019 Traders Tips. This is a slightly modified version of the original indicator John Ehlers designed. My improved implementation is an all-in-one combination of three indicators, consisting of Ehlers' 2-pole bandpass filter, fed into the Voss predictor, and my Correlation Color. I also purposefully attempted to make this indicator work on both "Light" and "Dark" charts equally well.

You can search for this indicator's white paper, entitled "A PEEK INTO THE FUTURE By John Ehlers", on his site in the educational reference section. It's VERY important that you fully grasp how this indicator works and when it doesn't during trending price movements. According to "TV House Rules", I can't link directly to his white paper on his web site. Technically he's a vendor, even though it has been divulged to me, that he is intending to retire after his last and final wØℾk$#Øp, where he is publicly disseminating the bulk of his unpublished proprietary code that drives his other website VERY SOON.

I love John Ehlers in a respectfully appreciative manner and he is my hero in life! I simply don't revel about pretended celebrities and supposed rock stars. I will never be able to adequately explain to you how much he has influenced me AND this website as it currently exists AND what is in store for the future of the ever evolving "Power of Pine". His inspiring legacy of code poetry shall forever be immortally enshrined here on TV and influence it.

Back to the topic of interest, this script originating from John Ehlers' mind... This indicator helps to anticipate cyclic turning points via negative group delay. It is NOT a predictive crystal ball. Do not become cluelessly disillusioned by it's title. I need to explain.

For example, this indicator could not have anticipated that the bold faced lie of "15 Days to Slow the Spread" of the CHImeravirus "plandemic" in the USA, would turn into our factual reality of multi state mandated orders demanding months of unconstitutional prison cell styled lockdowns with closures and the absurd criminalization of not wearing a mouth mask made from underwear while not being evidently ill, additionally combined with 24/7 black magick mass hypnosis spoon feeding non-scientific fear based psychological propaganda from the world's "finest" epidemiological data analysts and misleaders, eventually decimating the world's markets into zombie economies with abhorrent results of long term massive unemployment and financial hardship on a chart scale never before witnessed. Yep, it's NOT capable of predetermining any of that. I just wanted to make that very clear by example in a metaphorical manner many people can relate to concerning Voss' ability to anticipate.

The indicator consists of a bandpass filter coupled to the Voss predictor. Also, one thing about the Voss predictor, it can catch minute turning points or even false ones as explained in the white paper. So... I included my Correlation Color as a fitting companion to aid you in filtering out false signals during trending price movements. The Voss Predictive Filter should never be used alone, be forewarned!

Features List Includes:
Dark Background - Easily disabled in indicator Settings->Style for "Light" charts or with Pine commenting
AND a few more... Why list them, when you have the source code to explore!

When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members , I may implement more ideas when they present themselves as worthy additions. Have a profitable future everyone!

---

## Source Code

````pine
//@version=4
study("Voss Predictor (A Peek Into the Future) - Dr. John Ehlers", "VPF", false, format.price, 3)

bgcolor(color.new(#000000,20), title="Dark Background")
var color_none = color(na)

whiten(Series) =>
    0.5 * (Series - nz(Series[2], nz(Series[1], Series)))

bpf(Series, Period, Bandwidth) => // Ehler's BandPass Filter
    var PIx2  = 4.0 * asin(1.0) // 6.28318530718 Constant
    var alpha = PIx2 / Period
    var gamma = cos(alpha * Bandwidth)
    var delta = 1.0 / gamma - sqrt(1.0 / pow(gamma, 2.0) - 1.0)
    float bandPass = na,  bandPass := (1.0 - delta) * whiten(  Series   ) +
                         cos(alpha) * (1.0 + delta) *     nz(bandPass[1]) -
                                             delta  *     nz(bandPass[2])
    bandPass

vpf(Series, BarsOfPrediction) => // Ehler's Voss Predictive Filter
    var order  = 3.0 * min(3.0, BarsOfPrediction)
    float voss = na
    E = 0.0, for i=0 to int(order-1)
    	E := nz(voss[order - i]) * (  1 + i    ) / order  + E
    voss  :=                 0.5 * (3.0 + order) * Series - E
    voss

source         = input(         close,                             "Source", input.source )
showAreaBP     = input(          true,              "Display Bandpass Area", input.bool   )
periodBandpass = input(            20,                    "Bandpass Period", input.integer,  minval=   2)
bandWidth      = input(          0.25,                        "  Bandwidth", input.float  ,  minval=0.05, maxval=1.0, step=0.05)
barsPrediction = input(           3.0,                 "Bars of Prediction", input.float  ,  minval=0.5 , maxval=3.0, step=0.5 )
showCorrColor  = input(          true, "===== Show Correlation Color =====", input.bool   )
syncCorrPeriod = input("Synchronized",               " Correlation Control", input.string , options=["Independent", "Synchronized"])
periodCorr     = input(            40,                " Correlation Period", input.integer,  minval=2)
var periodCorrelation = syncCorrPeriod=="Synchronized" ? periodBandpass : periodCorr

BPF = bpf(  source, periodBandpass, bandWidth)
VPF = vpf(     BPF, barsPrediction)

colorFill =  BPF>0.0 and VPF>BPF ? #00FF00 :
             BPF<0.0 and VPF<BPF ? #FF0000 : color_none
plot(showAreaBP ? BPF : na, "Area", color=#AAFFFF80, style=plot.style_area)
plotVPF = plot(   VPF,       "VPF", color= VPF>0.0 ? #00FF00 : #FF0000)
plotBPF = plot(   BPF,       "BPF", color=#EEEEEEff, linewidth= 2)
fill(plotBPF, plotVPF,   colorFill, 75, "", editable=false)

//===== Correlation Color
correlate = correlation(source, bar_index, periodCorrelation)
colorCorrelate = correlate> 0.75 ? #00FF00ff :
                 correlate> 0.50 ? #00C000ff :
                 correlate> 0.25 ? #008000ff :
                 correlate> 0.0  ? #004000ff :
                 correlate>-0.25 ? #400000ff :
                 correlate>-0.50 ? #800000ff :
                 correlate>-0.75 ? #C00000ff : #FF0000ff
plot( showCorrColor ? 0.0 : na, color=colorCorrelate, style=plot.style_circles, editable=false, linewidth=3, title="CorrColor")

//===== Zero Lines
plot( showCorrColor ? na : 0.0, color=#FFFF0022, linewidth=7, title="Zero"  , editable=false)
hline(                     0.0, color=showCorrColor ? color_none : #CCCCCCff, editable=false)
````
