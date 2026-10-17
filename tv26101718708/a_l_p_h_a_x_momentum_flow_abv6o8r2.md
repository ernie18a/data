# [ A L P H A X ]  Momentum Flow

- url: https://www.tradingview.com/script/ABV6o8r2-A-L-P-H-A-X-Momentum-Flow/
- type: indicator
- pine_id: PUB;8831d1760f5d4c36901fdb3aa701e67d
- version: 1.0

## Description

[b]AlphaX Momentum Flow — 4-Color MACD Histogram, Divergence Detection, Squeeze Breakout, Zero Line Cross Markers & Live Dashboard[/b]

AlphaX Momentum Flow is a professional-grade MACD oscillator rebuilt from the ground up in Pine Script v6 under the AlphaX visual system. It takes the classic MACD framework and extends it with four additional signal layers — divergence detection, histogram squeeze breakout, zero line cross markers, and a real-time live dashboard — all presented through a clean, clutter-free visual design that eliminates the label noise common in most enhanced MACD indicators. Every signal is confirmed on bar close with zero repainting.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]📸 Visual Overview[/b]
[image]https://www.tradingview.com/x/IQMQK4zk/[/image]
[i]AlphaX Momentum Flow showing the 4-color histogram, MACD and signal lines, cross dots, zero line triangles, divergence ring markers, squeeze background flash, and the live dashboard[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]The MACD Engine[/b]

At the core of AlphaX Momentum Flow is the standard MACD calculation — fast EMA minus slow EMA, smoothed by a signal line, with the histogram representing the gap between them. The defaults (12 / 26 / 9) match the classic configuration used across most trading platforms, so the indicator is immediately familiar and directly comparable to any standard MACD setup.

What separates Momentum Flow from a plain MACD is everything built on top of that core — the visual system, the additional signal layers, and the live dashboard that synthesizes everything into a single readable state panel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]4-Color Histogram[/b]

The histogram uses four distinct colors to communicate not just direction but momentum quality at a glance — telling you whether the current move is building or fading before the MACD line has even crossed.

[list]
[*][b]Bright green (bull bright)[/b] — histogram is above zero and expanding. Bullish momentum is actively building. The strongest bullish histogram state.
[*][b]Dim green (bull dim)[/b] — histogram is above zero but contracting. Bullish momentum exists but is beginning to fade. Watch for a potential cross or reversal.
[*][b]Bright red (bear bright)[/b] — histogram is below zero and expanding downward. Bearish momentum is actively building. The strongest bearish histogram state.
[*][b]Dim red (bear dim)[/b] — histogram is below zero but contracting back toward zero. Bearish momentum exists but is weakening. A potential reversal or cross may be forming.
[/list]

Reading the histogram in 4-color mode gives you earlier warning of momentum shifts than waiting for a MACD/signal line cross — a transition from bright to dim in either direction is the first sign that the current move is losing energy.

4-color mode can be toggled off to display the histogram in a single neutral color if you prefer the classic look.

