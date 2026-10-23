//+------------------------------------------------------------------+
//|                                          Channel Sun Signals.mq5 |
//|                                   Copyright 2026, Marian Beceanu |
//|                            https://www.mql5.com/en/users/zorbacc |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Marian Beceanu"
#property link      "https://www.mql5.com/en/users/zorbacc"
#property link      "https://forge.mql5.io"
#property version   "2.00"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   5

//--- Buffer 0: linia centrala
#property indicator_label1  "Mid"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_style1  STYLE_DOT
#property indicator_width1  1

//--- Buffer 1: banda superioara
#property indicator_label2  "Upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Buffer 2: banda inferioara
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- Buffer 3: semnal SELL - sageata rosie, afisata DEASUPRA lumanarii
#property indicator_label4  "Sell (above)"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  1

//--- Buffer 4: semnal BUY - sageata albastra, afisata SUB lumanare
#property indicator_label5  "Buy (below)"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrBlue
#property indicator_width5  1

//+------------------------------------------------------------------+
//| Lista de culori disponibile ca ENUM (dropdown), nu color-picker.  |
//+------------------------------------------------------------------+
enum ENUM_ColorChoice
  {
   Color_White,
   Color_Black,
   Color_DimGray,
   Color_Gray,
   Color_Silver,
   Color_Red,
   Color_Maroon,
   Color_OrangeRed,
   Color_Orange,
   Color_Gold,
   Color_Yellow,
   Color_YellowGreen,
   Color_LimeGreen,
   Color_Lime,
   Color_Green,
   Color_DarkGreen,
   Color_Teal,
   Color_Aqua,
   Color_Cyan,
   Color_DeepSkyBlue,
   Color_DodgerBlue,
   Color_Blue,
   Color_Navy,
   Color_SlateBlue,
   Color_Purple,
   Color_Magenta,
   Color_DeepPink,
   Color_Pink,
   Color_Brown,
   Color_Chocolate,
   Color_Turquoise,
   Color_Violet
  };

//+------------------------------------------------------------------+
//| Conversie ENUM_ColorChoice -> color efectiv                       |
//+------------------------------------------------------------------+
color ColorFromChoice(ENUM_ColorChoice c)
  {
   switch(c)
     {
      case Color_White:       return clrWhite;
      case Color_Black:       return clrBlack;
      case Color_DimGray:     return clrDimGray;
      case Color_Gray:        return clrGray;
      case Color_Silver:      return clrSilver;
      case Color_Red:         return clrRed;
      case Color_Maroon:      return clrMaroon;
      case Color_OrangeRed:   return clrOrangeRed;
      case Color_Orange:      return clrOrange;
      case Color_Gold:        return clrGold;
      case Color_Yellow:      return clrYellow;
      case Color_YellowGreen: return clrYellowGreen;
      case Color_LimeGreen:   return clrLimeGreen;
      case Color_Lime:        return clrLime;
      case Color_Green:       return clrGreen;
      case Color_DarkGreen:   return clrDarkGreen;
      case Color_Teal:        return clrTeal;
      case Color_Aqua:        return clrAqua;
      case Color_Cyan:        return clrCyan;
      case Color_DeepSkyBlue: return clrDeepSkyBlue;
      case Color_DodgerBlue:  return clrDodgerBlue;
      case Color_Blue:        return clrBlue;
      case Color_Navy:        return clrNavy;
      case Color_SlateBlue:   return clrSlateBlue;
      case Color_Purple:      return clrPurple;
      case Color_Magenta:     return clrMagenta;
      case Color_DeepPink:    return clrDeepPink;
      case Color_Pink:        return clrPink;
      case Color_Brown:       return clrBrown;
      case Color_Chocolate:   return clrChocolate;
      case Color_Turquoise:   return clrTurquoise;
      case Color_Violet:      return clrViolet;
      default:                return clrDimGray;
     }
  }

