# Phantom Structure Engine [JOAT]

- url: https://www.tradingview.com/script/YDqPZcAd-Phantom-Structure-Engine-JOAT/
- type: indicator
- pine_id: PUB;39bf9e46f1dd474b976b67c56d4f9f11
- version: 1.0

## Description

[b]Phantom Structure Engine [JOAT][/b]

[b]Overview[/b]

Phantom Structure Engine is a comprehensive Smart Money Concepts (SMC) framework built entirely in Pine Script v6 using typed User-Defined Types and methods. It maps institutional price structure across five dimensions simultaneously: swing Break of Structure (BOS), Change of Character (CHoCH), Order Blocks (OB), Fair Value Gaps (FVG), Equal Highs/Lows (EQH/EQL), Liquidity Sweeps, and dynamic Premium/Discount/Equilibrium zones — all rendered with an institutional-grade dark visual palette and managed via object arrays.

[image]https://www.tradingview.com/x/R6vPr3L2/[/image]

[b]Why a Unified SMC Framework?[/b]

SMC concepts are deeply interconnected. A BOS creates the context for a valid Order Block. A CHoCH signals a structural regime shift that invalidates existing OBs. A liquidity sweep above an EQH often precedes a reversal into a Discount zone. Displaying these concepts in isolation (as separate indicators) breaks the logical chain between them. Phantom Structure Engine fuses all layers into a single coherent visual, so each element is always read in its correct structural context.

[b]Core Engine — Swing Structure[/b]

Two separate pivot engines run concurrently:

- [b]Swing pivots[/b] (configurable left/right bars, default 10/10): define the major structure highs and lows used for BOS and CHoCH detection
- [b]Internal pivots[/b] (default 3/3): track minor structure shifts for shorter-term intrabar analysis

[b]BOS Detection with Confirmation Counter[/b]

Rather than firing on the first close beyond a swing level, the engine counts consecutive closes above the last swing high (or below the last swing low). A BOS only registers when the close count reaches or exceeds the configurable confirmation threshold (default 1, max 5). This suppresses false breaks caused by wicks and momentary spikes while remaining responsive.

- [b]BOS (Break of Structure):[/b] Close beyond swing level, structure direction confirmed. Displayed as a horizontal line from the pivot bar to the break bar, with a BOS label.
- [b]CHoCH (Change of Character):[/b] BOS that occurs against the prevailing structural direction (e.g., a bullish break when the prior confirmed direction was bearish). Displayed in gold with a dashed line and CHoCH label.

[b]Order Block Detection[/b]

When a BOS or CHoCH fires, the engine scans backward (configurable lookback, default 10 bars) for the last opposing candle — a bearish candle before a bullish BOS, or a bullish candle before a bearish BOS. This candle becomes the Order Block zone.

Each OB is drawn with a two-layer box: a wide semi-transparent outer box and a tighter inner highlight. The OB extends forward on every bar and automatically invalidates (turns grey) when price closes through the opposite boundary — the exact behaviour seen when an OB has been mitigated by institutional flow.

[b]Fair Value Gap Detection[/b]

A bullish FVG is identified when bar[0].low > bar[2].high (a gap in price between the current bar's low and two bars ago's high), indicating that price moved so fast upward that no trading occurred in that range. Bearish FVG is the mirror. FVGs are drawn as dotted-border boxes that extend forward and auto-fill (turn grey) when price returns to close the gap.

[b]Equal Highs / Equal Lows (EQH / EQL)[/b]

At each new swing pivot, the engine compares the current pivot value against the previous pivot of the same type. If the absolute percentage difference is less than 0.15%, they are classified as equal and an EQH or EQL label is stamped at the midpoint. These levels represent liquidity pools resting above or below price — targets for institutional sweeps.

[b]Liquidity Sweeps[/b]

A sweep is detected when price wicks beyond the last confirmed swing high or low but closes back on the opposite side. This is the classic liquidity grab: price hunts stops above a high (or below a low), then reverses. Sweep labels fire at the wick extreme in gold — one of the highest-probability reversal signals in institutional analysis.

