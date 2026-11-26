# Compression Vector [JOAT]

- url: https://www.tradingview.com/script/xCwgVeXo-Compression-Vector-JOAT/
- type: indicator
- pine_id: PUB;eaa3b4ac3bf74762927a5dd432cb04b4
- version: 1.0

## Description

[b]Compression Vector [JOAT][/b]

[b]Overview[/b]

Compression Vector is a dual-engine volatility compression detector built in Pine Script v6. It identifies moments when both Bollinger Band width and Average True Range simultaneously contract relative to their historical baselines — a confluence that institutional traders recognise as the calm before an explosive directional move. When the squeeze releases, the indicator fires scored breakout signals with adaptive ATR-based take-profit levels and stop-loss placement directly on the chart.

[image]https://www.tradingview.com/x/uOAWLT1I/[/image]

[b]Why This Approach?[/b]

Most squeeze indicators rely on a single compression measure, such as BB width relative to Keltner Channel, which can produce false signals in low-volume sideways drift. Compression Vector cross-validates two independent compression engines:

- [b]Engine 1 — ATR Historical Ratio:[/b] Compares the 14-bar ATR against a slow ATR of configurable length (default 50). If the ratio falls below the compression threshold, the first engine fires.
- [b]Engine 2 — BB + ATR SMA Squeeze:[/b] Compares current BB width against its own SMA (so the band must narrow relative to its own recent average), AND compares the current ATR against its short-term SMA. Only when at least one of these secondary tests also confirms does a dual-engine squeeze register.

Both engines must agree before a zone is created. This eliminates the noise inherent in single-measure detectors.

[b]Compression Zones — 3-Layer Institutional Box System[/b]

Each confirmed squeeze prints a three-layer box structure that visually encodes squeeze intensity through colour:

- [b]Halo layer (outer):[/b] Wide, nearly transparent — marks the full expansion of the compressed range plus padding
- [b]Body layer (mid):[/b] The actual high-to-low range of all bars inside the squeeze
- [b]Core layer (inner):[/b] A tighter 40% interior slice highlighting the median energy pocket

The box colour progresses through a time-weighted palette: grey (< 5 bars), purple (5–9), teal (10–19), gold (20+). Longer squeezes accumulate more potential energy and are weighted accordingly in the signal score.

[b]Breakout Signal Scoring (0–100)[/b]

When close breaks convincingly above or below a zone, the indicator computes a composite score before stamping the signal:

- Proximity score (up to 35) — volume vs. its 20-bar SMA
- Squeeze score (up to 35) — duration of the squeeze in bars × 2.5
- RSI score (up to 15) — directional RSI headroom (long: RSI below 62, short: RSI above 38)
- Impulse score (up to 15) — breakout candle body relative to ATR

Grade letter (A+, A, B, C, D) is stamped on the signal label. Only breakouts where the candle body exceeds a configurable ATR multiple ("Min Impulse Body") qualify.

[b]Adaptive TP / SL Lines[/b]

Risk is calculated as the distance from entry to the opposite zone boundary plus an ATR buffer. Three take-profit levels at configurable R:R multiples (default 1.5R, 2.5R, 4.0R) are drawn as dotted lines extending forward 45 bars. The stop-loss line is drawn in the opposing colour at the calculated risk distance below/above entry.

[b]Dashboard (Bottom Centre)[/b]

A compact 8-column table displays in real time:
- Squeeze state (COMPRESSING / RELAXED) with bar count
- ASCII compression gauge (6 segments)
- ATR ratio and BB width percentage
- RSI, volume multiplier, last zone score with grade
- Active zone count and warm-up status

[b]Inputs Reference[/b]

[b]Squeeze Engine[/b]
- ATR Historical Length (50) — lookback for the slow ATR baseline
- ATR Compression Threshold (0.72) — ratio below which ATR engine triggers
- Bollinger Band Length (20) — period for BB and BB-width SMA
- BB Std Dev Multiplier (2.0) — standard deviation width of the Bollinger Bands
- BB Width Squeeze Ratio (0.82) — fraction of BB-width SMA below which BB engine triggers
- ATR SMA Squeeze Ratio (0.90) — fraction of ATR SMA below which ATR secondary engine triggers
- Min Bars Required in Squeeze (3) — minimum consecutive bars before a zone is registered

