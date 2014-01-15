#include "lib.hpp"

#include <cstdlib>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <mpi.h>
#include <algorithm>

using namespace std;

/**
 * Converts human-readable representation of list of vectors to std::vector of vectors.
 * 
 * @param string_vectors String that stores list of vectors in the following format: x1,y1,...;x2,y2,...;...
 * @return Vector of vectors.
 */
vector< vector<float> > parse_input(const char* string_vectors) {
    vector< vector<float> > vectors;
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
    
    return vectors;
}

/**
 * Calculates vectors sum.
 * 
 * @param vectors Vector of vectors to sum.
 * @return Sum of input vectors.
 */
vector<float> vector_sum(vector< vector<float> > &vectors) {
    vector<float> sum(vectors[0].size(), 0);
    for (vector<float> &single_vector : vectors) {
        std::transform(single_vector.begin(), single_vector.end(), sum.begin(), sum.begin(), std::plus<float>());
    }
    
    return sum;
}

/**
 * Converts std::vector to human-readable std::string.
 * 
 * @param input_vector Vector to convert.
 * @return Human-readable vector representation.
 */
string vector_to_human(vector<float> &input_vector) {
    string output;
    for (float &value : input_vector) {
        output.append(std::to_string(value) + ";");
    }
    
    return output;
}

void start_master(int argc, char **argv) {
    vector< vector<float> > input_vectors, output_vectors;
    int size, next_rank = 1, vector_index = 0;
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
    
    input_vectors=parse_input(argv[1]);
    
    for (vector<float> &single_vector : input_vectors) {
        process_log("Send vector #%d to process #%d", vector_index, next_rank);
        
        MPI_Isend(single_vector.data(), single_vector.size(), MPI_FLOAT, next_rank, vector_index+MPIE_TAG_OFFSET, 
                MPI_COMM_WORLD, &req);
        MPI_Request_free(&req);
        
        // Get next process from current communicator excluding master process.
        vector_index++;
        next_rank = vector_index % (size - 1) + 1;
    }
    
    while(vector_index>0) {
        output_vectors.push_back(mpi_receive_vector(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status));
        process_log("Has got result vector #%d from process #%d", status.MPI_TAG-MPIE_TAG_OFFSET, status.MPI_SOURCE);
        
        vector_index--;
    }
    
    vector<float> sum=vector_sum(output_vectors);
    process_log("Result: " + vector_to_human(sum));
    
    int data=1;
    for (int i = 1; i < size; i++) {
        MPI_Send(&data, 1, MPI_INT, i, MPIE_TAG_FINALIZE, MPI_COMM_WORLD);
    }
}