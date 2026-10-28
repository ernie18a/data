//+------------------------------------------------------------------+
//|                   WPR_WITH_TPSL II.mq5                           |
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else
      if(type == "error")
        {
         Print(type+" | WPR Point @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
        }
      else
         if(type == "order")
           {
           }
         else
            if(type == "modify")
              {
              }
  }

// Aku menggunakan -50 sebagai Pivot Point
// Input parameter untuk WPR
input int WPR_Period = 14;
// Handle indikator global untuk WPR
int wpr_handle;

//--- buffer tidak diperlukan untuk paparkan teks
string labelBuy = "TotalBuyLots";
string labelSell = "TotalSellLots";


//--- Input Parameter
//--- WPR guna nilai negatif
input int          Overbought    = -20;
input int          Oversold      = -80;
input double       TP_Multiplier = 100;
input double       SL_Multiplier = 100;

//--- Input Lokasi & Gaya

input int              X_Offset        = 380;
input int              Y_Offset        = 113;
input int              Box_Width       = 650;
input int              Box_Height      = 27;
input color            BG_Color        = clrBlack;
input int              Font_Size       = 13;

int      wpr_handle3;
datetime last_time = 0;
string   obj_name = "WPR_Box";


//--- used only zero graphical constructions
input ENUM_TIMEFRAMES trendline;
input color Resistance_Color=Blue;       // color of the resistance line
input ENUM_LINE_STYLE Resistance_Style; // line style of the resistance
input int Resistance_Width=2;           // width of the resistance line
input color Support_Color=Red;          // color of the support line
input ENUM_LINE_STYLE Support_Style;    // style of the support line
input int Support_Width=2;              // width of the support line
input bool Remove_TL=false;             // Remove_TL
int Fractal_base;

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
   ObjectCreate(0,labelBuy,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,labelBuy,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,labelBuy,OBJPROP_XDISTANCE,500);
   ObjectSetInteger(0,labelBuy,OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,labelBuy,OBJPROP_FONTSIZE,13);
   ObjectSetInteger(0,labelBuy,OBJPROP_COLOR,clrMistyRose);

   ObjectCreate(0,labelSell,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,labelSell,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,labelSell,OBJPROP_XDISTANCE,500);
   ObjectSetInteger(0,labelSell,OBJPROP_YDISTANCE,75);
   ObjectSetInteger(0,labelSell,OBJPROP_FONTSIZE,13);
   ObjectSetInteger(0,labelSell,OBJPROP_COLOR,clrMistyRose);

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

// Tukar handle kepada WPR
   wpr_handle = iWPR(_Symbol, _Period, WPR_Period);
   if(wpr_handle == INVALID_HANDLE)
      return(INIT_FAILED);

   if(!ObjectCreate(0, obj_name, OBJ_EDIT, 0, 0, 0))
      return(INIT_FAILED);


   ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, X_Offset);
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, Y_Offset);
   ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, Box_Width);
   ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, Box_Height);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, Font_Size);
   ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, BG_Color);
   ObjectSetInteger(0, obj_name, OBJPROP_READONLY, true);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, obj_name, OBJPROP_ALIGN, ALIGN_CENTER);
   
   
//get the handle of the iFractals indicator
   Fractal_base=iFractals(Symbol(),trendline);

