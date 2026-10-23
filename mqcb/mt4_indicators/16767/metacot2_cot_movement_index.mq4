//+------------------------------------------------------------------+
//|                                   MetaCOT 2 - Movement Index.mq4 |
//|                                  Copyright 2018, Vasiliy Sokolov |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "MetaCOT® 2009-2018, Vasiliy Sokolov, St.-Petersburg, Russia"
#property link      "https://www.mql5.com/en/articles/1573"
#include <MetaCOT\Version.mqh>
#property version   VERSION
#property description "MetaCOT 2 is designed for analize CFTC reports, data mining and for fundamental analysis."
#property description "See article 'MetaCOT Project - New horizons for CFTC report analysis in MetaTrader 4'"
#property description "\nFor work this indicator need download and install 'MetaCOT -  Install CFTC reports' tool."
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color1   clrRed
#property indicator_color2   clrSlateGray
#property icon "\\Images\\MetaCOT\\MetaCOT_COT_Movement_Index.ico"
#property strict

#include <MetaCot\Enums.mqh>
#include <MetaCOT\ToolBox.mqh>

const ENUM_CFTC_REPORT        ReportType = CFTC_COT;
CftcReportInfo                ReportInfo;
input ENUM_COT_SOURCE         Source = FUTURES_AND_OPTIONS;          // Source of Report
input ENUM_COT_NETTO_GROUP    Group = COT_NETTO_OPERATORS;           // Group of Traders
input int                     CotPeriod = 52;                        // Period of COT Index
input int                     DiffLag = 6;                           // Movement Period
input int                     CriticalValue = 40;                    // Critical Value
input ENUM_MOVMENT_TYPE       MovType = MOVMENT_ON_COT_INDEX;        // Movement Type
input string                  ProffSettings = "";                    // #      PROFESSIONAL SETTINGS:    #
input ENUM_COT_SUBGROUP       SubGroup = COT_SUBGROUP_ALL;           // Subgroup of Traders
input ENUM_COT_DATA_TYPE      DateType = COT_DATA_FUTURES;           // Data Type
input ENUM_COT_RELEASE_DAY    ReleaseDay = COT_RELEASE_FRIDAY;       // Release Day
input bool                    AutoDetectReport = true;               // Auto Detect Report Name
input string                  LoadReportName =                                
                              "# BRITISH POUND STERLING - CONCATENATE";    // Report Name (If Auto Detect=false)
input bool                    Mirror = false;                        // Mirror Mode
input bool                    NotShowContinuesData = false;          // Not Show Continues Data
input bool                    AutoUpdate = true;                     // Auto Update

