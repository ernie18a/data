# Regime Classifier [RC Tools]

- url: https://www.tradingview.com/script/ZLAf3wUs-Regime-Classifier-RC-Tools/
- type: indicator
- pine_id: PUB;5c5ecbf6139c4a0ca72b0dd001b3830d
- version: 5.0

## Description

RC Tools — Regime Classifier
─────────────────────────────────────────────────────────────

█ OVERVIEW

Most indicators assume a single market condition and quietly fail in another. This tool doesn't generate signals — it tells you which of four market regimes you are currently in, so you can judge whether your existing tools are operating in conditions that suit them. It is a context tool, not a decision tool.

█ WHAT IT DOES

Classifies each confirmed bar into one of four states and colours the chart background accordingly:

• Trending — Expansion: directional, volatility rising
• Trending — Exhaustion: directional, volatility compressing
• Ranging — Quiet: no direction, low volatility
• Ranging — Volatile: no direction, high volatility (chop)

A table (top-right by default, repositionable) shows the current regime, how long price has been in it, and historical base rates — the average forward return and win rate seen after each regime, going back over the chart's full history.

█ THE THEORY BEHIND IT

Market behaviour is not stationary. A trend-following tool that performs well in directional expansion will bleed in volatile chop; a mean-reversion tool does the reverse. Rather than attempting to fix any single indicator, this tool identifies which environment you are in, using two independent dimensions — directionality and volatility state — that measure genuinely different properties of price behaviour rather than two correlated views of the same one.

█ HOW IT IS CALCULATED

DIRECTIONALITY — Efficiency Ratio over N bars:

ER = |close[0] − close[N]| ÷ Σ|close[i] − close[i+1]|

Bounded 0–1. A value near 1 means price travelled almost directly from A to B (trending); near 0 means it wandered (ranging). No fitted parameters beyond the lookback. The Efficiency Ratio was introduced by Perry Kaufman as the core input to his Adaptive Moving Average (KAMA); it is used here purely as a directionality measure, independent of any moving average.

VOLATILITY STATE — realised volatility, percentile-ranked:

RV = stdev(log(close/close[1]), N)

RV is then ranked as a percentile against its own trailing distribution (default: 750 bars, ≈3 years on daily). An absolute volatility threshold is meaningless across assets — percentile ranking makes the classification behave identically on BTC, gold and equities with no parameter tuning.

The two dimensions are crossed to yield the four states. Classification occurs ONLY on confirmed bar close — the background never updates mid-bar and then flips back.

The base-rate table works by recording, for every historical bar, the forward N-bar return and whether it was positive, attributed back to whichever regime was active N bars earlier. Only fully-elapsed, already-known returns are used — nothing is looked up ahead of the current bar.

█ SETTINGS & CONFIGURATION

• Efficiency Ratio Lookback (default 20) — shorter = more responsive, noisier
• Realised Volatility Lookback (default 20)
• Percentile Ranking Window (default 750 bars ≈ 3 years daily) — longer = more stable, needs more history
• Directionality Threshold (default 0.35) — the ER above which price is considered trending
• Volatility Percentile Threshold (default 50) — the split between low and high volatility states
• Forward Return Window (default 20 bars) — the horizon used for the base-rate table
• Table position and background colours are fully configurable; the main-chart background painting can be toggled off if you only want the diagnostic pane

█ HOW TO USE IT

Use it as a filter on your existing process, not as an entry trigger. Example: if you run a breakout system, check whether it has historically performed in Ranging — Volatile; if not, consider standing aside when the background flags that state. Example: a mean-reversion system will typically show its worst results in Trending — Expansion.

Works on any asset and timeframe with sufficient history for the percentile window. Best used on daily and above, where regime persistence is greatest.

█ LIMITATIONS

This tool classifies the PRESENT. It does not predict the future, and any use of it as a forecast is a misuse.

