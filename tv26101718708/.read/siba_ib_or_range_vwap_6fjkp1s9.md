# [SIBA] IB + OR Range + VWAP

- url: https://www.tradingview.com/script/6fjKp1s9-SIBA-IB-OR-Range-VWAP/
- type: indicator
- pine_id: PUB;798e1de806e24dd1a2451e72bc0b5486
- version: 4.0

## Description

## 🇰🇷 한글 설명

**IB + OR Range + VWAP \[로베리단\]**

초기 균형(IB)과 오프닝 레인지(OR)를 기반으로 당일 핵심 가격 구조를 시각화하는 인디케이터입니다. NQ, ES, 금, 원유 등 선물 시장의 인트라데이 트레이딩에 최적화되어 있으며, 최근 5일치 레벨을 자동으로 추적합니다.

**주요 기능**

- **IB (Initial Balance)** — 시작/종료 시간 자유 설정. High/Low/Mid 라인과 반투명 박스, ×1.5 / ×2.0 확장 레벨 표시
- **OR (Opening Range)** — IB 시작 시각 기준으로 사용자 지정 분(분 단위) 동안의 레인지. High/Low/Mid 및 확장 레벨 표시
- **히스토리** — 당일 레벨은 진하게, 과거 4일치는 날짜별로 점진적으로 투명하게 표시 (자동 롤링)
- **BO / Failed** — IB 범위 돌파(BO↑/BO↓) 및 False Breakout(Failed↑/Failed↓) 자동 감지, 차트에 마킹
- **VWAP / AVWAP** — Session / Week / Month 앵커 선택 가능. 두 가지 동시 표시 옵션 포함
- **정보 테이블** — 차트 좌하단에 IB High/Low/Mid/크기, OR High/Low/크기 실시간 표시
- **알림(Alert)** — IB BO↑/↓, Failed↑/↓ 4가지 알림 조건 내장
- **타임존** — New York / Chicago / UTC / Seoul / Tokyo 선택 지원
- **색상 전체 커스터마이즈** 가능

**권장 사용 환경**

- 마켓: NQ, ES, GC(금), SI(은), CL(원유) 등 선물 / 주식 인트라데이
- 타임프레임: 1분 ~ 15분 추천
- 기본 설정: IB 9:30–10:30 ET, OR 30분

---

## 🇺🇸 English Description

**IB + OR Range + VWAP \[로베리단\]**

A comprehensive intraday structure indicator that visualizes the Initial Balance (IB) and Opening Range (OR) with up to 5 days of rolling history. Designed for futures traders — NQ, ES, Gold, Silver, Crude Oil — and any intraday equity session.

**Features**

- **Initial Balance (IB)** — Fully configurable start/end time. Plots High, Low, Mid lines with a shaded box and optional ×1.5 / ×2.0 extension levels
- **Opening Range (OR)** — Independently configurable range duration (minutes from IB start). Plots High, Low, Mid, and extension levels with a distinct color scheme
- **5-Day Rolling History** — Today's levels displayed in full opacity; prior days fade progressively (Day 2 → Day 5) so historical context never clutters the chart
- **Breakout & Failed BO Detection** — Auto-detects IB breakouts (BO↑ / BO↓) and false breakouts (Failed↑ / Failed↓) with plotshape markers directly on the chart
- **VWAP / AVWAP** — Choose Session, Week, or Month anchor. Display VWAP only, AVWAP only, or both simultaneously
- **Info Table** — Live bottom-left dashboard showing IB High / Low / Mid / Range size and OR High / Low / Range size
- **Built-in Alerts** — Four alert conditions: IB BO↑, IB BO↓, Failed↓, Failed↑
- **Timezone Support** — New York, Chicago, UTC, Seoul, Tokyo
- **Fully Customizable Colors** — Every line, box, and label color is individually configurable

**Recommended Settings**

- Markets: NQ, ES, GC, SI, CL futures — or any intraday equity/ETF
- Timeframes: 1m – 15m
- Default: IB 9:30–10:30 ET, OR 30 min

## Source Code

````pine
//@version=6
// v2 (2026-08-27) 변경점:
//  [가독성] 박스 테두리 → 점선+투명도 입력화(기본 80), 당일 라인 투명도 입력화(기본 35) → 캔들 꼬리가 비쳐 보임
//  [가독성] 과거일(d2~d5/o2~o5) 라벨은 롤링 시 삭제 (라벨은 당일 것만 유지)
//  [버그] 5일 히스토리 롤링이 실제로는 전혀 동작하지 않던 문제 수리 (ib_start에서 d1/o1을 na로 끊어
//         전일 객체가 고아가 되고 d2~d5는 영원히 na였음 → 롤링·투명도 에이징·최고령 삭제를 ib_start로 이동)
//  [버그] IB 롤링에서 d5 라인/박스 미삭제로 객체 누수 → 수리
//  [버그] OR 롤링에서 과거 OR 박스를 현재 봉까지 늘리던 코드 제거
//  [버그] tf_mins 정수 나눗셈 → 초 단위 차트(15S 등)에서 0이 되던 문제 (60.0으로 수정)
//  [성능] ATR 라벨을 매 봉 삭제/재생성하던 것을 마지막 봉에서만 갱신, ATR 라인 연장은 박스 종료 시각까지만
//  [변경] BO 되돌림 버퍼를 가격 0.05% → ATR 배수(기본 0.05, ATR 결측 시 IB 폭 대체)로 교체

