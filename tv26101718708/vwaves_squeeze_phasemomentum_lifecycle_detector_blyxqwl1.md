# VWaves Squeeze Phase-Momentum Lifecycle Detector

- url: https://www.tradingview.com/script/blYXqwL1-VWaves-Squeeze-Phase-Momentum-Lifecycle-Detector/
- type: indicator
- pine_id: PUB;5e362e1877b64ab7979e23e61b139b59
- version: 1.0

## Description

**VWaves Squeeze Phase · Momentum Lifecycle Detector**

---

Every move has a lifecycle. This indicator tells you where you are in it.

Most indicators tell you what price *did*. Squeeze Phase tells you what the move is *doing* — whether momentum is loading, expanding, peaking, or dying. It reads the geometry between price and its EMAs, weighted by candle conviction, to map the real-time energy of a move across seven distinct phases.

**The Core Idea**

Two measurements combined into one reading:

- **Squeeze %** — the total spread between price, the fast EMA, and the slow EMA as a percentage. Tight spread = coiled energy. Wide spread = full extension. Contracting spread = the move is fading.
- **Candle Reflex** — how much of each bar is body vs wick. A full-body candle during expansion means conviction. A doji during expansion means nobody's committed to staying there.

Multiply them together and you get **Thrust** — a momentum field reading that captures both *where* price is in the EMA structure and *how much energy* is behind it.

**Seven Phases**

| Phase | What It Means |
|-------|--------------|
| **ACCUM** | EMAs compressed. The spring is loading. Watch for a breakout direction. |
| **FRONTSIDE** | Price separating from EMAs. The move is starting. Early entry territory. |
| **EXPANSION** | Full separation, strong thrust. The meat of the run. Stay in. |
| **PEAK** | Price and fast EMA disagree. The move is topping. Tighten or exit. |
| **CONSOLIDATION** | EMAs compress after expansion. Pause — could continue or reverse. |
| **BACKSIDE** | Both spreads negative. The fade is underway. |
| **BREAKDOWN** | Full bearish expansion. Get out or get short. |

**How To Read It**

- **Green histogram expanding** → momentum building, ride it
- **Histogram shrinking while still green** → energy leaving the move, prepare to exit
- **Phase transition dots** → squeeze breakouts and phase changes marked in real time
- **Squeeze % contracting from a peak** → the move is dying before price confirms it

**What Makes This Different**

The reflex multiplier is the key. A stock can be in "expansion" by EMA geometry, but if the candles are dojis and small bodies, the thrust reading drops — telling you the expansion has no conviction. This catches tops and traps that pure EMA or MACD-based indicators miss.

Works on any timeframe. No repainting. All calculations use standard EMAs and price action — no proprietary or black-box math.

---

*Part of the VWaves system. More tools coming soon.*

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("VWaves Squeeze Phase", shorttitle="SQZ Phase", overlay=false, precision=3)

// ─── INPUTS ───
grpEMA    = "EMA Settings"
fastLen   = input.int(9,    "Fast EMA Length",   minval=2, maxval=50,  group=grpEMA)
slowLen   = input.int(21,   "Slow EMA Length",   minval=5, maxval=100, group=grpEMA)
srcEMA    = input.source(close, "EMA Source",    group=grpEMA)

grpPhase  = "Phase Detection"
sqzThresh = input.float(0.5,  "Squeeze Threshold %",    minval=0.1, maxval=2.0, step=0.1, group=grpPhase, tooltip="Below this combined spread = SQUEEZE phase")
expThresh = input.float(1.5,  "Expansion Threshold %",  minval=0.5, maxval=5.0, step=0.1, group=grpPhase, tooltip="Above this = full EXPANSION/BREAKDOWN")
reflexMin = input.float(0.15, "Reflex Min (body ratio)", minval=0.0, maxval=0.5, step=0.05, group=grpPhase, tooltip="Candle body ratio below this = no conviction")

grpVis    = "Visual"
showHisto = input.bool(true,  "Show Squeeze Histogram",  group=grpVis)
showReflex = input.bool(true, "Show Reflex Multiplier",  group=grpVis)
showPhase = input.bool(true,  "Show Phase Background",   group=grpVis)
showDots  = input.bool(true,  "Show Phase Transition Dots", group=grpVis)

grpAlert  = "Alerts"
alertSqzBreak = input.bool(true, "Alert: Squeeze Breakout", group=grpAlert)
alertPhaseChg = input.bool(true, "Alert: Phase Change",     group=grpAlert)


// ─── EMA CALCULATIONS ───
fastEMA = ta.ema(srcEMA, fastLen)
slowEMA = ta.ema(srcEMA, slowLen)


// ─── SQUEEZE SPREAD PERCENTAGES ───
// Price-to-Fast spread: how far price is from fast EMA (% of price)
priceFastPct = ((close - fastEMA) / close) * 100

