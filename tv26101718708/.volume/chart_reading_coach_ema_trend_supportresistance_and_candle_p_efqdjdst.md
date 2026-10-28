# Chart Reading Coach - EMA Trend, Support/Resistance and Candle P

- url: https://www.tradingview.com/script/efqDJDSt/
- type: indicator
- pine_id: PUB;37f2bc9a0c424f02a4411e2e9c2f9c41
- version: 3.0

## Description

OVERVIEW
Chart Reading Coach is an educational overlay for traders who are new to technical analysis. Instead of only drawing lines and signals, it explains on the chart what each element is and why it matters. Every label has a plain-language tooltip (hover or tap it), and a live panel summarizes what the chart is saying right now. The interface can be switched between English and Turkish in the settings.

WHAT IT SHOWS AND WHY THESE PARTS ARE COMBINED
The goal is to teach the basic checklist many traders go through when reading a chart: trend direction, trend strength, key price levels, momentum, volume and candle behavior. Each component answers one of these questions:
- EMA 20 / 50 / 200: short, medium and main trend direction. The cloud between EMA 20 and EMA 50 turns green or red to show the short-term bias, and its width shows trend strength.
- Support and resistance: the last 3 swing highs and lows (pivot-based), drawn as dashed lines extended to the right.
- Candle patterns: bullish/bearish engulfing, hammer and shooting star, filtered by candle size and the prior move.
- Volume: bars with volume above 1.8x the 20-bar average are flagged as a spike.
- RSI (14): shown in the panel as overbought (>70), oversold (<30) or normal.
- Signals: examples of how the components above can be combined. They are meant to be studied, not followed blindly.

HOW IT WORKS
- EMA cross BUY: EMA 20 crosses above EMA 50 while price is above EMA 200 and RSI is below 70. EMA cross SELL is the mirror condition.
- Pullback BUY: EMA 50 is above EMA 200, the candle's low touches EMA 50 and the candle closes green above EMA 50. At least 10 bars must pass between two pullback labels. Pullback SELL is the mirror condition.
- Engulfing: the body engulfs the previous opposite-colored body, is at least 1.2x its size and at least 0.7x ATR(14), and the preceding bars moved in the opposite direction.
- Hammer / shooting star: main wick at least 2x the body, opposite wick at most 0.5x the body, candle range at least 0.8x ATR(14), appearing after a decline / rise, with RSI below 45 / above 55.
- Pattern labels are limited to one per direction within a user-defined number of bars to reduce clutter.
- Every signal tooltip states whether volume confirms the move.
- Line notes on the right edge and the info panel update on the last bar.

HOW TO USE
1. Look at EMA 200 first. Price above it favors the long side; price below it calls for caution.
2. Check the cloud. A wide cloud means a strong trend. Thin, tangled EMAs mean a sideways market, where signals fail more often.
3. When price breaks support or resistance, check whether the breakout comes with a volume spike.
4. Hover over or tap any label to read what it means.
The script works on any symbol and timeframe. 4h and daily charts are recommended for learning.

WHAT MAKES IT DIFFERENT
The underlying calculations are standard and widely known. What this script adds is a teaching layer: every drawn object carries a context-aware explanation, signal tooltips include volume confirmation, and a plain-language panel turns the current state of all components into a single summary sentence. It is built to help beginners learn to read a chart step by step, not to act as a black-box signal system.

SETTINGS
Language (English / Turkish), show/hide each component, EMA lengths, RSI length, support/resistance sensitivity, volume spike multiplier, minimum bars between patterns, optional SMMA line, panel text size.

LIMITATIONS
- Pivot-based support/resistance levels are confirmed only after the chosen number of bars (default 10) has closed after the pivot, so they appear with a delay. Once drawn, they do not repaint.
- Labels on the live, unclosed bar can appear and disappear until the bar closes.
- Moving averages lag price. In sideways markets, cross and pullback signals often fail.
- No performance or accuracy claims are made. This is an educational tool, not financial advice.

ALERTS
Alert conditions are available for EMA cross BUY/SELL and pullback BUY/SELL.

---

TÜRKÇE

GENEL BAKIŞ
Grafik Okuma Koçu (Chart Reading Coach), teknik analize yeni başlayanlar için hazırlanmış eğitim amaçlı bir göstergedir. Sadece çizgi ve sinyal çizmekle kalmaz, grafikteki her öğenin ne olduğunu ve neden önemli olduğunu grafiğin üzerinde anlatır. Her etiketin sade Türkçe ile yazılmış bir açıklaması vardır (üzerine gelin veya dokunun). Canlı bilgi paneli, grafiğin şu an ne söylediğini özetler. Ayarlardan "Language / Dil" seçeneği ile arayüz Türkçe yapılabilir.

NE GÖSTERİR, PARÇALAR NEDEN BİR ARADA
Amaç, grafik okurken sorulan temel soruları öğretmektir: trendin yönü, trendin gücü, önemli fiyat seviyeleri, momentum, hacim ve mum davranışı. Her parça bu sorulardan birini cevaplar:
- EMA 20 / 50 / 200: kısa, orta ve ana trend yönü. EMA 20 ile EMA 50 arasındaki bulut yeşil veya kırmızı olarak kısa vadeli yönü, genişliğiyle de trendin gücünü gösterir.
- Destek ve direnç: son 3 tepe ve dip (pivot tabanlı), sağa uzatılmış kesikli çizgiler.
- Mum formasyonları: yutan boğa/ayı, çekiç ve kayan yıldız. Mum büyüklüğü ve önceki harekete göre filtrelenir.
- Hacim: 20 mumluk ortalamanın 1,8 katını aşan hacim "patlama" olarak işaretlenir.
- RSI (14): panelde aşırı alım (>70), aşırı satım (<30) veya normal olarak gösterilir.
- Sinyaller: yukarıdaki parçaların nasıl birleştirilebileceğine dair örneklerdir. İncelenmek içindir, körü körüne uygulanmak için değil.

NASIL ÇALIŞIR
- Kesişim AL: fiyat EMA 200 üstünde ve RSI 70 altındayken EMA 20'nin EMA 50'yi yukarı kesmesi. Kesişim SAT bunun tersidir.
- Tepki AL: EMA 50, EMA 200'ün üstündeyken mumun EMA 50'ye değip üstünde yeşil kapanması. İki tepki etiketi arasında en az 10 mum olmalıdır. Tepki SAT bunun tersidir.
- Yutan: gövde, önceki ters renkli gövdeyi tamamen kaplar, onun en az 1,2 katı ve ATR(14)'ün en az 0,7 katı büyüklüktedir, öncesinde ters yönde hareket vardır.
- Çekiç / kayan yıldız: ana fitil gövdenin en az 2 katı, ters fitil en fazla 0,5 katı, mum boyu ATR(14)'ün en az 0,8 katıdır. Düşüş / yükseliş sonrasında, RSI 45 altı / 55 üstü iken aranır.
- Kalabalığı azaltmak için her yönde, belirlenen mum sayısı içinde tek formasyon etiketi gösterilir.
- Her sinyal açıklaması, hareketi hacmin onaylayıp onaylamadığını belirtir.

NASIL KULLANILIR
1. Önce EMA 200'e bakın. Fiyat üstündeyse alım yönü öne çıkar, altındaysa temkinli olun.
2. Buluta bakın. Geniş bulut güçlü trend demektir. İnce ve iç içe geçmiş çizgiler yatay piyasa demektir, sinyaller daha sık başarısız olur.
3. Destek veya direnç kırıldığında, kırılımın yüksek hacimle gelip gelmediğini kontrol edin.
4. Herhangi bir etiketin üzerine gelerek açıklamasını okuyun.
Her sembol ve zaman diliminde çalışır. Öğrenmek için 4 saatlik ve günlük grafikler önerilir.

FARKI NEDİR
Hesaplamalar standart ve bilinen yöntemlerdir. Bu göstergenin kattığı şey öğretici katmandır: çizilen her nesnenin bağlama uygun bir açıklaması vardır, sinyal açıklamaları hacim onayını içerir ve panel tüm parçaların durumunu tek bir özet cümleye çevirir.

SINIRLAMALAR
- Pivot tabanlı destek/direnç seviyeleri, pivottan sonra belirlenen sayıda mum (varsayılan 10) kapandıktan sonra onaylanır, yani gecikmeli çıkar. Çizildikten sonra değişmez.
- Henüz kapanmamış canlı mumdaki etiketler, mum kapanana kadar çıkıp kaybolabilir.
- Hareketli ortalamalar fiyatın gerisinden gelir. Yatay piyasalarda kesişim ve tepki sinyalleri sık sık başarısız olur.
- Herhangi bir performans veya isabet iddiası yoktur. Eğitim amaçlı bir araçtır, yatırım tavsiyesi değildir.

## Source Code

````pine
//@version=6
indicator("Chart Reading Coach [EMA Trend, S/R, Candles]", shorttitle="Chart Coach", overlay=true, max_labels_count=500, max_lines_count=100)

