# Sector Tag (ETF Mapper)

- url: https://www.tradingview.com/script/W0JMbUqM-Sector-Tag-ETF-Mapper/
- type: indicator
- pine_id: PUB;862d941cf928409eabe9fb8a0278200e
- version: 3.0

## Description

The Sector Tag (ETF Mapper) is a TradingView utility designed to instantly identify the most relevant sector ETF for a stock. The indicator displays the corresponding sector directly on the chart, helping traders evaluate sector alignment, market context, and relative strength opportunities.

Coverage

The current database contains approximately 1,300+ US-listed stocks, including:

S&P 500 constituents
Nasdaq 100 constituents
Russell 2000 constituents
Additional actively traded swing and day trading stocks
High-volume growth, momentum, and earnings candidates

The ticker database is manually curated and can be expanded at any time.

Sector Classification

Stocks are mapped to the following ETFs:

XLK – Technology
XLF – Financials
XLV – Health Care
XLY – Consumer Discretionary
XLP – Consumer Staples
XLI – Industrials
XLE – Energy
XLU – Utilities
XLB – Materials
XLC – Communication Services
XLRE – Real Estate

For selected small-cap stocks where a sector classification adds limited value, an IWM (Russell 2000) designation may be used instead.

Why Use It for Day Trading?

Sector participation is often a major driver of intraday performance.

Examples:

A stock gapping up while its sector ETF is also strong has a higher probability of follow-through.
Multiple stocks from the same sector moving together can indicate institutional sector rotation.
Gap scanners frequently produce stocks from leading sectors. Knowing the sector immediately provides valuable context.

The indicator helps traders quickly answer:

Is this stock moving with its sector?
Is the sector leading or lagging the market?
Are multiple opportunities coming from the same industry group?
Why Use It for Swing Trading?

Swing traders often focus on stocks that are aligned with:

Sector strength
Market direction
Institutional money flow

A bullish setup in a strong sector generally has a higher probability than the same setup in a weak sector.

The Sector Tag allows traders to:

Compare stocks against their sector ETF
Monitor sector rotation
Build watchlists around leading sectors
Avoid concentration risk by unintentionally taking multiple positions within the same sector
Typical Workflow
Gap Scanner
Run a pre-market gap scan.
Open the stock chart.
Instantly see the sector ETF.
Compare the stock to its sector ETF.
Prioritize stocks showing both stock-specific and sector-wide strength.
Swing Trading
Identify technical setups.
Check sector alignment.
Favor setups in sectors already showing momentum.
Reduce exposure to sectors showing relative weakness.
Performance and Design

The indicator uses a compressed sector-mapping architecture optimized for TradingView Pine Script limitations.

Benefits:

Fast execution
Low resource usage
Large ticker coverage
Easy future expansion
No external data dependencies
Future Expansion

The ticker database is designed to be continuously updated.

Additional stocks, sectors, industry groups, or custom ETF mappings can be added without changing the core functionality of the indicator.

The goal is to provide a lightweight but highly practical tool that adds immediate market context to every chart.

## Source Code

````pine
//@version=6
indicator("Sector / Industry Tagger (ETF Mapper) – Trading V2", overlay=true)

f_sector_name(etf) =>
    switch etf
        "SMH" => "Semiconductors"
        "XBI" => "Biotech"
        "KRE" => "Regional Banks"
        "TAN" => "Solar"
        "XME" => "Metals & Mining"
        "XLK" => "Technology"
        "XLF" => "Financials"
        "XLV" => "Health Care"
        "XLY" => "Consumer Discretionary"
        "XLI" => "Industrials"
        "XLE" => "Energy"
        "XLP" => "Consumer Staples"
        "XLU" => "Utilities"
        "XLB" => "Materials"
        "XLC" => "Communication"
        "XLRE" => "Real Estate"
        "IWM" => "Russell 2000 / Small Cap"
        "ICLN" => "Clean Energy"
        => "Unknown"

