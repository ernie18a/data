<!-- tradingview-pine-id: PUB;67d0f67aa84f4e7ab3ba09aa6a6666b5 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Unicode Heatmap Candles

Source: https://www.tradingview.com/script/DhrcWUEd/

## Description

Unicode Heatmap Candles

■Overview: Analytical Paradigm & Value Proposition
This indicator introduces a fundamentally new approach to micro-structural market analysis within TradingView. Transcending the visual limitations of standard OHLC (Open, High, Low, Close) candles, it leverages Pine Script v6's dynamic array processing to completely reconstruct price bars into high-resolution liquidity heatmaps. Engineered specifically for active traders and quantitative analysts, it visualizes the true order flow and volume concentrations (Point of Control) hidden beneath superficial price action in real-time.

[image]https://www.tradingview.com/x/9NtkENkh/[/image]

1. Concept & Analytical Edge
Standard candlestick charts display static geometrical shapes, which inherit a critical flaw: they completely obscure internal transaction dynamics. A long wick or a large body tells you where the price moved, but not where the actual capital was deployed. In institutional quantitative analysis, a candlestick is not a solid bar, but a vertical aggregation of micro-transactions.

By utilizing Unicode block characters with sub-tick precision, this indicator maps the exact distribution of executed lower-timeframe (LTF) volume across price tiers within each individual candle—without relying on external footprint tables. It separates "empty price movements" from "solid liquidity zones.

2. Core Mechanics & Mathematical Logic

A. Dynamic Volatility Slicing (ATR Adaptive)
To maintain consistent visual resolution across varying market conditions (from low-volatility Asian sessions to high-impact news events), the price tier step is dynamically derived from the Average True Range (ATR).

Calculate dynamic price step based on 14-period ATR

[pine]float current_atr = global_atr[b_offset]
if na(current_atr) or current_atr == 0
current_atr := close[b_offset] * 0.005

int active_ticks = math.max(1, math.round((current_atr / 30) / syminfo.mintick))
float step = syminfo.mintick * active_ticks
int total_r = math.ceil((bar_h - bar_l) / step) + 1[/pine]

Why this calculation? Fixing the tier size by a static tick value causes resolution breakdown during volatility spikes. By dividing the 14-period ATR by 30 and rounding to the nearest minimum tick, this mathematical normalization guarantees that each candle is systematically divided into approximately 20 to 30 micro-tiers, outputting a consistent heatmap resolution regardless of the timeframe or asset class.

B. Geometry Detection: Real Body vs. Wick
The script evaluates the exact numerical center of each vertical price tier to identify whether it structurally belongs to the candle body or the wick, rendering distinct Unicode glyphs to preserve the traditional candlestick silhouette.

[image]https://www.tradingview.com/x/P2Aq1uAR/[/image]

Determine Body vs Wick geometry

[pine]float top_p = price_p + (step / 2)
float bot_p = price_p - (step / 2)

bool is_body = (top_p > body_bot) and (bot_p < body_top)
string current_char = is_body ? body_char : wick_char[/pine]

[*]Candle Body: Stacks wide block glyphs (███) to represent the high-density range between Open and Close.
[*]Candle Wick: Stacks slender vertical glyphs (┃) to trace extreme price rejections up to the High/Low limits.

3. Scope of Capability & Technical Boundaries
To maintain institutional-grade transparency, the operational boundaries and strict design choices of this tool are detailed below. This is a specialized hyper-local lens, not a historical charting tool.

[*]Intra-Candle Heatmap [ YES ] : Maps LTF volume directly inside the candle shape.
[*]Real-Time POC Tracking [ YES ] : Visualizes highest volume nodes via color saturation.
[*]Multi-Asset Support [ YES ] : Works flawlessly across Equities, Crypto, Forex, and Futures.
[*]Full Historical Backtesting [ NO ] : Restricted by the Pine Script 500-label buffer limit.
[*]High-ATR Max Display [ ~5-8 Bars ] : Optimized strictly for real-time, active execution setups.

