# NEXUS Signal Engine

- url: https://www.tradingview.com/script/XJ5etL13-NEXUS-Signal-Engine/
- type: indicator
- pine_id: PUB;7cb6e30a8fb245f68ab634fadeb26412
- version: 3.0

## Description

N[b]EXUS Signal Engine [/b]
Confluence Trading System

[b]OVERVIEW[/b]
NEXUS Signal Engine (NSE) is a multi-indicator confluence system designed for cryptocurrency and futures markets. It combines six established open-source technical analysis components — credited in full below — into a unified signal framework featuring an original state-machine trade lifecycle, dual signal architecture (Grand + Trend), multi-symbol AutoTrend filtering, automated exit management (Stop / TP1 / TP2 / Breakeven / Trailing Stop), a structured alert system with JSON output, and an on-chart simulation table for historical review.
The core concept: rather than monitoring six separate indicators and manually assessing their agreement, NSE merges them into a single confluence score. When enough components align, the engine generates an entry signal and then tracks that signal from entry to exit through a rule-based state machine — all within one overlay indicator.

[b]CREDITS AND ACKNOWLEDGMENTS[/b]
This indicator is built upon the following open-source works from the TradingView community. Full credit and sincere thanks to the original authors:
[list]
[*][b]Section 1: [/b]"Pivot Point SuperTrend" by LonesomeTheBlue
[*][b]Section 2: [/b]"SuperTrend" by KivancOzbilgic
[*][b]Section 3: [/b]"Chandelier Exit" by everget
[*][b]Section 4: [/b]"Twin Range Filter" by colinmck
[*][b]Section 5: [/b]"RSI Bands, RSI %B and RSI Bandwidth" by LazyBear
[*][b]Section 6: [/b]"WaveTrend with Crosses" by LazyBear
[/list]
These six components provide the foundational signal inputs. All additional logic — including the confluence scoring engine, state machine architecture, trade lifecycle management, exit logic (TP1/TP2/Breakeven/Trailing), AutoTrend multi-symbol filter, Symbol EMA filter, dual signal system, alert dispatch architecture, simulation table, and theme/mobile system — represents original work.
[b]
RECOMMENDED CHART SETUP[/b]
https://www.tradingview.com/x/d1nJvZpI/
This indicator is designed for use with Heikin Ashi candles for cleaner signal generation and smoother trend visualization.
[list]
[*][b]Step 1 — Switch to Heikin Ashi candles: [/b]Open your chart, click the candle type dropdown in the top toolbar, and select Heikin Ashi.
[*][b]Step 2 — Hide the default candle visuals:[/b] Double-click on any candle, or click the gear icon next to the symbol name. Go to the "Style" tab. Uncheck all three boxes: Body, Borders, and Wick. Click OK. This allows NSE's own HA overlay to render cleanly.
[*][b]Step 3 — Bring NSE to front: [/b]Right-click on the indicator on the chart. Select "Visual Order" then "Bring to Front". This ensures NSE's Heikin Ashi candles, RSI bands, and signal labels render above all other elements.
[/list]

[b]HOW THE SIGNAL ENGINE WORKS[/b]
NSE uses a quad-indicator confluence framework. Four independent sub-indicators run simultaneously:
[list]
[*][b]1. Pivot Point SuperTrend — [/b]Dynamic support/resistance using pivot-centered ATR bands
[*][b]2. Classic SuperTrend — [/b]Volatility-based trend detection with configurable ATR multiplier
[*][b]3. Chandelier Exit — [/b]Trailing volatility stop for trend confirmation
[*][b]4. Twin Range Filter — [/b]Dual-period noise filter using smoothed range calculations
[/list]
When a configurable minimum number of these four components fire within a signal bar window — combined with additional filters (RSI Band touch, WaveTrend zone visit) — the engine generates a signal.

[b]SIGNAL TYPES[/b]
[b]Grand Signals: [/b]Higher-confluence signals requiring agreement across all four sub-indicators, RSI band touch, and WaveTrend extreme zone visit. These represent the strongest alignment conditions the engine can detect.
[b]Trend Signals: [/b]Macro-trend-aligned entries. Fire when the AutoTrend filter confirms direction, price touches its RSI entry band, and optional Symbol EMA and WaveTrend filters pass. If a Grand signal fires on the same bar, the Trend signal is suppressed.

[b]ENTRY AND EXIT MECHANICS[/b]
[b]Entry: [/b]Confirmed at bar close when all signal conditions are met. Entry price, stop level, and TP1 target are drawn on the chart immediately.
[b]Stop Level — [/b]Grand signals: Lowest low (longs) or highest high (shorts) over the past N bars (configurable lookback).
[b]Stop Level — [/b]Trend signals: ATR-based stop with a configurable multiplier.
[b]TP1 Target: [/b]Dynamic RSI TP band that updates each bar, adapting to market conditions rather than using a fixed-distance level.
[b]After TP1 is reached:[/b]
[list]
[*]TP1 Close Percentage = 100%: Full position closes at TP1. Signal is complete.
[*]TP1 Close Percentage = 50% or 75%: Partial close at TP1. The remaining portion enters a trailing phase:
[quote]Stop moves to breakeven (entry price)
ATR-based trailing stop activates
If trailing stop is hit: TP2 exit (remaining position closes)
If breakeven is hit: position closes at entry price (TP1 gains are preserved)[/quote]

[b]EFFECT OF AUTOTREND FILTERING[/b]
The AutoTrend filter uses an external reference symbol across two configurable timeframes with EMA alignment to determine macro market direction.
[b]Bull condition: [/b]Reference symbol's close is above its EMA on both selected timeframes.
[b]Bear condition:[/b] Reference symbol's close is below its EMA on both selected timeframes.
The filtering strength parameter controls how strictly this directional condition must be satisfied before signals are allowed through.
[b]Off (No filtering): [/b]
https://www.tradingview.com/x/gUEvXs3Z/
AutoTrend filtering is disabled. The engine generates signals in both directions regardless of macro environment. Signal frequency is highest. This mode is suited to short-term or range-bound conditions where macro direction is less relevant, but the risk of counter-trend entries increases.

[b]Low (Mild filtering): [/b]
https://www.tradingview.com/x/UBbgZLZN/
Minor noise and small counter-trend price moves are suppressed while the indicator remains responsive to directional changes. Suitable for intraday timeframes with moderate trend clarity.

[b]Medium (Recommended default): [/b]
https://www.tradingview.com/x/Pbd0JsrA/
Balanced filtering. Provides the most practical trade-off between signal reactivity and noise reduction. Works well across most instruments and timeframes. Trend reversals are captured with reasonable lag and improved reliability compared to lower settings.

[b]High (Strict filtering): [/b]
https://www.tradingview.com/x/67HYrUlz/
Only clearly established trend conditions generate signals. Signal frequency decreases while the conditions for each signal become more stringent. Suited to higher timeframes, swing trading approaches, or periods of elevated volatility where avoiding false reversals takes priority.

[b]High– Grand Only[/b]
https://www.tradingview.com/x/2ilW8UKE/

[b]Common reference symbol options:[/b]
[b]Alt. Referans (ETH.D – Medium)[/b]
https://www.tradingview.com/x/QTlaokVQ/
BTCUSDT, BTC.D, USDT.D, TOTAL, TOTAL2, TOTAL3, OTHERS.D, SPX500, DXY, NDX, US100, XU100, XU30

[b]Alt. Referans (ETH.D – High EMA)[/b]
https://www.tradingview.com/x/eFJzfmKG/

[b]Recommended timeframe combinations based on your chart:[/b]
[*][b]15-minute charts: [/b]TF1 = 60 (1H), TF2 = 240 (4H)
[*][b]1-hour charts: TF1 = [/b]240 (4H), TF2 = D (Daily)
[*][b]4-hour charts: [/b]TF1 = D (Daily), TF2 = D (Daily) with a longer EMA period
[b]The AutoTrend filter[/b] can be applied to Grand signals only, Trend signals only, or both — configurable via the [b]"Apply AutoTrend Filter to Grand Signals" [/b]toggle.

[b]SYMBOL EMA FILTER[/b]
Independent of the AutoTrend system. Applies a local EMA directly to the current symbol's price. When active:
[b][*]Trend Buy signals require: close > Symbol EMA[/b]
[b][*]Trend Sell signals require: close < Symbol EMA[/b]
This provides an additional fast local trend confirmation layered on top of the macro AutoTrend direction.

[b]ALERT SYSTEM[/b]
NSE includes a structured alert system covering all signal events:
[*][b]Entry alerts:[/b] LONG / SHORT (separate for Grand and Trend signals)
[*][b]Exit alerts: [/b]TP1 Partial, TP1 Full, TP2 Trailing, Stop Loss, Breakeven
All alerts output structured JSON, making them compatible with webhook-based automation. Each alert type has independent enable/disable toggles and frequency settings [b](Once Per Bar / Once Per Bar Close).[/b]
[b]Setup: [/b]Add the indicator to your chart, click "Create Alert", select "Any alert() function call" as the condition, and configure your webhook URL if using external automation.

[b]SIGNAL SIMULATION TABLE[/b]
The on-chart table displays a historical signal review based on past bar data. All values are expressed in units (u) based on the configurable [b]Risk Unit[/b] parameter.
[b]How units work: [/b]Each stop hit equals the negative value of the risk unit [b](e.g., -100u at default settings).[/b] TP1 and TP2 outcomes vary based on the actual distance between entry and the RSI TP band at that time. This unit-based framework allows signal quality to be assessed independently of position sizing.
[b]The table includes:[/b]
[*]TP1 Rate: percentage of signals that reached the TP1 level
[*]TP1 / TP2 / Stop / Breakeven counts with unit-based outcomes
[*]Average R-Multiple across completed signals
[*]Grand vs Trend breakdown with separate metrics for each signal type
[*]Maximum consecutive win and loss streaks
[*]Lookback window: Last 10, 20, 50, 100, or All signals
Parameters that meaningfully affect simulation characteristics include RSI OB/OS levels, Stop Lookback, WT Lookback, Trend ATR Multiplier, and Symbol EMA Period. Small adjustments to these can shift signal behavior for specific instruments and timeframes.

[b]CUSTOMIZATION OPTIONS[/b]
[b]Visual:[/b] 5 color presets (Classic, Aqua, Cosmic, Ember, Neon) with Dark/Light theme support. Mobile/Tablet mode for smaller screens.
[b]Parameters: [/b]Every sub-indicator period, multiplier, and threshold is individually configurable. Default values provide a general starting point; optimal settings vary by symbol and timeframe.
[b]Stop and TP: [/b]Configurable trigger modes (Wick vs Close) for stop loss, TP1, and trailing stop independently. TP1 close percentage (50% / 75% / 100%). Trailing ATR multiplier.
[b]Lines: [/b]Entry, Stop, TP1, Breakeven, and Trailing stop line colors and widths are all adjustable.

[b]TECHNICAL NOTES[/b]
[*]Uses request.security() with close[1] and lookahead_on for confirmed higher-timeframe data to avoid repainting.
[*]State machine with 5 states: 0 = flat, 1 = long TP1 phase, -1 = short TP1 phase, 2 = long trailing, -2 = short trailing.
[*]The TP1 level follows the RSI TP band dynamically each bar.
[*]Stop levels are fixed at entry and do not move (Grand: swing-based, Trend: ATR-based).
[*]Heikin Ashi candles are calculated internally and are not derived from chart HA values.

[b]DISCLAIMER[/b]

[b]This indicator is published for educational and analytical purposes only. It does not constitute financial advice.[/b]
[*]The signal simulation table uses a simplified fixed-risk model expressed in abstract units (u). It does not account for slippage, commissions, spreads, liquidity, funding rates, or real-world execution conditions.
[*]Simulation results are shown in units (u), not real currency.
[*]Historical signal behavior does not predict or guarantee future results.
[*]This is an indicator, not a strategy — it identifies historical confluence conditions based on past price data.
[*]All trading involves substantial risk of loss.
[*]Conduct your own independent analysis before making any trading decisions.
[*]The author assumes no responsibility for financial decisions made using this tool.
[b]Use this indicator as one analytical input among others, not as a standalone decision-making system.[/b]

## Source Code