// ================= SETTINGS =================
grpG = "Display"
lang        = input.string("English", "Language", options=["English", "Türkçe", "Español", "Português", "Русский", "Deutsch", "Français", "Bahasa Indonesia", "Tiếng Việt", "中文", "Kurdî (Kurmancî)"], group=grpG)
showNotes   = input.bool(true,  "Line notes", group=grpG)
showTable   = input.bool(true,  "Info panel", group=grpG)
showPattern = input.bool(true,  "Candle patterns", group=grpG)
showSR      = input.bool(true,  "Support & resistance", group=grpG)
showSignal  = input.bool(true,  "Signals", group=grpG)
showSmma    = input.bool(false, "SMMA line", group=grpG)
tableSizeS  = input.string("Small", "Panel text size", options=["Tiny", "Small", "Normal"], group=grpG)

grpP = "Lengths"
lenFast = input.int(20,  "Fast EMA", minval=1, group=grpP)
lenMid  = input.int(50,  "Middle EMA", minval=1, group=grpP)
lenSlow = input.int(200, "Slow EMA", minval=1, group=grpP)
lenSmma = input.int(50,  "SMMA length", minval=1, group=grpP)
rsiLen  = input.int(14,  "RSI length", minval=1, group=grpP)
pivLen  = input.int(10,  "S/R sensitivity (bars)", minval=3, group=grpP)
volMult = input.float(1.8, "Volume spike multiplier", step=0.1, group=grpP)
patGap  = input.int(8, "Min bars between patterns", minval=1, group=grpP)

// ================= TRANSLATION HELPERS =================
fL = str.tostring(lenFast)
mL = str.tostring(lenMid)
sL = str.tostring(lenSlow)

langIdx = switch lang
    "Türkçe"           => 1
    "Español"          => 2
    "Português"        => 3
    "Русский"          => 4
    "Deutsch"          => 5
    "Français"         => 6
    "Bahasa Indonesia" => 7
    "Tiếng Việt"       => 8
    "中文"             => 9
    "Kurdî (Kurmancî)" => 10
    => 0

fmt(string s) =>
    str.replace_all(str.replace_all(str.replace_all(s, "{F}", fL), "{M}", mL), "{S}", sL)

tx(string en, string tr, string es, string pt, string ru, string de, string fr, string ind, string vi, string zh, string ku) =>
    string s = switch langIdx
        1  => tr
        2  => es
        3  => pt
        4  => ru
        5  => de
        6  => fr
        7  => ind
        8  => vi
        9  => zh
        10 => ku
        => en
    fmt(s)

// ================= TEXTS =================
var string L_BUY  = tx("BUY", "AL", "COMPRA", "COMPRA", "ПОКУПКА", "KAUF", "ACHAT", "BELI", "MUA", "买入", "KIRÎN")
var string L_SELL = tx("SELL", "SAT", "VENTA", "VENDA", "ПРОДАЖА", "VERKAUF", "VENTE", "JUAL", "BÁN", "卖出", "FIROTIN")
var string L_PBB  = tx("Pullback BUY", "Tepki AL", "Rebote COMPRA", "Pullback COMPRA", "Откат ПОКУПКА", "Pullback KAUF", "Repli ACHAT", "Pullback BELI", "Hồi MUA", "回调买入", "Vegerîn KIRÎN")
var string L_PBS  = tx("Pullback SELL", "Tepki SAT", "Rebote VENTA", "Pullback VENDA", "Откат ПРОДАЖА", "Pullback VERKAUF", "Repli VENTE", "Pullback JUAL", "Hồi BÁN", "反弹卖出", "Vegerîn FIROTIN")

var string VOL_Y = tx("\n✅ Volume well above average: strong move, more reliable signal.", "\n✅ Hacim ortalamanın çok üstünde: hareket güçlü, sinyal daha güvenilir.", "\n✅ Volumen muy por encima de la media: movimiento fuerte, señal más fiable.", "\n✅ Volume bem acima da média: movimento forte, sinal mais confiável.", "\n✅ Объём намного выше среднего: сильное движение, сигнал надёжнее.", "\n✅ Volumen deutlich über dem Durchschnitt: starke Bewegung, zuverlässigeres Signal.", "\n✅ Volume bien au-dessus de la moyenne : mouvement fort, signal plus fiable.", "\n✅ Volume jauh di atas rata-rata: pergerakan kuat, sinyal lebih andal.", "\n✅ Khối lượng cao hơn nhiều so với trung bình: biến động mạnh, tín hiệu đáng tin hơn.", "\n✅ 成交量远高于平均：走势强劲，信号更可靠。", "\n✅ Qebare pir li ser navînê ye: tevgera xurt, nîşaneya pêbawertir.")
var string VOL_N = tx("\n⚠️ Normal volume: weak confirmation, be careful.", "\n⚠️ Hacim normal: onay zayıf, dikkatli ol.", "\n⚠️ Volumen normal: confirmación débil, ten cuidado.", "\n⚠️ Volume normal: confirmação fraca, tenha cuidado.", "\n⚠️ Обычный объём: слабое подтверждение, будьте осторожны.", "\n⚠️ Normales Volumen: schwache Bestätigung, sei vorsichtig.", "\n⚠️ Volume normal : confirmation faible, prudence.", "\n⚠️ Volume normal: konfirmasi lemah, berhati-hatilah.", "\n⚠️ Khối lượng bình thường: xác nhận yếu, hãy cẩn trọng.", "\n⚠️ 成交量一般：确认较弱，请谨慎。", "\n⚠️ Qebare asayî ye: piştrastkirin qels e, hişyar be.")

