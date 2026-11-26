# ARFZTRK_5-8-13_SP500_BIST100_TARAMA

- url: https://www.tradingview.com/script/8j4uL1ie/
- type: indicator
- pine_id: PUB;cdf8932787004470995c495de0cc6dd1
- version: 1.0

## Description

🇹🇷 TÜRKÇE YAYIN METNİ
Başlık: ARFZTRK 5-8-13 Sıkışma ve Hacimli Patlama Tarayıcısı (Pro Scanner)

Açıklama:
Bu gelişmiş tarama motoru (Scanner), piyasadaki yüzlerce hisse arasından "yay gibi gerilmiş" ve patlamaya hazır olanları saniyeler içinde bulmak için tasarlanmış saf bir Price Action aracıdır.

Sistem; grafik üzerinde gereksiz çizgiler veya karmaşık hesaplamalarla göz yormaz. Yalnızca tek bir kusursuz senaryoya odaklanır: Volatilite daralması (Baskı) ve ardından gelen Kurumsal Hacimli Kırılım.

🎯 Tarama Kriterleri (Sistemin Mantığı):

Baskı (Squeeze): Fiyatın, sizin belirlediğiniz gün sayısı boyunca (örn: 2 gün) 5, 8 ve 13 periyotluk Hareketli Ortalamaların (MA) tamamen altında ezilmiş olmasını şart koşar. Enerji toplama evresidir.

Kırılım (Breakout): Fiyatın aniden bu 3 ortalamanın (5-8-13) tamamının üzerine çıkarak kapanış yapmasını arar.

Gerçek Hacim (RVOL): Bu kırılımın sahte (bull trap) olmaması için, kırılım mumundaki hacmin son 20 günlük ortalama hacmin belirlediğiniz çarpan (örn: 1.2x) üzerinde olmasını zorunlu kılar.

🔥 Eşsiz Teknik Mimari (Sıfır Uyarı - Sıfır Hata):
Pine Script'te request.security fonksiyonu döngüler (for) içinde kullanıldığında genellikle hesaplama hataları veya meşhur "Scope" uyarılarını verir. ARFZTRK Tarama Motoru, bu limiti aşmak için "Global Scope Unrolling" (Şartsız Küresel Çağrı) mimarisiyle özel olarak kodlanmıştır. Bu sayede hiçbir Pine Script uyarısı vermeden, seçilen gruptaki 30 hisseyi eksiksiz, hatasız ve anında tarar.

Nasıl Kullanılır?

Ayarlardan ABD Majör, ABD Hype veya BIST 100 gruplarından birini seçin.

İsterseniz "Yedekler" kısmına kendi favori sembollerinizi (virgülle ayırarak) ekleyin.

Tarama Periyodunu (1G, 4S, 1S) stratejinize göre belirleyin ve ekranın köşesindeki dinamik antrasit tabloda beliren patlamaya hazır hisseleri yakalayın!

🇬🇧 İNGİLİZCE YAYIN METNİ (ENGLISH)
Title: ARFZTRK 5-8-13 Volatility Squeeze & Volume Breakout Scanner

Description:
This advanced screening engine (Scanner) is a pure Price Action tool designed to instantly identify assets that have been "coiled like a spring" and are breaking out with massive momentum.

The system doesn't clutter your chart with lines or complex noise. It focuses purely on one perfect setup: Volatility Contraction (The Squeeze) followed by an Institutional Volume Breakout.

🎯 Scanning Criteria (The Engine Logic):

The Squeeze: It requires the price to be completely suppressed below the 5, 8, and 13-period Moving Averages (MAs) for a user-defined minimum number of consecutive days. This identifies the energy accumulation phase.

The Breakout: It searches for the exact moment the price violently closes above all three MAs (5-8-13) simultaneously.

Relative Volume (RVOL): To avoid fake-outs (bull traps), the breakout candle's volume must be significantly higher than the 20-period average volume by a customizable multiplier (e.g., 1.2x).

