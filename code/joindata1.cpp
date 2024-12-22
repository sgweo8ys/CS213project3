// joindata1.cpp
#include <cstdio>
#include <ctime>
#include <cstdlib>
int main()
{
    srand((int)time(0));
    freopen("jointest1.csv", "w", stdout);
    int n = 100000;
    puts("id1,name,grp");
    for(int i = 1; i <= n; i++){
        char s[30];
        for(int j = 0; j < 20; j++) s[j] = rand() % 26 + 'a';
        printf("%d,", i);
        for(int j = 0; j < 20; j++) printf("%c",s[j]);
        printf(",%d\n", i / 3);
    }
    return 0;
}