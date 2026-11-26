# Copper vs Cu/Au Decomposition

- url: https://www.tradingview.com/script/goVJ6n8m-Copper-vs-Cu-Au-Decomposition/
- type: indicator
- pine_id: PUB;bad279540f374a5b97f4e163fc016549
- version: 1.0

## Description

[b]Copper vs Cu/Au Decomposition[/b]

Overview

The copper-to-gold ratio (Cu/Au) is a widely followed macro signal, used as a proxy for global growth expectations, risk appetite, and the direction of long-end yields. The intuition is simple: copper demand rises with industrial activity, gold demand rises with monetary and geopolitical stress, so the ratio of the two encodes the balance between growth-on and defense-on regimes.

But the ratio has a structural blind spot. Because it is a quotient of two independently moving series, it cannot tell you which leg is doing the work. A rising Cu/Au can mean copper is rallying on real demand — or it can mean gold is selling off on a hawkish surprise, with copper doing nothing. A falling Cu/Au can mean genuine growth weakness — or it can mean copper is strong but gold is even stronger, masking the signal. Same number, very different stories, very different trades.

This indicator decomposes the Cu/Au ratio into its components so you can see which side is actually driving it, and adds a derived line that explicitly measures when gold is distorting the signal.

What it plots

All series are sampled on the monthly timeframe regardless of chart timeframe, z-score normalized over a configurable rolling lookback (default 60 months), and lightly EMA-smoothed (default length 3).

[list]
[*]Copper z-score — HG1! monthly close, position within its own 5-year distribution. Orange.
[*]Gold z-score — TVC:GOLD monthly close, same treatment. Yellow.
[*]Cu/Au ratio z-score — the ratio HG1!/TVC:GOLD, with both legs sampled on the same monthly bar (via nested request.security) before the ratio is formed and z-scored. Aqua, heavier linewidth as the headline series.
[*]Copper minus Ratio spread — the difference between copper's absolute z-position and its relative z-position. Magenta, optional, default off. This is the diagnostic line.
[*]A dashed zero line, light green/red background tint keyed to the ratio's sign, and a status table confirming each symbol loaded round out the display. All four lines have independent show/hide toggles.
[/list]

How to read it

The three primary lines tell you what each leg is doing. The magenta spread tells you whether the ratio is being honest about copper.

[list]
[*]Spread near zero — the ratio is faithfully reporting copper. Read Cu/Au at face value.
[*]Spread positive and rising — copper is stronger than the ratio shows; gold strength is masking it. Lean long copper but don't trust ratio-based signals.
[*]Spread negative and falling — the ratio is overstating copper; the move is really a short-gold story. Fade ratio-based copper longs.
[/list]

The four canonical scenarios

[list]
[*]Clean cyclical turn: copper rises, gold flat, ratio rises, spread near zero. All signals agree, ratio is honest, high-confidence growth-on tape.
[*]Masked copper strength: copper rises, gold rises harder, ratio flat or falling, spread sharply positive. The ratio is hiding real copper strength behind a stronger gold leg.
[*]Fake copper signal from gold weakness: copper flat, gold falling hard, ratio rises, spread sharply negative. The ratio looks bullish copper but it's actually a short-gold story misrepresented.
[*]Confirmed risk-off: copper falls, gold rises, ratio falls hard, spread roughly flat. Both legs agree on defense, ratio is honest.
[/list]

Why the spread matters

The Cu/Au ratio loses information whenever gold moves independently of copper. The spread quantifies that lost information as a single readable number. When it sits near zero, no information is being lost — copper and the ratio are saying the same thing. When it deviates, the ratio is failing as a copper proxy and you need to step around it to the underlying components. The spread does that decomposition explicitly so you don't have to mentally subtract two z-scores while reading the chart in real time.
Inputs

[list]
[*]Z-Score Lookback (default 60) — rolling window for mean and standard deviation, expressed in monthly bars
[*]EMA Smoothing Length (default 3) — applied to each z-score series after normalization
[*]Source Timeframe (default M) — the timeframe at which all symbols are sampled
[*]Display toggles — independent show/hide for copper, gold, ratio, spread, background tint, and status table
[/list]

Notes

[list]
[*]Data is fetched with gaps=barmerge.gaps_off and ignore_invalid_symbol=true, so the indicator handles missing bars gracefully and won't break if a symbol fails to load.
[*]All calculations are non-repainting (lookahead=barmerge.lookahead_off, the default).
[*]Best used on weekly or daily charts where the monthly resampling gives meaningful resolution. Below daily, the monthly values will appear as long flat segments.
[*]The ratio z-score is computed from monthly samples of both legs, not from the chart-level ratio, so the rolling window represents 60 genuine monthly observations rather than 60 stepped chart bars.
[/list]

