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
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
}

bool ProcessFlow::is_master() {
    return world_rank==MASTER_RANK;
}

bool ProcessFlow::check(int argc) {
    if (argc != 3) {
        process_log(
            "You must specify input matrix row by row and vector to compare to. Something like "
            "\"12,-32.04;4.03,905\" \"-13,0.01\""
        );
        return false;
    }
    if (world_size<2) {
        process_log("More then one process must be created");
        return false;
    }

    process_log("Number of processes: %d", world_size);
    
    return true;
}

void ProcessFlow::displace_get(int *data_per_process, int *displacement) {
    int min = matrix_rows / world_size,
        extra = matrix_rows % world_size,
        k = 0;
    
    for (int i = 0; i < world_size; i++) {
        data_per_process[i] = min;
        if (i < extra) {
            data_per_process[i] += 1;
        }
        
        data_per_process[i] *= matrix_cols;
        
        displacement[i] = k;
        k += data_per_process[i];
    }
}

void ProcessFlow::scalar_product(float const *vectors, int size, float *scalar_product) {
    int vectors_count=size/matrix_cols;
    
    vector<float> temp_vector(matrix_cols);
    for (int i = 0; i < vectors_count; i++) {
        temp_vector[0]=vectors[i * matrix_cols];
        scalar_product[i]=std::inner_product(temp_vector.begin(), temp_vector.end(), compare_vector.begin(), 0);
    
        process_log(world_rank, "Scalar product for row %d is %f.", world_rank+i, scalar_product[i]);
    }
}

bool ProcessFlow::run(int argc, char** argv) {
    int data_per_process[world_size], 
        displacement[world_size];
    
    if (is_master()) {
        if (!check(argc)) {
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        
        parse_input(argv[1], argv[2]);
    
        process_log("Matrix has %d rows and %d columns", matrix_rows, matrix_cols);
    }
    
    MPI_Bcast(&matrix_rows, 1, MPI_INT, MASTER_RANK, MPI_COMM_WORLD);
    MPI_Bcast(&matrix_cols, 1, MPI_INT, MASTER_RANK, MPI_COMM_WORLD);
    if (!is_master()) {
        compare_vector.resize(matrix_cols);
    }
    MPI_Bcast(&compare_vector[0], matrix_cols, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    displace_get(data_per_process,displacement);
    int rows_length=data_per_process[world_rank];
    float rows[rows_length];
    
    process_log(world_rank, "Will receive %d values starting from offset %d", data_per_process[world_rank], 
            displacement[world_rank]);
    
    if (data_per_process[world_rank]==0) {
        process_log(world_rank, "Stopping process. Not enough data.");
        return true;
    }
    
    MPI_Scatterv(matrix.data(), data_per_process, displacement, MPI_FLOAT, 
            rows, rows_length, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    process_log(world_rank, "Received its data part.");
    
    float product_result[rows_length/matrix_cols];
    scalar_product(rows, rows_length, product_result);
}

void ProcessFlow::parse_input(const char* string_matrix, const char* string_vector) {
    matrix_rows=0;
    
    string temp_matrix(string_matrix);
    stringstream ss1(temp_matrix);
    string temp_row, number;
    while (getline(ss1, temp_row, ';')) {
        matrix_rows++;
        matrix_cols=0;
        stringstream ss2(temp_row);
        while (getline(ss2, number, ',')) {
            matrix_cols++;
            matrix.push_back(atof(number.c_str()));
        }
    }
    
    temp_row.assign(string_vector);
    stringstream ss3(temp_row);
    while (getline(ss3, number, ',')) {
        compare_vector.push_back(atof(number.c_str()));
    }
}