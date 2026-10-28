#property indicator_chart_window
#property indicator_buffers 7  // 2 asal + 5 untuk candle
#property indicator_plots   3  // 2 arrow + 1 candle plot

//--- Plot Arrow 1
#property indicator_type1   DRAW_ARROW
#property indicator_color1   0xFFAA00
#property indicator_width1   2

//--- Plot Arrow 2
#property indicator_type2   DRAW_ARROW
#property indicator_color2   0x0000FF
#property indicator_width2   2

//--- Plot Color Candles (Baru)
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3   0xFFAA00, 0x0000FF // Warna ikut arrow
#property indicator_label3   "MA Open;MA High;MA Low;MA Close"

//--- Buffers
double Buffer1[], Buffer2[];
double candle_open[], candle_high[], candle_low[], candle_close[], candle_color[];

//--- Inputs & Handles (Kekal sama)
input int PeriodMA2 = 14;
input int PeriodMA1 = 3;
int MA_handle, MA_handle2;
double MA[], MA2[], Close_Data[];

int OnInit() {
   // Mapping Buffer Arrow
   SetIndexBuffer(0, Buffer1, INDICATOR_DATA);
   SetIndexBuffer(1, Buffer2, INDICATOR_DATA);
   
   // Mapping Buffer Candle (Mesti ikut turutan: O, H, L, C, Color)
   SetIndexBuffer(2, candle_open, INDICATOR_DATA);
   SetIndexBuffer(3, candle_high, INDICATOR_DATA);
   SetIndexBuffer(4, candle_low, INDICATOR_DATA);
   SetIndexBuffer(5, candle_close, INDICATOR_DATA);
   SetIndexBuffer(6, candle_color, INDICATOR_COLOR_INDEX);

   // Sembunyikan nilai kosong
   for(int i=0; i<3; i++) PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   MA_handle = iMA(_Symbol, _Period, PeriodMA1, 0, MODE_SMA, PRICE_CLOSE);
   MA_handle2 = iMA(_Symbol, _Period, PeriodMA2, 0, MODE_SMA, PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
   
   int limit = (prev_calculated < 1) ? 0 : prev_calculated - 1;

   // Ambil data MA
   if(CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0) return(0);
   if(CopyBuffer(MA_handle2, 0, 0, rates_total, MA2) <= 0) return(0);

   for(int i = limit; i < rates_total; i++) {
      // Logika Arrow & Warna Candle
      if(close[i] > MA[i]) {
         Buffer1[i] = MA2[i];
         Buffer2[i] = EMPTY_VALUE;
         candle_color[i] = 0; // Warna 0xFFAA00
      } 
      else if(close[i] < MA[i]) {
         Buffer2[i] = MA2[i];
         Buffer1[i] = EMPTY_VALUE;
         candle_color[i] = 1; // Warna 0x0000FF
      }
      else {
         Buffer1[i] = Buffer2[i] = EMPTY_VALUE;
         candle_color[i] = EMPTY_VALUE;
      }

      // Isi data candle supaya muncul di carta
      if(candle_color[i] != EMPTY_VALUE) {
         candle_open[i]  = open[i];
         candle_high[i]  = high[i];
         candle_low[i]   = low[i];
         candle_close[i] = close[i];
      } else {
         candle_open[i] = candle_high[i] = candle_low[i] = candle_close[i] = EMPTY_VALUE;
      }
   }
   return(rates_total);
}
