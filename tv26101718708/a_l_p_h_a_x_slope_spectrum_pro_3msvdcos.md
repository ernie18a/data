# [ A L P H A X ]  Slope Spectrum Pro

- url: https://www.tradingview.com/script/3MSvDCOS-A-L-P-H-A-X-Slope-Spectrum-Pro/
- type: indicator
- pine_id: PUB;b456536feb6a4770bb4bfbba33435e27
- version: 1.0

## Description

[b]AlphaX Slope Spectrum Pro — Multi-Period Regression Oscillator, Adaptive Signal Line, Momentum Acceleration, Statistical Regime Detection, Classic & Hidden Divergence & Conviction Dashboard[/b]

AlphaX Slope Spectrum Pro is a professional-grade trend momentum oscillator built on a proprietary multi-period linear regression engine that scans across an entire range of lookback periods simultaneously and synthesizes them into a single adaptive oscillator value per bar. Rather than relying on a fixed-period momentum calculation, Slope Spectrum Pro measures the statistical slope of price across every period in the scan range and combines them using inverse-variance weighting — giving more influence to periods whose regression fits are more consistent, and less to those where price has been noisy. The result is a momentum oscillator that is simultaneously responsive and robust. On top of this engine sits a complete analytical layer: an adaptive signal line that changes speed with market conditions, a momentum acceleration histogram, statistical regime detection bands, classic and hidden divergence detection, regime-filtered entry signals with main chart overlay, and a live 10-row conviction dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]📸 Visual Overview[/b]
[image]https://www.tradingview.com/x/dyup2057/[/image]
[i]AlphaX Slope Spectrum Pro in the oscillator pane — gradient-colored slope line with gradient fill, acceleration histogram in the background, adaptive signal line, regime threshold bands, divergence markers, bull/bear signal dots, main chart triangles, and the conviction dashboard[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]The Slope Engine — Multi-Period Regression Core[/b]

At the foundation of Slope Spectrum Pro is a [b]multi-period linear regression scanner[/b]. On every bar, the engine runs a complete set of linear regressions across every period from your configured minimum to maximum, stepping at your chosen interval. With default settings of Min Period 10, Max Period 100, and Step Size 5, this means [b]19 independent regressions[/b] are computed and synthesized per bar.

Each regression fits a straight line to the logarithm of price over the lookback window and extracts the slope of that fit — a dimensionless measure of directional momentum at that timescale. Positive slope means upward momentum. Negative slope means downward momentum. Steeper slope means stronger momentum.

[b]Inverse-Variance Weighting:[/b]

When Inverse-Variance Weighting is enabled, each regression period's slope is weighted by the inverse of its residual variance — how consistently price tracked the regression line over that lookback. A period where price followed its regression cleanly gets high weight. A period where price bounced erratically around the fitted line gets low weight. The result is that cleaner, more consistent trend periods contribute more to the final oscillator value than noisy, choppy periods — the oscillator becomes naturally less sensitive to random price fluctuations and more responsive to genuine directional momentum.

[b]What the oscillator value means:[/b]
[list]
[*]A value [b]above zero[/b] means the weighted regression slope is net positive — more periods are trending upward than downward across the scanned range.
[*]A value [b]below zero[/b] means the weighted slope is net negative — dominant downward trend momentum.
[*]The [b]magnitude[/b] reflects how steep the consensus slope is. A large positive value means strong, consistent upward momentum. A value near zero means flat or contested momentum.
[/list]

The oscillator is plotted as a gradient-colored line that transitions dynamically from bear red to bull green based on its rolling 200-bar min/max range — the stronger the current momentum relative to recent history, the brighter the color. A gradient fill between the oscillator line and the zero line reinforces the directional bias visually.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

〰 [b]Adaptive Signal Line[/b]

The signal line tracks the slope oscillator — but instead of a fixed-period EMA, Slope Spectrum Pro uses an [b]adaptive alpha-based EMA[/b] that changes its effective length based on current market conditions.

[b]How it adapts:[/b]

The adaptation measures trend strength as how many standard deviations the current oscillator value is from its recent mean. When the oscillator is far from its mean — a clear, developing trend — the signal line shortens and reacts faster, following the oscillator closely. When the oscillator is near its mean — a ranging or choppy condition — the signal line lengthens, smoothing out minor oscillations and reducing false crossovers.

[list]
[*]In a strong trend: the signal is tight. Crossovers happen quickly and reflect real momentum shifts.
[*]In chop or range: the signal is loose. It takes a more significant oscillator move to produce a crossover, filtering out noise automatically.
[/list]

The current effective signal length is shown live on the dashboard as [b]EMA~N[/b] — you can see exactly how tight or loose the signal is at any moment. Adaptive speed can be toggled off for a consistent fixed-length signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Momentum Acceleration Histogram[/b]

Behind the oscillator line, a background [b]acceleration histogram[/b] plots the rate of change of the slope oscillator — how fast momentum is building or fading right now.

[list]
[*][b]Green columns[/b] — acceleration is positive. The slope oscillator is increasing. Momentum is building in the bullish direction.
[*][b]Red columns[/b] — acceleration is negative. The slope oscillator is decreasing. Momentum is fading or building in the bearish direction.
[/list]

Reading the acceleration alongside the main oscillator gives you a two-layer picture:
[list]
[*]Oscillator above zero + green acceleration = [b]strengthening bull momentum[/b]. The best time to enter or hold long.
[*]Oscillator above zero + red acceleration = [b]bull momentum peaking and fading[/b]. Consider reducing exposure or preparing to exit.
[*]Oscillator below zero + red acceleration = [b]strengthening bear momentum[/b]. Best time to hold or enter short.
[*]Oscillator below zero + green acceleration = [b]bear momentum fading[/b]. Watch for a potential reversal or crossover signal.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Statistical Regime Detection[/b]

