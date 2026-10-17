# Exhaustion Volume Spike [forexobroker]

- url: https://www.tradingview.com/script/TWc9WOlC-Exhaustion-Volume-Spike-forexobroker/
- type: indicator
- pine_id: PUB;86c369348d514a5da4bd82360ed0be63
- version: 1.0

## Description

Not all volume spikes are created equal. A volume spike early in a trend signals continuation -- fresh money fueling the move. A volume spike late in a trend, with fading momentum, signals exhaustion -- the last gasp before reversal. This indicator classifies every volume spike and generates reversal signals on exhaustion events.

HOW IT WORKS

The indicator tracks trend direction (EMA20 vs EMA50), trend duration, ADX peak and decline, and momentum state. When a volume spike occurs, it classifies it:

Continuation Spike: Early in trend, ADX rising, momentum strong. Colored blue. Trend is healthy. Exhaustion Spike: Late in trend (20+ bars), ADX declining from peak, momentum waning. Colored amber. Reversal likely.

Buy signals fire after bearish exhaustion (sellers are spent). Sell signals fire after bullish exhaustion (buyers are spent).

FEATURES

Dual spike classification: continuation (blue) vs exhaustion (amber)
ADX peak tracking with configurable decline threshold
Trend duration monitoring with minimum bars requirement
Momentum divergence analysis
Continuation spikes shown as blue border boxes (informational)
Exhaustion signals with 3-layer neon glow
EXHAUST labels on reversal signals
Real-time dashboard: ADX, ADX peak, trend bars, trend direction, spike counts
Volume confirmation filter
11 alert conditions covering both spike types

SIGNAL LOGIC

Exhaustion classification requires ALL of:

Volume exceeds SMA by the spike multiplier
Trend has lasted at least the minimum bars
ADX has declined from its peak by the threshold amount
Momentum is waning (diverging from trend direction)
Bar must be confirmed (closed)
Then: Bullish signal = bearish trend exhaustion. Bearish signal = bullish trend exhaustion.

RECOMMENDED SETTINGS

Defaults are optimized for 4H and Daily charts. For 1H charts, reduce Min Bars in Trend to 15. For crypto, increase Volume Spike Multiplier to 2.5-3.0 due to higher baseline volatility. ADX Decline Threshold of 2.0 works across most instruments.

HOW TO USE

Blue boxes mark continuation spikes -- the trend is healthy, consider trend-following entries
Amber EXHAUST labels mark exhaustion reversals -- look for counter-trend entries
Monitor the ADX and Trend Bars in the dashboard for context
When ADX Peak is much higher than current ADX, the trend is mature
Combine exhaustion signals with support/resistance for precise entries

LIMITATIONS

Exhaustion spikes do not always lead to immediate reversals; price may consolidate first
ADX is inherently lagging; the decline may be detected after the optimal reversal point
Momentum analysis uses simple comparison which may produce false readings in choppy markets
Volume data quality varies between exchanges; crypto exchanges may show misleading volume
Classification is probabilistic, not deterministic
Signals are confirmed on bar close only
This indicator is a technical analysis tool and does not constitute financial advice
Past performance is not indicative of future results

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Exhaustion Volume Spike [forexobroker]", shorttitle="EVS [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
string g_vol    = "Volume Spike"
string g_trend  = "Trend Analysis"
string g_filter = "Filters"
string g_visual = "Visuals"
string g_table  = "Info Table"

float  volSpikeMult  = input.float(2.0, "Volume Spike Multiplier", minval=1.2, maxval=5.0, step=0.1, group=g_vol, tooltip="Volume must exceed SMA by this factor")
int    volSmaLen     = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_vol)
int    adxLen        = input.int(14, "ADX Length", minval=5, maxval=50, group=g_trend)
float  adxDecline    = input.float(2.0, "ADX Decline Threshold", minval=0.5, maxval=10.0, step=0.5, group=g_trend, tooltip="ADX must have declined by this amount from peak")
int    trendBarsMin  = input.int(20, "Min Bars in Trend", minval=5, maxval=100, group=g_trend, tooltip="How many bars into a move before exhaustion possible")
int    momentumLen   = input.int(14, "Momentum Length", minval=5, maxval=50, group=g_trend)
int    cooldown      = input.int(15, "Signal Cooldown Bars", minval=5, maxval=50, group=g_filter)
bool   showGlow      = input.bool(true, "Show Glow Effects", group=g_visual)
bool   showSpikes    = input.bool(true, "Show All Volume Spikes", group=g_visual, tooltip="Highlight continuation spikes too")
bool   showTable     = input.bool(true, "Show Info Table", group=g_table)
string tablePos      = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=g_table)

