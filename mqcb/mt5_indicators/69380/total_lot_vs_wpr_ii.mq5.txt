//+------------------------------------------------------------------+
//|                   Total_Lot_vs_WPR.mq5                           |
//|                                                                  |
//+------------------------------------------------------------------+
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_ARROW
#property indicator_width1 1
#property indicator_color1 0xFFAA00
#property indicator_label1 ""

#property indicator_type2 DRAW_ARROW
#property indicator_width2 1
#property indicator_color2 0x0000FF
#property indicator_label2 ""

#define PLOT_MAXIMUM_BARS_BACK 5000
#define OMIT_OLDEST_BARS 50

//--- indicator buffers
double Buffer1[];
double Buffer2[];

double myPoint; //initialized in OnInit
int WPR_handle;
double WPR[];
int WPR_handle2;
double WPR2[];
double Low[];
double High[];

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | WPR Point @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

// label -50 digunakan sebagai Pivot Point
// Input parameter untuk WPR
input int WPR_Period = 14; 
// Handle indikator global untuk WPR
int wpr_handle;

//--- buffer tidak diperlukan untuk paparkan teks
string labelBuy = "TotalBuyLots";
string labelSell = "TotalSellLots";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- 1. Buat objek label untuk ramalan trend
   if(!ObjectCreate(0, "TrendPredictionLabel", OBJ_LABEL, 0, 0, 0))
   {
      Print("Error creating TrendPredictionLabel: ", GetLastError());
   }
   ObjectSetInteger(0, "TrendPredictionLabel", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "TrendPredictionLabel", OBJPROP_XDISTANCE, 500);
   ObjectSetInteger(0, "TrendPredictionLabel", OBJPROP_YDISTANCE, 15);
   ObjectSetString(0, "TrendPredictionLabel", OBJPROP_TEXT, "TREND PREDICTION : ANALYZING...");
   ObjectSetInteger(0, "TrendPredictionLabel", OBJPROP_FONTSIZE, 15);
   ObjectSetInteger(0, "TrendPredictionLabel", OBJPROP_COLOR, clrWhite);

   //--- 2. Buat objek garisan mendatar pada harga tertentu (contoh 643.21)
   double price_level = 643.21;
   if(!ObjectCreate(0, "PriceLine", OBJ_HLINE, 0, 0, price_level))
   {
      Print("Error creating PriceLine: ", GetLastError());
   }
   ObjectSetInteger(0, "PriceLine", OBJPROP_COLOR, clrYellowGreen);
   ObjectSetInteger(0, "PriceLine", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, "PriceLine", OBJPROP_STYLE, STYLE_SOLID);

   //--- 3. Buat label untuk paparan P/L
   if(!ObjectCreate(0, "ProfitLossLabel", OBJ_LABEL, 0, 0, 0))
   {
      Print("Error creating ProfitLossLabel: ", GetLastError());
   }
   ObjectSetInteger(0, "ProfitLossLabel", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "ProfitLossLabel", OBJPROP_XDISTANCE, 500);
   ObjectSetInteger(0, "ProfitLossLabel", OBJPROP_YDISTANCE, 80);
   ObjectSetInteger(0, "ProfitLossLabel", OBJPROP_FONTSIZE, 16);
   
   // Buat label untuk paparan
   if(!ObjectCreate(0, "labelBuy", OBJ_LABEL, 0, 0, 0))
   {
      Print("Error creating labelBuy: ", GetLastError());
   }
   ObjectSetInteger(0, "labelBuy", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "labelBuy", OBJPROP_XDISTANCE,500);
   ObjectSetInteger(0, "labelBuy", OBJPROP_YDISTANCE, 50);
   ObjectSetInteger(0, "labelBuy", OBJPROP_FONTSIZE, 13);
   ObjectSetInteger(0, "labelBuy", OBJPROP_COLOR, clrMistyRose);

   if(!ObjectCreate(0, "labelSell", OBJ_LABEL, 0, 0, 0))
   {
      Print("Error creating labelSell: ", GetLastError());
   }
   ObjectSetInteger(0, "labelSell", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "labelSell", OBJPROP_XDISTANCE, 500);
   ObjectSetInteger(0, "labelSell", OBJPROP_YDISTANCE, 75);
   ObjectSetInteger(0, "labelSell", OBJPROP_FONTSIZE, 13);
   ObjectSetInteger(0, "labelSell",  OBJPROP_COLOR, clrMistyRose);
   
   //--- Inisialisasi handle indikator WPR
   wpr_handle = iWPR(_Symbol, _Period, WPR_Period);
   if(wpr_handle == INVALID_HANDLE)
   {
      Print("Error getting WPR handle: ", GetLastError());
      return(INIT_FAILED);
   }

SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   WPR_handle = iWPR(NULL, PERIOD_CURRENT, WPR_Period);
   if(WPR_handle < 0)
     {
      Print("The creation of iWPR has failed: WPR_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   WPR_handle2 = iWPR(NULL, PERIOD_CURRENT, WPR_Period);
   if(WPR_handle2 < 0)
     {
      Print("The creation of iWPR has failed: WPR_handle2=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   ChartRedraw();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, "TrendPredictionLabel");
   ObjectDelete(0, "PriceLine");
   ObjectDelete(0, "ProfitLossLabel");
   ObjectDelete(0, "labelBuy");
   ObjectDelete(0, "labelSell");
   IndicatorRelease(wpr_handle);
   IndicatorRelease(WPR_handle2);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& real_volume[],
                const int& spread[])
{
   // --- Logika Perhitungan WPR ---
   double wpr_values[];
   // Salin nilai WPR terbaru
   if(CopyBuffer(wpr_handle, 0, 0, 1, wpr_values) < 1)
   {
      return(rates_total);
   }
   double current_wpr = wpr_values[0]; // Ralat telah dibaiki di sini

   // Tentukan prediksi berdasarkan WPR
   string predictionText;
   color predictionColor;

   if (current_wpr > -50) // Kondisi Oversold: Signal Beli Kuat
   {
      predictionText = "JANGKAAN HARGA : BULLISH";
      predictionColor = clrDeepSkyBlue;
   }
   else if (current_wpr < -50) // Kondisi Overbought: Signal Jual Kuat
   {
      predictionText = "JANGKAAN HARGA : BEARISH";
      predictionColor = clrMagenta;
   }
   else // Pasar Netral/Sideways
   {
      predictionText = "JANGKAAN HARGA : MENUNGGU";
      predictionColor = clrYellow;
   }
   
   // Perbarui objek teks
   ObjectSetString(0, "TrendPredictionLabel", OBJPROP_TEXT, predictionText);
   ObjectSetInteger(0, "TrendPredictionLabel", OBJPROP_COLOR, predictionColor);

   // --- Logika Perhitungan P/L ---
   double totalProfit = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         totalProfit += PositionGetDouble(POSITION_PROFIT);
      }
   }
   
   // Tambah nama pair (_Symbol) ke teks P/L
   string plText = " KEUNTUNGAN " + "(" + _Symbol + ")" + " : $" + DoubleToString(totalProfit, 2);
   color plColor = clrDeepSkyBlue;
   if(totalProfit < 0)
   {
      plText = " KERUGIAN " + "(" + _Symbol + ")" + " : $" + DoubleToString(MathAbs(totalProfit), 2);
      plColor = clrGold;
   }
   
   ObjectSetString(0, "ProfitLossLabel", OBJPROP_TEXT, plText);
   ObjectSetInteger(0, "ProfitLossLabel", OBJPROP_COLOR, plColor);
   
   
   double totalBuyLots  = 0;
   double totalSellLots = 0;
   string chartSymbol   = Symbol(); // simbol carta semasa

   // Loop semua posisi terbuka
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         string posSymbol = PositionGetString(POSITION_SYMBOL);
         if(posSymbol == chartSymbol) // tapis hanya simbol carta semasa
           {
            double lots = PositionGetDouble(POSITION_VOLUME);
            long type   = PositionGetInteger(POSITION_TYPE);

            if(type == POSITION_TYPE_BUY)
               totalBuyLots += lots;
            else if(type == POSITION_TYPE_SELL)
               totalSellLots += lots;
           }
        }
     }

   // Paparkan pada carta
   string buyText  = "("+chartSymbol+") Lot BUY: " + DoubleToString(totalBuyLots,2);
   string sellText = "("+chartSymbol+") Lot SELL: " + DoubleToString(totalSellLots,2);

   ObjectSetString(0, "labelBuy", OBJPROP_TEXT, buyText);
   ObjectSetString(0, "labelSell", OBJPROP_TEXT, sellText);
   ChartRedraw();
   
   
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
     }
   else
      limit++;
   
   if(BarsCalculated(WPR_handle) <= 0) 
      return(0);
   if(CopyBuffer(WPR_handle, 0, 0, rates_total, WPR) <= 0) return(rates_total);
   ArraySetAsSeries(WPR, true);
   if(BarsCalculated(WPR_handle2) <= 0) 
      return(0);
   if(CopyBuffer(WPR_handle2, 0, 0, rates_total, WPR2) <= 0) return(rates_total);
   ArraySetAsSeries(WPR2, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(PLOT_MAXIMUM_BARS_BACK-1, rates_total-1-OMIT_OLDEST_BARS)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(WPR[i] > -50 //William's Percent Range > fixed value
      && WPR2[i] > -50 //William's Percent Range > fixed value
      )
        {
         Buffer1[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(WPR[i] < -50 //William's Percent Range < fixed value
      && WPR2[i] < -50 //William's Percent Range < fixed value
      )
        {
         Buffer2[i] = High[i]; //Set indicator value at Candlestick High
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
     }

   return(rates_total);
}