[b]Premium / Discount / Equilibrium Zones[/b]

After each confirmed BOS, the engine identifies the full range between the last confirmed swing high and swing low. This range is divided into three zones:
- [b]Premium (top 38.2%):[/b] Statistically expensive — short bias in a bearish structure
- [b]Equilibrium (38.2%–61.8%):[/b] Fair value — reduce exposure
- [b]Discount (bottom 38.2%):[/b] Statistically cheap — long bias in a bullish structure

Previous zones are deleted and redrawn on each new BOS, keeping the chart clean.

[b]Periodic Levels (PDH / PDL / PWH / PWL)[/b]

Previous Day High/Low and Previous Week High/Low are fetched via request.security() with lookahead disabled (barmerge.lookahead_off), preventing any future-bar contamination. These levels render as step-line plots and represent the primary reference levels used by institutional order desks at open.

[b]Institutional Funding Candles[/b]

Bars where the true range exceeds 1.5× ATR(14) AND volume exceeds 2× the 20-bar volume SMA are highlighted as funding candles. These represent institutional participation bars and are coloured based on the current structural direction: teal (bullish structure), red (bearish structure), gold (neutral).

[b]Dashboard (Top Right)[/b]

A compact 2-column, 8-row table displays: current structural direction, active OB count, open FVG count, last confirmed swing high/low values, and current sweep status for both sides.

[b]Inputs Reference[/b]

[b]Structure Settings[/b]
- Swing Pivot Left/Right Bars (10/10) — major swing sensitivity
- Internal Pivot Left/Right (3/3) — minor structure sensitivity
- BOS Confirmation Closes (1–5) — consecutive closes needed to confirm BOS
- Show BOS Labels / CHoCH Labels / HH-HL-LH-LL labels

[b]Order Blocks[/b]
- Show Order Blocks
- OB Lookback Candles (10) — how far back to scan for the OB candle
- Max Active OBs (6) — older OBs are deleted when limit is reached

[b]Fair Value Gaps[/b]
- Show Fair Value Gaps
- Max Active FVGs (5)

[b]Premium / Discount[/b]
- Show PD Zones / EQH-EQL / Liquidity Sweeps

[b]Periodic Levels[/b]
- Show Prev Day H/L / Prev Week H/L

[b]Visual[/b]
- Theme: Dark, Light, Auto
- Show Funding Candles

[b]How to Use[/b]

1. Apply on any liquid instrument. Allow the warmup period (driven by pivot lookback) before trusting the signals.
2. Read structure direction from the dashboard. BOS labels in teal confirm a bullish shift; CHoCH in gold signals a potential trend reversal.
3. Look for price to pull back into a valid (not invalidated) OB or into the Discount zone before considering long entries. Reverse for shorts.
4. FVG zones often act as magnets — price tends to revisit them before continuing in the BOS direction.
5. Treat Liquidity Sweep labels as potential reversal alerts, particularly when they align with OBs or Discount/Premium zones.

[b]Non-Repainting Design[/b]

All BOS, CHoCH, sweep, and FVG signals are gated by barstate.isconfirmed. Periodic levels use close[1] with lookahead_off. No pivot value is read until the required right-bar confirmation period has elapsed. Historical labels never shift position.

[b]Limitations[/b]

- SMC is a discretionary framework. This indicator automates detection but cannot replace contextual judgment on higher-timeframe bias.
- In extremely fast-moving markets, FVGs may form and fill within the same session, reducing their relevance as future targets.
- EQH/EQL detection uses a 0.15% price equality threshold — this may need adjustment for very low-priced or highly volatile instruments.
- OBs are detected from the most recent opposing candle before a BOS. On some instruments, the true institutional OB may be further back.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. SMC concepts describe price behaviour patterns and do not guarantee any future market outcome. Always conduct your own analysis and use proper risk management.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Phantom Structure Engine [JOAT]", shorttitle="PSE [JOAT]", overlay=true,
          max_boxes_count=500, max_lines_count=500, max_labels_count=300)
// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_S  = "Structure Settings"
var GRP_OB = "Order Blocks"
var GRP_FG = "Fair Value Gaps"
var GRP_PD = "Premium / Discount"
var GRP_PL = "Periodic Levels"
var GRP_V  = "Visual"

i_pvLeft   = input.int(10, "Swing Pivot Left Bars",  group=GRP_S, minval=3)
i_pvRight  = input.int(10, "Swing Pivot Right Bars", group=GRP_S, minval=3)
i_iPvL     = input.int(3,  "Internal Pivot Left",    group=GRP_S, minval=1)
i_iPvR     = input.int(3,  "Internal Pivot Right",   group=GRP_S, minval=1)
i_bosConf  = input.int(1,  "BOS Confirmation Closes",group=GRP_S, minval=1, maxval=5)
i_showBOS  = input.bool(true, "Show BOS Labels",     group=GRP_S)
i_showCH   = input.bool(true, "Show CHoCH Labels",   group=GRP_S)
i_showHHLL = input.bool(true, "Show HH/HL/LH/LL",   group=GRP_S)

i_showOB   = input.bool(true, "Show Order Blocks",   group=GRP_OB)
i_obScan   = input.int(10,   "OB Lookback Candles",  group=GRP_OB, minval=3, maxval=30)
i_maxOB    = input.int(6,    "Max Active OBs",       group=GRP_OB, minval=1, maxval=20)

i_showFVG  = input.bool(true, "Show Fair Value Gaps",group=GRP_FG)
i_maxFVG   = input.int(5,    "Max Active FVGs",      group=GRP_FG, minval=1, maxval=20)

i_showPD   = input.bool(true, "Show PD Zones",       group=GRP_PD)
i_showEQ   = input.bool(true, "Show EQH / EQL",      group=GRP_PD)
i_showSweep= input.bool(true, "Show Liquidity Sweeps",group=GRP_PD)

i_showPDH  = input.bool(true, "Show Prev Day H/L",   group=GRP_PL)
i_showPWH  = input.bool(true, "Show Prev Week H/L",  group=GRP_PL)

i_theme    = input.string("Auto","Theme",["Dark","Light","Auto"], group=GRP_V)
i_showFund = input.bool(true, "Show Funding Candles", group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark  = i_theme == "Auto" ? color.r(chart.bg_color) < 128 : i_theme == "Dark"
C_BULL   = color.rgb(0, 245, 212)
C_BEAR   = color.rgb(255, 68, 102)
C_GOLD   = color.rgb(255, 215, 0)
C_PURP   = color.rgb(155, 89, 182)
C_TEAL   = color.rgb(0, 220, 190)
C_SLATE  = color.rgb(96, 112, 128)
C_LBLBG  = _isDark ? color.new(color.black, 65) : color.new(color.white, 65)
C_TXT    = _isDark ? color.white : color.black
C_PANEL  = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)

// ─── UDTs ────────────────────────────────────────────────────────────
type OBZone
    float top      = na
    float bot      = na
    int   leftBar  = na
    bool  isBull   = true
    bool  valid    = true
    box   b1       = na
    box   b2       = na
    label lbl      = na

type FVGZone
    float top      = na
    float bot      = na
    int   leftBar  = na
    bool  isBull   = true
    bool  filled   = false
    box   bx       = na

// ─── HELPERS / FINDERS ───────────────────────────────────────────────
safeDiv(float n, float d) =>
    d != 0.0 and not na(d) ? n / d : 0.0

f_findOB(bool isBull, int scanLen) =>
    obHigh = float(na)
    obLow  = float(na)
    obBar  = int(na)
    for k = 1 to scanLen
        isBearCandle = close[k] < open[k]
        isBullCandle = close[k] > open[k]
        if (isBull and isBearCandle) or (not isBull and isBullCandle)
            obHigh := high[k]
            obLow  := math.min(open[k], close[k])
            if not isBull
                obLow  := math.max(open[k], close[k])
                obHigh := high[k]
            obBar  := bar_index - k
            break
    [obHigh, obLow, obBar]

