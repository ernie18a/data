# Supertrend Dashboard 5 min

- url: https://www.tradingview.com/script/nujrlSM9/
- type: indicator
- pine_id: PUB;f43ae0729bca4eacba802542bbd9fe91
- version: 4.0

## Description

Voici un indicateur qui permet de suivre la supertrend sur 5 min, 15 min et 1H.
Il est couplé avec la VWAP, le RSI ainsi que l'EMA 9 et 21. quand toute les tendances s'alignent une entrée en position se dessine . Un Stop loss sur la supertrend et un RR de 2 s'affiche. 
Bon trade a vous

## Source Code

````pine
//@version=6
indicator('Supertrend Dashboard 5 min', overlay = true)

// ─── Inputs ───────────────────────────────────────────────
atrPeriod = input.int(7, title = 'ATR Period')
multiplier = input.float(2.0, title = 'ATR Multiplier', step = 0.1)
rsiLength = input.int(14, title = 'RSI Length')
rrRatio1 = input.float(1.0, title = 'TP1 Risk:Reward', step = 0.1, group = 'Entrées graphiques')
rrRatio2 = input.float(2.0, title = 'TP2 Risk:Reward', step = 0.1, group = 'Entrées graphiques')
tableSize = input.string('Normal', title = 'Taille du tableau', options = ['Petit', 'Normal', 'Grand'], group = 'Affichage')

txtSize = tableSize == 'Petit' ? size.small : tableSize == 'Grand' ? size.large : size.normal

// ─── Fonctions ────────────────────────────────────────────
f_st_line() =>
    [stLine, _] = ta.supertrend(multiplier, atrPeriod)
    stLine

f_st_dir() =>
    [_, stDir] = ta.supertrend(multiplier, atrPeriod)
    stDir

// ─── Supertrend TF courante ───────────────────────────────
[st, dir] = ta.supertrend(multiplier, atrPeriod)
atr = ta.atr(atrPeriod)

// ─── Supertrend 15min / 1H / 4H ──────────────────────────
st5 = request.security(syminfo.tickerid, '5', f_st_line(), lookahead = barmerge.lookahead_off)
dir5 = request.security(syminfo.tickerid, '5', f_st_dir(), lookahead = barmerge.lookahead_off)
dir15 = request.security(syminfo.tickerid, '15', f_st_dir(), lookahead = barmerge.lookahead_off)
dir1H = request.security(syminfo.tickerid, '60', f_st_dir(), lookahead = barmerge.lookahead_off)

bull5_st = dir5 == -1
bull15_st = dir15 == -1
bull1H_st = dir1H == -1

// ─── Plot Supertrend ──────────────────────────────────────
plot(dir < 0 ? st : na, 'Up Trend', color = color.green, style = plot.style_linebr, linewidth = 2)
plot(dir > 0 ? st : na, 'Down Trend', color = color.red, style = plot.style_linebr, linewidth = 2)

// ─── EMA 9 / EMA 21 ───────────────────────────────────────
ema9_5 = request.security(syminfo.tickerid, '5', ta.ema(close, 9), lookahead = barmerge.lookahead_off)
ema21_5 = request.security(syminfo.tickerid, '5', ta.ema(close, 21), lookahead = barmerge.lookahead_off)
ema9_15 = request.security(syminfo.tickerid, '15', ta.ema(close, 9), lookahead = barmerge.lookahead_off)
ema21_15 = request.security(syminfo.tickerid, '15', ta.ema(close, 21), lookahead = barmerge.lookahead_off)
ema9_1H = request.security(syminfo.tickerid, '60', ta.ema(close, 9), lookahead = barmerge.lookahead_off)
ema21_1H = request.security(syminfo.tickerid, '60', ta.ema(close, 21), lookahead = barmerge.lookahead_off)

bull5_ema = ema9_5 > ema21_5
bull15_ema = ema9_15 > ema21_15
bull1H_ema = ema9_1H > ema21_1H

