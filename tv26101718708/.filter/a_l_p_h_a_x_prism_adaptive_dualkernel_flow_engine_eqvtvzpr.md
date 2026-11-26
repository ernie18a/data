# [ A L P H A X ] PRISM - Adaptive Dual-Kernel Flow Engine

- url: https://www.tradingview.com/script/eqvTvZpR-A-L-P-H-A-X-PRISM-Adaptive-Dual-Kernel-Flow-Engine/
- type: indicator
- pine_id: PUB;0b49310a13c341aeac670468a2231657
- version: 1.0

## Description

[b]AlphaX PRISM — Adaptive Dual-Kernel Flow Engine: Nadaraya-Watson Kernel Regression, Residual Band System, Pivot Divergence Detection, Z-Score Fade & 4-Setup Regime-Gated Confluence Engine[/b]

AlphaX PRISM is a professional-grade adaptive trend and mean-reversion system built on a mathematically distinct foundation from every other indicator in the AlphaX suite. Where VECTOR uses an Efficiency Ratio and Choppiness Index to classify regimes and a KAMA line as the trend reference, PRISM applies non-parametric kernel regression — specifically a Nadaraya-Watson weighted estimate — to compute a statistically optimal smooth estimate of the price process itself. The result is not a moving average in the traditional sense. It is a regression estimate that weights each historical price observation by its distance from the present using a configurable kernel function, producing a slow kernel (primary trend estimate) and a fast kernel (momentum layer) whose spread creates a real-time directional bias measure fundamentally different from EMA crossover systems. Residual bands built from the standard deviation of price minus the kernel estimate — not from the kernel itself — provide statistically grounded dynamic envelopes that scale with actual price noise rather than arbitrary ATR multiples. Four regime-gated setup types — Trend Flow Break, Kernel Pullback, Z-Score Fade, and Pivot Divergence Reversal — fire through a 7-layer confluence engine that checks both kernel-specific signals and macro filter alignment simultaneously. Designed for traders who want institutional-grade statistical price modeling applied to practical signal generation across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]The Kernel Engine — Nadaraya-Watson Regression[/b]

The foundational difference between PRISM and every other AlphaX indicator is the core price estimate. All other systems use variants of exponential or adaptive moving averages — weighted sums of past prices with exponentially decaying weights. PRISM uses a [b]Nadaraya-Watson kernel estimator[/b] — a non-parametric regression technique that estimates the true underlying price process at any point as a kernel-weighted average of all observations in the lookback window.

[b]What kernel regression actually does:[/b]
Standard moving averages assign weights by time elapsed — more recent bars get more weight, older bars get less, following an exponential decay curve. The NW estimator assigns weights by [i]position[/i] — how many bars ago a price occurred relative to the current bar — using a smooth, symmetric kernel function. This produces an estimate that minimizes the squared distance between the estimate and all observed prices, weighted by position.

[b]Why this produces a superior trend estimate:[/b] A kernel regression estimate adapts its response to the local density of price observations rather than following a fixed mathematical formula. In fast-moving price environments with large bar movements, the kernel naturally places more emphasis on nearby bars. In slow, thin environments, older observations carry more proportional weight. The result is an estimate that is simultaneously smoother than an EMA of the same effective period and more structurally faithful to the underlying price movement.

[b]Three kernel types available:[/b]

[b]Gaussian (default):[/b]
Uses the normal distribution probability density function as the weight function. Weights decay as a bell curve — bars near the center of the lookback carry the most weight, tailing off smoothly toward zero at the edges. The Gaussian kernel produces the smoothest estimate and is optimal for normally distributed price noise. It never fully zeroes out any observation in the window.

[b]Epanechnikov:[/b]
A parabolic weight function — (1 - (i/h)²) — that reaches exactly zero at the bandwidth boundary. More computationally efficient than Gaussian and optimal in a mean-squared-error sense under certain assumptions. Produces a slightly sharper response to local price movements than Gaussian.

[b]Tricube:[/b]
The weight function used in LOESS regression — (1 - |i/h|³)³. A smooth, zero-bounded kernel that falls off more steeply than Gaussian near the boundary, producing an estimate that is highly responsive to recent prices while cleanly ignoring anything beyond the bandwidth boundary.

The kernel type is selectable from settings. For most instruments and timeframes, Gaussian is recommended for its smoothness. Epanechnikov or Tricube may be preferable when faster response to recent price action is desired.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Adaptive Bandwidth — Scaling With Volatility[/b]

The bandwidth parameter h controls the effective "window width" of the kernel — how many observations contribute meaningfully to each estimate. Larger h = smoother, slower response. Smaller h = more reactive, noisier.

[b]The fixed bandwidth problem:[/b] A bandwidth calibrated for a low-volatility environment is too reactive during high-volatility periods, producing noisy, whipsawing estimates. A bandwidth calibrated for high-volatility is too slow during quiet periods, lagging price movements significantly.

[b]PRISM's adaptive bandwidth solution:[/b]
When Adaptive Bandwidth is enabled (default: on), the effective bandwidth is scaled by the current ATR's percentile rank relative to its own history over the configured lookback (default: 100 bars). The scaling formula produces:

[list]
[*][b]Low ATR percentile (quiet market)[/b] — bandwidth scales down toward the Adaptive Min Scale (default: 0.80). The kernel becomes more responsive, tracking the slower price movement more closely
[*][b]High ATR percentile (volatile market)[/b] — bandwidth scales up toward the Adaptive Max Scale (default: 1.25). The kernel becomes smoother, filtering out the larger noise inherent in high-volatility conditions
[/list]

[b]Bandwidth shift alert:[/b] When the effective bandwidth changes by 12% or more from the previous bar, a bandwidth shift event is detected and flagged on the dashboard. This indicates a significant volatility regime transition — the adaptive system is meaningfully adjusting its estimate parameters, which is itself information about the market's current character.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Dual-Kernel Architecture — Slow and Fast Estimates[/b]

PRISM runs two kernel estimates simultaneously, each with a different effective bandwidth:

[b]Slow Kernel (Primary Estimate):[/b]
The primary trend estimate computed at the full adaptive bandwidth. This is the principal signal line — the statistically optimal estimate of the underlying price trend. The residual bands are built relative to the slow kernel. The pullback setup watches price return to the slow kernel. The slow kernel is plotted as a purple line in Bands and Line visual modes.

[b]Fast Kernel (Momentum Layer):[/b]
A second kernel estimate computed at a fraction of the slow kernel's bandwidth (default: 0.55× the slow bandwidth). This produces a more reactive estimate that leads the slow kernel during momentum shifts. The fast kernel's proximity to or divergence from the slow kernel creates the [b]Kernel Spread[/b] — the primary directional bias indicator in PRISM.

[b]Kernel Spread:[/b]
`Kernel Spread = Fast Kernel − Slow Kernel`

When positive and growing (spreadBull): the fast kernel is above the slow kernel and the gap is widening — upward momentum is accelerating.
When negative and falling (spreadBear): the fast kernel is below and the gap is widening downward — bearish momentum is accelerating.
When near zero: the two estimates have converged — no directional momentum bias is present.

The spread is displayed on the dashboard with a + or - sign and colored by its directional state. It is a prerequisite for Setups A and B — trend-following entries only fire when the spread confirms the signal direction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Residual Bands — Statistically Grounded Envelopes[/b]

The residual bands in PRISM are fundamentally different from standard Bollinger Bands or ATR bands. They are built from the [b]residuals[/b] — the differences between actual price and the slow kernel estimate — not from the price series itself.

