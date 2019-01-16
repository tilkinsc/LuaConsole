
#pragma once

#include "darr.h"

typedef struct LangCache {
	size_t indices;
	Array* lines;
	char* buffer;
} LangCache;


static inline LangCache* langfile_load(const char* path) {
	
	FILE* fp;
	fp = fopen(path, "rb");
	if(fp == 0) {
		fprintf(stderr, "%s %s!\n", "Couldn't open file", path);
		return 0;
	}
	
	fseek(fp, 0, SEEK_END);
	long size = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	
	LangCache* lc = malloc(1 * sizeof(LangCache));
	if(lc == 0) {
		fputs("Out of memory!\n", stderr);
		return 0;
	}
	
	char* buffer = malloc(size * sizeof(char) + 1);
	if(buffer == 0) {
		fputs("Out of memory!\n", stderr);
		return 0;
	}
	fread(buffer, size, 1, fp);
	fclose(fp);
	buffer[size] = 0;
	lc->buffer = buffer;
	
	Array* array = array_new(10, 1, sizeof(char*));
	if(array == 0) {
		fputs("Out of memory!\n", stderr);
		return 0;
	}
	lc->lines = array;
	
	size_t indices = 0;
	char* begin = buffer;
	char* ch = buffer;
	while(*ch != '\0') {
		if (*ch == '\\') {
			*ch = '\n';
			ch++;
			continue;
		}
		if (*ch == '\n') {
			if(ch - begin > 1) {
				array_push(array, begin);
				indices++;
			}
			begin = ch + 1;
			*ch = 0;
			ch++;
			continue;
		}
		ch++;
	}
	lc->indices = indices;
	
	return lc;
}

static inline const char* langfile_get(LangCache* lc, const char* key) {
	for(size_t i=0; i<lc->indices; i++) {
		char* current = (char*) array_get(lc->lines, i);
		if(memcmp(current, key, strlen(key)) == 0) {
			while(*current++ != '=');
			return current;
		}
	}
	return 0;
}

static inline void langfile_free(void* lc) {
	free((LangCache*) lc);
}