//--- Input parameters
input ENUM_TIMEFRAMES InpTimeFrame = PERIOD_CURRENT;     // Timeframe (dropdown: current, M1...MN1)
input int    InpHalfLength      = 30;                    // Channel HalfLength (smoothness)
input ENUM_APPLIED_PRICE InpPrice = PRICE_WEIGHTED;       // Applied price
input double InpBandsDeviations = 2.0;                    // Bands deviation multiplier
input bool   InpInterpolate     = true;                   // Interpolate between MTF bars

input group "=== Colors (list, not palette) ==="
input ENUM_ColorChoice InpColorMid       = Color_White;       // Mid line color
input ENUM_ColorChoice InpColorUpper     = Color_Orange;      // Upper band color
input ENUM_ColorChoice InpColorLower     = Color_Orange;      // Lower band color
input ENUM_ColorChoice InpColorDownArrow = Color_Red;         // Sell arrow color
input ENUM_ColorChoice InpColorUpArrow   = Color_Blue;        // Buy arrow color

input group "=== Line width / Arrow size ==="
input int    InpWidthMid        = 1;                      // Mid line width (1-5)
input int    InpWidthUpper      = 2;                      // Upper band width (1-5)
input int    InpWidthLower      = 2;                      // Lower band width (1-5)
input int    InpArrowSizeDown   = 1;                       // Sell arrow size (1-5)
input int    InpArrowSizeUp     = 1;                       // Buy arrow size (1-5)

input group "=== Signals ==="
input bool   InpSignalsClosedBarOnly = false;             // Signal only after bar close (no repainting)

input group "=== Signal filters (optional) ==="
input bool   InpFilterVolatility  = false;                // 1) Filter signals when band is too narrow (no-trend market)
input double InpMinBandWidthPct   = 0.10;                 // Minimum band width (% of price) for a valid signal
input bool   InpFilterVolume      = false;                // 2) Confirm signal with above-average volume
input int    InpVolumeAvgPeriod   = 20;                   // Volume average period (bars prior to the signal bar)
input double InpVolumeMultiplier  = 1.2;                  // Signal bar volume must be >= average * this factor
input int    InpSignalCooldownBars= 0;                    // 3) Minimum bars between two signals (0 = disabled)

input group "=== Alerts ==="
input bool   InpAlertsOn        = false;                  // Enable alerts
input bool   InpAlertsOnCurrent = false;                  // Alerts on current (unclosed) bar
input bool   InpAlertsOnHighLow = true;                   // Alert on High/Low (otherwise on Close)
input bool   InpAlertsMessage   = true;                   // Popup alert
input bool   InpAlertsSound     = false;                  // Sound alert
input bool   InpAlertsEmail     = false;                  // Email alert
input bool   InpAlertsNotify    = false;                  // Push notification alert

//--- Buffere indicator (afisate pe graficul curent)
double midBuffer[];
double upBuffer[];
double dnBuffer[];
double dnArrowBuf[];   // semnal SELL (sageata rosie, deasupra lumanarii)
double upArrowBuf[];   // semnal BUY  (sageata albastra, sub lumanare)
double wuBuffer[];   // buffer intermediar de calcul (deviatie superioara) - pt. timeframe-ul curent
double wdBuffer[];   // buffer intermediar de calcul (deviatie inferioara) - pt. timeframe-ul curent

//--- Buffer de lucru pentru ATR (citit in bloc, nu bara-cu-bara), foloseste la offset-ul sagetilor
double atrArray[];
int    atrHandle = INVALID_HANDLE;

//--- Buffere locale pentru datele timeframe-ului ales (folosite DOAR daca timeFrame != Period(),
//    NU sunt indicator_buffers, sunt simple array-uri interne, populate cu CopyRates() -
//    aici e inlocuita complet dependenta de iCustom/.ex5 pentru functia multi-timeframe)
MqlRates htRates[];
double   htMid[];
double   htUpper[];
double   htLower[];
double   htWu[];
double   htWd[];
int      htCount=0;

//--- buffere OHLC persistente pentru timeframe-ul MTF (evita realocarea a 4 array-uri
//    noi la fiecare tick; sunt doar redimensionate, cu rezerva, cand cresc)
double   htO[];
double   htH[];
double   htL[];
double   htC[];

