# Watermark [Y.Algo]

- url: https://www.tradingview.com/script/3xxZgUGr/
- type: indicator
- pine_id: PUB;80865d3456dc42a894c848fbc3620cb5
- version: 1.0

## Description

Watermark — Overlay Dynamic Branding & Live Market Data on Your Charts

Place a title, subtitle, textbox, and LOGO anywhere on your chart. Text content supports automatic keyword substitution — instantly displaying symbol, timeframe, close price, date, time, and more. Perfect for trade screenshots, strategy showcases, and channel branding.

[b]🔶 USAGE[/b]

The most common use case is attaching full trade context to shared screenshots. Set your title to a channel or strategy name, then type keywords like Ticker | TF | Date into the textbox — the indicator replaces them automatically with the current symbol, timeframe, and date, so every screenshot carries complete context without manual editing.

In multi-chart layouts, each chart can have its own textbox content. For example, add the Ticker2 keyword to a BTC chart to simultaneously track another asset's live close price, supporting cross-market comparisons without switching windows.

All three text blocks (title, subtitle, textbox) have independent position settings and can be spread across the chart corners or grouped in one area. Pair with transparency adjustments to keep the watermark unobtrusive while your technical analysis remains the focus.

[b]🔹 Dynamic Keyword Substitution[/b]

The textbox supports 11 live keywords: TF (timeframe), Ticker (current symbol), Ticker2 (extra symbol close price), Volume, Open, Close, High, Low, Day, Date, and Time. Type any keyword directly into the textbox and it updates automatically on every bar — no manual maintenance required.

[b]🔹 Three Independent Layout Blocks[/b]

The title and subtitle share one set of position controls (vertical: top / middle / bottom; horizontal: left / center / right). The textbox has its own fully independent position settings, so you can place the title at the top center while pinning the info box to the bottom left. Font size (tiny to huge) and color are individually adjustable for each block.

[b]🔹 LOGO Display[/b]

Optionally enable the built-in ASCII art LOGO with its own position, color, and size controls. A monospace font ensures the pattern stays aligned regardless of chart size. The LOGO block positions independently and does not affect other text blocks.

[b]🔶 DETAILS[/b]

The indicator uses three separate table objects — one for the title/subtitle block, one for the textbox, and one for the LOGO — each freely positioned within the chart's nine-point grid without interfering with one another. Keyword substitution runs on the last tick of each bar; time values apply UTC offset to ensure the displayed time matches the user's local timezone.

The extra symbol (Ticker2) fetches its close price via a cross-ticker security request, letting you monitor another market in real time directly on the current chart.

[b]🔶 SETTINGS[/b]

[b]🔹 Text Settings[/b]
[list]
[*][b]Title[/b]: Main text displayed in the title block; supports keyword substitution
[*][b]Subtitle[/b]: Supplementary text shown below the title; supports keyword substitution
[*][b]Textbox[/b]: Content for the independent textbox block; supports all 11 live keywords
[/list]

[b]🔹 Time Adjustment[/b]
[list]
[*][b]UTC Offset[/b]: Shift displayed time to your local timezone (e.g. UTC+8 for CST)
[/list]

[b]🔹 Time Formatting[/b]
[list]
[*][b]Format - Day[/b]: Customize the display format for the Day keyword
[*][b]Format - Date[/b]: Customize the display format for the Date keyword (default MM/dd/yyyy)
[*][b]Format - Time[/b]: Choose 12-hour (with AM/PM) or 24-hour format
[/list]

[b]🔹 Title and Subtitle Position[/b]
[list]
[*][b]Title & Subtitle Vertical Position[/b]: top / middle / bottom
[*][b]Title & Subtitle Horizontal Position[/b]: left / center / right
[/list]

[b]🔹 Textbox Position[/b]
[list]
[*][b]Textbox Vertical Position[/b]: top / middle / bottom
[*][b]Textbox Horizontal Position[/b]: left / center / right
[/list]

[b]🔹 Logo Settings[/b]
[list]
[*][b]Show Logo[/b]: Toggle LOGO visibility on or off
[*][b]LOGO Vertical Position[/b]: top / middle / bottom
[*][b]LOGO Horizontal Position[/b]: left / center / right
[*][b]LOGO Color[/b]: Set LOGO color including opacity
[*][b]LOGO Size[/b]: tiny / small / normal / large / huge / auto
[/list]

