# Adaptive Confluence Engine [StrixEDGE]

- url: https://www.tradingview.com/script/XlAm7oeu-Adaptive-Confluence-Engine-StrixEDGE/
- type: indicator
- pine_id: PUB;d582477c4406463482b10aafa532b6b4
- version: 1.0

## Description

Adaptive Confluence Engine [StrixEDGE]

🔷 HOW IT WORKS

The indicator evaluates the market through four independent modules. Each module scores the current bar as bullish (+1), bearish (−1), or neutral (0). Volume and volatility modules act as confirmation filters and score +1 (confirmed) or 0 (not confirmed). The individual scores are aggregated into a confluence score ranging from 0 to 4 for each direction.

A signal fires only when:
→ The confluence score crosses above the minimum threshold (transition detection)
→ The previous signal was in the opposite direction (flip-only logic — no consecutive Buy-Buy or Sell-Sell)
→ A cooldown period has elapsed since the last signal

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 THE FOUR MODULES

MODULE 1 — TREND
Uses a Hull Moving Average (HMA) for responsive trend direction and a Weighted Moving Average (WMA) as a trend position filter. Bullish: HMA rising AND price above WMA. Bearish: HMA falling AND price below WMA. The HMA reacts faster than a standard EMA while filtering out noise, and the WMA acts as a structural trend gate.

https://www.tradingview.com/x/uxtJaZg5/

MODULE 2 — MOMENTUM
Combines RSI zone analysis with MACD histogram acceleration. RSI is evaluated against configurable directional thresholds (default 55/45), not traditional overbought/oversold levels. The MACD histogram must be positive AND increasing for bullish momentum (or negative AND decreasing for bearish). This captures momentum that is actively building, not fading.

https://www.tradingview.com/x/gxXsJ2cz/

MODULE 3 — VOLUME
Volume must exceed its simple moving average by a configurable multiplier AND the short-term volume trend (5-bar SMA) must be rising relative to the medium-term (10-bar SMA). This confirms that participation is genuine and sustained, not a single-bar spike.

https://www.tradingview.com/x/26OZtwkm/

MODULE 4 — VOLATILITY FILTER
Calculates the ATR percentile rank over a configurable lookback period. Signals are suppressed when volatility falls below the low percentile (indicating a dead, range-bound market with no follow-through potential) or above the high percentile (indicating chaotic conditions where stops are too wide and reversals too sudden). Only the "sweet spot" of volatility passes.

https://www.tradingview.com/x/D517db3k/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 SIGNAL LOGIC

The signal generation uses three layers of filtering:

1. Transition Detection — Signals fire only on the bar where the confluence score first crosses the minimum threshold, not on every bar it remains above it.

2. Flip-Only Mode — After a Buy signal, the next signal must be a Sell (and vice versa). This prevents consecutive same-direction signals and ensures alternating entries.

3. Cooldown — A configurable minimum number of bars must pass between any two signals, preventing rapid-fire entries during volatile transitions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 VISUAL FEATURES

→ Buy / Sell labels with exact entry price displayed on the chart
https://www.tradingview.com/x/D4YmetYF/
→ Entry price horizontal line (persists for 20 bars after signal)
→ ATR-based dynamic stop-loss levels
→ Hull Moving Average (colored by direction) and WMA overlay
→ Background shading when confluence is active
→ Real-time dashboard showing status of all four modules, ATR reading with percentile, and aggregate confluence score

https://www.tradingview.com/x/VyPRmvat/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 SETTINGS GUIDE

Trend Module
• Fast HMA Length (default 9) — Lower values react faster but produce more noise.
• Slow WMA Length (default 21) — The structural trend gate. Higher values require stronger trends.

Momentum Module
• RSI Bullish/Bearish Threshold (default 55/45) — These are directional filters, not overbought/oversold. Widen to 60/40 for stricter momentum requirements.
• MACD settings (12/26/9) — Standard defaults. Adjust for faster or slower momentum reads.

Volume Module
• Volume SMA Length (default 20) — Lookback for average volume calculation.
• Volume Threshold (default 1.0) — Multiplier applied to the volume SMA. Increase to 1.2–1.5 to require above-average volume.

