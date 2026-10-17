# Market Structure Coach - HH/HL/LH/LL, BOS and CHoCH Explained

- url: https://www.tradingview.com/script/rdCGvBv2/
- type: indicator
- pine_id: PUB;0e1215e55d7645e58c56716bd718c5bb
- version: 1.0

## Description

OVERVIEW
Market Structure Coach is an educational overlay that teaches one of the most important skills in chart reading: understanding market structure. It labels every confirmed swing, marks structure breaks, and explains each element in plain language through tooltips (hover or tap a label). A live panel summarizes who controls the structure right now. The interface is available in 11 languages: English, Turkish, Spanish, Portuguese, Russian, German, French, Indonesian, Vietnamese, Chinese and Kurdish (Kurmanji).

WHAT IT SHOWS
- Swing labels: HH (higher high), HL (higher low), LH (lower high), LL (lower low). Each new swing is compared with the previous swing of the same type.
- BOS (Break of Structure): price closes beyond the last swing in the direction of the current structure. It signals trend continuation.
- CHoCH (Change of Character): price closes beyond the last swing against the current structure. It is the first warning that control may be shifting.
- Active swing levels: the most recent unbroken swing high and swing low, drawn as dotted lines extended to the right.
- Optional background tint by structure, and an info panel with the current structure, last swing high and low with their prices, last break and a one-line summary.

HOW IT WORKS
- Swings are detected with pivot highs and lows using the "Swing sensitivity" setting (default 5 bars on each side).
- A new swing high is labeled HH if it is above the previous swing high, otherwise LH. A new swing low is labeled HL if it is above the previous swing low, otherwise LL.
- A break is registered on a bar close beyond the last unbroken swing level. The structure bias is set by the most recent break: a break in the same direction as the bias is a BOS, a break against it is a CHoCH. The first break on the chart is labeled BOS.
- Each swing level can only be broken once. A broken level is redrawn as a solid line from the swing to the breaking bar, with the BOS or CHoCH label in the middle.

HOW TO USE
1. Read the panel first: bullish, bearish or undecided structure.
2. In a bullish structure, the last HL is the level buyers must defend. In a bearish structure, the last LH is the level sellers must defend.
3. Treat CHoCH as an early warning, not a confirmed reversal. Confirmation comes when a new swing forms in the new direction (for example, a HL after a bullish CHoCH).
4. Higher sensitivity values show major structure; lower values show minor structure. Try 5 for intraday charts and 10 or more for daily charts.

WHAT MAKES IT DIFFERENT
Swing and structure-break tools are common. This script focuses on teaching: every label carries a context-aware explanation of what happened and what to watch next, the panel turns the current structure into one plain-language sentence, and the whole interface can be read in 11 languages.

LIMITATIONS
- Pivots are confirmed only after the chosen number of bars has closed after the swing, so swing labels appear with a delay and are placed back on the swing bar. Once confirmed, they do not change.
- A break on the live, unclosed bar can appear and disappear until the bar closes.
- Structure describes what price has done; it does not predict what price will do. No performance claims are made. This is an educational tool, not financial advice.

ALERTS
Alert conditions are available for bullish BOS, bearish BOS, bullish CHoCH and bearish CHoCH.

## Source Code

````pine
//@version=6
indicator("Market Structure Coach [HH/HL/LH/LL, BOS, CHoCH]", shorttitle="Structure Coach", overlay=true, max_labels_count=500, max_lines_count=500)

// ================= SETTINGS =================
grpG = "Display"
lang       = input.string("English", "Language", options=["English", "Türkçe", "Español", "Português", "Русский", "Deutsch", "Français", "Bahasa Indonesia", "Tiếng Việt", "中文", "Kurdî (Kurmancî)"], group=grpG)
showSwings = input.bool(true,  "Swing labels (HH/HL/LH/LL)", group=grpG)
showBreaks = input.bool(true,  "Breaks (BOS / CHoCH)", group=grpG)
showLevels = input.bool(true,  "Active swing levels", group=grpG)
showBg     = input.bool(false, "Background by structure", group=grpG)
showTable  = input.bool(true,  "Info panel", group=grpG)
tableSizeS = input.string("Small", "Panel text size", options=["Tiny", "Small", "Normal"], group=grpG)

grpP = "Settings"
pivLen = input.int(5, "Swing sensitivity (bars on each side)", minval=2, maxval=50, group=grpP)

bullC = color.new(color.teal, 0)
bearC = color.new(color.red, 0)

