# Gold Levels Dashboard

- url: https://www.tradingview.com/script/IYOl64hI-Gold-Levels-Dashboard/
- type: indicator
- pine_id: PUB;864ac4487bae46f2a548a799b611e853
- version: 1.0

## Description

Dashboard for full setup entry SL TP support 

Key levels: R3, R2, R1, Pivot, S1, S2, S3, MAJR (Major Support), SAR (Parabolic SAR)
Trade setup: Entry, SL, TP1, TP2, TP3
Multi-timeframe bias: Daily, 4H, 1H, 15M
Indicator scorecard: RSI, MACD, ADX, etc.
Pivot points (calculated from previous day's OHLC)
Parabolic SAR
RSI, MACD, ADX for bias determination
EMA for trend bias per timeframe
Table display with colored cells like the image

## Source Code

````pine
//@version=6
indicator("Gold Levels Dashboard", shorttitle="GLD·Levels", overlay=true, max_lines_count=20, max_labels_count=10)

// ══ INPUTS ══════════════════════════════════════════════════════
i_pos      = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left"])
i_lines    = input.bool(true, "Show Level Lines on Chart")
i_fsize    = input.string("normal", "Font Size", options=["tiny","small","normal","large","huge"])
i_atr_len  = input.int(14, "ATR Length", minval=1)
i_rsi_len  = input.int(14, "RSI Length", minval=1)
i_ema_fast = input.int(20, "EMA Fast",   minval=1)
i_ema_slow = input.int(50, "EMA Slow",   minval=1)

// ══ FONT SIZE ═══════════════════════════════════════════════════
fs_h = i_fsize == "tiny" ? size.tiny : i_fsize == "small" ? size.small : i_fsize == "normal" ? size.normal : i_fsize == "large" ? size.large : size.huge
fs_b = i_fsize == "tiny" ? size.tiny : i_fsize == "small" ? size.tiny  : i_fsize == "normal" ? size.small  : i_fsize == "large" ? size.normal : size.large
fs_s = i_fsize == "tiny" ? size.tiny : i_fsize == "small" ? size.tiny  : i_fsize == "normal" ? size.tiny   : i_fsize == "large" ? size.small  : size.normal

// ══ DAILY PIVOTS ════════════════════════════════════════════════
dh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
dl  = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
dc  = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
pvt = (dh + dl + dc) / 3.0
R1  = 2.0 * pvt - dl
R2  = pvt + (dh - dl)
R3  = dh  + 2.0 * (pvt - dl)
S1  = 2.0 * pvt - dh
S2  = pvt - (dh - dl)
S3  = dl  - 2.0 * (dh - pvt)

// ══ WEEKLY MAJOR ════════════════════════════════════════════════
wh   = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
wl   = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)
wc   = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)
wpvt = (wh + wl + wc) / 3.0
MAJR = wl - 2.0 * (wh - wpvt)

// ══ SAR / ATR ═══════════════════════════════════════════════════
SAR_v = ta.sar(0.02, 0.02, 0.2)
ATR_v = ta.atr(i_atr_len)

// ══ TRADE SETUPS ════════════════════════════════════════════════
sh_e   = R1
sh_sl  = R2
sh_t1  = S1
sh_t2  = S2
sh_t3  = S3
sh_rsk = math.max(sh_sl - sh_e, syminfo.mintick)
sh_rr1 = (sh_e - sh_t1) / sh_rsk
sh_rr2 = (sh_e - sh_t2) / sh_rsk
sh_rr3 = (sh_e - sh_t3) / sh_rsk
lg_e   = S2
lg_sl  = S3 - ATR_v * 0.3
lg_t1  = pvt
lg_t2  = R1
lg_t3  = R2
lg_rsk = math.max(lg_e - lg_sl, syminfo.mintick)
lg_rr1 = (lg_t1 - lg_e) / lg_rsk
lg_rr2 = (lg_t2 - lg_e) / lg_rsk
lg_rr3 = (lg_t3 - lg_e) / lg_rsk

// ══ INDICATORS ══════════════════════════════════════════════════
rsi_v = ta.rsi(close, i_rsi_len)
[macd_l, macd_s, macd_h] = ta.macd(close, 12, 26, 9)
[dp, dm, adx_v] = ta.dmi(14, 14)
ema_fast = ta.ema(close, i_ema_fast)
ema_slow = ta.ema(close, i_ema_slow)
ema200   = ta.ema(close, 200)

