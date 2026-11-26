# ORB Strategy Timo v14

- url: https://www.tradingview.com/script/rjmHFn2F/
- type: indicator
- pine_id: PUB;91b2957000a64e19ad00948ff320a0ec
- version: 9.0

## Description

ORB Strategy — Timo v2 [NQ/MNQ/MGC/MCL]
🔷 Opening Range Breakout — Complete Trading System
The most complete ORB indicator for futures traders. Built specifically for NQ, MNQ, MGC and MCL — but works on any instrument and timeframe.
This is not just an ORB box. It's a full trading system combining breakout detection, trend filters, volume confirmation, trap protection and a live multi-timeframe dashboard — all in one script.
⚡ What makes this different
Most ORB indicators just draw a box. This one tells you:
✅ Is the breakout real — or a fake (Trap Detection)
✅ Is the trend aligned — EMA 9/21/50 filter
✅ Is the volume confirming — Volume Spike analysis
✅ Is the setup worth taking — Quality Score 0–100
✅ What are all timeframes doing — MTF Dashboard M1–D1
📦 Features (14 total)
ORB Box & Sessions
Two independent sessions: London Open (03:00–03:15 ET) and NY Open (09:30–09:45 ET)
Session box grows live during the window, freezes at close
Zone remains visible all day until 00:00 ET midnight reset
Both London AND NY zones visible simultaneously after 15:45 CET
ORH / ORL labels at each level
Equilibrium line at 50% of range (style, width, color all adjustable)
All colors independently configurable per session
EMA 9 / 21 / 50
Three exponential moving averages as trend filter
EMA 9 > 21 = bullish → only BUY signals allowed
EMA 9 < 21 = bearish → only SELL signals allowed
EMA± cross markers at every crossover
All colors and widths adjustable
VWAP
Daily volume-weighted average price
Institutional reference level — smart money reference
VP± cross markers at every crossover
Color and width adjustable
BUY / SELL Signals
Signal arrow appears only when ALL active filters confirm simultaneously:
M1 close outside ORB range (breakout)
EMA alignment in breakout direction
Price on correct VWAP side
Optional: M15 / M5 close confirmation
Optional: First signal per session only
Signal Filters (5 total, all individually toggleable)
Filter
Default
Purpose
EMA Alignment
ON
No counter-trend trades
VWAP Side
ON
With institutional flow
M15 Confirmation
OFF
Safer, fewer signals
M5 Confirmation
OFF
Additional confirmation
First Signal Only
ON
Max 1 trade per session
SL / TP Lines
Automatic dotted lines at signal: Entry (white), SL (red), TP (green)
Price labels right side showing exact levels
Fully configurable: ticks, colors, line length
Linear Regression Trend Channel
2x Standard Deviation channel (covers ~95% of price action)
Dynamic midline: green = uptrend, red = downtrend
Channel width (length), colors, fill all adjustable
MTF Dashboard
Live multi-timeframe bias table (position adjustable):
7 timeframes: M1 · M5 · M15 · M30 · H1 · H4 · D1
Green dot = EMA9 > EMA21 (bullish) | Red dot = bearish
Current signal: BUY / SELL / NEUTRAL
Live ORB levels + Volume ratio + Quality Score
Volume Spike
Color-coded histogram (green/red per candle, gold on spike)
Configurable spike threshold (default: 1.5x average)
Vol label at signal: "VOL SPIKE 2.3x CONFIRMED" or "Vol 0.8x (no spike)"
MA length adjustable
ORB Quality Score (0–100)
Rates the ORB range before you trade:
70–100: SETUP GOOD → Range is ideal, take the trade
40–69: SETUP OK → Acceptable, trade carefully
0–39: SETUP WEAK → Too small or too large, wait
Based on ATR(14) ratio — label appears right after ORB close
Red background warning when score < 40
Trap Detection
Identifies fake breakouts automatically:
BULL TRAP: Price breaks above ORH but returns within X bars → buyers trapped
BEAR TRAP: Price breaks below ORL but returns within X bars → sellers trapped
Label + background highlight on detection
Bars threshold adjustable (default: 3)
Dedicated alert condition
ORB Statistics Box
Daily trade tracker (resets at configurable hour ET):
Trades / Wins / Losses / Win Rate / Simulated P&L / Status
Color coded: green ≥ 60% WR, yellow ≥ 40%, red below
Position adjustable (4 corners)
⚙️ Settings Overview
14 groups in the settings panel:
London Session (times, 4 colors)
NY Open Session (times, 4 colors)
ORB Box & Lines (box, lines, labels, midline, background)
EMA Settings (periods, colors, cross markers)
VWAP Settings (color, width, cross markers)
Signal Arrows (colors, size: Tiny/Small/Normal/Large)
Signal Filter (5 toggles)
SL / TP (ticks, colors, length)
Trend Channel (length, colors, fill)
MTF Dashboard (position, signal name)
Volume Spike (MA length, threshold, colors)
ORB Quality Score (ATR length, min/max range %, colors)
Trap Detection (bars threshold, colors, alert toggle)
ORB Statistics Box (position, reset hour)
📐 Recommended Setup
Setting
Value
Timeframe
M1 (entry)
London ET
03:00–03:15
NY Open ET
09:30–09:45
TV Timezone
America/New_York
EMA Filter
ON
VWAP Filter
ON
M15/M5 Filter
OFF (optional)
SL Ticks NQ
40 = $200
TP Ticks NQ
80 = $400
SL Ticks MNQ
40 = $60
TP Ticks MNQ
80 = $120
🔔 Alerts (9 total)
ORB BUY Signal
ORB SELL Signal
EMA Cross UP / DOWN (in session)
VWAP Cross UP / DOWN (in session)
ORB Range Set (window closed, ready for breakout)
BULL TRAP detected
BEAR TRAP detected
📋 Tags
ORB opening range breakout NQ MNQ MGC MCL futures prop firm Topstep IQ Capital session EMA VWAP breakout trap detection volume multi timeframe dashboard quality score linear regression
Built for prop firm traders on NQ/MNQ. Respects IQ Capital Position Loss (0.5% = $250/trade) and Topstep Trailing Drawdown rules by design.
This indicator is for informational purposes only. Past performance does not guarantee future results. Always trade with proper risk management.

## Source Code

