# CPR Scanner - NSE Nifty50

- url: https://www.tradingview.com/script/s0MIxKRR-CPR-Scanner-NSE-Nifty50/
- type: indicator
- pine_id: PUB;2901f0df17384c61bc7d4e9d36a56216
- version: 1.0

## Description

This indicator show which Nifty 50 stocks are in Narrow CPR range for Daily, Weekly or Monthly. Also it shows if the stock are above or below 200, 50 and 20 EMA.

Daily CPR -> check in 15min chart
Weekly CRP ->  Check in 1Hr Chart
Monthly CPR -> Check in Daily Chart

## Source Code

````pine
// ============================================================
// CPR SCANNER — NSE Nifty50 (Daily + Weekly + Monthly)
// ============================================================
// WHAT IS NARROW CPR?
//   CPR = Central Pivot Range (TC - BC range around Pivot)
//   Pivot  = (High + Low + Close) / 3
//   BC     = (High + Low) / 2
//   TC     = (Pivot - BC) + Pivot
//   Width% = (TC - BC) / Pivot × 100
//
//   A Narrow CPR means price was tightly compressed in the
//   prior period → signals coiled energy → high breakout odds
//
// SCORING (max 120):
//   Monthly Narrow CPR : 40 pts  (rarest, strongest signal)
//   Weekly Narrow CPR  : 35 pts
//   Daily Narrow CPR   : 25 pts
//   Above EMA 200      : 10 pts
//   Above EMA 50       :  5 pts
//   Above EMA 20       :  5 pts
//
// HOW TO USE:
//   1. Apply on ANY NSE chart (NIFTY index recommended)
//   2. Table updates at session close with latest CPR widths
//   3. 3x (triple narrow) = strongest setup — verify on chart
//   4. Always confirm with price action before trading
// ============================================================

//@version=5
indicator("CPR Scanner - NSE Nifty50", shorttitle="CPR-NSE", overlay=true, max_bars_back=500)

// ============================================================
// ─── INPUTS ──────────────────────────────────────────────────
// ============================================================

grpC = "CPR Narrow Thresholds"
dThr = input.float(0.50, "Daily CPR Narrow %",   minval=0.05, maxval=2.0, step=0.05, group=grpC, tooltip="CPR width < this % of price = Narrow Daily CPR")
wThr = input.float(0.80, "Weekly CPR Narrow %",  minval=0.05, maxval=3.0, step=0.05, group=grpC, tooltip="CPR width < this % of price = Narrow Weekly CPR")
mThr = input.float(1.50, "Monthly CPR Narrow %", minval=0.05, maxval=5.0, step=0.05, group=grpC, tooltip="CPR width < this % of price = Narrow Monthly CPR")

grpE = "EMA Settings"
ema20L  = input.int(20,  "EMA Short",  minval=5,   group=grpE)
ema50L  = input.int(50,  "EMA Mid",    minval=20,  group=grpE)
ema200L = input.int(200, "EMA Long",   minval=100, group=grpE)

grpD = "Display"
topN   = input.int(20, "Top N Stocks to Show", minval=3,  maxval=40,  group=grpD)
minScr = input.int(25, "Min Score to Display", minval=0,  maxval=120, group=grpD)

// ============================================================
// ─── CPR + EMA FUNCTION (runs on Daily bars per security) ────
// Tracks previous week / previous month OHLC using var state
// Returns: [dWidth, wWidth, mWidth, abvE20, abvE50, abvE200, price, score]
// ============================================================

