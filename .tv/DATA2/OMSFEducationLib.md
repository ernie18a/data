<!-- tradingview-pine-id: PUB;54544f5019744f9181293bfa3547cb1f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# OMSF_Education_Lib

Source: https://www.tradingview.com/script/nuFOT0Rc-OMSF-Education-Lib/

## Description

To keep the codebase of the OMSF Learning Space indicator cleanly structured, easy to read, and as concise as possible, I have extracted core calculations and logic functions into this reusable library. This keeps the main script lightweight while allowing you to flexibly utilize these individual building blocks for your own custom scripts and quantitative experiments.

Extracted Functions & Modules

1. pivot_fun – Pivot Analytics & Trend State

[*]Derivatives of the classic Pivot High/Low concept to identify key structural highs and lows using configurable confirmation lookback windows.
[*]Provides continuously updated persistent pivot levels, running extreme levels, and a clean trend state machine (1 = Long, -1 = Short) along with standard pivot lag metrics (avg_std_delay).

2. dir_kaufman_eff_ratio – Directional Kaufman Efficiency Ratio (KER)

[*]Computes directional trend efficiency ranging from -1.0 (strong downward efficiency) to +1.0 (strong upward efficiency), featuring built-in protection against division by zero.

3. ker_marketstructure_validation – KER Market Structure Validation

[*]Accumulates and averages KER metrics separately for Long and Short market regimes to evaluate overall structural trend quality.

4. max_excurs_ratio – MFE / MAE Analytics

[*]Tracks ATR-normalized Maximum Favorable Excursion (MFE) and Maximum Adverse Excursion (MAE) values for individual trend segments.
[*]Computes running aggregate ratios and stores historical trade metrics in float[] arrays—ideal for statistical distribution and percentile analysis.

5. vis_mfe_mae_ratio_long & vis_mfe_mae_ratio_short – Visualization Components

[*]Renders dynamic chart overlays featuring break-even levels, stop-loss excursion bounds, color fills, and informational labels displaying real-time or locked segment performance.