[b]Signal Filters[/b]
- Require Volume Above SMA — gates breakouts to above-average volume bars
- Volume SMA Length (20) — reference volume baseline
- Block Overbought/Oversold — RSI filter at 72 long / 28 short
- RSI Length (14)
- Min Impulse Body (1.3 ATR) — minimum breakout candle body in ATR units
- Max Zones Tracked (6)

[b]Risk & Targets[/b]
- SL Buffer (0.3 ATR) — added to raw risk for stop placement
- TP1 / TP2 / TP3 R:R — take-profit multiples (1.5 / 2.5 / 4.0)

[b]Visual Settings[/b]
- Show Compression Zones / Show TP-SL Lines / Show Dashboard
- Theme: Dark, Light, or Auto (detects chart background)

[b]How to Use[/b]

1. Add the indicator on any liquid market and timeframe. A warmup of roughly 100 bars is required before signals appear.
2. Watch for the dashboard state to read COMPRESSING and the gauge to fill. The longer the squeeze, the higher the potential score on breakout.
3. Wait for a labelled signal (BREAK+ for long, BREAK- for short). Prefer grade A or A+.
4. Use the drawn TP lines for partial exits and the SL line for stop placement.
5. Higher timeframes (15m, 1H, 4H) tend to produce cleaner zones with fewer false breaks.

[b]Non-Repainting Design[/b]

All signals are gated by barstate.isconfirmed, meaning they only fire on the final tick of a closed bar. Zones are computed from confirmed historical bars only. The indicator will never repaint a past signal.

[b]Limitations[/b]

- In extremely choppy, low-volume markets, short squeezes (2–3 bars) may resolve without meaningful breakout momentum. Raise Min Bars to filter these.
- The composite score is calibrated for liquid instruments. Illiquid or exotic pairs may require adjustment of the volume multiplier filter.
- ATR-based TP/SL levels are approximate and should not replace proper position sizing.
- No future-bar lookahead is used in any request.security() call.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. Past performance of any signal pattern is not indicative of future results. Always use proper risk management and conduct your own analysis before making any trading decisions.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Compression Vector [JOAT]", shorttitle="CV [JOAT]", overlay=true,
          max_boxes_count=300, max_lines_count=300, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════
//  COMPRESSION VECTOR [JOAT]  |  JackOfAllTrades
//  Dual-engine volatility compression detector. Identifies co-compression
//  of Bollinger Bands and ATR relative to historical norms, marks the
//  resulting squeeze zones with 3-layer institutional boxes, then fires
//  scored breakout signals with adaptive TP/SL levels on confirmed bars.
// ═══════════════════════════════════════════════════════════════════

// ─── INPUT GROUPS ────────────────────────────────────────────────────
var GRP_E = "Squeeze Engine"
var GRP_F = "Signal Filters"
var GRP_T = "Risk & Targets"
var GRP_V = "Visual Settings"

i_compLen    = input.int   (50,   "ATR Historical Length",    group=GRP_E, minval=20, maxval=300)
i_compRatio  = input.float (0.72, "ATR Compression Threshold",group=GRP_E, minval=0.3, maxval=0.99, step=0.01)
i_bbLen      = input.int   (20,   "Bollinger Band Length",    group=GRP_E, minval=5)
i_bbMult     = input.float (2.0,  "BB Std Dev Multiplier",    group=GRP_E, minval=1.0, step=0.25)
i_sqzThresh  = input.float (0.82, "BB Width Squeeze Ratio",   group=GRP_E, minval=0.4, maxval=1.0, step=0.01)
i_atrSqz     = input.float (0.90, "ATR SMA Squeeze Ratio",    group=GRP_E, minval=0.4, maxval=1.0, step=0.01)
i_minSqzBars = input.int   (3,    "Min Bars Required in Squeeze", group=GRP_E, minval=1)

