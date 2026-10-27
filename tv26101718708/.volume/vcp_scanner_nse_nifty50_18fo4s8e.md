# VCP Scanner - NSE Nifty50

- url: https://www.tradingview.com/script/18fo4s8E-VCP-Scanner-NSE-Nifty50/
- type: indicator
- pine_id: PUB;3bae4b2a15fe4a939e0e9ec3e101c779
- version: 1.0

## Description

HOW TO USE:
1. Apply on ANY NSE chart (e.g. NIFTY index)
2. Scan Timeframe: D (daily) recommended for VCP
3. Table shows top stocks ranked by VCP Score (0-100)
4. Score >= 70: strong VCP candidate -> check on chart  
5. Score >= 50: developing setup -> watch list

VCP SCORE BREAKDOWN (max 100):
----------------------------------------
Stage 2 uptrend  : 30 pts  (EMA20 > EMA50 > EMA150 > EMA200)
Volume dry-up    : 20 pts  (recent vol < threshold% of avg)
ATR contracting  : 15 pts  (short-term ATR% < long-term ATR%)
Near 52w High    : 15 pts  (within maxBH% of yearly high)
Price tightness  : 10 pts  (5-bar range < 40% of 20-bar range)
Prior uptrend    : 10 pts  (close >= minPG% above 52-bar low)

## Source Code

````pine
// ============================================================
// VCP SCANNER — NSE India (Nifty 50)
// Scans 40 Nifty50 stocks and ranks by VCP readiness score
// ============================================================
// HOW TO USE:
//   1. Apply on ANY NSE chart (e.g. NIFTY index)
//   2. Scan Timeframe: D (daily) recommended for VCP
//   3. Table shows top stocks ranked by VCP Score (0-100)
//   4. Score >= 70: strong VCP candidate -> check on chart
//   5. Score >= 50: developing setup -> watch list
//
// VCP SCORE BREAKDOWN (max 100):
//   Stage 2 uptrend  : 30 pts  (EMA20 > EMA50 > EMA150 > EMA200)
//   Volume dry-up    : 20 pts  (recent vol < threshold% of avg)
//   ATR contracting  : 15 pts  (short-term ATR% < long-term ATR%)
//   Near 52w High    : 15 pts  (within maxBH% of yearly high)
//   Price tightness  : 10 pts  (5-bar range < 40% of 20-bar range)
//   Prior uptrend    : 10 pts  (close >= minPG% above 52-bar low)
// ============================================================

//@version=5
indicator("VCP Scanner - NSE Nifty50", shorttitle="VCP-NSE", overlay=true, max_bars_back=500)

// ============================================================
// SETTINGS
// ============================================================

grpS    = "Scanner Settings"
scanTF  = input.timeframe("D",    "Scan Timeframe (D=Daily recommended)", group=grpS)
maxBH   = input.float   (25.0,   "Max % Below 52w High",   minval=5,  maxval=60,  group=grpS)
minPG   = input.float   (25.0,   "Min Prior Gain %",        minval=5,  maxval=200, group=grpS)
volDP   = input.float   (70.0,   "Volume Dry-up % of Avg",  minval=20, maxval=95,  group=grpS)
topN    = input.int     (20,     "Show Top N Results",      minval=3,  maxval=40,  group=grpS)
minDisp = input.int     (40,     "Min Score to Display",    minval=0,  maxval=100, group=grpS)

// ============================================================
// VCP SCORING FUNCTION
// Runs inside request.security -> uses the target symbol's OHLCV
// Returns: [score, stage2, nearHigh, volDry, price]
// ============================================================

