//+------------------------------------------------------------------+
//|        Sniper Pro — by Hammad Dilber V.05                        |
//|        MQL5 — Premium Visual Edition                             |
//|        © Hammad Dilber - 2026. All rights reserved.              |
//|  NEW: Smart Filter | R:R Ratio | Candle Patterns                 |
//|       Session Filter | Lot Size Calculator                       |
//+------------------------------------------------------------------+
#property copyright   "© Hammad Dilber - 2026"
#property version     "5.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

#property indicator_label1  "EMA 9"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "EMA 21"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrTomato
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "VWAP"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

#property indicator_label4  "BUY"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLime
#property indicator_width4  3

#property indicator_label5  "SELL"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrTomato
#property indicator_width5  3

//+------------------------------------------------------------------+
//| INPUTS
//+------------------------------------------------------------------+
input group  "=== Risk ==="
input double  InpATRMult      = 1.5;
input int     InpATRPeriod    = 14;

input group  "=== Periods ==="
input int     InpEMAFast      = 9;
input int     InpEMASlow      = 21;
input int     InpRSI          = 14;
input int     InpMACDFast     = 12;
input int     InpMACDSlow     = 26;
input int     InpMACDSig      = 9;
input int     InpADX          = 14;
input int     InpVolMA        = 20;

input group  "=== Smart Entry Filter ==="
input bool    InpUseFilter    = true;  // Enable smart filter
input int     InpMinScore     = 4;     // Min conditions out of 7 (4 = balanced)

input group  "=== Session Filter ==="
input bool    InpUseSession   = false; // OFF by default — turn ON if needed
input bool    InpAsian        = true;  // Asian   00:00-08:00 GMT
input bool    InpLondon       = true;  // London  08:00-17:00 GMT
input bool    InpNewYork      = true;  // New York 13:00-22:00 GMT

input group  "=== Lot Size Calculator ==="
input bool    InpLotCalc      = true;
input double  InpAccountBal   = 0;     // 0 = auto detect
input double  InpRiskPercent  = 1.0;   // Risk % per trade

input group  "=== Candle Patterns ==="
input bool    InpPatterns     = true;

input group  "=== Display ==="
input bool    InpDashboard    = true;
input bool    InpLevels       = true;
input bool    InpSignals      = true;
input bool    InpAlerts       = true;  // Enable TP hit alerts

//+------------------------------------------------------------------+
//| BUFFERS
//+------------------------------------------------------------------+
double B_EMA9[], B_EMA21[], B_VWAP[], B_BUY[], B_SELL[];

//+------------------------------------------------------------------+
//| HANDLES & STATE
//+------------------------------------------------------------------+
int hEma9, hEma21, hRSI, hATR, hMACD, hADX, hRSI5m;

double   gEntry=0, gSL=0;
double   gTP1=0, gTP2=0, gTP3=0, gTP4=0, gTP5=0;
int      gSig=0;
bool     gT1=false,gT2=false,gT3=false,gT4=false,gT5=false;
datetime gSigTime=0;
string   gPattern="";
double   gRR=0;
double   gLotSize=0;

string P = "SNP_";
string D = "DSH_";

//--- Theme colors
color C_BG      = C'10,12,20';
color C_PANEL   = C'20,24,40';
color C_BORDER  = C'70,80,120';
color C_HEADER  = C'28,34,58';
color C_GREEN   = C'0,230,110';
color C_RED     = C'255,70,70';
color C_YELLOW  = C'255,220,0';
color C_BLUE    = C'80,160,255';
color C_CYAN    = C'0,220,220';
color C_GRAY    = C'160,170,200';
color C_WHITE   = C'240,245,255';
color C_BULL_BG = C'0,100,50';
color C_BEAR_BG = C'110,25,25';
color C_ORANGE  = C'255,165,0';
color C_PURPLE  = C'180,100,255';
color C_GOLD    = C'255,200,50';

