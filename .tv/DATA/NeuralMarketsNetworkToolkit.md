<!-- tradingview-pine-id: PUB;cb0ef8cfeac841d788187d4df16ec86e -->
<!-- tradingviewscripts-format: 1 -->
# NeuralMarketsNetworkToolkit

Source: https://www.tradingview.com/script/PHUhggJX-NeuralMarketsNetworkToolkit/

## Description

Library  "NeuralMarketsNetworkToolkit"

Open-source network analysis toolkit for Pine Script.

This library provides reusable graph algorithms, matrix utilities and network analytics for building advanced multi-asset indicators. Rather than treating markets as isolated charts, it enables developers to model relationships between assets as weighted networks and extract structural characteristics such as connectivity, centrality, clustering and influence.

Current Modules

• Matrix utilities
• Directed & undirected graphs
• Network analytics
• Node analytics
• Graph algorithms
• Experimental financial network tools

Example Applications

• Correlation networks
• Market leadership analysis
• Sector relationship maps
• Cross-asset dependency analysis
• Financial network research

Design Philosophy

This toolkit provides reusable quantitative building blocks rather than trading signals. Functions are intentionally modular so they can be combined into custom indicators and research projects.

Markets are networks. This toolkit provides the building blocks to analyze them as such.

--------------------------------------------------------------------

matrixIndex(row, col, n)
  Converts row/column coordinates into a flat matrix index.
  Parameters:
    row (int): Row index.
    col (int): Column index.
    n (int): Matrix dimension.
  Returns: Flat-array index.

clamp(x, lo, hi)
  Clamp a float.
  Parameters:
    x (float): Value.
    lo (float): Minimum.
    hi (float): Maximum.
  Returns: Clamped value.

newMatrix(n, initialValue)
  Creates an n x n flat matrix initialized to a value.
  Parameters:
    n (int): Number of nodes.
    initialValue (float): Initial cell value.
  Returns: Flat float array.

setCell(matrix, row, col, n, value)
  Sets a matrix cell.
  Parameters:
    matrix (array<float>): Flat matrix.
    row (int): Row.
    col (int): Column.
    n (int): Matrix dimension.
    value (float): New value.

getCell(matrix, row, col, n)
  Gets a matrix cell.
  Parameters:
    matrix (array<float>): Flat matrix.
    row (int): Row.
    col (int): Column.
    n (int): Matrix dimension.
  Returns: Cell value.

setUndirectedEdge(matrix, a, b, n, weight)
  Sets both directions of an undirected edge.
  Parameters:
    matrix (array<float>): Flat matrix.
    a (int): Node A.
    b (int): Node B.
    n (int): Matrix dimension.
    weight (float): Edge weight.

meanAbsoluteConnectivity(matrix, n)
  Average absolute pairwise edge weight.
  Parameters:
    matrix (array<float>): Symmetric adjacency/weight matrix.
    n (int): Number of nodes.
  Returns: Average absolute connectivity from 0 upward.

meanSignedConnectivity(matrix, n)
  Average signed pairwise weight.
  Parameters:
    matrix (array<float>): Symmetric matrix.
    n (int): Number of nodes.
  Returns: Mean signed relationship.

density(matrix, n, threshold)
  Proportion of possible edges whose absolute weight exceeds threshold.
  Parameters:
    matrix (array<float>): Symmetric weight matrix.
    n (int): Number of nodes.
    threshold (float): Absolute edge threshold.
  Returns: Network density from 0 to 1.

fragmentation(matrix, n, threshold)
  Network fragmentation as inverse threshold density.
  Parameters:
    matrix (array<float>): Symmetric weight matrix.
    n (int): Number of nodes.
    threshold (float): Edge threshold.
  Returns: Fragmentation from 0 to 1.

nodeDegree(matrix, n, node, threshold)
  Number of strong edges attached to a node.
  Parameters:
    matrix (array<float>): Weight matrix.
    n (int): Number of nodes.
    node (int): Node index.
    threshold (float): Absolute edge threshold.
  Returns: Degree count.