//--- cache pentru recalcul incremental in RefreshHtf(): daca bara HTF cea mai noua
//    (index 0) e tot aceeasi ca la apelul anterior (doar s-a mai miscat pretul in ea,
//    fara sa se fi inchis), NU mai recalculam tot istoricul - doar fereastra din fata
//    afectata de acea bara (cel mult halfLength bare vecine). Cand se deschide o bara
//    HTF noua sau la prima rulare, se face un recalcul complet, sigur.
datetime gHtLastBarTime=0;
int      gHtLastCopied=-1;

//--- Variabile globale
int               halfLength;
double            bandsDeviations;
ENUM_TIMEFRAMES   timeFrame;
bool              useMTF    = false;

//+------------------------------------------------------------------+
//| Pret aplicat, pentru un set generic de arrays OHLC (folosit si    |
//| pentru timeframe-ul curent, si pentru cel ales din MTF)           |
//+------------------------------------------------------------------+
double AppliedPriceOf(int i,const double &o[],const double &h[],const double &l[],const double &c[])
  {
   switch(InpPrice)
     {
      case PRICE_OPEN:     return o[i];
      case PRICE_HIGH:     return h[i];
      case PRICE_LOW:      return l[i];
      case PRICE_MEDIAN:   return (h[i]+l[i])/2.0;
      case PRICE_TYPICAL:  return (h[i]+l[i]+c[i])/3.0;
      case PRICE_WEIGHTED: return (h[i]+l[i]+2.0*c[i])/4.0;
      default:             return c[i];
     }
  }

//+------------------------------------------------------------------+
//| Un nivel de banda e considerat valid doar daca e un pret real     |
//| posibil - respinge santinela EMPTY_VALUE / valorile neterminate   |
//+------------------------------------------------------------------+
bool IsValidLevel(double v)
  {
   return(v>-1000000.0 && v<1000000.0 && v!=0.0);
  }

//+------------------------------------------------------------------+
//| Text scurt pentru timeframe, folosit in numele afisat pe grafic   |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf)
  {
   string s=EnumToString(tf);
   StringReplace(s,"PERIOD_","");
   return s;
  }

//+------------------------------------------------------------------+
//| Calcul generic canal: medie ponderata triunghiular + benzi        |
//| Lucreaza pe orice set de arrays OHLC (curent sau MTF), scrie in   |
//| bufferele mid/up/dn/wu/wd primite ca parametri                    |
//+------------------------------------------------------------------+
void CalculateChannelGeneric(int limit,int total,
                              const double &o[],const double &h[],const double &l[],const double &c[],
                              double &midOut[],double &upOut[],double &dnOut[],double &wuOut[],double &wdOut[])
  {
   double fullLength=2.0*halfLength+1.0;
   int seedIndex=total-halfLength-1;
   if(seedIndex<0) seedIndex=total-1;

   for(int i=limit; i>=0; i--)
     {
      double sum =(halfLength+1)*AppliedPriceOf(i,o,h,l,c);
      double sumw=(halfLength+1);

      for(int j=1,k=halfLength; j<=halfLength; j++,k--)
        {
         int idxNewer=i-j;
         int idxOlder=i+j;

         if(idxNewer>=0)
           {
            sum +=k*AppliedPriceOf(idxNewer,o,h,l,c);
            sumw+=k;
           }
         if(idxOlder<total)
           {
            sum +=k*AppliedPriceOf(idxOlder,o,h,l,c);
            sumw+=k;
           }
        }
      midOut[i]=sum/sumw;

      double diff=AppliedPriceOf(i,o,h,l,c)-midOut[i];

      if(i>seedIndex) continue;
      if(i==seedIndex)
        {
         upOut[i]=midOut[i];
         dnOut[i]=midOut[i];
         if(diff>=0) { wuOut[i]=diff*diff; wdOut[i]=0; }
         else        { wdOut[i]=diff*diff; wuOut[i]=0; }
         continue;
        }

      if(diff>=0)
        {
         wuOut[i]=(wuOut[i+1]*(fullLength-1)+diff*diff)/fullLength;
         wdOut[i]= wdOut[i+1]*(fullLength-1)/fullLength;
        }
      else
        {
         wdOut[i]=(wdOut[i+1]*(fullLength-1)+diff*diff)/fullLength;
         wuOut[i]= wuOut[i+1]*(fullLength-1)/fullLength;
        }

      upOut[i]=midOut[i]+bandsDeviations*MathSqrt(MathMax(wuOut[i],0.0));
      dnOut[i]=midOut[i]-bandsDeviations*MathSqrt(MathMax(wdOut[i],0.0));

      //--- protectie: un tick/bara cu date corupte de la broker (pret 0, gap de feed etc.)
      //    nu trebuie sa "strice" definitiv canalul; daca rezultatul nu e un numar valid,
      //    revenim la ultima valoare buna cunoscuta (sau la pretul curent, in lipsa ei)
      if(!MathIsValidNumber(midOut[i]) || !MathIsValidNumber(upOut[i]) || !MathIsValidNumber(dnOut[i]))
        {
         double fallback=AppliedPriceOf(i,o,h,l,c);
         midOut[i]=fallback; upOut[i]=fallback; dnOut[i]=fallback;
         wuOut[i]=0; wdOut[i]=0;
        }
     }
  }

