# [BB] TA

- url: https://www.tradingview.com/script/v47VxoF4/
- type: indicator
- pine_id: PUB;761eb79250a94b66b938c414ca44c5e5
- version: 1.0

## Description

보조지표

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © bbtanman
//@version=6

indicator("[BB] TA", overlay=false, explicit_plot_zorder=true)

// 패턴 1 — 3선 정렬
// 빨강 > 흰색 AND 노랑 > 흰색  →  강한 상승 정렬
// 빨강 < 흰색 AND 노랑 < 흰색  →  강한 하락 정렬
// 빨강 ≠ 노랑 방향 (흰색 기준) →  전환 신호
// 패턴 2 — 빨강-노랑 차이가 순수 이격

// red - yellow = (norm_ang - norm_zls) / 2
// 빨강 > 노랑 : 모멘텀이 가격보다 앞서 달림 → 가격 추격 예상
// 노랑 > 빨강 : 가격 위치가 모멘텀보다 높음 → 모멘텀 둔화 경고

src     = input(hlc3, "Source")
len200  = input.int(200, "EMA 200", group="MA")

w_factor    = input.float(5.0, "가격 가중치",   group="Price Weight", minval=0.0, maxval=10.0, step=0.1)

env_pct     = input.float(10.0, "엔벨로프 %",   group="Envelope", minval=1, step=1)
env_smooth  = input.int(10,     "밴드 스무딩",   group="Envelope", minval=1, maxval=50)
wang_smooth = input.int(30,     "중심선 스무딩", group="Envelope", minval=1, maxval=100)
show_break  = input.bool(true,  "이탈 배경색",   group="Envelope")

div_thresh  = input.float(0.35, "이격도 기준 (°)", group="Signal", minval=0.01)
show_align  = input.bool(true,  "정렬 배경색",     group="Signal")

zls_norm_len  = input.int(200,   "정규화 기간",        group="ZLS Norm", minval=20)
show_zls_norm = input.bool(true, "ZLS200 블렌드 표시", group="ZLS Norm")

adx_len  = input.int(14,    "ADX 기간", group="ADX", minval=1)
show_adx = input.bool(true, "ADX 표시", group="ADX")

// ────────────────────────────────────────────────────
// ── 계산 — ZLS / TAMA
// ────────────────────────────────────────────────────

zl(s, l) =>
    ls = ta.linreg(s, l, 0)
    ls + (ls - ta.linreg(ls, l, 0))

ang_deg(ma) =>
    roc = (ma - ma[1]) / ma[1]
    ta.sma(math.atan(roc) * (180.0 / math.pi), 199) * 10

ma200    = ta.ema(close, len200)
zls200   = zl(src, len200)
ang200   = ang_deg(ma200)
agzls200 = ang_deg(zls200)

// ── 가격 가중 기준선
price_dev = (close - ma200) / ma200
w_ang200  = ang200 * (1.0 + price_dev * w_factor)

// ── 엔벨로프
env_delta = math.abs(w_ang200) * env_pct / 100.0
env_upper = env_smooth > 1 ? ta.ema(w_ang200 + env_delta, env_smooth) : w_ang200 + env_delta
env_lower = env_smooth > 1 ? ta.ema(w_ang200 - env_delta, env_smooth) : w_ang200 - env_delta

env_break_up   = agzls200 > env_upper
env_break_down = agzls200 < env_lower

// ── 이격도 신호
div_bear = agzls200 - w_ang200 >= div_thresh
div_bull = w_ang200 - agzls200 >= div_thresh

// ── 정규화 (-1~1)
ang_hi   = ta.highest(agzls200, zls_norm_len)
ang_lo   = ta.lowest(agzls200,  zls_norm_len)
ang_rng  = ang_hi - ang_lo
norm_ang = ang_rng != 0 ? (agzls200 - ang_lo) / ang_rng * 2 - 1 : 0

zls_hi   = ta.highest(zls200, zls_norm_len)
zls_lo   = ta.lowest(zls200,  zls_norm_len)
zls_rng  = zls_hi - zls_lo
norm_zls = zls_rng != 0 ? (zls200 - zls_lo) / zls_rng * 2 - 1 : 0

norm_wang   = ang_rng != 0 ? (w_ang200 - ang_lo) / ang_rng * 2 - 1 : 0
smooth_wang = wang_smooth > 1 ? ta.ema(norm_wang, wang_smooth) : norm_wang
avgzls      = math.avg(norm_ang, norm_zls)

// ── 3선 정렬
bull_align = norm_ang > smooth_wang and avgzls > smooth_wang
bear_align = norm_ang < smooth_wang and avgzls < smooth_wang

// ────────────────────────────────────────────────────
// ── 계산 — ADX 정규화
// ────────────────────────────────────────────────────

tr_val   = math.max(math.max(high - low,
           math.abs(high - nz(close[1]))),
           math.abs(low  - nz(close[1])))
dm_plus  = high - nz(high[1]) > nz(low[1]) - low ? math.max(high - nz(high[1]), 0) : 0
dm_minus = nz(low[1]) - low > high - nz(high[1]) ? math.max(nz(low[1]) - low, 0)  : 0

var float st_range  = 0.0
var float sdm_plus  = 0.0
var float sdm_minus = 0.0
st_range  := nz(st_range[1])  - nz(st_range[1])  / adx_len + tr_val
sdm_plus  := nz(sdm_plus[1])  - nz(sdm_plus[1])  / adx_len + dm_plus
sdm_minus := nz(sdm_minus[1]) - nz(sdm_minus[1]) / adx_len + dm_minus

di_plus  = st_range != 0 ? sdm_plus  / st_range * 100 : 0
di_minus = st_range != 0 ? sdm_minus / st_range * 100 : 0

// (DI+ - DI-) / (DI+ + DI-) → 방향 포함 강도 (-1~1)
dx_dir   = (di_plus + di_minus) != 0 ? (di_plus - di_minus) / (di_plus + di_minus) : 0
norm_adx = ta.ema(dx_dir, adx_len)

// ────────────────────────────────────────────────────
// ── PLOTS
// ────────────────────────────────────────────────────

hline(0, color=#CCCCCC50, linestyle=hline.style_dashed)

// ── ADX 막대 (먼저 — 선들이 위에 렌더링됨)
adx_col = norm_adx >= 0 ?  #689F3850 : #1976D250

plot(show_adx ? norm_adx : na, "ADX 정규화", adx_col, style=plot.style_area)
plot(show_adx ? norm_adx : na, "ADX 정규화", adx_col, style=plot.style_columns)


zls_col = avgzls > norm_ang ?  #FFFF0070 : #C6282870

z0 = plot(norm_ang,                    "ZLS200 각도", #FF0000,      1)
// plot(smooth_wang,                 "기준선",      #FFFFFF,      2)
z1 = plot(show_zls_norm ? avgzls : na, "ZLS 블렌드",  color.yellow, 1)
fill(z0, z1, zls_col)

plotshape(div_bear, "Bear 45°", shape.triangledown, location.top,    color=#01579B, size=size.tiny)
plotshape(div_bull, "Bull 45°", shape.triangleup,   location.bottom, color=#D50000, size=size.tiny)
````