// ================= TRANSLATION HELPER =================
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

tx(string en, string tr, string es, string pt, string ru, string de, string fr, string ind, string vi, string zh, string ku) =>
    switch langIdx
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

// ================= TEXTS =================
var string TT_HH = tx("HH = Higher High\nThis peak is higher than the previous peak.\nBuyers are pushing price to new highs: a sign of an uptrend.", "HH = Daha Yüksek Tepe\nBu tepe bir öncekinden yüksek.\nAlıcılar fiyatı yeni zirvelere taşıyor: yükseliş trendi işareti.", "HH = Máximo más alto\nEste pico es más alto que el anterior.\nLos compradores llevan el precio a nuevos máximos: señal de tendencia alcista.", "HH = Topo mais alto\nEste topo é mais alto que o anterior.\nOs compradores levam o preço a novas máximas: sinal de tendência de alta.", "HH = Более высокий максимум\nЭтот пик выше предыдущего.\nПокупатели выводят цену на новые максимумы: признак восходящего тренда.", "HH = Höheres Hoch\nDieses Hoch liegt über dem vorherigen.\nKäufer treiben den Kurs auf neue Hochs: Zeichen eines Aufwärtstrends.", "HH = Sommet plus haut\nCe sommet est plus haut que le précédent.\nLes acheteurs poussent le prix vers de nouveaux plus hauts : signe de tendance haussière.", "HH = Higher High (puncak lebih tinggi)\nPuncak ini lebih tinggi dari puncak sebelumnya.\nPembeli mendorong harga ke level baru: tanda tren naik.", "HH = Đỉnh cao hơn\nĐỉnh này cao hơn đỉnh trước.\nPhe mua đẩy giá lên mức mới: dấu hiệu xu hướng tăng.", "HH = 更高的高点\n这个高点高于前一个高点。\n买方推动价格创出新高：上升趋势的迹象。", "HH = Lûtkeya bilindtir\nEv lûtke ji ya berê bilindtir e.\nKiriyar bihayê ber bi astên nû dibin: nîşana meyla bilindbûnê.")
var string TT_HL = tx("HL = Higher Low\nThis dip stopped above the previous dip.\nBuyers step in earlier each time: the uptrend is healthy. Losing this level weakens the uptrend.", "HL = Daha Yüksek Dip\nBu düşüş bir önceki dibin üstünde durdu.\nAlıcılar her seferinde daha erken devreye giriyor: yükseliş sağlıklı. Bu seviyenin kırılması yükselişi zayıflatır.", "HL = Mínimo más alto\nEsta caída se detuvo por encima del mínimo anterior.\nLos compradores entran cada vez antes: la tendencia alcista es sana. Perder este nivel la debilita.", "HL = Fundo mais alto\nEsta queda parou acima do fundo anterior.\nOs compradores entram cada vez mais cedo: a alta está saudável. Perder este nível enfraquece a alta.", "HL = Более высокий минимум\nЭто снижение остановилось выше предыдущего минимума.\nПокупатели входят всё раньше: восходящий тренд здоров. Потеря этого уровня ослабляет тренд.", "HL = Höheres Tief\nDieser Rücksetzer endete über dem vorherigen Tief.\nKäufer steigen jedes Mal früher ein: der Aufwärtstrend ist intakt. Fällt diese Marke, wird er schwächer.", "HL = Creux plus haut\nCe repli s'est arrêté au-dessus du creux précédent.\nLes acheteurs interviennent de plus en plus tôt : la hausse est saine. Perdre ce niveau l'affaiblit.", "HL = Higher Low (lembah lebih tinggi)\nPenurunan ini berhenti di atas lembah sebelumnya.\nPembeli masuk makin cepat: tren naik sehat. Jika level ini jebol, tren naik melemah.", "HL = Đáy cao hơn\nNhịp giảm này dừng trên đáy trước.\nPhe mua vào lệnh sớm hơn mỗi lần: xu hướng tăng lành mạnh. Mất mức này sẽ làm xu hướng tăng yếu đi.", "HL = 更高的低点\n这次回调止于前一个低点之上。\n买方每次都更早入场：上升趋势健康。跌破此位置会削弱上升趋势。", "HL = Binîya bilindtir\nEv daketin li ser binîya berê rawestiya.\nKiriyar her car zûtir dikevin: meyla bilindbûnê saxlem e. Şikandina vê astê meylê qels dike.")
var string TT_LH = tx("LH = Lower High\nThis peak failed to reach the previous peak.\nSellers are active earlier: a sign of weakness or a downtrend.", "LH = Daha Düşük Tepe\nBu tepe bir öncekine ulaşamadı.\nSatıcılar daha erken devreye giriyor: zayıflık veya düşüş trendi işareti.", "LH = Máximo más bajo\nEste pico no alcanzó el anterior.\nLos vendedores actúan antes: señal de debilidad o tendencia bajista.", "LH = Topo mais baixo\nEste topo não alcançou o anterior.\nOs vendedores agem mais cedo: sinal de fraqueza ou tendência de baixa.", "LH = Более низкий максимум\nЭтот пик не дошёл до предыдущего.\nПродавцы активны раньше: признак слабости или нисходящего тренда.", "LH = Tieferes Hoch\nDieses Hoch erreichte das vorherige nicht.\nVerkäufer werden früher aktiv: Zeichen von Schwäche oder eines Abwärtstrends.", "LH = Sommet plus bas\nCe sommet n'a pas atteint le précédent.\nLes vendeurs agissent plus tôt : signe de faiblesse ou de tendance baissière.", "LH = Lower High (puncak lebih rendah)\nPuncak ini gagal mencapai puncak sebelumnya.\nPenjual aktif lebih awal: tanda pelemahan atau tren turun.", "LH = Đỉnh thấp hơn\nĐỉnh này không vượt được đỉnh trước.\nPhe bán hoạt động sớm hơn: dấu hiệu suy yếu hoặc xu hướng giảm.", "LH = 更低的高点\n这个高点未能达到前一个高点。\n卖方更早出手：走弱或下降趋势的迹象。", "LH = Lûtkeya nizmtir\nEv lûtke negihîşt ya berê.\nFiroşkar zûtir çalak dibin: nîşana qelsbûnê an meyla daketinê.")
var string TT_LL = tx("LL = Lower Low\nThis dip went below the previous dip.\nSellers are pushing price to new lows: a sign of a downtrend.", "LL = Daha Düşük Dip\nBu düşüş bir önceki dibin altına indi.\nSatıcılar fiyatı yeni diplere itiyor: düşüş trendi işareti.", "LL = Mínimo más bajo\nEsta caída perforó el mínimo anterior.\nLos vendedores llevan el precio a nuevos mínimos: señal de tendencia bajista.", "LL = Fundo mais baixo\nEsta queda rompeu o fundo anterior.\nOs vendedores levam o preço a novas mínimas: sinal de tendência de baixa.", "LL = Более низкий минимум\nЭто снижение ушло ниже предыдущего минимума.\nПродавцы толкают цену к новым минимумам: признак нисходящего тренда.", "LL = Tieferes Tief\nDieser Rücksetzer fiel unter das vorherige Tief.\nVerkäufer drücken den Kurs auf neue Tiefs: Zeichen eines Abwärtstrends.", "LL = Creux plus bas\nCe repli est passé sous le creux précédent.\nLes vendeurs poussent le prix vers de nouveaux plus bas : signe de tendance baissière.", "LL = Lower Low (lembah lebih rendah)\nPenurunan ini menembus lembah sebelumnya.\nPenjual mendorong harga ke level terendah baru: tanda tren turun.", "LL = Đáy thấp hơn\nNhịp giảm này xuyên thủng đáy trước.\nPhe bán đẩy giá xuống mức thấp mới: dấu hiệu xu hướng giảm.", "LL = 更低的低点\n这次下跌跌破了前一个低点。\n卖方推动价格创出新低：下降趋势的迹象。", "LL = Binîya nizmtir\nEv daketin ji binîya berê derbas bû.\nFiroşkar bihayê ber bi astên nizm ên nû dibin: nîşana meyla daketinê.")

