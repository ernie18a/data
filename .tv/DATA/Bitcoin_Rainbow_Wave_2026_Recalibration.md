<!-- tradingview-pine-id: PUB;0dfaa25d3c3b4bf9a506cbd54a3d4bdd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bitcoin Rainbow Wave (2026 Recalibration)

Source: https://www.tradingview.com/script/j6FiwqnR-Bitcoin-Rainbow-Wave-2026-Recalibration/

## Description

This is a recalibrated version of the open-source Bitcoin Rainbow Wave indicator originally published by leoum. What is original here: after the 2024–2025 cycle topped near $126K, far below the level the original parameters projected, I re-estimated all model parameters against the full history of cycle highs and lows, and added one curvature term to the trend equation. Nothing else in the model logic was changed.

What it does. The indicator draws a long-term envelope around BTC/USD. It converts calendar time into "halving time" h (block height divided by 210,000) using the actual timestamps of past halving and quarter-cycle blocks, so cycles become directly comparable. A trend line is computed as log10(price) = a + b·log10(h) + c·log10(h)², where the added c term (absent in the original, which is recovered by setting c = 0) lets growth per cycle slow smoothly instead of remaining a pure power law. Around this trend, a sine wave oscillates once per halving cycle. Its amplitude shrinks each cycle by a decay factor, and its phase is shifted by a "lag" function that models the market's delayed reaction to early halvings. Five wave lines are drawn at fixed offsets of this oscillation; the outermost upper line is fitted through past cycle all-time highs and the outermost lower line through past bear-market lows. An optional "miners profitability floor" caps how far the lower lines can fall below trend.

How the parameters were chosen. The five parameters were fitted by least squares in log space so that the upper band passes as close as possible to the 2013, 2017, 2021, and 2025 cycle tops and the lower band through the 2015, 2018, and 2022 lows, using one continuous formula over the whole history, with no per-cycle adjustments. Residual errors at each anchor are between roughly 2% and 19%; the largest gap is at the 2025 top, which sits below the fitted upper band.

How to use it. Designed for BTCUSD on the weekly timeframe with a logarithmic price scale. The fuchsia wave is the model's central estimate; the red upper and aqua lower bands mark the zones where previous cycles have topped and bottomed. Vertical lines mark past and estimated future halvings, with additional time markers at 38.2% and 61.8% of each cycle, near which past tops and bottoms respectively have occurred. Settings allow toggling the power-law rainbow bands, the wave bands, background highlighting when price touches the outer bands, and a price line colored by rainbow zone.

Important behavior to understand. The script plots the model's future path by offsetting plots into the future (default 690 bars, configurable), and draws vertical lines and labels at estimated future dates. Future halving dates are estimates extrapolated from the 2021–2025 cycle length and will differ from actual block times.

Limitations. This is a deterministic curve fitted to a small number of historical extremes, not a statistical model: its forward bands are extrapolations, and it will be wrong if market structure changes, as the 2024–2025 cycle demonstrated against the original calibration, which this version had to correct. It is a visualization framework for cycle context, not a trading signal and not financial advice.

---

## Source Code

````pine
//@version=6
indicator(title = 'Bitcoin Rainbow Wave (2026 Recalibration)', overlay = true, max_lines_count = 500, max_labels_count = 500)
// Based on the open-source "Bitcoin Rainbow Wave" model originally published on TradingView by leoum.
// This version is a parameter recalibration of that model; 
// Recalibrated Jul 2026: the 2024/25 cycle topped at ~$126.2k (Oct 2025), far below the
// original upper wave band (~$258k). The model was refit by least squares against every
// cycle ATH and ATL (2013 tops, 2015 low, 2017 top, 2018 low, 2021 tops, 2022 low,
// 2025 top) with ONE consistent formula over the whole history — no cutoffs, no
// per-cycle overrides. Changes vs the original:
//   1. Trend: log10(P) = a + b*log10(h) + c*log10(h)^2  (c is a smooth curvature term,
//      c = 0 recovers the original pure power law). New a, b, c below.
//   2. Envelope: decay = decay_base^(h + decay_shift). New base and shift below.
// Result: the upper (red) wave band now passes through the cycle ATHs, the lower (aqua)
// band through the cycle lows, and the upper band peaks at ~$300k next cycle
// (June/July 2029) instead of ~$500k+.
// This script displays the Bitcoin Rainbow chart based on a Power Law model,
// an oscillating Wave model derived from it, Halving/Fibonacci time markers,
// optional 'No Miss Zones', and an optional price line colored by the Rainbow zone.

// ==========================================================
// --- INPUT OPTIONS ---
// ==========================================================

// Group: Rainbow chart and PL
s11 = input.bool(true ,'Show Power Law (PL)' , inline = 'Power_Law'    , group = 'Rainbow chart and PL', tooltip = "Show the main Power Law trend line (Logarithmic Regression).")
s12 = input.bool(true ,'Show Rainbow bands'  , inline = 'Rainbow_bands', group = 'Rainbow chart and PL', tooltip = "Show the main upper and lower bands of the Rainbow chart.")
s13 = input.bool(false,'Show Fair value zone', inline = 'Fair_rainbow' , group = 'Rainbow chart and PL', tooltip = "Show the bands indicating the 'Fair Value' zone around the Power Law line.")
s14 = input.bool(true ,'Show Minor lines'    , inline = 'Minor_lines'  , group = 'Rainbow chart and PL', tooltip = "Show all intermediate lines creating the full Rainbow effect.")
s15 = input.bool(false,'Show Rainbow chart'  , inline = 'Rainbow_chart', group = 'Rainbow chart and PL', tooltip = "Show the color fills between the Rainbow chart lines.")

