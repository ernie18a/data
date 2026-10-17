# Whale Zones Coach - Whale Walls and Large Trades [TheTrendTutor]

- url: https://www.tradingview.com/script/XTUiyHF6/
- type: indicator
- pine_id: PUB;4c865e7c2d9b40e786f369c52ee64dcc
- version: 1.0

## Description

🇬🇧 United Kingdom · English

Whale Zones Coach shows where the big money traded. It scans the last N bars, builds a volume-by-price map and selects the heaviest zones on each side of price as whale walls. Walls above price are red (sell walls / resistance) and walls below price are green (buy walls / support). Thicker, brighter walls mean more traded value. Each wall starts at the bar where its largest volume printed and ends with a value tag ($12.4M).

- Balanced walls: sell and buy walls are picked separately, with a minimum gap and a maximum distance filter, so the chart stays clean and relevant.
- Large Trades: candles with abnormal volume (z-score) get green (buy) or red (sell) rings in three sizes.
- Whale List: price, value, age and distance of every wall, sorted by price.
- Coach Panel: nearest sell and buy wall, last big trade, pressure (sellers above vs buyers below) and a live tip, available in 11 languages.
- Alerts: Large BUY and Large SELL trades, plus whale wall breakouts (choose "Any alert() function call").

Note: Pine Script cannot read exchange order books, so the walls are built from executed volume rather than resting limit orders. This is an educational tool, not financial advice.

━━━━━━━━━━━━━━━━━━━━

🇮🇩 Indonesia · Bahasa Indonesia

Whale Zones Coach menampilkan di mana uang besar diperdagangkan. Indikator ini membangun peta volume-per-harga dari N bar terakhir dan memilih zona terberat di setiap sisi harga sebagai dinding paus: merah di atas harga (dinding jual/resistance), hijau di bawah harga (dinding beli/support). Lingkaran hijau/merah menandai transaksi besar (volume abnormal). Panel daftar menunjukkan harga, nilai, umur dan jarak setiap dinding, sedangkan panel pelatih memberi tips langsung. Catatan: Pine tidak bisa membaca order book, jadi dinding dihitung dari volume yang terjadi. Alat edukasi, bukan saran keuangan.

━━━━━━━━━━━━━━━━━━━━

🇩🇪 Germany · Deutsch

Whale Zones Coach zeigt, wo das große Geld gehandelt hat. Aus den letzten N Kerzen entsteht eine Volumen-nach-Preis-Karte, und auf jeder Seite des Kurses werden die schwersten Zonen als Wal-Wände gewählt: rot darüber (Verkaufswände/Widerstand), grün darunter (Kaufwände/Unterstützung). Grüne und rote Ringe markieren Großtrades (ungewöhnliches Volumen). Die Liste zeigt Preis, Wert, Alter und Abstand jeder Wand, das Coach-Panel gibt Live-Tipps. Hinweis: Pine kann keine Orderbücher lesen, daher basieren die Wände auf gehandeltem Volumen. Lernwerkzeug, keine Finanzberatung.

━━━━━━━━━━━━━━━━━━━━

🇪🇸 Spain · Español

Whale Zones Coach muestra dónde operó el dinero grande. Construye un mapa de volumen por precio de las últimas N velas y elige las zonas más pesadas a cada lado del precio como muros de ballenas: rojos arriba (muros de venta/resistencia) y verdes abajo (muros de compra/soporte). Los anillos verdes y rojos marcan operaciones grandes (volumen anormal). La lista muestra precio, valor, edad y distancia de cada muro, y el panel coach da consejos en vivo. Nota: Pine no puede leer libros de órdenes, así que los muros se calculan con el volumen ejecutado. Herramienta educativa, no es asesoría financiera.

━━━━━━━━━━━━━━━━━━━━

🇫🇷 France · Français

