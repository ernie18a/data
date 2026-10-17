# Volatility Managed Kelly Leverage

- url: https://www.tradingview.com/script/Uo4s2KXe-Volatility-Managed-Kelly-Leverage/
- type: indicator
- pine_id: PUB;c87e89562f1748cfb4bea76a895dbfbf
- version: 1.0

## Description

The Volatility Managed Kelly Leverage (VMKL) indicator is a tool that dynamically adjusts position sizing based on forecasted market volatility. It helps you to optimize leverage exposure by systematically reducing risk during high volatility periods and increasing exposure when markets are calm.
VMKL adapts in real-time to changing market conditions, potentially generating alpha while smoothing volatility and reducing maximum drawdown.

This indicator implements the Optimal Volatility Plus Mean Strategy (OVPMS) from one of my favorite leverage papers:
"[url=https://financialfactory.com/wp-content/uploads/2014/01/alphagenerationandrisksmoothingusingmanagedvolatility.pdf]Alpha Generation and Risk Smoothing using Managed Volatility[/url]" by Tony Cooper (2010)

These are the key findings from the paper, which this indicator translates to real life:
[list]
[*]Volatility is predictable while returns are not
[*]Dynamic leverage based on volatility forecasts can generate significant excess returns
[*]The strategy reduces volatility of volatility (vovo), kurtosis, and maximum drawdown
[*]Tested on 125+ years of market data across multiple global indices
[*] The OVPMS strategy (translated into this indicator) returned 12.6% annual return vs 7.0% for buy-and-hold, with the same volatility as the underlying index. Outstanding.
[/list]
[b]The indicator calculates optimal leverage using a three-step process[/b]
[b]1. Volatility Forecasting[/b]
Uses Exponential Weighted Moving Average (EWMA):
σ²(t) = λ·σ²(t-1) + (1-λ)·r²(t-1)
This predicts next-day volatility from recent price movements
[b]2. Return Prediction[/b]
Expected Return = a × σ^(b+1)
Where:
[list]
[*]a = Power coefficient (baseline return, default: 0.10)
[*]b = Power exponent (return-volatility relationship, default: -1.76 for SPY)
[*]σ = Forecasted volatility
[/list]
The negative exponent means returns decrease as volatility increases - a well-documented market behaviour.
[b]3. Optimal Leverage Calculation[/b]
Full Kelly Leverage = μ / σ²
Actual Leverage = Full Kelly × Kelly Fraction × Caps × Smoothing
The Kelly Criterion provides the theoretically optimal leverage, which is then reduced via:
[list]
[*]Kelly Fraction: Safety margin (default 75% = three-quarter Kelly)
[*]Leverage Caps: Hard maximum and minimum limits
[*]Smoothing: SMA to reduce rebalancing frequency
[/list]
[b]The Core Insight: Volatility varies over time (volatility of volatility), and this variation is costly. By targeting consistent volatility through dynamic leverage:
[list]
[*]Reduces volatility drag - Compounding works better with stable volatility
[*]Reduces drawdowns - Automatically deleverages before crashes
[*]Reduces kurtosis - Fewer extreme return events
[*]Generates alpha - Exploits the return-volatility relationship
[/list][/b]
The indicator calculates optimal leverage in real-time using EWMA volatility forecasting and Kelly Criterion mathematics, automatically detecting market regimes from CASH to VERY AGGRESSIVE and respective leverages. The statistics table shows Full Kelly leverage, Kelly Fraction leverage, forecasted volatility, predicted returns, and current regime.
[b]Settings Guide[/b]
Please check the informational "i" in setting to get a lot more info. 
[b]You can also use preset configurations:
Conservative (Safe)[/b]
Kelly Fraction: 0.50
Max Leverage: 2.0x
Lambda: 0.97
Sensitivity: Enhanced
[b]Moderate (Balanced) ⭐ DEFAULT[/b]
Kelly Fraction: 0.75
Max Leverage: 3.0x
Lambda: 0.94
Sensitivity: Enhanced
[b]Aggressive (Maximum)[/b]
Kelly Fraction: 1.0
Max Leverage: 5.0x
Lambda: 0.90
Sensitivity: Standard
[b]Paper Replication (Academic)[/b]
Kelly Fraction: 1.0
Max Leverage: 3.0x
Lambda: 0.94
Sensitivity: Standard
Adaptive: ON
Smoothing: 1

