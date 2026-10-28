# Supertrend Multi-Filter Toolkit [CLEVER]

- url: https://www.tradingview.com/script/KCnf3Jsc-Supertrend-Multi-Filter-Toolkit-CLEVER/
- type: indicator
- pine_id: PUB;2b4501e46bc04357a531eb6243eedb44
- version: 1.0

## Description

🧠 Overview

“Supertrend Multi-Filter Toolkit” is an advanced trend-following indicator designed to generate more reliable trading signals by combining multiple confirmation layers instead of relying on a single condition. Its main objective is to reduce false signals and market noise by validating trend direction through a structured multi-filter system.

The core structure is built on a dual Supertrend model. The fast Supertrend captures short-term price movements and immediate trend shifts, while the slow Supertrend confirms the overall market direction. When both align, the signal becomes stronger; when they conflict, the signal is considered weak or less reliable.

This system also includes Multi-Timeframe (MTF) analysis, which aligns lower timeframe signals with higher timeframe trends. This helps traders understand the broader market structure and avoid low-quality entries caused by short-term fluctuations.

In addition, the toolkit uses multiple confirmation filters such as EMA trend direction, ATR-based volatility filtering, ADX trend strength measurement, and volume confirmation. Together, these filters act as a validation layer that ensures trades are only considered when market conditions are strong and supportive.

The signal logic is divided into two main categories: trend signals and pullback signals. Trend signals identify major directional changes, while pullback signals capture retracement opportunities within an existing trend, allowing for better entry timing instead of chasing moves.

Visually, the indicator uses colored candles, trend clouds, and labels to clearly represent market structure and signal direction. An alert system is also included to notify users in real-time when valid buy, sell, or pullback conditions occur.

Overall, this is a probability-based trading support system that focuses on confirmation and structure rather than prediction. It is designed to assist decision-making and should be used with proper risk management instead of being treated as a guaranteed signal tool.

🧠 Core Concept (House Rules Based Deep Explanation)

The core concept of the “Supertrend Multi-Filter Toolkit” is to build a structured, rule-based decision system for trend identification instead of relying on a single indicator signal. According to house rules logic, this design follows a multi-confirmation framework, where every trade idea must pass through several independent market filters before being considered valid.

At its foundation, the system uses Supertrend as the primary trend engine, but it does not treat it as a standalone signal generator. Instead, Supertrend is only the “base direction layer.” The fast Supertrend captures immediate price shifts, while the slow Supertrend acts as a structural confirmation layer. This separation ensures that signals are not generated on weak or isolated movements.

A key house-rule principle in this system is “no single-point dependency.” That means no trade is allowed based on just one indicator condition. Every signal must be validated through additional layers like trend strength, volatility, volume, and higher timeframe alignment. This reduces random entries and forces the system to operate only in structured market conditions.

The Multi-Timeframe (MTF) filter is used as a higher-order rule to align lower timeframe decisions with the dominant market structure. This is important because, under house rules logic, lower timeframe signals without higher timeframe confirmation are considered low-quality and more prone to false triggers.

Another core concept is market quality filtering. EMA defines trend bias, ATR defines whether the market is stable or too noisy, ADX confirms whether a real trend exists or not, and volume confirms participation. If any of these conditions fail, the system treats the setup as incomplete and avoids generating a valid signal.

The system also applies a cooldown mechanism, which is a structural rule to prevent overtrading. Even if conditions repeat quickly, the system restricts signal frequency. This aligns with disciplined trading logic where quality is preferred over quantity.

Finally, pullback logic adds a second layer of opportunity detection inside an existing trend. Instead of chasing breakout candles, the system waits for retracement + rejection confirmation, which is considered a safer entry structure under house rules logic.

⚠️ Final House Rule Interpretation

This toolkit follows a confirmation-first, noise-filtered trading architecture. It does not predict the market; it filters it. The core idea is simple:
👉 Only trade when multiple independent conditions agree, otherwise stay out.

🔑 Key Features 

⚡ Dual Supertrend Engine (Fast + Slow Structure Layer)

The system is built on a dual Supertrend structure where the fast Supertrend reacts quickly to price changes and the slow Supertrend confirms the broader trend direction. From a house rules perspective, this prevents single-indicator dependency and ensures that signals are only considered valid when both layers agree. If they do not align, the setup is treated as weak or unreliable.

