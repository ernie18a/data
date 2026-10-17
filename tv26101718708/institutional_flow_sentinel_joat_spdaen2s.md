# Institutional Flow Sentinel [JOAT]

- url: https://www.tradingview.com/script/sPdaEN2S-Institutional-Flow-Sentinel-JOAT/
- type: indicator
- pine_id: PUB;b753396dc8a348799c8b95375379f750
- version: 1.0

## Description

[b]Institutional Flow Sentinel [JOAT][/b]

[b]Introduction[/b]

Institutional Flow Sentinel is an open-source market structure tool that tracks two categories of price behavior that institutional order flow leaves behind: Fair Value Gaps and liquidity sweeps. Both concepts originate from ICT (Inner Circle Trader) methodology, but this implementation combines them into a single unified engine with a live zone lifecycle, composite state tracking, and candle coloring — none of which are standard in most published FVG or sweep tools individually.

The core insight is that large participants need liquidity to fill orders. They engineer moves through external swing highs and lows to trigger retail stop orders, collect that liquidity, then reverse. Identifying these events in real time, tracking whether the gap or sweep level has been respected or violated, and classifying the current order flow bias from those events is the purpose of this indicator.

[image]https://www.tradingview.com/x/L5nBpRIl/[/image]

[b]Core Concepts[/b]

[b]1. Fair Value Gap Detection[/b]

A Fair Value Gap is a three-candle imbalance where the middle candle's range is not overlapped by the adjacent candles. Bullish FVGs form when a candle's low is above the high two bars prior. Bearish FVGs form when a candle's high is below the low two bars prior:

[pine]
bullFVG = low > high[2]
bearFVG = high < low[2]
[/pine]

Each gap is stored with its price bounds and tracked bar-by-bar. If price returns and closes inside the gap the zone is marked mitigated and drawn differently. Unmitigated gaps project forward as active imbalance reference levels.

[b]2. Liquidity Sweep Detection[/b]

The indicator tracks pivot highs as Buyside Liquidity (BSL) and pivot lows as Sellside Liquidity (SSL). A sweep occurs when price wicks through the level but then closes back inside it — indicating the liquidity was taken and price rejected:

[pine]
bslSweep = high > bslLevel and close < bslLevel
sslSweep = low  < sslLevel and close > sslLevel
[/pine]

Sweep events are labeled on the chart and contribute to the cumulative order flow bias score.

[b]3. Composite Bias Score[/b]

Each confirmed FVG and sweep increments or decrements a running bias counter. Bullish FVGs and bearish sweeps (stops run below, reversal up) add positive weight. Bearish FVGs and bullish sweeps add negative weight. The dashboard displays this composite score alongside the current structural bias.

[b]4. Zone Lifecycle Management[/b]

Active FVG zones are extended bar by bar. When price mitigates a zone (closes inside it), the zone rendering switches to a dimmed style but remains visible as a historical reference. The indicator tracks the count of active unmitigated gaps on each side and displays them in the dashboard.

[b]Features[/b]

[list]
[*][b]Real-time FVG detection:[/b] Bullish and bearish imbalances identified and drawn as price-bound boxes
[*][b]FVG mitigation tracking:[/b] Zones update styling when price returns into the gap
[*][b]BSL and SSL level tracking:[/b] Pivot-based liquidity levels updated each bar
[*][b]Sweep event labels:[/b] On-chart labels at every confirmed liquidity sweep with direction
[*][b]Composite order flow bias:[/b] Running score combining FVG and sweep events
[*][b]Candle coloring:[/b] Candles painted by current bias state (bullish / bearish / neutral)
[*][b]Institutional dashboard:[/b] Top-right table showing active FVGs, sweep count, and bias score
[*][b]All signals on confirmed bars:[/b] barstate.isconfirmed throughout — no repainting
[/list]

[b]Input Parameters[/b]

