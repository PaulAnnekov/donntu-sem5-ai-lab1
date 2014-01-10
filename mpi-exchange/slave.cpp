#include <mpich2/mpi.h>

void start_slave(int source_rank) {
//    MPI_Status status;
//    int number_amount;
//    
//    // Probe for an incoming message from process zero
//    MPI_Probe(0, 0, MPI_COMM_WORLD, &status);
// 
//    // When probe returns, the status object has the size and other
//    // attributes of the incoming message. Get the size of the message
//    MPI_Get_count(&status, MPI_INT, &number_amount);
// 
//    // Allocate a buffer just big enough to hold the incoming numbers
//    int* number_buf = (int*)malloc(sizeof(int) * number_amount);
// 
//    // Now receive the message with the allocated buffer
//    MPI_Recv(number_buf, number_amount, MPI_INT, 0, 0, MPI_COMM_WORLD,
//             MPI_STATUS_IGNORE);
//    printf("1 dynamically received %d numbers from 0.\n",
//           number_amount);
//    free(number_buf);
}