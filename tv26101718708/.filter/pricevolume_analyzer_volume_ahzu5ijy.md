# Price-Volume Analyzer [Volume]

- url: https://www.tradingview.com/script/aHZU5ijy-Price-Volume-Analyzer-Volume/
- type: indicator
- pine_id: PUB;ffe1d036738d432bb49d7f452d7b2e40
- version: 1.0

## Description

Volume tells you how much trading happened. Spread — the range of the bar — tells you how far price was willing to travel for it. Read together, the relationship between the two can say more than either alone: a market that moves a long way on almost no volume is not the same as one that barely moves while volume floods in. Price-Volume Analyzer measures each bar's spread and volume against their own recent averages and flags two relationships where the two pull against each other. It is an observation tool, not a signal service — it marks a condition on the chart and leaves the read to you.

[b]HOW IT WORKS[/b]

The tool keeps a moving average of spread (high - low) and a moving average of volume, then compares the current bar to both. A single threshold multiplier sets where "high" and "low" begin: above the multiplier is treated as high or wide, below its inverse is treated as low or narrow, and everything in between is normal. Two relationships are singled out.


WL — Wide Spread + Low Volume — a bar that travels a long range on unusually light volume. Price moved far without much trade behind it, which can be a sign of a thin, easily-pushed market rather than genuine participation — a manipulation risk worth noticing. It is marked with an x above the bar.
NH — Narrow Spread + High Volume — a bar that holds a tight range while volume runs unusually high. A lot of trade changing hands without price moving far is the classic shape of accumulation or distribution: someone is active, but price is being held. Direction is read from the bar's body — a bar that closes up is marked as possible accumulation, a bar that closes flat or down as possible distribution. It is marked with a diamond.
Info table — a small live readout in the corner shows the current bar's spread status, volume status, the combined P-V state, and each value as a percentage of its own average, so you can see why a bar was or was not flagged.


Signals, optional background, optional bar coloring, and alerts are all evaluated on confirmed (closed) bars only. A bar's spread and volume are not final until it closes, so nothing is marked on a forming bar and a mark does not move once printed.


Spread and volume are each compared to their own moving average using one threshold multiplier
Wide-spread / low-volume bars are flagged as WL; narrow-spread / high-volume bars as NH, with direction read from the body
Marks, coloring, and alerts commit on bar close; the info table reports the live bar's status without flagging it


[b]HOW TO READ[/b]


WL (wide spread, low volume) is a long move that little volume paid for. It flags a bar that could be a thin, low-participation push — a manipulation risk, not a confirmed one. It says watch this move, nothing more.
NH (narrow spread, high volume) is heavy trade that did not move price far. That is the footprint of accumulation or distribution; the close direction colors it as the possible accumulation or distribution side. It points to activity under a held price — it does not promise where price goes next.
The percentages in the info table are the point of reference: a spread or volume reading far above 100 percent of its average is what pushes a bar into wide or high; far below is what makes it narrow or low. Tune the threshold to match how strict you want that to be.
An anomaly is a flag on the relationship between price and volume — a reason to look closer, not a buy or sell instruction. Marking a WL or an NH says nothing about whether price will reverse, continue, or do neither. The tool reads the bar; the decision is yours.


[b]INPUTS[/b]


Volume MA Length / Spread MA Length — the lookback for each average the current bar is compared against (default 20).
Anomaly Threshold (multiplier) — how far from average counts as high or low. Above the multiplier is high/wide, below its inverse is low/narrow (default 1.3); raise it for fewer, more extreme flags, lower it for more.
Show WL Signals / Show NH Signals — enable each anomaly mark independently.
WL Color / NH Bullish Color / NH Bearish Color — colors for the marks.
Show Info Table — the corner readout of the live bar's spread, volume, and P-V status.
Anomaly Bar Background — shade the background of a flagged bar (default off).
Color Anomaly Bars — recolor the candle body of a flagged bar (default off).


[b]ALERTS[/b]


