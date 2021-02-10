#include <stdio.h>

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

inline void GoCycleEnd(){
	while(getc(file) >> command && command != ']'){}
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
					GoCycleEnd();
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