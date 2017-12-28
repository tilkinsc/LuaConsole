
#pragma once

#include <stdlib.h>
#include <string.h>

typedef struct tagArray {
	size_t size;
	size_t cap;
	size_t increment;
	size_t type_size;
	void** data;
} Array;


static int array_ensure_size(Array* arr, size_t size) {
	if(arr->size + size >= arr->cap) {
		arr->data = realloc(arr->data, (arr->cap + arr->increment) * sizeof(void*));
		if(arr->data == 0)
			return 0;
		arr->cap += arr->increment * ((((arr->size + size) - arr->cap) % arr->increment) + 1);
	}
	return 1;
}


Array* array_new(size_t init_size, size_t increment, size_t type_size);

static inline void array_free(void* arr) {
	Array* a = (Array*) arr;
	free(a->data);
	free(a);
}


static inline int array_push(Array* arr, void* data) {
	if(array_ensure_size(arr, 1) == 0)
		return 0;
	arr->data[arr->size++] = data;
	return 1;
}

static inline int array_pushback(Array* arr, void* data, size_t index) {
	if(array_ensure_size(arr, 1) == 0)
		return 0;
	memmove(arr->data + index + 1, arr->data + index, arr->size - index);
	arr->data[index] = data;
	arr->size++;
	return 1;
}


static inline void* array_rem(Array* arr, size_t index) {
	if(index >= arr->size)
		return 0;
	if(arr->size == 0)
		return 0;	
	void* mem = arr->data[index];
	memmove(arr->data + index, arr->data + index + 1, arr->size - (index + 1));
	arr->size--;
	return mem;
}


static inline void* array_set(Array* arr, void* data, size_t index) {
	if(index >= arr->size)
		return 0;
	void* mem = arr->data[index];
	arr->data[index] = data;
	return mem;
}

static inline void* array_get(Array* arr, size_t index) {
	if(index >= arr->size)
		return 0;
	return arr->data[index];
}


static inline void array_consume(Array* arr, void (*consumer)(void*)) {
	for(size_t i=0; i<arr->size; i++)
		consumer(array_get(arr, i));
}

