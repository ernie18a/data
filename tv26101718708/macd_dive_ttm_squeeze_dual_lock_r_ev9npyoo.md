# MACD Dive [TTM Squeeze | Dual Lock %R]

- url: https://www.tradingview.com/script/ev9NPyoo-MACD-Dive-TTM-Squeeze-Dual-Lock-R/
- type: indicator
- pine_id: PUB;a6194de42dcc4b21b1a19c2d421db51b
- version: 2.0

## Description

[b]Disclaimer[/b]: This indicator is not financial advice and is strictly for educational and informational purposes only. The metrics and signals provided herein (including momentum crosses, trend saturation state icons, and squeeze markers) are calculated based on historical market data and do not guarantee future performance. Trading stocks and commodities involves significant risk of loss. The user assumes full responsibility for all trading decisions and should always perform their own due diligence before executing trades.

MACD Dive is a multi-state momentum and volatility context engine. By layering momentum oscillation (MACD/PPO/MACD-V) with market stalemates (volatility squeeze) and trend exhaustion (Dual %R saturation), this suite transforms a standard MACD into a multi-dimensional 'No-Go' gatekeeper. This synergy is what gives the engine its edge: it actively blocks the trader from whipsawing in sideways chop or buying into a dying trend, highlighting high-probability market turns where momentum, volatility, and trend capacity perfectly align.

Standard oscillators have a scaling problem. This script lets you choose your engine:[list=1]
[*]MACD (Classic): Measures momentum in absolute dollars. Great for visual reactivity, but a "2.0" reading means something different on a $5 stock versus a $500 stock.
[*]PPO (Percentage): Measures momentum in percentages. Standardizes the reading across all assets, making it ideal for fixed-rule algorithmic trading.
[*]MACD-V (Volatility Normalized): This divides the MACD by the Average True Range (ATR). It measures momentum in "Units of Volatility," mathematically adapting to market chaos so that signals remain consistent across both different assets and shifting volatility regimes (quiet markets vs chaotic markets).
[/list]This suite includes a fully optimized divergence detection engine:[list=1]
[*]Regular Divergence (Solid Lines): Identifies Trend Reversals. Price pushes to a new extreme, but momentum fails to follow, signaling exhaustion.
[*]Hidden Divergence (Dashed Lines): Identifies Trend Continuations (Slingshots). Price pulls back, but momentum fully resets, signaling a high-probability entry in the direction of the dominant trend.
[/list]Located in your chosen corner, the HUD provides an instant visual readout with [i]hover tooltips[/i] for active Engine Mode, %R Fatigue state, Oscillator crossover validation, and Squeeze environment. Vertical background highlights in green or red represent filter-passed momentum crossovers, like the MACD bullish cross. Use the extensive inline tooltips in the indicator's settings panel for a comprehensive breakdown of every tunable parameter.

[b]Adaptive Time-Frames & RSI Gatekeeper[/b]
Think of this as an automated gear shifter. When looking at lower timeframes (below a user-defined boundary, e.g. 1 hour), the engine automatically scales down to tight, agile lookback periods. When viewing high timeframes, it dials up to filter out noise.

Buying a bullish MACD cross when the RSI is already at 85 increases risk of buying the top when the tank is empty. The [i]optional[/i] RSI Safety Filter acts as a strict ceiling/floor blocker. If momentum crosses upward but the asset is mathematically overbought, the indicator suppresses the background highlight. It prevents signals on MACD crosses that have no fuel left.

[b]VOLATILITY ENGINE: BB-KC Squeeze Radar[/b]
Building on John Carter’s TTM Squeeze by mapping the contraction of Bollinger Bands inside Keltner Channels to identify market stalemates. The implementation here color codes between a Loose Squeeze (BB inside 1.5 KC) and a hyper-compressed Tight Squeeze (BB inside 1.0 KC) to show the staged intensity of the coiled spring.

While the market coils sideways, a 20-period Linear Regression calculates the trajectory of price deviation inside the bands. The directional bias is shown by customizable markers on the zero line (default ⌃ or ⌄). This reveals hidden institutional accumulation or distribution before the trigger is pulled. To bypass "dead money" risk, the script tracks the first clean candle [i]close[/i] or [i]intraday pierce[/i] outside the Keltner bounds following a squeeze, catching the expansion phase exactly as it starts. 

Furthermore, it accounts for the "Disappearing Mark" phenomenon. Bollinger Bands expand instantly when price moves, causing standard squeeze signals to vanish 1-3 bars before the real breakout candle. This script uses a memory state to remember recent compression, firing a "squeeze release" marker (default ❖) the exact moment price closes outside the Keltner bounds. Trade the release, not the waiting room.

