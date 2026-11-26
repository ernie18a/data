# Mean Reversion Dashboard & Screener v6

- url: https://www.tradingview.com/script/a1e6xmcc/
- type: indicator
- pine_id: PUB;b8114cab4a9e43a19a683e62334dc4bf
- version: 1.0

## Description

Beschreibung (Deutsch)
Dieser multifunktionale Indikator wurde für professionelle Swing- und Momentum-Trader entwickelt. Er kombiniert Mean Reversion (Mean Reversion Bounces) und Momentum Breakout Setups (inspiriert von Kristjan Qullamaggie) in einem einzigen System.

Dank des integrierten Echtzeit-Dashboards oben rechts behältst du die wichtigsten Markt-Rahmenbedingungen, Sektoren-Zugehörigkeiten und technischen Kennzahlen der Aktie immer im Auge – direkt auf deinem Chart.

🌟 Kernfunktionen:
1. Mean Reversion Setups (Oversold/Overbought Bounces)
Kanal-Verhalten: Erkennung extremer Kursabweichungen über Bollinger Bänder und den RSI.
Filterung durch Markt-Kompass: Signale werden nur freigegeben, wenn der Markt-Index ruhig ist (Index ADX < 25) und keine Panik herrscht (VIX < 25).
Risiko-Rendite (R:R) Check: Automatische Berechnung von Stop Loss (basierend auf ATR) und Target (EMA 20). Signale werden nur geplottet, wenn ein Mindest-R:R-Verhältnis von 1,5 erreicht wird.
Earnings-Blocker: Blockiert Signale 48 Stunden vor Earnings, um Gap-Risiken zu minimieren.
2. Momentum Breakout Setups (Kullamägi-Style)
EMA Alignment: Überprüfung auf gestapelte EMAs (10 EMA > 20 EMA > 50 SMA > 200 SMA).
Volatility Squeeze: Filterung nach Bollinger Band Width Percentile (BBWP) im Squeeze-Bereich (BBWP < 40 %).
Volume Dryup & Breakout: Erkennt Volumen-Austrocknung und markiert den Ausbruch über das N-Tages-Hoch bei steigendem Volumen.
3. Interaktives Dashboard-Table (Top Right)
Live-Überwachung von Benchmark-Indizes (SPY/QQQ/IWM) inkl. ADX.
Anzeige des aktuellen VIX-Werts.
Automatisches Mapping des Tickers zu seinem Sektor-ETF (z. B. XLK, SMH, XLI) sowie dem Markt-Anker.
Dynamischer Status der verbleibenden Tage bis zu den nächsten Earnings.
4. Alarm & Webhook-Unterstützung (Automatisiertes Trading)
Der Indikator gibt ein numerisches Signal aus, das perfekt für die Anbindung an externe Webhooks (z. B. dein AI-Trading-Cockpit) vorbereitet ist:

1.0 = Mean Reversion BUY
-1.0 = Mean Reversion SELL
2.0 = Momentum BUY
0.0 = Kein Signal
⚙️ Einstellungsoptionen:
Benchmark Markt-Index: Wähle zwischen SPY, QQQ oder IWM.
VIX-Warnschwelle: Anpassbares Limit für Marktunruhe.
Risikomanagement: ATR-Periodenlänge und ATR-Multiplikator zur Bestimmung des Stop-Losses.
Momentum-Einstellungen: Aktivierung/Deaktivierung des Momentum-Screeners, Squeeze-Schwelle und Ausbruchs-Lookback.
💻 Pine Script Version:
Pine Script v6 (Aktuellster Standard von TradingView)

## Source Code

````pine
//@version=6
indicator("Mean Reversion Dashboard & Screener v6", overlay=true, precision=2)

// ==========================================
// 1. ENUMS & INPUTS
// ==========================================
enum IndexType
    spy = "S&P 500 (SPY)"
    qqq = "Nasdaq 100 (QQQ)"
    iwm = "Russell 2000 (IWM)"

gp_market  = "Markt-Filter (Übergeordnet)"
index_input = input.enum(IndexType.spy, "Benchmark Markt-Index", group=gp_market)
vix_limit  = input.int(25, "VIX Warn-Schwelle (Panik)", minval=10, maxval=50, group=gp_market)

gp_bb      = "Bollinger Bänder (Mittelwert)"
bb_len     = input.int(20, "Länge (Periode)", minval=5, group=gp_bb)
bb_mult    = input.float(2.0, "Standardabweichung (Multiplier)", minval=1.0, maxval=4.0, step=0.1, group=gp_bb)