[b]Residual = Close − Slow Kernel[/b]

The standard deviation of these residuals over the band lookback period (default: 24 bars) gives sigma — the statistically appropriate measure of how much price typically deviates from the kernel estimate. The bands are then:

[list]
[*][b]Upper Band = Slow Kernel + (Band Multiplier × σ)[/b]
[*][b]Lower Band = Slow Kernel − (Band Multiplier × σ)[/b]
[/list]

[b]Why residual-based bands are superior:[/b] Bollinger Bands are built from the standard deviation of price itself — which includes both the trend component and the noise component. In a strongly trending market, most of the "deviation" in Bollinger Bands is actually trend — the bands widen dramatically and the upper/lower band crossings lose their mean-reversion significance. PRISM's residual bands remove the trend component first and only measure the standard deviation of the remaining noise. This means the bands genuinely represent deviation from the estimated price trend, not deviation from a lagging average.

[b]Z-Score:[/b]
The current residual divided by sigma: `Z-Score = Residual / σ`. A Z-Score of +1.35 means price is currently 1.35 standard deviations above the kernel estimate — more than one standard deviation above expected. This is the metric that gates Setup C (Z-Score Fade) — a configurable minimum Z-Score is required before a mean-reversion fade signal can fire.

[b]σ Width:[/b]
The current sigma value is displayed on the dashboard — a real-time measure of the current price noise level relative to the kernel estimate. Rising sigma indicates price is deviating increasingly from the kernel trend, falling sigma indicates price is tightening around the kernel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Regime Classification — Two-Metric System[/b]

PRISM uses two independent measurements to determine the current regime, augmented by the kernel spread itself.

[b]Efficiency Ratio (ER):[/b]
Identical to the VECTOR implementation — net directional price change divided by total path traveled over the lookback period. High ER = efficient directional movement = trending. Low ER = inefficient oscillation = choppy or ranging.

[b]Choppiness Index (CI):[/b]
The logarithmic measure of how efficiently the period's ATR sum is packed into the high-low range. Above the configured threshold (default: 61.0) = stand aside (CHOP regime), blocking all signals.

[b]Kernel Spread as regime filter:[/b]
For PRISM's Trend regime classification, the kernel spread must also exceed a minimum threshold (0.15× sigma) to distinguish genuine momentum bias from flat spread near zero. This prevents Trend regime classification when the two kernels have converged — a state that typically precedes a direction change rather than a trend continuation.

[b]Four regimes:[/b]
[list]
[*][b]CHOP (0)[/b] — CI above threshold. All signals blocked. Dashboard: ⛔ CHOP
[*][b]TREND BULL (1)[/b] — not chop, ER above trend minimum, kernel spread positive and above minimum. Dashboard: ▲ TREND BULL
[*][b]TREND BEAR (2)[/b] — not chop, ER above minimum, kernel spread negative and below minimum. Dashboard: ▼ TREND BEAR
[*][b]BALANCE (3)[/b] — not chop, ER or spread conditions for trend not met. Dashboard: ◆ BALANCE
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔀 [b]Pivot Divergence Detection — Price vs Kernel[/b]

PRISM implements a [b]pivot-based divergence system[/b] that is significantly more robust than the slope comparison divergence used in most oscillator-based indicators.

[b]The pivot divergence method:[/b]
Standard divergence detection compares current price slope to current oscillator slope — a noisy, easily-fooled method that produces many false signals. PRISM instead identifies confirmed price pivots (using a configurable pivot length, default: 5 bars) and compares the price level at each new pivot to the slow kernel value at the same pivot bar.

[b]Bullish pivot divergence:[/b]
[list]
[*]Price forms a new pivot low lower than the previous pivot low — a genuine lower low in price
[*]The slow kernel at the current pivot low bar is [i]higher[/i] than it was at the previous pivot low — the kernel estimate is making a higher low while price makes a lower low
[*]Price is currently near or below the lower residual band (within 1σ) — confirming the divergence is occurring at a structurally meaningful oversold level
[/list]

[b]Bearish pivot divergence:[/b]
[list]
[*]Price forms a new pivot high higher than the previous pivot high — a genuine higher high in price
[*]The slow kernel at the current pivot high bar is lower than at the previous pivot high — kernel making a lower high while price makes a higher high
[*]Price is near or above the upper residual band
[/list]

[b]Why kernel-based divergence is more reliable than oscillator divergence:[/b] The slow kernel is a statistically optimal estimate of the price trend. When price makes a new extreme but the kernel's trend estimate does not confirm that extreme — actually reversing direction relative to the prior swing — it indicates that the underlying price process, stripped of noise, is already diverging from the price surface. This is a stronger divergence signal than any oscillator comparison because the kernel literally measures the same thing as price, just without noise.

[b]Divergence cooldown:[/b] A minimum cooldown between consecutive divergence detections (default: 8 bars) prevents the same divergence condition from generating multiple signals during a prolonged extreme.

[b]Divergence markers:[/b] Semi-transparent diamond shapes appear below (bull) or above (bear) bars where divergence is detected but a full entry signal has not fired. These allow you to track divergence conditions developing on the chart even before the complete signal conditions are met.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Four Regime-Gated Setup Types[/b]

PRISM implements four distinct entry setups, each gated to the appropriate regime state and designed to exploit a different market condition detected by the kernel system.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup A — Flow Break (Trend regime only)[/b]

A trend-following breakout entry that fires when price crosses through the residual band with kernel momentum confirmation.

[b]Long conditions:[/b]
[list]
[*]Regime is Trend Bull (regime == 1)
[*]Price closes above the upper residual band — a statistically significant positive deviation from the kernel trend
[*]Kernel spread is positive and accelerating (spreadBull) — fast kernel is above slow and the gap is widening, confirming the momentum behind the break
[*]A qualifying bull rejection candle (close > open, lower wick above 52% of range) is present
[/list]

[b]The rationale:[/b] A close above the upper residual band in a Trend Bull regime means price has moved more than one standard deviation above the kernel trend estimate with directional kernel momentum behind it. This is not a mean-reversion setup — in a trending regime, upper band closes are continuation signals, not exhaustion signals. The kernel spread confirmation ensures the break has genuine momentum backing rather than being a noise spike into the band.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup B — Kernel Pullback (Trend regime only)[/b]

The primary pullback entry — price retracing to the slow kernel with momentum still intact.

[b]Long conditions:[/b]
[list]
[*]Regime is Trend Bull
[*]Price touches the slow kernel from above — the low of the bar reaches within 0.25× ATR of the kernel line
[*]Price closes above the kernel — confirming the touch was a rejection, not a breakdown through the kernel
[*]Kernel spread is still positive and accelerating — the underlying momentum has not reversed despite the pullback
[*]A qualifying bull rejection candle confirms
[/list]

[b]The rationale:[/b] In a trend regime, the slow kernel is the trend's statistical backbone — the optimal estimate of where the underlying price process is. A pullback to the kernel during a trend is the equivalent of pulling back to the trend's center — the lowest-risk continuation entry with the widest statistical support. The spread confirmation ensures the trend's momentum is intact at the time of the touch.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup C — Z-Score Fade (Balance regime only)[/b]

A statistically informed mean-reversion entry using the residual Z-Score to identify genuine band extremes.

[b]Short fade conditions:[/b]
[list]
[*]Regime is Balance (regime == 3)
[*]Z-Score is above the configured minimum (default: 1.35) — price is more than 1.35 standard deviations above the kernel estimate, a statistically elevated extension
[*]A qualifying bear rejection candle confirms the rejection at the extreme
[/list]