````pine
//@version=6
indicator('ORB Strategy — Timo v2 [NQ/MNQ/MGC/MCL]', shorttitle = 'ORB·Timo·v2', overlay = true, max_boxes_count = 20, max_lines_count = 500, max_labels_count = 200)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 1 — LONDON SESSION
// ═══════════════════════════════════════════════════════════════════════════════
grp_ldn = '━━━ LONDON SESSION ━━━'
ldn_enable = input.bool(true, 'London Session aktiv', group = grp_ldn)
ldn_h_start = input.int(3, 'Start Stunde (ET)', minval = 0, maxval = 23, group = grp_ldn, tooltip = '09:00 CET = 03:00 ET')
ldn_m_start = input.int(0, 'Start Minute', minval = 0, maxval = 59, group = grp_ldn)
ldn_h_end = input.int(3, 'Ende Stunde (ET)', minval = 0, maxval = 23, group = grp_ldn, tooltip = '09:15 CET = 03:15 ET')
ldn_m_end = input.int(15, 'Ende Minute', minval = 0, maxval = 59, group = grp_ldn)
ldn_bg_color = input.color(color.new(#00d4ff, 92), 'Session Background', group = grp_ldn)
ldn_box_color = input.color(color.new(#00d4ff, 75), 'ORB Box Fill', group = grp_ldn)
ldn_line_color = input.color(color.new(#00d4ff, 15), 'ORB H/L Linien', group = grp_ldn)
ldn_lbl_color = input.color(color.new(#00d4ff, 10), 'Label Hintergrund', group = grp_ldn)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 2 — NY OPEN SESSION
// ═══════════════════════════════════════════════════════════════════════════════
grp_ny = '━━━ NY OPEN SESSION ━━━'
ny_enable = input.bool(true, 'NY Open Session aktiv', group = grp_ny)
ny_h_start = input.int(9, 'Start Stunde (ET)', minval = 0, maxval = 23, group = grp_ny, tooltip = '15:30 CET = 09:30 ET')
ny_m_start = input.int(30, 'Start Minute', minval = 0, maxval = 59, group = grp_ny)
ny_h_end = input.int(9, 'Ende Stunde (ET)', minval = 0, maxval = 23, group = grp_ny, tooltip = '15:45 CET = 09:45 ET')
ny_m_end = input.int(45, 'Ende Minute', minval = 0, maxval = 59, group = grp_ny)
ny_bg_color = input.color(color.new(#ffd700, 92), 'Session Background', group = grp_ny)
ny_box_color = input.color(color.new(#ffd700, 75), 'ORB Box Fill', group = grp_ny)
ny_line_color = input.color(color.new(#ffd700, 15), 'ORB H/L Linien', group = grp_ny)
ny_lbl_color = input.color(color.new(#ffd700, 10), 'Label Hintergrund', group = grp_ny)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 3 — ORB BOX & LINIEN
// ═══════════════════════════════════════════════════════════════════════════════
grp_orb = '━━━ ORB BOX & LINIEN ━━━'
show_orb_box = input.bool(true, 'ORB Box anzeigen', group = grp_orb)
show_orb_lines = input.bool(true, 'ORB H/L Linien extended', group = grp_orb)
show_orb_label = input.bool(true, 'Labels anzeigen (H/L Preis)', group = grp_orb)
orb_border_col = input.color(color.new(#ffffff, 60), 'Box Rahmen Farbe', group = grp_orb)
orb_line_width = input.int(1, 'Linien Breite', minval = 1, maxval = 4, group = grp_orb)
show_mid_line = input.bool(true, 'Mittellinie (50% Level) anzeigen', group = grp_orb)
mid_line_color = input.color(color.new(#ffffff, 40), 'Mittellinie Farbe', group = grp_orb)
mid_line_width = input.int(1, 'Mittellinie Breite', minval = 1, maxval = 4, group = grp_orb)
mid_line_style_s = input.string('Dotted', 'Mittellinie Stil', options = ['Solid', 'Dashed', 'Dotted'], group = grp_orb)
show_orb_bg = input.bool(true, 'Hintergrund H/L Zone anzeigen', group = grp_orb)
orb_bg_ldn = input.color(color.new(#00d4ff, 88), 'Hintergrund London', group = grp_orb)
orb_bg_ny = input.color(color.new(#ffd700, 88), 'Hintergrund NY', group = grp_orb)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 4 — EMA
// ═══════════════════════════════════════════════════════════════════════════════
grp_ema = '━━━ EMA EINSTELLUNGEN ━━━'
show_ema = input.bool(true, 'EMAs anzeigen', group = grp_ema)
ema_fast_len = input.int(9, 'EMA Fast Periode', minval = 1, group = grp_ema)
ema_slow_len = input.int(21, 'EMA Slow Periode', minval = 1, group = grp_ema)
ema_fast_color = input.color(#ffd700, 'EMA Fast Farbe (9)', group = grp_ema)
ema_slow_color = input.color(#ff6b35, 'EMA Slow Farbe (21)', group = grp_ema)
ema_width = input.int(1, 'EMA Breite', minval = 1, maxval = 4, group = grp_ema)
show_ema50 = input.bool(true, 'EMA 50 anzeigen', group = grp_ema)
ema50_len = input.int(50, 'EMA 50 Periode', minval = 1, group = grp_ema)
ema50_color = input.color(#3498db, 'EMA 50 Farbe', group = grp_ema)
ema50_width = input.int(1, 'EMA 50 Breite', minval = 1, maxval = 4, group = grp_ema)
show_ema_cross = input.bool(true, 'EMA Cross Signal anzeigen', group = grp_ema)
ema_cross_bull_color = input.color(#ffd700, 'EMA Cross UP Farbe', group = grp_ema)
ema_cross_bear_color = input.color(#ff6b35, 'EMA Cross DOWN Farbe', group = grp_ema)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 5 — VWAP
// ═══════════════════════════════════════════════════════════════════════════════
grp_vwap = '━━━ VWAP EINSTELLUNGEN ━━━'
show_vwap = input.bool(true, 'VWAP anzeigen', group = grp_vwap)
vwap_color = input.color(#9b59b6, 'VWAP Farbe', group = grp_vwap)
vwap_width = input.int(2, 'VWAP Breite', minval = 1, maxval = 4, group = grp_vwap)
show_vwap_cross = input.bool(true, 'VWAP Cross Signal anzeigen', group = grp_vwap)
vwap_cross_bull = input.color(color.new(#9b59b6, 20), 'VWAP Cross UP Farbe', group = grp_vwap)
vwap_cross_bear = input.color(color.new(#9b59b6, 20), 'VWAP Cross DOWN Farbe', group = grp_vwap)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 6 — SIGNAL PFEILE
// ═══════════════════════════════════════════════════════════════════════════════
grp_sig = '━━━ SIGNAL PFEILE ━━━'
buy_arrow_color = input.color(#00ff88, 'BUY Pfeil Farbe', group = grp_sig)
sell_arrow_color = input.color(#ff4444, 'SELL Pfeil Farbe', group = grp_sig)
sig_tiny = input.bool(false, 'Pfeil Tiny — nur eine Option waehlen!', group = grp_sig)
sig_small = input.bool(false, 'Pfeil Small — nur eine Option waehlen!', group = grp_sig)
sig_large = input.bool(false, 'Pfeil Large — nur eine Option waehlen!', group = grp_sig)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 7 — SIGNAL FILTER
// ═══════════════════════════════════════════════════════════════════════════════
grp_filter = '━━━ SIGNAL FILTER ━━━'
use_ema_filter = input.bool(true, 'Filter: EMA Ausrichtung', group = grp_filter, tooltip = 'BUY nur wenn EMA9>EMA21 | SELL wenn EMA9<EMA21')
use_vwap_filter = input.bool(true, 'Filter: VWAP Seite', group = grp_filter, tooltip = 'BUY nur wenn Preis>VWAP | SELL wenn Preis<VWAP')
use_m15_filter = input.bool(false, 'Filter: M15 Close bestaetigt', group = grp_filter, tooltip = 'M15 Kerze muss ausserhalb ORB geschlossen haben')
use_m5_filter = input.bool(false, 'Filter: M5 Close bestaetigt', group = grp_filter, tooltip = 'M5 Kerze muss ausserhalb ORB geschlossen haben')
use_first_only = input.bool(true, 'Nur erstes Signal pro Session', group = grp_filter, tooltip = 'Verhindert Mehrfach-Signale pro ORB Session')
use_orb_range_filter = input.bool(false, 'Filter: ORB Range Min/Max', group = grp_filter, tooltip = 'Blockiert Signale wenn die ORB Range zu klein oder zu gross ist (in Punkten)')
max_orb_points = input.float(80.0, 'Max ORB Range (Punkte)', minval = 1.0, group = grp_filter, tooltip = 'ORB Range darf nicht groesser sein als X Punkte')
min_orb_points = input.float(10.0, 'Min ORB Range (Punkte)', minval = 0.1, group = grp_filter, tooltip = 'ORB Range muss mindestens X Punkte betragen')
use_retest_filter = input.bool(false, 'Filter: ORB Retest bestaetigt', group = grp_filter, tooltip = 'BUY erst nach Retest der ORH | SELL erst nach Retest der ORL — Breakout muss erst zurueck zur Linie kommen, dann erneut bestaetigen')
retest_ticks = input.int(50, 'Retest Toleranz (Ticks)', minval = 1, maxval = 200, group = grp_filter, tooltip = 'Wie nah muss der Preis an die ORH/ORL kommen — fuer NQ empfohlen: 50-100 Ticks')

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 8 — SL/TP
// ═══════════════════════════════════════════════════════════════════════════════
grp_sltp = '━━━ STOP LOSS / TAKE PROFIT ━━━'
show_sl_tp = input.bool(true, 'SL/TP Linien anzeigen', group = grp_sltp)
sl_tp_mode = input.string('Ticks', 'Eingabe Modus', options = ['Ticks', 'USD/Punkte'], group = grp_sltp, tooltip = 'Ticks = klassisch (z.B. 40 SL / 80 TP) | USD/Punkte = direkte Eingabe (z.B. 100 SL / 200 TP)')
sl_ticks = input.int(40, 'Stop Loss (Ticks)', minval = 1, group = grp_sltp)
tp_ticks = input.int(80, 'Take Profit (Ticks)', minval = 1, group = grp_sltp)
sl_usd = input.float(100.0, 'Stop Loss (USD/Punkte)', minval = 0.25, step = 25.0, group = grp_sltp, tooltip = 'Nur aktiv wenn Modus = USD/Punkte')
tp_usd = input.float(200.0, 'Take Profit (USD/Punkte)', minval = 0.25, step = 25.0, group = grp_sltp, tooltip = 'Nur aktiv wenn Modus = USD/Punkte')
use_tp_relative = input.bool(false, 'TP relativ zur ORB Range', group = grp_sltp, tooltip = 'AN: TP wird taeglich neu berechnet als Faktor x ORB Range, statt fester Ticks/USD-Wert. SL bleibt unabhaengig davon fix (Ticks oder USD/Punkte oben).')
tp_orb_factor = input.float(1.2, 'TP Faktor (x ORB Range)', minval = 0.3, maxval = 3.0, step = 0.1, group = grp_sltp, tooltip = 'Nur aktiv wenn TP relativ zur ORB Range AN ist. NQ 15-Min Daten zeigen median ca. 1.1x Range als typische Fortsetzung — 1.2 ist ein leicht konservativerer Default.')
use_auto_contracts = input.bool(false, 'Automatische Kontrakte je Symbol', group = grp_sltp, tooltip = 'AN: Nutzt automatisch die passende Kontrakt-Zahl je nachdem ob du auf NQ oder MNQ bist. AUS: manueller Wert unten wird immer verwendet.')
contracts_nq = input.int(1, 'Kontrakte NQ', minval = 1, maxval = 50, group = grp_sltp, tooltip = 'Nur aktiv wenn Automatische Kontrakte AN ist')
contracts_mnq = input.int(2, 'Kontrakte MNQ', minval = 1, maxval = 50, group = grp_sltp, tooltip = 'Nur aktiv wenn Automatische Kontrakte AN ist')
contracts_manual = input.int(1, 'Anzahl Kontrakte (manuell)', minval = 1, maxval = 50, group = grp_sltp, tooltip = 'Nur aktiv wenn Automatische Kontrakte AUS ist')

// Symbol-Erkennung: MNQ enthaelt 'MNQ', NQ ist alles andere mit 'NQ' aber ohne 'M' davor
is_mnq_symbol = str.contains(syminfo.ticker, 'MNQ')
contracts = use_auto_contracts ? (is_mnq_symbol ? contracts_mnq : contracts_nq) : contracts_manual
sl_color = input.color(color.new(#ff4444, 0), 'SL Linie Farbe', group = grp_sltp)
tp_color = input.color(color.new(#00ff88, 0), 'TP Linie Farbe', group = grp_sltp)
entry_color = input.color(color.new(#ffffff, 0), 'Entry Linie', group = grp_sltp)
sl_tp_line_width = input.int(2, 'SL/TP/Entry Linien Dicke', minval = 1, maxval = 5, group = grp_sltp, tooltip = 'Hoehere Zahl = dickere, besser sichtbare Linien')
sl_tp_length = input.int(40, 'Linien Laenge (Bars)', minval = 5, maxval = 200, group = grp_sltp)

sl_ticks_eff = sl_tp_mode == 'USD/Punkte' ? math.round(sl_usd / (syminfo.mintick * syminfo.pointvalue)) : sl_ticks
tp_ticks_eff = sl_tp_mode == 'USD/Punkte' ? math.round(tp_usd / (syminfo.mintick * syminfo.pointvalue)) : tp_ticks
sl_usd_eff = sl_ticks_eff * syminfo.mintick * syminfo.pointvalue
tp_usd_eff = tp_ticks_eff * syminfo.mintick * syminfo.pointvalue
sl_usd_total = sl_usd_eff * contracts
tp_usd_total = tp_usd_eff * contracts

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 9 — TRENDKANAL
// ═══════════════════════════════════════════════════════════════════════════════
grp_ch = '━━━ TRENDKANAL ━━━'
show_channel = input.bool(true, 'Trendkanal anzeigen', group = grp_ch)
ch_length = input.int(80, 'Laenge (Bars)', minval = 10, maxval = 500, group = grp_ch, tooltip = '80 empfohlen fuer NQ M1 — reagiert ruhiger als 50')
ch_upper_color = input.color(color.new(#00d4ff, 20), 'Obere Linie Farbe', group = grp_ch)
ch_lower_color = input.color(color.new(#00d4ff, 20), 'Untere Linie Farbe', group = grp_ch)
ch_fill_color = input.color(color.new(#00d4ff, 92), 'Kanal Fill Farbe', group = grp_ch)
ch_width = input.int(2, 'Linien Breite', minval = 1, maxval = 4, group = grp_ch)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 10 — MTF DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
grp_dash = '━━━ MTF DASHBOARD ━━━'
show_dashboard = input.bool(true, 'Dashboard anzeigen', group = grp_dash)
dash_pos = input.string('Unten Rechts', 'Position', options = ['Unten Rechts', 'Unten Links', 'Oben Rechts', 'Oben Links'], group = grp_dash)
dash_signal_name = input.string('ORB SIGNAL', 'Signal Name', group = grp_dash)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 11 — VOLUMEN SPIKE
// ═══════════════════════════════════════════════════════════════════════════════
grp_vol = '━━━ VOLUMEN SPIKE ━━━'
show_vol = input.bool(true, 'Volumen anzeigen', group = grp_vol)
vol_ma_len = input.int(20, 'Volumen MA Laenge', minval = 5, maxval = 100, group = grp_vol)
vol_spike_mult = input.float(1.5, 'Spike Schwelle (x Durchschnitt)', minval = 1.0, maxval = 5.0, step = 0.1, group = grp_vol)
vol_bull_color = input.color(color.new(#2ecc71, 20), 'Volumen BUY Farbe', group = grp_vol)
vol_bear_color = input.color(color.new(#e74c3c, 20), 'Volumen SELL Farbe', group = grp_vol)
vol_spike_color = input.color(color.new(#ffd700, 0), 'Spike Farbe', group = grp_vol)
show_vol_label = input.bool(true, 'Vol-Label am Signal anzeigen', group = grp_vol)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 12 — ORB RANGE QUALITY SCORE
// ═══════════════════════════════════════════════════════════════════════════════
grp_qs = '━━━ ORB QUALITY SCORE ━━━'
show_quality = input.bool(true, 'Quality Score anzeigen', group = grp_qs)
qs_atr_len = input.int(14, 'ATR Laenge', minval = 5, maxval = 50, group = grp_qs)
qs_min_range_pct = input.float(0.15, 'Min. Range %% des ATR', minval = 0.05, maxval = 1.0, step = 0.05, group = grp_qs, tooltip = 'Range muss mindestens X%% des ATR sein — zu klein = schlechtes Setup. Fuer engeren NQ M1 Stil: 0.30 empfohlen')
qs_max_range_pct = input.float(2.0, 'Max. Range %% des ATR', minval = 1.0, maxval = 5.0, step = 0.1, group = grp_qs, tooltip = 'Range darf nicht groesser als X%% des ATR sein — zu gross = riskant. Fuer engeren NQ M1 Stil: 1.20 empfohlen')
qs_color_good = input.color(color.new(#2ecc71, 10), 'Score GUT Farbe', group = grp_qs)
qs_color_mid = input.color(color.new(#ffd700, 10), 'Score MITTEL Farbe', group = grp_qs)
qs_color_bad = input.color(color.new(#e74c3c, 10), 'Score SCHLECHT Farbe', group = grp_qs)
use_quality_filter = input.bool(false, 'Filter: Quality Score Minimum', group = grp_qs, tooltip = 'AN: Blockiert BUY/SELL Signale komplett wenn der Quality Score unter dem Minimum liegt (nutzt Checker Score Minimum aus Group 15). AUS: Score ist nur Anzeige, blockiert nichts.')

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 13 — ORB STATISTIK BOX
// ═══════════════════════════════════════════════════════════════════════════════
grp_stats = '━━━ ORB STATISTIK BOX ━━━'
show_stats = input.bool(true, 'Statistik Box anzeigen', group = grp_stats)
stats_pos = input.string('Oben Links', 'Position', options = ['Oben Links', 'Oben Rechts', 'Unten Links', 'Unten Rechts'], group = grp_stats)
stats_reset_hour = input.int(3, 'Reset Stunde ET (neuer Tag)', minval = 0, maxval = 6, group = grp_stats, tooltip = 'Statistik wird taeglich um diese Stunde ET zurueckgesetzt (Standard: 03:00 ET)')

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 14b — TRADE-LISTE
// ═══════════════════════════════════════════════════════════════════════════════
grp_tl = '━━━ TRADE-LISTE ━━━'
show_trade_list = input.bool(false, 'Trade-Liste anzeigen', group = grp_tl, tooltip = 'Zeigt eine Liste der letzten Trades mit Zeit, Signal, Risiko und Ergebnis — wie ein Mini-Journal direkt im Chart')
tl_pos = input.string('Unten Links', 'Position', options = ['Oben Links', 'Oben Rechts', 'Unten Links', 'Unten Rechts'], group = grp_tl)
tl_size = input.string('Normal', 'Größe', options = ['Klein', 'Normal', 'Groß'], group = grp_tl)
tl_rows = input.int(10, 'Anzahl Zeilen', minval = 1, maxval = 88, group = grp_tl, tooltip = 'Wie viele der letzten Trades angezeigt werden — max 88 (aeltere Trades fallen aus der Liste, bleiben aber in der Monats-Statistik enthalten)')

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 14 — TRAP / FAKE BREAKOUT DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
grp_trap = '━━━ TRAP DETECTION ━━━'
show_trap = input.bool(true, 'Trap Detection aktiv', group = grp_trap)
trap_bars = input.int(3, 'Bars bis Rueckkehr in Range (Trap)', minval = 1, maxval = 10, group = grp_trap, tooltip = 'Wie viele Bars darf der Preis ausserhalb der Range bleiben bevor es kein Trap mehr ist')
trap_color = input.color(color.new(#ff4444, 0), 'Trap Label Farbe', group = grp_trap)
trap_bg_color = input.color(color.new(#ff4444, 85), 'Trap Background', group = grp_trap)
show_trap_alert = input.bool(true, 'Trap Alert einschalten', group = grp_trap)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 15 — ENTRY CHECKER
// ═══════════════════════════════════════════════════════════════════════════════
grp_check = '━━━ ENTRY CHECKER ━━━'
show_checker = input.bool(true, 'Entry Checker anzeigen', group = grp_check, tooltip = 'Zeigt eine Ampel-Tabelle mit ATR, Volumen, EMA, VWAP und Quality Score')
checker_pos = input.string('Oben Rechts', 'Position', options = ['Oben Rechts', 'Oben Links', 'Unten Rechts', 'Unten Links'], group = grp_check)
checker_atr_adaptive = input.bool(false, 'Adaptive ATR-Schwelle', group = grp_check, tooltip = 'AN: Schwelle wird automatisch aus dem historischen ATR-Durchschnitt berechnet | AUS: feste Punkte-Zahl unten verwenden')
checker_atr_min = input.float(30.0, 'ATR Mindest-Punkte (fix)', minval = 5.0, step = 5.0, group = grp_check, tooltip = 'Nur aktiv wenn Adaptive ATR-Schwelle AUS ist')
checker_atr_len = input.int(50, 'Adaptive ATR — Vergleichszeitraum (Bars)', minval = 10, maxval = 200, group = grp_check, tooltip = 'Nur aktiv wenn Adaptive ATR-Schwelle AN ist — Anzahl Bars fuer den historischen ATR-Durchschnitt')
checker_atr_pct = input.float(70.0, 'Adaptive ATR — % vom Durchschnitt', minval = 30.0, maxval = 150.0, step = 5.0, group = grp_check, tooltip = 'Nur aktiv wenn Adaptive ATR-Schwelle AN ist — z.B. 70%% heisst: aktueller ATR muss mind. 70%% des historischen Schnitts sein')
checker_vol_min = input.float(1.2, 'Vol Mindest-Faktor (x Avg)', minval = 1.0, step = 0.1, group = grp_check, tooltip = 'Volumen muss mindestens X mal dem Durchschnitt entsprechen')
checker_score_min = input.int(60, 'Quality Score Minimum', minval = 0, maxval = 100, group = grp_check, tooltip = 'ORB Quality Score muss mindestens X betragen — 60 empfohlen fuer NQ M1 Stil')

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 16 — HTF TREND BIAS
// ═══════════════════════════════════════════════════════════════════════════════
grp_htf = '━━━ HTF TREND BIAS ━━━'
use_htf_filter = input.bool(false, 'Filter: HTF Trend-Ausrichtung', group = grp_htf, tooltip = 'BUY nur wenn uebergeordneter Trend (HTF) auch bullish ist | SELL nur wenn bearish')
htf_timeframe = input.timeframe('60', 'Higher Timeframe', group = grp_htf, tooltip = 'Standard: H1 — fuer NQ empfohlen. Kann auch 240 (H4) oder D (Tageschart) sein')
htf_ema_fast_len = input.int(9, 'HTF EMA Fast Periode', minval = 1, group = grp_htf)
htf_ema_slow_len = input.int(21, 'HTF EMA Slow Periode', minval = 1, group = grp_htf)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 17 — DAILY TRADE LIMIT
// ═══════════════════════════════════════════════════════════════════════════════
grp_limit = '━━━ DAILY TRADE LIMIT ━━━'
use_trade_limit = input.bool(false, 'Filter: Max Trades pro Tag', group = grp_limit, tooltip = 'Blockiert neue Signale sobald das Tageslimit erreicht ist')
max_trades_day = input.int(2, 'Max Trades pro Tag', minval = 1, maxval = 20, group = grp_limit)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 17b — ZWANGSSCHLUSS (Topstep Handelsschluss)
// ═══════════════════════════════════════════════════════════════════════════════
grp_fc = '━━━ ZWANGSSCHLUSS ━━━'
use_force_close = input.bool(false, 'Trades zum Handelsschluss schließen', group = grp_fc, tooltip = 'Markiert offene Trades im Zwangsschluss-Fenster als geschlossen (zu diesem Zeitpunkt-Preis) in der Statistik — wichtig weil Topstep den Handel taeglich automatisch pausiert')
fc_h_start = input.int(21, 'Zwangsschluss Start Stunde (ET)', minval = 0, maxval = 23, group = grp_fc, tooltip = 'Zeit in ET (US Ostkueste) — 21:50 CET = 15:50 ET (Sommerzeit kann abweichen, bitte selbst pruefen)')
fc_m_start = input.int(50, 'Start Minute', minval = 0, maxval = 59, group = grp_fc)
fc_h_end = input.int(22, 'Zwangsschluss Ende Stunde (ET)', minval = 0, maxval = 23, group = grp_fc)
fc_m_end = input.int(0, 'Ende Minute', minval = 0, maxval = 59, group = grp_fc)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 17c — HANDELSFENSTER
// ═══════════════════════════════════════════════════════════════════════════════
grp_hw = '━━━ HANDELSFENSTER ━━━'
use_trading_windows = input.bool(false, 'Nur in den Handelsfenstern handeln', group = grp_hw, tooltip = 'Blockiert alle Signale ausserhalb der definierten Zeitfenster — unabhaengig von den Session-Zeiten oben, als zusaetzliche Sicherheit')
hw_a_h_start = input.int(3, 'Fenster A (London) Start Stunde (ET)', minval = 0, maxval = 23, group = grp_hw, tooltip = '09:15 CET = 03:15 ET')
hw_a_m_start = input.int(15, 'Start Minute', minval = 0, maxval = 59, group = grp_hw)
hw_a_h_end = input.int(9, 'Fenster A (London) Ende Stunde (ET)', minval = 0, maxval = 23, group = grp_hw, tooltip = '15:30 CET = 09:30 ET')
hw_a_m_end = input.int(30, 'Ende Minute', minval = 0, maxval = 59, group = grp_hw)
hw_b_h_start = input.int(9, 'Fenster B (New York) Start Stunde (ET)', minval = 0, maxval = 23, group = grp_hw, tooltip = '15:45 CET = 09:45 ET')
hw_b_m_start = input.int(45, 'Start Minute', minval = 0, maxval = 59, group = grp_hw)
hw_b_h_end = input.int(15, 'Fenster B (New York) Ende Stunde (ET)', minval = 0, maxval = 23, group = grp_hw, tooltip = '21:45 CET = 15:45 ET')
hw_b_m_end = input.int(45, 'Ende Minute', minval = 0, maxval = 59, group = grp_hw)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 19 — ANZEIGE-GRÖSSE (Handy / PC)
// ═══════════════════════════════════════════════════════════════════════════════
grp_size = '━━━ ANZEIGE-GRÖSSE ━━━'
display_size = input.string('PC / Groß', 'Fenster-Größe (Stats, Checker, Dashboard)', options = ['Handy / Klein', 'Tablet / Mittel', 'PC / Groß'], group = grp_size, tooltip = 'Passt die Textgröße aller 3 Info-Fenster an dein Gerät an. Handy = klein, PC = normal.')

// Globale Textgröße aus der Auswahl ableiten
size_normal = display_size == 'Handy / Klein' ? size.tiny : display_size == 'Tablet / Mittel' ? size.small : size.normal
size_small = display_size == 'Handy / Klein' ? size.tiny : display_size == 'Tablet / Mittel' ? size.tiny : size.small
size_tiny = size.tiny

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP 20 — VECTOR CANDLES
// ═══════════════════════════════════════════════════════════════════════════════
grp_vec = '━━━ VECTOR CANDLES ━━━'
show_vec_candles = input.bool(false, 'Vector Candles anzeigen', group = grp_vec, tooltip = 'Zeigt Pfeil-Symbole ueber/unter Kerzen mit ungewoehnlich hohem Volumen + Range — Kerzenfarbe selbst bleibt unveraendert')
vec_lookback = input.int(10, 'Vergleichszeitraum (Bars)', minval = 5, maxval = 50, group = grp_vec, tooltip = 'Durchschnitt der letzten X Kerzen als Vergleichsbasis')
vec_climax_vol_mult = input.float(2.0, 'Climax Volumen-Schwelle (x Avg)', minval = 1.2, step = 0.1, group = grp_vec, tooltip = 'Grosses Dreieck ab dieser Volumen-Schwelle')
vec_elevated_vol_mult = input.float(1.5, 'Elevated Volumen-Schwelle (x Avg)', minval = 1.0, step = 0.1, group = grp_vec, tooltip = 'Mittlerer Punkt ab dieser Volumen-Schwelle')
vec_light_vol_mult = input.float(1.2, 'Leicht erhoeht Volumen-Schwelle (x Avg)', minval = 1.0, step = 0.05, group = grp_vec, tooltip = 'Kleinster Punkt ab dieser Volumen-Schwelle — schwaechste Stufe')
vec_range_mult = input.float(1.5, 'Range-Schwelle (x Avg)', minval = 1.0, step = 0.1, group = grp_vec, tooltip = 'Zusaetzlich muss die Kerzen-Range (High-Low) mindestens X mal dem Durchschnitt entsprechen fuer Climax')
vec_climax_up_col = input.color(#39FF14, 'Climax Up Farbe (▲▲)', group = grp_vec)
vec_climax_down_col = input.color(#FF3030, 'Climax Down Farbe (▼▼)', group = grp_vec)
vec_elevated_up_col = input.color(#00A8FF, 'Elevated Up Farbe (▲)', group = grp_vec)
vec_elevated_down_col = input.color(#A020F0, 'Elevated Down Farbe (▼)', group = grp_vec)
vec_light_up_col = input.color(color.new(#00A8FF, 40), 'Leicht erhoeht Up Farbe', group = grp_vec)
vec_light_down_col = input.color(color.new(#A020F0, 40), 'Leicht erhoeht Down Farbe', group = grp_vec)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
pad(n) =>
    n < 10 ? '0' + str.tostring(n) : str.tostring(n)
ldn_sess = pad(ldn_h_start) + pad(ldn_m_start) + '-' + pad(ldn_h_end) + pad(ldn_m_end)
ny_sess = pad(ny_h_start) + pad(ny_m_start) + '-' + pad(ny_h_end) + pad(ny_m_end)
hw_a_sess = pad(hw_a_h_start) + pad(hw_a_m_start) + '-' + pad(hw_a_h_end) + pad(hw_a_m_end)
hw_b_sess = pad(hw_b_h_start) + pad(hw_b_m_start) + '-' + pad(hw_b_h_end) + pad(hw_b_m_end)
fc_sess = pad(fc_h_start) + pad(fc_m_start) + '-' + pad(fc_h_end) + pad(fc_m_end)

// ═══════════════════════════════════════════════════════════════════════════════
// INDIKATOREN
// ═══════════════════════════════════════════════════════════════════════════════
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)
ema50 = ta.ema(close, ema50_len)
vwap_val = ta.vwap(hlc3)
tick = syminfo.mintick

vol_ma = ta.sma(volume, vol_ma_len)
vol_ratio = volume / vol_ma
is_vol_spike = volume > vol_ma * vol_spike_mult
vol_color = close >= open ? vol_bull_color : vol_bear_color
vol_spike_c = is_vol_spike ? vol_spike_color : vol_color

atr_val = ta.atr(qs_atr_len)

m15_close = request.security(syminfo.tickerid, '15', close[1], lookahead = barmerge.lookahead_on)
m5_close = request.security(syminfo.tickerid, '5', close[1], lookahead = barmerge.lookahead_on)

// M1 High/Low für praezise intrabar SL/TP Reihenfolge-Erkennung in der Statistik
// (loest das Problem dass eine M5-Kerze SL und TP gleichzeitig beruehren kann)
// M1 ist die feinste Intrabar-Aufloesung ohne TradingView Premium (Sekunden-Aufloesung erfordert Premium+)
m1_high = request.security_lower_tf(syminfo.tickerid, '1', high)
m1_low = request.security_lower_tf(syminfo.tickerid, '1', low)

// ── HTF Trend Bias ──
htf_ema_fast = request.security(syminfo.tickerid, htf_timeframe, ta.ema(close, htf_ema_fast_len)[1], lookahead = barmerge.lookahead_on)
htf_ema_slow = request.security(syminfo.tickerid, htf_timeframe, ta.ema(close, htf_ema_slow_len)[1], lookahead = barmerge.lookahead_on)
htf_bull = htf_ema_fast > htf_ema_slow
htf_bear = htf_ema_fast < htf_ema_slow

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
in_london = ldn_enable and not na(time('1', ldn_sess, 'America/New_York'))
in_ny = ny_enable and not na(time('1', ny_sess, 'America/New_York'))
in_any_orb = in_london or in_ny

// ── Handelsfenster (optionale Zusatz-Sicherheit, unabhaengig von den Session-Boxen oben) ──
in_window_a = not na(time('1', hw_a_sess, 'America/New_York'))
in_window_b = not na(time('1', hw_b_sess, 'America/New_York'))
in_trading_window = not use_trading_windows or in_window_a or in_window_b

// ── Zwangsschluss-Fenster ──
in_force_close_window = not na(time('1', fc_sess, 'America/New_York'))

london_started = in_london and not in_london[1]
ny_started = in_ny and not in_ny[1]
any_orb_started = london_started or ny_started

london_ended = not in_london and in_london[1]
ny_ended = not in_ny and in_ny[1]
any_orb_ended = london_ended or ny_ended

// ═══════════════════════════════════════════════════════════════════════════════
// ORB RANGE TRACKING
// ═══════════════════════════════════════════════════════════════════════════════
var float orb_high = na
var float orb_low = na
var bool orb_active = false
var int orb_start_bar = na
var bool is_london_sess = false

if london_started
    orb_high := high
    orb_low := low
    orb_active := false
    is_london_sess := true
    orb_start_bar := bar_index

if ny_started
    orb_high := high
    orb_low := low
    orb_active := false
    is_london_sess := false
    orb_start_bar := bar_index

if in_any_orb and not any_orb_started
    orb_high := math.max(orb_high, high)
    orb_low := math.min(orb_low, low)

if any_orb_ended
    orb_active := true

has_orb = orb_active and not na(orb_high) and not na(orb_low)

// ── ORB Range Quality Score ──
qs_range = has_orb ? orb_high - orb_low : 0.0
orb_valid = qs_range >= min_orb_points and qs_range <= max_orb_points

// TP relativ zur ORB Range — ueberschreibt tp_ticks_eff falls aktiv. SL bleibt immer unabhaengig fix.
tp_ticks_eff_final = use_tp_relative and has_orb and qs_range > 0 ? math.round((qs_range * tp_orb_factor) / tick) : tp_ticks_eff
tp_usd_eff_final = tp_ticks_eff_final * syminfo.mintick * syminfo.pointvalue
tp_usd_total_final = tp_usd_eff_final * contracts
qs_range_ratio = atr_val > 0 ? qs_range / atr_val : 0.0

qs_score_raw = qs_range_ratio >= qs_min_range_pct and qs_range_ratio <= qs_max_range_pct ? math.round(100 - math.abs(qs_range_ratio - 0.5) * 80) : qs_range_ratio < qs_min_range_pct ? math.round(qs_range_ratio / qs_min_range_pct * 40) : math.round(math.max(0, 100 - math.pow((qs_range_ratio - qs_max_range_pct) / qs_max_range_pct, 1.5) * 150))

qs_score = math.max(0, math.min(100, qs_score_raw))
quality_ok = not use_quality_filter or (has_orb and qs_score >= checker_score_min)
qs_label = qs_score >= 70 ? 'SETUP GUT' : qs_score >= 40 ? 'SETUP OK' : 'SETUP SCHWACH'
qs_color = qs_score >= 70 ? qs_color_good : qs_score >= 40 ? qs_color_mid : qs_color_bad
qs_atr_pct = atr_val > 0 ? math.round(qs_range_ratio * 100) : 0

// ═══════════════════════════════════════════════════════════════════════════════
// ORB BOX ZEICHNEN
// ═══════════════════════════════════════════════════════════════════════════════
mid_ls = mid_line_style_s == 'Solid' ? line.style_solid : mid_line_style_s == 'Dashed' ? line.style_dashed : line.style_dotted

var box ldn_sess_box = na
var box ldn_zone_box = na
var line ldn_high_line = na
var line ldn_low_line = na
var line ldn_mid_line = na
var label ldn_h_lbl = na
var label ldn_l_lbl = na
var label ldn_mid_lbl = na
var float ldn_orb_high = na
var float ldn_orb_low = na

var box ny_sess_box = na
var box ny_zone_box = na
var line ny_high_line = na
var line ny_low_line = na
var line ny_mid_line = na
var label ny_h_lbl = na
var label ny_l_lbl = na
var label ny_mid_lbl = na
var float ny_orb_high = na
var float ny_orb_low = na

is_midnight = hour(time, 'America/New_York') == 0 and minute(time, 'America/New_York') == 0

if is_midnight
    if not na(ldn_zone_box)
        box.set_right(ldn_zone_box, bar_index)
    if not na(ldn_high_line)
        line.delete(ldn_high_line)
        ldn_high_line := na
    if not na(ldn_low_line)
        line.delete(ldn_low_line)
        ldn_low_line := na
    if not na(ldn_mid_line)
        line.delete(ldn_mid_line)
        ldn_mid_line := na
    if not na(ny_zone_box)
        box.set_right(ny_zone_box, bar_index)
    if not na(ny_high_line)
        line.delete(ny_high_line)
        ny_high_line := na
    if not na(ny_low_line)
        line.delete(ny_low_line)
        ny_low_line := na
    if not na(ny_mid_line)
        line.delete(ny_mid_line)
        ny_mid_line := na
    ldn_orb_high := na
    ldn_orb_low := na
    ny_orb_high := na
    ny_orb_low := na

// ── LONDON SESSION BOX ──
if london_started
    box.delete(ldn_sess_box)
    ldn_sess_box := box.new(left = bar_index, top = high, right = bar_index, bottom = low, bgcolor = ldn_box_color, border_color = color.new(#ffffff, 80), border_width = 1)

if in_london and not na(ldn_sess_box)
    box.set_right(ldn_sess_box, bar_index)
    box.set_top(ldn_sess_box, math.max(box.get_top(ldn_sess_box), high))
    box.set_bottom(ldn_sess_box, math.min(box.get_bottom(ldn_sess_box), low))

if london_ended and not na(orb_high) and is_london_sess
    ldn_orb_high := orb_high
    ldn_orb_low := orb_low
    ldn_mid = (ldn_orb_high + ldn_orb_low) / 2
    if show_orb_bg
        box.delete(ldn_zone_box)
        ldn_zone_box := box.new(left = bar_index, top = ldn_orb_high, right = bar_index + 500, bottom = ldn_orb_low, bgcolor = orb_bg_ldn, border_color = color.new(#ffffff, 100), border_width = 0)
    if show_orb_lines
        line.delete(ldn_high_line)
        line.delete(ldn_low_line)
        ldn_high_line := line.new(bar_index, ldn_orb_high, bar_index + 1, ldn_orb_high, extend = extend.right, color = ldn_line_color, width = orb_line_width, style = line.style_dashed)
        ldn_low_line := line.new(bar_index, ldn_orb_low, bar_index + 1, ldn_orb_low, extend = extend.right, color = ldn_line_color, width = orb_line_width, style = line.style_dashed)
    if show_mid_line
        line.delete(ldn_mid_line)
        ldn_mid_line := line.new(bar_index, ldn_mid, bar_index + 1, ldn_mid, extend = extend.right, color = mid_line_color, width = mid_line_width, style = mid_ls)
        if show_orb_label
            label.delete(ldn_mid_lbl)
            ldn_mid_lbl := label.new(bar_index + 5, ldn_mid, 'Equilibrium', style = label.style_label_left, color = color.new(#111122, 10), textcolor = mid_line_color, size = size.small)
    if show_orb_label
        label.delete(ldn_h_lbl)
        label.delete(ldn_l_lbl)
        ldn_h_lbl := label.new(bar_index + 5, ldn_orb_high, 'LDN ORH', style = label.style_label_left, color = color.new(#111122, 10), textcolor = ldn_line_color, size = size.normal)
        ldn_l_lbl := label.new(bar_index + 5, ldn_orb_low, 'LDN ORL', style = label.style_label_left, color = color.new(#111122, 10), textcolor = ldn_line_color, size = size.normal)

if not na(ldn_zone_box) and show_orb_bg and not is_midnight
    box.set_right(ldn_zone_box, bar_index + 500)

// ── NY OPEN SESSION BOX ──
if ny_started
    box.delete(ny_sess_box)
    ny_sess_box := box.new(left = bar_index, top = high, right = bar_index, bottom = low, bgcolor = ny_box_color, border_color = color.new(#ffffff, 80), border_width = 1)

if in_ny and not na(ny_sess_box)
    box.set_right(ny_sess_box, bar_index)
    box.set_top(ny_sess_box, math.max(box.get_top(ny_sess_box), high))
    box.set_bottom(ny_sess_box, math.min(box.get_bottom(ny_sess_box), low))

if ny_ended and not na(orb_high) and not is_london_sess
    ny_orb_high := orb_high
    ny_orb_low := orb_low
    ny_mid = (ny_orb_high + ny_orb_low) / 2
    if show_orb_bg
        box.delete(ny_zone_box)
        ny_zone_box := box.new(left = bar_index, top = ny_orb_high, right = bar_index + 500, bottom = ny_orb_low, bgcolor = orb_bg_ny, border_color = color.new(#ffffff, 100), border_width = 0)
    if show_orb_lines
        line.delete(ny_high_line)
        line.delete(ny_low_line)
        ny_high_line := line.new(bar_index, ny_orb_high, bar_index + 1, ny_orb_high, extend = extend.right, color = ny_line_color, width = orb_line_width, style = line.style_dashed)
        ny_low_line := line.new(bar_index, ny_orb_low, bar_index + 1, ny_orb_low, extend = extend.right, color = ny_line_color, width = orb_line_width, style = line.style_dashed)
    if show_mid_line
        line.delete(ny_mid_line)
        ny_mid_line := line.new(bar_index, ny_mid, bar_index + 1, ny_mid, extend = extend.right, color = mid_line_color, width = mid_line_width, style = mid_ls)
        if show_orb_label
            label.delete(ny_mid_lbl)
            ny_mid_lbl := label.new(bar_index + 5, ny_mid, 'Equilibrium', style = label.style_label_left, color = color.new(#111122, 10), textcolor = mid_line_color, size = size.small)
    if show_orb_label
        label.delete(ny_h_lbl)
        label.delete(ny_l_lbl)
        ny_h_lbl := label.new(bar_index + 5, ny_orb_high, 'NY ORH', style = label.style_label_left, color = color.new(#111122, 10), textcolor = ny_line_color, size = size.normal)
        ny_l_lbl := label.new(bar_index + 5, ny_orb_low, 'NY ORL', style = label.style_label_left, color = color.new(#111122, 10), textcolor = ny_line_color, size = size.normal)

if not na(ny_zone_box) and show_orb_bg and not is_midnight
    box.set_right(ny_zone_box, bar_index + 500)

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL BEDINGUNGEN
// ═══════════════════════════════════════════════════════════════════════════════
bull_break = has_orb and close > orb_high
bear_break = has_orb and close < orb_low

ema_bull = ema_fast > ema_slow
ema_bear = ema_fast < ema_slow
ema_cross_up = ta.crossover(ema_fast, ema_slow)
ema_cross_down = ta.crossunder(ema_fast, ema_slow)

vwap_bull = close > vwap_val
vwap_bear = close < vwap_val
vwap_x_up = ta.crossover(close, vwap_val)
vwap_x_dn = ta.crossunder(close, vwap_val)

m15_bull = not na(m15_close) and not na(orb_high) and m15_close > orb_high
m15_bear = not na(m15_close) and not na(orb_low) and m15_close < orb_low
m5_bull = not na(m5_close) and not na(orb_high) and m5_close > orb_high
m5_bear = not na(m5_close) and not na(orb_low) and m5_close < orb_low

// ── Daily Trade Limit Counter ──
var int trades_today = 0
var int limit_last_day = -1
limit_curr_day = dayofmonth(time, 'America/New_York')
limit_curr_hr = hour(time, 'America/New_York')
if limit_curr_day != limit_last_day and limit_curr_hr == stats_reset_hour
    trades_today := 0
    limit_last_day := limit_curr_day
trade_limit_ok = not use_trade_limit or trades_today < max_trades_day

var bool bull_fired = false
var bool bear_fired = false
var int last_orb_id = -1

// ── RETEST FILTER — State Machine ──
// Phase 0 = kein Breakout | 1 = Breakout erkannt | 2 = Retest erkannt | 3 = Bestaetigung (Signal einmalig)
var int retest_bull_state = 0
var int retest_bear_state = 0
var bool retest_bull_ok = false
var bool retest_bear_ok = false
retest_zone = retest_ticks * syminfo.mintick

// Reset bei neuer Session
if not na(orb_start_bar) and orb_start_bar != last_orb_id
    bull_fired := false
    bear_fired := false
    retest_bull_ok := false
    retest_bear_ok := false
    retest_bull_state := 0
    retest_bear_state := 0
    last_orb_id := orb_start_bar

// State Machine BULL: Breakout → Retest → Bestaetigung
if has_orb and use_retest_filter
    if retest_bull_state == 0 and close > orb_high
        retest_bull_state := 1
    if retest_bull_state == 1 and low <= orb_high + retest_zone
        retest_bull_state := 2
    if retest_bull_state == 2 and close > orb_high
        retest_bull_state := 3
        retest_bull_ok := true

// State Machine BEAR: Breakout → Retest → Bestaetigung
if has_orb and use_retest_filter
    if retest_bear_state == 0 and close < orb_low
        retest_bear_state := 1
    if retest_bear_state == 1 and high >= orb_low - retest_zone
        retest_bear_state := 2
    if retest_bear_state == 2 and close < orb_low
        retest_bear_state := 3
        retest_bear_ok := true

long_ok = bull_break
long_ok := long_ok and (not use_ema_filter or ema_bull)
long_ok := long_ok and (not use_vwap_filter or vwap_bull)
long_ok := long_ok and (not use_m15_filter or m15_bull)
long_ok := long_ok and (not use_m5_filter or m5_bull)
long_ok := long_ok and (not use_first_only or not bull_fired)
long_ok := long_ok and (not use_htf_filter or htf_bull)
long_ok := long_ok and (not use_orb_range_filter or orb_valid)
long_ok := long_ok and quality_ok
long_ok := long_ok and (not use_retest_filter or retest_bull_ok)
long_ok := long_ok and trade_limit_ok
long_ok := long_ok and in_trading_window

short_ok = bear_break
short_ok := short_ok and (not use_ema_filter or ema_bear)
short_ok := short_ok and (not use_vwap_filter or vwap_bear)
short_ok := short_ok and (not use_m15_filter or m15_bear)
short_ok := short_ok and (not use_m5_filter or m5_bear)
short_ok := short_ok and (not use_first_only or not bear_fired)
short_ok := short_ok and (not use_htf_filter or htf_bear)
short_ok := short_ok and (not use_orb_range_filter or orb_valid)
short_ok := short_ok and quality_ok
short_ok := short_ok and (not use_retest_filter or retest_bear_ok)
short_ok := short_ok and trade_limit_ok
short_ok := short_ok and in_trading_window

// Signal gefeuert — Guard setzen + Retest zuruecksetzen
if long_ok
    bull_fired := true
    retest_bull_ok := false
    retest_bull_state := 0

if short_ok
    bear_fired := true
    retest_bear_ok := false
    retest_bear_state := 0

// Daily Trade Limit Zaehler — nur auf bestaetigten Bars hochzaehlen (verhindert Doppelzaehlung bei Intrabar-Neuberechnung)
if barstate.isconfirmed and long_ok
    trades_today := trades_today + 1
if barstate.isconfirmed and short_ok
    trades_today := trades_today + 1

// ═══════════════════════════════════════════════════════════════════════════════
// ORB STATISTIK TRACKING
// ═══════════════════════════════════════════════════════════════════════════════
// ── Trade-Liste Arrays (parallel, Index 0 = neuester Trade) ──
var tl_time = array.new_int(0)
var tl_dir = array.new_int(0)        // 1 = Long | -1 = Short
var tl_risk_ticks = array.new_int(0)
var tl_result = array.new_int(0)     // 1 = SL | 2 = TP
var tl_pnl = array.new_float(0)

var int stat_trades = 0
var int stat_wins = 0
var int stat_losses = 0
var float stat_pnl = 0.0
var int ldn_trades = 0
var int ldn_wins = 0
var int ldn_losses = 0
var int ny_trades = 0
var int ny_wins = 0
var int ny_losses = 0
var bool stat_trade_was_london = false
var int stat_last_day = -1
var bool stat_in_trade = false
var float stat_entry = na
var bool stat_is_long = false
var float stat_sl_price = na
var float stat_tp_price = na
var float stat_tp_usd_used = na

// ── Monats-Statistik (kumuliert ueber alle Tage im aktuellen Kalendermonat) ──
var int month_trades = 0
var int month_wins = 0
var int month_losses = 0
var float month_pnl = 0.0
var int stat_last_month = -1

stat_curr_day = dayofmonth(time, 'America/New_York')
stat_curr_hr = hour(time, 'America/New_York')
stat_curr_month = month(time, 'America/New_York')

// Monat gewechselt? Monats-Stats zuruecksetzen (unabhaengig von der Tages-Reset-Stunde)
if stat_curr_month != stat_last_month
    if stat_last_month != -1
        month_trades := 0
        month_wins := 0
        month_losses := 0
        month_pnl := 0.0
    stat_last_month := stat_curr_month

if stat_curr_day != stat_last_day and stat_curr_hr == stats_reset_hour
    // Bevor die Tages-Stats resettet werden: in die Monats-Summe uebernehmen
    month_trades := month_trades + stat_trades
    month_wins := month_wins + stat_wins
    month_losses := month_losses + stat_losses
    month_pnl := month_pnl + stat_pnl
    stat_trades := 0
    stat_wins := 0
    stat_losses := 0
    stat_pnl := 0.0
    stat_in_trade := false
    stat_entry := na
    ldn_trades := 0
    ldn_wins := 0
    ldn_losses := 0
    ny_trades := 0
    ny_wins := 0
    ny_losses := 0
    stat_last_day := stat_curr_day

month_wr = month_trades > 0 ? math.round(month_wins / month_trades * 100) : 0

if show_stats and barstate.isconfirmed
    if long_ok[1] and not stat_in_trade and not long_ok[2]
        stat_in_trade := true
        stat_is_long := true
        stat_entry := open
        stat_sl_price := open - sl_ticks_eff * tick
        stat_tp_price := open + tp_ticks_eff_final * tick
        stat_tp_usd_used := tp_ticks_eff_final * syminfo.mintick * syminfo.pointvalue * contracts
        stat_trades := stat_trades + 1
        stat_trade_was_london := is_london_sess
        if is_london_sess
            ldn_trades := ldn_trades + 1
        else
            ny_trades := ny_trades + 1

    if short_ok[1] and not stat_in_trade and not short_ok[2]
        stat_in_trade := true
        stat_is_long := false
        stat_entry := open
        stat_sl_price := open + sl_ticks_eff * tick
        stat_tp_price := open - tp_ticks_eff_final * tick
        stat_tp_usd_used := tp_ticks_eff_final * syminfo.mintick * syminfo.pointvalue * contracts
        stat_trades := stat_trades + 1
        stat_trade_was_london := is_london_sess
        if is_london_sess
            ldn_trades := ldn_trades + 1
        else
            ny_trades := ny_trades + 1

    // ── Zwangsschluss: offener simulierter Trade wird zum aktuellen Close bewertet, statt weiter auf SL/TP zu warten ──
    if use_force_close and stat_in_trade and in_force_close_window and not na(stat_sl_price) and not na(stat_tp_price)
        fc_pnl_simple = stat_is_long ? (close - stat_entry) * contracts * syminfo.pointvalue : (stat_entry - close) * contracts * syminfo.pointvalue
        stat_pnl := stat_pnl + fc_pnl_simple
        if fc_pnl_simple >= 0
            stat_wins := stat_wins + 1
            if stat_trade_was_london
                ldn_wins := ldn_wins + 1
            else
                ny_wins := ny_wins + 1
        else
            stat_losses := stat_losses + 1
            if stat_trade_was_london
                ldn_losses := ldn_losses + 1
            else
                ny_losses := ny_losses + 1
        array.unshift(tl_time, time)
        array.unshift(tl_dir, stat_is_long ? 1 : -1)
        array.unshift(tl_risk_ticks, sl_ticks_eff)
        array.unshift(tl_result, 3)  // 3 = Zwangsschluss
        array.unshift(tl_pnl, fc_pnl_simple)
        if array.size(tl_time) > 88
            array.pop(tl_time)
            array.pop(tl_dir)
            array.pop(tl_risk_ticks)
            array.pop(tl_result)
            array.pop(tl_pnl)
        stat_in_trade := false
        stat_entry := na

    if stat_in_trade and not na(stat_sl_price) and not na(stat_tp_price)
        // Praezise Reihenfolge-Erkennung: gehe M1-Kerzen innerhalb der Chart-Kerze durch
        // und erkenne welches Level (SL oder TP) zuerst getroffen wurde.
        // Wenn EINE einzelne M1-Kerze BEIDE Level beruehrt, ist nicht zuverlaessig feststellbar
        // welches zuerst kam (Pine Script hat keine echten Tick-Daten). Konservative Annahme:
        // SL zuerst — das unterschaetzt Gewinne systematisch statt unvorhersehbar in beide
        // Richtungen zu raten (eine getestete Richtungs-Heuristik war nicht zuverlaessig genug).
        int hit = 0  // 0 = nichts | 1 = SL zuerst | 2 = TP zuerst
        if array.size(m1_high) > 0 and array.size(m1_low) > 0
            for i = 0 to array.size(m1_high) - 1
                mh = array.get(m1_high, i)
                ml = array.get(m1_low, i)
                if stat_is_long
                    if ml <= stat_sl_price
                        hit := 1
                        break
                    else if mh >= stat_tp_price
                        hit := 2
                        break
                else
                    if mh >= stat_sl_price
                        hit := 1
                        break
                    else if ml <= stat_tp_price
                        hit := 2
                        break
        else
            // Fallback wenn keine M1-Daten: konservativ SL zuerst
            if stat_is_long
                if low <= stat_sl_price
                    hit := 1
                else if high >= stat_tp_price
                    hit := 2
            else
                if high >= stat_sl_price
                    hit := 1
                else if low <= stat_tp_price
                    hit := 2

        if hit == 1
            stat_losses := stat_losses + 1
            stat_pnl := stat_pnl + -sl_usd_total
            stat_in_trade := false
            stat_entry := na
            if stat_trade_was_london
                ldn_losses := ldn_losses + 1
            else
                ny_losses := ny_losses + 1
            array.unshift(tl_time, time)
            array.unshift(tl_dir, stat_is_long ? 1 : -1)
            array.unshift(tl_risk_ticks, sl_ticks_eff)
            array.unshift(tl_result, 1)  // 1 = SL
            array.unshift(tl_pnl, -sl_usd_total)
            if array.size(tl_time) > 88
                array.pop(tl_time)
                array.pop(tl_dir)
                array.pop(tl_risk_ticks)
                array.pop(tl_result)
                array.pop(tl_pnl)
        else if hit == 2
            stat_wins := stat_wins + 1
            stat_pnl := stat_pnl + stat_tp_usd_used
            stat_in_trade := false
            stat_entry := na
            if stat_trade_was_london
                ldn_wins := ldn_wins + 1
            else
                ny_wins := ny_wins + 1
            array.unshift(tl_time, time)
            array.unshift(tl_dir, stat_is_long ? 1 : -1)
            array.unshift(tl_risk_ticks, sl_ticks_eff)
            array.unshift(tl_result, 2)  // 2 = TP
            array.unshift(tl_pnl, stat_tp_usd_used)
            if array.size(tl_time) > 88
                array.pop(tl_time)
                array.pop(tl_dir)
                array.pop(tl_risk_ticks)
                array.pop(tl_result)
                array.pop(tl_pnl)

stat_wr = stat_trades > 0 ? math.round(stat_wins / stat_trades * 100) : 0
ldn_wr = ldn_trades > 0 ? math.round(ldn_wins / ldn_trades * 100) : 0
ny_wr = ny_trades > 0 ? math.round(ny_wins / ny_trades * 100) : 0

// ═══════════════════════════════════════════════════════════════════════════════
// TRAP / FAKE BREAKOUT DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
var int trap_bull_bar = -1
var int trap_bear_bar = -1
var bool trap_bull_active = false
var bool trap_bear_active = false

trap_bull_detected = false
trap_bear_detected = false

if show_trap and has_orb
    if close > orb_high and not trap_bull_active
        trap_bull_bar := bar_index
        trap_bull_active := true
        trap_bear_active := false
    if close < orb_low and not trap_bear_active
        trap_bear_bar := bar_index
        trap_bear_active := true
        trap_bull_active := false
    trap_bull_detected := trap_bull_active and bar_index - trap_bull_bar <= trap_bars and close < orb_high and close > orb_low
    trap_bear_detected := trap_bear_active and bar_index - trap_bear_bar <= trap_bars and close > orb_low and close < orb_high
    if trap_bull_detected
        trap_bull_active := false
    if trap_bear_detected
        trap_bear_active := false
    if bar_index - trap_bull_bar > trap_bars
        trap_bull_active := false
    if bar_index - trap_bear_bar > trap_bars
        trap_bear_active := false

// ═══════════════════════════════════════════════════════════════════════════════
// EMA PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
plot(show_ema ? ema_fast : na, title = 'EMA Fast', color = ema_fast_color, linewidth = math.max(1, ema_width))
plot(show_ema ? ema_slow : na, title = 'EMA Slow', color = ema_slow_color, linewidth = math.max(1, ema_width))
plot(show_ema50 ? ema50 : na, title = 'EMA 50', color = ema50_color, linewidth = math.max(1, ema50_width))

// EMA Cross Symbole entfernt (Platz fuer Vector Candles) — Alerts bleiben unten weiterhin aktiv, Kreuzung ist an den EMA-Linien selbst sichtbar

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP PLOT
// ═══════════════════════════════════════════════════════════════════════════════
plot(show_vwap ? vwap_val : na, title = 'VWAP', color = vwap_color, linewidth = math.max(1, vwap_width))

plotshape(show_vwap and show_vwap_cross and vwap_x_up, title = 'VWAP Cross UP', text = 'VP+', style = shape.labelup, location = location.belowbar, color = vwap_cross_bull, textcolor = color.white, size = size.tiny)
plotshape(show_vwap and show_vwap_cross and vwap_x_dn, title = 'VWAP Cross DOWN', text = 'VP-', style = shape.labeldown, location = location.abovebar, color = vwap_cross_bear, textcolor = color.white, size = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL PFEILE
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(long_ok and sig_tiny, title = 'BUY', text = 'BUY', style = shape.triangleup, location = location.belowbar, color = buy_arrow_color, textcolor = buy_arrow_color, size = size.tiny)
plotshape(short_ok and sig_tiny, title = 'SELL', text = 'SELL', style = shape.triangledown, location = location.abovebar, color = sell_arrow_color, textcolor = sell_arrow_color, size = size.tiny)
plotshape(long_ok and sig_small and not sig_tiny, title = 'BUY s', text = 'BUY', style = shape.triangleup, location = location.belowbar, color = buy_arrow_color, textcolor = buy_arrow_color, size = size.small)
plotshape(short_ok and sig_small and not sig_tiny, title = 'SELL s', text = 'SELL', style = shape.triangledown, location = location.abovebar, color = sell_arrow_color, textcolor = sell_arrow_color, size = size.small)
plotshape(long_ok and sig_large and not sig_tiny and not sig_small, title = 'BUY l', text = 'BUY', style = shape.triangleup, location = location.belowbar, color = buy_arrow_color, textcolor = buy_arrow_color, size = size.large)
plotshape(short_ok and sig_large and not sig_tiny and not sig_small, title = 'SELL l', text = 'SELL', style = shape.triangledown, location = location.abovebar, color = sell_arrow_color, textcolor = sell_arrow_color, size = size.large)
plotshape(long_ok and not sig_tiny and not sig_small and not sig_large, title = 'BUY n', text = 'BUY', style = shape.triangleup, location = location.belowbar, color = buy_arrow_color, textcolor = buy_arrow_color, size = size.normal)
plotshape(short_ok and not sig_tiny and not sig_small and not sig_large, title = 'SELL n', text = 'SELL', style = shape.triangledown, location = location.abovebar, color = sell_arrow_color, textcolor = sell_arrow_color, size = size.normal)

// ═══════════════════════════════════════════════════════════════════════════════
// SL / TP LINIEN
// ═══════════════════════════════════════════════════════════════════════════════
if show_sl_tp and long_ok
    ep = close
    sl = ep - sl_ticks_eff * tick
    tp = ep + tp_ticks_eff_final * tick
    line.new(bar_index, ep, bar_index + sl_tp_length, ep, color = entry_color, width = sl_tp_line_width, style = line.style_solid)
    line.new(bar_index, sl, bar_index + sl_tp_length, sl, color = sl_color, width = sl_tp_line_width, style = line.style_solid)
    line.new(bar_index, tp, bar_index + sl_tp_length, tp, color = tp_color, width = sl_tp_line_width, style = line.style_solid)
    label.new(bar_index + sl_tp_length, sl, 'SL ' + str.tostring(sl, format.mintick) + ' | -$' + str.tostring(math.round(sl_usd_total)) + ' (' + str.tostring(contracts) + ' Ktr)', style = label.style_label_left, color = color.new(#8b0000, 0), textcolor = color.white, size = size.small)
    label.new(bar_index + sl_tp_length, tp, 'TP ' + str.tostring(tp, format.mintick) + ' | +$' + str.tostring(math.round(tp_usd_total_final)) + ' (' + str.tostring(contracts) + ' Ktr)', style = label.style_label_left, color = color.new(#006633, 0), textcolor = color.white, size = size.small)

if show_sl_tp and short_ok
    ep = close
    sl = ep + sl_ticks_eff * tick
    tp = ep - tp_ticks_eff_final * tick
    line.new(bar_index, ep, bar_index + sl_tp_length, ep, color = entry_color, width = sl_tp_line_width, style = line.style_solid)
    line.new(bar_index, sl, bar_index + sl_tp_length, sl, color = sl_color, width = sl_tp_line_width, style = line.style_solid)
    line.new(bar_index, tp, bar_index + sl_tp_length, tp, color = tp_color, width = sl_tp_line_width, style = line.style_solid)
    label.new(bar_index + sl_tp_length, sl, 'SL ' + str.tostring(sl, format.mintick) + ' | -$' + str.tostring(math.round(sl_usd_total)) + ' (' + str.tostring(contracts) + ' Ktr)', style = label.style_label_left, color = color.new(#8b0000, 0), textcolor = color.white, size = size.small)
    label.new(bar_index + sl_tp_length, tp, 'TP ' + str.tostring(tp, format.mintick) + ' | +$' + str.tostring(math.round(tp_usd_total_final)) + ' (' + str.tostring(contracts) + ' Ktr)', style = label.style_label_left, color = color.new(#006633, 0), textcolor = color.white, size = size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// TRENDKANAL
// ═══════════════════════════════════════════════════════════════════════════════
ch_src = close
ch_basis = ta.linreg(ch_src, ch_length, 0)
ch_dev = 2.0 * ta.stdev(ch_src, ch_length)
ch_upper = ch_basis + ch_dev
ch_lower = ch_basis - ch_dev

ch_mid_rising = ch_basis > ch_basis[1]
ch_mid_dyn_col = show_channel ? ch_mid_rising ? color.new(#2ecc71, 0) : color.new(#e74c3c, 0) : na

p_upper = plot(show_channel ? ch_upper : na, title = 'Kanal Oben', color = ch_upper_color, linewidth = math.max(1, ch_width))
p_lower = plot(show_channel ? ch_lower : na, title = 'Kanal Unten', color = ch_lower_color, linewidth = math.max(1, ch_width))
plot(show_channel ? ch_basis : na, title = 'Kanal Mitte', color = ch_mid_dyn_col, linewidth = 2)
fill(p_upper, p_lower, color = show_channel ? ch_fill_color : na, title = 'Kanal Fill')

// ═══════════════════════════════════════════════════════════════════════════════
// MTF DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
f_bias(tf) =>
    e_fast = request.security(syminfo.tickerid, tf, ta.ema(close, 9)[1], lookahead = barmerge.lookahead_on)
    e_slow = request.security(syminfo.tickerid, tf, ta.ema(close, 21)[1], lookahead = barmerge.lookahead_on)
    e_fast > e_slow ? 1 : e_fast < e_slow ? -1 : 0

bias_m15 = f_bias('15')
bias_h1 = f_bias('60')

f_col(b) =>
    b == 1 ? color.new(#2ecc71, 10) : b == -1 ? color.new(#e74c3c, 10) : color.new(#888899, 30)

dash_table_pos = dash_pos == 'Oben Rechts' ? position.top_right : dash_pos == 'Oben Links' ? position.top_left : dash_pos == 'Unten Links' ? position.bottom_left : position.bottom_right

var table dash = table.new(dash_table_pos, 3, 4, bgcolor = color.new(#0d0d1a, 5), border_color = color.new(#1a1a2e, 0), border_width = 1, frame_color = color.new(#ffd700, 20), frame_width = 1)

if show_dashboard and barstate.islast
    table.cell(dash, 0, 0, dash_signal_name, text_color = color.new(#0d0d1a, 0), text_size = size_small, bgcolor = color.new(#ffd700, 0), text_halign = text.align_center)
    table.cell(dash, 1, 0, 'M15', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#1a1a2e, 0), text_halign = text.align_center)
    table.cell(dash, 2, 0, 'H1', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#1a1a2e, 0), text_halign = text.align_center)
    table.cell(dash, 0, 1, syminfo.ticker + ' SIGNAL', text_color = color.new(#888899, 0), text_size = size_small, bgcolor = color.new(#111122, 0), text_halign = text.align_left)
    table.cell(dash, 1, 1, '●', text_color = f_col(bias_m15), text_size = size_normal, bgcolor = color.new(#111122, 0), text_halign = text.align_center)
    table.cell(dash, 2, 1, '●', text_color = f_col(bias_h1), text_size = size_normal, bgcolor = color.new(#111122, 0), text_halign = text.align_center)
    sig_txt = long_ok ? '▲ BUY' : short_ok ? '▼ SELL' : '— NEUTRAL'
    sig_col = long_ok ? color.new(#2ecc71, 0) : short_ok ? color.new(#e74c3c, 0) : color.new(#888899, 0)
    sig_bg = long_ok ? color.new(#0d2e1a, 0) : short_ok ? color.new(#2e0d0d, 0) : color.new(#111122, 0)
    table.cell(dash, 0, 2, sig_txt, text_color = sig_col, text_size = size_small, bgcolor = sig_bg, text_halign = text.align_center)
    orb_txt = has_orb ? 'ORB: ' + str.tostring(orb_high, format.mintick) + ' / ' + str.tostring(orb_low, format.mintick) : 'ORB: warte...'
    table.cell(dash, 1, 2, orb_txt, text_color = color.new(#00d4ff, 0), text_size = size_tiny, bgcolor = color.new(#0d1a2e, 0), text_halign = text.align_center)
    vol_dash_txt = is_vol_spike ? 'VOL SPIKE ' + str.tostring(math.round(vol_ratio, 1)) + 'x' : 'Vol: ' + str.tostring(math.round(vol_ratio, 1)) + 'x avg'
    vol_dash_bg = is_vol_spike ? color.new(#2e2200, 0) : color.new(#0d1a2e, 0)
    vol_dash_col = is_vol_spike ? color.new(#ffd700, 0) : color.new(#888899, 0)
    table.cell(dash, 2, 2, vol_dash_txt, text_color = vol_dash_col, text_size = size_tiny, bgcolor = vol_dash_bg, text_halign = text.align_center)
    if show_quality and has_orb
        qs_bar_filled = math.round(qs_score / 100 * 6)
        qs_bar = ''
        for b = 0 to 5 by 1
            qs_bar := qs_bar + (b < qs_bar_filled ? '█' : '░')
        qs_dash_txt = 'QUALITY ' + qs_bar + ' ' + str.tostring(qs_score) + '/100 ' + qs_label + '  |  SL -$' + str.tostring(math.round(sl_usd_total)) + '  TP +$' + str.tostring(math.round(tp_usd_total_final)) + '  [' + str.tostring(contracts) + ' Ktr]'
        table.cell(dash, 0, 3, qs_dash_txt, text_color = qs_color, text_size = size_tiny, bgcolor = color.new(#0a0a15, 0), text_halign = text.align_center)
        for i = 1 to 2 by 1
            table.cell(dash, i, 3, '', bgcolor = color.new(#0a0a15, 0))
    else if show_quality
        table.cell(dash, 0, 3, 'QUALITY — warte auf ORB...', text_color = color.new(#444455, 0), text_size = size_tiny, bgcolor = color.new(#0a0a15, 0), text_halign = text.align_center)
        for i = 1 to 2 by 1
            table.cell(dash, i, 3, '', bgcolor = color.new(#0a0a15, 0))

// ═══════════════════════════════════════════════════════════════════════════════
// ORB RANGE QUALITY SCORE — LABEL
// ═══════════════════════════════════════════════════════════════════════════════
if show_quality and any_orb_ended and not na(orb_high)
    qs_txt = 'SCORE: ' + str.tostring(qs_score) + '/100 ' + qs_label + '\n' + 'Range: ' + str.tostring(math.round(qs_range * 100) / 100) + ' pts | ' + str.tostring(qs_atr_pct) + '%% ATR'
    label.new(bar_index, orb_high + atr_val * 0.3, qs_txt, style = label.style_label_down, color = qs_color, textcolor = color.new(#07070f, 0), size = size.normal)

bgcolor(show_quality and has_orb and qs_score < 40 and not in_any_orb ? color.new(#e74c3c, 96) : na, title = 'Schlechtes Setup Warning')

// ═══════════════════════════════════════════════════════════════════════════════
// VOLUMEN SPIKE PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
plot(show_vol ? volume : na, title = 'Volumen', style = plot.style_columns, color = vol_spike_c, linewidth = 1)
plot(show_vol ? vol_ma : na, title = 'Vol MA', color = color.new(#ffffff, 50), linewidth = 1, style = plot.style_line)

if show_vol_label and long_ok
    vol_txt = is_vol_spike ? 'VOL SPIKE ' + str.tostring(math.round(vol_ratio, 1)) + 'x BESTÄTIGT' : 'Vol ' + str.tostring(math.round(vol_ratio, 1)) + 'x (kein Spike)'
    vol_bg = is_vol_spike ? color.new(#2ecc71, 10) : color.new(#888899, 30)
    vol_tc = is_vol_spike ? color.new(#07070f, 0) : color.new(#e8e8ff, 0)
    label.new(bar_index, low - (high - low) * 0.5, vol_txt, style = label.style_label_up, color = vol_bg, textcolor = vol_tc, size = size.small)

if show_vol_label and short_ok
    vol_txt = is_vol_spike ? 'VOL SPIKE ' + str.tostring(math.round(vol_ratio, 1)) + 'x BESTÄTIGT' : 'Vol ' + str.tostring(math.round(vol_ratio, 1)) + 'x (kein Spike)'
    vol_bg = is_vol_spike ? color.new(#e74c3c, 10) : color.new(#888899, 30)
    vol_tc = is_vol_spike ? color.new(#ffffff, 0) : color.new(#e8e8ff, 0)
    label.new(bar_index, high + (high - low) * 0.5, vol_txt, style = label.style_label_down, color = vol_bg, textcolor = vol_tc, size = size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// ORB STATISTIK BOX
// ═══════════════════════════════════════════════════════════════════════════════
stats_table_pos = stats_pos == 'Oben Rechts' ? position.top_right : stats_pos == 'Unten Links' ? position.bottom_left : stats_pos == 'Unten Rechts' ? position.bottom_right : position.top_left

var table stats_tbl = table.new(stats_table_pos, 2, 11, bgcolor = color.new(#0d0d1a, 5), border_color = color.new(#1a1a2e, 0), border_width = 1, frame_color = color.new(#00d4ff, 30), frame_width = 1)

if show_stats and barstate.islast
    pnl_col = stat_pnl >= 0 ? color.new(#2ecc71, 0) : color.new(#e74c3c, 0)
    wr_col = stat_wr >= 60 ? color.new(#2ecc71, 0) : stat_wr >= 40 ? color.new(#ffd700, 0) : color.new(#e74c3c, 0)
    st_col = stat_in_trade ? color.new(#ffd700, 0) : color.new(#888899, 0)
    bg0 = color.new(#0d0d1a, 0)
    bg1 = color.new(#111122, 0)
    table.cell(stats_tbl, 0, 0, ' ORB STATS HEUTE', text_color = color.new(#00d4ff, 0), text_size = size_small, bgcolor = color.new(#0d1a2e, 0), text_halign = text.align_left)
    table.cell(stats_tbl, 1, 0, syminfo.ticker + ' ', text_color = color.new(#444455, 0), text_size = size_tiny, bgcolor = color.new(#0d1a2e, 0), text_halign = text.align_right)
    table.cell(stats_tbl, 0, 1, ' Trades', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = bg0, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 1, str.tostring(stat_trades) + ' ', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = bg0, text_halign = text.align_right)
    table.cell(stats_tbl, 0, 2, ' Wins / Losses', text_color = color.new(#2ecc71, 0), text_size = size_small, bgcolor = bg1, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 2, str.tostring(stat_wins) + ' / ' + str.tostring(stat_losses) + ' ', text_color = color.new(#e74c3c, 0), text_size = size_small, bgcolor = bg1, text_halign = text.align_right)
    table.cell(stats_tbl, 0, 3, ' Win Rate', text_color = wr_col, text_size = size_small, bgcolor = bg0, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 3, str.tostring(stat_wr) + ' % ', text_color = wr_col, text_size = size_small, bgcolor = bg0, text_halign = text.align_right)
    table.cell(stats_tbl, 0, 4, ' P&L (simuliert)', text_color = pnl_col, text_size = size_small, bgcolor = bg1, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 4, (stat_pnl >= 0 ? '+ $' : '- $') + str.tostring(math.abs(math.round(stat_pnl, 0))) + ' ', text_color = pnl_col, text_size = size_small, bgcolor = bg1, text_halign = text.align_right)
    ldn_wr_col = ldn_wr >= 60 ? color.new(#2ecc71, 0) : ldn_wr >= 40 ? color.new(#ffd700, 0) : color.new(#e74c3c, 0)
    ny_wr_col  = ny_wr  >= 60 ? color.new(#2ecc71, 0) : ny_wr  >= 40 ? color.new(#ffd700, 0) : color.new(#e74c3c, 0)
    table.cell(stats_tbl, 0, 5, ' London Session', text_color = color.new(#00d4ff, 0), text_size = size_small, bgcolor = bg0, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 5, str.tostring(ldn_trades) + ' Tr | ' + str.tostring(ldn_wins) + 'W/' + str.tostring(ldn_losses) + 'L | ' + str.tostring(ldn_wr) + '% ', text_color = ldn_wr_col, text_size = size_small, bgcolor = bg0, text_halign = text.align_right)
    table.cell(stats_tbl, 0, 6, ' NY Session', text_color = color.new(#ffd700, 0), text_size = size_small, bgcolor = bg1, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 6, str.tostring(ny_trades) + ' Tr | ' + str.tostring(ny_wins) + 'W/' + str.tostring(ny_losses) + 'L | ' + str.tostring(ny_wr) + '% ', text_color = ny_wr_col, text_size = size_small, bgcolor = bg1, text_halign = text.align_right)
    table.cell(stats_tbl, 0, 7, ' Kontrakte', text_color = color.new(#ffd700, 0), text_size = size_small, bgcolor = bg0, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 7, str.tostring(contracts) + ' Ktr | SL $' + str.tostring(math.round(sl_usd_total)) + ' / TP $' + str.tostring(math.round(tp_usd_total_final)) + ' ', text_color = color.new(#ffd700, 0), text_size = size_small, bgcolor = bg0, text_halign = text.align_right)
    table.cell(stats_tbl, 0, 8, ' Status', text_color = st_col, text_size = size_small, bgcolor = bg1, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 8, (stat_in_trade ? 'IN TRADE' : 'Warte...') + ' ', text_color = st_col, text_size = size_small, bgcolor = bg1, text_halign = text.align_right)
    limit_col = not use_trade_limit ? color.new(#888899, 0) : trades_today >= max_trades_day ? color.new(#e74c3c, 0) : color.new(#2ecc71, 0)
    table.cell(stats_tbl, 0, 9, ' Trade Limit', text_color = limit_col, text_size = size_small, bgcolor = bg0, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 9, (use_trade_limit ? str.tostring(trades_today) + ' / ' + str.tostring(max_trades_day) : 'AUS') + ' ', text_color = limit_col, text_size = size_small, bgcolor = bg0, text_halign = text.align_right)
    month_pnl_col = month_pnl >= 0 ? color.new(#2ecc71, 0) : color.new(#e74c3c, 0)
    table.cell(stats_tbl, 0, 10, ' Monat gesamt', text_color = color.new(#00d4ff, 0), text_size = size_small, bgcolor = bg1, text_halign = text.align_left)
    table.cell(stats_tbl, 1, 10, str.tostring(month_trades) + ' Tr | ' + str.tostring(month_wr) + '% | ' + (month_pnl >= 0 ? '+$' : '-$') + str.tostring(math.abs(math.round(month_pnl, 0))) + ' ', text_color = month_pnl_col, text_size = size_small, bgcolor = bg1, text_halign = text.align_right)

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY CHECKER — AMPEL TABELLE
// ═══════════════════════════════════════════════════════════════════════════════

// Checker Bedingungen
atr_hist_avg = ta.sma(atr_val, checker_atr_len)
checker_atr_threshold = checker_atr_adaptive ? atr_hist_avg * (checker_atr_pct / 100) : checker_atr_min
chk_atr   = atr_val >= checker_atr_threshold
chk_vol   = vol_ratio >= checker_vol_min
chk_ema   = ema_bull or ema_bear  // EMA ausgerichtet (egal ob long/short)
chk_vwap  = vwap_bull or vwap_bear  // Preis auf einer Seite des VWAP
chk_score = has_orb and qs_score >= checker_score_min
chk_htf   = htf_bull or htf_bear  // HTF Trend eindeutig ausgerichtet (egal welche Richtung)

// Ampel Farben
col_green = color.new(#2ecc71, 0)
col_red   = color.new(#e74c3c, 0)
col_grey  = color.new(#444455, 0)
col_bg_on  = color.new(#0d2e1a, 0)
col_bg_off = color.new(#2e0d0d, 0)
col_bg_na  = color.new(#111122, 0)

checker_table_pos = checker_pos == 'Oben Rechts' ? position.top_right : checker_pos == 'Oben Links' ? position.top_left : checker_pos == 'Unten Links' ? position.bottom_left : position.bottom_right

var table chk_tbl = table.new(checker_table_pos, 3, 9,
     bgcolor = color.new(#0d0d1a, 5),
     border_color = color.new(#1a1a2e, 0), border_width = 1,
     frame_color = color.new(#ffd700, 30), frame_width = 1)

if show_checker and barstate.islast
    bg_hdr = color.new(#1a1a2e, 0)
    tc_hdr = color.new(#ffd700, 0)

    // Header
    table.cell(chk_tbl, 0, 0, ' ENTRY CHECKER', text_color = tc_hdr, text_size = size_small, bgcolor = color.new(#0d1a2e, 0), text_halign = text.align_left)
    table.cell(chk_tbl, 1, 0, 'Status', text_color = color.new(#888899, 0), text_size = size_tiny, bgcolor = color.new(#0d1a2e, 0), text_halign = text.align_center)
    table.cell(chk_tbl, 2, 0, 'Wert', text_color = color.new(#888899, 0), text_size = size_tiny, bgcolor = color.new(#0d1a2e, 0), text_halign = text.align_center)

    // ATR
    table.cell(chk_tbl, 0, 1, ' ATR Bewegung', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#0d0d1a, 0), text_halign = text.align_left)
    table.cell(chk_tbl, 1, 1, chk_atr ? '✔' : '✘', text_color = chk_atr ? col_green : col_red, text_size = size_normal, bgcolor = chk_atr ? col_bg_on : col_bg_off, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 1, str.tostring(math.round(atr_val, 1)) + ' / ' + str.tostring(math.round(checker_atr_threshold, 1)) + ' pts', text_color = chk_atr ? col_green : col_red, text_size = size_tiny, bgcolor = color.new(#0d0d1a, 0), text_halign = text.align_center)

    // Volumen
    table.cell(chk_tbl, 0, 2, ' Volumen', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#111122, 0), text_halign = text.align_left)
    table.cell(chk_tbl, 1, 2, chk_vol ? '✔' : '✘', text_color = chk_vol ? col_green : col_red, text_size = size_normal, bgcolor = chk_vol ? col_bg_on : col_bg_off, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 2, str.tostring(math.round(vol_ratio, 1)) + 'x avg', text_color = chk_vol ? col_green : col_red, text_size = size_tiny, bgcolor = color.new(#111122, 0), text_halign = text.align_center)

    // EMA
    table.cell(chk_tbl, 0, 3, ' EMA Ausrichtung', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#0d0d1a, 0), text_halign = text.align_left)
    table.cell(chk_tbl, 1, 3, chk_ema ? '✔' : '✘', text_color = chk_ema ? col_green : col_red, text_size = size_normal, bgcolor = chk_ema ? col_bg_on : col_bg_off, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 3, ema_bull ? 'LONG' : ema_bear ? 'SHORT' : 'NEUTRAL', text_color = ema_bull ? col_green : ema_bear ? col_red : col_grey, text_size = size_tiny, bgcolor = color.new(#0d0d1a, 0), text_halign = text.align_center)

    // VWAP
    table.cell(chk_tbl, 0, 4, ' VWAP Seite', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#111122, 0), text_halign = text.align_left)
    table.cell(chk_tbl, 1, 4, chk_vwap ? '✔' : '✘', text_color = chk_vwap ? col_green : col_red, text_size = size_normal, bgcolor = chk_vwap ? col_bg_on : col_bg_off, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 4, vwap_bull ? 'ÜBER VWAP' : 'UNTER VWAP', text_color = vwap_bull ? col_green : col_red, text_size = size_tiny, bgcolor = color.new(#111122, 0), text_halign = text.align_center)

    // Quality Score
    table.cell(chk_tbl, 0, 5, ' ORB Score', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#0d0d1a, 0), text_halign = text.align_left)
    chk_score_col = has_orb ? (chk_score ? col_green : col_red) : col_grey
    chk_score_bg  = has_orb ? (chk_score ? col_bg_on : col_bg_off) : col_bg_na
    table.cell(chk_tbl, 1, 5, has_orb ? (chk_score ? '✔' : '✘') : '—', text_color = chk_score_col, text_size = size_normal, bgcolor = chk_score_bg, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 5, has_orb ? str.tostring(qs_score) + '/100' : 'warte...', text_color = chk_score_col, text_size = size_tiny, bgcolor = color.new(#0d0d1a, 0), text_halign = text.align_center)

    // HTF Trend Bias
    table.cell(chk_tbl, 0, 6, ' HTF Trend', text_color = color.new(#e8e8ff, 0), text_size = size_small, bgcolor = color.new(#111122, 0), text_halign = text.align_left)
    table.cell(chk_tbl, 1, 6, chk_htf ? '✔' : '✘', text_color = chk_htf ? col_green : col_red, text_size = size_normal, bgcolor = chk_htf ? col_bg_on : col_bg_off, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 6, htf_bull ? 'LONG' : htf_bear ? 'SHORT' : 'NEUTRAL', text_color = htf_bull ? col_green : htf_bear ? col_red : col_grey, text_size = size_tiny, bgcolor = color.new(#111122, 0), text_halign = text.align_center)

    // Gesamt-Score
    chk_count = (chk_atr ? 1 : 0) + (chk_vol ? 1 : 0) + (chk_ema ? 1 : 0) + (chk_vwap ? 1 : 0) + (chk_score ? 1 : 0) + (chk_htf ? 1 : 0)
    chk_max = 6
    chk_all_ok = chk_count >= 5
    chk_total_col = chk_count >= 5 ? col_green : chk_count >= 4 ? color.new(#ffd700, 0) : col_red
    chk_total_bg  = chk_count >= 5 ? col_bg_on : chk_count >= 4 ? color.new(#2e2200, 0) : col_bg_off
    chk_total_txt = chk_count >= 5 ? '✔ ENTRY OK' : chk_count >= 4 ? '⚠ PRÜFEN' : '✘ WARTEN'
    table.cell(chk_tbl, 0, 7, ' Gesamt', text_color = chk_total_col, text_size = size_small, bgcolor = chk_total_bg, text_halign = text.align_left)
    table.cell(chk_tbl, 1, 7, str.tostring(chk_count) + '/' + str.tostring(chk_max), text_color = chk_total_col, text_size = size_small, bgcolor = chk_total_bg, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 7, chk_total_txt, text_color = chk_total_col, text_size = size_small, bgcolor = chk_total_bg, text_halign = text.align_center)

    // Richtung — wie viele Kriterien sprechen fuer LONG vs SHORT (ATR und Vol sind richtungslos, zaehlen nicht mit)
    chk_long_count = (ema_bull ? 1 : 0) + (vwap_bull ? 1 : 0) + (htf_bull ? 1 : 0)
    chk_short_count = (ema_bear ? 1 : 0) + (vwap_bear ? 1 : 0) + (htf_bear ? 1 : 0)
    chk_dir_txt = chk_long_count > chk_short_count ? '▲ LONG BIAS' : chk_short_count > chk_long_count ? '▼ SHORT BIAS' : '— GEMISCHT'
    chk_dir_col = chk_long_count > chk_short_count ? col_green : chk_short_count > chk_long_count ? col_red : color.new(#ffd700, 0)
    chk_dir_bg  = chk_long_count > chk_short_count ? col_bg_on : chk_short_count > chk_long_count ? col_bg_off : color.new(#2e2200, 0)
    table.cell(chk_tbl, 0, 8, ' Richtung', text_color = chk_dir_col, text_size = size_small, bgcolor = chk_dir_bg, text_halign = text.align_left)
    table.cell(chk_tbl, 1, 8, str.tostring(chk_long_count) + 'L / ' + str.tostring(chk_short_count) + 'S', text_color = chk_dir_col, text_size = size_small, bgcolor = chk_dir_bg, text_halign = text.align_center)
    table.cell(chk_tbl, 2, 8, chk_dir_txt, text_color = chk_dir_col, text_size = size_small, bgcolor = chk_dir_bg, text_halign = text.align_center)

// ═══════════════════════════════════════════════════════════════════════════════
// TRADE-LISTE
// ═══════════════════════════════════════════════════════════════════════════════
tl_table_pos = tl_pos == 'Oben Rechts' ? position.top_right : tl_pos == 'Oben Links' ? position.top_left : tl_pos == 'Unten Rechts' ? position.bottom_right : position.bottom_left
tl_text_size = tl_size == 'Klein' ? size.tiny : tl_size == 'Groß' ? size.normal : size.small

var table tl_tbl = table.new(tl_table_pos, 5, 89, bgcolor = color.new(#0d0d1a, 5), border_color = color.new(#1a1a2e, 0), border_width = 1, frame_color = color.new(#00d4ff, 30), frame_width = 1)

if show_trade_list and barstate.islast
    tl_bg_hdr = color.new(#0d1a2e, 0)
    table.cell(tl_tbl, 0, 0, 'ZEIT', text_color = color.new(#00d4ff, 0), text_size = tl_text_size, bgcolor = tl_bg_hdr, text_halign = text.align_left)
    table.cell(tl_tbl, 1, 0, 'SIGNAL', text_color = color.new(#00d4ff, 0), text_size = tl_text_size, bgcolor = tl_bg_hdr, text_halign = text.align_center)
    table.cell(tl_tbl, 2, 0, 'RISIKO', text_color = color.new(#00d4ff, 0), text_size = tl_text_size, bgcolor = tl_bg_hdr, text_halign = text.align_center)
    table.cell(tl_tbl, 3, 0, 'ERGEBNIS', text_color = color.new(#00d4ff, 0), text_size = tl_text_size, bgcolor = tl_bg_hdr, text_halign = text.align_center)
    table.cell(tl_tbl, 4, 0, 'P&L', text_color = color.new(#00d4ff, 0), text_size = tl_text_size, bgcolor = tl_bg_hdr, text_halign = text.align_right)

    tl_count = math.min(array.size(tl_time), tl_rows)
    if tl_count > 0
        for r = 0 to tl_count - 1
            t_time = array.get(tl_time, r)
            t_dir = array.get(tl_dir, r)
            t_risk = array.get(tl_risk_ticks, r)
            t_result = array.get(tl_result, r)
            t_pnl = array.get(tl_pnl, r)

            row_bg = r % 2 == 0 ? color.new(#111122, 0) : color.new(#0d0d1a, 0)
            time_txt = str.format('{0,date,dd.MM} {0,time,HH:mm}', t_time)
            sig_txt = t_dir == 1 ? 'BUY' : 'SELL'
            sig_col = t_dir == 1 ? col_green : col_red
            result_txt = t_result == 2 ? 'TP ✓' : t_result == 3 ? 'Schluss' : 'SL ✗'
            result_col = t_result == 2 ? col_green : t_result == 3 ? color.new(#ffd700, 0) : col_red
            pnl_txt = (t_pnl >= 0 ? '+$' : '-$') + str.tostring(math.abs(math.round(t_pnl)))
            pnl_col = t_pnl >= 0 ? col_green : col_red

            table.cell(tl_tbl, 0, r + 1, time_txt, text_color = color.new(#888899, 0), text_size = tl_text_size, bgcolor = row_bg, text_halign = text.align_left)
            table.cell(tl_tbl, 1, r + 1, sig_txt, text_color = sig_col, text_size = tl_text_size, bgcolor = row_bg, text_halign = text.align_center)
            table.cell(tl_tbl, 2, r + 1, str.tostring(t_risk) + ' T', text_color = color.new(#e8e8ff, 0), text_size = tl_text_size, bgcolor = row_bg, text_halign = text.align_center)
            table.cell(tl_tbl, 3, r + 1, result_txt, text_color = result_col, text_size = tl_text_size, bgcolor = row_bg, text_halign = text.align_center)
            table.cell(tl_tbl, 4, r + 1, pnl_txt, text_color = pnl_col, text_size = tl_text_size, bgcolor = row_bg, text_halign = text.align_right)

// ═══════════════════════════════════════════════════════════════════════════════
// TRAP DETECTION — VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
if show_trap and trap_bull_detected
    label.new(bar_index, high + atr_val * 0.2, 'BULL TRAP', style = label.style_label_down, color = trap_color, textcolor = color.white, size = size.normal)

if show_trap and trap_bear_detected
    label.new(bar_index, low - atr_val * 0.2, 'BEAR TRAP', style = label.style_label_up, color = trap_color, textcolor = color.white, size = size.normal)

bgcolor(show_trap and (trap_bull_detected or trap_bear_detected) ? trap_bg_color : na, title = 'Trap Background')

// ═══════════════════════════════════════════════════════════════════════════════
// VECTOR CANDLES — Volumen + Range Klimax-Erkennung (letzte X Kerzen)
// ═══════════════════════════════════════════════════════════════════════════════
vec_vol_avg = ta.sma(volume, vec_lookback)
vec_range_avg = ta.sma(high - low, vec_lookback)
vec_vol_ratio = vec_vol_avg > 0 ? volume / vec_vol_avg : 0.0
vec_range_ratio = vec_range_avg > 0 ? (high - low) / vec_range_avg : 0.0

vec_is_climax = vec_vol_ratio >= vec_climax_vol_mult and vec_range_ratio >= vec_range_mult
vec_is_elevated = not vec_is_climax and vec_vol_ratio >= vec_elevated_vol_mult
vec_is_light = not vec_is_climax and not vec_is_elevated and vec_vol_ratio >= vec_light_vol_mult

vec_climax_up = vec_is_climax and close > open
vec_climax_down = vec_is_climax and close < open

// Nur Climax wird als Symbol gezeichnet (spart Plot-Ressourcen) — Elevated bleibt reine Hintergrund-Berechnung
vec_elevated_up = vec_is_elevated and close > open
vec_elevated_down = vec_is_elevated and close < open
vec_light_up = vec_is_light and close > open
vec_light_down = vec_is_light and close < open

// Climax = Dreieck (staerkeres Signal) | Elevated = mittlerer Punkt | Light = kleinster Punkt
// Alle 3 Staerken in EINEM Symbol pro Richtung — Farbe zeigt die Staerke (statt 6 separate Symbole)
vec_up_active = vec_climax_up or vec_elevated_up or vec_light_up
vec_down_active = vec_climax_down or vec_elevated_down or vec_light_down
vec_up_col = vec_climax_up ? vec_climax_up_col : vec_elevated_up ? vec_elevated_up_col : vec_light_up_col
vec_down_col = vec_climax_down ? vec_climax_down_col : vec_elevated_down ? vec_elevated_down_col : vec_light_down_col

plotchar(show_vec_candles and vec_up_active, title = 'Vector Up', char = '▲', location = location.belowbar, color = vec_up_col, size = size.tiny)
plotchar(show_vec_candles and vec_down_active, title = 'Vector Down', char = '▼', location = location.abovebar, color = vec_down_col, size = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION BACKGROUND
// ═══════════════════════════════════════════════════════════════════════════════
bgcolor(in_london ? ldn_bg_color : na, title = 'London Session Bg')
bgcolor(in_ny ? ny_bg_color : na, title = 'NY Open Session Bg')

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(long_ok, title = 'ORB BUY Signal', message = 'BUY -- {{ticker}} @ {{close}} | ORB Breakout hoch | EMA + VWAP OK | M15 bestaetigt')
alertcondition(short_ok, title = 'ORB SELL Signal', message = 'SELL -- {{ticker}} @ {{close}} | ORB Breakout runter | EMA + VWAP OK | M15 bestaetigt')
alertcondition(ema_cross_up and has_orb, title = 'EMA Cross UP', message = 'EMA Cross UP -- {{ticker}} @ {{close}}')
alertcondition(ema_cross_down and has_orb, title = 'EMA Cross DOWN', message = 'EMA Cross DOWN -- {{ticker}} @ {{close}}')
alertcondition(vwap_x_up and has_orb, title = 'VWAP Cross UP', message = 'VWAP Cross UP -- {{ticker}} @ {{close}}')
alertcondition(vwap_x_dn and has_orb, title = 'VWAP Cross DOWN', message = 'VWAP Cross DOWN -- {{ticker}} @ {{close}}')
alertcondition(any_orb_ended, title = 'ORB Range gesetzt', message = 'ORB Range gesetzt -- {{ticker}} | H: {{high}} | L: {{low}}')
alertcondition(show_trap_alert and trap_bull_detected, title = 'BULL TRAP erkannt', message = 'BULL TRAP -- {{ticker}} @ {{close}} | Preis zurueck unter ORH — Fake Breakout!')
alertcondition(show_trap_alert and trap_bear_detected, title = 'BEAR TRAP erkannt', message = 'BEAR TRAP -- {{ticker}} @ {{close}} | Preis zurueck ueber ORL — Fake Breakout!')
````
