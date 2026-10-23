//+------------------------------------------------------------------+
//|                                            Consensus_of_Five.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Consensus of Five indicator"
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   3
//--- plot UP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NL
#property indicator_label3  "Neutral"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpUseADX         =  INPUT_YES;  // Use ADX as trend filter
input ENUM_INPUT_YES_NO InpUseDMI         =  INPUT_YES;  // Use DMI
input ENUM_INPUT_YES_NO InpUseCCI         =  INPUT_YES;  // Use CCI
input ENUM_INPUT_YES_NO InpUseMACD        =  INPUT_YES;  // Use MACD
input ENUM_INPUT_YES_NO InpUseSto         =  INPUT_YES;  // Use Stochastic
input uint              InpPeriodADX      =  14;         // ADX period
input double            InpEntryADX       =  20.0;       // ADX entry level
input double            InpExitADX        =  40.0;       // ADX exit level
input uint              InpPeriodDMI      =  14;         // DMI period
input uint              InpPeriodCCI      =  14;         // CCI period
input double            InpBuyCCI         =  0.0;        // CCI Buy level
input double            InpSellCCI        =  0.0;        // CCI Sell level
input uint              InpPeriodFastMACD =  12;         // MACD fast EMA period
input uint              InpPeriodSlowMACD =  26;         // MACD slow EMA period
input double            InpBuyMACD        =  0.0;        // MACD Buy level
input double            InpSellMACD       =  0.0;        // MACD Sell level
input uint              InpPeriodStoK     =  5;          // Stochastic %K period
input uint              InpPeriodStoD     =  3;          // Stochastic %D period
input uint              InpSlowingSto     =  3;          // Stochastic slowing
input double            InpOverboughtSto  =  80.0;       // Stochastic overbought
input double            InpOversoldSto    =  20.0;       // Stochastic oversold
//--- defines
#define   COUNT            (3)
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferNL[];
double         BufferDMIP[];
double         BufferDMIM[];
double         BufferADX[];
double         BufferCCI[];
double         BufferMACD[];
double         BufferSTOK[];
double         BufferSTOS[];
//--- global variables
struct SDataUsed
  {
   string   name;
   bool     used;
  };
SDataUsed      array_used[];
//---
string         prefix;
int            wnd;
int            UpFr;
int            DnFr;
double         lev_entry_adx;
double         lev_exit_adx;
double         lev_buy_cci;
double         lev_sell_cci;
double         lev_buy_macd;
double         lev_sell_macd;
double         overbought_sto;
double         oversold_sto;
int            period_adx;
int            period_dmi;
int            period_cci;
int            period_fast;
int            period_slow;
int            period_k;
int            period_d;
int            period_s;
int            handle_adx;
int            handle_dmi;
int            handle_cci;
int            handle_macd;
int            handle_sto;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   //---
   ArrayResize(array_used,5);
   array_used[0].name="ADX";    array_used[0].used=InpUseADX;
   array_used[1].name="DMI";    array_used[1].used=InpUseDMI;
   array_used[2].name="CCI";    array_used[2].used=InpUseCCI;
   array_used[3].name="MACD";   array_used[3].used=InpUseMACD;
   array_used[4].name="Stoch";  array_used[4].used=InpUseSto;
   //---
   SizeByScale();
   Descriptions();
   //---
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_dmi=int(InpPeriodDMI<1 ? 1 : InpPeriodDMI);
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
   period_fast=int(InpPeriodFastMACD<1 ? 1 : InpPeriodFastMACD);
   period_slow=int(InpPeriodSlowMACD==period_fast ? period_fast+1 : InpPeriodSlowMACD<1 ? 1 : InpPeriodSlowMACD);
   period_k=int(InpPeriodStoK<1 ? 1 : InpPeriodStoK);
   period_d=int(InpPeriodStoD<1 ? 1 : InpPeriodStoD);
   period_s=int(InpSlowingSto<1 ? 1 : InpSlowingSto);
   lev_entry_adx=(InpEntryADX<0 ? 0 : InpEntryADX);
   lev_exit_adx=(InpExitADX<0 ? 0 : InpExitADX);
   lev_buy_cci=InpBuyCCI;
   lev_sell_cci=InpSellCCI;
   lev_buy_macd=InpBuyMACD;
   lev_sell_macd=InpSellMACD;
   overbought_sto=(InpOverboughtSto>100 ? 100 : InpOverboughtSto<0.1 ? 0.1 : InpOverboughtSto);
   oversold_sto=(InpOversoldSto<0 ? 0 : InpOversoldSto>=overbought_sto ? overbought_sto-0.1 : InpOversoldSto);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferNL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDMIP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDMIM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferADX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMACD,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferSTOK,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferSTOS,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<COUNT; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Consensus of Five");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferNL,true);
   ArraySetAsSeries(BufferDMIP,true);
   ArraySetAsSeries(BufferDMIM,true);
   ArraySetAsSeries(BufferADX,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferMACD,true);
   ArraySetAsSeries(BufferSTOK,true);
   ArraySetAsSeries(BufferSTOS,true);