• Regime identification is backward-looking by construction. The tool will confirm a regime change several bars AFTER it occurred. This lag cannot be removed without curve-fitting or repainting, and has not been.
• Classification is unstable near threshold boundaries; expect flickering between states when ER or volatility percentile sit close to the cut-offs.
• The percentile ranking requires substantial history. On assets with short histories, the ranking is unreliable and the tool should not be trusted.
• The base-rate table's early entries are built on fewer samples than its later ones — treat statistics as provisional until a state has accumulated a meaningful sample count.
• Four states is a deliberate simplification of a continuous reality. Markets do not actually occupy discrete regimes.
• This script does NOT repaint. All classification is computed on confirmed bar close only.

█ DISCLAIMER

For educational and informational purposes only. Nothing here is financial advice. Past behaviour of any market regime does not indicate future results. Trade at your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAC97

//@version=6
indicator("Regime Classifier [RC Tools]", shorttitle="RCT Regime", overlay=false, precision=2)

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT
// ─────────────────────────────────────────────────────────────────────────────
// This is a CONTEXT tool, not a signal tool. It classifies the current market
// into one of four regimes along two independent dimensions — directionality
// and volatility state — and colours the main chart background accordingly.
//
// It does NOT predict. Classification happens ONLY on confirmed bar close,
// so nothing here repaints. See the "Limitations" note at the bottom of this
// file, and the published script description, before using this.
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// ── Directionality (Efficiency Ratio) ─────────────────────────────────────────
int   erLen    = input.int(20, "Efficiency Ratio Lookback", minval=2, group="Directionality",
     tooltip="Bars used to measure net move vs total path length. Shorter = more responsive, noisier.")
float erThresh = input.float(0.35, "Directionality Threshold", minval=0.05, maxval=0.95, step=0.01, group="Directionality",
     tooltip="Efficiency Ratio above this value = Trending. Below = Ranging.")

// ── Volatility State (percentile-ranked realised vol) ─────────────────────────
int rvLen     = input.int(20, "Realised Volatility Lookback", minval=2, group="Volatility",
     tooltip="Bars used to compute the standard deviation of log returns.")
int pctWindow = input.int(750, "Percentile Ranking Window (bars)", minval=50, group="Volatility",
     tooltip="Trailing window realised volatility is ranked against. Default ≈ 3 years on the daily timeframe. Longer = more stable, but needs more history.")
int volThresh = input.int(50, "Volatility Percentile Threshold", minval=1, maxval=99, group="Volatility",
     tooltip="Volatility percentile above this = high-volatility state. This is a PERCENTILE, not an absolute level, so the tool behaves the same across assets.")

// ── Table ──────────────────────────────────────────────────────────────────────
bool showTable = input.bool(true, "Show Stats Table", group="Table")
string tablePos = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Table")

// ── Colours ────────────────────────────────────────────────────────────────────
color colExpansion  = input.color(color.new(color.lime,   72), "Trending — Expansion",  group="Colours")
color colExhaustion = input.color(color.new(color.orange, 72), "Trending — Exhaustion", group="Colours")
color colVolatile   = input.color(color.new(color.red,    72), "Ranging — Volatile",    group="Colours")
color colQuiet      = input.color(color.new(color.gray,   85), "Ranging — Quiet",       group="Colours")
bool  paintMainChart = input.bool(true, "Paint Main Chart Background", group="Colours",
     tooltip="Uses force_overlay so the regime background shows on the price chart even though this script lives in its own pane.")


// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

// ── Directionality — Efficiency Ratio ─────────────────────────────────────────
// ER = |close - close[N]| ÷ Σ|close[i] - close[i+1]|  over N bars. Bounded 0–1.
// Near 1 = price travelled almost directly from A to B (trending).
// Near 0 = price wandered (ranging). No fitted parameters beyond the lookback.
float netMove = math.abs(close - close[erLen])
float sumMove = math.sum(math.abs(close - close[1]), erLen)
float er      = sumMove != 0 ? netMove / sumMove : 0.0

// ── Volatility State — realised vol, percentile-ranked ────────────────────────
// RV = stdev(log(close/close[1]), N), then ranked as a percentile against its
// own trailing distribution. An absolute vol threshold is meaningless across
// assets — percentile ranking is what makes this behave the same on BTC,
// gold or equities with no parameter tuning.
float logRet = math.log(close / close[1])
float rv     = ta.stdev(logRet, rvLen)
float volPct = ta.percentrank(rv, pctWindow)