var string TT_BOSU = tx("BOS ↑ = Break of Structure (bullish)\nPrice closed above the last swing high in the direction of the trend.\nThe uptrend continues. The last higher low is now the key level to hold.", "BOS ↑ = Yapı Kırılımı (yükseliş)\nFiyat, trend yönünde son tepenin üstünde kapattı.\nYükseliş devam ediyor. Artık korunması gereken seviye son yükselen dip.", "BOS ↑ = Ruptura de estructura (alcista)\nEl precio cerró por encima del último máximo en la dirección de la tendencia.\nLa tendencia alcista continúa. El último mínimo más alto es ahora el nivel clave.", "BOS ↑ = Quebra de estrutura (alta)\nO preço fechou acima do último topo na direção da tendência.\nA alta continua. O último fundo mais alto passa a ser o nível-chave.", "BOS ↑ = Слом структуры (бычий)\nЦена закрылась выше последнего максимума по направлению тренда.\nВосходящий тренд продолжается. Ключевой уровень теперь последний более высокий минимум.", "BOS ↑ = Strukturbruch (bullisch)\nDer Kurs schloss in Trendrichtung über dem letzten Swing-Hoch.\nDer Aufwärtstrend setzt sich fort. Das letzte höhere Tief ist jetzt die wichtige Marke.", "BOS ↑ = Cassure de structure (haussière)\nLe prix a clôturé au-dessus du dernier sommet dans le sens de la tendance.\nLa hausse continue. Le dernier creux plus haut devient le niveau clé.", "BOS ↑ = Break of Structure (naik)\nHarga ditutup di atas puncak swing terakhir searah tren.\nTren naik berlanjut. Higher low terakhir kini menjadi level kunci.", "BOS ↑ = Phá vỡ cấu trúc (tăng)\nGiá đóng cửa trên đỉnh swing gần nhất theo hướng xu hướng.\nXu hướng tăng tiếp diễn. Đáy cao hơn gần nhất giờ là mức quan trọng.", "BOS ↑ = 结构突破（看涨）\n价格顺着趋势方向收在最近波段高点之上。\n上升趋势延续。最近的更高低点成为需要守住的关键位。", "BOS ↑ = Şikestina avahiyê (bilindbûn)\nBiha di rêya meylê de li ser lûtkeya dawî girt.\nMeyla bilindbûnê berdewam e. Niha binîya bilindtir a dawî asta sereke ye.")
var string TT_BOSD = tx("BOS ↓ = Break of Structure (bearish)\nPrice closed below the last swing low in the direction of the trend.\nThe downtrend continues. The last lower high is now the key level.", "BOS ↓ = Yapı Kırılımı (düşüş)\nFiyat, trend yönünde son dibin altında kapattı.\nDüşüş devam ediyor. Artık kritik seviye son alçalan tepe.", "BOS ↓ = Ruptura de estructura (bajista)\nEl precio cerró por debajo del último mínimo en la dirección de la tendencia.\nLa tendencia bajista continúa. El último máximo más bajo es ahora el nivel clave.", "BOS ↓ = Quebra de estrutura (baixa)\nO preço fechou abaixo do último fundo na direção da tendência.\nA baixa continua. O último topo mais baixo passa a ser o nível-chave.", "BOS ↓ = Слом структуры (медвежий)\nЦена закрылась ниже последнего минимума по направлению тренда.\nНисходящий тренд продолжается. Ключевой уровень теперь последний более низкий максимум.", "BOS ↓ = Strukturbruch (bärisch)\nDer Kurs schloss in Trendrichtung unter dem letzten Swing-Tief.\nDer Abwärtstrend setzt sich fort. Das letzte tiefere Hoch ist jetzt die wichtige Marke.", "BOS ↓ = Cassure de structure (baissière)\nLe prix a clôturé sous le dernier creux dans le sens de la tendance.\nLa baisse continue. Le dernier sommet plus bas devient le niveau clé.", "BOS ↓ = Break of Structure (turun)\nHarga ditutup di bawah lembah swing terakhir searah tren.\nTren turun berlanjut. Lower high terakhir kini menjadi level kunci.", "BOS ↓ = Phá vỡ cấu trúc (giảm)\nGiá đóng cửa dưới đáy swing gần nhất theo hướng xu hướng.\nXu hướng giảm tiếp diễn. Đỉnh thấp hơn gần nhất giờ là mức quan trọng.", "BOS ↓ = 结构突破（看跌）\n价格顺着趋势方向收在最近波段低点之下。\n下降趋势延续。最近的更低高点成为关键位。", "BOS ↓ = Şikestina avahiyê (daketin)\nBiha di rêya meylê de di bin binîya dawî de girt.\nMeyla daketinê berdewam e. Niha lûtkeya nizmtir a dawî asta sereke ye.")
var string TT_CHU = tx("CHoCH ↑ = Change of Character (bullish)\nIn a downtrend, price closed above the last swing high.\nFirst sign that sellers are losing control. Not a confirmed reversal yet: watch for a higher low.", "CHoCH ↑ = Karakter Değişimi (yükseliş)\nDüşüş trendindeyken fiyat son tepenin üstünde kapattı.\nSatıcıların kontrolü kaybettiğinin ilk işareti. Henüz kesin dönüş değil: yükselen bir dip oluşmasını bekle.", "CHoCH ↑ = Cambio de carácter (alcista)\nEn tendencia bajista, el precio cerró por encima del último máximo.\nPrimera señal de que los vendedores pierden el control. Aún no es un giro confirmado: espera un mínimo más alto.", "CHoCH ↑ = Mudança de caráter (alta)\nEm tendência de baixa, o preço fechou acima do último topo.\nPrimeiro sinal de que os vendedores perdem o controle. Ainda não é reversão confirmada: aguarde um fundo mais alto.", "CHoCH ↑ = Смена характера (бычья)\nВ нисходящем тренде цена закрылась выше последнего максимума.\nПервый признак, что продавцы теряют контроль. Разворот ещё не подтверждён: ждите более высокого минимума.", "CHoCH ↑ = Charakterwechsel (bullisch)\nIm Abwärtstrend schloss der Kurs über dem letzten Swing-Hoch.\nErstes Zeichen, dass Verkäufer die Kontrolle verlieren. Noch keine bestätigte Wende: auf ein höheres Tief achten.", "CHoCH ↑ = Changement de caractère (haussier)\nEn tendance baissière, le prix a clôturé au-dessus du dernier sommet.\nPremier signe que les vendeurs perdent le contrôle. Pas encore un retournement confirmé : attendez un creux plus haut.", "CHoCH ↑ = Change of Character (naik)\nDalam tren turun, harga ditutup di atas puncak swing terakhir.\nTanda awal penjual kehilangan kendali. Belum pembalikan pasti: tunggu terbentuknya higher low.", "CHoCH ↑ = Thay đổi tính chất (tăng)\nTrong xu hướng giảm, giá đóng cửa trên đỉnh swing gần nhất.\nDấu hiệu đầu tiên phe bán mất kiểm soát. Chưa phải đảo chiều chắc chắn: chờ một đáy cao hơn.", "CHoCH ↑ = 性质转变（看涨）\n下降趋势中，价格收在最近波段高点之上。\n卖方失去控制的第一个信号。尚未确认反转：等待更高低点出现。", "CHoCH ↑ = Guherîna karakterê (bilindbûn)\nDi meyla daketinê de biha li ser lûtkeya dawî girt.\nNîşana yekem ku firoşkar kontrolê winda dikin. Hîn vegera teqez nîn e: li benda binîyeke bilindtir be.")
var string TT_CHD = tx("CHoCH ↓ = Change of Character (bearish)\nIn an uptrend, price closed below the last swing low.\nFirst sign that buyers are losing control. Not a confirmed reversal yet: watch for a lower high.", "CHoCH ↓ = Karakter Değişimi (düşüş)\nYükseliş trendindeyken fiyat son dibin altında kapattı.\nAlıcıların kontrolü kaybettiğinin ilk işareti. Henüz kesin dönüş değil: alçalan bir tepe oluşmasını bekle.", "CHoCH ↓ = Cambio de carácter (bajista)\nEn tendencia alcista, el precio cerró por debajo del último mínimo.\nPrimera señal de que los compradores pierden el control. Aún no es un giro confirmado: espera un máximo más bajo.", "CHoCH ↓ = Mudança de caráter (baixa)\nEm tendência de alta, o preço fechou abaixo do último fundo.\nPrimeiro sinal de que os compradores perdem o controle. Ainda não é reversão confirmada: aguarde um topo mais baixo.", "CHoCH ↓ = Смена характера (медвежья)\nВ восходящем тренде цена закрылась ниже последнего минимума.\nПервый признак, что покупатели теряют контроль. Разворот ещё не подтверждён: ждите более низкого максимума.", "CHoCH ↓ = Charakterwechsel (bärisch)\nIm Aufwärtstrend schloss der Kurs unter dem letzten Swing-Tief.\nErstes Zeichen, dass Käufer die Kontrolle verlieren. Noch keine bestätigte Wende: auf ein tieferes Hoch achten.", "CHoCH ↓ = Changement de caractère (baissier)\nEn tendance haussière, le prix a clôturé sous le dernier creux.\nPremier signe que les acheteurs perdent le contrôle. Pas encore un retournement confirmé : attendez un sommet plus bas.", "CHoCH ↓ = Change of Character (turun)\nDalam tren naik, harga ditutup di bawah lembah swing terakhir.\nTanda awal pembeli kehilangan kendali. Belum pembalikan pasti: tunggu terbentuknya lower high.", "CHoCH ↓ = Thay đổi tính chất (giảm)\nTrong xu hướng tăng, giá đóng cửa dưới đáy swing gần nhất.\nDấu hiệu đầu tiên phe mua mất kiểm soát. Chưa phải đảo chiều chắc chắn: chờ một đỉnh thấp hơn.", "CHoCH ↓ = 性质转变（看跌）\n上升趋势中，价格收在最近波段低点之下。\n买方失去控制的第一个信号。尚未确认反转：等待更低高点出现。", "CHoCH ↓ = Guherîna karakterê (daketin)\nDi meyla bilindbûnê de biha di bin binîya dawî de girt.\nNîşana yekem ku kiriyar kontrolê winda dikin. Hîn vegera teqez nîn e: li benda lûtkeyeke nizmtir be.")