[b]🔹 Title Style[/b]
[list]
[*][b]Title Color[/b]: Set title text color including opacity
[*][b]Title Size[/b]: tiny / small / normal / large / huge / auto
[/list]

[b]🔹 Subtitle Style[/b]
[list]
[*][b]Subtitle Color[/b]: Set subtitle text color including opacity
[*][b]Subtitle Size[/b]: tiny / small / normal / large / huge / auto
[/list]

[b]🔹 Textbox Style[/b]
[list]
[*][b]Textbox Color[/b]: Set textbox text color including opacity
[*][b]Textbox Size[/b]: tiny / small / normal / large / huge / auto
[/list]

[b]🔹 Background Settings[/b]
[list]
[*][b]Background Color[/b]: Set background color for all text blocks (fully transparent by default)
[/list]

[b]🔹 Extra Ticker[/b]
[list]
[*][b]Extra Ticker[/b]: The symbol mapped to the Ticker2 keyword (default: BTCUSDTPERP)
[/list]

[b]🔶 DISCLAIMER[/b]

This indicator and all signals, labels, or alerts it produces are intended solely for technical analysis study and research. They do not constitute investment advice, financial advice, trading recommendations, or any solicitation to buy or sell. Trading financial markets involves substantial risk; you may lose part or all of your capital. Past performance does not guarantee future results. All trading decisions made using this indicator are the sole responsibility of the user. The author and publishing platform accept no liability. Please ensure you fully understand market rules and your own risk tolerance, and consult a qualified financial adviser if necessary.

━━━━━━━━━━━━━━
中文版本 CHINESE VERSION
━━━━━━━━━━━━━━

Watermark | 浮水印 — 在圖表上疊加動態品牌標識與即時市場資訊

將標題、副標題、文字框與 LOGO 靈活擺放於圖表任意位置，文字內容支援關鍵字自動替換，即時顯示標的、時框、收盤價、日期時間等交易資訊，適合交易截圖、策略展示與頻道品牌建立。

[b]🔶 USAGE[/b]

浮水印最常見的用途是在分享截圖時附帶完整交易情境資訊。將標題設為頻道或策略名稱，文字框輸入 Ticker | TF | Date，指標會自動將這些關鍵字替換為當前標的、時框與日期，讓每張截圖都清楚標示上下文。

在多圖表佈局中，可為各圖表分別設定不同的文字框內容。例如在 BTC 圖上加入 Ticker2 關鍵字，即可同步追蹤另一個標的的即時收盤價，輔助跨市場比對。

三個文字區塊（標題、副標題、文字框）各自擁有獨立的位置設定，可分散於圖表四角或集中於特定區域，搭配透明度調整，在不干擾技術分析的前提下達到最佳視覺效果。

[b]🔹 動態關鍵字替換[/b]

文字框支援 11 個即時關鍵字：TF（時間週期）、Ticker（當前標的）、Ticker2（額外標的收盤價）、Volume（成交量）、Open（開盤價）、Close（收盤價）、High（最高價）、Low（最低價）、Day（星期）、Date（日期）、Time（時間）。將關鍵字直接輸入文字框，每根 K 棒自動更新為最新數值，無需手動修改。

[b]🔹 三區塊獨立佈局[/b]

標題與副標題共用一組位置設定，可置於圖表頂部、中央或底部，並從左、中、右三個水平位置選擇。文字框擁有完全獨立的位置設定，可與標題區塊分開擺放，例如標題置頂居中、資訊文字框固定於左下角。每個區塊的字體大小（tiny 至 huge）與顏色均可單獨調整。

[b]🔹 LOGO 展示[/b]

可選擇開啟內建 ASCII 藝術 LOGO，同樣支援位置、顏色與大小自訂，使用等寬字體確保圖案對齊不變形。LOGO 區塊擁有獨立定位，不受其他文字區塊影響。

[b]🔶 DETAILS[/b]

本指標透過三張獨立表格分別對應標題副標題區塊、文字框區塊與 LOGO 區塊，各自可自由定位於圖表九宮格的任意格點，互不干擾版面配置。關鍵字替換於每根 K 棒最後一筆更新，時間計算支援 UTC 偏移，確保顯示時間符合使用者所在時區。

