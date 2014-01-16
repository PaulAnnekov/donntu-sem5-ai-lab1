#include "lib.hpp"
#include "process_flow.hpp"

#include <cstdlib>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <mpi.h>
#include <algorithm>

#define MASTER_RANK 0

using namespace std;

ProcessFlow::ProcessFlow() {
    MPI_Comm_size(MPI_COMM_WORLD, &this->world_size);
    MPI_Comm_rank(MPI_COMM_WORLD, &this->world_rank);
}

bool ProcessFlow::is_master() {
    return this->world_rank==MASTER_RANK;
}

bool ProcessFlow::check(int argc) {
    if (argc != 2) {
        process_log("You must specify input matrix row by row. Smth like 12,-32.04;4.03,905");
        return false;
    }
    if (this->world_size<2) {
        process_log("More then one process must be created");
        return false;
    }

    process_log("Number of processes: %d", this->world_size);
    
    return true;
}

int ProcessFlow::rows_per_process(int total_rows) {
    if (total_rows > this->world_size) {
        return (total_rows + this->world_size - 1) / this->world_size;
    } else {
        return 1;
    }
}

bool ProcessFlow::run(int argc, char** argv) {
    binary_matrix matrix;
    int cols_data[2];
    
    if (this->is_master()) {
        if (!check(argc)) {
            return false;
        }
        
        matrix=parse_input(argv[1]);
        cols_data[0]=matrix.cols;
        cols_data[1]=rows_per_process(matrix.rows);
    
        process_log("Each process will receive %d rows with %d columns", cols_data[1], cols_data[0]);
    }
    
    MPI_Bcast(cols_data, 2, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    int input_size=cols_data[0]*cols_data[1];
    float rows[input_size];
    
    int res=MPI_Scatter(matrix.data.data(), input_size, MPI_FLOAT, rows, input_size, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    if (rows == NULL) {
        process_log(this->world_rank, "Not enough data for this process. Exit.");
    } else {
        process_log(this->world_rank, "Received its data part. %d", res);
    }
}

/**
 * Converts human-readable representation of matrix to structure.
 * 
 * @param string_vectors String that stores list of rows in the following format: x1,y1,...;x2,y2,...;...
 * @return Matrix structure.
 */
ProcessFlow::binary_matrix ProcessFlow::parse_input(const char* string_vectors) {
    binary_matrix matrix;
    int cols=0;
    string data(string_vectors);

    stringstream ss1(data);
    matrix.rows=0;
    
    string string_vector, number;
    while (getline(ss1, string_vector, ';')) {
        matrix.rows++;
        cols=0;
        stringstream ss2(string_vector);
        while (getline(ss2, number, ',')) {
            cols++;
            matrix.data.push_back(atof(number.c_str()));
        }
    }
    matrix.cols=cols;
    
    return matrix;
}