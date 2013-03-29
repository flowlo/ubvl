#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

size_t asmb(char *s, size_t n);
size_t asmb_callchecking(char *s, size_t n);

size_t asmb_ref(char *s, size_t n)
{
  size_t c=0;
  size_t i;
  for (i=0; i<n; i++) {
    if (s[i]==' ')
      c++;
  }
  return c;
}

void printchar(char c)
{
  if (c<' ' || c>126 || c=='"')
    printf("\\x%02x",c);
  else
    putchar(c);
}

void printarray(char* bufstart, size_t buflength, char* s, size_t l)
{
  int i;
  char *p=s-16;
  unsigned long pl;
  if (p<bufstart)
    p=bufstart;
  pl=s+l+16-p;
  if (p+pl>bufstart+buflength)
    pl=bufstart+buflength-p;
  printf("%p=",p);
  for(i=0; ;i++) {
    if(p+i==s)
      printf("\"");
    if (p+i==s+l)
      printf("\"");
    if (!(i<pl))
      break;
    printchar(p[i]);
  }
  printf("\n");
}


int test(char *s, size_t offset, size_t len)
/* s ist der Originalstring; offset gibt an, wo im Originalstring der
   Teststring beginnen soll; len ist die Laenge des Teststrings;
   returns 0 on error and 1 on success
*/
{
  unsigned long l=offset+len;
  char stmp[l+16];
  char utmp[l+16];
  size_t r, orig_r;

  memcpy(stmp,s,l+16);
  memcpy(utmp,stmp,l+16);
  printf("\nCalling asmb(%p, %ld) with\n",stmp+offset, len);
  printarray(stmp,l,stmp+offset,len);
  orig_r=asmb_ref(utmp+offset,len);
  r=asmb_callchecking(stmp+offset,len);
  printf("Result=%ld\n", r);
  if (r!=orig_r) {
    printf("[Error] return value wrong. Expected: %ld\n",orig_r);
    return 0;
  }
  if (memcmp(stmp,s,l+16)!=0) {
    printf("[Error] input string modified\n");
    return 0;
  } else {
    printf("succeeded\n");
    return 1;
  }
}   
  
  

int main(int argc, char **argv)
{
  int success=1;
  int i,j;

  char *x=" \0 !  !!   !!!    !!!!     !!!!!      !!!!!!       !!!!!!!        !!!!!!!!         !!!!!!!!!";
  size_t sizes[]={0,1,14,15,16,17,31,32,33,-1};

  for(i=0; i<16;i+=3)
    for (j=0; sizes[j]!=-1; j++)
      success &= test(x,i,sizes[j]);

  if (!success)
    fprintf(stdout,"\nTest failed.\n");
  else
    fprintf(stdout,"\nTest succeeded.\n");
  return !success;
}