額外標的（Ticker2）透過跨標的數據請求即時取得收盤價，讓你在當前圖表上同步追蹤另一個市場的動態而無需切換視窗。

[b]🔶 SETTINGS[/b]

[b]🔹 文字設定 / Text Settings[/b]
[list]
[*][b]標題 / Title[/b]：顯示於標題區塊的主要文字，支援關鍵字替換
[*][b]副標題 / Subtitle[/b]：顯示於標題下方的補充文字，支援關鍵字替換
[*][b]文字框 / Textbox[/b]：獨立區塊的文字內容，支援所有 11 個即時關鍵字
[/list]

[b]🔹 時間調整 / Time Adjustment[/b]
[list]
[*][b]UTC 偏移 / UTC Offset[/b]：調整時間顯示至本地時區，台灣用戶設為 +8
[/list]

[b]🔹 時間格式 / Time Formatting[/b]
[list]
[*][b]格式化 - 星期[/b]：自訂 Day 關鍵字的星期顯示格式
[*][b]格式化 - 日期[/b]：自訂 Date 關鍵字的日期顯示格式（預設 MM/dd/yyyy）
[*][b]格式化 - 時間[/b]：選擇 12 小時制（含 AM/PM）或 24 小時制
[/list]

[b]🔹 標題與副標題位置 / Title and Subtitle Position[/b]
[list]
[*][b]標題與副標題垂直位置[/b]：top / middle / bottom
[*][b]標題與副標題水平位置[/b]：left / center / right
[/list]

[b]🔹 文字框位置 / Textbox Position[/b]
[list]
[*][b]文字框垂直位置[/b]：top / middle / bottom
[*][b]文字框水平位置[/b]：left / center / right
[/list]

[b]🔹 LOGO 設定 / Logo Settings[/b]
[list]
[*][b]顯示 LOGO / Show Logo[/b]：開啟或關閉 LOGO 顯示
[*][b]LOGO 垂直位置[/b]：top / middle / bottom
[*][b]LOGO 水平位置[/b]：left / center / right
[*][b]LOGO 顏色[/b]：自訂 LOGO 圖案顏色（含透明度）
[*][b]LOGO 大小[/b]：tiny / small / normal / large / huge / auto
[/list]

[b]🔹 標題樣式 / Title Style[/b]
[list]
[*][b]標題顏色[/b]：自訂標題文字顏色（含透明度）
[*][b]標題大小[/b]：tiny / small / normal / large / huge / auto
[/list]

[b]🔹 副標題樣式 / Subtitle Style[/b]
[list]
[*][b]副標題顏色[/b]：自訂副標題文字顏色（含透明度）
[*][b]副標題大小[/b]：tiny / small / normal / large / huge / auto
[/list]

[b]🔹 文字框樣式 / Textbox Style[/b]
[list]
[*][b]文字框顏色[/b]：自訂文字框文字顏色（含透明度）
[*][b]文字框大小[/b]：tiny / small / normal / large / huge / auto
[/list]

[b]🔹 背景設定 / Background Settings[/b]
[list]
[*][b]背景顏色[/b]：設定各文字區塊的背景色（預設全透明）
[/list]

[b]🔹 額外標的 / Extra Ticker[/b]
[list]
[*][b]額外標的[/b]：設定 Ticker2 關鍵字所對應的標的（預設 BTCUSDTPERP）
[/list]

[b]🔶 DISCLAIMER[/b]

本指標及其所產生之所有信號、標記與警報，僅供技術分析學習與研究參考，不構成任何形式之投資建議、財務建議、交易推薦或買賣邀約。金融市場交易涉及高度風險，投資人可能損失部分或全部本金。過去表現不代表亦不保證未來結果。使用本指標之任何交易決策均由使用者自行判斷並承擔完全責任，作者與發布平台不負任何法律責任。請充分了解市場規則與自身風險承受能力，必要時諮詢具備合法資質的專業財務顧問。

## Source Code

````pine
//@version=6
indicator('Watermark | 浮水印 [Y.Algo]', shorttitle = 'Watermark [Y.Algo]', overlay = true)

Time(Unix, format) =>
    string result = str.format('{0,time,' + format + '}', int(Unix))
    str.contains(format, 'a') ? result : str.replace_all(str.replace_all(result, ' AM', ''), ' PM', '')

