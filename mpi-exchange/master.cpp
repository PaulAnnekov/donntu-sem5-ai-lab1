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
    int size,next_rank=1,vector_index=0;
    MPI_Request req;
    MPI_Status status;
    
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    if (argc != 2) {
        process_log("You must specify input vectors. Smth like 12,-32.04;4.03,905");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }
    if (size<2) {
        process_log("More then one process must be created");
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
    }
    
    process_log("Number of processes: %d", size);
    
    parse_input(argv[1],vectors);
    
    for (vector<float> &single_vector : vectors) {
        process_log("Send vector #%d to process #%d", vector_index, next_rank);
        
        MPI_Isend(single_vector.data(), single_vector.size(), MPI_FLOAT, next_rank, vector_index, MPI_COMM_WORLD, &req);
        MPI_Request_free(&req);
        
        // Get next process from current communicator excluding master process.
        vector_index++;
        next_rank = vector_index % (size - 1) + 1;
    }
    
    while(vector_index>0) {
        vector<float> float_vector = mpi_receive_vector(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
        process_log("Has got result vector #%d from process #%d", status.MPI_TAG, status.MPI_SOURCE);
        
        vector_index--;
    }
}