Volatility Filter
• ATR Length (default 14) — Period for ATR calculation.
• ATR Lookback (default 100) — Number of bars for percentile ranking.
• Low/High Vol. Percentile (default 10/90) — Defines the acceptable volatility range. Narrow to 20/80 for stricter regime filtering.

Signal Control
• Min. Confluence Score (default 3) — Number of modules that must agree. Higher = fewer but higher-quality signals.
• Signal Cooldown (default 5 bars) — Minimum spacing between signals.
• Stop-Loss ATR Multiple (default 1.5) — Distance of the stop-loss from the signal bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 WHAT MAKES THIS ORIGINAL

StrixEDGE does not replicate any single built-in indicator. Its value lies in the confluence scoring architecture: four independent analysis dimensions, each evaluating a different market property (direction, momentum, participation, regime), aggregated through a transition-based scoring system with flip-only signal control. The combination of ATR percentile volatility filtering, MACD histogram acceleration (not just crossover), and alternating-direction signal enforcement creates a framework that is structurally distinct from standard indicator overlays.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 RECOMMENDED USE

Designed for day trading timeframes (15-minute to 1-hour charts). Works across all markets with volume data: crypto, forex, stocks, indices, commodities. Start with the default settings and adjust based on the instrument's behavior. Use the dashboard to understand why signals fire or don't fire.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ DISCLAIMER
This indicator is a technical analysis tool, not financial advice. No indicator guarantees profitable outcomes. Past performance of any signal does not indicate future results. Always apply proper risk management and use this tool as one component of a complete trading plan.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

5 alert conditions available: Buy Signal, Sell Signal, Any Signal, Bull Active, Bear Active.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Adaptive Confluence Engine [StrixEDGE]", shorttitle="Adaptive Confluence Engine [StrixEDGE]", overlay=true, max_labels_count=200, max_bars_back=500)

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  StrixEDGE — Adaptive Confluence Engine v1.0                                ║
// ║  Multi-Factor Scoring System for Day Trading                                ║
// ║                                                                              ║
// ║  4 Independent Modules:                                                      ║
// ║  [1] TREND    — HMA direction + WMA position filter                         ║
// ║  [2] MOMENTUM — RSI zone + MACD histogram acceleration                     ║
// ║  [3] VOLUME   — Relative volume + volume trend                              ║
// ║  [4] VOLATILITY — ATR percentile regime filter                              ║
// ║                                                                              ║
// ║  Signals fire only when modules reach minimum confluence                    ║
// ║  with transition detection (avoids repeated signals)                         ║
// ╚══════════════════════════════════════════════════════════════════════════════╝


// ============================================================================
// INPUTS
// ============================================================================

// ── Trend Module ──────────────────────────────────────────────────────────────
string GRP_TREND = "🔷 Trend Module"
int    i_hmaLen  = input.int(9,     "Fast HMA Length",  minval=2,  group=GRP_TREND, tooltip="Hull Moving Average — responsive trend direction. Lower = faster reaction, more noise.")
int    i_wmaLen  = input.int(21,    "Slow WMA Length",  minval=5,  group=GRP_TREND, tooltip="Weighted Moving Average — trend confirmation. Price must be on the correct side of this line.")
float  i_trdSrc  = input.source(close, "Source",         group=GRP_TREND)

// ── Momentum Module ──────────────────────────────────────────────────────────
string GRP_MOM   = "🔶 Momentum Module"
int    i_rsiLen  = input.int(14,    "RSI Length",       minval=2,  group=GRP_MOM)
int    i_rsiHi   = input.int(55,    "RSI Bullish Threshold", minval=50, maxval=90, group=GRP_MOM, tooltip="RSI above this = bullish momentum confirmed.")
int    i_rsiLo   = input.int(45,    "RSI Bearish Threshold", minval=10, maxval=50, group=GRP_MOM, tooltip="RSI below this = bearish momentum confirmed.")
int    i_mcdF    = input.int(12,    "MACD Fast",        minval=2,  group=GRP_MOM)
int    i_mcdS    = input.int(26,    "MACD Slow",        minval=5,  group=GRP_MOM)
int    i_mcdSig  = input.int(9,     "MACD Signal",      minval=2,  group=GRP_MOM)