//+------------------------------------------------------------------+
//| Calcul semnale BUY/SELL - aceeasi logica precum in TMA+CG:        |
//| bara anterioara sparge banda, apoi bara curenta revine in         |
//| directia opusa -> semnal de intoarcere de la marginea canalului.  |
//| Se aplica DUPA ce midBuffer/upBuffer/dnBuffer sunt deja umplute   |
//| (fie direct, fie prin MTF), atat pentru i cat si pentru i+1.      |
//+------------------------------------------------------------------+
void CalculateSignals(int limit,int rates_total,
                       const double &open[],const double &high[],const double &low[],const double &close[],
                       const long &tick_volume[])
  {
   int atrCount=limit+2;
   if(atrCount>rates_total) atrCount=rates_total;
   bool haveAtr=false;
   if(atrHandle!=INVALID_HANDLE && atrCount>0)
     {
      if(ArraySize(atrArray)<atrCount)
        {
         if(ArrayResize(atrArray,atrCount,1000)<atrCount) atrCount=0; // esec la resize -> renuntam sigur la offset ATR
        }
      if(atrCount>0)
        {
         ArraySetAsSeries(atrArray,true);
         haveAtr=(CopyBuffer(atrHandle,0,0,atrCount,atrArray)>0);
        }
     }

   int startIdx=(InpSignalsClosedBarOnly ? 1 : 0);
   for(int i=limit; i>=0; i--)
     {
      dnArrowBuf[i]=EMPTY_VALUE;
      upArrowBuf[i]=EMPTY_VALUE;

      if(i<startIdx) continue;            // bara 0 (in formare) - sarita daca vrem doar bare inchise
      if(i+1>=rates_total) continue;

      double atrVal=0;
      if(haveAtr && i<ArraySize(atrArray)) atrVal=atrArray[i];

      bool rawSell=(IsValidLevel(upBuffer[i+1]) && high[i+1]>upBuffer[i+1] && close[i+1]>open[i+1] && close[i]<open[i]);
      bool rawBuy =(IsValidLevel(dnBuffer[i+1]) && low[i+1] <dnBuffer[i+1] && close[i+1]<open[i+1] && close[i]>open[i]);
      if(!rawSell && !rawBuy) continue;

      //--- 1) FILTRU VOLATILITATE: ignoram semnalele cand banda e prea ingusta
      //    (piata plata / fara trend), unde spargerile de banda sunt mai degraba
      //    zgomot decat o reala extindere/epuizare de miscare
      if(InpFilterVolatility)
        {
         if(!IsValidLevel(upBuffer[i+1]) || !IsValidLevel(dnBuffer[i+1]) || !IsValidLevel(midBuffer[i+1]) || midBuffer[i+1]==0.0)
           { rawSell=false; rawBuy=false; }
         else
           {
            double widthPct=(upBuffer[i+1]-dnBuffer[i+1])/MathAbs(midBuffer[i+1])*100.0;
            if(widthPct<InpMinBandWidthPct) { rawSell=false; rawBuy=false; }
           }
        }

      //--- 2) FILTRU VOLUM: cerem ca bara ce a spart banda (i+1) sa aiba volum
      //    peste medie - o spargere pe volum slab e mai probabil o fals-pozitiva
      if((rawSell || rawBuy) && InpFilterVolume)
        {
         double avgVol=0; int cnt=0;
         for(int b=i+2;b<i+2+InpVolumeAvgPeriod && b<rates_total;b++)
           {
            avgVol+=(double)tick_volume[b];
            cnt++;
           }
         bool volumeOk=false;
         if(cnt>0)
           {
            avgVol/=cnt;
            volumeOk=(avgVol>0.0 && (double)tick_volume[i+1]>=avgVol*InpVolumeMultiplier);
           }
         if(!volumeOk) { rawSell=false; rawBuy=false; }
        }

      //--- 3) COOLDOWN: nu emitem un semnal nou daca a mai aparut unul (oricare
      //    directie) in ultimele InpSignalCooldownBars bare - evita "roiuri" de
      //    sageti dese in perioade agitate. Folosim direct bufferele proprii
      //    (deja calculate pentru barele mai vechi) ca istoric de semnale, fara
      //    nicio variabila globala suplimentara.
      if((rawSell || rawBuy) && InpSignalCooldownBars>0)
        {
         for(int b=1;b<=InpSignalCooldownBars;b++)
           {
            int idx=i+b;
            if(idx>=rates_total) break;
            if(dnArrowBuf[idx]!=EMPTY_VALUE || upArrowBuf[idx]!=EMPTY_VALUE)
              { rawSell=false; rawBuy=false; break; }
           }
        }

      //--- SEMNAL SELL (rosu, sageata jos): sus, DEASUPRA lumanarii (high + ATR)
      if(rawSell) dnArrowBuf[i]=high[i]+atrVal;
      //--- SEMNAL BUY (albastru, sageata sus): jos, SUB lumanarea (low - ATR)
      if(rawBuy)  upArrowBuf[i]=low[i]-atrVal;
     }
  }

