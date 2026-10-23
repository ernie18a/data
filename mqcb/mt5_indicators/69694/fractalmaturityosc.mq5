//+------------------------------------------------------------------+
//|                                    Ritz FractalMaturityOsc.mq5   |
//|                                    (c) 2026, Spiritual Trading   |
//|                         FRACTAL MATURITY OSCILLATOR (FMO) v4.5   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Ritz Spiritual Trading"
#property version   "1.0"
#property description "FMO - Visual Precision & Performance Optimized"

#property indicator_separate_window
#property indicator_buffers 16
#property indicator_plots   5

//--- PLOT 1: FMO Line
#property indicator_label1  "FMO Line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLime, clrDodgerBlue, clrOrange, clrRed, clrGray
#property indicator_width1  2

//--- PLOT 2: FMO Area Fill
#property indicator_label2  "FMO Area"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrLime, clrDodgerBlue, clrOrange, clrRed, clrGray
#property indicator_width2  2

//--- PLOT 3: Life Energy
#property indicator_label3  "Life Energy"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWhiteSmoke
#property indicator_style3  STYLE_DOT
#property indicator_width3  3

//--- PLOT 4: Maturity Zones (Background Filling)
#property indicator_label4  "Maturity Zones"
#property indicator_type4   DRAW_FILLING
#property indicator_color4  clrDarkSlateGray, clrBlack

//--- PLOT 5: Critical Points (Cycle 39 & 49)
#property indicator_label5  "Critical Points (Cycle 39 & 49)"
#property indicator_type5   DRAW_COLOR_SECTION
#property indicator_color5  clrWhite, clrGold, clrMagenta
#property indicator_width5  3

//--- Buffers
double FMOLineBuffer[], FMOLineColorBuffer[], FMOAreaBuffer[], FMOAreaColorBuffer[];
double LifeEnergyBuffer[], MaturityZonesUpBuffer[], MaturityZonesDownBuffer[];
double CriticalPointsBuffer[], CriticalPointsColorBuffer[];
double FractalUpBuffer[], FractalDownBuffer[], HHCounterBuffer[], LLCounterBuffer[];
double CycleCounterBuffer[], FMORawBuffer[], TempBuffer[];

//--- Global Variables
int    lastBuyBar = 0, lastSellBar = 0;
int    f_counter = 0;
datetime lastAlertTime = 0; // Untuk mencegah double alert pada satu bar

enum LifePhase { PHASE_BABY, PHASE_ADULT, PHASE_MATURE, PHASE_ELDERLY };

//--- Input Parameters
input int      FractalDepth = 2;          // Jumlah bar untuk fractal
input int      MaxFractals = 490;         // Maksimal fractal
input bool     ShowAlerts = true;         // Tampilkan alert
input bool     ShowDashboard = true;      // Tampilkan dashboard
input bool     ShowSignals = true;        // Tampilkan arrow
input int      SignalSensitivity = 1;     // Sensitivitas (1-5)
input color    DashColor = clrWhite;      // Warna teks dashboard Adaptif
input int      DashX = 3;                 // Posisi X
input int      DashY = 110;               // Posisi Y


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "FMO v1.0 Spiritual");
   IndicatorSetInteger(INDICATOR_DIGITS, 1);

   SetIndexBuffer(0, FMOLineBuffer);
   SetIndexBuffer(1, FMOLineColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, FMOAreaBuffer);
   SetIndexBuffer(3, FMOAreaColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, LifeEnergyBuffer);
   SetIndexBuffer(5, MaturityZonesUpBuffer);
   SetIndexBuffer(6, MaturityZonesDownBuffer);
   SetIndexBuffer(7, CriticalPointsBuffer);
   SetIndexBuffer(8, CriticalPointsColorBuffer, INDICATOR_COLOR_INDEX);