var string TT_BUY = tx("EMA CROSS BUY\nEMA {F} crossed above EMA {M}: short-term buyers got stronger.\nPrice above EMA {S}: main trend is up.\nRSI below 70: not overbought yet.\nStop idea: slightly below the last swing low.", "KESİŞİM AL\nEMA {F}, EMA {M} çizgisini yukarı kesti: kısa vadede alıcılar güçlendi.\nFiyat EMA {S} üstünde: ana trend yukarı.\nRSI 70 altında: henüz aşırı pahalı değil.\nStop fikri: son dibin biraz altı.", "CRUCE EMA: COMPRA\nLa EMA {F} cruzó por encima de la EMA {M}: los compradores se fortalecen a corto plazo.\nPrecio sobre la EMA {S}: la tendencia principal es alcista.\nRSI por debajo de 70: aún no está sobrecomprado.\nIdea de stop: justo debajo del último mínimo.", "CRUZAMENTO EMA: COMPRA\nA EMA {F} cruzou acima da EMA {M}: compradores mais fortes no curto prazo.\nPreço acima da EMA {S}: tendência principal de alta.\nRSI abaixo de 70: ainda não sobrecomprado.\nIdeia de stop: logo abaixo do último fundo.", "ПЕРЕСЕЧЕНИЕ EMA: ПОКУПКА\nEMA {F} пересекла EMA {M} снизу вверх: покупатели усилились в краткосроке.\nЦена выше EMA {S}: основной тренд восходящий.\nRSI ниже 70: перекупленности пока нет.\nИдея стопа: чуть ниже последнего минимума.", "EMA-KREUZUNG: KAUF\nEMA {F} hat EMA {M} nach oben gekreuzt: Käufer kurzfristig stärker.\nKurs über EMA {S}: Haupttrend aufwärts.\nRSI unter 70: noch nicht überkauft.\nStop-Idee: knapp unter dem letzten Tief.", "CROISEMENT EMA : ACHAT\nL'EMA {F} a croisé l'EMA {M} à la hausse : les acheteurs se renforcent à court terme.\nPrix au-dessus de l'EMA {S} : tendance principale haussière.\nRSI sous 70 : pas encore suracheté.\nIdée de stop : juste sous le dernier creux.", "PERSILANGAN EMA: BELI\nEMA {F} memotong ke atas EMA {M}: pembeli jangka pendek menguat.\nHarga di atas EMA {S}: tren utama naik.\nRSI di bawah 70: belum overbought.\nIde stop: sedikit di bawah titik terendah terakhir.", "EMA CẮT LÊN: MUA\nEMA {F} cắt lên trên EMA {M}: phe mua ngắn hạn mạnh lên.\nGiá trên EMA {S}: xu hướng chính là tăng.\nRSI dưới 70: chưa quá mua.\nGợi ý dừng lỗ: ngay dưới đáy gần nhất.", "EMA金叉买入\nEMA {F} 上穿 EMA {M}：短期买方增强。\n价格在 EMA {S} 之上：主要趋势向上。\nRSI 低于 70：尚未超买。\n止损参考：略低于最近低点。", "BIRÎNA EMA: KIRÎN\nEMA {F} ber bi jor EMA {M} birî: kiriyar di demeke kurt de xurt bûn.\nBiha li ser EMA {S} e: meyla sereke ber bi jor e.\nRSI di bin 70 de ye: hîn zêde biha nebûye.\nRamana stopê: hinekî di bin nizmtirîn xala dawî de.")
var string TT_SELL = tx("EMA CROSS SELL\nEMA {F} crossed below EMA {M}: short-term sellers got stronger.\nPrice below EMA {S}: main trend is down.\nRSI above 30: not oversold yet.\nConsider protecting open positions.", "KESİŞİM SAT\nEMA {F}, EMA {M} çizgisini aşağı kesti: kısa vadede satıcılar güçlendi.\nFiyat EMA {S} altında: ana trend aşağı.\nRSI 30 üstünde: henüz aşırı ucuz değil.\nElinde varsa korumayı düşün.", "CRUCE EMA: VENTA\nLa EMA {F} cruzó por debajo de la EMA {M}: los vendedores se fortalecen a corto plazo.\nPrecio bajo la EMA {S}: la tendencia principal es bajista.\nRSI por encima de 30: aún no está sobrevendido.\nConsidera proteger tus posiciones abiertas.", "CRUZAMENTO EMA: VENDA\nA EMA {F} cruzou abaixo da EMA {M}: vendedores mais fortes no curto prazo.\nPreço abaixo da EMA {S}: tendência principal de baixa.\nRSI acima de 30: ainda não sobrevendido.\nConsidere proteger posições abertas.", "ПЕРЕСЕЧЕНИЕ EMA: ПРОДАЖА\nEMA {F} пересекла EMA {M} сверху вниз: продавцы усилились в краткосроке.\nЦена ниже EMA {S}: основной тренд нисходящий.\nRSI выше 30: перепроданности пока нет.\nПодумайте о защите открытых позиций.", "EMA-KREUZUNG: VERKAUF\nEMA {F} hat EMA {M} nach unten gekreuzt: Verkäufer kurzfristig stärker.\nKurs unter EMA {S}: Haupttrend abwärts.\nRSI über 30: noch nicht überverkauft.\nOffene Positionen absichern.", "CROISEMENT EMA : VENTE\nL'EMA {F} a croisé l'EMA {M} à la baisse : les vendeurs se renforcent à court terme.\nPrix sous l'EMA {S} : tendance principale baissière.\nRSI au-dessus de 30 : pas encore survendu.\nPensez à protéger vos positions ouvertes.", "PERSILANGAN EMA: JUAL\nEMA {F} memotong ke bawah EMA {M}: penjual jangka pendek menguat.\nHarga di bawah EMA {S}: tren utama turun.\nRSI di atas 30: belum oversold.\nPertimbangkan melindungi posisi terbuka.", "EMA CẮT XUỐNG: BÁN\nEMA {F} cắt xuống dưới EMA {M}: phe bán ngắn hạn mạnh lên.\nGiá dưới EMA {S}: xu hướng chính là giảm.\nRSI trên 30: chưa quá bán.\nCân nhắc bảo vệ các vị thế đang mở.", "EMA死叉卖出\nEMA {F} 下穿 EMA {M}：短期卖方增强。\n价格在 EMA {S} 之下：主要趋势向下。\nRSI 高于 30：尚未超卖。\n考虑保护已有持仓。", "BIRÎNA EMA: FIROTIN\nEMA {F} ber bi jêr EMA {M} birî: firoşkar di demeke kurt de xurt bûn.\nBiha di bin EMA {S} de ye: meyla sereke ber bi jêr e.\nRSI li ser 30 e: hîn zêde erzan nebûye.\nParastina pozîsyonên vekirî bifikire.")
var string TT_PBB = tx("PULLBACK BUY\nIn an uptrend, price pulled back to EMA {M}, touched it and closed green above it.\nEMA {M} acted as support; the trend may continue.\nStop idea: slightly below EMA {M}.", "TEPKİ AL\nYükselen trendde fiyat EMA {M} çizgisine geri çekildi, değdi ve üstünde yeşil kapattı.\nEMA {M} destek gibi çalıştı; trend devam edebilir.\nStop fikri: EMA {M} çizgisinin biraz altı.", "REBOTE: COMPRA\nEn tendencia alcista, el precio retrocedió hasta la EMA {M}, la tocó y cerró en verde por encima.\nLa EMA {M} actuó como soporte; la tendencia puede continuar.\nIdea de stop: justo debajo de la EMA {M}.", "PULLBACK: COMPRA\nEm tendência de alta, o preço recuou até a EMA {M}, tocou nela e fechou verde acima.\nA EMA {M} funcionou como suporte; a tendência pode continuar.\nIdeia de stop: logo abaixo da EMA {M}.", "ОТКАТ: ПОКУПКА\nВ восходящем тренде цена откатилась к EMA {M}, коснулась её и закрылась зелёной свечой выше.\nEMA {M} сработала как поддержка; тренд может продолжиться.\nИдея стопа: чуть ниже EMA {M}.", "PULLBACK: KAUF\nIm Aufwärtstrend ist der Kurs bis zur EMA {M} zurückgelaufen, hat sie berührt und grün darüber geschlossen.\nDie EMA {M} wirkte als Unterstützung; der Trend kann weiterlaufen.\nStop-Idee: knapp unter der EMA {M}.", "REPLI : ACHAT\nEn tendance haussière, le prix est revenu sur l'EMA {M}, l'a touchée et a clôturé en vert au-dessus.\nL'EMA {M} a servi de support ; la tendance peut continuer.\nIdée de stop : juste sous l'EMA {M}.", "PULLBACK: BELI\nDalam tren naik, harga turun ke EMA {M}, menyentuhnya, lalu ditutup hijau di atasnya.\nEMA {M} berfungsi sebagai support; tren bisa berlanjut.\nIde stop: sedikit di bawah EMA {M}.", "HỒI VỀ: MUA\nTrong xu hướng tăng, giá hồi về EMA {M}, chạm vào và đóng nến xanh phía trên.\nEMA {M} đóng vai trò hỗ trợ; xu hướng có thể tiếp diễn.\nGợi ý dừng lỗ: ngay dưới EMA {M}.", "回调买入\n上升趋势中，价格回调至 EMA {M}，触及后以阳线收在其上方。\nEMA {M} 起到支撑作用，趋势可能延续。\n止损参考：略低于 EMA {M}。", "VEGERÎN: KIRÎN\nDi meyla ber bi jor de biha vegeriya EMA {M}, lê ket û bi kesk li ser wê girt.\nEMA {M} wek piştgirî xebitî; dibe ku meyl berdewam bike.\nRamana stopê: hinekî di bin EMA {M} de.")
var string TT_PBS = tx("PULLBACK SELL\nIn a downtrend, price rallied to EMA {M}, touched it and closed red below it.\nEMA {M} acted as resistance; the decline may continue.", "TEPKİ SAT\nDüşen trendde fiyat EMA {M} çizgisine kadar yükseldi, değdi ve altında kırmızı kapattı.\nEMA {M} direnç gibi çalıştı; düşüş devam edebilir.", "REBOTE: VENTA\nEn tendencia bajista, el precio subió hasta la EMA {M}, la tocó y cerró en rojo por debajo.\nLa EMA {M} actuó como resistencia; la caída puede continuar.", "PULLBACK: VENDA\nEm tendência de baixa, o preço subiu até a EMA {M}, tocou nela e fechou vermelho abaixo.\nA EMA {M} funcionou como resistência; a queda pode continuar.", "ОТКАТ: ПРОДАЖА\nВ нисходящем тренде цена поднялась к EMA {M}, коснулась её и закрылась красной свечой ниже.\nEMA {M} сработала как сопротивление; снижение может продолжиться.", "PULLBACK: VERKAUF\nIm Abwärtstrend ist der Kurs bis zur EMA {M} gestiegen, hat sie berührt und rot darunter geschlossen.\nDie EMA {M} wirkte als Widerstand; der Rückgang kann weitergehen.", "REPLI : VENTE\nEn tendance baissière, le prix est remonté jusqu'à l'EMA {M}, l'a touchée et a clôturé en rouge en dessous.\nL'EMA {M} a servi de résistance ; la baisse peut continuer.", "PULLBACK: JUAL\nDalam tren turun, harga naik ke EMA {M}, menyentuhnya, lalu ditutup merah di bawahnya.\nEMA {M} berfungsi sebagai resistance; penurunan bisa berlanjut.", "HỒI LÊN: BÁN\nTrong xu hướng giảm, giá hồi lên EMA {M}, chạm vào và đóng nến đỏ phía dưới.\nEMA {M} đóng vai trò kháng cự; đà giảm có thể tiếp diễn.", "反弹卖出\n下降趋势中，价格反弹至 EMA {M}，触及后以阴线收在其下方。\nEMA {M} 起到阻力作用，下跌可能延续。", "VEGERÎN: FIROTIN\nDi meyla ber bi jêr de biha heta EMA {M} rabû, lê ket û bi sor di bin wê de girt.\nEMA {M} wek berxwedan xebitî; dibe ku daketin berdewam bike.")

var string P_BE = tx("Engulf↑", "Yutan↑", "Envolvente↑", "Engolfo↑", "Поглощ.↑", "Engulfing↑", "Englobante↑", "Engulfing↑", "Nhấn chìm↑", "吞没↑", "Daqurtandin↑")
var string P_SE = tx("Engulf↓", "Yutan↓", "Envolvente↓", "Engolfo↓", "Поглощ.↓", "Engulfing↓", "Englobante↓", "Engulfing↓", "Nhấn chìm↓", "吞没↓", "Daqurtandin↓")
var string P_H  = tx("Hammer", "Çekiç", "Martillo", "Martelo", "Молот", "Hammer", "Marteau", "Hammer", "Búa", "锤子线", "Çakûç")
var string P_S  = tx("Shoot. star", "Kayan Y.", "Estrella fugaz", "Estrela cadente", "Падающая звезда", "Sternschnuppe", "Étoile filante", "Shooting star", "Sao băng", "射击之星", "Stêrka ketî")

