//+------------------------------------------------------------------+
//|                                         Mediana Trendline EN.mq5 |
//|                                   Copyright 2026, Marian Beceanu |
//|                            https://www.mql5.com/en/users/zorbacc |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Marian Beceanu"
#property link      "https://www.mql5.com/en/users/zorbacc"
#property link      "https://forge.mql5.io"
#property version   "1.07"
#property indicator_chart_window
#property indicator_plots 0 

// --- INPUT PARAMETERS (Inputs)
// --- Enable or disable each Multi-Timeframe channel
input group "--- Timeframe Selection (True/False) ---"
input bool Show_MN1 = true;  // Show Monthly Channel (MN1)
input bool Show_W1  = true;  // Show Weekly Channel (W1)
input bool Show_D1  = true;  // Show Daily Channel (D1)
input bool Show_H4  = false; // Show H4 Channel
input bool Show_H1  = false; // Show H1 Channel
input bool Show_M30 = false; // Show M30 Channel
input bool Show_M15 = false; // Show M15 Channel

// --- Independent colors for each Timeframe
input group "--- Channel Colors ---"
input color Color_MN1 = clrRed;
input color Color_W1  = clrOrange;
input color Color_D1  = clrYellow;
input color Color_H4  = clrLime;
input color Color_H1  = clrAqua;
input color Color_M30 = clrDeepSkyBlue;
input color Color_M15 = clrMagenta;

input group "--- Line Style Settings ---"
input int             LineWidth = 2;              // Line width
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;    // Line style

// --- Prefix global pentru gestionarea obiectelor
string prefix = "MTF_Channel_";
datetime last_bar_time = 0; // Pentru optimizarea executiei la minut/bara noua

