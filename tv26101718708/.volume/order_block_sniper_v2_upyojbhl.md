# Order Block Sniper v2

- url: https://www.tradingview.com/script/uPyOjbHl-order-block-sniper-v2/
- type: indicator
- pine_id: PUB;bc1a78ed1a284c289b12debe6a9dc24d
- version: 2.0

## Description

Indicator Logic:

Detects Break of Structure (BOS) — when the close breaks the previous swing high (for bullish) or swing low (for bearish).
Upon BOS, it identifies the Order Block — the last opposite candle before the breakout (bearish candle before bullish BOS, and vice versa).
Draws an OB zone (box) with:
Equilibrium line (50% level)
SL line
Three TP lines (1R, 2R, 3R)

Waits for mitigation — when price returns to the OB zone → generates an ENTRY signal.
A/B/C Grading:
A = Stop hunt + ultra high volume
B = Increased volume
C = Basic



What you see on the chart:

Zones labeled: BUY HUNT [A] RR 1:2.5 or SELL ZONE [C] RR 1:1.3
Dashed TP1 / TP2 / TP3 target lines
Dashed SL line
Upon mitigation: ENTRY A / ENTRY B / ENTRY C label + arrow
Optional FVG zones
Dashboard showing: Trend, Zone (Premium/Discount), Active OBs, Volume, Entries count





Clean zones labeled with A or B (max 3 zones displayed).
TP/SL lines are hidden until price retraces back into the zone.
When price returns to the zone: display ENTRY A 78.5 label + TP1 / TP2 / TP3 target lines with corresponding labels.

## Source Code

