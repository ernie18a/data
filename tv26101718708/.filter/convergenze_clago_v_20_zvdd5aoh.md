# Convergenze Clago v. 2.0

- url: https://www.tradingview.com/script/zvdD5aoh/
- type: indicator
- pine_id: PUB;7c7159e38d50471c8f5c6fcdaa82d508
- version: 1.0

## Description

Con questo potrai valutare di entrare o meno sui livelli importanti

## Source Code

````pine
//@version=6
indicator("WAVE v2.7 + EMA 8·12·21 + CVD [UNICO]", shorttitle="WAVE+ECV", overlay=false, format=format.volume, precision=2)

// CONFLUENZA
//   LONG  = EMA 8>12>21  +  CVD>Signal  +  WAVE sopra il suo signal
//   SHORT = EMA 8<12<21  +  CVD<Signal  +  WAVE sotto il suo signal
// Entrata = triangolo (verde long / rosso short). Uscita: BE = wave persa,
// TP = medie perse (testo giallo). CVD non disegnato (solo dashboard).

// 1. AUTO-DETECTION ASSET
is_btc = str.contains(syminfo.ticker, "BTC") or str.contains(syminfo.ticker, "BITCOIN")
is_xau = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
is_xag = str.contains(syminfo.ticker, "XAG") or str.contains(syminfo.ticker, "SILVER")
is_wti = str.contains(syminfo.ticker, "WTI") or str.contains(syminfo.ticker, "CL") or str.contains(syminfo.ticker, "CRUDE") or str.contains(syminfo.ticker, "OIL")
is_nas = str.contains(syminfo.ticker, "NAS") or str.contains(syminfo.ticker, "NDX") or str.contains(syminfo.ticker, "NASDAQ")

manual_override = input.bool(false, "Manual Asset Override", group="🎯 ASSET")
manual_asset    = input.string("AUTO", "Asset Type", options=["AUTO","BTC","XAU","XAG","WTI","NAS100"], group="🎯 ASSET")

string asset_type = "OTHER"
if manual_override
    asset_type := manual_asset == "AUTO" ? "OTHER" : manual_asset
else
    asset_type := is_btc ? "BTC" : is_xau ? "XAU" : is_xag ? "XAG" : is_wti ? "WTI" : is_nas ? "NAS100" : "OTHER"

// 2. PARAMETRI ADATTIVI
float vol_mult = switch asset_type
    "BTC"    => 2.0
    "XAU"    => 1.3
    "XAG"    => 1.5
    "WTI"    => 1.8
    "NAS100" => 1.5
    => 1.5
float mom_scale = switch asset_type
    "BTC"    => 50.0
    "XAU"    => 150.0
    "XAG"    => 120.0
    "WTI"    => 100.0
    "NAS100" => 100.0
    => 100.0
int auto_peak_left = switch asset_type
    "BTC"    => 6
    "XAU"    => 5
    "XAG"    => 5
    "NAS100" => 5
    => 5
int auto_peak_right   = 2
float auto_peak_min_amp = switch asset_type
    "BTC"    => 0.40
    "XAU"    => 0.20
    "XAG"    => 0.22
    "NAS100" => 0.30
    => 0.25
int auto_peak_cooldown = switch asset_type
    "BTC"    => 15
    "XAU"    => 12
    "XAG"    => 12
    "NAS100" => 12
    => 10

// 3. INPUTS CORE (WAVE)
group_core     = "⚙️ CORE"
sign           = input.int(7,     "Signal Smoothing",   minval=1, maxval=20, group=group_core)
price          = input.source(close, "Source",           group=group_core)
smoothing_type = input.string("rma", "Smoothing Type",  options=["rma","ema","sma"], group=group_core)
use_volume     = input.bool(true, "Volume Weighting",    group=group_core)
vol_period     = input.int(20,   "Volume SMA Period",    minval=1, group=group_core)

