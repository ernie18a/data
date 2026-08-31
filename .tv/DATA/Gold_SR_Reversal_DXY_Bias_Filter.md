<!-- tradingview-pine-id: PUB;99b4914799ae4ab3b65c25ae31347f77 -->
<!-- tradingviewscripts-format: 1 -->
# Gold S/R Reversal + DXY Bias Filter

Source: https://www.tradingview.com/script/BE9aOBNo-Gold-S-R-Reversal-DXY-Bias-Filter/

## Description

gold buy and sell at resistance and support, 

DXY filter:
Since gold and the US Dollar Index typically move inversely, buy signals require DXY to be bearish on both the Daily and H4 timeframes, and sell signals require DXY bullish on both — filtering out counter-trend setups. A bias table shows H1/H4/Daily/Weekly trend for both Gold and DXY at a glance.

---

## Source Code

````pine
//@version=6
indicator('Gold S/R Reversal + DXY Bias Filter', 'XAU-SR-DXY', overlay = true, max_bars_back = 501)

// ============================================================
// SETTINGS
// ============================================================
prd          = input.int(10, 'Pivot Period', minval = 4, maxval = 30, group = 'S/R Settings', tooltip = 'Left/right bars used to confirm a pivot high or low')
ppsrc        = input.string('High/Low', 'Pivot Source', options = ['High/Low', 'Close/Open'], group = 'S/R Settings')
atrLen       = input.int(14, 'ATR Length (zone width)', group = 'S/R Settings')
atrMult      = input.float(1.0, 'ATR Multiplier (zone width)', step = 0.1, group = 'S/R Settings', tooltip = 'Zone width = ATR x multiplier. Wider = fewer, broader zones.')
minstrength  = input.int(2, 'Minimum Strength', minval = 1, group = 'S/R Settings', tooltip = 'Zone must contain at least this many pivot points (x20) plus touches')
maxnumsr     = input.int(6, 'Maximum Number of S/R Zones', minval = 1, maxval = 10, group = 'S/R Settings') - 1
loopback     = input.int(290, 'Loopback Period', minval = 100, maxval = 400, group = 'S/R Settings')

sup_col      = input.color(color.new(color.blue, 75), 'Support / Buy Zone Color', group = 'Colors')
res_col      = input.color(color.new(color.red, 75), 'Resistance / Sell Zone Color', group = 'Colors')
inch_col     = input.color(color.new(color.gray, 80), 'Price Inside Zone Color', group = 'Colors')

dxySymbol    = input.symbol('TVC:DXY', 'DXY Symbol', group = 'DXY Bias Filter')
biasMaLen    = input.int(50, 'Bias MA Length (per timeframe)', group = 'DXY Bias Filter')
useDxyFilter = input.bool(true, 'Require DXY D1+H4 agreement to fire signal', group = 'DXY Bias Filter')
showUnfiltered = input.bool(false, 'Also plot unfiltered (pre-DXY-filter) signals', group = 'DXY Bias Filter')

tablePos     = input.string(position.top_right, 'Table Position', options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left], group = 'Table')
showTable    = input.bool(true, 'Show XAUUSD vs DXY Bias Table', group = 'Table')

// ============================================================
// PIVOT DETECTION
// ============================================================
float src1 = ppsrc == 'High/Low' ? high : math.max(close, open)
float src2 = ppsrc == 'High/Low' ? low : math.min(close, open)
float ph = ta.pivothigh(src1, prd, prd)
float pl = ta.pivotlow(src2, prd, prd)

// ============================================================
// ZONE WIDTH (ATR-based -- stable across gold's price eras/timeframes)
// ============================================================
cwidth = ta.atr(atrLen) * atrMult