🌍 Multi-Timeframe Confirmation (Market Context Filter)

The MTF feature aligns lower timeframe signals with higher timeframe market structure. This acts as a context filter, ensuring that short-term entries are not taken against the dominant trend. According to safe trading logic, this reduces noise and helps avoid low-quality or counter-trend signals.

🔍 Multi-Factor Filter System (Quality Control Layer)

This toolkit uses multiple independent filters to validate every signal:

EMA Filter: Defines directional trend bias
ATR Filter: Measures market volatility and stability
ADX Filter: Confirms whether a real trend exists
Volume Filter: Checks market participation strength

Under house rules logic, these filters act as a “validation gate,” meaning a signal is only considered valid when market conditions support it from multiple angles.

🚀 Signal Engine (Rule-Based Entry Logic)

Buy and sell signals are generated only when a Supertrend direction change occurs AND multiple filters confirm the move. This makes the system a multi-step confirmation model, not a single-trigger indicator. It ensures that signals are based on structured agreement rather than random price movements.

🔁 Pullback Detection (Trend Continuation Logic)

The pullback feature identifies retracement opportunities within an existing trend. Instead of chasing breakouts, the system waits for price pullbacks with rejection confirmation. This creates safer, trend-aligned entry opportunities and improves timing quality.

🧠 Cooldown Mechanism (Anti-Overtrading Control)

A cooldown system prevents repetitive signals during the same market phase. This ensures that the indicator does not over-trigger in choppy or volatile conditions. From a house rules perspective, this enforces discipline and reduces signal spam.

🎨 Visual Structure (Market Clarity Layer)

Candles, clouds, and labels are used to visually represent market structure and trend direction. This is purely for readability and does not influence signal logic. It helps traders quickly understand whether the market is bullish, bearish, or in transition.

🔔 Alert System (Event-Based Notification Layer)

Alerts are triggered only when full confirmation conditions are met. This is an event-driven system that notifies validated setups rather than predicting outcomes.

⚠️ Final House Rules Interpretation

This is a multi-layer confirmation-based system that filters market conditions instead of predicting them. The core principle is:
👉 Only take trades when multiple independent conditions align (trend, strength, volatility, and structure).

⚙️ How It Works 

🧠 Step 1: Market Structure Reading (Supertrend Base Layer)

The system first reads the market using two Supertrend lines: fast and slow. The fast Supertrend reacts to short-term price movement, while the slow Supertrend defines the overall directional bias. According to house rules logic, this step alone does not create a trade signal—it only defines initial market direction context.

🌍 Step 2: Higher Timeframe Confirmation (MTF Filter)

After the base direction is identified, the system checks the higher timeframe trend using MTF analysis. This ensures that lower timeframe movements are aligned with the broader market structure. If higher timeframe direction disagrees, the system reduces or blocks signal validity. This prevents counter-trend bias and improves structural alignment.

🔍 Step 3: Market Condition Validation (Filter Layer)

Before any signal is allowed, the system runs multiple independent checks:

EMA confirms trend direction
ATR checks if market is stable or too volatile
ADX verifies whether a real trend exists
Volume confirms participation strength

House rules logic treats this stage as a quality control gate. If any condition fails, the system does not allow a trade signal to proceed.

🚀 Step 4: Signal Formation (Decision Layer)

Only when Supertrend direction change AND all filters agree, a buy or sell signal is generated. This is not a single-indicator trigger. It is a multi-confirmation event where multiple conditions must align at the same time. This reduces random entries and forces structured decision-making.

🔁 Step 5: Pullback Detection (Continuation Logic)

After a trend is established, the system also watches for pullbacks. Instead of entering at random breakouts, it waits for retracements with rejection confirmation. This step allows entries during controlled pullbacks inside an existing trend, improving timing and reducing chasing behavior.

⏳ Step 6: Cooldown Control (Anti-Spam Logic)

Once a signal is generated, a cooldown period activates. This prevents repeated signals in the same market phase. Even if conditions reappear quickly, the system waits before allowing another signal. House rules consider this an anti-overtrading protection layer.

🎨 Step 7: Visual + Alert Output (User Interface Layer)