[b]Why the Z-Score threshold is the key gate:[/b] Any band touch could trigger a naive fade signal. The Z-Score requirement ensures only genuine statistical extremes are faded — points where price has deviated far enough from the kernel estimate that mean-reversion is statistically probable. The 1.35σ threshold balances frequency and quality — above this level, approximately 82% of normal distribution probability mass is below the current price, making continuation significantly less likely than reversion.

[b]Balance-only gating:[/b] In a Trend regime, upper band touches in a bull trend are continuation signals, not exhaustion (as Setup A exploits). Setup C is therefore hard-gated to Balance regime only — mean-reversion entries are only valid when the market is genuinely ranging, not when a trend is carrying price to the band.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup D — Divergence Reversal (Balance or opposing Trend regime)[/b]

The highest-conviction reversal entry, combining the pivot divergence signal with a band extreme and rejection candle.

[b]Long conditions:[/b]
[list]
[*]A qualifying bullish pivot divergence has been detected (price lower low, kernel higher low, near lower band)
[*]A qualifying bull rejection candle confirms on the divergence bar
[*]Regime is Balance OR Trend Bear (regime == 3 or regime == 2) — the setup is intended for counter-trend reversals, not trend continuation
[/list]

[b]Why divergence setups fire in opposing trend or balance regimes:[/b] A bullish divergence at the lower band during a Trend Bear regime is a potential trend exhaustion and reversal signal. In Balance, it is a standard oscillation reversal. Both contexts are appropriate for a divergence-based entry. A bullish divergence during Trend Bull would be anomalous — if the kernel is making higher lows while price makes lower lows in a bull trend, the trend is likely still intact and the divergence is noise rather than reversal signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 7-Layer Confluence Engine[/b]

Every signal across all four setup types is scored through the same 7-layer system. The default minimum is 5 of 7.

[b]Layer 1 — Regime and Kernel Spread Direction (1 point):[/b]
Awards 1 point when either the regime confirms the signal direction (Trend Bull for longs, Trend Bear for shorts) or the kernel spread is directionally aligned. This layer is satisfied by either condition, making it achievable even in Balance regime when the spread is directional.

[b]Layer 2 — Z-Score and Spread Positioning (1 point):[/b]
Awards 1 point when the residual Z-Score is positive (price above kernel) for longs, or negative for shorts; or when the kernel spread is directionally positive or negative respectively. Confirms the price is on the structurally correct side of the kernel estimate.

[b]Layer 3 — HTF Bias (1 point):[/b]
Higher timeframe EMA alignment agrees with the signal direction. The macro institutional flow confirmation layer.

[b]Layer 4 — Volume Expansion (1 point):[/b]
Current bar volume exceeds the volume moving average by the configured minimum multiplier (default: 1.05×). Confirms genuine participation on the signal bar.

[b]Layer 5 — Rejection Candle (1 point):[/b]
A qualifying bull or bear rejection candle — bullish close with lower wick exceeding 52% of range, or bearish close with upper wick exceeding 52%. The candle quality confirmation that price genuinely rejected at the relevant level.

[b]Layer 6 — Non-Chop Regime (1 point):[/b]
Market is not in Chop regime. Also enforced as a hard gate — no signal fires in Chop regardless of score.

[b]Layer 7 — Setup Type Active (1 point):[/b]
Any of the four enabled setup types has fired on the current bar. Both a scoring layer and a hard prerequisite — at least one setup type must qualify for a signal to exist.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 16-row real-time dashboard displays the complete internal state across four sections.

[b]KERNEL[/b]
[list]
[*][b]Regime[/b] — current regime: ⛔ CHOP, ▲ TREND BULL, ▼ TREND BEAR, or ◆ BALANCE
[*][b]Kernel Type[/b] — the active kernel function: Gaussian, Epanechnikov, or Tricube
[*][b]Bandwidth h[/b] — the current effective slow kernel bandwidth with "adap" suffix when adaptive scaling is active. Orange when a bandwidth shift event has been detected
[*][b]Flow Spread[/b] — the current Fast Kernel minus Slow Kernel spread value with + or - sign. Yellow-green when spreadBull, red when spreadBear
[/list]

[b]BANDS[/b]
[list]
[*][b]Z-Score[/b] — the current residual Z-Score. Orange when above the fade minimum threshold, indicating a statistically stretched condition
[*][b]σ Width[/b] — the current sigma value in price terms — the standard deviation of residuals, displayed as a price distance
[*][b]Divergence[/b] — ▲ BULL DIV or ▼ BEAR DIV when a pivot divergence is currently active, — otherwise
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — ▲ BULL, ▼ BEAR, or — FLAT
[*][b]Chop Index[/b] — live Choppiness Index value. Orange when in the stand-aside zone
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Bull Score[/b] — live 0–7 score. Background highlights yellow-green when threshold met and not in chop
[*][b]Bear Score[/b] — live 0–7 score. Background highlights red when threshold met and not in chop
[/list]

[b]Live confluence label:[/b] During non-chop regimes, a small B x/7 · S x/7 label appears near the slow kernel line on the current bar, updating in real time.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System — Three Visual Modes[/b]

PRISM provides three visual modes selectable from settings, allowing you to optimize the chart display for your preferred analysis style.

[b]Bands Mode (default):[/b]
Shows both the slow kernel line and the upper/lower residual bands as a channel around the kernel. The band fill creates a purple-tinted envelope. Setup A and C reference levels are immediately visible. Best for band-aware trading and Z-Score fade entries.

[b]Line Mode:[/b]
Shows only the slow kernel line without bands. Clean, minimal display for traders who prefer to use the kernel line purely as a trend reference and support/resistance level for pullback entries.

[b]Flow Mode:[/b]
Shows both the fast and slow kernel lines simultaneously without the residual bands. The spread between the two lines is directly visible on the chart — the gap between cyan (fast) and purple (slow) is the visual representation of the Flow Spread. Best for traders who want to monitor momentum through the kernel spread rather than band positioning.

[b]Additional visuals:[/b]
[list]
[*][b]Slow Kernel Line (purple)[/b] — the primary trend estimate, primary reference for Setup B pullbacks
[*][b]Fast Kernel Line (cyan, Flow Mode only)[/b] — the momentum layer, its position relative to the slow kernel shows the current spread
[*][b]Upper/Lower Residual Bands[/b] — statistically computed envelopes around the kernel. Setup A crossovers and Setup C fade levels
[*][b]Band Fill (purple tint)[/b] — semi-transparent fill between bands when enabled
[*][b]▲ Triangle (below bar)[/b] — long signal. All conditions confirmed
[*][b]▼ Triangle (above bar)[/b] — short signal
[*][b]◆ Diamond (semi-transparent, below/above)[/b] — divergence detected but full signal not yet confirmed. Pre-signal awareness
[*][b]SL Guide (red dotted circles)[/b] — stop loss below the lower band or bar low minimum, plus ATR buffer
[*][b]TP Guide (yellow-green dotted circles)[/b] — dynamic R-multiple target
[*][b]Bar coloring (optional, off by default)[/b] — bars colored by kernel bias direction when enabled
[*][b]Live confluence label[/b] — B x/7 · S x/7 near the slow kernel on the current bar
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX PRISM — Step by Step[/b]

