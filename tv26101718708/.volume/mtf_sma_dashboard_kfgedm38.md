# MTF SMA + Dashboard

- url: https://www.tradingview.com/script/KfGeDm38-MTF-SMA-Dashboard/
- type: indicator
- pine_id: PUB;4e7a9c51dacc432abe38f12e73c3f607
- version: 3.0

## Description

[image]https://www.tradingview.com/x/0YpfQ4eJ/[/image]

[b]Overview[/b]
This indicator answers one question at a glance: on which timeframes is the fast SMA above the slow SMA, and on which is it below? It reads the relationship between two simple moving averages (default lengths 9 and 20) on up to seven timeframes and shows the result as a compact table of colored badges directly on the chart. Each badge reads "Bull" when the fast SMA is above the slow SMA and "Bear" when it is below.

The goal is not to introduce a new moving average. The goal is to remove the need to flip through seven charts to check whether the short-term and higher-timeframe trend agree. Two things set the script apart:

[list]
[*]A multi-timeframe overlay table that sits on the price chart itself. Seven timeframes are condensed into one small block of badges, with an alignment count, an alignment background tint, alignment alerts and an explicit choice between confirmed and live higher-timeframe data.
[*]Customization down to the single element. Every timeframe slot, every optional row, every color, both text sizes, the grid, the frame, the position and the margin on each edge can be set independently, so the table fits an existing chart layout instead of forcing the layout to fit the table.
[/list]

[b]What is displayed[/b]
[list]
[*]One badge pair per timeframe, for example "H4 | Bear". Defaults are D1, H4, H1, M30, M15, M5 and M1. Every timeframe can be changed or switched off individually.
[*]An optional header row showing the SMA lengths in use.
[*]An optional summary badge that counts the majority side across the active timeframes, for example "5/7 Bull".
[*]Optionally the two SMA lines of the chart timeframe.
[*]An optional light background tint on bars where all active timeframes point the same way.
[/list]
If the two averages are exactly equal, or a timeframe does not yet have enough bars to calculate the slow SMA, the badge shows a neutral dash instead of Bull or Bear.

[b]Built to fit your chart, not the other way round[/b]
Dashboard tables often collide with what is already on the chart: the legend at the top, the logo at the bottom left, other indicator tables in the corners. This script treats the layout as a first-class feature.

[list]
[*]Nine positions, vertical or horizontal arrangement, and a separate margin for the top, bottom, left and right edge. A margin only takes effect on the edge the table is actually placed on, so the table can be moved clear of the legend or the logo without shifting anything else.
[*]A compact mode merges the timeframe label and the state into a single badge per timeframe, which roughly halves the width of the table.
[*]Timeframe slots that are switched off disappear and the remaining badges close the gap, so the table is never larger than it needs to be. The same applies to the optional header and summary rows.
[*]Background color and text color are independent for Bull, Bear, neutral and the timeframe label. Text color is never derived from the background, so the text stays readable with any opacity setting.
[*]The grid between the badges can follow the chart background, which makes the badges look detached, or take a custom color for a classic table look. The gap width and an optional outer frame are adjustable.
[*]Text sizes are set separately for the timeframe label and the state, and the font can be switched to monospace for evenly aligned columns.
[*]The badge texts are available in English and German, or can be replaced by any custom wording.
[/list]

[b]How it works[/b]
For each timeframe the script requests the state of the two SMAs through request.security() on the chart's own symbol. The state is +1 when SMA(fast) > SMA(slow), -1 when SMA(fast) < SMA(slow) and 0 otherwise. The table is drawn once on the last bar, while the states themselves are calculated on every bar so that the background tint and the alerts work across the whole chart history.

The summary badge counts how many active timeframes are bullish and how many are bearish and displays the larger group. Timeframes that are switched off are excluded from the count, from the tint and from the alerts.

[b]Repainting: please read[/b]
The input "Live mode" controls how higher-timeframe data is read, and it changes the behavior of the script materially.

[list]
[*]Live mode ON (default): the state of the bar that is still forming on each timeframe is used. The dashboard reacts immediately, but a badge can flip back and forth until the bar of that timeframe closes. On historical bars only confirmed values exist, so the background tint you see in history can differ from what was visible in real time. In this mode the script repaints.
[*]Live mode OFF: the script reads the state of the last completed bar of each timeframe, using the value offset by one bar together with barmerge.lookahead_on. This is the documented pattern for non-repainting higher-timeframe requests. It does not look into the future on historical bars, and in real time a badge changes only when a bar of that timeframe closes. History and real time match. The trade-off is a delay of up to one bar of the respective timeframe.
[/list]
If you use the alerts or evaluate the tint on past data, switch Live mode off.

[b]How to use it[/b]
The dashboard is a context tool. A typical use is to check whether the lower timeframes you trade on agree with the higher-timeframe direction before acting on your own setup, or to be notified when all selected timeframes line up. It does not generate entries, exits, stops or targets, and an SMA relationship alone is not a trading system. Moving averages lag by construction, and in ranging markets the badges will flip frequently.

[b]Alerts[/b]
Two alert conditions are available: all active timeframes have turned Bull, and all active timeframes have turned Bear. Each fires on the bar where full alignment is first reached. The alerts can be silenced with a single input. For stable alerts, switch Live mode off and set the alert to trigger once per bar close.

[b]Settings[/b]
[list]
[*]Display language of the badges: English, German or custom text.
[*]On/off switches: dashboard, header row, summary badge, compact single-badge mode, SMA lines, alignment tint, alerts.
[*]SMA: fast length, slow length, source, Live mode, line colors.
[*]Timeframes: seven slots, each with its own on/off switch and timeframe selector. Badge labels such as H4 or M15 are derived automatically.
[*]Position and margins, grid and frame, font, colors: as described in the layout section above.
[/list]
The settings are grouped and numbered in the dialog, starting with the display language.

[b]Limitations[/b]
[list]
[*]Timeframes lower than the chart timeframe are supported, but the badge then shows the state of the last lower-timeframe bar inside the current chart bar. For a consistent reading, use the dashboard on a chart timeframe that is equal to or lower than the lowest active timeframe, or switch the lower slots off.
[*]The script issues two data requests per timeframe slot, fourteen in total with the default configuration.
[*]Timeframes without sufficient history show the neutral dash until the slow SMA can be calculated.
[*]Input labels in the settings dialog are shown in English and German at the same time, because Pine Script does not allow input titles to change at runtime.
[/list]

