// CREDIT TO ROCKETFPU - used a benchmark here

module MulAddRecFNToRaw_preMul(
  input  [1:0]  io_op,
  input  [32:0] io_a,
  input  [32:0] io_b,
  input  [32:0] io_c,
  output [23:0] io_mulAddA,
  output [23:0] io_mulAddB,
  output [47:0] io_mulAddC,
  output        io_toPostMul_isSigNaNAny,
  output        io_toPostMul_isNaNAOrB,
  output        io_toPostMul_isInfA,
  output        io_toPostMul_isZeroA,
  output        io_toPostMul_isInfB,
  output        io_toPostMul_isZeroB,
  output        io_toPostMul_signProd,
  output        io_toPostMul_isNaNC,
  output        io_toPostMul_isInfC,
  output        io_toPostMul_isZeroC,
  output [9:0]  io_toPostMul_sExpSum,
  output        io_toPostMul_doSubMags,
  output        io_toPostMul_CIsDominant,
  output [4:0]  io_toPostMul_CDom_CAlignDist,
  output [25:0] io_toPostMul_highAlignedSigC,
  output        io_toPostMul_bit0AlignedSigC
);
  wire [8:0] rawA_exp = io_a[31:23]; // @[rawFloatFromRecFN.scala 51:21]
  wire  rawA_isZero = rawA_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  wire  rawA_isSpecial = rawA_exp[8:7] == 2'h3; // @[rawFloatFromRecFN.scala 53:53]
  wire  rawA__isNaN = rawA_isSpecial & rawA_exp[6]; // @[rawFloatFromRecFN.scala 56:33]
  wire  rawA__sign = io_a[32]; // @[rawFloatFromRecFN.scala 59:25]
  wire [9:0] rawA__sExp = {1'b0,$signed(rawA_exp)}; // @[rawFloatFromRecFN.scala 60:27]
  wire  _rawA_out_sig_T = ~rawA_isZero; // @[rawFloatFromRecFN.scala 61:35]
  wire [24:0] rawA__sig = {1'h0,_rawA_out_sig_T,io_a[22:0]}; // @[rawFloatFromRecFN.scala 61:44]
  wire [8:0] rawB_exp = io_b[31:23]; // @[rawFloatFromRecFN.scala 51:21]
  wire  rawB_isZero = rawB_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  wire  rawB_isSpecial = rawB_exp[8:7] == 2'h3; // @[rawFloatFromRecFN.scala 53:53]
  wire  rawB__isNaN = rawB_isSpecial & rawB_exp[6]; // @[rawFloatFromRecFN.scala 56:33]
  wire  rawB__sign = io_b[32]; // @[rawFloatFromRecFN.scala 59:25]
  wire [9:0] rawB__sExp = {1'b0,$signed(rawB_exp)}; // @[rawFloatFromRecFN.scala 60:27]
  wire  _rawB_out_sig_T = ~rawB_isZero; // @[rawFloatFromRecFN.scala 61:35]
  wire [24:0] rawB__sig = {1'h0,_rawB_out_sig_T,io_b[22:0]}; // @[rawFloatFromRecFN.scala 61:44]
  wire [8:0] rawC_exp = io_c[31:23]; // @[rawFloatFromRecFN.scala 51:21]
  wire  rawC_isZero = rawC_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  wire  rawC_isSpecial = rawC_exp[8:7] == 2'h3; // @[rawFloatFromRecFN.scala 53:53]
  wire  rawC__isNaN = rawC_isSpecial & rawC_exp[6]; // @[rawFloatFromRecFN.scala 56:33]
  wire  rawC__sign = io_c[32]; // @[rawFloatFromRecFN.scala 59:25]
  wire [9:0] rawC__sExp = {1'b0,$signed(rawC_exp)}; // @[rawFloatFromRecFN.scala 60:27]
  wire  _rawC_out_sig_T = ~rawC_isZero; // @[rawFloatFromRecFN.scala 61:35]
  wire [24:0] rawC__sig = {1'h0,_rawC_out_sig_T,io_c[22:0]}; // @[rawFloatFromRecFN.scala 61:44]
  wire  signProd = rawA__sign ^ rawB__sign ^ io_op[1]; // @[MulAddRecFN.scala 96:42]
  wire [10:0] _sExpAlignedProd_T = $signed(rawA__sExp) + $signed(rawB__sExp); // @[MulAddRecFN.scala 99:19]
  wire [10:0] sExpAlignedProd = $signed(_sExpAlignedProd_T) - 11'she5; // @[MulAddRecFN.scala 99:32]
  wire  doSubMags = signProd ^ rawC__sign ^ io_op[0]; // @[MulAddRecFN.scala 101:42]
  wire [10:0] _GEN_0 = {{1{rawC__sExp[9]}},rawC__sExp}; // @[MulAddRecFN.scala 105:42]
  wire [10:0] sNatCAlignDist = $signed(sExpAlignedProd) - $signed(_GEN_0); // @[MulAddRecFN.scala 105:42]
  wire [9:0] posNatCAlignDist = sNatCAlignDist[9:0]; // @[MulAddRecFN.scala 106:42]
  wire  isMinCAlign = rawA_isZero | rawB_isZero | $signed(sNatCAlignDist) < 11'sh0; // @[MulAddRecFN.scala 107:50]
  wire  CIsDominant = _rawC_out_sig_T & (isMinCAlign | posNatCAlignDist <= 10'h18); // @[MulAddRecFN.scala 109:23]
  wire [6:0] _CAlignDist_T_2 = posNatCAlignDist < 10'h4a ? posNatCAlignDist[6:0] : 7'h4a; // @[MulAddRecFN.scala 113:16]
  wire [6:0] CAlignDist = isMinCAlign ? 7'h0 : _CAlignDist_T_2; // @[MulAddRecFN.scala 111:12]
  wire [24:0] _mainAlignedSigC_T = ~rawC__sig; // @[MulAddRecFN.scala 119:25]
  wire [24:0] _mainAlignedSigC_T_1 = doSubMags ? _mainAlignedSigC_T : rawC__sig; // @[MulAddRecFN.scala 119:13]
  wire [52:0] _mainAlignedSigC_T_3 = doSubMags ? 53'h1fffffffffffff : 53'h0; // @[Bitwise.scala 77:12]
  wire [77:0] _mainAlignedSigC_T_5 = {_mainAlignedSigC_T_1,_mainAlignedSigC_T_3}; // @[MulAddRecFN.scala 119:94]
  wire [77:0] mainAlignedSigC = $signed(_mainAlignedSigC_T_5) >>> CAlignDist; // @[MulAddRecFN.scala 119:100]
  wire [26:0] _reduced4CExtra_T = {rawC__sig, 2'h0}; // @[MulAddRecFN.scala 121:30]
  wire  reduced4CExtra_reducedVec_0 = |_reduced4CExtra_T[3:0]; // @[primitives.scala 120:54]
  wire  reduced4CExtra_reducedVec_1 = |_reduced4CExtra_T[7:4]; // @[primitives.scala 120:54]
  wire  reduced4CExtra_reducedVec_2 = |_reduced4CExtra_T[11:8]; // @[primitives.scala 120:54]
  wire  reduced4CExtra_reducedVec_3 = |_reduced4CExtra_T[15:12]; // @[primitives.scala 120:54]
  wire  reduced4CExtra_reducedVec_4 = |_reduced4CExtra_T[19:16]; // @[primitives.scala 120:54]
  wire  reduced4CExtra_reducedVec_5 = |_reduced4CExtra_T[23:20]; // @[primitives.scala 120:54]
  wire  reduced4CExtra_reducedVec_6 = |_reduced4CExtra_T[26:24]; // @[primitives.scala 123:57]
  wire [6:0] _reduced4CExtra_T_1 = {reduced4CExtra_reducedVec_6,reduced4CExtra_reducedVec_5,reduced4CExtra_reducedVec_4,
    reduced4CExtra_reducedVec_3,reduced4CExtra_reducedVec_2,reduced4CExtra_reducedVec_1,reduced4CExtra_reducedVec_0}; // @[primitives.scala 124:20]
  wire [32:0] reduced4CExtra_shift = 33'sh100000000 >>> CAlignDist[6:2]; // @[primitives.scala 76:56]
  wire [5:0] _reduced4CExtra_T_18 = {reduced4CExtra_shift[14],reduced4CExtra_shift[15],reduced4CExtra_shift[16],
    reduced4CExtra_shift[17],reduced4CExtra_shift[18],reduced4CExtra_shift[19]}; // @[Cat.scala 33:92]
  wire [6:0] _GEN_1 = {{1'd0}, _reduced4CExtra_T_18}; // @[MulAddRecFN.scala 121:68]
  wire [6:0] _reduced4CExtra_T_19 = _reduced4CExtra_T_1 & _GEN_1; // @[MulAddRecFN.scala 121:68]
  wire  reduced4CExtra = |_reduced4CExtra_T_19; // @[MulAddRecFN.scala 129:11]
  wire  _alignedSigC_T_4 = &mainAlignedSigC[2:0] & ~reduced4CExtra; // @[MulAddRecFN.scala 133:44]
  wire  _alignedSigC_T_7 = |mainAlignedSigC[2:0] | reduced4CExtra; // @[MulAddRecFN.scala 134:44]
  wire  _alignedSigC_T_8 = doSubMags ? _alignedSigC_T_4 : _alignedSigC_T_7; // @[MulAddRecFN.scala 132:16]
  wire [74:0] alignedSigC_hi = mainAlignedSigC[77:3]; // @[Cat.scala 33:92]
  wire [75:0] alignedSigC = {alignedSigC_hi,_alignedSigC_T_8}; // @[Cat.scala 33:92]
  wire  _io_toPostMul_isSigNaNAny_T_2 = rawA__isNaN & ~rawA__sig[22]; // @[common.scala 82:46]
  wire  _io_toPostMul_isSigNaNAny_T_5 = rawB__isNaN & ~rawB__sig[22]; // @[common.scala 82:46]
  wire  _io_toPostMul_isSigNaNAny_T_9 = rawC__isNaN & ~rawC__sig[22]; // @[common.scala 82:46]
  wire [10:0] _io_toPostMul_sExpSum_T_2 = $signed(sExpAlignedProd) - 11'sh18; // @[MulAddRecFN.scala 157:53]
  wire [10:0] _io_toPostMul_sExpSum_T_3 = CIsDominant ? $signed({{1{rawC__sExp[9]}},rawC__sExp}) : $signed(
    _io_toPostMul_sExpSum_T_2); // @[MulAddRecFN.scala 157:12]
  assign io_mulAddA = rawA__sig[23:0]; // @[MulAddRecFN.scala 140:16]
  assign io_mulAddB = rawB__sig[23:0]; // @[MulAddRecFN.scala 141:16]
  assign io_mulAddC = alignedSigC[48:1]; // @[MulAddRecFN.scala 142:30]
  assign io_toPostMul_isSigNaNAny = _io_toPostMul_isSigNaNAny_T_2 | _io_toPostMul_isSigNaNAny_T_5 |
    _io_toPostMul_isSigNaNAny_T_9; // @[MulAddRecFN.scala 145:58]
  assign io_toPostMul_isNaNAOrB = rawA__isNaN | rawB__isNaN; // @[MulAddRecFN.scala 147:42]
  assign io_toPostMul_isInfA = rawA_isSpecial & ~rawA_exp[6]; // @[rawFloatFromRecFN.scala 57:33]
  assign io_toPostMul_isZeroA = rawA_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  assign io_toPostMul_isInfB = rawB_isSpecial & ~rawB_exp[6]; // @[rawFloatFromRecFN.scala 57:33]
  assign io_toPostMul_isZeroB = rawB_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  assign io_toPostMul_signProd = rawA__sign ^ rawB__sign ^ io_op[1]; // @[MulAddRecFN.scala 96:42]
  assign io_toPostMul_isNaNC = rawC_isSpecial & rawC_exp[6]; // @[rawFloatFromRecFN.scala 56:33]
  assign io_toPostMul_isInfC = rawC_isSpecial & ~rawC_exp[6]; // @[rawFloatFromRecFN.scala 57:33]
  assign io_toPostMul_isZeroC = rawC_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  assign io_toPostMul_sExpSum = _io_toPostMul_sExpSum_T_3[9:0]; // @[MulAddRecFN.scala 156:28]
  assign io_toPostMul_doSubMags = signProd ^ rawC__sign ^ io_op[0]; // @[MulAddRecFN.scala 101:42]
  assign io_toPostMul_CIsDominant = _rawC_out_sig_T & (isMinCAlign | posNatCAlignDist <= 10'h18); // @[MulAddRecFN.scala 109:23]
  assign io_toPostMul_CDom_CAlignDist = CAlignDist[4:0]; // @[MulAddRecFN.scala 160:47]
  assign io_toPostMul_highAlignedSigC = alignedSigC[74:49]; // @[MulAddRecFN.scala 162:20]
  assign io_toPostMul_bit0AlignedSigC = alignedSigC[0]; // @[MulAddRecFN.scala 163:48]
endmodule
module MulAddRecFNToRaw_postMul(
  input         io_fromPreMul_isSigNaNAny,
  input         io_fromPreMul_isNaNAOrB,
  input         io_fromPreMul_isInfA,
  input         io_fromPreMul_isZeroA,
  input         io_fromPreMul_isInfB,
  input         io_fromPreMul_isZeroB,
  input         io_fromPreMul_signProd,
  input         io_fromPreMul_isNaNC,
  input         io_fromPreMul_isInfC,
  input         io_fromPreMul_isZeroC,
  input  [9:0]  io_fromPreMul_sExpSum,
  input         io_fromPreMul_doSubMags,
  input         io_fromPreMul_CIsDominant,
  input  [4:0]  io_fromPreMul_CDom_CAlignDist,
  input  [25:0] io_fromPreMul_highAlignedSigC,
  input         io_fromPreMul_bit0AlignedSigC,
  input  [48:0] io_mulAddResult,
  input  [2:0]  io_roundingMode,
  output        io_invalidExc,
  output        io_rawOut_isNaN,
  output        io_rawOut_isInf,
  output        io_rawOut_isZero,
  output        io_rawOut_sign,
  output [9:0]  io_rawOut_sExp,
  output [26:0] io_rawOut_sig
);
  wire  roundingMode_min = io_roundingMode == 3'h2; // @[MulAddRecFN.scala 184:45]
  wire  CDom_sign = io_fromPreMul_signProd ^ io_fromPreMul_doSubMags; // @[MulAddRecFN.scala 188:42]
  wire [25:0] _sigSum_T_2 = io_fromPreMul_highAlignedSigC + 26'h1; // @[MulAddRecFN.scala 191:47]
  wire [25:0] _sigSum_T_3 = io_mulAddResult[48] ? _sigSum_T_2 : io_fromPreMul_highAlignedSigC; // @[MulAddRecFN.scala 190:16]
  wire [74:0] sigSum = {_sigSum_T_3,io_mulAddResult[47:0],io_fromPreMul_bit0AlignedSigC}; // @[Cat.scala 33:92]
  wire [1:0] _CDom_sExp_T = {1'b0,$signed(io_fromPreMul_doSubMags)}; // @[MulAddRecFN.scala 201:69]
  wire [9:0] _GEN_0 = {{8{_CDom_sExp_T[1]}},_CDom_sExp_T}; // @[MulAddRecFN.scala 201:43]
  wire [9:0] CDom_sExp = $signed(io_fromPreMul_sExpSum) - $signed(_GEN_0); // @[MulAddRecFN.scala 201:43]
  wire [49:0] _CDom_absSigSum_T_1 = ~sigSum[74:25]; // @[MulAddRecFN.scala 204:13]
  wire [49:0] _CDom_absSigSum_T_5 = {1'h0,io_fromPreMul_highAlignedSigC[25:24],sigSum[72:26]}; // @[MulAddRecFN.scala 207:71]
  wire [49:0] CDom_absSigSum = io_fromPreMul_doSubMags ? _CDom_absSigSum_T_1 : _CDom_absSigSum_T_5; // @[MulAddRecFN.scala 203:12]
  wire [23:0] _CDom_absSigSumExtra_T_1 = ~sigSum[24:1]; // @[MulAddRecFN.scala 213:14]
  wire  _CDom_absSigSumExtra_T_2 = |_CDom_absSigSumExtra_T_1; // @[MulAddRecFN.scala 213:36]
  wire  _CDom_absSigSumExtra_T_4 = |sigSum[25:1]; // @[MulAddRecFN.scala 214:37]
  wire  CDom_absSigSumExtra = io_fromPreMul_doSubMags ? _CDom_absSigSumExtra_T_2 : _CDom_absSigSumExtra_T_4; // @[MulAddRecFN.scala 212:12]
  wire [80:0] _GEN_5 = {{31'd0}, CDom_absSigSum}; // @[MulAddRecFN.scala 217:24]
  wire [80:0] _CDom_mainSig_T = _GEN_5 << io_fromPreMul_CDom_CAlignDist; // @[MulAddRecFN.scala 217:24]
  wire [28:0] CDom_mainSig = _CDom_mainSig_T[49:21]; // @[MulAddRecFN.scala 217:56]
  wire [26:0] _CDom_reduced4SigExtra_T_1 = {CDom_absSigSum[23:0], 3'h0}; // @[MulAddRecFN.scala 220:53]
  wire  CDom_reduced4SigExtra_reducedVec_0 = |_CDom_reduced4SigExtra_T_1[3:0]; // @[primitives.scala 120:54]
  wire  CDom_reduced4SigExtra_reducedVec_1 = |_CDom_reduced4SigExtra_T_1[7:4]; // @[primitives.scala 120:54]
  wire  CDom_reduced4SigExtra_reducedVec_2 = |_CDom_reduced4SigExtra_T_1[11:8]; // @[primitives.scala 120:54]
  wire  CDom_reduced4SigExtra_reducedVec_3 = |_CDom_reduced4SigExtra_T_1[15:12]; // @[primitives.scala 120:54]
  wire  CDom_reduced4SigExtra_reducedVec_4 = |_CDom_reduced4SigExtra_T_1[19:16]; // @[primitives.scala 120:54]
  wire  CDom_reduced4SigExtra_reducedVec_5 = |_CDom_reduced4SigExtra_T_1[23:20]; // @[primitives.scala 120:54]
  wire  CDom_reduced4SigExtra_reducedVec_6 = |_CDom_reduced4SigExtra_T_1[26:24]; // @[primitives.scala 123:57]
  wire [6:0] _CDom_reduced4SigExtra_T_2 = {CDom_reduced4SigExtra_reducedVec_6,CDom_reduced4SigExtra_reducedVec_5,
    CDom_reduced4SigExtra_reducedVec_4,CDom_reduced4SigExtra_reducedVec_3,CDom_reduced4SigExtra_reducedVec_2,
    CDom_reduced4SigExtra_reducedVec_1,CDom_reduced4SigExtra_reducedVec_0}; // @[primitives.scala 124:20]
  wire [2:0] _CDom_reduced4SigExtra_T_4 = ~io_fromPreMul_CDom_CAlignDist[4:2]; // @[primitives.scala 52:21]
  wire [8:0] CDom_reduced4SigExtra_shift = 9'sh100 >>> _CDom_reduced4SigExtra_T_4; // @[primitives.scala 76:56]
  wire [5:0] _CDom_reduced4SigExtra_T_20 = {CDom_reduced4SigExtra_shift[1],CDom_reduced4SigExtra_shift[2],
    CDom_reduced4SigExtra_shift[3],CDom_reduced4SigExtra_shift[4],CDom_reduced4SigExtra_shift[5],
    CDom_reduced4SigExtra_shift[6]}; // @[Cat.scala 33:92]
  wire [6:0] _GEN_1 = {{1'd0}, _CDom_reduced4SigExtra_T_20}; // @[MulAddRecFN.scala 220:72]
  wire [6:0] _CDom_reduced4SigExtra_T_21 = _CDom_reduced4SigExtra_T_2 & _GEN_1; // @[MulAddRecFN.scala 220:72]
  wire  CDom_reduced4SigExtra = |_CDom_reduced4SigExtra_T_21; // @[MulAddRecFN.scala 221:73]
  wire  _CDom_sig_T_4 = |CDom_mainSig[2:0] | CDom_reduced4SigExtra | CDom_absSigSumExtra; // @[MulAddRecFN.scala 224:61]
  wire [26:0] CDom_sig = {CDom_mainSig[28:3],_CDom_sig_T_4}; // @[Cat.scala 33:92]
  wire  notCDom_signSigSum = sigSum[51]; // @[MulAddRecFN.scala 230:36]
  wire [50:0] _notCDom_absSigSum_T_1 = ~sigSum[50:0]; // @[MulAddRecFN.scala 233:13]
  wire [50:0] _GEN_2 = {{50'd0}, io_fromPreMul_doSubMags}; // @[MulAddRecFN.scala 234:41]
  wire [50:0] _notCDom_absSigSum_T_4 = sigSum[50:0] + _GEN_2; // @[MulAddRecFN.scala 234:41]
  wire [50:0] notCDom_absSigSum = notCDom_signSigSum ? _notCDom_absSigSum_T_1 : _notCDom_absSigSum_T_4; // @[MulAddRecFN.scala 232:12]
  wire  notCDom_reduced2AbsSigSum_reducedVec_0 = |notCDom_absSigSum[1:0]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_1 = |notCDom_absSigSum[3:2]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_2 = |notCDom_absSigSum[5:4]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_3 = |notCDom_absSigSum[7:6]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_4 = |notCDom_absSigSum[9:8]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_5 = |notCDom_absSigSum[11:10]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_6 = |notCDom_absSigSum[13:12]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_7 = |notCDom_absSigSum[15:14]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_8 = |notCDom_absSigSum[17:16]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_9 = |notCDom_absSigSum[19:18]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_10 = |notCDom_absSigSum[21:20]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_11 = |notCDom_absSigSum[23:22]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_12 = |notCDom_absSigSum[25:24]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_13 = |notCDom_absSigSum[27:26]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_14 = |notCDom_absSigSum[29:28]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_15 = |notCDom_absSigSum[31:30]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_16 = |notCDom_absSigSum[33:32]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_17 = |notCDom_absSigSum[35:34]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_18 = |notCDom_absSigSum[37:36]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_19 = |notCDom_absSigSum[39:38]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_20 = |notCDom_absSigSum[41:40]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_21 = |notCDom_absSigSum[43:42]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_22 = |notCDom_absSigSum[45:44]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_23 = |notCDom_absSigSum[47:46]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_24 = |notCDom_absSigSum[49:48]; // @[primitives.scala 103:54]
  wire  notCDom_reduced2AbsSigSum_reducedVec_25 = |notCDom_absSigSum[50]; // @[primitives.scala 106:57]
  wire [5:0] notCDom_reduced2AbsSigSum_lo_lo = {notCDom_reduced2AbsSigSum_reducedVec_5,
    notCDom_reduced2AbsSigSum_reducedVec_4,notCDom_reduced2AbsSigSum_reducedVec_3,notCDom_reduced2AbsSigSum_reducedVec_2
    ,notCDom_reduced2AbsSigSum_reducedVec_1,notCDom_reduced2AbsSigSum_reducedVec_0}; // @[primitives.scala 107:20]
  wire [12:0] notCDom_reduced2AbsSigSum_lo = {notCDom_reduced2AbsSigSum_reducedVec_12,
    notCDom_reduced2AbsSigSum_reducedVec_11,notCDom_reduced2AbsSigSum_reducedVec_10,
    notCDom_reduced2AbsSigSum_reducedVec_9,notCDom_reduced2AbsSigSum_reducedVec_8,notCDom_reduced2AbsSigSum_reducedVec_7
    ,notCDom_reduced2AbsSigSum_reducedVec_6,notCDom_reduced2AbsSigSum_lo_lo}; // @[primitives.scala 107:20]
  wire [5:0] notCDom_reduced2AbsSigSum_hi_lo = {notCDom_reduced2AbsSigSum_reducedVec_18,
    notCDom_reduced2AbsSigSum_reducedVec_17,notCDom_reduced2AbsSigSum_reducedVec_16,
    notCDom_reduced2AbsSigSum_reducedVec_15,notCDom_reduced2AbsSigSum_reducedVec_14,
    notCDom_reduced2AbsSigSum_reducedVec_13}; // @[primitives.scala 107:20]
  wire [25:0] notCDom_reduced2AbsSigSum = {notCDom_reduced2AbsSigSum_reducedVec_25,
    notCDom_reduced2AbsSigSum_reducedVec_24,notCDom_reduced2AbsSigSum_reducedVec_23,
    notCDom_reduced2AbsSigSum_reducedVec_22,notCDom_reduced2AbsSigSum_reducedVec_21,
    notCDom_reduced2AbsSigSum_reducedVec_20,notCDom_reduced2AbsSigSum_reducedVec_19,notCDom_reduced2AbsSigSum_hi_lo,
    notCDom_reduced2AbsSigSum_lo}; // @[primitives.scala 107:20]
  wire [4:0] _notCDom_normDistReduced2_T_26 = notCDom_reduced2AbsSigSum[1] ? 5'h18 : 5'h19; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_27 = notCDom_reduced2AbsSigSum[2] ? 5'h17 : _notCDom_normDistReduced2_T_26; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_28 = notCDom_reduced2AbsSigSum[3] ? 5'h16 : _notCDom_normDistReduced2_T_27; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_29 = notCDom_reduced2AbsSigSum[4] ? 5'h15 : _notCDom_normDistReduced2_T_28; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_30 = notCDom_reduced2AbsSigSum[5] ? 5'h14 : _notCDom_normDistReduced2_T_29; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_31 = notCDom_reduced2AbsSigSum[6] ? 5'h13 : _notCDom_normDistReduced2_T_30; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_32 = notCDom_reduced2AbsSigSum[7] ? 5'h12 : _notCDom_normDistReduced2_T_31; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_33 = notCDom_reduced2AbsSigSum[8] ? 5'h11 : _notCDom_normDistReduced2_T_32; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_34 = notCDom_reduced2AbsSigSum[9] ? 5'h10 : _notCDom_normDistReduced2_T_33; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_35 = notCDom_reduced2AbsSigSum[10] ? 5'hf : _notCDom_normDistReduced2_T_34; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_36 = notCDom_reduced2AbsSigSum[11] ? 5'he : _notCDom_normDistReduced2_T_35; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_37 = notCDom_reduced2AbsSigSum[12] ? 5'hd : _notCDom_normDistReduced2_T_36; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_38 = notCDom_reduced2AbsSigSum[13] ? 5'hc : _notCDom_normDistReduced2_T_37; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_39 = notCDom_reduced2AbsSigSum[14] ? 5'hb : _notCDom_normDistReduced2_T_38; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_40 = notCDom_reduced2AbsSigSum[15] ? 5'ha : _notCDom_normDistReduced2_T_39; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_41 = notCDom_reduced2AbsSigSum[16] ? 5'h9 : _notCDom_normDistReduced2_T_40; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_42 = notCDom_reduced2AbsSigSum[17] ? 5'h8 : _notCDom_normDistReduced2_T_41; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_43 = notCDom_reduced2AbsSigSum[18] ? 5'h7 : _notCDom_normDistReduced2_T_42; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_44 = notCDom_reduced2AbsSigSum[19] ? 5'h6 : _notCDom_normDistReduced2_T_43; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_45 = notCDom_reduced2AbsSigSum[20] ? 5'h5 : _notCDom_normDistReduced2_T_44; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_46 = notCDom_reduced2AbsSigSum[21] ? 5'h4 : _notCDom_normDistReduced2_T_45; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_47 = notCDom_reduced2AbsSigSum[22] ? 5'h3 : _notCDom_normDistReduced2_T_46; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_48 = notCDom_reduced2AbsSigSum[23] ? 5'h2 : _notCDom_normDistReduced2_T_47; // @[Mux.scala 47:70]
  wire [4:0] _notCDom_normDistReduced2_T_49 = notCDom_reduced2AbsSigSum[24] ? 5'h1 : _notCDom_normDistReduced2_T_48; // @[Mux.scala 47:70]
  wire [4:0] notCDom_normDistReduced2 = notCDom_reduced2AbsSigSum[25] ? 5'h0 : _notCDom_normDistReduced2_T_49; // @[Mux.scala 47:70]
  wire [5:0] notCDom_nearNormDist = {notCDom_normDistReduced2, 1'h0}; // @[MulAddRecFN.scala 238:56]
  wire [6:0] _notCDom_sExp_T = {1'b0,$signed(notCDom_nearNormDist)}; // @[MulAddRecFN.scala 239:76]
  wire [9:0] _GEN_3 = {{3{_notCDom_sExp_T[6]}},_notCDom_sExp_T}; // @[MulAddRecFN.scala 239:46]
  wire [9:0] notCDom_sExp = $signed(io_fromPreMul_sExpSum) - $signed(_GEN_3); // @[MulAddRecFN.scala 239:46]
  wire [113:0] _GEN_6 = {{63'd0}, notCDom_absSigSum}; // @[MulAddRecFN.scala 241:27]
  wire [113:0] _notCDom_mainSig_T = _GEN_6 << notCDom_nearNormDist; // @[MulAddRecFN.scala 241:27]
  wire [28:0] notCDom_mainSig = _notCDom_mainSig_T[51:23]; // @[MulAddRecFN.scala 241:50]
  wire  notCDom_reduced4SigExtra_reducedVec_0 = |notCDom_reduced2AbsSigSum[1:0]; // @[primitives.scala 103:54]
  wire  notCDom_reduced4SigExtra_reducedVec_1 = |notCDom_reduced2AbsSigSum[3:2]; // @[primitives.scala 103:54]
  wire  notCDom_reduced4SigExtra_reducedVec_2 = |notCDom_reduced2AbsSigSum[5:4]; // @[primitives.scala 103:54]
  wire  notCDom_reduced4SigExtra_reducedVec_3 = |notCDom_reduced2AbsSigSum[7:6]; // @[primitives.scala 103:54]
  wire  notCDom_reduced4SigExtra_reducedVec_4 = |notCDom_reduced2AbsSigSum[9:8]; // @[primitives.scala 103:54]
  wire  notCDom_reduced4SigExtra_reducedVec_5 = |notCDom_reduced2AbsSigSum[11:10]; // @[primitives.scala 103:54]
  wire  notCDom_reduced4SigExtra_reducedVec_6 = |notCDom_reduced2AbsSigSum[12]; // @[primitives.scala 106:57]
  wire [6:0] _notCDom_reduced4SigExtra_T_2 = {notCDom_reduced4SigExtra_reducedVec_6,
    notCDom_reduced4SigExtra_reducedVec_5,notCDom_reduced4SigExtra_reducedVec_4,notCDom_reduced4SigExtra_reducedVec_3,
    notCDom_reduced4SigExtra_reducedVec_2,notCDom_reduced4SigExtra_reducedVec_1,notCDom_reduced4SigExtra_reducedVec_0}; // @[primitives.scala 107:20]
  wire [3:0] _notCDom_reduced4SigExtra_T_4 = ~notCDom_normDistReduced2[4:1]; // @[primitives.scala 52:21]
  wire [16:0] notCDom_reduced4SigExtra_shift = 17'sh10000 >>> _notCDom_reduced4SigExtra_T_4; // @[primitives.scala 76:56]
  wire [5:0] _notCDom_reduced4SigExtra_T_20 = {notCDom_reduced4SigExtra_shift[1],notCDom_reduced4SigExtra_shift[2],
    notCDom_reduced4SigExtra_shift[3],notCDom_reduced4SigExtra_shift[4],notCDom_reduced4SigExtra_shift[5],
    notCDom_reduced4SigExtra_shift[6]}; // @[Cat.scala 33:92]
  wire [6:0] _GEN_4 = {{1'd0}, _notCDom_reduced4SigExtra_T_20}; // @[MulAddRecFN.scala 245:78]
  wire [6:0] _notCDom_reduced4SigExtra_T_21 = _notCDom_reduced4SigExtra_T_2 & _GEN_4; // @[MulAddRecFN.scala 245:78]
  wire  notCDom_reduced4SigExtra = |_notCDom_reduced4SigExtra_T_21; // @[MulAddRecFN.scala 247:11]
  wire  _notCDom_sig_T_3 = |notCDom_mainSig[2:0] | notCDom_reduced4SigExtra; // @[MulAddRecFN.scala 250:39]
  wire [26:0] notCDom_sig = {notCDom_mainSig[28:3],_notCDom_sig_T_3}; // @[Cat.scala 33:92]
  wire  notCDom_completeCancellation = notCDom_sig[26:25] == 2'h0; // @[MulAddRecFN.scala 253:50]
  wire  _notCDom_sign_T = io_fromPreMul_signProd ^ notCDom_signSigSum; // @[MulAddRecFN.scala 257:36]
  wire  notCDom_sign = notCDom_completeCancellation ? roundingMode_min : _notCDom_sign_T; // @[MulAddRecFN.scala 255:12]
  wire  notNaN_isInfProd = io_fromPreMul_isInfA | io_fromPreMul_isInfB; // @[MulAddRecFN.scala 262:49]
  wire  notNaN_isInfOut = notNaN_isInfProd | io_fromPreMul_isInfC; // @[MulAddRecFN.scala 263:44]
  wire  notNaN_addZeros = (io_fromPreMul_isZeroA | io_fromPreMul_isZeroB) & io_fromPreMul_isZeroC; // @[MulAddRecFN.scala 265:58]
  wire  _io_invalidExc_T = io_fromPreMul_isInfA & io_fromPreMul_isZeroB; // @[MulAddRecFN.scala 270:31]
  wire  _io_invalidExc_T_1 = io_fromPreMul_isSigNaNAny | _io_invalidExc_T; // @[MulAddRecFN.scala 269:35]
  wire  _io_invalidExc_T_2 = io_fromPreMul_isZeroA & io_fromPreMul_isInfB; // @[MulAddRecFN.scala 271:32]
  wire  _io_invalidExc_T_3 = _io_invalidExc_T_1 | _io_invalidExc_T_2; // @[MulAddRecFN.scala 270:57]
  wire  _io_invalidExc_T_6 = ~io_fromPreMul_isNaNAOrB & notNaN_isInfProd; // @[MulAddRecFN.scala 272:36]
  wire  _io_invalidExc_T_7 = _io_invalidExc_T_6 & io_fromPreMul_isInfC; // @[MulAddRecFN.scala 273:61]
  wire  _io_invalidExc_T_8 = _io_invalidExc_T_7 & io_fromPreMul_doSubMags; // @[MulAddRecFN.scala 274:35]
  wire  _io_rawOut_isZero_T_1 = ~io_fromPreMul_CIsDominant & notCDom_completeCancellation; // @[MulAddRecFN.scala 281:42]
  wire  _io_rawOut_sign_T_1 = io_fromPreMul_isInfC & CDom_sign; // @[MulAddRecFN.scala 284:31]
  wire  _io_rawOut_sign_T_2 = notNaN_isInfProd & io_fromPreMul_signProd | _io_rawOut_sign_T_1; // @[MulAddRecFN.scala 283:54]
  wire  _io_rawOut_sign_T_5 = notNaN_addZeros & ~roundingMode_min & io_fromPreMul_signProd; // @[MulAddRecFN.scala 285:48]
  wire  _io_rawOut_sign_T_6 = _io_rawOut_sign_T_5 & CDom_sign; // @[MulAddRecFN.scala 286:36]
  wire  _io_rawOut_sign_T_7 = _io_rawOut_sign_T_2 | _io_rawOut_sign_T_6; // @[MulAddRecFN.scala 284:43]
  wire  _io_rawOut_sign_T_9 = io_fromPreMul_signProd | CDom_sign; // @[MulAddRecFN.scala 288:37]
  wire  _io_rawOut_sign_T_10 = notNaN_addZeros & roundingMode_min & _io_rawOut_sign_T_9; // @[MulAddRecFN.scala 287:46]
  wire  _io_rawOut_sign_T_11 = _io_rawOut_sign_T_7 | _io_rawOut_sign_T_10; // @[MulAddRecFN.scala 286:48]
  wire  _io_rawOut_sign_T_15 = io_fromPreMul_CIsDominant ? CDom_sign : notCDom_sign; // @[MulAddRecFN.scala 290:17]
  wire  _io_rawOut_sign_T_16 = ~notNaN_isInfOut & ~notNaN_addZeros & _io_rawOut_sign_T_15; // @[MulAddRecFN.scala 289:49]
  assign io_invalidExc = _io_invalidExc_T_3 | _io_invalidExc_T_8; // @[MulAddRecFN.scala 271:57]
  assign io_rawOut_isNaN = io_fromPreMul_isNaNAOrB | io_fromPreMul_isNaNC; // @[MulAddRecFN.scala 276:48]
  assign io_rawOut_isInf = notNaN_isInfProd | io_fromPreMul_isInfC; // @[MulAddRecFN.scala 263:44]
  assign io_rawOut_isZero = notNaN_addZeros | _io_rawOut_isZero_T_1; // @[MulAddRecFN.scala 280:25]
  assign io_rawOut_sign = _io_rawOut_sign_T_11 | _io_rawOut_sign_T_16; // @[MulAddRecFN.scala 288:50]
  assign io_rawOut_sExp = io_fromPreMul_CIsDominant ? $signed(CDom_sExp) : $signed(notCDom_sExp); // @[MulAddRecFN.scala 291:26]
  assign io_rawOut_sig = io_fromPreMul_CIsDominant ? CDom_sig : notCDom_sig; // @[MulAddRecFN.scala 292:25]
endmodule
module RoundAnyRawFNToRecFN(
  input         io_invalidExc,
  input         io_in_isNaN,
  input         io_in_isInf,
  input         io_in_isZero,
  input         io_in_sign,
  input  [9:0]  io_in_sExp,
  input  [26:0] io_in_sig,
  input  [2:0]  io_roundingMode,
  output [32:0] io_out
);
  wire  roundingMode_near_even = io_roundingMode == 3'h0; // @[RoundAnyRawFNToRecFN.scala 89:53]
  wire  roundingMode_min = io_roundingMode == 3'h2; // @[RoundAnyRawFNToRecFN.scala 91:53]
  wire  roundingMode_max = io_roundingMode == 3'h3; // @[RoundAnyRawFNToRecFN.scala 92:53]
  wire  roundingMode_near_maxMag = io_roundingMode == 3'h4; // @[RoundAnyRawFNToRecFN.scala 93:53]
  wire  roundingMode_odd = io_roundingMode == 3'h6; // @[RoundAnyRawFNToRecFN.scala 94:53]
  wire  roundMagUp = roundingMode_min & io_in_sign | roundingMode_max & ~io_in_sign; // @[RoundAnyRawFNToRecFN.scala 97:42]
  wire  doShiftSigDown1 = io_in_sig[26]; // @[RoundAnyRawFNToRecFN.scala 119:57]
  wire [8:0] _roundMask_T_1 = ~io_in_sExp[8:0]; // @[primitives.scala 52:21]
  wire  roundMask_msb = _roundMask_T_1[8]; // @[primitives.scala 58:25]
  wire [7:0] roundMask_lsbs = _roundMask_T_1[7:0]; // @[primitives.scala 59:26]
  wire  roundMask_msb_1 = roundMask_lsbs[7]; // @[primitives.scala 58:25]
  wire [6:0] roundMask_lsbs_1 = roundMask_lsbs[6:0]; // @[primitives.scala 59:26]
  wire  roundMask_msb_2 = roundMask_lsbs_1[6]; // @[primitives.scala 58:25]
  wire [5:0] roundMask_lsbs_2 = roundMask_lsbs_1[5:0]; // @[primitives.scala 59:26]
  wire [64:0] roundMask_shift = 65'sh10000000000000000 >>> roundMask_lsbs_2; // @[primitives.scala 76:56]
  wire [15:0] _GEN_0 = {{8'd0}, roundMask_shift[57:50]}; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_7 = _GEN_0 & 16'hff; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_9 = {roundMask_shift[49:42], 8'h0}; // @[Bitwise.scala 108:70]
  wire [15:0] _roundMask_T_11 = _roundMask_T_9 & 16'hff00; // @[Bitwise.scala 108:80]
  wire [15:0] _roundMask_T_12 = _roundMask_T_7 | _roundMask_T_11; // @[Bitwise.scala 108:39]
  wire [15:0] _GEN_1 = {{4'd0}, _roundMask_T_12[15:4]}; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_17 = _GEN_1 & 16'hf0f; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_19 = {_roundMask_T_12[11:0], 4'h0}; // @[Bitwise.scala 108:70]
  wire [15:0] _roundMask_T_21 = _roundMask_T_19 & 16'hf0f0; // @[Bitwise.scala 108:80]
  wire [15:0] _roundMask_T_22 = _roundMask_T_17 | _roundMask_T_21; // @[Bitwise.scala 108:39]
  wire [15:0] _GEN_2 = {{2'd0}, _roundMask_T_22[15:2]}; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_27 = _GEN_2 & 16'h3333; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_29 = {_roundMask_T_22[13:0], 2'h0}; // @[Bitwise.scala 108:70]
  wire [15:0] _roundMask_T_31 = _roundMask_T_29 & 16'hcccc; // @[Bitwise.scala 108:80]
  wire [15:0] _roundMask_T_32 = _roundMask_T_27 | _roundMask_T_31; // @[Bitwise.scala 108:39]
  wire [15:0] _GEN_3 = {{1'd0}, _roundMask_T_32[15:1]}; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_37 = _GEN_3 & 16'h5555; // @[Bitwise.scala 108:31]
  wire [15:0] _roundMask_T_39 = {_roundMask_T_32[14:0], 1'h0}; // @[Bitwise.scala 108:70]
  wire [15:0] _roundMask_T_41 = _roundMask_T_39 & 16'haaaa; // @[Bitwise.scala 108:80]
  wire [15:0] _roundMask_T_42 = _roundMask_T_37 | _roundMask_T_41; // @[Bitwise.scala 108:39]
  wire [21:0] _roundMask_T_59 = {_roundMask_T_42,roundMask_shift[58],roundMask_shift[59],roundMask_shift[60],
    roundMask_shift[61],roundMask_shift[62],roundMask_shift[63]}; // @[Cat.scala 33:92]
  wire [21:0] _roundMask_T_60 = ~_roundMask_T_59; // @[primitives.scala 73:32]
  wire [21:0] _roundMask_T_61 = roundMask_msb_2 ? 22'h0 : _roundMask_T_60; // @[primitives.scala 73:21]
  wire [21:0] _roundMask_T_62 = ~_roundMask_T_61; // @[primitives.scala 73:17]
  wire [24:0] _roundMask_T_63 = {_roundMask_T_62,3'h7}; // @[primitives.scala 68:58]
  wire [2:0] _roundMask_T_70 = {roundMask_shift[0],roundMask_shift[1],roundMask_shift[2]}; // @[Cat.scala 33:92]
  wire [2:0] _roundMask_T_71 = roundMask_msb_2 ? _roundMask_T_70 : 3'h0; // @[primitives.scala 62:24]
  wire [24:0] _roundMask_T_72 = roundMask_msb_1 ? _roundMask_T_63 : {{22'd0}, _roundMask_T_71}; // @[primitives.scala 67:24]
  wire [24:0] _roundMask_T_73 = roundMask_msb ? _roundMask_T_72 : 25'h0; // @[primitives.scala 62:24]
  wire [24:0] _GEN_4 = {{24'd0}, doShiftSigDown1}; // @[RoundAnyRawFNToRecFN.scala 158:23]
  wire [24:0] _roundMask_T_74 = _roundMask_T_73 | _GEN_4; // @[RoundAnyRawFNToRecFN.scala 158:23]
  wire [26:0] roundMask = {_roundMask_T_74,2'h3}; // @[RoundAnyRawFNToRecFN.scala 158:42]
  wire [27:0] _shiftedRoundMask_T = {1'h0,_roundMask_T_74,2'h3}; // @[RoundAnyRawFNToRecFN.scala 161:41]
  wire [26:0] shiftedRoundMask = _shiftedRoundMask_T[27:1]; // @[RoundAnyRawFNToRecFN.scala 161:53]
  wire [26:0] _roundPosMask_T = ~shiftedRoundMask; // @[RoundAnyRawFNToRecFN.scala 162:28]
  wire [26:0] roundPosMask = _roundPosMask_T & roundMask; // @[RoundAnyRawFNToRecFN.scala 162:46]
  wire [26:0] _roundPosBit_T = io_in_sig & roundPosMask; // @[RoundAnyRawFNToRecFN.scala 163:40]
  wire  roundPosBit = |_roundPosBit_T; // @[RoundAnyRawFNToRecFN.scala 163:56]
  wire [26:0] _anyRoundExtra_T = io_in_sig & shiftedRoundMask; // @[RoundAnyRawFNToRecFN.scala 164:42]
  wire  anyRoundExtra = |_anyRoundExtra_T; // @[RoundAnyRawFNToRecFN.scala 164:62]
  wire  anyRound = roundPosBit | anyRoundExtra; // @[RoundAnyRawFNToRecFN.scala 165:36]
  wire  _roundIncr_T = roundingMode_near_even | roundingMode_near_maxMag; // @[RoundAnyRawFNToRecFN.scala 168:38]
  wire  _roundIncr_T_1 = (roundingMode_near_even | roundingMode_near_maxMag) & roundPosBit; // @[RoundAnyRawFNToRecFN.scala 168:67]
  wire  _roundIncr_T_2 = roundMagUp & anyRound; // @[RoundAnyRawFNToRecFN.scala 170:29]
  wire  roundIncr = _roundIncr_T_1 | _roundIncr_T_2; // @[RoundAnyRawFNToRecFN.scala 169:31]
  wire [26:0] _roundedSig_T = io_in_sig | roundMask; // @[RoundAnyRawFNToRecFN.scala 173:32]
  wire [25:0] _roundedSig_T_2 = _roundedSig_T[26:2] + 25'h1; // @[RoundAnyRawFNToRecFN.scala 173:49]
  wire  _roundedSig_T_4 = ~anyRoundExtra; // @[RoundAnyRawFNToRecFN.scala 175:30]
  wire [25:0] _roundedSig_T_7 = roundingMode_near_even & roundPosBit & _roundedSig_T_4 ? roundMask[26:1] : 26'h0; // @[RoundAnyRawFNToRecFN.scala 174:25]
  wire [25:0] _roundedSig_T_8 = ~_roundedSig_T_7; // @[RoundAnyRawFNToRecFN.scala 174:21]
  wire [25:0] _roundedSig_T_9 = _roundedSig_T_2 & _roundedSig_T_8; // @[RoundAnyRawFNToRecFN.scala 173:57]
  wire [26:0] _roundedSig_T_10 = ~roundMask; // @[RoundAnyRawFNToRecFN.scala 179:32]
  wire [26:0] _roundedSig_T_11 = io_in_sig & _roundedSig_T_10; // @[RoundAnyRawFNToRecFN.scala 179:30]
  wire [25:0] _roundedSig_T_15 = roundingMode_odd & anyRound ? roundPosMask[26:1] : 26'h0; // @[RoundAnyRawFNToRecFN.scala 180:24]
  wire [25:0] _GEN_5 = {{1'd0}, _roundedSig_T_11[26:2]}; // @[RoundAnyRawFNToRecFN.scala 179:47]
  wire [25:0] _roundedSig_T_16 = _GEN_5 | _roundedSig_T_15; // @[RoundAnyRawFNToRecFN.scala 179:47]
  wire [25:0] roundedSig = roundIncr ? _roundedSig_T_9 : _roundedSig_T_16; // @[RoundAnyRawFNToRecFN.scala 172:16]
  wire [2:0] _sRoundedExp_T_1 = {1'b0,$signed(roundedSig[25:24])}; // @[RoundAnyRawFNToRecFN.scala 184:76]
  wire [9:0] _GEN_6 = {{7{_sRoundedExp_T_1[2]}},_sRoundedExp_T_1}; // @[RoundAnyRawFNToRecFN.scala 184:40]
  wire [10:0] sRoundedExp = $signed(io_in_sExp) + $signed(_GEN_6); // @[RoundAnyRawFNToRecFN.scala 184:40]
  wire [8:0] common_expOut = sRoundedExp[8:0]; // @[RoundAnyRawFNToRecFN.scala 186:37]
  wire [22:0] common_fractOut = doShiftSigDown1 ? roundedSig[23:1] : roundedSig[22:0]; // @[RoundAnyRawFNToRecFN.scala 188:16]
  wire [3:0] _common_overflow_T = sRoundedExp[10:7]; // @[RoundAnyRawFNToRecFN.scala 195:30]
  wire  common_overflow = $signed(_common_overflow_T) >= 4'sh3; // @[RoundAnyRawFNToRecFN.scala 195:50]
  wire  common_totalUnderflow = $signed(sRoundedExp) < 11'sh6b; // @[RoundAnyRawFNToRecFN.scala 199:31]
  wire  isNaNOut = io_invalidExc | io_in_isNaN; // @[RoundAnyRawFNToRecFN.scala 234:34]
  wire  commonCase = ~isNaNOut & ~io_in_isInf & ~io_in_isZero; // @[RoundAnyRawFNToRecFN.scala 236:61]
  wire  overflow = commonCase & common_overflow; // @[RoundAnyRawFNToRecFN.scala 237:32]
  wire  overflow_roundMagUp = _roundIncr_T | roundMagUp; // @[RoundAnyRawFNToRecFN.scala 242:60]
  wire  pegMinNonzeroMagOut = commonCase & common_totalUnderflow & (roundMagUp | roundingMode_odd); // @[RoundAnyRawFNToRecFN.scala 244:45]
  wire  pegMaxFiniteMagOut = overflow & ~overflow_roundMagUp; // @[RoundAnyRawFNToRecFN.scala 245:39]
  wire  notNaN_isInfOut = io_in_isInf | overflow & overflow_roundMagUp; // @[RoundAnyRawFNToRecFN.scala 247:32]
  wire  signOut = isNaNOut ? 1'h0 : io_in_sign; // @[RoundAnyRawFNToRecFN.scala 249:22]
  wire [8:0] _expOut_T_1 = io_in_isZero | common_totalUnderflow ? 9'h1c0 : 9'h0; // @[RoundAnyRawFNToRecFN.scala 252:18]
  wire [8:0] _expOut_T_2 = ~_expOut_T_1; // @[RoundAnyRawFNToRecFN.scala 252:14]
  wire [8:0] _expOut_T_3 = common_expOut & _expOut_T_2; // @[RoundAnyRawFNToRecFN.scala 251:24]
  wire [8:0] _expOut_T_5 = pegMinNonzeroMagOut ? 9'h194 : 9'h0; // @[RoundAnyRawFNToRecFN.scala 256:18]
  wire [8:0] _expOut_T_6 = ~_expOut_T_5; // @[RoundAnyRawFNToRecFN.scala 256:14]
  wire [8:0] _expOut_T_7 = _expOut_T_3 & _expOut_T_6; // @[RoundAnyRawFNToRecFN.scala 255:17]
  wire [8:0] _expOut_T_8 = pegMaxFiniteMagOut ? 9'h80 : 9'h0; // @[RoundAnyRawFNToRecFN.scala 260:18]
  wire [8:0] _expOut_T_9 = ~_expOut_T_8; // @[RoundAnyRawFNToRecFN.scala 260:14]
  wire [8:0] _expOut_T_10 = _expOut_T_7 & _expOut_T_9; // @[RoundAnyRawFNToRecFN.scala 259:17]
  wire [8:0] _expOut_T_11 = notNaN_isInfOut ? 9'h40 : 9'h0; // @[RoundAnyRawFNToRecFN.scala 264:18]
  wire [8:0] _expOut_T_12 = ~_expOut_T_11; // @[RoundAnyRawFNToRecFN.scala 264:14]
  wire [8:0] _expOut_T_13 = _expOut_T_10 & _expOut_T_12; // @[RoundAnyRawFNToRecFN.scala 263:17]
  wire [8:0] _expOut_T_14 = pegMinNonzeroMagOut ? 9'h6b : 9'h0; // @[RoundAnyRawFNToRecFN.scala 268:16]
  wire [8:0] _expOut_T_15 = _expOut_T_13 | _expOut_T_14; // @[RoundAnyRawFNToRecFN.scala 267:18]
  wire [8:0] _expOut_T_16 = pegMaxFiniteMagOut ? 9'h17f : 9'h0; // @[RoundAnyRawFNToRecFN.scala 272:16]
  wire [8:0] _expOut_T_17 = _expOut_T_15 | _expOut_T_16; // @[RoundAnyRawFNToRecFN.scala 271:15]
  wire [8:0] _expOut_T_18 = notNaN_isInfOut ? 9'h180 : 9'h0; // @[RoundAnyRawFNToRecFN.scala 276:16]
  wire [8:0] _expOut_T_19 = _expOut_T_17 | _expOut_T_18; // @[RoundAnyRawFNToRecFN.scala 275:15]
  wire [8:0] _expOut_T_20 = isNaNOut ? 9'h1c0 : 9'h0; // @[RoundAnyRawFNToRecFN.scala 277:16]
  wire [8:0] expOut = _expOut_T_19 | _expOut_T_20; // @[RoundAnyRawFNToRecFN.scala 276:73]
  wire [22:0] _fractOut_T_2 = isNaNOut ? 23'h400000 : 23'h0; // @[RoundAnyRawFNToRecFN.scala 280:16]
  wire [22:0] _fractOut_T_3 = isNaNOut | io_in_isZero | common_totalUnderflow ? _fractOut_T_2 : common_fractOut; // @[RoundAnyRawFNToRecFN.scala 279:12]
  wire [22:0] _fractOut_T_5 = pegMaxFiniteMagOut ? 23'h7fffff : 23'h0; // @[Bitwise.scala 77:12]
  wire [22:0] fractOut = _fractOut_T_3 | _fractOut_T_5; // @[RoundAnyRawFNToRecFN.scala 282:11]
  wire [9:0] _io_out_T = {signOut,expOut}; // @[RoundAnyRawFNToRecFN.scala 285:23]
  assign io_out = {_io_out_T,fractOut}; // @[RoundAnyRawFNToRecFN.scala 285:33]
endmodule
module RoundRawFNToRecFN(
  input         io_invalidExc,
  input         io_in_isNaN,
  input         io_in_isInf,
  input         io_in_isZero,
  input         io_in_sign,
  input  [9:0]  io_in_sExp,
  input  [26:0] io_in_sig,
  input  [2:0]  io_roundingMode,
  output [32:0] io_out
);
  wire  roundAnyRawFNToRecFN_io_invalidExc; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire  roundAnyRawFNToRecFN_io_in_isNaN; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire  roundAnyRawFNToRecFN_io_in_isInf; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire  roundAnyRawFNToRecFN_io_in_isZero; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire  roundAnyRawFNToRecFN_io_in_sign; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire [9:0] roundAnyRawFNToRecFN_io_in_sExp; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire [26:0] roundAnyRawFNToRecFN_io_in_sig; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire [2:0] roundAnyRawFNToRecFN_io_roundingMode; // @[RoundAnyRawFNToRecFN.scala 308:15]
  wire [32:0] roundAnyRawFNToRecFN_io_out; // @[RoundAnyRawFNToRecFN.scala 308:15]
  RoundAnyRawFNToRecFN roundAnyRawFNToRecFN ( // @[RoundAnyRawFNToRecFN.scala 308:15]
    .io_invalidExc(roundAnyRawFNToRecFN_io_invalidExc),
    .io_in_isNaN(roundAnyRawFNToRecFN_io_in_isNaN),
    .io_in_isInf(roundAnyRawFNToRecFN_io_in_isInf),
    .io_in_isZero(roundAnyRawFNToRecFN_io_in_isZero),
    .io_in_sign(roundAnyRawFNToRecFN_io_in_sign),
    .io_in_sExp(roundAnyRawFNToRecFN_io_in_sExp),
    .io_in_sig(roundAnyRawFNToRecFN_io_in_sig),
    .io_roundingMode(roundAnyRawFNToRecFN_io_roundingMode),
    .io_out(roundAnyRawFNToRecFN_io_out)
  );
  assign io_out = roundAnyRawFNToRecFN_io_out; // @[RoundAnyRawFNToRecFN.scala 316:23]
  assign roundAnyRawFNToRecFN_io_invalidExc = io_invalidExc; // @[RoundAnyRawFNToRecFN.scala 311:44]
  assign roundAnyRawFNToRecFN_io_in_isNaN = io_in_isNaN; // @[RoundAnyRawFNToRecFN.scala 313:44]
  assign roundAnyRawFNToRecFN_io_in_isInf = io_in_isInf; // @[RoundAnyRawFNToRecFN.scala 313:44]
  assign roundAnyRawFNToRecFN_io_in_isZero = io_in_isZero; // @[RoundAnyRawFNToRecFN.scala 313:44]
  assign roundAnyRawFNToRecFN_io_in_sign = io_in_sign; // @[RoundAnyRawFNToRecFN.scala 313:44]
  assign roundAnyRawFNToRecFN_io_in_sExp = io_in_sExp; // @[RoundAnyRawFNToRecFN.scala 313:44]
  assign roundAnyRawFNToRecFN_io_in_sig = io_in_sig; // @[RoundAnyRawFNToRecFN.scala 313:44]
  assign roundAnyRawFNToRecFN_io_roundingMode = io_roundingMode; // @[RoundAnyRawFNToRecFN.scala 314:44]
endmodule
module MulAddRecFN(
  input  [1:0]  io_op,
  input  [32:0] io_a,
  input  [32:0] io_b,
  input  [32:0] io_c,
  input  [2:0]  io_roundingMode,
  output [32:0] io_out
);
  wire [1:0] mulAddRecFNToRaw_preMul_io_op; // @[MulAddRecFN.scala 314:15]
  wire [32:0] mulAddRecFNToRaw_preMul_io_a; // @[MulAddRecFN.scala 314:15]
  wire [32:0] mulAddRecFNToRaw_preMul_io_b; // @[MulAddRecFN.scala 314:15]
  wire [32:0] mulAddRecFNToRaw_preMul_io_c; // @[MulAddRecFN.scala 314:15]
  wire [23:0] mulAddRecFNToRaw_preMul_io_mulAddA; // @[MulAddRecFN.scala 314:15]
  wire [23:0] mulAddRecFNToRaw_preMul_io_mulAddB; // @[MulAddRecFN.scala 314:15]
  wire [47:0] mulAddRecFNToRaw_preMul_io_mulAddC; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isSigNaNAny; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isNaNAOrB; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isInfA; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isZeroA; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isInfB; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isZeroB; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_signProd; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isNaNC; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isInfC; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_isZeroC; // @[MulAddRecFN.scala 314:15]
  wire [9:0] mulAddRecFNToRaw_preMul_io_toPostMul_sExpSum; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_doSubMags; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_CIsDominant; // @[MulAddRecFN.scala 314:15]
  wire [4:0] mulAddRecFNToRaw_preMul_io_toPostMul_CDom_CAlignDist; // @[MulAddRecFN.scala 314:15]
  wire [25:0] mulAddRecFNToRaw_preMul_io_toPostMul_highAlignedSigC; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_preMul_io_toPostMul_bit0AlignedSigC; // @[MulAddRecFN.scala 314:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isSigNaNAny; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isNaNAOrB; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isInfA; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroA; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isInfB; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroB; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_signProd; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isNaNC; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isInfC; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroC; // @[MulAddRecFN.scala 316:15]
  wire [9:0] mulAddRecFNToRaw_postMul_io_fromPreMul_sExpSum; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_doSubMags; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_CIsDominant; // @[MulAddRecFN.scala 316:15]
  wire [4:0] mulAddRecFNToRaw_postMul_io_fromPreMul_CDom_CAlignDist; // @[MulAddRecFN.scala 316:15]
  wire [25:0] mulAddRecFNToRaw_postMul_io_fromPreMul_highAlignedSigC; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_fromPreMul_bit0AlignedSigC; // @[MulAddRecFN.scala 316:15]
  wire [48:0] mulAddRecFNToRaw_postMul_io_mulAddResult; // @[MulAddRecFN.scala 316:15]
  wire [2:0] mulAddRecFNToRaw_postMul_io_roundingMode; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_invalidExc; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_rawOut_isNaN; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_rawOut_isInf; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_rawOut_isZero; // @[MulAddRecFN.scala 316:15]
  wire  mulAddRecFNToRaw_postMul_io_rawOut_sign; // @[MulAddRecFN.scala 316:15]
  wire [9:0] mulAddRecFNToRaw_postMul_io_rawOut_sExp; // @[MulAddRecFN.scala 316:15]
  wire [26:0] mulAddRecFNToRaw_postMul_io_rawOut_sig; // @[MulAddRecFN.scala 316:15]
  wire  roundRawFNToRecFN_io_invalidExc; // @[MulAddRecFN.scala 336:15]
  wire  roundRawFNToRecFN_io_in_isNaN; // @[MulAddRecFN.scala 336:15]
  wire  roundRawFNToRecFN_io_in_isInf; // @[MulAddRecFN.scala 336:15]
  wire  roundRawFNToRecFN_io_in_isZero; // @[MulAddRecFN.scala 336:15]
  wire  roundRawFNToRecFN_io_in_sign; // @[MulAddRecFN.scala 336:15]
  wire [9:0] roundRawFNToRecFN_io_in_sExp; // @[MulAddRecFN.scala 336:15]
  wire [26:0] roundRawFNToRecFN_io_in_sig; // @[MulAddRecFN.scala 336:15]
  wire [2:0] roundRawFNToRecFN_io_roundingMode; // @[MulAddRecFN.scala 336:15]
  wire [32:0] roundRawFNToRecFN_io_out; // @[MulAddRecFN.scala 336:15]
  wire [47:0] _mulAddResult_T = mulAddRecFNToRaw_preMul_io_mulAddA * mulAddRecFNToRaw_preMul_io_mulAddB; // @[MulAddRecFN.scala 324:45]
  MulAddRecFNToRaw_preMul mulAddRecFNToRaw_preMul ( // @[MulAddRecFN.scala 314:15]
    .io_op(mulAddRecFNToRaw_preMul_io_op),
    .io_a(mulAddRecFNToRaw_preMul_io_a),
    .io_b(mulAddRecFNToRaw_preMul_io_b),
    .io_c(mulAddRecFNToRaw_preMul_io_c),
    .io_mulAddA(mulAddRecFNToRaw_preMul_io_mulAddA),
    .io_mulAddB(mulAddRecFNToRaw_preMul_io_mulAddB),
    .io_mulAddC(mulAddRecFNToRaw_preMul_io_mulAddC),
    .io_toPostMul_isSigNaNAny(mulAddRecFNToRaw_preMul_io_toPostMul_isSigNaNAny),
    .io_toPostMul_isNaNAOrB(mulAddRecFNToRaw_preMul_io_toPostMul_isNaNAOrB),
    .io_toPostMul_isInfA(mulAddRecFNToRaw_preMul_io_toPostMul_isInfA),
    .io_toPostMul_isZeroA(mulAddRecFNToRaw_preMul_io_toPostMul_isZeroA),
    .io_toPostMul_isInfB(mulAddRecFNToRaw_preMul_io_toPostMul_isInfB),
    .io_toPostMul_isZeroB(mulAddRecFNToRaw_preMul_io_toPostMul_isZeroB),
    .io_toPostMul_signProd(mulAddRecFNToRaw_preMul_io_toPostMul_signProd),
    .io_toPostMul_isNaNC(mulAddRecFNToRaw_preMul_io_toPostMul_isNaNC),
    .io_toPostMul_isInfC(mulAddRecFNToRaw_preMul_io_toPostMul_isInfC),
    .io_toPostMul_isZeroC(mulAddRecFNToRaw_preMul_io_toPostMul_isZeroC),
    .io_toPostMul_sExpSum(mulAddRecFNToRaw_preMul_io_toPostMul_sExpSum),
    .io_toPostMul_doSubMags(mulAddRecFNToRaw_preMul_io_toPostMul_doSubMags),
    .io_toPostMul_CIsDominant(mulAddRecFNToRaw_preMul_io_toPostMul_CIsDominant),
    .io_toPostMul_CDom_CAlignDist(mulAddRecFNToRaw_preMul_io_toPostMul_CDom_CAlignDist),
    .io_toPostMul_highAlignedSigC(mulAddRecFNToRaw_preMul_io_toPostMul_highAlignedSigC),
    .io_toPostMul_bit0AlignedSigC(mulAddRecFNToRaw_preMul_io_toPostMul_bit0AlignedSigC)
  );
  MulAddRecFNToRaw_postMul mulAddRecFNToRaw_postMul ( // @[MulAddRecFN.scala 316:15]
    .io_fromPreMul_isSigNaNAny(mulAddRecFNToRaw_postMul_io_fromPreMul_isSigNaNAny),
    .io_fromPreMul_isNaNAOrB(mulAddRecFNToRaw_postMul_io_fromPreMul_isNaNAOrB),
    .io_fromPreMul_isInfA(mulAddRecFNToRaw_postMul_io_fromPreMul_isInfA),
    .io_fromPreMul_isZeroA(mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroA),
    .io_fromPreMul_isInfB(mulAddRecFNToRaw_postMul_io_fromPreMul_isInfB),
    .io_fromPreMul_isZeroB(mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroB),
    .io_fromPreMul_signProd(mulAddRecFNToRaw_postMul_io_fromPreMul_signProd),
    .io_fromPreMul_isNaNC(mulAddRecFNToRaw_postMul_io_fromPreMul_isNaNC),
    .io_fromPreMul_isInfC(mulAddRecFNToRaw_postMul_io_fromPreMul_isInfC),
    .io_fromPreMul_isZeroC(mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroC),
    .io_fromPreMul_sExpSum(mulAddRecFNToRaw_postMul_io_fromPreMul_sExpSum),
    .io_fromPreMul_doSubMags(mulAddRecFNToRaw_postMul_io_fromPreMul_doSubMags),
    .io_fromPreMul_CIsDominant(mulAddRecFNToRaw_postMul_io_fromPreMul_CIsDominant),
    .io_fromPreMul_CDom_CAlignDist(mulAddRecFNToRaw_postMul_io_fromPreMul_CDom_CAlignDist),
    .io_fromPreMul_highAlignedSigC(mulAddRecFNToRaw_postMul_io_fromPreMul_highAlignedSigC),
    .io_fromPreMul_bit0AlignedSigC(mulAddRecFNToRaw_postMul_io_fromPreMul_bit0AlignedSigC),
    .io_mulAddResult(mulAddRecFNToRaw_postMul_io_mulAddResult),
    .io_roundingMode(mulAddRecFNToRaw_postMul_io_roundingMode),
    .io_invalidExc(mulAddRecFNToRaw_postMul_io_invalidExc),
    .io_rawOut_isNaN(mulAddRecFNToRaw_postMul_io_rawOut_isNaN),
    .io_rawOut_isInf(mulAddRecFNToRaw_postMul_io_rawOut_isInf),
    .io_rawOut_isZero(mulAddRecFNToRaw_postMul_io_rawOut_isZero),
    .io_rawOut_sign(mulAddRecFNToRaw_postMul_io_rawOut_sign),
    .io_rawOut_sExp(mulAddRecFNToRaw_postMul_io_rawOut_sExp),
    .io_rawOut_sig(mulAddRecFNToRaw_postMul_io_rawOut_sig)
  );
  RoundRawFNToRecFN roundRawFNToRecFN ( // @[MulAddRecFN.scala 336:15]
    .io_invalidExc(roundRawFNToRecFN_io_invalidExc),
    .io_in_isNaN(roundRawFNToRecFN_io_in_isNaN),
    .io_in_isInf(roundRawFNToRecFN_io_in_isInf),
    .io_in_isZero(roundRawFNToRecFN_io_in_isZero),
    .io_in_sign(roundRawFNToRecFN_io_in_sign),
    .io_in_sExp(roundRawFNToRecFN_io_in_sExp),
    .io_in_sig(roundRawFNToRecFN_io_in_sig),
    .io_roundingMode(roundRawFNToRecFN_io_roundingMode),
    .io_out(roundRawFNToRecFN_io_out)
  );
  assign io_out = roundRawFNToRecFN_io_out; // @[MulAddRecFN.scala 342:23]
  assign mulAddRecFNToRaw_preMul_io_op = io_op; // @[MulAddRecFN.scala 318:35]
  assign mulAddRecFNToRaw_preMul_io_a = io_a; // @[MulAddRecFN.scala 319:35]
  assign mulAddRecFNToRaw_preMul_io_b = io_b; // @[MulAddRecFN.scala 320:35]
  assign mulAddRecFNToRaw_preMul_io_c = io_c; // @[MulAddRecFN.scala 321:35]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isSigNaNAny = mulAddRecFNToRaw_preMul_io_toPostMul_isSigNaNAny; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isNaNAOrB = mulAddRecFNToRaw_preMul_io_toPostMul_isNaNAOrB; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isInfA = mulAddRecFNToRaw_preMul_io_toPostMul_isInfA; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroA = mulAddRecFNToRaw_preMul_io_toPostMul_isZeroA; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isInfB = mulAddRecFNToRaw_preMul_io_toPostMul_isInfB; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroB = mulAddRecFNToRaw_preMul_io_toPostMul_isZeroB; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_signProd = mulAddRecFNToRaw_preMul_io_toPostMul_signProd; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isNaNC = mulAddRecFNToRaw_preMul_io_toPostMul_isNaNC; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isInfC = mulAddRecFNToRaw_preMul_io_toPostMul_isInfC; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_isZeroC = mulAddRecFNToRaw_preMul_io_toPostMul_isZeroC; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_sExpSum = mulAddRecFNToRaw_preMul_io_toPostMul_sExpSum; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_doSubMags = mulAddRecFNToRaw_preMul_io_toPostMul_doSubMags; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_CIsDominant = mulAddRecFNToRaw_preMul_io_toPostMul_CIsDominant; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_CDom_CAlignDist = mulAddRecFNToRaw_preMul_io_toPostMul_CDom_CAlignDist; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_highAlignedSigC = mulAddRecFNToRaw_preMul_io_toPostMul_highAlignedSigC; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_fromPreMul_bit0AlignedSigC = mulAddRecFNToRaw_preMul_io_toPostMul_bit0AlignedSigC; // @[MulAddRecFN.scala 328:44]
  assign mulAddRecFNToRaw_postMul_io_mulAddResult = _mulAddResult_T + mulAddRecFNToRaw_preMul_io_mulAddC; // @[MulAddRecFN.scala 325:50]
  assign mulAddRecFNToRaw_postMul_io_roundingMode = io_roundingMode; // @[MulAddRecFN.scala 331:46]
  assign roundRawFNToRecFN_io_invalidExc = mulAddRecFNToRaw_postMul_io_invalidExc; // @[MulAddRecFN.scala 337:39]
  assign roundRawFNToRecFN_io_in_isNaN = mulAddRecFNToRaw_postMul_io_rawOut_isNaN; // @[MulAddRecFN.scala 339:39]
  assign roundRawFNToRecFN_io_in_isInf = mulAddRecFNToRaw_postMul_io_rawOut_isInf; // @[MulAddRecFN.scala 339:39]
  assign roundRawFNToRecFN_io_in_isZero = mulAddRecFNToRaw_postMul_io_rawOut_isZero; // @[MulAddRecFN.scala 339:39]
  assign roundRawFNToRecFN_io_in_sign = mulAddRecFNToRaw_postMul_io_rawOut_sign; // @[MulAddRecFN.scala 339:39]
  assign roundRawFNToRecFN_io_in_sExp = mulAddRecFNToRaw_postMul_io_rawOut_sExp; // @[MulAddRecFN.scala 339:39]
  assign roundRawFNToRecFN_io_in_sig = mulAddRecFNToRaw_postMul_io_rawOut_sig; // @[MulAddRecFN.scala 339:39]
  assign roundRawFNToRecFN_io_roundingMode = io_roundingMode; // @[MulAddRecFN.scala 340:39]
endmodule
module Queue(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] ram [0:4]; // @[Decoupled.scala 273:95]
  wire  ram_io_deq_bits_MPORT_en; // @[Decoupled.scala 273:95]
  wire [2:0] ram_io_deq_bits_MPORT_addr; // @[Decoupled.scala 273:95]
  wire [31:0] ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 273:95]
  wire [31:0] ram_MPORT_data; // @[Decoupled.scala 273:95]
  wire [2:0] ram_MPORT_addr; // @[Decoupled.scala 273:95]
  wire  ram_MPORT_mask; // @[Decoupled.scala 273:95]
  wire  ram_MPORT_en; // @[Decoupled.scala 273:95]
  reg [2:0] enq_ptr_value; // @[Counter.scala 61:40]
  reg [2:0] deq_ptr_value; // @[Counter.scala 61:40]
  reg  maybe_full; // @[Decoupled.scala 276:27]
  wire  ptr_match = enq_ptr_value == deq_ptr_value; // @[Decoupled.scala 277:33]
  wire  empty = ptr_match & ~maybe_full; // @[Decoupled.scala 278:25]
  wire  full = ptr_match & maybe_full; // @[Decoupled.scala 279:24]
  wire  do_enq = io_enq_ready & io_enq_valid; // @[Decoupled.scala 51:35]
  wire  do_deq = io_deq_ready & io_deq_valid; // @[Decoupled.scala 51:35]
  wire  wrap = enq_ptr_value == 3'h4; // @[Counter.scala 73:24]
  wire [2:0] _value_T_1 = enq_ptr_value + 3'h1; // @[Counter.scala 77:24]
  wire  wrap_1 = deq_ptr_value == 3'h4; // @[Counter.scala 73:24]
  wire [2:0] _value_T_3 = deq_ptr_value + 3'h1; // @[Counter.scala 77:24]
  assign ram_io_deq_bits_MPORT_en = 1'h1;
  assign ram_io_deq_bits_MPORT_addr = deq_ptr_value;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign ram_io_deq_bits_MPORT_data = ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 273:95]
  `else
  assign ram_io_deq_bits_MPORT_data = ram_io_deq_bits_MPORT_addr >= 3'h5 ? _RAND_1[31:0] :
    ram[ram_io_deq_bits_MPORT_addr]; // @[Decoupled.scala 273:95]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign ram_MPORT_data = io_enq_bits;
  assign ram_MPORT_addr = enq_ptr_value;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_enq_ready & io_enq_valid;
  assign io_enq_ready = ~full; // @[Decoupled.scala 303:19]
  assign io_deq_valid = ~empty; // @[Decoupled.scala 302:19]
  assign io_deq_bits = ram_io_deq_bits_MPORT_data; // @[Decoupled.scala 310:17]
  always @(posedge clock) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[Decoupled.scala 273:95]
    end
    if (reset) begin // @[Counter.scala 61:40]
      enq_ptr_value <= 3'h0; // @[Counter.scala 61:40]
    end else if (do_enq) begin // @[Decoupled.scala 286:16]
      if (wrap) begin // @[Counter.scala 87:20]
        enq_ptr_value <= 3'h0; // @[Counter.scala 87:28]
      end else begin
        enq_ptr_value <= _value_T_1; // @[Counter.scala 77:15]
      end
    end
    if (reset) begin // @[Counter.scala 61:40]
      deq_ptr_value <= 3'h0; // @[Counter.scala 61:40]
    end else if (do_deq) begin // @[Decoupled.scala 290:16]
      if (wrap_1) begin // @[Counter.scala 87:20]
        deq_ptr_value <= 3'h0; // @[Counter.scala 87:28]
      end else begin
        deq_ptr_value <= _value_T_3; // @[Counter.scala 77:15]
      end
    end
    if (reset) begin // @[Decoupled.scala 276:27]
      maybe_full <= 1'h0; // @[Decoupled.scala 276:27]
    end else if (do_enq != do_deq) begin // @[Decoupled.scala 293:27]
      maybe_full <= do_enq; // @[Decoupled.scala 294:16]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_1 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 5; initvar = initvar+1)
    ram[initvar] = _RAND_0[31:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  enq_ptr_value = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  deq_ptr_value = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  maybe_full = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module RocketLane(
  input         clock,
  input         reset,
  input         io_req_valid,
  input  [31:0] io_req_bits_operands_0_0,
  input  [31:0] io_req_bits_operands_1_0,
  input  [31:0] io_req_bits_operands_2_0,
  input  [2:0]  io_req_bits_roundingMode,
  input  [3:0]  io_req_bits_op,
  input         io_req_bits_opModifier,
  input         io_resp_ready,
  output        io_resp_valid,
  output [31:0] io_resp_bits_result_0
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [63:0] _RAND_5;
  reg [63:0] _RAND_6;
  reg [63:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
`endif // RANDOMIZE_REG_INIT
  wire [1:0] adder_io_op; // @[RocketLane.scala 91:23]
  wire [32:0] adder_io_a; // @[RocketLane.scala 91:23]
  wire [32:0] adder_io_b; // @[RocketLane.scala 91:23]
  wire [32:0] adder_io_c; // @[RocketLane.scala 91:23]
  wire [2:0] adder_io_roundingMode; // @[RocketLane.scala 91:23]
  wire [32:0] adder_io_out; // @[RocketLane.scala 91:23]
  wire  decouple_clock; // @[RocketLane.scala 114:26]
  wire  decouple_reset; // @[RocketLane.scala 114:26]
  wire  decouple_io_enq_ready; // @[RocketLane.scala 114:26]
  wire  decouple_io_enq_valid; // @[RocketLane.scala 114:26]
  wire [31:0] decouple_io_enq_bits; // @[RocketLane.scala 114:26]
  wire  decouple_io_deq_ready; // @[RocketLane.scala 114:26]
  wire  decouple_io_deq_valid; // @[RocketLane.scala 114:26]
  wire [31:0] decouple_io_deq_bits; // @[RocketLane.scala 114:26]
  wire  _adder_io_a_T = io_req_bits_op == 4'h0; // @[RocketLane.scala 99:28]
  wire [31:0] _adder_io_a_T_3 = io_req_bits_op == 4'h0 | io_req_bits_op == 4'h3 ? io_req_bits_operands_0_0 : 32'h3f800000
    ; // @[RocketLane.scala 99:12]
  wire  adder_io_a_rawIn_sign = _adder_io_a_T_3[31]; // @[rawFloatFromFN.scala 44:18]
  wire [7:0] adder_io_a_rawIn_expIn = _adder_io_a_T_3[30:23]; // @[rawFloatFromFN.scala 45:19]
  wire [22:0] adder_io_a_rawIn_fractIn = _adder_io_a_T_3[22:0]; // @[rawFloatFromFN.scala 46:21]
  wire  adder_io_a_rawIn_isZeroExpIn = adder_io_a_rawIn_expIn == 8'h0; // @[rawFloatFromFN.scala 48:30]
  wire  adder_io_a_rawIn_isZeroFractIn = adder_io_a_rawIn_fractIn == 23'h0; // @[rawFloatFromFN.scala 49:34]
  wire [4:0] _adder_io_a_rawIn_normDist_T_23 = adder_io_a_rawIn_fractIn[1] ? 5'h15 : 5'h16; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_24 = adder_io_a_rawIn_fractIn[2] ? 5'h14 : _adder_io_a_rawIn_normDist_T_23; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_25 = adder_io_a_rawIn_fractIn[3] ? 5'h13 : _adder_io_a_rawIn_normDist_T_24; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_26 = adder_io_a_rawIn_fractIn[4] ? 5'h12 : _adder_io_a_rawIn_normDist_T_25; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_27 = adder_io_a_rawIn_fractIn[5] ? 5'h11 : _adder_io_a_rawIn_normDist_T_26; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_28 = adder_io_a_rawIn_fractIn[6] ? 5'h10 : _adder_io_a_rawIn_normDist_T_27; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_29 = adder_io_a_rawIn_fractIn[7] ? 5'hf : _adder_io_a_rawIn_normDist_T_28; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_30 = adder_io_a_rawIn_fractIn[8] ? 5'he : _adder_io_a_rawIn_normDist_T_29; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_31 = adder_io_a_rawIn_fractIn[9] ? 5'hd : _adder_io_a_rawIn_normDist_T_30; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_32 = adder_io_a_rawIn_fractIn[10] ? 5'hc : _adder_io_a_rawIn_normDist_T_31; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_33 = adder_io_a_rawIn_fractIn[11] ? 5'hb : _adder_io_a_rawIn_normDist_T_32; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_34 = adder_io_a_rawIn_fractIn[12] ? 5'ha : _adder_io_a_rawIn_normDist_T_33; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_35 = adder_io_a_rawIn_fractIn[13] ? 5'h9 : _adder_io_a_rawIn_normDist_T_34; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_36 = adder_io_a_rawIn_fractIn[14] ? 5'h8 : _adder_io_a_rawIn_normDist_T_35; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_37 = adder_io_a_rawIn_fractIn[15] ? 5'h7 : _adder_io_a_rawIn_normDist_T_36; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_38 = adder_io_a_rawIn_fractIn[16] ? 5'h6 : _adder_io_a_rawIn_normDist_T_37; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_39 = adder_io_a_rawIn_fractIn[17] ? 5'h5 : _adder_io_a_rawIn_normDist_T_38; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_40 = adder_io_a_rawIn_fractIn[18] ? 5'h4 : _adder_io_a_rawIn_normDist_T_39; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_41 = adder_io_a_rawIn_fractIn[19] ? 5'h3 : _adder_io_a_rawIn_normDist_T_40; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_42 = adder_io_a_rawIn_fractIn[20] ? 5'h2 : _adder_io_a_rawIn_normDist_T_41; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_a_rawIn_normDist_T_43 = adder_io_a_rawIn_fractIn[21] ? 5'h1 : _adder_io_a_rawIn_normDist_T_42; // @[Mux.scala 47:70]
  wire [4:0] adder_io_a_rawIn_normDist = adder_io_a_rawIn_fractIn[22] ? 5'h0 : _adder_io_a_rawIn_normDist_T_43; // @[Mux.scala 47:70]
  wire [53:0] _GEN_0 = {{31'd0}, adder_io_a_rawIn_fractIn}; // @[rawFloatFromFN.scala 52:33]
  wire [53:0] _adder_io_a_rawIn_subnormFract_T = _GEN_0 << adder_io_a_rawIn_normDist; // @[rawFloatFromFN.scala 52:33]
  wire [22:0] adder_io_a_rawIn_subnormFract = {_adder_io_a_rawIn_subnormFract_T[21:0], 1'h0}; // @[rawFloatFromFN.scala 52:64]
  wire [8:0] _GEN_3 = {{4'd0}, adder_io_a_rawIn_normDist}; // @[rawFloatFromFN.scala 55:18]
  wire [8:0] _adder_io_a_rawIn_adjustedExp_T = _GEN_3 ^ 9'h1ff; // @[rawFloatFromFN.scala 55:18]
  wire [8:0] _adder_io_a_rawIn_adjustedExp_T_1 = adder_io_a_rawIn_isZeroExpIn ? _adder_io_a_rawIn_adjustedExp_T : {{1
    'd0}, adder_io_a_rawIn_expIn}; // @[rawFloatFromFN.scala 54:10]
  wire [1:0] _adder_io_a_rawIn_adjustedExp_T_2 = adder_io_a_rawIn_isZeroExpIn ? 2'h2 : 2'h1; // @[rawFloatFromFN.scala 58:14]
  wire [7:0] _GEN_4 = {{6'd0}, _adder_io_a_rawIn_adjustedExp_T_2}; // @[rawFloatFromFN.scala 58:9]
  wire [7:0] _adder_io_a_rawIn_adjustedExp_T_3 = 8'h80 | _GEN_4; // @[rawFloatFromFN.scala 58:9]
  wire [8:0] _GEN_5 = {{1'd0}, _adder_io_a_rawIn_adjustedExp_T_3}; // @[rawFloatFromFN.scala 57:9]
  wire [8:0] adder_io_a_rawIn_adjustedExp = _adder_io_a_rawIn_adjustedExp_T_1 + _GEN_5; // @[rawFloatFromFN.scala 57:9]
  wire  adder_io_a_rawIn_isZero = adder_io_a_rawIn_isZeroExpIn & adder_io_a_rawIn_isZeroFractIn; // @[rawFloatFromFN.scala 60:30]
  wire  adder_io_a_rawIn_isSpecial = adder_io_a_rawIn_adjustedExp[8:7] == 2'h3; // @[rawFloatFromFN.scala 61:57]
  wire  adder_io_a_rawIn__isNaN = adder_io_a_rawIn_isSpecial & ~adder_io_a_rawIn_isZeroFractIn; // @[rawFloatFromFN.scala 64:28]
  wire [9:0] adder_io_a_rawIn__sExp = {1'b0,$signed(adder_io_a_rawIn_adjustedExp)}; // @[rawFloatFromFN.scala 68:42]
  wire  _adder_io_a_rawIn_out_sig_T = ~adder_io_a_rawIn_isZero; // @[rawFloatFromFN.scala 70:19]
  wire [22:0] _adder_io_a_rawIn_out_sig_T_2 = adder_io_a_rawIn_isZeroExpIn ? adder_io_a_rawIn_subnormFract :
    adder_io_a_rawIn_fractIn; // @[rawFloatFromFN.scala 70:33]
  wire [24:0] adder_io_a_rawIn__sig = {1'h0,_adder_io_a_rawIn_out_sig_T,_adder_io_a_rawIn_out_sig_T_2}; // @[rawFloatFromFN.scala 70:27]
  wire [2:0] _adder_io_a_T_5 = adder_io_a_rawIn_isZero ? 3'h0 : adder_io_a_rawIn__sExp[8:6]; // @[recFNFromFN.scala 48:15]
  wire [2:0] _GEN_6 = {{2'd0}, adder_io_a_rawIn__isNaN}; // @[recFNFromFN.scala 48:76]
  wire [2:0] _adder_io_a_T_7 = _adder_io_a_T_5 | _GEN_6; // @[recFNFromFN.scala 48:76]
  wire [9:0] _adder_io_a_T_10 = {adder_io_a_rawIn_sign,_adder_io_a_T_7,adder_io_a_rawIn__sExp[5:0]}; // @[recFNFromFN.scala 49:45]
  reg [32:0] adder_io_a_REG; // @[RocketLane.scala 17:40]
  reg [32:0] adder_io_a_REG_1; // @[RocketLane.scala 17:40]
  reg [1:0] adder_io_op_REG; // @[RocketLane.scala 17:40]
  reg [1:0] adder_io_op_REG_1; // @[RocketLane.scala 17:40]
  wire  adder_io_b_rawIn_sign = io_req_bits_operands_1_0[31]; // @[rawFloatFromFN.scala 44:18]
  wire [7:0] adder_io_b_rawIn_expIn = io_req_bits_operands_1_0[30:23]; // @[rawFloatFromFN.scala 45:19]
  wire [22:0] adder_io_b_rawIn_fractIn = io_req_bits_operands_1_0[22:0]; // @[rawFloatFromFN.scala 46:21]
  wire  adder_io_b_rawIn_isZeroExpIn = adder_io_b_rawIn_expIn == 8'h0; // @[rawFloatFromFN.scala 48:30]
  wire  adder_io_b_rawIn_isZeroFractIn = adder_io_b_rawIn_fractIn == 23'h0; // @[rawFloatFromFN.scala 49:34]
  wire [4:0] _adder_io_b_rawIn_normDist_T_23 = adder_io_b_rawIn_fractIn[1] ? 5'h15 : 5'h16; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_24 = adder_io_b_rawIn_fractIn[2] ? 5'h14 : _adder_io_b_rawIn_normDist_T_23; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_25 = adder_io_b_rawIn_fractIn[3] ? 5'h13 : _adder_io_b_rawIn_normDist_T_24; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_26 = adder_io_b_rawIn_fractIn[4] ? 5'h12 : _adder_io_b_rawIn_normDist_T_25; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_27 = adder_io_b_rawIn_fractIn[5] ? 5'h11 : _adder_io_b_rawIn_normDist_T_26; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_28 = adder_io_b_rawIn_fractIn[6] ? 5'h10 : _adder_io_b_rawIn_normDist_T_27; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_29 = adder_io_b_rawIn_fractIn[7] ? 5'hf : _adder_io_b_rawIn_normDist_T_28; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_30 = adder_io_b_rawIn_fractIn[8] ? 5'he : _adder_io_b_rawIn_normDist_T_29; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_31 = adder_io_b_rawIn_fractIn[9] ? 5'hd : _adder_io_b_rawIn_normDist_T_30; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_32 = adder_io_b_rawIn_fractIn[10] ? 5'hc : _adder_io_b_rawIn_normDist_T_31; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_33 = adder_io_b_rawIn_fractIn[11] ? 5'hb : _adder_io_b_rawIn_normDist_T_32; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_34 = adder_io_b_rawIn_fractIn[12] ? 5'ha : _adder_io_b_rawIn_normDist_T_33; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_35 = adder_io_b_rawIn_fractIn[13] ? 5'h9 : _adder_io_b_rawIn_normDist_T_34; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_36 = adder_io_b_rawIn_fractIn[14] ? 5'h8 : _adder_io_b_rawIn_normDist_T_35; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_37 = adder_io_b_rawIn_fractIn[15] ? 5'h7 : _adder_io_b_rawIn_normDist_T_36; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_38 = adder_io_b_rawIn_fractIn[16] ? 5'h6 : _adder_io_b_rawIn_normDist_T_37; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_39 = adder_io_b_rawIn_fractIn[17] ? 5'h5 : _adder_io_b_rawIn_normDist_T_38; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_40 = adder_io_b_rawIn_fractIn[18] ? 5'h4 : _adder_io_b_rawIn_normDist_T_39; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_41 = adder_io_b_rawIn_fractIn[19] ? 5'h3 : _adder_io_b_rawIn_normDist_T_40; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_42 = adder_io_b_rawIn_fractIn[20] ? 5'h2 : _adder_io_b_rawIn_normDist_T_41; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_b_rawIn_normDist_T_43 = adder_io_b_rawIn_fractIn[21] ? 5'h1 : _adder_io_b_rawIn_normDist_T_42; // @[Mux.scala 47:70]
  wire [4:0] adder_io_b_rawIn_normDist = adder_io_b_rawIn_fractIn[22] ? 5'h0 : _adder_io_b_rawIn_normDist_T_43; // @[Mux.scala 47:70]
  wire [53:0] _GEN_1 = {{31'd0}, adder_io_b_rawIn_fractIn}; // @[rawFloatFromFN.scala 52:33]
  wire [53:0] _adder_io_b_rawIn_subnormFract_T = _GEN_1 << adder_io_b_rawIn_normDist; // @[rawFloatFromFN.scala 52:33]
  wire [22:0] adder_io_b_rawIn_subnormFract = {_adder_io_b_rawIn_subnormFract_T[21:0], 1'h0}; // @[rawFloatFromFN.scala 52:64]
  wire [8:0] _GEN_7 = {{4'd0}, adder_io_b_rawIn_normDist}; // @[rawFloatFromFN.scala 55:18]
  wire [8:0] _adder_io_b_rawIn_adjustedExp_T = _GEN_7 ^ 9'h1ff; // @[rawFloatFromFN.scala 55:18]
  wire [8:0] _adder_io_b_rawIn_adjustedExp_T_1 = adder_io_b_rawIn_isZeroExpIn ? _adder_io_b_rawIn_adjustedExp_T : {{1
    'd0}, adder_io_b_rawIn_expIn}; // @[rawFloatFromFN.scala 54:10]
  wire [1:0] _adder_io_b_rawIn_adjustedExp_T_2 = adder_io_b_rawIn_isZeroExpIn ? 2'h2 : 2'h1; // @[rawFloatFromFN.scala 58:14]
  wire [7:0] _GEN_8 = {{6'd0}, _adder_io_b_rawIn_adjustedExp_T_2}; // @[rawFloatFromFN.scala 58:9]
  wire [7:0] _adder_io_b_rawIn_adjustedExp_T_3 = 8'h80 | _GEN_8; // @[rawFloatFromFN.scala 58:9]
  wire [8:0] _GEN_9 = {{1'd0}, _adder_io_b_rawIn_adjustedExp_T_3}; // @[rawFloatFromFN.scala 57:9]
  wire [8:0] adder_io_b_rawIn_adjustedExp = _adder_io_b_rawIn_adjustedExp_T_1 + _GEN_9; // @[rawFloatFromFN.scala 57:9]
  wire  adder_io_b_rawIn_isZero = adder_io_b_rawIn_isZeroExpIn & adder_io_b_rawIn_isZeroFractIn; // @[rawFloatFromFN.scala 60:30]
  wire  adder_io_b_rawIn_isSpecial = adder_io_b_rawIn_adjustedExp[8:7] == 2'h3; // @[rawFloatFromFN.scala 61:57]
  wire  adder_io_b_rawIn__isNaN = adder_io_b_rawIn_isSpecial & ~adder_io_b_rawIn_isZeroFractIn; // @[rawFloatFromFN.scala 64:28]
  wire [9:0] adder_io_b_rawIn__sExp = {1'b0,$signed(adder_io_b_rawIn_adjustedExp)}; // @[rawFloatFromFN.scala 68:42]
  wire  _adder_io_b_rawIn_out_sig_T = ~adder_io_b_rawIn_isZero; // @[rawFloatFromFN.scala 70:19]
  wire [22:0] _adder_io_b_rawIn_out_sig_T_2 = adder_io_b_rawIn_isZeroExpIn ? adder_io_b_rawIn_subnormFract :
    adder_io_b_rawIn_fractIn; // @[rawFloatFromFN.scala 70:33]
  wire [24:0] adder_io_b_rawIn__sig = {1'h0,_adder_io_b_rawIn_out_sig_T,_adder_io_b_rawIn_out_sig_T_2}; // @[rawFloatFromFN.scala 70:27]
  wire [2:0] _adder_io_b_T_1 = adder_io_b_rawIn_isZero ? 3'h0 : adder_io_b_rawIn__sExp[8:6]; // @[recFNFromFN.scala 48:15]
  wire [2:0] _GEN_10 = {{2'd0}, adder_io_b_rawIn__isNaN}; // @[recFNFromFN.scala 48:76]
  wire [2:0] _adder_io_b_T_3 = _adder_io_b_T_1 | _GEN_10; // @[recFNFromFN.scala 48:76]
  wire [9:0] _adder_io_b_T_6 = {adder_io_b_rawIn_sign,_adder_io_b_T_3,adder_io_b_rawIn__sExp[5:0]}; // @[recFNFromFN.scala 49:45]
  reg [32:0] adder_io_b_REG; // @[RocketLane.scala 17:40]
  reg [32:0] adder_io_b_REG_1; // @[RocketLane.scala 17:40]
  wire  adder_io_c_rawIn_sign = io_req_bits_operands_2_0[31]; // @[rawFloatFromFN.scala 44:18]
  wire [7:0] adder_io_c_rawIn_expIn = io_req_bits_operands_2_0[30:23]; // @[rawFloatFromFN.scala 45:19]
  wire [22:0] adder_io_c_rawIn_fractIn = io_req_bits_operands_2_0[22:0]; // @[rawFloatFromFN.scala 46:21]
  wire  adder_io_c_rawIn_isZeroExpIn = adder_io_c_rawIn_expIn == 8'h0; // @[rawFloatFromFN.scala 48:30]
  wire  adder_io_c_rawIn_isZeroFractIn = adder_io_c_rawIn_fractIn == 23'h0; // @[rawFloatFromFN.scala 49:34]
  wire [4:0] _adder_io_c_rawIn_normDist_T_23 = adder_io_c_rawIn_fractIn[1] ? 5'h15 : 5'h16; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_24 = adder_io_c_rawIn_fractIn[2] ? 5'h14 : _adder_io_c_rawIn_normDist_T_23; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_25 = adder_io_c_rawIn_fractIn[3] ? 5'h13 : _adder_io_c_rawIn_normDist_T_24; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_26 = adder_io_c_rawIn_fractIn[4] ? 5'h12 : _adder_io_c_rawIn_normDist_T_25; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_27 = adder_io_c_rawIn_fractIn[5] ? 5'h11 : _adder_io_c_rawIn_normDist_T_26; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_28 = adder_io_c_rawIn_fractIn[6] ? 5'h10 : _adder_io_c_rawIn_normDist_T_27; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_29 = adder_io_c_rawIn_fractIn[7] ? 5'hf : _adder_io_c_rawIn_normDist_T_28; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_30 = adder_io_c_rawIn_fractIn[8] ? 5'he : _adder_io_c_rawIn_normDist_T_29; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_31 = adder_io_c_rawIn_fractIn[9] ? 5'hd : _adder_io_c_rawIn_normDist_T_30; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_32 = adder_io_c_rawIn_fractIn[10] ? 5'hc : _adder_io_c_rawIn_normDist_T_31; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_33 = adder_io_c_rawIn_fractIn[11] ? 5'hb : _adder_io_c_rawIn_normDist_T_32; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_34 = adder_io_c_rawIn_fractIn[12] ? 5'ha : _adder_io_c_rawIn_normDist_T_33; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_35 = adder_io_c_rawIn_fractIn[13] ? 5'h9 : _adder_io_c_rawIn_normDist_T_34; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_36 = adder_io_c_rawIn_fractIn[14] ? 5'h8 : _adder_io_c_rawIn_normDist_T_35; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_37 = adder_io_c_rawIn_fractIn[15] ? 5'h7 : _adder_io_c_rawIn_normDist_T_36; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_38 = adder_io_c_rawIn_fractIn[16] ? 5'h6 : _adder_io_c_rawIn_normDist_T_37; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_39 = adder_io_c_rawIn_fractIn[17] ? 5'h5 : _adder_io_c_rawIn_normDist_T_38; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_40 = adder_io_c_rawIn_fractIn[18] ? 5'h4 : _adder_io_c_rawIn_normDist_T_39; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_41 = adder_io_c_rawIn_fractIn[19] ? 5'h3 : _adder_io_c_rawIn_normDist_T_40; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_42 = adder_io_c_rawIn_fractIn[20] ? 5'h2 : _adder_io_c_rawIn_normDist_T_41; // @[Mux.scala 47:70]
  wire [4:0] _adder_io_c_rawIn_normDist_T_43 = adder_io_c_rawIn_fractIn[21] ? 5'h1 : _adder_io_c_rawIn_normDist_T_42; // @[Mux.scala 47:70]
  wire [4:0] adder_io_c_rawIn_normDist = adder_io_c_rawIn_fractIn[22] ? 5'h0 : _adder_io_c_rawIn_normDist_T_43; // @[Mux.scala 47:70]
  wire [53:0] _GEN_2 = {{31'd0}, adder_io_c_rawIn_fractIn}; // @[rawFloatFromFN.scala 52:33]
  wire [53:0] _adder_io_c_rawIn_subnormFract_T = _GEN_2 << adder_io_c_rawIn_normDist; // @[rawFloatFromFN.scala 52:33]
  wire [22:0] adder_io_c_rawIn_subnormFract = {_adder_io_c_rawIn_subnormFract_T[21:0], 1'h0}; // @[rawFloatFromFN.scala 52:64]
  wire [8:0] _GEN_11 = {{4'd0}, adder_io_c_rawIn_normDist}; // @[rawFloatFromFN.scala 55:18]
  wire [8:0] _adder_io_c_rawIn_adjustedExp_T = _GEN_11 ^ 9'h1ff; // @[rawFloatFromFN.scala 55:18]
  wire [8:0] _adder_io_c_rawIn_adjustedExp_T_1 = adder_io_c_rawIn_isZeroExpIn ? _adder_io_c_rawIn_adjustedExp_T : {{1
    'd0}, adder_io_c_rawIn_expIn}; // @[rawFloatFromFN.scala 54:10]
  wire [1:0] _adder_io_c_rawIn_adjustedExp_T_2 = adder_io_c_rawIn_isZeroExpIn ? 2'h2 : 2'h1; // @[rawFloatFromFN.scala 58:14]
  wire [7:0] _GEN_12 = {{6'd0}, _adder_io_c_rawIn_adjustedExp_T_2}; // @[rawFloatFromFN.scala 58:9]
  wire [7:0] _adder_io_c_rawIn_adjustedExp_T_3 = 8'h80 | _GEN_12; // @[rawFloatFromFN.scala 58:9]
  wire [8:0] _GEN_13 = {{1'd0}, _adder_io_c_rawIn_adjustedExp_T_3}; // @[rawFloatFromFN.scala 57:9]
  wire [8:0] adder_io_c_rawIn_adjustedExp = _adder_io_c_rawIn_adjustedExp_T_1 + _GEN_13; // @[rawFloatFromFN.scala 57:9]
  wire  adder_io_c_rawIn_isZero = adder_io_c_rawIn_isZeroExpIn & adder_io_c_rawIn_isZeroFractIn; // @[rawFloatFromFN.scala 60:30]
  wire  adder_io_c_rawIn_isSpecial = adder_io_c_rawIn_adjustedExp[8:7] == 2'h3; // @[rawFloatFromFN.scala 61:57]
  wire  adder_io_c_rawIn__isNaN = adder_io_c_rawIn_isSpecial & ~adder_io_c_rawIn_isZeroFractIn; // @[rawFloatFromFN.scala 64:28]
  wire [9:0] adder_io_c_rawIn__sExp = {1'b0,$signed(adder_io_c_rawIn_adjustedExp)}; // @[rawFloatFromFN.scala 68:42]
  wire  _adder_io_c_rawIn_out_sig_T = ~adder_io_c_rawIn_isZero; // @[rawFloatFromFN.scala 70:19]
  wire [22:0] _adder_io_c_rawIn_out_sig_T_2 = adder_io_c_rawIn_isZeroExpIn ? adder_io_c_rawIn_subnormFract :
    adder_io_c_rawIn_fractIn; // @[rawFloatFromFN.scala 70:33]
  wire [24:0] adder_io_c_rawIn__sig = {1'h0,_adder_io_c_rawIn_out_sig_T,_adder_io_c_rawIn_out_sig_T_2}; // @[rawFloatFromFN.scala 70:27]
  wire [2:0] _adder_io_c_T_4 = adder_io_c_rawIn_isZero ? 3'h0 : adder_io_c_rawIn__sExp[8:6]; // @[recFNFromFN.scala 48:15]
  wire [2:0] _GEN_14 = {{2'd0}, adder_io_c_rawIn__isNaN}; // @[recFNFromFN.scala 48:76]
  wire [2:0] _adder_io_c_T_6 = _adder_io_c_T_4 | _GEN_14; // @[recFNFromFN.scala 48:76]
  wire [32:0] _adder_io_c_T_11 = {adder_io_c_rawIn_sign,_adder_io_c_T_6,adder_io_c_rawIn__sExp[5:0],
    adder_io_c_rawIn__sig[22:0]}; // @[recFNFromFN.scala 50:41]
  reg [32:0] adder_io_c_REG; // @[RocketLane.scala 17:40]
  reg [32:0] adder_io_c_REG_1; // @[RocketLane.scala 17:40]
  reg [2:0] adder_io_roundingMode_REG; // @[RocketLane.scala 17:40]
  reg [2:0] adder_io_roundingMode_REG_1; // @[RocketLane.scala 17:40]
  reg  decouple_io_enq_valid_REG; // @[RocketLane.scala 17:40]
  reg  decouple_io_enq_valid_REG_1; // @[RocketLane.scala 17:40]
  reg  decouple_io_enq_valid_REG_2; // @[RocketLane.scala 17:40]
  reg  decouple_io_enq_valid_REG_3; // @[RocketLane.scala 17:40]
  wire [8:0] decouple_io_enq_bits_rawIn_exp = adder_io_out[31:23]; // @[rawFloatFromRecFN.scala 51:21]
  wire  decouple_io_enq_bits_rawIn_isZero = decouple_io_enq_bits_rawIn_exp[8:6] == 3'h0; // @[rawFloatFromRecFN.scala 52:53]
  wire  decouple_io_enq_bits_rawIn_isSpecial = decouple_io_enq_bits_rawIn_exp[8:7] == 2'h3; // @[rawFloatFromRecFN.scala 53:53]
  wire  decouple_io_enq_bits_rawIn__isNaN = decouple_io_enq_bits_rawIn_isSpecial & decouple_io_enq_bits_rawIn_exp[6]; // @[rawFloatFromRecFN.scala 56:33]
  wire  decouple_io_enq_bits_rawIn__isInf = decouple_io_enq_bits_rawIn_isSpecial & ~decouple_io_enq_bits_rawIn_exp[6]; // @[rawFloatFromRecFN.scala 57:33]
  wire  decouple_io_enq_bits_rawIn__sign = adder_io_out[32]; // @[rawFloatFromRecFN.scala 59:25]
  wire [9:0] decouple_io_enq_bits_rawIn__sExp = {1'b0,$signed(decouple_io_enq_bits_rawIn_exp)}; // @[rawFloatFromRecFN.scala 60:27]
  wire  _decouple_io_enq_bits_rawIn_out_sig_T = ~decouple_io_enq_bits_rawIn_isZero; // @[rawFloatFromRecFN.scala 61:35]
  wire [24:0] decouple_io_enq_bits_rawIn__sig = {1'h0,_decouple_io_enq_bits_rawIn_out_sig_T,adder_io_out[22:0]}; // @[rawFloatFromRecFN.scala 61:44]
  wire  decouple_io_enq_bits_isSubnormal = $signed(decouple_io_enq_bits_rawIn__sExp) < 10'sh82; // @[fNFromRecFN.scala 51:38]
  wire [4:0] decouple_io_enq_bits_denormShiftDist = 5'h1 - decouple_io_enq_bits_rawIn__sExp[4:0]; // @[fNFromRecFN.scala 52:35]
  wire [23:0] _decouple_io_enq_bits_denormFract_T_1 = decouple_io_enq_bits_rawIn__sig[24:1] >>
    decouple_io_enq_bits_denormShiftDist; // @[fNFromRecFN.scala 53:42]
  wire [22:0] decouple_io_enq_bits_denormFract = _decouple_io_enq_bits_denormFract_T_1[22:0]; // @[fNFromRecFN.scala 53:60]
  wire [7:0] _decouple_io_enq_bits_expOut_T_2 = decouple_io_enq_bits_rawIn__sExp[7:0] - 8'h81; // @[fNFromRecFN.scala 58:45]
  wire [7:0] _decouple_io_enq_bits_expOut_T_3 = decouple_io_enq_bits_isSubnormal ? 8'h0 :
    _decouple_io_enq_bits_expOut_T_2; // @[fNFromRecFN.scala 56:16]
  wire  _decouple_io_enq_bits_expOut_T_4 = decouple_io_enq_bits_rawIn__isNaN | decouple_io_enq_bits_rawIn__isInf; // @[fNFromRecFN.scala 60:44]
  wire [7:0] _decouple_io_enq_bits_expOut_T_6 = _decouple_io_enq_bits_expOut_T_4 ? 8'hff : 8'h0; // @[Bitwise.scala 77:12]
  wire [7:0] decouple_io_enq_bits_expOut = _decouple_io_enq_bits_expOut_T_3 | _decouple_io_enq_bits_expOut_T_6; // @[fNFromRecFN.scala 60:15]
  wire [22:0] _decouple_io_enq_bits_fractOut_T_1 = decouple_io_enq_bits_rawIn__isInf ? 23'h0 :
    decouple_io_enq_bits_rawIn__sig[22:0]; // @[fNFromRecFN.scala 64:20]
  wire [22:0] decouple_io_enq_bits_fractOut = decouple_io_enq_bits_isSubnormal ? decouple_io_enq_bits_denormFract :
    _decouple_io_enq_bits_fractOut_T_1; // @[fNFromRecFN.scala 62:16]
  wire [8:0] decouple_io_enq_bits_hi = {decouple_io_enq_bits_rawIn__sign,decouple_io_enq_bits_expOut}; // @[Cat.scala 33:92]
  reg [31:0] decouple_io_enq_bits_REG; // @[RocketLane.scala 17:40]
  reg [31:0] decouple_io_enq_bits_REG_1; // @[RocketLane.scala 17:40]
  MulAddRecFN adder ( // @[RocketLane.scala 91:23]
    .io_op(adder_io_op),
    .io_a(adder_io_a),
    .io_b(adder_io_b),
    .io_c(adder_io_c),
    .io_roundingMode(adder_io_roundingMode),
    .io_out(adder_io_out)
  );
  Queue decouple ( // @[RocketLane.scala 114:26]
    .clock(decouple_clock),
    .reset(decouple_reset),
    .io_enq_ready(decouple_io_enq_ready),
    .io_enq_valid(decouple_io_enq_valid),
    .io_enq_bits(decouple_io_enq_bits),
    .io_deq_ready(decouple_io_deq_ready),
    .io_deq_valid(decouple_io_deq_valid),
    .io_deq_bits(decouple_io_deq_bits)
  );
  assign io_resp_valid = decouple_io_deq_valid; // @[RocketLane.scala 128:19]
  assign io_resp_bits_result_0 = decouple_io_deq_bits; // @[RocketLane.scala 127:28]
  assign adder_io_op = adder_io_op_REG_1; // @[RocketLane.scala 106:17]
  assign adder_io_a = adder_io_a_REG_1; // @[RocketLane.scala 97:16]
  assign adder_io_b = adder_io_b_REG_1; // @[RocketLane.scala 107:16]
  assign adder_io_c = adder_io_c_REG_1; // @[RocketLane.scala 108:16]
  assign adder_io_roundingMode = adder_io_roundingMode_REG_1; // @[RocketLane.scala 110:75]
  assign decouple_clock = clock;
  assign decouple_reset = reset;
  assign decouple_io_enq_valid = decouple_io_enq_valid_REG_3; // @[RocketLane.scala 131:27]
  assign decouple_io_enq_bits = decouple_io_enq_bits_REG_1; // @[RocketLane.scala 132:26]
  assign decouple_io_deq_ready = io_resp_ready; // @[RocketLane.scala 129:27]
  always @(posedge clock) begin
    adder_io_a_REG <= {_adder_io_a_T_10,adder_io_a_rawIn__sig[22:0]}; // @[recFNFromFN.scala 50:41]
    adder_io_a_REG_1 <= adder_io_a_REG; // @[RocketLane.scala 17:40]
    adder_io_op_REG <= {1'h0,io_req_bits_opModifier}; // @[Cat.scala 33:92]
    adder_io_op_REG_1 <= adder_io_op_REG; // @[RocketLane.scala 17:40]
    adder_io_b_REG <= {_adder_io_b_T_6,adder_io_b_rawIn__sig[22:0]}; // @[recFNFromFN.scala 50:41]
    adder_io_b_REG_1 <= adder_io_b_REG; // @[RocketLane.scala 17:40]
    if (_adder_io_a_T | io_req_bits_op == 4'h2) begin // @[RocketLane.scala 108:33]
      adder_io_c_REG <= _adder_io_c_T_11;
    end else begin
      adder_io_c_REG <= 33'h0;
    end
    adder_io_c_REG_1 <= adder_io_c_REG; // @[RocketLane.scala 17:40]
    adder_io_roundingMode_REG <= io_req_bits_roundingMode; // @[RocketLane.scala 17:40]
    adder_io_roundingMode_REG_1 <= adder_io_roundingMode_REG; // @[RocketLane.scala 17:40]
    decouple_io_enq_valid_REG <= io_req_valid; // @[RocketLane.scala 17:40]
    decouple_io_enq_valid_REG_1 <= decouple_io_enq_valid_REG; // @[RocketLane.scala 17:40]
    decouple_io_enq_valid_REG_2 <= decouple_io_enq_valid_REG_1; // @[RocketLane.scala 17:40]
    decouple_io_enq_valid_REG_3 <= decouple_io_enq_valid_REG_2; // @[RocketLane.scala 17:40]
    decouple_io_enq_bits_REG <= {decouple_io_enq_bits_hi,decouple_io_enq_bits_fractOut}; // @[Cat.scala 33:92]
    decouple_io_enq_bits_REG_1 <= decouple_io_enq_bits_REG; // @[RocketLane.scala 17:40]
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (decouple_io_enq_valid & ~reset & ~decouple_io_enq_ready) begin
          $fwrite(32'h80000002,"Assertion failed\n    at RocketLane.scala:134 assert(decouple.io.enq.ready)\n"); // @[RocketLane.scala 134:13]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
    `ifndef SYNTHESIS
    `ifdef STOP_COND
      if (`STOP_COND) begin
    `endif
        if (decouple_io_enq_valid & ~reset & ~decouple_io_enq_ready) begin
          $fatal; // @[RocketLane.scala 134:13]
        end
    `ifdef STOP_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {2{`RANDOM}};
  adder_io_a_REG = _RAND_0[32:0];
  _RAND_1 = {2{`RANDOM}};
  adder_io_a_REG_1 = _RAND_1[32:0];
  _RAND_2 = {1{`RANDOM}};
  adder_io_op_REG = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  adder_io_op_REG_1 = _RAND_3[1:0];
  _RAND_4 = {2{`RANDOM}};
  adder_io_b_REG = _RAND_4[32:0];
  _RAND_5 = {2{`RANDOM}};
  adder_io_b_REG_1 = _RAND_5[32:0];
  _RAND_6 = {2{`RANDOM}};
  adder_io_c_REG = _RAND_6[32:0];
  _RAND_7 = {2{`RANDOM}};
  adder_io_c_REG_1 = _RAND_7[32:0];
  _RAND_8 = {1{`RANDOM}};
  adder_io_roundingMode_REG = _RAND_8[2:0];
  _RAND_9 = {1{`RANDOM}};
  adder_io_roundingMode_REG_1 = _RAND_9[2:0];
  _RAND_10 = {1{`RANDOM}};
  decouple_io_enq_valid_REG = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  decouple_io_enq_valid_REG_1 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  decouple_io_enq_valid_REG_2 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  decouple_io_enq_valid_REG_3 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  decouple_io_enq_bits_REG = _RAND_14[31:0];
  _RAND_15 = {1{`RANDOM}};
  decouple_io_enq_bits_REG_1 = _RAND_15[31:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module FPU(
  input         clock,
  input         reset,
  output        io_req_ready,
  input         io_req_valid,
  input  [31:0] io_req_bits_operands_0_0,
  input  [31:0] io_req_bits_operands_1_0,
  input  [31:0] io_req_bits_operands_2_0,
  input  [2:0]  io_req_bits_roundingMode,
  input  [3:0]  io_req_bits_op,
  input         io_req_bits_opModifier,
  input  [2:0]  io_req_bits_srcFormat,
  input  [2:0]  io_req_bits_dstFormat,
  input  [1:0]  io_req_bits_intFormat,
  input         io_resp_ready,
  output        io_resp_valid,
  output [31:0] io_resp_bits_result_0,
  output        io_resp_bits_status_NV,
  output        io_resp_bits_status_DZ,
  output        io_resp_bits_status_OF,
  output        io_resp_bits_status_UF,
  output        io_resp_bits_status_NX
);
  wire  vecs_0_clock; // @[FPU.scala 65:25]
  wire  vecs_0_reset; // @[FPU.scala 65:25]
  wire  vecs_0_io_req_valid; // @[FPU.scala 65:25]
  wire [31:0] vecs_0_io_req_bits_operands_0_0; // @[FPU.scala 65:25]
  wire [31:0] vecs_0_io_req_bits_operands_1_0; // @[FPU.scala 65:25]
  wire [31:0] vecs_0_io_req_bits_operands_2_0; // @[FPU.scala 65:25]
  wire [2:0] vecs_0_io_req_bits_roundingMode; // @[FPU.scala 65:25]
  wire [3:0] vecs_0_io_req_bits_op; // @[FPU.scala 65:25]
  wire  vecs_0_io_req_bits_opModifier; // @[FPU.scala 65:25]
  wire  vecs_0_io_resp_ready; // @[FPU.scala 65:25]
  wire  vecs_0_io_resp_valid; // @[FPU.scala 65:25]
  wire [31:0] vecs_0_io_resp_bits_result_0; // @[FPU.scala 65:25]
  RocketLane vecs_0 ( // @[FPU.scala 65:25]
    .clock(vecs_0_clock),
    .reset(vecs_0_reset),
    .io_req_valid(vecs_0_io_req_valid),
    .io_req_bits_operands_0_0(vecs_0_io_req_bits_operands_0_0),
    .io_req_bits_operands_1_0(vecs_0_io_req_bits_operands_1_0),
    .io_req_bits_operands_2_0(vecs_0_io_req_bits_operands_2_0),
    .io_req_bits_roundingMode(vecs_0_io_req_bits_roundingMode),
    .io_req_bits_op(vecs_0_io_req_bits_op),
    .io_req_bits_opModifier(vecs_0_io_req_bits_opModifier),
    .io_resp_ready(vecs_0_io_resp_ready),
    .io_resp_valid(vecs_0_io_resp_valid),
    .io_resp_bits_result_0(vecs_0_io_resp_bits_result_0)
  );
  assign io_req_ready = 1'h1; // @[FPU.scala 63:20]
  assign io_resp_valid = vecs_0_io_resp_valid; // @[FPU.scala 79:21]
  assign io_resp_bits_result_0 = vecs_0_io_resp_bits_result_0; // @[FPU.scala 77:96]
  assign io_resp_bits_status_NV = 1'h0;
  assign io_resp_bits_status_DZ = 1'h0;
  assign io_resp_bits_status_OF = 1'h0;
  assign io_resp_bits_status_UF = 1'h0;
  assign io_resp_bits_status_NX = 1'h0;
  assign vecs_0_clock = clock;
  assign vecs_0_reset = reset;
  assign vecs_0_io_req_valid = io_req_valid; // @[FPU.scala 66:26]
  assign vecs_0_io_req_bits_operands_0_0 = io_req_bits_operands_0_0; // @[FPU.scala 69:117]
  assign vecs_0_io_req_bits_operands_1_0 = io_req_bits_operands_1_0; // @[FPU.scala 69:117]
  assign vecs_0_io_req_bits_operands_2_0 = io_req_bits_operands_2_0; // @[FPU.scala 69:117]
  assign vecs_0_io_req_bits_roundingMode = io_req_bits_roundingMode; // @[FPU.scala 70:38]
  assign vecs_0_io_req_bits_op = io_req_bits_op; // @[FPU.scala 67:28]
  assign vecs_0_io_req_bits_opModifier = io_req_bits_opModifier; // @[FPU.scala 68:36]
  assign vecs_0_io_resp_ready = io_resp_ready; // @[FPU.scala 71:27]
endmodule
