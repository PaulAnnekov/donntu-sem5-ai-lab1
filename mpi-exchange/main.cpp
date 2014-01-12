#include "master.hpp"
#include "slave.hpp"

#include <cstdlib>
#include <mpich2/mpi.h>

using namespace std;

int main(int argc, char** argv) {
    int rank, size;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    
    if (rank==0) {
        start_master(argc, argv);
    } else {
        start_slave(0);
    }

    MPI_Finalize();
    
    return EXIT_SUCCESS;
}