f_bg(etf) =>
    switch etf
        "SMH" => color.new(color.aqua, 80)
        "XBI" => color.new(color.green, 80)
        "KRE" => color.new(color.blue, 82)
        "TAN" => color.new(color.orange, 82)
        "XME" => color.new(color.red, 86)
        "XLK" => color.new(color.aqua, 85)
        "XLF" => color.new(color.blue, 87)
        "XLV" => color.new(color.green, 87)
        "XLY" => color.new(color.fuchsia, 88)
        "XLI" => color.new(color.purple, 88)
        "XLE" => color.new(color.orange, 85)
        "XLP" => color.new(color.lime, 87)
        "XLU" => color.new(color.yellow, 82)
        "XLB" => color.new(color.red, 90)
        "XLC" => color.new(color.teal, 88)
        "XLRE" => color.new(color.silver, 82)
        "IWM" => color.new(color.gray, 82)
        "ICLN" => color.new(color.green, 82)
        "UNKNOWN" => color.new(color.gray, 80)
        => color.new(color.gray, 80)

f_has(list, t) =>
    str.contains("," + list + ",", "," + t + ",")

f_is_SMH(t) =>
    f_has("ACLS,ACMR,ADI,AEHR,AEIS,ALGM,AMAT,AMBA,AMD,AMKR,AOSL,ARM,ASML,AVGO,AVT,CDNS,COHR,COHU,CRDO,CRWV,DIOD,ENTG,FLEX,FORM,GFS,ICHR,INTC,IPGP,JBL,KLAC,LITE,LRCX,LSCC,MCHP,MKSI,MRVL,MTSI,MU,MXL,NVDA,NXPI,ON,POWI,QCOM,QRVO,RMBS,SANM,SMCI,SMTC,SNDK,SNPS,STX,SWKS,TER,TSM,TTMI,TXN,VECO,VIAV,VSH,WDC", t)

f_is_XBI(t) =>
    f_has("ACAD,ADPT,AGIO,ALKS,ALMS,ALMU,ALNY,AMLX,ARQT,ARWR,AUPH,AXSM,BBIO,BEAM,BMRN,CAPR,CELC,CGEM,CGON,COGT,CORT,CPRX,CRNX,CRSP,CRVS,CYTK,DNLI,DYN,ERAS,EWTX,EYPT,HALO,IDYA,IMNM,IMVT,INCY,INSM,IONS,JAZZ,KALV,LQDA,MIRM,MLYS,MRX,NAVN,NBIX,NRIX,NTLA,OLMA,OMER,ORKA,PCVX,PHAT,PTCT,QDEL,RARE,RCUS,RLAY,RNA,ROIV,RVMD,RYTM,SMMT,SRPT,SRRK,SUPN,TARS,TGTX,TNGX,TVTX,TWST,VERA,VKTX,VRDN,XENE,XNCR,ZVRA", t)

f_is_KRE(t) =>
    f_has("ASB,AUB,BANC,CBSH,COLB,CVBF,FBP,FHB,FHN,FIBK,FITB,FULT,GBCI,HBAN,HOMB,HOPE,HTFL,NWBI,ONB,OZK,PFSI,PNFP,RF,SFNC,UBSI,WAL", t)

f_is_TAN(t) =>
    f_has("ENPH,FLNC,FSLR,NXT,RUN,SEDG,SHLS", t)

f_is_XME(t) =>
    f_has("AA,AU,CMC,CRH,FCX,HL,MP,NEM,PPTA,RGLD,SCCO", t)

