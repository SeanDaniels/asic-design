#include <stdio.h>
//#define DBG
#define MATRIX_A_ROW_SIZE 8
#define MATRIX_A_COL_SIZE 2
#define MATRIX_B_ROW_SIZE 2
#define MATRIX_B_COL_SIZE 8

int main(int argc, char *argv[]) {
    int matrix_a_row, matrix_a_col, matrix_b_row, matrix_b_col, i, j, k;
    matrix_a_row = MATRIX_A_ROW_SIZE;
    matrix_a_col = MATRIX_A_COL_SIZE;
    matrix_b_row = MATRIX_B_ROW_SIZE;
    matrix_b_col = MATRIX_B_COL_SIZE;

    if(matrix_a_row!=matrix_b_col){
        printf("Non-compatible matrix dimensions\n");
        return 0;
    }
    //matrix a is an 8x2 matrix
    int matrix_a[matrix_a_row][matrix_a_col];
    //matrix b is an 2x8 matrix
    int matrix_b[matrix_b_row][matrix_b_col];
    int matrix_c[matrix_a_row][matrix_b_col];

    for(i = 0; i < matrix_a_row; i++){
        for( j = 0; j < matrix_a_col; j++){
            matrix_a[i][j] = 4;
        }
    }
    for(i = 0; i < matrix_b_row; i++){
        for( j = 0; j < matrix_b_col; j++){
            matrix_b[i][j] = 4;
        }
    }
    for(i = 0; i < matrix_a_row; i++){
        for( j = 0; j < matrix_b_col; j++){
            matrix_c[i][j] = 0;
        }
    }

    //multiply matrix_a * matrix_b
    for(i = 0; i < matrix_a_row; i++){
        for(j = 0; j<matrix_b_col; j++){
            #ifdef DBG
            printf("Generating sum for matrix_c[%d][%d]\n", i, j);
            #endif
            for(k = 0; k < matrix_b_row; k++){
                #ifdef DBG
                printf("Multiplying matrix_a[%d][%d] and matrix_b[%d][%d]\n", i, j, j, k);
                #endif
                matrix_c[i][j] += matrix_a[i][k] * matrix_b[k][j];
            }
        }
    }

    printf("Result (Matrix C)\n");
    printf("------------------------\n");
    for (i = 0; i < matrix_a_row; i++) {
      for (j = 0; j < matrix_b_col; j++) {
        printf("|%d|", matrix_c[i][j]);
        if (j == matrix_b_col - 1) {
          printf("\n");
          printf("------------------------\n");
        }
      }
    }
    return 0;
}
