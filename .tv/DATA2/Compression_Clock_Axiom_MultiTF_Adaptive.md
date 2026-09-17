<!-- tradingview-pine-id: PUB;98a3e47422e24447b2930ebdd16991fb -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Compression Clock (Axiom Multi-TF Adaptive)

Source: https://www.tradingview.com/script/mpkvlxpo-Compression-Clock-Axiom-Multi-TF-Adaptive/

## Description

**Compression Clock (Axiom Multi-TF Adaptive) — Volatility Regime & State Age**

---

### **Description**

#### **Overview**

The **Compression Clock** is a non-directional volatility regime indicator based on the **Axiom quantitative research framework**. Instead of attempting to forecast market direction, it isolates the temporal dimension (**WHEN**) by measuring the duration and depth of volatility compression across any resolution.

Markets do not transition from quiet to expansion instantaneously; they exhibit a survival-rate decay where prolonged low-volatility states exponentially elevate the baseline probability of large physical displacement. The Compression Clock standardizes this process by normalizing rolling volatility and volume percentiles against a physical-time benchmark.

---

#### **Mathematical & Architectural Core**

1. **Dual-Feature Quiet Filter**:
* Evaluates rolling True Range ($\text{ATR}_{24}$) and Traded Volume ($\text{SMA}_{24}$) scaled against an intraday 24-hour physical window:

$$\text{ATR}_{\text{rolling}} = \text{SMA}(\text{TR}, N_{\text{bars}}), \quad \text{Vol}_{\text{rolling}} = \text{SMA}(\text{Volume}, N_{\text{bars}})$$

* Computes the rolling percentile rank of both features across a rolling 180-day baseline distribution.
* A bar qualifies as **Quiet** if and only if both features sit simultaneously in the lower tercile:

$$\text{Quiet}_t = \mathbb{I}\left(\text{Rank}(\text{ATR}_t) \le 33.33\%\right) \land \mathbb{I}\left(\text{Rank}(\text{Vol}_t) \le 33.33\%\right)$$

2. **Physical-Time Normalization**:
* TradingView indicators often suffer from timescale distortion when hardcoding bar-based periods across multiple resolutions.
* This script dynamically translates resolution minutes ($M_{\text{tf}}$) into actual **physical hours**. Whether applied to a 5-minute, 30-minute, or 4-hour chart, the Y-axis consistently represents **elapsed physical hours of continuous compression**.

3. **Regime State Categorization**:
* **S0 (ACTIVE)**: Market is expanding or fluctuating outside the quiet threshold. Compression age resets to 0.
* **S1 (QUIET, < 24 Hours)**: Early-stage compression. Natural volatility dampening without statistical hazard elevation.
* **S2 (MATURE, 24 – 72 Hours)**: Statistically mature compression. Historical survival analysis indicates a significant elevation in large-displacement probability.
* **S3 (DEEP, > 72 Hours)**: Extreme volatility exhaustion. Persistent absence of dispersion indicating imminent volatility expansion.

---

#### **How to Use (Methodological Discipline)**

* **Decoupled Architecture**:
* The Clock dictates **WHEN** (volatility environment), not **WHAT** (direction) or **HOW** (execution).
* Never treat an S2/S3 state as a directional trade signal. A compression state is directionally agnostic—it warns of imminent displacement hazard, but the direction must be governed by external momentum or structural acceptance/rejection models.

* **Multi-Timeframe Scope**:
* Low-scale compression (e.g., 5m/15m entering S3) reflects localized intraday order book exhaustion. It does **not** override a higher-timeframe S0 state. For macro regime filtering, monitor higher physical resolutions (such as 4H).

* **Buffer Safety**:
* Includes a built-in 4,900-bar memory clamp to prevent buffer overflow exceptions on ultra-low timeframes while maintaining valid causal percentile rankings.

---

#### **Inputs**

* **Rolling Feature Duration (Hours)**: Physical length of the short-term smoothing window (Default: 24h).
* **Lookback Days (Days)**: Historical distribution window for empirical percentile rankings (Default: 180 days).
* **Quantile Rank Threshold (%)**: Cutoff for the quiet regime (Default: 33.333% — bottom tercile).

---

## Source Code

````pine
//@version=6
indicator("Compression Clock (Axiom Multi-TF Adaptive)", shorttitle="CompClock", overlay=false, max_bars_back=5000)

// --- Input Configurations ---
grp_general     = "General Configuration"
rolling_len_h   = input.int(24, title="Short-Term Window (Hours)", minval=1, group=grp_general)
lookback_days   = input.int(180, title="Baseline Benchmark Lookback (Days)", minval=10, group=grp_general)
quantile_rank   = input.float(33.333, title="Bottom Tercile Threshold (%)", minval=1.0, maxval=99.0, group=grp_general)

grp_ui          = "User Interface"
ui_lang         = input.string("English", title="Dashboard Language / 语言", options=["English", "中文"], group=grp_ui)