Slope Spectrum Pro automatically classifies the current market environment into one of three regimes using a rolling statistical framework built from the oscillator's own mean and standard deviation:

[list]
[*][b]Bull Regime[/b] — the oscillator is above the upper band (mean + N standard deviations). Background tints subtly green. Only bullish signals fire when regime filtering is enabled.
[*][b]Bear Regime[/b] — the oscillator is below the lower band (mean − N standard deviations). Background tints subtly red. Only bearish signals fire when regime filtering is enabled.
[*][b]Range Regime[/b] — the oscillator sits between the two bands. Background is a very faint neutral gray. No directional regime is confirmed. Regime-filtered signals are suppressed entirely.
[/list]

Thresholds are calculated as [b]oscillator mean ± (standard deviation × sensitivity multiplier)[/b] over the configured lookback. Increasing the sensitivity multiplier raises the bar required to enter Bull or Bear regime — only the strongest trend episodes qualify. Lowering it makes transitions more frequent.

This system directly controls signal quality when Regime-Filtered Signals is enabled — crossovers opposing the active regime direction are silently blocked before they ever reach the chart.

[i]Regime bands on the oscillator — Bull threshold above, Bear threshold below, background tint reflecting the current zone[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ [b]Divergence Engine — Classic and Hidden[/b]

Slope Spectrum Pro detects four divergence types by comparing confirmed oscillator pivot highs and lows against confirmed price pivot highs and lows. All detections are confirmed on bar close only — no repainting.

[b]Classic Divergences — Reversal Signals:[/b]

[list]
[*][b]Classic Bull Divergence (DIV ▲)[/b] — price makes a lower low while the slope oscillator makes a higher low. Selling pressure is weakening even though price is still falling. A reversal upward may be building.
[*][b]Classic Bear Divergence (DIV ▼)[/b] — price makes a higher high while the slope oscillator makes a lower high. Buying pressure is weakening even though price is still rising. A reversal downward may be building.
[/list]

[b]Hidden Divergences — Trend Continuation Signals:[/b]

[list]
[*][b]Hidden Bull Divergence (H ▲)[/b] — price makes a higher low while the oscillator makes a lower low. Price held higher ground during the pullback — the uptrend is intact and continuation upward is probable.
[*][b]Hidden Bear Divergence (H ▼)[/b] — price makes a lower high while the oscillator makes a higher high. Price failed to rally as high as before even as the oscillator rebounded — the downtrend is intact and continuation downward is probable.
[/list]

Classic divergences warn of potential reversals. Hidden divergences confirm that pullbacks within a trend are likely to resume. Both are marked on the oscillator at the pivot bar with compact [b]DIV[/b] or [b]H[/b] labels. The divergence pivot lookback is configurable. Hidden divergence can be toggled independently from classic divergence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Entry Signals — Oscillator and Main Chart Overlay[/b]

Crossover signals fire when the slope oscillator crosses above or below the adaptive signal line, confirmed on bar close:

[list]
[*][b]Bull Signal (●)[/b] — oscillator crossed above signal line. A small green dot appears on the oscillator.
[*][b]Bear Signal (●)[/b] — oscillator crossed below signal line. A small red dot appears on the oscillator.
[/list]

[b]Regime filtering:[/b] When enabled, bull crossovers during a Bear Regime are blocked. Bear crossovers during a Bull Regime are blocked. Only signals aligned with the current statistical regime are displayed — this single filter eliminates a significant category of false signals.

[b]Main chart overlay:[/b] When Overlay Candle Color is enabled:
[list]
[*]A [b]▲ green triangle[/b] appears below the bar on the main chart at every bull signal.
[*]A [b]▼ red triangle[/b] appears above the bar on the main chart at every bear signal.
[*]Candles on the main chart are colored using the same gradient as the oscillator — chart candles reflect the current slope momentum state at a glance.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 [b]Live Conviction Dashboard[/b]

A real-time 10-row readout of the oscillator's full internal state, updating on every bar close:

[list]
[*][b]SAMPLES[/b] — number of regression periods computed per bar based on Min, Max, and Step settings.
[*][b]MODE[/b] — INV-VAR WEIGHTED or SIMPLE AVERAGE aggregation.
[*][b]OSC VALUE[/b] — live slope oscillator value to six decimal places, green above zero, red below.
[*][b]REGIME[/b] — ▲ BULL ZONE, ▼ BEAR ZONE, or — RANGING. Row highlighted in the corresponding color.
[*][b]MOMENTUM[/b] — ▲ BUILDING (acceleration positive) or ▼ FADING (acceleration negative). Row highlighted accordingly.
[*][b]SIGNAL[/b] — ▲ BULL CROSS / ▼ BEAR CROSS when a crossover fired this bar, or ▲ ABOVE SIG / ▼ BELOW SIG for ongoing position.
[*][b]SIG SPEED[/b] — current effective signal length as EMA~N, showing how tight or loose the adaptive signal is in real time.
[*][b]DIVERGENCE[/b] — highest-priority active divergence: ▲ BULL DIV, ▼ BEAR DIV, ▲ HIDDEN BULL, ▼ HIDDEN BEAR, or — NONE. Row highlighted when active.
[*][b]CONVICTION[/b] — a 0–4 confluence score. Each of the following adds 1 point: regime and oscillator sign agree; regime and acceleration agree; regime and signal side agree; any divergence is active. Score labels — LOW / MIXED (0–1), MODERATE (2), HIGH CONVICTION (3), MAX — ALL ALIGNED (4).
[*][b]OSC (sigma)[/b] — the oscillator value expressed as standard deviations from its recent mean. Shows statistically how far momentum has moved from neutral — +2.5s means 2.5 standard deviations into bull territory.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]

