// Candle (define g_rates as: MqlRates g_rates[];)
#define CANDLELOW(i)    g_rates[i].low
#define CANDLEHIGH(i)   g_rates[i].high
#define CANDLEOPEN(i)   g_rates[i].open
#define CANDLECLOSE(i)  g_rates[i].close
#define CANDLETIME(i)   g_rates[i].time

// Prices (define g_tick as: MqlTick g_tick;))
#define ASK             g_tick.ask
#define BID             g_tick.bid

// define these arrays as: double g_MA20_arr[];
// Moving averages and ATR
#define MOVAVG20(i)     g_MA20_arr[i]
#define MOVAVG40(i)     g_MA40_arr[i]
#define MOVAVG50(i)     g_MA50_arr[i]
#define MOVAVG200(i)    g_MA200_arr[i]
#define ATR(i)          g_atr_arr[i]

// candle features
#define CANDLEBODYTOP(i)      fmax(CANDLEOPEN(i),CANDLECLOSE(i))
#define CANDLEBODYBOT(i)      fmin(CANDLEOPEN(i),CANDLECLOSE(i))
#define CANDLEMEDIAN(i)       (0.5*(CANDLEHIGH(i)+CANDLELOW(i)))
#define CANDLEWEIGHTED(i)     (0.25*(CANDLEHIGH(i)+CANDLELOW(i)+2*CANDLECLOSE(i)))
#define CANDLETYPICAL(i)      (1./3.*(CANDLEHIGH(i)+CANDLELOW(i)+CANDLECLOSE(i)))
#define CANDLEBODYMIDDLE(i)   (0.5*(CANDLEBODYTOP(i)+CANDLEBODYBOT(i)))
#define CANDLESIZE(i)         (CANDLEHIGH(i)-CANDLELOW(i))
#define CANDLEBODYSIZE(i)     fabs(CANDLECLOSE(i)-CANDLEOPEN(i))
#define CANDLEWICKSIZE(i)     (CANDLEHIGH(i)-CANDLEBODYTOP(i))
#define CANDLETAILSIZE(i)     (CANDLEBODYBOT(i)-CANDLELOW(i))
#define ATRCANDLESIZE(i)      (CANDLESIZE(i)/ATR(i))
#define ATRCANDLEBODYSIZE(i)  (CANDLEBODYSIZE(i)/ATR(i))
#define CANDLEDIRECTION(i)    (CANDLECLOSE(i)>CANDLEOPEN(i)?1:(CANDLECLOSE(i)<CANDLEOPEN(i)?-1:0))
#define CANDLERUNUP(i)        ((CANDLECLOSE(i)>CANDLEOPEN(i))?(CANDLECLOSE(i)-CANDLELOW(i)):0)
#define CANDLERUNDOWN(i)      ((CANDLECLOSE(i)<CANDLEOPEN(i))?(CANDLEHIGH(i)-CANDLECLOSE(i)):0)

