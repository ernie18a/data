# Fibonacci EMA RSI Engine  [StrixEDGE]

- url: https://www.tradingview.com/script/kAxdwaH5-Fibonacci-EMA-RSI-Engine-StrixEDGE/
- type: indicator
- pine_id: PUB;9b1aed61d6e24f91b4d3fcb58c4d8e37
- version: 1.0

## Description

StrixFIBER is a three-pillar confluence indicator that combines automatic Fibonacci retracement levels, EMA 50/200 trend structure, and RSI overbought/oversold detection into a single chart overlay. Signals fire only when multiple pillars confirm the same direction, with separate labels for standard and strong (all-three) confluence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔶 THE THREE PILLARS

PILLAR 1 — AUTO FIBONACCI
The indicator automatically calculates Fibonacci retracement levels (0%, 23.6%, 38.2%, 50%, 61.8%, 78.6%, 100%) from the highest high and lowest low over a configurable lookback period. All seven levels are plotted on the chart with price labels at the right edge.

https://www.tradingview.com/x/wMyDu7qC/

The 50%–61.8% range is highlighted as the "Golden Zone" — the area where price most commonly finds support or resistance during healthy retracements. When price is within ATR proximity of a key Fibonacci level, the indicator scores it as "at support" or "at resistance" depending on price position relative to the 50% midpoint.

https://www.tradingview.com/x/RNvNSRbl/

PILLAR 2 — EMA 50 / 200
The classic dual exponential moving average system. EMA 50 is colored green when above EMA 200 (bullish structure) and red when below (bearish structure). Golden Cross (EMA 50 crossing above EMA 200) and Death Cross (EMA 50 crossing below EMA 200) events are marked with diamond shapes on the chart.

https://www.tradingview.com/x/S5nOz5aB/

The EMA pillar provides the trend context. Fibonacci support levels are more meaningful in a bullish EMA structure; resistance levels are more meaningful in a bearish structure.

PILLAR 3 — RSI OVERBOUGHT / OVERSOLD
RSI is calculated at a configurable length (default 14) with configurable OB/OS thresholds (default 70/30). The RSI line itself is not plotted (this is an overlay indicator), but OB and OS entries are marked as small colored circles above and below price bars.

OVERBOUGHT
https://www.tradingview.com/x/kEYYxSSs/

OVERSOLD
https://www.tradingview.com/x/VnBJlf2F/

The RSI pillar fires a bullish score when RSI recovers from oversold (crosses back above the OS threshold) and a bearish score when RSI drops from overbought (crosses back below the OB threshold). This captures the reversal moment, not just the extreme reading.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔶 CONFLUENCE LOGIC

Each pillar scores +1 (bullish), −1 (bearish), or 0 (neutral) independently. The scores are aggregated:

→ 3/3 Pillars = "Strong Buy" or "Strong Sell" — all three pillars fully aligned. Highest conviction.
BUY - https://www.tradingview.com/x/jGPZXI7U/
SELL - https://www.tradingview.com/x/XJwTssvx/
→ 2/3 Pillars = "Buy" or "Sell" — two of three pillars agree. Standard conviction.
→ 1/3 Pillars = No signal by default (configurable).

The minimum number of pillars required for a signal is adjustable (1, 2, or 3). Default is 2.

Additional signal filtering:
→ Flip-Only Logic: After a Buy, the next signal must be a Sell (and vice versa). No consecutive same-direction signals.
→ Cooldown: Configurable minimum bars between signals (default 10).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔶 VISUAL FEATURES

Fibonacci Levels
→ All 7 standard levels plotted as colored lines (thicker for 50% and 61.8%)
→ Golden Zone (50–61.8%) highlighted with a translucent fill
→ Price labels at the right edge of each level showing the exact price value

EMA System
→ EMA 50 colored by trend direction (green above EMA 200, red below)
→ EMA 200 as a steady reference line
→ Golden Cross (GC) and Death Cross (DC) diamond markers

RSI Markers
→ Small green circles below bars when RSI enters oversold
→ Small red circles above bars when RSI enters overbought
→ RSI value displayed in the dashboard (not as a separate pane line)

