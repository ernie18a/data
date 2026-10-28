#property copyright "Bugscoder Studio"
#property link      "https://www.bugscoder.com/"
#property version   "1.00"
#property strict
#property indicator_chart_window

enum ENUM_CANDLE_SHIFT {
   CANDLE0 = 0, //Running Candle
   CANDLE1 = 1, //Close Candle
};


input ENUM_CANDLE_SHIFT CANDLE_SHIFT = 1;

input bool wicks = false;
input ENUM_MA_METHOD ma1_type = MODE_SMA;
input ENUM_APPLIED_PRICE ma1_source = PRICE_HIGH;
input int ma1_length = 200;
input ENUM_MA_METHOD ma2_type = MODE_SMA;
input ENUM_APPLIED_PRICE ma2_source = PRICE_LOW;
input int ma2_length = 200;

datetime lastBar = NULL;

int OnInit() {

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {


   bool newBar = false;
   datetime curbar = (datetime) SeriesInfoInteger(NULL, 0, SERIES_LASTBAR_DATE);
   if (curbar != lastBar) {
      lastBar = curbar;
      newBar = true;
   }
   
   if (newBar == false) { return 0; }
   
   //iCustom(Symbol, TimeFrame, IndicatorFileName, [... PARAMETER ...], BufferNumber, Candle Shift);
   
   double greenBand = iCustom(NULL, 0, "SSL_Channel", wicks, ma1_type, ma1_source, ma1_length, ma2_type, ma2_source, ma2_length, 1, CANDLE_SHIFT);
   double redBand   = iCustom(NULL, 0, "SSL_Channel", wicks, ma1_type, ma1_source, ma1_length, ma2_type, ma2_source, ma2_length, 2, CANDLE_SHIFT);
   double buyArrow  = iCustom(NULL, 0, "SSL_Channel", wicks, ma1_type, ma1_source, ma1_length, ma2_type, ma2_source, ma2_length, 3, CANDLE_SHIFT);
   double sellArrow = iCustom(NULL, 0, "SSL_Channel", wicks, ma1_type, ma1_source, ma1_length, ma2_type, ma2_source, ma2_length, 4, CANDLE_SHIFT);
   
   Print(greenBand, " ", redBand, " ", buyArrow, " ", sellArrow);
   
   return(rates_total);
}