gp_rsi     = "RSI Einstellungen"
rsi_len    = input.int(14, "RSI Periode", minval=2, group=gp_rsi)
rsi_os     = input.int(30, "Überverkauft Schwelle (OS)", minval=10, maxval=50, group=gp_rsi)
rsi_ob     = input.int(70, "Überkauft Schwelle (OB)", minval=50, maxval=90, group=gp_rsi)

gp_indiv   = "Individuelle Filter (Aktie)"
adx_limit  = input.int(25, "Aktien ADX Trend-Schwelle", minval=10, maxval=50, group=gp_indiv)
bbwp_limit = input.int(20, "Mindest-BBWP (Volatilitäts-Expansion)", minval=0, maxval=100, group=gp_indiv)
bbwp_look  = input.int(252, "BBWP Lookback Periode", minval=20, group=gp_indiv)

gp_risk    = "Risikomanagement"
atr_len    = input.int(14, "ATR Länge für Stop Loss", minval=2, group=gp_risk)
atr_mult   = input.float(1.5, "ATR Multiplikator", minval=0.5, maxval=4.0, step=0.1, group=gp_risk)
min_rr     = input.float(1.5, "Mindest R:R Verhältnis", minval=0.5, step=0.1, group=gp_risk)
block_on_earnings = input.bool(true, "Bei Earnings blockieren", group=gp_risk)

gp_mom     = "Momentum Breakout (Kullamägi)"
enable_mom = input.bool(true, "Momentum-Ausbrüche scannen", group=gp_mom)
mom_len    = input.int(10, "Ausbruchs-Periode (N-Tage)", minval=2, group=gp_mom)
mom_squeeze = input.int(40, "Max. BBWP für Squeeze (%)", minval=1, maxval=100, group=gp_mom)
mom_vol    = input.float(1.3, "Mindest-Volumen Multiplikator", minval=0.5, step=0.1, group=gp_mom)

// ==========================================
// 2. MATHEMATISCHE BERECHNUNGEN (LOKAL)
// ==========================================
mean_ma   = ta.ema(close, bb_len)
std_dev   = ta.stdev(close, bb_len)
upper_bb  = mean_ma + bb_mult * std_dev
lower_bb  = mean_ma - bb_mult * std_dev
rsi_val   = ta.rsi(close, rsi_len)
atr_val   = ta.atr(atr_len)

// Momentum MAs
ema10     = ta.ema(close, 10)
ema20     = ta.ema(close, 20)
sma50     = ta.sma(close, 50)
sma200    = ta.sma(close, 200)

// BBWP (Bollinger Band Width Percentile)
bb_width = (upper_bb - lower_bb) / mean_ma * 100
bbwp      = ta.percentrank(bb_width, bbwp_look)

// ADX der Aktie
[_, _, local_adx] = ta.dmi(14, 14)

// ==========================================
// 3. DATENABFRAGEN (BENCHMARKS)
// ==========================================
index_symbol = switch index_input
    IndexType.spy => "SPY"
    IndexType.qqq => "QQQ"
    IndexType.iwm => "IWM"

// Funktion für den Index-ADX
f_index_adx() =>
    [_, _, adx_val] = ta.dmi(14, 14)
    adx_val

index_adx   = request.security(index_symbol, timeframe.period, f_index_adx())
index_close = request.security(index_symbol, timeframe.period, close)
index_ma50  = request.security(index_symbol, timeframe.period, ta.sma(close, 50))
vix_close   = request.security("VIX", timeframe.period, close)

// ==========================================
// 4. SIGNAL-LOGIK & VALIDIERUNG
// ==========================================
// Filterbedingungen
vix_ok       = vix_close < vix_limit
index_ok     = index_adx < 25
stock_adx_ok = local_adx < adx_limit
bbwp_ok      = bbwp >= bbwp_limit

// Dynamische Earnings-Prüfung
days_to_earnings = not na(earnings.future_time) ? (earnings.future_time - timenow) / 86400000.0 : na
has_earnings_soon = not na(days_to_earnings) and days_to_earnings <= 2.0 and days_to_earnings >= -0.5
earnings_block    = block_on_earnings and has_earnings_soon

// Struktur-Setups
long_setup  = (close < lower_bb) and (rsi_val < rsi_os)
short_setup = (close > upper_bb) and (rsi_val > rsi_ob)

// Risiko-Rendite-Prüfung
long_risk   = close - (low - atr_val * atr_mult)
long_reward = mean_ma - close
long_rr     = long_risk > 0.0 ? long_reward / long_risk : 0.0
long_rr_ok  = (long_reward > 0.0) and (long_rr >= min_rr)