var string TT_BE = tx("BULLISH ENGULFING\nAfter a decline, a large green candle fully engulfed the previous red candle.\nBuyers overpowered sellers: possible upward reversal. More meaningful at support.", "YUTAN BOĞA\nDüşüşten sonra büyük yeşil mum, önceki kırmızı mumu tamamen yuttu.\nAlıcılar satıcıları ezdi: yukarı dönüş işareti. Destekte çıkarsa daha değerli.", "ENVOLVENTE ALCISTA\nTras una caída, una gran vela verde envolvió por completo la vela roja anterior.\nLos compradores superaron a los vendedores: posible giro al alza. Más relevante en un soporte.", "ENGOLFO DE ALTA\nApós uma queda, um grande candle verde engoliu totalmente o candle vermelho anterior.\nCompradores superaram vendedores: possível reversão de alta. Mais relevante em suporte.", "БЫЧЬЕ ПОГЛОЩЕНИЕ\nПосле снижения большая зелёная свеча полностью поглотила предыдущую красную.\nПокупатели пересилили продавцов: возможен разворот вверх. Важнее на уровне поддержки.", "BULLISH ENGULFING\nNach einem Rückgang hat eine große grüne Kerze die vorherige rote Kerze vollständig umschlossen.\nKäufer haben die Verkäufer überwältigt: mögliche Umkehr nach oben. Aussagekräftiger an einer Unterstützung.", "AVALEMENT HAUSSIER\nAprès une baisse, une grande bougie verte a complètement englobé la bougie rouge précédente.\nLes acheteurs ont pris le dessus : retournement haussier possible. Plus significatif sur un support.", "BULLISH ENGULFING\nSetelah penurunan, lilin hijau besar menelan penuh lilin merah sebelumnya.\nPembeli mengalahkan penjual: kemungkinan pembalikan naik. Lebih bermakna di area support.", "NẾN NHẤN CHÌM TĂNG\nSau một đợt giảm, một nến xanh lớn nhấn chìm hoàn toàn nến đỏ trước đó.\nPhe mua áp đảo phe bán: có thể đảo chiều tăng. Ý nghĩa hơn khi ở vùng hỗ trợ.", "看涨吞没\n下跌之后，一根大阳线完全吞没了前一根阴线。\n买方压倒卖方：可能向上反转。出现在支撑位时更有意义。", "DAQURTANDINA BILINDBÛNÊ\nPiştî daketinê, momeke kesk a mezin moma sor a berê bi tevahî daqurtand.\nKiriyar ji firoşkaran xurttir bûn: dibe ku ber bi jor bizivire. Li ser piştgiriyê girîngtir e.")
var string TT_SE = tx("BEARISH ENGULFING\nAfter a rise, a large red candle fully engulfed the previous green candle.\nSellers took control: possible downward reversal. More meaningful at resistance.", "YUTAN AYI\nYükselişten sonra büyük kırmızı mum, önceki yeşil mumu tamamen yuttu.\nSatıcılar kontrolü aldı: aşağı dönüş işareti. Dirençte çıkarsa daha değerli.", "ENVOLVENTE BAJISTA\nTras una subida, una gran vela roja envolvió por completo la vela verde anterior.\nLos vendedores tomaron el control: posible giro a la baja. Más relevante en una resistencia.", "ENGOLFO DE BAIXA\nApós uma alta, um grande candle vermelho engoliu totalmente o candle verde anterior.\nVendedores assumiram o controle: possível reversão de baixa. Mais relevante em resistência.", "МЕДВЕЖЬЕ ПОГЛОЩЕНИЕ\nПосле роста большая красная свеча полностью поглотила предыдущую зелёную.\nПродавцы взяли контроль: возможен разворот вниз. Важнее на уровне сопротивления.", "BEARISH ENGULFING\nNach einem Anstieg hat eine große rote Kerze die vorherige grüne Kerze vollständig umschlossen.\nVerkäufer haben die Kontrolle übernommen: mögliche Umkehr nach unten. Aussagekräftiger an einem Widerstand.", "AVALEMENT BAISSIER\nAprès une hausse, une grande bougie rouge a complètement englobé la bougie verte précédente.\nLes vendeurs ont pris le contrôle : retournement baissier possible. Plus significatif sur une résistance.", "BEARISH ENGULFING\nSetelah kenaikan, lilin merah besar menelan penuh lilin hijau sebelumnya.\nPenjual mengambil alih: kemungkinan pembalikan turun. Lebih bermakna di area resistance.", "NẾN NHẤN CHÌM GIẢM\nSau một đợt tăng, một nến đỏ lớn nhấn chìm hoàn toàn nến xanh trước đó.\nPhe bán nắm quyền kiểm soát: có thể đảo chiều giảm. Ý nghĩa hơn khi ở vùng kháng cự.", "看跌吞没\n上涨之后，一根大阴线完全吞没了前一根阳线。\n卖方掌控局面：可能向下反转。出现在阻力位时更有意义。", "DAQURTANDINA DAKETINÊ\nPiştî bilindbûnê, momeke sor a mezin moma kesk a berê bi tevahî daqurtand.\nFiroşkar kontrol girtin: dibe ku ber bi jêr bizivire. Li ser berxwedanê girîngtir e.")
var string TT_H = tx("HAMMER\nLong lower wick: price was pushed down but buyers brought it back.\nAfter a decline it may mark a bottom. Confirmed if the next candle closes green.", "ÇEKİÇ\nUzun alt fitil: fiyat aşağı itildi ama alıcılar geri topladı.\nDüşüşten sonra dip sinyali olabilir. Sonraki mum yeşil kapanırsa onaylanır.", "MARTILLO\nMecha inferior larga: el precio fue empujado abajo pero los compradores lo recuperaron.\nTras una caída puede marcar un suelo. Se confirma si la siguiente vela cierra en verde.", "MARTELO\nPavio inferior longo: o preço foi empurrado para baixo, mas os compradores o recuperaram.\nApós uma queda pode marcar um fundo. Confirmado se o próximo candle fechar verde.", "МОЛОТ\nДлинная нижняя тень: цену продавили вниз, но покупатели вернули её.\nПосле снижения может означать дно. Подтверждение: следующая свеча закрывается зелёной.", "HAMMER\nLanger unterer Docht: Der Kurs wurde nach unten gedrückt, aber Käufer holten ihn zurück.\nNach einem Rückgang kann das einen Boden markieren. Bestätigt, wenn die nächste Kerze grün schließt.", "MARTEAU\nLongue mèche basse : le prix a été poussé vers le bas mais les acheteurs l'ont ramené.\nAprès une baisse, peut marquer un creux. Confirmé si la bougie suivante clôture en vert.", "HAMMER\nSumbu bawah panjang: harga sempat ditekan turun tetapi pembeli mengangkatnya kembali.\nSetelah penurunan bisa menandai dasar. Terkonfirmasi jika lilin berikutnya ditutup hijau.", "NẾN BÚA\nRâu dưới dài: giá bị đẩy xuống nhưng phe mua đã kéo lên lại.\nSau một đợt giảm có thể báo hiệu đáy. Được xác nhận nếu nến tiếp theo đóng xanh.", "锤子线\n长下影线：价格被压低，但买方将其拉回。\n下跌后出现可能是底部信号。若下一根K线收阳则得到确认。", "ÇAKÛÇ\nFitîla jêrîn dirêj e: biha ber bi jêr hat pêlkirin lê kiriyaran vegerand.\nPiştî daketinê dibe ku nîşana binî be. Heke moma din kesk bigire, tê piştrastkirin.")
var string TT_S = tx("SHOOTING STAR\nLong upper wick: price went up but sellers pushed it back.\nAfter a rise it may mark a top. Confirmed if the next candle closes red.", "KAYAN YILDIZ\nUzun üst fitil: fiyat yükseldi ama satıcılar geri bastırdı.\nYükselişten sonra tepe sinyali olabilir. Sonraki mum kırmızı kapanırsa onaylanır.", "ESTRELLA FUGAZ\nMecha superior larga: el precio subió pero los vendedores lo empujaron abajo.\nTras una subida puede marcar un techo. Se confirma si la siguiente vela cierra en rojo.", "ESTRELA CADENTE\nPavio superior longo: o preço subiu, mas os vendedores o empurraram de volta.\nApós uma alta pode marcar um topo. Confirmado se o próximo candle fechar vermelho.", "ПАДАЮЩАЯ ЗВЕЗДА\nДлинная верхняя тень: цена выросла, но продавцы вернули её вниз.\nПосле роста может означать вершину. Подтверждение: следующая свеча закрывается красной.", "STERNSCHNUPPE\nLanger oberer Docht: Der Kurs stieg, aber Verkäufer drückten ihn zurück.\nNach einem Anstieg kann das ein Hoch markieren. Bestätigt, wenn die nächste Kerze rot schließt.", "ÉTOILE FILANTE\nLongue mèche haute : le prix a monté mais les vendeurs l'ont repoussé.\nAprès une hausse, peut marquer un sommet. Confirmé si la bougie suivante clôture en rouge.", "SHOOTING STAR\nSumbu atas panjang: harga sempat naik tetapi penjual menekannya kembali.\nSetelah kenaikan bisa menandai puncak. Terkonfirmasi jika lilin berikutnya ditutup merah.", "NẾN SAO BĂNG\nRâu trên dài: giá tăng lên nhưng phe bán đã đẩy xuống lại.\nSau một đợt tăng có thể báo hiệu đỉnh. Được xác nhận nếu nến tiếp theo đóng đỏ.", "射击之星\n长上影线：价格上涨，但卖方将其压回。\n上涨后出现可能是顶部信号。若下一根K线收阴则得到确认。", "STÊRKA KETÎ\nFitîla jorîn dirêj e: biha bilind bû lê firoşkaran paş ve pêl kir.\nPiştî bilindbûnê dibe ku nîşana serî be. Heke moma din sor bigire, tê piştrastkirin.")

