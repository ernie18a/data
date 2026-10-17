# session high/low teszt

- url: https://www.tradingview.com/script/vdEebaiV-session-high-low-teszt/
- type: indicator
- pine_id: PUB;041c31f25bd54056a22276a6af837725
- version: 1.0

## Description

legkomoylabb indikator aki komoly ezt hasznalja 100% winrate 0 loss 67RR stratégia

## Source Code

````pine
//@version=5
indicator("session high/low teszt", overlay=true, max_lines_count=500, max_labels_count=500)

//========================
// Inputs
//========================
tz = input.string("America/New_York", "Session Timezone")

asiaCore = input.session("1800-0000", "Asia CORE (NY)")
lonCore  = input.session("0200-0500", "London CORE (NY)")
nyCore   = input.session("0930-1100", "New York AM (NY)")

useAsiaCarry  = input.bool(true,  "Asia Carry 00:00–03:00")
asiaCarrySess = input.session("0000-0200", "Asia Carry Window")

useLonCarry   = input.bool(true,  "London Carry 05:00–09:30")
lonCarrySess  = input.session("0500-0930", "London Carry Window")

useNYCarry    = input.bool(true,  "NY Carry 11:00–16:00")
nyCarrySess   = input.session("1100-1600", "NY Carry Window")

extendAsiaMins   = input.int(360, "Extend Asia (mins)", minval=0)
extendLondonMins = input.int(360, "Extend London (mins)", minval=0)
extendNYMins     = input.int(240, "Extend NY (mins)", minval=0)

//========================
// Colors & Appearance (Customizable)
//========================
lineW   = input.int(2, "Line Width", minval=1, maxval=5, group="Appearance")

asiaCol = input.color(color.rgb(95, 175, 115), title="Asia Color", group="Appearance")
lonCol  = input.color(color.rgb(24, 203, 227), title="London Color", group="Appearance")
nyCol   = input.color(color.rgb(60, 60, 60),   title="New York Color", group="Appearance")

//========================
// Helpers
//========================
ms_from_mins(_m) => _m * 60 * 1000
in_session(_sess) => not na(time(timeframe.period, _sess, tz))

//==================================================
// Session engine (lines + labels strictly at the exact candle)
//==================================================
f_session(_core, _carry, _useCarry, _extendMins, _col, _name) =>
    coreIn    = in_session(_core)
    coreStart = coreIn and not coreIn[1]
    coreEnd   = not coreIn and coreIn[1]

    carryIn   = in_session(_carry)
    trackIn   = coreIn or (_useCarry and carryIn)

    var float H = na
    var float L = na
    var int   HT = na
    var int   LT = na
    var int   endX = na

    var line  HLn = na
    var line  LLn = na
    var label HLb = na
    var label LLb = na

    if coreStart
        if not na(HLn)
            line.delete(HLn)
            HLn := na
        if not na(LLn)
            line.delete(LLn)
            LLn := na
        if not na(HLb)
            label.delete(HLb)
            HLb := na
        if not na(LLb)
            label.delete(LLb)
            LLb := na

        H := high
        L := low
        HT := time
        LT := time
        endX := na

        // A címkék stílusának beállítása: átlátszó háttér, szöveg a gyertya felett (down) és alatt (up)
        HLb := label.new(time, H, _name + " High", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.white, 100), textcolor=_col, size=size.tiny)
        LLb := label.new(time, L, _name + " Low",  xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.white, 100), textcolor=_col, size=size.tiny)

    if trackIn
        if na(H) or high > H
            H := high
            HT := time
        if na(L) or low < L
            L := low
            LT := time

    if coreEnd
        endX := time[1] + ms_from_mins(_extendMins)

    x2 = trackIn ? time : (na(endX) ? time : endX)

    if not na(H) and not na(HT)
        if na(HLn)
            HLn := line.new(HT, H, x2, H, xloc=xloc.bar_time, color=_col, width=lineW, extend=extend.right)
        line.set_xy1(HLn, HT, H)
        line_x2_H = x2 > HT ? x2 : HT + ms_from_mins(1)
        line.set_xy2(HLn, line_x2_H, H)

    if not na(L) and not na(LT)
        if na(LLn)
            LLn := line.new(LT, L, x2, L, xloc=xloc.bar_time, color=_col, width=lineW, extend=extend.right)
        line.set_xy1(LLn, LT, L)
        line_x2_L = x2 > LT ? x2 : LT + ms_from_mins(1)
        line.set_xy2(LLn, line_x2_L, L)

    // A feliratok mostantól a High és Low keletkezésének gyertyáját (HT és LT) követik
    if not na(HLb) and not na(H)
        label.set_xy(HLb, HT, H)
    if not na(LLb) and not na(L)
        label.set_xy(LLb, LT, L)

//==================================================
// Apply sessions
//==================================================
f_session(asiaCore, asiaCarrySess, useAsiaCarry, extendAsiaMins, asiaCol, "Asia")
f_session(lonCore,  lonCarrySess,  useLonCarry,  extendLondonMins, lonCol, "London")
f_session(nyCore,   nyCarrySess,   useNYCarry,   extendNYMins,     nyCol, "New York")
````
