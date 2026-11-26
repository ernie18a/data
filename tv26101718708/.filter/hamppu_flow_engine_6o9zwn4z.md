# Hamppu - Flow Engine

- url: https://www.tradingview.com/script/6O9Zwn4Z-Hamppu-Flow-Engine/
- type: indicator
- pine_id: PUB;4ca067564f5f4bbc89ea2ed8838f60a1
- version: 1.0

## Description

Hamppu - Flow Engine is an open-source crypto intraday context engine built in Pine Script v6.

It is designed to help read market context, not to provide standalone buy/sell signals.

The script combines multi-layer RSI regime logic, RSI compression/release, WaveTrend-style stretch reclaim/reject context, liquidity sweep quality scoring, displacement after sweep, HTF with-flow / counter-flow classification and a dynamic MTF Flow Stack.

The goal is transparency. Markers are not magic signals. They are context events that help show when momentum, liquidity and higher-timeframe flow may be interacting.

Core features:
- Multi-layer RSI momentum regime
- RSI compression and directional release
- WaveTrend-style stretch reclaim/reject context
- Liquidity sweep quality scoring
- Displacement after sweep
- HTF with-flow / counter-flow classification
- MTF Flow Stack with selectable 3–6 timeframe slots
- Curated profiles: Balanced, Degen Fast, Conservative, Research and Custom
- Optional source labels for studying RSI / WaveTrend / Degen Fast marker sources

Visual language:
- Background color shows local RSI regime.
- Marker color shows HTF alignment.
- MTF Flow Stack shows broader multi-timeframe momentum context.

Marker guide:
- Triangle = early momentum reclaim/reject context
- Circle = momentum release after RSI compression
- X = compression release / compression ended
- Heart = Flow Context: sweep + displacement + momentum
- Orange marker = counter-flow / HTF disagreement

Profiles:
Balanced is the default public profile.
Degen Fast is a faster 5m/15m profile with early reclaim behavior.
Conservative is stricter and produces fewer context events.
Research is a looser exploration profile.
Custom is for manual tuning.

Important:
Balanced, Degen Fast, Conservative and Research are curated presets. These presets may override selected sensitivity controls internally, including sweep thresholds, cooldowns, compression tightness and confirmed/live behavior.

Use Profile = Custom if you want manual control over the visible sensitivity inputs.

Suggested workflow:
1. Start with Balanced.
2. Read the background regime first.
3. Check marker color for HTF alignment.
4. Use the MTF Flow Stack to understand broader context.
5. Treat markers as context events, not automatic entries.
6. Use your own price action, risk management and invalidation.

Alerts:
Alerts focus on main context events and with-flow reclaim/reject events. Not every visual marker has a separate alert. For more stable alerts, use bar-close alert settings.

Stability note:
When confirmed HTF is active, HTF Bias uses the previous closed HTF candle. Current chart timeframe values can still update while the active candle is open.

License: MIT.

This script is published for educational/open-source purposes. It does not provide financial advice.

## Source Code

````pine
//@version=6
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hamppu - Flow Engine v4.9
// SPDX-License-Identifier: MIT
// License: MIT
// Copyright (c) 2026 Hamppu
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Transparent crypto intraday context engine for TradingView.
// Built for educational / open-source use.
//
// This script does not provide financial advice.
// Markers are context events, not standalone buy/sell signals.
//
// Core logic:
// - Multi-layer RSI momentum regime
// - RSI compression and momentum release
// - WaveTrend stretch reclaim/reject context
// - Liquidity sweep quality scoring
// - Displacement after sweep
// - HTF with-flow / counter-flow classification
// - Dynamic MTF Flow Stack with selectable 3–6 timeframe slots
// - Curated profiles for balanced, faster, stricter and research workflows
//
// Marker guide:
// Triangle = early momentum reclaim/reject context
// Circle   = momentum release after compression
// X        = compression release
// Heart    = Flow Context: sweep + displacement + momentum
// Orange   = counter-flow / HTF disagreement
//
// Visual language:
// - Marker color shows HTF alignment.
// - Background shows local RSI regime.
// - MTF Flow Stack shows broader multi-timeframe context.
// - A bull Flow Context can appear inside local bear regime.
//   This means local reversal context inside broader flow classification,
//   not a standalone long signal.
//
// Profile note:
// - Balanced, Degen Fast, Conservative and Research are curated presets.
// - Curated presets may override selected sensitivity controls internally.
// - This includes sweep thresholds, cooldowns, compression tightness and confirmed/live behavior.
// - Use Profile = Custom if you want manual control.
// - Custom respects the visible manual sensitivity inputs.
// - Display toggles, HTF Bias toggle and MTF dashboard settings remain user-configurable.
//
// Stability / alerts:
// - When confirmed HTF is active, HTF Bias uses the previous closed HTF candle.
// - Current chart timeframe values can update while the active candle is open.
// - For more stable alerts, use bar-close alert settings.
// - Alerts focus on main context events and with-flow reclaim/reject events.
// - Not every visual marker has a separate alert.
//
// WaveTrend calculation inspired by the classic LazyBear WaveTrend formulation.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
indicator("Hamppu - Flow Engine", overlay=false)

//━━━━━━━━━━━━━━━━━━
// INPUT GROUPS
//━━━━━━━━━━━━━━━━━━
group_display = "Display"
group_liquidity = "Liquidity / Sweep Quality"
group_rsi = "RSI Engine"
group_wt = "WaveTrend Engine"
group_htf = "HTF Bias"
group_mtf = "MTF Flow Stack"

//━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━
profile = input.string(
     "Balanced",
     "Profile",
     options=["Balanced", "Degen Fast", "Conservative", "Research", "Custom"],
     group=group_display,
     display=display.none,
     tooltip="Balanced, Degen Fast, Conservative and Research are curated presets that may override selected sensitivity inputs. Use Profile = Custom for manual control. Custom respects the visible manual sensitivity inputs. Display, HTF and MTF dashboard settings remain user-configurable."
)

show_coil_start = input.bool(
     false,
     "Show Coil Start",
     group=group_display,
     display=display.none,
     tooltip="Shows the first candle where momentum compression begins. Usually best left OFF because compression background already shows the coil zone."
)

show_quality_sweeps = input.bool(
     false,
     "Show Quality Sweeps",
     group=group_display,
     display=display.none,
     tooltip="Shows filtered sweep events. Useful for research/inspection, but can add visual noise. Flow Context hearts are the main marker."
)

show_flow_context = input.bool(
     true,
     "Show Flow Context",
     group=group_display,
     display=display.none,
     tooltip="Shows heart markers when quality sweep + displacement + momentum context align. This is context, not a standalone entry signal."
)

show_reclaim_reject = input.bool(
     true,
     "Show Momentum Reclaim / Reject",
     group=group_display,
     display=display.none,
     tooltip="Shows early momentum reclaim/reject triangles. These can be RSI-led or WaveTrend-led. Color shows HTF flow alignment. These are context markers, not standalone entries."
)

show_momentum_release = input.bool(
     true,
     "Show Momentum Release",
     group=group_display,
     display=display.none,
     tooltip="Shows green/red circles when RSI compression releases directionally. These are context markers, not standalone entry signals."
)

show_compression_release = input.bool(
     true,
     "Show Compression Release",
     group=group_display,
     display=display.none,
     tooltip="Shows pink X markers when RSI compression ends. This is a state-change marker, not an entry signal."
)

show_ema34 = input.bool(
     true,
     "Show EMA 34",
     group=group_display,
     display=display.none,
     tooltip="Plots EMA34 on the price chart. Used as local wave context for 5m/15m intraday trading."
)

