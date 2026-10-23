#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_width1 3
#property indicator_color1 clrRed
#property indicator_label1 "Range ratio"

enum ENUM_RANGE_TYPE{
   RANGE_TYPE_HL_SUM    = 0,  // sum [High - Low]
   RANGE_TYPE_OC_SUM    = 1,  // sum [Close - Open]
};

input ENUM_TIMEFRAMES   inp_time_frame_lower    = PERIOD_M15;           // lower time frame
input ENUM_RANGE_TYPE   inp_range_type          = RANGE_TYPE_HL_SUM;    // range type

input bool              inp_alert               = false;                // alert
input double            inp_alert_level         = 70;                   // alert level

double ext_range[];
//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0,ext_range);
   SetIndexLabel(0,"Range ratio");

   IndicatorDigits(3);

   return(INIT_SUCCEEDED);
}
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
                const int &spread[]) {
                
   //---
   static datetime time_bar = 0;
   bool  new_bar = time[0] > time_bar;
   time_bar = time[0];

   //---
   int limit = prev_calculated>0 ? rates_total - prev_calculated + 1 : rates_total - 1;
   for(int i=limit;i>=0;i--) {
      int      lower_start_bar   = iBarShift(NULL, inp_time_frame_lower, time[i],false);
      int      lower_end_bar     = i>0 ? iBarShift(NULL, inp_time_frame_lower, time[i-1],false) -1 : 0;
      double   lower_sum         = 0;
      for(int lb = lower_start_bar; lb>= lower_end_bar; lb--) {
         switch(inp_range_type) {
            case RANGE_TYPE_HL_SUM:
               lower_sum += iHigh(NULL, inp_time_frame_lower, lb) - iLow(NULL, inp_time_frame_lower, lb);
               break;
            case RANGE_TYPE_OC_SUM:
               lower_sum += MathAbs(iClose(NULL, inp_time_frame_lower, lb) - iOpen(NULL, inp_time_frame_lower, lb) );
               break;
         }
      }
      
      double higher_sum = 0;
      switch(inp_range_type) {
         case RANGE_TYPE_HL_SUM:
            higher_sum = high[i] - low[i];
            break;
         case RANGE_TYPE_OC_SUM:
            higher_sum = MathAbs(close[i] - open[i]);
            break;
      }
      if(higher_sum>0.0)
         ext_range[i] = lower_sum / higher_sum;
      else
         ext_range[i] = 0.0;
      
   }

   //---
   if(inp_alert && new_bar) {
      if(ext_range[1] >= inp_alert_level && ext_range[2] < inp_alert_level) 
         Alert("Big range ratio on "+_Symbol);
   }
   
                
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
                  
}
//+------------------------------------------------------------------+
