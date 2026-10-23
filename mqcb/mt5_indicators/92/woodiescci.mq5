//+------------------------------------------------------------------+
//|                                                   WoodiesCCI.mq5 |
//|                                        Copyright Dmitry Voronkov |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitry Voronkov"
#property link      "vdv_2001@mail.ru"
#property version   "1.00"
#property indicator_separate_window
#property indicator_maximum   300.00
#property indicator_minimum   -300.00
#property indicator_level1    50
#property indicator_level2    -50
#property indicator_level3    100
#property indicator_level4    -100
#property indicator_level5    200
#property indicator_level6    -200
#property indicator_buffers   6
#property indicator_plots     4
//#property indicator_label1    "Slow CCI HISTOGRAM"
#property indicator_type1     DRAW_COLOR_HISTOGRAM
#property indicator_color1    Silver, Gold, LightGreen, Tomato
#property indicator_width1    2
#property indicator_type2     DRAW_LINE
#property indicator_color2    Black
#property indicator_width2    1
#property indicator_type3     DRAW_LINE
#property indicator_color3    Red
#property indicator_width3    1
#property indicator_type4     DRAW_COLOR_LINE
#property indicator_color4    Green, Red
#property indicator_width4    3
input ENUM_TIMEFRAMES   InpPeriod=PERIOD_CURRENT;  // Time period
input int   InpSlowCCIPeriod=14; // Slow CCI
input int   InpFastCCIPeriod=6; // Fast CCI
input int   InpLSMAPeriod=25; // Period LSMA
input int   InpSignalBar=6;   // Bar of change of a trend
input int   InpHowLong=300;   // How many bars
//--- global variable
int        CountPeriodBar=0;
//---- indicator buffer
double   ExtSlowCCIHistogram[];
double   ExtSlowCCIHistogramColor[];
double   ExtSlowCCILine[];
double   ExtFastCCILine[];
double   ExtLSMA[];
double   ExtColorLSMA[];
//--- handles of the indicators
int      HSlowCCI;
int      HFastCCI;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtSlowCCIHistogram,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSlowCCIHistogramColor,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtSlowCCILine,INDICATOR_DATA);
   SetIndexBuffer(3,ExtFastCCILine,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLSMA,INDICATOR_DATA);
   SetIndexBuffer(5,ExtColorLSMA,INDICATOR_COLOR_INDEX);
   PlotIndexSetString(0,PLOT_LABEL,"Histogram ("+IntegerToString(InpSlowCCIPeriod)+") CCI");
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpSlowCCIPeriod-1);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpSlowCCIPeriod-1);
   PlotIndexSetString(2,PLOT_LABEL,"Turbo("+IntegerToString(InpFastCCIPeriod)+") CCI");
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpFastCCIPeriod-1);
   PlotIndexSetString(3,PLOT_LABEL,"LSMA("+IntegerToString(InpLSMAPeriod)+")");

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME,"WoodiesCCI "+PeriodToString(InpPeriod));
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---
   HSlowCCI=iCCI(NULL,InpPeriod,InpSlowCCIPeriod,PRICE_TYPICAL);
   HFastCCI=iCCI(NULL,InpPeriod,InpFastCCIPeriod,PRICE_TYPICAL);
   EventSetTimer(1);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert Timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
   long second=TimeEndOfPeriod(InpPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"WoodiesCCI "+PeriodToString(InpPeriod)+" ["+IntegerToString(second)+" sec ]");
   ChartRedraw();
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
//---
   int start_buf=0,pos=0;
   int  counter_bars=0;
   double   Buff[],price[];
   bool  fup=false, fdn=false;
   int count=BarsCalculated(HSlowCCI);
   int count_fast=BarsCalculated(HFastCCI);
   if(count<=0 || count_fast<=0)
     {
      Print("Not all data of iCCI is calculated. Error",GetLastError());
      return(0);
     }
   if(CountPeriodBar!=count || prev_calculated!=rates_total)
     {
      CountPeriodBar=count;
      if(count>rates_total){ start_buf=count-rates_total;count=rates_total;}
      if(count==rates_total) start_buf=0;
      // Quantity of bars for the analysis
      if(InpHowLong<=0) pos=count; else pos=InpHowLong;

      if(CopyBuffer(HSlowCCI,0,start_buf,count,ExtSlowCCIHistogram)<=0)
        {
         Print("Getting of iCCI data has failed! Error",GetLastError());
         return(0);
        }
      ArrayCopy(ExtSlowCCILine,ExtSlowCCIHistogram);
      if(CopyBuffer(HFastCCI,0,start_buf,count,ExtFastCCILine)<=0)
        {
         Print("Getting of iCCI data has failed! Error",GetLastError());
         return(0);
        }
      ArrayInitialize(ExtSlowCCIHistogramColor,0);
      ArrayInitialize(ExtColorLSMA,0);
     }
   else
     {
      if(CopyBuffer(HSlowCCI,0,0,1,Buff)<=0)
        {
         Print("Getting of iCCI data has failed! Error",GetLastError());
         return(0);
        }
      ExtSlowCCIHistogram[rates_total-1]=Buff[0];
      ExtSlowCCILine[rates_total-1]=ExtSlowCCIHistogram[rates_total-1];
      if(CopyBuffer(HFastCCI,0,0,1,Buff)<=0)
        {
         Print("Getting of iCCI data has failed! Error",GetLastError());
         return(0);
        }
      ExtFastCCILine[rates_total-1]=Buff[0];
     }
   for(int i=rates_total-pos; i<rates_total; i++)
     {
      if(ExtSlowCCIHistogram[i-1]*ExtSlowCCIHistogram[i]<0)
         counter_bars=1;
      else
         counter_bars++;
      if(counter_bars==InpSignalBar-1)ExtSlowCCIHistogramColor[i]=1;
      if(counter_bars>=InpSignalBar && ExtSlowCCIHistogram[i]>0)
         ExtSlowCCIHistogramColor[i]=2;
      if(counter_bars>=InpSignalBar && ExtSlowCCIHistogram[i]<0)
         ExtSlowCCIHistogramColor[i]=3;
     }
   int close_count=CopyClose(NULL,InpPeriod,0,pos+InpLSMAPeriod,price);
   if(close_count<=0)
     {
      Print("Getting Close data has failed! Error",GetLastError());
      return(0);
     }
   for(int i=1; i<pos; i++)
     {
      double tmp=CalcLsma(close_count-i,InpLSMAPeriod,price);
      if(price[close_count-i]==tmp) ExtColorLSMA[rates_total-i]=ExtColorLSMA[rates_total-i-1];
      if(price[close_count-i]>tmp) ExtColorLSMA[rates_total-i]=0;
      if(price[close_count-i]<tmp) ExtColorLSMA[rates_total-i]=1;

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Function will transform time period to string value              |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   ENUM_TIMEFRAMES tmp;
   if(period==PERIOD_CURRENT) tmp=_Period; else tmp=period;
   switch(tmp)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M2: return("M2");
      case PERIOD_M3: return("M3");
      case PERIOD_M4: return("M4");
      case PERIOD_M5: return("M5");
      case PERIOD_M6: return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H2: return("H2");
      case PERIOD_H3: return("H3");
      case PERIOD_H4: return("H4");
      case PERIOD_H6: return("H6");
      case PERIOD_H8: return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1: return("Daily");
      case PERIOD_W1: return("Weekly");
      case PERIOD_MN1: return("Monthly");
     }
   return(NULL);
  };