System Constraint & Design Architecture: Pine Script v6 enforces a hard maximum of 500 label objects (max_labels_count=500). Because each high-resolution candle consumes 20 to 40 individual labels to render the micro-tiers, the simultaneous display limit is mathematically capped around the most recent 5 to 8 bars in high-ATR environments. Older bars are systematically garbage-collected. This is an intentional architectural choice: 100% of the maximum allowed computing and drawing resources are allocated to maximizing the resolution of the current market structure.

Important Note on Higher Timeframes (Daily/Weekly/Monthly): TradingView Data Limits
You may notice that when applied to high timeframes like the Monthly chart, older candles render as gray (Zero Volume). This is not a bug. TradingView imposes a strict limit of 100,000 historical bars for lower-timeframe (request.security_lower_tf) data requests. If your LTF is set to 1-minute, 100,000 bars cover only about 70 days. Therefore, older macro candles cannot retrieve micro-volume data.

[image]https://www.tradingview.com/x/YT6xK5vJ/[/image]

Remember: This indicator is a "Microscope" built for active intraday/swing execution. It is fundamentally designed for micro-structure analysis, not macro-historical profiling.

Anti-Crash Fail-Safe (For Non-Premium Users)
TradingView strictly limits access to seconds-based timeframes (e.g., 1S, 15S) to Premium plan subscribers. To prevent runtime crashes for Essential/Plus users, this script features a built-in safety toggle: "Premium Plan (Allow Seconds TF)".

If this box is unchecked (default), any attempt to input a seconds-based LTF will be automatically intercepted and safely downgraded to a 1-minute (1m) resolution, ensuring uninterrupted operation for all user tiers.

4. How to Use

[*]Add the indicator to your chart.
[*]Open Chart Settings (Gear Icon) -> Symbol -> Uncheck Body, Wick, and Borders (hide standard candles).
[*]Observe the internal liquidity distribution:

[*]Red / Orange Nodes: Point of Control (POC) and high-liquidity concentration zones.
[*]Blue / Muted Nodes: Low volume nodes (slippage zones, price vacuums, or liquidity voids).

Disclaimer
This script and its description are published solely for the purpose of learning, researching, and providing technical analysis methodologies. The developer assumes no responsibility for any direct, indirect, incidental, or consequential losses or damages (including trading losses or loss of profits) arising from the use of this tool. Trading in financial markets involves substantial risk. Please conduct thorough verification and implement appropriate risk management at your own risk before using this in a live trading environment.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (C) ALT_analyst

//@version=6
indicator("Unicode Heatmap Candles", overlay=true, max_labels_count=500, max_bars_back=500)

// ~~ Constants {
const string GRP_CORE = " [ SYSTEM ] CORE"
const string TITLE_PREM = "Premium Plan (Allow Seconds TF)"
const string TT_PREM = "If OFF and a seconds timeframe is specified, it will be forcefully downgraded to a 1-minute (1) minimum timeframe to prevent errors."
const string TITLE_LB = "Lookback Bars (Target Candles)"
const string TITLE_LTF = "Lower Timeframe (LTF)"

const string GRP_DISP = " [ DISPLAY ] UNICODE SHAPE"
const string TITLE_BODY_CHAR = "Body Unicode String"
const string TITLE_WICK_CHAR = "Wick Unicode String"
const string TITLE_LBL_SIZE = "Label Size"

const string GRP_BG = " [ COLOR ] TEXT GRADIENT"
const string TITLE_BG_H = "Volume High (Max)"
const string TITLE_BG_M = "Volume Mid (50%)"
const string TITLE_BG_L = "Volume Low (Min)"
const string TITLE_BG_Z = "Volume Zero (No Trade)"
//~~~~~}

// ~~ Inputs {
bool is_premium = input.bool(false, TITLE_PREM, group=GRP_CORE, tooltip=TT_PREM)
int lookback_bars = input.int(3, TITLE_LB, minval=1, maxval=20, group=GRP_CORE)
string ltf_res_input = input.timeframe("1", TITLE_LTF, group=GRP_CORE)

string body_char = input.string("███", TITLE_BODY_CHAR, group=GRP_DISP)
string wick_char = input.string(" ┃ ", TITLE_WICK_CHAR, group=GRP_DISP)
string lbl_size = input.string(size.normal, TITLE_LBL_SIZE, options=[size.auto, size.tiny, size.small, size.normal, size.large], group=GRP_DISP)

