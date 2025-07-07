/*
 * File: out_of_bounds.c
 *
 * Description: Programa que recibe un segmentation fault al acceder a un índice no válido de un array
 *
 * Author:  Intro_SW
 * Version: 2020
 *
*/

#include <stdio.h>

#define ROWS    5
#define COLUMNS 250

int search_matrix (int matrix[ROWS][COLUMNS]);

int main (void) {

    // Declaracion de variables
    int matrix[ROWS][COLUMNS];
    int counter = search_matrix (matrix);

    // Mostramos resultados por pantalla
    printf ("%d", counter);
    return 0;
}

int search_matrix (int matrix[ROWS][COLUMNS]) {
    int counter = 0;
    
    // Bucle para recorrer el array 
    for (int i = 0; i < COLUMNS; i++) {     // Error
        for (int j = 0; j < COLUMNS; j++) {
            if (matrix[i][j] == 1) {        // Segmentation fault
                counter++;
            }
        }
    }
    return counter;    
}
