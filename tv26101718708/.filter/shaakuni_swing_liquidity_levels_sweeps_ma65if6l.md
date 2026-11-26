# Shaakuni - Swing Liquidity Levels & Sweeps

- url: https://www.tradingview.com/script/MA65If6L-Shaakuni-Swing-Liquidity-Levels-Sweeps/
- type: indicator
- pine_id: PUB;a7aee10a1bde41e0ab2440bc717d4ac5
- version: 1.0

## Description

Overview

Shaakuni - Swing Liquidity Levels & Sweeps marks swing highs and swing lows as liquidity levels, tracks whether price has swept or broken them, and groups very close swing levels into equal highs and equal lows. It also includes two optional extras: a fast and slow EMA, and a small RSI readout panel. It does not generate buy or sell signals and it does not predict reversals.

Key concepts

Liquidity levels: many traders place stop orders just beyond obvious swing highs and swing lows. Because of this, these levels are often watched as areas where price may pause, reverse or accelerate. The script marks them so you do not have to draw them by hand.

BSL and SSL: BSL (buy-side liquidity) is a swing high level, where stops of short positions and buy breakout orders may sit. SSL (sell-side liquidity) is a swing low level, where stops of long positions and sell breakout orders may sit.

EQH and EQL: when two swing highs (or two swing lows) form at nearly the same price, the level is relabelled EQH (equal highs) or EQL (equal lows). Many traders view equal levels as more obvious liquidity.

Sweep and break: a level is swept when price trades beyond it but the bar closes back on the original side. A level is broken when a bar closes beyond it. A swept or broken level stops extending and is drawn dashed; a broken level is also dimmed.

How the levels are calculated

1. A swing high or swing low is confirmed with a pivot using "Swing Length" (default 14 bars on each side). Because a pivot needs those bars to confirm, a level can appear no earlier than 14 bars after the swing formed, and it is drawn back on the swing candle.
2. Each level gets a zone. With "Wick Extremity" the zone runs from the swing extreme to the highest (or lowest) of the swing candle's open and close. With "Full Range" it covers the swing candle's whole range.
3. If a new swing forms within a tolerance of an existing active level on the same side (default 0.25 x ATR(14)), the two are merged and relabelled EQH or EQL instead of drawing a second line.
4. On every closed bar, a bar whose range overlaps the zone counts as a touch. The zone box grows one bar to the right per touch, and "Volume" label mode shows the total volume of those touching bars.
5. By default a level is displayed only after price has touched it at least once ("Min Touches To Show Level" = 1). Set it to 0 to see fresh untouched levels too.
6. A level is then closed as swept (high above a BSL level or low below an SSL level with the close back inside) or broken (close beyond the level). Up to 80 levels are tracked at a time.

Optional extras

EMA lines: a fast EMA (default 9) and slow EMA (default 21) of the close are plotted. They are standard exponential moving averages and are not used by the liquidity logic. They are included so a trend reference can be viewed on the same chart, and can be switched off.

RSI panel: a small table in the corner shows RSI (default length 14), coloured red above 70, teal below 30 and amber otherwise. It is a plain RSI readout, not used by the liquidity logic, and can be switched off.

How to use it

For example, on a 15-minute chart, look at which swing levels are still active above and below price and which have already been swept. A level that was swept and closed back inside shows that price took out the stops and rejected the level on that bar; a broken level shows that price accepted beyond it. Many traders combine references like these with their own confirmation and risk rules; the script is meant as a map, not a trade plan. Label mode can show the name, name plus price, or touch volume. Colours, swing length, zone type and tolerance are adjustable.

Alerts

Two alert conditions are available, one for buy-side liquidity swept and one for sell-side liquidity swept. They fire when the bar closes.

Why it is built this way

Swing highs and lows, equal levels, sweeps, EMAs and RSI are all widely used, and this script does not claim to have invented them. What it adds is one implementation that tracks each swing level through its whole life (active, touched, swept or broken), merges close levels using an ATR-based tolerance, and shows touch counts and volume on the zone. The source code is open so you can verify each step.