[b]Step 1 — Check Regime and Kernel State[/b]
[list]
[*]Dashboard Regime row is the first check. ⛔ CHOP means no trades. ▲ TREND BULL or ▼ TREND BEAR means Setup A and B are available. ◆ BALANCE means Setup C and D are available
[*]Check Flow Spread — is it confirming the regime direction? In Trend Bull, the spread should be positive and yellow-green. A Trend Bull regime with a flat or negative spread is a weakening trend that may be transitioning to Balance
[*]Note the Z-Score — is it near or beyond the fade threshold? A Z-Score above +1.35 in Balance regime means Setup C short fade conditions are approaching. Below -1.35 means Setup C long fade is approaching
[*]Check Divergence row — if it shows ▲ BULL DIV or ▼ BEAR DIV, a reversal setup is potentially developing. Watch for the rejection candle confirmation
[/list]

[b]Step 2 — Identify the Active Setup Type[/b]
[list]
[*]Trend Bull: watch for price to reach the slow kernel line from above (Setup B) or close above the upper band with spread confirmation (Setup A)
[*]Balance: watch Z-Score. When it reaches ±1.35 and the rejection candle fires, Setup C is the play
[*]Any regime where divergence is active: Setup D — the rejection candle at the band extreme is the trigger
[/list]

[b]Step 3 — Enter on the PRISM Signal[/b]
[list]
[*]A ▲ triangle confirms the full confluence stack is met. The SL guide is below the lower band and bar low minimum — the structural invalidation level
[*]The TP guide is at the R-multiple target. For Setup A trend breaks, consider extending the target toward previous swing highs if the trend is strongly established
[*]For Setup D divergence entries, the target is typically the kernel line itself (the mean) — the Z-Score fading back toward zero is the natural first target
[/list]

[b]Step 4 — Manage with Kernel State[/b]
[list]
[*]During a Trend regime trade, watch the Flow Spread on the dashboard. When the spread begins narrowing (converging toward zero), trend momentum is fading — begin preparing to exit
[*]A bandwidth shift (Bandwidth h shows orange) during a trade means volatility is changing significantly. Reassess the trade's context — the kernel is recalibrating
[*]If regime transitions to Chop during an open trade, close immediately — the market character no longer supports the setup's thesis
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Regime shows ⛔ CHOP[/b] — the Choppiness Index has crossed the stand-aside threshold. All signals are blocked. This is the most important dashboard reading in PRISM
[*][b]Bandwidth h shows orange (bandwidth shift)[/b] — the adaptive bandwidth is shifting significantly, indicating a volatility regime transition. The kernel is recalibrating and its estimates may be temporarily less reliable
[*][b]Flow Spread is near zero in either direction[/b] — when the fast and slow kernels have converged, there is no directional momentum bias. Setup A and B require a spreading kernel; a flat spread means the market has no directional commitment at the kernel level
[*][b]Z-Score is between -1.0 and +1.0 in Balance regime[/b] — price is near the kernel estimate, well within one standard deviation. Setup C fade signals require statistical stretch beyond 1.35σ — entering fades too close to the kernel means the edge from Z-Score mean reversion is absent
[*][b]Divergence markers appear but no rejection candle forms for multiple bars[/b] — a divergence without a confirming candle is a warning, not a signal. Do not enter on the divergence alone; wait for the full Setup D conditions including the rejection candle and minimum confluence score
[*][b]Regime alternates rapidly between Trend Bull and Balance or Balance and Chop[/b] — unstable regime cycling indicates a transitional market where neither trending nor ranging playbooks have sustained applicability. Reduce size or wait for a clear, sustained regime
[/list]

[b]The ideal PRISM setup:[/b]
[list]
[*]Trend regime sustained for 10+ bars with consistent spread direction
[*]Flow Spread positive and growing (Trend Bull) — the momentum is actively building
[*]HTF Bias aligned with regime direction
[*]Price retracing cleanly to the slow kernel (Setup B) — touch within 0.25× ATR with a qualifying rejection pin bar
[*]Volume above average, confirming institutional participation at the kernel level
[*]Confluence score at 6/7 or 7/7
[*]Z-Score near zero at the pullback bar — confirming the pullback reached the statistical center, not an overextended entry
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🔬 Nadaraya-Watson kernel regression — non-parametric weighted estimate of the underlying price process using Gaussian, Epanechnikov, or Tricube kernel functions
[*]⚙ Adaptive bandwidth scaling — effective bandwidth scales by ATR percentile rank, tightening in quiet markets and widening in volatile conditions
[*]⚡ Dual-kernel architecture — slow kernel (primary trend estimate) and fast kernel (momentum layer) whose spread creates a real-time directional bias measure
[*]📊 Residual-based bands — bands computed from the standard deviation of price-minus-kernel residuals, not from price itself. Statistically superior to ATR or price-deviation bands
[*]📉 Z-Score display — live residual Z-Score showing how many standard deviations price has deviated from the kernel estimate, gating the mean-reversion fade setup
[*]🔀 Pivot-based divergence detection — price pivot extremes compared to kernel estimate at same bar, more robust than oscillator slope divergence
[*]◆ Divergence pre-signal markers — semi-transparent diamonds show developing divergence conditions before the full signal fires
[*]🏷 Four regime-gated setup types — Setup A (Flow Break, trend only), Setup B (Kernel Pullback, trend only), Setup C (Z-Score Fade, balance only), Setup D (Divergence Reversal, balance or opposing trend)
[*]📡 Bandwidth shift detection — alerts when adaptive bandwidth changes by 12%+ in a single bar, signaling a volatility regime transition
[*]🎨 Three visual modes — Bands (channel display), Line (clean kernel only), Flow (dual-kernel spread visualization)
[*]📊 Optional bar coloring — bars colored by kernel bias direction, off by default for chart cleanliness
[*]🧠 7-layer confluence engine — Regime/Spread, Z-Score/Positioning, HTF Bias, Volume, Rejection Candle, Non-Chop, and Setup Type scored every bar
[*]📊 16-row live dashboard — Regime, Kernel Type, Bandwidth h, Flow Spread, Z-Score, σ Width, Divergence, HTF Bias, Chop Index, and Confluence scores updated in real time
[*]🔔 6 alert conditions — long/short entry, chop warning, bull/bear divergence, bandwidth shift
[*]⚙ Fully configurable — kernel type, lookback window, base bandwidth, adaptive scaling range, output EMA smoothing, fast kernel bandwidth multiplier, residual band multiplier and lookback, Z-Score fade minimum, ER and CI regime thresholds, divergence pivot length and cooldown, all four setup enables, HTF timeframe and EMAs, volume filter, session, SL/TP parameters, visual mode, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Kernel Engine[/b]
[list]
[*]Kernel Type — Gaussian / Epanechnikov / Tricube. The weight function applied in the NW estimate
[*]Lookback Window — the number of historical bars included in the kernel estimate (default: 40)
[*]Base Bandwidth (h) — the base bandwidth parameter controlling effective kernel width (default: 6.0)
[*]Adaptive Bandwidth (ATR percentile) — when on, scales h by ATR percentile rank (default: on)
[*]ATR Length — lookback for the ATR calculation used in adaptive scaling (default: 14)
[*]ATR Percentile Lookback — history window for ATR percentile rank (default: 100)
[*]Adaptive Min Scale — minimum bandwidth multiplier in quiet markets (default: 0.80)
[*]Adaptive Max Scale — maximum bandwidth multiplier in volatile markets (default: 1.25)
[*]Output EMA Smooth — post-kernel EMA smoothing applied to both kernel outputs (default: 2)
[*]Fast Kernel h Mult — bandwidth multiplier for the fast kernel relative to the slow (default: 0.55)
[/list]

