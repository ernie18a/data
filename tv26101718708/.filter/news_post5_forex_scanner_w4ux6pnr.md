# News Post-5 Forex Scanner

- url: https://www.tradingview.com/script/w4ux6PnR/
- type: indicator
- pine_id: PUB;60cb64cb9faf4b3a9af1fe1f34b7c7da
- version: 1.0

## Description

detecta los pares con mayor probabilidad de continuacion despues de noticia

## Source Code

````pine
//@version=6
indicator("News Post-5 Forex Scanner", overlay=true, max_labels_count=500, dynamic_requests=true)

//======================================================================
// INPUTS
//======================================================================

inpPrefix = input.string("FX:", "Prefijo símbolos TradingView", tooltip="Ejemplos: FX:, OANDA:, FOREXCOM:, PEPPERSTONE:")
inpYear   = input.int(2026, "Año noticia", minval=2000, maxval=2100)
inpMonth  = input.int(1, "Mes noticia", minval=1, maxval=12)
inpDay    = input.int(1, "Día noticia", minval=1, maxval=31)
inpHour   = input.int(14, "Hora noticia", minval=0, maxval=23)
inpMinute = input.int(30, "Minuto noticia", minval=0, maxval=59)

inpTimezone = input.string("Europe/Madrid", "Zona horaria")
inpCurrency = input.string("USD", "Divisa afectada", options=["USD", "EUR", "GBP", "CAD", "AUD", "NZD", "JPY", "CHF"])
inpNewsType = input.string("NFP", "Tipo de noticia", options=["NFP", "CPI", "PMI", "GDP", "FOMC", "Speech", "Rate Decision", "Employment", "Other"])

inpMinutesAfter = input.int(5, "MinutesAfterNews", minval=5, maxval=60)
inpMinScoreShow = input.float(0.0, "Score mínimo para mostrar", minval=0, maxval=100)

newsTime = timestamp(inpTimezone, inpYear, inpMonth, inpDay, inpHour, inpMinute)
postTime = newsTime + inpMinutesAfter * 60 * 1000

//======================================================================
// GRUPOS DE PARES
//======================================================================

f_pair_count(string cur) =>
    switch cur
        "USD" => 11
        "GBP" => 7
        "EUR" => 7
        "CAD" => 7
        "AUD" => 7
        "NZD" => 7
        "JPY" => 7
        "CHF" => 7
        => 0

f_pair(string cur, int i) =>
    string p = na

    if cur == "USD"
        p := switch i
            0 => "EURUSD"
            1 => "GBPUSD"
            2 => "AUDUSD"
            3 => "NZDUSD"
            4 => "USDCAD"
            5 => "USDCHF"
            6 => "USDJPY"
            7 => "GBPAUD"
            8 => "EURAUD"
            9 => "EURCAD"
            10 => "GBPCAD"
            => na

    if cur == "GBP"
        p := switch i
            0 => "GBPUSD"
            1 => "GBPJPY"
            2 => "GBPAUD"
            3 => "GBPCAD"
            4 => "GBPCHF"
            5 => "GBPNZD"
            6 => "EURGBP"
            => na

    if cur == "EUR"
        p := switch i
            0 => "EURUSD"
            1 => "EURGBP"
            2 => "EURAUD"
            3 => "EURCAD"
            4 => "EURCHF"
            5 => "EURNZD"
            6 => "EURJPY"
            => na

    if cur == "CAD"
        p := switch i
            0 => "USDCAD"
            1 => "EURCAD"
            2 => "GBPCAD"
            3 => "AUDCAD"
            4 => "NZDCAD"
            5 => "CADJPY"
            6 => "CADCHF"
            => na

    if cur == "AUD"
        p := switch i
            0 => "AUDUSD"
            1 => "AUDJPY"
            2 => "AUDCAD"
            3 => "AUDCHF"
            4 => "AUDNZD"
            5 => "EURAUD"
            6 => "GBPAUD"
            => na

    if cur == "NZD"
        p := switch i
            0 => "NZDUSD"
            1 => "NZDJPY"
            2 => "NZDCAD"
            3 => "NZDCHF"
            4 => "AUDNZD"
            5 => "EURNZD"
            6 => "GBPNZD"
            => na

    if cur == "JPY"
        p := switch i
            0 => "USDJPY"
            1 => "EURJPY"
            2 => "GBPJPY"
            3 => "AUDJPY"
            4 => "NZDJPY"
            5 => "CADJPY"
            6 => "CHFJPY"
            => na

    if cur == "CHF"
        p := switch i
            0 => "USDCHF"
            1 => "EURCHF"
            2 => "GBPCHF"
            3 => "AUDCHF"
            4 => "NZDCHF"
            5 => "CADCHF"
            6 => "CHFJPY"
            => na

    p

