# Liquidity Sweep & Absorption Reversal Engine [PhenLabs]

- url: https://www.tradingview.com/script/AeGl0W8J-Liquidity-Sweep-Absorption-Reversal-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;2ec573a0a42f405a8575479b99d4b868
- version: 1.0

## Description

📊 Liquidity Sweep & Absorption Reversal Engine [PhenLabs]

[b]Version:[/b] PineScript™ v6

📌 Description

The Liquidity Sweep & Absorption Reversal Engine (LSA Engine) is a two-stage reversal tool that separates high-probability liquidity stop-runs from the noise of ordinary breakouts. Most sweep indicators fire the moment price pokes through a swing high or low — the LSA Engine refuses to commit until that sweep is [i]confirmed[/i] by genuine institutional absorption.

The problem it solves is simple but expensive: not every wick beyond a prior high or low is a smart-money stop hunt. Many are clean breakouts that keep going. By requiring a volume spike paired with a disproportionately small body (volume that failed to displace price), the engine filters for the specific fingerprint of absorbed liquidity — the moment resting orders are consumed and price is rejected. Only then does it flag a reversal and project the opposing draw.

The result is a clean, dashboard-backed overlay that gives smart-money, ICT, and intraday reversal traders a single source of truth for swept liquidity, absorption status, and the next untaken pool — without the false-signal storm of a raw sweep detector.

🚀 Points of Innovation

[list]
[*]Two-stage validation that pairs a liquidity sweep with a mandatory volume-absorption confirmation — sweeps without absorption are ignored, not flagged.
[*]Absorption fingerprint defined quantitatively: a volume spike (≥ configurable multiple of average) [i]and[/i] a body-to-range ratio below a tunable threshold, so “absorbed” means measured, not eyeballed.
[*]Dual sweep triggers — a classic close-back-inside rejection [i]or[/i] an ATR-scaled displacement break — letting traders tune to rejection-style or momentum-style sweeps on the same instrument.
[*]Auto-projected opposing draw that targets the nearest untaken opposing liquidity pool, with a structure-based R-multiple fallback when no pool is in range.
[*]Live dashboard reporting nearest BSL/SSL, volume-spike state, absorption state, and active trigger mode in real time.
[*]Self-cleaning pool management — swept pools are retired so each level can only fire once, eliminating duplicate signals on the same stop-run.
[/list]

🔧 Core Components

[list]
[*][b]Liquidity Pool Engine:[/b] Detects confirmed pivot highs and lows and stores them as resting buy-side liquidity (BSL, above) and sell-side liquidity (SSL, below). A rolling buffer keeps only the most relevant active pools per side.
[*][b]Sweep Detector:[/b] Monitors every active pool for a wick beyond its level, then validates the sweep using the selected trigger — close-back-inside rejection or ATR-scaled displacement.
[*][b]Absorption Filter:[/b] On the sweeping bar, measures volume against its moving average and the candle’s body-to-range ratio. A spike with a small body = absorbed; this gate can be toggled on or off.
[*][b]Projection Module:[/b] From each confirmed sweep extreme, projects a dotted target line to the nearest opposing pool or to an R-multiple measured from sweep risk, with a labeled price target.
[*][b]Dashboard:[/b] A compact on-chart table reporting the nearest BSL/SSL, current volume-spike and absorption state, and the active sweep mode.
[/list]

🔥 Key Features

[list]
[*][b]Confirmed reversal signals:[/b] Bullish and bearish sweep-plus-absorption triangles fire only on two-stage-validated setups, reducing false stop-run signals.
[*][b]Resting liquidity map:[/b] Dashed BSL/SSL lines show the live pools price is magnetically drawn to — so you always know where the next sweep is likely.
[*][b]Quantitative absorption marker:[/b] A yellow circle flags the exact bar where volume spiked while price made minimal progress.
[*][b]Projected opposing draw:[/b] A dotted line and labeled price target extend from each confirmed sweep to the next opposing pool or R-multiple objective.
[*][b]Adaptive trigger mode:[/b] Switch between close-back-inside rejection and ATR displacement to match the instrument’s sweep behavior.
[*][b]Live status dashboard:[/b] Nearest BSL/SSL, volume-spike state, absorption state, and mode at a glance.
[*][b]Alerts:[/b] Separate alerts for bullish and bearish confirmed sweep-plus-absorption setups.
[/list]