// ── Volume Module ─────────────────────────────────────────────────────────────
string GRP_VOL   = "🟢 Volume Module"
int    i_volLen  = input.int(20,    "Volume SMA Length", minval=5,  group=GRP_VOL)
float  i_volMul  = input.float(1.0, "Volume Threshold",  minval=0.5, step=0.1, group=GRP_VOL, tooltip="Volume must exceed SMA × this multiplier to confirm activity.")

// ── Volatility Module ─────────────────────────────────────────────────────────
string GRP_VOLA  = "🟡 Volatility Filter"
int    i_atrLen  = input.int(14,    "ATR Length",              minval=5,  group=GRP_VOLA)
int    i_atrLB   = input.int(100,   "ATR Lookback (bars)",     minval=20, group=GRP_VOLA, tooltip="How many bars to use for ATR percentile ranking.")
int    i_atrLo   = input.int(10,    "Low Vol. Percentile",     minval=5,  maxval=40, group=GRP_VOLA, tooltip="ATR below this percentile = dead market, skip signals.")
int    i_atrHi   = input.int(90,    "High Vol. Percentile",    minval=60, maxval=95, group=GRP_VOLA, tooltip="ATR above this percentile = chaos, skip signals.")

// ── Signal Control ────────────────────────────────────────────────────────────
string GRP_SIG   = "⚡ Signal Control"
int    i_minConf = input.int(3,     "Min. Confluence Score",   minval=1,  maxval=4, group=GRP_SIG, tooltip="How many modules must agree for a signal (1-4). Default 3 = conservative.")
int    i_cooldown= input.int(5,     "Signal Cooldown (bars)",  minval=1,  maxval=50, group=GRP_SIG, tooltip="Minimum bars between consecutive signals in the same direction.")
bool   i_showSL  = input.bool(true, "Show ATR Stop Levels",    group=GRP_SIG, tooltip="Plot dynamic stop-loss levels based on ATR.")
float  i_slMul   = input.float(1.5, "Stop-Loss ATR Multiple",  minval=0.5, step=0.1, group=GRP_SIG, tooltip="Stop distance = ATR × this value.")

// ── Display ───────────────────────────────────────────────────────────────────
string GRP_DISP  = "🎨 Display"
bool   i_showDB  = input.bool(true,  "Show Dashboard",          group=GRP_DISP)
bool   i_showBG  = input.bool(true,  "Show Background Shading", group=GRP_DISP)
bool   i_showMA  = input.bool(true,  "Show Moving Averages",    group=GRP_DISP)


// ============================================================================
// FUNCTIONS
// ============================================================================

// ── Hull Moving Average ───────────────────────────────────────────────────────
// HMA = WMA(2 × WMA(n/2) − WMA(n), √n) — faster than EMA with less lag
hma(float src, int length) =>
    int halfLen  = math.max(length / 2, 1)
    int sqrtLen  = math.max(math.round(math.sqrt(length)), 1)
    float wma1   = ta.wma(src, halfLen)
    float wma2   = ta.wma(src, length)
    ta.wma(2.0 * wma1 - wma2, sqrtLen)


// ============================================================================
// MODULE 1 — TREND
// Combines HMA direction (responsive) with WMA position (confirmation)
// Score: +1 bullish | -1 bearish | 0 neutral
// ============================================================================
float hmaVal      = hma(i_trdSrc, i_hmaLen)
float wmaVal      = ta.wma(i_trdSrc, i_wmaLen)

bool  hmaRising   = hmaVal > hmaVal[1]
bool  hmaFalling  = hmaVal < hmaVal[1]
bool  aboveWMA    = i_trdSrc > wmaVal
bool  belowWMA    = i_trdSrc < wmaVal

bool  trendBull   = hmaRising  and aboveWMA
bool  trendBear   = hmaFalling and belowWMA
int   trendScore  = trendBull ? 1 : trendBear ? -1 : 0