rsi_lbl  = rsi_v > 70 ? "Overbought" : rsi_v < 30 ? "Oversold-Bounce" : rsi_v > 55 ? "Bullish" : rsi_v < 45 ? "Bearish" : "Neutral"
macd_lbl = macd_l > macd_s and macd_h > macd_h[1] ? "Bull-Rising" : macd_l > macd_s ? "Bull-Weak" : macd_l < macd_s and macd_h < macd_h[1] ? "Bear-Falling" : "Bear-Recover"
adx_lbl  = adx_v > 35 ? (dp > dm ? "Strong Up" : "Strong Down") : adx_v > 20 ? (dp > dm ? "Trending Bull" : "Trending Bear") : "Ranging/Weak"
sar_lbl  = close > SAR_v ? "Bullish" : "Bearish"
ema_lbl  = close > ema_fast and ema_fast > ema_slow ? "Bull Stack" : close < ema_fast and ema_fast < ema_slow ? "Bear Stack" : close > ema_fast ? "Price > EMA" : "Mixed"

// ══ MTF BIAS ════════════════════════════════════════════════════
f_score(c, ef, es, rsi_, macd_, sar_) =>
    sc = 0
    sc := c    > ef   ? sc + 1 : sc - 1
    sc := c    > es   ? sc + 1 : sc - 1
    sc := ef   > es   ? sc + 1 : sc - 1
    sc := rsi_ > 50   ? sc + 1 : sc - 1
    sc := macd_ > 0   ? sc + 1 : sc - 1
    sc := c    > sar_ ? sc + 1 : sc - 1
    sc

f_label(sc) => sc >= 5 ? "STRONG BULL" : sc >= 2 ? "BULL" : sc <= -5 ? "STRONG BEAR" : sc <= -2 ? "BEAR" : "NEUTRAL"