//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,B_EMA9, INDICATOR_DATA);
   SetIndexBuffer(1,B_EMA21,INDICATOR_DATA);
   SetIndexBuffer(2,B_VWAP, INDICATOR_DATA);
   SetIndexBuffer(3,B_BUY,  INDICATOR_DATA);
   SetIndexBuffer(4,B_SELL, INDICATOR_DATA);

   PlotIndexSetInteger(3,PLOT_ARROW,233);
   PlotIndexSetInteger(4,PLOT_ARROW,234);
   PlotIndexSetDouble (3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble (4,PLOT_EMPTY_VALUE,0.0);

   hEma9  = iMA  (_Symbol,PERIOD_CURRENT,InpEMAFast,0,MODE_EMA,PRICE_CLOSE);
   hEma21 = iMA  (_Symbol,PERIOD_CURRENT,InpEMASlow,0,MODE_EMA,PRICE_CLOSE);
   hRSI   = iRSI (_Symbol,PERIOD_CURRENT,InpRSI,PRICE_CLOSE);
   hATR   = iATR (_Symbol,PERIOD_CURRENT,InpATRPeriod);
   hMACD  = iMACD(_Symbol,PERIOD_CURRENT,InpMACDFast,InpMACDSlow,InpMACDSig,PRICE_CLOSE);
   hADX   = iADX (_Symbol,PERIOD_CURRENT,InpADX);
   hRSI5m = iRSI (_Symbol,PERIOD_M5,InpRSI,PRICE_CLOSE);

   if(hEma9==INVALID_HANDLE||hEma21==INVALID_HANDLE||
      hRSI==INVALID_HANDLE ||hATR==INVALID_HANDLE  ||
      hMACD==INVALID_HANDLE||hADX==INVALID_HANDLE)
   { Alert("Sniper Pro: Handle error!"); return INIT_FAILED; }

   IndicatorSetString(INDICATOR_SHORTNAME,"Sniper Pro by Hammad Dilber V.05");
   ClearAll();
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ClearAll();
   Comment("");
   IndicatorRelease(hEma9); IndicatorRelease(hEma21);
   IndicatorRelease(hRSI);  IndicatorRelease(hATR);
   IndicatorRelease(hMACD); IndicatorRelease(hADX);
   IndicatorRelease(hRSI5m);
}

//+------------------------------------------------------------------+
//| SESSION CHECK — only for live/current bar                       |
//+------------------------------------------------------------------+
bool IsActiveSession()
{
   if(!InpUseSession) return true;
   MqlDateTime dt;
   TimeToStruct(TimeGMT(),dt);
   int h=dt.hour;
   bool asian   = InpAsian   && (h>=0  && h<8);
   bool london  = InpLondon  && (h>=8  && h<17);
   bool newyork = InpNewYork && (h>=13 && h<22);
   return (asian||london||newyork);
}

//+------------------------------------------------------------------+
//| SCORE FOR A SPECIFIC BAR INDEX (series arrays)                  |
//| r=0 means latest bar                                            |
//+------------------------------------------------------------------+
void CalcScoreAtBar(
   int r,
   const double &e9[], const double &e21[],
   const double &rsi[], const double &mm[], const double &ms[],
   const double &adx[],
   const double &vwap_arr[],   // forward indexed (B_VWAP)
   const double &open_arr[],   // forward indexed
   const double &close_arr[],  // forward indexed
   const long   &tvol[],       // forward indexed
   int rates_total,
   int &bScore, int &rScore)
{
   bScore=0; rScore=0;

   // forward bar index from r
   int fi = rates_total-1-r;

   double cC   = (fi>=0&&fi<rates_total)? close_arr[fi] : 0;
   double cO   = (fi>=0&&fi<rates_total)? open_arr[fi]  : 0;
   double cVwap= (fi>=0&&fi<rates_total)? vwap_arr[fi]  : 0;
   double cE9  = (r<ArraySize(e9))  ? e9[r]  : 0;
   double cE21 = (r<ArraySize(e21)) ? e21[r] : 0;
   double cRSI = (r<ArraySize(rsi)) ? rsi[r] : 50;
   double cMm  = (r<ArraySize(mm))  ? mm[r]  : 0;
   double cMs  = (r<ArraySize(ms))  ? ms[r]  : 0;
   double cADX = (r<ArraySize(adx)) ? adx[r] : 0;

   // Volume MA at this bar
   double cVolMA=0;
   int vb=MathMin(20,fi+1);
   for(int k=fi-vb+1;k<=fi;k++)
      if(k>=0&&k<rates_total) cVolMA+=(double)tvol[k];
   if(vb>0) cVolMA/=vb;
   long cVol=(fi>=0&&fi<rates_total)?tvol[fi]:0;

   if(cC>cVwap)             bScore++; else rScore++;
   if(cRSI>50)              bScore++; else rScore++;
   if(cMm>cMs)              bScore++; else rScore++;
   if(cE9>cE21)             bScore++; else rScore++;
   if(cADX>25&&cC>cE9)    bScore++; else if(cADX>25&&cC<cE9) rScore++;
   if(cVol>cVolMA&&cC>cO) bScore++; else if(cVol>cVolMA&&cC<cO) rScore++;
   // 5m RSI not available per-bar easily, skip for historical scoring
   // use a neutral 0 contribution for that slot
}

