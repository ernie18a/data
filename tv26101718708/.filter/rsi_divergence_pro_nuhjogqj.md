# RSI Divergence Pro

- url: https://www.tradingview.com/script/nuhjogqJ-RSI-Divergence-Pro/
- type: indicator
- pine_id: PUB;cda5bdc21b484632bac2c02252ea0f08
- version: 6.0

## Description

RSI Divergence Pro

WHAT IT DOES
RSI Divergence Pro is a self-contained RSI that detects all four divergence types (regular bullish, regular bearish, hidden bullish, hidden bearish), draws them on both the RSI pane and the main price chart, and — unlike most divergence tools — keeps a live scoreboard of how each divergence type has actually behaved on the current symbol and timeframe.

It reproduces the standard RSI (same calculation and pane visuals as the built-in: band background, overbought/oversold gradient fills, optional smoothing MA and Bollinger Bands) so it can replace an existing RSI pane one-for-one, then layers divergence detection on top.

WHY IT'S DIFFERENT
1. RSI-anchored pivots. Divergences are detected from pivots on the RSI itself (ta.pivotlow / ta.pivothigh applied to the RSI series), not on price. Marker and line endpoints therefore sit exactly on the RSI curve instead of floating mid-slope, and the RSI — the thing actually diverging — is the source of truth. Price at those same bars supplies the price leg.
2. Built-in outcome tracking. Every confirmed divergence spawns a simulated bracket (entry at the confirmation close, ATR-multiple target and stop, fixed bar horizon). Results are tallied per type into a table: sample size (N), win rate, and average R. This turns the indicator into a measurement instrument — you can see, per symbol and timeframe, whether a given divergence type has shown any edge before you weight it in your analysis.
3. Honest mechanics. Signals confirm a fixed number of bars after the pivot (the right lookback) and never earlier; alerts fire on bar close; the simulator resolves on confirmed bars only, checks the stop before the target when both are touched inside one bar (conservative tie-break), and is gap-aware — a bar opening beyond the stop or target fills at the open, not at the ideal price.

HOW DETECTION WORKS
A pivot low/high on RSI is confirmed after "Pivot Lookback Right" bars. Each newly confirmed pivot is compared to the previous same-side pivot, subject to a minimum/maximum bar-distance gate:
- Regular bullish: price lower low + RSI higher low
- Hidden bullish: price higher low + RSI lower low
- Regular bearish: price higher high + RSI lower high
- Hidden bearish: price lower high + RSI higher high
Each type toggles independently and is styled independently (color, line style, width, transparency).

THE OUTCOME TABLE — READ BEFORE TRUSTING ANY DIVERGENCE
Defaults: entry at the confirmation close, target 2×ATR(14), stop 1×ATR(14), 20-bar horizon (expiry marks to close). All adjustable. With the default 2:1 bracket, average R ≈ 3 × win rate − 1 for non-gap resolutions, so the table's internal consistency can be sanity-checked by eye. These statistics measure raw divergence behavior under one fixed mechanical rule on the loaded chart history. They are not a backtest of a complete trading plan, they are not predictive of future results, and small samples are noise. Open (unresolved) simulations are shown in the table header and excluded from N.

DISPLAY & CUSTOMIZATION
- Lines on the RSI pane, the price chart, or both; info tags toggle per pane independently of the lines
- Tag styles: colored bubble or clean floating text; compact or detailed text (RSI change and price %); hover any tag for the full tooltip (type, RSI from→to, price from→to, bars apart, position vs the 50 line)
- Optional forward projection ray per divergence line, with its own color source, style, width, and transparency
- Optional freshness fade: older lines grow progressively more transparent so the newest stands out
- Discreet pivot tick marks on the RSI curve and on candles, styled per side
- The stock RSI visuals (band background, OB/OS gradients) can each be hidden for a clean pane
- Info table (RSI value, 50-line bias, last pivots, last divergence and its age) and outcome table, each position-selectable; both flash green or red for a configurable number of bars when a new bullish or bearish divergence confirms
- Array-managed object pools with configurable caps keep the script inside Pine's drawing limits; oldest drawings trim automatically and statistics are never trimmed

ALERTS
Five alertcondition triggers (one per type plus "Any RSI Divergence") for the standard alert dialog, and an optional dynamic alert() payload ("Any alert() function call") carrying live detail: ticker, timeframe, type, RSI from→to, price from→to, bars apart.

HOW TO USE IT
Works on any symbol and adapts to the chart timeframe. A reasonable workflow: run all four types with outcome tracking on, let the table accumulate, then disable the types showing no edge on your market and keep those that do. Regular divergences are conventionally read as reversal context and hidden divergences as continuation context; treat both as context alongside your own structure and trend analysis, not as standalone entries.

KNOWN BEHAVIOR / LIMITATIONS
- Confirmation lag is by design: a divergence cannot exist until its pivot confirms, so the signal appears "Pivot Lookback Right" bars after the pivot bar. After confirmation, signals do not repaint.
- Divergence lines and labels connect back to past pivots by nature; the drawing extends into the past, the signal timing does not.
- The outcome simulator works from confirmed OHLC bars; intrabar sequence is unknowable from OHLC, hence the conservative stop-first rule.
- Intended for standard candle/bar charts; synthetic chart types (Heikin Ashi, Renko, etc.) distort the price legs and the simulation.

The base RSI calculation and pane visuals reproduce TradingView's built-in RSI so the script can serve as a drop-in replacement; the divergence detection, drawing system, outcome tracking, and alert logic are original to this script.