f_ticker(string pair) =>
    inpPrefix + pair

//======================================================================
// DATOS M5
//======================================================================

f_m5_data(int _newsTime, int _postTime) =>
    var float newsOpen = na
    var float postClose = na
    var bool foundNews = false
    var bool foundPost = false

    isNewsBar = time <= _newsTime and time_close > _newsTime

    if isNewsBar and not foundNews
        newsOpen := open
        foundNews := true

    if foundNews and not foundPost and time_close >= _postTime
        postClose := close
        foundPost := true

    atr = ta.atr(14)
    atrAvg = ta.sma(atr, 50)

    vwapValue = ta.vwap(hlc3)

    bbBasis = ta.sma(close, 20)
    bbDev = ta.stdev(close, 20) * 2.0
    bbUpper = bbBasis + bbDev
    bbLower = bbBasis - bbDev
    bbWidth = bbUpper - bbLower
    bbExpanding = bbWidth > ta.sma(bbWidth, 20)

    [close, newsOpen, postClose, atr, atrAvg, vwapValue, bbBasis, bbExpanding]

//======================================================================
// SCORE
//======================================================================

f_quality(float score) =>
    score >= 90 ? "A++" :
     score >= 80 ? "A+" :
     score >= 70 ? "A" :
     score >= 60 ? "B" :
     "No Trade"

f_yesno(bool v) =>
    v ? "OK" : "NO"

f_direction(float move) =>
    move > 0 ? "LONG" : move < 0 ? "SHORT" : "FLAT"

f_reason(float moveAtr, bool cont, bool vwapOk, bool bbOk, bool m15Ok, bool h1Ok) =>
    string r = "Move"

    if cont
        r := "Continuation"
    else if vwapOk
        r := "VWAP"
    else if bbOk
        r := "Bollinger"
    else if m15Ok
        r := "M15 Trend"
    else if h1Ok
        r := "H1 Trend"

    r

f_score(float firstMove, float currentClose, float postClose, float atr, float atrAvg, float vwapValue, float bbBasis, bool bbExpanding, int m15Trend, int h1Trend) =>
    dir = firstMove > 0 ? 1 : firstMove < 0 ? -1 : 0

    moveAtr = atr > 0 ? math.abs(firstMove) / atr : 0.0

    movementScore = math.min(moveAtr, 1.0) * 25.0
    volatilityScore = atr > atrAvg ? 5.0 : 0.0

    continuationOk = dir == 1 ? currentClose > postClose : dir == -1 ? currentClose < postClose : false
    continuationScore = continuationOk ? 20.0 : 0.0

    vwapOk = dir == 1 ? currentClose > vwapValue : dir == -1 ? currentClose < vwapValue : false
    vwapScore = vwapOk ? 15.0 : 0.0

    bbOk = dir == 1 ? currentClose > bbBasis : dir == -1 ? currentClose < bbBasis : false
    bbScore = bbOk ? 10.0 : 0.0
    bbScore += bbOk and bbExpanding ? 5.0 : 0.0

    m15Ok = dir == 1 ? m15Trend == 1 : dir == -1 ? m15Trend == -1 : false
    m15Score = m15Ok ? 10.0 : 0.0

    h1Ok = dir == 1 ? h1Trend == 1 : dir == -1 ? h1Trend == -1 : false
    h1Score = h1Ok ? 10.0 : 0.0

    total = movementScore + volatilityScore + continuationScore + vwapScore + bbScore + m15Score + h1Score

    [math.min(total, 100.0), moveAtr, continuationOk, vwapOk, bbOk, m15Ok, h1Ok]

