//+------------------------------------------------------------------+
//|                                    Tom_Demark_Moving_Average.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "T.Demark Moving Average"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot DN
#property indicator_label2  "Down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint     InpPeriodTR =  12;   // Trend period
input uint     InpPeriodMA =  5;    // SMA period
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferTR[];
double         BufferMAH[];
double         BufferMAL[];
//--- global variables
int            period_tr;
int            period_ma;
int            handle_mah;
int            handle_mal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_tr=int(InpPeriodTR<1 ? 1 : InpPeriodTR);
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"TDemark MA ("+(string)period_tr+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferMAH,true);
   ArraySetAsSeries(BufferMAL,true);
//--- create MA's handles
   ResetLastError();
   handle_mah=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_HIGH);
   if(handle_mah==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_mal=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_LOW);
   if(handle_mal==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") by PRICE_LOW object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferMAH,0);
      ArrayInitialize(BufferMAL,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_mah,0,0,count,BufferMAH);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_mal,0,0,count,BufferMAL);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=HighestL(period_tr,i+1);
      int bl=LowestH(period_tr,i+1);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double max=low[bh];
      double min=high[bl];

      if(BufferTR[i+1]==1 || BufferTR[i+1]==-1)
         BufferTR[i]=0;
      else if(BufferTR[i+1]>1)
         BufferTR[i]=BufferTR[i+1]-1;
      else if(BufferTR[i+1]<-1)
         BufferTR[i]=BufferTR[i+1]+1;
      //---
      if(low[i]>max)
         BufferTR[i]=period_ma;
      else if(high[i]<min)
         BufferTR[i]=-1*period_ma;
      //---
      if(BufferTR[i]==period_ma)
        {
         BufferUP[i]=BufferMAL[i];
         BufferDN[i]=EMPTY_VALUE;
        }
      else if(BufferTR[i]==-period_ma)
        {
         BufferDN[i]=BufferMAH[i];
         BufferUP[i]=EMPTY_VALUE;
        }
      else if(BufferTR[i]!=0 || BufferTR[i]!=EMPTY_VALUE)
        {
         BufferUP[i]=BufferUP[i+1];
         BufferDN[i]=BufferDN[i+1];
        }
      else
        {
         BufferUP[i]=EMPTY_VALUE;
         BufferDN[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии Low           |
//+------------------------------------------------------------------+
int HighestL(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии High           |
//+------------------------------------------------------------------+
int LowestH(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
