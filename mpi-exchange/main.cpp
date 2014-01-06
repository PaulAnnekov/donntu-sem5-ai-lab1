#include <cstdlib>
#include <cstdio>
#include <mpich2/mpi.h>
#include <algorithm>
#include <vector>
#include <string>
#include <sstream>

int main(int argc, char** argv) {
    if (argc != 2)
        return 0;
    
    std::string data (argv[1]);
    std::vector<float> vectors[2];
    int current=0;
    
    std::stringstream ss1(data);
    std::string vector, number;
    while (std::getline(ss1, vector, ';') && current < 2) {
        std::stringstream ss2(vector);
        while (std::getline(ss2, number, ',')) {
            vectors[current].push_back(atof(number.c_str()));
        }
        current++;
    }

    return 0;
}