<!-- tradingview-pine-id: PUB;347cd004621043a4a5a3366a1f4c54e9 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Period Rolling VWAP (True TF-Independent)

Source: https://www.tradingview.com/script/NlwvjyCc-Multi-Period-VWAP-7D-30D-90D/

## Description

This indicator plots three rolling Volume-Weighted Average Price (VWAP) lines calculated over trailing 7-day, 30-day, and 90-day windows, giving you a read on where price sits relative to volume-weighted "fair value" across short, medium, and long-term horizons.

Unlike a standard anchored VWAP that resets to zero at a fixed point (session, week, month), these lines are true rolling averages — they continuously reflect the most recent N days of trading and shift smoothly bar to bar, making them useful for spotting mean-reversion zones, confluence with order blocks/key levels, and gauging trend strength when the shorter VWAP is stacked above or below the longer ones.

Features:

- Adjustable lookback lengths for all three periods (defaults: 7 / 30 / 90 days)
- Toggle each VWAP on/off independently
- Customizable colors per line
- Choice of price source (HLC3, Close, or OHLC4)
- Optional "confirmed bars only" mode to prevent the lines from repainting as the current day's volume accumulates
- Live value labels on the last bar for each active VWAP

Built with crypto's 24/7 markets in mind, so the daily boundaries used for the rolling calculation aren't disrupted by traditional session gaps.

---

## Source Code

````pine
//@version=6
indicator("Multi-Period Rolling VWAP (True TF-Independent)", shorttitle="Rolling Multi-Day VWAP [DarthTrader0x]", overlay=true, max_labels_count=20)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
grp1 = "Period Lengths (in days)"
len7   = input.int(7,  "Short-Term Period",  minval=1, group=grp1)
len30  = input.int(30, "Medium-Term Period", minval=1, group=grp1)
len90  = input.int(90, "Long-Term Period",   minval=1, group=grp1)

grp2 = "Visibility"
show7   = input.bool(true, "Show Short-Term VWAP",  group=grp2)
show30  = input.bool(true, "Show Medium-Term VWAP", group=grp2)
show90  = input.bool(true, "Show Long-Term VWAP",   group=grp2)

grp3 = "Colors"
col7   = input.color(color.new(color.yellow, 0), "Short-Term Color",  group=grp3)
col30  = input.color(color.new(color.orange, 0), "Medium-Term Color", group=grp3)
col90  = input.color(color.new(color.red, 0),    "Long-Term Color",   group=grp3)

grp4 = "Source"
srcType = input.string("hlc3", "Price Source", options=["hlc3", "close", "ohlc4"], group=grp4)

// ─────────────────────────────
// FUNCTION that runs entirely on the daily timeframe
// (has access to the full daily history of the symbol)
// ─────────────────────────────
f_rolling_vwap(_len) =>
    src = srcType == "hlc3" ? hlc3 : srcType == "close" ? close : ohlc4
    pv  = src * volume
    // Simple and reliable rolling sum using cumulative technique
    cumPV  = ta.cum(pv)
    cumVol = ta.cum(volume)
    // Value from _len days ago (handles the first bars gracefully)
    pvSum  = cumPV  - cumPV[_len]
    volSum = cumVol - cumVol[_len]
    volSum > 0 ? pvSum / volSum : na

// Request the three VWAPs calculated on the daily chart
// These numbers are now identical on 1m, 5m, 1H, Daily, etc.
vwap7  = request.security(syminfo.tickerid, "1D", f_rolling_vwap(len7),  lookahead=barmerge.lookahead_off)
vwap30 = request.security(syminfo.tickerid, "1D", f_rolling_vwap(len30), lookahead=barmerge.lookahead_off)
vwap90 = request.security(syminfo.tickerid, "1D", f_rolling_vwap(len90), lookahead=barmerge.lookahead_off)

// ─────────────────────────────
// PLOTS
// ─────────────────────────────
plot(show7  ? vwap7  : na, title="7D VWAP",  color=col7,  linewidth=2)
plot(show30 ? vwap30 : na, title="30D VWAP", color=col30, linewidth=2)
plot(show90 ? vwap90 : na, title="90D VWAP", color=col90, linewidth=2)

// ─────────────────────────────
// LABELS (managed)
// ─────────────────────────────
var label lab7  = na
var label lab30 = na
var label lab90 = na

if barstate.islast
    if show7 and not na(vwap7)
        txt = str.tostring(len7) + "D VWAP: " + str.tostring(vwap7, format.mintick)
        if na(lab7)
            lab7 := label.new(bar_index, vwap7, txt, xloc=xloc.bar_index,
                 style=label.style_label_left, color=col7, textcolor=color.black, size=size.small)
        else
            label.set_xy(lab7, bar_index, vwap7)
            label.set_text(lab7, txt)
            label.set_color(lab7, col7)
    else if not na(lab7)
        label.delete(lab7)
        lab7 := na

    if show30 and not na(vwap30)
        txt = str.tostring(len30) + "D VWAP: " + str.tostring(vwap30, format.mintick)
        if na(lab30)
            lab30 := label.new(bar_index, vwap30, txt, xloc=xloc.bar_index,
                 style=label.style_label_left, color=col30, textcolor=color.black, size=size.small)
        else
            label.set_xy(lab30, bar_index, vwap30)
            label.set_text(lab30, txt)
            label.set_color(lab30, col30)
    else if not na(lab30)
        label.delete(lab30)
        lab30 := na

    if show90 and not na(vwap90)
        txt = str.tostring(len90) + "D VWAP: " + str.tostring(vwap90, format.mintick)
        if na(lab90)
            lab90 := label.new(bar_index, vwap90, txt, xloc=xloc.bar_index,
                 style=label.style_label_left, color=col90, textcolor=color.white, size=size.small)
        else
            label.set_xy(lab90, bar_index, vwap90)
            label.set_text(lab90, txt)
            label.set_color(lab90, col90)
    else if not na(lab90)
        label.delete(lab90)
        lab90 := na
````
