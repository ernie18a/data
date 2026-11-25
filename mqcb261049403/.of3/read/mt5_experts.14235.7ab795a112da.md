Calculation: price distance = normalize to symbol digits (trade tick size × (ceil(deviation in points × point size / trade tick size) if deviation is nonnegative, otherwise floor(deviation in points × point size / trade tick size)))
Long: last trade price >= ask + price distance
Short: last trade price <= bid - price distance
Exit: long, weekend OR outside all four configured trading intervals OR entry price < bid OR (entry price = bid AND last trade price captured when the entry order was placed <= ask)
Exit: short, weekend OR outside all four configured trading intervals OR entry price > ask OR (entry price = ask AND last trade price captured when the entry order was placed >= bid)