# ADX Filtered Average True Range

- url: https://www.tradingview.com/script/0tLeWbXY-ADX-Filtered-Average-True-Range/
- type: indicator
- pine_id: PUB;96ab6c45a68e47b5b6840c3cf84dcdf3
- version: 1.0

## Description

[b]Overview[/b]

This indicator combines ATR-based volatility measurement with ADX directional filtering to highlight only those moments when volatility expansion is aligned with confirmed trend momentum. Raw ATR measures how much price moves per bar, but a rising ATR alone says nothing about direction or conviction. By layering an ADX filter on top, the indicator separates meaningful expansion — where volatility is growing in the direction of a strengthening trend — from choppy noise where volatility rises without directional follow-through.

The result is a two-signal system displayed in a separate pane: a smoothed ATR line that changes colour only when the trend is directionally confirmed, and a background highlight that activates only when all three conditions align — expanding ATR, a rising directional ADX signal, and a bar that closes in the direction of the trend. This gives traders a compact, at-a-glance read on whether current volatility is actionable or should be ignored.

The indicator is designed for swing and intraday traders on instruments with clear trending behaviour, such as [symbol="NSE:NIFTY"]NSE:NIFTY[/symbol], [symbol="NSE:BANKNIFTY"]NSE:BANKNIFTY[/symbol], [symbol="MCX:CRUDEOIL1!"]MCX:CRUDEOIL1![/symbol], and major crypto pairs.

[b]How It Works[/b]

ATR is calculated by applying the selected smoothing method to the true range series. A second SWMA pass (smoothed ATR, [i]atrs[/i]) acts as a baseline — when raw ATR rises above [i]atrs[/i] and [i]atrs[/i] itself is also rising, the indicator treats volatility as actively expanding:

[pine]
atr  = ma_function(ta.tr(true), atrlen)
atrs = ta.swma(atr)
ATRExpanding = (atrs > atrs[1] and atr > atrs)
[/pine]

The ADX filter uses Pine's native [pine]ta.dmi()[/pine] to compute DI+, DI−, and raw ADX. A SWMA of ADX ([i]sadx[/i]) acts as the directional baseline. Bullish ADX is confirmed when [i]sadx[/i] is rising, ADX is above [i]sadx[/i], DI+ shows momentum or dominance over DI−, and DI+ is above 15. Bearish ADX mirrors this using DI−:

[pine]
sadx  = ta.swma(adx)
ADXUp = sadx > sadx[1] and adx > sadx and (diplus > diplus[1] or diplus > diminus) and diplus > 15
ADXDn = sadx > sadx[1] and adx > sadx and (diminus > diminus[1] or diminus > diplus) and diminus > 15
[/pine]

Background highlighting only fires when all three conditions are simultaneously true — expanding volatility, directional ADX confirmation, and a bar closing in the expected direction.

Colour key:
[list]
[*][b]Dark red line[/b] — raw ATR; always visible as the volatility baseline
[*][b]Thick white line[/b] — smoothed ATR (SWMA of ATR); the trend-adjusted volatility baseline
[*][b]Green background[/b] — ATR expanding + bullish ADX confirmed + bullish bar (close > open)
[*][b]Red background[/b] — ATR expanding + bearish ADX confirmed + bearish bar (close < open)
[*]No background — ATR contracting, or ADX directional filter not met, or bar indecisive
[/list]

[b]Inputs[/b]