//======================================================================
// SWAPS MANUALES
//======================================================================

f_swap_string(array<string> a, int i, int j) =>
    temp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, temp)

f_swap_float(array<float> a, int i, int j) =>
    temp = array.get(a, i)
    array.set(a, i, array.get(a, j))
    array.set(a, j, temp)

//======================================================================
// ARRAYS
//======================================================================

var table scannerTable = table.new(position.top_right, 11, 13, border_width=1)

var arrPairs = array.new_string()
var arrDirs = array.new_string()
var arrScores = array.new_float()
var arrQualities = array.new_string()
var arrMoveAtr = array.new_float()
var arrVwap = array.new_string()
var arrBb = array.new_string()
var arrM15 = array.new_string()
var arrH1 = array.new_string()
var arrReasons = array.new_string()

array.clear(arrPairs)
array.clear(arrDirs)
array.clear(arrScores)
array.clear(arrQualities)
array.clear(arrMoveAtr)
array.clear(arrVwap)
array.clear(arrBb)
array.clear(arrM15)
array.clear(arrH1)
array.clear(arrReasons)

//======================================================================
// ESCANEO
//======================================================================

count = f_pair_count(inpCurrency)

if barstate.isconfirmed
    for i = 0 to 10
        if i < count
            pair = f_pair(inpCurrency, i)
            ticker = f_ticker(pair)

            [c, nOpen, pClose, atr, atrAvg, vwapValue, bbBasis, bbExpanding] = request.security(ticker, "5", f_m5_data(newsTime, postTime), barmerge.gaps_off, barmerge.lookahead_off)
            m15Trend = request.security(ticker, "15", ta.ema(close, 20) > ta.ema(close, 50) ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)
            h1Trend = request.security(ticker, "60", ta.ema(close, 50) > ta.ema(close, 200) ? 1 : -1, barmerge.gaps_off, barmerge.lookahead_off)

            enoughData = not na(nOpen) and not na(pClose) and time >= postTime
            firstMove = enoughData ? pClose - nOpen : na
            dir = enoughData ? f_direction(firstMove) : "WAIT"

            float score = 0.0
            float moveAtr = 0.0
            bool contOk = false
            bool vwapOk = false
            bool bbOk = false
            bool m15Ok = false
            bool h1Ok = false

            if enoughData
                [scoreCalc, moveAtrCalc, contOkCalc, vwapOkCalc, bbOkCalc, m15OkCalc, h1OkCalc] = f_score(firstMove, c, pClose, atr, atrAvg, vwapValue, bbBasis, bbExpanding, m15Trend, h1Trend)

                score := scoreCalc
                moveAtr := moveAtrCalc
                contOk := contOkCalc
                vwapOk := vwapOkCalc
                bbOk := bbOkCalc
                m15Ok := m15OkCalc
                h1Ok := h1OkCalc

            if score >= inpMinScoreShow
                array.push(arrPairs, pair)
                array.push(arrDirs, dir)
                array.push(arrScores, score)
                array.push(arrQualities, enoughData ? f_quality(score) : "WAIT")
                array.push(arrMoveAtr, moveAtr)
                array.push(arrVwap, f_yesno(vwapOk))
                array.push(arrBb, f_yesno(bbOk))
                array.push(arrM15, f_yesno(m15Ok))
                array.push(arrH1, f_yesno(h1Ok))
                array.push(arrReasons, enoughData ? f_reason(moveAtr, contOk, vwapOk, bbOk, m15Ok, h1Ok) : "Waiting post-5")

//======================================================================
// ORDENACIÓN
//======================================================================

n = array.size(arrScores)

if n > 1
    for i = 0 to n - 2
        for j = i + 1 to n - 1
            if array.get(arrScores, j) > array.get(arrScores, i)
                f_swap_string(arrPairs, i, j)
                f_swap_string(arrDirs, i, j)
                f_swap_float(arrScores, i, j)
                f_swap_string(arrQualities, i, j)
                f_swap_float(arrMoveAtr, i, j)
                f_swap_string(arrVwap, i, j)
                f_swap_string(arrBb, i, j)
                f_swap_string(arrM15, i, j)
                f_swap_string(arrH1, i, j)
                f_swap_string(arrReasons, i, j)