🔥 Unique Technical Architecture (Zero Warnings):
In Pine Script, using request.security inside for loops often triggers history referencing warnings and causes scanners to drop symbols. The ARFZTRK Scanner bypasses this limitation by utilizing a custom "Global Scope Unrolling" architecture. This ensures 100% reliable, warning-free, and lightning-fast scanning of up to 30 symbols per group simultaneously.

How to Use:

Select one of the pre-defined groups (US Majors, US Hype, or BIST 100) from the settings.

Alternatively, paste your own custom ticker lists into the "Reserves" text areas.

Choose your scanning timeframe (1D, 4H, 1H) and watch the dynamic, clean anthracite dashboard highlight the tickers that are ready to explode!

## Source Code

````pine
//@version=6
indicator("ARFZTRK_5-8-13_SP500_BIST100_TARAMA", overlay = true)

// ==========================================
// 1. BÖLÜM: GÖRÜNÜM VE AYARLAR
// ==========================================
grp_ana = "1. TARAMA (SCANNER) SİSTEMİ"

// [YENİ] ZAMAN DİLİMİ SEÇİMİ (EN ÜSTTE)
tarama_periyot = input.timeframe("D", "⏰ Tarama Periyodu", group=grp_ana)

grup_no = input.int(1, "👉 Taranacak Grup No (1-30)", minval=1, maxval=30, group=grp_ana)
pos_val = input.string(position.bottom_right, "Scanner Konumu", options=[position.top_right, position.bottom_right, position.top_left, position.bottom_left], group=grp_ana)

// TASARIM: Antrasit Zemin, Siyah Yazı
col_bg  = input.color(color.blue, "Tablo Arka Planı", group="GÖRÜNÜM")
col_txt = input.color(color.white, "Yazı Rengi", group="GÖRÜNÜM")

// ==========================================
// [EKLENEN BÖLÜM]: STRATEJİ AYARLARI VE FONKSİYONU
// ==========================================
grp_str = "2. STRATEJİ AYARLARI"
maTipi    = input.string("EMA", title="MA Tipi", options=["SMA", "EMA"], group=grp_str)
hacimCarp = input.float(1.2, title="Hacim Çarpanı", step=0.1, group=grp_str)
hacimPer  = input.int(20, title="Hacim Ortalama Periyodu", group=grp_str)
baskiGun  = input.int(2, title="Min Baskı Günü", minval=1, maxval=10, group=grp_str)

// Fiyatın sıkışmasını ve hacimli patlamasını hesaplayan kapalı fonksiyon
f_taramaSarti() =>
    ma5  = maTipi == "EMA" ? ta.ema(close, 5)  : ta.sma(close, 5)
    ma8  = maTipi == "EMA" ? ta.ema(close, 8)  : ta.sma(close, 8)
    ma13 = maTipi == "EMA" ? ta.ema(close, 13) : ta.sma(close, 13)

    ortHacim    = ta.sma(volume, hacimPer)
    yuksekHacim = volume > (ortHacim * hacimCarp)

    durumAltinda = close < ma5 and close < ma8 and close < ma13
    gecmisBaski  = ta.barssince(not durumAltinda)[1] >= baskiGun
    ustundeKapanis = close > ma5 and close > ma8 and close > ma13

    gecmisBaski and ustundeKapanis and yuksekHacim

