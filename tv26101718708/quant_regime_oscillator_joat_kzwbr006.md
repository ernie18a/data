# Quant Regime Oscillator [JOAT]

- url: https://www.tradingview.com/script/KZwbr006-Quant-Regime-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;ae7704c531764b7faea4f1ba08800986
- version: 1.0

## Description

[b]════════════════════════════════[/b]
[b]QUANT REGIME OSCILLATOR [JOAT][/b]
[b]════════════════════════════════[/b]

A separate-pane composite oscillator that fuses two classic quant signals — how [i]stretched[/i] price is from its own mean, and how [i]strong[/i] its momentum is relative to recent volatility — into a single bounded line from [b]-100 to +100[/b]. A Kaufman Efficiency Ratio regime filter then decides whether the market is [b]Trending[/b], [b]Mean-Reverting[/b], or [b]Random[/b], so signals only fire when conditions actually support them.

[image]https://www.tradingview.com/x/iY8Ye8Zq/[/image]

[b]▎ WHAT IT DOES[/b]
It condenses mean-deviation and normalized momentum into one clean, smoothed oscillator, classifies the current market regime, and prints sparing [b]BUY / SELL[/b] labels only at stretched extremes that align with a trend. A dashboard summarizes every moving part at a glance.

[b]▎ HOW IT WORKS[/b]
• [b]Z-Score component[/b] — price is measured against its moving mean and standard deviation, then clamped at ±3σ and rescaled to ±100. This captures how far price has deviated from equilibrium.
• [b]Momentum component[/b] — rate-of-change is normalized by its own standard deviation (volatility-adjusted), clamped at ±3σ and rescaled to ±100. This measures thrust independent of raw price size.
• [b]Composite blend[/b] — the two components are combined using your chosen weights, EMA-smoothed, and clamped into a single [b]-100..+100 oscillator[/b], with an EMA [i]signal line[/i] layered on top.
• [b]Regime filter[/b] — a Kaufman Efficiency Ratio (directional change ÷ total path) scores 0..1. High values = trending; low values = mean-reverting; in-between = random. Direction is read from price versus its mean.
• [b]Signal gate[/b] — a raw BUY needs the oscillator to cross [i]up[/i] over its signal, to have recently visited [b]oversold[/b], and to sit inside a [b]trending-up[/b] regime. SELL is the mirror. A cooldown enforces a minimum bar gap so labels stay few and never stack.
• [b]Divergence[/b] — pivot highs/lows on the oscillator are compared to price pivots to flag regular bullish and bearish divergences.

[b]▎ HOW TO USE IT[/b]
• Read the oscillator like a bounded momentum gauge — [b]blue[/b] above zero, [b]magenta[/b] below. Pushes into the dotted [b]±80 extreme[/b] bands mark exhaustion zones.
• [b]BUY[/b] pills appear at oversold turns inside up-trends; [b]SELL[/b] pills at overbought turns inside down-trends. Treat them as context-filtered setups, not standalone triggers.
• Use the [b]regime[/b] as your playbook: in [i]Trending[/i], favor pullback continuation; in [i]Mean-Rev[/i], fade the band extremes; in [i]Random[/i], stand aside or size down.
• The subtle pane [b]background tint[/b] mirrors the regime — blue for trending-up, magenta for trending-down, grey for mean-reverting.
• [b]Divergence dots[/b] on the oscillator hint at weakening thrust; combine with your own structure and risk levels.

[b]▎ KEY SETTINGS[/b]
• [b]Engine[/b] — Z-Score length, Momentum (ROC) length, per-component weights, oscillator smoothing, and signal-line length.
• [b]Regime[/b] — Efficiency Ratio window plus the Trending and Mean-Revert thresholds that split the three regimes.
• [b]Signals[/b] — Overbought / Oversold levels, OB/OS recall window, minimum bars between signals (cooldown), and divergence pivot length.
• [b]Visuals[/b] — toggle the gradient fill, oscillator line, signal line, regime background, and signal markers.
• [b]Dashboard[/b] — show/hide, position, and text size.

[b]▎ DASHBOARD[/b]
A compact blue/magenta panel reporting: the current [b]bias[/b] (Long / Short / Flat), the [b]composite[/b] score, raw [b]Z-Score[/b] in σ, the [b]momentum[/b] value, the active [b]regime[/b] with a strength percentage, the [b]OB/OS state[/b], any live [b]divergence[/b], and the current [b]signal[/b] status.

