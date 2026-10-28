# 2nd Day Stock Scanner

- url: https://www.tradingview.com/script/NXe1u6ba-2nd-Day-Stock-Scanner/
- type: indicator
- pine_id: PUB;5f87a2645a55483ba7876efcf1684435
- version: 3.0

## Description

[b]2ND DAY STOCK SCANNER[/b]

A Pine Screener-ready indicator that flags stocks having an "in play" session — the kind of session that sets up a classic 2nd Day Play. Run it across a watchlist or the broader market to build a daily list of names worth watching for continuation the next session.


[b]THE 2ND DAY PLAY CONCEPT[/b]

A stock becomes "in play" when a catalyst — earnings, guidance, an FDA decision, an upgrade/downgrade, a contract win, a short squeeze, breaking news — pulls in enough participants that the stock trades with unusual size and unusual range for a full session. That session (Day 1) prints levels — the high and the low — that carry real weight, because so many market participants transacted around them.

On the next session (Day 2), those Day 1 levels often become the reference points for continuation: a break above Day 1's high can trigger fresh buying from traders who missed the move or are adding to winners; a break below Day 1's low can do the same on the short side. This is the "2nd Day Play" — trading the follow-through, using yesterday's range as the map.

This indicator's job is to find Day 1: the session that qualifies as genuinely "in play," so you know which names to build a Day 2 plan around.


[b]WHAT IT FLAGS[/b]

A session qualifies as a match when ALL of the following are true on that bar (daily timeframe):

1. Outsized move — the close is up or down at least a configurable % (default 3%) versus the prior day's close.

2. Strong directional close — the close falls within the top or bottom 20% (configurable) of the day's own high-low range. An up day closing near its high, or a down day closing near its low, signals conviction rather than a fade.

3. Elevated relative volume (RVOL) — volume exceeds a configurable % of the average volume over the prior N days (default: 100% of a 50-day average, i.e. above-normal turnover).

4. Volatility expansion — the day's true range exceeds the recent Average True Range (default 14-period), meaning the stock moved more than its own normal volatility would suggest.

By default the script also requires the move direction, close location, and volume/volatility expansion to all point the same way (an up move that closes strong = bullish match; a down move that closes weak = bearish match). This directional-alignment requirement can be turned off in settings if you want looser matching.


[b]READING THE OUTPUT[/b]

- Scan Match (0/1): the combined signal; this is the one to filter on for a general watchlist.
- Bullish Match / Bearish Match (0/1): directional versions, useful for building separate long and short watchlists.
- Pct Change, Range Position %, RVOL %, Range minus ATR: the underlying metrics, useful for sorting and sanity-checking why a name matched.
- On a chart: a green/red background tint, a triangle marker, and a small "2D up / 2D down" label mark matching sessions; an info table in the corner shows live values for the current bar.
- Alerts: "Bullish 2nd Day Scan," "Bearish 2nd Day Scan," and "Any 2nd Day Scan Match" fire on chart instances of the script (Pine Screener itself does not push alerts — see setup notes below).


[b]SETTINGS[/b]

- Min |% change| — default 3% — minimum move vs. prior close
- Top/Bottom % of range — default 20% — how close to the high/low the close must be
- Min RVOL % — default 100% — volume vs. average volume threshold
- Avg volume lookback — default 50 bars — window for the volume average
- ATR length — default 14 — window for the volatility baseline
- Require direction match — default on — whether move direction must match close location


[b]WHEN IT'S MOST VALUABLE[/b]

This indicator is a filter, not a trade signal. It's most useful run at or after the close (or scanned intraday for names already meeting the criteria in real time) to surface candidates that just had a genuine catalyst day — the kind of session worth carrying onto tomorrow's watchlist. It's less useful, and can produce false positives, on thinly traded or low-priced names where volume and range statistics are naturally erratic, or around known binary events (earnings, FDA dates) where a gap can satisfy the range/volume criteria without real intraday conviction. Always confirm a match against the news/catalyst driving the move, and build your own Day 2 execution plan (breakout, pullback, opening-range tactics) around the flagged levels — the scanner finds the candidates, it doesn't time the entry.


[b]SETTING UP THE PINE SCREENER[/b]

1. In TradingView, open Pine Screener (left toolbar, or Products > Screeners > Pine Screener).

2. Pick your universe from the Watchlist dropdown — a saved watchlist, or one of TradingView's broader market lists.

3. Load this script from the script-select dropdown next to the watchlist selector.

