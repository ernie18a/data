Calculation: FlowScale = HMA-smoothed normalized PVT, where PVT is cumulative(((close - prior close) / prior close) * volume), and normalized PVT is 200 * (PVT - rolling lowest PVT) / (rolling highest PVT - rolling lowest PVT) - 100
Long: FlowScale > positive balance buffer
Short: FlowScale < negative balance buffer