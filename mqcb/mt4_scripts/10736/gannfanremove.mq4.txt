//+------------------------------------------------------------------+
//|                                                GannFanRemove.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, TheXpert"
#property link      "mqltech@gmail.com"

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
      MessageBox("To remove the Gann Fan you wish from the chart, drop the script onto the lines starting point");
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
   
   if (pIDs[0] != 0)
   {
      int id = 0;
      if (pIDs[0] == tIDs[0] || In(pIDs[0], tIDs))
      {
         id = pIDs[0];
      }
      else if (In(tIDs[0], pIDs))
      {
         id = tIDs[0];
      }
      
      if (id != 0)
      {
         ObjectDelete("T11" + ID + id);
         ObjectDelete("T12" + ID + id);
         ObjectDelete("T13" + ID + id);
         ObjectDelete("T14" + ID + id);
         ObjectDelete("T18" + ID + id);
         ObjectDelete("T21" + ID + id);
         ObjectDelete("T31" + ID + id);
         ObjectDelete("T41" + ID + id);
         ObjectDelete("T81" + ID + id);
         
         WindowRedraw();

         MessageBox("Gann fan with ID #" + id + " deleted successfully", "Success");
      }
      else
      {
         MessageBox("The selection is ambiguous. Please, try to select more precisely", "Cannot delete");
         return (0);
      }
   }
   else
   {
      MessageBox("No fan was found. Missed the window?", "Cannot delete");
      return (0);
   }
   
   
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