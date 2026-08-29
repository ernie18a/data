<!-- tradingview-pine-id: PUB;ec6ae4fb57c84798a3735559fa62badc -->
<!-- tradingviewscripts-format: 1 -->
# Neural Network Showcase | Alien_Algorithms

Source: https://www.tradingview.com/script/lxhedC8E-Machine-Learning-using-Neural-Networks-Educational/

## Description

The script provided is a comprehensive illustration of how to implement and execute a simplistic Neural Network (NN) on TradingView using PineScript. 

It encompasses the entire workflow from data input, weight initialization, implicit neuron calculation, feedforward computation, backpropagation for weight adjustments, generating predictions, to visualizing the Mean Squared Error (MSE) Loss Curve for monitoring the training phase. 

In the visual example above, you can see that the prediction is not aligned with the actual value. This is intentional for demonstrative purposes, and by incrementing the Epochs or Learning Rate, you will see these two values converge as the accuracy increases.

Hyperparameters:
Learning Rate, Epochs, and the choice between Simple Backpropagation and a verbose version are declared as script inputs, allowing users to tailor the training process.

Initialization:
Random initialization of weight matrices (w1, w2) is performed to ensure asymmetry, promoting effective gradient updates. A seed is added for reproducibility.

Utility Functions:
Functions for matrix randomization, sigmoid activation, MSE loss calculation, data normalization, and standardization are defined to streamline the computation process.

Neural Network Computation:
The feedforward function computes the hidden and output layer values given the input.
Two variants of the backpropagation function are provided for weight adjustment, with one offering a more verbose step-by-step computation of gradients.

A wrapper train_nn function iterates through epochs, performing feedforward, loss computation, and backpropagation in each epoch while logging and collecting loss values.

Training Invocation:
The input data is prepared by normalizing it to a value between 0 and 1 using the maximum standardized value, and the training process is invoked only on the last confirmed bar to preserve computational resources.

Output Forecasting and Visualization:
Post training, the NN's output (predicted price) is computed, standardized and visualized alongside the actual price on the chart.

The MSE loss between the predicted and actual prices is visualized, providing insight into the prediction accuracy.

Optionally, the MSE Loss Curve is plotted on the chart, illustrating the loss trajectory through epochs, assisting in understanding the training performance.

Customizable Visualization:
Various inputs control visualization aspects like Chart Scaling, Chart Horizontal Offset, and Chart Vertical Offset, allowing users to adapt the visualization to their preference.

-------------------------------------------------------

The following is this Neural Network structure, consisting of one hidden layer, with two hidden neurons. 

[image]https://www.tradingview.com/x/8J3OORDq/[/image]

Through understanding the steps outlined in my code, one should be able to scale the NN in any way they like, such as changing the input / output data and layers to fit their strategy ideas. 

Additionally, one could forgo the backpropagation function, and load their own trained weights into the w1 and w2 matrices, to have this code run purely for inference.

-------------------------------------------------------

While this demonstration does create a “prediction”, it is on historical data. The purpose here is educational, rather than providing a ready tool for non-programmer consumers. 

Normally in Machine Learning projects, the training process would be split into two segments, the Training and the Validation parts. For the purpose of conveying the core concept in a concise and non-repetitive way, I have foregone the Validation part. However, it is merely the application of your trained network on new data (feedforward), and monitoring the loss curve. 

Essentially, checking the accuracy on “unseen” data, while training it on “seen” data.

-------------------------------------------------------

I hope that this code will help developers create interesting machine learning applications within the Tradingview ecosystem.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
//@version=5
indicator("Neural Network Showcase | Alien_Algorithms", overlay=true, shorttitle="Neural Showcase | Alien_Algorithms")

lr = input.float(title='Learning Rate', defval=0.1, minval=0.00001)
epochs = input.int(title='Epochs', defval=60, minval=10, maxval=1000)
use_simple_backprop = input(defval=false, title='Simple Backpropagation')

plot_loss_curve = input(true, 'Plot Loss Curve', group='Statistics')
chart_scaling = input.int(title='Chart Scaling Factor', defval=1, minval=1, group = 'Statistics')
horizontal_offset = input.int(title='Chart Horizontal Offset', defval = 100, group='Statistics')
vertical_offset = input.int(title='Chart Vertical Offset (percentage)', defval = -2, group='Statistics') 
vertical_offset_pct = 1 + (vertical_offset / 100)

// Begin logging the maximum price, to be used in normalization
var max_scale = 0.0
max_scale := high > max_scale ? high : max_scale

// Initialize weight matrices at random for better feature distribution
var w1 = matrix.new<float>(2, 2, 0.0)
var w2 = matrix.new<float>(1, 2, 0.0)