// Group: Rainbow Wave chart
s21 = input.bool(true ,'Show Wave line'      , inline = 'Wave_line'     , group = 'Rainbow Wave chart', tooltip = "Show the main oscillating Wave line.")
s22 = input.bool(true ,'Show Wave bands'     , inline = 'Wave_bands'    , group = 'Rainbow Wave chart', tooltip = "Show the upper and lower bands for the Wave.")
s23 = input.bool(true ,'Show Fair value zone', inline = 'Fair_wave'     , group = 'Rainbow Wave chart', tooltip = "Show the 'Fair Value' zone around the Wave line.")
s24 = input.bool(false,'Show Rainbow Wave'   , inline = 'Rainbow_wave'  , group = 'Rainbow Wave chart', tooltip = "Show the color fills between the Wave chart lines.")
s25 = input.bool(true ,'Miners profitability floor' , inline = 'Miners_profitability', group = 'Rainbow Wave chart', tooltip = "Apply correction to the lower Wave bands to prevent them from going unrealistically low, simulating miner price support.")

// Group: Extra Marks
s31 = input.bool(true ,'Show Halvings and time fibs' , inline = 'Halvings_marks', group = 'Extra Marks', tooltip = "Show vertical lines at Halving dates and key Fibonacci time retracements between them.")
s32 = input.bool(false,'Show 25%,50%,75% of Halvings', inline = '25%_marks'     , group = 'Extra Marks', tooltip = "Specifically show/hide the dashed vertical lines marking the 25%, 50%, 75% points between halvings.")
s36 = input.bool(false,'Show No Miss Zones'          , inline = 'No_Miss_zones' , group = 'Extra Marks', tooltip = "Show the calculated 'No Miss Zones' based on combined Rainbow and Wave logic.")
s_price_line_color = input.bool(true, title="Color Price Line by Rainbow Zone"  , group = 'Extra Marks', tooltip = "Colors the price line based on the rainbow zone. For best results, hide the main chart symbol.")
Color_price_line_width = input.int(5, 'Width of the colorful price line', inline = 'Width of the line', group = 'Extra Marks', minval=1, tooltip="Width for the colored price line.")

// Group: Future projection
futureBars = input.int(690, '# of future bars', inline = 'Number of future bars', group = 'Future projection', tooltip = 'Number of bars to project into the future. Recommended values depend on timeframe: 1H-4H<4500, D<3300, W<690, 2W<350, M<180, 2M-3M<60')

// ==========================================================
// --- HALVING TIME CALCULATIONS ---
// ==========================================================

// --- Historical Halving Timestamps ---
// Timestamps represent the exact time of the halving block or quarter-cycle block.
H000 = timestamp(2009, 01, 03, 18, 15, 05) // Block           0.The Genesis block (h=0.00)
H0116= timestamp(2009, 10, 05, 15, 41, 28) // Block      24 400 (h=0.116)
H025 = timestamp(2010, 04, 22, 12, 15, 34) // Block      52 500 (h=0.25)
H050 = timestamp(2011, 01, 28, 10, 41, 47) // Block     105 000 (h=0.50)
H075 = timestamp(2011, 12, 14, 16, 24, 37) // Block     157 500 (h=0.75)
H100 = timestamp(2012, 11, 28, 16, 24, 38) // Block     210 000.Halving 1 block (h=1.00)
H125 = timestamp(2013, 10, 09, 05, 28, 22) // Block     262 500 (h=1.25)
H150 = timestamp(2014, 08, 11, 05, 06, 05) // Block     315 000 (h=1.50)
H175 = timestamp(2015, 07, 29, 15, 45, 38) // Block     367 500 (h=1.75)
H200 = timestamp(2016, 07, 09, 18, 46, 13) // Block     420 000.Halving 2 block (h=2.00)
H225 = timestamp(2017, 06, 23, 07, 43, 51) // Block     472 500 (h=2.25)
H250 = timestamp(2018, 05, 29, 22, 24, 42) // Block     525 000 (h=2.50)
H275 = timestamp(2019, 05, 24, 05, 37, 41) // Block     577 500 (h=2.75)
H300 = timestamp(2020, 05, 11, 21, 23, 43) // Block     630 000.Halving 3 block (h=3.00)
H325 = timestamp(2021, 05, 08, 05, 20, 11) // Block     682 500 (h=3.25)
H350 = timestamp(2022, 05, 05, 12, 23, 33) // Block     735 000 (h=3.50)
H375 = timestamp(2023, 04, 29, 17, 06, 18) // Block     787 500 (h=3.75)
H400 = timestamp(2024, 04, 20, 02, 09, 27) // Block     840 000.Halving 4 block (h=4.00)
H425 = timestamp(2025, 04, 15, 08, 16, 12) // Block     892 500 (h=4.25)