//---

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
   ObjectDelete(0, labelBuy);
   ObjectDelete(0, labelSell);
   ObjectDelete(0, "WPR_Box");
   ObjectDelete(0,"TL_Support");
   ObjectDelete(0,"TL_Resistance");
   ObjectDelete(0,"LowerFractal_1");
   ObjectDelete(0,"LowerFractal_2");
   ObjectDelete(0,"UpperFractal_1");
   ObjectDelete(0,"UpperFractal_2");
   IndicatorRelease(wpr_handle);
   IndicatorRelease(WPR_handle2);
   IndicatorRelease(wpr_handle3);
   IndicatorRelease(trendline);
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

   if(current_wpr < -80)  // Kondisi Oversold: Signal Beli Kuat
     {
      predictionText = "OVERSOLD : BULLISH";
      predictionColor = clrDeepSkyBlue;
     }
   else
      if(current_wpr > -20)  // Kondisi Overbought: Signal Jual Kuat
        {
         predictionText = "OVERBOUGHT : BEARISH";
         predictionColor = clrMagenta;
        }
      else // Pasar Netral/Sideways
        {
         predictionText = "WAITING : NETRAL : SIDEWAYS";
         predictionColor = clrGray;
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
   string plText = " PROFIT " + "(" + _Symbol + ")" + " : $" + DoubleToString(totalProfit, 2);
   color plColor = clrDeepSkyBlue;
   if(totalProfit < 0)
     {
      plText = " LOSS " + "(" + _Symbol + ")" + " : $" + DoubleToString(MathAbs(totalProfit), 2);
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
            else
               if(type == POSITION_TYPE_SELL)
                  totalSellLots += lots;
           }
        }
     }

// Paparkan pada carta
   string buyText  = "("+chartSymbol+") Lot BUY: " + DoubleToString(totalBuyLots,2);
   string sellText = "("+chartSymbol+") Lot SELL: " + DoubleToString(totalSellLots,2);

   ObjectSetString(0,labelBuy,OBJPROP_TEXT,buyText);
   ObjectSetString(0,labelSell,OBJPROP_TEXT,sellText);
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
   if(CopyBuffer(WPR_handle, 0, 0, rates_total, WPR) <= 0)
      return(rates_total);
   ArraySetAsSeries(WPR, true);
   if(BarsCalculated(WPR_handle2) <= 0)
      return(0);
   if(CopyBuffer(WPR_handle2, 0, 0, rates_total, WPR2) <= 0)
      return(rates_total);
   ArraySetAsSeries(WPR2, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0)
      return(rates_total);
   ArraySetAsSeries(Low, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0)
      return(rates_total);
   ArraySetAsSeries(High, true);
//--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if(i >= MathMin(PLOT_MAXIMUM_BARS_BACK-1, rates_total-1-OMIT_OLDEST_BARS))
         continue; //omit some old rates to prevent "Array out of range" or slow calculation

      //Indicator Buffer 1
      if(WPR[i] < -20 //William's Percent Range > fixed value
         && WPR2[i] < -20 //William's Percent Range > fixed value
        )
        {
         Buffer1[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(WPR[i] > -80 //William's Percent Range < fixed value
         && WPR2[i] > -80 //William's Percent Range < fixed value
        )
        {
         Buffer2[i] = High[i]; //Set indicator value at Candlestick High
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
     }


   if(rates_total < WPR_Period)
      return(0);

// Ambil data WPR terkini
   double wpr_buffer[];
   ArraySetAsSeries(wpr_buffer, true);
   if(CopyBuffer(wpr_handle, 0, 0, 1, wpr_buffer) <= 0)
      return(prev_calculated);

   double wpr_val = wpr_buffer[0];

// Logik Signal WPR:
// > -20 adalah Overbought (Potensi SELL)
// < -80 adalah Oversold (Potensi BUY)
   string signal = (wpr_val > Overbought) ? "SELL" : (wpr_val < Oversold) ? "BUY" : "NEUTRAL";
   color  txt_col = (signal == "BUY") ? clrDeepSkyBlue : (signal == "SELL") ? clrGold : clrWhite;

   double tp = 0, sl = 0;
   double p = _Point;
   int last = rates_total - 1;

   if(signal == "BUY")
     {
      tp = high[last] + (TP_Multiplier * p);
      sl = low[last]  - (SL_Multiplier * p);
     }
   else
      if(signal == "SELL")
        {
         tp = low[last]  - (TP_Multiplier * p);
         sl = high[last] + (SL_Multiplier * p);
        }

   string info = StringFormat("WPR: %.2f | %s | TP: %.5f | SL: %.5f", wpr_val, signal, tp, sl);

   ObjectSetString(0, obj_name, OBJPROP_TEXT, info);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, txt_col);

//--- declaration of variables
   int n,UpperFractal_1_base,LowerFractal_1_base,UpperFractal_2_base,LowerFractal_2_base;
//--- declaration of arrays for writing the values of the buffers of the indicator iFractal
   double FractalDown_base[],FractalUp_base[];
   double UpFractal_1_base,LowFractal_1_base,UpFractal_2_base,LowFractal_2_base;
// --- first you need to write the arrays of the values of the Fractal
// --- filling with the data of the buffer
   CopyBuffer(Fractal_base,0,TimeCurrent(),Bars(Symbol(),trendline),FractalUp_base);
   CopyBuffer(Fractal_base,1,TimeCurrent(),Bars(Symbol(),trendline),FractalDown_base);
// --- indexing as in timeseries
   ArraySetAsSeries(FractalUp_base,true);
   ArraySetAsSeries(FractalDown_base,true);
//+------------------------------------------------------------------+
//| Search for fractal values                                        |
//+------------------------------------------------------------------+
// --- Search for the first upper fractal
   for(n=0; n<Bars(Symbol(),trendline); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalUp_base[n]!=EMPTY_VALUE)
         break;
     }
   UpFractal_1_base=FractalUp_base[n];// --- write the price value of the first fractal in the variable
   UpperFractal_1_base=n;// --- write the index of the first fractal in the variable
                         // ---  
