# [GYTS-CE] Kinetic Trend Envelope (adaptive trailing stop)

- url: https://www.tradingview.com/script/CsKTbPBI-GYTS-CE-Kinetic-Trend-Envelope-adaptive-trailing-stop/
- type: indicator
- pine_id: PUB;673305b9f10d4c9dbbbe1d2e8198520c
- version: 2.0

## Description

[b]Kinetic Trend Envelope (Community Edition)[/b]
[i]🌸 Part of GoemonYae Trading System (GYTS) 🌸[/i]


[b]🌸 --------- INTRODUCTION --------- 🌸[/b]

[b]💮 What is the Kinetic Trend Envelope?[/b]

The Kinetic Trend Envelope (KTE) is an adaptive directional trailing stop in the lineage of SuperTrend, rebuilt around the premise that [i]volatility is kinetic energy[/i]. It measures per-bar motion with five academically grounded volatility estimators, then widens the envelope as energy rises and contracts it as motion settles.

In an uptrend, the lower band ratchets higher and never retreats; in a downtrend, the upper band ratchets lower. The direction changes when the active stop is breached, after which the opposite side becomes the new trailing stop.


[b]💮 Why Use This Indicator?[/b]

Conventional trailing stops typically combine a price anchor with one symmetric ATR-derived width. The KTE extends that model with:
[list]
[*][b]Asymmetric volatility profiling[/b] — Bullish- and bearish-candle volatility shape the upper and lower bands independently.
[*][b]Three direction-switch methods[/b] — High/low, close, or a smoothed estimator controls flip sensitivity without moving the band anchor.
[*][b]Five volatility estimators[/b] — ATR plus Parkinson, Garman-Klass, Rogers-Satchell, and Yang-Zhang covers different treatments of gaps, drift, and intrabar range.
[/list]The outputs are calibrated to a common width basis, so [i]Volatility Factor[/i] remains interpretable across estimators and price scales. Fine adjustment may still be useful, but switching estimators should not require re-tuning by orders of magnitude.


[image]https://www.tradingview.com/x/dFslMw98/[/image][i]↑ The KTE on a trending instrument. The thick line is the active trailing stop; the thin line shows the opposing side of the envelope. Both expand and contract with market energy.[/i]


[image]https://www.tradingview.com/x/dbphPZxX/[/image][i]↑ KTE beside TradingView's built-in SuperTrend, both using ATR with a 10-bar lookback. KTE's asymmetric profile changes how each side responds to directional volatility while the monotonic active band avoids premature loosening.[/i]



[b]🌸 --------- HOW IT WORKS --------- 🌸[/b]

[b]💮 Core Concept[/b]

The bands share a smoothed price estimator as their anchor, but use separate volatility profiles:
[list]
[*][b]Upper band[/b] = estimator + (factor × bullish-candle volatility)
[*][b]Lower band[/b] = estimator − (factor × bearish-candle volatility)
[/list]In a bullish state, the lower band is active and can only rise. In a bearish state, the upper band is active and can only fall. This monotonic constraint prevents a live trailing stop from loosening within the trend.

The selected direction-switch method changes only the breach test. It does not change the smoothed estimator anchoring the envelope, so a wick-sensitive trigger cannot drag the bands around with the wick.


[b]💮 The Five Volatility Estimators[/b]

Each estimator reads a different part of the OHLC bar:
[list]
[*][b]ATR (Wilder, 1978)[/b] — Familiar baseline that handles gaps through true range.
[*][b]Parkinson (1980)[/b] — Uses high-low range; efficient under continuous, low-drift conditions.
[*][b]Garman-Klass (1980)[/b] — Adds open-close information; favours continuous sessions without material gaps.
[*][b]Rogers-Satchell (1991)[/b] — Drift-independent and well suited to trending, continuously traded instruments.
[*][b]Yang-Zhang (2000)[/b] — Combines overnight gaps, open-close movement, and Rogers-Satchell; the gap-aware default.
[/list]Statistical efficiency does not guarantee a visibly tighter stop. At slow [i]Adaptation Speed[/i] settings, long averaging makes the estimators look similar; at fast settings, their different treatments of gaps, drift, and range become more visible. Choose according to the instrument's behaviour rather than expecting one estimator always to produce the narrowest band.


[image]https://www.tradingview.com/x/xzlMW8UP/[/image][i]↑ ATR and Yang-Zhang at Adaptation Speed 2. The long profile memory (low speed) smooths away most of the difference, so the two envelopes nearly overlap.[/i]


[image]https://www.tradingview.com/x/330aAL6B/[/image][i]↑ ATR and Yang-Zhang at Adaptation Speed 8. The short profile memory (high speed) exposes their different volatility readings, producing visibly distinct envelope widths.[/i]


[b]💮 Asymmetric Volatility Profiling and Adaptation Speed[/b]

The KTE stores volatility from bullish and bearish candles separately. Bullish samples determine the upper width; bearish samples determine the lower width. This allows the two sides to respond differently when upward and downward motion carry different energy.

[i]Adaptation Speed[/i] controls the memory of this profile, not the speed of the price estimator and not the distance of the stop by itself. Its 1–10 scale maps logarithmically to an internal window:
[list]
[*][b]Speed 3[/b] — approximately 878 bars: stable and slow to re-weight
[*][b]Default 3.5[/b] — approximately 570 bars: general-purpose smoothing
[*][b]Speed 8[/b] — approximately 11 bars: highly responsive to recent volatility
[*][b]Speed 10[/b] — approximately 2 bars: extremely reactive and noisy
[/list][b]Faster does not necessarily mean closer to price.[/b] During a volatility burst, a fast profile recognises the expansion sooner and may widen the band sharply. Because the active stop cannot loosen, it can then remain flat until the estimator catches up. A slow profile dilutes the same burst across much more history, so its narrower band may appear to follow price faster.

This is why two instances matched during a calm period can separate during a shock, especially when they also use different [i]Volatility Factor[/i] values. Compare Adaptation Speed with the same factor first; matching lines in one regime does not make two configurations equivalent elsewhere.

The profiles are also direction-conditioned: bullish samples are replaced by later bullish candles and bearish samples by later bearish candles. A recent high-volatility sample can therefore persist through a run of opposite-colour candles, producing deliberate step-like plateaux in the relevant band.


[image]https://www.tradingview.com/x/BDjJpEBK/[/image][i]↑ Asymmetric profiling in action: the upper and lower widths respond independently to bullish- and bearish-candle volatility.[/i]


[b]💮 Direction Switch Methods[/b]

The breach source sets the balance between responsiveness and false flips:
[list]
[*][b]On high/low[/b] — Uses the current bar's wick and can switch on the breach bar. Fastest and most sensitive to noise.
[*][b]On close[/b] — Uses the previous confirmed close; the switch appears on the following bar.
[*][b]On estimator[/b] — Uses the previous smoothed estimator; the most conservative default, also switching on the following bar.
[/list]
[image]https://www.tradingview.com/x/8LSepvHB/[/image][i]↑ The three switch methods share the same band geometry but change direction at different times.[/i]



[b]🌸 --------- KEY FEATURES --------- 🌸[/b]

[b]💮 Eight Estimator Filters[/b]

