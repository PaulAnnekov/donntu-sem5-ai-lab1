#include "process_flow.hpp"

#include <cstdlib>
#include <mpich2/mpi.h>

using namespace std;

int main(int argc, char** argv) {
    int rank, size;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    
    ProcessFlow process_flow;
    bool success=process_flow.run(argc, argv);
    
    MPI_Finalize();
    
    return success ? EXIT_SUCCESS : EXIT_FAILURE;
}