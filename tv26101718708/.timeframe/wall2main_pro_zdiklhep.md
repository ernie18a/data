# Wall2Main Pro

- url: https://www.tradingview.com/script/ZDiKLHep-Wall2Main-Pro/
- type: indicator
- pine_id: PUB;9ee6d22483e5480395ad7b3a19bc8ced
- version: 1.0

## Description

MTF Squeeze Master

A consolidated multi-timeframe dashboard for John Carter's squeeze strategy. Replaces multiple overlapping MTF squeeze indicators with a single efficient script.

What it shows (5 rows × 5 timeframes — 1H, 4H, D, W, M by default):

SQZ — Squeeze compression level (High / Mid / Low / None) per TF
BARS — Number of bars since the squeeze fired, with a built-in "rolled over" exit based on John Carter's classic 2-consecutive-decline rule. Green while momentum is expanding, yellow when momentum starts decelerating (warning), "—" when momentum has fully turned over
MOM — Momentum direction (Bullish / Bearish / Weakening)
STK — Moving-average stack alignment (Stacked Up / Stacked Down / Unstacked)
10X — DMI/ADX trend strength (Up / Down / No trend if ADX below threshold)
Why use it:

When SQZ fires AND MOM/STK/10X all agree on direction, you have full multi-timeframe alignment — Carter's highest-conviction setup. The BARS counter tells you how mature the move is so you can time exits before momentum rolls over.

## Source Code

````pine
//@version=6
// MTF Squeeze Master — single dashboard replacing on-chart MTF squeeze indicators.
// Every parameter is exposed in the Settings panel — no code edits needed after install.
//
// Rows: SQZ • BARS • MOM • STK • 10X
// Default TFs: 1H, 4H, D, W, M
//
// One request.security call per TF returns a tuple consumed by every row.
indicator("MTF Squeeze Master", shorttitle="SQZ Master", overlay=true)

// =========================================================================
// 1) TIMEFRAMES — pick which TFs to show
// =========================================================================
g_tf = "① Timeframes"

tf1 = input.timeframe("60",  "TF 1", group=g_tf, tooltip="The smallest timeframe column. Use blank input to clear, or values like 5, 15, 60, 240, D, W, M.")
tf2 = input.timeframe("240", "TF 2", group=g_tf)
tf3 = input.timeframe("D",   "TF 3", group=g_tf)
tf4 = input.timeframe("W",   "TF 4", group=g_tf)
tf5 = input.timeframe("M",   "TF 5", group=g_tf, tooltip="The largest timeframe column.")

hideLower = input.bool(true, "Hide TFs below current chart TF", group=g_tf, tooltip="When ON, a TF column is hidden if its period is shorter than the chart's period. Useful when viewing a daily chart and you don't care about 1H or 4H rows.")

// =========================================================================
// 2) ROWS — which signals to show
// =========================================================================
g_rows = "② Rows To Show"

show_sqz  = input.bool(true, "SQZ — squeeze compression level", group=g_rows)
show_bars = input.bool(true, "BARS — bars since fire (with rolled-over exit)", group=g_rows)
show_mom  = input.bool(true, "MOM — momentum direction", group=g_rows)
show_stk  = input.bool(true, "STK — moving-average stack alignment", group=g_rows)
show_10x  = input.bool(true, "10X — DMI/ADX trend strength", group=g_rows)

// =========================================================================
// 3) TABLE POSITION & STYLE
// =========================================================================
g_tbl = "③ Table Position & Style"

yPos = input.string("middle", "Vertical position",   options=["top","middle","bottom"], group=g_tbl, inline="pos")
xPos = input.string("right",  "Horizontal position", options=["left","center","right"], group=g_tbl, inline="pos")

textSize  = input.string(size.tiny, "Text size",  options=[size.tiny,size.small,size.normal,size.large], group=g_tbl, inline="txt")
textColor = input.color(color.white, "Text color", group=g_tbl, inline="txt")

borderW   = input.int(1, "Border width", minval=0, maxval=4, group=g_tbl, inline="bdr")
borderC   = input.color(color.new(color.gray, 50), "Border color", group=g_tbl, inline="bdr")

headerBg  = input.color(color.new(color.gray, 0), "Header background (row labels)", group=g_tbl)
idleBg    = input.color(color.new(color.gray, 80), "Idle cell background (BARS row when nothing fired)", group=g_tbl)

// =========================================================================
// 4) SQUEEZE SETTINGS
// =========================================================================
g_sqz = "④ Squeeze Calculation"

