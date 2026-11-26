# BTC - PRISM: Proportional Risk & Institutional Sentiment Model

- url: https://www.tradingview.com/script/LS5nXizR/
- type: indicator
- pine_id: PUB;947640afb16841fa9f37d44559381fb9
- version: 1.0

## Description

[b]PRISM: Proportional Risk & Institutional Sentiment Model[/b]

[b]Overview[/b]
PRISM is a multi-dimensional quantitative suite engineered to identify structural turning points in Bitcoin market cycles. While traditional indicators often suffer from "regime drift" as market dynamics evolve—such as the transition from a retail-centric environment to the institutional ETF era—PRISM utilizes a [b]Consensus Ensemble Engine[/b] to maintain precision across fragmented market conditions. By synchronizing ten distinct data pillars across On-Chain health, TradFi flows, and global liquidity, PRISM provides a singular, high-conviction risk score between 0 and 100.

[b]The Core Engine: Classical vs. Adaptive Modeling[/b]
The unique mathematical foundation of PRISM is its dual-processing architecture. Every data pillar is calculated through two independent quantitative philosophies before being synthesized into the final consensus score.

[list]
[*] [b]The Classical Model (Fixed Baseline):[/b] Built on [b]Linear Normalization[/b], this model utilizes absolute historical boundaries (e.g., fixed Mayer Multiple and MVRV extremes). It asks: [i]"How extreme is this value relative to the blow-off tops of 2013, 2017, and 2021?"[/i] This model provides a "Hard Anchor" for the script, ensuring it remains grounded in Bitcoin’s long-term history.
[*] [b]The Adaptive Model (Statistical Rolling Baseline):[/b] Built on [b]Z-Score Standardization[/b], this model calculates the distance of the current value from its own 365-day mean in units of [b]Standard Deviation[/b]. It asks: [i]"How extreme is this value relative to the market behavior of the [i]last year[/i]?"[/i] This is critical for the modern era, where institutional floors and floors are evolving beyond historical precedents.
[/list]

[b]The Consensus Blend Mechanism[/b]
Through the [b]Model Blend[/b] input, users can calibrate the "weight" of these two philosophies. This effectively allows PRISM to monitor [b]20 data streams[/b] simultaneously.
[list]
[*] [b]0.0 (Classical):[/b] Prioritizes historical fixed targets.
[*] [b]0.6 (Professional Standard):[/b] My recommended default 40/60 blend. This provides a slight bias toward modern statistical sensitivity while maintaining a strong 40% anchor in historical cycle data.
[*] [b]1.0 (Adaptive):[/b] Focuses entirely on modern statistical deviations.
[/list]

[b]The Three-Stage Sell Engine: Saturation, Rollover, and Hysteresis[/b]
Unlike standard oscillators that trigger on a single spike, PRISM uses a logic-gated "Sell Engine" to differentiate between a healthy rally and terminal exhaustion.

[list]
[*] [b]Stage 1: Statistical Saturation (The Dots):[/b] This frequency-based signal monitors a lookback window (default 30 days). If the PRISM Score remains in the "Scorched Zone" (>75) for a specific density (default 20 out of 30 bars), a [b]Red Dot[/b] prints at the bottom. This pinpoint identifies [b]Liquidity Exhaustion[/b]—the point where "dry powder" is gone and the market is structurally overextended.
[*] [b]Stage 2: Momentum Rollover (The Hook):[/b] The engine monitors the first derivative (slope) of our ALMA signal line. A [b]Critical Sell State[/b] is triggered if the score is in the extreme zone (>80) and the slope turns negative, or if the raw score crosses under the signal line (The Hook).
[*] [b]Stage 3: Hysteresis State-Machine (The Glow):[/b] To eliminate "signal flickering," we use a [b]Hysteresis Glow[/b]. Once the Critical Sell State is activated, the engine [b]locks[/b] into a defensive posture. The red background shading remains active until the PRISM score drops below the 65-point [b]"Cooling Zone,"[/b] ensuring you do not re-enter during a distribution phase.
[/list]

