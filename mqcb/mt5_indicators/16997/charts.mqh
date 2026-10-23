#include <AIV/Matrices.mqh>

void ShowVector(SSeries& series[], double& vectors[], const int order, const string name)
{
    double max = 0;    
    datetime times[];
    int X = 10, Y = 5, size = 8, offset = int(ChartGetDouble(0, CHART_SHIFT_SIZE) * ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / 100);

    for (int k = 0; k < order; k++) 
    {
        max = MathAbs(vectors[k]) > max ? MathAbs(vectors[k]) : max;
    }

    int maxPixel = offset - 155;

    if (max)
    {
        for (int k = 0; k < order; k++) 
        {
            string alignment = (vectors[k] >= 0 ? " " : "") + DoubleToString(vectors[k], _Digits);
            string label = StringFormat("%s  | %s", series[k].mSymbol.mName, alignment);
            int level = int(MathCeil(MathAbs(vectors[k]) * maxPixel / max));
    
            ShowItem(name, OBJ_LABEL, name + series[k].mSymbol.mName + "A", label, X, Y, size, clrBlack);
            ShowItem(name, OBJ_RECTANGLE_LABEL, name + series[k].mSymbol.mName + "B", series[k].mSymbol.mName, X + level + 110, Y + 2, size, vectors[k] > 0 ? clrDeepSkyBlue : clrTomato, level, 10);
            
            Y += size * 2;
        }
    }
}

void ShowItem(const string indicator, const ENUM_OBJECT type, const string name, const string value, const int X, const int Y, const int size, const color clr, const int W = 0, const int H = 0, ENUM_ANCHOR_POINT point = ANCHOR_RIGHT_UPPER, ENUM_BASE_CORNER corner = CORNER_RIGHT_UPPER)
{
    long chart = ChartID();
    int window = ChartWindowFind(chart, indicator);

    if (ObjectFind(chart, name) < 0)
    {
        ObjectCreate(chart, name, type, window, 0, 0);
    }

    ObjectSetInteger(chart, name, OBJPROP_ANCHOR, point);
    ObjectSetInteger(chart, name, OBJPROP_CORNER, corner);
    ObjectSetInteger(chart, name, OBJPROP_FONTSIZE, size);
    ObjectSetInteger(chart, name, OBJPROP_XDISTANCE, X);
    ObjectSetInteger(chart, name, OBJPROP_YDISTANCE, Y);
    ObjectSetInteger(chart, name, OBJPROP_COLOR, clr);
    ObjectSetString(chart, name, OBJPROP_TEXT, value);

    if (type == OBJ_RECTANGLE_LABEL) 
    {
        ObjectSetInteger(chart, name, OBJPROP_BGCOLOR, clr);
        ObjectSetInteger(chart, name, OBJPROP_BACK, false);
        ObjectSetInteger(chart, name, OBJPROP_FILL, true);
        ObjectSetInteger(chart, name, OBJPROP_WIDTH, 0);
        ObjectSetInteger(chart, name, OBJPROP_YSIZE, H);
        ObjectSetInteger(chart, name, OBJPROP_XSIZE, W);
    }
}

bool SetLine(const string name, const datetime time)
{
    long chart = ChartID();
    int window = ChartWindowFind();

    if (ObjectFind(chart, name) < 0)
    {
        ObjectCreate(chart, name, OBJ_VLINE, window, 0, 0);
    }
    
    ObjectSetInteger(chart, name, OBJPROP_RAY, true);
    ObjectSetInteger(chart, name, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(chart, name, OBJPROP_STYLE, STYLE_DOT);
    
    ObjectMove(chart, name, 0, time, 0);
    
    return true;
}

void HidePanel(string name)
{
    long chart = ChartID();
    int window = ChartWindowFind(chart, name);
    ObjectsDeleteAll(chart, window, OBJ_VLINE);
    ObjectsDeleteAll(chart, window, OBJ_LABEL);
    ObjectsDeleteAll(chart, window, OBJ_RECTANGLE_LABEL);
}

void SetHLine(const string name, const double price)
{
    long chart = ChartID();
    int window = ChartWindowFind();

    if (ObjectFind(chart, name) < 0)
    {
        ObjectCreate(chart, name, OBJ_HLINE, window, 0, price);
    }

    ObjectSetInteger(chart, name, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(chart, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(chart, name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(chart, name, OBJPROP_BACK, true);
}

void HideHLine()
{
    long chart = ChartID();
    int window = ChartWindowFind();

    ObjectsDeleteAll(chart, window, OBJ_HLINE);
}