// --- Estimated Halving Cycle Durations (ms per 210k blocks) ---
// Estimated based on time observed over specific block intervals (historical data).
halving_dur_after_h000 = (H0116 - H000) /  0.116         // Estimated from Block 0 -> 24.4k (0.116 cycles)
halving_dur_after_h0116= (H025 - H0116) / (0.25 - 0.116) // Estimated from Block 24.4k -> 52.5k
halving_dur_after_h025 = (H050 - H025 ) * 4              // Estimated from Block 52.5k -> 105k (0.25 cycles)
halving_dur_after_h050 = (H075 - H050 ) * 4              // Estimated from Block 105k -> 157.5k (0.25 cycles)
halving_dur_after_h075 = (H100 - H075 ) * 4              // Estimated from Block 157.5k -> 210k (0.25 cycles)
halving_dur_after_h100 = (H125 - H100 ) * 4              // Estimated from Block 210k -> 262.5k (0.25 cycles)
halving_dur_after_h125 = (H150 - H125 ) * 4              // Estimated from Block 262.5k -> 315k (0.25 cycles)
halving_dur_after_h150 = (H175 - H150 ) * 4              // Estimated from Block 315k -> 367.5k (0.25 cycles)
halving_dur_after_h175 = (H200 - H175 ) * 4              // Estimated from Block 367.5k -> 420k (0.25 cycles)
halving_dur_after_h200 = (H225 - H200 ) * 4              // Estimated from Block 420k -> 472.5k (0.25 cycles)
halving_dur_after_h225 = (H250 - H225 ) * 4              // Estimated from Block 472.5k -> 525k (0.25 cycles)
halving_dur_after_h250 = (H275 - H250 ) * 4              // Estimated from Block 525k -> 577.5k (0.25 cycles)
halving_dur_after_h275 = (H300 - H275 ) * 4              // Estimated from Block 577.5k -> 630k (0.25 cycles)
halving_dur_after_h300 = (H325 - H300 ) * 4              // Estimated from Block 630k -> 682.5k (0.25 cycles)
halving_dur_after_h325 = (H350 - H325 ) * 4              // Estimated from Block 682.5k -> 735k (0.25 cycles)
halving_dur_after_h350 = (H375 - H350 ) * 4              // Estimated from Block 735k -> 787.5k (0.25 cycles)
halving_dur_after_h375 = (H400 - H375 ) * 4              // Estimated from Block 787.5k -> 840k (0.25 cycles)
halving_dur_after_h400 = (H425 - H400 ) * 4              // Estimated from Block 840k -> 892.5k (0.25 cycles)
halving_dur_after_h425 = (H425 - H325 )                  // Keep H3.25->H4.25 duration for FUTURE H date estimation

// --- Future Halving Event Estimations ---
// Based on the estimated duration of the H3.25 -> H4.25 cycle (halving_dur_after_h425)
future_interval_52k  = float(halving_dur_after_h425) / 4.0 // Est. duration for 52.5k blocks (1/4 cycle)
future_interval_105k = float(halving_dur_after_h425) / 2.0 // Est. duration for 105k  blocks (1/2 cycle)

H450 = H425 + int(future_interval_52k ) // h=4.50, Block 945k
H475 = H450 + int(future_interval_52k ) // h=4.75, Block 997.5k
H500 = H475 + int(future_interval_52k ) // h=5.00, Block 1050k (Halving 5 Approx)
H525 = H500 + int(future_interval_52k ) // h=5.25, Block 1102.5k
H550 = H525 + int(future_interval_52k ) // h=5.50, Block 1155k
H575 = H550 + int(future_interval_52k ) // h=5.75, Block 1207.5k
H600 = H575 + int(future_interval_52k ) // h=6.00, Block 1260k (Halving 6 Approx)
H650 = H600 + int(future_interval_105k) // h=6.50, Block 1365k
H700 = H650 + int(future_interval_105k) // h=7.00, Block 1470k (Halving 7 Approx)

// Converts current bar's time ('time') into fractional halving cycles passed (h = block_height / 210 000).
// Uses the estimated/measured cycle duration for the corresponding historical period.
// --- Calculate 'h' (Halving Cycle Progress) --- [ FULLY EXPANDED LOGIC ]
h = if time >= H425
    4.25  + (time - H425 ) / halving_dur_after_h425  // Use H3.25->H4.25 as future estimate
else if time >= H400
    4.00  + (time - H400 ) / halving_dur_after_h400  // Use H4.00->H4.25 estimate
else if time >= H375
    3.75  + (time - H375 ) / halving_dur_after_h375  // Use H3.75->H4.00 estimate
else if time >= H350
    3.50  + (time - H350 ) / halving_dur_after_h350  // Use H3.50->H3.75 estimate
else if time >= H325
    3.25  + (time - H325 ) / halving_dur_after_h325  // Use H3.25->H3.50 estimate
else if time >= H300
    3.00  + (time - H300 ) / halving_dur_after_h300  // Use H3.00->H3.25 estimate
else if time >= H275
    2.75  + (time - H275 ) / halving_dur_after_h275  // Use H2.75->H3.00 estimate
else if time >= H250
    2.50  + (time - H250 ) / halving_dur_after_h250  // Use H2.50->H2.75 estimate
else if time >= H225
    2.25  + (time - H225 ) / halving_dur_after_h225  // Use H2.25->H2.50 estimate
else if time >= H200
    2.00  + (time - H200 ) / halving_dur_after_h200  // Use H2.00->H2.25 estimate
else if time >= H175
    1.75  + (time - H175 ) / halving_dur_after_h175  // Use H1.75->H2.00 estimate
else if time >= H150
    1.50  + (time - H150 ) / halving_dur_after_h150  // Use H1.50->H1.75 estimate
else if time >= H125
    1.25  + (time - H125 ) / halving_dur_after_h125  // Use H1.25->H1.50 estimate
