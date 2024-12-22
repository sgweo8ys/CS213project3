#include <cstdio>
int main()
{
    freopen("test.out", "w", stdout);
    int n = 1000;
    printf("begin;\n"
           "explain analyse insert into test values\n");
    for(int i = 1; i <= n; i++){
        printf("(%d,'cstowonethree',%d)", i, i % 300);
        if(i < n) printf(",\n");
        else printf(";\n");
    }
    printf("rollback;\n");
}