// 4. ADX + SIGNAL
group_adx = "🔶 ADX + SIGNAL RIENTRO"
adx_period          = input.int(14, "ADX Period",       minval=5, maxval=30, group=group_adx)
adx_trend_threshold = input.int(23, "ADX Soglia Trend", minval=15, maxval=35, group=group_adx)
signal_fast   = input.int(9,  "Signal Fast  (ADX>25)",      minval=5,  maxval=15, group=group_adx)
signal_medium = input.int(12, "Signal Medium (ADX>soglia)",  minval=8,  maxval=18, group=group_adx)
signal_slow   = input.int(16, "Signal Slow  (Range)",        minval=12, maxval=25, group=group_adx)
show_signal   = input.bool(true, "Mostra Signal Line",        group=group_adx)

// 5. TIMEFRAMES
group_tf = "📊 TIMEFRAMES"
htf_tf = input.timeframe("60", "Higher TF (H1)", group=group_tf)
ltf_tf = input.timeframe("15", "Lower  TF (15m)", group=group_tf)

// 6. DIVERGENZE
group_div = "📐 DIVERGENZE"
div_left  = input.int(3, "Pivot Left",  minval=1, group=group_div)
div_right = input.int(2, "Pivot Right", minval=1, group=group_div)
div_prox  = input.int(8, "Proximity",   minval=5, group=group_div)

// 7. WAVE VISUALS + PICCHI
group_wave = "🌊 WAVE VISUALS"
show_curvature   = input.bool(true, "Mostra Curvatura (2ª derivata)", group=group_wave)
show_peak_labels = input.bool(true, "Mostra Marcatori Picco/Minimo",  group=group_wave)
peak_auto        = input.bool(true,  "Auto-Parametri per Asset",      group=group_wave)
peak_left        = input.int(5,      "Pivot Left (manuale)",          minval=2, maxval=12, group=group_wave)
peak_right       = input.int(2,      "Pivot Right (manuale)",         minval=1, maxval=5,  group=group_wave)
peak_min_amp     = input.float(0.25, "Ampiezza Minima (manuale)",     minval=0.05, step=0.05, group=group_wave)
peak_cooldown    = input.int(10,     "Cooldown tra picchi (manuale)", minval=3, maxval=30,  group=group_wave)
peak_adx_filter  = input.bool(true,  "Picchi solo in Trend (ADX)",    group=group_wave)
plot_multiplier  = input.float(1.0,  "Scala",                         minval=0.1, step=0.1, group=group_wave)

int   p_left     = peak_auto ? auto_peak_left     : peak_left
int   p_right    = peak_auto ? auto_peak_right     : peak_right
float p_min_amp  = peak_auto ? auto_peak_min_amp   : peak_min_amp
int   p_cooldown = peak_auto ? auto_peak_cooldown  : peak_cooldown

// 7b. INPUTS EMA 8/12/21
gE = "📈 EMA (sul prezzo)"
showEma = input.bool(true, "Mostra EMA 8/12/21", group=gE)
emaSrc  = input.source(close, "EMA Source",      group=gE)
emaLen1 = input.int(8,  "EMA veloce", minval=1,  group=gE)
emaLen2 = input.int(12, "EMA media",  minval=1,  group=gE)
emaLen3 = input.int(21, "EMA lenta",  minval=1,  group=gE)

// 7c. INPUTS CVD
gC = "📊 CVD"
cvdAnchor = input.string("Continuo", "Reset cumulo", options=["Continuo","Sessione (giorno)","Settimana"], group=gC)
cvdSigLen = input.int(21, "EMA Signal del CVD", minval=1, group=gC)

// 8. COLORI
col_bull    = color.rgb(0, 255, 120)
col_bear    = color.rgb(175, 0, 255)
col_signal  = color.orange
col_peak    = color.new(color.yellow, 0)

// 9. FUNZIONI HELPER
f_ma(src, type, len) =>
    switch type
        "rma" => ta.rma(src, len)
        "ema" => ta.ema(src, len)
        "sma" => ta.sma(src, len)
        => na