var string T_TITLE  = tx("🧭 STRUCTURE COACH", "🧭 PİYASA YAPISI KOÇU", "🧭 COACH DE ESTRUCTURA", "🧭 COACH DE ESTRUTURA", "🧭 ТРЕНЕР ПО СТРУКТУРЕ", "🧭 STRUKTUR-COACH", "🧭 COACH DE STRUCTURE", "🧭 PELATIH STRUKTUR", "🧭 HUẤN LUYỆN CẤU TRÚC", "🧭 结构教练", "🧭 RÊBERÊ AVAHIYÊ")
var string K_STRUCT = tx("Structure", "Yapı", "Estructura", "Estrutura", "Структура", "Struktur", "Structure", "Struktur", "Cấu trúc", "结构", "Avahî")
var string K_HIGH   = tx("Last swing high", "Son tepe", "Último máximo", "Último topo", "Последний максимум", "Letztes Hoch", "Dernier sommet", "Puncak terakhir", "Đỉnh gần nhất", "最近高点", "Lûtkeya dawî")
var string K_LOW    = tx("Last swing low", "Son dip", "Último mínimo", "Último fundo", "Последний минимум", "Letztes Tief", "Dernier creux", "Lembah terakhir", "Đáy gần nhất", "最近低点", "Binîya dawî")
var string K_EVENT  = tx("Last break", "Son kırılım", "Última ruptura", "Última quebra", "Последний слом", "Letzter Bruch", "Dernière cassure", "Break terakhir", "Phá vỡ gần nhất", "最近突破", "Şikestina dawî")
var string V_BULL   = tx("BULLISH ✅", "YÜKSELİŞ ✅", "ALCISTA ✅", "ALTA ✅", "БЫЧЬЯ ✅", "BULLISCH ✅", "HAUSSIÈRE ✅", "BULLISH ✅", "TĂNG ✅", "看涨 ✅", "BILINDBÛN ✅")
var string V_BEAR   = tx("BEARISH ❌", "DÜŞÜŞ ❌", "BAJISTA ❌", "BAIXA ❌", "МЕДВЕЖЬЯ ❌", "BÄRISCH ❌", "BAISSIÈRE ❌", "BEARISH ❌", "GIẢM ❌", "看跌 ❌", "DAKETIN ❌")
var string V_NEUT   = tx("UNDECIDED ⚪", "KARARSIZ ⚪", "INDECISA ⚪", "INDEFINIDA ⚪", "НЕОПРЕДЕЛЁННАЯ ⚪", "UNENTSCHIEDEN ⚪", "INDÉCISE ⚪", "BELUM JELAS ⚪", "CHƯA RÕ ⚪", "不明确 ⚪", "BÊBIRYAR ⚪")
var string SUM_BULL = tx("SUMMARY: Buyers control the structure. The uptrend holds while price stays above the last swing low.", "ÖZET: Yapıyı alıcılar kontrol ediyor. Fiyat son dibin üstünde kaldıkça yükseliş sürer.", "RESUMEN: Los compradores controlan la estructura. La tendencia alcista se mantiene mientras el precio siga sobre el último mínimo.", "RESUMO: Os compradores controlam a estrutura. A alta se mantém enquanto o preço ficar acima do último fundo.", "ИТОГ: Структуру контролируют покупатели. Рост сохраняется, пока цена выше последнего минимума.", "FAZIT: Käufer kontrollieren die Struktur. Der Aufwärtstrend hält, solange der Kurs über dem letzten Tief bleibt.", "RÉSUMÉ : Les acheteurs contrôlent la structure. La hausse tient tant que le prix reste au-dessus du dernier creux.", "RINGKASAN: Pembeli menguasai struktur. Tren naik bertahan selama harga di atas lembah terakhir.", "TÓM TẮT: Phe mua kiểm soát cấu trúc. Xu hướng tăng còn giữ khi giá ở trên đáy gần nhất.", "总结：买方控制结构。只要价格保持在最近低点之上，上升趋势就成立。", "KURTE: Kiriyar avahiyê kontrol dikin. Heta ku biha li ser binîya dawî bimîne, bilindbûn berdewam e.")
var string SUM_BEAR = tx("SUMMARY: Sellers control the structure. The downtrend holds while price stays below the last swing high.", "ÖZET: Yapıyı satıcılar kontrol ediyor. Fiyat son tepenin altında kaldıkça düşüş sürer.", "RESUMEN: Los vendedores controlan la estructura. La tendencia bajista se mantiene mientras el precio siga bajo el último máximo.", "RESUMO: Os vendedores controlam a estrutura. A baixa se mantém enquanto o preço ficar abaixo do último topo.", "ИТОГ: Структуру контролируют продавцы. Снижение сохраняется, пока цена ниже последнего максимума.", "FAZIT: Verkäufer kontrollieren die Struktur. Der Abwärtstrend hält, solange der Kurs unter dem letzten Hoch bleibt.", "RÉSUMÉ : Les vendeurs contrôlent la structure. La baisse tient tant que le prix reste sous le dernier sommet.", "RINGKASAN: Penjual menguasai struktur. Tren turun bertahan selama harga di bawah puncak terakhir.", "TÓM TẮT: Phe bán kiểm soát cấu trúc. Xu hướng giảm còn giữ khi giá ở dưới đỉnh gần nhất.", "总结：卖方控制结构。只要价格保持在最近高点之下，下降趋势就成立。", "KURTE: Firoşkar avahiyê kontrol dikin. Heta ku biha di bin lûtkeya dawî de bimîne, daketin berdewam e.")
var string SUM_NEUT = tx("SUMMARY: No clear structure yet. Wait for a break of the last swing high or low.", "ÖZET: Henüz net bir yapı yok. Son tepe veya dibin kırılmasını bekle.", "RESUMEN: Aún no hay una estructura clara. Espera la ruptura del último máximo o mínimo.", "RESUMO: Ainda não há estrutura clara. Aguarde a quebra do último topo ou fundo.", "ИТОГ: Чёткой структуры пока нет. Дождитесь пробоя последнего максимума или минимума.", "FAZIT: Noch keine klare Struktur. Auf den Bruch des letzten Hochs oder Tiefs warten.", "RÉSUMÉ : Pas encore de structure claire. Attendez la cassure du dernier sommet ou creux.", "RINGKASAN: Belum ada struktur yang jelas. Tunggu tembusnya puncak atau lembah terakhir.", "TÓM TẮT: Chưa có cấu trúc rõ ràng. Chờ giá phá vỡ đỉnh hoặc đáy gần nhất.", "总结：尚无清晰结构。等待突破最近高点或低点。", "KURTE: Hîn avahiyeke zelal tune. Li benda şikestina lûtke an binîya dawî be.")