[b]The ALMA Advantage (Arnaud Legoux Moving Average)[/b]
To provide the most responsive signal line possible, we utilize the ALMA rather than traditional EMAs.
[list]
[*] [b]Gaussian Weighting:[/b] The ALMA applies weights based on a Normal Distribution, allowing the signal line to "hug" the 10-pillar composite score with significantly less lag than a standard moving average.
[*] [b]Calibrated Response:[/b] PRISM is tuned with a [b]0.85 Offset[/b] and [b]Sigma of 6[/b], specifically optimized to catch momentum rollovers at the daily macro level.
[/list]

[b]The 10 Data Pillars: A 360-Degree Market Analysis[/b]
Every pillar represents a different vector of the Bitcoin economy, calculated twice and blended based on your settings:
[list]
[*] [b]1. BEAM (Cycle Mean):[/b] Tracks price deviation from the 1400-day baseline; a proxy for the [b]Bitcoin Power Law[/b].
[*] [b]2. MVRV Z-Score (Network Profitability):[/b] Measures the "Unrealized Profit" across the network to find profit-taking extremes.
[*] [b]3. Metcalfe Utility (Active Addresses):[/b] Ensures price growth is supported by actual network usage utility.
[*] [b]4. HODL-Wave Distribution (RHODL):[/b] Monitors the transfer of supply from "Smart Money" HODLers to new retail speculators.
[*] [b]5. AXIS Momentum (Dual-Speed RoC):[/b] Synthesizes dual-speed rates of change to filter out noise and find structural trend shifts.
[*] [b]6. Mayer Premium (Institutional Baseline):[/b] Measures extension from the 200-day institutional cost-basis.
[*] [b]7. Institutional SSR (Liquidity Check):[/b] Compares BTC market cap to the total supply of [i][symbol="CRYPTOCAP:USDT"]CRYPTOCAP:USDT[/symbol], [symbol="CRYPTOCAP:USDC"]CRYPTOCAP:USDC[/symbol], [symbol="FWB:DAI"]FWB:DAI[/symbol], and [symbol="CRYPTOCAP:PYUSD"]CRYPTOCAP:PYUSD[/symbol][/i] to verify buying power.
[*] [b]8. Money Flow (CMF Proxy):[/b] Volume-weighted tracking of accumulation vs. quiet institutional distribution.
[*] [b]9. ETF Absorption Intensity ($IBIT/[symbol="CBOE:FBTC"]CBOE:FBTC[/symbol]):[/b] A modern pillar tracking Wall Street demand relative to total market volume—essential for the 2026 regime.
[*] [b]10. Macro RSI (Cycle Saturation):[/b] High-timeframe relative strength monitoring for absolute velocity exhaustion.
[/list]

[b]User Inputs & Technical Configuration[/b]
To provide maximum flexibility for different trading styles, PRISM allows for some customization of its core engines:

[list]
[*] [b]Model Blend (0.0 - 1.0):[/b] The master slider for the Consensus Engine. Set to [b]0.0[/b] for a purely historical "Classical" view, [b]1.0[/b] for a purely statistical "Adaptive" view, or [b]0.6[/b] for the recommended professional consensus.
[*] [b]Heat Lookback (Days):[/b] The window used for the Saturation Dots. A higher number (e.g., 35) requires a longer period of overheating before a signal triggers, filtering out short-term "fake-outs."
[*] [b]Min Bars for Saturation (Density):[/b] The number of "Scorched" bars required within the lookback to trigger the Red Dots. Setting this to 20 (out of /30 (66% density)) provides a high-conviction signal for cycle tops.
[*] [b]Pro Lookback (Days):[/b] The period used by the Adaptive Model to calculate its rolling mean and standard deviation. 365 days is the standard for macro analysis.
[*] [b]ALMA Smoothing:[/b] Adjusts the "Signal Line" (Orange). We use the [i]Arnaud Legoux Moving Average[/i]. The lookback window can be adjusted in this field.
[/list]

