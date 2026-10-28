# TK Cloud v2

- url: https://www.tradingview.com/script/3VAwqapA-TK-Cloud-v2/
- type: indicator
- pine_id: PUB;edbab7019fec4f1ea8484cefb9763ea1
- version: 1.0

## Description

[url=https://www.tradingview.com/x/L0gBBJf1/]https://www.tradingview.com/x/L0gBBJf1/[/url]

# TK Cloud v2: TradingView Technical Indicator Manual

**TK Cloud v2** is an institutional-grade, multi-faceted technical overlay engineered for Pine Script v6. By flipping the mechanics of the traditional Ichimoku Kinko Hyo system, this script replaces the standard Senkou Span "Kumo Cloud" with a dynamic, highly responsive cloud formed directly between the **Tenkan-Sen (Conversion Line)** and the **Kijun-Sen (Base Line)**.

To create a complete trading workstation in a single script, it integrates a customizable high-order **Moving Average** filter and an auto-anchoring **Multi-Timeframe VWAP (Volume-Weighted Average Price)**.

---

## 1. Core Structural Components

### The Modified TK Cloud

In standard Ichimoku systems, the cloud (Kumo) is projected 26 periods into the future, acting as a trailing support/resistance metric. **TK Cloud v2** utilizes the immediate relationship between the short-term and medium-term equilibriums:

* **Tenkan-Sen (Blue Line by default):** Calculated as the midpoint of the highest high and lowest low over the past 9 periods ($\frac{\text{Highest High} + \text{Lowest Low}}{2}$). It represents short-term market momentum.
* **Kijun-Sen (Red Line by default):** Calculated as the midpoint of the highest high and lowest low over the past 26 periods. It represents medium-term market equilibrium.
* **The Cloud Fill:** The script fills the exact structural space between these two lines.
* A **Bullish Cloud (Green)** forms when the Tenkan-Sen trades above the Kijun-Sen, indicating accelerating upward velocity.
* A **Bearish Cloud (Red)** forms when the Tenkan-Sen trades below the Kijun-Sen, flashing localized structural decay.

### Lagging Span (Chikou Span)

True to the traditional Ichimoku layout, the **Lagging Span** plots the current close price shifted backward 26 periods. This allows traders to visually check current price action against historical price action to identify potential blockades or breakouts without shifting focus away from the current bar.

### Custom Trend Filter (Moving Average)

To ensure traders remain on the correct side of the primary macro trend, the script provides a built-in Moving Average tool. It defaults to a **200-period Simple Moving Average (SMA)**, widely recognized as the institutional boundary line between bull and bear markets. Traders can seamlessly toggle this element on or off and swap between:

* **SMA** (Simple Moving Average)
* **EMA** (Exponential Moving Average)
* **WMA** (Weighted Moving Average)
* **HMA** (Hull Moving Average)

### Multi-Timeframe Anchored VWAP

Volume-Weighted Average Price is the ultimate benchmark for intraday and swing liquidity. **TK Cloud v2** implements an automated anchor selector that bypasses native Pine Script script limitations, allowing users to track structural VWAP levels across macro intervals regardless of what chart timeframe they are looking at:

* **Daily:** Resets calculations at the start of each trading session.
* **Weekly:** Resets at the opening bar of Monday's session.
* **Monthly / Quarterly / Yearly:** Tracks institutional and corporate flow benchmarks by anchoring calculations to the opening of major fiscal periods.

---

## 2. Parameter Configurations & Inputs

The user interface inside TradingView is cleanly compartmentalized into three primary input blocks for rapid adjustment:

| Setting Group | Variable Parameter | Default Input | Available Configurations |
| --- | --- | --- | --- |
| **Ichimoku Settings** | Tenkan-Sen Length | `9` | Any integer value ($>0$) |
|  | Kijun-Sen Length | `26` | Any integer value ($>0$) |
|  | Lagging Span Offset | `26` | Any integer value ($>0$) |
| **Moving Average Settings** | Show Moving Average? | `True` (Checked) | Boolean Toggle |
|  | MA Type | `SMA` | Dropdown: `SMA`, `EMA`, `WMA`, `HMA` |
|  | MA Length | `200` | User choice (e.g., `50`, `100`, `200`) |
| **VWAP Settings** | Show VWAP? | `True` (Checked) | Boolean Toggle |
|  | VWAP Anchor | `Daily` | Dropdown: `Daily`, `Weekly`, `Monthly`, `Quarterly`, `Yearly` |

---

## 3. Practical Trading Strategies & Interpretations

### Strategy 1: The TK Cloud Compression & Expansion

Because the cloud tracks the distance between the 9-period and 26-period midpoints, the thickness of the cloud represents market volatility:

* **Squeeze / Flattening:** When the cloud thins to a narrow strip, it indicates a tight volatility squeeze. A major breakout is often imminent.
* **Trend Confirmation:** When the cloud expands rapidly with a deep green or red fill, it validates strong structural momentum. Traders can look to buy or short pullbacks to the inner edge (Kijun-Sen) of the cloud.

### Strategy 2: Multi-Confluence Confluence Filtering

Traders can run an exhaustive checklist for high-probability setups directly using this indicator:

1. **Macro Bias:** Is the price trading above the 200 SMA? (Bullish Bias)
2. **Value Bias:** Is the price holding above the Anchor VWAP (e.g., Weekly or Monthly)? (Institutions are buying)
3. **Execution Trigger:** Wait for a pullback into the **TK Cloud**. Enter long when a bar closes green out of the cloud while the cloud remains strongly bullish.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chadmk

//@version=6
indicator("TK Cloud v2", overlay=true, timeframe="", timeframe_gaps=true)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================

// --- Ichimoku Settings ---
string grp_ichi  = "Ichimoku (TK Cloud) Settings"
int tenkan_len   = input.int(9, title="Tenkan-Sen Length", group=grp_ichi)
int kijun_len    = input.int(26, title="Kijun-Sen Length", group=grp_ichi)
int lagging_len  = input.int(26, title="Lagging Span Offset", group=grp_ichi)

// --- Moving Average Settings ---
string grp_ma    = "Moving Average Settings"
bool show_ma     = input.bool(true, title="Show Moving Average?", group=grp_ma)
string ma_type   = input.string("SMA", title="MA Type", options=["SMA", "EMA", "WMA", "HMA"], group=grp_ma)
int ma_len       = input.int(200, title="MA Length", group=grp_ma)

// --- VWAP Settings ---
string grp_vwap  = "VWAP Settings"
bool show_vwap   = input.bool(true, title="Show VWAP?", group=grp_vwap)
string vwap_anch = input.string("Daily", title="VWAP Anchor Timeframe", options=["Daily", "Weekly", "Monthly", "Quarterly", "Yearly"], group=grp_vwap)

// --- Style & Color Settings ---
string grp_col   = "Color & Style Settings"
color c_tenkan   = input.color(color.blue, title="Tenkan-Sen", group=grp_col)
color c_kijun    = input.color(color.red, title="Kijun-Sen", group=grp_col)
color c_tk_bull  = input.color(color.new(color.green, 70), title="Bullish TK Cloud Fill", group=grp_col)
color c_tk_bear  = input.color(color.new(color.red, 70), title="Bearish TK Cloud Fill", group=grp_col)
color c_lagging  = input.color(color.green, title="Lagging Span", group=grp_col)
color c_ma       = input.color(color.orange, title="Moving Average", group=grp_col)
color c_vwap     = input.color(color.purple, title="VWAP", group=grp_col)

// ==========================================
// 2. CALCULATIONS
// ==========================================

// --- Ichimoku Logic ---
donchian(int len) =>
    math.avg(ta.highest(len), ta.lowest(len))

float tenkan = donchian(tenkan_len)
float kijun  = donchian(kijun_len)

// --- Moving Average Logic ---
float ma_val = na
if show_ma
    switch ma_type
        "SMA" => ma_val := ta.sma(close, ma_len)
        "EMA" => ma_val := ta.ema(close, ma_len)
        "WMA" => ma_val := ta.wma(close, ma_len)
        "HMA" => ma_val := ta.hma(close, ma_len)

// --- Custom Multi-Timeframe VWAP Logic ---
bool is_new_period = false
switch vwap_anch
    "Daily"     => is_new_period := ta.change(time("D")) != 0
    "Weekly"    => is_new_period := ta.change(time("W")) != 0
    "Monthly"   => is_new_period := ta.change(time("M")) != 0
    "Quarterly" => is_new_period := ta.change(time("3M")) != 0
    "Yearly"    => is_new_period := ta.change(time("12M")) != 0

var float vwap_pv_sum = 0.0
var float vwap_v_sum  = 0.0

if is_new_period
    vwap_pv_sum := 0.0
    vwap_v_sum  := 0.0

vwap_pv_sum += hlc3 * volume
vwap_v_sum  += volume

float my_vwap = vwap_v_sum != 0.0 ? vwap_pv_sum / vwap_v_sum : na

// ==========================================
// 3. PLOTTING & VISUALIZATION
// ==========================================

// Plot TK Lines and correctly capture their plot references
p_tenkan = plot(tenkan, color=c_tenkan, title="Tenkan-Sen", linewidth=2)
p_kijun  = plot(kijun, color=c_kijun, title="Kijun-Sen", linewidth=2)

// Cloud Fill between Tenkan and Kijun
color fill_color = tenkan > kijun ? c_tk_bull : c_tk_bear
fill(p_tenkan, p_kijun, color=fill_color, title="TK Cloud Fill")

// Plot Lagging Span (shifted backwards by default 26 periods)
plot(close, offset = -lagging_len, color=c_lagging, title="Lagging Span (Chikou)", linewidth=1)

// Plot Custom Moving Average
plot(show_ma ? ma_val : na, color=c_ma, title="Custom MA", linewidth=2)

// Plot Anchor VWAP
plot(show_vwap ? my_vwap : na, color=c_vwap, title="Anchor VWAP", linewidth=2)
````
