#include <stdio.h>
#include <stdlib.h>
#include "Sparse_mul.h"


#define MAX_ROW_A   4
#define MAX_COL_A   4
#define MAX_COL_B   4
#define MAX_NNZ_A   6
#define MAX_NNZ_B   7
#define MAX_NNZ_C   9




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
)
{

    idx_t i, j, k, c;
    idx_t idxempty = 0;

    RPC[0] = 0;

ROW_LOOP:
    for (i = 0; i < RowA; i++) {

        data_t temp_row[MAX_COL_B];
#pragma HLS ARRAY_PARTITION variable=temp_row complete dim=1

        // initialize temp row
        for (c = 0; c < ColB; c++) {
#pragma HLS UNROLL
            temp_row[c] = 0;
        }

        idx_t rowA_start = RPA[i];
        idx_t rowA_end   = RPA[i+1];

    COL_LOOP_A:
        for (j = rowA_start; j < rowA_end; j++) {

#pragma HLS PIPELINE II=1

            idx_t colA = CIA[j];
            data_t valA = NVA[j];

            idx_t rowB_start = RPB[colA];
            idx_t rowB_end   = RPB[colA+1];

        COL_LOOP_B:
            for (k = rowB_start; k < rowB_end; k++) {

                idx_t colB = CIB[k];
                data_t valB = NVB[k];

                temp_row[colB] += valA * valB;
            }
        }

        // Compress into CSR (sorted automatically)
        for (c = 0; c < ColB; c++) {
            if (temp_row[c] != 0) {
                CIC[idxempty] = c;
                NVC[idxempty] = temp_row[c];
                idxempty++;
            }
        }

        RPC[i+1] = idxempty;
    }
}