// --- 1. Multi-Timeframe Adaptation (Physical Time -> Bar Count) ---
tf_minutes = timeframe.isminutes ? timeframe.multiplier : timeframe.isdaily ? 1440 : timeframe.isseconds ? timeframe.multiplier / 60.0 : 60.0

rolling_bars = math.max(1, math.round((rolling_len_h * 60) / tf_minutes))
raw_percentile_bars = math.round((lookback_days * 24 * 60) / tf_minutes)
percentile_len      = math.min(4900, math.max(100, raw_percentile_bars))

s2_bar_threshold = math.max(1, math.round(24 * 60 / tf_minutes))
s3_bar_threshold = math.max(1, math.round(72 * 60 / tf_minutes))

// --- 2. Rolling Feature Extraction & Quantile Ranking ---
vol_rolling = ta.sma(volume, rolling_bars)
atr_rolling = ta.sma(ta.tr(true), rolling_bars)

vol_rank = ta.percentrank(vol_rolling, percentile_len)
atr_rank = ta.percentrank(atr_rolling, percentile_len)

is_quiet = (vol_rank <= quantile_rank) and (atr_rank <= quantile_rank)

// --- 3. State Age Accumulator ---
var int state_age_bars = 0
if is_quiet
    state_age_bars += 1
else
    state_age_bars := 0

float state_age_hours = (state_age_bars * tf_minutes) / 60.0

// --- 4. Regime Categorization ---
is_s0 = (state_age_bars == 0)
is_s1 = (state_age_bars >= 1 and state_age_bars < s2_bar_threshold)
is_s2 = (state_age_bars >= s2_bar_threshold and state_age_bars < s3_bar_threshold)
is_s3 = (state_age_bars >= s3_bar_threshold)

var string state_label_en = "S0 (ACTIVE)"
var string state_label_cn = "S0 (活跃态)"
var color state_color  = color.gray

if is_s0
    state_label_en := "S0 (ACTIVE)"
    state_label_cn := "S0 (活跃态)"
    state_color := color.gray
else if is_s1
    state_label_en := "S1 (QUIET <24h)"
    state_label_cn := "S1 (初始静默 <24h)"
    state_color := color.blue
else if is_s2
    state_label_en := "S2 (MATURE 24-72h ⚠️)"
    state_label_cn := "S2 (成熟压缩 24-72h ⚠️)"
    state_color := color.orange
else if is_s3
    state_label_en := "S3 (DEEP >72h 🚨)"
    state_label_cn := "S3 (深度压缩 >72h 🚨)"
    state_color := color.red

// --- 5. Visual Output ---
plot(state_age_hours, title="State Age (Physical Hours)", color=state_color, linewidth=2)
hline(24.0, "S1->S2 Threshold (24h)", color=color.new(color.orange, 40), linestyle=hline.style_dashed)
hline(72.0, "S2->S3 Threshold (72h)", color=color.new(color.red, 40), linestyle=hline.style_dashed)

bgcolor(is_s2 ? color.new(color.orange, 85) : is_s3 ? color.new(color.red, 85) : is_s1 ? color.new(color.blue, 92) : na)

// --- 6. Real-time Dashboard Table ---
var table dashboard = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)
if barstate.islast
    bool is_cn = (ui_lang == "中文")
    
    string label_state      = is_cn ? "当前状态" : "Current State"
    string label_age        = is_cn ? "物理时长" : "Physical Age"
    string label_truncation = is_cn ? "窗口截断" : "Window Truncation"
    string label_resolution = is_cn ? "图表周期" : "Resolution"
    
    string display_state = is_cn ? state_label_cn : state_label_en
    string display_age   = str.tostring(state_age_hours, "#.1") + (is_cn ? " 小时 (" : " Hours (") + str.tostring(state_age_bars) + (is_cn ? " 根)" : " Bars)")
    string display_trunc = raw_percentile_bars > 4900 ? (is_cn ? "已启用 (限4900根)" : "Active (Capped 4900b)") : (is_cn ? "未截断 (" : "Uncapped (") + str.tostring(percentile_len) + (is_cn ? "根)" : "b)")

    table.cell(dashboard, 0, 0, label_state, text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 0, display_state, bgcolor=state_color, text_color=color.white, text_size=size.small)
    
    table.cell(dashboard, 0, 1, label_age, text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 1, display_age, text_color=color.white, text_size=size.small)
    
    table.cell(dashboard, 0, 2, label_truncation, text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 2, display_trunc, text_color=raw_percentile_bars > 4900 ? color.yellow : color.white, text_size=size.small)

    table.cell(dashboard, 0, 3, label_resolution, text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 3, timeframe.period, text_color=color.white, text_size=size.small)

// --- 7. Alert Conditions ---
alert_s2_entry = ta.crossover(state_age_bars, s2_bar_threshold - 0.5)
alertcondition(alert_s2_entry, title="Entered S2 High-Risk (Physical 24h)", message="Axiom Warning: Market entered S2 Mature Quiet State (Physical 24h).")
````