// ==========================================
// 2. BÖLÜM: VERİ HAVUZU (30 GRUP)
// ==========================================
// Grup 1-16: ABD Devleri
g1 = input.text_area("A, AA, AAL, AAPL, ABBV, ABNB, ABT, ACN, ADBE, ADI, ADM, ADP, ADSK, AEE, AEP, AES, AFL, AIG, AIZ, AJG, AKAM, ALB, ALGN, ALK, ALL, ALLE, AMAT, AMCR, AMD, AME", "Grup 1", group="ABD MAJOR")
g2 = input.text_area("AMGN, AMP, AMT, AMZN, ANET, ANSS, AON, AOS, APA, APD, APH, APTV, ARE, ATO, AVB, AVGO, AVY, AWK, AXP, AZO, BA, BAC, BALL, BAX, BBWI, BBY, BDX, BEN, BF.B, BG", "Grup 2", group="ABD MAJOR")
g3 = input.text_area("BIIB, BIO, BK, BKNG, BKR, BLK, BMN, BMY, BR, BRK.B, BRO, BSX, BWA, BXP, C, CAG, CAH, CARR, CAT, CB, CBOE, CBRE, CCI, CCL, CDNS, CDW, CE, CEG, CF, CFG", "Grup 3", group="ABD MAJOR")
g4 = input.text_area("CHD, CHRW, CHTR, CI, CINF, CL, CLX, CMA, CMCSA, CME, CMG, CMI, CMS, CNC, CNP, COF, COO, COP, COST, CPB, CPRT, CPT, CRL, CRM, CSCO, CSGP, CSX, CTAS, CTRA, CTSH", "Grup 4", group="ABD MAJOR")
g5 = input.text_area("CTVA, CVS, CVX, CZR, D, DAL, DD, DE, DFS, DG, DGX, DHI, DHR, DIS, DLR, DLTR, DOV, DOW, DPZ, DRI, DTE, DUK, DVA, DVN, DXCM, EA, EBAY, ECL, ED, EFX", "Grup 5", group="ABD MAJOR")
g6 = input.text_area("EIX, EL, ELV, EMN, EMR, ENPH, EOG, EPAM, EQIX, EQR, ES, ESS, ETN, ETR, ETSY, EVRG, EW, EXC, EXPD, EXPE, EXR, F, FANG, FAST, FCX, FDS, FDX, FE, FFIV, FIS", "Grup 6", group="ABD MAJOR")
g7 = input.text_area("FITB, FLT, FMC, FOX, FOXA, FRT, FSLR, FTNT, FTV, GD, GE, GEHC, GEN, GILD, GIS, GL, GLW, GM, GNRC, GOOG, GOOGL, GPC, GPN, GRMN, GS, GWW, HAL, HAS, HBAN, HCA", "Grup 7", group="ABD MAJOR")
g8 = input.text_area("HD, HES, HIG, HII, HLT, HOLX, HON, HPE, HPQ, HRL, HSIC, HST, HSY, HUM, HWM, IBM, ICE, IDXX, IEX, IFF, ILMN, INCY, INTC, INTU, INVH, IP, IPG, IQV, IR, IRM", "Grup 8", group="ABD MAJOR")
g9 = input.text_area("ISRG, IT, ITW, IVZ, J, JBHT, JCI, JKHY, JNJ, JNPR, JPM, K, KDP, KEY, KEYS, KHC, KIM, KLAC, KMB, KMI, KMX, KO, KR, L, LDOS, LEN, LH, LHX, LIN, LKQ", "Grup 9", group="ABD MAJOR")
g10 = input.text_area("LLY, LMT, LNC, LNT, LOW, LRCX, LULU, LUV, LVS, LYB, LYV, MA, MAA, MAR, MAS, MCD, MCHP, MCK, MCO, MDLZ, MDT, MET, META, MGM, MHK, MKC, MKTX, MMC, MMM, MNST", "Grup 10", group="ABD MAJOR")
g11 = input.text_area("MO, MOH, MOS, MPC, MPWR, MRK, MRNA, MRO, MS, MSCI, MSFT, MSI, MTB, MTCH, MTD, MU, NCLH, NDAQ, NDSN, NEE, NEM, NFLX, NI, NKE, NOC, NOW, NRG, NSC, NTAP, NTRS", "Grup 11", group="ABD MAJOR")
g12 = input.text_area("NUE, NVDA, NVR, NWL, NWS, NWSA, NXPI, O, ODFL, OGN, OKE, OMC, ON, ORCL, ORLY, OTIS, OXY, PANW, PARA, PAYC, PAYX, PCAR, PCG, PEAK, PEG, PEP, PFE, PFG, PG, PGR", "Grup 12", group="ABD MAJOR")
g13 = input.text_area("PH, PHM, PKG, PLD, PM, PNC, PNR, PNW, POOL, PPG, PPL, PRU, PSA, PSX, PTC, PWR, PXD, PYPL, QCOM, QRVO, RCL, RE, REG, REGN, RF, RHI, RJF, RL, RMD, ROK", "Grup 13", group="ABD MAJOR")
g14 = input.text_area("ROL, ROP, ROST, RSG, RTX, SBAC, SBUX, SCHW, SEDG, SEE, SHW, SJM, SLB, SNA, SNPS, SO, SPG, SPGI, SRE, STE, STLD, STT, STX, STZ, SWK, SWKS, SYF, SYK, SYY, T", "Grup 14", group="ABD MAJOR")
g15 = input.text_area("TAP, TDG, TDY, TECH, TEL, TER, TFC, TFX, TGT, TJX, TMO, TMUS, TPR, TRGP, TRMB, TROW, TRV, TSCO, TSLA, TSN, TT, TTWO, TXN, TXT, TYL, UAL, UDR, UHS, ULTA, UNH", "Grup 15", group="ABD MAJOR")
g16 = input.text_area("UNP, UPS, URI, USB, V, VFC, VICI, VLO, VMC, VNO, VRSK, VRSN, VRTX, VTR, VTRS, VZ, WAB, WAT, WBA, WBD, WDC, WEC, WELL, WFC, WHR, WM, WMB, WMT, WRB, XOM", "Grup 16", group="ABD MAJOR")

