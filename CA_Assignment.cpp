#include <stdio.h>
#include <stdint.h>

static inline int my_clz(uint32_t x) {
    int count = 0;
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}

int findMaxConsecutiveOnes(int* nums, int numsSize) {
    int maxCount = 0;
    int currentCount = 0;
    int wordSize = 32;
    int set = (numsSize >> 5) << 5;

    if (numsSize == 0)
        return 0;

    for (int i = set; i >= 0; i -= wordSize) {
        uint32_t packed = 0;

        //Pack 32 bits into an unsigned interger
        for (int j = 0; j < wordSize && i + j < numsSize; j++) {
            packed |= ((uint32_t)nums[i + j] << j);
        }

        if (packed == 0xFFFFFFFF) {
            currentCount += wordSize;
        }
        else {
            int counter = 32;
            while (counter > 0) {
                int leadingZeros = my_clz(packed);
                packed <<= leadingZeros;
                counter -= leadingZeros;

                if (leadingZeros != 0) {
                    if (currentCount > maxCount)
                        maxCount = currentCount;
                    currentCount = 0;
                }
                else {
                    currentCount++;
                    packed <<= 1;
                    counter--;
                }
            }
        }
    }

    if (currentCount > maxCount)
        maxCount = currentCount;

    return maxCount;
}

int main() {

    int nums1[] = { 1, 1, 0, 1, 1, 1 };
    int numsSize1 = sizeof(nums1) / sizeof(nums1[0]);
    int result1 = findMaxConsecutiveOnes(nums1, numsSize1);
    printf("Maximum number of consecutive 1's: %d\n", result1);

    int nums2[] = { 1, 0, 1, 1, 0, 1 };
    int numsSize2 = sizeof(nums2) / sizeof(nums2[0]);
    int result2 = findMaxConsecutiveOnes(nums2, numsSize2);
    printf("Maximum number of consecutive 1's: %d\n", result2);

    int nums3[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
    int numsSize3 = sizeof(nums3) / sizeof(nums3[0]);
    int result3 = findMaxConsecutiveOnes(nums3, numsSize3);
    printf("Maximum number of consecutive 1's: %d\n", result3);

    return 0;
}
