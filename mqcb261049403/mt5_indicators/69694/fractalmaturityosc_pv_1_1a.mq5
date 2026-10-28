//+------------------------------------------------------------------+
//|                                    Ritz FractalMaturityOsc.mq5   |
//|                                    (c) 2026, Spiritual Trading   |
//|                         FRACTAL MATURITY OSCILLATOR (FMO) v1.1   |
//|                         WITH COMPLETE DASHBOARD                  |
//+------------------------------------------------------------------+
#property copyright  "Copyright 2026, Ritz Spiritual Trading"
#property link       "https://www.mql5.com/en/users/ritzfalih/seller"
#property version    "1.1"
#property indicator_separate_window
#property indicator_buffers 16
#property indicator_plots   5

//--- PLOT 1: FMO Area (Histogram harus di depan agar tidak tertutup)
#property indicator_label2  "FMO Area"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrLime, clrDodgerBlue, clrOrange, clrRed, clrGray
#property indicator_width2  2

//--- PLOT 2: FMO Line
#property indicator_label1  "FMO Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLime, clrDodgerBlue, clrOrange, clrRed, clrGray
#property indicator_width1  2

//--- PLOT 3: Life Energy (Smoothed)
#property indicator_label3  "Life Energy"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSeashell
#property indicator_style3  STYLE_DOT
#property indicator_width3  2

//--- PLOT 4: Maturity Zones (Background Filling)
#property indicator_label4  "Maturity Zones"
#property indicator_type4   DRAW_FILLING
#property indicator_color4  (color)0x0A0F14, clrBlack

//--- PLOT 5: Critical Points
#property indicator_label5  "Critical Points"
#property indicator_type5   DRAW_COLOR_SECTION
#property indicator_color5  clrWhite, clrGold, clrMagenta
#property indicator_width5  3

//--- Buffers
double FMOLineBuffer[], FMOLineColorBuffer[], FMOAreaBuffer[], FMOAreaColorBuffer[];
double LifeEnergyBuffer[], MaturityZonesUpBuffer[], MaturityZonesDownBuffer[];
double CriticalPointsBuffer[], CriticalPointsColorBuffer[];
double FractalUpBuffer[], FractalDownBuffer[], HHCounterBuffer[], LLCounterBuffer[];
double CycleCounterBuffer[], FMORawBuffer[], TempBuffer[];

//--- Global Handles & Variables
int      atrHandle;
double   atrValue = 0;
datetime lastAlertTime = 0;
int      lastBuyBar = 0, lastSellBar = 0;
int      f_counter = 0;

enum LifePhase { PHASE_BABY, PHASE_ADULT, PHASE_MATURE, PHASE_ELDERLY };

//--- Input Parameters
input int      FractalDepth     = 2;      // Fractal Depth
input int      ATR_Period       = 14;     // ATR for Energy Smoothing
input bool     ShowAlerts       = true;   // Alerts
input bool     ShowDashboard    = true;   // Dashboard
input int      SignalSensitivity= 2;      // Sensitivity (1-5)
input color    DashColor        = clrWhite;// Dashboard Text
input int      DashX            = 3;     // X Position
input int      DashY            = 100;     // Y Position
input bool     ShowSignals      = true;   // Tampilkan arrow