nodeStrength(matrix, n, node)
  Sum of absolute edge weights attached to node.
  Parameters:
    matrix (array<float>): Weight matrix.
    n (int): Number of nodes.
    node (int): Node index.
  Returns: Node strength.

strongestNode(matrix, n)
  Node with greatest absolute network strength.
  Parameters:
    matrix (array<float>): Weight matrix.
    n (int): Number of nodes.
  Returns: Strongest node index.

averageNodeStrength(matrix, n)
  Average node strength.
  Parameters:
    matrix (array<float>): Weight matrix.
    n (int): Number of nodes.
  Returns: Mean strength.

centralization(matrix, n)
  Measures how much one node dominates the network.
  Parameters:
    matrix (array<float>): Weight matrix.
    n (int): Number of nodes.
  Returns: Strength centralization approximately 0 to 1.

strengthEntropy(matrix, n)
  Shannon entropy of node-strength distribution.
  Parameters:
    matrix (array<float>): Weight matrix.
    n (int): Number of nodes.
  Returns: Normalized entropy from 0 to 1.

mstDistance(matrix, n)
  Computes total Prim minimum-spanning-tree distance.
Similarity is converted to distance using 1 - abs(similarity).
  Parameters:
    matrix (array<float>): Similarity matrix.
    n (int): Number of nodes.
  Returns: Total MST distance.

mstCompactness(matrix, n)
  Converts MST distance to compactness.
  Parameters:
    matrix (array<float>): Similarity matrix.
    n (int): Number of nodes.
  Returns: Network compactness from approximately 0 to 1.

setDirectedEdge(matrix, fromNode, toNode, n, weight)
  Sets one directed edge.
  Parameters:
    matrix (array<float>): Flat directed adjacency matrix.
    fromNode (int): Source node.
    toNode (int): Destination node.
    n (int): Number of nodes.
    weight (float): Directed edge weight.

outStrength(matrix, n, node)
  Sum of outgoing positive influence from a node.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
    node (int): Source node.
  Returns: Total outbound influence.

inStrength(matrix, n, node)
  Sum of incoming positive influence to a node.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
    node (int): Destination node.
  Returns: Total inbound influence.

netInfluence(matrix, n, node)
  Net directional leadership.
Positive means the node influences others more than it follows them.
Negative means the node behaves more like a follower.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
    node (int): Node index.
  Returns: Outbound minus inbound influence.

normalizedLeadership(matrix, n, node)
  Normalized directional leadership score.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
    node (int): Node index.
  Returns: Score approximately from -1 to +1.

leadingNode(matrix, n)
  Node with the largest net directional influence.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
  Returns: Node index.

followingNode(matrix, n)
  Node with the greatest incoming influence.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
  Returns: Node index.

meanDirectedInfluence(matrix, n)
  Average directed influence in the network.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
  Returns: Mean positive directed edge weight.

leadershipConcentration(matrix, n)
  Concentration of outbound influence.
High values mean leadership is concentrated in fewer nodes.
  Parameters:
    matrix (array<float>): Directed matrix.
    n (int): Number of nodes.
  Returns: Herfindahl-style concentration from 0 to 1.

connectedComponentsCount(matrix, n, threshold)
  Counts connected components in an undirected threshold graph.
  Parameters:
    matrix (array<float>): Symmetric adjacency / similarity matrix.
    n (int): Number of nodes.
    threshold (float): Minimum absolute edge weight required to connect nodes.
  Returns: Number of connected components.

localClusteringCoefficient(matrix, n, node, threshold)
  Computes local clustering coefficient for one node.
Measures how interconnected the node's neighbors are.
  Parameters:
    matrix (array<float>): Symmetric similarity matrix.
    n (int): Number of nodes.
    node (int): Node index.
    threshold (float): Minimum absolute edge weight to define a connection.
  Returns: Local clustering coefficient from 0 to 1.

averageClusteringCoefficient(matrix, n, threshold)
  Computes mean clustering coefficient across all nodes.
  Parameters:
    matrix (array<float>): Symmetric similarity matrix.
    n (int): Number of nodes.
    threshold (float): Minimum absolute edge weight.
  Returns: Average clustering coefficient from 0 to 1.

similarityDistance(similarity)
  Converts similarity to graph distance.