short_risk   = (high + atr_val * atr_mult) - close
short_reward = close - mean_ma
short_rr     = short_risk > 0.0 ? short_reward / short_risk : 0.0
short_rr_ok  = (short_reward > 0.0) and (short_rr >= min_rr)

// Finale, gefilterte Signale (Mean Reversion)
long_signal  = long_setup and vix_ok and index_ok and stock_adx_ok and bbwp_ok and long_rr_ok and not earnings_block
short_signal = short_setup and vix_ok and index_ok and stock_adx_ok and bbwp_ok and short_rr_ok and not earnings_block

// Momentum-Breakout-Bedingungen
ema_stacked   = ema10 > ema20 and ema20 > sma50 and sma50 > sma200
index_mkt_ok  = index_close > index_ma50
mom_vix_ok    = vix_close < 25
bbwp_squeeze  = bbwp < mom_squeeze
volume_dryup  = ta.sma(volume, 3) < ta.sma(volume, 20)
breakout_trig = high > ta.highest(high, mom_len)[1]
volume_ok     = volume > ta.sma(volume, 20) * mom_vol

// Finale Momentum-Signal
momentum_signal = enable_mom and ema_stacked and index_mkt_ok and mom_vix_ok and bbwp_squeeze and volume_dryup and breakout_trig and volume_ok and not earnings_block

// Numerisches Signal für Screener (1=MR Buy, -1=MR Sell, 2=Momentum Buy)
screener_sig = long_signal ? 1.0 : (short_signal ? -1.0 : (momentum_signal ? 2.0 : 0.0))

// ==========================================
// 5. VISUALISIERUNG AUF DEM CHART
// ==========================================
plot(mean_ma, "Mittelwert (20 EMA)", color=color.orange, linewidth=1, display=display.all - display.data_window)
p_upper = plot(upper_bb, "Oberes Band (Überkauft)", color=color.red, linestyle=plot.linestyle_dashed, display=display.all - display.data_window)
p_lower = plot(lower_bb, "Unteres Band (Überverkauft)", color=color.green, linestyle=plot.linestyle_dashed, display=display.all - display.data_window)
fill(p_upper, p_lower, color=color.new(color.blue, 96), title="Hintergrundband")

// Signale zeichnen
plotshape(long_signal, "BUY (Validated)", shape.triangleup, location.belowbar, color.green, size=size.normal, display=display.all - display.data_window)
plotshape(short_signal, "SELL (Validated)", shape.triangledown, location.abovebar, color.red, size=size.normal, display=display.all - display.data_window)
plotshape(momentum_signal, "MOMENTUM BUY", shape.arrowup, location.belowbar, color.blue, size=size.normal, display=display.all - display.data_window)

// Dynamische Stop-Loss & Take-Profit Vorschau für den aktuellen Bar (falls Signal)
if (long_signal)
    label.new(bar_index, low - 2 * atr_val, 
       text="LONG\nTP (EMA20): " + str.tostring(mean_ma, "#.##") + "\nSL: " + str.tostring(low - atr_val * atr_mult, "#.##") + "\nR:R: " + str.tostring(long_rr, "#.##"), 
       color=color.green, textcolor=color.white, style=label.style_label_up)
if (short_signal)
    label.new(bar_index, high + 2 * atr_val, 
       text="SHORT\nTP (EMA20): " + str.tostring(mean_ma, "#.##") + "\nSL: " + str.tostring(high + atr_val * atr_mult, "#.##") + "\nR:R: " + str.tostring(short_rr, "#.##"), 
       color=color.red, textcolor=color.white, style=label.style_label_down)

// ==========================================
// 6. SCREENER-AUSGABEN (Unsichtbar)
// ==========================================
plot(screener_sig, "Screener Signal", display=display.none)
plot(nz(rsi_val, 50.0), "RSI Wert", display=display.none)
plot(nz(bbwp, 0.0), "BBWP %", display=display.none)
plot(nz(local_adx, 0.0), "Aktie ADX", display=display.none)
plot(nz(index_adx, 0.0), "Index ADX", display=display.none)
plot(nz(vix_close, 20.0), "VIX Wert", display=display.none)