// Grup 17-19: Hype/Popüler
g17 = input.text_area("ACHR, AGRI, AI, ALCC, AMC, ANY, BB, BBAI, BITF, BKKT, BTBT, CENN, CIFR, CLOV, CLSK, COIN, CORZ, CVNA, DKNG, FFIE, FUBO, GME, GOEV, HIVE, HOOD, HUT, IONQ, IREN, JOBY, KOSS", "Grup 17", group="ABD HYPE")
g18 = input.text_area("LCID, MARA, MGI, MIGI, MSTR, MULN, NKLA, NIO, NOK, OPEN, PATH, PLUG, PSNY, QS, RDDT, RGTI, RIOT, RIVN, ROKU, SAVA, SDIG, SI, SKLZ, SOFI, SOUN, SPCE, SQ, TMF, TS, U", "Grup 18", group="ABD HYPE")
g19 = input.text_area("UPST, VIR, VORB, WISH, WKHS, WOLF, WULF, XPEV, ZM, ZS, AFRM, APPS, ASTS, BYND, CHPT, CRSR, DATS, FSR, GREE, HYMC, LIDR, MVIS, NVTS, OCGN, PROG, RIDE, SDC, SNDL, TLRY, VUZI", "Grup 19", group="ABD HYPE")

// Grup 20-23: BIST 100
g20 = input.text_area("BIST:AEFES, BIST:AGHOL, BIST:AHGAZ, BIST:AKBNK, BIST:AKCNS, BIST:AKFGY, BIST:AKSA, BIST:AKSEN, BIST:ALARK, BIST:ALBRK, BIST:ALFAS, BIST:ARCLK, BIST:ASELS, BIST:ASTOR, BIST:ASUZU, BIST:AYDEM, BIST:BAGFS, BIST:BERA, BIST:BIMAS, BIST:BIOEN, BIST:BRSAN, BIST:BRYAT, BIST:BUCIM, BIST:CANTE, BIST:CCOLA, BIST:CEMTS, BIST:CIMSA, BIST:CWENE, BIST:DOAS, BIST:DOHOL", "Grup 20", group="BIST 100")
g21 = input.text_area("BIST:ECILC, BIST:ECZYT, BIST:EGEEN, BIST:EKGYO, BIST:ENJSA, BIST:ENKAI, BIST:ERBOS, BIST:EREGL, BIST:EUREN, BIST:EUPWR, BIST:FROTO, BIST:GARAN, BIST:GENIL, BIST:GESAN, BIST:GLYHO, BIST:GSDHO, BIST:GUBRF, BIST:GWIND, BIST:HALKB, BIST:HEKTS, BIST:IMASM, BIST:IPEKE, BIST:ISCTR, BIST:ISDMR, BIST:ISGYO, BIST:ISMEN, BIST:IZMDC, BIST:KAREL, BIST:KARSN, BIST:KCAER", "Grup 21", group="BIST 100")
g22 = input.text_area("BIST:KCHOL, BIST:KMPUR, BIST:KONTR, BIST:KONYA, BIST:KORDS, BIST:KOZAA, BIST:KOZAL, BIST:KRDMD, BIST:KZBGY, BIST:MAVI, BIST:MGROS, BIST:MIATK, BIST:ODAS, BIST:OTKAR, BIST:OYAKC, BIST:PENTA, BIST:PETKM, BIST:PGSUS, BIST:PSGYO, BIST:QUAGR, BIST:SAHOL, BIST:SASA, BIST:SELEC, BIST:SISE, BIST:SKBNK, BIST:SMRTG, BIST:SNGYO, BIST:SOKM, BIST:TAVHL, BIST:TCELL", "Grup 22", group="BIST 100")
g23 = input.text_area("BIST:THYAO, BIST:TKFEN, BIST:TOASO, BIST:TSKB, BIST:TTKOM, BIST:TTRAK, BIST:TUKAS, BIST:TUPRS, BIST:TURSG, BIST:ULKER, BIST:VAKBN, BIST:VESBE, BIST:VESTL, BIST:YKBNK, BIST:YYLGD, BIST:ZOREN, BIST:SDTTR, BIST:ONCSM, BIST:KLSER, BIST:FORTE, BIST:KOPOL, BIST:CVKMD, BIST:EBEBK, BIST:ADGYO, BIST:DMRGD, BIST:HATSN, BIST:MEGMT, BIST:MHRGY, BIST:BORLS, BIST:VRGYO", "Grup 23", group="BIST 100")

