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
    if (argc != 2) {
        process_log(
            "You must specify matrix size. Something like: 42"
        );
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

void ProcessFlow::get_displace(int *rows_per_process, int *displacement) {
    int min = matrix_size / world_size,
        extra = matrix_size % world_size,
        k = 0;
    
    for (int i = 0; i < world_size; i++) {
        rows_per_process[i] = min;
        if (i < extra) {
            rows_per_process[i] += 1;
        }
        
        displacement[i] = k;
        k += rows_per_process[i];
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
    
    for (int i = 0; i < vectors.size(); i += 2) {
        // Attention! Initial value must be float (0.0) to get decimal number in result.
        products.push_back(std::inner_product(vectors[i].begin(), vectors[i].end(), vectors[i+1].begin(), 0.0));
    
        process_log(world_rank, "Scalar product for row and column %d (%s and %s) is %f", world_rank + i / 2, 
                vector_to_human(vectors[i]).c_str(), vector_to_human(vectors[i+1]).c_str(), products[i / 2]);
    }
    
    return products;
}

vector<float> ProcessFlow::matrix_prepare(vector< vector<float> > const &matrix) {
    vector<float> send_data;
    send_data.reserve(matrix_size*2);
    
    for (int i = 0; i < matrix_size; i++) {
        send_data.insert(send_data.end(),matrix[i].begin(),matrix[i].end());
        
        for (int j = 0; j < matrix_size; j++) {
            send_data.push_back(matrix[j][i]);
        }
    }
    
    return send_data;
}

bool ProcessFlow::run(int argc, char** argv) {
    int rows_per_process[world_size],
        displacement[world_size];
    double start_time;
    vector<float> send_data;
    
    if (is_master()) {
        start_time=MPI_Wtime();
        if (!check(argc)) {
            MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        }
        
        vector< vector<float> > matrix = parse_input(argv[1]);
        send_data = matrix_prepare(matrix);
        
        process_log("Matrix has %d rows and columns", matrix_size);
    }
    
    MPI_Bcast(&matrix_size, 1, MPI_INT, MASTER_RANK, MPI_COMM_WORLD);
    
    MPI_Datatype input_vectors;
    int block_length[2]={matrix_size, matrix_size};
    int offset[2]={0, matrix_size};
    MPI_Type_indexed(2, block_length, offset, MPI_FLOAT, &input_vectors);
    MPI_Type_commit(&input_vectors);
    
    get_displace(rows_per_process, displacement);
    float raw_vectors[rows_per_process[world_rank]*2*matrix_size];
    
    if (rows_per_process[world_rank]==0) {
        process_log(world_rank, "Not enough data for me.");
    } else {
        process_log(world_rank, "Will receive %d values starting from offset %d", rows_per_process[world_rank], 
            displacement[world_rank]);
    }
    
    MPI_Scatterv(send_data.data(), rows_per_process, displacement, input_vectors, 
            raw_vectors, rows_per_process[world_rank], input_vectors, MASTER_RANK, MPI_COMM_WORLD);
    
    if (rows_per_process[world_rank]!=0) {
        process_log(world_rank, "Received its data part.");
    }
    
    vector< vector<float> > vectors=array_to_vector(raw_vectors, matrix_size, rows_per_process[world_rank] * 2);
    vector<float> process_products = scalar_product(vectors);
    
    float products[matrix_size];
    MPI_Gatherv(process_products.data(), rows_per_process[world_rank], MPI_FLOAT, products, rows_per_process, 
            displacement, MPI_FLOAT, MASTER_RANK, MPI_COMM_WORLD);
    
    if (is_master()) {
        int min=0;
        for (int i = 1; i < matrix_size; i++) {
            if (products[i] < products[min]) {
                min=i;
            }
        }
        
        process_log("The smallest scalar product is for row %d with value %f", min, products[min]);
        
        process_log("Processed in %f seconds", MPI_Wtime()-start_time);
    }
}

vector< vector<float> > ProcessFlow::parse_input(const char* arg_size) {
    matrix_size=atof(arg_size);
    vector< vector<float> > matrix;
    
    std::default_random_engine generator;
    std::uniform_real_distribution<float> distribution(random_from, random_to);
    process_log("Generating random matrix");
    for (int i = 0; i < matrix_size; i++) {
        vector<float> row;
        
        for (int j = 0; j < matrix_size; j++) {
            row.push_back(distribution(generator));
        }
        process_log("Row %d: %s", i, vector_to_human(row).c_str());
        
        matrix.push_back(row);
    }
    
    return matrix;
}