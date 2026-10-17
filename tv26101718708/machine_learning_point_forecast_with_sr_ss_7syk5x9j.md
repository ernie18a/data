# Machine Learning Point Forecast with SR [SS]

- url: https://www.tradingview.com/script/7sYk5x9j-Machine-Learning-Point-Forecast-with-SR-SS/
- type: indicator
- pine_id: PUB;f8f406985bbd4be9ba7a7943009c5c18
- version: 1.0

## Description

Hello,
Releasing the Machine Learning Point Forecast indicator, let's get into it! 

[b]What It Is[/b]

This indicator is a price forecasting indicator built on a simple but powerful idea borrowed from machine learning: markets tend to behave similarly when they're in similar states.

Instead of relying on a fixed formula (like a moving average crossover or a fixed RSI threshold), this indicator constantly asks a different question every bar:

[quote] "Out of the last 200 bars, which ones looked most like right now and what happened next, those times?"
 [/quote]

It answers that question using K-Nearest Neighbors (KNN), a classic non-parametric machine learning technique, applied to four hand engineered features that describe the shape and momentum of price action. The result is plotted directly on the chart as a series of horizontal price targets, each one a literal price level the model thinks is worth watching, based on what similar historical setups did.

[b]The Theory[/b]

[i]Feature Engineering: Describing "What a Bar Looks Like"[/i]

Raw OHLC data isn't directly comparable across time (a $2 move means something different at $50 than at $500), so the model first converts each bar into four normalized descriptors:

[list]
[*] Composite candle shape: the combined magnitude of the high, low, and close moves relative to the open, expressed as a single Euclidean value. This captures how "stretched" or volatile a candle was.
[*] Close slope: the rate of change of a 14-period linear regression of price, normalized by price. This captures short-term trend acceleration/deceleration. 
[*] RSI slope: the rate of change of a 14-period linear regression of RSI. This captures whether momentum itself is accelerating or stalling, independent of price. 
[*] Return slope: the rate of change of a 14-period linear regression of bar-to-bar percentage returns. This captures whether volatility/returns are trending up or down.
[/list]

Together, these four numbers form a fingerprint for every bar, not just where price is, but how it's moving and accelerating.

[i]Standardization: Putting Everything on the Same Scale[/i]

Each of the four features is converted into a z-score over a rolling window (default 100 bars):

[quote] z = (value − rolling mean) / rolling standard deviation [/quote]

This step matters because the four raw features live on completely different scales. Z-scoring puts them all in "standard deviations from normal" terms, so no single feature can dominate the similarity comparison just because its raw numbers happen to be bigger.

[i]The K-Nearest Neighbors Search[/i]

With four standardized features per bar, every bar in history is now a point in 4-dimensional space. The model searches the last N bars (default 200, the "Historical Search Window") and calculates the Euclidean distance between the current bar's 4D fingerprint and every historical bar's fingerprint:

[quote] distance = √[(Δfeature1)² + (Δfeature2)² + (Δfeature3)² + (Δfeature4)²] [/quote]

The K historical bars (default 5) with the smallest distance are kept, these are the "nearest neighbors," i.e., the historical moments that most closely resembled the current setup across all four dimensions simultaneously.

[i]Inverse Distance Weighted Forecasting (IDWF)[/i]

This is the forecasting step. For each of the K neighbors, the model already knows what actually happened: the real forward return that occurred over the next N bars (the "Forecast Bars Forward" setting) after that historical analog appeared.

Those K historical outcomes are blended into a single forecast using inverse distance weighting closer matches (smaller distance) get more influence over the final number than weaker matches:

[quote] forecast return = Σ(return × weight) / Σ(weight),  where weight = 1 / distance [/quote]

That weighted return is applied to the current close to produce the point target — the model's price forecast.

This entire approach: 
[list=1]
[*]feature engineering 
[*]standardization 
[*]KNN
[*]Distance weighted aggregation 
[/list]

is a form of case-based / analog forecasting. It's the same family of technique used in some quantitative pattern-matching strategies and academic time series KNN research: rather than fitting one global formula to all market conditions, it lets the data itself decide what "similar" means, bar by bar.

[b]How It Works on the Chart[/b]

[i]Point-Forecast Lines[/i]

Once per closed bar, the model draws a flat, dashed, horizontal line at the calculated target price, extending forward indefinitely. Green lines mean the model's weighted forecast is bullish (target above current price); red means bearish.