[i]4-color histogram in action — bright colors marking strong momentum phases, dim colors showing early fading[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

〇 [b]Signal Line Cross Dots[/b]

When the MACD line crosses the signal line, a filled circle is plotted directly on the signal line at the cross bar:

[list]
[*][b]Bright green dot[/b] — MACD crossed above signal. Bullish momentum shift.
[*][b]Bright red dot[/b] — MACD crossed below signal. Bearish momentum shift.
[/list]

Cross dots are placed on the signal line rather than the histogram, keeping them visually separated from the histogram bars and easy to spot even during busy market conditions. They are confirmed on bar close only — no repainting.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▲ [b]Zero Line Cross Markers[/b]

When the MACD line crosses above or below zero, a small triangle is plotted directly on the zero line:

[list]
[*][b]▲ Green triangle[/b] — MACD crossed above zero. Macro bullish bias confirmed — the fast EMA has moved above the slow EMA.
[*][b]▼ Red triangle[/b] — MACD crossed below zero. Macro bearish bias confirmed.
[/list]

Zero line crosses are more significant than signal line crosses. A signal line cross tells you momentum is shifting within the current trend. A zero line cross tells you the macro trend itself has changed — price is now on the other side of its moving average equilibrium. Use zero line crosses to set your directional bias and signal line crosses to time entries within that bias.

Markers are pinned exactly on the zero line — no floating labels, no clutter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ [b]Divergence Detection[/b]

AlphaX Momentum Flow detects both bullish and bearish divergence automatically, confirmed on bar close with zero repainting.

[b]Bullish Divergence[/b] — price makes a lower low over the lookback window while the MACD makes a higher low at the same time, and MACD is currently below zero. This combination signals that selling pressure is weakening even though price is still falling — a classic early warning of a potential reversal upward.

[b]Bearish Divergence[/b] — price makes a higher high over the lookback window while the MACD makes a lower high at the same time, and MACD is currently above zero. This signals that buying pressure is weakening even though price is still rising — an early warning of a potential reversal downward.

Divergence is marked with a distinctive [b]ring marker[/b] — a larger outer circle with a dark center — plotted directly on the MACD line at the divergence bar. The ring design is intentionally distinct from the smaller, filled cross dots so you can differentiate the two signal types instantly without reading any text.

Two additional guards keep divergence signals meaningful:
[list]
[*]Bullish divergence only fires when MACD is below zero — divergence from within bearish territory is structurally more significant than divergence above the zero line
[*]Bearish divergence only fires when MACD is above zero — same logic in reverse
[/list]

The divergence lookback window is configurable from 5 to 50 bars.

[i]Divergence ring markers on the MACD line — larger ring shape clearly distinguishes them from the cross dots[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Histogram Squeeze Breakout[/b]

The Squeeze detector monitors the histogram for periods of compression — when the bars are getting progressively smaller in absolute terms, momentum is coiling and a breakout move is building. When the compression resolves and the histogram begins expanding again, the squeeze breakout fires.

[b]How the squeeze is detected:[/b]
[list]
[*]The absolute value of the histogram is tracked over the squeeze lookback window
[*]When the recent minimum absolute histogram value is very small relative to the broader historical range — below 15% of the recent high-low range — the market is in a squeeze state
[*]The squeeze breakout signal fires on the first bar where the histogram was in a squeeze state on the prior bar and is now actively expanding in a clear direction
[*]A bullish squeeze breakout fires when the histogram is above zero and expanding
[*]A bearish squeeze breakout fires when the histogram is below zero and expanding
[/list]

The signal is deliberately designed to mark the [b]start of the new move[/b] rather than the quiet period before it. The squeeze period itself is shown in the dashboard as [b]● COILING[/b] so you can see compression building in real time, and the moment it resolves the dashboard switches to [b]⚡ BULL SQUEEZE[/b] or [b]⚡ BEAR SQUEEZE[/b].

Visually, the squeeze breakout is shown as a [b]single-bar background flash[/b] — the pane background briefly highlights in green or red at the breakout bar only, then returns to normal. This is clean and unambiguous — no labels stacking on the histogram, no text overlapping other signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎨 [b]Bias Background Tint[/b]

When both the MACD line and the histogram agree on direction — both above zero for bullish, both below zero for bearish — a very subtle, persistent background tint is applied to the oscillator pane. Green for confirmed bull bias, red for confirmed bear bias, invisible when conditions are mixed or uncertain.

The tint is set at near-full transparency so it never competes with the histogram or lines visually — it is purely an ambient cue that tells you the overall momentum alignment without requiring you to actively check both values.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 [b]Live Dashboard[/b]

The dashboard gives you a real-time text readout of every MACD state in a compact panel — no need to read individual values off the chart manually. Eight rows update on every bar close:

[list]
[*][b]MACD[/b] — live MACD line value, green when above zero, red when below
[*][b]SIGNAL[/b] — live signal line value
[*][b]HISTOGRAM[/b] — live histogram value, green when positive, red when negative
[*][b]HIST MOM[/b] — histogram momentum state: ▲ EXPANDING or ▼ FADING, reflecting whether the current histogram bar is larger or smaller than the previous one
[*][b]BIAS[/b] — overall momentum bias: ▲ BULL (both MACD and histogram positive), ▼ BEAR (both negative), ▲ WEAK BULL or ▼ WEAK BEAR when they disagree. Highlighted in green or red when a strong bias is active.
[*][b]CROSS[/b] — shows ▲ BULL CROSS or ▼ BEAR CROSS when a signal line cross occurred on the current bar, highlighted in the corresponding color, otherwise — NONE
[*][b]SIGNAL[/b] — shows the highest-priority active special signal: ◆ BULL DIVERGENCE, ◆ BEAR DIVERGENCE, ⚡ BULL SQUEEZE, ⚡ BEAR SQUEEZE, ● COILING (squeeze building but not yet broken), or — NONE
[/list]

Dashboard position is configurable — Top Right, Top Left, Bottom Right, or Bottom Left.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]

[list]
[*]📊 4-color histogram — bright/dim bull and bear shading shows momentum direction AND quality simultaneously
[*]〇 Signal line cross dots — filled circles on the signal line, bull green and bear red, confirmed on bar close
[*]▲ Zero line cross markers — small triangles pinned at zero, marking macro trend shifts cleanly with no floating labels
[*]◆ Divergence detection — bullish and bearish divergence with configurable lookback, marked with distinctive ring markers on the MACD line
[*]⚡ Squeeze breakout detection — compression period monitoring with a single-bar background flash on breakout, no labels
[*]🎨 Bias background tint — subtle ambient pane color when MACD and histogram both confirm the same direction
[*]📋 Live 8-row dashboard — MACD, signal, histogram values, histogram momentum, bias state, cross status, and special signal — all updating in real time
[*]🔔 10 alert conditions — individual alerts for every signal type plus combined any-bull and any-bear alerts
[*]✅ Zero repainting — all signals confirmed on bar close only
[*]🎨 Full AlphaX visual theme — yellow-green for bullish, red for bearish, dark background dashboard, consistent across all chart elements
[*]⚙ Fully configurable — all MACD periods, source, display toggles, divergence lookback, and squeeze sensitivity adjustable from the settings panel
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]MACD Settings[/b]
[list]
[*]Fast Length — EMA period for the fast moving average (default: 12)
[*]Slow Length — EMA period for the slow moving average (default: 26)
[*]Signal Length — SMA period for the signal line smoothing (default: 9)
[*]Source — price source used for all calculations (default: close)
[/list]

