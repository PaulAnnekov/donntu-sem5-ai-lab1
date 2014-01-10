#include "lib.hpp"
#include "master.hpp"
#include "slave.hpp"

#include <cstdlib>
#include <mpich2/mpi.h>

using namespace std;

int main(int argc, char** argv) {
    if (argc != 2) {
        log("You must specify input vectors. Smth like 12,-32.04;4.03,905");
        return EXIT_FAILURE;
    }

    int rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    if (rank==0) {
        start_master(argv);
    } else {
        start_slave();
    }

    MPI_Finalize();
    
    return EXIT_SUCCESS;
}