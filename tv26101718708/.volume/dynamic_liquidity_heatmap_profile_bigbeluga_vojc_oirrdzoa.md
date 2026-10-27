# Dynamic Liquidity HeatMap Profile [BigBeluga - Vojc]

- url: https://www.tradingview.com/script/oirRdZOA-Dynamic-Liquidity-HeatMap-Profile-BigBeluga-Vojc/
- type: indicator
- pine_id: PUB;2373803ae4414563954e779fd0c79e65
- version: 1.0

## Description

Add calculation cart and resolution for each timeframe chart for better and accurate display. All credits stay with BigBeluga of course

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BigBeluga — Modified for per-timeframe lookback + day-trading filter (Vojc edit)

//@version=6
indicator("Dynamic Liquidity HeatMap Profile [BigBeluga - Vojc]", overlay = true, max_lines_count = 500, max_bars_back = 5000, max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
// ＬＯＯＫＢＡＣＫ  ＰＥＲ  ＴＩＭＥＦＲＡＭＥ ────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
lb_grp = "Lookback per Timeframe"
lb_1m    = input.int(800, "≤ 1m  Lookback", minval=50, maxval=4500, group=lb_grp, tooltip="Bars used on 1-min chart")
lb_5m    = input.int(900, "≤ 5m  Lookback", minval=50, maxval=4500, group=lb_grp, tooltip="Bars used on 5-min chart. 900 ≈ 3 days of 5m bars — covers your full defense window for swing-style holds on volatile alts.")
lb_15m   = input.int(400, "≤ 15m Lookback", minval=50, maxval=4500, group=lb_grp)
lb_1h    = input.int(350, "≤ 1h  Lookback", minval=50, maxval=4500, group=lb_grp)
lb_4h    = input.int(300, "≤ 4h  Lookback", minval=50, maxval=4500, group=lb_grp, tooltip="Big picture context (~50 days of 4h)")
lb_1d    = input.int(250, "≤ 1D  Lookback", minval=50, maxval=4500, group=lb_grp)
lb_other = input.int(300, "Other Lookback",  minval=50, maxval=4500, group=lb_grp, tooltip="Fallback for any TF not listed above")

// Auto-pick lookback based on chart's timeframe
tf_sec = timeframe.in_seconds()
lookBack = tf_sec <= 60     ? lb_1m   :
           tf_sec <= 300    ? lb_5m   :
           tf_sec <= 900    ? lb_15m  :
           tf_sec <= 3600   ? lb_1h   :
           tf_sec <= 14400  ? lb_4h   :
           tf_sec <= 86400  ? lb_1d   :
                              lb_other

// ═══════════════════════════════════════════════════════════════════════════
// ＲＥＳＯＬＵＴＩＯＮ  ＰＥＲ  ＴＩＭＥＦＲＡＭＥ  (Profile bins) ──────────────────────
// ═══════════════════════════════════════════════════════════════════════════
res_grp = "Profile Resolution per Timeframe"
displPf  = input.bool(true, "Show Profile", group=res_grp)
bins_1m  = input.int(70, "≤ 1m  Bins", minval=10, maxval=200, group=res_grp)
bins_5m  = input.int(60, "≤ 5m  Bins", minval=10, maxval=200, group=res_grp, tooltip="Higher = finer zones (better for scalping entries / BE defense)")
bins_15m = input.int(55, "≤ 15m Bins", minval=10, maxval=200, group=res_grp)
bins_1h  = input.int(50, "≤ 1h  Bins", minval=10, maxval=200, group=res_grp)
bins_4h  = input.int(50, "≤ 4h  Bins", minval=10, maxval=200, group=res_grp)
bins_1d  = input.int(45, "≤ 1D  Bins", minval=10, maxval=200, group=res_grp)
bins_oth = input.int(50, "Other Bins",  minval=10, maxval=200, group=res_grp)

bins = tf_sec <= 60     ? bins_1m  :
       tf_sec <= 300    ? bins_5m  :
       tf_sec <= 900    ? bins_15m :
       tf_sec <= 3600   ? bins_1h  :
       tf_sec <= 14400  ? bins_4h  :
       tf_sec <= 86400  ? bins_1d  :
                          bins_oth

resolution = 100  // pivot scan resolution (kept fixed — original behavior)

// ═══════════════════════════════════════════════════════════════════════════
// ＤＡＹ  ＴＲＡＤＩＮＧ  ＦＩＬＴＥＲ  (proximity to price) ──────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
dt_grp = "Day Trading Filter"
dtMode    = input.bool(true, "Trail-Defense Mode (only show nearby zones)", group=dt_grp,
     tooltip="Hides liquidity zones farther than the per-TF gap. On 5m it isolates actionable reversal zones for active trade defense; on 4h it widens to show full swing-range structure.")
gap_1m    = input.float(2.0,  "≤ 1m  Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp)
gap_5m    = input.float(3.0,  "≤ 5m  Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp, tooltip="Your active execution TF — 3% matches the trailing defense rule on RSR")
gap_15m   = input.float(5.0,  "≤ 15m Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp)
gap_1h    = input.float(10.0, "≤ 1h  Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp)
gap_4h    = input.float(20.0, "≤ 4h  Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp, tooltip="Big-picture TF — wider gap reveals the full liquidity range on swing scale")
gap_1d    = input.float(35.0, "≤ 1D  Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp)
gap_other = input.float(15.0, "Other Trail gap ± %", minval=0.1, maxval=50, step=0.1, group=dt_grp)

dtPctRange = if tf_sec <= 60
    gap_1m
else if tf_sec <= 300
    gap_5m
else if tf_sec <= 900
    gap_15m
else if tf_sec <= 3600
    gap_1h
else if tf_sec <= 14400
    gap_4h
else if tf_sec <= 86400
    gap_1d
else
    gap_other

// ═══════════════════════════════════════════════════════════════════════════
// ＣＯＬＯＲＳ ────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════
color sellColor = input.color(color.blue,   "Sell Liquidity")
color buyColor  = input.color(color.lime,   "Buy  Liquidity")
bool  poc       = input.bool(true, "", inline = "maxp")
color maxColor  = input.color(color.orange, "Max Point Liquidity", inline = "maxp")


var boxes       = array.new<box>()
var labels      = array.new<label>()
var lines       = array.new<line>()

var volume_bins = array.new<float>(bins, 0.)
h_l         = array.new<float>()


type pivot
    float value
    int   index
    float volume_
    float vol
    bool  isLower

var pivots = array.new<pivot>()


// ＣＡＬＣＵＬＡＴＩＯＮＳ ─────────────────────────────────────────────────────────
h = ta.highest(2)
l = ta.lowest(2)

volumeArr = array.new_float(lookBack)

vol  = math.sum(volume, 10)

for i = 0 to lookBack-1
    volumeArr.set(i, vol[i])

nVol   = vol / volumeArr.max() * 100
atr    = ta.atr(5) / 50
offset = ta.highest(atr * nVol, lookBack)

for i = 0 to lookBack-1
    h_l.push(high[i]+offset[i])
    h_l.push(low[i]-offset[i])


if last_bar_index - bar_index < lookBack

    top = h_l.max()
    bot = h_l.min()

    step = (top-bot)/resolution

    level1 = high + atr * nVol
    level2 = low  - atr * nVol


    if h == high
        for i = 0 to resolution - 1
            lower = bot + step * i
            mid   = lower + step/2

            if math.abs(level1 - mid) <= step
                pivots.push(pivot.new(mid, bar_index, nVol, vol, false))

    if l == low
        for i = 0 to resolution - 1
            lower = bot + step * i
            mid   = lower + step/2

            if math.abs(level2 - mid) <= step
                pivots.push(pivot.new(mid  - atr * nVol, bar_index, nVol, vol, true))


    if pivots.size() > 0
        for p in pivots
            y     = p.value
            x     = p.index
            isLow = p.isLower

            if isLow and low < y
                pivots.remove(pivots.indexof(p))

            if not isLow and high > y
                pivots.remove(pivots.indexof(p))


// ＰＬＯＴ ────────────────────────────────────────────────────────────────────
if barstate.islast

    if lines.size() > 0
        for ln in lines
            ln.delete()

    for b in boxes
        b.delete()
    boxes.clear()

    for lbl in labels
        lbl.delete()
    labels.clear()

    step = (h_l.max() - h_l.min()) / bins


    for j = 0 to bins-1
        volume_bins.set(j, 0)

    if pivots.size() > 0
        for i = 0 to pivots.size() - 1
            lvl     = pivots.get(i)
            vol_    = lvl.vol
            line_y  = lvl.value

            for j = 0 to bins-1
                lower = h_l.min() + step * j
                mid   = lower + step/2
                upper = lower + step

                if math.abs(line_y-mid) < step
                    volume_bins.set(j, volume_bins.get(j) + vol_)

        for j = 0 to bins-1
            lower    = h_l.min() + step * j
            upper    = lower + step
            mid      = lower + step/2
            voll     = volume_bins.get(j)
            valueVol = voll / volume_bins.max() * 50
            col      = close > mid ? buyColor : sellColor
            m_col    = color.from_gradient(voll, volume_bins.min(), volume_bins.max(), color.new(col, 80), color.new(col, 0))
            m_col1   = color.from_gradient(voll, volume_bins.min(), volume_bins.max(), color.new(col, 50), color.new(col, 0))

            // Day-trading proximity filter
            priceDistPct = math.abs(close - mid) / close * 100
            withinRange  = not dtMode or priceDistPct <= dtPctRange

            if not (close < upper and close > lower) and withinRange

                if displPf and (valueVol != 0)

                    boxes.push(
                                     box.new(bar_index+20, upper, bar_index+20+int(valueVol), lower
                                     , bgcolor      = voll == volume_bins.max() and poc ? maxColor : m_col
                                     , border_color = chart.bg_color
                                     , text         = voll > volume_bins.avg() ? str.tostring(voll, format.volume) : ""
                                     , text_halign  = text.align_left)
                                     )

                    boxes.push(
                                     box.new(bar_index+20, upper, bar_index+5, lower
                                     , text = str.tostring(valueVol*2, format.percent)
                                     , bgcolor = color(na)
                                     , border_color = color(na)
                                     , text_color = voll == volume_bins.max() ? maxColor : m_col1)
                                     )


                var start = 0
                isLower = close > mid

                for i = 0 to lookBack - 1
                    if isLower
                        if low[i] < mid
                            start := bar_index - i
                            break
                        if i == lookBack - 1
                            start := bar_index - i
                            break
                    else
                        if high[i] > mid
                            start := bar_index - i
                            break
                        if i == lookBack - 1
                            start := bar_index - i
                            break

                color = voll == volume_bins.max() and poc ? maxColor : color.from_gradient(valueVol, 0, 50, color(na), isLower ? color.new(buyColor, 30) : color.new(sellColor, 30))

                lines.push(line.new(start+3, mid, bar_index+5, mid, width = int(valueVol/5), color = color))
````