[b]Display[/b]
[list]
[*]Show MACD Line — toggle the MACD line on or off
[*]Show Signal Line — toggle the signal line on or off
[*]Show Histogram — toggle the histogram bars on or off
[*]Histogram 4-Color Mode — toggle between 4-color momentum shading and single neutral color
[*]Show Bias Background Tint — toggle the ambient pane tint when bias is confirmed
[/list]

[b]Signals[/b]
[list]
[*]Show Signal Cross Dots — toggle cross dot markers on the signal line
[*]Show Zero Line Cross Markers — toggle triangle markers at the zero line
[*]Show Divergence Markers — toggle divergence ring markers on the MACD line
[*]Divergence Lookback — number of bars to look back for divergence comparison (default: 14, range: 5–50)
[*]Show Squeeze Breakout Markers — toggle squeeze breakout background flash
[*]Squeeze Lookback (bars) — number of bars to measure histogram compression over (default: 5, range: 3–20)
[/list]

[b]Dashboard[/b]
[list]
[*]Show Dashboard — toggle the live dashboard panel on or off
[*]Position — placement of the dashboard (Top Right, Top Left, Bottom Right, Bottom Left)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions[/b]

[list]
[*]Bull Signal Cross — MACD crossed above signal line
[*]Bear Signal Cross — MACD crossed below signal line
[*]Bull Zero Line Cross — MACD crossed above zero
[*]Bear Zero Line Cross — MACD crossed below zero
[*]Bullish Divergence — price lower low with MACD higher low below zero
[*]Bearish Divergence — price higher high with MACD lower high above zero
[*]Bullish Squeeze Breakout — histogram expanding bullish after compression
[*]Bearish Squeeze Breakout — histogram expanding bearish after compression
[*]Any Bull Signal — fires on any of the four bullish events above
[*]Any Bear Signal — fires on any of the four bearish events above
[/list]