Remember: LEVERAGE MAGNIFIES BOTH GAINS AND LOSSES
Let me know if you have questions!
By Henrique Centieiro

## Source Code

````pine
//@version=6
indicator("Volatility Managed Kelly Leverage", shorttitle="VMKL", overlay=false, max_labels_count=500)

// ============================================================
// VOLATILITY MANAGED KELLY LEVERAGE (VMKL)
// Based on Cooper (2010) OVPMS Strategy
// ============================================================

// ============ INPUTS ============
string GP_VOL = "📊 Volatility Settings"
string GP_MEAN = "🎯 Return Prediction"
string GP_RISK = "⚠️ Risk Controls"
string GP_SENSITIVITY = "🎚️ Sensitivity Tuning"
string GP_DISPLAY = "🎨 Display"
string GP_TABLE = "📋 Table"

// ============ VOLATILITY FORECASTING ============
lambda = input.float(0.94, "EWMA Lambda (λ)", minval=0.80, maxval=0.999, step=0.01, 
     tooltip="Controls how fast volatility estimates adapt to new information.\n\n" +
     "HOW IT WORKS:\n" +
     "• Higher λ = Longer memory, smoother estimates\n" +
     "• Lower λ = Shorter memory, faster reaction\n\n" +
     "HALFLIFE:\n" +
     "• 0.94 = 11 days (paper's standard)\n" +
     "• 0.90 = 7 days (faster)\n" +
     "• 0.97 = 23 days (slower)\n\n" +
     "Think of it as: How many days of history matter?\n" +
     "Paper uses 0.94 as optimal balance.", 
     group=GP_VOL)

vol_multiplier = input.float(1.0, "Volatility Multiplier", minval=0.5, maxval=2.0, step=0.1,
     tooltip="Manually adjust perceived volatility.\n\n" +
     "• 1.0 = Use calculated volatility as-is\n" +
     "• >1.0 = See MORE volatility → Lower leverage (more defensive)\n" +
     "• <1.0 = See LESS volatility → Higher leverage (more aggressive)\n\n" +
     "Example: 1.2 = Treat market as 20% more volatile than measured",
     group=GP_VOL)

use_realized_vol = input.bool(false, "Use Realized Volatility", 
     tooltip="Alternative volatility measurement method.\n\n" +
     "OFF (default): Uses close-to-close returns\n" +
     "ON: Uses high-low ranges (Parkinson estimator)\n\n" +
     "Parkinson method:\n" +
     "• Captures intraday volatility\n" +
     "• More sensitive to flash crashes\n" +
     "• Better for assets with large intraday swings\n\n" +
     "Recommended: OFF for most uses",
     group=GP_VOL)

// ============ RETURN PREDICTION ============
power_b = input.float(-1.76, "Power Exponent (b)", minval=-10.0, maxval=2.0, step=0.1, 
     tooltip="Controls the return-volatility relationship.\n\n" +
     "WHAT IT MEANS:\n" +
     "This parameter describes HOW MUCH returns change when volatility changes.\n" +
     "The formula: Expected Return = a × Volatility^(b+1)\n\n" +
     "INTERPRETATION:\n" +
     "• Negative b = Returns DECREASE as volatility INCREASES\n" +
     "• More negative = Stronger relationship\n" +
     "• b = -1.76 means: When vol doubles, expected return drops ~70%\n\n" +
     "FROM THE PAPER (Table 1):\n" +
     "• S&P 500 (SPY): -1.76 ⭐\n" +
     "• NASDAQ (QQQ): -1.71\n" +
     "• Russell 2000 (IWM): -1.82\n" +
     "• International: -1.87 to -3.18\n\n" +
     "WHY IT MATTERS:\n" +
     "More negative = More defensive in high volatility\n" +
     "Less negative = Less sensitive to vol changes\n\n" +
     "USE ADAPTIVE MODE to auto-calibrate for your asset,\n" +
     "or use values from paper's Table 1.", 
     group=GP_MEAN)