bias_bg(b)   => b == "STRONG BULL" ? color.new(#bbf7d0,0) : b == "BULL" ? color.new(#dcfce7,0) : b == "STRONG BEAR" ? color.new(#fecaca,0) : b == "BEAR" ? color.new(#fee2e2,0) : color.new(#e2e8f0,0)
bias_tc(b)   => b == "STRONG BULL" ? color.new(#14532d,0) : b == "BULL" ? color.new(#166534,0) : b == "STRONG BEAR" ? color.new(#7f1d1d,0) : b == "BEAR" ? color.new(#991b1b,0) : color.new(#334155,0)
bias_icon(b) => b == "STRONG BULL" ? "^^ " : b == "BULL" ? "^  " : b == "STRONG BEAR" ? "vv " : b == "BEAR" ? "v  " : "-  "

d_c    = request.security(syminfo.tickerid, "D",   close)
d_ef   = request.security(syminfo.tickerid, "D",   ta.ema(close, i_ema_fast))
d_es   = request.security(syminfo.tickerid, "D",   ta.ema(close, i_ema_slow))
d_rsi  = request.security(syminfo.tickerid, "D",   ta.rsi(close, i_rsi_len))
d_macd = request.security(syminfo.tickerid, "D",   ta.ema(close,12) - ta.ema(close,26))
d_sar  = request.security(syminfo.tickerid, "D",   ta.sar(0.02,0.02,0.2))
d_bias = f_label(f_score(d_c, d_ef, d_es, d_rsi, d_macd, d_sar))
d_sc   = f_score(d_c, d_ef, d_es, d_rsi, d_macd, d_sar)

h4_c    = request.security(syminfo.tickerid, "240", close)
h4_ef   = request.security(syminfo.tickerid, "240", ta.ema(close, i_ema_fast))
h4_es   = request.security(syminfo.tickerid, "240", ta.ema(close, i_ema_slow))
h4_rsi  = request.security(syminfo.tickerid, "240", ta.rsi(close, i_rsi_len))
h4_macd = request.security(syminfo.tickerid, "240", ta.ema(close,12) - ta.ema(close,26))
h4_sar  = request.security(syminfo.tickerid, "240", ta.sar(0.02,0.02,0.2))
h4_bias = f_label(f_score(h4_c, h4_ef, h4_es, h4_rsi, h4_macd, h4_sar))
h4_sc   = f_score(h4_c, h4_ef, h4_es, h4_rsi, h4_macd, h4_sar)

h1_c    = request.security(syminfo.tickerid, "60",  close)
h1_ef   = request.security(syminfo.tickerid, "60",  ta.ema(close, i_ema_fast))
h1_es   = request.security(syminfo.tickerid, "60",  ta.ema(close, i_ema_slow))
h1_rsi  = request.security(syminfo.tickerid, "60",  ta.rsi(close, i_rsi_len))
h1_macd = request.security(syminfo.tickerid, "60",  ta.ema(close,12) - ta.ema(close,26))
h1_sar  = request.security(syminfo.tickerid, "60",  ta.sar(0.02,0.02,0.2))
h1_bias = f_label(f_score(h1_c, h1_ef, h1_es, h1_rsi, h1_macd, h1_sar))
h1_sc   = f_score(h1_c, h1_ef, h1_es, h1_rsi, h1_macd, h1_sar)

m15_c    = request.security(syminfo.tickerid, "15",  close)
m15_ef   = request.security(syminfo.tickerid, "15",  ta.ema(close, i_ema_fast))
m15_es   = request.security(syminfo.tickerid, "15",  ta.ema(close, i_ema_slow))
m15_rsi  = request.security(syminfo.tickerid, "15",  ta.rsi(close, i_rsi_len))
m15_macd = request.security(syminfo.tickerid, "15",  ta.ema(close,12) - ta.ema(close,26))
m15_sar  = request.security(syminfo.tickerid, "15",  ta.sar(0.02,0.02,0.2))
m15_bias = f_label(f_score(m15_c, m15_ef, m15_es, m15_rsi, m15_macd, m15_sar))
m15_sc   = f_score(m15_c, m15_ef, m15_es, m15_rsi, m15_macd, m15_sar)

// ══ COLOUR SYSTEM — light backgrounds, black text ═══════════════
// All backgrounds are very light pastels. All text is near-black.
BLK  = color.new(#0f172a, 0)   // near black — main text
DGRY = color.new(#334155, 0)   // dark grey — secondary text
MGRY = color.new(#64748b, 0)   // mid grey — dim labels

// Table chrome
BG_TABLE = color.new(#ffffff, 5)   // white table bg
BG_TITLE = color.new(#1e3a5f, 0)   // dark navy title bar — white text
BG_SEC   = color.new(#e2e8f0, 0)   // light grey section headers
BG_LKEY  = color.new(#f8fafc, 0)   // near white left key col
BG_CELL  = color.new(#ffffff, 0)   // pure white value cells

// Level tag colours (solid left-col badges)
TAG_R3  = color.new(#dc2626, 0)
TAG_R2  = color.new(#ea580c, 0)
TAG_R1  = color.new(#d97706, 0)
TAG_PV  = color.new(#1d4ed8, 0)
TAG_S1  = color.new(#16a34a, 0)
TAG_S2  = color.new(#15803d, 0)
TAG_S3  = color.new(#166534, 0)
TAG_MJ  = color.new(#475569, 0)
TAG_SAR = color.new(#7c3aed, 0)
TAG_ATR = color.new(#0369a1, 0)

// Level value cell pastels
BG_R3  = color.new(#fee2e2, 0)
BG_R2  = color.new(#ffedd5, 0)
BG_R1  = color.new(#fef9c3, 0)
BG_PV  = color.new(#dbeafe, 0)
BG_S1  = color.new(#dcfce7, 0)
BG_S2  = color.new(#bbf7d0, 0)
BG_S3  = color.new(#86efac, 0)
BG_MJ  = color.new(#e2e8f0, 0)
BG_SAR = color.new(#ede9fe, 0)
BG_ATR = color.new(#e0f2fe, 0)

// Trade setup cells
BG_SH  = color.new(#fee2e2, 0)   // short — light red
BG_LG  = color.new(#dcfce7, 0)   // long  — light green
TC_SH  = color.new(#991b1b, 0)   // short text — dark red
TC_LG  = color.new(#14532d, 0)   // long text  — dark green
TC_SHE = color.new(#7f1d1d, 0)   // entry/sl emphasis
TC_LGE = color.new(#052e16, 0)

// Indicator signal cells
BG_BULL  = color.new(#dcfce7, 0)
BG_BEAR  = color.new(#fee2e2, 0)
BG_NEUT  = color.new(#f1f5f9, 0)
TC_BULL  = color.new(#14532d, 0)
TC_BEAR  = color.new(#7f1d1d, 0)
TC_NEUT  = color.new(#334155, 0)

// ══ TABLE ═══════════════════════════════════════════════════════
tpos = switch i_pos
    "top_right"    => position.top_right
    "top_left"     => position.top_left
    "bottom_right" => position.bottom_right
    =>               position.bottom_left

var table tbl = na

if barstate.islast
    tbl := table.new(tpos, 3, 42, border_color=color.new(#cbd5e1,0), border_width=1, frame_color=color.new(#1e3a5f,0), frame_width=2, bgcolor=BG_TABLE)
    r = 0

    // ── TITLE ROW (dark background, white text — contrast anchor)
    table.cell(tbl, 0, r, "GC GOLD  DAILY DASHBOARD", bgcolor=BG_TITLE, text_color=color.new(#ffffff,0), text_size=fs_h, text_halign=text.align_left)
    table.cell(tbl, 1, r, "PRICE",   bgcolor=BG_TITLE, text_color=color.new(#93c5fd,0), text_size=fs_s)
    table.cell(tbl, 2, r, "STATUS",  bgcolor=BG_TITLE, text_color=color.new(#93c5fd,0), text_size=fs_s)
    r += 1

    // ── CURRENT PRICE
    pip_lbl = close > pvt ? "Above Pvt +" + str.tostring(math.round(close-pvt,2)) : "Below Pvt -" + str.tostring(math.round(pvt-close,2))
    cur_bg  = close > pvt ? color.new(#dbeafe,0) : color.new(#fee2e2,0)
    cur_tc  = close > pvt ? color.new(#1e3a8a,0) : color.new(#7f1d1d,0)
    table.cell(tbl, 0, r, "NOW",    bgcolor=cur_bg, text_color=cur_tc, text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(close, format.mintick), bgcolor=cur_bg, text_color=cur_tc, text_size=fs_h)
    table.cell(tbl, 2, r, pip_lbl,  bgcolor=cur_bg, text_color=cur_tc, text_size=fs_s)
    r += 1

    // ── KEY LEVELS SECTION HEADER
    table.cell(tbl, 0, r, "KEY LEVELS",  bgcolor=BG_SEC, text_color=DGRY, text_size=fs_s, text_halign=text.align_left)
    table.cell(tbl, 1, r, "LEVEL",       bgcolor=BG_SEC, text_color=MGRY, text_size=fs_s)
    table.cell(tbl, 2, r, "DESCRIPTION", bgcolor=BG_SEC, text_color=MGRY, text_size=fs_s)
    r += 1

    // SAR
    table.cell(tbl, 0, r, "SAR",  bgcolor=TAG_SAR, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(SAR_v,format.mintick), bgcolor=BG_SAR, text_color=color.new(#4c1d95,0), text_size=fs_b)
    table.cell(tbl, 2, r, close < SAR_v ? "Bearish - below SAR" : "Bullish - above SAR", bgcolor=BG_SAR, text_color=DGRY, text_size=fs_s)
    r += 1

    // R3
    table.cell(tbl, 0, r, "R3",   bgcolor=TAG_R3, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(R3,format.mintick), bgcolor=BG_R3, text_color=color.new(#7f1d1d,0), text_size=fs_b)
    table.cell(tbl, 2, r, "Strong resistance / SAR zone",  bgcolor=BG_R3, text_color=DGRY, text_size=fs_s)
    r += 1

    // R2
    table.cell(tbl, 0, r, "R2",   bgcolor=TAG_R2, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(R2,format.mintick), bgcolor=BG_R2, text_color=color.new(#7c2d12,0), text_size=fs_b)
    table.cell(tbl, 2, r, "Resistance / SL for shorts",    bgcolor=BG_R2, text_color=DGRY, text_size=fs_s)
    r += 1

    // R1
    table.cell(tbl, 0, r, "R1",   bgcolor=TAG_R1, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(R1,format.mintick), bgcolor=BG_R1, text_color=color.new(#713f12,0), text_size=fs_b)
    table.cell(tbl, 2, r, "First resistance / SHORT entry", bgcolor=BG_R1, text_color=DGRY, text_size=fs_s)
    r += 1

    // PIVOT
    table.cell(tbl, 0, r, "PIVOT", bgcolor=TAG_PV, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(pvt,format.mintick), bgcolor=BG_PV, text_color=color.new(#1e3a8a,0), text_size=fs_h)
    table.cell(tbl, 2, r, "Daily pivot - line in the sand", bgcolor=BG_PV, text_color=DGRY, text_size=fs_s)
    r += 1

    // S1
    table.cell(tbl, 0, r, "S1",   bgcolor=TAG_S1, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(S1,format.mintick), bgcolor=BG_S1, text_color=color.new(#14532d,0), text_size=fs_b)
    table.cell(tbl, 2, r, "First support / TP1 shorts",    bgcolor=BG_S1, text_color=DGRY, text_size=fs_s)
    r += 1

    // S2
    table.cell(tbl, 0, r, "S2",   bgcolor=TAG_S2, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(S2,format.mintick), bgcolor=BG_S2, text_color=color.new(#14532d,0), text_size=fs_b)
    table.cell(tbl, 2, r, "Key support / LONG bounce",     bgcolor=BG_S2, text_color=DGRY, text_size=fs_s)
    r += 1

    // S3
    table.cell(tbl, 0, r, "S3",   bgcolor=TAG_S3, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(S3,format.mintick), bgcolor=BG_S3, text_color=color.new(#052e16,0), text_size=fs_b)
    table.cell(tbl, 2, r, "Critical support / TP2",        bgcolor=BG_S3, text_color=DGRY, text_size=fs_s)
    r += 1

    // MAJR
    table.cell(tbl, 0, r, "MAJR", bgcolor=TAG_MJ, text_color=color.new(#ffffff,0), text_size=fs_b)
    table.cell(tbl, 1, r, str.tostring(MAJR,format.mintick), bgcolor=BG_MJ, text_color=color.new(#1e293b,0), text_size=fs_b)
    table.cell(tbl, 2, r, "Major structural support / TP3",  bgcolor=BG_MJ, text_color=DGRY, text_size=fs_s)
    r += 1

    // ATR
    table.cell(tbl, 0, r, "ATR(" + str.tostring(i_atr_len) + ")", bgcolor=TAG_ATR, text_color=color.new(#ffffff,0), text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(ATR_v,format.mintick), bgcolor=BG_ATR, text_color=color.new(#0c4a6e,0), text_size=fs_b)
    table.cell(tbl, 2, r, "Est. daily range",                  bgcolor=BG_ATR, text_color=DGRY, text_size=fs_s)
    r += 1

    // ── TRADE SETUPS SECTION
    table.cell(tbl, 0, r, "TRADE SETUPS",    bgcolor=BG_SEC, text_color=DGRY, text_size=fs_s, text_halign=text.align_left)
    table.cell(tbl, 1, r, "SHORT (Primary)", bgcolor=color.new(#fecaca,0), text_color=TC_SH, text_size=fs_s)
    table.cell(tbl, 2, r, "LONG (Counter)",  bgcolor=color.new(#bbf7d0,0), text_color=TC_LG, text_size=fs_s)
    r += 1

    table.cell(tbl, 0, r, "Trigger",   bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, "Reject at R1",    bgcolor=BG_SH, text_color=TC_SH, text_size=fs_s)
    table.cell(tbl, 2, r, "Bounce hold S2",  bgcolor=BG_LG, text_color=TC_LG, text_size=fs_s)
    r += 1

    table.cell(tbl, 0, r, "Entry",     bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(sh_e, format.mintick),  bgcolor=BG_SH, text_color=TC_SHE, text_size=fs_h)
    table.cell(tbl, 2, r, str.tostring(lg_e, format.mintick),  bgcolor=BG_LG, text_color=TC_LGE, text_size=fs_h)
    r += 1

    table.cell(tbl, 0, r, "Stop Loss", bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(sh_sl, format.mintick), bgcolor=BG_SH, text_color=TC_SH,  text_size=fs_b)
    table.cell(tbl, 2, r, str.tostring(lg_sl, format.mintick), bgcolor=BG_LG, text_color=TC_LG,  text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "TP1 (50%)", bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(sh_t1, format.mintick) + "  S1",  bgcolor=BG_SH, text_color=TC_LG, text_size=fs_b)
    table.cell(tbl, 2, r, str.tostring(lg_t1, format.mintick) + "  Pvt", bgcolor=BG_LG, text_color=TC_LG, text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "TP2 (30%)", bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(sh_t2, format.mintick) + "  S2", bgcolor=BG_SH, text_color=TC_LG, text_size=fs_b)
    table.cell(tbl, 2, r, str.tostring(lg_t2, format.mintick) + "  R1", bgcolor=BG_LG, text_color=TC_LG, text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "TP3 (20%)", bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(sh_t3, format.mintick) + "  S3", bgcolor=BG_SH, text_color=TC_LG, text_size=fs_b)
    table.cell(tbl, 2, r, str.tostring(lg_t3, format.mintick) + "  R2", bgcolor=BG_LG, text_color=TC_LG, text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "R:R TP1/2/3", bgcolor=BG_LKEY, text_color=DGRY, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(sh_rr1,"#.#") + " / " + str.tostring(sh_rr2,"#.#") + " / " + str.tostring(sh_rr3,"#.#"), bgcolor=BG_SH, text_color=TC_SH, text_size=fs_s)
    table.cell(tbl, 2, r, str.tostring(lg_rr1,"#.#") + " / " + str.tostring(lg_rr2,"#.#") + " / " + str.tostring(lg_rr3,"#.#"), bgcolor=BG_LG, text_color=TC_LG, text_size=fs_s)
    r += 1

    // ── MTF BIAS SECTION
    table.cell(tbl, 0, r, "MTF BIAS",  bgcolor=BG_SEC, text_color=DGRY, text_size=fs_s, text_halign=text.align_left)
    table.cell(tbl, 1, r, "TIMEFRAME", bgcolor=BG_SEC, text_color=MGRY, text_size=fs_s)
    table.cell(tbl, 2, r, "SIGNAL",    bgcolor=BG_SEC, text_color=MGRY, text_size=fs_s)
    r += 1

    table.cell(tbl, 0, r, "Daily 1D",   bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, "Score: " + str.tostring(d_sc),      bgcolor=bias_bg(d_bias),   text_color=bias_tc(d_bias), text_size=fs_s)
    table.cell(tbl, 2, r, bias_icon(d_bias) + d_bias,          bgcolor=bias_bg(d_bias),   text_color=bias_tc(d_bias), text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "4 Hour 4H",  bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, "Score: " + str.tostring(h4_sc),     bgcolor=bias_bg(h4_bias),  text_color=bias_tc(h4_bias), text_size=fs_s)
    table.cell(tbl, 2, r, bias_icon(h4_bias) + h4_bias,        bgcolor=bias_bg(h4_bias),  text_color=bias_tc(h4_bias), text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "1 Hour 1H",  bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, "Score: " + str.tostring(h1_sc),     bgcolor=bias_bg(h1_bias),  text_color=bias_tc(h1_bias), text_size=fs_s)
    table.cell(tbl, 2, r, bias_icon(h1_bias) + h1_bias,        bgcolor=bias_bg(h1_bias),  text_color=bias_tc(h1_bias), text_size=fs_b)
    r += 1

    table.cell(tbl, 0, r, "15 Min 15M", bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, "Score: " + str.tostring(m15_sc),    bgcolor=bias_bg(m15_bias), text_color=bias_tc(m15_bias), text_size=fs_s)
    table.cell(tbl, 2, r, bias_icon(m15_bias) + m15_bias,      bgcolor=bias_bg(m15_bias), text_color=bias_tc(m15_bias), text_size=fs_b)
    r += 1

    // ── INDICATORS SECTION
    table.cell(tbl, 0, r, "INDICATORS", bgcolor=BG_SEC, text_color=DGRY, text_size=fs_s, text_halign=text.align_left)
    table.cell(tbl, 1, r, "VALUE",      bgcolor=BG_SEC, text_color=MGRY, text_size=fs_s)
    table.cell(tbl, 2, r, "SIGNAL",     bgcolor=BG_SEC, text_color=MGRY, text_size=fs_s)
    r += 1

    // RSI
    rsi_bg = rsi_v > 70 ? BG_BEAR : rsi_v < 30 ? color.new(#fef9c3,0) : rsi_v > 50 ? BG_BULL : BG_BEAR
    rsi_tc = rsi_v > 70 ? TC_BEAR : rsi_v < 30 ? color.new(#713f12,0) : rsi_v > 50 ? TC_BULL : TC_BEAR
    table.cell(tbl, 0, r, "RSI(" + str.tostring(i_rsi_len) + ")", bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(rsi_v,"#.#"), bgcolor=rsi_bg, text_color=rsi_tc, text_size=fs_h)
    table.cell(tbl, 2, r, rsi_lbl,                   bgcolor=rsi_bg, text_color=rsi_tc, text_size=fs_s)
    r += 1

    // MACD
    macd_bg = macd_l > macd_s ? BG_BULL : BG_BEAR
    macd_tc = macd_l > macd_s ? TC_BULL : TC_BEAR
    table.cell(tbl, 0, r, "MACD(12/26/9)", bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(macd_l,"#.##"), bgcolor=macd_bg, text_color=macd_tc, text_size=fs_b)
    table.cell(tbl, 2, r, macd_lbl,                    bgcolor=macd_bg, text_color=macd_tc, text_size=fs_s)
    r += 1

    // ADX
    adx_bg = adx_v > 25 ? (dp > dm ? BG_BULL : BG_BEAR) : BG_NEUT
    adx_tc = adx_v > 25 ? (dp > dm ? TC_BULL : TC_BEAR) : TC_NEUT
    table.cell(tbl, 0, r, "ADX(14)",  bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(adx_v,"#.#"), bgcolor=adx_bg, text_color=adx_tc, text_size=fs_b)
    table.cell(tbl, 2, r, adx_lbl,                   bgcolor=adx_bg, text_color=adx_tc, text_size=fs_s)
    r += 1

    // Parabolic SAR
    sar_bg = close > SAR_v ? BG_BULL : BG_BEAR
    sar_tc = close > SAR_v ? TC_BULL : TC_BEAR
    table.cell(tbl, 0, r, "Parab SAR", bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(SAR_v,format.mintick), bgcolor=sar_bg, text_color=sar_tc, text_size=fs_b)
    table.cell(tbl, 2, r, sar_lbl,                            bgcolor=sar_bg, text_color=sar_tc, text_size=fs_s)
    r += 1

    // EMA Stack
    ema_bg = close > ema_fast and ema_fast > ema_slow ? BG_BULL : close < ema_fast and ema_fast < ema_slow ? BG_BEAR : BG_NEUT
    ema_tc = close > ema_fast and ema_fast > ema_slow ? TC_BULL : close < ema_fast and ema_fast < ema_slow ? TC_BEAR : TC_NEUT
    table.cell(tbl, 0, r, "EMA " + str.tostring(i_ema_fast) + "/" + str.tostring(i_ema_slow), bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(ema_fast,format.mintick), bgcolor=ema_bg, text_color=ema_tc, text_size=fs_b)
    table.cell(tbl, 2, r, ema_lbl,                               bgcolor=ema_bg, text_color=ema_tc, text_size=fs_s)
    r += 1

    // EMA 200
    e200_bg  = close > ema200 ? BG_BULL : BG_BEAR
    e200_tc  = close > ema200 ? TC_BULL : TC_BEAR
    e200_lbl = close > ema200 ? "Price > EMA200 Bull" : "Price < EMA200 Bear"
    table.cell(tbl, 0, r, "EMA 200",  bgcolor=BG_LKEY, text_color=BLK, text_size=fs_s)
    table.cell(tbl, 1, r, str.tostring(ema200,format.mintick), bgcolor=e200_bg, text_color=e200_tc, text_size=fs_b)
    table.cell(tbl, 2, r, e200_lbl,                            bgcolor=e200_bg, text_color=e200_tc, text_size=fs_s)

// ══ CHART LINES ═════════════════════════════════════════════════
plot(i_lines ? R3    : na, "R3",    color.new(#dc2626,20), 1, plot.style_linebr)
plot(i_lines ? R2    : na, "R2",    color.new(#ea580c,30), 1, plot.style_linebr)
plot(i_lines ? R1    : na, "R1",    color.new(#d97706,40), 1, plot.style_linebr)
plot(i_lines ? pvt   : na, "Pivot", color.new(#1d4ed8,10), 2, plot.style_linebr)
plot(i_lines ? S1    : na, "S1",    color.new(#16a34a,40), 1, plot.style_linebr)
plot(i_lines ? S2    : na, "S2",    color.new(#15803d,30), 1, plot.style_linebr)
plot(i_lines ? S3    : na, "S3",    color.new(#166534,20), 1, plot.style_linebr)
plot(i_lines ? MAJR  : na, "MAJR",  color.new(#475569,10), 2, plot.style_linebr)
plot(i_lines ? SAR_v : na, "SAR",   color.new(#7c3aed,10), 1, plot.style_circles)
````
