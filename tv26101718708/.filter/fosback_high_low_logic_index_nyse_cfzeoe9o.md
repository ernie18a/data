# Fosback High Low Logic Index [NYSE]

- url: https://www.tradingview.com/script/cFZeOE9o-Fosback-High-Low-Logic-Index-NYSE/
- type: indicator
- pine_id: PUB;6ea35df10df841148c1d00b7a755c482
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

This indicator implements Norman Fosback's High Low Logic Index (HLLI) as described in his 1976 book [i]Stock Market Logic[/i]. The HLLI detects internal market divergence by measuring how many stocks are simultaneously hitting 52-week highs and 52-week lows on the NYSE. When both counts are elevated, the market's internal structure is bifurcated, which historically precedes significant declines even when headline indices appear healthy.

This is a pure breadth indicator plotted in its own pane beneath price, not an overlay.


█ [b]CONCEPT[/b]

Most breadth indicators track net direction: advances minus declines, or new highs minus new lows. The HLLI takes a fundamentally different approach. Instead of asking "which side is winning," it asks "are both extremes active at the same time?" A market where many stocks are making new highs [i]and[/i] many are making new lows is structurally fragile regardless of which count is larger.

The core formula:

[b]Raw Ratio[/b] = min(New 52W Highs, New 52W Lows) / Total Issues Traded × 100

By taking the [i]minimum[/i] of the two counts, the index isolates the "disagreement" component. If 200 stocks hit new highs and 5 hit new lows, the ratio is tiny because the market is moving coherently upward. If 200 hit new highs and 150 hit new lows, the ratio spikes because the market is deeply split.