cprData() =>
    // Detect period boundaries
    isNW = weekofyear != weekofyear[1] or year != year[1]
    isNM = month != month[1] or year != year[1]

    // Weekly OHLC tracker
    var float wH = na
    var float wL = na
    var float wC = na
    var float pwH = na
    var float pwL = na
    var float pwC = na

    // Monthly OHLC tracker
    var float mH = na
    var float mL = na
    var float mC = na
    var float pmH = na
    var float pmL = na
    var float pmC = na

    if isNW
        pwH := wH
        pwL := wL
        pwC := wC
        wH  := high
        wL  := low
        wC  := close
    else
        wH := na(wH) ? high : math.max(wH, high)
        wL := na(wL) ? low  : math.min(wL, low)
        wC := close

    if isNM
        pmH := mH
        pmL := mL
        pmC := mC
        mH  := high
        mL  := low
        mC  := close
    else
        mH := na(mH) ? high : math.max(mH, high)
        mL := na(mL) ? low  : math.min(mL, low)
        mC := close

    // ── Daily CPR (previous day's H, L, C) ──
    dH   = high[1]
    dL   = low[1]
    dC   = close[1]
    dPvt = (dH + dL + dC) / 3
    dBC  = (dH + dL) / 2
    dTC  = (dPvt - dBC) + dPvt
    dW   = dPvt > 0 ? math.abs(dTC - dBC) / dPvt * 100.0 : 999.0

    // ── Weekly CPR (previous week's H, L, C) ──
    wPvt = not na(pwH) and not na(pwL) ? (pwH + pwL + pwC) / 3 : na
    wBC  = not na(pwH) and not na(pwL) ? (pwH + pwL) / 2        : na
    wTC  = not na(wPvt) and not na(wBC) ? (wPvt - wBC) + wPvt   : na
    wW   = not na(wPvt) and wPvt > 0 ? math.abs(wTC - wBC) / wPvt * 100.0 : 999.0

    // ── Monthly CPR (previous month's H, L, C) ──
    mPvt = not na(pmH) and not na(pmL) ? (pmH + pmL + pmC) / 3 : na
    mBC  = not na(pmH) and not na(pmL) ? (pmH + pmL) / 2        : na
    mTC  = not na(mPvt) and not na(mBC) ? (mPvt - mBC) + mPvt   : na
    mW   = not na(mPvt) and mPvt > 0 ? math.abs(mTC - mBC) / mPvt * 100.0 : 999.0

    // ── EMA status ──
    a20  = close > ta.ema(close, ema20L)
    a50  = close > ta.ema(close, ema50L)
    a200 = close > ta.ema(close, ema200L)

    // ── Composite score (max 120) ──
    sc = (dW <= dThr ? 25 : 0) + (wW <= wThr ? 35 : 0) + (mW <= mThr ? 40 : 0) +
         (a200 ? 10 : 0) + (a50 ? 5 : 0) + (a20 ? 5 : 0)

    [dW, wW, mW, a20, a50, a200, close, sc]

// ============================================================
// ─── 40 NIFTY50 STOCKS ───────────────────────────────────────
// ============================================================

