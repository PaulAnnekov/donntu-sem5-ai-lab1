#include <iostream>
#include <string>
#include <cstdarg>
#include <mpi.h>
#include <vector>

using namespace std;

void process_log(int rank, std::string message, ...) {
    message.insert(0, "Process #" + std::to_string(rank) + ": ");
    message.append("\n");
    
    va_list args;
    va_start(args, message);

    vprintf(message.c_str(), args);

    va_end(args);
}

void process_log(std::string message, ...) {
    message.insert(0, "Main process (#0): ");
    message.append("\n");
    
    va_list args;
    va_start(args, message);

    vprintf(message.c_str(), args);

    va_end(args);
}

vector<float> mpi_receive_vector(int source, int tag, MPI_Comm comm, MPI_Status *status) {
    int length, rank;
    
    MPI_Comm_rank(comm, &rank);
    MPI_Probe(source, tag, comm, status);
    MPI_Get_count(status, MPI_FLOAT, &length);
    
    vector<float> float_vector(length);
    
    MPI_Recv(&float_vector[0], length, MPI_FLOAT, source, tag, comm, status);
    
    return float_vector;
}