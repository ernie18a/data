# Grimes KC: MTF Volatility Regimes

- url: https://www.tradingview.com/script/TcvdKdSR/
- type: indicator
- pine_id: PUB;a6e1692ee85b42ad914a6b6fb5e28dec
- version: 2.0

## Description

### 🌐 Overview
**Grimes KC: MTF Volatility Regimes** is an advanced Multi-Timeframe (MTF) Volatility Regime Mapping System. The indicator is built upon the robust foundation of **Adam Grimes' Keltner Channels (KC)** and synthesized with the multi-layered volatility analysis inspired by **Mark Whistler's Wave PM** and **John Carter's TTM Squeeze**.

This indicator is NOT just a tool that paints colors on your background. It is a high-dimensional market map that seamlessly merges **Statistical Price Extremes (Spatial Dimension)** with **MTF Volatility Cycles (Temporal Dimension)** through a two-step framework.

---

### 🔬 The Two-Step Analytical Framework

#### Step 1: Statistical Price Extremes & Tail Events (Spatial Dimension)
The core structure utilizes a dual-layered MTF Keltner Channel. Statistically, the probability of price simultaneously piercing outside the outer bands of **both the Chart Timeframe and the Higher Timeframe at the exact same time is extremely low (a rare tail event)**. 
However, this extreme breakthrough presents **two diametrically opposed possibilities**: it could either be the birth of a massive, explosive **"Band-Walk" (institutional trend initiation)**, or a severe **"Mean-Reversion Snapback" (an overextended statistical anomaly ripe for a fade)**. By plotting these multi-layered price boundaries, the indicator visually maps these high-stakes junctions, allowing traders to monitor which of the two opposite paths the market will choose.

#### Step 2: Quantified Volatility Cycle Serialization (Temporal Dimension)
To eliminate raw price noise, the indicator continuously measures the historical percentile (0–100%) of the band widths over a user-defined lookback period. It dynamically normalizes and serializes the MTF volatility cycle (Contraction & Expansion). The interplay between long-term institutional compression and short-term retail momentum is instantly visualized, telling you whether the market is loading energy, expanding in a healthy trend, or reaching statistical exhaustion.

---

### 🎨 The 4 Volatility Regimes & Actionable Strategies

#### 1. 🟦 Double Squeeze (Both Timeframes <= 10%)
* **Market State:** Severe volatility compression across both short-term retail and long-term institutional participants. The market energy is coiled like a tight spring.
* **Strategy:** **Prepare for Breakout.** Do not trade inside this zone. Wait for the background color to turn off and look for a heavy momentum expansion.

#### 2. 🟨 Early Breakout / Volatility Illusion (Chart TF >= 90% / HTF <= 10%)
* **Market State:** Short-term volatility spikes while the macro timeframe remains in a heavy squeeze. According to **Mark Whistler's theory**, this represents a *"Volatility Illusion"* that lacks true institutional liquidity. 
* **Strategy:** **Monitor for Fade or Breakout.** This regime presents **two diametrically opposed scenarios**: 
  1) **The Fade (Mean-Reversion):** The price expansion fails as a "False Breakout," and the price is rapidly snapped back to the center by the gravity of the HTF squeeze. This offers a high-probability short-term counter-trend entry.
  2) **The Lead (Trend Initiation):** The short-term momentum is so powerful that it forces the higher timeframe to break its squeeze, dragging the HTF into an expansion and starting a massive **"Band-Walk"**. 
  Always wait for price action to confirm which scenario unfolds before execution.

#### 3. 🟪 Pullback / Trend Continuation (Chart TF <= 10% / HTF >= 90%)
* **Market State:** The higher timeframe is in a powerful, established trend, while the lower timeframe chart takes a temporary breath (forming tight ranges, flags, or pennants).
* **Strategy:** **High-Probability Pullback Entry.** This is the ideal regime for trend-followers. Look to buy the dips or sell the rallies when the short-term chart expands back out in the alignment direction of the HTF trend.

#### 4. 🟥 Double Expansion (Both Timeframes >= 90%)
* **Market State:** Statistical exhaustion. Both macro and micro trends have reached their theoretical and statistical upper limit over the lookback history.
* **Strategy:** **Take Profit / Do Not Chase.** The market is severely overextended. Tighten trailing stops or secure your profits immediately. Absolutely avoid chasing new positions here.

---

### ⚠️ Crucial Trading Guide
**IMPORTANT:** This indicator is a Volatility Regime Map, NOT a raw buy/sell signal generator. It provides 1-dimensional volatility structure (width) and multi-timeframe regime contexts. 

To achieve a complete institutional execution setup, you must combine these background colors with a directional tool, such as the slope of the Moving Average or price action breakout direction, to filter your trades.

---

### ⚙️ Best Practices & Inputs
* **Timeframe Selection (HTF Input):** It is **highly recommended** to set the Higher Timeframe (HTF) to **1-Hour (60) or higher** (e.g., 240 or D) relative to your lower timeframe charts (like 5-min or 15-min). This allows the algorithm to accurately capture macro institutional cycles.
* **Fully Customizable Visuals:** Unlike rigid scripts, you can customize all 4 regime colors, line colors, and background opacities directly from the Input Parameter settings to seamlessly match your Dark or Light chart themes.