f_sec(sym, tf, src) =>
    request.security(sym, tf, src, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_detect_div(src_price_high, src_price_low, src_osc) =>
    priceHigh = ta.pivothigh(src_price_high, div_left, div_right)
    priceLow  = ta.pivotlow(src_price_low,  div_left, div_right)
    oscHigh   = ta.pivothigh(src_osc, div_left, div_right)
    oscLow    = ta.pivotlow(src_osc,  div_left, div_right)
    var float lastPH = na
    var int   lastPHBar = na
    var float lastOH = na
    var float lastPL = na
    var int   lastPLBar = na
    var float lastOL = na
    bearDiv    = false
    bullDiv    = false
    hiddenBear = false
    hiddenBull = false
    if not na(priceHigh) and (bar_index - lastPHBar < div_prox)
        if not na(lastPH) and priceHigh > lastPH and oscHigh < lastOH
            bearDiv := true
        else if not na(lastPH) and priceHigh < lastPH and oscHigh > lastOH
            hiddenBear := true
        lastPH    := priceHigh
        lastOH    := oscHigh
        lastPHBar := bar_index
    if not na(priceLow) and (bar_index - lastPLBar < div_prox)
        if not na(lastPL) and priceLow < lastPL and oscLow > lastOL
            bullDiv := true
        else if not na(lastPL) and priceLow > lastPL and oscLow < lastOL
            hiddenBull := true
        lastPL    := priceLow
        lastOL    := oscLow
        lastPLBar := bar_index
    [bearDiv, bullDiv, hiddenBear, hiddenBull]

// 10. CALCOLO DSL CORE
htf_price = f_sec(syminfo.tickerid, htf_tf, price)
avg  = nz(f_ma(htf_price, smoothing_type, 5))
avg1 = nz(f_ma(htf_price, smoothing_type, 10))
avg2 = nz(f_ma(htf_price, smoothing_type, 20))
avg3 = nz(f_ma(htf_price, smoothing_type, 40))
avg4 = nz(f_ma(htf_price, smoothing_type, 80))
mom1 = avg1 != 0 ? mom_scale * (avg - avg1) / avg1 : 0.0
mom2 = avg2 != 0 ? mom_scale * (avg - avg2) / avg2 : 0.0
mom3 = avg3 != 0 ? mom_scale * (avg - avg3) / avg3 : 0.0
mom4 = avg4 != 0 ? mom_scale * (avg - avg4) / avg4 : 0.0
dsl_vol = (mom4 + mom3 * 80/40 + mom2 * 80/20 + mom1 * 80/10) / 4.0
avg_vol    = ta.sma(volume, vol_period)
vol_factor = use_volume and volume > avg_vol * vol_mult ? 1.5 : 1.0
dsl_vol   := dsl_vol * vol_factor
alpha = 2.0 / (1.0 + sign)
var float lu = 0.0
var float ld = 0.0
lu := dsl_vol > 0 ? nz(lu[1]) + alpha * (dsl_vol - nz(lu[1])) : nz(lu[1])
ld := dsl_vol < 0 ? nz(ld[1]) + alpha * (dsl_vol - nz(ld[1])) : nz(ld[1])

// 11. ADX + SIGNAL LINE ADATTIVA
[diplus, diminus, adx] = ta.dmi(adx_period, adx_period)
bool is_trending = adx > adx_trend_threshold
ema1_fast   = ta.ema(dsl_vol, signal_fast)
dema_fast   = 2 * ema1_fast - ta.ema(ema1_fast, signal_fast)
ema1_med    = ta.ema(dsl_vol, signal_medium)
dema_medium = 2 * ema1_med - ta.ema(ema1_med, signal_medium)
ema1_slow   = ta.ema(dsl_vol, signal_slow)
dema_slow   = 2 * ema1_slow - ta.ema(ema1_slow, signal_slow)
dsl_signal  = adx > 25 ? dema_fast : adx > adx_trend_threshold ? dema_medium : dema_slow

// 11b. EMA + CVD + CONFLUENZA
ema_f = ta.ema(emaSrc, emaLen1)
ema_m = ta.ema(emaSrc, emaLen2)
ema_s = ta.ema(emaSrc, emaLen3)
bullStack = ema_f > ema_m and ema_m > ema_s
bearStack = ema_f < ema_m and ema_m < ema_s
priceUp   = close > ema_f

cvd_rng  = high - low
cvd_buy  = cvd_rng > 0 ? volume * (close - low) / cvd_rng : volume * 0.5
cvd_sell = cvd_rng > 0 ? volume * (high - close) / cvd_rng : volume * 0.5
cvd_delta = cvd_buy - cvd_sell
cvd_reset = cvdAnchor == "Continuo" ? false : cvdAnchor == "Settimana" ? timeframe.change("1W") : timeframe.change("1D")
var float cvd = 0.0
cvd := cvd_reset ? cvd_delta : nz(cvd[1]) + cvd_delta
cvd_sig = ta.ema(cvd, cvdSigLen)
cvdUp = cvd >= cvd_sig
cvdDn = cvd <  cvd_sig

waveBull = dsl_vol > dsl_signal
waveBear = dsl_vol < dsl_signal

longReady  = bullStack and cvdUp and waveBull
shortReady = bearStack and cvdDn and waveBear

// STATO POSIZIONE: un solo ingresso finché non c'è un'uscita vera
var bool inLong  = false
var bool inShort = false
longTrig  = longReady  and not inLong
shortTrig = shortReady and not inShort
longExit  = inLong  and (not bullStack or not waveBull)
shortExit = inShort and (not bearStack or not waveBear)
// Causa uscita: medie perse = TP (priorità), wave persa = BE
longExitTP  = longExit  and not bullStack
longExitBE  = longExit  and bullStack and not waveBull
shortExitTP = shortExit and not bearStack
shortExitBE = shortExit and bearStack and not waveBear
if longTrig
    inLong  := true
    inShort := false
if longExit
    inLong  := false
if shortTrig
    inShort := true
    inLong  := false
if shortExit
    inShort := false

// 12. CURVATURA + FASE
vel_raw    = dsl_vol - dsl_vol[1]
velocity   = ta.ema(vel_raw, 3)
curvature  = velocity - velocity[1]
bool phase_rising_bull  = dsl_vol > 0 and velocity > 0
bool phase_peak_bull    = dsl_vol > 0 and velocity <= 0
bool phase_falling_bear = dsl_vol < 0 and velocity < 0
bool phase_trough_bear  = dsl_vol < 0 and velocity >= 0

// 13. RILEVAMENTO PICCO
bool trend_ok_peak = not peak_adx_filter or is_trending
float dsl_pivot_high = ta.pivothigh(dsl_vol, p_left, p_right)
float dsl_pivot_low  = ta.pivotlow(dsl_vol,  p_left, p_right)
var int last_peak_bar   = -999
var int last_trough_bar = -999
bool peak_candidate   = not na(dsl_pivot_high) and dsl_pivot_high > p_min_amp  and trend_ok_peak
bool trough_candidate = not na(dsl_pivot_low)  and dsl_pivot_low  < -p_min_amp and trend_ok_peak
bool at_peak   = peak_candidate   and (bar_index - last_peak_bar)   >= p_cooldown
bool at_trough = trough_candidate and (bar_index - last_trough_bar) >= p_cooldown
if at_peak
    last_peak_bar := bar_index
if at_trough
    last_trough_bar := bar_index
var int decel_bull_count = 0
var int decel_bear_count = 0
decel_bull_count := dsl_vol > 0 and curvature < 0 ? decel_bull_count + 1 : 0
decel_bear_count := dsl_vol < 0 and curvature > 0 ? decel_bear_count + 1 : 0
bool near_peak   = dsl_vol > 0 and velocity > 0 and decel_bull_count >= 3 and trend_ok_peak and math.abs(dsl_vol) > p_min_amp
bool near_trough = dsl_vol < 0 and velocity < 0 and decel_bear_count >= 3 and trend_ok_peak and math.abs(dsl_vol) > p_min_amp

// 14. RIENTRO / ENTRATA WAVE
float wave_vel = ta.ema(dsl_vol - dsl_vol[1], 2)
bool reentry_bull = is_trending and (ta.crossover(dsl_vol, 0) or (dsl_vol > 0 and wave_vel > 0 and wave_vel[1] <= 0))
bool reentry_bear = is_trending and (ta.crossunder(dsl_vol, 0) or (dsl_vol < 0 and wave_vel < 0 and wave_vel[1] >= 0))

// 15. LTF + DIVERGENZE
ltf_dsl = f_sec(syminfo.tickerid, ltf_tf, dsl_vol)
[bearDiv, bullDiv, hiddenBear, hiddenBull] = f_detect_div(high, low, dsl_vol)
[ltf_bearDiv, ltf_bullDiv, ltf_hiddenBear, ltf_hiddenBull] = request.security(syminfo.tickerid, ltf_tf, f_detect_div(high, low, dsl_vol), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// 16. QUALITÀ SEGNALE
dsl_norm            = ta.percentrank(dsl_vol, 100)
float signal_strength = math.abs(dsl_norm - 50) * 2
if ltf_dsl * dsl_vol > 0
    signal_strength += 25
if vol_factor > 1.0
    signal_strength += 15
if ta.cross(dsl_vol, 0)
    signal_strength += 20
if is_trending
    signal_strength += 15
if bearDiv or bullDiv or hiddenBear or hiddenBull
    signal_strength -= 20
signal_strength := math.max(0, math.min(100, signal_strength))

// 17. SCALING
scaled_vol      = dsl_vol    * plot_multiplier
scaled_curve    = curvature  * plot_multiplier * 5.0
scaled_signal   = dsl_signal * plot_multiplier

// 18. COLORE CURVA
int bull_transp = at_peak   ? 40 : near_peak   ? 20 : phase_rising_bull  ? 0 : 30
int bear_transp = at_trough ? 40 : near_trough ? 20 : phase_falling_bear ? 0 : 30
main_color = dsl_vol > 0 ? color.from_gradient(dsl_norm, 0, 100, color.new(col_bull, bull_transp + 20), color.new(col_bull, bull_transp)) : color.from_gradient(math.abs(dsl_norm - 100), 0, 100, color.new(col_bear, bear_transp + 20), color.new(col_bear, bear_transp))

// 19. PLOTTING
plot(showEma ? ema_f : na, "EMA 8",  color.new(#00e0ff, 0), 2, force_overlay=true)
plot(showEma ? ema_m : na, "EMA 12", color.new(#ffb300, 0), 2, force_overlay=true)
plot(showEma ? ema_s : na, "EMA 21", color.new(#ff3d71, 0), 2, force_overlay=true)

hline(0, "Zero", color.new(color.white, 70), hline.style_solid, 1)
plot(show_curvature ? scaled_curve : na, "Curvatura", color.new(color.white, 55), 1, plot.style_line)

fill_opacity_bull = at_peak   ? 97 : near_peak   ? 93 : phase_rising_bull  ? 88 : 92
fill_opacity_bear = at_trough ? 97 : near_trough ? 93 : phase_falling_bear ? 88 : 92
fill_color = dsl_vol > 0 ? color.new(col_bull, fill_opacity_bull) : color.new(col_bear, fill_opacity_bear)
p_main = plot(scaled_vol,  "DSL Main", display=display.none)
p_zero = plot(0,           "Zero Ref", display=display.none)
fill(p_main, p_zero, fill_color, title="Wave Fill")

plot(scaled_vol, "Wave", main_color, 4, plot.style_line)
int sig_transp = is_trending ? 20 : 65
plot(show_signal ? scaled_signal : na, "Signal", color.new(col_signal, sig_transp), 1, plot.style_line)

plotshape(show_peak_labels and at_peak,   "Picco ∩",  shape.diamond, location.absolute, color.new(col_peak, 0), size=size.small, text="∩", textcolor=color.black)
plotshape(show_peak_labels and at_trough, "Minimo ∪", shape.diamond, location.absolute, color.new(col_peak, 0), size=size.small, text="∪", textcolor=color.black)
plotshape(show_peak_labels and near_peak and not at_peak,     "Near Peak",   shape.triangledown, location.absolute, color.new(color.orange, 20), size=size.tiny)
plotshape(show_peak_labels and near_trough and not at_trough, "Near Trough", shape.triangleup,   location.absolute, color.new(color.orange, 20), size=size.tiny)
plotshape(reentry_bull, "Rientro LONG",  shape.circle, location.absolute, color.new(color.lime, 0),    size=size.normal, text="↑", textcolor=color.black)
plotshape(reentry_bear, "Rientro SHORT", shape.circle, location.absolute, color.new(color.fuchsia, 0), size=size.normal, text="↓", textcolor=color.white)

// CONFLUENZA — entrata (verde long / rosso short)
plotshape(longTrig,  "CONFLUENZA LONG",  shape.triangleup,   location.bottom, color.new(color.green, 0), size=size.small)
plotshape(shortTrig, "CONFLUENZA SHORT", shape.triangledown, location.top,    color.new(color.red, 0),   size=size.small)
// USCITA — BE (wave persa) / TP (medie perse), testo giallo
plotshape(longExitBE,  "USCITA LONG BE",  shape.labelup,   location.bottom, color.new(color.gray, 100), text="BE", textcolor=color.yellow, size=size.small)
plotshape(longExitTP,  "USCITA LONG TP",  shape.labelup,   location.bottom, color.new(color.gray, 100), text="TP", textcolor=color.yellow, size=size.small)
plotshape(shortExitBE, "USCITA SHORT BE", shape.labeldown, location.top,    color.new(color.gray, 100), text="BE", textcolor=color.yellow, size=size.small)
plotshape(shortExitTP, "USCITA SHORT TP", shape.labeldown, location.top,    color.new(color.gray, 100), text="TP", textcolor=color.yellow, size=size.small)

bgcolor(not is_trending             ? color.new(color.gray,   97) : na, title="Range")
bgcolor(is_trending and dsl_vol > 0 ? color.new(color.green,  97) : na, title="Trend Bull")
bgcolor(is_trending and dsl_vol < 0 ? color.new(color.purple, 97) : na, title="Trend Bear")

// 20. DASHBOARD
if barstate.islast
    var table dash = table.new(position.bottom_right, 2, 14, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(color.gray, 50))
    string adx_str = adx > 25 ? "TREND ▲" : adx > adx_trend_threshold ? "WEAK" : "RANGE ⛔"
    color  adx_col = adx > 25 ? color.lime  : adx > adx_trend_threshold ? color.orange : color.red
    table.cell(dash, 0, 0, "🌊 WAVE+ECV — " + asset_type, text_color=color.white, bgcolor=color.new(color.blue, 50), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "ADX " + str.tostring(math.round(adx)) + " " + adx_str, text_color=adx_col, bgcolor=color.new(color.blue, 50), text_size=size.small)

    string fase_txt = ""
    color  fase_col = color.gray
    if at_peak
        fase_txt := "◆ PICCO — esci LONG"
        fase_col := col_peak
    else if at_trough
        fase_txt := "◆ MINIMO — esci SHORT"
        fase_col := col_peak
    else if near_peak
        fase_txt := "▽ PRE-PICCO — sposta BE"
        fase_col := color.orange
    else if near_trough
        fase_txt := "△ PRE-MINIMO — sposta BE"
        fase_col := color.orange
    else if phase_rising_bull
        fase_txt := "↑ SALITA BULL"
        fase_col := col_bull
    else if phase_peak_bull
        fase_txt := "↘ DISCESA DAL PICCO"
        fase_col := color.new(col_bull, 40)
    else if phase_falling_bear
        fase_txt := "↓ DISCESA BEAR"
        fase_col := col_bear
    else if phase_trough_bear
        fase_txt := "↗ RISALITA DAL MINIMO"
        fase_col := color.new(col_bear, 40)
    table.cell(dash, 0, 1, "Fase Ciclo:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, fase_txt, text_color=fase_col, text_size=size.small)

    bool aligned = (dsl_vol > 0 and ltf_dsl > 0) or (dsl_vol < 0 and ltf_dsl < 0)
    string htf_str = dsl_vol > 0 ? "BULL" : dsl_vol < 0 ? "BEAR" : "FLAT"
    string ltf_str = ltf_dsl > 0 ? "BULL" : ltf_dsl < 0 ? "BEAR" : "FLAT"
    table.cell(dash, 0, 2, "H1 / 15m:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, htf_str + " / " + ltf_str + (aligned ? " ✓" : " ✗"), text_color=aligned ? color.lime : color.orange, text_size=size.small)

    table.cell(dash, 0, 3, "Volume:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, vol_factor > 1.0 ? "✓ ALTO" : "Normale", text_color=vol_factor > 1.0 ? color.yellow : color.gray, text_size=size.small)

    bool has_bear_div = bearDiv or hiddenBear or ltf_bearDiv or ltf_hiddenBear
    bool has_bull_div = bullDiv or hiddenBull or ltf_bullDiv or ltf_hiddenBull
    string div_txt = has_bear_div and has_bull_div ? "⚠️ MISTE" : has_bear_div ? "🔴 Bear" : has_bull_div ? "🟢 Bull" : "Nessuna"
    color  div_col = has_bear_div and has_bull_div ? color.orange : has_bear_div ? color.red : has_bull_div ? color.lime : color.gray
    table.cell(dash, 0, 4, "Divergenze:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, div_txt, text_color=div_col, text_size=size.small)

    color sq_col = signal_strength > 70 ? color.lime : signal_strength > 50 ? color.yellow : color.red
    table.cell(dash, 0, 5, "Qualità:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(signal_strength)) + "%", text_color=sq_col, text_size=size.small)

    string emaTxt = bullStack ? "▲ 8>12>21 UP" : bearStack ? "▼ 8<12<21 DOWN" : "↔ intrecciate"
    color  emaColor = bullStack ? color.lime : bearStack ? color.red : color.gray
    table.cell(dash, 0, 6, "EMA 8/12/21:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, emaTxt, text_color=emaColor, text_size=size.small)

    table.cell(dash, 0, 7, "Prezzo vs EMA8:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, priceUp ? "sopra ✓" : "sotto ✗", text_color=priceUp ? color.lime : color.red, text_size=size.small)

    table.cell(dash, 0, 8, "CVD:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, cvdUp ? "▲ compratori" : "▼ venditori", text_color=cvdUp ? color.lime : color.red, text_size=size.small)

    table.cell(dash, 0, 9, "WAVE vs Signal:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, waveBull ? "▲ sopra" : "▼ sotto", text_color=waveBull ? color.lime : color.red, text_size=size.small)

    string conf_txt = ""
    color  conf_col = color.gray
    color  conf_bg  = color.new(color.gray, 70)
    if longReady
        conf_txt := "🟢 CONFLUENZA LONG"
        conf_col := col_bull
        conf_bg  := color.new(color.green, 70)
    else if shortReady
        conf_txt := "🔴 CONFLUENZA SHORT"
        conf_col := col_bear
        conf_bg  := color.new(color.purple, 70)
    else
        conf_txt := "⚪ attendi allineamento"
        conf_col := color.gray
        conf_bg  := color.new(color.gray, 70)
    table.cell(dash, 0, 10, "CONFLUENZA:", text_color=color.white, bgcolor=conf_bg, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 10, conf_txt, text_color=conf_col, bgcolor=conf_bg, text_size=size.normal)

// 21. ALERTS
bool aligned_alert = (dsl_vol > 0 and ltf_dsl > 0) or (dsl_vol < 0 and ltf_dsl < 0)
if at_peak and aligned_alert
    alert("⚠️ WAVE: PICCO BULL " + asset_type + " — esci LONG (ADX:" + str.tostring(math.round(adx)) + ")", alert.freq_once_per_bar_close)
if at_trough and aligned_alert
    alert("⚠️ WAVE: MINIMO BEAR " + asset_type + " — esci SHORT (ADX:" + str.tostring(math.round(adx)) + ")", alert.freq_once_per_bar_close)
alertcondition(longTrig,  "CONFLUENZA LONG (EMA+CVD+WAVE)",  "EMA 8>12>21 + CVD compratori + WAVE sopra signal")
alertcondition(shortTrig, "CONFLUENZA SHORT (EMA+CVD+WAVE)", "EMA 8<12<21 + CVD venditori + WAVE sotto signal")
alertcondition(longExit,  "USCITA LONG (cond. persa)",  "Chiudi LONG: persa EMA stack o WAVE sotto signal")
alertcondition(shortExit, "USCITA SHORT (cond. persa)", "Chiudi SHORT: persa EMA stack o WAVE sopra signal")
if reentry_bull
    alert("● WAVE: LONG " + asset_type + " — rientro (ADX:" + str.tostring(math.round(adx)) + ")", alert.freq_once_per_bar_close)
if reentry_bear
    alert("● WAVE: SHORT " + asset_type + " — rientro (ADX:" + str.tostring(math.round(adx)) + ")", alert.freq_once_per_bar_close)
````