[b]PRISM Dashboard[/b]
The bottom-right dashboard provides a real-time "Heartbeat" of the Bitcoin network:
[list]
[*] [b]Score:[/b] The final aggregate value of all 10 pillars (0–100). This is the "Mood" of the market.
[*] [b]Heat Density:[/b] A live counter (e.g., 15 / 30) showing how many days in the current window have been "Scorched."
[*] [b]Days to Exit:[/b] A dynamic countdown. It tells you exactly how many more "Hot" days are required before the Saturation Dots begin to print.
[*] [b]Data Status:[/b] A vital monitoring row. If a ticker like [symbol="NASDAQ:IBIT"]NASDAQ:IBIT[/symbol] or $MVRV becomes stale (no updates in 5 days) or is missing from your exchange, it will flag the specific ticker in Red to ensure you never trade on broken data.
[/list]

[b]Best Practices for Use[/b]
[list]
[*] [b]Timeframe:[/b] This indicator is strictly designed for the [b]1D (Daily) Chart[/b]. Using it on lower timeframes (1H, 4H) will result in "noisy" data and is not recommended for macro cycle detection.
[*] [b]The "Double Red" Confirmation:[/b] The highest probability exits occur when the [b]Red Shading (Glow)[/b] and the [b]Red Dots (Saturation)[/b] appear simultaneously. This confirms that both momentum has rolled over [i]and[/i] liquidity is exhausted.
[*] [b]Data Integrity:[/b] Always check the [b]Data Status[/b] in the dashboard. If you see a "STALE" or "MISSING" tag, the score may be skewed due to an external provider lag.
[/list]

[i][b]Disclaimer:[/b] Past performance is not indicative of future results. Trading Bitcoin involves significant risk. This script is for research and educational purposes and does not constitute financial advice.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ==========================================
// █▀█ █▀█ █▄▄   █▀▄▀█ ▄▀█ ▀█▀ █▄█ █▀
// █▀▄ █▄█ █▄█   █░▀░█ █▀█ ░█░ █░█ ▄█
// ==========================================
// © Rob_Maths

//@version=6
indicator("BTC - PRISM: Proportional Risk & Institutional Sentiment Model | RM", shorttitle="PRISM | RM", overlay=false, precision=0)

// ==========================================
// 1. SETTINGS & PARAMETERS
// ==========================================

// Consensus Model Settings
grp_ens   = "Consensus Engine"
model_mix = input.float(0.6, "Model Blend (0: Classic | 1: Pro)", minval=0.0, maxval=1.0, step=0.1, group=grp_ens, tooltip="Weights the normalization logic. 0.0 uses fixed historical targets (Classic). 1.0 uses adaptive statistical Z-scores (Pro). 0.5 balances both.")

// Exhaustion Engine Settings
grp_sell  = "Advanced Sell Engine"
heat_lookback = input.int(30, "Heat Density Lookback", minval=5, group=grp_sell, tooltip="The lookback window used to calculate the frequency of scorched bars.")
heat_density  = input.int(20, "Min Bars for Saturation", minval=1, group=grp_sell, tooltip="The number of bars required within the lookback window to trigger a red saturation dot.")

// Core Logic Settings
grp_mod   = "Statistical Parameters"
lookback  = input.int(365, "Pro Lookback (Days)", minval=20, group=grp_mod, tooltip="The period used by the Pro Model to calculate means and standard deviations.")
smLen     = input.int(14, "ALMA Smoothing", minval=1, group=grp_mod, tooltip="Lookback period for the Arnaud Legoux Moving Average signal line.")

// ==========================================
// 2. NORMALIZATION & DATA ENGINE
// ==========================================

// Fixed Linear Normalization (0-10)
f_norm_classic(val, min_v, max_v) => 
    math.max(0, math.min(10, nz((val - min_v) / (max_v - min_v) * 10, 5)))

// Adaptive Z-Score Normalization (0-10)
f_norm_pro(src, len) =>
    _mean = ta.sma(src, len)
    _std  = ta.stdev(src, len)
    _z    = (src - _mean) / (_std == 0 ? 0.000001 : _std)
    math.max(0, math.min(10, nz((_z + 2) * 2.5, 5)))

// Ensemble Pillar Logic (Blended 0-10)
calc_pillar(val, min_f, max_f, lb, blend) =>
    (f_norm_classic(val, min_f, max_f) * (1 - blend)) + (f_norm_pro(val, lb) * blend)