// ============================================================================
// MODULE 2 — MOMENTUM
// RSI must be in directional zone + MACD histogram must be accelerating
// Score: +1 bullish | -1 bearish | 0 neutral
// ============================================================================
float rsiVal = ta.rsi(i_trdSrc, i_rsiLen)

// MACD components
float macdLine   = ta.ema(i_trdSrc, i_mcdF) - ta.ema(i_trdSrc, i_mcdS)
float signalLine = ta.ema(macdLine, i_mcdSig)
float histogram  = macdLine - signalLine

bool rsiBull     = rsiVal > i_rsiHi
bool rsiBear     = rsiVal < i_rsiLo
bool histBull    = histogram > 0 and histogram > histogram[1]  // positive & rising
bool histBear    = histogram < 0 and histogram < histogram[1]  // negative & falling

bool momBull     = rsiBull and histBull
bool momBear     = rsiBear and histBear
int  momScore    = momBull ? 1 : momBear ? -1 : 0


// ============================================================================
// MODULE 3 — VOLUME
// Confirms activity: volume above SMA + short-term volume trend rising
// Score: +1 confirmed | 0 not confirmed (directionally neutral)
// ============================================================================
float volSMA     = ta.sma(volume, i_volLen)
float volFast    = ta.sma(volume, 5)
float volSlow    = ta.sma(volume, 10)

bool  volAbove   = volume > volSMA * i_volMul
bool  volTrend   = volFast > volSlow
bool  volActive  = volAbove and volTrend
int   volScore   = volActive ? 1 : 0


// ============================================================================
// MODULE 4 — VOLATILITY REGIME
// ATR percentile rank filters out dead markets and extreme volatility
// Score: +1 regime OK | 0 regime unfavorable
// ============================================================================
float atrVal     = ta.atr(i_atrLen)
float atrPctRank = ta.percentrank(atrVal, i_atrLB)

bool  regimeOK   = atrPctRank >= i_atrLo and atrPctRank <= i_atrHi
int   volaScore  = regimeOK ? 1 : 0


// ============================================================================
// CONFLUENCE SCORING & SIGNAL GENERATION
// ============================================================================

// ── Current bar scores ────────────────────────────────────────────────────────
int bullConf = (trendScore ==  1 ? 1 : 0) + (momScore ==  1 ? 1 : 0) + volScore + volaScore
int bearConf = (trendScore == -1 ? 1 : 0) + (momScore == -1 ? 1 : 0) + volScore + volaScore

// ── Previous bar scores (for transition detection) ────────────────────────────
int prevTrend = trendBull[1] ? 1 : trendBear[1] ? -1 : 0
int prevMom   = momBull[1]   ? 1 : momBear[1]   ? -1 : 0
int prevVol   = volActive[1] ? 1 : 0
int prevVola  = regimeOK[1]  ? 1 : 0

int prevBullConf = (prevTrend ==  1 ? 1 : 0) + (prevMom ==  1 ? 1 : 0) + prevVol + prevVola
int prevBearConf = (prevTrend == -1 ? 1 : 0) + (prevMom == -1 ? 1 : 0) + prevVol + prevVola

// ── Transition signals (fire only on threshold crossing) ──────────────────────
bool rawBuy  = bullConf >= i_minConf and prevBullConf < i_minConf
bool rawSell = bearConf >= i_minConf and prevBearConf < i_minConf

// ── Flip-only logic: no repeat signals in same direction ─────────────────────
// After a Buy, next signal must be Sell (and vice versa). Prevents spam.
var int lastSignalDir = 0   // 0 = none, 1 = buy, -1 = sell
var int lastSignalBar = -9999

bool buySignal  = rawBuy  and lastSignalDir != 1  and (bar_index - lastSignalBar) >= i_cooldown
bool sellSignal = rawSell and lastSignalDir != -1 and (bar_index - lastSignalBar) >= i_cooldown

if buySignal
    lastSignalDir := 1
    lastSignalBar := bar_index
if sellSignal
    lastSignalDir := -1
    lastSignalBar := bar_index


// ============================================================================
// VISUALS — CHART OVERLAYS
// ============================================================================