//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "FMO v5.0 [Spiritual]");
   IndicatorSetInteger(INDICATOR_DIGITS, 1);

   // Mapping Buffers (Urutan sangat krusial untuk DRAW_FILLING)
   SetIndexBuffer(0, FMOLineBuffer);
   SetIndexBuffer(1, FMOLineColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, FMOAreaBuffer);
   SetIndexBuffer(3, FMOAreaColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, LifeEnergyBuffer);
   SetIndexBuffer(5, MaturityZonesUpBuffer);
   SetIndexBuffer(6, MaturityZonesDownBuffer);
   SetIndexBuffer(7, CriticalPointsBuffer);
   SetIndexBuffer(8, CriticalPointsColorBuffer, INDICATOR_COLOR_INDEX);
   
   // Calculation Buffers
   SetIndexBuffer(9, HHCounterBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, LLCounterBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(11, CycleCounterBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(12, FractalUpBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(13, FractalDownBuffer, INDICATOR_CALCULATIONS);
   
   atrHandle = iATR(_Symbol, _Period, ATR_Period);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   if(rates_total < 50) return(0);

   // Update ATR for smoothing
   double atrBuf[1];
   if(CopyBuffer(atrHandle, 0, 0, 1, atrBuf) > 0) atrValue = atrBuf[0];

   int start = (prev_calculated > 0) ? prev_calculated - 1 : FractalDepth;

   for(int i = start; i < rates_total; i++)
   {
      // 1. Logika Fractal & Counter
      bool isUp = true, isDown = true;
      for(int j=1; j<=FractalDepth; j++) {
         if(i-j < 0 || high[i-j] >= high[i] || (i+j < rates_total && high[i+j] >= high[i])) isUp = false;
         if(i-j < 0 || low[i-j] <= low[i] || (i+j < rates_total && low[i+j] <= low[i])) isDown = false;
      }

      HHCounterBuffer[i] = (i > 0) ? HHCounterBuffer[i-1] : 0;
      LLCounterBuffer[i] = (i > 0) ? LLCounterBuffer[i-1] : 0;
      
      if(isUp) 
      {
         f_counter++;
         HHCounterBuffer[i] += 1.0;
      }
      if(isDown) 
      {
         f_counter++;
         LLCounterBuffer[i] += 1.0;
      }

      // 2. FMO Calculation
      int lookback = 49;
      double fmo = 50.0;
      if(i >= lookback) {
         double dH = HHCounterBuffer[i] - HHCounterBuffer[i-lookback];
         double dL = LLCounterBuffer[i] - LLCounterBuffer[i-lookback];
         fmo = MathMax(0, MathMin(100, ((dH - dL) * 10.0) + 50.0));
      }

      FMOLineBuffer[i] = fmo;
      FMOAreaBuffer[i] = fmo;
      
      LifePhase phase = GetPhase(fmo);
      int cIdx = GetColor(phase);
      FMOLineColorBuffer[i] = (double)cIdx;
      FMOAreaColorBuffer[i] = (double)cIdx;

      // 3. Life Energy Smoothing (Refactored)
      double priceDiff = (i >= 10) ? (close[i] - close[i-10]) : 0;
      double normMom = (atrValue > 0) ? (priceDiff / atrValue) * 5.0 : 0;
      double rawEnergy = 50.0 + (fmo - 50.0) * 0.5 + (normMom * 2.0);
      rawEnergy = MathMax(5, MathMin(95, rawEnergy));
      
      double alpha = 0.15; // Smoothing factor
      LifeEnergyBuffer[i] = (i > 0) ? (alpha * rawEnergy) + ((1.0 - alpha) * LifeEnergyBuffer[i-1]) : rawEnergy;

      // 4. Critical Points & Zones
      int cyclePos = (int)(f_counter % 50);
      CycleCounterBuffer[i] = (double)cyclePos;
      
      MaturityZonesUpBuffer[i] = 100;
      MaturityZonesDownBuffer[i] = 0;
      
      CriticalPointsBuffer[i] = (cyclePos == 39 || cyclePos == 49) ? fmo : EMPTY_VALUE;
      CriticalPointsColorBuffer[i] = (cyclePos == 39) ? 1 : 2;

      // 5. Signal Detection
      if(i == rates_total - 1 && ShowSignals)
         DrawSignal(i, fmo, FMOLineBuffer[i-1], phase, time, high, low);
   }

   if(ShowDashboard) UpdateDashboard(rates_total-1);

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Draw Signal Arrow                                                |
//+------------------------------------------------------------------+
void DrawSignal(int i, double fmo, double prev, LifePhase phase, const datetime &t[], const double &h[], const double &l[])
{
   double body = MathMax(h[i]-l[i], _Point*20);
   int gap = SignalSensitivity * 5;

   if(phase == PHASE_BABY && fmo > prev && i - lastBuyBar > gap) {
      if(CreateObj("BUY", i, t[i], l[i]-body, clrLime, 233)) lastBuyBar = i;
   }
   if(phase == PHASE_ELDERLY && fmo < prev && i - lastSellBar > gap) {
      if(CreateObj("SELL", i, t[i], h[i]+body, clrRed, 234)) lastSellBar = i;
   }
}

//+------------------------------------------------------------------+
//| Create Arrow Object                                              |
//+------------------------------------------------------------------+
bool CreateObj(string type, int i, datetime t, double p, color clr, int code)
{
   string name = "FMO_A_" + type + "_" + IntegerToString(i);
   if(ObjectFind(0, name) >= 0) return false;
   ObjectCreate(0, name, OBJ_ARROW, 0, t, p);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   return true;
}

//+------------------------------------------------------------------+
//| Update Dashboard LENGKAP dengan ENERGY                           |
//+------------------------------------------------------------------+
void UpdateDashboard(int i)
{
   string n = "FMO_D_";
   int x = DashX, y = DashY;

// --- LOGIKA DETEKSI DIVERGENSI UNTUK DASHBOARD ---
   string divTxt = "NORMAL";
   color divClr = clrGray;

   if(i > 2)
     {
      double fmoSlope = FMOLineBuffer[i] - FMOLineBuffer[i-2];
      double engSlope = LifeEnergyBuffer[i] - LifeEnergyBuffer[i-2];

      // Bearish Divergence (FMO naik tapi Energy melemah di zona jenuh)
      if(fmoSlope > 0.5 && engSlope < -1.0 && FMOLineBuffer[i] > 60)
        {
         divTxt = "BEARISH DIV";
         divClr = clrLightPink;
        }
      // Bullish Divergence (FMO turun tapi Energy menguat di zona bawah)
      else if(fmoSlope < -0.5 && engSlope > 1.0 && FMOLineBuffer[i] < 40)
        {
         divTxt = "BULLISH DIV";
         divClr = clrLightCyan;
        }
     }

// --- BACKGROUND (Ukuran diperbesar untuk Energy) ---
   if(ObjectFind(0, n+"BG") < 0)
     {
      ObjectCreate(0, n+"BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, n+"BG", OBJPROP_XSIZE, 250);
      ObjectSetInteger(0, n+"BG", OBJPROP_YSIZE, 175);
      ObjectSetInteger(0, n+"BG", OBJPROP_BGCOLOR, clrBlack);
      ObjectSetInteger(0, n+"BG", OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, n+"BG", OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, n+"BG", OBJPROP_ZORDER, 10);
     }

// --- LABELS ---
   SetLabel(n+"1", "FMO Value: " + DoubleToString(FMOLineBuffer[i], 1) + "%", x+10, y+10, DashColor);
   SetLabel(n+"2", "Cycle: " + IntegerToString((int)CycleCounterBuffer[i]) + "/49", x+10, y+30, clrCyan);

// Status Phase
   string pTxt = "NEUTRAL";
   color pClr = clrWhite;
   LifePhase p = GetPhase(FMOLineBuffer[i]);
   if(p==PHASE_BABY)
     {
      pTxt="BABY";
      pClr=clrLime;
     }
   if(p==PHASE_ADULT)
     {
      pTxt="ADULT";
      pClr=clrDodgerBlue;
     }
   if(p==PHASE_MATURE)
     {
      pTxt="MATURE";
      pClr=clrOrange;
     }
   if(p==PHASE_ELDERLY)
     {
      pTxt="ELDERLY";
      pClr=clrRed;
     }

   SetLabel(n+"3", "Phase: " + pTxt, x+10, y+55, pClr);

// BARIS UNTUK ENERGY (BARU)
   SetLabel(n+"6", "Energy: " + DoubleToString(LifeEnergyBuffer[i], 1) + "%", x+10, y+80, clrWhiteSmoke);

// Baris untuk Divergence (digeser ke bawah karena Energy sudah ditambahkan)
   SetLabel(n+"4", "Divergence: " + divTxt, x+10, y+105, divClr);

// Rekomendasi Tambahan (digeser ke bawah)
   string rec = (divTxt != "NORMAL") ? "WAIT/REVERSAL" : "FOLLOW TREND";
   SetLabel(n+"5", "Action: " + rec, x+10, y+130, (divTxt != "NORMAL") ? clrYellow : clrWhite);
}

//+------------------------------------------------------------------+
//| Set Label Helper                                                 |
//+------------------------------------------------------------------+
void SetLabel(string name, string txt, int x, int y, color clr)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
}

//+------------------------------------------------------------------+
//| Helper Functions                                                 |
//+------------------------------------------------------------------+
LifePhase GetPhase(double v) {
   if(v < 30) return PHASE_BABY;
   if(v < 50) return PHASE_ADULT;
   if(v < 70) return PHASE_MATURE;
   return PHASE_ELDERLY;
}

int GetColor(LifePhase p) {
   switch(p) {
      case PHASE_BABY: return 0;
      case PHASE_ADULT: return 1;
      case PHASE_MATURE: return 2;
      case PHASE_ELDERLY: return 3;
      default: return 4;
   }
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, "FMO_D_");
   if(reason == REASON_REMOVE) ObjectsDeleteAll(0, "FMO_A_");
   ChartRedraw(0);
}

//+------------------------------------------------------------------+