# Risk and Position Size Coach - Lot Size, Stop Loss, R/R Planner

- url: https://www.tradingview.com/script/9Za1phUL/
- type: indicator
- pine_id: PUB;6221aa5f6ac04009a8b5aa165aa63249
- version: 2.0

## Description

Risk and Position Size Coach turns three clicks on your chart into a complete trade plan: position size, lot size, loss at stop, risk/reward and a pre-trade checklist, in 11 languages.

CONTENTS: Overview · Why not the built-in tool? · 30-second start · How it works · Glossary · Simple vs Pro · Alerts · Limitations · 11 languages

━━━━━━━━━━━━━━━━━━━━
🇬🇧 United Kingdom · English
━━━━━━━━━━━━━━━━━━━━

OVERVIEW
Many losing trades are not caused by a bad entry but by a position that was too big for the stop. This tool answers one question before every trade: "If my stop is hit, how much do I lose, and how big should my position be?"

WHY NOT JUST THE BUILT-IN LONG/SHORT TOOL?
TradingView's Long/Short Position drawing tool is great for a quick look at risk/reward. This script is built as a coach on top of that idea and adds:
- Fees and stop slippage built into the size, so the loss at stop equals the risk you chose, not a bit more.
- Forex lot size and crypto size in the base coin (e.g. BTC), with optional account currency conversion.
- A stop check against ATR: is your stop inside normal market noise, or unusually wide?
- A volatility regime reading (low / normal / high) for the current market.
- A 5-point pre-trade checklist: 3 checks are automatic, 2 you confirm yourself.
- Status tracking with "Target reached" and "Stop hit" alerts.
- Every panel text, warning and alert message in 11 languages, so beginners learn the terms in their own language.

30-SECOND START
1. Add the indicator to your chart.
2. Click your entry candle and price, then your stop, then your target.
3. Open Settings and enter your account balance and risk % per trade.
4. Read the panel: position size, loss at stop (1R) and R/R.
You can move the levels later by dragging them on the chart.

HOW IT WORKS
- Direction: stop below entry = long, stop above entry = short.
- Risk amount = Balance × Risk %
- Loss per unit = (|Entry − Stop| + Stop × slippage %) × point value + (Entry + Stop) × point value × fee %
- Position size = Risk amount ÷ Loss per unit
  Fees and slippage are already inside your 1R, so the loss at stop equals the risk you chose.
- R/R = |Target − Entry| ÷ |Entry − Stop|
- Net R/R = (profit at target − fees) ÷ risk amount
- Forex: lots = units ÷ 100,000. Crypto: size is shown in the base coin (e.g. BTC).
- Leverage needed = position value ÷ balance (shown only above 1x).
- ATR stop idea = Entry ∓ ATR(14) × 1.5
- Stop distance: under 0.5 ATR = tight (likely inside normal noise), above 3 ATR = wide.
- Volatility regime: ATR(14) ÷ its 100-bar average. Below 0.8 = low, above 1.3 = high.

GLOSSARY
▶ Entry · ✕ Stop (invalidation) · ◎ Target
Dashed red zone = risk. Solid green zone = reward. Shapes and line styles differ, so the chart stays readable for color-blind users.
Status: Waiting · ◎ Target reached · ✕ Stop hit · ◐ Both touched in one candle (order unknown on that timeframe).

SIMPLE vs PRO
Simple (default): direction, levels, loss at stop, position size, R/R, status.
Pro adds: net R/R after fees, profit at target, position value, leverage needed, stop distance in % and ATR, volatility regime, ATR stop idea, 1R/2R/3R lines and a 5-point checklist (3 automatic, 2 you tick yourself).

ALERTS
"Target reached" and "Stop hit" alert conditions, plus alert messages in your panel language.

LIMITATIONS
- No repaint: all levels come from your inputs. ATR and status update with price like any live indicator.
- Status assumes the trade started at the candle you clicked. It cannot know whether a limit order was filled.
- If stop and target are both touched inside one candle, the order cannot be known from that timeframe.
- Account currency conversion uses TradingView currency rates. Stablecoins like USDT may have no rate; the panel then tells you and uses the symbol currency.
- Point value, lot size and fees differ by broker and exchange. Check your broker's contract specifications.
- This is a planning tool. It does not predict direction and does not make any trade profitable.

QUESTION FOR YOU
What risk % per trade do you use, and on which market? Share it in the comments.

Educational tool, not financial advice.

━━━━━━━━━━━━━━━━━━━━
🇮🇩 Indonesia · Bahasa Indonesia
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach mengubah tiga klik di grafik menjadi rencana trading lengkap: ukuran posisi, ukuran lot, kerugian di stop loss, risiko/imbalan (R/R) dan daftar periksa sebelum trading.

MULAI DALAM 30 DETIK
1. Tambahkan indikator ke grafik.
2. Klik candle dan harga entry, lalu stop loss, lalu target.
3. Di Pengaturan, isi saldo akun dan risiko % per trade.
4. Baca panel: ukuran posisi, kerugian di stop (1R) dan R/R.

CARA KERJA
Ukuran posisi = Jumlah risiko ÷ kerugian per unit. Biaya dan slippage sudah termasuk dalam 1R. Forex ditampilkan dalam lot, kripto dalam koin dasar (misalnya BTC).
Mode Pro menambahkan R/R bersih setelah biaya, leverage yang dibutuhkan, jarak stop dalam ATR, rezim volatilitas, garis 1R/2R/3R dan daftar periksa 5 poin.

BATASAN
- Tidak repaint: level berasal dari input Anda.
- Status mengasumsikan trade dimulai di candle yang Anda klik.
- Nilai poin, lot dan biaya berbeda di setiap broker. Periksa spesifikasi broker Anda.

Alat edukasi, bukan saran keuangan.

━━━━━━━━━━━━━━━━━━━━
🇩🇪 Germany · Deutsch
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach macht aus drei Klicks im Chart einen kompletten Handelsplan: Positionsgröße, Lotgröße, Verlust am Stop-Loss, Chance-Risiko-Verhältnis (CRV) und eine Checkliste vor dem Trade.

START IN 30 SEKUNDEN
1. Indikator zum Chart hinzufügen.
2. Einstiegskerze und Preis anklicken, dann Stop, dann Ziel.
3. In den Einstellungen Kontostand und Risiko % pro Trade eintragen.
4. Panel lesen: Positionsgröße, Verlust am Stop (1R) und CRV.