Finally, the system displays signals through labels, colors, and trend clouds. Alerts are triggered only when full confirmation is complete. This ensures the user only receives validated, structured signals, not incomplete or noisy triggers.

⚠️ Final House Rules Working Principle

The entire system works on one core rule:

👉 “No trade is valid unless multiple independent confirmations agree.”

It does not predict the market. It filters the market.
Each step acts like a checkpoint, and only fully confirmed setups are allowed to become signals.

🧭 How to Use It 

🧠 Step 1: Understand the System First (No Blind Trading)

Before using signals, you must understand that this indicator is not a prediction tool. It is a filter-based decision system. House rules logic requires that you treat every signal as “conditional,” not guaranteed. If market conditions are weak, no trade is better than forcing an entry.

📊 Step 2: Trade Only When Full Signal Appears

A valid trade setup is only considered when:

Supertrend direction changes
MTF trend agrees with direction
EMA / ATR / ADX / Volume filters align (based on mode)

If even one major confirmation is missing, the signal should be ignored. This is the core house rules principle: multi-confirmation or no trade.

🚀 Step 3: Follow Trend Signals First (Main Priority)

Trend signals (BUY / SELL) are the primary entries. These occur when the system detects a full directional shift with confirmations. These are higher confidence setups compared to pullbacks. House rules logic says:
👉 Always prioritize trend-confirmed signals over weak or partial setups.

🔁 Step 4: Use Pullbacks for Better Entries (Not Early Entries)

Pullback signals are not for early guessing. They are for entering after trend is already confirmed. When price retraces into the trend and shows rejection, that is your controlled entry opportunity. This helps avoid chasing tops or bottoms.

⏳ Step 5: Respect Cooldown (Do Not Overtrade)

After each signal, a cooldown period activates. During this time, even if another signal appears, you should ignore it. This is a built-in discipline rule to prevent overtrading. House rules logic strongly supports this:
👉 Fewer trades, higher quality.

🧠 Step 6: Use Market Context (Trend Environment Matters)

This system works best in trending markets. If the market is sideways or choppy, signals may become less reliable even with filters. Always check structure first:

Strong trend → follow signals
Range market → avoid aggressive entries
🎯 Step 7: Risk Management is Mandatory

No signal should be used without proper stop-loss and position sizing. House rules clearly treat this system as a decision assistant, not a risk-free strategy. Every trade must be controlled with risk limits.

⚠️ Final House Rules Usage Principle

👉 “Do not trade every signal — trade only fully confirmed market conditions.”

Best usage flow is:
Structure → Confirmation → Signal → Pullback (optional) → Risk-managed execution

This ensures the system is used in a disciplined, rule-based way instead of emotional or random trading.

⚙️ Settings & Customization

🧠 1. Trading Mode (Aggressive / Balanced / Conservative)

This is the core behavior controller of the entire system.

Aggressive Mode: Fewer filters active, faster signals, higher noise risk
Balanced Mode: Default structure, best mix of confirmation + speed
Conservative Mode: Maximum filters, fewer but higher-quality signals

House Rules Interpretation:
👉 This setting controls “signal strictness level.”
More strict = fewer trades but higher confirmation quality.

🎯 2. Supertrend Settings (Fast & Slow Control)

You can adjust ATR length and factor for both Supertrends.

Fast Supertrend = sensitivity to short-term movement
Slow Supertrend = stability and trend confirmation

House Rules Logic:
👉 Lower settings = more reactive but noisy
👉 Higher settings = smoother but delayed signals

Best practice is to keep fast reactive and slow stable for balance.

🌍 3. Multi-Timeframe (MTF) Setting

MTF timeframe selection defines higher timeframe structure.

Lower MTF (15m / 30m) = more responsive but less strict
Higher MTF (1H / 4H) = stronger trend confirmation

House Rules Meaning:
👉 Higher timeframe = stronger filter, fewer false signals
👉 Lower timeframe = more frequent but weaker validation

🔍 4. Confirmation Filters (EMA / ATR / ADX / Volume)

Each filter can be turned ON/OFF depending on strategy style:

EMA Filter: Trend direction confirmation
ATR Filter: Volatility control (avoid unstable markets)
ADX Filter: Trend strength confirmation
Volume Filter: Participation confirmation

House Rules Logic:
👉 Each filter is an independent “approval layer”
More filters ON = stricter system, fewer trades
Fewer filters ON = faster but riskier signals

