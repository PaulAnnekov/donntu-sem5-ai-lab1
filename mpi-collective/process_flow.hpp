#ifndef MASTER_HPP
#define	MASTER_HPP

#include <vector>

class ProcessFlow {

    struct binary_matrix {
        int rows, cols;
        std::vector<float> data;
    };

    int world_size, world_rank;
    
    /**
     * Converts human-readable representation of list of vectors to std::vector of vectors.
     * 
     * @param string_vectors String that stores list of vectors in the following format: x1,y1,...;x2,y2,...;...
     * @return Vector of vectors.
     */
    binary_matrix parse_input(const char* string_vectors);
    
    bool is_master();
    bool check(int argc);
    void displace_get(int rows_count, int cols_count, int *send_count, int *displacement);
    
public:
    ProcessFlow ();
    /**
     * Controls master process.
     * 
     * @param argc Value from main() function.
     * @param argv Value from main() function.
     */
    bool run(int argc, char **argv);
};

#endif	/* MASTER_HPP */