🎨 Visualization

[list]
[*][b]Dashed BSL (teal) / SSL (red) lines:[/b] resting liquidity pools — price is drawn to these; a sweep of one is the setup precondition.
[*][b]Yellow circle:[/b] marks the sweeping bar where a volume spike coincided with a small body — the absorption fingerprint.
[*][b]Red triangle (BEAR SWEEP) / teal triangle (BULL SWEEP):[/b] the confirmed two-stage reversal signal, plotted above/below the triggering bar.
[*][b]Dotted target line + price label:[/b] the projected opposing draw from the sweep extreme to the next pool or R-multiple target.
[*][b]Volume pane + vol-avg line:[/b] optional context showing the spike that powered the absorption call.
[*][b]Dashboard panel (top-right):[/b] nearest BSL/SSL, Vol Spike, Absorption, and Mode cells.
[/list]

📖 Usage Guidelines

[b]Structure & Liquidity[/b]
[list]
[*][b]Pivot Lookback (L/R)[/b] — [i]Default: 8[/i] — Range: 2–50 — Left/right bars used to confirm swing highs and lows. Higher = fewer, more significant pools; lower = more reactive pools.
[*][b]Max Active Pools / Side[/b] — [i]Default: 6[/i] — Range: 2–20 — How many BSL/SSL levels are tracked per side. More pools = denser map; fewer = cleaner chart.
[*][b]Sweep Trigger[/b] — [i]Default: Close Back Inside[/i] — Options: Close Back Inside / Displacement Break. “Close Back Inside” flags sweeps rejected back under/over the pool (reversal bias). “Displacement Break” flags sweeps that close beyond the pool by an ATR-scaled margin (momentum sweep bias).
[*][b]Displacement (× ATR)[/b] — [i]Default: 1.2[/i] — Range: 0.1–10 — Only active in Displacement Break mode; sets how far beyond the pool close must travel to qualify.
[/list]

[b]Absorption Filter[/b]
[list]
[*][b]Require Absorption Confirmation[/b] — [i]Default: true[/i] — When on, sweeps must pass the absorption gate to fire a signal. Turn off for raw sweep detection.
[*][b]Volume Spike (× avg)[/b] — [i]Default: 1.6[/i] — Range: 1.0–10 — Minimum volume-to-average ratio on the sweeping bar. Higher = stricter, fewer but higher-quality signals.
[*][b]Max Body/Range[/b] — [i]Default: 0.45[/i] — Range: 0.05–0.9 — Maximum body-to-range ratio for a bar to count as absorbed. Lower = stricter (volume absorbed with little progress).
[*][b]Volume SMA Length[/b] — [i]Default: 20[/i] — Range: 1–200 — Lookback for the volume average baseline.
[/list]

[b]Targets & Projection[/b]
[list]
[*][b]Target R-Multiple[/b] — [i]Default: 2.0[/i] — Range: 0.5–20 — Reward multiple used when projecting R-multiple targets.
[*][b]Show Projected Draw[/b] — [i]Default: true[/i] — Toggles the dotted target line and price label.
[*][b]Target Type[/b] — [i]Default: Opposing Pool[/i] — Options: Opposing Pool / R-Multiple. “Opposing Pool” targets the nearest untaken opposite liquidity; “R-Multiple” targets a fixed multiple of sweep risk.
[/list]

[b]Visuals[/b]
[list]
[*][b]Show Dashboard[/b] — [i]Default: true[/i] — Toggles the on-chart status panel.
[*][b]Signal / pool colors[/b] — configurable for bullish, bearish, BSL, and SSL elements.
[/list]

✅ Best Use Cases

[list]
[*]Smart-money / ICT traders hunting confirmed stop-runs on session highs and lows
[*]Intraday reversal and fade traders on indices, futures, crypto, and major FX
[*]Scalpers who need a fast, visual read on whether a sweep is being absorbed or extending
[*]Liquidity traders who map BSL/SSL and want the next opposing draw projected automatically
[*]Traders who want to filter breakout-vs-sweep ambiguity with a quantitative absorption gate
[/list]

⚠️ Limitations