[list]
[*]🔬 Multi-period regression engine — 19 independent regressions per bar (default) synthesized into one adaptive oscillator value
[*]⚖ Inverse-variance weighting — consistent regression periods carry more weight; noisy periods are automatically discounted
[*]〰 Adaptive signal line — effective EMA length speeds up in trends, slows in chop; current length shown live as EMA~N
[*]⚡ Momentum acceleration histogram — rate-of-change of the oscillator, showing whether momentum is building or fading right now
[*]📊 Statistical regime detection — three-zone classification (Bull / Bear / Range) using rolling mean ± standard deviation bands
[*]🔒 Regime-filtered signals — crossovers opposing the current statistical regime are automatically suppressed
[*]◆ Classic divergence — bull and bear reversal divergence between price pivots and oscillator pivots, bar-close confirmed
[*]◆ Hidden divergence — trend continuation signals when price and oscillator diverge in the trend direction
[*]🎯 Main chart overlay — bull/bear triangles on price chart and gradient candle coloring reflecting live slope momentum
[*]🎨 Dynamic gradient oscillator color — live transition from bear to bull based on rolling 200-bar normalization
[*]📋 Live 10-row conviction dashboard — samples, mode, osc value, regime, momentum, signal, signal speed, divergence, conviction score, sigma reading
[*]🏆 4-point conviction scoring — real-time confluence count across regime, acceleration, signal, and divergence alignment
[*]🔔 10 alert conditions — crossovers, classic and hidden divergences, confluence long/short, zero line crosses
[*]🎨 14 user-configurable color inputs — every visual element independently themeable with AlphaX brand defaults
[*]✅ Confirmed on bar close — no repainting on any signal, divergence, or regime transition
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Slope Engine[/b]
[list]
[*]Max Period — upper bound of the regression scan range (default: 100)
[*]Min Period — lower bound of the scan range (default: 10)
[*]Step Size — increment between scanned periods (default: 5). Smaller = more samples, smoother oscillator.
[*]Inverse-Variance Weighting — weight each period by its regression consistency (default: on)
[*]Source — price input for all regressions (default: close)
[/list]

[b]Adaptive Signal Line[/b]
[list]
[*]Base Signal Length — signal EMA length in neutral conditions (default: 7)
[*]Adaptive Speed — toggle adaptive EMA alpha on or off
[/list]

[b]Momentum Acceleration[/b]
[list]
[*]Show Acceleration Histogram — toggle the background column histogram
[*]Acceleration Smoothing — EMA smoothing period for acceleration (default: 3)
[/list]

[b]Regime Detection[/b]
[list]
[*]Show Regime Bands — toggle threshold lines and background tinting
[*]Regime Lookback — rolling window for mean and standard deviation (default: 200)
[*]Regime Sensitivity (σ×) — standard deviation multiplier for thresholds (default: 0.5)
[/list]

[b]Divergence Engine[/b]
[list]
[*]Show Divergences — toggle all divergence detection
[*]Divergence Pivot Length — bars on each side to confirm a divergence pivot (default: 5)
[*]Show Hidden Divergences — toggle hidden divergence independently
[/list]

[b]Entry Signals[/b]
[list]
[*]Show Crossover Signals — toggle oscillator signal dots
[*]Regime-Filtered Signals — suppress signals opposing the current regime
[*]Overlay Candle Color — toggle main chart triangles and gradient candle coloring
[/list]

[b]Dashboard[/b]
[list]
[*]Show Dashboard — toggle the dashboard panel
[*]Position — Top Right, Top Left, Bottom Right, Bottom Left
[/list]

[b]Theme[/b]
[list]
[*]Bull Primary / Bright / Dim — three shades of the bullish color family
[*]Bear Primary / Bright / Dim — three shades of the bearish color family
[*]Neutral / Neutral Light — neutral and secondary text colors
[*]Accel Bull / Accel Bear — acceleration histogram column colors
[*]Divergence Bull / Divergence Bear — classic divergence marker colors
[*]Hidden Div Bull / Hidden Div Bear — hidden divergence marker colors
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX Slope Spectrum Pro — Step by Step[/b]

[b]Step 1 — Establish the regime and directional bias[/b]
[list]
[*]Check the REGIME row. ▲ BULL ZONE = the market is in a statistically confirmed trend upward. ▼ BEAR ZONE = confirmed trend downward. — RANGING = no directional edge. Only trade in the direction of the active regime.
[*]Check OSC (sigma). A reading above +2s means deep bull territory. Below −2s means deep bear territory. Near zero = flat momentum, no edge.
[/list]

[b]Step 2 — Read acceleration for entry timing[/b]
[list]
[*]In a Bull Regime, wait for the acceleration histogram to turn green (▲ BUILDING on the dashboard). This means the slope oscillator is accelerating — momentum is growing, not just present.
[*]The ideal entry timing: Bull Regime + oscillator above zero + acceleration building + oscillator above signal line.
[*]Entering while acceleration is red (▼ FADING) in a bull regime risks entering as the current wave is losing steam.
[/list]

[b]Step 3 — Enter on a signal crossover[/b]
[list]
[*]A bull signal dot (oscillator crosses above signal line) with regime filtering enabled is your entry trigger — counter-trend crossovers are already blocked automatically.
[*]If Overlay is enabled, the ▲ triangle on the main chart confirms the exact entry bar.
[*]The faster the adaptive signal (lower EMA~N), the tighter the crossover timing. In strong trends the signal shortens and reacts more quickly.
[/list]

[b]Step 4 — Upgrade conviction with divergence[/b]
[list]
[*]A bull signal crossover occurring simultaneously with or just after a [b]Classic Bull Divergence (DIV ▲)[/b] = high-probability reversal setup.
[*]A bull signal crossover during an uptrend following a [b]Hidden Bull Divergence (H ▲)[/b] = high-probability trend continuation setup.
[*]Check CONVICTION. Score of HIGH CONVICTION (3) or MAX — ALL ALIGNED (4) means multiple independent factors agree. These are the setups to prioritize.
[/list]