double                        cot_values[];
double                        limit_values[];
double                        cvalues[];
datetime                      ctimes[];
int                           cindex = 0;
int                           prev_total = 0;
datetime                      last_knowing_date = 0;
int                           Sign = 1;
int                           critv = 40;
CotBaseSettings               CftcSet;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{  
   SendOnInit();
   // -- initialize -- //
   if(!AutoDetectReport || !GetCftcReportInfo(Symbol(), ReportType, ReportInfo))
   {
      ReportInfo.reverse = Mirror;
      ReportInfo.report_name = LoadReportName;
      ReportInfo.short_name = LoadReportName;
   }
   if(DateType == COT_DATA_NUMBERS_TRADES &&
     (Group == COT_NETTO_NONREPORTABLE))
   {
      printf("Incorrect combination of parameters");
      return (INIT_PARAMETERS_INCORRECT);
   }
   critv = CriticalValue;
   if(critv > 100)
      critv = 100;
   if(critv < 0)
      critv = 0;
   Sign = Mirror ? -1 : 1;
   EventSetTimer(5);
   SetIndexBuffer(0, cot_values, INDICATOR_DATA);
   SetIndexBuffer(1, limit_values, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetInteger(INDICATOR_LEVELS, 4);
   
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 100.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, critv);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 2, (-1)*critv);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 3, -100.0);
   // -- Config base parameters -- //   
   CftcSet.source = Source;
   CftcSet.subgroup = SubGroup;
   CftcSet.report_name = ReportInfo.report_name;
   CftcSet.date_type = DateType;
   CftcSet.release_day = ReleaseDay;
   
   string mmode = Mirror ? " (Mirror mode)," : ",";
   IndicatorSetString(INDICATOR_SHORTNAME, MC_LABEL + " Mov.Index, " +
                      ReportInfo.short_name + " (" + (string)CotPeriod + "," + (string)DiffLag +  ") " + EnumCotNetGroupToString(Group) + mmode);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // размер входных таймсерий 
                 const int prev_calculated,  // обработано баров на предыдущем вызове 
                 const datetime& time[],     // Time 
                 const double& open[],       // Open 
                 const double& high[],       // High 
                 const double& low[],        // Low 
                 const double& close[],      // Close 
                 const long& tick_volume[],  // Tick Volume 
                 const long& volume[],       // Real Volume 
                 const int& spread[]         // Spread 
   )
{
   ArraySetAsSeries(cot_values, false);
   ArraySetAsSeries(limit_values, false);
   ArraySetAsSeries(time, false);
   bool need_full_recalc = false;
   int limit = prev_calculated;
   if(LastKnowingDate() > last_knowing_date || prev_calculated == 0)
   {
      if(MovType == MOVMENT_ON_COT_INDEX)
         GetCotIndexValues(CftcSet, CotPeriod, Group, ctimes, cvalues);
      else
         GetCotWillcoValues(CftcSet,CotPeriod, Group, ctimes, cvalues);
      last_knowing_date = LastKnowingDate();
      need_full_recalc = true;
   }
   else if(rates_total - prev_calculated > 1 && NeedFullRecalc())
   {
      if(MovType == MOVMENT_ON_COT_INDEX)
         GetCotIndexValues(CftcSet, CotPeriod, Group, ctimes, cvalues);
      else
         GetCotWillcoValues(CftcSet,CotPeriod, Group, ctimes, cvalues);
      if(ArraySize(cvalues) >= prev_total)
         need_full_recalc = true;
   }
   int total = ArraySize(cvalues);
   if(total == 0)
      return rates_total;
   if(need_full_recalc)
   {
      cindex = 0;
      limit = 0;
      prev_total = total;
   }
   for(int i = limit; i < rates_total; i++)
   {
      if(ctimes[cindex] > time[i])
      {
         cot_values[i] = EMPTY_VALUE;
         continue;
      }
      while(cindex+1 < total && time[i]+PeriodSeconds() >= ctimes[cindex+1])  
        cindex++;
      if(cindex < DiffLag)
         cindex = DiffLag;
      double prev_value = cvalues[cindex-DiffLag];
      double value = 0.0;
      value = cvalues[cindex]-prev_value;
      if(!Mirror)
         cot_values[i] = value;
      else
         cot_values[i] = value * (-1);
      if(i > 0 && cot_values[i-1] == EMPTY_VALUE)
         cot_values[i-1] = cot_values[i];
      int sign =  cot_values[i] >= 0 ? 1 : (-1);
      if(MathAbs(cot_values[i]) > critv)
         limit_values[i] = critv*sign;
      else
         limit_values[i] = cot_values[i];
   }
   //-- trim last values if 'NotShowContinuesData' is enable
   datetime last_t = ctimes[cindex];
   for(int i = rates_total-1; i >= 0 && NotShowContinuesData; i--)
   {
      if(time[i] > last_t)
      {
         limit_values[i] = EMPTY_VALUE;
         cot_values[i] = EMPTY_VALUE;
      }
      else
         break;
   }
   return rates_total-1;
}
//+------------------------------------------------------------------+
//| This function using for blocking full recalculation of indicator |
//| in strategy tester.                                              |  
//+------------------------------------------------------------------+
bool NeedFullRecalc()
{
   if(!IsTesting())
      return true;
   if(NotShowContinuesData)
      return true;
   return false;
}
//+------------------------------------------------------------------+
//| Auto update CFTC reports by timer                                |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(AutoUpdate)
      UpdateReportsByTimer();
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   SendOnChartEvent(id, lparam, dparam, sparam);
}