Each line behaves like a real price target:

[list]
[*]It disappears the instant price actually reaches it (high touches an upside target, or low touches a downside target).
[*] It ages out automatically — only a capped number of lines (default 20, adjustable) are kept on screen. Once that cap is hit, the oldest surviving forecast is dropped to make room for the newest one.
[/list]

[i]Grouping Nearby Targets[/i]

Because a new forecast is generated every bar, it's common for the model to repeatedly point at roughly the same price over several bars in a row. Rather than stacking near duplicate lines, any new target that lands within a configurable percentage of an existing active target gets merged, the two are averaged into one line, and that line's label updates accordingly.

This has a useful side effect: the more a price level keeps attracting merges, the more "agreed upon" that level has been across many bars' worth of model runs informally, a cluster of merged calls is a stronger zone of interest than an isolated, never-revisited line.

[b]Reading the Signals in Practice[/b]

This indicator is best treated as a contextual map of historically-analogous price targets, not a standalone buy/sell signal generator. A few practical ways to use it:

[list=1]
[*] Confluence, not isolation. Treat each TP line as one vote. A target line that lines up with an existing structural level (a prior swing high/low, VWAP, a round number) is more interesting than one floating in open air.
[*] Watch for clustering. Because nearby targets merge, a chart where forecasts keep collapsing into the same line over time is the model expressing genuine conviction about that price. A chart full of scattered, never-merged lines suggests the model is seeing a noisier, less consistent setup right now.
 [*] Use Avg Fit Distance as a confidence dial. A low distance means "this is a well-worn pattern"; a high or rising distance means "this is a less familiar regime, be more skeptical of the target." % Bullish/Bearish tells you how unanimous the analogs are. 100%/0% is a much stronger statement than 60%/40%, even if the point target is identical.
 [*] New forecasts only print once per closed bar (not on every tick), so the model won't spam new lines intrabar, but a line can still vanish intrabar the instant its target is actually touched.

[/list]

[b]Honest Limitations[/b]

This is a similarity heuristic, not a trained, validated, or backtested predictive model. "What happened after similar setups in the past" is not a guarantee of what happens next.

Small windows (low K, short lookback) make the model fast and reactive but noisier; large windows make it smoother but slower to adapt to genuine regime change.

Like any pattern-matching tool, it can be confidently wrong, a low Avg Fit Distance means the pattern matched well, not that the outcome is certain.

It's intended as one input among several in a broader trading process — not a substitute for risk management, market structure analysis, or your own judgment.


I hope you all enjoy and find it helpful!
As always, safe trades to all!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steversteves
//                                                                                                
//                                                           =                                        
//                            ≈×  ≠±                          ≠≤    ≠:   ≈                            
//                           ≤≠  ≥≈                            ≠∑   ≈≥   ≈≥                           
//                       ≈   ≤∑ √≠=  =>             .           ≈≥:  ∑≈  ∑≠                           
//                       ∑   ≥∑≥√±  ≥≈           :>Iii;.         ≈≤≥ ≥±  ≥±  =                        
//                       ≥∑   ∑∑≠× ≤≈           ->IIii,:;         ±≤∑∑± √×   ≥÷                       
//                       ≥≥∑   ≥≥= ≥=          ->IIIi;   :!i,      ∑≥≤×∑±×   ≤-                       
//                        ≥≥∑  ∑≥≥√=.         <-<IIII; .    ,   ≥≠  ∑≈≥≈÷   √≠                        
//                         ≈≥∑≈ ≤∑≈+  ÷       -IIIIi;i: l       ≥≥= ∑≤±=   ∑≠                         
//                       =≥  ≤≥≤ ≥≈  ≈≤×     !::iii;::  .:      ∑≤ √∑+   ≠≥÷l                         
//                        ≈≥≥= ≠≤≥≠∑  ≥≥     iii;,.  .   >      ≥±=√± √≥≈-+                           
//                          ≈≈≤∑√≤≠≠≥∑≠≤≥   .,;!!Ii;;:,   l    ≥≠∑≥≈×+>>:                             
//                             :+<!!!<>×÷≈=!<iiii;;;;;;i:  .!==><+×+                                  
//                                      ,iI!;.           .,ii,                                        
//                                ;iIII;.    ∂-∇⋆•∇⋆⋆∇√>>:    ,iiIi:,                                 
//                                 I,      : ≥  +∇∫•≥<  !  :      ,:                                  
//                                   ;I:   : °:I≠≥∑⋆≤-  =, :    ;,                                    
//                                        I   <∂•°∂•≤÷×I  , ;                                         
//                                       :.:   ≈•∇≠≥∑÷+    ; ,                                        
//                                       ;....  ∇I, ≠-   ;  ,                                         
//                                          <:i ∇⋆°∏∂+  : ; : .                                       
//                                      I;. Il.:≥∇∏±+< ;:.    :i                                      
//                                  :<l: I.. !II.      ,i   . ,  ,!I                                  
//                                 ilIIIi ;.  >!,,:;, : ;  ,.      .<                                 
//                                 !IiI;II: ; :.!Iii:,;   ;.  ,i.   .i                                
//                                !I,;Ii iii    ,<i::i. ,,  iii      l                                
//                                II ,i;; ,i,;   Il.:     i;i,     :  I                               
//                               i,.  ; ;:  ;. .  l..   ;, :   ,   :  .                               
//                                       .:        ,   .      ,.                                      
//                               iI   i;;IIIi IIi  ,I   .I.i;  i;  .=±+;                              
//                               ∂∂÷ ≥∂÷×∫!!! ∂i ≈∇>∇   :∂.√∇∫,∑× I∂-i,!.                             
//                               ≈I±≈-÷+>±... ≈×±≈,l≠   ,≠.≈=!≠≠> . ,;>≈l                             
//                               I: I i;;IIII I, ;I;IIII.I.Ii  I; .I<><I                              
//@version=6
indicator("Machine Learning Point Forecast with SR [SS]", overlay=true, max_bars_back = 1000, max_lines_count=50, max_labels_count=50, max_boxes_count=5)

