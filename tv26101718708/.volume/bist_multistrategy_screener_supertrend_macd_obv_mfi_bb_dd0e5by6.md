# BIST Multi-Strategy Screener (SuperTrend, MACD, OBV, MFI, BB)

- url: https://www.tradingview.com/script/Dd0e5by6/
- type: indicator
- pine_id: PUB;cd44547fa4fc4c4786215fcfd5bf35a1
- version: 1.0

## Description

What it does
This indicator is designed for TradingView's Pine Screener. It combines five independent strategies — SuperTrend, MACD, Bollinger Bands + Volume, OBV, and MFI — into a single composite scoring model (0–100) and exposes every signal as a numeric plot, so each one can be used as a filter column in the Pine Screener.
How it works
Each strategy produces two states:
Trigger (a fresh crossover/flip on the current bar) → generates a "New Buy" state
Continuation (the condition is still active) → generates a "Buy (Ongoing)" state
Scoring weights: SuperTrend flip +80, Bollinger breakout with 1.5× average volume +85, MACD crossover +70, MFI crossing above 50 +65, OBV crossing above its EMA(20) +75. A special "Sniper" condition (SuperTrend flip confirmed by OBV) scores 95. Continuation states score lower (60–75). The total is capped at 100. A separate volume-spike flag fires when volume exceeds 2× its 20-bar average.
The rationale for the mashup: SuperTrend defines the trend regime, MACD and MFI confirm momentum, OBV confirms money flow, and the Bollinger + volume condition detects breakouts. Requiring agreement between trend, momentum and volume-based tools filters out many single-indicator false signals.
How to use it
Save the script, open Pine Screener, choose your watchlist (e.g. BIST stocks) and select this indicator.
Add filters on the plotted columns, for example: `New Buy = 1`, `Score ≥ 85`, `Volume Spike = 1`, or `Sniper (ST+OBV) = 1`.
An optional Heikin Ashi mode recalculates all signals on smoothed candles.
Settings
Calculation source: Normal candles / Heikin Ashi
ATR period and multiplier for SuperTrend (default 14 / 1.5)
Limitations
Signals are computed on bar close; intrabar values may repaint until the bar closes. Heikin Ashi mode uses synthetic prices and should not be used to estimate real entry prices. This script is a screening tool, not a trading system, and past signal behavior does not guarantee future results. Educational purposes only — not financial advice.

## Source Code

````pine
//@version=6
indicator('BIST Multi-Strategy Screener (SuperTrend, MACD, OBV, MFI, BB)', shorttitle='BIST MS Screener', overlay=false)

// ==========================================
// BIST Multi-Strategy Screener
// SuperTrend + MACD + OBV + MFI + Bollinger Bands
//
// PINE SCREENER NOTU:
// Pine Screener her sembolü kendisi tarar. Bu yüzden
// 40'lı request.security mimarisi ve tablo KALDIRILDI.
// Tüm sinyaller plot() olarak dışarı verildi.
// Screener'da bu plot'ları filtre olarak seçebilirsiniz.
// ==========================================

// 1. AYARLAR
calc_mode = input.string("Normal Mumlar", "Hesaplama Yöntemi", options=["Normal Mumlar", "Heikin Ashi (Smoothed)"])
atr_period = input.int(14, "ATR Periyodu")
atr_multiplier = input.float(1.5, "ATR Çarpanı", step=0.1)