Higher similarity becomes shorter distance.
  Parameters:
    similarity (float): Edge similarity, typically from 0 to 1 in magnitude.
  Returns: Distance from 0 to 1.

shortestPathDistance(matrix, n, source, target)
  Dijkstra shortest-path distance between two nodes.
Uses distance = 1 - abs(similarity).
  Parameters:
    matrix (array<float>): Weighted matrix.
    n (int): Number of nodes.
    source (int): Start node.
    target (int): End node.
  Returns: Shortest path distance.

averagePathLength(matrix, n)
  Average shortest-path distance across all node pairs.
  Parameters:
    matrix (array<float>): Weighted matrix.
    n (int): Number of nodes.
  Returns: Mean shortest path distance.

eigenvectorCentrality(matrix, n, node, iterations)
  Approximate eigenvector centrality for one node using power iteration.
  Parameters:
    matrix (array<float>): Weighted matrix.
    n (int): Number of nodes.
    node (int): Node index.
    iterations (int): Number of power iterations.
  Returns: Approximate normalized centrality from 0 to 1.

eigenvectorLeader(matrix, n, iterations)
  Returns node with highest eigenvector centrality.
  Parameters:
    matrix (array<float>): Weighted matrix.
    n (int): Number of nodes.
    iterations (int): Number of power iterations.
  Returns: Node index.

nodeStrengthPercentile(matrix, n, node)
  Cross-sectional percentile rank for a node's strength.
  Parameters:
    matrix (array<float>): Weighted matrix.
    n (int): Number of nodes.
    node (int): Node index.
  Returns: Percentile rank from 0 to 100.

nodeStrengthRank(matrix, n, node)
  Returns the rank position of a node by strength.
Rank 1 means strongest.
  Parameters:
    matrix (array<float>): Weighted matrix.
    n (int): Number of nodes.
    node (int): Node index.
  Returns: One-based rank.

networkCohesion(matrix, n, threshold)
  Composite network cohesion score.
Combines connectivity, density and clustering coefficient.
  Parameters:
    matrix (array<float>): Symmetric similarity matrix.
    n (int): Number of nodes.
    threshold (float): Edge threshold.
  Returns: Composite cohesion from 0 to 1.

---

## Source Code

````pine
//@version=6
//@version=6

//-----------------------------------------------------------------------------
// NeuralMarkets Network Toolkit
//
// Open-source network analysis toolkit for Pine Script
//
// Provides reusable graph algorithms, matrix utilities, network analytics,
// centrality measures, clustering algorithms and financial network primitives
// for building advanced multi-asset indicators.
//
// Project:
// https://www.tradingview.com/u/NeuralMarkets/
//
//-----------------------------------------------------------------------------
library("NeuralMarketsNetworkToolkit", false)

//====================================================================
// BASIC HELPERS
//====================================================================

// @function Converts row/column coordinates into a flat matrix index.
// @param row Row index.
// @param col Column index.
// @param n Matrix dimension.
// @returns Flat-array index.
export matrixIndex(int row, int col, int n) =>
    row * n + col


// @function Clamp a float.
// @param x Value.
// @param lo Minimum.
// @param hi Maximum.
// @returns Clamped value.
export clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))


//====================================================================
// MATRIX CONSTRUCTION
//====================================================================

// @function Creates an n x n flat matrix initialized to a value.
// @param n Number of nodes.
// @param initialValue Initial cell value.
// @returns Flat float array.
export newMatrix(int n, float initialValue = 0.0) =>
    array.new_float(n * n, initialValue)


// @function Sets a matrix cell.
// @param matrix Flat matrix.
// @param row Row.
// @param col Column.
// @param n Matrix dimension.
// @param value New value.
export setCell(array<float> matrix, int row, int col, int n, float value) =>
    int idx = row * n + col
    array.set(matrix, idx, value)


// @function Gets a matrix cell.
// @param matrix Flat matrix.
// @param row Row.
// @param col Column.
// @param n Matrix dimension.
// @returns Cell value.
export getCell(array<float> matrix, int row, int col, int n) =>
    int idx = row * n + col
    array.get(matrix, idx)