length  = input.int(20,    "TTM length",          group=g_sqz, tooltip="Lookback for Bollinger Bands, Keltner Channels, and the momentum oscillator. John Carter's default is 20.")
BB_mult = input.float(2.0, "Bollinger STD multiplier", group=g_sqz)
KC_high = input.float(1.0, "Keltner #1 (Narrow — High compression)", group=g_sqz)
KC_mid  = input.float(1.5, "Keltner #2 (Mid compression)",            group=g_sqz)
KC_low  = input.float(2.0, "Keltner #3 (Wide — Low compression)",     group=g_sqz)

// =========================================================================
// 5) BARS COUNTER SETTINGS
// =========================================================================
g_bars = "⑤ Bars-Since-Fire Behavior"

exitRule = input.string("Carter classic (2 declines)", "Exit rule for live counter",
     options=["Carter classic (2 declines)", "Strict (1 decline)", "Sign flip only"],
     group=g_bars,
     tooltip="When to consider the momentum 'turned over' and reset BARS to '—'.\n\n• Carter classic: 2 consecutive declining momentum bars (John Carter's rule).\n• Strict: exit on the first declining bar (more conservative).\n• Sign flip only: only reset when momentum crosses zero (gives most runway, often too late).")

// =========================================================================
// 6) MOMENTUM ROW
// =========================================================================
g_mom = "⑥ Momentum Row"
// (uses the shared signal colors below)

// =========================================================================
// 7) EMA STACK ROW
// =========================================================================
g_ma = "⑦ MA Stack"

ma_type = input.string("EMA", "MA type", options=["SMA","EMA","DEMA"], group=g_ma)
ma_src  = input.source(close, "Price source",                            group=g_ma)
ma_l1   = input.int(8,  "MA length 1", minval=1, group=g_ma, inline="ml1")
ma_l2   = input.int(21, "MA length 2", minval=1, group=g_ma, inline="ml1")
ma_l3   = input.int(34, "MA length 3", minval=1, group=g_ma, inline="ml2")
ma_l4   = input.int(55, "MA length 4 (0 = off)", minval=0, group=g_ma, inline="ml2")
ma_l5   = input.int(89, "MA length 5 (0 = off)", minval=0, group=g_ma, tooltip="Set length to 0 to disable the 4th or 5th MA. Stack is considered bullish only if all enabled MAs are in descending-length order (shortest > next > … > longest).")

// =========================================================================
// 8) 10X (DMI/ADX) ROW
// =========================================================================
g_10  = "⑧ 10X (DMI/ADX)"

dmi_len = input.int(14, "DMI length",    minval=1, group=g_10, inline="x0")
adx_t   = input.int(20, "ADX threshold", minval=1, group=g_10, inline="x0", tooltip="When ADX < threshold, the 10X cell turns Neutral (no trend). Carter uses 20.")

// =========================================================================
// 9) COLORS — Squeeze levels
// =========================================================================
g_csqz = "⑨ Colors — Squeeze Levels"

NoSqz_C   = input.color(color.green,  "No squeeze",         group=g_csqz)
LowSqz_C  = input.color(color.black,  "Low compression",    group=g_csqz)
MidSqz_C  = input.color(color.red,    "Mid compression",    group=g_csqz)
HighSqz_C = input.color(color.orange, "High compression",   group=g_csqz)

// =========================================================================
// 10) COLORS — Signal cells (shared by MOM / STK / 10X)
// =========================================================================
g_csig = "⑩ Colors — Signal Cells (MOM / STK / 10X)"

bull_C = input.color(color.green,  "Bullish",       group=g_csig, inline="sig1")
bear_C = input.color(color.red,    "Bearish",       group=g_csig, inline="sig1")
neut_C = input.color(color.yellow, "Neutral / Weak",group=g_csig, inline="sig1")

// =========================================================================
// 11) COLORS — BARS row
// =========================================================================
g_cbars = "⑪ Colors — BARS Row"

barsLong_C  = input.color(color.lime,   "Live long (expanding)",   group=g_cbars)
barsShort_C = input.color(color.red,    "Live short (expanding)",  group=g_cbars)
barsWarn_C  = input.color(color.yellow, "Warning (about to roll)", group=g_cbars, tooltip="Background color shown on the first declining momentum bar — momentum is decelerating but exit rule hasn't triggered yet.")

// =========================================================================
// HELPERS
// =========================================================================
fnMA(src, len) =>
    ma_type == "EMA" ? ta.ema(src, len) :
     ma_type == "SMA" ? ta.sma(src, len) :
     len > 0          ? 2 * ta.ema(src, len) - ta.ema(ta.ema(src, len), len) : na