🎨 5. Visual Settings (Cloud, Labels, Candles)

These settings control only display behavior, not logic:

Candles coloring → trend visualization
Cloud → market bias visualization
Labels → signal clarity

House Rules Note:
👉 Visuals do NOT affect trading logic
They only help interpret structure faster.

⏳ 6. Cooldown Settings (Built-in Discipline Control)

Cooldown defines how often signals can appear.

Low cooldown = frequent signals, risk of overtrading
High cooldown = fewer signals, more stability

House Rules Meaning:
👉 This is an “anti-spam trading protection layer”
It forces patience and avoids repetitive entries.

🧠 7. Pullback Sensitivity (Entry Optimization Layer)

Pullback logic controls retracement-based entries inside a trend.

Tight settings = fewer pullbacks, stricter entries
Loose settings = more pullback signals, higher activity

House Rules Interpretation:
👉 Pullbacks are secondary entries, not primary signals
They should only be used after trend confirmation.

⚠️ Final House Rules Customization Principle

👉 “Customization should never remove confirmation layers blindly.”

Best safe configuration logic:

Keep at least one trend filter (MTF or EMA) ON
Keep volatility or ADX filter for structure safety
Use Aggressive only if you understand noise risk
Use Conservative for clean, filtered signals
🧩 Final Summary

Settings are not just preferences—they are risk-control layers.
Every toggle changes system behavior between:

👉 Speed vs Safety
👉 Frequency vs Quality
👉 Noise vs Structure

The best use is not maximum signals, but maximum confirmation with controlled flexibility.

🧠 Logic Mashup (How Everything Works Together)

⚙️ 1. Core Idea: “Layered Decision System”

This indicator is not built on one signal. It is a multi-layer logic mashup system where each module has a specific job:

👉 Supertrend = direction
👉 MTF = context
👉 Filters (EMA/ATR/ADX/Volume) = validation
👉 Cooldown = discipline control
👉 Pullback = entry refinement

House rules principle:
👉 “No single component is enough — all layers together create final decision.”

🔄 2. Step-by-Step Logic Flow (How System Works Together)

The system runs in a pipeline structure:

🟢 Step 1: Trend Detection (Supertrend Layer)

Fast Supertrend detects immediate direction changes.
Slow Supertrend confirms whether trend is stable.

👉 If fast changes but slow disagrees → signal weak
👉 If both agree → trend bias established

🌍 Step 2: Market Context (MTF Layer)

After trend is detected, higher timeframe is checked.

👉 If HTF agrees → signal allowed to continue
👉 If HTF disagrees → signal is filtered or weakened

This ensures system is not trading against big trend structure.

🔍 Step 3: Quality Filters (Validation Layer)

Now system checks:

EMA → Is price above/below trend structure?
ATR → Is market stable or too volatile?
ADX → Is there real trend strength?
Volume → Is move supported by participation?

👉 All filters act like “approval gates”

House rules logic:
👉 “Signal cannot pass unless market conditions support it.”

🚀 Step 4: Signal Generation (Final Decision Layer)

Only when:

✔ Supertrend direction change
✔ MTF alignment
✔ Filters confirm conditions

👉 Then BUY or SELL signal is created

This is not random — it is a full confirmation stack.

🔁 Step 5: Pullback Logic (Secondary Entry Layer)

After trend is active:

👉 Price retraces
👉 Shows rejection
👉 Still inside trend zone

Then system gives PB BUY / PB SELL

House rules meaning:
👉 “Do not chase breakout — wait for controlled retracement.”

⏳ Step 6: Cooldown Logic (Anti-Overtrade Layer)

After a signal:

👉 System locks new signals for some bars

This prevents:

Signal spam
Emotional overtrading
Choppy market confusion

House rules principle:
👉 “Less signals, more quality.”

🧠 3. How Everything Works Together (Mashup Concept)

Now the important part:

This system is working like a decision machine with stacked filters:

Market Data
   ↓
Supertrend (direction)
   ↓
MTF (context validation)
   ↓
EMA + ATR + ADX + Volume (quality check)
   ↓
Cooldown (discipline check)
   ↓
Final Signal Output

👉 Each layer depends on the previous one
👉 If any layer fails → signal is blocked or ignored

