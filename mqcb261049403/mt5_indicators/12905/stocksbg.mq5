//+------------------------------------------------------------------+
//|                                             ShowStocksBGTest.mq5 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
//---
#include "CGOStocksContainer.mqh"
//---
input int ipt_top=0;                                                       // Top indent
input int ipt_down=20;                                                     // Bottom indent
input int ipt_scheme=0;                                                    // Color scheme
input int ipt_total=4;                                                     // Number of days to show
//---
CGOStocksContainer *m_daily_stocks;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SetPrefix(void)
  {
   string prefix="";
   int period_current=Period();
   switch(period_current)
     {
      case PERIOD_M15:
         prefix="StocksM15_"+_Symbol+"_";
         break;
      case PERIOD_M12:
         prefix="StocksM12_"+_Symbol+"_";
         break;
      case PERIOD_M10:
         prefix="StocksM10_"+_Symbol+"_";
         break;
      case PERIOD_M6:
         prefix="StocksM6_"+_Symbol+"_";
         break;
      case PERIOD_M5:
         prefix="StocksM5_"+_Symbol+"_";
         break;
      case PERIOD_M4:
         prefix="StocksM15_"+_Symbol+"_";
         break;
      case PERIOD_M3:
         prefix="StocksM3_"+_Symbol+"_";
         break;
      case PERIOD_M2:
         prefix="StocksM2_"+_Symbol+"_";
         break;
      case PERIOD_M1:
         prefix="StocksM1_"+_Symbol+"_";
         break;
     };
   return(prefix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetMultipier(void)
  {
   int period_current=Period();
   int divisor=1;
   switch(period_current)
     {
      case PERIOD_M15:
         divisor=15;
         break;
      case PERIOD_M12:
         divisor=12;
         break;
      case PERIOD_M10:
         divisor=10;
         break;
      case PERIOD_M6:
         divisor=6;
         break;
      case PERIOD_M5:
         divisor=5;
         break;
      case PERIOD_M4:
         divisor=4;
         break;
      case PERIOD_M3:
         divisor=3;
         break;
      case PERIOD_M2:
         divisor=2;
         break;
      case PERIOD_M1:
         divisor=1;
         break;
     };
   return(60/divisor);
  }
datetime DTime[];
string debug="";
bool stop_running=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
// CHART Period must be equal or less than 15 minutes
   if(Period()>PERIOD_M15)
     {
      stop_running=true;
      return(INIT_SUCCEEDED);
     }
   ArraySetAsSeries(DTime,true);
   ArrayResize(DTime,ipt_total);
//--- indicator buffers mapping
   string aPrefix=SetPrefix();
   for(int i=0;i<ipt_total;i++) DTime[i]=TimeCurrent();
   m_daily_stocks=new CGOStocksContainer(DTime,ipt_top,ipt_down,ipt_scheme,aPrefix,ipt_total);
   m_daily_stocks.SetAllStocks();
   m_daily_stocks.ReDraw();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(stop_running) return;
   string aPrefix=SetPrefix();
   m_daily_stocks.DeleteByPrefix(aPrefix);
   delete m_daily_stocks;
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
   if(stop_running) return(rates_total);
   static datetime currentBarTimeOpen=0;
   ArraySetAsSeries(time,true);
   int xdist=0;
   int ydist=0;
   long win_height=-1;
   ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,win_height);
//---
   if(currentBarTimeOpen!=time[0])
     {
      for(int i=0;i<ipt_total;i++)
        {
         currentBarTimeOpen=time[0];
         DTime[i]=time[i*(24*GetMultipier())];
        }
      m_daily_stocks.ProcessingAllStocks(DTime);
      m_daily_stocks.ReDraw();
     }
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
//---
   if(stop_running)
     {
      Alert(" Period must be equal or less than 15 minutes.");
      return;
     }
   m_daily_stocks.ProcessingAllStocks(DTime);
   m_daily_stocks.ReDraw();
  }
//+------------------------------------------------------------------+
