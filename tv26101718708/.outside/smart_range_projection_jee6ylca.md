# Smart Range Projection

- url: https://www.tradingview.com/script/JeE6YLCa-Smart-Range-Projection/
- type: indicator
- pine_id: PUB;e339435ec854463ebecfcbebe875f6d0
- version: 1.0

## Description

Smart Range Projection — Daily High/Low Forecast from Opening Volatility

OVERVIEW
This indicator projects the likely shape of the trading day early in the session, anchoring everything to the day's opening price. It plots the expected daily range envelope, an expansion range for potential trend day extension, and reversal zones near the projected extremes where 
price often exhausts or turns.

The projection is built from a blend of four independent volatility inputs: daily ATR, opening volatility, CPR width, and an optional VIX multiplier. Once the opening window completes, the levels lock in for the rest of the session and do not shift.

HOW IT WORKS

1. Daily ATR Baseline
The previous day's confirmed ATR sets the expected full-day travel. 
A user-defined multiplier (default 1.0x) converts this into the projected day range.

2. Opening Volatility Factor
The indicator measures the high-low range of the first N bars after the session opens (default 3 bars) and compares it to a rolling 20-day average of opening ranges. An unusually wide opening stretches the projection. An unusually narrow opening tightens it. The influence is 
user-controlled (default 0.5).

3. CPR Width Lean
Central Pivot Range width is calculated from the previous day's high, low, and close. The current day's CPR width is compared to its 20-day average. A narrow CPR (relative to history) widens the projection because narrow CPRs statistically precede trending or expansion days. 
A wide CPR tightens the projection.

4. VIX Multiplier (Optional)
An optional volatility-index input scales the entire projection based on the regime. Above the user-defined neutral level, the range widens. 
Below it, the range tightens. Disabled by default. Enable only if your local volatility index is available on TradingView.

5. Reversal and Expansion Zones
- Projected High and Projected Low: the expected daily range envelope
- Expansion High and Low: dashed lines beyond the normal range, marking trend day extension targets
- Reversal Zones: shaded bands just inside the projected extremes where price often exhausts on normal days
- Expansion Zones: shaded bands between the normal envelope and expansion lines, highlighting trend day extension territory

NON-REPAINTING DESIGN
- Prior-day values use historical offset [1] with lookahead_off
- Day open is tracked locally via session change detection
- Projection levels lock once the opening window completes and remain fixed for the rest of the session
- No future data access, no lookahead leak

INPUTS
- Daily ATR length and base range multiplier
- Expansion multiplier and reversal zone percentage
- Opening window bars and volatility influence
- Optional VIX symbol, neutral level, and toggle
- CPR lean toggle, dashboard toggle, level rounding toggle
- Color customization for all elements

DASHBOARD
A status panel shows projected high and low, expansion high and low, day lean classification (Trend or Range bias from CPR width), measured opening volatility, and the active VIX multiplier.

ALERTS
Four alert conditions are available:
- Price reached projected day high
- Price reached projected day low
- Price hit expansion high (trend day extension)
- Price hit expansion low (trend day extension)

HOW TO USE
The projected high and low serve as the day's expected range boundaries. 
Price reaching these zones early often coincides with exhaustion on range days. The expansion lines act as continuation targets when strong directional moves break the normal range envelope.

The day lean classification in the dashboard helps set expectations. 
A Trend lean (narrow CPR) suggests price is more likely to reach the expansion lines. A Range lean (wide CPR) suggests price is more likely to oscillate within the normal envelope and reverse at the extremes.

This indicator works on intraday timeframes where multiple bars fit within a session. It is most effective on actively traded instruments with reliable opening sessions.

NOTES
This is a technical analysis tool intended for educational and informational purposes. Volatility projections are statistical estimates based on historical patterns and do not guarantee price will reach the projected levels. Always apply proper risk management and combine with 
your own trading methodology.

CREDITS
Original implementation. Uses TradingView built-in ATR, security, and array functions combined with original opening volatility and CPR width lean methodology.

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════
//  SMART RANGE PROJECTION
//  Pine Script v6 | TradingView Compliant | Non-Repainting
//
//  Projects the likely shape of the trading day, early in the session:
//   • Projected DAY HIGH / DAY LOW   (expected range envelope)
//   • EXPANSION RANGE                (trend-day extension targets)
//   • REVERSAL ZONES                 (where price often exhausts/turns)
//
//  Built from a blend of:
//   • Daily ATR                — baseline expected travel
//   • Opening volatility       — first-N-bars range vs its average
//   • CPR width                — narrow CPR leans trend/expansion day
//   • VIX (optional)           — volatility regime multiplier
//
//  All anchored to the day's OPEN. Levels are fixed once the opening
//  window completes, so they don't shift around for the rest of the day.
//
//  Non-repainting design: prior-day values use historical offset [1] with
//  lookahead_off. Projection locks after the opening window completes.
// ════════════════════════════════════════════════════════════════════