// Grup 24-30: Yedekler (Boş)
g24 = input.text_area("", "Grup 24", group="YEDEKLER")
g25 = input.text_area("", "Grup 25", group="YEDEKLER")
g26 = input.text_area("", "Grup 26", group="YEDEKLER")
g27 = input.text_area("", "Grup 27", group="YEDEKLER")
g28 = input.text_area("", "Grup 28", group="YEDEKLER")
g29 = input.text_area("", "Grup 29", group="YEDEKLER")
g30 = input.text_area("", "Grup 30", group="YEDEKLER")

// ==========================================
// 3. BÖLÜM: TARAMA MOTORU (HAZIRLIK)
// ==========================================
string aktif_grup_metni = switch grup_no
    1 => g1
    2 => g2
    3 => g3
    4 => g4
    5 => g5
    6 => g6
    7 => g7
    8 => g8
    9 => g9
    10 => g10
    11 => g11
    12 => g12
    13 => g13
    14 => g14
    15 => g15
    16 => g16
    17 => g17
    18 => g18
    19 => g19
    20 => g20
    21 => g21
    22 => g22
    23 => g23
    24 => g24
    25 => g25
    26 => g26
    27 => g27
    28 => g28
    29 => g29
    30 => g30
    => ""

array<string> sembol_listesi = str.split(aktif_grup_metni, ",")
array<string> sonuc_listesi  = array.new_string() 

// ==========================================
// KÖKTEN ÇÖZÜM: GLOBAL SCOPE (DÖNGÜSÜZ) TARAMA
// ==========================================
// Pine Script'in "for" döngüsü uyarısını (Scope Hatası) SIFIRLAMAK ve 
// hesaplamaları kusursuzlaştırmak için döngü iptal edildi. 
// Gruptaki maks 30 hisse Global Alanda (şartsız) tek tek taranıyor.