All alert messages include {{ticker}} and {{interval}} placeholders for webhook integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Read AlphaX Momentum Flow — Step by Step[/b]

[b]Step 1 — Set your directional bias from the zero line[/b]
[list]
[*]MACD above zero → macro bullish bias. Prioritize long setups and look for bullish signal line crosses and bullish divergence.
[*]MACD below zero → macro bearish bias. Prioritize short setups and look for bearish signal line crosses and bearish divergence.
[*]A zero line cross triangle tells you the moment the bias has officially flipped.
[/list]

[b]Step 2 — Read histogram momentum for timing[/b]
[list]
[*]Bright color = momentum actively building in that direction. The strongest bars to align entries with.
[*]Dim color = momentum fading. Not the time to chase — a cross or reversal may be forming.
[*]Watch for dim → bright transitions as early momentum re-acceleration signals.
[/list]

[b]Step 3 — Use signal line crosses for entry timing[/b]
[list]
[*]A green dot on the signal line during a bullish bias (MACD above zero) is a confirmation entry signal — momentum is re-aligning with the macro trend.
[*]A red dot during a bearish bias is the equivalent for shorts.
[*]Cross dots that occur against the zero line bias (e.g., a red cross dot while MACD is above zero) are counter-trend signals — treat them with more caution or use them only for partial exits.
[/list]

[b]Step 4 — Watch for divergence as early reversal warning[/b]
[list]
[*]A ◆ ring marker on the MACD line means price and momentum are disagreeeing — one of them is about to correct toward the other.
[*]Bullish divergence below zero is one of the highest-probability reversal setups on this indicator — price is making new lows but the selling force is measurably weakening.
[*]Do not act on divergence alone — wait for a signal line cross or zero line cross to confirm the reversal is beginning.
[/list]

[b]Step 5 — Act on squeeze breakouts for impulsive move entries[/b]
[list]
[*]When the dashboard shows ● COILING, momentum is compressing. A larger move is building.
[*]When the pane flashes and the dashboard switches to ⚡ BULL SQUEEZE or ⚡ BEAR SQUEEZE, the compression has resolved — the new move is starting.
[*]Squeeze breakouts are particularly powerful when they occur after a zero line cross — compressed momentum breaking out in the direction of a fresh macro bias shift.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]

[list]
[*]📈 [b]MACD users who want more information without more clutter[/b] — every enhancement adds insight through visual design, not text labels stacking on the chart
[*]🥇 [b]Momentum traders on any instrument or timeframe[/b] — works on forex, gold, indices, crypto, and equities across all timeframes
[*]🧠 [b]Traders who use MACD for trend confirmation[/b] — the zero line cross markers and bias tint make the macro trend state immediately obvious without reading numbers
[*]🔍 [b]Traders who rely on divergence[/b] — automated detection with a clean ring marker removes the manual scanning process
[*]⚡ [b]Breakout traders[/b] — the squeeze detector gives early warning when momentum is coiling before an impulsive move
[*]🔔 [b]Alert-driven traders[/b] — 10 alert conditions cover every signal type with clean webhook-ready messages
[*]📋 [b]Traders who want a live status readout[/b] — the dashboard replaces manual value checking with a real-time state panel
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]