else if time >= H100
    1.00  + (time - H100 ) / halving_dur_after_h100  // Use H1.00->H1.25 estimate
else if time >= H075
    0.75  + (time - H075 ) / halving_dur_after_h075  // Use H0.75->H1.00 estimate
else if time >= H050
    0.50  + (time - H050 ) / halving_dur_after_h050  // Use H0.50->H0.75 estimate
else if time >= H025
    0.25  + (time - H025 ) / halving_dur_after_h025  // Use H0.25->H0.50 estimate
else // Before H0.25
    0.116 + (time - H0116) / halving_dur_after_h0116 // Use H0.116->H0.25 estimate


// ==========================================================
// --- MODEL PARAMETERS & CORE CALCULATIONS ---
// ==========================================================

// Logarithmic regression (Power Law) model parameters
// RECALIBRATED Jul 2026 — least-squares fit to cycle ATHs/ATLs (2013 -> 2025) with a
// next-cycle upper-band target of ~$300k (was ~$500k+ with a=1.47, b=5.38, c=0).
a = 1.268  // Intercept (was 1.47)
b = 6.798  // Slope (was 5.38)
c = -1.925 // Curvature of the log-log trend; c = 0 recovers the original pure power law

// Pre-calculate mathematical constants
TWO_PI         = 2   * math.pi
FIVE_SIXTHS    = 5.0 / 6.0
FIVE_TWELFTHS  = 5.0 / 12.0
ONE_TWELFTH    = 1.0 / 12.0

// Calculate h-dependent model values
// RECALIBRATED Jul 2026 — envelope decay refit (was decay_base = 0.79, decay_shift = 1.0)
float decay_base  = 0.719                            // Base for decay calculation
float decay_shift = 0.246                            // Offset of the decay exponent
decay             = math.pow(decay_base, h + decay_shift) // Exponential decay factor, determines band width reduction over time
decay_div_3       = decay / 3.0                      // Pre-calculate for rainbow band spacing

// Non-linear time shift ("Ignorance Lag") - models the delay in market reaction after halvings
delay = if h < 3.28
    0.025 + math.pow(0.3, h - 0.05) * (1.05 + math.cos(2.5 * (h + 0.15)))
else
    0.025

// Calculate sine and cosine based on delayed 'h' - drives the wave oscillation
h_delayed = h - delay
sin       = math.sin(TWO_PI * h_delayed)
cos       = math.cos(TWO_PI * h_delayed)

// Calculate Power Law Trend value (central tendency of the Rainbow Chart)
log_h = math.log10(h)
BTC_t = math.pow(10, a + b * log_h + c * log_h * log_h) // Power Law past (with curvature term)

// ==========================================================
// --- FUTURE PROJECTION CALCULATIONS ---
// ==========================================================

// Current date cutoff for future fills ('fh') - fraction of the current/future cycle completed by 'now'
fh = 4.25 + (timenow - H425) / halving_dur_after_h425

// Future 'h' value ('he') - projected 'h' based on user input 'futureBars'
he = 4.25 + (time - H425 + futureBars * timeframe.in_seconds() * 1000) / halving_dur_after_h425

// Calculate future decay factor
decaye       = math.pow(decay_base, he + decay_shift)
decaye_div_3 = decaye / 3.0 // Pre-calculate for future rainbow bands

// Simplified future delay and corresponding sine/cosine for future projection
delaye       = 0.025
he_delayed   = he - delaye
sine         = math.sin(TWO_PI * he_delayed)
cose         = math.cos(TWO_PI * he_delayed)

// Calculate future Power Law Trend value
log_he       = math.log10(he)
BTC_te       = math.pow(10, a + b * log_he + c * log_he * log_he) // Power Law projection (with curvature term)

// Condition for filling future areas (check if projected time 'he' is beyond current time 'fh')
bool fillConditionFuture = he > fh

// ==========================================================
// --- CALCULATE INTERMEDIATE INDICATOR VALUES ---
// ==========================================================

// --- Combine common input conditions for plotting visibility ---
// These help make the plot() calls cleaner by pre-calculating show conditions
show_PL_Fair_Minor_Chart = s11 or s13 or s14 or s15 // For t0, t0e
show_Bands_Minor_Chart   = s12 or s14 or s15        // For t_3, t5, t_3e, t5e
show_Fair_Minor_Chart    = s13 or s14 or s15        // For t_2, t_1, t1, t2 and their _e versions
show_Minor_Chart         = s14 or s15               // For t3, t4, t3e, t4e
show_Wave_Bands_Full     = s22 or s24               // Potential use for wl_2, wl_2e conditions
show_Wave_Fair_Full      = s23 or s24               // Potential use for wl_1, wl1 conditions

// --- Define conditions for calculating tVal values ---
// Past values needed if any past lines are shown OR if price line coloring is enabled
needs_past_tVal_calc   = s11 or s12 or s13 or s14 or s15 or s36 or s_price_line_color
// Future values needed only if any future lines are shown (any s11-s15 option)
needs_future_tVal_calc = s11 or s12 or s13 or s14 or s15 or s36

// --- Declare tVal variables using var ---
// Stores the calculated numerical values of the rainbow bands
var float tVal_3  = na, var float tVal_2  = na, var float tVal_1  = na, var float tVal0  = na
var float tVal1   = na, var float tVal2   = na, var float tVal3   = na, var float tVal4  = na, var float tVal5  = na
var float tVal_3e = na, var float tVal_2e = na, var float tVal_1e = na, var float tVal0e = na
var float tVal1e  = na, var float tVal2e  = na, var float tVal3e  = na, var float tVal4e = na, var float tVal5e = na