Signals
→ Buy / Sell labels with exact entry price
→ "Strong Buy" / "Strong Sell" labels when all 3 pillars align (darker color for distinction)
→ Entry price horizontal line persists for 20 bars
→ ATR-based stop-loss level plotted below/above entry

Dashboard
→ EMA trend status with direction
→ RSI current value and zone (Overbought / Oversold / Neutral)
→ Fibonacci proximity status (At Support / At Resistance / Between)
→ Nearest Fibonacci level with distance in ATR units
→ Pillar confluence count and direction
→ Last signal direction and age (bars ago)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔶 SETTINGS GUIDE

Fibonacci
• Lookback Period (default 120) — Bars used for highest high / lowest low. Increase for wider retracement levels, decrease for tighter ones.
• Fibonacci Proximity (default 0.5 ATR) — How close price must be to a level to count as "at support/resistance." Lower = stricter.

EMA
• Fast EMA (default 50) — The responsive trend line.
• Slow EMA (default 200) — The structural trend anchor.

RSI
• Length (default 14) — Standard RSI lookback.
• Overbought (default 70) / Oversold (default 30) — Zone thresholds.

Signals
• Minimum Pillars (default 2) — Set to 3 for highest quality signals only.
• Cooldown (default 10 bars) — Minimum spacing between signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔶 WHAT MAKES THIS ORIGINAL

While Fibonacci, EMA, and RSI are individually common, StrixFIBER integrates them through a structured pillar scoring system with proximity-based Fibonacci detection, RSI recovery signals (not raw readings), and automatic signal strength classification. The confluence layer evaluates whether a Fibonacci level is meaningful (is the EMA structure supporting it? is momentum confirming it?) rather than displaying the three tools independently. The ATR-based proximity detection for Fibonacci levels, combined with the transition-based RSI scoring and flip-only signal enforcement, creates a framework that is more than the sum of its parts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔶 RECOMMENDED USE

Designed for day trading on 15-minute to 1-hour charts across all markets: crypto, forex, stocks, indices, and commodities. Works well alongside StrixEDGE (trend confluence overlay) and StrixPULSE (pressure spectrum in a separate pane) for a complete multi-indicator setup.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ DISCLAIMER
This indicator is a technical analysis tool, not financial advice. No indicator guarantees profitable outcomes. Past performance of any signal does not indicate future results. Always apply proper risk management and use this tool as one component of a complete trading plan.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

5 alert conditions: Buy Signal, Sell Signal, Any Signal, Golden Cross, Death Cross.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Fibonacci EMA RSI Engine  [StrixEDGE]", shorttitle="Fibonacci EMA RSI Engine  [StrixEDGE]", overlay=true, max_labels_count=500, max_bars_back=500)

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  StrixFIBER v1.0                                                            ║
// ║  Three-pillar confluence: Auto Fibonacci + EMA 50/200 + RSI OB/OS          ║
// ║                                                                              ║
// ║  Signals fire when 2+ pillars confirm the same direction.                   ║
// ║  Strong signals require all 3 pillars aligned.                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝


// ============================================================================
// INPUTS
// ============================================================================

// ── Fibonacci ─────────────────────────────────────────────────────────────────
string GRP_FIB   = "🔶 Fibonacci"
int    i_fibLB   = input.int(120,   "Lookback Period",       minval=20,  maxval=500, group=GRP_FIB, tooltip="Bars used to find the highest high and lowest low for Fibonacci calculation.")
bool   i_showFib = input.bool(true, "Show Fibonacci Levels", group=GRP_FIB)
bool   i_showGZ  = input.bool(true, "Highlight Golden Zone (50–61.8%)", group=GRP_FIB, tooltip="The golden zone is where retracements most commonly reverse.")
bool   i_showLbl = input.bool(true, "Show Price Labels",     group=GRP_FIB, tooltip="Show price values at each Fibonacci level on the right edge.")

// ── EMA ───────────────────────────────────────────────────────────────────────
string GRP_EMA   = "🔷 EMA"
int    i_emaF    = input.int(50,    "Fast EMA",   minval=5,   group=GRP_EMA)
int    i_emaS    = input.int(200,   "Slow EMA",   minval=20,  group=GRP_EMA)
bool   i_showEMA = input.bool(true, "Show EMAs",  group=GRP_EMA)
bool   i_showCross = input.bool(true, "Show Golden / Death Cross", group=GRP_EMA)