WL Signal fires on a confirmed wide-spread / low-volume bar.
NH Bullish and NH Bearish fire on a confirmed narrow-spread / high-volume bar, split by close direction; NH Any fires on either.
All fire on confirmed (closed) bars — set them up with "Once Per Bar Close."


[b]NOTES & LIMITS[/b]

This is an observation tool, not a forecast. It needs volume data to work: the whole method rests on comparing volume to its own average, so it is only as meaningful as the volume feed underneath it. On instruments with genuine traded volume — futures and crypto — that comparison is at its most reliable. On forex and CFDs the "volume" is tick volume (the number of price updates, not contracts traded), so the readings there are looser and should be treated with more caution; on a symbol that reports no volume at all the anomalies cannot be computed meaningfully and should not be relied on. WL and NH are possibilities the price-volume relationship raises — a manipulation risk, a possible accumulation or distribution — not confirmed outcomes; an anomaly is a sign to look closer, and marking one says nothing about whether price will turn or continue. Signals, coloring, and alerts are evaluated on confirmed (closed) bars only, so nothing is marked on a forming bar and a mark does not move once printed; the info table reports the live bar's status but does not flag it. The lower-timeframe of the chart is read as it closes and the tool does not leak the future. No profit, win-rate, or guarantee claim. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// Price-Volume Analyzer [Volume] — Attribution required: credit "ElisTools" in any reuse or derivative.
//@version=6
indicator("Price-Volume Analyzer [Volume]", shorttitle="P-V", overlay=true)
// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grp_pv = "Price-Volume Settings"
pv_vol_ma_len    = input.int(20, "Volume MA Length", minval=5, maxval=50, group=grp_pv)
pv_spread_ma_len = input.int(20, "Spread MA Length", minval=5, maxval=50, group=grp_pv)
pv_threshold     = input.float(1.3, "Anomaly Threshold (multiplier)", minval=1.1, maxval=2.0, step=0.1, group=grp_pv, tooltip="If spread/volume is above this multiplier it is treated as 'high'; below its inverse it is treated as 'low'.")
grp_vis = "Visual Settings"
show_wl       = input.bool(true,  "Show WL Signals", group=grp_vis)
show_nh       = input.bool(true,  "Show NH Signals", group=grp_vis)
wl_color      = input.color(color.blue, "WL Color", group=grp_vis)
nh_bull_color = input.color(color.lime,   "NH Bullish Color", group=grp_vis)
nh_bear_color = input.color(color.red,    "NH Bearish Color", group=grp_vis)
show_table    = input.bool(true,  "Show Info Table", group=grp_vis)
show_bg       = input.bool(false, "Anomaly Bar Background", group=grp_vis)
grp_bar = "Bar Coloring"
color_bars = input.bool(false, "Color Anomaly Bars", group=grp_bar)
// ══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════
// Confirmed-bar gate: signals, coloring and alerts only emit on closed bars (no repaint)
bool barConfirmed = barstate.isconfirmed
// Spread (candle range)
float spread = high - low
// Averages
float avgSpread = ta.sma(spread, pv_spread_ma_len)
float avgVolume = ta.sma(volume, pv_vol_ma_len)
// Spread categories
bool isWideSpread   = spread > avgSpread * pv_threshold
bool isNarrowSpread = spread < avgSpread / pv_threshold
// Volume categories
bool isHighVol = volume > avgVolume * pv_threshold
bool isLowVol  = volume < avgVolume / pv_threshold
// ══════════════════════════════════════════════════════════════════════════════
// ANOMALY DETECTION
// ══════════════════════════════════════════════════════════════════════════════
// WL: Wide Spread + Low Volume (manipulation risk)
bool isWL = isWideSpread and isLowVol
// NH: Narrow Spread + High Volume (accumulation / distribution)
bool isNH = isNarrowSpread and isHighVol
// NH direction (close > open = bullish, otherwise bearish / doji)
bool isNH_Bull = isNH and close > open
bool isNH_Bear = isNH and close <= open
// ══════════════════════════════════════════════════════════════════════════════
// SIGNALS (confirmed bars only — non-repainting)
// ══════════════════════════════════════════════════════════════════════════════
plotshape(show_wl and isWL and barConfirmed, "WL Signal", style=shape.xcross, location=location.abovebar, color=wl_color, size=size.tiny)
plotshape(show_nh and isNH_Bull and barConfirmed, "NH Bullish", style=shape.diamond, location=location.belowbar, color=nh_bull_color, size=size.tiny)
plotshape(show_nh and isNH_Bear and barConfirmed, "NH Bearish", style=shape.diamond, location=location.abovebar, color=nh_bear_color, size=size.tiny)
// Background (optional)
color bgCol = na
if show_bg and barConfirmed
    if isWL
        bgCol := color.new(wl_color, 90)
    else if isNH_Bull
        bgCol := color.new(nh_bull_color, 90)
    else if isNH_Bear
        bgCol := color.new(nh_bear_color, 90)
