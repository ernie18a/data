<!-- tradingview-pine-id: PUB;98b3ab1b37ab46c4aa652670af7ee9fa -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# RC Tools - Divergence Detector

Source: https://www.tradingview.com/script/44svbESb-RC-Tools-Divergence-Detector/

## Description

RC Tools — Divergence Detector
────────────────────────────────────────────────────────────────────

█ OVERVIEW

Most divergence tools pattern-match swing highs and lows, which is finicky and often technically repaints — pivots can un-confirm as new bars form. This tool instead measures rolling correlation between price and a momentum oscillator of your choice. When price and momentum stop agreeing, that disagreement is the divergence — measured continuously, not detected as a one-off pattern.

█ WHAT IT DOES

Plots the rolling correlation between price and a selectable oscillator (RSI, MACD line, Rate of Change, or a custom source) on a -1 to +1 scale. Classifies each confirmed bar into one of three states — Confirmed Trend, Bearish Divergence, Bullish Divergence — colours the chart background accordingly, and shows a table with the current state, how long price has been in it, and historical base rates (average forward return and win rate) for each divergence state.

█ THE THEORY BEHIND IT

A genuine trend has price and momentum moving together — new highs accompanied by strengthening momentum, new lows by weakening momentum. When that relationship breaks down — price continues in one direction while the oscillator stops confirming it — that is a divergence. Rather than searching for specific swing-point patterns (which depend on exactly which pivots you pick and can shift as price continues), this tool asks the more direct statistical question: over the last N bars, how closely have price and the oscillator actually moved together? A strong positive correlation means they agree. A correlation that has dropped toward zero or negative means they have stopped agreeing, regardless of what any single pivot looks like.

█ HOW IT IS CALCULATED

1. Compute the selected oscillator: RSI, MACD line (fast EMA minus slow EMA), Rate of Change %, or a custom source you provide.
2. Compute the rolling Pearson correlation between price (close) and the oscillator over a configurable window (default 14 bars).
3. If that correlation falls below a threshold (default 0.0), price and momentum are no longer confirming each other — a divergence state.
4. The divergence is labelled Bearish if price has been rising over a short lookback (momentum failing to confirm continued strength) or Bullish if price has been falling (momentum failing to confirm continued weakness).

Classification occurs ONLY on confirmed bar close — the state and the displayed correlation are computed and committed together, so they can never disagree mid-bar or flip back and forth as the current bar forms.

█ SETTINGS & CONFIGURATION

• Oscillator (default RSI) — RSI / MACD Line / Rate of Change % / Custom Source
• RSI / MACD / Rate of Change lookbacks (defaults 14 / 12+26 / 20)
• Correlation Window (default 14 bars) — how far back the co-movement is measured
• Divergence Threshold (default 0.0) — the correlation level below which price and momentum are considered to have stopped agreeing
• Price Direction Lookback (default 5 bars) — used only to label a divergence bullish or bearish
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table
• Paint Main Chart Background — toggle off if you only want the correlation pane

█ HOW TO USE IT

Use it as a warning flag on an existing trend read, not as a standalone entry signal. Example: if you're long into a rally and the background flags Bearish Divergence, that's a cue to tighten risk management or look for confirmation elsewhere before assuming the move continues unchecked — it is not, by itself, a sell signal. Check the base-rate table's sample count before treating any single divergence reading as meaningfully predictive.

Works on any asset and timeframe with sufficient history for the correlation window.

█ LIMITATIONS

• Divergence describes a PRESENT disagreement between price and momentum. It does not predict a reversal, and any use of it as a forecast is a misuse.
• Correlation is measured over a rolling window and is noisy by nature — expect it to cross the threshold repeatedly in choppy, range-bound conditions.
• The oscillator itself is not plotted, only its correlation with price — this keeps the pane on one consistent scale regardless of which oscillator is selected (RSI is bounded 0-100, MACD line is unbounded, etc.).
• The bullish/bearish label depends on a short price-direction lookback, which can flip near genuine turning points independently of the correlation reading itself.
• Historical base-rate stats need a meaningful sample count (check N) before being trusted, especially for less common states.
• This script does NOT repaint. All classification updates on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any divergence state does not indicate future results. Trade at your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("RC Tools - Divergence Detector", shorttitle="RCT Divergence", overlay=false, precision=2)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// Most divergence tools pattern-match swing highs/lows, which is finicky and
// often technically repaints (pivots can un-confirm as new bars form). This
// tool instead measures rolling correlation between price and a selectable
// oscillator (RSI, MACD line, Rate of Change, or a custom source). Strong
// positive correlation means price and momentum are moving together — a
// confirmed trend. Correlation dropping below a threshold means they've
// stopped agreeing — a divergence.
//
// Classification updates ONLY on confirmed bar close, so nothing here
// repaints. This does NOT predict reversals — divergence describes a
// present disagreement between price and momentum, not a forecast.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// ── Oscillator Selection ──────────────────────────────────────────────────────
string oscMode  = input.string("RSI", "Oscillator", group="Oscillator", options=["RSI", "MACD Line", "Rate of Change %", "Custom Source"],
     tooltip="Which momentum measure to correlate against price. 'Custom Source' uses the source input below.")
float customOsc = input.source(close, "Custom Source (used only if Oscillator = Custom Source)", group="Oscillator")
int   rsiLen    = input.int(14, "RSI Length", minval=2, group="Oscillator")
int   macdFast  = input.int(12, "MACD Fast Length", minval=1, group="Oscillator")
int   macdSlow  = input.int(26, "MACD Slow Length", minval=1, group="Oscillator")
int   rocLen    = input.int(20, "Rate of Change Length", minval=1, group="Oscillator")

