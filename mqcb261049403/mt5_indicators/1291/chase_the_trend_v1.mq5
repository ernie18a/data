//+------------------------------------------------------------------+
//|                                          Chase the trend 1.0.mq5 |
//|                                                    Lazarev Denis |
//+------------------------------------------------------------------+
#property copyright "Lazarev Denis"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_label1  "LINE"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int    period   = 10;       //averaging period
input bool   USE_LIMIT= false;    //limiting on/off
                                  //is limitation of indicator value maximal change
input double use_limit= 0.00005;  //Maximal value
                                  //on which indicator can be changed

double         Buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
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
//--- calculate the indicator values
   int start=0;
//--- if the calculation is made on a previous run of OnCalculate
   if(prev_calculated>0) start=prev_calculated-1; // set the start of the penultimate bar calculations
//--- fill indicator buffer values
   for(int i=start;i<rates_total-1;i++)
     {
      Buffer[0]=price[0];
      double delta=(price[i]-Buffer[i])/period;
      if(USE_LIMIT && delta>use_limit)
        {
         delta=use_limit;
        }
      if(USE_LIMIT && delta<-use_limit)
        {
         delta=-use_limit;
        }
      Buffer[i+1]=Buffer[i]+delta;
     }
//--- return the value for the next call of prev_calculated function
   return(rates_total);
  }
//+------------------------------------------------------------------+