// External Data Fetching
mvrv       = request.security("INTOTHEBLOCK:BTC_MVRV", "D", close)
active_add = request.security("GLASSNODE:BTC_ACTIVEADDRESSES", "D", close)
active_1y  = request.security("GLASSNODE:BTC_ACTIVE1Y", "D", close)
ibit_vol   = request.security("NASDAQ:IBIT", "D", volume)
fbtc_vol   = request.security("BATS:FBTC", "D", volume)
btc_mc     = request.security("CRYPTOCAP:BTC", "D", close)
usdt_mc    = request.security("CRYPTOCAP:USDT", "D", close)
usdc_mc    = request.security("CRYPTOCAP:USDC", "D", close)
dai_mc     = request.security("CRYPTOCAP:DAI", "D", close)
pyusd_mc   = request.security("CRYPTOCAP:PYUSD", "D", close)

// Combined Liquidity Metrics
stables_mc = nz(usdt_mc) + nz(usdc_mc) + nz(dai_mc) + nz(pyusd_mc)

// Pillar 1: BEAM (Adaptive Logarithmic Multiple)
// Tracks logarithmic deviation from the 1400-day (4-year) cycle mean.
p1 = calc_pillar(math.log(close / ta.sma(close, 1400)) / 2.5, 0.1, 1.0, lookback, model_mix)

// Pillar 2: MVRV Z-Score (Financial Health)
// Measures the ratio between Market Value and Realized Value to find network profit extremes.
p2 = calc_pillar(mvrv, 0.5, 7.0, lookback, model_mix)

// Pillar 3: Metcalfe's Law (Network Utility)
// Models the fundamental valuation of the network based on daily Active Addresses.
p3 = calc_pillar(math.log(nz(active_add, 1)), 12.5, 14.5, lookback, model_mix)

// Pillar 4: RHODL Proxy (Supply Rotation)
// Tracks the movement of coins from long-term holders to new speculative entrants.
p4 = calc_pillar(100 - nz(active_1y, 50), 30, 70, lookback, model_mix)

// Pillar 5: AXIS Momentum (Dual-Speed RoC)
// Synthesizes dual-speed rate of change engines to capture structural trend shifts.
p5 = calc_pillar(ta.wma(ta.roc(close, 14) + ta.roc(close, 11), 10), -20, 30, lookback, model_mix)

// Pillar 6: Mayer Multiple (Institutional Extension)
// Evaluates price extension relative to the 200-day moving average baseline.
p6 = calc_pillar(close / ta.sma(close, 200), 0.6, 2.5, lookback, model_mix)

// Pillar 7: SSR Proxy (Liquidity Sidelines)
// Measures Bitcoin's market cap against the combined supply of major stablecoin competitors.
p7 = calc_pillar(btc_mc / (stables_mc > 0 ? stables_mc : 1), 10, 30, lookback, model_mix)

// Pillar 8: Institutional Money Flow (CMF Proxy)
// Uses volume-weighted price action to identify accumulation vs distribution phases.
p8 = calc_pillar(ta.sma(((close - low) - (high - close)) / (high - low == 0 ? 0.0000001 : high - low) * volume, 20) / ta.sma(volume, 20), -0.3, 0.3, lookback, model_mix)

// Pillar 9: ETF Absorption (Spot Demand)
// Tracks the percentage of total daily volume absorbed by leading institutional spot ETFs.
p9 = calc_pillar((nz(ibit_vol) + nz(fbtc_vol)) / (ta.sma(volume, 20) + 1), 0.05, 0.5, lookback, model_mix)

// Pillar 10: Macro RSI (Cycle Saturation)
// Analyzes high-timeframe momentum exhaustion and standard oscillator overextension.
p10 = calc_pillar(ta.rsi(close, 14), 30, 85, lookback, model_mix)

// Aggregate Score & Signal
total_score = p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10
signal_line = ta.alma(total_score, smLen, 0.85, 6)

// ==========================================
// 3. SELL ENGINE LOGIC
// ==========================================