// Fast-to-Slow spread: how far fast EMA is from slow EMA (% of price)
fastSlowPct = ((fastEMA - slowEMA) / close) * 100

// Combined squeeze: total absolute spread — position in move
combinedSqz = math.abs(priceFastPct) + math.abs(fastSlowPct)


// ─── CANDLE BODY REFLEX ───
// Body ratio: how much of the candle range is body vs wick
// Full body (marubozu) = 1.0 = max conviction
// Doji = ~0.0 = no conviction
candleRange = high - low
bodySize    = math.abs(close - open)
bodyRatio   = candleRange > 0 ? bodySize / candleRange : 0.0

// Reflex multiplier: scales the squeeze reading by candle conviction
// Below reflexMin = dampened, above = amplified
reflexMult = bodyRatio >= reflexMin ? 0.5 + (bodyRatio * 1.5) : bodyRatio / reflexMin * 0.5

// Directional reflex: positive for bullish bodies, negative for bearish
dirReflex = close >= open ? reflexMult : -reflexMult


// ─── THRUST SIGNAL (squeeze × reflex) ───
// This is the core innovation: EMA spread tells you WHERE in the move
// Candle reflex tells you the ENERGY of that moment
// Together = real-time momentum field reading
thrustRaw = combinedSqz * dirReflex
thrustSmooth = ta.ema(thrustRaw, 3)


// ─── PHASE DETECTION ───
// Phase is determined by the direction and magnitude of both spreads
// plus the reflex energy

PHASE_ACCUMULATION = 0
PHASE_FRONTSIDE    = 1
PHASE_EXPANSION    = 2
PHASE_PEAK         = 3
PHASE_CONSOLIDATION = 4
PHASE_BACKSIDE     = 5
PHASE_BREAKDOWN    = 6

var int currentPhase = PHASE_ACCUMULATION

// Determine phase from spread geometry
getPhase() =>
    int phase = PHASE_ACCUMULATION
    
    if combinedSqz < sqzThresh
        // Tight squeeze — either accumulation or consolidation
        // Use prior context: if we were in expansion, this is consolidation
        if currentPhase >= PHASE_EXPANSION and currentPhase <= PHASE_PEAK
            phase := PHASE_CONSOLIDATION
        else
            phase := PHASE_ACCUMULATION
    else if priceFastPct > 0 and fastSlowPct > 0
        // Both positive: price > fast > slow — bullish structure
        if combinedSqz >= expThresh
            phase := PHASE_EXPANSION
        else
            phase := PHASE_FRONTSIDE
    else if priceFastPct > 0 and fastSlowPct < 0
        // Price above fast but fast below slow — early recovery or peak
        phase := PHASE_PEAK
    else if priceFastPct < 0 and fastSlowPct > 0
        // Price below fast but fast still above slow — topping/rollover
        phase := PHASE_PEAK
    else if priceFastPct < 0 and fastSlowPct < 0
        // Both negative: price < fast < slow — bearish structure
        if combinedSqz >= expThresh
            phase := PHASE_BREAKDOWN
        else
            phase := PHASE_BACKSIDE
    else
        phase := PHASE_ACCUMULATION
    phase

newPhase = getPhase()
prevPhase = currentPhase
currentPhase := newPhase


// ─── PHASE COLORS ───
phaseColor = switch currentPhase
    PHASE_ACCUMULATION  => color.new(color.gray, 30)
    PHASE_FRONTSIDE     => color.new(color.aqua, 20)
    PHASE_EXPANSION     => color.new(color.lime, 10)
    PHASE_PEAK          => color.new(color.yellow, 20)
    PHASE_CONSOLIDATION => color.new(color.orange, 30)
    PHASE_BACKSIDE      => color.new(color.orange, 10)
    PHASE_BREAKDOWN     => color.new(color.red, 10)
    => color.new(color.gray, 50)

phaseName = switch currentPhase
    PHASE_ACCUMULATION  => "ACCUM"
    PHASE_FRONTSIDE     => "FRONT"
    PHASE_EXPANSION     => "EXPAND"
    PHASE_PEAK          => "PEAK"
    PHASE_CONSOLIDATION => "CONSOL"
    PHASE_BACKSIDE      => "BACK"
    PHASE_BREAKDOWN     => "BREAK▼"
    => "—"


// ─── SQUEEZE BREAKOUT DETECTION ───
// Squeeze breaks when combined spread crosses above threshold after being below
wasSqueezed    = ta.valuewhen(combinedSqz < sqzThresh, 1, 0) == 1
sqzBreakout    = combinedSqz >= sqzThresh and combinedSqz[1] < sqzThresh
sqzBreakBull   = sqzBreakout and priceFastPct > 0
sqzBreakBear   = sqzBreakout and priceFastPct < 0

// Phase transition detection
phaseChanged = currentPhase != prevPhase


// ─── PLOTTING ───

