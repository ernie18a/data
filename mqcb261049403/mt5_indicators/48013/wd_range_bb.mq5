//+-------------------------------------------------------------------+
//|                                                   wd.Range_BB.mq5 |
//|                 Copyright © 2024, Karya Prima Rajasa Mediavestama |
//|                                  Programmed by widhie75@yahoo.com |
//+-------------------------------------------------------------------+
#property copyright   "Copyright © 2024, Karya Prima Rajasa Mediavestama."
#property link        "https://www.mql5.com/en/code/48013"
#property version     "2.24"
#property description "Provides Bollinger Bands, calculating the range bandwidth as the difference in pips between the upper and lower Bands."
#property description "Bollinger Bands appearance and behavior can be tailored by adjusting period, shift, deviation, and applied price, along with color and line style."
#property description "The 'range/bandwidth information' label can be placed in the specified Sub-Window, allowing customization of label positions."
#property description "Overall, this indicator helps traders visualize market flexibility and volatility based on Bollinger Bands' width."
#property strict

#property indicator_chart_window 
#property indicator_buffers 3 
#property indicator_plots   3 

//--- UpperBB plot 
#property indicator_label1  "UpperBB" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrMediumSeaGreen 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- MiddleBB plot 
#property indicator_label2  "MidBB" 
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrMediumSeaGreen 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  2 
//--- LowerBB plot 
#property indicator_label3  "LowerBB" 
#property indicator_type3   DRAW_LINE 
#property indicator_color3  clrMediumSeaGreen 
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1 

//--- Input parameters 
input string   Comment1="===== Bollinger Bands Settings =======";       //=======================
input int      BB_period=20;                          // Period
input int      BB_shift=0;                            // Shift 
input double   Deviation=2.0;                         // Deviations  
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE;   // Apply to
input string   Comment2="===== Range/Bandwidth Settings ======";       //========================
input color    InfoColor=clrOrange;                   // Font color 
input int      InfoSize=7;                            // Font size
input int      SubWindow=0;                           // Sub-Window placement
input int      XDist=4;                               // X-Position label
input int      YDist=12;                              // Y-Position label

//--- Indicator buffers 
double         UpperBB_Buffer[];
double         MidBB_Buffer[]; 
double         LowerBB_Buffer[];

//--- Global variables
int            labelRangeBB; // Handle for the range bandwidth BB label
int            handleBB; 
int            bars_calculated=0; 

//+-------------------------------------------------------------------+
//| Function to create a label in a separate sub-window               |
//+-------------------------------------------------------------------+
void CreateLabelInSubWindow(int subWindowNumber)
{
   //--- Create label for 'Range/Bandwidth BB' in the specified sub-window
   labelRangeBB = ObjectCreate(0, "RangeBB", OBJ_LABEL, subWindowNumber, 0, 0);
   ObjectSetInteger(0, "RangeBB", OBJPROP_COLOR, InfoColor);
   ObjectSetInteger(0, "RangeBB", OBJPROP_FONTSIZE, InfoSize);
   ObjectSetInteger(0, "RangeBB", OBJPROP_XDISTANCE, XDist);
   ObjectSetInteger(0, "RangeBB", OBJPROP_YDISTANCE, YDist);
   ObjectSetString(0, "RangeBB", OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, "RangeBB", OBJPROP_TEXT, "wd.Range_BB: ");
}

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
{ 
   //--- Specify the sub-window number where the label should be placed
   int subWindowNumber = SubWindow;

   //--- Initialize the label in the specified sub-window
   CreateLabelInSubWindow(subWindowNumber);
   
   //--- Assignment of arrays to indicator buffers 
   SetIndexBuffer(0, UpperBB_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, MidBB_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, LowerBB_Buffer, INDICATOR_DATA);

   //--- Set shift of each line 
   for (int i = 0; i < 3; i++)
      PlotIndexSetInteger(i, PLOT_SHIFT, BB_shift);

   handleBB = iBands(_Symbol, PERIOD_CURRENT, BB_period, BB_shift, Deviation, Applied_price); 

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
   //--- Calculate the number of BB values to copy
   int BBvalues;
   if (prev_calculated == 0 || BarsCalculated(handleBB) != bars_calculated || rates_total > prev_calculated + 1)
      BBvalues = MathMin(BarsCalculated(handleBB), rates_total);
   else
      BBvalues = rates_total - prev_calculated + 1;

   //--- Copy BB values directly to the buffers
   CopyBuffer(handleBB, 0, -BB_shift, BBvalues, MidBB_Buffer);
   CopyBuffer(handleBB, 1, -BB_shift, BBvalues, UpperBB_Buffer);
   CopyBuffer(handleBB, 2, -BB_shift, BBvalues, LowerBB_Buffer); 

   //--- Calculate range bandwidth, round to the nearest integer
   int BBandwidth = (int)MathRound((UpperBB_Buffer[rates_total-1] - LowerBB_Buffer[rates_total-1]) / _Point);
   string labelBBandwidth = StringFormat("wd.Range_BB: %d", BBandwidth);
   ObjectSetString(0, "RangeBB", OBJPROP_TEXT, labelBBandwidth);

   return(rates_total); 
} 

//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
{ 
   IndicatorRelease(handleBB);
    
   //--- Delete the bandwidth info label on deinitialization
   ObjectDelete(0, "RangeBB");
}