[i]Note: While MACD Dive tracks this compression mathematically on its zero-line, you can see the actual physical boundaries of the breakout by pairing it with my companion [url=https://www.tradingview.com/script/WjmfyDYC-Swing-Data-ATR-Ext-RVol-ADR-Ticker-Sector-RS/]Swing Data suite[/url]. Plotting its Keltner Channel at 1.5 multiplier over your price chart allows you to visually verify the exact moment the squeeze release mark is ignited.[/i]

[b]SATURATION ENGINE: Dual-Lock %R and Momentum Rot[/b]
This suite tracks sustained trend maturity using a fast/slow dual Williams %R setup. The conceptual pairing of a fast and slow %R to identify overbought/oversold exhaustion is credited to upslidedown's excellent [url=https://www.tradingview.com/script/8r6oARMe-R-Trend-Exhaustion-upslidedown/]Trend Exhaustion indicator[/url]. I highly recommend applying their script to your chart if you want to visually learn how the two %R lines interact.

While upslidedown’s implementation offers multiple display modes to paint visual boxes and exhaustion zones directly over price action, the focus here is on the discrete icons for trend status at the top and bottom of the MACD pane: Ignition (·), Saturation (□), and Fatigue (×). This suite adapts native ta.wpr() math assuming the trader is already familiar with Dual %R mechanics. Specific "Sprint" and "Marathon" tuning guidance is provided in the tooltips: heavily smoothing the fast line to ignore intraday noise, while lightly smoothing the macro slow line to preserve its reach into extreme zones.

It also features one major addition: the Stall. While Dual %R tracks [i]Price Location[/i] (confirming price is structurally pinned at the highs), it doesn't track [i]Velocity[/i] (confirming energy is sustained). To solve this, a Stoch RSI "Rot" detector runs quietly inside the saturation state. If price continues to float at the highs but internal velocity drops below a critical threshold, the script [i]overlays[/i] a Stall marker (•). Designed as a "one-shot" early warning, it fires only on the first detection per trend saturation leg to prevent chart clutter. This differentiates a strong trend lock from a rotting lock, warning us that the move is running on fumes: giving us the exact cue to tighten stops, trim into parabolic strength, and strictly avoid adding new size.

[b]BACKTESTER READY[/b]
Out-of-the-box compatibility with a comprehensive built-in README guide is available directly inside the settings menu. For traders who prefer a "Diamond Hands" approach, the indicator fully maps to [url=https://www.tradingview.com/script/n8bgynWl-Template-Trailing-Strategy-Backtester/]Jason5480's TTS Framework[/url] convention, outputting strict integer states (1, -1, 2, -2) to hold full position size until the trailing macro baseline completely fractures. My personal backtester, Cosmos Signal Commander (which may be released to the public in the future), broadcasts a composite float signal capable of managing active trade positioning. It tracks entries, hard stops, and partial take-profits (swapping the trailing stop from tight to a wide "runner" buffer upon hitting extended ATR targets). 

[b]PERFORMANCE OPTIMIZATION[/b][list=1]
[*]O(1) Memory States: Replaced lag-heavy ta.barssince() and 50-bar for loops in the Divergence engine with O(1) var state trackers.
[*]String Caching: HUD table strings are built once in the global var scope to prevent constant memory allocation and garbage collection lag.
[*]UI Mutation: The HUD uses table.cell_set_* to alter data dynamically, bypassing the stutter caused by destroying and redrawing tables on every tick.
[*]Native C++ Backend: Replaced custom highest/lowest math arrays with native ta.wpr() functions for the %R engine to maximize computation speed.
[*]Ghost State Resets: When switching the backtester logic to "Long Only" mode, the engine actively hunts and kills lingering short-memory variables so they don't inadvertently suppress valid long signals.
[/list]

## Source Code

````pine
// ©GoldenCosmos, TradingView handle for 项嘉祺
//@version=6
indicator(title="MACD Dive", overlay=false)
//
// ==========================================
// ─── 1. OSCILLATOR ENGINE ───
// ==========================================
// [ARCHITECTURAL NOTE]
// This section handles the "Dualzone" auto-switching logic.
// We detect the timeframe using 'timeframe.multiplier'. 
// The 'Boundary' input allows the user to define what counts as "Low Timeframe" (Scalp) vs "High Timeframe" (Swing).

grp_eng = "1. Time-Frame Controls"

// TOOLTIPS: STRATEGY
tt_dual = "Timeframe Adaptive Mode:\n" + 
     "• ON (Smart): Solves the 'Lag vs. Noise' problem. It uses faster settings on lower timeframes to catch quick scalps, " + 
     "and slower settings on higher timeframes to filter noise for swing trades.\n" + 
     "   - Below Boundary: Activates 'LTF' settings (Fast/Scalp).\n" + 
     "   - Above Boundary: Activates 'HTF' settings (Standard/Swing).\n" + 
     "• OFF (Manual): Forces the HTF 'Swing' settings on all time-frames. Use this if you want the classic time-frame behavior."

tt_bnd = "HTF/LTF Boundary:\n" + 
     "Defines the exact timeframe where the strategy shifts gears.\n" + 
     "• Example: Set to '1 Hour'.\n" + 
     "   - 5m, 15m, 30m charts will use the Fast LTF settings.\n" + 
     "   - 1H, 4H, Daily charts will use the Standard HTF settings."

tt_type = "Engine (MACD vs PPO vs MACD-V):\n" + 
     "• MACD (Moving Average Convergence Divergence): The classic. Measures momentum in absolute Dollars ($). " + 
     "Levels vary wildly by asset price (e.g., 20.0 is huge for Apple but tiny for BTC). Hard to automate across different assets.\n" + 
     "• PPO (Percentage Price Oscillator): The modern standard. Measures momentum in Percent (%). " + 
     "A 1.0% move is consistent across all assets. Best for fixed-rule trading.\n" + 
     "• MACD-V (Volatility Normalized): The institutional upgrade by Alex Spiroglou. Divides MACD by the Average True Range (ATR) of the Slow Length. " + 
     "Measures momentum in 'Units of Volatility'. A 1.0 reading means momentum shifted exactly 1 ATR."

tt_ma = "Oscillator Smoothing :\n" + 
     "• EMA (Exponential): The default. Prioritizes recent price action. " + 
     "Better for catching the start of a trend, but prone to whipsaws in chop.\n" + 
     "• SMA (Simple): Equal weighting. Slower and smoother. " + 
     "Use this if you find the indicator is too 'twitchy' or reactive."

tt_sig = "Signal Smoothing (Trigger):\n" + 
     "• EMA (Standard): Reacts immediately to momentum shifts. Good for aggressive entries.\n" + 
     "• SMA (Pro Tip): A 'Smoother' trigger. It filters out small, insignificant crosses. " + 
     "The Trade-off: You enter slightly later, but you get stopped out far less often."

use_dual = input.bool(true, "Enable Adaptive Time-Frames", group=grp_eng, tooltip=tt_dual)
tf_bound = input.string("1 Hour", "Boundary (HTF Start)", options=["15 Minutes", "30 Minutes", "1 Hour", "2 Hours", "4 Hours"], group=grp_eng, tooltip=tt_bnd)
osc_type = input.string("MACD-V", "Oscillator Type", options=["MACD", "PPO", "MACD-V"], group=grp_eng, tooltip=tt_type)
ma_type  = input.string("EMA", "Oscillator MA Type", options=["EMA", "SMA"], group=grp_eng, tooltip=tt_ma)
sig_type = input.string("SMA", "Signal Line MA Type", options=["EMA", "SMA"], group=grp_eng, tooltip=tt_sig)

// HTF Settings (Standard Swing)
fast_htf = input.int(12, "HTF Fast" , group=grp_eng, inline="htfline")
slow_htf = input.int(26, "| Slow"   , group=grp_eng, inline="htfline")
sig_htf  = input.int(9,  "| Signal" , group=grp_eng, inline="htfline")

// LTF Settings (Scalping)
fast_ltf = input.int(8,  "LTF Fast" , group=grp_eng, inline="ltfline")
slow_ltf = input.int(21, "| Slow"   , group=grp_eng, inline="ltfline")
sig_ltf  = input.int(5,  "| Signal" , group=grp_eng, inline="ltfline")

// LOGIC: Convert Dropdown String to Minutes
var int bound_min = switch tf_bound
    "15 Minutes" => 15
    "30 Minutes" => 30
    "1 Hour"     => 60
    "2 Hours"    => 120
    "4 Hours"    => 240
    => 60 // Default fallback

// LOGIC: Determine Timeframe and Swap Variables
// We check if current chart is intraday AND if the multiplier (minutes) is LESS than our boundary
var int current_min = timeframe.isintraday ? timeframe.multiplier : 1440 // Treat Daily+ as 1440 min
var bool is_ltf     = current_min < bound_min
var int fast_len    = use_dual and is_ltf ? fast_ltf : fast_htf
var int slow_len    = use_dual and is_ltf ? slow_ltf : slow_htf
var int sig_len     = use_dual and is_ltf ? sig_ltf  : sig_htf

// HELPER: Function to switch between SMA/EMA cleanly
get_ma(src, len, type) =>
    type == "SMA" ? ta.sma(src, len) : ta.ema(src, len)

// ==========================================
// ─── 2. RSI FILTERS (THE GATEKEEPER) ───
// ==========================================
// [ARCHITECTURAL NOTE]
// This section acts as a "No-Go" gatekeeper for oscillator entries.
// It relies strictly on RSI to prevent taking Long signals into Overbought 
// conditions, or Short signals into Oversold conditions.

grp_rsi  = "2. RSI Safety Filters"

// TOOLTIPS: RSI LEVELS
tt_rsi = "RSI Validation (The 'No-Go' Filter):\n" + 
     "This filter decides whether to paint the Background Highlight or suppress it.\n" + 
     "• Mechanism: If the RSI condition is NOT met, the 'Bull/Bear Highlight' (Green/Red vertical strip) is BLOCKED even if the Oscillator lines cross.\n" + 
     "• Why?: It prevents the indicator from flagging a buy signal when price is already Overbought (No fuel left)."
tt_rsi_len = "RSI Lookback Length:\n" + 
     "• 14 (Standard): The universal default. Balanced.\n" + 
     "• Lower (e.g. 7): Faster. Makes the filter very sensitive to short-term spikes.\n" + 
     "• Higher (e.g. 21): Slower. Better for filtering out noise in longer trends."

tt_rsi_bull = "Bullish Filter (Max RSI Ceiling):\n" + 
     "• Logic: Prevents long signals when the tank is empty (Overbought).\n" +
     "• Setting to 80 (Aggressive): Allows signal of Bull Cross even when RSI is hot (70+). Essential for catching 'Parabolic' breakouts that stay overbought for weeks.\n" + 
     "• If RSI is ABOVE this level (e.g. 80), signals for Bull Cross are suppressed.\n" + 
     "• Setting to 50 (Conservative): Strictly for 'Dip Buying'. Blocks signals for Bull Cross on any breakout that is already in motion."

tt_rsi_bear = "Bearish Filter (Min RSI Floor):\n" + 
     "• Logic: Prevents short signals when the tank is full (Oversold).\n" +
     "• Setting to 20 (Aggressive): Allows signal of Bear Cross even when RSI is cold (30-). Essential for catching strong capitulation flushes.\n" + 
     "• If RSI is BELOW this level (e.g. 20), signals for Bear Cross are suppressed.\n" + 
     "• Setting to 50 (Conservative): Blocks signals for Bear Cross on crashing stocks if the asset is already falling off the cliff."

// RSI Customization
use_rsi_flt = input.bool(true, "Apply RSI Limits", group=grp_rsi, inline="rsi_limit")
rsi_len     = input.int(14, "| RSI Length", minval=2, group=grp_rsi, tooltip=tt_rsi, inline="rsi_limit")
rsi_bull_lv = input.int(80, "RSI Max for Bull", minval=1, maxval=99, group=grp_rsi, tooltip=tt_rsi_bull)
rsi_bear_lv = input.int(20, "RSI Min for Bear", minval=1, maxval=99, group=grp_rsi, tooltip=tt_rsi_bear)

// CALCULATION: Main Oscillator
src = close
fast_ma = get_ma(src, fast_len, ma_type)
slow_ma = get_ma(src, slow_len, ma_type)

macd_val = fast_ma - slow_ma
ppo_val = ((fast_ma - slow_ma) / slow_ma) * 100
float _atr = ta.atr(slow_len)
macdv_val = _atr == 0 ? 0 : (macd_val / _atr) // Volatility Normalized by Slow Length ATR

osc = osc_type == "PPO" ? ppo_val : (osc_type == "MACD-V" ? macdv_val : macd_val)
signal = get_ma(osc, sig_len, sig_type)
hist = osc - signal

// CALCULATION: RSI
rsi_val = ta.rsi(close, rsi_len)

// ==========================================
// ─── 3. BB-KC SQUEEZE RADAR ───
// ==========================================
// [ARCHITECTURAL NOTE]
// BB-KC Radar detects "Volatility Compression" (The TTM Squeeze Logic) originally designed by John Carter.
//
// [THEORY: THE COILED SPRING]
// Imagine a heavy metal spring. When you press down on it, it doesn't move, but it packs
// immense potential energy. It *wants* to explode.
// • The Squeeze: The market is "Pressing the Spring." Price goes dead quiet, volatility vanishes.
// • The Release: The moment the pressure lifts, price snaps violently (The Expansion).
//
// [CRITICAL THEORY: THE "TRENDING SQUEEZE" PROBLEM]
// NOT ALL SQUEEZES ARE EQUAL. Context is King.
// • The "Good" Squeeze (Consolidation): Occurs when price moves SIDEWAYS after a trend. 
//   The moving averages flatten, volume dies, and energy builds for a new leg. This has predictive power.
// • The "Bad" Squeeze (Trending): Occurs when price grinds slowly upward in a low-volatility channel.
//   The math sees "Low Volatility" and prints dots, but there is no "stored energy"—the energy is already 
//   being spent on the trend. These dots often appear right before the trend ROLLS OVER (exhaustion).
//
// [MECHANICS: THE DETECTION ENGINE]
// We use two "Measuring Sticks" to detect this compressed state:
// 1. Bollinger Bands (The Elastic Balloon) expand/contract dynamically as price deviate from the mean.
//    • Behavior: Hyper-reactive Standard Deviation. They blow up in chaos and deflate quietly tight in quiet.
// 2. Keltner Channels (The Rigid Pipe) remain relatively stable based on average candle size.
//    • Behavior: Steady and boring Average True Range. They define the baseline for "Normalcy."
//
// THE SIGNAL LOGIC (MULTI-STATE UPGRADE):
// • TIGHT SQUEEZE: BB shrinks inside the TIGHT KC (1.0). Extreme compression. Explosive move imminent.
// • LOOSE SQUEEZE: BB shrinks inside the LOOSE KC (1.5). Standard compression. Watch for setup.
// • IGNITION: The exact bar where BB expands OUT of the KC. The "Trigger Pull."
// • NO SQUEEZE (Black): Volatility is normal.
//
// [PSYCHOLOGY: WHY IT WORKS]
// 1. Stalemate: Buyers/Sellers fight to a draw. Price flattens.
// 2. Compression: Traders get bored/nervous and tighten their Stop Losses ($1 up I buy, $1 down I sell).
// 3. Chain Reaction: News hit -> Price move $1 into Stops -> Stops become Market Orders -> BOOM.
// Squeeze did not create the energy; it identifies stalemate conditions that hint at energy coalescence.
//
// [STRATEGIC GUIDANCE: TIMING THE BREAKOUT]
// • THE DISAPPEARING MARK: Squeeze marks often vanish 1-3 bars BEFORE the massive breakout candle. 
//   Why? As price begins to poke out, the Bollinger Bands expand immediately. The moment BB expands
//   wider than the KC, the marks stop. 
//   RULE: Don't wait for the marks to persist; their disappearance IS the signal that expansion has started.
//
// • DO NOT ENTER ON THE SQUEEZE MARKS ALONE. The Squeeze tells you *something* big is coming, but not *which direction*.
// • The "Dead Money" Risk: Squeezes can last 3 days or 3 weeks. Entering early ties up capital.
// • The "Fake-Out" Risk: Price often head-fakes inside the squeeze before the real move.
// • ACTION: Use Squeeze as "Get Ready" (Gun is Loaded). Enter on the Breakout/Momentum (Trigger Pulled).
//
// [CHEAT CODES: ANTICIPATING DIRECTION]
// While the Squeeze is technically neutral, these "Internal Clues" hint at the winner:
// 
// A. VOLUME CLUES (The Truth):
//    • Power Pivots: A high RVol buying burst *inside* the range (Intent to Accumulate).
//    • Absorption Hammers: High Volume rejection of the lows (Limit Orders defending the floor).
//    • Ghost Rejection: A "Shooting Star" (ugly wick) on LOW RVol. (Failed selling test/No supply).
//
// B. MOMENTUM CLUES (The Engine):
//    • Weak Bear Oscillator: Histogram is shrinking towards zero (Pink) while price is flat. Sellers are tired.
//    • MA Surfing: Price is riding *above* the rising 20 SMA inside the squeeze. Support is rising.
//
// C. STRUCTURAL CLUES (The Geometry):
//    • Relative Strength: Market (SPY) dumps, but this stock stays green/flat. (Institutions holding).
//    • Higher Lows: Sellers cannot push price back to the bottom band (Ascending pressure).
//    • VCP Geometry: Volatility contracts sequentially (e.g. dips go 10% -> 5% -> 2%).
// 
// D. PLOT LOOSE KELTNER CHANNELS FOR STRONG CONFIRMATION
//    By definition from geometry, a "Squeeze" only exists when the Bollinger Bands (BB) are INSIDE the Keltner Channels (KC).
//    KC represents the "Lid" on volatility, so price must have moved further than average bar size to cross the KC.
//    This confirms the energy release has enough inertia to leave the containment zone from a buyer-seller stalemate.
//    Align Loose KC bounds at length 20 multiplier 1.5 using SMA on ATR length 20.
//
//    Remember that the Inner Line during squeeze is Bollinger Band; Outer Line during squeeze is Keltner Channel.
//    Price will frequently wiggle during market noise against the BB during a squeeze because it's the inner line.

grp_sqz = "3. Bollinger-Keltner Squeeze"

// TOOLTIP: SQUEEZE THEORY & TUNING
// We use a multi-line format to explain the "Spring" analogy and how to tune the sensitivity.
// TOOLTIP: SQUEEZE CONCEPT
tt_sqz_concept = "BB-KC Squeeze (Marks on the Zero Line):\n" +  
     "Originally designed by John Carter, named TTM Squeeze. Bollinger Bands (elastic balloon) based on standard deviation, inflate in chaos and " + 
     "deflate when quiet. Keltner Channel (rigid pipe) based on ATR, remains relatively stable based on average candle size. When BB squeeze inside KC, " + 
     "buyers and sellers reach stalemate as stop orders build up at the edge - creating conditions for an explosive move. Longer stalemate = bigger boom.\n\n" + 
     "CONTEXT: Good squeeze in SIDEWAYS consolidation (e.g. VCP). Price is flat, volume is low. Bad squeeze in a TREND, often exhaustion. Avoid these.\n\n" +
     "TIMING THE TRIGGER (THE DISAPPEARING DOT): Dots could vanish 1-3 bars BEFORE price crosses Keltner bounds. Why? Because Bollinger expands instantly when price moves. " +
     "Disappearance of tight/loose marks IS the signal. Watch for Release Mark when price closed outside the loose Keltner Channel.\n\n" + 
     "LEGEND:\n" + 
     "• Loose Squeeze: Normal compression (BB inside 1.5 KC). Begin monitoring.\n" + 
     "• Tight Squeeze: Extreme compression (BB inside 1.0 KC). The coiling stalemate has reached extreme levels.\n" + 
     "• Release Mark: Trigger when Price breaks Keltner Channel after a recent squeeze. Strong confirmation of energy release.\n" + 
     "• Normal Conditions Dot (Default Transparent): Normal volatility."

// TOOLTIP: KELTNER CHANNELS (The Pipe)
tt_sqz_kc = "KC Multiplier (The Rigid Pipe):\n" + 
     "Sets the baseline for 'The Pipe' squeezing the Bollinger balloon.\n" + 
     "• 1.5 (Standard, default for Loose Level): Good balance for detecting compression of volatility.\n" + 
     "• 1.0 (Narrow, default for Tight Level): Makes the channel narrower to reduce frequency of BB-KC Squeeze.\n" + 
     "• 2.0 (Wide): Makes the channel wider to increase frequency of BB-KC Squeeze.\n" + 
     "Adjustment: If you see too many squeeze marks, decrease this value."

// TOOLTIP: BOLLINGER BANDS (The Energy)
tt_sqz_bb = "BB Multiplier (The Elastic Balloon):\n" + 
     "Sets the sensitivity of the volatility bands.\n" + 
     "• 2.0 (Standard): The universal default.\n" + 
     "Adjustment: If you NEVER see squeeze dots, decrease this value to 1.9 or 1.8."

// TOOLTIP: MEMORY
tt_sqz_mem = "Memory Duration of Recent BB-KC Squeeze:\n" +
     "Volatility can expand slightly 1-3 bars BEFORE the major price breakout as buyers or sellers start losing the stalemate. " + 
     "This causes Squeeze dots to disappear early because Bollinger Bands is hyper-sensitive to price movement.\n" +
     "This setting remembers if we were squeezing recently.\n\n" +
     "• Logic: IF (Squeeze was Active in last X bars) AND (Price breaks KC) THEN (add Squeeze Release marks on Zero Line).\n" +
     "• Default 8 Bars: Allows for a reasonable pause between ending of BB-KC squeeze and the price moving beyond KC."

sqz_show    = input.bool(true, "Display Zero Line Dots for BB-KC Squeeze", group=grp_sqz, tooltip=tt_sqz_concept)

// Sensitivity Inputs
sqz_bb_mult = input.float(2.0, "Bollinger: Sensitivity", step=0.1, group=grp_sqz, tooltip=tt_sqz_bb)
sqz_kc_loose = input.float(1.5, "Keltner: Loose Limit", step=0.1, group=grp_sqz, tooltip=tt_sqz_kc)
sqz_kc_tight = input.float(1.0, "Keltner: Tight Limit", step=0.1, group=grp_sqz, tooltip=tt_sqz_kc)
sqz_mem_len  = input.int(8, "Squeeze Memory (Bars)", minval=1, group=grp_sqz, tooltip=tt_sqz_mem)
sqz_trig_src = input.string("Closed outside Keltner", "Trigger of Squeeze Release", options=["Closed outside Keltner", "Intraday Pierced Keltner"], group=grp_sqz, 
     tooltip="Determines what counts as a Squeeze Release.\n"+
             "• Closed outside Keltner: Price closed outside Keltner Channel is a safer confirmation of Squeeze Release.\n" + 
             "• Intraday Pierced Keltner: Price intraday pierced the Keltner Channel is a riskier confirmation of Squeeze Release.")

// Visual Inputs
// TOOLTIP: DIRECTIONAL BIAS MECHANICS
tt_sqz_up = "Zero-line marker when compression of BB-KC Squeeze has rising momentum (Bullish Bias):\n" + 
     "The 20-period Linear Regression of price deviation is sloping upward.\n\n" +
     "• The Math: A 'line of best fit' is plotted against the distance between closing prices and the structural midline.\n" +
     "• The Translation: Even if price is dead flat, buyers are systematically absorbing supply at incrementally higher prices inside the squeeze. Stored energy is tilting Long."

tt_sqz_dn = "Zero-line marker when compression of BB-KC Squeeze has falling momentum (Bearish Bias):\n" + 
     "The 20-period Linear Regression of price deviation is sloping downward.\n\n" +
     "• The Math: The 'line of best fit' of price deviation is negative.\n" +
     "• The Translation: Sellers are systematically hitting the bid at incrementally lower prices inside the squeeze. Stored energy is tilting Short."

sqz_col_none  = input.color(color.new(#000000, 100), "No Squeeze", group=grp_sqz, inline="SQC1", tooltip="Color when Volatility is HIGH (Safe Zone). Default is transparent.")
sqz_col_loose = input.color(color.new(#f3ff09, 0), "Loose Squeeze", group=grp_sqz, inline="SQC1", tooltip="Color when Volatility is LOW (Danger Zone). Market is coiling.")
sqz_col_tight = input.color(color.new(#ffffff, 0), "Tight Squeeze", group=grp_sqz, inline="SQC2", tooltip="Color when Volatility is SUPER LOW (Extreme Zone). Market is coiled.")
sqz_col_fire  = input.color(color.new(#ffffff, 15), "Squeeze Release", group=grp_sqz, inline="SQC2", tooltip="Color when price has escaped BB-KC Squeeze.")
sqz_char_up   = input.string("⌃", "Squeeze Mark (Rising)", options=["▴", "▲", "▵", "△", "↑", "⇡", "⇑", "⌃", "∧"], 
          group=grp_sqz, tooltip=tt_sqz_up)
sqz_char_dn   = input.string("⌄", "Squeeze Mark (Falling)", options=["▾", "▼", "▿", "▽", "↓", "⇣", "⇓", "⌄", "∨"], 
          group=grp_sqz, tooltip=tt_sqz_dn)
sqz_char_fire = input.string("❖", "Release Mark", options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "✦", "✧", "◆", "❖", "★", "⛧", "🛡️", "⚓", "🚀", "⚡"], 
          group=grp_sqz, tooltip="Zero-line marker for release confirmation from a recent BB-KC Squeeze.")

// Squeeze Calculation (Multi-State)
sqz_len = 20

// 1. Bollinger Bands & Baseline
// ta.bb inherently calculates the SMA as its middle band. Reusing it bypasses a redundant moving average loop.
[bb_mid, bb_u, bb_l] = ta.bb(close, sqz_len, sqz_bb_mult)

// 2. Keltner Channels (The Pipes)
float kc_ma    = bb_mid
float kc_range = ta.atr(sqz_len)

// Loose Channel (default KC 1.5)
float kc_u_loose = kc_ma + kc_range * sqz_kc_loose
float kc_l_loose = kc_ma - kc_range * sqz_kc_loose

// Tight Channel (default KC 1.0)
float kc_u_tight = kc_ma + kc_range * sqz_kc_tight
float kc_l_tight = kc_ma - kc_range * sqz_kc_tight

// 3. Determine Squeeze States
// Tight: BB is inside the 1.0 KC
bool is_sqz_tight = (bb_u < kc_u_tight) and (bb_l > kc_l_tight)

// Loose: BB is inside the 1.5 KC (but NOT the 1.0 KC, to avoid double counting)
bool is_sqz_loose_raw = (bb_u < kc_u_loose) and (bb_l > kc_l_loose)
bool is_sqz_loose = is_sqz_loose_raw and not is_sqz_tight

// Momentum Bias Engine (The Directional Tell)
// We calculate the Linear Regression of price deviation to find the squeeze trajectory inside the pipe.
// Calculates the line of best fit over sqz_len periods for distance between price and Donchian/SMA baseline.
float donchian_mid = (ta.highest(high, sqz_len) + ta.lowest(low, sqz_len)) * 0.5
float sqz_mom = ta.linreg(close - ((donchian_mid + kc_ma) * 0.5), sqz_len, 0)

// Momentum Direction: Is the slope rising or falling compared to the previous bar?
bool is_mom_rising = sqz_mom > nz(sqz_mom[1])

// 4. Ignition Logic (The Intelligent Release)
// Requirement 1: Was there a squeeze recently? (Memory)
// We check if 'is_sqz_loose_raw' (which includes tight) was true within X bars.
// Replaced O(N) ta.barssince() array lookup with an O(1) active state tracker.
var int last_loose_bar = na
if is_sqz_loose_raw
    last_loose_bar := bar_index
bool was_sqz_recent = not na(last_loose_bar) and (bar_index - last_loose_bar) <= sqz_mem_len

// Requirement 2: Did Price Break Out of the KC 1.5?
// Caches the string evaluation once on init to prevent continuous string parsing lag.
var bool use_close_trig = sqz_trig_src == "Closed outside Keltner"

float trig_u = use_close_trig ? close : high
float trig_l = use_close_trig ? close : low

bool is_breakout_u = trig_u > kc_u_loose
bool is_breakout_l = trig_l < kc_l_loose
bool is_breakout   = is_breakout_u or is_breakout_l

// Requirement 3: Fire Ignition
// Only fire if we have a recent squeeze AND a breakout AND it's the *first* breakout of the sequence.
// (Prevents firing every single bar of a run).
bool is_ignition = was_sqz_recent and is_breakout and not is_breakout[1]

// 5. Determine Final Color and Plots
// Standard Dot Color (Tight, Loose, or None)
color col_dot = switch
    is_sqz_tight => sqz_col_tight
    is_sqz_loose => sqz_col_loose
    => sqz_col_none

// ==========================================
// ─── 4. OSCILLATOR DIVERGENCE ───
// ==========================================
// [ARCHITECTURAL NOTE]
// We split the 'Show' and 'Text' inputs so the user can control Regular (Reversal) 
// and Hidden (Continuation) divergences independently.

grp_div = "4. Oscillator Divergence Bars"

tt_div_show = "Divergence Strategy:\n" + 
     "• Regular (Solid Line): The 'Reversal' Signal. Price makes a new high/low, but Momentum is tired.\n" + 
     "• Hidden (Dashed Line): The 'Continuation' Signal. Price pulls back, but Momentum resets quickly. " + 
     "This is often called a 'Slingshot' trade."

tt_piv = "Pivot Lookback (Lag vs. Reliability): default 5 left 5 right.\n" + 
     "• How it works: We must wait 'X' bars after a High/Low to confirm it was actually a pivot.\n" + 
     "• Daily/4H Charts: Set to 5. We want to confirm major structural turns.\n" + 
     "• 5m/1m Charts: Prefer 2 or 3. Waiting 5 bars on a 1m chart may be too slow but expect more unreliability."

tt_lbl_r = "Regular Divergence (Trend Reversal):\n" + 
     "• The Logic: 'Running on Fumes'.\n" + 
     "• Bullish: Price drops to a Lower Low, but Oscillator makes a Higher Low. Sellers are exhausted.\n" + 
     "• Bearish: Price pushes to a Higher High, but Oscillator makes a Lower High. Buyers are exhausted."

tt_lbl_h = "Hidden Divergence (Trend Continuation):\n" + 
     "• The Logic: 'The Slingshot'.\n" + 
     "• Bullish: Price pulls back to a Higher Low, but Oscillator drops to a Lower Low. " + 
     "Momentum has fully reset while price held up. Strong buy signal.\n" + 
     "• Bearish: Price bounces to a Lower High, but Oscillator spikes to a Higher High. " + 
     "Price is weak despite the momentum spike. Strong sell signal."

// INPUTS FOR DIVERGENCE
use_div  = input.bool(true, "Enable Divergence Detection", group=grp_div, tooltip="PERFORMANCE TOGGLE:\nDisabling this prevents the script from calculating pivots and generating Drawing Objects. Highly recommended to turn OFF for maximum chart speed if you do not actively trade divergence.")
show_reg = input.bool(true, "plot Regular |", group=grp_div, inline="SHOW")
show_hid = input.bool(true, "plot Hidden", group=grp_div, inline="SHOW", tooltip=tt_div_show)

lbL = input.int(5, "Pivot Left", group=grp_div, inline="pivotline")
lbR = input.int(5, "| Pivot Right", group=grp_div, inline="pivotline", tooltip=tt_piv)

div_txt_r = input.string("R", "Label for Regular", group=grp_div, tooltip=tt_lbl_r)
div_txt_h = input.string("H", "Label for Hidden", group=grp_div, tooltip=tt_lbl_h)
div_wid   = input.int(2, "Width of Divergence Line", minval=1, maxval=5, group=grp_div)

col_div_bull = input.color(color.rgb(160, 255, 199), "Bullish Divergence", inline="div_color", group=grp_div)
col_div_bear = input.color(color.rgb(255, 125, 125), "Bearish Divergence", inline="div_color", group=grp_div)
col_div_txt  = input.color(color.rgb(0, 0, 0), "Label Text Color", group=grp_div)

// ==========================================
// ─── 5. OSCILLATOR VISUALS ───
// ==========================================
grp_vis = "5. Visual Styling of Oscillator"
tt_imp  = "Impulse Coloring:\n• Strong (Darker): Momentum increasing.\n• Weak (Lighter): Momentum fading."

col_h_s_bull = input.color(color.rgb(0, 166, 30), "Histogram: Strong Bull", group=grp_vis, inline="HB")
col_h_w_bull = input.color(color.rgb(255, 126, 126), "| Weak Bull",   group=grp_vis, inline="HB", tooltip=tt_imp)
col_h_s_bear = input.color(color.rgb(255, 126, 126), "Histogram: Strong Bear", group=grp_vis, inline="HBr")
col_h_w_bear = input.color(color.rgb(0, 166, 30), "| Weak Bear",   group=grp_vis, inline="HBr", tooltip=tt_imp)

col_mac  = input.color(color.rgb(255, 159, 90), "Fast Line: Color",    group=grp_vis, inline = "fast_line" )
wid_mac  = input.int(1, "| Width",   minval=1, maxval=5, group=grp_vis, inline = "fast_line" )

col_sig  = input.color(color.rgb(103, 156, 255), "Signal Line: Color", group=grp_vis, inline = "signal_line" )
wid_sig  = input.int(1, "| Width", minval=1, maxval=5, group=grp_vis, inline = "signal_line" )

col_bg_bull = input.color(color.new(#80ff84, 80), "Background: Bull Cross", group=grp_vis, inline="BG")
col_bg_bear = input.color(color.new(#ff6f6f, 80), "| Bear Cross", group=grp_vis, inline="BG")

// OSCILLATOR SIGNAL VALIDATION (The Master Switch)
// [ARCHITECTURAL NOTE]
// This section determines if the Background Highlight fires.
// The 'valid_bull_rsi' variable acts as a gatekeeper.
// IF (use_rsi_flt is ON) AND (RSI is > Max Level) -> valid_bull_rsi becomes FALSE.
// This forces 'bull_cross' to FALSE, preventing the 'bgcolor' command from executing.

valid_bull_rsi = use_rsi_flt ? rsi_val < rsi_bull_lv : true
valid_bear_rsi = use_rsi_flt ? rsi_val > rsi_bear_lv : true

// The Final Condition for Bull/Bear Crosses:
bool raw_bull = ta.crossover(osc, signal)
bool raw_bear = ta.crossunder(osc, signal)

bull_cross = raw_bull and valid_bull_rsi
bear_cross = raw_bear and valid_bear_rsi

// PLOT Background Highlights
// These strictly depend on the 'bull_cross' / 'bear_cross' booleans calculated above.
bgcolor(bull_cross ? col_bg_bull : na, title="Bull Highlight")
bgcolor(bear_cross ? col_bg_bear : na, title="Bear Highlight")

// PLOT Main Lines
is_rising = hist > hist[1]
hist_col = hist >= 0 ? (is_rising ? col_h_s_bull : col_h_w_bull) : (is_rising ? col_h_w_bear : col_h_s_bear)

plot(hist, title="Histogram", style=plot.style_columns, color=hist_col)
plot(osc, title="Oscillator", color=col_mac, linewidth=wid_mac)
plot(signal, title="Signal", color=col_sig, linewidth=wid_sig)

// PLOT: Rising Momentum (Accumulation Bias)
plotchar(sqz_show and not is_ignition and is_mom_rising ? 0 : na, title="Squeeze (Rising Bias)", char=sqz_char_up, color=col_dot, 
         location=location.absolute, size=size.tiny, display=display.all - display.status_line)

// PLOT: Falling Momentum (Distribution Bias)
plotchar(sqz_show and not is_ignition and not is_mom_rising ? 0 : na, title="Squeeze (Falling Bias)", char=sqz_char_dn, color=col_dot, 
         location=location.absolute, size=size.tiny, display=display.all - display.status_line)

// PLOT Release from BB-KC Squeeze
plotchar(sqz_show and is_ignition ? 0 : na, title="Squeeze Release", char=sqz_char_fire, color=sqz_col_fire, 
         location=location.absolute, size=size.tiny, display=display.all - display.status_line)


// ─── DIVERGENCE ENGINE ───
// [ARCHITECTURAL NOTE]
// This engine detects Regular (Reversal) and Hidden (Continuation) divergence.
// OPTIMIZATION: The loop only executes when a new Pivot is confirmed (not every tick).
// 1. Regular Div (Reversal):   Price moves with trend, Momentum fails. (Solid Line)
// 2. Hidden Div  (Slingshot):  Price pulls back, Momentum resets fully. (Dashed Line)

// 1. Identify Pivots
// 'ta.pivotlow' returns a value ONLY on the specific bar where the pivot is confirmed.
// The confirmation happens 'lbR' bars after the actual low.
float pl_raw = na
float ph_raw = na

if use_div
    pl_raw := ta.pivotlow(osc, lbL, lbR)
    ph_raw := ta.pivothigh(osc, lbL, lbR)

// 2. Gatekeeping (Efficiency Check)
bool new_pivot_L = not na(pl_raw)
bool new_pivot_H = not na(ph_raw)

// [OPTIMIZATION]: Replaced the O(N) 50-bar 'for' loop with O(1) 'var' state trackers.
// Instead of forcing the VM to scan history to find the previous pivot, we cache it in active memory.
var float prev_pl_val = na
var int   prev_pl_bar = na
var float prev_ph_val = na
var int   prev_ph_bar = na

// BULLISH DIVERGENCE LOGIC (Oscillator is BELOW Zero)
if new_pivot_L 
    if osc[lbR] < 0 
        if not na(prev_pl_val)
            // Distance indexing bypasses array fetches for structural lows
            int dist = bar_index - prev_pl_bar
            
            // A. REGULAR BULL (Reversal Signal)
            if show_reg and low[lbR] < low[lbR + dist] and pl_raw > prev_pl_val
                line.new(prev_pl_bar - lbR, prev_pl_val, bar_index - lbR, pl_raw, color=col_div_bull, width=div_wid)
                if div_txt_r != ""
                    label.new(bar_index - lbR, pl_raw, div_txt_r, style=label.style_label_up, color=col_div_bull, textcolor=col_div_txt, size=size.tiny)
            
            // B. HIDDEN BULL (Continuation/Slingshot Signal)
            if show_hid and low[lbR] > low[lbR + dist] and pl_raw < prev_pl_val
                line.new(prev_pl_bar - lbR, prev_pl_val, bar_index - lbR, pl_raw, color=col_div_bull, width=div_wid, style=line.style_dashed)
                if div_txt_h != ""
                    label.new(bar_index - lbR, pl_raw, div_txt_h, style=label.style_label_up, color=col_div_bull, textcolor=col_div_txt, size=size.tiny)
    
    // Update trackers for the next pivot sequence
    prev_pl_val := pl_raw
    prev_pl_bar := bar_index

// BEARISH DIVERGENCE LOGIC (Oscillator is ABOVE Zero)
if new_pivot_H 
    if osc[lbR] > 0
        if not na(prev_ph_val)
            // Distance indexing bypasses array fetches for structural highs
            int dist = bar_index - prev_ph_bar
            
            // A. REGULAR BEAR (Reversal Signal)
            if show_reg and high[lbR] > high[lbR + dist] and ph_raw < prev_ph_val
                line.new(prev_ph_bar - lbR, prev_ph_val, bar_index - lbR, ph_raw, color=col_div_bear, width=div_wid)
                if div_txt_r != ""
                    label.new(bar_index - lbR, ph_raw, div_txt_r, style=label.style_label_down, color=col_div_bear, textcolor=col_div_txt, size=size.tiny)
            
            // B. HIDDEN BEAR (Continuation/Slingshot Signal)
            if show_hid and high[lbR] < high[lbR + dist] and ph_raw > prev_ph_val
                line.new(prev_ph_bar - lbR, prev_ph_val, bar_index - lbR, ph_raw, color=col_div_bear, width=div_wid, style=line.style_dashed)
                if div_txt_h != ""
                    label.new(bar_index - lbR, ph_raw, div_txt_h, style=label.style_label_down, color=col_div_bear, textcolor=col_div_txt, size=size.tiny)
    
    // Update trackers for the next pivot sequence
    prev_ph_val := ph_raw
    prev_ph_bar := bar_index

// ==========================================
// ─── 6. DUAL LOCK %R ENGINE ───
// ==========================================
grp_fat = "6. Williams %R: Dual-Lock Fatigue"

// TOOLTIPS
tt_fat_con = "Dual-Lock Williams %R.\n" + 
     "Dual-Lock method compares a Short-Term Sprint against a Long-Term Marathon to signal Sustained Trend Strength and Fatigue (possible reversal).\n\n" +
     "1. IGNITION (Start): Trend has reached sustained strength with both short-term and long-term Williams %R in the saturation zone.\n" +
     "2. SATURATION (Hold): Super-trend is active when BOTH the spring and marathon signals remain in saturation extremes (e.g. Default outer 20%). " + 
     "Not recommended to short a Bull Lock nor long a Bear Lock.\n" + 
     "3. FATIGUE (Exit): Momentum has snapped when one or both of the spring and marathon signals snaps out of the extreme zones. " + 
     "Momentum may be exhausted, so trim or exit positions.\n\n" + 
     "SUGGESTED CONFIGURATIONS for Fast Smooth / Slow Smooth:\n" + 
      "• Weekly: 14 5 / 55 3 (Classic)\n" + 
      "• Daily: 21 7 / 112 3 (Swing Standard)\n" + 
      "• 5m/15m: 8 3 / 34 3 (Fib Scalp)"
tt_fat_smooth = "Smoothing Method (Stability vs. Speed):\n" + 
      "• SMA (Default): High Stability. Best for 'Locking'. Resists unlocking during minor intraday wicks. Recommended for Swing Trading.\n" + 
      "• EMA: High Speed. Reacts to recent price faster. Good for Parabolic blow-off tops, but risks shaking you out early."

tt_fat_sm_fast = "Short-Term Williams %R (The Sprint): " + 
             "Fast length measures short-term buying/selling pressure. This line must 'Lock' with the Slow line to confirm a major move.\n\n" + 
             "VARIANTS on Lookback Length:\n" + 
             "• 21 (Default 21/112): Fibonacci #. Filters noise for high probability Swing Trading high beta.\n" + 
             "• 14 (Classic 14/50): Standard Williams %R (14) and a 50-bar baseline. Faster signals but more noise.\n" + 
             "• 8 (Fib Scalp 8/34): Use for 5m/15m charts. Extremely reactive for 5m/15m charts. Catches quick reversals.\n" + 
             "• 28 (Macro 28/200): 'Black Swan' hunter. Only signals on major market cycle tops/bottoms.\n\n" +
             "Smoothing of Fast Length is SPRINT STABILIZATION\n" + 
             "Fast line is hyper-active, which twitches into outer %R Extremes constantly on minor price spikes. " + 
             "We smooth the Fast Line HEAVILY (Default 7) to prevent false alarms, forcing the fast line to wait for a cluster of strength.\n\n" + 
             "• 3 (Agile / Scalp): The 'Hair Trigger'. Reacts instantly to price changes. Use this for 5m/15m charts (8/34 pairing). \n" + 
             "   [RISK]: High probability of 'Whipsaws' (signal appears, you enter, then signal vanishes).\n\n" + 
             "• 7 (Standard / Swing): The 'Anchor'. It ignores random price spikes and 1-candle wonders. It forces the market to prove it has sustained momentum before the signal Locks.\n" + 
             "   [BENEFIT]: drastically reduces fake-outs.\n\n" + 
             "• 14 (Default / Heavy): The 'Confirmation'. Use this if you find yourself getting stopped out often. You will enter later, but the success rate of the signal increases."

tt_fat_sm_slow = "Long-Term Williams %R (The Marathon): " + 
             "Slow length measures the dominant trend. We only care about signals when this 'Macro' trend is also stretched to the limit.\n\n" + 
             "VARIANTS on Lookback Length:\n" + 
             "• 112 (Default 21/112): Fibonacci #. Filters noise for high probability Swing Trading high beta.\n" + 
             "• 50 (Classic 14/50): Standard Williams %R (14) and a 50-bar baseline. Faster signals but more noise.\n" + 
             "• 34 (Fib Scalp 8/34): Use for 5m/15m charts. Extremely reactive for 5m/15m charts. Catches quick reversals.\n" + 
             "• 200 (Macro 28/200): 'Black Swan' hunter. Only signals on major market cycle tops/bottoms.\n\n" + 
             "Smoothing of Slow Length is MARATHON REACH PRESERVATION\n" + 
             "Slow line is naturally heavy, like turning a cruise ship taking forever to reach outer %R Extremes. " + 
             "We smooth the Slow Line LIGHTLY (Default 3) to preserve its reach, only filtering out glitches or flash crash wicks.\n\n" + 
             "• 3 (Default): 'The Reach'. Allows heavier slow length such as 112 to actually reach the extreme zone without being flattened out by lag.\n" + 
             "• 5 (Dampening): Use for lower slow length that can reach the extreme zones earlier, and filter out 'scam wicks'.\n" + 
             "• 9 (Heavy): Very stable, but reduces the wave amplitude. You may need to widen the Threshold (e.g. to 30) because the line will struggle to reach 20."

tt_fat_thres = "THEORY: THE SATURATION ZONE\n" + 
             "Defines how deep price must go to trigger 'Lock'. HTF default 20. LTF default 25.\n" + 
             "• Outer 15-20 (Standard trades): The best all-rounder. Wide enough for Slow line to actually reach them, but strict enough to filter noise. Recommended for HTF to avoid exiting strong trends too early.\n" + 
             "• Outer 20-30 (Volatile trades): Use for lower timeframes. 'Slow' trends often turn around before hitting the -10/-90 extremes. Recommended for LTF to catch noisy reversals that don't hit perfect extremes.\n" + 
             "• Outer 10 (Black Swan mode): The Slow line will almost NEVER trigger this unless a major crash is happening."

// LOGIC SETTINGS
show_fatigue = input.bool(true, "Display Dual-Lock %R Status", group=grp_fat, tooltip=tt_fat_con)
fat_sm_type  = input.string("SMA", "Smoothing Method for %R", options=["EMA", "SMA", "RMA", "WMA"], group=grp_fat, tooltip=tt_fat_smooth)

// --- HTF SETTINGS (Swing) ---
fat_fast_len_htf = input.int(21,  "HTF Fast Lookback", minval=1, group=grp_fat, inline="HTF1")
fat_sm_fast_htf  = input.int(14,   "Smooth",            minval=1, group=grp_fat, inline="HTF1", tooltip = tt_fat_sm_fast)
fat_slow_len_htf = input.int(112, "HTF Slow Lookback", minval=1, group=grp_fat, inline="HTF2")
fat_sm_slow_htf  = input.int(3,   "Smooth",            minval=1, group=grp_fat, inline="HTF2", tooltip = tt_fat_sm_slow)
fat_thresh_htf   = input.int(20,  "HTF Threshold",     minval=5, maxval=45, group=grp_fat, inline="HTF3", tooltip=tt_fat_thres)

// --- LTF SETTINGS (Scalp) ---
fat_fast_len_ltf = input.int(8,   "LTF Fast Lookback", minval=1, group=grp_fat, inline="LTF1")
fat_sm_fast_ltf  = input.int(3,   "Smooth",            minval=1, group=grp_fat, inline="LTF1", tooltip = tt_fat_sm_fast)
fat_slow_len_ltf = input.int(34,  "LTF Slow Lookback", minval=1, group=grp_fat, inline="LTF2")
fat_sm_slow_ltf  = input.int(3,   "Smooth",            minval=1, group=grp_fat, inline="LTF2", tooltip = tt_fat_sm_slow)

fat_thresh_ltf   = input.int(25,  "LTF Threshold",     minval=5, maxval=45, group=grp_fat, inline="LTF3", tooltip=tt_fat_thres)

// ─── BULLISH VISUALS ───
// 1. IGNITION (Start)
show_ign_bull  = input.bool(true, "Overlay Bull Ignition?", group=grp_fat, inline="B_IGN")
char_ign_bull  = input.string("·", "", 
     options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "▴", "▲", "▼", "✦", "✧", "◆", "❖", "★", "⛧","↑", "↓", "🛡️", "⚓", "🚀", "⚡"], group=grp_fat, inline="B_IGN")
col_ign_bull   = input.color(color.new(#47ffa6, 0), "", group=grp_fat, inline="B_IGN")

// 2. SATURATION (Hold)
show_sat_bull  = input.bool(true, "Show Bull Saturation?", group=grp_fat, inline="B_SAT")
char_sat_bull  = input.string("□", "", 
     options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "▴", "▲", "▼", "✦", "✧", "◆", "❖", "★", "⛧","↑", "↓", "🛡️", "⚓", "🚀", "⚡"], group=grp_fat, inline="B_SAT")
col_sat_bull   = input.color(color.new(#4caf4f, 40), "", group=grp_fat, inline="B_SAT")

// 3. FATIGUE (Exit)
show_fat_bull  = input.bool(true, "Show Bull Fatigue?", group=grp_fat, inline="B_FAT")
char_fat_bull  = input.string("×", "", 
     options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "▴", "▲", "▼", "✦", "✧", "◆", "❖", "★", "⛧","↑", "↓", "🛡️", "⚓", "🚀", "⚡"], group=grp_fat, inline="B_FAT")
col_fat_bull   = input.color(color.new(#4fff30, 0), "", group=grp_fat, inline="B_FAT")

// ─── BEARISH VISUALS ───
// 1. IGNITION (Start)
show_ign_bear  = input.bool(true, "Overlay Bear Ignition?", group=grp_fat, inline="R_IGN")
char_ign_bear  = input.string("·", "", 
     options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "▴", "▲", "▼", "✦", "✧", "◆", "❖", "★", "⛧","↑", "↓", "🛡️", "⚓", "🚀", "⚡"], group=grp_fat, inline="R_IGN")
col_ign_bear   = input.color(color.new(#ff1744, 0), "", group=grp_fat, inline="R_IGN")

// 2. SATURATION (Hold)
show_sat_bear  = input.bool(true, "Show Bear Saturation?", group=grp_fat, inline="R_SAT")
char_sat_bear  = input.string("□", "", 
     options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "▴", "▲", "▼", "✦", "✧", "◆", "❖", "★", "⛧","↑", "↓", "🛡️", "⚓", "🚀", "⚡"], group=grp_fat, inline="R_SAT")
col_sat_bear   = input.color(color.new(#ef5350, 40), "", group=grp_fat, inline="R_SAT")

// 3. FATIGUE (Exit)
show_fat_bear  = input.bool(true, "Show Bear Fatigue?", group=grp_fat, inline="R_FAT")
char_fat_bear  = input.string("×", "", 
     options=["×", "✕", "✖", "·", "•", "●", "○", "⁎", "□", "▢", "▪", "■", "▴", "▲", "▼", "✦", "✧", "◆", "❖", "★", "⛧","↑", "↓", "🛡️", "⚓", "🚀", "⚡"], group=grp_fat, inline="R_FAT")
col_fat_bear   = input.color(color.new(#ff6c5e, 0), "", group=grp_fat, inline="R_FAT")

grp_stall = "Stalling Stoch RSI for %R"

// --- STALL WARNING (Stoch RSI) ---
// Theory: Detects when the "Lock" is rotting from the inside.
// If %R is Locked (Price High) but Stoch RSI drops (Momentum Low), it's a Divergence/Stall.
use_stall     = input.bool(true, "Overlay Stall Icon on %R Saturation", group=grp_stall, 
          tooltip="MOMENTUM ROT DETECTOR through Stoch RSI\n\n" + 
                  "While Dual-Lock %R tracks 'Price Location' (Are prices in extreme zones?), Stoch RSI tracks 'Velocity' (Is energy sustained?).\n" + 
                  "• %R Saturation Icons: Price is structurally locked at the highs.\n" + 
                  "• Stall Icon from RSI Stoch: Internal momentum is fading ('Rotting') even though price is still holding up. " + 
                  "This differentiates a Strong %R Lock from a Rotting %R Lock.\n\n" + 
                  "ACTIONABLE GUIDANCE:\n" + 
                  "1. TIGHTEN STOPS OR TRIM: The 'easy money' has been made. Volatility may expand against you soon.\n" + 
                  "2. NO NEW ADDS: Do not pyramid or add size during a Stall. The price is rising, but the engine is unsupported.\n" + 
                  "3. EXIT STRATEGY: Standard Rule: Wait for the %R Fatigue signal to close the full position. \n" +
                  "   Parabolic Exception: If the move is vertical, the Stall on a closed candle can be your signal to sell into strength, as the subsequent pullback is often severe.\n\n" + 
                  "SUGGESTED CONFIGURATIONS:\n" + 
                  "• 21 14 3 @ 40 (Default): The 'Real World' swing setting. Heavy smoothing (14) and a deep threshold (40) filters out all chart noise, only alerting when momentum is lost.\n" + 
                  "• 14 7 3 @ 20 (Faster): Traditional setting. Good for intraday, but may flicker on minor red candles.\n" + 
                  "• 21 7 3 @ 30 (Intermediate): A middle ground between sensitivity and filtering.")
stoch_len    = input.int(21, "Stoch Length", minval=1, group=grp_stall)
stoch_k      = input.int(14,  "Stoch K Smooth", minval=1, group=grp_stall)
stoch_d      = input.int(3,  "Stoch D Smooth", minval=1, group=grp_stall)
stall_thresh = input.int(40, "Stall Threshold", minval=5, maxval=45, group=grp_stall, 
          tooltip="Outer % Zone (Distance from 0/100).\n" + 
          "• 40 (Default - Deep Rot): The Strict Filter. Warning triggers only if Stoch RSI drops below 60 during Bull trend or rises above 40 during Bear trend. This confirms the 'Engine' is actually broken, not just idling.\n" + 
          "• 30 (Moderate): Warning triggers if Stoch RSI drops below 70 / rises above 30.\n" + 
          "• 20 (Sensitive): Warning triggers if Stoch RSI drops below 80 / rises above 20.")

char_stall   = input.string("•", "Stall Icon", options=["×", "▪", "·", "•", "●", "○", "⁎", "◇", "✦", "✧", "◆", "❖", "★", "⛧", "⚠"], group=grp_stall, inline="STALL")
col_stall    = input.color(color.new(#ffb43b, 10), "Color", group=grp_stall, inline="STALL")

// ==========================================
// ─── DUAL LOCK %R LOGIC & PLOT ───
// ==========================================

// A. CALCULATE DUAL %R (The Rubber Bands)
// Utilizing native C++ backend ta.wpr() instead of custom ta.highest/lowest math arrays.

// Helper: Smoothing Selector
f_smooth(src, len, type) =>
    float res = switch type
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "RMA" => ta.rma(src, len)
        "WMA" => ta.wma(src, len)
        => ta.ema(src, len)
    res

// DYNAMIC SELECTION (Lengths & Thresholds)
// We check 'use_dual' and 'is_ltf' (from Section 1)
c_fast_len = use_dual and is_ltf ? fat_fast_len_ltf : fat_fast_len_htf
c_fast_sm  = use_dual and is_ltf ? fat_sm_fast_ltf  : fat_sm_fast_htf
c_slow_len = use_dual and is_ltf ? fat_slow_len_ltf : fat_slow_len_htf
c_slow_sm  = use_dual and is_ltf ? fat_sm_slow_ltf  : fat_sm_slow_htf
c_thresh   = use_dual and is_ltf ? fat_thresh_ltf   : fat_thresh_htf

// Raw %R Values
float raw_f = ta.wpr(c_fast_len)
float raw_s = ta.wpr(c_slow_len)

// Apply Smoothing
float val_f = c_fast_sm > 1 ? f_smooth(raw_f, c_fast_sm, fat_sm_type) : raw_f
float val_s = c_slow_sm > 1 ? f_smooth(raw_s, c_slow_sm, fat_sm_type) : raw_s

// B. DEFINE ZONES
// Bull Zone: Value is typically -20 to 0 (Top of chart).
// Bear Zone: Value is typically -80 to -100 (Bottom of chart).
// Note: %R is negative. -20 is "Higher" than -80.

float z_top = -c_thresh           // e.g. -20
float z_bot = -100 + c_thresh     // e.g. -80

// CALCULATE STOCH RSI (The Stall Detector)
// We run this on the standard 'close' source to detect momentum shifts relative to price.
rsi_stoch_src = ta.rsi(close, stoch_len)
stoch_val     = ta.stoch(rsi_stoch_src, rsi_stoch_src, rsi_stoch_src, stoch_len)
// Smooth the Stoch (K)
k_val         = ta.sma(stoch_val, stoch_k)
// We don't strictly need D (Signal) for this logic, just the K line (Fast).

// Define Stall Zones
stall_top = 100 - stall_thresh     // 100 - 20 = 80 (Bull Stall Boundary)
stall_bot = stall_thresh           // 20            (Bear Stall Boundary)

// C. DETERMINE STATES
// SATURATION (The Lock)
// Both bands must be INSIDE the extreme zone to trigger saturation.
bool is_sat_bull = (val_f >= z_top) and (val_s >= z_top)      // Both > -20 (Top)
bool is_sat_bear = (val_f <= z_bot) and (val_s <= z_bot)      // Both < -80 (Bottom)

// FATIGUE (The Snap)
// We fire a signal when we WERE saturated yesterday, but NOT today.
bool is_fat_bull = not is_sat_bull and is_sat_bull[1] // Bull trend snapped
bool is_fat_bear = not is_sat_bear and is_sat_bear[1] // Bear trend snapped

// IGNITION (The Start - Trigger)
// Occurs when we are Saturated NOW, but were NOT Saturated yesterday.
bool is_ign_bull = is_sat_bull and not is_sat_bull[1]
bool is_ign_bear = is_sat_bear and not is_sat_bear[1]

// STALL (The Rot - Warning) [UPGRADED ONE-SHOT LOGIC]
// 1. Define State Variables to track if we have already stalled in this trend
var bool stall_fired_L = false
var bool stall_fired_S = false

// 2. Reset Logic: If a NEW trend Ignites, we reset the memory to allow a new trim.
if is_ign_bull
    stall_fired_L := false
if is_ign_bear
    stall_fired_S := false

// 3. Raw Condition (Continuous Monitor)
// Occurs when we ARE Saturated (Price High) but Stoch RSI momentum has dropped (Weakness).
bool raw_stall_bull = use_stall and is_sat_bull and not is_ign_bull and (k_val < stall_top)
bool raw_stall_bear = use_stall and is_sat_bear and not is_ign_bear and (k_val > stall_bot)

// 4. Fire Once Logic
// We only fire TRUE if the condition is met AND we haven't fired yet for this trend.
bool is_stall_bull = false
bool is_stall_bear = false

if raw_stall_bull and not stall_fired_L
    is_stall_bull := true
    stall_fired_L := true // LOCK: Mute future signals for this trend leg

if raw_stall_bear and not stall_fired_S
    is_stall_bear := true
    stall_fired_S := true // LOCK: Mute future signals for this trend leg

// ==========================================
// ─── PLOTTING: FATIGUE ENGINE ───
// ==========================================

// ─── BULL PLOTS ───
// Saturation (Continuous)
plotchar(show_fatigue and show_sat_bull and is_sat_bull ? 1 : na, title="Bull Saturation", 
     char=char_sat_bull, location=location.top, color=col_sat_bull, size=size.tiny, display=display.all - display.status_line)

// Fatigue (Exit)
plotchar(show_fatigue and show_fat_bull and is_fat_bull ? 1 : na, title="Bull Fatigue", 
     char=char_fat_bull, location=location.top, color=col_fat_bull, size=size.tiny, display=display.all - display.status_line)

// Ignition - Plots ON TOP of the first Saturation block
plotchar(show_fatigue and show_ign_bull and is_ign_bull ? 1 : na, title="Bull Ignition", 
     char=char_ign_bull, location=location.top, color=col_ign_bull, size=size.tiny, display=display.all - display.status_line)

// Stall (Warning) - Overlays on Saturation
plotchar(show_fatigue and is_stall_bull ? 1 : na, title="Bull Stall", 
     char=char_stall, location=location.top, color=col_stall, size=size.tiny, display=display.all - display.status_line)

// ─── BEAR PLOTS ───
// Saturation (Continuous)
plotchar(show_fatigue and show_sat_bear and is_sat_bear ? 1 : na, title="Bear Saturation", 
     char=char_sat_bear, location=location.bottom, color=col_sat_bear, size=size.tiny, display=display.all - display.status_line)

// Fatigue (Exit)
plotchar(show_fatigue and show_fat_bear and is_fat_bear ? 1 : na, title="Bear Fatigue", 
     char=char_fat_bear, location=location.bottom, color=col_fat_bear, size=size.tiny, display=display.all - display.status_line)

// Ignition - Plots ON TOP of the first Saturation block
plotchar(show_fatigue and show_ign_bear and is_ign_bear ? 1 : na, title="Bear Ignition", 
     char=char_ign_bear, location=location.bottom, color=col_ign_bear, size=size.tiny, display=display.all - display.status_line)

// Stall (Warning) - Overlays on Saturation
plotchar(show_fatigue and is_stall_bear ? 1 : na, title="Bear Stall", 
     char=char_stall, location=location.bottom, color=col_stall, size=size.tiny, display=display.all - display.status_line)

// ==========================================
// ─── 7. HUD TABLE SETTINGS ───
// ==========================================
grp_tab     = "7. Configure Status Table"
showTable   = input.bool(true, "Show Status Table", group=grp_tab)
tablePos    = input.string("Bottom Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right"], group=grp_tab)
textSize    = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_tab)

// Map UI strings to Pine Script constants
pos_val  = tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Left" ? position.bottom_left : position.middle_right
size_val = textSize == "Tiny" ? size.tiny : textSize == "Small" ? size.small : textSize == "Normal" ? size.normal : size.large

// ==========================================
// ─── HUD TABLE LOGIC ───
// ==========================================
// [ARCHITECTURAL NOTE: PERFORMANCE]
// 1. Table Object Initialization: We use 'var' to allocate the table structure ONCE.
// 2. String Caching: We build large static tooltip strings in the global 'var' scope so Pine Script
//    does not allocate memory and trigger garbage collection lag on every tick.
// 3. Mutation Functions: We use 'table.cell_set_*' to alter data inside existing UI elements
//    instead of destroying and recreating the cell. This eliminates chart stutter on rapid refreshes.

var infoTable = table.new(pos_val, 1, 4, frame_color=color.white, frame_width=0, border_width=0, border_color=color.white)
var int last_row_count = 0

// ─── CACHED STRING DICTIONARY (Memory Optimization) ───
var string s_osc_desc = osc_type == "PPO" ? "Engine (PPO): Measures momentum in percentages (%). This standardizes the reading so a 1% shift looks the same on a $5 stock or a $500 stock." : osc_type == "MACD-V" ? "Engine (MACD-V): Measures momentum in units of volatility. By normalizing against the Average True Range, it mathematically adapts to market chaos." : "Engine (MACD): Measures momentum in absolute dollar values ($). Classic and reactive, but does not adjust for asset price or volatility."
var string s_rsi_b_lv = str.tostring(rsi_bull_lv)
var string s_rsi_s_lv = str.tostring(rsi_bear_lv)
var string s_k_t      = str.tostring(sqz_kc_tight)
var string s_k_l      = str.tostring(sqz_kc_loose)
var string s_tf_bnd   = tf_bound

var string tt_mode_man = "Engine: Mode MANUAL\nStatus: Adaptive timeframe switching is OFF.\n\nThe engine is forcing the HTF (Swing) settings across all timeframes. Manual override engaged."
var string tt_mode_ltf = "Engine: Mode LTF\nStatus: Adaptive timeframe switching is ON. The current chart is BELOW your [" + s_tf_bnd + "] boundary.\n\nThe system is using your specialized LTF (Fast/Scalp) settings to optimize for the current chart speed."
var string tt_mode_htf = "Engine: Mode HTF\nStatus: Adaptive timeframe switching is ON. The current chart is ABOVE your [" + s_tf_bnd + "] boundary.\n\nThe system is using your specialized HTF (Standard/Swing) settings to optimize for the current chart speed."

var string s_t_thr = str.tostring(use_dual and is_ltf ? fat_thresh_ltf : fat_thresh_htf)
var string s_t_stl = str.tostring(stall_thresh)

var string tt_fat_neu = "Dual %R: Neutral\nStatus: Price is currently floating between the extreme saturation zones.\n\nThe Dual %R measures sustained trend strength. Wait for both short-term and long-term momentum to lock into an extreme zone before trusting a super-trend."
var string tt_fat_ex_b = "Dual %R: Alert (Bull Fatigue)\nStatus: The %R oscillators were locked in the upper [" + s_t_thr + "] extreme zone, but momentum has snapped below it.\n\nThe upward pressure required to maintain the lock has broken. Buyers are exhausted. Exit long positions or trail stops tightly."
var string tt_fat_ex_s = "Dual %R: Alert (Bear Fatigue)\nStatus: The %R oscillators were locked in the lower [" + s_t_thr + "] extreme zone, but momentum has snapped above it.\n\nThe downward pressure required to maintain the lock has broken. Sellers are exhausted. Exit short positions or trail stops tightly."
var string tt_fat_ig_b = "Dual %R: Action (Bull Ignition)\nStatus: Both the Fast and Slow %R oscillators have simultaneously crossed above the upper [" + s_t_thr + "] extreme zone for the first time.\n\nDual %R requires both 'sprint' and 'marathon' momentum to align. A sustained bullish lock has just engaged. Expect upward trend continuation."
var string tt_fat_ig_s = "Dual %R: Action (Bear Ignition)\nStatus: Both the Fast and Slow %R oscillators have simultaneously crossed below the lower [" + s_t_thr + "] extreme zone for the first time.\n\nDual %R requires both 'sprint' and 'marathon' momentum to align. A sustained bearish lock has just engaged. Expect downward trend continuation."
var string tt_fat_st_b = "Dual %R: Warning (Bull Stall)\nStatus: Price location is structurally locked in the upper extreme zone, but underlying momentum (Stoch RSI) has weakened and dropped below the [" + s_t_stl + "] limit.\n\nThe rally is running on fumes; price is floating, but active buying pressure has stalled. Tighten stops or trim profits; avoid adding to longs here."
var string tt_fat_st_s = "Dual %R: Warning (Bear Stall)\nStatus: Price location is structurally locked in the lower extreme zone, but underlying momentum (Stoch RSI) has weakened and risen above the [" + s_t_stl + "] limit.\n\nThe crash is running on fumes; price is floating low, but active selling pressure has stalled. Tighten stops or trim profits; avoid adding to shorts here."
var string tt_fat_hd_b = "Dual %R: Active (Bull Saturation)\nStatus: Both %R oscillators remain firmly pinned in the upper [" + s_t_thr + "] extreme zone.\n\nThe engine is running at maximum capacity. The trend is actively pushing higher. Hold position."
var string tt_fat_hd_s = "Dual %R: Active (Bear Saturation)\nStatus: Both %R oscillators remain firmly pinned in the lower [" + s_t_thr + "] extreme zone.\n\nThe engine is running at maximum capacity. The trend is actively pushing lower. Hold position."

var string tt_trig_bull = "Trigger: Action (Bull Cross)\nStatus: Momentum just completed a valid bullish cross" + (use_rsi_flt ? ", and RSI is safely below your [" + s_rsi_b_lv + "] ceiling.\n\n" : ".\n\n") + s_osc_desc + "\n\n" + (use_rsi_flt ? "All safety filters have passed. Look for entry setups." : "[WARNING]: RSI safety filters are disabled. Ensure this cross is not just sideways chop.")
var string tt_trig_bear = "Trigger: Action (Bear Cross)\nStatus: Momentum just completed a valid bearish cross" + (use_rsi_flt ? ", and RSI is safely above your [" + s_rsi_s_lv + "] floor.\n\n" : ".\n\n") + s_osc_desc + "\n\n" + (use_rsi_flt ? "All safety filters have passed. Look for entry setups." : "[WARNING]: RSI safety filters are disabled. Ensure this cross is not just sideways chop.")
var string tt_trig_hi_rsi = "Trigger: Blocked (High RSI Bull Cross)\nStatus: Momentum just completed a valid Bullish cross, but the current RSI is above your [" + s_rsi_b_lv + "] ceiling.\n\n" + s_osc_desc + "\n\nThe RSI filter acts as a safety gatekeeper. While momentum crossed up, the asset is already mathematically overbought. The signal is suppressed to prevent buying the top; sit this one out."
var string tt_trig_lo_rsi = "Trigger: Blocked (Low RSI Bear Cross)\nStatus: Momentum just completed a valid Bearish cross, but the current RSI is below your [" + s_rsi_s_lv + "] floor.\n\n" + s_osc_desc + "\n\nThe RSI filter acts as a safety gatekeeper. While momentum crossed down, the asset is already mathematically oversold. The signal is suppressed to prevent shorting the bottom; sit this one out."

var string tt_env_t_up = "Volatility: Coiling (Tight Squeeze)\nStatus: The Bollinger Bands have contracted completely inside the [" + s_k_t + "] Keltner Channels, while the internal price regression slopes upward.\n\nBuyers and sellers are at a stalemate, storing massive explosive energy. The slope suggests Bullish absorption. Prepare for a violent breakout."
var string tt_env_t_dn = "Volatility: Coiling (Tight Squeeze)\nStatus: The Bollinger Bands have contracted completely inside the [" + s_k_t + "] Keltner Channels, while the internal price regression slopes downward.\n\nBuyers and sellers are at a stalemate, storing massive explosive energy. The slope suggests Bearish absorption. Prepare for a violent breakout."
var string tt_env_l_up = "Volatility: Compressing (Loose Squeeze)\nStatus: The Bollinger Bands have contracted inside the outer [" + s_k_l + "] Keltner Channels, while the internal price regression slopes upward.\n\nThe market is beginning to coil and store energy. The slope suggests Bullish absorption. Begin monitoring for a tighter squeeze or a sudden release."
var string tt_env_l_dn = "Volatility: Compressing (Loose Squeeze)\nStatus: The Bollinger Bands have contracted inside the outer [" + s_k_l + "] Keltner Channels, while the internal price regression slopes downward.\n\nThe market is beginning to coil and store energy. The slope suggests Bearish absorption. Begin monitoring for a tighter squeeze or a sudden release."
var string tt_env_fire = "Volatility: Action (Squeeze Released)\nStatus: Price has broken out of the outer [" + s_k_l + "] Keltner Channels immediately following a recorded period of compression.\n\nThe stored energy from the stalemate has been unleashed. Momentum has chosen a direction and the trigger is pulled."

// Constants for colors
var color col_r_bull = color.rgb(1, 111, 39)
var color col_r_bear = color.rgb(140, 0, 0)

if showTable and barstate.islast
    int rIdx = 0

    // A. ENGINE MODE (Always Visible, Anchors Row 0)
    string txt_mode = use_dual ? (is_ltf ? "Mode LTF" : "Mode HTF") : "Mode MANUAL"
    string tt_mode_cell = use_dual ? (is_ltf ? tt_mode_ltf : tt_mode_htf) : tt_mode_man

    table.cell(infoTable, 0, rIdx, txt_mode, tooltip=tt_mode_cell, bgcolor=color.white, text_color=color.black, text_size=size.tiny, text_halign=text.align_right)
    rIdx += 1

    // B. %R FATIGUE ENGINE
    string txt_fat  = " %R NEUTRAL"
    string tt_fat   = tt_fat_neu
    color  col_fat  = color.black 

    if show_fatigue
        if is_fat_bull
            txt_fat := " %R EXIT"
            tt_fat  := tt_fat_ex_b
            col_fat := col_r_bull 
        else if is_fat_bear
            txt_fat := " %R EXIT"
            tt_fat  := tt_fat_ex_s
            col_fat := col_r_bear 
        else if is_ign_bull
            txt_fat := " %R LONG"
            tt_fat  := tt_fat_ig_b
            col_fat := col_r_bull
        else if is_ign_bear
            txt_fat := " %R SHORT"
            tt_fat  := tt_fat_ig_s
            col_fat := col_r_bear
        else if is_stall_bull
            txt_fat := " %R STALL"
            tt_fat  := tt_fat_st_b
            col_fat := col_r_bull
        else if is_stall_bear
            txt_fat := " %R STALL"
            tt_fat  := tt_fat_st_s
            col_fat := col_r_bear
        else if is_sat_bull
            txt_fat := " %R HOLD"
            tt_fat  := tt_fat_hd_b
            col_fat := col_r_bull
        else if is_sat_bear
            txt_fat := " %R HOLD"
            tt_fat  := tt_fat_hd_s
            col_fat := col_r_bear
        
        // Elastic UI Push
        table.cell(infoTable, 0, rIdx, txt_fat, tooltip=tt_fat, bgcolor=color.white, text_color=col_fat, text_size=size_val, text_halign=text.align_right)
        rIdx += 1

    // C. OSCILLATOR CROSS ROW
    string txt_trig  = ""
    string tt_trig   = ""
    color  col_trig  = color.black
    bool   show_trig = false

    if bull_cross
        txt_trig  := "BULL Cross"
        tt_trig   := tt_trig_bull
        col_trig  := col_r_bull
        show_trig := true
    else if bear_cross
        txt_trig  := "BEAR Cross"
        tt_trig   := tt_trig_bear
        col_trig  := col_r_bear
        show_trig := true
    else if (raw_bull and not valid_bull_rsi)
        txt_trig  := "Hi RSI Cross"
        tt_trig   := tt_trig_hi_rsi
        col_trig  := color.rgb(143, 0, 178)
        show_trig := true
    else if (raw_bear and not valid_bear_rsi)
        txt_trig  := "Lo RSI Cross"
        tt_trig   := tt_trig_lo_rsi
        col_trig  := color.rgb(143, 0, 178)
        show_trig := true

    if show_trig
        // Elastic UI Push
        table.cell(infoTable, 0, rIdx, txt_trig, tooltip=tt_trig, bgcolor=color.white, text_color=col_trig, text_size=size_val, text_halign=text.align_right)
        rIdx += 1

    // D. ENVIRONMENT ROW (Squeeze States)
    string txt_env   = ""
    string tt_env    = ""
    color  col_env   = color.black
    bool   show_env  = false

    if is_sqz_tight
        txt_env  := is_mom_rising ? "SQZ TIGHT UP" : "SQZ TIGHT DN"
        tt_env   := is_mom_rising ? tt_env_t_up : tt_env_t_dn
        show_env := true
    else if is_sqz_loose
        txt_env  := is_mom_rising ? "SQZ LOOSE UP" : "SQZ LOOSE DN"
        tt_env   := is_mom_rising ? tt_env_l_up : tt_env_l_dn
        show_env := true
    else if is_ignition
        txt_env  := "SQZ RELEASED"
        tt_env   := tt_env_fire
        show_env := true

    if show_env
        // Elastic UI Push
        table.cell(infoTable, 0, rIdx, txt_env, tooltip=tt_env, bgcolor=color.white, text_color=col_env, text_size=size_val, text_halign=text.align_right)
        rIdx += 1

    // ─── THE DESTROYER (Auto-Shrink) ───
    // Explicitly destroys physical table cells so the grid snaps tight to the anchor point.
    if rIdx < last_row_count
        table.clear(infoTable, 0, rIdx, 0, 3)
        
    last_row_count := rIdx

// ==========================================
// ─── 7.5 ALERT CONDITIONS ───
// ==========================================
// [ARCHITECTURAL NOTE]
// These allow the user to set Server-Side alerts in TradingView.
// They do NOT fire automatically; the user must configure them in the Alert menu.

// 1. Standard Oscillator Crosses
alertcondition(bull_cross, title="A. Bullish Cross", message="MACD Dive: Bullish Momentum Cross Detected")
alertcondition(bear_cross, title="B. Bearish Cross", message="MACD Dive: Bearish Momentum Cross Detected")

// 2. Squeeze Radar (The Big Move)
// A. Release (Actionable Signal)
alertcondition(is_ignition and is_breakout_u, title="C. Squeeze Release (Bull)", message="MACD Dive: Volatility Expansion (Bullish)")
alertcondition(is_ignition and is_breakout_l, title="D. Squeeze Release (Bear)", message="MACD Dive: Volatility Expansion (Bearish)")
// B. Status (Watchlist Signal)
alertcondition(is_sqz_tight, title="C2. Entered Tight Squeeze", message="MACD Dive: Market in Extreme Compression (Watch for Breakout)")
alertcondition(is_sqz_loose, title="D2. Entered Loose Squeeze", message="MACD Dive: Market in Standard Compression")

// 3. %R Dual-Lock Engine
// A. Ignition (Trend Start)
alertcondition(is_ign_bull, title="E. %R Bull Lock (Start)", message="MACD Dive: Bull Trend Lock Engaged")
alertcondition(is_ign_bear, title="F. %R Bear Lock (Start)", message="MACD Dive: Bear Trend Lock Engaged")
// B. Stall (Warning)
alertcondition(is_stall_bull, title="G. %R Bull Stall (Warn)", message="MACD Dive: Bull Trend Momentum Rotting (Stall)")
alertcondition(is_stall_bear, title="H. %R Bear Stall (Warn)", message="MACD Dive: Bear Trend Momentum Rotting (Stall)")
// C. Fatigue (Trend End)
alertcondition(is_fat_bull, title="I. %R Bull Fatigue (End)", message="MACD Dive: Bull Trend Exhaustion (%R Unlock)")
alertcondition(is_fat_bear, title="J. %R Bear Fatigue (End)", message="MACD Dive: Bear Trend Exhaustion (%R Unlock)")

// ==========================================
// ─── 8. STRATEGY BROADCASTER ───
// ==========================================
// [ARCHITECTURAL NOTE]
// This section handles the complex hand-off between the Indicator (The Brain) and the Backtester (The Hands).
// It supports two distinct protocols: Custom (Composite Signal) and TTS (Simple Signal).
//
// -----------------------------------------------------------------------------
// METHOD 1: CUSTOM "SIGNAL COMMANDER" (The 'Trimmer')
// -----------------------------------------------------------------------------
// CONNECTION: In Signal Commander, set Master Signal to "Cosmos Backtest Signal" and External SL Source to "Cosmos Trail Stop".
// PHILOSOPHY: Active Management (Trims position, rides free shares).
//    • TYPE: Composite Float (e.g., 20.0, 30.0, 2.0, 1.0)
//    • BEHAVIOR: 
//       - Entry (20.0): Strategy from [MACD Dive] determines WHAT triggers entry (Oscillator Cross or %R Ignition).
//       - TP TRIGGER:   Strategy from [MACD Dive] determines WHAT triggers take profit (ATR Extension logic).
//       - TP1 (30.0):   Exit Logic in [Signal Commander] determines HOW MUCH to sell at Take Profit (TP1 default Trim 40%).
//       - TP1 (30.0):   Simultaneously, [MACD Dive] switches Trailing mode to Wide Buffer for the remaining position (i.e., 60%).
//       - Exit (1.0):   [MACD Dive] calculates Trail Stop at Tight Buffer (if TP1 not hit) OR Wide Buffer (if TP1 hit).
//    • RESULT: Smoother equity curve, banks cash early, allows the runner to survive deeper pullbacks.
//
// -----------------------------------------------------------------------------
// METHOD 2: JASON5480's "TTS FRAMEWORK" (The 'Holder')
// -----------------------------------------------------------------------------
// CONNECTION: In TTS, set Signal to "Jason5480 TTS Signal".
// PHILOSOPHY: Diamond Hands (Holds 100% size until the trend fully breaks).
//    • TYPE: Simple Integer (1, -1, 2, -2)
//    • BEHAVIOR:
//       - Entry (1):           Strategy from [MACD Dive] determines WHAT triggers entry (Oscillator Cross or %R Ignition).
//       - TP1 (No broadcast):  [MACD Dive] switch to Wide Buffer when 'Ext: ATR Threshold' is hit. No signal is sent to TTS to trim.
//                              [WHY?] The Standard TTS Signal Protocol interprets any exit signal (2) as "Close Full Position".
//                              If we signaled TP1, TTS would kill the trade entirely. To save the "Runner", we must remain silent.
//       - Exit (2):            [MACD Dive] monitors the Trail Stop internally; sends generic Exit (2) only when price hits the stop.
//                              The TTS Backtester does NOT know the stop price; it blindly waits for the command.
//    • RESULT: Higher volatility, maximum profit on runners (100% size), but gives back more open profit on reversals.
//
// [CRITICAL SETTING FOR JASON'S TTS]
// To use Method 2 correctly, you must DISABLE Jason's internal exit logic so it respects the "Ghost" stop loss:
// • Set 'Deal Conditions Mode' -> "External"
// • Set 'Signal' -> "MACD Dive: Jason5480 TTS Signal"
// • Set 'Stop Loss' -> OFF (or very wide)
// • Set 'Take Profit' -> OFF (Let the strategy drive)

grp_strat = "8. Backtester Settings (Read Tooltips)"
tt_guide = "USER GUIDE: BROADCAST TO CONNECTION\n" + 
           "Connect the correct signal stream to your chosen Backtester. They behave differently by design.\n\n" +
           "METHOD 1: COSMOS SIGNAL COMMANDER (can handle complex Take Profit)\n" +
           "• CONNECTION: Set [Master Signal] to 'Cosmos Backtest Signal' and [External SL Source] to 'Cosmos Trail Stop'.\n" +
           "• TYPE: Composite Float (e.g., 20.0, 30.0, 2.0, 1.0)\n" +
           "• BEHAVIOR:\n" +
           "   - Entry (20.0): Strategy from [MACD Dive] determines WHAT triggers entry (Oscillator Cross or %R Ignition).\n" +
           "   - TP TRIGGER: Strategy determines WHAT triggers take profit (ATR Extension logic).\n" +
           "   - TP1 (30.0): Exit Logic in [Signal Commander] determines HOW MUCH to sell (default Trim 40%).\n" +
           "   - TP1 (30.0): Simultaneously, [MACD Dive] switches Trailing mode to 'Wide Buffer' for the remaining position (60%).\n" +
           "   - Exit (1.0): [MACD Dive] calculates Trail Stop at Tight Buffer (if TP1 not hit) OR Wide Buffer (if TP1 hit).\n" +
           "• RESULT: Smoother equity curve, banks cash early, allows the runner to survive deeper pullbacks.\n\n" +
           "METHOD 2: JASON5480's 'TTS FRAMEWORK' (simple Holder)\n" +
           "• CONNECTION: In TTS, set Signal to 'Jason5480 TTS Signal'.\n" +
           "• TYPE: Simple Integer (1, -1, 2, -2)\n" +
           "• BEHAVIOR:\n" +
           "   - Entry (1): Strategy from [MACD Dive] determines WHAT triggers entry (Oscillator Cross or %R Ignition).\n" +
           "   - TP1 (NO BROADCAST): [MACD Dive] switches to 'Wide Buffer' when 'Ext: ATR Threshold' is hit. NO signal is sent to TTS.\n" +
           "     [WHY?] TTS interprets any exit signal (2) as 'Close Full Position'. If we signaled TP1, TTS would kill the trade entirely. To save the 'Runner', we must remain silent.\n" +
           "   - Exit (2): [MACD Dive] monitors the Trail Stop internally; sends generic Exit (2) ONLY when price hits the dynamic trailing stop.\n" +
           "     The TTS Backtester does NOT know the stop price; it blindly waits for the command.\n" +
           "• RESULT: Higher volatility, maximum profit on runners (100% size), but gives back more open profit on reversals.\n\n" +
           "[CRITICAL SETTING FOR JASON'S TTS]\n" +
           "To use Method 2 correctly:\n" +
           "• Set 'Deal Conditions Mode' -> 'External'\n" +
           "• Set 'Signal' -> 'MACD Dive: Jason5480 TTS Signal'\n" +
           "• Set 'Stop Loss' -> OFF\n" +
           "• Set 'Take Profit' -> OFF"
dummy_guide = input.bool(true, "📘 README (Backtester Guide)", group=grp_strat, tooltip=tt_guide)

tt_logic = "ENTRY STRATEGY:\n" + 
           "1. Enter on Bull/Bear MACD Cross (momentum inertia), then Trim at Extended ATR Multiple above SMA. May lag after move has already started.\n" + 
           "2. Enter on %R Ignition (trend lock), then Trim at Extended ATR Multiple above SMA. May be late to trend already at highs.\n" + 
           "3. Enter on Price moving beyond Keltner (Squeeze Release) after a recent BB-KC Squeeze, then Trim at Extended ATR Multiple above SMA."
strat_select = input.string("3. Squeeze Release -> ATR Ext", "Active Strategy", group=grp_strat, tooltip = tt_logic,
     options=["1. MACD Cross -> ATR Ext", "2. %R Ignition -> ATR Ext", "3. Squeeze Release -> ATR Ext"])

trade_mode   = input.string("Long Only", "Trade Direction", options=["Long Only", "Both"], group=grp_strat, 
     tooltip="Forces the backtester to take only Longs, or both Longs and Shorts.")

// --- REGIME FILTER (Default SMA 200) ---
// We use this to filter out counter-trend entries.
// "Nothing good happens below the 200-day moving average."
// This filter forces you to align with the dominant money flow and avoid counter-trend entries.

tt_trend = "Institutional Regime Filter (The 200-Day Rule):\n" + 
           "Based on the classic risk management rule to avoid fighting the tide.\n\n" + 
           "• ON (Gatekeeper): Trades are strictly gated by the Macro Baseline.\n" + 
           "   - Longs: PERMITTED only if Price > SMA (Bull Regime).\n" + 
           "   - Shorts: PERMITTED only if Price < SMA (Bear Regime).\n" + 
           "• OFF (Wild West): Allows counter-trend entries (e.g., catching a falling knife or fading a rally).\n\n" +
           "Why use this? It drastically reduces drawdown by preventing you from buying 'cheap' stocks that are actually crashing."

use_trend_flt = input.bool(true, "Filter: Macro Trend Regime", group=grp_strat, tooltip=tt_trend)
trend_len     = input.int(200, "Regime Baseline Length", minval=1, group=grp_strat, 
     tooltip="The dividing line between Bull and Bear regimes. Standard is 200 for Daily charts.")

// --- EXIT CONFIGURATION ---
s1_ma_len   = input.int(10, "Trail: SMA Length", minval=1, group=grp_strat, tooltip="The moving average baseline used for calculating the Trailing Stop.")
s1_atr_len  = input.int(14, "Trail: ATR Length", minval=1, group=grp_strat)
s1_tight    = input.float(0.5, "Trail: Tight Buffer (ATR)", step=0.1, group=grp_strat, 
     tooltip="PROTECTION MODE:\n" + 
     "The distance of the Stop Loss BEFORE the Take Profit target is hit.\n" + 
     "Kept tight to minimize loss if the breakout fails immediately.")

s1_wide     = input.float(1.0, "Trail: Wide Buffer (ATR)",  step=0.1, group=grp_strat, 
     tooltip="RUNNER MODE:\n" + 
     "The distance of the Stop Loss AFTER the Take Profit target is hit.\n" + 
     "Widened to allow the 'Runner' portion of the position to survive pullbacks.")

ext_ma_len  = input.int(50, "Ext: Base MA Length", minval=1, group=grp_strat)
ext_mult    = input.float(7.0, "Ext: ATR Threshold (TP Trigger)", step=0.1, group=grp_strat, 
     tooltip="THE MODE SWITCH TRIGGER:\n" + 
     "When price extends this many ATRs away from the MA, the system detects 'Extension'.\n" + 
     "• Action 1: Triggers Partial Take Profit (Method 1 only).\n" + 
     "• Action 2: Switches Stop Loss from 'Tight' to 'Wide' (all Strategies).")

// --- CALCULATIONS ---
// 1. Trend Filter
float trend_ma = ta.sma(close, trend_len)
bool bull_trend_ok = use_trend_flt ? close > trend_ma : true
bool bear_trend_ok = use_trend_flt ? close < trend_ma : true

// 2. Trailing Stops
float ma_trail = ta.sma(close, s1_ma_len)
float s_atr    = ta.atr(s1_atr_len)

// Pre-calculate the offset values to avoid repetitive multiplication on each trailing band.
float offset_tight = s_atr * s1_tight
float offset_wide  = s_atr * s1_wide

float trail_tight_L = ma_trail - offset_tight
float trail_wide_L  = ma_trail - offset_wide
float trail_tight_S = ma_trail + offset_tight
float trail_wide_S  = ma_trail + offset_wide

// 3. Extension Logic
float ma_ext   = ta.sma(close, ext_ma_len)
float dist_L = high - ma_ext
float dist_S = ma_ext - low
bool is_extended_L = dist_L >= (s_atr * ext_mult)
bool is_extended_S = dist_S >= (s_atr * ext_mult)

// 4. Signal Inputs (Global Links)
// We reference the global variables calculated in previous sections
bool strat_bull_valid = bull_cross // Section 2 (RSI filtered)
bool strat_bear_valid = bear_cross // Section 2 (RSI filtered)

// --- STATE MANAGEMENT ---
var bool in_long    = false
var bool in_short   = false
var bool tp1_hit    = false 
var int  entry_idx  = 0     

// RESET GHOST STATES: Ensure Short memory does not suppress Long trades in Long Only mode.
if trade_mode == "Long Only"
    in_short := false

// --- TRIGGERS ---
bool open_long   = false
bool close_long  = false
bool open_short  = false
bool close_short = false
bool tp1_long    = false
bool tp1_short   = false

// --- LOGIC ENGINE ---
// ENTRY LOGIC (Direction + Trend Filtered)

// STRATEGY 1: MACD Cross
if strat_select == "1. MACD Cross -> ATR Ext"
    if strat_bull_valid and bull_trend_ok and not in_long
        open_long := true
    if trade_mode == "Both" and strat_bear_valid and bear_trend_ok and not in_short
        open_short := true

// STRATEGY 2: %R Ignition
if strat_select == "2. %R Ignition -> ATR Ext"
    if is_ign_bull and bull_trend_ok and not in_long
        open_long := true
    if trade_mode == "Both" and is_ign_bear and bear_trend_ok and not in_short
        open_short := true

// STRATEGY 3: Squeeze Release (Breakout)
// Logic: If Ignition fired (Release Mark) AND price is above Upper KC, it's a Long Breakout.
if strat_select == "3. Squeeze Release -> ATR Ext"
    // Note: is_ignition is calculated in Section 3.
    // We confirm direction by checking if we are breaking the Upper or Lower KC.
    // 'is_breakout_u' and 'is_breakout_l' come from Section 3 global scope.
    if is_ignition and is_breakout_u and bull_trend_ok and not in_long
        open_long := true
    if trade_mode == "Both" and is_ignition and is_breakout_l and bear_trend_ok and not in_short
        open_short := true

// STATE UPDATES
if open_long
    in_long    := true
    in_short   := false
    tp1_hit    := false
    entry_idx  := bar_index

if open_short
    in_short   := true
    in_long    := false
    tp1_hit    := false
    entry_idx  := bar_index

// EXIT & TRIM LOGIC
if in_long
    // Check extension for TP1
    if not tp1_hit and is_extended_L
        tp1_long := true
        tp1_hit  := true
    
    float active_L = tp1_hit ? trail_wide_L : trail_tight_L
    
    // Hard Exit
    if close < active_L
        close_long := true
        in_long    := false

if in_short
    // Check extension for TP1
    if not tp1_hit and is_extended_S
        tp1_short := true
        tp1_hit   := true
    
    float active_S = tp1_hit ? trail_wide_S : trail_tight_S
    
    // Hard Exit
    if close > active_S
        close_short := true
        in_short    := false

// --- DATA BROADCAST (CUSTOM BACKTESTER) ---
// ─── A. SIGNAL CONSTANTS (The Dictionary) ───
// [ARCHITECTURAL NOTE] 
// We define these codes once here. If the external backtester protocols change, 
// update the values here, and the logic below automatically adapts.

// 1. COSMOS PROTOCOL (Signal Commander)
// Used for the Composite Float signal (e.g., 21.0 = Entry Long + Exit Short)
const float COS_ENTRY = 2.0  // Trigger Entry
const float COS_EXIT  = 1.0  // Trigger Hard Exit
const float COS_TRIM  = 3.0  // Trigger Partial Take Profit
const float COS_NONE  = 0.0  // Neutral/Hold

// 2. TTS PROTOCOL (Jason5480)
// Used for simple integer state machine
const int TTS_L_START = 1    // Open Long
const int TTS_S_START = -1   // Open Short
const int TTS_L_END   = 2    // Close Long
const int TTS_S_END   = -2   // Close Short
const int TTS_NONE    = 0    // Neutral

// Returns specific codes (e.g. 20.0, 30.0) that 'Cosmos Signal Commander' understands.
// LOGIC: Determine value for Long and Short "Lanes" independently
float l_val = open_long ? COS_ENTRY : close_long ? COS_EXIT : tp1_long ? COS_TRIM : COS_NONE
float s_val = open_short ? COS_ENTRY : close_short ? COS_EXIT : tp1_short ? COS_TRIM : COS_NONE
// LOGIC: Create Composite Signal
float ext_signal = (10.0 * l_val) + s_val
// LOGIC: Select Active Trailing Stop
// If we are Long -> Check if TP1 was hit (Wide) or not (Tight) -> Select L Stop.
// If we are Short -> Check if TP1 was hit (Wide) or not (Tight) -> Select S Stop.
float smart_trail = in_long  ? (tp1_hit ? trail_wide_L : trail_tight_L) : 
                     in_short ? (tp1_hit ? trail_wide_S : trail_tight_S) : na

plot(ext_signal, title="Cosmos Backtest Signal", color=color.rgb(0, 0, 0, 100), display=display.data_window)
plot(smart_trail, title="Cosmos Trail Stop", color=color.rgb(0, 0, 0, 100), display=display.data_window)

// --- DATA BROADCAST (TTS JASON5480 COMPATIBILITY) ---
// TTS Convention: 1=StartLong, -1=StartShort, 2=EndLong, -2=EndShort
// Returns simple integers (1, -1, 2, -2) that 'TTS' understands.
// It relies on the 'close_long' signal (which IS affected by the Smart Trail logic) to exit the full position.
// NOTE: This ignores 'COS_TRIM' (tp1) signals because TTS interprets any exit code as a full close.
int tts_signal = switch
    open_long   => TTS_L_START
    open_short  => TTS_S_START
    close_long  => TTS_L_END
    close_short => TTS_S_END
    => TTS_NONE

plot(tts_signal, title="Jason5480 TTS Signal", display=display.none)
````