//+------------------------------------------------------------------+
//| CANDLE PATTERN DETECTION                                        |
//+------------------------------------------------------------------+
string DetectPattern(const double &open[], const double &high[],
                     const double &low[],  const double &close[],
                     int r, double atr)
{
   if(!InpPatterns) return "";
   if(r+2>=ArraySize(open)) return "";

   double body   = MathAbs(close[r]-open[r]);
   double bodyP  = close[r]-open[r];
   double hiWick = high[r] -MathMax(close[r],open[r]);
   double loWick = MathMin(close[r],open[r])-low[r];
   double small  = atr*0.3;
   double big    = atr*0.6;

   if(close[r+1]<open[r+1]&&close[r]>open[r]&&
      open[r]<=close[r+1]&&close[r]>=open[r+1])   return "Bullish Engulfing";
   if(close[r+1]>open[r+1]&&close[r]<open[r]&&
      open[r]>=close[r+1]&&close[r]<=open[r+1])   return "Bearish Engulfing";
   if(loWick>=body*2.0&&hiWick<=body*0.5&&body>=small)  return "Hammer";
   if(hiWick>=body*2.0&&loWick<=body*0.5&&body>=small)  return "Shooting Star";
   if(loWick>=atr*0.6&&body<=small)                      return "Bull Pin Bar";
   if(hiWick>=atr*0.6&&body<=small)                      return "Bear Pin Bar";
   if(body<=atr*0.1&&(hiWick+loWick)>=atr*0.4)           return "Doji";
   if(bodyP>=big&&loWick<=body*0.2&&hiWick<=body*0.2)    return "Strong Bull Bar";
   if(-bodyP>=big&&loWick<=body*0.2&&hiWick<=body*0.2)   return "Strong Bear Bar";
   return "";
}