[b]Residual Bands[/b]
[list]
[*]Band Multiplier (σ) — number of residual standard deviations for the band boundaries (default: 1.0)
[*]Residual σ Lookback — bars used to compute the residual standard deviation (default: 24)
[*]Z-Score Min for Range Fade — minimum absolute Z-Score required for Setup C to fire (default: 1.35)
[/list]

[b]Regime & Divergence[/b]
[list]
[*]Efficiency Ratio Length — ER lookback (default: 10)
[*]ER Min (Trend) — minimum ER for trend classification (default: 0.32)
[*]Choppiness Length — CI lookback (default: 14)
[*]Chop — Stand Aside Above — CI threshold (default: 61.0)
[*]Enable Pivot Divergence — toggle the divergence detection system
[*]Divergence Pivot Length — bars on each side for pivot confirmation (default: 5)
[*]Divergence Cooldown (bars) — minimum bars between divergence detections (default: 8)
[/list]

[b]Entries & Confluence[/b]
[list]
[*]Setup A · Flow Break (trend) — toggle the trend band crossover setup
[*]Setup B · Kernel Pullback — toggle the kernel touch pullback setup
[*]Setup C · Z-Score Fade (balance) — toggle the balance mean-reversion setup
[*]Setup D · Divergence Reversal — toggle the pivot divergence entry
[*]Min Confluence Layers (of 7) — minimum score to fire a signal (default: 5)
[*]Show Entry Signals — toggle signal triangles
[*]Show Confluence Label — toggle the live B/S score label near the kernel line
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 6)
[/list]

[b]Filters[/b]
[list]
[*]HTF Trend Filter / HTF Timeframe / HTF Fast / HTF Slow EMA — higher timeframe bias parameters (defaults: on / 60-minute / 21 / 55)
[*]Volume Confirm / Min Volume vs Avg / Volume Avg Length — volume expansion gate (defaults: on / 1.05 / 20)
[*]Session Filter / Active Session — trading hours restriction (default: off)
[/list]

[b]Exit Guidance[/b]
[list]
[*]Show SL / TP Guides — toggle stop and target circles
[*]SL Distance (xATR) — ATR buffer beyond the lower band and bar low minimum (default: 1.0)
[*]TP Reward (R) — take profit as risk × R multiple (default: 2.5)
[/list]

[b]Display[/b]
[list]
[*]Visual Mode — Bands / Line / Flow. Selects which kernel components are rendered
[*]Fill Residual Bands — toggle the purple band fill between upper and lower bands
[*]Color Bars by Bias — toggle optional bar coloring by kernel spread direction (default: off)
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for bullish signals and indicators
[*]Bear / Bear Bright — red family for bearish signals
[*]Chop / Caution — orange for chop regime and bandwidth shift warnings
[*]Kernel Line — purple for the slow kernel line and neutral band elements
[*]Fast Kernel — cyan for the fast kernel line in Flow mode
[*]SL Guide / TP Guide — stop and target circle colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (6 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]PRISM Long — all conditions confirmed. Long signal fired across any of the four setup types
[*]PRISM Short — all conditions confirmed. Short signal fired
[/list]

[b]State Alerts[/b]
[list]
[*]PRISM Chop Warning — market has entered the Chop regime. All signals blocked — stand aside
[*]PRISM Bull Divergence — bullish pivot divergence confirmed at the lower band. Setup D long conditions developing — watch for rejection candle
[*]PRISM Bear Divergence — bearish pivot divergence confirmed at the upper band
[*]PRISM Bandwidth Shift — adaptive bandwidth shifted 12%+ in one bar. Volatility regime transition in progress
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M5–H1[/b]:
[list]
[*]Gaussian kernel — smoothest estimate, optimal for the normally-distributed noise of gold and forex price action
[*]Lookback at 40 — sufficient history for a meaningful kernel estimate on intraday timeframes without excessive lag
[*]Base bandwidth at 6.0 with adaptive scaling — allows the kernel to breathe with gold's characteristic alternation between tight ranges and explosive moves
[*]Band Multiplier at 1.0σ — one standard deviation bands are sensitive to genuine residual extremes without requiring extreme extension
[*]Z-Score minimum at 1.35 — approximately 82nd percentile of normal distribution — a meaningful but not excessive statistical stretch requirement
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Lookback to 25–30, reduce Base Bandwidth to 4.0–5.0, reduce Output EMA Smooth to 1, reduce Cooldown to 3, reduce TP to 2.0R
[*][b]H4–Daily swing trading[/b] — increase Lookback to 60–80, increase Base Bandwidth to 8.0–12.0, increase ATR Percentile Lookback to 200, increase TP to 3.5–5.0R
[*][b]Crypto (BTC, ETH)[/b] — increase Adaptive Max Scale to 1.40–1.50 for the wider volatility swings, consider Epanechnikov kernel for faster response to crypto's sharper price movements
[*][b]Indices (NAS100, US30)[/b] — increase Z-Score minimum to 1.5–1.8 (indices can sustain higher Z-scores in trends before reverting), use session filter for cash market hours
[*][b]More signals[/b] — lower Min Confluence to 4, reduce Z-Score minimum to 1.1, increase Base Bandwidth to produce wider bands that are touched more frequently
[*][b]Fewer, highest-quality signals[/b] — raise Min Confluence to 6–7, increase Z-Score minimum to 1.6, reduce Fast Kernel multiplier to 0.45 for a slower fast kernel that only diverges from slow in strong trends
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🔬 [b]Mathematically sophisticated traders[/b] — PRISM exposes the full statistical machinery of non-parametric kernel regression to traders who want more than a moving average but something grounded in rigorous statistical theory
[*]📊 [b]Band-based traders who struggle with Bollinger Bands[/b] — residual-based bands solve the core Bollinger Band problem: bands that widen dramatically in trends due to trend variance rather than noise variance. PRISM's bands measure only the noise
[*]🎯 [b]Divergence traders[/b] — the pivot-based kernel divergence system is the most robust divergence implementation in the AlphaX suite, comparing structural price pivots to the kernel's trend estimate rather than oscillator slopes
[*]🧭 [b]Regime-aware traders[/b] — like VECTOR, PRISM classifies the current market regime and selects the appropriate playbook automatically. Four distinct setup types cover trending, balanced, and reversal conditions
[*]📈 [b]Adaptive system traders[/b] — the adaptive bandwidth scaling means PRISM truly adapts to the current volatility environment without manual recalibration
[*]🥇 [b]Gold and forex intraday traders[/b] — the Gaussian kernel with adaptive scaling is particularly well-suited to gold's volatility patterns, and the default settings are calibrated for XAUUSD intraday conditions
[*]🔀 [b]Traders who use mean-reversion and trend-following simultaneously[/b] — PRISM's four setups cover both directions: momentum breaks and pullbacks in trends, fades and divergence reversals in balance. One indicator, complete market coverage across regimes
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Kernel estimates, regime classification, divergence detection, and confluence scoring all finalize on confirmed bars
[*]The kernel regression calculation requires all bars within the lookback window to produce its estimate. On charts with fewer bars than the Lookback Window setting, the kernel estimate may be imprecise during the warm-up period. Allow the chart to accumulate at least the full lookback period (default: 40 bars) before treating signals as reliable
[*]Adaptive bandwidth scaling uses ATR percentile rank, which itself requires the ATR Percentile Lookback period to calibrate. On fresh chart loads, the adaptive scale may not reflect the full historical context until sufficient bars have accumulated
[*]The divergence system compares to the [i]most recently confirmed[/i] pivot high or low. On timeframes where pivots form infrequently (H4+), the prior pivot reference may be many bars old and the divergence comparison less temporally relevant. Reduce the divergence pivot length on higher timeframes for more frequent reference points
[*]The bandwidth shift alert fires when the bandwidth changes by 12%+ between consecutive bars. On very fast timeframes with high ATR volatility, this threshold may be crossed frequently — increase the threshold or disable the bandwidth shift alert if this becomes excessive noise
[*]Maximum 500 labels and 500 lines are rendered. The divergence markers and confluence labels count toward these limits
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who believe that the best price estimate is not an average of the past — it is a statistically optimal reconstruction of the price process itself.[/i]