// ============================================================
// PIVOT STORAGE
// ============================================================
var pivotvals = array.new_float(0)
var pivotlocs = array.new_float(0)
if bool(ph) or bool(pl)
    array.unshift(pivotvals, bool(ph) ? ph : pl)
    array.unshift(pivotlocs, bar_index)
    for x = array.size(pivotvals) - 1 to 0 by 1
        if bar_index - array.get(pivotlocs, x) > loopback
            array.pop(pivotvals)
            array.pop(pivotlocs)
            continue
        break

// ============================================================
// ZONE BUILDING (same clustering approach as original SR script)
// ============================================================
get_sr_vals(ind) =>
    float lo = array.get(pivotvals, ind)
    float hi = lo
    int numpp = 0
    for y = 0 to array.size(pivotvals) - 1 by 1
        float cpp = array.get(pivotvals, y)
        float wdth = cpp <= hi ? hi - cpp : cpp - lo
        if wdth <= cwidth
            if cpp <= hi
                lo := math.min(lo, cpp)
            else
                hi := math.max(hi, cpp)
            numpp := numpp + 20
    [hi, lo, numpp]

var suportresistance = array.new_float(20, 0)
changeit(x, y) =>
    tmp = array.get(suportresistance, y * 2)
    array.set(suportresistance, y * 2, array.get(suportresistance, x * 2))
    array.set(suportresistance, x * 2, tmp)
    tmp2 = array.get(suportresistance, y * 2 + 1)
    array.set(suportresistance, y * 2 + 1, array.get(suportresistance, x * 2 + 1))
    array.set(suportresistance, x * 2 + 1, tmp2)

if bool(ph) or bool(pl)
    supres = array.new_float(0)
    stren = array.new_float(10, 0)
    for x = 0 to array.size(pivotvals) - 1 by 1
        [hi, lo, strength] = get_sr_vals(x)
        array.push(supres, strength)
        array.push(supres, hi)
        array.push(supres, lo)

    for x = 0 to array.size(pivotvals) - 1 by 1
        h = array.get(supres, x * 3 + 1)
        l = array.get(supres, x * 3 + 2)
        s = 0
        for y = 0 to loopback by 1
            if high[y] <= h and high[y] >= l or low[y] <= h and low[y] >= l
                s := s + 1
        array.set(supres, x * 3, array.get(supres, x * 3) + s)

    array.fill(suportresistance, 0)
    src = 0
    for x = 0 to array.size(pivotvals) - 1 by 1
        stv = -1.0
        stl = -1
        for y = 0 to array.size(pivotvals) - 1 by 1
            if array.get(supres, y * 3) > stv and array.get(supres, y * 3) >= minstrength * 20
                stv := array.get(supres, y * 3)
                stl := y
        if stl >= 0
            hh = array.get(supres, stl * 3 + 1)
            ll = array.get(supres, stl * 3 + 2)
            array.set(suportresistance, src * 2, hh)
            array.set(suportresistance, src * 2 + 1, ll)
            array.set(stren, src, array.get(supres, stl * 3))
            for y = 0 to array.size(pivotvals) - 1 by 1
                if array.get(supres, y * 3 + 1) <= hh and array.get(supres, y * 3 + 1) >= ll or array.get(supres, y * 3 + 2) <= hh and array.get(supres, y * 3 + 2) >= ll
                    array.set(supres, y * 3, -1)
            src := src + 1
            if src >= 10
                break

    for x = 0 to 8 by 1
        for y = x + 1 to 9 by 1
            if array.get(stren, y) > array.get(stren, x)
                changeit(x, y)

// ============================================================
// ZONE INVALIDATION -- broken zones disappear and stay gone
// (resistance broken above = zone removed; support broken below = zone removed)
// ============================================================
var invTop = array.new_float(0)
var invBot = array.new_float(0)
epsilon = syminfo.mintick * 2

f_isInvalidated(t, b) =>
    found = false
    if array.size(invTop) > 0
        for i = 0 to array.size(invTop) - 1 by 1
            if math.abs(array.get(invTop, i) - t) < epsilon and math.abs(array.get(invBot, i) - b) < epsilon
                found := true
    found