f_is_XLK(t) =>
    f_has("AAOI,AAON,AAPL,ACIW,ADBE,ADEA,ADP,ADSK,ADTN,AEVA,AFRM,AI,AIP,AKAM,ALAB,ALKT,AMBQ,AMSC,ANET,ANSS,APG,APH,APLD,APP,APPN,ARLO,ARW,ASAN,ATEN,AXON,BAND,BILL,BL,BOX,BR,BRZE,BSY,CDW,CEVA,CGNX,CIEN,CNXC,CRM,CRWD,CSCO,CSGP,CTSH,CWAN,DASH,DBX,DDOG,DELL,DLB,DOCN,DOCS,DOCU,DOX,DT,DUOL,EBAY,EPAM,ESTC,EXLS,EXTR,FFIV,FICO,FIS,FIVN,FN,FSLY,FTNT,FTV,FVRR,GDDY,GDS,GEN,GLOB,GLW,GOOG,GOOGL,GPN,GRMN,GTLB,GWRE,HLIT,HPE,HPQ,HUBG,HUBS,IBM,INOD,INTA,INTU,IOT,IRDM,IREN,IT,KEYS,KLIC,KN,LASR,LIF,LUMN,MDB,META,MITK,MSFT,NCNO,NET,NFLX,NOW,NSIT,NTAP,NTNX,NVTS,OKTA,OLED,OMDA,ONTO,OPLN,ORCL,PANW,PATH,PAYC,PCOR,PCTY,PDFS,PEG,PEGA,PENG,PLTR,PSKY,PTC,QLYS,QNST,QTWO,RBRK,RELY,RGTI,RNG,ROKU,ROP,S,SAIL,SATS,SDGR,SHOP,SKYT,SNDX,SNOW,SSNC,ST,SYNA,TEAM,TEL,TENB,TRMB,TSSI,TTD,TWLO,TYL,U,UCTT,VERX,VGNT,VICR,VISN,VLTO,VRNS,VRSN,VRT,WAY,WDAY,WK,WLTH,XMTR,Z,ZBRA,ZETA,ZG,ZM,ZS", t)

f_is_XLF(t) =>
    f_has("ACGL,AFG,AFL,AIG,AIZ,AJG,ALL,ALLY,AMP,AON,APO,ARES,AXP,BAC,BAM,BEN,BGC,BK,BLK,BLSH,BNY,BRK.B,BRO,BRSL,BWIN,BX,C,CB,CBOE,CFG,CG,CINF,CMA,CME,CNO,CODI,COF,COIN,CPAY,CRBG,CRCL,EBC,EFX,EG,EQH,EVER,EVTC,EWBC,FDS,FG,FIGR,FISV,FLG,FLY,FLYW,FNB,FNF,FOUR,GL,GS,HIG,HLI,HLNE,HOOD,HWC,IBKR,ICE,IVZ,JEF,JHG,JKHY,JPM,KEY,KKR,KMPR,L,LAZ,LC,LION,LMND,LNC,LPLA,MA,MC,MCO,MET,MIAX,MS,MSCI,MTB,MTG,NATL,NDAQ,NTRS,NU,OMF,ORI,PAX,PB,PFG,PFS,PGR,PGY,PNC,PRU,PWP,PYPL,RDN,RJF,RKT,RLI,RYAN,SCHW,SEI,SF,SLM,SOFI,SPGI,STT,SYF,TFC,TFSL,TPG,TRI,TROW,TRU,TRV,TW,TWO,UNM,UPST,USB,V,VIRT,VLY,VOYA,VRSK,WBS,WFC,WRB,WT,WTW,XP,ZION", t)

f_is_XLV(t) =>
    f_has("A,ABBV,ABT,ACHC,AGL,AHCO,ALGN,ALHC,AMGN,AMN,AMPH,AMRX,AORT,ATRC,AVNS,AZTA,BAX,BDX,BIIB,BKD,BMY,BRKR,BSX,CAH,CAI,CALY,CCRN,CI,CNC,COO,COR,CRL,CTRI,CVS,CYRX,DGX,DHR,DVA,DXCM,EHC,ELAN,ELV,ENOV,EW,EXEL,FTRE,GEHC,GH,GILD,GMED,HAE,HCA,HIMS,HOLX,HQY,HRMY,HROW,HSIC,HUM,IART,IDXX,ILMN,INDV,INSP,ISRG,JANX,JNJ,KVUE,LH,LIVN,LLY,LNTH,MASI,MBX,MCK,MD,MDLN,MDT,MMSI,MOH,MRK,MRNA,NTRA,NVCR,NVST,OGN,OHI,OPCH,OSCR,PACS,PBH,PFE,PGNY,PODD,PRCT,PRGO,PRVA,QGEN,RDNT,REGN,RGEN,RMD,RPRX,RVTY,SARO,SEM,SGRY,SHC,SIBN,SLNO,SOLV,STAA,STE,SYK,SYRE,TECH,TEM,TFX,THC,TMDX,TMO,TNDM,TXG,UHS,UNH,VCYT,VEEV,VRTX,VTR,VTRS,WAT,WEST,WGS,WST,XRAY,YOU,ZBH,ZTS", t)

