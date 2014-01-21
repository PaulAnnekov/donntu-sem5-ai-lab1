#include "lib.hpp"
#include "process_flow.hpp"

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

string ProcessFlow::vector_to_human(vector<float> &input_vector) {
    string output;
    for (float &value : input_vector) {
        output.append(std::to_string(value) + ";");
    }
    
    return output;
}

void ProcessFlow::get_rows_per_process(int *rows_per_process) {
    int min = matrix_rows / world_size,
        extra = matrix_rows % world_size;
    
    for (int i = 0; i < world_size; i++) {
        rows_per_process[i] = min;
        if (i < extra) {
            rows_per_process[i] += 1;
        }
    }
}

void ProcessFlow::get_displace(int const *rows_per_process, int size, int *data_per_process, int *displacement) {
    int k = 0;
    
    for (int i = 0; i < world_size; i++) {
        data_per_process[i] = rows_per_process[i] * size;
        
        displacement[i] = k;
        k += data_per_process[i];
    }
}

vector< vector<float> > ProcessFlow::array_to_vector(float const *array, int count, int total) {
    vector< vector<float> > output_vector;
    
    for (int i = 0; i < total; i++) {
        vector<float> temp_vector(array + i * count, array + i * count + count);
        output_vector.push_back(temp_vector);
    }
    
    return output_vector;
}

vector<float> ProcessFlow::scalar_product(vector< vector<float> > &vectors) {
    vector<float> products;
    int i=0;
    
    for (vector<float> &single_vector : vectors) {
        // Attention! Initial value must be float (0.0) to get decimal number in result.
        products.push_back(std::inner_product(single_vector.begin(), single_vector.end(), compare_vector.begin(), 0.0));
    
        process_log(world_rank, "Scalar product for row %d (%s) is %f", world_rank+i, 
                vector_to_human(single_vector).c_str(), products[i]);
        i++;
    }
    
    return products;
}

bool ProcessFlow::run(int argc, char** argv) {
    int rows_per_process[world_size],
        data_per_process[world_size], 
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
    
    get_rows_per_process(rows_per_process);
    get_displace(rows_per_process, matrix_cols, data_per_process, displacement);
    int rows_length=data_per_process[world_rank];
    float rows[rows_length];
    
    if (data_per_process[world_rank]==0) {
        process_log(world_rank, "Not enough data for me.");
    } else {
        process_log(world_rank, "Will receive %d values starting from offset %d", data_per_process[world_rank], 
            displacement[world_rank]);
    }
    
    MPI_Scatterv(matrix.data(), data_per_process, displacement, MPI_FLOAT, 
            rows, rows_length, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    if (data_per_process[world_rank]!=0) {
        process_log(world_rank, "Received its data part.");
    }
    
    vector< vector<float> > vectors=array_to_vector(rows, matrix_cols, rows_per_process[world_rank]);
    vector<float> process_products = scalar_product(vectors);
    
    float products[matrix_rows];
    get_displace(rows_per_process, 1, data_per_process, displacement);
    MPI_Gatherv(process_products.data(), data_per_process[world_rank], MPI_FLOAT, products, data_per_process, 
            displacement, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    if (is_master()) {
        int min=0;
        for (int i = 1; i < matrix_rows; i++) {
            if (products[i] < products[min]) {
                min=i;
            }
        }
        
        process_log("The smallest scalar product is for row %d with value %f.", min, products[min]);
    }
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