// ================= SWINGS =================
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

var float  lastH    = na
var float  prevH    = na
var int    lastHBar = na
var bool   hBroken  = true
var line   hLine    = na
var string hType    = ""

var float  lastL    = na
var float  prevL    = na
var int    lastLBar = na
var bool   lBroken  = true
var line   lLine    = na
var string lType    = ""

var int    bias      = 0
var string lastEvent = ""

bosUp   = false
bosDn   = false
chochUp = false
chochDn = false

if not na(ph)
    prevH    := lastH
    lastH    := ph
    lastHBar := bar_index - pivLen
    hBroken  := false
    if not na(prevH)
        hType := ph > prevH ? "HH" : "LH"
        if showSwings
            label.new(lastHBar, ph, hType, style=label.style_label_down, color=hType == "HH" ? color.new(bullC, 25) : color.new(bearC, 25), textcolor=color.white, size=size.tiny, tooltip=hType == "HH" ? TT_HH : TT_LH)
    line.delete(hLine)
    hLine := na
    if showLevels
        hLine := line.new(lastHBar, ph, bar_index, ph, extend=extend.right, style=line.style_dotted, color=color.new(bearC, 40))

if not na(pl)
    prevL    := lastL
    lastL    := pl
    lastLBar := bar_index - pivLen
    lBroken  := false
    if not na(prevL)
        lType := pl > prevL ? "HL" : "LL"
        if showSwings
            label.new(lastLBar, pl, lType, style=label.style_label_up, color=lType == "HL" ? color.new(bullC, 25) : color.new(bearC, 25), textcolor=color.white, size=size.tiny, tooltip=lType == "HL" ? TT_HL : TT_LL)
    line.delete(lLine)
    lLine := na
    if showLevels
        lLine := line.new(lastLBar, pl, bar_index, pl, extend=extend.right, style=line.style_dotted, color=color.new(bullC, 40))