for x = 0 to math.min(9, maxnumsr) by 1
    top = array.get(suportresistance, x * 2)
    bot = array.get(suportresistance, x * 2 + 1)
    if top != 0 and bot != 0
        if f_isInvalidated(top, bot)
            // previously broken zone re-surfaced from recalculation -> keep it cleared
            array.set(suportresistance, x * 2, 0)
            array.set(suportresistance, x * 2 + 1, 0)
        else
            wasResistance = top > close[1] and bot > close[1]
            wasSupport    = top < close[1] and bot < close[1]
            brokeUp   = wasResistance and close > top
            brokeDown = wasSupport and close < bot
            if brokeUp or brokeDown
                array.push(invTop, top)
                array.push(invBot, bot)
                array.set(suportresistance, x * 2, 0)
                array.set(suportresistance, x * 2 + 1, 0)

if array.size(invTop) > 50
    array.shift(invTop)
    array.shift(invBot)

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

var srboxes = array.new_box(10)
for x = 0 to math.min(9, maxnumsr) by 1
    box.delete(array.get(srboxes, x))
    zcol = get_color(x * 2)
    if not na(zcol)
        array.set(srboxes, x, box.new(left = bar_index, top = get_level(x * 2), right = bar_index + 1, bottom = get_level(x * 2 + 1), border_color = zcol, border_width = 1, extend = extend.both, bgcolor = zcol))

// ============================================================
// TOUCH + REJECTION CONFIRMATION (mean-reversion signal logic)
// Touch = price wicks into a zone this bar
// Confirm = NEXT bar closes back outside the zone (close-back-through)
// ============================================================
float touchTopNow = na
float touchBotNow = na
for x = 0 to math.min(9, maxnumsr) by 1
    top = get_level(x * 2)
    bot = get_level(x * 2 + 1)
    if not na(top) and not na(bot)
        if close > top and low <= top and low >= bot
            touchTopNow := top   // support zone touched (price sits above zone, wicked into it)
        if close < bot and high >= bot and high <= top
            touchBotNow := bot  // resistance zone touched (price sits below zone, wicked into it)

var float prevTouchTop = na
var float prevTouchBot = na

buySignal  = not na(prevTouchTop) and close[1] <= prevTouchTop and close > prevTouchTop
sellSignal = not na(prevTouchBot) and close[1] >= prevTouchBot and close < prevTouchBot

prevTouchTop := touchTopNow
prevTouchBot := touchBotNow