//+------------------------------------------------------------------+
//| Alerte                                                             |
//+------------------------------------------------------------------+
void DoAlert(string doWhat)
  {
   static string   previousAlert="";
   static datetime previousTime=0;

   datetime barTime=iTime(_Symbol,PERIOD_CURRENT,0);
   if(previousAlert!=doWhat || previousTime!=barTime)
     {
      previousAlert=doWhat;
      previousTime =barTime;

      string message=_Symbol+" la "+TimeToString(TimeLocal(),TIME_SECONDS)+" Channel Sun Signals: "+doWhat;
      if(InpAlertsMessage) Alert(message);
      if(InpAlertsNotify)  SendNotification(message);
      if(InpAlertsEmail)   SendMail(_Symbol+" Channel Sun Signals",message);
      if(InpAlertsSound)   PlaySound("alert2.wav");
     }
  }

void CheckAlerts(int rates_total,const double &open[],const double &high[],const double &low[],const double &close[])
  {
   int forBar=InpAlertsOnCurrent ? 0 : 1;
   if(forBar+1>=rates_total) return;

   if(InpAlertsOnHighLow)
     {
      if(high[forBar]>upBuffer[forBar] && high[forBar+1]<upBuffer[forBar+1]) DoAlert("high a penetrat banda superioara");
      if(low[forBar] <dnBuffer[forBar] && low[forBar+1] >dnBuffer[forBar+1]) DoAlert("low a penetrat banda inferioara");
     }
   else
     {
      if(close[forBar]>upBuffer[forBar] && close[forBar+1]<upBuffer[forBar+1]) DoAlert("close a penetrat banda superioara");
      if(close[forBar]<dnBuffer[forBar] && close[forBar+1]>dnBuffer[forBar+1]) DoAlert("close a penetrat banda inferioara");
     }
  }