## Source Code

````pine
// © AlphaX — PRISM v1.0
// Adaptive Dual-Kernel Flow Engine — evolved from kernel-regression concepts.
// Fixes vs naive band systems: regime gating, dual-kernel momentum, pivot divergence, confluence.
// AlphaX branded — styled after ANCHOR.

//@version=6
indicator("[ A L P H A X ] PRISM - Adaptive Dual-Kernel Flow Engine", shorttitle="AlphaX PRISM",
  overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  KERNEL ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpKernel = "Kernel Engine"
kernelType  = input.string("Gaussian", "Kernel Type",
  options=["Gaussian", "Epanechnikov", "Tricube"], group=grpKernel)
nwLen       = input.int(40, "Lookback Window", minval=15, maxval=120, group=grpKernel)
baseH       = input.float(6.0, "Base Bandwidth (h)", minval=1.0, maxval=20.0, step=0.5, group=grpKernel)
useAdaptive = input.bool(true, "Adaptive Bandwidth (ATR percentile)", group=grpKernel,
  tooltip="Scales h by ATR percentile — wider in expansion, tighter in quiet markets. More stable than raw ATR×constant.")
atrLen      = input.int(14, "ATR Length", minval=5, maxval=50, group=grpKernel)
atrPctLen   = input.int(100, "ATR Percentile Lookback", minval=20, maxval=300, group=grpKernel)
adaptMin    = input.float(0.80, "Adaptive Min Scale", minval=0.5, maxval=1.0, step=0.05, group=grpKernel)
adaptMax    = input.float(1.25, "Adaptive Max Scale", minval=1.0, maxval=1.8, step=0.05, group=grpKernel)
smoothOut   = input.int(2, "Output EMA Smooth", minval=1, maxval=10, group=grpKernel)
fastHMult   = input.float(0.55, "Fast Kernel h Mult", minval=0.3, maxval=0.9, step=0.05, group=grpKernel,
  tooltip="Fast kernel = responsive momentum layer. Slow = primary estimate + bands.")

// ═══════════════════════════════════════════════════════════════════════════════
//  RESIDUAL BANDS
// ═══════════════════════════════════════════════════════════════════════════════
grpBands = "Residual Bands"
bandMult    = input.float(1.0, "Band Multiplier (σ)", minval=0.5, maxval=2.5, step=0.1, group=grpBands)
bandLen     = input.int(24, "Residual σ Lookback", minval=10, maxval=100, group=grpBands)
zFadeMin    = input.float(1.35, "Z-Score Min for Range Fade", minval=0.8, maxval=3.0, step=0.05, group=grpBands,
  tooltip="In balance regime, fade only when residual Z exceeds this — avoids weak fades.")

// ═══════════════════════════════════════════════════════════════════════════════
//  REGIME & DIVERGENCE
// ═══════════════════════════════════════════════════════════════════════════════
grpReg = "Regime & Divergence"
erLen       = input.int(10, "Efficiency Ratio Length", minval=5, maxval=50, group=grpReg)
erTrendMin  = input.float(0.32, "ER Min (Trend)", minval=0.15, maxval=0.7, step=0.05, group=grpReg)
chopLen     = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpReg)
chopMax     = input.float(61.0, "Chop — Stand Aside Above", minval=50, maxval=75, step=0.5, group=grpReg)
useDiv      = input.bool(true, "Enable Pivot Divergence", group=grpReg,
  tooltip="Pivot-based: price LL + kernel HL (bull) — more robust than raw slope comparison.")
divPivotLen = input.int(5, "Divergence Pivot Length", minval=2, maxval=15, group=grpReg)
divCooldown = input.int(8, "Divergence Cooldown (bars)", minval=1, maxval=50, group=grpReg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ENTRIES & CONFLUENCE
// ═══════════════════════════════════════════════════════════════════════════════
grpEntry = "Entries & Confluence"
enableFlowBreak = input.bool(true, "Setup A · Flow Break (trend)", group=grpEntry,
  tooltip="Trend regime: close breaks residual band WITH fast/slow kernel spread aligned.")
enableKernelPullback = input.bool(true, "Setup B · Kernel Pullback", group=grpEntry,
  tooltip="Trend regime: touch slow kernel + rejection while spread still directional.")
enableZFade     = input.bool(true, "Setup C · Z-Score Fade (balance)", group=grpEntry,
  tooltip="Balance regime: fade band extreme when Z-score stretched + optional divergence.")
enableDivReversal = input.bool(true, "Setup D · Divergence Reversal", group=grpEntry,
  tooltip="Pivot divergence at band extreme + rejection candle.")
minConf         = input.int(5, "Min Confluence Layers (of 7)", minval=4, maxval=7, group=grpEntry)
showSignals     = input.bool(true, "Show Entry Signals", group=grpEntry)
showConfLbl     = input.bool(true, "Show Confluence Label", group=grpEntry)
cooldown        = input.int(6, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpEntry)

// ═══════════════════════════════════════════════════════════════════════════════
//  FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
grpFilt = "Filters"
useHtf      = input.bool(true, "HTF Trend Filter", group=grpFilt)
htfTf       = input.timeframe("60", "HTF Timeframe", group=grpFilt)
htfFast     = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpFilt)
htfSlow     = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpFilt)
useVol      = input.bool(true, "Volume Confirm", group=grpFilt)
volMult     = input.float(1.05, "Min Volume vs Avg", minval=0.8, maxval=3.0, step=0.05, group=grpFilt)
volLen      = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpFilt)
useSession  = input.bool(false, "Session Filter", group=grpFilt)
sessStart   = input.session("0700-2000", "Active Session", group=grpFilt)

