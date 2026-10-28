//+------------------------------------------------------------------+
//|                                         SD Delete Indicators.mq5 |
//|                                                      Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
#property copyright "2017, Dina Paches"
#property link      "https://www.mql5.com/ru/users/dipach"
#property version   "1.008"
#property script_show_inputs
//---
#define  CHART_ID                      (0)
#define  LIMIT_CHARTS                  (100)
//---
enum enum_Sub_windows {ALL_CHARTS,ONLY_THIS_CHART,};
//---
input enum_Sub_windows i_windows=ONLY_THIS_CHART;//Delete all indicators
//+------------------------------------------------------------------+
void OnStart()
  {
   if(i_windows==ONLY_THIS_CHART){ActionsOnTheChart(CHART_ID);}
   else{ActionsOnAllCharts();}
//---
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void ActionsOnAllCharts()
  {
   long chart_id =CHART_ID;
   bool res      =true;
//--- 
   for(int i=0;i<LIMIT_CHARTS && !IsStopped();i++)
     {
      chart_id=(i==0) ? ChartFirst() : ChartNext(chart_id);
      //---
      if(chart_id<0){break;}
      //---
      res=ActionsOnTheChart(chart_id);
      //---
      if(!res){break;}
     }
//---
   return;
  }
//+------------------------------------------------------------------+ 
bool ActionsOnTheChart(const long chart_id)
  {
   int sub_windows_total =-1;
   int indicators_total  =0;
//---
   if(!ChartWindowsTotal(chart_id,sub_windows_total)){return(false);}
//---
   for(int i=sub_windows_total-1;i>=0;i--)
     {
      indicators_total=ChartIndicatorsTotal(chart_id,i);
      //---
      if(indicators_total>0){ChIndicatorsDelete(chart_id,i,indicators_total);}
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool ChartWindowsTotal(const long chart_ID,int &sub_windows_total)
  {
   long value=-1;
//---
   if(!ChartGetInteger(chart_ID,CHART_WINDOWS_TOTAL,0,value))
     {Print(__FUNCTION__," Error = ",GetLastError()); return(false);}
//--- 
   sub_windows_total=(int)value;
//---
   return(true);
  }
//+------------------------------------------------------------------+
void ChIndicatorsDelete(const long  chart_id,
                        const int   sub_window,
                        const int   indicators_total)
  {
   for(int i=indicators_total-1;i>=0;i--)
     {
      string indicator_name=ChartIndicatorName(chart_id,sub_window,i);
      //---
      ChIndicatorDelete(indicator_name,chart_id,sub_window);
     }
//---
   return;
  }
//+------------------------------------------------------------------+
bool ChIndicatorDelete(const string short_name,
                       const long   chart_id=0,
                       const int    sub_window=0)
  {
   bool res=ChartIndicatorDelete(chart_id,sub_window,short_name);
//---
   if(!res)
     {
      Print("Failed to delete indicator:\"",short_name,"\". Error: ",GetLastError());
      //---
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
