//+------------------------------------------------------------------+
//|                                             Cronex T RSI BBS.mq5 |
//|                                        Copyright © 2017, Cronex. |
//|                                Sergii Kozin sergagame1@gmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2017, Cronex"
#property  link      "https://www.metaquotes.net/"

#property  indicator_separate_window

#property indicator_buffers 7
#property indicator_plots 7

#property indicator_color1 DarkOrange
#property indicator_color2 SteelBlue
#property indicator_color3 Blue
#property indicator_color4 Yellow
#property indicator_color5 Green
#property indicator_color6 Blue
#property indicator_color7 Red

#property indicator_style5  STYLE_SOLID 

#property indicator_width1 2
#property indicator_width5 1
#property indicator_width6 2
#property indicator_width7 2
   
#property indicator_level1  10
#property indicator_level2 -10

input int RSIPeriod = 16;
input double TCurvature = 0.618;
input bool WideMethod = false;
input int BandsPeriod = 20;
input int BandsDeviations = 2;
input int BandsShift = 0;

double RSITArray[];
double RSIArray[];
double BBMDArray[];
double BBUPArray[];
double BBDNArray[];
double MaxArray[];
double MinArray[];

int BandsHandle = 0;
int CronesSubHandle = 0;

int OnInit()
{
   SetIndexBuffer(0, RSITArray, INDICATOR_DATA);
   SetIndexBuffer(1, RSIArray, INDICATOR_DATA);
   SetIndexBuffer(2, BBMDArray, INDICATOR_DATA);
   SetIndexBuffer(3, BBUPArray, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, BBDNArray, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, MaxArray, INDICATOR_DATA);
   SetIndexBuffer(6, MinArray, INDICATOR_DATA);
     
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);   
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);   
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);   
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);   
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);   
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   
   PlotIndexSetString(0, PLOT_LABEL, "RSI T");
   PlotIndexSetString(1, PLOT_LABEL, "RSI");
   PlotIndexSetString(2, PLOT_LABEL, "BB Middle");
   PlotIndexSetString(3, PLOT_LABEL, "BB Upper");
   PlotIndexSetString(4, PLOT_LABEL, "BB Lower");
   PlotIndexSetString(5, PLOT_LABEL, "Max Point");
   PlotIndexSetString(6, PLOT_LABEL, "Min Point");

   IndicatorSetInteger(INDICATOR_DIGITS, (int)SymbolInfoInteger(NULL, SYMBOL_DIGITS));
   IndicatorSetString(INDICATOR_SHORTNAME, "Cronex T RSI BBS (" + IntegerToString(RSIPeriod) + ")");
      
   CronesSubHandle = iCustom(_Symbol, _Period, "Cronex_T_RSI_BBSW_sub", RSIPeriod, TCurvature);   
   BandsHandle = iBands(_Symbol, _Period, BandsPeriod, BandsShift, BandsDeviations, CronesSubHandle);

   return(0);
}

int OnCalculate(
   const int rates_total,
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
   int to_calc = rates_total - prev_calculated;
   
   CopyBuffer(CronesSubHandle, 0, 0, to_calc, RSITArray);
   CopyBuffer(CronesSubHandle, 1, 0, to_calc, RSIArray);
   
   CopyBuffer(BandsHandle, 0, 0, to_calc, BBMDArray);   
   CopyBuffer(BandsHandle, 1, 0, to_calc, BBUPArray);   
   CopyBuffer(BandsHandle, 2, 0, to_calc, BBDNArray);    
   
   int i, c;
   for (i = 0; i < to_calc; i++) {      
      c = prev_calculated + i;
      
      MaxArray[c] = 0.0;
      MinArray[c] = 0.0;
     
      if (BBMDArray[c] < 100 && BBMDArray[c] > -100 && BBUPArray[c] < 100 && BBUPArray[c] > -100 && BBDNArray[c] < 100 && BBDNArray[c] > -100) { 
         if (WideMethod) {           
               if (RSITArray[c] > BBMDArray[c]) {
                  if (RSITArray[c] - BBMDArray[c] > RSITArray[c - 1] - BBMDArray[c - 1]) {
                     MaxArray[c] = RSITArray[c] - BBMDArray[c];
                  } else {
                     MinArray[c] = RSITArray[c] - BBMDArray[c];
                  }
               } else if (RSITArray[c] < BBMDArray[c]) {
                  if (RSITArray[c] - BBMDArray[c] < RSITArray[c - 1] - BBMDArray[c - 1]) {
                     MinArray[c] = RSITArray[c] - BBMDArray[c];                                       
                  } else {
                     MaxArray[c] = RSITArray[c] - BBMDArray[c];
                  }
               }
         } else {  
            if (RSIArray[c] > BBUPArray[c]) {
               MaxArray[c] = RSIArray[c] - BBUPArray[c];
            } 
            if (RSIArray[c] < BBDNArray[c]) {
               MinArray[c] = RSIArray[c] - BBDNArray[c];
            } 
         }      
      }      
   }

   return(rates_total);
}