---
*Credits: Conceptualized based on the volatility market microstructures of Adam Grimes and Mark Whistler. Developed with the assistance of an AI coding partner.*

## Source Code

````pine
//@version=6
indicator("Grimes KC: MTF Volatility Regimes", overlay=true)

// --- Input Parameters & Tooltips ---
resInput          = input.timeframe("60", title="Higher Timeframe (HTF)",
     tooltip="[RECOMMENDED: 1-Hour '60' or higher]\nTo correctly capture macro volatility cycles and Whistler's 'Volatility Illusion' regime, it is highly recommended to select a timeframe of 1-Hour (60) or greater relative to your lower timeframe chart.")

bandlength        = input.int(20, title="EMA Length (bandlength)")
atrlength         = input.int(14, title="ATR Length (atrlength)")
keltnerMultiplier = input.float(2.25, title="ATR Multiplier (keltnerMultiplier)")

// Percentile & Threshold Settings
lookback_period   = input.int(200, title="Lookback Period for Width", minval=10)
upper_threshold   = input.int(85, title="Upper Extreme Threshold (%)", minval=50, maxval=100)
lower_threshold   = input.int(15, title="Lower Extreme Threshold (%)", minval=0, maxval=50)

// --- Band Line Color Settings ---
group_color_lines = "Band Line Color Settings"
c_normal_color    = input.color(color.white, title="Chart TF Band (Normal)", group=group_color_lines)
htf_normal_color  = input.color(color.gray,  title="HTF Band (Normal)", group=group_color_lines)
line_color_upper  = input.color(color.red,   title="Band Color at Upper Extreme (>=85%)", group=group_color_lines)
line_color_lower  = input.color(color.blue,  title="Band Color at Lower Extreme (<=15%)", group=group_color_lines)

// --- Background Regime Color Settings ---
group_color_bg    = "Background Regime Color Settings"
color_squeeze     = input.color(color.new(color.blue, 88), title="① Double Squeeze Color", group=group_color_bg)
color_lead_break  = input.color(color.new(color.yellow, 88), title="② Early Breakout Color", group=group_color_bg)
color_pullback    = input.color(color.new(color.purple, 88), title="③ Pullback Color", group=group_color_bg)
color_expansion   = input.color(color.new(color.red, 88), title="④ Double Expansion Color", group=group_color_bg)

// --- Background Switches with Trading Logic Tooltips ---
group_bg          = "Background Switches & Strategy Tooltips"
show_squeeze      = input.bool(true, title="① Double Squeeze (Blue) Active", group=group_bg, 
     tooltip="[SQUEEZE / PREPARE TO BREAKOUT]\nBoth Chart TF and HTF are extremely compressed (<=15%). Energy is fully loaded. Prepare for a massive breakout when the color turns off.")

show_lead_break   = input.bool(true, title="② Early Breakout / Fade Zone (Yellow) Active", group=group_bg, 
     tooltip="[VOLATILITY ILLUSION / SHORT-TERM FADE OPPORTUNITY]\nChart TF is expanding (>=85%) but HTF remains compressed (<=15%). According to Mark Whistler's theory, this represents a 'volatility illusion' lacking institutional liquidity. It often leads to a false breakout, making it an excellent opportunity for short-term counter-trend (fade) trading toward the center.")

show_pullback     = input.bool(true, title="③ Pullback / Trend Continuation (Purple) Active", group=group_bg, 
     tooltip="[PULLBACK / TREND CONTINUATION]\nHTF is in a strong trend (>=85%) while Chart TF takes a temporary rest (<=15%). This marks a high-probability pullback/re-entry setup in the direction of the HTF trend.")

show_expansion    = input.bool(true, title="④ Double Expansion (Red) Active", group=group_bg, 
     tooltip="[EXHAUSTION / TAKE PROFIT]\nBoth Chart TF and HTF are overextended (>85%). The trend has reached its statistical limit. Absolutely avoid chasing the market; look to lock in profits.")

// ==========================================
// 1. Chart Timeframe (Current TF) KC Calculation
// ==========================================
c_ema   = ta.ema(close, bandlength)
c_atr   = ta.atr(atrlength)
c_upper = c_ema + c_atr * keltnerMultiplier
c_lower = c_ema - c_atr * keltnerMultiplier

// Percentile of Chart TF Band Width
c_width = c_upper - c_lower
c_highest_width = ta.highest(c_width, lookback_period)
c_lowest_width  = ta.lowest(c_width, lookback_period)
c_width_range   = c_highest_width - c_lowest_width
c_percentile    = c_width_range > 0 ? ((c_width - c_lowest_width) / c_width_range) * 100 : 50

