# Adaptive Flow II | Anonycryptous

- url: https://www.tradingview.com/script/qhPNoqfI-Adaptive-Flow-II-Anonycryptous/
- type: indicator
- pine_id: PUB;c6dc584535a14da8af1b9867ff510754
- version: 1.0

## Description

Adaptive Flow II | Anonycryptous
Description & user manual

Why this indicator is different
Most trend-following indicators use a fixed moving average. A 50-period EMA moves at the same speed whether the market is trending hard or grinding sideways. It cannot distinguish between a clean directional move and noise. It gives the same weight to a volatile consolidation as it does to a strong impulse. The result is signals that arrive late in trends and fire repeatedly during chop.

Adaptive Flow v2 works differently.
At its core is a Kaufman Adaptive Moving Average — a moving average that measures the efficiency of price movement on every single bar and adjusts its own speed accordingly. When price is moving cleanly in one direction with low noise, the flow line accelerates toward price. When price is churning sideways with high volatility and no direction, the flow line nearly stops moving. It adapts. Automatically. Without requiring any manual intervention.

V2 builds significantly on this foundation. It adds five configurable stop modes, full market structure detection through BOS and CHoCH events, three independent signal filters, dynamic extension bands, a session-anchored VWAP, and an expanded dashboard. The result is a complete adaptive trend and structure system — not just a trend indicator, but a context-aware trading framework.

Important notice
Adaptive Flow v2 generates signals based on technical indicator alignment.
These signals are not financial advice.
They do not predict the future.
They do not guarantee profitability.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Adaptive Flow v2 is an adaptive trend-following indicator built around a Kaufman Adaptive Moving Average with a configurable stop engine and full market structure detection.

What it includes:
- Kaufman Adaptive Moving Average rendered as a neon glow line with four stacked plot layers
- Five stop modes: ATR Trailing, Supertrend, Chandelier, Donchian, and Volatility Pivot
- Cloud fill between the flow line and the stop line, reflecting the current trend state
- Dynamic extension bands above and below the flow line at configurable ATR distance
- BOS and CHoCH structure detection with BOS confirmation filter
- Pivot high and low target lines that change color when broken
- EMA 200 macro trend filter with higher timeframe support
- ADX filter for directional environment confirmation
- Session filter to restrict signals to a configurable trading window
- Signal cooldown to prevent repeated triggering
- Session-anchored VWAP with daily and custom session modes
- Bar coloring reflecting the current trend state
- Three presets: default, fast, and smooth
- Live dashboard with 13 data rows
- Seven alert conditions

2. The flow line — Kaufman Adaptive Moving Average
The flow line is the visual heart of Adaptive Flow. On every bar it calculates an Efficiency Ratio — a measure of how directionally efficient price movement is relative to total volatility over the lookback period.

When the Efficiency Ratio is high — price is moving strongly in one direction with low noise — the flow line accelerates toward price. When the Efficiency Ratio is low — price is ranging with high volatility — the flow line nearly stops moving.

This adaptive behavior means the flow line naturally stays close to price during strong trends and pulls away only during genuine transitions. It is not a lagging average that mechanically follows price at a fixed delay. It responds to market character.

The flow line is rendered with four stacked plot layers — a sharp core at full opacity and three progressively wider, more transparent layers behind it — creating a neon glow effect that makes it visually distinct on any chart.

The noise filter adds an additional gate: KAMA only advances when the price displacement exceeds ATR × threshold. This prevents the flow line from reacting to insignificant micro-movements during low-momentum conditions. Disable it for maximum responsiveness in strong trending environments.

3. Stop engine — five modes
The stop engine calculates a dynamic stop level from the flow line. All five modes use the flow line as their reference point, not raw price. This means the stop inherits KAMA's adaptive smoothing before calculating any distance.
When the flow line crosses the stop level, the trend flips and a signal fires.

3.1 ATR Trailing (default)
The stop trails the flow line at a fixed ATR distance using a ratchet mechanism — it only moves in the direction of the trend and locks in the floor or ceiling. This produces the characteristic smooth, flowing wave that follows the flow line closely. The cloud between the flow line and the stop gives a live view of the trend zone width. Default and recommended for most users.

3.2 Supertrend
ATR band above or below the flow line with ratchet mechanism. Similar to ATR Trailing but calculated differently, producing a more angular step-like stop line. More angular appearance, fewer intermediate flips.

3.3 Chandelier
The stop trails the highest or lowest flow line value over a configurable lookback window, then subtracts or adds ATR × multiplier. Exits when the flow line has sustained a reversal beyond the lookback range. Better for trending markets where you want to trail a historical extreme rather than the current level.

3.4 Donchian
The stop follows the highest or lowest flow line value over a rolling window with no ATR component. Purely range-based. The stop level is exactly the rolling high or low of the flow line — clean, simple, no volatility scaling.

3.5 Volatility Pivot
The stop anchors to the last confirmed pivot high or low of the flow line plus an ATR buffer. Structurally aware — the stop sits at a level where the flow line previously reversed, not at an arbitrary distance. Best for traders who want the stop to respect structure rather than trail at a fixed distance.

4. Extension bands
When enabled, two bands are drawn above and below the flow line at ATR × multiplier distance. They are not stop levels — they are extension context. When price reaches the upper band during a bullish trend, it may indicate an overextended condition. When price compresses back toward the flow line after touching a band, it may indicate a pullback area. The bands move with the flow line and adapt to current volatility.

5. Market structure — BOS and CHoCH
Adaptive Flow v2 includes a full market structure detection engine that runs alongside the adaptive trend engine.