f_is_XLY(t) =>
    f_has("AAP,ABNB,ADNT,AEO,AMZN,ANF,APTV,ARMK,AS,ASO,AZO,BABA,BBWI,BBY,BFAM,BIRK,BJ,BKNG,BLDR,BOOT,BROS,BURL,BWA,BYD,BZH,CAKE,CAR,CARG,CART,CAVA,CBRL,CCL,CHDN,CHWY,CMG,COST,CPNG,CPRI,CRI,CROX,CVNA,CZR,DAN,DECK,DFH,DG,DHI,DKNG,DKS,DLTR,DPZ,DRI,DRVN,EAT,ETSY,EXPE,EYE,F,FIGS,FIVE,FLUT,FND,FUN,FWRG,GAP,GCT,GM,GME,GNTX,GPC,GRPN,GTES,GTX,H,HAS,HAYW,HD,HLF,HLT,HOG,HRB,IMAX,JACK,KBH,KMX,KRMN,KSS,KTB,LEN,LIND,LKQ,LOW,LTH,LULU,LVS,LYFT,M,MAN,MAR,MAT,MCD,MELI,MGM,MHK,MNRO,MTH,NCLH,NKE,OLLI,ONON,ORLY,OUT,P,PDD,PENN,PFGC,PHM,PINS,PLAY,PLNT,POOL,PVH,PZZA,QSR,RBLX,RCL,REYN,REZI,RIVN,RL,ROST,RRR,RSI,RVLV,SBH,SBUX,SCI,SEZL,SGHC,SHAK,SHOO,SONO,TGT,TH,TJX,TMHC,TOL,TOST,TPR,TSCO,TSLA,TXRH,UBER,ULTA,URBN,VFC,VIK,W,WH,WHR,WING,WMT,WRBY,WSM,WWW,WYNN,XYZ,YELP,YETI,YSS,YUM", t)

f_is_XLI(t) =>
    f_has("AAL,ACM,ACN,AGCO,ALK,ALLE,ALSN,AME,AMPX,AMTM,AOS,ATMU,BA,BAH,BETA,BV,BWXT,CARR,CAT,CBRE,CECO,CHRW,CLH,CMI,CNH,CNM,CPRT,CSX,CTAS,CWK,CXT,DAL,DE,DOV,DRS,EME,ERIE,ETN,EXPD,FA,FAST,FBIN,FDX,FER,FERG,FLOC,FLR,FLS,FTAI,G,GD,GE,GEV,GGG,GNRC,GTLS,GWW,GXO,HEI,HII,HNI,HON,HUBB,HWM,HXL,IEX,IMXI,INGM,IR,ITT,ITW,J,JBHT,JCI,JOBY,KBR,KD,KGS,KMT,KNX,LDOS,LHX,LII,LMT,LOAR,LUNR,LUV,MAS,MDU,MEI,MIDD,MIR,MLM,MMM,MMS,MOD,MRTN,MSI,MTZ,MWA,NDSN,NN,NOC,NSC,NVT,ODFL,OSK,OTIS,OUST,PAR,PAYX,PBI,PCAR,PCT,PH,PNR,POWL,PPLI,PRA,PRIM,PRKS,PSIX,PSN,PWR,QXO,RBA,RDW,RHI,ROK,ROL,RRX,RSG,RTX,RXO,SITE,SMR,SNA,SNDR,SPIR,STRL,SWK,TDC,TDG,TDS,TDY,TEX,THR,TKR,TT,TTEK,TTTY,TXT,UAL,UNP,UPS,URI,USAR,VNT,VRRM,VSTS,VVV,VVX,WAB,WERN,WM,WSC,XPO,XYL,ZWS", t)