📌 Coming next: 
OMSF Learning Space Update: Chapter 5 MFE/MAE. (https://www.tradingview.com/script/KYJoMqb1-OMSF-Learning-Space/)

Best regards, arni

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer

//////////////////////////////////////////////////////////////////////////////////////////////
// DISCLAIMER:                                                                               //
// This script is for educational and analytical purposes only. It does NOT provide          //
// financial advice, guaranteed trading signals, or proven strategies.                       //
// Trading involves significant risk. Your success depends on your own strategy,             //
// backtesting, and risk management. That's your job! ;)                                     //
///////////////////////////////////////////////////////////////////////////////////////////////
//@version=6

//@description Modular logic, market structure calculations, Kaufman Efficiency Ratio (KER),
//@description MFE/MAE excursion analytics, and chart visualization components extracted from 
//@description the OMSF Learning Space Indicator to maintain a clean and lightweight main script.



library("OMSF_Education_Lib", overlay = true)

// ===============================================================================
//|                              PIVOT LOGIC                                     |
// ===============================================================================
//@function Calculates standard high/low pivots, running extremes, pivot lines, and a simple market trend state.
//@param leftLenH Left bar length for pivot high.
//@param rightLenH Right bar length for pivot high.
//@param leftLenL Left bar length for pivot low.
//@param rightLenL Right bar length for pivot low.
//@returns Tuple [count_std_pivots, avg_std_delay, pivot_market_state, running_pivot_high, running_pivot_low, ph, pl, plot_ph, plot_pl]
//  - count_std_pivots (int): Accumulated total count of confirmed pivot points.
//  - avg_std_delay (float): Average confirmation lag in bars for high and low pivots.
//  - pivot_market_state (int): Market direction status (1 = Long, -1 = Short, na = Undefined).
//  - running_pivot_high (float): Highest price level over the left high lookback window.
//  - running_pivot_low (float): Lowest price level over the left low lookback window.
//  - ph (float): Confirmed Pivot High price level on the detection bar, otherwise 'na'.
//  - pl (float): Confirmed Pivot Low price level on the detection bar, otherwise 'na'.
//  - plot_ph (float): Active persistent price level of the last Pivot High while in High state.
//  - plot_pl (float): Active persistent price level of the last Pivot Low while in Low state.
export pivot_fun(int leftLenH, int rightLenH, int leftLenL, int rightLenL) =>
	// plot running pivots and last_pivot
	float ph = ta.pivothigh(leftLenH, rightLenH)
	float pl = ta.pivotlow(leftLenL, rightLenL)

	var float last_pivot = na
	var bool is_pivot_high = false

	if not na(ph)
		last_pivot    := ph
		is_pivot_high := true
	if not na(pl)
		last_pivot    := pl
		is_pivot_high := false

	float running_pivot_high = ta.highest(high, leftLenH)
	float running_pivot_low  = ta.lowest(low, leftLenL)

	// 2. Active Pivot Lines
	float plot_ph = is_pivot_high ? last_pivot : na
	float plot_pl = not is_pivot_high ? last_pivot : na

	// count pivots
	var int count_std_pivots = 0

	bool is_std_high = not na(ph), bool is_std_low  = not na(pl)

	if is_std_high or is_std_low
    	count_std_pivots += 1

    float avg_std_delay  = (rightLenH + rightLenL) / 2.0
	
    // simple Pivot-Trendfilterstates
    // 1. Pivot Trend Status (Integer State Machine: 1 = Long, -1 = Short)
	var int pivot_market_state = na, switch
		not na(pl) => pivot_market_state := 1
		not na(ph) => pivot_market_state := -1

	[count_std_pivots, avg_std_delay, pivot_market_state, running_pivot_high, running_pivot_low, ph, pl, plot_ph, plot_pl]

// ===============================================================================
//|                      KAUFMAN EFFICIENCY RATIO (KER)                           |
// ===============================================================================
//@function Calculates Kaufman's Efficiency Ratio (KER) over a defined lookback period for directional efficiency filtering.
//@param kerLen Lookback period for KER calculation.
//@returns Tuple [ker]
//  - ker (float): Directional efficiency ratio value ranging from -1.0 (strong downtrend) to +1.0 (strong uptrend).

export dir_kaufman_eff_ratio(int kerLen) =>	
	float direction = close - close[kerLen]
	float volatility = math.sum(math.abs(close - close[1]), kerLen)
	float ker = volatility != 0 ? (direction / volatility) : 0.0

	[ker]
    
// For use as a trend filter, see here: @link https://www.tradingview.com/script/wr5FCH3p-Kaufman-Efficiency-Ratio-Directional/
// ... and here: @link https://www.tradingview.com/script/j9hCD2lP-Kaufman-s-Efficiency-Ratio-Indicator/


// ===============================================================================
//|          KAUFMAN EFFICIENCY RATIO (KER) & FILTER STATES (PIVOT VS OMSF)       |
// ===============================================================================
//@function Validates market structure by separately accumulating and averaging KER for Long (1) and Short (-1) market states.
//@param ker Current KER value.
//@param market_state Current market state (1 = Long, -1 = Short).
//@returns Tuple [avg_ker_long, long_bars, avg_ker_short, short_bars]
//  - avg_ker_long (float): Accumulated average KER value during Long market states.
//  - long_bars (int): Total bar count evaluated in Long market state.
//  - avg_ker_short (float): Accumulated average KER value during Short market states.
//  - short_bars (int): Total bar count evaluated in Short market state.
export ker_marketstructure_validation(float ker, int market_state) =>
	var int long_bars = 0
	var int short_bars = 0
	var float long_ker_sum = 0.0
	var float short_ker_sum = 0.0

	if not na(market_state) and not na(ker)
		if market_state == 1
			long_bars += 1
			long_ker_sum += ker
		else if market_state == -1
			short_bars += 1
			short_ker_sum += ker

	float avg_ker_long  = long_bars > 0  ? (long_ker_sum / long_bars) : 0.0
	float avg_ker_short = short_bars > 0 ? (short_ker_sum / short_bars) : 0.0

	[avg_ker_long, long_bars, avg_ker_short, short_bars]

// ===============================================================================
//|                        EXCURSION ANALYTICS (MFE / MAE)                       |
// ===============================================================================
//@function Tracks ATR-normalized MFE (Maximum Favorable Excursion) and MAE (Maximum Adverse Excursion) for individual trend segments and maintains historical arrays for distribution/percentile analysis.
//@param market_state Current market direction status (1 = Long, -1 = Short, 0 or na = Inactive).
//@param max_trades_history Maximum number of completed trend segments stored in historical arrays.
//@returns Tuple [avg_mfe_up, avg_mae_up, avg_mfe_dn, avg_mae_dn, ratio_up, ratio_dn, curr_mfe, curr_mae, final_mfe, final_mae, long_mfes, long_maes, short_mfes, short_maes]
//  - avg_mfe_up (float): Historical average MFE (in ATR units) for all completed Long segments.
//  - avg_mae_up (float): Historical average MAE (in ATR units) for all completed Long segments.
//  - avg_mfe_dn (float): Historical average MFE (in ATR units) for all completed Short segments.
//  - avg_mae_dn (float): Historical average MAE (in ATR units) for all completed Short segments.
//  - ratio_up (float): Aggregate Reward/Risk ratio (avg_mfe_up / avg_mae_up) for Long segments.
//  - ratio_dn (float): Aggregate Reward/Risk ratio (avg_mfe_dn / avg_mae_dn) for Short segments.
//  - curr_mfe (float): Real-time Maximum Favorable Excursion of the active segment in ATR multiples.
//  - curr_mae (float): Real-time Maximum Adverse Excursion of the active segment in ATR multiples.
//  - final_mfe (float): Last locked MFE value of the most recently closed segment.
//  - final_mae (float): Last locked MAE value of the most recently closed segment.
//  - long_mfes (float[]): Array containing historical MFE values for completed Long segments.
//  - long_maes (float[]): Array containing historical MAE values for completed Long segments.
//  - short_mfes (float[]): Array containing historical MFE values for completed Short segments.
//  - short_maes (float[]): Array containing historical MAE values for completed Short segments.
export max_excurs_ratio(int market_state, int max_trades_history) =>
    var float start_price = na, var float start_atr = na
    var float curr_mfe = 0.0,   var float curr_mae = 0.0, var float final_mfe = 0.0,   var float final_mae = 0.0
    var float tot_mfe_up = 0.0, var float tot_mae_up = 0.0, var int seg_up = 0
    var float tot_mfe_dn = 0.0, var float tot_mae_dn = 0.0, var int seg_dn = 0

    var float[] long_mfes  = array.new_float(0)
    var float[] long_maes  = array.new_float(0)
    var float[] short_mfes = array.new_float(0)
    var float[] short_maes = array.new_float(0)

    bool state_changed = market_state != market_state[1]
    float atr = ta.atr(14)

    // Step 1: If a market condition was active on the previous bar, update active segment excursions
    if market_state[1] != 0 and not na(start_price) and start_atr > 0
        if market_state[1] == 1 // Long-Bedingung lief
            curr_mfe := math.max(curr_mfe, (high - start_price) / start_atr)
            curr_mae := math.max(curr_mae, (start_price - low) / start_atr)
        else if market_state[1] == -1 // Short-Bedingung lief
            curr_mfe := math.max(curr_mfe, (start_price - low) / start_atr)
            curr_mae := math.max(curr_mae, (high - start_price) / start_atr)

    // Steps 2 & 3: On state change, commit closed segment metrics to summary totals and arrays
    if state_changed
        if market_state[1] == 1 // Long-Phase beendet
            final_mfe := curr_mfe
            final_mae := curr_mae
            tot_mfe_up += curr_mfe 
            tot_mae_up += curr_mae
            seg_up     += 1
            array.push(long_mfes, curr_mfe)
            array.push(long_maes, curr_mae)
            if array.size(long_mfes) > max_trades_history
                array.shift(long_mfes), array.shift(long_maes)

        else if market_state[1] == -1 // Short-Phase beendet
            final_mfe := curr_mfe
            final_mae := curr_mae
            tot_mfe_dn += curr_mfe 
            tot_mae_dn += curr_mae
            seg_dn     += 1
            array.push(short_mfes, curr_mfe)
            array.push(short_maes, curr_mae)
            if array.size(short_mfes) > max_trades_history
                array.shift(short_mfes), array.shift(short_maes)

        // Step 4: Initialize new phase metrics (or reset to 'na' if state is inactive/0)
        if market_state != 0
            start_price := close
            start_atr   := atr
            curr_mfe    := 0.0
            curr_mae    := 0.0
        else
            start_price := na
            start_atr   := na
            curr_mfe    := 0.0
            curr_mae    := 0.0


    // Compute aggregate averages
    float avg_mfe_up = seg_up > 0 ? (tot_mfe_up / seg_up) : 0.0
    float avg_mae_up = seg_up > 0 ? (tot_mae_up / seg_up) : 0.0
    float avg_mfe_dn = seg_dn > 0 ? (tot_mfe_dn / seg_dn) : 0.0
    float avg_mae_dn = seg_dn > 0 ? (tot_mae_dn / seg_dn) : 0.0

    float ratio_up   = avg_mae_up > 0 ? (avg_mfe_up / avg_mae_up) : avg_mfe_up
    float ratio_dn   = avg_mae_dn > 0 ? (avg_mfe_dn / avg_mae_dn) : avg_mfe_dn

    [avg_mfe_up, avg_mae_up, avg_mfe_dn, avg_mae_dn, ratio_up, ratio_dn, curr_mfe, curr_mae, final_mfe, final_mae, long_mfes, long_maes, short_mfes, short_maes]

// ===============================================================================
//|                  VISUALIZATION FUNCTIONS (MFE / MAE LONG & SHORT)             |
// ===============================================================================

//@function Renders dynamic Long MFE/MAE bands (break-even, stop-loss, curve fills) and info labels directly on the chart.
//@param state Current market trend state (1 = Long, -1 = Short, 0 or na = Inactive).
//@param vis_excursion Label text prefix (e.g., 'Pivot-Trendfilter' or 'OMSF').
//@param curr_mfe Current active segment MFE value.
//@param curr_mae Current active segment MAE value.
//@param final_mfe Locked MFE value from the last completed segment.
//@param final_mae Locked MAE value from the last completed segment.
//@param long_color Color for Long trends / positive performance.
//@param short_color Color for Short trends / risk.
//@param omsf_color Text and break-even line color.
//@param show_label Toggle to show or hide the info label.
//@returns void Executes chart drawing commands (lines, fills, labels) and returns no value.
export vis_mfe_mae_ratio_long(int state, string vis_excursion, float curr_mfe, float curr_mae, float final_mfe, float final_mae, color long_color, color short_color, color omsf_color, bool show_label) =>
    var label pos_Lab_long = na
    bool is_long = state == 1
    bool state_shift = state != state[1]
    
    var float max_mfe = na, var float max_mae = na

    var float zero = na, var int state_shift_time = 0

    // 1. Initialization on new Long state transition
    if state_shift and is_long
        zero := close, state_shift_time := time, max_mfe := zero, max_mae := zero

    // 2. Separate tracking updates for extreme excursion levels
    if not state_shift and is_long or state_shift and not is_long
        if high > max_mfe
            max_mfe := high
        if low < max_mae
            max_mae := low  
        

    var line be_Line_long = na, var line sl_Line_long = na, var line max_crv_Line_long = na, var line run_crv_Line_long = na 
    var linefill risk_long = na, var linefill reward_long = na, var linefill max_crv_fill_long = na

    if is_long or is_long[1]
        line.delete(be_Line_long), line.delete(sl_Line_long), line.delete(max_crv_Line_long), line.delete(run_crv_Line_long)
        label.delete(pos_Lab_long)

        be_Line_long := line.new(state_shift_time, zero, time, zero, xloc = xloc.bar_time, color = color.new(omsf_color, 50), width = 1, style = line.style_solid, force_overlay = true)
        sl_Line_long := line.new(state_shift_time, max_mae, time, max_mae, xloc = xloc.bar_time, color = color.new(short_color, 100), width = 1, style = line.style_solid, force_overlay = true)
        max_crv_Line_long := line.new(state_shift_time, max_mfe, time, max_mfe, xloc = xloc.bar_time, color = color.new(is_long ? long_color : short_color, 100), width = 1, style = line.style_solid, force_overlay = true)
        run_crv_Line_long := line.new(state_shift_time, close , time, close , xloc = xloc.bar_time, color = color.new(long_color, 100), width = 1, style = line.style_solid, force_overlay = true)
        risk_long := linefill.new(sl_Line_long, be_Line_long , color = color.new(short_color, 60))
        reward_long := linefill.new(run_crv_Line_long, be_Line_long , color = color.new(close > zero ? long_color : short_color, 60))
        max_crv_fill_long := linefill.new(max_crv_Line_long, be_Line_long , color = color.new(long_color, 80))

        if show_label
            pos_Lab_long := label.new(state_shift_time + (time - state_shift_time)/2, zero,
                 text = vis_excursion + "\n" + 'MFE: ' + str.tostring(state_shift and not is_long ? final_mfe : curr_mfe,'#.00 | ') + 'MAE: ' + str.tostring(state_shift and not is_long ? final_mae : curr_mae,'#.00')
                 , xloc = xloc.bar_time, style = (curr_mfe > curr_mae) ? label.style_label_down : label.style_label_up,
                 color = (close > zero) ? color.new(long_color, 100) : color.new(short_color, 100),
                 textcolor = omsf_color, size = size.small, force_overlay = true)

//@function Renders dynamic Short MFE/MAE bands (break-even, stop-loss, curve fills) and info labels directly on the chart.
//@param state Current market trend state (1 = Long, -1 = Short, 0 or na = Inactive).
//@param vis_excursion Label text prefix (e.g., 'Pivot-Trendfilter' or 'OMSF').
//@param curr_mfe Current active segment MFE value.
//@param curr_mae Current active segment MAE value.
//@param final_mfe Locked MFE value from the last completed segment.
//@param final_mae Locked MAE value from the last completed segment.
//@param long_color Color for Long trends / positive performance.
//@param short_color Color for Short trends / risk.
//@param omsf_color Text and break-even line color.
//@param show_label Toggle to show or hide the info label.
//@returns void Executes chart drawing commands (lines, fills, labels) and returns no value.
export vis_mfe_mae_ratio_short(int state, string vis_excursion, float curr_mfe, float curr_mae, float final_mfe, float final_mae, color long_color, color short_color, color omsf_color, bool show_label) =>
    var label pos_Lab_short = na
    bool is_short = state == -1
    bool state_shift = state != state[1]
    
    var float max_mfe = na, var float max_mae = na

    var float zero = na, var int state_shift_time = 0

    // 1. Initialization on new Short state transition
    if state_shift and is_short
        zero := close, state_shift_time := time, max_mfe := zero, max_mae := zero

    // 2. Separate tracking updates for extreme excursion levels
    if not state_shift and is_short or state_shift and not is_short
        if low < max_mfe
            max_mfe := low
        if high > max_mae
            max_mae := high  
        

    var line be_Line_short = na, var line sl_Line_short = na, var line max_crv_Line_short = na, var line run_crv_Line_short = na 
    var linefill risk_short = na, var linefill reward_short = na, var linefill max_crv_fill_short = na

    if is_short or is_short[1]
        line.delete(be_Line_short), line.delete(sl_Line_short), line.delete(max_crv_Line_short), line.delete(run_crv_Line_short)
        label.delete(pos_Lab_short)

        be_Line_short := line.new(state_shift_time, zero, time, zero, xloc = xloc.bar_time, color = color.new(omsf_color, 50), width = 1, style = line.style_solid, force_overlay = true)
        sl_Line_short := line.new(state_shift_time, max_mae, time, max_mae, xloc = xloc.bar_time, color = color.new(short_color, 100), width = 1, style = line.style_solid, force_overlay = true)
        max_crv_Line_short := line.new(state_shift_time, max_mfe, time, max_mfe, xloc = xloc.bar_time, color = color.new(is_short ? long_color : short_color, 100), width = 1, style = line.style_solid, force_overlay = true)
        run_crv_Line_short := line.new(state_shift_time, close , time, close , xloc = xloc.bar_time, color = color.new(long_color, 100), width = 1, style = line.style_solid, force_overlay = true)
        risk_short := linefill.new(sl_Line_short, be_Line_short , color = color.new(short_color, 60))
        reward_short := linefill.new(run_crv_Line_short, be_Line_short , color = color.new(close < zero ? long_color : short_color, 60))
        max_crv_fill_short := linefill.new(max_crv_Line_short, be_Line_short , color = color.new(long_color, 80))

        if show_label
            pos_Lab_short := label.new(state_shift_time + (time - state_shift_time)/2, zero,
                 text = vis_excursion + "\n" + 'MFE: ' + str.tostring(state_shift and not is_short ? final_mfe : curr_mfe,'#.00 | ') + 'MAE: ' + str.tostring(state_shift and not is_short ? final_mae : curr_mae,'#.00')
                 , xloc = xloc.bar_time, style = (curr_mfe < curr_mae) ? label.style_label_down : label.style_label_up,
                 color = (close < zero) ? color.new(long_color, 100) : color.new(short_color, 100),
                 textcolor = omsf_color, size = size.small, force_overlay = true)


//Made in Germany 🇩🇪 ☺
````