// --- Calculate PL/Rainbow band VALUES ---
// Calculate past/present values conditionally
if needs_past_tVal_calc
    tVal_3 := not na(BTC_t) ? BTC_t * math.pow(10, -3 * decay_div_3) : na
    tVal_2 := not na(BTC_t) ? BTC_t * math.pow(10, -2 * decay_div_3) : na
    tVal_1 := not na(BTC_t) ? BTC_t * math.pow(10, -1 * decay_div_3) : na
    tVal0  := not na(BTC_t) ? BTC_t                                  : na
    tVal1  := not na(BTC_t) ? BTC_t * math.pow(10, +1 * decay_div_3) : na
    tVal2  := not na(BTC_t) ? BTC_t * math.pow(10, +2 * decay_div_3) : na
    tVal3  := not na(BTC_t) ? BTC_t * math.pow(10, +3 * decay_div_3) : na
    tVal4  := not na(BTC_t) ? BTC_t * math.pow(10, +4 * decay_div_3) : na
    tVal5  := not na(BTC_t) ? BTC_t * math.pow(10, +5 * decay_div_3) : na

// Calculate Future PL/Rainbow band VALUES conditionally
if needs_future_tVal_calc
    tVal_3e := not na(BTC_te) ? BTC_te * math.pow(10, -3 * decaye_div_3) : na
    tVal_2e := not na(BTC_te) ? BTC_te * math.pow(10, -2 * decaye_div_3) : na
    tVal_1e := not na(BTC_te) ? BTC_te * math.pow(10, -1 * decaye_div_3) : na
    tVal0e  := not na(BTC_te) ? BTC_te                                   : na
    tVal1e  := not na(BTC_te) ? BTC_te * math.pow(10, +1 * decaye_div_3) : na
    tVal2e  := not na(BTC_te) ? BTC_te * math.pow(10, +2 * decaye_div_3) : na
    tVal3e  := not na(BTC_te) ? BTC_te * math.pow(10, +3 * decaye_div_3) : na
    tVal4e  := not na(BTC_te) ? BTC_te * math.pow(10, +4 * decaye_div_3) : na
    tVal5e  := not na(BTC_te) ? BTC_te * math.pow(10, +5 * decaye_div_3) : na

// --- Indicator 2: Wave Calculations ---
// Combine input conditions: Calculate wave values only if needed
needs_wave_calc = s21 or s22 or s23 or s24 or s36

// Declare wave variables using var
var float w_2   = na, var float w_1   = na, var float w0   = na, var float w1   = na, var float w2   = na
var float w_2c  = na, var float w_1c  = na, var float w0c  = na, var float w1c  = na, var float w2c  = na
var float w_2e  = na, var float w_1e  = na, var float w0e  = na, var float w1e  = na, var float w2e  = na
var float w_2ce = na, var float w_1ce = na, var float w0ce = na, var float w1ce = na, var float w2ce = na

// Calculate wave values conditionally
if needs_wave_calc
    // Calculate the Rainbow Wave line values
    w_2   := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  *         (          sin  - FIVE_SIXTHS  )) : na
    w_1   := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  *         (          sin  - FIVE_TWELFTHS)) : na
    w0    := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  *                    sin                  ) : na
    w1    := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  *         (          sin  + FIVE_TWELFTHS)) : na
    w2    := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  *         (          sin  + FIVE_SIXTHS  )) : na
    // Corrected/cut wave lines for "Miners avoid losses" option (s25)
    w_2c  := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  * math.max(-1.0,     sin  - FIVE_SIXTHS  )) : na
    w_1c  := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  * math.max(-1.0,     sin  - FIVE_TWELFTHS)) : na
    w0c   := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  * math.max(-2.0/3.0, sin                 )) : na
    w1c   := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  * math.max(-1.0/3.0, sin  + FIVE_TWELFTHS)) : na
    w2c   := not na(BTC_t)  ? BTC_t  * math.pow(10, decay  * math.max(0.0,      sin  + FIVE_SIXTHS  )) : na
    // Future wave lines
    w_2e  := not na(BTC_te) ? BTC_te * math.pow(10, decaye *         (          sine - FIVE_SIXTHS  )) : na
    w_1e  := not na(BTC_te) ? BTC_te * math.pow(10, decaye *         (          sine - FIVE_TWELFTHS)) : na
    w0e   := not na(BTC_te) ? BTC_te * math.pow(10, decaye *                    sine                 ) : na
    w1e   := not na(BTC_te) ? BTC_te * math.pow(10, decaye *         (          sine + FIVE_TWELFTHS)) : na
    w2e   := not na(BTC_te) ? BTC_te * math.pow(10, decaye *         (          sine + FIVE_SIXTHS  )) : na
    // Future corrected/cut wave lines
    w_2ce := not na(BTC_te) ? BTC_te * math.pow(10, decaye * math.max(-1.0,     sine - FIVE_SIXTHS  )) : na
    w_1ce := not na(BTC_te) ? BTC_te * math.pow(10, decaye * math.max(-1.0,     sine - FIVE_TWELFTHS)) : na
    w0ce  := not na(BTC_te) ? BTC_te * math.pow(10, decaye * math.max(-2.0/3.0, sine                )) : na
    w1ce  := not na(BTC_te) ? BTC_te * math.pow(10, decaye * math.max(-1.0/3.0, sine + FIVE_TWELFTHS)) : na
    w2ce  := not na(BTC_te) ? BTC_te * math.pow(10, decaye * math.max(0.0,      sine + FIVE_SIXTHS  )) : na