// ── Moving Averages ───────────────────────────────────────────────────────────
color hmaColor = hmaRising ? color.new(#00E676, 0) : color.new(#FF5252, 0)
plot(i_showMA ? hmaVal : na, "HMA (Fast)", color=hmaColor, linewidth=2)
plot(i_showMA ? wmaVal : na, "WMA (Slow)", color=color.new(#42A5F5, 60), linewidth=1, style=plot.style_line)

// ── Background Shading ───────────────────────────────────────────────────────
color bgColor = na
if i_showBG
    if bullConf >= i_minConf
        bgColor := color.new(#00E676, 92)
    else if bearConf >= i_minConf
        bgColor := color.new(#FF5252, 92)
bgcolor(bgColor, title="Confluence Background")

// ── Signal Labels with Entry Price ───────────────────────────────────────────
if buySignal
    label.new(bar_index, low, "Buy\n" + str.tostring(close, format.mintick), style=label.style_label_up, color=color.new(#00E676, 0), textcolor=color.white, size=size.normal)

if sellSignal
    label.new(bar_index, high, "Sell\n" + str.tostring(close, format.mintick), style=label.style_label_down, color=color.new(#FF5252, 0), textcolor=color.white, size=size.normal)

// ── Entry Price Line (horizontal line at entry for 20 bars) ──────────────────
var float entryPrice  = na
var int   entryBar    = -9999
var int   entryDir    = 0

if buySignal
    entryPrice := close
    entryBar   := bar_index
    entryDir   := 1
if sellSignal
    entryPrice := close
    entryBar   := bar_index
    entryDir   := -1

bool showEntry = not na(entryPrice) and (bar_index - entryBar) <= 20
color entryClr = entryDir == 1 ? color.new(#00E676, 40) : color.new(#FF5252, 40)
plot(showEntry ? entryPrice : na, "Entry Level", color=entryClr, style=plot.style_linebr, linewidth=2)

// ── Dynamic Stop-Loss Levels ──────────────────────────────────────────────────
var float activeBuySL  = na
var float activeSellSL = na

if buySignal
    activeBuySL  := low - atrVal * i_slMul
if sellSignal
    activeSellSL := high + atrVal * i_slMul

// Expire stop levels after 20 bars
bool showBuySL  = i_showSL and not na(activeBuySL)  and entryDir == 1  and (bar_index - entryBar) <= 20
bool showSellSL = i_showSL and not na(activeSellSL) and entryDir == -1 and (bar_index - entryBar) <= 20

plot(showBuySL  ? activeBuySL  : na, "Buy Stop-Loss",  color=color.new(#00E676, 50), style=plot.style_linebr, linewidth=1)
plot(showSellSL ? activeSellSL : na, "Sell Stop-Loss", color=color.new(#FF5252, 50), style=plot.style_linebr, linewidth=1)


// ============================================================================
// DASHBOARD TABLE
// ============================================================================
if i_showDB and barstate.islast

    var table dash = table.new(position.top_right, 3, 7, bgcolor=color.new(#131722, 5), border_color=color.new(#2A2E39, 0), border_width=1, frame_color=color.new(#363A45, 0), frame_width=2)

    // ── Header ────────────────────────────────────────────────────────────────
    table.cell(dash, 0, 0, "StrixEDGE",      text_color=color.white,   text_size=size.small, bgcolor=color.new(#1565C0, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0",           text_color=#90CAF9,       text_size=size.tiny,  bgcolor=color.new(#1565C0, 0), text_halign=text.align_center)
    table.cell(dash, 2, 0, "STATUS",          text_color=color.white,   text_size=size.small, bgcolor=color.new(#1565C0, 0), text_halign=text.align_right)

    // ── Row: Trend ────────────────────────────────────────────────────────────
    string trendTxt  = trendScore ==  1 ? "BULLISH" : trendScore == -1 ? "BEARISH" : "NEUTRAL"
    string trendIcon = trendScore ==  1 ? " ▲"      : trendScore == -1 ? " ▼"      : " ◆"
    color  trendClr  = trendScore ==  1 ? #00E676   : trendScore == -1 ? #FF5252   : #FFA726
    table.cell(dash, 0, 1, "TREND",     text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 1, trendTxt,    text_color=trendClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 1, trendIcon,   text_color=trendClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Row: Momentum ─────────────────────────────────────────────────────────
    string momTxt  = momScore ==  1 ? "BULLISH" : momScore == -1 ? "BEARISH" : "NEUTRAL"
    string momIcon = momScore ==  1 ? " ▲"      : momScore == -1 ? " ▼"      : " ◆"
    color  momClr  = momScore ==  1 ? #00E676   : momScore == -1 ? #FF5252   : #FFA726
    table.cell(dash, 0, 2, "MOMENTUM", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 2, momTxt,     text_color=momClr,  text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 2, momIcon,    text_color=momClr,  text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Row: Volume ───────────────────────────────────────────────────────────
    string volTxt  = volActive ? "ACTIVE"  : "WEAK"
    string volIcon = volActive ? " ✓"      : " ✗"
    color  volClr  = volActive ? #00E676   : #EF5350
    table.cell(dash, 0, 3, "VOLUME",  text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 3, volTxt,    text_color=volClr,  text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 3, volIcon,   text_color=volClr,  text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Row: Volatility ───────────────────────────────────────────────────────
    string volaTxt  = regimeOK ? "OPTIMAL" : "EXTREME"
    string volaIcon = regimeOK ? " ✓"      : " ⚠"
    color  volaClr  = regimeOK ? #00E676   : #FFA726
    table.cell(dash, 0, 4, "VOLATILITY", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 4, volaTxt,      text_color=volaClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 4, volaIcon,     text_color=volaClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Row: ATR Info ─────────────────────────────────────────────────────────
    string atrTxt = "ATR: " + str.tostring(atrVal, format.mintick) + " (" + str.tostring(atrPctRank, "#") + "%)"
    table.cell(dash, 0, 5, atrTxt,     text_color=#78909C, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_left)
    table.cell(dash, 1, 5, "",         text_color=#78909C, text_size=size.tiny, bgcolor=color.new(#131722, 0))
    table.cell(dash, 2, 5, "",         text_color=#78909C, text_size=size.tiny, bgcolor=color.new(#131722, 0))

    // ── Row: Confluence Score ─────────────────────────────────────────────────
    int    activeConf  = math.max(bullConf, bearConf)
    string confDir     = bullConf >= bearConf ? "BULL" : "BEAR"
    string confTxt     = str.tostring(activeConf) + " / 4  " + confDir
    color  confBG      = activeConf >= i_minConf ? (bullConf >= bearConf ? color.new(#1B5E20, 0) : color.new(#B71C1C, 0)) : color.new(#37474F, 0)
    color  confTxtClr  = activeConf >= i_minConf ? color.white : #90A4AE
    table.cell(dash, 0, 6, "CONFLUENCE", text_color=color.white,  text_size=size.small, bgcolor=confBG, text_halign=text.align_left)
    table.cell(dash, 1, 6, confTxt,      text_color=confTxtClr,   text_size=size.small, bgcolor=confBG, text_halign=text.align_center)
    table.cell(dash, 2, 6, activeConf >= i_minConf ? "🟢" : "⚪",text_color=color.white, text_size=size.small, bgcolor=confBG, text_halign=text.align_right)


// ============================================================================
// ALERTS
// ============================================================================
alertcondition(buySignal,                "StrixEDGE — Buy Signal",    "StrixEDGE BUY: Bullish confluence reached on {{ticker}} {{interval}}")
alertcondition(sellSignal,               "StrixEDGE — Sell Signal",   "StrixEDGE SELL: Bearish confluence reached on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,  "StrixEDGE — Any Signal",    "StrixEDGE SIGNAL on {{ticker}} {{interval}}")
alertcondition(bullConf >= i_minConf,    "StrixEDGE — Bull Active",   "StrixEDGE: Bullish confluence active on {{ticker}} {{interval}}")
alertcondition(bearConf >= i_minConf,    "StrixEDGE — Bear Active",   "StrixEDGE: Bearish confluence active on {{ticker}} {{interval}}")
````