i_volFilt    = input.bool  (true,  "Require Volume Above SMA", group=GRP_F)
i_volLen     = input.int   (20,    "Volume SMA Length",        group=GRP_F, minval=5)
i_rsiFilt    = input.bool  (true,  "Block Overbought/Oversold",group=GRP_F)
i_rsiLen     = input.int   (14,    "RSI Length",               group=GRP_F, minval=2)
i_impulseM   = input.float (1.3,   "Min Impulse Body (ATR x)", group=GRP_F, minval=0.5, step=0.1)
i_maxZones   = input.int   (6,     "Max Zones Tracked",        group=GRP_F, minval=1, maxval=25)

i_slBuf      = input.float (0.3,   "SL Buffer (ATR x)",        group=GRP_T, minval=0.0, step=0.1)
i_tp1R       = input.float (1.5,   "TP1  R:R",                 group=GRP_T, minval=0.5, step=0.25)
i_tp2R       = input.float (2.5,   "TP2  R:R",                 group=GRP_T, minval=0.5, step=0.25)
i_tp3R       = input.float (4.0,   "TP3  R:R",                 group=GRP_T, minval=0.5, step=0.25)

i_showZones  = input.bool  (true,  "Show Compression Zones",   group=GRP_V)
i_showLevels = input.bool  (true,  "Show TP / SL Lines",       group=GRP_V)
i_showDash   = input.bool  (true,  "Show Dashboard",           group=GRP_V)
i_theme      = input.string("Auto","Theme", ["Dark","Light","Auto"], group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark  = i_theme == "Auto" ? color.r(chart.bg_color) < 128 : i_theme == "Dark"
C_BULL   = color.rgb(0, 245, 212)
C_BEAR   = color.rgb(255, 68, 102)
C_GOLD   = color.rgb(255, 215, 0)
C_PURP   = color.rgb(155, 89, 182)
C_TEAL   = color.rgb(0, 220, 190)
C_SLATE  = color.rgb(96, 112, 128)
C_PANEL  = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT    = _isDark ? color.white : color.black

// ─── UDT ─────────────────────────────────────────────────────────────
type CompZone
    float zHigh        = na
    float zLow         = na
    float entry        = na
    float sl           = na
    float tp1          = na
    float tp2          = na
    float tp3          = na
    int   startBar     = na
    int   sqzBars      = 0
    int   score        = 0
    bool  isBull       = true
    bool  fired        = false
    bool  done         = false
    int   activatedBar = na
    box   halo         = na
    box   body         = na
    box   core         = na
    line  midLine      = na
    line  tp1Line      = na
    line  tp2Line      = na
    line  tp3Line      = na
    line  slLine       = na
    label sigLabel     = na

// ─── HELPERS ─────────────────────────────────────────────────────────
f_gauge(float pct, int segs) =>
    filled = math.round(math.max(math.min(pct, 100.0), 0.0) / 100.0 * segs)
    str.repeat("█", filled) + str.repeat("░", segs - filled)

safeDiv(float n, float d) =>
    d != 0.0 and not na(d) ? n / d : 0.0

f_sqzColor(int bars) =>
    bars < 5  ? C_SLATE :
     bars < 10 ? C_PURP  :
     bars < 20 ? C_TEAL  : C_GOLD

f_grade(int s) =>
    s >= 80 ? "A+" : s >= 65 ? "A" : s >= 50 ? "B" : s >= 35 ? "C" : "D"

// ─── METHODS ─────────────────────────────────────────────────────────
method draw(CompZone self) =>
    c   = f_sqzColor(self.sqzBars)
    r   = self.startBar + math.max(self.sqzBars + 2, 5)
    pad = (self.zHigh - self.zLow) * 0.06
    self.halo    := box.new(self.startBar, self.zHigh + pad, r, self.zLow - pad,
                    bgcolor=color.new(c, 93), border_color=na)
    self.body    := box.new(self.startBar, self.zHigh, r, self.zLow,
                    bgcolor=color.new(c, 87), border_color=na)
    self.core    := box.new(self.startBar, self.zHigh - pad * 0.4, r, self.zLow + pad * 0.4,
                    bgcolor=color.new(c, 80), border_color=color.new(c, 52), border_width=1)
    mid = (self.zHigh + self.zLow) * 0.5
    self.midLine := line.new(self.startBar, mid, r, mid,
                    color=color.new(c, 45), style=line.style_dashed, width=1)

method extend(CompZone self) =>
    if not na(self.halo) and not self.fired
        r = bar_index + 1
        box.set_right(self.halo,   r)
        box.set_right(self.body,   r)
        box.set_right(self.core,   r)
        line.set_x2(self.midLine,  r)

method stamp(CompZone self) =>
    ext = bar_index + 45
    lc  = self.isBull ? C_BULL : C_BEAR
    if i_showLevels
        self.tp1Line := line.new(bar_index, self.tp1, ext, self.tp1,
                        color=color.new(lc, 55), width=1, style=line.style_dotted)
        self.tp2Line := line.new(bar_index, self.tp2, ext, self.tp2,
                        color=color.new(lc, 30), width=1, style=line.style_dotted)
        self.tp3Line := line.new(bar_index, self.tp3, ext, self.tp3,
                        color=color.new(lc, 10), width=2, style=line.style_dotted)
        self.slLine  := line.new(bar_index, self.sl, ext, self.sl,
                        color=color.new(C_BEAR, 30), width=1, style=line.style_dashed)
    grade  = f_grade(self.score)
    txt    = (self.isBull ? "BREAK+" : "BREAK-") + " " + grade + "\n" + str.tostring(self.score)
    ypos   = self.isBull ? self.zLow * 0.9998 : self.zHigh * 1.0002
    self.sigLabel := label.new(bar_index, ypos, txt,
                     color=color.new(lc, 65), textcolor=color.white,
                     style=self.isBull ? label.style_label_up : label.style_label_down,
                     size=size.small)

method fade(CompZone self) =>
    if not na(self.halo)
        box.set_bgcolor(self.halo, color.new(C_SLATE, 96))
        box.set_bgcolor(self.body, color.new(C_SLATE, 93))
        box.set_bgcolor(self.core, color.new(C_SLATE, 91))
        line.set_color(self.midLine, color.new(C_SLATE, 82))

// ─── CORE CALCULATIONS ───────────────────────────────────────────────
atr14       = ta.atr(14)
atrSlow     = ta.atr(i_compLen)
rsiVal      = ta.rsi(close, i_rsiLen)
volSma      = ta.sma(volume, i_volLen)
[bbU, bbB, bbL] = ta.bb(close, i_bbLen, i_bbMult)
bbWidth     = safeDiv(bbU - bbL, math.max(bbB, syminfo.mintick))
bbWidthSma  = ta.sma(bbWidth, i_bbLen)
atrSma      = ta.sma(atr14, i_bbLen)

atrComp     = safeDiv(atr14, math.max(atrSlow, syminfo.mintick)) < i_compRatio
bbSqz       = bbWidth < bbWidthSma * i_sqzThresh
atrSqzFlag  = atr14 < atrSma * i_atrSqz
isSqueeze   = atrComp and (bbSqz or atrSqzFlag)

WARMUP      = math.max(i_compLen * 2, 100)
isReady     = bar_index >= WARMUP

// ─── SQUEEZE STATE MACHINE ───────────────────────────────────────────
var bool  wasSqueezing = false
var float sqzH         = na
var float sqzL         = na
var int   sqzN         = 0
var int   sqzSBar      = na
var array<CompZone> zones = array.new<CompZone>()

if isSqueeze and isReady
    if not wasSqueezing
        sqzH    := high
        sqzL    := low
        sqzN    := 1
        sqzSBar := bar_index
    else
        sqzH    := math.max(sqzH, high)
        sqzL    := math.min(sqzL, low)
        sqzN    += 1
    wasSqueezing := true
else
    if wasSqueezing and barstate.isconfirmed and sqzN >= i_minSqzBars
        zone = CompZone.new(zHigh=sqzH, zLow=sqzL, startBar=sqzSBar, sqzBars=sqzN)
        if i_showZones
            zone.draw()
        array.unshift(zones, zone)
        if array.size(zones) > i_maxZones
            old = array.pop(zones)
            old.fade()
    wasSqueezing := false
    sqzN         := 0

// ─── BREAKOUT SIGNAL PROCESSING ──────────────────────────────────────
bodySize   = math.abs(close - open)
isImpulse  = bodySize > atr14 * i_impulseM
volOk      = not i_volFilt  or volume > volSma * 1.05
rsiLongOk  = not i_rsiFilt  or rsiVal < 72.0
rsiShortOk = not i_rsiFilt  or rsiVal > 28.0

bool bullFired = false
bool bearFired = false

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if not z.fired and not z.done
            z.extend()
            isBull = close > z.zHigh and isImpulse and volOk and rsiLongOk  and barstate.isconfirmed
            isBear = close < z.zLow  and isImpulse and volOk and rsiShortOk and barstate.isconfirmed
            if (isBull or isBear) and bar_index > z.startBar
                z.isBull  := isBull
                z.entry   := close
                risk       = isBull ? close - z.zLow + atr14 * i_slBuf : z.zHigh - close + atr14 * i_slBuf
                risk      := math.max(risk, atr14 * 0.5)
                z.sl      := isBull ? close - risk       : close + risk
                z.tp1     := isBull ? close + risk*i_tp1R : close - risk*i_tp1R
                z.tp2     := isBull ? close + risk*i_tp2R : close - risk*i_tp2R
                z.tp3     := isBull ? close + risk*i_tp3R : close - risk*i_tp3R
                volScore   = math.min(safeDiv(volume, volSma) * 20.0, 35.0)
                sqzScore   = math.min(z.sqzBars * 2.5, 35.0)
                rsiScore   = isBull ? math.max((62.0 - rsiVal) * 0.4, 0.0) : math.max((rsiVal - 38.0) * 0.4, 0.0)
                impScore   = math.min(safeDiv(bodySize, atr14) * 8.0, 15.0)
                z.score          := int(math.min(volScore + sqzScore + rsiScore + impScore, 100.0))
                z.fired          := true
                z.activatedBar   := bar_index
                z.stamp()
                if isBull
                    bullFired := true
                else
                    bearFired := true
            else if bar_index - z.startBar > 300
                z.done := true
                z.fade()

// ─── BACKGROUND SQUEEZE GLOW ─────────────────────────────────────────
sqzIntensity = math.min(safeDiv(float(sqzN), 30.0), 1.0)
sqzBg = isSqueeze and isReady ?
     color.from_gradient(sqzIntensity, 0.0, 1.0,
         color.new(C_SLATE, 98), color.new(C_GOLD, 91)) : na
bgcolor(sqzBg, title="Squeeze Glow")

// ─── ALERTS ──────────────────────────────────────────────────────────
alertcondition(bullFired, "CV Bull Breakout [JOAT]",
     "Compression Vector: Confirmed bullish breakout from squeeze zone")
alertcondition(bearFired, "CV Bear Breakout [JOAT]",
     "Compression Vector: Confirmed bearish breakout from squeeze zone")

// ─── DASHBOARD ───────────────────────────────────────────────────────
var table dash = table.new(position.bottom_center, 8, 4,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 55))

