<!-- tradingview-pine-id: PUB;51e982897e454937a346c5e7bfd2e933 -->
<!-- tradingviewscripts-format: 1 -->
# Per Bak Self-Organized Criticality

Source: https://www.tradingview.com/script/bZo4yadb-Per-Bak-Self-Organized-Criticality/

## Description

TL;DR: This indicator measures market fragility. It measures the system's vulnerability to cascade failures and phase transitions. I've added four independent stress vectors: tail risk, volatility regime, credit stress, and positioning extremes. This allows us to quantify how susceptible markets are to disproportionate moves from small shocks, similar to how a steep sandpile is primed for avalanches.

Avalanches, forest fires, earthquakes, pandemic outbreaks, and market crashes. What do they all have in common? They are not random. 
These events follow power laws - stable systems that naturally evolve toward critical states where small triggers can unleash catastrophic cascades.
For example, if you are building a sandpile, there will be a point with a little bit additional sand will cause a landslide. 

Markets build fragility grain by grain, like a sandpile approaching avalanche.
The Per Bak Self-Organized Criticality (SOC) indicator detects when the markets are a few grains away from collapse. 
This indicator is highly inspired by the work of Per Bak related to [the science of self-organized criticality](https://neurocurso.wordpress.com/wp-content/uploads/2016/05/per-bak_how-nature-works_-the-science-of-self-organized-criticality-copernicus-1996.pdf). 

As Bak said:
"The earthquake does not 'know how large it will become'. Thus, any precursor state of a large event is essentially identical to a precursor state of a small event."

For markets, this means:

[*]We cannot predict individual crash size from initial conditions
[*]We can predict statistical distribution of crashes
[*]We can identify periods of increased systemic risk (proximity to critical state)

BTW, this is a forwarding looking indicator and doesn't reprint. :)

The Story of Per Bak
In 1987, Danish physicist Per Bak and his colleagues discovered an important pattern in nature: self-organized criticality. 
Their sandpile experiment revealed something: drop grains of sand one by one onto a pile, and the system naturally evolves toward a critical state. Most grains cause nothing. Some trigger small slides. But occasionally a single grain triggers a massive avalanche.

The key insight is that we cannot predict which grain will trigger the avalanche, but you can measure when the pile has reached a critical state. 

Why Markets Are the Ultimate SOC System?

[*]Financial markets exhibit all the hallmarks of self-organized criticality:
[*]Interconnected agents (traders, institutions, algorithms) with feedback loops
[*]Non-linear interactions where small events can cascade through the system
[*]Power-law distributions of returns (fat tails, not normal distributions)
[*]Natural evolution toward fragility as leverage builds, correlations tighten, and positioning crowds
[*]Phase transitions where calm markets suddenly shift to crisis regimes

Mathematical Foundation
Power Law Distributions
Traditional finance assumes returns follow a normal distribution. "Markets return 10% on average." But I disagree. Markets follow power laws:

P(x) ∝ x^(-α)
Where P(x) is the probability of an event of size x, and α is the power law exponent (typically 3-4 for financial markets).
What this means: Small moves happen constantly. Medium moves are less frequent. Catastrophic moves are rare but follow predictable probability distributions. The "fat tails" are features of critical systems.

Critical Slowing Down
As systems approach phase transitions, they exhibit critical slowing down—reduced ability to absorb shocks. Mathematically, this appears as:

τ ∝ |T - T_c|^(-ν)
Where τ is the relaxation time, T is the current state, T_c is the critical threshold, and ν is the critical exponent.
Translation: Near criticality, markets take longer to recover from perturbations. Fragility compounds.

Component Aggregation & Non-Linear Emergence
The Per Bak SOC our index aggregates four normalized components (each scaled 0-100) with tunable weights:

SOC = w₁·C_tail + w₂·C_vol + w₃·C_credit + w₄·C_position
Default weights (you can change this):
w₁ = 0.34 (Tail Risk via SKEW)
w₂ = 0.26 (Volatility Regime via VIX term structure)
w₃ = 0.18 (Credit Stress via HYG/LQD + TED spread)
w₄ = 0.22 (Positioning Extremes via Put/Call ratio)
Each component uses percentile ranking over a 252-day lookback combined with absolute thresholds to capture both relative regime shifts and extreme absolute levels.

The Four Pillars Explained
1. Tail Risk (SKEW Index)
Measures options market pricing of fat-tail events. High SKEW indicates elevated outlier probability.
C_tail = 0.7·percentrank(SKEW, 252) + 0.3·((SKEW - 115)/0.5)

2. Volatility Regime (VIX Term Structure)
Combines VIX level with term structure slope. Backwardation signals acute stress.
C_vol = 0.4·VIX_level + 0.35·VIX_slope + 0.25·VIX_ratio

3. Credit Stress (HYG/LQD + TED Spread)
Tracks high-yield deterioration versus investment-grade and interbank lending stress.
C_credit = 0.65·percentrank(LQD/HYG, 252) + 0.35·(TED/0.75)·100

4. Positioning Extremes (Put/Call Ratio)
Detects extreme hedging demand through percentile ranking and z-score analysis.
C_position = 0.6·percentrank(P/C, 252) + 0.4·zscore_normalized

What the Indicator Really Measures? 
Not Volatility but Fragility
Markets Going Down ≠ Fragility Building (actually when markets go down, risk and fragility are released)

The 0-100 Scale & Regime Thresholds
The indicator outputs a 0-100 fragility score with four regimes:
🟢 Safe (0-39): System resilient, can absorb normal shocks
🟡 Building (40-54): Early fragility signs, watch for deterioration
🟠 Elevated (55-69): System vulnerable
🔴 Critical (70-100): Highly susceptible to cascade failures
 
Further Reading for Nerds
[Bak, P., Tang, C., & Wiesenfeld, K. (1987). "Self-organized criticality: An explanation of 1/f noise." Physical Review Letters.](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.59.381)
[Bak, P. & Chen, K. (1991). "Self-organized criticality." Scientific American.](https://scispace.com/pdf/self-organized-criticality-4v87dkoa15.pdf)
[Bak, P. (1996). How Nature Works: The Science of Self-Organized Criticality. Copernicus.](https://neurocurso.wordpress.com/wp-content/uploads/2016/05/per-bak_how-nature-works_-the-science-of-self-organized-criticality-copernicus-1996.pdf)

Feedback is appreciated :)

---

## Source Code

````pine
//@version=5
//By yours and only, Henrique Centieiro ;)
indicator("Per Bak Self-Organized Criticality", shorttitle="Per Bak SOC", overlay=false)

// ═══════════════════════════════════════════════════════════
// INPUTS - Component Weights & Parameters
// ═══════════════════════════════════════════════════════════

lookback = input.int(252, "Statistical Lookback Period", minval=50, maxval=1000)

// Component weights (should sum to 100%)
skew_weight = input.float(34.0, "1️⃣ Tail Risk Weight %", minval=0, maxval=100) / 100
vix_weight = input.float(26.0, "2️⃣ Volatility Regime Weight %", minval=0, maxval=100) / 100
credit_weight = input.float(18.0, "3️⃣ Credit Stress Weight %", minval=0, maxval=100) / 100
pc_weight = input.float(22.0, "4️⃣ Positioning Weight %", minval=0, maxval=100) / 100

// Alert thresholds - RECALIBRATED
alert_building = input.int(40, "Building Fragility Threshold", minval=1, maxval=100, group="Thresholds")
alert_elevated = input.int(55, "Elevated Fragility Threshold", minval=1, maxval=100, group="Thresholds")
alert_critical = input.int(70, "Critical Fragility Threshold", minval=1, maxval=100, group="Thresholds")

// Display options
show_components = input.bool(true, "Show Individual Components", group="Display")
show_historical_avg = input.bool(true, "Show Historical Average", group="Display")
show_labels = input.bool(true, "Show Component Labels", group="Display")

// ═══════════════════════════════════════════════════════════
// DATA SOURCES - Fetch External Symbols (FORCED DAILY)
// ═══════════════════════════════════════════════════════════

// Tail risk - FORCE DAILY
skew = request.security("SKEW", "D", close, gaps=barmerge.gaps_off)

// Volatility term structure - FORCE DAILY
vix = request.security("VIX", "D", close, gaps=barmerge.gaps_off)
vix3m = request.security("VIX3M", "D", close, gaps=barmerge.gaps_off)
vix6m = request.security("VIX6M", "D", close, gaps=barmerge.gaps_off)

// Credit stress - FORCE DAILY
hyg = request.security("HYG", "D", close, gaps=barmerge.gaps_off)
lqd = request.security("LQD", "D", close, gaps=barmerge.gaps_off)
hyg_lqd_ratio = lqd > 0 ? hyg / lqd : na

ted_spread = request.security("TEDRATE", "D", close, gaps=barmerge.gaps_off)

// Positioning - FORCE DAILY
pcall = request.security("FINRA:PALL_SHORT_VOLUME", "D", close, gaps=barmerge.gaps_off)

// ═══════════════════════════════════════════════════════════
// COMPONENT 1: TAIL RISK (SKEW Index)
// ═══════════════════════════════════════════════════════════

// Use percentile rank for better dynamic scaling
skew_percentile = ta.percentrank(skew, lookback)

// Also keep absolute level for extreme events
skew_absolute = math.min(100, math.max(0, (skew - 115) / 0.5))  // 115-165 range maps to 0-100

// Blend percentile (responsive) with absolute (extreme detection)
skew_component = skew_percentile * 0.7 + skew_absolute * 0.3

// ═══════════════════════════════════════════════════════════
// COMPONENT 2: VOLATILITY REGIME (VIX Term Structure)
// ═══════════════════════════════════════════════════════════

// VIX spot level contribution
vix_level = math.min(100, (vix / 50) * 100)  // VIX 50+ = maxed out

// Term structure slope (backwardation = stress)
vix_term_slope = vix3m > 0 ? (vix - vix3m) / vix3m : 0
vix_slope_score = math.max(0, math.min(100, 50 + (vix_term_slope * 300)))

// 6-month ratio
vix_6m_ratio = vix6m > 0 ? vix / vix6m : 1
vix_ratio_score = math.max(0, math.min(100, (vix_6m_ratio - 0.7) * 200))

// Weighted combination
vix_component = (vix_level * 0.4 + vix_slope_score * 0.35 + vix_ratio_score * 0.25)

// ═══════════════════════════════════════════════════════════
// COMPONENT 3: CREDIT STRESS (HYG/LQD + TED)
// ═══════════════════════════════════════════════════════════

// HYG/LQD falling = stress (use inverse percentile)
hyg_lqd_stress = hyg_lqd_ratio > 0 ? 1 / hyg_lqd_ratio : 1
hyg_lqd_percentile = ta.percentrank(hyg_lqd_stress, lookback)

// TED spread - recalibrated for normal vs stress
ted_normalized = math.min(100, (ted_spread / 0.75) * 100)  // 0.75% = extreme stress

credit_component = (hyg_lqd_percentile * 0.65 + ted_normalized * 0.35)

// ═══════════════════════════════════════════════════════════
// COMPONENT 4: POSITIONING EXTREMES (Put/Call Ratio)
// ═══════════════════════════════════════════════════════════

// Percentile rank for dynamic adaptation
pc_percentile = ta.percentrank(pcall, lookback)

// Z-score for extreme detection
pc_mean = ta.sma(pcall, lookback)
pc_std = ta.stdev(pcall, lookback)
pc_zscore = pc_std > 0 ? (pcall - pc_mean) / pc_std : 0

// High P/C = hedging demand = fragility
pc_zscore_normalized = math.min(100, math.max(0, 50 + (pc_zscore * 25)))

// Blend percentile and z-score
pc_component = pc_percentile * 0.6 + pc_zscore_normalized * 0.4

// ═══════════════════════════════════════════════════════════
// COMPOSITE SLOPE INDEX
// ═══════════════════════════════════════════════════════════

slope_index = (skew_weight * skew_component + vix_weight * vix_component + credit_weight * credit_component + pc_weight * pc_component)

// Lighter smoothing for more responsiveness
slope_smoothed = ta.ema(slope_index, 2)

slope_historical_avg = ta.sma(slope_index, lookback)

slope_roc = ta.change(slope_smoothed, 10)
slope_acceleration = ta.change(slope_roc, 5)

// ═══════════════════════════════════════════════════════════
// REGIME DETECTION - RECALIBRATED
// ═══════════════════════════════════════════════════════════

regime_safe = slope_smoothed < alert_building
regime_building = slope_smoothed >= alert_building and slope_smoothed < alert_elevated
regime_elevated = slope_smoothed >= alert_elevated and slope_smoothed < alert_critical
regime_critical = slope_smoothed >= alert_critical

regime_color = regime_critical ? color.new(color.red, 0) : regime_elevated ? color.new(color.orange, 0) : regime_building ? color.new(color.yellow, 0) : color.new(color.green, 0)

// ═══════════════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════════════

plot(slope_smoothed, "Fragility Index", color=regime_color, linewidth=3)

plot(show_historical_avg ? slope_historical_avg : na, "Historical Avg", color=color.new(color.gray, 50), linewidth=1, style=plot.style_line)

// Updated threshold lines
hline(alert_building, "Building Risk", color=color.new(color.yellow, 60), linestyle=hline.style_dotted)
hline(alert_elevated, "Elevated Risk", color=color.new(color.orange, 60), linestyle=hline.style_dashed)
hline(alert_critical, "Critical Zone", color=color.new(color.red, 60), linestyle=hline.style_solid, linewidth=2)

// Background shading
bgcolor(regime_critical ? color.new(color.red, 90) : regime_elevated ? color.new(color.orange, 93) : regime_building ? color.new(color.yellow, 95) : na)

// ═══════════════════════════════════════════════════════════
// INDIVIDUAL COMPONENTS (Optional Display)
// ═══════════════════════════════════════════════════════════

plot(show_components ? skew_component : na, "1️⃣ Tail Risk", color=color.new(color.purple, 60), linewidth=1)
plot(show_components ? vix_component : na, "2️⃣ Vol Regime", color=color.new(color.blue, 60), linewidth=1)
plot(show_components ? credit_component : na, "3️⃣ Credit Stress", color=color.new(color.fuchsia, 60), linewidth=1)
plot(show_components ? pc_component : na, "4️⃣ Positioning", color=color.new(color.aqua, 60), linewidth=1)

// ═══════════════════════════════════════════════════════════
// COMPONENT LABELS ON CHART
// ═══════════════════════════════════════════════════════════

if barstate.islast and show_components and show_labels
    label.new(bar_index, skew_component, "Tail Risk", 
              color=color.new(color.purple, 80), 
              textcolor=color.purple, 
              style=label.style_label_left, 
              size=size.tiny)
    
    label.new(bar_index, vix_component, "Vol Regime", 
              color=color.new(color.blue, 80), 
              textcolor=color.blue, 
              style=label.style_label_left, 
              size=size.tiny)
    
    label.new(bar_index, credit_component, "Credit", 
              color=color.new(color.fuchsia, 80), 
              textcolor=color.fuchsia, 
              style=label.style_label_left, 
              size=size.tiny)
    
    label.new(bar_index, pc_component, "Positioning", 
              color=color.new(color.aqua, 80), 
              textcolor=color.aqua, 
              style=label.style_label_left, 
              size=size.tiny)

// ═══════════════════════════════════════════════════════════
// TABLE - Current Readings
// ═══════════════════════════════════════════════════════════

var table dashboard = table.new(position.top_right, 3, 7, bgcolor=color.new(color.black, 85), border_width=1)

if barstate.islast
    table.cell(dashboard, 0, 0, "PER BAK SOC", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.navy, 70))
    table.merge_cells(dashboard, 0, 0, 2, 0)
    
    regime_text = regime_critical ? "🔴 AVALANCHE ZONE" : regime_elevated ? "🟠 CRACKING" : regime_building ? "🟡 STRESS FORMING" : "🟢 STABLE"
    
    table.cell(dashboard, 0, 1, "Current State:", text_color=color.gray, text_size=size.small)
    table.cell(dashboard, 1, 1, regime_text, text_color=regime_color, text_size=size.normal, bgcolor=color.new(regime_color, 85))
    table.cell(dashboard, 2, 1, str.tostring(slope_smoothed, "#.0"), text_color=color.white, text_size=size.normal)
    
    table.cell(dashboard, 0, 2, "Tail Risk:", text_color=color.gray, text_size=size.small)
    table.cell(dashboard, 1, 2, str.tostring(skew_component, "#.0"), text_color=color.purple, text_size=size.small)
    table.cell(dashboard, 2, 2, "SKEW: " + str.tostring(skew, "#.0"), text_color=color.gray, text_size=size.tiny)
    
    table.cell(dashboard, 0, 3, "Vol Regime:", text_color=color.gray, text_size=size.small)
    table.cell(dashboard, 1, 3, str.tostring(vix_component, "#.0"), text_color=color.blue, text_size=size.small)
    table.cell(dashboard, 2, 3, "VIX: " + str.tostring(vix, "#.1"), text_color=color.gray, text_size=size.tiny)
    
    table.cell(dashboard, 0, 4, "Credit:", text_color=color.gray, text_size=size.small)
    table.cell(dashboard, 1, 4, str.tostring(credit_component, "#.0"), text_color=color.fuchsia, text_size=size.small)
    table.cell(dashboard, 2, 4, "TED: " + str.tostring(ted_spread, "#.2") + "%", text_color=color.gray, text_size=size.tiny)
    
    table.cell(dashboard, 0, 5, "Positioning:", text_color=color.gray, text_size=size.small)
    table.cell(dashboard, 1, 5, str.tostring(pc_component, "#.0"), text_color=color.aqua, text_size=size.small)
    table.cell(dashboard, 2, 5, "P/C: " + str.tostring(pcall, "#.2"), text_color=color.gray, text_size=size.tiny)
    
    trend_arrow = slope_roc > 2 ? "⬆️ Accelerating" : slope_roc > 0 ? "↗️ Rising" : slope_roc > -2 ? "↘️ Falling" : "⬇️ Declining"
    
    table.cell(dashboard, 0, 6, "10D Δ:", text_color=color.gray, text_size=size.small)
    table.cell(dashboard, 1, 6, trend_arrow, text_color=slope_roc > 0 ? color.red : color.green, text_size=size.small)
    table.merge_cells(dashboard, 1, 6, 2, 6)

// ═══════════════════════════════════════════════════════════
// ALERTS - Updated thresholds
// ═══════════════════════════════════════════════════════════

alertcondition(ta.crossover(slope_smoothed, alert_critical), title="🔴 AVALANCHE ZONE", message="Per Bak SOC entered AVALANCHE ZONE (70+)!")

alertcondition(ta.crossover(slope_smoothed, alert_elevated), title="🟠 CRACKING", message="Per Bak SOC CRACKING (55+) - add hedges")

alertcondition(ta.crossover(slope_smoothed, alert_building), title="🟡 STRESS FORMING", message="Per Bak SOC STRESS FORMING (40+)")

alertcondition(ta.crossunder(slope_smoothed, alert_building) and regime_safe, title="🟢 STABLE", message="Per Bak SOC returned to STABLE (<40)")

alertcondition(slope_roc > 5 and slope_smoothed > alert_elevated, title="⚡ RAPID DETERIORATION", message="Fragility accelerating rapidly from elevated levels!")

alertcondition(skew > 150, title="⚠️ EXTREME TAIL RISK", message="SKEW Index > 150 - fat tails forming")

alertcondition(vix_term_slope > 0.15 and vix > 20, title="⚠️ VIX BACKWARDATION", message="VIX term structure inverted with elevated VIX")

alertcondition(ted_spread > 0.5, title="⚠️ CREDIT STRESS", message="TED Spread elevated above 0.5%")
````