// =========================================================================
// MASTER CALC — runs per TF security context
// =========================================================================
calc() =>
    // ----- Squeeze -----
    basis = ta.sma(close, length)
    dev   = BB_mult * ta.stdev(close, length)
    bbU   = basis + dev
    bbL   = basis - dev
    devKC = ta.sma(ta.tr, length)
    NoSq  = bbL <  basis - devKC * KC_low  or bbU >  basis + devKC * KC_low
    LoSq  = bbL >= basis - devKC * KC_low  or bbU <= basis + devKC * KC_low
    MdSq  = bbL >= basis - devKC * KC_mid  or bbU <= basis + devKC * KC_mid
    HiSq  = bbL >= basis - devKC * KC_high or bbU <= basis + devKC * KC_high
    sqClr = HiSq ? HighSqz_C : MdSq ? MidSqz_C : LoSq ? LowSqz_C : NoSqz_C

    // ----- Momentum -----
    mom = ta.linreg(close - math.avg(math.avg(ta.highest(high, length), ta.lowest(low, length)), ta.sma(close, length)), length, 0)
    momWeakening = (mom > 0 and mom < nz(mom[1])) or (mom < 0 and mom > nz(mom[1]))
    momClr = momWeakening ? neut_C : mom > 0 ? bull_C : mom < 0 ? bear_C : neut_C

    // ----- Bars-since-fire -----
    fired       = NoSq and (LoSq[1] or MdSq[1] or HiSq[1])
    momFalling1 = mom < nz(mom[1])
    momRising1  = mom > nz(mom[1])
    momFalling2 = momFalling1 and nz(mom[1]) < nz(mom[2])
    momRising2  = momRising1  and nz(mom[1]) > nz(mom[2])

    longRollover  = exitRule == "Strict (1 decline)" ? momFalling1 :
                     exitRule == "Sign flip only"     ? mom <= 0    :
                     momFalling2  // Carter classic
    shortRollover = exitRule == "Strict (1 decline)" ? momRising1  :
                     exitRule == "Sign flip only"     ? mom >= 0    :
                     momRising2

    var int barsDir = 0
    var int sign    = 0   // 1 long alive, -1 short alive, 0 idle
    if fired
        sign    := mom > 0 ? 1 : mom < 0 ? -1 : 0
        barsDir := sign != 0 ? 1 : 0
    else if sign == 1
        if mom > 0 and not longRollover
            barsDir := barsDir + 1
        else
            sign    := 0
            barsDir := 0
    else if sign == -1
        if mom < 0 and not shortRollover
            barsDir := barsDir + 1
        else
            sign    := 0
            barsDir := 0
    warning = sign == 1 ? momFalling1 : sign == -1 ? momRising1 : false

    // ----- 10X (DMI + ADX) -----
    up_d   = ta.change(high)
    dn_d   = -ta.change(low)
    plusDM = na(up_d) ? na : (up_d > dn_d and up_d > 0 ? up_d : 0.0)
    minuDM = na(dn_d) ? na : (dn_d > up_d and dn_d > 0 ? dn_d : 0.0)
    trur   = ta.rma(ta.tr, dmi_len)
    plus   = fixnan(100 * ta.rma(plusDM, dmi_len) / trur)
    minus  = fixnan(100 * ta.rma(minuDM, dmi_len) / trur)
    sumv   = plus + minus
    adx    = 100 * ta.rma(math.abs(plus - minus) / (sumv == 0 ? 1 : sumv), dmi_len)
    dmiClr = adx < adx_t ? neut_C : plus > minus ? bull_C : bear_C

    // ----- Stack MA -----
    a1 = fnMA(ma_src, ma_l1)
    a2 = fnMA(ma_src, ma_l2)
    a3 = fnMA(ma_src, ma_l3)
    a4 = ma_l4 > 0 ? fnMA(ma_src, ma_l4) : na
    a5 = ma_l5 > 0 ? fnMA(ma_src, ma_l5) : na
    upT = a1 > a2 and a2 > a3 and (a3 > a4 or ma_l4 == 0) and (a4 > a5 or ma_l4 == 0 or ma_l5 == 0)
    dnT = (a5 > a4 or ma_l4 == 0 or ma_l5 == 0) and (a4 > a3 or ma_l4 == 0) and a3 > a2 and a2 > a1
    maClr = upT ? bull_C : dnT ? bear_C : neut_C

    [sqClr, barsDir, sign, warning, momClr, maClr, dmiClr]

// =========================================================================
// 5 SECURITY CALLS — one tuple per TF
// =========================================================================
[s1_, b1_, d1_, w1_, m1_, k1_, x1_] = request.security(syminfo.tickerid, tf1, calc(), lookahead=barmerge.lookahead_off)
[s2_, b2_, d2_, w2_, m2_, k2_, x2_] = request.security(syminfo.tickerid, tf2, calc(), lookahead=barmerge.lookahead_off)
[s3_, b3_, d3_, w3_, m3_, k3_, x3_] = request.security(syminfo.tickerid, tf3, calc(), lookahead=barmerge.lookahead_off)
[s4_, b4_, d4_, w4_, m4_, k4_, x4_] = request.security(syminfo.tickerid, tf4, calc(), lookahead=barmerge.lookahead_off)
[s5_, b5_, d5_, w5_, m5_, k5_, x5_] = request.security(syminfo.tickerid, tf5, calc(), lookahead=barmerge.lookahead_off)

