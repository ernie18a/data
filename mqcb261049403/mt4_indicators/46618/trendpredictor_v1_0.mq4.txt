#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
//---- input parameters
input    int         inp_zone_period            =  10;      // zone period
input    int         inp_amplitude_period       =  25;      // zone amplitude
input    double      inp_amplitude_coefficient  =  3;       // zone coefficient
//---- indicator buffers
double ext_arrow_up[];
double ext_arrow_dn[];
double ext_zone_up[];
double ext_zone_dn[];
double ext_current_min[];
double ext_current_max[];
double ext_trend[];
//+------------------------------------------------------------------+
int OnInit() {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   IndicatorBuffers(7);
   SetIndexBuffer(0,ext_arrow_up);
   SetIndexBuffer(1,ext_arrow_dn);
   SetIndexBuffer(2,ext_zone_up);
   SetIndexBuffer(3,ext_zone_dn);
   SetIndexBuffer(4,ext_current_min);
   SetIndexBuffer(5,ext_current_max);
   SetIndexBuffer(6,ext_trend);
//---- name for DataWindow and indicator subwindow label
   short_name="Trand Predictor";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Dn");
//----
   SetIndexDrawBegin(0,inp_zone_period);
   SetIndexDrawBegin(1,inp_zone_period);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| ChandelierStops_v1                                               |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // размер входных таймсерий 
                 const int prev_calculated,  // обработано баров на предыдущем вызове 
                 const datetime &time[],     // Time 
                 const double &open[],       // Open 
                 const double &high[],       // High 
                 const double &low[],        // Low 
                 const double &close[],      // Close 
                 const long &tick_volume[],  // Tick Volume 
                 const long &volume[],       // Real Volume 
                 const int &spread[]) {      // Spread 
   int shift,limit, counted_bars=IndicatorCounted();

   if(counted_bars > 0) limit=rates_total-counted_bars;
   if(counted_bars < 0) return(0);
   if(counted_bars ==0) limit=rates_total-inp_zone_period-1;

   for(shift=limit;shift>=0;shift--) {
      ext_current_min[shift]=high[Highest(NULL,0,MODE_HIGH,inp_zone_period,shift+1)] - inp_amplitude_coefficient*iATR(NULL,0,inp_amplitude_period,shift+1);
      ext_current_max[shift]=low[Lowest(NULL,0,MODE_LOW,inp_zone_period,shift+1)] + inp_amplitude_coefficient*iATR(NULL,0,inp_amplitude_period,shift+1);
      ext_trend[shift]=ext_trend[shift+1];

      if(close[shift] > ext_current_max[shift+1])ext_trend[shift]= 1;
      if(close[shift] < ext_current_min[shift+1])ext_trend[shift]=-1;
      if(ext_trend[shift] >0) {
         if(ext_current_min[shift]<ext_current_min[shift+1])ext_current_min[shift]=ext_current_min[shift+1];
         ext_zone_up[shift]=ext_current_min[shift];
         ext_zone_dn[shift]=EMPTY_VALUE;
      }
      if(ext_trend[shift] <0) {
         if(ext_current_max[shift]>ext_current_max[shift+1])ext_current_max[shift]=ext_current_max[shift+1];
         ext_zone_up[shift]=EMPTY_VALUE;
         ext_zone_dn[shift]=ext_current_max[shift];
      }
      if(shift+1 < rates_total) {
         if(ext_trend[shift] != ext_trend[shift+1]) {
            if(ext_trend[shift] == 1)
               ext_arrow_up[shift] = low[shift] - iATR(NULL,0,inp_amplitude_period,shift);
            else
               ext_arrow_dn[shift] = high[shift] + iATR(NULL,0,inp_amplitude_period,shift);
         }else{
            ext_arrow_up[shift] = EMPTY_VALUE;
            ext_arrow_dn[shift] = EMPTY_VALUE;
         }
      }
   }
   return(0);
}
//+------------------------------------------------------------------+