// @function Sets both directions of an undirected edge.
// @param matrix Flat matrix.
// @param a Node A.
// @param b Node B.
// @param n Matrix dimension.
// @param weight Edge weight.
export setUndirectedEdge(array<float> matrix, int a, int b, int n, float weight) =>
    int idx1 = a * n + b
    int idx2 = b * n + a
    array.set(matrix, idx1, weight)
    array.set(matrix, idx2, weight)


//====================================================================
// NETWORK CONNECTIVITY
//====================================================================

// @function Average absolute pairwise edge weight.
// @param matrix Symmetric adjacency/weight matrix.
// @param n Number of nodes.
// @returns Average absolute connectivity from 0 upward.
export meanAbsoluteConnectivity(array<float> matrix, int n) =>
    float total = 0.0
    int count = 0
    if n > 1
        for i = 0 to n - 2
            for j = i + 1 to n - 1
                float w = array.get(matrix, i * n + j)
                total += math.abs(w)
                count += 1
    count > 0 ? total / count : 0.0


// @function Average signed pairwise weight.
// @param matrix Symmetric matrix.
// @param n Number of nodes.
// @returns Mean signed relationship.
export meanSignedConnectivity(array<float> matrix, int n) =>
    float total = 0.0
    int count = 0
    if n > 1
        for i = 0 to n - 2
            for j = i + 1 to n - 1
                float w = array.get(matrix, i * n + j)
                total += w
                count += 1
    count > 0 ? total / count : 0.0


// @function Proportion of possible edges whose absolute weight exceeds threshold.
// @param matrix Symmetric weight matrix.
// @param n Number of nodes.
// @param threshold Absolute edge threshold.
// @returns Network density from 0 to 1.
export density(array<float> matrix, int n, float threshold) =>
    int activeEdges = 0
    int possibleEdges = n * (n - 1) / 2
    if n > 1
        for i = 0 to n - 2
            for j = i + 1 to n - 1
                float w = math.abs(array.get(matrix, i * n + j))
                if w >= threshold
                    activeEdges += 1
    possibleEdges > 0 ? activeEdges * 1.0 / possibleEdges : 0.0


// @function Network fragmentation as inverse threshold density.
// @param matrix Symmetric weight matrix.
// @param n Number of nodes.
// @param threshold Edge threshold.
// @returns Fragmentation from 0 to 1.
export fragmentation(array<float> matrix, int n, float threshold) =>
    float d = density(matrix, n, threshold)
    1.0 - d


//====================================================================
// NODE METRICS
//====================================================================

// @function Number of strong edges attached to a node.
// @param matrix Weight matrix.
// @param n Number of nodes.
// @param node Node index.
// @param threshold Absolute edge threshold.
// @returns Degree count.
export nodeDegree(array<float> matrix, int n, int node, float threshold) =>
    int degree = 0
    if n > 1
        for j = 0 to n - 1
            if j != node
                float w = math.abs(array.get(matrix, node * n + j))
                if w >= threshold
                    degree += 1
    degree


// @function Sum of absolute edge weights attached to node.
// @param matrix Weight matrix.
// @param n Number of nodes.
// @param node Node index.
// @returns Node strength.
export nodeStrength(array<float> matrix, int n, int node) =>
    float strength = 0.0
    if n > 1
        for j = 0 to n - 1
            if j != node
                strength += math.abs(array.get(matrix, node * n + j))
    strength


// @function Node with greatest absolute network strength.
// @param matrix Weight matrix.
// @param n Number of nodes.
// @returns Strongest node index.
export strongestNode(array<float> matrix, int n) =>
    int bestNode = 0
    float bestStrength = -1.0
    if n > 0
        for i = 0 to n - 1
            float strength = nodeStrength(matrix, n, i)
            if strength > bestStrength
                bestStrength := strength
                bestNode := i
    bestNode


// @function Average node strength.
// @param matrix Weight matrix.
// @param n Number of nodes.
// @returns Mean strength.
export averageNodeStrength(array<float> matrix, int n) =>
    float total = 0.0
    if n > 0
        for i = 0 to n - 1
            total += nodeStrength(matrix, n, i)
    n > 0 ? total / n : 0.0


