//+------------------------------------------------------------------+
//| ZigZag_HHHL_LHLL.mq4                                             |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property strict

input int ExtDepth     = 12;
input int ExtDeviation = 5;
input int ExtBackstep  = 3;
input color LineColor  = clrDodgerBlue;
input color TextColor  = clrYellow;

double zzBuffer[];
string tfTag;

//+------------------------------------------------------------------+
int OnInit()
  {
   tfTag = "TF" + IntegerToString(Period()) + "_";
   IndicatorShortName("ZigZag HH HL LH LL (" + tfTag + ")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
int start()
  {
   DeleteAllOtherTFObjects(tfTag);

   int bars = Bars - ExtBackstep - 1;
   if(bars < 10) return(0);

   ArrayResize(zzBuffer, bars);

   // Baca ZigZag ke dalam buffer
   for(int i = 0; i < bars; i++)
      zzBuffer[i] = iCustom(NULL, 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);

   int lastHighIndex = -1;
   int lastLowIndex = -1;

   for(int i = bars - 1; i >= 0; i--)
     {
      if(zzBuffer[i] != 0.0)
        {
         double currPrice = zzBuffer[i];
         string label = "";

         // Swing HIGH atau LOW
         bool isHigh = (High[i] == currPrice);
         bool isLow  = (Low[i]  == currPrice);

         //------- HIGH -------
         if(isHigh)
           {
            if(lastHighIndex != -1)
              {
               double lastHigh = zzBuffer[lastHighIndex];
               label = (currPrice > lastHigh) ? "HH" : "LH";
              }
            lastHighIndex = i;
           }

         //------- LOW -------
         else if(isLow)
           {
            if(lastLowIndex != -1)
              {
               double lastLow = zzBuffer[lastLowIndex];
               label = (currPrice < lastLow) ? "LL" : "HL";
              }
            lastLowIndex = i;
           }

         // Sambung garis dengan zigzag sebelumnya
         int prevIdx = FindPreviousZigZag(i);
         if(prevIdx != -1)
           {
            string lineName = tfTag + "Line_" + IntegerToString(i);

            ObjectCreate(lineName, OBJ_TREND, 0,
                         Time[prevIdx], zzBuffer[prevIdx],
                         Time[i], currPrice);

            ObjectSet(lineName, OBJPROP_COLOR, LineColor);
            ObjectSet(lineName, OBJPROP_WIDTH, 1);
            ObjectSet(lineName, OBJPROP_RAY_RIGHT, false);
            ObjectSet(lineName, OBJPROP_RAY_LEFT, false);
           }

         // Label HH HL LH LL
         if(label != "")
           {
            string labelName = tfTag + "Label_" + IntegerToString(i);

            ObjectCreate(labelName, OBJ_TEXT, 0, Time[i], currPrice);
            ObjectSetText(labelName, label, 10, "Arial", TextColor);
           }
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Cari zigzag sebelumnya                                          |
//+------------------------------------------------------------------+
int FindPreviousZigZag(int current)
  {
   for(int i = current + 1; i < ArraySize(zzBuffer); i++)
     {
      if(zzBuffer[i] != 0.0) return(i);
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//| Buang objek timeframe lain                                      |
//+------------------------------------------------------------------+
void DeleteAllOtherTFObjects(string currentTFTag)
  {
   int total = ObjectsTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(i);

      // Nama objek mesti bermula dengan "TF"
      if(StringFind(name, "TF") == 0)
        {
         // Jika bukan tag TF semasa → padam
         if(StringFind(name, currentTFTag) != 0)
            ObjectDelete(name);
        }
     }
  }
//+------------------------------------------------------------------+
