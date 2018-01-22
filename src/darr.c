
#include "darr.h"

Array* array_new(size_t init_size, size_t increment, size_t type_size) {
	Array* arr = malloc(sizeof(Array));
	if(arr == 0)
		return 0;
	arr->size = 0;
	arr->cap = init_size;
	arr->increment = increment;
	arr->type_size = type_size;
	arr->data = malloc(init_size * sizeof(void*));
	if(arr->data == 0) {
		free(arr);
		return 0;
	}
	return arr;
}
