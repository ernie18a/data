# Gold Support Resistance Channels

- url: https://www.tradingview.com/script/2SOMgyv8-Gold-Support-Resistance-Channels/
- type: indicator
- pine_id: PUB;8959f808418d45bb857c9b2739df5300
- version: 1.0

## Description

support and resistance channels, 1 hr but works on all time frames.

## Source Code

````pine
//@version=6
indicator("Support Resistance Channels – H1 Pivots (Clean Zones Only)", "SRchannel_H1", overlay = true, max_bars_back = 500)

//---------------------------------------------------------
// INPUTS
//---------------------------------------------------------
prd = input.int(10, "Pivot Period", minval = 4, maxval = 30)
ppsrc = input.string("High/Low", "Source", options = ["High/Low", "Close/Open"])
ChannelW = input.int(5, "Maximum Channel Width %", minval = 1, maxval = 8)
minstrength = input.int(1, "Minimum Strength", minval = 1)
maxnumsr = input.int(6, "Maximum Number of S/R", minval = 1, maxval = 10) - 1
loopback = input.int(290, "Loopback Period", minval = 100, maxval = 400)

res_col = input.color(color.new(color.red, 75), "Resistance Color")
sup_col = input.color(color.new(color.lime, 75), "Support Color")
inch_col = input.color(color.new(color.gray, 75), "Color When Price in Channel")

showpp = input.bool(false, "Show Pivot Points")

//---------------------------------------------------------
// FORCE PIVOTS TO 1-HOUR DATA
//---------------------------------------------------------
htfHigh  = request.security(syminfo.tickerid, "60", high)
htfLow   = request.security(syminfo.tickerid, "60", low)
htfClose = request.security(syminfo.tickerid, "60", close)
htfOpen  = request.security(syminfo.tickerid, "60", open)

src1 = ppsrc == "High/Low" ? htfHigh : math.max(htfClose, htfOpen)
src2 = ppsrc == "High/Low" ? htfLow  : math.min(htfClose, htfOpen)

ph = ta.pivothigh(src1, prd, prd)
pl = ta.pivotlow(src2, prd, prd)

//---------------------------------------------------------
// OPTIONAL PIVOT PLOTS
//---------------------------------------------------------
plotshape(not na(ph) and showpp, "H", shape.labeldown, location.abovebar, color = na, textcolor = color.red, offset = -prd)
plotshape(not na(pl) and showpp, "L", shape.labelup, location.belowbar, color = na, textcolor = color.lime, offset = -prd)

//---------------------------------------------------------
// CHANNEL WIDTH
//---------------------------------------------------------
prdhighest = ta.highest(high, 300)
prdlowest  = ta.lowest(low, 300)
cwidth = (prdhighest - prdlowest) * ChannelW / 100

//---------------------------------------------------------
// STORE PIVOTS
//---------------------------------------------------------
var pivotvals = array.new_float()
var pivotlocs = array.new_int()

if not na(ph) or not na(pl)
    array.unshift(pivotvals, not na(ph) ? ph : pl)
    array.unshift(pivotlocs, bar_index)

    for i = array.size(pivotvals) - 1 to 0
        if bar_index - array.get(pivotlocs, i) > loopback
            array.pop(pivotvals)
            array.pop(pivotlocs)
        else
            break

//---------------------------------------------------------
// BUILD SR CHANNELS
//---------------------------------------------------------
get_sr_vals(ind) =>
    lo = array.get(pivotvals, ind)
    hi = lo
    numpp = 0

    for y = 0 to array.size(pivotvals) - 1
        cpp = array.get(pivotvals, y)
        wdth = cpp <= hi ? hi - cpp : cpp - lo

        if wdth <= cwidth
            if cpp <= hi
                lo := math.min(lo, cpp)
            else
                hi := math.max(hi, cpp)
            numpp += 20

    [hi, lo, numpp]

var suportresistance = array.new_float(20, 0)
var stren = array.new_float(10, 0)

changeit(x, y) =>
    t1 = array.get(suportresistance, y * 2)
    array.set(suportresistance, y * 2, array.get(suportresistance, x * 2))
    array.set(suportresistance, x * 2, t1)

    t2 = array.get(suportresistance, y * 2 + 1)
    array.set(suportresistance, y * 2 + 1, array.get(suportresistance, x * 2 + 1))
    array.set(suportresistance, x * 2 + 1, t2)

if not na(ph) or not na(pl)
    supres = array.new_float()

    for x = 0 to array.size(pivotvals) - 1
        [hi, lo, strength] = get_sr_vals(x)
        array.push(supres, strength)
        array.push(supres, hi)
        array.push(supres, lo)

    for x = 0 to array.size(pivotvals) - 1
        h = array.get(supres, x * 3 + 1)
        l = array.get(supres, x * 3 + 2)
        s = 0

        for y = 0 to loopback
            if (high[y] <= h and high[y] >= l) or (low[y] <= h and low[y] >= l)
                s += 1

        array.set(supres, x * 3, array.get(supres, x * 3) + s)

    array.fill(suportresistance, 0)

    src = 0
    for x = 0 to array.size(pivotvals) - 1
        stv = -1.0
        stl = -1

        for y = 0 to array.size(pivotvals) - 1
            if array.get(supres, y * 3) > stv and array.get(supres, y * 3) >= minstrength * 20
                stv := array.get(supres, y * 3)
                stl := y

        if stl >= 0
            hh = array.get(supres, stl * 3 + 1)
            ll = array.get(supres, stl * 3 + 2)

            array.set(suportresistance, src * 2, hh)
            array.set(suportresistance, src * 2 + 1, ll)
            array.set(stren, src, array.get(supres, stl * 3))

            for y = 0 to array.size(pivotvals) - 1
                if (array.get(supres, y * 3 + 1) <= hh and array.get(supres, y * 3 + 1) >= ll) or
                   (array.get(supres, y * 3 + 2) <= hh and array.get(supres, y * 3 + 2) >= ll)
                    array.set(supres, y * 3, -1)

            src += 1
            if src >= 10
                break

    for x = 0 to 8
        for y = x + 1 to 9
            if array.get(stren, y) > array.get(stren, x)
                changeit(x, y)