f_is_XLE(t) =>
    f_has("AESI,AM,APA,AR,AROC,BE,BKR,BKV,BTU,CLMT,CNX,COP,CRC,CRGY,CRK,CTRA,CVI,CVX,DHT,DINO,DK,DNOW,DVN,EMR,EOG,EQT,EXE,FANG,FTI,GLNG,GPRE,HAL,HCC,HES,HLX,HNRG,HP,KMI,KNTK,LBRT,LEU,LNG,LTBR,METC,MGY,MPC,MTDR,MUR,NE,NESR,NFG,NNE,NOG,NOV,OII,OKE,OKLO,OVV,OXY,PARR,PBF,PR,PSX,PTEN,PUMP,RRC,SFL,SLB,SM,SOC,STNG,TALO,TDW,TRGP,TTI,UEC,UTI,UUUU,VAL,VLO,VNOM,WFRD,WMB,WTTR,WULF,XOM,XPRO", t)

f_is_XLP(t) =>
    f_has("ACI,ADM,AVO,BF.B,BG,CAG,CALM,CCEP,CELH,CHD,CL,CLX,COCO,COKE,CPB,DAR,DOLE,EL,ELF,ENR,EPC,FRPT,GIS,HRL,HSY,K,KDP,KHC,KMB,KO,KR,LW,MDLZ,MKC,MNST,MO,PEP,PG,PM,POST,PRMB,RAL,SFD,SFM,SGI,SJM,SMPL,SN,STZ,SYY,TAP,TSN,USFD,WBA", t)

f_is_XLU(t) =>
    f_has("AEE,AEP,AES,ATO,AWK,BEPC,BKH,CDP,CEG,CMS,CNP,CWEN,D,DTE,DUK,ED,EIX,ES,ETR,EVRG,EXC,FE,HASI,HE,LNT,NEE,NI,NRG,OGE,ORA,PCG,PNW,POR,PPL,SO,SRE,TXNM,UGI,VST,WEC,WTRG,XEL", t)

f_is_XLB(t) =>
    f_has("ALB,AMCR,APD,ASH,ATI,AVNT,AVY,AXTA,BALL,CC,CCK,CDE,CE,CENX,CF,CLF,CMP,CNR,CRML,CSTM,CTVA,DD,DOW,ECL,ECVT,EMN,ESI,FMC,HUN,IE,IFF,INGR,IP,JHX,LIN,LPX,LXU,LYB,MOS,MRP,MRSH,NUE,NVRI,OC,OLN,PKG,PPC,PPG,PRM,SHW,SMG,SOLS,SON,SSRM,STLD,SW,TREX,VMC,WLK,WY,X", t)

f_is_XLC(t) =>
    f_has("AMT,CCOI,CHTR,CMCSA,CNK,DIS,EA,FOX,FOXA,FWONK,GLIBK,GRND,LBRDK,LBTYA,LBTYK,LYV,MGNI,MTCH,NWS,NWSA,NYT,OMC,RDDT,SIRI,SPHR,SPOT,T,TIGO,TKO,TMUS,TNL,TTWO,VZ,WBD", t)

f_is_XLRE(t) =>
    f_has("ADC,AGNC,AHR,AKR,AMH,APLE,ARE,ARI,ARR,AVB,BIPC,BNL,BRX,BXMT,BXP,CCI,COLD,CPT,CTRE,CUBE,CUZ,CXW,DBRG,DEI,DLR,DOC,DRH,DX,ECG,EFC,ELS,EPRT,EQR,ESS,EXR,FRT,GEO,GLPI,HIW,HPP,HR,HST,INVH,IRM,IRT,JBGS,KIM,KRC,KRG,KW,LAMR,LINE,MAA,MAC,NLY,NMRK,NNN,NSA,NTST,O,PEB,PECO,PK,PLD,PMT,PSA,REG,REXR,RYN,SBAC,SBRA,SHO,SKT,SLG,SPG,STAG,STWD,UDR,UMH,UNIT,VICI,VNO,WELL,WPC", t)

