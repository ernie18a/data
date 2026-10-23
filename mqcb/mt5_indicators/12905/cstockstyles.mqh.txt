//+------------------------------------------------------------------+
//|                                                 CStockStyles.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#include "StockStruct.mqh"
#define COLOR_SCHEMES 2                      // color schemes
//+------------------------------------------------------------------+
//| CStockStyles: managering common structures                       |
//+------------------------------------------------------------------+
class CStockStyles
  {
protected:
   SBackground    m_style[COLOR_SCHEMES];                                  // structure for background
   int            m_scheme;                                                // current color scheme
   bool           m_created;                                               // created
public:
   CStockStyles(int scheme=0);
   ~CStockStyles();
   void Deinit(void) {}
   //--- Setting default values
   void           InitDefaults(void);
   //--- fonts
   int            FontSizeV(void)              {return(m_style[m_scheme].FontSizeV);}             
   int            FontSizeH(void)              {return(m_style[m_scheme].FontSizeH);}             
   string         FontNameV(void)              {return(m_style[m_scheme].FontNameV);}             
   string         FontNameH(void)              {return(m_style[m_scheme].FontNameH);}  
   //--- geometry
   int            StockCanvasH(void)            {return(m_style[m_scheme].iStockCanvasH);}
   int            StockLabelIndH(void)          {return(m_style[m_scheme].iStockLabelIndH);}
   int            StockLabelIndL(void)          {return(m_style[m_scheme].iStockLabelIndL);}
   int            StockLabelIndW(void)          {return(m_style[m_scheme].iStockLabelIndW);}
   //--- object colors
   color          BgRectActive(void)           {return(m_style[m_scheme].cBgRectActive);}
   color          BgRectSleep(void)            {return(m_style[m_scheme].cBgRectSleep);}
   color          FgTextActive(void)           {return(m_style[m_scheme].cFgTextActive);}
   color          FgTextSleep(void)            {return(m_style[m_scheme].cFgTextSleep);}
   bool           Created(void)        {return(m_created);}                // checking creating of the object
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStockStyles::CStockStyles(int scheme=0)
  {
   m_scheme=scheme;
   m_created=true;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStockStyles::~CStockStyles()
  {
   Deinit();
  }
//+------------------------------------------------------------------+
//| Setting default graph background value                           |
//+------------------------------------------------------------------+
void CStockStyles::InitDefaults(void)
  {
   switch(m_scheme)
     {
      case 0:
         //---fonts
         m_style[m_scheme].FontNameV="Times New Roman";
         m_style[m_scheme].FontSizeV=12;
         m_style[m_scheme].FontNameH="Arial";
         m_style[m_scheme].FontSizeH=10;
         //--- colors
         m_style[m_scheme].cFgTextActive=C'100,100,100';                         // FG active color
         m_style[m_scheme].cFgTextSleep=C'50,50,50';                             // FG sleeping color
         m_style[m_scheme].cBgRectActive=C'30,30,30';                            // BG active color
         m_style[m_scheme].cBgRectSleep=C'15,15,15';                             // BG sleeping color
         //--- geometry
         m_style[m_scheme].iStockCanvasH=20;                                     // canvas height
         m_style[m_scheme].iStockLabelIndH=1;                                    // label height indent 
         m_style[m_scheme].iStockLabelIndL=5;                                    // label left indent
         m_style[m_scheme].iStockLabelIndW=10;                                   // label width indent
         break;
      case 1:
         //---fonts
         m_style[m_scheme].FontNameV="Times New Roman";
         m_style[m_scheme].FontSizeV=12;
         m_style[m_scheme].FontNameH="Arial";
         m_style[m_scheme].FontSizeH=10;
         //--- colors
         m_style[m_scheme].cFgTextActive=C'155,155,155';                         // FG active color
         m_style[m_scheme].cFgTextSleep=C'205,205,205';                             // FG sleeping color
         m_style[m_scheme].cBgRectActive=C'225,225,225';                            // BG active color
         m_style[m_scheme].cBgRectSleep=C'240,240,240';                             // BG sleeping color
         //--- geometry
         m_style[m_scheme].iStockCanvasH=20;                                     // canvas height
         m_style[m_scheme].iStockLabelIndH=1;                                    // label height indent 
         m_style[m_scheme].iStockLabelIndL=5;                                    // label left indent
         m_style[m_scheme].iStockLabelIndW=10;                                   // label width indent
         break;
     };
  }

//+------------------------------------------------------------------+