// ============================================================
// DXY MULTI-TIMEFRAME BIAS (Close vs SMA -- same rule every timeframe)
// ============================================================
f_bias(sym, tf) =>
    c = request.security(sym, tf, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    m = request.security(sym, tf, ta.sma(close, biasMaLen), lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    c - m   // float: positive = bullish, negative = bearish, na = data unavailable

dxyBiasH1 = f_bias(dxySymbol, '60')
dxyBiasH4 = f_bias(dxySymbol, '240')
dxyBiasD  = f_bias(dxySymbol, 'D')
dxyBiasW  = f_bias(dxySymbol, 'W')

goldBiasH1 = f_bias(syminfo.tickerid, '60')
goldBiasH4 = f_bias(syminfo.tickerid, '240')
goldBiasD  = f_bias(syminfo.tickerid, 'D')
goldBiasW  = f_bias(syminfo.tickerid, 'W')

// D1 + H4 must agree (and both must have valid data) for the filter to confirm a directional bias
dxyBearishConfirmed = not na(dxyBiasD) and not na(dxyBiasH4) and dxyBiasD < 0 and dxyBiasH4 < 0   // supports GOLD BUY
dxyBullishConfirmed = not na(dxyBiasD) and not na(dxyBiasH4) and dxyBiasD > 0 and dxyBiasH4 > 0    // supports GOLD SELL

finalBuy  = useDxyFilter ? buySignal and dxyBearishConfirmed : buySignal
finalSell = useDxyFilter ? sellSignal and dxyBullishConfirmed : sellSignal

// ============================================================
// PLOTS
// ============================================================
plotshape(finalBuy, title = 'BUY', style = shape.triangleup, location = location.belowbar, color = color.new(color.blue, 0), size = size.small)
plotshape(finalSell, title = 'SELL', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.small)

plotshape(showUnfiltered and buySignal and not finalBuy, title = 'BUY (unfiltered)', style = shape.triangleup, location = location.belowbar, color = color.new(color.blue, 60), size = size.tiny)
plotshape(showUnfiltered and sellSignal and not finalSell, title = 'SELL (unfiltered)', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 60), size = size.tiny)

alertcondition(finalBuy, title = 'Gold Buy Signal', message = 'Gold BUY: support zone rejection confirmed, DXY bearish D1+H4')
alertcondition(finalSell, title = 'Gold Sell Signal', message = 'Gold SELL: resistance zone rejection confirmed, DXY bullish D1+H4')

// ============================================================
// XAUUSD vs DXY BIAS TABLE
// ============================================================
var table biasTable = table.new(tablePos, 3, 6, border_width = 1)

f_cellcolor(diff) => na(diff) ? color.new(color.gray, 50) : diff > 0 ? color.new(color.green, 30) : color.new(color.red, 30)
f_celltext(diff) => na(diff) ? 'N/A' : diff > 0 ? 'Bullish' : 'Bearish'

if showTable and barstate.islast
    table.cell(biasTable, 0, 0, 'Trend Bias', bgcolor = color.new(color.black, 0), text_color = color.white)
    table.cell(biasTable, 1, 0, 'XAUUSD', bgcolor = color.new(color.black, 0), text_color = color.white)
    table.cell(biasTable, 2, 0, 'DXY', bgcolor = color.new(color.black, 0), text_color = color.white)

    table.cell(biasTable, 0, 1, 'H1', bgcolor = color.new(color.gray, 60), text_color = color.white)
    table.cell(biasTable, 1, 1, f_celltext(goldBiasH1), bgcolor = f_cellcolor(goldBiasH1), text_color = color.white)
    table.cell(biasTable, 2, 1, f_celltext(dxyBiasH1), bgcolor = f_cellcolor(dxyBiasH1), text_color = color.white)

    table.cell(biasTable, 0, 2, 'H4', bgcolor = color.new(color.gray, 60), text_color = color.white)
    table.cell(biasTable, 1, 2, f_celltext(goldBiasH4), bgcolor = f_cellcolor(goldBiasH4), text_color = color.white)
    table.cell(biasTable, 2, 2, f_celltext(dxyBiasH4), bgcolor = f_cellcolor(dxyBiasH4), text_color = color.white)

    table.cell(biasTable, 0, 3, 'Daily', bgcolor = color.new(color.gray, 60), text_color = color.white)
    table.cell(biasTable, 1, 3, f_celltext(goldBiasD), bgcolor = f_cellcolor(goldBiasD), text_color = color.white)
    table.cell(biasTable, 2, 3, f_celltext(dxyBiasD), bgcolor = f_cellcolor(dxyBiasD), text_color = color.white)

    table.cell(biasTable, 0, 4, 'Weekly', bgcolor = color.new(color.gray, 60), text_color = color.white)
    table.cell(biasTable, 1, 4, f_celltext(goldBiasW), bgcolor = f_cellcolor(goldBiasW), text_color = color.white)
    table.cell(biasTable, 2, 4, f_celltext(dxyBiasW), bgcolor = f_cellcolor(dxyBiasW), text_color = color.white)

    table.cell(biasTable, 0, 5, 'Note', bgcolor = color.new(color.black, 0), text_color = color.white)
    table.merge_cells(biasTable, 1, 5, 2, 5)
    table.cell(biasTable, 1, 5, 'DXY up = XAUUSD down (inverse)', bgcolor = color.new(color.black, 0), text_color = color.white)
````