show_reclaim_source_labels = input.bool(
     false,
     "Show Reclaim Source Labels",
     group=group_display,
     display=display.none,
     tooltip="Shows inspection labels for Momentum Reclaim / Reject markers. R = RSI source, W = WaveTrend source, D = Degen Fast early reclaim. Labels are for studying marker sources and are hidden by default."
)

show_wt_lines = input.bool(
     false,
     "Show WT Lines",
     group=group_display,
     display=display.none,
     tooltip="Optional advanced inspection layer. Shows the internal WT1/WT2 lines used for WaveTrend reclaim/reject context. Default OFF to keep the indicator panel clean. WT uses a different scale than RSI, so enabling it may rescale the panel."
)

//━━━━━━━━━━━━━━━━━━
// LIQUIDITY / SWEEP QUALITY
//━━━━━━━━━━━━━━━━━━
liq_lookback = input.int(
     20,
     "Liquidity Lookback",
     group=group_liquidity,
     display=display.none,
     tooltip="How many bars back the engine looks for previous highs/lows that can be swept. Higher values detect larger liquidity pools, lower values react faster."
)

flow_context_window = input.int(
     5,
     "Flow Context Window",
     minval=1,
     group=group_liquidity,
     display=display.none,
     tooltip="How many bars after a sweep or compression release the event can still be considered recent for Flow Context."
)

context_cooldown = input.int(
     5,
     "Flow Context Cooldown",
     minval=1,
     group=group_liquidity,
     display=display.none,
     tooltip="Minimum bars before another same-side Flow Context marker can print. Helps reduce repeated hearts in the same move."
)

use_sweep_quality = input.bool(
     true,
     "Use Sweep Quality Filter",
     group=group_liquidity,
     display=display.none,
     tooltip="When ON, sweeps must pass candle quality checks based on range, wick size, wick/body ratio, and close position. Recommended ON for cleaner context."
)

sweep_atr_len = input.int(
     14,
     "Sweep ATR Length",
     minval=1,
     group=group_liquidity,
     display=display.none,
     tooltip="ATR length used to judge sweep candle range. Higher values smooth volatility more, lower values react faster."
)

min_range_atr = input.float(
     0.62,
     "Min Sweep Range / ATR",
     step=0.05,
     minval=0.0,
     group=group_liquidity,
     display=display.none,
     tooltip="Minimum candle range relative to ATR for a sweep to count as meaningful. Higher values require stronger expansion candles."
)

min_wick_range = input.float(
     0.30,
     "Min Wick % of Candle Range",
     step=0.05,
     minval=0.0,
     maxval=1.0,
     group=group_liquidity,
     display=display.none,
     tooltip="Minimum wick size as a percentage of the whole candle range. Helps identify actual stop-run / rejection candles instead of weak taps."
)

min_wick_body = input.float(
     0.75,
     "Min Wick / Body Ratio",
     step=0.25,
     minval=0.0,
     group=group_liquidity,
     display=display.none,
     tooltip="Minimum wick-to-body ratio for sweep quality. Higher values require stronger rejection wicks compared to the candle body."
)

close_reclaim_strength = input.float(
     0.55,
     "Close Reclaim Strength",
     step=0.05,
     minval=0.0,
     maxval=1.0,
     group=group_liquidity,
     display=display.none,
     tooltip="How strongly the candle must close back into range after a sweep. For sweep lows, higher means close nearer the top of the candle. For sweep highs, lower close position is required."
)

min_sweep_score = input.int(
     3,
     "Min Sweep Quality Score",
     minval=1,
     maxval=4,
     group=group_liquidity,
     display=display.none,
     tooltip="Minimum sweep quality score from 1 to 4. Score checks range, wick size, wick/body ratio, and close reclaim strength. Higher = fewer but cleaner sweeps."
)

//━━━━━━━━━━━━━━━━━━
// RSI ENGINE INPUTS
//━━━━━━━━━━━━━━━━━━
fast_len = input.int(
     6,
     "Fast RSI",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Fast RSI length. Reacts quickly to local momentum shifts and early reclaim/reject behavior."
)

mid_len = input.int(
     18,
     "Mid RSI",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Mid RSI length. Acts as the middle momentum layer between fast impulse and slower regime."
)

slow_len = input.int(
     34,
     "Slow RSI",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Slow RSI length. Used for broader momentum regime classification and background bias."
)

fast_smooth = input.int(
     8,
     "Fast Smooth",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Smoothing length for Fast RSI. Used for fast reclaim/reject crosses."
)

slow_smooth = input.int(
     21,
     "Slow Smooth",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Smoothing length for Slow RSI. Used to classify bullish/bearish RSI regime."
)

compression_tightness = input.float(
     3.0,
     "Compression Tightness",
     step=0.1,
     minval=0.1,
     group=group_rsi,
     display=display.none,
     tooltip="Maximum allowed distance between RSI layers for compression. Lower values require tighter coil, higher values detect looser compression."
)

bull_reclaim_cooldown = input.int(
     7,
     "Bull Reclaim Cooldown",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Limits repeated bullish reclaim triangles. Helps keep early long-side momentum markers from clustering too much."
)

bear_reject_cooldown = input.int(
     9,
     "Bear Reject Cooldown",
     minval=1,
     group=group_rsi,
     display=display.none,
     tooltip="Limits repeated bearish reject triangles. Helps reduce top-side marker clutter in weak markets."
)

//━━━━━━━━━━━━━━━━━━
// WAVETREND INPUTS
//━━━━━━━━━━━━━━━━━━
n1 = input.int(
     10,
     "WT Channel Length",
     minval=1,
     group=group_wt,
     display=display.none,
     tooltip="WaveTrend channel length. Lower values react faster, higher values smooth the base WT calculation."
)

n2 = input.int(
     21,
     "WT Average Length",
     minval=1,
     group=group_wt,
     display=display.none,
     tooltip="WaveTrend average length. Controls WT1 smoothing. Higher values create slower, cleaner WT movement."
)

wt_signal_len = input.int(
     4,
     "WT Signal Length",
     minval=1,
     group=group_wt,
     display=display.none,
     tooltip="Controls WT2 smoothing. Lower = faster crosses, higher = smoother/slower confirmation."
)

wt_stretch_lookback = input.int(
     3,
     "WT Stretch Lookback",
     minval=1,
     group=group_wt,
     display=display.none,
     tooltip="How many previous candles WT can be stretched before a reclaim/reject cross still counts."
)

stretch_ob = input.float(
     65.0,
     "WT Stretch High",
     group=group_wt,
     display=display.none,
     tooltip="Upper WaveTrend stretch level. Bearish reject context can trigger when WT was recently above this level and crosses down."
)

stretch_os = input.float(
     -65.0,
     "WT Stretch Low",
     group=group_wt,
     display=display.none,
     tooltip="Lower WaveTrend stretch level. Bullish reclaim context can trigger when WT was recently below this level and crosses up."
)

//━━━━━━━━━━━━━━━━━━
// WAVETREND ENGINE
//━━━━━━━━━━━━━━━━━━
ap = hlc3
esa = ta.ema(ap, n1)
d = ta.ema(math.abs(ap - esa), n1)
d_safe = d == 0.0 ? 1e-10 : d
ci = (ap - esa) / (0.015 * d_safe)

wt1 = ta.ema(ci, n2)
wt2 = ta.sma(wt1, wt_signal_len)

wt_bull_cross = ta.crossover(wt1, wt2)
wt_bear_cross = ta.crossunder(wt1, wt2)

wt_was_stretched_low =
     ta.lowest(wt1, wt_stretch_lookback)[1] < stretch_os

wt_was_stretched_high =
     ta.highest(wt1, wt_stretch_lookback)[1] > stretch_ob

wt_reclaim_long =
     wt_was_stretched_low and wt_bull_cross

wt_reject_short =
     wt_was_stretched_high and wt_bear_cross

