#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int factorial(int num) {
  if (num == 0 || num == 1) {
    return 1;
  } else {
    return num * factorial(num - 1);
  }
}
int main(int argc, char *argv[]) {
  int a = factorial(5);
  return a;
}
