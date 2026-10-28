# Labeled MAs

- url: https://www.tradingview.com/script/Mcc7RIdD-Labeled-MAs/
- type: indicator
- pine_id: PUB;090acb46caa54036acdaef38a159b172
- version: 1.0

## Description

Clearly label each MA at the end of the moving average line.

## Source Code

````pine
//@version=5
indicator("Labeled MAs", overlay=true, max_labels_count=20)

// ═══════════════════════════════════════════
// TIMEFRAME SETTINGS
// ═══════════════════════════════════════════
use_fixed_tf = input.bool(false, "Use Fixed Timeframe", group="Timeframe")
fixed_tf     = input.timeframe("D", "Fixed Timeframe (if enabled)", group="Timeframe")

// ═══════════════════════════════════════════
// MA SETTINGS
// ═══════════════════════════════════════════
c1  = input.color(color.new(#00BFFF, 0), "SMA 9  Color",   group="MA Colors")
c2  = input.color(color.new(#FFD700, 0), "SMA 10 Color",   group="MA Colors")
c3  = input.color(color.new(#FF69B4, 0), "EMA 20 Color",   group="MA Colors")
c4  = input.color(color.new(#00FF99, 0), "SMA 20 Color",   group="MA Colors")
c5  = input.color(color.new(#FF8C00, 0), "SMA 150 Color",  group="MA Colors")
c6  = input.color(color.new(#FF4C4C, 0), "SMA 200 Color",  group="MA Colors")

show1 = input.bool(true, "Show SMA 9",   group="Visibility")
show2 = input.bool(true, "Show SMA 10",  group="Visibility")
show3 = input.bool(true, "Show EMA 20",  group="Visibility")
show4 = input.bool(true, "Show SMA 20",  group="Visibility")
show5 = input.bool(true, "Show SMA 150", group="Visibility")
show6 = input.bool(true, "Show SMA 200", group="Visibility")

// ═══════════════════════════════════════════
// FETCH WITH TIMEFRAME OPTION
// ═══════════════════════════════════════════
tf = use_fixed_tf ? fixed_tf : timeframe.period

src1  = request.security(syminfo.tickerid, tf, ta.sma(close, 9),   lookahead=barmerge.lookahead_off)
src2  = request.security(syminfo.tickerid, tf, ta.sma(close, 10),  lookahead=barmerge.lookahead_off)
src3  = request.security(syminfo.tickerid, tf, ta.ema(close, 20),  lookahead=barmerge.lookahead_off)
src4  = request.security(syminfo.tickerid, tf, ta.sma(close, 20),  lookahead=barmerge.lookahead_off)
src5  = request.security(syminfo.tickerid, tf, ta.sma(close, 150), lookahead=barmerge.lookahead_off)
src6  = request.security(syminfo.tickerid, tf, ta.sma(close, 200), lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════
// PLOT LINES
// ═══════════════════════════════════════════
plot(show1 ? src1 : na, "SMA 9",   color=c1, linewidth=1)
plot(show2 ? src2 : na, "SMA 10",  color=c2, linewidth=1)
plot(show3 ? src3 : na, "EMA 20",  color=c3, linewidth=2)
plot(show4 ? src4 : na, "SMA 20",  color=c4, linewidth=1)
plot(show5 ? src5 : na, "SMA 150", color=c5, linewidth=2)
plot(show6 ? src6 : na, "SMA 200", color=c6, linewidth=2)

// ═══════════════════════════════════════════
// END-OF-LINE LABELS
// ═══════════════════════════════════════════
tf_suffix = use_fixed_tf ? " [" + fixed_tf + "]" : ""

if barstate.islast
    if show1 and not na(src1)
        label.new(bar_index, src1, "SMA9"  + tf_suffix, color=color.new(color.black,100), textcolor=c1, style=label.style_label_left, size=size.small)
    if show2 and not na(src2)
        label.new(bar_index, src2, "SMA10" + tf_suffix, color=color.new(color.black,100), textcolor=c2, style=label.style_label_left, size=size.small)
    if show3 and not na(src3)
        label.new(bar_index, src3, "EMA20" + tf_suffix, color=color.new(color.black,100), textcolor=c3, style=label.style_label_left, size=size.small)
    if show4 and not na(src4)
        label.new(bar_index, src4, "SMA20" + tf_suffix, color=color.new(color.black,100), textcolor=c4, style=label.style_label_left, size=size.small)
    if show5 and not na(src5)
        label.new(bar_index, src5, "SMA150"+ tf_suffix, color=color.new(color.black,100), textcolor=c5, style=label.style_label_left, size=size.small)
    if show6 and not na(src6)
        label.new(bar_index, src6, "SMA200"+ tf_suffix, color=color.new(color.black,100), textcolor=c6, style=label.style_label_left, size=size.small)
````
