//+------------------------------------------------------------------+
//|                                              WeekendGapStats.mq5 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Illia Ivanov"
#property link      ""
#property version   "1.40"
#property indicator_chart_window
#property indicator_plots 0 

//--- Input Parameters
input int    InpMinGapPoints = 20;     // Minimum Gap Size (in Points)
input int    InpMaxBarsScan  = 100000; // Max History Bars to Scan

//--- Data Structure
struct GapData {
    datetime time;
    double   gapPoints;
    bool     isUp;
    bool     isClosed;
    double   maxExcursion; // MAE (Adverse)
    double   maxFavorable; // MFE (Favorable)
};

//--- Global Variables
GapData gaps[];
int     gapCount = 0;
string  prefix = "WGStats_"; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    ArrayResize(gaps, 2000);
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    ObjectsDeleteAll(0, prefix);
    ChartRedraw();
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
    if(rates_total < 10) return 0;

    ArraySetAsSeries(time, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true);
    
    gapCount = 0; 
    int limit = MathMin(rates_total - 2, InpMaxBarsScan);
    MqlDateTime dt_curr, dt_prev;

    for(int i = limit; i >= 0; i--) {
        TimeToStruct(time[i], dt_curr);     
        TimeToStruct(time[i+1], dt_prev);   

        if(dt_prev.day_of_week == 5 && (dt_curr.day_of_week == 0 || dt_curr.day_of_week == 1)) {
            double gapSize = open[i] - close[i+1];
            
            if(MathAbs(gapSize) >= InpMinGapPoints * _Point) {
                if(gapCount >= ArraySize(gaps)) {
                    ArrayResize(gaps, ArraySize(gaps) + 500);
                }

                gaps[gapCount].time = time[i];
                gaps[gapCount].gapPoints = MathAbs(gapSize) / _Point;
                gaps[gapCount].isUp = (gapSize > 0);
                gaps[gapCount].isClosed = false;
                gaps[gapCount].maxExcursion = 0.0;
                gaps[gapCount].maxFavorable = 0.0;

                double refClose = close[i+1]; 

                for(int j = i; j >= 0; j--) {
                    if(gaps[gapCount].isUp) { 
                        double adv = (high[j] - open[i]) / _Point;
                        double fav = (open[i] - low[j]) / _Point;
                        
                        if(adv > gaps[gapCount].maxExcursion) gaps[gapCount].maxExcursion = adv;
                        if(fav > gaps[gapCount].maxFavorable) gaps[gapCount].maxFavorable = fav;
                        
                        if(low[j] <= refClose) { gaps[gapCount].isClosed = true; break; }
                    } 
                    else { 
                        double adv = (open[i] - low[j]) / _Point;
                        double fav = (high[j] - open[i]) / _Point;
                        
                        if(adv > gaps[gapCount].maxExcursion) gaps[gapCount].maxExcursion = adv;
                        if(fav > gaps[gapCount].maxFavorable) gaps[gapCount].maxFavorable = fav;
                        
                        if(high[j] >= refClose) { gaps[gapCount].isClosed = true; break; }
                    }
                }
                gapCount++; 
            }
        }
    }

    UpdateDashboard();
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Formats the string and sends it to the drawing function          |
//+------------------------------------------------------------------+
void UpdateDashboard() {
    string displayTxt = "====== WEEKEND GAP STATISTICS ======\n\n";
    
    if(gapCount == 0) {
        DrawPanel(displayTxt + "No gaps found. Try lowering 'Min Gap Points'.");
        return;
    }

    int count5 = MathMin(5, gapCount);
    displayTxt += GenerateStatString("Last 5 Gaps", gapCount - 1, count5);

    int countYear = 0;
    datetime oneYearAgo = TimeCurrent() - (365 * 24 * 60 * 60);
    for(int i = gapCount - 1; i >= 0; i--) {
        if(gaps[i].time >= oneYearAgo) countYear++;
        else break; 
    }
    displayTxt += GenerateStatString("Last 12 Months", gapCount - 1, countYear);
    displayTxt += GenerateStatString("All Time (Scanned)", gapCount - 1, gapCount);

    DrawPanel(displayTxt);
}