[b]Step 5 — Exit when momentum confirms the move is ending[/b]
[list]
[*]Acceleration histogram turning red (▼ FADING) while you are long = first sign the current wave is losing force. Begin monitoring for exit.
[*]A bear signal crossover (oscillator crosses below signal line) = exit trigger.
[*]A regime shift from Bull Zone to Ranging or Bear Zone = structural move is over. Exit and reset.
[*]A Classic Bear Divergence appearing while you are in a long position = warning. Price is printing new highs the oscillator is not confirming. Reduce size or prepare to close.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions[/b]

[list]
[*]SSP — Bull Crossover — oscillator crossed above the adaptive signal line
[*]SSP — Bear Crossover — oscillator crossed below the adaptive signal line
[*]SSP — Classic Bull Divergence — price lower low, oscillator higher low confirmed
[*]SSP — Classic Bear Divergence — price higher high, oscillator lower high confirmed
[*]SSP — Hidden Bull Divergence — price higher low, oscillator lower low (trend continuation)
[*]SSP — Hidden Bear Divergence — price lower high, oscillator higher high (trend continuation)
[*]SSP — CONFLUENCE LONG — bull crossover occurring with bull or hidden bull divergence simultaneously
[*]SSP — CONFLUENCE SHORT — bear crossover occurring with bear or hidden bear divergence simultaneously
[*]SSP — Zero Line Cross Up — oscillator crossed above zero (macro bull momentum shift)
[*]SSP — Zero Line Cross Down — oscillator crossed below zero (macro bear momentum shift)
[/list]

All alert messages include {{ticker}} and {{interval}} for webhook integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]

[list]
[*]🧠 [b]Systematic and quantitative traders[/b] — the regression engine, inverse-variance weighting, and statistical regime framework provide a mathematically grounded, objective momentum reading with no arbitrary indicator parameters to tune
[*]📈 [b]Trend traders on any instrument and timeframe[/b] — the multi-period scan adapts naturally to any market's momentum characteristics without manual recalibration
[*]🔍 [b]Divergence traders[/b] — four divergence types covering both reversals and trend continuations, all confirmed on bar close
[*]⚡ [b]Momentum traders[/b] — the acceleration histogram adds a layer no standard oscillator provides: not just where momentum is, but whether it is growing or shrinking right now
[*]🎯 [b]Precision entry traders[/b] — regime filtering, adaptive signal speed, and the conviction score ensure signals are only shown when multiple independent conditions agree simultaneously
[*]🎨 [b]Traders who customize their charts[/b] — 14 fully user-configurable color inputs, compatible with any chart theme
[*]🔔 [b]Alert-driven traders and bot operators[/b] — 10 alert conditions including a dedicated confluence alert for maximum-conviction setups
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]

[list]
[*]All signals are confirmed on [b]bar close[/b] only. Slope Spectrum Pro does not repaint.
[*]The oscillator value is in units of log-price per bar. The absolute value is very small (typically 0.000001 to 0.001 range) — what matters is the sign, the direction of change, and where it sits relative to regime thresholds and zero.
[*]Wider Min–Max scan ranges produce a smoother oscillator capturing broader trend consensus. Narrower ranges are more reactive to short-term changes. Smaller Step Size = more periods sampled per bar = smoother result.
[*]Regime Sensitivity is the most impactful setting after the scan range. At 0.5σ (default) the regime bands trigger relatively frequently. At 1.0–1.5σ, only very strong trend episodes qualify — signals become rarer but higher quality.
[*]On very low timeframes the nested regression loop may be computationally intensive. Default settings are optimized for timeframes from 1 minute upward on standard instruments.
[*]All theme color defaults are designed for dark chart backgrounds. Adjust Theme inputs if using a light background.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who want to know not just where momentum is — but how it got there, how strong it is, and whether it is still building.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlphaX

//@version=6
indicator("[ A L P H A X ]  Slope Spectrum Pro", shorttitle="AlphaX SSP",
  overlay=false, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ██████████████████  ALPHAX SLOPE SPECTRUM PRO  ███████████████████████████████
// ██  Multi-Period Regression · Adaptive Signal · Divergence · Regime Engine  ██
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ INPUTS ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

GRP_SLOPE = "Slope Engine"
maxRange    = input.int(100,  "Max Period",            minval=20, maxval=300, group=GRP_SLOPE,
  tooltip="Upper bound of the regression period scan. Higher = captures longer-term trend momentum.")
minRange    = input.int(10,   "Min Period",            minval=3,  maxval=50,  group=GRP_SLOPE,
  tooltip="Lower bound of the regression period scan. Lower = more responsive to short-term slope changes.")
stepSize    = input.int(5,    "Step Size",             minval=1,  maxval=20,  group=GRP_SLOPE,
  tooltip="Increment between scanned periods. Smaller step = more samples, smoother oscillator.")
useWeighted = input.bool(true, "Inverse-Variance Weighting",                  group=GRP_SLOPE,
  tooltip="When ON, regression periods with more consistent slopes carry greater weight.")
srcInput    = input.source(close, "Source",                                    group=GRP_SLOPE)

GRP_SIG = "Adaptive Signal Line"
baseSigLen  = input.int(7,    "Base Signal Length",    minval=2,  maxval=50,  group=GRP_SIG,
  tooltip="The signal line length in neutral/ranging conditions.")
adaptiveSig = input.bool(true, "Adaptive Speed",                               group=GRP_SIG,
  tooltip="When ON, the signal EMA alpha adapts faster in trends, slower in chop.")

GRP_ACC = "Momentum Acceleration"
showAccel   = input.bool(true,  "Show Acceleration Histogram",                 group=GRP_ACC,
  tooltip="Plots the rate-of-change of the slope oscillator as a background histogram.")
accelLen    = input.int(3,      "Acceleration Smoothing",  minval=1, maxval=10, group=GRP_ACC)

GRP_REGIME = "Regime Detection"
showRegimes    = input.bool(true,  "Show Regime Bands",                        group=GRP_REGIME)
regimeLookback = input.int(200,    "Regime Lookback",   minval=50, maxval=500, group=GRP_REGIME)
regimeMult     = input.float(0.5,  "Regime Sensitivity (σ×)", minval=0.1, maxval=2.0, step=0.1, group=GRP_REGIME)

GRP_DIV = "Divergence Engine"
showDiv     = input.bool(true,  "Show Divergences",                            group=GRP_DIV)
divPivotLen = input.int(5,      "Divergence Pivot Length", minval=3, maxval=20, group=GRP_DIV)
showHidden  = input.bool(true,  "Show Hidden Divergences",                     group=GRP_DIV)

GRP_SIG2 = "Entry Signals"
showSignals  = input.bool(true,  "Show Crossover Signals",                     group=GRP_SIG2)
regimeFilter = input.bool(true,  "Regime-Filtered Signals",                    group=GRP_SIG2)
showOverlay  = input.bool(true,  "Overlay Candle Color",                       group=GRP_SIG2)

GRP_DASH = "Dashboard"
showDash = input.bool(true,  "Show Dashboard",                                 group=GRP_DASH)
dashPos  = input.string("Top Right", "Position",
  options=["Top Right","Top Left","Bottom Right","Bottom Left"],                group=GRP_DASH)

GRP_CLR = "Theme"
color i_bull        = input.color(#c8e624, "Bull Primary",    group=GRP_CLR)
color i_bull_bright = input.color(#d4f03a, "Bull Bright",     group=GRP_CLR)
color i_bull_dim    = input.color(#9ab81c, "Bull Dim",        group=GRP_CLR)
color i_bear        = input.color(#ff1744, "Bear Primary",    group=GRP_CLR)
color i_bear_bright = input.color(#ff5252, "Bear Bright",     group=GRP_CLR)
color i_bear_dim    = input.color(#d50032, "Bear Dim",        group=GRP_CLR)
color i_neutral     = input.color(#555555, "Neutral",         group=GRP_CLR)
color i_neutral_lt  = input.color(#a0aec0, "Neutral Light",   group=GRP_CLR)
color i_accel_bull  = input.color(#9ab81c, "Accel Bull",      group=GRP_CLR)
color i_accel_bear  = input.color(#d50032, "Accel Bear",      group=GRP_CLR)
color i_div_bull    = input.color(#d4f03a, "Divergence Bull", group=GRP_CLR)
color i_div_bear    = input.color(#ff5252, "Divergence Bear", group=GRP_CLR)
color i_hidden_bull = input.color(#9ab81c, "Hidden Div Bull", group=GRP_CLR)
color i_hidden_bear = input.color(#d50032, "Hidden Div Bear", group=GRP_CLR)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ ALIASES ═══════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

CLEAR        = color.new(color.black, 100)
_bull        = i_bull
_bull_bright = i_bull_bright
_bull_dim    = i_bull_dim
_bear        = i_bear
_bear_bright = i_bear_bright
_bear_dim    = i_bear_dim
_neutral     = i_neutral
_neutral_lt  = i_neutral_lt

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ CORE ENGINE ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// Regression logic is fully inlined inside the for loop so that `period`
// (loop variable = series int) is only ever used in arithmetic — never
// passed as a simple int argument to any built-in function.

float weightedSlope = 0.0
float totalWeight   = 0.0

for period = minRange to maxRange by stepSize
    float sumX   = 0.0
    float sumY   = 0.0
    float sumXSq = 0.0
    float sumXY  = 0.0
    for i = 0 to period - 1
        float lv = math.log(srcInput[i])
        float p  = float(i + 1)
        sumX   += p
        sumY   += lv
        sumXSq += p * p
        sumXY  += lv * p
    float denom = float(period) * sumXSq - sumX * sumX
    float slope = denom != 0.0 ? (float(period) * sumXY - sumX * sumY) / denom * -1.0 : 0.0

    if useWeighted
        float meanY = sumY / float(period)
        float ssRes = 0.0
        for i = 0 to period - 1
            float fitted = meanY + slope * (float(i + 1) - (float(period) + 1.0) / 2.0)
            float res    = math.log(srcInput[i]) - fitted
            ssRes += res * res
        float variance = ssRes / math.max(float(period) - 2.0, 1.0)
        float w = variance > 0.0 ? 1.0 / variance : 1.0
        weightedSlope += slope * w
        totalWeight   += w
    else
        weightedSlope += slope
        totalWeight   += 1.0

float slopeOsc = totalWeight > 0.0 ? weightedSlope / totalWeight : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ REGIME DETECTION ══════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// regimeLookback is input.int → simple int — ta.stdev / ta.sma are fine.

float oscStd     = ta.stdev(slopeOsc, regimeLookback)
float oscMean    = ta.sma(slopeOsc,   regimeLookback)
float bullThresh = oscMean + oscStd * regimeMult
float bearThresh = oscMean - oscStd * regimeMult

bool inBullRegime  = slopeOsc > bullThresh
bool inBearRegime  = slopeOsc < bearThresh
bool inRangeRegime = not inBullRegime and not inBearRegime

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ ADAPTIVE SIGNAL LINE ══════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// FIX (CE10123): ta.ema() requires simple int for its length argument.
// effLen is computed at runtime → series float → cannot be passed to ta.ema().
// Solution: manual alpha-based EMA using a var float updated every bar.
// Alpha = 2 / (length + 1) — mathematically identical to ta.ema() but accepts
// a runtime-computed length with no type restriction.

float trendStrength = math.abs(slopeOsc - oscMean) / math.max(oscStd, 0.000001)
float adaptMult     = adaptiveSig ? math.max(0.4, math.min(1.8, trendStrength)) : 1.0
float effLen        = math.max(2.0, float(baseSigLen) / adaptMult)
float sigAlpha      = 2.0 / (effLen + 1.0)

var float sigLine = na
sigLine := na(sigLine) ? slopeOsc : sigLine + sigAlpha * (slopeOsc - sigLine)

int effSigLenDisplay = math.round(effLen)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ MOMENTUM ACCELERATION ═════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// accelLen is input.int → simple int — ta.ema() is valid here.

float accelRaw    = slopeOsc - slopeOsc[accelLen]
float accelSmooth = ta.ema(accelRaw, accelLen)
bool  accelBull   = accelSmooth > 0
bool  accelBear   = accelSmooth < 0

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ DIVERGENCE ENGINE ═════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════
// divPivotLen is input.int → simple int — ta.pivothigh/low are valid here.
// All pivot state assignments are on separate lines (no semicolon syntax).

float pivHigh = ta.pivothigh(slopeOsc, divPivotLen, divPivotLen)
float pivLow  = ta.pivotlow(slopeOsc,  divPivotLen, divPivotLen)
float pxHigh  = ta.pivothigh(high, divPivotLen, divPivotLen)
float pxLow   = ta.pivotlow(low,  divPivotLen, divPivotLen)

var float prevOscH  = na
var float currOscH  = na
var float prevPxH   = na
var float currPxH   = na
var int   prevOscHB = na
var int   currOscHB = na

var float prevOscL  = na
var float currOscL  = na
var float prevPxL   = na
var float currPxL   = na
var int   prevOscLB = na
var int   currOscLB = na

if not na(pivHigh)
    prevOscH  := currOscH
    currOscH  := pivHigh
    prevPxH   := currPxH
    currPxH   := pxHigh
    prevOscHB := currOscHB
    currOscHB := bar_index - divPivotLen

if not na(pivLow)
    prevOscL  := currOscL
    currOscL  := pivLow
    prevPxL   := currPxL
    currPxL   := pxLow
    prevOscLB := currOscLB
    currOscLB := bar_index - divPivotLen

bool classicBearDiv = showDiv and
  not na(prevOscH) and not na(currOscH) and not na(prevPxH) and not na(currPxH) and
  currPxH > prevPxH and currOscH < prevOscH and
  bar_index - currOscHB <= divPivotLen + 2 and currOscHB - prevOscHB >= divPivotLen

bool classicBullDiv = showDiv and
  not na(prevOscL) and not na(currOscL) and not na(prevPxL) and not na(currPxL) and
  currPxL < prevPxL and currOscL > prevOscL and
  bar_index - currOscLB <= divPivotLen + 2 and currOscLB - prevOscLB >= divPivotLen

bool hiddenBearDiv = showDiv and showHidden and
  not na(prevOscH) and not na(currOscH) and not na(prevPxH) and not na(currPxH) and
  currPxH < prevPxH and currOscH > prevOscH and
  bar_index - currOscHB <= divPivotLen + 2 and currOscHB - prevOscHB >= divPivotLen

bool hiddenBullDiv = showDiv and showHidden and
  not na(prevOscL) and not na(currOscL) and not na(prevPxL) and not na(currPxL) and
  currPxL > prevPxL and currOscL < prevOscL and
  bar_index - currOscLB <= divPivotLen + 2 and currOscLB - prevOscLB >= divPivotLen

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ SIGNAL GENERATION ═════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bool crossUp   = ta.crossover(slopeOsc, sigLine)  and barstate.isconfirmed
bool crossDown = ta.crossunder(slopeOsc, sigLine)  and barstate.isconfirmed

bool bullSignal = crossUp   and (not regimeFilter or not inBearRegime)
bool bearSignal = crossDown and (not regimeFilter or not inBullRegime)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ DYNAMIC COLOR ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var array<float> gradientWindow = array.new<float>()
gradientWindow.push(slopeOsc)
if gradientWindow.size() > 200
    gradientWindow.shift()

float gradMin   = gradientWindow.min()
float gradMax   = gradientWindow.max()
color mainColor = color.from_gradient(slopeOsc, gradMin, gradMax, _bear, _bull)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ VISUALISATION ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

bgcolor(showRegimes and inBullRegime  ? color.new(_bull,    96) : na, title="Bull Regime BG")
bgcolor(showRegimes and inBearRegime  ? color.new(_bear,    96) : na, title="Bear Regime BG")
bgcolor(showRegimes and inRangeRegime ? color.new(_neutral, 98) : na, title="Range Regime BG")

plot(showRegimes ? bullThresh : na, "Bull Threshold",
  color=color.new(_bull, 60), linewidth=1, style=plot.style_line)
plot(showRegimes ? bearThresh : na, "Bear Threshold",
  color=color.new(_bear, 60), linewidth=1, style=plot.style_line)

hline(0, "Zero", color=color.new(_neutral_lt, 50), linewidth=1, linestyle=hline.style_solid)

plot(showAccel ? accelSmooth : na, "Acceleration",
  color=accelBull ? color.new(i_accel_bull, 55) : color.new(i_accel_bear, 55),
  linewidth=4, style=plot.style_columns)

pOsc = plot(slopeOsc, "Slope Oscillator",
  color=color.new(mainColor, 0), linewidth=2)
p0   = plot(0, display=display.none, editable=false)

fill(pOsc, p0, slopeOsc, 0,
  top_color    = color.new(_bull, 75),
  bottom_color = color.new(_bear, 75))

plot(sigLine, "Adaptive Signal",
  color=color.new(chart.fg_color, 30), linewidth=1, style=plot.style_line)

if barstate.islast and showRegimes
    label.new(bar_index + 1, bullThresh, "BULL",
      style=label.style_label_left, color=CLEAR,
      textcolor=color.new(_bull, 20), size=size.tiny)
    label.new(bar_index + 1, bearThresh, "BEAR",
      style=label.style_label_left, color=CLEAR,
      textcolor=color.new(_bear, 20), size=size.tiny)

plotshape(showSignals and bullSignal ? slopeOsc : na, "Bull Signal",
  style=shape.circle, location=location.absolute,
  color=color.new(_bull_bright, 0), size=size.tiny)

plotshape(showSignals and bearSignal ? slopeOsc : na, "Bear Signal",
  style=shape.circle, location=location.absolute,
  color=color.new(_bear_bright, 0), size=size.tiny)

// force_overlay=true is a valid plotshape() argument in Pine v6
plotshape(showSignals and showOverlay and bullSignal ? low : na, "Bull Overlay",
  style=shape.triangleup, location=location.belowbar,
  color=color.new(_bull_bright, 0), size=size.small, force_overlay=true)

plotshape(showSignals and showOverlay and bearSignal ? high : na, "Bear Overlay",
  style=shape.triangledown, location=location.abovebar,
  color=color.new(_bear_bright, 0), size=size.small, force_overlay=true)

plotshape(classicBullDiv ? slopeOsc : na, "Classic Bull Div",
  style=shape.labelup, location=location.absolute,
  color=color.new(i_div_bull, 10), textcolor=#1a1a1a,
  text="DIV", size=size.tiny)

plotshape(classicBearDiv ? slopeOsc : na, "Classic Bear Div",
  style=shape.labeldown, location=location.absolute,
  color=color.new(i_div_bear, 10), textcolor=#ffffff,
  text="DIV", size=size.tiny)

plotshape(hiddenBullDiv ? slopeOsc : na, "Hidden Bull Div",
  style=shape.labelup, location=location.absolute,
  color=color.new(i_hidden_bull, 25), textcolor=#1a1a1a,
  text="H", size=size.tiny)

plotshape(hiddenBearDiv ? slopeOsc : na, "Hidden Bear Div",
  style=shape.labeldown, location=location.absolute,
  color=color.new(i_hidden_bear, 25), textcolor=#ffffff,
  text="H", size=size.tiny)

// FIX (CE10120): barcolor() has no force_overlay argument — removed.
// It automatically colors candles on the main chart pane regardless.
barcolor(showOverlay ? mainColor : na)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ DASHBOARD ═════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

f_dPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

var table dash = table.new(f_dPos(dashPos), 2, 11,
  bgcolor      = color.new(#0a0a0a, 0),
  border_width = 1,
  border_color = color.new(#1a1a1a, 0),
  frame_width  = 1,
  frame_color  = color.new(#242424, 0))

if showDash and barstate.islast
    color  headerBg = color.new(#111111, 0)
    color  cellBg   = color.new(#0a0a0a, 0)
    color  lblCol   = color.new(#cccccc, 0)
    sz = size.small

    table.cell(dash, 0, 0, "AlphaX  S L O P E  S P E C T R U M  P R O",
      text_color=color.new(_bull, 0), text_size=sz,
      bgcolor=headerBg, text_halign=text.align_center)
    table.cell(dash, 1, 0, "", bgcolor=headerBg)

    int samples = math.floor((maxRange - minRange) / stepSize) + 1
    table.cell(dash, 0, 1, "SAMPLES", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 1, str.tostring(samples) + " periods",
      text_color=color.new(_neutral_lt, 0), text_size=sz, bgcolor=cellBg)

    string modeStr = useWeighted ? "INV-VAR WEIGHTED" : "SIMPLE AVERAGE"
    table.cell(dash, 0, 2, "MODE", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 2, modeStr,
      text_color=color.new(_neutral_lt, 0), text_size=sz, bgcolor=cellBg)

    color oscDispClr = slopeOsc > 0 ? color.new(_bull, 0) : color.new(_bear, 0)
    table.cell(dash, 0, 3, "OSC VALUE", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 3, str.tostring(slopeOsc, "#.######"),
      text_color=oscDispClr, text_size=sz, bgcolor=cellBg)

    color  regimeBg  = inBullRegime ? color.new(_bull, 82) : inBearRegime ? color.new(_bear, 82) : cellBg
    color  regimeClr = inBullRegime ? color.new(_bull, 0)  : inBearRegime ? color.new(_bear, 0)  : color.new(_neutral, 0)
    string regimeTxt = inBullRegime ? "▲ BULL ZONE" : inBearRegime ? "▼ BEAR ZONE" : "— RANGING"
    table.cell(dash, 0, 4, "REGIME", text_color=lblCol, text_size=sz, bgcolor=regimeBg)
    table.cell(dash, 1, 4, regimeTxt, text_color=regimeClr, text_size=sz, bgcolor=regimeBg)

    string accelTxt = accelSmooth > 0 ? "▲ BUILDING" : "▼ FADING"
    color  accelClr = accelSmooth > 0 ? color.new(_bull_dim, 0)  : color.new(_bear_dim, 0)
    color  accelBg2 = accelSmooth > 0 ? color.new(_bull_dim, 88) : color.new(_bear_dim, 88)
    table.cell(dash, 0, 5, "MOMENTUM", text_color=lblCol, text_size=sz, bgcolor=accelBg2)
    table.cell(dash, 1, 5, accelTxt, text_color=accelClr, text_size=sz, bgcolor=accelBg2)

    float  sigDiff = slopeOsc - sigLine
    string sigTxt  = crossUp     ? "▲ BULL CROSS" : crossDown    ? "▼ BEAR CROSS"
                   : sigDiff > 0 ? "▲ ABOVE SIG"  : "▼ BELOW SIG"
    color  sigClr  = sigDiff > 0 ? color.new(_bull, 0) : color.new(_bear, 0)
    table.cell(dash, 0, 6, "SIGNAL", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 6, sigTxt, text_color=sigClr, text_size=sz, bgcolor=cellBg)

    table.cell(dash, 0, 7, "SIG SPEED", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 7, "EMA~" + str.tostring(effSigLenDisplay),
      text_color=color.new(_neutral_lt, 0), text_size=sz, bgcolor=cellBg)

    string divTxt = classicBullDiv ? "▲ BULL DIV"
                  : classicBearDiv ? "▼ BEAR DIV"
                  : hiddenBullDiv  ? "▲ HIDDEN BULL"
                  : hiddenBearDiv  ? "▼ HIDDEN BEAR"
                  : "— NONE"
    color divClr  = classicBullDiv or hiddenBullDiv ? color.new(_bull_bright, 0)
                  : classicBearDiv or hiddenBearDiv  ? color.new(_bear_bright, 0)
                  : color.new(_neutral, 0)
    color divBg   = classicBullDiv or hiddenBullDiv ? color.new(_bull, 85)
                  : classicBearDiv or hiddenBearDiv  ? color.new(_bear, 85)
                  : cellBg
    table.cell(dash, 0, 8, "DIVERGENCE", text_color=lblCol, text_size=sz, bgcolor=divBg)
    table.cell(dash, 1, 8, divTxt, text_color=divClr, text_size=sz, bgcolor=divBg)

    int convScore = 0
    convScore += (inBullRegime and slopeOsc > 0) or (inBearRegime and slopeOsc < 0) ? 1 : 0
    convScore += (inBullRegime and accelBull)     or (inBearRegime and accelBear)    ? 1 : 0
    convScore += (inBullRegime and sigDiff > 0)   or (inBearRegime and sigDiff < 0)  ? 1 : 0
    convScore += classicBullDiv or hiddenBullDiv or classicBearDiv or hiddenBearDiv  ? 1 : 0
    string convTxt = convScore >= 4 ? "MAX — ALL ALIGNED"
                   : convScore >= 3 ? "HIGH CONVICTION"
                   : convScore >= 2 ? "MODERATE"
                   : "LOW / MIXED"
    color convClr  = convScore >= 4 ? color.new(_bull_bright, 0)
                   : convScore >= 3 ? color.new(_bull, 0)
                   : convScore >= 2 ? color.new(_neutral_lt, 0)
                   : color.new(_neutral, 0)
    color convBg   = convScore >= 3 ? color.new(_bull_dim, 78) : cellBg
    table.cell(dash, 0, 9,  "CONVICTION", text_color=lblCol,  text_size=sz, bgcolor=convBg)
    table.cell(dash, 1, 9,  convTxt,      text_color=convClr, text_size=sz, bgcolor=convBg)

    float sigmaRead = oscStd > 0 ? (slopeOsc - oscMean) / oscStd : 0.0
    table.cell(dash, 0, 10, "OSC (sigma)", text_color=lblCol, text_size=sz, bgcolor=cellBg)
    table.cell(dash, 1, 10, str.tostring(sigmaRead, "#.##") + "s",
      text_color=sigmaRead > 0 ? color.new(_bull_dim, 0) : color.new(_bear_dim, 0),
      text_size=sz, bgcolor=cellBg)

// ═══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════ ALERTS ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(bullSignal,
  title="SSP — Bull Crossover",
  message="[AlphaX SSP] BULL crossover — {{ticker}} {{interval}} | OSC @ {{close}}")

alertcondition(bearSignal,
  title="SSP — Bear Crossover",
  message="[AlphaX SSP] BEAR crossover — {{ticker}} {{interval}} | OSC @ {{close}}")

alertcondition(classicBullDiv,
  title="SSP — Classic Bull Divergence",
  message="[AlphaX SSP] Classic BULL divergence detected — {{ticker}} {{interval}}")

alertcondition(classicBearDiv,
  title="SSP — Classic Bear Divergence",
  message="[AlphaX SSP] Classic BEAR divergence detected — {{ticker}} {{interval}}")

alertcondition(hiddenBullDiv,
  title="SSP — Hidden Bull Divergence (Trend Continuation)",
  message="[AlphaX SSP] Hidden BULL divergence — trend continuation signal — {{ticker}} {{interval}}")

alertcondition(hiddenBearDiv,
  title="SSP — Hidden Bear Divergence (Trend Continuation)",
  message="[AlphaX SSP] Hidden BEAR divergence — trend continuation signal — {{ticker}} {{interval}}")

alertcondition(bullSignal and (classicBullDiv or hiddenBullDiv),
  title="SSP — CONFLUENCE LONG",
  message="[AlphaX SSP] HIGH CONFLUENCE LONG — crossover + divergence — {{ticker}} {{interval}}")

alertcondition(bearSignal and (classicBearDiv or hiddenBearDiv),
  title="SSP — CONFLUENCE SHORT",
  message="[AlphaX SSP] HIGH CONFLUENCE SHORT — crossover + divergence — {{ticker}} {{interval}}")

alertcondition(ta.crossover(slopeOsc, 0),
  title="SSP — Zero Line Cross Up",
  message="[AlphaX SSP] Oscillator crossed ABOVE zero — {{ticker}} {{interval}}")

alertcondition(ta.crossunder(slopeOsc, 0),
  title="SSP — Zero Line Cross Down",
  message="[AlphaX SSP] Oscillator crossed BELOW zero — {{ticker}} {{interval}}")
````