f_is_IWM(t) =>
    f_has("ASST,ASTS,AVAV,BKSY,BTDR,BTSG,CIFR,CLSK,CORZ,DFTX,EFOR,GPGI,GSAT,HUT,IONQ,IQV,KTOS,LAUR,LGN,MARA,MSTR,PL,Q,QBTS,QUBT,RIOT,RKLB,SLDE,TRVI,URGN,VOYG,VSAT,VSNT,VSXY,WYFI", t)

f_sector(t) =>
    string sector = "UNKNOWN"
    if f_is_SMH(t)
        sector := "SMH"
    else if f_is_XBI(t)
        sector := "XBI"
    else if f_is_KRE(t)
        sector := "KRE"
    else if f_is_TAN(t)
        sector := "TAN"
    else if f_is_XME(t)
        sector := "XME"
    else if f_is_XLK(t)
        sector := "XLK"
    else if f_is_XLF(t)
        sector := "XLF"
    else if f_is_XLV(t)
        sector := "XLV"
    else if f_is_XLY(t)
        sector := "XLY"
    else if f_is_XLI(t)
        sector := "XLI"
    else if f_is_XLE(t)
        sector := "XLE"
    else if f_is_XLP(t)
        sector := "XLP"
    else if f_is_XLU(t)
        sector := "XLU"
    else if f_is_XLB(t)
        sector := "XLB"
    else if f_is_XLC(t)
        sector := "XLC"
    else if f_is_XLRE(t)
        sector := "XLRE"
    else if f_is_IWM(t)
        sector := "IWM"

    else if t == "SPY"
        sector := "SPY"
    else if t == "QQQ"
        sector := "QQQ"
    else if t == "IWM"
        sector := "IWM"
    else if t == "XLK"
        sector := "XLK"
    else if t == "XLF"
        sector := "XLF"
    else if t == "XLV"
        sector := "XLV"
    else if t == "XLY"
        sector := "XLY"
    else if t == "XLP"
        sector := "XLP"
    else if t == "XLI"
        sector := "XLI"
    else if t == "XLE"
        sector := "XLE"
    else if t == "XLU"
        sector := "XLU"
    else if t == "XLB"
        sector := "XLB"
    else if t == "XLC"
        sector := "XLC"
    else if t == "XLRE"
        sector := "XLRE"
    else if t == "SMH"
        sector := "SMH"
    else if t == "XBI"
        sector := "XBI"
    else if t == "KRE"
        sector := "KRE"
    else if t == "TAN"
        sector := "TAN"
    else if t == "XME"
        sector := "XME"
    else if t == "IGV"
        sector := "IGV"
    else if t == "ITA"
        sector := "ITA"
    else if t == "HACK"
        sector := "HACK"
    else if t == "URA"
        sector := "URA"
    else if t == "ARKK"
        sector := "ARKK"

    sector

string tkr = str.upper(syminfo.ticker)
string etf = f_sector(tkr)
string sectorName = f_sector_name(etf)

showName = input.bool(false, "Show sector / industry name")
bgOn     = input.bool(true,  "Colored background")
txtSize  = input.string("normal", "Text size", options=["tiny","small","normal","large","huge"])

string txt = showName ? ("Tag: " + etf + " (" + sectorName + ")") : ("Tag: " + etf)

var table tbl = table.new(position.top_right, 1, 1, frame_width=1, frame_color=color.new(color.black, 0))
table.cell(tbl, 0, 0, txt, text_color=color.black, bgcolor=bgOn ? f_bg(etf) : na, text_size=txtSize)
````
