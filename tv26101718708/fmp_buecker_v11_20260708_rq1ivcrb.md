# FMP Buecker V11 2026.07.08

- url: https://www.tradingview.com/script/rq1ivcrb/
- type: indicator
- pine_id: PUB;b7872c151dfd4da5bf5ce65e5a14846c
- version: 1.0

## Description

Below is a professional English user manual suitable for publication on TradingView or as a PDF/manual.

FMP Buecker V11 – User Guide

Version: 11 (2026-07-08)
Author: Martin Bücker

Introduction

FMP Buecker V11 is a momentum oscillator designed to identify the earliest possible changes in market momentum.

Unlike conventional oscillators that rely solely on crossing the zero line, the FMP uses dynamic color changes to detect transitions between strengthening and weakening bullish or bearish momentum.

Its primary purpose is to identify:

Beginning of bullish momentum
Beginning of bearish momentum
Pullbacks inside an existing trend
Strong trend phases
Early reversals

The indicator is especially suitable for intraday trading, scalping and swing trading.

Oscillator Types

The indicator offers four different oscillators.

1. Fisher Transform

Transforms price into an approximately Gaussian distribution.

Advantages:

Fast reaction
Excellent reversal detection
Very sensitive

Recommended for:

Scalping
Short-term trading
Crypto
Futures
2. Inverse Fisher RSI

Applies an Inverse Fisher Transform to the RSI.

Advantages:

Smooth signals
Reduced noise
Excellent trend confirmation

Recommended for:

Trend trading
Swing trading
3. Inverse Fisher Stochastic

Applies an Inverse Fisher Transform to the Stochastic Oscillator.

Advantages:

Detects overbought/oversold reversals
Very responsive

Recommended for:

Reversal trading
Fast markets
4. Inverse Fisher CCI

Uses the Commodity Channel Index with an Inverse Fisher Transform.

Advantages:

Excellent for identifying strong trends
Filters small fluctuations

Recommended for:

Trending markets
Commodity trading
Input Parameters
Source

Selects the input price.

Usually:

Close
Sampling Period

Determines the calculation length.

Typical values:

8–10 → very fast
13 → default
20–30 → smoother

Lower values increase sensitivity.

Higher values reduce noise.

Smooth Oscillator

Applies an additional EMA smoothing.

Benefits:

Less noise
Cleaner trends
Slightly more lag
Smoothing Period

Determines the EMA smoothing length.

Typical values:

2
3
5
Alpha

Only used for the Inverse Fisher oscillators.

Higher values:

More sensitive
Faster

Lower values:

Smoother
Less reactive
Threshold Types

The indicator supports two threshold modes.

Auto

Automatically calculates adaptive thresholds based on historical oscillator behavior.

Advantages:

No optimization required
Automatically adapts to market volatility

Recommended for most users.

Custom

Allows manual threshold selection.

Use this if you want fixed signal levels.

Example:

High Threshold = 0.50

Low Threshold = -0.50

Threshold Compression

Optional feature.

Compression reduces extreme oscillator values while preserving the overall trend.

Benefits:

Better readability
Less exaggerated peaks
Cleaner visualization
Compression Intensity

0%

No compression.

100%

Maximum compression.

Typical values:

70–90%.

Oscillator Fill

Adds a semi-transparent fill between the oscillator and the zero line.

This improves visual trend recognition.

Can be disabled if preferred.

Color Logic

The oscillator changes color according to market conditions.

White

White indicates bullish momentum.

It appears when:

Bullish momentum is increasing
A bullish trend is forming
A bearish pullback is ending
Red

Red indicates bearish momentum.

It appears when:

Bearish momentum is increasing
A bearish trend is forming
A bullish pullback is ending
Understanding the Signals

The indicator does not generate signals by crossing the zero line.

Instead, every color change generates a signal.

This allows much earlier detection of momentum changes.

LONG Signal

Generated when the oscillator changes from:

Red → White

This indicates increasing bullish momentum.

SHORT Signal

Generated when the oscillator changes from:

White → Red

This indicates increasing bearish momentum.

Threshold Signals

The indicator distinguishes between two different signal qualities.

LONG Above Threshold

The color changes to white while the oscillator is already above the bullish threshold.

This represents:

Strong bullish momentum
High-quality trend continuation
Strong confirmation

These are generally the strongest long signals.

LONG Below Threshold

