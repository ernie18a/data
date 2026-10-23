#property strict
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1  clrDeepSkyBlue
#property indicator_width1  2
#property indicator_color2  clrTomato
#property indicator_width2  2
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW

input double      inp_hot_money_sensitivity     = 0.7;   // fast sensitivity
input int         inp_hot_money_period          = 40;    // fast period
input double      inp_hot_money_base            = 30;    // fast level
input double      inp_banker_sensitivity        = 1.5;   // slow sensitivity
input int         inp_banker_period             = 50;    // slow period
input double      inp_banker_base               = 50;    // slow level

double ext_arrow_up[];
double ext_arrow_dn[];
double ext_retailer[], ext_hot_money[], ext_banker[];

int OnInit() {

   IndicatorBuffers(5);
   SetIndexBuffer(0, ext_arrow_up);
   SetIndexBuffer(1, ext_arrow_dn);
	SetIndexBuffer(2, ext_retailer);
	SetIndexBuffer(3, ext_hot_money);
	SetIndexBuffer(4, ext_banker);
	SetIndexArrow(0, 233);
	SetIndexArrow(1, 234);
	
	SetIndexLabel(0,"buy");
	SetIndexLabel(1,"sell");


   return(INIT_SUCCEEDED);
}

int OnCalculate (const int rates_total,      // размер входных таймсерий 
                 const int prev_calculated,  // обработано баров на предыдущем вызове 
                 const datetime &time[],     // Time 
                 const double &open[],       // Open 
                 const double &high[],       // High 
                 const double &low[],        // Low 
                 const double &close[],      // Close 
                 const long &tick_volume[],  // Tick Volume 
                 const long &volume[],       // Real Volume 
                 const int &spread[]         // Spread 
   ) {
   
   int limit = prev_calculated > 0 ? rates_total - prev_calculated + 1 : rates_total-1;   
 
   for(;limit>=0;limit--) {    
	   ext_retailer[limit] = 20;
	   ext_hot_money[limit] = rsi(inp_hot_money_sensitivity, inp_hot_money_period, inp_hot_money_base, limit);
	   ext_banker[limit] = rsi(inp_banker_sensitivity, inp_banker_period, inp_banker_base, limit);
	   
	   if(limit >= rates_total-1) continue;
	   
	   if( (ext_hot_money[limit] <= 0 || ext_hot_money[limit+1] <= 0) && close[limit] > open[limit]) {
	      ext_arrow_up[limit] = low[limit] - iATR(NULL,PERIOD_CURRENT, 14, limit) / 3.0;
	   }else{
	      ext_arrow_up[limit] = EMPTY_VALUE;
	   }
	   
	   if( (ext_banker[limit] >= 20 || ext_banker[limit+1] >= 20) && close[limit] < open[limit]) {
	      ext_arrow_dn[limit] = high[limit] + iATR(NULL,PERIOD_CURRENT, 14, limit) / 3.0;
	   }else{
	      ext_arrow_dn[limit] = EMPTY_VALUE;
	   }
	}
   return(rates_total);
}

double rsi(double sensitivity, int period, double base, int pos) {
   double rsi = sensitivity * (iRSI(NULL, 0, period, PRICE_CLOSE, pos)-base);
   if (rsi > 20) { rsi = 20; }
   if (rsi < 0) { rsi = 0; }
   
   return rsi;
}