4. Click the script's name/settings icon to open its Settings dialog inside the Screener. This is a separate instance from any chart — inputs you change on a chart do not carry over, and vice versa. Set your thresholds here and click Apply.

5. Use the + button to add the columns you want visible: Scan Match, Bullish Match, Bearish Match, Pct Change, Range Position %, RVOL %, Range minus ATR.

6. Click on the Scan Match column pill and set a filter, e.g. "Greater than 0.5" (since the output is 0 or 1, this isolates matches). Use Bullish Match / Bearish Match instead if you want a directional-only list.

7. Click Scan. Sort by any column to review results, and use the unfiltered metric columns to see why each name matched.

8. For live, per-symbol alerts during the session, add the script to that symbol's chart individually and create an alert from one of its three alert conditions — the Screener is a point-in-time scan, not a persistent alert engine.


[b]DISCLAIMER[/b]

For informational and educational purposes only — not financial advice. This scanner identifies stocks meeting a set of historical price/volume conditions; it does not predict future performance. Always do your own research and manage your own risk.

## Source Code

````pine
//@version=6
indicator("2nd Day Stock Scanner", overlay=true, shorttitle="2nd Day")

// ═══════════════════════════════════════════════════════════════════
// Run this on the DAILY timeframe. Designed to work with TradingView's
// Pine Screener (scan the whole market / a watchlist against the
// "Scan Match" plot) as well as on individual charts with alerts.
// ═══════════════════════════════════════════════════════════════════

// ── Inputs ─────────────────────────────────────────────────────────
grpMove = "1. Price Move (vs prior close)"
moveThreshold = input.float(3.0, "Min |% change|", minval=0, step=0.1, group=grpMove)

grpRange = "2. Close Location in Daily Range"
rangeThreshold = input.float(20.0, "Top/Bottom % of range", minval=1, maxval=50, step=1, group=grpRange)

grpVol = "3. Relative Volume"
rvolThreshold = input.float(100.0, "Min RVOL % (100 = avg volume)", minval=0, step=10, group=grpVol)
volLength = input.int(50, "Avg volume lookback (bars)", minval=1, group=grpVol)

grpATR = "4. Volatility Expansion"
atrLength = input.int(14, "ATR length", minval=1, group=grpATR)

grpLogic = "Matching Logic"
requireAlignment = input.bool(true, "Require direction match (up+top-close / down+bottom-close)", group=grpLogic)

