<!-- tradingview-pine-id: PUB;28c5aa4f6ed643be9bec45ce0533502c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Master Line Lite · 5-MA Consensus

Source: https://www.tradingview.com/script/UpOkagpl-Master-Line-Lite-5-MA-Consensus/

## Description

Master Line Lite condenses five different moving-average families into a single, easy-to-read consensus trend line, then filters its direction with a volatility-aware band so the trend only changes when price commits. It's a clean, open-source alternative to stacking several moving averages on one chart.

How it works

Each moving-average type reacts to price differently. An EMA and a WMA weight recent bars heavily and turn quickly; an SMA weights every bar equally and turns slowly; an RMA (Wilder's) is the smoothest; and an HMA cuts lag while staying responsive. Any single one is a compromise — fast types whipsaw in chop, slow types lag at turns.

Master Line Lite computes all five over the same length and averages them into one line:

consensus = ( EMA + SMA + WMA + HMA + RMA ) / 5

Blending the five balances their individual biases: the fast members keep the line responsive while the slow members damp noise. That's the purpose of the combination — not to stack indicators, but to average out the weakness of each MA type into one steadier reference than a single fast MA, yet more responsive than a single slow one.

Direction is then decided with an ATR band instead of a raw cross. The trend turns bullish only when price closes above the line by more than Flip band × ATR, and bearish only when it closes the same distance below; between those thresholds the previous trend is held. This deadband is what suppresses the constant flip-flopping of a plain price/MA cross during sideways markets.

The line is colored by the current trend, an optional band shows the flip thresholds, and triangles mark the exact bar where the trend flips.

How to use it

Use the line as a trend reference and bias filter — favor longs while it's teal, shorts while it's red.
The triangles flag where the consensus trend changes — a "context has shifted" cue, not a standalone entry.
Widen the Flip band on noisy/ranging instruments to cut false flips; narrow it on clean trends for earlier turns.
Increase Length for a slower higher-timeframe bias; decrease it for a faster intraday read.
Two built-in alerts fire on bullish and bearish flips.

Settings

Source — price series the averages are built from (default: close).
Length — lookback used for all five moving averages.
Flip band (× ATR) — how far price must clear the line to change the trend; the core noise filter.
Show band — draw the upper/lower flip thresholds.
Color bars by trend — tint candles with the trend color.
Show status box — small top-right label with the current Bull / Bear / Flat state.

Notes and limitations

Like all moving-average methods, this lags at turning points and can flip late after sharp reversals — the ATR band trades some timing for fewer false signals. Values can update on the still-forming real-time bar until it closes. It does not predict price and makes no performance claims; use it as one input alongside your own analysis and risk management.

For research and education only. This is not financial advice.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
//  MASTER LINE LITE   ·   v1.0             Free 5-MA Consensus Trend
//  © 2026 Boris Tatchou   ·   Licensed under MPL-2.0 (open source)
// ──────────────────────────────────────────────────────────────────────
//  Blends five classic moving averages — EMA · SMA · WMA · HMA · RMA —
//  into one consensus trend line, with an ATR-banded direction filter,
//  flip markers and alerts. Minimal, open-source and self-contained.
//
//  For research and education only. Not financial advice.
// ══════════════════════════════════════════════════════════════════════

indicator("Master Line Lite · 5-MA Consensus", overlay = true)

// ── Inputs ────────────────────────────────────────────────────────────
src       = input.source(close, "Source")
len       = input.int(50, "Length", minval = 2)
bandMult  = input.float(0.5, "Flip band (× ATR)", minval = 0.0, step = 0.1,
             tooltip = "Price must clear the consensus line by this many ATR to flip the trend. Higher = fewer, steadier flips.")
showBand  = input.bool(true,  "Show band")
colorBars = input.bool(false, "Color bars by trend")
showPanel = input.bool(true,  "Show status box")

// ── Consensus of five classic moving averages ─────────────────────────
c_ema = ta.ema(src, len)
c_sma = ta.sma(src, len)
c_wma = ta.wma(src, len)
c_hma = ta.hma(src, len)
c_rma = ta.rma(src, len)
consensus = (c_ema + c_sma + c_wma + c_hma + c_rma) / 5.0

// ── Direction: latch trend until price clears the far ATR band ────────
band = bandMult * ta.atr(14)
var int dir = 0
dir := close > consensus + band ?  1 :
       close < consensus - band ? -1 : dir

up = dir > 0
dn = dir < 0
lineCol = up ? color.teal : dn ? color.red : color.gray

// ── Plots ─────────────────────────────────────────────────────────────
plot(consensus, "Consensus", color = lineCol, linewidth = 2)
plot(showBand ? consensus + band : na, "Upper band", color = color.new(color.gray, 80))
plot(showBand ? consensus - band : na, "Lower band", color = color.new(color.gray, 80))
barcolor(colorBars ? (up ? color.new(color.teal, 60) : dn ? color.new(color.red, 60) : na) : na)

// ── Flip signals + alerts ─────────────────────────────────────────────
bull = up and dir[1] <= 0
bear = dn and dir[1] >= 0
plotshape(bull, "Bull flip", shape.triangleup,   location.belowbar, color.teal, size = size.small)
plotshape(bear, "Bear flip", shape.triangledown, location.abovebar, color.red,  size = size.small)
alertcondition(bull, "Bull flip", "Master Line Lite — bullish flip on {{ticker}} {{interval}}")
alertcondition(bear, "Bear flip", "Master Line Lite — bearish flip on {{ticker}} {{interval}}")

// ── Compact status box ────────────────────────────────────────────────
var table t = table.new(position.top_right, 1, 1,
     bgcolor = color.new(color.black, 30), frame_color = color.new(color.gray, 60), frame_width = 1)
if showPanel and barstate.islast
    state = up ? "▲  Bull" : dn ? "▼  Bear" : "—  Flat"
    table.cell(t, 0, 0, "Master Line Lite     " + state, text_color = lineCol, text_size = size.normal)
````