//━━━━━━━━━━━━━━━━━━
// HTF BIAS INPUTS
//━━━━━━━━━━━━━━━━━━
use_htf_bias = input.bool(
     true,
     "Use HTF Bias",
     group=group_htf,
     display=display.none,
     tooltip="Global HTF classification toggle. When ON, local momentum and Flow Context are classified as with-flow or counter-flow. Profiles control confirmed/live HTF behavior separately."
)

htf_tf = input.timeframe(
     "60",
     "HTF Timeframe",
     group=group_htf,
     display=display.none,
     tooltip="Higher timeframe used for flow classification. For 5m charts, 1H is a balanced default. Lower HTF reacts faster, higher HTF is stricter."
)

htf_ema_len = input.int(
     210,
     "HTF EMA Length",
     group=group_htf,
     display=display.none,
     tooltip="EMA length used by HTF bias modes. 210 is a slightly slower alternative to the common 200 EMA."
)

htf_bias_mode = input.string(
     "HLC3 vs EMA",
     "HTF Bias Mode",
     options=["Close vs EMA", "HLC3 vs EMA", "EMA34 vs EMA210"],
     group=group_htf,
     display=display.none,
     tooltip="Choose how higher timeframe bias is classified. HLC3 vs EMA is smoother than Close vs EMA. EMA34 vs EMA210 behaves more like a trend structure filter."
)

use_confirmed_htf = input.bool(
     true,
     "Confirmed HTF Bias",
     group=group_htf,
     display=display.none,
     tooltip="Manual confirmed/live HTF setting used when Profile = Custom. Curated profiles use internal behavior: Balanced and Conservative use confirmed HTF, Degen Fast and Research use live HTF."
)

// Effective HTF setting selected by Profile.
// Custom keeps the manual input above.
eff_use_confirmed_htf =
     profile == "Degen Fast" ? false :
     profile == "Research" ? false :
     profile == "Custom" ? use_confirmed_htf :
     true

// HTF bias function
f_htf_bull() =>
    switch htf_bias_mode
        "Close vs EMA" =>
            close > ta.ema(close, htf_ema_len)
        "HLC3 vs EMA" =>
            hlc3 > ta.ema(hlc3, htf_ema_len)
        "EMA34 vs EMA210" =>
            ta.ema(close, 34) > ta.ema(close, htf_ema_len)

f_htf_bear() =>
    switch htf_bias_mode
        "Close vs EMA" =>
            close < ta.ema(close, htf_ema_len)
        "HLC3 vs EMA" =>
            hlc3 < ta.ema(hlc3, htf_ema_len)
        "EMA34 vs EMA210" =>
            ta.ema(close, 34) < ta.ema(close, htf_ema_len)

// Live HTF bias
htf_bull_live = request.security(syminfo.tickerid, htf_tf, f_htf_bull())
htf_bear_live = request.security(syminfo.tickerid, htf_tf, f_htf_bear())

// Confirmed HTF bias, previous closed HTF candle
htf_bull_confirmed = request.security(syminfo.tickerid, htf_tf, f_htf_bull()[1])
htf_bear_confirmed = request.security(syminfo.tickerid, htf_tf, f_htf_bear()[1])

htf_bull = eff_use_confirmed_htf ? htf_bull_confirmed : htf_bull_live
htf_bear = eff_use_confirmed_htf ? htf_bear_confirmed : htf_bear_live

htf_long_ok = not use_htf_bias or htf_bull
htf_short_ok = not use_htf_bias or htf_bear

//━━━━━━━━━━━━━━━━━━
// MTF FLOW STACK INPUTS
//━━━━━━━━━━━━━━━━━━
show_mtf_stack = input.bool(
     true,
     "Show MTF Flow Stack",
     group=group_mtf,
     display=display.none,
     tooltip="Shows a multi-timeframe RSI momentum summary as a table. This is context, not a standalone signal."
)

mtf_slots = input.int(
     6,
     "MTF Slots",
     minval=3,
     maxval=6,
     group=group_mtf,
     display=display.none,
     tooltip="How many MTF rows are used in the Flow Stack score and table. Default 6 shows the full 10m/15m/30m/1H/2H/4H stack. Lower values create a cleaner compact view."
)

mtf_use_confirmed = input.bool(
     false,
     "Use Confirmed MTF RSI",
     group=group_mtf,
     display=display.none,
     tooltip="Controls confirmed/live MTF RSI for Balanced and Custom. Conservative uses confirmed MTF RSI internally, while Degen Fast and Research use live MTF RSI."
)

mtf_rsi_len = input.int(
     7,
     "MTF RSI Length",
     minval=1,
     group=group_mtf,
     display=display.none,
     tooltip="RSI length used for the multi-timeframe flow stack. Default 7 keeps the stack responsive while reducing noise compared to very fast RSI lengths. Lower values react faster, higher values smooth more."
)

mtf_bull_level = input.float(
     50.0,
     "MTF Bull Level",
     step=0.5,
     group=group_mtf,
     display=display.none,
     tooltip="RSI level required for a timeframe to count as bullish in the MTF Flow Stack."
)

mtf_neutral_band = input.float(
     2.0,
     "MTF Neutral Band",
     step=0.5,
     minval=0.0,
     group=group_mtf,
     display=display.none,
     tooltip="Creates a neutral zone around the MTF Bull Level. With bull level 50 and neutral band 2, RSI 48–52 counts as Neutral."
)

mtf_curl_lookback = input.int(
     1,
     "MTF Curl Lookback",
     minval=1,
     group=group_mtf,
     display=display.none,
     tooltip="How many candles of each selected timeframe are used to judge whether MTF RSI is curling up, down, or flat."
)

mtf_curl_threshold = input.float(
     0.25,
     "MTF Curl Threshold",
     step=0.05,
     minval=0.0,
     group=group_mtf,
     display=display.none,
     tooltip="Minimum RSI change required to show an up/down curl arrow. Smaller values react faster, larger values ignore minor noise."
)

show_mtf_values = input.bool(
     false,
     "Show MTF RSI Values",
     group=group_mtf,
     display=display.none,
     tooltip="When ON, the MTF table shows raw RSI values. When OFF, it only shows curl direction and state for a cleaner dashboard."
)

mtf_table_position_input = input.string(
     "Top Right",
     "MTF Table Position",
     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"],
     group=group_mtf,
     display=display.none,
     tooltip="Controls where the MTF table is placed inside the indicator pane."
)

