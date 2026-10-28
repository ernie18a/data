#property strict
#property indicator_chart_window
#property indicator_buffers 1
#include <Movement\Chanse.mqh>
#include <Movement\Status.mqh>

#define PREFIX "TRP_"
#define TEXT_COLOR C'80,80,80'

input int               inp_movement_base       = 250;            // base price movement
input double            inp_percent_shift       = 5;              // levels %
input int               inp_percent_size        = 12;             // Font
input color             inp_percent_color       = clrTomato;      // Color
input int               inp_percent_line_left   = 1;              // line width in bars (left part)
input int               inp_percent_line_right  = 5;              // line width in bars (right part)

double ext_buf[];

CMovement *c_mov;

//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0,ext_buf);
   // инициализация класса
   c_mov = new CMovement(inp_movement_base);
   // размещение кнопок
   CreateEdit(PREFIX+"edit_movement_size",10,15,100,20,13,(string)inp_movement_base,TEXT_COLOR,clrWhite,TEXT_COLOR);
   CreateButton(PREFIX+"button_movement_recal", 113, 15, 70, 20, "recalc", TEXT_COLOR, clrWhite);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   // изменили размер базы - пересчитаем
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam == PREFIX+"edit_movement_size") {
      int new_size = (int)ObjectGetString(0,sparam,OBJPROP_TEXT);
      if(new_size<0 || new_size>2000) {
         ObjectSetString(0,sparam,OBJPROP_TEXT, (string)c_mov.movement_size);
         return;
      }
      c_mov.SetMovementSize(new_size);
      SMovement current_movement;
      GetLastMovement(current_movement, new_size);
      PutFlipLevels(current_movement);
   }
   
   // нажали кнопку reset - пересчитаем   
   if(id==CHARTEVENT_OBJECT_CLICK && sparam == PREFIX+"button_movement_recal") {
      c_mov.CalcMovements();
      SMovement current_movement;
      GetLastMovement(current_movement, c_mov.movement_size);
      PutFlipLevels(current_movement);
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
   }
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // удаление объектов
   ObjectsDeleteAll(0,PREFIX);
   // деинициализация класса
   delete c_mov;
}
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
                
   if(rates_total<=0) return(rates_total);

   bool reset_lines = false;
   
   // получим данные по последнему движения
   SMovement current_movement;
   GetLastMovement(current_movement, c_mov.movement_size);
   
   // отследим последнее направление
   static int s_direction = -1;
   if(current_movement.direction != s_direction) {
      s_direction = current_movement.direction;
      c_mov.CalcMovements();
      reset_lines = true;
   }   
      
   // отследим последний размер движения
   static int s_move_size = 0;
   if(current_movement.size != s_move_size) {
      s_move_size = current_movement.size;
      reset_lines = true;
   }

   // переставим процентные уровни если нужно
   if(reset_lines)
      PutFlipLevels( current_movement );
                
   return(rates_total);
}
//+------------------------------------------------------------------+
void PutFlipLevels(SMovement& movement) {
   // get current percent
   double current_percent = c_mov.GetPercentBySize(movement.size);
   // create next levels
   int      levels_count = int( MathFloor((100 - current_percent) / inp_percent_shift + 1) );
   double   level_percent[];
   int      level_shift[];
   ArrayResize(level_percent, levels_count);
   ArrayResize(level_shift, levels_count);
   for(int l=0;l<levels_count;l++) {
      level_percent[l]  = 100-inp_percent_shift*l;
      level_shift[l]    = c_mov.GetSizeByPercent( level_percent[l] );
   }
   // draw next levels
   ObjectsDeleteAll(0,PREFIX+"level_");
   for(int l=0; l<levels_count; l++) {
      double   level_price    = movement.price_base + (movement.direction==0?1:-1)*level_shift[l]*_Point;
      int      standart_shift = (int)ChartGetInteger(0,CHART_WIDTH_IN_BARS) / 10;
      CreateTrend(PREFIX+"level_left"+(string)l, level_price, Time[0], level_price, Time[0]-PeriodSeconds()*(standart_shift*inp_percent_line_left),STYLE_SOLID,2,inp_percent_color);
      CreateTrend(PREFIX+"level_right"+(string)l, level_price, Time[0], level_price,Time[0]+PeriodSeconds()*(standart_shift*inp_percent_line_right),STYLE_DOT,1,inp_percent_color);
      CreateText(PREFIX+"level_text"+(string)l, level_price,Time[0]-PeriodSeconds()*(standart_shift*inp_percent_line_left),DoubleToString(level_percent[l],0)+"%","Verdana",inp_percent_size,movement.direction==0 ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER, inp_percent_color);
   }
}
//+------------------------------------------------------------------+
void CreateButton(string name, int x, int y, int xsize, int ysize, string text, color _color,color _colorbg) {
   if(ObjectFind(0,name)<0) {
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,12);
      ObjectSetString(0,name,OBJPROP_FONT,"Verdana");
   }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,_colorbg);
}
//+------------------------------------------------------------------+
void CreateEdit(string name, int x, int y, int x_size, int y_size, int fontsize, string text, color _color, color _colorbg, color _colorbd) {
   if(ObjectFind(0,name)<0) {
      ObjectCreate(0,name,OBJ_EDIT,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,x_size);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,y_size);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetString(0,name,OBJPROP_FONT,"Calibri");
   }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,_colorbg);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,_colorbd);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
}
//+------------------------------------------------------------------+
void CreateText(string name, double price, datetime time, string text, string font, int font_size,ENUM_ANCHOR_POINT _anchor, color _color) {
   if(ObjectFind(0,name)<0) 
      ObjectCreate(0,name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,_anchor);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
}
//+------------------------------------------------------------------+
void CreateTrend(string name, double price0, datetime time0, double price1, datetime time1, ENUM_LINE_STYLE style, int width, color _color) {
   if(ObjectFind(0,name)<0) 
      ObjectCreate(0,name,OBJ_TREND,0,0,0);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price0);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time0);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,price1);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,time1);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
}
//+------------------------------------------------------------------+