// =========================================================================
// TABLE BUILD
// =========================================================================
var table T = table.new(yPos + "_" + xPos, 6, 6, border_width=borderW, border_color=borderC)

if barstate.islast
    table.clear(T, 0, 0, 5, 5)
    curSecs = timeframe.in_seconds()

    tfs    = array.from(tf1, tf2, tf3, tf4, tf5)
    sCols  = array.from(s1_, s2_, s3_, s4_, s5_)
    bs     = array.from(b1_, b2_, b3_, b4_, b5_)
    dirs   = array.from(d1_, d2_, d3_, d4_, d5_)
    warns  = array.from(w1_, w2_, w3_, w4_, w5_)
    mCols  = array.from(m1_, m2_, m3_, m4_, m5_)
    kCols  = array.from(k1_, k2_, k3_, k4_, k5_)
    xCols  = array.from(x1_, x2_, x3_, x4_, x5_)

    rowMap = array.new<int>(0)
    rowIdx = 0
    if show_sqz
        table.cell(T, 0, rowIdx, "SQZ",  text_color=textColor, bgcolor=headerBg, text_size=textSize)
        array.push(rowMap, 0)
        rowIdx := rowIdx + 1
    if show_bars
        table.cell(T, 0, rowIdx, "BARS", text_color=textColor, bgcolor=headerBg, text_size=textSize)
        array.push(rowMap, 1)
        rowIdx := rowIdx + 1
    if show_mom
        table.cell(T, 0, rowIdx, "MOM",  text_color=textColor, bgcolor=headerBg, text_size=textSize)
        array.push(rowMap, 2)
        rowIdx := rowIdx + 1
    if show_stk
        table.cell(T, 0, rowIdx, "STK",  text_color=textColor, bgcolor=headerBg, text_size=textSize)
        array.push(rowMap, 3)
        rowIdx := rowIdx + 1
    if show_10x
        table.cell(T, 0, rowIdx, "10X",  text_color=textColor, bgcolor=headerBg, text_size=textSize)
        array.push(rowMap, 4)
        rowIdx := rowIdx + 1

    col = 1
    for i = 0 to 4
        tf     = array.get(tfs, i)
        tfSecs = timeframe.in_seconds(tf)
        if not hideLower or tfSecs >= curSecs
            for ri = 0 to array.size(rowMap) - 1
                kind = array.get(rowMap, ri)
                if kind == 0
                    table.cell(T, col, ri, tf, text_color=textColor, bgcolor=array.get(sCols, i), text_size=textSize)
                else if kind == 1
                    b  = array.get(bs,    i)
                    dg = array.get(dirs,  i)
                    wn = array.get(warns, i)
                    bg = dg == 0 ? idleBg
                         : wn   ? barsWarn_C
                         : dg == 1 ? barsLong_C
                         : barsShort_C
                    txt = b > 0 ? str.tostring(b) : "—"
                    table.cell(T, col, ri, txt, text_color=dg == 0 ? color.silver : color.black, bgcolor=bg, text_size=textSize)
                else if kind == 2
                    table.cell(T, col, ri, tf, text_color=textColor, bgcolor=array.get(mCols, i), text_size=textSize)
                else if kind == 3
                    table.cell(T, col, ri, tf, text_color=textColor, bgcolor=array.get(kCols, i), text_size=textSize)
                else if kind == 4
                    table.cell(T, col, ri, tf, text_color=textColor, bgcolor=array.get(xCols, i), text_size=textSize)
            col := col + 1

// =========================================================================
// ALERTS — long fires on each TF (set via "Add alert on…" in TradingView)
// =========================================================================
alertcondition(d1_ == 1 and b1_ == 1, "TF1 Long Fire", "Squeeze fired LONG on TF1")
alertcondition(d2_ == 1 and b2_ == 1, "TF2 Long Fire", "Squeeze fired LONG on TF2")
alertcondition(d3_ == 1 and b3_ == 1, "TF3 Long Fire", "Squeeze fired LONG on TF3")
alertcondition(d4_ == 1 and b4_ == 1, "TF4 Long Fire", "Squeeze fired LONG on TF4")
alertcondition(d5_ == 1 and b5_ == 1, "TF5 Long Fire", "Squeeze fired LONG on TF5")
````