power_a = input.float(0.10, "Power Coefficient (a)", minval=0.001, maxval=0.30, step=0.01,
     tooltip="Baseline expected return in normal volatility.\n\n" +
     "WHAT IT MEANS:\n" +
     "This is a scaling factor that sets the overall return level.\n" +
     "Think of it as: 'What return do I expect in typical conditions?'\n\n" +
     "FORMULA: Expected Return = a × Volatility^(b+1)\n\n" +
     "TYPICAL VALUES:\n" +
     "• 0.08 = Conservative (expect 8% in normal vol)\n" +
     "• 0.10 = Moderate (expect 10% - paper's default) ⭐\n" +
     "• 0.12-0.15 = Aggressive (expect 12-15%)\n\n" +
     "HOW IT WORKS:\n" +
     "When volatility = 15% and b = -1.76:\n" +
     "• a = 0.08 → Expected return ≈ 9%\n" +
     "• a = 0.10 → Expected return ≈ 11%\n" +
     "• a = 0.12 → Expected return ≈ 13%\n\n" +
     "Higher 'a' = Higher expected returns = Higher leverage\n\n" +
     "Paper uses 0.10 for stocks.\n" +
     "USE ADAPTIVE MODE to auto-calibrate.", 
     group=GP_MEAN)

use_adaptive = input.bool(false, "🤖 Adaptive Parameters", 
     tooltip="Automatically estimate 'a' and 'b' from recent market data.\n\n" +
     "HOW IT WORKS:\n" +
     "• Analyzes relationship between past returns and volatility\n" +
     "• Updates parameters every 20 bars (monthly)\n" +
     "• Uses 500 bars of history (~2 years)\n\n" +
     "PROS:\n" +
     "• Adapts to changing market regimes\n" +
     "• No need to manually set parameters\n" +
     "• Automatically calibrates to your specific asset\n\n" +
     "CONS:\n" +
     "• Can produce unstable estimates\n" +
     "• May show unrealistic values (μ > 50%)\n" +
     "• Requires sufficient history\n\n" +
     "RECOMMENDATION:\n" +
     "• START with OFF, use paper's values\n" +
     "• Turn ON after you understand the indicator\n" +
     "• Monitor for unrealistic μ values (⚠️ warnings)",
     group=GP_MEAN)

adaptive_window = input.int(500, "Adaptive Window", minval=100, maxval=2000, step=50,
     tooltip="How many bars to analyze when estimating parameters.\n\n" +
     "500 bars ≈ 2 years of daily data\n" +
     "Longer window = More stable, slower to adapt",
     group=GP_MEAN)

adaptive_freq = input.int(20, "Recalibration Frequency", minval=1, maxval=100,
     tooltip="How often to recalculate adaptive parameters.\n\n" +
     "20 bars ≈ Monthly updates\n" +
     "Lower = More frequent updates, more reactive",
     group=GP_MEAN)

mu_cap = input.float(0.50, "Predicted μ Cap", minval=0.15, maxval=2.0, step=0.05,
     tooltip="Maximum allowed predicted return.\n\n" +
     "WHY WE NEED THIS:\n" +
     "In very low volatility, the formula can predict unrealistic returns\n" +
     "(like 100%+ annual return). This cap prevents that.\n\n" +
     "SETTINGS:\n" +
     "• 0.20 = Conservative (max 20% expected)\n" +
     "• 0.50 = Moderate (max 50% expected) ⭐\n" +
     "• 1.0+ = Aggressive (allow high predictions)\n\n" +
     "When μ hits the cap, you'll see ⚠️ warning and\n" +
     "the μ line turns orange.\n\n" +
     "Paper doesn't cap, but we recommend 0.50 for stability.",
     group=GP_MEAN)