// ─── VWAP ─────────────────────────────────────────────────
vwap5 = request.security(syminfo.tickerid, '5', ta.vwap(hlc3), lookahead = barmerge.lookahead_off)
vwap15 = request.security(syminfo.tickerid, '15', ta.vwap(hlc3), lookahead = barmerge.lookahead_off)
vwap1H = request.security(syminfo.tickerid, '60', ta.vwap(hlc3), lookahead = barmerge.lookahead_off)
close5 = request.security(syminfo.tickerid, '5', close, lookahead = barmerge.lookahead_off)
close15 = request.security(syminfo.tickerid, '15', close, lookahead = barmerge.lookahead_off)
close1H = request.security(syminfo.tickerid, '60', close, lookahead = barmerge.lookahead_off)

bull5_vwap = close5 > vwap5
bull15_vwap = close15 > vwap15
bull1H_vwap = close1H > vwap1H

// ─── RSI ──────────────────────────────────────────────────
rsi5 = request.security(syminfo.tickerid, '5', ta.rsi(close, rsiLength), lookahead = barmerge.lookahead_off)
rsi15 = request.security(syminfo.tickerid, '15', ta.rsi(close, rsiLength), lookahead = barmerge.lookahead_off)
rsi1H = request.security(syminfo.tickerid, '60', ta.rsi(close, rsiLength), lookahead = barmerge.lookahead_off)

rsiLabel(r) =>
    r >= 70 ? '⚠ Surachat' : r <= 30 ? '⚠ Survente' : r >= 50 ? '▲ Haussier' : '▼ Baissier'

rsiBgColor(r) =>
    r >= 70 ? color.new(color.orange, 20) : r <= 30 ? color.new(color.purple, 20) : r >= 50 ? color.new(color.green, 20) : color.new(color.red, 20)

// ─── SCORING (basé sur 15min et 1H uniquement) ────────────
stAligned = bull5_st == bull15_st
bullTrend = bull15_st

score5_ema = stAligned ? bullTrend ? bull5_ema ? 1 : 0 : not bull5_ema ? 1 : 0 : 0
score5_vwap = stAligned ? bullTrend ? bull5_vwap ? 1 : 0 : not bull5_vwap ? 1 : 0 : 0
rsi5_ok = bullTrend ? rsi5 < 70 : rsi5 > 30
score5_rsi = stAligned ? rsi5_ok ? 1 : 0 : 0

totalScore = score5_ema + score5_vwap + score5_rsi
stars = totalScore

starsLabel(n) =>
    n == 3 ? '★★★' : n == 2 ? '★★☆' : n == 1 ? '★☆☆' : '☆☆☆'

starsBgColor(n) =>
    n == 3 ? color.new(color.green, 0) : n == 2 ? color.new(color.green, 30) : n == 1 ? color.new(color.orange, 20) : color.new(color.red, 20)

signalLabel = not stAligned ? '🔴 ST NON ALIGNEES' : stars == 3 ? '🟢 TOP SETUP' : stars == 2 ? '🟢 Bon setup' : stars == 1 ? '🟡 ATTENDRE' : '🔴 NE PAS ENTRER'
signalBg = not stAligned ? color.new(color.red, 0) : stars == 3 ? color.new(color.green, 0) : stars == 2 ? color.new(color.green, 30) : stars == 1 ? color.new(color.orange, 20) : color.new(color.red, 20)

// ─── SIGNAUX D'ENTREE ─────────────────────────────────────
goodSetup  = stAligned and stars >= 2
stFlipBull = dir[1] > 0 and dir < 0
stFlipBear = dir[1] < 0 and dir > 0
anyFlip    = stFlipBull or stFlipBear

var bool waitingBuy  = false
var bool waitingSell = false
var bool positionOn  = false
var bool alertSent   = false

