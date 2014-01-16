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

void ProcessFlow::displace_get(int rows_count, int cols_count, int *send_count, int *displacement) {
    int min = rows_count / this->world_size,
        extra = rows_count % this->world_size,
        k = 0;
    
    for (int i = 0; i < this->world_size; i++) {
        send_count[i] = min;
        if (i < extra) {
            send_count[i] += 1;
        }
        
        send_count[i] *= cols_count;
        
        displacement[i] = k;
        k = k+send_count[i];
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
        cols_data[1]=matrix.rows;
    
        process_log("Matrix has %d rows and %d columns", cols_data[1], cols_data[0]);
    }
    
    MPI_Bcast(cols_data, 2, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    int send_count[this->world_size], displacement[this->world_size];
    displace_get(cols_data[1],cols_data[0],send_count,displacement);
    float rows[send_count[this->world_rank]];
    
    process_log(this->world_rank, "Will receive %d values starting from offset %d", send_count[this->world_rank], 
            displacement[this->world_rank]);
    
    if (send_count[this->world_rank]==0) {
        process_log(this->world_rank, "Stopping process. Not enough data.");
        return true;
    }
    
    MPI_Scatterv(matrix.data.data(), send_count, displacement, MPI_FLOAT, rows, send_count[this->world_rank], 
            MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    process_log(this->world_rank, "Received its data part.");
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