⚠️ 4. House Rules Safe Interpretation

This is NOT:

❌ Single indicator strategy
❌ Predictive system
❌ Guaranteed signal system

This IS:

✔ Confirmation-based decision framework
✔ Multi-filter risk reduction model
✔ Structure + strength + context aligned system

🧩 Final Core Truth

👉 “All components work together like a filter chain — only strongest, fully confirmed market conditions are allowed to become a signal.”

This is the real logic mashup:
Structure → Context → Strength → Validation → Controlled Entry

🧩 Final Note 

This system should be understood as a multi-layer confirmation framework, not a prediction tool. Its logic is built to combine trend detection, market context, strength validation, and risk-control rules into one structured decision process.

Every part of the indicator has a specific role:

Supertrend defines direction
MTF confirms higher-timeframe structure
EMA/ATR/ADX/Volume filters validate market quality
Pullback logic refines entry timing
Cooldown controls overtrading behavior

Under house rules logic, a signal is only meaningful when all required layers agree at the same time. If even one major condition fails, the setup is considered incomplete and should be ignored.

The main principle of this toolkit is simple:
👉 Trade only when market structure, trend strength, and confirmation filters align together.

It is designed for disciplined, structured decision-making—not for guessing market direction or expecting guaranteed outcomes.

⚠️ Disclaimer 

This indicator and all related logic are provided for educational and informational purposes only. It is a technical analysis tool designed to help understand market structure, trend behavior, and probability-based signal conditions.

It does not guarantee profits, accuracy, or future market performance. All trading decisions made using this tool are the sole responsibility of the user.

Markets are inherently risky and can behave unpredictably. Even strong-looking signals may fail due to sudden volatility, news events, liquidity changes, or broader market conditions.

This system is built on a multi-filter confirmation model, meaning signals are based on calculated conditions, not certainty. Therefore, no signal should be treated as financial advice or a guaranteed entry/exit point.

Users are strongly advised to:

Use proper risk management at all times
Avoid over-leveraging or emotional trading
Test strategies in demo environments before live use
Combine this tool with personal analysis and judgment

Under “house rules safe” logic, this indicator is a decision-support system, not a financial advisory service or automated profit tool.

👉 Final principle: No system removes risk — it only structures decision-making.

## Source Code

````pine
//@version=5
indicator("Supertrend Multi-Filter Toolkit [CLEVER]", overlay=true, precision=2, max_labels_count=100)

// ==========================================
// PRO SETTINGS & INPUTS
// ==========================================

// --- Trading Presets ---
grp_preset = "Trading Mode"
trade_mode = input.string("Balanced", "Strategy Preset", options=["Aggressive", "Balanced", "Conservative"], group=grp_preset, tooltip="Aggressive: Faster signals with fewer filters. \nBalanced: Standard filtering. \nConservative: More filters applied, stricter conditions.")

