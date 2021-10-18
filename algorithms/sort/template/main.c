#include <stdio.h>
#include <stdbool.h>
#include <assert.h>


int unsorted0[] = {91, 39, 99, 66, 95, 65, 61, 49, 79, 18, 78, 35, 58, 29, 88};
int sorted0[]   = {18, 29, 35, 39, 49, 58, 61, 65, 66, 78, 79, 88, 91, 95, 99};
int unsorted1[] = {50, 87, 16, 12, 96, 15, 12, 33, 96, 10, 82, 61, 65, 51, 87};
int sorted1[]   = {10, 12, 12, 15, 16, 33, 50, 51, 61, 65, 82, 87, 87, 96, 96};
int unsorted2[] = {17, 91, 42, 42, 76, 46, 15, 33, 19, 39, 11, 70, 20, 48, 5};
int sorted2[]   = {5, 11, 15, 17, 19, 20, 33, 39, 42, 42, 46, 48, 70, 76, 91};
int unsorted3[] = {61, 17, 71, 17, 57, 99, 19, 86, 71, 26, 74, 1, 65, 3, 4};
int sorted3[]   = {1, 3, 4, 17, 17, 19, 26, 57, 61, 65, 71, 71, 74, 86, 99};
int unsorted4[] = {29, 65, 0, 45, 20, 92, 30, 86, 34, 61, 41, 5, 97, 92, 25};
int sorted4[]   = {0, 5, 20, 25, 29, 30, 34, 41, 45, 61, 65, 86, 92, 92, 97};

bool cmplist(int list1[], int list1len, int list2[], int list2len){
    if (list1len != list2len) {
        return false;
    }
    for(int i=0; i < list1len; i++){
        if(list1[i] != list2[i]) {
            return false;
        }
    }
    return true;
}

void printlist(int list[], int listlen) {
    for(int i=0; i < listlen; i++){
        printf("%d,", list[i]);
    }
    printf("\n");
}

int main(void) {

    printlist(unsorted0, sizeof(unsorted0)/sizeof(unsorted0[0]));
    printlist(sorted0, sizeof(sorted0)/sizeof(sorted0[0]));
    assert(cmplist(unsorted0, sizeof(unsorted0)/sizeof(unsorted0[0]), sorted0, sizeof(unsorted0)/sizeof(sorted0[0])));
    assert(cmplist(unsorted1, sizeof(unsorted1)/sizeof(unsorted1[0]), sorted1, sizeof(unsorted1)/sizeof(sorted1[0])));
    assert(cmplist(unsorted2, sizeof(unsorted2)/sizeof(unsorted2[0]), sorted2, sizeof(unsorted2)/sizeof(sorted2[0])));
    assert(cmplist(unsorted3, sizeof(unsorted3)/sizeof(unsorted3[0]), sorted3, sizeof(unsorted3)/sizeof(sorted3[0])));
    assert(cmplist(unsorted4, sizeof(unsorted4)/sizeof(unsorted4[0]), sorted4, sizeof(unsorted4)/sizeof(sorted4[0])));

    printf("Done!\n");
    return 0;
}