[list=1]
[*][b]ATR – Length[/b] — Number of bars used to smooth the true range for ATR calculation. Constrained to the Fibonacci sequence for harmonic alignment. Low (e.g. 5): fast, reactive ATR that tracks short-term volatility spikes. High (e.g. 55): slow, structural ATR that filters out minor fluctuations. Default: 13.
[*][b]Smoothing[/b] — MA method applied to the true range when computing ATR. RMA (Wilder's moving average) is the industry standard and matches most platform ATR implementations. SWMA is the most responsive with zero lag; VWMA incorporates volume weight. Default: RMA.
[*][b]ADX – Length[/b] — Lookback period for the DMI/ADX calculation via [pine]ta.dmi()[/pine]. Low (e.g. 8): ADX responds faster, triggers more frequently but with more false positives. High (e.g. 55): ADX requires sustained directional pressure before confirming. Default: 34.
[*][b]ADX – Smoothing[/b] — Smoothing period applied inside [pine]ta.dmi()[/pine] to derive the signal line (lensig). Low (e.g. 1): raw, unsmoothed ADX. High (e.g. 13): heavily smoothed ADX that lags but reduces whipsaws. Default: 3.
[/list]

[b]Usage Notes[/b]

[list]
[*]A green or red background is a confluence signal, not a standalone entry. Use it to confirm setups identified on your primary chart — price action, structure, or another trend tool.
[*]When the background is absent despite a strong price move, treat this as a caution flag. Either ATR is contracting (move may be running out of energy) or ADX disagrees with direction (possible counter-trend move).
[*]The DI threshold of 15 acts as a minimum directional noise filter. In low-volatility instruments or compressed consolidation phases, ADX rarely satisfies this condition — this is intentional behaviour, not a bug.
[*]The Fibonacci-constrained length inputs encourage harmonic consistency across ATR and ADX settings. Consider pairing lengths that share a ratio — for example ATR 13 with ADX 34, or ATR 21 with ADX 55.
[*]On shorter timeframes (1m–5m), set ATR Length to 5 or 8 and ADX Length to 13 or 21 for responsive signals. On daily or weekly charts, 34/89 or 55/144 combinations work well.
[*]This indicator plots in a separate pane. Keep your price chart uncluttered — the background colour bleeds through to the main chart, providing context without requiring you to watch the pane constantly.
[/list]

[b]Recommended Pairings[/b]

This indicator pairs well with a trend-following overlay such as a Hull MA, VWAP, or a multi-timeframe EMA ribbon to confirm the broader bias before the background activates. Volume indicators — particularly Volume Delta or On-Balance Volume — add a useful layer of confirmation when the background fires, helping distinguish absorption-driven moves from thin-market noise. For Indian derivative traders, pairing with an open-interest change indicator on [symbol="NSE:NIFTY"]NSE:NIFTY[/symbol] or [symbol="NSE:BANKNIFTY"]NSE:BANKNIFTY[/symbol] options can sharpen entry timing during background signals.

## Source Code

````pine
//@version=6
indicator(title="ADX Filtered Average True Range", shorttitle="FilterATR", overlay=false, timeframe="", timeframe_gaps=true)

var GATR = "ADX Filtered ATR"
atrlen = input.int(title="ATR - Length", defval=13, options = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946], group = GATR, inline = "1")
smoothing = input.string(title="Smoothing", defval="RMA", options=["SWMA", "RMA", "SMA", "EMA", "VWMA", "WMA"], group = GATR, inline = "1")

adxlen = input.int(34, title="ADX - Length", options = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946], group = GATR, inline = "2")
lensig = input.int(3, title="Smoothing", options = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946], group = GATR, inline = "2")

[diplus, diminus, adx] = ta.dmi(adxlen, lensig)

sadx = ta.swma(adx)
// plot(sadx, color=color.teal, title="ADX")

ADXUp = sadx > sadx[1] and adx > sadx and (diplus > diplus[1] or diplus > diminus) and diplus > 15
ADXDn = sadx > sadx[1] and adx > sadx and (diminus > diminus[1] or diminus > diplus) and diminus > 15

ma_function(source, atrlen) =>
    switch smoothing
        "SWMA"=> ta.swma(source)
        "RMA" => ta.rma(source, atrlen)
        "SMA" => ta.sma(source, atrlen)
        "EMA" => ta.ema(source, atrlen)
        "VWMA" => ta.vwma(source, atrlen)
        => ta.wma(source, atrlen)

atr = ma_function(ta.tr(true), atrlen)
atrs = ta.swma(atr)

ATRExpanding = (atrs > atrs[1] and atr > atrs)

plot(atr, title = "ATR", color=color.new(#B71C1C, 0))
plot(atrs, title = "ATRS", color = ATRExpanding ? color.green : color.white, linewidth = 3)

bgcolor(ATRExpanding and ADXUp and close > open ? color.new(color.green, 50) : ATRExpanding and ADXDn and close < open ? color.new(color.red, 50) : na)
````