[list]
[*]Absorption relies on volume data; symbols with no/low-quality volume (some FX feeds) will produce fewer or weaker confirmations.
[*]The body-to-range absorption proxy is an approximation of true order-flow absorption; for delta-grade accuracy pair with a volume-profile/delta source.
[*]Pivots confirm [i]pivotLen[/i] bars after the swing, so pool levels are retrospective — recent extremes may not yet be registered as pools.
[*]Reversal signals perform best in ranging and liquidity-driven regimes; in strong trending regimes swept levels often continue, so bias signals toward the prevailing trend.
[*]Like all reversal tools, signals are probabilistic — always manage risk and confirm with broader market structure.
[/list]

💡 What Makes This Unique

[list]
[*][b]Absorption as the second stage:[/b] Most sweep tools stop at “price went beyond the level.” The LSA Engine demands the institutional fingerprint — volume that failed to move price — before any signal fires.
[*][b]Measured, not eyeballed:[/b] Absorption is a tunable volume-spike × body/range rule, so the filter is reproducible and adjustable per instrument, not a discretionary call.
[*][b]Self-cleaning pools + auto opposing draw:[/b] each pool fires once and projects its own target, giving a complete sweep-to-draw narrative on the chart.
[/list]

🔬 How It Works

[list]
[*][b]Pool registration:[/b] Confirmed swing highs and lows are recorded as resting BSL and SSL pools in a rolling buffer, so the chart always shows the liquidity price is drawn toward.
[*][b]Sweep detection:[/b] Each bar, the engine checks whether price wicked beyond an active pool and validates it with the selected trigger — a close back inside the pool (rejection) or an ATR-scaled displacement close beyond it.
[*][b]Absorption gating:[/b] On the sweeping bar, volume is compared to its moving average and the body is compared to the bar’s range. A spike with a small body passes the absorption gate — the signature of consumed resting liquidity that failed to displace price. Swept pools are then retired.
[*][b]Signal + projection:[/b] A confirmed sweep-plus-absorption prints a directional signal and projects a dotted target to the nearest opposing pool (or an R-multiple objective), while the dashboard updates nearest pools, volume-spike, and absorption state in real time.
[/list]

[quote][b]💡 Note:[/b] For best results, tune [i]Volume Spike[/i] and [i]Max Body/Range[/i] to your instrument’s typical volume profile — FX and crypto often need a higher spike multiple than index futures. Favor signals aligned with the higher-timeframe trend, and use [i]Opposing Pool[/i] targets on ranging instruments and [i]R-Multiple[/i] targets on trending ones. This tool is an analytical aid, not financial advice.
[/quote]

## Source Code

