<!-- tradingview-pine-id: PUB;2823de14622049369550b448c7631265 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Atty Short Volume

Source: https://www.tradingview.com/script/kOdaYkhv-Atty-Short-Volume/

## Description

Plots daily short-sale volume as a percentage of total volume, below the chart, for US/FINRA-reported symbols. Uses TradingView's per-symbol short-volume feed, so it auto-updates daily.

IMPORTANT: this is SHORT SALE VOLUME, not SHORT INTEREST (percent of float currently sold short). They are different metrics that get casually confused. Short-sale volume includes routine market-maker and algorithmic activity and often runs 30-50% on an entirely ordinary day — it is a daily trading-activity metric, not a measure of how much of a stock's float is held short. For true short interest, check a source like FINRA's official short interest report.

Updates once per day (FINRA daily resolution). Not available for OTC or non-US-listed symbols. Includes a smoothed average line, an adjustable elevated-level reference line, and a small table showing the latest reading and shares float.

---

## Source Code

````pine
//@version=6
indicator("Atty Short Volume", shorttitle="ATTY SHORT", overlay=false)
// Chart preview refreshed 2026-09-11 — indicator shown on its own. Re-shot 2026-09-12 so the indicator pane is actually visible.

maLen = input.int(10, title="Smoothing Length", minval=1)
showMA = input.bool(true, title="Show Smoothed Average")
warnLevel = input.float(50, title="Elevated Level %", minval=0, maxval=100)

shortVol = request.security(syminfo.ticker + "_SHORT_VOLUME", "D", close, ignore_invalid_symbol=true)
totalVol = request.security(syminfo.tickerid, "D", volume)
shortPct = totalVol != 0 ? shortVol / totalVol * 100 : na
maVal = ta.sma(shortPct, maLen)
barColor = shortPct >= warnLevel ? color.new(color.orange, 0) : color.new(color.gray, 30)

plot(shortPct, title="Short Volume %", style=plot.style_columns, color=barColor)
plot(showMA ? maVal : na, title="Smoothed Average", color=color.new(color.aqua, 0), linewidth=2)
hline(warnLevel, title="Elevated Level", color=color.new(color.red, 60), linestyle=hline.style_dashed)

floatShares = syminfo.shares_outstanding_float
floatM = floatShares / 1000000
var table info = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 20), border_width=1)
table.cell(info, 0, 0, "Short Vol %", text_color=color.white, text_size=size.small)
table.cell(info, 1, 0, na(shortPct) ? "N/A" : str.tostring(shortPct, "#.#") + "%", text_color=color.white, text_size=size.small)
table.cell(info, 0, 1, "Float (M)", text_color=color.white, text_size=size.small)
table.cell(info, 1, 1, na(floatShares) ? "N/A" : str.tostring(floatM, "#.##"), text_color=color.white, text_size=size.small)
table.cell(info, 0, 2, "Note", text_color=color.gray, text_size=size.tiny)
table.cell(info, 1, 2, "FINRA short SALE vol, not short interest", text_color=color.gray, text_size=size.tiny)
````