// ─── OB METHODS ──────────────────────────────────────────────────────
method drawOB(OBZone self) =>
    c   = self.isBull ? C_BULL : C_BEAR
    ext = bar_index + 40
    self.b1  := box.new(self.leftBar, self.top, ext, self.bot,
                bgcolor=color.new(c, 88), border_color=color.new(c, 60), border_width=1)
    self.b2  := box.new(self.leftBar, self.top, ext,
                self.bot + (self.top - self.bot) * 0.35,
                bgcolor=color.new(c, 78), border_color=na)
    txt  = self.isBull ? "OB+" : "OB-"
    self.lbl := label.new(self.leftBar, self.isBull ? self.bot : self.top, txt,
                color=color.new(c, 55), textcolor=color.white,
                style=self.isBull ? label.style_label_up : label.style_label_down,
                size=size.tiny)

method extendOB(OBZone self) =>
    if not na(self.b1) and self.valid
        box.set_right(self.b1, bar_index + 1)
        box.set_right(self.b2, bar_index + 1)

method invalidateOB(OBZone self) =>
    if not na(self.b1)
        self.valid := false
        box.set_bgcolor(self.b1, color.new(C_SLATE, 94))
        box.set_bgcolor(self.b2, color.new(C_SLATE, 92))
        box.set_border_color(self.b1, color.new(C_SLATE, 80))

// ─── FVG METHODS ─────────────────────────────────────────────────────
method drawFVG(FVGZone self) =>
    c = self.isBull ? color.rgb(0, 200, 160) : color.rgb(220, 60, 90)
    self.bx := box.new(self.leftBar, self.top, bar_index + 30, self.bot,
               bgcolor=color.new(c, 85), border_color=color.new(c, 65),
               border_style=line.style_dotted, border_width=1)

method extendFVG(FVGZone self) =>
    if not na(self.bx) and not self.filled
        box.set_right(self.bx, bar_index + 1)

method fillFVG(FVGZone self) =>
    if not na(self.bx)
        self.filled := true
        box.set_bgcolor(self.bx, color.new(C_SLATE, 95))

// ─── CALCULATIONS ────────────────────────────────────────────────────
atr14  = ta.atr(14)
volSma = ta.sma(volume, 20)

// Pivots
ph  = ta.pivothigh(high, i_pvLeft, i_pvRight)
pl  = ta.pivotlow (low,  i_pvLeft, i_pvRight)
iph = ta.pivothigh(high, i_iPvL,   i_iPvR)
ipl = ta.pivotlow (low,  i_iPvL,   i_iPvR)

WARMUP  = math.max((i_pvLeft + i_pvRight) * 3, 50)
isReady = bar_index >= WARMUP

// Swing level tracking
var float lastSH    = na
var float lastSL    = na
var int   shBar     = na
var int   slBar     = na
var float prevSH    = na
var float prevSL    = na
var int   structDir = 0   // 1=bull, -1=bear, 0=neutral
var bool  bosUpDone = false
var bool  bosDnDone = false

// Confirmation counter for BOS
var int bosUpCount  = 0
var int bosDnCount  = 0

if not na(ph)
    prevSH      := lastSH
    lastSH      := ph
    shBar       := bar_index - i_pvRight
    bosUpDone   := false
    bosUpCount  := 0

if not na(pl)
    prevSL      := lastSL
    lastSL      := pl
    slBar       := bar_index - i_pvRight
    bosDnDone   := false
    bosDnCount  := 0

// BOS confirmation counter logic
if not bosUpDone and not na(lastSH) and close > lastSH
    bosUpCount += 1
else if close <= lastSH
    bosUpCount := 0

if not bosDnDone and not na(lastSL) and close < lastSL
    bosDnCount += 1
else if close >= lastSL
    bosDnCount := 0

bool bosUp   = bosUpCount >= i_bosConf and not bosUpDone and isReady and barstate.isconfirmed
bool bosDn   = bosDnCount >= i_bosConf and not bosDnDone and isReady and barstate.isconfirmed
bool chochUp = bosUp and structDir == -1
bool chochDn = bosDn and structDir ==  1

