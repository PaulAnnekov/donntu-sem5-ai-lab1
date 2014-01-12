#include "lib.hpp"

#include <mpich2/mpi.h>
#include <vector>
#include <algorithm>

using namespace std;

void start_slave(int master_rank) {
    MPI_Status status;
    int rank;
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    
    // While we are still alive - wait and process vectors from master.
    while(true) {
        vector<float> float_vector = mpi_receive_vector(master_rank, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
        process_log(rank, "Has got float array of size %d with tag %d", float_vector.size(), status.MPI_TAG);
        
        std::sort(float_vector.begin(), float_vector.end(), [](float a, float b)
        {
          return a < b;
        });
        
        MPI_Send(&float_vector[0], float_vector.size(), MPI_FLOAT, master_rank, status.MPI_TAG, MPI_COMM_WORLD);
    }
}