// Saturation Check
is_scorched = total_score >= 75
scorched_count = math.sum(is_scorched ? 1 : 0, heat_lookback)
density_alert  = scorched_count >= heat_density

// Momentum Rollover
slope = signal_line - signal_line[1]
is_rolling_over = slope < 0 and slope[1] >= 0 
is_hook = ta.crossunder(total_score, signal_line) and total_score > 75

// State Machine with Hysteresis
var bool in_sell_zone = false
if (is_hook or (is_rolling_over and total_score > 80))
    in_sell_zone := true
else if total_score < 65
    in_sell_zone := false

// ==========================================
// 4. VISUALIZATION & PLOTTING
// ==========================================

// Color Palette
c_deep_blue   = color.rgb(0, 0, 139)
c_rm_orange   = color.rgb(255, 140, 0)
c_deep_red    = color.rgb(139, 0, 0)

rm_color = total_score < 25 ? color.from_gradient(total_score, 0, 25, c_deep_blue, color.blue) : 
           total_score <= 50 ? color.from_gradient(total_score, 25, 50, color.blue, color.gray) : 
           total_score <= 75 ? color.from_gradient(total_score, 50, 75, color.gray, c_rm_orange) : 
           color.from_gradient(total_score, 75, 100, c_rm_orange, c_deep_red)

// Main Plots
plot(total_score, "AUI Consensus", color=rm_color, linewidth=4, style=plot.style_columns, histbase=50)
plot(signal_line, "ALMA Signal", color=c_rm_orange, linewidth=2)

// Saturation Dots (Bottom)
plotshape(density_alert, "Peak Saturation Dots", shape.circle, location.bottom, color.new(color.red, 0), size=size.tiny)

// Danger Zone Shading
bgcolor(in_sell_zone ? color.new(color.red, 94) : na)

// Threshold Lines
hline(50, title="AXIS", color=color.new(color.gray, 50), linewidth=2, linestyle=hline.style_solid)
hline(75, title="SCORCHED", color=color.new(c_deep_red, 50), linestyle=hline.style_dashed)
hline(25, title="FROZEN", color=color.new(c_deep_blue, 50), linestyle=hline.style_dashed)

// ==========================================
// 5. DASHBOARD & SYSTEM MONITORING
// ==========================================

var table info = table.new(position.bottom_right, 2, 5, border_width=1, border_color=color.new(color.gray, 70))

// Data Integrity Monitor
f_check_status(val, name) =>
    _is_na    = na(val)
    _is_stale = ta.barssince(ta.change(val) != 0) > 5 
    _is_na ? name + ": MISSING" : _is_stale ? name + ": STALE" : ""

if barstate.islast
    string status = ""
    status += f_check_status(mvrv, "MVRV ")
    status += f_check_status(active_add, "Active_Add ")
    status += f_check_status(ibit_vol, "IBIT ")
    status += f_check_status(btc_mc, "BTC_MC ")
    status += f_check_status(usdt_mc, "USDT ")
    
    string data_health = status == "" ? "ALL SYSTEMS ONLINE" : status
    color  health_color = status == "" ? color.green : color.red

    table.cell(info, 0, 0, "MODEL BLEND", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, str.tostring(model_mix, "0.0"), bgcolor=color.black, text_color=color.white, text_size=size.small)
    
    table.cell(info, 0, 1, "SCORE", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, str.tostring(total_score, "#"), bgcolor=color.black, text_color=rm_color, text_size=size.small)
    
    table.cell(info, 0, 2, "HEAT DENSITY", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, str.tostring(scorched_count) + " / " + str.tostring(heat_lookback), bgcolor=color.black, text_color=color.white, text_size=size.small)
    
    table.cell(info, 0, 3, "DAYS TO EXIT", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    _days_left = math.max(0, heat_density - scorched_count)
    table.cell(info, 1, 3, str.tostring(_days_left), bgcolor=color.black, text_color=_days_left == 0 ? color.red : color.white, text_size=size.small)

    table.cell(info, 0, 4, "DATA STATUS", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, data_health, bgcolor=color.black, text_color=health_color, text_size=size.small)
````
