#include <Trade\Trade.mqh>
#property tester_file "larry_model.onnx" 

// Input parameters
input long      InpMagic           = 123456;
input double    InpLotSize         = 0.5;
// Larry Williams RR ideal ratio
input double    InpRR              = 1.5;      
input string    InpModelName       = "larry_model.onnx";
// Probability threshold
input double    InpThreshold       = 0.6;      
input int       InpAtrPeriod       = 14;

// Global variables
long      m_onnx_handle = INVALID_HANDLE;
int       m_atr_handle  = INVALID_HANDLE;
CTrade    m_trade;
static double s_currentLot = 0.0;
// NUMBER OF FEATURES MUST BE THE SAME AS PYTHON
#define NUM_FEATURES 10 

int OnInit()
{
   m_onnx_handle = OnnxCreate(InpModelName, ONNX_DEFAULT);
   if(m_onnx_handle == INVALID_HANDLE) return(INIT_FAILED);

   m_atr_handle = iATR(_Symbol, _Period, InpAtrPeriod);
   s_currentLot = InpLotSize;

   long input_shape[] = {1, NUM_FEATURES};
   if(!OnnxSetInputShape(m_onnx_handle, 0, input_shape)) return(INIT_FAILED);

   long shape_label[] = {1}; 
   if(!OnnxSetOutputShape(m_onnx_handle, 0, shape_label)) Print("Warning Output 0: ", GetLastError());

   long shape_probs[] = {1, 3};
   if(!OnnxSetOutputShape(m_onnx_handle, 1, shape_probs)) 
   {
      Print("Fail SetOutputShape Probabilities: ", GetLastError());
      return(INIT_FAILED);
   }

   m_trade.SetExpertMagicNumber(InpMagic);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   static datetime last_bar = 0;
   if(last_bar == iTime(_Symbol, _Period, 0)) return;
   last_bar = iTime(_Symbol, _Period, 0);

   if(PositionsTotal() > 0) return;

   // Larry Williams Strategy Detection (Mechanical)
   if(!IsLarryOutsideBar()) return;

   // If there is an Outside Bar, then call AI for filtering.
   float inputs[NUM_FEATURES];
   if(!CalculateFeatures(inputs)) return;

   // Using good data types according to ONNX standards
   long  predicted_label[1];      // Node 0: output shape {1}
   float predicted_probs[1*3];    // Node 1: output shape {1, 3}

   // Use ONNX_NO_CONVERSION so that MT5 does not try to change the data type automatically.
   if(!OnnxRun(m_onnx_handle, ONNX_NO_CONVERSION, inputs, predicted_label, predicted_probs))
   {
      // If it still gives an error, print the error code.
      Print("OnnxRun Error: ", GetLastError());
      return;
   }

   // Use threshold on probability class 1 (Buy) or class 2 (Sell)
   if(predicted_probs[1] > InpThreshold) 
   {
      Print("AI Signal BUY: ", predicted_probs[1]);
      ExecuteOrder(ORDER_TYPE_BUY,InpLotSize);
   }
   else if(predicted_probs[2] > InpThreshold) 
   {
      Print("AI Signal SELL: ", predicted_probs[2]);
      ExecuteOrder(ORDER_TYPE_SELL,InpLotSize);
   }
}

// LARRY WILLIAMS STRATEGY LOGIC (Almost the same as Python)
bool IsLarryOutsideBar()
{
   double h0 = iHigh(_Symbol, _Period, 1);
   double l0 = iLow(_Symbol, _Period, 1);
   double c0 = iClose(_Symbol, _Period, 1);
   
   double h1 = iHigh(_Symbol, _Period, 2);
   double l1 = iLow(_Symbol, _Period, 2);

   bool bull = (l0 < l1 && h0 > h1 && c0 > h1);
   bool bear = (h0 > h1 && l0 < l1 && c0 < l1);
   
   return (bull || bear);
}