// 2. STRATEJİ MOTORU (tek sembol üzerinde çalışır)
f_engine() =>
    // MACD
    [macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
    t_macd = ta.crossover(macdLine, signalLine)
    s_macd = macdLine > signalLine

    // SuperTrend
    [st_val, st_dir] = ta.supertrend(atr_multiplier, atr_period)
    t_st = ta.change(st_dir) < 0
    s_st = st_dir == -1

    // Bollinger + Hacim
    [_, upper, _] = ta.bb(close, 20, 2)
    vol_avg = ta.sma(volume, 20)
    t_bb = ta.crossover(close, upper) and volume > (vol_avg * 1.5)
    s_bb = close > upper

    // MFI
    mfi_val = ta.mfi(close, 14)
    t_mfi = ta.crossover(mfi_val, 50)
    s_mfi = mfi_val > 50

    // OBV
    obv = ta.obv
    obv_ma = ta.ema(obv, 20)
    t_obv = ta.crossover(obv, obv_ma)
    s_obv = obv > obv_ma

    // Hacim patlaması
    v_spike = (nz(vol_avg) > 0) ? (volume > (vol_avg * 2)) : false

    [t_macd, s_macd, t_st, s_st, t_bb, s_bb, t_mfi, s_mfi, t_obv, s_obv, v_spike]

// Heikin Ashi modu seçildiyse HA verisiyle hesapla
sym = calc_mode == "Heikin Ashi (Smoothed)" ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid
[t_macd, s_macd, t_st, s_st, t_bb, s_bb, t_mfi, s_mfi, t_obv, s_obv, v_spike] = request.security(sym, timeframe.period, f_engine())

// 3. PUANLAMA VE SİNYAL DURUMU (orijinal mantık birebir korundu)
int score = 0
bool is_new_buy = false

bool sniper_trig = t_st and (t_obv or s_obv)
if sniper_trig
    score += 95
    is_new_buy := true
else
    if t_st
        score += 80
        is_new_buy := true
    if t_obv
        score += 75
        is_new_buy := true

if t_bb
    score += 85
    is_new_buy := true
if t_macd
    score += 70
    is_new_buy := true
if t_mfi
    score += 65
    is_new_buy := true

bool is_cont_buy = false
if not is_new_buy
    if s_bb
        score += 75
        is_cont_buy := true
    if s_st
        score += 70
        is_cont_buy := true
    if s_macd
        score += 60
        is_cont_buy := true
    if s_obv
        score += 60
        is_cont_buy := true
    if s_mfi
        score += 60
        is_cont_buy := true

int final_score = math.min(score, 100)

// 4. SCREENER ÇIKTILARI (Pine Screener bu plot'ları görür)
// Sayısal kolon
plot(final_score, "GÜÇ (Puan)", display=display.data_window)

// Durum kolonları (1 = Evet, 0 = Hayır)
plot(is_new_buy ? 1 : 0, "YENİ AL", display=display.data_window)
plot(is_cont_buy ? 1 : 0, "AL (Sürüyor)", display=display.data_window)
plot((is_new_buy or is_cont_buy) ? 1 : 0, "Herhangi AL", display=display.data_window)
plot(v_spike ? 1 : 0, "Hacim Patlaması", display=display.data_window)
plot((is_new_buy and v_spike) ? 1 : 0, "YENİ AL + Hacim", display=display.data_window)
plot(final_score == 100 ? 1 : 0, "GÜÇ 100", display=display.data_window)

// Strateji bazlı tetik kolonları
plot(sniper_trig ? 1 : 0, "Keskin Nişancı (ST+OBV)", display=display.data_window)
plot(t_st ? 1 : 0, "SuperTrend Tetik", display=display.data_window)
plot(t_bb ? 1 : 0, "Bollinger+Vol Tetik", display=display.data_window)
plot(t_macd ? 1 : 0, "MACD Tetik", display=display.data_window)
plot(t_mfi ? 1 : 0, "MFI Tetik", display=display.data_window)
plot(t_obv ? 1 : 0, "OBV Tetik", display=display.data_window)

// Devam eden durum kolonları
plot(s_st ? 1 : 0, "SuperTrend Yukarı", display=display.data_window)
plot(s_bb ? 1 : 0, "Bollinger Üstünde", display=display.data_window)
plot(s_macd ? 1 : 0, "MACD Pozitif", display=display.data_window)
plot(s_mfi ? 1 : 0, "MFI > 50", display=display.data_window)
plot(s_obv ? 1 : 0, "OBV Yukarı", display=display.data_window)
````