// ui 
grp_knn  = "KNN Parameters"
grp_disp = "Display"

k_neighbors  = input.int(5,   title="K-Nearest Neighbors",     minval=1, maxval=20,  group=grp_knn)
lookback_win = input.int(200, title="Historical Search Window", minval=50, maxval=300, group=grp_knn,
              tooltip="Lower = faster, fewer timeout errors. 200 recommended for intraday.")
z_window     = input.int(100, title="Z-Score Window",          minval=20, maxval=200, group=grp_knn,
              tooltip="Total bars needed = Z-Score Window + Search Window. Keep sum under 400.")
proj_bars    = input.int(5,   title="Forecast Bars Forward",   minval=1, maxval=20,   group=grp_knn)

show_table    = input.bool(true, title="Show Stats Table",       group=grp_disp)
max_forecasts = input.int(20, title="Max Point Forecast Lines", minval=1, maxval=50, group=grp_disp,
              tooltip="Caps how many forecast lines stay on the chart at once. Oldest is dropped once the cap is exceeded; any line is also removed early if price reaches its target.")
group_threshold_pct = input.float(0.1, title="Group Targets Within (%)", minval=0.0, maxval=5.0, step=0.01, group=grp_disp,
              tooltip="If a new forecast target lands within this % of an existing one, they're merged (averaged) into a single line/label instead of stacking. Set to 0 to disable grouping.")


f_slope(src, len) => ta.change(ta.linreg(src, len, 0))

pct_h = (high  - open) / open * 100
pct_l = (low   - open) / open * 100
pct_c = (close - open) / open * 100
var1_euclidean  = math.sqrt(math.pow(pct_h, 2) + math.pow(pct_l, 2) + math.pow(pct_c, 2))
var2_closeSlope = f_slope(close, 14) / close * 100
var3_rsiSlope   = f_slope(ta.rsi(close, 14), 14)
candle_return   = (close - open) / open * 100
var4_retSlope   = f_slope(candle_return, 14)


f_zscore(src, len) =>
    mean = ta.sma(src, len)
    stdv = ta.stdev(src, len)
    stdv == 0 ? 0.0 : (src - mean) / stdv

z1 = f_zscore(var1_euclidean,  z_window)
z2 = f_zscore(var2_closeSlope, z_window)
z3 = f_zscore(var3_rsiSlope,   z_window)
z4 = f_zscore(var4_retSlope,   z_window)


ta.sma(z1, lookback_win + 1)
ta.sma(z2, lookback_win + 1)
ta.sma(z3, lookback_win + 1)
ta.sma(z4, lookback_win + 1)
ta.sma(close, lookback_win + 1)

var line[]  fc_lines   = array.new_line(0)
var label[] fc_labels  = array.new_label(0)
var float[] fc_targets = array.new_float(0)
var bool[]  fc_bullish = array.new_bool(0)