bool CalculateFeatures(float &features[])
{
   ArrayResize(features, NUM_FEATURES);
   
   // Take OHLC data for candle 1 (Signal Bar) and candle 2 (Prev Bar)
   double h0 = iHigh(_Symbol, _Period, 1), l0 = iLow(_Symbol, _Period, 1);
   double c0 = iClose(_Symbol, _Period, 1), o0 = iOpen(_Symbol, _Period, 1);
   double h1 = iHigh(_Symbol, _Period, 2), l1 = iLow(_Symbol, _Period, 2);
   double c1 = iClose(_Symbol, _Period, 2), o1 = iOpen(_Symbol, _Period, 2);
   
   // Get ATR data
   double atr_val[];
   CopyBuffer(m_atr_handle, 0, 1, 1, atr_val);
   
   // Range 10 for REL_RANGE
   int high_idx = iHighest(_Symbol, _Period, MODE_HIGH, 10, 1);
   int low_idx  = iLowest(_Symbol, _Period, MODE_LOW, 10, 1);
   double range_10 = iHigh(_Symbol, _Period, high_idx) - iLow(_Symbol, _Period, low_idx);

   // FEATURE CONTENT (ORDER MUST BE THE SAME AS PYTHON)
   // 0: BODY_SIZE
   features[0] = (float)(MathAbs(c0 - o0) / (h0 - l0 + 1e-9));
   // 1: REL_RANGE
   features[1] = (float)((h0 - l0) / (range_10 + 1e-9));
   // 2: is_outside_bull
   features[2] = (l0 < l1 && h0 > h1 && c0 > h1) ? 1.0f : 0.0f;
   // 3: is_outside_bear
   features[3] = (h0 > h1 && l0 < l1 && c0 < l1) ? 1.0f : 0.0f;
   // 4: ATR
   features[4] = (float)atr_val[0];
   // 5: RELATIVE_ATR
   features[5] = (float)((h0 - l0) / (atr_val[0] + 1e-9));
   // 6: DAY (0=Mon, 6=Sun in MQL5, adjust if necessary)
   MqlDateTime dt;
   TimeCurrent(dt);
   features[6] = (float)dt.day_of_week;
   // 7: HOUR
   features[7] = (float)dt.hour;
   // 8: VOL_CHANGE (Simple pct change volume candle 1 vs 2)
   long v0 = iVolume(_Symbol, _Period, 1);
   long v1 = iVolume(_Symbol, _Period, 2);
   features[8] = (float)((double)(v0 - v1) / (v1 + 1e-9));
   // 9: PREV_DIR (1 if previous candle was Bull, -1 if Bear)
   features[9] = (c1 > o1) ? 1.0f : -1.0f;

   return true;
}

void ExecuteOrder(ENUM_ORDER_TYPE type, double lotSize)
{
   // --- 1. Validasi Volume & Presisi (Standard Dinamis) ---
   double minLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotStep  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double maxLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   // Hitung presisi lot secara dinamis (0.01 = 2 desimal, 0.1 = 1 desimal)
   int lotPrecision = 0;
   double tempStep = lotStep;
   while(tempStep < 1.0 && lotPrecision < 5) { tempStep *= 10; lotPrecision++; }

   lotSize = MathMax(minLot, MathMin(maxLot, lotSize)); 
   lotSize = MathRound(lotSize / lotStep) * lotStep;     
   lotSize = NormalizeDouble(lotSize, lotPrecision);

   // --- 2. Cek Kecukupan Margin (Proteksi Babi Ngepet) ---
   double marginRequired;
   if(!OrderCalcMargin(type, _Symbol, lotSize, (type == ORDER_TYPE_BUY ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID)), marginRequired))
   {
      Print("Gagal hitung margin!");
      return;
   }
   
   if(marginRequired > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      Print("Margin tidak cukup! Butuh: ", marginRequired, " Tersedia: ", AccountInfoDouble(ACCOUNT_MARGIN_FREE));
      return;
   }

   // --- 3. Ambil Harga & Level High/Low ---
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double h0 = iHigh(_Symbol, _Period, 1);
   double l0 = iLow(_Symbol, _Period, 1);

   // --- 4. Proteksi Jarak Stop Level & Freeze Level ---
   double stopsLevel  = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double freezeLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * _Point;
   
   // Gunakan buffer minimal 2 pips di atas aturan broker agar aman saat spread fluktuatif
   double minDistance = MathMax(stopsLevel, freezeLevel) + (20 * _Point); // Buffer 20 points/2 pips

   double sl, tp;
   if(type == ORDER_TYPE_BUY)
   {
      sl = l0;
      // Validasi SL: Minimal harus di bawah Ask sejauh minDistance
      if(price - sl < minDistance) sl = price - minDistance;
      
      // Hitung TP berdasarkan Risk:Reward
      tp = price + (price - sl) * InpRR;
      // Validasi TP: Minimal harus di atas Ask sejauh minDistance
      if(tp - price < minDistance) tp = price + minDistance;
      
      // Eksekusi
      if(!m_trade.Buy(lotSize, _Symbol, price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Babi Ngepet Order 🐖"))
         Print("Gagal Buy: ", m_trade.ResultRetcodeDescription());
   }
   else
   {
      sl = h0;
      // Validasi SL: Minimal harus di atas Bid sejauh minDistance
      if(sl - price < minDistance) sl = price + minDistance;
      
      // Hitung TP berdasarkan Risk:Reward
      tp = price - (sl - price) * InpRR;
      // Validasi TP: Minimal harus di bawah Bid sejauh minDistance
      if(price - tp < minDistance) tp = price - minDistance;
      
      // Eksekusi
      if(!m_trade.Sell(lotSize, _Symbol, price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Babi Ngepet Order 🐖"))
         Print("Gagal Sell: ", m_trade.ResultRetcodeDescription());
   }
}