// ============ RISK CONTROLS ============
max_leverage = input.float(3.0, "Maximum Leverage", minval=0.1, maxval=20.0, step=0.5, 
     tooltip="Hard cap on leverage - never exceed this.\n\n" +
     "FROM THE PAPER:\n" +
     "• Paper's practical maximum: 3.0x ⭐\n" +
     "• Theoretical optimum often higher\n" +
     "• Figure 7 shows most strategies peak around 2-3x\n\n" +
     "RISK LEVELS:\n" +
     "• 2.0x = Conservative, more dynamic range\n" +
     "• 3.0x = Moderate (paper's default) ⭐\n" +
     "• 5.0x+ = Aggressive, high ruin risk\n\n" +
     "RUIN RISK:\n" +
     "• 2x leverage = Wiped out on 50% drop\n" +
     "• 3x leverage = Wiped out on 33% drop\n" +
     "• 5x leverage = Wiped out on 20% drop\n\n" +
     "Paper recommends 3.0x as good balance.", 
     group=GP_RISK)

min_leverage = input.float(0.1, "Minimum Leverage", minval=0.0, maxval=5.0, step=0.1,
     tooltip="Floor for leverage - won't go below this.\n\n" +
     "• 0.0 = Can fully exit to cash in extreme volatility\n" +
     "• 0.1 = Maintain 10% minimum position ⭐\n" +
     "• 0.5 = Always stay at least 50% invested\n" +
     "• 1.0 = Never reduce below 100% (always fully invested)\n\n" +
     "Paper uses very low minimum (~0.1) to allow defensive\n" +
     "positioning during crashes (see 1987 crash in Figure 7).",
     group=GP_RISK)

kelly_fraction = input.float(0.75, "Kelly Fraction", minval=0.01, maxval=3.0, step=0.05,
     tooltip="What fraction of 'Full Kelly' leverage to actually use.\n\n" +
     "KELLY CRITERION BACKGROUND:\n" +
     "Full Kelly = Theoretically optimal leverage for max growth\n" +
     "But: Full Kelly is often too aggressive in practice!\n\n" +
     "COMMON FRACTIONS:\n" +
     "• 0.25 = Quarter Kelly (very conservative)\n" +
     "• 0.50 = Half Kelly (conservative, safe)\n" +
     "• 0.75 = Three-quarter Kelly (moderate) ⭐\n" +
     "• 1.00 = Full Kelly (paper's theoretical optimum)\n" +
     "• >1.0 = Beyond Kelly (not recommended!)\n\n" +
     "EXAMPLE:\n" +
     "If Full Kelly = 20x:\n" +
     "• 0.50 → Use 10x\n" +
     "• 0.75 → Use 15x\n" +
     "• 1.00 → Use 20x (risky!)\n\n" +
     "WHY NOT FULL KELLY?\n" +
     "• Estimation errors magnified\n" +
     "• Drawdowns are severe\n" +
     "• Real markets have fat tails\n\n" +
     "Paper uses 1.0 theoretically, but 0.75 is safer for real trading.\n" +
     "Most professionals use 0.25-0.50.", 
     group=GP_RISK)

vol_floor = input.float(0.10, "Volatility Floor", minval=0.01, maxval=0.50, step=0.01,
     tooltip="Minimum volatility assumption to prevent extreme leverage.\n\n" +
     "WHY WE NEED THIS:\n" +
     "In ultra-low volatility (like 5%), optimal leverage can\n" +
     "spike to 50x+, which is dangerous.\n\n" +
     "HOW IT WORKS:\n" +
     "If measured volatility < floor, we use the floor instead.\n\n" +
     "SETTINGS:\n" +
     "• 0.08 = Allows higher leverage (paper's typical)\n" +
     "• 0.10 = Moderate protection ⭐\n" +
     "• 0.12 = Conservative, limits max leverage\n\n" +
     "EXAMPLE (with Kelly = 1.0, μ = 10%):\n" +
     "• Vol floor 0.08 → Max leverage ≈ 15x\n" +
     "• Vol floor 0.10 → Max leverage ≈ 10x\n" +
     "• Vol floor 0.12 → Max leverage ≈ 7x\n\n" +
     "This is a safety feature - higher floor = lower max leverage.", 
     group=GP_RISK)