Pivot highs and lows are detected on price using configurable left and right bar lookbacks. When price closes beyond a confirmed swing level, the indicator classifies the event as either a Break of Structure or a Change of Character.
A BOS fires when price closes beyond a swing level in the direction of the existing structural trend — confirming continuation. Drawn as a dashed line
A CHoCH fires when price closes beyond a swing level against the existing structural trend — signaling a potential reversal. Drawn as a solid line.
The BOS confirmation requirement prevents false reversals. When set to 1 (default), at least one BOS must confirm the current structural trend before a CHoCH can flip it. This blocks the common false reversal where a sharp pullback briefly closes beyond a swing level before the trend reasserts.
Pivot target lines are drawn automatically at the last confirmed pivot high and low. They extend to the right and change color when price closes through them.

6. Signal filters
Three optional filters are available. All three can be combined. A signal only fires when all active filters agree.

EMA 200 — always active as a macro filter. Bullish signals only fire above the EMA 200. Bearish signals only below. Set the EMA 200 timeframe to a higher timeframe (1H or 4H) when trading on lower timeframes — the native EMA 200 on a 1-minute chart only covers a few hours and provides no meaningful macro context.

ADX filter — when enabled, signals only fire when ADX is at or above the configured threshold. Below this level the market is typically ranging and directional signals carry less weight. Default threshold of 20 removes the weakest trend environments.

Session filter — when enabled, signals only fire during the configured trading window. Defined in HHMM-HHMM format using exchange timezone. Outside the window the flow line continues calculating but no new signals are generated.

Signal cooldown — minimum bars between two signals in the same direction. Prevents repeated triggering during choppy conditions around the stop level.


7. VWAP
The VWAP provides a volume-weighted price reference that resets at the start of each session. It represents the average price paid weighted by volume — a key reference for intraday value and institutional order flow.

Daily mode resets every calendar day. Custom mode anchors to a specific session defined by start and end times in HHMM-HHMM format. Timezone selection ensures correct boundary alignment.

8. Presets
Three preset configurations are available. Selecting a preset overrides the core KAMA calculation parameters.

Default — balanced for swing trading on 4H and daily charts.
Adaptive length 14 | Fast constant 2 | Slow constant 30 | Noise threshold 0.3.

Fast — built for scalping on 1 to 15 minute charts.
Adaptive length 6 | Fast constant 2 | Slow constant 15 | Noise threshold 0.15.
Shorter lookback for faster momentum shift detection. Lower noise threshold preserves full adaptive speed.

Smooth — designed for position trading on daily and weekly charts.
Adaptive length 21 | Fast constant 3 | Slow constant 40 | Noise threshold 0.5.
Extended lookback demands sustained momentum before accelerating. Aggressive noise filtering for high-conviction reads only.

9. Dashboard
The dashboard displays the live state of all indicator components and updates on every bar.
Rows displayed:
- Adaptive Flow — indicator name with trend-colored header and current timeframe
- Trend — current flow line direction: bullish or bearish
- Stop Mode — active stop mode in use
- Structure — current structural direction from BOS/CHoCH logic
- EMA 200 — whether price is above or below the macro filter
- VWAP — whether price is above or below session value
- ADX — current ADX value with confirmation indicator
- Session — whether the session filter is active and the current bar is inside the window
- Noise Filter — whether the noise gate is active
- Stop Distance — distance from current close to stop level in ATR multiples and as a percentage
- Trend Bars — number of bars the current trend has been active
- BOS Count — number of confirmed BOS events in the current structural direction
- Signal — last signal fired: buy, sell, CHoCH, BOS, or none

10. Settings reference
KAMA & Calculation
- Price Source: input for the flow line calculation
- Adaptive Length: efficiency ratio lookback period
- Fast Constant: smoothing speed during trending conditions
- Slow Constant: smoothing speed during ranging conditions
- Enable Noise Filter: toggle the displacement gate
- Noise Threshold: minimum ATR multiple required to advance the flow line
- Preset: Default, Fast, or Smooth

Stop Engine
- Stop Mode: ATR Trailing, Supertrend, Chandelier, Donchian, or Volatility Pivot
- ATR Length: volatility measurement period
- ATR Multiplier: distance scaling for the stop level
- Stop Lookback: rolling window for Chandelier and Donchian modes
- Pivot Buffer: ATR buffer for Volatility Pivot mode

Market Structure
- Show BOS / CHoCH: toggle structure detection
- Pivot Left / Right Bars: swing confirmation lookback
- Max Structure Levels: maximum lines shown on chart
- BOS Required Before CHoCH Flip: false reversal filter
- Show Pivot Target Lines: toggle automatic target lines
- Target Line Color and Width

Signal Filters
- EMA 200 Timeframe: leave empty for chart timeframe
- Show EMA 200: toggle line and label visibility
- EMA 200 Color
- Enable ADX Filter: toggle directional environment gate
- ADX Length and Threshold
- Enable Session Filter: toggle session-based signal restriction
- Session Window: HHMM-HHMM format
- Signal Cooldown: bars between signals

VWAP
- Session: Daily or Custom
- Timezone: UTC, Exchange, or major financial center timezone
- Session Window: for Custom mode
- Show VWAP: toggle line and label
- VWAP Color

Visuals
- Bull Color and Bear Color
- Cloud Transparency: fill between flow line and stop
- Show Extension Bands: toggle ATR extension bands
- Extension Band Multiplier: distance from flow line
- Show Reversal Signals: toggle triangle markers
- Color Candles: toggle bar coloring
- Candle Transparency

Dashboard
- Show Dashboard
- Size: Tiny, Small, or Normal
- Position: Top Left, Top Right, Bottom Left, or Bottom Right

11. How to use
11.1 Initial setup

Select a preset matching your primary trading style. Set the EMA 200 timeframe to a higher timeframe when trading on lower timeframes — 60 for 1H, 240 for 4H. Set the VWAP to Daily or configure a custom session matching your primary market. Choose a stop mode — ATR Trailing is the default and works well across all timeframes. Enable the session filter and ADX filter if you want stricter signal conditions.