// ── RSI ───────────────────────────────────────────────────────────────────────
string GRP_RSI   = "🟣 RSI"
int    i_rsiLen  = input.int(14,    "RSI Length",          minval=2,   group=GRP_RSI)
int    i_obLvl   = input.int(70,    "Overbought Level",   minval=60, maxval=90, group=GRP_RSI)
int    i_osLvl   = input.int(30,    "Oversold Level",     minval=10, maxval=40, group=GRP_RSI)
bool   i_showRSI = input.bool(true, "Show RSI OB/OS Markers", group=GRP_RSI)

// ── Signals ───────────────────────────────────────────────────────────────────
string GRP_SIG   = "⚡ Signals"
int    i_minPill = input.int(2,     "Minimum Pillars for Signal", minval=1, maxval=3, group=GRP_SIG, tooltip="1 = any single pillar, 2 = two must agree, 3 = all three required.")
int    i_cooldown= input.int(10,    "Signal Cooldown (bars)",     minval=1, group=GRP_SIG)
float  i_fibProx = input.float(0.5, "Fibonacci Proximity (ATR×)", minval=0.1, step=0.1, group=GRP_SIG, tooltip="How close price must be to a Fibonacci level to count as 'at support/resistance'.")

// ── Display ───────────────────────────────────────────────────────────────────
string GRP_DISP  = "🎨 Display"
bool   i_showDash = input.bool(true, "Show Dashboard", group=GRP_DISP)
bool   i_showSL   = input.bool(true, "Show Stop-Loss Level", group=GRP_DISP)


// ============================================================================
// PILLAR 1 — FIBONACCI AUTO-RETRACEMENT
// ============================================================================
// Finds highest high and lowest low over the lookback period, then calculates
// all standard Fibonacci retracement levels between them.

float fibHigh  = ta.highest(high, i_fibLB)
float fibLow   = ta.lowest(low, i_fibLB)
float fibRange = fibHigh - fibLow

// Standard Fibonacci levels (measured from the low)
float fib000 = fibLow                          // 0%
float fib236 = fibLow + fibRange * 0.236       // 23.6%
float fib382 = fibLow + fibRange * 0.382       // 38.2%
float fib500 = fibLow + fibRange * 0.500       // 50.0%
float fib618 = fibLow + fibRange * 0.618       // 61.8%
float fib786 = fibLow + fibRange * 0.786       // 78.6%
float fib100 = fibHigh                         // 100%

// Proximity detection — is price near a key Fibonacci level?
float atr      = ta.atr(14)
float proxDist = atr * i_fibProx

// Support levels (price pulling back down toward these in an uptrend)
bool nearFib382_sup = math.abs(close - fib382) <= proxDist
bool nearFib500_sup = math.abs(close - fib500) <= proxDist
bool nearFib618_sup = math.abs(close - fib618) <= proxDist

// Resistance levels (price pushing up toward these in a downtrend)
bool nearFib236_res = math.abs(close - fib236) <= proxDist
bool nearFib382_res = math.abs(close - fib382) <= proxDist
bool nearFib500_res = math.abs(close - fib500) <= proxDist
bool nearFib618_res = math.abs(close - fib618) <= proxDist

bool atFibSupport    = nearFib382_sup or nearFib500_sup or nearFib618_sup
bool atFibResistance = nearFib236_res or nearFib382_res or nearFib500_res or nearFib618_res

// Fibonacci pillar score
int fibScore = atFibSupport and close > fib500 ? 1 : atFibResistance and close < fib500 ? -1 : 0


// ============================================================================
// PILLAR 2 — EMA 50 / 200
// ============================================================================
float emaFast = ta.ema(close, i_emaF)
float emaSlow = ta.ema(close, i_emaS)

bool emaBull     = emaFast > emaSlow
bool emaBear     = emaFast < emaSlow
bool goldenCross = ta.crossover(emaFast, emaSlow)
bool deathCross  = ta.crossunder(emaFast, emaSlow)

