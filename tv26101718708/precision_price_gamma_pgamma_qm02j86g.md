# Precision Price Gamma [PGamma]

- url: https://www.tradingview.com/script/qM02j86G-Precision-Price-Gamma-PGamma/
- type: indicator
- pine_id: PUB;21b49d123a4642d3bc3f6cc0417f978e
- version: 6.0

## Description

Here's the full updated description with all the fixes — car analogy corrected, image captions added, ready to copy:

Precision Price Gamma (PGamma) is a second-derivative momentum indicator that measures the acceleration of momentum, not momentum itself.

━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY PGAMMA IS DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━

Most momentum indicators tell you how strong a move is. PGamma tells you whether that strength is increasing or fading — going one step further by measuring whether momentum is strengthening or weakening. This allows PGamma to identify changes in market pressure before many trend-following indicators respond.

━━━━━━━━━━━━━━━━━━━━━━━━━━
THE FOUR STATES
━━━━━━━━━━━━━━━━━━━━━━━━━━

Γ↑ Accelerating — Bullish momentum is positive and still strengthening.

Γ⌃ Bull Weakening — Bullish momentum remains positive, but buying pressure is beginning to fade.

Γ↓ Bear Pressure — Bearish momentum is dominant and selling pressure continues to strengthen.

Γ⌄ Bear Exhaustion — Bearish momentum remains negative, but selling pressure is beginning to weaken.

━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━

PGamma smooths the source series, then computes the slope of that smoothed series — the first derivative, or Momentum. It then smooths Momentum and computes its slope — the second derivative, or Price Gamma. The four states are determined by the sign of both values simultaneously.

Momentum determines the current direction of market pressure. Gamma determines whether that pressure is strengthening or weakening. They often disagree near turning points — and those disagreements are often the most informative signals PGamma produces.

Think of it like driving a car. Momentum is your speed. Gamma is whether you are pressing the gas or the brake. You can be moving backward while pressing the brake — still moving backward, but slowing. That is negative momentum with positive gamma. In market terms, price may still be making lower lows, but each push down is losing force. That often precedes consolidation, a bounce, or a reversal.

Two examples of this disagreement are illustrated in the first two snapshots — a red candle during a green Gamma Timeline, and a green candle during an amber Gamma Timeline. The third snapshot illustrates when Momentum and Gamma align, showing a green candle with a green Gamma Timeline during Accelerating state.

https://www.tradingview.com/x/X1eRFUw1/

https://www.tradingview.com/x/dfUkYmfL/

https://www.tradingview.com/x/L1tOUAJX/

━━━━━━━━━━━━━━━━━━━━━━━━━━
THE STATE MATRIX
━━━━━━━━━━━━━━━━━━━━━━━━━━

Momentum  |  Gamma  |  State
+         |  +      |  Accelerating
+         |  -      |  Bull Weakening
-         |  -      |  Bear Pressure
-         |  +      |  Bear Exhaustion

Momentum and Gamma often disagree near turning points. A positive Gamma reading while Momentum remains negative does not mean the market is bullish — it means bearish momentum is losing acceleration. Those disagreements are where PGamma is most useful.

━━━━━━━━━━━━━━━━━━━━━━━━━━
UNDERSTANDING THE DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━

State — Combines Momentum and Price Gamma into one of the four market conditions above. Read the State row first.

Momentum — The first derivative of price. Positive = bullish momentum dominates. Negative = bearish momentum dominates.

Gamma — The second derivative of momentum. Above Zero = momentum is accelerating. Below Zero = momentum is decelerating. Gamma often changes direction before Momentum, making it useful for identifying transitions in market pressure.

Bias — A simplified interpretation combining Momentum and Gamma into a single directional context label.

━━━━━━━━━━━━━━━━━━━━━━━━━━
GAMMA TIMELINE
━━━━━━━━━━━━━━━━━━━━━━━━━━

