#include <features.h>
#include <stdio.h>

int main()
{
  printf("%d.%d", __GLIBC__, __GLIBC_MINOR__);
  return 0;
}
