<!-- tradingview-pine-id: PUB;a43d3150d1954fe6819e1c1624334936 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# LoD Split Exit & Position Sizer

Source: https://www.tradingview.com/script/hnlztnxl/

## Description

LoD Split Exit & Position Sizer
This indicator helps swing and momentum traders plan trades around the current day's Low of Day (LoD). It draws a staged (scaled) stop-loss plan, a take-profit target based on your risk unit (R), and calculates the maximum position size that keeps your total risk within a defined percentage of your account.

What it does
The core idea is to treat the distance from your entry price down to the Low of Day as your risk unit, or "R". Everything else — the staged stops, the take-profit target, and the position size — is derived from this single risk measurement.

The indicator lets you exit a losing position in three stages rather than all at once. By default it plots stop levels at 33%, 66%, and 100% of the way down from your entry to the LoD, but all three levels are fully adjustable. Assuming you close one third of the position at each stage, the average (effective) loss works out to roughly 0.66R with the default settings, which the indicator uses in its position-sizing math.

Main features
Entry Price Mode. You can choose between two modes. In Auto (current price) mode, the default, the indicator pulls the live chart price as your entry. In Manual (actual fill price) mode, you type in the exact price at which you were filled, so the lines reflect your real trade rather than the current market price. If the manual field is left at zero, it safely falls back to the current price.

Staged stop-loss levels. Three configurable exit levels (default 33 / 66 / 100 percent of the entry-to-LoD range) are drawn as horizontal lines with price labels. The 100% level sits exactly at the Low of Day.

Take-profit line. A target line is plotted at a chosen R multiple above your entry (default 2R). You can toggle it on or off and change the multiple.

Position sizing (percentage). Based on your account size and your maximum allowed risk per position (default 0.3%), the indicator computes the largest position you can hold while keeping the effective staged loss within that risk limit. The result is shown as a percentage of your account, so you instantly see how much of your capital the trade should represent.

Customizable table. A summary table shows the take-profit price, entry price (labeled Auto or Manual), the LoD, the risk width, each stop price, the effective loss factor, and the maximum position percentage. The table can be placed in any of six positions — top left, top center, top right, bottom left, bottom center, or bottom right — and its text color, size, and background are adjustable.

How the position size is calculated
The maximum dollar risk is your account size multiplied by your risk percentage. The effective loss per share is the risk width (entry minus LoD) multiplied by the average of your three stop levels. Dividing the maximum dollar risk by the effective loss per share gives the maximum number of shares, which is then expressed as a percentage of your account value.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator(title='LoD Split Exit & Position Sizer', shorttitle='LoD Split + PosSize', overlay=true)

// ==================== Inputs ====================
grpEntry   = 'Entry / Risk Settings'
entryMode  = input.string('Auto (current price)', title='Entry Price Mode',
     options=['Auto (current price)', 'Manual (actual fill price)'], group=grpEntry,
     tooltip='Auto: チャートの現在価格を自動取得 / Manual: 実際にエントリーした価格を下の欄に入力')
entryManual= input.float(0.0, title='Manual Entry Price ($)', group=grpEntry, minval=0.0,
     tooltip='Entry Price Mode が Manual のとき、実際に約定した価格を入力してください')

grpSplit   = 'Split Levels (% of Entry→LoD)'
lvl1       = input.float(33,  title='Level 1 (%)', group=grpSplit, minval=0.0, maxval=100.0, step=1)
lvl2       = input.float(66,  title='Level 2 (%)', group=grpSplit, minval=0.0, maxval=100.0, step=1)
lvl3       = input.float(100, title='Level 3 (%)', group=grpSplit, minval=0.0, maxval=100.0, step=1)

grpTP      = 'Take Profit'
showTP     = input.bool(true, title='Show Take Profit line', group=grpTP)
tpR        = input.float(2.0, title='Take Profit (R multiple)', group=grpTP, minval=0.1, step=0.1)

grpAcct    = 'Account / Risk'
acctSize   = input.float(100000, title='Account Size ($)', group=grpAcct, minval=0.0)
riskPct    = input.float(0.3, title='Max Risk per Position (%)', group=grpAcct, minval=0.01, step=0.05)