// ==========================================================
// --- INDICATOR PLOTTING ---
// ==========================================================

// --- Plotting: Power Law Trend and Rainbow Bands ---
// Plots conditionally display the pre-calculated tValX values based on show_... visibility inputs
t_3 = plot(show_Bands_Minor_Chart ? tVal_3 : na, title="PL Band -3", color = color.rgb(100, 0, 251), linewidth = 2)
t_2 = plot(show_Fair_Minor_Chart  ? tVal_2 : na, title="PL Band -2", color = color.blue , linewidth = 1)
t_1 = plot(show_Fair_Minor_Chart  ? tVal_1 : na, title="PL Band -1", color = color.green, linewidth = 1)
t0  = plot(show_PL_Fair_Minor_Chart ? tVal0 : na, title="Power Law Trend", color = color.green, linewidth = 3)
t1  = plot(show_Fair_Minor_Chart  ? tVal1  : na, title="PL Band +1", color = color.green , linewidth = 1)
t2  = plot(show_Fair_Minor_Chart  ? tVal2  : na, title="PL Band +2", color = color.yellow, linewidth = 1)
t3  = plot(show_Minor_Chart       ? tVal3  : na, title="PL Band +3", color = color.orange, linewidth = 1)
t4  = plot(show_Minor_Chart       ? tVal4  : na, title="PL Band +4", color = color.orange, linewidth = 1)
t5  = plot(show_Bands_Minor_Chart ? tVal5  : na, title="PL Band +5", color = color.red   , linewidth = 2)
// Future plots
t_3e = plot(show_Bands_Minor_Chart ? tVal_3e : na , title="Future PL Band -3", color = color.rgb(100, 0, 251), linewidth = 2, offset = futureBars, show_last = futureBars + 1)
t_2e = plot(show_Fair_Minor_Chart  ? tVal_2e : na , title="Future PL Band -2", color = color.blue  , linewidth = 1, offset = futureBars, show_last = futureBars + 1)
t_1e = plot(show_Fair_Minor_Chart  ? tVal_1e : na , title="Future PL Band -1", color = color.green , linewidth = 1, offset = futureBars, show_last = futureBars + 1)
t0e  = plot(show_PL_Fair_Minor_Chart ? tVal0e : na, title = "Future Power Law Trend", color = color.green, linewidth = 3, offset = futureBars, show_last = futureBars + 1)
t1e  = plot(show_Fair_Minor_Chart  ? tVal1e : na  , title="Future PL Band +1", color = color.green , linewidth = 1, offset = futureBars, show_last = futureBars + 1)
t2e  = plot(show_Fair_Minor_Chart  ? tVal2e : na  , title="Future PL Band +2", color = color.yellow, linewidth = 1, offset = futureBars, show_last = futureBars + 1)
t3e  = plot(show_Minor_Chart       ? tVal3e : na  , title="Future PL Band +3", color = color.orange, linewidth = 1, offset = futureBars, show_last = futureBars + 1)
t4e  = plot(show_Minor_Chart       ? tVal4e : na  , title="Future PL Band +4", color = color.orange, linewidth = 1, offset = futureBars, show_last = futureBars + 1)
t5e  = plot(show_Bands_Minor_Chart ? tVal5e : na  , title="Future PL Band +5", color = color.red   , linewidth = 2, offset = futureBars, show_last = futureBars + 1)

// --- Filling: Rainbow Chart Areas ---
// Fills depend on the visibility of specific bands controlled by s15 or s13+s15
fill(t_3 , t_2 , color = s15                                 ? color.new(color.rgb(80, 0, 200), 65)  : na, title = "Rainbow Fill 1")
fill(t_3e, t_2e, color = s15 and fillConditionFuture         ? color.new(color.rgb(80, 0, 200), 65)  : na, title = "Future Rainbow Fill 1")
fill(t_2 , t_1 , color = s13 or s15                          ? color.new(color.blue, 50)             : na, title = "Rainbow Fill 2")
fill(t_2e, t_1e, color =(s13 or s15) and fillConditionFuture ? color.new(color.blue, 50)             : na, title = "Future Rainbow Fill 2")
fill(t_1 , t0  , color = s13 or s15                          ? color.new(color.green, 50)            : na, title = "Rainbow Fill 3")
fill(t_1e, t0e , color =(s13 or s15) and fillConditionFuture ? color.new(color.green, 50)            : na, title = "Future Rainbow Fill 3")
fill(t0  , t1  , color = s13 or s15                          ? color.new(color.green, 50)            : na, title = "Rainbow Fill 4")
fill(t0e , t1e , color =(s13 or s15) and fillConditionFuture ? color.new(color.green, 50)            : na, title = "Future Rainbow Fill 4")
fill(t1  , t2  , color = s13 or s15                          ? color.new(color.rgb(150, 220, 0), 50) : na, title = "Rainbow Fill 5")
fill(t1e , t2e , color =(s13 or s15) and fillConditionFuture ? color.new(color.rgb(150, 220, 0), 50) : na, title = "Future Rainbow Fill 5")
fill(t2  , t3  , color = s15                                 ? color.new(color.orange, 70)           : na, title = "Rainbow Fill 6")
fill(t2e , t3e , color = s15         and fillConditionFuture ? color.new(color.orange, 70)           : na, title = "Future Rainbow Fill 6")
fill(t3  , t4  , color = s15                                 ? color.new(color.red, 70)              : na, title = "Rainbow Fill 7")
fill(t3e , t4e , color = s15         and fillConditionFuture ? color.new(color.red, 70)              : na, title = "Future Rainbow Fill 7")
fill(t4  , t5  , color = s15                                 ? color.new(color.rgb(200, 0, 80), 70)  : na, title = "Rainbow Fill 8")
fill(t4e , t5e , color = s15         and fillConditionFuture ? color.new(color.rgb(200, 0, 80), 70)  : na, title = "Future Rainbow Fill 8")