SO FUNKTIONIERT ES
Positionsgröße = Risikobetrag ÷ Verlust pro Einheit. Gebühren und Slippage sind bereits im 1R enthalten. Forex wird in Lots angezeigt, Krypto in der Basiswährung (z. B. BTC).
Der Pro-Modus ergänzt Netto-CRV nach Gebühren, benötigten Hebel, Stop-Abstand in ATR, Volatilitätsregime, 1R/2R/3R-Linien und eine 5-Punkte-Checkliste.

GRENZEN
- Kein Repaint: Die Level stammen aus deinen Eingaben.
- Der Status geht davon aus, dass der Trade an der angeklickten Kerze begann.
- Punktwert, Lotgröße und Gebühren unterscheiden sich je nach Broker. Prüfe die Kontraktspezifikationen.

Lernwerkzeug, keine Finanzberatung.

━━━━━━━━━━━━━━━━━━━━
🇪🇸 Spain · Español
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach convierte tres clics en el gráfico en un plan de trading completo: tamaño de posición, tamaño de lote, pérdida en el stop loss, relación riesgo/beneficio y una lista de control previa.

INICIO EN 30 SEGUNDOS
1. Añade el indicador al gráfico.
2. Haz clic en la vela y el precio de entrada, luego en el stop y luego en el objetivo.
3. En Configuración, introduce el saldo de tu cuenta y el riesgo % por operación.
4. Lee el panel: tamaño de posición, pérdida en stop (1R) y R/B.

CÓMO FUNCIONA
Tamaño de posición = Riesgo ÷ pérdida por unidad. Comisiones y slippage ya están incluidos en 1R. En forex se muestra en lotes y en cripto en la moneda base (por ejemplo, BTC).
El modo Pro añade R/B neto tras comisiones, apalancamiento necesario, distancia al stop en ATR, régimen de volatilidad, líneas 1R/2R/3R y una lista de control de 5 puntos.

LÍMITES
- Sin repintado: los niveles vienen de tus entradas.
- El estado asume que la operación empezó en la vela que marcaste.
- El valor del punto, el lote y las comisiones varían según el bróker. Revisa sus especificaciones.

Herramienta educativa, no es asesoría financiera.

━━━━━━━━━━━━━━━━━━━━
🇫🇷 France · Français
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach transforme trois clics sur le graphique en un plan de trade complet : taille de position, taille de lot, perte au stop loss, ratio risque/rendement et une checklist avant d'entrer.

DÉMARRAGE EN 30 SECONDES
1. Ajoutez l'indicateur au graphique.
2. Cliquez la bougie et le prix d'entrée, puis le stop, puis l'objectif.
3. Dans les Paramètres, saisissez le solde du compte et le risque % par trade.
4. Lisez le panneau : taille de position, perte au stop (1R) et R/R.

FONCTIONNEMENT
Taille de position = Montant du risque ÷ perte par unité. Les frais et le slippage sont déjà inclus dans 1R. Forex en lots, crypto en devise de base (par ex. BTC).
Le mode Pro ajoute le R/R net après frais, l'effet de levier requis, la distance du stop en ATR, le régime de volatilité, les lignes 1R/2R/3R et une checklist en 5 points.

LIMITES
- Pas de repaint : les niveaux viennent de vos saisies.
- Le statut suppose que le trade a commencé sur la bougie cliquée.
- Valeur du point, lot et frais varient selon le courtier. Vérifiez ses spécifications.

Outil éducatif, pas un conseil financier.

━━━━━━━━━━━━━━━━━━━━
☀️ Kurdistan · Kurdî Kurmancî
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach sê tikandinên li ser grafîkê dike planeke bazirganiyê ya temam: mezinahiya pozîsyonê, mezinahiya lotê, zirara li stopê, rîsk/qezenc û lîsteya kontrolê berî bazirganiyê.

DI 30 SANIYEYAN DE DEST PÊ BIKE
1. Nîşanderê li grafîkê zêde bike.
2. Mûm û bihayê ketinê bitikîne, paşê stopê, paşê armancê.
3. Di Mîhengan de balansa hesabê û rîska % ji bo her bazirganiyê binivîse.
4. Panelê bixwîne: mezinahiya pozîsyonê, zirara li stopê (1R) û R/R.

ÇAWA DIXEBITE
Mezinahiya pozîsyonê = Mîqdara rîskê ÷ zirara ji bo her yekîneyê. Xerc û slippage di nav 1R de ne. Forex bi lot, kripto bi diravê bingehîn (mînak BTC) tê nîşandan.
Moda Pro R/R-ya net piştî xercan, leverage-a pêwîst, dûrahiya stopê bi ATR, rewşa volatîlîteyê, xetên 1R/2R/3R û lîsteya kontrolê ya 5 xalan zêde dike.

SÎNOR
- Repaint tune: ast ji têketinên te tên.
- Rewş dihesibîne ku bazirganî li ser mûma ku te tikandî dest pê kiriye.
- Nirxa xalê, lot û xerc li gorî brokerê diguherin.

Amûra perwerdeyê ye, ne şîreta darayî ye.

━━━━━━━━━━━━━━━━━━━━
🇧🇷 Brazil · Português
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach transforma três cliques no gráfico em um plano de trade completo: tamanho da posição, tamanho do lote, perda no stop loss, risco/retorno e um checklist antes da operação.

COMECE EM 30 SEGUNDOS
1. Adicione o indicador ao gráfico.
2. Clique no candle e no preço de entrada, depois no stop e depois no alvo.
3. Nas Configurações, informe o saldo da conta e o risco % por operação.
4. Leia o painel: tamanho da posição, perda no stop (1R) e R/R.

COMO FUNCIONA
Tamanho da posição = Valor em risco ÷ perda por unidade. Taxas e slippage já estão incluídos no 1R. Forex em lotes, cripto na moeda base (ex.: BTC).
O modo Pro adiciona R/R líquido após taxas, alavancagem necessária, distância do stop em ATR, regime de volatilidade, linhas 1R/2R/3R e um checklist de 5 pontos.

LIMITAÇÕES
- Sem repaint: os níveis vêm das suas entradas.
- O status considera que a operação começou no candle clicado.
- Valor do ponto, lote e taxas variam por corretora. Confira as especificações.

Ferramenta educacional, não é recomendação financeira.

━━━━━━━━━━━━━━━━━━━━
🇻🇳 Vietnam · Tiếng Việt
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach biến ba cú nhấp trên biểu đồ thành một kế hoạch giao dịch hoàn chỉnh: khối lượng vị thế, số lot, mức lỗ khi chạm cắt lỗ, tỷ lệ rủi ro/lợi nhuận và danh sách kiểm tra trước khi vào lệnh.