var string L_RES = tx("Resistance", "Direnç", "Resistencia", "Resistência", "Сопротивление", "Widerstand", "Résistance", "Resistance", "Kháng cự", "阻力", "Berxwedan")
var string L_SUP = tx("Support", "Destek", "Soporte", "Suporte", "Поддержка", "Unterstützung", "Support", "Support", "Hỗ trợ", "支撑", "Piştgirî")
var string TT_RES = tx("RESISTANCE (ceiling)\nPrice rose to here and turned back; sellers are strong here.\nA clear close above it can speed up the rise, and the level may turn into support.", "DİRENÇ (tavan)\nFiyat buraya kadar çıkıp geri döndü; satıcılar burada güçlü.\nÜstünde net kapanış yükselişi hızlandırabilir, seviye desteğe dönüşebilir.", "RESISTENCIA (techo)\nEl precio subió hasta aquí y retrocedió; los vendedores son fuertes aquí.\nUn cierre claro por encima puede acelerar la subida y el nivel puede convertirse en soporte.", "RESISTÊNCIA (teto)\nO preço subiu até aqui e voltou; os vendedores são fortes aqui.\nUm fechamento claro acima pode acelerar a alta e o nível pode virar suporte.", "СОПРОТИВЛЕНИЕ (потолок)\nЦена дошла сюда и развернулась; здесь сильны продавцы.\nУверенное закрытие выше может ускорить рост, и уровень может стать поддержкой.", "WIDERSTAND (Decke)\nDer Kurs stieg bis hier und drehte ab; hier sind Verkäufer stark.\nEin klarer Schluss darüber kann den Anstieg beschleunigen, und die Marke kann zur Unterstützung werden.", "RÉSISTANCE (plafond)\nLe prix est monté jusqu'ici puis a reculé ; les vendeurs y sont forts.\nUne clôture nette au-dessus peut accélérer la hausse et le niveau peut devenir un support.", "RESISTANCE (atap)\nHarga naik sampai sini lalu berbalik; penjual kuat di area ini.\nPenutupan jelas di atasnya bisa mempercepat kenaikan, dan level ini bisa menjadi support.", "KHÁNG CỰ (trần)\nGiá tăng đến đây rồi quay đầu; phe bán mạnh ở vùng này.\nĐóng nến rõ ràng phía trên có thể đẩy nhanh đà tăng, và vùng này có thể thành hỗ trợ.", "阻力（天花板）\n价格涨到这里后回落，卖方在此较强。\n若明确收在其上方，涨势可能加速，该位置可能转为支撑。", "BERXWEDAN (ban)\nBiha heta vir bilind bû û vegeriya; firoşkar li vir xurt in.\nGirtineke zelal li ser wê dikare bilindbûnê bilezîne, û ev ast dibe ku bibe piştgirî.")
var string TT_SUP = tx("SUPPORT (floor)\nPrice fell to here and bounced; buyers are strong here.\nA clear close below it can speed up the decline, and the level may turn into resistance.", "DESTEK (taban)\nFiyat buraya kadar düşüp geri yükseldi; alıcılar burada güçlü.\nAltında net kapanış düşüşü hızlandırabilir, seviye dirence dönüşebilir.", "SOPORTE (suelo)\nEl precio cayó hasta aquí y rebotó; los compradores son fuertes aquí.\nUn cierre claro por debajo puede acelerar la caída y el nivel puede convertirse en resistencia.", "SUPORTE (piso)\nO preço caiu até aqui e subiu de volta; os compradores são fortes aqui.\nUm fechamento claro abaixo pode acelerar a queda e o nível pode virar resistência.", "ПОДДЕРЖКА (пол)\nЦена опустилась сюда и отскочила; здесь сильны покупатели.\nУверенное закрытие ниже может ускорить падение, и уровень может стать сопротивлением.", "UNTERSTÜTZUNG (Boden)\nDer Kurs fiel bis hier und prallte ab; hier sind Käufer stark.\nEin klarer Schluss darunter kann den Rückgang beschleunigen, und die Marke kann zum Widerstand werden.", "SUPPORT (plancher)\nLe prix est descendu jusqu'ici puis a rebondi ; les acheteurs y sont forts.\nUne clôture nette en dessous peut accélérer la baisse et le niveau peut devenir une résistance.", "SUPPORT (lantai)\nHarga turun sampai sini lalu memantul; pembeli kuat di area ini.\nPenutupan jelas di bawahnya bisa mempercepat penurunan, dan level ini bisa menjadi resistance.", "HỖ TRỢ (sàn)\nGiá giảm đến đây rồi bật lên; phe mua mạnh ở vùng này.\nĐóng nến rõ ràng phía dưới có thể đẩy nhanh đà giảm, và vùng này có thể thành kháng cự.", "支撑（地板）\n价格跌到这里后反弹，买方在此较强。\n若明确收在其下方，跌势可能加速，该位置可能转为阻力。", "PIŞTGIRÎ (erd)\nBiha heta vir daket û vegeriya; kiriyar li vir xurt in.\nGirtineke zelal di bin wê de dikare daketinê bilezîne, û ev ast dibe ku bibe berxwedan.")