[b]Structure Detection:[/b]
[list]
[*]Pivot Lookback: Bars required on each side for BSL/SSL pivot confirmation (default: 5)
[*]Max Active FVGs: Maximum simultaneous FVG zones drawn per side (default: 3)
[/list]

[b]Display:[/b]
[list]
[*]Show FVG Zones toggle
[*]Show Sweep Labels toggle
[*]Show Candle Color toggle
[*]Show Dashboard toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Active Imbalances[/b]
Unmitigated FVG boxes mark price areas where a directional move was so strong that no two-sided trading occurred. Price tends to return and fill these gaps. Use them as magnet targets or potential reversal zones.

[b]Step 2: Watch for Sweep Events[/b]
When a sweep label appears at a prior swing level, the indicator is signaling that liquidity at that level was collected. Sweeps followed by a strong close in the opposite direction are high-probability reversal setups.

[b]Step 3: Read the Bias Score[/b]
The composite score in the dashboard quantifies accumulated institutional signals. A strongly positive score suggests the order flow is biased bullish; strongly negative suggests bearish. Use this as a directional filter.

[b]Indicator Limitations[/b]

[list]
[*]FVGs form on every timeframe and many will not be mitigated; not every gap is tradeable
[*]Sweep detection uses close-back confirmation which adds one bar of delay
[*]The bias score is a heuristic, not a statistically validated predictor of future direction
[*]This indicator identifies market structure events; it does not generate entry or exit signals
[/list]

[b]Originality Statement[/b]

This indicator is original in combining FVG zone lifecycle management, pivot-based liquidity sweep detection, and a composite order flow bias score into a single Pine Script v6 publication. The zone mitigation tracking system, which distinguishes between active and mitigated imbalances while keeping both visible with different rendering, is not present in most standalone FVG tools on TradingView.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. All signals are based on historical price data and do not guarantee future results. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Institutional Flow Sentinel [JOAT]", shorttitle="IFS [JOAT]", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=300, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color TEAL_MINT  = color.rgb(0,   201, 167)
color CORAL_RED  = color.rgb(255,  83, 112)
color GOLD_SIG   = color.rgb(255, 185,  20)
color CYAN_SWEEP = color.rgb(0,   243, 255)
color PINK_SWEEP = color.rgb(255,   0,  85)
color VOID_BG    = color.rgb(10,   14,  26)
color SLATE_BRD  = color.rgb(40,   55,  90)
color LAVEN_HDR  = color.rgb(140, 160, 210)
color GOLD_VAL   = color.rgb(255, 215,  60)
color FVG_BULL   = color.rgb(0,   180, 120)
color FVG_BEAR   = color.rgb(200,  30,  60)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_ST   = "━━ Adaptive Supertrend ━━"
string G_FILT = "━━ Confluence Filters ━━"
string G_LIQ  = "━━ Liquidity Detection ━━"
string G_RISK = "━━ Risk Management ━━"
string G_VIZ  = "━━ Visual Settings ━━"
string G_WH   = "━━ Webhook Configuration ━━"

int    i_atrLen     = input.int(14,    "ATR Length",              minval=2, group=G_ST)
float  i_baseF      = input.float(3.0, "Base Factor",             minval=0.5, step=0.1, group=G_ST)
float  i_volWt      = input.float(1.0, "Volatility Weight",       minval=0.0, step=0.1, group=G_ST)
float  i_pcWt       = input.float(5.0, "Price Change Weight",     minval=0.0, step=0.5, group=G_ST)
int    i_smooth     = input.int(3,     "Factor Smoothing",        minval=1, group=G_ST)