//====================================================================
// NETWORK CENTRALIZATION
//====================================================================

// @function Measures how much one node dominates the network.
// @param matrix Weight matrix.
// @param n Number of nodes.
// @returns Strength centralization approximately 0 to 1.
export centralization(array<float> matrix, int n) =>
    float maximum = 0.0
    float sumStrength = 0.0
    if n > 0
        for i = 0 to n - 1
            float strength = nodeStrength(matrix, n, i)
            maximum := math.max(maximum, strength)
            sumStrength += strength
    float meanStrength = n > 0 ? sumStrength / n : 0.0
    float maxPossible = math.max(n - 1, 1)
    clamp((maximum - meanStrength) / maxPossible, 0.0, 1.0)


//====================================================================
// NETWORK ENTROPY
//====================================================================

// @function Shannon entropy of node-strength distribution.
// @param matrix Weight matrix.
// @param n Number of nodes.
// @returns Normalized entropy from 0 to 1.
export strengthEntropy(array<float> matrix, int n) =>
    float totalStrength = 0.0
    if n > 0
        for i = 0 to n - 1
            totalStrength += nodeStrength(matrix, n, i)

    float entropyValue = 0.0
    if totalStrength > 0 and n > 1
        for i = 0 to n - 1
            float strength = nodeStrength(matrix, n, i)
            float p = strength / totalStrength
            if p > 0
                entropyValue += -p * math.log(p)

    n > 1 ? entropyValue / math.log(n) : 0.0


//====================================================================
// MINIMUM SPANNING TREE
//
// Distance interpretation:
// distance = 1 - abs(weight)
//
// Highly related nodes therefore have short graph distance.
//====================================================================

// @function Computes total Prim minimum-spanning-tree distance.
// Similarity is converted to distance using 1 - abs(similarity).
// @param matrix Similarity matrix.
// @param n Number of nodes.
// @returns Total MST distance.
export mstDistance(array<float> matrix, int n) =>
    float totalDistance = 0.0
    array<bool> selected = array.new_bool(n, false)
    array<float> minDistance = array.new_float(n, 1.0)

    if n > 0
        array.set(selected, 0, true)
        array.set(minDistance, 0, 0.0)

        if n > 1
            for i = 1 to n - 1
                float similarity = math.abs(array.get(matrix, i))
                float edgeDistance = 1.0 - math.max(0.0, math.min(1.0, similarity))
                array.set(minDistance, i, edgeDistance)

            for step = 1 to n - 1
                int nearestNode = -1
                float nearestDistance = 1000000.0

                for i = 0 to n - 1
                    bool isSelected = array.get(selected, i)
                    float candidateDistance = array.get(minDistance, i)

                    if not isSelected and candidateDistance < nearestDistance
                        nearestDistance := candidateDistance
                        nearestNode := i

                if nearestNode >= 0
                    array.set(selected, nearestNode, true)
                    totalDistance += nearestDistance

                    for j = 0 to n - 1
                        bool isSelected = array.get(selected, j)

                        if not isSelected
                            float similarity = math.abs(array.get(matrix, nearestNode * n + j))
                            float edgeDistance = 1.0 - math.max(0.0, math.min(1.0, similarity))
                            float currentDistance = array.get(minDistance, j)

                            if edgeDistance < currentDistance
                                array.set(minDistance, j, edgeDistance)

    totalDistance


// @function Converts MST distance to compactness.
// @param matrix Similarity matrix.
// @param n Number of nodes.
// @returns Network compactness from approximately 0 to 1.
export mstCompactness(array<float> matrix, int n) =>
    float distanceValue = mstDistance(matrix, n)
    float maximumDistance = math.max(n - 1, 1)
    clamp(1.0 - distanceValue / maximumDistance, 0.0, 1.0)

//====================================================================
// DIRECTED NETWORK ANALYTICS
//====================================================================

// @function Sets one directed edge.
// @param matrix Flat directed adjacency matrix.
// @param fromNode Source node.
// @param toNode Destination node.
// @param n Number of nodes.
// @param weight Directed edge weight.
export setDirectedEdge(array<float> matrix, int fromNode, int toNode, int n, float weight) =>
    int idx = fromNode * n + toNode
    array.set(matrix, idx, weight)


