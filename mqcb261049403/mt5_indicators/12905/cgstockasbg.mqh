//+------------------------------------------------------------------+
//|                                                  CGStockAsBG.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#include "CStock.mqh"
#include "CStockStyles.mqh"
#include "CGCanvas.mqh"
#include "CGLabel.mqh"
//+------------------------------------------------------------------+
//| Class creates background and label with the name of the stock    |
//+------------------------------------------------------------------+
class CGStockAsBG
  {
protected:
   long           m_id;                                                    // graph ID
   int            m_subwin;                                                // subwindow index
   int            m_scheme;                                                // current scheme
   bool           m_created;                                               // true if all objects cteated
   STOCK_NAME     m_stock;                                                 // enum stock name
   datetime       m_dt_start;                                              // checking datetime
   string         m_name_label;                                            // Label object name
   string         m_name_canvas;                                           // Canvas(edit)object name
   string         m_text_label;                                            // text property for label
   string         m_prefix;                                                // common prefix
   string         m_suffix;                                                // additional suffix
   int            m_xdist;                                                 // x-distance from the corner
   int            m_ydist;                                                 // y-distance from the corner
   int            m_xsize;                                                 // group width
   int            m_ysize;                                                 // group hight
   int            m_xshift;                                                // x-shift label position from canvas position
   int            m_yshift;                                                // y-shift lable position from canvas position
   datetime       m_time_pos;                                              // time position related with x-distance
   bool           m_caps;                                                  // caps on/off
   color          m_color_bg_sleep;                                        // bg color when stock is non active
   color          m_color_bg_active;                                       // bg_color when stock is active
   color          m_color_fg_active;                                       // fg color when stock is non active
   color          m_color_fg_sleep;                                        // fg color when stock is active
   int            m_font_size;                                             // font size
   string         m_font_name;                                             // font name
   datetime       m_dt_open;                                               // open datetime
   datetime       m_dt_close;                                              // close datetime

   // pointers to the used classes
   CStock         *m_ptr_stock;                                            // pointer to CStock
   CStockStyles   *m_ptr_style;                                            // pointer to CStockStyle
   CGCanvas       *m_ptr_canvas;                                           // pointer to CGCanvas
   CGLabel        *m_ptr_label;                                            // ponter to CGLabel
   CGStockAsBG    *m_stock_bg;                                             // pointer to the class
public:
   CGStockAsBG(STOCK_NAME aStock=Tokio,
               datetime aTStart=0,                                         // TimeTradeServer or TimeSeria
               int aTop=0,                                                 // y top position
               string aPrefix="",                                          // prefix
               string aSuffix="",                                          // suffix
               int aScheme=0,                                              // color scheme
               bool aCapsOn=false,                                         // text in caps on/off 
               long aID=0,                                                 // graph ID
               int  aSubwin=0);                                            // subwindow index               
   void           SetPositionProps(datetime aTime,int aTop=0);             // setting all object position and dimention properties 
   void           SetPositionPropsXY(int aLeft=0,int aTop=0,int aWidth=100); // setting all object position and dimention properties by default
   void           SetNonPositionProps(void);                               // setting all object properties except position
   void           SetActiveColors(void);                                   // setting colors when stock is active
   void           SetSleepColors(void);                                    // setting colors when stock is non active 
   void           ProcessingColor(datetime aTime,bool aTimeCurrent=true);  // processing stock color and position
   void           ReDraw(void)   {ChartRedraw(m_id);}                      // chart redrawing 
   bool           CheckActive(datetime aTime,bool aTimeCurrent=true);      // check when stock is active (TimeCurrent==true - only TimeCurrent()
   bool           Created(void) {return(m_created);}                       // true if objects created
   ~CGStockAsBG();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGStockAsBG::CGStockAsBG(STOCK_NAME aStock=Tokio,
                         datetime aTStart=0,
                         int aTop=0,
                         string aPrefix="",
                         string aSuffix="",
                         int aScheme=0,
                         bool aCapsOn=false,
                         long aID=0,
                         int aSubwin=0)
  {
   bool stock_created=false;
   bool canvas_created=false;
   bool label_created=false;
   bool styles_created=false;
   m_created=false;
   m_scheme=aScheme;
   m_id=aID;
   m_subwin=aSubwin;
   m_stock=aStock;
   m_dt_start=aTStart;
   m_ydist=aTop;
   m_caps=aCapsOn;
   m_prefix=aPrefix;
   m_ptr_stock=new CStock(m_stock,m_caps);
   if(m_ptr_stock.Created())
     {
      stock_created=true;    
      m_name_canvas=aPrefix+m_ptr_stock.StockName("Cvs_")+aSuffix;
      m_name_label=aPrefix+m_ptr_stock.StockName("Lbl_")+aSuffix;
     } else
     {
      ResetLastError();
      Print(__FUNCTION__,". Error while CStock created. Code: ",GetLastError()); 
     }    
   m_ptr_canvas=new CGCanvas(m_name_canvas,m_id,m_subwin);
   if(m_ptr_canvas.Created())
      canvas_created=true;
   else
     {
      ResetLastError();
      Print(__FUNCTION__,". Error while CGCanvas created. Code: ",GetLastError());     
     }
   m_ptr_label=new CGLabel(m_name_label,m_id,m_subwin);
   if(m_ptr_label.Created())
      label_created=true;     
   else
     {   
      ResetLastError();
      Print(__FUNCTION__,". Error while CGLabel created. Code: ",GetLastError());     
     }
   m_ptr_style=new CStockStyles(m_scheme);
   if(m_ptr_style.Created())
      styles_created=true;  
   else  
     {
      ResetLastError();
      Print(__FUNCTION__,". Error while CStockStyles created. Code: ",GetLastError());
     }  
   if(stock_created&&canvas_created&&label_created&&styles_created)
     {
      ResetLastError();
      m_ydist=10;
      ChartTimePriceToXY(m_id,m_subwin,m_dt_start,SYMBOL_ASK,m_xdist,m_ydist);
      m_ydist=aTop;
      m_created=true;   
     }
   m_ptr_style.InitDefaults();                                             // setting default style
   m_color_bg_active=m_ptr_style.BgRectActive();                           // setting active bg color
   m_color_bg_sleep=m_ptr_style.BgRectSleep();                             // setting non-active bg color
   m_color_fg_active=m_ptr_style.FgTextActive();                           // setting active fg color
   m_color_fg_sleep=m_ptr_style.FgTextSleep();                             // setting non-active fg color
   m_font_name=m_ptr_style.FontNameH();                                    // setting font name
   m_font_size=m_ptr_style.FontSizeH();                                    // setting font size;
   SetNonPositionProps();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGStockAsBG::~CGStockAsBG()
  {
   delete m_ptr_stock;
   delete m_ptr_canvas;
   delete m_ptr_label;
   delete m_ptr_style;
  }
//+------------------------------------------------------------------+
//| SetPositionProp                                                  |
//+------------------------------------------------------------------+
void CGStockAsBG::SetPositionPropsXY(int aLeft=0,int aTop=0,int aWidth=100)
  {
   //int a_temp;
   int canvas_left=aLeft;
   int canvas_top=aTop;
   int canvas_width=aWidth;
   int canvas_height=m_ptr_style.StockCanvasH();
   int label_left,label_top,label_width,label_height;
   m_ptr_canvas.SetXDist(canvas_left);
   m_ptr_canvas.SetYDist(canvas_top);
   m_ptr_canvas.SetXSize(canvas_width);
   m_ptr_canvas.SetYSize(canvas_height);
   label_left=canvas_left+m_ptr_style.StockLabelIndL();//+5
   label_top=canvas_top+m_ptr_style.StockLabelIndH();//+1;
   label_width=canvas_width-m_ptr_style.StockLabelIndW();//-10;
   label_height=canvas_height-m_ptr_style.StockLabelIndH()*2;//-2;
   m_ptr_label.SetXDist(label_left);
   m_ptr_label.SetYDist(label_top);
   m_ptr_label.SetXSize(label_width);
   m_ptr_label.SetYSize(label_top);
   m_ptr_label.SetText(m_ptr_stock.StockText(m_caps));
  }
//+------------------------------------------------------------------+
//| SetPositionProps                                                 |
//+------------------------------------------------------------------+
void CGStockAsBG::SetPositionProps(datetime aTime,int aTop=0)
  {
   int a_temp;
   int canvas_left,canvas_right,canvas_top,canvas_width,canvas_height;
   int label_left,label_top,label_width,label_height;
   string label_text;
   m_dt_start=aTime;
   m_ptr_stock.StockShedule(m_dt_start,m_dt_open,m_dt_close);
   ChartTimePriceToXY(m_id,m_subwin,m_dt_open,SYMBOL_ASK,canvas_left,a_temp);
   canvas_top=aTop;
   canvas_height=m_ptr_style.StockCanvasH();
   ChartTimePriceToXY(m_id,m_subwin,m_dt_close,SYMBOL_ASK,canvas_right,a_temp);
   canvas_width=MathAbs(canvas_right-canvas_left);
   m_ptr_canvas.SetXDist(canvas_left);
   m_ptr_canvas.SetYDist(canvas_top);
   m_ptr_canvas.SetXSize(canvas_width);
   m_ptr_canvas.SetYSize(canvas_height);
   label_left=canvas_left+m_ptr_style.StockLabelIndL();//+5
   label_top=canvas_top+m_ptr_style.StockLabelIndH();//+1;
   label_width=canvas_width-m_ptr_style.StockLabelIndW();//-10;
   label_height=canvas_height-m_ptr_style.StockLabelIndH()*2;//-2;
   label_text=m_ptr_stock.StockText(m_caps);
   m_ptr_label.SetXDist(label_left);
   m_ptr_label.SetYDist(label_top);
   m_ptr_label.SetXSize(label_width);
   m_ptr_label.SetYSize(label_top);
   m_ptr_label.SetText(label_text);
  }
//+------------------------------------------------------------------+
//| Setting all object properties except                             |
//+------------------------------------------------------------------+
void CGStockAsBG::SetNonPositionProps(void)
  {
   // CGCanvas
   m_ptr_canvas.SetColorBG(m_color_bg_sleep);
   m_ptr_canvas.SetColorBorder(m_color_bg_sleep);
   m_ptr_canvas.SetCorner();
   m_ptr_canvas.SetFontName(m_font_name);
   m_ptr_canvas.SetFontSize(m_font_size);
   m_ptr_canvas.SetSelected();
   m_ptr_canvas.SetSelectable();
   m_ptr_canvas.SetReadOnly();
   m_ptr_canvas.SetBack(true);
   m_ptr_canvas.SetZOrder();
   m_ptr_canvas.SetHidden();
   // CGLabel
   m_ptr_label.SetColorText(m_color_fg_sleep);
   m_ptr_label.SetCorner();
   m_ptr_label.SetAnchor();
   m_ptr_label.SetAngle();
   m_ptr_label.SetFontName(m_font_name);
   m_ptr_label.SetFontSize(m_font_size);
   m_ptr_label.SetSelected();
   m_ptr_label.SetSelectable();
   m_ptr_label.SetBack(true);
   m_ptr_label.SetZOrder();
   m_ptr_label.SetHidden();
  }
//+------------------------------------------------------------------+
//| Setting colors when stock is active                              |
//+------------------------------------------------------------------+
void CGStockAsBG::SetActiveColors(void)
  {
   m_ptr_canvas.SetColorBG(m_color_bg_active);
   m_ptr_canvas.SetColorBorder(m_color_bg_active);
   m_ptr_label.SetColorText(m_color_fg_active);
  }
//+------------------------------------------------------------------+
//| Setting colors when stock is non active                          |
//+------------------------------------------------------------------+
void CGStockAsBG::SetSleepColors(void)
  {
   m_ptr_canvas.SetColorBG(m_color_bg_sleep);
   m_ptr_canvas.SetColorBorder(m_color_bg_sleep);
   m_ptr_label.SetColorText(m_color_fg_sleep);
  }
//+------------------------------------------------------------------+
//| Checking when stock is non active                                |
//| aTimeCurrent==true: check by TimeCurrent()                       |
//| aTimeCurrent==false: check by aTime                              |
//+------------------------------------------------------------------+
bool CGStockAsBG::CheckActive(datetime aTime,bool aTimeCurrent=true)
  {
   if(aTimeCurrent)
     {
      if(TimeCurrent()>=m_dt_open&&TimeCurrent()<=m_dt_close)
       return(true);
      else
       return(false);
     } else
     {
      if(aTime>=m_dt_open&&aTime<=m_dt_close)
       return(true);
      else
       return(false);
     }
  }
//+------------------------------------------------------------------+
//| Processing Stock colors and position                             |
//+------------------------------------------------------------------+
void CGStockAsBG::ProcessingColor(datetime aTime,bool aTimeCurrent=true)
  {
   //SetPositionProps(aTime);
   if(CheckActive(aTime,aTimeCurrent))
     SetActiveColors();
   else
     SetSleepColors();
  }
//+------------------------------------------------------------------+
