/*
 * File: segfault.c
 *
 * Description: Simple program to raise a segmentation fault
 *
 * Author:  Intro_SW <>
 * Version: 1.0
 *
*/

#include <stdio.h>

// Prototypes for testing
void baz();
void foo();
void bar();

void baz() {
    int *foo = (int *) -1;       // declare a pointer to a bad memory address
    printf ("%d\n", *foo);       // causes a segmentation fault
}

void bar() { 
    baz(); 
}
void foo() { 
    bar(); 
}

int main (void) {
    printf ("Starting program...\n");
    foo();
    printf ("Never getting here\n");
}
