//+------------------------------------------------------------------+
//|                                   TimeFrame_Quality_Analyzer.mq5 |
//|                                Copyright 2026, Rajesh Kumar Nait |
//|                         https://www.mql5.com/en/users/rajeshnait |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- inputs
input int    InpWindow        = 100;    // Rolling Window Length
input int    InpEntropyBins   = 20;     // Entropy Bin Count
input double InpWeightSNR     = 0.25;   // Weight: SNR
input double InpWeightAC      = 0.15;   // Weight: Autocorrelation
input double InpWeightHurst   = 0.25;   // Weight: Hurst
input double InpWeightDER     = 0.20;   // Weight: DER
input double InpWeightEntropy = 0.15;   // Weight: Inverse Entropy
input int    InpPanelX        = 10;     // Panel X Position
input int    InpPanelY        = 30;     // Panel Y Position

string P = "TQA_";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   CreatePanel();
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--) {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, P) == 0)
         ObjectDelete(0, name);
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[]) {
//---
   if(rates_total < InpWindow + 2)
      return(0);

   int last = rates_total - 1;

//--- build closes and returns for latest window only
   double closes[];
   ArrayResize(closes, InpWindow + 1);
   for(int j = 0; j <= InpWindow; j++)
      closes[j] = close[last - InpWindow + j];

   double returns[];
   ArrayResize(returns, InpWindow);
   for(int j = 0; j < InpWindow; j++)
      returns[j] = closes[j + 1] - closes[j];

   double snr     = CalcSNR(closes, InpWindow + 1);
   double ac      = CalcAutocorrelation(returns, InpWindow);
   double hurst   = CalcHurst(returns, InpWindow);
   double der     = CalcDER(closes, InpWindow + 1);
   double entropy = CalcEntropy(returns, InpWindow, InpEntropyBins);
   double tqs     = CalcTQS(snr, ac, hurst, der, entropy);

   UpdatePanel(snr, ac, hurst, der, entropy, tqs);
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcSNR(double &data[], int len) {
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
   for(int i = 0; i < len; i++) {
      sumX  += i;
      sumY  += data[i];
      sumXY += i * data[i];
      sumX2 += (double)i * i;
   }
   double n = (double)len;
   double denom = n * sumX2 - sumX * sumX;
   if(MathAbs(denom) < 1e-20) return 0;
   double slope     = (n * sumXY - sumX * sumY) / denom;
   double intercept = (sumY - slope * sumX) / n;
   double meanY = sumY / n;
   double ssExp = 0, ssRes = 0;
   for(int i = 0; i < len; i++) {
      double fitted = intercept + slope * i;
      ssExp += (fitted - meanY) * (fitted - meanY);
      ssRes += (data[i] - fitted) * (data[i] - fitted);
   }
   if(ssRes < 1e-20) return 10.0;
   return MathMin(ssExp / ssRes, 10.0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcAutocorrelation(double &ret[], int len) {
   if(len < 3) return 0;
   double mean = 0;
   for(int i = 0; i < len; i++) mean += ret[i];
   mean /= len;
   double num = 0, den = 0;
   for(int i = 0; i < len; i++) {
      double d = ret[i] - mean;
      den += d * d;
      if(i < len - 1)
         num += d * (ret[i + 1] - mean);
   }
   if(MathAbs(den) < 1e-20) return 0;
   return num / den;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcHurst(double &ret[], int len) {
   if(len < 20) return 0.5;
   int sizes[];
   int cnt = 0;
   for(int s = 8; s <= len / 2; s *= 2) {
      cnt++;
      ArrayResize(sizes, cnt);
      sizes[cnt - 1] = s;
   }
   if(cnt < 2) return 0.5;

   double lnN[], lnRS[];
   ArrayResize(lnN, cnt);
   ArrayResize(lnRS, cnt);

   for(int si = 0; si < cnt; si++) {
      int w = sizes[si];
      int nw = len / w;
      double rsSum = 0;
      int valid = 0;
      for(int b = 0; b < nw; b++) {
         int st = b * w;
         double m = 0;
         for(int k = 0; k < w; k++) m += ret[st + k];
         m /= w;
         double cum = 0, mx = -1e30, mn = 1e30, ss = 0;
         for(int k = 0; k < w; k++) {
            double d = ret[st + k] - m;
            cum += d;
            ss  += d * d;
            if(cum > mx) mx = cum;
            if(cum < mn) mn = cum;
         }
         double S = MathSqrt(ss / w);
         if(S > 1e-20) {
            rsSum += (mx - mn) / S;
            valid++;
         }
      }
      lnN[si]  = MathLog((double)w);
      lnRS[si] = (valid > 0) ? MathLog(rsSum / valid) : 0;
   }

   double sx = 0, sy = 0, sxy = 0, sx2 = 0;
   for(int i = 0; i < cnt; i++) {
      sx += lnN[i];
      sy += lnRS[i];
      sxy += lnN[i] * lnRS[i];
      sx2 += lnN[i] * lnN[i];
   }
   double n = (double)cnt;
   double dd = n * sx2 - sx * sx;
   if(MathAbs(dd) < 1e-20) return 0.5;
   return MathMax(0.0, MathMin(1.0, (n * sxy - sx * sy) / dd));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcDER(double &data[], int len) {
   if(len < 2) return 0;
   double net = MathAbs(data[len - 1] - data[0]);
   double path = 0;
   for(int i = 1; i < len; i++)
      path += MathAbs(data[i] - data[i - 1]);
   if(path < 1e-20) return 0;
   return net / path;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcEntropy(double &ret[], int len, int bins) {
   if(len < 2 || bins < 2) return 1.0;
   double mn = ret[0], mx = ret[0];
   for(int i = 1; i < len; i++) {
      if(ret[i] < mn) mn = ret[i];
      if(ret[i] > mx) mx = ret[i];
   }
   double rng = mx - mn;
   if(rng < 1e-20) return 0;

   int c[];
   ArrayResize(c, bins);
   ArrayInitialize(c, 0);
   for(int i = 0; i < len; i++) {
      int b = (int)((ret[i] - mn) / rng * (bins - 1));
      if(b < 0) b = 0;
      if(b >= bins) b = bins - 1;
      c[b]++;
   }
   double ent = 0, logB = MathLog((double)bins);
   if(logB < 1e-20) return 1.0;
   for(int i = 0; i < bins; i++) {
      if(c[i] > 0) {
         double p = (double)c[i] / (double)len;
         ent -= p * MathLog(p);
      }
   }
   return ent / logB;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcTQS(double snr, double ac, double hurst, double der, double entropy) {
   double nSNR    = MathMin(snr / 5.0, 1.0);
   double nAC     = MathMin(MathAbs(ac) * 3.0, 1.0);
   double nHurst  = MathMin(MathAbs(hurst - 0.5) * 4.0, 1.0);
   double nDER    = der;
   double nInvEnt = 1.0 - entropy;
   double tw = InpWeightSNR + InpWeightAC + InpWeightHurst +
               InpWeightDER + InpWeightEntropy;
   if(tw < 1e-10) tw = 1.0;
   return (InpWeightSNR * nSNR + InpWeightAC * nAC +
           InpWeightHurst * nHurst + InpWeightDER * nDER +
           InpWeightEntropy * nInvEnt) / tw;
}

//+------------------------------------------------------------------+
//| PANEL                                                            |
//+------------------------------------------------------------------+
void MakeRect(string name, int x, int y, int w, int h, color bg, color bd) {
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,    x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,    y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE,        w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE,        h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,      bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, bd);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE,  BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK,         false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MakeLabel(string name, int x, int y, string text,
               color clr, string font, int sz) {
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT,        text);
   ObjectSetString(0, name, OBJPROP_FONT,        font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   sz);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_BACK,       false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePanel() {
   int x = InpPanelX, y = InpPanelY;

   MakeRect(P+"BG",   x, y, 340, 360, C'15,15,28', C'50,50,80');
   MakeRect(P+"BG2",  x+2, y+2, 336, 356, C'20,20,35', C'50,50,80');

   int r = y + 8;
   MakeLabel(P+"T1", x+14, r, "TIMEFRAME QUALITY ANALYZER", clrWhite, "Arial Bold", 12);
   r += 22;
   MakeRect(P+"S1", x+8, r, 324, 1, clrDodgerBlue, clrDodgerBlue);
   r += 8;

   MakeLabel(P+"LW", x+14, r, "Window: "+IntegerToString(InpWindow)+"  |  TF: "+PeriodStr(),
             C'120,120,150', "Consolas", 9);
   r += 22;
   MakeRect(P+"S1b", x+8, r, 324, 1, C'40,40,60', C'40,40,60');
   r += 10;

// SNR row
   MakeLabel(P+"LSNR",  x+14, r, "SNR",              C'150,150,180', "Consolas", 10);
   MakeLabel(P+"VSNR",  x+160, r, "---",             clrDodgerBlue,  "Consolas", 10);
   MakeLabel(P+"ISNR",  x+230, r, "",                C'120,120,150', "Consolas", 9);
   r += 26;

// AC row
   MakeLabel(P+"LAC",   x+14, r, "Autocorrelation",  C'150,150,180', "Consolas", 10);
   MakeLabel(P+"VAC",   x+160, r, "---",             clrLime,        "Consolas", 10);
   MakeLabel(P+"IAC",   x+230, r, "",                C'120,120,150', "Consolas", 9);
   r += 26;

// Hurst row
   MakeLabel(P+"LHU",   x+14, r, "Hurst Exponent",   C'150,150,180', "Consolas", 10);
   MakeLabel(P+"VHU",   x+160, r, "---",             clrGold,        "Consolas", 10);
   MakeLabel(P+"IHU",   x+230, r, "",                clrGold,        "Consolas", 9);
   r += 26;

// DER row
   MakeLabel(P+"LDER",  x+14, r, "Dir. Efficiency",  C'150,150,180', "Consolas", 10);
   MakeLabel(P+"VDER",  x+160, r, "---",             clrMagenta,     "Consolas", 10);
   MakeLabel(P+"IDER",  x+230, r, "",                C'120,120,150', "Consolas", 9);
   r += 26;

// Entropy row
   MakeLabel(P+"LENT",  x+14, r, "Entropy (norm)",   C'150,150,180', "Consolas", 10);
   MakeLabel(P+"VENT",  x+160, r, "---",             clrOrangeRed,   "Consolas", 10);
   MakeLabel(P+"IENT",  x+230, r, "",                C'120,120,150', "Consolas", 9);
   r += 30;

// Separator
   MakeRect(P+"S2", x+8, r, 324, 2, clrDodgerBlue, clrDodgerBlue);
   r += 10;

// TQS
   MakeLabel(P+"LTQS", x+14, r, "QUALITY SCORE", clrWhite, "Arial Bold", 12);
   MakeLabel(P+"VTQS", x+200, r, "---",          clrWhite, "Arial Bold", 16);
   r += 28;

// Progress bar
   MakeRect(P+"BBG", x+14, r, 312, 18, C'35,35,50', C'55,55,75');
   MakeRect(P+"BFG", x+14, r, 1, 18, clrDodgerBlue, clrDodgerBlue);
   r += 28;

// Verdict
   MakeLabel(P+"VRD", x+14, r, "ANALYZING...", clrYellow, "Arial Bold", 15);
   r += 28;

// Detail lines
   MakeLabel(P+"D1", x+14, r, "", C'130,130,155', "Consolas", 9);
   r += 16;
   MakeLabel(P+"D2", x+14, r, "", C'130,130,155', "Consolas", 9);
   r += 16;
   MakeLabel(P+"D3", x+14, r, "", C'130,130,155', "Consolas", 9);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePanel(double snr, double ac, double hurst,
                 double der, double entropy, double tqs) {
// SNR
   ObjectSetString(0, P+"VSNR", OBJPROP_TEXT, DoubleToString(snr, 3));
   string sSNR = (snr > 2.0) ? "Strong" : (snr > 0.5) ? "Moderate" : "Weak";
   color  cSNR = (snr > 2.0) ? clrLime   : (snr > 0.5) ? clrGold   : clrRed;
   ObjectSetString(0, P+"ISNR", OBJPROP_TEXT, sSNR);
   ObjectSetInteger(0, P+"ISNR", OBJPROP_COLOR, cSNR);
   ObjectSetInteger(0, P+"VSNR", OBJPROP_COLOR, cSNR);

// AC
   ObjectSetString(0, P+"VAC", OBJPROP_TEXT, DoubleToString(ac, 4));
   bool acSig = MathAbs(ac) > 0.1;
   color cAC = acSig ? clrLime : clrRed;
   string sAC = acSig ? "Persistent" : "Noise";
   ObjectSetInteger(0, P+"VAC", OBJPROP_COLOR, cAC);
   ObjectSetString(0, P+"IAC", OBJPROP_TEXT, sAC);
   ObjectSetInteger(0, P+"IAC", OBJPROP_COLOR, cAC);

// Hurst
   ObjectSetString(0, P+"VHU", OBJPROP_TEXT, DoubleToString(hurst, 4));
   string sHU;
   color cHU;
   if(hurst > 0.55)      {
      sHU = "Trending";
      cHU = clrLime;
   } else if(hurst < 0.45) {
      sHU = "Mean-Revert";
      cHU = clrOrangeRed;
   } else                  {
      sHU = "Random Walk";
      cHU = clrGray;
   }
   ObjectSetString(0, P+"IHU", OBJPROP_TEXT, sHU);
   ObjectSetInteger(0, P+"IHU", OBJPROP_COLOR, cHU);
   ObjectSetInteger(0, P+"VHU", OBJPROP_COLOR, cHU);

// DER
   ObjectSetString(0, P+"VDER", OBJPROP_TEXT, DoubleToString(der, 4));
   color cDER = (der > 0.6) ? clrLime : (der > 0.3) ? clrGold : clrRed;
   string sDER = (der > 0.6) ? "Structured" : (der > 0.3) ? "Mixed" : "Noisy";
   ObjectSetInteger(0, P+"VDER", OBJPROP_COLOR, cDER);
   ObjectSetString(0, P+"IDER", OBJPROP_TEXT, sDER);
   ObjectSetInteger(0, P+"IDER", OBJPROP_COLOR, cDER);

// Entropy
   ObjectSetString(0, P+"VENT", OBJPROP_TEXT, DoubleToString(entropy, 4));
   color cENT = (entropy < 0.5) ? clrLime : (entropy < 0.75) ? clrGold : clrRed;
   string sENT = (entropy < 0.5) ? "Ordered" : (entropy < 0.75) ? "Mixed" : "Random";
   ObjectSetInteger(0, P+"VENT", OBJPROP_COLOR, cENT);
   ObjectSetString(0, P+"IENT", OBJPROP_TEXT, sENT);
   ObjectSetInteger(0, P+"IENT", OBJPROP_COLOR, cENT);

// TQS
   ObjectSetString(0, P+"VTQS", OBJPROP_TEXT, DoubleToString(tqs * 100, 1) + "%");
   int barW = (int)(tqs * 312);
   if(barW < 1) barW = 1;
   if(barW > 312) barW = 312;
   ObjectSetInteger(0, P+"BFG", OBJPROP_XSIZE, barW);

   color cTQS = (tqs > 0.65) ? clrLime : (tqs > 0.40) ? clrGold : clrRed;
   ObjectSetInteger(0, P+"BFG",  OBJPROP_BGCOLOR, cTQS);
   ObjectSetInteger(0, P+"VTQS", OBJPROP_COLOR, cTQS);

// Verdict
   string vrd;
   color cV;
   if(tqs > 0.65)      {
      vrd = "HIGH STRUCTURE";
      cV = clrLime;
   } else if(tqs > 0.40) {
      vrd = "MODERATE";
      cV = clrGold;
   } else                {
      vrd = "NOISE DOMINATED";
      cV = clrRed;
   }
   ObjectSetString(0, P+"VRD", OBJPROP_TEXT, vrd);
   ObjectSetInteger(0, P+"VRD", OBJPROP_COLOR, cV);

// Detail
   ObjectSetString(0, P+"D1", OBJPROP_TEXT,
                   "SNR=" + DoubleToString(snr,2) + " | AC=" + DoubleToString(ac,3));
   ObjectSetString(0, P+"D2", OBJPROP_TEXT,
                   "Hurst=" + DoubleToString(hurst,3) + " -> " + sHU);
   ObjectSetString(0, P+"D3", OBJPROP_TEXT,
                   "DER=" + DoubleToString(der,3) + " | Ent=" + DoubleToString(entropy,3));

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodStr() {
   ENUM_TIMEFRAMES tf = Period();
   switch(tf) {
   case PERIOD_M1:
      return "M1";
   case PERIOD_M2:
      return "M2";
   case PERIOD_M3:
      return "M3";
   case PERIOD_M4:
      return "M4";
   case PERIOD_M5:
      return "M5";
   case PERIOD_M6:
      return "M6";
   case PERIOD_M10:
      return "M10";
   case PERIOD_M12:
      return "M12";
   case PERIOD_M15:
      return "M15";
   case PERIOD_M20:
      return "M20";
   case PERIOD_M30:
      return "M30";
   case PERIOD_H1:
      return "H1";
   case PERIOD_H2:
      return "H2";
   case PERIOD_H3:
      return "H3";
   case PERIOD_H4:
      return "H4";
   case PERIOD_H6:
      return "H6";
   case PERIOD_H8:
      return "H8";
   case PERIOD_H12:
      return "H12";
   case PERIOD_D1:
      return "D1";
   case PERIOD_W1:
      return "W1";
   case PERIOD_MN1:
      return "MN1";
   default:
      return "??";
   }
}

//+------------------------------------------------------------------+