//+------------------------------------------------------------------+
//| Generates the stats block, including Size, MFE, and Percentiles  |
//+------------------------------------------------------------------+
string GenerateStatString(string title, int startIndex, int count) {
    if(count == 0 || startIndex < 0) return StringFormat("--- %s ---\nNo gaps in this period.\n\n", title);

    int closedCount = 0;
    double sumExcursion = 0.0;
    double sumGapSize = 0.0;
    double sumMFE = 0.0;
    
    double mfe_arr[]; ArrayResize(mfe_arr, count); 
    double mae_arr[]; ArrayResize(mae_arr, count); 

    for(int i = 0; i < count; i++) {
        int idx = startIndex - i;
        if(idx < 0) break;
        
        sumGapSize += gaps[idx].gapPoints;
        
        // MFE is collected for ALL gaps to know TP probabilities
        mfe_arr[i] = gaps[idx].maxFavorable;
        sumMFE += gaps[idx].maxFavorable;
        
        // MAE is collected only for CLOSED gaps to know SL survival probabilities
        if(gaps[idx].isClosed) {
            mae_arr[closedCount] = gaps[idx].maxExcursion;
            sumExcursion += gaps[idx].maxExcursion;
            closedCount++;
        }
    }

    double closureRate = (double)closedCount / count * 100.0;
    double avgGapSize = sumGapSize / count;
    double avgMFE = sumMFE / count;
    double avgMAE = (closedCount > 0) ? (sumExcursion / closedCount) : 0.0;
    
    // Sort MFE array (Ascending)
    ArraySort(mfe_arr);
    
    // TP Probabilities (What % of gaps went AT LEAST this far)
    // 95% win rate = 5th percentile ascending
    double mfe95 = mfe_arr[(int)MathRound((count - 1) * 0.05)]; 
    double mfe70 = mfe_arr[(int)MathRound((count - 1) * 0.30)]; 
    double mfe50 = mfe_arr[(int)MathRound((count - 1) * 0.50)]; 
    double mfe25 = mfe_arr[(int)MathRound((count - 1) * 0.75)]; 

    string out = StringFormat("--- %s ---\n", title);
    out += StringFormat("Total: %d  |  Closed: %d (%.1f%%)\n", count, closedCount, closureRate);
    out += StringFormat("Avg Size: %.1f pts | Avg MFE: %.1f | Avg MAE: %.1f\n", avgGapSize, avgMFE, avgMAE);
    out += StringFormat("TP Hit Rate (MFE >=): 95%%=>%.0f | 70%%=>%.0f | 50%%=>%.0f | 25%%=>%.0f pts\n", mfe95, mfe70, mfe50, mfe25);
    
    if(closedCount > 0) {
        ArrayResize(mae_arr, closedCount); 
        ArraySort(mae_arr); 
        
        // SL Survival Probabilities (What % of closed gaps stayed UNDER this heat)
        double mae25 = mae_arr[(int)MathRound((closedCount - 1) * 0.25)];
        double mae50 = mae_arr[(int)MathRound((closedCount - 1) * 0.50)];
        double mae70 = mae_arr[(int)MathRound((closedCount - 1) * 0.70)];
        double mae95 = mae_arr[(int)MathRound((closedCount - 1) * 0.95)];
        
        out += StringFormat("SL Survival (MAE <=): 25%%=>%.0f | 50%%=>%.0f | 70%%=>%.0f | 95%%=>%.0f pts\n\n", mae25, mae50, mae70, mae95);
    } else {
        out += "SL Survival: N/A (No closed gaps)\n\n";
    }
    
    return out;
}

//+------------------------------------------------------------------+
//| Draws the text using Graphical Objects in the Lower-Left Corner  |
//+------------------------------------------------------------------+
void DrawPanel(string text) {
    string lines[];
    int numLines = StringSplit(text, '\n', lines);
    
    ObjectsDeleteAll(0, prefix);
    
    color bg = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
    int r = (bg >> 16) & 0xFF;
    int g = (bg >> 8) & 0xFF;
    int b = bg & 0xFF;
    
    color textColor = clrWhite; 
    if((r * 0.299 + g * 0.587 + b * 0.114) > 128) {
        textColor = clrBlack; 
    }

    int lineHeight = 13; 
    int startY = 15;     
    int fontSize = 8;    
    
    for(int i = 0; i < numLines; i++) {
        if(lines[i] == "") continue; 
        
        string objName = prefix + IntegerToString(i);
        ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 10);
        
        int yPos = startY + ((numLines - 1 - i) * lineHeight);
        ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yPos);
        
        ObjectSetString(0, objName, OBJPROP_TEXT, lines[i]);
        ObjectSetString(0, objName, OBJPROP_FONT, "Courier New"); 
        ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, textColor);
        ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true); 
    }
    
    ChartRedraw();
}
//+------------------------------------------------------------------+