//+------------------------------------------------------------------+
//| LOT SIZE CALCULATOR                                             |
//+------------------------------------------------------------------+
double CalcLotSize(double slDist)
{
   if(!InpLotCalc||slDist<=0) return 0;
   double balance  = (InpAccountBal>0)?InpAccountBal:AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmt  = balance*(InpRiskPercent/100.0);
   double tickVal  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double lotStep  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double minLot   = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot   = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(tickVal<=0||tickSize<=0) return 0;
   double valPerPoint = tickVal/tickSize;
   if(valPerPoint<=0) return 0;
   double lot = riskAmt/(slDist/tickSize*tickVal);
   lot = MathFloor(lot/lotStep)*lotStep;
   lot = MathMax(minLot,MathMin(maxLot,lot));
   return NormalizeDouble(lot,2);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   if(rates_total<InpEMASlow+30) return 0;

   //--- Copy all indicator buffers
   double e9[],e21[],rsi[],atr[],mm[],ms[],adx[],r5m[];
   ArraySetAsSeries(e9,true);  ArraySetAsSeries(e21,true);
   ArraySetAsSeries(rsi,true); ArraySetAsSeries(atr,true);
   ArraySetAsSeries(mm,true);  ArraySetAsSeries(ms,true);
   ArraySetAsSeries(adx,true); ArraySetAsSeries(r5m,true);

   if(CopyBuffer(hEma9, 0,0,rates_total,e9)  <=0) return 0;
   if(CopyBuffer(hEma21,0,0,rates_total,e21) <=0) return 0;
   if(CopyBuffer(hRSI,  0,0,rates_total,rsi) <=0) return 0;
   if(CopyBuffer(hATR,  0,0,rates_total,atr) <=0) return 0;
   if(CopyBuffer(hMACD, 0,0,rates_total,mm)  <=0) return 0;
   if(CopyBuffer(hMACD, 1,0,rates_total,ms)  <=0) return 0;
   if(CopyBuffer(hADX,  0,0,rates_total,adx) <=0) return 0;
   CopyBuffer(hRSI5m,0,0,MathMin(10,rates_total),r5m);

   //--- Buffers forward-indexed
   ArraySetAsSeries(B_EMA9,false);  ArraySetAsSeries(B_EMA21,false);
   ArraySetAsSeries(B_VWAP,false);  ArraySetAsSeries(B_BUY,false);
   ArraySetAsSeries(B_SELL,false);

   //--- EMA + VWAP fill
   int s=(prev_calculated<=1)?0:prev_calculated-1;
   double cumTPV=0,cumVol=0;

   for(int i=s;i<rates_total;i++)
   {
      int r=rates_total-1-i;
      B_EMA9[i]  = (r<ArraySize(e9))  ? e9[r]  : EMPTY_VALUE;
      B_EMA21[i] = (r<ArraySize(e21)) ? e21[r] : EMPTY_VALUE;

      if(i==0){cumTPV=0;cumVol=0;}
      else
      {
         MqlDateTime d1,d2;
         TimeToStruct(time[i],d1);
         TimeToStruct(time[i-1],d2);
         if(d1.day!=d2.day){cumTPV=0;cumVol=0;}
      }
      double hlc3=(high[i]+low[i]+close[i])/3.0;
      double v=(double)tick_volume[i];
      cumTPV+=hlc3*v; cumVol+=v;
      B_VWAP[i]=(cumVol>0)?cumTPV/cumVol:close[i];
      B_BUY[i]=0; B_SELL[i]=0;
   }

   //------------------------------------------------------------------
   // SIGNAL SCAN — full history scan on first load, then just new bars
   //------------------------------------------------------------------
   int sf=(prev_calculated<=2)?1:prev_calculated-1;

   for(int i=sf; i<rates_total-1; i++)
   {
      int r  = rates_total-1-i;   // series index (0=latest)
      int r1 = r+1;
      if(r1>=ArraySize(e9)||r1>=ArraySize(e21)) continue;

      //--- EMA crossover detection
      bool crossUp = (e9[r1] <= e21[r1]) && (e9[r] > e21[r]);  // 9 crossed above 21
      bool crossDn = (e9[r1] >= e21[r1]) && (e9[r] < e21[r]);  // 9 crossed below 21

      if(!crossUp && !crossDn) continue;  // no crossover this bar
      if(time[i] == gSigTime)  continue;  // same bar, skip

      bool doBuy  = crossUp;
      bool doSell = crossDn;

      //--- SMART FILTER: calculate score AT THAT SPECIFIC BAR
      if(InpUseFilter)
      {
         int bSc=0, rSc=0;
         CalcScoreAtBar(r,e9,e21,rsi,mm,ms,adx,
                        B_VWAP,open,close,tick_volume,
                        rates_total,bSc,rSc);
         if(doBuy  && bSc < InpMinScore) continue;
         if(doSell && rSc < InpMinScore) continue;
      }

      //--- SESSION FILTER: only apply to current/last bar
      if(InpUseSession && i==(rates_total-2))
      {
         if(!IsActiveSession()) continue;
      }

      //--- Signal confirmed — set globals
      gSig     = doBuy ? 1 : -1;
      gSigTime = time[i];
      gEntry   = close[i];

      double atrVal = (r<ArraySize(atr)) ? atr[r] : atr[0];
      double risk   = atrVal * InpATRMult;

      gSL  = doBuy ? gEntry-risk     : gEntry+risk;
      gTP1 = doBuy ? gEntry+risk     : gEntry-risk;
      gTP2 = doBuy ? gEntry+risk*2.0 : gEntry-risk*2.0;
      gTP3 = doBuy ? gEntry+risk*3.0 : gEntry-risk*3.0;
      gTP4 = doBuy ? gEntry+risk*4.0 : gEntry-risk*4.0;
      gTP5 = doBuy ? gEntry+risk*5.0 : gEntry-risk*5.0;
      gT1=gT2=gT3=gT4=gT5=false;

      // R:R using TP3 as target
      double rwd = MathAbs(gTP3-gEntry);
      double rsk = MathAbs(gSL-gEntry);
      gRR = (rsk>0) ? NormalizeDouble(rwd/rsk,1) : 0;

      // Candle pattern
      gPattern = DetectPattern(open,high,low,close,r,atrVal);

      // Lot size
      gLotSize = CalcLotSize(MathAbs(gEntry-gSL));

      // Draw arrow
      if(InpSignals)
      {
         if(doBuy)  B_BUY[i]  = low[i]  - atrVal*0.5;
         else       B_SELL[i] = high[i] + atrVal*0.5;
      }

      // Draw lines
      if(InpLevels) DrawLevels();
   }

   //--- TP hit check on latest bar
   int last=rates_total-1;
   if(gSig!=0)
   {
      double cH=high[last], cL=low[last];
      if(gSig==1)
      {
         if(!gT1&&cH>=gTP1){gT1=true;HitLine(P+"TP1");if(InpAlerts)Alert("Sniper TP1 HIT @ "+DoubleToString(gTP1,_Digits));}
         if(!gT2&&cH>=gTP2){gT2=true;HitLine(P+"TP2");if(InpAlerts)Alert("Sniper TP2 HIT @ "+DoubleToString(gTP2,_Digits));}
         if(!gT3&&cH>=gTP3){gT3=true;HitLine(P+"TP3");if(InpAlerts)Alert("Sniper TP3 HIT @ "+DoubleToString(gTP3,_Digits));}
         if(!gT4&&cH>=gTP4){gT4=true;HitLine(P+"TP4");if(InpAlerts)Alert("Sniper TP4 HIT @ "+DoubleToString(gTP4,_Digits));}
         if(!gT5&&cH>=gTP5){gT5=true;HitLine(P+"TP5");if(InpAlerts)Alert("Sniper TP5 HIT @ "+DoubleToString(gTP5,_Digits));}
      }
      else
      {
         if(!gT1&&cL<=gTP1){gT1=true;HitLine(P+"TP1");if(InpAlerts)Alert("Sniper TP1 HIT @ "+DoubleToString(gTP1,_Digits));}
         if(!gT2&&cL<=gTP2){gT2=true;HitLine(P+"TP2");if(InpAlerts)Alert("Sniper TP2 HIT @ "+DoubleToString(gTP2,_Digits));}
         if(!gT3&&cL<=gTP3){gT3=true;HitLine(P+"TP3");if(InpAlerts)Alert("Sniper TP3 HIT @ "+DoubleToString(gTP3,_Digits));}
         if(!gT4&&cL<=gTP4){gT4=true;HitLine(P+"TP4");if(InpAlerts)Alert("Sniper TP4 HIT @ "+DoubleToString(gTP4,_Digits));}
         if(!gT5&&cL<=gTP5){gT5=true;HitLine(P+"TP5");if(InpAlerts)Alert("Sniper TP5 HIT @ "+DoubleToString(gTP5,_Digits));}
      }
      if(InpLevels) UpdateLevelTimes();
   }

   //--- Dashboard (current bar stats)
   if(InpDashboard)
   {
      double cC=close[last],cO=open[last],cVwap=B_VWAP[last];
      double cE9=e9[0],cE21=e21[0];
      double cRSI=(ArraySize(rsi)>0)?rsi[0]:0;
      double cATR=(ArraySize(atr)>0)?atr[0]:0;
      double cMm =(ArraySize(mm)>0)?mm[0]:0;
      double cMs =(ArraySize(ms)>0)?ms[0]:0;
      double cADX=(ArraySize(adx)>0)?adx[0]:0;
      double c5m =(ArraySize(r5m)>0)?r5m[0]:cRSI;
      long   cVol=tick_volume[last];
      double cVolMA=0;
      int vb=MathMin(InpVolMA,rates_total);
      for(int k=last-vb+1;k<=last;k++) cVolMA+=(double)tick_volume[k];
      if(vb>0) cVolMA/=vb;

      int bS=0,rS=0;
      if(cC>cVwap)            bS++; else rS++;
      if(cRSI>50)             bS++; else rS++;
      if(cMm>cMs)             bS++; else rS++;
      if(cE9>cE21)            bS++; else rS++;
      if(cADX>25&&cC>cE9)   bS++; else if(cADX>25&&cC<cE9) rS++;
      if(cVol>cVolMA&&cC>cO) bS++; else if(cVol>cVolMA&&cC<cO) rS++;
      if(c5m>50)              bS++; else rS++;

      double bull=MathRound((bS/7.0)*100);
      double bear=MathRound((rS/7.0)*100);
      double diff=bull-bear;
      string bias=diff>=40?"STRONG BULL":diff<=-40?"STRONG BEAR":diff>0?"MILD BULL":"MILD BEAR";
      color  biasC=diff>=40?C_GREEN:diff<=-40?C_RED:C_YELLOW;

      BuildDashboard(bull,bear,bias,biasC,(int)bS,(int)rS,
                     cC,cVwap,cRSI,c5m,cMm,cMs,cADX,cE9,cE21,cATR,cVol,cVolMA,cO);
   }

   return rates_total;
}