// --- Search for the second upper fractal
   for(n=UpperFractal_1_base+1; n<Bars(Symbol(),trendline); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalUp_base[n]!=EMPTY_VALUE)
         break;
     }
   UpFractal_2_base=FractalUp_base[n]; // --- write the price value of the second fractal in the variable
   UpperFractal_2_base=n;// --- write the index of the second fractal in the variable
                         // ---
// --- Search for the first lower fractal
   for(n=0; n<Bars(Symbol(),trendline); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalDown_base[n]!=EMPTY_VALUE)
         break;
     }
   LowFractal_1_base=FractalDown_base[n];// --- write the price value of the first fractal in the variable
   LowerFractal_1_base=n;// --- write the index of the first fractal in the variable
                         // ---  
// --- Search for the second lower fractal
   for(n=LowerFractal_1_base+1; n<Bars(Symbol(),trendline); n++)
     {
      // --- if a non-empty value, terminate the loop
      if(FractalDown_base[n]!=EMPTY_VALUE)
         break;
     }
   LowFractal_2_base=FractalDown_base[n];// --- write the price value of the second fractal in the variable
   LowerFractal_2_base=n;// --- write the index of the second fractal in the variable
//---
//+------------------------------------------------------------------+
//|Search of time values of fractals                                 |
//+------------------------------------------------------------------+
// --- declaration of an array for storing the time of the corresponding bar index
   datetime UpFractalTime_1_base[],LowFractalTime_1_base[],UpFractalTime_2_base[],LowFractalTime_2_base[];
// --- indexing as in timeseries  
   ArraySetAsSeries(UpFractalTime_1_base,true);
   ArraySetAsSeries(LowFractalTime_1_base,true);
   ArraySetAsSeries(UpFractalTime_2_base,true);
   ArraySetAsSeries(LowFractalTime_2_base,true);
// --- search of time of fractals
   CopyTime(Symbol(),trendline,UpperFractal_1_base,1,UpFractalTime_1_base);
   CopyTime(Symbol(),trendline,LowerFractal_1_base,1,LowFractalTime_1_base);
   CopyTime(Symbol(),trendline,UpperFractal_2_base,1,UpFractalTime_2_base);
   CopyTime(Symbol(),trendline,LowerFractal_2_base,1,LowFractalTime_2_base);