// Thrust histogram (the main visual)
thrustColor = thrustSmooth > 0 ? 
     (thrustSmooth > thrustSmooth[1] ? color.new(color.lime, 10) : color.new(color.aqua, 30)) : 
     (thrustSmooth < thrustSmooth[1] ? color.new(color.red, 10)  : color.new(color.orange, 30))

plot(showHisto ? thrustSmooth : na, "Thrust", color=thrustColor, style=plot.style_columns, linewidth=2)

// Zero line
hline(0, "Zero", color=color.new(color.white, 80), linestyle=hline.style_dotted)

// Combined squeeze as a line overlay
plot(combinedSqz, "Squeeze %", color=color.new(color.white, 60), linewidth=1, style=plot.style_line)
plot(-combinedSqz, "Squeeze % (neg)", color=color.new(color.white, 80), linewidth=1, style=plot.style_line)

// Squeeze threshold bands
hline(sqzThresh,  "Squeeze Band +", color=color.new(color.yellow, 70), linestyle=hline.style_dashed)
hline(-sqzThresh, "Squeeze Band -", color=color.new(color.yellow, 70), linestyle=hline.style_dashed)
hline(expThresh,  "Expansion +",    color=color.new(color.lime, 70),   linestyle=hline.style_dashed)
hline(-expThresh, "Expansion -",    color=color.new(color.red, 70),    linestyle=hline.style_dashed)

// Reflex multiplier as small dots along zero
plot(showReflex ? bodyRatio * 0.3 : na, "Reflex", color=close >= open ? color.new(color.lime, 50) : color.new(color.red, 50), style=plot.style_circles, linewidth=1)

// Phase background shading
bgcolor(showPhase ? color.new(phaseColor, 88) : na, title="Phase BG")

// Phase transition markers
plotshape(showDots and sqzBreakBull, "Squeeze Break ▲", shape.diamond, location.bottom, color.new(color.lime, 0), size=size.small)
plotshape(showDots and sqzBreakBear, "Squeeze Break ▼", shape.diamond, location.top, color.new(color.red, 0), size=size.small)
plotshape(showDots and phaseChanged and currentPhase == PHASE_EXPANSION, "→ Expansion", shape.triangleup, location.bottom, color.new(color.lime, 0), size=size.tiny)
plotshape(showDots and phaseChanged and currentPhase == PHASE_BREAKDOWN, "→ Breakdown", shape.triangledown, location.top, color.new(color.red, 0), size=size.tiny)

// Phase label (shown on last bar)
var label phaseLabel = na
if barstate.islast
    label.delete(phaseLabel)
    phaseLabel := label.new(
         bar_index, thrustSmooth,
         phaseName + "\n" + str.tostring(combinedSqz, "#.##") + "%",
         color=color.new(phaseColor, 40),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.normal)


// ─── DATA TABLE (circle-inspired compact readout) ───
var table infoTable = table.new(position.top_right, 2, 7, 
     bgcolor=color.new(color.black, 20), 
     border_color=color.new(color.gray, 70),
     border_width=1,
     frame_color=color.new(color.gray, 70),
     frame_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "PHASE",        text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 0, phaseName,       text_color=phaseColor, text_size=size.small)
    
    table.cell(infoTable, 0, 1, "SQUEEZE",       text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(combinedSqz, "#.##") + "%", 
         text_color=combinedSqz < sqzThresh ? color.yellow : combinedSqz > expThresh ? color.lime : color.white, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 2, "P↔FAST",       text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(priceFastPct, "+#.##;-#.##") + "%", 
         text_color=priceFastPct > 0 ? color.aqua : color.red, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 3, "F↔SLOW",       text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(fastSlowPct, "+#.##;-#.##") + "%", 
         text_color=fastSlowPct > 0 ? color.yellow : color.red, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 4, "REFLEX",        text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(bodyRatio, "#.##"), 
         text_color=bodyRatio > 0.5 ? color.lime : bodyRatio > reflexMin ? color.white : color.gray, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 5, "THRUST",        text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 5, str.tostring(thrustSmooth, "+#.##;-#.##"), 
         text_color=thrustSmooth > 0 ? color.lime : color.red, 
         text_size=size.small)
    
    table.cell(infoTable, 0, 6, "BODY",          text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 6, str.tostring(bodySize, "#.####"), 
         text_color=close >= open ? color.lime : color.red, 
         text_size=size.small)


// ─── ALERTS ───
alertcondition(alertSqzBreak and sqzBreakBull, "Squeeze Break Bullish", "🔥 SQZ BREAK ▲ — Bullish expansion from squeeze")
alertcondition(alertSqzBreak and sqzBreakBear, "Squeeze Break Bearish", "🔻 SQZ BREAK ▼ — Bearish breakdown from squeeze")
alertcondition(alertPhaseChg and phaseChanged,  "Phase Transition",      "⚡ Phase transition detected")
````
