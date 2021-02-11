#include <stdio.h>
#include <iostream>

int* arr = new int[30000]{0};
int now_arr_point = 0;
int now_file_point = 0;
char command;


FILE* file;

inline void Print(){
	printf("%d\n", arr[now_arr_point]);
}

inline void Input(){
	scanf("%d", &arr[now_arr_point]);
}

inline void GoWhileNot(char ch){
	command = getc(file);
	while(command != ch && !feof(file)){
		command = getc(file);
	}
}


void start(){
	int back_file_point = ftell(file);


	while(!feof(file)){
		command = getc(file);
		switch(command){
			case '.':
				Print();
				break;
			case ',':
				Input();
				break;
			case '+':
				arr[now_arr_point]++;
				break;
			case '-':
				arr[now_arr_point]--;
				break;
			case '<':
				now_arr_point++;
				break;
			case '>':
				now_arr_point--;
				break;
			case '[':
				if(arr[now_arr_point] == 0){
					GoWhileNot(']');
				}
				else {
					start();
					break;	
				} 
			case ']':
				if(arr[now_arr_point] != 0){
					fseek(file, back_file_point, 0);
					break;
				}
				else  
					return;
			case '#':
				GoWhileNot('\n');
				break;
			case '/':
				GoWhileNot('/');
				break;
		}
	}
}


int main(int size, char** args){
	if(size == 1)
		file = fopen("main.bf", "r");
	else 
		file = fopen(args[1], "r");
	start();
	fclose(file);
	return 0;
}