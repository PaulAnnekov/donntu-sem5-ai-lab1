#include "process_flow.hpp"

#include <cstdlib>
#include <mpi.h>

using namespace std;

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    
    ProcessFlow process_flow;
    bool success=process_flow.run(argc, argv);
    
    MPI_Finalize();
    
    return success ? EXIT_SUCCESS : EXIT_FAILURE;
}