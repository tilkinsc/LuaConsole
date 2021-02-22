/* MIT License
 * 
 * Copyright (c) 2017-2021 Cody Tilkins
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
#pragma once

#include <stdlib.h>
#include <string.h>


typedef struct tagArray {
	size_t size;
	size_t cap;
	size_t increment;
	void** data;
} Array;



static inline Array* array_new(size_t init_size, size_t increment) {
	Array* arr = malloc(sizeof(Array));
	if(arr == 0)
		return 0;
	arr->size = 0;
	arr->cap = init_size;
	arr->increment = increment;
	arr->data = malloc(init_size * sizeof(void*));
	if(arr->data == 0) {
		free(arr);
		return 0;
	}
	return arr;
}

static inline void array_free(void* arr) {
	if(arr == 0)
		return;
	Array* a = (Array*) arr;
	free(a->data);
	free(a);
}


static int array_ensure_size(Array* arr, size_t size) {
	if(arr->size + size >= arr->cap) {
		arr->data = realloc(arr->data, (arr->cap + arr->increment) * sizeof(void*));
		if(arr->data == 0)
			return 0;
		arr->cap += arr->increment * ((((arr->size + size) - arr->cap) % arr->increment) + 1);
	}
	return 1;
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


static inline void array_consume(Array* arr, void (*consumer)(Array*, void*)) {
	for(size_t i=0; i<arr->size; i++)
		consumer(arr, array_get(arr, i));
}