[b]▎ ALERTS[/b]
• [b]QRO — Long[/b] — oscillator crossed up from oversold in a trending-up regime.
• [b]QRO — Short[/b] — oscillator crossed down from overbought in a trending-down regime.
• [b]QRO — Any Signal[/b] — fires on either a long or short signal.

[b]▎ NOTES[/b]
• Works on [b]all timeframes and all assets[/b] — the oscillator is self-normalizing, so it adapts to the instrument automatically.
• Every visual layer is [b]toggleable[/b] for a clean chart; the cooldown keeps markers sparse on any timeframe.
• Signals confirm on the [b]closed bar[/b] and are non-repainting once the bar completes; divergence markers reference confirmed pivots offset back by the pivot length.

[i]For research and education only. This is not financial advice. No indicator can predict the future, and past behavior does not guarantee future results. Always do your own analysis and manage your own risk.[/i]

[i]Made with passion by JackOfAllTrades ⚡[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Quant Regime Oscillator [JOAT]", shorttitle="QRO [JOAT]", overlay=false, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// QUANT REGIME OSCILLATOR [JOAT]
// Composite quant oscillator: z-score (mean deviation) + normalized momentum (ROC)
// + volatility/trend regime factor (Kaufman Efficiency Ratio). Blended into a
// single -100..+100 oscillator with regime-aware signals & divergence.
// BLUE / PURPLE quant aesthetic — premium dark.
// ═══════════════════════════════════════════════════════════════════════════

// ─── PALETTE ────────────────────────────────────────────────────────────────
color C_BLUE   = #2979FF
color C_PURPLE = #E040FB
color C_WHITE  = #FFFFFF
color C_GREY   = #6E7681
color C_CHROME = #DCE3EE

// ─── GROUPS ─────────────────────────────────────────────────────────────────
var string G_ENG = "01 · Engine"
var string G_REG = "02 · Regime"
var string G_SIG = "03 · Signals"
var string G_VIS = "04 · Visuals"
var string G_DSH = "05 · Dashboard"

// ─── 01 · ENGINE INPUTS ──────────────────────────────────────────────────────
i_zLen    = input.int  (30,  "Z-Score Length",      minval=5,  maxval=300, group=G_ENG, tooltip="Lookback for the moving mean & standard deviation used in the z-score of price.")
i_rocLen  = input.int  (14,  "Momentum (ROC) Length", minval=2, maxval=200, group=G_ENG, tooltip="Rate-of-change lookback for the normalized momentum component.")
i_wZ      = input.float(1.0, "Weight · Z-Score",    minval=0.0, maxval=3.0, step=0.1, group=G_ENG, tooltip="Blend weight for the mean-deviation (z-score) component.")
i_wM      = input.float(1.0, "Weight · Momentum",   minval=0.0, maxval=3.0, step=0.1, group=G_ENG, tooltip="Blend weight for the momentum (ROC) component.")
i_smooth  = input.int  (2,   "Oscillator Smoothing", minval=1, maxval=20,  group=G_ENG, tooltip="EMA smoothing applied to the raw composite oscillator.")
i_sigLen  = input.int  (9,   "Signal Line Length",  minval=1,  maxval=50,  group=G_ENG, tooltip="EMA length for the smoothed signal line.")

// ─── 02 · REGIME INPUTS ──────────────────────────────────────────────────────
i_erLen    = input.int  (20,   "Efficiency Ratio Length", minval=4, maxval=200, group=G_REG, tooltip="Kaufman Efficiency Ratio window. High ER = trending, low ER = mean-reverting / random.")
i_trendThr = input.float(0.45, "Trending Threshold",  minval=0.20, maxval=0.90, step=0.01, group=G_REG, tooltip="ER ≥ this = Trending regime.")
i_mrThr    = input.float(0.25, "Mean-Revert Threshold", minval=0.05, maxval=0.60, step=0.01, group=G_REG, tooltip="ER ≤ this = Mean-Reverting regime. Between the two = Random.")

// ─── 03 · SIGNAL INPUTS ──────────────────────────────────────────────────────
i_ob       = input.float(55,  "Overbought Level",  minval=10, maxval=100, step=5, group=G_SIG, tooltip="Upper band. SELL setups require a recent visit above this.")
i_os       = input.float(-55, "Oversold Level",    minval=-100, maxval=-10, step=5, group=G_SIG, tooltip="Lower band. BUY setups require a recent visit below this.")
i_recall   = input.int  (6,   "OB/OS Recall Bars", minval=1, maxval=30, group=G_SIG, tooltip="How many bars back a cross must still 'remember' an OB/OS visit to qualify.")
i_cool     = input.int  (10,  "Min Bars Between Signals", minval=1, maxval=100, group=G_SIG, tooltip="Cooldown: minimum bars between BUY/SELL labels so markers stay few and never stack on any timeframe.")
i_showDiv  = input.bool (true, "Show Divergences",  group=G_SIG, tooltip="Detect & mark regular price↔oscillator divergences.")
i_divLen   = input.int  (5,   "Divergence Pivot Len", minval=2, maxval=20, group=G_SIG, tooltip="Pivot lookback/forward for divergence detection.")

// ─── 04 · VISUAL INPUTS ──────────────────────────────────────────────────────
i_showFill = input.bool (true, "Gradient Fill",        group=G_VIS)
i_showComp = input.bool (true, "Oscillator Line",      group=G_VIS)
i_showSig  = input.bool (true, "Signal Line",          group=G_VIS)
i_showBg   = input.bool (true, "Regime Background",    group=G_VIS, tooltip="Subtle pane background tint: blue = trending-up, purple = trending-down, grey = mean-reverting.")
i_showSets = input.bool (true, "Signal Markers",       group=G_VIS)

// ─── 05 · DASHBOARD INPUTS ────────────────────────────────────────────────────
i_showTab  = input.bool  (true, "Show Dashboard", group=G_DSH)
i_tabPos   = input.string("Top Right", "Position", options=["Top Right","Middle Right","Bottom Right","Top Center","Bottom Center","Top Left","Middle Left","Bottom Left"], group=G_DSH)
i_tabSize  = input.string("Small", "Size", options=["Auto","Large","Normal","Small","Tiny"], group=G_DSH)

// ─── HELPERS ─────────────────────────────────────────────────────────────────
f_clamp(x, lo, hi) => math.max(lo, math.min(hi, x))

f_pos(s) =>
    switch s
        "Top Right"     => position.top_right
        "Middle Right"  => position.middle_right
        "Bottom Right"  => position.bottom_right
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        "Top Left"      => position.top_left
        "Middle Left"   => position.middle_left
        "Bottom Left"   => position.bottom_left
        => position.top_right

f_size(s) =>
    switch s
        "Auto"   => size.auto
        "Large"  => size.large
        "Normal" => size.normal
        "Small"  => size.small
        "Tiny"   => size.tiny
        => size.small

// ═══════════════════════════════════════════════════════════════════════════
// ENGINE — COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

// --- Z-Score of price vs moving mean ---
float basis = ta.sma(close, i_zLen)
float dev   = ta.stdev(close, i_zLen)
float zRaw  = dev != 0 ? (close - basis) / dev : 0.0
float zComp = f_clamp(zRaw / 3.0, -1.0, 1.0) * 100.0        // clamp ±3σ → ±100

// --- Normalized momentum (ROC) ---
float roc     = ta.roc(close, i_rocLen)
float rocStd  = ta.stdev(roc, i_rocLen)
float rocNorm = rocStd != 0 ? roc / rocStd : 0.0
float mComp   = f_clamp(rocNorm / 3.0, -1.0, 1.0) * 100.0    // clamp ±3σ → ±100

// --- Volatility / trend regime factor (Kaufman Efficiency Ratio) ---
float _chg = math.abs(close - close[i_erLen])
float _vol = math.sum(math.abs(close - close[1]), i_erLen)
float er   = _vol != 0 ? _chg / _vol : 0.0                  // 0..1

// --- Composite blend ---
float _wsum = i_wZ + i_wM
float compRaw = _wsum > 0 ? (zComp * i_wZ + mComp * i_wM) / _wsum : 0.0
float osc     = f_clamp(ta.ema(compRaw, i_smooth), -100.0, 100.0)
float signal  = ta.ema(osc, i_sigLen)

// ═══════════════════════════════════════════════════════════════════════════
// REGIME CLASSIFICATION
// ═══════════════════════════════════════════════════════════════════════════
bool regTrend = er >= i_trendThr
bool regMR    = er <= i_mrThr
bool trendUp  = regTrend and close > basis
bool trendDn  = regTrend and close < basis
float regStr  = f_clamp(er * 100.0, 0.0, 100.0)             // regime strength %
string regTxt = regTrend ? (close > basis ? "Trending ▲" : "Trending ▼") : regMR ? "Mean-Rev" : "Random"

// ═══════════════════════════════════════════════════════════════════════════
// SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════
bool crossUp = ta.crossover(osc, signal)
bool crossDn = ta.crossunder(osc, signal)
bool wasOS   = ta.lowest(osc, i_recall)  <= i_os
bool wasOB   = ta.highest(osc, i_recall) >= i_ob

bool buyRaw  = crossUp and wasOS and trendUp
bool sellRaw = crossDn and wasOB and trendDn

// Cooldown gate — keeps signals few & labels strictly non-overlapping on all timeframes
var int lastSigBar = na
bool coolOk = na(lastSigBar) or (bar_index - lastSigBar) >= i_cool
bool buy  = buyRaw  and coolOk
bool sell = sellRaw and coolOk

var int lastSig = 0
if buy
    lastSig := 1
    lastSigBar := bar_index
if sell
    lastSig := -1
    lastSigBar := bar_index

string obosTxt = osc >= i_ob ? "Overbought" : osc <= i_os ? "Oversold" : "Neutral"

// ═══════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION (regular)
// ═══════════════════════════════════════════════════════════════════════════
float pl = ta.pivotlow(osc, i_divLen, i_divLen)
float ph = ta.pivothigh(osc, i_divLen, i_divLen)

var float prevPL      = na
var float prevPLprice = na
var float prevPH      = na
var float prevPHprice = na

bool bullDiv = false
bool bearDiv = false

if not na(pl)
    float pxLow = low[i_divLen]
    if not na(prevPL) and pl > prevPL and pxLow < prevPLprice
        bullDiv := true
    prevPL      := pl
    prevPLprice := pxLow

if not na(ph)
    float pxHigh = high[i_divLen]
    if not na(prevPH) and ph < prevPH and pxHigh > prevPHprice
        bearDiv := true
    prevPH      := ph
    prevPHprice := pxHigh

// ═══════════════════════════════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════════════════════════════
color oscLineCol = osc >= 0 ? C_BLUE : C_PURPLE

// Bands & zero line
hline(0,     "Zero",       color=color.new(C_GREY, 30), linestyle=hline.style_solid)
hline(i_ob,  "Overbought", color=color.new(C_GREY, 55), linestyle=hline.style_dashed)
hline(i_os,  "Oversold",   color=color.new(C_GREY, 55), linestyle=hline.style_dashed)
hline(80,    "Extreme +",  color=color.new(C_GREY, 75), linestyle=hline.style_dotted)
hline(-80,   "Extreme -",  color=color.new(C_GREY, 75), linestyle=hline.style_dotted)

// Oscillator body + gradient fill
p_osc  = plot(osc, "Oscillator", color=i_showComp ? color.new(oscLineCol, 10) : na, linewidth=2)
p_zero = plot(0, "ZeroBase", color=na, display=display.none, editable=false)
fill(p_osc, p_zero, 100, -100, i_showFill ? color.new(C_BLUE, 55) : na, i_showFill ? color.new(C_PURPLE, 55) : na, title="Gradient Fill")

// Signal line
plot(i_showSig ? signal : na, "Signal", color=color.new(C_WHITE, 10), linewidth=2)

// Regime background (subtle)
bgcolor(i_showBg ? (trendUp ? color.new(C_BLUE, 92) : trendDn ? color.new(C_PURPLE, 92) : regMR ? color.new(C_GREY, 94) : na) : na, title="Regime BG")

// Signal markers as clean label pills at the oscillator value (no triangles/arrows)
var array<label> sigLbls = array.new<label>()
if i_showSets and (buy or sell)
    label sigLbl = label.new(bar_index, osc, buy ? "BUY" : "SELL", xloc=xloc.bar_index, yloc=yloc.price, style=buy ? label.style_label_up : label.style_label_down, color=color.new(buy ? C_BLUE : C_PURPLE, 0), textcolor=color.new(C_WHITE, 0), size=size.normal, text_formatting=text.format_bold)
    array.push(sigLbls, sigLbl)
    while array.size(sigLbls) > 60
        label.delete(array.shift(sigLbls))

// Divergence markers (at pivot, offset back by pivot len)
plotshape(i_showDiv and bullDiv ? osc : na, "Bull Div", style=shape.circle, location=location.absolute, size=size.tiny, color=color.new(C_BLUE, 0),   offset=-i_divLen)
plotshape(i_showDiv and bearDiv ? osc : na, "Bear Div", style=shape.circle, location=location.absolute, size=size.tiny, color=color.new(C_PURPLE, 0), offset=-i_divLen)

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table tbl = table.new(f_pos(i_tabPos), 2, 9, bgcolor=color.new(#0B0E17, 12), border_color=color.new(C_GREY, 55), border_width=1, frame_color=color.new(C_GREY, 45), frame_width=1)

if barstate.islast and i_showTab
    _sz        = f_size(i_tabSize)
    color lbT   = color.new(#AEB6C2, 0)
    color hdBg0 = color.new(#161D2E, 0)
    color hdBg1 = color.new(#1E2740, 0)
    color rwBg  = color.new(#0B0E17, 20)

    // gradient value color for the composite score
    color compCol = osc >= 0 ? color.from_gradient(osc, 0, 100, color.new(C_BLUE, 55), C_BLUE) : color.from_gradient(osc, -100, 0, C_PURPLE, color.new(C_PURPLE, 55))

    // Header — subtle chrome gradient, bold-italic
    table.cell(tbl, 0, 0, "QUANT REGIME", text_color=C_CHROME, text_size=_sz, bgcolor=hdBg0, text_halign=text.align_left)
    table.cell_set_text_formatting(tbl, 0, 0, text.format_bold + text.format_italic)
    table.cell(tbl, 1, 0, lastSig == 1 ? "◆ LONG" : lastSig == -1 ? "◆ SHORT" : "◆ FLAT", text_color=lastSig == 1 ? C_BLUE : lastSig == -1 ? C_PURPLE : lbT, text_size=_sz, bgcolor=hdBg1)
    table.cell_set_text_formatting(tbl, 1, 0, text.format_bold + text.format_italic)

    // Composite score
    table.cell(tbl, 0, 1, "Composite", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(osc, "#.0"), text_color=color.new(C_WHITE, 0), text_size=_sz, bgcolor=compCol)

    // Z-Score
    table.cell(tbl, 0, 2, "Z-Score", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(zRaw, "#.00") + "σ", text_color=zRaw >= 0 ? C_BLUE : C_PURPLE, text_size=_sz, bgcolor=rwBg)

    // Momentum
    table.cell(tbl, 0, 3, "Momentum", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(mComp, "#.0"), text_color=mComp >= 0 ? C_BLUE : C_PURPLE, text_size=_sz, bgcolor=rwBg)

    // Regime + strength
    table.cell(tbl, 0, 4, "Regime", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 4, regTxt, text_color=regTrend ? (close > basis ? C_BLUE : C_PURPLE) : lbT, text_size=_sz, bgcolor=rwBg)

    table.cell(tbl, 0, 5, "Regime Str", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(regStr, "#") + "%", text_color=color.from_gradient(regStr, 0, 100, lbT, C_WHITE), text_size=_sz, bgcolor=rwBg)

    // OB/OS state
    table.cell(tbl, 0, 6, "State", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 6, obosTxt, text_color=obosTxt == "Overbought" ? C_BLUE : obosTxt == "Oversold" ? C_PURPLE : lbT, text_size=_sz, bgcolor=rwBg)

    // Divergence flag
    table.cell(tbl, 0, 7, "Divergence", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 7, bullDiv ? "Bullish ▲" : bearDiv ? "Bearish ▼" : "—", text_color=bullDiv ? C_BLUE : bearDiv ? C_PURPLE : lbT, text_size=_sz, bgcolor=rwBg)

    // Active signal
    table.cell(tbl, 0, 8, "Signal", text_color=lbT, text_size=_sz, bgcolor=rwBg, text_halign=text.align_left)
    table.cell(tbl, 1, 8, buy ? "BUY ●" : sell ? "SELL ●" : "waiting", text_color=buy ? C_BLUE : sell ? C_PURPLE : lbT, text_size=_sz, bgcolor=rwBg)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(buy,  "QRO — Long",  "Quant Regime Oscillator [JOAT]: LONG — oscillator crossed up from oversold in a trending-up regime")
alertcondition(sell, "QRO — Short", "Quant Regime Oscillator [JOAT]: SHORT — oscillator crossed down from overbought in a trending-down regime")
alertcondition(buy or sell, "QRO — Any Signal", "Quant Regime Oscillator [JOAT]: Signal detected")
````
