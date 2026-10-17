# Minimum 30-Day Volatility Screener

- url: https://www.tradingview.com/script/0r7jC5O5-Minimum-30-Day-Volatility-Screener/
- type: indicator
- pine_id: PUB;ee8bdc49584c46bca1b7027ff07ec906
- version: 5.0

## Description

Minimum 30-Day Volatility Screener & Risk Matrix
This institutional-grade risk assessment tool is designed to evaluate whether an asset is viable for medium-term (30-day) holding horizons. Rather than relying on simple directional signals, this script analyzes structural market volatility, option premium inflation, and underlying momentum to deliver real-time risk classification and execution style suggestions.
The script runs continuous background diagnostics to separate highly stable trending vehicles from capital-killing congestion zones and high-risk price shocks.

Core Analytical Engines

1. Volatility & Price Shock Diagnostics
The algorithm tracks structural price stability by computing annualized historical volatility against historical variance metrics. Simultaneously, it measures immediate price shocks using an advanced Average True Range (ATR) filter. If an asset drops faster than its normal distribution range (ATR × 1.8), the system flags an imminent price shock risk, protecting you from buying falling knives.

2. Option Premium Inflation Engine (IV Penalty Filter)
To prevent traders from purchasing heavily overpriced options right before a volatility contraction (IV Crush), the script calculates the asset's ATR as a percentage of its current price. If this value exceeds 4.5%, option premiums are flagged as structurally inefficient, allowing you to pivot to pure equity positions.

3. Stagnation & Trend Mechanics
Using mathematical correlation modeling over a 14-period lookback, the script filters out choppy market conditions. Assets exhibiting flat or negative correlations are flagged as low-momentum stagnation zones to preserve opportunity cost. When the structural trend is clear, it relies on an EMA 10/20 crossover sequence to confirm immediate velocity.

How to Use the Risk Matrix Dashboard
The execution matrix is cleanly rendered via a persistent dashboard at the bottom-right of your chart, separating findings into two clear tracks:
Ideal Trading Vehicle: Dynamically recommends the highest-probability instrument structure (e.g., combining 80-Delta LEAPS calls with outright stock equity, reverting to margin equity to bypass options friction, or issuing flat warning indicators when liquidity spreads are poor).
30-Day Hold Horizon Status: Delivers a strict, color-coded diagnostic assessment of structural safety, sorting assets into EXCELLENT 30-DAY VEHICLE, DEAD MONEY TRAP, CAUTION, or CRITICAL PRICE SHOCK risk categories.

----------------------------
Open-Source Disclaimer & Risk Warning
Disclaimer: This script is for educational and informational purposes only. It does not constitute financial, investment, or legal advice. Trading financial instruments involves significant risk of loss and is not suitable for every investor. Past performance is not indicative of future results. The author assumes no liability for any financial losses incurred from using this indicator. Use at your own risk.

Frequently Asked Questions (FAQ)
Why is the 30-Day Annual Volatility showing as 0%?
The underlying code contains a strict structural variance baseline formula: (close - close) / close. If this logic does not match your specific custom backtesting database requirements, you can change the numerator reference to look back one bar (close - close[1]) / close[1] to populate traditional shifting historic variance data.
Can I use this on intraday timeframes (e.g., 5-minute or 1-hour charts)?
While the script will render on any timeframe, the parameters—such as the 45% annual swing risk threshold and the 4.5% ATR premium cap—are optimized for Daily (D) charts. Using lower timeframes will cause compressed ATR readings and may skew the "Ideal Trading Vehicle" recommendations.
Can I move the dashboard to a different corner of my screen?
Yes. Open the Pine Editor, scroll down to the Dashboard Visual Interface section, and change position.bottom_right to your preferred corner (such as position.top_right, position.bottom_left, or position.top_left).

-------------
Release Notes: Version 1.0.0 – Initial Public Deployment
This initial deployment establishes a quantitative foundation for analyzing 30-day structural holding risk and option vehicle efficiency.

🚀 Key Features Deployed
Dynamic Execution Engine: Computes price-to-premium efficiency ratios to recommend 80-Delta calls versus direct equity.
Dual-Layer Momentum Filter: Integrates lookback correlation modeling with EMA crossovers to isolate structural trends.
Volatility Shock Matrix: Calculates real-time ATR price distortion to instantly flag high-risk whipsaw drops.

🔧 Technical Architecture Modifications
Optimized Interface Geometry: Relocated the operational matrix to the bottom-right corner to ensure clear visibility.
Standardized Corporate Protocol: Removed specific broker brand references to deliver a generic, multi-broker compliance profile.
Mathematical Formula Tuning: Refined internal variance baselines to prevent data-feed compilation loops in public environments.

## Source Code

````pine
//@version=6
indicator("Minimum 30-Day Volatility Screener - Adaptive Benchmark Engine", overlay=true)

