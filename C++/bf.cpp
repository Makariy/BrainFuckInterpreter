#include <iostream>
#include <fstream>

int* arr = new int[30000]{0};
int now_point = 0;
int now_file_point = 0;

std::fstream file;

void Print(){
	std::cout << arr[now_point] << std::endl;
}

void Input(){
	std::cin >> arr[now_point];
}

void GoCycleEnd(){
	char command = '\0';
	while(file >> command && command != ']'){}
}


int main(int size, char** file_name){
	if(size)
		file.open("main.bf");
	else 
		file.open(file_name[0]);

	char command;
	while(file >> command){
		switch(command){
			case '.':
				Print();
				break;
			case ',':
				Input();
				break;
			case '+':
				arr[now_point]++;
				break;
			case '-':
				arr[now_point]--;
				break;
			case '<':
				now_point++;
				break;
			case '>':
				now_point--;
				break;
			case '[':
				if(arr[now_point] == 0)
					GoCycleEnd();
				else now_file_point = int(file.tellg())-1;
				break;
			case ']':
				file.seekg(now_file_point, std::ios::beg);
				break;
		}
	}
}