// --- Colors ---
grp_color = "Global Theme Colors"
color_bull_inp = input.color(#00fbff20, "Bullish Color", group=grp_color)
color_bear_inp = input.color(#fb00ff20, "Bearish Color", group=grp_color)

// --- Supertrend 1 (Fast) ---
grp_st1 = "Fast Supertrend Settings"
st1_length = input.int(10, "ATR Length", minval=1, group=grp_st1)
st1_factor = input.float(3.0, "Factor", step=0.1, group=grp_st1)

// --- Supertrend 2 (Slow) ---
grp_st2 = "Slow Supertrend Settings"
st2_length = input.int(20, "ATR Length", minval=1, group=grp_st2)
st2_factor = input.float(5.0, "Factor", step=0.1, group=grp_st2)

// --- MTF Settings ---
grp_mtf = "Multi-Timeframe Analysis"
use_mtf = input.bool(true, "Enable MTF Trend Filter", group=grp_mtf)
mtf_tf  = input.timeframe("60", "MTF Timeframe", group=grp_mtf)
show_mtf_line = input.bool(true, "Show MTF Line on Chart", group=grp_mtf)

// --- Trend Confirmation Filters ---
grp_filter = "Trend Confirmation Filters"
use_ema_filter = input.bool(false, "EMA 200 Filter (Trend)", group=grp_filter)
ema_len        = input.int(200, "EMA Length", group=grp_filter)
use_volat_filter = input.bool(false, "Volatility Filter (ATR)", group=grp_filter)
atr_len        = input.int(14, "ATR Length", group=grp_filter)
use_adx_filter = input.bool(false, "Trend Strength Filter (ADX)", group=grp_filter)
adx_len        = input.int(14, "ADX Length", group=grp_filter)
use_vol_filter = input.bool(false, "Volume Spike Confirmation", group=grp_filter)
vol_ma_len     = input.int(20, "Volume MA Length", group=grp_filter)

// --- Visual Settings ---
grp_ui = "Visuals"
show_labels = input.bool(true, "Show Buy/Sell Labels", group=grp_ui)
show_pullbacks = input.bool(true, "Show Pullback/Continuation Signals", group=grp_ui)
show_cloud  = input.bool(true, "Show Trend Cloud", group=grp_ui)
cloud_transp = input.int(85, "Cloud Transparency (0-100)", minval=0, maxval=100, group=grp_ui)
show_bars   = input.bool(true, "Colorize Candles", group=grp_ui)

// ==========================================
// 🛠️ DYNAMIC PRESET TUNING
// ==========================================

// Threshold Tuning based on Trade Mode
float adx_threshold_dyn  = trade_mode == "Aggressive" ? 15.0 : (trade_mode == "Conservative" ? 35.0 : 25.0)
float rvol_threshold_dyn = trade_mode == "Aggressive" ? 0.8  : (trade_mode == "Conservative" ? 2.0  : 1.5)
int   trend_cooldown     = trade_mode == "Aggressive" ? 3    : (trade_mode == "Conservative" ? 15   : 8)
int   pb_cooldown        = trade_mode == "Aggressive" ? 5    : (trade_mode == "Conservative" ? 20   : 12)

// ==========================================
// 🛠️ CORE LOGIC FUNCTIONS
// ==========================================

f_supertrend(_len, _factor) =>
    [st_line, st_dir] = ta.supertrend(_factor, _len)
    [st_line, st_dir]

// --- Calculations ---
[st1_line, st1_dir] = f_supertrend(st1_length, st1_factor)
[st2_line, st2_dir] = f_supertrend(st2_length, st2_factor)

// MTF Calculation (Non-Repainting - Using Slow ST for stability)
[mtf_line, mtf_dir] = request.security(syminfo.tickerid, mtf_tf, f_supertrend(st2_length, st2_factor), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Filter Logic
ema_filter = ta.ema(close, ema_len)
vol_ma = ta.sma(volume, vol_ma_len)
rvol = volume / vol_ma
atr_val = ta.atr(atr_len)
atr_ma = ta.sma(atr_val, 20)
[plus_di, minus_di, adx_val] = ta.dmi(adx_len, adx_len)
is_adx_rising = adx_val > adx_val[1]

// Preset-based Logic Application
bool filter_mtf   = trade_mode == "Aggressive" ? false : use_mtf
bool filter_ema   = trade_mode == "Aggressive" ? false : use_ema_filter
bool filter_vol   = trade_mode == "Aggressive" ? false : (trade_mode == "Conservative" ? true : use_vol_filter)
bool filter_volat = trade_mode == "Conservative" ? true  : (trade_mode == "Balanced" ? use_volat_filter : false)
bool filter_adx   = trade_mode == "Conservative" ? true  : (trade_mode == "Balanced" ? use_adx_filter : false)

is_bullish_mtf = not filter_mtf or mtf_dir < 0
is_bearish_mtf = not filter_mtf or mtf_dir > 0
is_bullish_ema = not filter_ema or close > ema_filter
is_bearish_ema = not filter_ema or close < ema_filter
is_volume_ok   = not filter_vol or rvol > rvol_threshold_dyn
is_volat_ok    = not filter_volat or atr_val > atr_ma
is_adx_ok      = not filter_adx or (adx_val > adx_threshold_dyn and is_adx_rising)

// --- Signal Logic (Refined for no overlap) ---
trend_changed_bull = ta.crossunder(st1_dir, 0)
trend_changed_bear = ta.crossover(st1_dir, 0)

// --- Separate Cooldown System ---
var int last_trend_bar = 0
var int last_pb_bar = 0
can_trend_signal = (bar_index - last_trend_bar) > trend_cooldown
can_pb_signal    = (bar_index - last_pb_bar) > pb_cooldown

// --- Combined Signal Confirmation ---
buy_signal  = trend_changed_bull and is_bullish_mtf and is_bullish_ema and is_volume_ok and is_volat_ok and is_adx_ok and can_trend_signal
sell_signal = trend_changed_bear and is_bearish_mtf and is_bearish_ema and is_volume_ok and is_volat_ok and is_adx_ok and can_trend_signal

// --- Pullback / Continuation Logic (Refined with Rejection Confirmation) ---
is_bullish_rej = close > open and (close - low) > (high - low) * 0.5
is_bearish_rej = close < open and (high - close) > (high - low) * 0.5

pb_buy  = not trend_changed_bull and st1_dir < 0 and low < st1_line and close > st1_line and is_bullish_rej and is_bullish_mtf and is_bullish_ema and is_volume_ok and is_volat_ok and is_adx_ok and can_pb_signal
pb_sell = not trend_changed_bear and st1_dir > 0 and high > st1_line and close < st1_line and is_bearish_rej and is_bearish_mtf and is_bearish_ema and is_volume_ok and is_volat_ok and is_adx_ok and can_pb_signal

// Update Separate Cooldown Trackers
if buy_signal or sell_signal
    last_trend_bar := bar_index
if pb_buy or pb_sell
    last_pb_bar := bar_index

// Strong Signals
strong_buy  = buy_signal and st2_dir < 0
strong_sell = sell_signal and st2_dir > 0

// ==========================================
// 📈 VISUAL RENDERERS
// ==========================================

color_bull = color_bull_inp
color_bear = color_bear_inp

// Bar Colors
barcolor(show_bars ? (st1_dir < 0 ? color_bull : color_bear) : na, title="Bar Color", editable=false)

// Plot Supertrends
plot(st1_line, "Fast ST", color = st1_dir < 0 ? color_bull : color_bear, linewidth=2)
plot(st2_line, "Slow ST", color = st2_dir < 0 ? color.new(color_bull, 50) : color.new(color_bear, 50), linewidth=1, style=plot.style_linebr)

// Plot MTF Supertrend
plot(show_mtf_line ? mtf_line : na, "MTF Supertrend Line", color = mtf_dir < 0 ? color.new(color_bull, 30) : color.new(color_bear, 30), linewidth=3, style=plot.style_stepline)

// Cloud Fill
p1 = plot(st1_line, "Cloud Ref 1", display=display.none, editable=false)
p2 = plot(close, "Cloud Ref 2", display=display.none, editable=false)
fill(p1, p2, st1_dir < 0 ? color.new(color_bull, cloud_transp) : color.new(color_bear, cloud_transp), "Trend Cloud", title="Cloud Fill")

// Signal Labels
if show_labels
    if strong_buy
        label.new(bar_index, low, "BUY", color=color.new(color_bull, 20), textcolor=color.white, style=label.style_label_up, size=size.small)
    else if buy_signal
        label.new(bar_index, low, "BUY", color=color.new(color_bull, 40), textcolor=color.white, style=label.style_label_up, size=size.small)
        
    if strong_sell
        label.new(bar_index, high, "SELL", color=color.new(color_bear, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
    else if sell_signal
        label.new(bar_index, high, "SELL", color=color.new(color_bear, 40), textcolor=color.white, style=label.style_label_down, size=size.small)

// Pullback Labels
if show_pullbacks
    if pb_buy
        label.new(bar_index, low, "PB BUY", color=color.new(color_bull, 60), textcolor=color.white, style=label.style_label_up, size=size.tiny)
    if pb_sell
        label.new(bar_index, high, "PB SELL", color=color.new(color_bear, 60), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ==========================================
// 🔔 ALERTS
// ==========================================

alertcondition(buy_signal, "Buy Signal", "Buy signal based on Supertrend conditions")
alertcondition(sell_signal, "Sell Signal", "Sell signal based on Supertrend conditions")
alertcondition(strong_buy, "Strong Buy", "Strong buy signal based on filter conditions")
alertcondition(strong_sell, "Strong Sell", "Strong sell signal based on filter conditions")
alertcondition(pb_buy, "Pullback Buy", "Pullback buy condition detected")
alertcondition(pb_sell, "Pullback Sell", "Pullback sell condition detected")
````