````pine
//@version=6
// OB Sniper v3 — PARLIZZ (indicator, webhook)
// Base: OB Sniper v2 parlizz + extracted features from:
//   • UST 2.0 (BullByte)    — DER + AMVS + VRI + COFP → Confluence Score 0-100
//   • Liquidity Echo        — Sweep classification + Volume Vacuum + Auto-calibration
//
// Pipeline: OB detection → Sweep classification → Auto-calibrated gate →
//           Confluence Score ≥ 70 → entry (LMT at mid OB) → webhook parlizz_ssl
//
// Visuals: Entry/SL/TP1/TP2/TP3 + dashboard (UST score, Sweep type, Auto-cal stats).
indicator('OB Sniper v3 (parlizz)', 'OB-V3', overlay=true,
     max_boxes_count=200, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// §1. INPUTS
// ═══════════════════════════════════════════════════════════════════════════

grp_calib = 'Калибровка по символу'
usePerSym = input.bool(true, 'Использовать настройки под символ', group=grp_calib)
useAutoCal = input.bool(true, 'Авто-калибровка под чарт', group=grp_calib,
     tooltip='Подстраивает пороги под текущий чарт: тень/тело, CV объёма, ATR%. Перекрывает настройки под символ.')

grp_det = 'Детекция OB (ручной резерв)'
_swing_n        = input.int(5,     'Длина свинга',                  minval=2,  maxval=30,  group=grp_det)
_disp_atr_mult  = input.float(0.8, 'Мин. смещение (×ATR)',      step=0.1,  minval=0.3, group=grp_det)
_disp_body_pct  = input.float(50,  'Мин. тело/диапазон %',             step=5,    minval=30,  group=grp_det)
_min_grade      = input.string('B','Мин. грейд',                     options=['A+','A','B','C'], group=grp_det)
ob_lookback     = input.int(6,     'Поиск OB (баров назад)',            minval=2,  maxval=15,  group=grp_det)
expire_bars     = input.int(300,   'Срок жизни OB (баров)',                  minval=10,             group=grp_det)

grp_sweep = 'Классификация сбора ликвидности (Sweep)'
use_sweep      = input.bool(true, 'Требовать тип sweep ≥ порога', group=grp_sweep)
min_sweep_type = input.string('MAJOR', 'Мин. тип sweep', options=['MINOR','MAJOR','FLUSH','GRIND'], group=grp_sweep,
     tooltip='MINOR (тень<0.5×ATR) / MAJOR (0.5-1.0) / FLUSH (>1.0) / GRIND (несколько баров)')

grp_vac = 'Объёмный вакуум'
use_vacuum     = input.bool(true,  'Требовать объёмный вакуум',          group=grp_vac)
vac_lookback   = input.int(5,      'Окно вакуума (баров)',         minval=2, maxval=20, group=grp_vac)
vac_sma_len    = input.int(50,     'Длина SMA объёма',                 minval=20, group=grp_vac)
vac_thresh     = input.float(0.7,  'Порог вакуума (× SMA)',       minval=0.3, maxval=1.0, step=0.05, group=grp_vac)

grp_compress = 'Зона сжатия'
use_compress   = input.bool(true,  'Требовать зону сжатия',       group=grp_compress)
compress_len   = input.int(20,     'Окно сжатия',           minval=5, maxval=100, group=grp_compress)
compress_max_atr = input.float(6.0,'Макс. диапазон / ATR',          step=0.5, minval=2.0, maxval=15.0, group=grp_compress)

grp_ust = 'Score конфлюэнса (DER+AMVS+VRI+COFP+KP)'
use_ust_gate   = input.bool(true,  'Требовать Score ≥ порога', group=grp_ust)
ust_min_score  = input.int(70,     'Мин. Score конфлюэнса (0-100)',  minval=0, maxval=100, group=grp_ust)
ust_der_len    = input.int(14,     'DER: окно',                  minval=5, group=grp_ust)
ust_mom_len    = input.int(10,     'AMVS: длина моментума',          minval=3, group=grp_ust)
ust_vri_len    = input.int(50,     'VRI: окно перцентиля ATR',     minval=20, group=grp_ust)
ust_cofp_len   = input.int(20,     'COFP: окно ордер-флоу',        minval=5, group=grp_ust)

grp_gate = 'Мультитаймфрейм-гейт (5 признаков)'
use_gate       = input.bool(true,  'Включить мультитаймфрейм-гейт',           group=grp_gate)
gate_min       = input.int(3,      'Мин. score гейта (0..5)',  minval=0, maxval=5, group=grp_gate)
gate_hma15_tf  = input.timeframe('15', 'HMA ТФ 1', group=grp_gate)
gate_hma18_tf  = input.timeframe('60', 'HMA ТФ старший', group=grp_gate, tooltip='ФИКС: было 18m (нестандарт, без анти-MM смысла). Заменено на стандартный старший ТФ.')
gate_lf1_tf    = input.timeframe('5',  'LF1 (ret5)', group=grp_gate)
gate_lf2_tf    = input.timeframe('15', 'LF2 (ret5)', group=grp_gate, tooltip='ФИКС: было 7m. Используй реально независимый ТФ, а не почти-копию 5m.')
gate_lf3_tf    = input.timeframe('30', 'LF3 (ret5)', group=grp_gate, tooltip='ФИКС: было 8m. Используй реально независимый ТФ.')
gate_hma_len   = input.int(20, 'Длина HMA', minval=4, group=grp_gate)

grp_risk = 'Риск (масштаб по VRI)'
_sl_atr_mult   = input.float(0.5, 'SL (×ATR за низом OB)', step=0.1, minval=0.1, maxval=2.0, group=grp_risk)
entry_frac     = input.float(0.5, 'Уровень входа в зоне (0=край, 0.5=середина, 1=дальний край)',
     minval=0.0, maxval=1.0, step=0.05, group=grp_risk,
     tooltip='Где в зоне OB ставится вход. 0.0 = ближний край (чаще срабатывает, цена хуже, стоп дальше). 0.5 = середина/mid (реже, цена лучше, R:R лучше — рекомендуется для funded). Сигнал отправляется в момент, когда цена реально касается этого уровня — лимитник всегда исполним.')
use_vri_scale  = input.bool(true, 'SL/TP масштаб по VRI', group=grp_risk,
     tooltip='Множитель SL по VRI: высокая вол. → шире SL, низкая → уже SL.')

grp_vis = 'Визуал'
max_active     = input.int(3,     'Макс. активных OB', minval=1,  maxval=8,  group=grp_vis)
show_dash      = input.bool(true, 'Панель',     group=grp_vis)
show_stats     = input.bool(true, 'Таблица статистики (сырой счётчик)', group=grp_vis,
     tooltip='Грубый счётчик срабатываний TP/SL на видимой истории. ЭТО НЕ БЭКТЕСТ: без комиссий, слиппеджа, на предположениях о fill. Для ориентира при настройке, не для оценки прибыльности.')
show_trade_lvls= input.bool(true, 'Постоянные линии Entry/SL/TP', group=grp_vis)
lbl_offset     = input.int(20,    'Смещение меток по X', minval=1, maxval=100, group=grp_vis)
col_bull       = input.color(color.new(#089981, 0),'Бычий',     group=grp_vis)
col_bear       = input.color(color.new(#f23645, 0),'Медвежий',     group=grp_vis)
sl_color       = input.color(color.new(#C53F3F, 0),'Линия SL',     group=grp_vis)
entry_color    = input.color(color.new(#808080, 0),'Линия входа',  group=grp_vis)
tp1_color      = input.color(color.new(#228B22, 0),'Линия TP1',    group=grp_vis)
tp2_color      = input.color(color.new(#FF4500, 0),'Линия TP2',    group=grp_vis)
tp3_color      = input.color(color.new(#4169E1, 0),'Линия TP3',    group=grp_vis)

grp_wh = 'Вебхук (parlizz_ssl)'
enableAlerts   = input.bool(true,  'Включить вебхук',   group=grp_wh)
// ── Режим тайминга сигнала ──
signalMode = input.string('Вариант 2: на закрытии бара (без repaint)',
     'Режим тайминга сигнала',
     options=['Вариант 1: внутри бара (точнее, НО repaint)', 'Вариант 2: на закрытии бара (без repaint)'],
     group=grp_wh,
     tooltip='ВАРИАНТ 1 — алерт уходит в момент касания зоны внутри бара. Вход точнее по цене, НО возможен repaint: если бар развернётся до закрытия, сигнал уже отправлен, а условие могло отмениться. Опасно на быстрых барах MNQ.\n\nВАРИАНТ 2 (по умолчанию) — алерт уходит на закрытии бара. Repaint исключён, но сигнал отстаёт на длину бара (до 5 мин на 5m), поэтому цена входа может разойтись с текущей.')
modeIntrabar = signalMode == 'Вариант 1: внутри бара (точнее, НО repaint)'
strategyName   = input.string('parlizz_ob_sniper_v3', 'strategy_name', group=grp_wh)
alertStrength  = input.string('strong', 'strength', options=['strong','regular'], group=grp_wh)
alertQty       = input.int(1, 'quantity', minval=1, maxval=20, group=grp_wh)
reverseClose   = input.bool(true,  'reverse_order_close', group=grp_wh)
sameDirIgnore  = input.bool(true,  'same_direction_ignore', group=grp_wh)
pyramid        = input.bool(false, 'pyramid', group=grp_wh)
orderType      = input.string('LMT', 'order_type', options=['MKT','LMT'], group=grp_wh)
alertOnTp1     = input.bool(true,  'Алерт: достигнут TP1', group=grp_wh)
alertOnTp2     = input.bool(true,  'Алерт: достигнут TP2', group=grp_wh)
alertOnTp3     = input.bool(true,  'Алерт: достигнут TP3', group=grp_wh)
alertOnSl      = input.bool(true,  'Алерт: достигнут SL',  group=grp_wh)

// ═══════════════════════════════════════════════════════════════════════════
// §2. PER-SYMBOL TUNED
// ═══════════════════════════════════════════════════════════════════════════
ps_disp_atr() =>
    t = syminfo.ticker
    str.contains(t, 'MES') ? 0.8 : str.contains(t, 'MNQ') ? 1.2 :
     str.contains(t, 'MYM') ? 1.2 : str.contains(t, 'M2K') ? 1.2 :
     str.contains(t, 'MGC') ? 1.2 : _disp_atr_mult

ps_body_pct() =>
    t = syminfo.ticker
    str.contains(t, 'MES') ? 50.0 : str.contains(t, 'MNQ') ? 60.0 :
     str.contains(t, 'MYM') ? 70.0 : str.contains(t, 'M2K') ? 50.0 :
     str.contains(t, 'MGC') ? 40.0 : _disp_body_pct

ps_sl_atr() =>
    t = syminfo.ticker
    str.contains(t, 'MES') ? 0.3 : str.contains(t, 'MNQ') ? 0.8 :
     str.contains(t, 'MYM') ? 0.5 : str.contains(t, 'M2K') ? 0.3 :
     str.contains(t, 'MGC') ? 0.5 : _sl_atr_mult

// ═══════════════════════════════════════════════════════════════════════════
// §3. CORE INDICATORS
// ═══════════════════════════════════════════════════════════════════════════
// Режим тайминга: bar_ready решает, ждать ли закрытия бара.
// Вариант 1 (intrabar): true всегда → расчёт и алерт внутри бара (repaint).
// Вариант 2 (на закрытии): только barstate.isconfirmed → без repaint.
bar_ready = modeIntrabar ? true : barstate.isconfirmed
atr14   = ta.atr(14)
ema_v   = ta.ema(close, 200)
vol_sma = ta.sma(volume, 20)

// Swings
ph = ta.pivothigh(high, _swing_n, _swing_n)
pl = ta.pivotlow(low,   _swing_n, _swing_n)
var float sh1 = na, var float sh2 = na
var float sl1 = na, var float sl2 = na
if not na(ph)
    sh2 := sh1
    sh1 := ph
if not na(pl)
    sl2 := sl1
    sl1 := pl

// ═══════════════════════════════════════════════════════════════════════════
// §4. AUTO-CALIBRATION (from Liquidity Echo)
// ═══════════════════════════════════════════════════════════════════════════
ac_window = 100
body_abs_raw = math.abs(close - open)
wick_total = (high - math.max(open, close)) + (math.min(open, close) - low)
wb_ratio_now = body_abs_raw > 0 ? wick_total / body_abs_raw : 1.0
wb_ratio_avg = ta.sma(wb_ratio_now, ac_window)
vol_mean = ta.sma(volume, ac_window)
vol_std = ta.stdev(volume, ac_window)
vol_cv = vol_mean > 0 ? vol_std / vol_mean : 0.0
atr_hi = ta.highest(atr14, ac_window)
atr_lo = ta.lowest(atr14, ac_window)
atr_pct = atr_hi - atr_lo > 0 ? (atr14 - atr_lo) / (atr_hi - atr_lo) : 0.5

// Auto-derived disp_atr_mult: higher wick/body → require more displacement
auto_disp_atr = math.max(0.6, math.min(1.5, 0.8 + (wb_ratio_avg - 1.5) * 0.2))
auto_body_pct = math.max(40.0, math.min(70.0, 50.0 + atr_pct * 20.0))

disp_atr_mult = useAutoCal ? auto_disp_atr : (usePerSym ? ps_disp_atr() : _disp_atr_mult)
disp_body_pct = useAutoCal ? auto_body_pct : (usePerSym ? ps_body_pct() : _disp_body_pct)
sl_atr        = usePerSym ? ps_sl_atr() : _sl_atr_mult
min_grade     = _min_grade
swing_n       = _swing_n

// ═══════════════════════════════════════════════════════════════════════════
// §5. UST CONFLUENCE SCORE (DER + AMVS + VRI + COFP)
// ═══════════════════════════════════════════════════════════════════════════
// DER: Directional Efficiency Ratio = |sum changes| / sum |changes|, in [0,1]
sum_change = close - close[ust_der_len]
// FIX #3: honest sum over the SAME window as sum_change (was sma*len → window mismatch, der could exceed 1)
sum_abs = math.sum(math.abs(ta.change(close)), ust_der_len)
der = sum_abs > 0 ? math.min(1.0, math.abs(sum_change) / sum_abs) : 0.0
der_score = der * 100  // [0, 100]

// AMVS: Adaptive Momentum / Volatility Scaled
mom_raw = (close - close[ust_mom_len]) / ust_mom_len
amvs = atr14 > 0 ? mom_raw / atr14 : 0.0
amvs_score = math.min(100.0, math.max(0.0, 50.0 + amvs * 25.0))  // center at 50

// VRI: Volatility Regime Index (ATR percentile)
vri_score = atr_pct * 100  // [0, 100]

// COFP: Composite Order Flow Proxy
bar_dir = close > open ? 1 : close < open ? -1 : 0
flow_raw = bar_dir * volume * body_abs_raw / (high - low + syminfo.mintick)
flow_smooth = ta.sma(flow_raw, ust_cofp_len)
flow_max = ta.highest(math.abs(flow_smooth), ust_cofp_len * 3)
cofp_norm = flow_max > 0 ? flow_smooth / flow_max : 0.0
cofp_score = math.min(100.0, math.max(0.0, 50.0 + cofp_norm * 50.0))  // [0, 100]

// ── SECTOR 1: KINETIC PULSE — volume-weighted momentum + Fisher Transform ──
// Public techniques, every line transparent. Coefficients are an engineering
// starting point (sqrt vol-weight, Fisher *20 scale) — calibrate on your data.
kp_len    = input.int(14, 'KP: длина моментума', minval=5, maxval=30, group=grp_ust)
kp_volW   = vol_sma > 0 ? math.sqrt(volume / vol_sma) : 1.0      // sqrt damps volume spikes
kp_chg    = ta.change(close)
// ── СЕКТОР 2: адаптивный период KP через blend быстрой/медленной EMA по перцентилю ATR ──
useAdaptiveKP = input.bool(true, 'KP: адаптивный период', group=grp_ust,
     tooltip='Высокая вол. → быстрее (короткая EMA), низкая → медленнее (длинная). Смешивает две фикс. EMA, без динамической длины.')
kp_len_fast = math.max(3, int(kp_len * 0.6))   // быстрый край ~60% базы
kp_len_slow = int(kp_len * 1.4)                // медленный край ~140% базы
kp_up_raw = (kp_chg > 0 ?  kp_chg : 0.0) * kp_volW
kp_dn_raw = (kp_chg < 0 ? -kp_chg : 0.0) * kp_volW
kp_up_f = ta.ema(kp_up_raw, kp_len_fast)
kp_up_s = ta.ema(kp_up_raw, kp_len_slow)
kp_dn_f = ta.ema(kp_dn_raw, kp_len_fast)
kp_dn_s = ta.ema(kp_dn_raw, kp_len_slow)
// blend: atr_pct=1 (вол. высокая) → fast; atr_pct=0 (штиль) → slow; выкл → 0.5 (≈база)
kp_w_fast = useAdaptiveKP ? atr_pct : 0.5
kp_up     = kp_up_f * kp_w_fast + kp_up_s * (1 - kp_w_fast)
kp_dn     = kp_dn_f * kp_w_fast + kp_dn_s * (1 - kp_w_fast)
kp_rs     = kp_dn > 0 ? kp_up / kp_dn : 0.0
kp_rsi    = 100 - 100 / (1 + kp_rs)                              // VW-RSI 0..100
kp_norm   = math.max(-0.999, math.min(0.999, 2 * (kp_rsi/100) - 1))
kp_fish   = 0.5 * math.log((1 + kp_norm) / (1 - kp_norm))        // Ehlers Fisher
kp_score  = math.min(100.0, math.max(0.0, 50.0 + kp_fish * 20.0))
kp_bull   = kp_rsi > 50                                          // direction (unused for now)

// ── СЕКТОР 3: мульти-осцилляторные дивергенции (без repaint) ──
// Пивот подтверждается через div_pivot_n баров. Значения осцилляторов берутся
// на баре пивота (сдвиг [div_pivot_n]), поэтому дивергенция фиксируется только
// на УЖЕ подтверждённом пивоте — никакого перерисовывания.
grp_div = 'Дивергенции (KP + CCI + Stoch)'
use_div      = input.bool(true,  'Учитывать дивергенции', group=grp_div)
div_pivot_n  = input.int(5, 'Длина пивота (подтв. вправо)', minval=2, maxval=15, group=grp_div,
     tooltip='Пивот подтверждается через N баров. Больше N = надёжнее, но позже. Без repaint.')
div_min_osc  = input.int(2, 'Мин. осцилляторов в согласии (1..3)', minval=1, maxval=3, group=grp_div)
div_bonus_pts= input.int(8, 'Бонус к Score за дивергенцию', minval=0, maxval=20, group=grp_div,
     tooltip='Сколько очков добавляется к направленному confluence при дивергенции в нужную сторону.')

div_cci   = ta.cci(close, 20)
div_stoch = ta.stoch(close, high, low, 14)

ph_px = ta.pivothigh(high, div_pivot_n, div_pivot_n)
pl_px = ta.pivotlow(low,   div_pivot_n, div_pivot_n)

var float prev_pl_price = na, var float prev_pl_kp = na, var float prev_pl_cci = na, var float prev_pl_stoch = na
var float prev_ph_price = na, var float prev_ph_kp = na, var float prev_ph_cci = na, var float prev_ph_stoch = na

bool bull_div = false
bool bear_div = false

if not na(pl_px)
    float kp_at    = kp_rsi[div_pivot_n]
    float cci_at   = div_cci[div_pivot_n]
    float stoch_at = div_stoch[div_pivot_n]
    if not na(prev_pl_price) and not na(kp_at)
        bool d_kp    = pl_px < prev_pl_price and kp_at    > prev_pl_kp
        bool d_cci   = pl_px < prev_pl_price and cci_at   > prev_pl_cci
        bool d_stoch = pl_px < prev_pl_price and stoch_at > prev_pl_stoch
        int agree = (d_kp ? 1 : 0) + (d_cci ? 1 : 0) + (d_stoch ? 1 : 0)
        bull_div := use_div and agree >= div_min_osc
    prev_pl_price := pl_px
    prev_pl_kp    := kp_at
    prev_pl_cci   := cci_at
    prev_pl_stoch := stoch_at

if not na(ph_px)
    float kp_at    = kp_rsi[div_pivot_n]
    float cci_at   = div_cci[div_pivot_n]
    float stoch_at = div_stoch[div_pivot_n]
    if not na(prev_ph_price) and not na(kp_at)
        bool d_kp    = ph_px > prev_ph_price and kp_at    < prev_ph_kp
        bool d_cci   = ph_px > prev_ph_price and cci_at   < prev_ph_cci
        bool d_stoch = ph_px > prev_ph_price and stoch_at < prev_ph_stoch
        int agree = (d_kp ? 1 : 0) + (d_cci ? 1 : 0) + (d_stoch ? 1 : 0)
        bear_div := use_div and agree >= div_min_osc
    prev_ph_price := ph_px
    prev_ph_kp    := kp_at
    prev_ph_cci   := cci_at
    prev_ph_stoch := stoch_at

// Дивергенция живёт несколько баров после подтверждения (иначе мигнёт на 1 баре)
var int bull_div_age = 999, var int bear_div_age = 999
bull_div_age := bull_div ? 0 : bull_div_age + 1
bear_div_age := bear_div ? 0 : bear_div_age + 1
bool bull_div_active = bull_div_age <= div_pivot_n * 2
bool bear_div_active = bear_div_age <= div_pivot_n * 2

// ── Confluence weights (defaults = starting point, NOT optimum; normalized) ──
w_der  = input.float(0.25, 'Вес DER',  minval=0, maxval=1, step=0.05, group=grp_ust)
w_amvs = input.float(0.15, 'Вес AMVS', minval=0, maxval=1, step=0.05, group=grp_ust)
w_vri  = input.float(0.15, 'Вес VRI',  minval=0, maxval=1, step=0.05, group=grp_ust)
w_cofp = input.float(0.25, 'Вес COFP', minval=0, maxval=1, step=0.05, group=grp_ust)
w_kp   = input.float(0.20, 'Вес KP',   minval=0, maxval=1, step=0.05, group=grp_ust)
w_sum  = w_der + w_amvs + w_vri + w_cofp + w_kp

// Confluence: normalized weighted average → always stays in 0..100
confluence_score = w_sum > 0 ? (der_score*w_der + amvs_score*w_amvs + vri_score*w_vri + cofp_score*w_cofp + kp_score*w_kp) / w_sum : 0.0

// Direction-aware confluence: bullish = require positive amvs + cofp (+ divergence bonus)
f_confluence_dir(bool is_bull) =>
    bool dir_amvs = is_bull ? amvs > 0 : amvs < 0
    bool dir_cofp = is_bull ? cofp_norm > 0 : cofp_norm < 0
    int dir_bonus = (dir_amvs ? 5 : 0) + (dir_cofp ? 5 : 0)
    // СЕКТОР 3: бонус за дивергенцию в нужную сторону
    bool dir_div = is_bull ? bull_div_active : bear_div_active
    int div_bonus = dir_div ? div_bonus_pts : 0
    math.min(100.0, confluence_score + dir_bonus + div_bonus)

// ═══════════════════════════════════════════════════════════════════════════
// §6. VOLUME VACUUM (from Liquidity Echo)
// ═══════════════════════════════════════════════════════════════════════════
vol_recent_avg = ta.sma(volume, vac_lookback)
vol_baseline = ta.sma(volume, vac_sma_len)
vacuum_active = not use_vacuum or (vol_baseline > 0 and vol_recent_avg < vol_baseline * vac_thresh)

// ═══════════════════════════════════════════════════════════════════════════
// §7. COMPRESSION ZONE (from Liquidity Echo)
// ═══════════════════════════════════════════════════════════════════════════
range_hi = ta.highest(high, compress_len)
range_lo = ta.lowest(low, compress_len)
range_atr_ratio = atr14 > 0 ? (range_hi - range_lo) / atr14 : 99
in_compression = not use_compress or range_atr_ratio < compress_max_atr

// ═══════════════════════════════════════════════════════════════════════════
// §8. SWEEP CLASSIFICATION (from Liquidity Echo)
// ═══════════════════════════════════════════════════════════════════════════
// Bullish sweep: wick below recent low + close back above
recent_low_swept = ta.lowest(low, 20)[1]  // prior bars' lowest (not including current)
recent_high_swept = ta.highest(high, 20)[1]

wick_below = recent_low_swept - low  // positive if low pierced below
wick_above = high - recent_high_swept
wick_atr_b = atr14 > 0 ? wick_below / atr14 : 0
wick_atr_a = atr14 > 0 ? wick_above / atr14 : 0

bull_pierced = low < recent_low_swept and close > recent_low_swept
bear_pierced = high > recent_high_swept and close < recent_high_swept

// Sweep type classification
f_sweep_type(float wick_atr) =>
    wick_atr >= 1.0 ? 3 :       // FLUSH
     wick_atr >= 0.5 ? 2 :       // MAJOR
     wick_atr >= 0.1 ? 1 : 0     // MINOR

bull_sweep_type = bull_pierced ? f_sweep_type(wick_atr_b) : 0
bear_sweep_type = bear_pierced ? f_sweep_type(wick_atr_a) : 0

// Grind sweep: 3+ bars closing beyond level, then return
grind_bull = (low[2] < recent_low_swept and low[1] < recent_low_swept and close > recent_low_swept)
grind_bear = (high[2] > recent_high_swept and high[1] > recent_high_swept and close < recent_high_swept)
if grind_bull
    bull_sweep_type := 4
if grind_bear
    bear_sweep_type := 4

f_min_sweep_num() =>
    min_sweep_type == 'MINOR' ? 1 : min_sweep_type == 'MAJOR' ? 2 :
     min_sweep_type == 'FLUSH' ? 3 : 4

f_sweep_name(int n) =>
    n == 4 ? 'GRIND' : n == 3 ? 'FLUSH' : n == 2 ? 'MAJOR' : n == 1 ? 'MINOR' : 'NONE'

bull_sweep_ok = not use_sweep or bull_sweep_type >= f_min_sweep_num()
bear_sweep_ok = not use_sweep or bear_sweep_type >= f_min_sweep_num()

// ═══════════════════════════════════════════════════════════════════════════
// §9. DISPLACEMENT + BOS (OB Sniper core)
// ═══════════════════════════════════════════════════════════════════════════
float body_abs = math.abs(close - open)
float range_abs = high - low
float body_pct = range_abs > 0 ? body_abs / range_abs * 100.0 : 0.0
bool is_disp_bull = bar_ready and body_abs >= atr14 * disp_atr_mult and body_pct >= disp_body_pct and close > open
bool is_disp_bear = bar_ready and body_abs >= atr14 * disp_atr_mult and body_pct >= disp_body_pct and close < open

bool bull_bos = is_disp_bull and not na(sh1) and close > sh1
bool bear_bos = is_disp_bear and not na(sl1) and close < sl1

bool fvg_bull = low > high[2]
bool fvg_bear = high < low[2]

// ═══════════════════════════════════════════════════════════════════════════
// §10. CROSS-TF GATE (5 features) — kept from v2
// ═══════════════════════════════════════════════════════════════════════════
f_hma(float src, simple int n) =>
    half = math.max(1, n / 2)
    sq   = math.max(1, int(math.round(math.sqrt(n))))
    ta.wma(2 * ta.wma(src, half) - ta.wma(src, n), sq)

g_hma15_c = request.security(syminfo.tickerid, gate_hma15_tf, close, lookahead=barmerge.lookahead_off)
g_hma15_v = request.security(syminfo.tickerid, gate_hma15_tf, f_hma(close, gate_hma_len), lookahead=barmerge.lookahead_off)
g_hma18_c = request.security(syminfo.tickerid, gate_hma18_tf, close, lookahead=barmerge.lookahead_off)
g_hma18_v = request.security(syminfo.tickerid, gate_hma18_tf, f_hma(close, gate_hma_len), lookahead=barmerge.lookahead_off)
g_r5_lf1  = request.security(syminfo.tickerid, gate_lf1_tf,   math.sign(close - close[5]), lookahead=barmerge.lookahead_off)
g_r5_lf2  = request.security(syminfo.tickerid, gate_lf2_tf,   math.sign(close - close[5]), lookahead=barmerge.lookahead_off)
g_r5_lf3  = request.security(syminfo.tickerid, gate_lf3_tf,   math.sign(close - close[5]), lookahead=barmerge.lookahead_off)

f_gate_score(bool is_bull) =>
    int ds = is_bull ? 1 : -1
    int sc = 0
    if not na(g_hma15_v) and not na(g_hma15_c)
        if (g_hma15_c > g_hma15_v ? 1 : -1) == ds
            sc += 1
    if not na(g_hma18_v) and not na(g_hma18_c)
        if (g_hma18_c > g_hma18_v ? 1 : -1) == ds
            sc += 1
    if not na(g_r5_lf1) and int(g_r5_lf1) == ds
        sc += 1
    if not na(g_r5_lf2) and int(g_r5_lf2) == ds
        sc += 1
    if not na(g_r5_lf3) and int(g_r5_lf3) == ds
        sc += 1
    sc

// ═══════════════════════════════════════════════════════════════════════════
// §11. DQS (grade)
// ═══════════════════════════════════════════════════════════════════════════
f_clamp(float v, float lo, float hi) => math.min(math.max(v, lo), hi)
f_dqs(float body_a, float range_a, float atr_v, bool has_fvg, float vol_now, float vol_avg, float sweep_depth_atr) =>
    float c1 = f_clamp(body_a / math.max(atr_v, syminfo.mintick) / 2.0, 0.0, 1.0)
    float c2 = range_a > 0 ? f_clamp(body_a / range_a, 0.0, 1.0) : 0.0
    float c3 = has_fvg ? 1.0 : 0.0
    float c4 = not na(vol_avg) and vol_avg > 0 ? f_clamp(vol_now / vol_avg / 2.0, 0.0, 1.0) : 0.5
    float c5 = f_clamp(sweep_depth_atr / 1.0, 0.0, 1.0)
    30.0 * c1 + 25.0 * c2 + 20.0 * c3 + 15.0 * c4 + 10.0 * c5

f_grade(float dqs) => dqs >= 85 ? 'A+' : dqs >= 70 ? 'A' : dqs >= 55 ? 'B' : 'C'
f_grade_num(string g) => g == 'A+' ? 4 : g == 'A' ? 3 : g == 'B' ? 2 : 1
f_min_grade_num() => min_grade == 'A+' ? 4 : min_grade == 'A' ? 3 : min_grade == 'B' ? 2 : 1

// ═══════════════════════════════════════════════════════════════════════════
// §12. OB STORAGE
// ═══════════════════════════════════════════════════════════════════════════
var float[]  ob_top   = array.new_float()
var float[]  ob_bot   = array.new_float()
var int[]    ob_bar   = array.new_int()
var bool[]   ob_bull  = array.new_bool()
var bool[]   ob_mit   = array.new_bool()
var float[]  ob_dqs   = array.new_float()
var string[] ob_grade = array.new_string()
var box[]    ob_box   = array.new_box()
var int[]    ob_sweep = array.new_int()
var float[]  ob_conf  = array.new_float()  // FIX #2: store directional confluence per-OB

f_del(int idx) =>
    box.delete(array.get(ob_box, idx))
    array.remove(ob_top, idx)
    array.remove(ob_bot, idx)
    array.remove(ob_bar, idx)
    array.remove(ob_bull, idx)
    array.remove(ob_mit, idx)
    array.remove(ob_dqs, idx)
    array.remove(ob_grade, idx)
    array.remove(ob_box, idx)
    array.remove(ob_sweep, idx)
    array.remove(ob_conf, idx)

// ═══════════════════════════════════════════════════════════════════════════
// §13. OB CREATION (with ALL extracted filters)
// ═══════════════════════════════════════════════════════════════════════════
f_try_ob(bool is_bull, bool has_fvg) =>
    // ─ Standard filters
    bool trend_ok = is_bull ? close > ema_v : close < ema_v
    bool gate_ok  = not use_gate or f_gate_score(is_bull) >= gate_min

    // ─ EXTRACTED filters
    bool sweep_ok = is_bull ? bull_sweep_ok : bear_sweep_ok
    bool vacuum_ok = vacuum_active
    bool compress_ok = in_compression
    bool ust_ok = not use_ust_gate or f_confluence_dir(is_bull) >= ust_min_score

    if trend_ok and gate_ok and sweep_ok and vacuum_ok and compress_ok and ust_ok
        int found = -1
        for j = 1 to ob_lookback
            if j > bar_index
                break
            if is_bull and close[j] < open[j]
                found := j
                break
            if not is_bull and close[j] > open[j]
                found := j
                break

        if found > 0
            int sw_type = is_bull ? bull_sweep_type : bear_sweep_type
            float sweep_depth_atr = is_bull ? wick_atr_b : wick_atr_a
            float dqs = f_dqs(body_abs, range_abs, atr14, has_fvg, volume, vol_sma, sweep_depth_atr)
            string grade = f_grade(dqs)
            float conf_dir = f_confluence_dir(is_bull)  // FIX #2: directional score, captured at creation

            if f_grade_num(grade) >= f_min_grade_num()
                float t = high[found]
                float b = low[found]
                color pc = is_bull ? col_bull : col_bear
                int alpha = grade == 'A+' ? 55 : grade == 'A' ? 68 : grade == 'B' ? 78 : 88
                int bw    = grade == 'A+' ? 3  : grade == 'A' ? 2  : 1
                box nb = box.new(bar_index - found, t, bar_index + 20, b,
                     bgcolor=color.new(pc, alpha), border_color=pc, border_width=bw)
                box.set_text(nb, grade + ' ' + f_sweep_name(sw_type))
                box.set_text_color(nb, color.new(pc, 20))
                box.set_text_size(nb, size.small)

                array.push(ob_top, t)
                array.push(ob_bot, b)
                array.push(ob_bar, bar_index - found)
                array.push(ob_bull, is_bull)
                array.push(ob_mit, false)
                array.push(ob_dqs, dqs)
                array.push(ob_grade, grade)
                array.push(ob_box, nb)
                array.push(ob_sweep, sw_type)
                array.push(ob_conf, conf_dir)
    true

if bull_bos
    f_try_ob(true, fvg_bull)
if bear_bos
    f_try_ob(false, fvg_bear)

// ═══════════════════════════════════════════════════════════════════════════
// §14. OB MGMT — mitigation, invalidation
// ═══════════════════════════════════════════════════════════════════════════
var int    mit_total     = 0
bool       mit_long_now  = false
bool       mit_short_now = false
string     mit_grade_out = ''
float      mit_dqs_out   = 0.0
int        mit_sweep_out = 0

var float last_entry = na, var float last_sl    = na
var float last_tp1   = na, var float last_tp2   = na, var float last_tp3   = na
var string last_dir  = na, var string last_grade = na
var int last_sweep_type = 0
var float last_conf = na  // FIX #2: directional confluence at signal time
var bool tp1_hit = false, var bool tp2_hit = false, var bool tp3_hit = false, var bool sl_hit  = false
var bool trade_open = false

// VRI-scaled SL multiplier
sl_mult_effective = use_vri_scale ? sl_atr * (0.7 + atr_pct * 0.6) : sl_atr

if bar_ready and array.size(ob_top) > 0
    for i = array.size(ob_top) - 1 to 0
        if i >= array.size(ob_top)
            continue
        float t = array.get(ob_top, i)
        float b = array.get(ob_bot, i)
        bool is_bull = array.get(ob_bull, i)
        bool is_mit = array.get(ob_mit, i)
        int age = bar_index - array.get(ob_bar, i)

        if not is_mit
            box.set_right(array.get(ob_box, i), bar_index + 20)
            // ── Уровень входа по ползунку entry_frac ──
            // Лонг: от верха (t) вниз внутрь зоны; шорт: от низа (b) вверх внутрь зоны.
            // entry_frac=0 → ближний край, 0.5 → mid, 1.0 → дальний край.
            float oh = t - b                              // высота зоны
            float entry_lvl = is_bull ? t - oh * entry_frac : b + oh * entry_frac
            // ── Armed-логика: сигнал ждёт, пока цена РЕАЛЬНО коснётся уровня входа ──
            // Тогда лимитник на entry_lvl исполним мгновенно, без "висящих в космосе".
            bool touched = false
            if is_bull and low <= entry_lvl and close > b
                touched := true
            if not is_bull and high >= entry_lvl and close < t
                touched := true

            // БАГ 4 ФИКС: не открываем новую сделку, пока предыдущая ещё открыта.
            // Иначе старая сделка молча затиралась (наложение позиций = двойной риск).
            // OB остаётся непомеченным и может сработать позже, когда сделка закроется.
            if touched and not trade_open
                array.set(ob_mit, i, true)
                mit_total += 1
                if is_bull
                    mit_long_now := true
                else
                    mit_short_now := true
                mit_grade_out := array.get(ob_grade, i)
                mit_dqs_out := array.get(ob_dqs, i)
                mit_sweep_out := array.get(ob_sweep, i)
                last_conf := array.get(ob_conf, i)  // FIX #2: directional score for webhook

                float sl_px = is_bull ? b - atr14 * sl_mult_effective : t + atr14 * sl_mult_effective
                // БАГ 1 ФИКС: TP считаются от РЕАЛЬНОГО риска (вход→стоп), а не от высоты зоны.
                // Иначе подписи "1:1/1:2/1:3" врут — реальный R:R зависел бы от entry_frac и ATR-буфера.
                float real_risk = math.abs(entry_lvl - sl_px)
                float tp1 = is_bull ? entry_lvl + real_risk * 1.0 : entry_lvl - real_risk * 1.0
                float tp2 = is_bull ? entry_lvl + real_risk * 2.0 : entry_lvl - real_risk * 2.0
                float tp3 = is_bull ? entry_lvl + real_risk * 3.0 : entry_lvl - real_risk * 3.0

                last_entry := entry_lvl
                last_sl    := sl_px
                last_tp1   := tp1
                last_tp2   := tp2
                last_tp3   := tp3
                last_dir   := is_bull ? 'LONG' : 'SHORT'
                last_grade := mit_grade_out
                last_sweep_type := mit_sweep_out
                trade_open := true
                tp1_hit := false
                tp2_hit := false
                tp3_hit := false
                sl_hit  := false

                box.set_bgcolor(array.get(ob_box, i), color.new(color.gray, 92))
                box.set_text(array.get(ob_box, i), mit_grade_out + ' ✓')

            if age > expire_bars
                f_del(i)
                continue

        // FIX #4: re-read mit flag fresh (it may have been set above this bar);
        // chain invalidation so a single iteration never calls f_del twice on a shifted index
        if i < array.size(ob_top) and not array.get(ob_mit, i)
            float bb = array.get(ob_bot, i)
            float tt = array.get(ob_top, i)
            bool ib = array.get(ob_bull, i)
            if ib and close < bb and close[1] < bb
                f_del(i)
            else if not ib and close > tt and close[1] > tt
                f_del(i)

// Track TP/SL hits
// БАГ 2 ФИКС: на одном баре цена может пройти и SL, и TP (большой бар).
// Порядок внутри бара неизвестен → консервативно считаем SL первым.
// Если SL сработал — TP в этом же баре не засчитываем (не завышаем результат).
var int cnt_tp1 = 0, var int cnt_tp2 = 0, var int cnt_tp3 = 0, var int cnt_sl = 0
if trade_open and not na(last_entry) and barstate.isconfirmed
    bool is_long = last_dir == 'LONG'
    if is_long
        if not sl_hit and low <= last_sl
            sl_hit := true
            cnt_sl += 1
            trade_open := false
        else
            if not tp1_hit and high >= last_tp1
                tp1_hit := true
                cnt_tp1 += 1
            if not tp2_hit and high >= last_tp2
                tp2_hit := true
                cnt_tp2 += 1
            if not tp3_hit and high >= last_tp3
                tp3_hit := true
                cnt_tp3 += 1
                trade_open := false
    else
        if not sl_hit and high >= last_sl
            sl_hit := true
            cnt_sl += 1
            trade_open := false
        else
            if not tp1_hit and low <= last_tp1
                tp1_hit := true
                cnt_tp1 += 1
            if not tp2_hit and low <= last_tp2
                tp2_hit := true
                cnt_tp2 += 1
            if not tp3_hit and low <= last_tp3
                tp3_hit := true
                cnt_tp3 += 1
                trade_open := false

// ═══════════════════════════════════════════════════════════════════════════
// §14b. СЕКТОР 4 — Оценка состояния сделки (confidence + машина состояний)
// Аналитика, НЕ управление. Считает "здоровье" открытой позиции по факторам,
// которые уже посчитаны выше. Статус — описание данных, а не команда.
// ═══════════════════════════════════════════════════════════════════════════
grp_state = 'Статус сделки (Сектор 4)'
use_state    = input.bool(true, 'Показывать статус сделки', group=grp_state)
state_smooth = input.int(3, 'Сглаживание confidence (баров EMA)', minval=1, maxval=10, group=grp_state)

var float confidence = 50.0  // 0..100, нейтраль = 50
var string trade_state = 'НЕТ СДЕЛКИ'

if trade_open and not na(last_entry) and not na(last_sl) and barstate.isconfirmed
    bool is_long = last_dir == 'LONG'
    // ── Фактор 1: моментум согласован с направлением (KP) ──
    float f_mom = (is_long ? kp_bull : not kp_bull) ? 25.0 : -25.0
    // ── Фактор 2: позиция по R (сколько прошли к цели в долях риска) ──
    float risk_dist = math.abs(last_entry - last_sl)
    float prog = risk_dist > 0 ? (is_long ? close - last_entry : last_entry - close) / risk_dist : 0.0
    float f_pos = math.max(-20.0, math.min(20.0, prog * 15.0))   // +R → плюс, -R → минус
    // ── Фактор 3: HTF-гейт всё ещё за нас ──
    int gs_now = f_gate_score(is_long)
    float f_gate = (gs_now - gate_min) * 6.0
    f_gate := math.max(-18.0, math.min(18.0, f_gate))
    // ── Фактор 4: близость к стопу (в ATR) ──
    float sl_dist_atr = atr14 > 0 ? math.abs(close - last_sl) / atr14 : 2.0
    float f_sl = sl_dist_atr < 0.3 ? -25.0 : sl_dist_atr < 0.7 ? -10.0 : sl_dist_atr > 1.5 ? 8.0 : 0.0

    float raw_conf = 50.0 + f_mom + f_pos + f_gate + f_sl
    raw_conf := math.max(0.0, math.min(100.0, raw_conf))
    confidence := ta.ema(raw_conf, state_smooth)

    // ── Машина состояний с гистерезисом (БАГ 3 ФИКС: без мёртвых зон) ──
    // Каждая зона confidence имеет явное состояние. Гистерезис — через буфер ±3
    // вокруг порогов, чтобы не мигало на границе. Логика: определяем целевое
    // состояние по confidence, но переход требует выхода за буфер.
    string target = confidence >= 65 ? 'ФАКТОРЫ ЗА' :
                     confidence >= 45 ? 'НЕЙТРАЛЬНО' :
                     confidence >= 28 ? 'ФАКТОРЫ ОСЛАБЛИ' : 'ФАКТОРЫ ПРОТИВ'
    // Гистерезис: меняем состояние только если confidence ушёл за буфер ±3 от текущей зоны.
    bool can_switch = true
    if trade_state == 'ФАКТОРЫ ЗА' and confidence >= 62
        can_switch := false
    else if trade_state == 'НЕЙТРАЛЬНО' and confidence >= 42 and confidence < 68
        can_switch := false
    else if trade_state == 'ФАКТОРЫ ОСЛАБЛИ' and confidence >= 25 and confidence < 48
        can_switch := false
    else if trade_state == 'ФАКТОРЫ ПРОТИВ' and confidence < 31
        can_switch := false
    if can_switch
        trade_state := target
else if not trade_open
    confidence := 50.0
    trade_state := 'НЕТ СДЕЛКИ'

// Quota
int act = 0
if array.size(ob_top) > 0
    for i = 0 to array.size(ob_top) - 1
        if not array.get(ob_mit, i)
            act += 1
while act > max_active and array.size(ob_top) > 0
    for i = 0 to array.size(ob_top) - 1
        if not array.get(ob_mit, i)
            f_del(i)
            act -= 1
            break

// ═══════════════════════════════════════════════════════════════════════════
// §15. PERSISTENT VISUALS
// ═══════════════════════════════════════════════════════════════════════════
var line  pl_sl  = na, var line  pl_en  = na
var line  pl_tp1 = na, var line  pl_tp2 = na, var line  pl_tp3 = na
var label lb_sl  = na, var label lb_en  = na
var label lb_tp1 = na, var label lb_tp2 = na, var label lb_tp3 = na
var label sig_lb = na

f_clear_levels() =>
    if not na(pl_sl)
        line.delete(pl_sl), line.delete(pl_en), line.delete(pl_tp1), line.delete(pl_tp2), line.delete(pl_tp3)
        label.delete(lb_sl), label.delete(lb_en), label.delete(lb_tp1), label.delete(lb_tp2), label.delete(lb_tp3)
    if not na(sig_lb)
        label.delete(sig_lb)
    true

if show_trade_lvls and (mit_long_now or mit_short_now) and barstate.isconfirmed and not na(last_entry)
    f_clear_levels()
    int rx = bar_index + lbl_offset
    pl_sl  := line.new(bar_index, last_sl,    rx, last_sl,    color=sl_color,    width=2)
    pl_en  := line.new(bar_index, last_entry, rx, last_entry, color=entry_color, width=2)
    pl_tp1 := line.new(bar_index, last_tp1,   rx, last_tp1,   color=tp1_color,   width=2)
    pl_tp2 := line.new(bar_index, last_tp2,   rx, last_tp2,   color=tp2_color,   width=2)
    pl_tp3 := line.new(bar_index, last_tp3,   rx, last_tp3,   color=tp3_color,   width=2)
    lb_sl  := label.new(rx, last_sl,    'SL: '    + str.tostring(last_sl,    format.mintick), style=label.style_label_left, color=sl_color,    textcolor=color.white, size=size.small)
    lb_en  := label.new(rx, last_entry, 'Вход: ' + str.tostring(last_entry, format.mintick), style=label.style_label_left, color=entry_color, textcolor=color.white, size=size.small)
    lb_tp1 := label.new(rx, last_tp1,   'TP1: '   + str.tostring(last_tp1,   format.mintick), style=label.style_label_left, color=tp1_color,   textcolor=color.white, size=size.small)
    lb_tp2 := label.new(rx, last_tp2,   'TP2: '   + str.tostring(last_tp2,   format.mintick), style=label.style_label_left, color=tp2_color,   textcolor=color.white, size=size.small)
    lb_tp3 := label.new(rx, last_tp3,   'TP3: '   + str.tostring(last_tp3,   format.mintick), style=label.style_label_left, color=tp3_color,   textcolor=color.white, size=size.small)
    color st_col = alertStrength == 'strong' ? color.new(#00897b, 0) : color.new(#1565c0, 0)
    sig_lb := label.new(bar_index, last_entry, (last_dir == 'LONG' ? 'LONG ' : 'SHORT ') + str.upper(alertStrength) + ' ' + last_grade + ' ' + f_sweep_name(last_sweep_type),
         style=last_dir == 'LONG' ? label.style_label_up : label.style_label_down,
         color=st_col, textcolor=color.white, size=size.normal)

plotshape(mit_long_now,  'Long fire',  style=shape.triangleup,   location=location.belowbar, color=col_bull, size=size.normal)
plotshape(mit_short_now, 'Short fire', style=shape.triangledown, location=location.abovebar, color=col_bear, size=size.normal)

// ═══════════════════════════════════════════════════════════════════════════
// §16. WEBHOOK JSON (parlizz_ssl + UST/sweep extras)
// ═══════════════════════════════════════════════════════════════════════════
f_entry_json(string dir, string strength, string grade) =>
    '{"strategy_name":"' + strategyName + '"'
     + ',"symbol":"'     + syminfo.ticker + '"'
     + ',"date":"{{timenow}}"'
     + ',"data":"'       + (dir == 'LONG' ? 'buy' : 'sell') + '"'
     + ',"strength":"'   + strength + '"'
     + ',"quantity":'    + str.tostring(alertQty)
     + ',"price":"'      + str.tostring(last_entry) + '"'
     + ',"tp":'          + str.tostring(last_tp1)
     + ',"tp2":'         + str.tostring(last_tp2)
     + ',"tp3":'         + str.tostring(last_tp3)
     + ',"sl":'          + str.tostring(last_sl)
     + ',"dollar_tp":0'
     + ',"dollar_sl":0'
     + ',"percentage_tp":0'
     + ',"percentage_sl":0'
     + ',"reverse_order_close":' + (reverseClose ? 'true' : 'false')
     + ',"same_direction_ignore":' + (sameDirIgnore ? 'true' : 'false')
     + ',"pyramid":' + (pyramid ? 'true' : 'false')
     + ',"order_type":"' + orderType + '"'
     + ',"grade":"' + grade + '"'
     + ',"sweep_type":"' + f_sweep_name(last_sweep_type) + '"'
     + ',"confluence":' + str.tostring(last_conf, '#.0')
     + ',"archetype":"OBv3_' + grade + '_' + f_sweep_name(last_sweep_type) + '"}'

f_hit_json(string hit_type, int level, string dir) =>
    '{"type":"' + hit_type + '"'
     + ',"tp_level":' + str.tostring(level)
     + ',"direction":"' + dir + '"'
     + ',"instrument":"' + syminfo.ticker + '"'
     + ',"price":' + str.tostring(math.round_to_mintick(close)) + '}'

alert_freq = modeIntrabar ? alert.freq_once_per_bar : alert.freq_once_per_bar_close
if enableAlerts and bar_ready
    if mit_long_now and not na(last_entry)
        alert(f_entry_json('LONG', alertStrength, last_grade), alert_freq)
    if mit_short_now and not na(last_entry)
        alert(f_entry_json('SHORT', alertStrength, last_grade), alert_freq)
    if alertOnTp1 and tp1_hit and not tp1_hit[1]
        alert(f_hit_json('tp_hit', 1, last_dir), alert_freq)
    if alertOnTp2 and tp2_hit and not tp2_hit[1]
        alert(f_hit_json('tp_hit', 2, last_dir), alert_freq)
    if alertOnTp3 and tp3_hit and not tp3_hit[1]
        alert(f_hit_json('tp_hit', 3, last_dir), alert_freq)
    if alertOnSl  and sl_hit  and not sl_hit[1]
        alert(f_hit_json('sl_hit', 0, last_dir), alert_freq)

alertcondition(mit_long_now,                'Entry LONG',  'OBv3 LONG — {{ticker}} {{interval}} @ {{close}}')
alertcondition(mit_short_now,               'Entry SHORT', 'OBv3 SHORT — {{ticker}} {{interval}} @ {{close}}')
alertcondition(tp1_hit and not tp1_hit[1],  'TP1 hit',     'OBv3 TP1 — {{ticker}}')
alertcondition(tp2_hit and not tp2_hit[1],  'TP2 hit',     'OBv3 TP2 — {{ticker}}')
alertcondition(tp3_hit and not tp3_hit[1],  'TP3 hit',     'OBv3 TP3 — {{ticker}}')
alertcondition(sl_hit  and not sl_hit[1],   'SL hit',      'OBv3 SL — {{ticker}}')

// ═══════════════════════════════════════════════════════════════════════════
// §17. DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 17, border_width=1, bgcolor=color.new(#0f172a, 10))
if show_dash and barstate.islast
    color hd = color.new(#0b1220, 0)
    color bg = color.new(color.gray, 30)
    color wh = color.white
    color ok = color.new(#69F0AE, 0)
    color no = color.new(#FF5252, 0)

    table.cell(dash, 0, 0, 'OB-V3', text_color=color.new(#f59e0b, 0), text_size=size.small, bgcolor=hd)
    table.cell(dash, 1, 0, syminfo.ticker + ' ' + timeframe.period, text_color=wh, text_size=size.small, bgcolor=hd)

    table.cell(dash, 0, 1, 'Конфлюэнс',  text_color=wh, text_size=size.tiny, bgcolor=bg)
    color c_col = confluence_score >= ust_min_score ? ok : (confluence_score >= 50 ? color.yellow : no)
    table.cell(dash, 1, 1, str.tostring(confluence_score, '#.0') + '/100', text_color=c_col, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 2, 'DER',  text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 2, str.tostring(der_score, '#.0'), text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 3, 'AMVS', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 3, str.tostring(amvs_score, '#.0'), text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 4, 'VRI',  text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 4, str.tostring(vri_score, '#.0'), text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 5, 'COFP', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 5, str.tostring(cofp_score, '#.0'), text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 6, 'KP (моментум)', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 6, str.tostring(kp_score, '#.0') + (kp_bull ? ' ▲' : ' ▼'), text_color=kp_bull ? ok : no, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 7, 'Дивергенция', text_color=wh, text_size=size.tiny, bgcolor=bg)
    string div_txt = bull_div_active ? 'БЫЧ ▲' : bear_div_active ? 'МЕДВ ▼' : 'нет'
    color  div_col = bull_div_active ? ok : bear_div_active ? no : color.gray
    table.cell(dash, 1, 7, div_txt, text_color=div_col, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 8, 'Сжатие',  text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 8, in_compression ? 'ДА' : 'нет', text_color=in_compression ? ok : no, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 9, 'Вакуум', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 9, vacuum_active ? 'ДА' : 'нет', text_color=vacuum_active ? ok : no, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 10, 'Авто-кал.', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 10, 'disp=' + str.tostring(disp_atr_mult, '#.1') + ' body=' + str.tostring(disp_body_pct, '#') + '%',
         text_color=wh, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 11, 'Гейт сейчас', text_color=wh, text_size=size.tiny, bgcolor=bg)
    bool bull_now = close > ema_v
    int gs = f_gate_score(bull_now)
    table.cell(dash, 1, 11, str.tostring(gs) + '/5 (≥' + str.tostring(gate_min) + ')',
         text_color=gs >= gate_min ? ok : no, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 12, 'Входов', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 12, str.tostring(mit_total), text_color=wh, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 13, 'Лесенка TP',  text_color=wh, text_size=size.tiny, bgcolor=bg)
    string ladder = (tp1_hit ? 'TP1✓ ' : 'TP1· ') + (tp2_hit ? 'TP2✓ ' : 'TP2· ') + (tp3_hit ? 'TP3✓' : 'TP3·')
    table.cell(dash, 1, 13, ladder, text_color=wh, text_size=size.tiny, bgcolor=bg)

    table.cell(dash, 0, 14, 'Вебхук', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 14, enableAlerts ? 'ВКЛ' : 'ВЫКЛ', text_color=enableAlerts ? ok : no, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 0, 15, 'Режим', text_color=wh, text_size=size.tiny, bgcolor=bg)
    table.cell(dash, 1, 15, modeIntrabar ? 'В1 ⚠repaint' : 'В2 close', text_color=modeIntrabar ? color.orange : ok, text_size=size.tiny, bgcolor=bg)
    if use_state
        color stcol = trade_state == 'ФАКТОРЫ ЗА' ? ok : trade_state == 'НЕЙТРАЛЬНО' ? color.yellow : trade_state == 'ФАКТОРЫ ОСЛАБЛИ' ? color.orange : trade_state == 'ФАКТОРЫ ПРОТИВ' ? no : color.gray
        table.cell(dash, 0, 16, 'Статус', text_color=wh, text_size=size.tiny, bgcolor=bg)
        table.cell(dash, 1, 16, trade_state + (trade_open ? ' ' + str.tostring(confidence, '#') + '%' : ''), text_color=stcol, text_size=size.tiny, bgcolor=bg)

// ═══════════════════════════════════════════════════════════════════════════
// §18. ТАБЛИЦА СТАТИСТИКИ (сырой счётчик — НЕ бэктест)
// Считает срабатывания TP/SL на видимой истории. Без комиссий/слиппеджа,
// на тех же предположениях о fill. Ориентир для настройки, не оценка прибыли.
// ═══════════════════════════════════════════════════════════════════════════
var table stat = table.new(position.bottom_left, 2, 8, border_width=1, bgcolor=color.new(#0f172a, 10))
if show_stats and barstate.islast
    color shd = color.new(#0b1220, 0)
    color sbg = color.new(color.gray, 30)
    color swh = color.white
    color sok = color.new(#69F0AE, 0)
    color sno = color.new(#FF5252, 0)
    int closed = cnt_tp3 + cnt_sl  // завершённые сделки (дошли до TP3 или SL)
    // БАГ 5 ФИКС: умножаем на 100.0 ДО деления — иначе int/int даёт целочисленное
    // деление (3/10=0), и win-rate всегда показывал бы 0%.
    float wr1 = mit_total > 0 ? cnt_tp1 * 100.0 / mit_total : 0.0
    float wr3 = closed > 0 ? cnt_tp3 * 100.0 / closed : 0.0

    table.cell(stat, 0, 0, 'СТАТИСТИКА', text_color=color.new(#f59e0b,0), text_size=size.tiny, bgcolor=shd)
    table.cell(stat, 1, 0, 'сырой счёт', text_color=color.new(#f59e0b,0), text_size=size.tiny, bgcolor=shd)

    table.cell(stat, 0, 1, 'Входов', text_color=swh, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 1, str.tostring(mit_total), text_color=swh, text_size=size.tiny, bgcolor=sbg)

    table.cell(stat, 0, 2, 'TP1 взят', text_color=swh, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 2, str.tostring(cnt_tp1) + ' (' + str.tostring(wr1,'#') + '%)', text_color=sok, text_size=size.tiny, bgcolor=sbg)

    table.cell(stat, 0, 3, 'TP2 взят', text_color=swh, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 3, str.tostring(cnt_tp2), text_color=sok, text_size=size.tiny, bgcolor=sbg)

    table.cell(stat, 0, 4, 'TP3 взят', text_color=swh, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 4, str.tostring(cnt_tp3), text_color=sok, text_size=size.tiny, bgcolor=sbg)

    table.cell(stat, 0, 5, 'SL взят', text_color=swh, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 5, str.tostring(cnt_sl), text_color=sno, text_size=size.tiny, bgcolor=sbg)

    table.cell(stat, 0, 6, 'TP3/закрыто', text_color=swh, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 6, str.tostring(wr3,'#') + '%', text_color=wr3>=50?sok:sno, text_size=size.tiny, bgcolor=sbg)

    table.cell(stat, 0, 7, '⚠ не бэктест', text_color=color.orange, text_size=size.tiny, bgcolor=sbg)
    table.cell(stat, 1, 7, 'ориентир', text_color=color.orange, text_size=size.tiny, bgcolor=sbg)
````