//+------------------------------------------------------------------+
//| Aduce lumanarile timeframe-ului ales (CopyRates, nativ, fara      |
//| iCustom) si calculeaza local canalul pe acele lumanari.           |
//| Se re-executa la fiecare tick, dar CopyRates e ieftin (citeste    |
//| direct din istoricul deja incarcat de terminal).                  |
//+------------------------------------------------------------------+
bool RefreshHtf(int chartRatesTotal)
  {
   double secChart=(double)PeriodSeconds(Period());
   double secHtf  =(double)PeriodSeconds(timeFrame);
   if(secChart<=0 || secHtf<=0) return(false);

   double ratio=secHtf/secChart;
   int needed=(int)MathCeil(chartRatesTotal/MathMax(ratio,1.0))+halfLength+5;
   if(needed<halfLength*2+5) needed=halfLength*2+5;
   if(needed>20000) needed=20000; // limita rezonabila, evita cereri uriase

   int copied=CopyRates(_Symbol,timeFrame,0,needed,htRates);
   if(copied<=halfLength+1) return(false);

   ArraySetAsSeries(htRates,true);

//--- redimensionare cu rezerva (500 elemente) - reduce realocarile dese pe masura
//    ce se acumuleaza istoric; verificam explicit reusita, altfel iesim sigur
   if(ArraySize(htMid)<copied)
     {
      if(ArrayResize(htMid,copied,500)<copied)   return(false);
      if(ArrayResize(htUpper,copied,500)<copied) return(false);
      if(ArrayResize(htLower,copied,500)<copied) return(false);
      if(ArrayResize(htWu,copied,500)<copied)    return(false);
      if(ArrayResize(htWd,copied,500)<copied)    return(false);
     }

//--- buffere OHLC reutilizate (nu mai realocam 4 array-uri noi la fiecare tick)
   if(ArraySize(htO)<copied)
     {
      if(ArrayResize(htO,copied,500)<copied) return(false);
      if(ArrayResize(htH,copied,500)<copied) return(false);
      if(ArrayResize(htL,copied,500)<copied) return(false);
      if(ArrayResize(htC,copied,500)<copied) return(false);
     }
   for(int k=0;k<copied;k++)
     {
      htO[k]=htRates[k].open; htH[k]=htRates[k].high; htL[k]=htRates[k].low; htC[k]=htRates[k].close;
     }

//--- decidem daca putem face un recalcul usor (doar fereastra din fata) sau trebuie
//    recalcul complet: e sigur sa sarim peste recalculul integral DOAR daca bara HTF
//    cea mai noua e EXACT aceeasi ca la apelul precedent (acelasi timp de deschidere
//    si acelasi numar de bare copiate) - inseamna ca niciun index nu s-a deplasat,
//    doar OHLC-ul barei curente (nedefinitivate) s-a mai miscat intre timp.
   bool sameFrontBar=(gHtLastCopied==copied && gHtLastCopied>0 && htRates[0].time==gHtLastBarTime);

   if(sameFrontBar)
     {
      //--- doar bara 0 (in formare) s-a putut schimba; media triunghiulara are fereastra
      //    de +/-halfLength, deci doar primele halfLength+1 bare pot fi afectate. Restul
      //    istoricului (deja calculat corect la trecerea anterioara) ramane neatins,
      //    iar recursia wu/wd continua exact din valoarea cache-uita la halfLength+1.
      int frontLimit=MathMin(copied-1,halfLength+1);
      CalculateChannelGeneric(frontLimit,copied,htO,htH,htL,htC,htMid,htUpper,htLower,htWu,htWd);
     }
   else
     {
      //--- prima rulare, schimbare de parametri, gaura de istoric sau bara HTF noua
      //    deschisa -> recalcul complet, cea mai sigura varianta
      CalculateChannelGeneric(copied-1,copied,htO,htH,htL,htC,htMid,htUpper,htLower,htWu,htWd);
     }

   gHtLastBarTime=htRates[0].time;
   gHtLastCopied =copied;

   htCount=copied;
   return(true);
  }