[list]
[*]All signals are confirmed on [b]bar close[/b] — Momentum Flow does not repaint. Signals visible on historical bars will not move or disappear.
[*]The divergence detector compares the current bar's close and MACD value against the lowest or highest values seen in the lookback window. Increasing the lookback produces fewer but more structurally significant divergence signals. Decreasing it produces more frequent signals on smaller swings.
[*]The squeeze sensitivity is controlled by the Squeeze Lookback setting. Shorter lookback = more squeeze signals on minor compressions. Longer lookback = only major compression periods qualify.
[*]The MACD line color changes dynamically based on whether it is above or below the signal line — green when above, red when below — giving an additional at-a-glance view of cross state beyond the dot markers.
[*]Default MACD settings (12 / 26 / 9) are the universal standard. They work well across all timeframes and instruments without adjustment. Modify them only if you have a specific reason based on your instrument's volatility profile.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who want more from their MACD — without more noise on their chart.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX

//@version=6
indicator("[ A L P H A X ]  Momentum Flow", shorttitle="AlphaX MFlow", overlay=false)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ THEME TOKENS ════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

_bull        = #A7D129
_bull_bright = #c8e624
_bull_dim    = #6b8a1a
_bear        = #E43636
_bear_bright = #ff5252
_bear_dim    = #9c1f1f
_neutral     = #555555
_neutral_lt  = #888888
_text_lt     = #cccccc
_dash_bg     = #0f0f0f
_dash_border = #1a1a1a
_dash_frame  = #242424

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ INPUTS ══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

fastLen       = input.int(12,  "Fast Length",              minval=1,           group="MACD Settings")
slowLen       = input.int(26,  "Slow Length",              minval=1,           group="MACD Settings")
signalLen     = input.int(9,   "Signal Length",            minval=1,           group="MACD Settings")
src           = input.source(close, "Source",                                  group="MACD Settings")

showMacd      = input.bool(true,  "Show MACD Line",                            group="Display")
showSignal    = input.bool(true,  "Show Signal Line",                          group="Display")
showHist      = input.bool(true,  "Show Histogram",                            group="Display")
histFourColor = input.bool(true,  "Histogram 4-Color Mode",                    group="Display")
showBiasTint  = input.bool(true,  "Show Bias Background Tint",                 group="Display")

showCross     = input.bool(true,  "Show Signal Cross Dots",                    group="Signals")
showZeroCross = input.bool(true,  "Show Zero Line Cross Markers",              group="Signals")
showDiv       = input.bool(true,  "Show Divergence Markers",                   group="Signals")
divLookback   = input.int(14,     "Divergence Lookback", minval=5, maxval=50,  group="Signals")
showSqueeze   = input.bool(true,  "Show Squeeze Breakout Markers",             group="Signals")
squeezeBars   = input.int(5,      "Squeeze Lookback (bars)", minval=3, maxval=20, group="Signals")

showDash      = input.bool(true, "Show Dashboard",                             group="Dashboard")
dashPos       = input.string("Bottom Right", "Position",
  options=["Top Right","Top Left","Bottom Right","Bottom Left"],                group="Dashboard")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ CORE CALCULATIONS ════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

fastMA = ta.ema(src, fastLen)
slowMA = ta.ema(src, slowLen)
macd   = fastMA - slowMA
signal = ta.sma(macd, signalLen)
hist   = macd - signal

// ── Histogram state ───────────────────────────────────────────────────────────
histUp_pos   = hist > 0 and hist > hist[1]    // above zero, expanding  → brightest bull
histDown_pos = hist > 0 and hist <= hist[1]   // above zero, fading     → dim bull
histDown_neg = hist < 0 and hist < hist[1]    // below zero, expanding  → brightest bear
histUp_neg   = hist < 0 and hist >= hist[1]   // below zero, fading     → dim bear

histColor = histFourColor
  ? histUp_pos   ? color.new(_bull_bright, 0)
  : histDown_pos ? color.new(_bull_dim,    0)
  : histDown_neg ? color.new(_bear_bright, 0)
  : histUp_neg   ? color.new(_bear_dim,    0)
  : color.new(_neutral, 0)
  : color.new(_neutral_lt, 0)

// ── MACD / Signal colors ──────────────────────────────────────────────────────
macdAbove   = macd >= signal
macdColor   = macdAbove ? color.new(_bull, 0) : color.new(_bear, 0)
signalColor = color.new(_text_lt, 20)