BẮT ĐẦU TRONG 30 GIÂY
1. Thêm chỉ báo vào biểu đồ.
2. Nhấp vào nến và giá điểm vào, sau đó cắt lỗ, rồi mục tiêu.
3. Trong Cài đặt, nhập số dư tài khoản và % rủi ro mỗi lệnh.
4. Đọc bảng: khối lượng vị thế, lỗ khi chạm cắt lỗ (1R) và R/R.

CÁCH HOẠT ĐỘNG
Khối lượng vị thế = Số tiền rủi ro ÷ mức lỗ mỗi đơn vị. Phí và trượt giá đã nằm trong 1R. Forex hiển thị theo lot, crypto theo đồng cơ sở (ví dụ BTC).
Chế độ Pro thêm R/R ròng sau phí, đòn bẩy cần thiết, khoảng cách cắt lỗ theo ATR, trạng thái biến động, đường 1R/2R/3R và danh sách kiểm tra 5 mục.

GIỚI HẠN
- Không vẽ lại (repaint): các mức lấy từ dữ liệu bạn nhập.
- Trạng thái giả định lệnh bắt đầu từ cây nến bạn đã nhấp.
- Giá trị điểm, lot và phí khác nhau theo sàn. Hãy kiểm tra thông số của sàn.

Công cụ giáo dục, không phải lời khuyên tài chính.

━━━━━━━━━━━━━━━━━━━━
🇹🇷 Türkiye · Türkçe
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach, grafikteki üç tıklamayı eksiksiz bir işlem planına dönüştürür: pozisyon büyüklüğü, lot miktarı, stop olunca zarar, risk/ödül oranı ve işlem öncesi kontrol listesi.

30 SANİYEDE BAŞLA
1. Göstergeyi grafiğe ekle.
2. Giriş mumuna ve fiyatına, ardından stop'a, sonra hedefe tıkla.
3. Ayarlar'da hesap bakiyeni ve işlem başına risk yüzdeni gir.
4. Paneli oku: pozisyon büyüklüğü, stopta zarar (1R) ve R/Ö.

NASIL ÇALIŞIR
Pozisyon büyüklüğü = Risk tutarı ÷ birim başına zarar. Komisyon ve kayma (slippage) 1R'ın içine dahildir. Forex'te lot, kriptoda ana coin (örneğin BTC) cinsinden gösterilir.
Pro mod; komisyon sonrası net R/Ö, gereken kaldıraç, ATR cinsinden stop mesafesi, volatilite rejimi, 1R/2R/3R çizgileri ve 5 maddelik kontrol listesi ekler.

SINIRLAR
- Repaint yok: seviyeler senin girdiğin değerlerden gelir.
- Durum bilgisi, işlemin tıkladığın mumda başladığını varsayar.
- Pip değeri, lot ve komisyon aracı kuruma göre değişir. Kurumunun kontrat özelliklerini kontrol et.

Eğitim aracıdır, yatırım tavsiyesi değildir.

━━━━━━━━━━━━━━━━━━━━
🇷🇺 Russia · Русский
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach превращает три клика на графике в полный торговый план: размер позиции, размер лота, убыток на стоп-лоссе, соотношение риск/прибыль и чек-лист перед сделкой.

СТАРТ ЗА 30 СЕКУНД
1. Добавьте индикатор на график.
2. Кликните свечу и цену входа, затем стоп, затем цель.
3. В настройках укажите баланс счёта и риск % на сделку.
4. Смотрите панель: размер позиции, убыток на стопе (1R) и R/P.

КАК ЭТО РАБОТАЕТ
Размер позиции = Сумма риска ÷ убыток на единицу. Комиссии и проскальзывание уже включены в 1R. Форекс показывается в лотах, крипта в базовой монете (например, BTC).
Режим Pro добавляет чистый R/P после комиссий, нужное плечо, дистанцию стопа в ATR, режим волатильности, линии 1R/2R/3R и чек-лист из 5 пунктов.

ОГРАНИЧЕНИЯ
- Без перерисовки: уровни берутся из ваших настроек.
- Статус предполагает, что сделка началась на выбранной свече.
- Стоимость пункта, лот и комиссии зависят от брокера. Проверьте спецификации контракта.

Обучающий инструмент, не финансовый совет.

━━━━━━━━━━━━━━━━━━━━
🇨🇳 China · 中文
━━━━━━━━━━━━━━━━━━━━

Risk and Position Size Coach 只需在图表上点击三次，即可生成完整的交易计划：仓位大小、手数、止损亏损、风险回报比以及交易前检查清单。

30 秒上手
1. 将指标添加到图表。
2. 依次点击入场K线和价格、止损、目标。
3. 在设置中输入账户余额和每笔交易风险 %。
4. 查看面板：仓位大小、止损亏损 (1R) 和风险回报比。

工作原理
仓位大小 = 风险金额 ÷ 每单位亏损。手续费和滑点已计入 1R。外汇以手数显示，加密货币以基础币种显示 (例如 BTC)。
Pro 模式增加：扣费后的净风险回报比、所需杠杆、以 ATR 表示的止损距离、波动率状态、1R/2R/3R 线和 5 项检查清单。

局限
- 不重绘：所有价位来自你的输入。
- 状态假设交易从你点击的K线开始。
- 点值、手数和手续费因经纪商而异，请查看合约规格。

教育工具，非投资建议。

## Source Code

````pine
//@version=6
// © TheTrendTutor — Risk and Position Size Coach
// Educational tool, not financial advice.
indicator("Risk and Position Size Coach [TheTrendTutor]", shorttitle = "Risk Coach", overlay = true, max_boxes_count = 20, max_lines_count = 40, max_labels_count = 40)

//━━━━━━━━━━━━━━━━━━━━━━━━ INPUTS ━━━━━━━━━━━━━━━━━━━━━━━━
string G1 = "① Trade levels (click on the chart)"
float entryPrice  = input.price(0.0, "Entry", confirm = true, inline = "E", group = G1)
int   entryTime   = input.time(0, "·", confirm = true, inline = "E", group = G1, tooltip = "When you add the indicator: click your entry candle and price, then your stop, then your target. You can move the levels later by dragging them on the chart.")
float stopPrice   = input.price(0.0, "Stop", confirm = true, group = G1)
float targetPrice = input.price(0.0, "Target", confirm = true, group = G1)