var string N_F = tx(" · short term", " · kısa vade", " · corto plazo", " · curto prazo", " · краткосрок", " · kurzfristig", " · court terme", " · jangka pendek", " · ngắn hạn", " · 短期", " · demkurt")
var string N_M = tx(" · medium term", " · orta vade", " · medio plazo", " · médio prazo", " · среднесрок", " · mittelfristig", " · moyen terme", " · jangka menengah", " · trung hạn", " · 中期", " · demnavîn")
var string N_S = tx(" · MAIN TREND", " · ANA TREND", " · TENDENCIA PRINCIPAL", " · TENDÊNCIA PRINCIPAL", " · ОСНОВНОЙ ТРЕНД", " · HAUPTTREND", " · TENDANCE PRINCIPALE", " · TREN UTAMA", " · XU HƯỚNG CHÍNH", " · 主要趋势", " · MEYLA SEREKE")
var string TT_NF = tx("EMA {F} (thin light blue)\nAverage of the last ~{F} candles; reacts quickly.\nPrice above it: buyers lead in the short term. In strong trends price touches it and continues.", "EMA {F} (ince açık mavi)\nSon ~{F} mumun ortalaması; hızlı tepki verir.\nFiyat üstündeyse kısa vadede alıcılar önde. Güçlü trendlerde fiyat buna değip devam eder.", "EMA {F} (azul claro fina)\nMedia de las últimas ~{F} velas; reacciona rápido.\nPrecio por encima: los compradores lideran a corto plazo. En tendencias fuertes el precio la toca y continúa.", "EMA {F} (azul-claro fina)\nMédia dos últimos ~{F} candles; reage rápido.\nPreço acima: compradores lideram no curto prazo. Em tendências fortes o preço toca nela e segue.", "EMA {F} (тонкая голубая)\nСреднее за ~{F} последних свечей; реагирует быстро.\nЦена выше: в краткосроке лидируют покупатели. В сильном тренде цена касается её и продолжает движение.", "EMA {F} (dünn, hellblau)\nDurchschnitt der letzten ~{F} Kerzen; reagiert schnell.\nKurs darüber: Käufer führen kurzfristig. In starken Trends berührt der Kurs sie und läuft weiter.", "EMA {F} (fine, bleu clair)\nMoyenne des ~{F} dernières bougies ; réagit vite.\nPrix au-dessus : les acheteurs mènent à court terme. En tendance forte, le prix la touche et continue.", "EMA {F} (biru muda tipis)\nRata-rata ~{F} lilin terakhir; bereaksi cepat.\nHarga di atasnya: pembeli unggul jangka pendek. Dalam tren kuat harga menyentuhnya lalu melanjutkan.", "EMA {F} (xanh nhạt, mảnh)\nTrung bình của ~{F} nến gần nhất; phản ứng nhanh.\nGiá ở trên: phe mua dẫn dắt ngắn hạn. Trong xu hướng mạnh giá chạm vào rồi tiếp tục.", "EMA {F}（细浅蓝线）\n最近约 {F} 根K线的均值，反应较快。\n价格在其上方：短期买方占优。强势趋势中价格触及后会继续前进。", "EMA {F} (şînê vekirî yê zirav)\nNavîniya ~{F} momên dawî; zû bertek nîşan dide.\nBiha li ser wê ye: di demeke kurt de kiriyar pêş in. Di meylên xurt de biha lê dikeve û berdewam dike.")
var string TT_NM = tx("EMA {M} (orange)\nMedium-term trend. Often acts as support/resistance on pullbacks.\nEMA {F} crossing above it: short term strengthening; crossing below: weakening.", "EMA {M} (turuncu)\nOrta vadeli trend. Geri çekilmelerde sık sık destek/direnç olur.\nEMA {F} yukarı keserse kısa vade güçleniyor, aşağı keserse zayıflıyor.", "EMA {M} (naranja)\nTendencia de medio plazo. Suele actuar como soporte/resistencia en retrocesos.\nSi la EMA {F} la cruza al alza: el corto plazo se fortalece; a la baja: se debilita.", "EMA {M} (laranja)\nTendência de médio prazo. Costuma atuar como suporte/resistência nas correções.\nSe a EMA {F} cruzar para cima: curto prazo se fortalece; para baixo: enfraquece.", "EMA {M} (оранжевая)\nСреднесрочный тренд. На откатах часто служит поддержкой/сопротивлением.\nEMA {F} пересекает её вверх: краткосрок усиливается; вниз: ослабевает.", "EMA {M} (orange)\nMittelfristiger Trend. Wirkt bei Rücksetzern oft als Unterstützung/Widerstand.\nKreuzt EMA {F} sie nach oben: kurzfristig stärker; nach unten: schwächer.", "EMA {M} (orange)\nTendance moyen terme. Sert souvent de support/résistance lors des replis.\nSi l'EMA {F} la croise à la hausse : le court terme se renforce ; à la baisse : il s'affaiblit.", "EMA {M} (oranye)\nTren jangka menengah. Sering menjadi support/resistance saat pullback.\nEMA {F} memotong ke atas: jangka pendek menguat; ke bawah: melemah.", "EMA {M} (cam)\nXu hướng trung hạn. Thường là hỗ trợ/kháng cự khi giá điều chỉnh.\nEMA {F} cắt lên: ngắn hạn mạnh lên; cắt xuống: yếu đi.", "EMA {M}（橙线）\n中期趋势。回调时常起到支撑/阻力作用。\nEMA {F} 上穿：短期走强；下穿：短期走弱。", "EMA {M} (porteqalî)\nMeyla demnavîn. Di vegerînan de gelek caran wek piştgirî/berxwedan dixebite.\nEMA {F} wê ber bi jor bibire: demkurt xurt dibe; ber bi jêr: qels dibe.")
var string TT_NS = tx("EMA {S} (thick red)\nThe most important line, watched worldwide.\nPrice ABOVE: bull market, think long side.\nPrice BELOW: bear market, be very careful with buys.", "EMA {S} (kalın kırmızı)\nEn önemli çizgi, tüm dünyada takip edilir.\nFiyat ÜSTÜNDE: boğa piyasası, alım yönlü düşün.\nFiyat ALTINDA: ayı piyasası, alımlarda çok temkinli ol.", "EMA {S} (roja gruesa)\nLa línea más importante, seguida en todo el mundo.\nPrecio ENCIMA: mercado alcista, piensa en compras.\nPrecio DEBAJO: mercado bajista, mucha cautela al comprar.", "EMA {S} (vermelha grossa)\nA linha mais importante, acompanhada no mundo todo.\nPreço ACIMA: mercado de alta, pense em compras.\nPreço ABAIXO: mercado de baixa, muito cuidado ao comprar.", "EMA {S} (толстая красная)\nСамая важная линия, за ней следит весь мир.\nЦена ВЫШЕ: бычий рынок, думайте о покупках.\nЦена НИЖЕ: медвежий рынок, с покупками очень осторожно.", "EMA {S} (dick, rot)\nDie wichtigste Linie, weltweit beachtet.\nKurs DARÜBER: Bullenmarkt, eher Long denken.\nKurs DARUNTER: Bärenmarkt, bei Käufen sehr vorsichtig sein.", "EMA {S} (rouge épaisse)\nLa ligne la plus importante, suivie dans le monde entier.\nPrix AU-DESSUS : marché haussier, privilégiez l'achat.\nPrix EN DESSOUS : marché baissier, grande prudence à l'achat.", "EMA {S} (merah tebal)\nGaris terpenting, dipantau di seluruh dunia.\nHarga DI ATAS: pasar bullish, utamakan posisi beli.\nHarga DI BAWAH: pasar bearish, sangat berhati-hati saat membeli.", "EMA {S} (đỏ, đậm)\nĐường quan trọng nhất, được theo dõi trên toàn thế giới.\nGiá Ở TRÊN: thị trường tăng, ưu tiên mua.\nGiá Ở DƯỚI: thị trường giảm, hết sức thận trọng khi mua.", "EMA {S}（粗红线）\n最重要的一条线，全球交易者都在关注。\n价格在其上方：牛市，以做多思路为主。\n价格在其下方：熊市，买入需非常谨慎。", "EMA {S} (sorê stûr)\nXeta herî girîng, li seranserê cîhanê tê şopandin.\nBiha LI SER: bazara bilindbûnê, li kirînê bifikire.\nBiha LI BIN: bazara daketinê, di kirînê de pir hişyar be.")
var string TT_SMMA = tx("SMMA (purple)\nSmoothed moving average. Slower than EMA: fewer false signals but more lag.", "SMMA (mor)\nDüzleştirilmiş ortalama. EMA'dan yavaş: daha az sahte sinyal ama daha geç.", "SMMA (morada)\nMedia móvil suavizada. Más lenta que la EMA: menos señales falsas pero más retraso.", "SMMA (roxa)\nMédia móvel suavizada. Mais lenta que a EMA: menos sinais falsos, porém mais atraso.", "SMMA (фиолетовая)\nСглаженная скользящая средняя. Медленнее EMA: меньше ложных сигналов, но больше запаздывание.", "SMMA (lila)\nGeglätteter gleitender Durchschnitt. Langsamer als EMA: weniger Fehlsignale, aber mehr Verzögerung.", "SMMA (violette)\nMoyenne mobile lissée. Plus lente que l'EMA : moins de faux signaux mais plus de retard.", "SMMA (ungu)\nRata-rata bergerak yang dihaluskan. Lebih lambat dari EMA: sinyal palsu lebih sedikit, tetapi lebih tertinggal.", "SMMA (tím)\nĐường trung bình làm mượt. Chậm hơn EMA: ít tín hiệu nhiễu hơn nhưng trễ hơn.", "SMMA（紫线）\n平滑移动平均线。比 EMA 更慢：假信号更少，但滞后更多。", "SMMA (mor)\nNavîniya livok a nermkirî. Ji EMA hêdîtir e: nîşaneyên şaş kêmtir in lê derengtir e.")