// Calculations Buffers
   SetIndexBuffer(9, FractalUpBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, FractalDownBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(11, HHCounterBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(12, LLCounterBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(13, CycleCounterBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(14, FMORawBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(15, TempBuffer, INDICATOR_CALCULATIONS);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "FMO_D_");
   if(reason == REASON_REMOVE)
      ObjectsDeleteAll(0, "FMO_A_");
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
   if(rates_total < 50)
      return(0);

   int start = prev_calculated - 1;
   if(start < FractalDepth)
     {
      start = FractalDepth;
      f_counter = 0;
      ArrayInitialize(HHCounterBuffer, 0);
      ArrayInitialize(LLCounterBuffer, 0);
     }

   for(int i = start; i < rates_total; i++)
     {
      //--- DETEKSI FRACTAL (logika asli yang presisi)
      bool isUp = true, isDown = true;
      for(int j=1; j<=FractalDepth; j++)
        {
         if(high[i-j] >= high[i] || (i+j < rates_total && high[i+j] >= high[i]))
            isUp = false;
         if(low[i-j] <= low[i] || (i+j < rates_total && low[i+j] <= low[i]))
            isDown = false;
        }

      //--- Akumulasi Counter
      HHCounterBuffer[i] = HHCounterBuffer[i-1];
      LLCounterBuffer[i] = LLCounterBuffer[i-1];
      CycleCounterBuffer[i] = CycleCounterBuffer[i-1];

      if(isUp)
        {
         f_counter++;
         HHCounterBuffer[i] += 1.0;
         CycleCounterBuffer[i] = (double)(f_counter % 50);
        }
      if(isDown)
        {
         f_counter++;
         LLCounterBuffer[i] += 1.0;
         CycleCounterBuffer[i] = (double)(f_counter % 50);
        }

      //--- Perhitungan Maturity (Lookback Period 49)
      double bM = 50.0, sM = 50.0;
      int lookback = 49;
      if(i >= lookback)
        {
         double diffH = HHCounterBuffer[i] - HHCounterBuffer[i-lookback];
         double diffL = LLCounterBuffer[i] - LLCounterBuffer[i-lookback];
         bM = (diffH / lookback) * 1000.0; // Scaled for visual sensitivity
         sM = (diffL / lookback) * 1000.0;
        }

      // Normalisasi FMO agar tetap di range 0-100
      double fmo = MathMax(0, MathMin(100, (bM - sM) + 50.0));
      FMOLineBuffer[i] = fmo;
      FMOAreaBuffer[i] = fmo;

      // Fase & Warna
      LifePhase phase = GetPhase(fmo);
      int cIdx = GetColor(phase);
      FMOLineColorBuffer[i] = cIdx;
      FMOAreaColorBuffer[i] = cIdx;

      // Life Energy (Momentum based)
      double mom = (i > 10) ? (close[i] - close[i-10]) : 0;
      LifeEnergyBuffer[i] = MathMax(0, MathMin(100, 50.0 + (fmo-50.0)*0.8 + (mom/_Point)*0.01));

      // --- LOGIKA DETEKSI DIVERGENSI (Taruh di dalam loop OnCalculate) ---
      if(i == rates_total - 1 && i > 5)
        {
         double fmoSlope = FMOLineBuffer[i] - FMOLineBuffer[i-2];
         double engSlope = LifeEnergyBuffer[i] - LifeEnergyBuffer[i-2];

         string divType = "NORMAL";
         color  divColor = clrGray;

         // Deteksi Bearish Divergence
         if(fmoSlope > 0.5 && engSlope < -1.0 && FMOLineBuffer[i] > 60)
           {
            divType = "BEARISH DIV";
            divColor = clrLightPink;
           }
         // Deteksi Bullish Divergence
         else
            if(fmoSlope < -0.5 && engSlope > 1.0 && FMOLineBuffer[i] < 40)
              {
               divType = "BULLISH DIV";
               divColor = clrLightCyan;
              }

         // Update Dashboard menggunakan fungsi SetLabel yang sudah ada
         SetLabel("FMO_D_4", "Divergence: " + divType, DashX+10, DashY+80, divColor);

         // Logika Alert agar tidak berulang setiap tick
         if(divType != "NORMAL" && ShowAlerts && lastAlertTime != time[i])
           {
            Alert("FMO " + divType + " terdeteksi pada " + Symbol());
            lastAlertTime = time[i];
           }
        }

      // Background Filling
      MaturityZonesUpBuffer[i] = 100;
      MaturityZonesDownBuffer[i] = 0;

      // Critical Points
      int cp = (int)CycleCounterBuffer[i];
      CriticalPointsBuffer[i] = (cp == 39 || cp == 49) ? fmo : EMPTY_VALUE;
      CriticalPointsColorBuffer[i] = (cp == 39) ? 1 : 2;

      //--- SIGNAL GENERATOR (Hanya untuk Bar Terakhir)
      if(ShowSignals && i == rates_total - 1)
         DrawSignal(i, fmo, FMOLineBuffer[i-1], phase, bM, sM, time, high, low);
     }

   if(ShowDashboard)
      UpdateDashboard(rates_total-1);

   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignal(int i, double fmo, double prev, LifePhase phase, double bM, double sM,
                const datetime &t[], const double &h[], const double &l[])
  {
   double net = bM - sM;
   double body = MathMax(h[i]-l[i], _Point*20);
   int gap = SignalSensitivity * 3;

// BUY: Baby Phase + FMO Hook Up
   if(net > 20 && phase == PHASE_BABY && fmo > prev && i - lastBuyBar > gap)
     {
      if(CreateObj("BUY", i, t[i], l[i]-body, clrLime, 233))
        {
         lastBuyBar = i;
         if(ShowAlerts)
            Alert("FMO BUY Signal @ ", Symbol());
        }
     }
// SELL: Elderly Phase + FMO Hook Down
   if(net < -20 && phase == PHASE_ELDERLY && fmo < prev && i - lastSellBar > gap)
     {
      if(CreateObj("SELL", i, t[i], h[i]+body, clrRed, 234))
        {
         lastSellBar = i;
         if(ShowAlerts)
            Alert("FMO SELL Signal @ ", Symbol());
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateObj(string type, int i, datetime t, double p, color clr, int code)
  {
   string fmoobj = "FMO_A_" + type + "_" + IntegerToString(i);
   if(ObjectFind(0, fmoobj) >= 0)
      return false;
   ObjectCreate(0, fmoobj, OBJ_ARROW, 0, t, p);
   ObjectSetInteger(0, fmoobj, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, fmoobj, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, fmoobj, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, fmoobj, OBJPROP_SELECTABLE, false);
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
      else
         if(fmoSlope < -0.5 && engSlope > 1.0 && FMOLineBuffer[i] < 40)
           {
            divTxt = "BULLISH DIV";
            divClr = clrLightCyan;
           }
     }

// --- BACKGROUND (Ukuran Y) ---
   if(ObjectFind(0, n+"BG") < 0)
     {
      ObjectCreate(0, n+"BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, n+"BG", OBJPROP_XSIZE, 200);
      ObjectSetInteger(0, n+"BG", OBJPROP_YSIZE, 130);
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

// Baris untuk Divergence
   SetLabel(n+"4", "Divergence: " + divTxt, x+10, y+80, divClr);

// Rekomendasi Tambahan (Opsional)
   string rec = (divTxt != "NORMAL") ? "WAIT/REVERSAL" : "FOLLOW TREND";
   SetLabel(n+"5", "Action: " + rec, x+10, y+105, (divTxt != "NORMAL") ? clrYellow : clrWhite);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
LifePhase GetPhase(double v)
  {
   if(v < 33)
      return PHASE_BABY;
   if(v < 49)
      return PHASE_ADULT;
   if(v < 65)
      return PHASE_MATURE;
   return PHASE_ELDERLY;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetColor(LifePhase p)
  {
   switch(p)
     {
      case PHASE_BABY:
         return 0;
      case PHASE_ADULT:
         return 1;
      case PHASE_MATURE:
         return 2;
      case PHASE_ELDERLY:
         return 3;
      default:
         return 4;
     }
  }
//+------------------------------------------------------------------+
