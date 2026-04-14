#include<stdio.h>
#include<stdlib.h>
#include<dlfcn.h>
#include<string.h>
typedef int(*fptr)(int,int);
int main()
{
    char operation[6];
    int num1,num2;
    char lib_path[32];
    while (scanf("%s%d%d",operation,&num1,&num2)==3) {
        strcpy(lib_path,"./lib");
        strcat(lib_path,operation);
        strcat(lib_path,".so");
        
        void *handle = dlopen(lib_path,RTLD_LAZY);
        fptr func = (fptr) dlsym(handle,operation);
        
        printf("%d\n",func(num1,num2));

        dlclose(handle);
    }
    return 0;

}