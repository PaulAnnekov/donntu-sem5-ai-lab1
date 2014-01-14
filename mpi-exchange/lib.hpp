#ifndef LIB_HPP
#define	LIB_HPP

#define MPIE_TAG_FINALIZE 0
#define MPIE_TAG_OFFSET 1000

#include <string>
#include <vector>
#include <mpi.h>

void process_log(int rank, std::string message, ...);
void process_log(std::string message, ...);

/**
 * MPI blocking receive of vector with unknown size.
 */
std::vector<float> mpi_receive_vector(int source, int tag, MPI_Comm comm, MPI_Status *status);

#endif	/* LIB_HPP */