//======================================================================
// TABLA
//======================================================================

f_cell(int col, int row, string txt, color bg, color fg=color.white) =>
    table.cell(scannerTable, col, row, txt, bgcolor=bg, text_color=fg, text_size=size.small)

if barstate.isconfirmed
    table.clear(scannerTable, 0, 0, 10, 12)

    headerBg = color.rgb(20, 30, 45)
    rowBg = color.rgb(10, 15, 25)

    f_cell(0, 0, "Rank", headerBg)
    f_cell(1, 0, "Pair", headerBg)
    f_cell(2, 0, "Direction", headerBg)
    f_cell(3, 0, "Score", headerBg)
    f_cell(4, 0, "Quality", headerBg)
    f_cell(5, 0, "MoveATR", headerBg)
    f_cell(6, 0, "VWAP", headerBg)
    f_cell(7, 0, "BB", headerBg)
    f_cell(8, 0, "M15", headerBg)
    f_cell(9, 0, "H1", headerBg)
    f_cell(10, 0, "Reason", headerBg)

    rows = math.min(n, 12)

    for r = 0 to rows - 1
        scoreRow = array.get(arrScores, r)
        dirRow = array.get(arrDirs, r)
        qRow = array.get(arrQualities, r)

        scoreBg = scoreRow >= 90 ? color.rgb(0, 120, 60) :
             scoreRow >= 80 ? color.rgb(35, 130, 35) :
             scoreRow >= 70 ? color.rgb(130, 110, 20) :
             scoreRow >= 60 ? color.rgb(120, 70, 20) :
             color.rgb(80, 30, 30)

        dirBg = dirRow == "LONG" ? color.rgb(0, 90, 60) :
             dirRow == "SHORT" ? color.rgb(120, 35, 35) :
             color.rgb(70, 70, 70)

        f_cell(0, r + 1, str.tostring(r + 1), rowBg)
        f_cell(1, r + 1, array.get(arrPairs, r), rowBg)
        f_cell(2, r + 1, dirRow, dirBg)
        f_cell(3, r + 1, str.tostring(scoreRow, "#.##"), scoreBg)
        f_cell(4, r + 1, qRow, scoreBg)
        f_cell(5, r + 1, str.tostring(array.get(arrMoveAtr, r), "#.##"), rowBg)
        f_cell(6, r + 1, array.get(arrVwap, r), rowBg)
        f_cell(7, r + 1, array.get(arrBb, r), rowBg)
        f_cell(8, r + 1, array.get(arrM15, r), rowBg)
        f_cell(9, r + 1, array.get(arrH1, r), rowBg)
        f_cell(10, r + 1, array.get(arrReasons, r), rowBg)

//======================================================================
// ALERTAS
//======================================================================

topScore = n > 0 ? array.get(arrScores, 0) : 0.0
topPair = n > 0 ? array.get(arrPairs, 0) : "NA"
topDir = n > 0 ? array.get(arrDirs, 0) : "NA"
topQuality = n > 0 ? array.get(arrQualities, 0) : "NA"

anyScore85 = false

if n > 0
    for i = 0 to n - 1
        anyScore85 := anyScore85 or array.get(arrScores, i) >= 85

condTop80 = barstate.isconfirmed and topScore >= 80
condTop90 = barstate.isconfirmed and topScore >= 90
condAny85 = barstate.isconfirmed and anyScore85

alertcondition(condTop80, "News Scanner Top 1 >= 80", "News Scanner: Top 1 score >= 80. Revisa la tabla del indicador.")
alertcondition(condTop90, "News Scanner Top 1 >= 90", "News Scanner: Top 1 score >= 90. Revisa la tabla del indicador.")
alertcondition(condAny85, "News Scanner Any Pair >= 85", "News Scanner: Hay al menos un par del grupo con score >= 85. Revisa la tabla del indicador.")

if condTop80
    alert("News Scanner:\nTop Pair = " + topPair + "\nDirection = " + topDir + "\nScore = " + str.tostring(topScore, "#.##") + "\nQuality = " + topQuality + "\nCurrency = " + inpCurrency + "\nNews Type = " + inpNewsType, alert.freq_once_per_bar_close)
````
