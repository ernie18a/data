<!-- tradingview-pine-id: PUB;7a78ef3962374115a482525a02d6a51a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stochastic MTF Table [XoRonX]

Source: https://www.tradingview.com/script/GcwWU60B-Stochastic-MTF-Table-XoRonX/

## Description

### Suggested Title

  Stochastic MTF Table with Momentum & Divergence

  ### Description

  This indicator provides a compact multi-timeframe overview of Stochastic conditions across
  five fixed timeframes:

  - M15
  - M30
  - H1
  - H4
  - D1

  The table displays the current %K / %D values and classifies each timeframe as:

  - OB — Over Bought
  - OS — Over Sold
  - Neutral
  - DIV — Bullish or Bearish Divergence

  ### Momentum Confirmation

  A momentum signal is confirmed when all five timeframes are aligned:

  - All timeframes in Over Bought: Upward Momentum
  - All timeframes in Over Sold: Downward Momentum

  When a new five-timeframe momentum confirmation occurs, the indicator places:

  - A green upward arrow below the candle for upward momentum.
  - A red downward arrow above the candle for downward momentum.
  - An optional candle color highlight.
  chart clean.

  ### Divergence Detection

  The indicator detects regular Stochastic divergence:

  - Bullish Divergence: Price forms a lower low while Stochastic forms a higher low.
  - Bearish Divergence: Price forms a higher high while Stochastic forms a lower high.

  Divergence signals use confirmed pivots and therefore appear after the selected pivot
  confirmation period.

  ### Customizable Settings

  - Stochastic K period
  - Stochastic D period
  - K smoothing
  - Over Bought and Over Sold levels
  - Pivot left and right lookback
  - Maximum distance between pivots
  - Divergence display duration
  - Optional OB/OS filter for divergence
  - Table position and text size
  - Momentum arrows and candle coloring

  ### Alerts

  Alert conditions are available for:

  - New Over Bought condition
  - New Over Sold condition
  - Bullish Divergence
  - Bearish Divergence
  - Five-timeframe Upward Momentum
  - Five-timeframe Downward Momentum

  ### Important Note

  Values from active higher-timeframe candles may change until those candles close. Momentum
  and divergence indications should be used as confirmation tools, not as standalone buy or
  sell signals.

  This indicator is intended for technical analysis and educational purposes only. It does
  not constitute financial advice.

---

## Source Code

````pine
//@version=6
indicator("Stochastic MTF Table [XoRonX]", shorttitle="Stoch MTF Table", overlay=true)

// =============================================================================
// INPUT
// =============================================================================
string GRP_STOCH = "Pengaturan Stochastic"
string GRP_DIV   = "Pengaturan Divergence"
string GRP_TABLE = "Tampilan Table"
string GRP_SIGNAL = "Signal Momentum 5 TF"

int kLength  = input.int(5, "K Period", minval=1, group=GRP_STOCH)
int dLength  = input.int(3, "D Period", minval=1, group=GRP_STOCH)
int kSmooth  = input.int(3, "Slowing / Smooth K", minval=1, group=GRP_STOCH)
int overBought = input.int(80, "Level Over Bought", minval=50, maxval=100, group=GRP_STOCH)
int overSold   = input.int(20, "Level Over Sold", minval=0, maxval=50, group=GRP_STOCH)

int pivotLeft    = input.int(5, "Pivot Lookback Kiri", minval=1, maxval=20, group=GRP_DIV)
int pivotRight   = input.int(5, "Pivot Lookback Kanan", minval=1, maxval=20, group=GRP_DIV,
     tooltip="Divergence baru dikonfirmasi setelah jumlah candle ini selesai.")
int maxLookback  = input.int(60, "Maks Jarak Antar Pivot", minval=5, maxval=200, group=GRP_DIV)
int signalHold   = input.int(3, "Tampilkan DIV Selama N Candle TF", minval=0, maxval=50, group=GRP_DIV)
bool requireZone = input.bool(false, "Divergence Wajib Berasal Dari OB/OS", group=GRP_DIV,
     tooltip="Jika aktif, Bearish DIV harus berasal dari zona Over Bought dan Bullish DIV dari zona Over Sold.")

bool showTable = input.bool(true, "Tampilkan Table", group=GRP_TABLE)
string tablePosition = input.string("Top Right", "Posisi", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_TABLE)
string tableTextSize = input.string("Small", "Ukuran Teks", options=["Tiny", "Small", "Normal"], group=GRP_TABLE)