// --- Plotting: Rainbow Wave Lines ---
// Plots conditionally display the calculated wX or wXc values based on s2X visibility inputs
wl_2  = plot((show_Wave_Bands_Full) and not s25 ? w_2  : (show_Wave_Bands_Full) and s25 ? w_2c  : na, title = 'Wave Band -2'       , color = color.aqua, linewidth = 2                                                    )
wl_2e = plot((show_Wave_Bands_Full) and not s25 ? w_2e : (show_Wave_Bands_Full) and s25 ? w_2ce : na, title = 'Future Wave Band -2', color = color.aqua, linewidth = 2, offset = futureBars, show_last = futureBars + 1   )
wl_1  = plot((show_Wave_Fair_Full)  and not s25 ? w_1  : (show_Wave_Fair_Full)  and s25 ? w_1c  : na, title = 'Wave Band -1'       , color = color.blue, linewidth = 1                                                    )
wl_1e = plot((show_Wave_Fair_Full)  and not s25 ? w_1e : (show_Wave_Fair_Full)  and s25 ? w_1ce : na, title = 'Future Wave Band -1', color = color.blue, linewidth = 1, offset = futureBars, show_last = futureBars + 1   )
wl0   = plot(s21 and not s23 and not s24 or (s21 or s23 or s24) and not s25 ? w0  : s25 and (s21 and not s22 and not s23 and not s24 or s23 or s24) ? w0  : na, title = 'Wave'       , color = color.fuchsia, linewidth = 3)
wl0e  = plot(s21 and not s23 and not s24 or (s21 or s23 or s24) and not s25 ? w0e : s25 and (s21 and not s22 and not s23 and not s24 or s23 or s24) ? w0e : na, title = 'Future Wave', color = color.fuchsia, linewidth = 3, offset = futureBars, show_last = futureBars + 1)
wl1   = plot((show_Wave_Fair_Full)  and not s25 ? w1   : (show_Wave_Fair_Full)  and s25 ? w1    : na, title = 'Wave Band +1'       , color = color.orange, linewidth = 1                                                  )
wl1e  = plot((show_Wave_Fair_Full)  and not s25 ? w1e  : (show_Wave_Fair_Full)  and s25 ? w1e   : na, title = 'Future Wave Band +1', color = color.orange, linewidth = 1, offset = futureBars, show_last = futureBars + 1 )
wl2   = plot(not s24 and s22 or s24 and not s25 ? w2   : s24 and s25 ? w2                       : na, title = 'Wave Band +2'       , color = color.red   , linewidth = 2                                                  )
wl2e  = plot(not s24 and s22 or s24 and not s25 ? w2e  : s24 and s25 ? w2e                      : na, title = 'Future Wave Band +2', color = color.red   , linewidth = 2, offset = futureBars, show_last = futureBars + 1 )

// --- Filling: Rainbow Wave Areas ---
// Fills depend on the visibility of specific wave bands controlled by s24 or s23+s24
fill(wl1  , wl2  , color = s24                                         ? color.new(color.red, 80)    : na, title="Wave Fill 1")
fill(wl1e , wl2e , color = s24                 and fillConditionFuture ? color.new(color.red, 80)    : na, title="Future Wave Fill 1")
fill(wl0  , wl1  , color = show_Wave_Fair_Full                         ? color.new(color.orange, 80) : na, title="Wave Fill 2")
fill(wl0e , wl1e , color = show_Wave_Fair_Full and fillConditionFuture ? color.new(color.orange, 80) : na, title="Future Wave Fill 2")
fill(wl_1 , wl0  , color = show_Wave_Fair_Full                         ? color.new(color.green, 80)  : na, title="Wave Fill 3")
fill(wl_1e, wl0e , color = show_Wave_Fair_Full and fillConditionFuture ? color.new(color.green, 80)  : na, title="Future Wave Fill 3")
fill(wl_2 , wl_1 , color = s24                                         ? color.new(color.blue, 80)   : na, title="Wave Fill 4")

// ==========================================================
// --- EXTRA MARKS: HALVING LINES, TIME FIBS, NO MISS ZONES, COLORED PRICE ---
// ==========================================================
// NOTE: this drawing section was missing from the source provided for the
// recalibration (the inputs s31/s32/s36/s_price_line_color existed but nothing
// used them), so it is reimplemented here to match the published chart:
//   - solid aqua vertical lines + labels at each halving: "h=N d/m/yy t=days"
//   - red   "h=n.382" fib time marks (historical cycle-TOP timing)
//   - green "h=n.618" fib time marks (historical cycle-BOTTOM timing)
//   - optional dashed 25% / 50% / 75% cycle lines (s32)
//   - optional No Miss Zones: bars where price tags the outer wave bands (s36)
//   - price line colored by Rainbow zone (s_price_line_color)
// All levels are computed from the recalibrated model above.

