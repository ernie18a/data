# SSMT pp on the pp

- url: https://www.tradingview.com/script/vUabmdSA-SSMT-pp-on-the-pp/
- type: indicator
- pine_id: PUB;fc7267bb77ab44a8972977728a61ba62
- version: 1.0

## Description

ssmts

monthly
weekly
daily
90
micro

this indicator represents ssmts of the qurterly theory confluences and market phases

## Source Code

````pine
//@version=6

indicator("SSMT Scanner", overlay=true)

// ============================================================
// INPUTS
// ============================================================
grp(n) => "Asset " + str.tostring(n)

sym1 = input.symbol("FX:EURUSD", "Symbol", group=grp(1))
inv1 = input.bool(false, "Invert", group=grp(1))
sym2 = input.symbol("FX:GBPUSD", "Symbol", group=grp(2))
inv2 = input.bool(false, "Invert", group=grp(2))
sym3 = input.symbol("FX:AUDUSD", "Symbol", group=grp(3))
inv3 = input.bool(false, "Invert", group=grp(3))
sym4 = input.symbol("FX:NZDUSD", "Symbol", group=grp(4))
inv4 = input.bool(false, "Invert", group=grp(4))
sym5 = input.symbol("FX:USDCAD", "Symbol", group=grp(5))
inv5 = input.bool(true, "Invert", group=grp(5))
sym6 = input.symbol("FX:USDJPY", "Symbol", group=grp(6))
inv6 = input.bool(true, "Invert", group=grp(6))
sym7 = input.symbol("FX:USDCHF", "Symbol", group=grp(7))
inv7 = input.bool(true, "Invert", group=grp(7))
sym8 = input.symbol("FX:USDSEK", "Symbol", group=grp(8))
inv8 = input.bool(true, "Invert", group=grp(8))

labelMode = input.string("Failed / non-confirming", "Table shows", group="Display",
     options=["Breaker", "Failed / non-confirming"])