var line  entry_line = na
var line  sl_line    = na
var line  tp1_line   = na
var line  tp2_line   = na
var box   tp1_box    = na
var box   tp2_box    = na
var box   sl_box     = na
var label entry_lbl  = na
var label sl_lbl     = na
var label tp1_lbl    = na
var label tp2_lbl    = na

// Flip → reset tout + nouvelle attente
if anyFlip
    line.delete(entry_line)
    line.delete(sl_line)
    line.delete(tp1_line)
    line.delete(tp2_line)
    box.delete(tp1_box)
    box.delete(tp2_box)
    box.delete(sl_box)
    label.delete(entry_lbl)
    label.delete(sl_lbl)
    label.delete(tp1_lbl)
    label.delete(tp2_lbl)
    entry_line  := na
    sl_line     := na
    tp1_line    := na
    tp2_line    := na
    tp1_box     := na
    tp2_box     := na
    sl_box      := na
    entry_lbl   := na
    sl_lbl      := na
    tp1_lbl     := na
    tp2_lbl     := na
    positionOn  := false
    alertSent   := false
    waitingBuy  := stFlipBull
    waitingSell := stFlipBear

// Trigger alerte : sur clôture de bougie confirmée
triggerBuyAlert  = waitingBuy  and goodSetup and not positionOn and barstate.isconfirmed
triggerSellAlert = waitingSell and goodSetup and not positionOn and barstate.isconfirmed

// Trigger dessin : bougie confirmée OU bougie suivante si alerte déjà envoyée
triggerBuy  = waitingBuy  and goodSetup and not positionOn and (barstate.isconfirmed or (alertSent and not positionOn))
triggerSell = waitingSell and goodSetup and not positionOn and (barstate.isconfirmed or (alertSent and not positionOn))

if triggerBuyAlert or triggerSellAlert
    waitingBuy  := false
    waitingSell := false
    positionOn  := true
    alertSent   := true

// ─── BUY ──────────────────────────────────────────────────
if triggerBuy
    entryPrice = open   // ouverture de la bougie — prix fixe et identique à chaque replay
    slPrice    = st
    risk       = math.abs(entryPrice - slPrice)
    tp1Price   = entryPrice + risk * rrRatio1
    tp2Price   = entryPrice + risk * rrRatio2
    entry_line := line.new(bar_index, entryPrice, bar_index, entryPrice, color = color.green, width = 2)
    sl_line := line.new(bar_index, slPrice, bar_index, slPrice, color = color.red, width = 2)
    tp1_line := line.new(bar_index, tp1Price, bar_index, tp1Price, color = color.blue, width = 1, style = line.style_dashed)
    tp2_line := line.new(bar_index, tp2Price, bar_index, tp2Price, color = color.blue, width = 2)

    tp2_box := box.new(bar_index, tp2Price, bar_index, tp1Price, bgcolor = color.new(color.green, 75), border_color = color.new(color.green, 50))
    tp1_box := box.new(bar_index, tp1Price, bar_index, entryPrice, bgcolor = color.new(color.green, 88), border_color = color.new(color.green, 60))
    sl_box := box.new(bar_index, entryPrice, bar_index, slPrice, bgcolor = color.new(color.red, 85), border_color = color.red)

    entry_lbl := label.new(bar_index, entryPrice, 'ENTRY\n' + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = color.new(color.green, 70), textcolor = color.white)
    sl_lbl := label.new(bar_index, slPrice, 'SL\n' + str.tostring(slPrice, format.mintick), style = label.style_label_left, color = color.new(color.red, 70), textcolor = color.white)
    tp1_lbl := label.new(bar_index, tp1Price, 'TP1 ' + str.tostring(rrRatio1) + 'R\n' + str.tostring(tp1Price, format.mintick), style = label.style_label_left, color = color.new(color.blue, 60), textcolor = color.white)
    tp2_lbl := label.new(bar_index, tp2Price, 'TP2 ' + str.tostring(rrRatio2) + 'R\n' + str.tostring(tp2Price, format.mintick), style = label.style_label_left, color = color.new(color.blue, 40), textcolor = color.white)
    tp2_lbl