// @function Sum of outgoing positive influence from a node.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @param node Source node.
// @returns Total outbound influence.
export outStrength(array<float> matrix, int n, int node) =>
    float total = 0.0
    if n > 1
        for j = 0 to n - 1
            if j != node
                float w = array.get(matrix, node * n + j)
                total += math.max(w, 0.0)
    total


// @function Sum of incoming positive influence to a node.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @param node Destination node.
// @returns Total inbound influence.
export inStrength(array<float> matrix, int n, int node) =>
    float total = 0.0
    if n > 1
        for i = 0 to n - 1
            if i != node
                float w = array.get(matrix, i * n + node)
                total += math.max(w, 0.0)
    total


// @function Net directional leadership.
// Positive means the node influences others more than it follows them.
// Negative means the node behaves more like a follower.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @param node Node index.
// @returns Outbound minus inbound influence.
export netInfluence(array<float> matrix, int n, int node) =>
    outStrength(matrix, n, node) - inStrength(matrix, n, node)


// @function Normalized directional leadership score.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @param node Node index.
// @returns Score approximately from -1 to +1.
export normalizedLeadership(array<float> matrix, int n, int node) =>
    float outgoing = outStrength(matrix, n, node)
    float incoming = inStrength(matrix, n, node)
    float total = outgoing + incoming
    total > 0.000001 ? (outgoing - incoming) / total : 0.0


// @function Node with the largest net directional influence.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @returns Node index.
export leadingNode(array<float> matrix, int n) =>
    int bestNode = 0
    float bestScore = -1000000.0
    if n > 0
        for i = 0 to n - 1
            float score = netInfluence(matrix, n, i)
            if score > bestScore
                bestScore := score
                bestNode := i
    bestNode


// @function Node with the greatest incoming influence.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @returns Node index.
export followingNode(array<float> matrix, int n) =>
    int bestNode = 0
    float bestScore = -1.0
    if n > 0
        for i = 0 to n - 1
            float score = inStrength(matrix, n, i)
            if score > bestScore
                bestScore := score
                bestNode := i
    bestNode 


// @function Average directed influence in the network.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @returns Mean positive directed edge weight.
export meanDirectedInfluence(array<float> matrix, int n) =>
    float total = 0.0
    int count = 0
    if n > 1
        for i = 0 to n - 1
            for j = 0 to n - 1
                if i != j
                    float w = math.max(array.get(matrix, i * n + j), 0.0)
                    total += w
                    count += 1
    count > 0 ? total / count : 0.0


// @function Concentration of outbound influence.
// High values mean leadership is concentrated in fewer nodes.
// @param matrix Directed matrix.
// @param n Number of nodes.
// @returns Herfindahl-style concentration from 0 to 1.
export leadershipConcentration(array<float> matrix, int n) =>
    float total = 0.0
    if n > 0
        for i = 0 to n - 1
            total += outStrength(matrix, n, i)

    float hhi = 0.0
    if total > 0.000001
        for i = 0 to n - 1
            float share = outStrength(matrix, n, i) / total
            hhi += share * share

    float minimum = n > 0 ? 1.0 / n : 1.0
    float denominator = 1.0 - minimum
    denominator > 0 ? math.max(0.0, math.min(1.0, (hhi - minimum) / denominator)) : 0.0


//====================================================================
// CONNECTED COMPONENTS
//====================================================================

// @function Counts connected components in an undirected threshold graph.
// @param matrix Symmetric adjacency / similarity matrix.
// @param n Number of nodes.
// @param threshold Minimum absolute edge weight required to connect nodes.
// @returns Number of connected components.
export connectedComponentsCount(array<float> matrix, int n, float threshold) =>
    array<bool> visited = array.new_bool(n, false)
    array<int> stack = array.new_int(0)
    int components = 0

    if n > 0
        for startNode = 0 to n - 1
            if not array.get(visited, startNode)
                components += 1
                array.clear(stack)
                array.push(stack, startNode)
                array.set(visited, startNode, true)

                while array.size(stack) > 0
                    int node = array.pop(stack)

                    for neighbor = 0 to n - 1
                        if neighbor != node and not array.get(visited, neighbor)
                            float weight = math.abs(array.get(matrix, node * n + neighbor))

                            if weight >= threshold
                                array.set(visited, neighbor, true)
                                array.push(stack, neighbor)

    components