For education and analysis only. Nothing here is financial advice, and past behavior of any signal does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("RSI Divergence Pro", "RSI Div Pro", format=format.price, precision=2, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
// v1.2 — RECENT ROW (ROLLING LAST-K WINDOW)
// The outcome table gains a "Last 20" row: Win% (same Wilson CI / ★
// treatment) and Exp R over the most recent K resolved trades, pooled
// across all four divergence types — the drift detector. Compare it
// against All: a healthy lifetime record with a sagging recent window
// means the divergences' character on this symbol changed (regime
// shift, volatility shift, or edge decay). The row's tooltip carries
// the window's MEDIAN R, and the All row's tooltip now carries the
// lifetime median (medians are gap-robust where means are not).
// Window adjustable (default 20); exempt from Min-N dimming — the
// small sample is by design; the CI carries the honesty. Same
// machinery as the Setup Expectancy Lab's Recent row. Statistics are
// fed by a new master R list (soft cap 4000) that replays with
// history; per-type counters are never trimmed.
// ───────────────────────────────────────────────────────────────────
// v1.1.2 — SELF-AUDITING OUTCOME TOOLTIPS
// The outcome tag's tooltip is now a complete trade record: alongside
// the result (R, bars) it states HOW the bracket resolved — stop hit,
// target hit, gap fill (with the actual fill price), or horizon
// expiry (with the marked close) — plus the Entry / Stop / Target
// prices, with the pivot→entry offset stated explicitly (the tag sits
// at the PIVOT; entry is the close Pivot-Lookback-Right bars later).
// Tooltip-only: detection, statistics, painting, rendering unchanged.
// ───────────────────────────────────────────────────────────────────
// v1.1.1 — COLORED OUTCOME MARKS
// The tag outcome suffix can now render as colored marks — green ✅ on
// a win, red ❌ on a loss (new default) — via an "Outcome Mark Style"
// selector. A Pine label has a SINGLE text color, so the minimal ✓/✗
// glyphs can only inherit the tag's type color; the colored marks are
// emoji glyphs that render green/red regardless of text color.
// "Minimal ✓ / ✗" preserves the v1.1 look. The suffix toggle still
// defaults OFF — default rendering is unchanged.
// ───────────────────────────────────────────────────────────────────
// v1.1 — OUTCOME PAINT + WILSON CI
// 1) OUTCOME-PAINTED DIVERGENCES (default Off): when the tracker
//    resolves a divergence's bracket, its lines/projections repaint by
//    result — Win/Loss Recolor, or Type Color with dimmed losers.
//    Optional outcome tag suffix adds resolution detail (R, bars) to
//    the tag and its tooltip. Resolved lines are exempt from freshness
//    fade; open trades render exactly as before resolution. Painting
//    is serial-linked and pool-scan based: drawings trimmed by the
//    object cap are simply skipped — no deleted-object access is
//    possible by construction.
// 2) OUTCOME TABLE STATISTICS: Win% now shows a Wilson 95% CI
//    (±half-width; exact bounds in the cell tooltip) and a ★ when the
//    exact Wilson lower bound clears the bracket's breakeven rate
//    (stop/(stop+target), shown in the header). Min-N dimming renders
//    small-sample rows as noise. Same math as the Setup Expectancy
//    Lab — 58±24★ means the identical thing in both tables.
// ═══════════════════════════════════════════════════════════════════

// ============================== HELPERS ==============================
getLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

getSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

getTablePos(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : s == "Bottom Center" ? position.bottom_center : s == "Bottom Right" ? position.bottom_right : position.top_right

// Wilson score interval for a binomial proportion (z fixed at 1.96 = 95%).
// Returns [center, halfWidth] as fractions 0–1. Chosen over the normal
// approximation because it stays honest at small N and extreme win rates.
// Ported verbatim from the Setup Expectancy Lab so both tables agree.
wilsonCI(int w, int n) =>
    float z = 1.96
    float nf = float(n)
    float p = float(w) / nf
    float z2n = z * z / nf
    float center = (p + z2n / 2.0) / (1.0 + z2n)
    float half = z * math.sqrt(p * (1.0 - p) / nf + z * z / (4.0 * nf * nf)) / (1.0 + z2n)
    [center, half]

// ============================ RSI (BASE) ============================
rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")

// RSI pane display toggles (consumed by the fills below)
i_showRsiBg   = input.bool(true, "Show Band Background", group="RSI Settings", inline="rbg")
i_rsiBgCol    = input.color(#7E57C2, "", group="RSI Settings", inline="rbg")
i_rsiBgTransp = input.int(90, "", minval=0, maxval=100, group="RSI Settings", inline="rbg", tooltip="The fill between the 70 and 30 bands: toggle · color · transparency (0 = opaque, 100 = invisible). Defaults reproduce the stock purple at 90 transparency. This transparency field always overrides any opacity set inside the color picker.")
i_showGrad  = input.bool(true, "Show OB/OS Gradients", group="RSI Settings", tooltip="Green shading above 70 and red shading below 30 on the RSI line.")

change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color = i_showRsiBg ? color.new(i_rsiBgCol, i_rsiBgTransp) : na, title="RSI Background Fill", display = i_showRsiBg ? display.all : display.none)
midLinePlot = plot(50, color=na, editable=false, display=display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color = i_showGrad ? color.new(color.green, 0) : na, bottom_color = i_showGrad ? color.new(color.green, 100) : na, title="Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30, 0, top_color = i_showGrad ? color.new(color.red, 100) : na, bottom_color = i_showGrad ? color.new(color.red, 0) : na, title="Oversold Gradient Fill")

// ===================== SMOOTHING MA (BASE) ==========================
GRP = "Moving Average"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("None", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.data_window, tooltip="Preserved from the base RSI. Defaulted OFF so the line doesn't clutter divergence markers — set to SMA to restore stock behavior.")
maLengthInput = input.int(14, "Length", group = GRP, display = display.data_window)
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.data_window)
enableMA = maTypeInput != "None"
isBB = maTypeInput == "SMA + Bollinger Bands"

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)
        => na

smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(smoothingMA, "RSI-based MA", color=color.yellow, display = enableMA ? display.all : display.none)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none)

// =========================== INPUTS (NEW) ===========================
// --- Pivot Detection (on the RSI — the source of truth) ---
i_lbL = input.int(5, "Pivot Lookback Left",  minval=1, group="Pivot Detection", inline="lb")
i_lbR = input.int(5, "Pivot Lookback Right", minval=1, group="Pivot Detection", inline="lb", tooltip="Bars each side that define an RSI swing. Signal confirms this many bars after the pivot (honest lag). HRN parity ≈ 3.")

// --- Range Gate ---
i_rangeLower = input.int(5,  "Min Bars Between Pivots", minval=1, group="Range Gate", inline="rg")
i_rangeUpper = input.int(60, "Max Bars Between Pivots", minval=2, group="Range Gate", inline="rg")

// --- Divergence Types ---
i_showRegBull = input.bool(true, "Regular Bullish", group="Divergence Types", inline="t1")
i_showRegBear = input.bool(true, "Regular Bearish", group="Divergence Types", inline="t1")
i_showHidBull = input.bool(true, "Hidden Bullish",  group="Divergence Types", inline="t2")
i_showHidBear = input.bool(true, "Hidden Bearish",  group="Divergence Types", inline="t2")

// --- Divergence Lines ---
i_drawRsi   = input.bool(true, "Draw on RSI Pane",    group="Divergence Lines", inline="dr")
i_drawPrice = input.bool(true, "Draw on Price Chart", group="Divergence Lines", inline="dr")
i_maxDiv    = input.int(60, "Max Divergences Kept", minval=5, maxval=100, group="Divergence Lines", tooltip="Oldest lines/tags removed beyond this (Pine object limit). Note: with projection ON each divergence can use up to 4 lines — keep total lines (divs + pivot marks) under 500. Drawing caps never affect the outcome statistics. Outcome Paint only repaints drawings still on the chart — a trimmed drawing is simply skipped.")

// --- Line Projection & Fade ---
i_projDiv  = input.bool(false, "Project Divergence Line", group="Line Projection & Fade", inline="pj", tooltip="Extends the divergence line forward as a dotted ray — a live reference for where the trajectory points. Default off to keep the chart clean. Appearance is set in 'Projection Line Style'.")
i_projLen  = input.int(15, "Bars", minval=1, maxval=200, group="Line Projection & Fade", inline="pj")
i_fadeOld  = input.bool(false, "Fade Older Divergences", group="Line Projection & Fade", inline="fd", tooltip="Progressively increases transparency on older divergence lines so the newest stands out. Ramps UP from each line's resting transparency (set per type / per projection). Applies to lines only (not pivot marks or tags). Divergences already painted by Outcome Paint are exempt — their result color is frozen.")
i_fadeStep = input.int(3, "Step", minval=0, maxval=20, group="Line Projection & Fade", inline="fd")
i_fadeMax  = input.int(65, "Max", minval=0, maxval=100, group="Line Projection & Fade", tooltip="Transparency ceiling for the oldest lines (0 = opaque, 100 = invisible). If a line's resting transparency already exceeds this, it stays at its resting value.")