// ─── COLORS ───────────────────────────────────────────────────────────────────
color c_bull_core    = color.new(#00E676, 0)
color c_bull_mid     = color.new(#00E676, 55)
color c_bull_outer   = color.new(#00E676, 82)
color c_bear_core    = color.new(#FF5252, 0)
color c_bear_mid     = color.new(#FF5252, 55)
color c_bear_outer   = color.new(#FF5252, 82)
color c_continue     = color.new(#42A5F5, 0)
color c_continue_bg  = color.new(#42A5F5, 85)
color c_exhaust      = color.new(#FFAB00, 0)
color c_exhaust_bg   = color.new(#FFAB00, 85)
color c_none         = color.new(color.white, 100)

// ─── STATE ────────────────────────────────────────────────────────────────────
var int lastBullBar   = 0
var int lastBearBar   = 0
var int totalBullExh  = 0
var int totalBearExh  = 0
var int totalCont     = 0
var int totalExhaust  = 0
var float adxPeak     = 0.0
var int trendBars     = 0
var int trendDir      = 0

// ─── CALCULATIONS ─────────────────────────────────────────────────────────────
float volSma = ta.sma(volume, volSmaLen)
bool  isSpike = volume > volSma * volSpikeMult

// ADX
float trVal   = ta.tr(true)
float dmPlus  = high - high[1] > low[1] - low ? math.max(high - high[1], 0) : 0
float dmMinus = low[1] - low > high - high[1] ? math.max(low[1] - low, 0) : 0
float smTR    = ta.rma(trVal, adxLen)
float smPlus  = ta.rma(dmPlus, adxLen)
float smMinus = ta.rma(dmMinus, adxLen)
float diPlus  = smTR != 0 ? smPlus / smTR * 100 : 0
float diMinus = smTR != 0 ? smMinus / smTR * 100 : 0
float dx      = (diPlus + diMinus) != 0 ? math.abs(diPlus - diMinus) / (diPlus + diMinus) * 100 : 0
float adxVal  = ta.rma(dx, adxLen)

// Momentum
float mom = ta.mom(close, momentumLen)
float momSma = ta.sma(mom, momentumLen)

// Track trend direction and duration
float ema20 = ta.ema(close, 20)
float ema50 = ta.ema(close, 50)

if ema20 > ema50 and (trendDir != 1)
    trendDir  := 1
    trendBars := 0
    adxPeak   := adxVal

if ema20 < ema50 and (trendDir != -1)
    trendDir  := -1
    trendBars := 0
    adxPeak   := adxVal

trendBars += 1
if adxVal > adxPeak
    adxPeak := adxVal

// ─── CLASSIFY SPIKE ──────────────────────────────────────────────────────────
bool adxDeclining    = adxPeak - adxVal > adxDecline
bool momentumWaning  = (trendDir == 1 and mom < momSma) or (trendDir == -1 and mom > momSma)
bool deepInTrend     = trendBars > trendBarsMin

bool isExhaustion   = isSpike and deepInTrend and adxDeclining and momentumWaning and barstate.isconfirmed
bool isContinuation = isSpike and not isExhaustion and barstate.isconfirmed

// Bullish exhaustion = bearish trend exhausting (sellers tired) = buy signal
bool bullExhaustion = isExhaustion and trendDir == -1 and volume > volSma and (bar_index - lastBullBar > cooldown)
// Bearish exhaustion = bullish trend exhausting (buyers tired) = sell signal
bool bearExhaustion = isExhaustion and trendDir == 1 and volume > volSma and (bar_index - lastBearBar > cooldown)

if bullExhaustion
    lastBullBar  := bar_index
    totalBullExh += 1
    totalExhaust += 1

if bearExhaustion
    lastBearBar  := bar_index
    totalBearExh += 1
    totalExhaust += 1

if isContinuation
    totalCont += 1

// ─── CONTINUATION SPIKE MARKERS ──────────────────────────────────────────────
if isContinuation and showSpikes
    float halfRng = (high - low) * 0.15
    box.new(bar_index, high + halfRng, bar_index, low - halfRng, border_color=c_continue, bgcolor=c_continue_bg, border_width=1)

// ─── GLOW EFFECTS ────────────────────────────────────────────────────────────
float rng = high - low
if bullExhaustion and showGlow
    box.new(bar_index - 1, low - rng * 0.4, bar_index + 1, low + rng * 0.1, border_color=c_bull_outer, bgcolor=c_bull_outer)
    box.new(bar_index - 1, low - rng * 0.25, bar_index + 1, low + rng * 0.05, border_color=c_bull_mid, bgcolor=c_bull_mid)
    box.new(bar_index, low - rng * 0.1, bar_index, low, border_color=c_bull_core, bgcolor=color.new(#00E676, 70))

if bearExhaustion and showGlow
    box.new(bar_index - 1, high - rng * 0.1, bar_index + 1, high + rng * 0.4, border_color=c_bear_outer, bgcolor=c_bear_outer)
    box.new(bar_index - 1, high - rng * 0.05, bar_index + 1, high + rng * 0.25, border_color=c_bear_mid, bgcolor=c_bear_mid)
    box.new(bar_index, high, bar_index, high + rng * 0.1, border_color=c_bear_core, bgcolor=color.new(#FF5252, 70))

// ─── SIGNAL LABELS ───────────────────────────────────────────────────────────
plotshape(bullExhaustion, title="Bull Exhaustion", style=shape.labelup, location=location.belowbar, color=c_exhaust, size=size.normal, text="EXHAUST", textcolor=color.black)
plotshape(bearExhaustion, title="Bear Exhaustion", style=shape.labeldown, location=location.abovebar, color=c_exhaust, size=size.normal, text="EXHAUST", textcolor=color.black)

// ─── BAR COLORING ─────────────────────────────────────────────────────────────
color barCol = bullExhaustion ? c_bull_core : bearExhaustion ? c_bear_core : isContinuation and showSpikes ? c_continue : c_none
barcolor(barCol, title="Signal Bar Color")

// ─── BACKGROUND ───────────────────────────────────────────────────────────────
color bgCol = bullExhaustion ? color.new(#00E676, 92) : bearExhaustion ? color.new(#FF5252, 92) : c_none
bgcolor(bgCol, title="Signal Background")

// ─── INFO TABLE ──────────────────────────────────────────────────────────────
var table infoTable = na
tablePosition = tablePos == "Top Left" ? position.top_left : tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Left" ? position.bottom_left : position.bottom_right

if showTable and barstate.islast
    infoTable := table.new(tablePosition, 2, 8, bgcolor=color.new(#1a1a2e, 10), border_color=color.new(#FFAB00, 60), border_width=1)
    table.cell(infoTable, 0, 0, "Exhaustion Volume", text_color=color.white, text_size=size.small, bgcolor=color.new(#0d0d1a, 0))
    table.cell(infoTable, 1, 0, "", bgcolor=color.new(#0d0d1a, 0))
    table.cell(infoTable, 0, 1, "Bull Exhaustion", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 1, str.tostring(totalBullExh), text_color=c_bull_core, text_size=size.tiny)
    table.cell(infoTable, 0, 2, "Bear Exhaustion", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 2, str.tostring(totalBearExh), text_color=c_bear_core, text_size=size.tiny)
    table.cell(infoTable, 0, 3, "Continuation", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 3, str.tostring(totalCont), text_color=c_continue, text_size=size.tiny)
    table.cell(infoTable, 0, 4, "ADX", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 4, str.tostring(adxVal, "#.#"), text_color=adxDeclining ? c_exhaust : color.lime, text_size=size.tiny)
    table.cell(infoTable, 0, 5, "ADX Peak", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 5, str.tostring(adxPeak, "#.#"), text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 0, 6, "Trend Bars", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 6, str.tostring(trendBars), text_color=trendBars > trendBarsMin ? c_exhaust : color.white, text_size=size.tiny)
    string trendStr = trendDir == 1 ? "BULLISH" : trendDir == -1 ? "BEARISH" : "FLAT"
    color trendCol = trendDir == 1 ? c_bull_core : trendDir == -1 ? c_bear_core : color.gray
    table.cell(infoTable, 0, 7, "Trend", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 1, 7, trendStr, text_color=trendCol, text_size=size.tiny)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
if bullExhaustion
    alert("Bullish Exhaustion Spike on " + syminfo.ticker + " " + timeframe.period + " at " + str.tostring(close), alert.freq_once_per_bar_close)

if bearExhaustion
    alert("Bearish Exhaustion Spike on " + syminfo.ticker + " " + timeframe.period + " at " + str.tostring(close), alert.freq_once_per_bar_close)

alertcondition(bullExhaustion, title="Bull Exhaustion", message="Bullish Exhaustion Spike on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearExhaustion, title="Bear Exhaustion", message="Bearish Exhaustion Spike on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullExhaustion or bearExhaustion, title="Any Exhaustion", message="Exhaustion Volume Spike on {{ticker}} {{interval}} at {{close}}")
alertcondition(isContinuation, title="Continuation Spike", message="Continuation Volume Spike on {{ticker}} {{interval}} at {{close}}")
alertcondition(isSpike, title="Any Volume Spike", message="Volume Spike detected on {{ticker}} {{interval}} at {{close}}")
alertcondition(adxDeclining and isSpike, title="ADX Decline + Spike", message="ADX declining with volume spike on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullExhaustion and volume > volSma * 3, title="Extreme Bull Exhaust", message="Extreme Bullish Exhaustion on {{ticker}} {{interval}} at {{close}}")
alertcondition(bearExhaustion and volume > volSma * 3, title="Extreme Bear Exhaust", message="Extreme Bearish Exhaustion on {{ticker}} {{interval}} at {{close}}")
alertcondition(bullExhaustion or bearExhaustion, title="Exhaustion Webhook", message="Exhaustion signal on {{ticker}} {{interval}} price={{close}}")
````