// ---
//+------------------------------------------------------------------+
//|Drawing fractals
//+------------------------------------------------------------------+
ObjectCreate(0,"UpperFractal_1",OBJ_ARROW,0,UpFractalTime_1_base[0], UpFractal_1_base);
ObjectCreate(0,"UpperFractal_2",OBJ_ARROW,0,UpFractalTime_2_base[0], UpFractal_2_base);
ObjectSetInteger(0,"UpperFractal_1",OBJPROP_COLOR,Resistance_Color);
ObjectSetInteger(0,"UpperFractal_2",OBJPROP_COLOR,Resistance_Color);
ObjectSetInteger(0,"UpperFractal_1",OBJPROP_ARROWCODE,217);
ObjectSetInteger(0,"UpperFractal_2",OBJPROP_ARROWCODE,217);
ObjectSetInteger(0,"UpperFractal_1",OBJPROP_ANCHOR,ANCHOR_BOTTOM);
ObjectSetInteger(0,"UpperFractal_2",OBJPROP_ANCHOR,ANCHOR_BOTTOM);
//----
ObjectCreate(0,"LowerFractal_1",OBJ_ARROW,0,LowFractalTime_1_base[0], LowFractal_1_base);
ObjectCreate(0,"LowerFractal_2",OBJ_ARROW,0,LowFractalTime_2_base[0], LowFractal_2_base);
ObjectSetInteger(0,"LowerFractal_1",OBJPROP_COLOR,Support_Color);
ObjectSetInteger(0,"LowerFractal_2",OBJPROP_COLOR,Support_Color);
ObjectSetInteger(0,"LowerFractal_1",OBJPROP_ARROWCODE,218);
ObjectSetInteger(0,"LowerFractal_2",OBJPROP_ARROWCODE,218);
ObjectSetInteger(0,"LowerFractal_1",OBJPROP_ANCHOR,ANCHOR_TOP);
ObjectSetInteger(0,"LowerFractal_2",OBJPROP_ANCHOR,ANCHOR_TOP);
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Drawing trend lines                                |
//+------------------------------------------------------------------+
//--- rewrite tl
if (ObjectGetInteger(0,"TL_Support",OBJPROP_TIME)!=LowFractalTime_2_base[0])
   {
      ObjectDelete(0,"TL_Support");
      ObjectDelete(0,"LowerFractal_1");
      ObjectDelete(0,"LowerFractal_2");
   }
if (ObjectGetInteger(0,"TL_Resistance",OBJPROP_TIME)!=UpFractalTime_2_base[0])
   {
      ObjectDelete(0,"TL_Resistance");
      ObjectDelete(0,"UpperFractal_1");
      ObjectDelete(0,"UpperFractal_2");
   }
//--- Create support line
   ObjectCreate(0,"TL_Support",OBJ_TREND,0,LowFractalTime_2_base[0],LowFractal_2_base,LowFractalTime_1_base[0],LowFractal_1_base);
   ObjectSetInteger(0,"TL_Support",OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,"TL_Support",OBJPROP_COLOR,Support_Color);
   ObjectSetInteger(0,"TL_Support",OBJPROP_STYLE,Support_Style);
   ObjectSetInteger(0,"TL_Support",OBJPROP_WIDTH,Support_Width);
//--- Create resistance line
   ObjectCreate(0,"TL_Resistance",OBJ_TREND,0,UpFractalTime_2_base[0],UpFractal_2_base,UpFractalTime_1_base[0],UpFractal_1_base);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_COLOR,Resistance_Color);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_STYLE,Resistance_Style);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_WIDTH,Resistance_Width);
//--- Delete trendlines
if (Remove_TL==true)
{
   ObjectDelete(0,"TL_Support");
   ObjectDelete(0,"TL_Resistance");
   ObjectDelete(0,"LowerFractal_1");
   ObjectDelete(0,"LowerFractal_2");
   ObjectDelete(0,"UpperFractal_1");
   ObjectDelete(0,"UpperFractal_2");
      
}
//--- return value of prev_calculated for next call   
   
   
   return(rates_total);
  }


//+------------------------------------------------------------------+