indicator("IB + OR Range + VWAP + Day Type [로베리단]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ── Settings ──────────────────────────────────────────────
grp1 = "IB / OR Time"
ib_start_hour = input.int(9,  "IB Start Hour", minval=0, maxval=23, group=grp1)
ib_start_min  = input.int(30, "IB Start Min",  minval=0, maxval=59, group=grp1)
ib_end_hour   = input.int(10, "IB End Hour",   minval=0, maxval=23, group=grp1)
ib_end_min    = input.int(30, "IB End Min",    minval=0, maxval=59, group=grp1)
or_mins       = input.int(30, "OR Length (min)", minval=5, maxval=120, group=grp1)
box_end_hour  = input.int(16, "Box Draw End Hour", minval=0, maxval=23, group=grp1)
box_end_min   = input.int(0,  "Box Draw End Min",  minval=0, maxval=59, group=grp1)
tz            = input.string("America/New_York", "Timezone",
     options=["America/New_York","America/Chicago","UTC","Asia/Seoul","Asia/Tokyo"], group=grp1)

grp2 = "IB Display"
show_ib_box = input.bool(true, "IB Box",    group=grp2)
show_mid    = input.bool(true, "IB Mid",    group=grp2)
show_ext_15 = input.bool(true, "IB ×1.5",  group=grp2)
show_ext_20 = input.bool(true, "IB ×2.0",  group=grp2)
show_labels = input.bool(true, "Labels",    group=grp2)

grp_or = "OR Display"
show_or     = input.bool(true, "OR",          group=grp_or)
show_or_mid = input.bool(true, "OR Mid",      group=grp_or)
show_or_ext = input.bool(false, "OR Extension",group=grp_or)

grp3 = "Colors"
show_box_fill = input.bool(false, "Show Box Fill (off = border only)", group=grp3)
edge_transp   = input.int(35, "Today Line Transparency (0=opaque)", minval=0, maxval=90, group=grp3)
border_transp = input.int(80, "Box Border Transparency (100=hidden)", minval=0, maxval=100, group=grp3)
col_ib_high = input.color(color.new(color.green,  0),  "IB High",      group=grp3)
col_ib_low  = input.color(color.new(color.red,    0),  "IB Low",       group=grp3)
col_ib_mid  = input.color(color.new(color.yellow, 50), "IB Mid",       group=grp3)
col_ext_15  = input.color(color.new(color.aqua,   40), "IB ×1.5",      group=grp3)
col_ext_20  = input.color(color.new(color.orange, 40), "IB ×2.0",      group=grp3)
col_box_bg  = input.color(color.new(color.blue,   90), "IB Box BG",    group=grp3)
col_or_high = input.color(color.new(#00E5FF, 0),  "OR High",      group=grp3)
col_or_low  = input.color(color.new(#FF6B6B, 0),  "OR Low",       group=grp3)
col_or_mid  = input.color(color.new(#FFD700, 60), "OR Mid",       group=grp3)
col_or_ext  = input.color(color.new(#B0BEC5, 60), "OR Extension", group=grp3)
col_or_box  = input.color(color.new(#00E5FF, 93), "OR Box BG",    group=grp3)

grp_bo = "BO / Failed"
show_bo     = input.bool(true, "BO/Failed",    group=grp_bo)
col_bo_up   = input.color(color.new(color.lime,   0), "BO↑",    group=grp_bo)
col_bo_down = input.color(color.new(color.red,    0), "BO↓",    group=grp_bo)
col_failed  = input.color(color.new(color.orange, 0), "Failed", group=grp_bo)
bo_buf_atr  = input.float(0.05, "BO Reset Buffer (ATR mult)", minval=0.0, maxval=1.0, step=0.01, group=grp_bo)

grp5 = "VWAP"
vwap_mode    = input.string("VWAP", "Type", options=["VWAP","AVWAP","Both","None"], group=grp5)
avwap_anchor = input.string("Session", "AVWAP Anchor", options=["Session","Week","Month"], group=grp5)
col_vwap  = input.color(color.new(#FF69B4, 0), "VWAP",  group=grp5)
col_avwap = input.color(color.new(#00BFFF, 0), "AVWAP", group=grp5)
lw_vwap   = input.int(2, "Line Width", minval=1, maxval=4, group=grp5)

grp_atr = "ATR Levels"
show_atr  = input.bool(true,  "Show ATR Levels", group=grp_atr)
atr_len   = input.int(14,     "ATR Length",      minval=1, maxval=50, group=grp_atr)
atr_mult1 = input.float(1.0,  "ATR ×1 Mult",    minval=0.1, maxval=10.0, step=0.1, group=grp_atr)
atr_mult2 = input.float(2.0,  "ATR ×2 Mult",    minval=0.1, maxval=10.0, step=0.1, group=grp_atr)
atr_mult3 = input.float(3.0,  "ATR ×3 Mult",    minval=0.1, maxval=10.0, step=0.1, group=grp_atr)
atr_mult4 = input.float(4.0,  "ATR ×4 Mult",    minval=0.1, maxval=10.0, step=0.1, group=grp_atr)
show_atr3 = input.bool(false, "Show ATR ×3",    group=grp_atr)
show_atr4 = input.bool(false, "Show ATR ×4",    group=grp_atr)
col_atr1  = input.color(color.new(#00FF88, 40), "ATR ×1 Color", group=grp_atr)
col_atr2  = input.color(color.new(#FF4444, 40), "ATR ×2 Color", group=grp_atr)
col_atr3  = input.color(color.new(#FFB800, 40), "ATR ×3 Color", group=grp_atr)
col_atr4  = input.color(color.new(#CC44FF, 40), "ATR ×4 Color", group=grp_atr)

grp_tbl = "Info Panel"
show_table    = input.bool(true, "Show Panel", group=grp_tbl)
table_pos_raw = input.string("Bottom Left", "Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group=grp_tbl)

grp_day = "Balance / Trend Day"
show_day_type   = input.bool(true,  "Classify Day Type", group=grp_day)
ib_atr_bal_th   = input.float(0.45, "IB/ATR ≥ this → Balance lean", minval=0.05, maxval=2.0, step=0.05, group=grp_day)
ib_atr_trend_th = input.float(0.25, "IB/ATR ≤ this → Trend lean",   minval=0.05, maxval=2.0, step=0.05, group=grp_day)
show_calibration = input.bool(false, "Show prediction accuracy row (this chart's history)", group=grp_day)

grp_va      = "Value Area (Prior Day)"
show_va     = input.bool(true,  "Show Prior-Day POC/VAH/VAL", group=grp_va)
va_use_rth  = input.bool(true,  "RTH Session Only (off = full Globex day)", group=grp_va)
va_rth_end_hour = input.int(16, "RTH Session End Hour", minval=0, maxval=23, group=grp_va)
va_rth_end_min  = input.int(55, "RTH Session End Min",  minval=0, maxval=59, group=grp_va)
va_block_tf = input.timeframe("1", "Volume Profile Block Size (finer = less smearing on big-range bars)", group=grp_va)
va_bin_mode = input.string("Auto (ATR)", "Bin Size Mode", options=["Auto (ATR)", "Manual (Price)", "Ticks (STPO-style)"], group=grp_va)
va_bin_div  = input.int(40,     "Auto: Daily ATR ÷ this = Bin Size", minval=10, maxval=200, group=grp_va)
va_bin_size = input.float(5.0,  "Manual Bin Size (price units)", minval=0.0001, step=0.5, group=grp_va)
va_bin_ticks = input.int(55,    "Bin Size in Ticks (match STPO's Ticks Per Row)", minval=1, group=grp_va)
va_pct      = input.float(70.0, "Value Area %", minval=50.0, maxval=95.0, step=1.0, group=grp_va)
col_va_poc  = input.color(color.new(color.yellow, 0), "POC Color", group=grp_va)
col_va_vah  = input.color(color.new(#00C896, 0),       "VAH Color", group=grp_va)
col_va_val  = input.color(color.new(#FF5C8A, 0),       "VAL Color", group=grp_va)

grp_sig = "Trade Signals (Entry / SL / TP)"
show_trend_sig  = input.bool(true,  "Show Trend(Breakout) Entry Signals", group=grp_sig)
show_fade_sig   = input.bool(true,  "Show Fade(Reversion) Entry Signals", group=grp_sig)
sig_sl_atr_mult = input.float(1.0,  "Trend SL: ATR multiple cap (vs opposite IB edge)", minval=0.1, step=0.1, group=grp_sig)
sig_fade_sl_mult = input.float(0.3, "Fade SL: ATR multiple buffer beyond VAH/VAL", minval=0.05, step=0.05, group=grp_sig)

// ── 매매 신호 구조체 (진입/SL/TP 라인+라벨을 한 묶음으로 관리) ──
type TradeSig
    float entry = na
    float sl    = na
    float tp    = na
    bool  active = false
    bool  is_long = true
    line  entry_ln = na
    line  sl_ln    = na
    line  tp_ln    = na
    label lbl      = na

open_signal(TradeSig sig, float entry, float sl, float tp, bool is_long, color col, string tag) =>
    line.delete(sig.entry_ln)
    line.delete(sig.sl_ln)
    line.delete(sig.tp_ln)
    label.delete(sig.lbl)
    sig.entry  := entry
    sig.sl     := sl
    sig.tp     := tp
    sig.active := true
    sig.is_long := is_long
    sig.entry_ln := line.new(bar_index, entry, bar_index, entry, color=col, style=line.style_solid, width=1)
    sig.sl_ln    := line.new(bar_index, sl,    bar_index, sl,    color=color.red,  style=line.style_dashed, width=1)
    sig.tp_ln    := line.new(bar_index, tp,    bar_index, tp,    color=color.lime, style=line.style_dashed, width=1)
    sig.lbl      := label.new(bar_index, entry, tag, style=is_long ? label.style_label_up : label.style_label_down,
         color=color.new(color.black,100), textcolor=col, size=size.small)

update_signal(TradeSig sig) =>
    if sig.active
        line.set_x2(sig.entry_ln, bar_index)
        line.set_x2(sig.sl_ln, bar_index)
        line.set_x2(sig.tp_ln, bar_index)
        if sig.is_long
            if low <= sig.sl
                sig.active := false
                label.new(bar_index, sig.sl, "SL", style=label.style_label_down, color=color.new(color.red,80),  textcolor=color.red,  size=size.tiny)
            else if high >= sig.tp
                sig.active := false
                label.new(bar_index, sig.tp, "TP", style=label.style_label_up,   color=color.new(color.lime,80), textcolor=color.lime, size=size.tiny)
        else
            if high >= sig.sl
                sig.active := false
                label.new(bar_index, sig.sl, "SL", style=label.style_label_up,   color=color.new(color.red,80),  textcolor=color.red,  size=size.tiny)
            else if low <= sig.tp
                sig.active := false
                label.new(bar_index, sig.tp, "TP", style=label.style_label_down, color=color.new(color.lime,80), textcolor=color.lime, size=size.tiny)

var TradeSig sig_trend_long  = TradeSig.new()
var TradeSig sig_trend_short = TradeSig.new()
var TradeSig sig_fade_long   = TradeSig.new()
var TradeSig sig_fade_short  = TradeSig.new()

// ── 시간 ─────────────────────────────────────────────────
cur_mins = hour(time, tz) * 60 + minute(time, tz)
ib_s     = ib_start_hour * 60 + ib_start_min
ib_e     = ib_end_hour   * 60 + ib_end_min
or_e     = ib_s + or_mins
tf_mins  = timeframe.in_seconds() / 60.0  // current timeframe in minutes (float: 초 단위 차트에서 0이 되지 않도록)

// 봉이 IB 시작 시각을 포함하는지 체크 (모든 타임프레임 호환)
bar_end_mins = cur_mins + tf_mins
in_ib    = cur_mins < ib_e  and bar_end_mins > ib_s
in_or    = cur_mins < or_e  and bar_end_mins > ib_s
ib_start = cur_mins <= ib_s and bar_end_mins > ib_s and (cur_mins[1] + tf_mins <= ib_s or cur_mins[1] > cur_mins)

// 박스/라인을 뉴욕시간 기준 box_end 시각까지만 연장 (당일 세션 내에서만)
box_end_mins  = box_end_hour * 60 + box_end_min
in_box_window = cur_mins >= ib_s and bar_end_mins <= box_end_mins

// Value Area 누적 구간: RTH 모드면 ib_s~va_rth_end, 아니면 항상 true(다음 ib_start까지 풀세션)
va_rth_end_mins = va_rth_end_hour * 60 + va_rth_end_min
in_va_window    = not va_use_rth or (cur_mins >= ib_s and bar_end_mins <= va_rth_end_mins)

// ── VWAP ─────────────────────────────────────────────────
use_vwap  = vwap_mode == "VWAP"  or vwap_mode == "Both"
use_avwap = vwap_mode == "AVWAP" or vwap_mode == "Both"
is_new_week  = dayofweek(time, tz) == dayofweek.monday and dayofweek(time[1], tz) != dayofweek.monday
is_new_month = month(time, tz) != month(time[1], tz)
avwap_reset  = avwap_anchor == "Week" ? is_new_week : avwap_anchor == "Month" ? is_new_month : ib_start
var float acp = 0.
var float acv = 0.
if avwap_reset
    acp := hlc3 * volume
    acv := volume
else
    acp += hlc3 * volume
    acv += volume
avwap_val = acv > 0 ? acp / acv : na

// VWAP 라벨 (선 끝에 텍스트 표시)
vwap_raw  = ta.vwap(hlc3)
var label vwap_lbl  = na
var label avwap_lbl = na
if barstate.islast
    label.delete(vwap_lbl)
    label.delete(avwap_lbl)
    if use_vwap and not na(vwap_raw)
        vwap_lbl := label.new(bar_index, vwap_raw, "VWAP",
             color=color.new(color.black, 100), textcolor=col_vwap,
             style=label.style_label_left, size=size.small)
    if use_avwap and not na(avwap_val)
        avwap_lbl := label.new(bar_index, avwap_val, "AVWAP",
             color=color.new(color.black, 100), textcolor=col_avwap,
             style=label.style_label_left, size=size.small)

// ── ATR (일봉 기준, IB 완료 시 고정) ──────────────────────
atr_daily = request.security(syminfo.tickerid, "D", ta.atr(atr_len)[1], lookahead=barmerge.lookahead_off)
var float atr_locked = na

// ── 당일 IB/OR 추적 ──────────────────────────────────────
var float ibh = na
var float ibl = na
var bool  ibd = false
var int   ibs = na
var float orh = na
var float orl = na
var bool  ord_done = false
var int   ors_b = na

if ib_start
    ibh      := high
    ibl      := low
    ibd      := false
    ibs      := bar_index
    orh      := high
    orl      := low
    ord_done := false
    ors_b    := bar_index
if in_ib and not ibd
    ibh := math.max(ibh, high)
    ibl := math.min(ibl, low)
if in_or and not ord_done
    orh := math.max(orh, high)
    orl := math.min(orl, low)
if cur_mins < ib_e and bar_end_mins >= ib_e and not ibd
    ibd := true
    atr_locked := atr_daily
if cur_mins < or_e and bar_end_mins >= or_e and not ord_done
    ord_done := true

// ── ATR 레벨 라인 (당일 IB 완료 후 표시) ────────────────
var line atr1_up = na, var line atr1_dn = na
var line atr2_up = na, var line atr2_dn = na
var line atr3_up = na, var line atr3_dn = na
var line atr4_up = na, var line atr4_dn = na
var label atr1_up_lbl = na, var label atr1_dn_lbl = na
var label atr2_up_lbl = na, var label atr2_dn_lbl = na
var label atr3_up_lbl = na, var label atr3_dn_lbl = na
var label atr4_up_lbl = na, var label atr4_dn_lbl = na

atr_make_line(y_val, col, sty) =>
    line.new(ibs, y_val, bar_index, y_val, color=col, style=sty, width=1)

atr_update_line(ln, y_val) =>
    line.set_y1(ln, y_val)
    line.set_y2(ln, y_val)
    line.set_x2(ln, bar_index)

atr_make_lbl(y_val, mult, col) =>
    label.new(bar_index, y_val, "ATR×"+str.tostring(mult, "#.#")+" "+str.tostring(y_val, format.mintick), color=color.new(color.black, 100), textcolor=col, style=label.style_label_left, size=size.small)

if ibd and not na(ibh) and show_atr and in_box_window
    a1u = ibh + atr_locked * atr_mult1
    a1d = ibl - atr_locked * atr_mult1
    a2u = ibh + atr_locked * atr_mult2
    a2d = ibl - atr_locked * atr_mult2
    a3u = ibh + atr_locked * atr_mult3
    a3d = ibl - atr_locked * atr_mult3
    a4u = ibh + atr_locked * atr_mult4
    a4d = ibl - atr_locked * atr_mult4
    // ATR 1
    if na(atr1_up)
        atr1_up := atr_make_line(a1u, col_atr1, line.style_dashed)
        atr1_dn := atr_make_line(a1d, col_atr1, line.style_dashed)
    else
        atr_update_line(atr1_up, a1u)
        atr_update_line(atr1_dn, a1d)
    // ATR 2
    if na(atr2_up)
        atr2_up := atr_make_line(a2u, col_atr2, line.style_dashed)
        atr2_dn := atr_make_line(a2d, col_atr2, line.style_dashed)
    else
        atr_update_line(atr2_up, a2u)
        atr_update_line(atr2_dn, a2d)
    // ATR 3
    if show_atr3
        if na(atr3_up)
            atr3_up := atr_make_line(a3u, col_atr3, line.style_dotted)
            atr3_dn := atr_make_line(a3d, col_atr3, line.style_dotted)
        else
            atr_update_line(atr3_up, a3u)
            atr_update_line(atr3_dn, a3d)
    // ATR 4
    if show_atr4
        if na(atr4_up)
            atr4_up := atr_make_line(a4u, col_atr4, line.style_dotted)
            atr4_dn := atr_make_line(a4d, col_atr4, line.style_dotted)
        else
            atr_update_line(atr4_up, a4u)
            atr_update_line(atr4_dn, a4d)
    // 라벨 갱신 (마지막 봉에서만 — 매 봉 삭제/재생성 낭비 제거)
    if barstate.islast
        label.delete(atr1_up_lbl)
        label.delete(atr1_dn_lbl)
        label.delete(atr2_up_lbl)
        label.delete(atr2_dn_lbl)
        label.delete(atr3_up_lbl)
        label.delete(atr3_dn_lbl)
        label.delete(atr4_up_lbl)
        label.delete(atr4_dn_lbl)
        atr1_up_lbl := atr_make_lbl(a1u, atr_mult1, col_atr1)
        atr1_dn_lbl := atr_make_lbl(a1d, atr_mult1, col_atr1)
        atr2_up_lbl := atr_make_lbl(a2u, atr_mult2, col_atr2)
        atr2_dn_lbl := atr_make_lbl(a2d, atr_mult2, col_atr2)
        if show_atr3
            atr3_up_lbl := atr_make_lbl(a3u, atr_mult3, col_atr3)
            atr3_dn_lbl := atr_make_lbl(a3d, atr_mult3, col_atr3)
        if show_atr4
            atr4_up_lbl := atr_make_lbl(a4u, atr_mult4, col_atr4)
            atr4_dn_lbl := atr_make_lbl(a4d, atr_mult4, col_atr4)

// IB 시작 시 ATR 라인 초기화
if ib_start
    line.delete(atr1_up)
    line.delete(atr1_dn)
    line.delete(atr2_up)
    line.delete(atr2_dn)
    line.delete(atr3_up)
    line.delete(atr3_dn)
    line.delete(atr4_up)
    line.delete(atr4_dn)
    label.delete(atr1_up_lbl)
    label.delete(atr1_dn_lbl)
    label.delete(atr2_up_lbl)
    label.delete(atr2_dn_lbl)
    label.delete(atr3_up_lbl)
    label.delete(atr3_dn_lbl)
    label.delete(atr4_up_lbl)
    label.delete(atr4_dn_lbl)
    atr1_up := na
    atr1_dn := na
    atr2_up := na
    atr2_dn := na
    atr3_up := na
    atr3_dn := na
    atr4_up := na
    atr4_dn := na
    atr_locked := na

// ── Balance / Trend Day 판별 ──────────────────────────────
// 1) IB Range / ATR 비율로 1차 성향(lean) 판단
// 2) IB 완료 후 가격이 ×1.5 확장 레벨까지 도달했는지로 확정(confirm) 판단
var float day_ib_range   = na
var float day_ib_atr     = na
var string day_lean      = "—"
var string day_confirm   = "—"
var bool day_ext_up_hit  = false
var bool day_ext_dn_hit  = false
var float day_ext_up_lvl = na
var float day_ext_dn_lvl = na

// ── IB/ATR 임계값 예측 정확도 추적 (당일 차트 히스토리 범위 내 자체 검증용) ──
var int pred_trend_n   = 0
var int pred_trend_hit = 0
var int pred_bal_n     = 0
var int pred_bal_hit   = 0
if ib_start and day_lean != "—" and day_confirm != "—"
    was_confirmed_trend = day_confirm == "Trend Day Confirmed ↑" or day_confirm == "Trend Day Confirmed ↓"
    if day_lean == "Trend"
        pred_trend_n += 1
        if was_confirmed_trend
            pred_trend_hit += 1
    if day_lean == "Balance"
        pred_bal_n += 1
        if not was_confirmed_trend
            pred_bal_hit += 1

if ib_start
    day_ib_range   := na
    day_ib_atr     := na
    day_lean       := "—"
    day_confirm    := "—"
    day_ext_up_hit := false
    day_ext_dn_hit := false
    day_ext_up_lvl := na
    day_ext_dn_lvl := na

if ibd and not ibd[1] and not na(ibh)
    day_ib_range   := ibh - ibl
    day_ib_atr     := (not na(atr_locked) and atr_locked > 0) ? day_ib_range / atr_locked : na
    day_lean       := na(day_ib_atr) ? "—" : day_ib_atr >= ib_atr_bal_th ? "Balance" : day_ib_atr <= ib_atr_trend_th ? "Trend" : "Neutral"
    day_ext_up_lvl := ibh + day_ib_range * 0.5
    day_ext_dn_lvl := ibl - day_ib_range * 0.5

if ibd and not na(ibh) and not na(day_ib_range)
    if high >= day_ext_up_lvl
        day_ext_up_hit := true
    if low <= day_ext_dn_lvl
        day_ext_dn_hit := true
    day_confirm := day_ext_up_hit and day_ext_dn_hit ? "Both Sides Extended (Choppy)" : day_ext_up_hit ? "Trend Day Confirmed ↑" : day_ext_dn_hit ? "Trend Day Confirmed ↓" : "Inside IB (In Progress)"

// Day Type이 막 확정된 순간 감지 (alertcondition용, 하루 1회씩만 true)
day_confirm_changed   = day_confirm != day_confirm[1]
day_trend_up_now       = day_confirm_changed and day_confirm == "Trend Day Confirmed ↑"
day_trend_dn_now       = day_confirm_changed and day_confirm == "Trend Day Confirmed ↓"
day_choppy_now         = day_confirm_changed and day_confirm == "Both Sides Extended (Choppy)"

// ── Value Area (전일 볼륨 프로파일 기반 POC/VAH/VAL) ─────
// 매일 ib_start~다음 ib_start 사이를 "하루"로 보고, 차트 타임프레임 봉의
// 거래량을 가격 빈(bin)에 누적해 전일 POC/VAH/VAL을 계산한다.
VA_BINS = 400
var array<float> vp_vol  = array.new_float(VA_BINS, 0.0)
var int    vp_base    = na
var float  va_bin_eff = na
var float  prev_poc   = na
var float  prev_vah   = na
var float  prev_val   = na
var string va_position = "—"
var line   va_poc_ln = na, var line  va_vah_ln = na, var line  va_val_ln = na
var label  va_poc_lb = na, var label va_vah_lb = na, var label va_val_lb = na

if ib_start
    if not na(vp_base) and not na(va_bin_eff)
        total_vol = array.sum(vp_vol)
        if total_vol > 0
            poc_idx   = array.indexof(vp_vol, array.max(vp_vol))
            va_target = total_vol * (va_pct / 100.0)
            lo_p = poc_idx
            hi_p = poc_idx
            accumulated = array.get(vp_vol, poc_idx)
            while accumulated < va_target and (lo_p > 0 or hi_p < VA_BINS - 1)
                vol_below = lo_p > 0 ? array.get(vp_vol, lo_p - 1) : -1.0
                vol_above = hi_p < VA_BINS - 1 ? array.get(vp_vol, hi_p + 1) : -1.0
                if vol_below >= vol_above
                    lo_p := lo_p - 1
                    accumulated := accumulated + vol_below
                else
                    hi_p := hi_p + 1
                    accumulated := accumulated + vol_above
            prev_poc := (vp_base + poc_idx) * va_bin_eff + va_bin_eff / 2
            prev_vah := (vp_base + hi_p) * va_bin_eff + va_bin_eff
            prev_val := (vp_base + lo_p) * va_bin_eff
            line.delete(va_poc_ln)
            line.delete(va_vah_ln)
            line.delete(va_val_ln)
            label.delete(va_poc_lb)
            label.delete(va_vah_lb)
            label.delete(va_val_lb)
            if show_va
                va_poc_ln := line.new(bar_index, prev_poc, bar_index, prev_poc, color=col_va_poc, style=line.style_dashed, width=1)
                va_vah_ln := line.new(bar_index, prev_vah, bar_index, prev_vah, color=col_va_vah, style=line.style_dotted, width=1)
                va_val_ln := line.new(bar_index, prev_val, bar_index, prev_val, color=col_va_val, style=line.style_dotted, width=1)
                va_poc_lb := label.new(bar_index, prev_poc, "POC "+str.tostring(prev_poc, format.mintick), color=color.new(color.black,100), textcolor=col_va_poc, style=label.style_label_left, size=size.small)
                va_vah_lb := label.new(bar_index, prev_vah, "VAH "+str.tostring(prev_vah, format.mintick), color=color.new(color.black,100), textcolor=col_va_vah, style=label.style_label_left, size=size.small)
                va_val_lb := label.new(bar_index, prev_val, "VAL "+str.tostring(prev_val, format.mintick), color=color.new(color.black,100), textcolor=col_va_val, style=label.style_label_left, size=size.small)
    array.fill(vp_vol, 0.0)
    va_bin_eff := switch va_bin_mode
        "Auto (ATR)"          => na(atr_daily) or atr_daily <= 0 ? va_bin_size : math.max(atr_daily / va_bin_div, syminfo.mintick)
        "Manual (Price)"      => va_bin_size
        "Ticks (STPO-style)"  => va_bin_ticks * syminfo.mintick
        => va_bin_size
    vp_base     := int(math.floor(close / va_bin_eff)) - VA_BINS / 2
    va_position := "—"

// 차트 타임프레임과 무관하게 고정된 타임프레임(기본 1분)으로 거래량 프로파일용 데이터 수집
[va_h_arr, va_l_arr, va_v_arr] = request.security_lower_tf(syminfo.tickerid, va_block_tf, [high, low, volume])

// 매 봉마다 당일 거래량을 가격 빈에 누적 (RTH 모드면 정규장 시간대만)
if not na(va_bin_eff) and in_va_window
    va_n_sub = math.min(array.size(va_h_arr), math.min(array.size(va_l_arr), array.size(va_v_arr)))
    if va_n_sub > 0
        for si = 0 to va_n_sub - 1
            sub_h = array.get(va_h_arr, si)
            sub_l = array.get(va_l_arr, si)
            sub_v = array.get(va_v_arr, si)
            va_lo_bin = int(math.floor(sub_l / va_bin_eff))
            va_hi_bin = int(math.floor(sub_h / va_bin_eff))
            va_n_bins = va_hi_bin - va_lo_bin + 1
            for vb = va_lo_bin to va_hi_bin
                vidx = vb - vp_base
                if vidx >= 0 and vidx < VA_BINS
                    array.set(vp_vol, vidx, array.get(vp_vol, vidx) + sub_v / va_n_bins)

// 전일 VA 라인 실시간 연장 (박스와 동일하게 16:00 컷오프 적용)
if show_va and in_box_window
    if not na(va_poc_ln)
        line.set_x2(va_poc_ln, bar_index)
        label.set_x(va_poc_lb, bar_index)
    if not na(va_vah_ln)
        line.set_x2(va_vah_ln, bar_index)
        label.set_x(va_vah_lb, bar_index)
    if not na(va_val_ln)
        line.set_x2(va_val_ln, bar_index)
        label.set_x(va_val_lb, bar_index)

// IB 완료 시: 오늘 IB가 전일 Value Area 대비 어디서 형성됐는지 판정
if ibd and not ibd[1] and not na(ibh)
    va_position := na(prev_vah) or na(prev_val) ? "—" : ibl > prev_vah ? "Above Value" : ibh < prev_val ? "Below Value" : "Inside Value"

// IB/ATR 성향(day_lean) + 전일 VA 위치(va_position)를 종합한 최종 판정
day_lean_final = switch
    va_position == "Above Value"  and day_lean == "Trend"   => "Trend (VA Breakout Confirmed)"
    va_position == "Below Value"  and day_lean == "Trend"   => "Trend (VA Breakout Confirmed)"
    va_position == "Above Value"  and day_lean == "Neutral"          => "Trend (VA Breakout)"
    va_position == "Below Value"  and day_lean == "Neutral"          => "Trend (VA Breakout)"
    va_position == "Above Value"  and day_lean == "Balance" => "Mixed (IB·VA Conflict)"
    va_position == "Below Value"  and day_lean == "Balance" => "Mixed (IB·VA Conflict)"
    va_position == "Inside Value" and day_lean == "Balance" => "Balance (Inside VA Confirmed)"
    va_position == "Inside Value" and day_lean == "Neutral"          => "Balance (Inside VA)"
    va_position == "Inside Value" and day_lean == "Trend"   => "Mixed (IB·VA Conflict)"
    => day_lean

day_strategy = day_confirm == "Trend Day Confirmed ↑" or day_confirm == "Trend Day Confirmed ↓" ? "Trend Follow (Breakout)" : day_confirm == "Both Sides Extended (Choppy)" ? "Stand Aside (Choppy)" : str.contains(day_lean_final, "Balance") ? "Fade (Boundary Reversal)" : str.contains(day_lean_final, "Mixed") ? "Caution (Mixed Signals)" : str.contains(day_lean_final, "Trend") ? "Await Breakout" : "Stand Aside"

// ── 패널 색상 코딩 (Day Type / Strategy 값에 따라 셀 글자색 변경) ──
day_type_color = day_confirm == "Trend Day Confirmed ↑" ? color.lime : day_confirm == "Trend Day Confirmed ↓" ? color.red : day_confirm == "Both Sides Extended (Choppy)" ? color.gray : str.contains(day_lean_final, "Trend") ? color.orange : str.contains(day_lean_final, "Balance") ? color.aqua : str.contains(day_lean_final, "Mixed") ? color.orange : color.yellow

strategy_color = day_strategy == "Trend Follow (Breakout)" ? color.lime : day_strategy == "Stand Aside (Choppy)" ? color.gray : day_strategy == "Fade (Boundary Reversal)" ? color.aqua : day_strategy == "Caution (Mixed Signals)" ? color.orange : day_strategy == "Await Breakout" ? color.yellow : color.gray

// ── Strategy 텍스트에 실제 가격 레벨 결합 (돌파=확정된 IB 레벨, 페이드=VAH/VAL 경계, 돌파대기=IB 확장 레벨) ──
day_strategy_display = day_strategy == "Trend Follow (Breakout)" ? day_strategy + (day_confirm == "Trend Day Confirmed ↑" and not na(day_ext_up_lvl) ? "  ↑" + str.tostring(day_ext_up_lvl, format.mintick) + " Breakout" : day_confirm == "Trend Day Confirmed ↓" and not na(day_ext_dn_lvl) ? "  ↓" + str.tostring(day_ext_dn_lvl, format.mintick) + " Breakout" : "") : day_strategy == "Fade (Boundary Reversal)" ? day_strategy + (va_position == "Above Value" and not na(prev_vah) ? "  @VAH " + str.tostring(prev_vah, format.mintick) : va_position == "Below Value" and not na(prev_val) ? "  @VAL " + str.tostring(prev_val, format.mintick) : "") : day_strategy == "Await Breakout" ? day_strategy + (not na(day_ext_up_lvl) and not na(day_ext_dn_lvl) ? "  ↑" + str.tostring(day_ext_up_lvl, format.mintick) + " / ↓" + str.tostring(day_ext_dn_lvl, format.mintick) : "") : day_strategy

// ── 페이드(역추세) 진입 트리거: VAH/VAL 첫 터치-거부, 하루 1회씩만 발동 ──
var bool fade_dn_armed = true
var bool fade_up_armed = true
if ib_start
    fade_dn_armed := true
    fade_up_armed := true
    sig_trend_long.active  := false
    sig_trend_short.active := false
    sig_fade_long.active   := false
    sig_fade_short.active  := false
fade_dn = fade_dn_armed and ibd and not na(prev_vah) and not na(prev_poc) and high >= prev_vah and close < prev_vah and close > prev_poc
fade_up = fade_up_armed and ibd and not na(prev_val) and not na(prev_poc) and low <= prev_val and close > prev_val and close < prev_poc
if fade_dn
    fade_dn_armed := false
if fade_up
    fade_up_armed := false

// ── 헬퍼: 라인/박스 그리기 ───────────────────────────────
// 박스 테두리는 점선+고투명(border_transp)으로 → IB/OR 경계는 H/L 라인이 담당, 꼬리가 비쳐 보이게
draw_ib_lines(h, l, sb, eb, al) =>
    r   = h - l
    mid = (h + l) / 2.0
    ch  = color.new(col_ib_high, al)
    cl  = color.new(col_ib_low,  al)
    cm  = color.new(col_ib_mid,  math.min(99, al + 20))
    c15 = color.new(col_ext_15,  math.min(99, al + 30))
    c20 = color.new(col_ext_20,  math.min(99, al + 30))
    _lh  = line.new(sb, h,       eb, h,       color=ch,  width=2)
    _ll  = line.new(sb, l,       eb, l,       color=cl,  width=2)
    _lm  = show_mid    ? line.new(sb, mid,     eb, mid,   color=cm,  style=line.style_dashed, width=1) : na
    _h15 = show_ext_15 ? line.new(sb, h+r*.5, eb, h+r*.5, color=c15, style=line.style_dashed, width=1) : na
    _l15 = show_ext_15 ? line.new(sb, l-r*.5, eb, l-r*.5, color=c15, style=line.style_dashed, width=1) : na
    _h20 = show_ext_20 ? line.new(sb, h+r,    eb, h+r,    color=c20, style=line.style_dashed, width=1) : na
    _l20 = show_ext_20 ? line.new(sb, l-r,    eb, l-r,    color=c20, style=line.style_dashed, width=1) : na
    _bx  = show_ib_box ? box.new(sb, h, eb, l, border_color=color.new(col_ib_high, math.max(al, border_transp)), border_style=line.style_dashed, bgcolor=show_box_fill ? color.new(col_box_bg, math.min(99,90+al/10)) : na, border_width=1) : na
    // IB 라벨: 박스 왼쪽(sb) 고정
    _lbh = show_labels ? label.new(sb, h,   "IB H "+str.tostring(h, format.mintick),   color=color.new(color.black,100), textcolor=ch, style=label.style_label_right, size=size.small) : na
    _lbl = show_labels ? label.new(sb, l,   "IB L "+str.tostring(l, format.mintick),   color=color.new(color.black,100), textcolor=cl, style=label.style_label_right, size=size.small) : na
    _lbm = show_labels and show_mid ? label.new(sb, mid, "IB M "+str.tostring(mid, format.mintick), color=color.new(color.black,100), textcolor=cm, style=label.style_label_right, size=size.small) : na
    // 확장선 라벨: 박스 왼쪽 고정
    _lh15u = show_labels and show_ext_15 ? label.new(sb, h+r*.5, "×1.5 "+str.tostring(h+r*.5, format.mintick), color=color.new(color.black,100), textcolor=c15, style=label.style_label_right, size=size.small) : na
    _lh15d = show_labels and show_ext_15 ? label.new(sb, l-r*.5, "×1.5 "+str.tostring(l-r*.5, format.mintick), color=color.new(color.black,100), textcolor=c15, style=label.style_label_right, size=size.small) : na
    _lh20u = show_labels and show_ext_20 ? label.new(sb, h+r,    "×2.0 "+str.tostring(h+r, format.mintick),    color=color.new(color.black,100), textcolor=c20, style=label.style_label_right, size=size.small) : na
    _lh20d = show_labels and show_ext_20 ? label.new(sb, l-r,    "×2.0 "+str.tostring(l-r, format.mintick),    color=color.new(color.black,100), textcolor=c20, style=label.style_label_right, size=size.small) : na
    [_lh, _ll, _lm, _h15, _l15, _h20, _l20, _bx, _lbh, _lbl, _lbm, _lh15u, _lh15d, _lh20u, _lh20d]

draw_or_lines(h, l, sb, eb, al) =>
    r   = h - l
    mid = (h + l) / 2.0
    ch  = color.new(col_or_high, al)
    cl  = color.new(col_or_low,  al)
    cm  = color.new(col_or_mid,  math.min(99, al + 20))
    ce  = color.new(col_or_ext,  math.min(99, al + 30))
    _lh  = line.new(sb, h,       eb, h,       color=ch, width=1)
    _ll  = line.new(sb, l,       eb, l,       color=cl, width=1)
    _lm  = show_or_mid ? line.new(sb, mid,     eb, mid,   color=cm, style=line.style_dashed, width=1) : na
    _h15 = show_or_ext ? line.new(sb, h+r*.5, eb, h+r*.5, color=ce, style=line.style_dotted, width=1) : na
    _l15 = show_or_ext ? line.new(sb, l-r*.5, eb, l-r*.5, color=ce, style=line.style_dotted, width=1) : na
    _h20 = show_or_ext ? line.new(sb, h+r,    eb, h+r,    color=ce, style=line.style_dotted, width=1) : na
    _l20 = show_or_ext ? line.new(sb, l-r,    eb, l-r,    color=ce, style=line.style_dotted, width=1) : na
    _bx  = box.new(sb, h, eb, l, border_color=color.new(col_or_high, math.max(al, border_transp)), border_style=line.style_dashed, bgcolor=show_box_fill ? color.new(col_or_box, math.min(99,93+al/10)) : na, border_width=1)
    // OR 라벨: 박스 오른쪽(eb) → 우측 따라다님
    _lbh = show_labels ? label.new(eb, h,   "OR H "+str.tostring(h, format.mintick),   color=color.new(color.black,100), textcolor=ch, style=label.style_label_left, size=size.small) : na
    _lbl = show_labels ? label.new(eb, l,   "OR L "+str.tostring(l, format.mintick),   color=color.new(color.black,100), textcolor=cl, style=label.style_label_left, size=size.small) : na
    _lbm = show_labels and show_or_mid ? label.new(eb, mid, "OR M "+str.tostring(mid, format.mintick), color=color.new(color.black,100), textcolor=cm, style=label.style_label_left, size=size.small) : na
    _le15u = show_labels and show_or_ext ? label.new(eb, h+r*.5, "OR×1.5 "+str.tostring(h+r*.5, format.mintick), color=color.new(color.black,100), textcolor=ce, style=label.style_label_left, size=size.small) : na
    _le15d = show_labels and show_or_ext ? label.new(eb, l-r*.5, "OR×1.5 "+str.tostring(l-r*.5, format.mintick), color=color.new(color.black,100), textcolor=ce, style=label.style_label_left, size=size.small) : na
    _le20u = show_labels and show_or_ext ? label.new(eb, h+r,    "OR×2.0 "+str.tostring(h+r, format.mintick),    color=color.new(color.black,100), textcolor=ce, style=label.style_label_left, size=size.small) : na
    _le20d = show_labels and show_or_ext ? label.new(eb, l-r,    "OR×2.0 "+str.tostring(l-r, format.mintick),    color=color.new(color.black,100), textcolor=ce, style=label.style_label_left, size=size.small) : na
    [_lh, _ll, _lm, _h15, _l15, _h20, _l20, _bx, _lbh, _lbl, _lbm, _le15u, _le15d, _le20u, _le20d]

// 과거일 H/L/Mid 라인 투명도 강화 (하루 지날 때마다 옅어지게)
fade_day(line f_lh, line f_ll, line f_lm, color c_h, color c_l, color c_m, int t) =>
    if not na(f_lh)
        line.set_color(f_lh, color.new(c_h, math.min(95, t)))
    if not na(f_ll)
        line.set_color(f_ll, color.new(c_l, math.min(95, t)))
    if not na(f_lm)
        line.set_color(f_lm, color.new(c_m, math.min(95, t + 20)))

// ── 히스토리 변수: 5일치 (라벨은 당일 d1/o1만 보관) ─────
var line  d1_ih=na
var line d1_il=na
var line d1_im=na
var line  d1_h15=na
var line d1_l15=na
var line d1_h20=na
var line d1_l20=na
var box   d1_bx=na
var label d1_lh=na
var label d1_ll=na
var label d1_lm=na
var label d1_lh15u=na
var label d1_lh15d=na
var label d1_lh20u=na
var label d1_lh20d=na

var line  d2_ih=na
var line d2_il=na
var line d2_im=na
var line  d2_h15=na
var line d2_l15=na
var line d2_h20=na
var line d2_l20=na
var box   d2_bx=na

var line  d3_ih=na
var line d3_il=na
var line d3_im=na
var line  d3_h15=na
var line d3_l15=na
var line d3_h20=na
var line d3_l20=na
var box   d3_bx=na

var line  d4_ih=na
var line d4_il=na
var line d4_im=na
var line  d4_h15=na
var line d4_l15=na
var line d4_h20=na
var line d4_l20=na
var box   d4_bx=na

var line  d5_ih=na
var line d5_il=na
var line d5_im=na
var line  d5_h15=na
var line d5_l15=na
var line d5_h20=na
var line d5_l20=na
var box   d5_bx=na

var line  o1_h=na
var line o1_l=na
var line o1_m=na
var line  o1_h15=na
var line o1_l15=na
var line o1_h20=na
var line o1_l20=na
var box   o1_bx=na
var label o1_lh=na
var label o1_ll=na
var label o1_lm=na
var label o1_lh15u=na
var label o1_lh15d=na
var label o1_lh20u=na
var label o1_lh20d=na

var line  o2_h=na
var line o2_l=na
var line o2_m=na
var line  o2_h15=na
var line o2_l15=na
var line o2_h20=na
var line o2_l20=na
var box   o2_bx=na

var line  o3_h=na
var line o3_l=na
var line o3_m=na
var line  o3_h15=na
var line o3_l15=na
var line o3_h20=na
var line o3_l20=na
var box   o3_bx=na

var line  o4_h=na
var line o4_l=na
var line o4_m=na
var line  o4_h15=na
var line o4_l15=na
var line o4_h20=na
var line o4_l20=na
var box   o4_bx=na

var line  o5_h=na
var line o5_l=na
var line o5_m=na
var line  o5_h15=na
var line o5_l15=na
var line o5_h20=na
var line o5_l20=na
var box   o5_bx=na

// ── ib_start: 하루 롤링 (최고령 삭제 → 어제를 히스토리로 → 투명도 에이징 → 당일 슬롯 비움) ──
if ib_start
    // 최고령(d5/o5) 객체 삭제
    line.delete(d5_ih)
    line.delete(d5_il)
    line.delete(d5_im)
    line.delete(d5_h15)
    line.delete(d5_l15)
    line.delete(d5_h20)
    line.delete(d5_l20)
    box.delete(d5_bx)
    line.delete(o5_h)
    line.delete(o5_l)
    line.delete(o5_m)
    line.delete(o5_h15)
    line.delete(o5_l15)
    line.delete(o5_h20)
    line.delete(o5_l20)
    box.delete(o5_bx)
    // 어제(d1/o1) 라벨은 히스토리로 넘기지 않고 삭제 (차트 정리)
    label.delete(d1_lh)
    label.delete(d1_ll)
    label.delete(d1_lm)
    label.delete(d1_lh15u)
    label.delete(d1_lh15d)
    label.delete(d1_lh20u)
    label.delete(d1_lh20d)
    label.delete(o1_lh)
    label.delete(o1_ll)
    label.delete(o1_lm)
    label.delete(o1_lh15u)
    label.delete(o1_lh15d)
    label.delete(o1_lh20u)
    label.delete(o1_lh20d)
    // IB 롤링
    d5_ih:=d4_ih
    d5_il:=d4_il
    d5_im:=d4_im
    d5_h15:=d4_h15
    d5_l15:=d4_l15
    d5_h20:=d4_h20
    d5_l20:=d4_l20
    d5_bx:=d4_bx
    d4_ih:=d3_ih
    d4_il:=d3_il
    d4_im:=d3_im
    d4_h15:=d3_h15
    d4_l15:=d3_l15
    d4_h20:=d3_h20
    d4_l20:=d3_l20
    d4_bx:=d3_bx
    d3_ih:=d2_ih
    d3_il:=d2_il
    d3_im:=d2_im
    d3_h15:=d2_h15
    d3_l15:=d2_l15
    d3_h20:=d2_h20
    d3_l20:=d2_l20
    d3_bx:=d2_bx
    d2_ih:=d1_ih
    d2_il:=d1_il
    d2_im:=d1_im
    d2_h15:=d1_h15
    d2_l15:=d1_l15
    d2_h20:=d1_h20
    d2_l20:=d1_l20
    d2_bx:=d1_bx
    // OR 롤링
    o5_h:=o4_h
    o5_l:=o4_l
    o5_m:=o4_m
    o5_h15:=o4_h15
    o5_l15:=o4_l15
    o5_h20:=o4_h20
    o5_l20:=o4_l20
    o5_bx:=o4_bx
    o4_h:=o3_h
    o4_l:=o3_l
    o4_m:=o3_m
    o4_h15:=o3_h15
    o4_l15:=o3_l15
    o4_h20:=o3_h20
    o4_l20:=o3_l20
    o4_bx:=o3_bx
    o3_h:=o2_h
    o3_l:=o2_l
    o3_m:=o2_m
    o3_h15:=o2_h15
    o3_l15:=o2_l15
    o3_h20:=o2_h20
    o3_l20:=o2_l20
    o3_bx:=o2_bx
    o2_h:=o1_h
    o2_l:=o1_l
    o2_m:=o1_m
    o2_h15:=o1_h15
    o2_l15:=o1_l15
    o2_h20:=o1_h20
    o2_l20:=o1_l20
    o2_bx:=o1_bx
    // 투명도 에이징 (오래될수록 옅게)
    fade_day(d2_ih, d2_il, d2_im, col_ib_high, col_ib_low, col_ib_mid, edge_transp + 20)
    fade_day(d3_ih, d3_il, d3_im, col_ib_high, col_ib_low, col_ib_mid, edge_transp + 40)
    fade_day(d4_ih, d4_il, d4_im, col_ib_high, col_ib_low, col_ib_mid, edge_transp + 55)
    fade_day(d5_ih, d5_il, d5_im, col_ib_high, col_ib_low, col_ib_mid, edge_transp + 65)
    fade_day(o2_h, o2_l, o2_m, col_or_high, col_or_low, col_or_mid, edge_transp + 20)
    fade_day(o3_h, o3_l, o3_m, col_or_high, col_or_low, col_or_mid, edge_transp + 40)
    fade_day(o4_h, o4_l, o4_m, col_or_high, col_or_low, col_or_mid, edge_transp + 55)
    fade_day(o5_h, o5_l, o5_m, col_or_high, col_or_low, col_or_mid, edge_transp + 65)
    // 당일 슬롯 비움
    d1_ih:=na
    d1_il:=na
    d1_im:=na
    d1_h15:=na
    d1_l15:=na
    d1_h20:=na
    d1_l20:=na
    d1_bx:=na
    d1_lh:=na
    d1_ll:=na
    d1_lm:=na
    d1_lh15u:=na
    d1_lh15d:=na
    d1_lh20u:=na
    d1_lh20d:=na
    o1_h:=na
    o1_l:=na
    o1_m:=na
    o1_h15:=na
    o1_l15:=na
    o1_h20:=na
    o1_l20:=na
    o1_bx:=na
    o1_lh:=na
    o1_ll:=na
    o1_lm:=na
    o1_lh15u:=na
    o1_lh15d:=na
    o1_lh20u:=na
    o1_lh20d:=na

// ── IB 완료 시: 당일 IB 그리기 ───────────────────────────
if ibd and not ibd[1] and not na(ibh)
    [a,b,c,d,e,f,g,h2,i2,j2,k2,l2,m2,n2,o2v] = draw_ib_lines(ibh, ibl, ibs, bar_index, edge_transp)
    d1_ih:=a
    d1_il:=b
    d1_im:=c
    d1_h15:=d
    d1_l15:=e
    d1_h20:=f
    d1_l20:=g
    d1_bx:=h2
    d1_lh:=i2
    d1_ll:=j2
    d1_lm:=k2
    d1_lh15u:=l2
    d1_lh15d:=m2
    d1_lh20u:=n2
    d1_lh20d:=o2v

// ── OR 완료 시: 당일 OR 그리기 ───────────────────────────
if show_or and ord_done and not ord_done[1] and not na(orh)
    [a,b,c,d,e,f,g,h2,i2,j2,k2,l2,m2,n2,o2v] = draw_or_lines(orh, orl, ors_b, bar_index, edge_transp)
    o1_h:=a
    o1_l:=b
    o1_m:=c
    o1_h15:=d
    o1_l15:=e
    o1_h20:=f
    o1_l20:=g
    o1_bx:=h2
    o1_lh:=i2
    o1_ll:=j2
    o1_lm:=k2
    o1_lh15u:=l2
    o1_lh15d:=m2
    o1_lh20u:=n2
    o1_lh20d:=o2v

// ── 당일(d1/o1) 라인 실시간 연장 (뉴욕시간 박스 종료 시각까지만) ──
if in_box_window and not na(d1_ih)
    line.set_x2(d1_ih, bar_index)
    line.set_x2(d1_il, bar_index)
    if not na(d1_im)
        line.set_x2(d1_im, bar_index)
    if not na(d1_h15)
        line.set_x2(d1_h15, bar_index)
        line.set_x2(d1_l15, bar_index)
    if not na(d1_h20)
        line.set_x2(d1_h20, bar_index)
        line.set_x2(d1_l20, bar_index)
    if not na(d1_bx)
        box.set_right(d1_bx, bar_index)

if show_or and in_box_window and not na(o1_h)
    line.set_x2(o1_h, bar_index)
    line.set_x2(o1_l, bar_index)
    if not na(o1_m)
        line.set_x2(o1_m, bar_index)
    if not na(o1_h15)
        line.set_x2(o1_h15, bar_index)
        line.set_x2(o1_l15, bar_index)
    if not na(o1_h20)
        line.set_x2(o1_h20, bar_index)
        line.set_x2(o1_l20, bar_index)
    if not na(o1_bx)
        box.set_right(o1_bx, bar_index)
    if show_labels
        if not na(o1_lh)
            label.set_x(o1_lh, bar_index)
        if not na(o1_ll)
            label.set_x(o1_ll, bar_index)
        if not na(o1_lm)
            label.set_x(o1_lm, bar_index)
        if not na(o1_lh15u)
            label.set_x(o1_lh15u, bar_index)
            label.set_x(o1_lh15d, bar_index)
        if not na(o1_lh20u)
            label.set_x(o1_lh20u, bar_index)
            label.set_x(o1_lh20d, bar_index)

// ── BO / Failed ───────────────────────────────────────────
var bool bo_up_f = false
var bool bo_dn_f = false
var bool was_up  = false
var bool was_dn  = false
if ib_start
    bo_up_f := false
    bo_dn_f := false
    was_up := false
    was_dn := false
if ibd and not na(ibh)
    // 되돌림 버퍼: ATR 기준 (ATR 결측 시 IB 폭으로 대체) — 가격 % 기준은 종목별 체감이 달라 폐기
    bo_buf = not na(atr_locked) ? atr_locked * bo_buf_atr : (ibh - ibl) * bo_buf_atr
    if close > ibh and not bo_up_f
        bo_up_f := true
    else if close < ibh - bo_buf
        bo_up_f := false
    if close < ibl and not bo_dn_f
        bo_dn_f := true
    else if close > ibl + bo_buf
        bo_dn_f := false

bo_up = bo_up_f and not bo_up_f[1]
bo_dn = bo_dn_f and not bo_dn_f[1]
if bo_up
    was_up := true
if bo_dn
    was_dn := true
fail_up = was_up and ibd and close < ibh and close[1] >= ibh
fail_dn = was_dn and ibd and close > ibl and close[1] <= ibl
if fail_up
    was_up := false
if fail_dn
    was_dn := false

plotshape(show_bo and bo_up,   style=shape.triangleup,   location=location.belowbar, color=col_bo_up,   size=size.small, text="BO↑")
plotshape(show_bo and bo_dn,   style=shape.triangledown, location=location.abovebar, color=col_bo_down, size=size.small, text="BO↓")
plotshape(show_bo and fail_up, style=shape.triangledown, location=location.abovebar, color=col_failed,  size=size.small, text="Failed↓")
plotshape(show_bo and fail_dn, style=shape.triangleup,   location=location.belowbar, color=col_failed,  size=size.small, text="Failed↑")
plotshape(show_fade_sig and fade_dn, style=shape.diamond, location=location.abovebar, color=color.fuchsia, size=size.small, text="Fade↓")
plotshape(show_fade_sig and fade_up, style=shape.diamond, location=location.belowbar, color=color.fuchsia, size=size.small, text="Fade↑")

// ── 매매 신호: 진입 시 SL/TP 계산 후 오픈, 매 봉 업데이트(연장/적중 체크) ──
// 추세(돌파) SL = IB 반대편 끝, 단 ATR×배수보다 멀면 ATR×배수로 캡. TP = IB×1.5 확장 레벨(Trend Day 확정 레벨과 동일)
if show_trend_sig and bo_up
    sl_long = not na(atr_locked) ? close - math.min(close - ibl, atr_locked * sig_sl_atr_mult) : ibl
    open_signal(sig_trend_long, close, sl_long, day_ext_up_lvl, true, col_bo_up, "Long " + str.tostring(close, format.mintick))
if show_trend_sig and bo_dn
    sl_short = not na(atr_locked) ? close + math.min(ibh - close, atr_locked * sig_sl_atr_mult) : ibh
    open_signal(sig_trend_short, close, sl_short, day_ext_dn_lvl, false, col_bo_down, "Short " + str.tostring(close, format.mintick))
// 페이드 SL = VAH/VAL 너머 ATR×배수 버퍼(ATR 결측 시 VA폭의 10%로 대체). TP = 전일 POC(VA 경계 사이의 다음 의미있는 레벨)
if show_fade_sig and fade_dn
    va_w = not na(prev_vah) and not na(prev_val) ? prev_vah - prev_val : na
    sl_fade_short = not na(atr_locked) ? prev_vah + atr_locked * sig_fade_sl_mult : prev_vah + (not na(va_w) ? va_w * 0.1 : 0.0)
    open_signal(sig_fade_short, close, sl_fade_short, prev_poc, false, color.fuchsia, "Fade↓ " + str.tostring(close, format.mintick))
if show_fade_sig and fade_up
    va_w2 = not na(prev_vah) and not na(prev_val) ? prev_vah - prev_val : na
    sl_fade_long = not na(atr_locked) ? prev_val - atr_locked * sig_fade_sl_mult : prev_val - (not na(va_w2) ? va_w2 * 0.1 : 0.0)
    open_signal(sig_fade_long, close, sl_fade_long, prev_poc, true, color.fuchsia, "Fade↑ " + str.tostring(close, format.mintick))

update_signal(sig_trend_long)
update_signal(sig_trend_short)
update_signal(sig_fade_long)
update_signal(sig_fade_short)

alertcondition(show_trend_sig and bo_up,   title="Entry: Trend Long",  message="[Signal] 🟢 Trend Long Entry")
alertcondition(show_trend_sig and bo_dn,   title="Entry: Trend Short", message="[Signal] 🔴 Trend Short Entry")
alertcondition(show_fade_sig and fade_dn,  title="Entry: Fade Short",  message="[Signal] 🟣 Fade Short Entry (VAH Rejection)")
alertcondition(show_fade_sig and fade_up,  title="Entry: Fade Long",   message="[Signal] 🟣 Fade Long Entry (VAL Rejection)")

// ── VWAP 플롯 ────────────────────────────────────────────
plot(use_vwap  ? vwap_raw  : na, "VWAP",  color=col_vwap,  linewidth=lw_vwap)
plot(use_avwap ? avwap_val : na, "AVWAP", color=col_avwap, linewidth=lw_vwap)

// ── Info Panel ────────────────────────────────────────────
table_pos = switch table_pos_raw
    "Top Left"       => position.top_left
    "Top Center"     => position.top_center
    "Top Right"      => position.top_right
    "Middle Left"    => position.middle_left
    "Middle Center"  => position.middle_center
    "Middle Right"   => position.middle_right
    "Bottom Left"    => position.bottom_left
    "Bottom Center"  => position.bottom_center
    => position.bottom_right

var table t = na
panel_rows = 5 + (show_calibration ? 1 : 0)
if barstate.islast and show_table and not na(ibh)
    if na(t)
        t := table.new(table_pos, 2, panel_rows,
             bgcolor=color.new(color.black,60), border_color=color.new(color.gray,50),
             border_width=1, frame_color=color.gray, frame_width=1)
    table.cell(t,0,0,"IB / OR",  text_color=color.white, bgcolor=color.new(color.blue,40), text_size=size.small, text_halign=text.align_center)
    table.cell(t,1,0,"Today",    text_color=color.white, bgcolor=color.new(color.blue,40), text_size=size.small, text_halign=text.align_center)
    atr_missing = ibd and na(atr_locked)
    ib_atr_pct_txt = na(day_ib_atr) ? (atr_missing ? "  (ATR Missing ⚠)" : "") : "  (" + str.tostring(day_ib_atr*100, "#") + "% of ATR)"
    table.cell(t,0,1,"IB Range (vs ATR)", text_color=color.gray, text_size=size.small)
    table.cell(t,1,1, str.tostring(ibh-ibl, format.mintick) + ib_atr_pct_txt, text_color=atr_missing ? color.orange : color.white, text_size=size.small)
    or_ib_pct_txt = (not na(orh) and (ibh-ibl) != 0) ? "  (" + str.tostring((orh-orl)/(ibh-ibl)*100, "#") + "% of IB)" : ""
    table.cell(t,0,2,"OR Range (vs IB)", text_color=color.gray, text_size=size.small)
    table.cell(t,1,2, (not na(orh) ? str.tostring(orh-orl, format.mintick) : "—") + or_ib_pct_txt, text_color=color.white, text_size=size.small)
    table.cell(t,0,3,"Day Type",  text_color=color.gray, text_size=size.small)
    table.cell(t,1,3, show_day_type ? (na(day_ib_atr) ? "—" : str.tostring(math.round(day_ib_atr,2))) + " " + day_lean_final + "/" + day_confirm : "Off", text_color=show_day_type ? day_type_color : color.gray, text_size=size.small)
    table.cell(t,0,4,"Strategy",  text_color=color.gray, text_size=size.small)
    table.cell(t,1,4, show_day_type ? day_strategy_display : "", text_color=show_day_type ? strategy_color : color.gray, text_size=size.small)
    if show_calibration
        trend_acc_txt = pred_trend_n > 0 ? str.tostring(pred_trend_hit) + "/" + str.tostring(pred_trend_n) + " (" + str.tostring(pred_trend_hit*100.0/pred_trend_n, "#") + "%)" : "—"
        bal_acc_txt   = pred_bal_n   > 0 ? str.tostring(pred_bal_hit)   + "/" + str.tostring(pred_bal_n)   + " (" + str.tostring(pred_bal_hit*100.0/pred_bal_n, "#")   + "%)" : "—"
        table.cell(t,0,5,"Threshold Accuracy", text_color=color.gray, text_size=size.small)
        table.cell(t,1,5, "Trend " + trend_acc_txt + " · Bal " + bal_acc_txt, text_color=color.silver, text_size=size.small)
if barstate.islast and not show_table and not na(t)
    table.delete(t)
    t := na

alertcondition(bo_up,   title="IB BO↑",      message="[IB] 🟢 IB High Breakout")
alertcondition(bo_dn,   title="IB BO↓",      message="[IB] 🔴 IB Low Breakdown")
alertcondition(fail_up, title="IB Failed↓",  message="[IB] ⚠️ Failed Breakout High")
alertcondition(fail_dn, title="IB Failed↑",  message="[IB] ⚠️ Failed Breakdown Low")
alertcondition(day_trend_up_now, title="Day Type: Trend Confirmed ↑", message="[DayType] 📈 Trend Day Confirmed (Up)")
alertcondition(day_trend_dn_now, title="Day Type: Trend Confirmed ↓", message="[DayType] 📉 Trend Day Confirmed (Down)")
alertcondition(day_choppy_now,   title="Day Type: Choppy Confirmed",  message="[DayType] 🔀 Both Sides Extended (Choppy)")
````