// Function to fill each element of a matrix with random values, while maintaining reproducibility with a seed. 
// This is needed because matrix.new() can only set the same value for the entire matrix. 
fillMatrixRandomly(matrix, rows, cols) =>
    seed = 1337  // Any fixed number as a seed will do
    for i = 0 to rows - 1
        for j = 0 to cols - 1
            // The seed is altered for each matrix element to ensure different values
            // while still being repeatable on every run
            matrix.set(matrix, i, j, math.random(0, 1, seed + i + j * rows))

// Fill w1 and w2 with random values
// It is important that the weights are not initialized with the same values, to induce asymmetry during gradient updates.
// This allows the network to utilize all the weights effectively
if barstate.isfirst
    fillMatrixRandomly(w1, 2, 2)
    fillMatrixRandomly(w2, 1, 2)

// Sigmoid activation function
sigmoid(x) =>
    1 / (1 + math.exp(-x))

// Mean Squared Error Loss function
mse_loss(predicted, actual) =>
    math.pow(predicted - actual, 2)

// Normalize the data between 0 and 1
normalize(data) =>
    data / max_scale

// Revert the data back to the original form
standardize(data) =>
    data * max_scale

// Feed forward through the neural network
// This process passes the input data through the network, and obtains an output
feedforward(input) =>
    hidden_out = array.new_float(0)

    // Push through the first layer
    for i = 0 to 1
        sum = 0.0
        for j = 0 to 1
            sum := sum + w1.get(i, j) * array.get(input, j)
        array.push(hidden_out, sigmoid(sum))

    // Push through the second layer
    output = 0.0
    for i = 0 to 1
        output := output + w2.get(0, i) * array.get(hidden_out, i)
    output := sigmoid(output)
    [output, hidden_out]

// Backpropagation observes the difference in actual and predicted values (obtained from the feedforward), and adjusts the weights using a gradient to lower the error (loss).
backpropagation_simple(input, actual_output, predicted_output, hidden_out) => 

    // Update weights of the second layer
    for i = 0 to 1
        w2.set(0, i, w2.get(0, i) - lr * 2 * (predicted_output - actual_output) * array.get(hidden_out, i))

    // Update weights of the first layer
    for i = 0 to 1
        for j = 0 to 1
            w1.set(i, j, w1.get(i, j) - lr * 2 * (predicted_output - actual_output) * w2.get(0, i) * array.get(input, j))

backpropagation_verbose(input, actual_output, predicted_output, hidden_out) =>
    // Calculate the derivative of the loss with respect to the output (MSE loss)
    float d_loss_d_output = 2 * (predicted_output - actual_output)
    
    // Update weights of the second layer
    for i = 0 to 1
        float hidden_val = array.get(hidden_out, i)
        float d_loss_d_w2 = d_loss_d_output * hidden_val
        w2.set(0, i, w2.get(0, i) - lr * d_loss_d_w2)
    
    // Update weights of the first layer
    for i = 0 to 1
        for j = 0 to 1
            float input_val = array.get(input, j)
            float w2_val = w2.get(0, i)
            float hidden_val = array.get(hidden_out, i)
            float sigmoid_derivative = hidden_val * (1 - hidden_val)
            float d_loss_d_w1 = d_loss_d_output * w2_val * sigmoid_derivative * input_val
            w1.set(i, j, w1.get(i, j) - lr * d_loss_d_w1)


// A wrapper function that trains the neural network with the set parameters (Learning Rate, Epochs)
train_nn(input, actual_output) =>
    loss_curve = array.new<float>(0)

    for epoch = 1 to epochs 
        // Predicting
        [predicted_output, hidden_out] = feedforward(input)
        loss = mse_loss(predicted_output, actual_output)
        
        // Metrics
        log.warning("~~~~ Epoch {0} ~~~~", epoch)
        log.info("Loss: {0}", str.tostring(loss))
        array.push(loss_curve, loss)

        // Weight Adjustment (Training)
        if use_simple_backprop
            backpropagation_simple(input, actual_output, predicted_output, hidden_out)
        else
            backpropagation_verbose(input, actual_output, predicted_output, hidden_out)
    
    loss_curve



// Define input and output variables that the network will use.
float[] input = array.new_float(0)
array.push(input, normalize(close[1]))
array.push(input, normalize(close[2]))
actual_output = normalize(close)

