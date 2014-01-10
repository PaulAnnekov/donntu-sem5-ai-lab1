#include "main.hpp"

#include <cstdlib>
#include <cstdio>
#include <mpich2/mpi.h>
#include <algorithm>
#include <string>
#include <sstream>
#include <vector>

using namespace std;

int main(int argc, char** argv) {
    if (argc != 2)
        return 0;

    int rank;
    vector< vector<float> > vectors;
    parse_input(argv[1],vectors);
    
    MPI_Init(&argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    
    MPI_Finalize();
    
    return 0;
}

void parse_input(const char* string_vectors, vector< vector<float> > &vectors) {
    string data(string_vectors);

    stringstream ss1(data);
    string string_vector, number;
    while (getline(ss1, string_vector, ';')) {
        stringstream ss2(string_vector);
        vectors.push_back(vector<float>());
        while (getline(ss2, number, ',')) {
            vectors[vectors.size()-1].push_back(atof(number.c_str()));
        }
    }
}