// ================= BREAKS =================
if not hBroken and not na(lastH) and close > lastH
    hBroken := true
    isCh = bias == -1
    bias := 1
    bosUp   := not isCh
    chochUp := isCh
    lastEvent := isCh ? "CHoCH ↑" : "BOS ↑"
    line.delete(hLine)
    hLine := na
    if showBreaks
        line.new(lastHBar, lastH, bar_index, lastH, color=bullC, width=1)
        label.new(math.round((lastHBar + bar_index) / 2.0), lastH, isCh ? "CHoCH ↑" : "BOS ↑", style=label.style_label_down, color=color.new(color.white, 100), textcolor=bullC, size=size.small, tooltip=isCh ? TT_CHU : TT_BOSU)

if not lBroken and not na(lastL) and close < lastL
    lBroken := true
    isCh = bias == 1
    bias := -1
    bosDn   := not isCh
    chochDn := isCh
    lastEvent := isCh ? "CHoCH ↓" : "BOS ↓"
    line.delete(lLine)
    lLine := na
    if showBreaks
        line.new(lastLBar, lastL, bar_index, lastL, color=bearC, width=1)
        label.new(math.round((lastLBar + bar_index) / 2.0), lastL, isCh ? "CHoCH ↓" : "BOS ↓", style=label.style_label_up, color=color.new(color.white, 100), textcolor=bearC, size=size.small, tooltip=isCh ? TT_CHD : TT_BOSD)

