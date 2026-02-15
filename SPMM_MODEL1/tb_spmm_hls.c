#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "Sparse_mul.h"

#define MAX_ROW_A   4
#define MAX_COL_A   4
#define MAX_COL_B   4
#define MAX_NNZ_A   6
#define MAX_NNZ_B   7
#define MAX_NNZ_C   9

// Forward declaration (optional if already in header)
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

int main() {

    idx_t RowA = 4;
    idx_t ColA = 4;
    idx_t ColB = 4;

    // ===== Matrix A (CSR) =====
    idx_t RPA[5] = {0,2,3,5,6};
    idx_t CIA[6] = {0,2,1,0,3,2};
    data_t NVA[6] = {1,2,3,4,5,6};

    // ===== Matrix B (CSR) =====
    idx_t RPB[5] = {0,2,3,5,7};
    idx_t CIB[7] = {0,3,1,0,2,1,3};
    data_t NVB[7] = {7,8,9,10,11,12,13};

    // ===== Output Matrix C (CSR) =====
    idx_t RPC[5];
    idx_t CIC[9];
    data_t NVC[9];

    // Initialize output
    memset(RPC, 0, sizeof(RPC));
    memset(CIC, 0, sizeof(CIC));
    memset(NVC, 0, sizeof(NVC));

    // Call accelerator function
    spmm_csr(
        RowA, ColA, ColB,
        RPA, CIA, NVA,
        RPB, CIB, NVB,
        RPC, CIC, NVC
    );

    printf("\n=== CSR Output ===\n");

    int i, j;

    printf("RPC: ");
    for(i = 0; i <= RowA; i++)
        printf("%d ", RPC[i]);
    printf("\n");

    printf("CIC: ");
    for(i = 0; i < RPC[RowA]; i++)
        printf("%d ", CIC[i]);
    printf("\n");

    printf("NVC: ");
    for(i = 0; i < RPC[RowA]; i++)
        printf("%.1f ", NVC[i]);
    printf("\n");

    // ===== Convert to Dense for Verification =====
    data_t C_dense[4][4];

    // Initialize dense matrix
    for(i = 0; i < 4; i++)
        for(j = 0; j < 4; j++)
            C_dense[i][j] = 0;

    for(i = 0; i < RowA; i++) {
        for(j = RPC[i]; j < RPC[i+1]; j++) {
            C_dense[i][CIC[j]] = NVC[j];
        }
    }

    printf("\n=== Dense Matrix C ===\n");
    for(i = 0; i < 4; i++) {
        for(j = 0; j < 4; j++) {
            printf("%6.1f ", C_dense[i][j]);
        }
        printf("\n");
    }

    return 0;
}
