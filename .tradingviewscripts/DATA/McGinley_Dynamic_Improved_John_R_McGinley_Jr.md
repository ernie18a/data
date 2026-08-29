<!-- tradingview-pine-id: PUB;PRBcBYKD4K3zpkQEov76F8SqUYwcC6Le -->
<!-- tradingviewscripts-format: 1 -->
# McGinley Dynamic (Improved) - John R. McGinley, Jr.

Source: https://www.tradingview.com/script/AKsKg1ih-McGinley-Dynamic-Improved-John-R-McGinley-Jr/

## Description

For all the McGinley enthusiasts out there, this is my improved version of the "McGinley Dynamic", originally formulated and publicized in 1990 by John R. McGinley, Jr. Prior to this release, I recently had an encounter with a member request regarding the reliability and stability of the general algorithm. Years ago, I attempted to discover the root of it's inconsistency, but success was not possible until now. Being no stranger to a good old fashioned computational crisis, I revisited it with considerable contemplation.

I discovered a lack of constraints in the formulation that either caused the algorithm to implode to near zero and zero OR it could explosively enlarge to near infinite values during unusual price action volatility conditions, occurring on different time frames. A numeric E-notation in a moving average doesn't mean a stock just shot up in excess of a few quintillion in value from just "10ish" moments ago. Anyone experienced with the usual McGinley Dynamic, has probably encountered this with dynamically dramatic surprises in their chart, destroying it's usability.

Well, I believe I have found an answer to this dilemma of 'susceptibility to miscalculation', to provide what is most likely McGinley's whole hearted intention. It required upgrading the formulation with two constraints applied to it using min/max() functions. Let me explain why below.

When using base numbers with an exponent to the power of four, some miniature numbers smaller than one can numerically collapse to near 0 values, or even 0.0 itself. A denominator of zero will always give any computational device a horribly bad day, not to mention the developer. Let this be an EASY lesson in computational division, I often entertainingly express to others. You have heard the terminology "$#|T happens!🙂" right? In the programming realm, "AnyNumber/0.0 CAN happen!🤪" too, and it happens "A LOT" unexpectedly, even when it's highly improbable. On the other hand, numbers a bit larger than 2 with the power of four can tremendously expand rapidly to the numeric limits of 64-bit processing, generating ginormous spikes on a chart.

The ephemeral presence of one OR both of those potentials now has a combined satisfactory remedy, AND you as TV members now have it, endowed with the ever evolving "Power of Pine". Oh yeah, this one plots from bar_index==0 too. It also has experimental settings tweaks to play with, that may reveal untapped potential of this formulation. This function now has gain of function capabilities, NOT to be confused with viral gain of function enhancements from reckless BSL-4 leaking laboratories that need to be eternally abolished from this planet. Although, I do have hopes this imd() function has the potential to go viral. I believe this improved function may have utility in the future by developers of the TradingView community. You have the source, and use it wisely...

I included an generic ema() plot for a basic comparison, ultimately unveiling some of this algorithm's unique characteristics differing on a variety of time frames. Also another unconstrained function is included to display some the disparities of having no limitations on a divisor in the calculation. I strongly advise against the use of umd() in any published script. There is simply just no reason to even ponder using it. I also included notes in the script to warn against this. It's funny now, but some folks don't always read/understand my advisories... You have been warned!

NOTICE: You have absolute freedom to use this source code any way you see fit within your new Pine projects, and that includes TV themselves. You don't have to ask for my permission to reuse this improved function in your published scripts, simply because I have better things to do than answer requests for the reuse of this simplistic imd() function. Sufficient accreditation regarding this script and compliance with "TV's House Rules" regarding code reuse, is as easy as copying the entire function as is. Fair enough? Good! I have a backlog of "computational crises" to contend with, including another one during the writing of this elaborate description.

When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members, I may implement more ideas when they present themselves as worthy additions. Have a profitable future everyone!

---

## Source Code

````pine
//@version=4
study("McGinley Dynamic (Improved) - John R. McGinley, Jr.", "MD(I)", true, resolution="")

imd(Series, fPeriod, fK, fExponent) => // "Improved McGinley Dynamic" Function - @midtownsk8rguy
    period = max(1.0, fPeriod)
    float return = na, priorMD = nz(return[1], Series)
    return := priorMD + (Series - priorMD) / min(period, max(1.0, fK * period * pow(Series / priorMD, fExponent)))
    return

// BEWARE: ***DO NOT USE*** BELOW FUNCTION IN ANY OTHER SCRIPT
umd(Series, fPeriod, fK, fExponent) => // Unconstrained McGinley Dynamic - Susceptible to miscalculation
    period = max(1.0, fPeriod)
    float return = na, priorMD = nz(return[1], Series)
    return := priorMD + (Series - priorMD) / (fK * period * pow(Series / priorMD, fExponent))
    return

period   = input(      14,              "   Period", input.float ,  minval=  1, step= 0.5)
source   = input(   close,     "===== Source =====", input.source)
formula  = input("Modern",            "Formulation", input.string, options=["Modern","Original","Custom k"])
kCustom  = input(     0.5,      " Custom k (tweak)", input.float ,  minval=0.3, step=0.05)
exponent = input(     4.0,      " Exponent (tweak)", input.float ,  minval=1.0, step= 0.1)
umdOnOff = input(   false, "Disable Inferior umd()", input.bool  ) 
var k = if formula=="Modern"
    0.6
else if formula=="Original"
    1.0
else
    kCustom

errataProneMD = umd(source, period, k, exponent) // Susceptible to miscalculation
plot(umdOnOff ? na : errataProneMD, "umd()", color=#990099ff, linewidth=3)

McGinleyDynamic = imd(source, period, k, exponent)
plot(McGinleyDynamic, "imd()", color=#FFFF00ff)

plot(ema(source, int(period)), "ema()") // Ordinary ema()
````