tablePosInput = input.string("top_right", "Table position", group="Display",
     options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"])

bullColor    = input.color(color.new(color.green, 0), "Bullish color", group="Display")
bearColor    = input.color(color.new(color.red, 0), "Bearish color", group="Display")
neutralColor = input.color(color.new(color.gray, 0), "Neutral color", group="Display")

// ============================================================
// HELPERS
// ============================================================
f_tablePos(pos) =>
    pos == "top_right" ? position.top_right :
     pos == "top_left" ? position.top_left :
     pos == "bottom_right" ? position.bottom_right :
     pos == "bottom_left" ? position.bottom_left :
     pos == "middle_right" ? position.middle_right :
     position.middle_left

f_shortName(s) =>
    idx = str.pos(s, ":")
    na(idx) ? s : str.substring(s, idx + 1)

names = array.from(
     f_shortName(sym1), f_shortName(sym2), f_shortName(sym3), f_shortName(sym4),
     f_shortName(sym5), f_shortName(sym6), f_shortName(sym7), f_shortName(sym8))

f_periodHL(sym, tf, invert) =>
    [h, l, ph, pl] = request.security(sym, tf, [high, low, high[1], low[1]], lookahead=barmerge.lookahead_off)

    float curH = na
    float curL = na
    float prevH = na
    float prevL = na

    if invert
        curH  := 1.0 / l
        curL  := 1.0 / h
        prevH := 1.0 / pl
        prevL := 1.0 / ph
    else
        curH  := h
        curL  := l
        prevH := ph
        prevL := pl

    brokeH = not na(curH) and not na(prevH) and curH > prevH
    brokeL = not na(curL) and not na(prevL) and curL < prevL

    [brokeH, brokeL]

// ============================================================
// NY SESSION HELPERS
// ============================================================
f_sessionId(mod) =>
    mod >= 18 * 60 ? 0 :
     mod < 6 * 60 ? 1 :
     mod < 12 * 60 ? 2 : 3

f_q90(mod, sid) =>
    sessionStart = sid == 0 ? 18 * 60 : sid == 1 ? 0 : sid == 2 ? 6 * 60 : 12 * 60
    offset = sid == 0 and mod < 18 * 60 ? mod + 24 * 60 - 18 * 60 : mod - sessionStart
    int(math.floor(offset / 90))

f_micro(mod, sid, q90) =>
    sessionStart = sid == 0 ? 18 * 60 : sid == 1 ? 0 : sid == 2 ? 6 * 60 : 12 * 60
    offset = sid == 0 and mod < 18 * 60 ? mod + 24 * 60 - 18 * 60 : mod - sessionStart
    within90 = offset - q90 * 90
    int(math.floor(within90 / 22.5))

// ============================================================
// DAILY ENGINE
// Daily = current 6-hour NY session vs previous 6-hour NY session
// ============================================================
f_dailySessionBreak(invert) =>
    float h = invert ? 1.0 / low : high
    float l = invert ? 1.0 / high : low

    mod = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
    sid = f_sessionId(mod)

    var int prevSid = na
    var float curH = na
    var float curL = na
    var float refH = na
    var float refL = na

    if na(prevSid)
        curH := h
        curL := l
        prevSid := sid
    else if sid != prevSid
        refH := curH
        refL := curL
        curH := h
        curL := l
        prevSid := sid
    else
        curH := na(curH) ? h : math.max(curH, h)
        curL := na(curL) ? l : math.min(curL, l)

    brokeH = not na(refH) and not na(curH) and curH > refH
    brokeL = not na(refL) and not na(curL) and curL < refL

    [brokeH, brokeL]

// ============================================================
// 90M ENGINE
// 90m = current 90-minute NY quarter vs previous 90-minute NY quarter
// ============================================================
f_90mBreak(invert) =>
    float h = invert ? 1.0 / low : high
    float l = invert ? 1.0 / high : low

    mod = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
    sid = f_sessionId(mod)
    q90 = f_q90(mod, sid)

    bucket = sid * 10 + q90

    var int prevBucket = na
    var float curH = na
    var float curL = na
    var float refH = na
    var float refL = na

    if na(prevBucket)
        curH := h
        curL := l
        prevBucket := bucket
    else if bucket != prevBucket
        refH := curH
        refL := curL
        curH := h
        curL := l
        prevBucket := bucket
    else
        curH := na(curH) ? h : math.max(curH, h)
        curL := na(curL) ? l : math.min(curL, l)

    brokeH = not na(refH) and not na(curH) and curH > refH
    brokeL = not na(refL) and not na(curL) and curL < refL

    [brokeH, brokeL]

// ============================================================
// MICRO ENGINE
// Micro = current 22.5-minute NY quarter vs previous 22.5-minute NY quarter
// ============================================================
f_microBreak(invert) =>
    float h = invert ? 1.0 / low : high
    float l = invert ? 1.0 / high : low

    mod = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
    sid = f_sessionId(mod)
    q90 = f_q90(mod, sid)
    mic = f_micro(mod, sid, q90)

    bucket = sid * 100 + q90 * 10 + mic

    var int prevBucket = na
    var float curH = na
    var float curL = na
    var float refH = na
    var float refL = na

    if na(prevBucket)
        curH := h
        curL := l
        prevBucket := bucket
    else if bucket != prevBucket
        refH := curH
        refL := curL
        curH := h
        curL := l
        prevBucket := bucket
    else
        curH := na(curH) ? h : math.max(curH, h)
        curL := na(curL) ? l : math.min(curL, l)

    brokeH = not na(refH) and not na(curH) and curH > refH
    brokeL = not na(refL) and not na(curL) and curL < refL

    [brokeH, brokeL]

// ============================================================
// MONTHLY CYCLE: CURRENT WEEK VS PREVIOUS WEEK
// ============================================================
[m1H, m1L] = f_periodHL(sym1, "W", inv1)
[m2H, m2L] = f_periodHL(sym2, "W", inv2)
[m3H, m3L] = f_periodHL(sym3, "W", inv3)
[m4H, m4L] = f_periodHL(sym4, "W", inv4)
[m5H, m5L] = f_periodHL(sym5, "W", inv5)
[m6H, m6L] = f_periodHL(sym6, "W", inv6)
[m7H, m7L] = f_periodHL(sym7, "W", inv7)
[m8H, m8L] = f_periodHL(sym8, "W", inv8)

monthlyBrokeH = array.from(m1H, m2H, m3H, m4H, m5H, m6H, m7H, m8H)
monthlyBrokeL = array.from(m1L, m2L, m3L, m4L, m5L, m6L, m7L, m8L)

// ============================================================
// WEEKLY CYCLE: CURRENT DAY VS PREVIOUS DAY
// ============================================================
[w1H, w1L] = f_periodHL(sym1, "D", inv1)
[w2H, w2L] = f_periodHL(sym2, "D", inv2)
[w3H, w3L] = f_periodHL(sym3, "D", inv3)
[w4H, w4L] = f_periodHL(sym4, "D", inv4)
[w5H, w5L] = f_periodHL(sym5, "D", inv5)
[w6H, w6L] = f_periodHL(sym6, "D", inv6)
[w7H, w7L] = f_periodHL(sym7, "D", inv7)
[w8H, w8L] = f_periodHL(sym8, "D", inv8)

weeklyBrokeH = array.from(w1H, w2H, w3H, w4H, w5H, w6H, w7H, w8H)
weeklyBrokeL = array.from(w1L, w2L, w3L, w4L, w5L, w6L, w7L, w8L)

// ============================================================
// DAILY CYCLE: CURRENT 6H SESSION VS PREVIOUS 6H SESSION
// ============================================================
[d1H, d1L] = request.security(sym1, "1", f_dailySessionBreak(inv1), lookahead=barmerge.lookahead_off)
[d2H, d2L] = request.security(sym2, "1", f_dailySessionBreak(inv2), lookahead=barmerge.lookahead_off)
[d3H, d3L] = request.security(sym3, "1", f_dailySessionBreak(inv3), lookahead=barmerge.lookahead_off)
[d4H, d4L] = request.security(sym4, "1", f_dailySessionBreak(inv4), lookahead=barmerge.lookahead_off)
[d5H, d5L] = request.security(sym5, "1", f_dailySessionBreak(inv5), lookahead=barmerge.lookahead_off)
[d6H, d6L] = request.security(sym6, "1", f_dailySessionBreak(inv6), lookahead=barmerge.lookahead_off)
[d7H, d7L] = request.security(sym7, "1", f_dailySessionBreak(inv7), lookahead=barmerge.lookahead_off)
[d8H, d8L] = request.security(sym8, "1", f_dailySessionBreak(inv8), lookahead=barmerge.lookahead_off)

dailyBrokeH = array.from(d1H, d2H, d3H, d4H, d5H, d6H, d7H, d8H)
dailyBrokeL = array.from(d1L, d2L, d3L, d4L, d5L, d6L, d7L, d8L)

// ============================================================
// 90M CYCLE: CURRENT 90M QUARTER VS PREVIOUS 90M QUARTER
// ============================================================
[q1H, q1L] = request.security(sym1, "1", f_90mBreak(inv1), lookahead=barmerge.lookahead_off)
[q2H, q2L] = request.security(sym2, "1", f_90mBreak(inv2), lookahead=barmerge.lookahead_off)
[q3H, q3L] = request.security(sym3, "1", f_90mBreak(inv3), lookahead=barmerge.lookahead_off)
[q4H, q4L] = request.security(sym4, "1", f_90mBreak(inv4), lookahead=barmerge.lookahead_off)
[q5H, q5L] = request.security(sym5, "1", f_90mBreak(inv5), lookahead=barmerge.lookahead_off)
[q6H, q6L] = request.security(sym6, "1", f_90mBreak(inv6), lookahead=barmerge.lookahead_off)
[q7H, q7L] = request.security(sym7, "1", f_90mBreak(inv7), lookahead=barmerge.lookahead_off)
[q8H, q8L] = request.security(sym8, "1", f_90mBreak(inv8), lookahead=barmerge.lookahead_off)

q90BrokeH = array.from(q1H, q2H, q3H, q4H, q5H, q6H, q7H, q8H)
q90BrokeL = array.from(q1L, q2L, q3L, q4L, q5L, q6L, q7L, q8L)

// ============================================================
// MICRO CYCLE: CURRENT 22.5M QUARTER VS PREVIOUS 22.5M QUARTER
// ============================================================
[u1H, u1L] = request.security(sym1, "1", f_microBreak(inv1), lookahead=barmerge.lookahead_off)
[u2H, u2L] = request.security(sym2, "1", f_microBreak(inv2), lookahead=barmerge.lookahead_off)
[u3H, u3L] = request.security(sym3, "1", f_microBreak(inv3), lookahead=barmerge.lookahead_off)
[u4H, u4L] = request.security(sym4, "1", f_microBreak(inv4), lookahead=barmerge.lookahead_off)
[u5H, u5L] = request.security(sym5, "1", f_microBreak(inv5), lookahead=barmerge.lookahead_off)
[u6H, u6L] = request.security(sym6, "1", f_microBreak(inv6), lookahead=barmerge.lookahead_off)
[u7H, u7L] = request.security(sym7, "1", f_microBreak(inv7), lookahead=barmerge.lookahead_off)
[u8H, u8L] = request.security(sym8, "1", f_microBreak(inv8), lookahead=barmerge.lookahead_off)

microBrokeH = array.from(u1H, u2H, u3H, u4H, u5H, u6H, u7H, u8H)
microBrokeL = array.from(u1L, u2L, u3L, u4L, u5L, u6L, u7L, u8L)

// ============================================================
// SSMT SCAN
// ============================================================
f_scan(bH, bL, mode) =>
    int bullIdx = na
    int bearIdx = na

    bool anyH = false
    bool anyNoH = false
    bool anyL = false
    bool anyNoL = false

    int breakerH = na
    int breakerL = na
    int failedH  = na
    int failedL  = na

    for i = 0 to 7
        h = array.get(bH, i)
        l = array.get(bL, i)

        if h
            anyH := true
            breakerH := i
        else
            anyNoH := true
            failedH := i

        if l
            anyL := true
            breakerL := i
        else
            anyNoL := true
            failedL := i

    if anyH and anyNoH
        bearIdx := mode == "Breaker" ? breakerH : failedH

    if anyL and anyNoL
        bullIdx := mode == "Breaker" ? breakerL : failedL

    [bullIdx, bearIdx]

[monthlyBull, monthlyBear] = f_scan(monthlyBrokeH, monthlyBrokeL, labelMode)
[weeklyBull, weeklyBear]   = f_scan(weeklyBrokeH, weeklyBrokeL, labelMode)
[dailyBull, dailyBear]     = f_scan(dailyBrokeH, dailyBrokeL, labelMode)
[q90Bull, q90Bear]         = f_scan(q90BrokeH, q90BrokeL, labelMode)
[microBull, microBear]     = f_scan(microBrokeH, microBrokeL, labelMode)

// ============================================================
// TABLE - DARK 3 COLUMN STYLE
// ============================================================
var table t = table.new(f_tablePos(tablePosInput), 3, 6, border_width=2)

if barstate.islast
    table.clear(t, 0, 0, 2, 5)

    headerBg = color.new(color.black, 20)
    labelBg  = color.new(color.black, 55)
    bearBg   = color.new(bearColor, 65)
    bullBg   = color.new(bullColor, 65)
    noneBg   = color.new(neutralColor, 80)

    monthlyBullTxt = na(monthlyBull) ? "None" : array.get(names, monthlyBull)
    monthlyBearTxt = na(monthlyBear) ? "None" : array.get(names, monthlyBear)
    weeklyBullTxt  = na(weeklyBull) ? "None" : array.get(names, weeklyBull)
    weeklyBearTxt  = na(weeklyBear) ? "None" : array.get(names, weeklyBear)
    dailyBullTxt   = na(dailyBull) ? "None" : array.get(names, dailyBull)
    dailyBearTxt   = na(dailyBear) ? "None" : array.get(names, dailyBear)
    q90BullTxt     = na(q90Bull) ? "None" : array.get(names, q90Bull)
    q90BearTxt     = na(q90Bear) ? "None" : array.get(names, q90Bear)
    microBullTxt   = na(microBull) ? "None" : array.get(names, microBull)
    microBearTxt   = na(microBear) ? "None" : array.get(names, microBear)

    table.cell(t, 0, 0, "Cycle", bgcolor=headerBg, text_color=color.white)
    table.cell(t, 1, 0, "Bearish", bgcolor=color.new(bearColor, 45), text_color=color.white)
    table.cell(t, 2, 0, "Bullish", bgcolor=color.new(bullColor, 45), text_color=color.white)

    table.cell(t, 0, 1, "Monthly", bgcolor=labelBg, text_color=color.white)
    table.cell(t, 1, 1, monthlyBearTxt, bgcolor=na(monthlyBear) ? noneBg : bearBg, text_color=color.white)
    table.cell(t, 2, 1, monthlyBullTxt, bgcolor=na(monthlyBull) ? noneBg : bullBg, text_color=color.white)

    table.cell(t, 0, 2, "Weekly", bgcolor=labelBg, text_color=color.white)
    table.cell(t, 1, 2, weeklyBearTxt, bgcolor=na(weeklyBear) ? noneBg : bearBg, text_color=color.white)
    table.cell(t, 2, 2, weeklyBullTxt, bgcolor=na(weeklyBull) ? noneBg : bullBg, text_color=color.white)

    table.cell(t, 0, 3, "Daily", bgcolor=labelBg, text_color=color.white)
    table.cell(t, 1, 3, dailyBearTxt, bgcolor=na(dailyBear) ? noneBg : bearBg, text_color=color.white)
    table.cell(t, 2, 3, dailyBullTxt, bgcolor=na(dailyBull) ? noneBg : bullBg, text_color=color.white)

    table.cell(t, 0, 4, "90", bgcolor=labelBg, text_color=color.white)
    table.cell(t, 1, 4, q90BearTxt, bgcolor=na(q90Bear) ? noneBg : bearBg, text_color=color.white)
    table.cell(t, 2, 4, q90BullTxt, bgcolor=na(q90Bull) ? noneBg : bullBg, text_color=color.white)

    table.cell(t, 0, 5, "Micro", bgcolor=labelBg, text_color=color.white)
    table.cell(t, 1, 5, microBearTxt, bgcolor=na(microBear) ? noneBg : bearBg, text_color=color.white)
    table.cell(t, 2, 5, microBullTxt, bgcolor=na(microBull) ? noneBg : bullBg, text_color=color.white)
````
