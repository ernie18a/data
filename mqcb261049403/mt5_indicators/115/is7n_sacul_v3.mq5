//+------------------------------------------------------------------+
//|                                                iS7N_SacuL_v3.mq5 |
//|                                       Copyright 2010, SHOOTER777 |
//|                                                      s7n@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, SHOOTER777"
#property link      "s7n@mail.ru"
#property version   "3.00"
#property description "Arrows & curves type indicator"
#property description "The 'iS7N_SacuL.mq5' indicator is based on the"
#property description "original indicator 'Lucas1.mq4', written in MT4"
#property description "Copyright © 2007, lukas1"
#property description "http://www.alpari-idc.ru/"
/*//--- Changes:
        It's designed for work with MetaTrader 5
        The iMx parameter is used to limit the number of bars       
        Due to calculation technique of the 1st,2nd and 5th buffer, 
        it recalculates iMn bars, 10 periods of the indicator.
        The input parameter bool bExp = false; - is used only if the indicator is called from the Expert Advisors
        it's false by default, buy it should be set to true if the indicator is called from the Expert Advisors
*/
#property indicator_applied_price PRICE_CLOSE
#property indicator_chart_window
//---- 
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
//---- 
#property indicator_label1  "iSacuL_UP_Arrow"
#property indicator_label2  "iSacuL_DN_Arrow"
#property indicator_label3  "iSacuL_UP_Line"
#property indicator_label4  "iSacuL_DN_Line"
#property indicator_label5  "iSacuL_Trend"
//----
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
//----
#property indicator_color1  Red
#property indicator_color2  Green
#property indicator_color3  Gray
#property indicator_color4  Gray
#property indicator_width1  3
#property indicator_width2  3
#property indicator_width3  2
#property indicator_width4  2
//--- 
input int Per =  7;
input int Pro = 25;

input bool bExp=false;
//input bool bExp = true;
// this parameter is used 
// for the forced recalculation iMn = 10*Per during the initialization; 
//when this indicator is called from the external expert advisors

//input 
int iMx=500; // number of bars to calculate

//--- 
double dBuf_1[];     // "up" arrows buffer
double dBuf_2[];     // "down" arrows buffer
double dBuf_3[];     // upper channel buffer
double dBuf_4[];     // lower channel buffer
double dBuf_5[];     // trend direction buffer
//---
double dBuf_Hi[];    // buffer for Hi
double dBuf_Lo[];    // buffer for Lo
//--- 
int ihHiA;
int ihLoA;
int ihHiL;
int ihLoL;
//--- 
//static 
bool   bUp,bOld;
string sSmbl;
//string sSmbl = "EURUSD";
string sShNm;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   sSmbl=_Symbol;
//---
   SetIndexBuffer(0,dBuf_1);
   SetIndexBuffer(1,dBuf_2);
   SetIndexBuffer(2,dBuf_3);
   SetIndexBuffer(3,dBuf_4);
   SetIndexBuffer(4,dBuf_5);
//---
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//----
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits-1);
//----
   IndicatorSetString(INDICATOR_SHORTNAME,sShNm);
//----
   PlotIndexSetString(0,PLOT_LABEL,"UP_Arrow");
   PlotIndexSetString(1,PLOT_LABEL,"DN_Arrow");
   PlotIndexSetString(2,PLOT_LABEL,"UP_Line");
   PlotIndexSetString(3,PLOT_LABEL,"DN_Line");
   PlotIndexSetString(4,PLOT_LABEL,"Trend_Arrow");
//---
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
///----
   if(prev_calculated>0)
     {
      if(rates_total<=prev_calculated)
         return(rates_total);
     }
//--
   double dHiA,dLoA;
   double dMax,dMin;
//---\/
// Define the indicator output with different colors
// depending on value of Pro parameter
   if(Pro<=0)
     {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,Blue);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,Blue);
     }
   else
     {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,Gray);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,Gray);
     }
//---/\
// ===At first call of the indicator we fill all the buffers with empty values :)
   if(prev_calculated<=0)// check for the first call 
     {
      for(int i=0;i<=rates_total-1;i++)
        {
         dBuf_1[i]=EMPTY_VALUE;
         dBuf_2[i]=EMPTY_VALUE;
         dBuf_3[i]=EMPTY_VALUE;
         dBuf_4[i]=EMPTY_VALUE;
         dBuf_5[i]=EMPTY_VALUE;
        }
      Print("!!!All buffer arrays has been filled with empty values!!!");
     }
//===
// we need the iMn bars available in the history
   int iMn = 10*Per;                   // The mininal number of bars needed
   if(iMn>rates_total)return(0);       // return if we haven't iMn bars
   if(iMn>iMx) iMx=iMn;               // if the minimal is greater than specified, lets calculate minimal.
   if(iMx>rates_total)iMx=rates_total; // if specified is greater than available, lets calculate all available.
//---
//---
   int limit;
   int preMx=1;
   if(bExp) preMx=iMn;
   if(prev_calculated<=0)// check for the first call of the indicator
     {limit=rates_total-iMx;}
   else
     {
      limit=prev_calculated-preMx;
     }
//---
   for(int i=limit; i>0; i--)
     {
      if( dBuf_2[i]>0 )  {bOld = false;break;}
      if( dBuf_1[i]>0 )  {bOld = true; break;}
     }
//---
//=== MAIN CYCLE
   for(int iii=limit;iii<=rates_total;iii++)
     {
      ihHiA=CopyHigh(sSmbl,_Period,rates_total-iii-1,Per,dBuf_Hi);
      if(ihHiA<=0) break;
      else
         dHiA=dBuf_Hi[ArrayMaximum(dBuf_Hi,0,WHOLE_ARRAY)];
      //---
      ihLoA=CopyLow(sSmbl,_Period,rates_total-iii-1,Per,dBuf_Lo);
      if(ihLoA<=0) break;
      else
         dLoA=dBuf_Lo[ArrayMinimum(dBuf_Lo,0,WHOLE_ARRAY)];
      //---
      dMax = dHiA - (dHiA - dLoA)*Pro / 100; // 
      dMin = dLoA + (dHiA - dLoA)*Pro / 100; // 

      //---

      if(price[iii]<dMin) // 
        {
         bUp=false;
        }
      if(price[iii]>dMax) // 	
        {
         bUp=true;
        }
      //---
      dBuf_5[iii]=bUp;

      if(bUp!=bOld && bUp==false && iii!=rates_total-1)
        {
         dBuf_2[iii]=dHiA; //
        }
      if(bUp!=bOld && bUp==true && iii!=rates_total-1)
        {
         dBuf_1[iii]=dLoA; //
        }

      bOld=bUp;

      dBuf_3[iii]=dMax;
      dBuf_4[iii]=dMin;

      dBuf_1[limit+1]=EMPTY_VALUE;
      dBuf_2[limit+1]=EMPTY_VALUE;
      dBuf_1[limit]=EMPTY_VALUE;
      dBuf_2[limit]=EMPTY_VALUE;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