// ── Crosses ───────────────────────────────────────────────────────────────────
crossUp       = ta.crossover(macd,  signal)
crossDown     = ta.crossunder(macd, signal)
zeroCrossUp   = ta.crossover(macd,  0)
zeroCrossDown = ta.crossunder(macd, 0)

// ── Divergence ────────────────────────────────────────────────────────────────
// Bullish: price makes lower low while MACD makes higher low (below zero)
// Bearish: price makes higher high while MACD makes lower high (above zero)
priceLL = close < ta.lowest(close[1],  divLookback)
macdHL  = macd  > ta.lowest(macd[1],   divLookback)
priceHH = close > ta.highest(close[1], divLookback)
macdLH  = macd  < ta.highest(macd[1],  divLookback)

bullDiv = showDiv and priceLL and macdHL and macd < 0
bearDiv = showDiv and priceHH and macdLH and macd > 0

// ── Histogram Squeeze ─────────────────────────────────────────────────────────
// Squeeze: histogram compressing → momentum coiling → breakout imminent.
// Signal fires on the first expanding bar after a compression period.
absHist      = math.abs(hist)
squeezeLow   = ta.lowest(absHist, squeezeBars)
histRange    = ta.highest(absHist, squeezeBars * 3) - ta.lowest(absHist, squeezeBars * 3)
squeezeActive     = histRange > 0 and squeezeLow < histRange * 0.15
squeezeBreakBull  = showSqueeze and squeezeActive[1] and hist > 0 and absHist > absHist[1]
squeezeBreakBear  = showSqueeze and squeezeActive[1] and hist < 0 and absHist > absHist[1]

// ── Bias ─────────────────────────────────────────────────────────────────────
bullBias = macd > 0 and hist > 0
bearBias = macd < 0 and hist < 0

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ PLOTS ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// Histogram, MACD, Signal
plot(showHist   ? hist   : na, title="Histogram",   color=histColor,   style=plot.style_histogram, linewidth=4)
plot(showMacd   ? macd   : na, title="MACD Line",   color=macdColor,   linewidth=2)
plot(showSignal ? signal : na, title="Signal Line", color=signalColor, linewidth=1)
hline(0, "Zero Line", color=color.new(_neutral, 50), linestyle=hline.style_solid, linewidth=1)

// ── Signal Line Cross — filled circles on the signal line ────────────────────
plot(showCross and crossUp   ? signal : na,
  title="Bull Cross Dot", style=plot.style_circles, linewidth=5,
  color=color.new(_bull_bright, 0))

plot(showCross and crossDown ? signal : na,
  title="Bear Cross Dot", style=plot.style_circles, linewidth=5,
  color=color.new(_bear_bright, 0))

// ── Zero Line Cross — small triangles pinned at the zero line ───────────────
// With location.absolute the series value IS the Y coordinate.
// Passing (condition ? 0.0 : na) places the shape exactly on zero.
plotshape(showZeroCross and zeroCrossUp   ? 0.0 : na,
  title="Zero Cross Bull", style=shape.triangleup,
  location=location.absolute, color=color.new(_bull_bright, 0),
  size=size.tiny)

plotshape(showZeroCross and zeroCrossDown ? 0.0 : na,
  title="Zero Cross Bear", style=shape.triangledown,
  location=location.absolute, color=color.new(_bear_bright, 0),
  size=size.tiny)

// ── Divergence — small diamonds plotted on the MACD line ─────────────────────
// Uses plot with style_circles at a distinct size to mark the bar cleanly
plot(bullDiv ? macd : na,
  title="Bull Divergence Dot", style=plot.style_circles, linewidth=7,
  color=color.new(_bull_bright, 20))

plot(bearDiv ? macd : na,
  title="Bear Divergence Dot", style=plot.style_circles, linewidth=7,
  color=color.new(_bear_bright, 20))

