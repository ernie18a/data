//+------------------------------------------------------------------+
//|                                                 Demand_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Demand Index by James Sibbet"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot DI
#property indicator_label1  "Demand Idx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpPeriod   =  5;    // Period
//--- indicator buffers
double         BufferDI[];
double         BufferVol[];
double         BufferBuyPres[];
double         BufferSellPres[];
double         BufferTR[];
double         BufferVolAvg[];
double         BufferWghtClose[];
//--- global variables
int            period_ind;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferVol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferBuyPres,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferSellPres,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferVolAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferWghtClose,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Demand Index ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDI,true);
   ArraySetAsSeries(BufferVol,true);
   ArraySetAsSeries(BufferBuyPres,true);
   ArraySetAsSeries(BufferSellPres,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferVolAvg,true);
   ArraySetAsSeries(BufferWghtClose,true);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ind,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-2;
      ArrayInitialize(BufferDI,EMPTY_VALUE);
      ArrayInitialize(BufferVol,0);
      ArrayInitialize(BufferBuyPres,0);
      ArrayInitialize(BufferSellPres,0);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferVolAvg,0);
      ArrayInitialize(BufferWghtClose,0);
     }
//--- Подготовка данных

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVol[i]=(double)tick_volume[i];
      BufferWghtClose[i]=(2.0*close[i]+high[i]+low[i])/4.0;
      BufferTR[i]=fmax(high[i],high[i+1])-fmin(low[i],low[i+1]);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferVolAvg[i]=(i==rates_total-period_ind-2 ? GetSMA(rates_total,i,period_ind,BufferVol) : (BufferVolAvg[i+1]*(period_ind-1.)+tick_volume[i])/period_ind);
      double AvgTR=GetSMA(rates_total,i,period_ind,BufferTR);

      if(BufferWghtClose[i]!=0 && BufferWghtClose[i+1]!=0 && AvgTR!=0 && BufferVolAvg[i]!=0)
        {
         double WtCRatio=(BufferWghtClose[i]-BufferWghtClose[i+1])/fmin(BufferWghtClose[i], BufferWghtClose[i+1]);
         double VolRatio=tick_volume[i]/BufferVolAvg[i];
         double Constant=VolRatio/exp(fmin(3.0*fabs(WtCRatio)*BufferWghtClose[i]/AvgTR,88.0));
         
         double BuyP=0,SellP=0;
         if(WtCRatio>0)
           {
            BuyP=VolRatio;
            SellP=Constant;
           }
         else
           {
            BuyP=Constant;
            SellP=VolRatio;
           }
         BufferBuyPres[i]=(BufferBuyPres[i+1]*(period_ind-1.)+BuyP)/period_ind;
         BufferSellPres[i]=(BufferSellPres[i+1]*(period_ind-1.)+SellP)/period_ind;
         double TempDI=1,Sign=0;
         if(BufferSellPres[i]>BufferBuyPres[i])
           {
            Sign=-1;
            if(BufferSellPres[i]!=0)
               TempDI=BufferBuyPres[i]/BufferSellPres[i];
           }
         else
           {
            Sign=1;
            if(BufferBuyPres[i]!=0)
               TempDI=BufferSellPres[i]/BufferBuyPres[i];
           }
         TempDI*=Sign;

         BufferDI[i]=(TempDI<0 ? (-1.0-TempDI) : (1.0-TempDI))/Point();
        }
      else
         BufferDI[i]=0;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i] : price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