Whale Zones Coach montre où le gros argent a échangé. Il construit une carte volume-par-prix sur les N dernières bougies et choisit les zones les plus lourdes de chaque côté du prix comme murs de baleines : rouges au-dessus (murs de vente/résistance), verts en dessous (murs d'achat/support). Les anneaux verts et rouges signalent les gros trades (volume anormal). La liste affiche prix, valeur, âge et distance de chaque mur, et le panneau coach donne des conseils en direct. Note : Pine ne peut pas lire les carnets d'ordres, les murs sont donc calculés à partir du volume exécuté. Outil éducatif, pas un conseil financier.

━━━━━━━━━━━━━━━━━━━━

☀️ Kurdistan · Kurdî Kurmancî

Whale Zones Coach nîşan dide ku pereyê mezin li ku derê hatiye bazirganîkirin. Ji N mûmên dawî nexşeyek qebare-li-gor-bihayê çêdike û li her aliyê bihayê herêmên herî giran wek dîwarên balîneyan hildibijêre: sor li jor (dîwarên firotinê/berxwedan), kesk li jêr (dîwarên kirînê/piştgirî). Xelekên kesk û sor bazirganiyên mezin (qebareya ne-asayî) nîşan didin. Lîste biha, nirx, temen û dûriya her dîwarî nîşan dide, û panela rêber şîretên zindî dide. Nîşe: Pine nikare order book bixwîne, ji ber vê yekê dîwar ji qebareya pêkhatî têne hesibandin. Amûra perwerdeyî ye, ne şîreta darayî ye.

━━━━━━━━━━━━━━━━━━━━

🇧🇷 Brazil · Português

Whale Zones Coach mostra onde o dinheiro grande negociou. Cria um mapa de volume por preço das últimas N velas e escolhe as zonas mais pesadas de cada lado do preço como muros de baleias: vermelhos acima (muros de venda/resistência) e verdes abaixo (muros de compra/suporte). Anéis verdes e vermelhos marcam grandes negociações (volume anormal). A lista mostra preço, valor, idade e distância de cada muro, e o painel coach dá dicas ao vivo. Nota: o Pine não lê livros de ofertas, então os muros são calculados com o volume executado. Ferramenta educacional, não é recomendação financeira.

━━━━━━━━━━━━━━━━━━━━

🇻🇳 Vietnam · Tiếng Việt

Whale Zones Coach cho thấy dòng tiền lớn đã giao dịch ở đâu. Chỉ báo xây bản đồ khối lượng theo giá từ N nến gần nhất và chọn các vùng nặng nhất ở mỗi phía của giá làm tường cá voi: đỏ phía trên (tường bán/kháng cự), xanh phía dưới (tường mua/hỗ trợ). Vòng tròn xanh và đỏ đánh dấu giao dịch lớn (khối lượng bất thường). Bảng danh sách hiển thị giá, giá trị, tuổi và khoảng cách của từng tường, còn bảng huấn luyện đưa ra gợi ý trực tiếp. Lưu ý: Pine không đọc được sổ lệnh, nên tường được tính từ khối lượng đã khớp. Công cụ giáo dục, không phải lời khuyên tài chính.

━━━━━━━━━━━━━━━━━━━━

🇹🇷 Türkiye · Türkçe

Whale Zones Coach büyük paranın nerede işlem gördüğünü gösterir. Son N mumdan fiyat bazlı hacim haritası çıkarır ve fiyatın her iki tarafındaki en ağır bölgeleri balina duvarı olarak seçer: üstte kırmızı (satış duvarı/direnç), altta yeşil (alış duvarı/destek). Yeşil ve kırmızı halkalar büyük işlemleri (anormal hacim) işaretler. Liste panelinde her duvarın fiyatı, değeri, yaşı ve uzaklığı, koç panelinde ise canlı ipuçları yer alır. Not: Pine emir defterini okuyamaz, bu yüzden duvarlar gerçekleşen hacimden hesaplanır. Eğitim aracıdır, yatırım tavsiyesi değildir.

━━━━━━━━━━━━━━━━━━━━

🇷🇺 Russia · Русский

Whale Zones Coach показывает, где торговали крупные деньги. Индикатор строит карту объёма по цене за последние N свечей и выбирает самые тяжёлые зоны с каждой стороны от цены как стены китов: красные сверху (стены продаж/сопротивление), зелёные снизу (стены покупок/поддержка). Зелёные и красные кольца отмечают крупные сделки (аномальный объём). Список показывает цену, объём, возраст и дистанцию каждой стены, а панель тренера даёт подсказки в реальном времени. Примечание: Pine не видит биржевой стакан, поэтому стены рассчитываются по исполненному объёму. Обучающий инструмент, не финансовый совет.

━━━━━━━━━━━━━━━━━━━━

🇨🇳 China · 中文

Whale Zones Coach 显示大资金在哪里成交。指标根据最近 N 根K线构建价格-成交量分布，并在价格两侧分别选出最重的区域作为巨鲸墙：上方为红色（卖墙/阻力），下方为绿色（买墙/支撑）。绿色和红色圆环标记大单（异常成交量）。列表面板显示每道墙的价格、金额、时长和距离，教练面板提供实时提示。注意：Pine 无法读取订单簿，因此墙体基于已成交量计算。仅供学习，不构成投资建议。

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheTrendTutor
//@version=6
indicator("Whale Zones Coach [TheTrendTutor]", shorttitle = "Whale Zones Coach", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 3000)

// ═══════════════════════ LANGUAGE ═══════════════════════
string GRP_L  = "🌐 Language"
string langIn = input.string("English", "Language", options = ["English", "Bahasa Indonesia", "Deutsch", "Español", "Français", "Kurdî Kurmancî", "Português", "Tiếng Việt", "Türkçe", "Русский", "中文"], group = GRP_L, display = display.none)
int LI = switch langIn
    "Bahasa Indonesia" => 1
    "Deutsch"          => 2
    "Español"          => 3
    "Français"         => 4
    "Kurdî Kurmancî"   => 5
    "Português"        => 6
    "Tiếng Việt"       => 7
    "Türkçe"           => 8
    "Русский"          => 9
    "中文"              => 10
    => 0

f_t(string s) =>
    str.split(s, "|").get(LI)

// Order: EN | ID | DE | ES | FR | KU | PT | VI | TR | RU | ZH
string K_TITLE  = "Whale Coach|Pelatih Paus|Wal-Coach|Entrenador de Ballenas|Coach Baleines|Rêberê Balîneyan|Treinador de Baleias|Huấn luyện Cá voi|Balina Koçu|Тренер Китов|巨鲸教练"
string K_SELL   = "Sell wall|Dinding jual|Verkaufswand|Muro de venta|Mur de vente|Dîwarê firotinê|Muro de venda|Tường bán|Satış duvarı|Стена продаж|卖墙"
string K_BUY    = "Buy wall|Dinding beli|Kaufwand|Muro de compra|Mur d'achat|Dîwarê kirînê|Muro de compra|Tường mua|Alış duvarı|Стена покупок|买墙"
string K_LAST   = "Last big trade|Transaksi besar terakhir|Letzter Großtrade|Última operación grande|Dernier gros trade|Bazirganiya mezin a dawî|Última grande operação|Giao dịch lớn gần nhất|Son büyük işlem|Последняя крупная сделка|最近大单"
string K_BUYW   = "BUY|BELI|KAUF|COMPRA|ACHAT|KIRÎN|COMPRA|MUA|ALIŞ|ПОКУПКА|买入"
string K_SELLW  = "SELL|JUAL|VERKAUF|VENTA|VENTE|FIROTIN|VENDA|BÁN|SATIŞ|ПРОДАЖА|卖出"
string K_AGO    = "bars ago|bar lalu|Kerzen her|velas atrás|bougies avant|mûm berê|velas atrás|nến trước|mum önce|свечей назад|根K线前"
string K_PRESS  = "Pressure|Tekanan|Druck|Presión|Pression|Zext|Pressão|Áp lực|Baskı|Давление|压力"
string K_SELLH  = "Sellers heavier above|Penjual lebih berat di atas|Verkäufer oben stärker|Vendedores más fuertes arriba|Vendeurs plus lourds au-dessus|Firoşkar li jor girantir in|Vendedores mais fortes acima|Bên bán mạnh hơn phía trên|Yukarıda satıcı ağır|Продавцы сильнее сверху|上方卖方更重"
string K_BUYH   = "Buyers heavier below|Pembeli lebih berat di bawah|Käufer unten stärker|Compradores más fuertes abajo|Acheteurs plus lourds en dessous|Kiryar li jêr girantir in|Compradores mais fortes abaixo|Bên mua mạnh hơn phía dưới|Aşağıda alıcı ağır|Покупатели сильнее снизу|下方买方更重"
string K_BAL    = "Balanced|Seimbang|Ausgeglichen|Equilibrado|Équilibré|Hevseng|Equilibrado|Cân bằng|Dengeli|Баланс|均衡"
string K_TIPS   = "Testing a sell wall: watch for rejection or a high-volume breakout.|Menguji dinding jual: perhatikan penolakan atau breakout bervolume tinggi.|Test einer Verkaufswand: auf Abprall oder Ausbruch mit hohem Volumen achten.|Probando un muro de venta: vigila rechazo o ruptura con alto volumen.|Test d'un mur de vente : surveillez un rejet ou une cassure à fort volume.|Dîwarê firotinê tê ceribandin: li vegerê an şikandina bi qebareya bilind binêre.|Testando um muro de venda: observe rejeição ou rompimento com alto volume.|Đang thử tường bán: chú ý bị từ chối hoặc phá vỡ với khối lượng lớn.|Satış duvarı test ediliyor: ret ya da yüksek hacimli kırılım izle.|Тест стены продаж: следи за отбоем или пробоем на высоком объёме.|正在测试卖墙：留意回落或放量突破。"
string K_TIPB   = "Testing a buy wall: watch for a bounce or a high-volume breakdown.|Menguji dinding beli: perhatikan pantulan atau breakdown bervolume tinggi.|Test einer Kaufwand: auf Abprall oder Bruch mit hohem Volumen achten.|Probando un muro de compra: vigila rebote o ruptura bajista con alto volumen.|Test d'un mur d'achat : surveillez un rebond ou une cassure baissière à fort volume.|Dîwarê kirînê tê ceribandin: li hilpekînê an şikestina bi qebareya bilind binêre.|Testando um muro de compra: observe repique ou rompimento de baixa com alto volume.|Đang thử tường mua: chú ý bật lên hoặc thủng với khối lượng lớn.|Alış duvarı test ediliyor: tepki ya da yüksek hacimli kırılım izle.|Тест стены покупок: следи за отскоком или пробоем вниз на высоком объёме.|正在测试买墙：留意反弹或放量跌破。"
string K_TIPM   = "Between walls: thick zones act as magnets and barriers.|Di antara dinding: zona tebal bertindak sebagai magnet dan penghalang.|Zwischen den Wänden: dicke Zonen wirken als Magnet und Barriere.|Entre muros: las zonas gruesas actúan como imanes y barreras.|Entre les murs : les zones épaisses agissent comme aimants et barrières.|Di navbera dîwaran de: herêmên stûr wek magnet û asteng dixebitin.|Entre muros: zonas grossas agem como ímãs e barreiras.|Giữa các tường: vùng dày đóng vai trò nam châm và rào cản.|Duvarlar arasında: kalın bölgeler mıknatıs ve engel gibi çalışır.|Между стенами: толстые зоны работают как магнит и барьер.|处于墙之间：厚区域既是磁铁也是屏障。"
string K_NOSELL = "No sell wall above: open space, breakouts can run further.|Tidak ada dinding jual di atas: ruang terbuka, breakout bisa berlanjut jauh.|Keine Verkaufswand oben: freier Raum, Ausbrüche können weiter laufen.|Sin muro de venta arriba: espacio libre, las rupturas pueden extenderse.|Aucun mur de vente au-dessus : espace libre, les cassures peuvent aller plus loin.|Li jor dîwarê firotinê tune: cihê vekirî, şikandin dikarin dûrtir biçin.|Sem muro de venda acima: espaço livre, rompimentos podem ir mais longe.|Không có tường bán phía trên: vùng trống, đột phá có thể đi xa hơn.|Yukarıda satış duvarı yok: alan açık, kırılımlar uzayabilir.|Сверху нет стены продаж: свободное пространство, пробой может уйти дальше.|上方无卖墙：空间开阔，突破可能走得更远。"
string K_NOBUY  = "No buy wall below: support is thin, drops can extend.|Tidak ada dinding beli di bawah: support tipis, penurunan bisa berlanjut.|Keine Kaufwand unten: dünne Unterstützung, Rückgänge können sich ausweiten.|Sin muro de compra abajo: soporte débil, las caídas pueden extenderse.|Aucun mur d'achat en dessous : support faible, les baisses peuvent s'étendre.|Li jêr dîwarê kirînê tune: piştgirî qels e, daketin dikarin dirêj bibin.|Sem muro de compra abaixo: suporte fraco, quedas podem se estender.|Không có tường mua phía dưới: hỗ trợ mỏng, giảm có thể kéo dài.|Aşağıda alış duvarı yok: destek zayıf, düşüşler uzayabilir.|Снизу нет стены покупок: поддержка слабая, падение может продолжиться.|下方无买墙：支撑薄弱，下跌可能延续。"
string K_NOTE   = "Walls = high-volume price zones (Pine cannot read order books).|Dinding = zona harga bervolume tinggi (Pine tidak bisa membaca order book).|Wände = Preiszonen mit hohem Volumen (Pine liest keine Orderbücher).|Muros = zonas de precio con alto volumen (Pine no lee libros de órdenes).|Murs = zones de prix à fort volume (Pine ne lit pas les carnets d'ordres).|Dîwar = herêmên bihayê bi qebareya bilind (Pine nikare order book bixwîne).|Muros = zonas de preço com alto volume (Pine não lê livros de ofertas).|Tường = vùng giá khối lượng lớn (Pine không đọc được sổ lệnh).|Duvar = yüksek hacimli fiyat bölgesi (Pine emir defterini okuyamaz).|Стены = зоны цены с высоким объёмом (Pine не видит стакан).|墙 = 高成交量价格区（Pine 无法读取订单簿）。"
string K_NOVOL  = "No volume data on this symbol.|Tidak ada data volume pada simbol ini.|Keine Volumendaten für dieses Symbol.|Sin datos de volumen en este símbolo.|Aucune donnée de volume pour ce symbole.|Ji bo vê sembolê daneyên qebareyê tune ne.|Sem dados de volume neste ativo.|Mã này không có dữ liệu khối lượng.|Bu sembolde hacim verisi yok.|Нет данных объёма по этому символу.|该品种无成交量数据。"
string K_HDR    = "Whale Zones|Zona Paus|Wal-Zonen|Zonas de Ballenas|Zones Baleines|Herêmên Balîneyan|Zonas de Baleias|Vùng Cá voi|Balina Bölgeleri|Зоны Китов|巨鲸区域"
string K_PRICE  = "Price|Harga|Preis|Precio|Prix|Biha|Preço|Giá|Fiyat|Цена|价格"
string K_VAL    = "Value|Nilai|Wert|Valor|Valeur|Nirx|Valor|Giá trị|Değer|Объём|金额"
string K_AGE    = "Age|Umur|Alter|Edad|Âge|Temen|Idade|Tuổi|Yaş|Возраст|时长"
string K_DIST   = "Dist|Jarak|Abst.|Dist.|Dist.|Dûrî|Dist.|K.cách|Uzaklık|Дист.|距离"
string K_NONE   = "none|tidak ada|keine|ninguno|aucun|tune|nenhum|không có|yok|нет|无"

// ═══════════════════════ INPUTS ═══════════════════════
string GRP_W        = "🐋 Whale Walls"
int   lookback      = input.int(500, "Lookback (bars)", minval = 50, maxval = 2500, group = GRP_W, tooltip = "How many bars are scanned to build the volume-by-price map.", display = display.none)
int   nRows         = input.int(80, "Price rows (resolution)", minval = 20, maxval = 200, group = GRP_W, display = display.none)
int   wallsPerSide  = input.int(6, "Walls per side (sell / buy)", minval = 1, maxval = 15, group = GRP_W, display = display.none)
float wallMult      = input.float(1.5, "Min wall strength (x side average)", minval = 1.0, step = 0.1, group = GRP_W, display = display.none)
int   minGap        = input.int(3, "Min gap between walls (rows)", minval = 1, maxval = 20, group = GRP_W, display = display.none)
float maxDist       = input.float(15.0, "Max distance from price % (0 = off)", minval = 0.0, step = 0.5, group = GRP_W, display = display.none)
int   extRight      = input.int(15, "Extend right (bars)", minval = 0, maxval = 200, group = GRP_W, display = display.none)
bool  showVal       = input.bool(true, "Show value tags", group = GRP_W, display = display.none)
color sellCol       = input.color(#e53935, "Sell wall", group = GRP_W, inline = "col", display = display.none)
color buyCol        = input.color(#43a047, "Buy wall", group = GRP_W, inline = "col", display = display.none)

string GRP_T  = "💥 Large Trades"
bool  showLT  = input.bool(true, "Show large trade rings", group = GRP_T, display = display.none)
int   ltLen   = input.int(100, "Volume baseline length", minval = 20, group = GRP_T, display = display.none)
float ltZ     = input.float(2.5, "Z-score threshold", minval = 1.0, step = 0.1, group = GRP_T, tooltip = "Higher = only the most extreme volume candles are marked.", display = display.none)

string GRP_P      = "📋 Panels"
bool   showList   = input.bool(true, "Show whale list", group = GRP_P, display = display.none)
string listPosIn  = input.string("Top Right", "List position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group = GRP_P, display = display.none)
bool   showCoach  = input.bool(true, "Show coach panel", group = GRP_P, display = display.none)
string coachPosIn = input.string("Bottom Left", "Coach position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group = GRP_P, display = display.none)
float  nearPct    = input.float(0.5, "'Near wall' distance %", minval = 0.05, step = 0.05, group = GRP_P, display = display.none)
string txtIn      = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GRP_P, display = display.none)

// ═══════════════════════ HELPERS ═══════════════════════
color PANEL_BG = color.new(#0b0f17, 5)
color HEAD_BG  = #131a26
color FRAME    = #2a3446
color TXT      = #d1d4dc
color MUTED    = #8a93a6

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Middle Left"  => position.middle_left
        => position.bottom_left

string TS = switch txtIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

string curr    = syminfo.currency
bool   usdLike = curr == "USD" or curr == "USDT" or curr == "USDC" or curr == "BUSD" or curr == "FDUSD"

f_num(float x) =>
    x >= 1e9 ? str.tostring(x / 1e9, "#.##") + "B" : x >= 1e6 ? str.tostring(x / 1e6, "#.##") + "M" : x >= 1e3 ? str.tostring(x / 1e3, "#.#") + "K" : str.tostring(x, "#")

f_val(float x) =>
    usdLike ? "$" + f_num(x) : f_num(x) + " " + curr

f_pct(float d) =>
    (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%"

f_age(int t) =>
    int ms = timenow - t
    int d  = math.floor(ms / 86400000)
    int h  = math.floor((ms % 86400000) / 3600000)
    int m  = math.floor((ms % 3600000) / 60000)
    d > 0 ? str.tostring(d) + "D " + str.tostring(h) + "H" : h > 0 ? str.tostring(h) + "H " + str.tostring(m) + "M" : str.tostring(m) + "M"

// side 0 = above price (sell), side 1 = below price (buy)
f_ok(float cr, int side) =>
    bool sideOk = side == 0 ? cr > close : cr <= close
    bool distOk = maxDist <= 0 or math.abs(cr - close) / close * 100 <= maxDist
    sideOk and distOk

// ═══════════════════════ LARGE TRADES ═══════════════════════
float vol      = nz(volume)
float vMean    = ta.sma(vol, ltLen)
float vDev     = ta.stdev(vol, ltLen)
float z        = vDev > 0 ? (vol - vMean) / vDev : 0.0
bool  isBuy    = close >= open
bool  bigTrade = z >= ltZ

bool lt1 = showLT and z >= ltZ and z < ltZ * 1.5
bool lt2 = showLT and z >= ltZ * 1.5 and z < ltZ * 2
bool lt3 = showLT and z >= ltZ * 2

plotchar(lt1 ? close : na, "Large trade (S)", "◯", location.absolute, color = isBuy ? buyCol : sellCol, size = size.small, display = display.pane)
plotchar(lt2 ? close : na, "Large trade (M)", "◯", location.absolute, color = isBuy ? buyCol : sellCol, size = size.normal, display = display.pane)
plotchar(lt3 ? close : na, "Large trade (L)", "◯", location.absolute, color = isBuy ? buyCol : sellCol, size = size.large, display = display.pane)

var int  lastBigBar = na
var bool lastBigBuy = false
if bigTrade
    lastBigBar := bar_index
    lastBigBuy := isBuy

var float cumVol = 0.0
cumVol += vol

alertcondition(bigTrade and isBuy, "Large BUY trade", "Whale Zones Coach: large BUY volume on {{ticker}} at {{close}}")
alertcondition(bigTrade and not isBuy, "Large SELL trade", "Whale Zones Coach: large SELL volume on {{ticker}} at {{close}}")

// ═══════════════════════ WHALE WALLS ═══════════════════════
var array<box>   wBoxes  = array.new<box>()
var array<label> wLabels = array.new<label>()
var table listT  = na
var table coachT = showCoach ? table.new(f_pos(coachPosIn), 1, 7, bgcolor = PANEL_BG, frame_color = FRAME, frame_width = 1, border_color = FRAME, border_width = 1) : na

if barstate.islast
    for b in wBoxes
        b.delete()
    wBoxes.clear()
    for l in wLabels
        l.delete()
    wLabels.clear()

    int   n  = math.min(lookback, bar_index + 1)
    float hi = high
    float lo = low
    for i = 0 to n - 1
        hi := math.max(hi, high[i])
        lo := math.min(lo, low[i])
    float rowH = (hi - lo) / nRows

    array<float> wP = array.new_float()
    array<float> wV = array.new_float()
    array<int>   wT = array.new_int()
    float nearSellP = na
    float nearBuyP  = na
    float sellSum   = 0.0
    float buySum    = 0.0

    if rowH > 0 and cumVol > 0
        array<float> rVol = array.new_float(nRows, 0.0)
        array<float> rVal = array.new_float(nRows, 0.0)
        array<float> rMax = array.new_float(nRows, 0.0)
        array<int>   rIdx = array.new_int(nRows, 0)
        for i = 0 to n - 1
            float v = nz(volume[i])
            if v > 0
                int s = math.max(0, math.min(nRows - 1, math.floor((low[i] - lo) / rowH)))
                int e = math.max(0, math.min(nRows - 1, math.floor((high[i] - lo) / rowH)))
                float share = v / (e - s + 1)
                float pv    = share * hlc3[i]
                for r = s to e
                    rVol.set(r, rVol.get(r) + share)
                    rVal.set(r, rVal.get(r) + pv)
                    if share > rMax.get(r)
                        rMax.set(r, share)
                        rIdx.set(r, i)

        float maxV = rVol.max()
        array<bool> used = array.new_bool(nRows, false)

        for side = 0 to 1
            float sSum = 0.0
            int   sCnt = 0
            for r = 0 to nRows - 1
                if f_ok(lo + (r + 0.5) * rowH, side)
                    sSum += rVol.get(r)
                    sCnt += 1
            float sAvg = sCnt > 0 ? sSum / sCnt : 0.0

            for k = 1 to wallsPerSide
                int   best = -1
                float bv   = 0.0
                for r = 0 to nRows - 1
                    if not used.get(r) and f_ok(lo + (r + 0.5) * rowH, side) and rVol.get(r) > bv
                        bv   := rVol.get(r)
                        best := r
                if best < 0 or bv < sAvg * wallMult
                    break
                for g = math.max(0, best - minGap) to math.min(nRows - 1, best + minGap)
                    used.set(g, true)

                float c      = lo + (best + 0.5) * rowH
                bool  isSell = side == 0
                color col    = isSell ? sellCol : buyCol
                float ratio  = maxV > 0 ? bv / maxV : 0.0
                float half   = rowH * 0.5 * (0.5 + 0.5 * ratio)
                int   transp = math.round(10 + 55 * (1 - ratio))
                int   offs   = rIdx.get(best)

                wBoxes.push(box.new(bar_index - offs, c + half, bar_index + extRight, c - half, border_color = color.new(col, transp), bgcolor = color.new(col, transp)))
                if showVal
                    wLabels.push(label.new(bar_index + extRight, c, f_val(rVal.get(best)), style = label.style_label_right, color = col, textcolor = color.white, size = TS))

                wP.push(c)
                wV.push(rVal.get(best))
                wT.push(time[offs])
                if isSell
                    sellSum += bv
                    if na(nearSellP) or c < nearSellP
                        nearSellP := c
                else
                    buySum += bv
                    if na(nearBuyP) or c > nearBuyP
                        nearBuyP := c

                if close > c and close[1] <= c
                    alert("Whale Zones Coach: " + syminfo.ticker + " broke ABOVE whale wall " + str.tostring(c, format.mintick), alert.freq_once_per_bar_close)
                else if close < c and close[1] >= c
                    alert("Whale Zones Coach: " + syminfo.ticker + " broke BELOW whale wall " + str.tostring(c, format.mintick), alert.freq_once_per_bar_close)

    // ───── Whale list panel (rebuilt each update → no empty rows)
    if showList
        if not na(listT)
            listT.delete()
        int cnt = wP.size()
        listT := table.new(f_pos(listPosIn), 5, cnt + 2, bgcolor = PANEL_BG, frame_color = FRAME, frame_width = 1, border_color = FRAME, border_width = 1)
        listT.cell(0, 0, "🐋 " + f_t(K_HDR) + (usdLike ? "" : " · " + curr), bgcolor = HEAD_BG, text_color = color.white, text_size = TS)
        listT.merge_cells(0, 0, 4, 0)
        listT.cell(0, 1, "", bgcolor = HEAD_BG, text_size = TS)
        listT.cell(1, 1, f_t(K_PRICE), bgcolor = HEAD_BG, text_color = MUTED, text_size = TS)
        listT.cell(2, 1, f_t(K_VAL), bgcolor = HEAD_BG, text_color = MUTED, text_size = TS)
        listT.cell(3, 1, f_t(K_AGE), bgcolor = HEAD_BG, text_color = MUTED, text_size = TS)
        listT.cell(4, 1, f_t(K_DIST), bgcolor = HEAD_BG, text_color = MUTED, text_size = TS)
        if cnt > 0
            array<int> ord = wP.sort_indices(order.descending)
            for j = 0 to cnt - 1
                int   rr  = j + 2
                int   id  = ord.get(j)
                float p   = wP.get(id)
                bool  s   = p > close
                color col = s ? sellCol : buyCol
                color rb  = color.new(col, 78)
                listT.cell(0, rr, s ? "▼" : "▲", bgcolor = rb, text_color = col, text_size = TS)
                listT.cell(1, rr, str.tostring(p, format.mintick), bgcolor = rb, text_color = TXT, text_size = TS, text_halign = text.align_right)
                listT.cell(2, rr, f_val(wV.get(id)), bgcolor = rb, text_color = color.white, text_size = TS, text_halign = text.align_right)
                listT.cell(3, rr, f_age(wT.get(id)), bgcolor = rb, text_color = MUTED, text_size = TS, text_halign = text.align_right)
                listT.cell(4, rr, f_pct((p - close) / close * 100), bgcolor = rb, text_color = col, text_size = TS, text_halign = text.align_right)

    // ───── Coach panel
    if showCoach
        coachT.cell(0, 0, "🐋 " + f_t(K_TITLE), bgcolor = HEAD_BG, text_color = color.white, text_size = TS, text_halign = text.align_left)
        if cumVol <= 0
            coachT.cell(0, 1, f_t(K_NOVOL), text_color = sellCol, text_size = TS, text_halign = text.align_left)
            for rr = 2 to 6
                coachT.cell(0, rr, "", text_size = TS)
        else
            float  dS    = na(nearSellP) ? na : (nearSellP - close) / close * 100
            float  dB    = na(nearBuyP)  ? na : (close - nearBuyP) / close * 100
            string sTxt  = na(nearSellP) ? f_t(K_NONE) : str.tostring(nearSellP, format.mintick) + "  (" + f_pct(dS) + ")"
            string bTxt  = na(nearBuyP)  ? f_t(K_NONE) : str.tostring(nearBuyP, format.mintick) + "  (" + f_pct(-dB) + ")"
            string ltTxt = na(lastBigBar) ? f_t(K_NONE) : (lastBigBuy ? f_t(K_BUYW) : f_t(K_SELLW)) + " · " + str.tostring(bar_index - lastBigBar) + " " + f_t(K_AGO)
            color  ltCol = na(lastBigBar) ? MUTED : lastBigBuy ? buyCol : sellCol
            bool   sH    = sellSum > buySum * 1.25
            bool   bH    = buySum > sellSum * 1.25
            string prTxt = sH ? f_t(K_SELLH) : bH ? f_t(K_BUYH) : f_t(K_BAL)
            color  prCol = sH ? sellCol : bH ? buyCol : MUTED
            string tip   = not na(dS) and dS <= nearPct ? f_t(K_TIPS) : not na(dB) and dB <= nearPct ? f_t(K_TIPB) : na(nearSellP) ? f_t(K_NOSELL) : na(nearBuyP) ? f_t(K_NOBUY) : f_t(K_TIPM)
            coachT.cell(0, 1, "🔴 " + f_t(K_SELL) + ": " + sTxt, text_color = sellCol, text_size = TS, text_halign = text.align_left)
            coachT.cell(0, 2, "🟢 " + f_t(K_BUY) + ": " + bTxt, text_color = buyCol, text_size = TS, text_halign = text.align_left)
            coachT.cell(0, 3, "💥 " + f_t(K_LAST) + ": " + ltTxt, text_color = ltCol, text_size = TS, text_halign = text.align_left)
            coachT.cell(0, 4, "⚖️ " + f_t(K_PRESS) + ": " + prTxt, text_color = prCol, text_size = TS, text_halign = text.align_left)
            coachT.cell(0, 5, "💡 " + tip, text_color = color.white, text_size = TS, text_halign = text.align_left)
            coachT.cell(0, 6, "ℹ️ " + f_t(K_NOTE), text_color = MUTED, text_size = size.tiny, text_halign = text.align_left)
````