bool showMomentumArrow = input.bool(true, "Tampilkan Arrow Momentum di Candle", group=GRP_SIGNAL)
bool colorMomentumBar = input.bool(true, "Warnai Candle Momentum", group=GRP_SIGNAL,
     tooltip="Signal muncul saat kelima timeframe serempak berada di OB atau serempak berada di OS.")

// =============================================================================
// STOCHASTIC + REGULAR DIVERGENCE
// Return: [%K, %D, zoneCode, divCode]
// zoneCode: 1 = OB, -1 = OS, 0 = Neutral
// divCode : 1 = Bullish DIV, -1 = Bearish DIV, 0 = Tidak ada
// =============================================================================
f_stochState() =>
    float rawK = ta.stoch(close, high, low, kLength)
    float k = ta.sma(rawK, kSmooth)
    float d = ta.sma(k, dLength)

    float priceHighPivot = ta.pivothigh(high, pivotLeft, pivotRight)
    float priceLowPivot  = ta.pivotlow(low, pivotLeft, pivotRight)
    bool newHighPivot = not na(priceHighPivot)
    bool newLowPivot  = not na(priceLowPivot)

    float stochAtHigh = k[pivotRight]
    float stochAtLow  = k[pivotRight]
    int highPivotBar = bar_index - pivotRight
    int lowPivotBar  = bar_index - pivotRight

    float previousPriceHigh = ta.valuewhen(newHighPivot, priceHighPivot, 1)
    float previousStochHigh = ta.valuewhen(newHighPivot, stochAtHigh, 1)
    int previousHighBar = ta.valuewhen(newHighPivot, highPivotBar, 1)

    float previousPriceLow = ta.valuewhen(newLowPivot, priceLowPivot, 1)
    float previousStochLow = ta.valuewhen(newLowPivot, stochAtLow, 1)
    int previousLowBar = ta.valuewhen(newLowPivot, lowPivotBar, 1)

    int highDistance = highPivotBar - previousHighBar
    int lowDistance  = lowPivotBar - previousLowBar

    bool bearishZoneValid = not requireZone or stochAtHigh >= overBought or previousStochHigh >= overBought
    bool bullishZoneValid = not requireZone or stochAtLow <= overSold or previousStochLow <= overSold

    // Regular Bearish: harga Higher High, Stochastic Lower High.
    bool bearishDivEvent = newHighPivot and not na(previousPriceHigh) and not na(previousStochHigh) and
         highDistance > 0 and highDistance <= maxLookback and
         priceHighPivot > previousPriceHigh and stochAtHigh < previousStochHigh and bearishZoneValid

    // Regular Bullish: harga Lower Low, Stochastic Higher Low.
    bool bullishDivEvent = newLowPivot and not na(previousPriceLow) and not na(previousStochLow) and
         lowDistance > 0 and lowDistance <= maxLookback and
         priceLowPivot < previousPriceLow and stochAtLow > previousStochLow and bullishZoneValid

    int barsSinceBear = ta.barssince(bearishDivEvent)
    int barsSinceBull = ta.barssince(bullishDivEvent)
    bool bearActive = not na(barsSinceBear) and barsSinceBear <= signalHold
    bool bullActive = not na(barsSinceBull) and barsSinceBull <= signalHold

    int divCode = bearActive and bullActive ? (barsSinceBear <= barsSinceBull ? -1 : 1) :
         bearActive ? -1 : bullActive ? 1 : 0
    int zoneCode = k >= overBought ? 1 : k <= overSold ? -1 : 0

    [k, d, zoneCode, divCode]