// Inner dot to create a ring effect — visually distinct from cross dots
plot(bullDiv ? macd : na,
  title="Bull Div Inner", style=plot.style_circles, linewidth=3,
  color=color.new(_dash_bg, 0))

plot(bearDiv ? macd : na,
  title="Bear Div Inner", style=plot.style_circles, linewidth=3,
  color=color.new(_dash_bg, 0))

// ── Squeeze Breakout — background flash on breakout bar only ─────────────────
// A brief, single-bar bgcolor flash is far cleaner than a label on the histogram
bgcolor(showSqueeze and squeezeBreakBull ? color.new(_bull, 82) :
        showSqueeze and squeezeBreakBear ? color.new(_bear, 82) : na,
  title="Squeeze Breakout Flash")

// ── Bias tint — very subtle, sustained while bias holds ──────────────────────
bgcolor(showBiasTint and bullBias ? color.new(_bull, 96) :
        showBiasTint and bearBias ? color.new(_bear, 96) : na,
  title="Bias Background Tint")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ DASHBOARD ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

f_dashPos(string p) =>
    switch p
        "Top Right"   => position.top_right
        "Top Left"    => position.top_left
        "Bottom Left" => position.bottom_left
        =>               position.bottom_right

var table dash = table.new(f_dashPos(dashPos), 2, 8,
  bgcolor      = color.new(_dash_bg,     0),
  border_width = 1,
  border_color = color.new(_dash_border, 0),
  frame_width  = 1,
  frame_color  = color.new(_dash_frame,  0))

