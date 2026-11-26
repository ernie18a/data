# Parallel Transport & Holonomy [DAFE]

- url: https://www.tradingview.com/script/6sHT4bUl-Parallel-Transport-Holonomy-DAFE/
- type: indicator
- pine_id: PUB;f6781800f86d4a23983675e391b4e2f9
- version: 1.0

## Description

[b]Parallel Transport & Holonomy [DAFE] - (⟡ PTH)[/b]

This publication presents the quantitative mechanics and theoretical architecture behind the [b]Parallel Transport & Holonomy [DAFE][/b] engine. This system models price and volume dynamics as trajectories on a continuous two-dimensional manifold. By computing the parallel transport of multi-scale momentum vectors, tracking their covariant derivatives, and integrating their path-dependent rotational deficit ([b]Holonomy[/b]), the indicator identifies macro regime shifts, structural pivots, and trend continuations.

The architecture is entirely self-contained, featuring a [b]Legit Footprint Toggle[/b] that automatically falls back to an advanced [b]Synthetic Footprint Engine[/b] when tick-level footprint data is unavailable. It is strictly anchored by a [b]Rolling Confidence Matrix (RCM)[/b] and modulated by an [b]Ensemble Dynamic Volatility Scaling (DVS)[/b] engine.

The core principle of this system is geometric invariance: signal evaluation is not based on static, lagging thresholds but on the coordinate-invariant deviation of momentum from its natural geodesic path.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Riemannian Price-Volume Manifold & Metric Tensor[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
We define the market state as a coordinate point on a two-dimensional Riemannian manifold 
M, where the coordinates are:
[image]https://www.tradingview.com/x/XFu7c0rU/[/image]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Parallel Transport & Covariant Derivatives[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Let V be a momentum vector on the tangent space of the manifold, constructed at three distinct temporal scales: [b]Fast[/b] (vecFast), [b]Medium[/b] (vecMed), and [b]Slow[/b] (vecSlow). The coordinate components of the vector scale k are computed as:
[image]https://www.tradingview.com/x/1Zf3fqlb/[/image]

[b]Geodesic Deviation[/b]
A path is geodesic if its covariant derivative along the direction of travel is zero (representing the path of least resistance on the manifold). We define the geodesic deviation Zgeodesic as the rolling z-score of the absolute transport deviation:
[image]https://www.tradingview.com/x/2eWiX3XE/[/image]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Holonomy & Phase Accumulation[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Holonomy[/b] describes the geometric phenomenon where parallel transporting a vector along a closed loop returns a vector with a changed orientation. This angular deficit directly measures the total curvature enclosed by the loop.
[image]https://www.tradingview.com/x/tATtdGvW/[/image]

[b]Holonomy Group Classifications[/b]
Based on the magnitude of the accumulated rotation (HolonomyNorm), the local coordinate space is classified into four geometric groups:
[list=1]
[*][b]Trivial[/b] (Norm<0.10): The manifold is flat; parallel transport is path-independent, indicating quiet consolidated ranges.
[*][b]Abelian[/b] (Norm<0.25): Minor commutative drift; the vector field undergoes predictable linear shifts.
[*][b]Non-Abelian[/b] (Norm<0.50): Significant non-commutative curvature. Parallel transport is highly path-dependent, signaling complex trend development and institutional accumulation.
[*][b]Singular[/b] (Norm≥0.50): Severe rotational deficit. The manifold geometry has collapsed or rotated sharply, marking high-probability reversal peaks and structural transitions.
[/list]

[b]Holonomy Regime Shifts[/b]
A [b]Regime Shift[/b] is triggered when HolonomyNorm exceeds the user-defined threshold (i_holoThresh). Depending on the sign of the accumulated loop (sgn(H)) and the divergence between the fast and slow vectors, the engine classifies the transition into one of the following states:
[list]
[*][b]Bull Rotation[/b]: Enclosed path yields a positive rotational deficit combined with positive multi-scale momentum.
[*][b]Bear Rotation[/b]: Enclosed path yields a negative rotational deficit combined with negative multi-scale momentum.
[*][b]Geodesic Break[/b]: Extreme localized acceleration causing the momentum field to tear away from its expected trajectory.
[*][b]Scale Divergence[/b]: High-frequency (fast) and low-frequency (slow) vectors rotate in opposite directions, enclosing a singular point.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Rolling Confidence Matrix (RCM)[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The [b]Rolling Confidence Matrix (RCM)[/b] acts as a structural anchor. It takes multi-scale geometric indicators from the transport engine and compiles them into a state-space model that dynamically controls signal permissions.

[b]State Space Representation[/b]
The matrix maintains a rolling assessment of market structure across three distinct states:
[list=1]
[*][b]Established[/b] (State 0): The trend is structurally intact; manifold bands are compressed, and parallel transport confirms high directional persistence.
[*][b]Transition[/b] (State 1): Price is approaching key structural levels or experiencing a holonomy spike. Manifold bands widen, and standard signals are gated.
[*][b]Damaged[/b] (State 2): Price has broken through primary defensive corridors. Structural confidence is compromised; bands expand by the [b]Damage Band Expansion[/b] multiplier 
(i_damageWiden), and counter-trend positions are heavily penalized.
[/list]

[b]External Evidence Injection[/b]
On every bar, the system injects external geometric parameters from the manifold:
[image]https://www.tradingview.com/x/kkkM4DJi/[/image]

This evidence is integrated into the RCM, outputting structural permissions (allowLong, allowShort) and score modulations that are applied to the final signal scoring calculations.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Ensemble Dynamic Volatility Scaling (DVS)[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
To adapt the mathematical models to varying market volatility, the script runs three independent volatility estimators concurrently on every bar:
[image]https://www.tradingview.com/x/1A764vXX/[/image]

[b]Ensemble Combinatorics[/b]
The baseline values are calculated as moving averages over the memory period. The script then computes the ratios of the current estimators to their historical baselines:
[image]https://www.tradingview.com/x/075Q8uJt/[/image]

This ratio dynamically scales the width of the holographic manifold bands and the RCM damage thresholds: during highly volatile regimes, thresholds are expanded to prevent whipsaws; during compression regimes, thresholds are tightened to capture early breakouts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Footprint & Synthetic Fallback Engine[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The script includes a [b]Use Legit Footprint[/b] toggle (i_useFp). When enabled on charts supporting tick databases, the system requests official exchange-traded order flow data:
[pine]fp=request.footprint(i_fpTicks,i_fpVA)[/pine]

[b]The Advanced Synthetic Footprint Engine[/b]
If the user deactivates the footprint toggle, or if the asset/timeframe does not support tick database access (e.g., historical bars or Forex), the [b]Synthetic Footprint Fallback Engine** takes over, simulating volume-at-price and directional delta using high-frequency mathematical approximations:
[image]https://www.tradingview.com/x/nFnWai1k/[/image]

This estimated delta reconstructs the synthetic buy and sell pressures:
[image]https://www.tradingview.com/x/5Jmd9u1Q/[/image]

​[b]Kyle's Lambda (Price Impact & Liquidity Risk)[/b]
Using these directional volumes, we calculate Kyle's price impact coefficient λ, measuring the price change per unit of volume flow:
[image]https://www.tradingview.com/x/02Izpp82/[/image]

​High values of λ represent illiquid, thin, or toxic conditions. The system calculates the z-score of lambda (Zλ). If Zλ > 2.0, signal scores are dynamically penalized to protect capital from low-liquidity slippage.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Structural Scoring & Signal Gating[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The system generates a directional [b]Signal Score[/b] using a two-tier quantitative scoring process.

[b]Stage 1: Structural Base (Minimum of one required)[/b]
[b]Siege Corridor Proximity[/b]: Price is within 1.2 ⋅ ATR of a verified support or resistance level.
ScoreBase = 0.28+(Hold Probability⋅0.18)
[b]EMA21 Geodesic Pullback[/b]: Price pulls back to the EMA21 in trend alignment.
ScoreBase = 0.25
[b]RSI Extreme Exhaustion[/b]: RSI is below 25 (for longs) or above 75 (for shorts).
ScoreBase = 0.28

[b]Stage 2: Confirmations (Additive)[/b]
Multi-pattern confluence (2+ patterns matching): +0.15
Pressure bar strength exceeds thresholds: +0.08 to +0.15
Metric curvature aligns with structural turn: +0.10
Volume expansion exceeds historical average: +0.10
Holonomy phase shifts or loop spikes: +0.12

[b]Directional Scaling & Gating[/b]
The score is adjusted based on trend alignment. [b]With-Trend (WT)[/b] setups (longs above the EMA50, shorts below) are evaluated using standard thresholds. [b]Counter-Trend (CT)[/b]setups face a strict scaling penalty:
ScoreCT = ScoreRaw ⋅ clamp(1.0−Trend Strength⋅0.15,0.45,1.0)

Additionally, the score passes through three gates:
[list=1]
[*][b]Liquidity Penalty[/b]: Reduced by up to 30% if order flow thickness is classified as Desert or Frozen.
[*][b]Kyle Lambda Gate[/b]: Penalized if price impact is highly volatile (Zλ > 2.0).
[*][b]Danger Gate[/b]: Score is multiplied by 0.60 if the composite risk danger index exceeds 75.
[/list]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Input Reference[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]═══ GEOMETRY ENGINE ═══[/b]
[b]Hurst Period[/b] (30 to 200, default 80): Lookback window for R/S calculations to evaluate trend persistence.
[b]Pivot Length[/b] (2 to 15, default 5): Lookback/lookahead buffer for swing pivot detection.
[b]TF Preset[/b] (Auto, 1m-5m Scalp, 10m-15m Intra, 30m-1H Swing, 4H-D Position): Set the timeframe scaling preset. Auto dynamically scales lookbacks based on the current chart timeframe.
[b]Use Legit Footprint[/b] (Boolean, default true): Toggles whether to query exchange tick database for real footprint data.
[b]Footprint Ticks/Row[/b] (1 to 500, default 100): Height of the footprint rows in tick units.
[b]Footprint VA %[/b] (50 to 90, default 70): Percentage of volume enclosed within the Value Area.

[b]═══ TRANSPORT & HOLONOMY ═══[/b]
[b]Vector Fast Scale[/b] (3 to 21, default 8): Periods for tracking short-term momentum vectors.
[b]Vector Medium Scale[/b] (10 to 55, default 21): Periods for intermediate momentum geometry.
[b]Vector Slow Scale[/b] (21 to 144, default 55): Baseline vector window representing the macro manifold.
[b]Holonomy Window[/b] (13 to 89, default 34): Size of the temporal loop used to integrate local deviations.
[b]Holonomy Spike Threshold[/b] (0.10 to 0.90, default 0.35): Sensitivity threshold for identifying rotational shifts.
[b]Geodesic Deviation Sensitivity[/b] (0.5 to 3.0, default 1.5): Sensitivity for flagging off-path momentum.
[b]Enable Continuation Signals[/b] (Boolean, default true): Toggles secondary pullback entries in strong trends.

[b]═══ ROLLING CONFIDENCE MATRIX ═══[/b]
[b]Block Transition Signals[/b] (Boolean, default true): If active, blocks standard entry signals when the matrix is in transition state.
[b]Conf Band Tightening Factor[/b] (0.0 to 1.0, default 0.35): Compression multiplier for manifold bands under high confidence.
[b]Damage Band Expansion[/b] (1.0 to 1.5, default 1.15): Expansion multiplier for manifold bands under structural damage.

[b]═══ DYNAMIC VOLATILITY SCALING (DVS) ═══[/b]
[b]Enable Ensemble DVS Engine[/b] (Boolean, default true): Toggles whether to scale target multiples and thresholds by volatility.
[b]DVS Method[/b] (ATR Ratio, Parkinson, Garman-Klass, Ensemble): Method for calculating real-time volatility.
[b]DVS Memory Period[/b] (20 to 200, default 100): Baseline lookback window for historical volatility.
[b]DVS Sensitivity[/b] (0.3 to 1.5, default 0.7): Exponent scaling parameter for the DVS ratio.

[b]═══ SIGNAL GATING ═══[/b]
[b]Signal Threshold[/b] (0.10 to 0.85, default 0.40): Minimum score required to fire a signal.
[b]Cooldown Bars[/b] (1 to 50, default 6): Minimum bar spacing between consecutive signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Visual System & Dashboard Interpretation[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Transport Field Manifold[/b]: A multi-layered band surrounding price. It contracts during clean, high-confidence geodesic flow and expands during high-entropy, damaged, or volatile regimes. Its color is determined by the RCM state: Green for bullish stability, Red for bearish, and Purple during transitions.
[image]https://www.tradingview.com/x/pSNuCNdC/[/image]

[b]Siege Corridors[/b]: Plotted as horizontal support (Green) and resistance (Red) zones with an ATR-scaled boundary. At the right-hand side of the chart, these corridors display critical metrics: the total historical hit count, the estimated break probability (Pbreak), and the fail/reversal probability (Pfail).
[image]https://www.tradingview.com/x/ap7IoG2q/[/image]

[b]Vector Field Lines[/b]: Small arrow-headed lines plotted on every third bar. They show the mathematical direction of the Fast momentum vector. They visually represent the difference between the actual observed path of the market and the expected parallel-transported baseline.
[image]https://www.tradingview.com/x/kBVx6LKM/[/image]

[b]Holonomy Phase Ring[/b]: An indicator plotted at the right edge of the chart displaying the current phase angle (e.g., ◐ 144∘).
[b]Glitch Markers:[/b] Flagged on the chart as ◈ GLITCH when anomalous pricing data or sudden coordinate jumps are detected on the manifold.

[b]Dashboard:[/b] Displays real-time metric readings from all quantitative modules:
[list]
[*][b]Tensor Metrics:[/b] Curvature, Entropy, Hurst Exponent, and Price Pressure.
[*][b]Volatility:[/b] Dynamic DVS Ratio, active estimator method, and scaling state.
[*][b]RCM Brain:[/b] State classification, integrity index, and gate permissions.
[*][b]Performance:[/b] Total trades, win rate, total profit (R-multiple), profit factor, and max drawdown.
[/list]
[image]https://www.tradingview.com/x/0yAKh67F/[/image]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]Limitations and Disclaimers[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This tool is for analytical purposes only and does not predict future market direction.

[b]Historical Simulation:[/b] The built-in simulator represents hypothetical performance on historical data. Past results do not guarantee future performance.
[b]Volume Approximations:[/b] The synthetic footprint engine uses OHLCV approximations to estimate volume-at-price and directional delta. It is not an actual connection to L2 exchange data feeds or a central clearing book.
[b]Persistence:[/b] Reinforcement learning weights are state-space variables that exist within the local execution thread; they reset to 1.0 on every chart load or browser reload.

— Dskyz. Trade with insight. Trade with anticipation. (It's lonely at the top)

## Source Code

````pine
//@version=6
indicator("Parallel Transport & Holonomy [DAFE]", "⟡ PTH", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)
// ═══════════════════════════════════════════════════════════════════════════════
//    Parallel Transport & Holonomy [DAFE] 
//    ─────────────────────────────────────────────────────
//    Momentum Vector Field Construction
//    Christoffel Connection & Covariant Derivatives
//    Holonomy Accumulation & Phase Detection
//    Rolling Confidence Matrix (RCM) Structural Anchor
//    Ensemble Dynamic Volatility Scaling (DVS)
//    Regime Shift Classification | Geodesic Deviation
//    Structural Signal Scoring | TF-Adaptive | Anti-Repaint
//    ─────────────────────────────────────────────────────
//    "The Market is an Illusion"
// ═══════════════════════════════════════════════════════════════════════════════
import DskyzInvestments/MarketStructureLib/1 as msl
import DskyzInvestments/DafeVisLib/1 as viz
import DskyzInvestments/DafeRCMLib/1 as rcm
// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_GEOM   = "═══ ⟡ GEOMETRY ENGINE ═══"
string G_TRANS  = "═══ ⟡ TRANSPORT & HOLONOMY ═══"
string G_RCM    = "═══ ⟡ ROLLING CONFIDENCE MATRIX ═══"
string G_DVS    = "═══ ⟡ DYNAMIC VOLATILITY SCALING (DVS) ═══"
string G_SIG    = "═══ ⟡ SIGNAL GATING ═══"
string G_TRADE  = "═══ ⟡ TRADE MANAGEMENT ═══"
string G_VIS    = "═══ ⟡ VISUALS ═══"
string G_DASH   = "═══ ⟡ DASHBOARDS ═══"
int    i_hurstPd    = input.int(80, "Hurst Period", minval=30, maxval=200, group=G_GEOM, tooltip="Lookback for Hurst Exponent — measures market memory.\n" + "H > 0.5: Trending (persistent). H < 0.5: Mean-reverting.\n" + "H ≈ 0.5: Random walk. Feeds the connection coefficients\n" + "that define how momentum 'should' evolve on the manifold.")
int    i_pivLen     = input.int(5, "Pivot Length", minval=2, maxval=15, group=G_GEOM, tooltip="Bars left/right to confirm swing pivots.\n" + "Defines structural granularity for the MSL engine.\n" + "Auto-scaled by TF-Adaptive engine across timeframes.")
string i_tfPreset   = input.string("Auto", "TF Preset", options=["Auto", "1m-5m Scalp", "10m-15m Intra", "30m-1H Swing", "4H-D Position"], group=G_GEOM, tooltip="Override automatic timeframe detection.\n" + "Auto: Scales all parameters to current chart TF.\n" + "Manual: Lock to specific trading style parameters.")
bool   i_useFp      = input.bool(true, "Use Legit Footprint", group=G_GEOM, tooltip="Toggles legitimate request.footprint data usage.\n" + "If disabled or unavailable on the chart, the advanced Synthetic Footprint Engine will take over.")
int    i_fpTicks    = input.int(100, "Footprint Ticks/Row", minval=1, maxval=500, group=G_GEOM, tooltip="Price resolution for footprint data.\n" + "Ticks per row for Delta, POC, Value Area calculation.\n" + "Calibrate to instrument for optimal order flow fidelity.")
int    i_fpVA       = input.int(70, "Footprint VA %", minval=50, maxval=90, group=G_GEOM, tooltip="Volume percentage for Value Area bounds (VAH/VAL).")
int    i_vecFast    = input.int(7, "Vector Fast Scale", minval=3, maxval=21, group=G_TRANS, tooltip="Fast momentum vector construction period.\n" + "Captures immediate directional impulse on the manifold.\n" + "Shorter = more responsive to micro regime changes.")
int    i_vecMed     = input.int(21, "Vector Medium Scale", minval=10, maxval=55, group=G_TRANS, tooltip="Medium-scale momentum vector period.\n" + "Captures intermediate trend geometry.\n" + "Primary scale for transport deviation calculations.")
int    i_vecSlow    = input.int(55, "Vector Slow Scale", minval=21, maxval=144, group=G_TRANS, tooltip="Slow momentum vector period.\n" + "Defines the macro directional 'baseline' of the manifold.\n" + "Holonomy relative to this scale = macro regime shifts.")
int    i_holoWin    = input.int(34, "Holonomy Window", minval=13, maxval=89, group=G_TRANS, tooltip="Sliding window for holonomy accumulation.\n" + "Cumulative angular deficit measured over this many bars.\n" + "Larger = detects bigger regime shifts, fewer false alarms.\n" + "Smaller = faster detection, more noise sensitivity.")
float  i_holoThresh = input.float(0.35, "Holonomy Spike Threshold", minval=0.10, maxval=0.90, step=0.05, group=G_TRANS, tooltip="Normalized threshold for holonomy spike detection.\n" + "When cumulative angular deficit exceeds this level,\n" + "it signals a potential regime shift or high-probability turn.\n" + "Higher = fewer, stronger regime shift signals.")
float  i_geodesicSens = input.float(1.5, "Geodesic Deviation Sensitivity", minval=0.5, maxval=3.0, step=0.1, group=G_TRANS, tooltip="How sensitive geodesic deviation detection is.\n" + "Measures whether price follows the 'least action' path.\n" + "Higher = more sensitive to deviations from natural flow.")
bool   i_contOn     = input.bool(true, "Enable Continuation Signals", group=G_TRANS, tooltip="Activate secondary continuation signals.\n" + "Identifies entries in established trends during pullbacks\n" + "when parallel transport confirms trend persistence.")
bool   i_blockTrans = input.bool(true, "Block Transition Signals", group=G_RCM, tooltip="If enabled, blocks entry signals when RCM is in transition state.")
float  i_confTighten = input.float(0.35, "Conf Band Tightening Factor", minval=0.0, maxval=1.0, step=0.05, group=G_RCM, tooltip="Determines how aggressively high structural confidence compresses the manifold bands (0 = no compression).")
float  i_damageWiden = input.float(1.15, "Damage Band Expansion", minval=1.0, maxval=1.5, step=0.05, group=G_RCM, tooltip="Multiplier to expand manifold bands when structural damage is detected.")
bool   i_enableDVS      = input.bool(true, "Enable Ensemble DVS Engine", group=G_DVS, tooltip="Adjusts execution targets and manifold bands based on Parkinson, Garman-Klass, and ATR volatility ratios.")
string i_dvsMethod      = input.string("Ensemble", "DVS Method", options=["ATR Ratio", "Parkinson", "Garman-Klass", "Ensemble"], group=G_DVS, tooltip="Method for estimating real-time volatility relative to historical baselines.")
int    i_dvsMemory      = input.int(100, "DVS Memory Period", minval=20, maxval=200, group=G_DVS, tooltip="Lookback window for baseline volatility calculations.")
float  i_dvsSensitivity = input.float(0.5, "DVS Sensitivity", minval=0.3, maxval=1.5, step=0.1, group=G_DVS, tooltip="Exponent scaling factor. Higher values translate to larger adjustments during sudden volatility shifts.")
float  i_threshold  = input.float(0.40, "Signal Threshold", minval=0.10, maxval=0.85, step=0.01, group=G_SIG, tooltip="Minimum structural score (0-1) for signal generation.\n" + "Master sensitivity: higher = fewer, more convicted signals.")
int    i_cooldown   = input.int(6, "Cooldown Bars", minval=1, maxval=50, group=G_SIG, tooltip="Minimum bars between signals. Prevents over-signaling.\n" + "Scaled by TF-Adaptive engine automatically.")
float  i_slMult     = input.float(1.5, "Stop ATR Mult", minval=0.5, maxval=4.0, step=0.1, group=G_TRADE, tooltip="ATR multiplier for stop loss distance.\n" + "Adaptive to current volatility regime.")
float  i_tpMult     = input.float(2.5, "TP ATR Mult", minval=1.0, maxval=6.0, step=0.25, group=G_TRADE, tooltip="ATR multiplier for final take profit (TP2).\n" + "TP1 auto-placed at 50% of this distance.")
int    i_maxBars    = input.int(30, "Max Trade Bars", minval=5, maxval=100, group=G_TRADE, tooltip="Time-based stop. Auto-close after N bars.\n" + "Represents thesis invalidation by elapsed time.")
string i_theme      = input.string("Neon", "Theme", options=["Neon", "Cyber", "Gold", "Ice", "Blood", "DAFE Signature", "Matrix"], group=G_VIS, tooltip="Color palette for all visuals.")
bool   i_showMani   = input.bool(true, "Transport Field Manifold", group=G_VIS, tooltip="Multi-layered bands showing momentum transport energy.\n" + "Expands with holonomy deficit/structural damage, contracts during clean geodesic flow.")
bool   i_showSiege  = input.bool(true, "Siege Corridors", group=G_VIS, tooltip="Dynamic S/R zones from MSL with hit count, decay, probability.")
bool   i_showGlitch = input.bool(true, "Holonomy Glitches", group=G_VIS, tooltip="Flags anomalous momentum rotation events.\n" + "Sudden angular discontinuities in the transport field.")
bool   i_showCandle = input.bool(true, "Transport Candle Auras", group=G_VIS, tooltip="Bar coloring based on transport deviation intensity.\n" + "Bright = large deviation from parallel transport path.")
bool   i_showVecField = input.bool(true, "Vector Field Lines", group=G_VIS, tooltip="Draws momentum vector direction indicators.\n" + "Shows transported vs. actual momentum visually.")
bool   i_showHoloRing = input.bool(true, "Holonomy Phase Ring", group=G_VIS, tooltip="Visual ring/arc showing cumulative holonomy phase.\n" + "Color shifts as angular deficit accumulates toward regime shift.")
bool   i_showDash   = input.bool(true, "Holonomy Dashboard", group=G_DASH, tooltip="Main quantitative dashboard with all engine metrics.")
bool   i_showNarr   = input.bool(true, "Narrative Panel", group=G_DASH, tooltip="Human-readable market state interpretation.")
// ═══════════════════════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════════════════════
viz.Theme TH = viz.get_theme(i_theme)
// ═══════════════════════════════════════════════════════════════════════════════
// INTERNAL TYPES
// ═══════════════════════════════════════════════════════════════════════════════
type MomentumVector
    float angle     = 0.0
    float magnitude = 0.0
    float dp        = 0.0
    float dv        = 0.0
type TransportState
    float parallel_angle    = 0.0
    float actual_angle      = 0.0
    float deviation         = 0.0
    float angular_velocity  = 0.0
    float geodesic_dev      = 0.0
type HolonomyState
    float cumulative_angle  = 0.0
    float phase             = 0.0
    float spike_strength    = 0.0
    bool  regime_shift      = false
    string regime_type      = "stable"
    int   bars_since_shift  = 0
type TradeState
    string side     = ""
    int    bar      = 0
    bool   closed   = true
    bool   h1       = false
    bool   isWT     = true
    int    tier     = 0
    float  entryATR = 1.0
    float  en       = na
    float  stop     = na
    float  t1       = na
    float  t2       = na
type TradeStats
    int    total      = 0
    int    wins       = 0
    int    losses     = 0
    float  grossProf  = 0.0
    float  grossLoss  = 0.0
    float  totalPnl   = 0.0
    float  peakEq     = 0.0
    float  maxDD      = 0.0
type ActiveSig
    string sigType = ""
    float  sc      = 0.0
    float  en      = na
    float  stop    = na
    float  t1      = na
    float  t2      = na
    int    tier    = 0
    bool   isWT    = true
// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
float EPS = 1e-10
_nz(float v, float fb) => na(v) or v != v ? fb : v
_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
_safeDiv(float a, float b, float fb) => math.abs(b) > EPS ? a / b : fb
_fNorm(float x) =>
    float v = _clamp(x, -8.0, 8.0)
    (math.exp(2.0 * v) - 1.0) / (math.exp(2.0 * v) + 1.0)
_fStr(float val, int d) => na(val) ? "—" : str.tostring(val, d == 0 ? "#" : d == 1 ? "#.#" : d == 2 ? "#.##" : "#.###")
_angleDiff(float a, float b) =>
    float d = a - b
    float PI = math.pi
    float TWO_PI = 2.0 * PI
    d - TWO_PI * math.floor((d + PI) / TWO_PI)
_atan2(float y, float x) =>
    float PI = math.pi
    if math.abs(x) < EPS and math.abs(y) < EPS
        0.0
    else if math.abs(x) < EPS
        y > 0 ? PI / 2.0 : -PI / 2.0
    else
        math.atan(y / x) + (x < 0 ? (y >= 0 ? PI : -PI) : 0.0)
// ═══════════════════════════════════════════════════════════════════════════════
// TF-ADAPTIVE SCALING & RCM BRAIN INITIALIZATION
// ═══════════════════════════════════════════════════════════════════════════════
float tfMinutes = timeframe.in_seconds() / 60.0
if i_tfPreset == "1m-5m Scalp"
    tfMinutes := 3.0
else if i_tfPreset == "10m-15m Intra"
    tfMinutes := 12.0
else if i_tfPreset == "30m-1H Swing"
    tfMinutes := 45.0
else if i_tfPreset == "4H-D Position"
    tfMinutes := 240.0
float tfScoreScale    = tfMinutes <= 5 ? 1.55 : tfMinutes <= 15 ? 1.35 : tfMinutes <= 60 ? 1.0 : 0.9
float tfCooldownScale = tfMinutes <= 5 ? 3.5 : tfMinutes <= 15 ? 2.5 : tfMinutes <= 60 ? 1.0 : 0.7
float tfTrendScale    = tfMinutes <= 5 ? 2.5 : tfMinutes <= 15 ? 2.0 : tfMinutes <= 60 ? 1.0 : 0.7
float tfCtStrictness  = tfMinutes <= 5 ? 1.4 : tfMinutes <= 15 ? 1.25 : tfMinutes <= 60 ? 1.0 : 0.85
int scaledPivLen = math.max(3, math.round(i_pivLen * (tfMinutes <= 5 ? 3.0 : tfMinutes <= 15 ? 2.0 : tfMinutes <= 60 ? 1.0 : 0.7)))
int vecFast = math.max(3, math.round(i_vecFast * (tfMinutes <= 5 ? 1.5 : tfMinutes <= 15 ? 1.2 : 1.0)))
int vecMed  = math.max(8, math.round(i_vecMed * (tfMinutes <= 5 ? 1.3 : tfMinutes <= 15 ? 1.1 : 1.0)))
int vecSlow = math.max(13, math.round(i_vecSlow * (tfMinutes <= 5 ? 1.2 : tfMinutes <= 15 ? 1.1 : 1.0)))
int holoWin = math.max(8, math.round(i_holoWin * (tfMinutes <= 5 ? 1.3 : tfMinutes <= 15 ? 1.1 : 1.0)))
var rcm.RCMConfig rcmCfg = na
if i_tfPreset == "1m-5m Scalp" or (i_tfPreset == "Auto" and tfMinutes <= 5.0)
    rcmCfg := rcm.scalp_config()
else if i_tfPreset == "4H-D Position" or (i_tfPreset == "Auto" and tfMinutes >= 240.0)
    rcmCfg := rcm.swing_config()
else
    rcmCfg := rcm.default_config()
var rcm.RCMState rcmState = rcm.RCMState.new()
// ═══════════════════════════════════════════════════════════════════════════════
// ENSEMBLE DVS SYSTEM - CONSTRAINED GLOBAL CALLS
// ═══════════════════════════════════════════════════════════════════════════════
f_vol_atr(int pd) =>
    ta.atr(pd) / close
f_vol_parkinson(int pd) =>
    float sum = 0.0
    for i = 0 to pd - 1
        float hl = math.log(high[i] / math.max(low[i], 1e-10))
        sum += hl * hl
    math.sqrt(sum / (4.0 * pd * math.log(2.0)))
f_vol_garman_klass(int pd) =>
    float sum = 0.0
    for i = 0 to pd - 1
        float hl = math.log(high[i] / math.max(low[i], 1e-10))
        float co = math.log(close[i] / math.max(open[i], 1e-10))
        sum += 0.5 * hl * hl - (2.0 * math.log(2.0) - 1.0) * co * co
    math.sqrt(math.max(sum / pd, 0.0))
float rawAtr  = f_vol_atr(14)
float rawPark = f_vol_parkinson(14)
float rawGk   = f_vol_garman_klass(14)
float baseAtr  = ta.sma(rawAtr, i_dvsMemory)
float basePark = ta.sma(rawPark, i_dvsMemory)
float baseGk   = ta.sma(rawGk, i_dvsMemory)
f_getDVS(string method, float rAtr, float bAtr, float rPark, float bPark, float rGk, float bGk, float sensitivity) =>
    float volCurrent = 1.0
    float volBaseline = 1.0 
    if method == "ATR Ratio"
        volCurrent := rAtr
        volBaseline := bAtr
    else if method == "Parkinson"
        volCurrent := rPark
        volBaseline := bPark
    else if method == "Garman-Klass"
        volCurrent := rGk
        volBaseline := bGk
    else 
        float r1 = bAtr > 0 ? rAtr / bAtr : 1.0
        float r2 = bPark > 0 ? rPark / bPark : 1.0
        float r3 = bGk > 0 ? rGk / bGk : 1.0
        float med = r1 > r2 ? (r2 > r3 ? r2 : (r1 > r3 ? r3 : r1)) : (r1 > r3 ? r1 : (r2 > r3 ? r3 : r2))
        volCurrent := med
        volBaseline := 1.0
    float ratio = volBaseline > 0 ? volCurrent / volBaseline : 1.0
    float scaled = math.pow(ratio, sensitivity)
    _clamp(scaled, 0.5, 2.5)
float dvsRatio = i_enableDVS ? ta.ema(f_getDVS(i_dvsMethod, rawAtr, baseAtr, rawPark, basePark, rawGk, baseGk, i_dvsSensitivity), 5) : 1.0
rcmCfg.damageThreshold := rcmCfg.damageThreshold * _clamp(dvsRatio, 0.7, 1.4)
// ═══════════════════════════════════════════════════════════════════════════════
// DERIVED SERIES & FOOTPRINT/SYNTHETIC ENGINE INTEGRATION
// ═══════════════════════════════════════════════════════════════════════════════
float atr14    = ta.atr(14)
float ema9     = ta.ema(close, 9)
float ema21    = ta.ema(close, 21)
float ema50    = ta.ema(close, 50)
float rsi14    = ta.rsi(close, 14)
float vol20    = ta.sma(volume, 20)
float atrLast  = _nz(atr14, 1.0)
var float volEma20 = 0.0
float vAlpha = 2.0 / 21.0
volEma20 := bar_index == 0 ? math.max(volume, 1.0) : vAlpha * volume + (1.0 - vAlpha) * volEma20
float relVol = volEma20 > 0 ? volume / volEma20 : 1.0
footprint fp   = i_useFp ? request.footprint(i_fpTicks, i_fpVA) : na
bool fpActive  = not na(fp)
float rng      = high - low
float _bar_range    = rng
float _body         = math.abs(close - open)
float _upper_wick   = high - math.max(open, close)
float _lower_wick   = math.min(open, close) - low
float _bar_loc      = _bar_range > 0 ? (close - low) / _bar_range : 0.5
float _loc_bias     = (_bar_loc - 0.5) * 2.0
float _wick_pressure = 0.0
if _upper_wick > _lower_wick * 2.2 and _upper_wick > _body * 0.35
    _wick_pressure := -0.45
else if _lower_wick > _upper_wick * 2.2 and _lower_wick > _body * 0.35
    _wick_pressure := 0.45
float _trend_dir = close > open ? 1.0 : close < open ? -1.0 : 0.0
var float _prev_delta_store = 0.0
float _momentum    = _clamp(_prev_delta_store * 0.30, -0.25, 0.25)
float _vol_stdev   = ta.stdev(volume, 20)
float _vol_z       = vol20 > 0 ? (volume - vol20) / (_vol_stdev + EPS) : 0.0
float _vol_boost   = 1.0 + _clamp(_vol_z * 0.18, -0.25, 0.50)
float _range_z     = atr14 > 0 ? _bar_range / atr14 : 1.0
float _range_factor = _range_z > 1.6 ? 1.25 : _range_z < 0.4 ? 0.55 : 1.0
float est_delta       = fpActive ? fp.delta() : volume * _clamp((_loc_bias * 0.50 + _trend_dir * 0.22 + _wick_pressure + _momentum) * _vol_boost * _range_factor, -0.95, 0.95)
float delta_ratio_raw = fpActive ? (fp.buy_volume() + fp.sell_volume() > 0 ? fp.delta() / (fp.buy_volume() + fp.sell_volume()) : 0.0) : (vol20 > 0 ? est_delta / vol20 : 0.0)
float delta_ratio     = _clamp(delta_ratio_raw, -1.0, 1.0)
_prev_delta_store    := delta_ratio
float buyPress  = fpActive ? fp.buy_volume() : (volume + est_delta) / 2.0
float sellPress = fpActive ? fp.sell_volume() : (volume - est_delta) / 2.0
float delta     = fpActive ? fp.delta() : est_delta
float abs_range_ratio  = atr14 > 0 ? rng / atr14 : 1.0
float abs_vol_ratio    = vol20 > 0 ? volume / vol20 : 1.0
float absorption_synth = abs_vol_ratio > 1.25 and abs_range_ratio < 0.60 ? _clamp(abs_vol_ratio * (1.0 - abs_range_ratio) * 1.8, 0.0, 2.0) / 2.0 : 0.0
float absorption = fpActive ? (((close > open and delta < 0) or (close < open and delta > 0)) ? 1.0 : (math.abs(close - open) < rng * 0.3 and volume > volEma20) ? 0.7 : 0.0) : absorption_synth
// ═══════════════════════════════════════════════════════════════════════════════
// LIQUIDITY MICROSTRUCTURE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
int FAST_LEN = 8
int SLOW_LEN = 34
float fastCumDelta = math.sum(delta, FAST_LEN)
float slowCumDelta = math.sum(delta, SLOW_LEN)
var float fdMn = 0.0, var float fdVr = 1.0
var float sdMn = 0.0, var float sdVr = 1.0
var float klMn = 0.0, var float klVr = 1.0
float aZ = 2.0 / (math.max(bar_index + 1, 20) + 1.0)
fdMn := fdMn * (1.0 - aZ) + fastCumDelta * aZ
float fdD = fastCumDelta - fdMn
fdVr := fdVr * (1.0 - aZ) + fdD * fdD * aZ
float fastDeltaZ = math.sqrt(math.max(fdVr, EPS)) > 0 ? _clamp(fdD / math.sqrt(math.max(fdVr, EPS)), -4.0, 4.0) : 0.0
sdMn := sdMn * (1.0 - aZ) + slowCumDelta * aZ
float sdD = slowCumDelta - sdMn
sdVr := sdVr * (1.0 - aZ) + sdD * sdD * aZ
float slowDeltaZ = math.sqrt(math.max(sdVr, EPS)) > 0 ? _clamp(sdD / math.sqrt(math.max(sdVr, EPS)), -4.0, 4.0) : 0.0
float fVel = fastDeltaZ - nz(fastDeltaZ[1])
float sVel = slowDeltaZ - nz(slowDeltaZ[1])
float pVel = bar_index >= 5 and nz(close[5]) > 0 ? (close - nz(close[5])) / nz(close[5]) * 100.0 : 0.0
float divRaw = fastDeltaZ - slowDeltaZ
float disagree = math.abs(divRaw)
float velAgree = fVel * sVel > 0 ? 1.0 : 0.5
var string divType = "aligned"
var float  divConf = 0.0
if disagree < 0.5
    divType := "aligned"
    divConf := (1.0 - disagree / 0.5) * velAgree
else if fastDeltaZ > 0.5 and slowDeltaZ < -0.3 and pVel > 0
    divType := "absorption"
    divConf := _clamp(disagree / 2.0, 0.0, 1.0) * _clamp(relVol, 0.0, 1.0) * velAgree
else if fastDeltaZ < -0.5 and slowDeltaZ > 0.3 and pVel < 0
    divType := "accumulation"
    divConf := _clamp(disagree / 2.0, 0.0, 1.0) * _clamp(relVol, 0.0, 1.0) * velAgree
else if math.abs(fastDeltaZ) > 2.0 and math.abs(sVel) < 0.3
    divType := "exhaustion"
    divConf := _clamp((math.abs(fastDeltaZ) - 2.0) / 2.0, 0.0, 1.0) * (1.0 - _clamp(math.abs(sVel), 0.0, 1.0))
else if math.abs(fastDeltaZ) < 0.5 and math.abs(pVel) < 0.3 and math.abs(slowDeltaZ) > 1.0
    divType := "stealth"
    divConf := _clamp((math.abs(slowDeltaZ) - 1.0) / 2.0, 0.0, 1.0) * (1.0 - math.abs(fastDeltaZ)) * velAgree
else if disagree >= 0.5
    divType := fastDeltaZ > 0 and slowDeltaZ < 0 ? "absorption" : fastDeltaZ < 0 and slowDeltaZ > 0 ? "accumulation" : "aligned"
    divConf := _clamp(disagree / 3.0, 0.0, 1.0) * velAgree
float divScore = _clamp(divRaw / 3.0, -1.0, 1.0)
string flowRegime = slowDeltaZ > 1.0 and sVel > 0 ? "accum" : 
     slowDeltaZ < -1.0 and sVel < 0 ? "distrib" : 
     (divType == "stealth" or divType == "accumulation" or divType == "absorption") and math.abs(divScore) > 0.3 ? "transition" : "balanced"
var float kyleLambda = 0.0
if bar_index >= 20
    float covPS = 0.0, float varSV = 0.0
    for k = 0 to 19
        float pc2 = nz(close[k + 1])
        if pc2 > 0
            float pChg = nz(close[k]) - pc2
            float rng2 = nz(high[k]) - nz(low[k])
            float bDir = nz(close[k]) > nz(open[k]) ? 1.0 : nz(close[k]) < nz(open[k]) ? -1.0 : 0.0
            float rangePos = rng2 > 0 ? ((nz(close[k]) - nz(low[k])) - (nz(high[k]) - nz(close[k]))) / rng2 : 0.0
            float signW = rangePos * 0.7 + bDir * 0.3
            float signedVol = nz(volume[k]) * signW
            covPS += pChg * signedVol
            varSV += signedVol * signedVol
    covPS /= 20.0
    varSV /= 20.0
    kyleLambda := varSV > EPS ? math.abs(covPS / varSV) : 0.0
klMn := klMn * (1.0 - aZ) + kyleLambda * aZ
float klD = kyleLambda - klMn
klVr := klVr * (1.0 - aZ) + klD * klD * aZ
float kyleLambdaZ = math.sqrt(math.max(klVr, EPS)) > 0 ? _clamp(klD / math.sqrt(math.max(klVr, EPS)), -4.0, 4.0) : 0.0
float liqComp = kyleLambdaZ * 0.4
float volContrib = relVol < 0.5 ? (0.5 - relVol) * 4.0 : relVol > 2.0 ? -(relVol - 2.0) * 0.5 : 0.0
liqComp += volContrib * 0.35
liqComp += (absorption > 0.5 ? -0.3 : 0.0) * 0.25
int liqRegime = liqComp < -0.5 ? 1 : liqComp < 0.8 ? 2 : liqComp < 1.8 ? 3 : liqComp < 2.5 ? 4 : 5
float liqPenalty = liqRegime <= 1 ? 1.0 : liqRegime == 2 ? 1.0 : liqRegime == 3 ? 0.7 : liqRegime == 4 ? 0.4 : 0.2
string liqName = liqRegime <= 1 ? "Deep" : liqRegime == 2 ? "Normal" : liqRegime == 3 ? "Thin" : liqRegime == 4 ? "Desert" : "Frozen"
float danger = _clamp(kyleLambdaZ * 8.0, 0.0, 25.0)
if relVol < 0.5
    danger += (0.5 - relVol) * 40.0
if divType == "absorption" or divType == "exhaustion"
    danger += divConf * 20.0
else if divType == "stealth"
    danger += divConf * 12.0
if liqRegime >= 3
    danger += liqRegime * 3.0
danger := _clamp(danger, 0.0, 100.0)
// ═══════════════════════════════════════════════════════════════════════════════
// HURST EXPONENT & ENTROPY
// ═══════════════════════════════════════════════════════════════════════════════
float uWick = high - math.max(open, close)
float lWick = math.min(open, close) - low
float fpDelta = rng > 0 ? volume * ((close - low) - (high - close)) / rng : 0.0
var float hurstVal = 0.5
float hMean = ta.sma(close, i_hurstPd)
float hStd  = ta.stdev(close, i_hurstPd)
if bar_index >= i_hurstPd
    float cumDev = 0.0, float maxD = 0.0, float minD = 0.0
    for k = 0 to i_hurstPd - 1
        cumDev += nz(close[k]) - hMean
        maxD := math.max(maxD, cumDev)
        minD := math.min(minD, cumDev)
    float rs = hStd > 0 ? (maxD - minD) / hStd : 0.0
    hurstVal := rs > 0 ? _clamp(math.log(rs) / math.log(i_hurstPd), 0.2, 0.8) : 0.5
float dv_price = _safeDiv(close - nz(close[1]), nz(close[1], close), 0.0)
float dv_vol   = _safeDiv(volume - nz(volume[1], 1.0), math.max(nz(volume[1], 1.0), 1.0), 0.0)
float alphaT = _clamp(0.15 * (1.2 - hurstVal), 0.02, 0.25)
var float varPrice = 0.0, var float varVol = 0.0, var float covPV = 0.0, var float lastDet = 1.0
varPrice := alphaT * (dv_price * dv_price) + (1.0 - alphaT) * varPrice
varVol   := alphaT * (dv_vol * dv_vol) + (1.0 - alphaT) * varVol
covPV    := alphaT * (dv_price * dv_vol) + (1.0 - alphaT) * covPV
float det = math.max(varPrice * varVol - covPV * covPV, EPS)
float detRoc = _safeDiv(det - lastDet, lastDet, 0.0)
lastDet := det
var float curvEma = 0.0
curvEma := 0.15 * _fNorm(detRoc * -10.0) + 0.85 * curvEma
float instEnt = math.abs(dv_price) > EPS ? -math.abs(dv_price) * math.log(math.abs(dv_price)) : 0.0
var float entEma = 0.0
entEma := 0.05 * instEnt + 0.95 * entEma
float normEnt = _fNorm(entEma * 50.0)
float tStr = _safeDiv(math.abs(ema9 - ema50), atr14, 0.0)
string regime = tStr > 1.2 and hurstVal > 0.55 ? "TREND" : tStr < 0.5 and hurstVal < 0.45 ? "CHOP" : tStr > 0.8 ? "DRIFT" : "RANGE"
int curTD = ema9 > ema50 ? 1 : ema9 < ema50 ? -1 : 0
var int prevTD = 0, var int trendBars = 0
if curTD != prevTD
    trendBars := 0
    prevTD := curTD
else
    trendBars += 1
// ═══════════════════════════════════════════════════════════════════════════════
// MOMENTUM VECTOR FIELD CONSTRUCTION
// ═══════════════════════════════════════════════════════════════════════════════
var float pChgMean = 0.0, var float pChgVar = 0.001
var float vChgMean = 0.0, var float vChgVar = 0.001
float zAlpha = 2.0 / (math.max(bar_index + 1, 50) + 1.0)
float rawPriceChg = close - nz(close[1])
float rawVolChg   = volume - nz(volume[1], volume)
pChgMean := pChgMean * (1.0 - zAlpha) + rawPriceChg * zAlpha
float pDev = rawPriceChg - pChgMean
pChgVar := pChgVar * (1.0 - zAlpha) + pDev * pDev * zAlpha
vChgMean := vChgMean * (1.0 - zAlpha) + rawVolChg * zAlpha
float vDev = rawVolChg - vChgMean
vChgVar := vChgVar * (1.0 - zAlpha) + vDev * vDev * zAlpha
float pChgNorm = math.sqrt(math.max(pChgVar, EPS))
float vChgNorm = math.sqrt(math.max(vChgVar, EPS))
float dpFast = 0.0, float dvFast = 0.0
for k = 0 to math.min(vecFast - 1, bar_index)
    dpFast += (nz(close[k]) - nz(close[k + 1])) / pChgNorm
    dvFast += (nz(volume[k]) - nz(volume[k + 1], nz(volume[k]))) / vChgNorm
dpFast /= vecFast
dvFast /= vecFast
float fpWeight = fpActive ? _clamp(delta / math.max(volume * 0.1, 1.0), -1.0, 1.0) * 0.3 : 0.0
dpFast += fpWeight
float angleFast = _atan2(dvFast, dpFast)
float magFast   = math.sqrt(dpFast * dpFast + dvFast * dvFast)
float dpMed = 0.0, float dvMed = 0.0
for k = 0 to math.min(vecMed - 1, bar_index)
    dpMed += (nz(close[k]) - nz(close[k + 1])) / pChgNorm
    dvMed += (nz(volume[k]) - nz(volume[k + 1], nz(volume[k]))) / vChgNorm
dpMed /= vecMed
dvMed /= vecMed
float angleMed = _atan2(dvMed, dpMed)
float magMed   = math.sqrt(dpMed * dpMed + dvMed * dvMed)
float dpSlow = 0.0, float dvSlow = 0.0
for k = 0 to math.min(vecSlow - 1, bar_index)
    dpSlow += (nz(close[k]) - nz(close[k + 1])) / pChgNorm
    dvSlow += (nz(volume[k]) - nz(volume[k + 1], nz(volume[k]))) / vChgNorm
dpSlow /= vecSlow
dvSlow /= vecSlow
float angleSlow = _atan2(dvSlow, dpSlow)
float magSlow   = math.sqrt(dpSlow * dpSlow + dvSlow * dvSlow)
// ═══════════════════════════════════════════════════════════════════════════════
// CONNECTION COEFFICIENTS 
// ═══════════════════════════════════════════════════════════════════════════════
float g11 = math.max(varPrice, EPS)  
float g12 = covPV                    
float g22 = math.max(varVol, EPS)   
float g11_prev = nz(g11[1], g11)
float g12_prev = nz(g12[1], g12)
float g22_prev = nz(g22[1], g22)
float dg11 = g11 - g11_prev
float dg12 = g12 - g12_prev
float dg22 = g22 - g22_prev
float gDet = math.max(g11 * g22 - g12 * g12, EPS)
float gi11 = g22 / gDet
float gi12 = -g12 / gDet
float gi22 = g11 / gDet
float christoffel = (gi11 * dg12 + gi12 * dg22 - gi12 * dg11) / 2.0
float hurstConnectionScale = _clamp(1.0 + (0.5 - hurstVal) * 2.0, 0.5, 2.0)
float connectionStrength = christoffel * hurstConnectionScale
// ═══════════════════════════════════════════════════════════════════════════════
// PARALLEL TRANSPORT & COVARIANT DERIVATIVE
// ═══════════════════════════════════════════════════════════════════════════════
float dAngleFast = _angleDiff(angleFast, nz(angleFast[1], angleFast))
float dAngleMed  = _angleDiff(angleMed, nz(angleMed[1], angleMed))
float dAngleSlow = _angleDiff(angleSlow, nz(angleSlow[1], angleSlow))
float parallelAngleFast = nz(angleFast[1], angleFast) + connectionStrength
float parallelAngleMed  = nz(angleMed[1], angleMed) + connectionStrength * 0.7
float parallelAngleSlow = nz(angleSlow[1], angleSlow) + connectionStrength * 0.4
float transportDevFast = _angleDiff(angleFast, parallelAngleFast)
float transportDevMed  = _angleDiff(angleMed, parallelAngleMed)
float transportDevSlow = _angleDiff(angleSlow, parallelAngleSlow)
float transportDev = transportDevFast * 0.25 + transportDevMed * 0.45 + transportDevSlow * 0.30
float angVelFast = dAngleFast
float angVelMed  = dAngleMed
float angVelSlow = dAngleSlow
var float geodesicAcc = 0.0
float geodesicAlpha = 0.1
geodesicAcc := geodesicAcc * (1.0 - geodesicAlpha) + math.abs(transportDev) * geodesicAlpha
var float geodMn = 0.0, var float geodVr = 0.001
geodMn := geodMn * (1.0 - zAlpha) + geodesicAcc * zAlpha
float geodD = geodesicAcc - geodMn
geodVr := geodVr * (1.0 - zAlpha) + geodD * geodD * zAlpha
float geodesicDevZ = _clamp(geodD / math.sqrt(math.max(geodVr, EPS)), -4.0, 4.0)
float signedTransport = transportDev
var float transportEma = 0.0
transportEma := 0.12 * signedTransport + 0.88 * transportEma
// ═══════════════════════════════════════════════════════════════════════════════
// HOLONOMY ACCUMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
float holoSum = 0.0
float holoAbsSum = 0.0
for k = 0 to math.min(holoWin - 1, bar_index)
    float td_k = nz(transportDev[k])
    holoSum += td_k
    holoAbsSum += math.abs(td_k)
float holonomyMag = math.abs(holoSum)
var float holoMn = 0.0, var float holoVr = 0.001
holoMn := holoMn * (1.0 - zAlpha) + holonomyMag * zAlpha
float holoD = holonomyMag - holoMn
holoVr := holoVr * (1.0 - zAlpha) + holoD * holoD * zAlpha
float holonomyZ = _clamp(holoD / math.sqrt(math.max(holoVr, EPS)), -4.0, 4.0)
float holonomyNorm = _clamp(holonomyZ / 4.0, 0.0, 1.0)
float holonomySign = holoSum > 0 ? 1.0 : holoSum < 0 ? -1.0 : 0.0
float holonomyPhase = _clamp(holoSum / math.max(math.pi, EPS), -1.0, 1.0)
float crossScaleAngle = _angleDiff(angleFast, angleSlow)
float crossScaleHolo  = math.abs(crossScaleAngle)
var float crossHoloMn = 0.0, var float crossHoloVr = 0.001
crossHoloMn := crossHoloMn * (1.0 - zAlpha) + crossScaleHolo * zAlpha
float crossHoloD = crossScaleHolo - crossHoloMn
crossHoloVr := crossHoloVr * (1.0 - zAlpha) + crossHoloD * crossHoloD * zAlpha
float crossHoloZ = _clamp(crossHoloD / math.sqrt(math.max(crossHoloVr, EPS)), -4.0, 4.0)
// ═══════════════════════════════════════════════════════════════════════════════
// HOLONOMY REGIME CLASSIFICATION
// ═══════════════════════════════════════════════════════════════════════════════
var HolonomyState holo = HolonomyState.new()
holo.cumulative_angle := holonomyMag
holo.phase := holonomyPhase
holo.bars_since_shift += 1
float holoSpikeRaw = holonomyZ
bool holoSpike = holonomyNorm > i_holoThresh and holo.bars_since_shift > 5
holo.spike_strength := holoSpike ? holonomyNorm : 0.0
if holoSpike
    holo.regime_shift := true
    holo.bars_since_shift := 0
    if holonomySign > 0 and crossScaleAngle > 0
        holo.regime_type := "bull_rotation"
    else if holonomySign < 0 and crossScaleAngle < 0
        holo.regime_type := "bear_rotation"
    else if geodesicDevZ > i_geodesicSens
        holo.regime_type := "geodesic_break"
    else if crossHoloZ > 2.0
        holo.regime_type := "scale_divergence"
    else
        holo.regime_type := "phase_shift"
else
    holo.regime_shift := false
    if holo.bars_since_shift > 10
        holo.regime_type := holonomyNorm < 0.15 ? "stable" : holonomyNorm < 0.25 ? "drifting" : "rotating"
float transportPersist = 0.0
int persistCount = 0
for k = 0 to math.min(13, bar_index)
    if nz(transportDev[k]) * transportDev > 0
        persistCount += 1
transportPersist := persistCount / 14.0
string holonomyGroup = holonomyNorm < 0.10 ? "trivial" : holonomyNorm < 0.25 ? "abelian" : holonomyNorm < 0.50 ? "non-abelian" : "singular"  
// ═══════════════════════════════════════════════════════════════════════════════
// PRESSURE BAR
// ═══════════════════════════════════════════════════════════════════════════════
float uWickSma60 = ta.sma(uWick, 60)
float uWickStd60 = ta.stdev(uWick, 60)
float lWickSma60 = ta.sma(lWick, 60)
float lWickStd60 = ta.stdev(lWick, 60)
float uZ = uWickStd60 > 0 ? _clamp((uWick - uWickSma60) / uWickStd60, -4.0, 4.0) : 0.0
float lZ = lWickStd60 > 0 ? _clamp((lWick - lWickSma60) / lWickStd60, -4.0, 4.0) : 0.0
float pBar = bar_index >= 60 ? _clamp(
     (lWick / math.max(rng, EPS) * 100.0 * (lZ > 1 ? 1.5 : 1.0)) - 
     (uWick / math.max(rng, EPS) * 100.0 * (uZ > 1 ? 1.5 : 1.0)) + 
     fpDelta / math.max(volume, 1.0) * 35.0 + 
     (close > open ? 4.0 : -4.0) +
     signedTransport * 15.0,  
     -100.0, 100.0) : 0.0
// ═══════════════════════════════════════════════════════════════════════════════
// GLITCH DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
var float glitchScore = 0.0
float gSc = 0.0
if math.abs(rng - nz(high[1] - low[1])) < EPS and rng > 0
    gSc += 0.4
if math.abs(close - open) < EPS and rng > atr14 * 0.3
    gSc += 0.3
if math.abs(close - nz(high[1])) < EPS or math.abs(close - nz(low[1])) < EPS
    gSc += 0.3
if math.abs(transportDevFast) > math.pi * 0.6
    gSc += 0.5
if crossHoloZ > 3.0
    gSc += 0.4
glitchScore := gSc > 0.5 ? glitchScore + gSc : math.max(0.0, glitchScore - 0.1)
bool glitchFire = glitchScore >= 1.2 and i_showGlitch
if glitchFire
    glitchScore := 0.0
// ═══════════════════════════════════════════════════════════════════════════════
// MSL STRUCTURE INTEGRATION
// ═══════════════════════════════════════════════════════════════════════════════
var float prevPocMid = na
float curPocMid = na
if fpActive
    volume_row fpPocRow = fp.poc()
    curPocMid := (fpPocRow.up_price() + fpPocRow.down_price()) / 2.0
else
    curPocMid := (high + low + close) / 3.0
msl.MarketContext mCtx = msl.get_market_context(open, high, low, close, volume, fp, vol20, prevPocMid, atr14)
prevPocMid := curPocMid
var array<float> shPrices = array.new_float()
var array<int>   shBars   = array.new_int()
var array<float> slPrices = array.new_float()
var array<int>   slBars   = array.new_int()
[shP, shB] = msl.detect_swing_high(scaledPivLen)
[slP, slB] = msl.detect_swing_low(scaledPivLen)
if not na(shP)
    array.unshift(shPrices, shP)
    array.unshift(shBars, shB)
    if array.size(shPrices) > 10
        array.pop(shPrices)
        array.pop(shBars)
if not na(slP)
    array.unshift(slPrices, slP)
    array.unshift(slBars, slB)
    if array.size(slPrices) > 10
        array.pop(slPrices)
        array.pop(slBars)
var array<float> lbH = array.new_float()
var array<float> lbL = array.new_float()
var array<float> lbC = array.new_float()
var array<float> lbV = array.new_float()
int VP_LB = 100
array.unshift(lbH, high)
array.unshift(lbL, low)
array.unshift(lbC, close)
array.unshift(lbV, volume)
if array.size(lbH) > VP_LB
    array.pop(lbH), array.pop(lbL), array.pop(lbC), array.pop(lbV)
[poc, vah, val_] = msl.calc_unified_poc_va(lbH, lbL, lbC, lbV, 24, fp)
var msl.MultiTFStructure structure = msl.create_structure()
structure.tf1 := msl.update_structure(structure.tf1, poc, vah, val_, shPrices, shBars, slPrices, slBars, timeframe.period, atr14, mCtx)
bool atSiegeRes = msl.check_siege_proximity(close, structure.tf1.res_corridor, atr14)
bool atSiegeSup = msl.check_siege_proximity(close, structure.tf1.sup_corridor, atr14)
msl.StructureState sState = msl.get_structure_state(structure, close, atSiegeRes or atSiegeSup)
float siegeResProj = structure.tf1.res_corridor.is_active ? msl.project_siege_price(structure.tf1.res_corridor, bar_index) : na
float siegeSupProj = structure.tf1.sup_corridor.is_active ? msl.project_siege_price(structure.tf1.sup_corridor, bar_index) : na
float siegeResDist = not na(siegeResProj) and atr14 > 0 ? (siegeResProj - close) / atr14 : 99.0
float siegeSupDist = not na(siegeSupProj) and atr14 > 0 ? (close - siegeSupProj) / atr14 : 99.0
float siegeResHold = 0.5, float siegeSupHold = 0.5
string siegeResAction = "neutral", string siegeSupAction = "neutral"
if atSiegeRes and structure.tf1.res_corridor.is_active
    siegeResHold := _clamp(0.5 + (structure.tf1.res_corridor.decay > 0.7 ? 0.15 : -0.1) + (mCtx.absorption > 0.5 ? 0.1 : 0.0), 0.1, 0.9)
    siegeResAction := mCtx.absorption > 0.5 ? "absorbing" : delta > 0 ? "defending" : delta < 0 ? "attacking" : "neutral"
if atSiegeSup and structure.tf1.sup_corridor.is_active
    siegeSupHold := _clamp(0.5 + (structure.tf1.sup_corridor.decay > 0.7 ? 0.15 : -0.1) + (mCtx.absorption > 0.5 ? 0.1 : 0.0), 0.1, 0.9)
    siegeSupAction := mCtx.absorption > 0.5 ? "absorbing" : delta < 0 ? "defending" : delta > 0 ? "attacking" : "neutral"
// ═══════════════════════════════════════════════════════════════════════════════
// 5-CATEGORY PATTERN ENGINE WITH RL LEARNING WEIGHTS
// ═══════════════════════════════════════════════════════════════════════════════
var float wCandle    = 1.0
var float wStructure = 1.0
var float wGeometry  = 1.0
var float wVsa       = 1.0
var float wMomentum  = 1.0
float PLASTICITY = 0.03
float FILTER_THRESH = 0.8
float curVolRatio = atr14 / math.max(close, 1.0)
float avgVolRatio = ta.sma(atr14 / math.max(close, 1.0), 100)
float dvsRatioPattern = avgVolRatio > 0 ? _clamp(curVolRatio / avgVolRatio, 0.5, 2.5) : 1.0
int recentBearBars = 0, int recentBullBars = 0
for i = 1 to math.min(5, bar_index)
    if nz(close[i]) < nz(open[i]) and (nz(high[i]) - nz(low[i])) > atr14 * 0.5
        recentBearBars += 1
    if nz(close[i]) > nz(open[i]) and (nz(high[i]) - nz(low[i])) > atr14 * 0.5
        recentBullBars += 1
bool strongSelloff = recentBearBars >= 3
bool strongRally   = recentBullBars >= 3
float body     = math.abs(close - open)
float bodyPrev = math.abs(nz(close[1]) - nz(open[1]))
bool isBull = close > open, bool isBear = close < open
bool prevBull = nz(close[1]) > nz(open[1]), bool prevBear = nz(close[1]) < nz(open[1])
bool insideBar = high < nz(high[1]) and low > nz(low[1])
var array<string> bullPats = array.new_string()
var array<string> bullCats = array.new_string()
var array<string> bearPats = array.new_string()
var array<string> bearCats = array.new_string()
array.clear(bullPats), array.clear(bullCats), array.clear(bearPats), array.clear(bearCats)
if not strongSelloff
    if isBull and prevBear and close > nz(open[1]) and open < nz(close[1])
        array.push(bullPats, "eng"), array.push(bullCats, "candle")
    if isBull and (math.min(close, open) - low) > rng * 0.6
        array.push(bullPats, "pin"), array.push(bullCats, "candle")
    if lWick > body * 2.0 and uWick < body * 0.3
        array.push(bullPats, "ham"), array.push(bullCats, "candle")
    if body < rng * 0.1 and rng > atr14 * 0.5 and close > ema21
        array.push(bullPats, "doji"), array.push(bullCats, "candle")
    if body > rng * 0.85 and isBull
        array.push(bullPats, "maru"), array.push(bullCats, "candle")
if not strongRally
    if isBear and prevBull and close < nz(open[1]) and open > nz(close[1])
        array.push(bearPats, "eng"), array.push(bearCats, "candle")
    if isBear and (high - math.max(close, open)) > rng * 0.6
        array.push(bearPats, "pin"), array.push(bearCats, "candle")
    if uWick > body * 2.0 and lWick < body * 0.3
        array.push(bearPats, "ham"), array.push(bearCats, "candle")
    if body < rng * 0.1 and rng > atr14 * 0.5 and close < ema21
        array.push(bearPats, "doji"), array.push(bearCats, "candle")
    if body > rng * 0.85 and isBear
        array.push(bearPats, "maru"), array.push(bearCats, "candle")
if insideBar
    if close > nz(close[1])
        array.push(bullPats, "ins"), array.push(bullCats, "structure")
    else
        array.push(bearPats, "ins"), array.push(bearCats, "structure")
if ema9 > ema21 and nz(ema9[1]) <= nz(ema21[1])
    array.push(bullPats, "emaCross"), array.push(bullCats, "structure")
if ema9 < ema21 and nz(ema9[1]) >= nz(ema21[1])
    array.push(bearPats, "emaCross"), array.push(bearCats, "structure")
if rsi14 < 30 and nz(rsi14[1]) >= 30 and not strongSelloff
    array.push(bullPats, "rsiSnap"), array.push(bullCats, "momentum")
if rsi14 > 70 and nz(rsi14[1]) <= 70 and not strongRally
    array.push(bearPats, "rsiSnap"), array.push(bearCats, "momentum")
float atr5 = ta.sma(atr14, 5)
float atr20 = ta.sma(atr14, 20)
if bar_index >= 20 and atr5 > atr20 * 1.3 and atr20 > 0
    if isBull
        array.push(bullPats, "squeeze"), array.push(bullCats, "momentum")
    else
        array.push(bearPats, "squeeze"), array.push(bearCats, "momentum")
if holoSpike and holonomySign > 0 and dpFast > 0
    array.push(bullPats, "holoShift"), array.push(bullCats, "geometry")
if holoSpike and holonomySign < 0 and dpFast < 0
    array.push(bearPats, "holoShift"), array.push(bearCats, "geometry")
if transportPersist > 0.7 and transportEma > 0
    array.push(bullPats, "geodesic"), array.push(bullCats, "geometry")
if transportPersist > 0.7 and transportEma < 0
    array.push(bearPats, "geodesic"), array.push(bearCats, "geometry")
if geodesicDevZ > i_geodesicSens and pBar > 15
    array.push(bullPats, "geodBreak"), array.push(bullCats, "geometry")
if geodesicDevZ > i_geodesicSens and pBar < -15
    array.push(bearPats, "geodBreak"), array.push(bearCats, "geometry")
if volume > _nz(vol20, 0.0) * (2.0 * dvsRatioPattern) and rng < atr14 * 0.8
    if close > open
        array.push(bearPats, "stopVol"), array.push(bearCats, "vsa")
    else
        array.push(bullPats, "stopVol"), array.push(bullCats, "vsa")
var array<string> filtBull = array.new_string()
var array<string> filtBear = array.new_string()
array.clear(filtBull), array.clear(filtBear)
for i = 0 to (array.size(bullPats) > 0 ? array.size(bullPats) - 1 : na)
    string cat = array.get(bullCats, i)
    float w = cat == "candle" ? wCandle : cat == "structure" ? wStructure : cat == "geometry" ? wGeometry : cat == "vsa" ? wVsa : wMomentum
    if w >= FILTER_THRESH
        array.push(filtBull, array.get(bullPats, i))
for i = 0 to (array.size(bearPats) > 0 ? array.size(bearPats) - 1 : na)
    string cat = array.get(bearCats, i)
    float w = cat == "candle" ? wCandle : cat == "structure" ? wStructure : cat == "geometry" ? wGeometry : cat == "vsa" ? wVsa : wMomentum
    if w >= FILTER_THRESH
        array.push(filtBear, array.get(bearPats, i))
bool strongBullPat = array.includes(filtBull, "eng") or array.includes(filtBull, "pin") or array.includes(filtBull, "maru") or array.includes(filtBull, "stopVol") or array.includes(filtBull, "holoShift")
bool strongBearPat = array.includes(filtBear, "eng") or array.includes(filtBear, "pin") or array.includes(filtBear, "maru") or array.includes(filtBear, "stopVol") or array.includes(filtBear, "holoShift")
// ═══════════════════════════════════════════════════════════════════════════════
// STRUCTURAL SIGNAL SCORING + HOLONOMY GATING
// ═══════════════════════════════════════════════════════════════════════════════
float lBase = 0.0, float sBase = 0.0
float lConf = 0.0, float sConf = 0.0
bool nearSup = siegeSupDist >= -0.3 and siegeSupDist < 1.2
bool nearRes = siegeResDist >= -0.3 and siegeResDist < 1.2
if nearSup
    lBase := math.max(lBase, 0.28 + siegeSupHold * 0.18)
    if siegeSupAction == "defending" or siegeSupAction == "absorbing"
        lBase := math.max(lBase, 0.42)
if nearRes
    sBase := math.max(sBase, 0.28 + siegeResHold * 0.18)
    if siegeResAction == "defending" or siegeResAction == "absorbing"
        sBase := math.max(sBase, 0.42)
float distE21 = math.abs(close - ema21) / math.max(atr14, EPS)
bool emaProx = distE21 < 0.5
if curTD == 1 and emaProx and close >= ema21 and (strongBullPat or pBar > 20)
    lBase := math.max(lBase, 0.25)
if curTD == -1 and emaProx and close <= ema21 and (strongBearPat or pBar < -20)
    sBase := math.max(sBase, 0.25)
float rsiExtLo = tfMinutes <= 15 ? 25.0 : 28.0
float rsiExtHi = tfMinutes <= 15 ? 75.0 : 72.0
if rsi14 < rsiExtLo
    lBase := math.max(lBase, 0.28)
if rsi14 > rsiExtHi
    sBase := math.max(sBase, 0.28)
if strongBullPat
    lBase := math.max(lBase, 0.28)
if strongBearPat
    sBase := math.max(sBase, 0.28)
if holo.regime_shift
    if holo.regime_type == "bull_rotation"
        lBase := math.max(lBase, 0.35 + holo.spike_strength * 0.15)
    else if holo.regime_type == "bear_rotation"
        sBase := math.max(sBase, 0.35 + holo.spike_strength * 0.15)
    else if holo.regime_type == "geodesic_break"
        if transportEma > 0
            lBase := math.max(lBase, 0.30)
        else
            sBase := math.max(sBase, 0.30)
if transportPersist > 0.75 and math.abs(transportEma) > 0.05
    if transportEma > 0
        lBase := math.max(lBase, 0.25)
    else
        sBase := math.max(sBase, 0.25)
if array.size(filtBull) >= 2
    lConf += 0.15
if array.size(filtBear) >= 2
    sConf += 0.15
if pBar > 35
    lConf += 0.15
else if pBar > 15
    lConf += 0.08
if pBar < -35
    sConf += 0.15
else if pBar < -15
    sConf += 0.08
if curvEma > 0.2 and rsi14 < 45
    lConf += 0.10
if curvEma > 0.2 and rsi14 > 55
    sConf += 0.10
if curvEma < -0.2 and curTD == 1
    lConf += 0.08
if curvEma < -0.2 and curTD == -1
    sConf += 0.08
if ema9 > ema21 and ema21 > ema50
    lConf += 0.10
if ema9 < ema21 and ema21 < ema50
    sConf += 0.10
if relVol >= 1.5
    lConf += 0.10
    sConf += 0.10
if hurstVal > 0.55 and curTD == 1
    lConf += 0.06
if hurstVal > 0.55 and curTD == -1
    sConf += 0.06
if nearSup and structure.tf1.sup_corridor.third_push
    lConf += 0.12
if nearRes and structure.tf1.res_corridor.third_push
    sConf += 0.12
if divType == "accumulation" and divConf > 0.4
    lConf += 0.12
if divType == "absorption" and divConf > 0.4
    sConf += 0.12
if array.includes(filtBull, "stopVol")
    lConf += 0.15
if array.includes(filtBear, "stopVol")
    sConf += 0.15
if transportEma > 0.03 and transportPersist > 0.5
    lConf += 0.12
if transportEma < -0.03 and transportPersist > 0.5
    sConf += 0.12
if holonomyPhase > 0.15 and dpFast > 0
    lConf += 0.08
if holonomyPhase < -0.15 and dpFast < 0
    sConf += 0.08
if geodesicDevZ > 1.0 and geodesicDevZ < i_geodesicSens * 1.5
    lConf += transportEma > 0 ? 0.08 : 0.0
    sConf += transportEma < 0 ? 0.08 : 0.0
float scaleAlignment = math.abs(_angleDiff(angleFast, angleSlow))
if scaleAlignment < math.pi * 0.25  
    if dpFast > 0 and dpSlow > 0
        lConf += 0.10
    if dpFast < 0 and dpSlow < 0
        sConf += 0.10
if holonomyGroup == "non-abelian" or holonomyGroup == "singular"
    if holo.regime_type == "bull_rotation"
        lConf += 0.10
    if holo.regime_type == "bear_rotation"
        sConf += 0.10
if array.includes(filtBull, "holoShift") or array.includes(filtBull, "geodesic")
    lConf += 0.12
if array.includes(filtBear, "holoShift") or array.includes(filtBear, "geodesic")
    sConf += 0.12
float lTotal = lBase > 0 ? lBase + lConf : 0.0
float sTotal = sBase > 0 ? sBase + sConf : 0.0
if liqPenalty < 1.0
    float liqRed = (1.0 - liqPenalty) * 0.3
    lTotal *= (1.0 - liqRed)
    sTotal *= (1.0 - liqRed)
if kyleLambdaZ > 2.0
    float klPen = _clamp(1.0 - (kyleLambdaZ - 2.0) * 0.15, 0.7, 1.0)
    lTotal *= klPen
    sTotal *= klPen
if danger > 75
    lTotal *= 0.6
    sTotal *= 0.6
if holo.regime_type == "stable" and math.abs(transportEma) < 0.01 and holonomyNorm < 0.1
    lTotal *= 0.85
    sTotal *= 0.85
float signalScore = lTotal > sTotal ? lTotal : -sTotal
// ═══════════════════════════════════════════════════════════════════════════════
// RCM EXTERNAL EVIDENCE INJECTION & PROCESS ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
float extBullEv = (transportEma > 0 ? transportEma * 15.0 : 0.0) + (holo.regime_type == "bull_rotation" ? holo.spike_strength * 10.0 : 0.0)
float extBearEv = (transportEma < 0 ? math.abs(transportEma) * 15.0 : 0.0) + (holo.regime_type == "bear_rotation" ? holo.spike_strength * 10.0 : 0.0)
float extIntegMod = -_clamp(geodesicDevZ / i_geodesicSens, 0.0, 1.0) * 0.35 - (danger > 60.0 ? 0.20 : 0.0)
rcm.ExternalEvidence extEv = rcm.ExternalEvidence.new(extBullEv, extBearEv, extIntegMod, "PTH_Manifold")
rcmState := rcm.inject(rcmState, extEv)
rcmState := rcm.update(rcmState, rcmCfg)
rcm.RCMModulation rcmMod = rcm.get_modulation(rcmState, i_confTighten, i_damageWiden, signalScore, 0.20, i_blockTrans, TH.bull, TH.bear, TH.s)
signalScore += rcmMod.scoreMod
// ═══════════════════════════════════════════════════════════════════════════════
// RL MEMORY & WEIGHT ADAPTATION
// ═══════════════════════════════════════════════════════════════════════════════
type RLMemory
    float  price
    string cat
    string dir
    int    bar
var array<RLMemory> rlMem = array.new<RLMemory>()
if math.abs(signalScore) > i_threshold * 0.5 and barstate.isconfirmed
    if signalScore > 0
        for ci = 0 to (array.size(bullCats) > 0 ? math.min(array.size(bullCats) - 1, 2) : na)
            string cat = array.get(bullCats, ci)
            bool exists = false
            for mi = 0 to (array.size(rlMem) > 0 ? array.size(rlMem) - 1 : na)
                RLMemory m = array.get(rlMem, mi)
                if m.bar == bar_index and m.cat == cat
                    exists := true
                    break
            if not exists
                array.push(rlMem, RLMemory.new(close, cat, "bull", bar_index))
    if signalScore < 0
        for ci = 0 to (array.size(bearCats) > 0 ? math.min(array.size(bearCats) - 1, 2) : na)
            string cat = array.get(bearCats, ci)
            bool exists = false
            for mi = 0 to (array.size(rlMem) > 0 ? array.size(rlMem) - 1 : na)
                RLMemory m = array.get(rlMem, mi)
                if m.bar == bar_index and m.cat == cat
                    exists := true
                    break
            if not exists
                array.push(rlMem, RLMemory.new(close, cat, "bear", bar_index))
if array.size(rlMem) > 0
    for mi = array.size(rlMem) - 1 to 0
        RLMemory m = array.get(rlMem, mi)
        int age = bar_index - m.bar
        if age >= 5 and age < 50
            bool isWin = (m.dir == "bull" and close > m.price) or (m.dir == "bear" and close < m.price)
            float adj = isWin ? PLASTICITY : -PLASTICITY
            if m.cat == "candle"
                wCandle := _clamp(wCandle + adj, 0.5, 2.0)
            else if m.cat == "structure"
                wStructure := _clamp(wStructure + adj, 0.5, 2.0)
            else if m.cat == "geometry"
                wGeometry := _clamp(wGeometry + adj, 0.5, 2.0)
            else if m.cat == "vsa"
                wVsa := _clamp(wVsa + adj, 0.5, 2.0)
            else if m.cat == "momentum"
                wMomentum := _clamp(wMomentum + adj, 0.5, 2.0)
            array.remove(rlMem, mi)
        else if age >= 50
            array.remove(rlMem, mi)
if array.size(rlMem) > 30
    array.shift(rlMem)
if bar_index % 50 == 0 and bar_index > 90
    float DECAY = 0.03
    wCandle    := wCandle + (1.0 - wCandle) * DECAY
    wStructure := wStructure + (1.0 - wStructure) * DECAY
    wGeometry  := wGeometry + (1.0 - wGeometry) * DECAY
    wVsa       := wVsa + (1.0 - wVsa) * DECAY
    wMomentum  := wMomentum + (1.0 - wMomentum) * DECAY
// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL GATING + TRADE SIMULATOR
// ═══════════════════════════════════════════════════════════════════════════════
int WARMUP = math.max(i_hurstPd + 10, 90)
var int lastSigBar = -999
var TradeState curTrade = TradeState.new()
var TradeStats stats = TradeStats.new()
var ActiveSig activeSig = na
var int wtTrades = 0, var int wtWins = 0
var int ctTrades = 0, var int ctWins = 0
bool canEval = bar_index >= WARMUP and barstate.isconfirmed
float absSc = math.abs(signalScore)
bool isLong = signalScore > 0
bool isShort = signalScore < 0
float strongTB = math.round(12 * tfTrendScale)
float modTB    = math.round(6 * tfTrendScale)
bool strongT = tStr > 1.8 and trendBars >= strongTB
bool modT    = tStr > 1.0 and trendBars >= modTB
bool isWT = (isLong and curTD >= 0) or (isShort and curTD <= 0)
float t1T = 0.0, float t2T = 0.0
if isWT
    t1T := (modT ? i_threshold * 0.85 : i_threshold) * tfScoreScale
    t2T := (modT ? i_threshold * 1.4 : i_threshold * 1.6) * tfScoreScale
else
    t1T := (strongT ? i_threshold * 1.6 : (modT ? i_threshold * 1.4 : i_threshold * 1.15)) * tfScoreScale
    t2T := (strongT ? i_threshold * 2.2 : modT ? i_threshold * 1.9 : i_threshold * 1.6) * tfScoreScale
float ctP = isWT ? 1.0 : _clamp(1.0 - tStr * 0.15 * tfCtStrictness, 0.45, 1.0)
float adj_score = absSc * ctP
bool ctQ = isWT or rsi14 < 26 or rsi14 > 74 or absSc > i_threshold * 2.0
int sCD = math.max(2, math.round(i_cooldown * tfCooldownScale))
bool cdOK = (bar_index - lastSigBar) >= sCD
int sigTier = 0
if canEval and adj_score >= t2T and cdOK and ctQ
    sigTier := 2
else if canEval and adj_score >= t1T and cdOK and relVol >= 0.7 and ctQ
    sigTier := 1
bool rcmAllowLong  = rcmMod.permissions.allowLong
bool rcmAllowShort = rcmMod.permissions.allowShort
bool contLong = false, bool contShort = false
if i_contOn and sigTier == 0 and canEval and (bar_index - lastSigBar) >= math.round(sCD * 2.0)
    int cBarsMin = math.round(12 * tfTrendScale)
    if trendBars >= cBarsMin and relVol >= 1.0 and tStr > 1.0
        float dE = math.abs(close - ema21) / math.max(atr14, EPS)
        bool transportConfirmsBull = transportEma > 0 and transportPersist > 0.5
        bool transportConfirmsBear = transportEma < 0 and transportPersist > 0.5
        if curTD == 1 and close > ema21 and dE < 0.6 and rsi14 > 42 and rsi14 < 62 and pBar > 15 and signalScore > 0 and transportConfirmsBull and rcmAllowLong and rcmMod.gatePass
            contLong := true
            sigTier := 3
            lastSigBar := bar_index
        else if curTD == -1 and close < ema21 and dE < 0.6 and rsi14 > 38 and rsi14 < 58 and pBar < -15 and signalScore < 0 and transportConfirmsBear and rcmAllowShort and rcmMod.gatePass
            contShort := true
            sigTier := 3
            lastSigBar := bar_index
bool sigLong = sigTier > 0 and sigTier <= 2 and isLong and rcmAllowLong and rcmMod.gatePass
bool sigShort = sigTier > 0 and sigTier <= 2 and isShort and rcmAllowShort and rcmMod.gatePass

if sigLong or sigShort
    lastSigBar := bar_index
if not curTrade.closed and bar_index > curTrade.bar
    bool isSh = curTrade.side == "SHORT"
    float activeStop = curTrade.stop
    bool hitSL  = isSh ? high >= activeStop : low <= activeStop
    bool hitTP1 = isSh ? low <= curTrade.t1 : high >= curTrade.t1
    bool hitTP2 = isSh ? low <= curTrade.t2 : high >= curTrade.t2
    bool timeout = (bar_index - curTrade.bar) >= i_maxBars
    bool flipExit = (isSh and (sigLong or contLong)) or (not isSh and (sigShort or contShort))
    if not curTrade.h1
        if hitSL
            curTrade.closed := true
            float pnlR = -1.0
            stats.total += 1, stats.losses += 1, stats.grossLoss += 1.0
            stats.totalPnl += pnlR
            stats.maxDD := math.max(stats.maxDD, stats.peakEq - stats.totalPnl)
            if curTrade.isWT
                wtTrades += 1
            else
                ctTrades += 1
        else if hitTP2
            curTrade.closed := true
            float pnlR = (isSh ? curTrade.en - curTrade.t2 : curTrade.t2 - curTrade.en) / (curTrade.entryATR * i_slMult * dvsRatio)
            stats.wins += 1, stats.total += 1, stats.grossProf += math.abs(pnlR)
            stats.totalPnl += pnlR, stats.peakEq := math.max(stats.peakEq, stats.totalPnl)
            stats.maxDD := math.max(stats.maxDD, stats.peakEq - stats.totalPnl)
            if curTrade.isWT
                wtTrades += 1, wtWins += 1
            else
                ctTrades += 1, ctWins += 1
        else if hitTP1
            curTrade.h1 := true
            curTrade.stop := curTrade.en
            float pnlR = (isSh ? curTrade.en - curTrade.t1 : curTrade.t1 - curTrade.en) / (curTrade.entryATR * i_slMult * dvsRatio)
            stats.wins += 1, stats.total += 1, stats.grossProf += pnlR
            stats.totalPnl += pnlR
            stats.peakEq := math.max(stats.peakEq, stats.totalPnl)
            if curTrade.isWT
                wtTrades += 1, wtWins += 1
            else
                ctTrades += 1, ctWins += 1
            bool hitNewSL = isSh ? high >= curTrade.en : low <= curTrade.en
            if hitNewSL
                curTrade.closed := true
            else if hitTP2
                curTrade.closed := true
                float pnlR2 = (isSh ? curTrade.en - curTrade.t2 : curTrade.t2 - curTrade.en) / (curTrade.entryATR * i_slMult * dvsRatio)
                stats.wins += 1, stats.total += 1, stats.grossProf += math.abs(pnlR2)
                stats.totalPnl += pnlR2, stats.peakEq := math.max(stats.peakEq, stats.totalPnl)
                stats.maxDD := math.max(stats.maxDD, stats.peakEq - stats.totalPnl)
                if curTrade.isWT
                    wtTrades += 1, wtWins += 1
                else
                    ctTrades += 1, ctWins += 1
        else if timeout or flipExit
            curTrade.closed := true
            float curPx = close
            float entATR = curTrade.entryATR
            float pnlR = isSh ? (curTrade.en - curPx) / (entATR * i_slMult * dvsRatio) : (curPx - curTrade.en) / (entATR * i_slMult * dvsRatio)
            stats.total += 1
            if pnlR > 0
                stats.wins += 1, stats.grossProf += math.abs(pnlR)
            else if pnlR < 0
                stats.losses += 1, stats.grossLoss += math.abs(pnlR)
            stats.totalPnl += pnlR, stats.peakEq := math.max(stats.peakEq, stats.totalPnl)
            stats.maxDD := math.max(stats.maxDD, stats.peakEq - stats.totalPnl)
            if curTrade.isWT
                wtTrades += 1
                if pnlR > 0
                    wtWins += 1
            else
                ctTrades += 1
                if pnlR > 0
                    ctWins += 1
    else
        if hitSL
            curTrade.closed := true
        else if hitTP2
            curTrade.closed := true
            float pnlR = (isSh ? curTrade.en - curTrade.t2 : curTrade.t2 - curTrade.en) / (curTrade.entryATR * i_slMult * dvsRatio)
            stats.wins += 1, stats.total += 1, stats.grossProf += math.abs(pnlR)
            stats.totalPnl += pnlR, stats.peakEq := math.max(stats.peakEq, stats.totalPnl)
            stats.maxDD := math.max(stats.maxDD, stats.peakEq - stats.totalPnl)
            if curTrade.isWT
                wtTrades += 1, wtWins += 1
            else
                ctTrades += 1, ctWins += 1
        else if timeout or flipExit
            curTrade.closed := true
            float curPx = close
            float entATR = curTrade.entryATR
            float pnlR = isSh ? (curTrade.en - curPx) / (entATR * i_slMult * dvsRatio) : (curPx - curTrade.en) / (entATR * i_slMult * dvsRatio)
            stats.total += 1
            if pnlR > 0
                stats.wins += 1, stats.grossProf += math.abs(pnlR)
            else if pnlR < 0
                stats.losses += 1, stats.grossLoss += math.abs(pnlR)
            stats.totalPnl += pnlR, stats.peakEq := math.max(stats.peakEq, stats.totalPnl)
            stats.maxDD := math.max(stats.maxDD, stats.peakEq - stats.totalPnl)
            if curTrade.isWT
                wtTrades += 1
                if pnlR > 0
                    wtWins += 1
            else
                ctTrades += 1
                if pnlR > 0
                    ctWins += 1
bool noActive = curTrade.closed
bool newLong  = noActive and (sigLong or contLong)
bool newShort = noActive and (sigShort or contShort)
if newLong
    float integrityScale = _clamp(rcmState.integrity, 0.6, 1.0)
    float sM = (sigTier == 3 ? i_slMult * 0.8 : not isWT ? i_slMult * 0.7 : i_slMult) * dvsRatio * (2.0 - integrityScale)
    float tM = (sigTier == 3 ? i_tpMult * 0.7 : not isWT ? i_tpMult * 0.65 : i_tpMult) * dvsRatio * integrityScale
    curTrade := TradeState.new("LONG", bar_index, false, false, isWT, sigTier, atr14, close, close - atr14 * sM, close + atr14 * tM * 0.5, close + atr14 * tM)
    activeSig := ActiveSig.new("LONG ⟡", absSc * 100, curTrade.en, curTrade.stop, curTrade.t1, curTrade.t2, sigTier, isWT)
else if newShort
    float integrityScale = _clamp(rcmState.integrity, 0.6, 1.0)
    float sM = (sigTier == 3 ? i_slMult * 0.8 : not isWT ? i_slMult * 0.7 : i_slMult) * dvsRatio * (2.0 - integrityScale)
    float tM = (sigTier == 3 ? i_tpMult * 0.7 : not isWT ? i_tpMult * 0.65 : i_tpMult) * dvsRatio * integrityScale
    curTrade := TradeState.new("SHORT", bar_index, false, false, isWT, sigTier, atr14, close, close + atr14 * sM, close - atr14 * tM * 0.5, close - atr14 * tM)
    activeSig := ActiveSig.new("SHORT ⟡", absSc * 100, curTrade.en, curTrade.stop, curTrade.t1, curTrade.t2, sigTier, isWT)
if curTrade.closed
    activeSig := na
float winRate = stats.total > 0 ? stats.wins / float(stats.total) * 100.0 : 0.0
float profitFactor = stats.grossLoss > 0 ? stats.grossProf / stats.grossLoss : stats.grossProf > 0 ? 99.9 : 0.0
float expectancy = stats.total > 0 ? stats.totalPnl / float(stats.total) : 0.0
// ═══════════════════════════════════════════════════════════════════════════════
// VISUAL RENDERING
// ═══════════════════════════════════════════════════════════════════════════════
float baseEnergy = holonomyNorm * 0.6 + normEnt * 0.4
float holoEnergy = baseEnergy * rcmMod.bandMod * dvsRatio
float mW1 = i_showMani ? atr14 * (0.2 + holoEnergy * 0.5) : na
float mW2 = i_showMani ? atr14 * (0.6 + holoEnergy * 1.0) : na
float mW3 = i_showMani ? atr14 * (1.2 + holoEnergy * 2.0) : na
float m1Up = na, float m1Dn = na, float m2Up = na, float m2Dn = na, float m3Up = na, float m3Dn = na
if i_showMani and not na(mW1)
    m1Up := close + mW1, m1Dn := close - mW1
    m2Up := close + mW2, m2Dn := close - mW2
    m3Up := close + mW3, m3Dn := close - mW3
color mColor = rcmMod.stateColor
p_m3u = plot(m3Up, "M3U", color=color(na), display=display.none)
p_m3d = plot(m3Dn, "M3D", color=color(na), display=display.none)
p_m2u = plot(m2Up, "M2U", color=color(na), display=display.none)
p_m2d = plot(m2Dn, "M2D", color=color(na), display=display.none)
p_m1u = plot(m1Up, "M1U", color=color(na), display=display.none)
p_m1d = plot(m1Dn, "M1D", color=color(na), display=display.none)
fill(p_m3u, p_m3d, color=color.new(mColor, 97), title="Transport Field T3")
fill(p_m2u, p_m2d, color=color.new(mColor, 92), title="Transport Field T2")
fill(p_m1u, p_m1d, color=color.new(mColor, 80), title="Transport Field T1")
float transportInt = _clamp(math.abs(transportDev) / (math.pi * 0.5), 0.0, 1.0)
float candleInt = _clamp(math.max(math.abs(pBar) / 100.0, transportInt), 0.0, 1.0)
color candleC = i_showCandle ? (transportEma > 0 ? color.new(TH.bull, int(80 - candleInt * 60)) : transportEma < 0 ? color.new(TH.bear, int(80 - candleInt * 60)) : pBar > 0 ? color.new(TH.bull, int(80 - candleInt * 60)) : color.new(TH.bear, int(80 - candleInt * 60))) : na
barcolor(candleC)
float siegeBandW = atr14 * 0.3
float siegeResLine = i_showSiege ? siegeResProj : na
float siegeResUp   = i_showSiege and not na(siegeResProj) ? siegeResProj + siegeBandW : na
float siegeResDn   = i_showSiege and not na(siegeResProj) ? siegeResProj - siegeBandW : na
float siegeSupLine = i_showSiege ? siegeSupProj : na
float siegeSupUp   = i_showSiege and not na(siegeSupProj) ? siegeSupProj + siegeBandW : na
float siegeSupDn   = i_showSiege and not na(siegeSupProj) ? siegeSupProj - siegeBandW : na
p_srm = plot(siegeResLine, "Siege Res", color=color.new(TH.bear, 35), style=plot.style_linebr, linewidth=2)
p_sru = plot(siegeResUp, "Siege Res Up", color=color(na), display=display.none)
p_srd = plot(siegeResDn, "Siege Res Dn", color=color(na), display=display.none)
fill(p_sru, p_srd, color=color.new(TH.bear, 92), title="Siege Res Band")
p_ssm = plot(siegeSupLine, "Siege Sup", color=color.new(TH.bull, 35), style=plot.style_linebr, linewidth=2)
p_ssu = plot(siegeSupUp, "Siege Sup Up", color=color(na), display=display.none)
p_ssd = plot(siegeSupDn, "Siege Sup Dn", color=color(na), display=display.none)
fill(p_ssu, p_ssd, color=color.new(TH.bull, 92), title="Siege Sup Band")
var label lbl_siege_r = na
var label lbl_siege_s = na
if barstate.islast and i_showSiege
    if not na(lbl_siege_r)
        label.delete(lbl_siege_r)
    if not na(lbl_siege_s)
        label.delete(lbl_siege_s)
    if structure.tf1.res_corridor.is_active and not na(siegeResProj)
        lbl_siege_r := label.new(bar_index + 3, siegeResProj, "Siege R H:" + str.tostring(structure.tf1.res_corridor.hit_count) + " B:" + _fStr(structure.tf1.res_corridor.break_prob * 100, 0) + "% F:" + _fStr(structure.tf1.res_corridor.fail_prob * 100, 0) + "%", style=label.style_label_left, color=color.new(color.black, 100), textcolor=TH.bear, size=size.tiny)
    if structure.tf1.sup_corridor.is_active and not na(siegeSupProj)
        lbl_siege_s := label.new(bar_index + 3, siegeSupProj, "Siege S H:" + str.tostring(structure.tf1.sup_corridor.hit_count) + " B:" + _fStr(structure.tf1.sup_corridor.break_prob * 100, 0) + "% F:" + _fStr(structure.tf1.sup_corridor.fail_prob * 100, 0) + "%", style=label.style_label_left, color=color.new(color.black, 100), textcolor=TH.bull, size=size.tiny)
if i_showVecField and barstate.isconfirmed and bar_index % 3 == 0
    float vecLen = atr14 * 1.5 * math.min(magFast + 0.3, 2.0)
    float vecAngle = angleFast
    float vecDx = math.cos(vecAngle)
    float vecDy = math.sin(vecAngle) * atr14
    color vecColor = dpFast > 0 ? color.new(TH.bull, 40) : color.new(TH.bear, 40)
    int vecWidth = magFast > 1.5 ? 2 : 1
    line.new(bar_index, close, bar_index + math.round(vecDx * 3), close + vecDy * vecLen * 0.3, color=vecColor, width=vecWidth, style=line.style_arrow_right)
if i_showHoloRing and barstate.islast
    float phaseValue = holonomyPhase
    string phaseStr = holonomyGroup == "trivial" ? "○" : holonomyGroup == "abelian" ? "◐" : holonomyGroup == "non-abelian" ? "◑" : "●"
    color phaseColor = holonomyNorm > i_holoThresh ? TH.a : holonomyPhase > 0 ? color.new(TH.bull, 30) : holonomyPhase < 0 ? color.new(TH.bear, 30) : color.new(TH.s, 50)
    label.new(bar_index + 5, close + atr14 * 0.8, phaseStr + " " + _fStr(holonomyPhase * 180, 0) + "°", style=label.style_label_left, color=color.new(color.black, 100), textcolor=phaseColor, size=size.tiny)
float entLine = not curTrade.closed ? curTrade.en : na
float stpLine = not curTrade.closed ? curTrade.stop : na
float tp1Line = not curTrade.closed ? curTrade.t1 : na
float tp2Line = not curTrade.closed ? curTrade.t2 : na
plot(entLine, "Entry", color=TH.a, linewidth=2, style=plot.style_linebr)
plot(stpLine, "Stop", color=#FF0000, linewidth=2, style=plot.style_linebr)
plot(tp1Line, "TP1", color=TH.bull, linewidth=1, style=plot.style_linebr)
plot(tp2Line, "TP2", color=color.new(TH.bull, 50), linewidth=1, style=plot.style_linebr)
string sigTag = sigTier == 2 ? "◆" : sigTier == 1 ? "◇" : sigTier == 3 ? "▸" : ""
string wtTag  = isWT ? " WT" : " CT"
string holoTag = holo.regime_shift ? " ⟐" : transportPersist > 0.7 ? " →" : ""
if sigLong
    label.new(bar_index, low, sigTag + wtTag + holoTag + " " + str.tostring(math.round(absSc * 100)) + "%", style=label.style_label_up, color=color.new(TH.bull, 20), textcolor=viz.smart_text(TH.bull), size=size.small)
if sigShort
    label.new(bar_index, high, str.tostring(math.round(absSc * 100)) + "% " + wtTag + holoTag + sigTag, style=label.style_label_down, color=color.new(TH.bear, 20), textcolor=viz.smart_text(TH.bear), size=size.small)
if contLong
    label.new(bar_index, low, "▸ CONT", style=label.style_label_up, color=color.new(TH.s, 20), textcolor=viz.smart_text(TH.s), size=size.tiny)
if contShort
    label.new(bar_index, high, "CONT ◂", style=label.style_label_down, color=color.new(TH.s, 20), textcolor=viz.smart_text(TH.s), size=size.tiny)
if holo.regime_shift and barstate.isconfirmed
    color shiftColor = holo.regime_type == "bull_rotation" ? TH.bull : holo.regime_type == "bear_rotation" ? TH.bear : TH.a
    string shiftLabel = holo.regime_type == "bull_rotation" ? "⟐ BULL SHIFT" : holo.regime_type == "bear_rotation" ? "⟐ BEAR SHIFT" : holo.regime_type == "geodesic_break" ? "⟐ GEODESIC" : holo.regime_type == "scale_divergence" ? "⟐ DIVERGE" : "⟐ PHASE"
    label.new(bar_index, holo.regime_type == "bear_rotation" ? high + atr14 * 0.3 : low - atr14 * 0.3, shiftLabel, style=holo.regime_type == "bear_rotation" ? label.style_label_down : label.style_label_up, color=color.new(shiftColor, 30), textcolor=viz.smart_text(shiftColor), size=size.tiny)
if glitchFire
    label.new(bar_index, high, "◈ GLITCH", style=label.style_label_down, color=color.new(TH.a, 30), textcolor=TH.a, size=size.tiny)
plot(poc, "POC", color=color.new(#FFD700, 40), linewidth=2, style=plot.style_linebr)
plot(vah, "VAH", color=color.new(#FF6B35, 60), linewidth=1, style=plot.style_linebr)
plot(val_, "VAL", color=color.new(#00C853, 60), linewidth=1, style=plot.style_linebr)
alertcondition(sigLong, "PTH Long", "⟡ PTH Long Signal")
alertcondition(sigShort, "PTH Short", "⟡ PTH Short Signal")
alertcondition(contLong, "PTH Cont Long", "⟡ PTH Continuation Long")
alertcondition(contShort, "PTH Cont Short", "⟡ PTH Continuation Short")
alertcondition(holo.regime_shift, "Holonomy Regime Shift", "⟡ Holonomy Regime Shift Detected")
// ═══════════════════════════════════════════════════════════════════════════════
// HOLONOMY & RCM DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast and i_showDash
    var table dash = viz.create_pane("TopRight", 45, 3, TH)
    int r = 0
    viz.fill_header(dash, r, "⟡ Parallel Transport & RCM Matrix", TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    string tfLabel = tfMinutes <= 5 ? str.tostring(math.round(tfMinutes)) + "m Scalp" : tfMinutes <= 15 ? str.tostring(math.round(tfMinutes)) + "m Intra" : tfMinutes <= 60 ? str.tostring(math.round(tfMinutes)) + "m Swing" : str.tostring(math.round(tfMinutes / 60)) + "H Pos"
    string tfST = tfScoreScale == 1.0 ? "Baseline" : tfScoreScale > 1.0 ? "x" + _fStr(tfScoreScale, 2) + " Filter" : "x" + _fStr(tfScoreScale, 2) + " Relax"
    table.cell(dash, 0, r, " TF", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + tfLabel, text_color=TH.p, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " " + tfST, text_color=TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " RCM Brain", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + rcm.state_text(rcmState), text_color=rcmMod.stateColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, rcmState.state == 0 ? " Sub: " + rcm.substate_text(rcmState) : " Dur: " + str.tostring(rcmState.stateBars) + "b", text_color=TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    color rcmIntegCol = rcm.integrity_color(rcmState, TH.bull, TH.bear)
    table.cell(dash, 0, r, " Integrity", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + rcm.integrity_text(rcmState) + " " + rcm.conf_bar(rcmState.integrity, 1.0, 5), text_color=rcmIntegCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " " + rcm.damage_text(rcmState), text_color=rcmMod.isDamaged ? TH.bear : TH.bull, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Ensemble DVS Volatility Engine", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    color dvsCol = dvsRatio > 1.4 ? TH.bear : dvsRatio < 0.7 ? TH.a : TH.bull
    string dvsStatus = dvsRatio > 1.4 ? "VOLATILE" : dvsRatio < 0.7 ? "COMPRESSED" : "STABLE"
    table.cell(dash, 0, r, " Method", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + i_dvsMethod, text_color=TH.p, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " " + dvsStatus, text_color=dvsCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " DVS Scale", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(dvsRatio, 2) + "x" + " (" + str.tostring(math.round(dvsRatio * 100)) + "%)", text_color=dvsCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Sens: " + _fStr(i_dvsSensitivity, 1), text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Parallel Transport Engine", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    table.cell(dash, 0, r, " Vec Fast", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(angleFast * 180 / math.pi, 1) + "°", text_color=dpFast > 0 ? TH.bull : TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Mag:" + _fStr(magFast, 2), text_color=magFast > 1.0 ? TH.bull : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " Vec Slow", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(angleSlow * 180 / math.pi, 1) + "°", text_color=dpSlow > 0 ? TH.bull : TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Mag:" + _fStr(magSlow, 2), text_color=magSlow > 1.0 ? TH.bull : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    color tdColor = math.abs(transportDev) > math.pi * 0.3 ? TH.a : TH.s
    table.cell(dash, 0, r, " Transport", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " Dev:" + _fStr(transportDev * 180 / math.pi, 1) + "°", text_color=tdColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Persist:" + _fStr(transportPersist * 100, 0) + "%", text_color=transportPersist > 0.7 ? TH.bull : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " Γ Connect", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(connectionStrength * 1000, 2), text_color=math.abs(connectionStrength) > 0.01 ? TH.a : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " H-scale:" + _fStr(hurstConnectionScale, 2), text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    color geodColor = geodesicDevZ > i_geodesicSens ? TH.a : geodesicDevZ > 1.0 ? TH.s : TH.bull
    table.cell(dash, 0, r, " Geodesic", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(geodesicDevZ, 2) + "σ", text_color=geodColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, geodesicDevZ > i_geodesicSens ? " OFF PATH" : " ON PATH", text_color=geodColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Manifold Curvature & Loops", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    color phColor = holonomyNorm > i_holoThresh ? TH.a : holonomyPhase > 0 ? TH.bull : holonomyPhase < 0 ? TH.bear : TH.s
    table.cell(dash, 0, r, " Phase", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(holonomyPhase * 180, 1) + "°", text_color=phColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Norm:" + _fStr(holonomyNorm * 100, 0) + "%", text_color=holonomyNorm > i_holoThresh ? TH.a : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    color groupColor = holonomyGroup == "trivial" ? TH.bull : holonomyGroup == "abelian" ? TH.s : holonomyGroup == "non-abelian" ? TH.a : TH.bear
    table.cell(dash, 0, r, " Group", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + holonomyGroup, text_color=groupColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " X-scale:" + _fStr(crossHoloZ, 2) + "σ", text_color=crossHoloZ > 2.0 ? TH.a : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    color regShiftColor = holo.regime_shift ? TH.a : holo.regime_type == "stable" ? TH.bull : holo.regime_type == "drifting" ? TH.s : TH.a
    table.cell(dash, 0, r, " Regime", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + holo.regime_type, text_color=regShiftColor, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Since:" + str.tostring(holo.bars_since_shift) + "b", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Tensor Metrics", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    viz.fill_metric(dash, r, "Curvature", curvEma * 100, 6, -50.0, 50.0, TH), r += 1
    viz.fill_metric(dash, r, "Entropy", normEnt * 100, 6, 0.0, 100.0, TH), r += 1
    viz.fill_metric(dash, r, "Hurst", hurstVal * 100, 6, 20.0, 80.0, TH), r += 1
    viz.fill_metric(dash, r, "Pressure", pBar, 6, -100.0, 100.0, TH), r += 1
    table.cell(dash, 0, r, " Core State", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    color rgC = regime == "TREND" ? TH.bull : regime == "CHOP" ? TH.bear : TH.a
    table.cell(dash, 1, r, " " + regime, text_color=rgC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    string patFired = array.size(filtBull) > 0 ? array.join(filtBull, "+") : array.size(filtBear) > 0 ? array.join(filtBear, "+") : "—"
    table.cell(dash, 2, r, " " + patFired, text_color=TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Siege Corridors", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    bool resActive = structure.tf1.res_corridor.is_active
    bool supActive = structure.tf1.sup_corridor.is_active
    table.cell(dash, 0, r, " Res", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, resActive ? " " + str.tostring(structure.tf1.res_corridor.hit_count) + " hits" : " Inactive", text_color=resActive ? TH.bear : TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, resActive ? " Brk:" + _fStr(structure.tf1.res_corridor.break_prob * 100, 0) + "%" : "", text_color=TH.a, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " Sup", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, supActive ? " " + str.tostring(structure.tf1.sup_corridor.hit_count) + " hits" : " Inactive", text_color=supActive ? TH.bull : TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, supActive ? " Brk:" + _fStr(structure.tf1.sup_corridor.break_prob * 100, 0) + "%" : "", text_color=TH.a, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Microstructure Liquidity", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    color liqC = liqRegime <= 2 ? TH.bull : liqRegime == 3 ? TH.a : TH.bear
    color dangerC = danger > 60 ? TH.bear : danger > 30 ? TH.a : TH.bull
    table.cell(dash, 0, r, " Volume", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + liqName, text_color=liqC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Risk:" + _fStr(danger, 0), text_color=dangerC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    color divC = divType == "absorption" ? TH.a : divType == "accumulation" ? TH.bull : divType == "exhaustion" ? TH.bear : TH.s
    table.cell(dash, 0, r, " Diverg.", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + divType, text_color=divC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Kyle λ:" + _fStr(kyleLambdaZ, 2), text_color=kyleLambdaZ > 1.5 ? TH.bear : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "Synthesizer & Gating", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    color sigC = signalScore > 0.2 ? TH.bull : signalScore < -0.2 ? TH.bear : TH.s
    table.cell(dash, 0, r, " Final Score", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(signalScore * 100, 1) + "%", text_color=sigC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Gate:" + (rcmMod.gatePass ? "PASS" : "BLOCK"), text_color=rcmMod.gatePass ? TH.bull : TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    float structConf = 0.0
    if resActive
        structConf += (1.0 - structure.tf1.res_corridor.break_prob) * 0.20
    if supActive
        structConf += (1.0 - structure.tf1.sup_corridor.break_prob) * 0.20
    structConf += (regime == "TREND" ? 0.20 : regime == "CHOP" ? 0.08 : 0.12)
    structConf += _clamp(math.abs(hurstVal - 0.5) * 2.0, 0.0, 0.20)
    structConf += holonomyNorm > i_holoThresh ? 0.15 : holonomyNorm > 0.2 ? 0.08 : 0.0
    structConf += transportPersist > 0.7 ? 0.10 : 0.0
    structConf := _clamp(structConf, 0.0, 1.0)
    table.cell(dash, 0, r, " Conf", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + viz.confidence_bar(structConf, 6), text_color=structConf > 0.7 ? TH.bull : structConf > 0.4 ? TH.a : TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Glitch:" + _fStr(glitchScore * 100, 0) + "%", text_color=glitchScore > 0.8 ? TH.a : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    viz.fill_separator(dash, r, "System Performance", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    color wrC = winRate >= 55 ? TH.bull : winRate >= 45 ? TH.s : winRate > 0 ? TH.bear : TH.s
    color pfC = profitFactor >= 1.5 ? TH.bull : profitFactor >= 1.0 ? TH.s : TH.bear
    table.cell(dash, 0, r, " Trades", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + str.tostring(stats.total), text_color=TH.txt_hi, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Win:" + _fStr(winRate, 1) + "%", text_color=wrC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " PnL", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(stats.totalPnl, 2) + "R", text_color=stats.totalPnl > 0 ? TH.bull : TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " PF:" + _fStr(profitFactor, 2), text_color=pfC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    table.cell(dash, 0, r, " MaxDD", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 1, r, " " + _fStr(stats.maxDD, 2) + "R", text_color=TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.cell(dash, 2, r, " Exp:" + _fStr(expectancy, 2) + "R", text_color=expectancy > 0 ? TH.bull : TH.bear, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    r += 1
    if stats.total > 0
        float wtWR = wtTrades > 0 ? wtWins / float(wtTrades) * 100 : 0
        float ctWR = ctTrades > 0 ? ctWins / float(ctTrades) * 100 : 0
        table.cell(dash, 0, r, " WT", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        table.cell(dash, 1, r, " " + str.tostring(wtTrades) + " (" + _fStr(wtWR, 0) + "%)", text_color=wtWR >= 55 ? TH.bull : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        table.cell(dash, 2, r, " CT:" + str.tostring(ctTrades) + " (" + _fStr(ctWR, 0) + "%)", text_color=ctWR >= 55 ? TH.bull : TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        r += 1
    if not na(activeSig)
        viz.fill_separator(dash, r, "Active Order", 3, TH)
        table.merge_cells(dash, 0, r, 2, r), r += 1
        color atC = str.contains(activeSig.sigType, "LONG") ? TH.bull : TH.bear
        table.cell(dash, 0, r, " " + activeSig.sigType, text_color=atC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        table.cell(dash, 1, r, " " + (activeSig.isWT ? "WT" : "CT") + " T" + str.tostring(activeSig.tier), text_color=TH.s, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        table.cell(dash, 2, r, " " + _fStr(activeSig.sc, 0) + "%", text_color=TH.p, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        r += 1
        table.cell(dash, 0, r, " Entry", text_color=TH.txt_lo, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        table.cell(dash, 1, r, " " + _fStr(activeSig.en, 2), text_color=TH.a, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        table.cell(dash, 2, r, " Stop:" + _fStr(activeSig.stop, 2), text_color=#FF0000, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
        r += 1
    viz.fill_separator(dash, r, "", 3, TH)
    table.merge_cells(dash, 0, r, 2, r), r += 1
    table.cell(dash, 0, r, "⟡ The Market is an Illusion ⟡", text_color=TH.p, text_size=size.tiny, bgcolor=color.new(TH.p, 92), text_font_family=font.family_monospace)
    table.merge_cells(dash, 0, r, 2, r)
// ═══════════════════════════════════════════════════════════════════════════════
// NARRATIVE PANEL 
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast and i_showNarr
    var table narr = viz.create_pane("BottomLeft", 16, 2, TH)
    int nr = 0
    viz.fill_header(narr, nr, "📖 Transport Narrative", TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    [regimeTxt, regimeCol] = rcm.narrative_regime(rcmState, TH.bull, TH.bear, TH.a, TH.s)
    viz.fill_separator(narr, nr, "Regime", 2, TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, " " + regimeTxt, text_color=regimeCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    [kineticsTxt, kineticsCol] = rcm.narrative_kinetics(rcmState, TH.a, TH.s)
    viz.fill_separator(narr, nr, "Kinetics", 2, TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, " " + kineticsTxt, text_color=kineticsCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    [structureTxt, structureCol] = rcm.narrative_structure(rcmState, TH.bull, TH.bear, TH.a)
    viz.fill_separator(narr, nr, "Structure", 2, TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, " " + structureTxt, text_color=structureCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    [permTxt, permCol] = rcm.narrative_permissions(rcmMod.permissions, TH.bull, TH.bear, TH.s)
    viz.fill_separator(narr, nr, "Permissions", 2, TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, " " + permTxt, text_color=permCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    [modTxt, modCol] = rcm.narrative_modulation(rcmMod.bandMod, TH.bull, TH.bear, TH.s)
    viz.fill_separator(narr, nr, "Manifold Modulation", 2, TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, " " + modTxt, text_color=modCol, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    string wN = "Scanning..."
    color wC = TH.s
    if not na(activeSig)
        wN := activeSig.sigType + " ACTIVE"
        wC := str.contains(activeSig.sigType, "LONG") ? TH.bull : TH.bear
    else if signalScore > i_threshold * 0.7
        wN := "Approaching bull threshold"
        wC := TH.a
    else if signalScore < -i_threshold * 0.7
        wN := "Approaching bear threshold"
        wC := TH.a
    viz.fill_separator(narr, nr, "Synthesizer", 2, TH)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, " " + wN, text_color=wC, text_size=size.tiny, bgcolor=TH.bg, text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr), nr += 1
    table.cell(narr, 0, nr, "⟡ Dskyz (DAFE) Trading Systems", text_color=TH.p, text_size=size.tiny, bgcolor=color.new(TH.p, 92), text_font_family=font.family_monospace)
    table.merge_cells(narr, 0, nr, 1, nr)
// ═══════════════════════════════════════════════════════════════════════════════
//  "The Market is an Illusion"
// ═══════════════════════════════════════════════════════════════════════════════
````