var table    tbl        = na


var float[] top_dist = array.new_float(k_neighbors, 999999.9)
var int[]   top_idx  = array.new_int(k_neighbors,   0)


if array.size(fc_lines) > 0
    for i = array.size(fc_lines) - 1 to 0
        t_price = array.get(fc_targets, i)
        t_bull  = array.get(fc_bullish, i)
        hit     = t_bull ? high >= t_price : low <= t_price
        if hit
            line.delete(array.get(fc_lines, i))
            label.delete(array.get(fc_labels, i))
            array.remove(fc_lines, i)
            array.remove(fc_labels, i)
            array.remove(fc_targets, i)
            array.remove(fc_bullish, i)

min_bars_needed = z_window + lookback_win + proj_bars + 5


if (barstate.islastconfirmedhistory or (barstate.isrealtime and barstate.isconfirmed)) and bar_index > min_bars_needed


    array.fill(top_dist, 999999.9)
    array.fill(top_idx,  0)

    for i = proj_bars to lookback_win
        dist = math.sqrt(
          math.pow(z1 - z1[i], 2) +
          math.pow(z2 - z2[i], 2) +
          math.pow(z3 - z3[i], 2) +
          math.pow(z4 - z4[i], 2))

        max_d = array.max(top_dist)
        if dist < max_d
            worst = array.indexof(top_dist, max_d)
            array.set(top_dist, worst, dist)
            array.set(top_idx,  worst, i)


    idw_sum        = 0.0
    idw_wt_sum     = 0.0
    hi_ret         = -99999.0
    lo_ret         =  99999.0
    bull_count     = 0
    bear_count     = 0
    valid_matches  = 0
    dist_sum       = 0.0

    for j = 0 to k_neighbors - 1
        idx = array.get(top_idx, j)
        d   = array.get(top_dist, j)
        
        if idx > 0 and d < 999999.0
            fwd_ret = (close[idx - proj_bars] - close[idx]) / close[idx]
            w       = d > 1e-10 ? 1.0 / d : 1e10

            idw_sum    += fwd_ret * w
            idw_wt_sum += w
            hi_ret     := math.max(hi_ret, fwd_ret)
            lo_ret     := math.min(lo_ret, fwd_ret)
            dist_sum   += d

            if fwd_ret >= 0
                bull_count += 1
            else
                bear_count += 1
            valid_matches += 1

    if valid_matches > 0
        avg_ret      = idw_wt_sum > 0 ? idw_sum / idw_wt_sum : 0.0
        avg_dist     = dist_sum / valid_matches
        pct_bull     = valid_matches > 0 ? bull_count / valid_matches * 100 : 0.0

        target_pt = close * (1 + avg_ret)
        target_hi = close * (1 + hi_ret)
        target_lo = close * (1 + lo_ret)

     
        merge_idx = -1
        if group_threshold_pct > 0.0 and array.size(fc_targets) > 0
            for i = 0 to array.size(fc_targets) - 1
                existing = array.get(fc_targets, i)
                pct_diff = math.abs(target_pt - existing) / existing * 100
                if pct_diff <= group_threshold_pct
                    merge_idx := i
                    break

        if merge_idx >= 0
            merged_target = (array.get(fc_targets, merge_idx) + target_pt) / 2
            merged_bull   = merged_target >= close
            merged_col    = merged_bull ? color.new(color.lime, 5) : color.new(color.red, 5)

            m_line  = array.get(fc_lines,  merge_idx)
            m_label = array.get(fc_labels, merge_idx)

            line.set_y1(m_line, merged_target)
            line.set_y2(m_line, merged_target)
            line.set_color(m_line, merged_col)

            label.set_y(m_label, merged_target)
            label.set_text(m_label, "TP " + str.tostring(merged_target, "#.##"))
            label.set_textcolor(m_label, merged_col)

            array.set(fc_targets, merge_idx, merged_target)
            array.set(fc_bullish, merge_idx, merged_bull)
        else
            is_bullish = avg_ret >= 0
            pt_col     = is_bullish ? color.new(color.lime, 5) : color.new(color.red, 5)

            new_fc = line.new(bar_index, target_pt, bar_index + proj_bars, target_pt,
                              color=pt_col, width=2, style=line.style_dashed,
                              extend=extend.right)

            new_lbl = label.new(bar_index, target_pt, text="TP " + str.tostring(target_pt, "#.##"),
                                style=label.style_label_down, size=size.normal,
                                color=color.new(color.black, 100), textcolor=pt_col)

            array.push(fc_lines,   new_fc)
            array.push(fc_labels,  new_lbl)
            array.push(fc_targets, target_pt)
            array.push(fc_bullish, is_bullish)
            if array.size(fc_lines) > max_forecasts
                old_line  = array.shift(fc_lines)
                old_label = array.shift(fc_labels)
                line.delete(old_line)
                label.delete(old_label)
                array.shift(fc_targets)
                array.shift(fc_bullish)

        // Stats table
        if show_table
            if not na(tbl)
                table.delete(tbl)

            bias_str   = avg_ret >= 0 ? "▲ BULLISH" : "▼ BEARISH"
            bias_col   = avg_ret >= 0 ? color.new(color.lime, 20) : color.new(color.red, 20)
            bg_dark    = color.new(color.black, 15)
            bg_med     = color.new(color.black, 35)
            txt_col    = color.white
            
            tbl := table.new(position.top_right, 2, 10,
                             border_color=color.new(color.gray, 50),
                             border_width=1,
                             frame_color=color.new(color.gray, 30),
                             frame_width=1)

            table.cell(tbl, 0, 0, "KNN 4-FACTOR MODEL", text_color=txt_col,
                        bgcolor=color.new(color.navy, 10), text_size=size.small,
                        text_halign=text.align_center)
            table.merge_cells(tbl, 0, 0, 1, 0)

            table.cell(tbl, 0, 1, bias_str, text_color=color.white,
                        bgcolor=bias_col, text_size=size.normal,
                        text_halign=text.align_center)
            table.merge_cells(tbl, 0, 1, 1, 1)

            table.cell(tbl, 0, 2, "Point Target",  text_color=color.silver, bgcolor=bg_dark, text_size=size.small)
            table.cell(tbl, 1, 2, str.tostring(target_pt, "#.##"), text_color=txt_col, bgcolor=bg_dark, text_size=size.small)

            table.cell(tbl, 0, 3, "High Target",   text_color=color.silver, bgcolor=bg_med,  text_size=size.small)
            table.cell(tbl, 1, 3, str.tostring(target_hi, "#.##"), text_color=color.new(color.teal, 10), bgcolor=bg_med, text_size=size.small)

            table.cell(tbl, 0, 4, "Low Target",    text_color=color.silver, bgcolor=bg_dark, text_size=size.small)
            table.cell(tbl, 1, 4, str.tostring(target_lo, "#.##"), text_color=color.new(color.orange, 10), bgcolor=bg_dark, text_size=size.small)

            table.cell(tbl, 0, 5, "Avg Fit Dist",  text_color=color.silver, bgcolor=bg_med,  text_size=size.small)
            table.cell(tbl, 1, 5, str.tostring(avg_dist, "#.####"), text_color=txt_col, bgcolor=bg_med, text_size=size.small)

            table.cell(tbl, 0, 6, "Similar Cases", text_color=color.silver, bgcolor=bg_dark, text_size=size.small)
            table.cell(tbl, 1, 6, str.tostring(valid_matches), text_color=txt_col, bgcolor=bg_dark, text_size=size.small)

            table.cell(tbl, 0, 7, "% Bullish",     text_color=color.silver, bgcolor=bg_med,  text_size=size.small)
            table.cell(tbl, 1, 7, str.tostring(pct_bull, "#.#") + "%",
                        text_color = pct_bull >= 50 ? color.new(color.lime, 10) : color.new(color.red, 10),
                        bgcolor=bg_med, text_size=size.small)

            table.cell(tbl, 0, 8, "% Bearish",     text_color=color.silver, bgcolor=bg_dark, text_size=size.small)
            table.cell(tbl, 1, 8, str.tostring(100 - pct_bull, "#.#") + "%",
                        text_color = pct_bull < 50 ? color.new(color.red, 10) : color.new(color.lime, 10),
                        bgcolor=bg_dark, text_size=size.small)

            table.cell(tbl, 0, 9, "Active Forecasts", text_color=color.silver, bgcolor=bg_med, text_size=size.small)
            table.cell(tbl, 1, 9, str.tostring(array.size(fc_lines)) + " / " + str.tostring(max_forecasts),
                        text_color=txt_col, bgcolor=bg_med, text_size=size.small)
````