Limitations

Levels are placed after the pivot is confirmed, so they appear at least 14 bars (or your chosen swing length) after the swing, drawn on the earlier candle. Touches are counted only after the level has been confirmed. The EMA lines and RSI panel use the live bar and can change until it closes, while the liquidity engine only changes on closed bars. Volume labels depend on the data feed; some instruments provide little or no volume. A sweep does not mean price will reverse, and a level that is not swept can still fail. Only the most recent 80 levels are tracked, and TradingView limits the number of lines, boxes and labels, so the oldest drawings may disappear. This is a visual aid and not financial advice.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) Shaakuni

//@version=6
indicator("Shaakuni - Swing Liquidity Levels & Sweeps", shorttitle="Shaakuni Liquidity Sweeps", overlay=true, max_bars_back=1000, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ==========================================
// Shaakuni - Swing Liquidity Levels & Sweeps
//  1) Liquidity: swing zones, BSL/SSL/EQH/EQL levels, sweep / break status
//  2) EMA lines (fast/slow), plotted independently of the liquidity logic
//  3) RSI: small readout panel, independent of the liquidity logic
// The liquidity engine only changes state on closed bars. Swing levels are placed on the swing
// candle after the pivot is confirmed (pivot length bars later). EMA lines and the RSI panel
// follow the live bar like any standard indicator. No buy/sell signals.
// ==========================================

// ==========================================
// 1. INPUTS
// ==========================================
grp_liq = "1. Liquidity Settings"
pivot_len      = input.int(14, "Swing Length (Pivot Lookback)", minval=2, group=grp_liq)
swing_area     = input.string("Wick Extremity", "Swing Area", options=["Wick Extremity", "Full Range"], group=grp_liq)
min_touches    = input.int(1, "Min Touches To Show Level", minval=0, group=grp_liq, tooltip="1 = only show levels that price has returned to at least once. 0 = also show fresh (untouched) levels.")
eq_tol         = input.float(0.25, "Equal Level Tolerance (x ATR)", minval=0.05, step=0.05, group=grp_liq)
show_zones     = input.bool(true, "Show Swing Zones", group=grp_liq)
label_mode     = input.string("Name", "Level Label", options=["Name", "Name + Price", "Volume"], group=grp_liq, tooltip="Name = BSL / SSL / EQH / EQL. Volume = total volume of the bars that touched the zone.")
col_top        = input.color(color.red, "Swing High (BSL) Color", group=grp_liq)
col_btm        = input.color(color.teal, "Swing Low (SSL) Color", group=grp_liq)

grp_ema = "2. EMA Settings"
show_emas    = input.bool(true, "Show EMAs", group=grp_ema)
ema_fast_len = input.int(9, "Fast EMA Length", minval=1, group=grp_ema)
ema_slow_len = input.int(21, "Slow EMA Length", minval=1, group=grp_ema)

grp_rsi = "3. RSI Settings"
rsi_len    = input.int(14, "RSI Length", minval=1, group=grp_rsi)
show_panel = input.bool(true, "Show RSI Panel", group=grp_rsi)
panel_pos  = input.string("Top Right", "RSI Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_rsi)

// ==========================================
// 2. EMA, ATR
// ==========================================
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)
rsi_val  = ta.rsi(close, rsi_len)
atr      = ta.atr(14)
int tfms = timeframe.in_seconds() * 1000

plot(show_emas ? ema_fast : na, title="Fast EMA", color=color.rgb(0, 229, 255), linewidth=1)
plot(show_emas ? ema_slow : na, title="Slow EMA", color=color.rgb(255, 109, 0), linewidth=1)

// ==========================================
// 3. LIQUIDITY ENGINE
// ==========================================
type Liq
    float  price            // level line (swing high / swing low)
    float  top              // zone top
    float  bot              // zone bottom
    bool   isHigh
    string kind             // BSL / SSL / EQH / EQL
    bool   strong
    int    startBar
    int    startTime
    int    count = 0        // number of bars that touched the zone
    float  vol = 0.0        // volume of those touching bars
    int    status = 0       // 0 active, 1 swept, 2 broken
    int    endBar = na
    int    endTime = na
    bool   shown = false
    line   ln
    box    bx
    label  lb
    label  ar

lblText(Liq lv) =>
    string txt = lv.kind
    if label_mode == "Name + Price"
        txt := lv.kind + "  " + str.tostring(lv.price, format.mintick)
    else if label_mode == "Volume"
        txt := ((lv.kind == "EQH" or lv.kind == "EQL") ? "EQ " : "") + str.tostring(lv.vol, format.volume)
    txt

showLevel(Liq lv, int tfms) =>
    color c = lv.isHigh ? col_top : col_btm
    lv.ln := line.new(lv.startTime, lv.price, time + 3 * tfms, lv.price, xloc=xloc.bar_time, color=c, width=1)
    if show_zones
        lv.bx := box.new(lv.startTime, lv.top, lv.startTime + math.max(lv.count, 1) * tfms, lv.bot, xloc=xloc.bar_time, border_color=na, bgcolor=color.new(c, 80))
    lv.ar := label.new(int((lv.startTime + time + 3 * tfms) / 2), lv.price, "x", xloc=xloc.bar_time, style=label.style_label_center, size=size.normal, color=color.new(color.black, 100), textcolor=c)
    lv.lb := label.new(lv.startTime, lv.price, lblText(lv), xloc=xloc.bar_time, style=lv.isHigh ? label.style_label_down : label.style_label_up, size=size.tiny, color=color.new(color.black, 100), textcolor=c)
    lv.shown := true

refreshLevel(Liq lv, int tfms) =>
    if lv.shown
        line.set_x2(lv.ln, time + 3 * tfms)
        if not na(lv.bx)
            box.set_right(lv.bx, lv.startTime + math.max(lv.count, 1) * tfms)
        label.set_text(lv.lb, lblText(lv))
        label.set_x(lv.ar, int((lv.startTime + time + 3 * tfms) / 2))

endLevel(Liq lv, int st) =>
    lv.status := st
    lv.endBar := bar_index
    lv.endTime := time
    if lv.shown
        line.set_x2(lv.ln, time)
        line.set_style(lv.ln, line.style_dashed)
        label.set_x(lv.ar, int((lv.startTime + time) / 2))
        if st == 2
            line.set_color(lv.ln, color.new(lv.isHigh ? col_top : col_btm, 60))
            label.set_textcolor(lv.ar, color.new(lv.isHigh ? col_top : col_btm, 60))

addLevel(array<Liq> arr, float price, float top, float bot, bool isHigh, string kind, int startBar, int startTime, float tol, int cap) =>
    bool merged = false
    int sz = array.size(arr)
    if sz > 0
        for i = sz - 1 to 0
            Liq lv = array.get(arr, i)
            if lv.status == 0 and lv.isHigh == isHigh and math.abs(lv.price - price) <= tol
                merged := true
                lv.strong := true
                lv.kind := isHigh ? "EQH" : "EQL"
                if isHigh
                    lv.price := math.max(lv.price, price)
                    lv.top := lv.price
                    lv.bot := math.min(lv.bot, bot)
                else
                    lv.price := math.min(lv.price, price)
                    lv.bot := lv.price
                    lv.top := math.max(lv.top, top)
                if lv.shown
                    line.set_y1(lv.ln, lv.price)
                    line.set_y2(lv.ln, lv.price)
                    if not na(lv.bx)
                        box.set_top(lv.bx, lv.top)
                        box.set_bottom(lv.bx, lv.bot)
                    label.set_y(lv.lb, lv.price)
                    label.set_y(lv.ar, lv.price)
                break
    if not merged
        array.push(arr, Liq.new(price=price, top=top, bot=bot, isHigh=isHigh, kind=kind, strong=false, startBar=startBar, startTime=startTime))
        if array.size(arr) > cap
            int rm = 0
            for i = 0 to array.size(arr) - 1
                if array.get(arr, i).status != 0
                    rm := i
                    break
            array.remove(arr, rm)
    merged

var array<Liq> levels = array.new<Liq>()

ph = ta.pivothigh(high, pivot_len, pivot_len)
pl = ta.pivotlow(low, pivot_len, pivot_len)
float tol = nz(atr) * eq_tol

bool bslSweep = false
bool sslSweep = false

if barstate.isconfirmed and not na(atr)
    // 1) new swing levels
    if not na(ph)
        float hb = swing_area == "Full Range" ? low[pivot_len] : math.max(open[pivot_len], close[pivot_len])
        addLevel(levels, ph, ph, hb, true, "BSL", bar_index - pivot_len, time[pivot_len], tol, 80)
    if not na(pl)
        float lt = swing_area == "Full Range" ? high[pivot_len] : math.min(open[pivot_len], close[pivot_len])
        addLevel(levels, pl, lt, pl, false, "SSL", bar_index - pivot_len, time[pivot_len], tol, 80)

    // 2) touches, display, sweep / break
    int n = array.size(levels)
    if n > 0
        for i = 0 to n - 1
            Liq lv = array.get(levels, i)
            if lv.status == 0
                if low < lv.top and high > lv.bot
                    lv.count := lv.count + 1
                    lv.vol := lv.vol + nz(volume)
                if not lv.shown and lv.count >= min_touches
                    showLevel(lv, tfms)
                if lv.isHigh and high > lv.price
                    if close < lv.price
                        endLevel(lv, 1)
                        bslSweep := true
                    else
                        endLevel(lv, 2)
                else if not lv.isHigh and low < lv.price
                    if close > lv.price
                        endLevel(lv, 1)
                        sslSweep := true
                    else
                        endLevel(lv, 2)
                if lv.status == 0
                    refreshLevel(lv, tfms)

alertcondition(bslSweep, "Buy-side liquidity swept", "Swing high level was taken out and the bar closed back below it")
alertcondition(sslSweep, "Sell-side liquidity swept", "Swing low level was taken out and the bar closed back above it")

// ==========================================
// 4. RSI PANEL (small)
// ==========================================
panelPosition = panel_pos == "Top Left" ? position.top_left : panel_pos == "Bottom Right" ? position.bottom_right : panel_pos == "Bottom Left" ? position.bottom_left : position.top_right

var table rsiTbl = table.new(panelPosition, 3, 2, bgcolor=color.new(#131722, 8), border_color=color.new(#2A2E39, 0), border_width=1, frame_color=color.new(#2962FF, 0), frame_width=1)

panelRow(table t, int r, string k, string v, color vc) =>
    table.cell(t, 0, r, "●", text_color=vc, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(#131722, 8), width=1)
    table.cell(t, 1, r, k, text_color=#9598A1, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#131722, 8), text_font_family=font.family_default, width=6)
    table.cell(t, 2, r, v, text_color=vc, text_size=size.small, text_halign=text.align_right, bgcolor=color.new(#1E222D, 8), text_font_family=font.family_monospace, width=10)

if barstate.islast and show_panel
    table.cell(rsiTbl, 0, 0, "SHAAKUNI", text_color=color.white, text_size=size.small, text_halign=text.align_center, bgcolor=#2962FF, text_font_family=font.family_monospace)
    table.merge_cells(rsiTbl, 0, 0, 2, 0)

    color rsiCol = rsi_val > 70 ? #EF5350 : rsi_val < 30 ? #26A69A : #FFCA28
    panelRow(rsiTbl, 1, "RSI (" + str.tostring(rsi_len) + ")", str.tostring(rsi_val, "#.0"), rsiCol)
````
