//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Resources                                                        |
//+------------------------------------------------------------------+
#resource "opencl_program.cl" as string OCLprogram
//---
#define TYPE                          double
#define MATRIX                        matrix<TYPE>
#define VECTOR                        vector<TYPE>
#define LOCAL_SIZE                    256
const string ExtType=StringFormat("#define TYPE %s\r\n"
                                  "#define TYPE4 %s4\r\n"
                                  "#define LOCAL_SIZE %d\r\n",
                                   typename(TYPE),typename(TYPE),LOCAL_SIZE);
#define cl_program                    ExtType+OCLprogram
//---
#define defLossSmoothFactor            1000
#define defLearningRate                (TYPE)3.0e-4
#define defBeta1                       (TYPE)0.9
#define defBeta2                       (TYPE)0.999
#define defLambdaL1                    (TYPE)0
#define defLambdaL2                    (TYPE)0
//+------------------------------------------------------------------+
//| Constants                                                        |
//+------------------------------------------------------------------+
#define Defines
#define defNeuronNet                0x8000
#define defArrayLayers              0x8001
#define defBuffer                   0x8002
#define defActivation               0x8003
#define defLayerDescription         0x8004
#define defNeuronBase               0x8010
#define defNeuronConv               0x8011
#define defNeuronProof              0x8012
#define defNeuronLSTM               0x8013
#define defNeuronAttention          0x8014
#define defNeuronMHAttention        0x8015
#define defNeuronGPT                0x8016
#define defNeuronDropout            0x8017
#define defNeuronBatchNorm          0x8018
//---
#define defFileName                 StringFormat("%s_%s_%s.nns",MQLInfoString(MQL_PROGRAM_NAME),_Symbol,StringSubstr(EnumToString(_Period),7))
//+------------------------------------------------------------------+
//| OpenCL kernels                                                   |
//+------------------------------------------------------------------+
#define def_k_PerceptronFeedForward    0
#define def_k_LineActivation           1
#define def_k_SigmoidActivation        2
#define def_k_SigmoidDerivative        3
#define def_k_TANHActivation           4
#define def_k_TANHDerivative           5
#define def_k_LReLuActivation          6
#define def_k_LReLuDerivative          7
#define def_k_SoftMAXActivation        8
#define def_k_SoftMAXDerivative        9
#define def_k_SwishActivation          10
#define def_k_SwishDerivative          11
#define def_k_CalcOutputGradient       12
#define def_k_CalcHiddenGradient       13
#define def_k_CalcDeltaWeights         14
#define def_k_SGDUpdate                15
#define def_k_MomentumUpdate           16
#define def_k_AdaGradUpdate            17
#define def_k_RMSPropUpdate            18
#define def_k_AdaDeltaUpdate           19
#define def_k_AdamUpdate               20
#define def_k_ProofFeedForward         21
#define def_k_ProofHiddenGradients     22
#define def_k_ConvolutionFeedForward   23
#define def_k_ConvolutionHiddenGradients  24
#define def_k_ConvolutionDeltaWeights  25
#define def_k_LSTMFeedForward          26
#define def_k_LSTMHiddenGradients      27
#define def_k_AttentionFeedForward     28
#define def_k_AttentionScoreGradients  29
#define def_k_AttentionHiddenGradients 30
#define def_k_Sum                      31
#define def_k_LayerNormalize           32
#define def_k_LayerNormalizeGradient   33
#define def_k_GPTFeedForward           34
#define def_k_GPTScoreGradients        35
#define def_k_GPTHiddenGradients       36
#define def_k_BatchNormFeedForward     37
#define def_k_BatchNormCalcHiddenGradient 38
#define def_k_BatchNormCalcDeltaWeights   39
#define def_k_MaskMult                 40
#define def_k_Split                    41
#define def_k_Concatenate              42
//+------------------------------------------------------------------+
//| OpenCL parameters                                                |
//+------------------------------------------------------------------+
//--- perceptron feed-forward pass
#define def_pff_inputs                 0
#define def_pff_weights                1
#define def_pff_outputs                2
#define def_pff_inputs_total           3
//--- define the error gradient of the results layer
#define def_outgr_target               0
#define def_outgr_outputs              1
#define def_outgr_gradients            2
#define def_outgr_loss_function        3
//--- define the error gradient of the hidden layer
#define def_hidgr_gradient_inputs      0
#define def_hidgr_weights              1
#define def_hidgr_gradients            2
#define def_hidgr_outputs_total        3
//--- define the error gradient at the weight matrix level
#define def_delt_inputs                0
#define def_delt_delta_weights         1
#define def_delt_gradients             2
//--- optimize parameters using stochastic gradient descent
#define def_sgd_delta_weights          0
#define def_sgd_weights                1
#define def_sgd_total                  2
#define def_sgd_batch_size             3
#define def_sgd_learningRate           4
#define def_sgd_Lambda1                5
#define def_sgd_Lambda2                6
//--- optimize parameters using momentum method
#define def_moment_delta_weights       0
#define def_moment_weights             1
#define def_moment_momentum            2
#define def_moment_total               3
#define def_moment_batch_size          4
#define def_moment_learningRate        5
#define def_moment_beta                6
#define def_moment_Lambda1             7
#define def_moment_Lambda2             8
//--- optimize parameters using the AdaGrad method
#define def_adagrad_delta_weights      0
#define def_adagrad_weights            1
#define def_adagrad_momentum           2
#define def_adagrad_total              3
#define def_adagrad_batch_size         4
#define def_adagrad_learningRate       5
#define def_adagrad_Lambda1            6
#define def_adagrad_Lambda2            7
//--- optimize parameters using the RMSProp method
#define def_rms_delta_weights          0
#define def_rms_weights                1
#define def_rms_momentum               2
#define def_rms_total                  3
#define def_rms_batch_size             4
#define def_rms_learningRate           5
#define def_rms_beta                   6
#define def_rms_Lambda1                7
#define def_rms_Lambda2                8
//--- optimize parameters using the AdaDelta method
#define def_adadelt_delta_weights      0
#define def_adadelt_weights            1
#define def_adadelt_momentumW          2
#define def_adadelt_momentumG          3
#define def_adadelt_total              4
#define def_adadelt_batch_size         5
#define def_adadelt_beta1              6
#define def_adadelt_beta2              7
#define def_adadelt_Lambda1            8
#define def_adadelt_Lambda2            9
//--- optimize parameters using the Adam method
#define def_adam_delta_weights         0
#define def_adam_weights               1
#define def_adam_momentumM             2
#define def_adam_momentumV             3
#define def_adam_total                 4
#define def_adam_batch_size            5
#define def_adam_learningRate          6
#define def_adam_beta1                 7
#define def_adam_beta2                 8
#define def_adam_Lambda1               9
#define def_adam_Lambda2               10
//--- feed-forward of the pooling layer
#define def_prff_inputs                0
#define def_prff_outputs               1
#define def_prff_inputs_total          2
#define def_prff_input_neurons         3
#define def_prff_window                4
#define def_prff_step                  5
#define def_prff_activation            6
//--- gradient propagation through the pooling layer
#define def_prhgr_inputs               0
#define def_prhgr_gradient_inputs      1
#define def_prhgr_outputs              2
#define def_prhgr_gradients            3
#define def_prhgr_inputs_total         4
#define def_prhgr_outputs_total        5
#define def_prhgr_window               6
#define def_prhgr_step                 7
#define def_prhgr_neurons              8
#define def_prhgr_activation           9
//--- feed-forward of the convolutional layer
#define def_cff_inputs                 0
#define def_cff_weights                1
#define def_cff_outputs                2
#define def_cff_inputs_total           3
#define def_cff_window                 4
#define def_cff_step                   5
#define def_cff_window_out             6
#define def_cff_transposed_out         7
//--- gradient propagation through the convolutional layer
#define def_convhgr_gradient_inputs    0
#define def_convhgr_weights            1
#define def_convhgr_gradients          2
#define def_convhgr_window             3
#define def_convhgr_step               4
#define def_convhgr_window_out         5
#define def_convhgr_neurons            6
#define def_convhgr_transposed_out     7
//--- gradient propagation to the weight matrix of the convolutional layer
#define def_convdelt_inputs            0
#define def_convdelt_delta_weights     1
#define def_convdelt_gradients         2
#define def_convdelt_inputs_total      3
#define def_convdelt_step              4
#define def_convdelt_neurons           5
#define def_convdelt_transposed_out    6
//--- LSTM block feed-forward pass
#define def_lstmff_forgetgate          0
#define def_lstmff_inputgate           1
#define def_lstmff_outputgate          2
#define def_lstmff_newcontent          3
#define def_lstmff_memory              4
#define def_lstmff_hiddenstate         5
#define def_lstmff_outputs_total       6
//--- gradient propagation through the LSTM block
#define def_lstmhgr_outputs            0
#define def_lstmhgr_gradients          1
#define def_lstmhgr_inputgate          2
#define def_lstmhgr_outputgate         3
#define def_lstmhgr_newcontent         4
#define def_lstmhgr_memory             5
#define def_lstmhgr_fg_gradients       6
#define def_lstmhgr_ig_gradients       7
#define def_lstmhgr_og_gradients       8
#define def_lstmhgr_nc_gradients       9
#define def_lstmhgr_outputs_total      10
//--- Attention block feed-forward pass
#define def_attff_querys               0
#define def_attff_keys                 1
#define def_attff_scores               2
#define def_attff_values               3
#define def_attff_outputs              4
#define def_attff_window               5
#define def_attff_key_size             6
#define def_attff_mask                 7
//--- define gradient at the matrix of dependence coefficients in the attention block
#define def_attscr_scores              0
#define def_attscr_scores_grad         1
#define def_attscr_values              2
#define def_attscr_values_grad         3
#define def_attscr_outputs_grad        4
#define def_attscr_scores_temp         5
#define def_attscr_window              6
//--- gradient propagation through the Attention block
#define def_atthgr_querys              0
#define def_atthgr_querys_grad         1
#define def_atthgr_keys                2
#define def_atthgr_keys_grad           3
#define def_atthgr_scores_grad         4
#define def_atthgr_key_size            5
//--- GPT feed-forward
#define def_gptff_querys               0
#define def_gptff_keys                 1
#define def_gptff_scores               2
#define def_gptff_values               3
#define def_gptff_outputs              4
#define def_gptff_key_size             5
#define def_gptff_units                6
#define def_gptff_current              7
//--- define gradient at the matrix of dependence coefficients in GPT
#define def_gptscr_scores              0
#define def_gptscr_scores_grad         1
#define def_gptscr_values              2
#define def_gptscr_values_grad         3
#define def_gptscr_outputs_grad        4
#define def_gptscr_scores_temp         5
#define def_gptscr_window              6
#define def_gptscr_units               7
#define def_gptscr_current             8
//--- gradient propagation through GPT
#define def_gpthgr_querys              0
#define def_gpthgr_querys_grad         1
#define def_gpthgr_keys                2
#define def_gpthgr_scores_grad         3
#define def_gpthgr_key_size            4
#define def_gpthgr_units               5
#define def_gpthgr_current             6
//--- batch normalization feed-forward
#define def_bnff_inputs                0
#define def_bnff_options               1
#define def_bnff_weights               2
#define def_bnff_outputs               3
#define def_bnff_batch                 4
#define def_bnff_total                 5
//--- gradient propagation through the batch normalization layer
#define def_bnhgr_options              0
#define def_bnhgr_gradient             1
#define def_bnhgr_inputs               2
#define def_bnhgr_gradient_inputs      3
#define def_bnhgr_weights              4
#define def_bnhgr_batch                5
#define def_bnhgr_total                6
//--- gradient propagation to optimizable parameters in batch normalization
#define def_bndelt_options             0
#define def_bndelt_delta_weights       1
#define def_bndelt_gradient            2
//--- data masking
#define def_mask_inputs                0
#define def_mask_mask                  1
#define def_mask_outputs               2
#define def_mask_total                 3
//--- sum of vectors 
#define def_sum_inputs1                0
#define def_sum_inputs2                1
#define def_sum_outputs                2
//--- vector normalization
#define def_layernorm_inputs           0
#define def_layernorm_outputs          1
#define def_layernorm_std              2
#define def_layernorm_vector_size      3
#define def_layernorm_std_shift        4
//--- vector normalization gradient
#define def_layernormgr_outputs        0
#define def_layernormgr_out_grad       1
#define def_layernormgr_inp_grad       2
#define def_layernormgr_std            3
#define def_layernormgr_vector_size    4
#define def_layernormgr_std_shift      5
//--- activation functions
#define def_activ_inputs               0
#define def_activ_outputs              1
#define def_activ_param_a              2
#define def_activ_param_b              3
//--- adjust the gradient to the derivative of the activation function
#define def_deactgr_outputs            0
#define def_deactgr_gradients          1
#define def_deactgr_deact_gradient     2
#define def_deactgr_act_param_a        3
#define def_deactgr_act_param_b        4
//--- SoftMax
#define def_softmax_input              0
#define def_softmax_output             1
#define def_softmax_total              2
//--- Split
#define def_split_source               0
#define def_split_target1              1
#define def_split_target2              2
#define def_split_total_source         3
#define def_split_total_target1        4
#define def_split_total_target2        5
//--- Concatenate
#define def_concat_source1             0
#define def_concat_source2             1
#define def_concat_target              2
#define def_concat_total_source1       3
#define def_concat_total_sourse2       4
#define def_concat_total_target        5
//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
//--- activation functions of the pooling layer
enum ENUM_PROOF
  {
   AF_MAX_POOLING,
   AF_AVERAGE_POOLING
  };
//--- optimization methods
enum ENUM_OPTIMIZATION
  {
   None = -1,
   SGD,
   MOMENTUM,
   AdaGrad,
   RMSProp,
   AdaDelta,
   Adam
  };
//+------------------------------------------------------------------+