The raw ratio is then smoothed with an exponential moving average (default 50 bars, approximating Fosback's original 10-week EMA on a daily chart) to filter noise and reveal the underlying regime.


█ [b]HOW TO READ IT[/b]

[b]High readings (above the bearish threshold)[/b]
The market is internally divided. A large number of stocks are reaching 52-week extremes on both sides simultaneously. This condition historically precedes broad market weakness. The rally, if one exists, is narrow or rotational rather than broad-based.

[b]Low readings (below the bullish threshold)[/b]
The market is moving coherently. Very few stocks are at opposing extremes at the same time. This internal agreement, whether the market is trending up or down, historically supports sustained directional moves.

[b]Neutral readings (between thresholds)[/b]
No strong signal in either direction. The background shading is absent in this zone.


█ [b]FEATURES[/b]

• The smoothed HLLI line is color-coded by regime: red when above the bearish threshold,
  green when below the bullish threshold, and gray when neutral.
• The unsmoothed raw ratio is plotted as a faded area behind the HLLI line, allowing you
  to see individual spikes before smoothing absorbs them.
• A status label on the last bar displays the current HLLI value, raw ratio, underlying
  new highs/lows counts, total issues traded, and the active regime.
• Background shading highlights bearish (red) and bullish (green) regimes.
• Two alert conditions fire on threshold crossovers: one when the HLLI crosses above the
  bearish level, one when it crosses below the bullish level.


█ [b]INPUTS[/b]

• [b]EMA Smoothing Length[/b]: Controls the smoothing period for the raw ratio. Default is
  50 bars (approximately 10 trading weeks on a daily chart). Shorter values increase
  sensitivity; longer values produce a slower, more stable signal.
• [b]Bearish Threshold %[/b]: The level above which the HLLI signals elevated divergence.
  Default is 2.5%. This may require adjustment depending on the historical period and
  your risk tolerance.
• [b]Bullish Threshold %[/b]: The level below which the HLLI signals market coherence.
  Default is 1.0%.


█ [b]DATA SOURCES[/b]

This script uses four external data feeds via [i]request.security()[/i]:

• [symbol="MAHN"]MAHN[/symbol] : NYSE new 52-week highs
• [symbol="MALN"]MALN[/symbol] : NYSE new 52-week lows
• [symbol="USI:ADV"]USI:ADV[/symbol] : NYSE advancing issues
• [symbol="USI:DECL"]USI:DECL[/symbol] : NYSE declining issues

Total issues traded is computed as advancing + declining issues. Fosback's original formulation included unchanged issues in the denominator, but TradingView does not provide a reliable NYSE unchanged-issues feed, so this script uses the two-component total. The practical impact on the ratio is minimal.


█ [b]LIMITATIONS[/b]

• This is a regime indicator, not a timing tool. The 50-bar EMA smoothing means the HLLI
  responds slowly to sudden shifts. It is best used as a confirmation layer alongside
  faster signals.
• The default thresholds (2.5% bearish, 1.0% bullish) are starting points derived from
  historical convention. The NYSE universe has changed substantially since 1976 due to
  ETF proliferation and structural changes in listed issues. Backtesting threshold
  sensitivity on your timeframe of interest is recommended.
• Historical data availability for the underlying breadth feeds varies by TradingView
  subscription tier.
• The script uses four [i]request.security()[/i] calls. Keep this in mind if you are near
  TradingView's per-script limit when combining with other multi-feed indicators.


█ [b]NOTES[/b]

This indicator should not be confused with the "High-Low Index" (sometimes called the Record High Percent indicator), which computes new highs / (new highs + new lows). That is a directional measure. Fosback's HLLI specifically uses [i]min[/i](new highs, new lows) in the numerator to capture divergence, which makes it conceptually distinct.

Fosback's original research is published in:
Fosback, Norman G. [i]Stock Market Logic: A Sophisticated Approach to Profits on Wall Street[/i]. Dearborn Financial Publishing, 1976.


═════════════════════════════════════════════════════════════════════════

[b]Disclaimer[/b]: This script is provided for educational and informational purposes only. It is not financial advice. Past indicator behavior does not guarantee future results.

## Source Code

````pine
// Fosback's High Low Logic Index - Traditional NYSE
// Original formulation from Norman Fosback's "Stock Market Logic" (1976)
//
// Calculation:
//   Raw ratio = min(new 52W highs, new 52W lows) / total NYSE issues traded * 100
//   Smoothed with a 50-bar EMA (~10 trading weeks)
//
// Interpretation:
//   High readings (above bearish threshold): breadth bifurcated, historically bearish
//   Low readings (below bullish threshold): market coherent, historically bullish

//@version=6
indicator("Fosback High Low Logic Index [NYSE]", shorttitle = "HLLI NYSE", overlay = false, precision = 2)

////////////
// INPUTS //
////////////
int   ema_length      = input.int(50,    title = "EMA Smoothing Length (bars)", minval = 1)
float bearish_thresh  = input.float(2.5, title = "Bearish Threshold %", step = 0.1)
float bullish_thresh  = input.float(1.0, title = "Bullish Threshold %", step = 0.1)

//////////////
// GET DATA //
//////////////
float nyse_newh = request.security("MAHN", "D", close)  // NYSE new 52W highs
float nyse_newl = request.security("MALN", "D", close)  // NYSE new 52W lows
float nyse_adv  = request.security("USI:ADV",  "D", close)  // NYSE advancing issues
float nyse_dec  = request.security("USI:DECL", "D", close)  // NYSE declining issues

/////////////////
// CALCULATION //
/////////////////
float total_issues = nyse_adv + nyse_dec
float raw_ratio    = total_issues != 0 ? (math.min(nyse_newh, nyse_newl) / total_issues) * 100.0 : 0.0
float hlli         = ta.ema(raw_ratio, ema_length)

///////////////////
// REGIME DETECT //
///////////////////
bool bearish_regime = hlli >= bearish_thresh
bool bullish_regime = hlli <= bullish_thresh

///////////
// PLOTS //
///////////
color hlli_color = bearish_regime ? color.red : bullish_regime ? color.green : color.gray

plot(hlli, title = "HLLI", color = hlli_color, linewidth = 2)
plot(raw_ratio, title = "Raw Ratio", color = color.new(color.gray, 70), linewidth = 1, style = plot.style_area)

hline(bearish_thresh, "Bearish Threshold", color = color.red,   linestyle = hline.style_dashed)
hline(bullish_thresh, "Bullish Threshold", color = color.green, linestyle = hline.style_dashed)

bgcolor(bearish_regime ? color.new(color.red, 90) : bullish_regime ? color.new(color.green, 90) : na)

/////////////////////
// INFO LABEL      //
/////////////////////
if barstate.islast
    string sep = "-----------------------------\n"

    string regime_str = bearish_regime ? "BEARISH (divergence elevated)" :
         bullish_regime ? "BULLISH (market coherent)" : "NEUTRAL"

    string label_text = "FOSBACK HLLI (NYSE): " + regime_str + "\n" +
         sep +
         "HLLI (EMA " + str.tostring(ema_length) + "): " + str.tostring(hlli, "#.##") + "%\n" +
         "Raw ratio: " + str.tostring(raw_ratio, "#.##") + "%\n" +
         sep +
         "New 52W Highs: " + str.tostring(nyse_newh, "#") + "\n" +
         "New 52W Lows:  " + str.tostring(nyse_newl, "#") + "\n" +
         "min(H,L):      " + str.tostring(math.min(nyse_newh, nyse_newl), "#") + "\n" +
         "Total issues:  " + str.tostring(total_issues, "#") + "\n" +
         sep +
         "Bearish above: " + str.tostring(bearish_thresh, "#.#") + "%\n" +
         "Bullish below: " + str.tostring(bullish_thresh, "#.#") + "%\n"

    label.new(bar_index + 3, hlli, label_text,
         xloc = xloc.bar_index, yloc = yloc.price,
         color = bearish_regime ? color.red : bullish_regime ? color.green : color.blue,
         textcolor = color.white, style = label.style_label_left,
         size = size.normal)

/////////////
// ALERTS  //
/////////////
alertcondition(ta.crossover(hlli, bearish_thresh),  title = "HLLI Bearish Cross", message = "Fosback HLLI crossed above bearish threshold - elevated divergence.")
alertcondition(ta.crossunder(hlli, bullish_thresh), title = "HLLI Bullish Cross", message = "Fosback HLLI crossed below bullish threshold - market coherent.")
````