//@version=6
indicator("Smart Range Projection",
          shorttitle       = "RANGE-PROJ",
          overlay          = true,
          max_lines_count  = 60,
          max_labels_count = 40,
          max_boxes_count  = 20)

// ─────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────
G1 = "Projection Engine"
G2 = "Opening Volatility"
G3 = "VIX (optional)"
G4 = "Display"

i_atr_len   = input.int(14,   "Daily ATR Length", minval=5, maxval=50, group=G1)
i_base_mult = input.float(1.0,"Base Range (× Daily ATR)", minval=0.3, maxval=2.0, step=0.1, group=G1,
              tooltip="Expected full-day range as a multiple of daily ATR.")
i_exp_mult  = input.float(1.5,"Expansion Range (× Daily ATR)", minval=0.8, maxval=3.0, step=0.1, group=G1,
              tooltip="Trend-day extension target beyond the normal range.")
i_rev_pct   = input.float(85.0,"Reversal Zone (% of range)", minval=60.0, maxval=100.0, step=5.0, group=G1,
              tooltip="Zone near the projected extremes where price often exhausts or turns.")

i_open_bars = input.int(3,    "Opening Window (bars)", minval=1, maxval=12, group=G2,
              tooltip="How many bars after the open define opening volatility.")
i_open_infl = input.float(0.5,"Opening Volatility Influence", minval=0.0, maxval=1.0, step=0.1, group=G2,
              tooltip="How much an unusually wide or narrow open stretches or shrinks the projection.")

i_use_vix   = input.bool(false, "Use VIX multiplier", group=G3,
              tooltip="OFF by default. If your symbol VIX is available on TradingView, enable and set below.")
i_vix_sym   = input.symbol("CBOE:VIX", "VIX Symbol", group=G3,
              tooltip="For example CBOE:VIX for US, or your local volatility index ticker.")
i_vix_base  = input.float(15.0, "VIX Neutral Level", minval=5.0, maxval=40.0, step=1.0, group=G3,
              tooltip="VIX above this widens the projection. Below it tightens. Tune to your market.")

