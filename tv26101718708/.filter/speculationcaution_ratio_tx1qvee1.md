# Speculation/Caution Ratio

- url: https://www.tradingview.com/script/Tx1QveE1-Speculation-Caution-Ratio/
- type: indicator
- pine_id: PUB;dd24485677804fad85bd3a486e79261d
- version: 1.0

## Description

█ OVERVIEW

[b]Speculation/Caution Ratio (NDX/DJU, raw)[/b] plots the Nasdaq-100 divided by the Dow Jones Utility Average as an absolute level in a separate pane, with reference lines at documented historical milestones and a label showing the current ratio. It is the long-history companion to the detrended sector z-score. It deliberately preserves the non-stationary level so that the full record from 1985 to the present, including the 2000 peak, is visible on a single pane.


█ HISTORY / BACKGROUND

The ratio of the Nasdaq-100 to the Dow Jones Utility Average as a speculation-versus-caution gauge is associated with Robert Prechter and Elliott Wave International. The reasoning is that the Nasdaq-100 represents high-beta, long-duration growth, standing in for speculation, while the Dow Jones Utility Average, a price-weighted average of fifteen utilities, represents low-beta, yield-driven caution. Observed levels include approximate parity in the 1980s, roughly 15 to 1 at the March 2000 peak, a decline toward 3 to 1 across the post-2000 decade, and a higher reading in the 2020s. These are descriptive observations of where the ratio has traded, not signals.


█ HOW IT WORKS

 • Both legs are requested with request.security at the chart resolution using closing values.
 • The ratio is the numerator close divided by the denominator close, computed only when both legs are present and positive.
 • An optional simple moving average smooths the ratio when the smoothing length is greater than 1. At the default of 1, the raw ratio is plotted.
 • Horizontal reference lines are drawn at 1, 3, and 15, corresponding to the historical levels described above.
 • On the last bar, a label prints the current ratio to one decimal place.


█ HOW TO USE

Read the line as the prevailing balance of offensive versus defensive leadership. A rising ratio indicates speculation outpacing caution; a falling ratio indicates the reverse. The reference lines provide historical context: proximity to the 15 line recalls the 2000 peak, the 1 line marks historical parity, and the 3 line marks the post-2000 trough.

Recommended timeframe is weekly or monthly for the secular view. Note that the level is not comparable across decades; see Notes. For a calibrated, cross-era reading, use the companion z-score script.

Visual elements: the ratio line is teal. The 1 and 3 references are gray, dashed and dotted respectively, and the 15 reference is orange dashed. The last-bar label shows the live value.


█ SETTINGS

 • Speculation leg (numerator): default NASDAQ:NDX (Nasdaq-100).
 • Caution leg (denominator): default DJ:DJU (Dow Jones Utility Average). If it does not load, try TVC:DJU.
 • Smoothing (SMA, bars): 1 plots the raw ratio; higher values reduce visual noise. Default 1, minimum 1.
 • Show historical reference levels: toggles the 1, 3, and 15 lines. Default on.
 • Label current ratio: toggles the last-bar value label. Default on.


█ WHAT MAKES IT ORIGINAL

This is a faithful implementation of a known public construct rather than a new method, and it is published open. Its contribution is framing and disclosure. It pairs the raw ratio with documented historical reference levels and an explicit statement of the level's non-stationarity, and it is built as the deep-history half of a two-part pairing whose other half supplies the calibrated, detrended reading. The value it adds is the long, uninterrupted record that cap-weighted, sector-clean pairs cannot reach on this platform.


█ NOTES / LIMITATIONS

 • Non-stationary level. The ratio drifts upward over decades because of index composition changes, divergent sector earnings growth, and the interest-rate cycle. Absolute levels are not comparable across eras, and a new high does not by itself establish a new sentiment extreme. Use the companion z-score for a comparable reading.
 • Construction mismatch. The numerator is a modified cap-weighted index; the denominator is a price-weighted average of fifteen stocks. The two are not built on the same basis, which is part of why the level is not a clean sentiment measure.
 • Symbol availability. The Dow Jones Utility Average symbol convention varies by data feed. If DJ:DJU returns na, substitute TVC:DJU. The Nasdaq-100 numerator requires history from 1985 for the full record.
 • Real-time behavior. Confirmed historical values do not repaint. The current bar updates while it is open and settles on close. No lookahead is requested.
 • Chart symbol. Output depends only on the two leg inputs. The chart's own symbol does not affect the calculation.
 • Reference lines are descriptive context, not buy or sell signals.

## Source Code

````pine
//@version=6
// Speculation/Caution Ratio (NDX/DJU, raw) - Prechter / EWI construct
// The original speculation-vs-caution ratio: Nasdaq-100 divided by the Dow Jones Utility
// Average, plotted as an absolute level. This is the deep-but-dirty companion to the
// detrended sector z-score. Its purpose is the long historical context (1985-present, incl.
// the 2000 mania) that no clean cap-weighted pair can reach on TradingView. The level is
// deliberately NOT detrended or standardized; see Notes on why the level is non-stationary.
// Intended for weekly or monthly charts. Symbol-agnostic: reads the two configured legs.

indicator("Speculation/Caution Ratio (NDX/DJU, raw)", shorttitle="SPEC/CAUT raw", overlay=false, max_bars_back=5000)

// ---------------- Inputs ----------------
specSym = input.symbol("NASDAQ:NDX", "Speculation leg (numerator)", group="Construction", tooltip="Default = Nasdaq-100, modified cap-weighted, history from 1985. The original Prechter/EWI speculation leg.")
cautSym = input.symbol("DJ:DJU", "Caution leg (denominator)", group="Construction", tooltip="Default = Dow Jones Utility Average, 15-stock price-weighted. If it does not load, try TVC:DJU. Verify history depth on your feed.")

smoothLen = input.int(1, "Smoothing (SMA, bars)", minval=1, group="Display", tooltip="1 = raw ratio, as Prechter/EWI present it. Increase only to reduce visual noise.")
showRefs  = input.bool(true, "Show historical reference levels", group="Display")
showLast  = input.bool(true, "Label current ratio", group="Display")

// ---------------- Data ----------------
spec = request.security(specSym, timeframe.period, close)
caut = request.security(cautSym, timeframe.period, close)

valid  = not na(spec) and not na(caut) and caut > 0 and spec > 0
ratio  = valid ? spec / caut : na
ratioS = smoothLen > 1 ? ta.sma(ratio, smoothLen) : ratio

// ---------------- Plot ----------------
plot(ratioS, "NDX/DJU", color=#1D9E75, linewidth=2)

// Documented historical levels - descriptive references, not signals:
//   ~1   1980s parity
//   ~3   2009 lost-decade trough
//   ~15  March 2000 dot-com peak
hline(showRefs ? 1  : na, "1980s parity (1:1)",    color=color.new(color.gray, 40),   linestyle=hline.style_dashed)
hline(showRefs ? 3  : na, "2009 trough (3:1)",     color=color.new(color.gray, 60),   linestyle=hline.style_dotted)
hline(showRefs ? 15 : na, "2000 peak (15:1)",      color=color.new(color.orange, 20), linestyle=hline.style_dashed)

// ---------------- Current-value label ----------------
var label lbl = na
if barstate.islast and showLast and not na(ratioS)
    label.delete(lbl)
    lbl := label.new(bar_index, ratioS, str.tostring(ratioS, "#.0") + " : 1", style=label.style_label_left, color=color.new(#1D9E75, 0), textcolor=color.white, size=size.small)
````
