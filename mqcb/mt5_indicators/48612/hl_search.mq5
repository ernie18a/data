//+------------------------------------------------------------------+
//|                                                    HL_Search.mq5 |
//|                                Copyright 2024, Rajesh Kumar Nait |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

int ind_h=0,ind_l=0,ind_db=0,ind_dt=0,lvb,_fvb,_clb,fvb=-1,clb=-1,ind_l_cl=0,ind_l_op=0,l_lb=0,ind_h_cl=0,ind_h_op=0,h_ub=0;
string prefix ="d_";


input color TextColor = clrSnow;
input string TextFont = "Arial";
input int TextSize = 10;
input int Text_Adjustment = 2; // Adjust High Low Text in points

bool showh2l=false,showl2h=false;


enum Mode {
   Wick_HL,
   Body_HL

};

input Mode SelectMode = Body_HL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   showl2h=false;
   showh2l=false;
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
   ObjectsDeleteAll(0,prefix);
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
                const int &spread[]) {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//---
   if(id==CHARTEVENT_CHART_CHANGE) {

      FindChartBars();
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindChartBars() {

   _fvb=(int)ChartGetInteger(ChartID(),CHART_FIRST_VISIBLE_BAR,0);
   _clb=(int)ChartGetInteger(ChartID(),CHART_WIDTH_IN_BARS,0);
   if (_fvb>0 &&(_fvb!=fvb||_clb!=clb)) {

      lvb=_fvb-(_clb-1);
      if (lvb<0) {
         lvb=0;
      }
      ind_h= iHighest(_Symbol,_Period,MODE_HIGH,(_fvb-lvb),lvb);
      ind_l= iLowest(_Symbol,_Period,MODE_LOW,(_fvb-lvb),lvb);



      //Highest Body
      ind_h_cl= iHighest(_Symbol,_Period,MODE_CLOSE,(_fvb-lvb),lvb);
      ind_h_op= iHighest(_Symbol,_Period,MODE_OPEN,(_fvb-lvb),lvb);

      if(upperBody(ind_h_cl)>upperBody(ind_h_op))
         h_ub = ind_h_cl;
      else
         h_ub = ind_h_op;

      if(upperBody(ind_h_cl)==upperBody(ind_h_op)) {
         if(ind_h_cl>ind_h_op)
            h_ub=ind_h_op;
         else
            h_ub= ind_h_cl;
      }

      if(upperBody(h_ub)==upperBody(h_ub-1))
         h_ub = h_ub-1;

      //Lowest Body
      ind_l_cl= iLowest(_Symbol,_Period,MODE_CLOSE,(_fvb-lvb),lvb);
      ind_l_op= iLowest(_Symbol,_Period,MODE_OPEN,(_fvb-lvb),lvb);

      if(lowerBody(ind_l_cl)>lowerBody(ind_l_op))
         l_lb = ind_l_op;
      else
         l_lb = ind_l_cl;

      if(lowerBody(ind_l_cl)==lowerBody(ind_l_op)) {
         if(ind_l_cl>ind_l_op)
            l_lb=ind_l_op;
         else
            l_lb= ind_l_cl;
      }


      if(lowerBody(l_lb)==lowerBody(l_lb-1))
         l_lb = l_lb-1;

      if(SelectMode==Wick_HL) {
         TextCreate(0,prefix+"High",0,time(ind_h),high(ind_h)+Text_Adjustment*Point(),DoubleToString(high(ind_h),_Digits),TextFont,TextSize,TextColor,0,ANCHOR_CENTER,true,false,true,0);
         TextCreate(0,prefix+"Low",0,time(ind_l),low(ind_l)-Text_Adjustment*Point(),DoubleToString(low(ind_l),_Digits),TextFont,TextSize,TextColor,0,ANCHOR_CENTER,true,false,true,0);

      }

      if(SelectMode==Body_HL) {
         TextCreate(0,prefix+"High_UB",0,time(h_ub),high(h_ub)+Text_Adjustment*Point(),""+DoubleToString(high(h_ub),_Digits),TextFont,TextSize,TextColor,0,ANCHOR_CENTER,true,false,true,0);
         TextCreate(0,prefix+"Low_LB",0,time(l_lb),low(l_lb)-Text_Adjustment*Point(),""+DoubleToString(low(l_lb),_Digits),TextFont,TextSize,TextColor,0,ANCHOR_CENTER,true,false,true,0);
      }

      ChartRedraw();
      fvb=_fvb;
      clb=_clb;
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime time(int index) {
   return iTime(NULL,0,index);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double high(int index) {
   return iHigh(NULL,0,index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double low(int index) {
   return iLow(NULL,0,index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double open(int index) {
   return iOpen(NULL,0,index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double close(int index) {
   return iClose(NULL,0,index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double upperBody(int index) {
   return MathMax(open(index), close(index));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lowerBody(int index) {
   return MathMin(open(index), close(index));
}


//+------------------------------------------------------------------+
//| TEXT
//+------------------------------------------------------------------+
void TextCreate(const long              chart_ID,               // ID del gráfico
                const string            name,              // nombre del objeto
                const int               sub_window,             // número de subventana
                datetime                time,                   // hora del punto de anclaje
                double                  price,                  // precio del punto de anclaje
                const string            text,              // el texto
                const string            font,             // fuente
                const int               font_size_,             // tamaño de la fuente
                const color             clr,               // color
                const double            angle,                // inclinación del texto
                const ENUM_ANCHOR_POINT anchor,              // modo de anclaje
                const bool              back,               // al fondo
                const bool              selection,          // seleccionar para mover
                const bool              hidden,              // ocultar en la lista de objetos
                const long              z_order) {              // prioridad para el clic del ratón
   ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size_);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
}

//+------------------------------------------------------------------+