//+------------------------------------------------------------------+
//| Update line end-times every tick so they stay at chart edge     |
//+------------------------------------------------------------------+
void UpdateLevelTimes()
{
   if(gSigTime==0) return;
   datetime tEnd=TimeCurrent()+PeriodSeconds()*5000;
   string names[]={P+"ENTRY",P+"SL",P+"TP1",P+"TP2",P+"TP3",P+"TP4",P+"TP5"};
   for(int i=0;i<ArraySize(names);i++)
      if(ObjectFind(0,names[i])>=0)
      {
         ObjectSetInteger(0,names[i],OBJPROP_TIME,0,gSigTime);
         ObjectSetInteger(0,names[i],OBJPROP_TIME,1,tEnd);
         ObjectSetInteger(0,names[i],OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(0,names[i],OBJPROP_RAY_LEFT, false);
      }
   datetime tLbl=TimeCurrent()+PeriodSeconds()*2;
   string lbls[]={P+"L_ENTRY",P+"L_SL",P+"L_TP1",P+"L_TP2",P+"L_TP3",P+"L_TP4",P+"L_TP5"};
   for(int i=0;i<ArraySize(lbls);i++)
      if(ObjectFind(0,lbls[i])>=0)
         ObjectSetInteger(0,lbls[i],OBJPROP_TIME,0,tLbl);
}

//+------------------------------------------------------------------+
//| DASHBOARD                                                       |
//+------------------------------------------------------------------+
void BuildDashboard(
   double bull,double bear,string bias,color biasC,int bS,int rS,
   double cC,double cVwap,double cRSI,double c5m,
   double cMm,double cMs,double cADX,double cE9,double cE21,
   double cATR,long cVol,double cVolMA,double cO)
{
   int X=12,Y=14,W=280,H=22,sep=3;

   // Title
   MakeRect(D+"T_BG", X,Y,W,26,C'5,8,25',C_GOLD);
   MakeTxt (D+"T_TX", X+(W/2)-55, Y+4,"SNIPER PRO", C_GOLD, 10,"Arial Bold");
   ObjectDelete(0,D+"T_AU");
   Y+=29;

   // Bull/Bear
   int hw=(W/2)-1;
   MakeRect(D+"BS_BG",X,      Y,hw,  H,C_BULL_BG,C_GREEN);
   MakeTxt (D+"BS_TX",X+8,    Y+4,"BULL "+IntegerToString((int)bull)+"% ("+IntegerToString(bS)+"/7)",C_GREEN,7,"Arial Bold");
   MakeRect(D+"BR_BG",X+hw+2, Y,hw,  H,C_BEAR_BG,C_RED);
   MakeTxt (D+"BR_TX",X+hw+8, Y+4,"BEAR "+IntegerToString((int)bear)+"% ("+IntegerToString(rS)+"/7)",C_RED,  7,"Arial Bold");
   Y+=H+sep;

   // Trend bar
   int barW=W-2;
   int fillW=(int)MathRound((bull/100.0)*barW);
   fillW=MathMax(3,MathMin(fillW,barW));
   int emptyW=barW-fillW;
   color barCol=bull>=60?C_GREEN:bull<=40?C_RED:C_YELLOW;
   MakeRect(D+"TM_BG",X,        Y,W,    20,C'5,8,25',  C_BORDER);
   MakeRect(D+"TM_FL",X+1,      Y+1,fillW, 18,barCol,  barCol);
   if(emptyW>0)
   MakeRect(D+"TM_EM",X+1+fillW,Y+1,emptyW,18,C'20,24,44',C'20,24,44');
   MakeTxt (D+"TM_LB",X+5,      Y+3,"TREND STRENGTH",C_GRAY,7,"Arial Bold");
   MakeTxt (D+"TM_PC",X+W-40,   Y+3,IntegerToString((int)bull)+"%",C_WHITE,7,"Arial Bold");
   Y+=22+sep;

   // Bias
   MakeRect(D+"MB_BG",X,Y,W,H+2,C_HEADER,biasC);
   MakeTxt (D+"MB_LB",X+6, Y+3,"BIAS:", C_GRAY,8,"Arial");
   MakeTxt (D+"MB_VL",X+60,Y+1,bias,    biasC, 9,"Arial Bold");
   Y+=H+4;

   // Session pills (no header row)
   MqlDateTime gdt; TimeToStruct(TimeGMT(),gdt);
   int gh=gdt.hour;
   bool asianOn  = InpAsian   && (gh>=0  && gh<8);
   bool londonOn = InpLondon  && (gh>=8  && gh<17);
   bool nyOn     = InpNewYork && (gh>=13 && gh<22);
   ObjectDelete(0,D+"SS_BG"); ObjectDelete(0,D+"SS_HD"); ObjectDelete(0,D+"SS_TM");
   int pw=(W-8)/3;
   int px=X;
   color asC=InpAsian?(asianOn?C_GREEN:C_GRAY):C'40,40,40';
   MakeRect(D+"SA_BG",px,Y,pw,H-2,asianOn?C'0,60,30':C'20,24,40',asC);
   MakeTxt (D+"SA_TX",px+6,Y+3,(asianOn?"● ":"○ ")+"ASIAN",asC,7,"Arial Bold");
   px+=pw+4;
   color ldC=InpLondon?(londonOn?C_GREEN:C_GRAY):C'40,40,40';
   MakeRect(D+"SL_BG",px,Y,pw,H-2,londonOn?C'0,60,30':C'20,24,40',ldC);
   MakeTxt (D+"SL_TX",px+6,Y+3,(londonOn?"● ":"○ ")+"LONDON",ldC,7,"Arial Bold");
   px+=pw+4;
   color nyC=InpNewYork?(nyOn?C_GREEN:C_GRAY):C'40,40,40';
   MakeRect(D+"SN_BG",px,Y,pw,H-2,nyOn?C'0,60,30':C'20,24,40',nyC);
   MakeTxt (D+"SN_TX",px+6,Y+3,(nyOn?"● ":"○ ")+"NY",nyC,7,"Arial Bold");
   Y+=H+sep;

   // Separator
   MakeRect(D+"SP1",X,Y,W,2,C_BORDER,C_BORDER);
   Y+=4;

   // Column headers
   MakeRect(D+"CH_1",X,      Y,hw,  H-2,C_HEADER,C_BORDER);
   MakeTxt (D+"CH_L1",X+8,   Y+4,"INDICATOR",   C_YELLOW,7,"Arial Bold");
   MakeRect(D+"CH_2",X+hw+2, Y,hw,  H-2,C_HEADER,C_BORDER);
   MakeTxt (D+"CH_L2",X+hw+10,Y+4,"STATUS/VALUE",C_YELLOW,7,"Arial Bold");
   Y+=H;

   // Data rows
   string vwapS=cC>cVwap?"▲ ABOVE":"▼ BELOW"; color vwapC=cC>cVwap?C_GREEN:C_RED;
   string rsiS=DoubleToString(cRSI,1);          color rsiC=cRSI>70?C_RED:cRSI<30?C_GREEN:cRSI>50?C_GREEN:C_RED;
   MakeDataRow(D+"R0",X,Y,W,H,"VWAP",vwapS,vwapC,"RSI 14",rsiS,rsiC);
   Y+=H+sep;

   string macdS=cMm>cMs?"▲ BULL":"▼ BEAR"; color macdC=cMm>cMs?C_GREEN:C_RED;
   string emaS =cE9>cE21?"▲ BULL":"▼ BEAR"; color emaC =cE9>cE21?C_GREEN:C_RED;
   MakeDataRow(D+"R1",X,Y,W,H,"MACD",macdS,macdC,"EMA X",emaS,emaC);
   Y+=H+sep;

   string adxS=DoubleToString(cADX,1)+(cADX>25?" STR":" WEK"); color adxC=cADX>25?C_GREEN:C_ORANGE;
   string volS=cVol>cVolMA?"▲ HIGH":"▼ LOW";                    color volC=cVol>cVolMA?C_GREEN:C_GRAY;
   MakeDataRow(D+"R2",X,Y,W,H,"ADX",adxS,adxC,"VOL",volS,volC);
   Y+=H+sep;

   string r5S=DoubleToString(c5m,1)+(c5m>50?" ▲":" ▼"); color r5C=c5m>50?C_GREEN:C_RED;
   string atrS=DoubleToString(cATR,_Digits>3?5:2);
   MakeDataRow(D+"R3",X,Y,W,H,"RSI 5m",r5S,r5C,"ATR",atrS,C_CYAN);
   Y+=H+sep;

   // Filter status
   if(InpUseFilter)
   {
      string ftxt="FILTER ON: Need "+IntegerToString(InpMinScore)+"/7  |  Bull:"+IntegerToString(bS)+"  Bear:"+IntegerToString(rS);
      color  fc=(bS>=InpMinScore||rS>=InpMinScore)?C_GREEN:C_ORANGE;
      MakeRect(D+"FT_BG",X,Y,W,H,C_PANEL,fc);
      MakeTxt (D+"FT_TX",X+8,Y+6,ftxt,fc,7,"Arial Bold");
      Y+=H+sep;
   }

   // Separator
   MakeRect(D+"SP2",X,Y,W,2,C_BORDER,C_BORDER);
   Y+=4;

   // Signal bar
   string sigTxt=gSig==1?"▲  BUY SIGNAL ACTIVE":gSig==-1?"▼  SELL SIGNAL ACTIVE":"—  WAITING FOR SIGNAL";
   color  sigBg =gSig==1?C'0,100,50':gSig==-1?C'110,25,25':C'25,28,50';
   color  sigBd =gSig==1?C_GREEN:gSig==-1?C_RED:C_BORDER;
   color  sigTc =gSig==1?C_GREEN:gSig==-1?C_RED:C_GRAY;
   MakeRect(D+"SG_BG",X,Y,W,H+4,sigBg,sigBd);
   MakeTxt (D+"SG_TX",X+8,Y+5,sigTxt,sigTc,9,"Arial Bold");

   // Delete all panels that used to appear below the signal bar
   string toDelete[]={D+"RR_BG",D+"RR_TX",
                      D+"PT_BG",D+"PT_IC",D+"PT_TX",
                      D+"LS_BG",D+"LS_TX",
                      D+"ES_BG",D+"ES_EN",D+"ES_SL",
                      D+"TP_BG1",D+"TP_1",D+"TP_2",D+"TP_3",
                      D+"TP_BG2",D+"TP_4",D+"TP_5"};
   for(int i=0;i<ArraySize(toDelete);i++) ObjectDelete(0,toDelete[i]);
}

//+------------------------------------------------------------------+
void MakeDataRow(string id,int x,int y,int w,int h,
                 string lbl1,string val1,color col1,
                 string lbl2,string val2,color col2)
{
   int half=(w/2)-1;
   MakeRect(id+"_BG1",x,        y,half,h,C_PANEL,C_BORDER);
   MakeTxt (id+"_L1", x+8,        y+5,lbl1,C_GRAY,7,"Arial");
   MakeTxt (id+"_V1", x+half-60,  y+5,val1,col1,  7,"Arial Bold");
   MakeRect(id+"_BG2",x+half+2, y,half,h,C_PANEL,C_BORDER);
   MakeTxt (id+"_L2", x+half+10,  y+5,lbl2,C_GRAY,7,"Arial");
   MakeTxt (id+"_V2", x+w-60,     y+5,val2,col2,  7,"Arial Bold");
}

//+------------------------------------------------------------------+
void MakeRect(string name,int x,int y,int w,int h,color bg,color border)
{
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,  x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,      w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,      h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,    bg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,      border);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0,name,OBJPROP_BACK,       false);
}