string G2 = "② Account"
float  balance = input.float(1000.0, "Account balance", minval = 0.0, step = 100.0, group = G2)
string acctCcy = input.string("Symbol currency", "Account currency", options = ["Symbol currency", "USD", "EUR", "GBP", "TRY", "JPY", "CHF", "AUD", "CAD", "CNY", "RUB", "BRL", "IDR", "VND"], group = G2, tooltip = "Currency of your balance. 'Symbol currency' = the quote currency of the chart (e.g. USDT on BTCUSDT).")
float  riskPct = input.float(1.0, "Risk per trade %", minval = 0.01, maxval = 100.0, step = 0.25, group = G2)
float  maxRisk = input.float(2.0, "My max risk %", minval = 0.01, maxval = 100.0, step = 0.25, group = G2, tooltip = "Your personal limit. The panel warns you if Risk per trade is above it.")
float  feePct  = input.float(0.10, "Fee per side %", minval = 0.0, step = 0.01, group = G2, tooltip = "Exchange / broker commission charged on entry and on exit.")
float  slipPct = input.float(0.05, "Stop slippage %", minval = 0.0, step = 0.01, group = G2, tooltip = "Extra distance your stop order may be filled beyond the stop price.")

string G3 = "③ Coach"
string langIn   = input.string("English", "Language", options = ["English", "Bahasa Indonesia", "Deutsch", "Español", "Français", "Kurdî Kurmancî", "Português", "Tiếng Việt", "Türkçe", "Русский", "中文"], group = G3)
string modeIn   = input.string("Simple", "Mode", options = ["Simple", "Pro"], group = G3, tooltip = "Simple: the essentials for beginners. Pro: fees, leverage, ATR, volatility, R lines and checklist.")
float  minRR    = input.float(1.5, "Minimum R/R", minval = 0.1, step = 0.1, group = G3)
int    atrLen   = input.int(14, "ATR length", minval = 1, group = G3)
float  atrMult  = input.float(1.5, "ATR stop multiplier", minval = 0.1, step = 0.1, group = G3)
bool   chkTrend = input.bool(false, "Checklist: I checked the higher-timeframe trend", group = G3)
bool   chkNews  = input.bool(false, "Checklist: I checked news / economic calendar", group = G3)