vcpCalc() =>
    e20  = ta.ema(close, 20)
    e50  = ta.ema(close, 50)
    e150 = ta.ema(close, 150)
    e200 = ta.ema(close, 200)
    s2   = close > e20 and e20 > e50 and e50 > e150 and e150 > e200

    h52  = ta.highest(high, 252)
    nh   = not na(h52) and h52 > 0 ? (h52 - close) / h52 * 100.0 <= maxBH : false

    lo52 = ta.lowest(low, 52)
    pg   = not na(lo52) and lo52 > 0 ? (close - lo52) / lo52 * 100.0 >= minPG : false

    vSMA = ta.sma(volume, 20)
    vRec = ta.sma(volume, 10)
    vd   = not na(vSMA) and vSMA > 0 ? vRec < vSMA * (volDP / 100.0) : false

    ap   = close > 0 ? ta.atr(10) / close * 100.0 : 0.0
    ac   = ta.sma(ap, 8) < ta.sma(ap, 40) * 0.90

    r5   = close > 0 ? (ta.highest(high, 5)  - ta.lowest(low, 5))  / close * 100.0 : 100.0
    r20  = close > 0 ? (ta.highest(high, 20) - ta.lowest(low, 20)) / close * 100.0 : 100.0
    rt   = r20 > 0 ? r5 < r20 * 0.40 : false

    sc   = na(close) ? 0 : (s2 ? 30 : 0) + (nh ? 15 : 0) + (pg ? 10 : 0) + (vd ? 20 : 0) + (ac ? 15 : 0) + (rt ? 10 : 0)
    [sc, s2, nh, vd, close]

// ============================================================
// NIFTY 50 STOCK DATA (40 stocks, 1 request each)
// ============================================================

[s01,b01,n01,d01,p01] = request.security("NSE:RELIANCE",   scanTF, vcpCalc())
[s02,b02,n02,d02,p02] = request.security("NSE:TCS",        scanTF, vcpCalc())
[s03,b03,n03,d03,p03] = request.security("NSE:HDFCBANK",   scanTF, vcpCalc())
[s04,b04,n04,d04,p04] = request.security("NSE:INFY",       scanTF, vcpCalc())
[s05,b05,n05,d05,p05] = request.security("NSE:ICICIBANK",  scanTF, vcpCalc())
[s06,b06,n06,d06,p06] = request.security("NSE:HINDUNILVR", scanTF, vcpCalc())
[s07,b07,n07,d07,p07] = request.security("NSE:ITC",        scanTF, vcpCalc())
[s08,b08,n08,d08,p08] = request.security("NSE:SBIN",       scanTF, vcpCalc())
[s09,b09,n09,d09,p09] = request.security("NSE:BHARTIARTL", scanTF, vcpCalc())
[s10,b10,n10,d10,p10] = request.security("NSE:KOTAKBANK",  scanTF, vcpCalc())
[s11,b11,n11,d11,p11] = request.security("NSE:LT",         scanTF, vcpCalc())
[s12,b12,n12,d12,p12] = request.security("NSE:AXISBANK",   scanTF, vcpCalc())
[s13,b13,n13,d13,p13] = request.security("NSE:WIPRO",      scanTF, vcpCalc())
[s14,b14,n14,d14,p14] = request.security("NSE:ASIANPAINT", scanTF, vcpCalc())
[s15,b15,n15,d15,p15] = request.security("NSE:MARUTI",     scanTF, vcpCalc())
[s16,b16,n16,d16,p16] = request.security("NSE:HCLTECH",    scanTF, vcpCalc())
[s17,b17,n17,d17,p17] = request.security("NSE:NESTLEIND",  scanTF, vcpCalc())
[s18,b18,n18,d18,p18] = request.security("NSE:TITAN",      scanTF, vcpCalc())
[s19,b19,n19,d19,p19] = request.security("NSE:BAJFINANCE", scanTF, vcpCalc())
[s20,b20,n20,d20,p20] = request.security("NSE:BAJAJFINSV", scanTF, vcpCalc())
[s21,b21,n21,d21,p21] = request.security("NSE:POWERGRID",  scanTF, vcpCalc())
[s22,b22,n22,d22,p22] = request.security("NSE:NTPC",       scanTF, vcpCalc())
[s23,b23,n23,d23,p23] = request.security("NSE:TECHM",      scanTF, vcpCalc())
[s24,b24,n24,d24,p24] = request.security("NSE:SUNPHARMA",  scanTF, vcpCalc())
[s25,b25,n25,d25,p25] = request.security("NSE:ULTRACEMCO", scanTF, vcpCalc())
[s26,b26,n26,d26,p26] = request.security("NSE:TATASTEEL",  scanTF, vcpCalc())
[s27,b27,n27,d27,p27] = request.security("NSE:JSWSTEEL",   scanTF, vcpCalc())
[s28,b28,n28,d28,p28] = request.security("NSE:GRASIM",     scanTF, vcpCalc())
[s29,b29,n29,d29,p29] = request.security("NSE:DRREDDY",    scanTF, vcpCalc())
[s30,b30,n30,d30,p30] = request.security("NSE:DIVISLAB",   scanTF, vcpCalc())
[s31,b31,n31,d31,p31] = request.security("NSE:CIPLA",      scanTF, vcpCalc())
[s32,b32,n32,d32,p32] = request.security("NSE:EICHERMOT",  scanTF, vcpCalc())
[s33,b33,n33,d33,p33] = request.security("NSE:HEROMOTOCO", scanTF, vcpCalc())
[s34,b34,n34,d34,p34] = request.security("NSE:COALINDIA",  scanTF, vcpCalc())
[s35,b35,n35,d35,p35] = request.security("NSE:ONGC",       scanTF, vcpCalc())
[s36,b36,n36,d36,p36] = request.security("NSE:TATAMOTORS", scanTF, vcpCalc())
[s37,b37,n37,d37,p37] = request.security("NSE:INDUSINDBK", scanTF, vcpCalc())
[s38,b38,n38,d38,p38] = request.security("NSE:BPCL",       scanTF, vcpCalc())
[s39,b39,n39,d39,p39] = request.security("NSE:ADANIPORTS", scanTF, vcpCalc())
[s40,b40,n40,d40,p40] = request.security("NSE:M_M",        scanTF, vcpCalc())