The Gamma Timeline displays the historical sequence of Price Gamma states as a continuous color band along the bottom of the chart. Each colored segment represents one bar, allowing traders to quickly identify transitions between acceleration, weakening, pressure, and exhaustion without obscuring price action. Green for Accelerating, amber for Bull Weakening, red for Bear Pressure, sky blue for Bear Exhaustion. Toggle on or off in Display settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━
GETTING STARTED
━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Add PGamma to any chart. It works on all instruments and timeframes.
2. In Settings → Display, choose your panel position and size.
3. In Settings → Calculation, adjust Momentum Smoothing, Momentum Length, and Gamma Length to suit your timeframe. Default values are calibrated for intraday 1m–60m charts.
4. Read the State row first. Then use Momentum and Gamma to understand why the state is what it is.
5. Use Bias as a quick at-a-glance directional context.
6. Use the Gamma Timeline to read state history across the session at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━

PGamma is not a buy or sell signal. Think of PGamma as a market condition indicator rather than a trade signal. Use it as a confirmation layer alongside your existing methodology. Typical applications:

• Confirming trend continuation when State shows Accelerating.
• Identifying weakening rallies before reversals when State shows Bull Weakening.
• Recognizing building pressure before visible breakdowns when State shows Bear Pressure.
• Spotting exhaustion during extended trends when State shows Bear Exhaustion.

When used alongside a GEX level tool, price approaching a Call Wall with Γ⌃ Bull Weakening is a different setup than price approaching the same level with Γ↑ Accelerating. PGamma makes that distinction visible.

Because PGamma analyzes smoothed momentum rather than candle color, bullish candles can appear during Bear Pressure and bearish candles can appear during Bull Weakening. This reflects underlying momentum conditions rather than individual price bars — and is often an early warning of what is developing beneath the surface.

━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKS WELL ALONGSIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━

PGamma complements indicators that identify where important price levels exist.

• Trend indicators
• Moving averages
• Volume Profile
• VWAP
• Options Gamma Exposure (GEX)
• Support and Resistance
• Market Structure

These tools identify where price may react. PGamma helps evaluate how price is behaving as it approaches those levels.

━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT THIS TOOL IS NOT
━━━━━━━━━━━━━━━━━━━━━━━━━━

PGamma measures changes in momentum. It does not predict future prices or guarantee reversals. Use it as analytical context alongside your existing trading methodology.

━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━

Calculation: Source, Momentum Smoothing, Momentum Length, Gamma Length

Display: Show Dashboard, Panel Position (6 locations), Panel Size (Small / Normal / Large), Show Gamma Timeline

## Source Code

````pine
// © MohaveTrader
// Precision Price Gamma [MohaveTrader] (PGamma)
// Version History
// v1.1 — June 2026
// • Added optional candle painting using the Gamma state colors.
//
// v1.2 — June 2026
// • Added Zero Buffer % to reduce state flicker around the zero line.
// • Added adaptive hysteresis based on recent momentum and gamma magnitude.
// • Paint Candles now defaults to ON.
//
// v1.3 — July 2026
// • Gamma Timeline can now float above the chart bottom, anchored below
//   the session's opening range instead of glued to the pane floor.
// • Added Ribbon Style toggle (Floating vs. Classic bottom-anchored).
// • Added Sessions to Show to limit the ribbon to the N most recent
//   sessions instead of drawing across full history.
//
// v1.4 — October 2026
// • Momentum Smoothing now defaults to 2 (was 9). Bull Weakening shows a
//   bar or two sooner when a run tops out. Expect more color changes in
//   sideways tape. Existing charts keep their saved setting.
// • Every input tooltip now lists its default value.
// • Gamma Timeline now uses the lifted Classic ribbon only: it sits just
//   above the chart bottom, leaving room for labels underneath, and runs
//   across full history by default. Floating style, Ribbon Style and
//   Timeline Offset removed. Sessions to Show now limits the Classic ribbon
//   (0 = full history).
//
// Hero Image Update Only. NO code change.
//
// Second-derivative momentum state engine. PGamma measures the
// rate of change of momentum — not momentum itself. The four
// states are determined by the sign of Momentum (first derivative)
// and Price Gamma (second derivative) simultaneously:
//
//   Γ↑  Accelerating    — momentum positive, gamma above zero
//   Γ⌃  Bull Weakening  — momentum positive, gamma below zero
//   Γ↓  Bear Pressure   — momentum negative, gamma below zero
//   Γ⌄  Bear Exhaustion — momentum negative, gamma above zero
//
// The dashboard panel border changes color to reflect the current
// state — green for Accelerating, amber for Bull Weakening, red
// for Bear Pressure, sky blue for Bear Exhaustion.
//
// The State Ribbon plots a continuous color timeline along the
// bottom of the chart, one marker per bar, providing a visual
// history of state transitions across the session.
//
// Optional candle painting recolors bars by gamma state using
// the same colors as the State Ribbon.
//
// Best used on intraday timeframes (1m–60m).
//
// DISCLAIMER
// This script is provided for educational and informational purposes only and
// does not constitute financial, investment, or trading advice.
// Trading involves substantial risk. You are solely responsible for your decisions.
// Past performance is not indicative of future results.

