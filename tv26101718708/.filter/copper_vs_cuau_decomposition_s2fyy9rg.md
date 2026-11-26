# Copper vs Cu/Au Decomposition

- url: https://www.tradingview.com/script/s2FYy9Rg-Copper-vs-Cu-Au-Decomposition/
- type: indicator
- pine_id: PUB;110c599d8e3a45e89df800839cde8727
- version: 1.0

## Description

[b]Copper vs Cu/Au Decomposition[/b]

The copper-to-gold ratio is one of the most widely watched macro signals in markets, used as a proxy for global growth, risk appetite, and the direction of long-end yields. The framework is intuitive. Copper demand rises with industrial activity. Gold demand rises with monetary and geopolitical stress. The ratio encodes the balance between growth-on and defense-on regimes.

It has a structural blind spot. Because Cu/Au is a quotient of two independently moving series, the ratio alone cannot tell you which leg is doing the work. A rising Cu/Au might mean copper is rallying on real industrial demand. It might also mean gold is selling off on a hawkish surprise while copper does nothing. A falling Cu/Au might mean genuine growth weakness, or it might mean copper is strong but gold is even stronger and is masking the signal. Same number, very different stories, very different trades.

This indicator decomposes the ratio into its components so you can see which side is actually driving it. It plots copper, gold, and the ratio as z-score normalized series on a shared monthly timeframe, then adds a derived line that quantifies the gap between copper's absolute strength and what the ratio is reporting. That derived line is the diagnostic.

[b]WHAT IT PLOTS[/b]
- Four lines, all sampled on the monthly timeframe regardless of the chart timeframe.

[i]Copper z-score (orange)[/i]
- HG1! monthly close, normalized over a rolling 60-month lookback, lightly EMA-smoothed.

[i]Gold z-score (yellow)[/i]
- TVC:GOLD monthly close, same treatment.

[i]Cu/Au ratio z-score (aqua)[/i]
- The headline series with heavier linewidth. 

The ratio is built by sampling both legs on the same monthly bar via nested request security before forming the quotient. This matters. If you compute the ratio at chart level using forward-filled monthly values, a 60-bar rolling window on a daily chart averages roughly three months of stepped data rather than 60 actual monthly observations. The nested approach preserves true monthly resolution in the rolling window.

[i]Copper minus Ratio spread (magenta)[/i]
- The diagnostic line. Optional, off by default to keep the panel clean on first load.

Supporting elements include a dashed zero line, light green and red background tints keyed to the ratio's sign, and a status table top-right confirming each symbol loaded. All four lines have independent toggles.

[b]HOW TO READ IT[/b]
- The three primary lines tell you what each leg is doing. The magenta spread tells you whether   the ratio is being honest about copper.

[i]Spread near zero[/i]
   The ratio is faithfully reporting copper. Read Cu/Au at face value.

[i]Spread positive and rising[/i]
   Copper is stronger than the ratio shows. Gold strength is masking it. Lean long copper but do not trust ratio-based signals to size the trade.

[i]Spread negative and falling[/i]
   The ratio is overstating copper. The move is really a short-gold story misrepresented as a copper bid. Fade ratio-based copper longs in this regime.

[b]THE FOUR CHARACTERISTIC SCENARIOS[/b]

[i]Clean cyclical turn[/i] - Copper rises, gold flat, ratio rises, spread near zero. All signals agree. The ratio is honest. High-confidence growth-on tape.

[i]Masked copper strength[/i] - Copper rises, gold rises harder, ratio flat or falling, spread sharply positive. The ratio is hiding real copper strength behind a stronger gold leg. This is the regime the indicator exists to flag.

[i]Fake copper signal from gold weakness[/i] - Copper flat, gold collapses, ratio rises, spread sharply negative. The ratio looks bullish on copper but it is really a short-gold story. Fade.

[i]Confirmed risk-off[/i] - Copper falls, gold rises, ratio falls hard, spread roughly flat. Both legs agree on defense. The ratio is honest.

[b]WHAT THE SPREAD REVEALS[/b]

The Cu/Au ratio loses information whenever gold moves independently of copper. The spread quantifies that lost information as a single readable number. When it sits near zero, no information is being lost. Copper and the ratio are saying the same thing. When it deviates, the ratio is failing as a copper proxy and you need to step around it to the underlying components.

