//+------------------------------------------------------------------+
//|                                                GannFanModify.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, TheXpert"
#property link      "mqltech@gmail.com"

#property show_inputs

extern color DrawColor = Blue;
extern color MainColor = White;

extern int Width = 1;
extern int MainWidth = 3;

string names[] = {"T11", "T12", "T13", "T14", "T18", "T21", "T31", "T41", "T81"};
double coefs[] = {1.0, 0.5, 0.33333333333333333, 0.25, 0.125, 2, 3, 4, 8};

#define ID "GANN_FAN!"

int start()
{
   int wnd = WindowOnDropped();
   double p = WindowPriceOnDropped();
   datetime t = WindowTimeOnDropped();
   
   double w = WindowBarsPerChart()*Period()*60;
   double h = WindowPriceMax() - WindowPriceMin();

   if (wnd == 0 && p == 0 && t == 0)
   { // the script was called by doubleclick
      MessageBox("To modify the Gann Fan you wish, drop the script onto the lines starting point");
      return (0);
   }
   
   double pNearest = 2*MathAbs(WindowPriceMax());
   double tNearest = 0;
   int pIDs[];
   int tIDs[];
   
   ArrayResize(pIDs, 1); pIDs[0] = 0;
   ArrayResize(tIDs, 1); tIDs[0] = 0;
   
   int idlen = StringLen(ID);
   
   for (int i = ObjectsTotal(OBJ_TREND); i >= 0; i--)
   {
      string now = ObjectName(i);
      int pos = StringFind(now, ID);
      
      if (pos > 0)
      {
         int nowid = StrToInteger(StringSubstr(now, pos + idlen));
         
         double pNow = ObjectGet(now, OBJPROP_PRICE1);
         datetime tNow = ObjectGet(now, OBJPROP_TIME1);
         
         if (MathAbs(pNow - p) < h/6.0 && MathAbs(tNow - t) < w/6.0)
         {
            if (MathAbs(pNow - p) < MathAbs(pNearest - p))
            {
               pNearest = pNow;
               ArrayResize(pIDs, 1);
               pIDs[0] = nowid;
            }
            else if (MathAbs(pNow - p) == MathAbs(pNearest - p))
            {
               int size = ArraySize(pIDs);
               ArrayResize(pIDs, size + 1);
               pIDs[size] = nowid;
            }
         
            if (MathAbs(tNow - t) < MathAbs(tNearest - t))
            {
               tNearest = tNow;
               ArrayResize(tIDs, 1);
               tIDs[0] = nowid;
            }
            else if (MathAbs(tNow - t) == MathAbs(tNearest - t))
            {
               size = ArraySize(tIDs);
               ArrayResize(tIDs, size + 1);
               tIDs[size] = nowid;
            }
         }
      }
   }
   
   int id = 0;

   if (pIDs[0] != 0)
   {
      if (pIDs[0] == tIDs[0] || In(pIDs[0], tIDs))
      {
         id = pIDs[0];
      }
      else if (In(tIDs[0], pIDs))
      {
         id = tIDs[0];
      }
      
      if (id == 0)
      {
         MessageBox("The selection is ambiguous. Please, try to select more precisely", "Cannot modify");
         return (0);
      }
   }
   else
   {
      MessageBox("No fan was found. Missed the window?", "Cannot modify");
      return (0);
   }
   
   // id != 0
   
   string UID = ID + id;
   
   double p1, coef = 0;
   string name;
   
   for (i = 0; i < ArraySize(names); i++)
   {
      p1 = ObjectGet(names[i] + UID, OBJPROP_PRICE1);
   
      int err = GetLastError();
      if (err != 4202)
      {
         coef = coefs[i];
         name = names[i] + UID;
         break;
      }
   }
   
   if (coef == 0)
   {
      MessageBox("No fan was found.", "Cannot modify");
      return (0);
   }
   
   double p2 = ObjectGet(name, OBJPROP_PRICE2);
   p2 = p1 + (p2 - p1)/coef;
   
   double t1 = ObjectGet(name, OBJPROP_TIME1);
   double t2 = ObjectGet(name, OBJPROP_TIME2);

   SetTrend("T11" + UID, wnd, t1, p1, t2, p2, MainColor, MainWidth);
   
   // start the cycle
   
   while(!IsStopped())
   {
      // if the main line is deleted
      
      double nowp1 = ObjectGet("T11" + UID, OBJPROP_PRICE1);
      
      err = GetLastError();
      if (err == 4202)
      {
         WindowRedraw();
         break;
      }
      
      double nowp2 = ObjectGet("T11" + UID, OBJPROP_PRICE2);
      double nowt1 = ObjectGet("T11" + UID, OBJPROP_TIME1);
      double nowt2 = ObjectGet("T11" + UID, OBJPROP_TIME2);
      
      SetTrend("T12" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/2.0, DrawColor, Width);
      SetTrend("T13" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/3.0, DrawColor, Width);
      SetTrend("T14" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/4.0, DrawColor, Width);
      SetTrend("T18" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/8.0, DrawColor, Width);
      SetTrend("T21" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*2.0, DrawColor, Width);
      SetTrend("T31" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*3.0, DrawColor, Width);
      SetTrend("T41" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*4.0, DrawColor, Width);
      SetTrend("T81" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*8.0, DrawColor, Width);
      
      p1 = nowp1;
      p2 = nowp2;
      t1 = nowt1;
      t2 = nowt2;
      
      WindowRedraw();
      Sleep(50);
   }
   
   SetTrend("T11" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*1.0, DrawColor, Width);
   SetTrend("T12" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/2.0, DrawColor, Width);
   SetTrend("T13" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/3.0, DrawColor, Width);
   SetTrend("T14" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/4.0, DrawColor, Width);
   SetTrend("T18" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/8.0, DrawColor, Width);
   SetTrend("T21" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*2.0, DrawColor, Width);
   SetTrend("T31" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*3.0, DrawColor, Width);
   SetTrend("T41" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*4.0, DrawColor, Width);
   SetTrend("T81" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*8.0, DrawColor, Width);
   
   MessageBox("Gann fan was built successfully", "Done!");

   return (0);   
   
   
   return(0);
}

bool In(int value, int array[])
{
   int size = ArraySize(array);
   
   for (int i = 0; i < size; i++)
   {
      if (array[i] == value) return (true);
   }
   return (false);
}

void SetTrend(string name, int window, datetime t1, double price1, datetime t2, double price2, color clr = Gold, int width = 1)
{
   ObjectCreate(name, OBJ_TREND, window, t1, price1, t2, price2);
   
   ObjectSet(name, OBJPROP_CORNER, 0);
   ObjectSet(name, OBJPROP_RAY, 1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_TIME1, t1);
   ObjectSet(name, OBJPROP_TIME2, t2);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);
}