// ============================================================
// SCANNER TABLE
// ============================================================

var table tbl = table.new(position.top_right, 7, 43, bgcolor=color.new(color.black, 5), border_color=color.new(color.gray, 40), border_width=1, frame_color=color.gray, frame_width=1)

if barstate.islast
    scArr = array.from(
         float(s01), float(s02), float(s03), float(s04), float(s05),
         float(s06), float(s07), float(s08), float(s09), float(s10),
         float(s11), float(s12), float(s13), float(s14), float(s15),
         float(s16), float(s17), float(s18), float(s19), float(s20),
         float(s21), float(s22), float(s23), float(s24), float(s25),
         float(s26), float(s27), float(s28), float(s29), float(s30),
         float(s31), float(s32), float(s33), float(s34), float(s35),
         float(s36), float(s37), float(s38), float(s39), float(s40))

    nmArr = array.from(
         "RELIANCE","TCS","HDFCBANK","INFY","ICICIBANK",
         "HINDUNILVR","ITC","SBIN","BHARTIARTL","KOTAKBANK",
         "LT","AXISBANK","WIPRO","ASIANPAINT","MARUTI",
         "HCLTECH","NESTLEIND","TITAN","BAJFINANCE","BAJAJFINSV",
         "POWERGRID","NTPC","TECHM","SUNPHARMA","ULTRACEMCO",
         "TATASTEEL","JSWSTEEL","GRASIM","DRREDDY","DIVISLAB",
         "CIPLA","EICHERMOT","HEROMOTO","COALINDIA","ONGC",
         "TATAMOTORS","INDUSINDBK","BPCL","ADANIPORTS","M&M")

    s2Arr = array.from(
         b01,b02,b03,b04,b05,b06,b07,b08,b09,b10,
         b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,
         b21,b22,b23,b24,b25,b26,b27,b28,b29,b30,
         b31,b32,b33,b34,b35,b36,b37,b38,b39,b40)

    nhArr = array.from(
         n01,n02,n03,n04,n05,n06,n07,n08,n09,n10,
         n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,
         n21,n22,n23,n24,n25,n26,n27,n28,n29,n30,
         n31,n32,n33,n34,n35,n36,n37,n38,n39,n40)

    vdArr = array.from(
         d01,d02,d03,d04,d05,d06,d07,d08,d09,d10,
         d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
         d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,
         d31,d32,d33,d34,d35,d36,d37,d38,d39,d40)

    prArr = array.from(
         p01,p02,p03,p04,p05,p06,p07,p08,p09,p10,
         p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,
         p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,
         p31,p32,p33,p34,p35,p36,p37,p38,p39,p40)

    idxArr = array.sort_indices(scArr, order.descending)

    totalAbove = 0
    for k = 0 to 39
        if array.get(scArr, k) >= minDisp
            totalAbove += 1

    hdrBg = color.new(color.navy, 5)
    colBg = color.new(color.navy, 30)

    table.cell(tbl, 0, 0, "VCP SCANNER - NIFTY50",              text_color=color.white,  bgcolor=hdrBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 0, "TF: " + scanTF,                      text_color=color.yellow, bgcolor=hdrBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 2, 0, str.tostring(totalAbove) + " stocks >= " + str.tostring(minDisp), text_color=color.lime, bgcolor=hdrBg, text_size=size.small)
    table.cell(tbl, 3, 0, "", bgcolor=hdrBg, text_size=size.small)
    table.cell(tbl, 4, 0, "", bgcolor=hdrBg, text_size=size.small)
    table.cell(tbl, 5, 0, "", bgcolor=hdrBg, text_size=size.small)
    table.cell(tbl, 6, 0, "", bgcolor=hdrBg, text_size=size.small)

    table.cell(tbl, 0, 1, "#",      text_color=color.gray,  bgcolor=colBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 1, "Stock",  text_color=color.white, bgcolor=colBg, text_size=size.small)
    table.cell(tbl, 2, 1, "Score",  text_color=color.white, bgcolor=colBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 3, 1, "S2",     text_color=color.white, bgcolor=colBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 4, 1, "NearHi", text_color=color.white, bgcolor=colBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 5, 1, "VolDry", text_color=color.white, bgcolor=colBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 6, 1, "Price",  text_color=color.white, bgcolor=colBg, text_size=size.small, text_halign=text.align_right)

    rowsFilled = 0
    for i = 0 to 39
        if rowsFilled >= topN
            break
        idx = array.get(idxArr, i)
        sc  = array.get(scArr,  idx)
        if sc < minDisp
            break
        row = rowsFilled + 2
        nm  = array.get(nmArr,  idx)
        s2v = array.get(s2Arr,  idx)
        nhv = array.get(nhArr,  idx)
        vdv = array.get(vdArr,  idx)
        prv = array.get(prArr,  idx)

        scInt   = int(sc)
        rowBg   = scInt >= 70 ? color.new(color.teal,  80) : scInt >= 50 ? color.new(color.navy, 60) : color.new(color.black, 20)
        scColor = scInt >= 70 ? color.lime : scInt >= 50 ? color.yellow : color.orange
        nmColor = scInt >= 70 ? color.lime : scInt >= 50 ? color.white  : color.gray

        table.cell(tbl, 0, row, str.tostring(rowsFilled + 1), text_color=color.gray,    bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, row, nm,                            text_color=nmColor,       bgcolor=rowBg, text_size=size.small)
        table.cell(tbl, 2, row, str.tostring(scInt) + "/100",  text_color=scColor,       bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 3, row, s2v ? "YES" : "-",             text_color=s2v ? color.lime : color.red,  bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 4, row, nhv ? "YES" : "-",             text_color=nhv ? color.lime : color.gray, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 5, row, vdv ? "YES" : "-",             text_color=vdv ? color.lime : color.gray, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 6, row, str.tostring(math.round(prv)), text_color=color.yellow,  bgcolor=rowBg, text_size=size.small, text_halign=text.align_right)

        rowsFilled += 1

// ============================================================
// ALERT — when any stock crosses 70
// ============================================================

topScore = math.max(
     s01,s02,s03,s04,s05,s06,s07,s08,s09,s10,
     s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,
     s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,
     s31,s32,s33,s34,s35,s36,s37,s38,s39,s40)

alertcondition(topScore >= 70 and topScore[1] < 70, title="VCP Nifty50 New Setup", message="VCP score 70+ detected in Nifty50 — open scanner to find the stock")

// END
````