leverage_smooth = input.int(3, "Leverage Smoothing", minval=1, maxval=50, 
     tooltip="Smooth the leverage signal to reduce whipsaw.\n\n" +
     "Uses Simple Moving Average (SMA) of the raw leverage signal.\n\n" +
     "• 1 = No smoothing (most responsive, more trades)\n" +
     "• 3 = Light smoothing (balanced) ⭐\n" +
     "• 5 = Standard smoothing\n" +
     "• 10-20 = Heavy smoothing (very smooth, fewer trades)\n\n" +
     "TRADE-OFF:\n" +
     "Lower smoothing = Faster reaction, more rebalancing costs\n" +
     "Higher smoothing = Slower reaction, fewer costs\n\n" +
     "Paper uses daily rebalancing (smoothing = 1), but\n" +
     "3 days reduces costs with minimal lag.", 
     group=GP_RISK)

// ============ SENSITIVITY TUNING ============
sensitivity_mode = input.string("Enhanced", "Sensitivity Mode", 
     options=["Standard", "Enhanced", "Maximum"],
     tooltip="Apply a multiplier to volatility for more defensive positioning.\n\n" +
     "• Standard = Use calculated volatility as-is (paper's approach)\n" +
     "• Enhanced = Multiply volatility by 1.25x ⭐\n" +
     "• Maximum = Multiply volatility by 1.5x\n\n" +
     "EFFECT:\n" +
     "Higher perceived volatility → Lower leverage\n\n" +
     "This is an enhancement beyond the paper.\n" +
     "Enhanced mode makes the indicator more responsive.",
     group=GP_SENSITIVITY)

crash_protection = input.bool(false, "🛡️ Crash Protection", 
     tooltip="Extra defensive mode during volatility spikes.\n\n" +
     "When volatility exceeds threshold:\n" +
     "• Multiply volatility by 1.5x (see even more vol)\n" +
     "• Cut max leverage in half\n" +
     "• Chart turns red\n\n" +
     "This is an enhancement not in the original paper.\n\n" +
     "Recommended: OFF (paper doesn't use this)\n" +
     "Turn ON if you want extra crash protection.",
     group=GP_SENSITIVITY)

crash_threshold = input.float(0.25, "Crash Vol Threshold", minval=0.15, maxval=0.50, step=0.05,
     tooltip="Volatility level that triggers crash protection mode.\n\n" +
     "0.25 = 25% annualized volatility\n\n" +
     "Historical context:\n" +
     "• Normal market: 12-18%\n" +
     "• Elevated: 20-30%\n" +
     "• Crash: 30%+\n\n" +
     "Only applies if Crash Protection is ON.",
     group=GP_SENSITIVITY)

// ============ DISPLAY ============
show_vol = input.bool(true, "Show Volatility", group=GP_DISPLAY)
show_mu = input.bool(true, "Show Predicted Return", group=GP_DISPLAY)
show_zones = input.bool(true, "Show Regime Zones", group=GP_DISPLAY)
show_labels = input.bool(true, "Show Chart Labels", group=GP_DISPLAY)

// ============ TABLE ============
table_position = input.string("Top Right", "Position", 
     options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group=GP_TABLE)
table_size = input.string("Normal", "Size", 
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group=GP_TABLE)
table_theme = input.string("Dark", "Theme", 
     options=["Dark", "Light"],
     group=GP_TABLE)