if bosUp
    bosUpDone  := true
    structDir  := 1
if bosDn
    bosDnDone  := true
    structDir  := -1

// EQH / EQL
var float prevPH = na
var float prevPL = na
eqhTriggered = false
eqlTriggered = false
eqhLevel     = float(na)
eqlLevel     = float(na)

if not na(ph)
    if not na(prevPH) and safeDiv(math.abs(ph - prevPH), prevPH) < 0.0015
        eqhTriggered := true
        eqhLevel     := (ph + prevPH) * 0.5
    prevPH := ph

if not na(pl)
    if not na(prevPL) and safeDiv(math.abs(pl - prevPL), prevPL) < 0.0015
        eqlTriggered := true
        eqlLevel     := (pl + prevPL) * 0.5
    prevPL := pl

// Liquidity sweep detection
sweepHigh = not na(lastSH) and high > lastSH and close < lastSH and barstate.isconfirmed and isReady
sweepLow  = not na(lastSL) and low  < lastSL and close > lastSL and barstate.isconfirmed and isReady

// FVG detection
bullFVG = low > high[2] and barstate.isconfirmed and isReady
bearFVG = high < low[2] and barstate.isconfirmed and isReady

// Institutional funding candle
isFunding = ta.tr(true) > atr14 * 1.5 and volume > volSma * 2.0

// ─── OBJECT ARRAYS ───────────────────────────────────────────────────
var array<OBZone>  obs  = array.new<OBZone>()
var array<FVGZone> fvgs = array.new<FVGZone>()

// Process OBs — extend or invalidate each bar
if array.size(obs) > 0
    for i = 0 to array.size(obs) - 1
        ob = array.get(obs, i)
        if ob.valid
            ob.extendOB()
            if (ob.isBull and close < ob.bot) or (not ob.isBull and close > ob.top)
                ob.invalidateOB()

// Create OB on BOS
if bosUp and i_showOB
    [obH, obL, obBr] = f_findOB(true, i_obScan)
    if not na(obBr)
        ob = OBZone.new(top=obH, bot=obL, leftBar=obBr, isBull=true)
        ob.drawOB()
        array.unshift(obs, ob)
        if array.size(obs) > i_maxOB
            old = array.pop(obs)
            if not na(old.b1)
                box.delete(old.b1)
                box.delete(old.b2)
                label.delete(old.lbl)

if bosDn and i_showOB
    [obH, obL, obBr] = f_findOB(false, i_obScan)
    if not na(obBr)
        ob = OBZone.new(top=obH, bot=obL, leftBar=obBr, isBull=false)
        ob.drawOB()
        array.unshift(obs, ob)
        if array.size(obs) > i_maxOB
            old = array.pop(obs)
            if not na(old.b1)
                box.delete(old.b1)
                box.delete(old.b2)
                label.delete(old.lbl)

// Process FVGs — extend or fill
if array.size(fvgs) > 0
    for i = 0 to array.size(fvgs) - 1
        fg = array.get(fvgs, i)
        if not fg.filled
            fg.extendFVG()
            if fg.isBull and low <= fg.bot
                fg.fillFVG()
            else if not fg.isBull and high >= fg.top
                fg.fillFVG()

// Create FVG
if bullFVG and i_showFVG
    fg = FVGZone.new(top=low, bot=high[2], leftBar=bar_index - 2, isBull=true)
    fg.drawFVG()
    array.unshift(fvgs, fg)
    if array.size(fvgs) > i_maxFVG
        old = array.pop(fvgs)
        if not na(old.bx)
            box.delete(old.bx)

if bearFVG and i_showFVG
    fg = FVGZone.new(top=low[2], bot=high, leftBar=bar_index - 2, isBull=false)
    fg.drawFVG()
    array.unshift(fvgs, fg)
    if array.size(fvgs) > i_maxFVG
        old = array.pop(fvgs)
        if not na(old.bx)
            box.delete(old.bx)