string G4 = "④ Display"
string posIn      = input.string("Top right", "Panel position", options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group = G4)
string sizeIn     = input.string("Normal", "Panel text size", options = ["Small", "Normal", "Large"], group = G4)
int    zoneBars   = input.int(12, "Zone length (bars)", minval = 3, maxval = 500, group = G4, tooltip = "How many bars the risk / reward zones extend from the entry candle.")
bool   showRLines = input.bool(true, "Pro: show 1R / 2R / 3R lines", group = G4)
bool   showAtrLn  = input.bool(true, "Pro: show ATR stop idea line", group = G4)
color  cReward    = input.color(color.new(#26A69A, 82), "Reward zone", group = G4)
color  cRisk      = input.color(color.new(#EF5350, 82), "Risk zone", group = G4)
color  cEntry     = input.color(#2962FF, "Entry line", group = G4)

//━━━━━━━━━━━━━━━━━━━━━━━━ LANGUAGE ━━━━━━━━━━━━━━━━━━━━━━━━
int L = switch langIn
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

t(string en, string id_, string de, string es, string fr, string ku, string pt, string vi, string tk, string ru, string zh) =>
    switch L
        1  => id_
        2  => de
        3  => es
        4  => fr
        5  => ku
        6  => pt
        7  => vi
        8  => tk
        9  => ru
        10 => zh
        => en

S_LONG     = t("LONG ▲", "LONG ▲", "LONG ▲", "LONG ▲", "LONG ▲", "LONG ▲", "LONG ▲", "LONG ▲", "LONG ▲", "ЛОНГ ▲", "做多 ▲")
S_SHORT    = t("SHORT ▼", "SHORT ▼", "SHORT ▼", "SHORT ▼", "SHORT ▼", "SHORT ▼", "SHORT ▼", "SHORT ▼", "SHORT ▼", "ШОРТ ▼", "做空 ▼")
S_DIR      = t("Direction", "Arah", "Richtung", "Dirección", "Direction", "Alî", "Direção", "Hướng", "Yön", "Направление", "方向")
S_ENTRY    = t("Entry", "Entry", "Einstieg", "Entrada", "Entrée", "Ketin", "Entrada", "Điểm vào", "Giriş", "Вход", "入场")
S_STOP     = t("Stop", "Stop loss", "Stop", "Stop", "Stop", "Stop", "Stop", "Cắt lỗ", "Stop", "Стоп", "止损")
S_TARGET   = t("Target", "Target", "Ziel", "Objetivo", "Objectif", "Armanc", "Alvo", "Mục tiêu", "Hedef", "Цель", "目标")
S_LOSS     = t("Loss at stop (1R)", "Rugi di stop (1R)", "Verlust am Stop (1R)", "Pérdida en stop (1R)", "Perte au stop (1R)", "Zirar li stopê (1R)", "Perda no stop (1R)", "Lỗ khi chạm cắt lỗ (1R)", "Stopta zarar (1R)", "Убыток на стопе (1R)", "止损亏损 (1R)")
S_SIZE     = t("Position size", "Ukuran posisi", "Positionsgröße", "Tamaño de posición", "Taille de position", "Mezinahiya pozîsyonê", "Tamanho da posição", "Khối lượng vị thế", "Pozisyon büyüklüğü", "Размер позиции", "仓位大小")
S_UNITS    = t("units", "unit", "Einheiten", "unidades", "unités", "yekîne", "unidades", "đơn vị", "adet", "ед.", "单位")
S_LOTS     = t("lots", "lot", "Lots", "lotes", "lots", "lot", "lotes", "lot", "lot", "лот", "手")
S_RR       = t("Risk/Reward", "Risiko/Imbalan", "Risiko/Ertrag", "Riesgo/Beneficio", "Risque/Rendement", "Rîsk/Qezenc", "Risco/Retorno", "Rủi ro/Lợi nhuận", "Risk/Ödül", "Риск/Прибыль", "风险回报比")
S_NETRR    = t("Net R/R (after fees)", "R/R bersih (biaya)", "Netto-R/R (Gebühren)", "R/B neto (comisiones)", "R/R net (frais)", "R/R net (xerc)", "R/R líquido (taxas)", "R/R ròng (sau phí)", "Net R/Ö (komisyon sonrası)", "Чистый R/P (с комиссией)", "净风险回报比 (含费)")
S_PROFIT   = t("Profit at target", "Profit di target", "Gewinn am Ziel", "Beneficio en objetivo", "Gain à l'objectif", "Qezenc li armancê", "Lucro no alvo", "Lợi nhuận tại mục tiêu", "Hedefte kâr", "Прибыль у цели", "目标盈利")
S_VALUE    = t("Position value", "Nilai posisi", "Positionswert", "Valor de posición", "Valeur de position", "Nirxa pozîsyonê", "Valor da posição", "Giá trị vị thế", "Pozisyon değeri", "Стоимость позиции", "仓位价值")
S_LEV      = t("Leverage needed", "Leverage dibutuhkan", "Benötigter Hebel", "Apalancamiento necesario", "Effet de levier requis", "Leverage pêwîst", "Alavancagem necessária", "Đòn bẩy cần", "Gereken kaldıraç", "Нужное плечо", "所需杠杆")
S_DIST     = t("Stop distance", "Jarak stop", "Stop-Abstand", "Distancia al stop", "Distance du stop", "Dûrahiya stopê", "Distância do stop", "Khoảng cách cắt lỗ", "Stop mesafesi", "Дистанция стопа", "止损距离")
S_TIGHT    = t("Tight", "Sempit", "Eng", "Ajustado", "Serré", "Teng", "Apertado", "Hẹp", "Dar", "Узкий", "偏紧")
S_NORMAL   = t("Normal", "Normal", "Normal", "Normal", "Normal", "Normal", "Normal", "Bình thường", "Normal", "Норма", "正常")
S_WIDE     = t("Wide", "Lebar", "Weit", "Amplio", "Large", "Fireh", "Amplo", "Rộng", "Geniş", "Широкий", "偏宽")
S_VOL      = t("Volatility", "Volatilitas", "Volatilität", "Volatilidad", "Volatilité", "Volatîlîte", "Volatilidade", "Biến động", "Volatilite", "Волатильность", "波动率")
S_LOW      = t("Low", "Rendah", "Niedrig", "Baja", "Faible", "Kêm", "Baixa", "Thấp", "Düşük", "Низкая", "低")
S_HIGH     = t("High", "Tinggi", "Hoch", "Alta", "Élevée", "Bilind", "Alta", "Cao", "Yüksek", "Высокая", "高")
S_ATRSTOP  = t("ATR stop idea", "Ide stop ATR", "ATR-Stop-Vorschlag", "Stop ATR sugerido", "Stop ATR suggéré", "Pêşniyara stopa ATR", "Stop ATR sugerido", "Gợi ý cắt lỗ ATR", "ATR stop önerisi", "Стоп по ATR", "ATR止损建议")
S_STATUS   = t("Status", "Status", "Status", "Estado", "Statut", "Rewş", "Status", "Trạng thái", "Durum", "Статус", "状态")
S_WAIT     = t("Waiting", "Menunggu", "Wartend", "Esperando", "En attente", "Li benda", "Aguardando", "Đang chờ", "Bekliyor", "Ожидание", "等待中")
S_TGT_HIT  = t("Target reached", "Target tercapai", "Ziel erreicht", "Objetivo alcanzado", "Objectif atteint", "Armanc hat", "Alvo atingido", "Đạt mục tiêu", "Hedefe ulaştı", "Цель достигнута", "已达目标")
S_STOP_HIT = t("Stop hit", "Stop tersentuh", "Stop ausgelöst", "Stop tocado", "Stop touché", "Stop hat", "Stop atingido", "Chạm cắt lỗ", "Stop oldu", "Стоп сработал", "已触发止损")
S_BOTH     = t("Both hit in 1 candle (order unknown)", "Keduanya di 1 candle (urutan tidak diketahui)", "Beide in 1 Kerze (Reihenfolge unbekannt)", "Ambos en 1 vela (orden desconocido)", "Les deux en 1 bougie (ordre inconnu)", "Herdu di 1 mûmê de (rêz nayê zanîn)", "Ambos em 1 vela (ordem desconhecida)", "Cả hai trong 1 nến (không rõ thứ tự)", "İkisi de 1 mumda (sıra belirsiz)", "Оба в 1 свече (порядок неизвестен)", "同一K线触及两者 (顺序未知)")
S_CHECK    = t("Checklist", "Daftar periksa", "Checkliste", "Lista de control", "Checklist", "Lîsteya kontrolê", "Checklist", "Danh sách kiểm tra", "Kontrol listesi", "Чек-лист", "检查清单")
S_C1       = t("R/R ≥ minimum", "R/R ≥ minimum", "R/R ≥ Minimum", "R/B ≥ mínimo", "R/R ≥ minimum", "R/R ≥ kêmtirîn", "R/R ≥ mínimo", "R/R ≥ tối thiểu", "R/Ö ≥ asgari", "R/P ≥ минимум", "风险回报 ≥ 最低值")
S_C2       = t("Risk ≤ my max %", "Risiko ≤ batas saya", "Risiko ≤ mein Max.", "Riesgo ≤ mi máximo", "Risque ≤ mon max", "Rîsk ≤ sînorê min", "Risco ≤ meu máximo", "Rủi ro ≤ mức tối đa", "Risk ≤ azami limitim", "Риск ≤ мой максимум", "风险 ≤ 我的上限")
S_C3       = t("Stop outside noise (≥0.5 ATR)", "Stop di luar noise (≥0.5 ATR)", "Stop außerhalb des Rauschens (≥0,5 ATR)", "Stop fuera del ruido (≥0,5 ATR)", "Stop hors du bruit (≥0,5 ATR)", "Stop li derveyî dengê (≥0.5 ATR)", "Stop fora do ruído (≥0,5 ATR)", "Cắt lỗ ngoài vùng nhiễu (≥0.5 ATR)", "Stop gürültü dışında (≥0,5 ATR)", "Стоп вне шума (≥0,5 ATR)", "止损在噪音之外 (≥0.5 ATR)")
S_C4       = t("Higher-TF trend checked", "Tren TF besar sudah dicek", "Trend im höheren TF geprüft", "Tendencia de TF mayor revisada", "Tendance UT sup. vérifiée", "Trenda TF-ya mezin kontrol kir", "Tendência do TF maior verificada", "Đã xem xu hướng khung lớn", "Üst zaman dilimi trendi bakıldı", "Тренд старшего ТФ проверен", "已检查大周期趋势")
S_C5       = t("News / calendar checked", "Berita / kalender sudah dicek", "News / Kalender geprüft", "Noticias / calendario revisados", "Actus / calendrier vérifiés", "Nûçe / salname kontrol kir", "Notícias / calendário verificados", "Đã xem tin tức / lịch", "Haber / takvim bakıldı", "Новости / календарь проверены", "已查看新闻 / 日历")
S_CLICK    = t("Click Entry, Stop and Target on the chart", "Klik Entry, Stop dan Target di grafik", "Klicke Einstieg, Stop und Ziel im Chart an", "Haz clic en Entrada, Stop y Objetivo en el gráfico", "Cliquez Entrée, Stop et Objectif sur le graphique", "Li ser grafîkê Ketin, Stop û Armancê bitikîne", "Clique em Entrada, Stop e Alvo no gráfico", "Nhấp Điểm vào, Cắt lỗ và Mục tiêu trên biểu đồ", "Grafikte Giriş, Stop ve Hedef'e tıklayın", "Отметьте на графике Вход, Стоп и Цель", "在图表上点击入场、止损和目标")
S_INVALID  = t("⚠ Stop and target must be on opposite sides of entry", "⚠ Stop dan target harus di sisi berlawanan dari entry", "⚠ Stop und Ziel müssen auf verschiedenen Seiten des Einstiegs liegen", "⚠ Stop y objetivo deben estar a lados opuestos de la entrada", "⚠ Stop et objectif doivent être de part et d'autre de l'entrée", "⚠ Stop û armanc divê li du aliyên cuda yên ketinê bin", "⚠ Stop e alvo devem ficar em lados opostos da entrada", "⚠ Cắt lỗ và mục tiêu phải ở hai phía của điểm vào", "⚠ Stop ve hedef, girişin zıt taraflarında olmalı", "⚠ Стоп и цель должны быть по разные стороны от входа", "⚠ 止损与目标须位于入场价两侧")
S_FIX      = t("Drag the levels on the chart or edit them in Settings → ①", "Geser level di grafik atau ubah di Pengaturan → ①", "Level im Chart ziehen oder in Einstellungen → ① ändern", "Arrastra los niveles en el gráfico o edítalos en Configuración → ①", "Déplacez les niveaux sur le graphique ou modifiez-les dans Paramètres → ①", "Astan li ser grafîkê bikişîne an di Mîhengan → ① de biguherîne", "Arraste os níveis no gráfico ou edite em Configurações → ①", "Kéo các mức trên biểu đồ hoặc sửa trong Cài đặt → ①", "Seviyeleri grafikte sürükle veya Ayarlar → ① bölümünden düzelt", "Перетащите уровни на графике или измените в Настройках → ①", "在图表上拖动价位，或在设置 → ① 中修改")
S_W_RISK   = t("⚠ Risk is above your max %", "⚠ Risiko di atas batas Anda", "⚠ Risiko über deinem Maximum", "⚠ Riesgo por encima de tu máximo", "⚠ Risque au-dessus de ton maximum", "⚠ Rîsk ji sînorê te zêdetir e", "⚠ Risco acima do seu máximo", "⚠ Rủi ro vượt mức tối đa của bạn", "⚠ Risk, azami limitinin üstünde", "⚠ Риск выше вашего максимума", "⚠ 风险超过你的上限")
S_W_RR     = t("⚠ Reward is smaller than risk", "⚠ Imbalan lebih kecil dari risiko", "⚠ Ertrag kleiner als Risiko", "⚠ El beneficio es menor que el riesgo", "⚠ Le gain est inférieur au risque", "⚠ Qezenc ji rîskê kêmtir e", "⚠ O retorno é menor que o risco", "⚠ Lợi nhuận nhỏ hơn rủi ro", "⚠ Ödül, riskten küçük", "⚠ Прибыль меньше риска", "⚠ 回报小于风险")
S_W_FX     = t("⚠ No FX rate: symbol currency used", "⚠ Kurs tidak ada: mata uang simbol dipakai", "⚠ Kein Kurs: Symbolwährung verwendet", "⚠ Sin tipo de cambio: se usa la divisa del símbolo", "⚠ Taux indisponible : devise du symbole utilisée", "⚠ Rêjeya diravî tune: diravê sembolê tê bikaranîn", "⚠ Sem câmbio: moeda do símbolo usada", "⚠ Không có tỷ giá: dùng tiền tệ của mã", "⚠ Kur yok: sembolün para birimi kullanıldı", "⚠ Нет курса: используется валюта символа", "⚠ 无汇率:使用品种计价货币")
S_TIP      = t("1R = what you lose if the stop is hit", "1R = kerugian Anda jika stop tersentuh", "1R = dein Verlust, wenn der Stop greift", "1R = lo que pierdes si salta el stop", "1R = ta perte si le stop est touché", "1R = ya ku tu winda dikî heke stop bibe", "1R = o que você perde se o stop for atingido", "1R = số tiền mất nếu chạm cắt lỗ", "1R = stop olursan kaybedeceğin tutar", "1R = ваш убыток при срабатывании стопа", "1R = 触发止损时的亏损")
S_EDU      = t("Educational tool · not financial advice", "Alat edukasi · bukan saran keuangan", "Lernwerkzeug · keine Finanzberatung", "Herramienta educativa · no es asesoría financiera", "Outil éducatif · pas un conseil financier", "Amûra perwerdeyê · ne şîreta darayî ye", "Ferramenta educacional · não é recomendação financeira", "Công cụ giáo dục · không phải lời khuyên tài chính", "Eğitim aracıdır · yatırım tavsiyesi değildir", "Обучающий инструмент · не финансовый совет", "教育工具 · 非投资建议")

//━━━━━━━━━━━━━━━━━━━━━━━━ CALCULATIONS ━━━━━━━━━━━━━━━━━━━━━━━━
bool isPro     = modeIn == "Pro"
bool levelsSet = entryPrice > 0 and stopPrice > 0 and targetPrice > 0
bool isLong    = stopPrice < entryPrice
bool valid     = levelsSet and entryPrice != stopPrice and (isLong ? targetPrice > entryPrice : targetPrice < entryPrice)

// Currency conversion (account currency -> symbol quote currency)
string quoteCcy = syminfo.currency
bool   sameCcy  = acctCcy == "Symbol currency" or acctCcy == quoteCcy
string fromCcy  = sameCcy ? quoteCcy : acctCcy
float  fxRaw    = request.currency_rate(fromCcy, quoteCcy, ignore_invalid_currency = true)
bool   fxFail   = not sameCcy and na(fxRaw)
float  rate     = sameCcy or na(fxRaw) ? 1.0 : fxRaw
string ccyLbl   = sameCcy or fxFail ? quoteCcy : acctCcy

// Volatility
float atrVal   = ta.atr(atrLen)
float atrBase  = ta.sma(atrVal, 100)
float volRatio = atrVal / atrBase

// Position math (fees and stop slippage are included inside 1R)
float pv          = syminfo.pointvalue
float riskAcct    = balance * riskPct / 100.0
float riskQuote   = riskAcct * rate
float dist        = math.abs(entryPrice - stopPrice)
float lossPerUnit = (dist + stopPrice * slipPct / 100.0) * pv + (entryPrice + stopPrice) * pv * feePct / 100.0
float qty         = valid and lossPerUnit > 0 ? riskQuote / lossPerUnit : na
float notional    = qty * entryPrice * pv
float lev         = notional / (balance * rate)
float rr          = valid ? math.abs(targetPrice - entryPrice) / dist : na
float grossProfit = qty * math.abs(targetPrice - entryPrice) * pv
float feesAtTgt   = qty * (entryPrice + targetPrice) * pv * feePct / 100.0
float netProfit   = grossProfit - feesAtTgt
float netRR       = netProfit / riskQuote
float distPct     = dist / entryPrice * 100.0
float distAtr     = dist / atrVal
float atrStop     = isLong ? entryPrice - atrVal * atrMult : entryPrice + atrVal * atrMult

string stopClass = distAtr < 0.5 ? S_TIGHT : distAtr > 3.0 ? S_WIDE : S_NORMAL
string volClass  = volRatio < 0.8 ? S_LOW : volRatio > 1.3 ? S_HIGH : S_NORMAL

// Checklist
bool c1 = rr >= minRR
bool c2 = riskPct <= maxRisk
bool c3 = distAtr >= 0.5
bool c4 = chkTrend
bool c5 = chkNews
int  score = (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) + (c5 ? 1 : 0)

// Trade status: assumes the trade started at the clicked candle
var int state = 0   // 0 waiting · 1 target · 2 stop · 3 both in one candle
if valid and time > entryTime and state == 0
    bool hitT = isLong ? high >= targetPrice : low <= targetPrice
    bool hitS = isLong ? low <= stopPrice : high >= stopPrice
    state := hitT and hitS ? 3 : hitT ? 1 : hitS ? 2 : 0
int prevState = nz(state[1])

//━━━━━━━━━━━━━━━━━━━━━━━━ HELPERS ━━━━━━━━━━━━━━━━━━━━━━━━
fmtP(float p) => na(p) ? "—" : str.tostring(p, format.mintick)
fmtM(float v, string c) => na(v) ? "—" : str.tostring(v, "#,##0.00") + " " + c
fmtQ(float q) => na(q) ? "—" : q >= 1000 ? str.tostring(q, "#,##0") : q >= 1 ? str.tostring(q, "#,##0.###") : str.tostring(q, "0.######")

row(table tb, int r, string k, string v, color vc, color kc, string sz) =>
    table.cell(tb, 0, r, k, text_color = kc, text_size = sz, text_halign = text.align_left)
    table.cell(tb, 1, r, v, text_color = vc, text_size = sz, text_halign = text.align_right)
    r + 1

wide(table tb, int r, string v, color tc, color bg, string sz, string al) =>
    table.cell(tb, 0, r, v, text_color = tc, bgcolor = bg, text_size = sz, text_halign = al)
    table.merge_cells(tb, 0, r, 1, r)
    r + 1

//━━━━━━━━━━━━━━━━━━━━━━━━ STYLE (auto light / dark) ━━━━━━━━━━━━━━━━━━━━━━━━
float bgLum   = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
bool  lightBg = bgLum > 128
color bgCol   = lightBg ? #FFFFFF : #131722
color txtCol  = lightBg ? #131722 : #E6E6E6
color dimCol  = color.new(txtCol, 40)
color headBg  = #1B2A41
color goodCol = #26A69A
color badCol  = #EF5350
color warnCol = #D97706
color warnBg  = #B45309

string tSize = switch sizeIn
    "Small" => size.small
    "Large" => size.large
    => size.normal

string tPos = switch posIn
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    "Bottom left"  => position.bottom_left
    => position.top_right

//━━━━━━━━━━━━━━━━━━━━━━━━ DRAWINGS + PANEL ━━━━━━━━━━━━━━━━━━━━━━━━
var box   bRisk   = na
var box   bReward = na
var line  lEntry  = na
var line  lStop   = na
var line  lTarget = na
var line  lAtr    = na
var label tEntry  = na
var label tStop   = na
var label tTarget = na
var array<line>  rLines  = array.new<line>()
var array<label> rLabels = array.new<label>()
var table panel = na

if barstate.islast
    box.delete(bRisk)
    box.delete(bReward)
    line.delete(lEntry)
    line.delete(lStop)
    line.delete(lTarget)
    line.delete(lAtr)
    label.delete(tEntry)
    label.delete(tStop)
    label.delete(tTarget)
    for ln in rLines
        line.delete(ln)
    rLines.clear()
    for lb in rLabels
        label.delete(lb)
    rLabels.clear()
    table.delete(panel)
    panel := table.new(tPos, 2, 28, bgcolor = bgCol, frame_color = color.new(txtCol, 70), frame_width = 1, border_color = color.new(txtCol, 88), border_width = 1)

    // ── Chart drawings (lines always visible once levels exist, zones only when valid) ──
    if levelsSet
        int tfMs   = timeframe.in_seconds() * 1000
        int rightT = math.max(entryTime + zoneBars * tfMs, time + 2 * tfMs)
        if valid
            bRisk   := box.new(entryTime, math.max(entryPrice, stopPrice), rightT, math.min(entryPrice, stopPrice), xloc = xloc.bar_time, bgcolor = cRisk, border_color = color.new(cRisk, 30), border_style = line.style_dashed, border_width = 1)
            bReward := box.new(entryTime, math.max(entryPrice, targetPrice), rightT, math.min(entryPrice, targetPrice), xloc = xloc.bar_time, bgcolor = cReward, border_color = color.new(cReward, 30), border_style = line.style_solid, border_width = 1)
        lEntry  := line.new(entryTime, entryPrice, rightT, entryPrice, xloc = xloc.bar_time, color = cEntry, width = 2)
        lStop   := line.new(entryTime, stopPrice, rightT, stopPrice, xloc = xloc.bar_time, color = badCol, width = 3, style = line.style_dashed)
        lTarget := line.new(entryTime, targetPrice, rightT, targetPrice, xloc = xloc.bar_time, color = goodCol, width = 2, style = line.style_solid)
        string stopLblTxt = "✕ " + S_STOP + "  " + fmtP(stopPrice) + (valid ? "  −" + fmtM(riskAcct, ccyLbl) : "")
        string tgtLblTxt  = "◎ " + S_TARGET + "  " + fmtP(targetPrice) + (valid ? "  R/R " + str.tostring(rr, "#.##") : "")
        tEntry  := label.new(rightT, entryPrice, "▶ " + S_ENTRY + "  " + fmtP(entryPrice), xloc = xloc.bar_time, style = label.style_label_left, color = cEntry, textcolor = color.white, size = size.small)
        tStop   := label.new(rightT, stopPrice, stopLblTxt, xloc = xloc.bar_time, style = label.style_label_left, color = badCol, textcolor = color.white, size = size.small)
        tTarget := label.new(rightT, targetPrice, tgtLblTxt, xloc = xloc.bar_time, style = label.style_label_left, color = goodCol, textcolor = color.white, size = size.small)
        if valid and isPro and showRLines
            for i = 1 to 3
                float lvl = isLong ? entryPrice + i * dist : entryPrice - i * dist
                rLines.push(line.new(entryTime, lvl, rightT, lvl, xloc = xloc.bar_time, color = color.new(txtCol, 65), style = line.style_dotted, width = 1))
                rLabels.push(label.new(rightT, lvl, str.tostring(i) + "R", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = dimCol, size = size.small))
        if valid and isPro and showAtrLn and not na(atrStop)
            lAtr := line.new(entryTime, atrStop, rightT, atrStop, xloc = xloc.bar_time, color = warnCol, width = 1, style = line.style_dotted)

    // ── Panel ──
    int r = 0
    r := wide(panel, r, "RISK & POSITION COACH", color.white, headBg, tSize, text.align_center)
    if not valid
        if levelsSet
            r := row(panel, r, "▶ " + S_ENTRY, fmtP(entryPrice), txtCol, txtCol, tSize)
            r := row(panel, r, "✕ " + S_STOP, fmtP(stopPrice), badCol, txtCol, tSize)
            r := row(panel, r, "◎ " + S_TARGET, fmtP(targetPrice), goodCol, txtCol, tSize)
        r := wide(panel, r, levelsSet ? S_INVALID : S_CLICK, color.white, warnBg, tSize, text.align_left)
        if levelsSet
            r := wide(panel, r, S_FIX, dimCol, na, size.small, text.align_left)
    else
        string sizeTxt = syminfo.type == "forex" ? fmtQ(qty / 100000.0) + " " + S_LOTS + " (" + fmtQ(qty) + " " + S_UNITS + ")" : syminfo.type == "crypto" and syminfo.basecurrency != "" ? fmtQ(qty) + " " + syminfo.basecurrency : fmtQ(qty) + " " + S_UNITS
        string stTxt   = state == 1 ? "◎ " + S_TGT_HIT : state == 2 ? "✕ " + S_STOP_HIT : state == 3 ? "◐ " + S_BOTH : "… " + S_WAIT
        color  stCol   = state == 1 ? goodCol : state == 2 ? badCol : state == 3 ? warnCol : txtCol
        r := row(panel, r, S_DIR, isLong ? S_LONG : S_SHORT, isLong ? goodCol : badCol, txtCol, tSize)
        r := row(panel, r, "▶ " + S_ENTRY, fmtP(entryPrice), txtCol, txtCol, tSize)
        r := row(panel, r, "✕ " + S_STOP, fmtP(stopPrice), badCol, txtCol, tSize)
        r := row(panel, r, "◎ " + S_TARGET, fmtP(targetPrice), goodCol, txtCol, tSize)
        r := row(panel, r, S_LOSS, fmtM(riskAcct, ccyLbl) + " (" + str.tostring(riskPct, "#.##") + "%)", badCol, txtCol, tSize)
        r := row(panel, r, S_SIZE, sizeTxt, txtCol, txtCol, tSize)
        r := row(panel, r, S_RR, "1 : " + str.tostring(rr, "#.##"), c1 ? goodCol : warnCol, txtCol, tSize)
        if isPro
            r := row(panel, r, S_NETRR, "1 : " + str.tostring(netRR, "#.##"), netRR >= minRR ? goodCol : warnCol, txtCol, tSize)
            r := row(panel, r, S_PROFIT, fmtM(netProfit / rate, ccyLbl), goodCol, txtCol, tSize)
            r := row(panel, r, S_VALUE, fmtM(notional / rate, ccyLbl), txtCol, txtCol, tSize)
            r := row(panel, r, S_LEV, lev > 1 ? str.tostring(lev, "#.#") + "x" : "—", lev > 10 ? badCol : txtCol, txtCol, tSize)
            r := row(panel, r, S_DIST, str.tostring(distPct, "#.##") + "% · " + str.tostring(distAtr, "#.#") + " ATR · " + stopClass, c3 ? txtCol : warnCol, txtCol, tSize)
            r := row(panel, r, S_VOL, volClass + " (" + str.tostring(volRatio, "#.##") + "×)", txtCol, txtCol, tSize)
            r := row(panel, r, S_ATRSTOP, fmtP(atrStop), warnCol, txtCol, tSize)
        r := row(panel, r, S_STATUS, stTxt, stCol, txtCol, tSize)
        if isPro
            r := wide(panel, r, "✔ " + S_CHECK + "  " + str.tostring(score) + "/5", color.white, headBg, tSize, text.align_center)
            r := row(panel, r, S_C1, c1 ? "✔" : "✘", c1 ? goodCol : badCol, txtCol, tSize)
            r := row(panel, r, S_C2, c2 ? "✔" : "✘", c2 ? goodCol : badCol, txtCol, tSize)
            r := row(panel, r, S_C3, c3 ? "✔" : "✘", c3 ? goodCol : badCol, txtCol, tSize)
            r := row(panel, r, S_C4, c4 ? "✔" : "✘", c4 ? goodCol : badCol, txtCol, tSize)
            r := row(panel, r, S_C5, c5 ? "✔" : "✘", c5 ? goodCol : badCol, txtCol, tSize)
        string warn = ""
        if riskPct > maxRisk
            warn += S_W_RISK + "\n"
        if rr < 1
            warn += S_W_RR + "\n"
        if fxFail
            warn += S_W_FX + "\n"
        warn := str.trim(warn)
        if str.length(warn) > 0
            r := wide(panel, r, warn, color.white, warnBg, tSize, text.align_left)
        if not isPro
            r := wide(panel, r, S_TIP, dimCol, na, size.small, text.align_left)
    r := wide(panel, r, S_EDU, dimCol, na, size.tiny, text.align_center)

//━━━━━━━━━━━━━━━━━━━━━━━━ OUTPUTS + ALERTS ━━━━━━━━━━━━━━━━━━━━━━━━
plot(atrVal, "ATR", display = display.data_window)

alertcondition(state == 1 and prevState == 0, "Target reached", "Risk Coach: target reached on {{ticker}}")
alertcondition(state == 2 and prevState == 0, "Stop hit", "Risk Coach: stop hit on {{ticker}}")

if state != prevState and state > 0
    alert(syminfo.ticker + " · " + (state == 1 ? S_TGT_HIT : state == 2 ? S_STOP_HIT : S_BOTH), alert.freq_once_per_bar)
````