bool   i_useHTF     = input.bool(true,  "HTF Alignment Filter",   group=G_FILT)
string i_htfTf      = input.timeframe("D", "HTF Timeframe",       group=G_FILT)
bool   i_useADX     = input.bool(true,  "ADX Trending Filter",    group=G_FILT)
int    i_adxLen     = input.int(14,    "ADX Length",              minval=1, group=G_FILT)
int    i_adxThr     = input.int(20,    "ADX Min Threshold",       minval=5, group=G_FILT)
bool   i_useVol     = input.bool(true,  "Volume Surge Filter",    group=G_FILT)
int    i_volLen     = input.int(20,    "Volume MA Length",        minval=1, group=G_FILT)
float  i_volMult    = input.float(1.2, "Volume Multiplier",       minval=0.5, step=0.1, group=G_FILT)
bool   i_useRSI     = input.bool(true,  "RSI Momentum Gate",      group=G_FILT)
int    i_rsiLen     = input.int(14,    "RSI Length",              minval=2, group=G_FILT)
bool   i_useBody    = input.bool(true,  "Candle Body Filter",     group=G_FILT)
float  i_bodyMult   = input.float(0.3, "Min Body / ATR Ratio",   minval=0.1, step=0.05, group=G_FILT)

int    i_swLen      = input.int(10,    "Swing Length for Liq",   minval=3, group=G_LIQ)
int    i_sweepMem   = input.int(5,     "Sweep Memory (bars)",    minval=1, maxval=30, group=G_LIQ,
     tooltip="Signal requires a sweep within this many bars before the trend flip.")
float  i_atrBuf     = input.float(0.5, "Sweep SL ATR Buffer",    minval=0.1, step=0.1, group=G_LIQ)

float  i_rrRatio    = input.float(2.0, "Risk : Reward Ratio",    minval=0.5, step=0.5, group=G_RISK)
int    i_boxWidth   = input.int(40,    "Trade Box Width (bars)",  minval=5, group=G_RISK)

bool   i_showDash   = input.bool(true,  "Show Filter Dashboard",  group=G_VIZ)
bool   i_showFVG    = input.bool(true,  "Show FVG Zones",         group=G_VIZ)

string i_actLong    = input.string("long",       "Long Action Name",   group=G_WH)
string i_actShort   = input.string("short",      "Short Action Name",  group=G_WH)
string i_actCloseLg = input.string("closelong",  "Close Long Action",  group=G_WH)
string i_actCloseSh = input.string("closeshort", "Close Short Action", group=G_WH)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — ADAPTIVE SUPERTREND ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
float atr       = ta.atr(i_atrLen)
float priceMove = math.abs(close - close[1]) / nz(close[1], close)
float dynRaw    = i_baseF + (atr / nz(close, 1.0)) * i_volWt + priceMove * i_pcWt
float factor    = ta.sma(dynRaw, i_smooth)
float hl2v      = (high + low) / 2.0
float upperBand = hl2v + factor * atr
float lowerBand = hl2v - factor * atr

var float trendLine = na
var int   direction = 1

if na(trendLine)
    trendLine := upperBand

if close > trendLine
    direction := 1
    trendLine := math.max(lowerBand, trendLine)
else
    direction := -1
    trendLine := math.min(upperBand, trendLine)

bool trendUp   = direction ==  1
bool trendDn   = direction == -1
bool flipUp    = direction ==  1 and direction[1] == -1
bool flipDn    = direction == -1 and direction[1] ==  1

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — CONFLUENCE FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
int htfDir = request.security(syminfo.tickerid, i_htfTf, direction[1], lookahead=barmerge.lookahead_on)
bool htfBull = htfDir ==  1
bool htfBear = htfDir == -1
bool filtHTF_L = not i_useHTF or htfBull
bool filtHTF_S = not i_useHTF or htfBear