// === 輸入設定 / Input Settings ===
title = input.text_area('Take a Trade Pro', '標題 / Title', group = '文字設定 / Text Settings', tooltip = '輸入標題內容，可使用關鍵字')
subtitle = input.text_area('Subtitle  |  Subtitle  |  Subtitle', '副標題 / Subtitle', group = '文字設定 / Text Settings', tooltip = '輸入副標題內容，可使用關鍵字')
textbox = input.text_area('Date\nTicker | TF', '文字框 / Textbox', group = '文字設定 / Text Settings', tooltip = '輸入文字框內容，可使用關鍵字')

exampleBox = input.text_area('【以下為範例，可複製並使用於文字框】\n\n選項▼▼▼\nTF (時間週期)\nTicker (當前標的)\nTicker2 (額外標的)\nVolume (成交量)\nOpen (開盤價)\nClose (收盤價)\nHigh (最高價)\nLow (最低價)\nDay (星期)\nDate (日期)\nTime (時間)', '範例與說明 / Examples', group = '文字設定 / Text Settings')

UTC = input.int(8, 'UTC 偏移 / UTC Offset', minval = -18, maxval = 18, group = '時間調整 / Time Adjustment', tooltip = 'CST 為 UTC+8')

fDay = input.string('E', '格式化 - 星期', inline = 'f', group = '時間格式 / Time Formatting')
fDate = input.string('MM/dd/yyyy', '格式化 - 日期', inline = 'f', group = '時間格式 / Time Formatting')
fTime = input.string('HH:mm:ss', '格式化 - 時間', inline = 'f', group = '時間格式 / Time Formatting', options = ['hh:mm:ssa', 'HH:mm:ss'])

text_ypos = input.string('top', '標題與副標題垂直位置', options = ['top', 'middle', 'bottom'], group = '標題與副標題位置 / Title and Subtitle Position')
text_xpos = input.string('center', '標題與副標題水平位置', options = ['left', 'center', 'right'], group = '標題與副標題位置 / Title and Subtitle Position')

textbox_ypos = input.string('bottom', '文字框垂直位置', options = ['top', 'middle', 'bottom'], group = '文字框位置 / Textbox Position')
textbox_xpos = input.string('center', '文字框水平位置', options = ['left', 'center', 'right'], group = '文字框位置 / Textbox Position')