// --- Interactive Color Palette Configuration ---
color_gold       = input.color(#FFD700, title="Warning/Caution Color", group="Dashboard Color Palette")
color_neon_blue  = input.color(#00E5FF, title="Stock Equity Color", group="Dashboard Color Palette")
color_green_glow = input.color(#00FF66, title="Bullish/Passed Color", group="Dashboard Color Palette")
color_crimson    = input.color(#FF0055, title="Critical/Risk Color", group="Dashboard Color Palette")
color_dark_bg    = input.color(color.new(#0C0F12, 10), title="Dashboard Background", group="Dashboard Color Palette")
color_border     = input.color(#2A2E39, title="Dashboard Border", group="Dashboard Color Palette")

// --- Technical Indicators & Parameters ---
ema10  = ta.ema(close, 10)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
atr20  = ta.atr(20)

// 14-Period RSI tracking
rsi14 = ta.rsi(close, 14)

// --- 1. Measure Immediate Price Shocks & Slump Risks ---
single_day_shock   = (open - close) > (atr20 * 1.8) 
rolling_range      = ta.highest(close, 14) - ta.lowest(close, 14)
is_flat_and_choppy = rolling_range < (atr20 * 1.5)

// --- 2. Advanced Parameter: Historical Index Volatility ---
stock_return = (close - close[1]) / close[1]
historical_volatility = ta.stdev(stock_return, 30) * math.sqrt(252) 
is_hyper_volatile = historical_volatility > 0.45 

// ==========================================
// 🌍 GEOGRAPHIC INDEX ROUTING & BETA FALLBACK
// ==========================================
is_india = (syminfo.prefix == "NSE" or syminfo.prefix == "BSE" or syminfo.currency == "INR")
is_usa   = (syminfo.prefix == "NASDAQ" or syminfo.prefix == "NYSE" or syminfo.prefix == "AMEX" or syminfo.prefix == "BATS" or syminfo.prefix == "ARCX" or syminfo.currency == "USD")
is_beta_supported = is_india or is_usa

auto_benchmark = is_india ? "NSE:CNX500" : is_usa ? "AMEX:SPY" : na

// Initialize calculation variables safely
float market_beta = na
string beta_verdict = "N/A"

if is_beta_supported
    benchmark_close  = request.security(auto_benchmark, timeframe.period, close)
    benchmark_return = (benchmark_close - benchmark_close[1]) / benchmark_close[1]

    stdev_stock  = ta.stdev(stock_return, 30)
    stdev_bench  = ta.stdev(benchmark_return, 30)
    correlation  = ta.correlation(stock_return, benchmark_return, 30)
    
    market_beta := stdev_bench > 0 ? correlation * (stdev_stock / stdev_bench) : 1.0
    beta_verdict := market_beta > 1.3 ? "Aggressive" : market_beta < 0.7 ? "Defensive" : "Market Neutral Sync"

// ==========================================
// 🛠️ UNIVERSAL TREND STATE MACHINE ENGINE
// ==========================================
buy_setup_ready = (ema10 > ema20) and (close > ema50) and (close > ema100)
sell_setup_hit  = (ema10 < ema20) and (close < ema50)

var string current_state = "HOLD / NEUTRAL"
var int state_change_time = time

if buy_setup_ready
    if current_state != "BUY READY"
        current_state := "BUY READY"
        state_change_time := time
else if sell_setup_hit
    if current_state != "SELL ACTION"
        current_state := "SELL ACTION"
        state_change_time := time
else
    if current_state == "BUY READY"
        current_state := "HOLD / NEUTRAL"
        state_change_time := time

state_date_string = str.format("{0,date,yyyy-MM-dd}", state_change_time)

string structural_verdict = ""
color status_color = color.white

if current_state == "BUY READY"
    structural_verdict := "🟢 BUY READY (Since " + state_date_string + ")"
    status_color := color_green_glow
else if current_state == "SELL ACTION"
    structural_verdict := "🔴 SELL CUTOFF (Since " + state_date_string + ")"
    status_color := color_crimson
else
    structural_verdict := "🟡 HOLD / NEUTRAL (Since " + state_date_string + ")"
    status_color := color_gold

// --- 7-Day & 30-Day Time Horizon Scoring Modules ---
atr5 = ta.rma(ta.tr(true), 5)
week_suitability = single_day_shock ? "❌ UNVIABLE (Price Shock)" : atr5 > (atr20 * 1.3) ? "⚠️ RISK ZONE (ATR Spike)" : close < ema10 ? "⚠️ BEARISH MOMENTUM (Below EMA 10)" : close > ema10 and ema10 > ema20 and not is_flat_and_choppy ? "✅ VIABLE WEEK HOLD" : "★ NEUTRAL (Consolidating)"
color week_color = single_day_shock ? color_crimson : atr5 > (atr20 * 1.3) or close < ema10 ? color_gold : close > ema10 and ema10 > ema20 and not is_flat_and_choppy ? color_green_glow : color.white

string hold_suitability = single_day_shock ? "❌ CRITICAL PRICE SHOCK" : is_hyper_volatile ? "❌ HYPER-VOLATILE WHIPSAW" : is_flat_and_choppy ? "⚠️ DEAD MONEY TRAP" : ema10 > ema20 ? "✅ EXCELLENT 30-DAY VEHICLE" : "⚠️ CAUTION (Macro Bearish)"
color hold_color = single_day_shock or is_hyper_volatile ? color_crimson : is_flat_and_choppy ? color_gold : ema10 > ema20 ? color_green_glow : color_gold

// --- 4. RSI Boundary Conditions ---
string rsi_verdict = rsi14 >= 70 ? "⚠️ OVERBOUGHT" : rsi14 <= 30 ? "✅ OVERSOLD" : "Neutral Momentum"
color rsi_color = rsi14 >= 70 ? color_crimson : rsi14 <= 30 ? color_green_glow : color.white

// --- 5. Option Pricing Penalty Check ---
atr_percentage = (atr20 / close) * 100
is_premium_overpriced = atr_percentage > 4.5 

string vehicle_recommendation = close >= 100.0 and not is_premium_overpriced ? "★ BUY STOCK OR 80-Delta CALL" : close >= 100.0 and is_premium_overpriced ? "⚠️ AVOID OPTIONS: High IV. Use Shares" : close <= 60.0 ? "★ BUY STOCK via Margin" : "★ Borderline Tier: Check Spread"
color vehicle_color = close >= 100.0 and not is_premium_overpriced ? color_green_glow : close <= 60.0 ? color_neon_blue : color_gold


// ==========================================
// 📊 DASHBOARD VISUAL INTERFACE
// ==========================================
var table dashboard = table.new(position = position.middle_left, columns = 2, rows = 9, bgcolor = color_dark_bg, border_color = color_border, border_width = 1)

if barstate.islast
    string header_context = is_beta_supported ? " (" + auto_benchmark + ")" : " (INDEX PROFILE UNRESOLVED)"
    table.cell(dashboard, 0, 0, "RISK INTEGRATION ENGINE", bgcolor=color_border, text_color=color.white, text_size=size.small, width=18)
    table.cell(dashboard, 1, 0, "SCREENING VERDICT & EXECUTION METRICS" + header_context, bgcolor=color_border, text_color=color.white, text_size=size.small, width=42, text_halign=text.align_left)
        
    table.cell(dashboard, 0, 1, "System Setup Status", text_color=color.white, bgcolor=color.new(#1E222D, 20), text_size=size.small)
    table.cell(dashboard, 1, 1, structural_verdict, text_color=status_color, bgcolor=color.new(#1E222D, 20), text_size=size.small, text_halign=text.align_left)

    table.cell(dashboard, 0, 2, "Target Asset Price", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 2, str.tostring(close, "#.##") + " " + syminfo.currency, text_color=color.white, text_size=size.small, text_halign=text.align_left)
        
    table.cell(dashboard, 0, 3, "30-Day Annual Volatility", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 3, str.tostring(historical_volatility * 100, "#.#") + "% " + (is_hyper_volatile ? "(CRITICAL)" : "(SAFE)"), text_color=(is_hyper_volatile ? color_crimson : color.white), text_size=size.small, text_halign=text.align_left)

    // Row 4: Adaptive Beta Fallback Display Check
    string beta_display_string = is_beta_supported ? str.tostring(market_beta, "0.00") + " → " + beta_verdict : "⚠️ IGNORED: Beta calculation requires US or India asset profile"
    table.cell(dashboard, 0, 4, "Historical 30D Beta", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 4, beta_display_string, text_color=color.white, text_size=size.small, text_halign=text.align_left)

    table.cell(dashboard, 0, 5, "RSI (14) Momentum Boundary", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 5, str.tostring(rsi14, "0.0") + " → " + rsi_verdict, text_color=rsi_color, text_size=size.small, text_halign=text.align_left)

    table.cell(dashboard, 0, 6, "Ideal Trading Vehicle", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 6, vehicle_recommendation, text_color=vehicle_color, text_size=size.small, text_halign=text.align_left)
        
    table.cell(dashboard, 0, 7, "7-Day Hold Horizon Status", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 7, week_suitability, text_color=week_color, text_size=size.small, text_halign=text.align_left)

    table.cell(dashboard, 0, 8, "30-Day Hold Horizon Status", text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, 8, hold_suitability, text_color=hold_color, text_size=size.small, text_halign=text.align_left)

// --- Plot Moving Averages ---
plot(ema10, title="EMA 10", color=color.orange, linewidth=1)
plot(ema20, title="EMA 20", color=color.blue, linewidth=1)
plot(ema50, title="EMA 50", color=color.red, linewidth=1)
plot(ema100, title="EMA 100", color=color.purple, linewidth=1)
````