//+------------------------------------------------------------------+
//| Initializare                                                      |
//+------------------------------------------------------------------+
int OnInit()
  {
   halfLength=(int)MathMax(InpHalfLength,1);
   if(halfLength>2000) halfLength=2000;

   bandsDeviations=InpBandsDeviations;
   if(bandsDeviations<=0.0) bandsDeviations=2.0;
   if(bandsDeviations>20.0) bandsDeviations=20.0;

   timeFrame=InpTimeFrame;
   if(timeFrame==PERIOD_CURRENT) timeFrame=(ENUM_TIMEFRAMES)Period();
//--- siguranta: canalul MTF presupune ca timeframe-ul ales are bare "mai mari"
//    (una sau mai multe bare de grafic incap intr-o bara HTF). Daca userul alege
//    un timeframe mai mic decat graficul, logica de shift/interpolare si-ar pierde
//    sensul (ar insemna mai multe bare HTF intr-o singura bara de grafic) -> revenim
//    sigur la timeframe-ul graficului, exact ca in TMA+CG.
   if(timeFrame<Period()) timeFrame=(ENUM_TIMEFRAMES)Period();

//--- resetam cache-ul de recalcul incremental MTF - orice reinitializare (schimbare
//    de parametri, reincarcare) trebuie sa forteze un recalcul complet si sigur
   gHtLastBarTime=0;
   gHtLastCopied=-1;

   int widthMid     =(int)MathMin(MathMax(InpWidthMid,1),5);
   int widthUpper   =(int)MathMin(MathMax(InpWidthUpper,1),5);
   int widthLower   =(int)MathMin(MathMax(InpWidthLower,1),5);
   int arrowSizeDown=(int)MathMin(MathMax(InpArrowSizeDown,1),5);
   int arrowSizeUp  =(int)MathMin(MathMax(InpArrowSizeUp,1),5);

   SetIndexBuffer(0,midBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,upBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,dnBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,dnArrowBuf,INDICATOR_DATA);
   SetIndexBuffer(4,upArrowBuf,INDICATOR_DATA);
   SetIndexBuffer(5,wuBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,wdBuffer,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(midBuffer,true);
   ArraySetAsSeries(upBuffer,true);
   ArraySetAsSeries(dnBuffer,true);
   ArraySetAsSeries(dnArrowBuf,true);
   ArraySetAsSeries(upArrowBuf,true);
   ArraySetAsSeries(wuBuffer,true);
   ArraySetAsSeries(wdBuffer,true);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,halfLength);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,halfLength);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,halfLength);

//--- santinele sigure pentru benzi (evita valori aberante la inceputul istoricului
//    si in interpolarea multi-timeframe)
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,-EMPTY_VALUE);

   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(3,PLOT_ARROW,242);   // sageata jos (SELL)
   PlotIndexSetInteger(4,PLOT_ARROW,241);   // sageata sus (BUY)

//--- culori aplicate din enum-uri (dropdown), nu din paleta nativa de culoare
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,ColorFromChoice(InpColorMid));
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,ColorFromChoice(InpColorUpper));
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,ColorFromChoice(InpColorLower));
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,ColorFromChoice(InpColorDownArrow));
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,ColorFromChoice(InpColorUpArrow));

   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,widthMid);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,widthUpper);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,widthLower);
   PlotIndexSetInteger(3,PLOT_LINE_WIDTH,arrowSizeDown);
   PlotIndexSetInteger(4,PLOT_LINE_WIDTH,arrowSizeUp);

   atrHandle=iATR(_Symbol,PERIOD_CURRENT,20);
   if(atrHandle==INVALID_HANDLE)
      Print("Channel Sun Signals: eroare la crearea handle-ului ATR (",GetLastError(),"). Sagetile de semnal vor fi dezactivate.");

//--- NU mai cream niciun handle iCustom catre noi insine - useMTF doar semnaleaza
//    daca timeframe-ul ales difera de cel al graficului; datele se aduc cu CopyRates()
//    direct in OnCalculate/RefreshHtf(), fara nicio dependenta de fisierul .ex5.
   useMTF=(timeFrame!=Period());

   IndicatorSetString(INDICATOR_SHORTNAME,"Channel "+TimeframeToString(timeFrame)+"("+IntegerToString(halfLength)+")");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitializare                                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(atrHandle!=INVALID_HANDLE) IndicatorRelease(atrHandle);
  }