i_show_cpr  = input.bool(true, "Use CPR width lean", group=G4)
i_show_dash = input.bool(true, "Show Dashboard", group=G4)
i_round     = input.bool(true, "Round levels to whole numbers", group=G4)
i_col_hi    = input.color(#EF5350, "Projected High / Resistance", group=G4)
i_col_lo    = input.color(#26A69A, "Projected Low / Support", group=G4)
i_col_exp   = input.color(color.new(#7E57C2, 80), "Expansion Zone", group=G4)
i_col_rev   = input.color(color.new(#FF9100, 75), "Reversal Zone", group=G4)

rnd(x) => i_round ? math.round(x) : x

// ─────────────────────────────────────────────────────
//  PRIOR-DAY DATA + CPR (non-repaint, lookahead_off)
// ─────────────────────────────────────────────────────
// Using historical offset [1] with lookahead_off = safe non-repainting access
// to previous day's confirmed values.
pdh = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_off)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)

pivot  = (pdh + pdl + pdc) / 3.0
bc     = (pdh + pdl) / 2.0
tc     = (pivot - bc) + pivot
cprTop = math.max(tc, bc)
cprBot = math.min(tc, bc)
cprWidth = cprTop - cprBot
cprWidthPct = pdc != 0 ? cprWidth / pdc * 100 : na

// Daily ATR from previous completed day — safe non-repaint
dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(i_atr_len)[1], lookahead = barmerge.lookahead_off)

// Day open — current day's open value, tracked locally to avoid future-leak
var float dayOpen = na
isNewDay = ta.change(time("D")) != 0
if isNewDay
    dayOpen := open

// CPR-width lean: narrow CPR → expect expansion (widen); wide CPR → range (tighten)
var array<float> cprwHist = array.new<float>()
if isNewDay and not na(cprWidthPct)
    array.push(cprwHist, cprWidthPct)
    if array.size(cprwHist) > 20
        array.shift(cprwHist)

cprwAvg = array.size(cprwHist) > 2 ? array.avg(cprwHist) : na
cprLean = 1.0
if i_show_cpr and not na(cprwAvg) and cprwAvg > 0 and not na(cprWidthPct)
    ratio = cprWidthPct / cprwAvg
    cprLean := math.max(0.8, math.min(1.0 + (1.0 - ratio) * 0.3, 1.25))

// ─────────────────────────────────────────────────────
//  VIX MULTIPLIER (optional, non-repaint)
// ─────────────────────────────────────────────────────
vixVal = i_use_vix ? request.security(i_vix_sym, "D", close[1], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off) : na
vixMult = 1.0
if i_use_vix and not na(vixVal) and i_vix_base > 0
    vixMult := math.max(0.7, math.min(vixVal / i_vix_base, 1.6))

// ─────────────────────────────────────────────────────
//  OPENING VOLATILITY
// ─────────────────────────────────────────────────────
var int   barInDay   = 0
var float openHi     = na
var float openLo     = na
var float openRange  = na
var bool  openLocked = false

if isNewDay
    barInDay := 1
    openHi := high
    openLo := low
    openRange := na
    openLocked := false
else
    barInDay += 1
    openHi := math.max(openHi, high)
    openLo := math.min(openLo, low)

if barInDay == i_open_bars and not openLocked
    openRange := openHi - openLo
    openLocked := true

var array<float> orHist = array.new<float>()
if barInDay == i_open_bars and not na(openRange)
    array.push(orHist, openRange)
    if array.size(orHist) > 20
        array.shift(orHist)
orAvg = array.size(orHist) > 2 ? array.avg(orHist) : na

openFactor = 1.0
if openLocked and not na(openRange) and not na(orAvg) and orAvg > 0
    orRatio = openRange / orAvg
    openFactor := 1.0 + (orRatio - 1.0) * i_open_infl
    openFactor := math.max(0.7, math.min(openFactor, 1.5))

// ─────────────────────────────────────────────────────
//  PROJECTION MATH
// ─────────────────────────────────────────────────────
combMult = cprLean * vixMult * openFactor
halfBase = na(dailyAtr) ? na : dailyAtr * i_base_mult * 0.5 * combMult
halfExp  = na(dailyAtr) ? na : dailyAtr * i_exp_mult  * 0.5 * combMult

projHi = dayOpen + halfBase
projLo = dayOpen - halfBase
expHi  = dayOpen + halfExp
expLo  = dayOpen - halfExp

revHiInner = dayOpen + halfBase * (i_rev_pct / 100.0)
revLoInner = dayOpen - halfBase * (i_rev_pct / 100.0)

// ─────────────────────────────────────────────────────
//  DRAW
// ─────────────────────────────────────────────────────
var line  lnHi = na
var line  lnLo = na
var line  lnEH = na
var line  lnEL = na
var box   boxRevHi = na
var box   boxRevLo = na
var box   boxExpHi = na
var box   boxExpLo = na
var label lbHi = na
var label lbLo = na
var label lbEH = na
var label lbEL = na

f_clear() =>
    if not na(lnHi)
        line.delete(lnHi)
        line.delete(lnLo)
        line.delete(lnEH)
        line.delete(lnEL)
    if not na(boxRevHi)
        box.delete(boxRevHi)
        box.delete(boxRevLo)
        box.delete(boxExpHi)
        box.delete(boxExpLo)
    if not na(lbHi)
        label.delete(lbHi)
        label.delete(lbLo)
        label.delete(lbEH)
        label.delete(lbEL)

if barInDay == i_open_bars and openLocked and not na(halfBase)
    f_clear()
    xL = bar_index
    xR = bar_index + 30

    lnHi := line.new(xL, projHi, xR, projHi, color = i_col_hi, width = 2)
    lnLo := line.new(xL, projLo, xR, projLo, color = i_col_lo, width = 2)
    lnEH := line.new(xL, expHi,  xR, expHi,  color = i_col_hi, width = 1, style = line.style_dashed)
    lnEL := line.new(xL, expLo,  xR, expLo,  color = i_col_lo, width = 1, style = line.style_dashed)

    boxExpHi := box.new(xL, expHi,  xR, projHi, border_color = na, bgcolor = i_col_exp)
    boxExpLo := box.new(xL, projLo, xR, expLo,  border_color = na, bgcolor = i_col_exp)

    boxRevHi := box.new(xL, projHi, xR, revHiInner, border_color = na, bgcolor = i_col_rev)
    boxRevLo := box.new(xL, revLoInner, xR, projLo, border_color = na, bgcolor = i_col_rev)

    lbHi := label.new(xR, projHi, "Proj High " + str.tostring(rnd(projHi)),
            style = label.style_label_left, color = i_col_hi, textcolor = color.white, size = size.small)
    lbLo := label.new(xR, projLo, "Proj Low " + str.tostring(rnd(projLo)),
            style = label.style_label_left, color = i_col_lo, textcolor = color.white, size = size.small)
    lbEH := label.new(xR, expHi, "Exp High " + str.tostring(rnd(expHi)),
            style = label.style_label_left, color = color.new(i_col_hi, 30), textcolor = color.white, size = size.tiny)
    lbEL := label.new(xR, expLo, "Exp Low " + str.tostring(rnd(expLo)),
            style = label.style_label_left, color = color.new(i_col_lo, 30), textcolor = color.white, size = size.tiny)

if openLocked and not isNewDay and not na(lnHi)
    xR2 = bar_index + 30
    line.set_x2(lnHi, xR2)
    line.set_x2(lnLo, xR2)
    line.set_x2(lnEH, xR2)
    line.set_x2(lnEL, xR2)
    box.set_right(boxExpHi, xR2)
    box.set_right(boxExpLo, xR2)
    box.set_right(boxRevHi, xR2)
    box.set_right(boxRevLo, xR2)
    label.set_x(lbHi, xR2)
    label.set_x(lbLo, xR2)
    label.set_x(lbEH, xR2)
    label.set_x(lbEL, xR2)

// ─────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 7,
                  border_width = 1, border_color = color.new(color.gray, 60),
                  frame_width = 1, frame_color = color.new(color.gray, 50))

f_cell(_t, _c, _txt, _col, _bg) => table.cell(dash, _c, _t, _txt, text_color = _col, bgcolor = _bg, text_size = size.small)

if i_show_dash and barstate.islast
    bgHdr = color.new(#311B92, 0)
    bgRow = color.new(#4527A0, 25)

    dayType = cprLean >= 1.1 ? "TREND lean" : cprLean <= 0.95 ? "RANGE lean" : "Neutral"

    f_cell(0, 0, "RANGE-PROJ", color.white, bgHdr)
    table.merge_cells(dash, 0, 0, 1, 0)

    f_cell(1, 0, "Proj High", color.silver, bgRow)
    f_cell(1, 1, na(projHi) ? "—" : str.tostring(rnd(projHi)), i_col_hi, bgRow)

    f_cell(2, 0, "Proj Low", color.silver, bgRow)
    f_cell(2, 1, na(projLo) ? "—" : str.tostring(rnd(projLo)), i_col_lo, bgRow)

    f_cell(3, 0, "Exp High / Low", color.silver, bgRow)
    f_cell(3, 1, na(expHi) ? "—" : str.tostring(rnd(expHi)) + " / " + str.tostring(rnd(expLo)), color.white, bgRow)

    f_cell(4, 0, "Day Lean", color.silver, bgRow)
    f_cell(4, 1, dayType, color.white, cprLean >= 1.1 ? color.new(#7E57C2, 30) : bgRow)

    f_cell(5, 0, "Open Vol", color.silver, bgRow)
    f_cell(5, 1, openLocked and not na(openRange) ? str.tostring(rnd(openRange)) + " pts" : "measuring...", color.white, bgRow)

    f_cell(6, 0, "VIX Mult", color.silver, bgRow)
    f_cell(6, 1, i_use_vix and not na(vixVal) ? str.tostring(vixMult, "#.##") + "x" : "off", color.white, bgRow)

// ─────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────
alertcondition(openLocked and not na(projHi) and ta.crossover(high, projHi) and barstate.isconfirmed,
     title = "Reached Projected High", message = "[RANGE-PROJ] Price reached the projected day high. Watch the reversal zone.")
alertcondition(openLocked and not na(projLo) and ta.crossunder(low, projLo) and barstate.isconfirmed,
     title = "Reached Projected Low", message = "[RANGE-PROJ] Price reached the projected day low. Watch the reversal zone.")
alertcondition(openLocked and not na(expHi) and ta.crossover(high, expHi) and barstate.isconfirmed,
     title = "Expansion High Hit", message = "[RANGE-PROJ] Price hit the expansion high. Trend-day extension.")
alertcondition(openLocked and not na(expLo) and ta.crossunder(low, expLo) and barstate.isconfirmed,
     title = "Expansion Low Hit", message = "[RANGE-PROJ] Price hit the expansion low. Trend-day extension.")
````