//@version=6
indicator(
     title      = "Precision Price Gamma [MohaveTrader]",
     shorttitle = "PGamma",
     overlay    = true
     )

// ============================================================
// COLORS
// ============================================================

C_BG      = color.rgb(4,   7,  12)
C_PANEL   = color.rgb(8,  13,  22)
C_MUTED   = color.rgb(132, 145, 160)
C_HOT     = color.rgb(0,  240, 220)

C_ACCEL   = color.new(#39FF14, 0)   // PRange Accumulation green
C_ROLL    = color.new(#f5c842, 0)   // amber — bull weakening
C_SELL    = color.new(#FF1744, 0)   // PRange Distribution red
C_EXHAUST = color.new(#7ec8e3, 0)   // sky blue — bear exhaustion

// Strip colors — slightly lighter than PRange fill
C_STRIP_ACCEL   = #2DB82D
C_STRIP_ROLL    = #C9952A
C_STRIP_SELL    = #C0152F
C_STRIP_EXHAUST = #5BA8C4

// ============================================================
// PANEL HELPERS
// ============================================================

f_resolvePosition(_str) =>
    switch _str
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.top_right

f_resolveSize(_str) =>
    switch _str
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

// ============================================================
// INPUTS
// ============================================================

const string GRP_CALC = "Calculation"
const string GRP_DISP = "Display"

pgSource = input.source(close, "Source",          group=GRP_CALC, tooltip="Default: close.")
pgSmooth = input.int(2, "Momentum Smoothing",     group=GRP_CALC, minval=2, maxval=50, tooltip="EMA length applied to source before momentum calculation. Higher = smoother, less reactive. Default: 2.")
pgMomLen = input.int(5, "Momentum Length",        group=GRP_CALC, minval=2, maxval=30, tooltip="Lookback for slope of smoothed source (first derivative). Default: 5.")
pgGamLen  = input.int(3, "Gamma Length",           group=GRP_CALC, minval=2, maxval=20, tooltip="Lookback for rate of change of momentum (second derivative). Shorter = more reactive. Default: 3.")
i_bufPct  = input.float(5.0, "Zero Buffer %",     group=GRP_CALC, minval=0.0, maxval=50.0, step=1.0, tooltip="Hysteresis band around zero for momentum and gamma sign checks. Expressed as a percentage of each signal's recent absolute average. Prevents state flips on noise near zero. Default: 5.")

showDash  = input.bool(true,          "Show Dashboard",    group=GRP_DISP, tooltip="Default: On.")
dashPos   = input.string("Top Right", "Panel Position",    group=GRP_DISP, options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center"], tooltip="Default: Top Right.")
dashSize  = input.string("Small",     "Panel Size",        group=GRP_DISP, options=["Small","Normal","Large"], tooltip="Default: Small.")
showRibbon = input.bool(true, "Show Gamma Timeline", group=GRP_DISP, tooltip="Displays the historical sequence of Price Gamma states as a continuous color timeline along the bottom of the chart. Default: On.")
sessionsToShow = input.int(0, "Sessions to Show", group=GRP_DISP, minval=0, tooltip="Number of most recent sessions to draw the timeline for, counting today as 1. 0 = full history. Default: 0.")
showPaintbars = input.bool(true, "Paint Candles",   group=GRP_DISP, tooltip="Recolors candles by gamma state using the same colors as the State Ribbon. Disable if another indicator is painting candles. Default: On.")


// ============================================================
// CALCULATION
// ============================================================

float pgBase     = ta.ema(pgSource, pgSmooth)
float momentum   = pgBase - pgBase[pgMomLen]
float momSmooth  = ta.ema(momentum, pgSmooth)
float priceGamma = momSmooth - momSmooth[pgGamLen]

// ============================================================
// STATE CLASSIFICATION
// ============================================================

// Indicator-scale hysteresis buffers — sized relative to each signal's
// own recent magnitude, not ATR. Prevents state flips on noise near zero.
float momBuf = ta.ema(math.abs(momSmooth),  20) * i_bufPct / 100
float gamBuf = ta.ema(math.abs(priceGamma), 20) * i_bufPct / 100

var bool momUpState = false
var bool gamUpState = false

momUpState := momUpState ? momSmooth  > -momBuf : momSmooth  > momBuf
gamUpState := gamUpState ? priceGamma > -gamBuf : priceGamma > gamBuf

bool momUp   = momUpState
bool gammaUp = gamUpState

int pgStateInt = momUp and gammaUp ? 0 : momUp and not gammaUp ? 1 : not momUp and not gammaUp ? 2 : 3

string pgGlyph = pgStateInt == 0 ? "Γ↑" : pgStateInt == 1 ? "Γ⌃" : pgStateInt == 2 ? "Γ↓" : "Γ⌄"
string pgState = pgStateInt == 0 ? "Accelerating" : pgStateInt == 1 ? "Bull Weakening" : pgStateInt == 2 ? "Bear Pressure" : "Bear Exhaustion"
string gamStr  = gammaUp ? "Above Zero" : "Below Zero"

color pgColor = pgStateInt == 0 ? C_ACCEL : pgStateInt == 1 ? C_ROLL : pgStateInt == 2 ? C_SELL : C_EXHAUST

// ============================================================
// STATE STRIP
// ============================================================

color vizBase = pgStateInt == 0 ? C_STRIP_ACCEL : pgStateInt == 1 ? C_STRIP_ROLL : pgStateInt == 2 ? C_STRIP_SELL : C_STRIP_EXHAUST

// State Ribbon — colored squares along the chart bottom, lifted one text line
// so labels can sit underneath it. The shape is transparent; the square is text.
int daysFromLatest = math.floor(last_bar_time / 86400000) - math.floor(time / 86400000)
bool ribbonVisible = showRibbon and (sessionsToShow == 0 or daysFromLatest < sessionsToShow)
plotshape(ribbonVisible ? close : na, title="Gamma Timeline", style=shape.square, location=location.bottom, color=color.new(vizBase, 100), text="■\n ", textcolor=vizBase, size=size.tiny)

// ============================================================
// CANDLE PAINTING
// ============================================================

// Draws colored candles over native candles using the main state palette.
// Uses plotcandle() to match PFrostFire behavior — more reliable than barcolor().
// Disable native candles in chart settings when this is active.
color finalGammaColor = showPaintbars ? pgColor : na
plotcandle(open, high, low, close,
     title       = "PGamma Candles",
     color       = finalGammaColor,
     wickcolor   = finalGammaColor,
     bordercolor = finalGammaColor)

// ============================================================
// DASHBOARD
// ============================================================

var table  panel        = na
var string lastDashPos  = ""
var int    lastStateInt = -1

if barstate.islast and showDash
    if na(panel) or dashPos != lastDashPos or pgStateInt != lastStateInt
        if not na(panel)
            table.delete(panel)
        panel := table.new(
             position     = f_resolvePosition(dashPos),
             columns      = 3,
             rows         = 5,
             bgcolor      = color.new(C_PANEL, 4),
             frame_color  = color.new(pgColor, 30),
             frame_width  = 2,
             border_color = color.new(color.silver, 70),
             border_width = 1
             )
        lastDashPos  := dashPos
        lastStateInt := pgStateInt

    pSize = f_resolveSize(dashSize)

    string momArrow  = momUp   ? "↑" : "↓"
    string momStr    = momUp   ? "Positive" : "Negative"
    color  momColor  = momUp   ? C_ACCEL : C_SELL
    string gamArrow  = gammaUp ? "↑" : "↓"
    color  gamColor  = gammaUp ? C_ACCEL : C_SELL
    string biasArrow = pgStateInt == 0 ? "↑" : pgStateInt == 1 ? "↗" : pgStateInt == 2 ? "↓" : "↘"
    string biasStr   = pgStateInt == 0 ? "Bull Pressure" : pgStateInt == 1 ? "Bull Weakening" : pgStateInt == 2 ? "Bear Pressure" : "Bear Exhaustion"
    color  biasColor = pgStateInt == 0 ? C_ACCEL : pgStateInt == 1 ? C_ROLL : pgStateInt == 2 ? C_SELL : C_EXHAUST

    table.cell(panel, 0, 0, "PRICE GAMMA", text_color=C_HOT,   text_size=pSize, text_halign=text.align_left,   bgcolor=color.new(C_BG, 0))
    table.cell(panel, 1, 0, "",            text_color=C_MUTED, text_size=pSize, text_halign=text.align_center, bgcolor=color.new(C_BG, 0))
    table.cell(panel, 2, 0, "",            text_color=C_MUTED, text_size=pSize, text_halign=text.align_right,  bgcolor=color.new(C_BG, 0))

    table.cell(panel, 0, 1, "STATE",   text_color=C_MUTED, text_size=pSize, text_halign=text.align_left,   bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 1, 1, pgGlyph,   text_color=pgColor, text_size=pSize, text_halign=text.align_center, bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 2, 1, pgState,   text_color=pgColor, text_size=pSize, text_halign=text.align_right,  bgcolor=color.new(C_PANEL, 0))

    table.cell(panel, 0, 2, "MOMENTUM", text_color=C_MUTED,  text_size=pSize, text_halign=text.align_left,   bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 1, 2, momArrow,   text_color=momColor, text_size=pSize, text_halign=text.align_center, bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 2, 2, momStr,     text_color=momColor, text_size=pSize, text_halign=text.align_right,  bgcolor=color.new(C_PANEL, 0))

    table.cell(panel, 0, 3, "GAMMA",   text_color=C_MUTED,  text_size=pSize, text_halign=text.align_left,   bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 1, 3, gamArrow,  text_color=gamColor, text_size=pSize, text_halign=text.align_center, bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 2, 3, gamStr,    text_color=gamColor, text_size=pSize, text_halign=text.align_right,  bgcolor=color.new(C_PANEL, 0))

    table.cell(panel, 0, 4, "BIAS",     text_color=C_MUTED,   text_size=pSize, text_halign=text.align_left,   bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 1, 4, biasArrow,  text_color=biasColor, text_size=pSize, text_halign=text.align_center, bgcolor=color.new(C_PANEL, 0))
    table.cell(panel, 2, 4, biasStr,    text_color=biasColor, text_size=pSize, text_halign=text.align_right,  bgcolor=color.new(C_PANEL, 0))
````