var string T_TITLE = tx("📘 CHART COACH", "📘 GRAFİK ÖĞRETMENİ", "📘 COACH DE GRÁFICOS", "📘 COACH DE GRÁFICOS", "📘 ТРЕНЕР ПО ГРАФИКАМ", "📘 CHART-COACH", "📘 COACH GRAPHIQUE", "📘 PELATIH GRAFIK", "📘 HUẤN LUYỆN ĐỌC BIỂU ĐỒ", "📘 图表教练", "📘 RÊBERÊ GRAFÎKÊ")
var string K_MAIN  = tx("Main trend", "Ana trend", "Tendencia principal", "Tendência principal", "Основной тренд", "Haupttrend", "Tendance principale", "Tren utama", "Xu hướng chính", "主要趋势", "Meyla sereke")
var string K_SHORT = tx("Short trend", "Kısa trend", "Tendencia corta", "Tendência curta", "Краткосрочный тренд", "Kurzfristiger Trend", "Tendance courte", "Tren pendek", "Xu hướng ngắn", "短期趋势", "Meyla kurt")
var string K_VOL   = tx("Volume", "Hacim", "Volumen", "Volume", "Объём", "Volumen", "Volume", "Volume", "Khối lượng", "成交量", "Qebare")
var string K_LAST  = tx("Last candle", "Son mum", "Última vela", "Último candle", "Последняя свеча", "Letzte Kerze", "Dernière bougie", "Lilin terakhir", "Nến gần nhất", "最新K线", "Moma dawî")
var string V_UP    = tx("UP ✅ (price above EMA{S})", "YUKARI ✅ (fiyat EMA{S} üstünde)", "ALCISTA ✅ (precio sobre EMA{S})", "ALTA ✅ (preço acima da EMA{S})", "ВВЕРХ ✅ (цена выше EMA{S})", "AUFWÄRTS ✅ (Kurs über EMA{S})", "HAUSSIÈRE ✅ (prix au-dessus de l'EMA{S})", "NAIK ✅ (harga di atas EMA{S})", "TĂNG ✅ (giá trên EMA{S})", "向上 ✅（价格在 EMA{S} 之上）", "JOR ✅ (biha li ser EMA{S})")
var string V_DN    = tx("DOWN ❌ (price below EMA{S})", "AŞAĞI ❌ (fiyat EMA{S} altında)", "BAJISTA ❌ (precio bajo EMA{S})", "BAIXA ❌ (preço abaixo da EMA{S})", "ВНИЗ ❌ (цена ниже EMA{S})", "ABWÄRTS ❌ (Kurs unter EMA{S})", "BAISSIÈRE ❌ (prix sous l'EMA{S})", "TURUN ❌ (harga di bawah EMA{S})", "GIẢM ❌ (giá dưới EMA{S})", "向下 ❌（价格在 EMA{S} 之下）", "JÊR ❌ (biha di bin EMA{S} de)")
var string V_STR   = tx("Strengthening (EMA{F} > EMA{M})", "Güçleniyor (EMA{F} > EMA{M})", "Fortaleciéndose (EMA{F} > EMA{M})", "Fortalecendo (EMA{F} > EMA{M})", "Усиливается (EMA{F} > EMA{M})", "Stärker werdend (EMA{F} > EMA{M})", "Se renforce (EMA{F} > EMA{M})", "Menguat (EMA{F} > EMA{M})", "Mạnh lên (EMA{F} > EMA{M})", "走强（EMA{F} > EMA{M}）", "Xurt dibe (EMA{F} > EMA{M})")
var string V_WEAK  = tx("Weakening (EMA{F} < EMA{M})", "Zayıflıyor (EMA{F} < EMA{M})", "Debilitándose (EMA{F} < EMA{M})", "Enfraquecendo (EMA{F} < EMA{M})", "Ослабевает (EMA{F} < EMA{M})", "Schwächer werdend (EMA{F} < EMA{M})", "S'affaiblit (EMA{F} < EMA{M})", "Melemah (EMA{F} < EMA{M})", "Yếu đi (EMA{F} < EMA{M})", "走弱（EMA{F} < EMA{M}）", "Qels dibe (EMA{F} < EMA{M})")
var string R_OB    = tx(" · Overbought: expensive, pullback risk", " · Aşırı alım: pahalı, düşüş riski", " · Sobrecompra: caro, riesgo de retroceso", " · Sobrecomprado: caro, risco de correção", " · Перекупленность: дорого, риск отката", " · Überkauft: teuer, Rücksetzerrisiko", " · Suracheté : cher, risque de repli", " · Overbought: mahal, risiko koreksi", " · Quá mua: đắt, rủi ro điều chỉnh", " · 超买：价格偏高，有回调风险", " · Zêde kirîn: biha ye, xetereya daketinê")
var string R_OS    = tx(" · Oversold: cheap, bounce possible", " · Aşırı satım: ucuz, tepki gelebilir", " · Sobreventa: barato, posible rebote", " · Sobrevendido: barato, possível repique", " · Перепроданность: дёшево, возможен отскок", " · Überverkauft: günstig, Erholung möglich", " · Survendu : bon marché, rebond possible", " · Oversold: murah, bisa memantul", " · Quá bán: rẻ, có thể hồi phục", " · 超卖：价格偏低，可能反弹", " · Zêde firotin: erzan e, dibe ku vegere")
var string R_N     = tx(" · Normal zone", " · Normal bölge", " · Zona normal", " · Zona normal", " · Нормальная зона", " · Normaler Bereich", " · Zone normale", " · Zona normal", " · Vùng bình thường", " · 正常区间", " · Herêma asayî")
var string V_SPIKE = tx("SPIKE! Strong move", "PATLAMA! Güçlü hareket var", "¡PICO! Movimiento fuerte", "PICO! Movimento forte", "ВСПЛЕСК! Сильное движение", "SPITZE! Starke Bewegung", "PIC ! Mouvement fort", "LONJAKAN! Pergerakan kuat", "ĐỘT BIẾN! Biến động mạnh", "放量！走势强劲", "TEQÎN! Tevgera xurt")
var string V_NORM  = tx("Normal", "Normal", "Normal", "Normal", "Обычный", "Normal", "Normal", "Normal", "Bình thường", "正常", "Asayî")
var string PN_BE   = tx("Bullish engulfing", "Yutan boğa (yükseliş)", "Envolvente alcista", "Engolfo de alta", "Бычье поглощение", "Bullish Engulfing", "Avalement haussier", "Bullish engulfing", "Nhấn chìm tăng", "看涨吞没", "Daqurtandina bilindbûnê")
var string PN_SE   = tx("Bearish engulfing", "Yutan ayı (düşüş)", "Envolvente bajista", "Engolfo de baixa", "Медвежье поглощение", "Bearish Engulfing", "Avalement baissier", "Bearish engulfing", "Nhấn chìm giảm", "看跌吞没", "Daqurtandina daketinê")
var string PN_H    = tx("Hammer (bottom?)", "Çekiç (dip dönüşü?)", "Martillo (¿suelo?)", "Martelo (fundo?)", "Молот (дно?)", "Hammer (Boden?)", "Marteau (creux ?)", "Hammer (dasar?)", "Nến búa (đáy?)", "锤子线（底部？）", "Çakûç (binî?)")
var string PN_S    = tx("Shooting star (top?)", "Kayan yıldız (tepe dönüşü?)", "Estrella fugaz (¿techo?)", "Estrela cadente (topo?)", "Падающая звезда (вершина?)", "Sternschnuppe (Hoch?)", "Étoile filante (sommet ?)", "Shooting star (puncak?)", "Sao băng (đỉnh?)", "射击之星（顶部？）", "Stêrka ketî (serî?)")
var string PN_NONE = tx("No special pattern", "Özel formasyon yok", "Sin patrón especial", "Sem padrão especial", "Нет особой фигуры", "Kein besonderes Muster", "Aucune figure particulière", "Tidak ada pola khusus", "Không có mẫu hình đặc biệt", "无特殊形态", "Şêweyekî taybet tune")
var string SUM_UP  = tx("SUMMARY: Trend up. Pullbacks to EMA{F}/{M} may offer buying opportunities.", "ÖZET: Trend yukarı. EMA{F}/{M} çizgilerine gelen geri çekilmeler alım fırsatı olabilir.", "RESUMEN: Tendencia alcista. Los retrocesos a la EMA{F}/{M} pueden ser oportunidades de compra.", "RESUMO: Tendência de alta. Correções até a EMA{F}/{M} podem ser oportunidades de compra.", "ИТОГ: Тренд вверх. Откаты к EMA{F}/{M} могут дать возможность для покупки.", "FAZIT: Trend aufwärts. Rücksetzer zur EMA{F}/{M} können Kaufgelegenheiten bieten.", "RÉSUMÉ : Tendance haussière. Les replis vers l'EMA{F}/{M} peuvent offrir des opportunités d'achat.", "RINGKASAN: Tren naik. Pullback ke EMA{F}/{M} bisa menjadi peluang beli.", "TÓM TẮT: Xu hướng tăng. Các nhịp điều chỉnh về EMA{F}/{M} có thể là cơ hội mua.", "总结：趋势向上。回调至 EMA{F}/{M} 可能是买入机会。", "KURTE: Meyl ber bi jor e. Vegerînên ber bi EMA{F}/{M} dibe ku derfeta kirînê bin.")
var string SUM_DN  = tx("SUMMARY: Trend down. Don't rush to buy; rallies may meet selling pressure.", "ÖZET: Trend aşağı. Alıma acele etme, yükselişler satış baskısıyla karşılaşabilir.", "RESUMEN: Tendencia bajista. No te apresures a comprar; los rebotes pueden encontrar presión vendedora.", "RESUMO: Tendência de baixa. Não tenha pressa para comprar; altas podem encontrar pressão vendedora.", "ИТОГ: Тренд вниз. Не спешите покупать; на росте может появиться давление продавцов.", "FAZIT: Trend abwärts. Nicht voreilig kaufen; Anstiege können auf Verkaufsdruck treffen.", "RÉSUMÉ : Tendance baissière. Ne vous précipitez pas pour acheter ; les rebonds peuvent rencontrer des vendeurs.", "RINGKASAN: Tren turun. Jangan buru-buru membeli; kenaikan bisa bertemu tekanan jual.", "TÓM TẮT: Xu hướng giảm. Đừng vội mua; các nhịp tăng có thể gặp áp lực bán.", "总结：趋势向下。不要急于买入，反弹可能遇到抛压。", "KURTE: Meyl ber bi jêr e. Bi lez nekire; bilindbûn dibe ku rastî zexta firotinê werin.")
var string SUM_MIX = tx("SUMMARY: Undecided zone. Lines are mixed; waiting is best.", "ÖZET: Kararsız bölge. Çizgiler karışık, beklemek en iyisi.", "RESUMEN: Zona indecisa. Las líneas están mezcladas; lo mejor es esperar.", "RESUMO: Zona indecisa. As linhas estão misturadas; o melhor é esperar.", "ИТОГ: Зона неопределённости. Линии переплетены; лучше подождать.", "FAZIT: Unentschiedene Zone. Die Linien sind gemischt; Abwarten ist am besten.", "RÉSUMÉ : Zone indécise. Les lignes sont mêlées ; mieux vaut attendre.", "RINGKASAN: Zona ragu-ragu. Garis-garis bercampur; lebih baik menunggu.", "TÓM TẮT: Vùng lưỡng lự. Các đường đan xen; tốt nhất là chờ đợi.", "总结：方向不明。均线交织，最好观望。", "KURTE: Herêma bêbiryar. Xet tevlihev in; çêtir e ku li bendê bimînî.")

// ================= CALCULATIONS =================
emaF   = ta.ema(close, lenFast)
emaM   = ta.ema(close, lenMid)
emaS   = ta.ema(close, lenSlow)
smma   = ta.rma(close, lenSmma)
rsi    = ta.rsi(close, rsiLen)
volAvg = ta.sma(volume, 20)
volSpike = volume > volAvg * volMult
atr    = ta.atr(14)