// ─── STRUCTURE LABELS ────────────────────────────────────────────────
if i_showBOS and bosUp and not chochUp
    line.new(shBar, lastSH, bar_index, lastSH,
         color=color.new(C_BULL, 30), width=1, style=line.style_solid)
    label.new(bar_index, lastSH, "BOS",
         color=color.new(C_BULL, 55), textcolor=color.white,
         style=label.style_label_down, size=size.tiny)

if i_showBOS and bosDn and not chochDn
    line.new(slBar, lastSL, bar_index, lastSL,
         color=color.new(C_BEAR, 30), width=1, style=line.style_solid)
    label.new(bar_index, lastSL, "BOS",
         color=color.new(C_BEAR, 55), textcolor=color.white,
         style=label.style_label_up, size=size.tiny)

if i_showCH and chochUp
    line.new(shBar, lastSH, bar_index, lastSH,
         color=color.new(C_GOLD, 20), width=2, style=line.style_dashed)
    label.new(bar_index, lastSH, "CHoCH",
         color=color.new(C_GOLD, 45), textcolor=color.black,
         style=label.style_label_down, size=size.tiny)

if i_showCH and chochDn
    line.new(slBar, lastSL, bar_index, lastSL,
         color=color.new(C_GOLD, 20), width=2, style=line.style_dashed)
    label.new(bar_index, lastSL, "CHoCH",
         color=color.new(C_GOLD, 45), textcolor=color.black,
         style=label.style_label_up, size=size.tiny)

// HH / HL / LH / LL labels on pivots
if i_showHHLL and not na(ph) and not na(prevSH)
    txt = ph > prevSH ? "HH" : "LH"
    clr = ph > prevSH ? C_BULL : C_BEAR
    label.new(bar_index - i_pvRight, ph, txt,
         color=color.new(clr, 60), textcolor=color.white,
         style=label.style_label_down, size=size.tiny, xloc=xloc.bar_index)

if i_showHHLL and not na(pl) and not na(prevSL)
    txt = pl > prevSL ? "HL" : "LL"
    clr = pl > prevSL ? C_BULL : C_BEAR
    label.new(bar_index - i_pvRight, pl, txt,
         color=color.new(clr, 60), textcolor=color.white,
         style=label.style_label_up, size=size.tiny, xloc=xloc.bar_index)

// EQH / EQL labels
if i_showEQ and eqhTriggered
    label.new(bar_index - i_pvRight, eqhLevel, "EQH",
         color=color.new(C_PURP, 50), textcolor=color.white,
         style=label.style_label_down, size=size.tiny, xloc=xloc.bar_index)

if i_showEQ and eqlTriggered
    label.new(bar_index - i_pvRight, eqlLevel, "EQL",
         color=color.new(C_PURP, 50), textcolor=color.white,
         style=label.style_label_up, size=size.tiny, xloc=xloc.bar_index)

// Liquidity sweep labels
if i_showSweep and sweepHigh
    label.new(bar_index, high, "SWEEP",
         color=color.new(C_GOLD, 45), textcolor=color.black,
         style=label.style_label_down, size=size.tiny)

if i_showSweep and sweepLow
    label.new(bar_index, low, "SWEEP",
         color=color.new(C_GOLD, 45), textcolor=color.black,
         style=label.style_label_up, size=size.tiny)

// Funding candles
fundingClr = i_showFund and isFunding ?
     (structDir == 1 ? color.new(C_BULL, 50) : structDir == -1 ? color.new(C_BEAR, 50) : color.new(C_GOLD, 50)) : na
barcolor(fundingClr, title="Funding Candle")

// ─── PREMIUM / DISCOUNT ZONES (based on last BOS range) ───────────────
var float pdHigh   = na
var float pdLow    = na
var box   premBox  = na
var box   discBox  = na
var box   eqBox    = na

