#include "lib.hpp"

#include <cstdlib>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <mpi.h>

using namespace std;

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

void start_master(int argc, char **argv) {
    vector< vector<float> > vectors;
    int size;
    
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    if (argc != 2) {
        log("You must specify input vectors. Smth like 12,-32.04;4.03,905");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }
    if (size<2) {
        log("More then one process must be created");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }
    
    parse_input(argv[1],vectors);

    // TODO: Send vectors to processes.
}