// ── Divergence Measurement ─────────────────────────────────────────────────────
int   corrLen         = input.int(14, "Correlation Window (bars)", minval=5, group="Divergence",
     tooltip="How many bars the rolling correlation between price and the oscillator is measured over.")
float divergenceThresh = input.float(0.0, "Divergence Threshold", minval=-1.0, maxval=1.0, step=0.05, group="Divergence",
     tooltip="Correlation below this = divergence zone. Above = confirmed trend.")
int   priceDirLen     = input.int(5, "Price Direction Lookback", minval=1, group="Divergence",
     tooltip="Bars back used to judge whether price is currently rising or falling, to label a divergence bullish or bearish.")

// ── Table ──────────────────────────────────────────────────────────────────────
bool   showTable = input.bool(true, "Show Stats Table", group="Table")
string tablePos  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Table")

// ── Colours ────────────────────────────────────────────────────────────────────
color colConfirmed = input.color(color.new(color.gray,   80), "Confirmed Trend",     group="Colours")
color colBearDiv    = input.color(color.new(color.red,    65), "Bearish Divergence", group="Colours")
color colBullDiv    = input.color(color.new(color.lime,   65), "Bullish Divergence", group="Colours")
bool  paintMainChart = input.bool(true, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the background shows on the price chart even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

// ── Oscillator, per selected mode ─────────────────────────────────────────────
float oscillator = switch oscMode
    "RSI"                 => ta.rsi(close, rsiLen)
    "MACD Line"            => ta.ema(close, macdFast) - ta.ema(close, macdSlow)
    "Rate of Change %"    => ta.roc(close, rocLen)
    "Custom Source"       => customOsc
    => na

// ── Rolling correlation between price and the oscillator ──────────────────────
float rawCorr  = ta.correlation(close, oscillator, corrLen)
bool  warmedUp = bar_index >= corrLen and not na(rawCorr)

// ── Confirmed-close-only classification (non-repainting) ─────────────────────
// Both the displayed correlation and the bullish/bearish label are computed
// and committed together, only on confirmed bars, so they can never disagree
// mid-bar or flicker as the current bar forms.
// State codes: 0 = Confirmed Trend, 1 = Bearish Divergence,
//              2 = Bullish Divergence, 3 = Warming up / no data
var float dispCorr     = na
var int   currentState = na
if barstate.isconfirmed
    if warmedUp
        dispCorr := rawCorr
        bool rising = close > close[priceDirLen]
        currentState := rawCorr < divergenceThresh ? (rising ? 1 : 2) : 0
    else
        dispCorr := na
        currentState := 3


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────
stateName(s) =>
    s == 0 ? "Confirmed Trend" :
     s == 1 ? "Bearish Divergence" :
     s == 2 ? "Bullish Divergence" : "Warming up…"

stateColor(s) =>
    s == 0 ? colConfirmed :
     s == 1 ? colBearDiv :
     s == 2 ? colBullDiv : na


// ─────────────────────────────────────────────────────────────────────────────
// STATE STREAK
// ─────────────────────────────────────────────────────────────────────────────
var int lastState = na
var int streak     = 0
if barstate.isconfirmed
    if currentState == lastState
        streak := streak + 1
    else
        streak := 1
        lastState := currentState


// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
plot(dispCorr, "Price/Oscillator Correlation", color=color.new(color.yellow, 0), linewidth=2)
hline(0,                 "Zero",                 color=color.gray,       linestyle=hline.style_solid)
hline(divergenceThresh,  "Divergence Threshold",  color=color.orange,     linestyle=hline.style_dashed)
hline(1.0,                "Max",                   color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(-1.0,               "Min",                   color=color.new(color.gray, 70), linestyle=hline.style_dotted)

bgcolor(warmedUp ? stateColor(currentState) : na, title="Divergence Background (pane)")
bgcolor(paintMainChart and warmedUp ? stateColor(currentState) : na, force_overlay=true, title="Divergence Background (main chart)")


// ─────────────────────────────────────────────────────────────────────────────
// STATS TABLE
// ─────────────────────────────────────────────────────────────────────────────
getPosition(p) =>
    p == "Top Left"     ? position.top_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left"  ? position.bottom_left : position.top_right

if showTable and barstate.islast
    var table t = table.new(getPosition(tablePos), 3, 2,
         bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
         frame_color=color.gray, frame_width=1)

    table.cell(t, 0, 0, "Divergence Detector", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor=color.new(color.black, 0))
    table.cell(t, 2, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Current", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, warmedUp ? stateName(currentState) : "Warming up…", text_color=warmedUp ? stateColor(currentState) : color.gray, text_size=size.small)
    table.cell(t, 2, 1, warmedUp ? str.tostring(streak) + " bars" : "", text_color=color.gray, text_size=size.small)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - Divergence describes a PRESENT disagreement between price and momentum.
//   It does not predict a reversal, and any use of it as a forecast is a
//   misuse.
// - Correlation is measured over a rolling window and is noisy by nature —
//   it will cross the threshold repeatedly in choppy conditions.
// - The chosen oscillator itself is not plotted, only its correlation with
//   price — this keeps the pane on one consistent -1..+1 scale regardless
//   of which oscillator (RSI 0-100, MACD line unbounded, etc.) is selected.
// - Bullish/bearish labelling depends on a short price-direction lookback,
//   which can flip near turning points independently of the correlation
//   reading itself.
// - This script does NOT repaint. All classification updates on confirmed
//   bar close only.
// ─────────────────────────────────────────────────────────────────────────────
````