if (bosUp or bosDn) and i_showPD and not na(lastSH) and not na(lastSL)
    pdHigh := math.max(lastSH, lastSL)
    pdLow  := math.min(lastSH, lastSL)
    rng    = pdHigh - pdLow
    if not na(premBox)
        box.delete(premBox)
        box.delete(discBox)
        box.delete(eqBox)
    ext    = bar_index + 60
    premBox := box.new(bar_index, pdHigh, ext, pdLow + rng * 0.618,
               bgcolor=color.new(C_BEAR, 92), border_color=na)
    discBox := box.new(bar_index, pdLow + rng * 0.382, ext, pdLow,
               bgcolor=color.new(C_BULL, 92), border_color=na)
    eqBox   := box.new(bar_index, pdLow + rng * 0.618, ext, pdLow + rng * 0.382,
               bgcolor=color.new(C_GOLD, 95), border_color=na)

// ─── PERIODIC LEVELS (PDH / PDL / PWH / PWL) ─────────────────────────
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]],
              lookahead=barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]],
              lookahead=barmerge.lookahead_off)

plot(i_showPDH ? pdh : na, "Prev Day High",  color=color.new(C_BEAR, 40), linewidth=1, style=plot.style_stepline)
plot(i_showPDH ? pdl : na, "Prev Day Low",   color=color.new(C_BULL, 40), linewidth=1, style=plot.style_stepline)
plot(i_showPWH ? pwh : na, "Prev Week High", color=color.new(C_BEAR, 20), linewidth=2, style=plot.style_stepline)
plot(i_showPWH ? pwl : na, "Prev Week Low",  color=color.new(C_BULL, 20), linewidth=2, style=plot.style_stepline)

// ─── ALERTS ──────────────────────────────────────────────────────────
alertcondition(bosUp,    "PSE Bull BOS [JOAT]",     "Phantom Structure: Bullish BOS confirmed")
alertcondition(bosDn,    "PSE Bear BOS [JOAT]",     "Phantom Structure: Bearish BOS confirmed")
alertcondition(chochUp,  "PSE Bull CHoCH [JOAT]",   "Phantom Structure: Bullish CHoCH — structure flip")
alertcondition(chochDn,  "PSE Bear CHoCH [JOAT]",   "Phantom Structure: Bearish CHoCH — structure flip")
alertcondition(sweepHigh,"PSE Liquidity Sweep H [JOAT]","Phantom Structure: High-side liquidity sweep")
alertcondition(sweepLow, "PSE Liquidity Sweep L [JOAT]","Phantom Structure: Low-side liquidity sweep")

// ─── DASHBOARD ───────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 8,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    dirStr  = structDir ==  1 ? "BULLISH" : structDir == -1 ? "BEARISH" : "NEUTRAL"
    dirClr  = structDir ==  1 ? C_BULL    : structDir == -1 ? C_BEAR    : C_SLATE
    obsAct  = 0
    if array.size(obs) > 0
        for i = 0 to array.size(obs) - 1
            if array.get(obs, i).valid
                obsAct += 1
    fvgsAct = 0
    if array.size(fvgs) > 0
        for i = 0 to array.size(fvgs) - 1
            if not array.get(fvgs, i).filled
                fvgsAct += 1
    table.cell(dash, 0, 0, "PSE [JOAT]", bgcolor=color.new(C_PURP, 40),
         text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "JackOfAllTrades", bgcolor=color.new(C_PURP, 40),
         text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 1, "Structure",   text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 1, dirStr,        text_color=dirClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 2, "Active OBs",  text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 2, str.tostring(obsAct), text_color=C_GOLD, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 3, "Open FVGs",   text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 3, str.tostring(fvgsAct), text_color=C_TEAL, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 4, "Last SH",     text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 4, na(lastSH) ? "N/A" : str.tostring(math.round(lastSH, 4)),
         text_color=C_BEAR, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 5, "Last SL",     text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 5, na(lastSL) ? "N/A" : str.tostring(math.round(lastSL, 4)),
         text_color=C_BULL, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 6, "Sweep H",     text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 6, sweepHigh ? "ACTIVE" : "NO",
         text_color=sweepHigh ? C_GOLD : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 7, "Sweep L",     text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 7, sweepLow ? "ACTIVE" : "NO",
         text_color=sweepLow ? C_GOLD : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
````