11.2 Reading the chart
The flow line and its glow indicate the current adaptive trend. Green indicates a bullish environment. Red indicates a bearish environment. The cloud between the flow line and the stop shows the trend zone width — a wide cloud indicates strong momentum, a narrowing cloud indicates the flow line is slowing.
The stop line is where the trend flips. A reversal signal fires when the flow line crosses it. Triangle markers appear at the stop line at the signal bar.
Extension bands show how far price has moved from adaptive value. Price at the upper band in a bullish trend may indicate overextension. Price returning toward the flow line after touching a band may offer a pullback reference.

BOS and CHoCH lines show structural context. Use them to understand whether the trend is in a confirmation phase (BOS firing repeatedly) or approaching a potential reversal (flow line slowing while price approaches a structural level).

11.3 Timeframe guide
1 to 5 minutes — Fast preset. EMA 200 timeframe set to 60 or 240. Session filter recommended.
15 to 30 minutes — Fast or Default preset. EMA 200 timeframe 240 or D.
1 hour to 4 hours — Default preset. Native EMA 200 or D timeframe.
Daily and above — Smooth preset. Native EMA 200.

11.4 Stop mode selection guide
ATR Trailing — best for most situations. Smooth, flowing, closely follows the flow line.
Supertrend — fewer flips, more angular. Good for lower timeframe noise reduction.
Chandelier — suited for trending markets where you want to trail a recent high or low.
Donchian — clean range-based stop with no ATR influence. Simple and transparent.
Volatility Pivot — best when you want the stop at a structurally meaningful KAMA level.

11.5 Context
Adaptive Flow v2 identifies adaptive trend direction and market structure. It does not filter by fundamental events, news, or macro calendar. A bullish signal during a risk-off macro event may fail more often than one in a clear trending environment. Always apply your own context and judgment alongside the indicator output.


12. Alerts
Seven alert conditions are available:

- Bull Trend: flow line crosses above the stop level, EMA 200 above, all active filters passed.
- Bear Trend: flow line crosses below the stop level, EMA 200 below, all active filters passed.
- Any Trend Change: fires on either bull or bear trend signal.
- Bull CHoCH: market structure flips to bullish via Change of Character.
- Bear CHoCH: market structure flips to bearish via Change of Character.
- Bull BOS: bullish Break of Structure confirms trend continuation.
- Bear BOS: bearish Break of Structure confirms trend continuation.
All alerts include exchange, ticker, and interval in the message.

