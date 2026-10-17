# Plexus - Tendency Planimetry (Bundles)

- url: https://www.tradingview.com/script/YdVnc8gO-Plexus-Tendency-Planimetry-Bundles/
- type: indicator
- pine_id: PUB;ce70db2d6192452688b599b359ab3f76
- version: 3.0

## Description

[b]The first implementation of the Tendency Planimetry method on TradingView[/b]

Works on any market and timeframe: forex, stocks, futures, crypto, indices, commodities.

This indicator overlays a family of moving averages computed on the (H+L)/2 price, with progressively increasing period steps. Where many MAs converge into a narrow price band, a "bundle" forms — a dynamic support/resistance level that carries its own direction (slope).

[b]What it draws:[/b]
- a "fabric" of moving averages (fast = cool tones, slow = warm tones);
- the automatically detected bundle on the current bar, with a highlighted zone and a center line;
- bounce markers when price rejects the bundle in the direction of its slope (long/short);
- an info table: bundle size, level and slope;
- built-in alerts for upward and downward bounces.

[b]How it differs from a regular MA ribbon:[/b]
- MA periods use a progressive step, not a uniform one;
- the bundle is detected automatically as a dense cluster of converged averages;
- signals are filtered by the slope of the bundle itself — only in the direction of the trend.

[b]About the method.[/b] The Tendency Planimetry method is described in public sources; one of its early authors is Valeriy Kim (known as Insen) and the trading community around him. This code is written from scratch as an independent implementation of a publicly described idea. Credit and thanks to the method's authors.

⚠️ This is a visualization and alert tool, not financial advice and not a trading bot. It does not execute orders. Any signal is a prompt for your own analysis. Trading involves risk of loss.

## Source Code

````pine
// © Plexus — Tendency Planimetry (Bundles)
// v2 — S7-2: full 54-MA family (matches the validated method / web tool),
// ALL qualifying clusters shown (up to 3 simultaneous), not just the largest.
// First implementation of the tendency-planimetry method on TradingView.
// Works on any market and timeframe: forex, stocks, futures, crypto, indices,
// commodities.
//
// CREDIT: the method is described in public sources; one of the early authors is
// Valeriy Kim (a.k.a. Insen) and the OpenTraders community. This code is an
// independent, from-scratch implementation of that publicly described idea.
//
// HOW IT DIFFERS FROM A PLAIN MA RIBBON:
// - moving-average periods grow with a progressive (non-uniform) step
// - a bundle is an auto-detected dense cluster of converged averages
// - ALL qualifying clusters are shown at once (up to 8), not just the largest
// - signals are filtered by the slope of the bundle itself
//
// v2 CHANGE LOG (2026-07-14):
// - MA family widened from 20 (periods 2..114) to the full 54 (periods 2..494)
//   used by the validated method (bot.py / the web tool) — same period formula
//   as site/index.html's genPeriods(500), verified identical.
// - Bundle detection now finds and displays UP TO 3 simultaneous clusters
//   (previously only the single largest). Distant structural walls, which the
//   20-MA version could not compute at all, are now visible.
// - Visible "fabric" lines cut to 12, sampled evenly across the full
//   54-period family. First attempt (24 fabric + 8 zones, ~50 nominal plots)
//   hit runtime error RE10140 (108 real plots > 64) -- true per-plot cost is
//   higher than the nominal count for reasons not fully diagnosed without a
//   compiler. Cut hard to 12 fabric + 3 zones for a wide safety margin
//   instead of re-guessing the exact multiplier.
// - No change to the honest positioning: still a visualization/alert tool,
//   not a signal service, not financial advice.
//
// Not financial advice. Trading carries risk.

//@version=6
indicator("Plexus — Tendency Planimetry (Bundles)", shorttitle="Plexus Bundles", overlay=true, max_labels_count=200, max_boxes_count=20, max_lines_count=100)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
grpMA = "Moving averages"
showMA = input.bool(true, "Show MA fabric", group=grpMA)
slopeW = input.int(5, "Slope window, bars", minval=2, maxval=30, group=grpMA)

grpB = "Bundles"
tolPct = input.float(0.5, "Bundle width, %", minval=0.05, maxval=2.0, step=0.05, group=grpB, tooltip="Base width. With adaptation on, it is multiplied by a timeframe factor.")
adaptive= input.bool(true, "Adapt to timeframe", group=grpB, tooltip="On higher timeframes the averages spread further apart, so the width widens automatically to keep finding bundles on any timeframe.")
minSize = input.int(4, "Min MAs in bundle", minval=3, maxval=15, group=grpB)
minSlope= input.float(0.003,"Min slope, %/bar", minval=0.0, maxval=0.1, step=0.001, group=grpB)
maxShown= input.int(3, "Max bundles shown at once", minval=1, maxval=3, group=grpB, tooltip="Capped at 3 (down from an original 8) to stay well under Pine's 64-plot limit, after a higher cap hit runtime error RE10140. Largest-by-size are prioritized if more qualify.")