color bg_col_high = input.color(color.new(#FF0000, 0), TITLE_BG_H, group=GRP_BG) 
color bg_col_mid = input.color(color.new(#FFEB3B, 0), TITLE_BG_M, group=GRP_BG)
color bg_col_low = input.color(color.new(#2196F3, 30), TITLE_BG_L, group=GRP_BG)
color bg_col_zero = input.color(color.new(color.gray, 80), TITLE_BG_Z, group=GRP_BG)
//~~~~~}

// ~~ Helpers {
//~~~~~}

// ~~ Calculation & Drawing {
bool is_sec_tf = str.contains(ltf_res_input, "S")
string actual_ltf = (not is_premium and is_sec_tf) ? "1" : ltf_res_input

[ltf_o, ltf_h, ltf_l, ltf_c, ltf_v] = request.security_lower_tf(syminfo.tickerid, actual_ltf, [open, high, low, close, volume])
float global_atr = ta.atr(14)

var label[] fp_labels = array.new_label()

if barstate.islast
    while array.size(fp_labels) > 0
        label.delete(array.shift(fp_labels))
        
    for b_offset = lookback_bars - 1 to 0
        if b_offset >= bar_index or array.size(ltf_v) == 0 or array.size(ltf_v) <= b_offset
            continue
            
        float[] ltf_h_arr = ltf_h[b_offset]
        float[] ltf_l_arr = ltf_l[b_offset]
        float[] ltf_v_arr = ltf_v[b_offset]
        
        int ltf_size = array.size(ltf_v_arr)
        
        float bar_o = open[b_offset]
        float bar_h = high[b_offset]
        float bar_l = low[b_offset]
        float bar_c = close[b_offset]
        
        float body_top = math.max(bar_o, bar_c)
        float body_bot = math.min(bar_o, bar_c)
        
        float current_atr = global_atr[b_offset]
        if na(current_atr) or current_atr == 0
            current_atr := close[b_offset] * 0.005 
            
        int active_ticks = math.max(1, math.round((current_atr / 30) / syminfo.mintick))
        float step = syminfo.mintick * active_ticks
        
        int total_r = math.ceil((bar_h - bar_l) / step) + 1
        
        float[] tot_v_arr = array.new_float(total_r, 0.0)
        float max_r_v = 0.0
        
        if ltf_size > 0
            for i = 0 to ltf_size - 1
                float c_h = array.get(ltf_h_arr, i)
                float c_l = array.get(ltf_l_arr, i)
                float c_v = array.get(ltf_v_arr, i)
                    
                int ticks_1s = math.max(1, math.round((c_h - c_l) / syminfo.mintick) + 1)
                float v_tick = c_v / ticks_1s
                
                int s_idx = math.max(0, math.round((c_l - bar_l) / step))
                int e_idx = math.min(total_r - 1, math.round((c_h - bar_l) / step))
                
                for t_idx = s_idx to e_idx
                    if t_idx >= 0 and t_idx < total_r
                        array.set(tot_v_arr, t_idx, array.get(tot_v_arr, t_idx) + v_tick)

        for i = 0 to total_r - 1
            float total = array.get(tot_v_arr, i)
            max_r_v := math.max(max_r_v, total)
            
        int t_ctr = time[b_offset]

        for i = 0 to total_r - 1
            float total = array.get(tot_v_arr, i)
            float price_p = bar_l + (i * step)
            
            float top_p = price_p + (step / 2)
            float bot_p = price_p - (step / 2)
            
            bool is_body = (top_p > body_bot) and (bot_p < body_top)
            string current_char = is_body ? body_char : wick_char
            
            float half_max = max_r_v * 0.5
            color grad_col = total == 0 ? bg_col_zero : (total >= half_max ? color.from_gradient(total, half_max, max_r_v, bg_col_mid, bg_col_high) : color.from_gradient(total, 0, half_max, bg_col_low, bg_col_mid))
            
            array.push(fp_labels, label.new(
                x = t_ctr, y = price_p,
                xloc = xloc.bar_time, yloc = yloc.price,
                text = current_char,
                style = label.style_none,
                textcolor = grad_col,
                size = lbl_size,
                textalign = text.align_center
            ))
//~~~~~}
````