````pine
//@version=5
// ╔══════════════════════════════════════════════════════════════════╗
// ║                  **  NEXUS SIGNAL ENGINE **                      ║
// ║             Designed by @alpprofitmax 🅰🅻🅿 🇹🇷                   ║
// ║       ----------------------------------------------------       ║
// ║  This indicator is a comprehensive Confluence Trading System     ║
// ║  developed for educational purposes and advanced analysis.       ║
// ╚══════════════════════════════════════════════════════════════════╝

indicator("NEXUS Signal Engine 🅰🅻🅿", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
// COLOR PRESET & THEME
// ═══════════════════════════════════════════════════════════════════
themeMode  = input.string("Dark", title="Theme",
     options=["Dark","Light"],
     group="🎨 Theme & Colors",
     tooltip="Select the chart theme. 'Dark' uses vivid colors on dark backgrounds. 'Light' adjusts colors for visibility on white/light backgrounds.")

colorPreset = input.string("Aqua", title="Color Preset",
     options=["Classic","Aqua","Cosmic","Ember","Neon"],
     group="🎨 Theme & Colors",
     tooltip="Choose a color palette for bullish/bearish/neutral elements. Each preset offers a distinct visual style.")

mobileMode = input.bool(false, title="Mobile / Tablet Mode",
     group="🎨 Theme & Colors",
     tooltip="Enable for smaller screens. Shrinks table text, shortens labels, and compacts the stats table for phones and tablets.")

isDark = themeMode == "Dark"

// ── Dark theme palettes ──
[darkBull, darkBear, darkNeutral] = switch colorPreset
    "Classic" => [color.lime, color.new(#ff3535,0), color.rgb(128,128,128)]
    "Aqua"    => [color.rgb(0,191,255), color.rgb(255,140,0), color.rgb(127,127,127)]
    "Cosmic"  => [color.rgb(73,255,206), color.rgb(153,50,204), color.rgb(106,90,205)]
    "Ember"   => [color.rgb(255,102,0), color.rgb(0,204,204), color.rgb(153,153,153)]
    "Neon"    => [color.rgb(255,255,0), color.rgb(255,0,255), color.rgb(0,255,0)]
    =>           [color.rgb(0,191,255), color.rgb(255,140,0), color.rgb(127,127,127)]

// ── Light theme palettes (deeper / more saturated for white BG) ──
[lightBull, lightBear, lightNeutral] = switch colorPreset
    "Classic" => [color.rgb(0,150,0), color.rgb(200,0,0), color.rgb(100,100,100)]
    "Aqua"    => [color.rgb(0,120,200), color.rgb(210,90,0), color.rgb(110,110,110)]
    "Cosmic"  => [color.rgb(0,160,130), color.rgb(120,30,170), color.rgb(80,70,160)]
    "Ember"   => [color.rgb(200,70,0), color.rgb(0,150,150), color.rgb(120,120,120)]
    "Neon"    => [color.rgb(180,160,0), color.rgb(180,0,180), color.rgb(0,140,0)]
    =>           [color.rgb(0,120,200), color.rgb(210,90,0), color.rgb(110,110,110)]

presetBull    = isDark ? darkBull    : lightBull
presetBear    = isDark ? darkBear    : lightBear
presetNeutral = isDark ? darkNeutral : lightNeutral

trendBullColor = isDark ? color.rgb(0, 230, 255) : color.rgb(0, 130, 190)
trendBearColor = isDark ? color.rgb(180, 0, 255) : color.rgb(130, 0, 190)

// ═══════════════════════════════════════════════════════════════════
// HEIKIN ASHI
// ═══════════════════════════════════════════════════════════════════
ha_on = input.bool(true, title="Show Heikin Ashi Candles", group="🕯️ Heikin Ashi Candles",
     tooltip="Enable/disable Heikin Ashi candle overlay. HA candles smooth price action and help identify trends more clearly.")

ha_close = math.avg(open, high, low, close)
var float ha_open = na
ha_open  := na(ha_open[1]) ? math.avg(open, close) : math.avg(ha_open[1], ha_close[1])
ha_high   = math.max(high, math.max(ha_open, ha_close))
ha_low    = math.min(low,  math.min(ha_open, ha_close))
ha_bull   = ha_close >= ha_open

plotcandle(ha_on ? ha_open : na, ha_on ? ha_high : na, ha_on ? ha_low : na, ha_on ? ha_close : na,
     title="HA Candles", color=ha_bull ? presetBull : presetBear,
     wickcolor=ha_bull ? color.new(presetBull,40) : color.new(presetBear,40),
     bordercolor=ha_bull ? presetBull : presetBear)

// ═══════════════════════════════════════════════════════════════════
// 1. PIVOT POINT SUPERTREND
// ═══════════════════════════════════════════════════════════════════
pp_prd    = input.int(1,     title="Pivot Period",  minval=1, maxval=50,  group="1 · Pivot Point SuperTrend",
     tooltip="Number of bars on each side to identify pivot highs/lows. Lower values react faster; higher values produce smoother pivots.")
pp_factor = input.float(1.0, title="ATR Factor",   minval=0.1, step=0.1, group="1 · Pivot Point SuperTrend",
     tooltip="Multiplier applied to ATR for calculating the SuperTrend bands around pivot centers. Higher values widen the channel.")
pp_pd     = input.int(1,     title="ATR Period",   minval=1,              group="1 · Pivot Point SuperTrend",
     tooltip="Lookback period for ATR calculation in the Pivot Point SuperTrend. Shorter periods make ATR more responsive.")

float ph = ta.pivothigh(pp_prd, pp_prd)
float pl = ta.pivotlow(pp_prd, pp_prd)
var float pp_center = na
float lastpp = not na(ph) ? ph : not na(pl) ? pl : na
if not na(lastpp)
    pp_center := na(pp_center) ? lastpp : (pp_center * 2 + lastpp) / 3
pp_Up  = pp_center - (pp_factor * ta.atr(pp_pd))
pp_Dn  = pp_center + (pp_factor * ta.atr(pp_pd))
var float pp_TUp   = na
var float pp_TDown = na
var int   pp_Trend = 0
pp_TUp   := nz(close[1]) > nz(pp_TUp[1])   ? math.max(pp_Up, nz(pp_TUp[1]))   : pp_Up
pp_TDown := nz(close[1]) < nz(pp_TDown[1]) ? math.min(pp_Dn, nz(pp_TDown[1])) : pp_Dn
pp_Trend := close > nz(pp_TDown[1]) ? 1 : close < nz(pp_TUp[1]) ? -1 : nz(pp_Trend,1)
pp_buy  = pp_Trend ==  1 and pp_Trend[1] == -1
pp_sell = pp_Trend == -1 and pp_Trend[1] ==  1

// ═══════════════════════════════════════════════════════════════════
// 2. SUPERTREND
// ═══════════════════════════════════════════════════════════════════
st_period = input.int(10,     title="ATR Period",     minval=1,             group="2 · Supertrend",
     tooltip="ATR lookback period for the classic SuperTrend indicator. Longer periods produce smoother trend lines.")
st_src    = input.source(hl2, title="Source",                               group="2 · Supertrend",
     tooltip="Price source for SuperTrend calculation. HL2 (midpoint of high and low) is the standard choice.")
st_mult   = input.float(1.0,  title="ATR Multiplier", minval=0.1, step=0.1, group="2 · Supertrend",
     tooltip="ATR multiplier for SuperTrend bands. Higher values create wider bands and fewer signal flips.")

st_atr = ta.atr(st_period)
st_up  = st_src - (st_mult * st_atr)
st_dn  = st_src + (st_mult * st_atr)
var float st_up1   = na
var float st_dn1   = na
var int   st_trend = 1
st_up1   := nz(close[1]) > nz(st_up1[1]) ? math.max(st_up, nz(st_up1[1])) : st_up
st_dn1   := nz(close[1]) < nz(st_dn1[1]) ? math.min(st_dn, nz(st_dn1[1])) : st_dn
st_trend := nz(st_trend[1], 1)
st_trend := st_trend == -1 and close > nz(st_dn1[1]) ? 1 : st_trend == 1 and close < nz(st_up1[1]) ? -1 : st_trend
st_buy  = st_trend ==  1 and st_trend[1] == -1
st_sell = st_trend == -1 and st_trend[1] ==  1

// ═══════════════════════════════════════════════════════════════════
// 3. CHANDELIER EXIT
// ═══════════════════════════════════════════════════════════════════
ce_length = input.int(1,     title="ATR Period",     minval=1,             group="3 · Chandelier Exit",
     tooltip="ATR lookback for Chandelier Exit. This determines how many bars are used to compute volatility-based trailing stops.")
ce_mult   = input.float(1.5, title="ATR Multiplier", minval=0.1, step=0.1, group="3 · Chandelier Exit",
     tooltip="Multiplier applied to ATR for the Chandelier Exit trailing distance. Higher values keep stops further from price.")

ce_atr           = ce_mult * ta.atr(ce_length)
ce_longStop      = ta.highest(close, ce_length) - ce_atr
ce_longStopPrev  = nz(ce_longStop[1], ce_longStop)
ce_longStop     := close[1] > ce_longStopPrev ? math.max(ce_longStop, ce_longStopPrev) : ce_longStop
ce_shortStop     = ta.lowest(close, ce_length) + ce_atr
ce_shortStopPrev = nz(ce_shortStop[1], ce_shortStop)
ce_shortStop    := close[1] < ce_shortStopPrev ? math.min(ce_shortStop, ce_shortStopPrev) : ce_shortStop
var int ce_dir   = 1
ce_dir := close > ce_shortStopPrev ? 1 : close < ce_longStopPrev ? -1 : ce_dir
ce_buy  = ce_dir ==  1 and ce_dir[1] == -1
ce_sell = ce_dir == -1 and ce_dir[1] ==  1

// ═══════════════════════════════════════════════════════════════════
// 4. TWIN RANGE FILTER
// ═══════════════════════════════════════════════════════════════════
trf_src   = input.source(close, title="Source",      group="4 · Twin Range Filter",
     tooltip="Price source for the Twin Range Filter calculation.")
trf_per1  = input.int(12,    title="Fast Period", minval=1,             group="4 · Twin Range Filter",
     tooltip="Period for the fast smoothed range. Shorter periods make the filter more reactive to recent price changes.")
trf_mult1 = input.float(1.0, title="Fast Range",  minval=0.1, step=0.1, group="4 · Twin Range Filter",
     tooltip="Multiplier for the fast range component. Increasing this widens the filter's noise threshold.")
trf_per2  = input.int(4,     title="Slow Period", minval=1,             group="4 · Twin Range Filter",
     tooltip="Period for the slow smoothed range. Longer periods capture broader market structure.")
trf_mult2 = input.float(2.0, title="Slow Range",  minval=0.1, step=0.1, group="4 · Twin Range Filter",
     tooltip="Multiplier for the slow range component. Works with the fast range to define the combined noise filter.")

trf_smoothrng(x, t, m) => ta.ema(ta.ema(math.abs(x - x[1]), t), t * 2 - 1) * m
trf_smrng = (trf_smoothrng(trf_src,trf_per1,trf_mult1) + trf_smoothrng(trf_src,trf_per2,trf_mult2)) / 2
trf_rngfilt(x, r) =>
    var float f = na
    f := x > nz(f[1]) ? (x - r < nz(f[1]) ? nz(f[1]) : x - r) : (x + r > nz(f[1]) ? nz(f[1]) : x + r)
    f
trf_filt = trf_rngfilt(trf_src, trf_smrng)
var float trf_upward   = 0.0
var float trf_downward = 0.0
trf_upward   := trf_filt > trf_filt[1] ? nz(trf_upward[1])+1   : trf_filt < trf_filt[1] ? 0 : nz(trf_upward[1])
trf_downward := trf_filt < trf_filt[1] ? nz(trf_downward[1])+1 : trf_filt > trf_filt[1] ? 0 : nz(trf_downward[1])
trf_longCond  = trf_src > trf_filt and trf_upward   > 0
trf_shortCond = trf_src < trf_filt and trf_downward > 0
var int trf_CondIni = 0
trf_CondIni := trf_longCond ? 1 : trf_shortCond ? -1 : trf_CondIni[1]
trf_buy  = trf_longCond  and trf_CondIni[1] == -1
trf_sell = trf_shortCond and trf_CondIni[1] ==  1

// ═══════════════════════════════════════════════════════════════════
// 5. RSI BANDS
// ═══════════════════════════════════════════════════════════════════
rsi_ob        = input.int(65,    title="Overbought Level",  minval=50, maxval=100, group="5 · RSI Bands",
     tooltip="RSI overbought threshold. Price touching the upper RSI band (derived from this level) is used as a short-side confirmation.")
rsi_os        = input.int(40,    title="Oversold Level",    minval=0,  maxval=50,  group="5 · RSI Bands",
     tooltip="RSI oversold threshold. Price touching the lower RSI band (derived from this level) is used as a long-side confirmation.")
rsi_len_entry = input.int(10,    title="Entry Length",      minval=1,              group="5 · RSI Bands",
     tooltip="RSI length used to compute the entry-level resistance/support bands. Shorter lengths produce tighter bands.")
rsi_len_tp    = input.int(20,    title="TP Target Length",  minval=1,              group="5 · RSI Bands",
     tooltip="RSI length used for TP1 target bands. A longer length here produces wider TP targets relative to entry bands.")
rsi_fill_on   = input.bool(true, title="Show Entry/TP Band Fill",                  group="5 · RSI Bands",
     tooltip="Toggle the shaded fill between Entry and TP RSI bands for visual clarity.")

rsi_calc(len) =>
    ep_  = 2 * len - 1
    auc_ = ta.ema(math.max(close - close[1], 0), ep_)
    adc_ = ta.ema(math.max(close[1] - close, 0), ep_)
    x1_  = (len - 1) * (adc_ * rsi_ob / (100 - rsi_ob) - auc_)
    ub_  = x1_ >= 0 ? close + x1_ : close + x1_ * (100 - rsi_ob) / rsi_ob
    x2_  = (len - 1) * (adc_ * rsi_os / (100 - rsi_os) - auc_)
    lb_  = x2_ >= 0 ? close + x2_ : close + x2_ * (100 - rsi_os) / rsi_os
    [ub_, lb_, math.avg(ub_, lb_)]

[rsi_ub,    rsi_lb,    rsi_mid]    = rsi_calc(rsi_len_entry)
[rsi_ub_tp, rsi_lb_tp, rsi_mid_tp] = rsi_calc(rsi_len_tp)

p_rsi_ub    = plot(rsi_ub,    title="RSI Resistance (Entry)", color=color.new(presetBear,55), linewidth=1)
p_rsi_lb    = plot(rsi_lb,    title="RSI Support (Entry)",    color=color.new(presetBull,55), linewidth=1)
p_rsi_mid   = plot(rsi_mid,   title="RSI Midline",            color=color.new(presetNeutral,60), linewidth=1)
p_rsi_ub_tp = plot(rsi_ub_tp, title="RSI Resistance (TP)",   color=color.new(presetBear,55), linewidth=1)
p_rsi_lb_tp = plot(rsi_lb_tp, title="RSI Support (TP)",      color=color.new(presetBull,55), linewidth=1)
fill(p_rsi_ub, p_rsi_ub_tp, color=rsi_fill_on ? color.new(presetBear,88) : na,  title="RSI Upper Fill")
fill(p_rsi_lb, p_rsi_lb_tp, color=rsi_fill_on ? color.new(presetBull,88) : na,  title="RSI Lower Fill")

// ═══════════════════════════════════════════════════════════════════
// 6. WT CROSS LB
// ═══════════════════════════════════════════════════════════════════
wt_ch_len  = input.int(10,  title="Channel Length",      minval=1,  group="6 · WaveTrend (No Visuals)",
     tooltip="EMA length for the WaveTrend channel midline. Controls the responsiveness of the oscillator.")
wt_avg_len = input.int(10,  title="Average Length",      minval=1,  group="6 · WaveTrend (No Visuals)",
     tooltip="Final smoothing EMA applied to the WaveTrend oscillator. Higher values produce a smoother WT line.")
wt_ob1     = input.int(60,  title="Overbought Level 1",  minval=1,  group="6 · WaveTrend (No Visuals)",
     tooltip="Primary WT overbought threshold. Used as the outer extreme zone for signal filtering.")
wt_ob2     = input.int(53,  title="Overbought Level 2",  minval=1,  group="6 · WaveTrend (No Visuals)",
     tooltip="Secondary WT overbought threshold. Defines the inner edge of the overbought zone.")
wt_os1     = input.int(-60, title="Oversold Level 1",    maxval=-1, group="6 · WaveTrend (No Visuals)",
     tooltip="Primary WT oversold threshold. Used as the outer extreme zone for signal filtering.")
wt_os2     = input.int(-53, title="Oversold Level 2",    maxval=-1, group="6 · WaveTrend (No Visuals)",
     tooltip="Secondary WT oversold threshold. Defines the inner edge of the oversold zone.")

wt_esa = ta.ema(hlc3, wt_ch_len)
wt_d   = ta.ema(math.abs(hlc3 - wt_esa), wt_ch_len)
wt1    = ta.ema((hlc3 - wt_esa) / (0.015 * wt_d), wt_avg_len)

// ═══════════════════════════════════════════════════════════════════
// 7. ATR
// ═══════════════════════════════════════════════════════════════════
atr_length = input.int(14,       title="Length",    minval=1,                          group="7 · ATR (No Visuals)",
     tooltip="ATR period used for trailing stop distance and general volatility reference.")
atr_smooth = input.string("RMA", title="Smoothing", options=["RMA","SMA","EMA","WMA"], group="7 · ATR (No Visuals)",
     tooltip="Smoothing method for ATR calculation. RMA (Wilder's) is the standard; others offer alternative responsiveness profiles.")

atr_val = switch atr_smooth
    "RMA" => ta.rma(ta.tr(true), atr_length)
    "SMA" => ta.sma(ta.tr(true), atr_length)
    "EMA" => ta.ema(ta.tr(true), atr_length)
    "WMA" => ta.wma(ta.tr(true), atr_length)
    =>       ta.rma(ta.tr(true), atr_length)

// ═══════════════════════════════════════════════════════════════════
// 8. GRAND SIGNAL CONDITIONS
// ═══════════════════════════════════════════════════════════════════
gs_min_signals   = input.int(2,      title="Min Quad-Indicator Signals",       minval=1, maxval=4,    group="8 · Grand Signal Conditions",
     tooltip="Minimum number of the 4 sub-indicators (PP-ST, ST, CE, TRF) that must fire within the signal window to trigger a Grand signal.")
gs_bar_window    = input.int(2,      title="Signal Bar Window",                minval=1, maxval=5,    group="8 · Grand Signal Conditions",
     tooltip="How many consecutive bars to look back for accumulating sub-indicator signals. Wider windows allow more time for signals to cluster.")
gs_rsi_band_on   = input.bool(true,  title="RSI Band Touch Condition",                               group="8 · Grand Signal Conditions",
     tooltip="When enabled, a Grand Long requires price to have touched the RSI lower band, and a Grand Short requires a touch of the upper band, within the lookback window.")
gs_rsi_band_bars = input.int(5,      title="RSI Band Touch Lookback (bars)", minval=1, maxval=50,   group="8 · Grand Signal Conditions",
     tooltip="Number of bars to look back for an RSI band touch when the RSI Band Touch Condition is active.")
gs_midline_on    = input.bool(false, title="RSI Midline Filter",                                      group="8 · Grand Signal Conditions",
     tooltip="When enabled, Grand Long requires price below the RSI midline, and Grand Short requires price above it. This adds a mean-reversion filter.")
gs_stop_lookback = input.int(2,      title="Stop Level Lookback (bars)",        minval=2, maxval=500,  group="8 · Grand Signal Conditions",
     tooltip="Number of past bars to scan for the lowest low (long stop) or highest high (short stop) when setting the Grand signal's stop level.")
gs_wt_on         = input.bool(true,  title="WT Cross Band Condition",                                 group="8 · Grand Signal Conditions",
     tooltip="When enabled, Grand Long requires a recent WT visit to the oversold zone, and Grand Short requires a visit to the overbought zone.")
gs_wt_lookback   = input.int(4,      title="WT Band Visit Lookback (bars)",  minval=1, maxval=100,  group="8 · Grand Signal Conditions",
     tooltip="Number of bars to look back for a WaveTrend oversold/overbought zone visit when the WT condition is active.")

var int total_buy  = 0
var int total_sell = 0
total_buy  := 0
total_sell := 0
for i = 0 to gs_bar_window - 1
    total_buy  := total_buy  + (pp_buy[i]?1:0)  + (st_buy[i]?1:0)  + (ce_buy[i]?1:0)  + (trf_buy[i]?1:0)
    total_sell := total_sell + (pp_sell[i]?1:0) + (st_sell[i]?1:0) + (ce_sell[i]?1:0) + (trf_sell[i]?1:0)
buy_this_bar  = (pp_buy?1:0)  + (st_buy?1:0)  + (ce_buy?1:0)  + (trf_buy?1:0)
sell_this_bar = (pp_sell?1:0) + (st_sell?1:0) + (ce_sell?1:0) + (trf_sell?1:0)
quad_buy  = total_buy  >= gs_min_signals and buy_this_bar  >= 1
quad_sell = total_sell >= gs_min_signals and sell_this_bar >= 1

rsi_ob_touched = false
rsi_os_touched = false
if gs_rsi_band_on
    for i = 0 to gs_rsi_band_bars - 1
        if high[i] >= rsi_ub[i]
            rsi_ob_touched := true
        if low[i]  <= rsi_lb[i]
            rsi_os_touched := true
rsi_sell_ok     = gs_rsi_band_on ? rsi_ob_touched : true
rsi_buy_ok      = gs_rsi_band_on ? rsi_os_touched : true
midline_sell_ok = gs_midline_on  ? low  > rsi_mid : true
midline_buy_ok  = gs_midline_on  ? high < rsi_mid : true

wt_os_touched = false
wt_ob_touched = false
if gs_wt_on
    for i = 0 to gs_wt_lookback - 1
        if wt1[i] <= math.max(wt_os1, wt_os2)
            wt_os_touched := true
        if wt1[i] >= math.min(wt_ob1, wt_ob2)
            wt_ob_touched := true
wt_buy_ok  = gs_wt_on ? wt_os_touched : true
wt_sell_ok = gs_wt_on ? wt_ob_touched : true

grandBuy  = quad_buy  and rsi_buy_ok  and midline_buy_ok  and wt_buy_ok
grandSell = quad_sell and rsi_sell_ok and midline_sell_ok and wt_sell_ok

// ═══════════════════════════════════════════════════════════════════
// 9. STOP & TP SETTINGS
// ═══════════════════════════════════════════════════════════════════
sl_mode        = input.string("Close", title="Stop Loss Trigger",     options=["Wick","Close"], group="9 · Stop & TP Settings",
     tooltip="Determines whether the stop loss is triggered by the candle wick (intrabar low/high) or the bar close price.")
tp_mode        = input.string("Wick",  title="TP1 Trigger",           options=["Wick","Close"], group="9 · Stop & TP Settings",
     tooltip="Determines whether TP1 is triggered by the candle wick or the bar close price.")
tp1_pct        = input.string("100%",  title="TP1 Close Percentage",  options=["50%","75%","100%"], group="9 · Stop & TP Settings",
     tooltip="Percentage of position to close at TP1. At 100% the full position exits; at 50% or 75% the remainder moves to trailing stop.")
trail_mode     = input.string("Wick",  title="Trailing Stop Trigger", options=["Wick","Close"], group="9 · Stop & TP Settings",
     tooltip="Determines whether the trailing stop (TP2 phase) is triggered by the wick or the close price.")
trail_atr_mult = input.float(1.0,     title="Trailing ATR Multiplier", minval=0.1, step=0.1,   group="9 · Stop & TP Settings",
     tooltip="ATR multiplier for the trailing stop distance after TP1 partial close. Lower values keep the trail tighter to price.")
sl_color    = input.color(color.red,                 title="Stop Loss Line Color",     group="9 · Stop & TP Settings",
     tooltip="Color of the stop loss level line on the chart.")
sl_width    = input.int(2, minval=1, maxval=5,       title="Stop Loss Line Width",     group="9 · Stop & TP Settings",
     tooltip="Thickness of the stop loss level line.")
tp1_color   = input.color(color.new(color.green,0),  title="TP1 Line Color",           group="9 · Stop & TP Settings",
     tooltip="Color of the TP1 target level line on the chart.")
tp1_width   = input.int(2, minval=1, maxval=5,       title="TP1 Line Width",           group="9 · Stop & TP Settings",
     tooltip="Thickness of the TP1 target level line.")
be_color    = input.color(color.yellow,              title="Breakeven Line Color",      group="9 · Stop & TP Settings",
     tooltip="Color of the breakeven level line shown after TP1 partial close.")
be_width    = input.int(2, minval=1, maxval=5,       title="Breakeven Line Width",     group="9 · Stop & TP Settings",
     tooltip="Thickness of the breakeven level line.")
trail_color = input.color(color.new(color.orange,0), title="Trailing Stop Line Color",  group="9 · Stop & TP Settings",
     tooltip="Color of the trailing stop level line during the TP2 phase.")
trail_width = input.int(2, minval=1, maxval=5,       title="Trailing Stop Line Width", group="9 · Stop & TP Settings",
     tooltip="Thickness of the trailing stop level line.")
entry_color = input.color(color.new(#FFD700,0), title="Entry Line Color",          group="9 · Stop & TP Settings",
     tooltip="Color of the entry price level line on the chart.")
entry_width = input.int(1, minval=1, maxval=5,       title="Entry Line Width",         group="9 · Stop & TP Settings",
     tooltip="Thickness of the entry price level line.")

tp1_full_close = tp1_pct == "100%"
tp1_ratio = tp1_pct == "50%" ? 0.5 : tp1_pct == "75%" ? 0.75 : 1.0
tp2_ratio = 1.0 - tp1_ratio

// ═══════════════════════════════════════════════════════════════════
// 10. STATS TABLE
// ═══════════════════════════════════════════════════════════════════
tbl_on       = input.bool(true,          title="Show Stats Table",      group="10 · Stats Table",
     tooltip="Toggle the on-chart statistics table that displays backtest performance metrics.")
tbl_pos      = input.string("Top Right", title="Table Position",        group="10 · Stats Table",
     options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center"],
     tooltip="Screen position for the stats table overlay.")
tbl_size     = input.string("Small",     title="Table Text Size",       group="10 · Stats Table",
     options=["Tiny","Small","Normal","Large"],
     tooltip="Font size for all text inside the stats table. Overridden to 'Tiny' when Mobile Mode is on.")
tbl_lookback = input.string("Last 10",       title="Stats Lookback Window", group="10 · Stats Table",
     options=["All","Last 100","Last 50","Last 20","Last 10"],
     tooltip="Limit backtest statistics to the most recent N closed trades. 'All' uses every trade on the visible chart.")
tbl_risk     = input.float(100.0,        title="Risk Unit (Simulation)",  group="10 · Stats Table", minval=1,
     tooltip="Base unit for signal simulation. Results are shown in units (u), not real currency. Example: if set to 100, a +350u result means 3.5x the base unit. For educational purposes only.")
tbl_utc      = input.string("UTC+3",    title="Timezone (UTC Offset)", group="10 · Stats Table",
     options=["UTC-12","UTC-11","UTC-10","UTC-9","UTC-8","UTC-7","UTC-6","UTC-5","UTC-4","UTC-3","UTC-2","UTC-1","UTC+0","UTC+1","UTC+2","UTC+3","UTC+4","UTC+5","UTC+5:30","UTC+5:45","UTC+6","UTC+6:30","UTC+7","UTC+8","UTC+9","UTC+9:30","UTC+10","UTC+11","UTC+12","UTC+13"],
     tooltip="Select your timezone as a UTC offset. All date/time values in the stats table (Start Date, Current Time) will be displayed in this timezone.")

// ═══════════════════════════════════════════════════════════════════
// 11. AUTOTREND FILTER
// ═══════════════════════════════════════════════════════════════════
at_enabled      = input.bool(true,       title="AutoTrend Active",        group="11 · AutoTrend Filter",
     tooltip="Enable/disable the macro trend filter based on an external symbol's EMA alignment across two timeframes.")
at_tf1          = input.string("240",      title="Reference TF 1 (min)", group="11 · AutoTrend Filter",
     options=["15","30","60","120","240","D"],
     tooltip="First timeframe for the reference symbol's trend assessment (e.g., 60 = 1 hour).")
at_tf2          = input.string("D",     title="Reference TF 2 (min)", group="11 · AutoTrend Filter",
     options=["15","30","60","120","240","D"],
     tooltip="Second timeframe for the reference symbol's trend assessment. Both TFs must agree for the AutoTrend to be bullish or bearish.")
at_ema_period   = input.int(50,           title="EMA Period",           group="11 · AutoTrend Filter", minval=1,
     tooltip="EMA period applied on the reference symbol across both timeframes for trend determination.")
at_symbol       = input.string("USDT.D",  title="Trend Symbol",         group="11 · AutoTrend Filter",
     tooltip="External symbol used as the macro trend reference (e.g., BTCUSDT, USDT.D, BTC.D).")
at_trendbuy_on  = input.bool(true,        title="TrendBuy Active",      group="11 · AutoTrend Filter",
     tooltip="Enable Trend Long signals. These fire when the AutoTrend is bullish and the symbol's RSI band is touched.")
at_trendsell_on = input.bool(true,        title="TrendSell Active",     group="11 · AutoTrend Filter",
     tooltip="Enable Trend Short signals. These fire when the symbol is below its EMA and the RSI band is touched.")
at_grand_filter = input.bool(true,       title="Apply AutoTrend Filter to Grand Signals", group="11 · AutoTrend Filter",
     tooltip="ON: Grand signals only fire in the trend direction. OFF: Grand signals work in both directions (classic NSE behavior).")
trend_atr_len  = input.int(14,            title="Trend ATR Length",     group="11 · AutoTrend Filter", minval=1,
     tooltip="ATR period used specifically for Trend signal stop-loss calculation.")
trend_atr_mult = input.float(0.5,         title="Trend ATR Stop Mult",  group="11 · AutoTrend Filter", minval=0.1, step=0.1,
     tooltip="ATR multiplier for Trend signal stops. Lower values place tighter stops for scalp-style trend entries.")
trend_wt_on    = input.bool(true,         title="Trend WT Filter Active",group="11 · AutoTrend Filter",
     tooltip="When enabled, TrendBuy requires a recent WT oversold visit and TrendSell requires a recent WT overbought visit.")
trend_wt_lb    = input.int(4,             title="Trend WT Lookback (bars)",group="11 · AutoTrend Filter", minval=1, maxval=50,
     tooltip="Number of bars to look back for a WT zone visit when the Trend WT Filter is active.")

// ── Symbol EMA Filter ──────────────────────────────────────────
sym_ema_on     = input.bool(true,  title="Symbol EMA Filter Active", group="11 · AutoTrend Filter",
     tooltip="ON: TrendBuy requires close > Symbol EMA. TrendSell requires close < Symbol EMA. Independent of the reference symbol.")
sym_ema_period = input.int(7,      title="Symbol EMA Period",        group="11 · AutoTrend Filter", minval=1,
     tooltip="EMA period calculated on the current symbol's price for the Symbol EMA Filter.")
sym_ema_show   = input.bool(false, title="Show Symbol EMA",          group="11 · AutoTrend Filter",
     tooltip="Display the Symbol EMA line on the chart.")

// NSE Trend ATR — independent ATR calculation
trend_atr_val = ta.rma(ta.tr(true), trend_atr_len)

// Symbol EMA calculation
sym_ema  = ta.ema(close, sym_ema_period)
sym_bull = close > sym_ema
sym_bear = close < sym_ema
plot(sym_ema_on and sym_ema_show ? sym_ema : na,
     title="Symbol EMA",
     color=sym_bull ? color.new(trendBullColor,30) : color.new(trendBearColor,30),
     linewidth=2)

btc_tf1_close = request.security(at_symbol, at_tf1, close[1],                        lookahead=barmerge.lookahead_on)
btc_tf2_close = request.security(at_symbol, at_tf2, close[1],                        lookahead=barmerge.lookahead_on)
btc_tf1_ema   = request.security(at_symbol, at_tf1, ta.ema(close, at_ema_period)[1], lookahead=barmerge.lookahead_on)
btc_tf2_ema   = request.security(at_symbol, at_tf2, ta.ema(close, at_ema_period)[1], lookahead=barmerge.lookahead_on)

autoTrendBull = at_enabled ? (btc_tf1_close > btc_tf1_ema and btc_tf2_close > btc_tf2_ema) : true
autoTrendBear = at_enabled ? (btc_tf1_close < btc_tf1_ema and btc_tf2_close < btc_tf2_ema) : true

bgcolor(at_enabled and autoTrendBull ? color.new(color.green, 90) : na, title="AutoTrend Bull BG")
bgcolor(at_enabled and autoTrendBear ? color.new(color.red,   90) : na, title="AutoTrend Bear BG")

// ═══════════════════════════════════════════════════════════════════
// STATE MACHINE VARIABLES
// ═══════════════════════════════════════════════════════════════════
var int   state         = 0
var int   sig_type      = 0
var float entryPrice    = na
var float stopLvl       = na
var float trailLvl      = na
var float origStopDist  = na
var line  slLine        = na
var line  tp1Line       = na
var line  beLine        = na
var line  trailLine     = na
var line  entryLine     = na
var label slLbl         = na
var label tp1Lbl        = na
var label beLbl         = na
var label trailLbl      = na
var label entryLbl      = na
var float trade_tp1_pnl = 0.0

var float lastEntryPrice  = na
var float lastStopLvl     = na
var float lastTp1Lvl      = na
var float lastExitPrice   = na
var string lastExitType   = "—"
var string lastSide       = "—"

var int[]   arr_type     = array.new_int(0)
var int[]   arr_sig      = array.new_int(0)
var float[] arr_pnl_tp1  = array.new_float(0)
var float[] arr_pnl_tp2  = array.new_float(0)
var float[] arr_pnl_stop = array.new_float(0)
var int[]   arr_time     = array.new_int(0)
var int     cnt_long     = 0
var int     cnt_short    = 0

// ─── HELPERS ────────────────────────────────────────────────────────
f_lowest(len) =>
    float ll = low[1]
    for j = 2 to len
        if low[j] < ll
            ll := low[j]
    ll

f_highest(len) =>
    float hh = high[1]
    for j = 2 to len
        if high[j] > hh
            hh := high[j]
    hh

f_delLine(ln) =>
    if not na(ln)
        line.delete(ln)

f_delLabel(lb) =>
    if not na(lb)
        label.delete(lb)

f_calc_pnl(exitPrice, _entryPrice, _origSD, _dir, _ratio) =>
    _posSize = _origSD > 0 ? tbl_risk / _origSD : 0.0
    _raw     = _dir == 1 ? (exitPrice - _entryPrice) : (_entryPrice - exitPrice)
    _posSize * _raw * _ratio

// ─── TP1 LEVEL ───────────────────────────────────────────────────
tp1Lvl_now = (state[1] == 1 or state[1] == 2) ? rsi_ub_tp : rsi_lb_tp

// ─── LINE UPDATES ──────────────────────────────────────────────────
if state[1] != 0
    if not na(slLine)
        line.set_x2(slLine, bar_index)
    if not na(beLine)
        line.set_x2(beLine, bar_index)
    if not na(trailLine)
        line.set_x2(trailLine, bar_index)
    if not na(entryLine)
        line.set_x2(entryLine, bar_index)
    if not na(slLbl)
        label.set_x(slLbl, bar_index)
    if not na(beLbl)
        label.set_x(beLbl, bar_index)
    if not na(trailLbl)
        label.set_x(trailLbl, bar_index)
        label.set_y(trailLbl, trailLvl)
    if not na(entryLbl)
        label.set_x(entryLbl, bar_index)

if (state[1] == 1 or state[1] == -1) and not na(tp1Line)
    line.set_x2(tp1Line, bar_index)
    line.set_y1(tp1Line, tp1Lvl_now)
    line.set_y2(tp1Line, tp1Lvl_now)
    if not na(tp1Lbl)
        label.set_x(tp1Lbl, bar_index)
        label.set_y(tp1Lbl, tp1Lvl_now)

if state[1] == 2
    newT = close - trail_atr_mult * atr_val
    if newT > trailLvl
        trailLvl := newT
        if not na(trailLine)
            line.set_y1(trailLine, trailLvl)
            line.set_y2(trailLine, trailLvl)

if state[1] == -2
    newT = close + trail_atr_mult * atr_val
    if newT < trailLvl
        trailLvl := newT
        if not na(trailLine)
            line.set_y1(trailLine, trailLvl)
            line.set_y2(trailLine, trailLvl)

// ═══════════════════════════════════════════════════════════════════
// ENTRY SIGNALS
// ═══════════════════════════════════════════════════════════════════
trend_wt_os_ok = false
trend_wt_ob_ok = false
if trend_wt_on
    for i = 0 to trend_wt_lb - 1
        if wt1[i] <= math.max(wt_os1, wt_os2)
            trend_wt_os_ok := true
        if wt1[i] >= math.min(wt_ob1, wt_ob2)
            trend_wt_ob_ok := true
else
    trend_wt_os_ok := true
    trend_wt_ob_ok := true

showGrandBuy  = grandBuy  and (at_grand_filter ? autoTrendBull : true) and state[1] == 0
showGrandSell = grandSell and (at_grand_filter ? autoTrendBear : true) and state[1] == 0
sym_bull_ok = sym_ema_on ? sym_bull : true
sym_bear_ok = sym_ema_on ? sym_bear : true

showTrendBuy  = at_trendbuy_on and autoTrendBull and sym_bull_ok and low  <= rsi_lb and trend_wt_os_ok and state[1] == 0 and not showGrandBuy
showTrendSell = at_trendsell_on and sym_bear_ok and high >= rsi_ub and trend_wt_ob_ok and state[1] == 0 and not showGrandSell

if showGrandBuy
    label.new(bar_index, low, text="GrandBuy\n" + str.tostring(close, format.mintick), style=label.style_label_up, color=color.new(color.orange,0), textcolor=color.black, size=size.small)
if showGrandSell
    label.new(bar_index, high, text="GrandSell\n" + str.tostring(close, format.mintick), style=label.style_label_down, color=color.new(color.blue,0), textcolor=color.white, size=size.small)
if showTrendBuy
    label.new(bar_index, low, text="▲ TrendBuy\n" + str.tostring(close, format.mintick), style=label.style_label_up, color=color.new(trendBullColor,0), textcolor=color.black, size=size.small)
if showTrendSell
    label.new(bar_index, high, text="▼ TrendSell\n" + str.tostring(close, format.mintick), style=label.style_label_down, color=color.new(trendBearColor,0), textcolor=color.white, size=size.small)
// ═══════════════════════════════════════════════════════════════════
// STATE MACHINE — ENTRIES
// ═══════════════════════════════════════════════════════════════════
_evtSize = mobileMode ? size.tiny : size.small

if state[1] == 0 and showGrandBuy
    f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
    f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
    slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
    slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
    state := 1,  sig_type := 0,  entryPrice := close
    stopLvl      := f_lowest(gs_stop_lookback)
    origStopDist := math.abs(close - f_lowest(gs_stop_lookback))
    trailLvl     := na,  trade_tp1_pnl := 0.0
    lastEntryPrice := close
    lastStopLvl    := stopLvl
    lastTp1Lvl     := rsi_ub_tp
    lastExitPrice  := na
    lastExitType   := "—"
    lastSide       := "LONG"
    entryLine := line.new(bar_index-15, close,     bar_index, close,     color=entry_color, width=entry_width, style=line.style_dashed)
    entryLbl  := label.new(bar_index,   close,     text="ENTRY", color=color.new(entry_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    slLine  := line.new(bar_index-15, stopLvl,   bar_index, stopLvl,   color=sl_color,  width=sl_width,  style=line.style_solid)
    slLbl   := label.new(bar_index,   stopLvl,   text="STOP",  color=color.new(sl_color,20),  textcolor=color.white, style=label.style_label_left, size=_evtSize)
    tp1Line := line.new(bar_index-15, rsi_ub_tp, bar_index, rsi_ub_tp, color=tp1_color, width=tp1_width, style=line.style_solid)
    tp1Lbl  := label.new(bar_index,   rsi_ub_tp, text="TP1",   color=color.new(tp1_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    cnt_long += 1
    array.push(arr_type,0), array.push(arr_sig,0), array.push(arr_pnl_tp1,0.0)
    array.push(arr_pnl_tp2,0.0), array.push(arr_pnl_stop,0.0), array.push(arr_time,time)

else if state[1] == 0 and showGrandSell
    f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
    f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
    slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
    slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
    state := -1, sig_type := 0,  entryPrice := close
    stopLvl      := f_highest(gs_stop_lookback)
    origStopDist := math.abs(close - f_highest(gs_stop_lookback))
    trailLvl     := na,  trade_tp1_pnl := 0.0
    lastEntryPrice := close
    lastStopLvl    := stopLvl
    lastTp1Lvl     := rsi_lb_tp
    lastExitPrice  := na
    lastExitType   := "—"
    lastSide       := "SHORT"
    entryLine := line.new(bar_index-15, close,     bar_index, close,     color=entry_color, width=entry_width, style=line.style_dashed)
    entryLbl  := label.new(bar_index,   close,     text="ENTRY", color=color.new(entry_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    slLine  := line.new(bar_index-15, stopLvl,   bar_index, stopLvl,   color=sl_color,  width=sl_width,  style=line.style_solid)
    slLbl   := label.new(bar_index,   stopLvl,   text="STOP",  color=color.new(sl_color,20),  textcolor=color.white, style=label.style_label_left, size=_evtSize)
    tp1Line := line.new(bar_index-15, rsi_lb_tp, bar_index, rsi_lb_tp, color=tp1_color, width=tp1_width, style=line.style_solid)
    tp1Lbl  := label.new(bar_index,   rsi_lb_tp, text="TP1",   color=color.new(tp1_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    cnt_short += 1
    array.push(arr_type,0), array.push(arr_sig,0), array.push(arr_pnl_tp1,0.0)
    array.push(arr_pnl_tp2,0.0), array.push(arr_pnl_stop,0.0), array.push(arr_time,time)

else if state[1] == 0 and showTrendBuy
    f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
    f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
    slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
    slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
    state := 1,  sig_type := 1,  entryPrice := close
    stopLvl      := close - trend_atr_val * trend_atr_mult
    origStopDist := trend_atr_val * trend_atr_mult
    trailLvl     := na,  trade_tp1_pnl := 0.0
    lastEntryPrice := close
    lastStopLvl    := stopLvl
    lastTp1Lvl     := rsi_ub_tp
    lastExitPrice  := na
    lastExitType   := "—"
    lastSide       := "LONG"
    entryLine := line.new(bar_index-15, close,     bar_index, close,     color=entry_color, width=entry_width, style=line.style_dashed)
    entryLbl  := label.new(bar_index,   close,     text="ENTRY", color=color.new(entry_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    slLine  := line.new(bar_index-15, stopLvl,   bar_index, stopLvl,   color=color.new(trendBullColor,20), width=sl_width,  style=line.style_solid)
    slLbl   := label.new(bar_index,   stopLvl,   text="T.SL", color=color.new(trendBullColor,20), textcolor=color.black, style=label.style_label_left, size=_evtSize)
    tp1Line := line.new(bar_index-15, rsi_ub_tp, bar_index, rsi_ub_tp, color=color.new(trendBullColor,20), width=tp1_width, style=line.style_solid)
    tp1Lbl  := label.new(bar_index,   rsi_ub_tp, text="T.TP",  color=color.new(trendBullColor,20), textcolor=color.black, style=label.style_label_left, size=_evtSize)
    cnt_long += 1
    array.push(arr_type,0), array.push(arr_sig,1), array.push(arr_pnl_tp1,0.0)
    array.push(arr_pnl_tp2,0.0), array.push(arr_pnl_stop,0.0), array.push(arr_time,time)

else if state[1] == 0 and showTrendSell
    f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
    f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
    slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
    slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
    state := -1, sig_type := 1,  entryPrice := close
    stopLvl      := close + trend_atr_val * trend_atr_mult
    origStopDist := trend_atr_val * trend_atr_mult
    trailLvl     := na,  trade_tp1_pnl := 0.0
    lastEntryPrice := close
    lastStopLvl    := stopLvl
    lastTp1Lvl     := rsi_lb_tp
    lastExitPrice  := na
    lastExitType   := "—"
    lastSide       := "SHORT"
    entryLine := line.new(bar_index-15, close,     bar_index, close,     color=entry_color, width=entry_width, style=line.style_dashed)
    entryLbl  := label.new(bar_index,   close,     text="ENTRY", color=color.new(entry_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    slLine  := line.new(bar_index-15, stopLvl,   bar_index, stopLvl,   color=color.new(trendBearColor,20), width=sl_width,  style=line.style_solid)
    slLbl   := label.new(bar_index,   stopLvl,   text="T.SL", color=color.new(trendBearColor,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    tp1Line := line.new(bar_index-15, rsi_lb_tp, bar_index, rsi_lb_tp, color=color.new(trendBearColor,20), width=tp1_width, style=line.style_solid)
    tp1Lbl  := label.new(bar_index,   rsi_lb_tp, text="T.TP",  color=color.new(trendBearColor,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
    cnt_short += 1
    array.push(arr_type,0), array.push(arr_sig,1), array.push(arr_pnl_tp1,0.0)
    array.push(arr_pnl_tp2,0.0), array.push(arr_pnl_stop,0.0), array.push(arr_time,time)

// ═══════════════════════════════════════════════════════════════════
// STATE MACHINE — LONG ACTIVE (state == 1)
// ═══════════════════════════════════════════════════════════════════
else if state[1] == 1
    _stopHit   = sl_mode == "Wick" ? low <= stopLvl : close <= stopLvl
    _tp1Hit    = tp_mode == "Wick" ? high >= tp1Lvl_now : close >= tp1Lvl_now
    _tp1ExitPx = tp_mode == "Wick" ? tp1Lvl_now : close

    if _stopHit
        // ── FIX: Calculate real stop PnL based on actual exit price ──
        _sl_exit_px = sl_mode == "Wick" ? stopLvl : close
        _sl_pnl     = f_calc_pnl(_sl_exit_px, entryPrice, origStopDist, 1, 1.0)
        label.new(bar_index, low, text="SL\n"+str.tostring(math.round(_sl_pnl,2))+"u", style=label.style_label_up, color=sl_color, textcolor=color.white, size=_evtSize)
        f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
        f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
        slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
        slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
        state := 0
        lastExitPrice := _sl_exit_px
        lastExitType  := "STOP"
        _sz = array.size(arr_type)
        if _sz > 0
            array.set(arr_type, _sz-1, -1)
            array.set(arr_pnl_stop, _sz-1, _sl_pnl)
        origStopDist := na
    else if _tp1Hit
        _tp1_pnl = f_calc_pnl(_tp1ExitPx, entryPrice, origStopDist, 1, tp1_ratio)
        if tp1_full_close
            label.new(bar_index, high, text="TP1\n+"+str.tostring(math.round(_tp1_pnl,2))+"u", style=label.style_label_down, color=tp1_color, textcolor=color.white, size=_evtSize)
            f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
            f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
            slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
            slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
            state := 0
            lastExitPrice := tp_mode == "Wick" ? tp1Lvl_now : close
            lastExitType  := "TP1 FULL"
            _sz = array.size(arr_type)
            if _sz > 0
                array.set(arr_type, _sz-1, 1)
                array.set(arr_pnl_tp1, _sz-1, _tp1_pnl)
        else
            label.new(bar_index, high, text="TP1 "+tp1_pct+"\n+"+str.tostring(math.round(_tp1_pnl,2))+"u", style=label.style_label_down, color=tp1_color, textcolor=color.white, size=_evtSize)
            f_delLine(slLine), f_delLine(tp1Line), f_delLabel(slLbl), f_delLabel(tp1Lbl)
            slLine := na, tp1Line := na, slLbl := na, tp1Lbl := na
            stopLvl := entryPrice,  trade_tp1_pnl := _tp1_pnl
            _sz = array.size(arr_type)
            if _sz > 0
                array.set(arr_pnl_tp1, _sz-1, _tp1_pnl)
            beLine    := line.new(bar_index-15, stopLvl,  bar_index, stopLvl,  color=be_color,    width=be_width,    style=line.style_dashed)
            beLbl     := label.new(bar_index,   stopLvl,  text="BE",        color=color.new(be_color,20),    textcolor=color.black, style=label.style_label_left, size=_evtSize)
            trailLvl  := close - trail_atr_mult * atr_val
            trailLine := line.new(bar_index-15, trailLvl, bar_index, trailLvl, color=trail_color, width=trail_width, style=line.style_solid)
            trailLbl  := label.new(bar_index,   trailLvl, text="TRL",    color=color.new(trail_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
            lastExitType := "TP1 → TRAIL"
            state := 2

// ═══════════════════════════════════════════════════════════════════
// STATE MACHINE — SHORT ACTIVE (state == -1)
// ═══════════════════════════════════════════════════════════════════
else if state[1] == -1
    _stopHit   = sl_mode == "Wick" ? high >= stopLvl : close >= stopLvl
    _tp1Hit    = tp_mode == "Wick" ? low <= tp1Lvl_now : close <= tp1Lvl_now
    _tp1ExitPx = tp_mode == "Wick" ? tp1Lvl_now : close

    if _stopHit
        // ── FIX: Calculate real stop PnL based on actual exit price ──
        _sl_exit_px = sl_mode == "Wick" ? stopLvl : close
        _sl_pnl     = f_calc_pnl(_sl_exit_px, entryPrice, origStopDist, -1, 1.0)
        label.new(bar_index, high, text="SL\n"+str.tostring(math.round(_sl_pnl,2))+"u", style=label.style_label_down, color=sl_color, textcolor=color.white, size=_evtSize)
        f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
        f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
        slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
        slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
        state := 0
        lastExitPrice := _sl_exit_px
        lastExitType  := "STOP"
        _sz = array.size(arr_type)
        if _sz > 0
            array.set(arr_type, _sz-1, -1)
            array.set(arr_pnl_stop, _sz-1, _sl_pnl)
        origStopDist := na
    else if _tp1Hit
        _tp1_pnl = f_calc_pnl(_tp1ExitPx, entryPrice, origStopDist, -1, tp1_ratio)
        if tp1_full_close
            label.new(bar_index, low, text="TP1\n+"+str.tostring(math.round(_tp1_pnl,2))+"u", style=label.style_label_up, color=tp1_color, textcolor=color.white, size=_evtSize)
            f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
            f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
            slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
            slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
            state := 0
            lastExitPrice := tp_mode == "Wick" ? tp1Lvl_now : close
            lastExitType  := "TP1 FULL"
            _sz = array.size(arr_type)
            if _sz > 0
                array.set(arr_type, _sz-1, 1)
                array.set(arr_pnl_tp1, _sz-1, _tp1_pnl)
        else
            label.new(bar_index, low, text="TP1 "+tp1_pct+"\n+"+str.tostring(math.round(_tp1_pnl,2))+"u", style=label.style_label_up, color=tp1_color, textcolor=color.white, size=_evtSize)
            f_delLine(slLine), f_delLine(tp1Line), f_delLabel(slLbl), f_delLabel(tp1Lbl)
            slLine := na, tp1Line := na, slLbl := na, tp1Lbl := na
            stopLvl := entryPrice,  trade_tp1_pnl := _tp1_pnl
            _sz = array.size(arr_type)
            if _sz > 0
                array.set(arr_pnl_tp1, _sz-1, _tp1_pnl)
            beLine    := line.new(bar_index-15, stopLvl,  bar_index, stopLvl,  color=be_color,    width=be_width,    style=line.style_dashed)
            beLbl     := label.new(bar_index,   stopLvl,  text="BE",        color=color.new(be_color,20),    textcolor=color.black, style=label.style_label_left, size=_evtSize)
            trailLvl  := close + trail_atr_mult * atr_val
            trailLine := line.new(bar_index-15, trailLvl, bar_index, trailLvl, color=trail_color, width=trail_width, style=line.style_solid)
            trailLbl  := label.new(bar_index,   trailLvl, text="TRL",    color=color.new(trail_color,20), textcolor=color.white, style=label.style_label_left, size=_evtSize)
            lastExitType := "TP1 → TRAIL"
            state := -2

// ═══════════════════════════════════════════════════════════════════
// STATE MACHINE — LONG TRAILING (state == 2)
// ═══════════════════════════════════════════════════════════════════
else if state[1] == 2
    _beHit       = sl_mode    == "Wick" ? low  <= stopLvl  : close <= stopLvl
    _trailHit    = trail_mode == "Wick" ? low  <= trailLvl : close <= trailLvl
    _trailExitPx = trail_mode == "Wick" ? trailLvl : close
    if _beHit
        // ── FIX: Calculate real BE PnL for the TP2 portion ──
        _be_exit_px = sl_mode == "Wick" ? stopLvl : close
        _be_tp2_pnl = f_calc_pnl(_be_exit_px, entryPrice, origStopDist, 1, tp2_ratio)
        _be_total   = trade_tp1_pnl + _be_tp2_pnl
        label.new(bar_index, low, text="BE\n"+str.tostring(math.round(_be_total,2))+"u", style=label.style_label_down, color=be_color, textcolor=color.black, size=_evtSize)
        f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
        f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
        slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
        slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
        state := 0
        lastExitPrice := _be_exit_px
        lastExitType  := "BREAKEVEN"
        _sz = array.size(arr_type)
        if _sz > 0
            array.set(arr_type, _sz-1, 3)
            array.set(arr_pnl_tp1, _sz-1, trade_tp1_pnl)
            array.set(arr_pnl_tp2, _sz-1, _be_tp2_pnl)
        trade_tp1_pnl := 0.0
    else if _trailHit
        _tp2_pnl = f_calc_pnl(_trailExitPx, entryPrice, origStopDist, 1, tp2_ratio)
        label.new(bar_index, low, text="TP2\n+"+str.tostring(math.round(_tp2_pnl,2))+"u", style=label.style_label_up, color=trail_color, textcolor=color.white, size=_evtSize)
        f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
        f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
        slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
        slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
        state := 0
        lastExitPrice := trail_mode == "Wick" ? trailLvl : close
        lastExitType  := "TP2 TRAIL"
        _sz = array.size(arr_type)
        if _sz > 0
            array.set(arr_type, _sz-1, 2)
            array.set(arr_pnl_tp2, _sz-1, _tp2_pnl)
        trade_tp1_pnl := 0.0

// ═══════════════════════════════════════════════════════════════════
// STATE MACHINE — SHORT TRAILING (state == -2)
// ═══════════════════════════════════════════════════════════════════
else if state[1] == -2
    _beHit       = sl_mode    == "Wick" ? high >= stopLvl  : close >= stopLvl
    _trailHit    = trail_mode == "Wick" ? high >= trailLvl : close >= trailLvl
    _trailExitPx = trail_mode == "Wick" ? trailLvl : close
    if _beHit
        // ── FIX: Calculate real BE PnL for the TP2 portion ──
        _be_exit_px = sl_mode == "Wick" ? stopLvl : close
        _be_tp2_pnl = f_calc_pnl(_be_exit_px, entryPrice, origStopDist, -1, tp2_ratio)
        _be_total   = trade_tp1_pnl + _be_tp2_pnl
        label.new(bar_index, high, text="BE\n"+str.tostring(math.round(_be_total,2))+"u", style=label.style_label_up, color=be_color, textcolor=color.black, size=_evtSize)
        f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
        f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
        slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
        slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
        state := 0
        lastExitPrice := _be_exit_px
        lastExitType  := "BREAKEVEN"
        _sz = array.size(arr_type)
        if _sz > 0
            array.set(arr_type, _sz-1, 3)
            array.set(arr_pnl_tp1, _sz-1, trade_tp1_pnl)
            array.set(arr_pnl_tp2, _sz-1, _be_tp2_pnl)
        trade_tp1_pnl := 0.0
    else if _trailHit
        _tp2_pnl = f_calc_pnl(_trailExitPx, entryPrice, origStopDist, -1, tp2_ratio)
        label.new(bar_index, high, text="TP2\n+"+str.tostring(math.round(_tp2_pnl,2))+"u", style=label.style_label_down, color=trail_color, textcolor=color.white, size=_evtSize)
        f_delLine(slLine), f_delLine(tp1Line), f_delLine(beLine), f_delLine(trailLine), f_delLine(entryLine)
        f_delLabel(slLbl), f_delLabel(tp1Lbl), f_delLabel(beLbl), f_delLabel(trailLbl), f_delLabel(entryLbl)
        slLine := na, tp1Line := na, beLine := na, trailLine := na, entryLine := na
        slLbl  := na, tp1Lbl  := na, beLbl  := na, trailLbl  := na, entryLbl  := na
        state := 0
        lastExitPrice := trail_mode == "Wick" ? trailLvl : close
        lastExitType  := "TP2 TRAIL"
        _sz = array.size(arr_type)
        if _sz > 0
            array.set(arr_type, _sz-1, 2)
            array.set(arr_pnl_tp2, _sz-1, _tp2_pnl)
        trade_tp1_pnl := 0.0

// ═══════════════════════════════════════════════════════════════════
// LIVE PNL
// ═══════════════════════════════════════════════════════════════════
var float live_pnl_val = 0.0
if state != 0 and not na(entryPrice) and not na(origStopDist) and origStopDist > 0
    _lPS    = tbl_risk / origStopDist
    _lDiff  = state > 0 ? (close - entryPrice) : (entryPrice - close)
    _lRatio = (state == 1 or state == -1) ? 1.0 : tp2_ratio
    live_pnl_val := _lPS * _lDiff * _lRatio
    if state == 2 or state == -2
        live_pnl_val := live_pnl_val + trade_tp1_pnl
else
    live_pnl_val := 0.0

// ═══════════════════════════════════════════════════════════════════
// STATS TABLE
// ═══════════════════════════════════════════════════════════════════
if barstate.islast and tbl_on
    _tpos = switch tbl_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Top Center"   => position.top_center
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Bottom Center"=> position.bottom_center
        =>               position.top_right

    _tsz_base = switch tbl_size
        "Tiny"  => size.tiny
        "Small" => size.small
        "Normal"=> size.normal
        "Large" => size.large
        =>         size.small
    _tsz = mobileMode ? size.tiny : _tsz_base

    _lb_n = switch tbl_lookback
        "Last 10"  => 10
        "Last 20"  => 20
        "Last 50"  => 50
        "Last 100" => 100
        =>            0

    _sz = array.size(arr_type)
    _w_tp1full=0, _w_tp1_tp2=0, _w_tp1_be=0, _w_stop=0
    _pnl_tp1=0.0, _pnl_tp2=0.0, _pnl_stop=0.0, _w_pnl=0.0
    _closed_count=0, _best_trade=0.0, _worst_trade=0.0
    _win_streak=0, _loss_streak=0, _cur_w=0, _cur_l=0
    _first_trade_time=0
    _t_wins=0, _t_total=0, _t_pnl=0.0
    _g_wins=0, _g_total=0, _g_pnl=0.0

    for k = _sz - 1 to 0
        _t  = array.get(arr_type, k)
        _sg = array.get(arr_sig,  k)
        if _t == 0
            continue
        if _lb_n > 0 and _closed_count >= _lb_n
            break
        _closed_count += 1
        _p1 = array.get(arr_pnl_tp1,  k)
        _p2 = array.get(arr_pnl_tp2,  k)
        _ps = array.get(arr_pnl_stop, k)
        _tm = array.size(arr_time) > k ? array.get(arr_time, k) : 0
        _first_trade_time := _tm
        // ── FIX: Use real PnL values from arrays for all exit types ──
        _trade_total = _t==1?_p1 : _t==2?_p1+_p2 : _t==3?_p1+_p2 : _ps
        if _trade_total > _best_trade
            _best_trade := _trade_total
        if _trade_total < _worst_trade
            _worst_trade := _trade_total
        if _trade_total > 0
            _cur_w += 1, _cur_l := 0
        else
            _cur_l += 1, _cur_w := 0
        if _cur_w > _win_streak
            _win_streak := _cur_w
        if _cur_l > _loss_streak
            _loss_streak := _cur_l
        if _t == 1
            _w_tp1full+=1, _pnl_tp1+=_p1, _w_pnl+=_p1
        else if _t == 2
            _w_tp1_tp2+=1, _pnl_tp1+=_p1, _pnl_tp2+=_p2, _w_pnl+=_p1+_p2
        else if _t == 3
            _w_tp1_be+=1, _pnl_tp1+=_p1, _pnl_tp2+=_p2, _w_pnl+=_p1+_p2
        else if _t == -1
            _w_stop+=1, _pnl_stop+=_ps, _w_pnl+=_ps
        if _sg == 1
            _t_total+=1
            if _trade_total > 0
                _t_wins+=1
            _t_pnl+=_trade_total
        else
            _g_total+=1
            if _trade_total > 0
                _g_wins+=1
            _g_pnl+=_trade_total

    _w_wins   = _w_tp1full + _w_tp1_tp2
    _w_closed = _closed_count
    _w_wr     = _w_closed > 0 ? math.round((_w_wins/_w_closed)*100,1) : 0.0
    _avg_rr   = _w_wins > 0 and tbl_risk > 0 ? math.round((_pnl_tp1+_pnl_tp2)/(_w_wins*tbl_risk),2) : 0.0
    _t_wr     = _t_total > 0 ? math.round((_t_wins/_t_total)*100,1) : 0.0
    _g_wr     = _g_total > 0 ? math.round((_g_wins/_g_total)*100,1) : 0.0
    _lb_lbl   = tbl_lookback=="All" ? "All" : tbl_lookback

    // Timezone
    _tz = switch tbl_utc
        "UTC-12"   => "Etc/GMT+12"
        "UTC-11"   => "Etc/GMT+11"
        "UTC-10"   => "Etc/GMT+10"
        "UTC-9"    => "Etc/GMT+9"
        "UTC-8"    => "Etc/GMT+8"
        "UTC-7"    => "Etc/GMT+7"
        "UTC-6"    => "Etc/GMT+6"
        "UTC-5"    => "Etc/GMT+5"
        "UTC-4"    => "Etc/GMT+4"
        "UTC-3"    => "Etc/GMT+3"
        "UTC-2"    => "Etc/GMT+2"
        "UTC-1"    => "Etc/GMT+1"
        "UTC+0"    => "Etc/GMT"
        "UTC+1"    => "Etc/GMT-1"
        "UTC+2"    => "Etc/GMT-2"
        "UTC+3"    => "Etc/GMT-3"
        "UTC+4"    => "Etc/GMT-4"
        "UTC+5"    => "Etc/GMT-5"
        "UTC+5:30" => "Asia/Kolkata"
        "UTC+5:45" => "Asia/Kathmandu"
        "UTC+6"    => "Etc/GMT-6"
        "UTC+6:30" => "Asia/Yangon"
        "UTC+7"    => "Etc/GMT-7"
        "UTC+8"    => "Etc/GMT-8"
        "UTC+9"    => "Etc/GMT-9"
        "UTC+9:30" => "Australia/Darwin"
        "UTC+10"   => "Etc/GMT-10"
        "UTC+11"   => "Etc/GMT-11"
        "UTC+12"   => "Etc/GMT-12"
        "UTC+13"   => "Pacific/Apia"
        =>            "Etc/GMT-3"
    _start_str = _first_trade_time > 0 ? str.format_time(_first_trade_time, "yyyy/MM/dd HH:mm", _tz) : "—"
    _live_str  = state==0 ? "—" : (live_pnl_val>=0?"+":"")+str.tostring(math.round(live_pnl_val,2))+"u"
    _live_clr  = state==0 ? presetNeutral : live_pnl_val>=0 ? presetBull : presetBear

    // Theme colors
    _bg        = isDark ? color.new(#0d1117,15)     : color.new(#f8f9fa,5)
    _bg_hdr    = isDark ? color.new(#1a237e,20)      : color.new(#e3f2fd,5)
    _bg_sep    = isDark ? color.new(#1e2530,30)      : color.new(#e9ecef,10)
    _clr_brd   = isDark ? color.new(#30363d,40)      : color.new(#dee2e6,30)
    _clr_title = isDark ? color.white                : color.new(#0d1b2a,0)
    _clr_lbl   = isDark ? color.new(#8b949e,0)      : color.new(#495057,0)
    _clr_val   = isDark ? color.new(#e6edf3,0)      : color.new(#212529,0)
    _clr_sep   = isDark ? color.new(#58a6ff,30)      : color.new(#6c757d,20)
    _wr_clr    = _w_wr>=55?presetBull : _w_wr>=40?color.orange : presetBear
    _rr_clr    = _avg_rr>=1.5?presetBull : _avg_rr>=1.0?color.orange : presetBear
    _pnl_clr   = _w_pnl>=0?presetBull : presetBear
    _t_wr_clr  = _t_wr>=55?presetBull : _t_wr>=40?color.orange : presetBear
    _g_wr_clr  = _g_wr>=55?presetBull : _g_wr>=40?color.orange : presetBear
    _pos_txt   = state==0?"—":state==1?"LONG (TP1)":state==-1?"SHORT (TP1)":state==2?"LONG (TRL)":"SHORT (TRL)"
    _pos_clr   = state==0?presetNeutral:state>0?presetBull:presetBear
    _at_txt    = not at_enabled?"OFF":autoTrendBull?"BULL":autoTrendBear?"BEAR":"—"
    _at_clr    = not at_enabled?presetNeutral:autoTrendBull?presetBull:autoTrendBear?presetBear:presetNeutral
    _sym_txt   = not sym_ema_on?"OFF":sym_bull?"BULL":"BEAR"
    _sym_clr   = not sym_ema_on?presetNeutral:sym_bull?trendBullColor:trendBearColor
    _disc_clr  = isDark ? color.new(#6e7681,0) : color.new(#868e96,0)

    // ── Entry/Exit display values ──
    _entryStr  = not na(lastEntryPrice) ? str.tostring(lastEntryPrice, format.mintick) : "—"
    _stopStr   = not na(lastStopLvl) ? str.tostring(lastStopLvl, format.mintick) : "—"
    _tp1LStr   = not na(lastTp1Lvl) ? str.tostring(lastTp1Lvl, format.mintick) : "—"
    _exitStr   = not na(lastExitPrice) ? str.tostring(lastExitPrice, format.mintick) : state != 0 ? "OPEN" : "—"
    _sideClr   = lastSide == "LONG" ? presetBull : lastSide == "SHORT" ? presetBear : presetNeutral
    _exitClr   = lastExitType == "STOP" ? presetBear : lastExitType == "BREAKEVEN" ? color.orange : lastExitType == "—" ? presetNeutral : state != 0 and na(lastExitPrice) ? color.orange : presetBull
    _typeClr   = lastExitType == "STOP" ? presetBear : lastExitType == "BREAKEVEN" ? color.orange : lastExitType == "—" ? presetNeutral : lastExitType == "TP1 → TRAIL" ? color.orange : presetBull

    // ── Mobile labels ──
    _lPosition  = mobileMode ? "Pos"           : "Position"
    _lAutoTrend = mobileMode ? "AT ("+at_symbol+")" : "AutoTrend ("+at_symbol+")"
    _lSymTrend  = mobileMode ? "Sym Trend"     : "Current Symbol Trend"
    _lOpenPnl   = mobileMode ? "Open Sig"      : "Open Signal"
    _lEntry     = mobileMode ? "Entry"         : "Entry Price"
    _lSLvl      = mobileMode ? "Stop"          : "Stop Level"
    _lTP1Lvl    = mobileMode ? "TP1"           : "TP1 Target"
    _lExit      = mobileMode ? "Exit"          : "Exit Price"
    _lExType    = mobileMode ? "Type"          : "Exit Type"
    _lStartDate = mobileMode ? "Start"         : "Start Date"
    _lClosed    = mobileMode ? "Closed"        : "Closed Trades"
    _lWR        = mobileMode ? "TP1%"          : "TP1 Rate"
    _lTP1       = mobileMode ? "TP1 x"+str.tostring(_w_tp1full+_w_tp1_tp2+_w_tp1_be) : "TP1 Hits  x"+str.tostring(_w_tp1full+_w_tp1_tp2+_w_tp1_be)
    _lTP2       = mobileMode ? "TP2 x"+str.tostring(_w_tp1_tp2) : "TP2 Hits  x"+str.tostring(_w_tp1_tp2)
    _lSL        = mobileMode ? "SL x"+str.tostring(_w_stop) : "Stop Hits  x"+str.tostring(_w_stop)
    _lBE        = mobileMode ? "BE x"+str.tostring(_w_tp1_be) : "Breakeven  x"+str.tostring(_w_tp1_be)
    _lAvgRR     = mobileMode ? "Avg R"         : "Avg R-Multiple"
    _lBest      = mobileMode ? "Best"          : "Best Signal"
    _lWorst     = mobileMode ? "Worst"         : "Worst Signal"
    _lWinS      = mobileMode ? "Win Str"       : "Max Win Streak"
    _lLosS      = mobileMode ? "Loss Str"      : "Max Loss Streak"
    _lGSig      = mobileMode ? "Grand"         : "Grand Signals"
    _lGWR       = mobileMode ? "Grand TP1%"    : "Grand TP1 Rate"
    _lGNet      = mobileMode ? "Grand Net"     : "Grand Signals Net"
    _lTSig      = mobileMode ? "Trend"         : "Trend Signals"
    _lTWR       = mobileMode ? "Trend TP1%"    : "Trend TP1 Rate"
    _lTNet      = mobileMode ? "Trend Net"     : "Trend Signals Net"
    _lRisk      = mobileMode ? "Unit"          : "Risk Unit"
    _lNet       = mobileMode ? "NET"           : "Sim Net Result"
    _lTime      = mobileMode ? tbl_utc         : "Current ("+tbl_utc+")"
    _lTF        = mobileMode ? "TF"            : "Timeframe"

    // ── Table: 2 columns x 43 rows ──
    var table st = table.new(_tpos, 2, 43, bgcolor=_bg, border_color=_clr_brd, border_width=1, frame_color=_clr_brd, frame_width=1)

    // Row 0 — Header
    _hdr_l = mobileMode ? "NSE ["+_lb_lbl+"]" : "NSE SIGNAL ENGINE — SIMULATION  ["+_lb_lbl+"]"
    table.cell(st, 0, 0, text=_hdr_l, text_color=_clr_title, bgcolor=_bg_hdr, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 0, text=syminfo.ticker+" "+timeframe.period, text_color=_clr_sep, bgcolor=_bg_hdr, text_size=_tsz, text_halign=text.align_right)

    table.cell(st, 0, 1, text=_lPosition, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 1, text=_pos_txt,   text_color=_pos_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 2, text=_lAutoTrend, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 2, text=_at_txt,     text_color=_at_clr,  bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 3, text=_lSymTrend, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 3, text=_sym_txt,   text_color=_sym_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    _sep_live = mobileMode ? " LIVE" : "  LIVE  "
    table.cell(st, 0, 4, text=_sep_live, text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 4, text="",         text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 5, text=_lOpenPnl, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 5, text=_live_str, text_color=_live_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 6, text=_lEntry,   text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 6, text=_entryStr, text_color=_sideClr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 7, text=_lSLvl,  text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 7, text=_stopStr, text_color=sl_color,  bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 8, text=_lTP1Lvl, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 8, text=_tp1LStr, text_color=tp1_color, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 9, text=_lExit,   text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 9, text=_exitStr,  text_color=_exitClr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 10, text=_lExType,     text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 10, text=lastExitType, text_color=_typeClr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    table.cell(st, 0, 11, text="", bgcolor=_bg_sep, text_size=_tsz)
    table.cell(st, 1, 11, text="", bgcolor=_bg_sep, text_size=_tsz)

    _sep_bt = mobileMode ? " SIM ["+_lb_lbl+"]" : "  SIGNAL SIMULATION  ["+_lb_lbl+"]"
    table.cell(st, 0, 12, text=_sep_bt, text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 12, text="",      text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 13, text=_lStartDate, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 13, text=_start_str,  text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 14, text=_lClosed, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 14, text=str.tostring(_w_closed), text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 15, text=_lWR, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 15, text=str.tostring(_w_wr)+"%", text_color=_wr_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 16, text=_lTP1, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 16, text=(_pnl_tp1>=0?"+":"")+str.tostring(math.round(_pnl_tp1,2))+"u", text_color=presetBull, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 17, text=_lTP2, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 17, text=(_pnl_tp2>=0?"+":"")+str.tostring(math.round(_pnl_tp2,2))+"u", text_color=_pnl_tp2>=0?presetBull:presetBear, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 18, text=_lSL, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 18, text=(_pnl_stop>=0?"+":"")+str.tostring(math.round(_pnl_stop,2))+"u", text_color=presetBear, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 19, text=_lBE, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 19, text="+0u", text_color=color.orange, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    _sep_an = mobileMode ? " ANALYTICS" : "  SIMULATION ANALYTICS"
    table.cell(st, 0, 20, text=_sep_an, text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 20, text="",      text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 21, text=_lAvgRR, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 21, text=str.tostring(_avg_rr)+"R", text_color=_rr_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 22, text=_lBest, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 22, text="+"+str.tostring(math.round(_best_trade,2))+"u", text_color=presetBull, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    // ── NEW: Worst Signal row ──
    table.cell(st, 0, 23, text=_lWorst, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 23, text=str.tostring(math.round(_worst_trade,2))+"u", text_color=presetBear, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 24, text=_lWinS, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 24, text=str.tostring(_win_streak), text_color=presetBull, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 25, text=_lLosS, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 25, text=str.tostring(_loss_streak), text_color=presetBear, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    _sep_gvt = mobileMode ? " GRAND / TREND" : "  GRAND vs TREND BREAKDOWN"
    table.cell(st, 0, 26, text=_sep_gvt, text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 26, text="",       text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 27, text=_lGSig, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 27, text=str.tostring(_g_total), text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 28, text=_lGWR, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 28, text=str.tostring(_g_wr)+"%", text_color=_g_wr_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 29, text=_lGNet, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 29, text=(_g_pnl>=0?"+":"")+str.tostring(math.round(_g_pnl,2))+"u", text_color=_g_pnl>=0?presetBull:presetBear, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 30, text=_lTSig, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 30, text=str.tostring(_t_total), text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 31, text=_lTWR, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 31, text=str.tostring(_t_wr)+"%", text_color=_t_wr_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 32, text=_lTNet, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 32, text=(_t_pnl>=0?"+":"")+str.tostring(math.round(_t_pnl,2))+"u", text_color=_t_pnl>=0?presetBull:presetBear, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    _sep_tot = mobileMode ? " TOTAL" : "  SIMULATION TOTAL"
    table.cell(st, 0, 33, text=_sep_tot, text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 33, text="",       text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 34, text=_lRisk, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 34, text=str.tostring(tbl_risk,"#")+"u", text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    _net_bg = color.new(_pnl_clr, 85)
    table.cell(st, 0, 35, text=_lNet, text_color=_clr_title, bgcolor=_net_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 35, text=(_w_pnl>=0?"+":"")+str.tostring(math.round(_w_pnl,2))+"u", text_color=_pnl_clr, bgcolor=_net_bg, text_size=_tsz, text_halign=text.align_right)

    _sep_ti = mobileMode ? " TIME" : "  TIME INFO"
    table.cell(st, 0, 36, text=_sep_ti, text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 36, text="",      text_color=_clr_sep, bgcolor=_bg_sep, text_size=_tsz, text_halign=text.align_right)

    _now_user = str.format_time(timenow, "yyyy/MM/dd HH:mm", _tz)
    table.cell(st, 0, 37, text=_lTime, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 37, text=_now_user, text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)
    table.cell(st, 0, 38, text=_lTF, text_color=_clr_lbl, bgcolor=_bg, text_size=_tsz, text_halign=text.align_left)
    table.cell(st, 1, 38, text=timeframe.period, text_color=_clr_val, bgcolor=_bg, text_size=_tsz, text_halign=text.align_right)

    table.cell(st, 0, 39, text="", bgcolor=_bg_sep, text_size=_tsz)
    table.cell(st, 1, 39, text="", bgcolor=_bg_sep, text_size=_tsz)

    _d1 = mobileMode ? "Simulation only." : "Simulation for educational purposes only."
    table.cell(st, 0, 40, text=_d1, text_color=_disc_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_center)
    table.cell(st, 1, 40, text="",  text_color=_disc_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_center)

    _d2 = mobileMode ? "Not financial advice." : "Not financial advice. Past signals do not predict future results."
    table.cell(st, 0, 41, text=_d2, text_color=_disc_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_center)
    table.cell(st, 1, 41, text="",  text_color=_disc_clr, bgcolor=_bg, text_size=_tsz, text_halign=text.align_center)

// ═══════════════════════════════════════════════════════════════════
// 12. ALERT SETTINGS
// ═══════════════════════════════════════════════════════════════════
alert_long_enabled    = input.bool(true,  "LONG Entry Alert",                                    group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when a Grand Long or Trend Long signal triggers.")
alert_long_freq       = input.string("Once Per Bar Close", "LONG Alert Frequency",              group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for Long entries. 'Once Per Bar Close' waits for the bar to close before firing.")
alert_short_enabled   = input.bool(true,  "SHORT Entry Alert",                                group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when a Grand Short or Trend Short signal triggers.")
alert_short_freq      = input.string("Once Per Bar Close", "SHORT Alert Frequency",             group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for Short entries.")
alert_tp1_enabled     = input.bool(true,  "TP1 Partial Alert",                                group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when TP1 is hit and a partial close occurs.")
alert_tp1_freq        = input.string("Once Per Bar", "TP1 Partial Frequency",                   group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for TP1 partial exits.")
alert_tp1full_enabled = input.bool(true,  "TP1 Full Alert (100%)",                            group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when TP1 is hit at 100% close.")
alert_tp1full_freq    = input.string("Once Per Bar", "TP1 Full Frequency",                      group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for TP1 full exits.")
alert_tp2_enabled     = input.bool(true,  "TP2 Trailing Alert",                               group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when the trailing stop (TP2) is hit.")
alert_tp2_freq        = input.string("Once Per Bar", "TP2 Trailing Frequency",                  group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for TP2 trailing exits.")
alert_stop_enabled    = input.bool(true,  "Stop Loss Alert",                                  group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when the stop loss is hit.")
alert_stop_freq       = input.string("Once Per Bar Close", "Stop Loss Frequency",               group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for stop loss exits.")
alert_be_enabled      = input.bool(true,  "Breakeven Alert",                                  group="12 · Alert Settings",
     tooltip="Enable/disable the alert fired when the breakeven level is hit.")
alert_be_freq         = input.string("Once Per Bar Close", "Breakeven Frequency",               group="12 · Alert Settings",
     options=["Once Per Bar","Once Per Bar Close"],
     tooltip="Alert frequency for breakeven exits.")

_freq(f) => f == "Once Per Bar" ? alert.freq_once_per_bar : alert.freq_once_per_bar_close

// ═══════════════════════════════════════════════════════════════════
// ALERT FLAGS
// ═══════════════════════════════════════════════════════════════════
sig_long        = showGrandBuy
sig_short       = showGrandSell
sig_trend_long  = showTrendBuy
sig_trend_short = showTrendSell
sig_tp1_partial = (state[1]==1 and state==2) or (state[1]==-1 and state==-2)
_closed_now = state==0 and state[1]!=0
_from_entry = (state[1]==1 or state[1]==-1) and state==0
_from_trail = (state[1]==2 or state[1]==-2) and state==0
_sz2  = array.size(arr_type)
_last = _sz2 > 0 ? array.get(arr_type, _sz2-1) : 0
sig_stop     = _closed_now and _from_entry and _last == -1
sig_tp1_full = _closed_now and _from_entry and _last ==  1
sig_tp2      = _closed_now and _from_trail and _last ==  2
sig_be       = _closed_now and _from_trail and _last ==  3

// ═══════════════════════════════════════════════════════════════════
// ALERT DISPATCH
// ═══════════════════════════════════════════════════════════════════
if sig_be and alert_be_enabled
    alert('{"action":"BREAKEVEN","source":"nse","symbol":"' + syminfo.ticker + '"}', _freq(alert_be_freq))
if sig_stop and alert_stop_enabled
    alert('{"action":"STOP","source":"nse","symbol":"' + syminfo.ticker + '"}', _freq(alert_stop_freq))
if sig_tp2 and alert_tp2_enabled
    alert('{"action":"TP2","source":"nse","symbol":"' + syminfo.ticker + '"}', _freq(alert_tp2_freq))
if sig_tp1_full and alert_tp1full_enabled
    alert('{"action":"TP1_FULL","source":"nse","symbol":"' + syminfo.ticker + '"}', _freq(alert_tp1full_freq))
if sig_tp1_partial and alert_tp1_enabled
    alert('{"action":"TP1","source":"nse","symbol":"' + syminfo.ticker + '","close_pct":' + (tp1_pct=="50%"?"50":tp1_pct=="75%"?"75":"100") + '}', _freq(alert_tp1_freq))
if sig_trend_long and alert_long_enabled
    alert('{"action":"LONG","source":"nse_trend","symbol":"' + syminfo.ticker + '","entry":' + str.tostring(close) + ',"stop":' + str.tostring(stopLvl) + ',"tp1":' + str.tostring(rsi_ub_tp) + ',"tp1_pct":' + (tp1_pct=="50%"?"50":tp1_pct=="75%"?"75":"100") + ',"sl_mode":"' + sl_mode + '","tp1_mode":"' + tp_mode + '","trail_mode":"' + trail_mode + '"}', _freq(alert_long_freq))
if sig_trend_short and alert_short_enabled
    alert('{"action":"SHORT","source":"nse_trend","symbol":"' + syminfo.ticker + '","entry":' + str.tostring(close) + ',"stop":' + str.tostring(stopLvl) + ',"tp1":' + str.tostring(rsi_lb_tp) + ',"tp1_pct":' + (tp1_pct=="50%"?"50":tp1_pct=="75%"?"75":"100") + ',"sl_mode":"' + sl_mode + '","tp1_mode":"' + tp_mode + '","trail_mode":"' + trail_mode + '"}', _freq(alert_short_freq))
if sig_long and alert_long_enabled
    alert('{"action":"LONG","source":"nse_grand","symbol":"' + syminfo.ticker + '","entry":' + str.tostring(close) + ',"stop":' + str.tostring(stopLvl) + ',"tp1":' + str.tostring(rsi_ub_tp) + ',"tp1_pct":' + (tp1_pct=="50%"?"50":tp1_pct=="75%"?"75":"100") + ',"sl_mode":"' + sl_mode + '","tp1_mode":"' + tp_mode + '","trail_mode":"' + trail_mode + '"}', _freq(alert_long_freq))
if sig_short and alert_short_enabled
    alert('{"action":"SHORT","source":"nse_grand","symbol":"' + syminfo.ticker + '","entry":' + str.tostring(close) + ',"stop":' + str.tostring(stopLvl) + ',"tp1":' + str.tostring(rsi_lb_tp) + ',"tp1_pct":' + (tp1_pct=="50%"?"50":tp1_pct=="75%"?"75":"100") + ',"sl_mode":"' + sl_mode + '","tp1_mode":"' + tp_mode + '","trail_mode":"' + trail_mode + '"}', _freq(alert_short_freq))

// ═══════════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// ═══════════════════════════════════════════════════════════════════
alertcondition(sig_long,        title="NSE — LONG Entry",          message="NSE LONG {{ticker}} @ {{close}}")
alertcondition(sig_short,       title="NSE — SHORT Entry",         message="NSE SHORT {{ticker}} @ {{close}}")
alertcondition(sig_trend_long,  title="NSE — TREND LONG Entry",    message="NSE TREND LONG {{ticker}} @ {{close}}")
alertcondition(sig_trend_short, title="NSE — TREND SHORT Entry",   message="NSE TREND SHORT {{ticker}} @ {{close}}")
alertcondition(sig_tp1_partial, title="NSE — TP1 Partial",         message="NSE TP1 Partial {{ticker}}")
alertcondition(sig_tp1_full,    title="NSE — TP1 Full",            message="NSE TP1 Full {{ticker}}")
alertcondition(sig_tp2,         title="NSE — TP2 Trailing",        message="NSE TP2 {{ticker}}")
alertcondition(sig_stop,        title="NSE — Stop Loss",           message="NSE Stop {{ticker}}")
alertcondition(sig_be,          title="NSE — Breakeven",           message="NSE Breakeven {{ticker}}")
````
