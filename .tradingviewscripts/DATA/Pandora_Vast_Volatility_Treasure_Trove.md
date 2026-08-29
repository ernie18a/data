<!-- tradingview-pine-id: PUB;152dc73c55cc41f2bd78e4eb24d0d5ed -->
<!-- tradingviewscripts-format: 1 -->
# [Pandora] Vast Volatility Treasure Trove

Source: https://www.tradingview.com/script/94GZ1QY4-Pandora-Vast-Volatility-Treasure-Trove/

## Description

INTRODUCTION:
Volatility enthusiasts, prepare for VICTORY on this day of July 4th, 2024! This is my "Vast Volatility Treasure Trove," intended mostly for educational purposes, yet these functions will also exhibit versatility when combined with other algorithms to garner statistical excellence. Once again, I am now ripping the lid off of Pandora's box... of volatility. Inside this script is a 'vast' collection of volatility estimators, reflecting the indicators name. Whether you are a seasoned trader destined to navigate financial strife or an eagerly curious learner, this script offers a comprehensive toolkit for a broad spectrum of volatility analysis. Enjoy your journey through the realm of market volatility with this code!

WHAT IS MARKET VOLATILITY?:
Market volatility refers to various fluctuations in the value of a financial market or asset over a period of time, often characterized by occasional rapid and significant deviations in price. During periods of greater market volatility, evolving conditions of prices can move rapidly in either direction, creating uncertainty for investors with results of sharp declines as well as rapid gains. However, market volatility is a typical aspect expected in financial markets that can also present opportunities for informed decision-making and potential benefits from the price flux.

SCRIPT INTENTION:
Volatility is assuredly omnipresent, waxing and waning in magnitude, and some readers have every intention of studying and/or measuring it. This script serves as an all-in-one armada of volatility estimators for TradingView members. I set out to provide a diverse set of tools to analyze and interpret market volatility, offering volatile insights, and aid with the development of robust trading indicators and strategies.

In today's fast-paced financial markets, understanding and quantifying volatility is informative for both seasoned traders and novice investors. This script is designed to empower users by equipping them with a comprehensive suite of volatility estimators. Each function within this script has been meticulously crafted to address various aspects of volatility, from traditional methods like Garman-Klass and Parkinson to more advanced techniques like Yang-Zhang and my custom experimental algorithms.

Ultimately, this script is more than just a collection of functions. It is a gateway to a deeper understanding of market volatility and a valuable resource for anyone committed to mastering the complexities of financial markets.

SCRIPT CONTENTS:
This script includes a variety of functions designed to measure and analyze market volatility. Where applicable, an input checkbox option provides an unbiased/biased estimate. Below is a brief description of each function in the original order they appear as code upon first publish:

Parkinson Volatility - Estimates volatility emphasizing the high and low range movements.
Alternate Parkinson Volatility - Simpler version of the original Parkinson Volatility that I realized.
Garman-Klass Volatility - Estimates volatility based on high, low, open, and close prices using a formula that adjusts for biases in price dynamics.
Rogers-Satchell-Yoon Volatility #1 - Estimates volatility based on logarithmic differences between high, low, open, and close values.
Rogers-Satchell-Yoon Volatility #2 - Similar estimate to Rogers-Satchell with the same result via an alternate formulation of volatility.
Yang-Zhang Volatility - An advanced volatility estimate combining both strengths of the Garman-Klass and Rogers-Satchell estimators, with weights determined by an alpha parameter.
Yang-Zhang (Modified) Volatility - My experimental modification slightly different from the Yang-Zhang formula with improved computational efficiency.

Selectable Volatility - Basic customizable volatility calculation based on the logarithmic difference between selected numerator and denominator prices (e.g., open, high, low, close).
Close-to-Close Volatility - Estimates volatility using the logarithmic difference between consecutive closing prices. Specifically applicable to data sources without open, high, and low prices.
Open-to-Close Volatility - (Overnight Volatility): Estimates volatility based on the logarithmic difference between the opening price and the last closing price emphasizing overnight gaps.