//+------------------------------------------------------------------+
//| Calcul principal                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[])
  {
   if(rates_total<=halfLength) return(0);

   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);

   int limit;
   if(prev_calculated==0)
      limit=rates_total-1;
   else
      limit=MathMin(rates_total-1,(rates_total-prev_calculated)+halfLength);

   if(!useMTF)
     {
      //--- caz simplu: acelasi timeframe ca graficul - calculam direct pe barele curente
      CalculateChannelGeneric(limit,rates_total,open,high,low,close,midBuffer,upBuffer,dnBuffer,wuBuffer,wdBuffer);
      CalculateSignals(limit,rates_total,open,high,low,close,tick_volume);
      if(InpAlertsOn) CheckAlerts(rates_total,open,high,low,close);
      return(rates_total);
     }

//--- caz multi-timeframe: aducem lumanarile timeframe-ului ales si calculam local (fara iCustom)
   if(!RefreshHtf(rates_total))
     {
      // daca nu avem inca destule bare pe timeframe-ul ales (ex. istoric insuficient descarcat),
      // lasam bufferele goale pana se mai descarca istoric - nu blocam indicatorul
      for(int i=limit; i>=0; i--) { midBuffer[i]=EMPTY_VALUE; upBuffer[i]=EMPTY_VALUE; dnBuffer[i]=EMPTY_VALUE; dnArrowBuf[i]=EMPTY_VALUE; upArrowBuf[i]=EMPTY_VALUE; }
      return(rates_total);
     }

   int cachedNextShift=-2; // -2 = necunoscut inca; evita apelul dublu al iBarShift() pe aceeasi bara

   for(int i=limit; i>=0; i--)
     {
      int      shift1=-1;
      datetime time1=0;

      shift1=(cachedNextShift!=-2) ? cachedNextShift : iBarShift(_Symbol,timeFrame,time[i]);
      cachedNextShift=-2;

      if(shift1>=0 && shift1<htCount)
        {
         time1=htRates[shift1].time;
         midBuffer[i]=htMid[shift1];
         upBuffer[i] =htUpper[shift1];
         dnBuffer[i] =htLower[shift1];
        }
      else
        {
         midBuffer[i]=EMPTY_VALUE;
         upBuffer[i] =EMPTY_VALUE;
         dnBuffer[i] =EMPTY_VALUE;
         continue;
        }

      if(!InpInterpolate) continue;
      if(i==0)             continue;

      int shiftNewer=iBarShift(_Symbol,timeFrame,time[i-1]);
      cachedNextShift=shiftNewer;
      if(shift1==shiftNewer) continue;

      int n=1;
      while(i+n<rates_total && time[i+n]>=time1) n++;

//--- daca bucla iese la marginea/dincolo de istoricul incarcat, renuntam la interpolare
      if(i+n>=rates_total) continue;

//--- interpolam DOAR daca ambele capete au deja valori de banda valide
      if(!IsValidLevel(midBuffer[i]) || !IsValidLevel(midBuffer[i+n]) ||
         !IsValidLevel(upBuffer[i]) || !IsValidLevel(upBuffer[i+n]) ||
         !IsValidLevel(dnBuffer[i]) || !IsValidLevel(dnBuffer[i+n]))
         continue;

      double factor=1.0/n;
      for(int k=1;k<n;k++)
        {
         midBuffer[i+k]=k*factor*midBuffer[i+n]+(1.0-k*factor)*midBuffer[i];
         upBuffer[i+k]=k*factor*upBuffer[i+n]+(1.0-k*factor)*upBuffer[i];
         dnBuffer[i+k]=k*factor*dnBuffer[i+n]+(1.0-k*factor)*dnBuffer[i];
        }
     }

   CalculateSignals(limit,rates_total,open,high,low,close,tick_volume);
   if(InpAlertsOn) CheckAlerts(rates_total,open,high,low,close);

   return(rates_total);
  }
//+------------------------------------------------------------------+