The oscillator turns white before reaching the bullish threshold.

This represents:

Early reversal
Trend beginning
More aggressive entry

Higher potential reward, but lower confirmation.

SHORT Below Threshold

The oscillator turns red while already below the bearish threshold.

Represents:

Strong bearish momentum
Confirmed downtrend
High-confidence short setup
SHORT Above Threshold

The oscillator turns red before reaching the bearish threshold.

Represents:

Early bearish reversal
Beginning of downward momentum

Higher risk but earlier entry.

Alerts

The indicator provides six independent TradingView alerts.

LONG

Triggered whenever the oscillator changes to white.

SHORT

Triggered whenever the oscillator changes to red.

LONG Above Threshold

Only triggers when bullish momentum begins above the upper threshold.

LONG Below Threshold

Only triggers below the threshold.

SHORT Below Threshold

Only triggers below the lower threshold.

SHORT Above Threshold

Only triggers above the lower threshold.

Typical Trading Interpretation

A common interpretation is:

White after red → potential long opportunity.
Red after white → potential short opportunity.
Signals occurring beyond the adaptive thresholds indicate stronger momentum and often provide higher-confidence entries.
Signals occurring before the thresholds may identify reversals earlier but generally require additional confirmation from price action, trend filters, or volume.
Recommended Markets

The indicator works particularly well on:

Cryptocurrency
Futures
Forex
Stocks
Indices

Recommended timeframes:

1 Minute
3 Minutes
5 Minutes
15 Minutes
1 Hour
Best Practice

For optimal results, combine the FMP Buecker V11 with complementary tools such as:

Trend filters (e.g., EMA 200 or Supertrend)
Volume analysis
Market structure (higher highs/lower lows)
Support and resistance levels

Using the FMP as part of a broader trading plan can help filter lower-quality signals and improve decision-making.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Martin Bücker

//@version=6
indicator(title="FMP Buecker V11 2026.07.08", shorttitle="FMP Buecker V11 2026.07.08")

//---------------------------------------------------------------------
// Functions
//---------------------------------------------------------------------

fish(x, t) =>
    highval = ta.highest(x, t)
    lowval  = ta.lowest(x, t)
    var float val1 = 0.0
    val1 := 0.66 * ((x - lowval) / math.max(highval - lowval, 0.001) - 0.5) + 0.67*nz(val1[1], 0)
    val2 = val1 > 0.99 ? 0.999 : val1 < -0.99 ? -0.999 : val1
    var float fish = 0.0
    fish := 0.5 * math.log((1 + val2) / math.max(1 - val2, 0.001)) + 0.5*nz(fish[1], 0)
    fish

ifishrsi(x, t, a)=>
    rsiv  = a*(ta.rsi(x, t) - 50)
    wmarv = ta.wma(rsiv, t)
    (math.exp(2*wmarv) - 1)/(math.exp(2*wmarv) + 1)

ifishstoch(x, t, a)=>
    stochv = a*(ta.stoch(x, high, low, t) - 50)
    wmasv  = ta.wma(stochv, t)
    (math.exp(2*wmasv) - 1)/(math.exp(2*wmasv) + 1)

ifishcci(x, t, a)=>
    cciv  = a*(ta.cci(x, t))
    wmacv = ta.wma(cciv, t)
    (math.exp(2*wmacv) - 1)/(math.exp(2*wmacv) + 1)

EMA(x, t)=>
    var float EMA = na
    EMA := na(EMA[1]) ? x : (x - nz(EMA[1]))*(2/(t + 1)) + nz(EMA[1])
    EMA

cmean(x)=>
    var float xsum = 0.0
    xsum += x
    var float tsum = 0.0
    tsum += 1
    xsum/tsum

comp(x, k_type, h_knee, l_knee, intensity)=>
    hk = k_type=="Auto" ? cmean(math.abs(x)) : h_knee
    lk = k_type=="Auto" ? -cmean(math.abs(x)) : l_knee
    comp_val = x > hk ? x - intensity*(x - hk)/100 : x < lk ? x + intensity*(lk - x)/100 : x
    comp_val

//---------------------------------------------------------------------
// Inputs
//---------------------------------------------------------------------

src = input.source(close, "Source")
per = input.int(13, "Sampling Period", minval=1)

smooth = input.bool(false, "Smooth Oscillator")
smper  = input.int(1, "Smoothing Period", minval=1)