//+------------------------------------------------------------------+
void MakeTxt(string name,int x,int y,string txt,color col,int sz,string font)
{
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     col);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,  sz);
   ObjectSetString (0,name,OBJPROP_FONT,      font);
   ObjectSetString (0,name,OBJPROP_TEXT,      txt);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,      false);
}

//+------------------------------------------------------------------+
void DrawLevels()
{
   string del[]={P+"ENTRY",P+"SL",P+"TP1",P+"TP2",P+"TP3",P+"TP4",P+"TP5",
                 P+"L_ENTRY",P+"L_SL",P+"L_TP1",P+"L_TP2",P+"L_TP3",P+"L_TP4",P+"L_TP5"};
   for(int i=0;i<ArraySize(del);i++) ObjectDelete(0,del[i]);

   datetime tEnd=TimeCurrent()+PeriodSeconds()*5000;
   MakeLine(P+"ENTRY",gEntry,C_BLUE,      STYLE_SOLID,2,tEnd);
   MakeLine(P+"SL",   gSL,   C_RED,       STYLE_SOLID,2,tEnd);
   MakeLine(P+"TP1",  gTP1,  C_GREEN,     STYLE_DASH, 1,tEnd);
   MakeLine(P+"TP2",  gTP2,  C_GREEN,     STYLE_DASH, 1,tEnd);
   MakeLine(P+"TP3",  gTP3,  C_GREEN,     STYLE_DASH, 1,tEnd);
   MakeLine(P+"TP4",  gTP4,  C'0,200,90', STYLE_SOLID,2,tEnd);
   MakeLine(P+"TP5",  gTP5,  C'0,160,70', STYLE_SOLID,2,tEnd);

   datetime tLbl=TimeCurrent()+PeriodSeconds()*2;
   MakeChartTxt(P+"L_ENTRY",tLbl,gEntry,"  ENTRY "+DoubleToString(gEntry,_Digits),C_BLUE);
   MakeChartTxt(P+"L_SL",   tLbl,gSL,  "  SL    "+DoubleToString(gSL,   _Digits),C_RED);
   MakeChartTxt(P+"L_TP1",  tLbl,gTP1, "  TP1   "+DoubleToString(gTP1,  _Digits),C_GREEN);
   MakeChartTxt(P+"L_TP2",  tLbl,gTP2, "  TP2   "+DoubleToString(gTP2,  _Digits),C_GREEN);
   MakeChartTxt(P+"L_TP3",  tLbl,gTP3, "  TP3   "+DoubleToString(gTP3,  _Digits),C_GREEN);
   MakeChartTxt(P+"L_TP4",  tLbl,gTP4, "  TP4   "+DoubleToString(gTP4,  _Digits),C'0,200,90');
   MakeChartTxt(P+"L_TP5",  tLbl,gTP5, "  TP5   "+DoubleToString(gTP5,  _Digits),C'0,160,70');
}

//+------------------------------------------------------------------+
void MakeLine(string name,double price,color clr,int style,int width,datetime tEnd)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_TREND,0,gSigTime,price,tEnd,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,     style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,     width);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT, true);
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,  false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,      true);
}

//+------------------------------------------------------------------+
void MakeChartTxt(string name,datetime t,double price,string txt,color clr)
{
   if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_TEXT,0,t,price);
   ObjectSetString (0,name,OBJPROP_TEXT,      txt);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,  8);
   ObjectSetString (0,name,OBJPROP_FONT,      "Arial Bold");
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,    ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,      false);
}

//+------------------------------------------------------------------+
void HitLine(string name)
{
   if(ObjectFind(0,name)>=0)
      ObjectSetInteger(0,name,OBJPROP_COLOR,C_CYAN);
}

//+------------------------------------------------------------------+
void ClearAll()
{
   int total=ObjectsTotal(0);
   for(int i=total-1;i>=0;i--)
   {
      string nm=ObjectName(0,i);
      if(StringFind(nm,P)==0||StringFind(nm,D)==0)
         ObjectDelete(0,nm);
   }
}
//+------------------------------------------------------------------+