// candle feature inquiries (boolean)
#define isCANDLEUP(i)               (CANDLEDIRECTION(i)==1)
#define isCANDLEDOWN(i)             (CANDLEDIRECTION(i)==-1)
#define isCANDLEFLAT(i)             (CANDLEDIRECTION(i)==0)
#define isCANDLEWICKLESS(i)         (CANDLEWICKSIZE(i)==0)
#define isCANDLETAILLESS(i)         (CANDLETAILSIZE(i)==0)
#define isCANDLESOLID(i)            (CANDLEWICKSIZE(i)==0 && CANDLETAILSIZE(i)==0)
#define isCANDLERIGHTDIR(i,dir)     (dir*(CANDLECLOSE(i) - CANDLEOPEN(i))>0)
#define isCANDLEFRACTALTOP(i)       (CANDLEHIGH(i) > CANDLEHIGH(i-1) && CANDLEHIGH(i-1) > CANDLEHIGH(i-2) && CANDLEHIGH(i) > CANDLEHIGH(i+1) && CANDLEHIGH(i+1) > CANDLEHIGH(i+2))
#define isCANDLEFRACTALBOT(i)       (CANDLELOW(i) < CANDLELOW(i-1) && CANDLELOW(i-1) < CANDLELOW(i-2) && CANDLELOW(i) < CANDLELOW(i+1) && CANDLELOW(i+1) < CANDLELOW(i+2))
#define isCANDLEFRACTALEQTOP(i)     (CANDLEHIGH(i) >= CANDLEHIGH(i-1) && CANDLEHIGH(i-1) >= CANDLEHIGH(i-2) && CANDLEHIGH(i) >= CANDLEHIGH(i+1) && CANDLEHIGH(i+1) >= CANDLEHIGH(i+2))
#define isCANDLEFRACTALEQBOT(i)     (CANDLELOW(i) <= CANDLELOW(i-1) && CANDLELOW(i-1) <= CANDLELOW(i-2) && CANDLELOW(i) <= CANDLELOW(i+1) && CANDLELOW(i+1) <= CANDLELOW(i+2))
#define isCANDLEWEAKFRACTALTOP(i)   (CANDLEHIGH(i) > CANDLEHIGH(i-1) && CANDLEHIGH(i) > CANDLEHIGH(i+1))
#define isCANDLEWEAKFRACTALBOT(i)   (CANDLELOW(i) < CANDLELOW(i-1) && CANDLELOW(i) < CANDLELOW(i+1))
#define isCANDLEWEAKFRACTALEQBOT(i) (CANDLELOW(i) <= CANDLELOW(i-1) && CANDLELOW(i) <= CANDLELOW(i+1))
#define isCANDLEWEAKFRACTALEQTOP(i) (CANDLEHIGH(i) >= CANDLEHIGH(i-1) && CANDLEHIGH(i) >= CANDLEHIGH(i+1))
#define is3CANDLEGAPUP(i,gap,size)  (CANDLELOW(i)-CANDLEHIGH(i+2)>gap && CANDLEBODYSIZE(i+1)>=size)
#define is3CANDLEGAPDOWN(i,gap,size) (CANDLELOW(i+2)-CANDLEHIGH(i)>gap && CANDLEBODYSIZE(i+1)>=size)
#define is3CANDLEGAPUPTREND(i,gap,size)  (CANDLELOW(i)-CANDLEHIGH(i+2)>gap && CANDLEBODYSIZE(i+1)>=size &&  isCANDLEUP(i+2))
#define is3CANDLEGAPDOWNTREND(i,gap,size) (CANDLELOW(i+2)-CANDLEHIGH(i)>gap && CANDLEBODYSIZE(i+1)>=size &&  isCANDLEDOWN(i+2))
#define isCANDLEDOJIPOINTS(i,n)     (CANDLEBODYSIZE(i) <= n*_Point)
#define isCANDLEDOJIFRACTION(i,f)   (CANDLEBODYSIZE(i) <= f*CANDLESIZE(i))


// Math functions & operations
#define BRACKET(x,minV,maxV)                 (x<minV?minV:(x>maxV?maxV:x))
#define CONVEXCOMB(a,x1,x2)                  (a*x1+(1.0-a)*x2)
#define EVALLINE(x,x1,y1,x2,y2,ymin,ymax)    BRACKET((y2-y1)/(x2-x1)*(x-x1)+y1,ymin,ymax)
#define MAPAB11(x,A,B)                       (2./(B-A)*(BRACKET(x,A,B)-A)-1.)
#define MAP11AB(x,A,B)                       ((B-A)/2.*(BRACKET(x,-1,1)-1)+B)
#define SIGMOID(x,a)                         (1.0/(1.0 + exp(-a*x)))
#define NN1(x,w,b)                           (w*x+b)
#define EVALPOLY(X,X0,X1,Y0,Y1,EX,ymin,ymax) BRACKET(Y1*pow((X-X0)/(X1-X0),EX)+Y0,ymin,ymax)
#define EVALPOLY2P(X,X0,X1,Y0,Y1,EX,ymn,ymx) BRACKET((Y1-Y0)*pow((X-X0)/(X1-X0),EX)+Y0,ymn,ymx)
#define MA20DIFF(i,n)                        (MOVAVG20(i)-MOVAVG20(i+n))
#define MA40DIFF(i,n)                        (MOVAVG40(i)-MOVAVG40(i+n))
#define MA50DIFF(i,n)                        (MOVAVG50(i)-MOVAVG50(i+n))
#define MA200DIFF(i,n)                       (MOVAVG200(i)-MOVAVG200(i+n))
#define CANDLECLOSEDIFF(i,n)                 (CANDLECLOSE(i)-CANDLECLOSE(i+n))
#define CANDLEOPENDIFF(i,n)                  (CANDLEOPEN(i)-CANDLEOPEN(i+n))
#define CANDLEHIGHDIFF(i,n)                  (CANDLEHIGH(i)-CANDLEHIGH(i+n))
#define CANDLELOWDIFF(i,n)                   (CANDLELOW(i)-CANDLELOW(i+n))
#define CANDLEMEDIANDIFF(i,n)                (CANDLEMEDIAN(i)-CANDLEMEDIAN(i+n))
#define CANDLEWEIGHTEDDIFF(i,n)              (CANDLEWEIGHTED(i)-CANDLEWEIGHTED(i+n))
#define CANDLETYPICALDIFF(i,n)               (CANDLETYPICAL(i)-CANDLETYPICAL(i+n))
#define CANDLEBODYMIDDLEDIFF(i,n)            (CANDLEBODYMIDDLE(i)-CANDLEBODYMIDDLE(i+n))
#define isINBRACKET(x,minV,maxV)             (x<=maxV && x>=minV)
#define isINBRACKETSTRICT(x,minV,maxV)       (x<maxV && x>minV)
#define isOUTBRACKET(x,minV,maxV)            (x>=maxV || x<=minV)
#define isOUTBRACKETSTRICT(x,minV,maxV)      (x> maxV || x< minV)
#define isCONVEX(yl,yc,yr)                   (yl>=yc && yc<=yr)
#define isCONCAVE(yl,yc,yr)                  (yl<=yc && yc>=yr)
#define isCONVEXTSTRICT(yl,yc,yr)            (yl>yc && yc<yr)
#define isCONCAVESTRICT(yl,yc,yr)            (yl<yc && yc>yr)