grpVis = "Display"
showLabels = input.bool(true, "Show labels on chart", group=grpVis)
showBg = input.bool(true, "Highlight background", group=grpVis)
showTable = input.bool(true, "Show info table", group=grpVis)
tablePosInput = input.string("Top Right", "Info table position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpVis)
tableSizeInput = input.string("Normal", "Info table text size", options=["Tiny", "Small", "Normal", "Large"], group=grpVis)

tablePosition = switch tablePosInput
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right
    => position.top_right

tableTextSize = switch tableSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.normal

// ── Criterion 1: % move vs prior close ────────────────────────────
pctChange = (close - close[1]) / close[1] * 100
moveCond = math.abs(pctChange) >= moveThreshold
isUpMove = pctChange > 0

// ── Criterion 2: close location within the day's range ────────────
dayRange = high - low
rangePos = dayRange != 0 ? (close - low) / dayRange * 100 : 50   // 0 = at low, 100 = at high
closedTop = rangePos >= (100 - rangeThreshold)
closedBottom = rangePos <= rangeThreshold
rangeCond = closedTop or closedBottom

// ── Criterion 3: RVOL (today's volume vs avg of prior N days) ─────
avgVolume = ta.sma(volume, volLength)[1]   // excludes current, still-forming bar
rvol = avgVolume != 0 ? volume / avgVolume * 100 : na
rvolCond = not na(rvol) and rvol > rvolThreshold

// ── Criterion 4: today's range expanded beyond recent ATR ─────────
dailyATR = ta.atr(atrLength)
trueRange = ta.tr(true)
atrCond = trueRange > dailyATR[1]   // compare vs prior ATR to avoid self-reference

// ── Combine ─────────────────────────────────────────────────────────
bullishMatch = isUpMove and moveCond and closedTop and rvolCond and atrCond
bearishMatch = (not isUpMove) and moveCond and closedBottom and rvolCond and atrCond
looseMatch = moveCond and rangeCond and rvolCond and atrCond

scanCondition = requireAlignment ? (bullishMatch or bearishMatch) : looseMatch
bullish = requireAlignment ? bullishMatch : (looseMatch and isUpMove and closedTop)
bearish = requireAlignment ? bearishMatch : (looseMatch and not isUpMove and closedBottom)

// ── Plots (drive Pine Screener / Data Window) ──────────────────────
plot(scanCondition ? 1 : 0, title="Scan Match", display=display.data_window)
plot(bullish ? 1 : 0, title="Bullish Match", display=display.data_window)
plot(bearish ? 1 : 0, title="Bearish Match", display=display.data_window)
plot(pctChange, title="Pct Change", display=display.data_window)
plot(rangePos, title="Range Position %", display=display.data_window)
plot(rvol, title="RVOL %", display=display.data_window)
plot(trueRange - dailyATR, title="Range minus ATR", display=display.data_window)

// ── Visuals ─────────────────────────────────────────────────────────
bgcolor(showBg and bullish ? color.new(color.green, 85) : showBg and bearish ? color.new(color.red, 85) : na)

plotshape(showLabels and bullish, title="Bullish 2nd Day Setup", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(showLabels and bearish, title="Bearish 2nd Day Setup", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

if showLabels and scanCondition
    label.new(bar_index, bullish ? low : high, bullish ? "2D▲" : "2D▼", style=bullish ? label.style_label_up : label.style_label_down, color=bullish ? color.green : color.red, textcolor=color.white, size=size.small)

// ── Alerts ──────────────────────────────────────────────────────────
alertcondition(bullish, title="Bullish 2nd Day Scan", message="{{ticker}} ({{interval}}): Bullish 2nd Day setup")
alertcondition(bearish, title="Bearish 2nd Day Scan", message="{{ticker}} ({{interval}}): Bearish 2nd Day setup")
alertcondition(scanCondition, title="Any 2nd Day Scan Match", message="{{ticker}} ({{interval}}): 2nd Day scan match")

// ── Info table (last bar) ──────────────────────────────────────────
tableBg = color.new(#131722, 5)   // solid dark backdrop, independent of chart theme
headerBg = color.new(#2A2E39, 0)

var table infoTable = table.new(tablePosition, 3, 6, bgcolor=tableBg, border_width=1, border_color=color.new(color.gray, 40), frame_width=1, frame_color=color.new(color.gray, 40))
if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "2nd Day Scan", bgcolor=headerBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 1, 0, scanCondition ? "MATCH" : "-", bgcolor=scanCondition ? (bullish ? color.green : color.red) : headerBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 2, 0, "Result of all 4 criteria", bgcolor=headerBg, text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 0, 1, "% Change", bgcolor=tableBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 1, 1, str.tostring(pctChange, "#.##") + "%", bgcolor=tableBg, text_color=moveCond ? color.green : color.red, text_size=tableTextSize)
    table.cell(infoTable, 2, 1, "Move vs prior close", bgcolor=tableBg, text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 0, 2, "Range Pos", bgcolor=tableBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 1, 2, str.tostring(rangePos, "#.##") + "%", bgcolor=tableBg, text_color=rangeCond ? color.green : color.red, text_size=tableTextSize)
    table.cell(infoTable, 2, 2, "Close location in day's range (0=low, 100=high)", bgcolor=tableBg, text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 0, 3, "RVOL", bgcolor=tableBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 1, 3, str.tostring(rvol, "#.##") + "%", bgcolor=tableBg, text_color=rvolCond ? color.green : color.red, text_size=tableTextSize)
    table.cell(infoTable, 2, 3, "Volume vs avg (100% = normal)", bgcolor=tableBg, text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 0, 4, "Range vs ATR", bgcolor=tableBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 1, 4, str.tostring(trueRange, "#.##") + " / " + str.tostring(dailyATR[1], "#.##"), bgcolor=tableBg, text_color=atrCond ? color.green : color.red, text_size=tableTextSize)
    table.cell(infoTable, 2, 4, "Today's range vs recent ATR", bgcolor=tableBg, text_color=color.gray, text_size=size.tiny)
    table.cell(infoTable, 0, 5, "Direction", bgcolor=tableBg, text_color=color.white, text_size=tableTextSize)
    table.cell(infoTable, 1, 5, isUpMove ? "Up" : "Down", bgcolor=tableBg, text_color=isUpMove ? color.green : color.red, text_size=tableTextSize)
    table.cell(infoTable, 2, 5, "Up or down vs prior close", bgcolor=tableBg, text_color=color.gray, text_size=size.tiny)
````
