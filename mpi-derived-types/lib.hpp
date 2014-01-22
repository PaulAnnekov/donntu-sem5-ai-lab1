#ifndef LIB_HPP
#define	LIB_HPP

#include <string>
#include <mpi.h>

/**
 * Logs message taking into account a process rank.
 * It uses syntax similar to printf.
 * 
 * @param rank Process rank.
 * @param message Message to log.
 * @param ... Parameters for message.
 */
void process_log(int rank, std::string message, ...);

/**
 * Logs message as master process.
 * It uses syntax similar to printf.
 * 
 * @param message Message to log.
 * @param ... Parameters for message.
 */
void process_log(std::string message, ...);

#endif	/* LIB_HPP */