Hilo Volatility - Estimates volatility using a method similar to Parkinson's method, which considers the logarithm of the high and low prices.
Vantage Volatility - My experimental custom 'vantage' method to estimate volatility similar to Yang-Zhang, which incorporates various factors (Alpha, Beta, Gamma) to generate a weighted logarithmic calculation. This may be a volatility advantage or disadvantage, hence it's name.

Schwert Volatility - Estimates volatility based on arithmetic returns.
Historical Volatility - Estimates volatility considering logarithmic returns.
Annualized Historical Volatility - Estimates annualized volatility using logarithmic returns, adjusted for the number of trading days in a year.

If I omitted any other known varieties, detailed requests for future consideration can be made below for their inclusion into this script within future versions...

BONUS ALGORITHMS:
This script also includes several experimental and bonus functions that push the boundaries of volatility analysis as I understand it. These functions are designed to provide additional insights and also are my ideal notions for traders looking to explore other methods of volatility measurement.

VOLATILITY APPLICATIONS:
Volatility estimators serve a common role across various facets of trading and financial analysis, offering insights into market behavior. These tools are already in instrumental with enhancing risk management practices by providing a deeper understanding of market dynamics and the inherent uncertainty in asset prices. With volatility estimators, traders can effectively quantifying market risk and adjust their strategies accordingly, optimizing portfolio performance and mitigating potential losses. Additionally, volatility estimations may serve as indication for detecting overbought or oversold market conditions, offering probabilistic insights that could inform strategic decisions at turning points. This script 
distinctly offers a variety of volatility estimators to navigate intricate financial terrains with informed judgment to address challenges of strategic planning.

CODE REUSE:
You don't have to ask for my permission to use/reuse these functions in your published scripts, simply because I have better things to do than answer requests for the reuse of these functions.

Notice: Unfortunately, I will not provide any integration support into member's projects at all. I have my own projects that require way too much of my day already.

---

## Source Code

````pine
//  Use and reuse of this code is governed by the terms of the Attribution-NonCommercial-ShareAlike 4.0 International License. https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.txt
// © ImmortalFreedom

//@version=5
indicator("[Pandora] Vast Volatility Treasure Trove", 'VVTT')


var int volatilityPeriod = input.int(10, 'Volatility Period', minval=1)


// ╔═════════════════════╗
// ║  Popular Varieties  ║
// ╚═════════════════════╝
const string pop = 'POPULARS:'

parkinson(simple int    Period=10,
          simple bool Unbiased=false,
          series float    High=high,
          series float     Low=low) =>
    //≡≡≡≡≡ Parkinson Volatility ≡≡≡≡≡//
    if Period > 0
        const float  LOG16 = math.log(16.0)
        var int  period_S1 =  Period - 1
        var float uDivisor = (Period - 1) * LOG16 // unbiased
        var float bDivisor =  Period      * LOG16 //   biased
        float logRatioCalc = math.pow(math.log(High / Low), 2)
        float E=0.0, for int i=0 to period_S1
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / uDivisor)
        else
            math.sqrt(E / bDivisor)
    else
        0.0 // na