// EMA pillar score
int emaScore = emaBull ? 1 : emaBear ? -1 : 0


// ============================================================================
// PILLAR 3 — RSI OVERBOUGHT / OVERSOLD
// ============================================================================
float rsiVal = ta.rsi(close, i_rsiLen)

bool isOB = rsiVal >= i_obLvl
bool isOS = rsiVal <= i_osLvl

// Recovery signals: RSI leaving OB or OS zone
bool osRecovery = rsiVal > i_osLvl and rsiVal[1] <= i_osLvl   // leaving oversold → bullish
bool obRecovery = rsiVal < i_obLvl and rsiVal[1] >= i_obLvl   // leaving overbought → bearish

// RSI zone awareness (not just recovery, but current zone)
bool rsiBullish = rsiVal > 50 and rsiVal < i_obLvl
bool rsiBearish = rsiVal < 50 and rsiVal > i_osLvl

// RSI pillar score
int rsiScore = osRecovery ? 1 : obRecovery ? -1 : 0


// ============================================================================
// CONFLUENCE SCORING & SIGNAL GENERATION
// ============================================================================
// Each pillar contributes +1 (bullish) or −1 (bearish).
// Signal fires when enough pillars agree on the same direction.

int bullPillars = (emaScore == 1 ? 1 : 0) + (fibScore == 1 ? 1 : 0) + (rsiScore == 1 ? 1 : 0)
int bearPillars = (emaScore == -1 ? 1 : 0) + (fibScore == -1 ? 1 : 0) + (rsiScore == -1 ? 1 : 0)

bool rawBuy  = bullPillars >= i_minPill and bullPillars > bullPillars[1]
bool rawSell = bearPillars >= i_minPill and bearPillars > bearPillars[1]

// ── Flip-only + cooldown ──────────────────────────────────────────────────────
var int lastSigDir = 0
var int lastSigBar = -9999

bool buySignal  = rawBuy  and lastSigDir != 1  and (bar_index - lastSigBar) >= i_cooldown
bool sellSignal = rawSell and lastSigDir != -1 and (bar_index - lastSigBar) >= i_cooldown

if buySignal
    lastSigDir := 1
    lastSigBar := bar_index
if sellSignal
    lastSigDir := -1
    lastSigBar := bar_index

// Signal strength
bool strongBuy  = buySignal  and bullPillars == 3
bool strongSell = sellSignal and bearPillars == 3


// ============================================================================
// VISUALS — FIBONACCI LEVELS (projected into future only)
// ============================================================================
// Lines start at current bar and extend right into future.
// Historical bars stay clean — no overlapping with past candles.
// Dashed style distinguishes Fibonacci from EMA (solid).