grpTbl     = 'Table'
txt_col    = input(color.orange, title='Text Color', group=grpTbl)
posTable   = input.string(defval='Bottom Right', title='Table Position',
     options=['Top Left', 'Top Center', 'Top Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=grpTbl)
tbl_size   = input.string('Normal', title='Table Size', options=['Tiny', 'Small', 'Normal', 'Large'], group=grpTbl)
bg_col     = input(#00000000, title='Background Color', group=grpTbl)

grpLine    = 'Chart Lines'
showLines  = input.bool(true, title='Show LoD split price lines', group=grpLine)
col1       = input(color.new(color.green, 0),  title='Level 1 line color', group=grpLine)
col2       = input(color.new(color.orange, 0), title='Level 2 line color', group=grpLine)
col3       = input(color.new(color.red, 0),    title='Level 3 line color', group=grpLine)
colTP      = input(color.new(color.blue, 0),   title='Take Profit line color', group=grpLine)
colEntry   = input(color.new(color.gray, 0),   title='Entry line color', group=grpLine)

// ==================== Switches ====================
tablePos = switch posTable
    'Top Left'      => position.top_left
    'Top Center'    => position.top_center
    'Top Right'     => position.top_right
    'Bottom Left'   => position.bottom_left
    'Bottom Center' => position.bottom_center
    'Bottom Right'  => position.bottom_right

size_tbl = switch tbl_size
    'Normal' => size.normal
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Large'  => size.large

// ==================== Core calculation ====================
// LoD = 当日の安値 (Low of Day)
lod   = request.security(syminfo.tickerid, 'D', low)

// エントリー価格の決定
isManual = entryMode == 'Manual (actual fill price)'
entry    = isManual and entryManual > 0 ? entryManual : close

// エントリーからLoDまでの下落幅（リスク幅 R）
R = entry - lod

// 各分割損切り価格 (エントリーから lvl% 下落した水準)
f1 = lvl1 / 100.0
f2 = lvl2 / 100.0
f3 = lvl3 / 100.0
price1 = entry - R * f1
price2 = entry - R * f2
price3 = entry - R * f3

// 利益確定価格 (エントリーから R * tpR 上)
priceTP = entry + R * tpR

// ==================== 実効損失係数（設定した3段階の平均） ====================
// 各段階で建玉の1/3ずつ損切りする想定
//   平均損失係数 = (f1 + f2 + f3) / 3
effLossFactor   = (f1 + f2 + f3) / 3.0
effLossPerShare = R * effLossFactor        // 1株あたりの実効損失($)

// ==================== ポジションサイズ計算（割合のみ） ====================
maxRiskDollar = acctSize * (riskPct / 100.0)             // 許容損失額($)
maxShares     = effLossPerShare > 0 ? maxRiskDollar / effLossPerShare : 0.0
maxSharesFloor= math.floor(maxShares)                    // 端数切り捨て
positionValue = maxSharesFloor * entry                   // 建玉評価額($)
positionPct   = acctSize > 0 ? positionValue / acctSize * 100.0 : 0.0  // 建玉が口座資金の何%か

// ==================== Chart lines ====================
var line ln1   = na
var line ln2   = na
var line ln3   = na
var line lnTP  = na
var line lnEnt = na
var label lb1  = na
var label lb2  = na
var label lb3  = na
var label lbTP = na
var label lbEnt= na

if showLines and barstate.islast
    line.delete(ln1)
    line.delete(ln2)
    line.delete(ln3)
    line.delete(lnEnt)
    label.delete(lb1)
    label.delete(lb2)
    label.delete(lb3)
    label.delete(lbEnt)
    x1 = bar_index - 30
    x2 = bar_index + 10
    // エントリーライン
    lnEnt := line.new(x1, entry, x2, entry, color=colEntry, width=1, style=line.style_dotted)
    lbEnt := label.new(x2, entry, 'Entry  ' + str.tostring(entry, format.mintick), style=label.style_label_left, color=color.new(colEntry,80), textcolor=colEntry, size=size.small)
    // 分割損切りライン
    ln1 := line.new(x1, price1, x2, price1, color=col1, width=1, style=line.style_dashed)
    ln2 := line.new(x1, price2, x2, price2, color=col2, width=1, style=line.style_dashed)
    ln3 := line.new(x1, price3, x2, price3, color=col3, width=2, style=line.style_solid)
    lb1 := label.new(x2, price1, str.tostring(lvl1, '0') + '%  ' + str.tostring(price1, format.mintick), style=label.style_label_left, color=color.new(col1,80), textcolor=col1, size=size.small)
    lb2 := label.new(x2, price2, str.tostring(lvl2, '0') + '%  ' + str.tostring(price2, format.mintick), style=label.style_label_left, color=color.new(col2,80), textcolor=col2, size=size.small)
    lb3 := label.new(x2, price3, str.tostring(lvl3, '0') + '%  ' + str.tostring(price3, format.mintick), style=label.style_label_left, color=color.new(col3,80), textcolor=col3, size=size.small)

// 利益確定ライン
if showTP and barstate.islast
    line.delete(lnTP)
    label.delete(lbTP)
    x1t = bar_index - 30
    x2t = bar_index + 10
    lnTP := line.new(x1t, priceTP, x2t, priceTP, color=colTP, width=2, style=line.style_solid)
    lbTP := label.new(x2t, priceTP, str.tostring(tpR, '0.0') + 'R  ' + str.tostring(priceTP, format.mintick), style=label.style_label_left, color=color.new(colTP,80), textcolor=colTP, size=size.small)

// ==================== Table ====================
table t = table.new(tablePos, 2, 13, bgcolor=bg_col)
if barstate.islast
    table.cell(t, 0, 0, 'Take Profit (' + str.tostring(tpR, '0.0') + 'R)', text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 0, str.tostring(priceTP, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 1, 'Entry Price' + (isManual ? ' (Manual)' : ' (Auto)'), text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 1, str.tostring(entry, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 2, 'LoD',                    text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 2, str.tostring(lod, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 3, 'Risk Width (Entry-LoD)', text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 3, str.tostring(R, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 4, str.tostring(lvl1, '0') + '% Stop Price', text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 4, str.tostring(price1, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 5, str.tostring(lvl2, '0') + '% Stop Price', text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 5, str.tostring(price2, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 6, str.tostring(lvl3, '0') + '% Stop Price', text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 6, str.tostring(price3, format.mintick), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 7, '— Position Sizing —',    text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 7, '',                       text_color=txt_col, text_size=size_tbl)

    table.cell(t, 0, 8, 'Eff. Loss Factor',       text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 8, str.tostring(effLossFactor, '0.000'), text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)

    table.cell(t, 0, 9, 'Max Position (% of Acct)', text_color=txt_col, text_size=size_tbl, text_halign=text.align_left)
    table.cell(t, 1, 9, str.tostring(positionPct, '0.00') + '%', text_color=txt_col, text_size=size_tbl, text_halign=text.align_right)
````