bgcolor(showBg and bias == 1 ? color.new(bullC, 93) : showBg and bias == -1 ? color.new(bearC, 93) : na, title="Structure background")

// ================= INFO PANEL =================
var table t = table.new(position.top_right, 2, 6, border_width=1, border_color=color.new(color.gray, 60))
tSize = tableSizeS == "Tiny" ? size.tiny : tableSizeS == "Small" ? size.small : size.normal
bgc = color.new(color.black, 15)

f_row(r, k, v, c) =>
    table.cell(t, 0, r, k, text_color=color.white, bgcolor=bgc, text_size=tSize, text_halign=text.align_left)
    table.cell(t, 1, r, v, text_color=c, bgcolor=bgc, text_size=tSize, text_halign=text.align_left)

if barstate.isfirst
    table.merge_cells(t, 0, 0, 1, 0)
    table.merge_cells(t, 0, 5, 1, 5)

if barstate.islast and showTable
    table.cell(t, 0, 0, T_TITLE, text_color=color.yellow, bgcolor=bgc, text_size=tSize)
    f_row(1, K_STRUCT, bias == 1 ? V_BULL : bias == -1 ? V_BEAR : V_NEUT, bias == 1 ? color.lime : bias == -1 ? color.red : color.white)
    hVal = hType == "" ? "—" : hType + " · " + str.tostring(lastH, format.mintick)
    lVal = lType == "" ? "—" : lType + " · " + str.tostring(lastL, format.mintick)
    f_row(2, K_HIGH, hVal, hType == "HH" ? color.lime : hType == "LH" ? color.red : color.white)
    f_row(3, K_LOW, lVal, lType == "HL" ? color.lime : lType == "LL" ? color.red : color.white)
    f_row(4, K_EVENT, lastEvent == "" ? "—" : lastEvent, str.contains(lastEvent, "↑") ? color.lime : str.contains(lastEvent, "↓") ? color.red : color.white)
    summary = bias == 1 ? SUM_BULL : bias == -1 ? SUM_BEAR : SUM_NEUT
    table.cell(t, 0, 5, summary, text_color=color.yellow, bgcolor=bgc, text_size=tSize, text_halign=text.align_left)

// ================= ALERTS =================
alertcondition(bosUp,   "Bullish BOS",   "Structure Coach: Bullish break of structure")
alertcondition(bosDn,   "Bearish BOS",   "Structure Coach: Bearish break of structure")
alertcondition(chochUp, "Bullish CHoCH", "Structure Coach: Bullish change of character")
alertcondition(chochDn, "Bearish CHoCH", "Structure Coach: Bearish change of character")
````