if showDash and barstate.islast
    headerBg = color.new(#111111, 0)
    cellBg   = color.new(#0a0a0a, 0)
    lblCol   = color.new(_text_lt, 0)
    sz       = size.small

    // Header
    table.cell(dash, 0, 0, "AlphaX  M O M E N T U M  F L O W",
      text_color=color.new(_bull, 0), text_size=sz,
      bgcolor=headerBg, text_halign=text.align_center)
    table.cell(dash, 1, 0, "", bgcolor=headerBg)

    // MACD
    macdCol = macd > 0 ? color.new(_bull, 0) : color.new(_bear, 0)
    table.cell(dash, 0, 1, "MACD",      text_color=lblCol,   text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 1, str.tostring(macd,   "#.####"), text_color=macdCol,            text_size=sz, bgcolor=cellBg)

    // Signal
    table.cell(dash, 0, 2, "SIGNAL",    text_color=lblCol,   text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 2, str.tostring(signal, "#.####"), text_color=color.new(_text_lt, 0), text_size=sz, bgcolor=cellBg)

    // Histogram
    histCol = hist > 0 ? color.new(_bull, 0) : color.new(_bear, 0)
    table.cell(dash, 0, 3, "HISTOGRAM", text_color=lblCol,   text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 3, str.tostring(hist,   "#.####"), text_color=histCol,            text_size=sz, bgcolor=cellBg)

    // Histogram Momentum
    histMomTxt = histUp_pos ? "▲ EXPANDING" : histDown_pos ? "▼ FADING" : histDown_neg ? "▼ EXPANDING" : "▲ FADING"
    histMomCol = histUp_pos or histUp_neg ? color.new(_bull, 0) : color.new(_bear, 0)
    table.cell(dash, 0, 4, "HIST MOM",  text_color=lblCol,   text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 4, histMomTxt, text_color=histMomCol, text_size=sz, bgcolor=cellBg)

    // Bias
    biasTxt = bullBias ? "▲ BULL" : bearBias ? "▼ BEAR" : macd > 0 ? "▲ WEAK BULL" : "▼ WEAK BEAR"
    biasCol = macd > 0 ? color.new(_bull, 0) : color.new(_bear, 0)
    biasBg  = bullBias ? color.new(_bull, 88) : bearBias ? color.new(_bear, 88) : cellBg
    table.cell(dash, 0, 5, "BIAS",      text_color=lblCol,   text_size=sz, bgcolor=biasBg)
    table.cell(dash, 1, 5, biasTxt,    text_color=biasCol,  text_size=sz, bgcolor=biasBg)

    // Cross
    crossTxt = crossUp ? "▲ BULL CROSS" : crossDown ? "▼ BEAR CROSS" : "— NONE"
    crossCol = crossUp ? color.new(_bull_bright, 0) : crossDown ? color.new(_bear_bright, 0) : color.new(_neutral, 0)
    crossBg  = crossUp ? color.new(_bull, 88) : crossDown ? color.new(_bear, 88) : cellBg
    table.cell(dash, 0, 6, "CROSS",     text_color=lblCol,   text_size=sz, bgcolor=crossBg)
    table.cell(dash, 1, 6, crossTxt,   text_color=crossCol, text_size=sz, bgcolor=crossBg)

    // Divergence / Squeeze
    divSqTxt = bullDiv            ? "◆ BULL DIVERGENCE"  :
               bearDiv            ? "◆ BEAR DIVERGENCE"  :
               squeezeBreakBull   ? "⚡ BULL SQUEEZE"     :
               squeezeBreakBear   ? "⚡ BEAR SQUEEZE"     :
               squeezeActive      ? "● COILING"           : "— NONE"
    divSqCol = bullDiv or squeezeBreakBull ? color.new(_bull_bright, 0) :
               bearDiv or squeezeBreakBear ? color.new(_bear_bright, 0) :
               squeezeActive               ? color.new(_neutral_lt,  0) :
               color.new(_neutral, 0)
    divSqBg  = bullDiv or squeezeBreakBull ? color.new(_bull, 90) :
               bearDiv or squeezeBreakBear ? color.new(_bear, 90) : cellBg
    table.cell(dash, 0, 7, "SIGNAL",    text_color=lblCol,   text_size=sz, bgcolor=divSqBg)
    table.cell(dash, 1, 7, divSqTxt,   text_color=divSqCol, text_size=sz, bgcolor=divSqBg)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ALERTS ══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(crossUp,
  title="Bull Signal Cross",
  message="[AlphaX MFlow] BULL — MACD crossed above Signal — {{ticker}} {{interval}} @ {{close}}")
alertcondition(crossDown,
  title="Bear Signal Cross",
  message="[AlphaX MFlow] BEAR — MACD crossed below Signal — {{ticker}} {{interval}} @ {{close}}")
alertcondition(zeroCrossUp,
  title="Bull Zero Line Cross",
  message="[AlphaX MFlow] BULL ZERO CROSS — MACD above zero — {{ticker}} {{interval}} @ {{close}}")
alertcondition(zeroCrossDown,
  title="Bear Zero Line Cross",
  message="[AlphaX MFlow] BEAR ZERO CROSS — MACD below zero — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullDiv,
  title="Bullish Divergence",
  message="[AlphaX MFlow] BULL DIVERGENCE — Price lower low, MACD higher low — {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearDiv,
  title="Bearish Divergence",
  message="[AlphaX MFlow] BEAR DIVERGENCE — Price higher high, MACD lower high — {{ticker}} {{interval}} @ {{close}}")
alertcondition(squeezeBreakBull,
  title="Bullish Squeeze Breakout",
  message="[AlphaX MFlow] BULL SQUEEZE BREAK — Histogram expanding bullish — {{ticker}} {{interval}} @ {{close}}")
alertcondition(squeezeBreakBear,
  title="Bearish Squeeze Breakout",
  message="[AlphaX MFlow] BEAR SQUEEZE BREAK — Histogram expanding bearish — {{ticker}} {{interval}} @ {{close}}")
alertcondition(crossUp or zeroCrossUp or bullDiv or squeezeBreakBull,
  title="Any Bull Signal",
  message="[AlphaX MFlow] BULL signal — {{ticker}} {{interval}} @ {{close}}")
alertcondition(crossDown or zeroCrossDown or bearDiv or squeezeBreakBear,
  title="Any Bear Signal",
  message="[AlphaX MFlow] BEAR signal — {{ticker}} {{interval}} @ {{close}}")
````