// ─── SELL ─────────────────────────────────────────────────
if triggerSell
    entryPrice = open   // ouverture de la bougie — prix fixe et identique à chaque replay
    slPrice    = st
    risk       = math.abs(entryPrice - slPrice)
    tp1Price   = entryPrice - risk * rrRatio1
    tp2Price   = entryPrice - risk * rrRatio2
    entry_line := line.new(bar_index, entryPrice, bar_index, entryPrice, color = color.green, width = 2)
    sl_line := line.new(bar_index, slPrice, bar_index, slPrice, color = color.red, width = 2)
    tp1_line := line.new(bar_index, tp1Price, bar_index, tp1Price, color = color.blue, width = 1, style = line.style_dashed)
    tp2_line := line.new(bar_index, tp2Price, bar_index, tp2Price, color = color.blue, width = 2)

    tp2_box := box.new(bar_index, tp1Price, bar_index, tp2Price, bgcolor = color.new(color.green, 75), border_color = color.new(color.green, 50))
    tp1_box := box.new(bar_index, entryPrice, bar_index, tp1Price, bgcolor = color.new(color.green, 88), border_color = color.new(color.green, 60))
    sl_box := box.new(bar_index, slPrice, bar_index, entryPrice, bgcolor = color.new(color.red, 85), border_color = color.red)

    entry_lbl := label.new(bar_index, entryPrice, 'ENTRY\n' + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = color.new(color.green, 70), textcolor = color.white)
    sl_lbl := label.new(bar_index, slPrice, 'SL\n' + str.tostring(slPrice, format.mintick), style = label.style_label_left, color = color.new(color.red, 70), textcolor = color.white)
    tp1_lbl := label.new(bar_index, tp1Price, 'TP1 ' + str.tostring(rrRatio1) + 'R\n' + str.tostring(tp1Price, format.mintick), style = label.style_label_left, color = color.new(color.blue, 60), textcolor = color.white)
    tp2_lbl := label.new(bar_index, tp2Price, 'TP2 ' + str.tostring(rrRatio2) + 'R\n' + str.tostring(tp2Price, format.mintick), style = label.style_label_left, color = color.new(color.blue, 40), textcolor = color.white)
    tp2_lbl

// ─── Extension des lignes ─────────────────────────────────
if not na(entry_line)
    line.set_x2(entry_line, bar_index)
    label.set_x(entry_lbl, bar_index)
if not na(sl_line)
    line.set_x2(sl_line, bar_index)
    label.set_x(sl_lbl, bar_index)
if not na(tp1_line)
    line.set_x2(tp1_line, bar_index)
    label.set_x(tp1_lbl, bar_index)
if not na(tp2_line)
    line.set_x2(tp2_line, bar_index)
    label.set_x(tp2_lbl, bar_index)
if not na(tp1_box)
    box.set_right(tp1_box, bar_index)
if not na(tp2_box)
    box.set_right(tp2_box, bar_index)
if not na(sl_box)
    box.set_right(sl_box, bar_index)

/// ─── ALERTES ──────────────────────────────────────────────
alertcondition(triggerBuyAlert,  title="🟢 LONG",  message="🟢 LONG sur {{ticker}} [{{interval}}]\nENTRY : {{close}}")
alertcondition(triggerSellAlert, title="🔴 SHORT", message="🔴 SHORT sur {{ticker}} [{{interval}}]\nENTRY : {{close}}")
alertcondition(triggerBuyAlert or triggerSellAlert, title="⚡ Entrée Long ou Short", message="⚡ ENTRÉE sur {{ticker}} [{{interval}}]\nENTRY : {{close}}")

// ─── Tableau visuel (4 colonnes : 15min / 1H / 4H) ────────
var table dash = table.new(position.top_right, 4, 7, border_width = 1, border_color = color.gray, frame_width = 1, frame_color = color.gray)