// --- Divergence Line Style (per type: color | style | width | transparency) ---
i_colRegBull = input.color(color.white, "Regular Bullish", group="Divergence Line Style", inline="srb")
i_styRegBull = input.string("Dotted", "", options=["Solid","Dashed","Dotted"], group="Divergence Line Style", inline="srb")
i_wRegBull   = input.int(1, "", minval=1, maxval=5, group="Divergence Line Style", inline="srb")
i_tRegBull   = input.int(0, "", minval=0, maxval=100, group="Divergence Line Style", inline="srb", tooltip="Regular Bullish line, four columns: color · style · width (1–5) · transparency (0=opaque, 100=invisible). Transparency here is the resting opacity; 'Fade Older Divergences' ramps up from it.")
i_colRegBear = input.color(color.white, "Regular Bearish", group="Divergence Line Style", inline="srbe")
i_styRegBear = input.string("Dotted", "", options=["Solid","Dashed","Dotted"], group="Divergence Line Style", inline="srbe")
i_wRegBear   = input.int(1, "", minval=1, maxval=5, group="Divergence Line Style", inline="srbe")
i_tRegBear   = input.int(0, "", minval=0, maxval=100, group="Divergence Line Style", inline="srbe", tooltip="Regular Bearish line: color · style · width · transparency.")
i_colHidBull = input.color(color.white, "Hidden Bullish",  group="Divergence Line Style", inline="shb")
i_styHidBull = input.string("Dotted", "", options=["Solid","Dashed","Dotted"], group="Divergence Line Style", inline="shb")
i_wHidBull   = input.int(1, "", minval=1, maxval=5, group="Divergence Line Style", inline="shb")
i_tHidBull   = input.int(0, "", minval=0, maxval=100, group="Divergence Line Style", inline="shb", tooltip="Hidden Bullish line: color · style · width · transparency.")
i_colHidBear = input.color(color.white, "Hidden Bearish",  group="Divergence Line Style", inline="shbe")
i_styHidBear = input.string("Dotted", "", options=["Solid","Dashed","Dotted"], group="Divergence Line Style", inline="shbe")
i_wHidBear   = input.int(1, "", minval=1, maxval=5, group="Divergence Line Style", inline="shbe")
i_tHidBear   = input.int(0, "", minval=0, maxval=100, group="Divergence Line Style", inline="shbe", tooltip="Hidden Bearish line: color · style · width · transparency.")

// --- Projection Line Style (applies when projection is on) ---
i_projColorSrc = input.string("Inherit from Divergence", "Color Source", options=["Inherit from Divergence","Custom Color"], group="Projection Line Style", tooltip="Inherit = each projection uses its divergence type's color. Custom = one color for all projections.")
i_projColor    = input.color(color.gray, "Custom Color", group="Projection Line Style", tooltip="Used only when Color Source = Custom Color.")
i_projStyle    = input.string("Dotted", "Style", options=["Solid","Dashed","Dotted"], group="Projection Line Style", inline="ps")
i_projW        = input.int(1, "Width", minval=1, maxval=5, group="Projection Line Style", inline="ps")
i_projTransp   = input.int(55, "Transp", minval=0, maxval=100, group="Projection Line Style", inline="ps", tooltip="Projection line: style · width · transparency (0=opaque, 100=invisible). Only applies when 'Project Divergence Line' is on.")

// --- Info Tags ---
i_showLblRsi   = input.bool(true, "Tags on RSI Pane",    group="Info Tags", inline="lbl")
i_showLblPrice = input.bool(true, "Tags on Price Chart", group="Info Tags", inline="lbl", tooltip="Toggle the divergence tags on each pane independently. Decoupled from the lines — you can draw a line on one pane and place the tag on the other. Hover any tag for full detail.")
i_tagStyle     = input.string("Bubble", "Tag Style", options=["Bubble","Text Only"], group="Info Tags", tooltip="'Bubble' = colored callout box. 'Text Only' = floating text with no background box.")
i_tagDetail    = input.bool(false, "Detailed Tag Text", group="Info Tags", tooltip="Off = short label (Bull / Bear). On = adds RSI Δ and price % onto the tag face, e.g. 'Bull  +4.2 / -1.8%'.")
i_tagSize      = input.string("Tiny", "Tag Size", options=["Tiny","Small","Normal","Large"], group="Info Tags")

// --- RSI Pivot Markers (simple line ticks on the RSI) ---
i_showRsiPiv  = input.bool(true, "Show RSI Pivots", group="RSI Pivot Markers")
i_rsiPivHi    = input.color(color.white, "High", group="RSI Pivot Markers", inline="rp")
i_rsiPivLo    = input.color(color.white, "Low",  group="RSI Pivot Markers", inline="rp")
i_rsiMarkStyle= input.string("Dotted", "Style", options=["Solid","Dashed","Dotted"], group="RSI Pivot Markers")
i_rsiMarkW    = input.int(1, "Thickness", minval=1, maxval=5, group="RSI Pivot Markers", inline="rpw")
i_rsiMarkLen  = input.int(1, "Length (bars)", minval=1, maxval=10, group="RSI Pivot Markers", inline="rpw", tooltip="Half-length each side of the pivot. 1 = a small 3-bar tick.")
i_maxMarks    = input.int(80, "Max Marks Kept", minval=10, group="RSI Pivot Markers", tooltip="Caps RSI and price pivot marks (each) to respect Pine's line limit.")

// --- Price Pivot Markers (simple line ticks on the candles) ---
i_showPxPiv  = input.bool(true, "Show Price Pivots", group="Price Pivot Markers")
i_pxPivHi    = input.color(color.white, "High", group="Price Pivot Markers", inline="pp")
i_pxPivLo    = input.color(color.white, "Low",  group="Price Pivot Markers", inline="pp")
i_pxMarkStyle= input.string("Dotted", "Style", options=["Solid","Dashed","Dotted"], group="Price Pivot Markers")
i_pxMarkW    = input.int(1, "Thickness", minval=1, maxval=5, group="Price Pivot Markers", inline="ppw")
i_pxMarkLen  = input.int(1, "Length (bars)", minval=1, maxval=10, group="Price Pivot Markers", inline="ppw", tooltip="Half-length each side of the pivot. 1 = a small 3-bar tick.")