// ==========================================
// 2. Higher Timeframe (HTF) KC & Percentile Calculation
// ==========================================
f_kc_calc(int lookback) =>
    ema_val = ta.ema(close, bandlength)
    atr_val = ta.atr(atrlength)
    u_band  = ema_val + atr_val * keltnerMultiplier
    l_band  = ema_val - atr_val * keltnerMultiplier
    
    w_val   = u_band - l_band
    h_w     = ta.highest(w_val, lookback)
    l_w     = ta.lowest(w_val, lookback)
    w_rg    = h_w - l_w
    pct_val = w_rg > 0 ? ((w_val - l_w) / w_rg) * 100 : 50
    [ema_val, u_band, l_band, pct_val]

[m_basis_raw, m_upper_raw, m_lower_raw, m_pct_raw] = request.security(syminfo.tickerid, resInput, f_kc_calc(lookback_period), barmerge.gaps_off, barmerge.lookahead_off)

// 【ギザギザ修正の核心】直前の値から明確に変化した瞬間のみをbool型で検知
is_new_bar = (m_basis_raw != m_basis_raw[1])

var int bar_count = 0
var int bars_per_mtf = 12

if is_new_bar
    if bar_count > 0
        bars_per_mtf := bar_count
    bar_count := 0
else
    bar_count += 1

var float prev_basis = na, var float curr_basis = na
var float prev_upper = na, var float curr_upper = na
var float prev_lower = na, var float curr_lower = na
var float prev_pct   = na, var float curr_pct   = na

if is_new_bar
    prev_basis := curr_basis
    curr_basis := m_basis_raw
    prev_upper := curr_upper
    curr_upper := m_upper_raw
    prev_lower := curr_lower
    curr_lower := m_lower_raw
    prev_pct   := curr_pct
    curr_pct   := m_pct_raw

var float smooth_basis = na
var float smooth_upper = na
var float smooth_lower = na
var float htf_percentile = na

if not na(prev_basis) and not na(curr_basis)
    float weight = float(bar_count) / float(bars_per_mtf)
    smooth_basis   := barstate.islast ? na : prev_basis + (curr_basis - prev_basis) * weight
    smooth_upper   := barstate.islast ? na : prev_upper + (curr_upper - prev_upper) * weight
    smooth_lower   := barstate.islast ? na : prev_lower + (curr_lower - prev_lower) * weight
    htf_percentile := barstate.islast ? na : prev_pct + (curr_pct - prev_pct) * weight

// ==========================================
// 3. Dynamic Band Line Coloring
// ==========================================
color dyn_c_band = c_normal_color
if c_percentile >= upper_threshold
    dyn_c_band := line_color_upper
else if c_percentile <= lower_threshold
    dyn_c_band := line_color_lower

color dyn_htf_band = htf_normal_color
if htf_percentile >= upper_threshold
    dyn_htf_band := line_color_upper
else if htf_percentile <= lower_threshold
    dyn_htf_band := line_color_lower

// ==========================================
// 4. Multi-Timeframe Regime Switching Background Logic
// ==========================================
color bg_color = color.new(color.white, 100)

if c_percentile <= lower_threshold and htf_percentile <= lower_threshold
    bg_color := show_squeeze ? color_squeeze : color.new(color.white, 100)
else if c_percentile >= upper_threshold and htf_percentile <= lower_threshold
    bg_color := show_lead_break ? color_lead_break : color.new(color.white, 100)
else if c_percentile <= lower_threshold and htf_percentile >= upper_threshold
    bg_color := show_pullback ? color_pullback : color.new(color.white, 100)
else if c_percentile >= upper_threshold and htf_percentile >= upper_threshold
    bg_color := show_expansion ? color_expansion : color.new(color.white, 100)

bgcolor(bg_color, title="Wave PM Regime Switching Background")

// ==========================================
// 5. Dual Band Extreme Breakout Detection
// ==========================================
dual_upper_break = (close > c_upper) and (close > smooth_upper)
dual_lower_break = (close < c_lower) and (close < smooth_lower)

is_first_upper_break = dual_upper_break and not dual_upper_break[1]
is_first_lower_break = dual_lower_break and not dual_lower_break[1]

// ==========================================
// 6. Plotting & Signals
// ==========================================
plot(smooth_basis, color=color.new(htf_normal_color, 50), linewidth=1, title="HTF Basis")
plot(c_ema, color=color.new(c_normal_color, 50), linewidth=1, title="Chart Basis")

plot(c_upper, color=dyn_c_band, linewidth=1, title="Chart Upper Band")
plot(c_lower, color=dyn_c_band, linewidth=1, title="Chart Lower Band")

plot(smooth_upper, color=dyn_htf_band, linewidth=3, title="HTF Upper Band")
plot(smooth_lower, color=dyn_htf_band, linewidth=3, title="HTF Lower Band")

plotshape(is_first_upper_break, title="Dual Upper Break Signal", style=shape.triangledown, 
          location=location.abovebar, color=line_color_upper, size=size.small)

plotshape(is_first_lower_break, title="Dual Lower Break Signal", style=shape.triangleup, 
          location=location.belowbar, color=line_color_lower, size=size.small)
````