// Perform training only on the last confirmed bar to save resources
float predicted_output = na
if barstate.islastconfirmedhistory
    // Training updates all the weights and returns a loss curve containing the loss for each epoch in an array, which can then be visualized.
    loss_curve = train_nn(input, actual_output)

    // Get neural network output
    [predicted_output_normalized, _] = feedforward(input)
    predicted_output := standardize(predicted_output_normalized)


    log.error(str.tostring(w1))
    log.error(str.tostring(w2))
    // ~~~~~~~~~~~~~ Plot the neural network output ~~~~~~~~~~~~~
    label.new(bar_index+40, predicted_output, text = 'Predicted Output', style = label.style_label_lower_left, color=color.purple, textcolor = color.white, tooltip = 'The price which the neural network predicted')
    line.new(bar_index, predicted_output, bar_index+40, predicted_output, color=color.purple, width=4)

    label.new(bar_index+40, standardize(actual_output), text = 'Actual Output',style = label.style_label_lower_left, color=color.green, textcolor = color.black, tooltip = 'The price which the neural network aims to predict')
    line.new(bar_index, standardize(actual_output), bar_index+40, standardize(actual_output), color=color.green, width=4)

    mid = math.abs(standardize(actual_output) - predicted_output)  / 2
    mid := predicted_output > standardize(actual_output) ? predicted_output - mid : predicted_output + mid

    label.new(bar_index+10, mid, text = 'MSE Loss: '+str.tostring(array.get(loss_curve,epochs-1)), color=color.rgb(195, 195, 195), style=label.style_label_left, textcolor = color.black, tooltip = 'The rate of error between the prediction and actual value')
    line.new(bar_index+10, predicted_output, bar_index+10, standardize(actual_output), color=color.rgb(177, 177, 177), style=line.style_dashed, width=1)
    
    if plot_loss_curve
        size = array.size(loss_curve)
        float max_loss = array.max(loss_curve)
        float min_loss = array.min(loss_curve)
        float loss_range = max_loss - min_loss

        float chart_range = (high - low) / chart_scaling
        float scaling_factor = chart_range / loss_range

        var points = array.new<chart.point>()
        for i = 0 to size - 1
            float normalized_loss = (array.get(loss_curve, i) - min_loss) / loss_range  // Normalize to [0, 1]
            float scaled_loss = normalized_loss * scaling_factor  // Scale to chart range
            float shifted_loss = scaled_loss + (close * vertical_offset_pct)  // Shift to match chart values
            point = chart.point.new(time+i+horizontal_offset, bar_index+i+horizontal_offset, shifted_loss)
            points.push(point)

        float first_loss = (array.get(loss_curve, 0) - min_loss) / loss_range * scaling_factor + (close * vertical_offset_pct)
        float last_loss = (array.get(loss_curve, size-1) - min_loss) / loss_range * scaling_factor + (close * vertical_offset_pct)

        label.new(bar_index+horizontal_offset+size, last_loss - 0.01 * scaling_factor, text = 'Loss Curve', style = label.style_label_upper_left, color=color.rgb(87, 87, 87), textcolor = color.rgb(255, 255, 255), tooltip='The MSE Loss (y-axis) plotted over the epoch iterations (x-axis)')
        box.new(bar_index+horizontal_offset, first_loss, bar_index+horizontal_offset+size, last_loss - 0.01 * scaling_factor, bgcolor = color.rgb(120, 123, 134, 81),border_width = 3)
        polyline.new(points, curved=true, line_color=color.rgb(194, 208, 0), line_width = 1)


// With the introduction of NeuraLib Library to TradingView (https://www.tradingview.com/script/GewgOj30-NeuraLib-A-Native-AI-and-Deep-Learning-Runtime/),
// we can now replicate the above architecture in the following way:


// ~~~ [Import NeuraLib (Make sure to use the latest version)]
// import Alien_Algorithms/NeuraLib/1 as nl

// ~~~ [Settings and other Init Variables / Helper Functions] ~~~

// ~~~ [Model Declaration]
// if barstate.isfirst
//     nl.CompileConfig cfg = nl.compileConfig()
//     cfg := cfg.loss(nl.LossKind.mse).metric(nl.MetricKind.mae).optimizer(nl.sgd(learningRate)).withTrainingGate(true).historyLength(epochs)
//     model := nl.sequential("neural_showcase_nn").input(array.from(2), "lagged_close")
//     for layer = 1 to hiddenLayers
//         model := model.dense(hiddenUnits, nl.ActivationKind.sigmoid, "hidden_" + str.tostring(layer))
//     model := model.dense(1, nl.ActivationKind.sigmoid, "output").build(nl.rng(seed)).compile(cfg)

// ~~~ [Training and Inference Logic]
// if barstate.islastconfirmedhistory
//     nl.Tensor x = nl.vector(array.from(normalize(close[1]), normalize(close[2])), "x")
//     nl.Tensor y = nl.vector(array.from(normalize(close)), "y")
//     for epoch = 1 to epochs
//         model := model.trainOnBatch(x, y)
//     predictedPrice := model.predict(x).get1d(0) * maxScale
//     trainLoss := model.trainStats.lastLoss
````