// Helper-Funktion zur Bestimmung des Sektor-ETFs (Ausgerichtet an deiner Liste)
f_get_sector_etf() =>
    s = syminfo.sector
    ind = syminfo.industry
    t = syminfo.ticker
    etf = "N/A"
    
    // Check MAGS (Magnificent 7)
    is_mags = (t == "AAPL" or t == "MSFT" or t == "NVDA" or t == "AMZN" or t == "META" or t == "GOOG" or t == "GOOGL" or t == "TSLA")
    
    if is_mags
        etf := "MAGS (Mag 7)"
    else if not na(ind) and (str.contains(str.lower(ind), "semiconductor"))
        etf := "SMH (Semiconductors)"
    else if not na(ind) and (str.contains(str.lower(ind), "software"))
        etf := "IGV (Software)"
    else if not na(ind) and (str.contains(str.lower(ind), "aerospace") or str.contains(str.lower(ind), "defense"))
        etf := "ITA (Aerospace/Defense)"
    else if not na(s)
        if s == "Electronic Technology" or s == "Technology Services"
            etf := "XLK (Technology)"
        else if s == "Finance"
            etf := "XLF (Financials)"
        else if s == "Health Technology" or s == "Health Services"
            etf := "XLV (Healthcare)"
        else if s == "Utilities"
            etf := "XLU (Utilities)"
        else if s == "Consumer Non-Durables"
            etf := "XLP (Staples)"
        else if s == "Consumer Services"
            etf := "XLY (Discretionary)"
        else if s == "Energy Minerals" or s == "Non-Energy Minerals"
            etf := "XLE (Energy)"
        else if s == "Producer Manufacturing" or s == "Transportation"
            etf := "XLI (Industrials)"
        else if s == "Process Industries" or s == "Distribution Services"
            etf := "XLB (Materials)"
        else if s == "Communications"
            etf := "XLC (Communications)"
        else if s == "Real Estate"
            etf := "XLRE (Real Estate)"
        else
            etf := s
    etf

// Helper-Funktion zur Bestimmung der Index-Zugehörigkeit (Markt-Anker)
f_get_stock_index() =>
    t = syminfo.ticker
    // Dow 30 Komponenten
    is_dow = (t == "AAPL" or t == "AMZN" or t == "AMGN" or t == "AXP" or t == "BA" or t == "CAT" or t == "CRM" or t == "CSCO" or t == "CVX" or t == "DIS" or t == "GS" or t == "HD" or t == "HON" or t == "IBM" or t == "INTC" or t == "JNJ" or t == "JPM" or t == "KO" or t == "MCD" or t == "MMM" or t == "MRK" or t == "MSFT" or t == "NKE" or t == "PG" or t == "SHW" or t == "TRV" or t == "UNH" or t == "V" or t == "WMT" or t == "VZ")
    
    // Top Nasdaq 100 Komponenten (nicht im Dow 30)
    is_nasdaq100 = (t == "NVDA" or t == "GOOG" or t == "GOOGL" or t == "META" or t == "TSLA" or t == "AVGO" or t == "COST" or t == "ADBE" or t == "PEP" or t == "NFLX" or t == "CMG" or t == "AMD" or t == "TXN" or t == "QCOM" or t == "INTU" or t == "AMAT" or t == "ISRG" or t == "MU" or t == "LRCX" or t == "REGN" or t == "PANW" or t == "MDLZ" or t == "KLAC" or t == "SNPS" or t == "CDNS" or t == "ASML" or t == "CSX" or t == "PDD" or t == "MELI" or t == "MAR" or t == "PYPL" or t == "NXPI" or t == "ADSK" or t == "MNST" or t == "LULU" or t == "KDP" or t == "ODFL" or t == "FTNT" or t == "ORLY" or t == "WDAY" or t == "MCHP" or t == "ADI" or t == "IDXX" or t == "CPRT" or t == "CTAS" or t == "SBUX" or t == "GILD" or t == "VRTX" or t == "DXCM" or t == "ROST")
    
    if is_dow
        "DIA (Dow 30)"
    else if is_nasdaq100
        "QQQ (Nasdaq 100)"
    else if syminfo.prefix == "NASDAQ" or syminfo.prefix == "NYSE"
        "SPY (S&P 500)"
    else
        "IWM (Russell 2000)"

