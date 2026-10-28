//+------------------------------------------------------------------+
//|                                                                  |
//|                 Filename:    XprofuterOverlay                    |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Magenta
//----
extern int per   =14;  // Period for signal
extern int update=1;   // 1 = continuously update, 0 = freeze
// Buffers for signals
double drawBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init() 
  {
   string title="XProfuter(" + (string)per + ")";
//----
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, drawBuffer);
   // Shift everything forward
   SetIndexShift(0, per);
   // Titles for each line
   SetIndexLabel(0, "Signal(" + (string)per + ")");
   IndicatorShortName(title);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int start() 
  {
   int    counted_bars=IndicatorCounted();
   int    shift;
   double prevSignal=-1, barClose=-1, imp;
//----
     if(update==1) 
     {
      imp=iCustom(NULL, 0, "XprofuterDD", per, 0, 0, 0, 0, 0, per) * Point;
      barClose=Close[0] - iCustom(NULL, 0, "XprofuterDD", per, 0, per) * Point;
      // Loop through and calculate the signals. Everytime this runs we recalculate the
      // current and all future signals. The future is not set :)
        for(shift=per - 1; shift>=0; shift--) 
        {
         imp=iCustom(NULL, 0, "XprofuterDD", per, 0, shift) * Point;
         drawBuffer[shift]=barClose + imp;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+