The decomposition can be done mentally by watching the three primary lines, but doing it in real time while reading a chart is error-prone. The spread does that subtraction explicitly and renders the answer as a single line whose distance from zero is the magnitude of the distortion. Z-scoring the ratio as its own series, rather than computing the spread as copper z minus gold z arithmetically, is the design choice that makes the spread responsive to what the ratio is actually doing as a series, not just what its components are doing in isolation.

[b]INPUTS AND DEFAULTS[/b]

[i]Z-Score Lookback (default 60[/i]) 
- The rolling window for mean and standard deviation, in monthly bars. Five years captures roughly one full commodity and business cycle, long enough to represent a regime-neutral baseline but short enough to update when the macro environment shifts.

[i]EMA Smoothing Length (default 3) [/i]
- Light smoothing on each z-score after normalization. Three monthly bars dampens single-month noise without introducing meaningful lag.

[i]Source Timeframe (default M) [/i]
- The timeframe at which all symbols are sampled. See Suggested settings below for pairings with different lookbacks.

[i]Display toggles[/i]
- Independent show/hide for each line, the background tint, and the status table.

[b][i]Suggested settings[/i][/b]

The two calibration inputs, lookback and source timeframe, are not really independent. They multiply to give you one number, the regime window the z-score measures against. Lookback × bar length = regime window. The default monthly × 60 produces a 5-year window because that's the natural horizon for Cu/Au as a multi-year cycle signal. Other source timeframes can preserve the same horizon at finer visual resolution.

[i]Macro regime (~5 years)[/i]
- The indicator's original design horizon. Best for reading Cu/Au as a structural cycle tool. Monthly × 60, weekly × 260, daily × 1260, or 3D × 420.

[i]Cycle phase (~2 years)[/i]
- Intermediate, captures one full phase of a business or commodity cycle. Useful when the broader regime is well established and the question is where within it you currently sit. Monthly × 24, weekly × 104, daily × 504, or 3D × 168.

[i]Tactical (~6 months)[/i]
- Short horizon, asks where copper sits relative to recent trading. The masking dynamic operates more weakly at this scale, so the spread's diagnostic power is reduced. Weekly × 26, daily × 126, or 3D × 42.

[i]A few practical notes on choosing among these[/i]

The higher the source timeframe, the more it filters intra-period noise before the z-score is calculated. Monthly source gives the cleanest macro read but updates only when a new month closes, producing a stepped visual on lower chart timeframes. Setting source equal to your chart timeframe gives a smoother line but mixes regime drift with intra-period noise.

A useful middle ground on multi-day charts is setting source one or two steps above your chart timeframe. On a 3D chart, weekly source smooths daily volatility without going all the way to monthly's stepped behavior.

Z-score magnitudes do not transfer perfectly across sources. Higher-frequency series carry more variance, which inflates the rolling standard deviation and compresses z-scores. The same 5-year window will print spikier readings on monthly than on daily because monthly closes filter noise before the calculation begins. The shape of moves matches across sources, but the amplitudes do not.

The most informative use is running multiple instances of the indicator simultaneously at different horizons. The slow spread tells you whether the macro Cu/Au framework is currently honest. The fast spread tells you about near-term distortions worth trading around.

[b][i]Notes[/i][/b]

Data is fetched with gaps=barmerge.gaps_off and ignore_invalid_symbol=true, so missing bars are forward-filled and the indicator does not break if a symbol fails to load. Calculations are non-repainting.

Best used on weekly or daily charts at the default settings. The monthly resampling gives meaningful resolution there. Below daily, monthly values will appear as long flat segments, in which case the suggested settings above for tactical or cycle-phase calibrations are worth considering.

[b][i]Originality[/i][/b]

The underlying mechanics, z-score normalization, forward-filling, and ratio construction, are standard. The original contributions are three: the integrated four-line decomposition; the construction of the ratio from same-bar monthly samples via nested request security to preserve true monthly window resolution; and the Copper-minus-Ratio spread as an explicit measure of when the Cu/Au ratio is being distorted by gold-side moves. No published TradingView indicator I am aware of combines these elements as a single diagnostic for Cu/Au signal quality.

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