var bool  pShow  = input.bool (     true,                                      '', group=pop, inline='PV')
var color pColor = input.color(#804000, '                 Parkinson Volatility', group=pop, inline='PV')
var bool  pBias  = input.bool (    false,                             '←Unbiased', group=pop, inline='PV')
plot( not pShow ? na : parkinson( volatilityPeriod, pBias), '',    pColor, 3)


parkinson2(simple int    Period=10,
           simple bool Unbiased=false,
           series float    High=high,
           series float     Low=low) =>
    //≡≡≡≡≡ Alternate Parkinson Volatility ≡≡≡≡≡// (Simpler Calculation)
    if Period > 0
        const float LOG16R = 1.0 / math.log(16.0)
        var int  period_S1 = Period - 1
        float logRatioCalc = math.pow(math.log(High / Low), 2) * LOG16R
        float E=0.0, for int i=0 to period_S1
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  p2Show  = input.bool (     true,                                 '', group=pop, inline='P2V')
var color p2Color = input.color(#FF8000, '  Alternate Parkinson Volatility', group=pop, inline='P2V')
var bool  p2Bias  = input.bool (    false,                        '←Unbiased', group=pop, inline='P2V')
plot( not p2Show ? na : parkinson2(volatilityPeriod, p2Bias), '', p2Color)


garmanKlass( simple int    Period=10,
             simple bool Unbiased=false,
             series float    Open=open,
             series float    High=high,
             series float     Low=low,
             series float   Close=close) =>
    //≡≡≡≡≡ Garman-Klass Volatility ≡≡≡≡≡//
    if Period > 0
        const float LOG4_1 = math.log(4.0) - 1.0 // 2.0 * math.log(2.0) - 1.0
        var int  period_S1 = Period - 1
        float logRatioCalc = math.pow(math.log(High  /  Low), 2) * 0.5 -
                             math.pow(math.log(Close / Open), 2) * LOG4_1
        float E=0.0, for int i=0 to period_S1
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  gkShow  = input.bool  (     true,                                   '', group=pop, inline='GKV')
var color gkColor = input.color (#440044, '           Garman-Klass Volatility', group=pop, inline='GKV')
var bool  gkBias  = input.bool  (    false,                          '←Unbiased', group=pop, inline='GKV')
plot( not gkShow ? na : garmanKlass(volatilityPeriod, gkBias), '', gkColor, 3)


rogersSatchellYoon(simple int    Period=10,
                   simple bool Unbiased=false,
                   series float    Open=open,
                   series float    High=high,
                   series float     Low=low,
                   series float   Close=close) =>
    //≡≡≡≡≡ Rogers-Satchell-Yoon Volatility ≡≡≡≡≡//
    if Period > 0
        var int  period_S1 = Period - 1
        float logHighOpen  = math.log(High  / Open)
        float logCloseOpen = math.log(Close / Open)
        float logLowOpen   = math.log(Low   / Open)
        float logRatioCalc = logHighOpen * (logHighOpen - logCloseOpen) +
                              logLowOpen * ( logLowOpen - logCloseOpen)
        float E=0.0, for int i=0 to period_S1 
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  rsShow  = input.bool (     true,                                '', group=pop, inline='RSV')
var color rsColor = input.color(#000080, 'Rogers-Satchell-Yoon Volatility', group=pop, inline='RSV')
var bool  rsBias  = input.bool (    false,                       '←Unbiased', group=pop, inline='RSV')
plot( not rsShow ? na : rogersSatchellYoon(volatilityPeriod, rsBias), '', rsColor, 5)


rogersSatchellYoon2( simple int    Period=10,
                     simple bool Unbiased=false,
                     series float    Open=open,
                     series float    High=high,
                     series float     Low=low,
                     series float   Close=close) =>
    //≡≡≡≡≡ Rogers-Satchell-Yoon Volatility ≡≡≡≡≡//
    if Period > 0
        var int  period_S1 = Period - 1
        float logRatioCalc = math.log(High  / Close) *
                             math.log(High  /  Open) +
                             math.log(Close /   Low) *
                             math.log(Open  /   Low)
        float E=0.0, for int i=0 to period_S1 
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  rsyShow  = input.bool (     true,                                '', group=pop, inline='RSYV')
var color rsyColor = input.color(#0055FF, 'Rogers-Satchell-Yoon Volatility', group=pop, inline='RSYV')
var bool  rsyBias  = input.bool (    false,                       '←Unbiased', group=pop, inline='RSYV')
plot( not rsyShow ? na : rogersSatchellYoon2(volatilityPeriod, rsyBias), '', rsyColor)


yangZhang(simple int    Period=10,
          simple bool Unbiased=false,
          simple float   Alpha=1.34,
          series float    Open=open,
          series float    High=high,
          series float     Low=low,
          series float   Close=close) =>
    //≡≡≡≡≡ Yang-Zhang Volatility ≡≡≡≡≡//
    if Period > 1
        var int  period_S1 = Period - 1
        var float    kappa = (1.0 - Alpha) / (Alpha + (Period + 1) / (Period - 1))
        var float   lambda =  1.0 - kappa
        float logHighOpen  = math.log(High  / Open)
        float logCloseOpen = math.log(Close / Open)
        float logLowOpen   = math.log(Low   / Open)
        float logOpenPrior = math.log(Open / nz(Close[1], Close))
        float avgOpenPrior = 0.0
        float avgCloseOpen = 0.0
        for int i=0 to period_S1
            avgOpenPrior += nz(logOpenPrior[i])
            avgCloseOpen += nz(logCloseOpen[i])
        avgOpenPrior /= Period
        avgCloseOpen /= Period
        float logRatioCalc = logHighOpen * (logHighOpen - logCloseOpen) +
                             logLowOpen * ( logLowOpen - logCloseOpen)
        float volatilityON = 0.0
        float volatilityRS = 0.0
        float volatilityCO = 0.0
        for int i=0 to period_S1
            volatilityON += math.pow(nz(logOpenPrior[i]) - avgOpenPrior, 2) //     "Overnight" Volatility
            volatilityRS +=          nz(logRatioCalc[i])                    // Rogers-Satchell Volatility
            volatilityCO += math.pow(nz(logCloseOpen[i]) - avgCloseOpen, 2) //   Close-to-Open Volatility
        volatilityON /= Unbiased ? period_S1 : Period
        volatilityRS /= Unbiased ? period_S1 : Period
        volatilityCO /= Unbiased ? period_S1 : Period
        math.sqrt(volatilityON +
          kappa * volatilityCO +
         lambda * volatilityRS)
    else
        0.0 // na

var bool  yzShow  = input.bool (     true,                                    '', group=pop, inline='YZV')
var color yzColor = input.color(#FF0000, '              Yang-Zhang Volatility', group=pop, inline='YZV')
var bool  yzBias  = input.bool (     true,                           '←Unbiased', group=pop, inline='YZV')
var float yzAlpha = input.float(     1.34,         '                         α:', group=pop, inline='YZV', minval=1.0, maxval=1.5, step=0.02)
plot( not yzShow ? na : yangZhang(volatilityPeriod, yzBias, yzAlpha), '', yzColor, 3)


yangZhangMod(simple int    Period=10,
             simple bool Unbiased=false,
             simple float   Alpha=1.34,
             series float    Open=open,
             series float    High=high,
             series float     Low=low,
             series float   Close=close) =>
    //≡≡≡≡≡ Yang-Zhang (Modified) Volatility ≡≡≡≡≡// ***EXPERIMENTAL***
    if Period > 1
        var int  period_S1 = Period - 1
        var float    kappa = (1.0 - Alpha) / (Alpha + (Period + 1) / (Period - 1))
        var float   lambda =  1.0 - kappa
        float logHighOpen  = math.log(High  / Open)
        float logCloseOpen = math.log(Close / Open)
        float logLowOpen   = math.log(Low   / Open)
        float logOpenPrior = math.log(Open  / nz(Close[1], Close))
        float logRatioCalc = logHighOpen * (logHighOpen - logCloseOpen) +
                             logLowOpen * ( logLowOpen - logCloseOpen)
        float volatilityON = 0.0
        float volatilityRS = 0.0
        float volatilityCO = 0.0
        for int i=0 to period_S1
            volatilityON += math.pow(nz(logOpenPrior[i]), 2) //     "Overnight" Volatility
            volatilityRS +=          nz(logRatioCalc[i])     // Rogers-Satchell Volatility
            volatilityCO += math.pow(nz(logCloseOpen[i]), 2) //   Close-to-Open Volatility
        volatilityON /= Unbiased ? period_S1 : Period
        volatilityRS /= Unbiased ? period_S1 : Period
        volatilityCO /= Unbiased ? period_S1 : Period
        math.sqrt(volatilityON +
          kappa * volatilityCO +
         lambda * volatilityRS)
    else
        0.0 // na

var bool  yzmShow  = input.bool (     true,                                 '', group=pop, inline='YZMV')
var color yzmColor = input.color(#FFFF00, '      Yang-Zhang(Mod) Volatility', group=pop, inline='YZMV')
var bool  yzmBias  = input.bool (     true,                        '←Unbiased', group=pop, inline='YZMV')
var float yzmAlpha = input.float(     1.34,      '                         α:', group=pop, inline='YZMV', minval=1.0, maxval=1.5, step=0.02)
plot( not yzmShow ? na : yangZhangMod(volatilityPeriod, yzmBias, yzmAlpha), '', yzmColor)



// ╔══════════════════════╗
// ║  Basic Volatilities  ║
// ╚══════════════════════╝
const string base = 'BASICS:'

selectable(simple string   Numerator,
           simple string Denominator,
           simple int         Period=10,
           simple bool      Unbiased=false,
           series float         Open=open,
           series float         High=high,
           series float          Low=low,
           series float        Close=close) =>
    //≡≡≡≡≡ Selectable Volatility ≡≡≡≡≡//
    if Period > 0
        var int  period_S1 = Period - 1
        numerator = switch Numerator
            'open' => Open
            'high' => High
            'low'  => Low
            => Close
        denominator = switch Denominator
            'open'  => Open
            'high'  => High
            'low'   => Low
            'close' => Close
            => nz(Close[1], Close)
        float  squaredDiff = math.pow(math.log(numerator / denominator), 2)
        float E=0.0, for int i=0 to period_S1
            E += nz(squaredDiff[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  sShow  = input.bool  (      true,                      '', group=base, inline='SV')
var color sColor = input.color ( #AAFFAA, 'Selectable Volatility', group=base, inline='SV')
var bool  sBias  = input.bool  (     false,             '←Unbiased', group=base, inline='SV')
var string sNum  = input.string(   'close',          '        Num:', group=base, inline='SV2', options=['close','open','high','low'])
var string sDen  = input.string('close[1]',                  'Den:', group=base, inline='SV2', options=['close','open','high','low','close[1]'], tooltip='Calculation: log(Num / Den)')
plot( not sShow ? na : selectable(sNum, sDen, volatilityPeriod, sBias), '', sColor, 5)


closeToClose(simple int    Period=10,
             simple bool Unbiased=false,
             series float   Close=close) =>
    //≡≡≡≡≡ Close-to-Close Volatility ≡≡≡≡≡//
    // Applicable to non-OHLC data sources
    if Period > 0
        var int  period_S1 = Period - 1
        float logRatioCalc = math.pow(math.log(Close / nz(Close[1], Close)), 2)
        float E=0.0, for int i=0 to period_S1
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  ccShow  = input.bool (     true,                          '', group=base, inline='CCV')
var color ccColor = input.color(#FF00FF, 'Close-to-Close Volatility', group=base, inline='CCV')
var bool  ccBias  = input.bool (    false,                 '←Unbiased', group=base, inline='CCV')
plot( not ccShow ? na : closeToClose(volatilityPeriod, ccBias), '', ccColor)


ocVola(simple int    Period=10,
       simple bool Unbiased=false,
       series float    Open=open,
       series float   Close=close) =>
    //≡≡≡≡≡ Open-to-Close Volatility ≡≡≡≡≡// AKA -> Overnight Volatility
    // Overnight gaps are pronounced
    if Period > 0
        var int  period_S1 = Period - 1
        float logRatioCalc = math.pow(math.log(Open / nz(Close[1], Close)), 2)
        float E=0.0, for int i=0 to period_S1  
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)
    else
        0.0 // na

var bool  ocShow  = input.bool (    false,                            '', group=base, inline='OCV')
var color ocColor = input.color(#0055FF, '       Overnight Volatility', group=base, inline='OCV')
var bool  ocBias  = input.bool (    false,                   '←Unbiased', group=base, inline='OCV')
plot( not ocShow ? na : ocVola(volatilityPeriod, ocBias), '', ocColor, 2)



// ╔═════════════════╗
// ║  EXPERIMENTALS  ║
// ╚═════════════════╝
const string exps = 'EXPERIMENTALS:'

hilo(simple int    Period=10,
     simple bool Unbiased=true,
     series float    High=high,
     series float     Low=low) =>
    //≡≡≡≡≡ Hilo Volatility ≡≡≡≡≡// (Parkinson-like)
    if Period > 0
        var float   lambda = 4.0 / math.e
        var float exponent = 1.0 /  lambda
        var int  period_S1 =        Period - 1
        var float uDivisor = 2.0 * (Period - 1) // unbiased
        var float bDivisor = 2.0 *  Period      //   biased
        float logRatioCalc = math.pow(math.log(High / Low), lambda) // math.log(High / Low) == math.log(High) - math.log(Low)
        float E=0.0, for int i=0 to period_S1
            E += nz(logRatioCalc[i])
        if Unbiased
            math.pow(E / uDivisor, exponent)
        else
            math.pow(E / bDivisor, exponent)
    else
        0.0 // na

var bool  hlShow  = input.bool (     true,                      '', group=exps, inline='HLV')
var color hlColor = input.color(#FF00AA, '      Hilo Volatility', group=exps, inline='HLV')
var bool  hlBias  = input.bool (    false,            '← Unbiased', group=exps, inline='HLV')
plot( not hlShow ? na : hilo(volatilityPeriod, hlBias), '', hlColor)


vantage( simple int     Period=10,
         simple bool  Unbiased=true,
         simple float    Alpha=1.0,
         simple float     Beta=1.0,
         simple float    Gamma=1.0,
         simple float      Log=2.0,
         series float     Open=open,
         series float     High=high,
         series float      Low=low,
         series float    Close=close) =>
    //≡≡≡≡≡ Vantage Volatility ≡≡≡≡≡//
    if Period > 1
        var float     logX = math.log(math.e + Log)
        var int  period_S1 =         Period - 1
        var float uDivisor = logX * (Period - 1) // unbiased
        var float bDivisor = logX *  Period      //   biased
        var float     beta =  2.0 -  Alpha
        float        prior = nz(Close[1], Close)
        float logRatioCalc =  math.log(Open  / Close)     *
                              math.log(Close /  Open)     * Alpha +
                     math.pow(math.log(High  /   Low), 2) * Beta  +
                     math.pow(math.log(Open  / prior), 2) * Gamma
        float E=0.0, for int i=0 to period_S1 
            E += nz(logRatioCalc[i])
        if Unbiased
            math.sqrt(E / uDivisor)
        else
            math.sqrt(E / bDivisor)
    else
        0.0 // na

var bool  vShow  = input.bool (     true,                   '', group=exps, inline='VV')
var color vColor = input.color(#FFFFFF, 'Vantage Volatility', group=exps, inline='VV')
var bool  vBias  = input.bool (     true,          '←Unbiased', group=exps, inline='VV')
var float vLog   = input.float(      2.0,              '  ln:', group=exps, inline='VV',  minval=1.0, maxval=3.0, step=0.1)
var float vAlpha = input.float(      1.0,        '         ⍺:', group=exps, inline='VV2', minval=0.7, maxval=1.3, step=0.1)
var float vBeta  = input.float(      1.0,        '         ϐ:', group=exps, inline='VV2', minval=0.7, maxval=1.3, step=0.1)
var float vGamma = input.float(      1.0,        '         𝛾:', group=exps, inline='VV2', minval=0.7, maxval=1.3, step=0.1)
plot( not vShow ? na : vantage(volatilityPeriod, vBias, vAlpha, vBeta, vGamma, vLog), '', vColor, 2)



// ╔═══════════════╗
// ║  HISTORICALS  ║
// ╚═══════════════╝
const string hist = 'HISTORICALS:'

schwert( simple int    Period=10,
         simple bool Unbiased=false,
         series float   Close=close) =>
    //≡≡≡≡≡ Schwert Volatility ≡≡≡≡≡//
    if Period <= 1
        0.0 // na
    else
        var int period_S1 = Period - 1
        float       prior = nz(Close[1], Close)
        float arithReturn = (Close - prior) / prior
        float avg=0.0, for int i=0 to period_S1
            avg += nz(arithReturn[i])
        avg /= Period
        float E=0.0, for int i=0 to period_S1
            E += math.pow(nz(arithReturn[i]) - avg, 2)
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)

var bool  schwertShow   = input.bool (     true,                       '', group=hist, inline='SCHV')
var color schwertColor  = input.color(#555555, '    Schwert Volatility', group=hist, inline='SCHV')
var bool  schwertBias   = input.bool (     true,             '← Unbiased', group=hist, inline='SCHV')
plot( not schwertShow ? na : schwert(volatilityPeriod, schwertBias), '', schwertColor, 4)


hist(simple int    Period=10,
     simple bool Unbiased=false,
     series float   Close=close) =>
    //≡≡≡≡≡ Historical Volatility ≡≡≡≡≡//
    if Period <= 1
        0.0 // na
    else
        var int period_S1 = Period - 1
        float       prior = nz(Close[1], Close)
        float   logReturn = math.log(Close / prior)
        float avg=0.0, for int i=0 to period_S1
            avg += nz(logReturn[i])
        avg /= Period
        float E=0.0, for int i=0 to period_S1
            E += math.pow(nz(logReturn[i]) - avg, 2)
        if Unbiased
            math.sqrt(E / period_S1)
        else
            math.sqrt(E / Period)

var bool  histShow  = input.bool (     true,                        '', group=hist, inline='HV')
var color histColor = input.color(#00AAFF, '  Historical Volatility', group=hist, inline='HV')
var bool  histBias  = input.bool (     true,              '← Unbiased', group=hist, inline='HV')
plot( not histShow ? na : hist(volatilityPeriod, histBias), '', histColor)


annualHist(simple int     Period=10,
           simple bool  Unbiased=false,
           simple int DaysInYear=252,
           series float    Close=close) =>
    //≡≡≡≡≡ Annualized Historical Volatility ≡≡≡≡≡//
    if Period <= 1
        0.0 // na
    else
        var int   period_S1 = Period - 1
        var float annualize = math.sqrt(DaysInYear / Period)
        float         prior = nz(Close[1], Close)
        float     logReturn = math.log(Close / prior)
        float avg=0.0, for int i=0 to period_S1
            avg += nz(logReturn[i])
        avg /= Period
        float E=0.0, for int i=0 to period_S1
            E += math.pow(nz(logReturn[i]) - avg, 2)
        if Unbiased
            math.sqrt(E / period_S1) * annualize
        else
            math.sqrt(E / Period) * annualize

var bool  ahShow  = input.bool (    false,                      '', group=hist, inline='AHV')
var color ahColor = input.color(#00FFFF, 'Annualized Volatility', group=hist, inline='AHV')
var bool  ahBias  = input.bool (     true,            '← Unbiased', group=hist, inline='AHV')
var int   ahDays  = input.int  (      252,               '  Days:', group=hist, inline='AHV', tooltip='Daily returns in a trading year')
plot( not ahShow ? na : annualHist(volatilityPeriod, ahBias, ahDays), '', ahColor)


// ╔════════════════════════════╗
// ║  Bonus Functions (Unused)  ║
// ╚════════════════════════════╝ 
arithmeticReturn(float Close=close, float Open=open) => (Close - Open) / Open // Arithmetic Return
logReturn       (float Close=close) => math.log(Close / nz(Close[1], Close))  //        Log Return
// plot(arithmeticReturn(), '', #FF0000)
// plot(       logReturn(), '', #FFFF00)
````
