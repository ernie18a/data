//+------------------------------------------------------------------+
//|                                                    NonLagRSI.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp. ~ By 3rjfx ~ Created: 04/04/2020"
#property link        "https://forge.mql5.io"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
#property description "Non Lag Relative Strength Index"
#property description "Eliminates unnecessary preliminary calculations on the built-in RSI"
#property strict
//--
/** Update_01: 27/11/2023 **/
//--
//--- indicator settings
#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_level1     30
#property indicator_level2     50
#property indicator_level3     70
#property indicator_buffers    5
#property indicator_plots      1
#property indicator_type1      DRAW_LINE
#property indicator_color1     clrRed
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_SOLID
//--
//--- input parameters
input int          InpPeriodRSI = 14;             // Period
input ENUM_APPLIED_PRICE eprice = PRICE_WEIGHTED; // Calculation Price
//--
//--- indicator buffers
double    ExtRSIBuffer[];
double    ExtPosBuffer[];
double    ExtNegBuffer[];
double    diffup[];
double    diffdn[];
//--
//--- global variable
int       ExtPeriodRSI;
#define DATA_LIMIT  125
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input
   if(InpPeriodRSI<1)
     {
      ExtPeriodRSI=14;
      Print("Incorrect value for input variable InpPeriodRSI =",InpPeriodRSI,
            "Indicator will use value =",ExtPeriodRSI,"for calculations.");
     }
   else ExtPeriodRSI=InpPeriodRSI;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtPosBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtNegBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,diffup,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,diffdn,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtPeriodRSI);
   //--
   string nameadd="";
   switch(eprice)
     {
       case PRICE_CLOSE:    nameadd="Close price";     break;
       case PRICE_OPEN:     nameadd="Open price";      break;
       case PRICE_HIGH:     nameadd="High price";      break;
       case PRICE_LOW:      nameadd="Low price";       break;
       case PRICE_MEDIAN:   nameadd="Median price";    break;
       case PRICE_TYPICAL:  nameadd="Typical price";   break;
       case PRICE_WEIGHTED: nameadd="Average price";   break;
     }
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"NonLagRSI("+string(ExtPeriodRSI)+"-"+nameadd+")");
   //--
   return(INIT_SUCCEEDED);
//--- initialization done
  }
//---------//
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //--
   PrintFormat("%s: Deinitialization reason code=%d",__FUNCTION__,reason);
   Print(getUninitReasonText(reason));
   ObjectsDeleteAll(0,-1,-1);
   //--
   return;
//---
  }
//---------//
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
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
    int limit,pos;
    double diff=0.0;
//--- check for rates total
   if(rates_total<DATA_LIMIT)
      return(0); 
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(limit==0) limit=ExtPeriodRSI+3;
   if(limit<ExtPeriodRSI) limit=ExtPeriodRSI+3;
   if(prev_calculated>0) limit++;
   if(limit>rates_total) limit=rates_total;
   //--
   ArrayResize(ExtRSIBuffer,rates_total,rates_total);
   ArrayResize(ExtPosBuffer,rates_total,rates_total);
   ArrayResize(ExtNegBuffer,rates_total,rates_total);
   ArrayResize(diffup,rates_total,rates_total);
   ArrayResize(diffdn,rates_total,rates_total);
   //---
//--- the main loop of calculations
   pos=ExtPeriodRSI+1;
   for(int i=pos; i<rates_total; i++)
     {
       diff=0.0;
       switch(eprice)
         {
           case PRICE_CLOSE:    diff=close[i]-close[i-1];                                                                        break;
           case PRICE_OPEN:     diff=open[i]-open[i-1];                                                                          break;
           case PRICE_HIGH:     diff=high[i]-high[i-1];                                                                          break;
           case PRICE_LOW:      diff=low[i]-low[i-1];                                                                            break;
           case PRICE_MEDIAN:   diff=((high[i]+low[i])/2.0)-((high[i-1]+low[i-1])/2.0);                                          break;
           case PRICE_TYPICAL:  diff=((high[i]+low[i]+close[i])/3.0)-((high[i-1]+low[i-1]+close[i-1])/3.0);                      break;
           case PRICE_WEIGHTED: diff=((high[i]+low[i]+close[i]+close[i])/4.0)-((high[i-1]+low[i-1]+close[i-1]+close[i-1])/4.0);  break;
           
         }
       //--
       diffup[i]=diff>0.0 ? diff : 0.0;
       diffdn[i]=diff<0.0 ? -diff : 0.0;
       //--
       ExtPosBuffer[i]=((ExtPosBuffer[i-1]*(ExtPeriodRSI-1))+(diffup[i]))/ExtPeriodRSI;
       ExtNegBuffer[i]=((ExtNegBuffer[i-1]*(ExtPeriodRSI-1))+(diffdn[i]))/ExtPeriodRSI;
       if(ExtNegBuffer[i]!=0.0)
          ExtRSIBuffer[i]=100.0-(100.0/(1+(ExtPosBuffer[i]/ExtNegBuffer[i])));
       else
        {
         if(ExtPosBuffer[i]!=0.0)
            ExtRSIBuffer[i]=100.0;
         else
            ExtRSIBuffer[i]=50.0;
        }
     }
   //---
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//---------//

string getUninitReasonText(int reasonCode) 
  { 
//---
   string text=""; 
   //--- 
   switch(reasonCode) 
     { 
       case REASON_PROGRAM:
            text="The EA has stopped working calling by remove function."; break;
       case REASON_REMOVE: 
            text="Program "+__FILE__+" was removed from chart"; break;
       case REASON_RECOMPILE:
            text="Program recompiled."; break;    
       case REASON_CHARTCHANGE: 
            text="Symbol or timeframe was changed"; break;
       case REASON_CHARTCLOSE: 
            text="Chart was closed"; break; 
       case REASON_PARAMETERS: 
            text="Input-parameter was changed"; break;            
       case REASON_ACCOUNT: 
            text="Account was changed"; break; 
       case REASON_TEMPLATE: 
            text="New template was applied to chart"; break; 
       case REASON_INITFAILED:
            text="The OnInit() handler returned a non-zero value."; break;
       case REASON_CLOSE: 
            text="Terminal closed."; break;
       default: text="Another reason"; break;
     } 
   //--
   return text;
//---
  } //-end getUninitReasonText()
//---------//
//+------------------------------------------------------------------+