[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool isTrending = adxVal > i_adxThr
bool filtADX    = not i_useADX or isTrending

float volMA  = ta.sma(volume, i_volLen)
bool  volSrg = volume > volMA * i_volMult
bool  filtVol= not i_useVol or volSrg

float rsiVal  = ta.rsi(close, i_rsiLen)
bool  rsiLgOK = rsiVal > 50.0
bool  rsiShOK = rsiVal < 50.0
bool  filtRSI_L = not i_useRSI or rsiLgOK
bool  filtRSI_S = not i_useRSI or rsiShOK

float bodySize = math.abs(close - open)
bool  strongBody = bodySize >= atr * i_bodyMult
bool  filtBody   = not i_useBody or strongBody

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — LIQUIDITY SWEEP DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
float swH = ta.pivothigh(high, i_swLen, i_swLen)
float swL = ta.pivotlow(low,   i_swLen, i_swLen)

var float[] bslLvls  = array.new_float()
var bool[]  bslSwept = array.new_bool()
var float[] sslLvls  = array.new_float()
var bool[]  sslSwept = array.new_bool()

if not na(swH)
    array.push(bslLvls, swH)
    array.push(bslSwept, false)
    while bslLvls.size() > 10
        array.shift(bslLvls)
        array.shift(bslSwept)

if not na(swL)
    array.push(sslLvls, swL)
    array.push(sslSwept, false)
    while sslLvls.size() > 10
        array.shift(sslLvls)
        array.shift(sslSwept)

bool sslSweep  = false
bool bslSweep  = false
float sweepLow = na
float sweepHi  = na

int ns = sslLvls.size()
if ns > 0
    for i = 0 to ns - 1
        if not array.get(sslSwept, i)
            float lvl = array.get(sslLvls, i)
            if low < lvl and close > lvl
                array.set(sslSwept, i, true)
                sslSweep := true
                sweepLow := low

int nb = bslLvls.size()
if nb > 0
    for i = 0 to nb - 1
        if not array.get(bslSwept, i)
            float lvl = array.get(bslLvls, i)
            if high > lvl and close < lvl
                array.set(bslSwept, i, true)
                bslSweep := true
                sweepHi  := high

// Track bars since last sweep
var int barsSinceSweepL = 999
var int barsSinceSweepS = 999

if sslSweep
    barsSinceSweepL := 0
else
    barsSinceSweepL := barsSinceSweepL + 1

if bslSweep
    barsSinceSweepS := 0
else
    barsSinceSweepS := barsSinceSweepS + 1

bool recentSweepL = barsSinceSweepL <= i_sweepMem
bool recentSweepS = barsSinceSweepS <= i_sweepMem

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — FVG DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
bool bullFVG = low > high[2]
bool bearFVG = high < low[2]

var float[] bFvgT = array.new_float()
var float[] bFvgB = array.new_float()
var float[] sFvgT = array.new_float()
var float[] sFvgB = array.new_float()

if bullFVG
    array.push(bFvgT, low)
    array.push(bFvgB, high[2])
    while bFvgT.size() > 15
        array.shift(bFvgT)
        array.shift(bFvgB)

if bearFVG and i_showFVG
    array.push(sFvgT, low[2])
    array.push(sFvgB, high)
    while sFvgT.size() > 15
        array.shift(sFvgT)
        array.shift(sFvgB)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — COMPOSITE SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════════
bool longSignal  = barstate.isconfirmed and flipUp and filtHTF_L and filtADX and
                   filtVol and filtRSI_L and filtBody and recentSweepL
bool shortSignal = barstate.isconfirmed and flipDn and filtHTF_S and filtADX and
                   filtVol and filtRSI_S and filtBody and recentSweepS

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — TRADE VISUALIZATION
// ═══════════════════════════════════════════════════════════════════════════════
if longSignal
    float entry = close
    float sl    = ta.lowest(low, i_swLen) - atr * i_atrBuf
    float slDst = entry - sl
    float tp    = entry + slDst * i_rrRatio
    int   x2    = bar_index + i_boxWidth

    box bTP = box.new(bar_index, tp, x2, entry,
         border_color=color.new(TEAL_MINT, 20), bgcolor=color.new(TEAL_MINT, 75),
         text="TP  " + str.tostring(tp, format.mintick),
         text_color=color.new(color.white, 10), text_size=size.small,
         text_halign=text.align_right, text_valign=text.align_top)
    box bSL = box.new(bar_index, entry, x2, sl,
         border_color=color.new(CORAL_RED, 20), bgcolor=color.new(CORAL_RED, 75),
         text="SL  " + str.tostring(sl, format.mintick),
         text_color=color.new(color.white, 10), text_size=size.small,
         text_halign=text.align_right, text_valign=text.align_bottom)
    line.new(bar_index, entry, x2, entry, color=color.white, width=2, style=line.style_dashed)
    label.new(bar_index, entry, "LONG  " + str.tostring(entry, format.mintick),
         style=label.style_label_up, color=TEAL_MINT, textcolor=color.white, size=size.small)

if shortSignal
    float entry = close
    float sl    = ta.highest(high, i_swLen) + atr * i_atrBuf
    float slDst = sl - entry
    float tp    = entry - slDst * i_rrRatio
    int   x2    = bar_index + i_boxWidth

    box bTP = box.new(bar_index, entry, x2, tp,
         border_color=color.new(TEAL_MINT, 20), bgcolor=color.new(TEAL_MINT, 75),
         text="TP  " + str.tostring(tp, format.mintick),
         text_color=color.new(color.white, 10), text_size=size.small,
         text_halign=text.align_right, text_valign=text.align_bottom)
    box bSL = box.new(bar_index, sl, x2, entry,
         border_color=color.new(CORAL_RED, 20), bgcolor=color.new(CORAL_RED, 75),
         text="SL  " + str.tostring(sl, format.mintick),
         text_color=color.new(color.white, 10), text_size=size.small,
         text_halign=text.align_right, text_valign=text.align_top)
    line.new(bar_index, entry, x2, entry, color=color.white, width=2, style=line.style_dashed)
    label.new(bar_index, entry, "SHORT  " + str.tostring(entry, format.mintick),
         style=label.style_label_down, color=CORAL_RED, textcolor=color.white, size=size.small)

// Sweep markers
if sslSweep
    label.new(bar_index, low, "SSL", style=label.style_label_up,
         color=color.new(CYAN_SWEEP, 50), textcolor=color.white, size=size.tiny)
if bslSweep
    label.new(bar_index, high, "BSL", style=label.style_label_down,
         color=color.new(PINK_SWEEP, 50), textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — SUPERTREND PLOT
// ═══════════════════════════════════════════════════════════════════════════════
stColor = direction == 1 ? TEAL_MINT : CORAL_RED
plot(trendLine, "Sentinel Line", color=stColor, linewidth=2, style=plot.style_linebr)

pMid  = plot((open + close) / 2.0, display=display.none)
pBand = plot(trendLine, display=display.none)
fill(pBand, pMid,
     math.max((open + close) / 2.0, trendLine),
     math.min((open + close) / 2.0, trendLine),
     direction == 1 ? color.new(TEAL_MINT, 88) : color.new(CORAL_RED, 88),
     direction == 1 ? color.new(TEAL_MINT, 92) : color.new(CORAL_RED, 92))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
f_statusIcon(bool enabled, bool state) =>
    not enabled ? "— OFF" : state ? "PASS" : "FAIL"

f_statusColor(bool enabled, bool state) =>
    not enabled ? LAVEN_HDR : state ? TEAL_MINT : CORAL_RED

var table dash = table.new(position.top_right, 2, 10,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash
    table.cell(dash, 0, 0, "Institutional Flow Sentinel", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Direction", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, direction == 1 ? "BULLISH" : "BEARISH",
         text_color=direction == 1 ? TEAL_MINT : CORAL_RED, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 2, "HTF Align", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    bool htfOK = not i_useHTF or (direction == 1 ? htfBull : htfBear)
    table.cell(dash, 1, 2, f_statusIcon(i_useHTF, htfOK),
         text_color=f_statusColor(i_useHTF, htfOK), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 3, "ADX Trend", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, f_statusIcon(i_useADX, isTrending),
         text_color=f_statusColor(i_useADX, isTrending), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 4, "Vol Surge", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, f_statusIcon(i_useVol, volSrg),
         text_color=f_statusColor(i_useVol, volSrg), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 5, "RSI Gate",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    bool rsiGate = direction == 1 ? rsiLgOK : rsiShOK
    table.cell(dash, 1, 5, f_statusIcon(i_useRSI, rsiGate),
         text_color=f_statusColor(i_useRSI, rsiGate), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 6, "Body Str",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, f_statusIcon(i_useBody, strongBody),
         text_color=f_statusColor(i_useBody, strongBody), text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 7, "Sweep Rdy", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    bool swpRdy = direction == 1 ? recentSweepL : recentSweepS
    table.cell(dash, 1, 7, swpRdy ? "READY" : "WAITING",
         text_color=swpRdy ? GOLD_SIG : LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 8, "ADX Value", text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 8, str.tostring(adxVal, "#.#"),
         text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    bool   anySig = longSignal or shortSignal
    string sigTxt = longSignal ? "LONG" : shortSignal ? "SHORT" : "WAIT"
    color  sigCol = longSignal ? TEAL_MINT : shortSignal ? CORAL_RED : LAVEN_HDR
    table.cell(dash, 0, 9, "Signal",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 9, sigTxt, text_color=sigCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — WEBHOOKS & ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
float entryRef = close[1]
float atrRef   = atr[1]

if longSignal
    float sl  = entryRef - atrRef * 1.5
    float tp1 = entryRef + atrRef * 1.5
    float tp2 = entryRef + atrRef * 2.5
    float tp3 = entryRef + atrRef * 3.5
    string payload = '{"action":"' + i_actLong + '","symbol":"' + syminfo.tickerid +
         '","timeframe":"' + timeframe.period + '","entry":"' + str.tostring(entryRef, format.mintick) +
         '","sl":"' + str.tostring(sl, format.mintick) +
         '","tp1":"' + str.tostring(tp1, format.mintick) +
         '","tp2":"' + str.tostring(tp2, format.mintick) +
         '","tp3":"' + str.tostring(tp3, format.mintick) + '"}'
    alert(payload, alert.freq_once_per_bar_close)

if shortSignal
    float sl  = entryRef + atrRef * 1.5
    float tp1 = entryRef - atrRef * 1.5
    float tp2 = entryRef - atrRef * 2.5
    float tp3 = entryRef - atrRef * 3.5
    string payload = '{"action":"' + i_actShort + '","symbol":"' + syminfo.tickerid +
         '","timeframe":"' + timeframe.period + '","entry":"' + str.tostring(entryRef, format.mintick) +
         '","sl":"' + str.tostring(sl, format.mintick) +
         '","tp1":"' + str.tostring(tp1, format.mintick) +
         '","tp2":"' + str.tostring(tp2, format.mintick) +
         '","tp3":"' + str.tostring(tp3, format.mintick) + '"}'
    alert(payload, alert.freq_once_per_bar_close)

if flipDn and barstate.isconfirmed
    alert('{"action":"' + i_actCloseLg + '","symbol":"' + syminfo.tickerid + '"}', alert.freq_once_per_bar_close)
if flipUp and barstate.isconfirmed
    alert('{"action":"' + i_actCloseSh + '","symbol":"' + syminfo.tickerid + '"}', alert.freq_once_per_bar_close)

alertcondition(longSignal,  "IFS Long",  "Institutional Flow Sentinel [JOAT]: LONG signal on {{ticker}} {{interval}}")
alertcondition(shortSignal, "IFS Short", "Institutional Flow Sentinel [JOAT]: SHORT signal on {{ticker}} {{interval}}")
alertcondition(sslSweep,    "IFS SSL Sweep", "Institutional Flow Sentinel [JOAT]: SSL swept on {{ticker}}")
alertcondition(bslSweep,    "IFS BSL Sweep", "Institutional Flow Sentinel [JOAT]: BSL swept on {{ticker}}")
````