// [Rest of the code remains exactly the same as the previous version...]
// ============ HELPER FUNCTIONS ============
get_table_position(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

get_table_text_size(sz) =>
    switch sz
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

get_theme_colors() =>
    if table_theme == "Light"
        [color.new(color.white, 0), color.new(color.gray, 0), color.new(color.black, 0), color.new(color.blue, 70)]
    else
        [color.new(#000000, 10), color.new(color.gray, 0), color.new(color.white, 0), color.new(color.aqua, 30)]

TRADING_DAYS = 252
returns = math.log(close / close[1])
initial_variance = ta.variance(returns, 20)

var float ewma_var = na

if use_realized_vol
    hl_returns = math.log(high / low)
    
    if na(ewma_var)
        ewma_var := ta.variance(hl_returns, 20) / (4 * math.log(2))
    else
        hl_var = math.pow(hl_returns, 2) / (4 * math.log(2))
        ewma_var := lambda * ewma_var + (1 - lambda) * hl_var
else
    if na(ewma_var)
        ewma_var := initial_variance
    else
        ewma_var := lambda * ewma_var + (1 - lambda) * math.pow(returns[1], 2)

adjusted_var = ewma_var * math.pow(vol_multiplier, 2)
raw_forecast_vol = math.sqrt(adjusted_var * TRADING_DAYS)
base_forecast_vol = math.max(raw_forecast_vol, vol_floor)

sensitivity_factor = switch sensitivity_mode
    "Standard" => 1.0
    "Enhanced" => 1.25
    "Maximum" => 1.5
    => 1.0

forecast_vol = base_forecast_vol * sensitivity_factor
vol_halflife = math.log(0.5) / math.log(lambda)

in_crash_mode = crash_protection and forecast_vol > crash_threshold
crash_vol_mult = in_crash_mode ? 1.5 : 1.0
effective_vol = forecast_vol * crash_vol_mult

var float estimated_a = power_a
var float estimated_b = power_b
var int last_calibration = 0

if use_adaptive and bar_index > adaptive_window and (bar_index - last_calibration) >= adaptive_freq
    float sum_x = 0.0
    float sum_y = 0.0
    float sum_xx = 0.0
    float sum_xy = 0.0
    int n = 0
    
    for i = 1 to adaptive_window
        if not na(returns[i]) and not na(ewma_var[i])
            past_vol = math.sqrt(ewma_var[i] * TRADING_DAYS)
            
            if past_vol > vol_floor and past_vol < 1.0
                ann_return = returns[i] * TRADING_DAYS
                
                if ann_return > 0.001 and ann_return < 0.5
                    x = math.log(past_vol)
                    y = math.log(ann_return / past_vol)
                    
                    sum_x += x
                    sum_y += y
                    sum_xx += x * x
                    sum_xy += x * y
                    n += 1
    
    if n > 100
        mean_x = sum_x / n
        mean_y = sum_y / n
        
        numerator = sum_xy - n * mean_x * mean_y
        denominator = sum_xx - n * mean_x * mean_x
        
        if math.abs(denominator) > 0.001
            estimated_b := numerator / denominator
            estimated_a := math.exp(mean_y - estimated_b * mean_x)
            estimated_b := math.max(-5.0, math.min(estimated_b, -0.5))
            estimated_a := math.max(0.05, math.min(estimated_a, 0.20))
            last_calibration := bar_index

final_a = use_adaptive ? estimated_a : power_a
final_b = use_adaptive ? estimated_b : power_b

raw_predicted_mu = final_a * math.pow(effective_vol, final_b + 1)
predicted_mu = math.min(raw_predicted_mu, mu_cap)
is_mu_capped = raw_predicted_mu > mu_cap

full_kelly_leverage = predicted_mu / (forecast_vol * forecast_vol)
kelly_fraction_leverage = full_kelly_leverage * kelly_fraction

effective_max = in_crash_mode ? max_leverage * 0.5 : max_leverage
capped_leverage = math.max(min_leverage, math.min(kelly_fraction_leverage, effective_max))

optimal_leverage = ta.sma(capped_leverage, leverage_smooth)

string regime = ""
color regime_color = color.gray

if in_crash_mode
    regime := "CRASH"
    regime_color := color.new(color.red, 70)
else if optimal_leverage >= 4.0
    regime := "VERY AGGRESSIVE"
    regime_color := color.new(color.lime, 85)
else if optimal_leverage >= 2.5
    regime := "AGGRESSIVE"
    regime_color := color.new(color.green, 85)
else if optimal_leverage >= 1.5
    regime := "GROWTH"
    regime_color := color.new(color.teal, 85)
else if optimal_leverage >= 0.75
    regime := "BALANCED"
    regime_color := color.new(color.yellow, 85)
else if optimal_leverage >= 0.25
    regime := "DEFENSIVE"
    regime_color := color.new(color.orange, 85)
else
    regime := "CASH"
    regime_color := color.new(color.maroon, 85)

leverage_color = in_crash_mode ? color.new(color.red, 0) : 
                 optimal_leverage > 3.0 ? color.new(#00ff00, 0) :
                 optimal_leverage > 2.0 ? color.new(#00d4ff, 0) :
                 optimal_leverage > 1.0 ? color.new(#ffaa00, 0) :
                 color.new(#ff4444, 0)

leverage_plot = plot(optimal_leverage, title="Optimal Leverage", 
     color=leverage_color, linewidth=3)

hline(0.0, title="Zero", color=color.new(color.gray, 60), linestyle=hline.style_solid)
hline(1.0, title="1x", color=color.new(color.white, 0), linestyle=hline.style_solid, linewidth=2)
hline(2.0, title="2x", color=color.new(color.yellow, 30), linestyle=hline.style_dashed, linewidth=1)
hline(3.0, title="3x", color=color.new(color.orange, 30), linestyle=hline.style_dashed, linewidth=1)
hline(5.0, title="5x", color=color.new(color.red, 40), linestyle=hline.style_dotted, linewidth=1)
hline(max_leverage, title="Max", color=color.new(color.fuchsia, 30), linestyle=hline.style_dotted, linewidth=2)

vol_plot = plot(show_vol ? forecast_vol * 10 : na, title="Volatility (×10)", 
     color=color.new(#ff3333, 0), linewidth=2)
hline(vol_floor * 10, title="Vol Floor (×10)", 
     color=color.new(#ff6666, 50), linestyle=hline.style_dotted)

hline(crash_threshold * 10, title="Crash Threshold (×10)", 
     color=crash_protection ? color.new(color.fuchsia, 40) : na, 
     linestyle=hline.style_dashed, linewidth=1)

mu_plot = plot(show_mu ? predicted_mu * 10 : na, title="Predicted μ (×10)", 
     color=is_mu_capped ? color.new(#ff8844, 0) : color.new(#dd88ff, 0), 
     linewidth=2)

bgcolor(show_zones ? regime_color : na, title="Regime")

if show_labels and barstate.islast
    label.new(bar_index, optimal_leverage,
         text="Leverage\n" + str.tostring(math.round(optimal_leverage, 2)) + "x",
         style=label.style_label_left, color=leverage_color, textcolor=color.white, size=size.small)
    
    if show_vol
        label.new(bar_index, forecast_vol * 10,
             text="Vol\n" + str.tostring(math.round(forecast_vol * 100, 1)) + "%",
             style=label.style_label_left, color=color.new(#ff3333, 20), textcolor=color.white, size=size.small)
    
    if show_mu
        mu_label_text = "μ\n" + str.tostring(math.round(predicted_mu * 100, 1)) + "%"
        if is_mu_capped
            mu_label_text := mu_label_text + " ⚠️"
        label.new(bar_index, predicted_mu * 10, text=mu_label_text,
             style=label.style_label_left, 
             color=is_mu_capped ? color.new(#ff8844, 20) : color.new(#dd88ff, 20), 
             textcolor=color.white, size=size.small)

[table_bg, text_gray, text_white, header_bg] = get_theme_colors()
text_size = get_table_text_size(table_size)

var table stats = table.new(get_table_position(table_position), 2, 11, 
     bgcolor=table_bg, border_width=2, border_color=header_bg, frame_width=1, frame_color=header_bg)

if barstate.islast
    table.cell(stats, 0, 0, "VMKL", bgcolor=header_bg, text_color=text_white, text_size=text_size)
    table.cell(stats, 1, 0, "VOL-MANAGED KELLY", bgcolor=header_bg, text_color=text_white, text_size=text_size)
    
    table.cell(stats, 0, 1, "Forecast Vol", text_color=text_gray, text_size=text_size)
    vol_color = forecast_vol > 0.30 ? color.red : forecast_vol > 0.20 ? color.orange : text_white
    table.cell(stats, 1, 1, str.tostring(math.round(forecast_vol * 100, 1)) + "%", 
         text_color=vol_color, text_size=text_size)
    
    table.cell(stats, 0, 2, "Vol Halflife", text_color=text_gray, text_size=text_size)
    table.cell(stats, 1, 2, str.tostring(math.round(vol_halflife, 1)) + " days", 
         text_color=text_gray, text_size=text_size)
    
    table.cell(stats, 0, 3, "Predicted μ", text_color=text_gray, text_size=text_size)
    mu_display_color = is_mu_capped ? color.orange : 
                       predicted_mu > 0.15 ? color.red : 
                       predicted_mu > 0.10 ? color.yellow : color.lime
    mu_text = str.tostring(math.round(predicted_mu * 100, 1)) + "%"
    if is_mu_capped
        mu_text := mu_text + " ⚠️"
    table.cell(stats, 1, 3, mu_text, text_color=mu_display_color, text_size=text_size)
    
    table.cell(stats, 0, 4, "Exponent (b)", text_color=text_gray, text_size=text_size)
    table.cell(stats, 1, 4, str.tostring(math.round(final_b, 2)), 
         text_color=color.yellow, text_size=text_size)
    
    table.cell(stats, 0, 5, "Coefficient (a)", text_color=text_gray, text_size=text_size)
    table.cell(stats, 1, 5, str.tostring(math.round(final_a, 3)), 
         text_color=color.yellow, text_size=text_size)
    
    table.cell(stats, 0, 6, "Full Kelly", text_color=text_gray, text_size=text_size)
    fk_text = str.tostring(math.round(full_kelly_leverage, 2)) + "x"
    if full_kelly_leverage > 20
        fk_text := fk_text + " ⚠️"
    table.cell(stats, 1, 6, fk_text, text_color=text_gray, text_size=text_size)
    
    table.cell(stats, 0, 7, "Kelly % Used", text_color=text_gray, text_size=text_size)
    table.cell(stats, 1, 7, str.tostring(math.round(kelly_fraction * 100, 0)) + "%", 
         text_color=text_gray, text_size=text_size)
    
    table.cell(stats, 0, 8, "After Kelly %", text_color=text_gray, text_size=text_size)
    table.cell(stats, 1, 8, str.tostring(math.round(kelly_fraction_leverage, 2)) + "x", 
         text_color=text_gray, text_size=text_size)
    
    table.cell(stats, 0, 9, "Regime", text_color=text_gray, text_size=text_size)
    table.cell(stats, 1, 9, regime, text_color=text_white, text_size=text_size)
    
    table.cell(stats, 0, 10, "FINAL LEVERAGE", bgcolor=header_bg, text_color=text_white, text_size=text_size)
    
    lev_color = optimal_leverage > 4.0 ? color.lime : 
                 optimal_leverage > 2.0 ? color.new(#00d4ff, 0) : 
                 optimal_leverage > 1.0 ? color.yellow : 
                 optimal_leverage > 0.5 ? color.orange : color.red
    
    table.cell(stats, 1, 10, str.tostring(math.round(optimal_leverage, 2)) + "x", 
         bgcolor=header_bg, text_color=lev_color, text_size=text_size)

alertcondition(in_crash_mode, title="🚨 CRASH MODE", message="VMKL: Crash protection activated")
alertcondition(ta.crossover(optimal_leverage, 3.0), title="Very Aggressive", message="VMKL: Leverage >3x")
alertcondition(ta.crossover(optimal_leverage, 2.0), title="Aggressive", message="VMKL: Leverage >2x")
alertcondition(ta.crossunder(optimal_leverage, 1.0), title="Defensive", message="VMKL: Leverage <1x")
alertcondition(ta.crossunder(optimal_leverage, 0.5), title="Cash", message="VMKL: Leverage <0.5x")
````