color clrFib0   = color.new(#78909C, 30)
color clrFib236 = color.new(#42A5F5, 20)
color clrFib382 = color.new(#26C6DA, 20)
color clrFib500 = color.new(#FFCA28, 0)
color clrFib618 = color.new(#FF7043, 0)
color clrFib786 = color.new(#AB47BC, 20)
color clrFib100 = color.new(#78909C, 30)

var line ln_000 = na
var line ln_236 = na
var line ln_382 = na
var line ln_500 = na
var line ln_618 = na
var line ln_786 = na
var line ln_100 = na
var linefill gzFill = na

var label lb_000 = na
var label lb_236 = na
var label lb_382 = na
var label lb_500 = na
var label lb_618 = na
var label lb_786 = na
var label lb_100 = na
var label lb_gz  = na

if i_showFib and barstate.islast

    // ── Clean up previous objects ─────────────────────────────────────────────
    line.delete(ln_000),     line.delete(ln_236),     line.delete(ln_382)
    line.delete(ln_500),     line.delete(ln_618)
    line.delete(ln_786),     line.delete(ln_100)
    linefill.delete(gzFill)
    label.delete(lb_000),    label.delete(lb_236),    label.delete(lb_382)
    label.delete(lb_500),    label.delete(lb_618)
    label.delete(lb_786),    label.delete(lb_100),    label.delete(lb_gz)

    // ── Draw lines 20 bars into the future ──────────────────────────────────
    int fibEnd = bar_index + 20

    ln_000 := line.new(bar_index, fib000, fibEnd, fib000, color=clrFib0,   width=1, style=line.style_dashed)
    ln_236 := line.new(bar_index, fib236, fibEnd, fib236, color=clrFib236, width=1, style=line.style_dashed)
    ln_382 := line.new(bar_index, fib382, fibEnd, fib382, color=clrFib382, width=1, style=line.style_dashed)
    ln_500 := line.new(bar_index, fib500, fibEnd, fib500, color=clrFib500, width=2, style=line.style_solid)
    ln_618 := line.new(bar_index, fib618, fibEnd, fib618, color=clrFib618, width=2, style=line.style_solid)
    ln_786 := line.new(bar_index, fib786, fibEnd, fib786, color=clrFib786, width=1, style=line.style_dashed)
    ln_100 := line.new(bar_index, fib100, fibEnd, fib100, color=clrFib100, width=1, style=line.style_dashed)

    // ── Golden Zone fill between 50% and 61.8% ───────────────────────────────
    if i_showGZ
        gzFill := linefill.new(ln_500, ln_618, color=color.new(#FF7043, 85))

    // ── Price labels at the right edge ────────────────────────────────────────
    int lblX = fibEnd + 2

    if i_showLbl
        lb_000 := label.new(lblX, fib000, "0%  —  "    + str.tostring(fib000, format.mintick), style=label.style_none, textcolor=clrFib0,   size=size.normal, textalign=text.align_left)
        lb_236 := label.new(lblX, fib236, "23.6%  —  " + str.tostring(fib236, format.mintick), style=label.style_none, textcolor=clrFib236, size=size.normal, textalign=text.align_left)
        lb_382 := label.new(lblX, fib382, "38.2%  —  " + str.tostring(fib382, format.mintick), style=label.style_none, textcolor=clrFib382, size=size.normal, textalign=text.align_left)
        lb_500 := label.new(lblX, fib500, "50%  —  "   + str.tostring(fib500, format.mintick), style=label.style_none, textcolor=clrFib500, size=size.normal, textalign=text.align_left)
        lb_618 := label.new(lblX, fib618, "61.8%  —  " + str.tostring(fib618, format.mintick), style=label.style_none, textcolor=clrFib618, size=size.normal, textalign=text.align_left)
        lb_786 := label.new(lblX, fib786, "78.6%  —  " + str.tostring(fib786, format.mintick), style=label.style_none, textcolor=clrFib786, size=size.normal, textalign=text.align_left)
        lb_100 := label.new(lblX, fib100, "100%  —  "  + str.tostring(fib100, format.mintick), style=label.style_none, textcolor=clrFib100, size=size.normal, textalign=text.align_left)

    // ── GOLDEN ZONE label centered in the zone ────────────────────────────────
    if i_showGZ
        float gzMid = (fib500 + fib618) / 2.0
        lb_gz := label.new(bar_index + 10, gzMid, "◆  GOLDEN ZONE  ◆", style=label.style_none, textcolor=color.new(#FF7043, 0), size=size.large, textalign=text.align_center)


// ============================================================================
// VISUALS — EMA
// ============================================================================
color emaFastClr = emaBull ? color.new(#00E676, 0) : color.new(#FF5252, 0)
color emaSlowClr = color.new(#FF7043, 30)

plot(i_showEMA ? emaFast : na, "EMA 50",  color=emaFastClr, linewidth=2)
plot(i_showEMA ? emaSlow : na, "EMA 200", color=emaSlowClr, linewidth=2)

// ── Golden Cross / Death Cross markers ────────────────────────────────────────
plotshape(i_showCross and goldenCross, "Golden Cross", shape.diamond, location.belowbar, color.new(#00E676, 0), size=size.tiny, text="GC", textcolor=color.new(#00E676, 0))
plotshape(i_showCross and deathCross,  "Death Cross",  shape.diamond, location.abovebar, color.new(#FF5252, 0), size=size.tiny, text="DC", textcolor=color.new(#FF5252, 0))


// ============================================================================
// VISUALS — RSI SIGNALS ON CHART
// ============================================================================
plotshape(i_showRSI and isOS and not isOS[1], "RSI Oversold",   shape.circle, location.belowbar, color.new(#00E676, 20), size=size.tiny)
plotshape(i_showRSI and isOB and not isOB[1], "RSI Overbought", shape.circle, location.abovebar, color.new(#FF5252, 20), size=size.tiny)


// ============================================================================
// VISUALS — BUY / SELL SIGNALS + ENTRY PRICE
// ============================================================================
if buySignal
    string bTxt = strongBuy ? "Strong Buy\n" + str.tostring(close, format.mintick) : "Buy\n" + str.tostring(close, format.mintick)
    color  bClr = strongBuy ? color.new(#00C853, 0) : color.new(#00E676, 0)
    label.new(bar_index, low, bTxt, style=label.style_label_up, color=bClr, textcolor=color.white, size=size.normal)

if sellSignal
    string sTxt = strongSell ? "Strong Sell\n" + str.tostring(close, format.mintick) : "Sell\n" + str.tostring(close, format.mintick)
    color  sClr = strongSell ? color.new(#C62828, 0) : color.new(#FF5252, 0)
    label.new(bar_index, high, sTxt, style=label.style_label_down, color=sClr, textcolor=color.white, size=size.normal)

// ── Entry line + Stop-Loss ────────────────────────────────────────────────────
var float entryPrice = na
var float slPrice    = na
var int   entryBar   = -9999
var int   entryDir   = 0

if buySignal
    entryPrice := close
    slPrice    := low - atr * 1.5
    entryBar   := bar_index
    entryDir   := 1
if sellSignal
    entryPrice := close
    slPrice    := high + atr * 1.5
    entryBar   := bar_index
    entryDir   := -1

bool showLines = not na(entryPrice) and (bar_index - entryBar) <= 20
color lineClr  = entryDir == 1 ? color.new(#00E676, 40) : color.new(#FF5252, 40)

plot(showLines ? entryPrice : na, "Entry Level", color=lineClr, style=plot.style_linebr, linewidth=2)
plot(showLines and i_showSL ? slPrice : na, "Stop-Loss", color=color.new(#FF9800, 50), style=plot.style_linebr, linewidth=1)


// ============================================================================
// DASHBOARD
// ============================================================================
if i_showDash and barstate.islast

    var table dash = table.new(position.top_right, 3, 7, bgcolor=color.new(#131722, 5), border_color=color.new(#2A2E39, 0), border_width=1, frame_color=color.new(#363A45, 0), frame_width=2)

    // ── Header ────────────────────────────────────────────────────────────────
    table.cell(dash, 0, 0, "STRIXFIBER",   text_color=color.white, text_size=size.small, bgcolor=color.new(#E65100, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0",         text_color=#FFAB91,     text_size=size.tiny,  bgcolor=color.new(#E65100, 0), text_halign=text.align_center)
    table.cell(dash, 2, 0, "STATUS",        text_color=color.white, text_size=size.tiny,  bgcolor=color.new(#E65100, 0), text_halign=text.align_right)

    // ── EMA Row ───────────────────────────────────────────────────────────────
    string emaTxt = emaBull ? "BULLISH" : "BEARISH"
    string emaIco = emaBull ? " ▲" : " ▼"
    color  emaClr = emaBull ? #00E676 : #FF5252
    table.cell(dash, 0, 1, "EMA " + str.tostring(i_emaF) + "/" + str.tostring(i_emaS), text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 1, emaTxt,    text_color=emaClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 1, emaIco,    text_color=emaClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── RSI Row ───────────────────────────────────────────────────────────────
    string rsiTxt = isOB ? "OVERBOUGHT" : isOS ? "OVERSOLD" : "NEUTRAL"
    string rsiIco = isOB ? " ▼" : isOS ? " ▲" : " ◆"
    color  rsiClr = isOB ? #FF5252 : isOS ? #00E676 : #78909C
    table.cell(dash, 0, 2, "RSI (" + str.tostring(rsiVal, "#.#") + ")", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 2, rsiTxt,    text_color=rsiClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 2, rsiIco,    text_color=rsiClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Fibonacci Row ─────────────────────────────────────────────────────────
    string fibTxt = atFibSupport ? "AT SUPPORT" : atFibResistance ? "AT RESISTANCE" : "BETWEEN"
    color  fibClr = atFibSupport ? #00E676 : atFibResistance ? #FF5252 : #78909C
    string fibIco = atFibSupport ? " ✓" : atFibResistance ? " ✗" : " ◆"
    table.cell(dash, 0, 3, "FIBONACCI", text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 3, fibTxt,      text_color=fibClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 3, fibIco,      text_color=fibClr, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Nearest Fib Level ─────────────────────────────────────────────────────
    float d236 = math.abs(close - fib236)
    float d382 = math.abs(close - fib382)
    float d500 = math.abs(close - fib500)
    float d618 = math.abs(close - fib618)
    float d786 = math.abs(close - fib786)
    float minD = math.min(d236, math.min(d382, math.min(d500, math.min(d618, d786))))

    string nearTxt = minD == d236 ? "23.6%" : minD == d382 ? "38.2%" : minD == d500 ? "50.0%" : minD == d618 ? "61.8%" : "78.6%"
    table.cell(dash, 0, 4, "NEAREST",   text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_left)
    table.cell(dash, 1, 4, nearTxt,      text_color=#FFCA28, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.cell(dash, 2, 4, str.tostring(minD / atr, "#.##") + " ATR", text_color=#90A4AE, text_size=size.tiny, bgcolor=color.new(#1E222D, 0), text_halign=text.align_right)

    // ── Confluence Row ────────────────────────────────────────────────────────
    int    pillars  = math.max(bullPillars, bearPillars)
    string pillDir  = bullPillars >= bearPillars ? "BULL" : "BEAR"
    string pillTxt  = str.tostring(pillars) + " / 3  " + pillDir
    color  pillBG   = pillars >= i_minPill ? (bullPillars >= bearPillars ? color.new(#1B5E20, 0) : color.new(#B71C1C, 0)) : color.new(#37474F, 0)
    color  pillClr  = pillars >= i_minPill ? color.white : #90A4AE

    table.cell(dash, 0, 5, "PILLARS",  text_color=color.white, text_size=size.small, bgcolor=pillBG, text_halign=text.align_left)
    table.cell(dash, 1, 5, pillTxt,     text_color=pillClr,     text_size=size.small, bgcolor=pillBG, text_halign=text.align_center)
    table.cell(dash, 2, 5, pillars >= i_minPill ? "🟢" : "⚪", text_color=color.white, text_size=size.small, bgcolor=pillBG, text_halign=text.align_right)

    // ── Signal Row ────────────────────────────────────────────────────────────
    string sigTxt = lastSigDir == 1 ? "LAST: BUY" : lastSigDir == -1 ? "LAST: SELL" : "NONE"
    color  sigClr = lastSigDir == 1 ? #00E676 : lastSigDir == -1 ? #FF5252 : #546E7A
    string sigAge = lastSigBar > 0 ? str.tostring(bar_index - lastSigBar) + " bars ago" : "—"
    table.cell(dash, 0, 6, "SIGNAL",   text_color=#B0BEC5, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_left)
    table.cell(dash, 1, 6, sigTxt,      text_color=sigClr,  text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_center)
    table.cell(dash, 2, 6, sigAge,      text_color=#546E7A, text_size=size.tiny, bgcolor=color.new(#131722, 0), text_halign=text.align_right)


// ============================================================================
// ALERTS
// ============================================================================
alertcondition(buySignal,                "StrixFIBER — Buy Signal",   "StrixFIBER BUY on {{ticker}} {{interval}}")
alertcondition(sellSignal,               "StrixFIBER — Sell Signal",  "StrixFIBER SELL on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,  "StrixFIBER — Any Signal",   "StrixFIBER SIGNAL on {{ticker}} {{interval}}")
alertcondition(goldenCross,              "StrixFIBER — Golden Cross", "StrixFIBER: Golden Cross on {{ticker}} {{interval}}")
alertcondition(deathCross,               "StrixFIBER — Death Cross",  "StrixFIBER: Death Cross on {{ticker}} {{interval}}")
````