otype = input.string("Fisher Transform", "Oscillator Type",
     options=["Fisher Transform", "Inverse Fisher RSI", "Inverse Fisher Stochastic", "Inverse Fisher CCI"])

alpha = input.float(0.1, "Alpha", minval=0)

th_type   = input.string("Auto", "Threshold Type", options=["Auto", "Custom"])
custom_ht = input.float(0.0, "Custom High Threshold")
custom_lt = input.float(0.0, "Custom Low Threshold")

use_comp       = input.bool(false, "Compress Around Thresholds")
comp_intensity = input.int(90, "Compression Intensity (%)", minval=0, maxval=100)

// Oscillator Fill
showFill = input.bool(true, "Oscillator Fill")

//---------------------------------------------------------------------
// Core
//---------------------------------------------------------------------

fisher  = nz(fish(src, per), 0)
ifrsi   = nz(ifishrsi(src, per, alpha), 0)
ifstoch = nz(ifishstoch(src, per, alpha), 0)
ifcci   = nz(ifishcci(src, per, alpha), 0)

osc1 = otype=="Fisher Transform" ? fisher :
       otype=="Inverse Fisher RSI" ? ifrsi :
       otype=="Inverse Fisher Stochastic" ? ifstoch : ifcci

osc2 = EMA(osc1, smooth ? smper : 1)
osc  = use_comp ? comp(osc2, th_type, custom_ht, custom_lt, comp_intensity) : osc2

tdist = cmean(math.abs(osc2))
hth   = th_type=="Auto" ? tdist : custom_ht
lth   = th_type=="Auto" ? -tdist : custom_lt

// Signals
bullpower    = (osc > 0) and (osc >= osc[1]) and (osc >= hth)
bullforming  = (osc > 0) and (osc > osc[1]) and (osc < hth)
bullpullback = (osc > 0) and (osc < osc[1])
bearpower    = (osc < 0) and (osc <= osc[1]) and (osc <= lth)
bearforming  = (osc < 0) and (osc < osc[1]) and (osc > lth)
bearpullback = (osc < 0) and (osc > osc[1])

// Farben
basiscolor = osc > 0 ? #4CAF50 : osc < 0 ? #C2185B : #E0E0E0

osccolor = bullforming  ? #FFFFFF :
           bullpower    ? #FFFFFF :
           bullpullback ? #FF5252 :
           bearforming  ? #FF5252 :
           bearpower    ? #FF5252 :
           bearpullback ? #FFFFFF :
                          #FFFFFF

//---------------------------------------------------------------------
//---------------------------------------------------------------------
// ✅ Farbwechsel exakt messen
//---------------------------------------------------------------------

colorChange = osccolor != osccolor[1]

// Bisherige Signale
longSignal  = colorChange and osccolor == #FFFFFF
shortSignal = colorChange and osccolor == #FF5252

// Neue Signale innerhalb der Power-Zonen
longAboveThreshold  = colorChange and osccolor == #FFFFFF and osc >= hth
shortBelowThreshold = colorChange and osccolor == #FF5252 and osc <= lth

// Neue Signale außerhalb der Power-Zonen
longBelowThreshold  = colorChange and osccolor == #FFFFFF and osc < hth
shortAboveThreshold = colorChange and osccolor == #FF5252 and osc > lth

// Alerts
alertcondition(longSignal,          title="LONG",                   message="LONG")
alertcondition(shortSignal,         title="SHORT",                  message="SHORT")

alertcondition(longAboveThreshold,  title="LONG Above Threshold",   message="LONG Above Threshold")
alertcondition(shortBelowThreshold, title="SHORT Below Threshold",  message="SHORT Below Threshold")

alertcondition(longBelowThreshold,  title="LONG Below Threshold",   message="LONG Below Threshold")
alertcondition(shortAboveThreshold, title="SHORT Above Threshold",  message="SHORT Above Threshold")

//---------------------------------------------------------------------
// Outputs
//---------------------------------------------------------------------

hbandplot = plot(hth, color=#E0E0E0, linewidth=1)
basisplot = plot(0,   color=basiscolor, linewidth=2)
lbandplot = plot(lth, color=#FF0050, linewidth=1)

oscplot = plot(osc, color=osccolor, linewidth=2)

fill(oscplot, basisplot, color=showFill ? color.new(osccolor, 70) : na)
````