f_get_sym(array<string> arr, int i) => 
    array.size(arr) > i ? str.replace_all(str.replace_all(array.get(arr, i), " ", ""), "\n", "") : ""

string s00 = f_get_sym(sembol_listesi, 0)
string s01 = f_get_sym(sembol_listesi, 1)
string s02 = f_get_sym(sembol_listesi, 2)
string s03 = f_get_sym(sembol_listesi, 3)
string s04 = f_get_sym(sembol_listesi, 4)
string s05 = f_get_sym(sembol_listesi, 5)
string s06 = f_get_sym(sembol_listesi, 6)
string s07 = f_get_sym(sembol_listesi, 7)
string s08 = f_get_sym(sembol_listesi, 8)
string s09 = f_get_sym(sembol_listesi, 9)
string s10 = f_get_sym(sembol_listesi, 10)
string s11 = f_get_sym(sembol_listesi, 11)
string s12 = f_get_sym(sembol_listesi, 12)
string s13 = f_get_sym(sembol_listesi, 13)
string s14 = f_get_sym(sembol_listesi, 14)
string s15 = f_get_sym(sembol_listesi, 15)
string s16 = f_get_sym(sembol_listesi, 16)
string s17 = f_get_sym(sembol_listesi, 17)
string s18 = f_get_sym(sembol_listesi, 18)
string s19 = f_get_sym(sembol_listesi, 19)
string s20 = f_get_sym(sembol_listesi, 20)
string s21 = f_get_sym(sembol_listesi, 21)
string s22 = f_get_sym(sembol_listesi, 22)
string s23 = f_get_sym(sembol_listesi, 23)
string s24 = f_get_sym(sembol_listesi, 24)
string s25 = f_get_sym(sembol_listesi, 25)
string s26 = f_get_sym(sembol_listesi, 26)
string s27 = f_get_sym(sembol_listesi, 27)
string s28 = f_get_sym(sembol_listesi, 28)
string s29 = f_get_sym(sembol_listesi, 29)

