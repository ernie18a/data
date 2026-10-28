//+------------------------------------------------------------------+
//|                                                      drawing.mq4 |
//|                                                    Julien Loutre |
//|                                  http://www.thetradingtheory.com |
//+------------------------------------------------------------------+
#property copyright "Julien Loutre"
#property link      "http://www.thetradingtheory.com"
#property library

void draw_bar(string uid, string i, int x, double y, int x2, double y2, color c) {
   if (ObjectFind("shape_"+uid+"_rec_"+i) == -1) {
      ObjectCreate("shape_"+uid+"_rec_"+i,OBJ_RECTANGLE,0,x,y,x2,y2);
   } else {
      ObjectSet("shape_"+uid+"_rec_"+i, OBJPROP_TIME1, x);
      ObjectSet("shape_"+uid+"_rec_"+i, OBJPROP_PRICE1, y);
      ObjectSet("shape_"+uid+"_rec_"+i, OBJPROP_TIME2, x2);
      ObjectSet("shape_"+uid+"_rec_"+i, OBJPROP_PRICE2, y2);
   }
   ObjectSet("shape_"+uid+"_rec_"+i, OBJPROP_COLOR, c);
}

void draw_vline(string uid, string i, int x, double y, color c) {
   if (ObjectFind("shape_"+uid+"_vline_"+i) == -1) {
      ObjectCreate("shape_"+uid+"_vline_"+i,OBJ_VLINE,0,x,y);
   } else {
      ObjectSet("shape_"+uid+"_vline_"+i, OBJPROP_TIME1, x);
      ObjectSet("shape_"+uid+"_vline_"+i, OBJPROP_PRICE1, y);
   }
   ObjectSet("shape_"+uid+"_vline_"+i, OBJPROP_COLOR, c);
}

void draw_line(string uid, string i, int x, double y, int x2, double y2, color c) {
   if (ObjectFind("shape_"+uid+"_line_"+i) == -1) {
      ObjectCreate("shape_"+uid+"_line_"+i,OBJ_TREND,0,x,y,x2,y2);
   } else {
      ObjectSet("shape_"+uid+"_line_"+i, OBJPROP_TIME1, x);
      ObjectSet("shape_"+uid+"_line_"+i, OBJPROP_PRICE1, y);
      ObjectSet("shape_"+uid+"_line_"+i, OBJPROP_TIME2, x2);
      ObjectSet("shape_"+uid+"_line_"+i, OBJPROP_PRICE2, y2);
   }
   ObjectSet("shape_"+uid+"_line_"+i, OBJPROP_RAY, false);
   ObjectSet("shape_"+uid+"_line_"+i, OBJPROP_COLOR, c);
}

void draw_array_as_line(string uid, double& a[], color c) {
   for (int i=0;i<ArraySize(a);i++) {
      draw_line(uid, "arrayline"+i, Time[i],a[i],Time[i+1],a[i+1], c);
   }
}

void draw_erase(string uid) {
   string name;
   int i;
   int t = ObjectsTotal();
   for (i=0;i<t;i++) {
      name = ObjectName(i);
      if (StringFind(name,"shape_"+uid) != -1) {
         ObjectDelete(name);
      }
   }
}
void draw_erase_all() {
   ObjectsDeleteAll();
}

int rgb2int(int r, int g, int b) {
   return (b*65536+g*256+r);
}

int colorGradient(int r, int g, int b, int r2, int g2, int b2, double min, double max, double pos) {
   double steps = (max-min);
   pos = max-pos;
   double stepR = (r-r2)/(steps-1);
   double stepG = (g-g2)/(steps-1);
   double stepB = (b-b2)/(steps-1);
   return (rgb2int((r-(stepR*pos)),(g-(stepG*pos)),(b-(stepB*pos))));
}

double map(double x, double in_min, double in_max, double out_min, double out_max) {
  return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
}