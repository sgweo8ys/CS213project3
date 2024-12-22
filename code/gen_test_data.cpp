#include <cstdio>
#include <ctime>
#include <cstdlib>
int main()
{
    srand((int)time(0));
    freopen("tu1.csv", "w", stdout);
    puts("id,name,value");
    int n = 100000;
    for(int i = 1; i <= n; i++){
        char s[30];
        for(int j = 0; j < 20; j++) s[j] = rand() % 26 + 'a';
        printf("%d,", i);
        for(int j = 0; j < 20; j++) printf("%c",s[j]);
        printf(",%d\n",rand() % 300);
    }
    return 0;
}