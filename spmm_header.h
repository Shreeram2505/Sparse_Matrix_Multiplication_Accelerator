#ifndef SPARSE_MATRIX_MUL_H
#define SPARSE_MATRIX_MUL_H

#define MAX_ROW_A   4
#define MAX_COL_A   4
#define MAX_COL_B   4
#define MAX_NNZ_A   6
#define MAX_NNZ_B   7
#define MAX_NNZ_C   9

typedef int DTYPE;

typedef int data_t;
typedef int   idx_t;

void spmm_csr(
    idx_t RowA,
    idx_t ColA,
    idx_t ColB,

    idx_t RPA[MAX_ROW_A+1],
    idx_t CIA[MAX_NNZ_A],
    data_t NVA[MAX_NNZ_A],

    idx_t RPB[MAX_COL_A+1],
    idx_t CIB[MAX_NNZ_B],
    data_t NVB[MAX_NNZ_B],

    idx_t RPC[MAX_ROW_A+1],
    idx_t CIC[MAX_NNZ_C],
    data_t NVC[MAX_NNZ_C]
);

#endif