table.cell(dash, 0, 0, '', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 0, '5 min', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 0, '15 min', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 3, 0, '1 H ℹ', bgcolor = color.new(color.gray, 40), text_color = color.new(color.gray, 20), text_size = txtSize)

table.cell(dash, 0, 1, 'Supertrend', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 1, bull5_st ? '▲ Haussier' : '▼ Baissier', bgcolor = bull5_st ? color.new(color.green, 20) : color.new(color.red, 20), text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 1, bull15_st ? '▲ Haussier' : '▼ Baissier', bgcolor = bull15_st ? color.new(color.green, 20) : color.new(color.red, 20), text_color = color.white, text_size = txtSize)
table.cell(dash, 3, 1, bull1H_st ? '▲ Haussier' : '▼ Baissier', bgcolor = bull1H_st ? color.new(color.green, 40) : color.new(color.red, 40), text_color = color.white, text_size = txtSize)

table.cell(dash, 0, 2, 'EMA 9/21', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 2, bull5_ema ? '▲ Achat' : '▼ Vente', bgcolor = bull5_ema ? color.new(color.green, 20) : color.new(color.red, 20), text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 2, bull15_ema ? '▲ Achat' : '▼ Vente', bgcolor = bull15_ema ? color.new(color.green, 20) : color.new(color.red, 20), text_color = color.white, text_size = txtSize)
table.cell(dash, 3, 2, bull1H_ema ? '▲ Achat' : '▼ Vente', bgcolor = bull1H_ema ? color.new(color.green, 40) : color.new(color.red, 40), text_color = color.white, text_size = txtSize)

table.cell(dash, 0, 3, 'VWAP', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 3, bull5_vwap ? '▲ Achat' : '▼ Vente', bgcolor = bull5_vwap ? color.new(color.green, 20) : color.new(color.red, 20), text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 3, bull15_vwap ? '▲ Achat' : '▼ Vente', bgcolor = bull15_vwap ? color.new(color.green, 20) : color.new(color.red, 20), text_color = color.white, text_size = txtSize)
table.cell(dash, 3, 3, bull1H_vwap ? '▲ Achat' : '▼ Vente', bgcolor = bull1H_vwap ? color.new(color.green, 40) : color.new(color.red, 40), text_color = color.white, text_size = txtSize)

table.cell(dash, 0, 4, 'RSI(' + str.tostring(rsiLength) + ')', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 4, rsiLabel(rsi5), bgcolor = rsiBgColor(rsi5), text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 4, rsiLabel(rsi15), bgcolor = rsiBgColor(rsi15), text_color = color.white, text_size = txtSize)
table.cell(dash, 3, 4, rsiLabel(rsi1H), bgcolor = rsiBgColor(rsi1H), text_color = color.white, text_size = txtSize)

table.cell(dash, 0, 5, 'Score', bgcolor = color.new(color.gray, 60), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 5, not stAligned ? '⛔ N/A' : starsLabel(stars), bgcolor = not stAligned ? color.new(color.red, 0) : starsBgColor(stars), text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 5, not stAligned ? 'ST non alignées' : str.tostring(totalScore) + '/3 critères', bgcolor = not stAligned ? color.new(color.red, 0) : starsBgColor(stars), text_color = color.white, text_size = txtSize)
table.cell(dash, 3, 5, 'Info seule', bgcolor = color.new(color.gray, 40), text_color = color.new(color.gray, 20), text_size = txtSize)

table.cell(dash, 0, 6, 'SIGNAL', bgcolor = color.new(color.gray, 40), text_color = color.white, text_size = txtSize)
table.cell(dash, 1, 6, signalLabel, bgcolor = signalBg, text_color = color.white, text_size = txtSize)
table.cell(dash, 2, 6, '', bgcolor = signalBg)
table.cell(dash, 3, 6, '', bgcolor = color.new(color.gray, 40))
````