Credits and concept
Built for traders who use Cu/Au as a macro signal but want to know when the signal is being distorted by gold-side moves. The decomposition framework draws on the standard observation in commodity macro that ratio-based indicators carry hidden denominator risk, and operationalizes that observation as a single readable diagnostic line.

## Source Code

````pine
//@version=6
indicator("Copper vs Cu/Au Decomposition", shorttitle="Cu/Au Decomp", overlay=false)

// === Inputs ===
lookback   = input.int(60, "Z-Score Lookback", minval=2, group="Calculation")
emaLen     = input.int(3,  "EMA Smoothing Length", minval=1, group="Calculation")
htf        = input.timeframe("M", "Source Timeframe", group="Calculation")
showCopper = input.bool(true,  "Show Copper",      group="Display")
showGold   = input.bool(true,  "Show Gold",        group="Display")
showRatio  = input.bool(true,  "Show Cu/Au Ratio", group="Display")
showSpread = input.bool(false, "Show Cu − Ratio Spread (masking signal)", group="Display")
showBg     = input.bool(true,  "Background Tint on Ratio Sign", group="Display")
showTable  = input.bool(true,  "Show Status Table", group="Display")

// === Symbols ===
cuSym = "HG1!"
auSym = "TVC:GOLD"

// === Helpers ===
f_z(src, len, smlen) => ta.ema((src - ta.sma(src, len)) / ta.stdev(src, len), smlen)

f_ratio_z(otherSym, htfArg, len, smlen) =>
    other = request.security(otherSym, htfArg, close, gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
    r = close / other
    ta.ema((r - ta.sma(r, len)) / ta.stdev(r, len), smlen)

// === Fetch (all on monthly) ===
cuClose = request.security(cuSym, htf, close, gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
auClose = request.security(auSym, htf, close, gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
cuZ     = request.security(cuSym, htf, f_z(close, lookback, emaLen), gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
auZ     = request.security(auSym, htf, f_z(close, lookback, emaLen), gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
ratioZ  = request.security(cuSym, htf, f_ratio_z(auSym, htf, lookback, emaLen), gaps=barmerge.gaps_off, ignore_invalid_symbol=true)

// === Derived: copper-minus-ratio spread ===
spreadZ = cuZ - ratioZ

// === Plots ===
plot(showCopper ? cuZ     : na, "Copper Z",   color=color.orange,  linewidth=2)
plot(showGold   ? auZ     : na, "Gold Z",     color=color.yellow,  linewidth=2)
plot(showRatio  ? ratioZ  : na, "Cu/Au Z",    color=color.aqua,    linewidth=3)
plot(showSpread ? spreadZ : na, "Cu − Ratio", color=color.fuchsia, linewidth=2)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dashed)

// === Background tint on ratio sign ===
bgCol = showBg ? (ratioZ > 0 ? color.new(color.green, 88) : ratioZ < 0 ? color.new(color.red, 88) : na) : na
bgcolor(bgCol)

// === Status table ===
cuOk     = not na(cuClose)
auOk     = not na(auClose)
ratioOk  = not na(ratioZ)
spreadOk = not na(spreadZ)

var table statusTable = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast and showTable
    table.cell(statusTable, 0, 0, "Symbol", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(statusTable, 1, 0, "Status", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(statusTable, 0, 1, "HG1! (Cu)",    text_color=color.orange,  text_size=size.small)
    table.cell(statusTable, 1, 1, cuOk     ? "OK" : "X", text_color=cuOk     ? color.green : color.red, text_size=size.small)
    table.cell(statusTable, 0, 2, "TVC:GOLD",     text_color=color.yellow,  text_size=size.small)
    table.cell(statusTable, 1, 2, auOk     ? "OK" : "X", text_color=auOk     ? color.green : color.red, text_size=size.small)
    table.cell(statusTable, 0, 3, "Cu/Au Ratio",  text_color=color.aqua,    text_size=size.small)
    table.cell(statusTable, 1, 3, ratioOk  ? "OK" : "X", text_color=ratioOk  ? color.green : color.red, text_size=size.small)
    table.cell(statusTable, 0, 4, "Cu − Ratio",   text_color=color.fuchsia, text_size=size.small)
    table.cell(statusTable, 1, 4, spreadOk ? "OK" : "X", text_color=spreadOk ? color.green : color.red, text_size=size.small)
````