// ignore_invalid_symbol=true sayesinde bozuk semboller sistemi çökertmez
bool r00 = request.security(s00 == "" ? syminfo.tickerid : s00, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r01 = request.security(s01 == "" ? syminfo.tickerid : s01, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r02 = request.security(s02 == "" ? syminfo.tickerid : s02, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r03 = request.security(s03 == "" ? syminfo.tickerid : s03, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r04 = request.security(s04 == "" ? syminfo.tickerid : s04, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r05 = request.security(s05 == "" ? syminfo.tickerid : s05, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r06 = request.security(s06 == "" ? syminfo.tickerid : s06, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r07 = request.security(s07 == "" ? syminfo.tickerid : s07, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r08 = request.security(s08 == "" ? syminfo.tickerid : s08, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r09 = request.security(s09 == "" ? syminfo.tickerid : s09, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r10 = request.security(s10 == "" ? syminfo.tickerid : s10, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r11 = request.security(s11 == "" ? syminfo.tickerid : s11, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r12 = request.security(s12 == "" ? syminfo.tickerid : s12, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r13 = request.security(s13 == "" ? syminfo.tickerid : s13, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r14 = request.security(s14 == "" ? syminfo.tickerid : s14, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r15 = request.security(s15 == "" ? syminfo.tickerid : s15, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r16 = request.security(s16 == "" ? syminfo.tickerid : s16, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r17 = request.security(s17 == "" ? syminfo.tickerid : s17, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r18 = request.security(s18 == "" ? syminfo.tickerid : s18, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r19 = request.security(s19 == "" ? syminfo.tickerid : s19, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r20 = request.security(s20 == "" ? syminfo.tickerid : s20, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r21 = request.security(s21 == "" ? syminfo.tickerid : s21, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r22 = request.security(s22 == "" ? syminfo.tickerid : s22, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r23 = request.security(s23 == "" ? syminfo.tickerid : s23, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r24 = request.security(s24 == "" ? syminfo.tickerid : s24, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r25 = request.security(s25 == "" ? syminfo.tickerid : s25, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r26 = request.security(s26 == "" ? syminfo.tickerid : s26, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r27 = request.security(s27 == "" ? syminfo.tickerid : s27, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r28 = request.security(s28 == "" ? syminfo.tickerid : s28, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)
bool r29 = request.security(s29 == "" ? syminfo.tickerid : s29, tarama_periyot, f_taramaSarti(), ignore_invalid_symbol=true)

// Şartları sağlayanları (ve boş olmayanları) tablo listesine ekle
if s00 != "" and r00
    array.push(sonuc_listesi, s00)
if s01 != "" and r01
    array.push(sonuc_listesi, s01)
if s02 != "" and r02
    array.push(sonuc_listesi, s02)
if s03 != "" and r03
    array.push(sonuc_listesi, s03)
if s04 != "" and r04
    array.push(sonuc_listesi, s04)
if s05 != "" and r05
    array.push(sonuc_listesi, s05)
if s06 != "" and r06
    array.push(sonuc_listesi, s06)
if s07 != "" and r07
    array.push(sonuc_listesi, s07)
if s08 != "" and r08
    array.push(sonuc_listesi, s08)
if s09 != "" and r09
    array.push(sonuc_listesi, s09)
if s10 != "" and r10
    array.push(sonuc_listesi, s10)
if s11 != "" and r11
    array.push(sonuc_listesi, s11)
if s12 != "" and r12
    array.push(sonuc_listesi, s12)
if s13 != "" and r13
    array.push(sonuc_listesi, s13)
if s14 != "" and r14
    array.push(sonuc_listesi, s14)
if s15 != "" and r15
    array.push(sonuc_listesi, s15)
if s16 != "" and r16
    array.push(sonuc_listesi, s16)
if s17 != "" and r17
    array.push(sonuc_listesi, s17)
if s18 != "" and r18
    array.push(sonuc_listesi, s18)
if s19 != "" and r19
    array.push(sonuc_listesi, s19)
if s20 != "" and r20
    array.push(sonuc_listesi, s20)
if s21 != "" and r21
    array.push(sonuc_listesi, s21)
if s22 != "" and r22
    array.push(sonuc_listesi, s22)
if s23 != "" and r23
    array.push(sonuc_listesi, s23)
if s24 != "" and r24
    array.push(sonuc_listesi, s24)
if s25 != "" and r25
    array.push(sonuc_listesi, s25)
if s26 != "" and r26
    array.push(sonuc_listesi, s26)
if s27 != "" and r27
    array.push(sonuc_listesi, s27)
if s28 != "" and r28
    array.push(sonuc_listesi, s28)
if s29 != "" and r29
    array.push(sonuc_listesi, s29)

// ==========================================
// 4. BÖLÜM: DİNAMİK TABLO ÇİZİMİ
// ==========================================
var table scanner_table = table.new(pos_val, 1, 31, border_width=0) 

if barstate.islast
    // Sadece Başlık (Her zaman görünür)
    table.cell(scanner_table, 0, 0, "GRUP : " + str.tostring(grup_no), bgcolor=col_bg, text_color=col_txt, text_size=size.normal)
    
    // Sonuçları Yazdır (Varsa)
    int sonuc_sayisi = array.size(sonuc_listesi)
    
    if sonuc_sayisi > 0
        for i = 0 to math.min(sonuc_sayisi - 1, 29)
            string s = array.get(sonuc_listesi, i)
            table.cell(scanner_table, 0, i + 1, s, bgcolor=col_bg, text_color=col_txt, text_size=size.small)
    else
        // Temizlik
        for j = 1 to 30
            table.cell(scanner_table, 0, j, "", bgcolor=color.new(color.white, 100))
````