[d01,w01,m01,a20_01,a50_01,a200_01,p01,sc01] = request.security("NSE:RELIANCE",   "D", cprData())
[d02,w02,m02,a20_02,a50_02,a200_02,p02,sc02] = request.security("NSE:TCS",        "D", cprData())
[d03,w03,m03,a20_03,a50_03,a200_03,p03,sc03] = request.security("NSE:HDFCBANK",   "D", cprData())
[d04,w04,m04,a20_04,a50_04,a200_04,p04,sc04] = request.security("NSE:INFY",       "D", cprData())
[d05,w05,m05,a20_05,a50_05,a200_05,p05,sc05] = request.security("NSE:ICICIBANK",  "D", cprData())
[d06,w06,m06,a20_06,a50_06,a200_06,p06,sc06] = request.security("NSE:HINDUNILVR", "D", cprData())
[d07,w07,m07,a20_07,a50_07,a200_07,p07,sc07] = request.security("NSE:ITC",        "D", cprData())
[d08,w08,m08,a20_08,a50_08,a200_08,p08,sc08] = request.security("NSE:SBIN",       "D", cprData())
[d09,w09,m09,a20_09,a50_09,a200_09,p09,sc09] = request.security("NSE:BHARTIARTL", "D", cprData())
[d10,w10,m10,a20_10,a50_10,a200_10,p10,sc10] = request.security("NSE:KOTAKBANK",  "D", cprData())
[d11,w11,m11,a20_11,a50_11,a200_11,p11,sc11] = request.security("NSE:LT",         "D", cprData())
[d12,w12,m12,a20_12,a50_12,a200_12,p12,sc12] = request.security("NSE:AXISBANK",   "D", cprData())
[d13,w13,m13,a20_13,a50_13,a200_13,p13,sc13] = request.security("NSE:WIPRO",      "D", cprData())
[d14,w14,m14,a20_14,a50_14,a200_14,p14,sc14] = request.security("NSE:ASIANPAINT", "D", cprData())
[d15,w15,m15,a20_15,a50_15,a200_15,p15,sc15] = request.security("NSE:MARUTI",     "D", cprData())
[d16,w16,m16,a20_16,a50_16,a200_16,p16,sc16] = request.security("NSE:HCLTECH",    "D", cprData())
[d17,w17,m17,a20_17,a50_17,a200_17,p17,sc17] = request.security("NSE:NESTLEIND",  "D", cprData())
[d18,w18,m18,a20_18,a50_18,a200_18,p18,sc18] = request.security("NSE:TITAN",      "D", cprData())
[d19,w19,m19,a20_19,a50_19,a200_19,p19,sc19] = request.security("NSE:BAJFINANCE", "D", cprData())
[d20,w20,m20,a20_20,a50_20,a200_20,p20,sc20] = request.security("NSE:BAJAJFINSV", "D", cprData())
[d21,w21,m21,a20_21,a50_21,a200_21,p21,sc21] = request.security("NSE:POWERGRID",  "D", cprData())
[d22,w22,m22,a20_22,a50_22,a200_22,p22,sc22] = request.security("NSE:NTPC",       "D", cprData())
[d23,w23,m23,a20_23,a50_23,a200_23,p23,sc23] = request.security("NSE:TECHM",      "D", cprData())
[d24,w24,m24,a20_24,a50_24,a200_24,p24,sc24] = request.security("NSE:SUNPHARMA",  "D", cprData())
[d25,w25,m25,a20_25,a50_25,a200_25,p25,sc25] = request.security("NSE:ULTRACEMCO", "D", cprData())
[d26,w26,m26,a20_26,a50_26,a200_26,p26,sc26] = request.security("NSE:TATASTEEL",  "D", cprData())
[d27,w27,m27,a20_27,a50_27,a200_27,p27,sc27] = request.security("NSE:JSWSTEEL",   "D", cprData())
[d28,w28,m28,a20_28,a50_28,a200_28,p28,sc28] = request.security("NSE:GRASIM",     "D", cprData())
[d29,w29,m29,a20_29,a50_29,a200_29,p29,sc29] = request.security("NSE:DRREDDY",    "D", cprData())
[d30,w30,m30,a20_30,a50_30,a200_30,p30,sc30] = request.security("NSE:DIVISLAB",   "D", cprData())
[d31,w31,m31,a20_31,a50_31,a200_31,p31,sc31] = request.security("NSE:CIPLA",      "D", cprData())
[d32,w32,m32,a20_32,a50_32,a200_32,p32,sc32] = request.security("NSE:EICHERMOT",  "D", cprData())
[d33,w33,m33,a20_33,a50_33,a200_33,p33,sc33] = request.security("NSE:HEROMOTOCO", "D", cprData())
[d34,w34,m34,a20_34,a50_34,a200_34,p34,sc34] = request.security("NSE:COALINDIA",  "D", cprData())
[d35,w35,m35,a20_35,a50_35,a200_35,p35,sc35] = request.security("NSE:ONGC",       "D", cprData())
[d36,w36,m36,a20_36,a50_36,a200_36,p36,sc36] = request.security("NSE:TATAMOTORS", "D", cprData())
[d37,w37,m37,a20_37,a50_37,a200_37,p37,sc37] = request.security("NSE:INDUSINDBK", "D", cprData())
[d38,w38,m38,a20_38,a50_38,a200_38,p38,sc38] = request.security("NSE:BPCL",       "D", cprData())
[d39,w39,m39,a20_39,a50_39,a200_39,p39,sc39] = request.security("NSE:ADANIPORTS", "D", cprData())
[d40,w40,m40,a20_40,a50_40,a200_40,p40,sc40] = request.security("NSE:M_M",        "D", cprData())

// ============================================================
// ─── TABLE ───────────────────────────────────────────────────
// ============================================================

var table tbl = table.new(position.top_right, 10, 43,
     bgcolor=color.new(color.black, 5),
     border_color=color.new(color.gray, 40), border_width=1,
     frame_color=color.gray, frame_width=1)