mtf_tf_1 = input.timeframe(
     "10",
     "MTF 1",
     options=["3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "1M"],
     group=group_mtf,
     display=display.none,
     tooltip="Timeframe used for this MTF slot. Intraday values use minutes: 60 = 1H, 240 = 4H, 360 = 6H, 480 = 8H, 720 = 12H. Higher context: D = 1D, W = 1W, 1M = 1 month."
)

mtf_tf_2 = input.timeframe(
     "15",
     "MTF 2",
     options=["3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "1M"],
     group=group_mtf,
     display=display.none,
     tooltip="Timeframe used for this MTF slot. Intraday values use minutes: 60 = 1H, 240 = 4H, 360 = 6H, 480 = 8H, 720 = 12H. Higher context: D = 1D, W = 1W, 1M = 1 month."
)

mtf_tf_3 = input.timeframe(
     "30",
     "MTF 3",
     options=["3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "1M"],
     group=group_mtf,
     display=display.none,
     tooltip="Timeframe used for this MTF slot. Intraday values use minutes: 60 = 1H, 240 = 4H, 360 = 6H, 480 = 8H, 720 = 12H. Higher context: D = 1D, W = 1W, 1M = 1 month."
)

mtf_tf_4 = input.timeframe(
     "60",
     "MTF 4",
     options=["3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "1M"],
     group=group_mtf,
     display=display.none,
     tooltip="Timeframe used for this MTF slot. Intraday values use minutes: 60 = 1H, 240 = 4H, 360 = 6H, 480 = 8H, 720 = 12H. Higher context: D = 1D, W = 1W, 1M = 1 month."
)

mtf_tf_5 = input.timeframe(
     "120",
     "MTF 5",
     options=["3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "1M"],
     group=group_mtf,
     display=display.none,
     tooltip="Timeframe used for this MTF slot. Intraday values use minutes: 60 = 1H, 240 = 4H, 360 = 6H, 480 = 8H, 720 = 12H. Higher context: D = 1D, W = 1W, 1M = 1 month."
)

mtf_tf_6 = input.timeframe(
     "240",
     "MTF 6",
     options=["3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "360", "480", "720", "D", "W", "1M"],
     group=group_mtf,
     display=display.none,
     tooltip="Timeframe used for this MTF slot. Intraday values use minutes: 60 = 1H, 240 = 4H, 360 = 6H, 480 = 8H, 720 = 12H. Higher context: D = 1D, W = 1W, 1M = 1 month."
)

//━━━━━━━━━━━━━━━━━━
// PROFILE / EFFECTIVE SETTINGS
//━━━━━━━━━━━━━━━━━━
// Balanced     = default public profile.
// Degen Fast   = faster 5m/15m profile with Degen-only early reclaim logic.
// Conservative = stricter profile with fewer context events.
// Research     = looser exploration profile for studying context behavior.
// Custom       = manual-control profile for sensitivity inputs.

eff_liq_lookback =
     profile == "Research" ? 15 :
     profile == "Conservative" ? 30 :
     profile == "Custom" ? liq_lookback :
     20

eff_flow_context_window =
     profile == "Degen Fast" ? 6 :
     profile == "Conservative" ? 4 :
     profile == "Research" ? 7 :
     profile == "Custom" ? flow_context_window :
     5

eff_context_cooldown =
     profile == "Degen Fast" ? 4 :
     profile == "Conservative" ? 8 :
     profile == "Research" ? 3 :
     profile == "Custom" ? context_cooldown :
     5

eff_bull_reclaim_cooldown =
     profile == "Degen Fast" ? 5 :
     profile == "Conservative" ? 8 :
     profile == "Research" ? 2 :
     profile == "Custom" ? bull_reclaim_cooldown :
     7

eff_bear_reject_cooldown =
     profile == "Degen Fast" ? 7 :
     profile == "Conservative" ? 10 :
     profile == "Research" ? 3 :
     profile == "Custom" ? bear_reject_cooldown :
     9

eff_use_sweep_quality =
     profile == "Custom" ? use_sweep_quality :
     true

eff_min_range_atr =
     profile == "Degen Fast" ? 0.58 :
     profile == "Conservative" ? 0.75 :
     profile == "Research" ? 0.45 :
     profile == "Custom" ? min_range_atr :
     0.62

eff_min_wick_range =
     profile == "Degen Fast" ? 0.25 :
     profile == "Conservative" ? 0.35 :
     profile == "Research" ? 0.20 :
     profile == "Custom" ? min_wick_range :
     0.30

eff_min_wick_body =
     profile == "Degen Fast" ? 0.60 :
     profile == "Conservative" ? 1.00 :
     profile == "Research" ? 0.40 :
     profile == "Custom" ? min_wick_body :
     0.75

eff_close_reclaim_strength =
     profile == "Degen Fast" ? 0.50 :
     profile == "Conservative" ? 0.60 :
     profile == "Research" ? 0.45 :
     profile == "Custom" ? close_reclaim_strength :
     0.55

eff_min_sweep_score =
     profile == "Conservative" ? 4 :
     profile == "Research" ? 2 :
     profile == "Custom" ? min_sweep_score :
     3

eff_compression_tightness =
     profile == "Degen Fast" ? 3.3 :
     profile == "Conservative" ? 2.7 :
     profile == "Research" ? 4.0 :
     profile == "Custom" ? compression_tightness :
     3.0

eff_mtf_use_confirmed =
     profile == "Conservative" ? true :
     profile == "Degen Fast" ? false :
     profile == "Research" ? false :
     mtf_use_confirmed

// Display toggles remain manual in every profile.
// Research changes engine sensitivity, but does not force extra visual markers on.
show_coil_start_active = show_coil_start
show_quality_sweeps_active = show_quality_sweeps

//━━━━━━━━━━━━━━━━━━
// MTF FLOW STACK ENGINE
//━━━━━━━━━━━━━━━━━━
f_mtf_rsi() =>
    _r = ta.rsi(close, mtf_rsi_len)
    eff_mtf_use_confirmed ? _r[1] : _r

f_mtf_rsi_delta() =>
    _r = ta.rsi(close, mtf_rsi_len)
    _v = eff_mtf_use_confirmed ? _r[1] : _r
    _v - _v[mtf_curl_lookback]

mtf_rsi_1 = request.security(syminfo.tickerid, mtf_tf_1, f_mtf_rsi())
mtf_rsi_2 = request.security(syminfo.tickerid, mtf_tf_2, f_mtf_rsi())
mtf_rsi_3 = request.security(syminfo.tickerid, mtf_tf_3, f_mtf_rsi())
mtf_rsi_4 = request.security(syminfo.tickerid, mtf_tf_4, f_mtf_rsi())
mtf_rsi_5 = request.security(syminfo.tickerid, mtf_tf_5, f_mtf_rsi())
mtf_rsi_6 = request.security(syminfo.tickerid, mtf_tf_6, f_mtf_rsi())

mtf_delta_1 = request.security(syminfo.tickerid, mtf_tf_1, f_mtf_rsi_delta())
mtf_delta_2 = request.security(syminfo.tickerid, mtf_tf_2, f_mtf_rsi_delta())
mtf_delta_3 = request.security(syminfo.tickerid, mtf_tf_3, f_mtf_rsi_delta())
mtf_delta_4 = request.security(syminfo.tickerid, mtf_tf_4, f_mtf_rsi_delta())
mtf_delta_5 = request.security(syminfo.tickerid, mtf_tf_5, f_mtf_rsi_delta())
mtf_delta_6 = request.security(syminfo.tickerid, mtf_tf_6, f_mtf_rsi_delta())

mtf_upper = mtf_bull_level + mtf_neutral_band
mtf_lower = mtf_bull_level - mtf_neutral_band

mtf_active_count = mtf_slots

mtf_active_1 = mtf_slots >= 1
mtf_active_2 = mtf_slots >= 2
mtf_active_3 = mtf_slots >= 3
mtf_active_4 = mtf_slots >= 4
mtf_active_5 = mtf_slots >= 5
mtf_active_6 = mtf_slots >= 6

mtf_strong_threshold =
     mtf_active_count <= 3 ? 3 :
     mtf_active_count <= 4 ? 4 :
     mtf_active_count <= 5 ? 4 :
     5

f_mtf_is_bull(_rsi) =>
    not na(_rsi) and _rsi > mtf_upper

f_mtf_is_bear(_rsi) =>
    not na(_rsi) and _rsi < mtf_lower

f_mtf_state(_rsi) =>
    if na(_rsi)
        "na"
    else if _rsi > mtf_upper
        "Bull"
    else if _rsi < mtf_lower
        "Bear"
    else
        "Neutral"

f_mtf_color(_rsi) =>
    if na(_rsi)
        color.new(color.gray, 85)
    else if _rsi > mtf_upper
        color.new(color.lime, 80)
    else if _rsi < mtf_lower
        color.new(color.red, 80)
    else
        color.new(color.gray, 80)

f_mtf_text(_rsi) =>
    na(_rsi) ? "na" : str.tostring(_rsi, "#.0")

mtf_bull_1 = f_mtf_is_bull(mtf_rsi_1)
mtf_bull_2 = f_mtf_is_bull(mtf_rsi_2)
mtf_bull_3 = f_mtf_is_bull(mtf_rsi_3)
mtf_bull_4 = f_mtf_is_bull(mtf_rsi_4)
mtf_bull_5 = f_mtf_is_bull(mtf_rsi_5)
mtf_bull_6 = f_mtf_is_bull(mtf_rsi_6)

mtf_bear_1 = f_mtf_is_bear(mtf_rsi_1)
mtf_bear_2 = f_mtf_is_bear(mtf_rsi_2)
mtf_bear_3 = f_mtf_is_bear(mtf_rsi_3)
mtf_bear_4 = f_mtf_is_bear(mtf_rsi_4)
mtf_bear_5 = f_mtf_is_bear(mtf_rsi_5)
mtf_bear_6 = f_mtf_is_bear(mtf_rsi_6)

mtf_bull_score =
     (mtf_active_1 and mtf_bull_1 ? 1 : 0) +
     (mtf_active_2 and mtf_bull_2 ? 1 : 0) +
     (mtf_active_3 and mtf_bull_3 ? 1 : 0) +
     (mtf_active_4 and mtf_bull_4 ? 1 : 0) +
     (mtf_active_5 and mtf_bull_5 ? 1 : 0) +
     (mtf_active_6 and mtf_bull_6 ? 1 : 0)

mtf_bear_score =
     (mtf_active_1 and mtf_bear_1 ? 1 : 0) +
     (mtf_active_2 and mtf_bear_2 ? 1 : 0) +
     (mtf_active_3 and mtf_bear_3 ? 1 : 0) +
     (mtf_active_4 and mtf_bear_4 ? 1 : 0) +
     (mtf_active_5 and mtf_bear_5 ? 1 : 0) +
     (mtf_active_6 and mtf_bear_6 ? 1 : 0)

mtf_flow_state =
     mtf_bull_score >= mtf_strong_threshold ? "Strong Bull" :
     mtf_bear_score >= mtf_strong_threshold ? "Strong Bear" :
     mtf_bull_score > mtf_bear_score ? "Bull Lean" :
     mtf_bear_score > mtf_bull_score ? "Bear Lean" :
     "Mixed"

mtf_context_label =
     mtf_flow_state == "Strong Bull" ? "Strong Bullish" :
     mtf_flow_state == "Strong Bear" ? "Strong Bearish" :
     mtf_flow_state == "Bull Lean" ? "Bullish Context" :
     mtf_flow_state == "Bear Lean" ? "Bearish Context" :
     "Mixed Context"

f_tf_label(_tf) =>
    if _tf == "1"
        "1m"
    else if _tf == "3"
        "3m"
    else if _tf == "5"
        "5m"
    else if _tf == "10"
        "10m"
    else if _tf == "15"
        "15m"
    else if _tf == "30"
        "30m"
    else if _tf == "45"
        "45m"
    else if _tf == "60"
        "1H"
    else if _tf == "120"
        "2H"
    else if _tf == "180"
        "3H"
    else if _tf == "240"
        "4H"
    else if _tf == "360"
        "6H"
    else if _tf == "480"
        "8H"
    else if _tf == "720"
        "12H"
    else if _tf == "D"
        "1D"
    else if _tf == "W"
        "1W"
    else if _tf == "M" or _tf == "1M"
        "1M"
    else
        _tf

f_mtf_curl(_delta) =>
    if na(_delta)
        "·"
    else if _delta > mtf_curl_threshold
        "↑"
    else if _delta < -mtf_curl_threshold
        "↓"
    else
        "→"

f_mtf_cell(_rsi, _delta) =>
    _base = f_mtf_curl(_delta) + " " + f_mtf_state(_rsi)
    show_mtf_values ? _base + " " + f_mtf_text(_rsi) : _base

//━━━━━━━━━━━━━━━━━━
// PRICE / LIQUIDITY CONTEXT
//━━━━━━━━━━━━━━━━━━
prev_low = ta.lowest(low, eff_liq_lookback)[1]
prev_high = ta.highest(high, eff_liq_lookback)[1]

// Raw sweep detection
sweep_low_raw = low < prev_low and close > prev_low
sweep_high_raw = high > prev_high and close < prev_high

// Candle anatomy
sweep_atr = ta.atr(sweep_atr_len)

candle_range = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
body_safe = math.max(body, syminfo.mintick)

upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

close_position = (close - low) / candle_range

// Sweep quality components
range_ok = candle_range >= sweep_atr * eff_min_range_atr

low_wick_range_ok = lower_wick / candle_range >= eff_min_wick_range
high_wick_range_ok = upper_wick / candle_range >= eff_min_wick_range

low_wick_body_ok = lower_wick / body_safe >= eff_min_wick_body
high_wick_body_ok = upper_wick / body_safe >= eff_min_wick_body

low_close_ok = close_position >= eff_close_reclaim_strength
high_close_ok = close_position <= 1.0 - eff_close_reclaim_strength

// Quality score: 0–4
low_sweep_score =
     (range_ok ? 1 : 0) +
     (low_wick_range_ok ? 1 : 0) +
     (low_wick_body_ok ? 1 : 0) +
     (low_close_ok ? 1 : 0)

high_sweep_score =
     (range_ok ? 1 : 0) +
     (high_wick_range_ok ? 1 : 0) +
     (high_wick_body_ok ? 1 : 0) +
     (high_close_ok ? 1 : 0)

// Final sweep events used by engine
sweep_low =
     sweep_low_raw and
     (
         not eff_use_sweep_quality or
         low_sweep_score >= eff_min_sweep_score
     )

sweep_high =
     sweep_high_raw and
     (
         not eff_use_sweep_quality or
         high_sweep_score >= eff_min_sweep_score
     )

//━━━━━━━━━━━━━━━━━━
// PRICE EMA CONTEXT
//━━━━━━━━━━━━━━━━━━
ema34 = ta.ema(close, 34)

plot(
     show_ema34 ? ema34 : na,
     title="EMA 34",
     color=color.aqua,
     linewidth=2,
     force_overlay=true,
     display=display.all - display.status_line
)

//━━━━━━━━━━━━━━━━━━
// RSI ENGINE
//━━━━━━━━━━━━━━━━━━
fast_src = close
mid_src  = hlc3
slow_src = ta.ema(close, 13)

rsi_fast = ta.rsi(fast_src, fast_len)
rsi_mid  = ta.rsi(mid_src, mid_len)
rsi_slow = ta.rsi(slow_src, slow_len)

fast_sma = ta.sma(rsi_fast, fast_smooth)
slow_sma = ta.sma(rsi_slow, slow_smooth)

//━━━━━━━━━━━━━━━━━━
// RSI REGIME
//━━━━━━━━━━━━━━━━━━
bull_regime = rsi_slow > 50 and rsi_slow > slow_sma
bear_regime = rsi_slow < 50 and rsi_slow < slow_sma

//━━━━━━━━━━━━━━━━━━
// COMPRESSION ENGINE
//━━━━━━━━━━━━━━━━━━
rsi_spread_fast_mid = math.abs(rsi_fast - rsi_mid)
rsi_spread_mid_slow = math.abs(rsi_mid - rsi_slow)

compression =
     rsi_spread_fast_mid < eff_compression_tightness and
     rsi_spread_mid_slow < eff_compression_tightness

compression_start = compression and not compression[1]
compression_release = compression[1] and not compression

raw_expansion_up =
     compression_release and
     rsi_fast > rsi_mid and
     rsi_mid > rsi_slow

raw_expansion_down =
     compression_release and
     rsi_fast < rsi_mid and
     rsi_mid < rsi_slow

bull_momentum_release = raw_expansion_up and htf_long_ok
bear_momentum_release = raw_expansion_down and htf_short_ok

counter_bias_long = use_htf_bias and raw_expansion_up and htf_bear
counter_bias_short = use_htf_bias and raw_expansion_down and htf_bull

momentum_release_marker =
     bull_momentum_release or
     bear_momentum_release or
     counter_bias_long or
     counter_bias_short

compression_release_marker =
     compression_release and
     not (
         show_momentum_release and momentum_release_marker
     )

//━━━━━━━━━━━━━━━━━━
// MOMENTUM RECLAIM / REJECT SETUP
//━━━━━━━━━━━━━━━━━━
rsi_bull_stack = rsi_fast > rsi_mid and rsi_mid > rsi_slow
rsi_bear_stack = rsi_fast < rsi_mid and rsi_mid < rsi_slow

rsi_fast_reclaim = rsi_fast[1] < fast_sma[1] and rsi_fast > fast_sma
rsi_fast_reject  = rsi_fast[1] > fast_sma[1] and rsi_fast < fast_sma

wt_bull_reclaim_context =
     wt_reclaim_long and
     rsi_fast_reclaim

wt_bear_reject_context =
     wt_reject_short and
     rsi_fast_reject

//━━━━━━━━━━━━━━━━━━
// MOMENTUM RECLAIM / REJECT LAYER
//━━━━━━━━━━━━━━━━━━
// Early momentum reclaim/reject logic.
// Earlier than Flow Context and does not require sweep/displacement.

mid_hold_bull = rsi_mid > 45
mid_hold_bear = rsi_mid < 55

fast_cross_up = ta.crossover(rsi_fast, fast_sma)
fast_cross_down = ta.crossunder(rsi_fast, fast_sma)
rsi_sniper_reclaim_long = rsi_fast[1] < 30 and rsi_fast > 35
rsi_sniper_reject_short = rsi_fast[1] > 70 and rsi_fast < 65

degen_mtf_soft_ok =
     mtf_bull_1 or
     mtf_bull_2 or
     (
         mtf_bull_score >= 2 and
         mtf_bear_score <= 3
     )

degen_bars_since_sweep_low = ta.barssince(sweep_low)

degen_recent_sweep_low =
     not na(degen_bars_since_sweep_low) and
     degen_bars_since_sweep_low <= eff_flow_context_window

degen_sweep_low_high =
     ta.valuewhen(sweep_low, high, 0)

degen_sweep_displacement =
     degen_recent_sweep_low and
     not na(degen_sweep_low_high) and
     close > degen_sweep_low_high

degen_sweep_displacement_start =
     degen_sweep_displacement and
     not degen_sweep_displacement[1]

degen_ema_reclaim_start =
     close > ema34 and
     close[1] <= ema34[1] and
     close > high[1]

degen_local_high_reclaim =
     close > ta.highest(high, 3)[1]

degen_local_high_reclaim_start =
     degen_local_high_reclaim and
     not degen_local_high_reclaim[1]

degen_price_reclaim_start =
     degen_sweep_displacement_start or
     degen_ema_reclaim_start or
     (
         close > ema34 and
         degen_local_high_reclaim_start
     )

degen_bars_since_price_reclaim =
     ta.barssince(degen_price_reclaim_start)

degen_recent_price_reclaim =
     not na(degen_bars_since_price_reclaim) and
     degen_bars_since_price_reclaim <= 2

degen_early_bull_reclaim_raw =
     profile == "Degen Fast" and
     not bull_regime and
     degen_mtf_soft_ok and
     degen_recent_price_reclaim and
     mid_hold_bull and
     rsi_fast > fast_sma and
     rsi_mid > rsi_mid[1] and
     rsi_slow >= rsi_slow[1]

degen_early_bull_reclaim =
     degen_early_bull_reclaim_raw and
     not degen_early_bull_reclaim_raw[1]

bull_momentum_reclaim =
     bull_regime and
     mid_hold_bull and
     (
         fast_cross_up or
         rsi_sniper_reclaim_long
     )

bear_momentum_reject =
     bear_regime and
     mid_hold_bear and
     (
         fast_cross_down or
         rsi_sniper_reject_short
     )

bull_reclaim_event =
     bull_momentum_reclaim or
     wt_bull_reclaim_context or
     degen_early_bull_reclaim

degen_bear_reject_event =
     wt_bear_reject_context or
     (
         bear_momentum_reject and
         raw_expansion_down
     )

bear_reject_event =
     profile == "Degen Fast" ? degen_bear_reject_event :
     bear_momentum_reject or wt_bear_reject_context

//━━━━━━━━━━━━━━━━━━
// MOMENTUM RECLAIM / REJECT COOLDOWN
//━━━━━━━━━━━━━━━━━━
var int last_bull_reclaim_bar = na
var int last_bear_reject_bar = na

bull_reclaim_allowed =
     na(last_bull_reclaim_bar) or
     bar_index - last_bull_reclaim_bar > eff_bull_reclaim_cooldown

bear_reject_allowed =
     na(last_bear_reject_bar) or
     bar_index - last_bear_reject_bar > eff_bear_reject_cooldown

bull_reclaim_plot =
     bull_reclaim_event and
     bull_reclaim_allowed

bear_reject_plot =
     bear_reject_event and
     bear_reject_allowed

bull_reclaim_source_count =
     (bull_momentum_reclaim ? 1 : 0) +
     (wt_bull_reclaim_context ? 1 : 0) +
     (degen_early_bull_reclaim ? 1 : 0)

bear_reject_source_count =
     (bear_momentum_reject ? 1 : 0) +
     (wt_bear_reject_context ? 1 : 0)

bull_reclaim_src_rsi =
     show_reclaim_source_labels and
     bull_reclaim_plot and
     bull_reclaim_source_count == 1 and
     bull_momentum_reclaim

bull_reclaim_src_wt =
     show_reclaim_source_labels and
     bull_reclaim_plot and
     bull_reclaim_source_count == 1 and
     wt_bull_reclaim_context

bull_reclaim_src_degen =
     show_reclaim_source_labels and
     bull_reclaim_plot and
     bull_reclaim_source_count == 1 and
     degen_early_bull_reclaim

bear_reject_src_rsi =
     show_reclaim_source_labels and
     bear_reject_plot and
     bear_reject_source_count == 1 and
     bear_momentum_reject

bear_reject_src_wt =
     show_reclaim_source_labels and
     bear_reject_plot and
     bear_reject_source_count == 1 and
     wt_bear_reject_context

if bull_reclaim_plot
    last_bull_reclaim_bar := bar_index

if bear_reject_plot
    last_bear_reject_bar := bar_index

//━━━━━━━━━━━━━━━━━━
// MOMENTUM RECLAIM / REJECT HTF CLASSIFICATION
//━━━━━━━━━━━━━━━━━━
bull_reclaim_with_htf =
     bull_reclaim_plot and
     (
         not use_htf_bias or htf_bull
     )

bull_reclaim_counter =
     bull_reclaim_plot and
     use_htf_bias and
     htf_bear

bear_reject_with_htf =
     bear_reject_plot and
     (
         not use_htf_bias or htf_bear
     )

bear_reject_counter =
     bear_reject_plot and
     use_htf_bias and
     htf_bull

//━━━━━━━━━━━━━━━━━━
// FLOW CONTEXT WINDOW
//━━━━━━━━━━━━━━━━━━
bars_since_sweep_low = ta.barssince(sweep_low)
bars_since_sweep_high = ta.barssince(sweep_high)
bars_since_release = ta.barssince(compression_release)

recent_sweep_low =
     not na(bars_since_sweep_low) and
     bars_since_sweep_low <= eff_flow_context_window

recent_sweep_high =
     not na(bars_since_sweep_high) and
     bars_since_sweep_high <= eff_flow_context_window

recent_release =
     not na(bars_since_release) and
     bars_since_release <= eff_flow_context_window

//━━━━━━━━━━━━━━━━━━
// DISPLACEMENT AFTER SWEEP
//━━━━━━━━━━━━━━━━━━
// Bull displacement:
// after a quality sweep low, price closes above the high of the sweep candle.
//
// Bear displacement:
// after a quality sweep high, price closes below the low of the sweep candle.
sweep_low_high = ta.valuewhen(sweep_low, high, 0)
sweep_high_low = ta.valuewhen(sweep_high, low, 0)

bull_displacement =
     recent_sweep_low and
     not na(sweep_low_high) and
     close > sweep_low_high

bear_displacement =
     recent_sweep_high and
     not na(sweep_high_low) and
     close < sweep_high_low

//━━━━━━━━━━━━━━━━━━
// FLOW CONTEXT
//━━━━━━━━━━━━━━━━━━
// Base flow means:
// quality sweep + displacement + momentum context.
// HTF does not block the base signal anymore.
// HTF only classifies it as with-flow or counter-flow.

flow_long_base =
     recent_sweep_low and
     bull_displacement and
     (
         raw_expansion_up or
         bull_reclaim_event or
         (recent_release and rsi_bull_stack)
     )

flow_short_base =
     recent_sweep_high and
     bear_displacement and
     (
         raw_expansion_down or
         bear_reject_event or
         (recent_release and rsi_bear_stack)
     )

flow_long_with_htf =
     flow_long_base and
     (
         not use_htf_bias or htf_bull
     )

flow_short_with_htf =
     flow_short_base and
     (
         not use_htf_bias or htf_bear
     )

flow_long_counter =
     flow_long_base and
     use_htf_bias and
     htf_bear

flow_short_counter =
     flow_short_base and
     use_htf_bias and
     htf_bull

//━━━━━━━━━━━━━━━━━━
// FLOW CONTEXT COOLDOWN
//━━━━━━━━━━━━━━━━━━
flow_long_raw = flow_long_with_htf or flow_long_counter
flow_short_raw = flow_short_with_htf or flow_short_counter

long_raw_start = flow_long_raw and not flow_long_raw[1]
short_raw_start = flow_short_raw and not flow_short_raw[1]

var int last_long_context_bar = na
var int last_short_context_bar = na

long_context_allowed =
     na(last_long_context_bar) or
     bar_index - last_long_context_bar > eff_context_cooldown

short_context_allowed =
     na(last_short_context_bar) or
     bar_index - last_short_context_bar > eff_context_cooldown

flow_long_context =
     long_raw_start and
     long_context_allowed

flow_short_context =
     short_raw_start and
     short_context_allowed

if flow_long_context
    last_long_context_bar := bar_index

if flow_short_context
    last_short_context_bar := bar_index

bull_flow_context =
     flow_long_context and flow_long_with_htf

bull_counter_context =
     flow_long_context and flow_long_counter

bear_flow_context =
     flow_short_context and flow_short_with_htf

bear_counter_context =
     flow_short_context and flow_short_counter

//━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━
// These are context alerts, not standalone trade instructions.
// For cleaner behavior, use bar-close alerts in TradingView.

alertcondition(
     bull_flow_context,
     title="Hamppu Bull Flow Context",
     message="Hamppu Bull Flow Context on {{ticker}} {{interval}}"
)

alertcondition(
     bear_flow_context,
     title="Hamppu Bear Flow Context",
     message="Hamppu Bear Flow Context on {{ticker}} {{interval}}"
)

alertcondition(
     bull_counter_context,
     title="Hamppu Bull Counter-flow Context",
     message="Hamppu Bull Counter-flow Context on {{ticker}} {{interval}}"
)

alertcondition(
     bear_counter_context,
     title="Hamppu Bear Counter-flow Context",
     message="Hamppu Bear Counter-flow Context on {{ticker}} {{interval}}"
)

alertcondition(
     bull_reclaim_with_htf,
     title="Hamppu Bull Momentum Reclaim",
     message="Hamppu Bull Momentum Reclaim on {{ticker}} {{interval}}"
)

alertcondition(
     bear_reject_with_htf,
     title="Hamppu Bear Momentum Reject",
     message="Hamppu Bear Momentum Reject on {{ticker}} {{interval}}"
)

alertcondition(
     bull_momentum_release,
     title="Hamppu Bull Momentum Release",
     message="Hamppu Bull Momentum Release on {{ticker}} {{interval}}"
)

alertcondition(
     bear_momentum_release,
     title="Hamppu Bear Momentum Release",
     message="Hamppu Bear Momentum Release on {{ticker}} {{interval}}"
)

mtf_strong_bull_shift =
     mtf_bull_score >= mtf_strong_threshold and
     mtf_bull_score[1] < mtf_strong_threshold

mtf_strong_bear_shift =
     mtf_bear_score >= mtf_strong_threshold and
     mtf_bear_score[1] < mtf_strong_threshold

alertcondition(
     mtf_strong_bull_shift,
     title="Hamppu MTF Strong Bull Shift",
     message="Hamppu MTF Flow shifted to Strong Bull on {{ticker}} {{interval}}"
)

alertcondition(
     mtf_strong_bear_shift,
     title="Hamppu MTF Strong Bear Shift",
     message="Hamppu MTF Flow shifted to Strong Bear on {{ticker}} {{interval}}"
)

//━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━
plot(
     rsi_fast,
     title="Fast RSI",
     color=color.purple,
     display=display.none
)
plot(
     fast_sma,
     title="Fast RSI Smooth",
     color=color.white,
     display=display.none
)

plot(rsi_mid, title="Mid RSI", color=color.blue, display=display.none)

plot(
     rsi_slow,
     title="Slow RSI",
     color=color.green,
     display=display.pane
)
plot(
     slow_sma,
     title="Slow RSI Smooth",
     color=color.orange,
     display=display.pane
)

plot(
     wt1,
     title="WT1",
     color=color.new(color.lime, 0),
     display=show_wt_lines ? display.pane : display.none,
     editable=false
)

plot(
     wt2,
     title="WT2",
     color=color.new(color.red, 0),
     display=show_wt_lines ? display.pane : display.none,
     editable=false
)

hline(70, "Upper RSI", color=color.gray)
hline(50, "Midline", color=color.gray)
hline(30, "Lower RSI", color=color.gray)

hline(stretch_ob, "WT Stretch High", color=color.new(color.red, 60), display=display.none)
hline(stretch_os, "WT Stretch Low", color=color.new(color.lime, 60), display=display.none)

//━━━━━━━━━━━━━━━━━━
// MARKER LANGUAGE
//━━━━━━━━━━━━━━━━━━
// Triangle = early momentum reclaim/reject context
// Circle   = RSI compression released directionally.
// X        = compression ended.
// Heart    = stronger Flow Context: quality sweep + displacement + momentum.
// Orange   = counter-flow / HTF disagreement.
//
// These markers are context events, not standalone trade signals.

//━━━━━━━━━━━━━━━━━━
// VISUAL MARKERS
//━━━━━━━━━━━━━━━━━━
// Compression Start - optional only
plotshape(show_coil_start_active and compression_start,
     title="Coil Start",
     location=location.bottom,
     color=color.yellow,
     style=shape.circle,
     size=size.tiny,
     display=display.pane)

plotshape(show_compression_release and compression_release_marker,
     title="Compression Release",
     location=location.bottom,
     color=color.rgb(250, 145, 236),
     style=shape.xcross,
     size=size.tiny,
     display=display.pane)

// Bull / Bear Momentum Release
plotshape(show_momentum_release and bull_momentum_release,
     title="Bull Momentum Release",
     location=location.bottom,
     color=color.lime,
     style=shape.circle,
     size=size.small,
     display=display.pane)

plotshape(show_momentum_release and bear_momentum_release,
     title="Bear Momentum Release",
     location=location.top,
     color=color.red,
     style=shape.circle,
     size=size.small,
     display=display.pane)

// Counter-flow Momentum Release
plotshape(show_momentum_release and counter_bias_long,
     title="Counter-flow Bull Momentum Release",
     location=location.bottom,
     color=color.rgb(158, 129, 164),
     style=shape.circle,
     size=size.tiny,
     display=display.pane)

plotshape(show_momentum_release and counter_bias_short,
     title="Counter-flow Bear Momentum Release",
     location=location.top,
     color=color.rgb(158, 129, 164),
     style=shape.circle,
     size=size.tiny,
     display=display.pane)

plotshape(show_reclaim_reject and bull_reclaim_with_htf,
     title="Bull Momentum Reclaim",
     location=location.bottom,
     color=color.lime,
     style=shape.triangleup,
     size=size.tiny,
     display=display.pane)

plotshape(show_reclaim_reject and bull_reclaim_counter,
     title="Counter-flow Bull Momentum Reclaim",
     location=location.bottom,
     color=color.orange,
     style=shape.triangleup,
     size=size.tiny,
     display=display.pane)

plotshape(show_reclaim_reject and bear_reject_with_htf,
     title="Bear Momentum Reject",
     location=location.top,
     color=color.red,
     style=shape.triangledown,
     size=size.tiny,
     display=display.pane)

plotshape(show_reclaim_reject and bear_reject_counter,
     title="Counter-flow Bear Momentum Reject",
     location=location.top,
     color=color.orange,
     style=shape.triangledown,
     size=size.tiny,
     display=display.pane)

// Quality Sweeps - optional research layer
plotshape(show_quality_sweeps_active and sweep_low,
     title="Quality Sweep Low",
     location=location.bottom,
     color=color.aqua,
     style=shape.circle,
     size=size.tiny,
     display=display.pane)

plotshape(show_quality_sweeps_active and sweep_high,
     title="Quality Sweep High",
     location=location.top,
     color=color.aqua,
     style=shape.circle,
     size=size.tiny,
     display=display.pane)

// Flow Context - main liquidity/momentum context marker
plotchar(show_flow_context and bull_flow_context,
     title="Bull Flow Context",
     char="♥",
     location=location.bottom,
     color=color.lime,
     size=size.small,
     display=display.pane)

plotchar(show_flow_context and bull_counter_context,
     title="Bull Counter-flow Context",
     char="♥",
     location=location.bottom,
     color=color.orange,
     size=size.small,
     display=display.pane)

plotchar(show_flow_context and bear_flow_context,
     title="Bear Flow Context",
     char="♥",
     location=location.top,
     color=color.red,
     size=size.small,
     display=display.pane)

plotchar(show_flow_context and bear_counter_context,
     title="Bear Counter-flow Context",
     char="♥",
     location=location.top,
     color=color.orange,
     size=size.small,
     display=display.pane)

plotchar(bull_reclaim_src_rsi,
     title="Bull Reclaim Source RSI",
     char="R",
     location=location.bottom,
     color=color.white,
     size=size.tiny,
     display=display.pane)

plotchar(bull_reclaim_src_wt,
     title="Bull Reclaim Source WT",
     char="W",
     location=location.bottom,
     color=color.aqua,
     size=size.tiny,
     display=display.pane)

plotchar(bull_reclaim_src_degen,
     title="Bull Reclaim Source Degen",
     char="D",
     location=location.bottom,
     color=color.orange,
     size=size.tiny,
     display=display.pane)

plotchar(bear_reject_src_rsi,
     title="Bear Reject Source RSI",
     char="R",
     location=location.top,
     color=color.white,
     size=size.tiny,
     display=display.pane)

plotchar(bear_reject_src_wt,
     title="Bear Reject Source WT",
     char="W",
     location=location.top,
     color=color.aqua,
     size=size.tiny,
     display=display.pane)

//━━━━━━━━━━━━━━━━━━
// BACKGROUND REGIME
//━━━━━━━━━━━━━━━━━━
bgcolor(bull_regime ? color.new(color.green, 92) : na,
     title="Bull Regime Background")

bgcolor(bear_regime ? color.new(color.red, 92) : na,
     title="Bear Regime Background")

bgcolor(compression ? color.new(color.yellow, 92) : na,
     title="Compression Background")

//━━━━━━━━━━━━━━━━━━
// MTF FLOW STACK TABLE
//━━━━━━━━━━━━━━━━━━
mtf_header_color =
     mtf_bull_score >= mtf_strong_threshold ? color.new(color.green, 70) :
     mtf_bear_score >= mtf_strong_threshold ? color.new(color.red, 70) :
     mtf_bull_score > mtf_bear_score ? color.new(color.green, 80) :
     mtf_bear_score > mtf_bull_score ? color.new(color.red, 80) :
     color.new(color.gray, 70)

f_mtf_table_position(_pos) =>
    if _pos == "Top Right"
        position.top_right
    else if _pos == "Middle Right"
        position.middle_right
    else if _pos == "Bottom Right"
        position.bottom_right
    else if _pos == "Top Left"
        position.top_left
    else if _pos == "Middle Left"
        position.middle_left
    else if _pos == "Bottom Left"
        position.bottom_left
    else
        position.top_right

mtf_table_position = f_mtf_table_position(mtf_table_position_input)

var table mtf_table = table.new(
     mtf_table_position,
     2,
     8,
     frame_color=color.new(color.gray, 80),
     frame_width=1
)

f_mtf_header_row() =>
    table.cell(
         mtf_table,
         0,
         0,
         "MTF Flow",
         text_color=color.white,
         bgcolor=color.new(color.black, 15)
    )

    table.cell(
         mtf_table,
         1,
         0,
         mtf_context_label,
         text_color=color.white,
         bgcolor=mtf_header_color
    )

f_mtf_data_row(_row, _tf, _rsi, _delta) =>
    table.cell(
         mtf_table,
         0,
         _row,
         f_tf_label(_tf),
         text_color=color.white,
         bgcolor=color.new(color.black, 40)
    )

    table.cell(
         mtf_table,
         1,
         _row,
         f_mtf_cell(_rsi, _delta),
         text_color=color.white,
         bgcolor=f_mtf_color(_rsi)
    )

f_mtf_role_row(_row) =>
    table.cell(
         mtf_table,
         0,
         _row,
         "Role",
         text_color=color.white,
         bgcolor=color.new(color.black, 40)
    )

    table.cell(
         mtf_table,
         1,
         _row,
         "Context",
         text_color=color.white,
         bgcolor=color.new(color.blue, 80)
    )

f_clear_mtf_table() =>
    for _row = 0 to 7
        table.cell(mtf_table, 0, _row, "", bgcolor=color.new(color.black, 100))
        table.cell(mtf_table, 1, _row, "", bgcolor=color.new(color.black, 100))

if barstate.islast
    if show_mtf_stack
        f_clear_mtf_table()
        f_mtf_header_row()

        f_mtf_data_row(1, mtf_tf_1, mtf_rsi_1, mtf_delta_1)
        f_mtf_data_row(2, mtf_tf_2, mtf_rsi_2, mtf_delta_2)
        f_mtf_data_row(3, mtf_tf_3, mtf_rsi_3, mtf_delta_3)

        if mtf_active_4
            f_mtf_data_row(4, mtf_tf_4, mtf_rsi_4, mtf_delta_4)

        if mtf_active_5
            f_mtf_data_row(5, mtf_tf_5, mtf_rsi_5, mtf_delta_5)

        if mtf_active_6
            f_mtf_data_row(6, mtf_tf_6, mtf_rsi_6, mtf_delta_6)

        f_mtf_role_row(mtf_active_count + 1)
    else
        f_clear_mtf_table()
````