upTrend   = close > emaS and emaF > emaM
downTrend = close < emaS and emaF < emaM

// ================= LINES =================
pF = plot(emaF, "Fast EMA", color=color.new(color.aqua, 0), linewidth=1)
pM = plot(emaM, "Middle EMA", color=color.new(color.orange, 0), linewidth=2)
plot(emaS, "Slow EMA (main trend)", color=color.new(color.red, 0), linewidth=3)
plot(showSmma ? smma : na, "SMMA", color=color.new(color.purple, 0), linewidth=2)
fill(pF, pM, color = emaF > emaM ? color.new(color.green, 85) : color.new(color.red, 85), title="Trend cloud")

// ================= SIGNALS =================
crossUp = ta.crossover(emaF, emaM)
crossDn = ta.crossunder(emaF, emaM)
buySig  = crossUp and close > emaS and rsi < 70
sellSig = crossDn and close < emaS and rsi > 30

bounceUp = emaM > emaS and low <= emaM and close > emaM and close > open and close > emaS
bounceDn = emaM < emaS and high >= emaM and close < emaM and close < open and close < emaS
var int lastBU = na
var int lastBD = na
bounceUpOk = false
bounceDnOk = false
if bounceUp and (na(lastBU) or bar_index - lastBU > 10)
    bounceUpOk := true
    lastBU := bar_index
if bounceDn and (na(lastBD) or bar_index - lastBD > 10)
    bounceDnOk := true
    lastBD := bar_index

volNote = volSpike ? VOL_Y : VOL_N

if showSignal and buySig
    label.new(bar_index, low - atr * 0.6, L_BUY, style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small, tooltip=TT_BUY + volNote)
if showSignal and sellSig
    label.new(bar_index, high + atr * 0.6, L_SELL, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small, tooltip=TT_SELL + volNote)
if showSignal and bounceUpOk
    label.new(bar_index, low - atr * 0.6, L_PBB, style=label.style_label_up, color=color.new(color.teal, 10), textcolor=color.white, size=size.tiny, tooltip=TT_PBB + volNote)
if showSignal and bounceDnOk
    label.new(bar_index, high + atr * 0.6, L_PBS, style=label.style_label_down, color=color.new(color.maroon, 10), textcolor=color.white, size=size.tiny, tooltip=TT_PBS + volNote)

// ================= CANDLE PATTERNS =================
body   = math.abs(close - open)
rng    = high - low
upperW = high - math.max(close, open)
lowerW = math.min(close, open) - low
priorDown = close[1] < close[4]
priorUp   = close[1] > close[4]

bullEngRaw = close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and body > body[1] * 1.2 and body >= atr * 0.7 and priorDown
bearEngRaw = close < open and close[1] > open[1] and close <= open[1] and open >= close[1] and body > body[1] * 1.2 and body >= atr * 0.7 and priorUp
hammerRaw  = body > 0 and rng >= atr * 0.8 and lowerW >= body * 2 and upperW <= body * 0.5 and priorDown and rsi < 45
starRaw    = body > 0 and rng >= atr * 0.8 and upperW >= body * 2 and lowerW <= body * 0.5 and priorUp and rsi > 55

var int lastBullPat = na
var int lastBearPat = na
bullEng = false
hammer  = false
bearEng = false
star    = false
if (bullEngRaw or hammerRaw) and (na(lastBullPat) or bar_index - lastBullPat > patGap)
    bullEng := bullEngRaw
    hammer  := hammerRaw and not bullEngRaw
    lastBullPat := bar_index
if (bearEngRaw or starRaw) and (na(lastBearPat) or bar_index - lastBearPat > patGap)
    bearEng := bearEngRaw
    star    := starRaw and not bearEngRaw
    lastBearPat := bar_index

if showPattern and bullEng
    label.new(bar_index, low - atr * 1.6, P_BE, style=label.style_label_up, color=color.new(color.green, 40), textcolor=color.white, size=size.tiny, tooltip=TT_BE)
if showPattern and bearEng
    label.new(bar_index, high + atr * 1.6, P_SE, style=label.style_label_down, color=color.new(color.red, 40), textcolor=color.white, size=size.tiny, tooltip=TT_SE)
if showPattern and hammer
    label.new(bar_index, low - atr * 1.6, P_H, style=label.style_label_up, color=color.new(color.green, 40), textcolor=color.white, size=size.tiny, tooltip=TT_H)
if showPattern and star
    label.new(bar_index, high + atr * 1.6, P_S, style=label.style_label_down, color=color.new(color.red, 40), textcolor=color.white, size=size.tiny, tooltip=TT_S)

// ================= SUPPORT / RESISTANCE =================
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
var array<line>  resLines  = array.new<line>()
var array<label> resLabels = array.new<label>()
var array<line>  supLines  = array.new<line>()
var array<label> supLabels = array.new<label>()

if showSR and not na(ph)
    array.push(resLines, line.new(bar_index - pivLen, ph, bar_index, ph, extend=extend.right, color=color.new(color.red, 30), style=line.style_dashed))
    array.push(resLabels, label.new(bar_index - pivLen, ph, L_RES, style=label.style_label_down, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny, tooltip=TT_RES))
    if array.size(resLines) > 3
        line.delete(array.shift(resLines))
        label.delete(array.shift(resLabels))

if showSR and not na(pl)
    array.push(supLines, line.new(bar_index - pivLen, pl, bar_index, pl, extend=extend.right, color=color.new(color.green, 30), style=line.style_dashed))
    array.push(supLabels, label.new(bar_index - pivLen, pl, L_SUP, style=label.style_label_up, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny, tooltip=TT_SUP))
    if array.size(supLines) > 3
        line.delete(array.shift(supLines))
        label.delete(array.shift(supLabels))

// ================= LINE NOTES =================
var label nF = na
var label nM = na
var label nS = na
var label nX = na
if barstate.islast
    label.delete(nF)
    label.delete(nM)
    label.delete(nS)
    label.delete(nX)
    if showNotes
        nF := label.new(bar_index + 3, emaF, "EMA" + fL + N_F, style=label.style_label_left, color=color.new(color.aqua, 20), textcolor=color.black, size=size.small, tooltip=TT_NF)
        nM := label.new(bar_index + 3, emaM, "EMA" + mL + N_M, style=label.style_label_left, color=color.new(color.orange, 20), textcolor=color.black, size=size.small, tooltip=TT_NM)
        nS := label.new(bar_index + 3, emaS, "EMA" + sL + N_S, style=label.style_label_left, color=color.new(color.red, 20), textcolor=color.white, size=size.small, tooltip=TT_NS)
        if showSmma
            nX := label.new(bar_index + 3, smma, "SMMA", style=label.style_label_left, color=color.new(color.purple, 20), textcolor=color.white, size=size.small, tooltip=TT_SMMA)

// ================= INFO PANEL =================
var table t = table.new(position.top_right, 2, 7, border_width=1, border_color=color.new(color.gray, 60))
tSize = tableSizeS == "Tiny" ? size.tiny : tableSizeS == "Small" ? size.small : size.normal
bgc = color.new(color.black, 15)

f_row(r, k, v, c) =>
    table.cell(t, 0, r, k, text_color=color.white, bgcolor=bgc, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, r, v, text_color=c, bgcolor=bgc, text_size=tSize, text_halign=text.align_left)

if barstate.isfirst
    table.merge_cells(t, 0, 0, 1, 0)
    table.merge_cells(t, 0, 6, 1, 6)

if barstate.islast and showTable
    table.cell(t, 0, 0, T_TITLE, text_color=color.yellow, bgcolor=bgc, text_size=tSize)
    f_row(1, K_MAIN, close > emaS ? V_UP : V_DN, close > emaS ? color.lime : color.red)
    f_row(2, K_SHORT, emaF > emaM ? V_STR : V_WEAK, emaF > emaM ? color.lime : color.red)
    rsiTxt = str.tostring(rsi, "#.0") + (rsi > 70 ? R_OB : rsi < 30 ? R_OS : R_N)
    f_row(3, "RSI", rsiTxt, rsi > 70 ? color.red : rsi < 30 ? color.lime : color.white)
    f_row(4, K_VOL, volSpike ? V_SPIKE : V_NORM, volSpike ? color.yellow : color.white)
    patName = bullEng ? PN_BE : bearEng ? PN_SE : hammer ? PN_H : star ? PN_S : PN_NONE
    f_row(5, K_LAST, patName, color.white)
    summary = upTrend ? SUM_UP : downTrend ? SUM_DN : SUM_MIX
    table.cell(t, 0, 6, summary, text_color=color.yellow, bgcolor=bgc, text_size=tSize, text_halign=text.align_left)

// ================= ALERTS =================
alertcondition(buySig, "EMA cross BUY", "Chart Coach: EMA cross BUY signal")
alertcondition(sellSig, "EMA cross SELL", "Chart Coach: EMA cross SELL signal")
alertcondition(bounceUpOk, "Pullback BUY", "Chart Coach: Pullback BUY from middle EMA")
alertcondition(bounceDnOk, "Pullback SELL", "Chart Coach: Pullback SELL from middle EMA")
````