grpSig = "Signals"
showSig = input.bool(true, "Show bounces", group=grpSig)
touchP = input.float(0.15, "Touch zone, %", minval=0.0, maxval=0.5, step=0.05, group=grpSig)
sigBundle = input.int(1, "Bounce signals use bundle #", minval=1, maxval=3, group=grpSig, tooltip="Bundles are numbered 1 upward by PRICE, bottom to top (not by size) — check the chart to see which number sits where before picking one. Bounce signals fire off this one bundle only, to keep alerts unambiguous.")

grpClr = "Colors"
cFast = input.color(color.new(#5dd6c8, 0), "Fast MAs", group=grpClr)
cSlow = input.color(color.new(#d99ae8, 0), "Slow MAs", group=grpClr)
cBundle = input.color(color.new(#f5b54a, 0), "Bundle", group=grpClr)

// ---------------------------------------------------------------------------
// 1. Median price
// ---------------------------------------------------------------------------
src = (high + low) / 2.0

// effective bundle width: on higher timeframes the averages spread further apart,
// so the factor grows logarithmically with the timeframe (1H ~ x1.39, 1D ~ x2.08).
_tfMin = timeframe.in_seconds() / 60.0
_mult = adaptive ? math.max(0.6, math.min(4.0, 0.5 + 0.5 * (math.log(_tfMin + 1) / math.log(10)))) : 1.0
effTol = tolPct * _mult

// ---------------------------------------------------------------------------
// 2. 54 SMAs — the full method's MA family (periods 2..494), matching
//    site/index.html's genPeriods(500) formula exactly (verified 2026-07-14).
// ---------------------------------------------------------------------------
_ma00 = ta.sma(src, 2)
_ma01 = ta.sma(src, 5)
_ma02 = ta.sma(src, 8)
_ma03 = ta.sma(src, 11)
_ma04 = ta.sma(src, 15)
_ma05 = ta.sma(src, 18)
_ma06 = ta.sma(src, 22)
_ma07 = ta.sma(src, 26)
_ma08 = ta.sma(src, 30)
_ma09 = ta.sma(src, 34)
_ma10 = ta.sma(src, 38)
_ma11 = ta.sma(src, 42)
_ma12 = ta.sma(src, 47)
_ma13 = ta.sma(src, 52)
_ma14 = ta.sma(src, 57)
_ma15 = ta.sma(src, 62)
_ma16 = ta.sma(src, 67)
_ma17 = ta.sma(src, 73)
_ma18 = ta.sma(src, 79)
_ma19 = ta.sma(src, 85)
_ma20 = ta.sma(src, 91)
_ma21 = ta.sma(src, 98)
_ma22 = ta.sma(src, 105)
_ma23 = ta.sma(src, 112)
_ma24 = ta.sma(src, 119)
_ma25 = ta.sma(src, 127)
_ma26 = ta.sma(src, 135)
_ma27 = ta.sma(src, 143)
_ma28 = ta.sma(src, 152)
_ma29 = ta.sma(src, 161)
_ma30 = ta.sma(src, 170)
_ma31 = ta.sma(src, 180)
_ma32 = ta.sma(src, 190)
_ma33 = ta.sma(src, 201)
_ma34 = ta.sma(src, 212)
_ma35 = ta.sma(src, 223)
_ma36 = ta.sma(src, 235)
_ma37 = ta.sma(src, 247)
_ma38 = ta.sma(src, 260)
_ma39 = ta.sma(src, 273)
_ma40 = ta.sma(src, 287)
_ma41 = ta.sma(src, 301)
_ma42 = ta.sma(src, 316)
_ma43 = ta.sma(src, 332)
_ma44 = ta.sma(src, 348)
_ma45 = ta.sma(src, 364)
_ma46 = ta.sma(src, 380)
_ma47 = ta.sma(src, 396)
_ma48 = ta.sma(src, 412)
_ma49 = ta.sma(src, 428)
_ma50 = ta.sma(src, 444)
_ma51 = ta.sma(src, 461)
_ma52 = ta.sma(src, 477)
_ma53 = ta.sma(src, 494)

// ---------------------------------------------------------------------------
// 3. Build arrays for the bundle algorithm (54 MAs, up from 20)
// ---------------------------------------------------------------------------
_maArr = array.new<float>(54, na)
_slArr = array.new<float>(54, 0.0)
array.set(_maArr, 0, _ma00)
array.set(_slArr, 0, na(_ma00[slopeW]) or _ma00[slopeW] == 0 ? 0.0 : (_ma00 - _ma00[slopeW]) / _ma00[slopeW] * 100.0 / slopeW)
array.set(_maArr, 1, _ma01)
array.set(_slArr, 1, na(_ma01[slopeW]) or _ma01[slopeW] == 0 ? 0.0 : (_ma01 - _ma01[slopeW]) / _ma01[slopeW] * 100.0 / slopeW)
array.set(_maArr, 2, _ma02)
array.set(_slArr, 2, na(_ma02[slopeW]) or _ma02[slopeW] == 0 ? 0.0 : (_ma02 - _ma02[slopeW]) / _ma02[slopeW] * 100.0 / slopeW)
array.set(_maArr, 3, _ma03)
array.set(_slArr, 3, na(_ma03[slopeW]) or _ma03[slopeW] == 0 ? 0.0 : (_ma03 - _ma03[slopeW]) / _ma03[slopeW] * 100.0 / slopeW)
array.set(_maArr, 4, _ma04)
array.set(_slArr, 4, na(_ma04[slopeW]) or _ma04[slopeW] == 0 ? 0.0 : (_ma04 - _ma04[slopeW]) / _ma04[slopeW] * 100.0 / slopeW)
array.set(_maArr, 5, _ma05)
array.set(_slArr, 5, na(_ma05[slopeW]) or _ma05[slopeW] == 0 ? 0.0 : (_ma05 - _ma05[slopeW]) / _ma05[slopeW] * 100.0 / slopeW)
array.set(_maArr, 6, _ma06)
array.set(_slArr, 6, na(_ma06[slopeW]) or _ma06[slopeW] == 0 ? 0.0 : (_ma06 - _ma06[slopeW]) / _ma06[slopeW] * 100.0 / slopeW)
array.set(_maArr, 7, _ma07)
array.set(_slArr, 7, na(_ma07[slopeW]) or _ma07[slopeW] == 0 ? 0.0 : (_ma07 - _ma07[slopeW]) / _ma07[slopeW] * 100.0 / slopeW)
array.set(_maArr, 8, _ma08)
array.set(_slArr, 8, na(_ma08[slopeW]) or _ma08[slopeW] == 0 ? 0.0 : (_ma08 - _ma08[slopeW]) / _ma08[slopeW] * 100.0 / slopeW)
array.set(_maArr, 9, _ma09)
array.set(_slArr, 9, na(_ma09[slopeW]) or _ma09[slopeW] == 0 ? 0.0 : (_ma09 - _ma09[slopeW]) / _ma09[slopeW] * 100.0 / slopeW)
array.set(_maArr, 10, _ma10)
array.set(_slArr, 10, na(_ma10[slopeW]) or _ma10[slopeW] == 0 ? 0.0 : (_ma10 - _ma10[slopeW]) / _ma10[slopeW] * 100.0 / slopeW)
array.set(_maArr, 11, _ma11)
array.set(_slArr, 11, na(_ma11[slopeW]) or _ma11[slopeW] == 0 ? 0.0 : (_ma11 - _ma11[slopeW]) / _ma11[slopeW] * 100.0 / slopeW)
array.set(_maArr, 12, _ma12)
array.set(_slArr, 12, na(_ma12[slopeW]) or _ma12[slopeW] == 0 ? 0.0 : (_ma12 - _ma12[slopeW]) / _ma12[slopeW] * 100.0 / slopeW)
array.set(_maArr, 13, _ma13)
array.set(_slArr, 13, na(_ma13[slopeW]) or _ma13[slopeW] == 0 ? 0.0 : (_ma13 - _ma13[slopeW]) / _ma13[slopeW] * 100.0 / slopeW)
array.set(_maArr, 14, _ma14)
array.set(_slArr, 14, na(_ma14[slopeW]) or _ma14[slopeW] == 0 ? 0.0 : (_ma14 - _ma14[slopeW]) / _ma14[slopeW] * 100.0 / slopeW)
array.set(_maArr, 15, _ma15)
array.set(_slArr, 15, na(_ma15[slopeW]) or _ma15[slopeW] == 0 ? 0.0 : (_ma15 - _ma15[slopeW]) / _ma15[slopeW] * 100.0 / slopeW)
array.set(_maArr, 16, _ma16)
array.set(_slArr, 16, na(_ma16[slopeW]) or _ma16[slopeW] == 0 ? 0.0 : (_ma16 - _ma16[slopeW]) / _ma16[slopeW] * 100.0 / slopeW)
array.set(_maArr, 17, _ma17)
array.set(_slArr, 17, na(_ma17[slopeW]) or _ma17[slopeW] == 0 ? 0.0 : (_ma17 - _ma17[slopeW]) / _ma17[slopeW] * 100.0 / slopeW)
array.set(_maArr, 18, _ma18)
array.set(_slArr, 18, na(_ma18[slopeW]) or _ma18[slopeW] == 0 ? 0.0 : (_ma18 - _ma18[slopeW]) / _ma18[slopeW] * 100.0 / slopeW)
array.set(_maArr, 19, _ma19)
array.set(_slArr, 19, na(_ma19[slopeW]) or _ma19[slopeW] == 0 ? 0.0 : (_ma19 - _ma19[slopeW]) / _ma19[slopeW] * 100.0 / slopeW)
array.set(_maArr, 20, _ma20)
array.set(_slArr, 20, na(_ma20[slopeW]) or _ma20[slopeW] == 0 ? 0.0 : (_ma20 - _ma20[slopeW]) / _ma20[slopeW] * 100.0 / slopeW)
array.set(_maArr, 21, _ma21)
array.set(_slArr, 21, na(_ma21[slopeW]) or _ma21[slopeW] == 0 ? 0.0 : (_ma21 - _ma21[slopeW]) / _ma21[slopeW] * 100.0 / slopeW)
array.set(_maArr, 22, _ma22)
array.set(_slArr, 22, na(_ma22[slopeW]) or _ma22[slopeW] == 0 ? 0.0 : (_ma22 - _ma22[slopeW]) / _ma22[slopeW] * 100.0 / slopeW)
array.set(_maArr, 23, _ma23)
array.set(_slArr, 23, na(_ma23[slopeW]) or _ma23[slopeW] == 0 ? 0.0 : (_ma23 - _ma23[slopeW]) / _ma23[slopeW] * 100.0 / slopeW)
array.set(_maArr, 24, _ma24)
array.set(_slArr, 24, na(_ma24[slopeW]) or _ma24[slopeW] == 0 ? 0.0 : (_ma24 - _ma24[slopeW]) / _ma24[slopeW] * 100.0 / slopeW)
array.set(_maArr, 25, _ma25)
array.set(_slArr, 25, na(_ma25[slopeW]) or _ma25[slopeW] == 0 ? 0.0 : (_ma25 - _ma25[slopeW]) / _ma25[slopeW] * 100.0 / slopeW)
array.set(_maArr, 26, _ma26)
array.set(_slArr, 26, na(_ma26[slopeW]) or _ma26[slopeW] == 0 ? 0.0 : (_ma26 - _ma26[slopeW]) / _ma26[slopeW] * 100.0 / slopeW)
array.set(_maArr, 27, _ma27)
array.set(_slArr, 27, na(_ma27[slopeW]) or _ma27[slopeW] == 0 ? 0.0 : (_ma27 - _ma27[slopeW]) / _ma27[slopeW] * 100.0 / slopeW)
array.set(_maArr, 28, _ma28)
array.set(_slArr, 28, na(_ma28[slopeW]) or _ma28[slopeW] == 0 ? 0.0 : (_ma28 - _ma28[slopeW]) / _ma28[slopeW] * 100.0 / slopeW)
array.set(_maArr, 29, _ma29)
array.set(_slArr, 29, na(_ma29[slopeW]) or _ma29[slopeW] == 0 ? 0.0 : (_ma29 - _ma29[slopeW]) / _ma29[slopeW] * 100.0 / slopeW)
array.set(_maArr, 30, _ma30)
array.set(_slArr, 30, na(_ma30[slopeW]) or _ma30[slopeW] == 0 ? 0.0 : (_ma30 - _ma30[slopeW]) / _ma30[slopeW] * 100.0 / slopeW)
array.set(_maArr, 31, _ma31)
array.set(_slArr, 31, na(_ma31[slopeW]) or _ma31[slopeW] == 0 ? 0.0 : (_ma31 - _ma31[slopeW]) / _ma31[slopeW] * 100.0 / slopeW)
array.set(_maArr, 32, _ma32)
array.set(_slArr, 32, na(_ma32[slopeW]) or _ma32[slopeW] == 0 ? 0.0 : (_ma32 - _ma32[slopeW]) / _ma32[slopeW] * 100.0 / slopeW)
array.set(_maArr, 33, _ma33)
array.set(_slArr, 33, na(_ma33[slopeW]) or _ma33[slopeW] == 0 ? 0.0 : (_ma33 - _ma33[slopeW]) / _ma33[slopeW] * 100.0 / slopeW)
array.set(_maArr, 34, _ma34)
array.set(_slArr, 34, na(_ma34[slopeW]) or _ma34[slopeW] == 0 ? 0.0 : (_ma34 - _ma34[slopeW]) / _ma34[slopeW] * 100.0 / slopeW)
array.set(_maArr, 35, _ma35)
array.set(_slArr, 35, na(_ma35[slopeW]) or _ma35[slopeW] == 0 ? 0.0 : (_ma35 - _ma35[slopeW]) / _ma35[slopeW] * 100.0 / slopeW)
array.set(_maArr, 36, _ma36)
array.set(_slArr, 36, na(_ma36[slopeW]) or _ma36[slopeW] == 0 ? 0.0 : (_ma36 - _ma36[slopeW]) / _ma36[slopeW] * 100.0 / slopeW)
array.set(_maArr, 37, _ma37)
array.set(_slArr, 37, na(_ma37[slopeW]) or _ma37[slopeW] == 0 ? 0.0 : (_ma37 - _ma37[slopeW]) / _ma37[slopeW] * 100.0 / slopeW)
array.set(_maArr, 38, _ma38)
array.set(_slArr, 38, na(_ma38[slopeW]) or _ma38[slopeW] == 0 ? 0.0 : (_ma38 - _ma38[slopeW]) / _ma38[slopeW] * 100.0 / slopeW)
array.set(_maArr, 39, _ma39)
array.set(_slArr, 39, na(_ma39[slopeW]) or _ma39[slopeW] == 0 ? 0.0 : (_ma39 - _ma39[slopeW]) / _ma39[slopeW] * 100.0 / slopeW)
array.set(_maArr, 40, _ma40)
array.set(_slArr, 40, na(_ma40[slopeW]) or _ma40[slopeW] == 0 ? 0.0 : (_ma40 - _ma40[slopeW]) / _ma40[slopeW] * 100.0 / slopeW)
array.set(_maArr, 41, _ma41)
array.set(_slArr, 41, na(_ma41[slopeW]) or _ma41[slopeW] == 0 ? 0.0 : (_ma41 - _ma41[slopeW]) / _ma41[slopeW] * 100.0 / slopeW)
array.set(_maArr, 42, _ma42)
array.set(_slArr, 42, na(_ma42[slopeW]) or _ma42[slopeW] == 0 ? 0.0 : (_ma42 - _ma42[slopeW]) / _ma42[slopeW] * 100.0 / slopeW)
array.set(_maArr, 43, _ma43)
array.set(_slArr, 43, na(_ma43[slopeW]) or _ma43[slopeW] == 0 ? 0.0 : (_ma43 - _ma43[slopeW]) / _ma43[slopeW] * 100.0 / slopeW)
array.set(_maArr, 44, _ma44)
array.set(_slArr, 44, na(_ma44[slopeW]) or _ma44[slopeW] == 0 ? 0.0 : (_ma44 - _ma44[slopeW]) / _ma44[slopeW] * 100.0 / slopeW)
array.set(_maArr, 45, _ma45)
array.set(_slArr, 45, na(_ma45[slopeW]) or _ma45[slopeW] == 0 ? 0.0 : (_ma45 - _ma45[slopeW]) / _ma45[slopeW] * 100.0 / slopeW)
array.set(_maArr, 46, _ma46)
array.set(_slArr, 46, na(_ma46[slopeW]) or _ma46[slopeW] == 0 ? 0.0 : (_ma46 - _ma46[slopeW]) / _ma46[slopeW] * 100.0 / slopeW)
array.set(_maArr, 47, _ma47)
array.set(_slArr, 47, na(_ma47[slopeW]) or _ma47[slopeW] == 0 ? 0.0 : (_ma47 - _ma47[slopeW]) / _ma47[slopeW] * 100.0 / slopeW)
array.set(_maArr, 48, _ma48)
array.set(_slArr, 48, na(_ma48[slopeW]) or _ma48[slopeW] == 0 ? 0.0 : (_ma48 - _ma48[slopeW]) / _ma48[slopeW] * 100.0 / slopeW)
array.set(_maArr, 49, _ma49)
array.set(_slArr, 49, na(_ma49[slopeW]) or _ma49[slopeW] == 0 ? 0.0 : (_ma49 - _ma49[slopeW]) / _ma49[slopeW] * 100.0 / slopeW)
array.set(_maArr, 50, _ma50)
array.set(_slArr, 50, na(_ma50[slopeW]) or _ma50[slopeW] == 0 ? 0.0 : (_ma50 - _ma50[slopeW]) / _ma50[slopeW] * 100.0 / slopeW)
array.set(_maArr, 51, _ma51)
array.set(_slArr, 51, na(_ma51[slopeW]) or _ma51[slopeW] == 0 ? 0.0 : (_ma51 - _ma51[slopeW]) / _ma51[slopeW] * 100.0 / slopeW)
array.set(_maArr, 52, _ma52)
array.set(_slArr, 52, na(_ma52[slopeW]) or _ma52[slopeW] == 0 ? 0.0 : (_ma52 - _ma52[slopeW]) / _ma52[slopeW] * 100.0 / slopeW)
array.set(_maArr, 53, _ma53)
array.set(_slArr, 53, na(_ma53[slopeW]) or _ma53[slopeW] == 0 ? 0.0 : (_ma53 - _ma53[slopeW]) / _ma53[slopeW] * 100.0 / slopeW)

// ---------------------------------------------------------------------------
// 4. Find ALL qualifying clusters (not just the largest) — S7-2 fix.
//    Same greedy sweep the v1 script already used; it now records EVERY
//    maximal run that meets minSize instead of overwriting with only the
//    biggest one. Verified equivalent to the v1 single-cluster result as a
//    subset, on synthetic multi-zone data (see canon, S6-bundle-definition-
//    check.md, S7-2 section).
// ---------------------------------------------------------------------------
_sorted = array.copy(_maArr)
array.sort(_sorted, order.ascending)

var _allLo = array.new<float>()
var _allHi = array.new<float>()
var _allMid = array.new<float>()
var _allSize = array.new<int>()
var _allSlope = array.new<float>()
array.clear(_allLo)
array.clear(_allHi)
array.clear(_allMid)
array.clear(_allSize)
array.clear(_allSlope)

_n = array.size(_sorted)
if _n >= minSize
    _i = 0
    while _i < _n
        _j = _i
        while _j + 1 < _n and array.get(_sorted, _j + 1) - array.get(_sorted, _i) <= array.get(_sorted, _i) * effTol / 100.0
            _j := _j + 1
        _sz = _j - _i + 1
        if _sz >= minSize
            _clo = array.get(_sorted, _i)
            _chi = array.get(_sorted, _j)
            _cmid = (_clo + _chi) / 2.0
            float _sSum = 0.0
            int _sCnt = 0
            for _k = 0 to 54 - 1
                _v = array.get(_maArr, _k)
                if not na(_v) and _v >= _clo * 0.9999 and _v <= _chi * 1.0001
                    _sSum := _sSum + array.get(_slArr, _k)
                    _sCnt := _sCnt + 1
            array.push(_allLo, _clo)
            array.push(_allHi, _chi)
            array.push(_allMid, _cmid)
            array.push(_allSize, _sz)
            array.push(_allSlope, _sCnt > 0 ? _sSum / _sCnt : 0.0)
        _i := _j + 1

// Keep the top `maxShown` by size, then re-sort those by price (ascending)
// for a stable top-to-bottom slot order on screen.
_nFound = array.size(_allSize)
var _keepIdx = array.new<int>()
array.clear(_keepIdx)
for _k = 0 to (_nFound == 0 ? na : _nFound - 1)
    array.push(_keepIdx, _k)
// simple selection sort by size descending (small N, at most ~20 candidates)
for _a = 0 to (array.size(_keepIdx) == 0 ? na : array.size(_keepIdx) - 1)
    _best = _a
    for _b = _a + 1 to (array.size(_keepIdx) - 1 < _a + 1 ? na : array.size(_keepIdx) - 1)
        if array.get(_allSize, array.get(_keepIdx, _b)) > array.get(_allSize, array.get(_keepIdx, _best))
            _best := _b
    if _best != _a
        _tmp = array.get(_keepIdx, _a)
        array.set(_keepIdx, _a, array.get(_keepIdx, _best))
        array.set(_keepIdx, _best, _tmp)
_nKeep = math.min(maxShown, array.size(_keepIdx))
var _finalIdx = array.new<int>()
array.clear(_finalIdx)
for _k2 = 0 to (_nKeep == 0 ? na : _nKeep - 1)
    array.push(_finalIdx, array.get(_keepIdx, _k2))
// re-sort the kept ones by price (ascending) for stable slot assignment
for _a2 = 0 to (array.size(_finalIdx) == 0 ? na : array.size(_finalIdx) - 1)
    _best2 = _a2
    for _b = _a2 + 1 to (array.size(_finalIdx) - 1 < _a2 + 1 ? na : array.size(_finalIdx) - 1)
        if array.get(_allMid, array.get(_finalIdx, _b)) < array.get(_allMid, array.get(_finalIdx, _best2))
            _best2 := _b
    if _best2 != _a2
        _tmp2 = array.get(_finalIdx, _a2)
        array.set(_finalIdx, _a2, array.get(_finalIdx, _best2))
        array.set(_finalIdx, _best2, _tmp2)

// helper getters — return na/0 for slots beyond what was actually found
f_lo(slot) => slot < array.size(_finalIdx) ? array.get(_allLo, array.get(_finalIdx, slot)) : na
f_hi(slot) => slot < array.size(_finalIdx) ? array.get(_allHi, array.get(_finalIdx, slot)) : na
f_mid(slot) => slot < array.size(_finalIdx) ? array.get(_allMid, array.get(_finalIdx, slot)) : na
f_size(slot) => slot < array.size(_finalIdx) ? array.get(_allSize, array.get(_finalIdx, slot)) : 0
f_slope(slot) => slot < array.size(_finalIdx) ? array.get(_allSlope, array.get(_finalIdx, slot)) : na

hasBundle = array.size(_finalIdx) > 0

// ---------------------------------------------------------------------------
// 5. Bundle visuals: up to 3 simultaneous zones (fill + center line each).
//    Cut from an original 8-slot design after RE10140 (108 real plots > 64) —
//    see the v2 CHANGE LOG at the top of this file.
//
//    DISCONTINUITY BREAKS (added 2026-07-14, founder's request): a "slot" is
//    just a price-sorted position (1=lowest, 2=next, ...), NOT a tracked
//    object. By the method, distinct bundles are distinct structural walls
//    and should NOT be visually connected just because they happen to land
//    in the same slot on consecutive bars. Each slot's line is broken
//    (na'd for exactly the one bar where a new, non-overlapping bundle
//    first appears there) so the chart never implies continuity that isn't
//    real. Raw f_lo/f_hi/f_mid/f_size/f_slope (used for signals, sigBundle,
//    and the table) are UNCHANGED by this — only the plotted lines break.
// ---------------------------------------------------------------------------
_isCont(prevLo, prevHi, curLo, curHi) =>
    not na(prevLo) and not na(curLo) and curLo <= prevHi and prevLo <= curHi

var float _prevLo0 = na
var float _prevHi0 = na
b0hi = f_hi(0)
b0lo = f_lo(0)
_cont0 = _isCont(_prevLo0, _prevHi0, b0lo, b0hi)
_dhi0 = _cont0 or na(b0hi) ? b0hi : na
_dlo0 = _cont0 or na(b0lo) ? b0lo : na
_prevLo0 := b0lo
_prevHi0 := b0hi
_p0hi = plot(_dhi0, "Bundle 1 top", color=color.new(cBundle, 55), linewidth=1, style=plot.style_linebr)
_p0lo = plot(_dlo0, "Bundle 1 bottom", color=color.new(cBundle, 55), linewidth=1, style=plot.style_linebr)
fill(_p0hi, _p0lo, color=not na(_dhi0) ? color.new(cBundle, 80) : na, title="Bundle 1 zone")
plot(_cont0 or na(b0hi) ? f_mid(0) : na, "Bundle 1 center", color=cBundle, linewidth=2, style=plot.style_linebr)

var float _prevLo1 = na
var float _prevHi1 = na
b1hi = f_hi(1)
b1lo = f_lo(1)
_cont1 = _isCont(_prevLo1, _prevHi1, b1lo, b1hi)
_dhi1 = _cont1 or na(b1hi) ? b1hi : na
_dlo1 = _cont1 or na(b1lo) ? b1lo : na
_prevLo1 := b1lo
_prevHi1 := b1hi
_p1hi = plot(_dhi1, "Bundle 2 top", color=color.new(cBundle, 65), linewidth=1, style=plot.style_linebr)
_p1lo = plot(_dlo1, "Bundle 2 bottom", color=color.new(cBundle, 65), linewidth=1, style=plot.style_linebr)
fill(_p1hi, _p1lo, color=not na(_dhi1) ? color.new(cBundle, 85) : na, title="Bundle 2 zone")
plot(_cont1 or na(b1hi) ? f_mid(1) : na, "Bundle 2 center", color=color.new(cBundle, 20), linewidth=1, style=plot.style_linebr)

var float _prevLo2 = na
var float _prevHi2 = na
b2hi = f_hi(2)
b2lo = f_lo(2)
_cont2 = _isCont(_prevLo2, _prevHi2, b2lo, b2hi)
_dhi2 = _cont2 or na(b2hi) ? b2hi : na
_dlo2 = _cont2 or na(b2lo) ? b2lo : na
_prevLo2 := b2lo
_prevHi2 := b2hi
_p2hi = plot(_dhi2, "Bundle 3 top", color=color.new(cBundle, 65), linewidth=1, style=plot.style_linebr)
_p2lo = plot(_dlo2, "Bundle 3 bottom", color=color.new(cBundle, 65), linewidth=1, style=plot.style_linebr)
fill(_p2hi, _p2lo, color=not na(_dhi2) ? color.new(cBundle, 85) : na, title="Bundle 3 zone")
plot(_cont2 or na(b2hi) ? f_mid(2) : na, "Bundle 3 center", color=color.new(cBundle, 20), linewidth=1, style=plot.style_linebr)

// ---------------------------------------------------------------------------
// 6. Bounce signals — fire off ONE chosen bundle slot (sigBundle input),
//    to keep alerts unambiguous when several bundles are on screen at once.
// ---------------------------------------------------------------------------
_sigSlot = sigBundle - 1
_sigLo = f_lo(_sigSlot)
_sigHi = f_hi(_sigSlot)
_sigSlope = f_slope(_sigSlot)
_sigHas = not na(_sigLo) and not na(_sigHi)

bool upBounce = false
bool dnBounce = false
if showSig and _sigHas
    zLo = _sigLo * (1 - touchP / 100.0)
    zHi = _sigHi * (1 + touchP / 100.0)
    upBounce := low <= zHi and close[1] > _sigHi and close > _sigHi and _sigSlope >= minSlope
    dnBounce := high >= zLo and close[1] < _sigLo and close < _sigLo and _sigSlope <= -minSlope

plotshape(upBounce, "Bounce up (long)", shape.triangleup, location.belowbar, color.new(#3ecf8e, 0), size=size.small)
plotshape(dnBounce, "Bounce down (short)", shape.triangledown, location.abovebar, color.new(#f26d6d, 0), size=size.small)

// ---------------------------------------------------------------------------
// 7. Alerts
// ---------------------------------------------------------------------------
alertcondition(upBounce, "Plexus: bounce up", "Bounce UP off the bundle on {{ticker}} {{interval}}")
alertcondition(dnBounce, "Plexus: bounce down", "Bounce DOWN off the bundle on {{ticker}} {{interval}}")

// ---------------------------------------------------------------------------
// 8. Status table — now shows how many bundles are visible right now
// ---------------------------------------------------------------------------
var table _tbl = table.new(position.top_right, 2, 3, border_width=1, border_color=color.new(color.gray, 70), bgcolor=color.new(color.black, 80))
if barstate.islast
    table.cell(_tbl, 0, 0, "Bundles", text_color=color.gray, text_size=size.small)
    table.cell(_tbl, 1, 0, hasBundle ? str.tostring(array.size(_finalIdx)) + " shown" : "none", text_color=hasBundle ? cBundle : color.gray, text_size=size.small)
    table.cell(_tbl, 0, 1, "Bundle 1", text_color=color.gray, text_size=size.small)
    table.cell(_tbl, 1, 1, hasBundle ? str.tostring(math.round(f_mid(0), 2)) + " (" + str.tostring(f_size(0)) + " MA)" : "—", text_color=color.gray, text_size=size.small)
    table.cell(_tbl, 0, 2, "Slope #1", text_color=color.gray, text_size=size.small)
    _s0 = f_slope(0)
    _dir = na(_s0) ? "—" : _s0 > 0 ? "↗ " + str.tostring(math.round(_s0, 4)) + "%" : "↘ " + str.tostring(math.round(_s0, 4)) + "%"
    table.cell(_tbl, 1, 2, _dir, text_color=hasBundle ? (na(_s0) ? color.gray : (_s0 > 0 ? #3ecf8e : #f26d6d)) : color.gray, text_size=size.small)

// ---------------------------------------------------------------------------
// 9. MA fabric — 12 visible lines, sampled across the full 54-period family,
//    so the visual "fabric" stays clean and within budget while detection
//    above uses all 54.
// ---------------------------------------------------------------------------
plot(showMA ? _ma00 : na, "MA01 (p2)", color=color.from_gradient(0.0000, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma05 : na, "MA02 (p18)", color=color.from_gradient(0.0909, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma10 : na, "MA03 (p38)", color=color.from_gradient(0.1818, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma14 : na, "MA04 (p57)", color=color.from_gradient(0.2727, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma19 : na, "MA05 (p85)", color=color.from_gradient(0.3636, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma24 : na, "MA06 (p119)", color=color.from_gradient(0.4545, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma29 : na, "MA07 (p161)", color=color.from_gradient(0.5455, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma34 : na, "MA08 (p212)", color=color.from_gradient(0.6364, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma39 : na, "MA09 (p273)", color=color.from_gradient(0.7273, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma43 : na, "MA10 (p332)", color=color.from_gradient(0.8182, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma48 : na, "MA11 (p412)", color=color.from_gradient(0.9091, 0, 1, cFast, cSlow), linewidth=1, editable=false)
plot(showMA ? _ma53 : na, "MA12 (p494)", color=color.from_gradient(1.0000, 0, 1, cFast, cSlow), linewidth=1, editable=false)
````