// ═══════════════════════════════════════════════════════════════════════════════
//  EXIT GUIDANCE
// ═══════════════════════════════════════════════════════════════════════════════
grpExit = "Exit Guidance"
showExits   = input.bool(true, "Show SL / TP Guides", group=grpExit)
slAtrMult   = input.float(1.0, "SL Distance (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpExit)
tpRR        = input.float(2.5, "TP Reward (R)", minval=0.5, maxval=20, step=0.5, group=grpExit)

// ═══════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Display"
visMode     = input.string("Bands", "Visual Mode", options=["Bands", "Line", "Flow"], group=grpVis,
  tooltip="Bands = residual envelope. Line = slow kernel only. Flow = fast+slow kernel spread.")
showFill    = input.bool(true, "Fill Residual Bands", group=grpVis)
showBarCol  = input.bool(false, "Color Bars by Bias", group=grpVis,
  tooltip="Off by default — keeps chart clean.")
showDash    = input.bool(true, "Show Dashboard", group=grpVis)
dashPos     = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

// ═══════════════════════════════════════════════════════════════════════════════
//  COLORS (ANCHOR palette)
// ═══════════════════════════════════════════════════════════════════════════════
grpColors = "Colors"
colBull       = input.color(#c8e624, "Bull",               group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear       = input.color(#ff1744, "Bear",               group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Bright",        group=grpColors)
colSqueeze    = input.color(#ff9800, "Chop / Caution",     group=grpColors)
colNeutral    = input.color(#555555, "Neutral",            group=grpColors)
colKernel     = input.color(#8b6fd0, "Kernel Line",        group=grpColors)
colFastK      = input.color(#00bcd4, "Fast Kernel",        group=grpColors)
colSlLine     = input.color(#ff1744, "SL Guide",           group=grpColors)
colTpLine     = input.color(#c8e624, "TP Guide",           group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text",          group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG",            group=grpColors)
colDashHeader = input.color(#111111, "Dash Header BG",     group=grpColors)
colDashSec    = input.color(#222222, "Dash Section BG",    group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame",         group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_kernelWeight(float i, float h, string kType) =>
    kType == "Gaussian" ? math.exp(-math.pow(i, 2) / (2.0 * math.pow(h, 2))) :
     kType == "Epanechnikov" ? math.max(0.0, 1.0 - math.pow(i / h, 2)) :
     math.max(0.0, math.pow(1.0 - math.pow(math.abs(i / h), 3), 3))

f_nwEstimate(float src, int len, float h, string kType) =>
    float wSum = 0.0
    float pSum = 0.0
    for i = 0 to len - 1
        float w = f_kernelWeight(float(i), h, kType)
        pSum += w * src[i]
        wSum += w
    wSum != 0.0 ? pSum / wSum : src

f_safeDiv(float n, float d, float fb) => d == 0.0 ? fb : n / d

// ═══════════════════════════════════════════════════════════════════════════════
//  KERNEL CORE
// ═══════════════════════════════════════════════════════════════════════════════
atrVal  = ta.atr(atrLen)
volMa   = ta.sma(volume, volLen)
rng     = math.max(high - low, syminfo.mintick)

atrPct  = ta.percentrank(atrVal, atrPctLen)
adaptSc = useAdaptive ? adaptMin + (adaptMax - adaptMin) * (atrPct / 100.0) : 1.0
hSlow   = baseH * adaptSc
hFast   = hSlow * fastHMult

nwSlowRaw = f_nwEstimate(close, nwLen, hSlow, kernelType)
nwFastRaw = f_nwEstimate(close, nwLen, hFast, kernelType)
kernelSlow = ta.ema(nwSlowRaw, smoothOut)
kernelFast = ta.ema(nwFastRaw, math.max(1, smoothOut - 1))

kernelSpread = kernelFast - kernelSlow
spreadBull = kernelSpread > 0 and kernelSpread > kernelSpread[1]
spreadBear = kernelSpread < 0 and kernelSpread < kernelSpread[1]
spreadCrossUp = ta.crossover(kernelSpread, 0)
spreadCrossDn = ta.crossunder(kernelSpread, 0)

// Residual bands (on slow kernel)
residual = close - kernelSlow
sigma    = ta.ema(ta.stdev(residual, bandLen), 3)
upperBand = kernelSlow + bandMult * sigma
lowerBand = kernelSlow - bandMult * sigma
zScore    = sigma != 0 ? residual / sigma : 0.0

// Bandwidth shift (regime volatility alert)
hChangePct = f_safeDiv(math.abs(hSlow - hSlow[1]), hSlow[1], 0.0)
bandShift  = hChangePct >= 0.12

// ── Regime ────────────────────────────────────────────────────────────────────
float erChg = math.abs(close - close[erLen])
float erVol = math.sum(math.abs(close - close[1]), erLen)
float effRatio = f_safeDiv(erChg, erVol, 0.0)

float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0

bool isChop    = chopIdx >= chopMax
bool isTrend   = not isChop and effRatio >= erTrendMin and math.abs(kernelSpread) > sigma * 0.15
bool isBalance = not isChop and not isTrend

int regime = isChop ? 0 : isTrend ? (kernelSpread > 0 ? 1 : 2) : 3
// 0=CHOP 1=TREND BULL 2=TREND BEAR 3=BALANCE

// ── HTF / session ─────────────────────────────────────────────────────────────
htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE
htfOKLong  = not useHtf or htfBull
htfOKShort = not useHtf or htfBear
volOK = not useVol or volume >= volMa * volMult
inSession = not useSession or not na(time(timeframe.period, sessStart))

// ── Pivot divergence (improved vs raw slope) ──────────────────────────────────
ph = ta.pivothigh(high, divPivotLen, divPivotLen)
pl = ta.pivotlow(low, divPivotLen, divPivotLen)

var float lastPriceHi = na
var float lastPriceLo = na
var float lastKernHi  = na
var float lastKernLo  = na

if not na(ph)
    lastPriceHi := ph
    lastKernHi  := kernelSlow[divPivotLen]
if not na(pl)
    lastPriceLo := pl
    lastKernLo  := kernelSlow[divPivotLen]

bool bullDivRaw = useDiv and not na(lastPriceLo) and not na(lastKernLo) and
     low < lastPriceLo and kernelSlow > lastKernLo and close <= lowerBand + sigma
bool bearDivRaw = useDiv and not na(lastPriceHi) and not na(lastKernHi) and
     high > lastPriceHi and kernelSlow < lastKernHi and close >= upperBand - sigma

var int lastBullDivBar = na
var int lastBearDivBar = na
bool bullDiv = bullDivRaw and (na(lastBullDivBar) or bar_index - lastBullDivBar >= divCooldown)
bool bearDiv = bearDivRaw and (na(lastBearDivBar) or bar_index - lastBearDivBar >= divCooldown)
if bullDiv
    lastBullDivBar := bar_index
if bearDiv
    lastBearDivBar := bar_index

// ── Candle triggers ───────────────────────────────────────────────────────────
bullTrig = close > open and (close - low) / rng > 0.52
bearTrig = close < open and (high - close) / rng > 0.52

float touchTol = atrVal * 0.25
bool touchKernelLong  = low <= kernelSlow + touchTol and close > kernelSlow
bool touchKernelShort = high >= kernelSlow - touchTol and close < kernelSlow

// ═══════════════════════════════════════════════════════════════════════════════
//  SETUPS (regime-gated — key fix vs single-mode band systems)
// ═══════════════════════════════════════════════════════════════════════════════
bool crossUpper = ta.crossover(close, upperBand)
bool crossLower = ta.crossunder(close, lowerBand)

setupFlowLong   = enableFlowBreak and (regime == 1) and crossUpper and spreadBull and bullTrig
setupFlowShort  = enableFlowBreak and (regime == 2) and crossLower and spreadBear and bearTrig

setupPullLong   = enableKernelPullback and (regime == 1) and touchKernelLong and spreadBull and bullTrig
setupPullShort  = enableKernelPullback and (regime == 2) and touchKernelShort and spreadBear and bearTrig

setupFadeShort  = enableZFade and (regime == 3) and zScore >= zFadeMin and bearTrig
setupFadeLong   = enableZFade and (regime == 3) and zScore <= -zFadeMin and bullTrig

setupDivLong    = enableDivReversal and bullDiv and bullTrig and (regime == 3 or regime == 2)
setupDivShort   = enableDivReversal and bearDiv and bearTrig and (regime == 3 or regime == 1)

int bullScore = (regime == 1 or spreadBull ? 1 : 0) + (zScore > 0 or kernelSpread > 0 ? 1 : 0) +
     (htfOKLong ? 1 : 0) + (volOK ? 1 : 0) + (bullTrig ? 1 : 0) + (not isChop ? 1 : 0) +
     ((setupFlowLong or setupPullLong or setupFadeLong or setupDivLong) ? 1 : 0)
int bearScore = (regime == 2 or spreadBear ? 1 : 0) + (zScore < 0 or kernelSpread < 0 ? 1 : 0) +
     (htfOKShort ? 1 : 0) + (volOK ? 1 : 0) + (bearTrig ? 1 : 0) + (not isChop ? 1 : 0) +
     ((setupFlowShort or setupPullShort or setupFadeShort or setupDivShort) ? 1 : 0)

bool setupLong  = setupFlowLong or setupPullLong or setupFadeLong or setupDivLong
bool setupShort = setupFlowShort or setupPullShort or setupFadeShort or setupDivShort

var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown

bool bullSignal = showSignals and barstate.isconfirmed and setupLong and bullScore >= minConf and inSession and cooled and volOK and not isChop
bool bearSignal = showSignals and barstate.isconfirmed and setupShort and bearScore >= minConf and inSession and cooled and volOK and not isChop

if bullSignal or bearSignal
    lastSigBar := bar_index

float slGuide = na
float tpGuide = na
if bullSignal
    slGuide := math.min(low, lowerBand) - slAtrMult * atrVal
    float risk = close - slGuide
    tpGuide := risk > 0 ? close + risk * tpRR : close + atrVal * tpRR
if bearSignal
    slGuide := math.max(high, upperBand) + slAtrMult * atrVal
    float riskS = slGuide - close
    tpGuide := riskS > 0 ? close - riskS * tpRR : close - atrVal * tpRR

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
color biasCol = kernelSpread > sigma * 0.1 ? colBull : kernelSpread < -sigma * 0.1 ? colBear : colNeutral

bool showBands = visMode == "Bands"
bool showLine  = visMode == "Line" or visMode == "Bands"
bool showFlow  = visMode == "Flow"

pUpper = plot(showBands ? upperBand : na, "Upper Band", color=color.new(biasCol, 50), linewidth=1)
pLower = plot(showBands ? lowerBand : na, "Lower Band", color=color.new(biasCol, 50), linewidth=1)
pSlow  = plot(showLine ? kernelSlow : na, "Slow Kernel", color=color.new(colKernel, 10), linewidth=2)
pFast  = plot(showFlow ? kernelFast : na, "Fast Kernel", color=color.new(colFastK, 30), linewidth=1)

fill(pUpper, pLower, color=showBands and showFill ? color.new(#8b6fd0, 88) : na, title="Band Fill")

barcolor(showBarCol ? color.new(biasCol, 40) : na)

plot(showExits and not na(slGuide) ? slGuide : na, "SL Guide", color=color.new(colSlLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and not na(tpGuide) ? tpGuide : na, "TP Guide", color=color.new(colTpLine, 25), linewidth=1, style=plot.style_circles)

plotshape(bullSignal, title="PRISM Long", style=shape.triangleup, location=location.belowbar,
  color=color.new(colBull, 0), size=size.small)
plotshape(bearSignal, title="PRISM Short", style=shape.triangledown, location=location.abovebar,
  color=color.new(colBear, 0), size=size.small)

plotshape(bullDiv and not bullSignal, title="Bull Div", style=shape.diamond, location=location.belowbar,
  color=color.new(colBullBr, 40), size=size.tiny)
plotshape(bearDiv and not bearSignal, title="Bear Div", style=shape.diamond, location=location.abovebar,
  color=color.new(colBearBr, 40), size=size.tiny)

if showConfLbl and barstate.islast and not isChop
    string confTxt = "B " + str.tostring(bullScore) + "/7  ·  S " + str.tostring(bearScore) + "/7"
    color confCol = bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral
    label.new(bar_index, kernelSlow, confTxt, color=color.new(colDashBg, 10),
      textcolor=confCol, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 16,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

string regimeTxt = regime == 0 ? "⛔ CHOP" : regime == 1 ? "▲ TREND BULL" : regime == 2 ? "▼ TREND BEAR" : "◆ BALANCE"
color  regimeCol = regime == 0 ? colSqueeze : regime == 1 ? colBull : regime == 2 ? colBear : colKernel
string spreadTxt = (kernelSpread >= 0 ? "+" : "") + str.tostring(kernelSpread, format.mintick)
string divTxt = bullDiv ? "▲ BULL DIV" : bearDiv ? "▼ BEAR DIV" : "—"

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX PRISM", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "v1.0", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── KERNEL ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    table.cell(dash, 0, 2, "REGIME", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, regimeTxt, text_color=regimeCol, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "KERNEL TYPE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, kernelType, text_color=colKernel, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "BANDWIDTH h", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, str.tostring(hSlow, "#.##") + (useAdaptive ? " adap" : ""),
      text_color=bandShift ? colSqueeze : colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "FLOW SPREAD", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, spreadTxt, text_color=spreadBull ? colBull : spreadBear ? colBear : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 6, "─── BANDS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 6, "", bgcolor=secBg)

    table.cell(dash, 0, 7, "Z-SCORE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, str.tostring(zScore, "#.##"),
      text_color=math.abs(zScore) >= zFadeMin ? colSqueeze : colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "σ WIDTH", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, str.tostring(sigma, format.mintick), text_color=colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "DIVERGENCE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, divTxt, text_color=bullDiv ? colBull : bearDiv ? colBear : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "─── FILTERS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 10, "", bgcolor=secBg)

    table.cell(dash, 0, 11, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "CHOP INDEX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, str.tostring(chopIdx, "#.#"), text_color=isChop ? colSqueeze : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 13, "", bgcolor=secBg)

    table.cell(dash, 0, 14, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf and not isChop ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 14, str.tostring(bullScore) + "/7" + (bullScore >= minConf and not isChop ? " ✓" : ""),
      text_color=bullScore >= minConf and not isChop ? colBull : colNeutral, text_size=size.small,
      bgcolor=bullScore >= minConf and not isChop ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 15, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf and not isChop ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 15, str.tostring(bearScore) + "/7" + (bearScore >= minConf and not isChop ? " ✓" : ""),
      text_color=bearScore >= minConf and not isChop ? colBear : colNeutral, text_size=size.small,
      bgcolor=bearScore >= minConf and not isChop ? color.new(colBear, 88) : dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, title="PRISM Long",
  message="[AlphaX PRISM] LONG on {{ticker}} {{interval}} — kernel flow setup.")
alertcondition(bearSignal, title="PRISM Short",
  message="[AlphaX PRISM] SHORT on {{ticker}} {{interval}} — kernel flow setup.")
alertcondition(isChop and regime[1] != 0, title="PRISM Chop Warning",
  message="[AlphaX PRISM] CHOP regime — stand aside on {{ticker}}.")
alertcondition(bullDiv, title="PRISM Bull Divergence",
  message="[AlphaX PRISM] Bullish pivot divergence at lower band.")
alertcondition(bearDiv, title="PRISM Bear Divergence",
  message="[AlphaX PRISM] Bearish pivot divergence at upper band.")
alertcondition(bandShift, title="PRISM Bandwidth Shift",
  message="[AlphaX PRISM] Adaptive bandwidth shifted — volatility regime change.")
````