````pine
//@version=6
// ===========================================================================
//  Liquidity Sweep & Absorption Reversal Engine [PhenLabs]
//  PineScript™ v6  •  Author: PhenLabs
// ===========================================================================
//  A two-stage reversal engine that pairs resting liquidity sweeps with
//  institutional volume absorption to filter out low-quality stop-runs.
//  Only sweeps that are confirmed by genuine absorption (high volume with
//  minimal displacement) are flagged as high-probability reversal setups.
// ===========================================================================
indicator("Liquidity Sweep & Absorption Reversal Engine [PhenLabs]", shorttitle="LSA Reversal Engine [PhenLabs]", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────── Inputs ───────────────────────────
grpS      = "━━━ Structure & Liquidity ━━━"
pivotLen  = input.int(8, "Pivot Lookback (L/R)", minval=2, group=grpS)
maxPools  = input.int(6, "Max Active Pools / Side", minval=2, maxval=20, group=grpS)
sweepMode = input.string("Close Back Inside", "Sweep Trigger", options=["Close Back Inside","Displacement Break"], group=grpS)
dispMult  = input.float(1.2, "Displacement (x ATR)", minval=0.1, step=0.1, group=grpS, tooltip="Used only when Sweep Trigger = Displacement Break")

grpA      = "━━━ Absorption Filter ━━━"
useAbs    = input.bool(true, "Require Absorption Confirmation", group=grpA)
volMult   = input.float(1.6, "Volume Spike (x avg)", minval=1.0, step=0.1, group=grpA)
bodyThresh= input.float(0.45, "Max Body/Range", minval=0.05, maxval=0.9, step=0.05, group=grpA, tooltip="Lower = stricter absorption (volume absorbed with little price progress)")
volLen    = input.int(20, "Volume SMA Length", minval=1, group=grpA)

grpT      = "━━━ Targets & Projection ━━━"
rMult     = input.float(2.0, "Target R-Multiple", minval=0.5, step=0.5, group=grpT)
showProj  = input.bool(true, "Show Projected Draw", group=grpT)
projStyle = input.string("Opposing Pool", "Target Type", options=["Opposing Pool","R-Multiple"], group=grpT)

grpV      = "━━━ Visuals ━━━"
showDash  = input.bool(true, "Show Dashboard", group=grpV)
colBull   = input.color(#26a69a, "Bullish Signal", group=grpV)
colBear   = input.color(#ef5350, "Bearish Signal", group=grpV)
colBSL    = input.color(#26a69a, "BSL Line", group=grpV)
colSSL    = input.color(#ef5350, "SSL Line", group=grpV)

// ─────────────────────────── Core Calcs ───────────────────────────
atr      = ta.atr(14)
volAvg   = ta.sma(volume, volLen)
volSpike = not na(volume) and not na(volAvg) and volAvg > 0 and volume >= volAvg * volMult
rng      = high - low
body     = math.abs(close - open)
bodyR    = rng > 0 ? body / rng : 0.0
absorbed = volSpike and bodyR <= bodyThresh

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

// ─────────────────────── Liquidity Pool Store ───────────────────────
var float[] bslLvl = array.new_float()
var int[]   bslBar = array.new_int()
var float[] sslLvl = array.new_float()
var int[]   sslBar = array.new_int()

if not na(ph)
    array.push(bslLvl, ph)
    array.push(bslBar, bar_index - pivotLen)
    if array.size(bslLvl) > maxPools
        array.shift(bslLvl)
        array.shift(bslBar)
if not na(pl)
    array.push(sslLvl, pl)
    array.push(sslBar, bar_index - pivotLen)
    if array.size(sslLvl) > maxPools
        array.shift(sslLvl)
        array.shift(sslBar)

// nearest active BSL above current low / SSL below current high
f_nearestBSL() =>
    float lvl = na
    int idx = -1
    if array.size(bslLvl) > 0
        for i = array.size(bslLvl) - 1 to 0
            v = array.get(bslLvl, i)
            if low < v and (na(lvl) or v < lvl)
                lvl := v
                idx := i
    [lvl, idx]

f_nearestSSL() =>
    float lvl = na
    int idx = -1
    if array.size(sslLvl) > 0
        for i = array.size(sslLvl) - 1 to 0
            v = array.get(sslLvl, i)
            if high > v and (na(lvl) or v > lvl)
                lvl := v
                idx := i
    [lvl, idx]

// ─────────────────────────── Sweep Engine ───────────────────────────
// Bearish reversal: BSL swept (wick above) then rejected / absorbed
// Bullish reversal: SSL swept (wick below) then rejected / absorbed
[bsl, bslIdx] = f_nearestBSL()
[ssl, sslIdx] = f_nearestSSL()

bool bslSwept = not na(bsl) and high > bsl
bool sslSwept = not na(ssl) and low  < ssl

bool bslReject = bslSwept and close < bsl                      // close back inside
bool sslReject = sslSwept and close > ssl
bool bslDisp   = bslSwept and not na(atr) and close > bsl + atr * dispMult
bool sslDisp   = sslSwept and not na(atr) and close < ssl - atr * dispMult

bool bslTrigger = sweepMode == "Close Back Inside" ? bslReject : bslDisp
bool sslTrigger = sweepMode == "Close Back Inside" ? sslReject : sslDisp

bool bslConfirm = bslTrigger and (not useAbs or absorbed)
bool sslConfirm = sslTrigger and (not useAbs or absorbed)

// remove swept pools so they don't re-fire
if bslSwept and bslIdx >= 0
    array.remove(bslLvl, bslIdx)
    array.remove(bslBar, bslIdx)
if sslSwept and sslIdx >= 0
    array.remove(sslLvl, sslIdx)
    array.remove(sslBar, sslIdx)

// ─────────────────────────── Targets ───────────────────────────
// Risk = sweep extreme -> pool; reward projected to opposing pool or R-multiple
var float lastBullEntry = na
var float lastBullRisk  = na
var float lastBearEntry = na
var float lastBearRisk  = na

if sslConfirm and not na(ssl)
    lastBullEntry := close
    lastBullRisk  := ssl
if bslConfirm and not na(bsl)
    lastBearEntry := close
    lastBearRisk  := bsl

// ─────────────────────────── Plotting ───────────────────────────
// active pools
if array.size(bslLvl) > 0 and barstate.islast
    for i = array.size(bslLvl) - 1 to 0
        v = array.get(bslLvl, i)
        line.new(bar_index - 60, v, bar_index + 8, v, color=colBSL, style=line.style_dashed, width=1)
if array.size(sslLvl) > 0 and barstate.islast
    for i = array.size(sslLvl) - 1 to 0
        v = array.get(sslLvl, i)
        line.new(bar_index - 60, v, bar_index + 8, v, color=colSSL, style=line.style_dashed, width=1)

// signals
plotshape(sslConfirm, title="Bullish Sweep+Absorption", style=shape.triangleup,   location=location.belowbar, color=colBull, size=size.small, text="Bull\nSweep")
plotshape(bslConfirm, title="Bearish Sweep+Absorption", style=shape.triangledown, location=location.abovebar, color=colBear, size=size.small, text="Bear\nSweep")

// projected draw
if showProj and bslConfirm and not na(bsl) and not na(atr)
    risk = math.max(atr, high - bsl)
    tgt  = projStyle == "Opposing Pool" ? (not na(ssl) ? ssl : close - risk * rMult) : close - risk * rMult
    line.new(bar_index, bsl, bar_index + 20, tgt, color=colBear, style=line.style_dotted, width=2)
    label.new(bar_index + 20, tgt, str.tostring(tgt, format.mintick), style=label.style_label_left, color=colBear, textcolor=color.white, size=size.small)
if showProj and sslConfirm and not na(ssl) and not na(atr)
    risk = math.max(atr, ssl - low)
    tgt  = projStyle == "Opposing Pool" ? (not na(bsl) ? bsl : close + risk * rMult) : close + risk * rMult
    line.new(bar_index, ssl, bar_index + 20, tgt, color=colBull, style=line.style_dotted, width=2)
    label.new(bar_index + 20, tgt, str.tostring(tgt, format.mintick), style=label.style_label_left, color=colBull, textcolor=color.white, size=size.small)

// absorption marker
plotshape(useAbs and absorbed and (bslSwept or sslSwept), title="Absorption", style=shape.circle, location=location.absolute, color=color.new(#f1c40f, 0), size=size.tiny)

// ─────────────────────────── Alerts ───────────────────────────
alertcondition(sslConfirm, title="Bullish Sweep + Absorption", message="LSA Engine: Bullish liquidity sweep confirmed by volume absorption.")
alertcondition(bslConfirm, title="Bearish Sweep + Absorption", message="LSA Engine: Bearish liquidity sweep confirmed by volume absorption.")

// ─────────────────────────── Dashboard ───────────────────────────
if showDash and barstate.islast
    var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(#0d1117, 12), border_width=1, border_color=color.new(#30363d, 0))
    table.cell(dash, 0, 0, "LSA Engine", text_color=#c9d1d9, text_size=size.small)
    table.cell(dash, 1, 0, "PhenLabs",  text_color=#7e8a9a, text_size=size.small)
    table.cell(dash, 0, 1, "Nearest BSL", text_color=#8b949e, text_size=size.tiny)
    table.cell(dash, 1, 1, na(bsl)  ? "—" : str.tostring(bsl,  format.mintick), text_color=colBSL, text_size=size.tiny)
    table.cell(dash, 0, 2, "Nearest SSL", text_color=#8b949e, text_size=size.tiny)
    table.cell(dash, 1, 2, na(ssl)  ? "—" : str.tostring(ssl,  format.mintick), text_color=colSSL, text_size=size.tiny)
    table.cell(dash, 0, 3, "Vol Spike", text_color=#8b949e, text_size=size.tiny)
    table.cell(dash, 1, 3, volSpike ? "YES" : "no", text_color=volSpike ? #f1c40f : #8b949e, text_size=size.tiny)
    table.cell(dash, 0, 4, "Absorption", text_color=#8b949e, text_size=size.tiny)
    table.cell(dash, 1, 4, absorbed ? "YES" : "no", text_color=absorbed ? #f1c40f : #8b949e, text_size=size.tiny)
    table.cell(dash, 0, 5, "Mode", text_color=#8b949e, text_size=size.tiny)
    table.cell(dash, 1, 5, sweepMode, text_color=#c9d1d9, text_size=size.tiny)
````
