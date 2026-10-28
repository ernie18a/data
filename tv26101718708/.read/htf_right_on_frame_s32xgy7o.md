# HTF Right on frame

- url: https://www.tradingview.com/script/S32XgY7O-HTF-Right-on-frame/
- type: indicator
- pine_id: PUB;bfd7780f8ae14457a12350edfe7315b0
- version: 1.0

## Description

Shows 4 HR and 1 Hr candles on 15 minute timeframe chart

## Source Code

````pine
//@version=6
indicator("HTF Right", shorttitle="HTF Right", overlay=true, max_boxes_count=100, max_labels_count=100, max_lines_count=200)

// ── Inputs with your preferred defaults ───────
rightOffset   = input.int(20,  "Right Offset", minval=1, maxval=100)
bodyWidth     = input.int(2,   "Body Width", minval=1, maxval=9)
opacity       = input.int(15,  "Opacity (0 = fully opaque)", minval=0, maxval=90, step=5)
showWicks     = input.bool(true, "Show 1H/4H Wicks")
wickWidth     = input.int(1,   "Wick Width", minval=1, maxval=4)
labelSize     = input.string("tiny", "Label Size", options=["tiny", "small", "normal", "large"])

// ── Higher Timeframe Data ─────────────────────
[htf4h_o, htf4h_h, htf4h_l, htf4h_c, htf4h_t] = request.security(syminfo.tickerid, "240", [open, high, low, close, time], lookahead=barmerge.lookahead_off)
[htf1h_o, htf1h_h, htf1h_l, htf1h_c, htf1h_t] = request.security(syminfo.tickerid, "60",  [open, high, low, close, time], lookahead=barmerge.lookahead_off)

new4h = ta.change(htf4h_t) != 0
new1h = ta.change(htf1h_t) != 0

// Colors with your default opacity
bull4h = color.new(color.green, opacity)
bear4h = color.new(color.red,   opacity)
bull1h = color.new(color.lime,  opacity)
bear1h = color.new(color.maroon,opacity)

// ── 4H Candle on Right ────────────────────────
var box   box4h = na
var label lbl4h = na
var line  upperWick4 = na
var line  lowerWick4 = na

left4h   = bar_index + rightOffset
right4h  = left4h + bodyWidth
center4h = left4h + math.round(bodyWidth / 2.0)

if new4h or barstate.isrealtime
    isBull4h = htf4h_c >= htf4h_o
    col4h    = isBull4h ? bull4h : bear4h

    // Body
    if na(box4h)
        box4h := box.new(left4h, math.max(htf4h_o, htf4h_c), right4h, math.min(htf4h_o, htf4h_c), 
                         border_color=color.black, border_width=1, bgcolor=col4h)
    else
        box.set_left(box4h, left4h)
        box.set_right(box4h, right4h)
        box.set_top(box4h, math.max(htf4h_o, htf4h_c))
        box.set_bottom(box4h, math.min(htf4h_o, htf4h_c))
        box.set_bgcolor(box4h, col4h)

    // 4H Wicks only
    if showWicks
        wickCenter4 = left4h + math.round(bodyWidth / 2.0)
        if na(upperWick4)
            upperWick4 := line.new(wickCenter4, htf4h_h, wickCenter4, math.max(htf4h_o, htf4h_c), color=color.black, width=wickWidth, xloc=xloc.bar_index)
            lowerWick4 := line.new(wickCenter4, htf4h_l, wickCenter4, math.min(htf4h_o, htf4h_c), color=color.black, width=wickWidth, xloc=xloc.bar_index)
        else
            line.set_xy1(upperWick4, wickCenter4, htf4h_h)
            line.set_xy2(upperWick4, wickCenter4, math.max(htf4h_o, htf4h_c))
            line.set_xy1(lowerWick4, wickCenter4, htf4h_l)
            line.set_xy2(lowerWick4, wickCenter4, math.min(htf4h_o, htf4h_c))

    // Label
    if na(lbl4h)
        lbl4h := label.new(center4h, math.min(htf4h_l, htf4h_o, htf4h_c) * 0.999, "4H Candle",
                           color=color.new(color.black, 0), textcolor=color.white,
                           style=label.style_label_up, size=labelSize, yloc=yloc.price)
    else
        label.set_x(lbl4h, center4h)
        label.set_y(lbl4h, math.min(htf4h_l, htf4h_o, htf4h_c) * 0.999)

// ── 1H Candle on Right ────────────────────────
var box   box1h = na
var label lbl1h = na
var line  upperWick1 = na
var line  lowerWick1 = na

left1h   = bar_index + rightOffset + bodyWidth + 4
right1h  = left1h + bodyWidth
center1h = left1h + math.round(bodyWidth / 2.0)

if new1h or barstate.isrealtime
    isBull1h = htf1h_c >= htf1h_o
    col1h    = isBull1h ? bull1h : bear1h

    // Body
    if na(box1h)
        box1h := box.new(left1h, math.max(htf1h_o, htf1h_c), right1h, math.min(htf1h_o, htf1h_c),
                         border_color=color.black, border_width=1, bgcolor=col1h)
    else
        box.set_left(box1h, left1h)
        box.set_right(box1h, right1h)
        box.set_top(box1h, math.max(htf1h_o, htf1h_c))
        box.set_bottom(box1h, math.min(htf1h_o, htf1h_c))
        box.set_bgcolor(box1h, col1h)

    // 1H Wicks only
    if showWicks
        wickCenter1 = left1h + math.round(bodyWidth / 2.0)
        if na(upperWick1)
            upperWick1 := line.new(wickCenter1, htf1h_h, wickCenter1, math.max(htf1h_o, htf1h_c), color=color.black, width=wickWidth, xloc=xloc.bar_index)
            lowerWick1 := line.new(wickCenter1, htf1h_l, wickCenter1, math.min(htf1h_o, htf1h_c), color=color.black, width=wickWidth, xloc=xloc.bar_index)
        else
            line.set_xy1(upperWick1, wickCenter1, htf1h_h)
            line.set_xy2(upperWick1, wickCenter1, math.max(htf1h_o, htf1h_c))
            line.set_xy1(lowerWick1, wickCenter1, htf1h_l)
            line.set_xy2(lowerWick1, wickCenter1, math.min(htf1h_o, htf1h_c))

    // Label
    if na(lbl1h)
        lbl1h := label.new(center1h, math.min(htf1h_l, htf1h_o, htf1h_c) * 0.999, "1H Candle",
                           color=color.new(color.black, 0), textcolor=color.white,
                           style=label.style_label_up, size=labelSize, yloc=yloc.price)
    else
        label.set_x(lbl1h, center1h)
        label.set_y(lbl1h, math.min(htf1h_l, htf1h_o, htf1h_c) * 0.999)
````
