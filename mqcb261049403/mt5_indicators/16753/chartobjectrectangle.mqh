#include "ChartObject.mqh"

class CHARTOBJECTRECTANGLE : public CHARTOBJECT
{
public:
  CHARTOBJECTRECTANGLE( const long chart_id = 0, const int sub_window = 0, const bool Add = FALSE )
                    : CHARTOBJECT(Add, chart_id, (string)::MathRand(), ::OBJ_RECTANGLE, sub_window, 0, 0)
  {
  }
};