// Constants
#define PIVALUE                              (M_PI)
#define MINSTOPPOINTS                        (30)
#define MINFREEZEPOINTS                      (30)
#define STOPLEVEL                            (fmax(MINSTOPPOINTS,(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL))*_Point)
#define FREEZELEVEL                          (fmax(MINFREEZEPOINTS,(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL))*_Point)

// Debugging with Print	
// At the beginning of your code define the debug level x={0,1,2} as: #define DEBUG_LEVELx	
#ifdef DEBUG_LEVEL0
#define PRINTTEXT(text)
#define PRINTVAR(x1)
#define PRINTVAR1(x1)
#define PRINTVAR2(x1,x2)
#define PRINTVAR3(x1,x2,x3)
#define PRINTVAR4(x1,x2,x3,x4)
#define PRINTVAR5(x1,x2,x3,x4,x5)
#define PRINTVAR6(x1,x2,x3,x4,x5,x6)

#define VPRINTTEXT(text)
#define VPRINTVAR(x1)
#define VPRINTVAR1(x1)
#define VPRINTVAR2(x1,x2)
#define VPRINTVAR3(x1,x2,x3)
#define VPRINTVAR4(x1,x2,x3,x4)
#define VPRINTVAR5(x1,x2,x3,x4,x5)
#define VPRINTVAR6(x1,x2,x3,x4,x5,x6)

#endif
												
#ifdef DEBUG_LEVEL1
#define PRINTTEXT(text)           Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :",text)
#define PRINTVAR(x1)              Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1))
#define PRINTVAR1(x1)             Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1))
#define PRINTVAR2(x1,x2)          Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2))
#define PRINTVAR3(x1,x2,x3)       Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3))
#define PRINTVAR4(x1,x2,x3,x4)    Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4))
#define PRINTVAR5(x1,x2,x3,x4,x5) Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4),", " #x5 + "=", (x5))
#define PRINTVAR6(x1,x2,x3,x4,x5,x6) Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4),", " #x5 + "=", (x5),", " #x6 + "=", (x6))

#define VPRINTTEXT(text)
#define VPRINTVAR(x1)
#define VPRINTVAR1(x1)
#define VPRINTVAR2(x1,x2)
#define VPRINTVAR3(x1,x2,x3)
#define VPRINTVAR4(x1,x2,x3,x4)
#define VPRINTVAR5(x1,x2,x3,x4,x5)
#define VPRINTVAR6(x1,x2,x3,x4,x5,x6)
#endif

#ifdef  DEBUG_LEVEL2
#define PRINTTEXT(text)           Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :",text)
#define PRINTVAR(x1)              Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1))
#define PRINTVAR1(x1)             Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1))
#define PRINTVAR2(x1,x2)          Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2))
#define PRINTVAR3(x1,x2,x3)       Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3))
#define PRINTVAR4(x1,x2,x3,x4)    Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4))
#define PRINTVAR5(x1,x2,x3,x4,x5) Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4),", " #x5 + "=", (x5))
#define PRINTVAR6(x1,x2,x3,x4,x5,x6) Print("*/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4),", " #x5 + "=", (x5),", " #x6 + "=", (x6))

#define VPRINTTEXT(text)           Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :",text)
#define VPRINTVAR(x1)              Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1))
#define VPRINTVAR1(x1)             Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1))
#define VPRINTVAR2(x1,x2)          Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2))
#define VPRINTVAR3(x1,x2,x3)       Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3))
#define VPRINTVAR4(x1,x2,x3,x4)    Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4))
#define VPRINTVAR5(x1,x2,x3,x4,x5) Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4),", " #x5 + "=", (x5))
#define VPRINTVAR6(x1,x2,x3,x4,x5,x6) Print("V/*/*/* ",__FUNCTION__,"(",__LINE__,") :", #x1 + "=", (x1),", " #x2 + "=", (x2),", " #x3 + "=", (x3),", " #x4 + "=", (x4),", " #x5 + "=", (x5),", " #x6 + "=", (x6))
#endif