13. Disclaimer
This indicator is provided for educational and informational purposes only.
All outputs are based on historical price action calculations and do not guarantee future results.
Trading financial instruments involves significant risk of loss.
Past performance does not indicate future results.
Use at your own discretion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6
indicator('Adaptive Flow II | Anonycryptous', shorttitle='Adaptive Flow II', overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ============================================================================
// INPUT GROUPS
// ============================================================================
var string G_CALC   = 'KAMA & Calculation'
var string G_STOP   = 'Stop Engine'
var string G_STRUCT = 'Market Structure'
var string G_FILTER = 'Signal Filters'
var string G_VWAP   = 'VWAP'
var string G_VIS    = 'Visuals'
var string G_DASH   = 'Dashboard'

// ============================================================================
// TOOLTIPS
// ============================================================================
var string tt_source    = 'Price input for all KAMA calculations. Close is standard. HL2 balances responsiveness with stability.'
var string tt_base_len  = 'Lookback period for the fastest KAMA strand. Each subsequent internal strand adds the step value. Shorter base = more reactive response to momentum shifts.'
var string tt_step      = 'Period increment between each of the 10 internal KAMA strands used to derive the adaptive midpoint. Larger steps create a wider spread between fast and slow calculations.'
var string tt_fast      = 'Fast smoothing constant for KAMA. Controls how aggressively the line tracks price during efficient trending conditions. Default of 2 is the standard fast constant.'
var string tt_slow      = 'Slow smoothing constant for KAMA. Controls how firmly the line anchors during ranging or noisy conditions. Default of 30 provides strong noise rejection.'
var string tt_noise     = 'When enabled, KAMA only advances when price displacement exceeds the noise threshold. Stabilizes the line during low-momentum conditions without removing adaptive behavior.'
var string tt_noise_thr = 'Minimum price change as a multiple of ATR required to advance KAMA. Lower values (0.1-0.2) preserve responsiveness. Higher values (0.5+) filter more noise.'
var string tt_preset    = 'Default: balanced for swing trading on 4H and daily charts.\nFast: built for scalping on 1-15m charts.\nSmooth: designed for position trading on daily and weekly charts.'
var string tt_stop_mode = 'Determines how the stop level is calculated from the KAMA line.\n\nATR Trailing (default): smooth flowing stop at KAMA ± ATR × multiplier. The original Adaptive Flow stop — velvety wave that follows KAMA closely.\n\nSupertrend: ATR band with ratchet — only moves in the direction of the trend. More angular, fewer flips.\n\nChandelier: stop trails the highest or lowest KAMA value over N bars plus ATR offset.\n\nDonchian: stop follows the highest or lowest KAMA value over a rolling window. No ATR.\n\nVolatility Pivot: stop anchors to the last confirmed KAMA swing level plus ATR buffer. Structurally aware.'
var string tt_atr_len   = 'ATR lookback period used by Volatility Pivot, Chandelier, and Supertrend stop modes for volatility scaling.'
var string tt_atr_mult  = 'ATR multiplier applied by the active stop mode. Higher values give the trend more room before flipping. Lower values produce tighter, more reactive stops.'
var string tt_stop_len  = 'Lookback window used by Chandelier and Donchian stop modes for their rolling KAMA high/low calculation.'
var string tt_piv_buf   = 'ATR buffer added above or below the confirmed KAMA swing level in Volatility Pivot mode. Prevents the stop from sitting exactly on the structural level.'
var string tt_struct    = 'Detects Break of Structure and Change of Character events on price using pivot-based swing levels. Solid lines for CHoCH, dashed lines for BOS.'
var string tt_piv       = 'Bars left and right required to confirm a swing high or low. Higher values produce fewer but more significant structure levels. Lower values produce more frequent but noisier signals.'
var string tt_maxlev    = 'Maximum number of BOS and CHoCH lines visible on the chart. Oldest lines are removed automatically when the limit is reached.'
var string tt_bosreq    = 'Minimum BOS confirmations required in the current trend before a CHoCH can flip structure. Default of 1 blocks false reversals from sharp pullbacks. Set to 0 for raw SMC behavior.'
var string tt_target    = 'Draws horizontal lines at the last confirmed pivot high and low as automatic reference levels. Lines change color when price closes through them.'
var string tt_ema200_tf = 'Timeframe for the EMA 200. Leave empty to use the chart timeframe. Set to 60 (1H), 240 (4H), or D (Daily) for macro filtering on lower timeframes.'
var string tt_adx       = 'When enabled, trend reversal signals only fire when ADX confirms a directional environment above the set threshold.'
var string tt_adx_thr   = 'Minimum ADX value required for a signal to fire. Default of 20 filters out the weakest trend conditions. Raise to 25-30 for stricter confirmation.'
var string tt_session   = 'When enabled, signals only fire during the configured session window. Outside the window KAMA continues calculating but no new signals are generated.'
var string tt_session_i = 'Session window in HHMM-HHMM format using exchange timezone. Example: 0930-1600 for NYSE cash session, 0800-1630 for London.'
var string tt_cooldown  = 'Minimum number of bars that must pass between two signals in the same direction. Prevents repeated triggering during choppy conditions around the stop level.'
var string tt_ribbon_t  = 'Unused.'
var string tt_cloud     = 'Transparency of the glow fill between KAMA and the stop line. Lower values create a more solid trend cloud.'
var string tt_bands     = 'Draws dynamic extension bands above and below KAMA at ATR x multiplier distance. Shows how far price has extended from adaptive value.'
var string tt_bands_m   = 'ATR multiplier for the extension bands. Higher values place the bands further from the ribbon, marking more extended price levels.'

// ============================================================================
// CALCULATION INPUTS
// ============================================================================
source      = input.source(close,     'Price Source',            group=G_CALC, tooltip=tt_source)
flowLen     = input.int(14,           'Adaptive Length',         group=G_CALC, minval=2, tooltip=tt_base_len)
fastLen     = input.int(2,            'Fast Constant',           group=G_CALC, minval=1, tooltip=tt_fast)
slowLen     = input.int(30,           'Slow Constant',           group=G_CALC, minval=2, tooltip=tt_slow)
noiseOn     = input.bool(true,        'Enable Noise Filter',     group=G_CALC, tooltip=tt_noise)
noiseThr    = input.float(0.3,        'Noise Threshold',         group=G_CALC, minval=0.0, step=0.1, tooltip=tt_noise_thr)
presetCfg   = input.string('Default', 'Preset',                  group=G_CALC, options=['Default','Fast','Smooth'], tooltip=tt_preset)

if presetCfg == 'Fast'
    flowLen  := 6
    fastLen  := 2
    slowLen  := 15
    noiseThr := 0.15
else if presetCfg == 'Smooth'
    flowLen  := 21
    fastLen  := 3
    slowLen  := 40
    noiseThr := 0.5

// ============================================================================
// STOP ENGINE INPUTS
// ============================================================================
stopMode    = input.string('ATR Trailing', 'Stop Mode',      group=G_STOP, options=['ATR Trailing','Volatility Pivot','Chandelier','Supertrend','Donchian'], tooltip=tt_stop_mode)
atrLen      = input.int(14,           'ATR Length',              group=G_STOP, minval=1, tooltip=tt_atr_len)
atrMult     = input.float(2.5,        'ATR Multiplier',          group=G_STOP, minval=0.1, step=0.1, tooltip=tt_atr_mult)
stopLen     = input.int(20,           'Stop Lookback',           group=G_STOP, minval=2, tooltip=tt_stop_len)
pivBuf      = input.float(0.5,        'Pivot Buffer',            group=G_STOP, minval=0.0, step=0.1, tooltip=tt_piv_buf)

// ============================================================================
// STRUCTURE INPUTS
// ============================================================================
showStruct  = input.bool(true,        'Show BOS / CHoCH',        group=G_STRUCT, tooltip=tt_struct)
pivLeft     = input.int(10,           'Pivot Left Bars',          group=G_STRUCT, minval=1, maxval=50, tooltip=tt_piv)
pivRight    = input.int(10,           'Pivot Right Bars',         group=G_STRUCT, minval=1, maxval=50, tooltip=tt_piv)
maxLevels   = input.int(5,            'Max Structure Levels',     group=G_STRUCT, minval=1, maxval=20, tooltip=tt_maxlev)
bosRequired = input.int(1,            'BOS Required Before CHoCH Flip', group=G_STRUCT, minval=0, maxval=5, tooltip=tt_bosreq)
showTargets = input.bool(false,       'Show Pivot Target Lines',  group=G_STRUCT, tooltip=tt_target)
targetColor = input.color(color.new(#808080, 0), 'Target Line Color', group=G_STRUCT)
targetWidth = input.int(1,            'Target Line Width',        group=G_STRUCT, minval=1, maxval=3)

// ============================================================================
// SIGNAL FILTER INPUTS
// ============================================================================
ema200Tf    = input.timeframe('',     'EMA 200 Timeframe',       group=G_FILTER, tooltip=tt_ema200_tf)
showEma200  = input.bool(true,        'Show EMA 200',            group=G_FILTER)
ema200Color = input.color(#ffffff,    'EMA 200 Color',           group=G_FILTER)
adxOn       = input.bool(false,       'Enable ADX Filter',       group=G_FILTER, tooltip=tt_adx)
adxLength   = input.int(14,           'ADX Length',              group=G_FILTER, minval=1)
adxThr      = input.float(20,         'ADX Threshold',           group=G_FILTER, minval=1, step=1, tooltip=tt_adx_thr)
sessionOn   = input.bool(false,       'Enable Session Filter',   group=G_FILTER, tooltip=tt_session)
sessionInp  = input.session('0930-1600', 'Session Window',       group=G_FILTER, tooltip=tt_session_i)
cooldown    = input.int(3,            'Signal Cooldown (bars)',   group=G_FILTER, minval=0, tooltip=tt_cooldown)

// ============================================================================
// VWAP INPUTS
// ============================================================================
vwapSession = input.string('Daily',   'Session',                 group=G_VWAP, options=['Daily','Custom'])
vwapTz      = input.string('UTC',     'Timezone',                group=G_VWAP, options=['UTC','Exchange','America/New_York','Europe/London','Europe/Amsterdam','Asia/Tokyo','Asia/Singapore','Asia/Hong_Kong','Europe/Frankfurt'])
vwapStart   = input.session('0000-2359', 'Session Window',       group=G_VWAP)
showVwap    = input.bool(true,        'Show VWAP',               group=G_VWAP)
vwapColor   = input.color(#f5c518,    'VWAP Color',              group=G_VWAP)

// ============================================================================
// VISUAL INPUTS
// ============================================================================
bullColorIn = input.color(color.rgb(0,255,0),  'Bull Color',     group=G_VIS)
bearColorIn = input.color(color.rgb(255,0,0),  'Bear Color',     group=G_VIS)
cloudTrans  = input.int(85,           'Cloud Transparency',       group=G_VIS, minval=0, maxval=100, tooltip=tt_cloud)
showBands   = input.bool(true,        'Show Extension Bands',     group=G_VIS, tooltip=tt_bands)
bandsMult   = input.float(1.5,        'Extension Band Multiplier',group=G_VIS, minval=0.1, step=0.1, tooltip=tt_bands_m)
showShapes  = input.bool(true,        'Show Reversal Signals',    group=G_VIS)
barColorOn  = input.bool(true,        'Color Candles',            group=G_VIS)
barTrans    = input.int(35,           'Candle Transparency',      group=G_VIS, minval=0, maxval=100)

// ============================================================================
// DASHBOARD INPUTS
// ============================================================================
showDash    = input.bool(true,        'Show Dashboard',           group=G_DASH)
dashSize    = input.string('Tiny',    'Size',                     group=G_DASH, options=['Tiny','Small','Normal'])
dashPos     = input.string('Bottom Right', 'Position',            group=G_DASH, options=['Top Left','Top Right','Bottom Left','Bottom Right'])

// ============================================================================
// ADAPTIVE FLOW ENGINE — Kaufman Adaptive Moving Average
// ============================================================================
atr     = ta.atr(atrLen)
fSC     = 2.0 / (fastLen + 1)
sSC     = 2.0 / (slowLen  + 1)

flowDir = math.abs(source - source[flowLen])
flowVol = math.sum(math.abs(source - source[1]), flowLen)
flowER  = flowVol != 0 ? flowDir / flowVol : 0.0
flowSC  = math.pow(flowER * (fSC - sSC) + sSC, 2)

var float flowLine = na
if na(flowLine)
    flowLine := source
else
    rawFlow = flowLine[1] + flowSC * (source - flowLine[1])
    if noiseOn
        if math.abs(rawFlow - flowLine[1]) > atr * noiseThr
            flowLine := rawFlow
    else
        flowLine := rawFlow

// flowLine is the single adaptive trend line — used as reference for all stop modes
kamaMid = flowLine

// ============================================================================
// TREND DIRECTION (from midpoint crossing ribbon center)
// ============================================================================
var int trend = 1

// ============================================================================
// STOP ENGINE — all modes operate on kamaMid
// ============================================================================
var float stopLine  = na
var float pivKamaH  = na
var float pivKamaL  = na

// Chandelier: highest/lowest kamaMid over stopLen
chanHigh = ta.highest(kamaMid, stopLen)
chanLow  = ta.lowest (kamaMid, stopLen)

// Donchian: highest/lowest kamaMid over stopLen (same calc, no ATR)
donHigh  = ta.highest(kamaMid, stopLen)
donLow   = ta.lowest (kamaMid, stopLen)

// Volatility Pivot: track KAMA swings
kamaH = ta.pivothigh(kamaMid, pivLeft, pivRight)
kamaL = ta.pivotlow (kamaMid, pivLeft, pivRight)
if not na(kamaH)
    pivKamaH := kamaMid[pivRight]
if not na(kamaL)
    pivKamaL := kamaMid[pivRight]

if na(stopLine)
    stopLine := kamaMid - atr * atrMult

// ATR Trailing — original smooth flowing stop (KAMA ± ATR × multiplier, ratchet)
if stopMode == 'ATR Trailing'
    if trend == 1
        if kamaMid < stopLine
            trend    := -1
            stopLine := kamaMid + atr * atrMult
        else
            stopLine := math.max(stopLine, kamaMid - atr * atrMult)
    else
        if kamaMid > stopLine
            trend    := 1
            stopLine := kamaMid - atr * atrMult
        else
            stopLine := math.min(stopLine, kamaMid + atr * atrMult)

// Supertrend on kamaMid
else if stopMode == 'Supertrend'
    if trend == 1
        if kamaMid < stopLine
            trend    := -1
            stopLine := kamaMid + atr * atrMult
        else
            stopLine := math.max(stopLine, kamaMid - atr * atrMult)
    else
        if kamaMid > stopLine
            trend    := 1
            stopLine := kamaMid - atr * atrMult
        else
            stopLine := math.min(stopLine, kamaMid + atr * atrMult)

// Chandelier on kamaMid
else if stopMode == 'Chandelier'
    if trend == 1
        newStop = chanHigh - atr * atrMult
        if kamaMid < newStop
            trend    := -1
            stopLine := chanLow + atr * atrMult
        else
            stopLine := math.max(stopLine, newStop)
    else
        newStop = chanLow + atr * atrMult
        if kamaMid > newStop
            trend    := 1
            stopLine := chanHigh - atr * atrMult
        else
            stopLine := math.min(stopLine, newStop)

// Donchian on kamaMid (no ATR)
else if stopMode == 'Donchian'
    if trend == 1
        if kamaMid < donLow
            trend    := -1
            stopLine := donHigh
        else
            stopLine := math.max(stopLine, donLow)
    else
        if kamaMid > donHigh
            trend    := 1
            stopLine := donLow
        else
            stopLine := math.min(stopLine, donHigh)

// Volatility Pivot — stop on last confirmed KAMA swing + ATR buffer
else
    if trend == 1
        newStop = not na(pivKamaL) ? pivKamaL - atr * pivBuf : kamaMid - atr * atrMult
        if kamaMid < newStop
            trend    := -1
            stopLine := not na(pivKamaH) ? pivKamaH + atr * pivBuf : kamaMid + atr * atrMult
        else
            stopLine := math.max(stopLine, newStop)
    else
        newStop = not na(pivKamaH) ? pivKamaH + atr * pivBuf : kamaMid + atr * atrMult
        if kamaMid > newStop
            trend    := 1
            stopLine := not na(pivKamaL) ? pivKamaL - atr * pivBuf : kamaMid - atr * atrMult
        else
            stopLine := math.min(stopLine, newStop)

// ============================================================================
// EMA 200 + ADX + SESSION
// ============================================================================
ema200      = request.security(syminfo.tickerid, ema200Tf == '' ? timeframe.period : ema200Tf, ta.ema(source, 200), lookahead=barmerge.lookahead_off)
aboveEma200 = source > ema200
belowEma200 = source < ema200

[diPlus, diMinus, adxVal] = ta.dmi(adxLength, adxLength)
adxOk    = not adxOn or adxVal >= adxThr
inSession = not sessionOn or not na(time(timeframe.period, sessionInp, syminfo.timezone))

// ============================================================================
// VWAP
// ============================================================================
_tz          = vwapTz == 'Exchange' ? syminfo.timezone : vwapTz
isNewSession = vwapSession == 'Daily' ? ta.change(time('D', _tz)) != 0 : ta.change(time(timeframe.period, vwapStart, _tz)) != 0
isInSess2    = vwapSession == 'Daily' ? true : not na(time(timeframe.period, vwapStart, _tz))

var float cumTPV = 0.0
var float cumVol = 0.0
typPrice = (high + low + close) / 3
if isNewSession
    cumTPV := typPrice * volume
    cumVol := volume
else if isInSess2
    cumTPV += typPrice * volume
    cumVol += volume
vwap = cumVol != 0 ? cumTPV / cumVol : na

// ============================================================================
// SIGNAL COOLDOWN + FINAL SIGNALS
// ============================================================================
var int barsSinceBull = 999
var int barsSinceBear = 999
barsSinceBull += 1
barsSinceBear += 1

rawBull = trend == 1 and trend[1] == -1 and aboveEma200 and adxOk and inSession
rawBear = trend == -1 and trend[1] == 1 and belowEma200 and adxOk and inSession

bullSignal = rawBull and barsSinceBull >= cooldown
bearSignal = rawBear and barsSinceBear >= cooldown

if bullSignal
    barsSinceBull := 0
if bearSignal
    barsSinceBear := 0

trendColor = trend == 1 ? bullColorIn : bearColorIn

// ============================================================================
// STRUCTURE ENGINE
// ============================================================================
pivH = ta.pivothigh(high, pivLeft, pivRight)
pivL = ta.pivotlow (low,  pivLeft, pivRight)

var float lastSwingH  = na
var float lastSwingL  = na
var int   lastSwingHB = na
var int   lastSwingLB = na

var int structTrend  = 0
var int bullBosCount = 0
var int bearBosCount = 0

var array<line>  bosLines   = array.new<line>()
var array<label> bosLabels  = array.new<label>()
var array<line>  chLines    = array.new<line>()
var array<label> chLabels   = array.new<label>()

bool isBullEvent  = false
bool isBearEvent  = false
bool isBosEvent   = false
bool isChochEvent = false

bullCol = bullColorIn
bearCol = bearColorIn

if showStruct and (not na(lastSwingH) and close > lastSwingH or not na(lastSwingL) and close < lastSwingL)
    if not na(lastSwingH) and close > lastSwingH
        if structTrend == 1
            isBosEvent  := true
            isBullEvent := true
            bullBosCount += 1
            b = line.new(lastSwingHB, lastSwingH, bar_index, lastSwingH,
                 color=color.new(bullCol, 20), style=line.style_dashed, width=1)
            l = label.new(lastSwingHB, lastSwingH, 'BOS',
                 color=color.new(color.black, 100), textcolor=bullCol,
                 style=label.style_label_right, size=size.tiny)
            array.push(bosLines, b)
            array.push(bosLabels, l)
            if array.size(bosLines) > maxLevels
                line.delete(array.shift(bosLines))
                label.delete(array.shift(bosLabels))
        else if bearBosCount >= bosRequired
            isChochEvent := true
            isBullEvent  := true
            structTrend  := 1
            bullBosCount := 0
            bearBosCount := 0
            b = line.new(lastSwingHB, lastSwingH, bar_index, lastSwingH,
                 color=color.new(bullCol, 20), style=line.style_solid, width=1)
            l = label.new(lastSwingHB, lastSwingH, 'CHoCH',
                 color=color.new(color.black, 100), textcolor=bullCol,
                 style=label.style_label_right, size=size.tiny)
            array.push(chLines, b)
            array.push(chLabels, l)
            if array.size(chLines) > maxLevels
                line.delete(array.shift(chLines))
                label.delete(array.shift(chLabels))
    else if not na(lastSwingL) and close < lastSwingL
        if structTrend == -1
            isBosEvent  := true
            isBearEvent := true
            bearBosCount += 1
            b = line.new(lastSwingLB, lastSwingL, bar_index, lastSwingL,
                 color=color.new(bearCol, 20), style=line.style_dashed, width=1)
            l = label.new(lastSwingLB, lastSwingL, 'BOS',
                 color=color.new(color.black, 100), textcolor=bearCol,
                 style=label.style_label_right, size=size.tiny)
            array.push(bosLines, b)
            array.push(bosLabels, l)
            if array.size(bosLines) > maxLevels
                line.delete(array.shift(bosLines))
                label.delete(array.shift(bosLabels))
        else if bullBosCount >= bosRequired
            isChochEvent := true
            isBearEvent  := true
            structTrend  := -1
            bullBosCount := 0
            bearBosCount := 0
            b = line.new(lastSwingLB, lastSwingL, bar_index, lastSwingL,
                 color=color.new(bearCol, 20), style=line.style_solid, width=1)
            l = label.new(lastSwingLB, lastSwingL, 'CHoCH',
                 color=color.new(color.black, 100), textcolor=bearCol,
                 style=label.style_label_right, size=size.tiny)
            array.push(chLines, b)
            array.push(chLabels, l)
            if array.size(chLines) > maxLevels
                line.delete(array.shift(chLines))
                label.delete(array.shift(chLabels))

if not na(pivH)
    lastSwingH  := high[pivRight]
    lastSwingHB := bar_index - pivRight
if not na(pivL)
    lastSwingL  := low[pivRight]
    lastSwingLB := bar_index - pivRight

// ============================================================================
// PIVOT TARGET LINES
// ============================================================================
var line targH = na
var line targL = na

if showTargets
    if not na(pivH)
        if not na(targH)
            line.set_x2(targH, bar_index - pivRight)
        targH := line.new(bar_index - pivRight, high[pivRight], bar_index, high[pivRight],
             color=targetColor, style=line.style_solid, width=targetWidth)
    if not na(pivL)
        if not na(targL)
            line.set_x2(targL, bar_index - pivRight)
        targL := line.new(bar_index - pivRight, low[pivRight], bar_index, low[pivRight],
             color=targetColor, style=line.style_solid, width=targetWidth)
    if not na(targH)
        if close > line.get_y1(targH)
            line.set_color(targH, bullCol)
        line.set_x2(targH, bar_index)
    if not na(targL)
        if close < line.get_y1(targL)
            line.set_color(targL, bearCol)
        line.set_x2(targL, bar_index)

// ============================================================================
// TREND BAR COUNTER + DISTANCE TO STOP
// ============================================================================
var int trendBars = 0
if trend != trend[1]
    trendBars := 1
else
    trendBars += 1

distAtr = math.abs(close - stopLine) / atr
distPct = math.abs(close - stopLine) / close * 100

// ============================================================================
// LABELS
// ============================================================================
if showEma200 and barstate.islast
    label.new(bar_index + 3, ema200, 'EMA 200: ' + str.tostring(ema200, format.mintick),
         color=color.new(ema200Color, 80), textcolor=ema200Color,
         style=label.style_label_left, size=size.tiny)

if showVwap and barstate.islast and not na(vwap)
    label.new(bar_index + 3, vwap, 'VWAP: ' + str.tostring(vwap, format.mintick),
         color=color.new(vwapColor, 80), textcolor=vwapColor,
         style=label.style_label_left, size=size.tiny)

// ============================================================================
// PLOTS — NEON GLOW ADAPTIVE FLOW LINE
// ============================================================================
// Four plots on the same flow line — core sharp, glow layers fade outward
pGlow3 = plot(flowLine, 'Flow Glow 3', color=color.new(trendColor, 88), linewidth=8)
pGlow2 = plot(flowLine, 'Flow Glow 2', color=color.new(trendColor, 72), linewidth=5)
pGlow1 = plot(flowLine, 'Flow Glow 1', color=color.new(trendColor, 50), linewidth=3)
pFlow  = plot(flowLine, 'Flow Core',   color=color.new(trendColor, 0),  linewidth=2)

// Stop line
pStop  = plot(stopLine, 'Stop Line', color=trendColor, linewidth=2)
pFill  = plot(flowLine, 'Fill Ref',  display=display.none)

// Cloud fill between flow line and stop
fill(pStop, pFill, stopLine, flowLine, color.new(trendColor, cloudTrans), color.new(trendColor, 100), 'Trend Cloud')

// Extension bands
plot(showBands ? flowLine + atr * bandsMult : na, 'Upper Band', color=color.new(trendColor, 75), linewidth=1)
plot(showBands ? flowLine - atr * bandsMult : na, 'Lower Band', color=color.new(trendColor, 75), linewidth=1)

// EMA 200 + VWAP
plot(showEma200 ? ema200 : na, 'EMA 200', color=ema200Color, linewidth=1)
plot(showVwap   ? vwap   : na, 'VWAP',    color=vwapColor,   linewidth=1)

// Signals — single core
plotshape(showShapes and bullSignal ? stopLine : na, 'Bull Signal',
     shape.triangleup, location.absolute, bullColorIn, size=size.tiny)
plotshape(showShapes and bearSignal ? stopLine : na, 'Bear Signal',
     shape.triangledown, location.absolute, bearColorIn, size=size.tiny)

barcolor(barColorOn ? color.new(trendColor, barTrans) : na, title='Bar Color')

// ============================================================================
// DASHBOARD
// ============================================================================
var table dash = table.new(position.bottom_right, 2, 14,
     bgcolor=color.new(#0d1117, 10),
     border_color=color.new(#30363d, 20), border_width=1,
     frame_color=color.new(#30363d, 40), frame_width=1)

if showDash and barstate.islast
    ds = dashSize == 'Tiny' ? size.tiny : dashSize == 'Small' ? size.small : size.normal
    dP = switch dashPos
        'Top Left'     => position.top_left
        'Top Right'    => position.top_right
        'Bottom Left'  => position.bottom_left
        =>               position.bottom_right
    table.set_position(dash, dP)

    cM    = color.new(#8b949e, 0)
    cW    = color.new(#ffffff, 0)
    cP    = color.new(#161b22, 0)
    cH    = color.new(trendColor, 75)
    cBull = bullColorIn
    cBear = bearColorIn

    // Row 0 — Header
    table.cell(dash, 0, 0, 'Adaptive Flow', text_color=cW, text_size=ds, bgcolor=cH, text_halign=text.align_left)
    table.cell(dash, 1, 0, timeframe.period, text_color=color.new(trendColor, 0), text_size=ds, bgcolor=cH, text_halign=text.align_right)

    // Row 1 — Trend
    table.cell(dash, 0, 1, 'Trend', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 1, trend == 1 ? '▲ Bullish' : '▼ Bearish', text_color=trend == 1 ? cBull : cBear, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 2 — Stop mode
    table.cell(dash, 0, 2, 'Stop Mode', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 2, stopMode, text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 3 — Structure
    structStr = structTrend == 1 ? '▲ Bull struct' : structTrend == -1 ? '▼ Bear struct' : '— None'
    structCol = structTrend == 1 ? cBull : structTrend == -1 ? cBear : cM
    table.cell(dash, 0, 3, 'Structure', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 3, structStr, text_color=structCol, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 4 — EMA 200
    table.cell(dash, 0, 4, 'EMA 200', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 4, aboveEma200 ? '▲ Above' : '▼ Below', text_color=aboveEma200 ? cBull : cBear, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 5 — VWAP
    vwapStr2 = not na(vwap) ? (close > vwap ? '▲ Above' : '▼ Below') : '— N/A'
    vwapCol2 = not na(vwap) ? (close > vwap ? cBull : cBear) : cM
    table.cell(dash, 0, 5, 'VWAP', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 5, vwapStr2, text_color=vwapCol2, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 6 — ADX
    adxStr = adxOn ? str.tostring(math.round(adxVal, 1)) + (adxVal >= adxThr ? ' ✓' : ' ✗') : 'Off'
    adxCol = adxOn ? (adxVal >= adxThr ? cBull : cBear) : cM
    table.cell(dash, 0, 6, 'ADX', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 6, adxStr, text_color=adxCol, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 7 — Session
    sessStr = not sessionOn ? 'Off' : inSession ? '▶ Active' : '— Closed'
    sessCol = not sessionOn ? cM : inSession ? cBull : cM
    table.cell(dash, 0, 7, 'Session', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 7, sessStr, text_color=sessCol, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 8 — Noise filter
    table.cell(dash, 0, 8, 'Noise Filter', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 8, noiseOn ? 'On' : 'Off', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 9 — Stop distance
    table.cell(dash, 0, 9, 'Stop Distance', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(math.round(distAtr, 2)) + ' ATR  ' + str.tostring(math.round(distPct, 2)) + '%', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 10 — Trend bars
    table.cell(dash, 0, 10, 'Trend Bars', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(trendBars), text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 11 — BOS count
    bosStr = structTrend == 1 ? str.tostring(bullBosCount) + ' bull' : structTrend == -1 ? str.tostring(bearBosCount) + ' bear' : '—'
    table.cell(dash, 0, 11, 'BOS Count', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 11, bosStr, text_color=structCol, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 12 — Signal
    sigStr = bullSignal ? '▲ Buy' : bearSignal ? '▼ Sell' : isChochEvent ? (isBullEvent ? '▲ CHoCH' : '▼ CHoCH') : isBosEvent ? (isBullEvent ? '▲ BOS' : '▼ BOS') : '— None'
    sigCol = bullSignal ? cBull : bearSignal ? cBear : isChochEvent or isBosEvent ? (isBullEvent ? cBull : cBear) : cM
    table.cell(dash, 0, 12, 'Signal', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 12, sigStr, text_color=sigCol, text_size=ds, bgcolor=cP, text_halign=text.align_right)

    // Row 13 — Brand
    table.cell(dash, 0, 13, 'ANONYCRYPTOUS', text_color=color.new(#bb86fc, 0), text_size=ds, bgcolor=cP, text_halign=text.align_left)
    table.cell(dash, 1, 13, 'v2.0', text_color=cM, text_size=ds, bgcolor=cP, text_halign=text.align_right)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(bullSignal,                    title='Bull Trend',  message='Adaptive Flow: BULLISH on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bearSignal,                    title='Bear Trend',  message='Adaptive Flow: BEARISH on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(bullSignal or bearSignal,      title='Any Trend Change', message='Adaptive Flow: Trend reversal on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(isChochEvent and isBullEvent,  title='Bull CHoCH', message='Adaptive Flow: BULLISH CHoCH on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(isChochEvent and isBearEvent,  title='Bear CHoCH', message='Adaptive Flow: BEARISH CHoCH on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(isBosEvent and isBullEvent,    title='Bull BOS',   message='Adaptive Flow: BULL BOS on {{exchange}}:{{ticker}} - {{interval}}')
alertcondition(isBosEvent and isBearEvent,    title='Bear BOS',   message='Adaptive Flow: BEAR BOS on {{exchange}}:{{ticker}} - {{interval}}')
````