// === LOGO 設定 / Logo Settings ===
grp_logo = 'LOGO 設定 / Logo Settings'
show_logo = input.bool(false, '顯示 LOGO / Show Logo', group=grp_logo)
locked_logo_text = input.text_area('⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  ⠀⣴⣿⣷⣆\n⠀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  ⠻⣿⣿⠟\n⠀⠈⠻⣿⣿⣿⣿⣷⣀⠀⠀⠀⠀⠀⠀⠀⠀ ⠀⣠⣶⣴⣶⣦⣶\n⠀⠀⠀⠈⠻⣿⣿⣿⣿⣧⣀⠀⠀⠀⠀⠀ ⣠⣾⣿⣿⣿⣿⣿⣿\n⠀⠀⠀⠀⠀⠘⠿⣿⣿⣿⣿⣧⣄⠀ ⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿\n⠀⠀⠀⠀⠀⠀⠀⠘⠿⣿⣿⣿⣿⣦⡀⠛⢿⣿⠟⠉ ⣿⣿⣿⣿\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣦⠌⠁⠀⠀  ⣿⣿⣿⣿\n⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀  ⣿⣿⣿⣿\n⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⡟⠉⠀⠀⠀⠀⠀⠀  ⣿⣿⣿⣿\n⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⠿⠁⠀⠀⠀⠀⠀⠀⠀   ⣿⣿⣿⣿\n⠀⠀⣠⣾⣿⣿⣿⣿⠟⠃⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n⣠⣾⣿⣿⣿⣿⠟⠃⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿', 'LOGO 圖案', group=grp_logo)
logo_ypos = input.string('middle', 'LOGO 垂直位置', options=['top', 'middle', 'bottom'], group=grp_logo)
logo_xpos = input.string('center', 'LOGO 水平位置', options = ['left', 'center', 'right'], group = grp_logo)
c_logo = input.color(color.new(color.white, 80), 'LOGO 顏色', group = grp_logo)
s_logo = input.string('small', 'LOGO 大小', options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'], group = grp_logo)

c_title = input.color(color.new(color.white, 0), '標題顏色', group = '標題樣式 / Title Style')
s_title = input.string('large', '標題大小', options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'], group = '標題樣式 / Title Style')

c_subtitle = input.color(color.new(color.white, 30), '副標題顏色', group = '副標題樣式 / Subtitle Style')
s_subtitle = input.string('normal', '副標題大小', options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'], group = '副標題樣式 / Subtitle Style')

c_textbox = input.color(color.new(color.white, 30), '文字框顏色', group = '文字框樣式 / Textbox Style')
s_textbox = input.string('normal', '文字框大小', options = ['tiny', 'small', 'normal', 'large', 'huge', 'auto'], group = '文字框樣式 / Textbox Style')

c_bg = input.color(color.new(color.blue, 100), '背景顏色', group = '背景設定 / Background Settings')

ticker2 = input.symbol('BTCUSDTPERP', '額外標的', group = '額外標的 / Extra Ticker')
t2 = array.get(str.split(ticker2, ':'), 1)

// === 時間框架計算 / Time Frame Calculation ===
string tfm = ''
if timeframe.isseconds
    tfm := 'S' + str.tostring(timeframe.multiplier)
    tfm
else if timeframe.isminutes
    if timeframe.multiplier % 60 == 0
        tfm := 'H' + str.tostring(int(timeframe.multiplier / 60))
        tfm
    else
        tfm := 'M' + str.tostring(timeframe.multiplier)
        tfm
else if timeframe.isdaily
    tfm := 'D' + str.tostring(timeframe.multiplier)
    tfm
else if timeframe.isweekly
    tfm := 'W' + str.tostring(timeframe.multiplier)
    tfm
else if timeframe.ismonthly
    tfm := 'Mo' + str.tostring(timeframe.multiplier)
    tfm

// === 文字替換功能 / Text Replacement Function ===
close2 = request.security(ticker2, '', close)
UTC_ms = UTC * 3600000

strReplace(textbox) =>
    str = textbox
    str := str.replace_all(str, 'Volume', str.tostring(volume))
    str := str.replace_all(str, 'Open', str.tostring(open))
    str := str.replace_all(str, 'Close', str.tostring(close))
    str := str.replace_all(str, 'High', str.tostring(high))
    str := str.replace_all(str, 'Low', str.tostring(low))
    str := str.replace_all(str, 'Ticker2', t2 + ': ' + str.tostring(close2))
    str := str.replace_all(str, 'Ticker', syminfo.ticker)
    str := str.replace_all(str, 'TF', str.tostring(tfm))
    str := str.replace_all(str, 'Day', Time(timenow + UTC_ms, fDay))
    str := str.replace_all(str, 'Date', Time(timenow + UTC_ms, fDate))
    str := str.replace_all(str, 'Time', Time(timenow + UTC_ms, fTime))
    str

// === 水印創建 / Watermark Creation ===
tn = Time(timenow + UTC_ms, fTime)

// 建立表格 (重點修改：將 textboxTable 改為 1行2列，以便分開設定大小)
var table textWatermark = table.new(text_ypos + '_' + text_xpos, 1, 2)
var table textboxTable = table.new(textbox_ypos + '_' + textbox_xpos, 1, 2)
var table logoTable = table.new(logo_ypos + '_' + logo_xpos, 1, 1)

if barstate.islast
    // 繪製標題與副標題
    table.cell(textWatermark, 0, 0, strReplace(title), 0, 0, c_title, text_size = s_title, bgcolor = c_bg)
    table.cell(textWatermark, 0, 1, strReplace(subtitle), 0, 0, c_subtitle, text_size = s_subtitle, bgcolor = c_bg)

    // 繪製文字框內容 (位於第0格，大小由使用者設定的 s_textbox 決定)
    table.cell(textboxTable, 0, 0, strReplace(textbox), 0, 0, c_textbox, text_size = s_textbox, bgcolor = c_bg)

    // 繪製中央 LOGO
    if show_logo
        table.cell(logoTable, 0, 0, locked_logo_text, 0, 0, c_logo, text_size = s_logo, bgcolor = color.new(color.white, 100), text_font_family = font.family_monospace)
````