The configurable price anchor includes:
[list]
[*][b]Ultimate Smoother, 2- or 3-pole[/b] — Low-noise, near-zero-lag passband response; the 2-pole version is the default.
[*][b]Super Smoother, 2- or 3-pole[/b] — Ehlers low-pass filters for progressively stronger smoothing.
[*][b]BiQuad[/b] — Second-order low-pass filter with an adjustable Q-factor.
[*][b]ADXvma[/b] — Adapts to trend strength and tends to flatten in ranges.
[*][b]MAMA[/b] — Cycle-adaptive MESA moving average.
[*][b]A2RMA[/b] — Adaptive recursive moving average with adjustable gamma.
[/list]They are provided by the open-source [url=https://www.tradingview.com/script/Mm789eKn-GYTS-FiltersToolkit-Library/]FiltersToolkit[/url] library.


[b]💮 Visual Layering[/b]

The display separates function from context:
[list]
[*][b]Active band[/b] — Thick directional trailing-stop line
[*][b]Opposing band[/b] — Thin reference for the inactive side
[*][b]Channel fill[/b] — Visual separation between the estimator and each band
[*][b]Estimator[/b] — Optional smoothed anchor
[/list]Palette, light/dark mode, widths, and transparencies can be adjusted independently.



[b]🌸 --------- USAGE GUIDE --------- 🌸[/b]

[b]💮 Getting Started[/b]

Start with the defaults, observe several calm and volatile regimes, and change one dimension at a time:
[list]
[*]Tune [i]Volatility Factor[/i] for the preferred stop distance.
[*]Tune [i]Adaptation Speed[/i] for how quickly width should respond to regime changes.
[*]Choose the direction-switch method for the preferred confirmation level.
[*]Change the volatility estimator only when its assumptions better fit the instrument.
[/list]
[b]💮 Choosing a Volatility Estimator[/b]
[list]
[*][b]Gapped equities[/b] — Yang-Zhang accounts for overnight movement.
[*][b]Trending 24/7 markets[/b] — Rogers-Satchell is drift-independent without a separate gap component.
[*][b]Continuous, range-led markets[/b] — Parkinson or Garman-Klass offers efficient range-based measurement under their assumptions.
[*][b]Familiar baseline[/b] — ATR provides conventional true-range behaviour.
[/list]On continuous instruments, Rogers-Satchell and Yang-Zhang may look very similar because there are few gaps to distinguish them. Use the [url=https://www.tradingview.com/script/T4ujAd60-GYTS-Volatility-Toolkit/]Volatility Toolkit[/url] to compare their raw behaviour on the intended instrument.


[image]https://www.tradingview.com/x/zwDdDoL2/[/image][i]↑ Three estimators compared on one instrument, each reading a different combination of OHLC information.[/i]


[b]💮 Tuning Width and Responsiveness[/b]

These controls solve different problems:
[list]
[*][b]Volatility Factor[/b] — Sets the distance per unit of measured volatility.
[*][b]Adaptation Speed[/b] — Sets the memory of the bullish/bearish profile; faster can widen the stop sooner during shocks.
[*][b]Volatility Lookback[/b] — Sets how quickly the underlying per-bar volatility estimate changes.
[*][b]Estimator Lookback[/b] — Sets the smoothness of the price anchor.
[/list]Use symptoms to guide adjustment:
[list]
[*][b]Frequent flips on minor pullbacks[/b] — Increase Volatility Factor or use a more conservative switch method (e.g. "on estimator").
[*][b]Excessive give-back[/b] — Decrease Volatility Factor or use a more responsive switch method (e.g. "on high/low").
[*][b]Width reacts too slowly to regime changes[/b] — Increase Adaptation Speed or reduce Volatility Lookback.
[*][b]Bands become erratic during shocks[/b] — Reduce Adaptation Speed or increase Volatility Lookback.
[/list]
[image]https://www.tradingview.com/x/cMaucj4f/[/image][i]↑ A tight factor follows price more closely and flips more often; a loose factor tolerates larger pullbacks.[/i]

[b]💮 Trading Applications[/b]
[list]
[*][b]Discretionary trailing stop[/b] — Move a protective stop with the active band as it tightens.
[*][b]Trend confirmation[/b] — Accept long signals only during a bullish KTE state, and short signals only while bearish.
[*][b]Exit timing[/b] — Treat a direction change as an exit when the trade thesis is trend-following.
[/list]
[b]💮 Integration with GYTS Suite[/b]

The visible bands and estimator can be selected as sources by compatible Pine scripts. Two packed streams are also exposed:
[list]
[*][i]🔗 STREAM KTE 🪜 Trailing Stoploss[/i] — Positive lower-band value in a bullish state; negative upper-band value in a bearish state.
[*][i]🔗 STREAM KTE 🪜 Mechanism[/i] — Encodes the switch method and scale-invariant estimator relationship for compatible consumers.
[/list]The KTE is, first and foremost, a trailing stop, and these streams are built for stop management. The [url=https://www.tradingview.com/script/1SsAkqKO-GYTS-Pro-Order-Orchestrator/]Order Orchestrator[/url] strategy consumes the [i]Trailing Stoploss[/i] and [i]Mechanism[/i] streams [b]together[/b]: the first supplies the active stop level and its direction, the second makes the strategy's trailing-exit runner follow whatever switch method and estimator you set here. So the stop is configured once, in the KTE.

Beyond that primary role, the signed trailing-stop stream can also serve as a trend signal, since its sign flips with direction: it can be read through sign and magnitude as an entry/exit signal, including by [url=https://www.tradingview.com/script/FhSSTxaX-GYTS-CE-Flux-Composer/]Flux Composer[/url]. The KTE can also be paired with [url=https://www.tradingview.com/script/2CR8Rt1O-GYTS-CE-Market-Regime-Detector/]Market Regime Detector[/url] so flips are acted on only when the broader regime supports trend-following behaviour.


[b]🌸 --------- LIMITATIONS --------- 🌸[/b]
[list]
[*][b]Trailing-stop latency[/b] — Every trailing stop gives back some of the move between the trend extreme and the eventual breach.
[*][b]Whipsaws in ranges[/b] — Low-energy chop can produce repeated flips; a regime filter may help when ranging conditions dominate.
[*][b]Fast adaptation can widen the stop[/b] — Higher Adaptation Speed means faster volatility response, not guaranteed proximity to price.
[*][b]Direction-conditioned memory[/b] — A bullish or bearish outlier remains in its own profile until enough matching-direction samples replace it, which can create plateaux after shocks.
[*][b]Warm-up and sample size[/b] — Long profile windows need sufficient chart history; strongly one-sided markets may leave one side with few recent samples.
[/list]
[b]🌸 --------- CREDITS --------- 🌸[/b]

[b]💮 Academic Sources[/b]
[list]
[*]Wilder, J. W. (1978). [i]New Concepts in Technical Trading Systems[/i]. Trend Research.
[*]Parkinson, M. (1980). The Extreme Value Method for Estimating the Variance of the Rate of Return. [i]Journal of Business, 53[/i](1), 61–65. [url=https://doi.org/10.1086/296071]DOI[/url]
[*]Garman, M. B., & Klass, M. J. (1980). On the Estimation of Security Price Volatilities from Historical Data. [i]Journal of Business, 53[/i](1), 67–78. [url=https://doi.org/10.1086/296072]DOI[/url]
[*]Rogers, L. C. G., & Satchell, S. E. (1991). Estimating Variance from High, Low and Closing Prices. [i]Annals of Applied Probability, 1[/i](4), 504–512. [url=https://doi.org/10.1214/aoap/1177005835]DOI[/url]
[*]Yang, D., & Zhang, Q. (2000). Drift-Independent Volatility Estimation Based on High, Low, Open, and Close Prices. [i]Journal of Business, 73[/i](3), 477–491. [url=https://doi.org/10.1086/209650]DOI[/url]
[*]Ehlers, J. F. (2024). The Ultimate Smoother. [i]Technical Analysis of Stocks & Commodities[/i], 2024-04. [url=https://traders.com/Documentation/FEEDbk_docs/2024/04/TradersTips.html]TASC[/url]
[*]Ehlers, J. F. (2004). [i]Cybernetic Analysis for Stocks and Futures[/i]. Wiley. Covers SuperSmoother, MAMA and more.
[/list]
[b]💮 Inspiration[/b]
[list]
[*]Thanks to Trendoscope for inspiring us with the [url=https://www.tradingview.com/script/8EZaD3CW-Supertrend-Ladder-ATR/]Supertrend - Ladder ATR[/url] (2021). It derives long-side stop distance from bearish-candle ATR and short-side distance from bullish-candle ATR, which is one of the mechanisms that we tried to develop further with the KTE.
[/list]
[b]💮 Libraries Used[/b]
[list]
[*][url=https://www.tradingview.com/script/Mm789eKn-GYTS-FiltersToolkit-Library/]FiltersToolkit[/url] — Ultimate Smoother, Super Smoother, BiQuad, ADXvma, MAMA, and A2RMA
[*][url=https://www.tradingview.com/script/Th3bPWea-GYTS-VolatilityToolkit-Library/]VolatilityToolkit[/url] — Parkinson, Garman-Klass, Rogers-Satchell, and Yang-Zhang estimators
[*][url=https://www.tradingview.com/script/3FCxmP9q-MathTransform/]MathTransform[/url] — Logarithmic scaling for Adaptation Speed
[*][url=https://www.tradingview.com/script/BXVj1kBS-ColourUtilities/]ColourUtilities[/url] — Palette management and light/dark-mode colour adjustment
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GoemonYae, 2026-07
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
// ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░
// ░▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░
// ░▒▓                                                                                                   ▓▒░
// ░▒▓        ██████╗ ██╗   ██╗████████╗███████╗                                                         ▓▒░
// ░▒▓       ██╔════╝ ╚██╗ ██╔╝╚══██╔══╝██╔════╝        GoemonYae Trading System                         ▓▒░
// ░▒▓       ██║  ███╗ ╚████╔╝    ██║   ███████╗                                                         ▓▒░
// ░▒▓       ██║   ██║  ╚██╔╝     ██║   ╚════██║        Kinetic Trend Envelope (Community Edition)       ▓▒░
// ░▒▓       ╚██████╔╝   ██║      ██║   ███████║        Adaptive Trailing Stop Indicator                 ▓▒░
// ░▒▓        ╚═════╝    ╚═╝      ╚═╝   ╚══════╝        Version 1.0.1                                    ▓▒░
// ░▒▓                                                                                                   ▓▒░
// ░▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░
// ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
//@version=6
//@description     GYTS "Kinetic Trend Envelope" (Community Edition) — Adaptive Trailing Stop Indicator

indicator('[GYTS-CE] Kinetic Trend Envelope', '[GYTS-CE] KTE', overlay=true, precision=4, max_lines_count=500, max_boxes_count=500)

const string VERSION = '1.0.1'

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//                                           KINETIC TREND ENVELOPE (KTE)
//                                      An Energy-State Adaptive Trailing Stop
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
//
// PHILOSOPHY
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Markets are not static structures but kinetic systems. Energy flows through them, accumulates, and dissipates. The Kinetic
// Trend Envelope captures this energy signature, expanding when the market expends force and contracting when motion settles
// into equilibrium.
//
// Unlike conventional trend-following stops that treat volatility as mere noise to be filtered, the KTE recognises volatility
// for what it truly is: the kinetic energy of the market. Every price movement represents energy transfer — from buyer to
// seller, from uncertainty to conviction, from accumulation to distribution.
//
// WHY "KINETIC"?
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// The term "kinetic" is deliberately chosen from physics, where kinetic energy (½mv²) describes energy possessed by an object
// due to its motion. In our context:
//
//   • Volatility IS kinetic energy — ATR, Parkinson, Garman-Klass, Rogers-Satchell, Yang-Zhang are not arbitrary statistical measures.
//     They quantify how much the market is moving, how much energy is being expended in price discovery.
//   • Higher volatility = more kinetic energy = wider envelope bands
//   • Lower volatility = less kinetic energy = tighter envelope bands
//
// This indicator doesn't just follow price; it measures the market's energy state and adapts its protective envelope
// accordingly. The bands breathe with the market's rhythm, expanding during periods of high energy expenditure and
// contracting when the market conserves its force.
//
// MATHEMATICAL FOUNDATIONS
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// The KTE employs sophisticated volatility estimators from quantitative finance:
//
//   1. Average True Range (ATR)      — Wilder's classic, handles gaps, industry standard
//   2. Parkinson Estimator           — Range-based, ~5× statistical efficiency
//   3. Garman-Klass Estimator        — OHLC-optimised, ~7× efficiency
//   4. Rogers-Satchell Estimator     — Drift-independent, ~8× efficiency
//   5. Yang-Zhang Estimator          — Gap-aware, drift-independent, most comprehensive
//
// Each estimator captures different aspects of market energy, allowing traders to select the measure most appropriate
// for their instrument and timeframe.
//
// ADAPTIVE INTELLIGENCE
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// The KTE features asymmetric volatility profiling — it separately tracks volatility during bullish and bearish candles,
// recognising that markets often exhibit different energy characteristics in each direction. This creates naturally
// asymmetric bands that respect the market's directional energy bias.
//
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════


//==================================================================//
//#region                       IMPORTS                             //
//==================================================================//

import GoemonYae/FiltersToolkit/2 as filt
import GoemonYae/MathTransform/5 as mt
import GoemonYae/ColourUtilities/8 as cu
import GoemonYae/VolatilityToolkit/3 as vol
import GoemonYae/ValidationUtilities/1 as vu

//#endregion


//==================================================================//
//#region                 CONSTANTS AND ENUMS                       //
//==================================================================//

// @enum                Trend direction tracked by the KTE state machine.
// @field bull          Bullish trend (active stop is the lower band).
// @field bear          Bearish trend (active stop is the upper band).
enum eDirection
    bull
    bear

// @enum                Volatility (kinetic energy) estimation method.
// @field atr           Classic Wilder ATR, handles gaps.
// @field parkinson     Range-based estimator, ~5× efficiency.
// @field garman_klass  OHLC-optimised, ~7× efficiency.
// @field rogers_satchell Drift-independent, ~8× efficiency.
// @field yang_zhang    Gap-aware, drift-independent.
enum eVolatilityMeasure
    atr              = 'Average True Range'
    parkinson        = 'Parkinson'
    garman_klass     = 'Garman-Klass'
    rogers_satchell  = 'Rogers-Satchell'
    yang_zhang       = 'Yang-Zhang'

// @enum                Direction switch trigger method.
// @field high_low      Uses high for bullish breach, low for bearish (most responsive, same-bar switch).
// @field on_close      Uses closing price (moderate, switch appears next bar after confirmation).
// @field estimator     Uses smoothed estimator (most conservative, switch appears next bar).
enum eSwitchMethod
    high_low   = 'on high/low'
    on_close   = 'on close'
    estimator  = 'on estimator'

// @enum                Pre-filtering algorithm for price source.
// @field ultimate_2    Ultimate Smoother (2-Pole), zero-lag in passband.
// @field ultimate_3    Ultimate Smoother (3-Pole), smoother with zero lag but overshoots.
// @field super_2       Super Smoother (2-Pole), excellent noise reduction.
// @field super_3       Super Smoother (3-Pole), maximum smoothing.
// @field biquad        BiQuad low pass filter, adjustable Q-factor.
// @field adxvma        ADXvma, adapts to trend strength.
// @field mama          MESA Adaptive Moving Average, tracks cycles.
// @field a2rma         Adaptive Autonomous Recursive MA.
enum eFilterType
    ultimate_2 = 'Ultimate Smoother (2-Pole)'
    ultimate_3 = 'Ultimate Smoother (3-Pole)'
    super_2    = 'Super Smoother (2-Pole)'
    super_3    = 'Super Smoother (3-Pole)'
    biquad     = 'BiQuad (Low Pass)'
    adxvma     = 'ADXvma'
    mama       = 'MAMA (Kaufman)'
    a2rma      = 'A2RMA'


//#endregion


//==================================================================//
//#region                  INPUT PARAMETERS                         //
//==================================================================//

const string g_general    = '🎛️ ────── General Settings ─────── 🎛️'
const string g_estimator  = '📐 ────────── Estimator ────────── 📐'
const string g_volatility = '📊 ────────── Volatility ────────── 📊'
const string g_kte        = '📈 ─────── Envelope (KTE) ──────── 📈'
const string g_visual     = '🎨 ──────── Visualisation ──────── 🎨'
const string g_alerts     = '🔔 ─────────── Alerts ──────────── 🔔'

//──────────────────────────── tooltips ────────────────────────────//

const string tt_source = 'The price source used for the estimator calculation.'

// Estimator (Price Filter)
const string tt_estimator_filter = 'Smoothing filter applied to the price source to produce the estimator.'
  + '\n\nThe estimator can be displayed on the chart (see "Show Estimator") and optionally '
  + 'used for direction switching (see "Direction Switch Method → on estimator").'
  + '\n\n• Ultimate Smoother (2/3-pole): Zero-lag in passband; 3-pole has true zero lag; can overshoot'
  + '\n• Super Smoother (2/3-pole): Ehlers low-lag IIR filter; excellent noise reduction'
  + '\n• BiQuad: 2-pole low-pass with adjustable Q-factor'
  + '\n• ADXvma: Adaptive to trend strength (flat in ranging markets)'
  + '\n• MAMA: MESA Adaptive Moving Average, tracks cycles'
  + '\n• A2RMA: Adaptive Autonomous Recursive MA, adjusts to volatility'

const string tt_estimator_lookback = 'Lookback period for the price estimator filter.'
  + '\n\nLower values = more responsive to price action'
  + '\nHigher values = smoother estimator, fewer direction changes'
  + '\n\nAffects the estimator line display and, when "Direction Switch Method" is set to '
  + '"on estimator", determines direction change sensitivity.'

// Shared between the Estimator and Volatility filter-factor inputs — the parameter has the
// same meaning in both groups (Q-factor for BiQuad, gamma for A2RMA, ignored elsewhere).
const string tt_filter_factor = 'Filter-specific parameter (Q-factor or Gamma). '
  + 'Only BiQuad and A2RMA use this setting; other filters ignore it.'
  + '\n\nBiQuad (Q-factor, typically ~0.7):'
  + '\n• Lower Q (0.3-0.5): Heavily damped, very smooth'
  + '\n• Q ≈ 0.707: Butterworth (maximally flat)'
  + '\n• Higher Q (0.8-1.0): More selective, may overshoot'
  + '\n\nA2RMA (gamma, typically 1.5-3.0):'
  + '\n• Lower gamma: More reactive to small moves'
  + '\n• Higher gamma: Flatter in ranges, responds to breakouts'
  + '\n\nNote: Default 0.70 is tuned for BiQuad. For A2RMA, increase to the typical range above.'

// Volatility Measure
const string tt_volatility_measure = "Selects the volatility (kinetic energy) estimator for band width calculation:"
  + "\n\n• Average True Range: Classic Wilder ATR, handles gaps, industry standard"
  + "\n• Parkinson (High-Low): Range-based, ~5× efficiency, best for ranging markets"
  + "\n• Garman-Klass: Adds open/close dynamics, ~7× efficiency, short-term focus"
  + "\n• Rogers-Satchell: Drift-independent, ~8× efficiency, ideal for trending/crypto"
  + "\n• Yang-Zhang: Most comprehensive, handles gaps + drift, best for daily TF"
  + "\n\nThe estimators measure different quantities, so at one Volatility Factor they would otherwise produce "
  + "different stop distances (ATR runs widest). Each is internally scaled by a per-estimator width factor so one "
  + "Volatility Factor yields comparable band widths across all five — expect only minor fine-tuning when switching."

const string tt_volatility_lookback = 'Lookback period for the selected volatility (kinetic energy) estimator.'
  + '\n\nLower values = more responsive to energy changes'
  + '\nHigher values = smoother, more stable volatility readout'
  + '\n\nNote: Distinct from "Adaptation Speed", which operates on top of this per-bar reading '
  + 'to smooth the bull-vs-bear split.'

const string tt_volatility_filter = 'Smoothing filter applied to the volatility (kinetic energy) calculation.'
  + '\n\nNote: ATR and Yang-Zhang ignore this setting — the dropdown is greyed out when either is selected. '
  + 'ATR always uses RMA (Wilder smoothing); Yang-Zhang uses its internal rolling variance.'
  + '\n\n• SMA / EMA: Traditional moving averages'
  + '\n• Ultimate Smoother: Zero-lag in passband'
  + '\n• Super Smoother: Ehlers low-lag IIR filter; excellent noise reduction'
  + '\n• BiQuad: 2-pole low-pass with adjustable Q-factor'
  + '\n• ADXvma: Adaptive to trend strength (flat in ranging markets)'
  + '\n• MAMA: MESA Adaptive Moving Average, tracks cycles'
  + '\n• A2RMA: Adaptive Autonomous Recursive MA, adjusts to volatility'

// Envelope (KTE)
// Naming note: this control is exposed as "Adaptation Speed" rather than "Adaptation Window".
// The input is a 1-10 scale, not a bar count — higher values mean *faster* adaptation
// (smaller internal lookback) and lower values mean slower adaptation (larger internal lookback).
// "Window" was rejected because it implies a fixed length in bars, which the input is not;
// "Speed" matches the monotonic, scale-like UX the slider provides.
const string tt_adaptation_speed = 'Speed at which the asymmetric bull/bear volatility profile adapts '
  + 'to recent price action.'
  + '\n\nNote: Distinct from "Volatility Lookback", which sets the per-bar estimator period. '
  + 'Adaptation Speed operates on top of that, smoothing the bull-vs-bear split.'
  + '\n\nThough not a direct width multiplier like "Volatility Factor", faster adaptation can '
  + 'visibly widen the bands during volatility spikes, recent samples dominate the smaller averaging window.'
  + '\n\nBecause faster adaptation averages the profile over fewer bars, it also makes the choice of '
  + 'Volatility Measure more visible; at slow settings the estimators look nearly identical.'
  + '\n\nHigher values = faster adaptation'
  + '\nLower values = smoother, more stable bands'
  + '\n\nTip: increase this value when few bars are available, otherwise early readings dominate the profile.'

const string tt_volatility_factor = 'Multiplier applied to the kinetic energy measure to determine envelope width.'
  + '\n\nThe envelope half-width is approximately factor × typical_bar_volatility, in price units. '
  + 'After internal normalisation, the default 5.0 produces sensible widths for most instruments and '
  + 'timeframes; values in the 3–8 range cover most use cases, regardless of the active volatility estimator.'
  + '\n\nHigher values = wider envelope, fewer signals, later entries'
  + '\nLower values = tighter envelope, more signals, earlier entries'

const string tt_switch_method = 'Determines what price must breach the envelope to trigger a direction change:'
  + '\n\n• On high/low: Uses high for bullish breach, low for bearish (most responsive). '
  + 'Switch appears on the same bar as the breach — like a limit order filling immediately.'
  + '\n• On close: Uses the previous bar\'s closing price. '
  + 'Switch appears on the bar after the breach — the breach is confirmed at bar close, acted upon next bar.'
  + '\n• On estimator: Uses the previous bar\'s smoothed estimator (most conservative, reduces whipsaws). '
  + 'Same next-bar timing as "on close".'
  + '\n\nNote: When set to "on estimator", filter configuration lives in the "Estimator" group above.'
  + '\n\nNote: In "on high/low" the flip fires on the breach bar itself, but the thick active line is drawn back to '
  + 'the previous bar, so its colour appears to change one bar before the breaching candle. This is purely a drawing '
  + 'effect — the direction flip, alerts and data streams all update on the breach bar. The two next-bar modes do not '
  + 'show this because their line connects back onto the breach bar.'

// Visualisation
const string tt_palette = 'Selects the colour palette for Kinetic Trend Envelope visualisation.'

const string tt_dark_mode = "Adjusts colour intensity, saturation and brightness for optimal visibility on dark backgrounds."
  + "\n\nDark mode deepens fill colours against a dark chart. Light mode softens and mutes them for legibility on white."

const string tt_fill_transparency = 'Transparency of the fill between price and KTE band.'
  + '\n\n0 = fully opaque, 100 = fully transparent.'

const string tt_show_estimator = 'Display the smoothed price estimator line on the chart.'
  + '\n\nThe estimator provides a smoothed view of price action. When "Direction Switch Method" '
  + 'is set to "on estimator", this line determines when direction changes occur.'

const string tt_opposing = 'Displays the opposing band (target) to visualise the full envelope width.'

// Alerts
const string tt_alerts_bull = "Includes bullish direction changes in the 'Any alert() function call' stream."
  + "\n\nOnly affects the bundled alert stream — the dedicated 'Direction → Bullish' alert condition"
  + " in TradingView's dropdown works independently of this toggle."
  + "\n\nUseful for receiving all events through a single alert slot (saves alert quota)."

const string tt_alerts_bear = "Includes bearish direction changes in the 'Any alert() function call' stream."
  + "\n\nOnly affects the bundled alert stream — the dedicated 'Direction → Bearish' alert condition"
  + " in TradingView's dropdown works independently of this toggle."
  + "\n\nUseful for receiving all events through a single alert slot (saves alert quota)."

//────────────────────────── general inputs ────────────────────────//

i_source = input.source(hlc3, 'Source', group=g_general, tooltip=tt_source)

//────────────────────────────── estimator ─────────────────────────//

i_estimator_filter        = input.enum(eFilterType.ultimate_2, 'Estimator Filter', group=g_estimator, tooltip=tt_estimator_filter)
i_estimator_lookback      = input.int(15, 'Estimator Lookback', minval=2, maxval=200, group=g_estimator, tooltip=tt_estimator_lookback)
i_estimator_filter_factor = input.float(0.7, 'Estimator Filter Factor (Q / Gamma)', minval=0.1, maxval=5.0, step=0.1, group=g_estimator, tooltip=tt_filter_factor, active=(i_estimator_filter == eFilterType.biquad or i_estimator_filter == eFilterType.a2rma))

//────────────────────────────── volatility ────────────────────────//

i_volatility_measure          = input.enum(eVolatilityMeasure.yang_zhang, 'Volatility Measure', group=g_volatility, tooltip=tt_volatility_measure)
i_volatility_lookback         = input.int(14, 'Volatility Lookback', minval=1, maxval=200, group=g_volatility, tooltip=tt_volatility_lookback)
// ATR uses Wilder RMA internally; Yang-Zhang uses rolling variance. Both bypass the filter pipeline,
// so the filter dropdown and its factor do not apply to those two measures.
bool b_volatility_uses_filter = i_volatility_measure != eVolatilityMeasure.atr and i_volatility_measure != eVolatilityMeasure.yang_zhang
i_volatility_filter           = input.enum(vol.eFilterType.sma, 'Volatility Filter', group=g_volatility, tooltip=tt_volatility_filter, active=b_volatility_uses_filter)
i_volatility_filter_factor    = input.float(0.7, 'Volatility Filter Factor (Q / Gamma)', minval=0.1, maxval=5.0, step=0.1, group=g_volatility, tooltip=tt_filter_factor, active=(b_volatility_uses_filter and (i_volatility_filter == vol.eFilterType.biquad or i_volatility_filter == vol.eFilterType.a2rma)))

//──────────────────────────── envelope (kte) ──────────────────────//

i_adaptation_speed  = input.float(3.5, 'Adaptation Speed', minval=1.0, maxval=10.0, step=0.1, group=g_kte, tooltip=tt_adaptation_speed)
i_volatility_factor = input.float(5.0, 'Volatility Factor', minval=0.5, maxval=50.0, step=0.1, group=g_kte, tooltip=tt_volatility_factor)
i_switch_method     = input.enum(eSwitchMethod.estimator, 'Direction Switch Method', group=g_kte, tooltip=tt_switch_method)

//─────────────────────────── visualisation ────────────────────────//

i_palette_name         = input.enum(cu.PaletteNames.gyts_purple, 'Palette', group=g_visual, tooltip=tt_palette)
i_dark_mode            = input.bool(true, 'Dark Mode', group=g_visual, tooltip=tt_dark_mode)

// Regular KTE
i_kte_linewidth        = input.int(3, 'KTE Line Width', minval=1, maxval=10, inline='kte', group=g_visual)
i_kte_line_transp      = input.int(0, 'Transparency', minval=0, maxval=100, inline='kte', group=g_visual)
i_kte_fill_transp      = input.int(80, 'KTE Fill Transparency', minval=0, maxval=100, group=g_visual, tooltip=tt_fill_transparency)

// Opposing Band
i_show_opposing        = input.bool(true, 'Show Opposing Band', group=g_visual, tooltip=tt_opposing)
i_opposing_linewidth   = input.int(1, 'Opposing Band Line Width', minval=1, maxval=10, inline='opposing', group=g_visual, active=i_show_opposing)
i_opposing_line_transp = input.int(75, 'Transparency', minval=0, maxval=100, inline='opposing', group=g_visual, active=i_show_opposing)
i_opposing_fill_transp = input.int(92, 'Opposing Band Fill Transparency', minval=0, maxval=100, group=g_visual, active=i_show_opposing)

// Estimator
i_show_estimator       = input.bool(true, 'Show Estimator', group=g_visual, tooltip=tt_show_estimator)
i_est_width            = input.int(2, 'Estimator Width', minval=1, maxval=10, inline='est', group=g_visual, active=i_show_estimator)
i_est_line_transp      = input.int(20, 'Transparency', minval=0, maxval=100, inline='est', group=g_visual, active=i_show_estimator)

//──────────────────────────── alerts ──────────────────────────────//

i_use_alerts_bull    = input.bool(true,  "Alert: Direction → Bullish", group=g_alerts, tooltip=tt_alerts_bull)
i_use_alerts_bear    = input.bool(true,  "Alert: Direction → Bearish", group=g_alerts, tooltip=tt_alerts_bear)

//#endregion


//==================================================================//
//#region                  USER-DEFINED TYPES                       //
//==================================================================//

// @type                State for tracking volatility (kinetic energy) profiles
// @field arr_positive  <array<float>> Volatility values during bullish candles
// @field arr_negative  <array<float>> Volatility values during bearish candles
// @field arr_direction <array<int>> Recent candle directions (1=bullish, 0=bearish)
// @field n_pos         <int> Current count limit for positive array
// @field n_neg         <int> Current count limit for negative array
type VolatilityProfile
    array<float> arr_positive
    array<float> arr_negative
    array<int>   arr_direction
    int          n_pos
    int          n_neg

// @type                     State for Kinetic Trend Envelope calculation
// @field direction          <eDirection> Current trend direction
// @field lower_band         <float> Current lower band value
// @field upper_band         <float> Current upper band value
type KineticTrendState
    eDirection direction
    float      lower_band
    float      upper_band

//#endregion


//==================================================================//
//#region                     VALIDATION                            //
//==================================================================//

var validator = vu.ValidationFramework.new()

if barstate.isfirst
    validator.init()

    validator.validate_range("Estimator", "Estimator Lookback", i_estimator_lookback, 2, 200, 5, 100, "bars")
    validator.validate_range("Volatility", "Volatility Lookback", i_volatility_lookback, 1, 200, 5, 100, "bars")
    validator.validate_range("Envelope", "Adaptation Speed", i_adaptation_speed, 1.0, 10.0, 2.0, 8.0)
    validator.validate_range("Envelope", "Volatility Factor", i_volatility_factor, 0.5, 50.0, 2.0, 15.0)

    validator.trigger_errors()

//#endregion




//==================================================================//
//#region                VOLATILITY CALCULATIONS                    //
//==================================================================//

//──────────────────── adaptation speed scaling ────────────────────//

// Map the user-facing "Adaptation Speed" (1-10) to an internal lookback in bars. The mapping is logarithmic and inverted:
// speed 1 → ~5000-bar lookback (slow adaptation), speed 10 → ~2-bar lookback (very fast adaptation). The variable is named
// `adaptation_lookback` rather than `profile_lookback` to keep the input label (Adaptation Speed) and its derived value
// greppable from the same root, even though the value is technically the bar-count input to the asymmetric volatility profile.
adaptation_lookback = int(mt.scaler_logarithmic_interpolation(i_adaptation_speed, 1, 10, 5000, 2))

//───────────────────────── estimator calculation ──────────────────//

float estimator = switch i_estimator_filter
    eFilterType.ultimate_2 => filt.ultimate_smoother_2pole(i_source, i_estimator_lookback)
    eFilterType.ultimate_3 => filt.ultimate_smoother_3pole(i_source, i_estimator_lookback)
    eFilterType.super_2    => filt.super_smoother_2pole(i_source, i_estimator_lookback)
    eFilterType.super_3    => filt.super_smoother_3pole(i_source, i_estimator_lookback)
    eFilterType.biquad     => filt.lpf_biquad(i_source, i_estimator_lookback, i_estimator_filter_factor)
    eFilterType.adxvma     => filt.adxvma(i_source, i_estimator_lookback)
    eFilterType.a2rma      => filt.a2rma(i_source, i_estimator_lookback, i_estimator_filter_factor)
    eFilterType.mama       =>
        [m, f, k] = filt.mesa_adaptive_moving_average(i_source, lookback_period=i_estimator_lookback)
        m

//────────────────────── select active volatility ──────────────────//

// Use VolatilityToolkit library for range-based estimators with filter options
// Note: ATR uses ta.atr() for Wilder's RMA smoothing (industry standard)
//       Yang-Zhang uses internal rolling variance, filter_type not applicable
//
// Unit normalisation: ATR returns price units (e.g. ~$45 on a $4500 instrument), while the four range-based estimators
// return per-bar SD in log-return units (dimensionless, e.g. ~0.01). We first express each output as a fraction of price
// (`vol_pct`), then scale back to price units below — so `active_volatility` carries one consistent meaning across all
// five estimators and the user's `Volatility Factor` is asset-scale independent.
float vol_pct = switch i_volatility_measure
    eVolatilityMeasure.atr             => ta.atr(i_volatility_lookback) / math.max(close, 1e-10)  // floor denominator: guards close <= 0 / micro-price (cancels with the later × close on normal data)
    eVolatilityMeasure.parkinson       => vol.parkinson(i_volatility_lookback, i_volatility_filter, i_volatility_filter_factor)
    eVolatilityMeasure.garman_klass    => vol.garman_klass(i_volatility_lookback, i_volatility_filter, i_volatility_filter_factor)
    eVolatilityMeasure.rogers_satchell => vol.rogers_satchell(i_volatility_lookback, i_volatility_filter, i_volatility_filter_factor)
    eVolatilityMeasure.yang_zhang      => vol.yang_zhang(i_volatility_lookback)  // floors to a 2-bar window at lookback = 1 (the other four read a single bar)

// Per-estimator width-scale calibration. The five estimators measure different quantities, so at a fixed Volatility
// Factor they would emit different stop distances: ATR reports mean true range (~1.6× the log-return SD that the four
// range estimators report), so it runs widest. Multiplying by a per-estimator scale brings them onto a common basis so
// one Volatility Factor yields comparable widths; Yang-Zhang (the default) keeps a scale of 1.0, leaving the shipped
// default stop unchanged. ATR is set to 0.64 to offset its wider raw range; the four range estimators stay at 1.0.
const float SCALE_ATR             = 0.64
const float SCALE_PARKINSON       = 1.00
const float SCALE_GARMAN_KLASS    = 1.00
const float SCALE_ROGERS_SATCHELL = 1.00
const float SCALE_YANG_ZHANG      = 1.00
float vol_scale = switch i_volatility_measure
    eVolatilityMeasure.atr             => SCALE_ATR
    eVolatilityMeasure.parkinson       => SCALE_PARKINSON
    eVolatilityMeasure.garman_klass    => SCALE_GARMAN_KLASS
    eVolatilityMeasure.rogers_satchell => SCALE_ROGERS_SATCHELL
    eVolatilityMeasure.yang_zhang      => SCALE_YANG_ZHANG

// Convert back to price units for downstream band-width arithmetic.
float active_volatility = vol_pct * close * vol_scale

//#endregion


//==================================================================//
//#region              KINETIC TREND ENVELOPE CORE                  //
//==================================================================//

// @function                  Calculates adaptive Kinetic Trend Envelope with asymmetric volatility profiling
// @param volatility          <float> Current volatility (kinetic energy) value
// @param factor              <float> Volatility multiplier
// @param lookback            <int> Sensitivity lookback period
// @param band_anchor         <float> Price anchor for band positioning (always the estimator). Decoupled from switch method so the bands stay smooth regardless of switch sensitivity.
// @param switch_src          <float> Price source for direction switching (na for high/low mode)
// @returns                   <KineticTrendState> Updated KTE state
method calculate(KineticTrendState self, VolatilityProfile profile, float volatility, float factor, int lookback, float band_anchor, float switch_src) =>
    // Track candle direction and update volatility profiles
    bool is_bullish = close > open

    // ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // NON-REPAINTING CONTRACT — three legs, all built on Pine's `var` semantics
    // ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // 1. VAR-ARRAY ROLLBACK (per-tick safety). Every realtime tick of the live bar re-runs the script, but `var` state
    //    is rolled back to its previous-bar-close snapshot before the next tick fires. The unconditional `arr.push(...)`
    //    below therefore commits exactly ONE sample per bar — the final tick (i.e. with `close` = the bar's eventual
    //    close). This is why pushes are unconditional rather than gated on `barstate.isconfirmed`, and the same reason
    //    this method as a whole does NOT need `barstate.isconfirmed` to be safe.
    //
    // 2. FLIP TEST READS COMMITTED VALUES. The direction-flip comparison further below (`src_min < self.lower_band` /
    //    `src_max > self.upper_band`) reads `self.lower_band` / `self.upper_band` BEFORE this method has reassigned
    //    them — those fields still hold the prior bar's committed values. For `on_close` and `on_estimator`, the
    //    switch source is also from the previous bar (`close[1]` / `estimator[1]`), so BOTH sides of the comparison
    //    are committed values — zero live-bar mutation. For `high_low`, source is the current bar's monotonic
    //    `low`/`high`. No self-reference, no circularity in any mode.
    //
    // 3. BANDS ANCHORED TO ESTIMATOR. `band_anchor = estimator` (set by the caller). Switching `i_switch_method` only
    //    changes *when* flips fire; it does NOT drag the band location around with the wicks. See the SWITCH-METHOD
    //    SEMANTICS note above `switch_source = …` for the timing implications of each option.
    // ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    vu.push_limited(profile.arr_direction, is_bullish ? 1 : 0, lookback)

    // Calculate adaptive array sizes BEFORE the asymmetric push, so the push uses the freshly-computed limits. Reading
    // limits stale here would discard the first opposing-direction sample during a strongly one-directional warmup (e.g.
    // all-bull bars drive n_neg to 0, and the first bear sample is shifted out immediately). Floor both sides at 1.
    //
    // arr_direction is an array<int>: array.avg() would resolve to its integer overload and truncate the 0/1 mean to
    // {0, 1} (1 only when every sample is bullish), collapsing the asymmetric split to all-or-nothing. Compute the
    // proportion of bullish candles in floating point instead, so the bull/bear allocation is genuinely proportional.
    int   dir_count      = profile.arr_direction.size()
    float proportion_pos = dir_count > 0 ? float(profile.arr_direction.sum()) / dir_count : 0.5
    profile.n_pos := math.max(int(proportion_pos * lookback), 1)
    profile.n_neg := math.max(lookback - profile.n_pos, 1)

    if is_bullish
        vu.push_limited(profile.arr_positive, volatility, profile.n_pos)
    else
        vu.push_limited(profile.arr_negative, volatility, profile.n_neg)

    // push_limited() trims only the buffer it pushes to, and only by one element per call, so a buffer whose target
    // shrank while the opposite direction was running would otherwise retain stale samples indefinitely. Trim BOTH
    // buffers down to their current limits every bar to keep each within its window.
    while profile.arr_positive.size() > profile.n_pos
        profile.arr_positive.shift()
    while profile.arr_negative.size() > profile.n_neg
        profile.arr_negative.shift()

    // Asymmetric volatility (kinetic energy) averages. Fall back to the current per-bar volatility while a directional
    // buffer is still empty (a one-sided run that has not yet produced an opposing candle), so the active band is never
    // left na once the estimator and volatility have warmed up.
    float vol_positive = profile.arr_positive.size() > 0 ? profile.arr_positive.avg() : volatility
    float vol_negative = profile.arr_negative.size() > 0 ? profile.arr_negative.avg() : volatility

    // Determine threshold source for direction changes
    float src_min = na(switch_src) ? low : switch_src
    float src_max = na(switch_src) ? high : switch_src

    // ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // DIRECTION FLIP DETECTION (moved before width calc)
    // ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // See leg 2 of the NON-REPAINTING CONTRACT. Bands (`self.lower_band` / `self.upper_band`) are read BEFORE
    // reassignment — they hold the prior bar's committed values. For `on_close`/`estimator`, `switch_src` is also from
    // the previous bar (`close[1]`/`estimator[1]`), so the flip fires one bar AFTER the breach — matching confirmed-bar
    // trading semantics. For `high_low`, `src_min`/`src_max` resolve to current `low`/`high` (immediate).
    //
    // Doing the flip first lets every monotonic constraint below be gated on `direction_just_changed`, so
    // prior-direction state cannot leak into the new trend's first bar.
    previous_direction = self.direction
    if self.direction == eDirection.bull and src_min < self.lower_band
        self.direction := eDirection.bear
    else if self.direction == eDirection.bear and src_max > self.upper_band
        self.direction := eDirection.bull
    bool direction_just_changed = self.direction != previous_direction

    // Calculate band widths directly from the asymmetric volatility profile. Widths follow current volatility, so the
    // envelope is free to expand when kinetic energy rises mid-trend (the "expanding energy envelope"). Monotonic
    // trailing-stop behaviour is enforced at band level below — the active band never loosens — so no separate width
    // clamp is needed here; clamping the width too would only over-tighten the stop into a volatility expansion.
    float lower_width = vol_negative * factor
    float upper_width = vol_positive * factor

    // Calculate new band positions. Bands are anchored to the estimator (band_anchor) regardless of switch method, so a
    // sensitive switch source (e.g. high/low) does not drag the envelope around with the wicks. The estimator gives a
    // smooth, consistent reference; the switch method controls only when crossings count.
    float new_lower_band = band_anchor - lower_width
    float new_upper_band = band_anchor + upper_width

    // Update bands with monotonic constraint. Skip on the flip bar: the prior self.lower_band was the BEAR-mode opposing
    // band (set without constraint to band_anchor − lower_width, often close to anchor). Carrying it through math.max
    // would pin the new BULL active band tight to the anchor and make it widen only as the estimator rises past the stuck
    // level. Symmetric reasoning for BEAR.
    // Guard an na new band before the monotonic clamp: if the estimator anchor emits na mid-trend, math.max(x, na) = na would
    // null the active stop for one bar, then next bar nz() would reseed it at the raw new band without the historical max — a
    // transient one-bar loosening of a live stop. Holding the prior committed band through an na carry avoids that drop.
    if not na(new_lower_band)
        if self.direction == eDirection.bull and not direction_just_changed
            self.lower_band := math.max(nz(self.lower_band, new_lower_band), new_lower_band)
        else
            self.lower_band := new_lower_band

    if not na(new_upper_band)
        if self.direction == eDirection.bear and not direction_just_changed
            self.upper_band := math.min(nz(self.upper_band, new_upper_band), new_upper_band)
        else
            self.upper_band := new_upper_band

    self

//───────────────────────── state initialisation ───────────────────//

var KineticTrendState kte_state = KineticTrendState.new(
    direction=eDirection.bull,
    lower_band=na,
    upper_band=na
)

var VolatilityProfile vol_profile = VolatilityProfile.new(
    arr_positive=array.new<float>(0),
    arr_negative=array.new<float>(0),
    arr_direction=array.new<int>(0),
    n_pos=10000,
    n_neg=10000
)

//─────────────────── calculate kinetic trend envelope ─────────────//

// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// SWITCH-METHOD SEMANTICS (critical for downstream strategy authors)
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// The chosen i_switch_method controls *when* a direction flip fires and how the switch aligns with trading behaviour.
// It does NOT affect band location (bands are anchored to the estimator — see leg 3 of NON-REPAINTING CONTRACT inside
// `calculate`).
//
//   • high_low (switch_src = na → low/high): Uses the current bar's high/low, which are MONOTONIC on the live bar.
//     Once a flip fires intra-bar it stays fired. Behaviour is IDENTICAL to a resting stop/limit order at the band
//     level. The direction switch is visualised on the SAME bar as the breach — matching immediate-fill semantics.
//     RENDERING: the thick active line connects back to the prior bar (see the Active Overlays plot comment), so the new
//     colour appears to BEGIN one bar before the breaching candle. Cosmetic only — the flip, alert and stream all update
//     on the breach bar. The two next-bar modes below do not show this because their back-drawn segment lands on the
//     breach bar itself.
//
//   • on_close (switch_src = close[1]): Compares the PREVIOUS bar's committed close against the previous bar's
//     committed band. The direction switch is visualised on the bar AFTER the breach — matching confirmed-bar trading:
//     the breach is confirmed at bar close, the trader acts at the next bar's open. Because both sides of the
//     comparison are committed values, direction is STABLE throughout the live bar (no flicker).
//
//   • estimator (switch_src = estimator[1]): Same as on_close but uses the smoothed estimator. Direction is STABLE
//     on the live bar.
//
// All three modes are non-flickering on the live bar, eliminating the need for `barstate.isconfirmed` gating on
// direction changes in downstream consumers.
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

// Determine switch source based on method. `on_close` and `estimator` use the [1] (previous bar's committed value) so
// the direction switch appears on the bar AFTER the breach — matching confirmed-bar trading semantics. `high_low` uses
// the current bar's high/low (immediate, like a resting stop/limit order).
float switch_source = switch i_switch_method
    eSwitchMethod.high_low  => float(na)
    eSwitchMethod.on_close  => close[1]
    eSwitchMethod.estimator => estimator[1]

// Update state. Note `estimator` is passed as `band_anchor` — bands always track the smoothed
// estimator, decoupled from the switch method's sensitivity choice.
kte_state.calculate(vol_profile, active_volatility, i_volatility_factor, adaptation_lookback, estimator, switch_source)

// Extract values for plotting
kte_direction = kte_state.direction
float  kte_lower         = kte_state.lower_band
float  kte_upper         = kte_state.upper_band

//#endregion


//==================================================================//
//#region                       PLOTTING                            //
//==================================================================//

//──────────────────────────── colours ─────────────────────────────//

var p = cu.Palette.new(transparency=0)
if barstate.isfirst
    p.apply_default_palette(i_palette_name)

const color col_transp = color.new(#000000, 100)

// Regular KTE Colors
color c_bull = p.get_colour(6, i_kte_line_transp)
color c_bear = p.get_colour(1, i_kte_line_transp)
color c_bull2 = p.get_colour(5, i_kte_line_transp)  // more mellow colour
color c_bear2 = p.get_colour(2, i_kte_line_transp)
int kte_fill_t = i_dark_mode ? math.max(i_kte_fill_transp - 8, 0) : i_kte_fill_transp
color c_bull_fill_base = p.get_colour(6, kte_fill_t)
color c_bear_fill_base = p.get_colour(1, kte_fill_t)
// Adjust fill colours for dark/light mode — dark deepens towards black, light mutes towards grey
float kte_desat = i_dark_mode ? 0.1 : 0.2
float kte_t_adj = i_dark_mode ? 0.0 : 0.1
color c_bull_fill = cu.adjust_colour(c_bull_fill_base, desaturation_amount=kte_desat, transparency_amount=kte_t_adj, dark_mode=i_dark_mode)
color c_bear_fill = cu.adjust_colour(c_bear_fill_base, desaturation_amount=kte_desat, transparency_amount=kte_t_adj, dark_mode=i_dark_mode)

// Opposing Band Colors — dark mode reduces transparency to keep opposing band visible against dark backgrounds
int opp_line_t = i_dark_mode ? math.max(i_opposing_line_transp - 25, 0) : i_opposing_line_transp
color c_opp_bull_line = p.get_colour(6, opp_line_t)
color c_opp_bear_line = p.get_colour(1, opp_line_t)
int opp_fill_t = i_dark_mode ? math.max(i_opposing_fill_transp - 6, 0) : i_opposing_fill_transp
color c_opp_bull_fill_base = p.get_colour(6, opp_fill_t)
color c_opp_bear_fill_base = p.get_colour(1, opp_fill_t)
float opp_desat = i_dark_mode ? 0.05 : 0.2
float opp_t_adj = i_dark_mode ? 0.0 : 0.1
color c_opp_bull_fill = cu.adjust_colour(c_opp_bull_fill_base, desaturation_amount=opp_desat, transparency_amount=opp_t_adj, dark_mode=i_dark_mode)
color c_opp_bear_fill = cu.adjust_colour(c_opp_bear_fill_base, desaturation_amount=opp_desat, transparency_amount=opp_t_adj, dark_mode=i_dark_mode)
// Estimator tracks the active envelope colour so all KTE lines share the same direction signal
color c_est_bull      = i_show_estimator ? p.get_colour(4, i_est_line_transp) : col_transp
color c_est_bear      = i_show_estimator ? p.get_colour(3, i_est_line_transp) : col_transp
color c_estimator     = kte_direction == eDirection.bull ? c_est_bull : c_est_bear

//────────────────────────── estimator plot ────────────────────────//

p_estimator = plot(estimator, 'Estimator', color=c_estimator, linewidth=i_est_width, force_overlay=true)

//────────────────────── continuous envelope plots ─────────────────//

// We plot Upper and Lower bands continuously to create a seamless envelope. To handle variable linewidths (thick for
// active, thin for opposing), we use a layering technique:
// 1. Base plots (always visible, thin) handle the continuous connection and opposing style.
// 2. Active plots (conditional, thick) overlay the base plots when the band is active.

// Determine dynamic colors for the base plots
// Upper Band: Red (Active Bear) or Cyan (Opposing Bull)
color col_upper_base = kte_direction == eDirection.bear ? c_bear : c_opp_bull_line
// Lower Band: Cyan (Active Bull) or Red (Opposing Bear)
color col_lower_base = kte_direction == eDirection.bull ? c_bull : c_opp_bear_line

// Handle visibility: if show_opposing is false, hide the base plot when it's in opposing mode
color col_upper_final = (i_show_opposing or kte_direction == eDirection.bear) ? col_upper_base : na
color col_lower_final = (i_show_opposing or kte_direction == eDirection.bull) ? col_lower_base : na

// Plot Base Lines (Continuous, thin)
p_upper = plot(kte_upper, 'Upper Band', color=col_upper_final, linewidth=i_opposing_linewidth, style=plot.style_linebr, force_overlay=true)
p_lower = plot(kte_lower, 'Lower Band', color=col_lower_final, linewidth=i_opposing_linewidth, style=plot.style_linebr, force_overlay=true)

// Plot Active Overlays (Conditional, thick). We use conditional colours instead of conditional values (na) to ensure the
// connecting line segment during a trend switch is drawn with the correct thickness (fixing the 1-bar lag visual artifact).
// Side effect: this segment takes the new direction's colour back to the prior bar, so in high_low mode (same-bar flip)
// the colour appears to begin one bar before the breaching candle. Cosmetic — flip/alert/stream are same-bar. See the
// SWITCH-METHOD SEMANTICS note.
color c_active_upper = kte_direction == eDirection.bear ? c_bear : na
color c_active_lower = kte_direction == eDirection.bull ? c_bull : na

p_upper_active = plot(kte_upper, 'Active Upper', color=c_active_upper, linewidth=i_kte_linewidth, style=plot.style_linebr, force_overlay=true)
p_lower_active = plot(kte_lower, 'Active Lower', color=c_active_lower, linewidth=i_kte_linewidth, style=plot.style_linebr, force_overlay=true)

// Fill the channel
// We use a conditional color to switch between bull/bear channel fills
color c_channel_lower_fill = kte_direction == eDirection.bull ? c_bull_fill : (i_show_opposing ? c_opp_bull_fill : na)
color c_channel_upper_fill = kte_direction == eDirection.bear ? c_bear_fill : (i_show_opposing ? c_opp_bear_fill : na)
// Only fill if opposing band is shown, otherwise it looks weird to have a fill with no border
fill(p_lower, p_estimator, c_channel_lower_fill, 'Channel (lower) fill')
fill(p_upper, p_estimator, c_channel_upper_fill, 'Channel (upper) fill')

//#endregion

if barstate.islast
    validator.display_warnings()


//==================================================================//
//#region                        ALERTS                             //
//==================================================================//

bool trigger_bullish      = bar_index >= 1 and kte_direction == eDirection.bull and kte_direction[1] == eDirection.bear
bool trigger_bearish      = bar_index >= 1 and kte_direction == eDirection.bear and kte_direction[1] == eDirection.bull
bool trigger_state_change = trigger_bullish or trigger_bearish

string msg_bullish = str.format("GYTS: {0} ({1}) KTE → BULLISH (Price: {2})", syminfo.ticker, timeframe.period, close)
string msg_bearish = str.format("GYTS: {0} ({1}) KTE → BEARISH (Price: {2})", syminfo.ticker, timeframe.period, close)

// freq_once_per_bar (not _close): the flip is already committed when trigger_* turns true — direction is stable on the
// live bar in every switch mode (on_close/estimator compare committed [1] values; high_low uses monotonic high/low), so
// the alert cannot repaint. Firing on the first qualifying tick rather than at bar close matches the documented timing —
// immediate for high_low, the new bar's open for on_close/estimator. _close would hold the alert back by up to a full bar.
if i_use_alerts_bull and trigger_bullish
    alert(msg_bullish, alert.freq_once_per_bar)

if i_use_alerts_bear and trigger_bearish
    alert(msg_bearish, alert.freq_once_per_bar)

alertcondition(trigger_bullish,      'Direction → Bullish',  'GYTS: {{ticker}} ({{interval}}) KTE → BULLISH')
alertcondition(trigger_bearish,      'Direction → Bearish',  'GYTS: {{ticker}} ({{interval}}) KTE → BEARISH')
alertcondition(trigger_state_change, "Any Direction Change", "GYTS: {{ticker}} ({{interval}}) KTE Direction Changed")

//#endregion


//==================================================================//
//#region                       EXPORTS                             //
//==================================================================//

// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// EXPORTS — public API for downstream consumers
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
// The visible chart plots and the hidden stream below form this indicator's public API. The full downstream wire-up
// guide — consumption patterns, order-type mapping, direction-flip gating and cross-timeframe reads — lives in the Pro
// edition.
//
// ── INVENTORY ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
//   Plot title (source dropdown)                   Type   Meaning
//   ─────────────────────────────────────────────   ─────  ──────────────────────────────────────────────────────────────────
//   "Upper Band"                                    float  Upper envelope band (post-monotonic-lock). Active trailing stop in bear trends; opposing
//                                                          target in bull trends. Visible on chart; available as input.source() wire.
//   "Lower Band"                                    float  Lower envelope band (post-monotonic-lock). Active trailing stop in bull trends; opposing
//                                                          target in bear trends. Visible on chart; available as input.source() wire.
//   "Estimator"                                     float  Smoothed price estimator anchoring the envelope centre. Visible on chart; available as input.source().
//   "🔗 STREAM KTE 🪜 Trailing Stoploss"           float  Sign-encoded combined stream: +kte_lower (bull) / −kte_upper (bear). One wire carrying direction ×
//                                                          active band. Assumes a strictly positive active band. Shown in the Data Window (display.data_window).
//   "🔗 STREAM KTE 🪜 Mechanism"                   float  Packed companion: switch method (1 high/low, 2 on close, 3 on estimator) in the 1e7 digit
//                                                          + estimator as a ratio-to-active-band in the low digits, behind an 8e12 marker. Hidden (display.none).
//
// The "Active Upper" / "Active Lower" overlay plots carry identical values to "Upper Band" / "Lower Band" — they exist
// solely for variable-linewidth rendering. Wiring to either is equivalent; prefer the base names.
//
// ── REPAINTING ────────────────────────────────────────────────────────────────────────────────────────────────────────────
//
// Closed bars: all exports are committed and reproducible — reloading the script or pulling history later yields
// identical values. Live bar: the band values (Upper/Lower) drift smoothly per tick like any reactive Pine indicator,
// but direction is STABLE for all three switch methods (`on_close`/`estimator` compare committed [1] values; `high_low`
// uses monotonic high/low), so the stream sign does not flicker. This is NOT post-hoc repainting — closed history is
// fixed. For an active trailing stop the live drift is bounded conservatively: the monotonic lock only tightens the
// active band intra-bar, never loosens it below its committed level. See the NON-REPAINTING CONTRACT and SWITCH-METHOD
// SEMANTICS notes above for the mechanism.
// ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

// WARM-UP: band and trailing-stop exports read `na` until the volatility and estimator filters have warmed up (scales
// with Adaptation Speed → 2–5000 bars, Volatility Lookback, Estimator Lookback). Guard downstream reads, e.g.
// `if not na(kte_lower) and not na(kte_upper)`. The Mechanism stream stays present throughout (ratio 0 until ready).
//
// Combined stream: sign carries direction, magnitude carries the active band level: +kte_lower (bull) / −kte_upper (bear).
// Note that large Volatility Factor can push  envelope's  lower band below zero
float kte_trailing_stoploss = kte_direction == eDirection.bull ? kte_lower : -kte_upper
plot(kte_trailing_stoploss, "🔗 STREAM KTE 🪜 Trailing Stoploss", editable=false, display=display.data_window)

// Stream to be used by downstream GYTS indicators. E.g. lets a strategy (e.g. Order Orchestrator) adopt this KTE's Direction Switch
// Method and draw its estimator runner line automatically, with no duplicated setting. One hidden float packed like the
// WT4D/Flux streams but behind a distinct 8e12 marker: the 1e7 digit holds the method (1 on high/low,
// 2 on close, 3 on estimator) and the low 7 digits hold the estimator as a SCALE-INVARIANT ratio to the active band
// (round(estimator / active_band × 1e6)), so it reconstructs at any price scale. The absolute stop keeps its own
// full-precision wire above — two prices cannot share one float. The method is present even during warm-up (ratio 0
// until the estimator is ready).
int   mech_method_code = switch i_switch_method
    eSwitchMethod.high_low  => 1
    eSwitchMethod.on_close  => 2
    eSwitchMethod.estimator => 3
float mech_active_band = kte_direction == eDirection.bull ? kte_lower : kte_upper
float mech_est_ratio   = not na(estimator) and not na(mech_active_band) and mech_active_band > 0 ? estimator / mech_active_band : na
int   mech_ratio_code  = na(mech_est_ratio) ? 0 : int(math.min(math.max(math.round(mech_est_ratio * 1e6), 0), 9999999))
float kte_mechanism    = 8e12 + mech_method_code * 1e7 + mech_ratio_code
plot(kte_mechanism, "🔗 STREAM KTE 🪜 Mechanism", editable=false, display=display.none)

//#endregion
````
