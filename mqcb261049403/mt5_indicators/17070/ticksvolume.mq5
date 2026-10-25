//+------------------------------------------------------------------+
//|                                                  TicksVolume.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot UpBuffer
#property indicator_label1 "Pips Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 Navy
#property indicator_style1 STYLE_SOLID
#property indicator_width1 6
//--- plot UpTick
#property indicator_label2 "Tick Up"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 LawnGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
//--- plot DnBuffer
#property indicator_label3 "Pips Down"
#property indicator_type3  DRAW_HISTOGRAM
#property indicator_color3 FireBrick
#property indicator_style3 STYLE_SOLID
#property indicator_width3 6
//--- plot DnTick
#property indicator_label4 "Tick Down"
#property indicator_type4  DRAW_HISTOGRAM
#property indicator_color4 Yellow
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2
//--- plot level line
#property indicator_level1 0
#property indicator_levelcolor White
#property indicator_levelstyle STYLE_DOT
//--- Indicator buffer
double   UpBuffer[];
double   DnBuffer[];
double   UpTick[];
double   DnTick[];
//--- 
double   _Bid=0,_Ask=0,PriceUp=0,PriceDn=0,TickUp=0,TickDn=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,UpBuffer, INDICATOR_DATA);
   SetIndexBuffer(1,UpTick, INDICATOR_DATA);
   SetIndexBuffer(2,DnBuffer, INDICATOR_DATA);
   SetIndexBuffer(3,DnTick, INDICATOR_DATA);
  
   IndicatorSetString(INDICATOR_SHORTNAME,"TicksVolume");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
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
  
   ArraySetAsSeries(UpBuffer, true);
   ArraySetAsSeries(DnBuffer, true);
   ArraySetAsSeries(UpTick, true);
   ArraySetAsSeries(DnTick, true);
   
   ArraySetAsSeries(time, true);
   
   int bars = rates_total-1;
   if(prev_calculated>0) bars = rates_total - (prev_calculated-1);
   
   for(int i=bars; i>=0; i--)
      {
     
         static datetime LastBar=0;
         datetime CurBar=time[0];
         //---
         // Check if new tick
         MqlTick last_tick;
         SymbolInfoTick(_Symbol,last_tick);
         double Bid=last_tick.bid;
         double Ask=last_tick.ask;
      //---
      // Set parameters to zero if new bar
      if(LastBar!=CurBar)
         {
            TickUp=0;
            TickDn=0;
            PriceUp= 0;
            PriceDn= 0;
            LastBar=CurBar;
         }
      if(_Bid == 0) _Bid = Bid;  // If still the initialized bid value change to current bid value 
      if(_Ask == 0) _Ask = Ask;  // If still the initialized bid value change to current ask value
      //---
      // Check if price goes up or down
      if(Bid>_Bid || (_Bid==Bid && _Ask>Ask)) // 
         {
            PriceUp += Bid - _Bid;                        // Current difference value from current and last bid
            UpBuffer[0] = PriceUp/_Point;                 // Pass current Price diff to UpBuffer buffer
            TickUp++;                                     // Add one point to Tick up
            UpTick[0] = TickUp;                           // Pass current value to UpTick buffer
         }
      if(Bid<_Bid || (_Bid==Bid && _Ask<Ask)) // 
         {
            PriceDn += Bid - _Bid;                        // Current difference value from current and last bid  
            DnBuffer[0] = PriceDn/_Point;                 // Pass current Price diff to UpBuffer buffer
            TickDn--;                                     // Add one point to Tick down
            DnTick[0] = TickDn;                           // Pass current value to DnTick buffer
         }
        _Bid = Bid;
        _Ask = Ask;
        
        }
  return(rates_total);
  }
//+------------------------------------------------------------------+