// --- Outcome Tracking ---
i_trackOutcome = input.bool(true, "Track Divergence Outcomes", group="Outcome Tracking", tooltip="After each divergence, simulates a bracket (ATR target vs ATR stop) from the confirmation-bar close and tallies win rate + expectancy per type on the current symbol/timeframe. Gap-aware: a bar opening beyond the stop/target fills at the open (realistic slippage on gaps). Stops are checked before targets on a same-bar tie (conservative). N counts resolved trades only; open trades show in the header.")
i_atrLen   = input.int(14, "ATR Length", minval=1, group="Outcome Tracking", inline="oc1")
i_tgtMult  = input.float(2.0, "Target ×ATR", minval=0.1, step=0.1, group="Outcome Tracking", inline="oc1")
i_stopMult = input.float(1.0, "Stop ×ATR", minval=0.1, step=0.1, group="Outcome Tracking", inline="oc2")
i_horizon  = input.int(20, "Horizon (bars)", minval=1, group="Outcome Tracking", inline="oc2", tooltip="Bars allowed to hit target or stop before the trade resolves at market. Expiry counts as a win only if marked R > 0; flat expiry is a loss.")
i_showOutTbl = input.bool(true, "Show Outcome Table", group="Outcome Tracking")
i_outTblPos  = input.string("Bottom Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group="Outcome Tracking")
i_showCI = input.bool(true, "Wilson 95% CI on Win%", group="Outcome Tracking", inline="st")
i_starOn = input.bool(true, "★ vs Breakeven", group="Outcome Tracking", inline="st", tooltip="CI: Win% cells show ± the Wilson 95% half-width — a 58% on N=8 and N=80 stop looking alike. ★: awarded when the EXACT Wilson lower bound clears the bracket's breakeven win rate (stop ÷ (stop + target)) — the type's edge is statistically distinguishable from chance at 95%. Hover any Win% cell for the exact interval. Same math as the Setup Expectancy Lab. Caveat: the CI assumes independent trades; overlapping open positions weaken it somewhat.")
i_showRecent = input.bool(true, "Recent Row", group="Outcome Tracking", inline="rc")
i_recentK    = input.int(20, "", minval=5, maxval=200, group="Outcome Tracking", inline="rc", tooltip="Rolling window: Win% and Exp R over the last K resolved trades, pooled across all four divergence types. Compare against All to make edge decay (or improvement) visible. Exempt from Min-N dimming — its small sample is by design; the CI carries the honesty. The row's tooltip shows the window's median R (gap-robust where the mean isn't).")
i_minN   = input.int(20, "Min N (dim below)", minval=1, group="Outcome Tracking", tooltip="Type rows with fewer resolved trades than this render dimmed, and Exp R stays uncolored — small samples should LOOK like noise. Default 20 (vs the Lab's 30) because four types split one chart's sample; the CI still carries the honesty. The Recent row is exempt (small by design).")

// --- Outcome Paint ---
i_paintMode = input.string("Off", "Paint Resolved Divergences", options=["Off","Win / Loss Recolor","Type Color, Dim Losers"], group="Outcome Paint", tooltip="Restyles a divergence's lines (and projections) when its simulated bracket resolves — the chart becomes its own scoreboard. OFF (default): rendering identical to before. WIN/LOSS RECOLOR: winners and losers take the two colors below, keeping each line's resting transparency (projections stay lighter). TYPE COLOR, DIM LOSERS: winners freeze at full type color, losers dim to the transparency below. Open (unresolved) trades always render normally until they resolve. Requires 'Track Divergence Outcomes' ON. Only affects drawings still on the chart — nothing is redrawn for trimmed history.")
i_paintWinCol  = input.color(color.green, "Win", group="Outcome Paint", inline="pc")
i_paintLossCol = input.color(color.red,   "Loss", group="Outcome Paint", inline="pc", tooltip="Colors used by 'Win / Loss Recolor' mode.")
i_paintDimT    = input.int(75, "Loser Dim Transparency", minval=0, maxval=100, group="Outcome Paint", tooltip="Used by 'Type Color, Dim Losers' mode: losing divergences fade to this transparency (never below a line's own resting transparency, so dimming can't brighten a projection). 0 = opaque, 100 = invisible.")
i_outcomeTag   = input.bool(false, "Tag Outcome Suffix (✓ / ✗)", group="Outcome Paint", tooltip="Appends a win/loss mark to the divergence's tags when its bracket resolves, and turns the tag tooltip into a full audit record: the result (R multiple, bars to resolution), HOW it resolved (stop hit / target hit / gap fill with the actual price / horizon expiry), and the Entry, Stop, and Target prices — with entry stated as pivot + N bars, since entry is the confirmation close, not the pivot. Independent of the line paint mode, so the scoreboard reading survives even with lines hidden. Requires 'Track Divergence Outcomes' ON. Mark appearance is set by 'Outcome Mark Style' below.")
i_outMarkStyle = input.string("Colored ✅ / ❌", "Outcome Mark Style", options=["Colored ✅ / ❌","Minimal ✓ / ✗ (tag color)"], group="Outcome Paint", tooltip="Style of the win/loss mark appended to tags. COLORED: emoji marks that render green (win) and red (loss) on their own — a Pine label carries a single text color, so this is the only way the mark can differ from the tag's type color. Emoji render slightly bolder than text glyphs. MINIMAL: the thin ✓ / ✗ glyphs in the tag's own color (the v1.1 look). Only applies when 'Tag Outcome Suffix' is on.")

// --- Table Flash ---
i_flashOn   = input.bool(true, "Flash Tables on New Divergence", group="Table Flash", tooltip="Tints both tables' backgrounds for a set number of bars after a divergence confirms — green for bullish (Regular/Hidden Bull), red for bearish. Timed from the confirmation bar, not the pivot bar, so the full duration is visible.")
i_flashBars = input.int(5, "Flash Duration (bars)", minval=1, maxval=50, group="Table Flash")
i_flashBull = input.color(color.new(color.green, 55), "Bull", group="Table Flash", inline="fc")
i_flashBear = input.color(color.new(color.red, 55),  "Bear", group="Table Flash", inline="fc", tooltip="Flash tint colors. Keep some transparency so table text stays readable.")

// --- Alerts ---
i_dynAlerts = input.bool(true, "Dynamic alert() Payload", group="Alerts", tooltip="In addition to the five named alertcondition triggers, fires one 'Any alert() function call' alert carrying live details (type, RSI from→to, price from→to, bars apart). Create an alert on 'Any alert() function call' to receive it.")

// --- Info Table ---
i_showTable = input.bool(true, "Show Table", group="Info Table")
i_tblPos    = input.string("Top Right", "Position", options=["Top Left","Top Center","Top Right","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group="Info Table")
i_tblBg     = input.color(color.new(color.black, 70), "BG",   group="Info Table", inline="tc")
i_tblTxt    = input.color(color.white, "Text", group="Info Table", inline="tc")

// ======================== OUTCOME STATS =============================
bool  paintOn = i_paintMode != "Off"
float beRate  = i_stopMult / (i_stopMult + i_tgtMult)   // breakeven win rate for the bracket

// Returns [cellText, starred, tooltip]. Cell shows raw Win% ± Wilson
// half-width (approximate — the true interval is asymmetric at small N);
// the tooltip carries the EXACT bounds, and the ★ always uses the exact
// lower bound vs breakeven. Honest at a glance, exact one hover away.
winStats(int w, int n) =>
    string txt = "—"
    bool star = false
    string tip = ""
    if n > 0
        float praw = float(w) / float(n) * 100.0
        [c, h] = wilsonCI(w, n)
        float loP = math.max(0.0, (c - h) * 100.0)
        float hiP = math.min(100.0, (c + h) * 100.0)
        txt := str.tostring(praw, "0")
        if i_showCI
            txt += "±" + str.tostring(h * 100.0, "0")
        star := i_starOn and (c - h) > beRate
        if star
            txt += "★"
        tip := "Wilson 95% CI: " + str.tostring(loP, "0") + "–" + str.tostring(hiP, "0") + "%." + (star ? " Lower bound clears breakeven (" + str.tostring(beRate * 100.0, "0.0") + "%) — edge distinguishable from chance at 95%." : "")
    [txt, star, tip]

// ===================== PIVOTS ON RSI (anchor) =======================
float plRsi = ta.pivotlow(rsi,  i_lbL, i_lbR)
float phRsi = ta.pivothigh(rsi, i_lbL, i_lbR)
bool plFound = not na(plRsi)
bool phFound = not na(phRsi)
float atrVal = ta.atr(i_atrLen)

// ================================ STATE =============================
var array<line>  divLines   = array.new<line>()
var array<color> divCols    = array.new<color>()
var array<int>   divLineSer = array.new<int>()   // serial of the divergence each line belongs to
var array<int>   divLineStat= array.new<int>()   // 0 = open/none, 1 = win, 2 = loss (fade exemption)
var array<label> divLabels  = array.new<label>()
var array<int>   divLabelSer= array.new<int>()   // serial per tag
var array<string>divLabelTxt= array.new<string>()// base tag text (suffix is rebuilt from this)
var array<string>divLabelTip= array.new<string>()// base tag tooltip (outcome detail appended)
var array<line>  rsiMarks  = array.new<line>()
var array<line>  pxMarks   = array.new<line>()

// outcome tracking pools — 9 parallel arrays; push/remove in lockstep
var array<int>   pendType = array.new<int>()
var array<int>   pendDir  = array.new<int>()
var array<float> pendEntry= array.new<float>()
var array<float> pendTgt  = array.new<float>()
var array<float> pendStop = array.new<float>()
var array<float> pendRisk = array.new<float>()
var array<int>   pendDL   = array.new<int>()
var array<int>   pendSer  = array.new<int>()     // divergence serial (links trade → drawings)
var array<int>   pendBar  = array.new<int>()     // entry bar (bars-to-resolution readout)
var array<int>   winCnt   = array.from(0, 0, 0, 0)
var array<int>   totCnt   = array.from(0, 0, 0, 0)
var array<float> sumR     = array.from(0.0, 0.0, 0.0, 0.0)

// v1.2: master list of resolved R values in resolution order (Recent
// row + medians). Soft cap 4000 — beyond any realistic chart output;
// shift keeps it bounded. Per-type statistics are never trimmed.
var array<float> allR = array.new<float>()

var int divSerial = 0                            // monotonically increasing divergence id

var int   prevLoBar = na
var float prevLoRsi = na
var float prevLoPx  = na
var int   prevHiBar = na
var float prevHiRsi = na
var float prevHiPx  = na

var string lastDiv    = "—"
var int    lastDivBar = na          // pivot bar of the last divergence (for the age readout)
var color  lastDivCol = color.gray
var int    lastSigBar = na          // confirmation bar of the last divergence (for flash timing)
var int    lastDivDir = 0           // +1 bullish, -1 bearish

bool sigRegBull = false
bool sigRegBear = false
bool sigHidBull = false
bool sigHidBear = false

// ============================ POOL HELPERS ==========================
pushDivLine(line ln, color baseCol, int ser) =>
    array.push(divLines, ln)
    array.push(divCols, baseCol)
    array.push(divLineSer, ser)
    array.push(divLineStat, 0)
    while array.size(divLines) > i_maxDiv * 4
        line.delete(array.shift(divLines))
        array.shift(divCols)
        array.shift(divLineSer)
        array.shift(divLineStat)

pushDivLabel(label lb, int ser, string txt, string tip) =>
    array.push(divLabels, lb)
    array.push(divLabelSer, ser)
    array.push(divLabelTxt, txt)
    array.push(divLabelTip, tip)
    while array.size(divLabels) > i_maxDiv * 2
        label.delete(array.shift(divLabels))
        array.shift(divLabelSer)
        array.shift(divLabelTxt)
        array.shift(divLabelTip)

// Fade ramps UP from each line's own resting transparency toward i_fadeMax.
// Outcome-painted lines (stat != 0 while a paint mode is active) are frozen.
applyFade() =>
    if i_fadeOld
        int n = array.size(divLines)
        if n > 0
            for i = 0 to n - 1
                if not (paintOn and array.get(divLineStat, i) != 0)
                    color baseCol = array.get(divCols, i)
                    int baseT = int(color.t(baseCol))
                    int ageRank = n - 1 - i
                    int capT = int(math.max(baseT, i_fadeMax))
                    int t = int(math.min(baseT + ageRank * i_fadeStep, capT))
                    line.set_color(array.get(divLines, i), color.new(baseCol, t))

// ======================= OUTCOME PAINT HELPERS ======================
// Pool-scan painting: only drawings still IN the pools are touched, so a
// reference to a trimmed (deleted) object can never be used — the hazard
// is removed by construction, not guarded. Serials are plain ints.
paintDivLines(int ser, bool win) =>
    int n = array.size(divLines)
    if n > 0
        for i = 0 to n - 1
            if array.get(divLineSer, i) == ser
                array.set(divLineStat, i, win ? 1 : 2)
                line  ln      = array.get(divLines, i)
                color baseCol = array.get(divCols, i)
                int   baseT   = int(color.t(baseCol))
                if i_paintMode == "Win / Loss Recolor"
                    line.set_color(ln, color.new(win ? i_paintWinCol : i_paintLossCol, baseT))
                else if win
                    line.set_color(ln, baseCol)                       // freeze at resting look
                else
                    int dimT = int(math.max(baseT, i_paintDimT))       // dim never brightens
                    line.set_color(ln, color.new(baseCol, dimT))

// v1.1.2: the outcome tooltip is a full audit record — result, HOW the
// bracket resolved (with actual fill prices on gaps/expiry), and the
// Entry / Stop / Target prices with the pivot→entry offset stated, so
// the mark's position (at the pivot) can never mislead about the trade
// (entered i_lbR bars later). The record is built ONCE per resolution,
// then appended to each stored base tooltip during the pool scan.
tagDivOutcome(int ser, bool win, float rR, int nBars, float e, float st, float tg, string how) =>
    bool coloredMk = i_outMarkStyle == "Colored ✅ / ❌"
    string mk = win ? (coloredMk ? " ✅" : " ✓") : (coloredMk ? " ❌" : " ✗")
    string outTip = "\nOutcome: " + (win ? "WIN " : "LOSS ") + (rR >= 0 ? "+" : "") + str.tostring(rR, "0.00") + "R in " + str.tostring(nBars) + " bars — " + how + "\nEntry: " + str.tostring(e, format.mintick) + " (pivot +" + str.tostring(i_lbR) + " bars) · Stop: " + str.tostring(st, format.mintick) + " · Target: " + str.tostring(tg, format.mintick)
    int n = array.size(divLabels)
    if n > 0
        for i = 0 to n - 1
            if array.get(divLabelSer, i) == ser
                label lb = array.get(divLabels, i)
                label.set_text(lb, array.get(divLabelTxt, i) + mk)
                label.set_tooltip(lb, array.get(divLabelTip, i) + outTip)

// ============================ MARK HELPERS ==========================
// Discreet horizontal line ticks centered on the pivot bar (sit on the curve/candle).
addRsiMark(int b, float y, bool isHigh) =>
    if i_showRsiPiv
        col = isHigh ? i_rsiPivHi : i_rsiPivLo
        int x2 = b + i_rsiMarkLen > bar_index ? bar_index : b + i_rsiMarkLen
        ln = line.new(b - i_rsiMarkLen, y, x2, y, xloc=xloc.bar_index, color=col, width=i_rsiMarkW, style=getLineStyle(i_rsiMarkStyle))
        array.push(rsiMarks, ln)
        while array.size(rsiMarks) > i_maxMarks
            line.delete(array.shift(rsiMarks))

addPxMark(int b, float y, bool isHigh) =>
    if i_showPxPiv
        col = isHigh ? i_pxPivHi : i_pxPivLo
        int x2 = b + i_pxMarkLen > bar_index ? bar_index : b + i_pxMarkLen
        ln = line.new(b - i_pxMarkLen, y, x2, y, xloc=xloc.bar_index, color=col, width=i_pxMarkW, style=getLineStyle(i_pxMarkStyle), force_overlay=true)
        array.push(pxMarks, ln)
        while array.size(pxMarks) > i_maxMarks
            line.delete(array.shift(pxMarks))

// ========================= OUTCOME HELPER ===========================
// typ: 0 RegBull, 1 HidBull, 2 RegBear, 3 HidBear ; dir: +1 bull / -1 bear
recordOutcome(int typ, int dir, int ser) =>
    if i_trackOutcome and not na(atrVal) and atrVal > 0
        float e  = close
        float rk = i_stopMult * atrVal
        float tg = dir > 0 ? e + i_tgtMult * atrVal : e - i_tgtMult * atrVal
        float st = dir > 0 ? e - i_stopMult * atrVal : e + i_stopMult * atrVal
        array.push(pendType, typ)
        array.push(pendDir, dir)
        array.push(pendEntry, e)
        array.push(pendTgt, tg)
        array.push(pendStop, st)
        array.push(pendRisk, rk)
        array.push(pendDL, bar_index + i_horizon)
        array.push(pendSer, ser)
        array.push(pendBar, bar_index)

// ============================ DRAW HELPER ===========================
// x = the RSI-pivot bar (shared by both panes); rsi*/px* = on-curve / on-candle values
// col = raw per-type color ; transp = per-type resting transparency ; ser = divergence id
drawDiv(int x1, int x2, float rsi1, float rsi2, float px1, float px2, color col, string styStr, int w, int transp, string tagShort, string tagFull, bool isLow, int ser) =>
    sty = getLineStyle(styStr)
    lblStyle = isLow ? label.style_label_up : label.style_label_down
    int barsApart = x2 - x1
    // resolved colors
    color lineCol = color.new(col, transp)
    bool projInherit = i_projColorSrc == "Inherit from Divergence"
    color projBase = projInherit ? col : i_projColor
    color projCol = color.new(projBase, i_projTransp)
    projStyleV = getLineStyle(i_projStyle)
    // tag content + tooltip
    float rsiDelta = rsi2 - rsi1
    float pxPct = px1 != 0 ? (px2 - px1) / px1 * 100 : 0
    string rsiDStr = (rsiDelta >= 0 ? "+" : "") + str.tostring(rsiDelta, "0.0")
    string pxDStr  = (pxPct  >= 0 ? "+" : "") + str.tostring(pxPct, "0.0")
    string tagText = i_tagDetail ? tagShort + "  " + rsiDStr + " / " + pxDStr + "%" : tagShort
    bool tagFloat = i_tagStyle == "Text Only"
    string tip = tagFull + "\nRSI: " + str.tostring(rsi1, "0.0") + " → " + str.tostring(rsi2, "0.0") + "\nPrice: " + str.tostring(px1, format.mintick) + " → " + str.tostring(px2, format.mintick) + "\nBars apart: " + str.tostring(barsApart) + "\nConfirm pivot vs 50: " + str.tostring(rsi2, "0.0") + (rsi2 >= 50 ? " (above)" : " (below)")
    // RSI pane line + projection
    if i_drawRsi
        ln = line.new(x1, rsi1, x2, rsi2, xloc=xloc.bar_index, color=lineCol, width=w, style=sty)
        pushDivLine(ln, lineCol, ser)
        if i_projDiv
            float slopeR = (x2 - x1) != 0 ? (rsi2 - rsi1) / (x2 - x1) : 0
            pr = line.new(x2, rsi2, x2 + i_projLen, rsi2 + slopeR * i_projLen, xloc=xloc.bar_index, color=projCol, width=i_projW, style=projStyleV)
            pushDivLine(pr, projCol, ser)
    // RSI pane tag (independent of the line)
    if i_showLblRsi
        lb = label.new(x2, rsi2, tagText, xloc=xloc.bar_index, style = tagFloat ? label.style_none : lblStyle, color = tagFloat ? na : color.new(col, 80), textcolor=col, size=getSize(i_tagSize), tooltip=tip)
        pushDivLabel(lb, ser, tagText, tip)
    // Price line + projection
    if i_drawPrice
        lp = line.new(x1, px1, x2, px2, xloc=xloc.bar_index, color=lineCol, width=w, style=sty, force_overlay=true)
        pushDivLine(lp, lineCol, ser)
        if i_projDiv
            float slopeP = (x2 - x1) != 0 ? (px2 - px1) / (x2 - x1) : 0
            pp = line.new(x2, px2, x2 + i_projLen, px2 + slopeP * i_projLen, xloc=xloc.bar_index, color=projCol, width=i_projW, style=projStyleV, force_overlay=true)
            pushDivLine(pp, projCol, ser)
    // Price tag (independent of the line)
    if i_showLblPrice
        lbp = label.new(x2, px2, tagText, xloc=xloc.bar_index, style = tagFloat ? label.style_none : lblStyle, color = tagFloat ? na : color.new(col, 80), textcolor=col, size=getSize(i_tagSize), tooltip=tip, force_overlay=true)
        pushDivLabel(lbp, ser, tagText, tip)
    // dynamic alert with live payload
    if i_dynAlerts
        string amsg = syminfo.ticker + " " + timeframe.period + " " + tagFull + " | RSI " + str.tostring(rsi1, "0.0") + "->" + str.tostring(rsi2, "0.0") + " | Px " + str.tostring(px1, format.mintick) + "->" + str.tostring(px2, format.mintick) + " | " + str.tostring(barsApart) + " bars"
        alert(amsg, alert.freq_once_per_bar_close)
    // freshness fade across the whole line pool
    applyFade()

// ===================== OUTCOME RESOLUTION (before detection) ========
// Resolve on confirmed bars; a record created this bar is not evaluated until the next.
// Gap-aware: a bar OPENING beyond the stop/target fills at the open (worse than the stop
// on gap-down losses, better than the target on gap-up wins). Intrabar touches fill at
// the bracket price. Stop is checked before target on a same-bar tie (conservative).
// On resolution, the divergence's drawings are painted/tagged by serial (pool scan).
// how codes: 1 gap-through-stop · 2 gap-through-target · 3 stop hit · 4 target hit · 5 expiry
if i_trackOutcome and barstate.isconfirmed and array.size(pendType) > 0
    for i = array.size(pendType) - 1 to 0
        int   typ = array.get(pendType, i)
        int   dir = array.get(pendDir, i)
        float e   = array.get(pendEntry, i)
        float tg  = array.get(pendTgt, i)
        float st  = array.get(pendStop, i)
        float rk  = array.get(pendRisk, i)
        int   dl  = array.get(pendDL, i)
        int   ser = array.get(pendSer, i)
        int   eb  = array.get(pendBar, i)
        bool resolved = false
        bool win = false
        float rR = na
        int how = 0
        if dir > 0
            if open <= st                      // gapped through stop → fill at open
                resolved := true
                win := false
                rR := (open - e) / rk
                how := 1
            else if open >= tg                 // gapped through target → fill at open
                resolved := true
                win := true
                rR := (open - e) / rk
                how := 2
            else if low <= st                  // intrabar stop touch (checked first)
                resolved := true
                win := false
                rR := (st - e) / rk
                how := 3
            else if high >= tg                 // intrabar target touch
                resolved := true
                win := true
                rR := (tg - e) / rk
                how := 4
        else
            if open >= st                      // gapped through stop → fill at open
                resolved := true
                win := false
                rR := (e - open) / rk
                how := 1
            else if open <= tg                 // gapped through target → fill at open
                resolved := true
                win := true
                rR := (e - open) / rk
                how := 2
            else if high >= st                 // intrabar stop touch (checked first)
                resolved := true
                win := false
                rR := (e - st) / rk
                how := 3
            else if low <= tg                  // intrabar target touch
                resolved := true
                win := true
                rR := (e - tg) / rk
                how := 4
        if not resolved and bar_index >= dl    // horizon expiry → mark to close
            resolved := true
            rR := dir > 0 ? (close - e) / rk : (e - close) / rk
            win := rR > 0
            how := 5
        if resolved
            array.set(totCnt, typ, array.get(totCnt, typ) + 1)
            array.set(sumR, typ, array.get(sumR, typ) + rR)
            if win
                array.set(winCnt, typ, array.get(winCnt, typ) + 1)
            // v1.2: master R list feeds the Recent row and the medians
            array.push(allR, rR)
            if array.size(allR) > 4000
                array.shift(allR)
            if paintOn
                paintDivLines(ser, win)
            if i_outcomeTag
                string howStr = how == 1 ? "gapped through the stop, filled at " + str.tostring(open, format.mintick) : how == 2 ? "gapped through the target, filled at " + str.tostring(open, format.mintick) : how == 3 ? "stop hit" : how == 4 ? "target hit" : "horizon expiry, marked to close at " + str.tostring(close, format.mintick)
                tagDivOutcome(ser, win, rR, bar_index - eb, e, st, tg, howStr)
            array.remove(pendType, i)
            array.remove(pendDir, i)
            array.remove(pendEntry, i)
            array.remove(pendTgt, i)
            array.remove(pendStop, i)
            array.remove(pendRisk, i)
            array.remove(pendDL, i)
            array.remove(pendSer, i)
            array.remove(pendBar, i)

// ===================== LOWS: Reg Bull / Hid Bull ====================
if plFound
    int   curBar = bar_index - i_lbR
    float curRsi = plRsi
    float curPx  = low[i_lbR]
    addRsiMark(curBar, curRsi, false)
    addPxMark(curBar, curPx, false)
    if not na(prevLoBar)
        int dist = curBar - prevLoBar
        bool inRange = dist >= i_rangeLower and dist <= i_rangeUpper
        if inRange
            // Regular bullish: price Lower Low + RSI Higher Low
            if i_showRegBull and curPx < prevLoPx and curRsi > prevLoRsi
                sigRegBull := true
                lastDiv := "Reg Bull"
                lastDivBar := curBar
                lastDivCol := i_colRegBull
                lastSigBar := bar_index
                lastDivDir := 1
                divSerial += 1
                drawDiv(prevLoBar, curBar, prevLoRsi, curRsi, prevLoPx, curPx, i_colRegBull, i_styRegBull, i_wRegBull, i_tRegBull, "Bull", "Regular Bullish", true, divSerial)
                recordOutcome(0, 1, divSerial)
            // Hidden bullish: price Higher Low + RSI Lower Low
            if i_showHidBull and curPx > prevLoPx and curRsi < prevLoRsi
                sigHidBull := true
                lastDiv := "Hid Bull"
                lastDivBar := curBar
                lastDivCol := i_colHidBull
                lastSigBar := bar_index
                lastDivDir := 1
                divSerial += 1
                drawDiv(prevLoBar, curBar, prevLoRsi, curRsi, prevLoPx, curPx, i_colHidBull, i_styHidBull, i_wHidBull, i_tHidBull, "H Bull", "Hidden Bullish", true, divSerial)
                recordOutcome(1, 1, divSerial)
    prevLoBar := curBar
    prevLoRsi := curRsi
    prevLoPx  := curPx

// ==================== HIGHS: Reg Bear / Hid Bear ====================
if phFound
    int   curBar = bar_index - i_lbR
    float curRsi = phRsi
    float curPx  = high[i_lbR]
    addRsiMark(curBar, curRsi, true)
    addPxMark(curBar, curPx, true)
    if not na(prevHiBar)
        int dist = curBar - prevHiBar
        bool inRange = dist >= i_rangeLower and dist <= i_rangeUpper
        if inRange
            // Regular bearish: price Higher High + RSI Lower High
            if i_showRegBear and curPx > prevHiPx and curRsi < prevHiRsi
                sigRegBear := true
                lastDiv := "Reg Bear"
                lastDivBar := curBar
                lastDivCol := i_colRegBear
                lastSigBar := bar_index
                lastDivDir := -1
                divSerial += 1
                drawDiv(prevHiBar, curBar, prevHiRsi, curRsi, prevHiPx, curPx, i_colRegBear, i_styRegBear, i_wRegBear, i_tRegBear, "Bear", "Regular Bearish", false, divSerial)
                recordOutcome(2, -1, divSerial)
            // Hidden bearish: price Lower High + RSI Higher High
            if i_showHidBear and curPx < prevHiPx and curRsi > prevHiRsi
                sigHidBear := true
                lastDiv := "Hid Bear"
                lastDivBar := curBar
                lastDivCol := i_colHidBear
                lastSigBar := bar_index
                lastDivDir := -1
                divSerial += 1
                drawDiv(prevHiBar, curBar, prevHiRsi, curRsi, prevHiPx, curPx, i_colHidBear, i_styHidBear, i_wHidBear, i_tHidBear, "H Bear", "Hidden Bearish", false, divSerial)
                recordOutcome(3, -1, divSerial)
    prevHiBar := curBar
    prevHiRsi := curRsi
    prevHiPx  := curPx

// ====================== EXTERNAL SIGNAL BUS =========================
// Hidden ±1 impulse streams for companion tools (Setup Expectancy Lab).
// +1 = bullish event bar, -1 = bearish, 0 = none.
// Combined streams (Regular/Hidden/Any): if a bull and a bear confirm on
// the SAME bar (two different pivots can share a confirmation bar), the
// stream carries +1 (bull precedence) — the bear event is invisible to a
// consumer. The one-sided streams are LOSSLESS: each side carries its
// full event set with no collision. Use those to monitor all bullish or
// all bearish divergences together, as a lab signal or gate.
plot(sigRegBull ? 1 : sigRegBear ? -1 : 0, "EXT: Regular Divergence", display=display.none)
plot(sigHidBull ? 1 : sigHidBear ? -1 : 0, "EXT: Hidden Divergence",  display=display.none)
plot((sigRegBull or sigHidBull) ? 1 : (sigRegBear or sigHidBear) ? -1 : 0, "EXT: Any Divergence", display=display.none)
plot((sigRegBull or sigHidBull) ? 1 : 0,  "EXT: Any Bullish Div", display=display.none)
plot((sigRegBear or sigHidBear) ? -1 : 0, "EXT: Any Bearish Div", display=display.none)

// =============================== ALERTS =============================
alertcondition(sigRegBull, "Regular Bullish Divergence", "RSI regular bullish divergence confirmed")
alertcondition(sigRegBear, "Regular Bearish Divergence", "RSI regular bearish divergence confirmed")
alertcondition(sigHidBull, "Hidden Bullish Divergence",  "RSI hidden bullish divergence confirmed")
alertcondition(sigHidBear, "Hidden Bearish Divergence",  "RSI hidden bearish divergence confirmed")
alertcondition(sigRegBull or sigRegBear or sigHidBull or sigHidBear, "Any RSI Divergence", "RSI divergence confirmed")

// ======================= TABLE FLASH STATE ==========================
bool  flashActive = i_flashOn and not na(lastSigBar) and (bar_index - lastSigBar) <= i_flashBars
color tblBgNow    = flashActive ? (lastDivDir > 0 ? i_flashBull : i_flashBear) : i_tblBg

// =============================== TABLE ==============================
var table t = table.new(getTablePos(i_tblPos), 2, 6, bgcolor=i_tblBg, border_width=1, border_color=color.new(color.gray, 60))
if i_showTable and barstate.islast
    table.set_bgcolor(t, tblBgNow)
    color rsiCol = rsi >= 50 ? i_colRegBull : i_colRegBear
    string age = na(lastDivBar) ? "" : "  (" + str.tostring(bar_index - lastDivBar) + "b)"
    string biasTxt = rsi >= 50 ? "▲ Above 50" : "▼ Below 50"
    color  biasCol = rsi >= 50 ? color.new(color.green, 0) : color.new(color.red, 0)
    table.cell(t, 0, 0, "RSI Div Pro", text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 1, 0, "",            text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 0, 1, "RSI",     text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(rsi, "0.0"), text_color=rsiCol, text_size=size.small)
    table.cell(t, 0, 2, "Bias",    text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 1, 2, biasTxt,   text_color=biasCol, text_size=size.small)
    table.cell(t, 0, 3, "Last Hi", text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 1, 3, na(prevHiRsi) ? "—" : str.tostring(prevHiRsi, "0.0"), text_color=i_rsiPivHi, text_size=size.small)
    table.cell(t, 0, 4, "Last Lo", text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 1, 4, na(prevLoRsi) ? "—" : str.tostring(prevLoRsi, "0.0"), text_color=i_rsiPivLo, text_size=size.small)
    table.cell(t, 0, 5, "Last Div", text_color=i_tblTxt, text_size=size.small)
    table.cell(t, 1, 5, lastDiv + age, text_color=lastDivCol, text_size=size.small)

// ========================== OUTCOME TABLE ===========================
// v1.2: rows = header + 4 types + All (+ Recent when enabled). Inputs
// are constant per run, so sizing the var table off the toggle is safe.
var table ot = table.new(getTablePos(i_outTblPos), 4, 6 + (i_showRecent ? 1 : 0), bgcolor=i_tblBg, border_width=1, border_color=color.new(color.gray, 60))
if i_trackOutcome and i_showOutTbl and barstate.islast
    table.set_bgcolor(ot, tblBgNow)
    int nPend = array.size(pendType)
    string hdrTxt = "Div Outcome" + (nPend > 0 ? " · " + str.tostring(nPend) + " open" : "")
    string winHdr = i_starOn ? "Win%·BE" + str.tostring(beRate * 100.0, "0") : "Win%"
    table.cell(ot, 0, 0, hdrTxt, text_color=i_tblTxt, text_size=size.small)
    table.cell(ot, 1, 0, "N",    text_color=i_tblTxt, text_size=size.small)
    table.cell(ot, 2, 0, winHdr, text_color=i_tblTxt, text_size=size.small, tooltip="Win rate ± Wilson 95% half-width (approximate — the exact asymmetric interval is in each row's hover). Breakeven for the current bracket = stop ÷ (stop + target) = " + str.tostring(beRate * 100.0, "0.0") + "%. ★ = exact Wilson lower bound clears breakeven: edge statistically distinguishable from chance at 95%. Rows dim below Min N = " + str.tostring(i_minN) + " (the Recent row is exempt). Caveat: assumes independent trades; overlapping open positions weaken the interval somewhat.")
    table.cell(ot, 3, 0, "Exp R",text_color=i_tblTxt, text_size=size.small)
    typeNames = array.from("Reg Bull", "Hid Bull", "Reg Bear", "Hid Bear")
    typeCols  = array.from(i_colRegBull, i_colHidBull, i_colRegBear, i_colHidBear)
    int allN = 0
    int allW = 0
    float allRSum = 0.0
    for ti = 0 to 3
        int n = array.get(totCnt, ti)
        int wn = array.get(winCnt, ti)
        float sr = array.get(sumR, ti)
        allN := allN + n
        allW := allW + wn
        allRSum := allRSum + sr
        bool dim = n < i_minN
        color typeCol = array.get(typeCols, ti)
        color nameCol = dim ? color.new(typeCol, 55) : typeCol
        color numCol  = dim ? color.new(i_tblTxt, 55) : i_tblTxt
        [wTxt, wStar, wTip] = winStats(wn, n)
        color winCol = wStar and not dim ? color.new(color.green, 0) : numCol
        float expv = n > 0 ? sr / n : na
        string expStr = n > 0 ? (expv >= 0 ? "+" : "") + str.tostring(expv, "0.00") : "—"
        color expCol = n > 0 and not dim ? (expv >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : numCol
        table.cell(ot, 0, ti + 1, array.get(typeNames, ti), text_color=nameCol, text_size=size.small)
        table.cell(ot, 1, ti + 1, str.tostring(n), text_color=numCol, text_size=size.small)
        table.cell(ot, 2, ti + 1, wTxt, text_color=winCol, text_size=size.small, tooltip=wTip)
        table.cell(ot, 3, ti + 1, expStr, text_color=expCol, text_size=size.small)
    bool dimAll = allN < i_minN
    color allNumCol = dimAll ? color.new(i_tblTxt, 55) : i_tblTxt
    [aTxt, aStar, aTip] = winStats(allW, allN)
    color allWinCol = aStar and not dimAll ? color.new(color.green, 0) : allNumCol
    float allExp = allN > 0 ? allRSum / allN : na
    string allExpStr = allN > 0 ? (allExp >= 0 ? "+" : "") + str.tostring(allExp, "0.00") : "—"
    color allExpCol = allN > 0 and not dimAll ? (allExp >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : allNumCol
    // v1.2: lifetime median on the All row's name cell (gap-robust)
    int szAllR = array.size(allR)
    float lifeMed = szAllR > 0 ? array.median(allR) : na
    string allNameTip = szAllR > 0 ? "Lifetime median R: " + (lifeMed >= 0 ? "+" : "") + str.tostring(lifeMed, "0.00") + " — robust to gap outliers, unlike the mean." : ""
    table.cell(ot, 0, 5, "All", text_color=i_tblTxt, text_size=size.small, tooltip=allNameTip)
    table.cell(ot, 1, 5, str.tostring(allN), text_color=allNumCol, text_size=size.small)
    table.cell(ot, 2, 5, aTxt, text_color=allWinCol, text_size=size.small, tooltip=aTip)
    table.cell(ot, 3, 5, allExpStr, text_color=allExpCol, text_size=size.small)
    // ---- v1.2: Recent row (rolling last-K, pooled across types) ----
    if i_showRecent
        int kk = math.min(i_recentK, szAllR)
        int recW = 0
        float recMean = na
        float recMed = na
        if kk > 0
            array<float> tailArr = array.new<float>()
            for q = szAllR - kk to szAllR - 1
                float rv = array.get(allR, q)
                array.push(tailArr, rv)
                if rv > 0
                    recW += 1
            recMean := array.avg(tailArr)
            recMed := array.median(tailArr)
        [rTxt, rStar, rTip] = winStats(recW, kk)
        color recWinCol = rStar ? color.new(color.green, 0) : i_tblTxt
        string recExpStr = kk > 0 ? (recMean >= 0 ? "+" : "") + str.tostring(recMean, "0.00") : "—"
        color recExpCol = kk > 0 ? (recMean >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : i_tblTxt
        string recNameTip = kk > 0 ? "Most recent " + str.tostring(kk) + " resolved trades, pooled across all four divergence types. Median R: " + (recMed >= 0 ? "+" : "") + str.tostring(recMed, "0.00") + ". Compare with All to spot edge decay or improvement. Small window by design — the CI carries the uncertainty; exempt from Min-N dimming." : "No resolved trades yet."
        table.cell(ot, 0, 6, "Last " + str.tostring(kk), text_color=i_tblTxt, text_size=size.small, tooltip=recNameTip)
        table.cell(ot, 1, 6, str.tostring(kk), text_color=i_tblTxt, text_size=size.small)
        table.cell(ot, 2, 6, rTxt, text_color=recWinCol, text_size=size.small, tooltip=rTip)
        table.cell(ot, 3, 6, recExpStr, text_color=recExpCol, text_size=size.small)

// === DEBUG (uncomment to verify) ===
// plot(divSerial, "Debug: Divergence Serial", display=display.data_window)
// plot(array.size(pendType), "Debug: Open Simulations", display=display.data_window)
// plot(array.size(allR), "Debug: Resolved Trades (master list)", display=display.data_window)
// plot(beRate * 100, "Debug: Breakeven %", display=display.data_window)
````