//+-------------------------------------------------------------------+
//| The function returnes time remaining for the close of a period    |
//+-------------------------------------------------------------------+
datetime TimeEndOfPeriod(ENUM_TIMEFRAMES _TimePeriod)
  {
   datetime tmpDateTime;
   int tmp;
   MqlDateTime last_time;
   TimeToStruct(TimeTradeServer(),last_time);
   last_time.sec=0;
   if(_TimePeriod<=PERIOD_H1)
     {
      tmp=(PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_M1));
      tmp=last_time.min/tmp;
      last_time.min=(tmp+1)*PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_M1);
     }
   else
   if(_TimePeriod>PERIOD_H1 && Period()<=PERIOD_D1)
     {
      tmp=(PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_H1));
      tmp=last_time.hour/tmp;
      last_time.hour=(tmp+1)*PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_H1);
      last_time.min=0;
     }
   tmpDateTime=StructToTime(last_time);
   tmpDateTime=tmpDateTime-TimeTradeServer();
   return(tmpDateTime);
  }
//+------------------------------------------------------------------+
//| Calculation of LSMA                                              |
//+------------------------------------------------------------------+
double CalcLsma(const int index,int period,const double &price[])
  {
   double sum=0;
   for(int i=1;i<=period;i++)
     {
      double tmp=i-(period+1)/3.0;
      sum+=(tmp*price[index-period+i])*6;
     }
   return(sum/(period*(period+1)));
  }
//+------------------------------------------------------------------+