//--- create handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print(__LINE__,": The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_dmi=iADX(NULL,PERIOD_CURRENT,period_dmi);
   if(handle_dmi==INVALID_HANDLE)
     {
      Print(__LINE__,": The ADX(",(string)period_dmi,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_CLOSE);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_macd=iMACD(NULL,PERIOD_CURRENT,period_fast,period_slow,1,PRICE_CLOSE);
   if(handle_macd==INVALID_HANDLE)
     {
      Print("The iMACD(",(string)period_fast,",",(string)period_slow,",2) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sto=iStochastic(NULL,PERIOD_CURRENT,period_k,period_d,period_s,MODE_SMA,STO_LOWHIGH);
   if(handle_sto==INVALID_HANDLE)
     {
      Print("The iStochastic(",(string)period_k,",",(string)period_d,",",(string)period_s,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferNL,EMPTY_VALUE);
      ArrayInitialize(BufferDMIP,0);
      ArrayInitialize(BufferDMIM,0);
      ArrayInitialize(BufferADX,0);
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferMACD,0);
      ArrayInitialize(BufferSTOK,0);
      ArrayInitialize(BufferSTOS,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dmi,PLUSDI_LINE,0,count,BufferDMIP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dmi,MINUSDI_LINE,0,count,BufferDMIM);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_macd,MAIN_LINE,0,count,BufferMACD);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,MAIN_LINE,0,count,BufferSTOK);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sto,SIGNAL_LINE,0,count,BufferSTOS);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      //---
      char ADX=(InpUseADX ? (BufferADX[i]>lev_entry_adx && BufferADX[i]<lev_exit_adx && BufferADX[i]>BufferADX[i+1] ? 1 : -1) : 0);
      char DMI=(InpUseDMI ? (BufferDMIP[i]>BufferDMIM[i] ? 1 : -1) : 0);
      char CCI_BUY=(InpUseCCI ? (BufferCCI[i]>lev_buy_cci ? 1 : -1) : 0);
      char CCI_SELL=(InpUseCCI ? (BufferCCI[i]<lev_sell_cci ? -1 : 1) : 0);
      char MACD_BUY=(InpUseMACD ? (BufferMACD[i]>lev_buy_macd ? 1 : -1) : 0);
      char MACD_SELL=(InpUseMACD ? (BufferMACD[i]<lev_sell_macd ? -1 : 1) : 0);
      char STO_BUY=(InpUseSto ? (BufferSTOK[i]>BufferSTOS[i] && BufferSTOS[i]<overbought_sto ? 1 : -1) : 0);
      char STO_SELL=(InpUseSto ? (BufferSTOK[i]<BufferSTOS[i] && BufferSTOS[i]>oversold_sto ? -1 : 1) : 0);

      if(DMI==0 && CCI_BUY==0 && CCI_SELL==0 && MACD_BUY==0 && MACD_SELL==0 && STO_BUY==0 && STO_SELL==0)
         SettingBufferValues(0,i);
      else
        {
         SettingBufferValues(0,i);
         if((ADX==1  ||  ADX==0)
            && (DMI==1 ||  DMI==0)
            && (CCI_BUY==1 || CCI_BUY==0)
            && (MACD_BUY==1   ||  MACD_BUY==0)
            && (STO_BUY==1   ||  STO_BUY==0) )
           {
            SettingBufferValues(1,i);
           }
         if((ADX==1 || ADX==0)
            && (DMI==-1 || DMI==0)
            &&(CCI_SELL==-1 ||  CCI_SELL==0)
            && (MACD_SELL==-1 ||  MACD_SELL==0)
            &&(STO_SELL==-1 ||  STO_SELL==0))
           {
            SettingBufferValues(-1,i);
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      for(int i=0;i<COUNT;i++)
         PlotIndexSetInteger(i,PLOT_LINE_WIDTH,SizeByScale());
      Descriptions();
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SettingBufferValues(const int direction,const int shift)
  {
   switch(direction)
     {
      case 1 :
        BufferUP[shift]=0.5;
        BufferDN[shift]=BufferNL[shift]=EMPTY_VALUE;
        break;
      case-1 :
        BufferDN[shift]=0.5;
        BufferNL[shift]=BufferUP[shift]=EMPTY_VALUE;
        break;
      default:
        BufferNL[shift]=0.5;
        BufferDN[shift]=BufferUP[shift]=EMPTY_VALUE;
        break;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает размер, соответствующий масштабу                      |
//+------------------------------------------------------------------+
uchar SizeByScale(void)
  {
   uchar scale=(uchar)ChartGetInteger(0,CHART_SCALE);
   uchar size=(scale<3 ? 1 : scale==3 ? 2 : scale==4 ? 5 : 8);
   return size;
  }
//+------------------------------------------------------------------+
//| Описание                                                         |
//+------------------------------------------------------------------+
void Descriptions(void)
  {
   int x=0;
   int y=1;
   string arr_texts[]={"Up","Down","Neutral"};
   for(int i=0; i<COUNT+5; i++)
     {
      if(i<COUNT)
        {
         x=45*i+6;
         string name=prefix+"label"+(string)i;
         color clr=(color)PlotIndexGetInteger(i,PLOT_LINE_COLOR);
         Label(name,x,y,CharToString(167),16,clr,"Wingdings");
         Label(name+"_txt",x+10,y+5,arr_texts[i],10,clrGray,"Calibri");
        }
      else
        {
         int shift=(i-COUNT>3 ? 33 : 30)*(i-COUNT);
         int x1=x+80+shift;
         Label(prefix+array_used[i-COUNT].name,x1,y+5,array_used[i-COUNT].name,10,(array_used[i-COUNT].used ? clrGreen : clrSilver),"Calibri");
        }
     }
  }
//+------------------------------------------------------------------+
//| Выводит текстовую метку                                          |
//+------------------------------------------------------------------+
void Label(const string name,const int x,const int y,const string text,const int size,const color clr,const string font)
  {
   if(ObjectFind(0,name)!=wnd)
      ObjectCreate(0,name,OBJ_LABEL,wnd,0,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
//---
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
  }
//+------------------------------------------------------------------+