//====================================================================
// LOCAL CLUSTERING COEFFICIENT
//====================================================================

// @function Computes local clustering coefficient for one node.
// Measures how interconnected the node's neighbors are.
// @param matrix Symmetric similarity matrix.
// @param n Number of nodes.
// @param node Node index.
// @param threshold Minimum absolute edge weight to define a connection.
// @returns Local clustering coefficient from 0 to 1.
export localClusteringCoefficient(array<float> matrix, int n, int node, float threshold) =>
    array<int> neighbors = array.new_int(0)

    if n > 1
        for j = 0 to n - 1
            if j != node
                float weight = math.abs(array.get(matrix, node * n + j))

                if weight >= threshold
                    array.push(neighbors, j)

    int k = array.size(neighbors)
    int links = 0

    if k >= 2
        for a = 0 to k - 2
            int nodeA = array.get(neighbors, a)

            for b = a + 1 to k - 1
                int nodeB = array.get(neighbors, b)
                float neighborWeight = math.abs(array.get(matrix, nodeA * n + nodeB))

                if neighborWeight >= threshold
                    links += 1

    int possibleLinks = k * (k - 1) / 2
    possibleLinks > 0 ? links * 1.0 / possibleLinks : 0.0


// @function Computes mean clustering coefficient across all nodes.
// @param matrix Symmetric similarity matrix.
// @param n Number of nodes.
// @param threshold Minimum absolute edge weight.
// @returns Average clustering coefficient from 0 to 1.
export averageClusteringCoefficient(array<float> matrix, int n, float threshold) =>
    float total = 0.0

    if n > 0
        for i = 0 to n - 1
            total += localClusteringCoefficient(matrix, n, i, threshold)

    n > 0 ? total / n : 0.0


//====================================================================
// SHORTEST PATH UTILITIES
//====================================================================

// @function Converts similarity to graph distance.
// Higher similarity becomes shorter distance.
// @param similarity Edge similarity, typically from 0 to 1 in magnitude.
// @returns Distance from 0 to 1.
export similarityDistance(float similarity) =>
    1.0 - clamp(math.abs(similarity), 0.0, 1.0)


// @function Dijkstra shortest-path distance between two nodes.
// Uses distance = 1 - abs(similarity).
// @param matrix Weighted matrix.
// @param n Number of nodes.
// @param source Start node.
// @param target End node.
// @returns Shortest path distance.
export shortestPathDistance(array<float> matrix, int n, int source, int target) =>
    array<float> distances = array.new_float(n, 1000000.0)
    array<bool> visited = array.new_bool(n, false)

    if source >= 0 and source < n
        array.set(distances, source, 0.0)

    if n > 0
        for step = 0 to n - 1
            int current = -1
            float bestDistance = 1000000.0

            for i = 0 to n - 1
                if not array.get(visited, i)
                    float candidate = array.get(distances, i)

                    if candidate < bestDistance
                        bestDistance := candidate
                        current := i

            if current >= 0
                array.set(visited, current, true)

                for neighbor = 0 to n - 1
                    if neighbor != current and not array.get(visited, neighbor)
                        float similarity = array.get(matrix, current * n + neighbor)
                        float edgeDistance = 1.0 - clamp(math.abs(similarity), 0.0, 1.0)
                        float alternate = bestDistance + edgeDistance
                        float oldDistance = array.get(distances, neighbor)

                        if alternate < oldDistance
                            array.set(distances, neighbor, alternate)

    target >= 0 and target < n ? array.get(distances, target) : na


// @function Average shortest-path distance across all node pairs.
// @param matrix Weighted matrix.
// @param n Number of nodes.
// @returns Mean shortest path distance.
export averagePathLength(array<float> matrix, int n) =>
    float total = 0.0
    int count = 0

    if n > 1
        for i = 0 to n - 2
            for j = i + 1 to n - 1
                float distanceValue = shortestPathDistance(matrix, n, i, j)

                if not na(distanceValue) and distanceValue < 999999.0
                    total += distanceValue
                    count += 1

    count > 0 ? total / count : 0.0