if i_showDash and barstate.islast
    atrRatio   = safeDiv(atr14, math.max(atrSlow, syminfo.mintick))
    sqzStr     = isSqueeze ? "COMPRESSING" : "RELAXED"
    sqzClr     = isSqueeze ? f_sqzColor(sqzN) : C_SLATE
    volRatio   = safeDiv(volume, math.max(volSma, 1.0))
    lastScore  = array.size(zones) > 0 ? array.get(zones, 0).score : 0
    sigStr     = bullFired ? "BULL BREAK" : bearFired ? "BEAR BREAK" : "WATCHING..."
    sigClr     = bullFired ? C_BULL : bearFired ? C_BEAR : C_SLATE

    // Row 0 — header
    table.cell(dash, 0, 0, "COMPRESSION VECTOR", bgcolor=C_TEAL,
         text_color=color.black, text_size=size.small)
    table.cell(dash, 1, 0, "[JOAT]", bgcolor=C_TEAL,
         text_color=color.black, text_size=size.small)
    table.cell(dash, 2, 0, "State",  bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 3, 0, sqzStr,  bgcolor=C_PANEL, text_color=sqzClr, text_size=size.small)
    table.cell(dash, 4, 0, "Bars",  bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 5, 0, str.tostring(sqzN), bgcolor=C_PANEL, text_color=C_GOLD, text_size=size.small)
    table.cell(dash, 6, 0, "Gauge", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 7, 0, f_gauge(sqzIntensity * 100, 6),
         bgcolor=C_PANEL, text_color=f_sqzColor(sqzN), text_size=size.small)
    // Row 1 — compression metrics
    table.cell(dash, 0, 1, "ATR Ratio", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(math.round(atrRatio, 3)),
         bgcolor=C_PANEL, text_color=atrComp ? C_GOLD : C_TXT, text_size=size.small)
    table.cell(dash, 2, 1, "BB Width", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 3, 1, str.tostring(math.round(bbWidth * 100, 2)) + "%",
         bgcolor=C_PANEL, text_color=bbSqz ? C_PURP : C_TXT, text_size=size.small)
    table.cell(dash, 4, 1, "RSI", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 5, 1, str.tostring(math.round(rsiVal, 1)),
         bgcolor=C_PANEL,
         text_color=rsiVal > 65 ? C_BEAR : rsiVal < 35 ? C_BULL : C_TXT,
         text_size=size.small)
    table.cell(dash, 6, 1, "Vol x", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 7, 1, str.tostring(math.round(volRatio, 2)) + "x",
         bgcolor=C_PANEL, text_color=volRatio > 1.1 ? C_BULL : C_TXT, text_size=size.small)
    // Row 2 — zone info
    table.cell(dash, 0, 2, "Zones", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(array.size(zones)),
         bgcolor=C_PANEL, text_color=C_TEAL, text_size=size.small)
    table.cell(dash, 2, 2, "Last Score", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 3, 2, str.tostring(lastScore) + " (" + f_grade(lastScore) + ")",
         bgcolor=C_PANEL, text_color=lastScore >= 65 ? C_GOLD : C_TXT, text_size=size.small)
    table.cell(dash, 4, 2, "BB Squeeze", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 5, 2, bbSqz ? "YES" : "NO",
         bgcolor=C_PANEL, text_color=bbSqz ? C_PURP : C_SLATE, text_size=size.small)
    table.cell(dash, 6, 2, "ATR Squeeze", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 7, 2, atrSqzFlag ? "YES" : "NO",
         bgcolor=C_PANEL, text_color=atrSqzFlag ? C_TEAL : C_SLATE, text_size=size.small)
    // Row 3 — signal line
    table.cell(dash, 0, 3, "Signal", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 1, 3, sigStr,  bgcolor=C_PANEL, text_color=sigClr, text_size=size.small)
    table.cell(dash, 2, 3, "Impulse", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 3, 3, isImpulse ? "YES" : "NO",
         bgcolor=C_PANEL, text_color=isImpulse ? C_BULL : C_SLATE, text_size=size.small)
    table.cell(dash, 4, 3, "Vol OK", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 5, 3, volOk ? "YES" : "NO",
         bgcolor=C_PANEL, text_color=volOk ? C_BULL : C_SLATE, text_size=size.small)
    table.cell(dash, 6, 3, "Warmup", bgcolor=C_PANEL, text_color=C_TXT, text_size=size.small)
    table.cell(dash, 7, 3, isReady ? "READY" : str.tostring(WARMUP - bar_index) + "b",
         bgcolor=C_PANEL, text_color=isReady ? C_BULL : C_SLATE, text_size=size.small)
````