//---------------------------------------------------------
// GETTERS
//---------------------------------------------------------
get_level(ind) =>
    float ret = na
    if ind < array.size(suportresistance)
        if array.get(suportresistance, ind) != 0
            ret := array.get(suportresistance, ind)
    ret

get_color(ind) =>
    color ret = na
    if ind < array.size(suportresistance)
        if array.get(suportresistance, ind) != 0
            top = array.get(suportresistance, ind)
            bot = array.get(suportresistance, ind + 1)
            ret := top > close and bot > close ? res_col : top < close and bot < close ? sup_col : inch_col
    ret

//---------------------------------------------------------
// DRAW ZONES + BOUNDARY LINES
//---------------------------------------------------------
var srboxes = array.new_box(10)

for i = 0 to maxnumsr
    box.delete(array.get(srboxes, i))

    top = get_level(i * 2)
    bot = get_level(i * 2 + 1)
    col = get_color(i * 2)

    if not na(top) and not na(bot)
        line.new(bar_index, top, bar_index + 1, top, extend=extend.both, color=col, width=1)
        line.new(bar_index, bot, bar_index + 1, bot, extend=extend.both, color=col, width=1)

        strength = array.get(stren, i)
        width = int(math.max(1.0, math.min(strength / 50.0, 4.0)))
        transp = math.max(0.0, math.min(90.0 - (strength / 3.0), 90.0))
        zoneColor = color.new(col, transp)

        array.set(srboxes, i,
            box.new(
                bar_index,
                top,
                bar_index + 1,
                bot,
                bgcolor = zoneColor,
                border_color = zoneColor,
                border_width = width,
                extend = extend.both
            )
        )

//---------------------------------------------------------
// ADAPTIVE NORMALIZATION (1–10)
//---------------------------------------------------------
maxStrength = 1.0
for i = 0 to maxnumsr
    maxStrength := math.max(maxStrength, array.get(stren, i))

normalize(strength) =>
    scaled = math.round(strength / maxStrength * 10)
    math.max(1, math.min(scaled, 10))

//---------------------------------------------------------
// LABELS: SHOW ZONE STRENGTH (SHIFTED RIGHT)
//---------------------------------------------------------
var srlabels = array.new_label(10)

for i = 0 to maxnumsr
    lbl = array.get(srlabels, i)
    if not na(lbl)
        label.delete(lbl)

    top = get_level(i * 2)
    bot = get_level(i * 2 + 1)
    rawStrength = array.get(stren, i)
    normStrength = normalize(rawStrength)

    if not na(top) and not na(bot)
        mid = (top + bot) / 2
        xpos = bar_index + 20

        txt = "SR " + str.tostring(i+1) + " | Strength: " + str.tostring(normStrength) + "/10"

        array.set(srlabels, i,
            label.new(
                xpos,
                mid,
                txt,
                style = label.style_label_left,
                textcolor = color.white,
                color = color.new(color.black, 0),
                size = size.small
            )
        )

//---------------------------------------------------------
// ALERT: PRICE APPROACHING ANY SR CHANNEL
//---------------------------------------------------------
approachPerc = 0.10

price = close
isApproaching = false
float approachStrength = na
float approachTop = na
float approachBot = na

for i = 0 to maxnumsr
    top = get_level(i * 2)
    bot = get_level(i * 2 + 1)

    if not na(top) and not na(bot)
        distTop = math.abs(price - top) / price * 100
        distBot = math.abs(price - bot) / price * 100

        if distTop <= approachPerc or distBot <= approachPerc
            isApproaching := true
            approachStrength := normalize(array.get(stren, i))
            approachTop := top
            approachBot := bot
            break

alertcondition(
    isApproaching,
    title = "Price Approaching SR Channel",
    message = "Price is approaching an SR channel."
)

if isApproaching
    alert(
        "Price approaching SR zone | Strength: " + str.tostring(approachStrength) + "/10" +
        " | Top: " + str.tostring(approachTop) +
        " | Bottom: " + str.tostring(approachBot),
        alert.freq_once_per_bar
    )

//---------------------------------------------------------
// ALERT: PRICE ENTERING ANY SR CHANNEL
//---------------------------------------------------------
isInside = false
float insideStrength = na
float insideTop = na
float insideBot = na

for i = 0 to maxnumsr
    top = get_level(i * 2)
    bot = get_level(i * 2 + 1)

    if not na(top) and not na(bot)
        if close <= top and close >= bot
            isInside := true
            insideStrength := normalize(array.get(stren, i))
            insideTop := top
            insideBot := bot
            break

alertcondition(
    isInside,
    title = "Price Entered SR Channel",
    message = "Price has entered an SR channel."
)

if isInside
    alert(
        "PRICE ENTERED SR ZONE | Strength: " + str.tostring(insideStrength) + "/10" +
        " | Top: " + str.tostring(insideTop) +
        " | Bottom: " + str.tostring(insideBot),
        alert.freq_once_per_bar
    )
````