if barstate.islast
    scArr = array.from(
         float(sc01),float(sc02),float(sc03),float(sc04),float(sc05),
         float(sc06),float(sc07),float(sc08),float(sc09),float(sc10),
         float(sc11),float(sc12),float(sc13),float(sc14),float(sc15),
         float(sc16),float(sc17),float(sc18),float(sc19),float(sc20),
         float(sc21),float(sc22),float(sc23),float(sc24),float(sc25),
         float(sc26),float(sc27),float(sc28),float(sc29),float(sc30),
         float(sc31),float(sc32),float(sc33),float(sc34),float(sc35),
         float(sc36),float(sc37),float(sc38),float(sc39),float(sc40))

    nmArr = array.from(
         "RELIANCE","TCS","HDFCBANK","INFY","ICICIBANK",
         "HINDUNILVR","ITC","SBIN","BHARTIARTL","KOTAKBANK",
         "LT","AXISBANK","WIPRO","ASIANPAINT","MARUTI",
         "HCLTECH","NESTLEIND","TITAN","BAJFINANCE","BAJAJFINSV",
         "POWERGRID","NTPC","TECHM","SUNPHARMA","ULTRACEMCO",
         "TATASTEEL","JSWSTEEL","GRASIM","DRREDDY","DIVISLAB",
         "CIPLA","EICHERMOT","HEROMOTO","COALINDIA","ONGC",
         "TATAMOTORS","INDUSINDBK","BPCL","ADANIPORTS","M&M")

    dArr = array.from(d01,d02,d03,d04,d05,d06,d07,d08,d09,d10,
                      d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
                      d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,
                      d31,d32,d33,d34,d35,d36,d37,d38,d39,d40)

    wArr = array.from(w01,w02,w03,w04,w05,w06,w07,w08,w09,w10,
                      w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,
                      w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,
                      w31,w32,w33,w34,w35,w36,w37,w38,w39,w40)

    mArr = array.from(m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,
                      m11,m12,m13,m14,m15,m16,m17,m18,m19,m20,
                      m21,m22,m23,m24,m25,m26,m27,m28,m29,m30,
                      m31,m32,m33,m34,m35,m36,m37,m38,m39,m40)

    e20A = array.from(a20_01,a20_02,a20_03,a20_04,a20_05,a20_06,a20_07,a20_08,a20_09,a20_10,
                      a20_11,a20_12,a20_13,a20_14,a20_15,a20_16,a20_17,a20_18,a20_19,a20_20,
                      a20_21,a20_22,a20_23,a20_24,a20_25,a20_26,a20_27,a20_28,a20_29,a20_30,
                      a20_31,a20_32,a20_33,a20_34,a20_35,a20_36,a20_37,a20_38,a20_39,a20_40)

    e50A = array.from(a50_01,a50_02,a50_03,a50_04,a50_05,a50_06,a50_07,a50_08,a50_09,a50_10,
                      a50_11,a50_12,a50_13,a50_14,a50_15,a50_16,a50_17,a50_18,a50_19,a50_20,
                      a50_21,a50_22,a50_23,a50_24,a50_25,a50_26,a50_27,a50_28,a50_29,a50_30,
                      a50_31,a50_32,a50_33,a50_34,a50_35,a50_36,a50_37,a50_38,a50_39,a50_40)

    e200A = array.from(a200_01,a200_02,a200_03,a200_04,a200_05,a200_06,a200_07,a200_08,a200_09,a200_10,
                       a200_11,a200_12,a200_13,a200_14,a200_15,a200_16,a200_17,a200_18,a200_19,a200_20,
                       a200_21,a200_22,a200_23,a200_24,a200_25,a200_26,a200_27,a200_28,a200_29,a200_30,
                       a200_31,a200_32,a200_33,a200_34,a200_35,a200_36,a200_37,a200_38,a200_39,a200_40)

    prArr = array.from(p01,p02,p03,p04,p05,p06,p07,p08,p09,p10,
                       p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,
                       p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,
                       p31,p32,p33,p34,p35,p36,p37,p38,p39,p40)

    idxArr = array.sort_indices(scArr, order.descending)

    tripleN = 0
    doubleN = 0
    for k = 0 to 39
        cnt = (array.get(dArr, k) <= dThr ? 1 : 0) +
              (array.get(wArr, k) <= wThr ? 1 : 0) +
              (array.get(mArr, k) <= mThr ? 1 : 0)
        if cnt == 3
            tripleN += 1
        else if cnt == 2
            doubleN += 1

    hBg = color.new(color.navy, 5)
    table.cell(tbl, 0, 0, "CPR SCANNER - NIFTY50",   text_color=color.white,  bgcolor=hBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 0, "D<" + str.tostring(dThr) + " W<" + str.tostring(wThr) + " M<" + str.tostring(mThr) + "%", text_color=color.yellow, bgcolor=hBg, text_size=size.tiny)
    table.cell(tbl, 2, 0, "3x:" + str.tostring(tripleN) + "  2x:" + str.tostring(doubleN), text_color=color.lime, bgcolor=hBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 3, 0, "", bgcolor=hBg)
    table.cell(tbl, 4, 0, "", bgcolor=hBg)
    table.cell(tbl, 5, 0, "", bgcolor=hBg)
    table.cell(tbl, 6, 0, "", bgcolor=hBg)
    table.cell(tbl, 7, 0, "", bgcolor=hBg)
    table.cell(tbl, 8, 0, "", bgcolor=hBg)
    table.cell(tbl, 9, 0, "", bgcolor=hBg)

    cBg = color.new(color.navy, 30)
    table.cell(tbl, 0, 1, "#",      text_color=color.gray,  bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 1, "Stock",  text_color=color.white, bgcolor=cBg, text_size=size.small)
    table.cell(tbl, 2, 1, "D-CPR%", text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 3, 1, "W-CPR%", text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 4, 1, "M-CPR%", text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 5, 1, "Narrow", text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 6, 1, "E200",   text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 7, 1, "E50",    text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 8, 1, "E20",    text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 9, 1, "Price",  text_color=color.white, bgcolor=cBg, text_size=size.small, text_halign=text.align_right)

    rowsFilled = 0
    for i = 0 to 39
        if rowsFilled >= topN
            break
        idx  = array.get(idxArr, i)
        sc   = array.get(scArr,  idx)
        if sc < minScr
            break
        row  = rowsFilled + 2
        nm   = array.get(nmArr,  idx)
        dv   = array.get(dArr,   idx)
        wv   = array.get(wArr,   idx)
        mv   = array.get(mArr,   idx)
        a20v = array.get(e20A,   idx)
        a50v = array.get(e50A,   idx)
        a200v= array.get(e200A,  idx)
        prv  = array.get(prArr,  idx)

        dNar = dv <= dThr
        wNar = wv <= wThr
        mNar = mv <= mThr
        nCnt = (dNar ? 1 : 0) + (wNar ? 1 : 0) + (mNar ? 1 : 0)

        rowBg = nCnt == 3 ? color.new(color.teal, 72) : nCnt == 2 ? color.new(color.navy, 50) : color.new(color.black, 20)
        nClr  = nCnt == 3 ? color.lime : nCnt == 2 ? color.yellow : color.orange
        nmClr = nCnt == 3 ? color.lime : nCnt == 2 ? color.white  : color.gray
        nStr  = nCnt == 3 ? "3x NAR" : nCnt == 2 ? "2x" : nCnt == 1 ? "1x" : "-"

        dClr  = dNar ? color.lime : color.new(color.gray, 30)
        wClr  = wNar ? color.lime : color.new(color.gray, 30)
        mClr  = mNar ? color.lime : color.new(color.gray, 30)

        table.cell(tbl, 0, row, str.tostring(rowsFilled + 1),    text_color=color.gray,   bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, row, nm,                               text_color=nmClr,        bgcolor=rowBg, text_size=size.small)
        table.cell(tbl, 2, row, str.tostring(math.round(dv, 3)),  text_color=dClr,         bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 3, row, str.tostring(math.round(wv, 3)),  text_color=wClr,         bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 4, row, str.tostring(math.round(mv, 3)),  text_color=mClr,         bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 5, row, nStr,                              text_color=nClr,         bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 6, row, a200v ? "ABV" : "BLW",            text_color=a200v ? color.lime : color.red,    bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 7, row, a50v  ? "ABV" : "BLW",            text_color=a50v  ? color.lime : color.orange, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 8, row, a20v  ? "ABV" : "BLW",            text_color=a20v  ? color.lime : color.orange, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 9, row, str.tostring(math.round(prv)),     text_color=color.yellow,                      bgcolor=rowBg, text_size=size.small, text_halign=text.align_right)

        rowsFilled += 1

// ============================================================
// ─── ALERTS ──────────────────────────────────────────────────
// ============================================================

topScore = math.max(
     sc01,sc02,sc03,sc04,sc05,sc06,sc07,sc08,sc09,sc10,
     sc11,sc12,sc13,sc14,sc15,sc16,sc17,sc18,sc19,sc20,
     sc21,sc22,sc23,sc24,sc25,sc26,sc27,sc28,sc29,sc30,
     sc31,sc32,sc33,sc34,sc35,sc36,sc37,sc38,sc39,sc40)

alertcondition(topScore >= 100 and topScore[1] < 100,
     title="Triple Narrow CPR — Nifty50",
     message="TRIPLE NARROW CPR detected in Nifty50 (D+W+M all narrow). Open scanner!")
alertcondition(topScore >= 60 and topScore[1] < 60,
     title="Double Narrow CPR — Nifty50",
     message="Double Narrow CPR found in Nifty50. Open scanner to identify stock.")
````