// Fixed timeframe sesuai kebutuhan: M15, M30, H1, H4, D1.
[k15, d15, zone15, div15] = request.security(syminfo.tickerid, "15", f_stochState(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[k30, d30, zone30, div30] = request.security(syminfo.tickerid, "30", f_stochState(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[kH1, dH1, zoneH1, divH1] = request.security(syminfo.tickerid, "60", f_stochState(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[kH4, dH4, zoneH4, divH4] = request.security(syminfo.tickerid, "240", f_stochState(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[kD1, dD1, zoneD1, divD1] = request.security(syminfo.tickerid, "D", f_stochState(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Konfirmasi momentum hanya aktif jika kelima timeframe serempak.
bool allOverBought = zone15 == 1 and zone30 == 1 and zoneH1 == 1 and zoneH4 == 1 and zoneD1 == 1
bool allOverSold   = zone15 == -1 and zone30 == -1 and zoneH1 == -1 and zoneH4 == -1 and zoneD1 == -1
bool momentumUpEvent   = allOverBought and not allOverBought[1]
bool momentumDownEvent = allOverSold and not allOverSold[1]

// =============================================================================
// TABLE
// =============================================================================
f_position() =>
    switch tablePosition
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_textSize() =>
    switch tableTextSize
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

color CLR_TITLE   = #111827
color CLR_HEADER  = #1F2937
color CLR_ROW_A   = #111827
color CLR_ROW_B   = #172033
color CLR_BORDER  = #4B5563
color CLR_NEUTRAL = #9CA3AF
color CLR_OB      = #EF4444
color CLR_OS      = #22C55E
color CLR_BULL    = #22C55E
color CLR_BEAR    = #EF4444

f_renderRow(table panel, int row, string tfLabel, float kValue, float dValue, int zoneCode, int divCode) =>
    color rowColor = row % 2 == 0 ? CLR_ROW_A : CLR_ROW_B
    string valueText = na(kValue) or na(dValue) ? "N/A" : str.tostring(kValue, "#.0") + " / " + str.tostring(dValue, "#.0")
    string zoneText = zoneCode == 1 ? "OB\nOver Bought" : zoneCode == -1 ? "OS\nOver Sold" : "Neutral"
    color zoneColor = zoneCode == 1 ? CLR_OB : zoneCode == -1 ? CLR_OS : CLR_NEUTRAL
    string divText = divCode == 1 ? "DIV\nBullish" : divCode == -1 ? "DIV\nBearish" : "-"
    color divColor = divCode == 1 ? CLR_BULL : divCode == -1 ? CLR_BEAR : CLR_NEUTRAL

    table.cell(panel, 0, row, tfLabel, text_color=color.white, bgcolor=rowColor, text_size=f_textSize(), text_halign=text.align_center)
    table.cell(panel, 1, row, valueText, text_color=color.white, bgcolor=rowColor, text_size=f_textSize(), text_halign=text.align_center)
    table.cell(panel, 2, row, zoneText, text_color=zoneColor, bgcolor=rowColor, text_size=f_textSize(), text_halign=text.align_center)
    table.cell(panel, 3, row, divText, text_color=divColor, bgcolor=rowColor, text_size=f_textSize(), text_halign=text.align_center)

var table stochTable = table.new(f_position(), 4, 9, frame_color=CLR_BORDER, frame_width=1, border_color=color.new(CLR_BORDER, 35), border_width=1)

if barstate.isfirst
    table.merge_cells(stochTable, 0, 0, 3, 0)
    table.merge_cells(stochTable, 0, 7, 3, 7)
    table.merge_cells(stochTable, 0, 8, 3, 8)

if barstate.islast
    if showTable
        table.cell(stochTable, 0, 0, "STOCHASTIC MTF", text_color=color.white, bgcolor=CLR_TITLE, text_size=f_textSize(), text_halign=text.align_center)

        table.cell(stochTable, 0, 1, "TF", text_color=color.white, bgcolor=CLR_HEADER, text_size=f_textSize(), text_halign=text.align_center)
        table.cell(stochTable, 1, 1, "%K / %D", text_color=color.white, bgcolor=CLR_HEADER, text_size=f_textSize(), text_halign=text.align_center)
        table.cell(stochTable, 2, 1, "OB / OS", text_color=color.white, bgcolor=CLR_HEADER, text_size=f_textSize(), text_halign=text.align_center)
        table.cell(stochTable, 3, 1, "DIV", text_color=color.white, bgcolor=CLR_HEADER, text_size=f_textSize(), text_halign=text.align_center)

        f_renderRow(stochTable, 2, "M15", k15, d15, zone15, div15)
        f_renderRow(stochTable, 3, "M30", k30, d30, zone30, div30)
        f_renderRow(stochTable, 4, "H1", kH1, dH1, zoneH1, divH1)
        f_renderRow(stochTable, 5, "H4", kH4, dH4, zoneH4, divH4)
        f_renderRow(stochTable, 6, "D1", kD1, dD1, zoneD1, divD1)

        string momentumText = allOverBought ? "SIGNAL: ALL OB - MOMENTUM NAIK" :
             allOverSold ? "SIGNAL: ALL OS - MOMENTUM TURUN" : "SIGNAL: MENUNGGU KONFIRMASI 5 TF"
        color momentumColor = allOverBought ? CLR_BULL : allOverSold ? CLR_BEAR : CLR_NEUTRAL
        color momentumBg = allOverBought ? color.new(CLR_BULL, 78) : allOverSold ? color.new(CLR_BEAR, 78) : CLR_HEADER
        table.cell(stochTable, 0, 7, momentumText, text_color=momentumColor, bgcolor=momentumBg, text_size=f_textSize(), text_halign=text.align_center)

        table.cell(stochTable, 0, 8, "OB = Over Bought  |  OS = Over Sold  |  DIV = Divergence", text_color=CLR_NEUTRAL, bgcolor=CLR_TITLE, text_size=size.tiny, text_halign=text.align_center)
    else
        table.clear(stochTable, 0, 0, 3, 8)

// Arrow dan warna hanya ditempatkan pada candle pertama saat 5 TF terkonfirmasi.
plotshape(showMomentumArrow and momentumUpEvent, title="Momentum Naik 5 TF", style=shape.arrowup, location=location.belowbar,
     color=CLR_BULL, size=size.large)
plotshape(showMomentumArrow and momentumDownEvent, title="Momentum Turun 5 TF", style=shape.arrowdown, location=location.abovebar,
     color=CLR_BEAR, size=size.large)

color momentumBarColor = colorMomentumBar ? (momentumUpEvent ? CLR_BULL : momentumDownEvent ? CLR_BEAR : na) : na
barcolor(momentumBarColor, title="Candle Momentum 5 TF")

// Alert hanya aktif ketika status baru muncul agar tidak berulang di setiap candle.
bool newOverBought = (zone15 == 1 and zone15[1] != 1) or (zone30 == 1 and zone30[1] != 1) or
     (zoneH1 == 1 and zoneH1[1] != 1) or (zoneH4 == 1 and zoneH4[1] != 1) or (zoneD1 == 1 and zoneD1[1] != 1)
bool newOverSold = (zone15 == -1 and zone15[1] != -1) or (zone30 == -1 and zone30[1] != -1) or
     (zoneH1 == -1 and zoneH1[1] != -1) or (zoneH4 == -1 and zoneH4[1] != -1) or (zoneD1 == -1 and zoneD1[1] != -1)
bool newBullDiv = (div15 == 1 and div15[1] != 1) or (div30 == 1 and div30[1] != 1) or
     (divH1 == 1 and divH1[1] != 1) or (divH4 == 1 and divH4[1] != 1) or (divD1 == 1 and divD1[1] != 1)
bool newBearDiv = (div15 == -1 and div15[1] != -1) or (div30 == -1 and div30[1] != -1) or
     (divH1 == -1 and divH1[1] != -1) or (divH4 == -1 and divH4[1] != -1) or (divD1 == -1 and divD1[1] != -1)

alertcondition(newOverBought, "Stochastic MTF - Over Bought", "Stochastic baru masuk zona Over Bought pada salah satu timeframe M15, M30, H1, H4, atau D1.")
alertcondition(newOverSold, "Stochastic MTF - Over Sold", "Stochastic baru masuk zona Over Sold pada salah satu timeframe M15, M30, H1, H4, atau D1.")
alertcondition(newBullDiv, "Stochastic MTF - Bullish Divergence", "Bullish Stochastic Divergence baru terdeteksi pada salah satu timeframe M15, M30, H1, H4, atau D1.")
alertcondition(newBearDiv, "Stochastic MTF - Bearish Divergence", "Bearish Stochastic Divergence baru terdeteksi pada salah satu timeframe M15, M30, H1, H4, atau D1.")
alertcondition(momentumUpEvent, "Stochastic MTF - Momentum Naik 5 TF", "Semua timeframe M15, M30, H1, H4, dan D1 berada di Over Bought: Momentum Naik terkonfirmasi.")
alertcondition(momentumDownEvent, "Stochastic MTF - Momentum Turun 5 TF", "Semua timeframe M15, M30, H1, H4, dan D1 berada di Over Sold: Momentum Turun terkonfirmasi.")
````