This script is provided for informational and educational purposes. It is not financial advice.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  MTF SMA Dashboard                                                   v3.5
// ───────────────────────────────────────────────────────────────────────────
//  One indicator made of five independently switchable modules.
//
//  A) MTF SMA Dashboard  ·  SMA 9 / SMA 20 on seven timeframes
//     Pill table: is the fast SMA above (Bull) or below (Bear) the slow SMA?
//     Logic unchanged from "MTF SMA Dashboard (9/20)".
//     Repainting: live mode off = request.security(.., state[1],
//     lookahead_on) -> last CLOSED candle of each timeframe, no repainting.
//     Live mode on = open candle, may flip until the candle closes.
//
//  B) FU Candle - Liquidity Sweep Detector (from FU Candle Sweep v1.2)
//     AFU  Attempted FU : wick sweeps the previous candle's extreme, close
//                         reclaims the previous candle's BODY (not its wick).
//     FU   FU           : wick sweeps the previous candle's extreme, close
//                         reclaims the previous candle's full RANGE.
//     SFU  Strong FU    : FU that additionally sweeps a multi-bar swing
//                         extreme and/or shows ATR displacement.
//     Labels with mouse-over tooltip, FVG boxes, level lines, candle colors.
//
//  C) Bollinger Bands  ·  lines, fill, price labels, optional FU filter.
//
//  D) MTF SMA lines  ·  up to 8 SMA lines from freely selectable timeframes
//     (input.timeframe dropdown = the chart's "Time interval" menu incl. own
//     intervals), e.g. SMA 200 of H4 on an M15 chart. Each line with its own
//     length, color, width and style plus a label such as "H4 · SMA 200".
//
//  E) Periodic Volume Profile  ·  up to 3 profiles (default D / W / M) with
//     POC, value area (VAH / VAL), naked-POC tracking and developing paths.
//     This module is derived from "[Pt] Periodic Volume Profile" (c) PtGambler,
//     itself based on "Volume Profile, Pivot Anchored" (c) dgtrd, and is
//     subject to the terms of the Mozilla Public License 2.0
//     (https://mozilla.org/MPL/2.0/). v6 migration + 3 instances: Wick-Sniper.
//
//  Language
//     The input "Sprache der Anzeige / Display language" controls the pill
//     texts AND the tooltips of all labels (Deutsch -> German, English and
//     Custom -> English). Menu texts are constants in Pine and therefore
//     bilingual ("Deutsch / English").
//
//  Settings dialog
//     Group 0 holds one switch per module. Group titles carry a colored
//     module mark. Inputs of a switched-off module are dimmed (active =).
//
//  Changelog
//    v3.5  Naming: the module is a Periodic Volume Profile (PVP), one type of
//          volume profile (one profile per fixed period). Module switch,
//          group tag, legend header and plot titles now say PVP.
//    v3.4  Fix for "The requested historical offset is beyond the historical
//          buffer's limit": fixed time buffer (max_bars_back) and x clamp to
//          that window. Color legend rebuilt as pills like the dashboard
//          table (line color = pill background), with the same options:
//          position, layout, header, margins, pill gap, grid, frame, font
//          sizes and font.
//    v3.3  Volume profile: optional color legend on the chart (group 24) that
//          lists which line color stands for which level of which profile.
//          New switch "Show volume rows" per profile. New defaults: only the
//          POC line of the developing day / week / month profile is shown;
//          rows, completed profiles, previous levels, VAH / VAL, fills,
//          developing paths, naked-POC tracking and markers start switched
//          off. The POC line of a completed period is only kept when
//          completed profiles are shown or naked POCs are tracked.
//    v3.2  Fix for runtime error RE10140 (79 plot counts, limit 64): a plot
//          whose color is not a constant counts twice. The developing paths
//          and the naked-POC markers of the volume profile now use constant
//          colors (changeable in the Style tab), the six per-profile POC
//          alerts are merged into "any naked POC crossed / touched".
//          The script now uses 60 of 64 plot counts.
//    v3.1  New module "Volume profile" (groups 24-27, switch in group 0).
//          Optimized against the stand-alone script: row volumes are
//          extended bar by bar instead of being recalculated over the whole
//          period every time (rebuild only on a new period high / low);
//          period high / low tracked on the way; one shared delete pass for
//          the developing drawings of all profiles; level labels go through
//          the shared label engine with collision guard (no labels of their
//          own); 13 instead of 21 plots; no additional data requests.
//          All code comments in English.
//    v3.0  New defaults: dashboard at the bottom right; Bollinger basis in
//          the color of the SMA 20 (#FF0014), Bollinger fill white; MTF SMA
//          slots M30 9/20, H1 9/20/200, H4 9/20/200, all dotted, blue shades
//          for SMA 9, red shades for SMA 20; price shown in the line labels.
//    v2.9  The SMA 9/20 lines of the chart timeframe get labels like the MTF
//          SMA lines ("M15 · SMA 9"), switch in group 3. They run through
//          the same layout, so the collision guard covers them together
//          with the MTF SMA and Bollinger labels.
//    v2.8  Settings dialog: new group "0 · MODULES" at the very top with
//          quick switches. Group titles carry a colored module mark.
//          Inputs of a switched-off module are dimmed (active =).
//    v2.7  The collision guard now also covers the Bollinger labels: MTF SMA
//          and Bollinger labels share one layout pass (common sorting,
//          spreading / staggering, connector line). Bollinger "Text only"
//          is therefore left-aligned at the anchor point.
//    v2.6  MTF SMA labels: distances named more clearly and new input
//          "Extra offset of moved labels" for labels moved by the guard.
//    v2.5  Pill table for the MTF SMA lines (v2.4) removed again. Instead
//          the labels of the MTF SMA lines are pills like the Bollinger
//          labels by default. Default font size of all labels: Normal.
//    v2.4  (withdrawn) MTF SMA lines as a pill table.
//    v2.3  Alignment background: own colors for Bull and Bear (group 23),
//          opacity in the color picker. Before, the tint was tied to the
//          pill colors at 90 % transparency.
//    v2.2  Collision guard for the labels of the MTF SMA lines: labels too
//          close in price are spread vertically (with a connector line to
//          the real price) or staggered to the right.
//    v2.1  New module "MTF SMA lines" (group 22): 8 slots with timeframe
//          (input.timeframe), length, color, width, style; label with
//          tooltip; live mode or closed candles only; timeframes below the
//          chart timeframe can be hidden.
//    v2.0  MTF SMA Dashboard (9/20) and FU Candle Sweep v1.2 (incl.
//          Bollinger Bands) merged into one indicator. Shared language
//          input, FU menu switched to the "Deutsch / English" notation,
//          groups 12-21 for FU and Bollinger.
// ═══════════════════════════════════════════════════════════════════════════
indicator("MTF SMA Dashboard", shorttitle = "MTF SMA", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// Drawings anchored on bar_index in the past read the time series that far
// back. Without a fixed buffer the runtime sizes it from the historical run
// and a realtime update can ask for one bar more (error "historical offset
// is beyond the buffer's limit"). 5000 is the maximum; f_pvpX() clamps all
// x coordinates to that window.
max_bars_back(time, 5000)

// =============================================================================
// === OPTION CONSTANTS ========================================================
// =============================================================================
string SZ_TINY    = "Winzig / Tiny"
string SZ_SMALL   = "Klein / Small"
string SZ_NORMAL  = "Normal"
string SZ_LARGE   = "Groß / Large"
string SZ_HUGE    = "Riesig / Huge"
string SZ_AUTO    = "Auto"

string SH_LABEL   = "Etikett / Label"
string SH_TRI     = "Dreieck / Triangle"
string SH_ARROW   = "Pfeil / Arrow"
string SH_CIRCLE  = "Kreis / Circle"
string SH_DIAMOND = "Raute / Diamond"
string SH_SQUARE  = "Quadrat / Square"
string SH_FLAG    = "Flagge / Flag"
string SH_CROSS   = "Kreuz / Cross"
string SH_XCROSS  = "X-Kreuz / X-Cross"
string SH_TEXT    = "Nur Text / Text only"

string LS_SOLID   = "Durchgezogen / Solid"
string LS_DASHED  = "Gestrichelt / Dashed"
string LS_DOTTED  = "Gepunktet / Dotted"

string TM_OFF     = "Aus / Off"
string TM_WITH    = "Mit Trend / With trend"
string TM_COUNTER = "Gegen Trend / Counter trend"

string FT_DEFAULT = "Standard / Default"
string FT_MONO    = "Monospace"

string PS_LINE    = "Linie / Line"
string PS_STEP    = "Treppe / Step line"

string CG_VERT    = "Vertikal spreizen / Spread vertically"
string CG_STEP    = "Nach rechts staffeln / Stagger to the right"
string CG_OFF     = "Aus / Off"

string PL_RIGHT   = "Rechts / Right"
string PL_LEFT    = "Links / Left"
string PL_NEXT    = "Nächste Periode / Next period"

string PX_LAST    = "Bis zur letzten Kerze / Until last bar"
string PX_CROSS   = "Bis eine Kerze kreuzt / Until bar cross"
string PX_TOUCH   = "Bis eine Kerze berührt / Until bar touch"
string PX_NONE    = "Keine / None"
string LP_TL      = "Oben links / Top left"
string LP_TC      = "Oben mitte / Top center"
string LP_TR      = "Oben rechts / Top right"
string LP_ML      = "Mitte links / Middle left"
string LP_MC      = "Mitte / Middle"
string LP_MR      = "Mitte rechts / Middle right"
string LP_BL      = "Unten links / Bottom left"
string LP_BC      = "Unten mitte / Bottom center"
string LP_BR      = "Unten rechts / Bottom right"
string LL_VERT    = "Vertikal / Vertical"
string LL_HOR     = "Horizontal"
string LF_DEF     = "Standard / Default"
string LF_MONO    = "Monospace"

string MA_SMA     = "SMA"
string MA_EMA     = "EMA"
string MA_RMA     = "SMMA (RMA)"
string MA_WMA     = "WMA"
string MA_VWMA    = "VWMA"

// ───────────────────────────────────────────────────────────────────────────
//  0) Module switches  (always at the very top of the dialog)
// ───────────────────────────────────────────────────────────────────────────
string G_MOD = "⚙️ 0 · MODULE / MODULES"
bool showDash    = input.bool(true, "🟦 Dashboard-Tabelle / Dashboard table", group = G_MOD, tooltip = "Pillen-Tabelle SMA 9/20 auf sieben Zeitebenen. Einstellungen: Gruppen 2 und 4-11.\nPill table SMA 9/20 on seven timeframes. Settings: groups 2 and 4-11.")
bool showSma     = input.bool(true, "🟦 SMA-Linien 9/20 (Chart-TF) / SMA lines 9/20 (chart TF)", group = G_MOD, tooltip = "Schneller und langsamer SMA der Chart-Zeitebene. Einstellungen: Gruppe 3.\nFast and slow SMA of the chart timeframe. Settings: group 3.")
bool bgTint      = input.bool(true, "🟦 Hintergrund bei Gleichlauf / Background on alignment", group = G_MOD, tooltip = "Färbt den Hintergrund, solange alle aktiven Dashboard-Zeitebenen in dieselbe Richtung zeigen. Farben: Gruppe 23.\nTints the background while all active dashboard timeframes point the same way. Colors: group 23.")
bool showFuMod   = input.bool(true, "🟧 FU-Kerzen / FU candles", group = G_MOD, tooltip = "FU / SFU / AFU: Labels, Kerzenfarben, FVG-Boxen, Level und FU-Alerts. Einstellungen: Gruppen 12-20.\nFU / SFU / AFU: labels, candle colors, FVG boxes, levels and FU alerts. Settings: groups 12-20.")
bool showBB      = input.bool(true, "🟪 Bollinger-Bänder / Bollinger Bands", group = G_MOD, tooltip = "Linien, Fläche und Labels der Bänder. Der FU-Filter aus Gruppe 21 wirkt auch bei ausgeblendeten Bändern. Einstellungen: Gruppe 21.\nLines, fill and labels of the bands. The FU filter of group 21 works even when the bands are hidden. Settings: group 21.")
bool showMtf     = input.bool(true, "🟩 MTF-SMA-Linien / MTF SMA lines", group = G_MOD, tooltip = "SMA-Linien aus anderen Zeitebenen, z. B. SMA 200 des 4-Stunden-Charts. Einstellungen: Gruppe 22.\nSMA lines from other timeframes, e.g. the SMA 200 of the 4-hour chart. Settings: group 22.")
bool showPvp     = input.bool(true, "🟨 Periodisches Volumenprofil (PVP) / Periodic Volume Profile (PVP)", group = G_MOD, tooltip = "PVP ist eine Art von Volumenprofil: je ein Profil pro fester Periode. Bis zu drei periodische Volumenprofile (Standard Tag, Woche, Monat) mit POC, Value Area und offenen POCs. Einstellungen: Gruppen 24-27.\nPVP is one type of volume profile: one profile per fixed period. Up to three periodic volume profiles (default day, week, month) with POC, value area and naked POCs. Settings: groups 24-27.")

// ───────────────────────────────────────────────────────────────────────────
//  A1) Dashboard inputs  (titles bilingual: Deutsch / English)
// ───────────────────────────────────────────────────────────────────────────
grpLang = "⚙️ 1 · Sprache / Language"
string langInp = input.string("English", "Sprache der Anzeige / Display language", options = ["Deutsch", "English", "Benutzerdefiniert / Custom"], group = grpLang, tooltip = "Betrifft die Texte in den Pillen (Bulle/Bär, Kopfzeile) und die Tooltips der FU- und Bollinger-Labels. 'Benutzerdefiniert' nutzt die Felder darunter; die Tooltips sind dann englisch.\n" + "Affects the pill texts (Bull/Bear, header) and the tooltips of the FU and Bollinger labels. 'Custom' uses the fields below; tooltips are English then.")
string cusBull    = input.string("Bulle", "Eigener Text Bulle / Custom text Bull",       group = grpLang)
string cusBear    = input.string("Bär",   "Eigener Text Bär / Custom text Bear",         group = grpLang)
string cusTf      = input.string("TF",    "Eigener Text Kopfzeile / Custom header text", group = grpLang)
string txtNeutInp = input.string("–",     "Text neutral / Neutral text",                 group = grpLang)
string txtSumInp  = input.string("Σ",     "Label Zusammenfassung / Summary label",       group = grpLang)

grpOn = "🟦 DASHBOARD │ 2 · Ein-Aus / On-Off"
bool showHeader  = input.bool(true,  "Kopfzeile / Header  [ TF | SMA 9/20 ]",                            group = grpOn, active = showDash)
bool showSummary = input.bool(true,  "Zusammenfassung / Summary  [ Σ | 5/7 ]",                           group = grpOn, active = showDash)
bool compactMode = input.bool(false, "Kompakt (eine Pille) / Compact (single pill)",                     group = grpOn, active = showDash)
bool alertsOn    = input.bool(true,  "Alerts bei Gleichlauf / Alerts on alignment",                      group = grpOn)

grpSma = "🟦 DASHBOARD │ 3 · SMA 9/20"
int    fastLen    = input.int(9,  "Schneller SMA / Fast SMA", minval = 1, group = grpSma)
int    slowLen    = input.int(20, "Langsamer SMA / Slow SMA", minval = 1, group = grpSma)
float  src        = input.source(close, "Quelle / Source", group = grpSma)
bool   liveMode   = input.bool(true,  "Live-Modus (kann repainten) / Live mode (may repaint)", group = grpSma)
color  smaFastCol = input.color(#2962FF, "Linie schneller SMA / Fast SMA line", group = grpSma, active = showSma)
color  smaSlowCol = input.color(#FF0014, "Linie langsamer SMA / Slow SMA line", group = grpSma, active = showSma)
bool   showSmaLbl = input.bool(true,  "Labels für SMA 9/20 / Labels for SMA 9/20", group = grpSma, tooltip = "Label am rechten Rand wie bei den MTF-SMA-Linien, z. B. 'M15 · SMA 9'. Aussehen (Form, Größe, Schrift, Abstand, Farben) und Kollisionsschutz: Gruppe 22.\nLabel at the right edge like the MTF SMA lines, e.g. 'M15 · SMA 9'. Look (shape, size, font, offset, colors) and collision guard: group 22.", active = showSma)

// Per timeframe: checkbox "An / On" + timeframe on one line.
// Switched-off timeframes disappear from the table and do not count
// towards the summary, the background tint and the alerts.
grpTf = "🟦 DASHBOARD │ 4 · Zeitebenen / Timeframes"
bool   en1 = input.bool(true, "An / On", inline = "tf1", group = grpTf)
string tf1 = input.timeframe("D",   "Zeitebene / Timeframe 1", inline = "tf1", group = grpTf)
bool   en2 = input.bool(true, "An / On", inline = "tf2", group = grpTf)
string tf2 = input.timeframe("240", "Zeitebene / Timeframe 2", inline = "tf2", group = grpTf)
bool   en3 = input.bool(true, "An / On", inline = "tf3", group = grpTf)
string tf3 = input.timeframe("60",  "Zeitebene / Timeframe 3", inline = "tf3", group = grpTf)
bool   en4 = input.bool(true, "An / On", inline = "tf4", group = grpTf)
string tf4 = input.timeframe("30",  "Zeitebene / Timeframe 4", inline = "tf4", group = grpTf)
bool   en5 = input.bool(true, "An / On", inline = "tf5", group = grpTf)
string tf5 = input.timeframe("15",  "Zeitebene / Timeframe 5", inline = "tf5", group = grpTf)
bool   en6 = input.bool(true, "An / On", inline = "tf6", group = grpTf)
string tf6 = input.timeframe("5",   "Zeitebene / Timeframe 6", inline = "tf6", group = grpTf)
bool   en7 = input.bool(true, "An / On", inline = "tf7", group = grpTf)
string tf7 = input.timeframe("1",   "Zeitebene / Timeframe 7", inline = "tf7", group = grpTf)

grpPos = "🟦 DASHBOARD │ 5 · Position & Ränder / Position & Margins"
string posInp    = input.string("Unten rechts / Bottom right", "Position", options = ["Oben links / Top left",       "Oben mitte / Top center",     "Oben rechts / Top right", "Mitte links / Middle left",   "Mitte / Middle",              "Mitte rechts / Middle right", "Unten links / Bottom left",   "Unten mitte / Bottom center", "Unten rechts / Bottom right"], group = grpPos, active = showDash)
string layoutInp = input.string("Vertikal / Vertical", "Anordnung / Layout", options = ["Vertikal / Vertical", "Horizontal"], group = grpPos, active = showDash)
int    padTop    = input.int(0, "Rand oben (Zeilen) / Top margin (rows)",         minval = 0, maxval = 10, group = grpPos, tooltip = "Nur an oberen Positionen. Platz für die Chart-Legende.\nTop positions only. Room for the chart legend.", active = showDash)
int    padBottom = input.int(0, "Rand unten (Zeilen) / Bottom margin (rows)",     minval = 0, maxval = 10, group = grpPos, tooltip = "Nur an unteren Positionen. Platz für das TradingView-Logo.\nBottom positions only. Room for the TradingView logo.", active = showDash)
int    padLeft   = input.int(0, "Rand links (Spalten) / Left margin (columns)",   minval = 0, maxval = 10, group = grpPos, active = showDash)
int    padRight  = input.int(0, "Rand rechts (Spalten) / Right margin (columns)", minval = 0, maxval = 10, group = grpPos, active = showDash)
int    gapPx     = input.int(2, "Pillenabstand (px) / Pill gap (px)",             minval = 0, maxval = 10, group = grpPos, active = showDash)

grpGrid = "🟦 DASHBOARD │ 6 · Gitter & Rahmen / Grid & Frame"
bool   gridAuto  = input.bool(true, "Gitter = Chart-Hintergrund / Grid = chart background", group = grpGrid, tooltip = "An: Pillen wirken freistehend. Aus: eigene Gitterfarbe.\nOn: pills look detached. Off: custom grid color.", active = showDash)
color  gridCol   = input.color(#131722, "Gitterfarbe / Grid color",             group = grpGrid, active = showDash)
int    frameW    = input.int(0, "Rahmen (px) / Frame (px)", minval = 0, maxval = 10, group = grpGrid, active = showDash)
color  frameCol  = input.color(#434651, "Rahmenfarbe / Frame color",           group = grpGrid, active = showDash)

grpText = "🟦 DASHBOARD │ 7 · Schrift / Font"
string sizeTfInp    = input.string("Normal", "Größe Zeitebene / Size timeframe", options = ["Winzig / Tiny", "Klein / Small", "Normal", "Groß / Large", "Riesig / Huge"], group = grpText, active = showDash)
string sizeStateInp = input.string("Normal", "Größe Zustand / Size state", options = ["Winzig / Tiny", "Klein / Small", "Normal", "Groß / Large", "Riesig / Huge"], group = grpText, active = showDash)
string fontInp      = input.string("Standard / Default", "Schriftart / Font", options = ["Standard / Default", "Monospace"], group = grpText, active = showDash)

// Opacity of every color can be set directly in the color picker.
grpColBull = "🟦 DASHBOARD │ 8 · Farben Bulle / Colors Bull"
color bullBg   = input.color(#089981, "Hintergrund / Background", group = grpColBull, active = showDash)
color bullTxt  = input.color(#FFFFFF, "Schrift / Text",           group = grpColBull, active = showDash)

grpColBear = "🟦 DASHBOARD │ 9 · Farben Bär / Colors Bear"
color bearBg   = input.color(#F23645, "Hintergrund / Background", group = grpColBear, active = showDash)
color bearTxt  = input.color(#FFFFFF, "Schrift / Text",           group = grpColBear, active = showDash)

grpColNeut = "🟦 DASHBOARD │ 10 · Farben Neutral / Colors Neutral"
color neutBg   = input.color(#787B86, "Hintergrund / Background", group = grpColNeut, active = showDash)
color neutTxt  = input.color(#FFFFFF, "Schrift / Text",           group = grpColNeut, active = showDash)

grpColTf = "🟦 DASHBOARD │ 11 · Farben Zeitebene & Kopfzeile / Colors Timeframe & Header"
color tfBg     = input.color(#2A2E39, "Hintergrund / Background", group = grpColTf, active = showDash)
color tfTxt    = input.color(#D1D4DC, "Schrift / Text",           group = grpColTf, active = showDash)


// =============================================================================
// === INPUTS: FU CANDLES + BOLLINGER BANDS ====================================
// =============================================================================
string G_GEN = "🟧 FU │ 12 · Allgemein / General"
bool   confirmClose  = input.bool(true, "Erst bei Kerzenschluss bestätigen (kein Repaint) / Confirm on bar close (no repaint)", group = G_GEN, tooltip = "AN: Signale erscheinen erst nach Kerzenschluss. AUS: Signale können erscheinen und wieder verschwinden, solange die Kerze läuft.\nON: signals appear only after the candle has closed. OFF: signals can appear and disappear while the candle is still forming.", active = showFuMod)
bool   showLabels    = input.bool(true, "Labels anzeigen / Show labels", group = G_GEN, active = showFuMod)
bool   showLblText   = input.bool(true, "Text im Label anzeigen (SFU / FU / AFU) / Show text in label (SFU / FU / AFU)", group = G_GEN, tooltip = "Bei der Form 'Nur Text' ist dieser Text der einzige sichtbare Teil des Labels.\nWith the shape 'Text only' this text is the only visible part of the label.", active = showFuMod)
bool   showTip       = input.bool(true, "Tooltip bei Mouseover / Tooltip on mouse-over", group = G_GEN, tooltip = "Maus über ein Label bewegen: Definition des Kerzentyps, abgeholte Kerze, Start (Eröffnung), Sweep-Extrem und Ende (Schluss). Zeiten in der Zeitzone der Börse.\nHover a label to see: definition of the candle type, swept candle, start (open), sweep extreme and end (close). Times use the exchange time zone.", active = showFuMod)
bool   useBarColor   = input.bool(true, "FU-Kerzen einfärben / Color FU candles", group = G_GEN, active = showFuMod)

string G_DET = "🟧 FU │ 13 · Erkennung / Detection"
bool   requireDir    = input.bool(true, "Kerze muss in Signalrichtung schließen / Candle must close in signal direction", group = G_DET, tooltip = "Bullische FU muss eine grüne, bärische FU eine rote Kerze sein.\nBullish FU must be a green candle, bearish FU a red candle.", active = showFuMod)
bool   sfuNeedSwing  = input.bool(true, "SFU erfordert Swing-Sweep / SFU requires swing sweep", group = G_DET, tooltip = "Der Docht muss zusätzlich das tiefste Tief / höchste Hoch des Lookbacks darunter abholen.\nThe wick must also take out the lowest low / highest high of the lookback below.", active = showFuMod)
int    swingLen      = input.int(5, "SFU Swing-Lookback (Kerzen) / SFU swing lookback (bars)", minval = 2, maxval = 200, group = G_DET, active = showFuMod)
bool   sfuNeedDisp   = input.bool(true, "SFU erfordert Displacement / SFU requires displacement", group = G_DET, tooltip = "Die Kerzenspanne muss mindestens das ATR-Vielfache darunter erreichen.\nCandle range must be at least the ATR multiple below.", active = showFuMod)
float  dispMult      = input.float(1.2, "SFU Displacement (x ATR) / SFU displacement (x ATR)", minval = 0.1, step = 0.1, group = G_DET, active = showFuMod)

string G_QLT = "🟧 FU │ 14 · Qualitätsfilter / Quality filters"
int    atrLen        = input.int(14, "ATR-Länge / ATR length", minval = 1, group = G_QLT, active = showFuMod)
float  minRangeAtr   = input.float(0.5, "Min. Kerzenspanne (x ATR) / Min. candle range (x ATR)", minval = 0.0, step = 0.1, group = G_QLT, tooltip = "Filtert sehr kleine Kerzen heraus. 0 = aus.\nFilters out tiny candles. 0 = off.", active = showFuMod)
float  minSweepAtr   = input.float(0.0, "Min. Sweep-Tiefe (x ATR) / Min. sweep depth (x ATR)", minval = 0.0, step = 0.05, group = G_QLT, tooltip = "Wie weit der Docht das vorherige Hoch/Tief überschreiten muss. 0 = jeder Sweep zählt.\nHow far the wick must exceed the previous high/low. 0 = any sweep counts.", active = showFuMod)
float  minBodyPct    = input.float(30.0, "Doji-Filter: Min. Körper (% der Spanne) / Doji filter: min. body (% of range)", minval = 0.0, maxval = 100.0, step = 5.0, group = G_QLT, tooltip = "Kerzen mit kleinerem Körper werden ignoriert. 0 = aus.\nCandles with a smaller body are ignored. 0 = off.", active = showFuMod)
float  minWickBody   = input.float(0.15, "Min. Verhältnis Sweep-Docht / Körper / Min. sweep wick / body ratio", minval = 0.0, step = 0.05, group = G_QLT, tooltip = "Länge des Sweep-Dochts im Verhältnis zum Körper. Höher = ausgeprägterer Ablehnungsdocht. 0 = aus.\nLength of the sweeping wick relative to the body. Higher = more pronounced rejection wick. 0 = off.", active = showFuMod)
float  minCloseLoc   = input.float(55.0, "Min. Schlusslage (% der Spanne) / Min. close location (% of range)", minval = 0.0, maxval = 100.0, step = 5.0, group = G_QLT, tooltip = "Bullisch: Schluss muss im oberen Teil der Kerze liegen; bärisch: im unteren Teil. Entfernt Kerzen, deren Gegendocht die Bewegung ablehnt. 0 = aus.\nBullish: close must be in the upper part of the candle; bearish: in the lower part. Removes candles whose opposite wick rejects the move. 0 = off.", active = showFuMod)

string G_TRD = "🟧 FU │ 15 · Trendfilter (SMA) / Trend filter (SMA)"
string trendMode     = input.string(TM_OFF, "Modus / Mode", options = [TM_OFF, TM_WITH, TM_COUNTER], group = G_TRD, tooltip = "Mit Trend: bullische FU nur über dem SMA, bärische nur darunter. Gegen Trend: umgekehrt (Reversal-Sweeps).\nWith trend: bullish FU only above the SMA, bearish only below. Counter trend: the opposite (reversal sweeps).", active = showFuMod)
int    maLen         = input.int(50, "SMA-Länge / SMA length", minval = 1, group = G_TRD, active = showFuMod)
bool   showMa        = input.bool(false, "SMA zeichnen / Plot SMA", inline = "ma", group = G_TRD, active = showFuMod)
color  cMa           = input.color(#ff9800, "Farbe / Color", inline = "ma", group = G_TRD, active = showFuMod)
int    maWidth       = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "ma", group = G_TRD, tooltip = "Der Linienstil des SMA lässt sich im Tab Stil ändern.\nThe line style of the SMA can be changed in the Style tab.", active = showFuMod)

string G_SFU = "🟧 FU │ 16 · SFU-Darstellung / SFU display"
bool   showSFU     = input.bool(true, "SFU anzeigen (Strong FU) / Show SFU (Strong FU)", group = G_SFU, tooltip = "Wenn aus, werden SFU-Kerzen als normale FU-Kerzen angezeigt.\nIf disabled, SFU candles are shown as normal FU candles.", active = showFuMod)
color  cLblBullSFU = input.color(#00c853, "Label: bullisch / Label: bullish", inline = "sfuL", group = G_SFU, active = showFuMod)
color  cLblBearSFU = input.color(#d50000, "bärisch / bearish", inline = "sfuL", group = G_SFU, active = showFuMod)
color  cTxtSFU     = input.color(color.white, "Text", inline = "sfuL", group = G_SFU, active = showFuMod)
string shpSFU      = input.string(SH_LABEL, "Form / Shape", options = [SH_LABEL, SH_TRI, SH_ARROW, SH_CIRCLE, SH_DIAMOND, SH_SQUARE, SH_FLAG, SH_CROSS, SH_XCROSS, SH_TEXT], inline = "sfuS", group = G_SFU, active = showFuMod)
string szSFU       = input.string(SZ_NORMAL, "Größe / Size", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE, SZ_AUTO], inline = "sfuS", group = G_SFU, active = showFuMod)
color  cBarBullSFU = input.color(#00c853, "Kerze: bullisch / Candle: bullish", inline = "sfuC", group = G_SFU, active = showFuMod)
color  cBarBearSFU = input.color(#d50000, "bärisch / bearish", inline = "sfuC", group = G_SFU, active = showFuMod)

string G_FU = "🟧 FU │ 17 · FU-Darstellung / FU display"
bool   showFU     = input.bool(true, "FU anzeigen / Show FU", group = G_FU, tooltip = "Sweep des Vorkerzen-Extrems + Schluss jenseits des gegenüberliegenden Extrems.\nSweep of the previous candle's extreme + close beyond its opposite extreme.", active = showFuMod)
color  cLblBullFU = input.color(#26a69a, "Label: bullisch / Label: bullish", inline = "fuL", group = G_FU, active = showFuMod)
color  cLblBearFU = input.color(#ef5350, "bärisch / bearish", inline = "fuL", group = G_FU, active = showFuMod)
color  cTxtFU     = input.color(color.white, "Text", inline = "fuL", group = G_FU, active = showFuMod)
string shpFU      = input.string(SH_LABEL, "Form / Shape", options = [SH_LABEL, SH_TRI, SH_ARROW, SH_CIRCLE, SH_DIAMOND, SH_SQUARE, SH_FLAG, SH_CROSS, SH_XCROSS, SH_TEXT], inline = "fuS", group = G_FU, active = showFuMod)
string szFU       = input.string(SZ_NORMAL, "Größe / Size", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE, SZ_AUTO], inline = "fuS", group = G_FU, active = showFuMod)
color  cBarBullFU = input.color(#26a69a, "Kerze: bullisch / Candle: bullish", inline = "fuC", group = G_FU, active = showFuMod)
color  cBarBearFU = input.color(#ef5350, "bärisch / bearish", inline = "fuC", group = G_FU, active = showFuMod)

string G_AFU = "🟧 FU │ 18 · AFU-Darstellung / AFU display"
bool   showAFU     = input.bool(true, "AFU anzeigen (Attempted FU) / Show AFU (Attempted FU)", group = G_AFU, tooltip = "Sweep + Schluss nur jenseits des Vorkerzen-Körpers (nicht jenseits des Dochts).\nSweep + close beyond the previous candle's body only (not beyond its wick).", active = showFuMod)
color  cLblBullAFU = input.color(#80cbc4, "Label: bullisch / Label: bullish", inline = "afuL", group = G_AFU, active = showFuMod)
color  cLblBearAFU = input.color(#ef9a9a, "bärisch / bearish", inline = "afuL", group = G_AFU, active = showFuMod)
color  cTxtAFU     = input.color(color.black, "Text", inline = "afuL", group = G_AFU, active = showFuMod)
string shpAFU      = input.string(SH_LABEL, "Form / Shape", options = [SH_LABEL, SH_TRI, SH_ARROW, SH_CIRCLE, SH_DIAMOND, SH_SQUARE, SH_FLAG, SH_CROSS, SH_XCROSS, SH_TEXT], inline = "afuS", group = G_AFU, active = showFuMod)
string szAFU       = input.string(SZ_NORMAL, "Größe / Size", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE, SZ_AUTO], inline = "afuS", group = G_AFU, active = showFuMod)
color  cBarBullAFU = input.color(#80cbc4, "Kerze: bullisch / Candle: bullish", inline = "afuC", group = G_AFU, active = showFuMod)
color  cBarBearAFU = input.color(#ef9a9a, "bärisch / bearish", inline = "afuC", group = G_AFU, active = showFuMod)

string G_FVG = "🟧 FU │ 19 · Fair Value Gap"
bool   showFvg       = input.bool(true, "FVG einer FU-Kerze markieren / Mark FVG created by an FU candle", group = G_FVG, tooltip = "Wird eine Kerze nach der FU geprüft: Hinterlässt die FU eine Drei-Kerzen-Imbalance, wird die Lücke als Box gezeichnet.\nChecked one bar after the FU candle: if the FU candle left a three-candle imbalance, the gap is drawn as a box.", active = showFuMod)
color  cFvgBull      = input.color(color.new(#26a69a, 82), "Füllung: bullisch / Fill: bullish", inline = "fvgF", group = G_FVG, active = showFuMod)
color  cFvgBear      = input.color(color.new(#ef5350, 82), "bärisch / bearish", inline = "fvgF", group = G_FVG, active = showFuMod)
color  cFvgBdBull    = input.color(color.new(#26a69a, 40), "Rahmen: bullisch / Border: bullish", inline = "fvgB", group = G_FVG, active = showFuMod)
color  cFvgBdBear    = input.color(color.new(#ef5350, 40), "bärisch / bearish", inline = "fvgB", group = G_FVG, active = showFuMod)
string fvgBdStyle    = input.string(LS_SOLID, "Rahmenstil / Border style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "fvgS", group = G_FVG, active = showFuMod)
int    fvgBdWidth    = input.int(1, "Breite / Width", minval = 0, maxval = 5, inline = "fvgS", group = G_FVG, active = showFuMod)
int    fvgExtend     = input.int(10, "Box-Verlängerung (Kerzen) / Box extension (bars)", minval = 1, maxval = 100, group = G_FVG, active = showFuMod)
int    fvgMax        = input.int(20, "Max. FVG-Boxen / Max. FVG boxes", minval = 1, maxval = 100, group = G_FVG, active = showFuMod)

string G_LVL = "🟧 FU │ 20 · Level / Levels"
bool   showLevels    = input.bool(false, "Körper-50% + Docht-Level zeichnen / Draw body 50% + wick level", group = G_LVL, tooltip = "Körper-50% = gängige Referenz für Limit-Einstiege. Docht-Level = Invalidierung des Sweeps.\nBody 50% = common limit-entry reference. Wick level = invalidation of the sweep.", active = showFuMod)
color  cMidBull      = input.color(#26a69a, "Körper-50%: bullisch / Body 50%: bullish", inline = "midC", group = G_LVL, active = showFuMod)
color  cMidBear      = input.color(#ef5350, "bärisch / bearish", inline = "midC", group = G_LVL, active = showFuMod)
string midStyle      = input.string(LS_DASHED, "Körper-50%: Stil / Body 50%: style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "midS", group = G_LVL, active = showFuMod)
int    midWidth      = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "midS", group = G_LVL, active = showFuMod)
color  cWickBull     = input.color(color.new(#26a69a, 40), "Docht-Level: bullisch / Wick level: bullish", inline = "wickC", group = G_LVL, active = showFuMod)
color  cWickBear     = input.color(color.new(#ef5350, 40), "bärisch / bearish", inline = "wickC", group = G_LVL, active = showFuMod)
string wickStyle     = input.string(LS_DOTTED, "Docht-Level: Stil / Wick level: style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "wickS", group = G_LVL, active = showFuMod)
int    wickWidth     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "wickS", group = G_LVL, active = showFuMod)
int    lvlLen        = input.int(8, "Level-Länge (Kerzen) / Level length (bars)", minval = 1, maxval = 100, group = G_LVL, active = showFuMod)
int    lvlMax        = input.int(30, "Max. FU-Kerzen mit Leveln / Max. FU candles with levels", minval = 1, maxval = 100, group = G_LVL, active = showFuMod)

string G_BB = "🟪 BOLLINGER │ 21 · Bänder & Labels / Bands & labels"
int    bbLen         = input.int(20, "Länge / Length", minval = 1, group = G_BB)
string bbMaType      = input.string(MA_SMA, "MA-Typ der Basis / Basis MA type", options = [MA_SMA, MA_EMA, MA_RMA, MA_WMA, MA_VWMA], group = G_BB)
float  bbSrc         = input.source(close, "Quelle / Source", group = G_BB)
float  bbMult        = input.float(2.0, "StdAbw-Multiplikator / StdDev multiplier", minval = 0.001, maxval = 50.0, step = 0.1, group = G_BB)
bool   showBbBasis   = input.bool(true, "Basis", inline = "bbB1", group = G_BB, active = showBB)
color  cBbBasis      = input.color(#FF0014, "Farbe / Color", inline = "bbB1", group = G_BB, active = showBB)
string bbBasisStyle  = input.string(LS_SOLID, "Basis: Stil / Basis: style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "bbB2", group = G_BB, active = showBB)
int    bbBasisWidth  = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "bbB2", group = G_BB, active = showBB)
bool   showBbUpper   = input.bool(true, "Oberes Band / Upper band", inline = "bbU1", group = G_BB, active = showBB)
color  cBbUpper      = input.color(#f23645, "Farbe / Color", inline = "bbU1", group = G_BB, active = showBB)
string bbUpperStyle  = input.string(LS_SOLID, "Oberes Band: Stil / Upper band: style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "bbU2", group = G_BB, active = showBB)
int    bbUpperWidth  = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "bbU2", group = G_BB, active = showBB)
bool   showBbLower   = input.bool(true, "Unteres Band / Lower band", inline = "bbL1", group = G_BB, active = showBB)
color  cBbLower      = input.color(#089981, "Farbe / Color", inline = "bbL1", group = G_BB, active = showBB)
string bbLowerStyle  = input.string(LS_SOLID, "Unteres Band: Stil / Lower band: style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "bbL2", group = G_BB, active = showBB)
int    bbLowerWidth  = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "bbL2", group = G_BB, active = showBB)
bool   bbFill        = input.bool(true, "Fläche zwischen den Bändern / Fill between bands", inline = "bbF", group = G_BB, active = showBB)
color  cBbFill       = input.color(color.new(#ffffff, 95), "Farbe / Color", inline = "bbF", group = G_BB, active = showBB)
bool   showBbLbl     = input.bool(true, "Band-Labels anzeigen / Show band labels", group = G_BB, tooltip = "Labels am rechten Chartrand. Mouseover zeigt eine kurze Erklärung in der gewählten Sprache.\nLabels at the right edge of the chart. Hover a label for a short explanation in the selected language.", active = showBB)
bool   bbLblPrice    = input.bool(true, "Preis im Label anzeigen / Show price in label", group = G_BB, active = showBB)
string bbLblShape    = input.string(SH_LABEL, "Label-Form / Label shape", options = [SH_LABEL, SH_TEXT], inline = "bbT1", group = G_BB, tooltip = "Nur Text: kein Hintergrund, der Text beginnt linksbündig am Ankerpunkt. Überlappende Labels ordnet der Kollisionsschutz aus Gruppe 22.\nText only: no background, text starts left-aligned at the anchor point. Overlapping labels are arranged by the collision guard in group 22.", active = showBB)
string bbLblSize     = input.string(SZ_NORMAL, "Größe / Size", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE, SZ_AUTO], inline = "bbT1", group = G_BB, active = showBB)
string bbLblFont     = input.string(FT_DEFAULT, "Schrift / Font", options = [FT_DEFAULT, FT_MONO], inline = "bbT2", group = G_BB, active = showBB)
int    bbLblOffset   = input.int(3, "Abstand (Kerzen) / Offset (bars)", minval = 0, maxval = 100, inline = "bbT2", group = G_BB, active = showBB)
bool   bbLblBandCol  = input.bool(true, "Text in Bandfarbe / Text in band color", inline = "bbT3", group = G_BB, tooltip = "AN: Jeder Labeltext nutzt die Farbe seines Bands. AUS: Es gilt die Textfarbe rechts.\nON: each label text uses the color of its band. OFF: the text color on the right is used.", active = showBB)
color  cBbLblTxt     = input.color(color.white, "Text", inline = "bbT3", group = G_BB, active = showBB)
color  cBbLblBg      = input.color(color.new(#131722, 20), "Hintergrund / Background", inline = "bbT3", group = G_BB, active = showBB)
bool   bbFilter      = input.bool(false, "FU-Filter: Sweep-Docht muss das Band durchstoßen / FU filter: sweep wick must pierce the band", group = G_BB, tooltip = "AN: Eine bullische FU / SFU / AFU gilt nur, wenn ihr Tief unter dem unteren Band liegt, eine bärische nur, wenn ihr Hoch über dem oberen Band liegt.\nON: a bullish FU / SFU / AFU is only valid if its low is below the lower band, a bearish one only if its high is above the upper band.")

string G_MTF = "🟩 MTF SMA │ 22 · Linien & Labels / Lines & labels"
float  mtfSrc        = input.source(close, "Quelle / Source", group = G_MTF, active = showMtf)
bool   mtfClosed     = input.bool(false, "Nur geschlossene Kerzen (kein Repaint) / Closed candles only (no repaint)", group = G_MTF, tooltip = "AUS: Die Linie folgt der noch offenen Kerze ihrer Zeitebene und kann sich bis zu deren Schluss bewegen. AN: Es gilt der Wert der letzten GESCHLOSSENEN Kerze der Zeitebene; Historie und Live-Anzeige sind identisch.\nOFF: the line follows the still open candle of its timeframe and can move until that candle closes. ON: the value of the last CLOSED candle of the timeframe is used; history and live display are identical.", active = showMtf)
bool   mtfHtfOnly    = input.bool(true, "Zeitebenen unter der Chart-Zeitebene ausblenden / Hide timeframes below the chart timeframe", group = G_MTF, tooltip = "AN: Ein Slot wird nur gezeichnet, wenn seine Zeitebene gleich oder höher als die Chart-Zeitebene ist (ein M5-SMA ergibt im H4-Chart wenig Sinn).\nON: a slot is only drawn when its timeframe is equal to or higher than the chart timeframe (an M5 SMA makes little sense on an H4 chart).", active = showMtf)
string mtfPlotStyle  = input.string(PS_LINE, "Linientyp / Line type", options = [PS_LINE, PS_STEP], group = G_MTF, tooltip = "Treppe zeigt deutlich, dass sich der Wert nur mit jeder Kerze der höheren Zeitebene ändert.\nStep line shows clearly that the value only changes with each candle of the higher timeframe.", active = showMtf)
bool   mtfEn1        = input.bool(true, "An / On", inline = "mtf1a", group = G_MTF, active = showMtf)
string mtfTf1        = input.timeframe("30", "Zeitebene 1 / Timeframe 1", inline = "mtf1a", group = G_MTF, active = showMtf)
int    mtfLen1       = input.int(9, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf1a", group = G_MTF, tooltip = "Zeitebenen-Dropdown = die Einträge des Zeitintervall-Menüs des Charts, einschließlich eigener Intervalle. Jährlich = 12 Monate.\nTimeframe dropdown = the entries of the chart's Time interval menu, including your own intervals. Yearly = 12 months.", active = showMtf)
color  cMtf1         = input.color(#3179f5, "Farbe 1 / Color 1", inline = "mtf1b", group = G_MTF, active = showMtf)
string mtfStyle1     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf1b", group = G_MTF, active = showMtf)
int    mtfWidth1     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf1b", group = G_MTF, active = showMtf)
bool   mtfEn2        = input.bool(true, "An / On", inline = "mtf2a", group = G_MTF, active = showMtf)
string mtfTf2        = input.timeframe("30", "Zeitebene 2 / Timeframe 2", inline = "mtf2a", group = G_MTF, active = showMtf)
int    mtfLen2       = input.int(20, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf2a", group = G_MTF, active = showMtf)
color  cMtf2         = input.color(#f7525f, "Farbe 2 / Color 2", inline = "mtf2b", group = G_MTF, active = showMtf)
string mtfStyle2     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf2b", group = G_MTF, active = showMtf)
int    mtfWidth2     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf2b", group = G_MTF, active = showMtf)
bool   mtfEn3        = input.bool(true, "An / On", inline = "mtf3a", group = G_MTF, active = showMtf)
string mtfTf3        = input.timeframe("60", "Zeitebene 3 / Timeframe 3", inline = "mtf3a", group = G_MTF, active = showMtf)
int    mtfLen3       = input.int(9, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf3a", group = G_MTF, active = showMtf)
color  cMtf3         = input.color(#5b9cf6, "Farbe 3 / Color 3", inline = "mtf3b", group = G_MTF, active = showMtf)
string mtfStyle3     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf3b", group = G_MTF, active = showMtf)
int    mtfWidth3     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf3b", group = G_MTF, active = showMtf)
bool   mtfEn4        = input.bool(true, "An / On", inline = "mtf4a", group = G_MTF, active = showMtf)
string mtfTf4        = input.timeframe("60", "Zeitebene 4 / Timeframe 4", inline = "mtf4a", group = G_MTF, active = showMtf)
int    mtfLen4       = input.int(20, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf4a", group = G_MTF, active = showMtf)
color  cMtf4         = input.color(#f77c80, "Farbe 4 / Color 4", inline = "mtf4b", group = G_MTF, active = showMtf)
string mtfStyle4     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf4b", group = G_MTF, active = showMtf)
int    mtfWidth4     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf4b", group = G_MTF, active = showMtf)
bool   mtfEn5        = input.bool(true, "An / On", inline = "mtf5a", group = G_MTF, active = showMtf)
string mtfTf5        = input.timeframe("60", "Zeitebene 5 / Timeframe 5", inline = "mtf5a", group = G_MTF, active = showMtf)
int    mtfLen5       = input.int(200, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf5a", group = G_MTF, active = showMtf)
color  cMtf5         = input.color(#b22833, "Farbe 5 / Color 5", inline = "mtf5b", group = G_MTF, active = showMtf)
string mtfStyle5     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf5b", group = G_MTF, active = showMtf)
int    mtfWidth5     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf5b", group = G_MTF, active = showMtf)
bool   mtfEn6        = input.bool(true, "An / On", inline = "mtf6a", group = G_MTF, active = showMtf)
string mtfTf6        = input.timeframe("240", "Zeitebene 6 / Timeframe 6", inline = "mtf6a", group = G_MTF, active = showMtf)
int    mtfLen6       = input.int(9, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf6a", group = G_MTF, active = showMtf)
color  cMtf6         = input.color(#90bff9, "Farbe 6 / Color 6", inline = "mtf6b", group = G_MTF, active = showMtf)
string mtfStyle6     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf6b", group = G_MTF, active = showMtf)
int    mtfWidth6     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf6b", group = G_MTF, active = showMtf)
bool   mtfEn7        = input.bool(true, "An / On", inline = "mtf7a", group = G_MTF, active = showMtf)
string mtfTf7        = input.timeframe("240", "Zeitebene 7 / Timeframe 7", inline = "mtf7a", group = G_MTF, active = showMtf)
int    mtfLen7       = input.int(20, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf7a", group = G_MTF, active = showMtf)
color  cMtf7         = input.color(#faa1a4, "Farbe 7 / Color 7", inline = "mtf7b", group = G_MTF, active = showMtf)
string mtfStyle7     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf7b", group = G_MTF, active = showMtf)
int    mtfWidth7     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf7b", group = G_MTF, active = showMtf)
bool   mtfEn8        = input.bool(true, "An / On", inline = "mtf8a", group = G_MTF, active = showMtf)
string mtfTf8        = input.timeframe("240", "Zeitebene 8 / Timeframe 8", inline = "mtf8a", group = G_MTF, active = showMtf)
int    mtfLen8       = input.int(200, "SMA-Länge / SMA length", minval = 1, maxval = 5000, inline = "mtf8a", group = G_MTF, active = showMtf)
color  cMtf8         = input.color(#ffffff, "Farbe 8 / Color 8", inline = "mtf8b", group = G_MTF, active = showMtf)
string mtfStyle8     = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtf8b", group = G_MTF, active = showMtf)
int    mtfWidth8     = input.int(1, "Breite / Width", minval = 1, maxval = 6, inline = "mtf8b", group = G_MTF, active = showMtf)
bool   showMtfLbl    = input.bool(true, "Linien-Labels anzeigen / Show line labels", group = G_MTF, tooltip = "Die Label-Einstellungen darunter (Preis, Form, Größe, Schrift, Abstand, Farben) gelten auch für die Labels der SMA-Linien 9/20 (Gruppe 3). Dezentes Label am rechten Rand, z. B. 'H4 · SMA 200', damit klar ist, dass die Linie nicht aus der Chart-Zeitebene stammt. Mouseover zeigt Details.\nThe label settings below (price, shape, size, font, offset, colors) also apply to the labels of the SMA 9/20 lines (group 3). Discreet label at the right edge, e.g. 'H4 · SMA 200', so it is clear that the line does not come from the chart timeframe. Hover the label for details.", active = showMtf)
bool   mtfLblPrice   = input.bool(true, "Preis im Label anzeigen / Show price in label", group = G_MTF)
string mtfLblShape   = input.string(SH_LABEL, "Label-Form / Label shape", options = [SH_LABEL, SH_TEXT], inline = "mtfT1", group = G_MTF, tooltip = "Etikett: Pille mit Hintergrund wie bei den Bollinger-Labels. Nur Text: kein Hintergrund, der Text beginnt linksbündig am Ankerpunkt.\nLabel: pill with background like the Bollinger Band labels. Text only: no background, text starts left-aligned at the anchor point.")
string mtfLblSize    = input.string(SZ_NORMAL, "Größe / Size", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE, SZ_AUTO], inline = "mtfT1", group = G_MTF)
string mtfLblFont    = input.string(FT_DEFAULT, "Schrift / Font", options = [FT_DEFAULT, FT_MONO], inline = "mtfT2", group = G_MTF)
int    mtfLblOffset  = input.int(3, "Label-Abstand zur letzten Kerze (Kerzen) / Label offset from last bar (bars)", minval = 0, maxval = 100, inline = "mtfT2", group = G_MTF, tooltip = "Horizontaler Abstand aller MTF-SMA-Labels zur letzten Kerze.\nHorizontal distance of all MTF SMA labels from the last candle.")
bool   mtfLblLineCol = input.bool(true, "Text in Linienfarbe / Text in line color", inline = "mtfT3", group = G_MTF)
color  cMtfLblTxt    = input.color(color.white, "Text", inline = "mtfT3", group = G_MTF)
color  cMtfLblBg     = input.color(color.new(#131722, 20), "Hintergrund / Background", inline = "mtfT3", group = G_MTF)
string mtfGuardMode  = input.string(CG_VERT, "Label-Kollisionsschutz (alle Labels am Rand) / Label collision guard (all edge labels)", options = [CG_VERT, CG_STEP, CG_OFF], group = G_MTF, tooltip = "Gilt für die Labels der MTF-SMA-Linien, der SMA-Linien 9/20 und der Bollinger-Bänder gemeinsam, auch wenn dieses Modul abgeschaltet ist. Ordnet die Labels automatisch an, wenn Linien dicht beieinander liegen. Vertikal spreizen: Labels werden gleichmäßig um ihre gemeinsame Mitte auseinandergeschoben; eine Verbindungslinie führt zum echten Preis der Linie. Nach rechts staffeln: Labels behalten ihren exakten Preis und rücken spaltenweise nach rechts.\nApplies to the labels of the MTF SMA lines, the SMA 9/20 lines and the Bollinger Bands together, also when this module is switched off. Arranges the labels automatically when lines lie close together. Spread vertically: labels are pushed apart evenly around their common centre; a connector line leads to the real price of each line. Stagger to the right: labels keep their exact price and step to the right column by column.")
float  mtfGuardPct   = input.float(5.0, "Min. Label-Abstand (% der Preisspanne) / Min. label distance (% of price range)", minval = 0.5, maxval = 50.0, step = 0.5, group = G_MTF, tooltip = "Zwei Labels, die näher liegen, gelten als Kollision. Wert erhöhen bei größerer Label-Schrift oder weit herausgezoomtem Chart.\nTwo labels closer than this are treated as colliding. Raise the value for larger label sizes or when zoomed far out.")
int    mtfGuardBars  = input.int(150, "Preisspanne: letzte n Kerzen / Price range: last n bars", minval = 20, maxval = 2000, group = G_MTF, tooltip = "Die Preisspanne ist die Hoch-Tief-Spanne der letzten n Kerzen, erweitert um die gezeigten MTF-SMA-Werte. n etwa auf die Zahl der Kerzen setzen, die üblicherweise im Bild sind.\nThe price range is the high-low range of the last n bars, extended by the shown MTF SMA values. Set n roughly to the number of bars you usually see on screen.")
int    mtfGuardCol   = input.int(12, "Staffeln: Spaltenabstand (Kerzen) / Staggering: column distance (bars)", minval = 1, maxval = 60, group = G_MTF, tooltip = "Nur im Modus 'Nach rechts staffeln': Abstand von einer Label-Spalte zur nächsten.\nMode 'Stagger to the right' only: distance from one label column to the next.")
int    mtfGuardExtra = input.int(0, "Zusatzabstand verschobener Labels (Kerzen) / Extra offset of moved labels (bars)", minval = 0, maxval = 100, group = G_MTF, tooltip = "Labels, die der Kollisionsschutz bewegt hat (gespreizt oder gestaffelt), rücken um so viele Kerzen weiter nach rechts. Gibt der Verbindungslinie mehr Platz. 0 = aus.\nLabels moved by the collision guard (spread or staggered) are placed this many bars further to the right. Gives the connector line more room. 0 = off.")
bool   mtfConnShow   = input.bool(true, "Verbindungslinie zum verschobenen Label / Connector line to moved label", inline = "mtfC", group = G_MTF)
string mtfConnStyle  = input.string(LS_DOTTED, "Stil / Style", options = [LS_SOLID, LS_DASHED, LS_DOTTED], inline = "mtfC", group = G_MTF)
int    mtfConnWidth  = input.int(1, "Breite / Width", minval = 1, maxval = 4, inline = "mtfC", group = G_MTF, tooltip = "Die Verbindungslinie nutzt die Farbe ihrer SMA-Linie.\nThe connector uses the color of its SMA line.")

string G_TINT = "🟦 DASHBOARD │ 23 · Hintergrund bei Gleichlauf / Alignment background"
color  cTintBull     = input.color(color.new(#089981, 90), "Alle Zeitebenen Bulle / All timeframes Bull", inline = "tint", group = G_TINT, active = bgTint)
color  cTintBear     = input.color(color.new(#F23645, 90), "Alle Zeitebenen Bär / All timeframes Bear", inline = "tint", group = G_TINT, tooltip = "Hintergrundfarbe, solange alle aktiven Dashboard-Zeitebenen in dieselbe Richtung zeigen. Deckkraft im Farbwähler einstellen. Ein/Aus: Schalter 'Hintergrund bei Gleichlauf' in Gruppe 0.\nBackground color while all active dashboard timeframes point the same way. Set the opacity in the color picker. On/off: switch 'Background on alignment' in group 0.", active = bgTint)

string G_PVP = "🟨 PVP │ 24 · Allgemein / General"
int    pvpPathBars   = input.int(2000, "Entwicklungspfade: letzte n Kerzen / Developing paths: last n bars", minval = 100, maxval = 20000, group = G_PVP, tooltip = "Die Entwicklungspfade für POC / VAH / VAL werden nur für die letzten n Chart-Kerzen gezeichnet. Abgeschlossene Profile und das laufende Profil auf der letzten Kerze werden immer berechnet.\nThe developing POC / VAH / VAL paths are drawn for the last n chart bars only. Completed profiles and the developing profile on the last bar are always calculated.", active = showPvp)
bool   pvpShowLbl    = input.bool(true, "Level-Labels (POC / VAH / VAL) / Level labels (POC / VAH / VAL)", group = G_PVP, tooltip = "Labels am rechten Rand, z. B. D1 POC oder D1 pVAH (p = vorheriges Profil). Sie nutzen das Label-Aussehen aus Gruppe 22 und nehmen am Kollisionsschutz teil.\nLabels at the right edge, e.g. D1 POC or D1 pVAH (p = previous profile). They use the label look of group 22 and take part in the collision guard.", active = showPvp)
bool   pvpLegOn      = input.bool(true, "Farblegende im Chart / Color legend on the chart", group = G_PVP, tooltip = "Kleine Tabelle, die zeigt, welche Linienfarbe für welchen Wert (POC / VAH / VAL) welches Profils steht, z. B. D1 = Tag, W1 = Woche, MN1 = Monat. Aufgeführt werden nur aktive Profile und eingeschaltete Linien.\nSmall table showing which line color stands for which level (POC / VAH / VAL) of which profile, e.g. D1 = day, W1 = week, MN1 = month. Only active profiles and switched-on lines are listed.", active = showPvp)
string pvpLegPos     = input.string(LP_TR, "Legende: Position / Legend: position", options = [LP_TL, LP_TC, LP_TR, LP_ML, LP_MC, LP_MR, LP_BL, LP_BC, LP_BR], group = G_PVP, tooltip = "Wähle eine andere Ecke als für die Dashboard-Tabelle, sonst überdecken sich beide.\nPick a different corner than the dashboard table, otherwise the two overlap.", active = showPvp)
string pvpLegLayout  = input.string(LL_VERT, "Legende: Anordnung / Legend: layout", options = [LL_VERT, LL_HOR], group = G_PVP, active = showPvp)
bool   pvpLegHdr     = input.bool(true, " Lines ]|Legende: Kopfzeile  [ PVP | Linien ] / Legend: header  [ PVP ", group = G_PVP, active = showPvp)
int    pvpLegPadT    = input.int(0, "Legende: Rand oben (Zeilen) / Legend: top margin (rows)", minval = 0, maxval = 10, group = G_PVP, tooltip = "Nur an oberen Positionen.\nTop positions only.", active = showPvp)
int    pvpLegPadB    = input.int(0, "Legende: Rand unten (Zeilen) / Legend: bottom margin (rows)", minval = 0, maxval = 10, group = G_PVP, tooltip = "Nur an unteren Positionen. Platz für das TradingView-Logo.\nBottom positions only. Room for the TradingView logo.", active = showPvp)
int    pvpLegPadL    = input.int(0, "Legende: Rand links (Spalten) / Legend: left margin (columns)", minval = 0, maxval = 10, group = G_PVP, active = showPvp)
int    pvpLegPadR    = input.int(0, "Legende: Rand rechts (Spalten) / Legend: right margin (columns)", minval = 0, maxval = 10, group = G_PVP, active = showPvp)
int    pvpLegGap     = input.int(2, "Legende: Pillenabstand (px) / Legend: pill gap (px)", minval = 0, maxval = 10, group = G_PVP, active = showPvp)
bool   pvpLegGridAuto = input.bool(true, "Legende: Gitter = Chart-Hintergrund / Legend: grid = chart background", group = G_PVP, tooltip = "An: Pillen wirken freistehend. Aus: eigene Gitterfarbe.\nOn: pills look detached. Off: custom grid color.", active = showPvp)
color  pvpLegGridCol = input.color(#131722, "Legende: Gitterfarbe / Legend: grid color", group = G_PVP, active = showPvp)
int    pvpLegFrameW  = input.int(0, "Legende: Rahmen (px) / Legend: frame (px)", minval = 0, maxval = 10, group = G_PVP, active = showPvp)
color  pvpLegFrameCol = input.color(#434651, "Legende: Rahmenfarbe / Legend: frame color", group = G_PVP, active = showPvp)
string pvpLegSizeTf  = input.string(SZ_NORMAL, "Legende: Größe Periode / Legend: size period", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE], group = G_PVP, active = showPvp)
string pvpLegSize    = input.string(SZ_NORMAL, "Legende: Größe Linienname / Legend: size line name", options = [SZ_TINY, SZ_SMALL, SZ_NORMAL, SZ_LARGE, SZ_HUGE], group = G_PVP, active = showPvp)
string pvpLegFont    = input.string(LF_DEF, "Legende: Schriftart / Legend: font", options = [LF_DEF, LF_MONO], group = G_PVP, active = showPvp)
color  pvpLegTfBg    = input.color(#2A2E39, "Legende: Perioden-Pille / Legend: period pill", inline = "pvpLg", group = G_PVP, active = showPvp)
color  pvpLegTfTxt   = input.color(#D1D4DC, "Schrift / Text", inline = "pvpLg", group = G_PVP, active = showPvp)
bool   pvpLegAutoTxt = input.bool(true, "Legende: Linien-Pille Schrift automatisch / Legend: line pill text automatic", group = G_PVP, tooltip = "Die Linien-Pillen haben die Linienfarbe als Hintergrund. An: Die Schrift ist schwarz oder weiß, je nachdem, was besser lesbar ist. Aus: die Schriftfarbe darunter.\nThe line pills use the line color as background. On: the text is black or white, whichever is easier to read. Off: the text color below.", active = showPvp)
color  pvpLegLvlTxt  = input.color(#FFFFFF, "Legende: Schrift der Linien-Pille / Legend: line pill text", group = G_PVP, active = showPvp)

string G_PVP1 = "🟨 PVP │ 25 · Profil 1 / Profile 1"
bool   pvpEn1        = input.bool(true, "Profil 1 aktivieren / Enable profile 1", group = G_PVP1, active = showPvp)
string pvpTf1        = input.timeframe("D", "Perioden-Zeitebene / Periodic timeframe", group = G_PVP1, tooltip = "Muss größer sein als die Chart-Zeitebene, sonst ist dieses Profil inaktiv.\nMust be higher than the chart timeframe, otherwise this profile is inactive.", active = showPvp and pvpEn1)
bool   pvpReg1       = input.bool(false, "Neustart bei regulärer Session / Reset on regular session", group = G_PVP1, tooltip = "Für Symbole mit erweiterten Handelszeiten.\nFor tickers with extended trading hours.", active = showPvp and pvpEn1)
bool   pvpHist1      = input.bool(false, "Abgeschlossene Profile anzeigen / Show completed profiles", group = G_PVP1, tooltip = "Vergangene Perioden: Volumenbalken, Value-Area-Linien und Bereichsfüllung (jeweils nur, wenn unten eingeschaltet).\nPast periods: volume rows, value area lines and range fill (each only if switched on below).", active = showPvp and pvpEn1)
bool   pvpDev1       = input.bool(true, "Laufendes Profil anzeigen / Show developing profile", group = G_PVP1, tooltip = "Aktuelle Periode: die unten eingeschalteten Linien (POC / VAH / VAL) und, falls aktiviert, Volumenbalken und Füllungen.\nCurrent period: the lines switched on below (POC / VAH / VAL) and, if enabled, volume rows and fills.", active = showPvp and pvpEn1)
bool   pvpPrev1      = input.bool(false, "Vorheriges POC, VAH, VAL anzeigen / Show previous POC, VAH, VAL", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpBars1      = input.bool(false, "Volumenbalken (Histogramm) anzeigen / Show volume rows (histogram)", group = G_PVP1, tooltip = "Aus: Es werden nur die Linien gezeichnet. An: die waagerechten Volumenbalken des laufenden und, falls aktiviert, der abgeschlossenen Profile.\nOff: only the lines are drawn. On: the horizontal volume rows of the developing and, if enabled, the completed profiles.", active = showPvp and pvpEn1)
float  pvpVaPct1     = input.float(68.0, "Value-Area-Volumen % / Value area volume %", minval = 1.0, maxval = 100.0, group = G_PVP1, active = showPvp and pvpEn1)
int    pvpRows1      = input.int(24, "Anzahl Zeilen / Number of rows", minval = 10, maxval = 100, group = G_PVP1, active = showPvp and pvpEn1)
string pvpPlc1       = input.string(PL_LEFT, "Platzierung / Placement", options = [PL_RIGHT, PL_LEFT, PL_NEXT], group = G_PVP1, active = showPvp and pvpEn1)
int    pvpWid1       = input.int(50, "Profilbreite % / Profile width %", minval = 0, maxval = 100, group = G_PVP1, active = showPvp and pvpEn1)
color  pvpColVA1     = input.color(color.new(color.orange, 50), "Zeilen: Value Area / Rows: value area", inline = "pvpR1", group = G_PVP1, active = showPvp and pvpEn1)
color  pvpColOut1    = input.color(color.new(color.gray, 50), "Außerhalb / Outside", inline = "pvpR1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpPoc1       = input.bool(true, "Point of Control (POC)", inline = "pvpP1", group = G_PVP1, active = showPvp and pvpEn1)
color  pvpPocCol1    = input.color(color.red, "Farbe / Color", inline = "pvpP1", group = G_PVP1, active = showPvp and pvpEn1)
int    pvpPocW1      = input.int(2, "Breite / Width", minval = 1, maxval = 5, inline = "pvpP1", group = G_PVP1, active = showPvp and pvpEn1)
string pvpPocExt1    = input.string(PX_NONE, "POC verlängern / Extend POC", options = [PX_LAST, PX_CROSS, PX_TOUCH, PX_NONE], group = G_PVP1, active = showPvp and pvpEn1)
int    pvpNaked1     = input.int(20, "Max. verfolgte offene POCs / Max. tracked naked POCs", minval = 1, maxval = 100, group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpVah1       = input.bool(false, "Value Area High (VAH)", inline = "pvpH1", group = G_PVP1, active = showPvp and pvpEn1)
color  pvpVahCol1    = input.color(color.blue, "Farbe / Color", inline = "pvpH1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpVal1       = input.bool(false, "Value Area Low (VAL)", inline = "pvpL1", group = G_PVP1, active = showPvp and pvpEn1)
color  pvpValCol1    = input.color(color.blue, "Farbe / Color", inline = "pvpL1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpVaBg1      = input.bool(false, "Value Area füllen / Fill value area", inline = "pvpA1", group = G_PVP1, active = showPvp and pvpEn1)
color  pvpVaBgCol1   = input.color(color.new(color.blue, 90), "Farbe / Color", inline = "pvpA1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpBg1        = input.bool(false, "Profilbereich füllen / Fill profile range", inline = "pvpB1", group = G_PVP1, active = showPvp and pvpEn1)
color  pvpBgCol1     = input.color(color.new(color.blue, 95), "Farbe / Color", inline = "pvpB1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpCross1     = input.bool(false, "POC-Kreuzungen markieren / Mark POC crosses", inline = "pvpC1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpTouch1     = input.bool(false, "POC-Berührungen markieren / Mark POC touches", inline = "pvpC1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpDpoc1      = input.bool(false, "Entwicklungspfad POC / Developing POC path", inline = "pvpDP1", group = G_PVP1, tooltip = "Farbe, Breite und Stil der drei Entwicklungspfade stellst du im Tab Stil ein (Plots PVP1 ...).\nColor, width and style of the three developing paths are set in the Style tab (plots PVP1 ...).", active = showPvp and pvpEn1)
bool   pvpDvah1      = input.bool(false, "Entwicklungspfad VAH / Developing VAH path", inline = "pvpDH1", group = G_PVP1, active = showPvp and pvpEn1)
bool   pvpDval1      = input.bool(false, "Entwicklungspfad VAL / Developing VAL path", inline = "pvpDL1", group = G_PVP1, active = showPvp and pvpEn1)

string G_PVP2 = "🟨 PVP │ 26 · Profil 2 / Profile 2"
bool   pvpEn2        = input.bool(true, "Profil 2 aktivieren / Enable profile 2", group = G_PVP2, active = showPvp)
string pvpTf2        = input.timeframe("W", "Perioden-Zeitebene / Periodic timeframe", group = G_PVP2, tooltip = "Muss größer sein als die Chart-Zeitebene, sonst ist dieses Profil inaktiv.\nMust be higher than the chart timeframe, otherwise this profile is inactive.", active = showPvp and pvpEn2)
bool   pvpReg2       = input.bool(false, "Neustart bei regulärer Session / Reset on regular session", group = G_PVP2, tooltip = "Für Symbole mit erweiterten Handelszeiten.\nFor tickers with extended trading hours.", active = showPvp and pvpEn2)
bool   pvpHist2      = input.bool(false, "Abgeschlossene Profile anzeigen / Show completed profiles", group = G_PVP2, tooltip = "Vergangene Perioden: Volumenbalken, Value-Area-Linien und Bereichsfüllung (jeweils nur, wenn unten eingeschaltet).\nPast periods: volume rows, value area lines and range fill (each only if switched on below).", active = showPvp and pvpEn2)
bool   pvpDev2       = input.bool(true, "Laufendes Profil anzeigen / Show developing profile", group = G_PVP2, tooltip = "Aktuelle Periode: die unten eingeschalteten Linien (POC / VAH / VAL) und, falls aktiviert, Volumenbalken und Füllungen.\nCurrent period: the lines switched on below (POC / VAH / VAL) and, if enabled, volume rows and fills.", active = showPvp and pvpEn2)
bool   pvpPrev2      = input.bool(false, "Vorheriges POC, VAH, VAL anzeigen / Show previous POC, VAH, VAL", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpBars2      = input.bool(false, "Volumenbalken (Histogramm) anzeigen / Show volume rows (histogram)", group = G_PVP2, tooltip = "Aus: Es werden nur die Linien gezeichnet. An: die waagerechten Volumenbalken des laufenden und, falls aktiviert, der abgeschlossenen Profile.\nOff: only the lines are drawn. On: the horizontal volume rows of the developing and, if enabled, the completed profiles.", active = showPvp and pvpEn2)
float  pvpVaPct2     = input.float(68.0, "Value-Area-Volumen % / Value area volume %", minval = 1.0, maxval = 100.0, group = G_PVP2, active = showPvp and pvpEn2)
int    pvpRows2      = input.int(24, "Anzahl Zeilen / Number of rows", minval = 10, maxval = 100, group = G_PVP2, active = showPvp and pvpEn2)
string pvpPlc2       = input.string(PL_RIGHT, "Platzierung / Placement", options = [PL_RIGHT, PL_LEFT, PL_NEXT], group = G_PVP2, active = showPvp and pvpEn2)
int    pvpWid2       = input.int(30, "Profilbreite % / Profile width %", minval = 0, maxval = 100, group = G_PVP2, active = showPvp and pvpEn2)
color  pvpColVA2     = input.color(color.new(color.teal, 50), "Zeilen: Value Area / Rows: value area", inline = "pvpR2", group = G_PVP2, active = showPvp and pvpEn2)
color  pvpColOut2    = input.color(color.new(color.gray, 60), "Außerhalb / Outside", inline = "pvpR2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpPoc2       = input.bool(true, "Point of Control (POC)", inline = "pvpP2", group = G_PVP2, active = showPvp and pvpEn2)
color  pvpPocCol2    = input.color(color.fuchsia, "Farbe / Color", inline = "pvpP2", group = G_PVP2, active = showPvp and pvpEn2)
int    pvpPocW2      = input.int(2, "Breite / Width", minval = 1, maxval = 5, inline = "pvpP2", group = G_PVP2, active = showPvp and pvpEn2)
string pvpPocExt2    = input.string(PX_NONE, "POC verlängern / Extend POC", options = [PX_LAST, PX_CROSS, PX_TOUCH, PX_NONE], group = G_PVP2, active = showPvp and pvpEn2)
int    pvpNaked2     = input.int(20, "Max. verfolgte offene POCs / Max. tracked naked POCs", minval = 1, maxval = 100, group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpVah2       = input.bool(false, "Value Area High (VAH)", inline = "pvpH2", group = G_PVP2, active = showPvp and pvpEn2)
color  pvpVahCol2    = input.color(color.teal, "Farbe / Color", inline = "pvpH2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpVal2       = input.bool(false, "Value Area Low (VAL)", inline = "pvpL2", group = G_PVP2, active = showPvp and pvpEn2)
color  pvpValCol2    = input.color(color.teal, "Farbe / Color", inline = "pvpL2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpVaBg2      = input.bool(false, "Value Area füllen / Fill value area", inline = "pvpA2", group = G_PVP2, active = showPvp and pvpEn2)
color  pvpVaBgCol2   = input.color(color.new(color.teal, 92), "Farbe / Color", inline = "pvpA2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpBg2        = input.bool(false, "Profilbereich füllen / Fill profile range", inline = "pvpB2", group = G_PVP2, active = showPvp and pvpEn2)
color  pvpBgCol2     = input.color(color.new(color.teal, 96), "Farbe / Color", inline = "pvpB2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpCross2     = input.bool(false, "POC-Kreuzungen markieren / Mark POC crosses", inline = "pvpC2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpTouch2     = input.bool(false, "POC-Berührungen markieren / Mark POC touches", inline = "pvpC2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpDpoc2      = input.bool(false, "Entwicklungspfad POC / Developing POC path", inline = "pvpDP2", group = G_PVP2, tooltip = "Farbe, Breite und Stil der drei Entwicklungspfade stellst du im Tab Stil ein (Plots PVP2 ...).\nColor, width and style of the three developing paths are set in the Style tab (plots PVP2 ...).", active = showPvp and pvpEn2)
bool   pvpDvah2      = input.bool(false, "Entwicklungspfad VAH / Developing VAH path", inline = "pvpDH2", group = G_PVP2, active = showPvp and pvpEn2)
bool   pvpDval2      = input.bool(false, "Entwicklungspfad VAL / Developing VAL path", inline = "pvpDL2", group = G_PVP2, active = showPvp and pvpEn2)

string G_PVP3 = "🟨 PVP │ 27 · Profil 3 / Profile 3"
bool   pvpEn3        = input.bool(true, "Profil 3 aktivieren / Enable profile 3", group = G_PVP3, active = showPvp)
string pvpTf3        = input.timeframe("M", "Perioden-Zeitebene / Periodic timeframe", group = G_PVP3, tooltip = "Muss größer sein als die Chart-Zeitebene, sonst ist dieses Profil inaktiv.\nMust be higher than the chart timeframe, otherwise this profile is inactive.", active = showPvp and pvpEn3)
bool   pvpReg3       = input.bool(false, "Neustart bei regulärer Session / Reset on regular session", group = G_PVP3, tooltip = "Für Symbole mit erweiterten Handelszeiten.\nFor tickers with extended trading hours.", active = showPvp and pvpEn3)
bool   pvpHist3      = input.bool(false, "Abgeschlossene Profile anzeigen / Show completed profiles", group = G_PVP3, tooltip = "Vergangene Perioden: Volumenbalken, Value-Area-Linien und Bereichsfüllung (jeweils nur, wenn unten eingeschaltet).\nPast periods: volume rows, value area lines and range fill (each only if switched on below).", active = showPvp and pvpEn3)
bool   pvpDev3       = input.bool(true, "Laufendes Profil anzeigen / Show developing profile", group = G_PVP3, tooltip = "Aktuelle Periode: die unten eingeschalteten Linien (POC / VAH / VAL) und, falls aktiviert, Volumenbalken und Füllungen.\nCurrent period: the lines switched on below (POC / VAH / VAL) and, if enabled, volume rows and fills.", active = showPvp and pvpEn3)
bool   pvpPrev3      = input.bool(false, "Vorheriges POC, VAH, VAL anzeigen / Show previous POC, VAH, VAL", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpBars3      = input.bool(false, "Volumenbalken (Histogramm) anzeigen / Show volume rows (histogram)", group = G_PVP3, tooltip = "Aus: Es werden nur die Linien gezeichnet. An: die waagerechten Volumenbalken des laufenden und, falls aktiviert, der abgeschlossenen Profile.\nOff: only the lines are drawn. On: the horizontal volume rows of the developing and, if enabled, the completed profiles.", active = showPvp and pvpEn3)
float  pvpVaPct3     = input.float(68.0, "Value-Area-Volumen % / Value area volume %", minval = 1.0, maxval = 100.0, group = G_PVP3, active = showPvp and pvpEn3)
int    pvpRows3      = input.int(24, "Anzahl Zeilen / Number of rows", minval = 10, maxval = 100, group = G_PVP3, active = showPvp and pvpEn3)
string pvpPlc3       = input.string(PL_RIGHT, "Platzierung / Placement", options = [PL_RIGHT, PL_LEFT, PL_NEXT], group = G_PVP3, active = showPvp and pvpEn3)
int    pvpWid3       = input.int(20, "Profilbreite % / Profile width %", minval = 0, maxval = 100, group = G_PVP3, active = showPvp and pvpEn3)
color  pvpColVA3     = input.color(color.new(color.green, 55), "Zeilen: Value Area / Rows: value area", inline = "pvpR3", group = G_PVP3, active = showPvp and pvpEn3)
color  pvpColOut3    = input.color(color.new(color.gray, 70), "Außerhalb / Outside", inline = "pvpR3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpPoc3       = input.bool(true, "Point of Control (POC)", inline = "pvpP3", group = G_PVP3, active = showPvp and pvpEn3)
color  pvpPocCol3    = input.color(color.lime, "Farbe / Color", inline = "pvpP3", group = G_PVP3, active = showPvp and pvpEn3)
int    pvpPocW3      = input.int(2, "Breite / Width", minval = 1, maxval = 5, inline = "pvpP3", group = G_PVP3, active = showPvp and pvpEn3)
string pvpPocExt3    = input.string(PX_NONE, "POC verlängern / Extend POC", options = [PX_LAST, PX_CROSS, PX_TOUCH, PX_NONE], group = G_PVP3, active = showPvp and pvpEn3)
int    pvpNaked3     = input.int(20, "Max. verfolgte offene POCs / Max. tracked naked POCs", minval = 1, maxval = 100, group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpVah3       = input.bool(false, "Value Area High (VAH)", inline = "pvpH3", group = G_PVP3, active = showPvp and pvpEn3)
color  pvpVahCol3    = input.color(color.olive, "Farbe / Color", inline = "pvpH3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpVal3       = input.bool(false, "Value Area Low (VAL)", inline = "pvpL3", group = G_PVP3, active = showPvp and pvpEn3)
color  pvpValCol3    = input.color(color.olive, "Farbe / Color", inline = "pvpL3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpVaBg3      = input.bool(false, "Value Area füllen / Fill value area", inline = "pvpA3", group = G_PVP3, active = showPvp and pvpEn3)
color  pvpVaBgCol3   = input.color(color.new(color.olive, 92), "Farbe / Color", inline = "pvpA3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpBg3        = input.bool(false, "Profilbereich füllen / Fill profile range", inline = "pvpB3", group = G_PVP3, active = showPvp and pvpEn3)
color  pvpBgCol3     = input.color(color.new(color.olive, 96), "Farbe / Color", inline = "pvpB3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpCross3     = input.bool(false, "POC-Kreuzungen markieren / Mark POC crosses", inline = "pvpC3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpTouch3     = input.bool(false, "POC-Berührungen markieren / Mark POC touches", inline = "pvpC3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpDpoc3      = input.bool(false, "Entwicklungspfad POC / Developing POC path", inline = "pvpDP3", group = G_PVP3, tooltip = "Farbe, Breite und Stil der drei Entwicklungspfade stellst du im Tab Stil ein (Plots PVP3 ...).\nColor, width and style of the three developing paths are set in the Style tab (plots PVP3 ...).", active = showPvp and pvpEn3)
bool   pvpDvah3      = input.bool(false, "Entwicklungspfad VAH / Developing VAH path", inline = "pvpDH3", group = G_PVP3, active = showPvp and pvpEn3)
bool   pvpDval3      = input.bool(false, "Entwicklungspfad VAL / Developing VAL path", inline = "pvpDL3", group = G_PVP3, active = showPvp and pvpEn3)

// ───────────────────────────────────────────────────────────────────────────
//  Dictionary: [ Bull, Bear, header label ] per language
// ───────────────────────────────────────────────────────────────────────────
[txtBullInp, txtBearInp, txtTfInp] = switch langInp
    "English" => ["Bull",  "Bear", "TF"]
    "Deutsch" => ["Bulle", "Bär",  "TF"]
    => [cusBull, cusBear, cusTf]

// ───────────────────────────────────────────────────────────────────────────
//  A2) Dashboard: calculation
// ───────────────────────────────────────────────────────────────────────────
// State on the current candle:
//   +1 = Bull (fast SMA > slow SMA)
//   -1 = Bear (fast SMA < slow SMA)
//    0 = neutral (equal) or not enough data yet
f_state() =>
    float fast = ta.sma(src, fastLen)
    float slow = ta.sma(src, slowLen)
    na(fast) or na(slow) ? 0 : fast > slow ? 1 : fast < slow ? -1 : 0

// Request the state of one timeframe (see the repainting notes in the header)
f_mtfState(simple string tf) =>
    int closed = request.security(syminfo.tickerid, tf, f_state()[1], lookahead = barmerge.lookahead_on)
    int live   = request.security(syminfo.tickerid, tf, f_state(),    lookahead = barmerge.lookahead_off)
    liveMode ? live : closed

// Turn a timeframe string into a short label: "D" -> D1, "240" -> H4, "30" -> M30 ...
f_tfLabel(simple string tf) =>
    int sec = timeframe.in_seconds(tf)
    string lbl = switch
        str.endswith(tf, "M")    => "MN" + str.tostring(int(sec / 2628003))
        sec % 604800 == 0        => "W"  + str.tostring(int(sec / 604800))
        sec % 86400  == 0        => "D"  + str.tostring(int(sec / 86400))
        sec % 3600   == 0        => "H"  + str.tostring(int(sec / 3600))
        sec % 60     == 0        => "M"  + str.tostring(int(sec / 60))
        => "S" + str.tostring(sec)
    lbl

// Evaluate all seven timeframes on every bar (request.security must be
// called on every bar, hence outside of barstate.islast)
int s1 = f_mtfState(tf1)
int s2 = f_mtfState(tf2)
int s3 = f_mtfState(tf3)
int s4 = f_mtfState(tf4)
int s5 = f_mtfState(tf5)
int s6 = f_mtfState(tf6)
int s7 = f_mtfState(tf7)

// Counters over the ACTIVE timeframes
f_cnt(bool en, int st, int want) => en and st == want ? 1 : 0
int nActive = (en1 ? 1 : 0) + (en2 ? 1 : 0) + (en3 ? 1 : 0) + (en4 ? 1 : 0) + (en5 ? 1 : 0) + (en6 ? 1 : 0) + (en7 ? 1 : 0)
int nBull   = f_cnt(en1, s1, 1) + f_cnt(en2, s2, 1) + f_cnt(en3, s3, 1) + f_cnt(en4, s4, 1) + f_cnt(en5, s5, 1) + f_cnt(en6, s6, 1) + f_cnt(en7, s7, 1)
int nBear   = f_cnt(en1, s1, -1) + f_cnt(en2, s2, -1) + f_cnt(en3, s3, -1) + f_cnt(en4, s4, -1) + f_cnt(en5, s5, -1) + f_cnt(en6, s6, -1) + f_cnt(en7, s7, -1)
bool allBull = nActive > 0 and nBull == nActive
bool allBear = nActive > 0 and nBear == nActive

// SMA lines of the chart timeframe (only when switched on)
float smaFast = ta.sma(src, fastLen)
float smaSlow = ta.sma(src, slowLen)
plot(showSma ? smaFast : na, "SMA schnell / fast", color = smaFastCol, linewidth = 1)
plot(showSma ? smaSlow : na, "SMA langsam / slow", color = smaSlowCol, linewidth = 1)

// Background tint on alignment
bgcolor(bgTint and allBull ? cTintBull : bgTint and allBear ? cTintBear : na)

// ───────────────────────────────────────────────────────────────────────────
//  A3) Dashboard (table)
// ───────────────────────────────────────────────────────────────────────────
// Input text -> Pine constants (the position strings start with the German word)
string tblPos = switch
    str.startswith(posInp, "Oben links")   => position.top_left
    str.startswith(posInp, "Oben mitte")   => position.top_center
    str.startswith(posInp, "Oben rechts")  => position.top_right
    str.startswith(posInp, "Mitte links")  => position.middle_left
    str.startswith(posInp, "Mitte rechts") => position.middle_right
    str.startswith(posInp, "Mitte")        => position.middle_center
    str.startswith(posInp, "Unten links")  => position.bottom_left
    str.startswith(posInp, "Unten mitte")  => position.bottom_center
    => position.bottom_right

f_dashSize(string s) =>
    switch
        str.startswith(s, "Winzig") => size.tiny
        str.startswith(s, "Klein")  => size.small
        str.startswith(s, "Groß")   => size.large
        str.startswith(s, "Riesig") => size.huge
        => size.normal

string sizeTf    = f_dashSize(sizeTfInp)
string sizeState = f_dashSize(sizeStateInp)
string fontFam   = fontInp == "Monospace" ? font.family_monospace : font.family_default
bool   vertical  = str.startswith(layoutInp, "Vertikal")

// Apply margins only at the edge where the table actually sits
bool atTop    = str.startswith(posInp, "Oben")
bool atBottom = str.startswith(posInp, "Unten")
bool atLeft   = str.contains(posInp, "links")
bool atRight  = str.contains(posInp, "rechts")
int  padT = atTop    ? padTop    : 0
int  padB = atBottom ? padBottom : 0
int  padL = atLeft   ? padLeft   : 0
int  padR = atRight  ? padRight  : 0

// Maximum table size: up to 9 pairs (header + 7 TF + summary) of 2 cells each
int cellsPerPair = compactMode ? 1 : 2
int maxPairs     = 9
int maxCols      = (vertical ? cellsPerPair : maxPairs * cellsPerPair) + padL + padR
int maxRows      = (vertical ? maxPairs     : 1) + padT + padB

// Create the table once. The grid (border) between the cells creates the
// gap; in the chart background color the cells look like detached pills,
// in a color of their own like a classic grid.
color gridColor = gridAuto ? chart.bg_color : gridCol
var table dash = table.new(tblPos, maxCols, maxRows, bgcolor      = color.new(color.black, 100), frame_width  = frameW, frame_color  = frameCol, border_width = gapPx, border_color = gridColor)

color transparent = color.new(color.black, 100)

// Invisible spacer cell (height / width comes from the blank text)
f_spacer(int col, int row, string txt) =>
    table.cell(dash, col, row, txt, bgcolor = transparent, text_size = sizeState)

// Visible cell
f_cell(int col, int row, string txt, color bg, color fg, string sz) =>
    table.cell(dash, col, row, txt, text_color       = fg, bgcolor          = bg, text_size        = sz, text_font_family = fontFam, text_halign      = text.align_center, text_valign      = text.align_center)

// Draw one pill pair. idx = position in the list (0-based).
// kind:  0 = timeframe (st = state)   1 = header   2 = summary
f_pill(int idx, int kind, string lbl, int st) =>
    string txt = ""
    color  bg  = tfBg
    color  fg  = tfTxt
    if kind == 1
        txt := "SMA " + str.tostring(fastLen) + "/" + str.tostring(slowLen)
    else if kind == 2
        bool bullish = nBull > nBear
        bool bearish = nBear > nBull
        int    n    = bullish ? nBull : bearish ? nBear : nBull
        string word = bullish ? txtBullInp : bearish ? txtBearInp : txtNeutInp
        txt := str.tostring(n) + "/" + str.tostring(nActive) + " " + word
        bg  := bullish ? bullBg  : bearish ? bearBg  : neutBg
        fg  := bullish ? bullTxt : bearish ? bearTxt : neutTxt
    else
        txt := st > 0 ? txtBullInp : st < 0 ? txtBearInp : txtNeutInp
        bg  := st > 0 ? bullBg  : st < 0 ? bearBg  : neutBg
        fg  := st > 0 ? bullTxt : st < 0 ? bearTxt : neutTxt
    int c = padL + (vertical ? 0   : idx * cellsPerPair)
    int r = padT + (vertical ? idx : 0)
    if compactMode
        f_cell(c, r, "  " + lbl + "  " + txt + "  ", bg, fg, sizeState)
    else
        f_cell(c,     r, "  " + lbl + "  ", tfBg, tfTxt, sizeTf)
        f_cell(c + 1, r, "  " + txt + "  ", bg,   fg,    sizeState)

// Append one pair to the display list
f_add(string[] lbls, int[] kinds, int[] sts, string lbl, int kind, int st) =>
    array.push(lbls, lbl)
    array.push(kinds, kind)
    array.push(sts, st)

// Draw on the last bar only - saves calculation time, the values come from
// the series calculated on every bar above.
if showDash and barstate.islast
    // Build the list of pairs to show
    string[] lbls  = array.new<string>()
    int[]    kinds = array.new<int>()
    int[]    sts   = array.new<int>()
    if showHeader
        f_add(lbls, kinds, sts, txtTfInp, 1, 0)
    if en1
        f_add(lbls, kinds, sts, f_tfLabel(tf1), 0, s1)
    if en2
        f_add(lbls, kinds, sts, f_tfLabel(tf2), 0, s2)
    if en3
        f_add(lbls, kinds, sts, f_tfLabel(tf3), 0, s3)
    if en4
        f_add(lbls, kinds, sts, f_tfLabel(tf4), 0, s4)
    if en5
        f_add(lbls, kinds, sts, f_tfLabel(tf5), 0, s5)
    if en6
        f_add(lbls, kinds, sts, f_tfLabel(tf6), 0, s6)
    if en7
        f_add(lbls, kinds, sts, f_tfLabel(tf7), 0, s7)
    if showSummary
        f_add(lbls, kinds, sts, txtSumInp, 2, 0)
    int pairs = array.size(lbls)

    // Area actually used (for the position of the margins)
    int usedCols = vertical ? cellsPerPair : pairs * cellsPerPair
    int usedRows = vertical ? pairs        : 1

    // Margins (rows top / bottom, columns left / right)
    if padT > 0
        for r = 0 to padT - 1
            f_spacer(padL, r, " ")
    if padB > 0
        for r = 0 to padB - 1
            f_spacer(padL, padT + usedRows + r, " ")
    if padL > 0
        for c = 0 to padL - 1
            f_spacer(c, padT, "      ")
    if padR > 0
        for c = 0 to padR - 1
            f_spacer(padL + usedCols + c, padT, "      ")

    // Pills
    if pairs > 0
        for i = 0 to pairs - 1
            f_pill(i, array.get(kinds, i), array.get(lbls, i), array.get(sts, i))

// ───────────────────────────────────────────────────────────────────────────
//  A4) Dashboard alerts (all active timeframes aligned)
// ───────────────────────────────────────────────────────────────────────────
alertcondition(alertsOn and allBull and not allBull[1], "Alle Zeitebenen Bulle / All timeframes Bull", "MTF SMA: alle aktiven Zeitebenen Bulle / all active timeframes Bull")
alertcondition(alertsOn and allBear and not allBear[1], "Alle Zeitebenen Bär / All timeframes Bear",   "MTF SMA: alle aktiven Zeitebenen Bär / all active timeframes Bear")

// =============================================================================
// === SHARED SERIES (computed once, on every bar) =============================
// =============================================================================
float atr         = ta.atr(atrLen)
float ma          = ta.sma(close, maLen)

// Bollinger Bands: basis = moving average, bands = basis +/- mult x stdev
f_ma(float maSrc, simple int len, string maType) =>
    switch maType
        MA_EMA  => ta.ema(maSrc, len)
        MA_RMA  => ta.rma(maSrc, len)
        MA_WMA  => ta.wma(maSrc, len)
        MA_VWMA => ta.vwma(maSrc, len)
        => ta.sma(maSrc, len)

float bbBasis     = f_ma(bbSrc, bbLen, bbMaType)
float bbDev       = bbMult * ta.stdev(bbSrc, bbLen)
float bbUpper     = bbBasis + bbDev
float bbLower     = bbBasis - bbDev
// Previous candle (the candle whose liquidity is swept)
float prevHigh    = high[1]
float prevLow     = low[1]
float prevBodyTop = math.max(open[1], close[1])
float prevBodyBot = math.min(open[1], close[1])
int   prevTime    = time[1]
// Swing liquidity BEFORE the current bar (shifted by one bar, so the current
// candle can actually exceed it).
float lowestLo    = ta.lowest(low, swingLen)
float highestHi   = ta.highest(high, swingLen)
float swingLow    = lowestLo[1]
float swingHigh   = highestHi[1]

// =============================================================================
// === STYLE HELPERS ===========================================================
// =============================================================================
f_size(string s) =>
    switch s
        SZ_TINY   => size.tiny
        SZ_SMALL  => size.small
        SZ_NORMAL => size.normal
        SZ_LARGE  => size.large
        SZ_HUGE   => size.huge
        => size.auto

// Label shape; direction-dependent shapes point at the candle.
f_shape(string s, bool isBull) =>
    switch s
        SH_LABEL   => isBull ? label.style_label_up : label.style_label_down
        SH_TRI     => isBull ? label.style_triangleup : label.style_triangledown
        SH_ARROW   => isBull ? label.style_arrowup : label.style_arrowdown
        SH_CIRCLE  => label.style_circle
        SH_DIAMOND => label.style_diamond
        SH_SQUARE  => label.style_square
        SH_FLAG    => label.style_flag
        SH_CROSS   => label.style_cross
        SH_XCROSS  => label.style_xcross
        => label.style_none

f_lineStyle(string s) =>
    s == LS_DASHED ? line.style_dashed : s == LS_DOTTED ? line.style_dotted : line.style_solid

// Per-tier style lookups (tier: 3 = SFU, 2 = FU, 1 = AFU)
f_lblColor(int tier, bool isBull) =>
    color c = isBull ? cLblBullAFU : cLblBearAFU
    if tier == 3
        c := isBull ? cLblBullSFU : cLblBearSFU
    else if tier == 2
        c := isBull ? cLblBullFU : cLblBearFU
    c

f_barColor(int tier, bool isBull) =>
    color c = isBull ? cBarBullAFU : cBarBearAFU
    if tier == 3
        c := isBull ? cBarBullSFU : cBarBearSFU
    else if tier == 2
        c := isBull ? cBarBullFU : cBarBearFU
    c

f_txtColor(int tier) =>
    tier == 3 ? cTxtSFU : tier == 2 ? cTxtFU : cTxtAFU

f_shapeSel(int tier) =>
    tier == 3 ? shpSFU : tier == 2 ? shpFU : shpAFU

f_sizeSel(int tier) =>
    tier == 3 ? szSFU : tier == 2 ? szFU : szAFU

// =============================================================================
// === CORE LOGIC ==============================================================
// =============================================================================
// f_fuTier(dir) -> 0 = none, 1 = AFU, 2 = FU, 3 = SFU
//   dir =  1 : bullish (sell-side liquidity below the previous LOW is swept)
//   dir = -1 : bearish (buy-side liquidity above the previous HIGH is swept)
f_fuTier(int dir) =>
    bool  isBull       = dir == 1

    // --- Candle anatomy ------------------------------------------------------
    float rng          = high - low
    float body         = math.abs(close - open)

    // --- 1) Liquidity sweep: the wick exceeds the previous candle's extreme --
    float sweepDepth   = isBull ? prevLow - low : high - prevHigh
    float sweepWick    = isBull ? math.min(open, close) - low : high - math.max(open, close)
    bool  isSweep      = sweepDepth > 0 and sweepDepth >= minSweepAtr * atr

    // --- 2) Reclaim: where does the candle close relative to the previous one?
    bool  reclaimBody  = isBull ? close > prevBodyTop : close < prevBodyBot
    bool  reclaimRange = isBull ? close > prevHigh : close < prevLow

    // --- 3) Quality filters --------------------------------------------------
    float closeDist    = isBull ? close - low : high - close
    float closeLoc     = rng > 0 ? closeDist / rng * 100.0 : 0.0
    bool  qRange       = rng >= minRangeAtr * atr
    bool  qBody        = rng > 0 and body / rng * 100.0 >= minBodyPct
    bool  qWick        = sweepWick >= minWickBody * body
    bool  qLoc         = closeLoc >= minCloseLoc
    bool  qDir         = not requireDir or (isBull ? close > open : close < open)

    // --- 4) Trend filter -----------------------------------------------------
    bool  withTrend    = isBull ? close > ma : close < ma
    bool  counter      = isBull ? close < ma : close > ma
    bool  trendOk      = trendMode == TM_OFF or (trendMode == TM_WITH and withTrend) or (trendMode == TM_COUNTER and counter)

    // --- 5) Bollinger filter (optional): the sweep wick pierces the band -----
    bool  bbOk         = not bbFilter or (isBull ? low < bbLower : high > bbUpper)

    bool  base         = isSweep and qRange and qBody and qWick and qLoc and qDir and trendOk and bbOk

    // --- 6) SFU extras -------------------------------------------------------
    bool  swingSweep   = isBull ? low < swingLow : high > swingHigh
    bool  sfuSwingOk   = not sfuNeedSwing or swingSweep
    bool  sfuDispOk    = not sfuNeedDisp or rng >= dispMult * atr

    // --- Tier assignment (highest matching tier wins) ------------------------
    int tier = 0
    if base and reclaimBody
        tier := 1
    if base and reclaimRange
        tier := 2
    if tier == 2 and sfuSwingOk and sfuDispOk
        tier := 3
    tier

// Maps a detected tier to the tier that is actually displayed, depending on
// the Show-switches (a hidden SFU falls back to FU).
f_visibleTier(int t) =>
    int v = t
    if v == 3 and not showSFU
        v := 2
    if v == 2 and not showFU
        v := 0
    if v == 1 and not showAFU
        v := 0
    v

// Both calls run on every bar (keeps the internal history consistent).
int  bullRaw   = f_fuTier(1)
int  bearRaw   = f_fuTier(-1)
bool confirmed = not confirmClose or barstate.isconfirmed

// showFuMod = module switch (group 2): off removes labels, candle colors,
// FVG boxes, levels and FU alerts in one step.
// A candle can never be bullish and bearish at once: bullish needs a close
// above the previous body, bearish a close below it.
int bullTier = confirmed and showFuMod ? f_visibleTier(bullRaw) : 0
int bearTier = confirmed and showFuMod ? f_visibleTier(bearRaw) : 0

bool bullSFU = bullTier == 3
bool bullFU  = bullTier == 2
bool bullAFU = bullTier == 1
bool bearSFU = bearTier == 3
bool bearFU  = bearTier == 2
bool bearAFU = bearTier == 1
bool anyBull = bullTier > 0
bool anyBear = bearTier > 0

// =============================================================================
// === LABELS WITH MOUSE-OVER TOOLTIP ==========================================
// =============================================================================
// Builds the tooltip in the selected language:
//   headline, definition of the candle type, then the facts of THIS candle
//   (swept candle, start = open, sweep extreme, end = close, reclaimed level).
f_tip(int tier, bool isBull) =>
    bool   de       = langInp == "Deutsch"
    string nl       = "\n"
    // Direction-dependent words
    string sExt     = isBull ? (de ? "Tief" : "low") : (de ? "Hoch" : "high")
    string sExtCap  = isBull ? (de ? "Tief" : "Low") : (de ? "Hoch" : "High")
    string sOpp     = isBull ? (de ? "Hoch" : "high") : (de ? "Tief" : "low")
    string sSide    = isBull ? (de ? "über" : "above") : (de ? "unter" : "below")
    string sLiq     = isBull ? (de ? "Sell-Side-Liquidität" : "sell-side liquidity") : (de ? "Buy-Side-Liquidität" : "buy-side liquidity")
    string sDir     = isBull ? (de ? "Bullische" : "Bullish") : (de ? "Bärische" : "Bearish")
    // Direction-dependent prices
    float  ext      = isBull ? low : high
    float  prevExt  = isBull ? prevLow : prevHigh
    float  prevOpp  = isBull ? prevHigh : prevLow
    float  prevBody = isBull ? prevBodyTop : prevBodyBot
    float  swingLv  = isBull ? swingLow : swingHigh
    float  depth    = math.abs(prevExt - ext)
    float  travel   = math.abs(close - ext)
    string tfmt     = de ? "dd.MM.yyyy HH:mm" : "yyyy-MM-dd HH:mm"

    // --- Headline + definition -----------------------------------------------
    string head = ""
    string defn = ""
    if tier == 1
        head := sDir + " AFU (Attempted FU)"
        if de
            defn := "Versuchte FU: Der Docht nimmt das " + sExt + " der Vorkerze heraus (" + sLiq + "), die Kerze schließt aber nur " + sSide + " dem Körper der Vorkerze, nicht " + sSide + " deren " + sOpp + "."
        else
            defn := "Attempted FU: the wick takes out the previous candle's " + sExt + " (" + sLiq + "), but the candle only closes " + sSide + " the previous candle's body, not " + sSide + " its " + sOpp + "."
    else if tier == 2
        head := sDir + (de ? " FU (FU-Kerze)" : " FU (FU candle)")
        if de
            defn := "FU-Kerze: Der Docht nimmt das " + sExt + " der Vorkerze heraus (" + sLiq + ") und die Kerze schließt " + sSide + " dem " + sOpp + " der Vorkerze. Sweep und Umkehr in einer Kerze."
        else
            defn := "FU candle: the wick takes out the previous candle's " + sExt + " (" + sLiq + ") and the candle closes " + sSide + " the previous candle's " + sOpp + ". Sweep and reversal in one candle."
    else
        head := sDir + " SFU (Strong FU)"
        string extra = ""
        if sfuNeedSwing
            extra := de ? " zusätzlich das Swing-" + sExtCap + " der letzten " + str.tostring(swingLen) + " Kerzen abholt" : " also sweeps the swing " + sExt + " of the last " + str.tostring(swingLen) + " bars"
        if sfuNeedDisp
            string joiner = sfuNeedSwing ? (de ? " und" : " and") : ""
            extra := extra + joiner + (de ? " eine Spanne von mindestens " + str.tostring(dispMult) + " × ATR hat" : " has a range of at least " + str.tostring(dispMult) + " × ATR")
        if de
            defn := "Starke FU: eine FU-Kerze" + (extra == "" ? "" : ", die" + extra) + ". FU = Docht nimmt das " + sExt + " der Vorkerze heraus (" + sLiq + "), Schluss " + sSide + " dem " + sOpp + " der Vorkerze."
        else
            defn := "Strong FU: an FU candle" + (extra == "" ? "" : " that" + extra) + ". FU = wick takes out the previous candle's " + sExt + " (" + sLiq + "), close " + sSide + " the previous candle's " + sOpp + "."

    // --- Facts of this candle ------------------------------------------------
    string atrTxt   = na(atr) or atr == 0 ? "" : " (" + str.tostring(travel / atr, "#.##") + " × ATR)"
    string lSwept   = (de ? "Abgeholte Kerze: " : "Swept candle: ") + str.format_time(prevTime, tfmt, syminfo.timezone) + " · " + sExtCap + " " + str.tostring(prevExt, format.mintick)
    string lCandle  = (de ? "FU-Kerze: " : "FU candle: ") + str.format_time(time, tfmt, syminfo.timezone)
    string lStart   = (de ? "Start (Eröffnung): " : "Start (open): ") + str.tostring(open, format.mintick)
    string lSweep   = (de ? "Sweep-" + sExtCap + ": " : "Sweep " + sExt + ": ") + str.tostring(ext, format.mintick) + (de ? " (" + str.tostring(depth, format.mintick) + " über das " + sExtCap + " der Vorkerze hinaus)" : " (" + str.tostring(depth, format.mintick) + " beyond the previous " + sExt + ")")
    string lSwing   = tier == 3 and sfuNeedSwing ? nl + (de ? "Abgeholtes Swing-" + sExtCap + ": " : "Swing " + sExt + " swept: ") + str.tostring(swingLv, format.mintick) : ""
    string lEnd     = (de ? "Ende (Schluss): " : "End (close): ") + str.tostring(close, format.mintick)
    string lReclaim = ""
    if tier == 1
        lReclaim := (de ? "Zurückerobert: Körper der Vorkerze " : "Reclaimed: previous candle's body ") + str.tostring(prevBody, format.mintick)
    else
        lReclaim := (de ? "Zurückerobert: " + sOpp + " der Vorkerze " : "Reclaimed: previous candle's " + sOpp + " ") + str.tostring(prevOpp, format.mintick)
    string lTravel  = (de ? "Strecke Sweep bis Schluss: " : "Move from sweep to close: ") + str.tostring(travel, format.mintick) + atrTxt
    string lBB      = showBB or bbFilter ? nl + (de ? "Bollinger-Band (" + (isBull ? "unten" : "oben") + "): " : "Bollinger Band (" + (isBull ? "lower" : "upper") + "): ") + str.tostring(isBull ? bbLower : bbUpper, format.mintick) : ""
    string lZone    = (de ? "Zeitzone: " : "Time zone: ") + syminfo.timezone

    head + nl + nl + defn + nl + nl + lSwept + nl + lCandle + nl + lStart + nl + lSweep + lSwing + nl + lEnd + nl + lReclaim + nl + lTravel + lBB + nl + lZone

f_drawLabel(int tier, bool isBull) =>
    string nm  = tier == 3 ? "SFU" : tier == 2 ? "FU" : "AFU"
    string tip = showTip ? f_tip(tier, isBull) : ""
    label.new(bar_index, isBull ? low : high, showLblText ? nm : "", xloc = xloc.bar_index, yloc = isBull ? yloc.belowbar : yloc.abovebar, color = f_lblColor(tier, isBull), style = f_shape(f_shapeSel(tier), isBull), textcolor = f_txtColor(tier), size = f_size(f_sizeSel(tier)), tooltip = tip)

// On a still-forming bar (confirmation off) Pine rolls the label back on every
// tick, so no duplicates can pile up. Oldest labels are removed automatically
// once max_labels_count is reached.
if showLabels and anyBull
    f_drawLabel(bullTier, true)
if showLabels and anyBear
    f_drawLabel(bearTier, false)

// =============================================================================
// === FVG CREATED BY THE FU CANDLE ============================================
// =============================================================================
// The FU candle is the middle candle [1] of the three-candle pattern:
//   bullish FVG: low of the current bar is above the high of bar [2]
//   bearish FVG: high of the current bar is below the low of bar [2]
var array<box> fvgBoxes = array.new<box>()
bool bullFvg = showFvg and confirmed and bullTier[1] > 0 and low > high[2]
bool bearFvg = showFvg and confirmed and bearTier[1] > 0 and high < low[2]

if bullFvg
    fvgBoxes.push(box.new(bar_index - 2, low, bar_index + fvgExtend, high[2], border_color = cFvgBdBull, border_width = fvgBdWidth, border_style = f_lineStyle(fvgBdStyle), bgcolor = cFvgBull))
if bearFvg
    fvgBoxes.push(box.new(bar_index - 2, low[2], bar_index + fvgExtend, high, border_color = cFvgBdBear, border_width = fvgBdWidth, border_style = f_lineStyle(fvgBdStyle), bgcolor = cFvgBear))
while fvgBoxes.size() > fvgMax
    box.delete(fvgBoxes.shift())

// =============================================================================
// === LEVELS (body 50% + sweep wick) ==========================================
// =============================================================================
var array<line> lvlLines = array.new<line>()
if showLevels and (anyBull or anyBear)
    float bodyMid = (open + close) / 2.0
    float wickLvl = anyBull ? low : high
    lvlLines.push(line.new(bar_index, bodyMid, bar_index + lvlLen, bodyMid, color = anyBull ? cMidBull : cMidBear, style = f_lineStyle(midStyle), width = midWidth))
    lvlLines.push(line.new(bar_index, wickLvl, bar_index + lvlLen, wickLvl, color = anyBull ? cWickBull : cWickBear, style = f_lineStyle(wickStyle), width = wickWidth))
while lvlLines.size() > lvlMax * 2
    line.delete(lvlLines.shift())

// =============================================================================
// === CANDLE COLOR + PLOTS ====================================================
// =============================================================================
color barCol = na
if useBarColor
    if anyBull
        barCol := f_barColor(bullTier, true)
    else if anyBear
        barCol := f_barColor(bearTier, false)
barcolor(barCol, title = "FU-Kerzenfarbe / FU candle color")

plot(showMa ? ma : na, title = "Trend-SMA / Trend SMA", color = cMa, linewidth = maWidth)

// Signed tier for the Data Window / Pine Screener:
// +3 / +2 / +1 = bullish SFU / FU / AFU, -3 / -2 / -1 = bearish, 0 = none
plot(bullTier - bearTier, title = "FU-Stufe (mit Vorzeichen) / FU tier (signed)", display = display.data_window)

// =============================================================================
// === BOLLINGER BANDS: LINES, FILL, LABELS ====================================
// =============================================================================
// A hidden band keeps its series (transparent color), so the fill between the
// upper and lower band still works when a single line is switched off.
plot(showBB ? bbBasis : na, title = "BB Basis / BB basis", color = showBbBasis ? cBbBasis : na, linewidth = bbBasisWidth, linestyle = bbBasisStyle == LS_DASHED ? plot.linestyle_dashed : bbBasisStyle == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
pBbUpper = plot(showBB ? bbUpper : na, title = "BB oben / BB upper", color = showBbUpper ? cBbUpper : na, linewidth = bbUpperWidth, linestyle = bbUpperStyle == LS_DASHED ? plot.linestyle_dashed : bbUpperStyle == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
pBbLower = plot(showBB ? bbLower : na, title = "BB unten / BB lower", color = showBbLower ? cBbLower : na, linewidth = bbLowerWidth, linestyle = bbLowerStyle == LS_DASHED ? plot.linestyle_dashed : bbLowerStyle == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
fill(pBbUpper, pBbLower, color = showBB and bbFill ? cBbFill : na, title = "BB-Fläche / BB fill")

// The band labels are drawn by the shared label engine further below
// (section "MTF SMA LINES"), together with the MTF SMA labels, so the
// collision guard can arrange both kinds in one pass.
bool bbCrossUp = ta.crossover(close, bbUpper)
bool bbCrossDn = ta.crossunder(close, bbLower)

// =============================================================================
// === MTF SMA LINES ===========================================================
// =============================================================================
// One SMA per slot, calculated on the slot's own timeframe (input.timeframe).
// Same repainting approach as the dashboard:
//   closed : request.security(.., sma[1], lookahead_on)  -> last CLOSED candle
//   live   : request.security(.., sma,    lookahead_off) -> open candle
// Both requests run on every bar; the input only selects which result is used.
f_mtfSma(simple string tf, simple int len) =>
    float closedVal = request.security(syminfo.tickerid, tf, ta.sma(mtfSrc, len)[1], lookahead = barmerge.lookahead_on)
    float liveVal   = request.security(syminfo.tickerid, tf, ta.sma(mtfSrc, len), lookahead = barmerge.lookahead_off)
    mtfClosed ? closedVal : liveVal

// A slot is drawn when module + slot are on and (optionally) its timeframe is
// not below the chart timeframe. An empty timeframe string means "Chart".
f_mtfVisible(simple string tf, bool en) =>
    showMtf and en and (not mtfHtfOnly or timeframe.in_seconds(tf) >= timeframe.in_seconds(timeframe.period))

// Short timeframe name: "240" -> H4, "D" -> D1, "W" -> W1, "M" -> MN1, "12M" -> Y1
f_mtfTfLabel(simple string tf) =>
    string tfs = tf == "" ? timeframe.period : tf
    int    sec = timeframe.in_seconds(tfs)
    int    mon = math.round(sec / 2628003.0)
    string lbl = switch
        str.endswith(tfs, "M") and mon % 12 == 0 => "Y" + str.tostring(int(mon / 12))
        str.endswith(tfs, "M")                   => "MN" + str.tostring(mon)
        sec % 604800 == 0                        => "W" + str.tostring(int(sec / 604800))
        sec % 86400 == 0                         => "D" + str.tostring(int(sec / 86400))
        sec % 3600 == 0                          => "H" + str.tostring(int(sec / 3600))
        sec % 60 == 0                            => "M" + str.tostring(int(sec / 60))
        => "S" + str.tostring(sec)
    lbl

float mtfVal1 = f_mtfSma(mtfTf1, mtfLen1)
bool  mtfOn1  = f_mtfVisible(mtfTf1, mtfEn1)
plot(mtfOn1 ? mtfVal1 : na, title = "MTF SMA 1", color = cMtf1, linewidth = mtfWidth1, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle1 == LS_DASHED ? plot.linestyle_dashed : mtfStyle1 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal2 = f_mtfSma(mtfTf2, mtfLen2)
bool  mtfOn2  = f_mtfVisible(mtfTf2, mtfEn2)
plot(mtfOn2 ? mtfVal2 : na, title = "MTF SMA 2", color = cMtf2, linewidth = mtfWidth2, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle2 == LS_DASHED ? plot.linestyle_dashed : mtfStyle2 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal3 = f_mtfSma(mtfTf3, mtfLen3)
bool  mtfOn3  = f_mtfVisible(mtfTf3, mtfEn3)
plot(mtfOn3 ? mtfVal3 : na, title = "MTF SMA 3", color = cMtf3, linewidth = mtfWidth3, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle3 == LS_DASHED ? plot.linestyle_dashed : mtfStyle3 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal4 = f_mtfSma(mtfTf4, mtfLen4)
bool  mtfOn4  = f_mtfVisible(mtfTf4, mtfEn4)
plot(mtfOn4 ? mtfVal4 : na, title = "MTF SMA 4", color = cMtf4, linewidth = mtfWidth4, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle4 == LS_DASHED ? plot.linestyle_dashed : mtfStyle4 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal5 = f_mtfSma(mtfTf5, mtfLen5)
bool  mtfOn5  = f_mtfVisible(mtfTf5, mtfEn5)
plot(mtfOn5 ? mtfVal5 : na, title = "MTF SMA 5", color = cMtf5, linewidth = mtfWidth5, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle5 == LS_DASHED ? plot.linestyle_dashed : mtfStyle5 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal6 = f_mtfSma(mtfTf6, mtfLen6)
bool  mtfOn6  = f_mtfVisible(mtfTf6, mtfEn6)
plot(mtfOn6 ? mtfVal6 : na, title = "MTF SMA 6", color = cMtf6, linewidth = mtfWidth6, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle6 == LS_DASHED ? plot.linestyle_dashed : mtfStyle6 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal7 = f_mtfSma(mtfTf7, mtfLen7)
bool  mtfOn7  = f_mtfVisible(mtfTf7, mtfEn7)
plot(mtfOn7 ? mtfVal7 : na, title = "MTF SMA 7", color = cMtf7, linewidth = mtfWidth7, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle7 == LS_DASHED ? plot.linestyle_dashed : mtfStyle7 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)
float mtfVal8 = f_mtfSma(mtfTf8, mtfLen8)
bool  mtfOn8  = f_mtfVisible(mtfTf8, mtfEn8)
plot(mtfOn8 ? mtfVal8 : na, title = "MTF SMA 8", color = cMtf8, linewidth = mtfWidth8, style = mtfPlotStyle == PS_STEP ? plot.style_stepline : plot.style_line, linestyle = mtfStyle8 == LS_DASHED ? plot.linestyle_dashed : mtfStyle8 == LS_DOTTED ? plot.linestyle_dotted : plot.linestyle_solid)

// =============================================================================
// === PERIODIC VOLUME PROFILE (3 instances) ===================================
// =============================================================================
// Derived from "[Pt] Periodic Volume Profile" (c) PtGambler, based on
// "Volume Profile, Pivot Anchored" (c) dgtrd - Mozilla Public License 2.0.
//
// How it differs from the stand-alone script (same results, less work):
//   - Row volumes are kept in a persistent array and extended by the NEW bar
//     only. A full pass over the period happens just when the period makes a
//     new high or low (the rows then change size) or when bars were skipped.
//   - The period's high / low are tracked while collecting (no array scan).
//   - The developing drawings of all three profiles live in three shared
//     pools that are cleared in one pass per update.
//   - Level labels are not drawn here: the levels are handed to the shared
//     label engine below (collision guard, look of group 22).
//   - No request.security() call: everything is built from chart bars.
type PvpCfg
    bool   showHist
    bool   showDev
    bool   showPrev
    bool   showRows
    float  vaPct
    int    rows
    string placement
    float  widthPct
    color  volVA
    color  volOut
    bool   showPoc
    color  pocCol
    int    pocWidth
    string pocExtend
    int    maxNaked
    bool   showVah
    color  vahCol
    bool   showVal
    color  valCol
    bool   vaBg
    color  vaBgCol
    bool   rangeBg
    color  rangeBgCol
    bool   pathOn

// Shared pools for the developing drawings (redrawn on every last-bar update)
var array<box>      pvpDevBoxes = array.new<box>()
var array<line>     pvpDevLines = array.new<line>()
var array<linefill> pvpDevFills = array.new<linefill>()
if barstate.islast
    for oldBox in pvpDevBoxes
        box.delete(oldBox)
    pvpDevBoxes.clear()
    for oldLine in pvpDevLines
        line.delete(oldLine)
    pvpDevLines.clear()
    for oldFill in pvpDevFills
        linefill.delete(oldFill)
    pvpDevFills.clear()

// Clamp an x coordinate (bar_index) into TradingView's drawable window
f_pvpX(int x) =>
    math.max(0, math.max(bar_index - 4990, math.min(x, bar_index + 490)))

// Distributes the volume of the bars [first .. last] over the rows
f_pvpAdd(array<float> vols, array<float> hs, array<float> ls, array<float> vs, int first, float lo, float step, int rows) =>
    int last = hs.size() - 1
    if step > 0 and first <= last
        for i = first to last
            float bv = vs.get(i)
            if bv > 0
                float bh = hs.get(i)
                float bl = ls.get(i)
                float sz = bh - bl
                int   k0 = math.max(0, math.min(rows - 1, int(math.floor((bl - lo) / step))))
                int   k1 = math.max(0, math.min(rows - 1, int(math.floor((bh - lo) / step))))
                if sz <= 0
                    vols.set(k0, vols.get(k0) + bv)
                else
                    for k = k0 to k1
                        float rBot = lo + k * step
                        float ov   = math.min(bh, rBot + step) - math.max(bl, rBot)
                        if ov > 0
                            vols.set(k, vols.get(k) + bv * ov / sz)

// Brings the row volumes up to date and returns the row height.
// Rebuilds only when the range changed since the last sync, otherwise adds
// the bars that are not binned yet (normally just the current bar).
f_pvpSync(array<float> vols, array<float> hs, array<float> ls, array<float> vs, int binned, float binLo, float binHi, float perLo, float perHi, int rows) =>
    float step    = (perHi - perLo) / rows
    bool  rebuild = na(binLo) or binLo != perLo or binHi != perHi or binned > hs.size()
    if rebuild
        vols.fill(0.0)
    f_pvpAdd(vols, hs, ls, vs, rebuild ? 0 : binned, perLo, step, rows)
    step

// POC row and value area rows -> [pocRow, vaUpRow, vaDnRow, maxRowVolume]
f_pvpArea(array<float> vols, int rows, float vaPct) =>
    float mx  = vols.max()
    int   poc = 0
    int   up  = 0
    int   dn  = 0
    if mx > 0
        poc := vols.indexof(mx)
        float target = vols.sum() * vaPct
        float acc    = mx
        up := poc
        dn := poc
        while acc < target and (dn > 0 or up < rows - 1)
            float vUp = up < rows - 1 ? vols.get(up + 1) : -1.0
            float vDn = dn > 0 ? vols.get(dn - 1) : -1.0
            if vUp >= vDn
                acc += vUp
                up  += 1
            else
                acc += vDn
                dn  -= 1
    [poc, up, dn, mx]

// Histogram rows; track = true puts the boxes into the developing pool
f_pvpRows(array<float> vols, float mx, float lo, float step, int up, int dn, int xA, int xB, int xN, int len, PvpCfg c, bool track) =>
    for k = 0 to c.rows - 1
        float v = vols.get(k)
        if v > 0
            int   w      = math.max(1, int(math.round(v / mx * len * c.widthPct)))
            int   bx0    = c.placement == PL_RIGHT ? xB - w : c.placement == PL_LEFT ? xA : xN
            int   bx1    = c.placement == PL_RIGHT ? xB : bx0 + w
            color rowCol = k >= dn and k <= up ? c.volVA : c.volOut
            box   rowBox = box.new(f_pvpX(bx0), lo + (k + 0.9) * step, f_pvpX(bx1), lo + (k + 0.1) * step, rowCol, 1, bgcolor = rowCol)
            if track
                pvpDevBoxes.push(rowBox)

// One profile instance (own state per call site via var).
// Returns [dPOC, dVAH, dVAL, pocAlert (1 = crossed, 2 = touched), newPeriod, pPOC, pVAH, pVAL]
f_pvp(simple string tf, bool regSess, bool active, PvpCfg c) =>
    var array<float> hs      = array.new<float>()
    var array<float> ls      = array.new<float>()
    var array<float> vs      = array.new<float>()
    var array<float> vols    = array.new<float>(c.rows, 0.0)
    var array<line>  naked   = array.new<line>()
    var bool  started = false
    var float perHi   = na
    var float perLo   = na
    var float binHi   = na
    var float binLo   = na
    var int   binned  = 0
    var float pPoc    = na
    var float pVah    = na
    var float pVal    = na

    bool  tfChange  = timeframe.change(tf)
    bool  firstReg  = session.isfirstbar_regular
    float prevClose = close[1]
    bool  newPeriod = active and (tfChange or (regSess and firstReg))
    int   pocAlert  = 0
    float dPoc      = na
    float dVah      = na
    float dVal      = na

    // 1) Naked POC tracking (cross / touch)
    if active and naked.size() > 0
        for i = naked.size() - 1 to 0
            line  ln  = naked.get(i)
            float lvl = line.get_y1(ln)
            if na(lvl)
                naked.remove(i)
            else if not na(prevClose)
                float sPrev   = math.sign(prevClose - lvl)
                bool  crossed = sPrev != math.sign(close - lvl)
                bool  touched = crossed or sPrev != math.sign(low - lvl) or sPrev != math.sign(high - lvl)
                if crossed
                    pocAlert := 1
                else if touched and pocAlert == 0
                    pocAlert := 2
                line.set_x2(ln, bar_index)
                if (c.pocExtend == PX_CROSS and crossed) or (c.pocExtend == PX_TOUCH and touched)
                    naked.remove(i)

    // 2) Period change -> finalize the completed profile
    if newPeriod
        int done = hs.size()
        if started and done > 0 and perHi > perLo
            float cStep = f_pvpSync(vols, hs, ls, vs, binned, binLo, binHi, perLo, perHi, c.rows)
            [cPoc, cUp, cDn, cMx] = f_pvpArea(vols, c.rows, c.vaPct)
            if cMx > 0
                int   xA    = f_pvpX(bar_index - done)
                int   xB    = bar_index - 1
                float pocPx = perLo + (cPoc + 0.5) * cStep
                float vahPx = perLo + (cUp + 1) * cStep
                float valPx = perLo + cDn * cStep
                if c.showHist
                    if c.showRows
                        f_pvpRows(vols, cMx, perLo, cStep, cUp, cDn, xA, xB, bar_index, done, c, false)
                    if c.rangeBg
                        box.new(xA, perHi, xB, perLo, c.rangeBgCol, 1, line.style_dotted, bgcolor = c.rangeBgCol)
                    if c.showVah or c.showVal or c.vaBg
                        line lH = line.new(xA, vahPx, xB, vahPx, color = c.showVah ? c.vahCol : color(na), width = 2)
                        line lL = line.new(xA, valPx, xB, valPx, color = c.showVal ? c.valCol : color(na), width = 2)
                        if c.vaBg
                            linefill.new(lH, lL, c.vaBgCol)
                // The POC line of a completed period is only kept when completed
                // profiles are shown or naked POCs are tracked.
                if c.showPoc and (c.showHist or c.pocExtend != PX_NONE)
                    line lP = line.new(xA, pocPx, bar_index, pocPx, color = c.pocCol, width = c.pocWidth)
                    if c.pocExtend != PX_NONE
                        naked.push(lP)
                        if naked.size() > c.maxNaked
                            naked.shift()
                pPoc := pocPx
                pVah := vahPx
                pVal := valPx
        hs.clear()
        ls.clear()
        vs.clear()
        vols.fill(0.0)
        binned  := 0
        binLo   := na
        binHi   := na
        perHi   := na
        perLo   := na
        started := true

    // 3) Collect the current bar, track the period's range on the way
    if active
        hs.push(high)
        ls.push(low)
        vs.push(nz(volume))
        perHi := na(perHi) ? high : math.max(perHi, high)
        perLo := na(perLo) ? low : math.min(perLo, low)

    // 4) Developing profile + previous levels
    if active and hs.size() > 0
        int  len     = hs.size()
        int  xD      = f_pvpX(bar_index - len + 1)
        bool pathNow = c.showDev and c.pathOn and bar_index >= last_bar_index - pvpPathBars
        bool drawNow = barstate.islast and c.showDev
        if (pathNow or drawNow) and perHi > perLo
            float dStep = f_pvpSync(vols, hs, ls, vs, binned, binLo, binHi, perLo, perHi, c.rows)
            binned := len
            binLo  := perLo
            binHi  := perHi
            [dPc, dUp, dDn, dMx] = f_pvpArea(vols, c.rows, c.vaPct)
            if dMx > 0
                dPoc := perLo + (dPc + 0.5) * dStep
                dVah := perLo + (dUp + 1) * dStep
                dVal := perLo + dDn * dStep
                if drawNow
                    if c.showRows
                        f_pvpRows(vols, dMx, perLo, dStep, dUp, dDn, xD, bar_index, bar_index, len, c, true)
                    if c.rangeBg
                        pvpDevBoxes.push(box.new(xD, perHi, bar_index, perLo, c.rangeBgCol, 1, line.style_dotted, bgcolor = c.rangeBgCol))
                    if c.showVah or c.showVal or c.vaBg
                        line dH = line.new(xD, dVah, bar_index, dVah, color = c.showVah ? c.vahCol : color(na), width = 2)
                        line dL = line.new(xD, dVal, bar_index, dVal, color = c.showVal ? c.valCol : color(na), width = 2)
                        pvpDevLines.push(dH)
                        pvpDevLines.push(dL)
                        if c.vaBg
                            pvpDevFills.push(linefill.new(dH, dL, c.vaBgCol))
                    if c.showPoc
                        pvpDevLines.push(line.new(xD, dPoc, bar_index, dPoc, color = c.pocCol, width = c.pocWidth))
        if barstate.islast and c.showPrev and not na(pPoc)
            line pP = line.new(xD, pPoc, bar_index, pPoc, color = c.pocCol, style = line.style_dashed, width = 2)
            line pH = line.new(xD, pVah, bar_index, pVah, color = c.vahCol, style = line.style_dashed, width = 2)
            line pL = line.new(xD, pVal, bar_index, pVal, color = c.valCol, style = line.style_dashed, width = 2)
            pvpDevLines.push(pP)
            pvpDevLines.push(pH)
            pvpDevLines.push(pL)
            if c.vaBg
                pvpDevFills.push(linefill.new(pH, pL, color.new(c.vaBgCol, 95)))

    [dPoc, dVah, dVal, pocAlert, newPeriod, pPoc, pVah, pVal]

var PvpCfg pvpCfg1 = PvpCfg.new(pvpHist1, pvpDev1, pvpPrev1, pvpBars1, pvpVaPct1 / 100.0, pvpRows1, pvpPlc1, pvpWid1 / 100.0, pvpColVA1, pvpColOut1, pvpPoc1, pvpPocCol1, pvpPocW1, pvpPocExt1, pvpNaked1, pvpVah1, pvpVahCol1, pvpVal1, pvpValCol1, pvpVaBg1, pvpVaBgCol1, pvpBg1, pvpBgCol1, pvpDpoc1 or pvpDvah1 or pvpDval1)
bool pvpOn1 = showPvp and pvpEn1 and timeframe.in_seconds(pvpTf1) > timeframe.in_seconds(timeframe.period)
[pvpDPoc1, pvpDVah1, pvpDVal1, pvpAlert1, pvpNew1, pvpPPoc1, pvpPVah1, pvpPVal1] = f_pvp(pvpTf1, pvpReg1, pvpOn1, pvpCfg1)
var PvpCfg pvpCfg2 = PvpCfg.new(pvpHist2, pvpDev2, pvpPrev2, pvpBars2, pvpVaPct2 / 100.0, pvpRows2, pvpPlc2, pvpWid2 / 100.0, pvpColVA2, pvpColOut2, pvpPoc2, pvpPocCol2, pvpPocW2, pvpPocExt2, pvpNaked2, pvpVah2, pvpVahCol2, pvpVal2, pvpValCol2, pvpVaBg2, pvpVaBgCol2, pvpBg2, pvpBgCol2, pvpDpoc2 or pvpDvah2 or pvpDval2)
bool pvpOn2 = showPvp and pvpEn2 and timeframe.in_seconds(pvpTf2) > timeframe.in_seconds(timeframe.period)
[pvpDPoc2, pvpDVah2, pvpDVal2, pvpAlert2, pvpNew2, pvpPPoc2, pvpPVah2, pvpPVal2] = f_pvp(pvpTf2, pvpReg2, pvpOn2, pvpCfg2)
var PvpCfg pvpCfg3 = PvpCfg.new(pvpHist3, pvpDev3, pvpPrev3, pvpBars3, pvpVaPct3 / 100.0, pvpRows3, pvpPlc3, pvpWid3 / 100.0, pvpColVA3, pvpColOut3, pvpPoc3, pvpPocCol3, pvpPocW3, pvpPocExt3, pvpNaked3, pvpVah3, pvpVahCol3, pvpVal3, pvpValCol3, pvpVaBg3, pvpVaBgCol3, pvpBg3, pvpBgCol3, pvpDpoc3 or pvpDvah3 or pvpDval3)
bool pvpOn3 = showPvp and pvpEn3 and timeframe.in_seconds(pvpTf3) > timeframe.in_seconds(timeframe.period)
[pvpDPoc3, pvpDVah3, pvpDVal3, pvpAlert3, pvpNew3, pvpPPoc3, pvpPVah3, pvpPVal3] = f_pvp(pvpTf3, pvpReg3, pvpOn3, pvpCfg3)

// Color legend: which line color stands for which level of which profile.
// Built like the dashboard table: detached pills, layout, margins, grid,
// frame and fonts are configurable. All of its content comes from inputs, so
// the table is built once on the first bar. A table needs no plot count.
// Black or white text, whichever reads better on the given background
f_pvpContrast(color bg) =>
    float lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 150 ? color.black : color.white

// Appends one pill to the legend lists. kind: 0 = period / header, 1 = line
f_pvpLegPush(array<string> txts, array<color> bgs, array<int> kinds, array<int> rows, array<int> cols, string txt, color bg, int kind, int r, int c) =>
    txts.push(txt)
    bgs.push(bg)
    kinds.push(kind)
    rows.push(r)
    cols.push(c)

// Appends the pills of one profile, returns the next free row
f_pvpLegRow(array<string> txts, array<color> bgs, array<int> kinds, array<int> rows, array<int> cols, int r, bool on, simple string tf, PvpCfg c) =>
    bool any = on and (c.showPoc or c.showVah or c.showVal or c.showPrev)
    if any
        int k = 0
        f_pvpLegPush(txts, bgs, kinds, rows, cols, f_mtfTfLabel(tf), pvpLegTfBg, 0, r, k)
        if c.showPoc or c.showPrev
            k += 1
            f_pvpLegPush(txts, bgs, kinds, rows, cols, "POC", c.pocCol, 1, r, k)
        if c.showVah or c.showPrev
            k += 1
            f_pvpLegPush(txts, bgs, kinds, rows, cols, "VAH", c.vahCol, 1, r, k)
        if c.showVal or c.showPrev
            k += 1
            f_pvpLegPush(txts, bgs, kinds, rows, cols, "VAL", c.valCol, 1, r, k)
    any ? r + 1 : r

if barstate.isfirst and showPvp and pvpLegOn
    array<string> legTxt  = array.new<string>()
    array<color>  legBg   = array.new<color>()
    array<int>    legKind = array.new<int>()
    array<int>    legRow  = array.new<int>()
    array<int>    legCol  = array.new<int>()
    int legNext = 0
    if pvpLegHdr
        f_pvpLegPush(legTxt, legBg, legKind, legRow, legCol, "PVP", pvpLegTfBg, 0, 0, 0)
        f_pvpLegPush(legTxt, legBg, legKind, legRow, legCol, langInp == "Deutsch" ? "Linien" : "Lines", pvpLegTfBg, 0, 0, 1)
        legNext := 1
    int legFirst = legNext
    legNext := f_pvpLegRow(legTxt, legBg, legKind, legRow, legCol, legNext, pvpOn1, pvpTf1, pvpCfg1)
    legNext := f_pvpLegRow(legTxt, legBg, legKind, legRow, legCol, legNext, pvpOn2, pvpTf2, pvpCfg2)
    legNext := f_pvpLegRow(legTxt, legBg, legKind, legRow, legCol, legNext, pvpOn3, pvpTf3, pvpCfg3)
    int legN = legTxt.size()
    if legNext > legFirst
        string legPos = switch pvpLegPos
            LP_TL => position.top_left
            LP_TC => position.top_center
            LP_ML => position.middle_left
            LP_MC => position.middle_center
            LP_MR => position.middle_right
            LP_BL => position.bottom_left
            LP_BC => position.bottom_center
            LP_BR => position.bottom_right
            => position.top_right
        bool legVert = pvpLegLayout == LL_VERT
        // Apply margins only at the edge where the table actually sits
        int legPT = pvpLegPos == LP_TL or pvpLegPos == LP_TC or pvpLegPos == LP_TR ? pvpLegPadT : 0
        int legPB = pvpLegPos == LP_BL or pvpLegPos == LP_BC or pvpLegPos == LP_BR ? pvpLegPadB : 0
        int legPL = pvpLegPos == LP_TL or pvpLegPos == LP_ML or pvpLegPos == LP_BL ? pvpLegPadL : 0
        int legPR = pvpLegPos == LP_TR or pvpLegPos == LP_MR or pvpLegPos == LP_BR ? pvpLegPadR : 0
        int legUsedC = legVert ? legCol.max() + 1 : legN
        int legUsedR = legVert ? legNext : 1
        color legClear = color.new(color.black, 100)
        table pvpLeg = table.new(legPos, legUsedC + legPL + legPR, legUsedR + legPT + legPB, bgcolor = legClear, frame_width = pvpLegFrameW, frame_color = pvpLegFrameCol, border_width = pvpLegGap, border_color = pvpLegGridAuto ? chart.bg_color : pvpLegGridCol)
        // Margins: invisible spacer cells (rows top / bottom, columns left / right)
        if legPT > 0
            for r = 0 to legPT - 1
                table.cell(pvpLeg, legPL, r, " ", bgcolor = legClear, text_size = f_size(pvpLegSize))
        if legPB > 0
            for r = 0 to legPB - 1
                table.cell(pvpLeg, legPL, legPT + legUsedR + r, " ", bgcolor = legClear, text_size = f_size(pvpLegSize))
        if legPL > 0
            for c = 0 to legPL - 1
                table.cell(pvpLeg, c, legPT, "      ", bgcolor = legClear, text_size = f_size(pvpLegSize))
        if legPR > 0
            for c = 0 to legPR - 1
                table.cell(pvpLeg, legPL + legUsedC + c, legPT, "      ", bgcolor = legClear, text_size = f_size(pvpLegSize))
        // Pills
        for i = 0 to legN - 1
            bool  isTf  = legKind.get(i) == 0
            color pillC = legBg.get(i)
            color txtC  = isTf ? pvpLegTfTxt : pvpLegAutoTxt ? f_pvpContrast(pillC) : pvpLegLvlTxt
            table.cell(pvpLeg, legPL + (legVert ? legCol.get(i) : i), legPT + (legVert ? legRow.get(i) : 0), "  " + legTxt.get(i) + "  ", text_color = txtC, bgcolor = pillC, text_size = f_size(isTf ? pvpLegSizeTf : pvpLegSize), text_font_family = pvpLegFont == LF_MONO ? font.family_monospace : font.family_default, text_halign = text.align_center, text_valign = text.align_center)

// Plot budget: a plot counts twice when its color is not a constant, and an
// input color is not a constant. The paths therefore use constant colors;
// users change them in the Style tab. plot.style_linebr + na on the first bar
// of a period breaks the line between two periods.
plot(pvpDev1 and pvpDpoc1 and not pvpNew1 ? pvpDPoc1 : na, title = "PVP1 Entwicklungspfad POC / developing POC path", color = color.yellow, linewidth = 2, style = plot.style_linebr)
plot(pvpDev1 and pvpDvah1 and not pvpNew1 ? pvpDVah1 : na, title = "PVP1 Entwicklungspfad VAH / developing VAH path", color = color.aqua, linewidth = 2, style = plot.style_linebr)
plot(pvpDev1 and pvpDval1 and not pvpNew1 ? pvpDVal1 : na, title = "PVP1 Entwicklungspfad VAL / developing VAL path", color = color.aqua, linewidth = 2, style = plot.style_linebr)
plot(pvpDev2 and pvpDpoc2 and not pvpNew2 ? pvpDPoc2 : na, title = "PVP2 Entwicklungspfad POC / developing POC path", color = color.fuchsia, linewidth = 2, style = plot.style_linebr)
plot(pvpDev2 and pvpDvah2 and not pvpNew2 ? pvpDVah2 : na, title = "PVP2 Entwicklungspfad VAH / developing VAH path", color = color.new(color.teal, 30), linewidth = 2, style = plot.style_linebr)
plot(pvpDev2 and pvpDval2 and not pvpNew2 ? pvpDVal2 : na, title = "PVP2 Entwicklungspfad VAL / developing VAL path", color = color.new(color.teal, 30), linewidth = 2, style = plot.style_linebr)
plot(pvpDev3 and pvpDpoc3 and not pvpNew3 ? pvpDPoc3 : na, title = "PVP3 Entwicklungspfad POC / developing POC path", color = color.lime, linewidth = 2, style = plot.style_linebr)
plot(pvpDev3 and pvpDvah3 and not pvpNew3 ? pvpDVah3 : na, title = "PVP3 Entwicklungspfad VAH / developing VAH path", color = color.new(color.olive, 30), linewidth = 2, style = plot.style_linebr)
plot(pvpDev3 and pvpDval3 and not pvpNew3 ? pvpDVal3 : na, title = "PVP3 Entwicklungspfad VAL / developing VAL path", color = color.new(color.olive, 30), linewidth = 2, style = plot.style_linebr)

// Naked-POC markers of all three profiles in four plots with constant colors
// (changeable in the Style tab).
bool  pvpXHit   = (pvpCross1 and pvpAlert1 == 1) or (pvpCross2 and pvpAlert2 == 1) or (pvpCross3 and pvpAlert3 == 1)
bool  pvpTHit   = (pvpTouch1 and pvpAlert1 == 2) or (pvpTouch2 and pvpAlert2 == 2) or (pvpTouch3 and pvpAlert3 == 2)
bool  pvpUpBar  = close >= open
plotshape(pvpXHit and pvpUpBar, title = "POC-Kreuzung (Aufwärtskerze) / POC cross (up bar)", style = shape.xcross, location = location.abovebar, color = color.orange, size = size.small)
plotshape(pvpXHit and not pvpUpBar, title = "POC-Kreuzung (Abwärtskerze) / POC cross (down bar)", style = shape.xcross, location = location.belowbar, color = color.orange, size = size.small)
plotshape(pvpTHit and pvpUpBar, title = "POC-Berührung (Aufwärtskerze) / POC touch (up bar)", style = shape.triangledown, location = location.abovebar, color = color.gray, size = size.small)
plotshape(pvpTHit and not pvpUpBar, title = "POC-Berührung (Abwärtskerze) / POC touch (down bar)", style = shape.triangleup, location = location.belowbar, color = color.gray, size = size.small)

alertcondition(pvpAlert1 == 1 or pvpAlert2 == 1 or pvpAlert3 == 1, title = "Irgendein offener POC gekreuzt / Any naked POC crossed", message = "A naked POC was crossed on {{ticker}} {{interval}} @ {{close}}")
alertcondition(pvpAlert1 == 2 or pvpAlert2 == 2 or pvpAlert3 == 2, title = "Irgendein offener POC berührt / Any naked POC touched", message = "A naked POC was touched on {{ticker}} {{interval}} @ {{close}}")

// Discreet label at the right edge: "H4 · SMA 200" + tooltip in the selected
// language, so the line is recognisable as coming from another timeframe.
//
// Collision guard
//   Shared by the MTF SMA labels and the Bollinger Band labels.
//   1) Every visible label is collected into buffers (price, text, tooltip,
//      color, kind: 0 = MTF SMA, 1 = Bollinger). The kind selects the style
//      settings (group 21 or 22) when the label is drawn.
//   2) Minimum distance = % of the price range (last n bars + shown SMA values).
//   3) "Spread vertically": labels sorted by price are grouped into clusters;
//      neighbouring clusters that would overlap are merged and their labels
//      laid out evenly around the cluster's mean price (minimal displacement).
//      "Stagger to the right": a label closer than the minimum distance to its
//      upper neighbour moves one column to the right, price stays exact.
//   4) A moved label gets a connector line back to the line's real price.
float mtfRefHi = ta.highest(high, mtfGuardBars)
float mtfRefLo = ta.lowest(low, mtfGuardBars)

var array<label>  mtfLbls   = array.new<label>()
var array<line>   mtfConns  = array.new<line>()
var array<float>  mtfBufY   = array.new<float>()
var array<string> mtfBufTxt = array.new<string>()
var array<string> mtfBufTip = array.new<string>()
var array<color>  mtfBufCol = array.new<color>()
var array<int>    mtfBufKnd = array.new<int>()

// SMA 9/20 of the chart timeframe -> shared buffers (kind 0 = same look as
// the MTF SMA labels, group 22)
f_smaCollect(float y, int len, color lineCol, string tfL, bool de) =>
    if not na(y)
        string nm = tfL + " · SMA " + str.tostring(len)
        mtfBufY.push(y)
        mtfBufTxt.push(mtfLblPrice ? nm + "  " + str.tostring(y, format.mintick) : nm)
        mtfBufTip.push(de ? "SMA " + str.tostring(len) + " der Chart-Zeitebene (" + tfL + ").\nWert: " + str.tostring(y, format.mintick) : "SMA " + str.tostring(len) + " of the chart timeframe (" + tfL + ").\nValue: " + str.tostring(y, format.mintick))
        mtfBufCol.push(lineCol)
        mtfBufKnd.push(0)

// Volume profile levels -> shared buffers (kind 0 = look of the MTF SMA labels)
f_pvpPush(float y, string nm, color lvlCol, string tip) =>
    if not na(y)
        mtfBufY.push(y)
        mtfBufTxt.push(mtfLblPrice ? nm + "  " + str.tostring(y, format.mintick) : nm)
        mtfBufTip.push(tip)
        mtfBufCol.push(lvlCol)
        mtfBufKnd.push(0)

f_pvpCollect(bool on, simple string tf, PvpCfg c, float dP, float dH, float dL, float pP, float pH, float pL) =>
    if on and pvpShowLbl
        bool   de   = langInp == "Deutsch"
        string tag  = f_mtfTfLabel(tf)
        string pct  = str.tostring(c.vaPct * 100) + " %"
        string tPoc = de ? "Point of Control: Preis mit dem meisten gehandelten Volumen" : "Point of Control: price with the most traded volume"
        string tVah = de ? "Value Area High: obere Grenze des Bereichs mit " + pct + " des Volumens" : "Value Area High: upper edge of the zone holding " + pct + " of the volume"
        string tVal = de ? "Value Area Low: untere Grenze des Bereichs mit " + pct + " des Volumens" : "Value Area Low: lower edge of the zone holding " + pct + " of the volume"
        string cur  = de ? " (laufendes " + tag + "-Profil)." : " (developing " + tag + " profile)."
        string prv  = de ? " (vorheriges " + tag + "-Profil)." : " (previous " + tag + " profile)."
        if c.showDev
            if c.showPoc
                f_pvpPush(dP, tag + " POC", c.pocCol, tPoc + cur)
            if c.showVah
                f_pvpPush(dH, tag + " VAH", c.vahCol, tVah + cur)
            if c.showVal
                f_pvpPush(dL, tag + " VAL", c.valCol, tVal + cur)
        if c.showPrev
            f_pvpPush(pP, tag + " pPOC", c.pocCol, tPoc + prv)
            f_pvpPush(pH, tag + " pVAH", c.vahCol, tVah + prv)
            f_pvpPush(pL, tag + " pVAL", c.valCol, tVal + prv)

// Bollinger Band label -> shared buffers (kind 1)
f_bbCollect(float y, string nm, color bandCol, string tip) =>
    mtfBufY.push(y)
    mtfBufTxt.push(bbLblPrice ? nm + " " + str.tostring(y, format.mintick) : nm)
    mtfBufTip.push(tip)
    mtfBufCol.push(bandCol)
    mtfBufKnd.push(1)

f_mtfCollect(bool on, float y, simple string tf, int len, color lineCol) =>
    if on and showMtfLbl and not na(y)
        bool   mtfDe   = langInp == "Deutsch"
        string tfL     = f_mtfTfLabel(tf)
        string chartL  = f_mtfTfLabel(timeframe.period)
        string nm      = tfL + " · SMA " + str.tostring(len)
        string txt     = mtfLblPrice ? nm + "  " + str.tostring(y, format.mintick) : nm
        string modeTxt = mtfClosed ? (mtfDe ? "nur geschlossene Kerzen (kein Repaint)" : "closed candles only (no repaint)") : (mtfDe ? "live (offene Kerze, kann sich bis Kerzenschluss ändern)" : "live (open candle, may change until it closes)")
        string tip     = ""
        if mtfDe
            tip := "SMA " + str.tostring(len) + " aus der Zeitebene " + tfL + ", nicht aus der Chart-Zeitebene (" + chartL + ").\nWert: " + str.tostring(y, format.mintick) + "\nModus: " + modeTxt
        else
            tip := "SMA " + str.tostring(len) + " from the " + tfL + " timeframe, not from the chart timeframe (" + chartL + ").\nValue: " + str.tostring(y, format.mintick) + "\nMode: " + modeTxt
        mtfBufY.push(y)
        mtfBufTxt.push(txt)
        mtfBufTip.push(tip)
        mtfBufCol.push(lineCol)
        mtfBufKnd.push(0)

if barstate.islast
    while mtfLbls.size() > 0
        label.delete(mtfLbls.pop())
    while mtfConns.size() > 0
        line.delete(mtfConns.pop())
    mtfBufY.clear()
    mtfBufTxt.clear()
    mtfBufTip.clear()
    mtfBufCol.clear()
    mtfBufKnd.clear()
    f_mtfCollect(mtfOn1, mtfVal1, mtfTf1, mtfLen1, cMtf1)
    f_mtfCollect(mtfOn2, mtfVal2, mtfTf2, mtfLen2, cMtf2)
    f_mtfCollect(mtfOn3, mtfVal3, mtfTf3, mtfLen3, cMtf3)
    f_mtfCollect(mtfOn4, mtfVal4, mtfTf4, mtfLen4, cMtf4)
    f_mtfCollect(mtfOn5, mtfVal5, mtfTf5, mtfLen5, cMtf5)
    f_mtfCollect(mtfOn6, mtfVal6, mtfTf6, mtfLen6, cMtf6)
    f_mtfCollect(mtfOn7, mtfVal7, mtfTf7, mtfLen7, cMtf7)
    f_mtfCollect(mtfOn8, mtfVal8, mtfTf8, mtfLen8, cMtf8)
    if showSma and showSmaLbl
        bool   smaDe = langInp == "Deutsch"
        string smaTf = f_mtfTfLabel(timeframe.period)
        f_smaCollect(smaFast, fastLen, smaFastCol, smaTf, smaDe)
        f_smaCollect(smaSlow, slowLen, smaSlowCol, smaTf, smaDe)
    f_pvpCollect(pvpOn1, pvpTf1, pvpCfg1, pvpDPoc1, pvpDVah1, pvpDVal1, pvpPPoc1, pvpPVah1, pvpPVal1)
    f_pvpCollect(pvpOn2, pvpTf2, pvpCfg2, pvpDPoc2, pvpDVah2, pvpDVal2, pvpPPoc2, pvpPVah2, pvpPVal2)
    f_pvpCollect(pvpOn3, pvpTf3, pvpCfg3, pvpDPoc3, pvpDVah3, pvpDVal3, pvpPPoc3, pvpPVah3, pvpPVal3)
    if showBB and showBbLbl and not na(bbBasis)
        bool   bbDe   = langInp == "Deutsch"
        string bbCfg  = bbMaType + " " + str.tostring(bbLen)
        string bbMulT = str.tostring(bbMult)
        if showBbBasis
            f_bbCollect(bbBasis, "BB Basis", cBbBasis, bbDe ? "Basis der Bollinger-Bänder: " + bbCfg + " der Quelle." : "Basis of the Bollinger Bands: " + bbCfg + " of the source.")
        if showBbUpper
            f_bbCollect(bbUpper, bbDe ? "BB Oben" : "BB Upper", cBbUpper, bbDe ? "Oberes Bollinger-Band: Basis (" + bbCfg + ") + " + bbMulT + " × Standardabweichung." : "Upper Bollinger Band: basis (" + bbCfg + ") + " + bbMulT + " × standard deviation.")
        if showBbLower
            f_bbCollect(bbLower, bbDe ? "BB Unten" : "BB Lower", cBbLower, bbDe ? "Unteres Bollinger-Band: Basis (" + bbCfg + ") - " + bbMulT + " × Standardabweichung." : "Lower Bollinger Band: basis (" + bbCfg + ") - " + bbMulT + " × standard deviation.")
    int mtfN = mtfBufY.size()
    if mtfN > 0
        // --- sorted order (highest price first) and minimum distance ---------
        array<int>   mtfOrd  = mtfBufY.sort_indices(order.descending)
        float        mtfTop  = math.max(nz(mtfRefHi, mtfBufY.max()), mtfBufY.max())
        float        mtfBot  = math.min(nz(mtfRefLo, mtfBufY.min()), mtfBufY.min())
        float        mtfGap  = math.max((mtfTop - mtfBot) * mtfGuardPct / 100.0, syminfo.mintick)
        array<float> mtfPosY = array.new<float>(mtfN, 0.0)
        array<int>   mtfPosC = array.new<int>(mtfN, 0)
        for i = 0 to mtfN - 1
            mtfPosY.set(i, mtfBufY.get(mtfOrd.get(i)))

        if mtfGuardMode == CG_VERT and mtfN > 1
            // --- clusters: centre (mean price) + number of labels ------------
            array<float> clCen = array.new<float>()
            array<int>   clCnt = array.new<int>()
            for i = 0 to mtfN - 1
                clCen.push(mtfPosY.get(i))
                clCnt.push(1)
                bool merging = true
                while merging and clCen.size() > 1
                    int   last  = clCen.size() - 1
                    float cenA  = clCen.get(last - 1)
                    int   cntA  = clCnt.get(last - 1)
                    float cenB  = clCen.get(last)
                    int   cntB  = clCnt.get(last)
                    float lowA  = cenA - (cntA - 1) / 2.0 * mtfGap
                    float highB = cenB + (cntB - 1) / 2.0 * mtfGap
                    if lowA - highB < mtfGap
                        clCen.set(last - 1, (cenA * cntA + cenB * cntB) / (cntA + cntB))
                        clCnt.set(last - 1, cntA + cntB)
                        clCen.pop()
                        clCnt.pop()
                    else
                        merging := false
            // --- lay the labels of each cluster out evenly -------------------
            int rank = 0
            for q = 0 to clCen.size() - 1
                float cen = clCen.get(q)
                int   cnt = clCnt.get(q)
                for j = 0 to cnt - 1
                    mtfPosY.set(rank, cen + (cnt - 1) / 2.0 * mtfGap - j * mtfGap)
                    rank += 1
        else if mtfGuardMode == CG_STEP and mtfN > 1
            for i = 1 to mtfN - 1
                if mtfPosY.get(i - 1) - mtfPosY.get(i) < mtfGap
                    mtfPosC.set(i, mtfPosC.get(i - 1) + 1)

        // --- draw ------------------------------------------------------------
        for i = 0 to mtfN - 1
            int   slot   = mtfOrd.get(i)
            float yReal  = mtfBufY.get(slot)
            float yLabel = mtfPosY.get(i)
            bool  moved  = yLabel != yReal or mtfPosC.get(i) > 0
            // style source: Bollinger settings (group 21) or MTF SMA settings (group 22)
            bool   isBb   = mtfBufKnd.get(slot) == 1
            int    xBase  = isBb ? bbLblOffset : mtfLblOffset
            int    xLabel = math.min(bar_index + xBase + mtfPosC.get(i) * mtfGuardCol + (moved ? mtfGuardExtra : 0), bar_index + 490)
            color  lineC  = mtfBufCol.get(slot)
            bool   asPill = (isBb ? bbLblShape : mtfLblShape) == SH_LABEL
            color  bgBase = isBb ? cBbLblBg : cMtfLblBg
            color  bgC    = asPill ? bgBase : color.new(bgBase, 100)
            color  txC    = isBb ? (bbLblBandCol ? lineC : cBbLblTxt) : (mtfLblLineCol ? lineC : cMtfLblTxt)
            string szS    = isBb ? bbLblSize : mtfLblSize
            string ftS    = isBb ? bbLblFont : mtfLblFont
            mtfLbls.push(label.new(xLabel, yLabel, mtfBufTxt.get(slot), xloc = xloc.bar_index, yloc = yloc.price, color = bgC, style = label.style_label_left, textcolor = txC, size = f_size(szS), text_font_family = ftS == FT_MONO ? font.family_monospace : font.family_default, tooltip = mtfBufTip.get(slot)))
            if mtfConnShow and moved and xLabel > bar_index
                mtfConns.push(line.new(bar_index, yReal, xLabel, yLabel, xloc = xloc.bar_index, color = color.new(lineC, 30), style = f_lineStyle(mtfConnStyle), width = mtfConnWidth))

// =============================================================================
// === ALERTS ==================================================================
// =============================================================================
// Alert messages must be constant strings and therefore stay in English.
alertcondition(bullSFU, title = "Bullische SFU / Bullish SFU", message = "Bullish SFU (strong liquidity sweep) on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullFU, title = "Bullische FU / Bullish FU", message = "Bullish FU on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullAFU, title = "Bullische AFU / Bullish AFU", message = "Bullish AFU (attempted) on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearSFU, title = "Bärische SFU / Bearish SFU", message = "Bearish SFU (strong liquidity sweep) on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearFU, title = "Bärische FU / Bearish FU", message = "Bearish FU on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bearAFU, title = "Bärische AFU / Bearish AFU", message = "Bearish AFU (attempted) on {{ticker}} {{interval}} @ {{close}}")
alertcondition(anyBull, title = "Jede bullische FU (SFU / FU / AFU) / Any bullish FU (SFU / FU / AFU)", message = "Bullish FU-type candle on {{ticker}} {{interval}} @ {{close}}")
alertcondition(anyBear, title = "Jede bärische FU (SFU / FU / AFU) / Any bearish FU (SFU / FU / AFU)", message = "Bearish FU-type candle on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bbCrossUp, title = "Schluss kreuzt über das obere Bollinger-Band / Close crosses above upper Bollinger Band", message = "Close crossed above the upper Bollinger Band on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bbCrossDn, title = "Schluss kreuzt unter das untere Bollinger-Band / Close crosses below lower Bollinger Band", message = "Close crossed below the lower Bollinger Band on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullFvg or bearFvg, title = "FU-Kerze hinterlässt FVG / FU candle left an FVG", message = "FU candle confirmed with FVG on {{ticker}} {{interval}}")
````