// ==========================================
// 7. DASHBOARD TABLE
// ==========================================
var table info_table = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 15), border_color=color.black, border_width=1)
if barstate.islast
    // Header
    table.cell(info_table, 0, 0, "Filter-Metrik", text_color=color.white, bgcolor=color.gray)
    table.cell(info_table, 1, 0, "Wert / Status", text_color=color.white, bgcolor=color.gray)
    
    // Markt-Index
    table.cell(info_table, 0, 1, "Benchmark Index", text_color=color.white)
    table.cell(info_table, 1, 1, index_symbol + " (ADX: " + str.tostring(index_adx, "#.#") + ")", text_color=index_ok ? color.green : color.red)
    
    // VIX
    table.cell(info_table, 0, 2, "CBOE VIX", text_color=color.white)
    table.cell(info_table, 1, 2, str.tostring(vix_close, "#.##"), text_color=vix_ok ? color.green : color.red)
    
    // Aktien-ADX
    table.cell(info_table, 0, 3, "Aktien ADX", text_color=color.white)
    table.cell(info_table, 1, 3, str.tostring(local_adx, "#.#"), text_color=stock_adx_ok ? color.green : color.red)
    
    // BBWP
    table.cell(info_table, 0, 4, "BBWP (Volatilität)", text_color=color.white)
    table.cell(info_table, 1, 4, str.tostring(bbwp, "#") + "%", text_color=bbwp_ok ? color.green : color.orange)
    
    // RSI
    table.cell(info_table, 0, 5, "RSI (14)", text_color=color.white)
    table.cell(info_table, 1, 5, str.tostring(rsi_val, "#.##"), text_color=rsi_val < rsi_os ? color.green : rsi_val > rsi_ob ? color.red : color.white)
    
    // Signal
    status_text  = long_signal ? "A+ LONG SIGNALIERT" : short_signal ? "A+ SHORT SIGNALIERT" : momentum_signal ? "A+ MOMENTUM BUY" : "Kein Signal"
    status_color = long_signal ? color.green : short_signal ? color.red : momentum_signal ? color.blue : color.white
    table.cell(info_table, 0, 6, "Signal-Status", text_color=color.white)
    table.cell(info_table, 1, 6, status_text, text_color=status_color, bgcolor=long_signal ? color.new(color.green, 80) : short_signal ? color.new(color.red, 80) : momentum_signal ? color.new(color.blue, 80) : na)

    earnings_text = na(days_to_earnings) ? "Keine Daten (OK)" : has_earnings_soon ? "EARNINGS IN " + str.tostring(math.round(days_to_earnings * 10) / 10) + " T.!" : "In " + str.tostring(math.round(days_to_earnings)) + " Tagen (OK)"
    earnings_color = has_earnings_soon ? color.red : color.green
    earnings_bg = has_earnings_soon ? color.new(color.red, 80) : na
    
    table.cell(info_table, 0, 7, "Earnings Status", text_color=color.white)
    table.cell(info_table, 1, 7, earnings_text, text_color=earnings_color, bgcolor=earnings_bg)

    // Index-Anker
    stock_index = f_get_stock_index()
    table.cell(info_table, 0, 8, "Index-Anker", text_color=color.white)
    table.cell(info_table, 1, 8, stock_index, text_color=color.white)

    // Sektor / ETF
    sector_etf = f_get_sector_etf()
    table.cell(info_table, 0, 9, "Sektor / ETF", text_color=color.white)
    table.cell(info_table, 1, 9, sector_etf, text_color=color.white)
    
    // Branche (Industry)
    ind_text = na(syminfo.industry) ? "N/A" : syminfo.industry
    table.cell(info_table, 0, 10, "Branche", text_color=color.white)
    table.cell(info_table, 1, 10, ind_text, text_color=color.white)

// ==========================================
// 8. PLOTS FOR WEBHOOK PAYLOAD (Unsichtbar)
// ==========================================
plot(nz(ema10, close), "Daily EMA10", display=display.none)
plot(nz(ema20, close), "Daily EMA20", display=display.none)
vol_ratio = nz(volume / ta.sma(volume, 20), 1.0)
plot(vol_ratio, "Daily Volume Ratio", display=display.none)

// ==========================================
// 9. ALERTS
// ==========================================
combined_signal = long_signal or short_signal or momentum_signal
alertcondition(combined_signal, "Kombiniertes Signal (BUY oder SELL)", "A+ Setup auf {{ticker}} bei {{close}} (Signal: {{plot(\"Screener Signal\")}} -> 1=BUY/LONG, -1=SELL/SHORT, 2=MOMENTUM)")
alertcondition(long_signal, "LONG Signal", "A+ LONG Mean Reversion für {{ticker}} bei {{close}} (RSI: {{plot(\"RSI Wert\")}})")
alertcondition(short_signal, "SHORT Signal", "A+ SHORT Mean Reversion für {{ticker}} bei {{close}} (RSI: {{plot(\"RSI Wert\")}})")
alertcondition(momentum_signal, "MOMENTUM Signal", "A+ Momentum Breakout für {{ticker}} bei {{close}} (Squeeze BBWP: {{plot(\"BBWP %\")}})")
````