//====================================================================
// EIGENVECTOR CENTRALITY APPROXIMATION
//====================================================================

// @function Approximate eigenvector centrality for one node using power iteration.
// @param matrix Weighted matrix.
// @param n Number of nodes.
// @param node Node index.
// @param iterations Number of power iterations.
// @returns Approximate normalized centrality from 0 to 1.
export eigenvectorCentrality(array<float> matrix, int n, int node, int iterations = 12) =>
    array<float> vector = array.new_float(n, n > 0 ? 1.0 / math.sqrt(n) : 0.0)
    array<float> nextVector = array.new_float(n, 0.0)

    if n > 0
        for iter = 0 to iterations - 1
            float norm = 0.0

            for i = 0 to n - 1
                float value = 0.0

                for j = 0 to n - 1
                    if i != j
                        float weight = math.abs(array.get(matrix, i * n + j))
                        value += weight * array.get(vector, j)

                array.set(nextVector, i, value)
                norm += value * value

            norm := math.sqrt(norm)

            if norm > 0.000001
                for i = 0 to n - 1
                    array.set(vector, i, array.get(nextVector, i) / norm)
            else
                for i = 0 to n - 1
                    array.set(vector, i, 0.0)

    float maxValue = 0.0

    if n > 0
        for i = 0 to n - 1
            maxValue := math.max(maxValue, math.abs(array.get(vector, i)))

    float result = node >= 0 and node < n ? math.abs(array.get(vector, node)) : 0.0
    maxValue > 0.000001 ? result / maxValue : 0.0


// @function Returns node with highest eigenvector centrality.
// @param matrix Weighted matrix.
// @param n Number of nodes.
// @param iterations Number of power iterations.
// @returns Node index.
export eigenvectorLeader(array<float> matrix, int n, int iterations = 12) =>
    int bestNode = 0
    float bestValue = -1.0

    if n > 0
        for i = 0 to n - 1
            float value = eigenvectorCentrality(matrix, n, i, iterations)

            if value > bestValue
                bestValue := value
                bestNode := i

    bestNode


//====================================================================
// NODE RANKING HELPERS
//====================================================================

// @function Cross-sectional percentile rank for a node's strength.
// @param matrix Weighted matrix.
// @param n Number of nodes.
// @param node Node index.
// @returns Percentile rank from 0 to 100.
export nodeStrengthPercentile(array<float> matrix, int n, int node) =>
    float target = nodeStrength(matrix, n, node)
    int belowOrEqual = 0

    if n > 0
        for i = 0 to n - 1
            float value = nodeStrength(matrix, n, i)

            if value <= target
                belowOrEqual += 1

    n > 0 ? 100.0 * belowOrEqual / n : 0.0


// @function Returns the rank position of a node by strength.
// Rank 1 means strongest.
// @param matrix Weighted matrix.
// @param n Number of nodes.
// @param node Node index.
// @returns One-based rank.
export nodeStrengthRank(array<float> matrix, int n, int node) =>
    float target = nodeStrength(matrix, n, node)
    int rank = 1

    if n > 0
        for i = 0 to n - 1
            if i != node
                float value = nodeStrength(matrix, n, i)

                if value > target
                    rank += 1

    rank


//====================================================================
// NETWORK COHESION SCORE
//====================================================================

// @function Composite network cohesion score.
// Combines connectivity, density and clustering coefficient.
// @param matrix Symmetric similarity matrix.
// @param n Number of nodes.
// @param threshold Edge threshold.
// @returns Composite cohesion from 0 to 1.
export networkCohesion(array<float> matrix, int n, float threshold) =>
    float connectivityValue = meanAbsoluteConnectivity(matrix, n)
    float densityValue = density(matrix, n, threshold)
    float clusteringValue = averageClusteringCoefficient(matrix, n, threshold)
    clamp((connectivityValue + densityValue + clusteringValue) / 3.0, 0.0, 1.0)
````