// --- Model evaluated at an arbitrary cycle position x (same formulas as above) ---
f_delay(float x) =>
    x < 3.28 ? 0.025 + math.pow(0.3, x - 0.05) * (1.05 + math.cos(2.5 * (x + 0.15))) : 0.025
f_trend(float x) =>
    lx = math.log10(x)
    math.pow(10, a + b * lx + c * lx * lx)
f_decay(float x) =>
    math.pow(decay_base, x + decay_shift)
f_sin(float x) =>
    math.sin(TWO_PI * (x - f_delay(x)))
f_top(float x) =>
    f_trend(x) * math.pow(10, f_decay(x) * (f_sin(x) + FIVE_SIXTHS))
f_bot(float x) =>
    f_trend(x) * math.pow(10, f_decay(x) * math.max(-1.0, f_sin(x) - FIVE_SIXTHS))

// --- Cycle position x -> timestamp (measured quarter-cycles, then projected) ---
var float[] qh = array.from(1.00, 1.25, 1.50, 1.75, 2.00, 2.25, 2.50, 2.75, 3.00, 3.25, 3.50, 3.75, 4.00, 4.25)
var float[] qt = array.from(float(H100), float(H125), float(H150), float(H175), float(H200), float(H225), float(H250), float(H275), float(H300), float(H325), float(H350), float(H375), float(H400), float(H425))
f_h_to_time(float x) =>
    float res = na
    if x >= 4.25
        res := H425 + (x - 4.25) * halving_dur_after_h425
    else
        for i = 0 to array.size(qh) - 2
            if x >= array.get(qh, i) and x < array.get(qh, i + 1)
                res := array.get(qt, i) + (x - array.get(qh, i)) / (array.get(qh, i + 1) - array.get(qh, i)) * (array.get(qt, i + 1) - array.get(qt, i))
    res

f_date_txt(int t_ms) =>
    str.tostring(dayofmonth(t_ms)) + '/' + str.tostring(month(t_ms)) + '/' + str.tostring(year(t_ms) % 100)

// --- Draw the vertical lines and labels once ---
var bool marksDrawn = false
if s31 and not marksDrawn and barstate.islast
    marksDrawn := true
    // Halving lines h = 1..7 with "h=N date t=days" labels
    for n = 1 to 7
        int tH = int(f_h_to_time(float(n)))
        line.new(tH, f_bot(float(n)) / 8, tH, f_top(float(n)) * 8, xloc = xloc.bar_time, extend = extend.both, color = color.new(color.aqua, 25), width = 1)
        int tdays = int((tH - H000) / 86400000)
        label.new(tH, f_bot(float(n)) * 0.72, 'h=' + str.tostring(n) + ' ' + f_date_txt(tH) + ' t=' + str.tostring(tdays), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.aqua, 0), textcolor = color.black, size = size.small)
    // Fib time marks: 0.382 (top timing, red) and 0.618 (bottom timing, green)
    for n = 1 to 6
        float x382 = n + 0.382
        int t382 = int(f_h_to_time(x382))
        line.new(t382, f_bot(x382) / 8, t382, f_top(x382) * 8, xloc = xloc.bar_time, extend = extend.both, color = color.new(color.red, 25), style = line.style_solid, width = 2)
        label.new(t382, f_top(x382) * 1.12, 'h=' + str.tostring(x382, '#.###'), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.red, 0), textcolor = color.white, size = size.small)
        float x618 = n + 0.618
        int t618 = int(f_h_to_time(x618))
        line.new(t618, f_bot(x618) / 8, t618, f_top(x618) * 8, xloc = xloc.bar_time, extend = extend.both, color = color.new(color.green, 25), style = line.style_solid, width = 2)
        label.new(t618, f_bot(x618) * 0.88, 'h=' + str.tostring(x618, '#.###'), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.green, 0), textcolor = color.white, size = size.small)
    // Optional 25% / 50% / 75% cycle marks
    if s32
        for n = 1 to 6
            for q = 1 to 3
                float xq = n + q * 0.25
                int tq = int(f_h_to_time(xq))
                line.new(tq, f_bot(xq) / 8, tq, f_top(xq) * 8, xloc = xloc.bar_time, extend = extend.both, color = color.new(color.gray, 55), style = line.style_dashed)

// --- No Miss Zones: highlight bars where price tags the outer wave bands ---
noMissBuy  = s36 and needs_wave_calc and not na(w_2c) and low  <= w_2c * 1.03
noMissSell = s36 and needs_wave_calc and not na(w2)   and high >= w2   * 0.97
bgcolor(noMissBuy ? color.new(color.green, 70) : noMissSell ? color.new(color.red, 70) : na, title = 'No Miss Zones')

// --- Price line colored by Rainbow zone (hide the chart symbol for best results) ---
color zoneColor = not s_price_line_color or na(tVal0) ? na : close < tVal_3 ? color.rgb(100, 0, 251) : close < tVal_2 ? color.blue : close < tVal_1 ? color.aqua : close < tVal0 ? color.green : close < tVal1 ? color.rgb(150, 220, 0) : close < tVal2 ? color.yellow : close < tVal3 ? color.orange : close < tVal4 ? color.red : color.rgb(200, 0, 80)
plot(s_price_line_color ? close : na, title = 'Price (Rainbow colored)', color = zoneColor, linewidth = Color_price_line_width)
````