// ── Enough history? ────────────────────────────────────────────────────────────
bool warmedUp = bar_index >= pctWindow and not na(volPct) and not na(er)

bool trendingNow = er > erThresh
bool volatileNow = volPct > volThresh

// State codes: 0 = Trending-Expansion, 1 = Trending-Exhaustion,
//              2 = Ranging-Volatile,   3 = Ranging-Quiet
int rawState = na
if warmedUp
    rawState := trendingNow and volatileNow ? 0 :
         trendingNow and not volatileNow ? 1 :
         (not trendingNow) and volatileNow ? 2 : 3

// ── Confirmed-close-only classification (non-repainting) ─────────────────────
// The state only updates when a bar is confirmed. During the forming
// (unconfirmed) bar, the chart keeps showing the previous CONFIRMED state.
// This is deliberate: it means the regime background never flips on you
// mid-bar and then flips back — it changes once, at close, and stays put.
var int regimeState = na
if barstate.isconfirmed
    regimeState := rawState


// ─────────────────────────────────────────────────────────────────────────────
// LABELS & COLOURS
// ─────────────────────────────────────────────────────────────────────────────

stateName(s) =>
    s == 0 ? "Trending — Expansion" :
     s == 1 ? "Trending — Exhaustion" :
     s == 2 ? "Ranging — Volatile" :
     s == 3 ? "Ranging — Quiet" : "Warming up…"

stateColor(s) =>
    s == 0 ? colExpansion :
     s == 1 ? colExhaustion :
     s == 2 ? colVolatile :
     s == 3 ? colQuiet : na


// ─────────────────────────────────────────────────────────────────────────────
// REGIME STREAK (how long we've been in the current state)
// ─────────────────────────────────────────────────────────────────────────────
var int lastState = na
var int streak     = 0
if barstate.isconfirmed
    if regimeState == lastState
        streak := streak + 1
    else
        streak := 1
        lastState := regimeState


// ─────────────────────────────────────────────────────────────────────────────
// PLOTS — diagnostics in this script's own pane
// ─────────────────────────────────────────────────────────────────────────────
plot(er * 100, "Efficiency Ratio (×100)", color=color.new(color.blue, 0), linewidth=1)
plot(volPct,   "Volatility Percentile",   color=color.new(color.purple, 0), linewidth=1)
hline(erThresh * 100, "Directionality Threshold", color=color.gray, linestyle=hline.style_dashed)
hline(volThresh,      "Volatility Threshold",     color=color.gray, linestyle=hline.style_dotted)

// Background on THIS pane
bgcolor(warmedUp ? stateColor(regimeState) : na, title="Regime Background (pane)")
// Background on the MAIN price chart, even though this script isn't overlay
bgcolor(paintMainChart and warmedUp ? stateColor(regimeState) : na, force_overlay=true, title="Regime Background (main chart)")


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

    table.cell(t, 0, 0, "Regime Classifier", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor=color.new(color.black, 0))
    table.cell(t, 2, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(t, 0, 1, "Current", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, warmedUp ? stateName(regimeState) : "Warming up…", text_color=warmedUp ? stateColor(regimeState) : color.gray, text_size=size.small)
    table.cell(t, 2, 1, warmedUp ? str.tostring(streak) + " bars" : "", text_color=color.gray, text_size=size.small)


// ─────────────────────────────────────────────────────────────────────────────
// LIMITATIONS (see published description for the full-length version)
// ─────────────────────────────────────────────────────────────────────────────
// - This classifies the PRESENT. It does not predict the future.
// - Regime identification is backward-looking by construction — it confirms
//   a regime change several bars AFTER it happened. This lag is not removed
//   without curve-fitting or repainting, and has not been.
// - Classification is unstable near threshold boundaries — expect flickering
//   between states when ER or vol percentile sit close to the cut-offs.
// - Percentile ranking needs substantial history. On short-history assets the
//   ranking is unreliable and the tool should not be trusted.
// - Four states is a deliberate simplification of a continuous reality.
// - This script does NOT repaint. All classification is on confirmed close.
// ─────────────────────────────────────────────────────────────────────────────
````
