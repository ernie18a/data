//+------------------------------------------------------------------+
//|                                          Momentum Color Fill.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright    "Alexander Piechotta (FinGeR)"
#property link         "http://www.metatrader-wiki.com/"
//---- indicator settings

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrTomato,clrMediumTurquoise
#property indicator_width1  1

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_width2  1


//---- input parameters
input int InpMomentumPeriod=14; // period
input int InpLevel=100; // level line

//---- indicator buffers
double    ExtMomentumBuffer[];
double    ExtMomentumBuffer2[];
double    ExtMomentumBuffer3[];

//--- global variable
int       ExtMomentumPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpMomentumPeriod<0)
     {
      ExtMomentumPeriod=14;
      Print("Input parameter InpMomentumPeriod has wrong value. Indicator will use value ",ExtMomentumPeriod);
     }
   else ExtMomentumPeriod=InpMomentumPeriod;
//---- buffers   

   SetIndexBuffer(0,ExtMomentumBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMomentumBuffer2,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(2,ExtMomentumBuffer3,INDICATOR_CALCULATIONS);
   
   
//---- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum Color Fill"+" ("+string(ExtMomentumPeriod)+")");
//--- sets first bar from what index will be drawn 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtMomentumPeriod-1);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,InpLevel);
//--- sets drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- digits
   IndicatorSetInteger(INDICATOR_DIGITS,2);
  }
//+------------------------------------------------------------------+
//|  Momentum                                                        |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- start calculation
   int StartCalcPosition=(ExtMomentumPeriod-1)+begin;
   
//---- insufficient data
   if(rates_total<StartCalcPosition)
      return(0);
      
//--- correct draw begin
   if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartCalcPosition+(ExtMomentumPeriod-1));
   
   
//--- start working, detect position
   int pos=prev_calculated-1;
   if(pos<StartCalcPosition)pos=begin+ExtMomentumPeriod;


//--- main cycle
   for(int i=pos;i<rates_total && !IsStopped();i++)
     {
      ExtMomentumBuffer2[i]=InpLevel;
      ExtMomentumBuffer[i]=price[i]*100/price[i-ExtMomentumPeriod];
      
      ExtMomentumBuffer3[i]=ExtMomentumBuffer[i]; 

                              
     }
     

   return(rates_total);
  }
//+------------------------------------------------------------------+
