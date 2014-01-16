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