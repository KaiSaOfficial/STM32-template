#include "thread.h"

/* Dimensions of the buffer that the task being created will use as its stack.
NOTE:  This is the number of words the stack will hold, not the number of
bytes.  For example, if each stack item is 32-bits, and this is set to 100,
then 400 bytes (100 * 32-bits) will be allocated. */
#define STACK_SIZE 200

/* Structure that will hold the TCB of the task being created. */
StaticTask_t xTaskBuffer;

/* Buffer that the task being created will use as its stack.  Note this is
an array of StackType_t variables.  The size of StackType_t is dependent on
the RTOS port. */
StackType_t xStack[STACK_SIZE];

StaticTask_t xTaskBuffer2;

StackType_t xStack2[STACK_SIZE];

/* Function that implements the task being created. */
void task1(void* pvParameters) {
    for (;; ) {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_0);
        vTaskDelay(1000);
        /* Task code goes here. */
    }
}

void task2(void* pvParameters) {
    for (;; ) {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_1);
        vTaskDelay(700);
        /* Task code goes here. */
    }
}

/* Function that creates a task. */
void create_task(void) {
    TaskHandle_t xHandle1 = NULL;
    TaskHandle_t xHandle2 = NULL;

    /* Create the task without using any dynamic memory allocation. */
    xHandle1 = xTaskCreateStatic(
        (void*)task1,       /* Function that implements the task. */
        "task",             /* Text name for the task. */
        STACK_SIZE,         /* Number of indexes in the xStack array. */
        NULL,               /* Parameter passed into the task. */
        100,                /* Priority at which the task is created. */
        xStack,             /* Array to use as the task's stack. */
        &xTaskBuffer);      /* Variable to hold the task's data structure. */

    xHandle2 = xTaskCreateStatic(
        (void*)task2,       /* Function that implements the task. */
        "task2",            /* Text name for the task. */
        STACK_SIZE,         /* Number of indexes in the xStack array. */
        NULL,               /* Parameter passed into the task. */
        100,                /* Priority at which the task is created. */
        xStack2,            /* Array to use as the task's stack. */
        &xTaskBuffer2);     /* Variable to hold the task's data structure. */

    if (xHandle1 == NULL || xHandle2 == NULL)
        return;
}