bgcolor(bgCol)
// Bar coloring (optional)
color barCol = na
if color_bars and barConfirmed
    if isWL
        barCol := wl_color
    else if isNH_Bull
        barCol := nh_bull_color
    else if isNH_Bear
        barCol := nh_bear_color
barcolor(barCol)
// ══════════════════════════════════════════════════════════════════════════════
// INFO TABLE (live readout of the current bar)
// ══════════════════════════════════════════════════════════════════════════════
var table infoTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_width=1)
if show_table and barstate.islast
    // Header
    table.cell(infoTable, 0, 0, "P-V ANALYZER", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 60))
    table.cell(infoTable, 1, 0, "", bgcolor=color.new(color.blue, 60))
    // Spread status
    string spreadText = isWideSpread ? "WIDE" : isNarrowSpread ? "NARROW" : "NORMAL"
    color  spreadCol  = isWideSpread ? color.orange : isNarrowSpread ? color.aqua : color.gray
    table.cell(infoTable, 0, 1, "Spread", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, spreadText, text_color=spreadCol, text_size=size.small)
    // Volume status
    string volText = isHighVol ? "HIGH" : isLowVol ? "LOW" : "NORMAL"
    color  volCol  = isHighVol ? color.lime : isLowVol ? color.red : color.gray
    table.cell(infoTable, 0, 2, "Volume", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, volText, text_color=volCol, text_size=size.small)
    // P-V status
    string pvText = isWL ? "WL - WARNING!" : isNH_Bull ? "NH - ACCUM" : isNH_Bear ? "NH - DISTRIB" : "NORMAL"
    color  pvCol  = isWL ? wl_color : isNH_Bull ? nh_bull_color : isNH_Bear ? nh_bear_color : color.gray
    table.cell(infoTable, 0, 3, "P-V", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, pvText, text_color=pvCol, text_size=size.small)
    // Spread value (absolute + percent of its average)
    string spreadVal = str.tostring(spread, format.mintick) + " (" + str.tostring(math.round(spread / avgSpread * 100, 0)) + "%)"
    table.cell(infoTable, 0, 4, "Spread Val", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 4, spreadVal, text_color=color.white, text_size=size.tiny)
    // Volume value (absolute + percent of its average)
    string volVal = str.tostring(volume, format.volume) + " (" + str.tostring(math.round(volume / avgVolume * 100, 0)) + "%)"
    table.cell(infoTable, 0, 5, "Vol Val", text_color=color.white, text_size=size.tiny)
    table.cell(infoTable, 1, 5, volVal, text_color=color.white, text_size=size.tiny)
// ══════════════════════════════════════════════════════════════════════════════
// ALERTS (confirmed bars only — non-repainting)
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(isWL and barConfirmed,      "WL Signal",  "Wide Spread + Low Volume - manipulation risk!")
alertcondition(isNH_Bull and barConfirmed, "NH Bullish", "Narrow Spread + High Volume - possible accumulation")
alertcondition(isNH_Bear and barConfirmed, "NH Bearish", "Narrow Spread + High Volume - possible distribution")
alertcondition(isNH and barConfirmed,      "NH Any",     "Narrow Spread + High Volume detected")
````