//+------------------------------------------------------------------+
//| Funcție ajutătoare pentru gestionarea liniilor unui Timeframe    |
//+------------------------------------------------------------------+
void UpdateChannelForTF(string tf_name, ENUM_TIMEFRAMES tf, color tf_color, bool show)
{
   string name_mediana = prefix + tf_name + "_Med";
   string name_high    = prefix + tf_name + "_High";
   string name_low     = prefix + tf_name + "_Low";

   // Regula de siguranta: Ascundem/Stergem canalul daca e dezactivat SAU daca TF-ul sursa e mai mic/egal cu cel al graficului curent
   if(!show || PeriodSeconds(tf) <= PeriodSeconds(_Period))
     {
      if(ObjectFind(0, name_mediana) >= 0) ObjectDelete(0, name_mediana);
      if(ObjectFind(0, name_high)    >= 0) ObjectDelete(0, name_high);
      if(ObjectFind(0, name_low)     >= 0) ObjectDelete(0, name_low);
      return;
     }

   // Resetam erorile din memorie înainte de interogarea istoricului
   ResetLastError();

   // Preluare date pentru Index 2 (Penultima candela inchisa)
   datetime time_p2 = iTime(_Symbol, tf, 2);
   double   open_2  = iOpen(_Symbol, tf, 2);
   double   close_2 = iClose(_Symbol, tf, 2);
   double   high_2  = iHigh(_Symbol, tf, 2);
   double   low_2   = iLow(_Symbol, tf, 2);

   // Preluare date pentru Index 1 (Ultima candela inchisa)
   datetime time_p1 = iTime(_Symbol, tf, 1);
   double   open_1  = iOpen(_Symbol, tf, 1);
   double   close_1 = iClose(_Symbol, tf, 1);

   // Daca terminalul nu a descarcat inca datele istorice pentru acest TF, oprim temporar executia
   if(GetLastError() != 0 || time_p2 <= 0 || time_p1 <= 0) 
      return;

   // Calculam mijlocul exact al lumânării pe axa timpului (in secunde)
   int half_period = PeriodSeconds(tf) / 2;
   datetime t1 = time_p2 + half_period;
   datetime t2 = time_p1 + half_period;

   // 1. Calcul puncte Linie Mediana & Panta (Slope)
   double p1_mediana = (open_2 + close_2) / 2.0;
   double p2_mediana = (open_1 + close_1) / 2.0;
   double slope = p2_mediana - p1_mediana;

   // 2. Calcul puncte Linie High
   double p1_high = high_2;
   double p2_high = p1_high + slope;

   // 3. Calcul puncte Linie Low
   double p1_low = low_2;
   double p2_low = p1_low + slope;

   // --- Creare / Actualizare Obiecte Grafice ---
   string lines[] = {name_mediana, name_high, name_low};
   double prices_p1[] = {p1_mediana, p1_high, p1_low};
   double prices_p2[] = {p2_mediana, p2_high, p2_low};

   for(int i = 0; i < 3; i++)
     {
      if(ObjectFind(0, lines[i]) < 0)
        {
         ObjectCreate(0, lines[i], OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSetInteger(0, lines[i], OBJPROP_RAY_RIGHT, true); // Proiectie in viitor
         ObjectSetInteger(0, lines[i], OBJPROP_BACK, false);
        }
      
      // Aplicam coordonatele dinamice
      ObjectSetInteger(0, lines[i], OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, lines[i], OBJPROP_PRICE, 0, prices_p1[i]);
      ObjectSetInteger(0, lines[i], OBJPROP_TIME, 1, t2);
      ObjectSetDouble(0, lines[i], OBJPROP_PRICE, 1, prices_p2[i]);

      // Sincronizam dinamic proprietatile vizuale din Inputs
      ObjectSetInteger(0, lines[i], OBJPROP_COLOR, tf_color);
      ObjectSetInteger(0, lines[i], OBJPROP_WIDTH, LineWidth);
      ObjectSetInteger(0, lines[i], OBJPROP_STYLE, LineStyle);
     }
}

//+------------------------------------------------------------------+
//| Funcție pentru ștergerea completă a tuturor liniilor            |
//+------------------------------------------------------------------+
void DeleteAllChannels()
{
   string tfs[] = {"MN1", "W1", "D1", "H4", "H1", "M30", "M15"};
   for(int i = 0; i < ArraySize(tfs); i++)
     {
      ObjectDelete(0, prefix + tfs[i] + "_Med");
      ObjectDelete(0, prefix + tfs[i] + "_High");
      ObjectDelete(0, prefix + tfs[i] + "_Low");
     }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   last_bar_time = 0;
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllChannels();
   Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total <= 0) return(0);

   // OPTIMIZARE ULTRA-EFICIENTĂ: 
   // Executam logica de calcul o singura data per lumânare pe graficul curent.
   // Previne lagul si functioneaza perfect pe 20 de grafice simultan.
   if(prev_calculated > 0 && time[rates_total - 1] == last_bar_time)
     {
      return(rates_total);
     }

   last_bar_time = time[rates_total - 1];

   // Rulam procesarea independenta pentru fiecare Timeframe configurat
   UpdateChannelForTF("MN1", PERIOD_MN1, Color_MN1, Show_MN1);
   UpdateChannelForTF("W1",  PERIOD_W1,  Color_W1,  Show_W1);
   UpdateChannelForTF("D1",  PERIOD_D1,  Color_D1,  Show_D1);
   UpdateChannelForTF("H4",  PERIOD_H4,  Color_H4,  Show_H4);
   UpdateChannelForTF("H1",  PERIOD_H1,  Color_H1,  Show_H1);
   UpdateChannelForTF("M30", PERIOD_M30, Color_M30, Show_M30);
   UpdateChannelForTF("M15", PERIOD_M15, Color_M15, Show_M15);

   // Generăm un text informativ curat în colț
   string msg = "Canale MTF Paralele Active:\n";
   if(Show_MN1 && PeriodSeconds(PERIOD_MN1) > PeriodSeconds(_Period)) msg += "- Monthly (Active)\n";
   if(Show_W1  && PeriodSeconds(PERIOD_W1)  > PeriodSeconds(_Period)) msg += "- Weekly (Active)\n";
   if(Show_D1  && PeriodSeconds(PERIOD_D1)  > PeriodSeconds(_Period)) msg += "- Daily (Active)\n";
   if(Show_H4  && PeriodSeconds(PERIOD_H4)  > PeriodSeconds(_Period)) msg += "- H4 (Active)\n";
   if(Show_H1  && PeriodSeconds(PERIOD_H1)  > PeriodSeconds(_Period)) msg += "- H1 (Active)\n";
   
   Comment(msg);

   return(rates_total);
}
//+------------------------------------------------------------------+
